extends Node
## VERIFICAREA TAVERNEI — catalogul meselor, lista de cuvinte și Cuvântul Ascuns.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_taverna.tscn
##
## ─────────────────────────────────────────────────────────────
## CE BATE, ȘI DE CE ÎN ORDINEA ASTA
##
##   1. CATALOGUL — un rând stricat (scenă care nu există, scenă care nu e un
##      `Joc`) nu se vede decât în clipa în care deschizi masa, adică în joc.
##      Aici se vede la fiecare rulare, pe toate rândurile deodată.
##   2. LISTELE — sunt DATE, deci se pot strica dintr-o scăpare de tastatură:
##      un cuvânt de patru litere în listă ar fi o partidă imposibilă, iar unul
##      cu „ă" ar fi una pe care n-o poți tasta. Regula „fără diacritice" e
##      scrisă ca decizie în antetul lui `cuvantul.gd`; aici devine un verdict.
##   3. MARCAREA — regula jocului, bătută FĂRĂ ecran, fiindcă e `static`.
##      Partea grea sunt literele duble, și de-aia are secțiunea ei.
##   4. PARTIDELE JUCATE CU SCENA ADEVĂRATĂ — proba că cele două jumătăți se
##      leagă: regula de mai sus, grila, tastatura și contractul `Joc`.
##   5. ECRANELE — Taverna și meniul, MĂSURATE pe pânza adevărată. Secțiunea
##      asta există din cauza ecranului de loadout, care a ieșit 692 px pe o
##      pânză de 648 fără ca nimeni s-o știe: de atunci, un ecran nou se
##      măsoară, nu se admiră.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## **Dacă CUVINTELE SUNT CUVINTE.** Că „tiraj" e românește și „tiraq" nu e o
## afirmație despre limbă, iar sursa listei sunt EU — exact situația celor 2046
## de note scrise de mână, despre care CLAUDE.md spune că „singura verificare e
## citirea". 308 cuvinte se citesc într-un sfert de oră; secțiunea 2 apără doar
## forma lor.
##
## **Dacă e DISTRACTIV.** Câte încercări cere un cuvânt bun, dacă lista are
## prea multe cuvinte rare — se joacă, nu se bifează.

const CUVANTUL := preload("res://scenes/taverna/cuvantul/cuvantul.gd")
const SCENA_CUVANTUL := preload("res://scenes/taverna/cuvantul/cuvantul.tscn")
const SCENA_TAVERNA := preload("res://scenes/taverna/taverna.tscn")
const SCENA_MENIU := preload("res://scenes/meniu/meniu.tscn")
const TAVERNA := preload("res://scenes/taverna/taverna.gd")

## Câte perechi (ghicire, cuvânt) se bat în secțiunea MARCAREA. Regula are patru
## feluri de a fi greșită și toate patru se văd pe litere duble, care apar rar
## într-o pereche trasă la întâmplare — deci multe.
const PERECHI_MARCATE := 4000

## Sub atâtea cuvinte, jocul se repetă într-o săptămână. Nu e o țintă de
## conținut, e o podea: ținta e scrisă în `progres.md`.
const PODEA_CUVINTE := 100

## Sub atâtea ghiciri acceptate, filtrul din dicționar începe să refuze cuvinte
## adevărate — adică se întoarce exact problema pentru care stătuse stins.
## Extragerea din hunspell dă ~13.000; podeaua e departe, dinadins, fiindcă ea
## apără împotriva unei extrageri STRICATE, nu a uneia sărace.
const PODEA_ACCEPTATE := 5000

## Pânza jocului, din `project.godot` (valorile implicite ale lui Godot 4).
const PANZA := Vector2(1152, 648)

## UNDE SCRIE VERIFICAREA ASTA. `Arhiva.dosar` se mută pe prima linie din
## `_ready`, ca la `verifica_salvarea`, iar dosarul se golește la început și la
## final.
##
## Nu e o grijă teoretică, și n-a fost mereu adevărat: secțiunea 4 cheamă
## `_pe_joc_terminat`, care scrie sacul pe disc; de pe 3 noiembrie 2026,
## `_deschide_masa` scrie și „ți-am arătat regulile". Fără rândul ăsta, o
## rulare a verificării ți-ar fi MÂNCAT prima dată: ai fi deschis Cuvântul
## Ascuns în joc, iar regulile n-ar mai fi apărut niciodată — fiindcă le
## „văzuse" o unealtă.
const DOSAR := "user://verificare_taverna/"

var tot_bun := true
var cuvinte: Array[String] = []
var acceptate: Array[String] = []
## Verdictele strânse de `_lista`, care întoarce cuvinte, nu adevăr.
var tot_bun_liste := true


func _ready() -> void:
	print("\n══ VERIFICAREA TAVERNEI ══\n")
	print("Dosar de probă: %s" % DOSAR)
	Arhiva.dosar = DOSAR
	_goleste_dosarul()

	tot_bun = _catalogul() and tot_bun
	tot_bun = _cuvintele() and tot_bun
	tot_bun = _marcarea() and tot_bun
	tot_bun = await _partidele() and tot_bun
	tot_bun = await _ecranele() and tot_bun
	tot_bun = await _regulile() and tot_bun
	_goleste_dosarul()

	print("\n══ %s ══\n" % ("TOTUL E BUN" if tot_bun else "SUNT PROBLEME, vezi mai sus"))
	get_tree().quit(0 if tot_bun else 1)


func _verdict(bun: bool, text: String) -> bool:
	print("    %s %s" % ["OK  " if bun else "PICĂ", text])
	return bun


# ─────────────────────────────────────────────────────────────
# 1. CATALOGUL
# ─────────────────────────────────────────────────────────────

func _catalogul() -> bool:
	print("  CATALOGUL MESELOR")
	var rezultat := true

	var chei := {}
	var gata := 0
	for m in Mese.CATALOG:
		var cheie := String(m.get("cheie", ""))
		rezultat = _verdict(cheie != "" and not chei.has(cheie),
			"cheie nevidă și nerepetată: %s" % cheie) and rezultat
		chei[cheie] = true
		rezultat = _verdict(String(m.get("nume", "")) != "" and String(m.get("rol", "")) != "",
			"%s are nume și rol" % cheie) and rezultat

		var cale := String(m.get("scena", ""))
		if cale == "":
			# O masă în lucru. Apare pe ecran, stinsă — vezi `mese.gd`.
			print("         (%s e în lucru)" % cheie)
			continue
		gata += 1
		var exista := ResourceLoader.exists(cale)
		rezultat = _verdict(exista, "%s: scena există (%s)" % [cheie, cale]) and rezultat
		if not exista:
			continue
		# Că scena e un `Joc` NU se poate afla din calea ei: o scenă care nu e
		# nu poate fi pornită și n-ar striga niciodată `terminat`, adică
		# Taverna ar aștepta la nesfârșit. Deci se instanțiază și se întreabă.
		var nod = (load(cale) as PackedScene).instantiate()
		rezultat = _verdict(nod is Joc, "%s: scena extinde `Joc`" % cheie) and rezultat
		nod.free()

	rezultat = _verdict(gata >= 1, "cel puțin o masă se poate juca (%d)" % gata) and rezultat
	rezultat = _verdict(Mese.cate_sunt_gata() == gata,
		"`cate_sunt_gata()` spune tot %d" % gata) and rezultat
	rezultat = _verdict(Mese.masa("cuvantul_ascuns").has("nume")
		and Mese.masa("nu_exista").is_empty(),
		"`masa()` găsește ce există și întoarce gol pentru ce nu") and rezultat
	return rezultat


# ─────────────────────────────────────────────────────────────
# 2. CUVINTELE
# ─────────────────────────────────────────────────────────────

func _cuvintele() -> bool:
	print("  LISTELE DE CUVINTE")
	var rezultat := true

	# DOUĂ liste, cu aceleași cerințe de formă și cu roluri diferite (vezi
	# antetul lui `cuvantul.gd`). Forma se bate o singură dată, într-o funcție:
	# două copii ale acelorași verdicte ar fi avut două șanse să se despartă.
	cuvinte = _lista(CUVANTUL.CALE_CUVINTE, "răspunsurile", PODEA_CUVINTE)
	acceptate = _lista(CUVANTUL.CALE_ACCEPTATE, "ghicirile acceptate", PODEA_ACCEPTATE)
	rezultat = tot_bun_liste and rezultat
	if cuvinte.is_empty() or acceptate.is_empty():
		return false

	# LEGĂTURA DINTRE CELE DOUĂ, și singurul verdict care nu e despre o listă,
	# ci despre perechea lor: un răspuns care n-ar fi acceptat ca ghicire e un
	# cuvânt pe care jocul ÎL ASCUNDE ȘI ÎL REFUZĂ. S-ar vedea o dată la 308
	# partide, în partida aia, după cinci încercări bune.
	var in_dictionar := {}
	for c in acceptate:
		in_dictionar[c] = true
	var neacceptate: Array[String] = []
	for c in cuvinte:
		if not in_dictionar.has(c):
			neacceptate.append(c)
	rezultat = _verdict(neacceptate.is_empty(),
		"toate cele %d răspunsuri sunt primite ca ghiciri%s"
		% [cuvinte.size(), _exemple(neacceptate)]) and rezultat

	# Și proba pe dos: tocmai ce ținea filtrul deschis.
	for sonda in ["aeiou", "qwert", "zzzzz"]:
		rezultat = _verdict(not in_dictionar.has(sonda),
			"„%s\" nu e primit" % sonda) and rezultat

	return rezultat


## O listă de cuvinte, cu toate cerințele de formă bătute pe ea.
##
## Întoarce cuvintele; verdictele se adună în `tot_bun_liste`, fiindcă o
## funcție care întoarce și listă, și adevăr, ar fi cerut un dicționar pentru
## un lucru care se citește o dată.
func _lista(cale: String, cine: String, podea: int) -> Array[String]:
	var gasite: Array[String] = []
	var text := FileAccess.get_file_as_string(cale)
	tot_bun_liste = _verdict(text != "", "%s: fișierul se poate citi (%s)" % [cine, cale]) and tot_bun_liste
	if text == "":
		return gasite
	var date = JSON.parse_string(text)
	tot_bun_liste = _verdict(typeof(date) == TYPE_DICTIONARY and date.has("cuvinte"),
		"%s: are cheia cuvinte" % cine) and tot_bun_liste
	if typeof(date) != TYPE_DICTIONARY or not date.has("cuvinte"):
		return gasite
	for c in date["cuvinte"]:
		gasite.append(String(c))

	tot_bun_liste = _verdict(gasite.size() >= podea,
		"%s: sunt destule, %d (podeaua e %d)" % [cine, gasite.size(), podea]) and tot_bun_liste

	# Lungimea. Un cuvânt de altă lungime n-ar încăpea în grilă și n-ar putea fi
	# nici ghicit, nici ascuns.
	var alta_lungime: Array[String] = []
	# Alfabetul. Regula „fără diacritice" din antetul lui `cuvantul.gd`, ca
	# verdict: literele românești care nu sunt pe tastatură (ă â î ș ț) ar face
	# cuvântul imposibil de tastat.
	var cu_diacritice: Array[String] = []
	var cu_majuscule: Array[String] = []
	var vazute := {}
	var dubluri: Array[String] = []
	for c in gasite:
		if c.length() != CUVANTUL.LUNGIME:
			alta_lungime.append(c)
		for i in c.length():
			var cod := c.unicode_at(i)
			if cod < 97 or cod > 122:
				if c.to_lower() != c:
					cu_majuscule.append(c)
				else:
					cu_diacritice.append(c)
				break
		if vazute.has(c):
			dubluri.append(c)
		vazute[c] = true

	tot_bun_liste = _verdict(alta_lungime.is_empty(),
		"%s: toate au %d litere%s" % [cine, CUVANTUL.LUNGIME, _exemple(alta_lungime)]) and tot_bun_liste
	tot_bun_liste = _verdict(cu_diacritice.is_empty(),
		"%s: toate sunt scrise din a-z, fără diacritice%s" % [cine, _exemple(cu_diacritice)]) and tot_bun_liste
	tot_bun_liste = _verdict(cu_majuscule.is_empty(),
		"%s: toate sunt cu litere mici%s" % [cine, _exemple(cu_majuscule)]) and tot_bun_liste
	tot_bun_liste = _verdict(dubluri.is_empty(),
		"%s: niciun cuvânt de două ori%s" % [cine, _exemple(dubluri)]) and tot_bun_liste
	return gasite


func _exemple(rele: Array[String]) -> String:
	if rele.is_empty():
		return ""
	return " — de pildă: %s" % ", ".join(rele.slice(0, 5))


# ─────────────────────────────────────────────────────────────
# 3. MARCAREA
#
# Regula jocului. `static`, deci se bate fără scenă, fără grilă și fără ecran.
# ─────────────────────────────────────────────────────────────

func _marcarea() -> bool:
	print("  MARCAREA")
	var rezultat := true
	var B := CUVANTUL.Semn.BUN
	var A := CUVANTUL.Semn.ALTUNDEVA
	var N := CUVANTUL.Semn.ABSENT

	# Cazurile scrise de mână. Toate sunt despre LITERE DUBLE, fiindcă acolo
	# greșește orice implementare naivă: „e litera în cuvânt?" colorează și
	# al doilea „a" dintr-un cuvânt care are unul singur.
	var cazuri := [
		["carte", "carte", [B, B, B, B, B], "cuvântul întreg e numai verde"],
		["lapte", "carte", [N, B, N, B, B], "a, t, e chiar pe locul lor; l și p nu există"],
		["ceart", "carte", [B, A, A, A, A], "aceleași litere, amestecate: un verde, patru mutate"],
		["aaaaa", "carte", [N, B, N, N, N], "cinci a pe un cuvânt cu unul singur"],
		["salam", "lalea", [N, B, B, A, N], "a și l pe loc, al doilea a mutat"],
		["aaxxx", "salam", [A, B, N, N, N], "un a pe loc, unul mutat, din două existente"],
		["axaxx", "lalea", [A, N, A, N, N], "a de pe locuri greșite, amândouă"],
		["zzzzz", "carte", [N, N, N, N, N], "nicio literă comună"],
	]
	for caz in cazuri:
		var semne := CUVANTUL.marcheaza(String(caz[0]), String(caz[1]))
		var asteptat: Array = caz[2]
		var bun := true
		for i in asteptat.size():
			if semne[i] != asteptat[i]:
				bun = false
		rezultat = _verdict(bun, "%s pe %s: %s" % [caz[0], caz[1], caz[3]]) and rezultat
		if not bun:
			print("         a ieșit %s, se aștepta %s" % [semne, asteptat])

	# INVARIANTELE, pe perechi trase la întâmplare din lista adevărată. Cazurile
	# de mai sus spun „în situația asta, atât"; astea spun ceva care trebuie să
	# fie adevărat în ORICE situație — adică prind și ce nu mi-am imaginat.
	var lungimi_rele := 0
	var prea_multe := 0
	var absente_colorate := 0
	var complet_gresite := 0
	for _i in range(PERECHI_MARCATE):
		var de_ghicit: String = cuvinte.pick_random()
		var ghicire: String = cuvinte.pick_random()
		var semne := CUVANTUL.marcheaza(ghicire, de_ghicit)
		if semne.size() != de_ghicit.length():
			lungimi_rele += 1
			continue
		# a) Pentru fiecare literă, câte au primit culoare nu poate trece peste
		#    câte sunt în cuvânt. Asta e chiar regula literelor duble, scrisă ca
		#    inegalitate: o implementare naivă o calcă de îndată ce ghicirea are
		#    aceeași literă de două ori.
		var colorate := {}
		for i in semne.size():
			if semne[i] != N:
				colorate[ghicire[i]] = int(colorate.get(ghicire[i], 0)) + 1
		for litera in colorate:
			if int(colorate[litera]) > de_ghicit.count(litera):
				prea_multe += 1
				break
		# b) O literă care nu e DELOC în cuvânt nu poate primi culoare.
		for i in semne.size():
			if semne[i] != N and de_ghicit.count(ghicire[i]) == 0:
				absente_colorate += 1
				break
		# c) Ghicirea egală cu cuvântul e numai verde — singurul fel în care
		#    jocul poate ști că ai câștigat.
		if ghicire == de_ghicit:
			for s in semne:
				if s != B:
					complet_gresite += 1
					break

	rezultat = _verdict(lungimi_rele == 0, "semnele sunt cât cuvântul, la toate %d perechile" % PERECHI_MARCATE) and rezultat
	rezultat = _verdict(prea_multe == 0, "nicio literă nu primește mai multă culoare decât are cuvântul (%d scăpări)" % prea_multe) and rezultat
	rezultat = _verdict(absente_colorate == 0, "o literă care lipsește din cuvânt rămâne stinsă (%d scăpări)" % absente_colorate) and rezultat
	rezultat = _verdict(complet_gresite == 0, "cuvântul ghicit exact e numai verde (%d scăpări)" % complet_gresite) and rezultat
	return rezultat


# ─────────────────────────────────────────────────────────────
# 4. PARTIDELE, JUCATE CU SCENA ADEVĂRATĂ
# ─────────────────────────────────────────────────────────────

func _partidele() -> bool:
	print("  PARTIDELE JUCATE")
	var rezultat := true

	# a) SĂMÂNȚA. Contractul din `joc.gd`: același număr = același joc. Pe asta
	#    se va sprijini Decretul Zilei, deci se bate înainte să existe.
	var joc := _masa_noua(12345)
	var intai: String = joc.cuvant
	joc.queue_free()
	joc = _masa_noua(12345)
	var adoua: String = joc.cuvant
	joc.queue_free()
	rezultat = _verdict(intai == adoua,
		"aceeași sămânță dă același cuvânt (%s)" % intai) and rezultat

	var altele := {}
	for s in range(1, 60):
		joc = _masa_noua(s)
		altele[joc.cuvant] = true
		joc.queue_free()
	rezultat = _verdict(altele.size() > 40,
		"semințe diferite dau cuvinte diferite (%d din 59)" % altele.size()) and rezultat

	# b) SACUL. Jocul liber nu repetă până nu se termină lista. Fără asta,
	#    al doilea cuvânt al serii ar putea fi primul.
	Sac.goleste_tot()
	var trase := {}
	var repetate := 0
	for _i in range(cuvinte.size()):
		joc = _masa_noua(Joc.SAMANTA_LIBERA)
		if trase.has(joc.cuvant):
			repetate += 1
		trase[joc.cuvant] = true
		joc.queue_free()
	rezultat = _verdict(repetate == 0,
		"%d partide libere, niciun cuvânt de două ori" % cuvinte.size()) and rezultat
	rezultat = _verdict(trase.size() == cuvinte.size(),
		"sacul a scos toate cele %d cuvinte" % cuvinte.size()) and rezultat
	Sac.goleste_tot()

	# c) O PARTIDĂ CÂȘTIGATĂ, tastată literă cu literă.
	joc = _masa_noua(77)
	var raportat := []
	joc.terminat.connect(func(r): raportat.append(r))
	await _scrie(joc, joc.cuvant)
	rezultat = _verdict(raportat.size() == 1 and bool(raportat[0]["reusit"]),
		"cuvântul tastat corect încheie partida cu «reușit»") and rezultat
	rezultat = _verdict(String(raportat[0]["rezumat"]).contains(joc.cuvant.to_upper()),
		"rezumatul spune cuvântul: %s" % raportat[0]["rezumat"]) and rezultat
	# Contractul din `joc.gd`: semnalul se strigă o singură dată.
	joc.termina(true, "a doua oară")
	rezultat = _verdict(raportat.size() == 1, "`termina` nu strigă de două ori") and rezultat
	joc.queue_free()

	# d) O PARTIDĂ PIERDUTĂ. Șase încercări greșite, și abia a șasea termină.
	joc = _masa_noua(78)
	raportat = []
	joc.terminat.connect(func(r): raportat.append(r))
	var gresit := ""
	for c in cuvinte:
		if c != joc.cuvant:
			gresit = c
			break
	var dupa_cinci := -1
	for incercare in range(CUVANTUL.RANDURI):
		await _scrie(joc, gresit)
		if incercare == CUVANTUL.RANDURI - 2:
			dupa_cinci = raportat.size()
	rezultat = _verdict(dupa_cinci == 0, "după cinci încercări partida merge mai departe") and rezultat
	rezultat = _verdict(raportat.size() == 1 and not bool(raportat[0]["reusit"]),
		"a șasea încercare greșită încheie partida cu «ratat»") and rezultat
	rezultat = _verdict(String(raportat[0]["rezumat"]).contains(joc.cuvant.to_upper()),
		"la final se spune care era cuvântul") and rezultat
	rezultat = _verdict(joc.incercari.size() == CUVANTUL.RANDURI,
		"s-au folosit exact %d rânduri" % CUVANTUL.RANDURI) and rezultat
	joc.queue_free()

	# e) UN RÂND NETERMINAT nu se trimite. Altfel ai pierde o încercare din
	#    patru litere scrise și un Enter apăsat din greșeală.
	joc = _masa_noua(79)
	joc._scrie_litera("a")
	joc._trimite_randul()
	rezultat = _verdict(joc.incercari.is_empty() and joc.mesaj.text != "",
		"un rând de o literă nu se trimite, și ecranul spune de ce") and rezultat

	# e2) UN CUVÂNT CARE NU E CUVÂNT nu se trimite, și NU se șterge.
	#     Jucat cu scena adevărată, fiindcă aici se leagă cele două liste de
	#     regula din `_trimite_randul`: lista o bate secțiunea 2, dar că Enter
	#     chiar o consultă nu se vede decât apăsând Enter. Iar „rândul rămâne"
	#     e o decizie de ecran: ai scris cinci litere, vrei să schimbi una.
	joc.queue_free()
	joc = _masa_noua(80)
	for c in "aeiou":
		joc._scrie_litera(c)
	joc._trimite_randul()
	rezultat = _verdict(joc.incercari.is_empty(),
		"«aeiou» nu consumă o încercare") and rezultat
	rezultat = _verdict(joc.rand_curent == "aeiou",
		"rândul refuzat rămâne scris, ca să-l poți corecta") and rezultat
	rezultat = _verdict(joc.mesaj.text.to_lower().contains("aeiou"),
		"ecranul spune ce a refuzat: %s" % joc.mesaj.text) and rezultat
	# Și imediat după refuz, un cuvânt bun trece: refuzul nu blochează nimic.
	for i in CUVANTUL.LUNGIME:
		joc._sterge_litera()
	await _scrie(joc, cuvinte[0])
	rezultat = _verdict(joc.incercari.size() == 1,
		"după un refuz, un cuvânt adevărat se trimite") and rezultat

	# f) TASTATURA ADEVĂRATĂ. Până aici am chemat funcțiile de-a dreptul; asta e
	#    singura probă că o tastă apăsată ajunge la ele.
	var inainte: String = joc.rand_curent
	var tasta := InputEventKey.new()
	tasta.keycode = KEY_B
	tasta.pressed = true
	get_viewport().push_input(tasta)
	await get_tree().process_frame
	rezultat = _verdict(joc.rand_curent == inainte + "b",
		"o tastă apăsată scrie în rândul curent: %s" % joc.rand_curent) and rezultat

	var cu_sterse: String = joc.rand_curent
	var backspace := InputEventKey.new()
	backspace.keycode = KEY_BACKSPACE
	backspace.pressed = true
	get_viewport().push_input(backspace)
	await get_tree().process_frame
	rezultat = _verdict(joc.rand_curent.length() == cu_sterse.length() - 1,
		"ștergerea scoate o literă") and rezultat
	joc.queue_free()

	# g) TASTELE DE PE ECRAN nu pot lua focusul. Dacă ar putea, Enter ar apăsa
	#    ultima tastă atinsă cu mouse-ul în loc să trimită rândul.
	joc = _masa_noua(80)
	var cu_focus := 0
	for litera in joc.taste:
		if joc.taste[litera].focus_mode != Control.FOCUS_NONE:
			cu_focus += 1
	rezultat = _verdict(cu_focus == 0, "nicio tastă de pe ecran nu ia focusul") and rezultat
	rezultat = _verdict(joc.taste.size() == 26,
		"tastatura are toate cele 26 de litere (%d)" % joc.taste.size()) and rezultat
	rezultat = _verdict(joc.celule.size() == CUVANTUL.RANDURI
		and joc.celule[0].size() == CUVANTUL.LUNGIME,
		"grila e %d × %d" % [CUVANTUL.RANDURI, CUVANTUL.LUNGIME]) and rezultat
	joc.queue_free()
	return rezultat


## O masă nouă, pornită și pusă în arbore — exact drumul Tavernei.
##
## FĂRĂ niciun cadru între `add_child` și `porneste`, și nu din grabă: `_ready`
## rulează ÎN `add_child`, deci nodurile `@onready` există deja când se iese
## din el. Un cadru de așteptare aici ar fi lăsat pornirea de F6 (vezi `_ready`
## din `cuvantul.gd`) s-o ia înainte — adică fiecare partidă din verificare ar
## fi tras DOUĂ bilete din sac, iar secțiunea care numără repetițiile ar fi
## măsurat propria greșeală.
func _masa_noua(samanta: int) -> Node:
	var joc := SCENA_CUVANTUL.instantiate()
	add_child(joc)
	joc.porneste(samanta)
	return joc


## Scrie un cuvânt și apasă Enter, apoi așteaptă dezvăluirea.
func _scrie(joc: Node, cuvant: String) -> void:
	for i in cuvant.length():
		joc._scrie_litera(cuvant[i])
	joc._trimite_randul()
	# Dezvăluirea întoarce celulele una câte una; până nu se termină, jocul nu
	# primește nimic (vezi `in_dezvaluire`).
	# Pașii dintre celule, plus rotirea ÎNTREAGĂ a ultimei. Scris din constante
	# și nu dintr-un număr: de pe 3 noiembrie 2026 dezvăluirea nu mai e o
	# colorare, e o întoarcere, iar o așteptare prea scurtă ar fi tipărit
	# „rândul nu s-a trimis" despre un rând care se trimisese.
	await get_tree().create_timer(
		CUVANTUL.PAS_DEZVALUIRE * (CUVANTUL.LUNGIME - 1)
		+ CUVANTUL.DURATA_INTOARCERE * 2.0 + 0.15).timeout


# ─────────────────────────────────────────────────────────────
# 5. ECRANELE, MĂSURATE
# ─────────────────────────────────────────────────────────────

func _ecranele() -> bool:
	print("  ECRANELE")
	var rezultat := true

	# MĂSURAT PE MINIMUL CERUT, nu pe mărimea pe care o are pe ecran. Pus pe o
	# pânză de 1152 × 648, orice ecran „intră": containerele îi strâng pe copii
	# până încape, iar butonul de jos iese pur și simplu pe sub margine, fără
	# să se plângă. Exact așa a stat ecranul de loadout o zi: arăta bine și
	# cerea 692 px pe 648. Deci întrebarea nu e „cât ocupă", e „cât CERE".
	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	# `set_deferred`, nu `size = ...`: sub un `Node` fără mărime, ancorele scenei
	# ar suprascrie mărimea pusă de mână la finalul cadrului, și Godot o spune.
	taverna.set_deferred("size", PANZA)
	await get_tree().process_frame
	await get_tree().process_frame

	var margini: Control = taverna.get_node("Margini")
	var cerut := margini.get_combined_minimum_size()
	print("         Taverna cere %d × %d px, pe o pânză de %d × %d"
		% [cerut.x, cerut.y, PANZA.x, PANZA.y])
	rezultat = _verdict(cerut.x <= PANZA.x,
		"cele %d mese încap în lățime (%d px, rezervă %d)"
		% [Mese.CATALOG.size(), cerut.x, PANZA.x - cerut.x]) and rezultat
	rezultat = _verdict(cerut.y <= PANZA.y,
		"ecranul Tavernei încape în înălțime (%d px, rezervă %d)"
		% [cerut.y, PANZA.y - cerut.y]) and rezultat

	# ANTETUL SUPRAPUS. Titlul ține toată lățimea și se centrează în ea, iar
	# butoanele plutesc peste el, ancorate la dreapta (vezi antetul lui
	# `taverna.gd`). Două noduri suprapuse nu se feresc unul de altul: un titlu
	# prea lung intră sub butoane și NICIUN container nu se plânge. Deci se
	# măsoară, pe fiecare nume din catalog — și pe cel mai rău caz, ecranul cu
	# mese, unde butonul „Mesele" e ascuns dar locul lui tot nu se eliberează.
	var titlu: Label = taverna.get_node("%Titlu")
	var butoane: Control = taverna.get_node("Margini/Coloana/Antet/Butoane")
	var latime_butoane := butoane.get_combined_minimum_size().x
	# Lățimea pe care o are antetul: pânza, fără marginile laterale.
	var latime_antet := PANZA.x - 2 * 28
	for m in Mese.CATALOG:
		titlu.text = String(m["nume"])
		await get_tree().process_frame
		# Centrat, titlul se întinde de o parte și de alta a mijlocului.
		var jumatate := titlu.get_combined_minimum_size().x / 2.0
		var pana_la_butoane := latime_antet / 2.0 - latime_butoane
		rezultat = _verdict(jumatate <= pana_la_butoane,
			"titlul „%s\" nu ajunge sub butoane (%d px de la mijloc, loc până la ele %d)"
			% [m["nume"], jumatate, pana_la_butoane]) and rezultat
	titlu.text = "TAVERNA"

	# ȘI ECRANUL CU MASA DESCHISĂ, în AMÂNDOUĂ stările lui.
	#
	# Măsurătoarea de mai sus se uită la ecranul cu mese; a lui se vedea, a
	# jocului nu — iar jocul era chiar cel care ieșea pe sub margine. Și nu
	# oricând: numai DUPĂ ce-l câștigai, fiindcă rândul de rezultat apărea
	# abia atunci și fura înălțime de la chenar. Deci se măsoară de două ori,
	# iar al treilea verdict cere ca cele două numere să fie EGALE: un ecran
	# care-și schimbă înălțimea la jumătatea unui joc se poate strica într-o
	# stare și arăta bine în cealaltă.
	taverna._deschide_masa(Mese.masa("cuvantul_ascuns"))
	await get_tree().process_frame
	await get_tree().process_frame
	var cerut_joc := margini.get_combined_minimum_size()
	print("         masa deschisă cere %d × %d px" % [cerut_joc.x, cerut_joc.y])
	rezultat = _verdict(cerut_joc.y <= PANZA.y,
		"Cuvântul Ascuns încape în înălțime (%d px, rezervă %d)"
		% [cerut_joc.y, PANZA.y - cerut_joc.y]) and rezultat

	taverna._pe_joc_terminat({"reusit": true, "rezumat": "COPAC, din 3 încercări."})
	await get_tree().process_frame
	await get_tree().process_frame
	var cerut_final := margini.get_combined_minimum_size()
	print("         după ce l-ai câștigat cere %d × %d px" % [cerut_final.x, cerut_final.y])
	rezultat = _verdict(cerut_final.y <= PANZA.y,
		"ecranul de după câștig încape în înălțime (%d px, rezervă %d)"
		% [cerut_final.y, PANZA.y - cerut_final.y]) and rezultat
	rezultat = _verdict(is_equal_approx(cerut_final.y, cerut_joc.y),
		"câștigul nu schimbă înălțimea cerută (%d px înainte, %d după)"
		% [cerut_joc.y, cerut_final.y]) and rezultat

	taverna.queue_free()

	var meniu := SCENA_MENIU.instantiate()
	add_child(meniu)
	meniu.set_deferred("size", PANZA)
	await get_tree().process_frame
	await get_tree().process_frame
	var margini_meniu: Control = meniu.get_node("Margini")
	var carti: Control = meniu.get_node("Margini/Coloana/Carti")
	var cerut_meniu := margini_meniu.get_combined_minimum_size()
	print("         meniul cere %d × %d px; rândul de pagini, %d px"
		% [cerut_meniu.x, cerut_meniu.y, carti.get_combined_minimum_size().x])
	for pagina in carti.get_children():
		print("           %s: %d px" % [pagina.name, (pagina as Control).get_combined_minimum_size().x])
	rezultat = _verdict(cerut_meniu.x <= PANZA.x,
		"cele trei pagini din meniu încap în lățime (%d px, rezervă %d)"
		% [cerut_meniu.x, PANZA.x - cerut_meniu.x]) and rezultat
	rezultat = _verdict(cerut_meniu.y <= PANZA.y,
		"meniul încape în înălțime (%d px, rezervă %d)"
		% [cerut_meniu.y, PANZA.y - cerut_meniu.y]) and rezultat
	rezultat = _verdict(carti.get_child_count() == 3, "meniul are trei pagini") and rezultat
	meniu.queue_free()
	# `queue_free` scoate nodul la finalul cadrului. Fără cele două cadre de
	# mai jos, `quit()` vine înainte, iar Godot se plânge la ieșire de obiecte
	# rămase în viață — un avertisment care nu înseamnă nimic aici, dar care
	# într-o zi ar ascunde unul care înseamnă.
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


# ─────────────────────────────────────────────────────────────
# 6. REGULILE
#
# „O singură dată" e o promisiune făcută jucătorului, iar promisiunile de felul
# ăsta se strică în tăcere: a doua oară când deschizi masa, panoul sau apare,
# sau nu, și nimeni nu se plânge în niciunul din cazuri. Deci se joacă.
# ─────────────────────────────────────────────────────────────

func _regulile() -> bool:
	print("  REGULILE")
	var rezultat := true

	# a) CONTRACTUL. O masă fără reguli nu plătește nimic, iar una cu reguli le
	#    COMPUNE din constantele ei, nu le scrie de mână — altfel textul ar
	#    rămâne în urma codului în ziua în care „șase încercări" devine cinci.
	var gol := Joc.new()
	rezultat = _verdict(gol.reguli() == null,
		"o masă care nu-și scrie regulile întoarce `null`") and rezultat
	gol.free()

	var masa := SCENA_CUVANTUL.instantiate()
	var cuprins: Control = masa.reguli()
	rezultat = _verdict(cuprins != null, "Cuvântul Ascuns își scrie regulile") and rezultat

	# Tot textul din nod, adunat: numerele trebuie să vină din constante, nu
	# dintr-un „5" scris de mână care ar rămâne în urmă.
	var scris := _textul_din(cuprins)
	rezultat = _verdict(scris.contains(str(CUVANTUL.LUNGIME)) and scris.contains(str(CUVANTUL.RANDURI)),
		"regulile spun câte litere (%d) și câte încercări (%d)"
		% [CUVANTUL.LUNGIME, CUVANTUL.RANDURI]) and rezultat

	# Cele trei culori sunt ARĂTATE, pe celule adevărate: se caută fondul
	# fiecărei celule din nod, nu un nume de culoare scris în text.
	var fonduri := _fondurile_din(cuprins)
	for pereche in [["bun", CUVANTUL.CULOARE_BUN], ["altundeva", CUVANTUL.CULOARE_ALTUNDEVA],
			["absent", CUVANTUL.CULOARE_ABSENT]]:
		rezultat = _verdict(fonduri.has((pereche[1] as Color).to_html(false)),
			"regulile ARATĂ culoarea „%s\" pe o celulă, n-o numesc" % pereche[0]) and rezultat

	# Și exemplele sunt cuvinte pe care jocul le-ar PRIMI. Un rând de exemplu
	# pe care l-ar refuza ar fi cea mai proastă primă impresie cu putință.
	var in_dictionar := {}
	for c in acceptate:
		in_dictionar[c] = true
	for e in CUVANTUL.EXEMPLE_REGULI:
		var cuvant := String(e["cuvant"])
		rezultat = _verdict(in_dictionar.has(cuvant),
			"exemplul „%s\" e un cuvânt primit ca ghicire" % cuvant.to_upper()) and rezultat
		rezultat = _verdict(cuvant.length() == CUVANTUL.LUNGIME
			and int(e["loc"]) >= 0 and int(e["loc"]) < cuvant.length(),
			"exemplul „%s\" are %d litere, iar litera arătată e una din ele"
			% [cuvant.to_upper(), CUVANTUL.LUNGIME]) and rezultat
	cuprins.free()
	masa.free()

	# b) PRIMA AȘEZARE o deschide, a doua nu. Jucat cu scena adevărată.
	var vazute_inainte := TAVERNA._reguli_vazute.duplicate()
	TAVERNA._reguli_vazute.clear()

	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	taverna.set_deferred("size", PANZA)
	await get_tree().process_frame
	await get_tree().process_frame

	var panou: Control = taverna.get_node("%PanouReguli")
	var buton: Button = taverna.get_node("%ButonReguli")
	rezultat = _verdict(not panou.visible, "pe ecranul cu mese panoul e închis") and rezultat
	rezultat = _verdict(not buton.visible,
		"pe ecranul cu mese nu e niciun buton „i\"") and rezultat

	taverna._deschide_masa(Mese.masa("cuvantul_ascuns"))
	await get_tree().process_frame
	rezultat = _verdict(panou.visible, "prima așezare la masă deschide regulile") and rezultat
	rezultat = _verdict(buton.visible, "butonul „i\" e acolo") and rezultat

	# c) CÂT E PANOUL DESCHIS, TASTELE NU AJUNG LA JOC. Aici e deosebirea față
	#    de popup-ul din Practice: masa ascultă tastatura adevărată, deci fără
	#    oprire ai fi scris litere în grilă citind regulile despre ea.
	var inainte: String = taverna.joc.rand_curent
	var tasta := InputEventKey.new()
	tasta.keycode = KEY_B
	tasta.pressed = true
	get_viewport().push_input(tasta)
	await get_tree().process_frame
	rezultat = _verdict(taverna.joc.rand_curent == inainte,
		"o tastă apăsată peste reguli nu scrie în grilă") and rezultat

	taverna._inchide_regulile()
	await get_tree().process_frame
	get_viewport().push_input(tasta)
	await get_tree().process_frame
	rezultat = _verdict(taverna.joc.rand_curent == inainte + "b",
		"după ce panoul se închide, tastatura merge din nou") and rezultat

	# d) A DOUA AȘEZARE, și „Încă unul" între ele: niciuna nu redeschide.
	taverna._inca_unul()
	await get_tree().process_frame
	rezultat = _verdict(not panou.visible, "«Încă unul» nu redeschide regulile") and rezultat

	taverna._arata_mesele()
	await get_tree().process_frame
	taverna._deschide_masa(Mese.masa("cuvantul_ascuns"))
	await get_tree().process_frame
	rezultat = _verdict(not panou.visible, "a doua așezare NU mai deschide regulile") and rezultat

	# e) BUTONUL „i" le redeschide oricând — altfel „o singură dată" ar
	#    însemna „o singură șansă".
	taverna._arata_regulile()
	await get_tree().process_frame
	rezultat = _verdict(panou.visible, "butonul „i\" le redeschide") and rezultat
	taverna._inchide_regulile()
	taverna.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

	# f) DRUMUL PRIN DISC. Cheia scrisă trebuie să se întoarcă; un save vechi
	#    (fără cheia asta) înseamnă „n-ai văzut nimic", adică taman purtarea de
	#    la prima instalare — deci nu cere migrare.
	var pe_disc := TAVERNA.spre_dictionar()
	rezultat = _verdict(pe_disc["reguli_vazute"].has("cuvantul_ascuns"),
		"masa deschisă ajunge pe disc: %s" % [pe_disc["reguli_vazute"]]) and rezultat
	TAVERNA.din_dictionar(pe_disc)
	rezultat = _verdict(TAVERNA._reguli_vazute.has("cuvantul_ascuns"),
		"și se întoarce de pe disc") and rezultat
	TAVERNA.din_dictionar({})
	rezultat = _verdict(TAVERNA._reguli_vazute.is_empty(),
		"un save fără cheia asta înseamnă «n-ai văzut nimic»") and rezultat
	TAVERNA.din_dictionar({"reguli_vazute": 7})
	rezultat = _verdict(TAVERNA._reguli_vazute.is_empty(),
		"un save strâmb (un număr în loc de listă) e citit la fel") and rezultat

	TAVERNA._reguli_vazute = vazute_inainte
	return rezultat


## Tot textul dintr-un arbore de noduri, pus cap la cap.
func _textul_din(nod: Node) -> String:
	var adunat := ""
	if nod is Label:
		adunat += (nod as Label).text + "
"
	for copil in nod.get_children():
		adunat += _textul_din(copil)
	return adunat


## Culorile de fond ale tuturor panourilor dintr-un arbore, ca TEXTE (un `Color`
## nu se poate căuta cu `has()` într-un dicționar fără să cadă pe virgulă).
func _fondurile_din(nod: Node) -> Dictionary:
	var gasite := {}
	if nod is PanelContainer:
		var stil = (nod as PanelContainer).get_theme_stylebox("panel")
		if stil is StyleBoxFlat:
			gasite[(stil as StyleBoxFlat).bg_color.to_html(false)] = true
	for copil in nod.get_children():
		gasite.merge(_fondurile_din(copil))
	return gasite


# ─────────────────────────────────────────────────────────────
# DOSARUL DE PROBĂ
# ─────────────────────────────────────────────────────────────

func _goleste_dosarul() -> void:
	if not DirAccess.dir_exists_absolute(DOSAR):
		DirAccess.make_dir_recursive_absolute(DOSAR)
		return
	for nume in DirAccess.get_files_at(DOSAR):
		DirAccess.remove_absolute(Arhiva.cale_catre(String(nume)))

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
##   2. CUVINTELE — sunt DATE, deci se pot strica dintr-o scăpare de tastatură:
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

## Câte perechi (ghicire, cuvânt) se bat în secțiunea MARCAREA. Regula are patru
## feluri de a fi greșită și toate patru se văd pe litere duble, care apar rar
## într-o pereche trasă la întâmplare — deci multe.
const PERECHI_MARCATE := 4000

## Sub atâtea cuvinte, jocul se repetă într-o săptămână. Nu e o țintă de
## conținut, e o podea: ținta e scrisă în `progres.md`.
const PODEA_CUVINTE := 100

## Pânza jocului, din `project.godot` (valorile implicite ale lui Godot 4).
const PANZA := Vector2(1152, 648)

var tot_bun := true
var cuvinte: Array[String] = []


func _ready() -> void:
	print("\n══ VERIFICAREA TAVERNEI ══\n")

	tot_bun = _catalogul() and tot_bun
	tot_bun = _cuvintele() and tot_bun
	tot_bun = _marcarea() and tot_bun
	tot_bun = await _partidele() and tot_bun
	tot_bun = await _ecranele() and tot_bun

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
	print("  LISTA DE CUVINTE")
	var rezultat := true

	var text := FileAccess.get_file_as_string(CUVANTUL.CALE_CUVINTE)
	rezultat = _verdict(text != "", "fișierul se poate citi (%s)" % CUVANTUL.CALE_CUVINTE) and rezultat
	if text == "":
		return false
	var date = JSON.parse_string(text)
	rezultat = _verdict(typeof(date) == TYPE_DICTIONARY and date.has("cuvinte"),
		"are cheia cuvinte") and rezultat
	if typeof(date) != TYPE_DICTIONARY or not date.has("cuvinte"):
		return false
	for c in date["cuvinte"]:
		cuvinte.append(String(c))

	rezultat = _verdict(cuvinte.size() >= PODEA_CUVINTE,
		"sunt destule: %d (podeaua e %d)" % [cuvinte.size(), PODEA_CUVINTE]) and rezultat

	# Lungimea. Un cuvânt de altă lungime n-ar încăpea în grilă și n-ar putea fi
	# ghicit niciodată.
	var alta_lungime: Array[String] = []
	# Alfabetul. Regula „fără diacritice" din antetul lui `cuvantul.gd`, ca
	# verdict: literele românești care nu sunt pe tastatură (ă â î ș ț) ar face
	# cuvântul imposibil de tastat.
	var cu_diacritice: Array[String] = []
	var cu_majuscule: Array[String] = []
	var vazute := {}
	var dubluri: Array[String] = []
	for c in cuvinte:
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

	rezultat = _verdict(alta_lungime.is_empty(),
		"toate au %d litere%s" % [CUVANTUL.LUNGIME, _exemple(alta_lungime)]) and rezultat
	rezultat = _verdict(cu_diacritice.is_empty(),
		"toate sunt scrise din a-z, fără diacritice%s" % _exemple(cu_diacritice)) and rezultat
	rezultat = _verdict(cu_majuscule.is_empty(),
		"toate sunt cu litere mici%s" % _exemple(cu_majuscule)) and rezultat
	rezultat = _verdict(dubluri.is_empty(), "niciun cuvânt de două ori%s" % _exemple(dubluri)) and rezultat
	return rezultat


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
	await get_tree().create_timer(
		CUVANTUL.PAS_DEZVALUIRE * CUVANTUL.LUNGIME + 0.1).timeout


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

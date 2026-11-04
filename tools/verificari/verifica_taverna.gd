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
##   5. DECRETUL — masa care nu are un joc al ei, deci nici o regulă de joc de
##      bătut: are PROMISIUNI („altul în fiecare zi", „o dată pe zi"), iar toate
##      se strică în tăcere, la miezul nopții sau în ziua în care se aprinde a
##      patra masă. Se joacă 1800 de zile, fiindcă o zi costă o socoteală.
##   6. ECRANELE — Taverna și meniul, MĂSURATE pe pânza adevărată. Secțiunea
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
const SUDOKU := preload("res://scenes/taverna/sudoku/sudoku.gd")
const SCENA_SUDOKU := preload("res://scenes/taverna/sudoku/sudoku.tscn")
const DECRETUL := preload("res://scenes/taverna/decretul/decretul.gd")
const SCENA_DECRETUL := preload("res://scenes/taverna/decretul/decretul.tscn")
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

## Câte zile se joacă în secțiunea DECRETUL. Multe și ieftine: alegerea zilei e
## o socoteală pe catalog, nu o scenă, deci cinci ani de decrete costă câteva
## milisecunde. Ce apără numărul e ROTAȚIA — cu zece zile, o masă care apare de
## două ori la rând ar fi putut scăpa.
const ZILE_DECRET := 1800

## Divizorii pe care se bate necorelarea sămânței cu rotația (vezi secțiunea
## DECRETUL). 3 e cel care contează azi — Sudoku își ia nivelul din
## `samanta % 3` — iar ceilalți sunt acolo fiindcă următoarea masă care citește
## sămânța cu un rest nu va fi neapărat împărțită la 3.
const RESTURI_DECRET := [2, 3, 4, 5]

## Câte grile se generează pe fiecare nivel de Sudoku. Puține, dinadins:
## fiecare grilă cere ~80 de numărători de soluții la generare și una la
## verificare, deci numărul ăsta e chiar durata secțiunii. Ce apără el nu e
## varietatea (grilele sunt generate, deci nu se repetă), e GENERATORUL — o
## scoatere care rupe unicitatea s-ar vedea de la prima grilă.
const SEMINTE_SUDOKU := 5

## Fonturile temei, pentru secțiunea CARACTERELE.
const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"

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
	tot_bun = await _sudoku() and tot_bun
	tot_bun = await _decretul() and tot_bun
	tot_bun = await _clicurile() and tot_bun
	tot_bun = await _caracterele() and tot_bun
	_goleste_dosarul()

	# SE AȘTEAPTĂ SĂ SE TERMINE SUNETELE. Verificarea apasă taste și pătrate, iar
	# jocul răspunde cu „corect" și „greșit" (`Sunet.reda`); Taverna pornește și
	# piesa CETATE. Un `AudioStreamPlayer` închis în timp ce încă sună își lasă
	# playback-ul în AudioServer, iar Godot îl numără la ieșire: „14 ObjectDB
	# instances were leaked" și „6 resources still in use". Niciun nod nu
	# rămâne — lista de la `--verbose` e numai `.ogg`-uri — deci nu e un verdict
	# picat, e un rând roșu care într-o zi ar ascunde unul care înseamnă ceva.
	#
	# DOUĂ lucruri, fiindcă sunt două feluri de sunet, iar măsurătoarea le-a
	# despărțit: efectele sunt scurte și se termină dacă le lași (de la 14/6 la
	# 10/4, doar din așteptare), iar piesa de fundal se repetă la nesfârșit și
	# nu se termină niciodată singură — pe ea trebuie s-o oprești. Cu
	# `cu_fade = false`, fiindcă o stingere lină are nevoie de cadre pe care
	# nimeni nu le mai trimite.
	Muzica.opreste(false)
	await get_tree().create_timer(1.5).timeout

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
	# De pe 4 noiembrie 2026 antetul are un nod plutitor și la STÂNGA: butonul
	# „i", mutat aici de pe tăblia mesei, unde cădea peste butoanele de nivel
	# ale lui Sudoku. Titlul e centrat, deci se lovește de cel mai LAT dintre
	# cele două capete — azi dreapta, cu mult, dar un `max` nu presupune asta.
	var buton_i: Control = taverna.get_node("%ButonReguli")
	var latime_butoane: float = maxf(butoane.get_combined_minimum_size().x,
		buton_i.get_combined_minimum_size().x)
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
	# PE FIECARE MASĂ CARE SE POATE JUCA, nu doar pe prima: o masă nouă e un
	# ecran nou, iar ecranul care a cerut secțiunea asta (loadout-ul) arăta
	# bine până în ziua în care a primit un rând în plus.
	for m in Mese.CATALOG:
		if String(m["scena"]) == "":
			continue
		var nume_masa := String(m["nume"])
		taverna._deschide_masa(m)
		await get_tree().process_frame
		await get_tree().process_frame
		var cerut_joc := margini.get_combined_minimum_size()
		print("         %s cere %d × %d px" % [nume_masa, cerut_joc.x, cerut_joc.y])
		rezultat = _verdict(cerut_joc.y <= PANZA.y,
			"%s încape în înălțime (%d px, rezervă %d)"
			% [nume_masa, cerut_joc.y, PANZA.y - cerut_joc.y]) and rezultat
		rezultat = _verdict(cerut_joc.x <= PANZA.x,
			"%s încape în lățime (%d px, rezervă %d)"
			% [nume_masa, cerut_joc.x, PANZA.x - cerut_joc.x]) and rezultat

		# UNELTELE MESEI (vezi `Joc.unelte`). Taverna le atârnă în capătul din
		# stânga al rândului de sub titlu, iar fraza de ajutor stă centrată pe
		# tot rândul — două noduri suprapuse, exact ca titlul și butoanele din
		# antet, deci se măsoară la fel. O masă fără unelte nu lasă nimic acolo.
		var rand_unelte: Control = taverna.get_node("%Unelte")
		var ajutor: Label = taverna.get_node("%Ajutor")
		var scule_asteptate: bool = taverna.joc.unelte() != null 			or rand_unelte.get_child_count() > 0
		if scule_asteptate:
			rezultat = _verdict(rand_unelte.get_child_count() == 1,
				"%s: uneltele mesei sunt atârnate în antet (%d noduri)"
				% [nume_masa, rand_unelte.get_child_count()]) and rezultat
			var latime_scule := rand_unelte.get_combined_minimum_size().x
			# Lățimea TEXTULUI, nu minimul etichetei: ea are autowrap, deci
			# minimul ei e zero și verdictul ar fi trecut mereu, spunând
			# nimic. Prima scriere făcea chiar asta.
			var font := ajutor.get_theme_font("font")
			var marime := ajutor.get_theme_font_size("font_size")
			var jumatate_ajutor: float = font.get_string_size(ajutor.text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, marime).x / 2.0
			var loc := (PANZA.x - 2 * 28) / 2.0 - latime_scule
			rezultat = _verdict(jumatate_ajutor <= loc,
				"%s: fraza de ajutor nu ajunge peste unelte (%d px de la mijloc, loc %d)"
				% [nume_masa, jumatate_ajutor, loc]) and rezultat

		taverna._pe_joc_terminat({"reusit": true, "rezumat": "Gata, din 3 încercări."})
		await get_tree().process_frame
		await get_tree().process_frame
		var cerut_final := margini.get_combined_minimum_size()
		print("         %s, după câștig, cere %d × %d px"
			% [nume_masa, cerut_final.x, cerut_final.y])
		rezultat = _verdict(cerut_final.y <= PANZA.y,
			"%s: ecranul de după câștig încape (%d px, rezervă %d)"
			% [nume_masa, cerut_final.y, PANZA.y - cerut_final.y]) and rezultat
		rezultat = _verdict(is_equal_approx(cerut_final.y, cerut_joc.y),
			"%s: câștigul nu schimbă înălțimea cerută (%d px înainte, %d după)"
			% [nume_masa, cerut_joc.y, cerut_final.y]) and rezultat
		taverna._arata_mesele()
		await get_tree().process_frame
		# Uneltele sunt ale MESEI, deci pleacă odată cu ea: altfel nivelurile
		# lui Sudoku ar fi rămas în antet peste Cuvântul Ascuns, exact cum ar
		# fi rămas regulile lui dacă nu le-ar îngropa cineva.
		rezultat = _verdict(taverna.get_node("%Unelte").get_child_count() == 0,
			"%s: uneltele pleacă odată cu masa" % nume_masa) and rezultat

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


## Cernelurile CELULELOR dintr-un arbore, ca texte: culoarea etichetei din
## fiecare `PanelContainer`.
##
## Fratele lui `_fondurile_din`, și există fiindcă la Sudoku regula se vede în
## CERNEALĂ, nu în fond: cifra dată, cea scrisă de tine și cea care se bate cu
## alta au același pătrat și trei culori de cifră.
##
## Numai din celule, nu din orice etichetă: rândurile de TEXT ale panoului sunt
## scrise cu cremul cifrelor date, deci căutate peste tot ar fi făcut verdictul
## „regulile arată cifra dată" adevărat și într-un panou fără nicio celulă.
func _cernelurile_celulelor_din(nod: Node) -> Dictionary:
	var gasite := {}
	if nod is PanelContainer and nod.get_child_count() > 0 and nod.get_child(0) is Label:
		var eticheta: Label = nod.get_child(0)
		gasite[eticheta.get_theme_color("font_color").to_html(false)] = true
	for copil in nod.get_children():
		gasite.merge(_cernelurile_celulelor_din(copil))
	return gasite


# ─────────────────────────────────────────────────────────────
# 7. SUDOKU
#
# Masa a doua, și prima la care conținutul nu e scris nicăieri: o grilă se
# GENEREAZĂ. Deci nu se poate citi înainte de joc, nici corectată — apărarea e
# că se poate REZOLVA, iar secțiunea asta o rezolvă.
#
# DOUĂ SOCOTELI CARE TREBUIE SĂ CADĂ DE ACORD. Jocul își apără unicitatea cu un
# rezolvitor pe biți, care alege de fiecare dată celula cea mai strâmtă și se
# oprește la a doua soluție. Verificarea o apără cu al ei, scris din liste de
# candidați și dicționare — aceeași idee, altă socoteală. Dacă numai una din
# ele ar greși, grilele ar fi ambigue, iar jucătorul ar afla-o după un sfert de
# oră de muncă bună.
#
# E judecata de la INTRUSUL din Tipare, unde generatorul își apără unicitatea cu
# determinanți și verificarea cu mii de reguli încercate.
# ─────────────────────────────────────────────────────────────

func _sudoku() -> bool:
	print("  SUDOKU — GENERATORUL (%d semințe pe nivel)" % SEMINTE_SUDOKU)
	var rezultat := true
	var medii: Array[float] = []

	for nivel in SUDOKU.NIVELURI.size():
		var nume := String(SUDOKU.NIVELURI[nivel]["nume"])
		var tinta := int(SUDOKU.NIVELURI[nivel]["cifre_date"])
		var forma_rea := 0
		var cu_conflict := 0
		var neunice := 0
		var fara_raspuns := 0
		var nerecunoscute := 0
		var sub_tinta := 0
		var total_date := 0

		for s in range(1, SEMINTE_SUDOKU + 1):
			var rng := RandomNumberGenerator.new()
			rng.seed = nivel * 1000 + s
			var date_grila: Array = SUDOKU.genereaza(nivel, rng)

			# Forma: 81 de numere, fiecare între 0 și 9.
			if date_grila.size() != SUDOKU.CELULE:
				forma_rea += 1
				continue
			for v in date_grila:
				if int(v) < 0 or int(v) > SUDOKU.LATURA:
					forma_rea += 1
					break

			# Cifrele date nu se bat între ele. O grilă pornită stricată n-ar
			# avea nicio soluție, iar jucătorul ar căuta-o la nesfârșit.
			if not _fara_conflicte(date_grila):
				cu_conflict += 1

			var cate := _cate_pline(date_grila)
			total_date += cate
			if cate < tinta:
				sub_tinta += 1

			# UNICITATEA, numărată cu socoteala verificării.
			if _numara_singur(date_grila.duplicate(), 2) != 1:
				neunice += 1

			# ȘI RĂSPUNSUL, găsit din nou: trebuie să fie o grilă plină validă,
			# iar `e_gata` al jocului trebuie să fie de acord că e gata. Două
			# drumuri către același adevăr — al meu zice „e validă", al lui
			# „nicio cifră nu se bate cu alta".
			var raspuns := _rezolva_singur(date_grila.duplicate())
			if raspuns.is_empty() or not _e_valida_plina(raspuns):
				fara_raspuns += 1
			else:
				var ca_int: Array[int] = []
				ca_int.assign(raspuns)
				if not SUDOKU.e_gata(ca_int):
					nerecunoscute += 1

		var medie := float(total_date) / float(SEMINTE_SUDOKU)
		medii.append(medie)
		print("         %s: țintă %d cifre date, măsurat %.1f în medie"
			% [nume, tinta, medie])
		rezultat = _verdict(forma_rea == 0,
			"%s: toate grilele au %d celule cu cifre 0-%d"
			% [nume, SUDOKU.CELULE, SUDOKU.LATURA]) and rezultat
		rezultat = _verdict(cu_conflict == 0,
			"%s: cifrele date nu se bat niciodată între ele" % nume) and rezultat
		rezultat = _verdict(neunice == 0,
			"%s: fiecare grilă are EXACT un răspuns (numărat de verificare)" % nume) and rezultat
		rezultat = _verdict(fara_raspuns == 0,
			"%s: răspunsul, găsit din nou, e o grilă plină validă" % nume) and rezultat
		rezultat = _verdict(nerecunoscute == 0,
			"%s: și `e_gata()` al jocului îl recunoaște ca încheiat" % nume) and rezultat
		rezultat = _verdict(sub_tinta == 0,
			"%s: nicio grilă nu coboară sub ținta de %d cifre date" % [nume, tinta]) and rezultat

	# Nivelurile trebuie să fie niveluri: mai greu = mai puține cifre date.
	# Ținta o spune în tabel; aici se măsoară că generatorul o atinge.
	var scade := true
	for i in range(1, medii.size()):
		if medii[i] >= medii[i - 1]:
			scade = false
	rezultat = _verdict(scade,
		"cifrele date scad de la un nivel la altul: %s" % [medii]) and rezultat

	print("  SUDOKU — SĂMÂNȚA")
	# Aceeași sămânță, același joc: promisiunea pe care Decretul Zilei o va
	# cere (vezi antetul lui `joc.gd`). Bătută pe generator, unde se naște.
	var a := RandomNumberGenerator.new()
	a.seed = 4711
	var b := RandomNumberGenerator.new()
	b.seed = 4711
	var c := RandomNumberGenerator.new()
	c.seed = 4712
	var g1: Array = SUDOKU.genereaza(1, a)
	var g2: Array = SUDOKU.genereaza(1, b)
	var g3: Array = SUDOKU.genereaza(1, c)
	rezultat = _verdict(g1 == g2, "aceeași sămânță dă aceeași grilă") and rezultat
	rezultat = _verdict(g1 != g3, "o altă sămânță dă altă grilă") and rezultat

	print("  SUDOKU — REGULA")
	# Un răspuns întreg e gata; același răspuns cu o celulă golită, nu; și cu o
	# cifră dublată pe linie, nici atât — deși e PLIN. Al treilea caz e cel
	# care contează: `e_gata` nu poate fi „sunt toate celulele pline?".
	var plina: Array = _rezolva_singur(g1.duplicate())
	var ca_int: Array[int] = []
	ca_int.assign(plina)
	rezultat = _verdict(SUDOKU.e_gata(ca_int), "o grilă plină validă e gata") and rezultat

	var cu_gaura: Array[int] = []
	cu_gaura.assign(plina)
	cu_gaura[40] = 0
	rezultat = _verdict(not SUDOKU.e_gata(cu_gaura),
		"una cu o singură celulă goală nu e gata") and rezultat

	var dublata: Array[int] = []
	dublata.assign(plina)
	# Prima celulă primește cifra vecinei de pe linie: grila rămâne PLINĂ și
	# devine greșită.
	dublata[0] = dublata[1]
	rezultat = _verdict(not SUDOKU.e_gata(dublata),
		"una plină, dar cu o cifră dublată pe linie, NU e gata") and rezultat
	rezultat = _verdict(SUDOKU.se_bate(dublata, 0) and SUDOKU.se_bate(dublata, 1),
		"și se bat AMÂNDOUĂ celulele, nu doar cea pusă ultima") and rezultat
	rezultat = _verdict(not SUDOKU.se_bate(cu_gaura, 40),
		"o celulă goală nu se bate cu nimic") and rezultat

	# AMBIGUITATEA, construită dinadins: patru celule în dreptunghi, cu cifrele
	# încrucișate, se pot umple în două feluri. Golite, grila are DOUĂ
	# răspunsuri — proba pe dos că numărătoarea nu răspunde mereu „unul".
	var patru := _dreptunghi_incrucisat(plina)
	if patru.is_empty():
		print("         (n-am găsit dreptunghi încrucișat în grila asta — sari)")
	else:
		var ambigua: Array[int] = []
		ambigua.assign(plina)
		for i in patru:
			ambigua[i] = 0
		rezultat = _verdict(_numara_singur(ambigua.duplicate(), 2) >= 2,
			"o grilă cu patru celule încrucișate golite are DOUĂ răspunsuri") and rezultat
		rezultat = _verdict(SUDOKU.numara_solutii(ambigua) >= 2,
			"și socoteala jocului spune la fel") and rezultat

	return await _sudoku_jucat() and rezultat


## PARTIDA JUCATĂ CU SCENA ADEVĂRATĂ.
##
## Tot ce e mai sus e regulă, bătută fără ecran. Asta e singura probă că cele
## două jumătăți se leagă: grila desenată, celula aleasă, tastele, numărătoarea
## greșelilor și contractul `Joc`.
func _sudoku_jucat() -> bool:
	print("  SUDOKU — PARTIDA JUCATĂ")
	var rezultat := true

	var joc := SCENA_SUDOKU.instantiate()
	add_child(joc)
	joc.porneste(42)

	rezultat = _verdict(joc.celule.size() == SUDOKU.CELULE,
		"grila are %d celule desenate" % SUDOKU.CELULE) and rezultat
	rezultat = _verdict(joc.taste.size() == SUDOKU.LATURA,
		"rândul de jos are cele %d cifre" % SUDOKU.LATURA) and rezultat
	rezultat = _verdict(joc.butoane_nivel.size() == SUDOKU.NIVELURI.size(),
		"cele %d niveluri sunt pe tăblie" % SUDOKU.NIVELURI.size()) and rezultat
	# Cu sămânță dată, nivelul vine din sămânță, nu din butonul apăsat ultima
	# dată: Decretul Zilei promite „același joc", iar nivelul e parte din joc.
	rezultat = _verdict(joc.nivel == 42 % SUDOKU.NIVELURI.size(),
		"cu sămânța 42, nivelul e %d" % (42 % SUDOKU.NIVELURI.size())) and rezultat
	rezultat = _verdict(joc.cate_date() == _cate_pline(joc.date),
		"`cate_date()` numără chiar cifrele din grilă (%d)" % joc.cate_date()) and rezultat

	# REGULILE MESEI, compuse din constante și ARĂTATE pe celule adevărate.
	# La Cuvântul Ascuns regula se vede în FONDUL celulei; aici în CERNEALĂ —
	# cifra dată, cea scrisă de tine și cea care se bate cu alta au același
	# pătrat și trei culori de cifră. Deci se caută culorile de text.
	var cuprins: Control = joc.reguli()
	rezultat = _verdict(cuprins != null, "Sudoku își scrie regulile") and rezultat
	if cuprins != null:
		var scris := _textul_din(cuprins)
		rezultat = _verdict(scris.contains(str(SUDOKU.LATURA))
			and scris.contains(str(SUDOKU.LATURA_CUTIE)),
			"regulile spun latura grilei (%d) și a pătratului (%d), din constante"
			% [SUDOKU.LATURA, SUDOKU.LATURA_CUTIE]) and rezultat
		var cerneli := _cernelurile_celulelor_din(cuprins)
		for pereche in [["dată", SUDOKU.CULOARE_CIFRA_DATA],
				["scrisă de tine", SUDOKU.CULOARE_CIFRA_SCRISA],
				["care se bate", SUDOKU.CULOARE_CIFRA_CONFLICT]]:
			rezultat = _verdict(cerneli.has((pereche[1] as Color).to_html(false)),
				"regulile ARATĂ cifra „%s\", n-o numesc" % pereche[0]) and rezultat
		cuprins.free()

	# O CIFRĂ DATĂ nu se schimbă, și ecranul spune de ce.
	var o_data := -1
	var una_goala := -1
	for i in SUDOKU.CELULE:
		if joc.date[i] != 0 and o_data < 0:
			o_data = i
		if joc.date[i] == 0 and una_goala < 0:
			una_goala = i
	var era: int = joc.grila[o_data]
	joc.alege(o_data)
	joc._scrie_cifra(era % SUDOKU.LATURA + 1)
	rezultat = _verdict(joc.grila[o_data] == era and joc.mesaj.text != "",
		"o cifră dată nu se schimbă, și ecranul spune de ce: %s" % joc.mesaj.text) and rezultat
	rezultat = _verdict(joc.greseli == 0,
		"și nu se socotește ca greșeală") and rezultat

	# O CIFRĂ CARE SE BATE: se numără, se vede chihlimbar, și se poate scoate.
	var gresita := _cifra_care_se_bate(joc.grila, una_goala)
	joc.alege(una_goala)
	joc._scrie_cifra(gresita)
	var eticheta: Label = joc.celule[una_goala].get_child(0)
	rezultat = _verdict(joc.greseli == 1,
		"o cifră care se bate cu alta se numără ca greșeală") and rezultat
	rezultat = _verdict(eticheta.get_theme_color("font_color") == SUDOKU.CULOARE_CIFRA_CONFLICT,
		"și se face chihlimbar pe ecran, nu roșie") and rezultat
	joc._scrie_cifra(0)
	rezultat = _verdict(joc.grila[una_goala] == 0,
		"0 golește celula") and rezultat
	rezultat = _verdict(joc.greseli == 1,
		"greșeala rămâne numărată după ce ai scos cifra") and rezultat

	# TASTATURA ADEVĂRATĂ și săgețile. Până aici am chemat funcțiile de-a
	# dreptul; asta e singura probă că o tastă apăsată ajunge la ele.
	joc.alege(una_goala)
	var tasta := InputEventKey.new()
	tasta.keycode = KEY_5
	tasta.pressed = true
	get_viewport().push_input(tasta)
	await get_tree().process_frame
	rezultat = _verdict(joc.grila[una_goala] == 5,
		"tasta 5 scrie 5 în celula aleasă") and rezultat

	var dreapta := InputEventKey.new()
	dreapta.keycode = KEY_RIGHT
	dreapta.pressed = true
	get_viewport().push_input(dreapta)
	await get_tree().process_frame
	rezultat = _verdict(joc.aleasa == una_goala + 1 or una_goala % SUDOKU.LATURA == SUDOKU.LATURA - 1,
		"săgeata mută alegerea cu o celulă") and rezultat
	# Și nu iese din grilă: pe marginea din dreapta, săgeata nu face nimic.
	joc.alege(SUDOKU.LATURA - 1)
	joc.muta(0, 1)
	rezultat = _verdict(joc.aleasa == SUDOKU.LATURA - 1,
		"pe marginea din dreapta, săgeata nu scoate alegerea din grilă") and rezultat

	# GRILA COMPLETATĂ. Răspunsul vine de la rezolvitorul VERIFICĂRII, deci
	# partida se joacă din afara jocului, cu cifre pe care el nu le-a dat.
	var raportat := []
	joc.terminat.connect(func(rez): raportat.append(rez))
	var raspuns := _rezolva_singur(joc.date.duplicate())
	for i in SUDOKU.CELULE:
		if joc.date[i] != 0:
			continue
		joc.alege(i)
		joc._scrie_cifra(int(raspuns[i]))
	rezultat = _verdict(raportat.size() == 1,
		"grila completată încheie partida, o singură dată") and rezultat
	if raportat.size() == 1:
		rezultat = _verdict(bool(raportat[0]["reusit"]),
			"și o încheie cu «reușit» — Sudoku nu se poate pierde") and rezultat
		rezultat = _verdict(String(raportat[0]["rezumat"]) != "",
			"cu o frază pentru jucător: %s" % raportat[0]["rezumat"]) and rezultat
		rezultat = _verdict(String(raportat[0]["rezumat"]).contains("greșeal")
			or String(raportat[0]["rezumat"]).contains("greșeli"),
			"care spune câte greșeli ai făcut") and rezultat
	# După final, tastele nu mai scriu: altfel o cifră apăsată peste rândul de
	# rezultat ar fi strigat semnalul a doua oară.
	var dupa: Array = joc.grila.duplicate()
	joc._scrie_cifra(1)
	rezultat = _verdict(joc.grila == dupa,
		"după final, grila nu se mai schimbă") and rezultat
	joc.queue_free()

	# NIVELUL DE PE TĂBLIE repornește partida ȘI o spune (semnalul `pornita`).
	# Fără semnal, rândul cu rezultatul partidei de dinainte ar fi rămas scris
	# lângă o grilă abia începută — vezi `Joc.pornita`.
	print("  SUDOKU — NIVELUL DE PE TĂBLIE")
	var masa := SCENA_SUDOKU.instantiate()
	add_child(masa)
	var porniri := []
	masa.pornita.connect(func(): porniri.append(true))
	masa.porneste(Joc.SAMANTA_LIBERA)
	rezultat = _verdict(porniri.size() == 1, "pornirea strigă `pornita`") and rezultat
	var inainte: int = masa.nivel
	var altul := (inainte + 1) % SUDOKU.NIVELURI.size()
	masa.schimba_nivelul(altul)
	rezultat = _verdict(masa.nivel == altul,
		"un alt nivel schimbă grila (%d → %d)" % [inainte, altul]) and rezultat
	rezultat = _verdict(porniri.size() == 2,
		"și o nouă partidă e anunțată") and rezultat
	rezultat = _verdict(masa.greseli == 0 and masa.aleasa == -1,
		"partida nouă pornește curată") and rezultat
	masa.queue_free()
	await get_tree().process_frame

	# ȘI ÎN TAVERNĂ: rândul cu rezultatul se închide când masa repornește.
	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	taverna.set_deferred("size", PANZA)
	await get_tree().process_frame
	taverna._deschide_masa(Mese.masa("sudoku"))
	await get_tree().process_frame
	taverna._pe_joc_terminat({"reusit": true, "rezumat": "Gata! Grila mediu."})
	await get_tree().process_frame
	var vazut_rezultatul: bool = taverna.rezultat.visible
	taverna.joc.schimba_nivelul(0)
	await get_tree().process_frame
	rezultat = _verdict(vazut_rezultatul and not taverna.rezultat.visible,
		"în Tavernă, un nivel nou închide rândul partidei de dinainte") and rezultat

	# Și fraza de pe rând e a MESEI, întreagă: niciun prefix pus de Tavernă.
	taverna._pe_joc_terminat({"reusit": true, "rezumat": "Gata! Grila mediu."})
	await get_tree().process_frame
	rezultat = _verdict(taverna.rezultat.text == "Gata! Grila mediu.",
		"rândul de rezultat poartă fraza mesei, neîmpodobită: %s"
		% taverna.rezultat.text) and rezultat

	taverna.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


# ─────────────────────────────────────────────────────────────
# 9. CLICURILE, PE PÂNZA ADEVĂRATĂ
#
# Tot restul verificării cheamă funcțiile de-a dreptul (`alege`, `_scrie_cifra`,
# `_scrie_litera`), deci nu spune nimic despre drumul pe care-l merge un deget:
# evenimentul intră în `Viewport`, care caută singur ce `Control` e sub el și-i
# trimite `gui_input`. Un filtru de mouse strâmb, un nod care acoperă masa, o
# celulă care nu primește evenimente — **niciuna din cele trei nu se vede
# chemând funcții**, și toate trei fac masa de nejucat cu mouse-ul.
#
# Secțiunea există fiindcă exact asta se întâmplase, de la prima masă încoace:
# `Suprapunere`, pânza care ține butonul „i", e întinsă de `PanelContainer`
# peste TOATĂ masa și sta pe `mouse_filter = PASS`. `PASS` nu înseamnă „lasă-l
# să treacă la ce e dedesubt", înseamnă „primește-l și trimite-l PĂRINTELUI" —
# deci nimic din masă nu era apăsabil: nici pătratele de Sudoku, nici tastatura
# de pe ecran a Cuvântului Ascuns. La prima masă nu s-a văzut fiindcă mouse-ul
# avea un înlocuitor (tastatura adevărată) și nimeni nu-l încercase.
#
# Aceeași judecată, scrisă la `push_input` din secțiunea Cuvântului Ascuns:
# „asta e singura probă că o tastă apăsată ajunge la ele".
# ─────────────────────────────────────────────────────────────

## ─────────────────────────────────────────────────────────────
## DECRETUL ZILEI
##
## Masa asta nu are un joc al ei, deci nu are nici o regulă de joc de bătut. Ce
## are sunt PROMISIUNI, și toate patru se strică în tăcere:
##
##   „altul în fiecare zi"      — o rotație stricată dă aceeași masă două zile
##                                la rând, și n-ai de unde s-o afli: fiecare zi
##                                arată, singură, perfect normal.
##   „același toată ziua"       — se strică abia la a doua deschidere.
##   „îl joci o dată pe zi"     — se strică la miezul nopții sau niciodată.
##   „nivelul e al zilei"       — se strică în ziua în care se aprinde a patra
##                                masă în catalog. Vezi mai jos.
##
## De-aia secțiunea joacă ZILE, nu partide: 1800 de zile de decrete, care costă
## mai puțin decât o grilă de Sudoku, fiindcă alegerea nu are nevoie de ecran.
##
## VERDICTUL CARE APĂRĂ O DECIZIE, nu o socoteală: `samanta % k` ia toate
## valorile pe zilele FIECĂREI mese. El e singurul care ar fi picat dacă sămânța
## ar fi fost ziua, și ar fi picat ACUM, nu peste o lună: pe zilele lui Sudoku
## (zilele pare, azi), `zi % 2` e constant. Vezi „O CORELAȚIE CARE AR FI OMORÂT
## UN NIVEL" din `decretul.gd`.
## ─────────────────────────────────────────────────────────────

func _decretul() -> bool:
	print("  DECRETUL ZILEI")
	var rezultat := true

	# a) ZIUA. Nu se poate cere un număr anume (ziua trece), dar se poate cere
	#    să fie ZIUA DE AZI: ceasul de sistem, împărțit la 24 de ore. Cele două
	#    socoteli pot cădea pe laturi diferite ale miezului nopții, fiindcă una
	#    e locală și cealaltă UTC — de-aia o zi de joc, nu egalitate.
	var azi := DECRETUL.zi_de_azi()
	var dupa_ceas := floori(Time.get_unix_time_from_system() / 86400.0)
	print("         azi e ziua %d (de la 1 ianuarie 1970); ceasul spune %d"
		% [azi, dupa_ceas])
	rezultat = _verdict(absi(azi - dupa_ceas) <= 1,
		"`zi_de_azi()` e chiar ziua de azi (%d, ceasul %d)" % [azi, dupa_ceas]) and rezultat
	rezultat = _verdict(DECRETUL.zi_de_azi() == azi,
		"și două întrebări una după alta dau aceeași zi") and rezultat

	# b) MESELE DE RÂND: cele scrise, fără decretul însuși. Dacă rândul care-l
	#    sare ar lipsi, decretul ar deschide un decret, care ar deschide un
	#    decret — iar asta nu e o cădere, e o fereastră care nu se mai termină.
	var de_rand := DECRETUL.mesele_de_rand()
	var chei_de_rand := {}
	for m in de_rand:
		chei_de_rand[String(m["cheie"])] = true
	print("         mese de rând: %s" % str(chei_de_rand.keys()))
	rezultat = _verdict(not chei_de_rand.has(DECRETUL.CHEIE),
		"decretul nu se alege pe sine") and rezultat
	rezultat = _verdict(de_rand.size() == Mese.cate_sunt_gata() - 1,
		"toate mesele scrise, în afară de el, intră în rotație (%d din %d)"
		% [de_rand.size(), Mese.cate_sunt_gata()]) and rezultat
	rezultat = _verdict(de_rand.size() >= 2,
		"sunt cel puțin două mese de rând, altfel „altul în fiecare zi\" e vorbă goală (%d)"
		% de_rand.size()) and rezultat

	# c) ROTAȚIA, pe 1800 de zile.
	var zile_ale_mesei := {}
	var lipite := 0
	var in_afara := 0
	var ieri := ""
	for pas in ZILE_DECRET:
		var zi: int = azi + pas
		var m: Dictionary = DECRETUL.masa_zilei(zi)
		var cheie := String(m.get("cheie", ""))
		if not chei_de_rand.has(cheie):
			in_afara += 1
			continue
		if cheie == ieri:
			lipite += 1
		ieri = cheie
		if not zile_ale_mesei.has(cheie):
			zile_ale_mesei[cheie] = []
		(zile_ale_mesei[cheie] as Array).append(zi)
	rezultat = _verdict(in_afara == 0,
		"în %d de zile, masa zilei e mereu una din rotație (%d scăpări)"
		% [ZILE_DECRET, in_afara]) and rezultat
	rezultat = _verdict(lipite == 0,
		"nicio masă nu vine două zile la rând (%d perechi lipite)" % lipite) and rezultat
	rezultat = _verdict(zile_ale_mesei.size() == de_rand.size(),
		"fiecare masă de rând își primește zilele (%d din %d)"
		% [zile_ale_mesei.size(), de_rand.size()]) and rezultat
	# AȘEZATĂ: aceeași zi, aceeași masă, oricând o întrebi. Fără asta,
	# „același toată ziua" ar fi ținut până la a doua deschidere.
	var mutate := 0
	for cheie in zile_ale_mesei:
		for zi in zile_ale_mesei[cheie]:
			# A doua trecere, pe zilele strânse la prima: dacă alegerea ar
			# atârna de altceva decât de zi (un `randi`, o stare rămasă de la
			# apelul dinainte), aici ar ieși altă masă decât atunci.
			if String(DECRETUL.masa_zilei(int(zi))["cheie"]) != String(cheie):
				mutate += 1
	# Și o zi dinaintea epocii: `-1 % 2` dă -1 în GDScript, adică un index în
	# afara listei. Din joc nu se poate ajunge acolo; de aici, da.
	rezultat = _verdict(mutate == 0 and not DECRETUL.masa_zilei(-7).is_empty(),
		"alegerea e așezată, și o zi negativă tot dă o masă") and rezultat

	# d) SĂMÂNȚA: niciodată „alege tu", așezată, și NECORELATĂ cu rotația.
	var zero := 0
	var nemisca := 0
	for pas in ZILE_DECRET:
		var zi: int = azi + pas
		var s: int = DECRETUL.samanta_pentru(zi)
		if s == Joc.SAMANTA_LIBERA:
			zero += 1
		if s != DECRETUL.samanta_pentru(zi):
			nemisca += 1
	rezultat = _verdict(zero == 0,
		"sămânța nu e niciodată 0, adică „alege tu\" (%d scăpări)" % zero) and rezultat
	rezultat = _verdict(nemisca == 0,
		"aceeași zi dă aceeași sămânță (%d scăpări)" % nemisca) and rezultat

	for cheie in zile_ale_mesei:
		for k in RESTURI_DECRET:
			var vazute := {}
			for zi in zile_ale_mesei[cheie]:
				vazute[DECRETUL.samanta_pentru(int(zi)) % int(k)] = true
			rezultat = _verdict(vazute.size() == int(k),
				"%s: pe zilele ei, `samanta %% %d` ia toate %d valorile (%d)"
				% [cheie, k, k, vazute.size()]) and rezultat

	# e) PARTIDE JUCATE CU SCENELE ADEVĂRATE — una pe FIECARE masă de rând.
	#
	# Nu pe „ziua de mâine", cum a fost la prima scriere: mâine e o zi anume,
	# deci verdictele ar fi bătut Cuvântul Ascuns azi și Sudoku mâine, iar
	# secțiunea ar fi verificat altceva în fiecare zi în care o rulez. Cel mai
	# rău, verdictul care contează cel mai mult — uneltele îngropate — ar fi
	# rulat doar în zilele de Sudoku, fiindcă numai el are unelte. O verificare
	# care depinde de ceas nu e o verificare, e un sondaj.
	#
	# Deci ziua se CAUTĂ: prima zi din rotație care dă masa asta.
	var decret = SCENA_DECRETUL.instantiate()
	add_child(decret)
	var raportat: Array[Dictionary] = []
	decret.terminat.connect(func(r): raportat.append(r))

	# Pentru măsurătoarea panoului cu reguli de mai jos e nevoie de panoul
	# ADEVĂRAT, cu lățimea și marginile lui, nu de o cutie ridicată aici.
	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	taverna.set_deferred("size", PANZA)
	await get_tree().process_frame
	var cuprins_taverna: Control = taverna.get_node("%Cuprins")
	var panou_reguli: Control = taverna.get_node("PanouReguli/Centru/Panou")

	for m in de_rand:
		var cheie := String(m["cheie"])
		var nume_masa := String(m["nume"])
		var zi_proba := azi + 1
		while String(DECRETUL.masa_zilei(zi_proba)["cheie"]) != cheie:
			zi_proba += 1
		print("         %s e decretul zilei %d" % [cheie, zi_proba])

		DECRETUL._zi_jucata = 0
		DECRETUL._reusit = false
		raportat.clear()
		decret.porneste(zi_proba)
		await get_tree().process_frame
		rezultat = _verdict(decret.masa != null,
			"%s: un decret nejucat deschide masa zilei" % cheie) and rezultat
		rezultat = _verdict(decret.zi == zi_proba,
			"%s: sămânța dată E ziua jucată (%d)" % [cheie, decret.zi]) and rezultat
		if decret.masa == null:
			continue
		rezultat = _verdict(String(decret.masa_de_azi["cheie"]) == cheie,
			"%s: masa de pe ecran e cea pe care o spune rotația" % cheie) and rezultat
		# Fraza de ajutor spune CARE joc e azi — singurul loc în care se spune,
		# fiindcă titlul din antet e „DECRETUL ZILEI".
		rezultat = _verdict(decret.rand_de_ajutor().contains(nume_masa),
			"%s: fraza de ajutor numește masa zilei" % cheie) and rezultat
		# UNELTELE MESEI GĂZDUITE nu ajung nici în antet, nici pe tăblie — dar
		# trăiesc, fiindcă masa le atinge la fiecare pornire (vezi
		# `_ia_uneltele`). Trei feluri de a greși, toate trei bătute: să ajungă
		# la Tavernă, să rămână pe tăblia mesei, să fie îngropate de tot.
		rezultat = _verdict(decret.unelte() == null,
			"%s: decretul nu dă unelte Tavernei — partida lui nu se reglează"
			% cheie) and rezultat
		var scule_masei: Control = decret.masa.unelte()
		if scule_masei == null:
			print("         (%s n-are unelte, deci nu e nimic de îngropat)" % cheie)
		else:
			rezultat = _verdict(is_instance_valid(scule_masei)
				and scule_masei.get_parent() == decret and not scule_masei.visible,
				"%s: uneltele ei sunt ținute în viață, la decret, și stinse"
				% cheie) and rezultat
			rezultat = _verdict(_textul_din(decret.masa).find(
				_textul_din(scule_masei).strip_edges()) == -1,
				"%s: și nu se văd nicăieri pe tăblie" % cheie) and rezultat

		# PANOUL CU REGULI, MĂSURAT în panoul ADEVĂRAT al Tavernei.
		for copil in cuprins_taverna.get_children():
			cuprins_taverna.remove_child(copil)
			copil.queue_free()
		var cuprins_decret: Control = decret.reguli()
		rezultat = _verdict(cuprins_decret != null,
			"%s: decretul își scrie regulile" % cheie) and rezultat
		if cuprins_decret != null:
			cuprins_taverna.add_child(cuprins_decret)
			# AICI SE MĂSOARĂ `size`, NU `get_combined_minimum_size()` — singurul
			# loc din suită în care regula „un ecran se măsoară pe cât CERE" NU
			# se aplică, și merită spus de ce. Panoul e numai text cu autowrap,
			# iar minimul unei etichete care încadrează singură se socotește la
			# lățime ZERO: fiecare cuvânt pe rândul lui. Prima scriere a cerut
			# minimul și a primit 13.373 px — un număr care nu descrie niciun
			# ecran care a existat vreodată. Ce contează aici e înălțimea pe care
			# o ia textul la LĂȚIMEA LUI ADEVĂRATĂ (620 px), deci panoul se
			# deschide și se citește cât a ieșit.
			taverna.panou_reguli.visible = true
			await get_tree().process_frame
			await get_tree().process_frame
			var inalt := panou_reguli.size.y
			print("         panoul cu reguli al decretului, cu %s: %d × %d px"
				% [cheie, panou_reguli.size.x, inalt])
			# `PanouReguli` nu se derulează — e un `CenterContainer`, deci ce nu
			# încape nu împinge nimic și nu se plânge nimeni: iese pe sus și pe
			# jos, tăiat. Iar panoul decretului e cel mai înalt din joc prin
			# construcție: paragraful lui PLUS panoul întreg al mesei de azi.
			rezultat = _verdict(inalt <= PANZA.y,
				"%s: panoul cu reguli încape în înălțime (%d px, rezervă %d)"
				% [cheie, inalt, PANZA.y - inalt]) and rezultat
			taverna.panou_reguli.visible = false
			rezultat = _verdict(_textul_din(cuprins_decret).contains(nume_masa),
				"%s: și spune ale cui sunt regulile de dedesubt" % cheie) and rezultat

		# Jocul se termină (prin masă, ca în joc), iar decretul duce rezumatul
		# întreg mai departe și ÎNCHIDE ziua.
		decret.masa.termina(true, "Gata, din 3 încercări.")
		await get_tree().process_frame
		rezultat = _verdict(raportat.size() == 1
			and String(raportat[0]["rezumat"]) == "Gata, din 3 încercări.",
			"%s: rezumatul mesei trece neatins prin decret" % cheie) and rezultat
		rezultat = _verdict(DECRETUL._zi_jucata == zi_proba and DECRETUL._reusit,
			"%s: ziua s-a închis, cu tot cu felul în care a ieșit" % cheie) and rezultat

		# f) A DOUA AȘEZARE ÎN ACEEAȘI ZI: pagina, nu jocul. Și NICIUN
		#    `terminat`, altfel Taverna ar fi pus „Încă unul" sub o pagină care
		#    spune chiar că nu mai e nimic de jucat.
		raportat.clear()
		decret.porneste(zi_proba)
		await get_tree().process_frame
		rezultat = _verdict(decret.masa == null,
			"%s: decretul jucat azi nu mai deschide jocul" % cheie) and rezultat
		var scris := _textul_din(decret)
		rezultat = _verdict(scris.contains("ÎNCHEIAT"),
			"%s: pagina spune că s-a încheiat" % cheie) and rezultat
		rezultat = _verdict(scris.contains(nume_masa),
			"%s: pagina spune CE masă a fost, fiindcă mâine n-ai de unde ști"
			% cheie) and rezultat
		rezultat = _verdict(scris.contains("L-ai scos."),
			"%s: pagina spune cum a ieșit" % cheie) and rezultat
		rezultat = _verdict(raportat.is_empty(),
			"%s: și nu strigă `terminat` — n-ar fi avut ce să însemne «Încă unul»"
			% cheie) and rezultat
		# MĂSURATĂ pe cât CERE, ca toate ecranele. Pagina e altă stare a mesei
		# decât jocul, deci se măsoară ca ea însăși.
		await get_tree().process_frame
		var cerut_pagina: Vector2 = decret.get_combined_minimum_size()
		print("         pagina de după %s cere %d × %d px"
			% [cheie, cerut_pagina.x, cerut_pagina.y])
		rezultat = _verdict(cerut_pagina.y <= PANZA.y and cerut_pagina.x <= PANZA.x,
			"%s: pagina de după încape pe pânză (%d × %d)"
			% [cheie, cerut_pagina.x, cerut_pagina.y]) and rezultat

		# g) MÂINE E ALTĂ ZI. Verdictul fără care „o dată pe zi" ar fi fost
		#    „o dată".
		decret.porneste(zi_proba + 1)
		await get_tree().process_frame
		rezultat = _verdict(decret.masa != null,
			"%s: ziua următoare deschide iar un joc" % cheie) and rezultat
		rezultat = _verdict(decret.masa != null
			and String(decret.masa_de_azi["cheie"]) != cheie,
			"%s: și e alt joc decât ieri (%s)"
			% [cheie, decret.masa_de_azi.get("cheie", "—")]) and rezultat
	decret.queue_free()
	taverna.queue_free()
	await get_tree().process_frame

	# h) DISCUL. Citit strâmb, ca peste tot.
	var zi_disc: int = azi + 500
	DECRETUL._zi_jucata = zi_disc
	DECRETUL._reusit = true
	var pe_disc := DECRETUL.spre_dictionar()
	rezultat = _verdict(int(pe_disc["zi_jucata"]) == zi_disc and bool(pe_disc["reusit"]),
		"ziua închisă trece în dicționar") and rezultat
	DECRETUL.din_dictionar({})
	rezultat = _verdict(DECRETUL._zi_jucata == 0 and not DECRETUL._reusit,
		"un save fără cheile decretului = n-ai jucat niciunul") and rezultat
	DECRETUL.din_dictionar({"zi_jucata": "alaltaieri", "reusit": "poate"})
	rezultat = _verdict(DECRETUL._zi_jucata == 0,
		"o zi care nu e un număr se citește ca «niciuna»") and rezultat
	DECRETUL.din_dictionar(pe_disc)
	rezultat = _verdict(DECRETUL._zi_jucata == zi_disc and DECRETUL._reusit,
		"și drumul înapoi aduce tot") and rezultat
	# Pus la loc: secțiunile de după pornesc mese, iar un decret „jucat" le-ar
	# fi dat pagina în loc de joc.
	DECRETUL._zi_jucata = 0
	DECRETUL._reusit = false
	return rezultat


func _clicurile() -> bool:
	print("  CLICURILE")
	var rezultat := true

	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	taverna.set_deferred("size", PANZA)
	await get_tree().process_frame
	await get_tree().process_frame

	# a) SUDOKU: un clic pe un pătrat îl alege, iar cifra tastată intră în el.
	taverna._deschide_masa(Mese.masa("sudoku"))
	taverna._inchide_regulile()
	await get_tree().process_frame
	await get_tree().process_frame
	var masa = taverna.joc
	var goala := -1
	for i in SUDOKU.CELULE:
		if masa.date[i] == 0:
			goala = i
			break
	masa.aleasa = -1
	await _clic_pe(masa.celule[goala])
	rezultat = _verdict(masa.aleasa == goala,
		"un CLIC pe un pătrat de Sudoku îl alege (celula %d, aleasă %d)"
		% [goala, masa.aleasa]) and rezultat

	# O celulă aleasă în care nu poți scrie nu e aleasă, e doar luminată.
	var cifra := InputEventKey.new()
	cifra.keycode = KEY_7
	cifra.pressed = true
	get_viewport().push_input(cifra)
	await get_tree().process_frame
	rezultat = _verdict(masa.grila[goala] == 7,
		"și cifra tastată după clic intră în pătratul ales (e %d)"
		% masa.grila[goala]) and rezultat

	# Și tasta de pe ecran, nu doar cea de sub degete.
	await _clic_pe(masa.taste[3])
	rezultat = _verdict(masa.grila[goala] == 3,
		"un clic pe cifra 3 din rândul de jos o scrie (e %d)"
		% masa.grila[goala]) and rezultat

	# b) BUTONUL „i" tot primește clicuri: suprapunerea nu mai oprește nimic,
	#    dar căutarea trebuie să coboare în continuare la copiii ei.
	rezultat = _verdict(not taverna.panou_reguli.visible,
		"panoul cu reguli e închis înainte de clic") and rezultat
	await _clic_pe(taverna.buton_reguli)
	rezultat = _verdict(taverna.panou_reguli.visible,
		"un clic pe „i\" deschide regulile") and rezultat
	taverna._inchide_regulile()
	await get_tree().process_frame

	# c) CUVÂNTUL ASCUNS: tastatura de pe ecran. Jumătatea veche a greșelii —
	#    masa aia se putea juca de la tastatură, deci clicurile ei moarte au
	#    stat nevăzute o zi întreagă.
	taverna._arata_mesele()
	await get_tree().process_frame
	taverna._deschide_masa(Mese.masa("cuvantul_ascuns"))
	taverna._inchide_regulile()
	await get_tree().process_frame
	await get_tree().process_frame
	var cuvantul = taverna.joc
	var inainte: String = cuvantul.rand_curent
	await _clic_pe(cuvantul.taste["a"])
	rezultat = _verdict(cuvantul.rand_curent == inainte + "a",
		"un clic pe litera A din tastatura de pe ecran o scrie (rândul: „%s\")"
		% cuvantul.rand_curent) and rezultat

	taverna.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


## Un clic adevărat, în mijlocul unui `Control`: apăsat și ridicat, prin
## `Viewport`, care caută singur ce e sub el.
##
## `push_input(clic, true)` — al doilea parametru e `in_local_coords`, și FĂRĂ
## el toate verdictele secțiunii pică, inclusiv cele care n-au nimic stricat în
## spate. Pe `false` (implicitul), Godot mai trece poziția prin transformarea
## finală a ferestrei, deci clicul ajunge în altă parte; coordonatele luate din
## `get_global_rect()` sunt deja ÎN viewport, așa că se dau ca atare.
##
## Scris aici fiindcă prima scriere a secțiunii a greșit-o, iar greșeala ARATĂ
## exact ca bug-ul pe care secțiunea îl caută: nimic nu răspunde la clic. Cele
## două s-au despărțit punând filtrul stricat înapoi pentru o rulare — cu
## coordonatele bune, butonul „i" răspundea și restul mesei nu, adică chiar
## tiparul „o pânză deasupra oprește tot, în afară de copiii ei".
func _clic_pe(nod: Control) -> void:
	var mijloc := nod.get_global_rect().get_center()
	for apasata in [true, false]:
		var clic := InputEventMouseButton.new()
		clic.button_index = MOUSE_BUTTON_LEFT
		clic.pressed = apasata
		clic.position = mijloc
		clic.global_position = mijloc
		get_viewport().push_input(clic, true)
	await get_tree().process_frame


# ─────────────────────────────────────────────────────────────
# REZOLVITORUL VERIFICĂRII — A DOUA SOCOTEALĂ
#
# Scris din liste de candidați și dicționare, nu din biți: aceeași idee (ia de
# fiecare dată celula cu cele mai puține variante), altă socoteală. Dacă cele
# două ar fi fost una, „grila are un singur răspuns" n-ar fi fost o verificare,
# ar fi fost o oglindă.
#
# Ăsta e și singurul loc din verificare care REZOLVĂ o grilă — iar răspunsul
# găsit aici e cel cu care se joacă partida de mai sus, cap-coadă.
# ─────────────────────────────────────────────────────────────

func _linia(i: int) -> int:
	@warning_ignore("integer_division")
	return i / SUDOKU.LATURA


## Cifrele care mai pot intra în celula `i`.
func _candidati(g: Array, i: int) -> Array[int]:
	var luate := {}
	var r := _linia(i)
	var c := i % SUDOKU.LATURA
	for k in SUDOKU.LATURA:
		luate[int(g[r * SUDOKU.LATURA + k])] = true
		luate[int(g[k * SUDOKU.LATURA + c])] = true
	var r0 := r - r % SUDOKU.LATURA_CUTIE
	var c0 := c - c % SUDOKU.LATURA_CUTIE
	for dr in SUDOKU.LATURA_CUTIE:
		for dc in SUDOKU.LATURA_CUTIE:
			luate[int(g[(r0 + dr) * SUDOKU.LATURA + c0 + dc])] = true
	var pot: Array[int] = []
	for v in range(1, SUDOKU.LATURA + 1):
		if not luate.has(v):
			pot.append(v)
	return pot


## Celula cea mai strâmtă: `[index, candidați]`, sau `[-1, []]` dacă grila e
## plină.
func _cea_mai_stramta(g: Array) -> Array:
	var cel := -1
	var lista: Array[int] = []
	for i in SUDOKU.CELULE:
		if int(g[i]) != 0:
			continue
		var pot := _candidati(g, i)
		if cel == -1 or pot.size() < lista.size():
			cel = i
			lista = pot
			if pot.size() <= 1:
				break
	return [cel, lista]


## Câte răspunsuri are grila, numărate până la `plafon`.
func _numara_singur(g: Array, plafon: int) -> int:
	var ales := _cea_mai_stramta(g)
	var cel: int = ales[0]
	if cel == -1:
		return 1
	var total := 0
	for v in ales[1]:
		g[cel] = v
		total += _numara_singur(g, plafon - total)
		g[cel] = 0
		if total >= plafon:
			return total
	return total


## Un răspuns al grilei, sau o listă goală.
func _rezolva_singur(g: Array) -> Array:
	var ales := _cea_mai_stramta(g)
	var cel: int = ales[0]
	if cel == -1:
		return g
	for v in ales[1]:
		g[cel] = v
		var gata := _rezolva_singur(g)
		if not gata.is_empty():
			return gata
		g[cel] = 0
	return []


## E grila plină o grilă validă? Scris ca o AFIRMAȚIE DESPRE SUDOKU („fiecare
## linie, coloană și pătrat au toate cele nouă cifre"), nu ca negarea
## conflictelor — altfel ar fi fost `e_gata()` al jocului, scris de două ori.
func _e_valida_plina(g: Array) -> bool:
	for k in SUDOKU.LATURA:
		var pe_linie := {}
		var pe_coloana := {}
		for j in SUDOKU.LATURA:
			pe_linie[int(g[k * SUDOKU.LATURA + j])] = true
			pe_coloana[int(g[j * SUDOKU.LATURA + k])] = true
		if pe_linie.size() != SUDOKU.LATURA or pe_coloana.size() != SUDOKU.LATURA:
			return false
		if pe_linie.has(0) or pe_coloana.has(0):
			return false
	for cutie in SUDOKU.LATURA:
		@warning_ignore("integer_division")
		var r0 := (cutie / SUDOKU.LATURA_CUTIE) * SUDOKU.LATURA_CUTIE
		var c0 := (cutie % SUDOKU.LATURA_CUTIE) * SUDOKU.LATURA_CUTIE
		var in_cutie := {}
		for dr in SUDOKU.LATURA_CUTIE:
			for dc in SUDOKU.LATURA_CUTIE:
				in_cutie[int(g[(r0 + dr) * SUDOKU.LATURA + c0 + dc])] = true
		if in_cutie.size() != SUDOKU.LATURA or in_cutie.has(0):
			return false
	return true


## Nu se bate nicio cifră cu alta? (Grila poate avea goluri.)
func _fara_conflicte(g: Array) -> bool:
	for i in SUDOKU.CELULE:
		if int(g[i]) == 0:
			continue
		# Se scoate cifra și se întreabă dacă mai poate intra: dacă nu mai
		# poate, altcineva de pe linia, coloana sau din pătratul ei o are deja.
		var lucru := g.duplicate()
		var v_ei := int(g[i])
		lucru[i] = 0
		if not _candidati(lucru, i).has(v_ei):
			return false
	return true


func _cate_pline(g: Array) -> int:
	var cate := 0
	for v in g:
		if int(v) != 0:
			cate += 1
	return cate


## Patru celule în dreptunghi, cu cifrele încrucișate: două linii din ACEEAȘI
## bandă, două coloane din stive diferite, și cifrele în cruce. Golite, se pot
## umple în două feluri, deci grila are două răspunsuri.
##
## „Aceeași bandă" nu e un amănunt, e tot ce face tiparul să țină, și prima
## scriere a greșit-o: cu liniile din benzi DIFERITE, cele patru celule cad în
## patru pătrate, iar schimbarea cifrelor între ele strică pătratele — grila
## rămâne cu un singur răspuns, și verificarea a spus-o. Așa, cele patru celule
## cad în DOUĂ pătrate, fiecare cu amândouă cifrele, deci schimbarea nu încalcă
## nimic: nici linie, nici coloană, nici pătrat.
func _dreptunghi_incrucisat(g: Array) -> Array[int]:
	var lat: int = SUDOKU.LATURA
	var cut: int = SUDOKU.LATURA_CUTIE
	for r1 in lat:
		for r2 in range(r1 + 1, lat):
			if r1 - r1 % cut != r2 - r2 % cut:
				continue
			for c1 in lat:
				for c2 in range(c1 + 1, lat):
					if c1 - c1 % cut == c2 - c2 % cut:
						continue
					if int(g[r1 * lat + c1]) == int(g[r2 * lat + c2]) \
						and int(g[r1 * lat + c2]) == int(g[r2 * lat + c1]):
						var patru: Array[int] = [
							r1 * lat + c1, r1 * lat + c2,
							r2 * lat + c1, r2 * lat + c2,
						]
						return patru
	var gol: Array[int] = []
	return gol


## O cifră care se bate sigur cu ceva, pentru celula goală `i`. Dacă n-ar
## exista niciuna (celulă cu toate cele nouă variante libere), se întoarce 0 și
## verdictul de deasupra o spune.
func _cifra_care_se_bate(g: Array, i: int) -> int:
	var pot := _candidati(g, i)
	for v in range(1, SUDOKU.LATURA + 1):
		if not pot.has(v):
			return v
	return 0


# ─────────────────────────────────────────────────────────────
# 8. CARACTERELE MESELOR
#
# Regula din sesiunea BULELE DESENATE (4 noiembrie 2026): un semn pe care
# fonturile jocului nu-l au se desenează, pe Windows, cu un semn împrumutat de
# la sistem — tăcut — iar în browser ca un pătrat gol. Adică greșeala e
# INVIZIBILĂ pe platforma pe care dezvolt și se vede doar pe ecranul
# jucătorului.
#
# Acolo scria, la „a rămas deschis": harta, meniul, TAVERNA și sumarul n-au
# fost întrebate niciodată. Taverna se întreabă de azi, pe toate mesele.
# ─────────────────────────────────────────────────────────────

func _caracterele() -> bool:
	print("  CARACTERELE MESELOR")
	var rezultat := true

	var fonturi := {}
	for cale in [CALE_CINZEL, CALE_ALEGREYA]:
		if not ResourceLoader.exists(cale):
			rezultat = _verdict(false, "fontul %s există" % cale.get_file()) and rezultat
			continue
		fonturi[cale.get_file()] = load(cale)
	fonturi["implicit"] = ThemeDB.fallback_font

	# Tot ce scrie pe ecranul fiecărei mese: celulele, tastele, rândul de
	# ajutor și panoul cu reguli. Strâns din NODURI, nu dintr-o listă de
	# texte scrisă de mână — una scrisă de mână ar fi rămas în urmă.
	var caractere := {}
	for m in Mese.CATALOG:
		var cale := String(m["scena"])
		if cale == "":
			continue
		var masa = (load(cale) as PackedScene).instantiate()
		add_child(masa)
		masa.porneste(99)
		await get_tree().process_frame
		for ch in _textul_din(masa):
			caractere[ch] = true
		for ch in masa.rand_de_ajutor():
			caractere[ch] = true
		var cuprins: Control = masa.reguli()
		if cuprins != null:
			for ch in _textul_din(cuprins):
				caractere[ch] = true
			cuprins.free()
		# Uneltele nu sunt în arborele mesei (Taverna le ia), deci `_textul_din`
		# de mai sus nu le vede — iar „Ușor" are chiar semnele pe care un font
		# le-ar putea rata. Se strâng separat, cât timp masa le mai ține.
		var scule: Control = masa.unelte()
		if scule != null and scule.get_parent() == null:
			for ch in _textul_din(scule):
				caractere[ch] = true
		for ch in String(m["nume"]) + String(m["rol"]):
			caractere[ch] = true
		masa.queue_free()
		await get_tree().process_frame

	# PAGINA DECRETULUI nu intră în bucla de deasupra: ea pornește fiecare masă
	# proaspătă, iar pagina se vede doar la un decret deja jucat. Textul ei e al
	# decretului, deci nimeni altcineva nu-l strânge — exact felul în care „✕"-ul
	# Tavernei a stat o zi nedesenat: verdictul exista, dar nu se uita acolo.
	var zi_proba := DECRETUL.zi_de_azi()
	DECRETUL._zi_jucata = zi_proba
	DECRETUL._reusit = false   # „Nu l-ai scos.", celălalt rând al paginii
	var decret = SCENA_DECRETUL.instantiate()
	add_child(decret)
	decret.porneste(zi_proba)
	await get_tree().process_frame
	for ch in _textul_din(decret):
		caractere[ch] = true
	for ch in decret.rand_de_ajutor():
		caractere[ch] = true
	var ale_decretului: Control = decret.reguli()
	if ale_decretului != null:
		for ch in _textul_din(ale_decretului):
			caractere[ch] = true
		ale_decretului.free()
	DECRETUL._reusit = true    # și „L-ai scos."
	decret.porneste(zi_proba)
	await get_tree().process_frame
	for ch in _textul_din(decret):
		caractere[ch] = true
	DECRETUL._zi_jucata = 0
	DECRETUL._reusit = false
	decret.queue_free()
	await get_tree().process_frame

	for nume in fonturi:
		var font: Font = fonturi[nume]
		var lipsa: Array[String] = []
		for ch in caractere:
			var cod: int = String(ch).unicode_at(0)
			# Sub 32 sunt spațiul și linia nouă: fonturile nu le declară, iar
			# desenarea lor nu trece prin glife.
			if cod < 32:
				continue
			if not font.has_char(cod):
				lipsa.append("„%s” (U+%04X)" % [ch, cod])
		rezultat = _verdict(lipsa.is_empty(),
			"%s are toate caracterele meselor%s" % [nume, _exemple(lipsa)]) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# DOSARUL DE PROBĂ
# ─────────────────────────────────────────────────────────────

func _goleste_dosarul() -> void:
	if not DirAccess.dir_exists_absolute(DOSAR):
		DirAccess.make_dir_recursive_absolute(DOSAR)
		return
	for nume in DirAccess.get_files_at(DOSAR):
		DirAccess.remove_absolute(Arhiva.cale_catre(String(nume)))

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
##   4b. SUDOKU și FIOLELE — mesele generate: se REZOLVĂ din nou, cu o a doua
##      socoteală, fiindcă nu se pot citi înainte de joc.
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
const FIOLE := preload("res://scenes/taverna/fiolele/fiolele.gd")
const SCENA_FIOLE := preload("res://scenes/taverna/fiolele/fiolele.tscn")
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

## Câte amestecuri se fac pe fiecare nivel la Fiolele. Mai multe decât la
## Sudoku, fiindcă un amestec costă puțin — iar ce apără numărul e garanția că
## TOATE se rezolvă: un generator care scapă un amestec înfundat o dată la
## douăzeci s-ar vedea abia aici.
const SEMINTE_FIOLE := 10
## Câte stări are voie să desfacă rezolvitorul VERIFICĂRII pe un amestec. Mai
## mult decât al jocului, dinadins: verificarea n-are voie să spună „nu se poate"
## doar fiindcă a obosit mai repede decât jocul.
const BUGET_FIOLE := 150000
## Cât de departe trebuie să fie oricare două culori din paleta unui nivel, în
## Oklab. 0,02 e pragul la care ochiul abia deosebește două culori puse una
## lângă alta; 0,12 e de șase ori pe atât, fiindcă aici stau în fiole DIFERITE.
const PRAG_PALETA := 0.12
## Și cât de luminoasă trebuie să fie fiecare, pe fondul închis al mesei
## (L ≈ 0,2): o culoare sub 0,5 s-ar citi ca o fiolă goală.
const PRAG_LUMINA := 0.5

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
	tot_bun = await _portretul() and tot_bun
	tot_bun = await _regulile() and tot_bun
	tot_bun = await _sudoku() and tot_bun
	tot_bun = await _fiolele() and tot_bun
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
		"cele patru pagini din meniu încap în lățime (%d px, rezervă %d)"
		% [cerut_meniu.x, PANZA.x - cerut_meniu.x]) and rezultat
	rezultat = _verdict(cerut_meniu.y <= PANZA.y,
		"meniul încape în înălțime (%d px, rezervă %d)"
		% [cerut_meniu.y, PANZA.y - cerut_meniu.y]) and rezultat
	rezultat = _verdict(carti.get_child_count() == 4, "meniul are patru pagini (a patra e Pescuitul, 16 noiembrie 2026)") and rezultat

	# AVERTISMENTUL apare doar când un fișier de save e stricat, deci se măsoară
	# și starea aia, cu amândouă frazele — un ecran se măsoară în fiecare stare.
	var avertisment: Label = meniu.get_node("%Avertisment")
	avertisment.text = "\n".join(meniu._randuri_de_avertisment_pentru(true, true))
	avertisment.visible = true
	# COLȚUL SALVĂRII, cu cea mai lungă frază pe care o poate purta.
	var nota: Label = meniu.get_node("%NotaSalvare")
	nota.text = meniu.FRAZA_EXPORT_WEB % "mindkeep-salvare-2026-11-10T14-33-02.json"
	await get_tree().process_frame
	await get_tree().process_frame
	var cu_avertisment := margini_meniu.get_combined_minimum_size()
	rezultat = _verdict(cu_avertisment.y <= PANZA.y,
		"meniul încape și cu avertismentul (%d px, rezervă %d)"
		% [cu_avertisment.y, PANZA.y - cu_avertisment.y]) and rezultat
	# Titlul e o etichetă cât toată coloana, deci se măsoară TEXTUL lui, nu
	# eticheta — exact greșeala de la antetul Tavernei.
	var titlu_meniu: Label = meniu.get_node("Margini/Coloana/Antet/Titlu")
	var latime_titlu := titlu_meniu.get_theme_font("font").get_string_size(titlu_meniu.text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, titlu_meniu.get_theme_font_size("font_size")).x
	var dreapta_titlu := titlu_meniu.global_position.x + (titlu_meniu.size.x + latime_titlu) / 2.0
	var salvarea := (meniu.get_node("Salvarea") as Control).get_global_rect()
	rezultat = _verdict(salvarea.position.x >= dreapta_titlu,
		"colțul salvării nu ajunge peste titlu (%d px între ele, înalt %d)"
		% [salvarea.position.x - dreapta_titlu, salvarea.size.y]) and rezultat
	rezultat = _verdict(salvarea.end.x <= PANZA.x and salvarea.end.y < carti.global_position.y,
		"colțul salvării stă deasupra paginilor") and rezultat
	meniu.queue_free()
	# `queue_free` scoate nodul la finalul cadrului. Fără cele două cadre de
	# mai jos, `quit()` vine înainte, iar Godot se plânge la ieșire de obiecte
	# rămase în viață — un avertisment care nu înseamnă nimic aici, dar care
	# într-o zi ar ascunde unul care înseamnă.
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


# ─────────────────────────────────────────────────────────────
# 5b. PE TELEFONUL ȚINUT VERTICAL
#
# De pe 25 noiembrie 2026 (vezi „PÂNZA ÎN PORTRET" din `fereastra.gd`). Aceleași
# întrebări ca la ECRANELE, puse pe pânza îngustă: încape totul, în fiecare
# stare? Plus două care nu existau acolo, fiindcă pânza mare nu se schimbă
# niciodată: CINE o primește și cine o retrage (sala cu mese și mesele care o
# declară da; Fiolele și meniul nu), și ce se întâmplă când telefonul se întoarce
# LA JUMĂTATEA unei partide.
#
# Fără fereastră nu există un telefon de întors, deci verificarea MINTE doar
# despre forma ferestrei (`Fereastra.simuleaza_verticala`); restul drumului —
# cine cheamă `primeste_portret`, cine ascultă semnalul — e chiar al jocului.
# ─────────────────────────────────────────────────────────────

## Mesele care TREBUIE să se joace și cu telefonul ținut vertical. Scris aici, nu
## citit din `incape_in_portret()`: o masă care și-ar pierde declarația ar
## trece altfel neobservată, iar asta a fost tot rostul schimbării.
const MESE_IN_PORTRET := ["cuvantul_ascuns", "sudoku"]
## Cât de înaltă trebuie să fie, măcar, o tastă pe pânza îngustă. Un deget are
## ~44 px de ecran; pe 450 de pânză întinși peste ~390 de telefon, 46 de pânză
## ies ~40.
const TASTA_MINIMA_PORTRET := 46


func _portretul() -> bool:
	print("  PE TELEFONUL ȚINUT VERTICAL")
	var rezultat := true
	var ingusta := Vector2(Fereastra.PANZA_PORTRET)
	var mare := Vector2i(PANZA)

	# a) MECANICA. Un ecran care nu o primește rămâne pe pânza mare oricum ar
	#    sta telefonul; unul care o primește o ia doar cât telefonul e vertical.
	var strigate := [0]
	var numara := func(_p: bool) -> void: strigate[0] += 1
	Fereastra.orientare_schimbata.connect(numara)
	Fereastra.simuleaza_verticala(true)
	Fereastra.primeste_portret(false)
	rezultat = _verdict(not Fereastra.portret and get_window().content_scale_size == mare,
		"un ecran care n-o primește rămâne pe pânza mare, cu telefonul vertical") and rezultat
	Fereastra.primeste_portret(true)
	rezultat = _verdict(Fereastra.portret
		and get_window().content_scale_size == Fereastra.PANZA_PORTRET,
		"primită, pânza devine %d × %d" % [ingusta.x, ingusta.y]) and rezultat
	Fereastra.simuleaza_verticala(false)
	rezultat = _verdict(not Fereastra.portret and get_window().content_scale_size == mare,
		"telefonul culcat la loc: pânza mare, chiar dacă ecranul o primea") and rezultat
	Fereastra.simuleaza_verticala(true)
	rezultat = _verdict(Fereastra.portret,
		"ridicat iar: pânza îngustă revine, fiindcă ecranul încă o primește") and rezultat
	Fereastra.primeste_portret(false)
	# Primită, culcat, ridicat, retrasă: patru schimbări. Cele două chemări de
	# la început n-au schimbat nimic, deci n-au voie să strige.
	rezultat = _verdict(strigate[0] == 4,
		"semnalul strigă la fiecare schimbare, și numai atunci (%d din 4)" % strigate[0]) and rezultat
	Fereastra.orientare_schimbata.disconnect(numara)

	# b) TAVERNA, cu telefonul ținut vertical de la intrare.
	var taverna := SCENA_TAVERNA.instantiate()
	add_child(taverna)
	taverna.set_deferred("size", ingusta)
	await get_tree().process_frame
	await get_tree().process_frame
	var margini: Control = taverna.get_node("Margini")
	rezultat = _verdict(Fereastra.portret, "sala cu mese primește pânza îngustă") and rezultat
	var cerut := margini.get_combined_minimum_size()
	print("         Taverna, în portret, cere %d × %d px, pe o pânză de %d × %d"
		% [cerut.x, cerut.y, ingusta.x, ingusta.y])
	rezultat = _verdict(cerut.x <= ingusta.x and cerut.y <= ingusta.y,
		"sala cu mese încape (rezervă %d în lățime, %d în înălțime)"
		% [ingusta.x - cerut.x, ingusta.y - cerut.y]) and rezultat

	# ANTETUL pe două rânduri: titlul are rândul lui, deci trebuie să încapă în
	# lățime; butoanele au rândul lor, deci „i" și „Mesele · Meniu" nu se ating.
	var titlu: Label = taverna.get_node("%Titlu")
	var latime_pagina := ingusta.x - 2 * TAVERNA.MARGINE_LATERALA_PORTRET
	var font_titlu := titlu.get_theme_font("font")
	var marime_titlu := titlu.get_theme_font_size("font_size")
	var cel_mai_lat := 0.0
	for m in Mese.CATALOG:
		cel_mai_lat = maxf(cel_mai_lat, font_titlu.get_string_size(String(m["nume"]),
			HORIZONTAL_ALIGNMENT_LEFT, -1, marime_titlu).x)
	rezultat = _verdict(cel_mai_lat <= latime_pagina,
		"cel mai lung nume de masă încape pe rândul titlului (%d px din %d)"
		% [cel_mai_lat, latime_pagina]) and rezultat
	var butoane: Control = taverna.get_node("Margini/Coloana/Antet/Butoane")
	var buton_mese: Button = taverna.get_node("%ButonMese")
	var buton_i: Control = taverna.get_node("%ButonReguli")
	# Cel mai rău caz: masa deschisă, deci „Mesele" se vede.
	var latime_butoane := butoane.get_combined_minimum_size().x
	if not buton_mese.visible:
		latime_butoane += buton_mese.get_combined_minimum_size().x \
			+ butoane.get_theme_constant("separation")
	rezultat = _verdict(buton_i.get_combined_minimum_size().x + latime_butoane < latime_pagina,
		"„i” și butoanele din dreapta nu se ating (%d + %d px din %d)"
		% [buton_i.get_combined_minimum_size().x, latime_butoane, latime_pagina]) and rezultat

	# c) FIECARE MASĂ: primește sau nu pânza, încape, iar câștigul nu mișcă nimic.
	#    Decretul Zilei NU se deschide pe azi: azi e o zi anume, deci verdictele
	#    ar fi bătut o singură masă găzduită (vezi „O verificare care depinde de
	#    ceas" din CLAUDE.md). Se deschide pe câte o zi CĂUTATĂ pentru fiecare
	#    masă din rotație — fraza lui de ajutor și panoul lui cu reguli sunt cele
	#    mai lungi din tavernă, și sunt altele în fiecare zi.
	for m in Mese.CATALOG:
		if String(m["scena"]) == "" or String(m["cheie"]) == DECRETUL.CHEIE:
			continue
		taverna._deschide_masa(m)
		rezultat = await _masura_in_portret(taverna, String(m["nume"]),
			MESE_IN_PORTRET.has(String(m["cheie"]))) and rezultat

	var decret_din_catalog: Dictionary = Mese.masa(DECRETUL.CHEIE)
	var azi: int = DECRETUL.zi_de_azi()
	for gazduita in DECRETUL.mesele_de_rand():
		var zi := azi + 1
		while String(DECRETUL.masa_zilei(zi)["cheie"]) != String(gazduita["cheie"]):
			zi += 1
		DECRETUL._zi_jucata = 0
		taverna._deschide_masa(decret_din_catalog)
		taverna._porneste_jocul(zi)
		rezultat = await _masura_in_portret(taverna,
			"DECRETUL (%s)" % String(gazduita["nume"]),
			MESE_IN_PORTRET.has(String(gazduita["cheie"]))) and rezultat
	DECRETUL._zi_jucata = 0

	# d) ÎNAPOI LA MESE: pânza îngustă revine, oricare a fost masa de dinainte.
	taverna._arata_mesele()
	await get_tree().process_frame
	rezultat = _verdict(Fereastra.portret, "înapoi la mese, pânza e iar cea îngustă") and rezultat

	# e) TELEFONUL ÎNTORS LA JUMĂTATEA PARTIDEI. Nimic din partidă nu se pierde;
	#    doar așezarea se schimbă, în amândouă sensurile.
	taverna._deschide_masa(Mese.masa("sudoku"))
	taverna._inchide_regulile()
	await get_tree().process_frame
	var sudoku = taverna.joc
	var goala: int = sudoku.date.find(0)
	sudoku.alege(goala)
	sudoku._scrie_cifra(5)
	Fereastra.simuleaza_verticala(false)
	await get_tree().process_frame
	rezultat = _verdict(not Fereastra.portret and sudoku.rand_taste.columns == SUDOKU.LATURA + 1,
		"Sudoku culcat la jumătate: pânza mare, tastele pe un rând") and rezultat
	Fereastra.simuleaza_verticala(true)
	await get_tree().process_frame
	rezultat = _verdict(Fereastra.portret
		and sudoku.rand_taste.columns == SUDOKU.COLOANE_TASTE_PORTRET
		and sudoku.grila[goala] == 5,
		"Sudoku ridicat la loc: tastele pe două rânduri, cifra scrisă e tot acolo") and rezultat

	taverna._deschide_masa(Mese.masa("cuvantul_ascuns"))
	taverna._inchide_regulile()
	await get_tree().process_frame
	var cuvantul = taverna.joc
	for litera in "abc":
		cuvantul._scrie_litera(litera)
	var celula: Control = cuvantul.celule[0][0]
	var in_portret := celula.custom_minimum_size.x
	Fereastra.simuleaza_verticala(false)
	await get_tree().process_frame
	var culcat := celula.custom_minimum_size.x
	Fereastra.simuleaza_verticala(true)
	await get_tree().process_frame
	rezultat = _verdict(in_portret == CUVANTUL.MARIME_CELULA_PORTRET
		and culcat == CUVANTUL.MARIME_CELULA and cuvantul.rand_curent == "abc",
		"Cuvântul întors la jumătate: celula %d → %d px, literele rămân („%s”)"
		% [in_portret, culcat, cuvantul.rand_curent]) and rezultat

	# f) PLECAREA. Meniul nu știe să stea îngust, deci Taverna o retrage.
	taverna.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	rezultat = _verdict(not Fereastra.portret and get_window().content_scale_size == mare,
		"plecarea din tavernă pune la loc pânza mare") and rezultat
	Fereastra.verticala_simulata = -1
	return rezultat


## Masa deschisă acum în Taverna din `_portretul`, măsurată pe pânza îngustă:
## primește pânza cum declară, încape, fraza și uneltele își au rândurile lor,
## tastele sunt cât un deget, regulile încap, iar câștigul nu mișcă nimic.
## `trebuie` = masa e una din `MESE_IN_PORTRET`.
func _masura_in_portret(taverna: Node, nume_masa: String, trebuie: bool) -> bool:
	var rezultat := true
	taverna._inchide_regulile()
	await get_tree().process_frame
	await get_tree().process_frame
	var ingusta := Vector2(Fereastra.PANZA_PORTRET)
	var latime_pagina := ingusta.x - 2 * TAVERNA.MARGINE_LATERALA_PORTRET
	var margini: Control = taverna.get_node("Margini")
	var ajutor: Label = taverna.get_node("%Ajutor")
	var rand_unelte: Control = taverna.get_node("%Unelte")

	var declara: bool = taverna.joc.incape_in_portret()
	if trebuie:
		rezultat = _verdict(declara, "%s se joacă și cu telefonul vertical" % nume_masa) and rezultat
	rezultat = _verdict(Fereastra.portret == declara,
		"%s: pânza e cea %s, cum declară masa"
		% [nume_masa, "îngustă" if declara else "mare"]) and rezultat
	if not declara:
		return rezultat

	var cerut_joc := margini.get_combined_minimum_size()
	print("         %s, în portret, cere %d × %d px" % [nume_masa, cerut_joc.x, cerut_joc.y])
	rezultat = _verdict(cerut_joc.x <= ingusta.x,
		"%s încape în lățime (rezervă %d)" % [nume_masa, ingusta.x - cerut_joc.x]) and rezultat
	rezultat = _verdict(cerut_joc.y <= ingusta.y,
		"%s încape în înălțime (rezervă %d)" % [nume_masa, ingusta.y - cerut_joc.y]) and rezultat
	# Fraza de ajutor, încadrată la lățimea paginii, în cutia pe care i-a dat-o
	# Taverna. Pe TEXT: minimul unei etichete cu autowrap nu spune nimic.
	var inaltime_ajutor := ajutor.get_theme_font("font").get_multiline_string_size(
		ajutor.text, HORIZONTAL_ALIGNMENT_CENTER, latime_pagina,
		ajutor.get_theme_font_size("font_size")).y
	rezultat = _verdict(inaltime_ajutor <= ajutor.size.y + 0.5,
		"%s: fraza de ajutor încape în cutia ei (%d px din %d)"
		% [nume_masa, inaltime_ajutor, ajutor.size.y]) and rezultat
	if rand_unelte.get_child_count() > 0:
		var latime_scule := rand_unelte.get_combined_minimum_size().x
		rezultat = _verdict(latime_scule <= latime_pagina
			and rand_unelte.get_rect().end.y <= ajutor.get_rect().position.y + 0.5,
			"%s: uneltele stau pe rândul lor, deasupra frazei (%d px lățime)"
			% [nume_masa, latime_scule]) and rezultat
	# Tastele: ținte cât un deget. Uneltele (nivelurile) nu sunt taste de joc.
	var cea_mai_joasa := INF
	for buton in _butoanele_din(taverna.joc):
		if buton.is_visible_in_tree() and not rand_unelte.is_ancestor_of(buton):
			cea_mai_joasa = minf(cea_mai_joasa, buton.get_combined_minimum_size().y)
	rezultat = _verdict(cea_mai_joasa >= TASTA_MINIMA_PORTRET,
		"%s: cea mai scundă tastă are %d px (cel puțin %d)"
		% [nume_masa, cea_mai_joasa, TASTA_MINIMA_PORTRET]) and rezultat

	# Panoul cu reguli. `size`, nu minimul — vezi „EXCEPȚIA" de la regula
	# ecranelor: e text cu autowrap, iar înălțimea contează la lățimea lui.
	taverna._arata_regulile()
	await get_tree().process_frame
	await get_tree().process_frame
	var panou: Control = taverna.get_node("PanouReguli/Centru/Panou")
	if taverna.get_node("%PanouReguli").visible:
		rezultat = _verdict(panou.size.x <= ingusta.x and panou.size.y <= ingusta.y,
			"%s: panoul cu reguli încape (%d × %d px)"
			% [nume_masa, panou.size.x, panou.size.y]) and rezultat
	taverna._inchide_regulile()

	# Cea mai lungă frază de rezultat pe care o scrie azi o masă.
	taverna._pe_joc_terminat({"reusit": true,
		"rezumat": "Grila de nivel mediu, completată fără nicio greșeală."})
	await get_tree().process_frame
	await get_tree().process_frame
	var cerut_final := margini.get_combined_minimum_size()
	rezultat = _verdict(is_equal_approx(cerut_final.y, cerut_joc.y)
		and cerut_final.x <= ingusta.x,
		"%s: câștigul nu schimbă înălțimea cerută (%d px înainte, %d după)"
		% [nume_masa, cerut_joc.y, cerut_final.y]) and rezultat
	return rezultat


## Toate butoanele dintr-un nod, la orice adâncime.
func _butoanele_din(nod: Node) -> Array[Button]:
	var gasite: Array[Button] = []
	for copil in nod.get_children():
		if copil is Button:
			gasite.append(copil)
		gasite.append_array(_butoanele_din(copil))
	return gasite


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
# 7b. FIOLELE
#
# Masa a patra, și a doua generată. Garanția ei nu e unicitatea (ca la Sudoku),
# e REZOLVABILITATEA: pot fi multe drumuri, dar trebuie să existe unul.
#
# DOUĂ SOCOTELI CARE TREBUIE SĂ CADĂ DE ACORD, ca la Sudoku. Jocul caută în
# ADÂNCIME, pe liste de numere, cu trei tăieturi de turnări inutile. Verificarea
# caută „CEA MAI BUNĂ STARE ÎNTÂI" (după cât de amestecată e masa), pe ȘIRURI de
# litere, cu regula turnării scrisă din nou și fără nicio tăietură. Și soluția
# fiecăreia se REJOACĂ pe regula celeilalte, mutare cu mutare, până la masa
# sortată: o regulă greșită într-una din ele s-ar vedea ca o turnare refuzată.
# ─────────────────────────────────────────────────────────────

func _fiolele() -> bool:
	print("  FIOLELE — PALETA")
	var rezultat := true

	# a) PALETA, MĂSURATĂ. Deosebirea o duce numai culoarea (nu sunt semne pe
	#    straturi), deci „se văd diferit" e o cifră, nu o părere.
	rezultat = _verdict(FIOLE.PALETA.size() >= int(FIOLE.NIVELURI[-1]["culori"]),
		"paleta are culori pentru cel mai greu nivel (%d)" % FIOLE.PALETA.size()) and rezultat
	for nivel in FIOLE.NIVELURI.size():
		var cate := int(FIOLE.NIVELURI[nivel]["culori"])
		var nume := String(FIOLE.NIVELURI[nivel]["nume"])
		var cea_mai_mica := INF
		var pereche := ""
		var cea_mai_intunecata := INF
		for i in cate:
			var oka := _oklab(FIOLE.PALETA[i]["culoare"])
			cea_mai_intunecata = minf(cea_mai_intunecata, oka.x)
			for j in range(i + 1, cate):
				var d := oka.distance_to(_oklab(FIOLE.PALETA[j]["culoare"]))
				if d < cea_mai_mica:
					cea_mai_mica = d
					pereche = "%s–%s" % [FIOLE.PALETA[i]["nume"], FIOLE.PALETA[j]["nume"]]
		rezultat = _verdict(cea_mai_mica >= PRAG_PALETA,
			"%s: oricare două din cele %d culori sunt la cel puțin %.2f în Oklab (cea mai apropiată: %s, %.3f)"
			% [nume, cate, PRAG_PALETA, pereche, cea_mai_mica]) and rezultat
		rezultat = _verdict(cea_mai_intunecata >= PRAG_LUMINA,
			"%s: fiecare culoare se vede pe fondul închis (L minim %.2f)"
			% [nume, cea_mai_intunecata]) and rezultat

	# b) REGULA TURNĂRII, pe cazuri de mână. Rezolvate întâi pe hârtie (vezi
	#    „O verificare care își scrie singură așteptările" din CLAUDE.md):
	#    [jos … sus], capacitate 4.
	print("  FIOLELE — REGULA")
	var cazuri := [
		# din,          în,              câte, din după,  în după,         ce bate
		[[0, 1, 1],     [],              2, [0],        [1, 1],          "tot stratul, într-o fiolă goală"],
		[[0, 1, 1],     [2, 1, 1],       1, [0, 1],     [2, 1, 1, 1],    "cât încape, nu tot stratul"],
		[[2, 1, 1, 1],  [1],             3, [2],        [1, 1, 1, 1],    "un strat de trei peste aceeași culoare"],
		[[0, 1],        [2],             0, [0, 1],     [2],             "peste altă culoare, nu"],
		[[0],           [0, 0, 0, 0],    0, [0],        [0, 0, 0, 0],    "într-o fiolă plină, nu"],
		[[],            [1],             0, [],         [1],             "dintr-o fiolă goală, nu"],
		[[1, 1, 1, 1],  [],              4, [],         [1, 1, 1, 1],    "o fiolă gata se poate muta întreagă — regula n-o oprește"],
		[[1, 0, 1],     [1, 1],          1, [1, 0],     [1, 1, 1],       "stratul se oprește la prima culoare altfel"],
	]
	for c in cazuri:
		var stare: Array = [(c[0] as Array).duplicate(), (c[1] as Array).duplicate()]
		var turnat: int = FIOLE.turna(stare, 0, 1)
		rezultat = _verdict(turnat == int(c[2]) and stare[0] == c[3] and stare[1] == c[4],
			"%s: %s → %s dă %s → %s (turnate %d)"
			% [c[5], c[0], c[1], stare[0], stare[1], turnat]) and rezultat
		# Și regula verificării spune la fel — altfel una din ele greșește.
		var siruri: Array = [_sir_din(c[0]), _sir_din(c[1])]
		var a_mers := _f_turna(siruri, 0, 1)
		rezultat = _verdict(a_mers == (int(c[2]) > 0)
			and siruri[0] == _sir_din(c[3]) and siruri[1] == _sir_din(c[4]),
			"și regula verificării, pe șiruri, cade de acord") and rezultat
	rezultat = _verdict(not FIOLE.poate_turna([[0, 1], [1]], 1, 1),
		"o fiolă nu se toarnă în ea însăși") and rezultat

	# Masa gata: fiecare fiolă goală sau plină cu o culoare. Al treilea caz e cel
	# care contează: fiole de o singură culoare, dar neumplute, NU sunt gata.
	rezultat = _verdict(FIOLE.e_gata([[0, 0, 0, 0], [1, 1, 1, 1], []]),
		"fiole pline de o culoare, plus una goală: gata") and rezultat
	rezultat = _verdict(not FIOLE.e_gata([[0, 0, 0, 1], [1, 1, 1, 0], []]),
		"fiole pline, dar amestecate: nu") and rezultat
	rezultat = _verdict(not FIOLE.e_gata([[0, 0, 0], [0], [1, 1, 1, 1]]),
		"o culoare despărțită în două fiole, fiecare de o singură culoare: nu") and rezultat

	# c) GENERATORUL, pe semințe × niveluri.
	print("  FIOLELE — GENERATORUL (%d semințe pe nivel)" % SEMINTE_FIOLE)
	var lungimi_medii: Array[float] = []
	for nivel in FIOLE.NIVELURI.size():
		var nume := String(FIOLE.NIVELURI[nivel]["nume"])
		var culori := int(FIOLE.NIVELURI[nivel]["culori"])
		var forma_rea := 0
		var neconservate := 0
		var gata_din_prima := 0
		var nerezolvate := 0
		var refuzate_la_joc := 0
		var refuzate_la_mine := 0
		var peste_capacitate := 0
		var lungime_mea := 0
		var lungime_joc := 0
		var minime: Array[int] = []
		var timp := Time.get_ticks_msec()

		for s in range(1, SEMINTE_FIOLE + 1):
			var rng := RandomNumberGenerator.new()
			rng.seed = 7000 + nivel * 100 + s
			var stare: Array = FIOLE.genereaza(nivel, rng)

			# Forma: culori + goale fiole, niciuna peste capacitate, culori din
			# paletă — și FIECARE culoare de exact `CAPACITATE` ori, adică
			# nimic pierdut și nimic dublat la amestecare.
			if stare.size() != culori + FIOLE.GOALE:
				forma_rea += 1
				continue
			var numar := {}
			for fiola in stare:
				if (fiola as Array).size() > FIOLE.CAPACITATE:
					forma_rea += 1
				for v in fiola:
					numar[int(v)] = int(numar.get(int(v), 0)) + 1
			var bune := numar.size() == culori
			for v in numar:
				if int(v) < 0 or int(v) >= culori or int(numar[v]) != FIOLE.CAPACITATE:
					bune = false
			if not bune:
				neconservate += 1
			if FIOLE.e_gata(stare) or FIOLE._are_fiola_gata(stare):
				gata_din_prima += 1

			# Rezolvat de VERIFICARE, rejucat pe regula JOCULUI.
			var drum_meu := _f_rezolva(_siruri_din(stare))
			if drum_meu.is_empty():
				nerezolvate += 1
			else:
				lungime_mea += drum_meu.size()
				var joc: Array = stare.duplicate(true)
				var refuz := false
				for m in drum_meu:
					if FIOLE.turna(joc, m[0], m[1]) == 0:
						refuz = true
						break
					for fiola in joc:
						if (fiola as Array).size() > FIOLE.CAPACITATE:
							peste_capacitate += 1
				if refuz or not FIOLE.e_gata(joc):
					refuzate_la_joc += 1

			# Și invers: soluția JOCULUI, rejucată pe regula VERIFICĂRII.
			var drum_joc: Array = FIOLE.rezolva(stare)
			lungime_joc += drum_joc.size()
			var siruri := _siruri_din(stare)
			var tot_a_mers := not drum_joc.is_empty()
			for m in drum_joc:
				if not _f_turna(siruri, m[0], m[1]):
					tot_a_mers = false
					break
			if not tot_a_mers or not _f_sortat(siruri):
				refuzate_la_mine += 1

			# Cel mai scurt drum, unde e ieftin de aflat. Nu e verdict: e
			# măsurătoarea pe care se va hotărî, cândva, un prag de mutări
			# minime (vezi antetul mesei).
			var minim := _f_cel_mai_scurt(_siruri_din(stare), BUGET_FIOLE)
			if minim >= 0:
				minime.append(minim)

		var medie := float(lungime_mea) / float(SEMINTE_FIOLE)
		lungimi_medii.append(medie)
		var minime_text := "—"
		if not minime.is_empty():
			var suma := 0
			for x in minime:
				suma += x
			minime_text = "%.1f (pe %d din %d amestecuri)" % [float(suma) / minime.size(),
				minime.size(), SEMINTE_FIOLE]
		print("         %s: %d culori, %d fiole; drum găsit de joc %.1f turnări, de verificare %.1f, cel mai scurt %s — %d ms"
			% [nume, culori, culori + FIOLE.GOALE, float(lungime_joc) / SEMINTE_FIOLE,
			medie, minime_text, Time.get_ticks_msec() - timp])
		rezultat = _verdict(forma_rea == 0,
			"%s: %d fiole, niciuna peste %d straturi" % [nume, culori + FIOLE.GOALE, FIOLE.CAPACITATE]) and rezultat
		rezultat = _verdict(neconservate == 0,
			"%s: fiecare din cele %d culori e de exact %d ori" % [nume, culori, FIOLE.CAPACITATE]) and rezultat
		rezultat = _verdict(gata_din_prima == 0,
			"%s: nicio fiolă nu e gata din prima" % nume) and rezultat
		rezultat = _verdict(nerezolvate == 0,
			"%s: fiecare amestec e rezolvat de verificare (a doua socoteală)" % nume) and rezultat
		rezultat = _verdict(refuzate_la_joc == 0 and peste_capacitate == 0,
			"%s: și soluția ei, rejucată pe regula jocului, sortează masa" % nume) and rezultat
		rezultat = _verdict(refuzate_la_mine == 0,
			"%s: iar soluția jocului, rejucată pe regula verificării, la fel" % nume) and rezultat

	var cresc := true
	for i in range(1, lungimi_medii.size()):
		if lungimi_medii[i] <= lungimi_medii[i - 1]:
			cresc = false
	rezultat = _verdict(cresc,
		"drumurile se lungesc de la un nivel la altul: %s" % [lungimi_medii]) and rezultat

	print("  FIOLELE — SĂMÂNȚA")
	var a := RandomNumberGenerator.new()
	a.seed = 4711
	var b := RandomNumberGenerator.new()
	b.seed = 4711
	var c2 := RandomNumberGenerator.new()
	c2.seed = 4712
	var s1: Array = FIOLE.genereaza(1, a)
	var s2: Array = FIOLE.genereaza(1, b)
	var s3: Array = FIOLE.genereaza(1, c2)
	rezultat = _verdict(s1 == s2, "aceeași sămânță dă același amestec") and rezultat
	rezultat = _verdict(s1 != s3, "o altă sămânță dă alt amestec") and rezultat

	rezultat = await _fiolele_jucate() and rezultat
	rezultat = await _fiolele_indiciul() and rezultat
	return await _fiolele_treptele() and rezultat


## INDICIUL (vezi antetul mesei): butonul nu e pe masă la început, nu apare
## sub `INDICIU_MINIM_TURNARI` oricât te-ai chinui, apare la un semn de chin
## sau peste prag, își ține locul în rând de la început, iar ce spune e
## ADEVĂRAT — o turnare voie pe un drum care merge, sau, dintr-o fundătură,
## câte desfaceri duc înapoi la o masă cu drum. „Cu drum" și „fără drum" se
## judecă și de AL DOILEA rezolvitor, cel al verificării.
func _fiolele_indiciul() -> bool:
	print("  FIOLELE — INDICIUL")
	var rezultat := true
	FIOLE._pe_trepte = false
	var minim: int = FIOLE.INDICIU_MINIM_TURNARI

	var joc := SCENA_FIOLE.instantiate()
	add_child(joc)
	var ceas := Time.get_ticks_msec()
	joc.porneste(2)  # nivelul 2 = Greu, cel mai scump de pornit
	print("         pornirea pe Greu, cu pragul socotit: %d ms; pragul: %d turnări"
		% [Time.get_ticks_msec() - ceas, joc.prag_indiciu])
	await get_tree().process_frame
	var buton: Button = joc.buton_indiciu
	var taste: Control = joc.get_node("%Taste")
	var latime_rand := taste.get_combined_minimum_size().x
	rezultat = _verdict(buton != null and buton.get_parent() == taste and buton.visible
		and buton.modulate.a == 0.0 and buton.disabled
		and buton.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"la început butonul nu se vede și nu se apasă, dar își ține locul în rând") and rezultat
	rezultat = _verdict(joc.prag_indiciu >= minim,
		"pragul pe turnări nu e sub minim (%d ≥ %d)" % [joc.prag_indiciu, minim]) and rezultat

	# SUB MINIM nu apare, oricâte semne de chin: turnări desfăcute și Reia.
	for runda in 2:
		var p := _o_pereche(joc.fiole, true)
		joc.apasa(p[0])
		joc.apasa(p[1])
		joc.inapoi()
	joc.reia()
	rezultat = _verdict(joc.turnari_de_numarat == 2 and joc.semn_de_chin
		and not joc.indiciu_aratat,
		"după 2 turnări desfăcute și un Reia, butonul tot nu apare") and rezultat
	# Cu semnul deja dat, apare EXACT la minim.
	while joc.turnari_de_numarat < minim - 1:
		var p := _o_pereche(joc.fiole, true)
		joc.apasa(p[0])
		joc.apasa(p[1])
	var inainte_de_minim: bool = joc.indiciu_aratat
	joc.inapoi()
	var p2 := _o_pereche(joc.fiole, true)
	joc.apasa(p2[0])
	joc.apasa(p2[1])
	rezultat = _verdict(not inainte_de_minim and joc.indiciu_aratat,
		"cu un semn de chin, apare exact la turnarea %d" % minim) and rezultat
	rezultat = _verdict(buton.modulate.a == 1.0 and not buton.disabled
		and buton.mouse_filter == Control.MOUSE_FILTER_STOP,
		"și atunci se vede și se apasă") and rezultat
	rezultat = _verdict(is_equal_approx(taste.get_combined_minimum_size().x, latime_rand),
		"rândul de taste nu s-a lărgit (%d px): Înapoi și Reia n-au fugit de sub cursor"
		% latime_rand) and rezultat

	# CALEA A DOUA, fără niciun semn: nimic sub prag, totul la prag.
	joc.turnari_de_numarat = joc.prag_indiciu - 1
	joc.semn_de_chin = false
	joc.indiciu_aratat = false
	joc._poate_apare_indiciul()
	var sub_prag: bool = joc.indiciu_aratat
	joc.turnari_de_numarat = joc.prag_indiciu
	joc._poate_apare_indiciul()
	rezultat = _verdict(not sub_prag and joc.indiciu_aratat,
		"fără semn de chin, apare abia peste drumul rezolvitorului (%d turnări)"
		% joc.prag_indiciu) and rezultat

	# CE SPUNE, pe o masă cu drum: o turnare voie, arătată pe ecran, și
	# urmându-l de la cap la coadă se sortează masa.
	joc.reia()
	var raportat := []
	joc.terminat.connect(func(rez): raportat.append(rez))
	joc.cere_indiciu()
	var primul_bun: bool = joc.aleasa >= 0 and joc.tinta_indiciului >= 0 \
		and FIOLE.poate_turna(joc.fiole, joc.aleasa, joc.tinta_indiciului) \
		and joc.vase[joc.aleasa].ridicata and joc.vase[joc.tinta_indiciului].indicata
	rezultat = _verdict(primul_bun,
		"indiciul ridică fiola de turnat și o face să pulseze pe cea în care torni") and rezultat
	# UN INDICIU PE BLOCAJ: folosit, butonul pleacă și socoteala o ia de la capăt.
	rezultat = _verdict(not joc.indiciu_aratat and buton.modulate.a == 0.0 and buton.disabled
		and buton.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"folosit, butonul dispare (haloul rămâne)") and rezultat
	rezultat = _verdict(joc.turnari_de_numarat == 0 and not joc.semn_de_chin,
		"iar numărătoarea și semnul de chin o iau de la capăt") and rezultat
	var de_dinainte_de_buton: Array = joc.fiole.duplicate(true)
	buton.pressed.emit()
	rezultat = _verdict(joc.fiole == de_dinainte_de_buton and joc.indicii_luate == 1,
		"un clic pe locul lui gol nu mai dă niciun indiciu") and rezultat
	var tinta: int = joc.tinta_indiciului
	joc.apasa(tinta)
	rezultat = _verdict(not joc.vase[tinta].indicata and joc.tinta_indiciului == -1,
		"după turnare haloul se stinge") and rezultat
	# De aici, butonul se dă înapoi DE MÂNĂ înaintea fiecărui indiciu: ce se
	# bate e că planul duce la capăt, nu regula apariției (bătută mai jos).
	var pasi := 1
	while not joc.terminat_deja and pasi < 300:
		joc.indiciu_aratat = true
		joc.cere_indiciu()
		if joc.tinta_indiciului < 0:
			break
		joc.apasa(joc.tinta_indiciului)
		pasi += 1
	rezultat = _verdict(raportat.size() == 1 and bool(raportat[0]["reusit"]),
		"urmând numai indiciile, masa se sortează (%d indicii)" % pasi) and rezultat
	if raportat.size() == 1:
		var asteptat_indicii := FIOLE._turnari(pasi).replace("turnări", "indicii")
		rezultat = _verdict(String(raportat[0]["rezumat"]).contains(asteptat_indicii),
			"iar rezumatul le spune: %s" % raportat[0]["rezumat"]) and rezultat
	joc.queue_free()

	# REAPARE numai la un blocaj NOU: după indiciu, aceeași regulă de la zero —
	# nimic sub minim, chiar cu semn de chin; exact la minim, cu semn.
	var din_nou := SCENA_FIOLE.instantiate()
	add_child(din_nou)
	din_nou.porneste(2)
	await get_tree().process_frame
	for k in minim:
		var p := _o_pereche(din_nou.fiole, true)
		din_nou.apasa(p[0])
		din_nou.apasa(p[1])
	din_nou.inapoi()
	var aparut_prima: bool = din_nou.indiciu_aratat
	din_nou.cere_indiciu()
	din_nou.apasa(din_nou.aleasa)  # lasă jos fiola ridicată de indiciu
	for k in minim - 1:
		var p := _o_pereche(din_nou.fiole, true)
		din_nou.apasa(p[0])
		din_nou.apasa(p[1])
	din_nou.inapoi()
	var sub_minim_iar: bool = din_nou.indiciu_aratat
	var p3 := _o_pereche(din_nou.fiole, true)
	din_nou.apasa(p3[0])
	din_nou.apasa(p3[1])
	var p4 := _o_pereche(din_nou.fiole, true)
	din_nou.apasa(p4[0])
	din_nou.apasa(p4[1])
	rezultat = _verdict(aparut_prima and not sub_minim_iar and din_nou.indiciu_aratat
		and din_nou.buton_indiciu.modulate.a == 1.0,
		"după un indiciu, butonul reapare abia la un blocaj nou: nu după %d turnări + Înapoi, da după %d"
		% [minim - 1, minim]) and rezultat
	din_nou.queue_free()

	# FUNDĂTURILE: pe drumuri la întâmplare, masa ajunge undeva fără drum. Atunci
	# indiciul spune câte desfaceri; după atâtea e drum, cu una mai puțin nu.
	var fundaturi := 0
	var adevarate := 0
	var cel_mai_lent := 0
	var rng := RandomNumberGenerator.new()
	for samanta in 40:
		rng.seed = 900 + samanta
		var stare: Array = FIOLE.genereaza(samanta % FIOLE.NIVELURI.size(), rng)
		var trecut: Array = []
		for pas in 60:
			if not FIOLE.are_turnari(stare) or FIOLE.e_gata(stare):
				break
			var posibile := []
			for din in stare.size():
				for in_ in stare.size():
					if FIOLE.poate_turna(stare, din, in_):
						posibile.append([din, in_])
			var m: Array = posibile[rng.randi() % posibile.size()]
			trecut.append(stare.duplicate(true))
			FIOLE.turna(stare, m[0], m[1])
		if FIOLE.e_gata(stare) or not FIOLE.rezolva(stare).is_empty():
			continue
		fundaturi += 1
		var ceas_f := Time.get_ticks_msec()
		var raspuns := FIOLE.indiciu_pentru(stare, trecut)
		cel_mai_lent = maxi(cel_mai_lent, Time.get_ticks_msec() - ceas_f)
		if not raspuns.has("inapoi"):
			continue
		var k := int(raspuns["inapoi"])
		var bun: Array = trecut[trecut.size() - k]
		var urmatorul: Array = stare if k == 1 else trecut[trecut.size() - k + 1]
		# Al doilea rezolvitor: drum acolo unde spune jocul, niciunul un pas mai
		# încolo.
		if not _f_rezolva(_siruri_din(bun)).is_empty() \
				and _f_rezolva(_siruri_din(urmatorul)).is_empty():
			adevarate += 1
	print("         %d fundături găsite pe 40 de drumuri la întâmplare; cel mai lent indiciu: %d ms"
		% [fundaturi, cel_mai_lent])
	rezultat = _verdict(fundaturi >= 5,
		"drumurile la întâmplare dau destule fundături de bătut (%d)" % fundaturi) and rezultat
	rezultat = _verdict(adevarate == fundaturi,
		"în fiecare fundătură indiciul spune câte desfaceri, iar AL DOILEA rezolvitor e de acord (%d din %d)"
		% [adevarate, fundaturi]) and rezultat
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


## TREPTELE — al doilea fel de a alege dificultatea (vezi antetul mesei).
##
## Trei lucruri: rețeta crește și nu scade pe 1200 de trepte; masa unei trepte
## e aceeași de fiecare dată, rezolvată de VERIFICARE, cu ascunsele numai sub
## vârf; și partida jucată cu scena adevărată, în care ce s-a văzut nu se mai
## ascunde, iar câștigul urcă treapta.
const TREPTE_DE_BATUT := [1, 2, 3, 4, 5, 6, 10, 15, 19, 20, 21, 27, 36, 50, 100, 176, 177, 500, 1000, 1001]

func _fiolele_treptele() -> bool:
	print("  FIOLELE — TREPTELE")
	var rezultat := true
	var treapta_de_dinainte: int = FIOLE._treapta

	# a) REȚETA, pe 1200 de trepte.
	var prima: Dictionary = FIOLE.reteta_treptei(1)
	rezultat = _verdict(int(prima["culori"]) + int(prima["goale"]) == 3,
		"treapta 1 e cel mai mic joc: %d culori în %d fiole" % [prima["culori"],
		int(prima["culori"]) + int(prima["goale"])]) and rezultat
	var scade := 0
	var peste := 0
	var ascunse_devreme := 0
	var prima_ascunsa := -1
	var plafon := -1
	var de_dinainte: Dictionary = prima
	for n in range(1, 1201):
		var r: Dictionary = FIOLE.reteta_treptei(n)
		if int(r["culori"]) < int(de_dinainte["culori"]) or int(r["ascunse"]) < int(de_dinainte["ascunse"]):
			scade += 1
		if int(r["culori"]) > FIOLE.PALETA.size() or int(r["culori"]) < 2 \
				or int(r["ascunse"]) > int(r["culori"]) * (FIOLE.CAPACITATE - 1):
			peste += 1
		if int(r["ascunse"]) > 0 and prima_ascunsa < 0:
			prima_ascunsa = n
		if n < FIOLE.TREAPTA_PRIMA_ASCUNSA and int(r["ascunse"]) > 0:
			ascunse_devreme += 1
		if plafon < 0 and int(r["culori"]) == FIOLE.PALETA.size() \
				and int(r["ascunse"]) == FIOLE.PALETA.size() * (FIOLE.CAPACITATE - 1):
			plafon = n
		de_dinainte = r
	rezultat = _verdict(scade == 0, "pe 1200 de trepte, nici culorile, nici ascunsele nu scad") and rezultat
	rezultat = _verdict(peste == 0,
		"nicio treaptă peste paletă și niciuna cu mai multe ascunse decât straturi de sub vârf") and rezultat
	rezultat = _verdict(prima_ascunsa == FIOLE.TREAPTA_PRIMA_ASCUNSA and ascunse_devreme == 0,
		"primul strat ascuns vine la treapta %d, nu mai devreme" % prima_ascunsa) and rezultat
	rezultat = _verdict(plafon == FIOLE.TREAPTA_PLAFON,
		"rețeta se închide la treapta %d (constanta spune %d)" % [plafon, FIOLE.TREAPTA_PLAFON]) and rezultat

	# b) MASA UNEI TREPTE, pe trepte alese de-a lungul drumului.
	var forma_rea := 0
	var nerezolvate := 0
	var neasezate := 0
	var ascunse_rele := 0
	var timp := Time.get_ticks_msec()
	for n in TREPTE_DE_BATUT:
		var r: Dictionary = FIOLE.reteta_treptei(n)
		var masa: Dictionary = FIOLE.genereaza_treapta(n)
		var stare: Array = masa["fiole"]
		var culori := int(r["culori"])
		var numar := {}
		for fiola in stare:
			for v in fiola:
				numar[int(v)] = int(numar.get(int(v), 0)) + 1
		var bune := stare.size() == culori + int(r["goale"]) and numar.size() == culori
		for v in numar:
			if int(numar[v]) != FIOLE.CAPACITATE:
				bune = false
		if not bune or FIOLE._are_fiola_gata(stare):
			forma_rea += 1
		if _f_rezolva(_siruri_din(stare)).is_empty():
			nerezolvate += 1
		var din_nou: Dictionary = FIOLE.genereaza_treapta(n)
		if din_nou["fiole"] != stare or din_nou["ascunse"] != masa["ascunse"]:
			neasezate += 1
		var vazute := {}
		for poz in masa["ascunse"]:
			var loc: Vector2i = poz
			if vazute.has(loc) or loc.x < 0 or loc.x >= stare.size() \
					or loc.y < 0 or loc.y >= (stare[loc.x] as Array).size() - 1:
				ascunse_rele += 1
			vazute[loc] = true
		if vazute.size() != int(r["ascunse"]):
			ascunse_rele += 1
	print("         %d trepte generate în %d ms" % [TREPTE_DE_BATUT.size(), Time.get_ticks_msec() - timp])
	rezultat = _verdict(forma_rea == 0,
		"pe %d trepte: fiolele și culorile cerute de rețetă, nimic gata din prima" % TREPTE_DE_BATUT.size()) and rezultat
	rezultat = _verdict(nerezolvate == 0, "și fiecare masă e rezolvată de verificare") and rezultat
	rezultat = _verdict(neasezate == 0, "treapta N e mereu aceeași masă, cu aceleași ascunse") and rezultat
	rezultat = _verdict(ascunse_rele == 0,
		"ascunsele sunt câte cere rețeta, distincte, și niciuna deasupra") and rezultat

	# c) PARTIDA JUCATĂ, pe o treaptă cu multe ascunse.
	var n_joc := 60
	FIOLE._pe_trepte = true
	FIOLE._treapta = n_joc
	var joc := SCENA_FIOLE.instantiate()
	add_child(joc)
	var raportat := []
	joc.terminat.connect(func(rez): raportat.append(rez))
	joc.porneste(Joc.SAMANTA_LIBERA)
	var cate := int(FIOLE.reteta_treptei(n_joc)["ascunse"])
	rezultat = _verdict(joc.treapta == n_joc and joc.ascunse_start.size() == cate,
		"pe trepte, masa e treapta %d, cu %d straturi ascunse" % [n_joc, cate]) and rezultat
	rezultat = _verdict(joc.buton_trepte.text.contains(str(n_joc)),
		"butonul spune treapta: %s" % joc.buton_trepte.text) and rezultat
	rezultat = _verdict(_ascunse_desenate(joc) == cate and _desenul_spune_ce_e_ascuns(joc),
		"iar fiolele desenate le poartă exact pe ele") and rezultat

	var drum := _f_rezolva(_siruri_din(joc.fiole))
	var varf_ascuns := 0
	var reascunse := 0
	var nedesenate := 0
	var vazute_inainte := {}
	for idx in drum.size():
		var m: Array = drum[idx]
		joc.apasa(m[0])
		joc.apasa(m[1])
		if raportat.is_empty():
			for f in joc.fiole.size():
				var h := (joc.fiole[f] as Array).size()
				if h > 0 and joc.e_ascuns(f, h - 1):
					varf_ascuns += 1
			if not _desenul_spune_ce_e_ascuns(joc):
				nedesenate += 1
		# La jumătatea drumului: un „Înapoi" nu ascunde la loc ce s-a văzut.
		if idx == drum.size() / 2:
			vazute_inainte = joc.dezvaluite.duplicate()
			joc.inapoi()
			for loc in vazute_inainte:
				if not joc.dezvaluite.has(loc):
					reascunse += 1
			joc.apasa(m[0])
			joc.apasa(m[1])
	rezultat = _verdict(varf_ascuns == 0,
		"după fiecare din cele %d turnări, niciun vârf de fiolă nu e ascuns" % drum.size()) and rezultat
	rezultat = _verdict(nedesenate == 0, "și desenul ține pasul cu ce e ascuns") and rezultat
	rezultat = _verdict(reascunse == 0 and not vazute_inainte.is_empty(),
		"Înapoi întoarce lichidul, nu și ce s-a văzut (%d straturi văzute)" % vazute_inainte.size()) and rezultat
	rezultat = _verdict(raportat.size() == 1 and FIOLE._treapta == n_joc + 1,
		"câștigul încheie partida și urcă treapta la %d" % FIOLE._treapta) and rezultat
	if raportat.size() == 1:
		rezultat = _verdict(String(raportat[0]["rezumat"]).contains(str(n_joc + 1)),
			"iar fraza spune ce urmează: %s" % raportat[0]["rezumat"]) and rezultat
	joc.queue_free()

	# d) „ÎNCĂ UNUL" e treapta următoare; un nivel te scoate de pe trepte; o
	# sămânță (decretul) nu urcă nimic.
	var masa2 := SCENA_FIOLE.instantiate()
	add_child(masa2)
	masa2.porneste(Joc.SAMANTA_LIBERA)
	rezultat = _verdict(masa2.treapta == n_joc + 1, "partida următoare e treapta %d" % (n_joc + 1)) and rezultat
	masa2.schimba_nivelul(0)
	rezultat = _verdict(masa2.treapta == 0 and masa2.nivel == 0 and masa2.ascunse_start.is_empty()
		and not FIOLE._pe_trepte, "un nivel de pe tăblie te scoate de pe trepte, fără ascunse") and rezultat
	masa2.urca_pe_trepte()
	rezultat = _verdict(masa2.treapta == n_joc + 1, "și butonul treptelor te duce înapoi unde rămăseseși") and rezultat
	masa2.porneste(42)
	rezultat = _verdict(masa2.treapta == 0 and masa2.nivel == 42 % FIOLE.NIVELURI.size(),
		"cu o sămânță dată (decretul), nici pe trepte nu se joacă treapta") and rezultat
	masa2.queue_free()

	# e) DISCUL.
	FIOLE._treapta = 314
	var pe_disc: Dictionary = FIOLE.spre_dictionar()
	FIOLE._treapta = 1
	FIOLE.din_dictionar(JSON.parse_string(JSON.stringify(pe_disc)))
	rezultat = _verdict(FIOLE._treapta == 314, "treapta trece prin disc (JSON) neatinsă") and rezultat
	FIOLE.din_dictionar({})
	var lipsa: int = FIOLE._treapta
	FIOLE.din_dictionar({"treapta": "multe"})
	var stramba: int = FIOLE._treapta
	FIOLE.din_dictionar({"treapta": -4})
	rezultat = _verdict(lipsa == 1 and stramba == 1 and FIOLE._treapta == 1,
		"o cheie lipsă, strâmbă sau negativă e treapta 1") and rezultat

	FIOLE._pe_trepte = false
	FIOLE._treapta = treapta_de_dinainte
	await get_tree().process_frame
	return rezultat


func _ascunse_desenate(joc) -> int:
	var cate := 0
	for vas in joc.vase:
		for a in vas.ascunse:
			if a:
				cate += 1
	return cate


## Desenul spune adevărul: fiecare fiolă desenată are ascunse exact straturile
## pe care masa le crede ascunse.
func _desenul_spune_ce_e_ascuns(joc) -> bool:
	for f in joc.vase.size():
		if joc.vase[f].ascunse != joc.ascunse_in(f):
			return false
	return true


## PARTIDA JUCATĂ CU SCENA ADEVĂRATĂ — fratele lui `_sudoku_jucat`.
func _fiolele_jucate() -> bool:
	print("  FIOLELE — PARTIDA JUCATĂ")
	var rezultat := true
	# Pe un nivel, nu pe trepte: secțiunea TREPTELE vine după și le pune înapoi.
	FIOLE._pe_trepte = false

	var joc := SCENA_FIOLE.instantiate()
	add_child(joc)
	joc.porneste(42)
	var nivel_asteptat := 42 % FIOLE.NIVELURI.size()
	var culori := int(FIOLE.NIVELURI[nivel_asteptat]["culori"])
	rezultat = _verdict(joc.nivel == nivel_asteptat,
		"cu sămânța 42, nivelul e %d" % nivel_asteptat) and rezultat
	rezultat = _verdict(joc.vase.size() == culori + FIOLE.GOALE,
		"sunt %d fiole desenate" % (culori + FIOLE.GOALE)) and rezultat
	rezultat = _verdict(joc.butoane_nivel.size() == FIOLE.NIVELURI.size(),
		"cele %d niveluri sunt gata de atârnat" % FIOLE.NIVELURI.size()) and rezultat

	# REGULILE: compuse din constante, și cu o turnare ADEVĂRATĂ în ele — patru
	# fiole, aceleași straturi înainte și după, dar nu aceeași masă.
	var cuprins: Control = joc.reguli()
	rezultat = _verdict(cuprins != null, "Fiolele își scriu regulile") and rezultat
	if cuprins != null:
		rezultat = _verdict(_textul_din(cuprins).contains(str(FIOLE.CAPACITATE)),
			"regulile spun câte straturi ține o fiolă (%d), din constantă" % FIOLE.CAPACITATE) and rezultat
		var desenate := _fiolele_din(cuprins)
		rezultat = _verdict(desenate.size() == 4,
			"regulile ARATĂ fiole adevărate (%d)" % desenate.size()) and rezultat
		if desenate.size() == 4:
			var inainte: int = desenate[0].culori.size() + desenate[1].culori.size()
			var dupa: int = desenate[2].culori.size() + desenate[3].culori.size()
			rezultat = _verdict(inainte == dupa
				and desenate[0].culori.size() != desenate[2].culori.size(),
				"și o turnare între ele: %d straturi înainte, %d după, mutate" % [inainte, dupa]) and rezultat
		cuprins.free()

	# O TURNARE CARE NU E VOIE: masa rămâne neatinsă și ecranul spune de ce.
	var nevoie := _o_pereche(joc.fiole, false)
	if nevoie.is_empty():
		print("         (n-am găsit o turnare oprită pe masa asta — sari)")
	else:
		var inainte_de: Array = joc.fiole.duplicate(true)
		joc.apasa(nevoie[0])
		joc.apasa(nevoie[1])
		rezultat = _verdict(joc.fiole == inainte_de and joc.istoric.is_empty(),
			"o turnare oprită de regulă nu schimbă nimic") and rezultat
		rezultat = _verdict(joc.mesaj.text != "",
			"și ecranul spune de ce: %s" % joc.mesaj.text) and rezultat
		rezultat = _verdict(joc.aleasa == nevoie[1],
			"iar fiola apăsată devine cea aleasă (ai vrut altă sursă)") and rezultat
		joc.apasa(nevoie[1])
		rezultat = _verdict(joc.aleasa == -1, "al doilea clic pe ea o lasă jos") and rezultat

	# O TURNARE VOIE: masa se schimbă EXACT cum spune regula.
	var voie := _o_pereche(joc.fiole, true)
	var asteptat: Array = joc.fiole.duplicate(true)
	FIOLE.turna(asteptat, voie[0], voie[1])
	var de_dinainte: Array = joc.fiole.duplicate(true)
	joc.apasa(voie[0])
	rezultat = _verdict(joc.aleasa == voie[0] and joc.vase[voie[0]].ridicata,
		"primul clic alege fiola, iar ea se ridică") and rezultat
	joc.apasa(voie[1])
	rezultat = _verdict(joc.fiole == asteptat and joc.istoric.size() == 1,
		"al doilea clic toarnă, exact cum spune regula") and rezultat

	# „ÎNAPOI" întoarce EXACT starea de dinainte — și de la tastatură.
	var tasta := InputEventKey.new()
	tasta.keycode = KEY_BACKSPACE
	tasta.pressed = true
	get_viewport().push_input(tasta)
	await get_tree().process_frame
	rezultat = _verdict(joc.fiole == de_dinainte and joc.istoric.is_empty(),
		"Backspace desface turnarea, înapoi la starea de dinainte") and rezultat

	# „REIA" după câteva turnări: amestecul de la început, nu altul.
	for k in 3:
		var p := _o_pereche(joc.fiole, true)
		joc.apasa(p[0])
		joc.apasa(p[1])
	rezultat = _verdict(joc.istoric.size() == 3, "trei turnări la rând") and rezultat
	joc.reia()
	rezultat = _verdict(joc.fiole == joc.start and joc.istoric.is_empty() and joc.aleasa == -1,
		"Reia întoarce amestecul de la început, cu istoricul gol") and rezultat

	# PARTIDA ÎNTREAGĂ, cu drumul găsit de VERIFICARE.
	var raportat := []
	joc.terminat.connect(func(rez): raportat.append(rez))
	var drum := _f_rezolva(_siruri_din(joc.fiole))
	for m in drum:
		joc.apasa(m[0])
		joc.apasa(m[1])
	rezultat = _verdict(FIOLE.e_gata(joc.fiole),
		"drumul verificării, jucat cu clicuri pe masă, o sortează (%d turnări)" % drum.size()) and rezultat
	rezultat = _verdict(raportat.size() == 1,
		"masa sortată încheie partida, o singură dată") and rezultat
	if raportat.size() == 1:
		rezultat = _verdict(bool(raportat[0]["reusit"]),
			"și o încheie cu «reușit» — Fiolele nu se pot pierde") and rezultat
		rezultat = _verdict(String(raportat[0]["rezumat"]).contains("turnăr")
			or String(raportat[0]["rezumat"]).contains("turnare"),
			"cu o frază care spune câte turnări: %s" % raportat[0]["rezumat"]) and rezultat
	var dupa_final: Array = joc.fiole.duplicate(true)
	joc.inapoi()
	joc.apasa(0)
	rezultat = _verdict(joc.fiole == dupa_final and joc.aleasa == -1,
		"după final, nici Înapoi, nici clicurile nu mai schimbă masa") and rezultat
	rezultat = _verdict(FIOLE._turnari(1) == "o turnare" and FIOLE._turnari(7) == "7 turnări"
		and FIOLE._turnari(23) == "23 de turnări" and FIOLE._turnari(112) == "112 turnări",
		"și numără ca în română: o turnare, 7 turnări, 23 de turnări, 112 turnări") and rezultat
	joc.queue_free()

	# NIVELUL DE PE TĂBLIE repornește partida și o anunță.
	var masa := SCENA_FIOLE.instantiate()
	add_child(masa)
	var porniri := []
	masa.pornita.connect(func(): porniri.append(true))
	masa.porneste(Joc.SAMANTA_LIBERA)
	var altul := (int(masa.nivel) + 1) % FIOLE.NIVELURI.size()
	masa.schimba_nivelul(altul)
	rezultat = _verdict(masa.nivel == altul and porniri.size() == 2,
		"un alt nivel repornește partida și o anunță") and rezultat
	rezultat = _verdict(masa.vase.size() == int(FIOLE.NIVELURI[altul]["culori"]) + FIOLE.GOALE,
		"cu atâtea fiole câte cere nivelul nou (%d)" % masa.vase.size()) and rezultat
	await get_tree().process_frame
	rezultat = _verdict(masa.get_node("%Fiole").get_child_count() == masa.vase.size(),
		"iar fiolele partidei de dinainte au plecat de pe masă") and rezultat
	masa.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	return rezultat


## Fiolele desenate dintr-un arbore, în ordinea din arbore.
func _fiolele_din(nod: Node) -> Array:
	var gasite := []
	if nod.get_script() == FIOLE.FIOLA:
		gasite.append(nod)
	for copil in nod.get_children():
		gasite.append_array(_fiolele_din(copil))
	return gasite


## Prima pereche `[din, în]` cu sursa nevidă la care turnarea E voie (sau, cu
## `voie = false`, NU e voie, cu ținta tot nevidă și neplină — ca refuzul să
## vină din culoare, cazul care chiar se întâmplă la masă).
func _o_pereche(stare: Array, voie: bool) -> Array:
	for din in stare.size():
		if (stare[din] as Array).is_empty():
			continue
		for in_ in stare.size():
			if din == in_:
				continue
			var tinta: Array = stare[in_]
			if voie and FIOLE.poate_turna(stare, din, in_):
				return [din, in_]
			if not voie and not tinta.is_empty() and tinta.size() < FIOLE.CAPACITATE \
					and not FIOLE.poate_turna(stare, din, in_):
				return [din, in_]
	return []


# ─────────────────────────────────────────────────────────────
# REZOLVITORUL VERIFICĂRII PENTRU FIOLE — A DOUA SOCOTEALĂ
#
# O fiolă e un ȘIR de litere, de jos în sus („ABB" = roșu jos, două galbene
# sus), iar regula turnării e scrisă aici din nou, cu operații pe șiruri. Nu
# cheamă nimic din `fiolele.gd`: dacă ar chema, „cade de acord cu jocul" ar fi
# fost o oglindă.
# ─────────────────────────────────────────────────────────────

func _sir_din(fiola: Array) -> String:
	var s := ""
	for v in fiola:
		s += char(65 + int(v))
	return s


func _siruri_din(stare: Array) -> Array:
	var siruri := []
	for fiola in stare:
		siruri.append(_sir_din(fiola))
	return siruri


## Toarnă pe loc; `false` dacă nu e voie (și atunci nu atinge nimic).
func _f_turna(s: Array, din: int, in_: int) -> bool:
	if din == in_:
		return false
	var x: String = s[din]
	var y: String = s[in_]
	if x.is_empty() or y.length() >= FIOLE.CAPACITATE:
		return false
	var culoare := x.right(1)
	if not y.is_empty() and y.right(1) != culoare:
		return false
	var strat := 0
	while strat < x.length() and x[x.length() - 1 - strat] == culoare:
		strat += 1
	var cat := mini(strat, FIOLE.CAPACITATE - y.length())
	s[din] = x.left(x.length() - cat)
	s[in_] = y + culoare.repeat(cat)
	return true


## Sortată, spus ca o afirmație despre ȘIRURI: fiecare e gol sau e o literă
## repetată de câte ori încape.
func _f_sortat(s: Array) -> bool:
	for x in s:
		var sir: String = x
		if not sir.is_empty() and sir != sir.left(1).repeat(FIOLE.CAPACITATE):
			return false
	return true


func _f_cheie(s: Array) -> String:
	var copie := PackedStringArray(s)
	copie.sort()
	return ",".join(copie)


## Cât de amestecată e masa: câte schimbări de culoare sunt în fiole, plus în
## câte fiole în plus e risipită fiecare culoare. Zero = sortată.
func _f_amestec(s: Array) -> int:
	var cost := 0
	var unde := {}
	for x in s:
		var sir: String = x
		for i in sir.length():
			if i > 0 and sir[i] != sir[i - 1]:
				cost += 1
			if not unde.has(sir[i]):
				unde[sir[i]] = {}
			unde[sir[i]][sir] = true
	for culoare in unde:
		cost += (unde[culoare] as Dictionary).size() - 1
	return cost


## UN drum, căutat „cea mai bună stare întâi": se desface mereu starea cea mai
## puțin amestecată dintre cele văzute. Altă ordine decât adâncimea jocului, și
## nicio tăietură — fiecare turnare voie e încercată.
func _f_rezolva(start: Array) -> Array:
	var cheie0 := _f_cheie(start)
	var de_unde := {cheie0: null}
	var galeti: Array = []
	_f_pune(galeti, _f_amestec(start), [start, cheie0])
	var desfacute := 0
	while desfacute < BUGET_FIOLE:
		var nod: Array = []
		for galeata in galeti:
			if not (galeata as Array).is_empty():
				nod = (galeata as Array).pop_back()
				break
		if nod.is_empty():
			return []
		var s: Array = nod[0]
		var cheie: String = nod[1]
		if _f_sortat(s):
			var drum := []
			var k = cheie
			while de_unde[k] != null:
				drum.push_front(de_unde[k][1])
				k = de_unde[k][0]
			return drum
		desfacute += 1
		for din in s.size():
			for in_ in s.size():
				var t := s.duplicate()
				if not _f_turna(t, din, in_):
					continue
				var kt := _f_cheie(t)
				if de_unde.has(kt):
					continue
				de_unde[kt] = [cheie, [din, in_]]
				_f_pune(galeti, _f_amestec(t), [t, kt])
	return []


func _f_pune(galeti: Array, cost: int, nod: Array) -> void:
	while galeti.size() <= cost:
		galeti.append([])
	(galeti[cost] as Array).append(nod)


## Cel mai scurt drum, în LĂȚIME, cu buget. -1 dacă bugetul nu ajunge.
func _f_cel_mai_scurt(start: Array, buget: int) -> int:
	var vazute := {_f_cheie(start): true}
	var strat: Array = [start]
	var pasi := 0
	var desfacute := 0
	while not strat.is_empty():
		var urmator: Array = []
		for s in strat:
			if _f_sortat(s):
				return pasi
			desfacute += 1
			if desfacute > buget:
				return -1
			for din in (s as Array).size():
				for in_ in (s as Array).size():
					var t: Array = (s as Array).duplicate()
					if not _f_turna(t, din, in_):
						continue
					var kt := _f_cheie(t)
					if vazute.has(kt):
						continue
					vazute[kt] = true
					urmator.append(t)
		strat = urmator
		pasi += 1
	return -1


## Oklab (Björn Ottosson, 2020): L, a, b, cu distanța euclidiană aproape de cea
## pe care o vede ochiul. `Color` ține componentele în sRGB, deci întâi se
## liniarizează.
func _oklab(c: Color) -> Vector3:
	var lin := c.srgb_to_linear()
	var l := 0.4122214708 * lin.r + 0.5363325363 * lin.g + 0.0514459929 * lin.b
	var m := 0.2119034982 * lin.r + 0.6806995451 * lin.g + 0.1073969566 * lin.b
	var s := 0.0883024619 * lin.r + 0.2817188376 * lin.g + 0.6299787005 * lin.b
	l = pow(l, 1.0 / 3.0)
	m = pow(m, 1.0 / 3.0)
	s = pow(s, 1.0 / 3.0)
	return Vector3(
		0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)

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

	# d) FIOLELE: un clic pe o fiolă cu lichid o alege, unul pe o fiolă goală
	#    toarnă, iar butonul „Înapoi" de pe ecran desface.
	taverna._arata_mesele()
	await get_tree().process_frame
	taverna._deschide_masa(Mese.masa("fiolele"))
	taverna._inchide_regulile()
	await get_tree().process_frame
	await get_tree().process_frame
	var fiole = taverna.joc
	var plina := -1
	var goala_f := -1
	for i in fiole.fiole.size():
		if (fiole.fiole[i] as Array).is_empty():
			if goala_f < 0:
				goala_f = i
		elif plina < 0:
			plina = i
	await _clic_pe(fiole.vase[plina])
	rezultat = _verdict(fiole.aleasa == plina,
		"un CLIC pe o fiolă o alege (fiola %d, aleasă %d)" % [plina, fiole.aleasa]) and rezultat
	await _clic_pe(fiole.vase[goala_f])
	rezultat = _verdict(fiole.istoric.size() == 1 and not (fiole.fiole[goala_f] as Array).is_empty(),
		"și un clic pe o fiolă goală toarnă în ea") and rezultat
	await _clic_pe(fiole.buton_inapoi)
	rezultat = _verdict(fiole.istoric.is_empty() and (fiole.fiole[goala_f] as Array).is_empty(),
		"un clic pe „Înapoi\" o desface") and rezultat

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

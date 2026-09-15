extends Puzzle
## Disciplina CUVINTE — a treia, și prima scrisă DUPĂ ce a apărut `puzzle.gd`.
##
## Tot ce ține de cronometru, butoane, culori, sunete și contractul cu lupta
## trăiește în baza comună. Fișierul ăsta răspunde la o singură întrebare:
## DE UNDE VINE ÎNTREBAREA. (Dacă ai scris-o pe a patra și ai nevoie de un
## model, ăsta e cel mai scurt din cele trei — copiază-l pe el.)
##
## TREI TIPURI DE PROVOCARE, cu șanse egale:
##   SENS       — „Sinonimul lui «rapid»?", „Antonimul lui «efemer»?"
##   DEFINITIE  — „Ce înseamnă «efemer»?" și forma inversă, de la definiție
##                înapoi la cuvânt
##   ANALOGIE   — „RAPID : IUTE :: VESEL : ?" — cuvântul lipsă. Aici nu ți se
##                spune ce relație leagă perechea; trebuie s-o deduci din
##                prima jumătate. De asta e altceva decât „Sinonimul lui…",
##                deși folosește aceleași date.
##
## ── DE CE CONTEAZĂ DE UNDE VIN VARIANTELE GREȘITE ─────────────
## Asta e toată diferența dintre un puzzle de vocabular și o loterie.
## Distractorii se aleg din ACEEAȘI CLASĂ GRAMATICALĂ și de la ACELAȘI NIVEL
## ca răspunsul corect. Dacă ai întreba „Sinonimul lui «efemer»?" și ai pune
## alături „vremelnic, masă, a alerga, repede", n-ar mai conta că știi
## cuvântul: trei variante se elimină din formă, nu din sens.
##
## Mai mult: distractorii sunt luați din listele de SINONIME ale cuvintelor
## vecine, nu din câmpul „cuvant" al lor. Pare un amănunt, dar nu e. Dacă
## răspunsul corect ar veni mereu din listele de sinonime, iar greșelile ar fi
## mereu cuvinte-intrare, ai învăța în zece minute că răspunsul e „ăla care nu
## seamănă cu celelalte trei" — și ai răspunde corect fără să știi cuvântul.
## Toate patru variantele trebuie să fie același FEL de lucru.

const CALE_CUVINTE := "res://data/cuvinte.json"

# Clasele gramaticale acceptate. Nu e o listă de decor: ea face ca un „verb"
# scris greșit în JSON („verv") să fie prins la încărcare, nu descoperit
# într-o luptă, sub forma unei întrebări cu patru variante ciudate.
const CLASE := ["substantiv", "verb", "adjectiv"]

# Câte variante are o întrebare. E tot 4, ca la celelalte discipline — baza
# verifică oricum și se plânge dacă primește altceva. Scris ca nume ca să nu
# apară cifra 4 în cinci locuri din generatoare.
const VARIANTE := 4

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de zeci de ori pe luptă; fără `static`, fișierul ar fi
# citit de pe disc de fiecare dată.
static var cuvinte: Array[Dictionary] = []
# „adjectiv|2" -> [toate adjectivele de nivel 2]. Construit o dată, la
# încărcare: FIECARE întrebare are nevoie de gălata ei, ca să scoată de acolo
# și răspunsul, și cele trei greșeli. Fără index, ar însemna un `filter` peste
# toate cele 60 de cuvinte la fiecare distractor.
static var pe_galeata := {}
static var incarcare_incercata := false

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Un tabel, ca la Logică: ca să adaugi un tip nou de provocare scrii o funcție
# și o linie aici.
#
#   „tip"      — familia. ASTA se alege prima, nu tiparul, ca un tip cu două
#                tipare să nu apară de două ori mai des decât unul cu unul.
#   „categorie"— ce scrie în antet. Spune ce fel de provocare e, nu răspunsul.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# LIPSEȘTE „niveluri", și nu din uitare. La Logică, nivelul era o însușire a
# GENERATORULUI: „Fibonacci" e greu prin construcție, indiferent de numerele
# alese. Aici dificultatea nu stă în tipar, ci în CUVÂNT: „Sinonimul lui
# «vesel»?" și „Sinonimul lui «caduc»?" sunt același tipar și două lumi
# diferite. Deci nivelul se aplică la alegerea cuvântului, iar fiecare tipar
# merge la toate trei.
#
# Fiecare metodă primește nivelul și întoarce un Dictionary cu „text",
# „variante", „corect" și „explicatie" — adică forma cerută de `puzzle.gd`,
# minus „categorie", pe care o adaugă `_compune_intrebare` din tabelul de aici.
# Dictionary GOL = „nu am destule cuvinte pentru asta" (vezi mai jos).
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	{"tip": "SENS", "categorie": "SINONIM", "metoda": "_sinonim"},
	{"tip": "SENS", "categorie": "ANTONIM", "metoda": "_antonim"},

	{"tip": "DEFINITIE", "categorie": "DEFINITIE", "metoda": "_definitia_cuvantului"},
	{"tip": "DEFINITIE", "categorie": "CUVANTUL POTRIVIT", "metoda": "_cuvantul_definitiei"},

	{"tip": "ANALOGIE", "categorie": "CUVANT LIPSA", "metoda": "_analogie_sinonim"},
	{"tip": "ANALOGIE", "categorie": "CUVANT LIPSA", "metoda": "_analogie_antonim"},
]


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește fișierul. Chemată de mai multe ori, face ceva o singură dată.
func _pregateste_datele() -> void:
	incarca_cuvinte()


## A doua: produce o întrebare pentru nivelul cerut.
##
## ALEGEREA E ÎN DOUĂ TREPTE, ca la Logică: întâi tipul, apoi tiparul din el.
## Dacă am trage direct dintre cele șase tipare, fiecare tip cu două tipare ar
## fi la fel de probabil ca altul — noroc că azi toate au două. Dar în ziua în
## care adaugi al treilea tipar de SENS, el ar deveni pe tăcute cel mai des
## întâlnit tip, iar tu n-ai avea de unde ști de ce jocul „s-a schimbat".
##
## LISTA, nu o singură alegere: `_retete_amestecate()` întoarce TOATE tiparele,
## primul fiind chiar tragerea la sorți în două trepte, iar restul o ordine de
## rezervă. Dacă un tipar nu poate produce nimic (ai șters din JSON tocmai
## antonimele adjectivelor de nivel 3), încercăm următorul în loc să arătăm un
## ecran de eroare. Abia dacă niciunul nu poate, spunem „n-am putut".
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate():
		# `call(nume, nivel)` cheamă o funcție al cărei nume îl știm abia la
		# rulare. Ocolul e necesar: o funcție nu poate sta într-un `const`.
		var intrebare: Dictionary = call(reteta["metoda"], nivel)
		if not intrebare.is_empty():
			intrebare["categorie"] = reteta["categorie"]
			return intrebare
	return {}


## Ce fișier să cauți dacă ecranul de eroare apare vreodată în luptă.
func _descriere_sursa() -> String:
	return CALE_CUVINTE


## Tiparele, în ordinea în care merită încercate.
## Primul element E tragerea la sorți în două trepte: un tip la întâmplare,
## un tipar la întâmplare din el. Ce urmează după e doar plasa de siguranță,
## amestecată și ea ca să nu existe un „tipar de rezervă preferat".
func _retete_amestecate() -> Array:
	var pe_tip := {}
	for generator in GENERATOARE:
		var tip: String = generator["tip"]
		if not pe_tip.has(tip):
			pe_tip[tip] = []
		pe_tip[tip].append(generator)

	var tipuri: Array = pe_tip.keys()
	tipuri.shuffle()

	var ordine: Array = []
	for tip in tipuri:
		var tipare: Array = pe_tip[tip].duplicate()
		tipare.shuffle()
		ordine.append_array(tipare)
	return ordine


# ─────────────────────────────────────────────────────────────
# TIPUL 1 — SENS: sinonim și antonim
# ─────────────────────────────────────────────────────────────

## „Sinonimul lui «rapid»?" → iute
func _sinonim(nivel: int) -> Dictionary:
	return _intrebare_de_sens(nivel, "sinonime", "Sinonimul lui")


## „Antonimul lui «efemer»?" → veșnic
func _antonim(nivel: int) -> Dictionary:
	return _intrebare_de_sens(nivel, "antonime", "Antonimul lui")


## Amândouă de mai sus, cu un singur trup: diferă doar LISTA din care iese
## răspunsul corect. Când două funcții se deosebesc printr-un cuvânt, cuvântul
## ăla devine parametru — altfel a doua copie o ia încet pe altă cale.
func _intrebare_de_sens(nivel: int, lista: String, formula: String) -> Dictionary:
	var tinta := _alege_cuvant(nivel, lista)
	if tinta.is_empty():
		return {}

	var corect := String(tinta[lista].pick_random())
	var gresite := _distractori(tinta, VARIANTE - 1)
	if gresite.size() < VARIANTE - 1:
		return {}   # gălata e prea săracă; `_compune_intrebare` încearcă alt tipar

	var variante: Array[String] = [corect]
	variante.append_array(gresite)
	variante.shuffle()

	return {
		"text": "%s «%s»?" % [formula, tinta["cuvant"]],
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": "«%s» = %s" % [tinta["cuvant"], tinta["definitie"]],
	}


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — DEFINIȚIA, în ambele sensuri
#
# Aceleași date, două direcții de gândire. De la cuvânt la sens e RECUNOAȘTERE
# (ți se arată cuvântul și cauți înțelesul); de la sens la cuvânt e EVOCARE
# (ai înțelesul în cap și cauți numele lui). A doua e măsurabil mai grea, și
# de-aia merită să existe amândouă.
# ─────────────────────────────────────────────────────────────

## „Ce înseamnă «efemer»?" → variantele sunt DEFINIȚII.
func _definitia_cuvantului(nivel: int) -> Dictionary:
	var tinta := _alege_cuvant(nivel, "")
	if tinta.is_empty():
		return {}

	var corect := String(tinta["definitie"])
	var gresite := _campuri_straine(tinta, VARIANTE - 1, "definitie")
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [corect]
	variante.append_array(gresite)
	variante.shuffle()

	return {
		"text": "Ce înseamnă «%s»?" % tinta["cuvant"],
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": "SINONIME: %s" % ", ".join(tinta["sinonime"]),
	}


## „Care cuvânt înseamnă «care ține foarte puțin»?" → variantele sunt CUVINTE.
func _cuvantul_definitiei(nivel: int) -> Dictionary:
	var tinta := _alege_cuvant(nivel, "")
	if tinta.is_empty():
		return {}

	var corect := String(tinta["cuvant"])
	var gresite := _campuri_straine(tinta, VARIANTE - 1, "cuvant")
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [corect]
	variante.append_array(gresite)
	variante.shuffle()

	return {
		"text": "Care cuvânt înseamnă\n«%s»?" % tinta["definitie"],
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": "SINONIME: %s" % ", ".join(tinta["sinonime"]),
	}


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — CUVÂNTUL LIPSĂ (analogie)
#
# Forma e cea de la Logică — „A : B :: C : ?", scrisă pe două rânduri, cu
# majuscule. Nu din comoditate: analogia e o DIAGRAMĂ, nu o propoziție, iar
# ochiul o citește mai repede dacă arată la fel peste tot în joc. O disciplină
# care inventează altă formă pentru același gest de gândire îți cere s-o
# înveți a doua oară degeaba.
#
# Diferența față de „Sinonimul lui X?": aici NU ți se spune ce relație e.
# Perechea-model e singurul loc de unde o poți afla.
# ─────────────────────────────────────────────────────────────

## „RAPID : IUTE :: VESEL : ?" — relația e sinonimia.
func _analogie_sinonim(nivel: int) -> Dictionary:
	return _analogie(nivel, "sinonime", "AMANDOUA PERECHILE SUNT SINONIME")


## „RAPID : LENT :: VESEL : ?" — relația e opoziția.
func _analogie_antonim(nivel: int) -> Dictionary:
	return _analogie(nivel, "antonime", "AMANDOUA PERECHILE SUNT ANTONIME")


func _analogie(nivel: int, lista: String, explicatie_regula: String) -> Dictionary:
	# Amândouă cuvintele (modelul și ținta) trebuie să fie din ACEEAȘI gălata:
	# aceeași clasă, același nivel. O analogie „substantiv : substantiv ::
	# verb : ?" ar fi cerut jucătorului să sară peste o treaptă pe care n-o
	# anunță nimeni.
	var doua := _doua_cuvinte(nivel, lista)
	if doua.is_empty():
		return {}
	var model: Dictionary = doua[0]
	var tinta: Dictionary = doua[1]

	# Perechea-model se alege ÎNAINTE de orice altceva, nu în dicționarul de la
	# final. Motivul e de ordine, nu de stil: cuvintele astea ajung pe ecran,
	# în enunț, iar ca să le poți interzice printre variante trebuie să le
	# știi deja.
	var pereche_model := String(model[lista].pick_random())

	# TOT ce se vede în enunț. Nimic de aici n-are voie să ajungă buton — și
	# asta include RĂSPUNSUL, nu doar greșelile.
	#
	# Cazul care a impus regula, găsit rulând generatorul de 6000 de ori:
	# „SFIALĂ : OBRĂZNICIE :: ÎNDRĂZNEALĂ : ?". Sfiala și îndrăzneala sunt
	# antonime una alteia, deci răspunsul corect pentru îndrăzneală era chiar
	# «sfială» — scris deja, cu majuscule, în colțul din stânga sus. Datele nu
	# sunt greșite; generatorul trebuie să știe să ocolească oglinda.
	var pe_ecran: Array = [
		String(model["cuvant"]), pereche_model, String(tinta["cuvant"]),
	]

	var raspunsuri: Array = tinta[lista].filter(func(c): return not (String(c) in pe_ecran))
	if raspunsuri.is_empty():
		return {}   # perechea asta se oglindește complet; `_compune_intrebare` reîncearcă
	var corect := String(raspunsuri.pick_random())

	# Modelul iese din lista de distractori cu totul: cuvintele lui sunt deja
	# pe ecran, iar o variantă luată din familia lui s-ar citi ca o capcană
	# despre partea stângă, când întrebarea e despre cea dreaptă.
	var gresite := _distractori(tinta, VARIANTE - 1, [model], pe_ecran)
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [corect.to_upper()]
	for gresita in gresite:
		variante.append(gresita.to_upper())
	variante.shuffle()

	return {
		"text": "%s : %s\n\n%s : ?" % [
			String(model["cuvant"]).to_upper(),
			pereche_model.to_upper(),
			String(tinta["cuvant"]).to_upper(),
		],
		"variante": variante,
		"corect": variante.find(corect.to_upper()),
		"explicatie": explicatie_regula,
	}


# ─────────────────────────────────────────────────────────────
# ALEGEREA CUVINTELOR
# Niciun cuvânt nu apare în codul de mai jos: adaugi o intrare în JSON și
# intră singură în rotație, atât ca răspuns, cât și ca distractor.
# ─────────────────────────────────────────────────────────────

## Cheia gălății. Clasa și nivelul, lipite: „adjectiv|2".
static func _cheie(clasa: String, nivel: int) -> String:
	return "%s|%d" % [clasa, nivel]


## Toate cuvintele de aceeași clasă și același nivel cu `cuvant`.
## Aici se nasc distractorii, deci gălata E regula „nu răspunsuri la nimereală".
static func _galeata_lui(cuvant: Dictionary) -> Array:
	return pe_galeata.get(_cheie(cuvant["clasa"], cuvant["nivel"]), [])


## Un cuvânt de nivelul cerut, bun de întrebat.
## `lista` = ce trebuie să aibă („sinonime", „antonime"); gol = orice cuvânt.
##
## Condiția a doua e la fel de importantă ca prima: gălata lui trebuie să aibă
## destui vecini pentru trei distractori. Un cuvânt rămas singur în clasa și
## nivelul lui nu poate produce o întrebare cinstită, deci nu e ales deloc.
func _alege_cuvant(nivel: int, lista: String) -> Dictionary:
	var pool: Array = cuvinte.filter(func(c):
		if c["nivel"] != nivel:
			return false
		if lista != "" and c[lista].is_empty():
			return false
		return _galeata_lui(c).size() >= VARIANTE
	)
	if pool.is_empty():
		return {}
	return pool.pick_random()


## Două cuvinte DIFERITE din aceeași gălata, amândouă cu lista cerută plină.
## Primul e modelul analogiei, al doilea e ținta.
func _doua_cuvinte(nivel: int, lista: String) -> Array:
	var tinta := _alege_cuvant(nivel, lista)
	if tinta.is_empty():
		return []

	var vecini: Array = _galeata_lui(tinta).filter(func(c):
		return c["cuvant"] != tinta["cuvant"] and not c[lista].is_empty()
	)
	if vecini.is_empty():
		return []
	return [vecini.pick_random(), tinta]


## TREI VARIANTE GREȘITE, și toată valoarea disciplinei stă în ele.
##
## De unde vin: din listele de SINONIME ale cuvintelor vecine — aceeași clasă
## gramaticală, același nivel. Vezi antetul fișierului pentru de ce nu din
## câmpul „cuvant" al lor.
##
## CE NU AU VOIE SĂ FIE: sinonime sau antonime ale țintei. Un distractor care
## e de fapt un al doilea răspuns corect nu e o greșeală de echilibru, e o
## întrebare stricată — răspunzi bine și jocul îți spune că ai greșit. De asta
## excludem AMÂNDOUĂ listele, nu doar cea din care iese răspunsul: la „Sinonimul
## lui «trainic»?" un „trecător" scos din familia lui «efemer» ar fi antonim, nu
## sinonim, dar tot ar trage ochiul într-acolo din motivul greșit.
##
## UN SINGUR cuvânt de la fiecare vecin (de-aia `break`-ul din bucla mică):
## două variante din aceeași familie ar arăta amândouă la fel de bune și ar
## reduce întrebarea la o alegere între două, nu între patru.
##
## Cei doi parametri de la coadă sunt amândoi despre „ce e deja pe ecran":
##   `excluse`          — intrări întregi de sărit (analogia sare peste model)
##   `cuvinte_interzise`— cuvinte anume, oriunde s-ar afla. Analogia trimite
##                        aici tot ce se vede deja în enunț: un cuvânt care
##                        apare și sus, și printre butoane se citește ca un
##                        indiciu, nu ca o greșeală.
func _distractori(tinta: Dictionary, cati: int, excluse := [], cuvinte_interzise := []) -> Array[String]:
	var interzise: Array = [tinta["cuvant"]]
	interzise.append_array(tinta["sinonime"])
	interzise.append_array(tinta["antonime"])
	interzise.append_array(cuvinte_interzise)

	var nume_excluse: Array = [tinta["cuvant"]]
	for exclus in excluse:
		nume_excluse.append(exclus["cuvant"])

	var vecini: Array = _galeata_lui(tinta).duplicate()
	vecini.shuffle()

	var alesi: Array[String] = []
	for vecin in vecini:
		if alesi.size() == cati:
			break
		if vecin["cuvant"] in nume_excluse:
			continue
		var candidati: Array = vecin["sinonime"].duplicate()
		candidati.shuffle()
		for candidat in candidati:
			if candidat in interzise or candidat in alesi:
				continue
			alesi.append(String(candidat))
			break
	return alesi


## Distractori pentru întrebările de definiție: același câmp, luat de la
## vecini. „definitie" când variantele sunt definiții, „cuvant" când sunt
## cuvinte. Aceeași gălata ca mai sus, din același motiv — patru definiții de
## adjectiv se citesc la fel („care..."), pe când o definiție de verb printre
## ele s-ar elimina singură, din formă.
func _campuri_straine(tinta: Dictionary, cati: int, camp: String) -> Array[String]:
	var vecini: Array = _galeata_lui(tinta).duplicate()
	vecini.shuffle()

	var alesi: Array[String] = []
	for vecin in vecini:
		if alesi.size() == cati:
			break
		if vecin["cuvant"] == tinta["cuvant"]:
			continue
		# Un vecin care e chiar sinonimul țintei ar da două răspunsuri bune la
		# „Care cuvânt înseamnă…". Rar, dar exact genul de rar care apare în
		# luptă, nu în teste.
		if vecin["cuvant"] in tinta["sinonime"]:
			continue
		var valoare := String(vecin[camp])
		if not (valoare in alesi):
			alesi.append(valoare)
	return alesi


# ─────────────────────────────────────────────────────────────
# ÎNCĂRCAREA DATELOR
#
# Godot nu poate verifica nimic dintr-un JSON la compilare: un fișier stricat
# se vede abia la rulare. De aceea încărcătorul VALIDEAZĂ fiecare intrare și
# sare peste cele stricate, cu un avertisment în consolă, în loc să crape
# lupta la mijloc. Un cuvânt greșit costă un cuvânt, nu o luptă.
# ─────────────────────────────────────────────────────────────

## Sigur de chemat de oricâte ori: după prima încercare nu mai face nimic.
static func incarca_cuvinte() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	for intrare in Puzzle.citeste_lista_json(CALE_CUVINTE, "Cuvinte"):
		if _cuvant_valid(intrare, cuvinte.size()):
			# Capcana clasică a JSON-ului: nu are numere întregi, doar zecimale.
			# „nivel": 2 ajunge în Godot ca 2.0 (float). Convertim o dată, aici.
			intrare["nivel"] = int(intrare["nivel"])
			cuvinte.append(intrare)

	_indexeaza_galetile()
	_verifica_coliziuni()

	print("Cuvinte: %d cuvinte in %d galeti." % [cuvinte.size(), pe_galeata.size()])


static func _cuvant_valid(c, i: int) -> bool:
	var unde := "cuvantul %d" % i
	var chei := ["cuvant", "clasa", "nivel", "domeniu", "definitie", "sinonime", "antonime"]
	if not Puzzle.are_campurile(c, chei, "Cuvinte", unde):
		return false

	if not (c["clasa"] in CLASE):
		push_warning("Cuvinte: '%s' are clasa necunoscuta '%s'. Asteptam: %s." % [
			c["cuvant"], c["clasa"], ", ".join(CLASE)
		])
		return false

	var nivel := int(c["nivel"])
	if nivel < 1 or nivel > Puzzle.TIMP_PE_NIVEL.size():
		push_warning("Cuvinte: '%s' are nivelul %d, in afara intervalului 1-3." % [c["cuvant"], nivel])
		return false

	if not (c["sinonime"] is Array) or not (c["antonime"] is Array):
		push_warning("Cuvinte: '%s' are 'sinonime' sau 'antonime' care nu sunt liste." % c["cuvant"])
		return false

	# Sinonimele sunt OBLIGATORII, antonimele nu. Motivul e practic: lista de
	# sinonime e și sursa distractorilor pentru vecini, deci un cuvânt fără ea
	# ar ocupa un loc în gălata fără să contribuie cu nimic. Antonime au voie
	# să lipsească — „drum" n-are opus, și e în regulă: tiparele de antonim
	# pur și simplu nu-l aleg.
	if c["sinonime"].is_empty():
		push_warning("Cuvinte: '%s' nu are niciun sinonim." % c["cuvant"])
		return false

	return true


## „adjectiv|2" -> [toate adjectivele de nivel 2].
## Avertizează pentru gălețile prea sărace: un cuvânt din patru nu poate
## produce o întrebare cinstită, deci n-ar apărea niciodată — iar tu ai crede
## că l-ai scris degeaba fără să afli de ce.
static func _indexeaza_galetile() -> void:
	pe_galeata.clear()
	for cuvant in cuvinte:
		var cheie := _cheie(cuvant["clasa"], cuvant["nivel"])
		if not pe_galeata.has(cheie):
			pe_galeata[cheie] = []
		pe_galeata[cheie].append(cuvant)

	for cheie in pe_galeata:
		if pe_galeata[cheie].size() < VARIANTE:
			push_warning("Cuvinte: galeata '%s' are doar %d cuvinte (minimum %d). Nu va aparea in joc." % [
				cheie, pe_galeata[cheie].size(), VARIANTE
			])


## REGULA DE AUR a disciplinei, verificată la încărcare: în aceeași gălata,
## un cuvânt n-are voie să fie sinonimul a două intrări diferite.
##
## Dacă „iute" e trecut și la „rapid", și la „sprinten", atunci la întrebarea
## „Sinonimul lui «rapid»?" el poate ajunge distractor scos din familia lui
## «sprinten» — adică un al doilea răspuns corect, pe care jocul îl va marca
## roșu. Nu e un bug de cod, e o problemă de date, și aici afli exact unde.
##
## (Garda de la generare — `_distractori` sare peste orice e în listele
## țintei — prinde oricum cazul. Avertismentul e ca să ȘTII, fiindcă o listă
## de sinonime care se repetă e, de obicei, semn că voiai altceva acolo.)
static func _verifica_coliziuni() -> void:
	for cheie in pe_galeata:
		var vazut := {}   # sinonim -> cuvântul în lista căruia a apărut întâi
		for cuvant in pe_galeata[cheie]:
			for sinonim in cuvant["sinonime"]:
				if vazut.has(sinonim):
					push_warning("Cuvinte: '%s' e sinonim si la '%s', si la '%s' (%s)." % [
						sinonim, vazut[sinonim], cuvant["cuvant"], cheie
					])
				else:
					vazut[sinonim] = cuvant["cuvant"]

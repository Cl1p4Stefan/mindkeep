extends Puzzle
## Disciplina LOGICĂ.
##
## Tot ce ține de cronometru, butoane, culori, sunete și contractul cu lupta
## trăiește în `puzzle.gd`. Fișierul ăsta răspunde la o singură întrebare:
## DE UNDE VINE ÎNTREBAREA.
##
## DE UNDE VIN ÎNTREBĂRILE. Sunt două feluri de tipuri, și fiecare își ia
## materia primă de unde îi e mai ieftin:
##
##   PUR GENERATIVE (deducțiile, enigmele, calendarul) — nu au nevoie de niciun
##   fișier. Regula E conținutul: „cine stă la stânga lui Anton" produce o
##   infinitate de întrebări din patru nume amestecate. Un fișier de date aici
##   ar fi fost muncă de scris pentru zero câștig.
##
##   ALIMENTATE CU DATE (analogiile, intrusul, silogismele, logica
##   propozițională, numărătorile) — au nevoie de cunoștințe despre lume sau de
##   forme gramaticale, iar nici una, nici alta nu se pot deduce. Ele citesc din
##   `data/logica_categorii.json` și `data/logica_vocabular.json`.
##
## Regula pentru fișiere: ca să adaugi conținut, editezi DOAR JSON-ul. Codul
## de mai jos nu conține niciun nume de categorie și niciun cuvânt din
## vocabular — lucrează pe ce găsește.
##
## CELE PATRUSPREZECE TIPURI, pe familii (vezi tabelul `GENERATOARE`):
##
##   SEMNIFICAȚII — INTRUS, ANALOGIE. Două din cele trei tipuri de la care a
##     pornit disciplina. Al treilea era SIR (șirurile numerice), și de pe
##     1 noiembrie 2026 nu mai e aici: a plecat la TIPARE, disciplina a cincea.
##     Nu era o curățenie, era pasul 2 din ruta de construcție — pitch-ul o
##     ceruse de la început („altfel același conținut apare în două
##     Obeliscuri"), iar cu Logica și Tipare în același loadout chiar așa s-ar
##     fi întâmplat. Logica a scăzut de la 15 tipuri la 14 și de la 56 de
##     tipare la 47, și n-a pierdut nimic: șirurile nu cereau nici vocabular,
##     nici categorii, deci erau singurul tip din disciplină care n-avea nicio
##     legătură cu restul ei.
##   LOGICĂ PROPOZIȚIONALĂ — SILOGISM, CONDITIONAL, NEGATIE, CONECTORI,
##     PREMISA. Propoziții asamblate din vocabular, rezolvate din FORMĂ.
##   ENIGME — MINCINOSI. Cine spune adevărul, dedus prin forță brută.
##   NUMĂRĂTOARE — MULTIMI, CERTITUDINE, CALENDAR. Cifre mici, raționament
##     mare: reuniuni, cel mai rău caz, roata săptămânii.
##   CONSTRÂNGERI — DEDUCTIE, ASEZARE, POTRIVIRE. Indicii din care se
##     reconstruiește o ordine sau o împerechere.
##
## DE CE ATÂT DE MULTE TIPURI, ȘI DE CE AICI. E calea scrisă în pitch
## (secțiunea „de ce rămânem la 4 discipline"): „varietate ÎN interiorul celor
## 4 — formate multiple de Logică — costă mult mai puțin decât o disciplină
## complet nouă și rezolvă aceeași problemă". Un tip nou e o funcție și un rând
## în tabel; o disciplină nouă e o scenă, un Obelisc, o statistică și o clădire.

# ─────────────────────────────────────────────────────────────
# FIȘIERELE DE DATE
#
# CE TREBUIE SĂ ȘTII CÂND ADAUGI O CATEGORIE în logica_categorii.json:
#
#   { "domeniu": "natura", "nume": "feline", "relatie": "sunt feline",
#     "membri": ["leu", "tigru", "ghepard", "ras", "jaguar", "puma"] }
#
#   • „domeniu" — familia din care face parte categoria. E câmpul care face
#     diferența dintre o întrebare bună și una de decor: analogiile și intrusul
#     își aleg TOATE categoriile din același domeniu, deci variantele greșite
#     sunt înrudite cu răspunsul. Fără el, „leu, tigru, ghepard, ciment" — și
#     nimeni n-are nevoie să gândească. Un domeniu are nevoie de minimum 2
#     categorii ca să fie folosit, și de 5 ca distractorii să vină tot din el.
#   • „nume" — cum se cheamă grupul. Apare în feedback, după răspuns.
#   • „relatie" — ce îi leagă, scris ca o propoziție care continuă „Ceilalți...".
#     Tot în feedback: de asta afli DE CE era greșit, nu doar CĂ era.
#   • „membri" — minimum 4. Sub atât, „intrusul" n-are din ce alege 3 + 1.
#
#   REGULA DE AUR: categoriile trebuie să fie DISJUNCTE — niciun membru în
#   două categorii. „Intrusul" se bazează pe asta: dacă „găină" ar fi și în
#   „păsări", și în „animale de curte", întrebarea ar avea două răspunsuri
#   bune. Încărcătorul verifică și te avertizează în consolă dacă se întâmplă.
#
# VOCABULARUL pentru silogisme, în logica_vocabular.json, are nevoie de toate
# formele gramaticale, fiindcă propozițiile se asamblează din bucăți:
#
#   { "singular": "pisica", "plural": "pisici",
#     "articulat": "pisicile", "gen": "f", "om": false }
#
#   „Toate PISICILE sunt CORBI." → articulat + plural.  „Nicio PISICĂ nu e
#   CORB." → singular. „gen" alege între Toți/Toate și Niciun/Nicio.
#   Cuvintele n-au nevoie să aibă sens împreună — un silogism se rezolvă din
#   formă, nu din adevărul lumii. „Toate stelele sunt corăbii" e o premisă
#   perfect bună, și chiar mai bună: te împiedică să răspunzi din memorie.
#
#   „om" E SINGURUL CÂMP CARE CERE SENS, și de-aia există. MULȚIMILE și
#   CERTITUDINEA nu sunt silogisme: ele povestesc ceva („în cetate sunt 12
#   cavaleri și 9 santinele"), iar o poveste cu stele amestecate printre cărți
#   nu se mai citește ca o poveste, se citește ca o greșeală de generator.
#   Steagul e OPȚIONAL — lipsa lui înseamnă `false`, deci un cuvânt nou intră
#   la silogisme fără să fi hotărât nimic despre el. Rândul tipărit la încărcare
#   spune câți oameni s-au găsit, ca o listă fără niciunul să nu treacă în
#   tăcere.
# ─────────────────────────────────────────────────────────────
const CALE_CATEGORII := "res://data/logica_categorii.json"
const CALE_VOCABULAR := "res://data/logica_vocabular.json"

const MINIM_MEMBRI := 4

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de zeci de ori pe luptă; fără `static`, fișierele ar fi
# citite de pe disc de fiecare dată.
static var categorii: Array[Dictionary] = []
static var vocabular: Array[Dictionary] = []
# Doar cuvintele cu „om": true. Mulțimile și certitudinea POVESTESC ceva, iar o
# poveste despre 12 stele și 9 cărți nu se citește ca o poveste.
static var oameni: Array[Dictionary] = []
# Doar cuvintele masculine. Tiparele cu UN personaj („Luca e cronicar") au nevoie
# de ele, fiindcă toate numele din `NUME` sunt masculine — vezi
# `_cuvinte_masculine` pentru de ce acordul conteaza aici și nu la silogisme.
static var masculine: Array[Dictionary] = []
# „natura" -> [categoria feline, categoria canide, ...]. Construit o dată, la
# încărcare: analogiile și intrusul îl interoghează de zeci de ori pe luptă.
static var pe_domeniu := {}
static var incarcare_incercata := false

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Un tabel, ca OBELISCURI din luptă: ca să adaugi un tip nou de întrebare
# scrii o funcție și o linie aici. Restul scenei (cronometru, butoane,
# feedback) nu se atinge, fiindcă nu știe ce fel de întrebare a primit.
#
#   „tip"      — familia de puzzle. ASTA se alege prima, nu tiparul: altfel
#                un tip cu 5 tipare ar apărea de 5 ori mai des decât unul cu
#                unul singur, și ai juca aproape numai logică propozițională.
#   „niveluri" — la ce dificultăți poate apărea. Un tipar poate fi bun la mai
#                multe: intrusul greu merge și la II, și la III.
#   „metoda"   — NUMELE funcției, ca text. `call(nume)` o cheamă după nume.
#                Ocolul e necesar: o funcție nu poate sta într-un `const`.
#   „categorie"— ce scrie în antet ÎNAINTE de răspuns. Spune ce fel de puzzle
#                e, nu care e regula — altfel ar da rezolvarea.
#   „necesita" — ce fișier îi trebuie. Gol = nimic. Dacă fișierul lipsește sau
#                e stricat, tipul ăsta pur și simplu nu e ales, iar jocul merge
#                mai departe cu cele care nu au nevoie de date.
#
# Fiecare metodă întoarce un Dictionary cu „text", „variante", „corect" și
# „explicatie" — adică exact forma cerută de `puzzle.gd`, minus „categorie",
# pe care o adaugă `_compune_intrebare` din tabelul de aici.
#
# ECHILIBRUL. Fiecare TIP trebuie să existe la toate cele trei niveluri, altfel
# la nivelul unde lipsește ceilalți se împart între ei toată probabilitatea.
# Când adaugi un tip nou, dă-i cel puțin un tipar pe fiecare nivel.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# INTRUSUL — dificultatea stă în cât de aproape e străinul de grup.
	{"tip": "INTRUS", "niveluri": [1], "categorie": "INTRUSUL", "necesita": "categorii", "metoda": "_intrus_din_alt_domeniu"},
	{"tip": "INTRUS", "niveluri": [2, 3], "categorie": "INTRUSUL", "necesita": "categorii", "metoda": "_intrus_din_acelasi_domeniu"},

	# ANALOGII — două forme: membru-la-membru și membru-la-categorie.
	{"tip": "ANALOGIE", "niveluri": [1], "categorie": "ANALOGIE", "necesita": "categorii", "metoda": "_analogie_larga"},
	{"tip": "ANALOGIE", "niveluri": [2, 3], "categorie": "ANALOGIE", "necesita": "categorii", "metoda": "_analogie_stransa"},
	{"tip": "ANALOGIE", "niveluri": [2, 3], "categorie": "ANALOGIE", "necesita": "categorii", "metoda": "_analogie_de_categorie"},

	# SILOGISME — trei scheme clasice, în ordinea dificultății.
	{"tip": "SILOGISM", "niveluri": [1], "categorie": "SILOGISM", "necesita": "vocabular", "metoda": "_silogism_barbara"},
	{"tip": "SILOGISM", "niveluri": [2], "categorie": "SILOGISM", "necesita": "vocabular", "metoda": "_silogism_celarent"},
	{"tip": "SILOGISM", "niveluri": [3], "categorie": "SILOGISM", "necesita": "vocabular", "metoda": "_silogism_darii"},

	# DEDUCȚII DE ORDONARE — pur generative, ca și enigmele.
	{"tip": "DEDUCTIE", "niveluri": [1], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_in_ordine"},
	{"tip": "DEDUCTIE", "niveluri": [2], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_amestecata"},
	{"tip": "DEDUCTIE", "niveluri": [3], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_lunga"},

	# ═══ CELE ZECE TIPURI DE PE 1 NOIEMBRIE 2026 ═══════════════
	# De la 5 tipuri la 15. Fiecare are, ca și cele de dinainte, cel puțin un
	# tipar pe FIECARE nivel — altfel la nivelul unde lipsește ceilalți s-ar
	# împărți între ei toată probabilitatea.

	# DACĂ-ATUNCI — implicația, în formele care se confundă între ele. Cele două
	# capcane clasice (afirmarea consecventului, negarea antecedentului) stau la
	# nivelul III, unde răspunsul bun e că NU rezultă nimic.
	{"tip": "CONDITIONAL", "niveluri": [1], "categorie": "DACA-ATUNCI", "necesita": "masculine", "metoda": "_modus_ponens"},
	{"tip": "CONDITIONAL", "niveluri": [2], "categorie": "DACA-ATUNCI", "necesita": "masculine", "metoda": "_modus_tollens"},
	{"tip": "CONDITIONAL", "niveluri": [2, 3], "categorie": "DACA-ATUNCI", "necesita": "masculine", "metoda": "_contrapozitiva"},
	{"tip": "CONDITIONAL", "niveluri": [3], "categorie": "DACA-ATUNCI", "necesita": "masculine", "metoda": "_conditional_nehotarat"},

	# NEGAȚIA — ce spune EXACT contrariul unei afirmații. Greșeala pe care o
	# vânează: „toți" nu se neagă cu „niciunul", se neagă cu „unii nu".
	{"tip": "NEGATIE", "niveluri": [1], "categorie": "NEGATIA", "necesita": "vocabular", "metoda": "_negatie_toti"},
	{"tip": "NEGATIE", "niveluri": [2], "categorie": "NEGATIA", "necesita": "vocabular", "metoda": "_negatie_niciun"},
	{"tip": "NEGATIE", "niveluri": [2], "categorie": "NEGATIA", "necesita": "vocabular", "metoda": "_negatie_unii"},
	{"tip": "NEGATIE", "niveluri": [3], "categorie": "NEGATIA", "necesita": "masculine", "metoda": "_negatie_conditional"},

	# ȘI / SAU — conectorii, plus cele două legi ale lui De Morgan la nivelul III.
	{"tip": "CONECTORI", "niveluri": [1], "categorie": "SI / SAU", "necesita": "masculine", "metoda": "_conector_sau"},
	{"tip": "CONECTORI", "niveluri": [2], "categorie": "SI / SAU", "necesita": "masculine", "metoda": "_conector_si_fals"},
	{"tip": "CONECTORI", "niveluri": [3], "categorie": "SI / SAU", "necesita": "masculine", "metoda": "_de_morgan_sau"},
	{"tip": "CONECTORI", "niveluri": [3], "categorie": "SI / SAU", "necesita": "masculine", "metoda": "_de_morgan_si"},

	# PREMISA LIPSĂ — nu tragi concluzia, o repari. Alt mușchi decât silogismul:
	# acolo ți se dau toate premisele, aici ți se ia una.
	{"tip": "PREMISA", "niveluri": [1], "categorie": "PREMISA LIPSA", "necesita": "vocabular", "metoda": "_premisa_mijloc"},
	{"tip": "PREMISA", "niveluri": [2], "categorie": "PREMISA LIPSA", "necesita": "vocabular", "metoda": "_premisa_negativa"},
	{"tip": "PREMISA", "niveluri": [2, 3], "categorie": "PREMISA LIPSA", "necesita": "masculine", "metoda": "_premisa_lant"},
	{"tip": "PREMISA", "niveluri": [3], "categorie": "PREMISA LIPSA", "necesita": "vocabular", "metoda": "_premisa_prima"},

	# ADEVĂR ȘI MINCIUNĂ — cavalerii spun adevărul, mincinoșii mint. Singurul tip
	# care nu construiește răspunsul, ci îl CAUTĂ: indiciile se trag la
	# întâmplare, iar enigma e păstrată doar dacă are exact o soluție.
	{"tip": "MINCINOSI", "niveluri": [1], "categorie": "ADEVAR SI MINCIUNA", "necesita": "", "metoda": "_mincinosi_doi"},
	{"tip": "MINCINOSI", "niveluri": [2], "categorie": "ADEVAR SI MINCIUNA", "necesita": "", "metoda": "_mincinosi_trei"},
	{"tip": "MINCINOSI", "niveluri": [3], "categorie": "ADEVAR SI MINCIUNA", "necesita": "", "metoda": "_mincinosi_numar"},

	# MULȚIMI — reuniune, intersecție, „numai una", „niciuna". Aritmetica e de
	# clasa a doua; greul e să vezi CE se adună și ce se scade de două ori.
	{"tip": "MULTIMI", "niveluri": [1], "categorie": "MULTIMI", "necesita": "oameni", "metoda": "_multimi_reuniune"},
	{"tip": "MULTIMI", "niveluri": [2], "categorie": "MULTIMI", "necesita": "oameni", "metoda": "_multimi_intersectie"},
	{"tip": "MULTIMI", "niveluri": [3], "categorie": "MULTIMI", "necesita": "oameni", "metoda": "_multimi_doar_unul"},
	{"tip": "MULTIMI", "niveluri": [3], "categorie": "MULTIMI", "necesita": "oameni", "metoda": "_multimi_niciuna"},

	# CEL MAI RĂU CAZ — principiul sertarelor. Întrebarea nu e „câte ai șanse să
	# scoți", e „câte trebuie ca să NU mai depinzi de noroc".
	{"tip": "CERTITUDINE", "niveluri": [1], "categorie": "CEL MAI RAU CAZ", "necesita": "oameni", "metoda": "_certitudine_unul"},
	{"tip": "CERTITUDINE", "niveluri": [2], "categorie": "CEL MAI RAU CAZ", "necesita": "oameni", "metoda": "_certitudine_trei_grupe"},
	{"tip": "CERTITUDINE", "niveluri": [2, 3], "categorie": "CEL MAI RAU CAZ", "necesita": "oameni", "metoda": "_certitudine_doi"},
	{"tip": "CERTITUDINE", "niveluri": [3], "categorie": "CEL MAI RAU CAZ", "necesita": "oameni", "metoda": "_certitudine_din_fiecare"},

	# CALENDAR — roata săptămânii. Deducție CICLICĂ: singurul tip în care
	# greșeala tipică nu e un pas în plus, ci un pas în direcția greșită.
	{"tip": "CALENDAR", "niveluri": [1], "categorie": "CALENDAR", "necesita": "", "metoda": "_calendar_aproape"},
	{"tip": "CALENDAR", "niveluri": [2], "categorie": "CALENDAR", "necesita": "", "metoda": "_calendar_departe"},
	{"tip": "CALENDAR", "niveluri": [3], "categorie": "CALENDAR", "necesita": "", "metoda": "_calendar_inapoi"},

	# LOCURILE — cine stă pe al câtelea loc. Rudă cu ORDONARE, dar altă unealtă:
	# acolo lanțul de comparații determină singur ordinea, aici indiciile sunt
	# capete, vecinătăți și „nu lângă", deci se rezolvă prin ELIMINARE.
	{"tip": "ASEZARE", "niveluri": [1], "categorie": "LOCURILE", "necesita": "", "metoda": "_asezare_simpla"},
	{"tip": "ASEZARE", "niveluri": [2], "categorie": "LOCURILE", "necesita": "", "metoda": "_asezare_grea"},
	{"tip": "ASEZARE", "niveluri": [3], "categorie": "LOCURILE", "necesita": "", "metoda": "_asezare_cinci"},

	# POTRIVIRE — cine are ce. Grila clasică de logică, la scara la care încape
	# pe un ecran: trei sau patru oameni, atâtea lucruri, câteva indicii negative.
	{"tip": "POTRIVIRE", "niveluri": [1], "categorie": "POTRIVIRE", "necesita": "", "metoda": "_potrivire_trei"},
	{"tip": "POTRIVIRE", "niveluri": [2], "categorie": "POTRIVIRE", "necesita": "", "metoda": "_potrivire_patru"},
	{"tip": "POTRIVIRE", "niveluri": [3], "categorie": "POTRIVIRE", "necesita": "", "metoda": "_potrivire_cine"},
]


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește fișierele. Chemată de mai multe ori, face ceva o singură dată.
func _pregateste_datele() -> void:
	incarca_date()


## A doua: produce o întrebare pentru nivelul cerut.
## Aici se leagă cele două jumătăți: tabelul spune CE fel de întrebare urmează
## (și ce scrie în antet), iar funcția numită de el o construiește.
##
## DE CE O BUCLĂ, ȘI NU UN SINGUR APEL. Până la tipurile cu CONSTRÂNGERI,
## fiecare generator reușea întotdeauna: își alegea datele și construia
## răspunsul. Mincinoșii, locurile și potrivirea merg invers — trag indicii la
## întâmplare și apoi CAUTĂ soluțiile. Dacă indiciile nu duc la un răspuns unic,
## singurul lucru cinstit pe care-l pot face e să întoarcă un dicționar gol:
## o întrebare cu două răspunsuri bune e mai rea decât niciuna.
##
## Eșecul lor nu are de ce să te coste întrebarea. Aici se alege pur și simplu
## altă rețetă — iar fiindcă cele mai multe tipuri nu pot da greș, bucla iese
## aproape întotdeauna din prima.
func _compune_intrebare(nivel: int) -> Dictionary:
	for incercare in range(INCERCARI_COMPUNERE):
		var reteta := _alege_reteta(nivel)
		# `call(nume)` cheamă o funcție al cărei nume îl știm abia la rulare.
		# Ocolul e necesar: o funcție nu poate sta într-un `const`.
		var intrebare: Dictionary = call(reteta["metoda"])
		if intrebare.is_empty():
			continue
		# Antetul: ce fel de puzzle e, nu care e regula. „SIR NUMERIC" spune la
		# fel de mult cât spune „ISTORIE" la Trivia — domeniul, nu răspunsul.
		intrebare["categorie"] = reteta["categorie"]
		# TIPUL, din același rând al tabelului. Nu ajunge pe ecran: baza îl ține
		# minte și îl ocolește la treapta următoare a lanțului — vezi „FĂRĂ DOUĂ
		# TREPTE DIN ACELAȘI TIP" din `puzzle.gd`.
		intrebare["tip"] = reteta["tip"]
		return intrebare
	return {}


## Ce fișiere să cauți dacă ecranul de eroare apare vreodată în luptă.
## (Greu de atins: deducțiile, enigmele și calendarul n-au nevoie de niciun
## fișier, deci Logica produce întrebări chiar și cu tot folderul `data/`
## șters.)
func _descriere_sursa() -> String:
	return "%s / %s" % [CALE_CATEGORII, CALE_VOCABULAR]


## Alege ce fel de întrebare urmează. ÎN DOUĂ TREPTE, și asta e tot rostul
## funcției: întâi tragem la sorți TIPUL, apoi un tipar din el.
##
## Dacă am trage direct dintre tipare, tipul cu cele mai multe ar câștiga
## proporțional. Funcția s-a scris pe vremea când existau cinci tipuri, iar
## unul din ele (șirurile numerice, plecate de atunci la Tipare) avea nouă
## tipare contra unui silogism: 90% din întrebări erau șiruri. Așa, cele
## patrusprezece tipuri au aceeași șansă indiferent câte tipare are fiecare,
## iar când mai adaugi un tipar nu strici echilibrul.
func _alege_reteta(nivel: int) -> Dictionary:
	# `filter` păstrează doar intrările pentru care funcția anonimă (lambda)
	# întoarce true: nivelul cerut ȘI datele necesare, prezente.
	var disponibile: Array = GENERATOARE.filter(
		func(g): return nivel in g["niveluri"] and _date_disponibile(g["necesita"])
	)
	# Plasă de siguranță: dacă un nivel rămâne fără nimic, luăm orice putem
	# genera. Nu poate fi gol — deducțiile și enigmele n-au nevoie de date.
	if disponibile.is_empty():
		disponibile = GENERATOARE.filter(func(g): return _date_disponibile(g["necesita"]))

	var pe_tip := {}
	for generator in disponibile:
		var tip: String = generator["tip"]
		if not pe_tip.has(tip):
			pe_tip[tip] = []
		pe_tip[tip].append(generator)

	# PRIMUL din ordinea amestecată, nu `pick_random` — și tot rostul ocolului e
	# că ordinea aia trimite tipul de la treapta trecută la coadă, deci aici el
	# iese doar dacă n-a mai rămas altul. Cu un singur tip disponibil, el rămâne
	# primul: regula amână, nu interzice. Vezi „FĂRĂ DOUĂ TREPTE DIN ACELAȘI
	# TIP" din `puzzle.gd`.
	var tip_ales = tipuri_amestecate(pe_tip.keys(), tip_de_ocolit())[0]
	return pe_tip[tip_ales].pick_random()


# ─────────────────────────────────────────────────────────────
# ÎNCĂRCAREA DATELOR
#
# Godot nu poate verifica nimic dintr-un JSON la compilare: un fișier stricat
# se vede abia la rulare. De aceea încărcătorul VALIDEAZĂ fiecare intrare și
# sare peste cele stricate, cu un avertisment în consolă, în loc să crape
# lupta la mijloc. O categorie greșită costă o categorie, nu o luptă.
# ─────────────────────────────────────────────────────────────

## Sigur de chemat de oricâte ori: după prima încercare nu mai face nimic.
static func incarca_date() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	for intrare in Puzzle.citeste_lista_json(CALE_CATEGORII, "Logica"):
		if _categorie_valida(intrare, categorii.size()):
			categorii.append(intrare)
	_verifica_membri_unici()
	_indexeaza_domeniile()

	for intrare in Puzzle.citeste_lista_json(CALE_VOCABULAR, "Logica"):
		if _cuvant_valid(intrare, vocabular.size()):
			vocabular.append(intrare)
			# Lista oamenilor se face O DATĂ, aici, nu se filtrează la fiecare
			# întrebare: mulțimile și certitudinea o cer de zeci de ori pe luptă.
			if bool(intrare.get("om", false)):
				oameni.append(intrare)
			if intrare["gen"] == "m":
				masculine.append(intrare)

	print("Logica: %d categorii in %d domenii, %d cuvinte (%d oameni, %d masculine)." % [
		categorii.size(), pe_domeniu.size(), vocabular.size(),
		oameni.size(), masculine.size()
	])


static func _categorie_valida(c, i: int) -> bool:
	if not Puzzle.are_campurile(c, ["domeniu", "nume", "relatie", "membri"], "Logica", "categoria %d" % i):
		return false

	if not (c["membri"] is Array) or c["membri"].size() < MINIM_MEMBRI:
		push_warning("Logica: categoria '%s' are sub %d membri." % [c["nume"], MINIM_MEMBRI])
		return false

	return true


## Verifică REGULA DE AUR: niciun membru în două categorii. Un membru comun
## face „intrusul" să aibă două răspunsuri bune, iar tu ai crede că e un bug
## de cod. Aici afli că e o problemă de date, și exact unde.
static func _verifica_membri_unici() -> void:
	var vazut := {}   # membru -> numele primei categorii în care a apărut
	for categorie in categorii:
		for membru in categorie["membri"]:
			if vazut.has(membru):
				push_warning("Logica: '%s' apare si in '%s', si in '%s'. Categoriile trebuie sa fie disjuncte." % [
					membru, vazut[membru], categorie["nume"]
				])
			else:
				vazut[membru] = categorie["nume"]


## Grupează categoriile pe domenii și avertizează dacă vreunul e prea sărac
## ca să producă întrebări — o categorie singură în domeniul ei n-are cu cine
## fi comparată, deci nu va apărea niciodată.
static func _indexeaza_domeniile() -> void:
	pe_domeniu.clear()
	for categorie in categorii:
		var domeniu: String = categorie["domeniu"]
		if not pe_domeniu.has(domeniu):
			pe_domeniu[domeniu] = []
		pe_domeniu[domeniu].append(categorie)

	for domeniu in pe_domeniu:
		if pe_domeniu[domeniu].size() < 2:
			push_warning("Logica: domeniul '%s' are o singura categorie; nu poate produce intrebari." % domeniu)


static func _cuvant_valid(v, i: int) -> bool:
	if not Puzzle.are_campurile(v, ["singular", "plural", "articulat", "gen"], "Logica", "cuvantul %d" % i):
		return false

	if not (v["gen"] in ["m", "f"]):
		push_warning("Logica: cuvantul '%s' are genul '%s'; asteptam 'm' sau 'f'." % [
			v["singular"], v["gen"]
		])
		return false

	return true


## Avem cu ce alimenta un tip de întrebare? Analogia și intrusul au nevoie de
## două categorii diferite; silogismul, de trei cuvinte; certitudinea, de trei
## cuvinte care să fie OAMENI; implicația, de trei MASCULINE.
static func _date_disponibile(necesita: String) -> bool:
	match necesita:
		"categorii":
			# Nu e destul să avem categorii — ne trebuie două în ACELAȘI domeniu.
			for domeniu in pe_domeniu:
				if pe_domeniu[domeniu].size() >= 2:
					return true
			return false
		"vocabular":
			return vocabular.size() >= 3
		"oameni":
			return oameni.size() >= 3
		"masculine":
			return masculine.size() >= 3
	return true


# ─────────────────────────────────────────────────────────────
# TIPURI ALIMENTATE CU CATEGORII
# Niciun nume de categorie nu apare în codul de mai jos. Adaugi o categorie în
# JSON și intră singură în rotație, atât ca sursă, cât și ca distractor.
# ─────────────────────────────────────────────────────────────

## Trei membri dintr-un grup si unul strain. Care nu se potriveste?
## Dificultatea sta intr-un singur lucru: cat de aproape e strainul de grup.
## „leu, tigru, ghepard, ciment" se rezolva fara sa gandesti; „leu, tigru,
## ghepard, lup" te pune sa te uiti.
func _intrus_din_alt_domeniu() -> Dictionary:
	return _intrusul(false)


func _intrus_din_acelasi_domeniu() -> Dictionary:
	return _intrusul(true)


func _intrusul(acelasi_domeniu: bool) -> Dictionary:
	var doua := _doua_categorii(acelasi_domeniu)
	var baza: Dictionary = doua[0]
	var strain: Dictionary = doua[1]

	var membri := _ia_membri(baza, 3)
	var intrus := ""
	# Categoriile ar TREBUI sa fie disjuncte (incarcatorul avertizeaza daca nu
	# sunt), dar daca totusi nu sunt, verificam si aici: o intrebare cu doua
	# raspunsuri bune e mai rea decat una lipsa.
	for candidat in _ia_membri(strain, strain["membri"].size()):
		if not (candidat in baza["membri"]):
			intrus = candidat
			break
	if intrus == "":
		return _intrusul(acelasi_domeniu)   # straina era o copie; incercam alta

	var variante: Array[String] = membri.duplicate()
	variante.append(intrus)
	variante.shuffle()

	return {
		"text": "Care nu se potriveste?",
		"variante": variante,
		"corect": variante.find(intrus),
		"explicatie": "CEILALTI %s" % String(baza["relatie"]).to_upper(),
	}


## ANALOGIE, forma membru-la-membru: doua lucruri din acelasi grup, apoi un al
## treilea — care e perechea lui? Distractorii vin din alte categorii, iar cat
## de departe sunt ele decide dificultatea.
func _analogie_larga() -> Dictionary:
	return _analogie(false)


func _analogie_stransa() -> Dictionary:
	return _analogie(true)


func _analogie(acelasi_domeniu: bool) -> Dictionary:
	var doua := _doua_categorii(acelasi_domeniu)
	var stanga: Dictionary = doua[0]
	var dreapta: Dictionary = doua[1]

	var pereche := _ia_membri(stanga, 2)
	var tinta := _ia_membri(dreapta, 2)
	var raspuns: String = tinta[1]

	var variante: Array[String] = [raspuns]
	variante.append_array(_membri_straini([stanga, dreapta], 3, acelasi_domeniu))
	variante.shuffle()

	return {
		"text": "%s : %s\n\n%s : ?" % [
			String(pereche[0]).to_upper(), String(pereche[1]).to_upper(),
			String(tinta[0]).to_upper(),
		],
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": "AMANDOUA %s" % String(dreapta["relatie"]).to_upper(),
	}


## ANALOGIE, forma membru-la-categorie: „GHEPARD : FELINE :: STEJAR : ?"
## Aici variantele sunt NUME de categorii, nu membri — alta forma de gandire
## decat cea de mai sus, cu aceleasi date.
func _analogie_de_categorie() -> Dictionary:
	var doua := _doua_categorii(true)
	var stanga: Dictionary = doua[0]
	var dreapta: Dictionary = doua[1]

	var corect := String(dreapta["nume"]).to_upper()
	var variante: Array[String] = [corect]
	# Distractorii: numele altor categorii din acelasi domeniu. Din alt domeniu
	# ar fi fost prea evident — „arbori rasinosi" langa „arbori foiosi" doare.
	for categorie in _alte_categorii([stanga, dreapta], 3):
		variante.append(String(categorie["nume"]).to_upper())
	variante.shuffle()

	return {
		"text": "%s : %s\n\n%s : ?" % [
			String(_ia_membri(stanga, 1)[0]).to_upper(), String(stanga["nume"]).to_upper(),
			String(_ia_membri(dreapta, 1)[0]).to_upper(),
		],
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": String(dreapta["relatie"]).to_upper(),
	}


## Doua categorii diferite. Cu `acelasi_domeniu`, amandoua din aceeasi familie —
## asta e ce face intrebarea sa merite: „leu, tigru, ghepard, lup" te pune sa te
## gandesti, „leu, tigru, ghepard, ciment" nu.
func _doua_categorii(acelasi_domeniu: bool) -> Array:
	if acelasi_domeniu:
		var utile: Array = []
		for domeniu in pe_domeniu:
			if pe_domeniu[domeniu].size() >= 2:
				utile.append(pe_domeniu[domeniu])
		var grup: Array = utile.pick_random()
		var pool := grup.duplicate()
		pool.shuffle()
		return [pool[0], pool[1]]

	# Domenii diferite: luam prima categorie oriunde, a doua din alt domeniu.
	var toate := categorii.duplicate()
	toate.shuffle()
	var prima: Dictionary = toate[0]
	for categorie in toate:
		if categorie["domeniu"] != prima["domeniu"]:
			return [prima, categorie]
	return _doua_categorii(true)   # un singur domeniu in tot fisierul


## `cati` membri dintr-o categorie, la intamplare, fara repetitie.
func _ia_membri(categorie: Dictionary, cati: int) -> Array[String]:
	var pool: Array = categorie["membri"].duplicate()
	pool.shuffle()
	var alesi: Array[String] = []
	for i in range(mini(cati, pool.size())):
		alesi.append(String(pool[i]))
	return alesi


## Alte categorii decat cele folosite in intrebare, preferabil din acelasi
## domeniu. Completam din restul lumii daca domeniul e prea mic.
func _alte_categorii(excluse: Array, cati: int) -> Array:
	var domeniu: String = excluse[0]["domeniu"]
	var pool: Array = pe_domeniu[domeniu].duplicate()
	pool.shuffle()

	var rezerva := categorii.duplicate()
	rezerva.shuffle()
	pool.append_array(rezerva)

	var alese: Array = []
	for categorie in pool:
		if alese.size() == cati:
			break
		if categorie in excluse or categorie in alese:
			continue
		alese.append(categorie)
	return alese


## Distractori: cate un membru din alte categorii. Unul din fiecare categorie,
## ca sa nu iasa doua variante din acelasi grup — doua „pasari" printre variante
## ar arata amandoua la fel de plauzibile.
func _membri_straini(excluse: Array, cati: int, acelasi_domeniu: bool) -> Array[String]:
	var pool: Array = []
	if acelasi_domeniu:
		pool = _alte_categorii(excluse, cati)
	else:
		var toate := categorii.duplicate()
		toate.shuffle()
		for categorie in toate:
			if pool.size() == cati:
				break
			if categorie in excluse:
				continue
			pool.append(categorie)

	var alesi: Array[String] = []
	for categorie in pool:
		var membru := _ia_membri(categorie, 1)[0]
		if not (membru in alesi):
			alesi.append(membru)
	return alesi


# -------------------------------------------------------------
# SILOGISME
# Se asambleaza din vocabular, dupa scheme clasice. Nu depind de sensul
# cuvintelor: daca premisele spun ca toate stelele sunt corabii, in lumea
# intrebarii chiar sunt. De asta cuvintele pot fi orice — te obliga sa
# urmaresti forma, nu memoria.
# -------------------------------------------------------------

## NIVEL I — Toti A sunt B. Toti B sunt C.  =>  Toti A sunt C.
## Cea mai simpla: lantul merge intr-o singura directie.
func _silogism_barbara() -> Dictionary:
	var trei := _trei_cuvinte()
	var a: Dictionary = trei[0]
	var b: Dictionary = trei[1]
	var c: Dictionary = trei[2]
	return _silogism(
		"%s\n%s" % [_toti(a, b), _toti(b, c)],
		_toti(a, c),
		[
			_toti(c, a),      # inversul — greseala clasica
			_niciun(a, c),    # opusul concluziei
			_unii_nu(a, c),   # contrazice concluzia
		]
	)


## NIVEL II — Toti A sunt B. Niciun B nu e C.  =>  Niciun A nu e C.
## Mai greu: a doua premisa e negativa, deci nu mai poti „merge inainte".
func _silogism_celarent() -> Dictionary:
	var trei := _trei_cuvinte()
	var a: Dictionary = trei[0]
	var b: Dictionary = trei[1]
	var c: Dictionary = trei[2]
	return _silogism(
		"%s\n%s" % [_toti(a, b), _niciun(b, c)],
		_niciun(a, c),
		[
			_toti(a, c),      # opusul concluziei
			_toti(c, a),      # inversul
			_toti(b, c),      # contrazice a doua premisa
		]
	)


## NIVEL III — Toti B sunt C. Unii A sunt B.  =>  Unii A sunt C.
## Cel mai greu: concluzia e PARTIALA. Tentatia e sa spui „toti", si exact
## asta e prima varianta gresita.
func _silogism_darii() -> Dictionary:
	var trei := _trei_cuvinte()
	var a: Dictionary = trei[0]
	var b: Dictionary = trei[1]
	var c: Dictionary = trei[2]
	return _silogism(
		"%s\n%s" % [_toti(b, c), _unii(a, b)],
		_unii(a, c),
		[
			_toti(a, c),      # prea tare: din „unii" nu rezulta „toti"
			_niciun(a, c),    # contrazice concluzia
			_unii(c, a),      # inversul
		]
	)


## Impacheteaza un silogism in forma pe care o asteapta scena.
func _silogism(premise: String, raspuns: String, gresite: Array) -> Dictionary:
	var variante: Array[String] = [raspuns]
	for gresita in gresite:
		variante.append(String(gresita))
	variante.shuffle()
	return {
		"text": "%s\n\nCe rezulta?" % premise,
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": "DIN PREMISE REZULTA DOAR ATAT",
	}


## Trei cuvinte diferite din vocabular.
func _trei_cuvinte() -> Array:
	return _cuvinte(3)


## „Toti cronicarii sunt cavaleri." / „Toate pisicile sunt corbi."
## Subiectul e articulat, predicatul nu — iar „Toti/Toate" urmeaza genul
## subiectului. De asta vocabularul tine toate formele: gramatica se asambleaza
## din bucati, nu se ghiceste.
func _toti(x: Dictionary, y: Dictionary) -> String:
	var cuvant := "Toti" if x["gen"] == "m" else "Toate"
	return "%s %s sunt %s." % [cuvant, x["articulat"], y["plural"]]


## „Niciun corb nu e cavaler." / „Nicio pisica nu e vulpe."
func _niciun(x: Dictionary, y: Dictionary) -> String:
	var cuvant := "Niciun" if x["gen"] == "m" else "Nicio"
	return "%s %s nu e %s." % [cuvant, x["singular"], y["singular"]]


## „Unii cronicari sunt cavaleri." / „Unele pisici sunt vulpi."
func _unii(x: Dictionary, y: Dictionary) -> String:
	var cuvant := "Unii" if x["gen"] == "m" else "Unele"
	return "%s %s sunt %s." % [cuvant, x["plural"], y["plural"]]


## „Unii cronicari nu sunt cavaleri." / „Unele pisici nu sunt vulpi."
func _unii_nu(x: Dictionary, y: Dictionary) -> String:
	var cuvant := "Unii" if x["gen"] == "m" else "Unele"
	return "%s %s nu sunt %s." % [cuvant, x["plural"], y["plural"]]


# -------------------------------------------------------------
# DEDUCTII DE ORDONARE
# Pur generative, ca si enigmele: regula E continutul. Primesti cateva
# comparatii si trebuie sa reconstruiesti ordinea din ele.
#
# Numele sunt toate masculine, dinadins: „Dalia e mai inalt" ar fi fost o
# greseala de acord la fiecare a doua intrebare. Aici gramatica nu e subiectul
# puzzle-ului, deci o evitam in loc s-o rezolvam.
#
# De pe 1 noiembrie 2026 lista nu mai e doar a deductiilor — o folosesc si
# DACA-ATUNCI, SI/SAU, MINCINOSII, LOCURILE si POTRIVIREA, adica jumatate din
# tipuri. De-aia s-a si redenumit din `NUME_DEDUCTIE` in `NUME`: o distributie
# comuna, nu lista unui singur tipar. Si de-aia regula de mai sus conteaza acum
# de cinci ori mai mult decat atunci cand a fost scrisa.
# -------------------------------------------------------------
const NUME := [
	"Anton", "Bran", "Corvin", "Dorin", "Emil", "Filip",
	"Grigore", "Horia", "Iancu", "Luca", "Matei", "Radu",
]

# „substantiv" e forma de care are nevoie intrebarea „al doilea ca ___".
const RELATII_DEDUCTIE := [
	{"comparativ": "mai inalt", "superlativ": "cel mai inalt", "substantiv": "inaltime"},
	{"comparativ": "mai iute", "superlativ": "cel mai iute", "substantiv": "iuteala"},
	{"comparativ": "mai batran", "superlativ": "cel mai batran", "substantiv": "varsta"},
	{"comparativ": "mai bogat", "superlativ": "cel mai bogat", "substantiv": "avere"},
	{"comparativ": "mai greu", "superlativ": "cel mai greu", "substantiv": "greutate"},
]


## NIVEL I — patru insi, comparatiile date in ordine. Lantul se citeste direct.
func _deductie_in_ordine() -> Dictionary:
	return _deductie(4, false, 0)


## NIVEL II — aceiasi patru, dar comparatiile amestecate: trebuie sa le
## rearanjezi tu inainte sa poti raspunde.
func _deductie_amestecata() -> Dictionary:
	return _deductie(4, true, 0)


## NIVEL III — cinci insi, amestecat, iar intrebarea nu mai cere extrema, ci
## locul al doilea. Extrema se poate ghici uneori din capetele lantului; locul
## doi cere ordinea intreaga.
func _deductie_lunga() -> Dictionary:
	return _deductie(5, true, 1)


## `cati` insi, `pozitie` = al catelea e cautat (0 = primul).
## Comparatiile sunt intre vecini in ordinea reala, deci lantul determina
## complet ordinea — nu exista ambiguitate si nici intrebari fara raspuns.
func _deductie(cati: int, amesteca: bool, pozitie: int) -> Dictionary:
	var relatie: Dictionary = RELATII_DEDUCTIE.pick_random()

	var nume := _nume(cati)
	var ordine: Array[String] = []
	for i in range(cati):
		ordine.append(String(nume[i]))

	var afirmatii: Array[String] = []
	for i in range(cati - 1):
		afirmatii.append("%s e %s decat %s." % [ordine[i], relatie["comparativ"], ordine[i + 1]])
	if amesteca:
		afirmatii.shuffle()

	var raspuns: String = ordine[pozitie]

	# Variantele sunt chiar cei din enunt: orice alt nume s-ar elimina singur.
	var variante: Array[String] = ordine.duplicate()
	variante.shuffle()
	if variante.size() > 4:
		variante.erase(raspuns)
		variante = variante.slice(0, 3)
		variante.append(raspuns)
		variante.shuffle()

	var intrebare := "Cine e %s?" % relatie["superlativ"]
	if pozitie > 0:
		intrebare = "Cine e al doilea ca %s?" % relatie["substantiv"]

	return {
		"text": "%s\n\n%s" % ["\n".join(afirmatii), intrebare],
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": "ORDINEA: %s" % " > ".join(ordine).to_upper(),
	}


# ═════════════════════════════════════════════════════════════
# AJUTOARELE CELOR ZECE TIPURI NOI
#
# Zece tipuri noi ar fi putut aduce zece feluri de a împacheta o întrebare și
# zece feluri de a scrie „nu e". Tot ce se repetă stă aici, o dată: cele două
# împachetătoare, tragerile la sorți, propozițiile și rezolvitorii prin forță
# brută.
# ═════════════════════════════════════════════════════════════

## Textul pentru „din premise nu rezultă nimic". CONSTANTĂ, nu un literal scris
## în patru locuri — și nu din economie, ci fiindcă trebuie să fie IDENTIC
## oriunde apare. Dacă un tipar ar scrie „Nu se poate stabili." și altul „Nu se
## poate afla.", varianta s-ar recunoaște după formulare, nu după raționament —
## iar la nivelul III ea e chiar răspunsul bun.
const NEHOTARAT := "Nu se poate stabili."

## Golul din care lipsește o premisă. Tot o constantă, din același motiv:
## lungimea liniuțelor nu e o decizie care are voie să difere între tipare.
const LOCUL_GOL := "_____"

## De câte ori se încearcă o rețetă înainte de ecranul de eroare.
## Vezi `_compune_intrebare`: tipurile cu constrângeri au voie să dea greș.
const INCERCARI_COMPUNERE := 8

## De câte ori un tip cu constrângeri își mai trage indiciile înainte să
## renunțe. O încercare costă câteva zeci de microsecunde (8, 24 sau 120 de
## situații verificate), deci cifra poate fi mare fără să se simtă.
const INCERCARI_ENIGMA := 24


## Împachetează o întrebare cu variante de TEXT, în forma cerută de `puzzle.gd`.
##
## Sare peste variantele care se repetă și, dacă din patru rămân mai puține,
## întoarce un dicționar GOL. E singurul răspuns cinstit: două butoane care
## scriu același lucru sunt fie o întrebare cu două răspunsuri bune, fie una
## care arată stricată. `_compune_intrebare` tratează golul ca „n-am putut".
func _pachet(enunt: String, raspuns: String, gresite: Array, explicatie: String) -> Dictionary:
	var variante: Array[String] = [raspuns]
	for gresita in gresite:
		var text := String(gresita)
		if not (text in variante):
			variante.append(text)
	if variante.size() != 4:
		return {}
	variante.shuffle()
	return {
		"text": enunt,
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": explicatie,
	}


## Ca `_pachet`, dar pentru răspunsuri NUMERICE: primește o listă de greșeli
## plauzibile, le amestecă și ia primele trei care sunt pozitive și diferite.
##
## Aceeași regulă ca la șirurile numerice (vezi `_variante_numerice` din
## `tipare.gd`, unde s-a scris întâi și unde trăiește de pe 1 noiembrie): un
## distractor trebuie să fie rezultatul pe care-l obții dacă te înșeli — ai
## uitat să scazi intersecția, ai scăzut-o de două ori, ai numărat grupul
## greșit. Cu numere la întâmplare, răspunsul bun ar fi cel care „arată bine",
## iar puzzle-ul n-ar mai măsura nimic.
func _pachet_numeric(enunt: String, raspuns: int, candidati: Array, explicatie: String) -> Dictionary:
	var pool := candidati.duplicate()
	pool.shuffle()
	var numere: Array[int] = [raspuns]
	for candidat in pool:
		if numere.size() == 4:
			break
		var numar := int(candidat)
		if numar > 0 and not (numar in numere):
			numere.append(numar)

	# Plasă de siguranță, ca la șirurile de la Tipare: dacă greșelile s-au suprapus
	# între ele, completăm cu vecini, ca să nu rămână un buton gol.
	var distanta := 1
	while numere.size() < 4:
		if raspuns + distanta > 0 and not (raspuns + distanta in numere):
			numere.append(raspuns + distanta)
		distanta += 1

	var variante: Array[String] = []
	for numar in numere:
		variante.append(str(numar))
	variante.shuffle()
	return {
		"text": enunt,
		"variante": variante,
		"corect": variante.find(str(raspuns)),
		"explicatie": explicatie,
	}


# ─── TRAGERILE LA SORȚI ──────────────────────────────────────

## `cate` cuvinte diferite din vocabular.
func _cuvinte(cate: int) -> Array:
	var pool := vocabular.duplicate()
	pool.shuffle()
	return pool.slice(0, cate)


## `cate` cuvinte diferite, toate MASCULINE.
##
## Tiparele cu un singur personaj au nevoie de ele: toate numele din `NUME` sunt
## masculine, dinadins (vezi comentariul de acolo), iar „Emil e calugarita" e o
## greșeală de ACORD, nu un nonsens util.
##
## Și distincția merită ținută minte, fiindcă pare o inconsecvență: nonsensul de
## la silogisme — „Toate stelele sunt corabii" — e BUN, te împiedică să răspunzi
## din memorie. Dar acolo nonsensul e în ÎNȚELES, iar propoziția e corectă
## gramatical. O greșeală de acord nu aduce nimic: nu te face să gândești, doar
## te face să te oprești și să te întrebi dacă generatorul e stricat.
func _cuvinte_masculine(cate: int) -> Array:
	var pool := masculine.duplicate()
	pool.shuffle()
	return pool.slice(0, cate)


## `cate` cuvinte diferite care sunt OAMENI (vezi câmpul „om" din vocabular).
func _oameni_diferiti(cate: int) -> Array:
	var pool := oameni.duplicate()
	pool.shuffle()
	return pool.slice(0, cate)


## `cati` oameni diferiți din distribuția comună de nume.
func _nume(cati: int) -> Array:
	var pool := NUME.duplicate()
	pool.shuffle()
	return pool.slice(0, cati)


## Un singur nume, pentru tiparele cu un singur personaj.
func _un_nume() -> String:
	return String(NUME.pick_random())


## `cate` lucruri diferite, pentru POTRIVIRE.
func _lucruri(cate: int) -> Array:
	var pool := LUCRURI.duplicate()
	pool.shuffle()
	return pool.slice(0, cate)


## `cate` indici diferiți din 0…`din`-1. Indici, nu nume: rezolvitorii lucrează
## pe numere, iar numele se pun abia la afișare — aceeași despărțire ca la
## Lacăt, unde indiciul e `{"a": 0, "b": 2}` și propoziția se compune la sfârșit.
func _indici(din: int, cate: int) -> Array:
	var pool := range(din)
	pool.shuffle()
	return pool.slice(0, cate)


# ─── PROPOZIȚIILE ────────────────────────────────────────────
# Se asamblează din bucăți, ca și cele de la silogisme, și din același motiv:
# gramatica nu se ghicește. Toate primesc un NUME ca subiect, nu o clasă, iar
# asta e ce face implicația citibilă: „Daca Luca e cronicar, atunci e cavaler"
# se urmărește din ochi, „Daca ceva e cronicar, atunci e cavaler" nu.

## „e" sau „nu e". Un singur loc în care se hotărăște cum arată negația.
func _e(afirmativ: bool) -> String:
	return "e" if afirmativ else "nu e"


## „Luca e cronicar." / „Luca nu e cronicar."
func _este(nume: String, x: Dictionary, afirmativ := true) -> String:
	return "%s %s %s." % [nume, _e(afirmativ), x["singular"]]


## Scurtătura pentru forma negativă, ca enunțurile să se citească de sus în jos.
func _nu_este(nume: String, x: Dictionary) -> String:
	return _este(nume, x, false)


## „Daca Luca e cronicar, atunci e cavaler."
##
## Cu steagurile pe false ies CELELALTE TREI forme care se confundă cu ea:
## inversa `_daca(n, x, y, false, false)`, conversa `_daca(n, y, x)` și
## contrapozitiva `_daca(n, y, x, false, false)`. Toate din aceeași funcție,
## dinadins: patru funcții ar fi fost patru locuri în care punctuația ar fi
## putut să se despartă pe furiș, iar la nivelul III cele patru forme stau una
## lângă alta pe ecran.
func _daca(nume: String, x: Dictionary, y: Dictionary, da_x := true, da_y := true) -> String:
	return "Daca %s %s %s, atunci %s %s." % [nume, _e(da_x), x["singular"], _e(da_y), y["singular"]]


## „Luca e cronicar si nu e cavaler."
## „e"/„nu e" se repetă pe amândouă laturile, chiar și când sunt amândouă
## afirmative („Luca e cronicar si e cavaler"). Mai stângaci, dar neambiguu —
## iar într-un puzzle de logică ambiguitatea e mai scumpă decât stilul.
func _si(nume: String, x: Dictionary, y: Dictionary, da_x := true, da_y := true) -> String:
	return "%s %s %s si %s %s." % [nume, _e(da_x), x["singular"], _e(da_y), y["singular"]]


## „Luca nu e cronicar sau nu e cavaler."
func _sau(nume: String, x: Dictionary, y: Dictionary, da_x := true, da_y := true) -> String:
	return "%s %s %s sau %s %s." % [nume, _e(da_x), x["singular"], _e(da_y), y["singular"]]


## „Nu e adevarat ca Luca e cronicar si e cavaler."
## Primește o propoziție întreagă, cu punct la capăt, și o înghite — de-aia nu
## trebuie să știe nimic despre ce neagă.
func _nu_e_adevarat(afirmatie: String) -> String:
	return "Nu e adevarat ca %s" % afirmatie


## Pune între ghilimele o afirmație care se CITEAZĂ, nu se afirmă. La negație și
## la De Morgan enunțul vorbește DESPRE o propoziție; fără ghilimele, ea s-ar
## citi ca o premisă, adică drept adevărată.
func _citat(afirmatie: String) -> String:
	return "„%s”" % afirmatie


## „Anton, Bran si Luca" / „arc, coif sau pumnal". Legătura de la sfârșit e
## parametru fiindcă enunțul are nevoie de amândouă în ACEEAȘI propoziție:
## oamenii sunt toți acolo („si"), lucrurile se împart între ei („sau").
func _insir(lista: Array, legatura: String) -> String:
	if lista.size() == 1:
		return String(lista[0])
	var afara: Array[String] = []
	for i in range(lista.size() - 1):
		afara.append(String(lista[i]))
	return "%s %s %s" % [", ".join(afara), legatura, String(lista[-1])]


## „un" sau „o", după genul cuvântului.
func _articol(cuvant: Dictionary) -> String:
	return "un" if cuvant["gen"] == "m" else "o"


## „doi" sau „doua", după gen.
func _doi(cuvant: Dictionary) -> String:
	return "doi" if cuvant["gen"] == "m" else "doua"


# ─── REZOLVITORII PRIN FORȚĂ BRUTĂ ───────────────────────────
# Trei tipuri noi (MINCINOSI, ASEZARE, POTRIVIRE) nu CONSTRUIESC răspunsul, îl
# CAUTĂ: trag niște indicii adevărate despre o situație ascunsă, apoi trec prin
# toate situațiile posibile și păstrează enigma doar dacă răspunsul iese același
# peste tot. Aceeași metodă ca la Lacăt (`generator_cifru.gd`): un puzzle nu se
# crede pe cuvânt, se rezolvă.
#
# Numerele sunt mult sub orice grijă de viteză: 2^3 = 8 atribuiri la mincinoși,
# 4! = 24 sau 5! = 120 de permutări la locuri și la potrivire.

# Permutările se memorează pe numărul de elemente: se cer de zeci de ori pe
# luptă și nu se schimbă niciodată. Cine le primește NU le modifică.
static var permutari_memorate := {}


## Toate permutările lui 0…`cate`-1, fiecare ca Array.
static func _permutari(cate: int) -> Array:
	if not permutari_memorate.has(cate):
		var rezultat: Array = []
		_creste_permutari([], range(cate), rezultat)
		permutari_memorate[cate] = rezultat
	return permutari_memorate[cate]


static func _creste_permutari(inceput: Array, rest: Array, rezultat: Array) -> void:
	if rest.is_empty():
		rezultat.append(inceput)
		return
	for i in range(rest.size()):
		var ramas := rest.duplicate()
		var ales = ramas.pop_at(i)
		var mai_lung := inceput.duplicate()
		mai_lung.append(ales)
		_creste_permutari(mai_lung, ramas, rezultat)


## Dau toate soluțiile ACELAȘI răspuns? Întoarce răspunsul, sau -1 dacă nu.
##
## Asta, și nu „soluția e unică", e condiția de care avem nevoie — și e mult mai
## blândă. Ca să întreb „cine stă pe locul 3?" nu-mi trebuie toată așezarea
## determinată, îmi trebuie doar locul 3. Cerând unicitatea întregii soluții aș
## fi avut nevoie de cinci indicii acolo unde doi ajung, adică de cinci rânduri
## de citit — iar un enunț pe care nu-l termini nu e un puzzle mai greu, e un
## puzzle pe care nu l-ai jucat.
##
## `extrage` e funcția care scoate răspunsul dintr-o soluție: „cine stă pe locul
## 3", „ce are Anton", „cine are spada". Rezolvitorul nu trebuie să știe care
## din ele e — de-aia o primește, în loc s-o aleagă cu un `if`.
static func _acelasi_raspuns(solutii: Array, extrage: Callable) -> int:
	if solutii.is_empty():
		return -1
	var intai := int(extrage.call(solutii[0]))
	for solutie in solutii:
		if int(extrage.call(solutie)) != intai:
			return -1
	return intai


# ═════════════════════════════════════════════════════════════
# DACĂ-ATUNCI — implicația
#
# Silogismul vorbește despre CLASE („toți cronicarii"); implicația vorbește
# despre UN caz („dacă Luca e cronicar"). Sunt două mușchiuri diferite, și
# diferența se vede în greșeli: la silogism greșești conversia, la implicație
# greșești SENSUL — crezi că merge și înapoi.
#
# Cele patru tipare sunt cele patru forme care se confundă între ele:
#   P → Q, P        ⊢ Q        (modus ponens, nivelul I)
#   P → Q, ¬Q       ⊢ ¬P       (modus tollens, nivelul II)
#   P → Q           ≡ ¬Q → ¬P  (contrapozitiva, nivelurile II-III)
#   P → Q, Q        ⊢ nimic    (afirmarea consecventului, nivelul III)
#   P → Q, ¬P       ⊢ nimic    (negarea antecedentului, nivelul III)
#
# `NEHOTARAT` apare ca variantă la TOATE, nu doar la nivelul III. Altfel ar fi
# fost un semn: „văd «Nu se poate stabili», deci asta e". O variantă care e
# corectă numai într-un tipar și lipsește din celelalte nu mai e o variantă, e
# un indiciu.
# ═════════════════════════════════════════════════════════════

## NIVEL I — condiția s-a împlinit, deci și urmarea.
func _modus_ponens() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"%s\n%s\n\nCe rezulta?" % [_daca(nume, c[0], c[1]), _este(nume, c[0])],
		_este(nume, c[1]),
		[_nu_este(nume, c[1]), _nu_este(nume, c[0]), NEHOTARAT],
		"CONDITIA S-A IMPLINIT, DECI SI URMAREA"
	)


## NIVEL II — urmarea lipsește, deci nu putea fi nici condiția. Mai greu decât
## modus ponens fiindcă se citește ÎNAPOI, de la capăt spre început.
func _modus_tollens() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"%s\n%s\n\nCe rezulta?" % [_daca(nume, c[0], c[1]), _nu_este(nume, c[1])],
		_nu_este(nume, c[0]),
		[_este(nume, c[0]), _este(nume, c[1]), NEHOTARAT],
		"FARA URMARE NU POATE FI NICI CONDITIA"
	)


## NIVELURILE II-III — care propoziție spune exact același lucru.
## Pe ecran stau una lângă alta toate patru rudele: contrapozitiva (bună),
## inversa, conversa și o conjuncție. Trei din patru arată la fel de plauzibil.
func _contrapozitiva() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"Ce spune ACELASI lucru?\n\n%s" % _citat(_daca(nume, c[0], c[1])),
		_daca(nume, c[1], c[0], false, false),
		[
			_daca(nume, c[0], c[1], false, false),   # inversa
			_daca(nume, c[1], c[0]),                 # conversa
			_si(nume, c[0], c[1], false, false),     # nici una, nici alta
		],
		"SE INTORC AMANDOUA: SI ORDINEA, SI SEMNUL"
	)


## NIVEL III — cele două capcane clasice. Răspunsul bun e că NU rezultă nimic,
## iar varianta cea mai ispititoare e tocmai concluzia pe care ai trage-o dacă
## ai citi implicația în amândouă sensurile.
func _conditional_nehotarat() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	var premise := ""
	var gresite: Array = []

	if randf() < 0.5:
		# AFIRMAREA CONSECVENTULUI: urmarea s-a întâmplat — dar poate din alt
		# motiv. „Daca e cronicar, atunci e cavaler" nu spune nimic despre
		# cavalerii care nu sunt cronicari.
		premise = "%s\n%s" % [_daca(nume, c[0], c[1]), _este(nume, c[1])]
		gresite = [_este(nume, c[0]), _nu_este(nume, c[0]), _nu_este(nume, c[1])]
	else:
		# NEGAREA ANTECEDENTULUI: condiția n-a fost îndeplinită — dar urmarea
		# poate veni oricum, pe alt drum.
		premise = "%s\n%s" % [_daca(nume, c[0], c[1]), _nu_este(nume, c[0])]
		gresite = [_nu_este(nume, c[1]), _este(nume, c[1]), _este(nume, c[0])]

	return _pachet(
		"%s\n\nCe rezulta?" % premise,
		NEHOTARAT,
		gresite,
		"IMPLICATIA MERGE INTR-UN SINGUR SENS"
	)


# ═════════════════════════════════════════════════════════════
# NEGAȚIA — ce spune exact contrariul
#
# Tipul cu cea mai mică suprafață și cel mai mare câștig: o întrebare de un
# rând, cu o greșeală pe care o face aproape toată lumea. Negația lui „toți
# corbii sunt negri" NU e „niciun corb nu e negru" (asta e contrariul, nu
# contradictoria) — e „există un corb care nu e negru". Un singur contraexemplu
# dărâmă un „toți".
#
# Distractorii sunt întotdeauna aceiași patru vecini: contrariul (prea tare),
# conversa (întoarsă) și afirmația însăși, slăbită. Nu e lene — ei sunt chiar
# greșelile care se fac, iar lista lor scurtă e chiar lecția.
# ═════════════════════════════════════════════════════════════

## NIVEL I — negația lui „toți".
func _negatie_toti() -> Dictionary:
	var c := _cuvinte(2)
	return _pachet(
		"Care e negatia?\n\n%s" % _citat(_toti(c[0], c[1])),
		_unii_nu(c[0], c[1]),
		[
			_niciun(c[0], c[1]),   # contrariul: prea tare
			_toti(c[1], c[0]),     # conversa
			_unii(c[0], c[1]),     # afirmația, slăbită
		],
		"UN SINGUR CONTRAEXEMPLU DARAMA UN „TOTI”"
	)


## NIVEL II — negația lui „niciunul". Mai greu: răspunsul e cel mai SLAB dintre
## cele patru, iar instinctul cere ceva pe măsura unui „niciunul".
func _negatie_niciun() -> Dictionary:
	var c := _cuvinte(2)
	return _pachet(
		"Care e negatia?\n\n%s" % _citat(_niciun(c[0], c[1])),
		_unii(c[0], c[1]),
		[
			_toti(c[0], c[1]),     # prea tare
			_unii_nu(c[0], c[1]),  # negație, dar pe partea greșită
			_niciun(c[1], c[0]),   # conversa, care aici spune ACELAȘI lucru
		],
		"„NICIUNUL” CADE LA UN SINGUR CAZ CARE DA"
	)


## NIVEL II — negația lui „unii". Singura care urcă în tărie: din „nu e adevărat
## că unii" rezultă „niciunul".
func _negatie_unii() -> Dictionary:
	var c := _cuvinte(2)
	return _pachet(
		"Care e negatia?\n\n%s" % _citat(_unii(c[0], c[1])),
		_niciun(c[0], c[1]),
		[
			_unii_nu(c[0], c[1]),  # capcana: arată ca o negație, dar nu e a ei
			_toti(c[0], c[1]),
			_unii(c[1], c[0]),
		],
		"DACA NICI „UNII” NU E, ATUNCI NICIUNUL"
	)


## NIVEL III — negația unei implicații. Cea mai greu de ghicit din formă: nu e
## o altă implicație, e un CAZ CONCRET care o dărâmă.
func _negatie_conditional() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"Care e negatia?\n\n%s" % _citat(_daca(nume, c[0], c[1])),
		_si(nume, c[0], c[1], true, false),
		[
			_daca(nume, c[0], c[1], true, false),    # tot o implicație: prea tare
			_si(nume, c[0], c[1], false, false),
			_daca(nume, c[0], c[1], false, false),   # inversa
		],
		"O IMPLICATIE SE NEAGA CU UN CONTRAEXEMPLU"
	)


# ═════════════════════════════════════════════════════════════
# ȘI / SAU — conectorii
#
# Primele două tipare sunt raționamente („din astea două, ce rezultă?"), al
# treilea și al patrulea sunt ECHIVALENȚE: cele două legi ale lui De Morgan,
# adică singurul loc din disciplină unde se cere ce înseamnă „nu e adevărat că".
#
# Capcana e aceeași la amândouă legile și e simetrică: negarea unui „sau" dă un
# „și", negarea unui „și" dă un „sau". Instinctul păstrează conectorul și mută
# doar negațiile — de-aia varianta greșită e exact afirmația bună cu conectorul
# neschimbat.
# ═════════════════════════════════════════════════════════════

## NIVEL I — silogismul disjunctiv: dacă una din două cade, rămâne cealaltă.
func _conector_sau() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"%s\n%s\n\nCe rezulta?" % [_sau(nume, c[0], c[1]), _nu_este(nume, c[0])],
		_este(nume, c[1]),
		[_nu_este(nume, c[1]), _este(nume, c[0]), NEHOTARAT],
		"DACA UNA DIN DOUA CADE, RAMANE CEALALTA"
	)


## NIVEL II — „nu amândouă" plus una dintre ele.
func _conector_si_fals() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"%s\n%s\n\nCe rezulta?" % [_nu_e_adevarat(_si(nume, c[0], c[1])), _este(nume, c[0])],
		_nu_este(nume, c[1]),
		[_este(nume, c[1]), _nu_este(nume, c[0]), NEHOTARAT],
		"DACA AMANDOUA NU POT FI, IAR UNA E, CEALALTA NU E"
	)


## NIVEL III — De Morgan pe „sau": negarea lui neagă AMÂNDOUĂ.
func _de_morgan_sau() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"Ce spune ACELASI lucru?\n\n%s" % _citat(_nu_e_adevarat(_sau(nume, c[0], c[1]))),
		_si(nume, c[0], c[1], false, false),
		[
			_sau(nume, c[0], c[1], false, false),   # conectorul nemutat
			_si(nume, c[0], c[1], true, false),
			_nu_este(nume, c[0]),                   # doar jumătate
		],
		"NEGAREA UNUI „SAU” NEAGA AMANDOUA"
	)


## NIVEL III — De Morgan pe „și": negarea lui lasă un „sau", nu un „și".
func _de_morgan_si() -> Dictionary:
	var c := _cuvinte_masculine(2)
	var nume := _un_nume()
	return _pachet(
		"Ce spune ACELASI lucru?\n\n%s" % _citat(_nu_e_adevarat(_si(nume, c[0], c[1]))),
		_sau(nume, c[0], c[1], false, false),
		[
			_si(nume, c[0], c[1], false, false),    # conectorul nemutat
			_nu_este(nume, c[0]),
			_nu_este(nume, c[1]),
		],
		"NEGAREA UNUI „SI” LASA UN „SAU”"
	)


# ═════════════════════════════════════════════════════════════
# PREMISA LIPSĂ — nu tragi concluzia, o repari
#
# Alt mușchi decât silogismul, și merită spus de ce: la silogism ți se dau toate
# premisele și ți se cere ce rezultă; aici ți se dă concluzia și ți se ia o
# premisă. Primul se rezolvă citind înainte, al doilea cerând „ce ar trebui să
# fie adevărat ca asta să țină?" — exact întrebarea pe care o pui când citești
# un argument al altcuiva.
#
# Distractorii sunt aleși cu grijă să fie INVALIZI, nu doar diferiți, și ăsta e
# singurul loc din fișier în care alegerea lor cere atenție la logică, nu la
# plauzibilitate. Două capcane evitate dinadins:
#   • „Niciun C nu e B" NU poate fi distractor la o premisă „Niciun B nu e C":
#     propozițiile negative universale se întorc, deci ar fi un AL DOILEA
#     răspuns bun.
#   • nici concluzia însăși, repetată ca premisă: un argument în care concluzia
#     e printre premise e valid, deci tot un al doilea răspuns bun.
# ═════════════════════════════════════════════════════════════

## NIVEL I — lipsește veriga din MIJLOC.
## Toți A sunt B. [Toți B sunt C.] Deci toți A sunt C.
func _premisa_mijloc() -> Dictionary:
	var c := _cuvinte(3)
	return _pachet(
		"%s\n%s\nDeci: %s\n\nCe premisa lipseste?" % [
			_toti(c[0], c[1]), LOCUL_GOL, _toti(c[0], c[2])
		],
		_toti(c[1], c[2]),
		[
			_toti(c[2], c[1]),    # conversa: nu duce nicăieri
			_unii(c[1], c[2]),    # prea slabă pentru un „toți"
			_niciun(c[1], c[2]),  # dă exact contrariul concluziei
		],
		"VERIGA DINTRE PRIMA PREMISA SI CONCLUZIE"
	)


## NIVEL II — concluzia e NEGATIVĂ, deci veriga trebuie să fie și ea.
## Toți A sunt B. [Niciun B nu e C.] Deci niciun A nu e C.
func _premisa_negativa() -> Dictionary:
	var c := _cuvinte(3)
	return _pachet(
		"%s\n%s\nDeci: %s\n\nCe premisa lipseste?" % [
			_toti(c[0], c[1]), LOCUL_GOL, _niciun(c[0], c[2])
		],
		_niciun(c[1], c[2]),
		[
			_toti(c[1], c[2]),     # ar da tocmai opusul
			_unii_nu(c[1], c[2]),  # prea slabă
			_unii(c[1], c[2]),
		],
		"O CONCLUZIE NEGATIVA CERE O PREMISA NEGATIVA"
	)


## NIVELURILE II-III — același lucru, pe implicații: un lanț căruia îi lipsește
## inelul din mijloc.
func _premisa_lant() -> Dictionary:
	var c := _cuvinte_masculine(3)
	var nume := _un_nume()
	return _pachet(
		"%s\n%s\nDeci: %s\n\nCe premisa lipseste?" % [
			_daca(nume, c[0], c[1]), LOCUL_GOL, _daca(nume, c[0], c[2])
		],
		_daca(nume, c[1], c[2]),
		[
			_daca(nume, c[2], c[1]),                 # conversa
			_daca(nume, c[1], c[2], false, false),   # inversa
			_daca(nume, c[0], c[1], false, false),
		],
		"LANTUL SE LEAGA DOAR INTR-UN SENS"
	)


## NIVEL III — gaura e la ÎNCEPUT. Mai greu, fiindcă nu mai poți citi de sus în
## jos: trebuie să pornești de la concluzie și să mergi înapoi.
## [Toți A sunt B.] Niciun B nu e C. Deci niciun A nu e C.
func _premisa_prima() -> Dictionary:
	var c := _cuvinte(3)
	return _pachet(
		"%s\n%s\nDeci: %s\n\nCe premisa lipseste?" % [
			LOCUL_GOL, _niciun(c[1], c[2]), _niciun(c[0], c[2])
		],
		_toti(c[0], c[1]),
		[
			_toti(c[1], c[0]),     # conversa: B în A nu spune nimic despre A
			_unii(c[0], c[1]),     # ar da doar „unii A nu sunt C"
			_niciun(c[0], c[1]),
		],
		"TOT A TREBUIE SA INTRE IN B CA SA MOSTENEASCA NEGATIA"
	)


# ═════════════════════════════════════════════════════════════
# ADEVĂR ȘI MINCIUNĂ — cavalerii spun adevărul, mincinoșii mint
#
# Primul tip din disciplină care nu CONSTRUIEȘTE răspunsul, ci îl CAUTĂ.
# Celelalte pornesc de la regulă și scriu întrebarea din ea; aici se trag niște
# afirmații la întâmplare și apoi se încearcă toate lumile posibile — o enigmă
# se păstrează doar dacă exact una se potrivește.
#
# DE CE E SINGURUL MOD CINSTIT. O afirmație e adevărată sau falsă DEPINZÂND de
# ce fel de om e cel care o rostește, iar ce fel de om e depinde de ce au spus
# ceilalți. Nu există o formulă care să-ți dea „Anton minte" din trei afirmații
# alese la noroc; există doar încercarea tuturor celor 2^3 = 8 combinații. Opt.
# Un generator care „ar construi" răspunsul ar fi, de fapt, un generator care
# publică enigme pe care nu le-a rezolvat.
#
# Afirmațiile sunt de trei feluri, fiecare o întrebare DA/NU despre o lume:
#   ESTE     — „Bran e mincinos."
#   AMANDOI  — „Eu si Bran suntem cavaleri."
#   ACELASI  — „Eu si Bran suntem de acelasi fel."
#
# Cu doi oameni și numai „ESTE" NU se poate face o enigmă: fiecare vorbește
# despre celălalt, situația e simetrică, iar simetria lasă mereu două soluții.
# De-aia există celelalte două forme — ele rup simetria. (E și motivul pentru
# care verificarea bate asta: ar fi exact felul de regulă care se pierde într-o
# refactorizare.)
# ═════════════════════════════════════════════════════════════

const AFIRMATII_SIMPLE := ["ESTE", "ACELASI"]
const AFIRMATII_TOATE := ["ESTE", "AMANDOI", "ACELASI"]

# Numele celor patru răspunsuri la „câți mint?". Indicele E numărul, deci lista
# se citește direct, fără tabel de traducere.
const CATI_MINT := ["Niciunul", "Unul", "Doi", "Toti trei"]


## Afirmația e adevărată în lumea descrisă de `atribuire`?
## `atribuire[om]` = true dacă omul e cavaler, deci spune adevărul.
static func _afirmatia_tine(af: Dictionary, atribuire: Array) -> bool:
	var cine: bool = atribuire[af["cine"]]
	var despre: bool = atribuire[af["despre"]]
	var pozitiv := bool(af["pozitiv"])
	match af["forma"]:
		"ESTE":
			return despre == pozitiv
		"AMANDOI":
			return cine == pozitiv and despre == pozitiv
		"ACELASI":
			return (cine == despre) == pozitiv
	return false


## Toate lumile în care fiecare om spune ce i se potrivește felului lui:
## cavalerii lucruri adevărate, mincinoșii lucruri false. Asta e tot ce
## înseamnă „a rezolva" enigma — o condiție pe fiecare om, verificată peste tot.
static func _solutii_mincinosi(afirmatii: Array, cati: int) -> Array:
	var solutii: Array = []
	for masca in range(1 << cati):
		var atribuire: Array = []
		for i in range(cati):
			atribuire.append((masca >> i) & 1 == 1)
		var bun := true
		for af in afirmatii:
			if atribuire[af["cine"]] != _afirmatia_tine(af, atribuire):
				bun = false
				break
		if bun:
			solutii.append(atribuire)
	return solutii


## Trage o enigmă cu soluție UNICĂ, sau întoarce gol.
##
## Aici se cere soluția ÎNTREAGĂ, nu doar răspunsul (cum la locuri și la
## potrivire): răspunsul E cine minte, deci a ști răspunsul și a ști soluția
## sunt același lucru.
func _enigma_mincinosi(cati: int, forme: Array) -> Dictionary:
	var nume := _nume(cati)
	for incercare in range(INCERCARI_ENIGMA):
		var afirmatii: Array = []
		for i in range(cati):
			# Fiecare vorbește despre ALTCINEVA. „Eu sunt cavaler" n-ar spune
			# nimic (și un cavaler, și un mincinos o rostesc fără să se
			# contrazică), iar „eu sunt mincinos" n-ar avea nicio soluție.
			var despre := i
			while despre == i:
				despre = randi_range(0, cati - 1)
			afirmatii.append({
				"cine": i,
				"despre": despre,
				"forma": forme.pick_random(),
				"pozitiv": randf() < 0.5,
			})
		var solutii := _solutii_mincinosi(afirmatii, cati)
		if solutii.size() == 1:
			return {"nume": nume, "afirmatii": afirmatii, "atribuire": solutii[0]}
	return {}


## Numele celor care mint, în ordinea din enunț.
func _cine_minte(enigma: Dictionary) -> Array:
	var mincinosi: Array = []
	var atribuire: Array = enigma["atribuire"]
	for i in range(atribuire.size()):
		if not bool(atribuire[i]):
			mincinosi.append(String(enigma["nume"][i]))
	return mincinosi


func _text_afirmatie(af: Dictionary, nume: Array) -> String:
	var despre: String = nume[af["despre"]]
	var pozitiv := bool(af["pozitiv"])
	match af["forma"]:
		"ESTE":
			return "%s e %s." % [despre, "cavaler" if pozitiv else "mincinos"]
		"AMANDOI":
			return "Eu si %s suntem %s." % [despre, "cavaleri" if pozitiv else "mincinosi"]
		"ACELASI":
			return "Eu si %s suntem %s." % [despre, "de acelasi fel" if pozitiv else "de feluri diferite"]
	return ""


## Enunțul: regula jocului pe primul rând, apoi câte o replică de fiecare.
func _text_mincinosi(enigma: Dictionary) -> String:
	var nume: Array = enigma["nume"]
	var rand: Array[String] = ["Cavalerii spun adevarul, mincinosii mint."]
	for af in enigma["afirmatii"]:
		rand.append("%s: %s" % [nume[af["cine"]], _citat(_text_afirmatie(af, nume))])
	return "\n".join(rand)


## Explicația e soluția întreagă, nu regula: aici regula e scrisă în enunț, iar
## ce nu vezi e tocmai cine a ieșit ce.
func _explicatie_mincinosi(enigma: Dictionary) -> String:
	var bucati: Array[String] = []
	var atribuire: Array = enigma["atribuire"]
	for i in range(atribuire.size()):
		bucati.append("%s %s" % [
			String(enigma["nume"][i]).to_upper(),
			"SPUNE ADEVARUL" if bool(atribuire[i]) else "MINTE",
		])
	return ", ".join(bucati)


## NIVEL I — doi oameni. Variantele acoperă toate cazurile posibile, deci nu se
## poate elimina niciuna din citit.
func _mincinosi_doi() -> Dictionary:
	var enigma := _enigma_mincinosi(2, AFIRMATII_TOATE)
	if enigma.is_empty():
		return {}

	var nume: Array = enigma["nume"]
	var mincinosi := _cine_minte(enigma)
	var raspuns := "Niciunul"
	if mincinosi.size() == 1:
		raspuns = String(mincinosi[0])
	elif mincinosi.size() == 2:
		raspuns = "Amandoi"

	var variante: Array = [String(nume[0]), String(nume[1]), "Amandoi", "Niciunul"]
	var gresite: Array = []
	for varianta in variante:
		if String(varianta) != raspuns:
			gresite.append(String(varianta))

	return _pachet(
		"%s\n\nCine minte?" % _text_mincinosi(enigma),
		raspuns,
		gresite,
		_explicatie_mincinosi(enigma)
	)


## NIVEL II — trei oameni, cel mult unul mincinos, deci răspunsul e un NUME (sau
## „Niciunul", care se întâmplă și el: altfel varianta aia ar fi fost un semn
## că întrebarea e de nivelul II).
func _mincinosi_trei() -> Dictionary:
	for incercare in range(INCERCARI_ENIGMA):
		var enigma := _enigma_mincinosi(3, AFIRMATII_SIMPLE)
		if enigma.is_empty():
			continue
		var mincinosi := _cine_minte(enigma)
		if mincinosi.size() > 1:
			continue

		var raspuns := String(mincinosi[0]) if mincinosi.size() == 1 else "Niciunul"
		var gresite: Array = ["Niciunul"]
		for n in enigma["nume"]:
			gresite.append(String(n))
		gresite.erase(raspuns)

		var pachet := _pachet(
			"%s\n\nCine minte?" % _text_mincinosi(enigma),
			raspuns,
			gresite,
			_explicatie_mincinosi(enigma)
		)
		if not pachet.is_empty():
			return pachet
	return {}


## NIVEL III — trei oameni, orice amestec, iar întrebarea cere NUMĂRUL. Mai greu
## decât „cine minte": ca să numeri, trebuie să-i fi pus pe toți trei la loc.
func _mincinosi_numar() -> Dictionary:
	var enigma := _enigma_mincinosi(3, AFIRMATII_TOATE)
	if enigma.is_empty():
		return {}

	var cati := _cine_minte(enigma).size()
	var gresite: Array = []
	for i in range(CATI_MINT.size()):
		if i != cati:
			gresite.append(CATI_MINT[i])

	return _pachet(
		"%s\n\nCati dintre ei mint?" % _text_mincinosi(enigma),
		CATI_MINT[cati],
		gresite,
		_explicatie_mincinosi(enigma)
	)


# ═════════════════════════════════════════════════════════════
# MULȚIMI — reuniune, intersecție, „numai una", „niciuna"
#
# Aritmetica e de clasa a doua, și e dinadins așa: greul nu e să scazi, e să
# vezi CE se scade și de câte ori. Cine adună 12 cu 9 și se oprește a greșit un
# raționament, nu un calcul — de-aia tipul stă la Logică și nu la Numere, și
# de-aia prima variantă greșită e întotdeauna tocmai suma.
#
# CIFRELE RĂMÂN SUB 20, și nu din grija pentru calcul: în românește „12
# cronicari" se scrie fără „de", iar „20 de cronicari" cu. O regulă de
# gramatică pe care puzzle-ul n-are de ce s-o plătească, deci n-o atinge.
#
# Cuvintele sunt OAMENI (câmpul „om" din vocabular), nu orice din vocabular: un
# silogism are voie să vorbească despre stele care sunt corăbii, dar aici se
# povestește ceva, iar „în cetate sunt 12 stele și 9 cărți" nu se citește ca o
# poveste, se citește ca o greșeală de generator.
# ═════════════════════════════════════════════════════════════

## Trage cele trei cifre ale unei mulțimi: cât e fiecare grup și cât e
## suprapunerea. Intersecția e strict mai mică decât grupul mic — altfel una din
## mulțimi ar fi cuprinsă în cealaltă, iar „numai una" ar da zero.
func _cifrele_multimii() -> Array:
	var a := randi_range(7, 12)
	var b := randi_range(5, 9)
	var i := randi_range(2, mini(4, b - 1))
	return [a, b, i]


## NIVEL I — reuniunea. Suma minus suprapunerea, numărată o dată.
func _multimi_reuniune() -> Dictionary:
	var c := _oameni_diferiti(2)
	var cifre := _cifrele_multimii()
	var a: int = cifre[0]
	var b: int = cifre[1]
	var i: int = cifre[2]
	var raspuns := a + b - i
	return _pachet_numeric(
		"In cetate sunt %d %s si %d %s.\n%d sunt si %s, si %s.\n\nCati sunt %s SAU %s?" % [
			a, c[0]["plural"], b, c[1]["plural"],
			i, c[0]["plural"], c[1]["plural"],
			c[0]["plural"], c[1]["plural"],
		],
		raspuns,
		[
			a + b,            # uitat să scadă suprapunerea
			a + b - 2 * i,    # scăzut-o de două ori
			a + b + i,        # adunat-o
			a, b, i,
		],
		"%d + %d - %d = %d" % [a, b, i, raspuns]
	)


## NIVEL II — drumul invers: se dă reuniunea, se cere suprapunerea.
func _multimi_intersectie() -> Dictionary:
	var c := _oameni_diferiti(2)
	var cifre := _cifrele_multimii()
	var a: int = cifre[0]
	var b: int = cifre[1]
	var raspuns: int = cifre[2]
	var reuniune := a + b - raspuns
	return _pachet_numeric(
		"In cetate sunt %d %s si %d %s.\n%d sunt %s sau %s.\n\nCati sunt si %s, si %s?" % [
			a, c[0]["plural"], b, c[1]["plural"],
			reuniune, c[0]["plural"], c[1]["plural"],
			c[0]["plural"], c[1]["plural"],
		],
		raspuns,
		[
			reuniune - a,     # scăzut doar un grup
			reuniune - b,
			a - b,
			a + b - reuniune + 1,
			a - raspuns, b - raspuns,
		],
		"%d + %d - %d = %d" % [a, b, reuniune, raspuns]
	)


## NIVEL III — câți au DOAR una din cele două. Suprapunerea se scade de două
## ori, o dată din fiecare grup, și ăsta e exact pasul care se uită.
func _multimi_doar_unul() -> Dictionary:
	var c := _oameni_diferiti(2)
	var cifre := _cifrele_multimii()
	var a: int = cifre[0]
	var b: int = cifre[1]
	var i: int = cifre[2]
	var raspuns := (a - i) + (b - i)
	return _pachet_numeric(
		"In cetate sunt %d %s si %d %s.\n%d sunt si %s, si %s.\n\nCati sunt doar %s sau doar %s?" % [
			a, c[0]["plural"], b, c[1]["plural"],
			i, c[0]["plural"], c[1]["plural"],
			c[0]["plural"], c[1]["plural"],
		],
		raspuns,
		[
			a + b - i,        # reuniunea: scăzut o singură dată
			a + b,
			a - i, b - i,
			i,
		],
		"(%d - %d) + (%d - %d) = %d" % [a, i, b, i, raspuns]
	)


## NIVEL III — câți nu sunt NICIUNA din cele două. Trei pași: reuniunea, apoi
## scăderea din tot. Cifrele sunt mai mici decât la celelalte tipare, fiindcă
## aici mai există un număr deasupra lor — totalul — și el trebuie să rămână
## sub 20.
func _multimi_niciuna() -> Dictionary:
	var c := _oameni_diferiti(2)
	var a := randi_range(5, 8)
	var b := randi_range(4, 6)
	var i := randi_range(2, mini(3, b - 1))
	var reuniune := a + b - i
	var total := randi_range(reuniune + 2, 19)
	var raspuns := total - reuniune
	return _pachet_numeric(
		"In cetate sunt %d oameni.\n%d sunt %s, %d sunt %s.\n%d sunt si %s, si %s.\n\nCati nu sunt nici %s, nici %s?" % [
			total,
			a, c[0]["plural"], b, c[1]["plural"],
			i, c[0]["plural"], c[1]["plural"],
			c[0]["plural"], c[1]["plural"],
		],
		raspuns,
		[
			total - a - b,        # uitat să adune suprapunerea înapoi
			total - a - b + 2 * i,
			total - a, total - b,
			reuniune, i,
		],
		"%d - (%d + %d - %d) = %d" % [total, a, b, i, raspuns]
	)


# ═════════════════════════════════════════════════════════════
# CEL MAI RĂU CAZ — principiul sertarelor
#
# Întrebarea nu e „câte ai șanse să nimerești", e „câte trebuie ca să NU mai
# depinzi de noroc". Răspunsul vine dintr-o singură idee: presupune că norocul
# e împotriva ta până la ultima clipă posibilă, apoi mai adaugă unul.
#
# De-aia explicația spune întotdeauna care grup „poate ieși tot primul": asta e
# ideea, iar odată văzută o dată se poate aplica la toate cele patru tipare.
# ═════════════════════════════════════════════════════════════

## NIVEL I — două grupuri, vrei unul de un anumit fel.
func _certitudine_unul() -> Dictionary:
	var c := _oameni_diferiti(2)
	var marimi := [randi_range(4, 9), randi_range(3, 8)]
	var tinta := randi_range(0, 1)
	var ceilalti: int = marimi[1 - tinta]
	var raspuns := ceilalti + 1
	return _pachet_numeric(
		"La poarta stau %d %s si %d %s.\n\nPe cati trebuie sa chemi, la nimereala, ca sa fii sigur ca ai chemat %s %s?" % [
			marimi[0], c[0]["plural"], marimi[1], c[1]["plural"],
			_articol(c[tinta]), c[tinta]["singular"],
		],
		raspuns,
		[
			ceilalti,                        # uitat „plus unul"
			int(marimi[tinta]) + 1,          # numărat grupul greșit
			int(marimi[0]) + int(marimi[1]),
			int(marimi[0]) + int(marimi[1]) - 1,
			1, 2,
		],
		"CEI %d %s POT IESI TOTI PRIMII" % [ceilalti, c[1 - tinta]["plural"].to_upper()]
	)


## NIVEL II — trei grupuri. Aceeași idee, dar „ceilalți" nu mai e un număr din
## enunț, trebuie adunat.
func _certitudine_trei_grupe() -> Dictionary:
	var c := _oameni_diferiti(3)
	var marimi := [randi_range(3, 7), randi_range(3, 7), randi_range(3, 7)]
	var tinta := randi_range(0, 2)
	var total: int = int(marimi[0]) + int(marimi[1]) + int(marimi[2])
	var ceilalti: int = total - int(marimi[tinta])
	var raspuns := ceilalti + 1
	return _pachet_numeric(
		"La poarta stau %d %s, %d %s si %d %s.\n\nPe cati trebuie sa chemi, la nimereala, ca sa fii sigur ca ai chemat %s %s?" % [
			marimi[0], c[0]["plural"], marimi[1], c[1]["plural"], marimi[2], c[2]["plural"],
			_articol(c[tinta]), c[tinta]["singular"],
		],
		raspuns,
		[
			ceilalti,
			total, total - 1,
			int(marimi[tinta]) + 1,
			raspuns + 1,
		],
		"CEI %d CARE NU SUNT %s POT IESI TOTI PRIMII" % [ceilalti, c[tinta]["plural"].to_upper()]
	)


## NIVELURILE II-III — vrei DOI de același fel. „Plus unul" devine „plus doi",
## și exact acolo se greșește.
func _certitudine_doi() -> Dictionary:
	var c := _oameni_diferiti(2)
	var marimi := [randi_range(4, 9), randi_range(3, 8)]
	var tinta := randi_range(0, 1)
	var ceilalti: int = marimi[1 - tinta]
	var raspuns := ceilalti + 2
	return _pachet_numeric(
		"La poarta stau %d %s si %d %s.\n\nPe cati trebuie sa chemi, la nimereala, ca sa fii sigur ca ai chemat %s %s?" % [
			marimi[0], c[0]["plural"], marimi[1], c[1]["plural"],
			_doi(c[tinta]), c[tinta]["plural"],
		],
		raspuns,
		[
			ceilalti + 1,                    # răspunsul la „unul"
			ceilalti,
			int(marimi[tinta]) + 2,
			int(marimi[0]) + int(marimi[1]),
			2,
		],
		"CEI %d %s, PLUS DOI" % [ceilalti, c[1 - tinta]["plural"].to_upper()]
	)


## NIVEL III — vrei câte unul din FIECARE fel. Cel mai rău caz nu mai e grupul
## celălalt, e grupul CEL MAI MARE: el poate ieși întreg înainte de primul om
## din celălalt.
func _certitudine_din_fiecare() -> Dictionary:
	var c := _oameni_diferiti(2)
	var a := randi_range(4, 9)
	var b := randi_range(3, 8)
	var raspuns := maxi(a, b) + 1
	return _pachet_numeric(
		"La poarta stau %d %s si %d %s.\n\nPe cati trebuie sa chemi, la nimereala, ca sa fii sigur ca ai chemat si %s %s, si %s %s?" % [
			a, c[0]["plural"], b, c[1]["plural"],
			_articol(c[0]), c[0]["singular"], _articol(c[1]), c[1]["singular"],
		],
		raspuns,
		[
			mini(a, b) + 1,   # grupul mic, nu cel mare
			maxi(a, b),
			a + b, a + b - 1,
			2,
		],
		"GRUPUL MARE, DE %d, POATE IESI TOT PRIMUL" % maxi(a, b)
	)


# ═════════════════════════════════════════════════════════════
# CALENDAR — roata săptămânii
#
# Singurul tip cu deducție CICLICĂ, și de-aia merită un loc al lui: greșeala
# tipică nu e un pas în plus sau în minus, e un pas în DIRECȚIA greșită. „Dacă
# ieri a fost marți" te pune să te întorci înainte să pornești, iar
# întrebarea „ce zi va fi peste 5 zile" te face să treci peste duminică fără să
# te oprești.
#
# De-aia prima variantă greșită e întotdeauna aceeași: ziua la care ajungi dacă
# numeri exact atâtea zile, dar în partea cealaltă.
# ═════════════════════════════════════════════════════════════

# Ordinea săptămânii. Stă în COD, nu în `logica_categorii.json`, deși există
# acolo o categorie „zilele saptamanii" — fiindcă acolo zilele sunt o LISTĂ
# (intrusul și analogia nu au nevoie de ordinea lor), iar aici ordinea e tot
# conținutul. Un fișier de date nu poate promite o ordine; un const poate.
const ZILE := ["luni", "marti", "miercuri", "joi", "vineri", "sambata", "duminica"]

# Cum se numesc zilele din jurul lui azi. Peste ±2 nu mai există cuvânt în
# românește, deci se scrie „peste 4 zile" / „acum 4 zile".
const CAND := {-2: "alaltaieri", -1: "ieri", 0: "azi", 1: "maine", 2: "poimaine"}


func _cand(decalaj: int) -> String:
	if CAND.has(decalaj):
		return CAND[decalaj]
	if decalaj > 0:
		return "peste %d zile" % decalaj
	return "acum %d zile" % -decalaj


## Verbul se potrivește cu momentul: trecut, prezent sau viitor.
func _a_fi(decalaj: int) -> String:
	if decalaj < 0:
		return "a fost"
	if decalaj == 0:
		return "e"
	return "va fi"


## „1 ZI" / „5 ZILE". Un rând de explicație nu e locul în care se vede un acord
## greșit — e singurul rând pe care-l citești DUPĂ ce ai aflat că ai greșit.
func _zile(cate: int) -> String:
	return "1 ZI" if cate == 1 else "%d ZILE" % cate


## Ziua, cu majusculă. Pe un buton „Joi" se citește mai bine decât „joi", iar în
## enunț zilele rămân cu literă mică, cum se scriu în românește.
func _zi(indice: int) -> String:
	var nume: String = ZILE[posmod(indice, 7)]
	return nume.substr(0, 1).to_upper() + nume.substr(1)


## Enunțul leagă două momente: la `ancora` se știe ziua, la `tinta` se cere.
## Amândouă sunt decalaje față de „azi", deci unul singur poate fi și negativ,
## și pozitiv — de-aia nu există două funcții, „înainte" și „înapoi".
func _calendar(ancora: int, tinta: int) -> Dictionary:
	var de_la := randi_range(0, 6)
	var pana_la := posmod(de_la - ancora + tinta, 7)
	var raspuns := _zi(pana_la)

	var candidati: Array = [
		_zi(de_la + ancora - tinta),   # numărat în sensul greșit
		_zi(de_la),                    # ziua din enunț, nemișcată
		_zi(pana_la + 1),
		_zi(pana_la - 1),
	]
	var gresite: Array = []
	for zi in candidati:
		if String(zi) != raspuns and not (zi in gresite):
			gresite.append(zi)
	# Plasă: dacă pașii s-au suprapus (șiruri scurte, decalaje mici), completăm
	# cu alte zile, ca să nu rămână un buton gol.
	for i in range(7):
		if gresite.size() >= 3:
			break
		var alta := _zi(i)
		if alta != raspuns and not (alta in gresite):
			gresite.append(alta)

	return _pachet(
		"Daca %s %s %s, ce zi %s %s?" % [
			_cand(ancora), _a_fi(ancora), ZILE[de_la], _a_fi(tinta), _cand(tinta)
		],
		raspuns,
		gresite.slice(0, 3),
		"DE LA %s, %s %s" % [
			ZILE[de_la].to_upper(),
			_zile(absi(tinta - ancora)),
			"INAINTE" if tinta > ancora else "INAPOI",
		]
	)


## NIVEL I — ieri, azi, mâine. Un pas sau doi, toate cu nume.
func _calendar_aproape() -> Dictionary:
	var doua := _indici(3, 2)
	return _calendar(int(doua[0]) - 1, int(doua[1]) - 1)


## NIVEL II — enunțul rămâne în jurul lui azi, dar ținta sare peste duminică.
func _calendar_departe() -> Dictionary:
	var tinta := randi_range(3, 4)
	if randf() < 0.5:
		tinta = -tinta
	return _calendar(randi_range(-2, 2), tinta)


## NIVEL III — enunțul vorbește despre VIITOR, întrebarea despre TRECUT. Două
## sensuri în același puzzle, deci nu mai poți număra dintr-un singur elan.
func _calendar_inapoi() -> Dictionary:
	var ancora := randi_range(4, 6)
	var tinta := -randi_range(1, 3)
	# O distanță de exact o săptămână ar da drept răspuns chiar ziua din enunț:
	# corect, dar degenerat — și ar transforma capcana „ziua nemișcată" în
	# răspunsul bun.
	while posmod(tinta - ancora, 7) == 0:
		tinta = -randi_range(1, 3)
	return _calendar(ancora, tinta)


# ═════════════════════════════════════════════════════════════
# LOCURILE — cine stă pe al câtelea loc
#
# E rudă cu ORDONARE, dar nu e aceeași unealtă, și merită spus limpede, fiindcă
# altfel e exact tipul pe care cineva l-ar șterge ca duplicat:
#
#   ORDONARE primește un LANȚ de comparații între vecini („A e mai înalt decât
#   B, B decât C"). Lanțul determină singur toată ordinea, deci se rezolvă
#   citind, într-un singur sens, fără să încerci nimic.
#
#   LOCURILE primește capete („stă la capătul din dreapta"), vecinătăți („stă
#   imediat la stânga lui"), intervale („stă între") și NEGAȚII („nu stă lângă").
#   Nimic nu se citește direct: se taie posibilități până rămâne una. Ăsta e
#   alt mușchi — eliminarea, nu urmărirea.
#
# Indiciile sunt de șase feluri, fiecare o întrebare DA/NU despre o așezare,
# deci verificabilă mecanic. Cele șase se dau pe niveluri: la I numai cele care
# spun ceva POZITIV, la II și III și cele care taie.
# ═════════════════════════════════════════════════════════════

const INDICII_ASEZARE_SIMPLE := ["IMEDIAT", "STANGA", "CAPAT_ST", "CAPAT_DR"]
const INDICII_ASEZARE_TOATE := ["IMEDIAT", "STANGA", "CAPAT_ST", "CAPAT_DR", "INTRE", "NU_LANGA"]

# Câte indicii se adună, cel mult. NU e o limită de corectitudine — enigma e
# oricum păstrată doar dacă răspunsul iese determinat. E o limită de CITIT: un
# enunț de șase rânduri nu se mai termină sub cronometru, oricât de corect ar
# fi, iar un puzzle pe care nu l-ai citit nu e un puzzle greu, e unul nejucat.
const MAX_INDICII := 4

# De câte ori se încearcă tragerea unui indiciu ADEVĂRAT despre situația
# ascunsă. Se trage la întâmplare și se verifică, în loc să se construiască
# dinadins: un indiciu construit ar fi fost un indiciu pe care generatorul îl
# știe adevărat fără să-l fi probat vreodată.
const INCERCARI_INDICIU := 30

# Dintre câte indicii se alege, la fiecare pas, cel mai tăios. Vezi
# `_cel_mai_taios`: numărul ăsta e diferența dintre un tip care apare cât
# trebuie și unul care apare de zece ori mai rar.
const CANDIDATI_INDICIU := 8


## Cel mai TĂIOS indiciu dintre câteva trase la întâmplare: cel care lasă cele
## mai puține situații în picioare.
##
## DE CE NU PRIMUL CARE IESE. Așa a fost scris întâi, și verificarea l-a prins
## din prima rulare: la cinci inși, 91% din enigme nu ajungeau niciodată la un
## răspuns determinat, deci tipul apărea de zece ori mai rar decât ar fi trebuit
## (57 de trageri din 600 așteptate, la nivelul III) — fără nicio eroare
## nicăieri, fiindcă `_compune_intrebare` alegea liniștit altă rețetă. Un
## indiciu tras la noroc e de obicei moale: „X sta undeva la stanga lui Y" taie
## jumătate din 120 de așezări și nu te duce nicăieri.
##
## Alegând dintre opt, enigma se închide în două-trei indicii în loc de cinci.
## Și asta nu e doar o rată mai bună, e și un enunț mai SCURT — adică exact
## invers de cum ar fi ieșit dacă aș fi ridicat doar plafonul de indicii.
##
## `tine` e funcția care spune dacă un indiciu e adevărat despre o situație.
## Funcția de aici nu știe dacă situațiile sunt așezări sau împerecheri, și nici
## nu are de ce: de-aia o primește, în loc s-o aleagă cu un `if`.
static func _cel_mai_taios(situatii: Array, candidati: Array, tine: Callable) -> Dictionary:
	var cel_mai_bun := {}
	# Situația ascunsă supraviețuiește oricărui indiciu adevărat, deci orice
	# candidat lasă cel puțin una. Pornim de la „mai multe decât toate".
	var minim := situatii.size() + 1
	for candidat in candidati:
		var ramase := 0
		for situatie in situatii:
			if tine.call(candidat, situatie):
				ramase += 1
		if ramase < minim:
			minim = ramase
			cel_mai_bun = candidat
	return cel_mai_bun


## Indiciul e adevărat despre așezarea dată? `locuri[om]` = pozitia lui, de la 0.
static func _asezare_tine(indiciu: Dictionary, locuri: Array, cati: int) -> bool:
	var a: int = locuri[indiciu["a"]]
	var b: int = locuri[indiciu["b"]]
	match indiciu["t"]:
		"IMEDIAT":
			return b == a + 1
		"STANGA":
			return a < b
		"CAPAT_ST":
			return a == 0
		"CAPAT_DR":
			return a == cati - 1
		"NU_LANGA":
			return absi(a - b) != 1
		"INTRE":
			var c: int = locuri[indiciu["c"]]
			return (b < a and a < c) or (c < a and a < b)
	return false


## Toate așezările care se împacă cu indiciile.
static func _solutii_asezare(indicii: Array, cati: int) -> Array:
	var solutii: Array = []
	for candidat in _permutari(cati):
		var bun := true
		for indiciu in indicii:
			if not _asezare_tine(indiciu, candidat, cati):
				bun = false
				break
		if bun:
			solutii.append(candidat)
	return solutii


## Un indiciu adevărat despre `locuri`, tras la întâmplare dintre `feluri`.
func _indiciu_asezare(locuri: Array, cati: int, feluri: Array, loc_intrebat: int) -> Dictionary:
	for incercare in range(INCERCARI_INDICIU):
		var fel := String(feluri.pick_random())
		# Un indiciu care spune direct cine stă pe locul întrebat ar fi un
		# răspuns, nu un indiciu.
		if fel == "CAPAT_ST" and loc_intrebat == 0:
			continue
		if fel == "CAPAT_DR" and loc_intrebat == cati - 1:
			continue

		var trei := _indici(cati, 3)
		var indiciu := {"t": fel, "a": trei[0], "b": trei[1], "c": trei[2]}
		if _asezare_tine(indiciu, locuri, cati):
			return indiciu
	return {}


## Trage o așezare ascunsă și atâtea indicii cât îi trebuie ca LOCUL ÎNTREBAT să
## iasă același în toate soluțiile. Gol dacă nu reușește în `MAX_INDICII`.
## Taie indiciile de prisos: dacă răspunsul rămâne determinat și fără unul, el
## n-a adus nimic în afară de un rând de citit.
##
## DE CE NU SE POATE EVITA DIN CONSTRUCȚIE. Alegerea lacomă pune indicii până
## când răspunsul se închide, iar pe drum poate pune unul care devine de prisos
## DUPĂ ce vine următorul: „Grigore are arc sau pumnal" taie mult la început și
## nu mai spune nimic odată ce se află ce are Anton. Un generator n-are cum să
## știe asta în avans — dar poate verifica la sfârșit, și costă cinci rezolvări.
##
## Se umblă de la capăt spre început dinadins: scoțând elementul `i`, cele de
## dinaintea lui își păstrează indicii, deci lista poate să se scurteze sub
## picioarele buclei fără ca ea să sară peste nimic.
##
## `rezolva` primește o listă de indicii și întoarce situațiile care se împacă
## cu ele; `extrage` scoate răspunsul dintr-o situație. Cu amândouă primite,
## funcția nu știe dacă taie indicii despre locuri sau despre lucruri.
static func _taie_de_prisos(indicii: Array, rezolva: Callable, extrage: Callable) -> Array:
	var pastrate := indicii.duplicate()
	var i := pastrate.size() - 1
	while i >= 0:
		if pastrate.size() > 1:
			var incercare := pastrate.duplicate()
			incercare.remove_at(i)
			if _acelasi_raspuns(rezolva.call(incercare), extrage) >= 0:
				pastrate = incercare
		i -= 1
	return pastrate


## Cheia unui indiciu de așezare, pentru a nu-l da de două ori. TEXT, nu
## dicționarul însuși: așa nu depinde de felul în care Godot compară două
## dicționare — un amănunt de limbaj care n-are ce căuta într-un generator.
static func _cheia_asezare(indiciu: Dictionary) -> String:
	return "%s:%d:%d:%d" % [indiciu["t"], indiciu["a"], indiciu["b"], indiciu["c"]]


static func _filtreaza_asezare(situatii: Array, indiciu: Dictionary, cati: int) -> Array:
	var ramase: Array = []
	for situatie in situatii:
		if _asezare_tine(indiciu, situatie, cati):
			ramase.append(situatie)
	return ramase


func _enigma_asezare(cati: int, feluri: Array) -> Dictionary:
	var nume := _nume(cati)
	var locuri := range(cati)
	locuri.shuffle()                            # locuri[om] = pozitia lui
	var loc_intrebat := randi_range(0, cati - 1)

	var indicii: Array = []
	var vazute := {}
	# Toate așezările, la început; fiecare indiciu taie din ele. Treptat, nu de
	# la zero la fiecare pas: altfel aceleași 120 de permutări s-ar verifica de
	# cinci ori, iar alegerea lacomă de mai jos le-ar verifica de patruzeci.
	var situatii := _permutari(cati)

	for pas in range(MAX_INDICII):
		var candidati: Array = []
		var vazute_acum := {}
		for i in range(CANDIDATI_INDICIU):
			var candidat := _indiciu_asezare(locuri, cati, feluri, loc_intrebat)
			if candidat.is_empty():
				continue
			var cheie_candidat := _cheia_asezare(candidat)
			if vazute.has(cheie_candidat) or vazute_acum.has(cheie_candidat):
				continue
			vazute_acum[cheie_candidat] = true
			candidati.append(candidat)
		if candidati.is_empty():
			break

		var indiciu := _cel_mai_taios(
			situatii, candidati, func(ind, sit): return _asezare_tine(ind, sit, cati)
		)
		if indiciu.is_empty():
			break
		vazute[_cheia_asezare(indiciu)] = true
		indicii.append(indiciu)
		situatii = _filtreaza_asezare(situatii, indiciu, cati)

		var extrage := func(s): return s.find(loc_intrebat)
		var cine := _acelasi_raspuns(situatii, extrage)
		if cine >= 0:
			var scurte := _taie_de_prisos(
				indicii, func(lista): return _solutii_asezare(lista, cati), extrage
			)
			# `unica` se recalculează: cu un indiciu mai puțin, așezarea poate să
			# nu mai fie determinată întreagă, chiar dacă locul întrebat e.
			# Explicația se uită la steagul ăsta ca să nu pretindă mai mult.
			var finale := _solutii_asezare(scurte, cati)
			return {
				"nume": nume, "indicii": scurte, "locuri": locuri,
				"loc": loc_intrebat, "cine": cine, "unica": finale.size() == 1,
			}
	return {}


## Primul rând al enunțului: cine stă și pe ce locuri.
##
## DE CE EXISTĂ. Indiciile se trag la întâmplare, deci un ins poate să nu apară
## în niciunul — iar la cinci inși butoanele arată doar patru nume. Fără rândul
## ăsta, cititorul n-are de unde ști nici câți sunt, nici cine, nici că locul 1
## e cel din stânga, și întrebarea devine nedreaptă: răspunsul e determinat
## pentru rezolvitorul care cunoaște distribuția, nu pentru cel care o citește.
##
## La DEDUCTIE și la MINCINOSI nu trebuie: acolo forma enunțului îi aduce pe
## toți de la sine — un lanț de comparații îi atinge pe toți, iar fiecare
## mincinos are replica lui.
##
## Numele se înșiră alfabetic, dintr-o COPIE: `nume` se citește peste tot prin
## indice (`nume[indiciu["a"]]`), deci sortarea originalului ar muta oamenii
## între ei.
func _scena_asezare(nume: Array) -> String:
	var cine: Array = nume.duplicate()
	cine.sort()
	return "%s stau pe locurile 1-%d, de la stanga la dreapta." % [
		_insir(cine, "si"), nume.size()
	]


func _text_indiciu_asezare(indiciu: Dictionary, nume: Array) -> String:
	var a: String = nume[indiciu["a"]]
	var b: String = nume[indiciu["b"]]
	match indiciu["t"]:
		"IMEDIAT":
			return "%s sta imediat la stanga lui %s." % [a, b]
		"STANGA":
			return "%s sta undeva la stanga lui %s." % [a, b]
		"CAPAT_ST":
			return "%s sta la capatul din stanga." % a
		"CAPAT_DR":
			return "%s sta la capatul din dreapta." % a
		"NU_LANGA":
			return "%s nu sta langa %s." % [a, b]
		"INTRE":
			return "%s sta intre %s si %s." % [a, b, nume[indiciu["c"]]]
	return ""


## Dacă indiciile au determinat TOATĂ așezarea, explicația o arată întreagă — e
## cea mai bună explicație posibilă. Dacă au determinat doar locul întrebat
## (ceea ce e de ajuns, vezi `_acelasi_raspuns`), se spune exact atât. O
## explicație n-are voie să pretindă mai mult decât s-a dedus.
func _explicatie_asezare(enigma: Dictionary) -> String:
	var nume: Array = enigma["nume"]
	if not bool(enigma["unica"]):
		return "PE LOCUL %d NU POATE STA ALTCINEVA" % (int(enigma["loc"]) + 1)

	var locuri: Array = enigma["locuri"]
	var in_ordine: Array[String] = []
	in_ordine.resize(nume.size())
	for om in range(nume.size()):
		in_ordine[locuri[om]] = String(nume[om])
	return "DE LA STANGA: %s" % " - ".join(in_ordine).to_upper()


func _asezare(cati: int, feluri: Array) -> Dictionary:
	var enigma := _enigma_asezare(cati, feluri)
	if enigma.is_empty():
		return {}

	var nume: Array = enigma["nume"]
	var rand: Array[String] = [_scena_asezare(nume)]
	for indiciu in enigma["indicii"]:
		rand.append(_text_indiciu_asezare(indiciu, nume))
	var raspuns := String(nume[enigma["cine"]])

	# Variantele sunt chiar oamenii din enunț: orice alt nume s-ar elimina
	# singur. La cinci inși ținem patru, cu răspunsul printre ei — aceeași
	# regulă ca la ORDONARE.
	var variante: Array = nume.duplicate()
	variante.shuffle()
	if variante.size() > 4:
		variante.erase(raspuns)
		variante = variante.slice(0, 3)
		variante.append(raspuns)

	var gresite: Array = []
	for varianta in variante:
		if String(varianta) != raspuns:
			gresite.append(String(varianta))

	return _pachet(
		"%s\n\nCine sta pe locul %d?" % ["\n".join(rand), int(enigma["loc"]) + 1],
		raspuns,
		gresite,
		_explicatie_asezare(enigma)
	)


## NIVEL I — patru inși, numai indicii care spun ceva pozitiv.
func _asezare_simpla() -> Dictionary:
	return _asezare(4, INDICII_ASEZARE_SIMPLE)


## NIVEL II — tot patru, dar intră „intre" și „nu langa", deci se taie.
func _asezare_grea() -> Dictionary:
	return _asezare(4, INDICII_ASEZARE_TOATE)


## NIVEL III — cinci inși. 120 de așezări posibile în loc de 24.
func _asezare_cinci() -> Dictionary:
	return _asezare(5, INDICII_ASEZARE_TOATE)


# ═════════════════════════════════════════════════════════════
# POTRIVIRE — cine are ce
#
# Grila clasică de logică, la scara la care încape pe un ecran: trei sau patru
# oameni, atâtea lucruri, fiecare cu altul, și câteva indicii din care se
# deduce împerecherea.
#
# Indiciile sunt de trei feluri, și toate trei sunt NEGATIVE sau PARȚIALE:
#   NU   — „Anton nu are spada."
#   SAU  — „Anton are spada sau scut."
#   NICI — „Anton nu are nici spada, nici scut."
# Un indiciu pozitiv („Anton are spada") ar fi fost jumătate de răspuns dat pe
# gratis la o grilă de trei.
#
# Ca și la locuri, se cere doar ca RĂSPUNSUL să fie determinat, nu toată grila.
# La o grilă de patru, unicitatea întreagă ar fi cerut cinci indicii (24 de
# împerecheri, iar cel mai informativ indiciu taie jumătate); determinarea unui
# singur rând cere două sau trei.
# ═════════════════════════════════════════════════════════════

# Lucrurile care se împart între oameni. Stau în COD, nu în
# `logica_categorii.json`, din exact motivul pentru care stau în cod numele:
# aici nu sunt conținut, sunt schelăria unui tip pur generativ.
#
# Categoriile din fișier n-ar fi mers, și asta e singurul lucru care merită
# ținut minte dacă cineva vrea mai târziu să le lege: jumătate din ele sunt
# NOȚIUNI („zilele saptamanii", „operatii aritmetice", „stari de agregare"),
# iar „Anton nu are luni" nu e o propoziție. Toate de aici sunt lucruri care se
# POT avea, și toate fără articol, ca indiciile să se citească la fel: „Anton nu
# are nici spada, nici scut."
const LUCRURI := [
	"spada", "scut", "arc", "coif", "pumnal",
	"lance", "topor", "arbaleta", "pavaza", "buzdugan",
]

const INDICII_POTRIVIRE_SIMPLE := ["NU", "SAU"]
const INDICII_POTRIVIRE_TOATE := ["NU", "SAU", "NICI"]


## Indiciul e adevărat despre împerecherea dată? `atribuire[om]` = lucrul lui.
static func _potrivire_tine(indiciu: Dictionary, atribuire: Array) -> bool:
	var al_lui: int = atribuire[indiciu["om"]]
	match indiciu["t"]:
		"NU":
			return al_lui != indiciu["a"]
		"SAU":
			return al_lui == indiciu["a"] or al_lui == indiciu["b"]
		"NICI":
			return al_lui != indiciu["a"] and al_lui != indiciu["b"]
	return false


static func _solutii_potrivire(indicii: Array, cati: int) -> Array:
	var solutii: Array = []
	for candidat in _permutari(cati):
		var bun := true
		for indiciu in indicii:
			if not _potrivire_tine(indiciu, candidat):
				bun = false
				break
		if bun:
			solutii.append(candidat)
	return solutii


func _indiciu_potrivire(atribuire: Array, cati: int, feluri: Array) -> Dictionary:
	for incercare in range(INCERCARI_INDICIU):
		var doua := _indici(cati, 2)
		var indiciu := {
			"t": String(feluri.pick_random()),
			"om": randi_range(0, cati - 1),
			"a": doua[0],
			"b": doua[1],
		}
		if _potrivire_tine(indiciu, atribuire):
			return indiciu
	return {}


## `pe_om` = true: întrebarea e „ce are Anton?". False: „cine are spada?".
## `intrebat` e, după caz, un om sau un lucru — de-aia e un singur câmp, nu doi.
static func _cheia_potrivire(indiciu: Dictionary) -> String:
	return "%s:%d:%d:%d" % [indiciu["t"], indiciu["om"], indiciu["a"], indiciu["b"]]


static func _filtreaza_potrivire(situatii: Array, indiciu: Dictionary) -> Array:
	var ramase: Array = []
	for situatie in situatii:
		if _potrivire_tine(indiciu, situatie):
			ramase.append(situatie)
	return ramase


func _enigma_potrivire(cati: int, feluri: Array, pe_om: bool) -> Dictionary:
	var nume := _nume(cati)
	# Patru lucruri întotdeauna, deși la o grilă de trei se împart doar trei:
	# al patrulea e rezerva din care se face a patra variantă de pe buton.
	var lucruri := _lucruri(4)
	var atribuire := range(cati)
	atribuire.shuffle()                         # atribuire[om] = indicele lucrului
	var intrebat := randi_range(0, cati - 1)

	var indicii: Array = []
	var vazute := {}
	var situatii := _permutari(cati)

	for pas in range(MAX_INDICII):
		var candidati: Array = []
		var vazute_acum := {}
		for i in range(CANDIDATI_INDICIU):
			var candidat := _indiciu_potrivire(atribuire, cati, feluri)
			if candidat.is_empty():
				continue
			var cheie_candidat := _cheia_potrivire(candidat)
			if vazute.has(cheie_candidat) or vazute_acum.has(cheie_candidat):
				continue
			vazute_acum[cheie_candidat] = true
			candidati.append(candidat)
		if candidati.is_empty():
			break

		var indiciu := _cel_mai_taios(
			situatii, candidati, func(ind, sit): return _potrivire_tine(ind, sit)
		)
		if indiciu.is_empty():
			break
		vazute[_cheia_potrivire(indiciu)] = true
		indicii.append(indiciu)
		situatii = _filtreaza_potrivire(situatii, indiciu)

		var extrage := (
			func(s): return s[intrebat]
		) if pe_om else (
			func(s): return s.find(intrebat)
		)
		var raspuns := _acelasi_raspuns(situatii, extrage)
		if raspuns >= 0:
			var scurte := _taie_de_prisos(
				indicii, func(lista): return _solutii_potrivire(lista, cati), extrage
			)
			var finale := _solutii_potrivire(scurte, cati)
			return {
				"nume": nume, "lucruri": lucruri, "indicii": scurte,
				"atribuire": atribuire, "pe_om": pe_om, "intrebat": intrebat,
				"raspuns": raspuns, "unica": finale.size() == 1,
			}
	return {}


## Primul rând al enunțului: cine joacă și care sunt lucrurile. Vezi
## `_scena_asezare` pentru de ce — aici lipsa era și mai gravă, fiindcă se
## ascundea nu doar distribuția, ci și RECUZITA: din „Luca nu are pumnal" plus
## „Anton are coif" nu rezultă ce are Luca decât dacă știi că în joc sunt exact
## trei lucruri și care sunt ele.
##
## Al patrulea buton de la grila de trei rămâne un lucru din AFARA listei, și
## asta e acum o alegere, nu o scăpare: cine citește primul rând îl taie din
## ochi. Plata pentru un răspuns determinat la nivelul I e o ghicire din trei
## în loc de una din patru — mai ieftină decât o întrebare cu două răspunsuri.
func _scena_potrivire(nume: Array, lucruri: Array, cati: int) -> String:
	var cine: Array = nume.duplicate()
	cine.sort()
	var ale_lor: Array = lucruri.slice(0, cati)
	ale_lor.sort()
	return "%s au, fiecare, alt lucru: %s." % [
		_insir(cine, "si"), _insir(ale_lor, "sau")
	]


func _text_indiciu_potrivire(indiciu: Dictionary, nume: Array, lucruri: Array) -> String:
	var om: String = nume[indiciu["om"]]
	match indiciu["t"]:
		"NU":
			return "%s nu are %s." % [om, lucruri[indiciu["a"]]]
		"SAU":
			return "%s are %s sau %s." % [om, lucruri[indiciu["a"]], lucruri[indiciu["b"]]]
		"NICI":
			return "%s nu are nici %s, nici %s." % [om, lucruri[indiciu["a"]], lucruri[indiciu["b"]]]
	return ""


## Ca la locuri: grila întreagă dacă s-a determinat, altfel numai rândul cerut.
func _explicatie_potrivire(enigma: Dictionary) -> String:
	var nume: Array = enigma["nume"]
	var lucruri: Array = enigma["lucruri"]
	var atribuire: Array = enigma["atribuire"]

	if not bool(enigma["unica"]):
		if bool(enigma["pe_om"]):
			return "%s NU POATE AVEA ALTCEVA" % String(nume[enigma["intrebat"]]).to_upper()
		# Scris cu omul in fata, nu cu lucrul: „pavaza nu poate fi AL altcuiva" ar
		# fi cerut un acord dupa genul lucrului, iar lista are si masculine, si
		# feminine. Propozitia asta nu are gen.
		return "%s E SINGURUL CARE POATE AVEA %s" % [
			String(nume[enigma["raspuns"]]).to_upper(),
			String(lucruri[enigma["intrebat"]]).to_upper(),
		]

	var bucati: Array[String] = []
	for om in range(nume.size()):
		bucati.append("%s - %s" % [String(nume[om]), String(lucruri[atribuire[om]])])
	return ", ".join(bucati).to_upper()


func _potrivire(cati: int, feluri: Array, pe_om: bool) -> Dictionary:
	var enigma := _enigma_potrivire(cati, feluri, pe_om)
	if enigma.is_empty():
		return {}

	var nume: Array = enigma["nume"]
	var lucruri: Array = enigma["lucruri"]
	var rand: Array[String] = [_scena_potrivire(nume, lucruri, cati)]
	for indiciu in enigma["indicii"]:
		rand.append(_text_indiciu_potrivire(indiciu, nume, lucruri))

	var intrebare := ""
	var raspuns := ""
	var variante: Array = []

	if bool(enigma["pe_om"]):
		intrebare = "Ce are %s?" % String(nume[enigma["intrebat"]])
		raspuns = String(lucruri[enigma["raspuns"]])
		# Variantele sunt lucrurile împărțite, plus rezerva la o grilă de trei:
		# fără ea, al patrulea buton ar fi rămas gol.
		for i in range(maxi(cati, 4)):
			variante.append(String(lucruri[i]))
	else:
		intrebare = "Cine are %s?" % String(lucruri[enigma["intrebat"]])
		raspuns = String(nume[enigma["raspuns"]])
		for n in nume:
			variante.append(String(n))

	var gresite: Array = []
	for varianta in variante:
		if String(varianta) != raspuns:
			gresite.append(String(varianta))

	return _pachet(
		"%s\n\n%s" % ["\n".join(rand), intrebare],
		raspuns,
		gresite,
		_explicatie_potrivire(enigma)
	)


## NIVEL I — trei oameni, trei lucruri, indicii simple. „Ce are Anton?"
func _potrivire_trei() -> Dictionary:
	return _potrivire(3, INDICII_POTRIVIRE_SIMPLE, true)


## NIVEL II — patru oameni, patru lucruri. Tot „ce are Anton?", dar grila s-a
## mărit de la 6 împerecheri posibile la 24.
##
## Primește și indiciile „nici…, nici…", deși la nivelul I nu există: la 24 de
## împerecheri, un „nu are spada" taie un sfert, iar un „nici spada, nici scut"
## taie jumătate — cu numai indicii slabe, enunțul ajungea la cinci rânduri. Un
## indiciu mai TARE face enunțul mai SCURT, și de-aia nivelul II nu e aici „mai
## multe indicii", e „aceleași indicii pe o grilă mai mare".
func _potrivire_patru() -> Dictionary:
	return _potrivire(4, INDICII_POTRIVIRE_TOATE, true)


## NIVEL III — întrebarea se întoarce: nu „ce are Anton", ci „cine are spada".
## Același tablou, citit pe coloane în loc de pe rânduri — iar indiciile vorbesc
## toate despre oameni, deci niciunul nu e despre ce se întreabă.
func _potrivire_cine() -> Dictionary:
	return _potrivire(4, INDICII_POTRIVIRE_TOATE, false)

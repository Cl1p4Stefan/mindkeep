extends Control
## Puzzle de LOGICĂ — scenă complet independentă.
##
## Are EXACT același contract ca Trivia, ca lupta să nu simtă diferența:
##   1. `porneste(nivel, context, scurtare)` — CE PRIMEȘTE
##   2. `arata_stare(valoare, maxim)`        — bara laterală, neutră
##   3. `arata_combo(text, marcaj)`          — streak-ul, cât e întrebarea pe ecran
##   4. semnalul `rezolvat(succes)`          — CE RETURNEAZĂ
##
## Nu știe nimic despre luptă, PV, PA sau inamici. Poți s-o testezi singură
## cu F6, fără să treci prin luptă.
##
## DE UNDE VIN ÎNTREBĂRILE. Sunt două feluri de tipuri, și fiecare își ia
## materia primă de unde îi e mai ieftin:
##
##   PUR GENERATIVE (șirurile numerice) — nu au nevoie de niciun fișier.
##   Regula E conținutul: „adună 4 de fiecare dată" produce o infinitate de
##   întrebări din trei numere alese la întâmplare. Un fișier de date aici ar
##   fi fost muncă de scris pentru zero câștig.
##
##   ALIMENTATE CU DATE (analogiile, intrusul, silogismele) — au nevoie de
##   cunoștințe despre lume, iar cunoștințele nu se pot deduce. Ele citesc
##   din `data/logica_categorii.json` și `data/logica_vocabular.json`.
##
## Regula pentru fișiere: ca să adaugi conținut, editezi DOAR JSON-ul. Codul
## de mai jos nu conține niciun nume de categorie și niciun cuvânt din
## vocabular — lucrează pe ce găsește.

signal rezolvat(succes: bool)

# ─────────────────────────────────────────────────────────────
# REGULI
# Aceleași numere ca la Trivia, intenționat. Cronometrul e o promisiune
# făcută jucătorului: dacă fiecare disciplină ar avea alt ritm, ar trebui
# să reînveți presiunea de fiecare dată când schimbi Obeliscul.
# ─────────────────────────────────────────────────────────────
const TIMP_PE_NIVEL := [12.0, 12.0, 15.0]
const TIMP_MINIM := 8.0
const PRAG_URGENTA := 5.0

# VERDICTUL de după răspuns. Culorile sunt DELIBERAT aceleași cu ale butoanelor
# de răspuns: verdele de pe varianta corectă și roșul de pe cea greșită. Două
# nuanțe apropiate, dar diferite, ar fi arătat ca două informații; identice,
# se citesc ca una singură.
const CULOARE_VERDICT_BUN := Color(0.45, 1, 0.55)
const CULOARE_VERDICT_RAU := Color(1, 0.4, 0.4)

# Fade-ul verdictului. SCURT, nu lent: e informația după care te uiți imediat
# ce ai apăsat. Peste ~0.25 s ar începe să pară că jocul se gândește.
const DURATA_VERDICT := 0.18

# Culorile liniei de context: aurie TOT TIMPUL. Portocaliul nu mai e o stare
# în care poate sta linia, ci culoarea unui singur moment — cel marcat prin
# `arata_combo()`. O culoare care ține minute întregi nu mai anunță nimic;
# una care ține o clipă e un semnal.
const CULOARE_CONTEXT := Color(1, 0.83, 0.42)
const CULOARE_ACCENT := Color(1, 0.45, 0.2)

# FLASH-ul liniei de context: culoarea din vârful pulsului, cât ține revenirea
# și cât se umflă eticheta. Alb, fiindcă e mai aprins decât ORICE culoare de
# bază — pulsul se vede la fel de bine și pe auriu, și pe portocaliu.
const CULOARE_FLASH := Color(1, 1, 1)
const DURATA_FLASH := 0.26
const SCARA_FLASH := 1.45

# MARCAJUL: eticheta scurtă care fulgeră lângă linia de context (lupta trimite
# acolo „CRITIC!"). Scena nu știe ce înseamnă textul — știe doar să-l aprindă,
# să-l țină cât să-l citești și să-l stingă.
#   DURATA_MARCAJ — cât stă tot momentul pe ecran, aprindere inclusă
#   DURATA_APARITIE_MARCAJ — cât durează aprinderea (scurtă: e o tresărire)
#   DURATA_REVENIRE — cât durează întoarcerea la normal. Mai lentă decât
#     aprinderea: ce apare trebuie să te ia prin surprindere, ce dispare nu
#     trebuie să pară că a fost șters.
const DURATA_MARCAJ := 0.4
const DURATA_APARITIE_MARCAJ := 0.1
const DURATA_REVENIRE := 0.2

const PAUZA_FEEDBACK := 1.8

# Câți termeni se VĂD într-un șir. Generatoarele produc unul în plus: ultimul
# e răspunsul.
const TERMENI_VIZIBILI := 5

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
#     "articulat": "pisicile", "gen": "f" }
#
#   „Toate PISICILE sunt CORBI." → articulat + plural.  „Nicio PISICĂ nu e
#   CORB." → singular. „gen" alege între Toți/Toate și Niciun/Nicio.
#   Cuvintele n-au nevoie să aibă sens împreună — un silogism se rezolvă din
#   formă, nu din adevărul lumii. „Toate stelele sunt corăbii" e o premisă
#   perfect bună, și chiar mai bună: te împiedică să răspunzi din memorie.
# ─────────────────────────────────────────────────────────────
const CALE_CATEGORII := "res://data/logica_categorii.json"
const CALE_VOCABULAR := "res://data/logica_vocabular.json"

const MINIM_MEMBRI := 4

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de zeci de ori pe luptă; fără `static`, fișierele ar fi
# citite de pe disc de fiecare dată.
static var categorii: Array[Dictionary] = []
static var vocabular: Array[Dictionary] = []
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
#                un tip cu 3 tipare ar apărea de 3 ori mai des decât unul cu
#                unul singur, și ai juca aproape numai șiruri numerice.
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
# Fiecare metodă întoarce un Dictionary:
#   {"text": ce se afișează, "variante": 4 șiruri, "corect": indicele bun,
#    "explicatie": regula rezolvării, în cuvinte; azi nu se afișează nicăieri}
#
# ECHILIBRUL. Fiecare TIP trebuie să existe la toate cele trei niveluri, altfel
# la nivelul unde lipsește ceilalți se împart între ei toată probabilitatea.
# Când adaugi un tip nou, dă-i cel puțin un tipar pe fiecare nivel.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# ȘIRURI NUMERICE — pur generative.
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_pas_constant"},
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_factor_constant"},
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_pas_negativ"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_pas_crescator"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_alternant"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_pas_dublat"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_mixt"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_fibonacci"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "necesita": "", "metoda": "_patrate"},

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

	# DEDUCȚII DE ORDONARE — pur generative, ca și șirurile.
	{"tip": "DEDUCTIE", "niveluri": [1], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_in_ordine"},
	{"tip": "DEDUCTIE", "niveluri": [2], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_amestecata"},
	{"tip": "DEDUCTIE", "niveluri": [3], "categorie": "ORDONARE", "necesita": "", "metoda": "_deductie_lunga"},
]

# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
var timp_ramas := 0.0
var indice_corect := -1
var raspuns_dat := false   # ca un al doilea click să nu poată răspunde de două ori
var pornit := false        # a chemat cineva porneste()?
var explicatie := ""       # regula rezolvării; azi neafișată (vezi `_termina`)

@onready var eticheta_categorie: Label = %CategorieEticheta
@onready var eticheta_context: Label = %ContextEticheta
# Marcajul stă în STÂNGA contextului, în același rând. Rândul e aliniat la
# dreapta, deci un element nou apărut în stânga crește spre golul din mijloc
# și NU împinge cifra de combo din loc — altfel, exact în cadrul în care vrei
# să citești „×5", cifra ar sări lateral.
@onready var eticheta_marcaj: Label = %MarcajEticheta

# Pulsul liniei de context, ținut ca să-l putem OMORÎ când textul se schimbă
# din nou. Fără referință, două pulsuri suprapuse s-ar bate pe `modulate`.
var tween_context: Tween = null
# Același motiv pentru marcaj: două marcaje suprapuse s-ar bate pe alfa, iar
# al doilea ar putea rămâne pe ecran după ce primul îl stinge.
var tween_marcaj: Tween = null
# Nu mai arată timpul — bara singură face asta. Rămâne doar pentru verdict.
@onready var eticheta_verdict: Label = %VerdictEticheta

# Fade-ul verdictului, ținut ca să-l putem omorî dacă se scrie altul peste el.
var tween_verdict: Tween = null
@onready var bara_timp: ProgressBar = %BaraTimp
@onready var eticheta_intrebare: Label = %Intrebare
@onready var butoane := [%Varianta1, %Varianta2, %Varianta3, %Varianta4]


func _ready() -> void:
	set_process(false)        # cronometrul stă până cheamă cineva porneste()
	incarca_date()            # citește fișierele o singură dată pe rulare
	for index in range(butoane.size()):
		var buton: Button = butoane[index]
		buton.pressed.connect(_pe_varianta_aleasa.bind(index))

	# Ca să poți testa scena singură cu F6: dacă nimeni n-a chemat porneste()
	# până la finalul acestui cadru, pornim noi, pe nivelul 1.
	await get_tree().process_frame
	if not pornit:
		porneste(1)


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

	for intrare in _citeste_lista(CALE_CATEGORII):
		if _categorie_valida(intrare, categorii.size()):
			categorii.append(intrare)
	_verifica_membri_unici()
	_indexeaza_domeniile()

	for intrare in _citeste_lista(CALE_VOCABULAR):
		if _cuvant_valid(intrare, vocabular.size()):
			vocabular.append(intrare)

	print("Logica: %d categorii in %d domenii, %d cuvinte." % [
		categorii.size(), pe_domeniu.size(), vocabular.size()
	])


## Citește un fișier JSON și întoarce lista din el. Listă goală la orice
## problemă — cine cheamă nu trebuie să verifice nimic.
static func _citeste_lista(cale: String) -> Array:
	if not FileAccess.file_exists(cale):
		push_warning("Logica: nu gasesc %s. Tipurile care depind de el nu vor aparea." % cale)
		return []

	# Folosim un obiect JSON, nu JSON.parse_string(), tocmai ca să putem spune
	# PE CE LINIE e greșeala. Într-un fișier scris de mână, asta e diferența
	# dintre „ceva e stricat" și „lipsește o virgulă la linia 37".
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(cale)) != OK:
		push_error("Logica: JSON invalid in %s, linia %d — %s" % [
			cale, parser.get_error_line(), parser.get_error_message()
		])
		return []

	if not (parser.data is Array):
		push_error("Logica: %s trebuie sa contina o LISTA." % cale)
		return []
	return parser.data


static func _categorie_valida(c, i: int) -> bool:
	if not (c is Dictionary):
		push_warning("Logica: categoria %d nu e un obiect." % i)
		return false

	for cheie in ["domeniu", "nume", "relatie", "membri"]:
		if not c.has(cheie):
			push_warning("Logica: categoria %d nu are campul '%s'." % [i, cheie])
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
	if not (v is Dictionary):
		push_warning("Logica: cuvantul %d nu e un obiect." % i)
		return false

	for cheie in ["singular", "plural", "articulat", "gen"]:
		if not v.has(cheie):
			push_warning("Logica: cuvantul %d nu are campul '%s'." % [i, cheie])
			return false

	if not (v["gen"] in ["m", "f"]):
		push_warning("Logica: cuvantul '%s' are genul '%s'; asteptam 'm' sau 'f'." % [
			v["singular"], v["gen"]
		])
		return false

	return true


## Avem cu ce alimenta un tip de întrebare? Analogia și intrusul au nevoie de
## două categorii diferite; silogismul, de trei cuvinte.
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
	return true


# ─────────────────────────────────────────────────────────────
# PUNCTUL DE INTRARE
# ─────────────────────────────────────────────────────────────

## Semnătură identică cu a Triviei — de asta integrarea în luptă e o singură
## linie schimbată.
func porneste(nivel: int, context := "", scurtare := 0.0) -> void:
	pornit = true
	nivel = clampi(nivel, 1, TIMP_PE_NIVEL.size())   # apărare: nu accepta nivel 7
	incarca_date()

	var reteta := _alege_reteta(nivel)
	var intrebare: Dictionary = call(reteta["metoda"])

	indice_corect = intrebare["corect"]
	explicatie = intrebare["explicatie"]
	raspuns_dat = false

	# Antetul: ce fel de puzzle e, nu care e regula. „SIR NUMERIC" spune la fel
	# de mult cât spune „ISTORIE" la Trivia — domeniul, nu răspunsul.
	eticheta_categorie.text = reteta["categorie"]

	# Streak-ul, cât mai discret: un „×4" mic lângă categorie.
	# La deschiderea întrebării îl scriem TĂCUT, fără puls: cifra asta e deja
	# câștigată și deja văzută: a pulsat la răspunsul care a produs-o.
	# Pulsează doar prin `arata_combo()`, adică exact când crește.
	_scrie_context(context)
	eticheta_intrebare.text = intrebare["text"]

	var variante: Array = intrebare["variante"]
	for index in range(butoane.size()):
		var buton: Button = butoane[index]
		buton.text = variante[index]
		buton.disabled = false
		buton.modulate = Color.WHITE   # ștergem verdele/roșul de la runda trecută

	# Podeaua de timp se aplică AICI, o singură dată, deci nimeni din afară
	# nu poate cere din greșeală o întrebare de 2 secunde.
	var timp_total: float = maxf(TIMP_PE_NIVEL[nivel - 1] - scurtare, TIMP_MINIM)
	timp_ramas = timp_total
	bara_timp.max_value = timp_total
	bara_timp.modulate = Color.WHITE

	# Verdictul de la întrebarea trecută se șterge, dar eticheta rămâne pe loc,
	# goală. Un Label gol tot cere înălțimea unui rând de text — exact ce vrem:
	# locul verdictului e păstrat, deci întrebarea nu sare în jos când apare el.
	_scrie_verdict("", true)

	butoane[0].grab_focus()   # ca să meargă și cu tastatura (săgeți + Enter)
	actualizeaza_cronometru()
	set_process(true)         # ABIA ACUM pornește timpul


## Alege ce fel de întrebare urmează. ÎN DOUĂ TREPTE, și asta e tot rostul
## funcției: întâi tragem la sorți TIPUL, apoi un tipar din el.
##
## Dacă am trage direct dintre tipare, tipul cu cele mai multe ar câștiga
## proporțional: 9 șiruri numerice contra unui silogism însemna 90% șiruri.
## Așa, cele cinci tipuri au aceeași șansă indiferent câte tipare are fiecare,
## iar când mai adaugi un șir numeric nu strici echilibrul.
func _alege_reteta(nivel: int) -> Dictionary:
	# `filter` păstrează doar intrările pentru care funcția anonimă (lambda)
	# întoarce true: nivelul cerut ȘI datele necesare, prezente.
	var disponibile: Array = GENERATOARE.filter(
		func(g): return nivel in g["niveluri"] and _date_disponibile(g["necesita"])
	)
	# Plasă de siguranță: dacă un nivel rămâne fără nimic, luăm orice putem
	# genera. Nu poate fi gol — șirurile și deducțiile n-au nevoie de date.
	if disponibile.is_empty():
		disponibile = GENERATOARE.filter(func(g): return _date_disponibile(g["necesita"]))

	var pe_tip := {}
	for generator in disponibile:
		var tip: String = generator["tip"]
		if not pe_tip.has(tip):
			pe_tip[tip] = []
		pe_tip[tip].append(generator)

	var tip_ales = pe_tip.keys().pick_random()
	return pe_tip[tip_ales].pick_random()


## INERTĂ ACUM, dar păstrată: face parte din contractul pe care îl are orice
## disciplină, iar lupta o cheamă la fiecare lovitură.
##
## Cât timp puzzle-ul acoperea tot ecranul, avea nevoie de bara ei proprie, ca
## să vezi inamicul slăbind. De când întrebarea stă într-un panou în mijlocul
## arenei, barele adevărate rămân vizibile în stânga și în dreapta — a doua
## bară ar fi fost aceeași informație, desenată de două ori.
##
## Rămâne aici fiindcă altundeva (un tur de antrenament în Cetate, de pildă)
## s-ar putea să nu existe o arenă în spate. Atunci se reumple; până atunci,
## contractul e respectat fără să deseneze nimic.
func arata_stare(_valoare: float, _maxim: float) -> void:
	pass


## ── MARCAJUL DE STREAK ─────────────────────────────────────────
## PARTE DIN CONTRACT, ca `porneste()` și `arata_stare()`. Lupta o cheamă
## după un răspuns corect, cât întrebarea e ÎNCĂ pe ecran, ca să vezi cifra
## urcând PESTE răspunsul tău — nu abia la întrebarea următoare.
##
## Primim un String gata compus. Scena tot nu știe ce e un combo, o treaptă
## sau un lanț: știe doar să scrie o linie și s-o facă să pulseze când e nouă.
## `marcaj` e al doilea capăt al aceluiași gest: un text scurt care FULGERĂ
## lângă context și dispare. Gol = momentul e obișnuit. Scena nu-l citește;
## îl aprinde. Așa lupta poate striga „CRITIC!" fără ca disciplina să afle
## vreodată ce e o lovitură critică.
func arata_combo(text: String, marcaj := "") -> void:
	var s_a_schimbat := text != eticheta_context.text
	_scrie_context(text)
	# Pulsăm la APARIȚIE și la CREȘTERE — adică ori de câte ori cifra e alta.
	# Un text identic (sau gol) nu merită un puls: n-ai ce observa.
	if text != "" and s_a_schimbat:
		_pulseaza_context(marcaj != "")
	# Marcajul e independent de cifră: e un eveniment, nu o valoare.
	if marcaj != "":
		_arata_marcaj(marcaj)


## Scrie linia de context și decide dacă ea există pe ecran.
## Un Label gol tot ocupă spațiu în container, deci text gol = ascuns de tot.
##
## Aici se OMOARĂ și pulsul în curs. `modulate` ține și culoarea, și albul de
## flash; dacă un tween vechi ar mai rula peste textul nou, ar trage culoarea
## înapoi spre ce era înainte.
func _scrie_context(text: String) -> void:
	if tween_context != null and tween_context.is_valid():
		tween_context.kill()
	eticheta_context.text = text
	eticheta_context.visible = text != ""
	# MEREU auriu. Portocaliul îl pune doar pulsul, și doar pentru o clipă.
	eticheta_context.modulate = CULOARE_CONTEXT
	eticheta_context.scale = Vector2.ONE
	# Marcajul însoțea contextul de dinainte. Context nou (întrebare nouă sau
	# serie ruptă) = el nu mai are ce descrie, deci pleacă odată cu ea.
	_ascunde_marcaj()


## Pulsul: eticheta se aprinde alb și se umflă, apoi revine la culoarea ei.
## De ce și mărime, nu doar culoare: în timpul unei întrebări te uiți la
## variante, nu la antet. O schimbare de MĂRIME se prinde cu coada ochiului;
## una de culoare, pe un text mic, deseori nu.
## `critic` nu schimbă pulsul, ci CULOAREA ÎN CARE SE AȘAZĂ el: portocaliu în
## loc de auriu, și doar cât ține marcajul de alături. Pe urmă linia se întoarce
## la auriu, ca la orice altă treaptă.
func _pulseaza_context(critic := false) -> void:
	var text_la_start := eticheta_context.text
	# Un cadru de așteptare. Tocmai am schimbat textul, dar containerul
	# reașază copiii abia la finalul cadrului — până atunci `size` (și cu ea
	# mijlocul etichetei) e cea de dinainte, iar pivotul ar cădea strâmb.
	await get_tree().process_frame
	# Între timp întrebarea s-ar fi putut încheia. Dacă pe ecran nu mai e
	# același text, pulsul ăsta n-are ce anima.
	if not is_instance_valid(eticheta_context) or eticheta_context.text != text_la_start:
		return
	if not eticheta_context.visible:
		return

	# `pivot_offset` = punctul în jurul căruia se scalează. Implicit e colțul
	# din stânga-sus, deci eticheta ar „crește spre dreapta-jos".
	# Îl punem pe marginea DIN DREAPTA, la mijlocul înălțimii: eticheta e
	# lipită de dreapta panoului (`alignment = END`), deci acolo are 14px de
	# margine și nimic altceva. Umflată din centru ar ieși din panou; umflată
	# din dreapta crește spre interior, unde e loc gol.
	eticheta_context.pivot_offset = Vector2(
		eticheta_context.size.x, eticheta_context.size.y / 2.0
	)

	# Culoarea în care se așază pulsul. La un moment obișnuit e auriul normal;
	# la unul marcat, portocaliul — dar ca escală, nu ca destinație.
	var culoare_baza := CULOARE_ACCENT if critic else CULOARE_CONTEXT
	eticheta_context.modulate = CULOARE_FLASH
	eticheta_context.scale = Vector2.ONE * SCARA_FLASH

	# `set_parallel(true)` = toți pașii pornesc odată, nu unul după altul:
	# vrem ca revenirea la mărime și cea la culoare să fie ACELAȘI gest.
	tween_context = create_tween().set_parallel(true)
	# TRANS_BACK + EASE_OUT trece puțin SUB mărimea normală înainte să se
	# așeze. Acel mic „recul" e ce face pulsul să pară o bătaie, nu o topire.
	var pas_scara := tween_context.tween_property(eticheta_context, "scale", Vector2.ONE, DURATA_FLASH)
	pas_scara.set_ease(Tween.EASE_OUT)
	pas_scara.set_trans(Tween.TRANS_BACK)
	tween_context.tween_property(eticheta_context, "modulate", culoare_baza, DURATA_FLASH)

	if not critic:
		return

	# Întoarcerea la auriu. `chain()` pune pasul următor DUPĂ ce se termină tot
	# ce rulează în paralel, nu odată cu el — de asta îl chemăm de două ori:
	# o dată pentru pauză, o dată pentru revenire. Fără el, într-un tween pus pe
	# paralel toți pașii ar porni în același cadru și portocaliul n-ar apuca
	# să existe.
	# `maxf(..., 0.0)`: dacă cineva scurtează cândva DURATA_MARCAJ sub durata
	# pulsului, vrem pauză zero, nu o durată negativă.
	tween_context.chain().tween_interval(maxf(DURATA_MARCAJ - DURATA_FLASH, 0.0))
	tween_context.chain().tween_property(
		eticheta_context, "modulate", CULOARE_CONTEXT, DURATA_REVENIRE
	)


## MARCAJUL. Apare, stă cât să-l citești, se stinge. E un EVENIMENT, nu o
## stare: dacă ar rămâne pe ecran, a doua oară n-ai mai vedea nimic
## întâmplându-se — și exact „s-a întâmplat ceva" e tot ce are de spus.
func _arata_marcaj(text: String) -> void:
	if tween_marcaj != null and tween_marcaj.is_valid():
		tween_marcaj.kill()
	eticheta_marcaj.text = text
	eticheta_marcaj.visible = true
	# Culoarea e pusă din primul cadru, iar apoi tragem DOAR de alfa
	# (`modulate:a`, transparența). Așa textul nu trece prin nicio nuanță
	# intermediară: apare direct portocaliu, doar din ce în ce mai opac.
	eticheta_marcaj.modulate = CULOARE_ACCENT
	eticheta_marcaj.modulate.a = 0.0

	# Tween NEparalel (implicit): pașii se execută unul după altul —
	# apare, stă, se stinge.
	tween_marcaj = create_tween()
	tween_marcaj.tween_property(eticheta_marcaj, "modulate:a", 1.0, DURATA_APARITIE_MARCAJ)
	tween_marcaj.tween_interval(maxf(DURATA_MARCAJ - DURATA_APARITIE_MARCAJ, 0.0))
	tween_marcaj.tween_property(eticheta_marcaj, "modulate:a", 0.0, DURATA_REVENIRE)
	# La final îl scoatem din layout de tot: un Label transparent tot ocupă
	# lățime, iar rândul ar rămâne împins degeaba.
	tween_marcaj.tween_callback(func(): eticheta_marcaj.visible = false)


## Stinge marcajul pe loc, fără animație. Îl cheamă `_scrie_context()`: acolo
## se schimbă chiar lucrul pe care marcajul îl însoțea.
func _ascunde_marcaj() -> void:
	if tween_marcaj != null and tween_marcaj.is_valid():
		tween_marcaj.kill()
	eticheta_marcaj.visible = false
	eticheta_marcaj.text = ""


## Scrie verdictul și îl aduce pe ecran cu un fade scurt.
##
## De ce fade și nu apariție seacă: textul apare în același cadru în care
## butonul tău se colorează. Două schimbări instantanee în același loc se
## citesc ca o singură tresărire și nu știi la care să te uiți. Fade-ul le
## desparte în timp cu o fracțiune de secundă, cât să înregistrezi întâi
## butonul, apoi cuvântul.
##
## Text gol = doar ștergem (fără fade — n-ai ce vedea apărând).
func _scrie_verdict(text: String, bun: bool) -> void:
	if tween_verdict != null and tween_verdict.is_valid():
		tween_verdict.kill()
	eticheta_verdict.text = text
	eticheta_verdict.modulate = CULOARE_VERDICT_BUN if bun else CULOARE_VERDICT_RAU
	if text == "":
		return
	# `modulate:a` = doar canalul alfa (transparența) din culoare. Tragem de el
	# de la 0 la 1, deci culoarea rămâne cea de mai sus și doar apare.
	eticheta_verdict.modulate.a = 0.0
	tween_verdict = create_tween()
	tween_verdict.tween_property(eticheta_verdict, "modulate:a", 1.0, DURATA_VERDICT)


# ─────────────────────────────────────────────────────────────
# ȘIRURI NUMERICE — pur generative, fără fișiere.
# Fiecare produce TERMENI_VIZIBILI + 1 numere; ultimul e răspunsul.
# Intervalele sunt alese ca numerele să rămână calculabile în cap: un șir
# corect matematic dar cu termeni de cinci cifre nu e mai greu, e doar obositor.
# ─────────────────────────────────────────────────────────────

## NIVEL I — se adună mereu același număr. 3, 7, 11, 15, 19, ?
func _pas_constant() -> Dictionary:
	var valoare := randi_range(1, 9)
	var pas := randi_range(2, 6)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += pas
	return _intrebare_din_sir(termeni, "PAS CONSTANT")


## NIVEL I — se înmulțește mereu cu același număr. 3, 6, 12, 24, 48, ?
func _factor_constant() -> Dictionary:
	# Factorul 3 crește mult mai repede, deci pornește de mai jos:
	# altfel ultimul termen ajunge la patru cifre și devine calcul, nu logică.
	var factor := 2 if randf() < 0.75 else 3
	var valoare := randi_range(1, 5) if factor == 2 else randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare *= factor
	return _intrebare_din_sir(termeni, "INMULTIRE CU %d" % factor)


## NIVEL I — același pas, dar în jos. 58, 51, 44, 37, 30, ?
func _pas_negativ() -> Dictionary:
	var pas := randi_range(3, 7)
	# Pornim destul de sus cât ultimul termen să rămână pozitiv: numere
	# negative ar cere o a doua idee, iar la nivelul I vrem una singură.
	var valoare := randi_range(45, 70)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare -= pas
	return _intrebare_din_sir(termeni, "PAS CONSTANT")


## NIVEL II — pasul crește de fiecare dată. 2, 3, 5, 8, 12, ?
func _pas_crescator() -> Dictionary:
	var valoare := randi_range(1, 6)
	var pas := randi_range(1, 3)
	var crestere := randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += pas
		pas += crestere
	return _intrebare_din_sir(termeni, "PAS CRESCATOR")


## NIVEL II — două operații care se schimbă între ele. 5, 12, 10, 17, 15, ?
## Adaosul e mereu mai mare decât scăderea, deci șirul urcă în zigzag.
func _alternant() -> Dictionary:
	var valoare := randi_range(4, 12)
	var adaos := randi_range(5, 9)
	var scadere := randi_range(1, 4)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += adaos if i % 2 == 0 else -scadere
	return _intrebare_din_sir(termeni, "ALTERNANT")


## NIVEL II — pasul se dublează. 3, 5, 9, 17, 33, ?
func _pas_dublat() -> Dictionary:
	var valoare := randi_range(2, 7)
	var pas := randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += pas
		pas *= 2
	return _intrebare_din_sir(termeni, "PAS DUBLAT")


## NIVEL III — două reguli în același șir: înmulțire, apoi adunare.
## 3, 6, 8, 16, 18, ?
func _mixt() -> Dictionary:
	var valoare := randi_range(2, 5)
	var adaos := randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare = valoare * 2 if i % 2 == 0 else valoare + adaos
	return _intrebare_din_sir(termeni, "MIXT: x2, APOI +%d" % adaos)


## NIVEL III — fiecare termen e suma celor doi dinainte. 2, 5, 7, 12, 19, ?
## Nu pornește mereu de la 1, 1: altfel ai memora șirul, nu regula.
func _fibonacci() -> Dictionary:
	var primul := randi_range(1, 5)
	var al_doilea := randi_range(2, 7)
	while al_doilea == primul:   # „4, 4, 8, ..." se citește ca o greșeală de tipar
		al_doilea = randi_range(2, 7)
	var termeni: Array[int] = [primul, al_doilea]
	while termeni.size() < TERMENI_VIZIBILI + 1:
		termeni.append(termeni[-1] + termeni[-2])
	return _intrebare_din_sir(termeni, "FIBONACCI")


## NIVEL III — pătrate perfecte, uneori decalate cu o constantă.
## 9, 16, 25, 36, 49, ?   sau   11, 18, 27, 38, 51, ?
func _patrate() -> Dictionary:
	var start := randi_range(1, 5)
	var adaos := randi_range(0, 2)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		var n := start + i
		termeni.append(n * n + adaos)
	return _intrebare_din_sir(termeni, "PATRATE" if adaos == 0 else "PATRATE +%d" % adaos)


## Împachetează un șir în forma pe care o așteaptă scena.
func _intrebare_din_sir(termeni: Array[int], nume_regula: String) -> Dictionary:
	var raspuns: int = termeni[-1]
	var afisati := termeni.slice(0, termeni.size() - 1)
	var numere := _variante_numerice(raspuns, afisati)

	# Butoanele afișează text, deci numerele devin șiruri de caractere aici.
	var variante: Array[String] = []
	for numar in numere:
		variante.append(str(numar))

	return {
		"text": ", ".join(afisati.map(func(n): return str(n))) + ", ?",
		"variante": variante,
		"corect": numere.find(raspuns),
		"explicatie": nume_regula,
	}


## Cele 3 variante greșite NU sunt numere la întâmplare — sunt GREȘELI
## PLAUZIBILE, adică rezultatele pe care le obții dacă te înșeli puțin:
## mai aplici o dată pasul, folosești diferența anterioară, sau ratezi cu 1-2.
##
## De ce contează: cu distractori aleatori, răspunsul corect e cel care „arată
## bine" și poți nimeri fără să calculezi. Puzzle-ul ar arăta la fel și n-ar
## mai măsura nimic.
func _variante_numerice(raspuns: int, afisati: Array[int]) -> Array[int]:
	var pas: int = afisati[-1] - afisati[-2]
	var pas_anterior: int = afisati[-2] - afisati[-3]
	# `absi` = valoarea absolută a unui întreg (fără semn). Pasul poate fi
	# negativ, la șirurile descrescătoare, iar noi vrem mărimea lui.
	var jumatate_pas: int = maxi(1, absi(pas) / 2)

	var candidati := [
		raspuns + 1, raspuns - 1,                    # ratat cu puțin
		raspuns + 2, raspuns - 2,
		raspuns + pas, raspuns - pas,                # aplicat pasul de două ori / deloc
		afisati[-1] + pas_anterior,                  # folosit diferența veche
		raspuns + jumatate_pas, raspuns - jumatate_pas,
	]
	candidati.shuffle()

	var variante: Array[int] = [raspuns]
	for candidat in candidati:
		if variante.size() == 4:
			break
		# Sărim peste: numere negative sau zero (se citesc ca greșeli de generator),
		# duplicate, și termeni care se văd deja în șir — ăia nu păcălesc pe nimeni.
		if candidat > 0 and not (candidat in variante) and not (candidat in afisati):
			variante.append(candidat)

	# Plasă de siguranță: dacă filtrele au fost prea severe (șiruri mici, cu
	# pas 1), completăm cu vecini. Fără asta, un buton ar rămâne gol.
	var distanta := 3
	while variante.size() < 4:
		if not (raspuns + distanta in variante):
			variante.append(raspuns + distanta)
		distanta += 1

	variante.shuffle()
	return variante


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
	var pool := vocabular.duplicate()
	pool.shuffle()
	return [pool[0], pool[1], pool[2]]


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
# Pur generative, ca si sirurile: regula E continutul. Primesti cateva
# comparatii si trebuie sa reconstruiesti ordinea din ele.
#
# Numele sunt toate masculine, dinadins: „Dalia e mai inalt" ar fi fost o
# greseala de acord la fiecare a doua intrebare. Aici gramatica nu e subiectul
# puzzle-ului, deci o evitam in loc s-o rezolvam.
# -------------------------------------------------------------
const NUME_DEDUCTIE := [
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

	var nume := NUME_DEDUCTIE.duplicate()
	nume.shuffle()
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


# ─────────────────────────────────────────────────────────────
# CRONOMETRU ȘI FEEDBACK
# Identice cu ale Triviei, intenționat: aceeași presiune, aceleași culori,
# aceeași pauză în care apuci să vezi răspunsul bun.
# ─────────────────────────────────────────────────────────────

## `_process` e chemată de Godot la FIECARE cadru (~60 pe secundă).
## `delta` = câte secunde au trecut de la cadrul precedent. Scădem delta,
## nu 1/60 — așa cronometrul e corect și dacă jocul încetinește.
func _process(delta: float) -> void:
	timp_ramas -= delta
	if timp_ramas <= 0.0:
		timp_ramas = 0.0
		actualizeaza_cronometru()
		_termina(false, -1)   # -1 = „n-a ales nimeni", adică timeout
		return
	actualizeaza_cronometru()


func actualizeaza_cronometru() -> void:
	bara_timp.value = timp_ramas
	# Cifra („9.7 s") a fost scoasă intenționat. Se schimba de 60 de ori pe
	# secundă chiar lângă întrebare, iar ochiul se duce automat la ce se mișcă.
	# Bara spune același lucru — cât a mai rămas — dar o spune periferic, fără
	# să-ți ceară să citești. Presiunea se simte, nu se numără.
	if timp_ramas <= PRAG_URGENTA:
		bara_timp.modulate = Color(1, 0.35, 0.3)
	else:
		bara_timp.modulate = Color(0.55, 0.85, 1)


## Chemată de oricare dintre cele 4 butoane; `index` vine din .bind().
func _pe_varianta_aleasa(index: int) -> void:
	if raspuns_dat:
		return
	_termina(index == indice_corect, index)


## Singura ieșire din scenă. `ales` = ce a apăsat jucătorul (-1 la timeout).
func _termina(succes: bool, ales: int) -> void:
	raspuns_dat = true
	set_process(false)   # oprim cronometrul IMEDIAT, înainte de orice așteptare

	for buton: Button in butoane:
		buton.disabled = true

	# Feedback: arătăm mereu care era răspunsul bun.
	# Ton sănătos — înveți ceva și când greșești, nu ești doar pedepsit.
	butoane[indice_corect].modulate = Color(0.45, 1, 0.55)
	if not succes and ales >= 0:
		butoane[ales].modulate = Color(1, 0.4, 0.4)

	# Seria s-a rupt (răspuns greșit SAU timp expirat), deci marcajul ei nu mai
	# are ce descrie: dispare pe loc, nu peste 1,8 secunde, când se închide
	# panoul. Rămâne o regulă neutră — ștergem o linie care a devenit falsă,
	# fără să știm ce e un combo.
	if not succes:
		_scrie_context("")

	# Antetul NU se schimbă la răspuns: rămâne tipul provocării, ca la Trivia.
	# Un rând care își schimbă înțelesul la jumătatea puzzle-ului („ORDONARE"
	# devine brusc „ORDINEA: A > B > C") îl obligă pe jucător să recitească un
	# text pe care tocmai îl citise. Regula rezolvării trăiește în `explicatie`,
	# dar nu are, deocamdată, un loc unde să fie afișată.

	if succes:
		_scrie_verdict("CORECT", true)
	elif ales < 0:
		_scrie_verdict("TIMPUL A EXPIRAT", false)
	else:
		_scrie_verdict("INCORECT", false)

	# `create_timer` face un cronometru de unică folosință; `await` pune funcția
	# pe pauză până când el emite `timeout`. Scurtă pauză, ca să apuci să vezi.
	await get_tree().create_timer(PAUZA_FEEDBACK).timeout

	# ȘI ABIA ACUM strigăm rezultatul. Cine ne-a deschis primește `succes`.
	rezolvat.emit(succes)

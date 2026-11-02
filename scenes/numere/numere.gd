extends Puzzle
## Disciplina NUMERE — a patra, și prima care nu citește nimic de pe disc.
##
## Cultura generală are 7829 de întrebări într-un JSON, Logica are un vocabular
## și 80 de categorii, Cuvintele au 180 de cuvinte. Numerele n-au nimic: nu
## există o listă de socoteli de scris, fiindcă „47 + 38 − 19" nu e un
## CONȚINUT, e un tipar cu niște numere în el. De-aia fișierul ăsta e singura
## disciplină la care `_pregateste_datele()` rămâne gol — și singurul loc din
## joc unde nivelul de dificultate se poate regla cu un număr, nu cu o
## săptămână de scris.
##
## PATRU TIPURI, unsprezece tipare:
##   CALCUL    — lanț de adunări, înmulțire, ordinea operațiilor, împărțire
##   PROCENTE  — procent dintr-un număr, cât la sută, reducere de preț
##   ESTIMARE  — ordinul de mărime al unui produs, suma rotunjită
##   CANTARUL  — care valoare e cea mai mare, și ce e egal cu ce (fracții,
##               zecimale și procente amestecate: de-aia piesa e TURNUL și
##               simbolul din pitch era o balanță)
##
## ─────────────────────────────────────────────────────────────
## DE UNDE VIN VARIANTELE GREȘITE — toată disciplina stă aici
##
## La Cuvinte, regula era „din aceeași clasă gramaticală și de la același
## nivel", altfel trei variante se elimină din FORMĂ. La numere forma nu te
## ajută niciodată: patru numere arată toate ca niște numere. Dar există
## capcana oglindă, și e mai rea: dacă greșelile se trag la întâmplare, se
## elimină din MĂRIME. La „14 × 6 = ?" variantele 84, 9, 311, 1250 nu cer
## înmulțirea — cer o privire.
##
## Deci regula de aici: **o variantă greșită e o GREȘEALĂ, nu un număr.**
## Fiecare tipar își declară propriile greșeli, în ordinea în care sunt
## tentante, iar cele mai bune sunt chiar cele pe care le-ai face tu:
##
##   • ordinea operațiilor — „4 + 3 × 5" calculat de la stânga la dreapta dă
##     35 în loc de 19. Varianta aia NU e un distractor, e răspunsul celui
##     care n-a învățat regula. Tiparul întreg există pentru ea.
##   • virgula mutată — la procente, 15% din 240 e 36, dar 360 și 3 sunt exact
##     ce iese când împarți la 10 o dată mai mult sau mai puțin.
##   • întrebarea greșită — la „preț 240, scade cu 15%, cât devine?" numărul
##     36 (REDUCEREA) e corect calculat și totuși greșit. Asta nu pedepsește
##     socoteala, pedepsește cititul — și e cea mai des făcută greșeală din tot
##     tiparul.
##   • semnul întors — la un lanț, „+" în loc de „−".
##   • vecinătatea — ±1, ±2, ±10. Astea sunt UMPLUTURA, nu miezul: stau la
##     coada listei de candidați și intră doar când greșelile adevărate nu
##     sunt destule.
##
## Și o excepție conștientă, care arată de ce regula nu e un reflex:
## **la ESTIMARE variantele sunt dinadins la zece ori una de alta.** Acolo
## priceperea măsurată E mărimea („cam cât e 312 × 48?"), deci variante
## apropiate ar transforma estimarea în calcul exact — adică în alt tipar.
## Regula adevărată nu e „variante apropiate", e „variantele să ceară chiar
## ce întreabă enunțul".
##
## ─────────────────────────────────────────────────────────────
## CE NU E AICI, ȘI DE CE
##
## ȘIRURI DE NUMERE. Ar fi stat perfect („2, 6, 12, 20, ?"), și tocmai de-aia
## nu sunt: pasul 2 din rută mută seriile numerice din Logică la TIPARE, nu la
## Numere. Dacă le-aș pune acum aici, pasul ăla ar însemna să le mut a doua
## oară.
##
## RĂSPUNSURI SCRISE DE LA TASTATURĂ. Contractul cu `puzzle.gd` e patru
## butoane, pentru toate disciplinele. Un câmp de scris ar fi cinstit la
## aritmetică (nu poți ghici din patru) și ar fi o a doua formă de întrebare în
## joc, deci o a doua presiune de învățat. Dacă vreodată merită, e o schimbare
## în `puzzle.gd` pentru TOATE disciplinele, nu o ramură aici.

# Câte variante are o întrebare. Tot 4, ca la celelalte; baza verifică oricum
# și se plânge dacă primește altceva.
const VARIANTE := 4

# ─────────────────────────────────────────────────────────────
# SIMBOLURILE, și de ce nu sunt cele „frumoase"
#
# Pentru înmulțire și împărțire s-au încercat întâi „×" și „÷". Al doilea a
# căzut din două motive, iar al doilea motiv e cel care contează:
#
#   1. în românește împărțirea se scrie cu două puncte („126 : 7"), nu cu ÷.
#      Așa e în manuale, deci așa se citește fără pauză.
#   2. „÷" și „−" (minusul tipografic, U+2212) nu sunt garantate în Cinzel și
#      Alegreya, fonturile temei de pergament. Un caracter care lipsește
#      dintr-un font se desenează ca un dreptunghi gol („tofu") — exact
#      capcana din care s-au născut piesele desenate din `glifa_sah.gd`.
#      De-aia minusul de aici e cratima ASCII.
#
# ȘI NU E O BĂNUIALĂ: `verifica_numere` cere ca fiecare caracter al fiecărei
# întrebări să existe în amândouă fonturile temei ȘI în cel implicit. Dacă
# mâine pun „≈" în enunț și Cinzel nu-l are, verificarea pică înainte să
# ajungă pe ecran.
const ORI := "×"
const IMPARTIT := ":"
const MINUS := "-"
const PLUS := "+"

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Un tabel, ca la Logică și la Cuvinte: un tipar nou e o funcție și un rând.
#
#   „tip"      — familia. ASTA se alege prima, nu tiparul, ca CALCUL (patru
#                tipare) să nu apară de două ori mai des decât ESTIMARE (două).
#   „categorie"— ce scrie în antet. Spune ce fel de socoteală e, nu răspunsul.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# LIPSEȘTE „niveluri", la fel ca la Cuvinte și nu ca la Logică, și distincția
# merită ținută minte. La Logică nivelul e o însușire a GENERATORULUI:
# „Fibonacci" e greu prin construcție, cu orice numere. Aici dificultatea stă
# în NUMERE: „7 × 8" și „24 × 17" sunt același tipar și două lumi diferite.
# Deci fiecare tipar merge la toate trei nivelurile, iar nivelul se aplică la
# alegerea numerelor (vezi tabelele de intervale de la fiecare tipar).
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	{"tip": "CALCUL", "categorie": "CALCUL", "metoda": "_lant"},
	{"tip": "CALCUL", "categorie": "INMULTIRE", "metoda": "_inmultire"},
	{"tip": "CALCUL", "categorie": "ORDINEA OPERATIILOR", "metoda": "_ordinea_operatiilor"},
	{"tip": "CALCUL", "categorie": "IMPARTIRE", "metoda": "_impartire"},

	{"tip": "PROCENTE", "categorie": "PROCENT", "metoda": "_procent_din"},
	{"tip": "PROCENTE", "categorie": "CAT LA SUTA", "metoda": "_cat_la_suta"},
	{"tip": "PROCENTE", "categorie": "REDUCERE", "metoda": "_reducere"},

	{"tip": "ESTIMARE", "categorie": "ORDIN DE MARIME", "metoda": "_ordin_de_marime"},
	{"tip": "ESTIMARE", "categorie": "ESTIMARE", "metoda": "_suma_rotunjita"},

	{"tip": "CANTARUL", "categorie": "CEA MAI MARE", "metoda": "_cea_mai_mare"},
	{"tip": "CANTARUL", "categorie": "ECHIVALENTA", "metoda": "_echivalenta"},
]


# ─────────────────────────────────────────────────────────────
# CÂNTARUL — valorile, scrise de mână
#
# O listă, nu o formulă, și dinadins. O formulă ar fi putut naște „7/13" sau
# „0,4375": numere corecte pe care nu le compari în cap, deci întrebări care
# măsoară răbdarea, nu priceperea. Fiecare valoare de mai jos are cel puțin
# două scrieri EXACTE, iar cele cu „fractie" au trei.
#
# „sutimi" e valoarea în sutimi (întreg, ca să nu existe nicio comparație
# între zecimale în virgulă mobilă). „fractie" lipsește unde n-ar fi frumoasă:
# 15% = 3/20, corect dar nu de citit dintr-o privire.
# ─────────────────────────────────────────────────────────────
const VALORI_CANTAR := [
	{"sutimi": 10, "fractie": "1/10"},
	{"sutimi": 15, "fractie": ""},
	{"sutimi": 20, "fractie": "1/5"},
	{"sutimi": 25, "fractie": "1/4"},
	{"sutimi": 30, "fractie": "3/10"},
	{"sutimi": 35, "fractie": ""},
	{"sutimi": 40, "fractie": "2/5"},
	{"sutimi": 45, "fractie": ""},
	{"sutimi": 50, "fractie": "1/2"},
	{"sutimi": 55, "fractie": ""},
	{"sutimi": 60, "fractie": "3/5"},
	{"sutimi": 65, "fractie": ""},
	{"sutimi": 70, "fractie": "7/10"},
	{"sutimi": 75, "fractie": "3/4"},
	{"sutimi": 80, "fractie": "4/5"},
	{"sutimi": 85, "fractie": ""},
	{"sutimi": 90, "fractie": "9/10"},
]

## Cât de depărtate trebuie să fie, în sutimi, cele patru valori de pe cântar.
## Nivelul I le vrea depărtate (compari dintr-o privire), nivelul III lipite.
## Zero n-ar fi un nivel IV, ar fi o întrebare stricată: 2/5, 0,4 și 40% sunt
## ACELAȘI număr, iar jocul ar marca roșu două butoane bune din patru.
const DISTANTA_CANTAR := [15, 10, 5]


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește datele. N-are ce să citească — numerele nu stau pe disc.
## Rămâne scrisă, goală, fiindcă e jumătate din contract: cine deschide
## fișierul ăsta ca model pentru a cincea disciplină trebuie să vadă că
## funcția EXISTĂ și că are voie să nu facă nimic.
func _pregateste_datele() -> void:
	pass


## A doua: produce o întrebare pentru nivelul cerut.
##
## Alegerea e în două trepte (întâi tipul, apoi tiparul din el), iar lista
## întoarsă de `_retete_amestecate()` e și ordinea de rezervă: un tipar are
## voie să dea greș. La Cuvinte asta se întâmpla când gălata era prea săracă;
## aici, când greșelile tipice ies identice între ele (vezi
## `_variante_numerice`) — rar, dar nu niciodată.
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate():
		var intrebare: Dictionary = call(reteta["metoda"], nivel)
		if not intrebare.is_empty():
			intrebare["categorie"] = reteta["categorie"]
			# TIPUL, luat din același rând al tabelului. Nu se afișează nicăieri:
			# baza îl ține minte și-l ocolește la treapta următoare.
			intrebare["tip"] = reteta["tip"]
			return intrebare
	return {}


## De unde vin întrebările, pentru ecranul de eroare. Nu e un fișier.
func _descriere_sursa() -> String:
	return "generate din `scenes/numere/numere.gd` (fara fisier de date)"


## Tiparele, în ordinea în care merită încercate. Primul element E tragerea la
## sorți în două trepte; restul e plasa de siguranță, amestecată și ea.
## (Aceeași funcție ca la Cuvinte. N-a fost mutată în `puzzle.gd` fiindcă
## Trivia nu are `GENERATOARE` deloc — ar fi fost o funcție din bază pe care
## o folosesc doar unii, adică un contract cu excepții.)
func _retete_amestecate() -> Array:
	var pe_tip := {}
	for generator in GENERATOARE:
		var tip: String = generator["tip"]
		if not pe_tip.has(tip):
			pe_tip[tip] = []
		pe_tip[tip].append(generator)

	# Amestecate, dar cu tipul de la treapta trecută trimis la COADĂ: două
	# trepte la rând din același fel de întrebare o prinzi pe a doua cu metoda
	# deja încălzită. Vezi „FĂRĂ DOUĂ TREPTE DIN ACELAȘI TIP" din `puzzle.gd`.
	var tipuri: Array = tipuri_amestecate(pe_tip.keys(), tip_de_ocolit())

	var ordine: Array = []
	for tip in tipuri:
		var tipare: Array = pe_tip[tip].duplicate()
		tipare.shuffle()
		ordine.append_array(tipare)
	return ordine


# ─────────────────────────────────────────────────────────────
# TIPUL 1 — CALCUL
# ─────────────────────────────────────────────────────────────

## „47 + 38 - 19 = ?"
##
## Lanțul se construiește PAS CU PAS, iar scăderea se acceptă doar dacă totalul
## rămâne peste 9. Nu e cochetărie: un răspuns negativ printre trei variante
## pozitive s-ar elimina din formă, fără nicio socoteală — exact greșeala
## împotriva căreia e scris antetul fișierului.
func _lant(nivel: int) -> Dictionary:
	var cati: int = [2, 3, 3][nivel - 1]
	var jos: int = [11, 21, 51][nivel - 1]
	var sus: int = [49, 99, 249][nivel - 1]

	var termeni: Array[int] = [randi_range(jos, sus)]
	var semne: Array[String] = []
	var total: int = termeni[0]
	for i in range(cati - 1):
		var t := randi_range(jos, sus)
		if randf() < 0.5 and total - t > 9:
			semne.append(MINUS)
			total -= t
		else:
			semne.append(PLUS)
			total += t
		termeni.append(t)

	# GREȘELILE, în ordinea în care sunt tentante.
	# Prima e semnul întors pe ULTIMUL termen — adică „am citit + unde era -".
	# Al doilea e carul uitat: ±10. Restul e vecinătate.
	# „De două ori ultimul termen" e tot ce trebuie ca să întorci semnul lui:
	# dacă s-a scăzut, îl adaugi de două ori ca să ajungi la cât ar fi fost
	# adunat, și invers.
	var ultimul: int = termeni[termeni.size() - 1]
	var cu_semn_intors: int = total + 2 * ultimul
	if semne[semne.size() - 1] == PLUS:
		cu_semn_intors = total - 2 * ultimul

	var enunt := str(termeni[0])
	for i in range(semne.size()):
		enunt += " %s %d" % [semne[i], termeni[i + 1]]

	return _intrebare_numerica(
		"%s = ?" % enunt,
		total,
		[cu_semn_intors, total + 10, total - 10, total + 1, total - 1, total + 2],
		"",
		"%s = %d" % [enunt, total]
	)


## „14 × 6 = ?"
##
## Greșelile sunt cele de tablă: un rând în plus sau în minus (a × (b±1), adică
## rezultatul ± a) și carul uitat (±10). ±1 vine la coadă, ca umplutură.
func _inmultire(nivel: int) -> Dictionary:
	var a := 0
	var b := 0
	match nivel:
		1:
			a = randi_range(3, 9)
			b = randi_range(3, 9)
		2:
			a = randi_range(12, 29)
			b = randi_range(3, 9)
		_:
			a = randi_range(13, 39)
			b = randi_range(11, 24)

	var corect := a * b
	return _intrebare_numerica(
		"%d %s %d = ?" % [a, ORI, b],
		corect,
		[corect + a, corect - a, corect + 10, corect - 10, corect + b, corect - b],
		"",
		"%d %s %d = %d" % [a, ORI, b, corect]
	)


## „4 + 3 × 5 = ?" → 19, nu 35.
##
## TIPARUL ĂSTA EXISTĂ PENTRU O SINGURĂ VARIANTĂ GREȘITĂ: rezultatul calculat
## de la stânga la dreapta. 35 nu e un distractor inventat, e răspunsul
## cuiva care nu știe că înmulțirea se face întâi — deci întrebarea verifică
## exact regula pe care o numește antetul ei.
##
## De-aia toți factorii sunt ≥ 2: cu c = 1, (a+b)×c ar fi egal cu a+b×c, iar
## greșeala n-ar mai fi o variantă.
func _ordinea_operatiilor(nivel: int) -> Dictionary:
	# Factorii cresc cu nivelul, nu doar numărul de termeni. Întâi erau 2..9 la
	# toate trei, iar `verifica_numere` a picat pe „7 → 7 → 7": nivelul I
	# servea „8 + 9 × 7", care nu e nivelul I al nimănui, iar III nu era mai
	# greu prin NUMERE, doar prin lungime.
	var jos: int = [2, 2, 3][nivel - 1]
	var sus: int = [6, 9, 12][nivel - 1]
	var a := randi_range(jos, sus)
	var b := randi_range(jos, sus)
	var c := randi_range(jos, sus)
	var d := randi_range(jos, sus)

	var enunt := ""
	var corect := 0
	var stanga_dreapta := 0

	match nivel:
		1:
			# a + b × c
			enunt = "%d %s %d %s %d" % [a, PLUS, b, ORI, c]
			corect = a + b * c
			stanga_dreapta = (a + b) * c
		2:
			# a + b × c - d
			enunt = "%d %s %d %s %d %s %d" % [a, PLUS, b, ORI, c, MINUS, d]
			corect = a + b * c - d
			stanga_dreapta = (a + b) * c - d
		_:
			# a × b + c × d — două înmulțiri, deci două locuri de greșit
			enunt = "%d %s %d %s %d %s %d" % [a, ORI, b, PLUS, c, ORI, d]
			corect = a * b + c * d
			stanga_dreapta = (a * b + c) * d

	if corect <= 0:
		return {}

	return _intrebare_numerica(
		"%s = ?" % enunt,
		corect,
		[stanga_dreapta, corect + 10, corect - 10, corect + 1, corect - 1, corect + 2],
		"",
		"Intai inmultirea, apoi adunarea: %s = %d (nu %d, de la stanga la dreapta)." % [
			enunt, corect, stanga_dreapta
		]
	)


## „126 : 7 = ?"
##
## Se construiește DIN RĂSPUNS: alegi câtul și divizorul, apoi le înmulțești ca
## să afli deîmpărțitul. Invers (un număr la întâmplare împărțit la altul) ar
## fi dat resturi, iar un rest într-o întrebare cu patru butoane nu e o
## dificultate, e o ambiguitate.
func _impartire(nivel: int) -> Dictionary:
	var divizor := 0
	var cat := 0
	match nivel:
		1:
			divizor = randi_range(3, 9)
			cat = randi_range(3, 9)
		2:
			divizor = randi_range(3, 9)
			cat = randi_range(11, 29)
		_:
			divizor = randi_range(4, 12)
			cat = randi_range(15, 45)

	var deimpartit := divizor * cat
	return _intrebare_numerica(
		"%d %s %d = ?" % [deimpartit, IMPARTIT, divizor],
		cat,
		[cat + 1, cat - 1, cat + 10, cat - 10, cat + 2, cat - 2],
		"",
		"%d %s %d = %d, fiindca %d %s %d = %d" % [
			deimpartit, IMPARTIT, divizor, cat, cat, ORI, divizor, deimpartit
		]
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — PROCENTE
#
# Toate trei tiparele au numerele alese ca răspunsul să fie ÎNTREG. Nu e o
# scutire de dificultate (greul la procente e să ști ce se împarte la ce, nu
# să ai zecimale pe ecran) — e condiția ca patru butoane să fie cinstite:
# „20,4" și „20,40" sunt același număr scris în două feluri, iar într-o
# întrebare cu variante asta e o capcană despre scriere, nu despre socoteală.
# ─────────────────────────────────────────────────────────────

## „15% din 240 = ?" → 36
##
## Marea greșeală de la procente e VIRGULA: împarți la 10 o dată mai mult sau
## mai puțin și ieși cu 3,6 sau 360. Amândouă sunt în listă, și intră doar dacă
## sunt întregi — un „3,6" printre butoane s-ar elimina din formă.
## A doua greșeală, și e subtilă: răspunsul la procentul rotund de lângă
## (10% în loc de 15%), adică „am rotunjit întrebarea".
func _procent_din(nivel: int) -> Dictionary:
	var procent := 0
	var baza := 0
	match nivel:
		1:
			procent = [10, 25, 50].pick_random()
			baza = randi_range(2, 10) * 20
		2:
			procent = [15, 20, 30, 40, 75].pick_random()
			baza = randi_range(2, 15) * 20
		_:
			procent = [8, 12, 16, 24, 36, 44, 64].pick_random()
			baza = randi_range(3, 20) * 25

	var corect := procent * baza / 100
	# Aceeași gardă ca la `_cat_la_suta` și `_reducere`: răspunsul trebuie să
	# iasă întreg. Ține prin construcție (bază multiplu de 20 cu procent
	# multiplu de 5, bază multiplu de 25 cu procent multiplu de 4), dar
	# invarianta se scrie în cod, nu într-un comentariu — un procent adăugat
	# mâine în vreuna din liste ar fi dat o zecimală rotunjită pe furiș.
	if corect <= 0 or corect * 100 != procent * baza:
		return {}

	# Virgula mutată, în amândouă direcțiile — dar numai cât iese ÎNTREG.
	# „3" în locul lui „3,6" ar fi tot o greșeală plauzibilă, însă ea și-ar
	# ascunde chiar natura: pe buton n-ar mai scrie virgula mutată, ar scrie un
	# număr rotund. Varianta se lasă deoparte și intră vecinătatea.
	var candidati: Array = [corect * 10]
	if corect % 10 == 0:
		candidati.append(corect / 10)
	# Cât RĂMÂNE, nu cât se ia: greșeala celui care a citit altceva.
	candidati.append(baza - corect)
	# Procentul rotund de lângă (10% în loc de 15%), adică „am rotunjit
	# întrebarea". Tot numai dacă e întreg: bazele de la nivelul III sunt
	# multipli de 25, deci a zecea parte din ele nu există.
	if baza % 10 == 0:
		candidati.append(baza / 10)
	candidati.append_array([corect + 10, corect - 10, corect + 1])

	return _intrebare_numerica(
		"%d%% din %d = ?" % [procent, baza],
		corect,
		candidati,
		"",
		"%d%% din %d: %d %s 100 %s %d = %d" % [
			procent, baza, baza, IMPARTIT, ORI, procent, corect
		]
	)


## „Cat la suta din 240 e 36?" → 15%
##
## Greșeala-rege aici e ÎMPĂRȚIREA INVERSĂ: 240 : 36 în loc de 36 : 240. Intră
## ca variantă doar când iese un procent întreg și nu prea mare — altfel ar fi
## un 666% care se elimină singur, adică un buton irosit. Lângă el stă
## complementul (100 − p), greșeala celui care a citit „cât rămâne".
func _cat_la_suta(nivel: int) -> Dictionary:
	var procent := 0
	match nivel:
		1:
			procent = [10, 25, 50, 75].pick_random()
		2:
			procent = [15, 20, 30, 40, 60, 80].pick_random()
		_:
			procent = [5, 35, 45, 55, 65, 85, 95].pick_random()

	# Totalul crește cu nivelul, nu doar procentul. Măsurat, nu presupus:
	# `verifica_numere` se uită la cel mai mare număr din enunț, mediat pe sute
	# de trageri, și a picat exact pe tiparul ăsta când totalul era același la
	# toate trei nivelurile.
	var total: int = randi_range([2, 5, 12][nivel - 1], [6, 14, 25][nivel - 1]) * 20
	var parte := procent * total / 100
	# PARTEA TREBUIE SĂ IASĂ ÎNTREAGĂ. Ține cât totalul e multiplu de 20 și
	# procentul de 5 — adică cât timp tabelele de mai sus rămân cum sunt. Garda
	# e aici fiindcă invarianta e a NUMERELOR, nu a comentariului: primul
	# procent care nu e multiplu de 5 ar fi dat un „36,5" rotunjit în tăcere la
	# 36, iar întrebarea ar fi arătat perfect normală. (Vezi `_reducere`, unde
	# chiar așa s-a întâmplat.)
	if parte <= 0 or parte * 100 != procent * total:
		return {}

	var candidati: Array = [100 - procent]
	# Împărțirea inversă, dacă iese un număr care arată ca un procent. Peste
	# 400% n-ar mai fi o greșeală, ar fi un buton irosit: se elimină din formă.
	var invers := total * 100 / parte
	if invers <= 400 and invers * parte == total * 100:
		candidati.append(invers)
	candidati.append_array([procent + 10, procent - 10, procent + 5, procent - 5])

	return _intrebare_numerica(
		"Cat la suta din %d e %d?" % [total, parte],
		procent,
		candidati,
		"%",
		"%d %s %d = %s, adica %d%%" % [parte, IMPARTIT, total, _zecimala(procent), procent]
	)


## „Un pret de 240 de monede scade cu 15%. Cat devine?" → 204
##
## Prima variantă greșită e REDUCEREA ÎNSĂȘI (36): calculată corect, dar
## răspuns la altă întrebare. E, cu mult, greșeala cea mai des făcută la
## tiparul ăsta, și de-aia tiparul merită să existe separat de `_procent_din`:
## el nu mai verifică socoteala procentului, verifică CITITUL enunțului.
##
## „Monede" nu e decor: e moneda expediției (vezi `Expeditie`). O disciplină
## care vorbește limba jocului costă un cuvânt și se leagă de restul.
func _reducere(nivel: int) -> Dictionary:
	var procent := 0
	match nivel:
		1:
			procent = [10, 25, 50].pick_random()
		2:
			procent = [15, 20, 30, 40].pick_random()
		_:
			procent = [12, 16, 24, 36, 44].pick_random()

	# PASUL PREȚULUI E AL NIVELULUI, și nu e o cochetărie de echilibru — e
	# condiția ca reducerea să iasă ÎNTREAGĂ. 10% din 75 e 7,5, iar prima
	# versiune a tiparului ăsta trunchia la 7 și punea „10% din 75 e 7" în
	# notă: o întrebare de aritmetică greșită într-un joc de învățat. A scăpat
	# și de verificare, fiindcă `verifica_numere` refăcea socoteala cu ACEEAȘI
	# împărțire de întregi — o verificare care copiază formula nu verifică
	# formula. Acum: pasul 20 cu procente multiplu de 5 (nivelurile I-II), 25 cu
	# multiplu de 4 (nivelul III), amândouă exacte, plus garda de dedesubt.
	var pas := 25 if nivel == 3 else 20
	var pret: int = randi_range([2, 5, 10][nivel - 1], [6, 14, 24][nivel - 1]) * pas
	var reducere := procent * pret / 100
	var corect := pret - reducere
	if reducere <= 0 or corect <= 0 or reducere * 100 != procent * pret:
		return {}

	return _intrebare_numerica(
		"Un pret de %d de monede scade cu %d%%.\nCat devine?" % [pret, procent],
		corect,
		[reducere, pret - procent, pret + reducere, corect + 10, corect - 10, corect + 1],
		"",
		"%d%% din %d e %d, deci pretul devine %d %s %d = %d" % [
			procent, pret, reducere, pret, MINUS, reducere, corect
		]
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — ESTIMARE
#
# Aici se rupe, dinadins, regula de bază a fișierului: variantele NU sunt
# apropiate. Vezi antetul — priceperea măsurată e mărimea, deci variante
# apropiate ar cere calculul exact, adică alt tipar.
#
# Amândouă tiparele spun pe față că răspunsul e aproximativ („Cam cat..."), iar
# nota de după arată valoarea exactă. Fără rândul ăla, un jucător care
# calculează corect 14 976 are dreptate să se simtă păcălit de butonul 15 000.
# ─────────────────────────────────────────────────────────────

## „Cam cat e 312 × 48?" → 15 000 (nu 1 500, nu 150 000)
##
## Variantele sunt de zece ori una de alta, deci întrebarea se rezolvă NUMĂRÂND
## CIFRELE: 3 cifre × 2 cifre dă 4 sau 5 cifre, iar 3 × 5 ≈ 15. Nicio înmulțire
## nu e cerută, și asta e chiar priceperea.
func _ordin_de_marime(nivel: int) -> Dictionary:
	var a := 0
	var b := 0
	match nivel:
		1:
			a = randi_range(21, 89)
			b = randi_range(21, 89)
		2:
			a = randi_range(110, 980)
			b = randi_range(21, 89)
		_:
			a = randi_range(110, 980)
			b = randi_range(110, 980)

	var exact := a * b
	var rotund := _doua_cifre_semnificative(exact)
	if rotund <= 0:
		return {}

	return _intrebare_numerica(
		"Cam cat e %d %s %d?" % [a, ORI, b],
		rotund,
		[rotund * 10, rotund / 10, rotund * 100],
		"",
		"%d %s %d = %s, deci cam %s" % [a, ORI, b, _numar(exact), _numar(rotund)]
	)


## „Cam cat fac 198 + 403 + 299?" → 900
##
## Celălalt fel de estimare: nu ordinul de mărime, ci ROTUNJIREA fiecărui
## termen înainte de adunare. De-aia variantele sunt aici la o sută una de
## alta, nu la zece ori: priceperea e „198 e cam 200", nu „are trei cifre".
##
## Termenii se aleg lipiți de o sută rotundă (±2..18), iar întrebarea se
## aruncă dacă suma cade prea departe de suta cea mai apropiată: la 950 ar fi
## fost DOUĂ variante la fel de aproape, adică două răspunsuri bune.
func _suma_rotunjita(nivel: int) -> Dictionary:
	var cati: int = [3, 4, 4][nivel - 1]
	var sute_max: int = [5, 8, 12][nivel - 1]

	var termeni: Array[int] = []
	var exact := 0
	for i in range(cati):
		var sute := randi_range(1, sute_max) * 100
		var abatere := randi_range(2, 18) * (1 if randf() < 0.5 else -1)
		var t: int = sute + abatere
		termeni.append(t)
		exact += t

	var rotund := int(round(float(exact) / 100.0)) * 100
	if absi(exact - rotund) > 35:
		return {}

	var bucati: Array[String] = []
	for t in termeni:
		bucati.append(str(t))
	var enunt := (" %s " % PLUS).join(bucati)

	return _intrebare_numerica(
		"Cam cat fac %s?" % enunt,
		rotund,
		[rotund + 100, rotund - 100, rotund + 200, rotund - 200, rotund + 300],
		"",
		"%s = %s, deci cam %s" % [enunt, _numar(exact), _numar(rotund)]
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 4 — CÂNTARUL
#
# Singurul tip la care variantele nu sunt rezultate, ci VALORI de cântărit. Și
# singurul care amestecă trei scrieri ale aceluiași fel de număr — fracție,
# zecimală, procent. Priceperea e traducerea dintre ele, care e exact ce
# lipsește cel mai des: „3/8 sau 37%?" nu se rezolvă cu o socoteală, se
# rezolvă trecându-le pe amândouă în aceeași limbă.
# ─────────────────────────────────────────────────────────────

## „Care valoare e cea mai mare?" → 3/4 dintre 0,55 · 1/5 · 3/4 · 65%
##
## DOUĂ GARANȚII, și amândouă sunt despre întrebări stricate, nu despre
## echilibru:
##   • cele patru valori sunt la cel puțin `DISTANTA_CANTAR` sutimi una de
##     alta. La zero, 2/5 și 0,4 și 40% ar fi același număr pe trei butoane.
##   • cel puțin două scrieri diferite printre cele patru. Patru procente ar
##     fi o întrebare despre care cifră e mai mare, adică alt tipar.
func _cea_mai_mare(nivel: int) -> Dictionary:
	var alese := _valori_depatrate(DISTANTA_CANTAR[nivel - 1])
	if alese.is_empty():
		return {}

	# Scrierea se trage la sorți (vezi `_scrie_valoare`), deci textul se compune
	# O DATĂ și se ține minte. A doua chemare pentru aceeași valoare ar fi dat
	# alt text — iar răspunsul corect ar fi fost un buton care nu există.
	var variante: Array[String] = []
	var scrieri := {}              # text -> sutimi
	var text_corect := ""
	var maxim := -1
	for valoare in alese:
		var sutimi := int(valoare["sutimi"])
		var text := _scrie_valoare(valoare, nivel)
		variante.append(text)
		scrieri[text] = sutimi
		if sutimi > maxim:
			maxim = sutimi
			text_corect = text

	# Două valori la fel de mari n-au cum să apară (distanța o interzice), dar
	# două TEXTE identice ar putea, dacă tabelul crește strâmb — iar atunci ar
	# fi două butoane identice. Baza le-ar prinde în luptă, cu `push_error`;
	# aici se evită cu o reîncercare.
	if scrieri.size() != VARIANTE:
		return {}
	# Cel puțin două scrieri diferite: patru procente ar fi o întrebare despre
	# care cifră e mai mare, adică alt tipar.
	if _cate_feluri(variante) < 2:
		return {}

	# Nota le pune pe toate patru în aceeași limbă — adică face chiar munca pe
	# care a cerut-o întrebarea. Sortată pe VALOARE, nu pe text: „10%" înaintea
	# lui „9/10" ar fi o ordine alfabetică într-un rând de numere.
	var ordonate: Array[String] = variante.duplicate()
	ordonate.sort_custom(func(a, b): return int(scrieri[a]) < int(scrieri[b]))
	var in_procente: Array[String] = []
	for text in ordonate:
		in_procente.append("%s = %d%%" % [text, scrieri[text]])

	variante.shuffle()
	return {
		"text": "Care valoare e cea mai mare?",
		"variante": variante,
		"corect": variante.find(text_corect),
		"explicatie": "  ·  ".join(in_procente),
	}


## „Cat e 3/4?" → 75%
##
## Prima variantă greșită e CIFRELE CITITE CA UN NUMĂR: 3/4 → „34%". Pare o
## glumă până o vezi aleasă; e aceeași greșeală ca virgula mutată de la
## procente, numai că la fracții. Lângă ea stă complementul (25% = cât
## RĂMÂNE) și fracția întoarsă.
##
## Nivelul III întoarce direcția: ți se dă procentul, variantele sunt fracții.
## De la fracție la procent e o traducere cu o regulă („împarte"); invers
## trebuie să recunoști numărul, și e măsurabil mai greu — aceeași distincție
## dintre RECUNOAȘTERE și EVOCARE pentru care Cuvintele au două tipare de
## definiție.
func _echivalenta(nivel: int) -> Dictionary:
	var cu_fractie: Array = VALORI_CANTAR.filter(func(v): return String(v["fractie"]) != "")
	if cu_fractie.size() < VARIANTE:
		return {}
	var tinta: Dictionary = cu_fractie.pick_random()
	var sutimi := int(tinta["sutimi"])
	var fractie := String(tinta["fractie"])

	if nivel == 3:
		# PROCENT → FRACȚIE. Variantele sunt fracțiile vecinilor; fracția
		# întoarsă n-ar fi fost o valoare din tabel, deci greșeala „citesc
		# invers" se acoperă aici cu vecinii, nu cu un număr inventat.
		var gresite: Array[String] = []
		var vecini: Array = cu_fractie.duplicate()
		vecini.shuffle()
		for vecin in vecini:
			if gresite.size() == VARIANTE - 1:
				break
			if int(vecin["sutimi"]) == sutimi:
				continue
			gresite.append(String(vecin["fractie"]))
		if gresite.size() < VARIANTE - 1:
			return {}

		var variante_f: Array[String] = [fractie]
		variante_f.append_array(gresite)
		variante_f.shuffle()
		return {
			"text": "Care fractie e egala cu %d%%?" % sutimi,
			"variante": variante_f,
			"corect": variante_f.find(fractie),
			"explicatie": "%d%% = %d/100 = %s" % [sutimi, sutimi, fractie],
		}

	# FRACȚIE → PROCENT (nivelul I) sau FRACȚIE → ZECIMALĂ (nivelul II).
	var bucati := fractie.split("/")
	var sus := int(bucati[0])
	var jos := int(bucati[1])

	# Cifrele fracției lipite: „3/4" citit ca 34. La zecimi („3/10") nu există
	# greșeala asta — 310 n-ar fi un procent, ar fi un buton de aruncat — deci
	# candidatul se stinge cu un 0, pe care motorul îl respinge oricum.
	var cifrele_lipite := sus * 10 + jos if jos < 10 else 0

	if nivel == 1:
		# Tot ce iese din 1..99 se taie AICI, nu în motor: un procent peste 100
		# pentru o fracție mai mică decât 1 se elimină din formă, iar motorul
		# (care servește și tipare unde 300 e un răspuns cinstit) n-are de unde
		# să știe asta.
		var candidati: Array = []
		for c in [cifrele_lipite, 100 - sutimi, jos * 10, sus * 10, sutimi + 10, sutimi - 10]:
			if c > 0 and c < 100:
				candidati.append(c)

		return _intrebare_numerica(
			"Cat e %s, in procente?" % fractie,
			sutimi,
			candidati,
			"%",
			"%s = %d %s %d = %s = %d%%" % [
				fractie, sus, IMPARTIT, jos, _zecimala(sutimi), sutimi
			]
		)

	# Nivelul II: variantele sunt zecimale, deci se compun ca text (nu prin
	# `_intrebare_numerica`, care lucrează pe întregi).
	var candidate: Array[int] = [cifrele_lipite, 100 - sutimi, sutimi + 10, sutimi - 10]
	var gresite_z: Array[String] = []
	for c in candidate:
		if gresite_z.size() == VARIANTE - 1:
			break
		if c == sutimi or c <= 0 or c >= 100:
			continue
		var text := _zecimala(c)
		if not (text in gresite_z):
			gresite_z.append(text)
	if gresite_z.size() < VARIANTE - 1:
		return {}

	var variante_z: Array[String] = [_zecimala(sutimi)]
	variante_z.append_array(gresite_z)
	variante_z.shuffle()
	return {
		"text": "Cat e %s, ca numar zecimal?" % fractie,
		"variante": variante_z,
		"corect": variante_z.find(_zecimala(sutimi)),
		"explicatie": "%s = %d %s %d = %s" % [fractie, sus, IMPARTIT, jos, _zecimala(sutimi)],
	}


# ─────────────────────────────────────────────────────────────
# MOTORUL VARIANTELOR
# ─────────────────────────────────────────────────────────────

## O întrebare cu răspuns ÎNTREG, din răspunsul corect și lista de greșeli.
##
## `candidati` vine în ordinea în care greșelile sunt tentante: prima e cea a
## tiparului (ordinea inversă, virgula mutată, reducerea în loc de preț), la
## coadă stă vecinătatea (±1, ±10). Se iau primele trei care TREC, deci
## umplutura intră doar când miezul nu ajunge.
##
## Ce aruncă o greșeală, și de ce fiecare:
##   • egală cu răspunsul corect — ar fi un al doilea buton bun, adică o
##     întrebare stricată. (Se întâmplă: la „4 + 3 × 5" cu c = 1, ordinea
##     inversă dă chiar răspunsul bun. De-aia factorii sunt ≥ 2, dar garda
##     rămâne: ea apără tiparele care NU și-au dat seama.)
##   • zero sau negativă — se elimină din formă, nu din socoteală.
##   • deja aleasă — două butoane identice; `puzzle.gd` nici nu le-ar accepta.
##
## Mai puțin de trei greșeli bune = Dictionary GOL, iar `_compune_intrebare`
## încearcă alt tipar. Un tipar are voie să dea greș; o întrebare, nu.
func _intrebare_numerica(
	text: String,
	corect: int,
	candidati: Array,
	sufix: String,
	explicatie: String
) -> Dictionary:
	if corect <= 0:
		return {}

	var gresite: Array[int] = []
	for candidat in candidati:
		if gresite.size() == VARIANTE - 1:
			break
		var c := int(candidat)
		if c == corect or c <= 0 or c in gresite:
			continue
		gresite.append(c)
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [_eticheta(corect, sufix)]
	for gresita in gresite:
		variante.append(_eticheta(gresita, sufix))
	variante.shuffle()

	return {
		"text": text,
		"variante": variante,
		"corect": variante.find(_eticheta(corect, sufix)),
		"explicatie": explicatie,
	}


## Numărul de pe buton: grupat pe mii, cu sufixul lui („%", sau nimic).
func _eticheta(valoare: int, sufix: String) -> String:
	return "%s%s" % [_numar(valoare), sufix]


## 15000 → „15 000". Grupat cu SPAȚIU, nu cu punct: punctul se citește ca
## virgulă zecimală de către jumătate din lume, iar jumătatea aia sunt chiar
## variantele de la ESTIMARE, unde singura informație e mărimea.
func _numar(valoare: int) -> String:
	var cifre := str(absi(valoare))
	var grupuri: Array[String] = []
	while cifre.length() > 3:
		grupuri.push_front(cifre.substr(cifre.length() - 3))
		cifre = cifre.substr(0, cifre.length() - 3)
	grupuri.push_front(cifre)
	var text := " ".join(grupuri)
	return text if valoare >= 0 else "%s%s" % [MINUS, text]


## Sutimi → zecimală românească: 75 → „0,75", 40 → „0,4" (nu „0,40": un zero
## la coadă pare o precizie care nu există, și pe un buton se citește ca altă
## valoare decât vecinul lui).
func _zecimala(sutimi: int) -> String:
	if sutimi % 10 == 0:
		return "0,%d" % (sutimi / 10)
	return "0,%02d" % sutimi


## Prima putere a lui zece la care numărul are două cifre semnificative.
## 14976 → 15000. Folosită numai la ESTIMARE, unde răspunsul E o rotunjire.
func _doua_cifre_semnificative(valoare: int) -> int:
	if valoare < 100:
		return valoare
	var pas := 1
	while valoare / pas >= 100:
		pas *= 10
	return int(round(float(valoare) / float(pas))) * pas


# ─────────────────────────────────────────────────────────────
# CÂNTARUL — alegerea și scrierea valorilor
# ─────────────────────────────────────────────────────────────

## Patru valori din tabel, fiecare la cel puțin `distanta` sutimi de celelalte.
## Lista goală = n-a ieșit (tabelul e prea subțire pentru distanța cerută).
##
## Alegerea e lacomă pe o listă amestecată, nu o căutare: la 17 valori și
## distanța cea mai mare (15 sutimi) încap exact patru, deci uneori ratează —
## și e în regulă, `_compune_intrebare` încearcă alt tipar. O căutare adevărată
## ar fi fost cod pentru un caz care se rezolvă cu o reîncercare.
func _valori_depatrate(distanta: int) -> Array:
	var amestecate: Array = VALORI_CANTAR.duplicate()
	amestecate.shuffle()

	var alese: Array = []
	for valoare in amestecate:
		if alese.size() == VARIANTE:
			break
		var incape := true
		for alt in alese:
			if absi(int(valoare["sutimi"]) - int(alt["sutimi"])) < distanta:
				incape = false
				break
		if incape:
			alese.append(valoare)

	return alese if alese.size() == VARIANTE else []


## Cum se scrie o valoare pe buton: fracție, zecimală sau procent.
##
## Alegerea e o funcție de NIVEL, nu de noroc curat: la nivelul I procentul și
## zecimala sunt cele mai ușor de comparat, la III fracția e preferată când
## valoarea o are. Deci dificultatea urcă prin SCRIERE, nu doar prin distanță.
##
## SE TRAGE LA SORȚI, deci cheamă-o o dată pe valoare și ține minte ce a ieșit
## (vezi `_cea_mai_mare`): a doua chemare dă alt text pentru același număr.
func _scrie_valoare(valoare: Dictionary, nivel: int) -> String:
	var sutimi := int(valoare["sutimi"])
	var fractie := String(valoare["fractie"])

	# Urna. Procentul și zecimala sunt mereu în ea; fracția intră de câte ori
	# e nivelul, fiindcă ea e scrierea care cere o TRADUCERE — la nivelul I o
	# dată, la III de trei ori. Așa urcă dificultatea prin scriere, nu doar
	# prin cât de apropiate sunt valorile.
	var feluri: Array[String] = ["procent", "zecimal"]
	if fractie != "":
		for i in range(nivel):
			feluri.append("fractie")

	match feluri.pick_random():
		"fractie":
			return fractie
		"zecimal":
			return _zecimala(sutimi)
		_:
			return "%d%%" % sutimi


## Câte FELURI de scriere sunt printre variante (fracție / zecimală / procent).
## Sub două, întrebarea nu mai e despre traducere.
func _cate_feluri(variante: Array[String]) -> int:
	var feluri := {}
	for text in variante:
		if "/" in text:
			feluri["fractie"] = true
		elif "%" in text:
			feluri["procent"] = true
		else:
			feluri["zecimal"] = true
	return feluri.size()

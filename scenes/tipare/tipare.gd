extends Puzzle
## Disciplina TIPARE — a cincea, și prima care PRIMEȘTE conținut de la alta.
##
## Toate celelalte patru au început de la zero. Asta începe cu nouă tipare deja
## scrise, jucate și verificate: șirurile numerice, care trăiau la Logică și
## care de azi sunt aici. Mutarea nu e o curățenie, e pasul 2 din ruta de
## construcție („seriile numerice se mută din Logică în Tipare"), scris în pitch
## de la bun început: „altfel același conținut apare în două Obeliscuri".
##
## Un jucător cu Logică și Tipare în loadout ar fi primit „2, 6, 12, 20, ?" din
## două butoane diferite și ar fi crezut, pe bună dreptate, că una din cele două
## discipline e un decor.
##
## PATRU TIPURI, optsprezece tipare:
##   SIR     — nouă tipare mutate din Logică: pas constant, factor, pas
##             crescător, alternant, pas dublat, mixt, Fibonacci, pătrate
##   LITERE  — alfabetul ca șir: pas în alfabet, două fire împletite, pas care
##             crește. Aceeași gândire ca la șiruri, dar fără cifre — deci nu se
##             poate ocoli cu o socoteală
##   CICLUL  — un șablon care se repetă: ce urmează, ce e pe locul 23, și două
##             roți de lungimi diferite care se întorc odată
##   INTRUS  — un singur număr strică regula. Nu continui șirul, îl JUDECI
##
## ─────────────────────────────────────────────────────────────
## UNDE STĂ DIFICULTATEA, ȘI DE CE TABELUL ARATĂ ALTFEL DECÂT LA NUMERE
##
## La Numere, `GENERATOARE` n-are coloana „niveluri": „7 × 8" și „24 × 17" sunt
## același tipar la două niveluri, fiindcă acolo greul stă în NUMERE. La Logică
## are, fiindcă acolo greul stă în REGULĂ: „Fibonacci" e greu prin construcție,
## cu orice numere.
##
## Tipare are coloana „niveluri" ȘI primește `nivel` în fiecare metodă, și e
## singura disciplină la care amândouă sunt adevărate deodată. Fibonacci nu
## devine ușor cu numere mici, deci tiparul își declară nivelul; dar „pas în
## alfabet" cu pasul 2 și cu pasul 5 sunt două dificultăți, deci tiparul
## primește și nivelul. Un tipar poate apărea la două niveluri cu numere
## diferite, sau la unul singur — tabelul spune care.
##
## METODELE CARE NU FOLOSESC `nivel` îl scriu `_nivel`, cu underscore. Așa cere
## GDScript ca să nu avertizeze pentru un parametru nefolosit — dar motivul
## pentru care parametrul EXISTĂ oricum e altul: un contract uniform. Un tipar
## care mâine urcă la două niveluri își schimbă corpul, nu semnătura, și nici
## tabelul de verificări nu trebuie să știe cine primește ce.
##
## ─────────────────────────────────────────────────────────────
## CE NU E AICI, ȘI DE CE
##
## MATRICEA (un tabel 3×3 cu o celulă lipsă). E cel mai „tipar" lucru din toate
## câte s-ar putea pune aici, și a căzut dintr-un motiv care n-are nimic de-a
## face cu dificultatea: **un tabel scris ca text nu se aliniază.** Cinzel și
## Alegreya (fonturile temei) nu sunt monospațiate, deci „2 · 4 · 8" peste
## „15 · 30 · 60" iese strâmb, iar o matrice cu coloanele deplasate se citește
## ca o greșeală de desenare. Matricea cere o GRILĂ desenată, adică o schimbare
## în `puzzle.gd` pentru toate disciplinile — exact genul de ramură pe care
## regula din CLAUDE.md o interzice. Locul ei firesc e lângă Spațial (#7), unde
## formele se desenează oricum.
##
## ȘIRURI DE SIMBOLURI DESENATE (triunghi, cerc, pătrat, care se rotesc). Tot
## pentru desenare: ca text ar fi fost caractere Unicode („▲ ● ■"), iar niciunul
## nu e garantat în Cinzel. Litera e singurul simbol din joc care există în toate
## trei fonturile — de-aia tipul se cheamă LITERE și nu SIMBOLURI.

# Câte variante are o întrebare. Tot 4, ca la celelalte; baza verifică oricum.
const VARIANTE := 4

# Câți termeni se VĂD într-un șir. Generatoarele produc unul în plus: ultimul
# e răspunsul. (Numărul vine neschimbat de la Logică, unde a fost reglat la
# ochi: cu patru termeni, prea multe reguli se potrivesc deodată.)
const TERMENI_VIZIBILI := 5

# Semnul înmulțirii, folosit în NOTE (nu în enunțuri: un șir nu scrie operații).
# „×" și nu „x", din același motiv pentru care `numere.gd` îl folosește, iar
# motivul e verificat, nu presupus: `verifica_tipare` cere ca fiecare caracter
# al fiecărei întrebări să existe în Cinzel, în Alegreya ȘI în fontul implicit.
# Un caracter care lipsește dintr-un font se desenează ca un dreptunghi gol.
const ORI := "×"

# ─────────────────────────────────────────────────────────────
# ALFABETUL, și de ce se declară în fiecare enunț
#
# „A, C, E, G, ?" are DOUĂ răspunsuri, și asta nu e o subtilitate: în alfabetul
# românesc (31 de litere) după A vin Ă și Â, deci pasul 2 de la A dă Â, nu C.
# Un jucător român care numără pe alfabetul pe care l-a învățat la școală
# răspunde altceva decât generatorul, și are dreptate.
#
# Soluția e cea pe care proiectul a luat-o deja o dată, la enigme („Enunțul
# unei enigme își declară distribuția"): dacă o întrebare are nevoie de o
# convenție ca să aibă un singur răspuns, convenția se SCRIE în enunț, nu se
# presupune. De-aia fiecare întrebare de litere începe cu un rând care spune pe
# ce alfabet se numără. Costă 18 semne de citit la fiecare întrebare și scoate
# ambiguitatea cu totul.
#
# Diacriticele ar fi fost oricum o a doua problemă: „Ă" și „Ș" nu sunt
# garantate în fonturile temei.
# ─────────────────────────────────────────────────────────────
const ALFABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ANTET_ALFABET := "In alfabetul A-Z:\n"

# Câți termeni se văd la INTRUS. Mai mulți decât la șiruri, și dinadins: aici
# nu cauți continuarea, cauți regula — iar cu cinci termeni din care unul e
# stricat rămân patru diferențe, adică prea puține ca o singură poveste să fie
# limpede. Pasul crescător primește unul în plus fiindcă familia lui are trei
# parametri (vezi `_pozitii_posibile`): cu mai puțini termeni, prea multe
# reguli trec prin aceleași puncte.
const TERMENI_INTRUS := 6
const TERMENI_INTRUS_CRESCATOR := 7

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Un tabel, ca la Logică, la Cuvinte și la Numere: un tipar nou e o funcție și
# un rând.
#
#   „tip"      — familia. ASTA se alege prima, nu tiparul: SIR are nouă tipare
#                și LITERE trei, deci fără treapta întâi ai fi jucat aproape
#                numai șiruri numerice — chiar greșeala pentru care se mută
#                aici din Logică.
#   „niveluri" — la ce dificultăți poate apărea tiparul. Vezi antetul: aici
#                nivelul e și al regulii, și al numerelor.
#   „categorie"— ce scrie în antet. Spune ce fel de tipar e, nu care e regula.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# N-are coloana „necesita", ca la Logică: disciplina asta nu citește niciun
# fișier. E a doua după Numere care nu are nimic pe disc, și pentru același
# motiv — regula E conținutul.
#
# ECHILIBRUL: fiecare TIP trebuie să existe la toate cele trei niveluri, altfel
# la nivelul unde lipsește ceilalți își împart între ei toată probabilitatea.
# `verifica_tipare` bate regula asta, nu doar o scrie.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# ȘIRURI NUMERICE — cele nouă mutate din `logica.gd`. Nivelurile sunt
	# neschimbate: ele erau deja o judecată făcută, iar mutarea n-a fost o
	# ocazie s-o redeschid.
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "metoda": "_pas_constant"},
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "metoda": "_factor_constant"},
	{"tip": "SIR", "niveluri": [1], "categorie": "SIR NUMERIC", "metoda": "_pas_negativ"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "metoda": "_pas_crescator"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "metoda": "_alternant"},
	{"tip": "SIR", "niveluri": [2], "categorie": "SIR NUMERIC", "metoda": "_pas_dublat"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "metoda": "_mixt"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "metoda": "_fibonacci"},
	{"tip": "SIR", "niveluri": [3], "categorie": "SIR NUMERIC", "metoda": "_patrate"},

	# LITERELE — aceeași gândire ca la șiruri, fără cifre. Pasul crește cu
	# nivelul la primul tipar, deci el apare la două niveluri cu două
	# dificultăți.
	{"tip": "LITERE", "niveluri": [1, 2], "categorie": "SIR DE LITERE", "metoda": "_litere_pas"},
	{"tip": "LITERE", "niveluri": [2, 3], "categorie": "SIR DE LITERE", "metoda": "_litere_fire"},
	{"tip": "LITERE", "niveluri": [3], "categorie": "SIR DE LITERE", "metoda": "_litere_pas_crescator"},

	# CICLUL — un șablon care se repetă. Al doilea și al treilea tipar nu mai
	# cer continuarea, cer o împărțire cu rest: de-aia sunt la nivelurile II și
	# III, deși regula e la fel de simplă.
	{"tip": "CICLUL", "niveluri": [1], "categorie": "SABLON", "metoda": "_ciclu_urmatorul"},
	{"tip": "CICLUL", "niveluri": [2, 3], "categorie": "SABLON", "metoda": "_ciclu_pe_loc"},
	{"tip": "CICLUL", "niveluri": [3], "categorie": "DOUA ROTI", "metoda": "_ciclu_doua_roti"},

	# INTRUSUL — un număr strică regula. Mecanica se cheamă la fel ca „intrusul"
	# de la Logică și e cu totul altceva, iar pitch-ul o spune pe față: „mecanica
	# «intrus» apare la mai multe discipline — corect, dar cu conținut diferit".
	# Acolo intrusul se găsește din SENS („leu, tigru, ghepard, ciment"), aici
	# din REGULĂ. Nimic din cele două nu se poate rezolva cu priceperea
	# celeilalte.
	{"tip": "INTRUS", "niveluri": [1], "categorie": "INTRUSUL DIN SIR", "metoda": "_intrus_din_pas"},
	{"tip": "INTRUS", "niveluri": [2], "categorie": "INTRUSUL DIN SIR", "metoda": "_intrus_din_factor"},
	{"tip": "INTRUS", "niveluri": [3], "categorie": "INTRUSUL DIN SIR", "metoda": "_intrus_din_pas_crescator"},
]


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește datele. N-are ce — tiparele nu stau pe disc. Rămâne scrisă,
## goală, fiindcă e jumătate din contract (vezi `numere.gd`, unde e tot goală).
func _pregateste_datele() -> void:
	pass


## A doua: produce o întrebare pentru nivelul cerut.
##
## Lista întoarsă de `_retete_amestecate` e și ordinea de rezervă: un tipar are
## voie să dea greș. Aici asta se întâmplă la INTRUS, care CAUTĂ răspunsul în
## loc să-l construiască (vezi `_intrebare_cu_intrus`) și care aruncă enigma
## dacă două numere diferite ar putea fi, amândouă, intrusul.
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate(nivel):
		var intrebare: Dictionary = call(reteta["metoda"], nivel)
		if not intrebare.is_empty():
			intrebare["categorie"] = reteta["categorie"]
			return intrebare
	return {}


## De unde vin întrebările, pentru ecranul de eroare. Nu e un fișier.
func _descriere_sursa() -> String:
	return "generate din `scenes/tipare/tipare.gd` (fara fisier de date)"


## Tiparele potrivite nivelului, în ordinea în care merită încercate.
##
## Primul element E tragerea la sorți în două trepte (întâi tipul, apoi tiparul
## din el); restul e plasa de siguranță, amestecată și ea. Filtrul pe nivel
## vine de la Logică, ordinea de rezervă de la Numere — disciplina asta are
## nevoie de amândouă, fiindcă are și tipare legate de nivel, și tipare care pot
## da greș.
func _retete_amestecate(nivel: int) -> Array:
	var disponibile: Array = GENERATOARE.filter(func(g): return nivel in g["niveluri"])
	# Plasă de siguranță: dacă un nivel ar rămâne fără nimic, luăm tot. Nu se
	# poate întâmpla azi (`verifica_tipare` bate exact asta), dar un tabel
	# editat mâine nu trebuie să poată produce un ecran de eroare în luptă.
	if disponibile.is_empty():
		disponibile = GENERATOARE.duplicate()

	var pe_tip := {}
	for generator in disponibile:
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
# TIPUL 1 — ȘIRURI NUMERICE
#
# Cele nouă mutate din `logica.gd`, cu intervalele neatinse: ele erau reglate
# ca numerele să rămână calculabile în cap, iar un șir corect matematic dar cu
# termeni de cinci cifre nu e mai greu, e doar obositor.
#
# UN SINGUR LUCRU S-A SCHIMBAT LA MUTARE, ȘI MERITA DE MULT: nota. La Logică,
# `explicatie` era numele regulii — „PAS CONSTANT", „FIBONACCI". Atât era de
# ajuns cât nota nu se vedea nicăieri; de când există creierul din chenar
# (Practice, 21 octombrie), nota E ce afli după ce răspunzi, iar „PAS CONSTANT"
# nu spune nici care e pasul, nici care era răspunsul. Acum fiecare șir își
# explică regula cu cifrele lui.
# ─────────────────────────────────────────────────────────────

## NIVEL I — se adună mereu același număr. 3, 7, 11, 15, 19, ?
func _pas_constant(_nivel: int) -> Dictionary:
	var valoare := randi_range(1, 9)
	var pas := randi_range(2, 6)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += pas
	return _intrebare_din_sir(
		termeni,
		"Pas constant: se adauga %d de fiecare data, deci dupa %d vine %d." % [
			pas, termeni[-2], termeni[-1]
		]
	)


## NIVEL I — se înmulțește mereu cu același număr. 3, 6, 12, 24, 48, ?
func _factor_constant(_nivel: int) -> Dictionary:
	# Factorul 3 crește mult mai repede, deci pornește de mai jos: altfel
	# ultimul termen ajunge la patru cifre și devine calcul, nu tipar.
	var factor := 2 if randf() < 0.75 else 3
	var valoare := randi_range(1, 5) if factor == 2 else randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare *= factor
	return _intrebare_din_sir(
		termeni,
		"Fiecare termen e cel dinainte inmultit cu %d: %d %s %d = %d." % [
			factor, termeni[-2], ORI, factor, termeni[-1]
		]
	)


## NIVEL I — același pas, dar în jos. 58, 51, 44, 37, 30, ?
func _pas_negativ(_nivel: int) -> Dictionary:
	var pas := randi_range(3, 7)
	# Pornim destul de sus cât ultimul termen să rămână pozitiv: numerele
	# negative ar cere o a doua idee, iar la nivelul I vrem una singură.
	var valoare := randi_range(45, 70)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare -= pas
	return _intrebare_din_sir(
		termeni,
		"Pas constant in jos: se scade %d de fiecare data, deci dupa %d vine %d." % [
			pas, termeni[-2], termeni[-1]
		]
	)


## NIVEL II — pasul crește de fiecare dată. 2, 3, 5, 8, 12, ?
func _pas_crescator(_nivel: int) -> Dictionary:
	var valoare := randi_range(1, 6)
	var pas := randi_range(1, 3)
	var crestere := randi_range(1, 3)
	var termeni: Array[int] = []
	var pasii: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		# Pașii se țin minte DOAR cât sunt folosiți: la a șasea trecere pasul
		# calculat n-ar duce nicăieri, iar nota l-ar scrie ca pe o treaptă care
		# există.
		if i < TERMENI_VIZIBILI:
			pasii.append(pas)
		valoare += pas
		pas += crestere
	return _intrebare_din_sir(
		termeni,
		"Pasul creste cu %d la fiecare treapta (%s), deci dupa %d vine %d." % [
			crestere, _pasii_scrisi(pasii), termeni[-2], termeni[-1]
		]
	)


## NIVEL II — două operații care se schimbă între ele. 5, 12, 10, 17, 15, ?
## Adaosul e mereu mai mare decât scăderea, deci șirul urcă în zigzag.
func _alternant(_nivel: int) -> Dictionary:
	var valoare := randi_range(4, 12)
	var adaos := randi_range(5, 9)
	var scadere := randi_range(1, 4)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare += adaos if i % 2 == 0 else -scadere
	# Ce operație a dus la ULTIMUL termen: de ea atârnă nota.
	var a_adunat := (TERMENI_VIZIBILI - 1) % 2 == 0
	return _intrebare_din_sir(
		termeni,
		"Doua operatii care se schimba intre ele: +%d, apoi -%d. Dupa %d se %s, deci vine %d." % [
			adaos, scadere, termeni[-2],
			"adauga %d" % adaos if a_adunat else "scade %d" % scadere,
			termeni[-1]
		]
	)


## NIVEL II — pasul se dublează. 3, 5, 9, 17, 33, ?
func _pas_dublat(_nivel: int) -> Dictionary:
	var valoare := randi_range(2, 7)
	var pas := randi_range(1, 3)
	var termeni: Array[int] = []
	var pasii: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		if i < TERMENI_VIZIBILI:
			pasii.append(pas)
		valoare += pas
		pas *= 2
	return _intrebare_din_sir(
		termeni,
		"Pasul se dubleaza (%s), deci dupa %d vine %d." % [
			_pasii_scrisi(pasii), termeni[-2], termeni[-1]
		]
	)


## NIVEL III — două reguli în același șir: înmulțire, apoi adunare.
## 3, 6, 8, 16, 18, ?
func _mixt(_nivel: int) -> Dictionary:
	var valoare := randi_range(2, 5)
	var adaos := randi_range(1, 3)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		termeni.append(valoare)
		valoare = valoare * 2 if i % 2 == 0 else valoare + adaos
	var a_inmultit := (TERMENI_VIZIBILI - 1) % 2 == 0
	return _intrebare_din_sir(
		termeni,
		"Doua reguli pe rand: ori 2, apoi +%d. Dupa %d se %s, deci vine %d." % [
			adaos, termeni[-2],
			"inmulteste cu 2" if a_inmultit else "adauga %d" % adaos,
			termeni[-1]
		]
	)


## NIVEL III — fiecare termen e suma celor doi dinainte. 2, 5, 7, 12, 19, ?
## Nu pornește mereu de la 1, 1: altfel ai memora șirul, nu regula.
func _fibonacci(_nivel: int) -> Dictionary:
	var primul := randi_range(1, 5)
	var al_doilea := randi_range(2, 7)
	while al_doilea == primul:   # „4, 4, 8, ..." se citește ca o greșeală de tipar
		al_doilea = randi_range(2, 7)
	var termeni: Array[int] = [primul, al_doilea]
	while termeni.size() < TERMENI_VIZIBILI + 1:
		termeni.append(termeni[-1] + termeni[-2])
	return _intrebare_din_sir(
		termeni,
		"Fiecare termen e suma celor doi dinainte: %d + %d = %d." % [
			termeni[-3], termeni[-2], termeni[-1]
		]
	)


## NIVEL III — pătrate perfecte, uneori decalate cu o constantă.
## 9, 16, 25, 36, 49, ?   sau   11, 18, 27, 38, 51, ?
func _patrate(_nivel: int) -> Dictionary:
	var start := randi_range(1, 5)
	var adaos := randi_range(0, 2)
	var termeni: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		var n := start + i
		termeni.append(n * n + adaos)
	var ultimul := start + TERMENI_VIZIBILI
	var coada := "" if adaos == 0 else " + %d" % adaos
	return _intrebare_din_sir(
		termeni,
		"Sunt patratele numerelor de la %d la %d%s: %d %s %d%s = %d." % [
			start, ultimul, "" if adaos == 0 else ", plus %d" % adaos,
			ultimul, ORI, ultimul, coada, termeni[-1]
		]
	)


## Pașii unui șir, scriși ca „+2, +3, +4, +5". Ultimul pas (cel care duce la
## răspuns) NU se scrie: nota ar da atunci socoteala de-a gata înainte de
## propoziția care o explică.
func _pasii_scrisi(pasii: Array[int]) -> String:
	var bucati: Array[String] = []
	for i in range(pasii.size() - 1):
		bucati.append("+%d" % pasii[i])
	return ", ".join(bucati)


## Împachetează un șir de numere în forma pe care o așteaptă baza.
## Ultimul termen e răspunsul; ceilalți se văd.
func _intrebare_din_sir(termeni: Array[int], nota: String) -> Dictionary:
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
		"explicatie": nota,
	}


## Cele 3 variante greșite NU sunt numere la întâmplare — sunt GREȘELI
## PLAUZIBILE, adică rezultatele pe care le obții dacă te înșeli puțin: mai
## aplici o dată pasul, folosești diferența anterioară, sau ratezi cu 1-2.
##
## De ce contează: cu distractori aleatori, răspunsul corect e cel care „arată
## bine" și poți nimeri fără să gândești. Puzzle-ul ar arăta la fel și n-ar mai
## măsura nimic. (Aceeași regulă pe care `numere.gd` o scrie pe trei paragrafe,
## formulată aici întâi — de la ea a plecat.)
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
		if variante.size() == VARIANTE:
			break
		# Sărim peste: numere negative sau zero (se citesc ca greșeli de
		# generator), duplicate, și termeni care se văd deja în șir — ăia nu
		# păcălesc pe nimeni.
		if candidat > 0 and not (candidat in variante) and not (candidat in afisati):
			variante.append(candidat)

	# Plasă de siguranță: dacă filtrele au fost prea severe (șiruri mici, cu
	# pas 1), completăm cu vecini. Fără asta, un buton ar rămâne gol.
	var distanta := 3
	while variante.size() < VARIANTE:
		if not (raspuns + distanta in variante):
			variante.append(raspuns + distanta)
		distanta += 1

	variante.shuffle()
	return variante


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — ȘIRURI DE LITERE
#
# Aceeași gândire ca la șirurile numerice, și totuși alt mușchi: la numere poți
# ocoli tiparul cu o socoteală („diferența e 7, deci adun 7"), la litere n-ai ce
# să calculezi — trebuie să NUMERI pozițiile. De-aia tipul merită să existe pe
# lângă SIR, și nu ca încă trei rânduri în el.
#
# Fiecare enunț începe cu rândul care declară alfabetul. Vezi `ANTET_ALFABET`
# pentru de ce — pe scurt: alfabetul românesc are 31 de litere, deci „litera de
# după A" are două răspunsuri, și amândouă sunt corecte.
# ─────────────────────────────────────────────────────────────

## „A, C, E, G, ?" → I
##
## Pasul crește cu nivelul: 2-3 la nivelul I, 4-5 la II. Un pas de 1 lipsește
## dinadins — „A, B, C, D, ?" nu e un tipar, e alfabetul.
func _litere_pas(nivel: int) -> Dictionary:
	var pas: int = randi_range(2, 3) if nivel == 1 else randi_range(4, 5)
	# Startul se alege cât tot șirul (6 litere) să încapă în alfabet.
	var ultimul_start := ALFABET.length() - 1 - TERMENI_VIZIBILI * pas
	if ultimul_start < 0:
		return {}
	var start := randi_range(0, ultimul_start)

	var indici: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		indici.append(start + i * pas)

	var raspuns: int = indici[-1]
	return _intrebare_din_litere(
		indici,
		# Greșelile, în ordinea în care sunt tentante: litera de lângă (ai
		# numărat cu una în plus sau în minus), pasul aplicat de două ori, și
		# pasul neaplicat deloc (acela cade singur — e o literă care se vede
		# deja în enunț). La coadă stă vecinătatea, ca umplutură: fără ea, un
		# șir care se termină chiar la Z n-ar avea trei greșeli de pus pe
		# butoane, fiindcă jumătate din candidați ies din alfabet.
		[
			raspuns + 1, raspuns - 1, raspuns + pas, raspuns - pas,
			raspuns + 2, raspuns - 2, raspuns + 3, raspuns - 3,
		],
		"Se sare peste %s de fiecare data (pas %d), deci dupa %s vine %s." % [
			_cate_litere(pas - 1), pas, _litera(indici[-2]), _litera(raspuns)
		]
	)


## „A, Z, B, Y, C, ?" → X
##
## DOUĂ FIRE ÎMPLETITE: literele de pe locurile 1, 3, 5 urcă în alfabet, cele de
## pe 2, 4, 6 coboară (sau invers — direcția se trage la sorți, altfel răspunsul
## ar fi mereu din firul care coboară).
##
## Tiparul care se citește cel mai greșit din toată disciplina, și de-aia e la
## nivelurile II-III: ochiul vede UN șir și caută o regulă care să lege „A" de
## „Z". Priceperea măsurată e să observi că sunt două povești, nu una.
func _litere_fire(nivel: int) -> Dictionary:
	var pas: int = 1 if nivel == 2 else 2
	# Firul care urcă pornește de jos, cel care coboară de sus, cât amândouă să
	# încapă: trei termeni fiecare, deci 2 × pas de alergat.
	var cate_pe_fir := (TERMENI_VIZIBILI + 1) / 2
	var alergare := (cate_pe_fir - 1) * pas
	var jos := randi_range(0, 4)
	var sus := ALFABET.length() - 1 - randi_range(0, 4)
	if jos + alergare >= sus - alergare:
		return {}

	# Care fir e primul: cel care urcă sau cel care coboară.
	var urca_primul := randf() < 0.5
	var indici: Array[int] = []
	for i in range(TERMENI_VIZIBILI + 1):
		var al_catelea_pe_fir: int = i / 2
		var pe_firul_intai := i % 2 == 0
		var urca := pe_firul_intai == urca_primul
		if urca:
			indici.append(jos + al_catelea_pe_fir * pas)
		else:
			indici.append(sus - al_catelea_pe_fir * pas)

	# Fără litere repetate: cele două fire n-au voie să se întâlnească, altfel
	# aceeași literă apare de două ori în enunț și arată ca o greșeală.
	var vazute := {}
	for indice in indici:
		if vazute.has(indice):
			return {}
		vazute[indice] = true

	var raspuns: int = indici[-1]
	# Greșeala-rege aici: ai citit șirul ca UNUL singur și ai continuat de la
	# litera dinainte. De-aia primul candidat e vecinul ultimei litere VĂZUTE,
	# nu al răspunsului.
	var ultima_vazuta: int = indici[-2]
	return _intrebare_din_litere(
		indici,
		[
			ultima_vazuta + 1, ultima_vazuta - 1, raspuns + pas, raspuns - pas,
			raspuns + 1, raspuns - 1, raspuns + 2, raspuns - 2,
		],
		"Sunt doua siruri impletite: locurile 1, 3, 5 %s, locurile 2, 4, 6 %s. Al saselea e %s." % [
			"urca" if urca_primul else "coboara",
			"coboara" if urca_primul else "urca",
			_litera(raspuns)
		]
	)


## „A, B, D, G, K, ?" → P
##
## Pasul crește: +1, +2, +3, +4, +5. Același tipar ca `_pas_crescator` de la
## șiruri, dar fără cifre de scăzut — diferențele trebuie NUMĂRATE pe alfabet,
## ceea ce la nivelul III e chiar greul.
func _litere_pas_crescator(_nivel: int) -> Dictionary:
	# ALFABETUL ARE 26 DE LITERE, și asta hotărăște ce combinații sunt posibile,
	# nu gustul meu: cu pasul 2 și creșterea 2, cele cinci trepte (2, 4, 6, 8,
	# 10) adună 30 — adică un șir care nu încape nicăieri în alfabet, oricât de
	# jos ar porni. Combinațiile de mai jos sunt chiar cele trei care încap, iar
	# startul se alege DUPĂ ce se știe cât e de lung drumul. Varianta leneșă (le
	# trag la sorți pe toate și arunc ce nu încape) ar fi dat un tipar care pică
	# la un sfert din trageri, fără ca nimic să spună de ce.
	var combinatie: Array = [[1, 1], [1, 2], [2, 1]].pick_random()
	var pas := int(combinatie[0])
	var crestere := int(combinatie[1])

	var pasii: Array[int] = []
	var p := pas
	var drum := 0
	for i in range(TERMENI_VIZIBILI):
		pasii.append(p)
		drum += p
		p += crestere

	var indici: Array[int] = [randi_range(0, ALFABET.length() - 1 - drum)]
	for treapta in pasii:
		indici.append(indici[-1] + treapta)
	# Garda rămâne, deși acum ține prin construcție: invarianta se scrie în cod,
	# nu într-un comentariu (aceeași regulă ca la gărzile de exactitate din
	# `numere.gd`). Dacă mâine adaug o combinație care nu încape, pică aici și
	# nu pe ecran.
	if indici[-1] >= ALFABET.length():
		return {}

	var raspuns: int = indici[-1]
	return _intrebare_din_litere(
		indici,
		[
			raspuns + 1, raspuns - 1, indici[-2] + pasii[-2],
			raspuns + crestere, raspuns + 2, raspuns - 2, raspuns + 3, raspuns - 3,
		],
		"Pasul creste cu %d la fiecare treapta (%s), deci dupa %s se sare peste %s si vine %s." % [
			crestere, _pasii_scrisi(pasii), _litera(indici[-2]),
			_cate_litere(pasii[-1]), _litera(raspuns)
		]
	)


## Litera de la un indice. 0 → „A", 25 → „Z".
func _litera(indice: int) -> String:
	return ALFABET[indice]


## „o litera" sau „3 litere".
##
## Acordul se scrie, nu se lasă pe seama formatului: „se sare peste 1 litere"
## trece orice verificare automată și e totuși greșit. E chiar motivul pentru
## care la Logică există `verifica_mostrele`, o verificare care nu dă verdicte
## și se citește cu ochiul — „Emil e calugarita" era forma corectă a aceleiași
## greșeli. Aici se poate rezolva în cod, fiindcă numărul e singurul lucru care
## variază; la Logică nu se putea, fiindcă varia cuvântul.
func _cate_litere(cate: int) -> String:
	return "o litera" if cate == 1 else "%d litere" % cate


## Împachetează un șir de LITERE, dat prin indici în alfabet. Ultimul indice e
## răspunsul; ceilalți se văd.
##
## Candidații sunt și ei indici, în ordinea în care greșeala e tentantă. Cad:
## cei din afara alfabetului (un buton gol), cei egali cu răspunsul, dublurile
## și literele care se văd deja în enunț — ultimele nu păcălesc pe nimeni.
func _intrebare_din_litere(indici: Array[int], candidati: Array, nota: String) -> Dictionary:
	var raspuns: int = indici[-1]
	var afisati := indici.slice(0, indici.size() - 1)

	var alese: Array[int] = []
	for candidat in candidati:
		if alese.size() == VARIANTE - 1:
			break
		var c := int(candidat)
		if c < 0 or c >= ALFABET.length():
			continue
		if c == raspuns or c in alese or c in afisati:
			continue
		alese.append(c)
	if alese.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [_litera(raspuns)]
	for indice in alese:
		variante.append(_litera(indice))
	variante.shuffle()

	var vizibile: Array[String] = []
	for indice in afisati:
		vizibile.append(_litera(indice))

	return {
		"text": "%s%s, ?" % [ANTET_ALFABET, ", ".join(vizibile)],
		"variante": variante,
		"corect": variante.find(_litera(raspuns)),
		"explicatie": nota,
	}


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — CICLUL
#
# Un șablon care se repetă. Tipul la care cele patru butoane sunt, de obicei,
# CHIAR ȘABLONUL — și asta nu e o lene de scris distractori, e cea mai strânsă
# întrebare din disciplină: când variantele sunt exact semnele din ciclu, niciun
# buton nu se poate elimina din formă, iar fiecare variantă greșită e o poziție
# greșită, adică exact greșeala pe care o face cineva care numără pe degete.
#
# Semnele sunt LITERE trase la sorți, nu litere consecutive: „X, Y, Z, W" ar fi
# sugerat o regulă de alfabet, care nu e regula de aici.
# ─────────────────────────────────────────────────────────────

## „Q, M, B, F, Q, M, B, F, Q, M, ?" → B
##
## Șablonul are exact patru semne, deci cele patru butoane sunt tot el. Cel mai
## simplu tipar din disciplină, și singurul de la nivelul I al tipului: aici nu
## trebuie decât să vezi unde se închide ciclul.
func _ciclu_urmatorul(_nivel: int) -> Dictionary:
	var ciclu := _semne(VARIANTE)
	# Câte se văd: cel puțin de două ori ciclul, și tăiat la mijloc, ca
	# întrebarea să nu cadă niciodată chiar pe începutul unei repetări (acolo
	# răspunsul se citește fără să numeri).
	var cate := randi_range(2 * VARIANTE + 1, 3 * VARIANTE - 1)
	var vazute: Array[String] = []
	for i in range(cate):
		vazute.append(ciclu[i % VARIANTE])

	var raspuns: String = ciclu[cate % VARIANTE]
	var variante: Array[String] = ciclu.duplicate()
	variante.shuffle()
	return {
		"text": "%s, ?" % ", ".join(vazute),
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": "Sablonul %s se repeta. S-au scris %d semne, deci urmeaza al %d-lea: %s." % [
			", ".join(ciclu), cate, cate + 1, raspuns
		],
	}


## „Sablonul Q, M, B, F se repeta la nesfarsit. Ce semn e pe locul 23?" → B
##
## De aici încolo tipul nu mai cere o privire, cere o împărțire cu rest. Locul
## 23 cu un ciclu de 4: 23 = 5 × 4 + 3, deci al treilea semn. Greșeala tipică e
## exact cu unul alături (rest 0 citit ca primul semn), iar ea e pe buton,
## fiindcă butoanele sunt semnele ciclului.
func _ciclu_pe_loc(nivel: int) -> Dictionary:
	# Ciclul crește cu nivelul, fiindcă el e împărțitorul: restul la 4 se vede
	# din ultimele cifre, restul la 7 chiar se calculează.
	var lungime: int = randi_range(4, 5) if nivel == 2 else randi_range(5, 7)
	var ciclu := _semne(lungime)
	# Locul: destul de departe cât să nu se poată număra pe degete.
	var loc: int = randi_range(3, 6) * lungime + randi_range(1, lungime)

	# Pe locul 1 e primul semn, deci restul se ia din `loc - 1`.
	var indice := (loc - 1) % lungime
	var raspuns: String = ciclu[indice]

	# Variantele sunt semne ale ciclului: răspunsul plus trei altele. Primele
	# luate sunt VECINII din ciclu — greșeala „cu unul alături" e cea pe care o
	# faci când împărțirea iese bine dar numărătoarea pornește de la zero.
	var alese: Array[String] = [raspuns]
	for pas in [1, -1, 2, -2, 3, -3]:
		if alese.size() == VARIANTE:
			break
		var vecin: String = ciclu[(indice + pas + lungime * 3) % lungime]
		if not (vecin in alese):
			alese.append(vecin)
	if alese.size() < VARIANTE:
		return {}

	alese.shuffle()
	return {
		"text": "Sablonul %s se repeta la nesfarsit.\nCe semn e pe locul %d?" % [
			", ".join(ciclu), loc
		],
		"variante": alese,
		"corect": alese.find(raspuns),
		"explicatie": "%d = %d %s %d + %d, deci pe locul %d e al %d-lea semn din sablon: %s." % [
			loc, (loc - 1) / lungime, ORI, lungime, indice + 1, loc, indice + 1, raspuns
		],
	}


## „Doua roti se intorc cu un semn la fiecare pas: Q, M, B si 1, 2, 3, 4.
## La pasul 1 arata Q1. Ce arata la pasul 10?" → Q2
##
## Două cicluri de lungimi diferite, numărate deodată. E singurul tipar din
## disciplină la care trebuie să ții minte DOUĂ resturi, și e cel mai util
## dintre toate în afara jocului: așa funcționează zilele săptămânii peste ani,
## schimburile de tură și orice calendar.
##
## Lungimile sunt mereu PRIME ÎNTRE ELE (3 și 4, 3 și 5, 4 și 5), ca perechea
## să se repete abia după produsul lor — cu 2 și 4, jumătate din perechi n-ar
## apărea niciodată, și întrebarea ar fi despre roata mare singură.
func _ciclu_doua_roti(_nivel: int) -> Dictionary:
	var lungimi: Array = [[3, 4], [3, 5], [4, 5]].pick_random()
	var sus := _semne(int(lungimi[0]))
	var jos: Array[String] = []
	for i in range(int(lungimi[1])):
		jos.append(str(i + 1))

	var pas := randi_range(8, 24)
	var i_sus := (pas - 1) % sus.size()
	var i_jos := (pas - 1) % jos.size()
	var raspuns := "%s%s" % [sus[i_sus], jos[i_jos]]

	# Greșelile, în ordinea în care sunt tentante: o roată nimerită și cealaltă
	# cu unul alături (ai numărat una din două bine), apoi amândouă deplasate.
	var candidati: Array[String] = []
	for deplasare in [[0, 1], [1, 0], [0, -1], [-1, 0], [1, 1], [-1, -1]]:
		var a: int = (i_sus + int(deplasare[0]) + sus.size() * 2) % sus.size()
		var b: int = (i_jos + int(deplasare[1]) + jos.size() * 2) % jos.size()
		candidati.append("%s%s" % [sus[a], jos[b]])

	var variante: Array[String] = [raspuns]
	for candidat in candidati:
		if variante.size() == VARIANTE:
			break
		if not (candidat in variante):
			variante.append(candidat)
	if variante.size() < VARIANTE:
		return {}

	variante.shuffle()
	return {
		"text": "Doua roti se intorc cu un semn la fiecare pas: %s si %s.\nLa pasul 1 arata %s%s. Ce arata la pasul %d?" % [
			", ".join(sus), ", ".join(jos), sus[0], jos[0], pas
		],
		"variante": variante,
		"corect": variante.find(raspuns),
		"explicatie": "Prima roata are %d semne, deci la pasul %d arata al %d-lea (%s); a doua are %d si arata al %d-lea (%s)." % [
			sus.size(), pas, i_sus + 1, sus[i_sus], jos.size(), i_jos + 1, jos[i_jos]
		],
	}


## Câteva litere distincte, trase la sorți, pentru un ciclu.
##
## NU litere consecutive, și nu primele din alfabet: „A, B, C, D" ar fi sugerat
## că regula e alfabetul (care e regula tipului de dinainte, nu a acestuia), iar
## un jucător care caută regula greșită pierde timp pe o pistă pe care chiar
## i-am pus-o eu.
func _semne(cate: int) -> Array[String]:
	var indici: Array[int] = []
	for i in range(ALFABET.length()):
		indici.append(i)
	indici.shuffle()

	var alese: Array[String] = []
	for i in range(cate):
		alese.append(_litera(indici[i]))
	return alese


# ─────────────────────────────────────────────────────────────
# TIPUL 4 — INTRUSUL DIN ȘIR
#
# „Care numar strica regula?" Un șir construit după o regulă, cu UN termen
# schimbat. Nu continui tiparul, îl judeci — iar asta e o pricepere separată,
# fiindcă pentru ea trebuie să vezi regula în ÎNTREG șirul, nu doar la coada
# lui: ca să continui „2, 5, 8, 11" îți ajung ultimii doi termeni.
#
# ─────────────────────────────────────────────────────────────
# ÎNTREBAREA NU SE CREDE PE CUVÂNT, SE REZOLVĂ
#
# Tipul ăsta e al patrulea din joc care CAUTĂ răspunsul în loc să-l construiască
# (după mincinoșii, locurile și potrivirea de la Logică), și pentru același
# motiv: un șir cu un termen stricat poate avea DOUĂ citiri la fel de bune.
# „2, 5, 8, 12, 14, 17" — e 12 cel greșit (ar fi trebuit 11), sau 14 (ar fi
# trebuit 15, dacă pasul e 3 de la 12)? Dacă răspunsul nu e singur, întrebarea
# e stricată, iar jocul ar marca roșu un răspuns bun.
#
# Deci, înainte să întoarcă întrebarea, generatorul trece prin TOATE pozițiile
# și întreabă pentru fiecare: „dacă ăsta ar fi intrusul, restul șirului s-ar
# ține pe o regulă?" Dacă răspunsul e da pentru mai mult de una, enigma se
# aruncă și `_compune_intrebare` încearcă alt tipar.
#
# CE ACOPERĂ GARANȚIA, scris pe față fiindcă nicio verificare n-o poate lărgi:
# „o regulă" înseamnă una din cele TREI FAMILII pe care chiar disciplina asta le
# predă — pas constant, factor constant, pas crescător. Un cititor destul de
# inventiv poate născoci pentru orice șase numere o a patra regulă care-i
# potrivește; ce se garantează e că printre regulile pe care jocul le-a arătat
# vreodată, răspunsul e unul singur. O familie nouă la INTRUS cere un rând în
# `_pozitii_posibile`, iar clichetul din `verifica_tipare` oprește un tipar nou
# care n-are cine să-l bată.
# ─────────────────────────────────────────────────────────────

## NIVEL I — pas constant, cu un termen mutat. 2, 5, 8, 12, 14, 17 → 12
func _intrus_din_pas(_nivel: int) -> Dictionary:
	var pas := randi_range(3, 9)
	var valoare := randi_range(2, 12)
	var curat: Array[int] = []
	for i in range(TERMENI_INTRUS):
		curat.append(valoare)
		valoare += pas

	# Abaterea e mai mică decât pasul: cu abaterea egală cu pasul, termenul
	# stricat ar cădea exact pe valoarea vecinului, iar șirul ar avea două
	# numere identice — adică o altă greșeală, nu asta.
	var abatere := randi_range(1, mini(3, pas - 1))
	if randf() < 0.5:
		abatere = -abatere

	return _intrebare_cu_intrus(curat, abatere, "pas constant (+%d)" % pas)


## NIVEL II — factor constant, cu un termen înmulțit greșit.
## 3, 6, 12, 36, 48, 96 → 36 (s-a înmulțit cu 3, nu cu 2)
##
## Aici abaterea NU poate fi ±1: la „3, 6, 12, 24, 48, 96", un 49 în loc de 48 e
## o greșeală pe care n-o vezi, o calculezi. Greșeala adevărată la un șir
## geometric e înmulțirea cu factorul greșit, deci asta se pune — și nota o
## numește, fiindcă e chiar lecția.
func _intrus_din_factor(_nivel: int) -> Dictionary:
	var factor := 2
	var valoare := randi_range(2, 6)
	var curat: Array[int] = []
	for i in range(TERMENI_INTRUS):
		curat.append(valoare)
		valoare *= factor

	# Poziția se alege AICI, nu în împachetător, fiindcă abaterea atârnă de ea:
	# termenul stricat e cel dinainte ori (factor + 1).
	var k := randi_range(1, TERMENI_INTRUS - 1)
	var stricat: int = curat[k - 1] * (factor + 1)
	return _intrebare_cu_intrus(
		curat, stricat - curat[k], "factor constant (%s %d)" % [ORI, factor], k
	)


## NIVEL III — pas crescător, cu un termen mutat. 3, 4, 6, 9, 14, 18 → 14
##
## Cel mai greu dintre cele trei, și nu fiindcă regula e mai complicată: ca să
## vezi intrusul trebuie să calculezi diferențele diferențelor, iar un termen
## stricat le strică DOUĂ dintre ele — deci saltul nu arată unde e greșeala, ci
## lângă ea.
func _intrus_din_pas_crescator(_nivel: int) -> Dictionary:
	var pas := randi_range(1, 3)
	var crestere := randi_range(1, 3)
	var valoare := randi_range(2, 8)
	var curat: Array[int] = []
	for i in range(TERMENI_INTRUS_CRESCATOR):
		curat.append(valoare)
		valoare += pas
		pas += crestere

	var abatere := randi_range(1, 3)
	if randf() < 0.5:
		abatere = -abatere

	return _intrebare_cu_intrus(curat, abatere, "pas crescator (+%d de fiecare data)" % crestere)


## Împachetează un șir cu un intrus, DUPĂ ce s-a asigurat că răspunsul e unul
## singur. Dicționar gol = nu s-a putut, iar asta e o purtare normală.
##
## `abatere` e cât se mută termenul stricat față de cel curat; `indice` e
## poziția lui, sau -1 ca s-o aleagă singur. Poziția 0 nu se alege niciodată: cu
## primul termen stricat, șirul se citește la fel de bine ca unul care începe de
## la al doilea, și atunci „intrusul" e o chestiune de gust.
func _intrebare_cu_intrus(
	curat: Array[int],
	abatere: int,
	descriere: String,
	indice := -1
) -> Dictionary:
	var k := indice if indice >= 0 else randi_range(1, curat.size() - 1)
	var termeni: Array[int] = curat.duplicate()
	termeni[k] = curat[k] + abatere

	if termeni[k] <= 0 or abatere == 0:
		return {}
	# Două numere identice în șir ar fi o a doua întrebare, pusă din greșeală.
	var vazute := {}
	for t in termeni:
		if vazute.has(t):
			return {}
		vazute[t] = true

	# AICI se rezolvă enigma: dacă mai mult de o poziție ar putea fi intrusul,
	# întrebarea are două răspunsuri bune și se aruncă.
	var posibile := _pozitii_posibile(termeni)
	if posibile.size() != 1 or posibile[0] != k:
		return {}

	# Variantele: intrusul plus trei termeni din șir. Primii luați sunt VECINII
	# lui, și ei sunt cele mai bune greșeli din toată disciplina — când ai găsit
	# saltul, îți rămâne de hotărât care dintre cele două numere de la capetele
	# lui îl face. Întrebarea măsoară chiar alegerea aia.
	var alese: Array[int] = [termeni[k]]
	var ordine: Array[int] = []
	for pas in [1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6]:
		ordine.append(k + pas)
	for pozitie in ordine:
		if alese.size() == VARIANTE:
			break
		if pozitie < 0 or pozitie >= termeni.size():
			continue
		if not (termeni[pozitie] in alese):
			alese.append(termeni[pozitie])
	if alese.size() < VARIANTE:
		return {}

	var variante: Array[String] = []
	for valoare in alese:
		variante.append(str(valoare))
	# Textul răspunsului se ține minte ÎNAINTE de amestec: după, poziția lui din
	# `alese` nu mai spune nimic.
	var corect := str(termeni[k])
	variante.shuffle()

	return {
		"text": "Care numar strica regula?\n%s" % ", ".join(
			termeni.map(func(n): return str(n))
		),
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": "Regula e %s. Pe locul %d ar fi trebuit %d, nu %d." % [
			descriere, k + 1, curat[k], termeni[k]
		],
	}


## Pozițiile care AR PUTEA fi intrusul: cele pentru care restul șirului se ține
## pe o regulă din cele trei familii cunoscute.
##
## O listă cu un singur element înseamnă „întrebarea are un răspuns". Mai multe
## elemente înseamnă „are două" — și întrebarea se aruncă, nu se corectează:
## aceeași alegere ca la enigmele din Logică, unde un indiciu în plus ar fi
## rezolvat unicitatea și ar fi lungit enunțul cu un rând.
func _pozitii_posibile(termeni: Array[int]) -> Array[int]:
	var posibile: Array[int] = []
	for k in range(termeni.size()):
		if _restul_se_tine(termeni, k):
			posibile.append(k)
	return posibile


## Fără poziția `k`, restul termenilor stau pe o regulă cunoscută?
func _restul_se_tine(termeni: Array[int], k: int) -> bool:
	return (
		_se_tine_pe_pas(termeni, k)
		or _se_tine_pe_factor(termeni, k)
		or _se_tine_pe_pas_crescator(termeni, k)
	)


## PAS CONSTANT: există a și d cu t[p] = a + d·p, pentru tot p ≠ k?
##
## Nu se împarte nicăieri, și e dinadins: `d` ar fi putut ieși fracționar, iar o
## împărțire de întregi l-ar fi rotunjit în tăcere — adică verificarea ar fi
## respins pe nedrept o citire bună, deci ar fi lăsat să treacă întrebări cu
## două răspunsuri. Se înmulțește cu numitorul în loc să se împartă la el:
##   t[p]·Δp = t[p1]·Δp + Δt·(p − p1)
func _se_tine_pe_pas(termeni: Array[int], k: int) -> bool:
	var pozitii := _fara(termeni.size(), k)
	if pozitii.size() < 3:
		return true   # prea puține puncte ca să poată contrazice ceva

	var p1: int = pozitii[0]
	var p2: int = pozitii[1]
	var dp := p2 - p1
	var dt: int = termeni[p2] - termeni[p1]
	for p in pozitii:
		if termeni[p] * dp != termeni[p1] * dp + dt * (p - p1):
			return false
	return true


## FACTOR CONSTANT: există a și r (întreg, 2..5) cu t[p] = a·r^p?
##
## Factorul se caută printre întregi mici, nu se deduce: un raport fracționar
## (3/2) ar da șiruri cu termeni care nu sunt întregi, deci nu poate veni din
## niciun generator de aici. Limita e scrisă în comentariu ȘI în interval, ca să
## nu pară deducție ce e enumerare.
func _se_tine_pe_factor(termeni: Array[int], k: int) -> bool:
	var pozitii := _fara(termeni.size(), k)
	if pozitii.size() < 3:
		return true

	for r in range(2, 6):
		var p1: int = pozitii[0]
		var bun := true
		for p in pozitii:
			var asteptat: int = termeni[p1]
			for i in range(p - p1):
				asteptat *= r
			if termeni[p] != asteptat:
				bun = false
				break
		if bun:
			return true
	return false


## PAS CRESCĂTOR: există t0, s și c cu t[p] = t0 + s·p + c·p(p−1)/2?
##
## Trei parametri, deci trei puncte îi determină; restul se verifică. Sistemul
## de două ecuații se rezolvă cu determinanți, iar verificarea se face ÎNMULȚITĂ
## CU DETERMINANTUL, exact ca la pasul constant: fără nicio împărțire, deci
## fără nicio rotunjire ascunsă.
func _se_tine_pe_pas_crescator(termeni: Array[int], k: int) -> bool:
	var pozitii := _fara(termeni.size(), k)
	if pozitii.size() < 4:
		return true

	var p1: int = pozitii[0]
	var p2: int = pozitii[1]
	var p3: int = pozitii[2]
	var a1 := p2 - p1
	var c1 := _triunghiular(p2) - _triunghiular(p1)
	var d1: int = termeni[p2] - termeni[p1]
	var a2 := p3 - p1
	var c2 := _triunghiular(p3) - _triunghiular(p1)
	var d2: int = termeni[p3] - termeni[p1]

	var det := a1 * c2 - a2 * c1
	if det == 0:
		return false

	var s := d1 * c2 - d2 * c1      # s · det
	var c := a1 * d2 - a2 * d1      # c · det
	for p in pozitii:
		var stanga: int = (termeni[p] - termeni[p1]) * det
		var dreapta: int = s * (p - p1) + c * (_triunghiular(p) - _triunghiular(p1))
		if stanga != dreapta:
			return false
	return true


## p(p−1)/2 — de câte ori s-a adăugat creșterea până la poziția p.
func _triunghiular(p: int) -> int:
	return p * (p - 1) / 2


## Toate pozițiile unui șir, fără una.
func _fara(cate: int, k: int) -> Array[int]:
	var pozitii: Array[int] = []
	for p in range(cate):
		if p != k:
			pozitii.append(p)
	return pozitii

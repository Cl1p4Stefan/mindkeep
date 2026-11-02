extends Puzzle
## Disciplina REȚINERE — a șaptea, și prima la care întrebarea are DOUĂ TIMPURI.
##
## Celelalte șase au, toate, aceeași formă: tot ce trebuie ca să răspunzi e pe
## ecran cât timp răspunzi. Chiar și Spațialul, care desenează: planșa stă acolo
## până apeși. Aici nu. Aici ți se ARATĂ ceva, dispare, și abia pe urmă vine
## întrebarea despre el — fiindcă altfel disciplina nu există: „ce cifră era pe
## locul 3" cu șirul încă pe ecran e o întrebare de citit, nu de ținut minte.
##
## De-aia disciplina asta a venit la pachet cu a doua schimbare de contract din
## `puzzle.gd`, după cârligul de desenare al Spațialului: EXPUNEREA. Vezi
## `_incepe_expunerea` acolo pentru de ce e un CÂMP și nu o funcție, și de ce
## ceasul expunerii curge și în Practice, unde cel al întrebării nu curge.
##
## ─────────────────────────────────────────────────────────────
## PATRU TIPURI, TREISPREZECE TIPARE
##
##   SIRUL      — un rând de cifre distincte. Ce era pe locul 3? Ce venea după
##                9? Care cifră NU era în șir? Cum arată citit invers?
##   CAROIAJUL  — o planșă cu litere, exact aceeași figură ca la Spațial (vezi
##                mai jos de ce desenatorul se reface). Ce literă era în linia
##                2, coloana 3? Unde era K?
##   LISTA      — câteva cuvinte, în ordine. Care n-a fost? Câte erau? Pe ce
##                loc era scutul?
##   PERECHILE  — cine are ce. Singurul tip la care nu ții minte o listă, ci o
##                LEGĂTURĂ: trei lucruri și trei oameni sunt șase semne, dar
##                potrivirea dintre ele e a șaptea informație
##
## ─────────────────────────────────────────────────────────────
## EXPUNEREA SE MĂSOARĂ PE SEMN, NU PE ÎNTREBARE
##
## Pitch-ul scria „vezi o secvență 3s". Trei secunde fixe ar fi fost greșeala:
## la nivelul I se arată 4 cifre, la III nouă litere. Cu o durată fixă, nivelul
## I ar fi generos și III imposibil — iar dificultatea ar veni din VITEZA DE
## CITIT, nu din cât ții minte. Două priceperi diferite, iar disciplina asta o
## antrenează pe a doua.
##
## Deci durata e `EXPUNERE_PE_SEMN` × câte semne sunt, cu o podea și un plafon.
## Un semn e o cifră, o literă din caroiaj, un cuvânt din listă — iar la
## PERECHI, fiecare jumătate a perechii. Nivelul schimbă CÂT ai de ținut minte,
## nu cât ai la dispoziție ca să te uiți.
##
## ─────────────────────────────────────────────────────────────
## CE COSTĂ DISCIPLINA, SPUS PE FAȚĂ
##
## O întrebare de Reținere ține mai mult decât oricare alta: expunerea (2–6,5 s)
## PLUS timpul întrebării (12–15 s). În luptă asta înseamnă un lanț mai lent cu
## ea decât cu Numere sau Cuvinte.
##
## Nu e compensat azi, și e o alegere, nu o scăpare. Lanțul nu are un buget de
## timp: el se rupe la greșeală, nu la secunde (vezi CLAUDE.md, „Bucla de
## luptă"), iar singurul ceas din joc e cel pe ÎNTREBARE al Lăncierului —
## neatins de expunere, fiindcă `scurtare` taie din timpul întrebării, iar
## expunerea vine deasupra lui. Deci costul e în ritm, nu în reguli. Dacă
## vreodată apare un inamic care numără secundele unei TURE, atunci expunerea
## devine un dezavantaj măsurabil și se reglează de aici, dintr-o constantă.
##
## ─────────────────────────────────────────────────────────────
## DE CE DESENATORUL E AL SPAȚIALULUI, ȘI NU UNUL NOU
##
## `PlansaSpatiala` (din `scenes/spatial/plansa.gd`) desenează un caroiaj din
## care unele celule există, unele au o literă, una e marcată. Caroiajul de aici
## e exact asta — litere în celule. Un al doilea desenator ar fi fost a doua
## cale de a pune un text în mijlocul unei casete, cu a doua șansă să iasă
## strâmb: aceeași duplicare împotriva căreia există `puzzle.gd`.
##
## Numele clasei rămâne `PlansaSpatiala` deși o folosesc două discipline. O
## redenumire ar atinge `plansa.gd`, `spatial.gd` și antetele care o pomenesc —
## adică o jumătate de zi de curățenie pentru un cuvânt, exact socoteala din
## care `glifa_sah.gd` și-a păstrat numele după ce glifele au încetat să fie
## piese de șah. Ce contează e scris: desenatorul e al CAROIAJULUI, nu al unei
## discipline.
##
## ─────────────────────────────────────────────────────────────
## GREȘELILE SUNT LUCRURI CARE AU FOST PE ECRAN
##
## Regula care ține toată disciplina, și e sora celei de la Numere („variantele
## greșite sunt GREȘELI, nu numere").
##
## La „ce cifră era pe locul 3", variantele greșite sunt CELELALTE CIFRE DIN
## ȘIR. Dacă ar fi cifre la întâmplare, ai putea răspunde cu o amintire mult mai
## slabă: „9 îmi sună cunoscut, celelalte trei nu" — adică ai recunoaște că o
## cifră a fost pe ecran, fără să ții minte UNDE. Întrebarea ar măsura altceva
## decât scrie în ea.
##
## Umplutura (o cifră sau un lucru care n-a fost arătat) apare doar când din ce
## a fost pe ecran nu se adună trei greșeli — la nivelul I, unde se arată puțin.
## Nu e un defect ascuns, e chiar gradientul: la nivelurile mari toate cele
## patru variante au fost, fiecare, pe ecran.
##
## ─────────────────────────────────────────────────────────────
## NOTA NU E DECOR AICI, E SINGURA CALE DE A VEDEA CE AI RATAT
##
## La celelalte discipline, după un răspuns greșit enunțul e tot pe ecran și
## poți reface socoteala. Aici nu: ce trebuia ținut minte a dispărut acum
## 15 secunde. Deci fiecare notă REPETĂ ce s-a arătat, întreg, și abia pe urmă
## răspunde: „Sirul era 7 2 9 4 1, deci pe locul 3 era 9." Fără rândul ăla,
## creierul din chenar (vezi `practice.gd`) n-ar avea ce să-ți arate, iar în
## luptă ai rămâne cu senzația că jocul a inventat răspunsul.

const VARIANTE := 4

# ─────────────────────────────────────────────────────────────
# ALFABETUL CAROIAJULUI
#
# Fără I, O și Q, din același motiv ca la Spațial: pe o celulă de 30 px, I și J
# se despart printr-un cârlig de doi pixeli. Aici motivul e însă mai greu, nu
# mai ușor — litera se citește o dată, în două secunde, și pe urmă nu mai poate
# fi recitită. O literă pe care ai citit-o prost nu se mai corectează.
# ─────────────────────────────────────────────────────────────
const ALFABET := "ABCDEFGHJKLMNPRSTUVWXYZ"

# ─────────────────────────────────────────────────────────────
# CONVENȚIA, DECLARATĂ ÎN ENUNȚ
#
# A patra aplicare a aceleiași reguli, după distribuția enigmelor, alfabetul
# literelor și coordonatele Spațialului: un enunț care are nevoie de o
# convenție o DECLARĂ. „Linia 1" e sus în tabele și jos în geometria analitică.
#
# Scrisă a doua oară aici, nu luată din `spatial.gd`, și dinadins: un rând de
# text împărțit de două discipline le-ar fi legat una de alta pentru totdeauna
# (schimbi formularea la una, se schimbă și la cealaltă, fără să ceri). O
# convenție e ieftină de repetat și scumpă de împărțit.
# ─────────────────────────────────────────────────────────────
const ANTET_COORDONATE := "Liniile se numara de sus, coloanele de la stanga.\n"

# ─────────────────────────────────────────────────────────────
# CÂT STĂ PE ECRAN
#
# `EXPUNERE_PE_SEMN` e singura cifră care reglează dificultatea întregii
# discipline. Vezi antetul fișierului pentru de ce se înmulțește cu numărul de
# semne și nu e o durată fixă.
#
# Podeaua există pentru nivelul I (patru cifre × 0,62 = 2,5 s, deci ea nu se
# atinge azi — e acolo ca un tipar viitor cu două semne să nu fulgere pe ecran).
# Plafonul există pentru nivelul III al PERECHILOR: cinci perechi sunt zece
# semne, adică 6,2 s, și chiar acolo se atinge.
# ─────────────────────────────────────────────────────────────
const EXPUNERE_PE_SEMN := 0.62
const EXPUNERE_MINIMA := 2.0
const EXPUNERE_MAXIMA := 6.5

# ─────────────────────────────────────────────────────────────
# CÂT SE ARATĂ, PE NIVEL
#
# Toate patru tabelele sunt citite cu `nivel - 1`, deci au exact trei intrări.
# Caroiajul e cel mai strâns dintre ele, și nu din eleganță: nouă litere e deja
# la marginea a ce ține un om minte dintr-o privire (span-ul de cifre e 7 ± 2).
# Un caroiaj 4×4 ar fi dat șaisprezece litere într-o întrebare la care se
# întreabă UNA — adică o întrebare pe care o nimerești cu noroc, nu cu memorie.
# Plafonul desenatorului (4×4, vezi `LATURA` din `plansa.gd`) e deci mult
# deasupra celui de aici.
# ─────────────────────────────────────────────────────────────
const CIFRE_PE_NIVEL := [4, 5, 6]
const CAROIAJ_PE_NIVEL := [Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 3)]
const CUVINTE_PE_NIVEL := [4, 5, 6]
const PERECHI_PE_NIVEL := [3, 4, 5]

# ─────────────────────────────────────────────────────────────
# NUMELE ȘI LUCRURILE
#
# Toate numele sunt masculine, ca la Logică și din același motiv: tiparele
# spun „Luca avea toporul", iar un acord greșit („Ana avea") e genul de
# greșeală pe care n-o prinde nicio verificare automată și o vede orice
# cititor.
#
# Lucrurile au DOUĂ forme, și ăsta e tot rostul tabelului: ce se arată e
# nehotărât („arc", „cupa"), iar ce se întreabă e hotărât („Cine avea arcul?",
# „Cine avea cupa?"). Fără a doua coloană ar fi trebuit dedus articolul din
# gen — adică o regulă de gramatică în cod, care greșește tăcut la primul
# cuvânt neobișnuit. Două coloane scrise de mână nu pot greși decât o dată, iar
# atunci se vede în mostre.
# ─────────────────────────────────────────────────────────────
const NUME := [
	"Anton", "Bran", "Emil", "Grigore", "Luca",
	"Matei", "Petru", "Radu", "Stefan", "Vlad",
]

const LUCRURI := [
	{"unul": "arc", "acela": "arcul"},
	{"unul": "buzdugan", "acela": "buzduganul"},
	{"unul": "candela", "acela": "candela"},
	{"unul": "cheie", "acela": "cheia"},
	{"unul": "clopot", "acela": "clopotul"},
	{"unul": "coif", "acela": "coiful"},
	{"unul": "cupa", "acela": "cupa"},
	{"unul": "felinar", "acela": "felinarul"},
	{"unul": "inel", "acela": "inelul"},
	{"unul": "lant", "acela": "lantul"},
	{"unul": "pergament", "acela": "pergamentul"},
	{"unul": "potir", "acela": "potirul"},
	{"unul": "pumnal", "acela": "pumnalul"},
	{"unul": "scut", "acela": "scutul"},
	{"unul": "stindard", "acela": "stindardul"},
	{"unul": "topor", "acela": "toporul"},
]

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Tabelul obișnuit: un tipar nou e o funcție și un rând. Coloanele sunt cele de
# la Tipare și Spațial, și pentru același motiv — dificultatea e în două locuri
# deodată: tiparul declară la ce NIVELURI apare, iar metoda primește `nivel` ca
# să știe cât să arate.
#
#   „tip"      — familia. Se alege PRIMA, ca SIRUL (cinci tipare) să nu apară
#                de două ori mai des decât PERECHILE (două).
#   „niveluri" — la ce dificultăți poate apărea tiparul. „Care era prima cifră"
#                nu devine greu pe un șir mai lung, deci nu urcă la III; șirul
#                citit invers e greu oricum, deci nu coboară la I.
#   „categorie"— ce scrie în antet. Ce FEL de sarcină e, nu care e răspunsul.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# N-are coloana „necesita": a patra disciplină care nu citește nimic de pe disc,
# după Numere, Tipare și Spațial. Cele douăzeci și șase de nume și lucruri de
# mai sus sunt un vocabular de decor, nu conținut — întrebarea nu e despre ele.
#
# ECHILIBRUL: fiecare TIP există la toate cele trei niveluri. `verifica_retinere`
# bate regula, nu doar o scrie.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# SIRUL — cifre distincte, văzute o dată. Cel mai simplu tip de explicat și
	# cel mai greu de păcălit: nu e nimic de dedus, ori ai reținut, ori nu.
	{"tip": "SIRUL", "niveluri": [1, 2, 3], "categorie": "LOCUL DIN SIR", "metoda": "_sir_locul"},
	{"tip": "SIRUL", "niveluri": [1, 2, 3], "categorie": "VECINUL DIN SIR", "metoda": "_sir_vecinul"},
	{"tip": "SIRUL", "niveluri": [1, 2], "categorie": "CAPETELE SIRULUI", "metoda": "_sir_capetele"},
	{"tip": "SIRUL", "niveluri": [2, 3], "categorie": "CIFRA LIPSA", "metoda": "_sir_lipsa"},
	{"tip": "SIRUL", "niveluri": [3], "categorie": "SIRUL INTORS", "metoda": "_sir_invers"},

	# CAROIAJUL — singurul tip care DESENEAZĂ, deci singurul care folosește
	# cârligul Spațialului. Dovada, în cealaltă direcție, că el e opțional: aici
	# trei tipuri din patru nu-l cheamă.
	{"tip": "CAROIAJUL", "niveluri": [1, 2, 3], "categorie": "CELULA DIN CAROIAJ", "metoda": "_caroiaj_celula"},
	{"tip": "CAROIAJUL", "niveluri": [2, 3], "categorie": "UNDE ERA LITERA", "metoda": "_caroiaj_unde"},
	{"tip": "CAROIAJUL", "niveluri": [1, 2], "categorie": "LITERA LIPSA", "metoda": "_caroiaj_lipsa"},

	# LISTA — cuvinte, în ordine. „Câte erau" e aici fiindcă numărul e o
	# amintire de alt fel decât cuvintele: îl ai sau nu, fără să-ți aduci aminte
	# niciun cuvânt.
	{"tip": "LISTA", "niveluri": [1, 2, 3], "categorie": "CUVANTUL LIPSA", "metoda": "_lista_intrusul"},
	{"tip": "LISTA", "niveluri": [1, 2], "categorie": "CATE ERAU", "metoda": "_lista_cate"},
	{"tip": "LISTA", "niveluri": [2, 3], "categorie": "LOCUL DIN LISTA", "metoda": "_lista_al_catelea"},

	# PERECHILE — legături, nu liste. Două tipare, ca PLIEREA la Spațial: tipul
	# are o singură idee, iar a treia întrebare despre ea ar fi fost aceeași
	# întrebare cu alte cuvinte. „Cine avea" cere patru nume pe ecran, deci nu
	# coboară la nivelul I, unde se arată trei perechi.
	{"tip": "PERECHILE", "niveluri": [1, 2, 3], "categorie": "CE AVEA", "metoda": "_pereche_ce_avea"},
	{"tip": "PERECHILE", "niveluri": [2, 3], "categorie": "CINE AVEA", "metoda": "_pereche_cine_avea"},
]


# ─────────────────────────────────────────────────────────────
# CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Datele. N-are ce să citească — a patra disciplină fără fișier, după Numere,
## Tipare și Spațial. Rămâne scrisă, goală, fiindcă e jumătate din contract.
func _pregateste_datele() -> void:
	pass


## Produce o întrebare pentru nivelul cerut. Alegerea e în două trepte (întâi
## tipul, apoi tiparul din el), iar lista întoarsă de `_retete_amestecate()` e și
## ordinea de rezervă: un tipar are voie să dea greș și să lase rândul altuia.
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate(nivel):
		var intrebare: Dictionary = call(reteta["metoda"], nivel)
		if not intrebare.is_empty():
			intrebare["categorie"] = reteta["categorie"]
			return intrebare
	return {}


## De unde vin întrebările, pentru ecranul de eroare. Nu e un fișier.
func _descriere_sursa() -> String:
	return "generate din `scenes/retinere/retinere.gd` (fara fisier de date)"


## PLANȘA, pentru singurul tip care desenează. Același cod ca la Spațial, și
## același desenator: datele stau în întrebare, nodul se face din ele.
##
## În timpul expunerii planșa se vede; `puzzle.gd` o îngroapă în clipa în care
## apare întrebarea (vezi `_incheie_expunerea`). Disciplina nu face nimic pentru
## asta și nici n-ar trebui: ce se vede pe ecran e treaba bazei.
func _plansa_pentru(q: Dictionary) -> Control:
	var date: Dictionary = q.get("plansa", {})
	if date.is_empty():
		return null
	return PlansaSpatiala.din_date(date)


## CE FACE DOUĂ ÎNTREBĂRI „ACEEAȘI ÎNTREBARE". Enunțul și variantele nu ajung,
## la fel ca la Spațial, și aici greșeala ar fi fost mai mare: la întrebarea
## „ce cifra era pe locul 3", enunțul e identic la TOATE întrebările tiparului,
## iar variantele sunt cifrele șirului — deci două șiruri care sunt permutări
## unul altuia, cu același răspuns pe locul 3, ar fi fost socotite o repetare.
##
## Identitatea cuprinde deci EXPUNEREA: ce ți s-a arătat face parte din
## întrebare. Aici mai mult decât oriunde — expunerea e, practic, enunțul.
func _identitate_intrebare(q: Dictionary) -> String:
	var variante: Array = (q.get("variante", []) as Array).duplicate()
	variante.sort()
	return "%s|%s|%s|%s" % [
		q.get("text", ""), "|".join(variante),
		q.get("text_expunere", ""), _amprenta_plansei(q.get("plansa", {})),
	]


## Planșa, strânsă într-un șir. Nu e pentru ochi, e pentru comparație.
func _amprenta_plansei(date: Dictionary) -> String:
	if date.is_empty():
		return ""
	var bucati: Array[String] = ["%dx%d" % [date.get("linii", 0), date.get("coloane", 0)]]
	for celula in date.get("celule", []):
		bucati.append("%d,%d,%s" % [
			celula.get("linie", 0), celula.get("coloana", 0), celula.get("text", ""),
		])
	return ";".join(bucati)


## Tiparele potrivite nivelului, în ordinea în care merită încercate. Copie după
## `spatial.gd`: filtru pe nivel plus ordine de rezervă amestecată, grupată pe
## tip ca familiile mari să nu înghită pe cele mici.
func _retete_amestecate(nivel: int) -> Array:
	var disponibile: Array = GENERATOARE.filter(func(g): return nivel in g["niveluri"])
	# Plasă de siguranță: un nivel rămas fără tipare ar fi un ecran de eroare în
	# mijlocul unui lanț. Nu se poate întâmpla azi (`verifica_retinere` bate
	# exact asta), dar un tabel editat mâine nu trebuie să poată.
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
# UNELTELE COMUNE
# ─────────────────────────────────────────────────────────────

## Întrebarea gata făcută. Aceeași formă ca la Numere și Spațial — răspunsul bun
## plus o listă de greșeli în ordinea în care sunt tentante — cu două câmpuri în
## plus, cele ale expunerii.
##
## `cate_semne` nu e durata, e CÂT ai de ținut minte: durata se calculează din
## el (vezi `_expunere`). Un tipar nu are voie să-și aleagă secundele; dacă ar
## putea, „cât stă pe ecran" ar deveni treisprezece decizii în loc de una.
func _intrebare(
	text: String,
	corect: String,
	candidati: Array,
	nota: String,
	text_expunere: String,
	cate_semne: int,
	plansa := {}
) -> Dictionary:
	var gresite: Array[String] = []
	for candidat in candidati:
		if gresite.size() == VARIANTE - 1:
			break
		var c := String(candidat)
		if c == "" or c == corect or c in gresite:
			continue
		gresite.append(c)
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [corect]
	variante.append_array(gresite)
	variante.shuffle()

	var intrebare := {
		"text": text,
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": nota,
		"text_expunere": text_expunere,
		"expunere": _expunere(cate_semne),
	}
	if not plansa.is_empty():
		intrebare["plansa"] = plansa
	return intrebare


## Cât stă pe ecran, din câte semne sunt. Singurul loc din disciplină care
## hotărăște secunde.
func _expunere(cate_semne: int) -> float:
	return clampf(
		float(cate_semne) * EXPUNERE_PE_SEMN, EXPUNERE_MINIMA, EXPUNERE_MAXIMA
	)


## Cifre DISTINCTE, trase la sorți din 0-9.
##
## Distincte, și nu la întâmplare, din două motive care se adună: „ce cifră era
## pe locul 3" are un singur răspuns oricum, dar greșelile tiparului sunt
## celelalte cifre din șir — iar dacă un 7 ar apărea de două ori, una din
## variante ar fi și corectă, și greșită. Al doilea motiv e al jucătorului: un
## șir cu dubluri se ține minte altfel (în grupuri), deci ar amesteca două
## sarcini în aceeași întrebare.
func _cifre(cate: int) -> Array[String]:
	var toate: Array[String] = []
	for i in range(10):
		toate.append(str(i))
	toate.shuffle()
	return toate.slice(0, cate)


## Cifrele care NU sunt în șir, pentru greșelile de umplutură și pentru tiparul
## „care cifră lipsea".
func _cifre_absente(sir: Array[String]) -> Array[String]:
	var absente: Array[String] = []
	for i in range(10):
		var c := str(i)
		if not (c in sir):
			absente.append(c)
	absente.shuffle()
	return absente


## Șirul, așa cum se vede pe ecran. Două spații, nu unul: cifrele lipite se
## citesc ca un număr („72941"), iar un număr se ține minte altfel decât un șir.
func _sirul_scris(sir: Array[String]) -> String:
	return "  ".join(sir)


## Textul expunerii pentru un șir de cifre. Un singur loc, ca toate cele cinci
## tipare ale tipului să arate IDENTIC în timpul expunerii — altfel, din felul
## în care e scris ce vezi, ai putea ghici ce o să te întrebe.
func _expunerea_sirului(sir: Array[String]) -> String:
	return "Tine minte sirul:\n\n%s" % _sirul_scris(sir)


## Litere distincte din `ALFABET`. Distincte fiindcă „unde era K" ar avea două
## răspunsuri cu două K-uri pe planșă.
func _litere(cate: int) -> Array[String]:
	var toate: Array[String] = []
	for i in range(ALFABET.length()):
		toate.append(ALFABET[i])
	toate.shuffle()
	return toate.slice(0, cate)


## Numele unei celule, așa cum apare pe buton și în notă. Aceeași formulare ca
## la Spațial, ca „linia 2, coloana 3" să însemne același lucru în tot jocul.
func _numele_celulei(linie: int, coloana: int) -> String:
	return "linia %d, coloana %d" % [linie, coloana]


## Caroiajul, ca date de planșă. Dreptunghiular, nu pătrat: `CAROIAJ_PE_NIVEL`
## trece prin 2×3, fiindcă saltul de la 2×2 (patru litere) direct la 3×3 (nouă)
## ar fi sărit peste tot nivelul II.
func _caroiaj(masura: Vector2i, litere: Array[String]) -> Dictionary:
	var celule: Array = []
	for linie in range(1, masura.x + 1):
		for coloana in range(1, masura.y + 1):
			celule.append({
				"linie": linie, "coloana": coloana,
				"text": litere[(linie - 1) * masura.y + (coloana - 1)],
			})
	return {"linii": masura.x, "coloane": masura.y, "celule": celule}


## Caroiajul scris pe un rând, pentru NOTĂ. „A B / C D" înseamnă două linii de
## câte două celule — figura a dispărut de pe ecran acum cincisprezece secunde,
## iar o notă care spune doar răspunsul nu-ți arată ce ai ratat (vezi antetul
## fișierului).
func _caroiajul_scris(masura: Vector2i, litere: Array[String]) -> String:
	var randuri: Array[String] = []
	for linie in range(1, masura.x + 1):
		var bucati: Array[String] = []
		for coloana in range(1, masura.y + 1):
			bucati.append(_litera_din(litere, masura, linie, coloana))
		randuri.append(" ".join(bucati))
	return " / ".join(randuri)


## Litera din celula dată. Șir gol în afara caroiajului.
func _litera_din(litere: Array[String], masura: Vector2i, linie: int, coloana: int) -> String:
	if linie < 1 or linie > masura.x or coloana < 1 or coloana > masura.y:
		return ""
	return litere[(linie - 1) * masura.y + (coloana - 1)]


## Lucruri distincte, trase la sorți. Întoarce dicționarele din `LUCRURI`, ca
## apelantul să aibă și forma nehotărâtă (ce se arată), și pe cea hotărâtă (ce
## se întreabă).
func _lucruri(cate: int) -> Array:
	var toate: Array = LUCRURI.duplicate()
	toate.shuffle()
	return toate.slice(0, cate)


## Nume distincte, trase la sorți.
func _nume(cate: int) -> Array[String]:
	var toate: Array[String] = []
	for nume in NUME:
		toate.append(String(nume))
	toate.shuffle()
	return toate.slice(0, cate)


# ─────────────────────────────────────────────────────────────
# TIPUL 1 — SIRUL
#
# Cifre distincte, arătate o dată. Cinci tipare care întreabă cinci lucruri
# diferite despre ACELAȘI fel de expunere — și de-aia toate cinci o scriu prin
# `_expunerea_sirului()`: dacă un tipar ar formula altfel ce arată, ai învăța
# să-i recunoști întrebarea înainte s-o vezi.
# ─────────────────────────────────────────────────────────────

## „Ce cifra era pe locul 3?"
##
## Greșelile sunt celelalte cifre din șir, amestecate. Vezi antetul fișierului:
## cifre la întâmplare ar fi cerut doar să recunoști că o cifră a fost pe ecran,
## nu să ții minte unde.
func _sir_locul(nivel: int) -> Dictionary:
	var sir := _cifre(CIFRE_PE_NIVEL[nivel - 1])
	var loc := randi_range(1, sir.size())
	var corect := sir[loc - 1]

	var candidati: Array[String] = []
	for cifra in sir:
		if cifra != corect:
			candidati.append(cifra)
	candidati.shuffle()

	return _intrebare(
		"Ce cifra era pe locul %d?" % loc,
		corect,
		candidati,
		"Sirul era %s, deci pe locul %d era %s." % [_sirul_scris(sir), loc, corect],
		_expunerea_sirului(sir),
		sir.size()
	)


## „Ce cifra venea DUPA 9?"
##
## Reperul (9) NU e între variante, și n-ar fi o subtilitate: el se vede în
## enunț, deci un buton cu el pe ecran ar fi o variantă pe care o elimină și
## cine nu ține minte nimic. Lipsind, cele trei greșeli sunt toate cifre despre
## care trebuie să-ți amintești ceva.
func _sir_vecinul(nivel: int) -> Dictionary:
	var sir := _cifre(CIFRE_PE_NIVEL[nivel - 1])
	# „După" nu se poate întreba despre ultima cifră, „înainte de" nu se poate
	# întreba despre prima. Alegem întâi sensul, apoi un loc care îl permite.
	var dupa := randi() % 2 == 0
	var poz := randi_range(0, sir.size() - 2) if dupa else randi_range(1, sir.size() - 1)
	var reper := sir[poz]
	var corect := sir[poz + 1] if dupa else sir[poz - 1]

	var candidati: Array[String] = []
	for cifra in sir:
		if cifra != corect and cifra != reper:
			candidati.append(cifra)
	candidati.shuffle()
	# UMPLUTURA, la coadă: cifre care n-au fost în șir. La nivelul I șirul are
	# patru cifre, deci din el se adună doar două greșeli. Vezi antetul
	# fișierului — e gradientul, nu o scăpare.
	candidati.append_array(_cifre_absente(sir))

	return _intrebare(
		"Ce cifra venea %s %s?" % ["DUPA" if dupa else "INAINTE de", reper],
		corect,
		candidati,
		"Sirul era %s, deci %s %s venea %s." % [
			_sirul_scris(sir), "dupa" if dupa else "inainte de", reper, corect,
		],
		_expunerea_sirului(sir),
		sir.size()
	)


## „Care era PRIMA cifra din sir?"
##
## Cel mai ușor tipar al disciplinei, și tot are o greșeală care merită să fie
## prima: cifra de la CELĂLALT cap. Capetele se rețin amândouă (sunt singurele
## două poziții pe care le ai fără să numeri), deci confuzia între ele e chiar
## greșeala de făcut aici.
func _sir_capetele(nivel: int) -> Dictionary:
	var sir := _cifre(CIFRE_PE_NIVEL[nivel - 1])
	var prima := randi() % 2 == 0
	var corect := sir[0] if prima else sir[sir.size() - 1]

	var candidati: Array[String] = [sir[sir.size() - 1] if prima else sir[0]]
	var mijloc: Array[String] = sir.slice(1, sir.size() - 1)
	mijloc.shuffle()
	candidati.append_array(mijloc)

	return _intrebare(
		"Care era %s cifra din sir?" % ("PRIMA" if prima else "ULTIMA"),
		corect,
		candidati,
		"Sirul era %s, deci %s cifra era %s." % [
			_sirul_scris(sir), "prima" if prima else "ultima", corect,
		],
		_expunerea_sirului(sir),
		sir.size()
	)


## „Care din cifrele astea NU era in sir?"
##
## Singurul tipar al tipului la care răspunsul bun e lucrul care NU s-a văzut,
## iar cele trei greșeli sunt cifre care au fost. Întoarce sarcina: nu mai
## trebuie să ții minte poziții, ci MULȚIMEA — altă memorie, aceeași expunere.
func _sir_lipsa(nivel: int) -> Dictionary:
	var sir := _cifre(CIFRE_PE_NIVEL[nivel - 1])
	var absente := _cifre_absente(sir)
	if absente.is_empty():
		return {}
	var corect := absente[0]

	var candidati: Array[String] = sir.duplicate()
	candidati.shuffle()

	return _intrebare(
		"Care din cifrele astea NU era in sir?",
		corect,
		candidati,
		"Sirul era %s. %s nu apare in el." % [_sirul_scris(sir), corect],
		_expunerea_sirului(sir),
		sir.size()
	)


## „Cum arata sirul citit de la sfarsit spre inceput?"
##
## Singurul tipar din disciplină la care variantele sunt ȘIRURI întregi, și
## singurul care cere și o prelucrare, nu doar o amintire — de-aia e numai la
## nivelul III.
##
## PRIMA GREȘEALĂ E ȘIRUL ÎN ORDINEA ÎN CARE L-AI VĂZUT. Tiparul există pentru
## varianta aia: ea e răspunsul cuiva care a reținut perfect și n-a mai întors
## șirul. Fără ea, întrebarea ar măsura doar memoria, ca celelalte patru.
##
## Cinci cifre, nu șase: a întoarce în cap un șir de șase cifre ținute minte e
## altă sarcină decât cea pe care o numește disciplina.
func _sir_invers(_nivel: int) -> Dictionary:
	var sir := _cifre(5)
	var intors: Array[String] = sir.duplicate()
	intors.reverse()
	var corect := _sirul_scris(intors)

	# Greșelile, în ordinea în care sunt tentante.
	var candidati: Array[String] = [_sirul_scris(sir)]   # neîntors
	# Întors, dar cu o pereche vecină schimbată: greșeala de mână, nu de cap.
	for i in range(intors.size() - 1):
		var variat: Array[String] = intors.duplicate()
		var temp := variat[i]
		variat[i] = variat[i + 1]
		variat[i + 1] = temp
		candidati.append(_sirul_scris(variat))

	return _intrebare(
		"Cum arata sirul citit de la sfarsit spre inceput?",
		corect,
		candidati,
		"Sirul era %s, deci intors e %s." % [_sirul_scris(sir), corect],
		_expunerea_sirului(sir),
		sir.size()
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — CAROIAJUL
#
# Singurul tip care desenează. Expunerea arată planșa, iar `puzzle.gd` o
# îngroapă în clipa în care apare întrebarea: ce se vede pe ecran e treaba
# bazei, nu a disciplinei.
#
# Textul expunerii e scurt dinadins („Tine minte caroiajul.") — tot ce trebuie
# ținut minte e în figură, iar un rând lung de citit ar mânca din secundele în
# care te uiți la ea.
# ─────────────────────────────────────────────────────────────

## „Ce litera era in linia 2, coloana 3?"
func _caroiaj_celula(nivel: int) -> Dictionary:
	var masura: Vector2i = CAROIAJ_PE_NIVEL[nivel - 1]
	var litere := _litere(masura.x * masura.y)
	var linie := randi_range(1, masura.x)
	var coloana := randi_range(1, masura.y)
	var corect := _litera_din(litere, masura, linie, coloana)

	# Greșelile, în ordinea în care sunt tentante: întâi vecinele celulei
	# cerute (acolo nimerești dacă ai numărat cu un pas greșit), apoi restul
	# literelor de pe caroiaj.
	var candidati: Array[String] = []
	for pas: Vector2i in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		candidati.append(_litera_din(litere, masura, linie + pas.x, coloana + pas.y))
	var restul: Array[String] = litere.duplicate()
	restul.shuffle()
	candidati.append_array(restul)

	return _intrebare(
		ANTET_COORDONATE + "Ce litera era in linia %d, coloana %d?" % [linie, coloana],
		corect,
		candidati,
		"Caroiajul era %s. In %s era %s." % [
			_caroiajul_scris(masura, litere), _numele_celulei(linie, coloana), corect,
		],
		"Tine minte caroiajul.",
		litere.size(),
		_caroiaj(masura, litere)
	)


## „In ce celula era litera K?"
##
## Întrebarea de dinainte, întoarsă: acolo știi locul și cauți litera, aici
## știi litera și cauți locul. Nu e aceeași întrebare cu alte cuvinte —
## caroiajul se ține minte citind pe rânduri, deci „ce e în linia 2, coloana 3"
## se răspunde numărând, iar „unde era K" cere să ai litera legată de un loc.
##
## Greșelile sunt celulele VECINE celei bune, nu celule la întâmplare: a greși
## cu un pas e greșeala de făcut, iar o celulă din colțul opus ar fi o variantă
## pe care o elimini fără să-ți amintești nimic.
func _caroiaj_unde(nivel: int) -> Dictionary:
	var masura: Vector2i = CAROIAJ_PE_NIVEL[nivel - 1]
	var litere := _litere(masura.x * masura.y)
	var linie := randi_range(1, masura.x)
	var coloana := randi_range(1, masura.y)
	var litera := _litera_din(litere, masura, linie, coloana)

	var candidati: Array[String] = []
	for pas: Vector2i in [
		Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1),
	]:
		var l := linie + pas.x
		var c := coloana + pas.y
		if _litera_din(litere, masura, l, c) == "":
			continue
		candidati.append(_numele_celulei(l, c))

	return _intrebare(
		ANTET_COORDONATE + "In ce celula era litera %s?" % litera,
		_numele_celulei(linie, coloana),
		candidati,
		"Caroiajul era %s. %s era in %s." % [
			_caroiajul_scris(masura, litere), litera, _numele_celulei(linie, coloana),
		],
		"Tine minte caroiajul.",
		litere.size(),
		_caroiaj(masura, litere)
	)


## „Care din literele astea NU era pe caroiaj?"
##
## Fratele lui `_sir_lipsa`, și e aici din același motiv: la nivelul I caroiajul
## are patru litere, iar „ce era în linia 2, coloana 1" cu patru litere pe ecran
## e aproape o singură întrebare. Mulțimea, în schimb, rămâne o sarcină
## adevărată chiar și la patru.
func _caroiaj_lipsa(nivel: int) -> Dictionary:
	var masura: Vector2i = CAROIAJ_PE_NIVEL[nivel - 1]
	var litere := _litere(masura.x * masura.y)

	var absente: Array[String] = []
	for i in range(ALFABET.length()):
		var l := ALFABET[i]
		if not (l in litere):
			absente.append(l)
	if absente.is_empty():
		return {}
	absente.shuffle()

	var candidati: Array[String] = litere.duplicate()
	candidati.shuffle()

	return _intrebare(
		"Care din literele astea NU era pe caroiaj?",
		absente[0],
		candidati,
		"Caroiajul era %s. %s nu era pe el." % [
			_caroiajul_scris(masura, litere), absente[0],
		],
		"Tine minte caroiajul.",
		litere.size(),
		_caroiaj(masura, litere)
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — LISTA
#
# Cuvinte, în ordine, pe un singur rând. Pe un rând și nu pe câte unul fiecare,
# și e o măsurătoare, nu o preferință: panoul de puzzle are loc pentru vreo
# patru rânduri de enunț, iar șase cuvinte puse unul sub altul ar fi împins
# butoanele în afara lui.
# ─────────────────────────────────────────────────────────────

## Lista, așa cum se vede. Un singur loc, ca toate trei tiparele să arate
## identic în timpul expunerii.
func _expunerea_listei(cuvinte: Array[String]) -> String:
	return "Tine minte lista, in ordine:\n\n%s" % ", ".join(cuvinte)


## Cuvintele unei liste, ca șiruri (forma nehotărâtă din `LUCRURI`).
func _cuvintele(cate: int) -> Array[String]:
	var alese: Array[String] = []
	for lucru in _lucruri(cate):
		alese.append(String(lucru["unul"]))
	return alese


## „Care din cuvintele astea NU era in lista?"
func _lista_intrusul(nivel: int) -> Dictionary:
	var cate: int = CUVINTE_PE_NIVEL[nivel - 1]
	# Se trag cu unul mai mult: ultimul nu intră în listă și e răspunsul bun.
	# Așa intrusul e un cuvânt din ACEEAȘI familie ca celelalte (tot un lucru
	# din cetate), nu unul care se deosebește prin ton și se ghicește din el.
	var toate := _cuvintele(cate + 1)
	var lista: Array[String] = toate.slice(0, cate)
	var corect := toate[cate]

	var candidati: Array[String] = lista.duplicate()
	candidati.shuffle()

	return _intrebare(
		"Care din cuvintele astea NU era in lista?",
		corect,
		candidati,
		"Lista era: %s. In ea nu era %s." % [", ".join(lista), corect],
		_expunerea_listei(lista),
		lista.size()
	)


## „Cate cuvinte erau in lista?"
##
## Cel mai ciudat tipar al disciplinei, și e aici dinadins: numărul e o amintire
## de ALT FEL. Îl ai fără să-ți aduci aminte niciun cuvânt, și îl poți pierde
## deși ții minte toate cuvintele. Fără el, toată disciplina ar întreba despre
## conținut.
##
## Greșelile sunt vecinii numărului, în ordinea în care sunt tentante: unul în
## minus sau în plus (ai numărat greșit cu unul), apoi doi în plus. Niciodată un
## număr depărtat — acolo n-ar fi nimic de greșit.
func _lista_cate(nivel: int) -> Dictionary:
	var lista := _cuvintele(CUVINTE_PE_NIVEL[nivel - 1])
	var cate := lista.size()

	return _intrebare(
		"Cate cuvinte erau in lista?",
		str(cate),
		[str(cate - 1), str(cate + 1), str(cate + 2), str(cate - 2)],
		"Lista era: %s. Deci %d cuvinte." % [", ".join(lista), cate],
		_expunerea_listei(lista),
		cate
	)


## „Pe ce loc in lista era cuvantul scut?"
##
## Cere patru locuri distincte între variante, deci o listă de cel puțin patru
## cuvinte — de-aia tiparul nu coboară la nivelul I, unde lista are exact patru
## și toate locurile ar fi fost pe butoane (adică ai fi știut din start că
## răspunsul e unul din toate, ceea ce nu e o informație, dar face întrebarea
## mecanică).
func _lista_al_catelea(nivel: int) -> Dictionary:
	var lista := _cuvintele(CUVINTE_PE_NIVEL[nivel - 1])
	var loc := randi_range(1, lista.size())
	var cuvant := lista[loc - 1]

	# Greșelile: întâi locurile vecine, apoi restul. Numărarea se greșește cu
	# un pas, nu cu trei.
	var candidati: Array[String] = ["locul %d" % (loc - 1), "locul %d" % (loc + 1)]
	var restul: Array[int] = []
	for i in range(1, lista.size() + 1):
		if i != loc and absi(i - loc) > 1:
			restul.append(i)
	restul.shuffle()
	for i in restul:
		candidati.append("locul %d" % i)
	# Locurile din afara listei se scot: „locul 0" nu există, iar „locul 7" pe o
	# listă de șase ar fi o variantă pe care o elimini fără să ții minte nimic.
	var curate: Array[String] = []
	for c in candidati:
		var numar := int(String(c).trim_prefix("locul "))
		if numar >= 1 and numar <= lista.size():
			curate.append(String(c))

	return _intrebare(
		"Pe ce loc in lista era cuvantul %s?" % cuvant,
		"locul %d" % loc,
		curate,
		"Lista era: %s. Cuvantul %s era pe locul %d." % [
			", ".join(lista), cuvant, loc,
		],
		_expunerea_listei(lista),
		lista.size()
	)


# ─────────────────────────────────────────────────────────────
# TIPUL 4 — PERECHILE
#
# Singurul tip la care nu ții minte o listă, ci o LEGĂTURĂ. Trei nume și trei
# lucruri sunt șase semne, dar potrivirea dintre ele e o informație în plus,
# care nu se vede în numărătoare — de-aia PERECHILE e cel mai greu tip al
# disciplinei la același număr de semne.
#
# Expunerea le pune pe RÂNDURI, nu pe un rând: aici o pereche e o unitate, iar
# „Emil - arc, Luca - scut, Radu - coif" pe un singur rând s-ar citi ca o listă
# de șase cuvinte, adică exact sarcina de la tipul 3.
# ─────────────────────────────────────────────────────────────

## Perechile, așa cum se văd. Întoarce și textul, și perechile alese.
func _perechi(cate: int) -> Dictionary:
	var nume := _nume(cate)
	var lucruri := _lucruri(cate)
	var randuri: Array[String] = []
	for i in range(cate):
		randuri.append("%s - %s" % [nume[i], lucruri[i]["unul"]])
	return {
		"nume": nume, "lucruri": lucruri, "randuri": randuri,
		"text": "Tine minte cine are ce:\n\n%s" % "\n".join(randuri),
	}


## Perechile scrise pe un rand, pentru NOTA. Nota repeta TOT ce s-a aratat, nu
## doar perechea despre care s-a intrebat: la un raspuns gresit nu stii care
## legatura ai pierdut, iar „Emil avea arcul" singur nu-ti spune ce credeai.
func _perechile_scrise(randuri: Array[String]) -> String:
	return ", ".join(randuri)


## „Ce avea Emil?"
##
## Greșelile sunt lucrurile CELORLALȚI, în ordine amestecată: cine ține minte
## lucrurile dar nu potrivirea nu câștigă nimic de aici. La nivelul I se arată
## trei perechi, deci din ele se adună doar două greșeli, iar a treia e un lucru
## care n-a fost pe ecran — o eliminare ieftină, care E gradientul: de la
## nivelul II încolo toate patru variantele au fost arătate.
func _pereche_ce_avea(nivel: int) -> Dictionary:
	var cate: int = PERECHI_PE_NIVEL[nivel - 1]
	var date := _perechi(cate)
	var nume: Array[String] = date["nume"]
	var lucruri: Array = date["lucruri"]

	var cine := randi_range(0, cate - 1)
	var corect := String(lucruri[cine]["unul"])

	var candidati: Array[String] = []
	for i in range(cate):
		if i != cine:
			candidati.append(String(lucruri[i]["unul"]))
	candidati.shuffle()
	# Umplutura: lucruri care n-au fost arătate. Vezi antetul tiparului.
	for lucru in LUCRURI:
		var nehotarat := String(lucru["unul"])
		var gasit := false
		for ales in lucruri:
			if String(ales["unul"]) == nehotarat:
				gasit = true
				break
		if not gasit:
			candidati.append(nehotarat)

	return _intrebare(
		"Ce avea %s?" % nume[cine],
		corect,
		candidati,
		"Erau: %s. Deci %s avea %s." % [
			_perechile_scrise(date["randuri"]),
			nume[cine], String(lucruri[cine]["acela"]),
		],
		String(date["text"]),
		cate * 2
	)


## „Cine avea toporul?"
##
## Oglinda tiparului de dinainte, și tot are nevoie de el separat: legătura se
## ține minte într-un sens (ai numele în cap și cauți lucrul), iar întrebarea
## asta o cere în celălalt.
##
## Întrebarea folosește forma HOTĂRÂTĂ a lucrului („toporul", „cupa"), luată din
## coloana a doua a tabelului `LUCRURI` — vezi acolo de ce e scrisă și nu dedusă.
## Cere patru nume pe ecran, deci nu coboară la nivelul I.
func _pereche_cine_avea(nivel: int) -> Dictionary:
	var cate: int = PERECHI_PE_NIVEL[nivel - 1]
	var date := _perechi(cate)
	var nume: Array[String] = date["nume"]
	var lucruri: Array = date["lucruri"]

	var cine := randi_range(0, cate - 1)
	var corect := nume[cine]

	var candidati: Array[String] = []
	for i in range(cate):
		if i != cine:
			candidati.append(nume[i])
	candidati.shuffle()

	return _intrebare(
		"Cine avea %s?" % String(lucruri[cine]["acela"]),
		corect,
		candidati,
		"Erau: %s. Deci %s avea %s." % [
			_perechile_scrise(date["randuri"]),
			corect, String(lucruri[cine]["acela"]),
		],
		String(date["text"]),
		cate * 2
	)

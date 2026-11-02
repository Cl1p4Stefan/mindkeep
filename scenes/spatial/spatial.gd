extends Puzzle
## Disciplina SPAȚIAL — a șasea, și prima care DESENEAZĂ.
##
## Celelalte cinci se puteau scrie cu un rând de text și patru butoane. Asta nu:
## o întrebare spațială fără imagine nu e o întrebare spațială, e o ghicitoare
## despre o figură pe care n-o vezi. De-aia disciplina asta a venit la pachet cu
## singura schimbare de contract din `puzzle.gd` de la Practice încoace — un
## cârlig opțional, `_plansa_pentru()`, care întoarce un `Control`. Vezi acolo de
## ce e un NOD și nu o listă de forme, și de ce se cheamă DUPĂ alegerea
## întrebării.
##
## Schimbarea era oricum datorată: matricea 3×3 și șirurile de simboluri au
## CĂZUT din Tipare, scris în antetul lui `tipare.gd`, fiindcă „un tabel scris
## ca text nu se aliniază". Cârligul le redeschide ușa, fără ca Tipare să fie
## atins azi.
##
## ─────────────────────────────────────────────────────────────
## PATRU TIPURI, DOUĂSPREZECE TIPARE
##
##   GRILA    — un caroiaj cu litere: ce e la dreapta lui M, pe ce linie și
##              coloană stă M, pe ce literă ajungi dacă pleci de la M și faci
##              doi pași. Cel mai simplu tip, și singurul în care nu se mișcă
##              nimic: te uiți, numeri, răspunzi
##   ROTATIA  — o figură cu un punct în ea. Rotești sau oglindești planșa, și
##              spui în ce celulă ajunge punctul. ASTA e miezul disciplinei
##   BUSOLA   — singurul tip FĂRĂ planșă: întoarceri, drumuri și drumul întors,
##              toate în cap. Dovada că planșa e opțională, nu obligatorie
##   PLIEREA  — desfășurata unui cub, din șase litere. Care față e opusă lui A?
##
## ─────────────────────────────────────────────────────────────
## REGULA CARE ȚINE TOATĂ DISCIPLINA: RĂSPUNSUL E O CELULĂ, NU O IMAGINE
##
## Varianta firească pentru „cum arată figura după rotație" ar fi fost patru
## butoane cu patru figuri desenate. A căzut, și nu din lene:
##
##   • patru planșe de 4×4 pe patru butoane, într-un panou de ~400 px, înseamnă
##     celule de 12 px — sub pragul la care un punct se mai vede;
##   • butoanele sunt ale lui `puzzle.gd`, adică ale TUTUROR disciplinelor. Un
##     buton care poate purta un desen ar fi o schimbare pe care o plătesc și
##     cele cinci de dinainte, pentru ceva ce folosește una singură;
##   • și, mai important, întrebarea devine mai SLABĂ: cu patru figuri în față,
##     poți elimina trei din formă, fără să rotești nimic.
##
## Deci întrebarea cere o COORDONATĂ („linia 2, coloana 3"), iar figura rămâne
## pe o singură planșă. Ca să ceri o coordonată trebuie să fi rotit figura în
## cap — nu există scurtătură. Prețul, plătit conștient: enunțul are un rând în
## plus, cel care declară cum se numără liniile (vezi `ANTET_COORDONATE`).
##
## ─────────────────────────────────────────────────────────────
## DE CE FIGURA ARE MAI MULTE CELULE DECÂT PUNCTUL
##
## La rotații, răspunsul atârnă NUMAI de celula punctului: celelalte celule
## pline nu intră în nicio socoteală. N-ar fi fost mai curat fără ele?
##
## Nu, și aici e toată diferența dintre o întrebare spațială și una de
## aritmetică. Cu un singur punct pe o grilă goală, rotația se face cu o
## formulă („linia devine coloană"), adică e o socoteală. Cu o figură în jurul
## lui, rotești o IMAGINE și citești unde a ajuns punctul — ce antrenează
## disciplina. Celulele în plus nu sunt decor: ele sunt chiar sarcina.

const VARIANTE := 4

# ─────────────────────────────────────────────────────────────
# ALFABETUL PLANȘEI, și de ce nu e tot alfabetul
#
# Lipsesc I, O și Q. Nu din superstiție: pe o celulă de 30 px, I și J se
# despart printr-un cârlig de doi pixeli, iar O și Q prin unul de trei. O
# întrebare la care răspunsul greșit vine din faptul că n-ai putut citi litera
# nu măsoară nimic — e aceeași grijă care a scos diacriticele din `tipare.gd`,
# doar că acolo motivul era fontul și aici e mărimea.
#
# Rămân 23 de litere, iar cea mai mare planșă cere 16. Destul, cu rest.
# ─────────────────────────────────────────────────────────────
const ALFABET := "ABCDEFGHJKLMNPRSTUVWXYZ"

# ─────────────────────────────────────────────────────────────
# CONVENȚIA, DECLARATĂ ÎN ENUNȚ
#
# A treia aplicare a aceleiași reguli: enigmele își declară distribuția
# („Anton, Emil si Radu au, fiecare, alt lucru"), literele își declară
# alfabetul („In alfabetul A-Z:"), iar coordonatele își declară sensul.
#
# „Linia 1" e sus sau jos? În tabele e sus, în geometria analitică e jos, iar
# jucătorul nu trebuie să ghicească pe care din cele două gândesc eu. Un joc de
# învățare care marchează roșu un răspuns corect e mai rău decât unul greu.
# ─────────────────────────────────────────────────────────────
const ANTET_COORDONATE := "Liniile se numara de sus, coloanele de la stanga.\n"

# ─────────────────────────────────────────────────────────────
# DIRECȚIILE
#
# `DIRECTII` e în sens ORAR, dinadins: așa „la dreapta" e +1 și „la stanga"
# e -1, iar întoarcerile se fac cu o adunare în loc de un tabel de cazuri.
# `ROZA` e aceeași idee cu opt brațe, pentru direcțiile diagonale; opusul unei
# direcții e mereu la +4.
#
# Scrise cu MAJUSCULE în enunțuri fiindcă sunt singurele cuvinte din propoziție
# pe care trebuie să le reții exact — iar la 12 secunde, ce trebuie reținut
# merită să sară în ochi.
# ─────────────────────────────────────────────────────────────
const DIRECTII := ["NORD", "EST", "SUD", "VEST"]
const ROZA := [
	"NORD", "NORD-EST", "EST", "SUD-EST", "SUD", "SUD-VEST", "VEST", "NORD-VEST",
]

# Pașii pe (est, nord) pentru fiecare direcție din `DIRECTII`. „Nordul e sus" nu
# intră niciodată în socoteală — busola nu are planșă, deci nu are sus.
const PAS := [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Tabelul obișnuit: un tipar nou e o funcție și un rând. Coloanele sunt cele de
# la Tipare — și pentru același motiv, fiindcă aici dificultatea e tot în două
# locuri deodată:
#
#   „tip"      — familia. Se alege PRIMA, ca ROTATIA (patru tipare) să nu apară
#                de două ori mai des decât PLIEREA (două).
#   „niveluri" — la ce dificultăți poate apărea tiparul. O oglindire nu devine
#                grea pe o planșă mai mare, deci ea nu urcă la nivelul III;
#                două transformări una după alta sunt grele oricum, deci acel
#                tipar nu coboară la I.
#   „categorie"— ce scrie în antet. Ce FEL de sarcină e, nu care e răspunsul.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# N-are coloana „necesita": a treia disciplină care nu citește nimic de pe disc,
# după Numere și Tipare. Figurile nu sunt conținut, sunt reguli.
#
# ECHILIBRUL: fiecare TIP există la toate cele trei niveluri. `verifica_spatial`
# bate regula, nu doar o scrie.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# GRILA — te uiți și numeri. Primele două sunt citire de caroiaj; a treia
	# cere deja să ții minte unde ai ajuns între doi pași.
	{"tip": "GRILA", "niveluri": [1, 2], "categorie": "CAROIAJ", "metoda": "_grila_vecin"},
	{"tip": "GRILA", "niveluri": [1, 2], "categorie": "COORDONATE", "metoda": "_grila_coordonata"},
	{"tip": "GRILA", "niveluri": [2, 3], "categorie": "DRUM PE CAROIAJ", "metoda": "_grila_drum"},

	# ROTATIA — miezul. Ordinea nivelurilor e ordinea dificultății așa cum se
	# simte, nu cum arată formula: oglindirea e cea mai ușoară, jumătatea de
	# tură vine imediat după (e o simetrie, se vede), iar sfertul de tură e
	# saltul — el nu se poate „vedea", trebuie rotit.
	{"tip": "ROTATIA", "niveluri": [1, 2], "categorie": "OGLINDIRE", "metoda": "_oglindire"},
	{"tip": "ROTATIA", "niveluri": [1, 2], "categorie": "JUMATATE DE TURA", "metoda": "_rotatie_jumatate"},
	{"tip": "ROTATIA", "niveluri": [2, 3], "categorie": "SFERT DE TURA", "metoda": "_rotatie_sfert"},
	{"tip": "ROTATIA", "niveluri": [3], "categorie": "DOUA MISCARI", "metoda": "_rotatie_dubla"},

	# BUSOLA — fără planșă. Singurul tip la care nu te uiți la nimic.
	{"tip": "BUSOLA", "niveluri": [1, 2], "categorie": "INTOARCERI", "metoda": "_busola_intoarceri"},
	{"tip": "BUSOLA", "niveluri": [2, 3], "categorie": "INCOTRO E CETATEA", "metoda": "_busola_spre_casa"},
	{"tip": "BUSOLA", "niveluri": [3], "categorie": "DRUMUL INTORS", "metoda": "_busola_drum_intors"},

	# PLIEREA — desfășurata cubului. Două tipare, ca CANTARUL la Numere: tipul
	# are o singură idee, iar a treia întrebare despre ea ar fi fost aceeași
	# întrebare cu alte cuvinte.
	{"tip": "PLIEREA", "niveluri": [1, 2], "categorie": "FETE OPUSE", "metoda": "_pliere_perechea"},
	{"tip": "PLIEREA", "niveluri": [2, 3], "categorie": "CUBUL PLIAT", "metoda": "_pliere_opusa"},
]


# ─────────────────────────────────────────────────────────────
# CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Datele. N-are ce să citească — a treia disciplină fără fișier, după Numere și
## Tipare. Rămâne scrisă, goală, fiindcă e jumătate din contract.
func _pregateste_datele() -> void:
	pass


## Produce o întrebare pentru nivelul cerut. Alegerea e în două trepte (întâi
## tipul, apoi tiparul din el), iar lista întoarsă de `_retete_amestecate()` e
## și ordinea de rezervă: un tipar are voie să dea greș, iar aici dă des — vezi
## `_celule_deosebite()`, poarta prin care nu trec niciodată două variante care
## înseamnă aceeași celulă.
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate(nivel):
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
	return "generate din `scenes/spatial/spatial.gd` (fara fisier de date)"


## PLANȘA. Singurul loc din disciplină în care se naște un nod.
##
## Datele stau în întrebare (`q["plansa"]`), nodul se face din ele. Despărțirea
## e cerută de `puzzle.gd` și are două urmări bune: cele 11 întrebări aruncate
## de `_compune_nerepetata` nu lasă noduri orfane, iar `verifica_spatial` poate
## CITI planșa ca pe o listă de celule, fără să deschidă o fereastră.
func _plansa_pentru(q: Dictionary) -> Control:
	var date: Dictionary = q.get("plansa", {})
	if date.is_empty():
		return null
	return PlansaSpatiala.din_date(date)


## CE FACE DOUĂ ÎNTREBĂRI „ACEEAȘI ÎNTREBARE". Enunțul și variantele nu ajung
## aici, și nu e o subtilitate — e o greșeală măsurabilă:
##
## pe o planșă 4×4, punctul din linia 1 coloana 1 și punctul din linia 4
## coloana 4 dau, la un sfert de tură, ACELEAȘI patru variante (cele patru
## colțuri) și același enunț, literă cu literă. Cu identitatea implicită din
## `puzzle.gd`, a doua ar fi fost socotită o repetare a primei — și, fiind patru
## colțuri la fel, s-ar fi „repetat" tot timpul. Deci identitatea cuprinde și
## PLANȘA: ce se vede pe ecran face parte din întrebare.
func _identitate_intrebare(q: Dictionary) -> String:
	var variante: Array = (q.get("variante", []) as Array).duplicate()
	variante.sort()
	return "%s|%s|%s" % [
		q.get("text", ""), "|".join(variante), _amprenta_plansei(q.get("plansa", {})),
	]


## Planșa, strânsă într-un șir. Nu e pentru ochi, e pentru comparație: o celulă
## în plus, o literă mutată sau punctul în altă parte dau alt șir.
func _amprenta_plansei(date: Dictionary) -> String:
	if date.is_empty():
		return ""
	var bucati: Array[String] = ["%dx%d" % [date.get("linii", 0), date.get("coloane", 0)]]
	for celula in date.get("celule", []):
		bucati.append("%d,%d,%s,%s,%s" % [
			celula.get("linie", 0), celula.get("coloana", 0),
			celula.get("text", ""), celula.get("plin", false),
			celula.get("marcat", false),
		])
	return ";".join(bucati)


## Tiparele potrivite nivelului, în ordinea în care merită încercate. Copie după
## `tipare.gd`: filtru pe nivel (de la Logică) plus ordine de rezervă
## amestecată (de la Numere), fiindcă disciplina asta are nevoie de amândouă.
func _retete_amestecate(nivel: int) -> Array:
	var disponibile: Array = GENERATOARE.filter(func(g): return nivel in g["niveluri"])
	# Plasă de siguranță: un nivel rămas fără tipare ar fi un ecran de eroare în
	# mijlocul unui lanț. Nu se poate întâmpla azi (`verifica_spatial` bate
	# exact asta), dar un tabel editat mâine nu trebuie să poată.
	if disponibile.is_empty():
		disponibile = GENERATOARE.duplicate()

	var pe_tip := {}
	for generator in disponibile:
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
# UNELTELE COMUNE
# ─────────────────────────────────────────────────────────────

## Întrebarea gata făcută, din răspunsul bun și o listă de greșeli în ordinea în
## care sunt tentante. Aceeași formă ca `_intrebare_numerica` din `numere.gd`:
## se iau primele trei greșeli care nu se bat cu răspunsul bun și între ele;
## dacă nu se adună trei, tiparul dă GREȘ (dicționar gol) și `_compune_intrebare`
## trece la următorul.
##
## `plansa` goală = întrebare numai text (tot tipul BUSOLA).
func _intrebare(
	text: String,
	corect: String,
	candidati: Array,
	nota: String,
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
	}
	if not plansa.is_empty():
		intrebare["plansa"] = plansa
	return intrebare


## Litere distincte, trase la sorți din `ALFABET`. Distincte e tot rostul: două
## celule cu același M fac întrebarea „ce e la dreapta lui M" nelegitimă, iar
## greșeala n-ar fi a jucătorului.
func _litere(cate: int) -> Array[String]:
	var toate: Array[String] = []
	for i in range(ALFABET.length()):
		toate.append(ALFABET[i])
	toate.shuffle()
	return toate.slice(0, cate)


## Numele unei celule, așa cum apare pe buton și în notă.
func _numele_celulei(linie: int, coloana: int) -> String:
	return "linia %d, coloana %d" % [linie, coloana]


## Sunt toate celulele din listă DIFERITE între ele?
##
## Poarta prin care cad cele mai multe încercări ale tipului ROTATIA, și
## dinadins: la jumătatea planșei, transformările se suprapun. Punctul din
## mijlocul unei planșe 3×3 rămâne în mijloc la orice rotație și la orice
## oglindire — deci „corect" și toate trei greșelile ar fi fost aceeași celulă.
## Un tipar care dă greș aici nu e un tipar stricat; e unul care a nimerit o
## poziție simetrică și lasă rândul altuia.
func _celule_deosebite(celule: Array) -> bool:
	var vazute := {}
	for celula in celule:
		var cheie := "%d,%d" % [celula.x, celula.y]
		if vazute.has(cheie):
			return false
		vazute[cheie] = true
	return true


# ── CELE CINCI TRANSFORMĂRI ───────────────────────────────────
# Toate pe celule numerotate DE LA 1 (linie, coloană), ca în enunț. De la 0 ar
# fi fost mai scurt de scris și mai greu de citit alături de notă — iar nota
# arată chiar aceste numere.
#
# Fiecare e o funcție, nu o ramură dintr-un `match`, fiindcă tiparele le trec
# una altei ca VALORI: `_rotatie_dubla` compune două transformări fără să știe
# care sunt.

## Un sfert de tură la DREAPTA (în sens orar).
func _spre_dreapta(c: Vector2i, n: int) -> Vector2i:
	return Vector2i(c.y, n + 1 - c.x)


## Un sfert de tură la STÂNGA.
func _spre_stanga(c: Vector2i, n: int) -> Vector2i:
	return Vector2i(n + 1 - c.y, c.x)


## O jumătate de tură. Aceeași în ambele sensuri — de-aia e mai ușoară.
func _jumatate_de_tura(c: Vector2i, n: int) -> Vector2i:
	return Vector2i(n + 1 - c.x, n + 1 - c.y)


## Oglindire STÂNGA-DREAPTA: liniile rămân, coloanele se întorc.
func _oglinda_laterala(c: Vector2i, n: int) -> Vector2i:
	return Vector2i(c.x, n + 1 - c.y)


## Oglindire SUS-JOS: coloanele rămân, liniile se întorc.
func _oglinda_pe_orizontala(c: Vector2i, n: int) -> Vector2i:
	return Vector2i(n + 1 - c.x, c.y)


# ─────────────────────────────────────────────────────────────
# TIPUL 1 — GRILA
#
# Un caroiaj plin cu litere distincte. Cel mai simplu tip, și cel la care
# planșa face toată munca: fără ea, „ce literă e la dreapta lui M" ar fi cerut
# un tabel scris ca text, adică exact ce nu se aliniază în Cinzel.
#
# NIMIC NU SE MIȘCĂ aici. De-aia tipul ăsta nu are nevoie de `ANTET_COORDONATE`
# decât la tiparul care chiar cere o coordonată.
# ─────────────────────────────────────────────────────────────

## „Ce litera e imediat la DREAPTA lui M?"
##
## Celula întrebată e mereu una din INTERIOR, ca toate cele patru vecine să
## existe — fiindcă chiar ele sunt cele trei variante greșite. Asta e regula de
## la Numere („variantele greșite sunt GREȘELI, nu numere") pe un caroiaj:
## singurele litere tentante sunt cele din celelalte trei direcții. Patru litere
## trase la sorți din planșă ar fi fost patru litere, nu patru greșeli.
##
## Nivelul I joacă pe 3×3, unde interiorul e doar mijlocul; nivelul II pe 4×4,
## cu patru celule de interior. Diferența reală dintre niveluri nu e poziția, e
## cât ai de căutat ca să găsești litera de pornire.
func _grila_vecin(nivel: int) -> Dictionary:
	var n: int = 3 if nivel == 1 else 4
	var litere := _litere(n * n)
	var plansa := _plansa_cu_litere(n, litere)

	# Celulă de interior: linia și coloana între 2 și n-1.
	var linie := randi_range(2, n - 1)
	var coloana := randi_range(2, n - 1)
	var centru := Vector2i(linie, coloana)

	# Cele patru vecine. Cea aleasă e răspunsul, celelalte trei sunt greșelile —
	# exact direcțiile pe care le-ai putea citi greșit.
	# Numele direcțiilor sunt scrise ca să intre în propoziție fără să o
	# strâmbe: „imediat DEASUPRA lui M", nu „imediat SUS de M". Un enunț care
	# sună a traducere te face să-l citești de două ori, iar la 12 secunde a
	# doua citire se plătește.
	var numele_directiilor := ["DEASUPRA lui", "DEDESUBTUL lui", "la STANGA lui", "la DREAPTA lui"]
	var deplasari := [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var aleasa := randi_range(0, 3)

	var candidati: Array[String] = []
	for i in range(4):
		if i == aleasa:
			continue
		candidati.append(_litera_din(litere, n, centru + deplasari[i]))

	var corect := _litera_din(litere, n, centru + deplasari[aleasa])
	var pornire := _litera_din(litere, n, centru)

	return _intrebare(
		"Ce litera e imediat %s %s?" % [numele_directiilor[aleasa], pornire],
		corect,
		candidati,
		"%s e in %s. Imediat %s %s se afla %s." % [
			pornire, _numele_celulei(centru.x, centru.y),
			numele_directiilor[aleasa], pornire, corect,
		],
		plansa
	)


## „Pe ce linie si coloana se afla litera M?"
##
## Greșeala care dă tiparului rostul lui e PRIMA din listă: linia și coloana
## schimbate între ele. Cine citește caroiajul pe coloane înainte de linii
## nimerește exact acolo — iar dacă litera stă pe diagonală (linia egală cu
## coloana), greșeala aia nu există, deci tiparul dă greș și lasă rândul altuia.
func _grila_coordonata(nivel: int) -> Dictionary:
	var n: int = 3 if nivel == 1 else 4
	var litere := _litere(n * n)
	var plansa := _plansa_cu_litere(n, litere)

	var linie := randi_range(1, n)
	var coloana := randi_range(1, n)
	# Pe diagonală, „linia și coloana schimbate" E răspunsul corect — deci
	# tiparul își pierde singura variantă care-i dă rost. Dă greș și lasă
	# rândul altuia, în loc să pună pe ecran o notă care se contrazice.
	if linie == coloana:
		return {}
	var litera := _litera_din(litere, n, Vector2i(linie, coloana))

	# Greșelile, în ordinea în care sunt tentante: întâi cele două numere
	# schimbate, apoi un pas greșit pe fiecare axă (numărat de la zero, sau
	# unul în plus).
	var candidate: Array[Vector2i] = [
		Vector2i(coloana, linie),
		Vector2i(linie, coloana + 1), Vector2i(linie + 1, coloana),
		Vector2i(linie, coloana - 1), Vector2i(linie - 1, coloana),
	]
	var candidati: Array[String] = []
	for c in candidate:
		if c.x < 1 or c.x > n or c.y < 1 or c.y > n:
			continue
		candidati.append(_numele_celulei(c.x, c.y))

	return _intrebare(
		"%sPe ce linie si coloana se afla litera %s?" % [ANTET_COORDONATE, litera],
		_numele_celulei(linie, coloana),
		candidati,
		"%s e in %s. Capcana obisnuita e sa le spui invers: %s." % [
			litera, _numele_celulei(linie, coloana), _numele_celulei(coloana, linie),
		],
		plansa
	)


## „Pornesti de la M: 1 JOS, 2 la DREAPTA. Pe ce litera ajungi?"
##
## Primul tipar al disciplinei la care trebuie să ȚII MINTE unde ai ajuns între
## doi pași — de-aia e singurul din GRILA care urcă la nivelul III, cu trei pași
## în loc de doi.
##
## Greșelile sunt cele pe care le face cineva care numără pe degete: ultimul pas
## în direcția opusă, un pas mai scurt, un pas mai lung. Ordinea pașilor NU e
## printre ele, și nu e o omisiune: deplasările se adună, deci doi pași făcuți
## invers duc în ACEEAȘI celulă. O „greșeală" care dă răspunsul corect nu e o
## variantă, e un al doilea buton bun.
## ─────────────────────────────────────────────────────────────
## CÂT A COSTAT GREȘELILE SĂ ÎNCAPĂ PE PLANȘĂ
##
## Prima scriere avea exact trei greșeli — ultimul pas întors, mai scurt, mai
## lung — și dădea greș în **80% din încercări**, măsurat de `verifica_spatial`.
## Motivul e geometric, nu întâmplător: drumul se termină de obicei aproape de o
## margine (acolo l-au împins pașii), iar „un pas mai lung" cade atunci în afara
## planșei. Cu trei greșeli din care una e mereu pierdută, nu se mai adună trei.
##
## Deci lista de greșeli e mai lungă decât îi trebuie: fiecare pas al drumului,
## nu doar ultimul, își dă cele trei variante. Nu e umplutură — un pas întors
## la mijlocul drumului e tot o greșeală pe care o face cineva care numără pe
## degete, doar mai puțin frecventă, deci stă mai jos în listă. `_intrebare`
## oprește la primele trei care încap.
## ─────────────────────────────────────────────────────────────
func _grila_drum(nivel: int) -> Dictionary:
	var n := 4
	var cati: int = 2 if nivel == 2 else 3
	var litere := _litere(n * n)
	var plansa := _plansa_cu_litere(n, litere)

	var numele_directiilor := ["SUS", "JOS", "la STANGA", "la DREAPTA"]
	var deplasari := [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var opuse := [1, 0, 3, 2]

	for incercare in range(10):
		var start := Vector2i(randi_range(1, n), randi_range(1, n))
		var pozitie := start
		var pasi: Array[int] = []
		var cate: Array[int] = []
		var scris: Array[String] = []
		var intreg := true

		for i in range(cati):
			# Se caută o direcție care încape pe planșă. Fără doi pași la rând
			# pe aceeași axă: „1 JOS, apoi 2 JOS" e un singur pas scris în două
			# rânduri.
			var gasit := false
			for a_doua in range(12):
				var d := randi_range(0, 3)
				if not pasi.is_empty() and (d == pasi[-1] or d == opuse[pasi[-1]]):
					continue
				var cat := randi_range(1, 2)
				var dupa: Vector2i = pozitie + deplasari[d] * cat
				if dupa.x < 1 or dupa.x > n or dupa.y < 1 or dupa.y > n:
					continue
				pasi.append(d)
				cate.append(cat)
				scris.append("%d %s" % [cat, numele_directiilor[d]])
				pozitie = dupa
				gasit = true
				break
			if not gasit:
				intreg = false
				break
		if not intreg:
			continue

		# Greșelile, de la ultimul pas spre primul: fiecare pas întors, mai
		# scurt cu unul, mai lung cu unul.
		var candidate: Array[Vector2i] = []
		for i in range(pasi.size() - 1, -1, -1):
			var pas: Vector2i = deplasari[pasi[i]]
			candidate.append(pozitie - pas * (2 * cate[i]))   # pasul întors
			candidate.append(pozitie - pas)                   # cu unul mai puțin
			candidate.append(pozitie + pas)                   # cu unul mai mult

		var candidati: Array[String] = []
		for c in candidate:
			if c.x < 1 or c.x > n or c.y < 1 or c.y > n:
				continue
			if c == pozitie:
				continue
			candidati.append(_litera_din(litere, n, c))

		var litera_start := _litera_din(litere, n, start)
		var corect := _litera_din(litere, n, pozitie)
		var intrebare := _intrebare(
			"Pornesti de la %s: %s. Pe ce litera ajungi?" % [
				litera_start, ", apoi ".join(scris),
			],
			corect,
			candidati,
			"De la %s (%s), drumul duce in %s, unde e %s." % [
				litera_start, _numele_celulei(start.x, start.y),
				_numele_celulei(pozitie.x, pozitie.y), corect,
			],
			plansa
		)
		if not intrebare.is_empty():
			return intrebare
	return {}


## Caroiajul plin: toate cele n×n celule, cu literele în ordine, linie cu linie.
func _plansa_cu_litere(n: int, litere: Array[String]) -> Dictionary:
	var celule: Array = []
	for linie in range(1, n + 1):
		for coloana in range(1, n + 1):
			celule.append({
				"linie": linie, "coloana": coloana,
				"text": litere[(linie - 1) * n + (coloana - 1)],
			})
	return {"linii": n, "coloane": n, "celule": celule}


## Litera din celula dată, pe o planșă n×n umplută de `_plansa_cu_litere`.
## Șir gol în afara planșei — cine cheamă a verificat deja marginile.
func _litera_din(litere: Array[String], n: int, celula: Vector2i) -> String:
	if celula.x < 1 or celula.x > n or celula.y < 1 or celula.y > n:
		return ""
	return litere[(celula.x - 1) * n + (celula.y - 1)]


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — ROTATIA
#
# Miezul disciplinei. O figură pe o planșă, un punct în ea, o mișcare de făcut
# în cap, și o celulă de numit.
#
# TOATE PATRU TIPARELE SUNT ACEEAȘI ÎNTREBARE cu altă mișcare, și de-aia sunt
# construite din aceleași două unelte: `_plansa_cu_figura()` desenează, iar
# `_intrebare_de_miscare()` compune. Un tipar nu face decât să spună CARE
# transformare e răspunsul și care trei sunt greșelile — adică exact ce ar scrie
# un rând într-un tabel.
#
# Transformările se trec ca NUME de funcții, nu ca ramuri de `match`, fiindcă
# `_rotatie_dubla` are nevoie să COMPUNĂ două dintre ele fără să știe care sunt.
# ─────────────────────────────────────────────────────────────

## „Oglindesti plansa STANGA-DREAPTA. In ce celula ajunge punctul?"
##
## Cea mai ușoară mișcare a tipului, și singura care se poate vedea fără să
## rotești nimic. Greșelile sunt celelalte trei lucruri pe care le-ai putea
## face în locul ei: oglindirea pe cealaltă axă, jumătatea de tură (care arată
## ca o oglindire făcută de două ori) și „n-am mișcat nimic".
func _oglindire(nivel: int) -> Dictionary:
	var n: int = 3 if nivel == 1 else 4
	var pe_lateral := randf() < 0.5
	var corecta := "_oglinda_laterala" if pe_lateral else "_oglinda_pe_orizontala"
	var cealalta := "_oglinda_pe_orizontala" if pe_lateral else "_oglinda_laterala"
	var descriere := "Oglindesti plansa %s." % (
		"STANGA-DREAPTA" if pe_lateral else "SUS-JOS"
	)
	var regula := (
		"Oglindirea stanga-dreapta lasa linia neschimbata si intoarce coloana."
		if pe_lateral else
		"Oglindirea sus-jos lasa coloana neschimbata si intoarce linia."
	)
	return _intrebare_de_miscare(n, descriere, corecta, [cealalta, "_jumatate_de_tura"], regula)


## „Rotesti plansa o JUMATATE de tura. In ce celula ajunge punctul?"
##
## A doua cea mai ușoară: o jumătate de tură e o simetrie față de centru, deci
## se poate „vedea" fără să rotești. Greșelile sunt cele două sferturi de tură —
## adică „am rotit, dar nu destul".
func _rotatie_jumatate(nivel: int) -> Dictionary:
	var n: int = 3 if nivel == 1 else 4
	return _intrebare_de_miscare(
		n,
		"Rotesti plansa o JUMATATE de tura.",
		"_jumatate_de_tura",
		["_spre_dreapta", "_spre_stanga"],
		"O jumatate de tura intoarce si linia, si coloana."
	)


## „Rotesti plansa un SFERT de tura la DREAPTA. In ce celula ajunge punctul?"
##
## SALTUL disciplinei, și singurul tipar pe care nu-l poți rezolva „privind":
## un sfert de tură schimbă liniile cu coloanele, deci figura nu mai seamănă cu
## ea însăși. Greșelile: sfertul în celălalt sens (cea mai frecventă), jumătatea
## de tură și figura nemișcată.
func _rotatie_sfert(nivel: int) -> Dictionary:
	var n: int = 3 if nivel == 2 else 4
	var la_dreapta := randf() < 0.5
	var corecta := "_spre_dreapta" if la_dreapta else "_spre_stanga"
	var cealalta := "_spre_stanga" if la_dreapta else "_spre_dreapta"
	return _intrebare_de_miscare(
		n,
		"Rotesti plansa un SFERT de tura la %s." % ("DREAPTA" if la_dreapta else "STANGA"),
		corecta,
		[cealalta, "_jumatate_de_tura"],
		"La un sfert de tura la %s, linia devine coloana." % (
			"dreapta" if la_dreapta else "stanga"
		)
	)


## „Oglindesti plansa STANGA-DREAPTA, apoi o rotesti un SFERT de tura la
## DREAPTA. In ce celula ajunge punctul?"
##
## Singurul tipar al disciplinei la nivelul III și numai acolo: două mișcări nu
## se adună, se COMPUN — iar compunerea nu e comutativă, ceea ce dă tiparului
## cea mai bună variantă greșită din toată disciplina: **aceleași două mișcări,
## în ordinea inversă.** Cine face mai întâi rotația și apoi oglindirea nu a
## greșit nicio socoteală; a greșit ordinea, și ajunge în altă celulă.
##
## Celelalte două greșeli sunt „m-am oprit după prima" și „am făcut doar pe a
## doua" — adică exact ce rămâne dacă pierzi o mișcare din două.
##
## Mișcările nu se trag la sorți oricum: întâi o oglindire, apoi o rotație.
## Două oglindiri ar fi dat o jumătate de tură (și atunci ordinea n-ar mai fi
## contat, deci varianta cea mai bună ar fi fost egală cu răspunsul), iar două
## rotații s-ar fi adunat într-una singură.
func _rotatie_dubla(_nivel: int) -> Dictionary:
	var n := 4
	var pe_lateral := randf() < 0.5
	var la_dreapta := randf() < 0.5
	var prima := "_oglinda_laterala" if pe_lateral else "_oglinda_pe_orizontala"
	var doua := "_spre_dreapta" if la_dreapta else "_spre_stanga"

	# Punctul se CAUTĂ printre celulele figurii, nu se trage la sorți — vezi
	# `_intrebare_de_miscare` pentru de ce, și cât a costat măsurat.
	for incercare in range(8):
		var pline := _figura(n, 4)
		if pline.is_empty():
			continue
		var ordine := pline.duplicate()
		ordine.shuffle()

		for punct in ordine:
			var dupa_prima: Vector2i = call(prima, punct, n)
			var corect: Vector2i = call(doua, dupa_prima, n)
			var in_alta_ordine: Vector2i = call(prima, call(doua, punct, n), n)
			var numai_a_doua: Vector2i = call(doua, punct, n)
			var gresite: Array[Vector2i] = [in_alta_ordine, dupa_prima, numai_a_doua]

			var toate: Array = [corect]
			toate.append_array(gresite)
			if not _celule_deosebite(toate):
				continue

			var candidati: Array[String] = []
			for c in gresite:
				candidati.append(_numele_celulei(c.x, c.y))

			var descriere := "Oglindesti plansa %s, apoi o rotesti un SFERT de tura la %s." % [
				"STANGA-DREAPTA" if pe_lateral else "SUS-JOS",
				"DREAPTA" if la_dreapta else "STANGA",
			]
			return _intrebare(
				"%s%s In ce celula ajunge punctul?" % [ANTET_COORDONATE, descriere],
				_numele_celulei(corect.x, corect.y),
				candidati,
				"Punctul pleaca din %s. Dupa oglindire ajunge in %s, iar dupa sfertul de tura in %s. Ordinea conteaza: invers ar fi iesit %s." % [
					_numele_celulei(punct.x, punct.y),
					_numele_celulei(dupa_prima.x, dupa_prima.y),
					_numele_celulei(corect.x, corect.y),
					_numele_celulei(in_alta_ordine.x, in_alta_ordine.y),
				],
				_plansa_din_figura(n, pline, punct)
			)
	return {}


## Tot ce au în comun primele trei tipare ale tipului: o planșă cu figură, o
## transformare corectă, câteva greșite (plus „nemișcat", adăugat aici fiindcă
## e greșeala tuturor), și întrebarea gata compusă.
##
## ─────────────────────────────────────────────────────────────
## DE CE PUNCTUL SE ALEGE, ȘI NU SE TRAGE LA SORȚI
##
## Prima scriere trăgea punctul la întâmplare dintre celulele figurii, iar dacă
## nimerea o poziție simetrică, tiparul dădea greș. `verifica_spatial` a măsurat
## cât de des: **68% din încercări la `_oglindire` nivelul I** — iar urmarea nu
## era doar risipă. Un tip care dă greș des se RĂREȘTE în tăcere: alegerea în
## două trepte trece la alt tip când toate tiparele celui ales eșuează, deci
## echilibrul măsurat arăta BUSOLA la jumătate din cât trebuia.
##
## Și greșeala era de gândire, nu de reglaj: pe o planșă 3×3, oglindirea are
## patru poziții bune din nouă (doar colțurile — o celulă pe linia sau coloana
## din mijloc se oglindește în ea însăși). A trage la sorți și a renunța
## înseamnă a arunca cinci din nouă figuri perfect bune.
##
## Deci acum se încearcă TOATE celulele figurii, în ordine amestecată, și se
## păstrează prima care dă patru celule diferite. Dacă nicio celulă a figurii nu
## e bună (o figură întreagă pe linia din mijloc), se încearcă altă figură.
## Eșecul rămâne posibil, dar a devenit rar — iar rar e tot ce trebuie, fiindcă
## `_compune_intrebare` are oricum o ordine de rezervă.
func _intrebare_de_miscare(
	n: int,
	descriere: String,
	corecta: String,
	gresite_nume: Array,
	regula: String
) -> Dictionary:
	for incercare in range(8):
		var pline := _figura(n, 3 if n == 3 else 4)
		if pline.is_empty():
			continue
		var ordine := pline.duplicate()
		ordine.shuffle()

		for punct in ordine:
			var corect: Vector2i = call(corecta, punct, n)
			var gresite: Array[Vector2i] = []
			for nume in gresite_nume:
				var gresita: Vector2i = call(String(nume), punct, n)
				gresite.append(gresita)
			# „N-am mișcat nimic" e greșeala pe care o poate face oricine, la
			# orice mișcare, deci se adaugă aici și nu în fiecare tipar. Ultima
			# în listă: e tentantă, dar mai puțin decât o mișcare greșită.
			gresite.append(punct)

			var toate: Array = [corect]
			toate.append_array(gresite)
			if not _celule_deosebite(toate):
				continue

			var candidati: Array[String] = []
			for c in gresite:
				candidati.append(_numele_celulei(c.x, c.y))

			return _intrebare(
				"%s%s In ce celula ajunge punctul?" % [ANTET_COORDONATE, descriere],
				_numele_celulei(corect.x, corect.y),
				candidati,
				"%s Punctul era in %s, deci ajunge in %s." % [
					regula,
					_numele_celulei(punct.x, punct.y),
					_numele_celulei(corect.x, corect.y),
				],
				_plansa_din_figura(n, pline, punct)
			)
	return {}


## O figură de `cate` celule LIPITE una de alta, pe o planșă n×n. Listă goală
## dacă n-a ieșit.
##
## LIPITE (fiecare celulă nouă se adaugă lângă una deja pusă), nu împrăștiate:
## trei pete depărtate nu formează o imagine pe care s-o poți roti în cap — ar
## fi trei puncte de rotit separat, adică trei socoteli.
func _figura(n: int, cate: int) -> Array[Vector2i]:
	var pline: Array[Vector2i] = [Vector2i(randi_range(1, n), randi_range(1, n))]
	var vecini := [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var incercari := 0
	while pline.size() < cate and incercari < 100:
		incercari += 1
		var de_la: Vector2i = pline[randi_range(0, pline.size() - 1)]
		var candidat: Vector2i = de_la + vecini[randi_range(0, 3)]
		if candidat.x < 1 or candidat.x > n or candidat.y < 1 or candidat.y > n:
			continue
		if candidat in pline:
			continue
		pline.append(candidat)
	if pline.size() < cate:
		return []
	return pline


## Planșa unei figuri, cu punctul pe celula dată.
##
## Toate cele n×n celule se DECLARĂ, chiar și cele goale, fiindcă aici grila
## întreagă e informație: ca să spui unde ajunge punctul după rotație trebuie să
## vezi unde sunt marginile planșei.
func _plansa_din_figura(n: int, pline: Array[Vector2i], punct: Vector2i) -> Dictionary:
	var celule: Array = []
	for linie in range(1, n + 1):
		for coloana in range(1, n + 1):
			var aici := Vector2i(linie, coloana)
			celule.append({
				"linie": linie, "coloana": coloana,
				"plin": aici in pline,
				"marcat": aici == punct,
			})
	return {"linii": n, "coloane": n, "celule": celule}


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — BUSOLA
#
# Singurul tip fără planșă, și nu dintr-o lipsă: aici nu ai la ce să te uiți.
# Ții o direcție în cap și o întorci, sau ții un drum în cap și îl desfaci.
#
# EXISTĂ CA DOVADĂ CĂ PLANȘA E OPȚIONALĂ. Cârligul din `puzzle.gd` întoarce
# `null` pentru întrebările de aici, cutia se ascunde, iar scena arată exact
# cum arăta înainte de disciplina asta. Dacă tipul ăsta n-ar fi existat,
# „opțional" ar fi fost o intenție scrisă în comentarii și nicăieri probată.
#
# `DIRECTII` e în sens orar, deci o întoarcere e o adunare: la dreapta +1, la
# stânga -1, cu spatele +2. Nicio ramură, nicio listă de cazuri.
# ─────────────────────────────────────────────────────────────

## „Privesti spre NORD. Te intorci la STANGA, apoi la DREAPTA. Incotro privesti?"
##
## Cele patru variante sunt chiar cele patru direcții — ca la CICLUL de la
## Tipare, unde butoanele erau chiar șablonul. Nicio variantă nu se poate
## elimina din formă, iar fiecare greșeală e o întoarcere numărată invers.
##
## Nivelul II adaugă „cu SPATELE" și urcă la patru întoarceri: nu e mai greu
## pentru că sunt mai multe, e mai greu pentru că nu mai poți ține socoteala
## pe degete.
func _busola_intoarceri(nivel: int) -> Dictionary:
	var cate: int = 2 if nivel == 1 else 4
	var intoarceri := [
		{"nume": "la STANGA", "cat": -1},
		{"nume": "la DREAPTA", "cat": 1},
	]
	if nivel > 1:
		intoarceri.append({"nume": "cu SPATELE", "cat": 2})

	var start := randi_range(0, 3)

	# ÎNTOARCERILE SE TRAG PÂNĂ CÂND DUC ALTUNDEVA, nu o dată cu renunțare.
	# Cu două întoarceri de ±90, una la stânga și una la dreapta te aduc înapoi
	# de unde ai plecat — adică o întrebare al cărei răspuns e chiar direcția
	# scrisă în primul rând al enunțului. Prima scriere renunța atunci, iar
	# `verifica_spatial` a arătat ce costă: la nivelul I, BUSOLA apărea de două
	# ori mai rar decât celelalte trei tipuri, fiindcă tipul ei cădea jumătate
	# din timp și alegerea trecea mai departe.
	var unde := start
	var scrise: Array[String] = []
	var lant: Array[String] = []
	for incercare in range(20):
		unde = start
		scrise = []
		# NOTA SE SCRIE CU PUNCT ȘI VIRGULĂ, nu cu semnul egal. Prima scriere
		# înșira „VEST la dreapta = NORD la dreapta = EST cu spatele = VEST", și
		# la citit nu se vedea unde se termină un pas și începe altul — semnul
		# egal leagă două lucruri, nu patru. Prins cu ochiul, în mostrele
		# tipărite de `verifica_spatial`: exact ce nu poate prinde un verdict.
		lant = ["Pornesti spre %s" % DIRECTII[start]]
		for i in range(cate):
			var pas: Dictionary = intoarceri[randi_range(0, intoarceri.size() - 1)]
			unde = posmod(unde + int(pas["cat"]), 4)
			scrise.append(String(pas["nume"]))
			lant.append("%s: %s" % [String(pas["nume"]).to_lower(), DIRECTII[unde]])
		if unde != start:
			break
	if unde == start:
		return {}

	# Greșelile, în ordinea în care sunt tentante: direcția de pornire (n-am
	# numărat nimic), opusul răspunsului (am numărat în sensul greșit), iar
	# ultima rămasă la coadă.
	var candidati: Array[String] = [
		String(DIRECTII[start]), String(DIRECTII[posmod(unde + 2, 4)]),
	]
	for i in range(4):
		candidati.append(String(DIRECTII[i]))

	return _intrebare(
		"Privesti spre %s. Te intorci %s. Incotro privesti?" % [
			DIRECTII[start], ", apoi ".join(scrise),
		],
		DIRECTII[unde],
		candidati,
		"; ".join(lant) + "."
	)


## „Pleci din cetate: 4 pasi spre NORD, 3 spre EST, 4 spre SUD. Incotro e
## cetatea fata de tine?"
##
## Două priceperi într-una: aduni deplasările, apoi ÎNTORCI rezultatul. A doua
## e chiar capcana, iar greșeala e prima din listă — direcția în care te-ai
## depărtat, nu cea în care e cetatea.
##
## Nivelul II dă un rezultat pe o singură axă (o pereche de pași se anulează),
## nivelul III unul pe diagonală. La diagonală se cere `|est| == |nord|`, și nu
## e cochetărie: „3 est, 7 nord" nu e NORD-EST, e aproape nord — iar o întrebare
## cu două răspunsuri apărabile e o întrebare greșită.
func _busola_spre_casa(nivel: int) -> Dictionary:
	for incercare in range(80):
		var pasi := _drum_la_intamplare(3)
		if pasi.is_empty():
			continue
		var total := Vector2i.ZERO
		var scrise: Array[String] = []
		for pas in pasi:
			total += PAS[int(pas["dir"])] * int(pas["cat"])
			# „pasi" numai la primul: „4 pasi spre NORD, 3 spre EST, 4 spre SUD"
			# se citește ca o propoziție, iar „4 pasi… 3 pasi… 4 pasi" ca un
			# tabel. Cuvântul are rostul de a spune ce se numără, o dată.
			scrise.append("%d%s spre %s" % [
				int(pas["cat"]), " pasi" if scrise.is_empty() else "",
				DIRECTII[int(pas["dir"])],
			])

		var pe_o_axa := (total.x == 0) != (total.y == 0)
		var pe_diagonala := total.x != 0 and total.y != 0 and absi(total.x) == absi(total.y)
		if nivel == 2 and not pe_o_axa:
			continue
		if nivel == 3 and not pe_diagonala:
			continue

		var dus := _brat_din_roza(total)
		var intors := posmod(dus + 4, 8)
		var candidati: Array[String] = [
			ROZA[dus],                      # am uitat să întorc direcția
			ROZA[posmod(intors + 1, 8)],    # un braț mai departe
			ROZA[posmod(intors - 1, 8)],    # un braț mai încoace
		]

		var unde_sunt := ""
		if total.x != 0 and total.y != 0:
			unde_sunt = "%d pasi spre %s si %d spre %s" % [
				absi(total.x), DIRECTII[1] if total.x > 0 else DIRECTII[3],
				absi(total.y), DIRECTII[0] if total.y > 0 else DIRECTII[2],
			]
		elif total.x != 0:
			unde_sunt = "%d pasi spre %s" % [
				absi(total.x), DIRECTII[1] if total.x > 0 else DIRECTII[3],
			]
		else:
			unde_sunt = "%d pasi spre %s" % [
				absi(total.y), DIRECTII[0] if total.y > 0 else DIRECTII[2],
			]

		return _intrebare(
			"Pleci din cetate: %s. Incotro e cetatea fata de tine?" % ", ".join(scrise),
			ROZA[intors],
			candidati,
			"Pasii se aduna: ai ajuns la %s de cetate, deci cetatea e spre %s." % [
				unde_sunt, ROZA[intors],
			]
		)
	return {}


## „Ai mers 3 pasi spre NORD, apoi 2 spre EST. Cum te intorci pe acelasi drum?"
##
## Tiparul la care greșelile sunt tot ce poți uita: ordinea, direcțiile, sau
## amândouă. Trei greșeli, exact trei butoane, niciunul inventat:
##   • ordinea bună, direcțiile neîntoarse → ai mers mai departe, nu înapoi;
##   • ordinea inversă, direcțiile neîntoarse → chiar drumul dus, scris invers;
##   • chiar drumul dus → „m-am întors pe unde am venit" citit pe dos.
func _busola_drum_intors(_nivel: int) -> Dictionary:
	var pasi := _drum_la_intamplare(2)
	if pasi.is_empty():
		return {}
	var d0 := int(pasi[0]["dir"])
	var c0 := int(pasi[0]["cat"])
	var d1 := int(pasi[1]["dir"])
	var c1 := int(pasi[1]["cat"])
	var o0 := posmod(d0 + 2, 4)
	var o1 := posmod(d1 + 2, 4)

	var scrie := func(a: int, da: int, b: int, db: int) -> String:
		return "%d spre %s, apoi %d spre %s" % [a, DIRECTII[da], b, DIRECTII[db]]

	return _intrebare(
		"Ai mers %d pasi spre %s, apoi %d spre %s. Cum te intorci pe acelasi drum?" % [
			c0, DIRECTII[d0], c1, DIRECTII[d1],
		],
		scrie.call(c1, o1, c0, o0),
		[
			scrie.call(c0, o0, c1, o1),   # direcții întoarse, ordine neschimbată
			scrie.call(c1, d1, c0, d0),   # ordine inversă, direcții neîntoarse
			scrie.call(c0, d0, c1, d1),   # chiar drumul dus
		],
		"Drumul intors se face in ordine inversa SI in directii opuse: mai intai %d spre %s, apoi %d spre %s." % [
			c1, DIRECTII[o1], c0, DIRECTII[o0],
		]
	)


## Un drum de `cati` pași, fiecare cu direcția și numărul lui.
##
## Pașii consecutivi nu stau pe aceeași axă: „2 nord, apoi 3 nord" e un singur
## pas scris în două rânduri, iar „2 nord, apoi 3 sud" e o scădere, nu un drum.
## Așa, axele alternează, deci un drum de trei pași are forma A, B, A — tocmai
## forma care poate lăsa o axă anulată (vezi `_busola_spre_casa`).
##
## Listă GOALĂ dacă n-a ieșit, ca orice altceva din fișierul ăsta.
func _drum_la_intamplare(cati: int) -> Array:
	var pasi: Array = []
	for i in range(cati):
		var gasit := false
		for incercare in range(12):
			var d := randi_range(0, 3)
			if not pasi.is_empty():
				var ultima := int(pasi[-1]["dir"])
				if d == ultima or d == posmod(ultima + 2, 4):
					continue
			pasi.append({"dir": d, "cat": randi_range(2, 6)})
			gasit = true
			break
		if not gasit:
			return []
	return pasi


## În ce braț al rozei cade o deplasare. Cele opt brațe din `ROZA`, în ordine.
func _brat_din_roza(d: Vector2i) -> int:
	if d.y > 0:
		if d.x > 0:
			return 1   # NORD-EST
		return 0 if d.x == 0 else 7
	if d.y < 0:
		if d.x > 0:
			return 3   # SUD-EST
		return 4 if d.x == 0 else 5
	return 2 if d.x > 0 else 6


# ─────────────────────────────────────────────────────────────
# TIPUL 4 — PLIEREA
#
# Desfășurata unui cub, scrisă cu șase litere. Întrebarea e mereu aceeași:
# care fețe ajung una în fața celeilalte când plierea se închide.
#
# TOT TIPUL ÎNCAPE ÎNTR-O REGULĂ, și de-aia are două tipare și nu trei: o
# desfășurată 1-4-1 are o BANDĂ de patru fețe care se închide în jurul cubului
# (deci prima e opusă celei de-a treia, a doua celei de-a patra) și două fețe în
# afara benzii, care sunt capacul și fundul — deci opuse între ele. A treia
# întrebare despre asta ar fi fost aceeași întrebare cu alte cuvinte, ca la
# CANTARUL de la Numere.
#
# CELULELE NEDECLARATE FAC FORMA. Planșa are 3×4 casete, din care se declară
# șase; restul nu se desenează. Fără asta, plierea ar fi cerut un desenator al
# ei — vezi `plansa.gd`, unde regula „lista celulelor ESTE forma" e scrisă
# tocmai pentru cazul ăsta.
# ─────────────────────────────────────────────────────────────

## „Care doua fete sunt OPUSE pe cub?"
##
## Primul tipar al tipului și singurul de la nivelul I: aici nu trebuie să
## urmărești o față anume, doar să vezi banda. Variantele greșite sunt perechi
## de fețe VECINE — adică perechi care chiar se ating pe cub, nu perechi trase
## la sorți.
func _pliere_perechea(nivel: int) -> Dictionary:
	var desfasurata := _desfasurata(nivel)
	var opuse: Array = desfasurata["opuse"]
	var litere: Array = desfasurata["litere"]

	var aleasa: Array = opuse[randi_range(0, opuse.size() - 1)]
	var corect := _perechea_scrisa(String(aleasa[0]), String(aleasa[1]))

	# Toate perechile posibile, fără cele opuse: ce rămâne sunt chiar perechile
	# de fețe vecine.
	var cele_opuse := {}
	for pereche in opuse:
		cele_opuse[_perechea_scrisa(String(pereche[0]), String(pereche[1]))] = true
	var vecine: Array[String] = []
	for i in range(litere.size()):
		for j in range(i + 1, litere.size()):
			var scrisa := _perechea_scrisa(String(litere[i]), String(litere[j]))
			if not cele_opuse.has(scrisa):
				vecine.append(scrisa)
	vecine.shuffle()

	return _intrebare(
		"Plansa e desfasurata unui cub. Care doua fete sunt OPUSE pe cub?",
		corect,
		vecine,
		"Banda de patru fete se inchide in jurul cubului, deci prima e opusa celei de-a treia si a doua celei de-a patra; cele doua fete din afara benzii sunt capacul si fundul, deci sunt opuse intre ele. Aici: %s." % corect,
		desfasurata["plansa"]
	)


## „Care fata e opusa fetei A?"
##
## Al doilea tipar, și cel care urcă la nivelul III pe o desfășurată AȘEZATĂ
## ALTFEL: banda verticală, cu cele două fețe din afara ei la stânga și la
## dreapta. Regula nu se schimbă deloc — se schimbă doar ce recunoști cu ochiul,
## care e chiar priceperea măsurată. O desfășurată pe care ai mai văzut-o se
## rezolvă din memorie, nu din pliere.
##
## Cele trei variante greșite sunt fețe VECINE cu cea întrebată, deci fiecare e
## un răspuns pe care l-ai da dacă ai plia într-o direcție greșită.
func _pliere_opusa(nivel: int) -> Dictionary:
	var desfasurata := _desfasurata(nivel)
	var opuse: Array = desfasurata["opuse"]
	var litere: Array = desfasurata["litere"]

	# Cine e opus cui, ca dicționar — e tot ce avem nevoie, în ambele sensuri.
	var opus := {}
	for pereche in opuse:
		opus[String(pereche[0])] = String(pereche[1])
		opus[String(pereche[1])] = String(pereche[0])

	var intrebata := String(litere[randi_range(0, litere.size() - 1)])
	var corect: String = opus[intrebata]

	var vecine: Array[String] = []
	for litera in litere:
		var l := String(litera)
		if l != intrebata and l != corect:
			vecine.append(l)
	vecine.shuffle()

	# NOTA DEPINDE DE FAȚA ÎNTREBATĂ, nu de desfășurată: una din bandă se
	# explică prin banda care se închide, una din afara ei prin capac și fund.
	# `_desfasurata()` nu știe ce întrebăm, deci ne dă amândouă șabloanele și
	# alegerea se face aici — altfel ar fi fost un parametru dat înainte să
	# existe informația care-l decide.
	var in_banda: bool = intrebata in desfasurata["banda"]
	var sablon := String(desfasurata["in_banda"] if in_banda else desfasurata["afara"])

	return _intrebare(
		"Plansa e desfasurata unui cub. Care fata e opusa fetei %s?" % intrebata,
		corect,
		vecine,
		sablon.format({"fata": intrebata, "opusa": corect}),
		desfasurata["plansa"]
	)


## Perechea, scrisă mereu în aceeași ordine. Alfabetic, nu în ordinea în care
## au venit: altfel „A si D" și „D si A" ar fi putut apărea pe două butoane ca
## două răspunsuri diferite la aceeași întrebare.
func _perechea_scrisa(a: String, b: String) -> String:
	return "%s si %s" % [a, b] if a < b else "%s si %s" % [b, a]


## O desfășurată 1-4-1, cu literele, perechile opuse și nota care explică
## regula. Întoarce și planșa, gata de desenat.
##
## CELE TREI AȘEZĂRI, pe niveluri:
##   I   — bandă orizontală, cele două fețe din afara ei una sub alta (crucea,
##         forma pe care o recunoaște oricine)
##   II  — bandă orizontală, cele două fețe decalate
##   III — bandă VERTICALĂ, fețele la stânga și la dreapta
##
## Decalajul nu schimbă nicio pereche opusă, și exact asta e lecția: fețele din
## afara benzii sunt opuse între ele oriunde ar fi lipite pe ea. Cine a învățat
## „crucea" pe de rost greșește la nivelul II; cine a înțeles banda, nu.
func _desfasurata(nivel: int) -> Dictionary:
	var litere := _litere(6)
	var banda := litere.slice(0, 4)   # cele patru fețe care se închid în jur
	var capac := litere[4]
	var fund := litere[5]

	var celule: Array = []
	var linii := 0
	var coloane := 0

	if nivel < 3:
		# Bandă orizontală pe linia 2, în coloanele 1-4.
		linii = 3
		coloane = 4
		var unde_capac := randi_range(1, 4)
		var unde_fund := unde_capac if nivel == 1 else _alta_coloana(unde_capac, 4)
		for i in range(4):
			celule.append({"linie": 2, "coloana": i + 1, "text": banda[i]})
		celule.append({"linie": 1, "coloana": unde_capac, "text": capac})
		celule.append({"linie": 3, "coloana": unde_fund, "text": fund})
	else:
		# Bandă verticală pe coloana 2, în liniile 1-4.
		linii = 4
		coloane = 3
		var unde_capac := randi_range(1, 4)
		var unde_fund := _alta_coloana(unde_capac, 4)
		for i in range(4):
			celule.append({"linie": i + 1, "coloana": 2, "text": banda[i]})
		celule.append({"linie": unde_capac, "coloana": 1, "text": capac})
		celule.append({"linie": unde_fund, "coloana": 3, "text": fund})

	# Cele două șabloane de notă, cu locurile pentru fața întrebată și cea opusă
	# lăsate de completat: `_pliere_opusa` știe despre ce față e vorba,
	# `_desfasurata` nu. Vezi acolo de ce alegerea se face în celălalt capăt.
	var in_banda := "{fata} e pe banda de patru fete. Banda se inchide in jurul cubului, deci fiecare fata de pe ea e opusa celei aflate la doua locuri mai departe: {opusa}."
	var afara := "{fata} e una din cele doua fete din afara benzii, adica unul din cele doua capace ale cubului. Ele sunt opuse intre ele: {opusa}."

	return {
		"plansa": {"linii": linii, "coloane": coloane, "celule": celule},
		"litere": litere,
		"banda": banda,
		"opuse": [[banda[0], banda[2]], [banda[1], banda[3]], [capac, fund]],
		"in_banda": in_banda,
		"afara": afara,
	}


## O coloană (sau linie) diferită de cea dată, între 1 și `cate`.
func _alta_coloana(fata_de: int, cate: int) -> int:
	var alta := randi_range(1, cate - 1)
	return alta if alta < fata_de else alta + 1

extends Node
## VERIFICAREA LOGICII — cele 15 tipuri, tiparele lor și răspunsurile.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_logica.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE O UNEALTĂ, ȘI NU O PARTIDĂ
##
## Logica nu are un fișier de întrebări care s-ar putea citi cu ochiul: are 56
## de TIPARE care nasc întrebări la infinit. O greșeală într-unul din ele nu se
## vede la o partidă, fiindcă tiparul ăla iese o dată la cincizeci de întrebări
## — iar când iese, arată ca o întrebare normală. „Cel mai rău caz" cu răspunsul
## calculat pe grupul greșit e tot un buton cu un număr pe el.
##
## Aici fiecare tipar e chemat de sute de ori, pe loc, iar răspunsul lui e
## RECALCULAT din enunț, nu crezut pe cuvânt.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   DATELE AU TRECUT. Încărcătorul sare peste intrările stricate cu un
##   `push_warning`, iar un avertisment nu oprește nimic și se pierde într-o
##   consolă plină. „80 încărcate din 80 găsite" e singurul loc unde o categorie
##   pierdută se vede ca un număr.
##
##   TABELUL ESTE ÎNTREG. Fiecare `metoda` din `GENERATOARE` există cu adevărat
##   pe script (un nume scris greșit ar fi o eroare în mijlocul luptei, nu la
##   pornire), fiecare `necesita` e un fel de date cunoscut (unul necunoscut
##   înseamnă „datele sunt mereu disponibile", deci un tip care crapă când
##   fișierul lipsește), și fiecare `categorie` e a unui singur tip — două
##   tipuri cu același antet ar fi un amestec invizibil.
##
##   FIECARE TIP LA TOATE TREI NIVELURILE. Regula scrisă în `logica.gd`: un tip
##   care lipsește de la un nivel lasă celelalte să-și împartă între ele toată
##   probabilitatea. Nu se vede nicum altfel — jocul merge, doar că la nivelul
##   II nu mai apar silogisme.
##
##   CONTRACTUL, PE FIECARE TIPAR. Exact patru variante, toate DIFERITE (două
##   butoane cu același text sunt două răspunsuri bune), `corect` în interval,
##   enunț și explicație nevide. `puzzle.gd` ar prinde o parte din astea, dar
##   abia în luptă, cu `push_error`.
##
##   RĂSPUNSURILE, RECALCULATE DIN ENUNȚ. Partea care merită cel mai mult: la
##   mulțimi, la cel mai rău caz și la calendar se citesc cifrele DIN TEXT și se
##   reface socoteala. Dacă `_multimi_doar_unul` ar scădea intersecția o singură
##   dată, întrebarea ar arăta perfect normală — și ar fi greșită.
##
##   ENIGMELE SUNT REZOLVATE, NU PRESUPUSE. La mincinoși, locuri și potrivire se
##   cere lucrul tare: situația ascunsă se potrivește cu TOATE indiciile, și
##   răspunsul publicat e chiar ce spune ea. Plus condiția de unicitate: niciun
##   indiciu nu lasă două răspunsuri bune.
##
##   O REGULĂ CARE PĂREA UN AMĂNUNT. Cu doi oameni și numai afirmații de felul
##   „X e mincinos" NU se poate face o enigmă: situația e simetrică, deci are
##   mereu două soluții. Scrie în comentariul din `logica.gd`; aici se probează,
##   fiindcă e exact felul de regulă care se pierde într-o rescriere.
##
##   ECHILIBRUL PE TIPURI. Alegerea e în două trepte (întâi tipul, apoi tiparul)
##   tocmai ca un tip cu 9 tipare să nu apară de 9 ori mai des decât unul cu
##   unul singur. E o probabilitate, nu o listă: nu se vede la o partidă, se
##   vede la zece mii de trageri.
##
##   FĂRĂ REPETIȚII PE EXPEDIȚIE. `_compune_nerepetata` din `puzzle.gd` nu poate
##   GARANTA nimic la o disciplină generativă (nu-și poate enumera întrebările),
##   deci singurul lucru care se poate afla e cât de rar repetă de fapt.
##
##   CÂT SE CITEȘTE. Ultima secțiune nu dă verdicte, TIPĂREȘTE — ca
##   `verifica_coltul`. Un enunț de șase rânduri e corect și nejucabil: la
##   inamicul cu cronometru ai 12 secunde pentru tot, citit inclusiv. Tabelul
##   arată cel mai lung enunț al fiecărui tip, ca lungimea să fie o cifră pe
##   care o văd, nu o bănuială.
##
## Ce NU verifică: dacă un silogism e VALID. Validitatea celor patru tipare de
## logică propozițională e logică scrisă de mână, iar un script care ar putea
## s-o bată ar fi un demonstrator de teoreme — mai mult cod decât disciplina
## întreagă. Ce se poate verifica mecanic (și se verifică) e că forma
## răspunsului e cea așteptată și că varianta „Nu se poate stabili" apare la
## TOATE tiparele de inferență, nu doar la cele unde e corectă.

const LOGICA := preload("res://scenes/logica/logica.gd")

# Câte categorii și cuvinte ar trebui să fie în fișiere. Scrise aici, nu citite
# din ce s-a încărcat: o verificare care-și ia așteptările din lucrul verificat
# nu verifică nimic — dacă mâine dispar 10 categorii, „am găsit câte am găsit"
# ar trece liniștită.
const CATE_CATEGORII := 80
const CATE_CUVINTE := 25
const CATE_OAMENI := 17
const CATE_MASCULINE := 17

# Câte întrebări se trag din fiecare tipar. 200 e mult peste cât trebuie ca să
# iasă toate ramurile dinăuntru (`_conditional_nehotarat` are două, alese cu
# `randf`, iar `_certitudine_unul` alege ținta din două grupuri), și destul de
# puțin ca toată secțiunea să se termină într-o secundă.
const TRAGERI_PE_TIPAR := 200
## Enunțuri tipărite întregi, pe tipar. Mai puține decât la enigme fiindcă
## aici se compune și TEXTUL, nu doar structura.
const TRAGERI_ENUNT := 120

# Câte trageri la măsurarea echilibrului, pe nivel. La 15 tipuri și 9000 de
# trageri fiecare ar trebui să iasă pe la 600; împrăștierea întâmplătoare e de
# vreo ±25, deci toleranța de mai jos e cu mult peste ea. Verificarea pică doar
# dacă alegerea e strâmbă, nu dacă zarul a avut o zi.
const TRAGERI_ECHILIBRU := 9000
const TOLERANTA_ECHILIBRU := 0.25

# Cât poate pica un tipar cu constrângeri fără ca asta să fie o problemă.
# Mincinoșii, locurile și potrivirea au voie să întoarcă gol — indiciile se trag
# la întâmplare și nu duc întotdeauna la un răspuns determinat. Peste jumătate,
# însă, înseamnă că tiparul nu mai apare cât ar trebui: `_compune_intrebare`
# alege altă rețetă, deci tipul se rărește în tăcere.
const MAX_RATA_DE_ESEC := 0.5

# Câte trageri la proba „fără repetiții pe expediție".
const TRAGERI_SAC := 300

# Felurile de date pe care le cunoaște `_date_disponibile`. Lista e închisă
# dinadins: un `necesita` scris greșit cade pe `return true`, adică „datele sunt
# mereu la locul lor" — exact invers decât s-ar fi vrut.
const NECESITA_CUNOSCUTE := ["", "categorii", "vocabular", "oameni", "masculine"]

# Tiparele de INFERENȚĂ: cele la care din premise rezultă ceva (sau nu rezultă
# nimic), deci la care „Nu se poate stabili" trebuie să fie printre variante
# chiar și când nu e răspunsul. Scrise aici, nu deduse: ele sunt o DECIZIE de
# design (vezi comentariul de la DACĂ-ATUNCI în `logica.gd`), iar o verificare
# care și-ar deduce așteptarea din cod n-ar mai apăra decizia.
const TIPARE_CU_NEHOTARAT := [
	"_modus_ponens", "_modus_tollens", "_conditional_nehotarat",
	"_conector_sau", "_conector_si_fals",
]

var scena = null
var cifre: RegEx = RegEx.create_from_string(r"\d+")
var calendarul: RegEx = RegEx.create_from_string(
	r"^Daca (.+?) (a fost|e|va fi) ([a-z]+), ce zi (a fost|e|va fi) (.+?)\?$"
)


func _ready() -> void:
	print("\n══ VERIFICAREA LOGICII ══\n")

	LOGICA.incarca_date()
	# Scriptul, nu scena: toate generatoarele lucrează pe `static var`-uri și pe
	# numere, niciunul nu atinge un buton. Deci nu se deschide nicio fereastră,
	# nu pornește niciun cronometru și nu se aude niciun sunet.
	scena = LOGICA.new()
	print("")

	var tot_bun := true
	tot_bun = _datele() and tot_bun
	tot_bun = _tabelul() and tot_bun
	tot_bun = _nivelurile() and tot_bun
	tot_bun = _contractul() and tot_bun
	tot_bun = _multimile() and tot_bun
	tot_bun = _cel_mai_rau_caz() and tot_bun
	tot_bun = _calendarul() and tot_bun
	tot_bun = _mincinosii() and tot_bun
	tot_bun = _locurile() and tot_bun
	tot_bun = _potrivirea() and tot_bun
	tot_bun = _enuntul_se_tine() and tot_bun
	tot_bun = _nehotaratul() and tot_bun
	tot_bun = _echilibrul() and tot_bun
	tot_bun = _fara_repetitii() and tot_bun
	_cat_se_citeste()

	scena.free()
	print("\n══ %s ══\n" % ("TOTUL E BUN" if tot_bun else "SUNT PROBLEME, vezi mai sus"))
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. AU TRECUT TOATE DATELE?
# ─────────────────────────────────────────────────────────────

func _datele() -> bool:
	print("  DATELE")
	var tot_bun := true

	# Fișierele, citite A DOUA OARĂ, direct de pe disc. Pare risipă, dar e chiar
	# ce face verificarea posibilă: ce e în `LOGICA.categorii` e ce a TRECUT,
	# iar singurul lucru care ne interesează e dacă s-a pierdut ceva pe drum.
	var brute_categorii := Puzzle.citeste_lista_json(LOGICA.CALE_CATEGORII, "Verificare")
	var brute_cuvinte := Puzzle.citeste_lista_json(LOGICA.CALE_VOCABULAR, "Verificare")

	tot_bun = _verdict(
		"categoriile gasite = cele asteptate",
		brute_categorii.size() == CATE_CATEGORII,
		"%d, asteptat %d" % [brute_categorii.size(), CATE_CATEGORII]
	) and tot_bun
	tot_bun = _verdict(
		"toate categoriile au trecut",
		LOGICA.categorii.size() == brute_categorii.size(),
		"%d din %d" % [LOGICA.categorii.size(), brute_categorii.size()]
	) and tot_bun
	tot_bun = _verdict(
		"cuvintele gasite = cele asteptate",
		brute_cuvinte.size() == CATE_CUVINTE,
		"%d, asteptat %d" % [brute_cuvinte.size(), CATE_CUVINTE]
	) and tot_bun
	tot_bun = _verdict(
		"toate cuvintele au trecut",
		LOGICA.vocabular.size() == brute_cuvinte.size(),
		"%d din %d" % [LOGICA.vocabular.size(), brute_cuvinte.size()]
	) and tot_bun
	tot_bun = _verdict(
		"oamenii din vocabular",
		LOGICA.oameni.size() == CATE_OAMENI,
		"%d, asteptat %d" % [LOGICA.oameni.size(), CATE_OAMENI]
	) and tot_bun
	tot_bun = _verdict(
		"cuvintele masculine",
		LOGICA.masculine.size() == CATE_MASCULINE,
		"%d, asteptat %d" % [LOGICA.masculine.size(), CATE_MASCULINE]
	) and tot_bun

	# REGULA DE AUR: categoriile trebuie să fie disjuncte. Încărcătorul doar
	# avertizează; aici e un verdict, fiindcă un membru în două categorii face
	# „intrusul" să aibă două răspunsuri bune.
	var vazut := {}
	var comuni: Array[String] = []
	for categorie in LOGICA.categorii:
		for membru in categorie["membri"]:
			if vazut.has(membru):
				comuni.append(String(membru))
			else:
				vazut[membru] = true
	tot_bun = _verdict(
		"niciun membru in doua categorii",
		comuni.is_empty(),
		_primele(comuni, 5)
	) and tot_bun

	# Un domeniu cu o singură categorie nu poate produce întrebări: analogia și
	# intrusul au nevoie de două ca să compare.
	var sarace: Array[String] = []
	for domeniu in LOGICA.pe_domeniu:
		if LOGICA.pe_domeniu[domeniu].size() < 2:
			sarace.append(String(domeniu))
	tot_bun = _verdict(
		"niciun domeniu cu o singura categorie",
		sarace.is_empty(),
		_primele(sarace, 5)
	) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 2. TABELUL ESTE ÎNTREG?
# ─────────────────────────────────────────────────────────────

func _tabelul() -> bool:
	print("  TABELUL")
	var tot_bun := true

	var lipsa: Array[String] = []
	var necunoscute: Array[String] = []
	for generator in LOGICA.GENERATOARE:
		if not scena.has_method(generator["metoda"]):
			lipsa.append(String(generator["metoda"]))
		if not (generator["necesita"] in NECESITA_CUNOSCUTE):
			necunoscute.append("%s: %s" % [generator["metoda"], generator["necesita"]])

	tot_bun = _verdict(
		"fiecare metoda din tabel exista",
		lipsa.is_empty(),
		_primele(lipsa, 5)
	) and tot_bun
	tot_bun = _verdict(
		"fiecare „necesita” e cunoscut",
		necunoscute.is_empty(),
		_primele(necunoscute, 5)
	) and tot_bun

	# Antetul trebuie să fie al unui singur tip: două tipuri cu aceeași
	# `categorie` s-ar amesteca pe ecran fără ca nimic să se plângă, iar
	# măsurarea echilibrului de mai jos (care numără pe antet) ar minți.
	var tip_pe_categorie := {}
	var amestecate: Array[String] = []
	for generator in LOGICA.GENERATOARE:
		var antet := String(generator["categorie"])
		var tip := String(generator["tip"])
		if tip_pe_categorie.has(antet) and tip_pe_categorie[antet] != tip:
			amestecate.append("%s: %s + %s" % [antet, tip_pe_categorie[antet], tip])
		tip_pe_categorie[antet] = tip
	tot_bun = _verdict(
		"fiecare antet e al unui singur tip",
		amestecate.is_empty(),
		_primele(amestecate, 5)
	) and tot_bun

	var tipuri := _tipurile()
	tot_bun = _verdict(
		"cincisprezece tipuri",
		tipuri.size() == 15,
		"%d: %s" % [tipuri.size(), ", ".join(tipuri)]
	) and tot_bun

	return tot_bun


## 3. FIECARE TIP LA TOATE TREI NIVELURILE.
func _nivelurile() -> bool:
	print("  NIVELURILE")
	var tot_bun := true

	for nivel in [1, 2, 3]:
		var cu_tipar := {}
		for generator in LOGICA.GENERATOARE:
			if nivel in generator["niveluri"]:
				cu_tipar[String(generator["tip"])] = true
		var lipsa: Array[String] = []
		for tip in _tipurile():
			if not cu_tipar.has(tip):
				lipsa.append(tip)
		tot_bun = _verdict(
			"nivelul %d are toate tipurile" % nivel,
			lipsa.is_empty(),
			"lipsesc: %s" % _primele(lipsa, 5) if not lipsa.is_empty() else "%d tipuri" % cu_tipar.size()
		) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 4. CONTRACTUL, PE FIECARE TIPAR
# ─────────────────────────────────────────────────────────────

func _contractul() -> bool:
	print("  CONTRACTUL (%d trageri pe tipar)" % TRAGERI_PE_TIPAR)
	var tot_bun := true

	var stricate: Array[String] = []
	var prea_des_gol: Array[String] = []

	for generator in LOGICA.GENERATOARE:
		var metoda := String(generator["metoda"])
		var goale := 0
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				goale += 1
				continue
			var problema := _problema_de_contract(q)
			if problema != "":
				stricate.append("%s: %s" % [metoda, problema])
				break
		var rata := float(goale) / float(TRAGERI_PE_TIPAR)
		if rata > MAX_RATA_DE_ESEC:
			prea_des_gol.append("%s: %d%%" % [metoda, int(rata * 100.0)])

	tot_bun = _verdict(
		"toate tiparele respecta contractul",
		stricate.is_empty(),
		_primele(stricate, 5)
	) and tot_bun
	tot_bun = _verdict(
		"niciun tipar nu pica mai des de %d%%" % int(MAX_RATA_DE_ESEC * 100.0),
		prea_des_gol.is_empty(),
		_primele(prea_des_gol, 5)
	) and tot_bun

	# Și prin poarta pe care o folosește chiar lupta: un dicționar gol de acolo
	# e ecranul de eroare în mijlocul unui lanț.
	var goale_la_compunere := 0
	for nivel in [1, 2, 3]:
		for i in range(TRAGERI_PE_TIPAR * 5):
			if scena._compune_intrebare(nivel).is_empty():
				goale_la_compunere += 1
	tot_bun = _verdict(
		"`_compune_intrebare` nu intoarce niciodata gol",
		goale_la_compunere == 0,
		"%d goale din %d" % [goale_la_compunere, TRAGERI_PE_TIPAR * 15]
	) and tot_bun

	return tot_bun


## Ce e în neregulă cu întrebarea, sau șir gol dacă e bună. Aceleași cerințe pe
## care le-ar verifica `puzzle.gd` în luptă (`_intrebare_buna`), plus una pe care
## el NU o verifică: variantele să fie diferite între ele.
func _problema_de_contract(q: Dictionary) -> String:
	for cheie in ["text", "variante", "corect", "explicatie"]:
		if not q.has(cheie):
			return "lipseste „%s”" % cheie
	if String(q["text"]).strip_edges() == "":
		return "enunt gol"
	if String(q["explicatie"]).strip_edges() == "":
		return "explicatie goala"

	var variante: Array = q["variante"]
	if variante.size() != 4:
		return "%d variante" % variante.size()

	var vazute := {}
	for varianta in variante:
		var text := String(varianta).strip_edges()
		if text == "":
			return "varianta goala"
		if vazute.has(text):
			return "doua variante identice: „%s”" % text
		vazute[text] = true

	var corect := int(q["corect"])
	if corect < 0 or corect >= variante.size():
		return "corect = %d" % corect
	return ""


# ─────────────────────────────────────────────────────────────
# 5. MULȚIMILE — răspunsul, recalculat din enunț
#
# Cifrele se citesc DIN TEXT, în ordinea în care apar, și se reface socoteala.
# Nu e o rotunjire a verificării: e singurul fel în care se poate afla că
# formula din cod și cea din enunț sunt aceeași.
# ─────────────────────────────────────────────────────────────

func _multimile() -> bool:
	print("  MULTIMILE")
	var tot_bun := true

	for proba in [
		{"metoda": "_multimi_reuniune", "cifre": 3},
		{"metoda": "_multimi_intersectie", "cifre": 3},
		{"metoda": "_multimi_doar_unul", "cifre": 3},
		{"metoda": "_multimi_niciuna", "cifre": 4},
	]:
		var metoda := String(proba["metoda"])
		var greseli: Array[String] = []
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			var n := _numerele(String(q["text"]))
			if n.size() != int(proba["cifre"]):
				greseli.append("%d cifre in enunt" % n.size())
				break
			var asteptat := _socoteala(metoda, n)
			var dat := int(String(q["variante"][int(q["corect"])]))
			if dat != asteptat:
				greseli.append("%s -> %d, asteptat %d" % [_lista(n), dat, asteptat])
				break
		tot_bun = _verdict(metoda, greseli.is_empty(), _primele(greseli, 2)) and tot_bun

	return tot_bun


## Socoteala pe care trebuie s-o dea fiecare tipar de mulțimi. Scrisă aici a
## doua oară, dinadins: dacă ar chema codul din `logica.gd`, ar confirma că acel
## cod e egal cu el însuși.
func _socoteala(metoda: String, n: Array) -> int:
	match metoda:
		"_multimi_reuniune":
			return int(n[0]) + int(n[1]) - int(n[2])
		"_multimi_intersectie":
			return int(n[0]) + int(n[1]) - int(n[2])
		"_multimi_doar_unul":
			return int(n[0]) + int(n[1]) - 2 * int(n[2])
		"_multimi_niciuna":
			return int(n[0]) - (int(n[1]) + int(n[2]) - int(n[3]))
	return -1


# ─────────────────────────────────────────────────────────────
# 6. CEL MAI RĂU CAZ
#
# Aici enunțul nu spune CARE grup e ținta într-un fel pe care un script să-l
# poată citi (numele grupului apare la singular în întrebare și la plural în
# enunț). Deci nu se cere un număr exact, se cere ca răspunsul să fie unul din
# cele câteva pe care formula LE POATE da — plus, la „câte unul din fiecare",
# unde ținta nu mai contează, numărul exact.
# ─────────────────────────────────────────────────────────────

func _cel_mai_rau_caz() -> bool:
	print("  CEL MAI RAU CAZ")
	var tot_bun := true

	for proba in [
		{"metoda": "_certitudine_unul", "grupe": 2, "plus": 1},
		{"metoda": "_certitudine_doi", "grupe": 2, "plus": 2},
		{"metoda": "_certitudine_trei_grupe", "grupe": 3, "plus": 1},
	]:
		var metoda := String(proba["metoda"])
		var grupe := int(proba["grupe"])
		var plus := int(proba["plus"])
		var greseli: Array[String] = []
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			var n := _numerele(String(q["text"]))
			if n.size() != grupe:
				greseli.append("%d cifre in enunt" % n.size())
				break
			var total := 0
			for marime in n:
				total += int(marime)
			# „Toți ceilalți pot ieși primii, apoi încă `plus`." Care e ținta nu
			# se poate citi din text, deci se acceptă oricare dintre grupuri —
			# dar NU altceva: un răspuns care nu e total minus un grup înseamnă
			# că formula e greșită.
			var permise: Array[int] = []
			for marime in n:
				permise.append(total - int(marime) + plus)
			var dat := int(String(q["variante"][int(q["corect"])]))
			if not (dat in permise):
				greseli.append("%s -> %d, permise %s" % [_lista(n), dat, _lista(permise)])
				break
		tot_bun = _verdict(metoda, greseli.is_empty(), _primele(greseli, 2)) and tot_bun

	# „Câte unul din FIECARE fel": aici ținta nu mai există, deci răspunsul e
	# determinat — grupul cel mai mare, plus unul.
	var greseli_fiecare: Array[String] = []
	for i in range(TRAGERI_PE_TIPAR):
		var q: Dictionary = scena.call("_certitudine_din_fiecare")
		if q.is_empty():
			continue
		var n := _numerele(String(q["text"]))
		if n.size() != 2:
			greseli_fiecare.append("%d cifre in enunt" % n.size())
			break
		var asteptat := maxi(int(n[0]), int(n[1])) + 1
		var dat := int(String(q["variante"][int(q["corect"])]))
		if dat != asteptat:
			greseli_fiecare.append("%s -> %d, asteptat %d" % [_lista(n), dat, asteptat])
			break
	tot_bun = _verdict(
		"_certitudine_din_fiecare",
		greseli_fiecare.is_empty(),
		_primele(greseli_fiecare, 2)
	) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 7. CALENDARUL — răspunsul, refăcut din enunț
#
# Singura secțiune care PARSEAZĂ o propoziție, și merită: aritmetica
# săptămânii e locul clasic în care se ascunde o greșeală cu o zi sau cu un
# semn, iar o astfel de greșeală arată, pe ecran, exact ca o întrebare bună.
# ─────────────────────────────────────────────────────────────

func _calendarul() -> bool:
	print("  CALENDARUL")
	var tot_bun := true

	for metoda in ["_calendar_aproape", "_calendar_departe", "_calendar_inapoi"]:
		var greseli: Array[String] = []
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			var text := String(q["text"])
			var potrivire := calendarul.search(text)
			if potrivire == null:
				greseli.append("enunt necitibil: %s" % text)
				break
			var ancora := _decalajul(potrivire.get_string(1))
			var tinta := _decalajul(potrivire.get_string(5))
			var de_la := LOGICA.ZILE.find(potrivire.get_string(3))
			if de_la < 0 or ancora == 99 or tinta == 99:
				greseli.append("nu inteleg: %s" % text)
				break
			var asteptat := _cu_majuscula(LOGICA.ZILE[posmod(de_la - ancora + tinta, 7)])
			var dat := String(q["variante"][int(q["corect"])])
			if dat != asteptat:
				greseli.append("„%s” -> %s, asteptat %s" % [text, dat, asteptat])
				break
			# O săptămână rotundă ar da drept răspuns chiar ziua din enunț, iar
			# capcana „ziua nemișcată" ar deveni răspunsul bun.
			if posmod(tinta - ancora, 7) == 0:
				greseli.append("distanta de o saptamana: %s" % text)
				break
		tot_bun = _verdict(metoda, greseli.is_empty(), _primele(greseli, 2)) and tot_bun

	return tot_bun


## „ieri" → -1, „peste 4 zile" → 4. 99 = n-am înțeles.
func _decalajul(cand: String) -> int:
	for decalaj in LOGICA.CAND:
		if LOGICA.CAND[decalaj] == cand:
			return int(decalaj)
	var n := _numerele(cand)
	if n.size() != 1:
		return 99
	if cand.begins_with("peste"):
		return int(n[0])
	if cand.begins_with("acum"):
		return -int(n[0])
	return 99


# ─────────────────────────────────────────────────────────────
# 8-10. ENIGMELE — rezolvate, nu presupuse
#
# Cele trei tipuri cu constrângeri sunt singurele care CAUTĂ răspunsul, deci
# singurele la care se poate cere lucrul tare: situația ascunsă se potrivește cu
# toate indiciile, răspunsul publicat e chiar ce spune ea, iar niciun indiciu nu
# lasă două răspunsuri bune.
#
# Verificarea se uită la enigmă, nu la textul ei: cheamă `_enigma_*` direct. Așa
# are în mână și situația ascunsă, și indiciile, și poate compara ce s-a publicat
# cu ce e adevărat.
# ─────────────────────────────────────────────────────────────

func _mincinosii() -> bool:
	print("  ADEVAR SI MINCIUNA")
	var tot_bun := true

	var nerezolvate := 0
	var gresite := 0
	var reusite := 0
	for i in range(TRAGERI_PE_TIPAR):
		var enigma: Dictionary = scena._enigma_mincinosi(3, LOGICA.AFIRMATII_TOATE)
		if enigma.is_empty():
			nerezolvate += 1
			continue
		reusite += 1
		# Rezolvată din nou, de aici: exact o soluție, și exact cea publicată.
		var solutii: Array = LOGICA._solutii_mincinosi(enigma["afirmatii"], 3)
		if solutii.size() != 1 or not _la_fel(solutii[0], enigma["atribuire"]):
			gresite += 1

	tot_bun = _verdict(
		"enigma are exact o soluție, si e cea publicata",
		gresite == 0,
		"%d gresite din %d rezolvate" % [gresite, reusite]
	) and tot_bun
	tot_bun = _verdict(
		"se gasesc enigme destul de des",
		float(nerezolvate) / float(TRAGERI_PE_TIPAR) <= MAX_RATA_DE_ESEC,
		"%d goale din %d" % [nerezolvate, TRAGERI_PE_TIPAR]
	) and tot_bun

	# REGULA DIN COMENTARIU, PROBATĂ: cu doi oameni și numai afirmații „X e
	# cavaler/mincinos", situația e simetrică — dacă o atribuire se potrivește,
	# și cea întoarsă pe dos se potrivește. Deci nu există enigmă.
	var simetrice := 0
	for i in range(TRAGERI_PE_TIPAR):
		if not scena._enigma_mincinosi(2, ["ESTE"]).is_empty():
			simetrice += 1
	tot_bun = _verdict(
		"doi oameni + numai „ESTE” nu dau nicio enigma",
		simetrice == 0,
		"%d gasite" % simetrice
	) and tot_bun

	# Și invers: cu toate cele trei forme, doi oameni ajung.
	var doi := 0
	for i in range(TRAGERI_PE_TIPAR):
		if not scena._enigma_mincinosi(2, LOGICA.AFIRMATII_TOATE).is_empty():
			doi += 1
	tot_bun = _verdict(
		"doi oameni + toate formele dau enigme",
		doi > 0,
		"%d din %d" % [doi, TRAGERI_PE_TIPAR]
	) and tot_bun

	return tot_bun


func _locurile() -> bool:
	print("  LOCURILE")
	var tot_bun := true

	for cati in [4, 5]:
		var minciuni: Array[String] = []
		var nedeterminate := 0
		var reusite := 0
		for i in range(TRAGERI_PE_TIPAR):
			var enigma: Dictionary = scena._enigma_asezare(cati, LOGICA.INDICII_ASEZARE_TOATE)
			if enigma.is_empty():
				nedeterminate += 1
				continue
			reusite += 1
			var locuri: Array = enigma["locuri"]

			# (a) Situația ascunsă respectă fiecare indiciu. Dacă nu, un indiciu
			# e o minciună, iar enigma n-are nicio soluție bună.
			for indiciu in enigma["indicii"]:
				if not LOGICA._asezare_tine(indiciu, locuri, cati):
					minciuni.append("indiciu fals: %s" % indiciu["t"])
					break

			# (b) Răspunsul publicat e chiar cine stă acolo.
			if locuri[enigma["cine"]] != enigma["loc"]:
				minciuni.append("raspunsul nu e cine sta pe loc")

			# (c) Niciun alt om nu poate sta pe locul întrebat.
			var solutii: Array = LOGICA._solutii_asezare(enigma["indicii"], cati)
			var altul := false
			for solutie in solutii:
				if solutie.find(enigma["loc"]) != enigma["cine"]:
					altul = true
			if altul:
				minciuni.append("locul %d are doua raspunsuri" % enigma["loc"])
			if not _printre(solutii, locuri):
				minciuni.append("asezarea ascunsa nu e intre soluții")

		tot_bun = _verdict(
			"%d insi: enigma spune adevarul" % cati,
			minciuni.is_empty(),
			_primele(minciuni, 3)
		) and tot_bun
		tot_bun = _verdict(
			"%d insi: se determina destul de des" % cati,
			float(nedeterminate) / float(TRAGERI_PE_TIPAR) <= MAX_RATA_DE_ESEC,
			"%d goale din %d" % [nedeterminate, TRAGERI_PE_TIPAR]
		) and tot_bun

	return tot_bun


func _potrivirea() -> bool:
	print("  POTRIVIREA")
	var tot_bun := true

	for proba in [
		{"cati": 3, "pe_om": true},
		{"cati": 4, "pe_om": true},
		{"cati": 4, "pe_om": false},
	]:
		var cati := int(proba["cati"])
		var pe_om := bool(proba["pe_om"])
		var minciuni: Array[String] = []
		var nedeterminate := 0
		for i in range(TRAGERI_PE_TIPAR):
			var enigma: Dictionary = scena._enigma_potrivire(
				cati, LOGICA.INDICII_POTRIVIRE_TOATE, pe_om
			)
			if enigma.is_empty():
				nedeterminate += 1
				continue
			var atribuire: Array = enigma["atribuire"]

			for indiciu in enigma["indicii"]:
				if not LOGICA._potrivire_tine(indiciu, atribuire):
					minciuni.append("indiciu fals: %s" % indiciu["t"])
					break

			# Răspunsul publicat e chiar ce spune împerecherea ascunsă.
			var adevarat: int = atribuire[enigma["intrebat"]] if pe_om else atribuire.find(enigma["intrebat"])
			if adevarat != enigma["raspuns"]:
				minciuni.append("raspunsul nu e cel adevarat")

			# Și nicio altă soluție nu dă alt răspuns.
			var solutii: Array = LOGICA._solutii_potrivire(enigma["indicii"], cati)
			var altul := false
			for solutie in solutii:
				var al_ei: int = solutie[enigma["intrebat"]] if pe_om else solutie.find(enigma["intrebat"])
				if al_ei != enigma["raspuns"]:
					altul = true
			if altul:
				minciuni.append("doua raspunsuri bune")
			if not _printre(solutii, atribuire):
				minciuni.append("imperecherea ascunsa nu e intre soluții")

		var eticheta := "%d oameni, %s" % [cati, "ce are X" if pe_om else "cine are Y"]
		tot_bun = _verdict(
			"%s: enigma spune adevarul" % eticheta,
			minciuni.is_empty(),
			_primele(minciuni, 3)
		) and tot_bun
		tot_bun = _verdict(
			"%s: se determina destul de des" % eticheta,
			float(nedeterminate) / float(TRAGERI_PE_TIPAR) <= MAX_RATA_DE_ESEC,
			"%d goale din %d" % [nedeterminate, TRAGERI_PE_TIPAR]
		) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 11. ENUNȚUL SE ȚINE SINGUR
#
# Secțiunile de dinainte verifică ce știe REZOLVITORUL: că fiecare indiciu e
# adevărat despre situația ascunsă și că răspunsul iese unul singur din ele.
# Niciuna nu verifică ce știe CITITORUL — și exact acolo a fost gaura.
#
# „Fiecare are alt lucru. / Luca nu are pumnal. / Anton nu are buzdugan. /
# Anton are buzdugan sau coif. / Ce are Luca?" avea, pentru rezolvitor, un
# singur răspuns: lucrurile împărțite sunt pumnal, buzdugan și coif, Anton ia
# coiful, Luca n-are voie la pumnal, deci lui Luca îi rămâne buzdugan. Pentru
# cititor, care nu aflase niciodată nici câți oameni sunt, nici care sunt
# lucrurile, „arc" de pe al patrulea buton era la fel de bun — două răspunsuri
# corecte, cu toate verdictele de mai sus verzi.
#
# De-aia secțiunea asta nu se uită la enigmă, ci la TEXTUL tipărit, și cere un
# singur lucru: nimeni și nimic să nu apară nedeclarat. Cu primul rând la locul
# lui, cele două lumi coincid — cititorul cunoaște exact distribuția pe care
# rezolvitorul a presupus-o, deci verdictele lui de unicitate devin și ale
# cititorului. Asta e tot rostul secțiunii: să lege unicitatea de enunț.
#
# Se uită numai la ASEZARE și la POTRIVIRE, și nu din lene: la DEDUCTIE și la
# MINCINOSI forma enunțului îi aduce pe toți de la sine (un lanț de comparații
# îi atinge pe toți, fiecare mincinos are replica lui), pe când aici indiciile
# se trag la întâmplare, deci un ins poate lipsi din toate.
# ─────────────────────────────────────────────────────────────

func _enuntul_se_tine() -> bool:
	print("  ENUNTUL SE TINE SINGUR")
	var tot_bun := true

	var prezinta_asezare := RegEx.create_from_string(
		r"^(.+) stau pe locurile 1-(\d+), de la stanga la dreapta\.$"
	)
	var prezinta_potrivire := RegEx.create_from_string(
		r"^(.+) au, fiecare, alt lucru: (.+)\.$"
	)

	for proba in [
		{"metoda": "_asezare_simpla", "cati": 4, "locuri": true, "pe_om": true},
		{"metoda": "_asezare_grea", "cati": 4, "locuri": true, "pe_om": true},
		{"metoda": "_asezare_cinci", "cati": 5, "locuri": true, "pe_om": true},
		{"metoda": "_potrivire_trei", "cati": 3, "locuri": false, "pe_om": true},
		{"metoda": "_potrivire_patru", "cati": 4, "locuri": false, "pe_om": true},
		{"metoda": "_potrivire_cine", "cati": 4, "locuri": false, "pe_om": false},
	]:
		var metoda := String(proba["metoda"])
		var cati := int(proba["cati"])
		var locuri := bool(proba["locuri"])
		var pe_om := bool(proba["pe_om"])

		var vini: Array[String] = []
		var facute := 0
		for i in range(TRAGERI_ENUNT):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			facute += 1

			var randuri := String(q["text"]).split("\n")
			var primul := String(randuri[0])
			var restul := "\n".join(randuri.slice(1))
			var variante: Array = q["variante"]

			var potrivire := (prezinta_asezare if locuri else prezinta_potrivire).search(primul)
			if potrivire == null:
				vini.append("primul rand nu prezinta scena: %s" % primul)
				continue

			var cast := _din_insiruire(potrivire.get_string(1), "si")
			if cast.size() != cati:
				vini.append("%d nume declarate, %d asteptate" % [cast.size(), cati])

			# Niciun nume din afara distribuției, nici în indicii, nici pe butoane.
			for nume in LOGICA.NUME:
				var pomenit: bool = restul.contains(String(nume)) or (String(nume) in variante)
				if pomenit and not (String(nume) in cast):
					vini.append("%s apare nedeclarat" % nume)

			if locuri:
				# Câte locuri spune primul rând că sunt? Trebuie să fie atâtea
				# câți inși — altfel „capatul din dreapta" arată spre nimic.
				if int(potrivire.get_string(2)) != cast.size():
					vini.append("locurile 1-%s pentru %d insi" % [
						potrivire.get_string(2), cast.size()
					])
				continue

			var recuzita := _din_insiruire(potrivire.get_string(2), "sau")
			if recuzita.size() != cati:
				vini.append("%d lucruri declarate, %d asteptate" % [recuzita.size(), cati])

			# Niciun lucru din afara recuzitei în indicii sau în întrebare.
			var cuvinte := _cuvintele(restul)
			for lucru in LOGICA.LUCRURI:
				if cuvinte.has(String(lucru)) and not (String(lucru) in recuzita):
					vini.append("%s apare nedeclarat" % lucru)

			if not pe_om:
				continue

			# Butoanele, la „ce are X": lucruri, și exact atâtea din afara
			# listei câte lipsesc până la patru — una la grila de trei, niciuna
			# la cea de patru. Din afara listei, dar DECLARAT din afara: cine
			# citește primul rând o taie din ochi.
			var din_afara := 0
			for varianta in variante:
				if not (String(varianta) in LOGICA.LUCRURI):
					vini.append("buton care nu e lucru: %s" % varianta)
				elif not (String(varianta) in recuzita):
					din_afara += 1
			if din_afara != 4 - cati:
				vini.append("%d butoane din afara listei, %d asteptate" % [
					din_afara, 4 - cati
				])

		tot_bun = _verdict(
			"%s: nimeni si nimic nedeclarat" % metoda,
			facute > 0 and vini.is_empty(),
			_primele(vini, 3) if facute > 0 else "niciun enunt compus"
		) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 12. „NU SE POATE STABILI" NU E UN SEMN
#
# Decizia de design: varianta apare la TOATE tiparele de inferență, nu doar la
# cele unde e corectă. Altfel s-ar putea răspunde fără să citești premisele —
# „văd «Nu se poate stabili», deci asta e".
# ─────────────────────────────────────────────────────────────

func _nehotaratul() -> bool:
	print("  „NU SE POATE STABILI”")
	var tot_bun := true

	var lipsa: Array[String] = []
	for metoda in TIPARE_CU_NEHOTARAT:
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			if not (LOGICA.NEHOTARAT in q["variante"]):
				lipsa.append(String(metoda))
				break
	tot_bun = _verdict(
		"apare la toate tiparele de inferenta",
		lipsa.is_empty(),
		_primele(lipsa, 5)
	) and tot_bun

	# Și e răspunsul bun numai acolo unde trebuie: la capcanele de nivel III.
	var corect_unde_nu_trebuie: Array[String] = []
	for metoda in TIPARE_CU_NEHOTARAT:
		if metoda == "_conditional_nehotarat":
			continue
		for i in range(TRAGERI_PE_TIPAR):
			var q: Dictionary = scena.call(metoda)
			if q.is_empty():
				continue
			if String(q["variante"][int(q["corect"])]) == LOGICA.NEHOTARAT:
				corect_unde_nu_trebuie.append(String(metoda))
				break
	tot_bun = _verdict(
		"nu e raspunsul bun la tiparele cu concluzie",
		corect_unde_nu_trebuie.is_empty(),
		_primele(corect_unde_nu_trebuie, 5)
	) and tot_bun

	var mereu_corect := true
	for i in range(TRAGERI_PE_TIPAR):
		var q: Dictionary = scena.call("_conditional_nehotarat")
		if q.is_empty():
			continue
		if String(q["variante"][int(q["corect"])]) != LOGICA.NEHOTARAT:
			mereu_corect = false
			break
	tot_bun = _verdict(
		"e raspunsul bun la cele doua capcane",
		mereu_corect
	) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 13. ECHILIBRUL PE TIPURI
#
# Alegerea e în două trepte (întâi tipul, apoi tiparul) tocmai ca un tip cu 9
# tipare să nu apară de 9 ori mai des decât unul cu unul singur. E cea mai greu
# de înlocuit cu ochiul: la o partidă n-ai cum să vezi o probabilitate.
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL (%d trageri pe nivel)" % TRAGERI_ECHILIBRU)
	var tot_bun := true

	var tip_pe_antet := {}
	for generator in LOGICA.GENERATOARE:
		tip_pe_antet[String(generator["categorie"])] = String(generator["tip"])

	for nivel in [1, 2, 3]:
		var asteptate := {}
		for generator in LOGICA.GENERATOARE:
			if nivel in generator["niveluri"]:
				asteptate[String(generator["tip"])] = true

		var numarate := {}
		for i in range(TRAGERI_ECHILIBRU):
			var q: Dictionary = scena._compune_intrebare(nivel)
			if q.is_empty():
				continue
			var tip: String = tip_pe_antet[String(q["categorie"])]
			numarate[tip] = int(numarate.get(tip, 0)) + 1

		var tinta := float(TRAGERI_ECHILIBRU) / float(asteptate.size())
		var strambe: Array[String] = []
		for tip in asteptate:
			var cate := int(numarate.get(tip, 0))
			if absf(float(cate) - tinta) / tinta > TOLERANTA_ECHILIBRU:
				strambe.append("%s %d" % [tip, cate])
		# Un tip care iese la nivelul la care NU e declarat ar însemna că plasa
		# de siguranță din `_alege_reteta` se deschide degeaba.
		for tip in numarate:
			if not asteptate.has(tip):
				strambe.append("%s nu e de nivelul %d" % [tip, nivel])

		tot_bun = _verdict(
			"nivelul %d: %d tipuri, ~%d fiecare" % [nivel, asteptate.size(), int(tinta)],
			strambe.is_empty(),
			_primele(strambe, 5)
		) and tot_bun

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 14. FĂRĂ REPETIȚII PE EXPEDIȚIE
#
# `_compune_nerepetata` din `puzzle.gd` nu poate GARANTA nimic la o disciplină
# generativă: nu-și poate enumera întrebările, deci nu se poate face un sac din
# ele. Ce se poate afla e cât de rar repetă de fapt — iar dacă o rescriere ar
# strica identitatea întrebării (enunț + variante sortate), cifra ar sări în ochi.
# ─────────────────────────────────────────────────────────────

func _fara_repetitii() -> bool:
	print("  FARA REPETITII (%d trageri pe nivel)" % TRAGERI_SAC)
	var tot_bun := true

	for nivel in [1, 2, 3]:
		Sac.expeditie_noua()
		var vazute := {}
		for i in range(TRAGERI_SAC):
			var q: Dictionary = scena._compune_nerepetata(nivel)
			if q.is_empty():
				continue
			vazute[scena._identitate_intrebare(q)] = true
		var repetari := TRAGERI_SAC - vazute.size()
		tot_bun = _verdict(
			"nivelul %d: cel mult 5%% repetari" % nivel,
			repetari <= TRAGERI_SAC / 20,
			"%d repetari din %d" % [repetari, TRAGERI_SAC]
		) and tot_bun
	Sac.expeditie_noua()

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 15. CÂT SE CITEȘTE — o MĂSURĂTOARE, nu un verdict
#
# Ca tabelul din `verifica_coltul`: se citește, nu se bifează. La inamicul cu
# cronometru ai 12 secunde (15 la nivelul III) pentru TOT — citit inclusiv. Un
# tip care cere constant cinci rânduri e corect și, pe un ceas, nejucabil.
# Verdictul îl dau ochii, dar cifra trebuie să existe.
# ─────────────────────────────────────────────────────────────

func _cat_se_citeste() -> void:
	print("  CAT SE CITESTE (nu e verdict, e masuratoare)")
	print("    %-20s %7s %7s %7s" % ["tip", "rand.", "rand.", "semne"])
	print("    %-20s %7s %7s %7s" % ["", "mediu", "maxim", "maxim"])

	for tip in _tipurile():
		var metode: Array[String] = []
		for generator in LOGICA.GENERATOARE:
			if String(generator["tip"]) == tip:
				metode.append(String(generator["metoda"]))

		var randuri := 0
		var randuri_maxim := 0
		var semne_maxim := 0
		var cate := 0
		for metoda in metode:
			for i in range(50):
				var q: Dictionary = scena.call(metoda)
				if q.is_empty():
					continue
				var text := String(q["text"])
				var r := text.split("\n").size()
				randuri += r
				randuri_maxim = maxi(randuri_maxim, r)
				semne_maxim = maxi(semne_maxim, text.length())
				cate += 1
		if cate == 0:
			continue
		print("    %-20s %7.1f %7d %7d" % [
			tip, float(randuri) / float(cate), randuri_maxim, semne_maxim
		])


# ─────────────────────────────────────────────────────────────
# AJUTOARE
# ─────────────────────────────────────────────────────────────

## Numele celor 15 tipuri, în ordinea din tabel.
func _tipurile() -> Array[String]:
	var tipuri: Array[String] = []
	for generator in LOGICA.GENERATOARE:
		var tip := String(generator["tip"])
		if not (tip in tipuri):
			tipuri.append(tip)
	return tipuri


## „Anton, Emil si Radu" → [Anton, Emil, Radu]. Despărțitorul de la sfârșit e
## parametru, fiindcă enunțul leagă oamenii cu „si" și lucrurile cu „sau".
func _din_insiruire(text: String, legatura: String) -> Array:
	var rezultat: Array = []
	for bucata in text.replace(" %s " % legatura, ", ").split(", "):
		rezultat.append(String(bucata).strip_edges())
	return rezultat


## Cuvintele unui text, tăiate pe orice nu e literă. Pe cuvinte întregi, nu cu
## `contains`: textul de afișare n-are diacritice, deci un cuvânt se termină
## unde se termină literele, iar „arc" n-are voie să fie găsit în „arcas".
func _cuvintele(text: String) -> Array:
	var rezultat: Array = []
	var curent := ""
	for caracter in text:
		if (caracter >= "a" and caracter <= "z") or (caracter >= "A" and caracter <= "Z"):
			curent += caracter
		else:
			if curent != "":
				rezultat.append(curent)
			curent = ""
	if curent != "":
		rezultat.append(curent)
	return rezultat


## Toate numerele dintr-un text, în ordinea în care apar.
func _numerele(text: String) -> Array:
	var gasite: Array = []
	for potrivire in cifre.search_all(text):
		gasite.append(int(potrivire.get_string()))
	return gasite


## Doua liste de numere sunt aceeasi? Scrisa de mana, nu cu `==`: felul in care
## Godot compara doua `Array` e un amanunt de limbaj, iar verificarea nu are de
## ce sa depinda de el — mai ales cand ce masoara e tocmai o egalitate.
func _la_fel(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if int(a[i]) != int(b[i]):
			return false
	return true


## Lista se afla printre cele date?
func _printre(liste: Array, cautata: Array) -> bool:
	for lista in liste:
		if _la_fel(lista, cautata):
			return true
	return false


func _cu_majuscula(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1)


func _lista(numere: Array) -> String:
	var bucati: Array[String] = []
	for n in numere:
		bucati.append(str(n))
	return "[%s]" % ", ".join(bucati)


# Aceleași două ajutoare ca la celelalte unelte, ca rapoartele să se citească la
# fel. Copiate dinadins, nu puse într-o bază comună: sunt patru rânduri de
# `print`, iar o bază comună de unelte ar fi un fișier pe care l-ai atinge de
# fiecare dată când o unealtă vrea o coloană în plus.

func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-46s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array, cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(String(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

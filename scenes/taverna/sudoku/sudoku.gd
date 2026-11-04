extends Joc
## SUDOKU — masa a doua din Tavernă.
##
## Nouă pe nouă, cifrele 1-9 o singură dată pe linie, pe coloană și în fiecare
## pătrat de 3×3. Fără ceas, fără limită de greșeli: joci până iese.
##
## Se poate juca singură, cu F6: nu știe nimic despre Tavernă, exact ca
## Cuvântul Ascuns și ca cele opt discipline.
##
## ─────────────────────────────────────────────────────────────
## CE ANTRENEAZĂ, ȘI DE CE ERA A DOUA
##
## Cuvântul Ascuns e căutare cu constrângeri: afli puțin la fiecare rând, și ce
## afli taie din ce merită încercat. Sudoku e constrângeri URMĂRITE DEODATĂ:
## nimic nu se află, totul e deja pe ecran, iar ce lipsește e răbdarea de a
## citi trei reguli despre aceeași celulă. Chiar priceperea pe care pitch-ul o
## cerea Turnului Perseverenței, și singura din tot proiectul la care nu se
## pune nicio întrebare: ecranul nu te întreabă nimic, îți dă o STARE.
##
## A fost a doua, și nu prima, fiindcă e scumpă exact acolo unde Cuvântul
## Ascuns era ieftin: o listă de cuvinte se scrie, o grilă de Sudoku se
## GENEREAZĂ, iar o grilă generată nu e bună până nu i se dovedește că are UN
## SINGUR răspuns. Dovada cere un rezolvitor — adică mașinăria Lacătului, unde
## un cifru nu e crezut pe cuvânt, ci rezolvat.
##
## ─────────────────────────────────────────────────────────────
## DE CE N-ARE NICIUN FIȘIER DE DATE, ȘI DE CE N-ARE NICIUN SAC
##
## Prima masă fără date pe disc, și pentru exact motivul scris la Numere și la
## Tipare: **grila nu e conținut, e un interval**. „27 de cifre date dintr-o
## grilă validă" nu se scrie, se cere.
##
## Urmarea, care la Cuvântul Ascuns a costat un sac permanent: nu există
## repetiție de care să te păzești. Cele 308 cuvinte se termină în 308 partide;
## grilele nu se termină niciodată, deci `Sac` n-are ce ține minte aici. Masa
## asta nu scrie NIMIC pe disc, în afară de steagul „ți-am arătat regulile",
## care e al Tavernei.
##
## ─────────────────────────────────────────────────────────────
## UNICITATEA E O DOVADĂ, NU O SPERANȚĂ
##
## Generatorul face întâi o grilă PLINĂ (prin backtracking, cu cifrele luate în
## ordine amestecată), apoi scoate cifre una câte una — și după fiecare
## scoatere **numără soluțiile**. Dacă ies două, cifra se pune înapoi.
##
## Deci grila dată jucătorului nu „probabil" are un singur răspuns: are, fiindcă
## nu s-a scos nicio cifră care să-l dubleze. Aceeași metodă, din același motiv,
## ca la cele trei tipuri de Logică ce CAUTĂ răspunsul (mincinoși, locuri,
## potrivire): un puzzle nu se crede pe cuvânt, se rezolvă.
##
## Și tot de-acolo vine ce se întâmplă la final: o grilă plină în care nicio
## cifră nu se bate cu alta E răspunsul. Nu se compară nimic cu soluția
## păstrată — comparația ar fi fost un al doilea adevăr, care se poate
## contrazice cu primul. Vezi `e_gata()`.
##
## ─────────────────────────────────────────────────────────────
## NIVELURILE STAU PE TĂBLIE, NU ÎN CATALOG
##
## `joc.gd` spunea, înainte să existe masa asta: „dacă o masă vrea totuși
## dificultăți (Sudoku le va vrea), aia intră ca sămânță sau ca rând în
## catalog, nu ca parametru al tuturor". Trei rânduri în catalog ar fi fost
## cinstit, și a căzut dintr-un motiv MĂSURAT: a patra masă nu mai încape pe un
## rând (vezi `LATIME_MASA` din `taverna.gd`), deci trei Sudoku-uri ar fi cerut
## grila de două coloane înainte ca Decretul Zilei să existe. Și ar fi fost trei
## mese cu aceleași reguli, deci trei „prime dăți".
##
## Deci nivelul e o alegere de pe masă: trei butoane peste grilă. Prețul, plătit
## conștient: un clic pe alt nivel REPORNEȘTE partida (o grilă nu se poate
## rescala), iar nivelul de pe ecran se vede apăsat, ca schimbarea să nu se
## întâmple din neatenție.
##
## Ținut `static`, ca `_nivel_atins` din Practice: masa se naște din nou la
## fiecare „Încă unul", iar o variabilă de instanță ar fi uitat nivelul ales
## între două partide — adică alegerea ar fi ținut o singură grilă.
##
## CU SĂMÂNȚĂ DATĂ, nivelul îl hotărăște sămânța, nu butonul: Decretul Zilei
## promite „același joc toată ziua", iar nivelul e parte din joc. Altfel doi
## jucători ar fi primit „decretul de azi" în două dificultăți.
##
## ─────────────────────────────────────────────────────────────
## DE CE N-ARE ROȘU (ȘI AICI)
##
## Cuvântul Ascuns n-are roșu fiindcă n-are greșit. Sudoku ARE greșit — o cifră
## care se bate cu alta — și totuși nu e roșie, ci chihlimbar: în tot proiectul
## chihlimbarul înseamnă „uită-te aici, dar nu e nicio urgență" (bara expunerii
## din Reținere, litera din altă parte de la Cuvântul Ascuns). O cifră care se
## bate cu alta nu e un verdict, e o informație: ai de unde s-o scoți, și n-ai
## pierdut nimic. Roșul rămâne al lucrurilor pe care nu le mai poți lua înapoi,
## iar aici nu există niciunul.
##
## ─────────────────────────────────────────────────────────────
## CE NU SE POATE PIERDE
##
## `termina(true, …)` e singurul final: n-ai ceas, n-ai încercări numărate,
## deci nu există „ratat". Plecatul de la masă nu e o înfrângere, e o plecare.
## Numărul de greșeli e tot ce are jocul ăsta drept scor — și nu se adună
## nicăieri, fiindcă Taverna nu ține socoteli (vezi `taverna.gd`).

## Latura grilei și latura unui pătrat. VARIABILE, nu nouă scris prin cod: un
## Sudoku de 4×4 (pentru copii) ar fi un rând în catalog, nu o rescriere.
## Aceeași judecată ca `LUNGIME`/`RANDURI` la Cuvântul Ascuns.
const LATURA := 9
const LATURA_CUTIE := 3
const CELULE := LATURA * LATURA

## Cele trei niveluri: câte cifre rămân pe ecran.
##
## „Câte cifre DATE" e singura măsură cinstită aici, fiindcă e singura pe care
## generatorul o poate urmări: dificultatea adevărată a unui Sudoku ține de ce
## fel de raționament cere, iar aia n-o știi fără un rezolvitor care numără
## tehnici — o sesiune în sine, pentru un joc fără ceas.
##
## 26 e aproape de podeaua la care mai ajunge scoaterea care păzește
## unicitatea; dacă nu se poate coborî până acolo, grila rămâne cu câteva cifre
## mai multe și nimeni nu se plânge — ținta e un ȚEL, nu o promisiune. De-aia
## verificarea MĂSOARĂ câte au rămas, în loc să ceară un număr exact.
const NIVELURI := [
	{"nume": "Ușor", "cifre_date": 40},
	{"nume": "Mediu", "cifre_date": 32},
	{"nume": "Greu", "cifre_date": 26},
]

## Câte soluții se caută ca să se afle dacă grila mai are una singură. DOUĂ:
## „câte sunt" nu interesează pe nimeni, „mai e vreuna pe lângă asta"
## interesează — iar numărătoarea care se oprește la 2 e de zeci de ori mai
## iute decât una care le numără pe toate.
const PLAFON_SOLUTII := 2

# ─────────────────────────────────────────────────────────────
# ÎNFĂȚIȘAREA
#
# Culorile nu vin din temă, ca și la Cuvântul Ascuns, fiindcă nu sunt culori de
# ecran, sunt REGULILE jocului: ce e dat, ce ai scris tu, ce se bate cu altceva.
# O temă care le-ar schimba ar schimba ce înțelegi din ecran.
#
# Celula neîncepută e aproape transparentă, cu chenar, din motivul scris la
# `CULOARE_CELULA` din `cuvantul.gd`: masa n-are tăblie, deci 81 de pătrate
# crem ar fi fost cel mai luminos lucru de pe ecran, iar cele mai multe nu spun
# nimic. Lumina se dă celor care poartă informație.
# ─────────────────────────────────────────────────────────────
const CULOARE_CELULA := Color(1, 1, 1, 0.05)
## Fondul unei celule cu cifră DATĂ: puțin mai plin, ca să se vadă din ochi
## scheletul grilei fără să citești culoarea fiecărei cifre.
const CULOARE_CELULA_DATA := Color(1, 1, 1, 0.11)
const CULOARE_CHENAR := Color(0.58, 0.5, 0.4)
## Cât se mai adaugă la fondul celulei alese și al celor care o privesc (linia,
## coloana, pătratul). ADUNATE la fondul de dedesubt, nu puse în locul lui:
## altfel o celulă dată și una goală ar fi arătat la fel cât timp erau alese.
const LUMINA_ALEASA := 0.16
const LUMINA_RUDA := 0.05

## Cifrele date: cremul obișnuit al mesei. Cele scrise de tine: mai reci, ca să
## se deosebească dintr-o privire ce era pe ecran de la început — fără asta,
## „ce am pus eu aici?" ar fi cerut să ții minte.
const CULOARE_CIFRA_DATA := Color(0.98, 0.95, 0.88)
const CULOARE_CIFRA_SCRISA := Color(0.68, 0.82, 0.93)
## Vezi „DE CE N-ARE ROȘU" din antet. Același chihlimbar ca la litera din altă
## parte a Cuvântului Ascuns și ca bara expunerii din Reținere.
const CULOARE_CIFRA_CONFLICT := Color(0.86, 0.64, 0.16)

const MARIME_CELULA := 36
const MARIME_CIFRA := 20
const MARIME_TASTA := 18
const INALTIME_TASTA := 34
const LATIME_TASTA := 34

## Ce poate fi o celulă pe ecran. Nu e starea jocului (aia sunt cele două
## grile), e ce se DESENEAZĂ — iar rândurile de exemplu din reguli au nevoie de
## exact aceleași patru feluri, fără să fie un joc.
enum Fel { GOALA, DATA, SCRISA, CONFLICT }

## Nivelul ales de pe tăblie. `static` — vezi „NIVELURILE STAU PE TĂBLIE".
static var _nivel_ales := 1

## Cifrele date la început: 0 = gol. Nu se schimbă în timpul partidei.
var date: Array[int] = []
## Ce scrie acum pe ecran, cifrele date incluse.
var grila: Array[int] = []
## Nivelul grilei de pe ecran. Poate să nu fie `_nivel_ales`, dacă partida a
## pornit cu sămânță dată.
var nivel := 1
## Celula aleasă, sau -1.
var aleasa := -1
## Câte cifre ai pus care se băteau cu altceva în clipa punerii. Scorul.
var greseli := 0

## Celulele, pe index de la 0 la 80.
var celule: Array[PanelContainer] = []
## Cifra → butonul ei din rândul de jos.
var taste := {}
## Butoanele celor trei niveluri.
var butoane_nivel: Array[Button] = []

@onready var cutii: GridContainer = %Cutii
@onready var mesaj: Label = %Mesaj
@onready var rand_niveluri: HBoxContainer = %Niveluri
@onready var rand_taste: HBoxContainer = %Taste


func _ready() -> void:
	_construieste_grila()
	_construieste_nivelurile()
	_construieste_tastele()
	mesaj.text = ""
	# Ca să poți juca masa singură, cu F6: dacă nimeni n-a chemat `porneste()`
	# până la finalul cadrului, pornim noi. Același tipar, din același motiv, ca
	# în `cuvantul.gd` și în `puzzle.gd`.
	await get_tree().process_frame
	if not pornit:
		porneste()


# ─────────────────────────────────────────────────────────────
# PORNIREA
# ─────────────────────────────────────────────────────────────

func _porneste(cu_samanta: int) -> void:
	var rng := RandomNumberGenerator.new()
	if cu_samanta == SAMANTA_LIBERA:
		rng.randomize()
		nivel = _nivel_ales
	else:
		# Sămânța hotărăște TOT jocul, nivelul inclus — vezi antetul.
		rng.seed = cu_samanta
		nivel = cu_samanta % NIVELURI.size()

	date = genereaza(nivel, rng)
	grila = []
	grila.assign(date)
	aleasa = -1
	greseli = 0
	_zugraveste_nivelurile()
	_zugraveste_tot()
	_spune("%s — %d cifre date din %d." % [
		String(NIVELURI[nivel]["nume"]), cate_date(), CELULE])


## Regulile, pentru panoul Tavernei (vezi `Joc.reguli`).
##
## Compuse din constante — `LATURA`, `LATURA_CUTIE` — și arătate pe celule
## ADEVĂRATE, născute din `_celula_noua` și îmbrăcate de `_imbraca_celula`,
## chiar cele două funcții care fac grila. Aceeași judecată, scrisă la
## `reguli()` din `cuvantul.gd`: un exemplu construit cu alte funcții poate
## ajunge să arate altfel decât masa pe care o explică.
func reguli() -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 14)

	coloana.add_child(_rand_de_reguli(
		"Completează grila de %d × %d cu cifrele 1-%d. Fiecare cifră apare o singură dată"
		% [LATURA, LATURA, LATURA]
		+ " pe fiecare linie, pe fiecare coloană și în fiecare pătrat de %d × %d:"
		% [LATURA_CUTIE, LATURA_CUTIE], 17))

	# Un pătrat ADEVĂRAT, plin cu toate cele nouă cifre: regula „toate o dată,
	# niciuna de două ori" se vede dintr-o privire, nu se citește.
	coloana.add_child(_cutia_de_exemplu())

	coloana.add_child(_rand_de_reguli(
		"Cifrele date la început nu se schimbă. Cele scrise de tine sunt mai reci,"
		+ " iar una care se bate cu alta de pe linia, coloana sau din pătratul ei se face"
		+ " chihlimbar — n-ai pierdut nimic, doar ai de unde s-o scoți:", 15))

	coloana.add_child(_rand_de_exemplu())

	coloana.add_child(_rand_de_reguli(
		"Clic pe o celulă (sau săgețile), apoi cifra. 0, Șterge sau Backspace o golește."
		+ " Fără cronometru: grila te așteaptă.", 15))
	return coloana


## Un rând de text din panoul cu reguli. Culoarea e a MESEI, nu a temei: panoul
## stă pe fond închis, iar cerneala de pergament ar fi fost neagră pe negru.
func _rand_de_reguli(text: String, marime: int) -> Label:
	var eticheta := Label.new()
	eticheta.text = text
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", CULOARE_CIFRA_DATA)
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return eticheta


## Pătratul de 3×3 din reguli, cu cele nouă cifre amestecate. Amestecarea e
## FIXĂ, nu trasă la sorți: regulile trebuie să arate la fel de fiecare dată,
## altfel două citiri ale aceluiași panou n-ar mai fi același panou.
func _cutia_de_exemplu() -> Control:
	const CIFRE := [4, 9, 2, 3, 5, 7, 8, 1, 6]
	var centru := CenterContainer.new()
	var cutie := GridContainer.new()
	cutie.columns = LATURA_CUTIE
	cutie.add_theme_constant_override("h_separation", 2)
	cutie.add_theme_constant_override("v_separation", 2)
	for i in CIFRE.size():
		var celula := _celula_noua()
		# Jumătate date, jumătate scrise de tine: pătratul arată amândouă
		# culorile pe care le explică rândul de sub el.
		_imbraca_celula(celula, str(CIFRE[i]), Fel.DATA if i % 2 == 0 else Fel.SCRISA, 0.0)
		cutie.add_child(celula)
	centru.add_child(cutie)
	return centru


## Trei celule, una din fiecare fel, pentru rândul care explică culorile.
func _rand_de_exemplu() -> Control:
	var centru := CenterContainer.new()
	var rand := HBoxContainer.new()
	rand.add_theme_constant_override("separation", 10)
	for fel in [Fel.DATA, Fel.SCRISA, Fel.CONFLICT]:
		var celula := _celula_noua()
		_imbraca_celula(celula, "7", int(fel), 0.0)
		rand.add_child(celula)
	centru.add_child(rand)
	return centru


func rand_de_ajutor() -> String:
	return "Cifrele 1-%d, o singură dată pe linie, pe coloană și în pătrat. Fără cronometru." % LATURA


# ─────────────────────────────────────────────────────────────
# GENERATORUL — PARTEA CARE N-ARE NEVOIE DE ECRAN
#
# Tot ce urmează e `static`, și dinadins: verificarea permanentă bate grile pe
# zeci de semințe fără să deschidă nicio fereastră și fără să construiască
# niciun `PanelContainer`. O regulă care are nevoie de scenă ca să fie probată
# se probează mai rar.
#
# `Array[int]`, nu `PackedInt32Array`, și nu din nepăsare: un pachet se dă prin
# VALOARE, deci rezolvitorul recursiv care scrie în el ar fi scris de fapt
# într-o copie, iar fiecare treaptă de recursie ar fi plecat de la grila
# nemodificată. O greșeală care nu se vede: codul merge, doar numără altceva.
# ─────────────────────────────────────────────────────────────

## O grilă de joc: cifrele date, cu 0 în locurile goale.
static func genereaza(nivel_cerut: int, rng: RandomNumberGenerator) -> Array[int]:
	var plina := _grila_plina(rng)
	var cate_raman := int(NIVELURI[clampi(nivel_cerut, 0, NIVELURI.size() - 1)]["cifre_date"])
	return _scoate_cifre(plina, cate_raman, rng)


## O grilă completă și validă, prin backtracking cu cifrele luate în ordine
## amestecată. Ordinea amestecată E generatorul: cu cifrele luate mereu de la 1
## în sus, backtracking-ul ar fi dat aceeași grilă de fiecare dată.
static func _grila_plina(rng: RandomNumberGenerator) -> Array[int]:
	var g: Array[int] = []
	g.resize(CELULE)
	g.fill(0)
	_umple(g, 0, rng)
	return g


static func _umple(g: Array[int], i: int, rng: RandomNumberGenerator) -> bool:
	if i >= CELULE:
		return true
	var folosite := _folosite(g, i)
	for v in _cifre_amestecate(rng):
		if (folosite & (1 << v)) != 0:
			continue
		g[i] = v
		if _umple(g, i + 1, rng):
			return true
	g[i] = 0
	return false


## Cifrele 1-9, amestecate cu RNG-ul PRIMIT.
##
## Nu `Array.shuffle()`: aceea ia generatorul global al jocului, deci o sămânță
## dată n-ar mai fi dat același joc — exact promisiunea pentru care sămânța
## există în contract.
static func _cifre_amestecate(rng: RandomNumberGenerator) -> Array[int]:
	var ordine: Array[int] = []
	for v in range(1, LATURA + 1):
		ordine.append(v)
	for i in range(ordine.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t := ordine[i]
		ordine[i] = ordine[j]
		ordine[j] = t
	return ordine


## Scoate cifre cât timp grila rămâne cu UN SINGUR răspuns, până la ținta
## nivelului. Vezi „UNICITATEA E O DOVADĂ" din antet.
static func _scoate_cifre(plina: Array[int], cate_raman: int, rng: RandomNumberGenerator) -> Array[int]:
	var g: Array[int] = []
	g.assign(plina)

	var ordine: Array[int] = []
	for i in CELULE:
		ordine.append(i)
	for i in range(ordine.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t := ordine[i]
		ordine[i] = ordine[j]
		ordine[j] = t

	var ramase := CELULE
	for i in ordine:
		if ramase <= cate_raman:
			break
		var vechi: int = g[i]
		g[i] = 0
		if numara_solutii(g) == 1:
			ramase -= 1
		else:
			g[i] = vechi
	return g


## Câte răspunsuri are grila, numărate până la `PLAFON_SOLUTII`.
##
## Lucrează pe o COPIE: funcția se cheamă din mijlocul scoaterii, pe grila care
## se construiește, iar un rezolvitor care-și lasă cifrele de probă în ea ar fi
## întors „o soluție" despre o grilă pe care el însuși o completase.
static func numara_solutii(g: Array[int]) -> int:
	var lucru: Array[int] = []
	lucru.assign(g)
	return _numara(lucru)


## Alege de fiecare dată celula cu CELE MAI PUȚINE cifre posibile (în
## literatură: MRV). Fără asta, numărătoarea ar porni de la prima celulă goală
## și ar încerca nouă ramuri acolo unde una singură era cu putință — adică
## scoaterea celor ~55 de cifre ar fi durat minute, nu clipe.
static func _numara(g: Array[int]) -> int:
	var cea_mai_stramta := -1
	var masca_ei := 0
	var cele_mai_putine := LATURA + 1
	for i in CELULE:
		if g[i] != 0:
			continue
		var masca := _folosite(g, i)
		var cate := 0
		for v in range(1, LATURA + 1):
			if (masca & (1 << v)) == 0:
				cate += 1
		if cate < cele_mai_putine:
			cele_mai_putine = cate
			cea_mai_stramta = i
			masca_ei = masca
			# O celulă fără nicio cifră posibilă încheie ramura; una cu exact o
			# cifră e cea mai bună alegere cu putință, deci nu mai căutăm.
			if cate <= 1:
				break
	if cea_mai_stramta == -1:
		# Nicio celulă goală: grila e plină, deci e un răspuns.
		return 1
	if cele_mai_putine == 0:
		return 0

	var total := 0
	for v in range(1, LATURA + 1):
		if (masca_ei & (1 << v)) != 0:
			continue
		g[cea_mai_stramta] = v
		total += _numara(g)
		g[cea_mai_stramta] = 0
		if total >= PLAFON_SOLUTII:
			return total
	return total


## Cifrele deja folosite pe linia, coloana și în pătratul celulei `i`, ca BIȚI:
## bitul 5 aprins = cifra 5 e luată. Bitul 0 ar însemna „gol" și nu se citește
## niciodată.
##
## Biți și nu trei liste: funcția asta se cheamă de zeci de mii de ori la
## generarea unei singure grile, deci e singurul loc din masă în care viteza e
## un argument.
static func _folosite(g: Array[int], i: int) -> int:
	@warning_ignore("integer_division")
	var r := i / LATURA
	var c := i % LATURA
	var masca := 0
	for k in LATURA:
		masca |= 1 << g[r * LATURA + k]
		masca |= 1 << g[k * LATURA + c]
	@warning_ignore("integer_division")
	var r0 := (r / LATURA_CUTIE) * LATURA_CUTIE
	@warning_ignore("integer_division")
	var c0 := (c / LATURA_CUTIE) * LATURA_CUTIE
	for dr in LATURA_CUTIE:
		for dc in LATURA_CUTIE:
			masca |= 1 << g[(r0 + dr) * LATURA + c0 + dc]
	return masca


## Se bate cifra din celula `i` cu altceva de pe linia, coloana sau din
## pătratul ei? O celulă goală nu se bate cu nimic.
static func se_bate(g: Array[int], i: int) -> bool:
	var v: int = g[i]
	if v == 0:
		return false
	@warning_ignore("integer_division")
	var r := i / LATURA
	var c := i % LATURA
	for k in LATURA:
		var pe_linie := r * LATURA + k
		if pe_linie != i and g[pe_linie] == v:
			return true
		var pe_coloana := k * LATURA + c
		if pe_coloana != i and g[pe_coloana] == v:
			return true
	@warning_ignore("integer_division")
	var r0 := (r / LATURA_CUTIE) * LATURA_CUTIE
	@warning_ignore("integer_division")
	var c0 := (c / LATURA_CUTIE) * LATURA_CUTIE
	for dr in LATURA_CUTIE:
		for dc in LATURA_CUTIE:
			var j := (r0 + dr) * LATURA + c0 + dc
			if j != i and g[j] == v:
				return true
	return false


## E grila gata? Plină ȘI fără nicio cifră care se bate cu alta.
##
## NU se compară cu soluția generată, și ăsta e tot rostul unicității: o grilă
## plină fără conflicte are pe fiecare linie, pe fiecare coloană și în fiecare
## pătrat nouă cifre deosebite — adică E un răspuns. Iar răspunsul e unic,
## fiindcă generatorul n-a scos nicio cifră care să-l dubleze. O a doua măsură
## („seamănă cu ce-am generat?") ar fi fost un al doilea adevăr, care se poate
## contrazice cu primul.
static func e_gata(g: Array[int]) -> bool:
	for i in CELULE:
		if g[i] == 0 or se_bate(g, i):
			return false
	return true


# ─────────────────────────────────────────────────────────────
# CE APEȘI
# ─────────────────────────────────────────────────────────────

## Tastatura adevărată. Butoanele de pe ecran sunt a doua cale către ACELEAȘI
## funcții, nu o cale separată — ca la Cuvântul Ascuns.
func _unhandled_key_input(event: InputEvent) -> void:
	if terminat_deja:
		return
	var tasta := event as InputEventKey
	if tasta == null or not tasta.pressed or tasta.echo:
		return

	var cod := tasta.keycode
	if cod >= KEY_1 and cod <= KEY_9:
		_scrie_cifra(cod - KEY_0)
		accept_event()
	elif cod >= KEY_KP_1 and cod <= KEY_KP_9:
		_scrie_cifra(cod - KEY_KP_0)
		accept_event()
	elif cod == KEY_0 or cod == KEY_KP_0 or cod == KEY_BACKSPACE or cod == KEY_DELETE:
		_scrie_cifra(0)
		accept_event()
	elif cod == KEY_LEFT:
		muta(0, -1)
		accept_event()
	elif cod == KEY_RIGHT:
		muta(0, 1)
		accept_event()
	elif cod == KEY_UP:
		muta(-1, 0)
		accept_event()
	elif cod == KEY_DOWN:
		muta(1, 0)
		accept_event()


## Alege o celulă. Și una DATĂ se poate alege: altfel săgețile ar fi sărit
## peste jumătate din grilă, iar un clic pe o cifră dată n-ar fi făcut nimic
## fără să spună de ce.
func alege(i: int) -> void:
	if terminat_deja or i < 0 or i >= CELULE:
		return
	aleasa = i
	_spune("Cifrele date nu se schimbă." if date[i] != 0 else "")
	_zugraveste_tot()


## Mută alegerea cu o celulă. Fără alegere, prima săgeată alege MIJLOCUL: un
## colț ar fi fost o alegere arbitrară, mijlocul e cel mai aproape de orice.
func muta(dr: int, dc: int) -> void:
	if aleasa < 0:
		@warning_ignore("integer_division")
		var mijloc := (CELULE - 1) / 2
		alege(mijloc)
		return
	@warning_ignore("integer_division")
	var r: int = aleasa / LATURA
	var c: int = aleasa % LATURA
	alege(clampi(r + dr, 0, LATURA - 1) * LATURA + clampi(c + dc, 0, LATURA - 1))


## Scrie o cifră (sau 0, ca să golească) în celula aleasă.
func _scrie_cifra(v: int) -> void:
	if terminat_deja:
		return
	if aleasa < 0:
		_spune("Alege o celulă, apoi cifra.")
		return
	if date[aleasa] != 0:
		_spune("Cifrele date nu se schimbă.")
		return

	grila[aleasa] = v
	if v != 0 and se_bate(grila, aleasa):
		# Greșeala se numără în clipa punerii, nu la final: o cifră pusă greșit
		# și scoasă a fost tot o greșeală, iar una numărată la final s-ar fi
		# șters odată cu ea.
		greseli += 1
		_spune("%d se bate cu o cifră de pe linie, coloană sau din pătrat." % v)
		Sunet.reda(Sunet.Efect.GRESIT)
	else:
		_spune("")
	_zugraveste_tot()

	if e_gata(grila):
		Sunet.reda(Sunet.Efect.CORECT)
		termina(true, rezumat())


## Fraza de la final. Greșelile sunt tot scorul jocului ăsta — vezi „CE NU SE
## POATE PIERDE" din antet.
func rezumat() -> String:
	var cum := "fără nicio greșeală"
	if greseli == 1:
		cum = "cu o greșeală"
	elif greseli > 1:
		cum = "cu %d greșeli" % greseli
	return "Gata! Grila de nivel %s, completată %s." % [
		String(NIVELURI[nivel]["nume"]).to_lower(), cum]


## Un alt nivel repornește partida — vezi „NIVELURILE STAU PE TĂBLIE".
##
## `porneste()`, nu `_porneste()`: cea publică e cea care spune Tavernei că
## începe o partidă nouă (semnalul `pornita`), deci rândul cu rezultatul
## partidei de dinainte se închide. Chemată de-a dreptul, cea privată ar fi
## lăsat „Gata! Grila mediu…" scris sub o grilă abia începută.
func schimba_nivelul(n: int) -> void:
	if n < 0 or n >= NIVELURI.size():
		return
	_nivel_ales = n
	porneste(SAMANTA_LIBERA)


func _spune(text: String) -> void:
	mesaj.text = text


## Câte cifre are grila de la început. Măsurată, nu citită din `NIVELURI`:
## scoaterea se poate înfunda, iar atunci rămân câteva mai multe.
func cate_date() -> int:
	var cate := 0
	for v in date:
		if v != 0:
			cate += 1
	return cate


# ─────────────────────────────────────────────────────────────
# ECRANUL
# ─────────────────────────────────────────────────────────────

## Grila, ca nouă pătrate de nouă celule.
##
## Un `GridContainer` de `GridContainer`-e, și nu 81 de celule într-unul
## singur: liniile groase dintre pătrate sunt chiar ce face un Sudoku citibil,
## iar așa ele vin din DOUĂ separări (una mare între cutii, una mică între
## celule) în loc dintr-un desenator care ar fi trebuit să știe unde cad
## marginile.
func _construieste_grila() -> void:
	for copil in cutii.get_children():
		copil.queue_free()
	celule.clear()
	celule.resize(CELULE)
	cutii.columns = LATURA_CUTIE
	for cutie_r in LATURA_CUTIE:
		for cutie_c in LATURA_CUTIE:
			var cutie := GridContainer.new()
			cutie.columns = LATURA_CUTIE
			cutie.add_theme_constant_override("h_separation", 2)
			cutie.add_theme_constant_override("v_separation", 2)
			cutii.add_child(cutie)
			for dr in LATURA_CUTIE:
				for dc in LATURA_CUTIE:
					var r := cutie_r * LATURA_CUTIE + dr
					var c := cutie_c * LATURA_CUTIE + dc
					var celula := _celula_noua()
					# `bind` duce indexul la funcția de alegere: fiecare celulă
					# știe doar cine e, nu ce să facă.
					celula.gui_input.connect(_pe_clic_celula.bind(r * LATURA + c))
					cutie.add_child(celula)
					celule[r * LATURA + c] = celula


func _pe_clic_celula(event: InputEvent, i: int) -> void:
	var clic := event as InputEventMouseButton
	if clic != null and clic.pressed and clic.button_index == MOUSE_BUTTON_LEFT:
		alege(i)


## O celulă goală, cu chenar. Folosită de grilă ȘI de rândurile de exemplu din
## reguli — vezi `reguli()`.
func _celula_noua() -> PanelContainer:
	var celula := PanelContainer.new()
	celula.custom_minimum_size = Vector2(MARIME_CELULA, MARIME_CELULA)
	celula.add_theme_stylebox_override("panel", _stil_celula(CULOARE_CELULA))
	var eticheta := Label.new()
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	eticheta.add_theme_font_size_override("font_size", MARIME_CIFRA)
	eticheta.add_theme_color_override("font_color", CULOARE_CIFRA_DATA)
	celula.add_child(eticheta)
	return celula


## Pune o cifră într-o celulă și o îmbracă după fel. `lumina` e cât se adaugă
## la fondul ei (celula aleasă, sau una care o privește).
func _imbraca_celula(celula: PanelContainer, text: String, fel: int, lumina: float) -> void:
	var eticheta: Label = celula.get_child(0)
	eticheta.text = text
	eticheta.add_theme_color_override("font_color", _culoare_cifra(fel))
	var fond := CULOARE_CELULA_DATA if fel == Fel.DATA else CULOARE_CELULA
	if lumina > 0.0:
		fond = Color(fond.r, fond.g, fond.b, fond.a + lumina)
	celula.add_theme_stylebox_override("panel", _stil_celula(fond))


func _culoare_cifra(fel: int) -> Color:
	match fel:
		Fel.DATA:
			return CULOARE_CIFRA_DATA
		Fel.CONFLICT:
			return CULOARE_CIFRA_CONFLICT
		_:
			return CULOARE_CIFRA_SCRISA


func _stil_celula(culoare: Color) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = culoare
	stil.corner_radius_top_left = 3
	stil.corner_radius_top_right = 3
	stil.corner_radius_bottom_left = 3
	stil.corner_radius_bottom_right = 3
	stil.border_color = CULOARE_CHENAR
	stil.set_border_width_all(1)
	return stil


## Toată grila, de la zero.
##
## Repictată ÎNTREAGĂ la fiecare apăsare, și nu doar celula atinsă: o cifră nou
## pusă poate aprinde un conflict în ALTĂ celulă (cea cu care se bate), iar
## alegerea mută lumina de pe o linie întreagă pe alta. 81 de etichete sunt
## nimic pentru un joc fără ceas; a ține minte „ce s-a schimbat" ar fi fost o a
## doua socoteală, care se poate contrazice cu prima.
func _zugraveste_tot() -> void:
	for i in CELULE:
		var v: int = grila[i] if i < grila.size() else 0
		var fel := Fel.GOALA
		if date.size() == CELULE and date[i] != 0:
			fel = Fel.DATA
		elif v != 0:
			# Numai cifrele TALE se fac chihlimbar: o cifră dată nu greșește
			# niciodată, deci marcată ea ar fi dat vina pe grilă.
			fel = Fel.CONFLICT if se_bate(grila, i) else Fel.SCRISA
		_imbraca_celula(celule[i], "" if v == 0 else str(v), fel, _lumina_pentru(i))
	_zugraveste_tastele()


## Cât de luminoasă e celula `i`: aleasă, rudă (pe linia, coloana sau în
## pătratul celei alese), sau nimic.
##
## Rudele se aprind fiindcă pe 81 de celule geometria nu se mai vede dintr-o
## privire — dar nu te scutesc de nimic: tot tu citești cifrele. Lumina arată
## UNDE se uită regula, nu ce spune.
func _lumina_pentru(i: int) -> float:
	if aleasa < 0:
		return 0.0
	if i == aleasa:
		return LUMINA_ALEASA
	@warning_ignore("integer_division")
	var r := i / LATURA
	var c := i % LATURA
	@warning_ignore("integer_division")
	var ra := aleasa / LATURA
	var ca := aleasa % LATURA
	@warning_ignore("integer_division")
	var aceeasi_cutie := (r / LATURA_CUTIE == ra / LATURA_CUTIE) \
		and (c / LATURA_CUTIE == ca / LATURA_CUTIE)
	if r == ra or c == ca or aceeasi_cutie:
		return LUMINA_RUDA
	return 0.0


func _construieste_nivelurile() -> void:
	for copil in rand_niveluri.get_children():
		copil.queue_free()
	butoane_nivel.clear()
	for n in NIVELURI.size():
		var buton := _buton(String(NIVELURI[n]["nume"]), 62)
		buton.pressed.connect(schimba_nivelul.bind(n))
		rand_niveluri.add_child(buton)
		butoane_nivel.append(buton)


## Nivelul de pe ecran se vede apăsat. Fără asta, cele trei butoane ar fi fost
## trei întrebări fără răspuns: „la care sunt acum?"
func _zugraveste_nivelurile() -> void:
	for n in butoane_nivel.size():
		var buton := butoane_nivel[n]
		if n == nivel:
			buton.add_theme_stylebox_override("normal", _stil_celula(Color(1, 1, 1, 0.2)))
			buton.add_theme_color_override("font_color", CULOARE_CIFRA_DATA)
		else:
			_imbraca_buton_stins(buton)


func _construieste_tastele() -> void:
	for copil in rand_taste.get_children():
		copil.queue_free()
	taste.clear()
	for v in range(1, LATURA + 1):
		var buton := _buton(str(v), LATIME_TASTA)
		buton.pressed.connect(_scrie_cifra.bind(v))
		rand_taste.add_child(buton)
		taste[v] = buton
	var sterge := _buton("Șterge", 64)
	sterge.pressed.connect(_scrie_cifra.bind(0))
	rand_taste.add_child(sterge)


## Cifrele puse deja de nouă ori se sting: n-au ce să mai caute pe nicio
## celulă, iar o tastă care nu mai are rost e un lucru mai puțin de cântărit.
## STINSE, nu scoase: locul lor rămâne, altfel rândul s-ar fi rearanjat sub
## degete la fiecare a noua cifră.
func _zugraveste_tastele() -> void:
	var cate := {}
	for v in grila:
		if v != 0:
			cate[v] = int(cate.get(v, 0)) + 1
	for v in taste:
		var buton: Button = taste[v]
		buton.modulate = Color(1, 1, 1, 0.4 if int(cate.get(v, 0)) >= LATURA else 1.0)


func _buton(text: String, latime: int) -> Button:
	var buton := Button.new()
	buton.text = text
	buton.custom_minimum_size = Vector2(latime, INALTIME_TASTA)
	buton.add_theme_font_size_override("font_size", MARIME_TASTA)
	# FĂRĂ FOCUS, din motivul scris la `_tasta` din `cuvantul.gd`: un buton cu
	# focus mănâncă tastele, iar aici tastele sunt chiar cum se joacă.
	buton.focus_mode = Control.FOCUS_NONE
	_imbraca_buton_stins(buton)
	return buton


func _imbraca_buton_stins(buton: Button) -> void:
	buton.add_theme_stylebox_override("normal", _stil_celula(CULOARE_CELULA))
	buton.add_theme_stylebox_override("hover", _stil_celula(Color(1, 1, 1, 0.14)))
	buton.add_theme_stylebox_override("pressed", _stil_celula(Color(1, 1, 1, 0.2)))
	for nume in ["font_color", "font_hover_color", "font_pressed_color"]:
		buton.add_theme_color_override(nume, CULOARE_CIFRA_SCRISA)

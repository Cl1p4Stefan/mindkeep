extends Joc
## CUVÂNTUL ASCUNS — prima masă din Tavernă.
##
## Șase încercări pentru un cuvânt de cinci litere. Fiecare încercare îți spune,
## literă cu literă: e chiar acolo (verde), e în cuvânt dar altundeva
## (chihlimbar), nu e deloc (stins). Tiparul e cel al lui Wordle.
##
## Se poate juca singură, cu F6: nu știe nimic despre Tavernă, exact ca cele opt
## discipline, care pornesc singure fără să știe de luptă.
##
## ─────────────────────────────────────────────────────────────
## CE ANTRENEAZĂ, ȘI DE CE ERA PRIMA
##
## Căutare cu constrângeri: la fiecare rând afli puțin, iar ce afli taie din ce
## merită încercat. Nu e memorie (ca Reținerea) și nu e viteză (n-are ceas) — e
## chiar priceperea pe care Turnul Perseverenței o voia: urmărirea mai multor
## constrângeri deodată, fără grabă.
##
## A fost prima dintre mese fiindcă e cea mai ieftină: o grilă, o tastatură și o
## listă de cuvinte. Sudoku cere pe deasupra un GENERATOR cu unicitate
## garantată, adică un rezolvitor care probează fiecare grilă — exact
## mașinăria pe care a cerut-o Lacătul, și o sesiune în sine.
##
## ─────────────────────────────────────────────────────────────
## CUVINTELE SUNT FĂRĂ DIACRITICE, ȘI ASTA E O DECIZIE, NU O LENE
##
## Alfabetul românesc are 31 de litere; tastatura are 26. Dacă răspunsul ar
## putea fi „carte" cu Ă sau Â, jucătorul ar trebui să ghicească și CUM se
## scrie, nu doar CE cuvânt e — iar o literă pe care n-o poți tasta nu e o
## ghicitoare, e o piedică. Deci lista ține numai cuvinte scrise din A-Z, și
## regula se DECLARĂ pe ecran, în rândul de ajutor.
##
## E a patra aplicare a regulii scrise la enigmele Logicii („un enunț care are
## nevoie de o convenție o declară"), după distribuția enigmelor, alfabetul
## literelor din Tipare și felul în care se numără liniile la Spațial.
##
## COSTUL, plătit conștient: româna își pune aproape toate substantivele
## feminine la singular în „-ă", deci lista e mai săracă în ele decât limba. 308
## cuvinte, destul pentru luni de joc, dar nu o oglindă a limbii.
##
## ─────────────────────────────────────────────────────────────
## O GHICIRE NU SE VERIFICĂ ÎN DICȚIONAR, ȘI DE CE
##
## Wordle refuză ghicirile care nu-s în lista lui. Aici orice cinci litere
## merg — fiindcă lista mea are 308 cuvinte, iar româna are zeci de mii. Un
## filtru ar fi respins aproape tot ce încearcă un jucător, adică l-ar fi
## pedepsit pentru conținutul care-mi lipsește MIE. Prețul invers e că se poate
## trage cu „aeiou" ca sondă de litere; într-un joc de antrenament fără clasament
## nu pierde nimeni nimic.
##
## Când lista va avea câteva mii de cuvinte, `CERE_CUVANT_DIN_LISTA` se pune pe
## `true` și regula se întoarce. Comutatorul stă aici, nu în date, fiindcă e o
## regulă de joc.
##
## ─────────────────────────────────────────────────────────────
## DE CE N-ARE ROȘU
##
## Celelalte jocuri ale proiectului spun „greșit" cu roșu (`Puzzle.CULOARE_RAU`).
## Aici nu există greșit: o literă care nu e în cuvânt e o INFORMAȚIE câștigată,
## nu o pedeapsă. Deci stinsă, nu roșie — iar roșul rămâne liber pentru singurul
## lucru care chiar e un eșec aici: niciun rând rămas.

## Cât e cuvântul și câte încercări ai.
##
## Cinci și șase sunt numerele lui Wordle, și nu sunt arbitrare: cu șase
## încercări la cinci litere, un jucător care joacă bine câștigă aproape
## întotdeauna, dar nu din prima — adică rămâne o ghicitoare, nu o loterie.
## VARIABILE, totuși, nu numere scrise prin cod: „patru litere, cinci încercări"
## ar fi o masă nouă în catalog, nu o rescriere.
const LUNGIME := 5
const RANDURI := 6

const CALE_CUVINTE := "res://data/taverna_cuvinte.json"

## Sacul cuvintelor deja ieșite. PERMANENT fiindcă Taverna nu e o expediție:
## un sac de expediție s-ar fi golit la fiecare run nou, adică ar fi repetat.
const CHEIE_SAC := "taverna:cuvantul_ascuns"

## Vezi „O GHICIRE NU SE VERIFICĂ ÎN DICȚIONAR" din antet.
const CERE_CUVANT_DIN_LISTA := false

## Ce poate fi o literă după o încercare. Ordinea NU e decorativă: starea de pe
## tastatură e maximul dintre ce se știa și ce s-a aflat (vezi `_tine_minte`),
## iar „maxim" are sens doar dacă ABSENT < ALTUNDEVA < BUN.
enum Semn { ABSENT, ALTUNDEVA, BUN }

# ─────────────────────────────────────────────────────────────
# ÎNFĂȚIȘAREA
#
# Culorile nu vin din temă, ci de aici, fiindcă nu sunt culori de ecran, sunt
# chiar REGULILE jocului: verde = la locul lui, chihlimbar = în cuvânt dar
# altundeva. O temă care le-ar schimba ar schimba ce înțelegi din ecran.
#
# Chihlimbarul e același cu cel al expunerii din Reținere (`CULOARE_EXPUNERE`):
# în tot proiectul el înseamnă „uită-te aici, dar nu e nicio urgență".
# ─────────────────────────────────────────────────────────────
const CULOARE_BUN := Color(0.24, 0.45, 0.22)
const CULOARE_ALTUNDEVA := Color(0.72, 0.52, 0.12)
const CULOARE_ABSENT := Color(0.38, 0.33, 0.28)
## Celula neîncepută: pergament, cu chenar. Nu goală — o celulă fără chenar nu
## se citește ca „aici urmează o literă".
const CULOARE_CELULA := Color(0.93, 0.87, 0.74)
const CULOARE_CHENAR := Color(0.55, 0.45, 0.32)
## Litera, pe celulă colorată și pe celulă de pergament.
const CULOARE_LITERA_PE_FOND := Color(0.98, 0.95, 0.88)
const CULOARE_LITERA := Color(0.2, 0.12, 0.06)

const MARIME_CELULA := 48
const MARIME_LITERA := 26
const MARIME_TASTA := 20

## Cât stă o celulă întoarsă până se întoarce următoarea. Rândul se citește de
## la stânga la dreapta, deci se și dezvăluie așa — altfel cinci culori apărute
## deodată cer o a doua privire ca să le pui în ordine.
const PAS_DEZVALUIRE := 0.14

## Cele trei rânduri de taste. QWERTY, fiindcă aia e tastatura de sub mâini:
## ordinea alfabetică ar fi mai „logică" și ar face căutarea unei litere mai
## lentă pentru oricine a scris vreodată la calculator.
const RANDURI_TASTE := [
	"QWERTYUIOP",
	"ASDFGHJKL",
	"ZXCVBNM",
]

## Lista de cuvinte, citită O DATĂ pentru tot jocul.
##
## `static`: scena se naște din nou la fiecare „încă unul", iar o variabilă de
## instanță ar fi recitit fișierul de pe disc la fiecare joc. Aceeași judecată
## ca la memoria tipurilor din `puzzle.gd`.
static var _cuvinte: Array[String] = []

## Cuvântul de ghicit, cu litere mici.
var cuvant := ""
## Ce s-a încercat până acum, în ordine.
var incercari: Array[String] = []
## Ce se scrie acum, pe rândul curent.
var rand_curent := ""
## Litera → cel mai bun `Semn` aflat despre ea. Pentru tastatură.
var stari_litere := {}
## Cât timp se întorc celulele, tastatura nu primește nimic: un rând trimis
## peste dezvăluirea celui de dinainte ar fi scris în două locuri deodată.
var in_dezvaluire := false

## Celulele, rând cu rând: `celule[rand][coloana]` → PanelContainer.
var celule: Array = []
## Litera → butonul ei de pe tastatură.
var taste := {}

@onready var grila: GridContainer = %Grila
@onready var mesaj: Label = %Mesaj
@onready var tastatura: VBoxContainer = %Tastatura


func _ready() -> void:
	grila.columns = LUNGIME
	_construieste_grila()
	_construieste_tastatura()
	mesaj.text = ""
	# Ca să poți juca scena singură cu F6: dacă nimeni n-a chemat `porneste()`
	# până la finalul cadrului ăsta, pornim noi. Același tipar ca în
	# `puzzle.gd` — și tot așteptând un cadru, fiindcă Taverna instanțiază
	# scena, o pune în arbore (deci `_ready` rulează) și cheamă `porneste()`
	# abia pe urmă.
	await get_tree().process_frame
	if not pornit:
		porneste()


# ─────────────────────────────────────────────────────────────
# PORNIREA
# ─────────────────────────────────────────────────────────────

func _porneste(cu_samanta: int) -> void:
	_incarca_cuvintele()
	if _cuvinte.is_empty():
		mesaj.text = "Lista de cuvinte lipsește (%s)." % CALE_CUVINTE
		# Eșec ORDONAT, nu o scenă care așteaptă la nesfârșit: aceeași regulă ca
		# la dicționarul gol întors de `_compune_intrebare`.
		termina(false, "Lista de cuvinte lipsește.")
		return

	cuvant = _alege_cuvantul(cu_samanta)
	incercari.clear()
	rand_curent = ""
	stari_litere.clear()
	in_dezvaluire = false
	_zugraveste_tot()
	print("Cuvantul ascuns: %s (samanta %d)" % [cuvant, cu_samanta])


## Cuvântul, pe unul din cele două drumuri din contract (vezi `joc.gd`).
func _alege_cuvantul(cu_samanta: int) -> String:
	if cu_samanta == SAMANTA_LIBERA:
		# Sacul: nu repetă nimic până nu s-au terminat toate 308.
		var tras = Sac.extrage(CHEIE_SAC, _cuvinte, "", Sac.Durata.PERMANENT)
		return String(tras) if tras != null else String(_cuvinte[0])
	# Sămânță dată = același cuvânt de fiecare dată. Pentru Decretul Zilei.
	var rng := RandomNumberGenerator.new()
	rng.seed = cu_samanta
	return _cuvinte[rng.randi() % _cuvinte.size()]


func rand_de_ajutor() -> String:
	return "Cuvinte de %d litere, scrise fără diacritice (A-Z). Enter trimite rândul." % LUNGIME


## Citește lista. Chemată de mai multe ori, nu face nimic a doua oară — exact
## contractul lui `_pregateste_datele` de la discipline.
static func _incarca_cuvintele() -> void:
	if not _cuvinte.is_empty():
		return
	var text := FileAccess.get_file_as_string(CALE_CUVINTE)
	if text == "":
		push_error("Cuvântul ascuns: nu pot citi %s" % CALE_CUVINTE)
		return
	var date = JSON.parse_string(text)
	if typeof(date) != TYPE_DICTIONARY or not date.has("cuvinte"):
		push_error("Cuvântul ascuns: %s n-are cheia cuvinte." % CALE_CUVINTE)
		return
	for c in date["cuvinte"]:
		_cuvinte.append(String(c))


# ─────────────────────────────────────────────────────────────
# REGULA JOCULUI — SINGURA PARTE CARE N-ARE NEVOIE DE ECRAN
#
# `static`, și dinadins: verificarea permanentă o bate cu sute de cazuri, fără
# să deschidă nicio fereastră și fără să construiască nicio grilă. O regulă
# care are nevoie de scenă ca să fie probată se probează mai rar.
# ─────────────────────────────────────────────────────────────

## Ce înseamnă fiecare literă din `ghicire`, față de `cuvant`.
##
## DOUĂ TRECERI, și aici stă tot ce e greu la jocul ăsta: literele DUBLE.
## Dacă cuvântul e „carte" și ghicești „aaaaa", numai UN „a" are dreptul la
## culoare, fiindcă în „carte" e un singur „a". O singură trecere („e litera în
## cuvânt?") ar fi colorat toate cinci și ar fi mințit.
##
## Deci: întâi se iau cele de pe locul lor (verzi) și se numără câte din
## fiecare literă RĂMÂN neconsumate în cuvânt; abia pe urmă se dau
## chihlimbarurile, fiecare scăzând din ce a rămas. Când nu mai rămâne, litera e
## stinsă — chiar dacă ea există în cuvânt, în altă parte deja socotită.
static func marcheaza(ghicire: String, de_ghicit: String) -> Array[int]:
	var semne: Array[int] = []
	semne.resize(de_ghicit.length())
	semne.fill(Semn.ABSENT)

	# Câte din fiecare literă a cuvântului n-au fost încă socotite.
	var rest := {}
	for i in de_ghicit.length():
		if i < ghicire.length() and ghicire[i] == de_ghicit[i]:
			semne[i] = Semn.BUN
		else:
			rest[de_ghicit[i]] = int(rest.get(de_ghicit[i], 0)) + 1

	for i in de_ghicit.length():
		if semne[i] == Semn.BUN or i >= ghicire.length():
			continue
		var litera := ghicire[i]
		if int(rest.get(litera, 0)) > 0:
			semne[i] = Semn.ALTUNDEVA
			rest[litera] = int(rest[litera]) - 1

	return semne


# ─────────────────────────────────────────────────────────────
# CE APEȘI
# ─────────────────────────────────────────────────────────────

## Tastatura adevărată. Butoanele de pe ecran sunt a doua cale către ACELEAȘI
## trei funcții de mai jos, nu o cale separată.
func _unhandled_key_input(event: InputEvent) -> void:
	if terminat_deja or in_dezvaluire:
		return
	var tasta := event as InputEventKey
	if tasta == null or not tasta.pressed or tasta.echo:
		return

	if tasta.keycode == KEY_ENTER or tasta.keycode == KEY_KP_ENTER:
		_trimite_randul()
		accept_event()
	elif tasta.keycode == KEY_BACKSPACE:
		_sterge_litera()
		accept_event()
	elif tasta.keycode >= KEY_A and tasta.keycode <= KEY_Z:
		_scrie_litera(char(tasta.keycode))
		accept_event()


func _scrie_litera(litera: String) -> void:
	if rand_curent.length() >= LUNGIME:
		return
	rand_curent += litera.to_lower()
	_zugraveste_randul(incercari.size())


func _sterge_litera() -> void:
	if rand_curent.is_empty():
		return
	rand_curent = rand_curent.substr(0, rand_curent.length() - 1)
	_zugraveste_randul(incercari.size())


func _trimite_randul() -> void:
	if rand_curent.length() < LUNGIME:
		_spune("Încă %d litere." % (LUNGIME - rand_curent.length()))
		return
	if CERE_CUVANT_DIN_LISTA and not _cuvinte.has(rand_curent):
		_spune("Nu e în lista mea.")
		return

	var ghicire := rand_curent
	var rand := incercari.size()
	incercari.append(ghicire)
	rand_curent = ""
	var semne := marcheaza(ghicire, cuvant)
	_tine_minte(ghicire, semne)
	_spune("")
	await _dezvaluie(rand, ghicire, semne)

	if ghicire == cuvant:
		Sunet.reda(Sunet.Efect.CORECT)
		termina(true, _rezumat_reusit(incercari.size()))
	elif incercari.size() >= RANDURI:
		Sunet.reda(Sunet.Efect.GRESIT)
		termina(false, "Cuvântul era %s." % cuvant.to_upper())


## Fraza de la final. Numărul de încercări e tot ce are jocul ăsta drept scor —
## și nu se adună nicăieri, fiindcă azi Taverna nu ține socoteli (vezi
## `taverna.gd`).
func _rezumat_reusit(cate: int) -> String:
	var din := "dintr-o încercare" if cate == 1 else "din %d încercări" % cate
	return "%s, %s." % [cuvant.to_upper(), din]


## Ce știe tastatura despre fiecare literă: cel mai bun semn aflat despre ea.
##
## MAXIMUL, nu ultimul: dacă „r" a fost verde la rândul 2, un „r" stins la
## rândul 4 (unde era pus în altă parte, deja socotită) n-are voie să șteargă ce
## se știa. Invers ar fi o tastatură care minte.
func _tine_minte(ghicire: String, semne: Array[int]) -> void:
	for i in ghicire.length():
		var litera := ghicire[i]
		var vechi: int = stari_litere.get(litera, -1)
		if semne[i] > vechi:
			stari_litere[litera] = semne[i]


func _spune(text: String) -> void:
	mesaj.text = text


# ─────────────────────────────────────────────────────────────
# ECRANUL
# ─────────────────────────────────────────────────────────────

func _construieste_grila() -> void:
	for copil in grila.get_children():
		copil.queue_free()
	celule.clear()
	for r in RANDURI:
		var rand_celule := []
		for c in LUNGIME:
			var celula := PanelContainer.new()
			celula.custom_minimum_size = Vector2(MARIME_CELULA, MARIME_CELULA)
			celula.add_theme_stylebox_override("panel", _stil_celula(CULOARE_CELULA, true))
			var eticheta := Label.new()
			eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			eticheta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			eticheta.add_theme_font_size_override("font_size", MARIME_LITERA)
			eticheta.add_theme_color_override("font_color", CULOARE_LITERA)
			celula.add_child(eticheta)
			grila.add_child(celula)
			rand_celule.append(celula)
		celule.append(rand_celule)


func _construieste_tastatura() -> void:
	for copil in tastatura.get_children():
		copil.queue_free()
	taste.clear()
	for i in RANDURI_TASTE.size():
		var rand := HBoxContainer.new()
		rand.alignment = BoxContainer.ALIGNMENT_CENTER
		rand.add_theme_constant_override("separation", 4)
		for litera in String(RANDURI_TASTE[i]):
			var buton := _tasta(litera, 38)
			buton.pressed.connect(_scrie_litera.bind(litera))
			rand.add_child(buton)
			taste[litera.to_lower()] = buton
		# Enter și ștergerea stau pe rândul de jos, la capetele lui, ca pe o
		# tastatură adevărată — nu pe un rând al lor, care ar fi al patrulea
		# rând de citit într-un ecran care are deja șase.
		if i == RANDURI_TASTE.size() - 1:
			var sterge := _tasta("Șterge", 64)
			sterge.pressed.connect(_sterge_litera)
			rand.add_child(sterge)
			var enter := _tasta("Enter", 64)
			enter.pressed.connect(_trimite_randul)
			rand.add_child(enter)
		tastatura.add_child(rand)


func _tasta(text: String, latime: int) -> Button:
	var buton := Button.new()
	buton.text = text
	buton.custom_minimum_size = Vector2(latime, 42)
	buton.add_theme_font_size_override("font_size", MARIME_TASTA)
	# FĂRĂ FOCUS, și ăsta nu e un detaliu de stil: un buton care poate lua
	# focusul ar fi apăsat de tasta Enter, deci „trimite rândul" ar fi scris
	# ultima literă apăsată cu mouse-ul. Butoanele de aici sunt o a doua mână,
	# nu o a doua cale de navigare.
	buton.focus_mode = Control.FOCUS_NONE
	return buton


## Chenarul unei celule sau al unei taste.
func _stil_celula(culoare: Color, cu_chenar: bool) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = culoare
	stil.corner_radius_top_left = 3
	stil.corner_radius_top_right = 3
	stil.corner_radius_bottom_left = 3
	stil.corner_radius_bottom_right = 3
	if cu_chenar:
		stil.border_color = CULOARE_CHENAR
		stil.set_border_width_all(2)
	return stil


## Dezvăluie rândul, celulă cu celulă, de la stânga la dreapta.
func _dezvaluie(rand: int, ghicire: String, semne: Array[int]) -> void:
	in_dezvaluire = true
	for c in LUNGIME:
		_coloreaza_celula(rand, c, ghicire[c], semne[c])
		await get_tree().create_timer(PAS_DEZVALUIRE).timeout
	_zugraveste_tastatura()
	in_dezvaluire = false


func _coloreaza_celula(rand: int, coloana: int, litera: String, semn: int) -> void:
	var celula: PanelContainer = celule[rand][coloana]
	var culoare := _culoare_semn(semn)
	celula.add_theme_stylebox_override("panel", _stil_celula(culoare, false))
	var eticheta: Label = celula.get_child(0)
	eticheta.text = litera.to_upper()
	eticheta.add_theme_color_override("font_color", CULOARE_LITERA_PE_FOND)


func _culoare_semn(semn: int) -> Color:
	match semn:
		Semn.BUN:
			return CULOARE_BUN
		Semn.ALTUNDEVA:
			return CULOARE_ALTUNDEVA
		_:
			return CULOARE_ABSENT


## Toată grila, de la zero. Chemată la pornire; după ea se repictează doar
## rândul în scriere, fiindcă restul nu se mai schimbă.
func _zugraveste_tot() -> void:
	for r in RANDURI:
		if r < incercari.size():
			var semne := marcheaza(incercari[r], cuvant)
			for c in LUNGIME:
				_coloreaza_celula(r, c, incercari[r][c], semne[c])
		else:
			_zugraveste_randul(r)
	_zugraveste_tastatura()


## Rândul în care se scrie acum (sau unul încă neatins).
func _zugraveste_randul(rand: int) -> void:
	if rand < 0 or rand >= RANDURI:
		return
	for c in LUNGIME:
		var celula: PanelContainer = celule[rand][c]
		celula.add_theme_stylebox_override("panel", _stil_celula(CULOARE_CELULA, true))
		var eticheta: Label = celula.get_child(0)
		eticheta.text = rand_curent[c].to_upper() if (rand == incercari.size() and c < rand_curent.length()) else ""
		eticheta.add_theme_color_override("font_color", CULOARE_LITERA)


func _zugraveste_tastatura() -> void:
	for litera in taste:
		var buton: Button = taste[litera]
		if stari_litere.has(litera):
			var culoare := _culoare_semn(stari_litere[litera])
			buton.add_theme_stylebox_override("normal", _stil_celula(culoare, false))
			buton.add_theme_stylebox_override("hover", _stil_celula(culoare.lightened(0.08), false))
			buton.add_theme_stylebox_override("pressed", _stil_celula(culoare.darkened(0.12), false))
			buton.add_theme_color_override("font_color", CULOARE_LITERA_PE_FOND)
			buton.add_theme_color_override("font_hover_color", CULOARE_LITERA_PE_FOND)
			buton.add_theme_color_override("font_pressed_color", CULOARE_LITERA_PE_FOND)
		else:
			# Fără suprascrieri: tasta se îmbracă din temă, ca orice buton.
			for nume in ["normal", "hover", "pressed"]:
				buton.remove_theme_stylebox_override(nume)

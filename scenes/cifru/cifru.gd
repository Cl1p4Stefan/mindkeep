extends Control
## LACĂTUL — un cufăr cu cifru, deschis prin deducție.
##
## Ecranul primului tip de Eveniment de pe hartă. Primește un nivel și o
## sămânță, cere generatorului un puzzle și te lasă să-l rezolvi: potrivești
## roțile, apeși „Deschide", ai trei încercări.
##
## Azi se poate rula singur cu F6, ca orice disciplină. Legătura cu nodul de
## Eveniment vine în sesiunea următoare; fișierul ăsta n-o să se schimbe atunci,
## fiindcă tot ce trebuie să știe harta despre el e deja aici:
## `porneste(nivel, samanta)` și semnalul `rezolvat(succes)`.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU MOȘTENEȘTE `Puzzle`
##
## `Puzzle` (din `scenes/puzzle/`) e baza celor trei discipline, și e o bază
## FOARTE concretă: o întrebare cu patru variante, un cronometru care curge, un
## verdict în trei timpi, un marcaj de combo. Un `extends Puzzle` ar aduce toate
## astea cu el:
##
##   • `@onready var butoane := [%Varianta1, …]` — noduri care nu există în
##     `cifru.tscn`. Scena ar crăpa la `_ready()`, înainte de orice linie de-a
##     mea. (Ar trebui deci să copiez în scena asta structura scenei de puzzle,
##     adică să car patru butoane pe care nu le folosesc.)
##   • `_compune_intrebare()` ar trebui să întoarcă patru variante. Un lacăt cu
##     patru variante nu mai e un lacăt, e o întrebare grilă despre un lacăt.
##   • cronometrul e obligatoriu acolo, fiindcă lupta e construită pe presiune
##     de timp. Lacătul e un eveniment de pe hartă: e liniștit deliberat.
##
## Moștenirea e pentru lucruri care sunt ACELAȘI LUCRU în esență. Cele trei
## discipline sunt: „o întrebare, patru variante, un cronometru". Lacătul nu e
## o a patra întrebare de felul ăla — e altă formă de interacțiune. Le leagă
## doar CONTRACTUL: `porneste()` și `rezolvat(succes)`, exact aceleași nume și
## aceeași formă. Așa, cine cheamă scena (lupta, harta, mai târziu Cetatea) nu
## trebuie să învețe nimic nou, dar scena nu cară cu ea o mașinărie străină.
##
## Regula, pe scurt: moștenește implementarea doar când chiar o refolosești;
## împrumută INTERFAȚA ori de câte ori poți.

## „Am terminat" — singurul lucru pe care îl aude lumea din afară.
## Același nume și aceeași formă ca la discipline, deliberat (vezi mai sus).
signal rezolvat(succes: bool)


# ─────────────────────────────────────────────────────────────
# REGLAJE
# ─────────────────────────────────────────────────────────────

## Câte încercări ai. Trei, și nu una, fiindcă o încercare greșită e AICI o
## sursă de informație: rândurile roșii îți arată ce indicii încalcă codul tău.
## Cu o singură încercare, feedback-ul n-ar avea când să fie folosit, iar
## lacătul ar deveni un test de „ai dedus perfect din prima sau pierzi".
const INCERCARI := 3

## Cronometrul, în secunde. **0 = fără timp**, și așa e azi.
##
## Lacătul e un nod de pe hartă, nu o luptă: presiunea de timp e unealta
## Campaniei, iar evenimentele sunt respirația dintre lupte. Rămâne totuși un
## reglaj, nu o absență, fiindcă „Lacăt cronometrat" e un modificator evident
## pentru mai târziu (un eveniment de elită, o variantă de Turn). Când va fi
## nevoie, se schimbă numărul ăsta — nu se scrie un sistem.
const SECUNDE := 0.0

## Cât stă ecranul după verdict, înainte să strige `rezolvat`. Victoria e
## scurtă (ai înțeles deja ce s-a întâmplat), eșecul e mai lung: acolo apare
## codul corect, iar el trebuie să aibă timp să fie citit — altfel pedeapsa
## rămâne pedeapsă, fără să te învețe nimic.
const PAUZA_VICTORIE := 1.3
const PAUZA_ESEC := 2.6

## Cu ce nivel pornește scena când o rulezi singură, cu F6.
const NIVEL_DE_PROBA := 2

## Mărimea unei roți, în pixeli.
const LATIME_ROATA := 76.0
const INALTIME_ROATA := 170.0


# ── PALETA ────────────────────────────────────────────────────
# Cerneală pe pergament, ca harta: Lacătul apare la un nod de Eveniment, deci
# trebuie să pară desenat pe aceeași hârtie. Cerneala propriu-zisă vine din
# `RoataCifra`, nu e copiată aici — o a doua definiție a aceleiași culori se
# desparte de prima exact în ziua în care schimbi una din ele.

## Hârtia. Placeholder: o singură culoare, fără textură, fără pete. Când
## evenimentul va sta peste harta adevărată, fundalul ăsta dispare — de-aia nu
## merită nicio imagine acum („prototip întâi, artă după").
const PERGAMENT := Color(0.90, 0.84, 0.69)

## Cerneala roșie a indiciilor încălcate. Roșu de cerneală veche, nu roșu de
## alarmă: pe hârtie caldă, un roșu saturat arată ca o etichetă lipită.
const CERNEALA_ROSIE := Color(0.55, 0.14, 0.10)

const MARIME_TITLU := 30
const MARIME_SUBTITLU := 15
const MARIME_INDICIU := 17
const MARIME_MESAJ := 16


# ─────────────────────────────────────────────────────────────
# STAREA
# ─────────────────────────────────────────────────────────────

## Puzzle-ul curent, exact cum l-a întors generatorul. Dicționar gol = n-avem
## puzzle (vezi `_fara_puzzle()`).
var puzzle := {}

var incercari_ramase := INCERCARI
var pornit := false
var terminat := false

## Roata pe care lucrează tastatura. Mouse-ul o schimbă, săgețile stânga/dreapta
## la fel.
var roata_curenta := 0

var roti: Array[RoataCifra] = []
var randuri_indicii: Array[Label] = []

## Sunt indicii colorate în roșu acum? Ca să știu dacă am ce șterge când
## jucătorul mișcă o roată. (Un `bool` în loc de o căutare prin etichete: e
## aceeași informație, dar nu trebuie recalculată la fiecare clintire de roată.)
var _are_rosu := false

var timp_ramas := 0.0

@onready var fundal: ColorRect = %Fundal
@onready var titlu: Label = %Titlu
@onready var subtitlu: Label = %Subtitlu
@onready var randul_rotilor: HBoxContainer = %Roti
@onready var lista_indicii: VBoxContainer = %Indicii
@onready var mesaj: Label = %Mesaj
@onready var eticheta_incercari: Label = %Incercari
@onready var cronometru: Label = %Cronometru
@onready var buton: Button = %Deschide


func _ready() -> void:
	set_process(false)   # cronometrul nu curge pe o scenă care n-a pornit
	_imbraca()

	buton.pressed.connect(_incearca)
	# Butonul NU primește focus. Dacă l-ar primi, Enter și săgețile ar ajunge
	# la el, nu la roți — iar navigarea cu tastatura, care e tot rostul lor,
	# s-ar bate cu sistemul de focus al interfeței. Aici tastatura are un singur
	# stăpân: `_unhandled_input()` de mai jos.
	buton.focus_mode = Control.FOCUS_NONE

	# Ca să poți testa scena singură cu F6, exact ca la discipline: dacă nimeni
	# n-a chemat `porneste()` până la finalul cadrului, pornim noi.
	await get_tree().process_frame
	if not pornit:
		# SINGURUL loc din tot Lacătul unde sămânța nu e dată din afară. E
		# deliberat: la testare vrei alt lacăt la fiecare F6. În joc, sămânța
		# vine mereu de la expediție, deci puzzle-ul e reproductibil.
		porneste(NIVEL_DE_PROBA, randi() % 1000000)


## Culorile și mărimile, puse din COD, nu din scenă.
##
## De ce: paleta e o decizie, iar deciziile trăiesc lângă motivul lor. Dacă ar
## fi în `.tscn`, ar fi opt culori scrise în opt locuri, fără un rând de
## explicație, iar schimbarea tonului hârtiei ar însemna opt clicuri prin
## Inspector. Aici e o constantă cu un comentariu, într-un fișier pe care îl
## poți citi.
func _imbraca() -> void:
	fundal.color = PERGAMENT

	_scrie_stil(titlu, MARIME_TITLU, RoataCifra.CERNEALA)
	_scrie_stil(subtitlu, MARIME_SUBTITLU, RoataCifra.CERNEALA_SLABA)
	_scrie_stil(mesaj, MARIME_MESAJ, RoataCifra.CERNEALA)
	_scrie_stil(eticheta_incercari, MARIME_SUBTITLU, RoataCifra.CERNEALA_SLABA)
	_scrie_stil(cronometru, MARIME_SUBTITLU, RoataCifra.CERNEALA_SLABA)
	_imbraca_butonul()


func _scrie_stil(eticheta: Label, marime: int, culoare: Color) -> void:
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", culoare)


## Butonul, îmbrăcat ca o plăcuță de lacăt.
##
## Un `Button` desenează întotdeauna ceva al lui: fondul gri al temei, chenarul,
## starea de hover. Pe pergament, ăla e singurul lucru de pe ecran care strigă
## „interfață" — exact motivul pentru care nodurile hărții au încetat să mai fie
## butoane (vezi `simbol_nod.gd`).
##
## Aici, spre deosebire de hartă, butonul RĂMÂNE buton: e o comandă, nu un
## obiect din lume, iar un buton știe deja tot ce trebuie despre hover, apăsare,
## dezactivare și mouse. Nu e nimic de câștigat rescriindu-le. Îi schimb doar
## hainele: aceleași patru stări, în aceeași cerneală pe hârtie ca roțile.
func _imbraca_butonul() -> void:
	buton.add_theme_stylebox_override("normal", RoataCifra.placuta(
		RoataCifra.PLACUTA, RoataCifra.CERNEALA_SLABA, RoataCifra.CONTUR))
	buton.add_theme_stylebox_override("hover", RoataCifra.placuta(
		RoataCifra.PLACUTA_ALEASA, RoataCifra.CERNEALA, RoataCifra.CONTUR_ALEASA))
	buton.add_theme_stylebox_override("pressed", RoataCifra.placuta(
		RoataCifra.PLACUTA.darkened(0.08), RoataCifra.CERNEALA, RoataCifra.CONTUR_ALEASA))
	buton.add_theme_stylebox_override("disabled", RoataCifra.placuta(
		Color(RoataCifra.PLACUTA, 0.45), Color(RoataCifra.CERNEALA_SLABA, 0.45), RoataCifra.CONTUR))

	buton.add_theme_font_size_override("font_size", MARIME_MESAJ)
	for stare in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		buton.add_theme_color_override(stare, RoataCifra.CERNEALA)
	buton.add_theme_color_override("font_disabled_color", Color(RoataCifra.CERNEALA_SLABA, 0.5))



# ─────────────────────────────────────────────────────────────
# CONTRACTUL CĂTRE LUMEA DIN AFARĂ
# ─────────────────────────────────────────────────────────────

## Pornește un lacăt. `nivel` alege dificultatea din tabelul generatorului,
## `samanta` alege puzzle-ul — aceeași sămânță, același lacăt, de fiecare dată.
func porneste(nivel: int, samanta: int) -> void:
	pornit = true
	terminat = false
	incercari_ramase = INCERCARI
	_are_rosu = false

	puzzle = GeneratorCifru.genereaza(nivel, samanta)
	if puzzle.is_empty():
		_fara_puzzle()
		return

	_construieste_rotile()
	_scrie_indiciile()
	_arata_incercarile()
	buton.disabled = false
	mesaj.text = "Potrivește roțile, apoi deschide."
	subtitlu.text = "Cifrul nu e scris nicăieri. E scris în indicii."

	if SECUNDE > 0.0:
		timp_ramas = SECUNDE
		cronometru.visible = true
		_scrie_timpul()
		set_process(true)
	else:
		cronometru.visible = false


## EȘECUL ORDONAT, copiat ca formă din `Puzzle._fara_intrebari()`: generatorul
## n-a putut produce nimic (vezi comentariul lui — practic imposibil, dar nu
## imposibil). Nu crăpăm și nu lăsăm un ecran gol: spunem ce s-a întâmplat, apoi
## dăm drumul mai departe, ca expediția să poată continua.
func _fara_puzzle() -> void:
	push_error("Cifru: generatorul n-a putut compune un lacat.")
	terminat = true
	buton.disabled = true
	titlu.text = "LACĂT RUGINIT"
	mesaj.text = "Mecanismul e blocat. Nu se poate deschide."
	await get_tree().create_timer(PAUZA_ESEC).timeout
	rezolvat.emit(false)


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ECRANULUI
# ─────────────────────────────────────────────────────────────

## Roțile. Câte una pe cifră, cu litera din generator — niciodată cu o literă
## calculată aici (vezi `RoataCifra.litera`).
func _construieste_rotile() -> void:
	for copil in randul_rotilor.get_children():
		copil.queue_free()
	roti.clear()

	for i in int(puzzle["cifre"]):
		var roata := RoataCifra.new()
		roata.custom_minimum_size = Vector2(LATIME_ROATA, INALTIME_ROATA)
		roata.litera = GeneratorCifru.litera(i)
		roata.minim = int(puzzle["minim"])
		roata.maxim = int(puzzle["maxim"])
		# Toate pornesc de la cea mai mică cifră. Nu de la una aleatoare: o
		# poziție de start trasă cu zarul ar arăta ca un indiciu („de ce tocmai
		# 7?"), iar o poziție apropiată de răspuns ar fi un ajutor nemeritat.
		roata.valoare = int(puzzle["minim"])
		roata.schimbata.connect(_pe_roata_schimbata)
		roata.aleasa.connect(_alege_roata.bind(i))
		randul_rotilor.add_child(roata)
		roti.append(roata)

	_alege_roata(0)


## Indiciile, unul pe rând, vizibile tot timpul.
##
## Nu se ascund, nu se derulează, nu apar pe rând. Un puzzle de deducție e o
## socoteală ținută în cap; orice indiciu pe care trebuie să-l cauți din nou e
## un pas de socoteală pierdut. De-aia generatorul are un maxim de indicii pe
## nivel — ca lista să încapă mereu întreagă pe ecran.
func _scrie_indiciile() -> void:
	for copil in lista_indicii.get_children():
		copil.queue_free()
	randuri_indicii.clear()

	for indiciu: Dictionary in puzzle["indicii"]:
		var rand := Label.new()
		rand.text = "•  " + GeneratorCifru.text(indiciu)
		_scrie_stil(rand, MARIME_INDICIU, RoataCifra.CERNEALA)
		lista_indicii.add_child(rand)
		randuri_indicii.append(rand)


func _arata_incercarile() -> void:
	# Cercuri pline și goale, nu o cifră: câte încercări ți-au rămas se citește
	# dintr-o privire, fără să citești un cuvânt.
	var puncte := "●".repeat(incercari_ramase) + "○".repeat(INCERCARI - incercari_ramase)
	eticheta_incercari.text = "Încercări:  %s" % puncte


# ─────────────────────────────────────────────────────────────
# COMENZILE
# ─────────────────────────────────────────────────────────────

## Ce roată ascultă tastatura. Trece de la un capăt la altul, ca și cifrele.
func _alege_roata(index: int) -> void:
	if roti.is_empty():
		return
	roata_curenta = posmod(index, roti.size())
	for i in roti.size():
		roti[i].alege(i == roata_curenta)


## Jucătorul a clintit o roată: evidențierile roșii nu mai spun adevărul despre
## ce e pe roți, deci se sting.
##
## Nu se sting imediat după încercare, ci ABIA la prima mișcare: roșul e
## răspunsul la o întrebare pe care tocmai ai pus-o („de ce nu s-a deschis?"),
## și trebuie să stea pe ecran cât te uiți la el. Dispare când începi să faci
## altceva — adică fix când a încetat să mai fie adevărat.
func _pe_roata_schimbata() -> void:
	if not _are_rosu:
		return
	for rand in randuri_indicii:
		rand.add_theme_color_override("font_color", RoataCifra.CERNEALA)
	_are_rosu = false


## Tastatura, toată într-un loc.
##
## `_unhandled_input` (nu `_input`) fiindcă e „ce n-a vrut nimeni altcineva":
## dacă mâine apare un câmp de text pe ecran, cifrele tastate în el n-o să mai
## ajungă aici, fără să scriu o linie în plus.
func _unhandled_input(event: InputEvent) -> void:
	if terminat or not pornit or roti.is_empty():
		return

	if event.is_action_pressed("ui_left"):
		_alege_roata(roata_curenta - 1)
	elif event.is_action_pressed("ui_right"):
		_alege_roata(roata_curenta + 1)
	elif event.is_action_pressed("ui_up"):
		roti[roata_curenta].muta(1)
	elif event.is_action_pressed("ui_down"):
		roti[roata_curenta].muta(-1)
	elif event.is_action_pressed("ui_accept"):
		_incearca()
	else:
		# Tastarea directă a unei cifre. E cea mai rapidă cale când știi deja
		# codul și vrei doar să-l introduci — iar după fiecare cifră sar pe
		# roata următoare, ca la orice câmp de cod.
		var cifra := _cifra_tastata(event)
		if cifra < int(puzzle["minim"]) or cifra > int(puzzle["maxim"]):
			return
		roti[roata_curenta].pune(cifra)
		_alege_roata(roata_curenta + 1)
	get_viewport().set_input_as_handled()


## Ce cifră s-a tastat, sau −1. Sunt DOUĂ rânduri de taste cu cifre pe o
## tastatură (cel de sus și cel numeric), iar jocul n-are de unde să știe pe
## care o folosești.
##
## `event as InputEventKey` întoarce `null` dacă evenimentul e altceva (o
## mișcare de mouse, de pildă). E varianta care se citește cel mai bine dintre
## cele care merg: pe o variabilă declarată `InputEvent`, GDScript nu te lasă
## să ceri `keycode` până nu ai în mână un `InputEventKey` adevărat.
func _cifra_tastata(event: InputEvent) -> int:
	var apasare := event as InputEventKey
	if apasare == null or not apasare.pressed or apasare.echo:
		return -1
	if apasare.keycode >= KEY_0 and apasare.keycode <= KEY_9:
		return apasare.keycode - KEY_0
	if apasare.keycode >= KEY_KP_0 and apasare.keycode <= KEY_KP_9:
		return apasare.keycode - KEY_KP_0
	return -1


## Un cod, ca text: „4 1 6". Cifrele despărțite prin spațiu, nu lipite: „416"
## se citește ca un număr, iar codul nu e un număr — sunt trei roți.
func _cod_scris(cod: Array) -> String:
	var bucati := PackedStringArray()
	for c in cod:
		bucati.append(str(c))
	return " ".join(bucati)


func _codul_introdus() -> Array:
	var cod := []
	for roata in roti:
		cod.append(roata.valoare)
	return cod


# ─────────────────────────────────────────────────────────────
# ÎNCERCAREA
# ─────────────────────────────────────────────────────────────

## Apeși „Deschide".
##
## CE ÎNSEAMNĂ „CORECT": codul respectă TOATE indiciile. Nu „codul e egal cu
## `puzzle["cod"]`" — deși, prin unicitatea garantată de generator și verificată
## pe 1500 de puzzle-uri, cele două sunt același lucru.
##
## Diferența contează: așa, deschiderea lacătului și rândurile roșii ies din
## ACEEAȘI socoteală. Nu poate exista starea absurdă „niciun indiciu roșu, dar
## lacătul nu se deschide" — aia e o contradicție pe care jocul ți-ar arăta-o
## pe ecran, și pe care ai crede-o vina ta.
func _incearca() -> void:
	if terminat or puzzle.is_empty():
		return

	var gresite := GeneratorCifru.indicii_incalcate(puzzle["indicii"], _codul_introdus())
	if gresite.is_empty():
		_termina(true)
		return

	incercari_ramase -= 1
	_arata_incercarile()
	_coloreaza(gresite)
	Sunet.reda(Sunet.Efect.GRESIT)

	if incercari_ramase <= 0:
		_termina(false)
		return

	# Mesajul spune CE s-a întâmplat și UNDE să te uiți. „Mai încearcă" n-ar
	# spune niciuna din două.
	mesaj.text = "Nu cedează. Roșu: indiciile pe care codul tău le încalcă."


## Colorează în roșu indiciile încălcate.
##
## Feedback-ul ăsta e tot rostul celor trei încercări: un cod greșit nu e doar
## o taxă, e o măsurătoare. Afli care dintre presupunerile tale a fost falsă,
## deci a doua încercare pleacă dintr-un loc mai bun decât prima. Fără el,
## „trei încercări" ar însemna doar trei ghiciri.
func _coloreaza(gresite: Array[int]) -> void:
	for i in randuri_indicii.size():
		var rosu := gresite.has(i)
		randuri_indicii[i].add_theme_color_override(
			"font_color", CERNEALA_ROSIE if rosu else RoataCifra.CERNEALA)
	_are_rosu = true


func _termina(succes: bool) -> void:
	terminat = true
	set_process(false)
	buton.disabled = true
	for roata in roti:
		roata.blocata = true
		roata.alege(false)

	if succes:
		Sunet.reda(Sunet.Efect.CORECT)
		mesaj.text = "Lacătul cedează."
		await get_tree().create_timer(PAUZA_VICTORIE).timeout
	else:
		# Codul corect se arată ÎNTOTDEAUNA la final. Un puzzle de deducție pe
		# care îl pierzi fără să afli răspunsul nu te învață nimic — și, mai
		# rău, te lasă cu bănuiala că poate n-avea soluție. Îl punem chiar pe
		# roți, nu într-un text: acolo te uitai oricum.
		for i in roti.size():
			roti[i].dezvaluie(int(puzzle["cod"][i]))
		mesaj.text = "Cifrul era %s." % _cod_scris(puzzle["cod"])
		await get_tree().create_timer(PAUZA_ESEC).timeout

	rezolvat.emit(succes)


# ─────────────────────────────────────────────────────────────
# CRONOMETRUL (oprit azi — vezi `SECUNDE`)
# ─────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	timp_ramas = maxf(timp_ramas - delta, 0.0)
	_scrie_timpul()
	if timp_ramas <= 0.0:
		mesaj.text = "Timpul s-a scurs."
		Sunet.reda(Sunet.Efect.GRESIT)
		incercari_ramase = 0
		_arata_incercarile()
		_termina(false)


func _scrie_timpul() -> void:
	cronometru.text = "%d s" % ceili(timp_ramas)

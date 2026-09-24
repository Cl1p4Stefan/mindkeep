extends Control
## LACĂTUL — un cufăr cu cifru, deschis prin deducție.
##
## Ecranul primului tip de Eveniment de pe hartă. Primește un nivel și o
## sămânță, cere generatorului un puzzle și te lasă să-l rezolvi: învârți cele
## patru roți ale cufărului, apeși „Deschide", ai trei încercări.
##
## Se rulează singur cu F6. Legătura cu nodul de Eveniment (și sămânța derivată
## din a expediției) vine separat; fișierul ăsta n-o să se schimbe atunci,
## fiindcă tot ce trebuie să știe harta despre el e deja aici:
## `porneste(nivel, samanta)` și semnalul `rezolvat(succes)`.
##
## ─────────────────────────────────────────────────────────────
## STRATURILE, ȘI DE CE ORDINEA LOR E TOT DESENUL
##
## De jos în sus, adică exact în ordinea din `cifru.tscn`:
##
##   Fundal    — o culoare caldă, întunecată. Nimic altceva.
##   Platou    — CAMERA. Tot ce e înăuntru se apropie și se depărtează
##               împreună, fiindcă se mută și se scalează un singur nod:
##     ├ Halou       — o pată de lumină caldă, sub cufăr
##     ├ Benzi       — cele patru role de cifre, desenate din cod
##     ├ Cufar       — IMAGINEA, cu ferestrele transparente
##     ├ Litere      — A B C D, peste placa de metal
##     └ Stralucire  — a doua copie a imaginii, adunată peste prima: fulgerul
##   Interfata — indicii, încercări, buton. NU e în Platou, deci nu se mișcă.
##
## Banda de cifre stă sub imagine, iar imaginea e opacă peste tot în afară de
## cele patru ferestre — care sunt găuri adevărate în PNG. Deci nu tai nimic și
## nu scriu nicio mască: POZA E MASCA. Explicația întreagă e în
## `banda_cifre.gd`, acolo unde se și desenează.
##
## ─────────────────────────────────────────────────────────────
## DE CE O CAMERĂ FĂCUTĂ DE MÂNĂ, ȘI NU `Camera2D`
##
## `Camera2D` ar fi fost un nod și zero linii. Dar ea nu mișcă un obiect, ci
## mișcă întreaga PÂNZĂ a viewport-ului — adică tot ce se desenează în el. Azi
## n-ar deranja (scena e singură pe ecran), dar Lacătul o să fie deschis din
## nodul de Eveniment, adică PESTE hartă. Camera ar trage atunci și pergamentul
## după ea, iar cauza ar fi de negăsit dintr-un fișier care nici nu pomenește
## harta.
##
## Un `Node2D` cu `position` și `scale` face exact același lucru, dar numai
## pentru copiii lui. Costă cinci linii și nu poate strica nimic din afară.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU MOȘTENEȘTE `Puzzle`
##
## `Puzzle` e baza celor trei discipline, și e o bază foarte concretă: o
## întrebare, patru variante, un cronometru, un verdict în trei timpi. Un
## `extends Puzzle` ar aduce `@onready var butoane := [%Varianta1, …]` — noduri
## care nu există aici, deci scena ar crăpa la `_ready()` — și ar cere un
## `_compune_intrebare()` cu patru variante. Un lacăt cu patru variante nu mai e
## un lacăt.
##
## Moștenirea e pentru lucruri care sunt același lucru în esență. Lacătul nu e a
## patra întrebare cu variante, e altă formă de interacțiune. Le leagă doar
## CONTRACTUL: `porneste()` și `rezolvat(succes)`, aceleași nume și aceeași
## formă. Moștenește implementarea doar când chiar o refolosești; împrumută
## INTERFAȚA ori de câte ori poți.

## „Am terminat" — singurul lucru pe care îl aude lumea din afară.
signal rezolvat(succes: bool)


# ─────────────────────────────────────────────────────────────
# ARTA
# ─────────────────────────────────────────────────────────────
const CUFAR_INCHIS := "res://assets/art/cifru/cufar_inchis.png"
const CUFAR_DESCHIS := "res://assets/art/cifru/cufar_deschis.png"

## Unde sunt tăiate ferestrele în imagine. Se CITEȘTE, nu se scrie în cod.
##
## Pozițiile alea sunt o proprietate a desenului, nu a jocului: dacă arta se
## redesenează mâine cu ferestrele cu 20 de pixeli mai jos, fișierul JSON vine
## odată cu ea și codul nu află niciodată. Scrise de mână aici, ar fi fost patru
## perechi de numere pe care nimeni nu le-ar mai fi recunoscut peste o lună.
const FERESTRE := "res://assets/art/cifru/ferestre.json"


# ─────────────────────────────────────────────────────────────
# REGULILE
# ─────────────────────────────────────────────────────────────

## Câte încercări ai. Trei, și nu una, fiindcă o încercare greșită e AICI o
## sursă de informație: rândurile roșii îți arată ce indicii încalcă codul tău.
const INCERCARI := 3

## Cronometrul, în secunde. **0 = fără timp**, și așa e azi. Lacătul e un nod de
## pe hartă, nu o luptă: presiunea de timp e unealta Campaniei, evenimentele
## sunt respirația dintre lupte. Rămâne un reglaj, nu o absență — „Lacăt
## cronometrat" e un modificator evident pentru mai târziu.
const SECUNDE := 0.0

## Cu ce nivel pornește scena când o rulezi singură, cu F6.
const NIVEL_DE_PROBA := 2


# ─────────────────────────────────────────────────────────────
# CAMERA
# ─────────────────────────────────────────────────────────────

## Cât de lată vrei să fie o fereastră, în pixeli de ecran, când placa domină.
## E numărul care hotărăște toată apropierea; restul (poziția cufărului, unde
## cad literele, cât de mari sunt cifrele) iese din el prin calcul.
const LATIME_FEREASTRA_TINTA := 80.0

## Unde ajunge CENTRUL celor patru ferestre, ca fracțiune din ecran, când placa
## domină. Stânga de centru, ca să rămână loc pentru indicii în dreapta.
const TINTA_APROAPE := Vector2(0.33, 0.42)

## Cât din înălțimea ecranului ocupă cufărul întreg, la pornire și la final.
const INALTIME_DEPARTE := 0.78
const TINTA_DEPARTE := Vector2(0.5, 0.5)

## Cât stă cufărul întreg pe ecran ÎNAINTE să înceapă apropierea.
##
## Fără răgazul ăsta, vederea de ansamblu există doar pe hârtie: apropierea
## pleacă din prima clipă și, cu o mișcare care începe repede, cufărul întreg se
## vede vreo două cadre. Primul lucru pe care trebuie să-l pricepi e CE e
## obiectul; abia al doilea, la ce te uiți din el.
const RAGAZ_DEPARTE := 0.5

const DURATA_APROPIERE := 0.85
const DURATA_RETRAGERE := 0.7


# ─────────────────────────────────────────────────────────────
# DESCHIDEREA — toate duratele, în ordinea în care se întâmplă
# ─────────────────────────────────────────────────────────────

## Cât stă aprinsă fiecare roată, una după alta, de la stânga la dreapta.
const APRINDERE_ROATA := 0.12

## Cât se zguduie cufărul înainte să se deschidă, și cu cât.
const TRESARIRE := 0.18
const TRESARIRE_SALT := 0.035   # fracțiune din scară

## Fulgerul. Urcă repede, coboară lent — ca o lumină care dă pe dinafară și apoi
## se resoarbe. ÎN VÂRFUL lui se schimbă imaginea (vezi `_fulgera()`).
const URCARE_FULGER := 0.16
const STINGERE_FULGER := 0.55

## Cât rămâne cufărul deschis pe ecran înainte să strige `rezolvat(true)`.
const PAUZA_DUPA_DESCHIDERE := 0.6

## La eșec: cât așteaptă între roți când se rotesc singure spre codul corect,
## și cât rămâne răspunsul pe ecran după aceea.
const DECALAJ_DEZVALUIRE := 0.22
const PAUZA_DUPA_DEZVALUIRE := 2.0


# ─────────────────────────────────────────────────────────────
# PALETA
# ─────────────────────────────────────────────────────────────

## Fundalul: aproape negru, dar cald. Cufărul e o imagine realistă, luminată
## cald; pe negru rece ar arăta decupat și lipit, pe pergament ar arăta ca o
## fotografie pusă peste un desen.
const FUNDAL := Color(0.075, 0.062, 0.055)

## Lumina din spatele cufărului. Nu e decor: fără ea, marginile întunecate ale
## lemnului se topesc în fundal și obiectul își pierde conturul.
const CULOARE_HALOU := Color(0.85, 0.58, 0.28)
const HALOU_ALFA := 0.22
const HALOU_MARIME := 1.35      # de câte ori imaginea

## Culoarea fulgerului. Alb cald, nu alb pur: lumina care iese dintr-un cufăr cu
## aur e galbenă.
const CULOARE_FULGER := Color(1.0, 0.93, 0.74)

## Textele: cerneală deschisă pe întuneric.
const TEXT := Color(0.93, 0.89, 0.80)
const TEXT_SLAB := Color(0.68, 0.62, 0.53)
const TEXT_ROSU := Color(0.88, 0.42, 0.34)

## Panoul din spatele indiciilor. Cât e camera aproape, cufărul umple ecranul,
## iar textul ar sta direct pe lemn înnodat — se citește, dar cu efort, și fix
## indiciile sunt lucrul pe care îl reciteşti de zece ori. Un strat întunecat și
## aproape transparent le dă o hârtie pe care să stea, fără să acopere cufărul.
const PANOU := Color(0.06, 0.05, 0.045, 0.78)
const PANOU_CONTUR := Color(0.32, 0.26, 0.20, 0.55)

## Literele roților, pe placa de metal: alama de pe rame.
const LITERA := Color(0.80, 0.70, 0.50)
const LITERA_ALEASA := Color(1.0, 0.88, 0.60)

## Litera roții SUDATE: patina verzuie a cifrei ei. Roata aia nu se poate alege,
## deci litera ei n-are voie să arate ca una care așteaptă să fie aleasă.
const LITERA_BLOCATA := Color(0.55, 0.58, 0.48)
const MARIME_LITERA := 48       # în pixeli DE IMAGINE

const MARIME_TITLU := 30
const MARIME_SUBTITLU := 14
const MARIME_INDICIU := 17
const MARIME_MESAJ := 17

## Cât de departe sub fereastră stă litera ei, în pixeli de imagine.
const LITERA_SUB_FEREASTRA := 26.0


# ─────────────────────────────────────────────────────────────
# STAREA
# ─────────────────────────────────────────────────────────────

var puzzle := {}
var incercari_ramase := INCERCARI
var pornit := false
var terminat := false

## Roțile pot fi atinse? Fals cât timp camera se apropie sau cufărul se deschide.
var _gata := false

var benzi: Array[BandaCifre] = []
var etichete_litere: Array[Label] = []
var randuri_indicii: Array[Label] = []

## Roata pe care lucrează tastatura, și cea prinsă acum cu mouse-ul (−1 = niciuna).
var roata_curenta := 0
var _prinsa := -1

## Ferestrele, în pixelii imaginii, citite din JSON.
var ferestre: Array[Rect2] = []
var dimensiune_imagine := Vector2(1990, 1529)

## Unde vrea camera să fie ACUM. Ținute ca variabile fiindcă tresărirea le
## strică temporar și trebuie să aibă unde se întoarce — și fiindcă la
## redimensionarea ferestrei trebuie recalculate amândouă.
var _scara_tinta := 1.0
var _pozitie_tinta := Vector2.ZERO
var _aproape := false

var _are_rosu := false
var timp_ramas := 0.0

var _textura_inchis: Texture2D = null
var _textura_deschis: Texture2D = null

@onready var fundal: ColorRect = %Fundal
@onready var platou: Node2D = %Platou
@onready var halou: Sprite2D = %Halou
@onready var parinte_benzi: Node2D = %Benzi
@onready var cufar: Sprite2D = %Cufar
@onready var parinte_litere: Node2D = %Litere
@onready var stralucire: Sprite2D = %Stralucire
@onready var interfata: Control = %Interfata
@onready var panou: Panel = %Panou
@onready var titlu: Label = %Titlu
@onready var subtitlu: Label = %Subtitlu
@onready var lista_indicii: VBoxContainer = %Indicii
@onready var eticheta_incercari: Label = %Incercari
@onready var buton: Button = %Deschide
@onready var mesaj: Label = %Mesaj


func _ready() -> void:
	set_process(false)
	_citeste_ferestrele()
	_pregateste_cufarul()
	_imbraca()

	buton.pressed.connect(_incearca)
	# Butonul NU primește focus: altfel Enter și săgețile ar ajunge la el, nu la
	# roți, iar navigarea cu tastatura s-ar bate cu sistemul de focus. Aici
	# tastatura are un singur stăpân: `_unhandled_input()`.
	buton.focus_mode = Control.FOCUS_NONE
	resized.connect(_pe_redimensionare)

	await get_tree().process_frame
	if not pornit:
		# SINGURUL loc din tot Lacătul unde sămânța nu vine din afară. E
		# deliberat: la testare vrei alt lacăt la fiecare F6. În joc, sămânța
		# vine de la expediție, deci puzzle-ul e reproductibil.
		porneste(NIVEL_DE_PROBA, randi() % 1000000)


# ─────────────────────────────────────────────────────────────
# ARTA ȘI FERESTRELE
# ─────────────────────────────────────────────────────────────

## Citește pozițiile ferestrelor din JSON-ul care vine împreună cu imaginile.
##
## Dacă fișierul lipsește sau e stricat, scena NU se oprește: își face patru
## ferestre din burtă, la mijlocul imaginii. Lacătul o să arate strâmb, dar
## mesajul din consolă spune exact ce s-a întâmplat — iar o expediție în
## desfășurare nu moare din cauza unui fișier de configurare.
func _citeste_ferestrele() -> void:
	var text := ""
	if FileAccess.file_exists(FERESTRE):
		text = FileAccess.get_file_as_string(FERESTRE)
	var date = JSON.parse_string(text) if text != "" else null

	if date is Dictionary and date.has("ferestre_px") and date.has("imagine"):
		var img: Array = date["imagine"]
		dimensiune_imagine = Vector2(float(img[0]), float(img[1]))
		for f: Array in date["ferestre_px"]:
			ferestre.append(Rect2(float(f[0]), float(f[1]), float(f[2]), float(f[3])))

	if ferestre.is_empty():
		push_error("Cifru: nu pot citi %s — ferestrele ies din burta codului." % FERESTRE)
		for i in 4:
			ferestre.append(Rect2(
				dimensiune_imagine.x * (0.31 + 0.108 * i), dimensiune_imagine.y * 0.437,
				dimensiune_imagine.x * 0.053, dimensiune_imagine.y * 0.119))


func _pregateste_cufarul() -> void:
	_textura_inchis = load(CUFAR_INCHIS) if ResourceLoader.exists(CUFAR_INCHIS) else null
	_textura_deschis = load(CUFAR_DESCHIS) if ResourceLoader.exists(CUFAR_DESCHIS) else null
	if _textura_inchis == null:
		push_error("Cifru: lipseste %s." % CUFAR_INCHIS)
	_pune_textura(_textura_inchis)

	# FULGERUL e o A DOUA copie a imaginii, desenată peste prima cu amestecare
	# prin ADUNARE: fiecare pixel al ei se ADAUGĂ la ce e dedesubt, în loc să-l
	# acopere. Efectul e că lumina aprinde exact silueta cufărului — nu un
	# dreptunghi, ci lemnul, fierul și alama, fiecare de la culoarea lui în sus.
	# O simplă pată albă peste tot ar fi arătat ca un cearșaf.
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	stralucire.material = material
	stralucire.modulate = Color(CULOARE_FULGER, 0.0)

	# HALOUL: un degrade radial, construit din cod. Cald în mijloc, transparent
	# spre margini.
	var degrade := Gradient.new()
	degrade.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	degrade.colors = PackedColorArray([
		Color(CULOARE_HALOU, 1.0), Color(CULOARE_HALOU, 0.35), Color(CULOARE_HALOU, 0.0)])
	var textura := GradientTexture2D.new()
	textura.gradient = degrade
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)
	textura.width = 256
	textura.height = 256
	halou.texture = textura
	halou.centered = true
	halou.position = dimensiune_imagine * 0.5
	halou.scale = dimensiune_imagine * HALOU_MARIME / 256.0
	halou.modulate = Color(Color.WHITE, HALOU_ALFA)


func _pune_textura(textura: Texture2D) -> void:
	cufar.texture = textura
	stralucire.texture = textura


func _imbraca() -> void:
	fundal.color = FUNDAL
	_stil(titlu, MARIME_TITLU, TEXT)
	_stil(subtitlu, MARIME_SUBTITLU, TEXT_SLAB)
	_stil(mesaj, MARIME_MESAJ, TEXT)
	_stil(eticheta_incercari, MARIME_SUBTITLU, TEXT_SLAB)

	buton.add_theme_font_size_override("font_size", MARIME_MESAJ)
	for stare in ["font_color", "font_hover_color", "font_pressed_color"]:
		buton.add_theme_color_override(stare, TEXT)
	buton.add_theme_color_override("font_disabled_color", Color(TEXT_SLAB, 0.5))
	buton.add_theme_stylebox_override("normal", _placa(Color(0.16, 0.13, 0.11), TEXT_SLAB, 2))
	buton.add_theme_stylebox_override("hover", _placa(Color(0.22, 0.18, 0.14), TEXT, 2))
	buton.add_theme_stylebox_override("pressed", _placa(Color(0.13, 0.10, 0.09), TEXT, 2))
	buton.add_theme_stylebox_override("disabled",
		_placa(Color(0.14, 0.12, 0.10, 0.5), Color(TEXT_SLAB, 0.35), 2))

	panou.add_theme_stylebox_override("panel", _placa(PANOU, PANOU_CONTUR, 1))
	# Mesajul de sub cufăr stă tot pe lemn, deci primește aceeași hârtie — doar
	# că a lui trebuie să aibă și margini, altfel textul s-ar lipi de chenar.
	var strat := _placa(PANOU, Color(PANOU_CONTUR, 0.0), 0)
	strat.content_margin_left = 16
	strat.content_margin_right = 16
	strat.content_margin_top = 8
	strat.content_margin_bottom = 8
	mesaj.add_theme_stylebox_override("normal", strat)


## Mesajul de sub cufăr. Trece TOT pe aici, fiindcă eticheta are un fond propriu
## (o fâșie întunecată care o desprinde de lemn) — iar un fond fără text e o
## bandă neagră care stă degeaba pe ecran. Textul gol înseamnă deci „ascunde-te",
## nu „scrie nimic".
func _spune(text: String) -> void:
	mesaj.text = text
	mesaj.visible = text != ""


func _stil(eticheta: Label, marime: int, culoare: Color) -> void:
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", culoare)


func _placa(fond: Color, contur: Color, grosime: int) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = fond
	stil.border_color = contur
	stil.set_border_width_all(grosime)
	stil.set_corner_radius_all(6)
	return stil


# ─────────────────────────────────────────────────────────────
# CONTRACTUL CĂTRE LUMEA DIN AFARĂ
# ─────────────────────────────────────────────────────────────

## Pornește un lacăt. `nivel` alege dificultatea din tabelul generatorului,
## `samanta` alege puzzle-ul — aceeași sămânță, același lacăt, de fiecare dată.
func porneste(nivel: int, samanta: int) -> void:
	pornit = true
	terminat = false
	_gata = false
	incercari_ramase = INCERCARI
	_are_rosu = false

	puzzle = GeneratorCifru.genereaza(nivel, samanta)
	if puzzle.is_empty():
		_fara_puzzle()
		return

	_pune_textura(_textura_inchis)
	stralucire.modulate = Color(CULOARE_FULGER, 0.0)
	halou.modulate = Color(Color.WHITE, HALOU_ALFA)

	_construieste_rotile()
	_scrie_indiciile()
	_arata_incercarile()
	buton.disabled = false
	_spune("")

	# Camera pornește DEPARTE, ca să vezi întâi ce obiect e, și abia apoi la ce
	# te uiți. Un ecran care începe direct pe patru ferestre e o interfață; unul
	# care începe pe un cufăr și se apropie e un loc.
	_aseaza_camera(false, true)
	interfata.modulate = Color(Color.WHITE, 0.0)
	await _apropie()

	if SECUNDE > 0.0:
		timp_ramas = SECUNDE
		set_process(true)


## EȘECUL ORDONAT, ca la discipline (`Puzzle._fara_intrebari()`): generatorul
## n-a putut produce nimic. Nu crăpăm și nu lăsăm un ecran gol — spunem ce s-a
## întâmplat, apoi dăm drumul mai departe, ca expediția să poată continua.
func _fara_puzzle() -> void:
	push_error("Cifru: generatorul n-a putut compune un lacat.")
	terminat = true
	buton.disabled = true
	titlu.text = "LACĂT RUGINIT"
	_spune("Mecanismul e blocat. Nu se poate deschide.")
	interfata.modulate = Color.WHITE
	_aseaza_camera(false, true)
	await get_tree().create_timer(PAUZA_DUPA_DEZVALUIRE).timeout
	rezolvat.emit(false)


# ─────────────────────────────────────────────────────────────
# CAMERA
# ─────────────────────────────────────────────────────────────

## Calculează unde și cât de mare trebuie să fie platoul, în cele două stări.
##
## Totul iese din DOUĂ cifre: cât de lată vrei o fereastră pe ecran și în ce
## punct al ecranului vrei centrul lor. Scara se află din prima, poziția din a
## doua. Nicio coordonată de cufăr nu e scrisă de mână: dacă arta se schimbă,
## calculul dă alt rezultat și nimeni nu observă.
func _aseaza_camera(aproape: bool, imediat: bool) -> void:
	_aproape = aproape
	var ecran := size
	var scara := 0.0
	var ancora := Vector2.ZERO
	var tinta := Vector2.ZERO

	if aproape:
		scara = LATIME_FEREASTRA_TINTA / maxf(_latime_medie_fereastra(), 1.0)
		ancora = _centrul_ferestrelor()
		tinta = ecran * TINTA_APROAPE
	else:
		scara = INALTIME_DEPARTE * ecran.y / maxf(dimensiune_imagine.y, 1.0)
		# Cufărul e mai lat decât înalt: pe o fereastră îngustă (sau la altă
		# proporție a ecranului) înălțimea singură l-ar lăsa să iasă pe laturi.
		scara = minf(scara, 0.92 * ecran.x / maxf(dimensiune_imagine.x, 1.0))
		ancora = dimensiune_imagine * 0.5
		tinta = ecran * TINTA_DEPARTE

	_scara_tinta = scara
	_pozitie_tinta = tinta - ancora * scara
	if imediat:
		platou.scale = Vector2(scara, scara)
		platou.position = _pozitie_tinta


func _latime_medie_fereastra() -> float:
	var suma := 0.0
	for f in ferestre:
		suma += f.size.x
	return suma / maxi(ferestre.size(), 1)


func _centrul_ferestrelor() -> Vector2:
	var tot := ferestre[0]
	for f in ferestre:
		tot = tot.merge(f)
	return tot.get_center()


## Apropierea de la cufărul întreg la placă. `await`-abilă: cine o cheamă
## așteaptă până se termină, și abia apoi dă drumul roților.
func _apropie() -> void:
	await get_tree().create_timer(RAGAZ_DEPARTE).timeout
	_aseaza_camera(true, false)
	var tween := create_tween()
	tween.set_parallel(true)
	# EASE_IN_OUT, nu EASE_OUT: pornirea trebuie să fie blândă, altfel imaginea
	# pare smucită din loc și răgazul de dinainte nu mai înseamnă nimic.
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(platou, "scale", Vector2(_scara_tinta, _scara_tinta),
		DURATA_APROPIERE)
	tween.tween_property(platou, "position", _pozitie_tinta, DURATA_APROPIERE)
	# Interfața apare ODATĂ cu apropierea, nu înainte: la început e un cufăr
	# într-o încăpere, nu un ecran cu panouri.
	tween.tween_property(interfata, "modulate", Color.WHITE, DURATA_APROPIERE)
	await tween.finished
	_gata = true


func _retrage() -> void:
	_gata = false
	_aseaza_camera(false, false)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(platou, "scale", Vector2(_scara_tinta, _scara_tinta),
		DURATA_RETRAGERE)
	tween.tween_property(platou, "position", _pozitie_tinta, DURATA_RETRAGERE)
	tween.tween_property(interfata, "modulate", Color(Color.WHITE, 0.25), DURATA_RETRAGERE)
	await tween.finished


## Redimensionarea ferestrei: recalculăm starea în care SUNTEM și o aplicăm pe
## loc. Scrise absolut, nu adunate — dacă am aduna, fiecare redimensionare ar
## lăsa cufărul cu câțiva pixeli mai încolo, pe vecie.
func _pe_redimensionare() -> void:
	_aseaza_camera(_aproape, true)
	_aseaza_literele()


# ─────────────────────────────────────────────────────────────
# ROȚILE ȘI LITERELE
# ─────────────────────────────────────────────────────────────

func _construieste_rotile() -> void:
	for copil in parinte_benzi.get_children():
		copil.queue_free()
	for copil in parinte_litere.get_children():
		copil.queue_free()
	benzi.clear()
	etichete_litere.clear()

	var blocata := int(puzzle.get("blocata", -1))
	for i in mini(int(puzzle["cifre"]), ferestre.size()):
		var banda := BandaCifre.new()
		banda.position = ferestre[i].position
		banda.fereastra = ferestre[i].size
		banda.minim = int(puzzle["minim"])
		banda.maxim = int(puzzle["maxim"])
		banda.blocata = i == blocata
		banda.clic.connect(_clic_roata)
		parinte_benzi.add_child(banda)
		benzi.append(banda)
		# Roata sudată pornește pe cifra ei; restul, pe cea mai mică.
		banda.pune_direct(int(puzzle["cod"][i]) if i == blocata else int(puzzle["minim"]))

		var litera := Label.new()
		litera.text = GeneratorCifru.litera(i)
		litera.add_theme_font_size_override("font_size", MARIME_LITERA)
		litera.add_theme_color_override("font_color", LITERA)
		parinte_litere.add_child(litera)
		etichete_litere.append(litera)

	_aseaza_literele()
	_alege_roata(_prima_libera())


## Literele stau sub ferestrele lor, în coordonatele IMAGINII — deci se apropie
## și se depărtează odată cu cufărul, ca și cum ar fi gravate în placă.
func _aseaza_literele() -> void:
	for i in etichete_litere.size():
		var eticheta := etichete_litere[i]
		eticheta.size = Vector2(ferestre[i].size.x, MARIME_LITERA * 1.4)
		eticheta.position = Vector2(
			ferestre[i].position.x,
			ferestre[i].position.y + ferestre[i].size.y + LITERA_SUB_FEREASTRA)
		eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


## Prima roată care se poate învârti. Roata sudată nu se selectează niciodată:
## ar fi un popas gol în drumul săgeților.
func _prima_libera() -> int:
	for i in benzi.size():
		if not benzi[i].blocata:
			return i
	return 0


func _alege_roata(index: int) -> void:
	if benzi.is_empty():
		return
	var n := benzi.size()
	var i := posmod(index, n)
	# Sărim peste roata blocată, în direcția în care mergeam.
	var pas := 1 if index >= roata_curenta else -1
	var ocol := 0
	while benzi[i].blocata and ocol < n:
		i = posmod(i + pas, n)
		ocol += 1
	roata_curenta = i
	for k in etichete_litere.size():
		var culoare := LITERA
		if benzi[k].blocata:
			culoare = LITERA_BLOCATA
		elif k == roata_curenta:
			culoare = LITERA_ALEASA
		etichete_litere[k].add_theme_color_override("font_color", culoare)


func _clic_roata() -> void:
	Sunet.reda(Sunet.Efect.CLIC_ROATA)
	# Cifrele s-au schimbat, deci evidențierile roșii nu mai spun adevărul
	# despre ce e pe roți.
	_sterge_rosul()


func _sterge_rosul() -> void:
	if not _are_rosu:
		return
	for rand in randuri_indicii:
		rand.add_theme_color_override("font_color", TEXT)
	_are_rosu = false


# ─────────────────────────────────────────────────────────────
# INDICIILE
# ─────────────────────────────────────────────────────────────

func _scrie_indiciile() -> void:
	for copil in lista_indicii.get_children():
		copil.queue_free()
	randuri_indicii.clear()

	for indiciu: Dictionary in puzzle["indicii"]:
		var rand := Label.new()
		rand.text = "•  " + GeneratorCifru.text(indiciu)
		rand.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_stil(rand, MARIME_INDICIU, TEXT)
		lista_indicii.add_child(rand)
		randuri_indicii.append(rand)


func _arata_incercarile() -> void:
	var puncte := "●".repeat(incercari_ramase) + "○".repeat(INCERCARI - incercari_ramase)
	eticheta_incercari.text = "Încercări:  %s" % puncte


# ─────────────────────────────────────────────────────────────
# MOUSE-UL
# ─────────────────────────────────────────────────────────────

## Ce roată e sub punctul ăsta de pe ecran, sau −1.
##
## Traducerea din pixeli de ecran în pixeli de imagine o face `to_local()` al
## platoului: el știe unde e camera și cât de aproape. De-aia nu există zone
## invizibile puse peste ferestre — ar fi trebuit reașezate la fiecare mișcare
## de cameră și la fiecare redimensionare.
func _roata_sub(punct: Vector2) -> int:
	if not _gata or benzi.is_empty():
		return -1
	var local := platou.to_local(punct)
	for i in benzi.size():
		# Zona apucabilă e puțin mai mare decât gaura: degetul nu nimerește
		# niciodată exact, iar o fereastră de 80 px pe ecran e o țintă mică.
		if ferestre[i].grow(ferestre[i].size.x * 0.25).has_point(local):
			return i
	return -1


func _gui_input(event: InputEvent) -> void:
	if terminat:
		return

	var apasare := event as InputEventMouseButton
	if apasare != null and apasare.pressed:
		var peste := _roata_sub(apasare.position)
		match apasare.button_index:
			MOUSE_BUTTON_LEFT:
				if peste >= 0 and not benzi[peste].blocata:
					_prinsa = peste
					_alege_roata(peste)
					benzi[peste].prinde()
					accept_event()
			MOUSE_BUTTON_WHEEL_UP:
				if peste >= 0:
					_alege_roata(peste)
					benzi[peste].pas(1)
					accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				if peste >= 0:
					_alege_roata(peste)
					benzi[peste].pas(-1)
					accept_event()
	elif apasare != null and not apasare.pressed and apasare.button_index == MOUSE_BUTTON_LEFT:
		if _prinsa >= 0:
			benzi[_prinsa].elibereaza()
			_prinsa = -1
			accept_event()

	var miscare := event as InputEventMouseMotion
	if miscare != null and _prinsa >= 0:
		# 1:1 CU MOUSE-UL: pixelii de ecran se împart la scara camerei ca să
		# devină pixeli de imagine, iar ăia se împart la înălțimea unui pas ca
		# să devină cifre. Așa banda urmărește degetul la fel, oricât de aproape
		# e camera — altfel tragerea ar fi de trei ori mai „grea" când placa
		# domină ecranul.
		var pas_px: float = ferestre[_prinsa].size.y * BandaCifre.PAS_CIFRA
		var cifre: float = miscare.relative.y / maxf(platou.scale.y, 0.001) / pas_px
		var delta := maxf(get_process_delta_time(), 0.001)
		benzi[_prinsa].trage(cifre, cifre / delta)
		accept_event()


# ─────────────────────────────────────────────────────────────
# TASTATURA
# ─────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if terminat or not _gata or benzi.is_empty():
		return

	if event.is_action_pressed("ui_left"):
		_alege_roata(roata_curenta - 1)
	elif event.is_action_pressed("ui_right"):
		_alege_roata(roata_curenta + 1)
	elif event.is_action_pressed("ui_up"):
		benzi[roata_curenta].pas(1)
	elif event.is_action_pressed("ui_down"):
		benzi[roata_curenta].pas(-1)
	elif event.is_action_pressed("ui_accept"):
		_incearca()
	else:
		var cifra := _cifra_tastata(event)
		if cifra < int(puzzle["minim"]) or cifra > int(puzzle["maxim"]):
			return
		benzi[roata_curenta].spre_cifra(cifra)
		_alege_roata(roata_curenta + 1)
	get_viewport().set_input_as_handled()


## Ce cifră s-a tastat, sau −1. Sunt DOUĂ rânduri de taste cu cifre pe o
## tastatură (cel de sus și cel numeric), iar jocul n-are de unde să știe pe
## care o folosești.
func _cifra_tastata(event: InputEvent) -> int:
	var apasare := event as InputEventKey
	if apasare == null or not apasare.pressed or apasare.echo:
		return -1
	if apasare.keycode >= KEY_0 and apasare.keycode <= KEY_9:
		return apasare.keycode - KEY_0
	if apasare.keycode >= KEY_KP_0 and apasare.keycode <= KEY_KP_9:
		return apasare.keycode - KEY_KP_0
	return -1


func _codul_introdus() -> Array:
	var cod := []
	for banda in benzi:
		cod.append(banda.cifra())
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
## lacătul nu se deschide" — aia e o contradicție pe care jocul ți-ar arăta-o pe
## ecran și pe care ai crede-o vina ta.
func _incearca() -> void:
	if terminat or not _gata or puzzle.is_empty():
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

	_spune("Nu cedează. Roșu: indiciile pe care codul tău le încalcă.")


## Colorează în roșu indiciile încălcate.
##
## Feedback-ul ăsta e tot rostul celor trei încercări: un cod greșit nu e o taxă,
## e o măsurătoare. Afli care dintre presupunerile tale a fost falsă, deci a doua
## încercare pleacă dintr-un loc mai bun decât prima.
func _coloreaza(gresite: Array[int]) -> void:
	for i in randuri_indicii.size():
		randuri_indicii[i].add_theme_color_override(
			"font_color", TEXT_ROSU if gresite.has(i) else TEXT)
	_are_rosu = true


func _termina(succes: bool) -> void:
	terminat = true
	set_process(false)
	_gata = false
	_prinsa = -1
	buton.disabled = true

	if succes:
		await _deschide_cufarul()
	else:
		await _arata_codul()
	rezolvat.emit(succes)


# ─────────────────────────────────────────────────────────────
# DESCHIDEREA
# ─────────────────────────────────────────────────────────────

## Cele cinci mișcări ale victoriei, în ordine. Fiecare așteaptă după cea
## dinainte — de-aia funcția e plină de `await` și se citește de sus în jos ca o
## listă de instrucțiuni, nu ca un ceas de temporizatoare.
func _deschide_cufarul() -> void:
	Sunet.reda(Sunet.Efect.CORECT)
	_spune("Lacătul cedează.")

	# 1. Roțile se aprind pe rând, de la stânga la dreapta. E confirmarea
	# mecanismului: fiecare cifră e recunoscută, una câte una, ca la un lacăt
	# adevărat care își lasă zăvoarele să cadă.
	for banda in benzi:
		var t := create_tween()
		t.tween_property(banda, "stralucire", 1.0, APRINDERE_ROATA)
		Sunet.reda(Sunet.Efect.CLIC_ROATA)
		await get_tree().create_timer(APRINDERE_ROATA).timeout

	# 2. Camera se retrage: ce urmează se întâmplă cufărului întreg, deci
	# trebuie să-l vezi întreg.
	await _retrage()

	# 3. Tresărirea. Zăvorul a cedat, capacul se mișcă în balamale.
	await _tresare()

	# 4-5. Fulgerul, cu schimbarea imaginii ascunsă în vârful lui.
	await _fulgera()

	await get_tree().create_timer(PAUZA_DUPA_DESCHIDERE).timeout


## O smucitură scurtă: platoul crește câteva procente și se întoarce.
##
## Scrisă ABSOLUT (pornim de la `_scara_tinta`, ne întoarcem la ea), nu adunată
## la scara curentă. Dacă efectul ar fi întrerupt la mijloc — o redimensionare,
## un `queue_free` — o adunare ar lăsa cufărul umflat pe veci.
func _tresare() -> void:
	var mare := _scara_tinta * (1.0 + TRESARIRE_SALT)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(platou, "scale", Vector2(mare, mare), TRESARIRE * 0.4)
	tween.tween_property(platou, "scale", Vector2(_scara_tinta, _scara_tinta),
		TRESARIRE * 0.6)
	await tween.finished


## FULGERUL, și de ce ascunde el înlocuirea imaginii.
##
## Ochiul nu vede „o imagine", vede DIFERENȚE. Când ecranul e acoperit de o
## lumină care aproape îneacă desenul, nu mai are ce compara între cadrul de
## dinainte și cel de după — iar când lumina scade, primește un cufăr deschis și
## presupune că s-a deschis SUB lumină. Trucul nu e lumina, e clipa aleasă:
## schimbarea se face fix în vârf, nu la urcare și nu la coborâre.
##
## Funcționează doar fiindcă cele două poze sunt încadrate IDENTIC, la pixel:
## placa lacătului, ferestrele și colțarele cad în același loc în amândouă. Dacă
## lacătul ar sări cu cinci pixeli, l-ai prinde chiar și prin fulger — mișcarea
## se vede prin lumină, culoarea nu.
##
## Fulgerul e din două lumini, nu una: silueta cufărului (`Stralucire`, adunată
## peste imagine) și o pată largă în jur (`Halou`). A doua e cea care acoperă
## conturul: capacul deschis are ALTĂ siluetă decât cel închis, iar fără o
## lumină care se revarsă dincolo de margini s-ar vedea cum sare marginea.
func _fulgera() -> void:
	var urcare := create_tween()
	urcare.set_parallel(true)
	urcare.tween_property(stralucire, "modulate:a", 1.0, URCARE_FULGER)
	urcare.tween_property(halou, "modulate:a", 1.0, URCARE_FULGER)
	await urcare.finished

	# VÂRFUL. Aici, și numai aici.
	_pune_textura(_textura_deschis)
	Sunet.reda(Sunet.Efect.CAPAC)

	var stingere := create_tween()
	stingere.set_parallel(true)
	stingere.tween_property(stralucire, "modulate:a", 0.0, STINGERE_FULGER)
	stingere.tween_property(halou, "modulate:a", HALOU_ALFA, STINGERE_FULGER)
	await stingere.finished


# ─────────────────────────────────────────────────────────────
# EȘECUL
# ─────────────────────────────────────────────────────────────

## După trei greșeli, roțile se duc singure pe codul corect.
##
## Un puzzle de deducție pierdut fără să afli răspunsul nu te învață nimic — și,
## mai rău, te lasă cu bănuiala că poate n-avea soluție. Cufărul rămâne închis:
## ai pierdut. Dar pleci știind cifrul, nu doar că ai greșit.
##
## Fără zguduit și fără sunet dur, deliberat: e un eveniment de pe hartă, nu o
## pedeapsă. Roțile care se rotesc singure spun destul.
func _arata_codul() -> void:
	_spune("Cifrul era %s." % _cod_scris(puzzle["cod"]))
	var blocata := int(puzzle.get("blocata", -1))
	for i in benzi.size():
		if i == blocata:
			continue
		# O tură întreagă înainte de aterizare: altfel o roată care e deja pe
		# cifra bună n-ar face nimic, iar dezvăluirea ar arăta ca o defecțiune.
		benzi[i].spre_cifra(int(puzzle["cod"][i]), 1)
		await get_tree().create_timer(DECALAJ_DEZVALUIRE).timeout
	await get_tree().create_timer(PAUZA_DUPA_DEZVALUIRE).timeout


## Un cod, ca text: „4 1 6 2". Cifrele despărțite prin spațiu, nu lipite:
## „4162" se citește ca un număr, iar codul nu e un număr — sunt patru roți.
func _cod_scris(cod: Array) -> String:
	var bucati := PackedStringArray()
	for c in cod:
		bucati.append(str(c))
	return " ".join(bucati)


# ─────────────────────────────────────────────────────────────
# CRONOMETRUL (oprit azi — vezi `SECUNDE`)
# ─────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	timp_ramas = maxf(timp_ramas - delta, 0.0)
	if timp_ramas <= 0.0:
		set_process(false)
		_spune("Timpul s-a scurs.")
		incercari_ramase = 0
		_arata_incercarile()
		_termina(false)

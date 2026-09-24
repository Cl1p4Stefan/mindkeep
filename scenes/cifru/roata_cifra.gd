class_name RoataCifra
extends Control
## O ROATĂ DE CIFRE — o piesă a Lacătului, desenată din cod.
##
## Nu știe ce e un cifru, un indiciu sau o încercare. Știe trei lucruri: ce
## literă poartă, între ce cifre se poate învârti și pe care stă acum. Când o
## clintești, strigă. Atât.
##
## Contractul subțire ăsta e același principiu ca între luptă și discipline:
## dacă roata ar ști ce e un puzzle, n-ai mai putea s-o folosești pentru
## altceva (o combinație într-un magazin, un cadran în Cetate) fără s-o rescrii.
##
## ─────────────────────────────────────────────────────────────
## DE CE E DESENATĂ, ȘI NU O IMAGINE SAU UN `SpinBox`
##
## `SpinBox` există în Godot și ar fi fost gratis. Dar aduce cu el tot ce are
## un câmp de formular: chenar de temă, cursor de text, săgeți mici cât un
## chibrit. Pe pergament ar arăta exact ca o interfață lipită deasupra desenului
## — chiar problema pentru care nodurile hărții au încetat să fie butoane
## (vezi comentariul din `simbol_nod.gd`).
##
## Iar o imagine ar fi fost artă de făcut înainte ca mecanica să fie validată,
## adică exact ce interzice principiul „prototip întâi, artă după". Un `Control`
## care se desenează singur costă zero fișiere și se schimbă dintr-un număr.

## Roata s-a mutat pe altă cifră. Scena ascultă ca să șteargă evidențierile
## rămase de la încercarea trecută — vezi `cifru.gd`.
signal schimbata

## Cineva a apăsat pe roată (nu pe săgețile ei). Scena o face „roata curentă",
## ca tastatura să știe pe cine lucrează.
signal aleasa


# ── MĂSURI ────────────────────────────────────────────────────
# Toate în pixeli, pe mărimea din `cifru.tscn`. Sunt reglaje de desen, nu
# calcule: dacă roata ți se pare prea îngustă, ăsta e singurul loc de umblat.

## Cât din înălțime ia litera de deasupra plăcuței.
const INALTIME_LITERA := 22.0

## Cât de departe de centru stau cifrele „vecine" (cea dinainte și cea de după).
## Ele nu sunt decor: fără ele, roata arată ca o casetă cu un număr în ea, și
## nimic nu spune că se poate învârti.
const DISTANTA_VECINI := 40.0

## Înălțimea zonei sensibile de la capete: apeși acolo, roata se mută.
## E și zona în care se desenează săgețile, deci ce vezi e chiar ce apeși.
const ZONA_SAGEATA := 30.0

const LATIME_SAGEATA := 16.0
const INALTIME_SAGEATA := 9.0

## GROSIMEA CONTURULUI, în pixeli: subțire când roata doar stă, gros când e cea
## pe care lucrează tastatura. Diferența trebuie să se vadă dintr-o privire, fără
## să te uiți după o culoare.
const CONTUR := 2
const CONTUR_ALEASA := 3

## Cât de rotunjite sunt colțurile plăcuțelor. Aceeași valoare pentru roți și
## pentru butonul „Deschide" — de-aia e o constantă, nu un număr scris de două ori.
const ROTUNJIRE := 8


const MARIME_CIFRA := 40
const MARIME_VECIN := 20
const MARIME_LITERA := 15


# ── CULORI ────────────────────────────────────────────────────
# Paleta de cerneală pe pergament a hărții, fiindcă Lacătul apare pe hartă, la
# nodul de Eveniment. Aceleași valori ca `CERNEALA` din `simbol_nod.gd`: nu
# negru, ci maro foarte închis — negrul pur pe hârtie caldă arată lipit
# deasupra, maro-ul închis arată absorbit în fibră.

const CERNEALA := Color(0.14, 0.09, 0.05)
const CERNEALA_SLABA := Color(0.42, 0.31, 0.20)
const PLACUTA := Color(0.84, 0.76, 0.60)
const PLACUTA_ALEASA := Color(0.91, 0.85, 0.69)

## Cifra corectă, arătată la final. Verde de cerneală, nu verde de neon: pe
## pergament, o culoare saturată sare din desen ca o etichetă.
const CULOARE_DEZVALUIRE := Color(0.20, 0.38, 0.18)


# ── STAREA ────────────────────────────────────────────────────

## Litera de pe roată — „A", „B"… Vine din `GeneratorCifru.litera()`, ca să fie
## SIGUR aceeași literă care apare în indicii. Dacă scena ar scrie litera
## singură, ar exista două locuri care numără pozițiile, iar în ziua în care
## unul începe de la 1 și celălalt de la 0, indiciile ar vorbi despre altă roată.
var litera := "?"

var minim := 0
var maxim := 9
var valoare := 0

## E roata pe care lucrează tastatura acum?
var aleasa_acum := false

## După ce lacătul s-a terminat, roțile nu se mai ating.
var blocata := false

## Se desenează cifra ca „dezvăluire" (codul corect, după trei greșeli)?
var dezvaluita := false

var _stil: StyleBoxFlat = null
var _stil_ales: StyleBoxFlat = null


## O plăcuță de lacăt, ca `StyleBoxFlat`.
##
## Stă aici, și e `static`, fiindcă o folosesc DOUĂ fișiere: roțile (mai jos) și
## butonul „Deschide" din `cifru.gd`. Dacă fiecare și-ar construi-o pe a lui, ar
## fi două definiții ale aceluiași obiect desenat — iar în ziua în care rotunjești
## colțurile roților, butonul ar rămâne, tăcut, cu colțurile vechi.
static func placuta(fond: Color, contur: Color, grosime: int) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = fond
	stil.border_color = contur
	stil.set_border_width_all(grosime)
	stil.set_corner_radius_all(ROTUNJIRE)
	return stil


func _ready() -> void:
	# Cele două înfățișări ale plăcuței, construite o dată. Două obiecte, nu
	# unul modificat la fiecare desen: un `StyleBox` e o resursă, iar desenul
	# ține o referință la ea — o resursă schimbată sub desenul deja făcut e
	# genul de bug care se vede doar la a doua roată.
	_stil = placuta(PLACUTA, CERNEALA_SLABA, CONTUR)
	_stil_ales = placuta(PLACUTA_ALEASA, CERNEALA, CONTUR_ALEASA)

	mouse_filter = Control.MOUSE_FILTER_STOP


## Pune roata pe o cifră. `strig` = false pentru așezarea inițială și pentru
## dezvăluirea codului: alea nu sunt gesturi ale jucătorului, iar semnalul e
## despre gesturi.
func pune(noua: int, strig := true) -> void:
	noua = clampi(noua, minim, maxim)
	if noua == valoare:
		queue_redraw()
		return
	valoare = noua
	queue_redraw()
	if strig:
		schimbata.emit()


## Mută roata cu un pas, cu trecere de la un capăt la celălalt.
##
## Rotirea circulară nu e un moft: de la 9 la 0 sunt nouă apăsări dacă roata se
## oprește la capete, și una singură dacă se învârte. Pe un lacăt pe care îl
## reglezi de zeci de ori până găsești codul, diferența se simte imediat.
func muta(pas: int) -> void:
	if blocata:
		return
	var interval := maxim - minim + 1
	# `posmod` e modulo care întoarce mereu un număr pozitiv. Cu `%` obișnuit,
	# un pas în jos de pe prima cifră ar da un rest negativ și ai ieși din roată.
	pune(minim + posmod(valoare - minim + pas, interval))


## Arată cifra ca fiind cea corectă (la finalul pierdut). Nu strigă `schimbata`:
## nu e o mutare a jucătorului, e răspunsul.
func dezvaluie(corecta: int) -> void:
	dezvaluita = true
	blocata = true
	pune(corecta, false)


func alege(da: bool) -> void:
	aleasa_acum = da
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if blocata:
		return

	# Rotița mouse-ului: gestul cel mai firesc pentru un obiect care se învârte.
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				aleasa.emit()
				muta(1)
				accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				aleasa.emit()
				muta(-1)
				accept_event()
			MOUSE_BUTTON_LEFT:
				aleasa.emit()
				# Unde ai apăsat contează: capetele sunt săgeți, mijlocul e doar
				# „asta e roata mea". Zona apăsabilă e exact zona desenată, deci
				# n-ai cum să apeși „lângă" săgeată și să nu se întâmple nimic.
				var y: float = event.position.y
				if y <= _sus_placuta() + ZONA_SAGEATA:
					muta(1)
				elif y >= size.y - ZONA_SAGEATA:
					muta(-1)
				accept_event()


func _sus_placuta() -> float:
	return INALTIME_LITERA


func _draw() -> void:
	var font := get_theme_default_font()
	var placuta := Rect2(0, _sus_placuta(), size.x, size.y - _sus_placuta())

	# Litera, deasupra plăcuței. Aceeași literă care apare în indicii — ăsta e
	# tot rostul ei: fără litere, un indiciu despre „A" n-ar avea unde să arate.
	_scrie(font, Rect2(0, 0, size.x, INALTIME_LITERA), litera, MARIME_LITERA,
		CERNEALA if aleasa_acum else CERNEALA_SLABA)

	draw_style_box(_stil_ales if aleasa_acum else _stil, placuta)

	var mijloc := placuta.position.y + placuta.size.y * 0.5
	var interval := maxim - minim + 1

	# Vecinele, șterse: ele sunt tot indicatorul că obiectul se învârte.
	var inainte := minim + posmod(valoare - minim - 1, interval)
	var dupa := minim + posmod(valoare - minim + 1, interval)
	_scrie(font, Rect2(0, mijloc - DISTANTA_VECINI - 12, size.x, 24),
		str(dupa), MARIME_VECIN, Color(CERNEALA_SLABA, 0.45))
	_scrie(font, Rect2(0, mijloc + DISTANTA_VECINI - 12, size.x, 24),
		str(inainte), MARIME_VECIN, Color(CERNEALA_SLABA, 0.45))

	# Cifra curentă.
	_scrie(font, Rect2(0, mijloc - 26, size.x, 52), str(valoare), MARIME_CIFRA,
		CULOARE_DEZVALUIRE if dezvaluita else CERNEALA)

	if not blocata:
		var culoare := CERNEALA if aleasa_acum else CERNEALA_SLABA
		_sageata(placuta.position.y + 11.0, true, culoare)
		_sageata(size.y - 11.0, false, culoare)


## Un triunghi plin. Trei puncte, nicio imagine: e singura formă de care are
## nevoie o săgeată, iar `draw_colored_polygon` o desenează dintr-o linie.
func _sageata(y: float, in_sus: bool, culoare: Color) -> void:
	var x := size.x * 0.5
	var h := INALTIME_SAGEATA * (1.0 if in_sus else -1.0)
	var puncte := PackedVector2Array([
		Vector2(x, y - h * 0.5),
		Vector2(x - LATIME_SAGEATA * 0.5, y + h * 0.5),
		Vector2(x + LATIME_SAGEATA * 0.5, y + h * 0.5),
	])
	draw_colored_polygon(puncte, culoare)


## Scrie un text CENTRAT într-o casetă.
##
## `draw_string` primește poziția LINIEI DE BAZĂ (talpa literelor), nu colțul
## casetei — de-aia nu e destul să dai centrul cutiei. Înălțimea fontului minus
## coada literelor („descent", cât coboară un „p" sub linie) mută talpa exact
## cât trebuie ca textul să pară centrat pe verticală.
func _scrie(font: Font, caseta: Rect2, text: String, marime: int, culoare: Color) -> void:
	if font == null:
		return
	var inaltime := font.get_height(marime)
	var baza := caseta.position.y + (caseta.size.y + inaltime) * 0.5 - font.get_descent(marime)
	draw_string(font, Vector2(caseta.position.x, baza), text,
		HORIZONTAL_ALIGNMENT_CENTER, caseta.size.x, marime, culoare)

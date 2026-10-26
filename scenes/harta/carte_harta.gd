extends Control
## CARTEA DIN COLȚ — „Cronicile", pictată în `campaign_map.jpg`, făcută apăsabilă.
##
## Cartea nu e un nod de scenă (vezi `CARTE_SUS` în `harta.gd`): e un desen în
## fundal. Ca s-o pot mișca, `tools/decupeaza_cartea.py` o taie de acolo într-un
## PNG cu transparență, `carte_cronici.png`. Nodul ăsta se întinde peste tot
## ecranul, exact ca `Pergament`, și desenează decupajul EXACT peste cartea
## pictată — dar numai cât stă mouse-ul pe ea. În repaus nu desenează nimic:
## fundalul arată deja cartea.
##
## ─── DE CE SE „RIDICĂ”, NU ALUNECĂ ─────────────────────────────
## Sub decupaj, cartea pictată rămâne pe loc. O carte mutată pur și simplu
## spre stânga ar dezveli-o pe cea pictată, și s-ar vedea două muchii. Așa că
## decupajul CREȘTE dintr-un punct de pe marginea din dreapta a ecranului: iese
## spre stânga (și puțin în sus și în jos) și acoperă mereu originalul, fiindcă
## o formă care conține punctul din care crește se conține pe ea însăși, mărită.
## Umbra de dedesubt e cea care o face să pară ridicată de pe masă.
##
## ─── ZONA DE CLIC ──────────────────────────────────────────────
## `_has_point()` e întrebarea pe care Godot o pune fiecărui Control ca să afle
## „e mouse-ul pe tine?". Răspunsul vine din TRANSPARENȚA decupajului: conturul
## există o singură dată, în scriptul Python, nu copiat și aici.

signal apasata

## Importat CU mipmaps, ca fundalul: e desenat la ~40% din mărimea lui, iar fără
## ele ieșea mai grăunțos decât cartea pictată, și la coborâre se vedea saltul.
const DECUPAJ := preload("res://assets/art/carte_cronici.png")
## Același decupaj, lățit și estompat: se desenează SUB carte și acoperă orice
## bucată din cartea pictată pe care conturul n-a prins-o. Fără el, colțul de
## sus al cotorului ieșea pe sub cartea ridicată, dublat. Vezi „MARGINEA” în
## `tools/decupeaza_cartea.py`. Are aceeași mărime ca DECUPAJ, deci aceeași cutie.
const MARGINE := preload("res://assets/art/carte_cronici_margine.png")
## Silueta neagră și estompată. Umbra făcută din DECUPAJ colorat în negru avea
## muchii la fel de tăioase ca a cărții: colțul ei de sus părea o a doua carte.
const UMBRA := preload("res://assets/art/carte_cronici_umbra.png")

## Fundalul din care a fost tăiat decupajul. Decupajul merge până la marginea
## din dreapta și cea de jos a fundalului, deci locul lui se CALCULEAZĂ din cele
## două mărimi — vezi `_cutia_cartii()`.
@export var fundal: Texture2D

## Cât crește cartea ridicată de tot (0,07 = cu 7%). Pe o fereastră de 1152 px,
## cotorul iese cam 10 px spre stânga.
const MARIRE := 0.07
## Umbra: cât se vede de sub carte, spre stânga-jos, și cât de neagră e.
const DEPLASARE_UMBRA := Vector2(-7.0, 9.0)
const OPACITATE_UMBRA := 0.55
const DURATA_RIDICARE := 0.16
const DURATA_COBORARE := 0.22

## Pixelii decupajului, ca să-i pot întreba transparența la fiecare mișcare de
## mouse. Citiți o dată, nu la fiecare întrebare.
var _pixeli: Image

## 0 = cartea stă pe masă, 1 = ridicată de tot. Orice schimbare redesenează.
var _ridicare := 0.0:
	set(valoare):
		_ridicare = valoare
		queue_redraw()

var _animatie: Tween

## Cât e deschis panoul „Cronicile”, cartea rămâne ridicată oriunde ar fi
## mouse-ul: tu ai deschis-o, ea stă „în mână”. Vezi `tine_ridicata()`.
var _tinuta := false


func _ready() -> void:
	_pixeli = DECUPAJ.get_image()
	mouse_entered.connect(_pe_survolare.bind(true))
	mouse_exited.connect(_pe_survolare.bind(false))
	resized.connect(queue_redraw)


## Unde stă decupajul pe ecran, ca să cadă exact peste cartea pictată.
func _cutia_cartii() -> Rect2:
	var marime_fundal := fundal.get_size() if fundal else DECUPAJ.get_size()
	var parte := DECUPAJ.get_size() / marime_fundal
	return Rect2((Vector2.ONE - parte) * size, parte * size)


func _has_point(punct: Vector2) -> bool:
	var cutie := _cutia_cartii()
	if not cutie.has_point(punct):
		return false
	var pixel := Vector2i((punct - cutie.position) / cutie.size * Vector2(_pixeli.get_size()))
	pixel = pixel.clamp(Vector2i.ZERO, _pixeli.get_size() - Vector2i.ONE)
	return _pixeli.get_pixelv(pixel).a > 0.5


func _gui_input(eveniment: InputEvent) -> void:
	if eveniment is InputEventMouseButton and eveniment.pressed \
			and eveniment.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		apasata.emit()


## Harta o cheamă cu `true` când deschide panoul și cu `false` când îl închide.
## La deschidere, voalul panoului acoperă cartea, deci Godot spune „mouse-ul a
## plecat” — iar cartea ar coborî tocmai când te uiți în ea. Cât e ținută,
## survolarea nu mai contează; la închidere coboară, afară de cazul în care
## mouse-ul a rămas chiar pe ea.
func tine_ridicata(da: bool) -> void:
	_tinuta = da
	if da:
		_porneste_animatia(1.0, DURATA_RIDICARE)
	else:
		var pe_carte := _has_point(get_local_mouse_position())
		_porneste_animatia(1.0 if pe_carte else 0.0,
			DURATA_RIDICARE if pe_carte else DURATA_COBORARE)


func _pe_survolare(da: bool) -> void:
	if _tinuta:
		return
	_porneste_animatia(1.0 if da else 0.0, DURATA_RIDICARE if da else DURATA_COBORARE)


func _porneste_animatia(tinta: float, durata: float) -> void:
	if _animatie:
		_animatie.kill()
	_animatie = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animatie.tween_property(self, "_ridicare", tinta, durata)


## Ascunsă cu cartea ridicată (ieși de pe hartă), revine pe masă pe loc și
## nu mai e ținută: altfel ar reapărea ridicată, cu mouse-ul în altă parte.
func _notification(ce: int) -> void:
	if ce == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		if _animatie:
			_animatie.kill()
		_tinuta = false
		_ridicare = 0.0


func _draw() -> void:
	if _ridicare <= 0.0:
		return
	var cutie := _cutia_cartii()
	# Punctul din care crește: pe marginea din dreapta, la mijlocul cărții.
	# Mărirea în jurul lui `p` e x' = p + s·(x − p) = s·x + p·(1 − s), adică
	# exact `draw_set_transform(p·(1 − s), 0, s)`.
	var p := Vector2(size.x, cutie.get_center().y)
	var s := 1.0 + MARIRE * _ridicare
	var mutare := p * (1.0 - s)

	# Ordinea: marginea, umbra peste ea (ca să cadă pe „hârtia” din margine),
	# apoi cartea, cu conturul strâns.
	draw_set_transform(mutare, 0.0, Vector2(s, s))
	draw_texture_rect(MARGINE, cutie, false)
	draw_set_transform(mutare + DEPLASARE_UMBRA * _ridicare, 0.0, Vector2(s, s))
	draw_texture_rect(UMBRA, cutie, false, Color(1, 1, 1, OPACITATE_UMBRA * _ridicare))
	draw_set_transform(mutare, 0.0, Vector2(s, s))
	draw_texture_rect(DECUPAJ, cutie, false)
	draw_set_transform(Vector2.ZERO)

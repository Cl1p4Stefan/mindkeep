class_name Silueta
extends Control
## Baza comună a siluetelor desenate în cod (regele, Pagina Goală).
##
## De ce o clasă de bază: ambele siluete au nevoie de exact același lucru —
## o casetă cu proporții corecte, o „respirație" și un mod de a scrie forme
## în fracțiuni. Codul ăsta ar fi fost identic în două fișiere. Aici e scris
## o dată, iar fiecare siluetă completează doar ce o face să fie ea însăși:
## funcția `_deseneaza_silueta()`.
##
## De ce `_draw()` și nu `Polygon2D`: `Polygon2D` e un `Node2D`, iar arena
## noastră e făcută din containere (`HBoxContainer`, `VBoxContainer`), care
## poziționează doar noduri de tip `Control`. Un `Node2D` le-ar ignora și ar
## trebui să-l plimbi cu mâna. Un `Control` cu `_draw()` stă în layout exact
## unde stătea `ColorRect`-ul — desenează aceleași poligoane, dar în cutia
## pe care i-o dă containerul.
##
## Sunt PLACEHOLDER-e. Când vine artă adevărată, înlocuiești nodul cu un
## `TextureRect` și ștergi fișierul — nimic altceva din luptă nu depinde de ele.

## Proporția siluetei: lățime împărțită la înălțime.
## Cutia primită de la container e lată și scundă (~500x355). Dacă am desena
## direct pe toată suprafața ei, silueta ar ieși turtită. De asta desenăm
## într-o casetă centrată, cu proporția asta, oricât de lată e cutia.
@export var proportie := 0.75

## RESPIRAȚIA: cât durează un ciclu complet (inspir + expir), în secunde.
@export var durata_respiratie := 2.6

## Cât de mult se umflă silueta: 0.02 = 2%. Trebuie să fie abia perceptibil —
## dacă îl observi conștient, e prea mult.
@export var amplitudine := 0.02

## Decalajul de pornire, în secunde. Cele două siluete primesc valori diferite
## din scenă, ca să nu respire sincron — altfel se vede că e același efect.
@export var decalaj := 0.0

## Înclinarea siluetei, în grade. Se aplică în jurul aceluiași pivot ca
## respirația. O filă perfect dreaptă arată desenată cu rigla; 3-5 grade sunt
## de ajuns cât să pară așezată, nu construită.
@export var inclinare := 0.0:
	set(valoare):
		inclinare = valoare
		queue_redraw()

## Punctul fix al respirației, ca fracțiune din înălțimea casetei.
## 1.0 = talpa: silueta se umflă în sus, dar rămâne „așezată".
## 0.5 = centrul: silueta plutește, se umflă în toate direcțiile.
@export var ancora_y := 1.0

# Starea animației. Prefixul „_" e o convenție: „nu umbla la asta din afară".
var _timp := 0.0
var _scara := 1.0

# Calculate o dată per desenare, în `_draw()`, și folosite de funcțiile ajutătoare.
var _caseta := Rect2()
var _pivot := Vector2.ZERO


func _ready() -> void:
	# `_draw()` nu e chemată automat la redimensionare — semnalul ne anunță.
	resized.connect(queue_redraw)
	_timp = decalaj


func _process(delta: float) -> void:
	_timp += delta
	# `sin()` merge de la -1 la 1 și se întoarce, la nesfârșit: exact forma unei
	# respirații. `TAU` e un cerc complet în radiani, deci `timp * TAU / durata`
	# înseamnă „un ciclu complet la fiecare `durata` secunde".
	_scara = 1.0 + sin(_timp * TAU / durata_respiratie) * amplitudine
	queue_redraw()


## Godot cheamă `_draw()`. Noi pregătim aici caseta și pivotul, apoi lăsăm
## fiecare siluetă să-și deseneze forma. Așa nimeni nu poate uita pregătirea.
func _draw() -> void:
	pregateste_caseta()
	_deseneaza_silueta()


## Caseta și pivotul, recalculate din mărimea de ACUM.
##
## Aritmetica asta stătea în `_draw()`. A ieșit afară fiindcă i-a apărut un al
## doilea client: harta are nevoie să știe unde cade cerneala unui simbol
## ÎNAINTE ca simbolul să fi apucat să se deseneze măcar o dată (vezi
## `SimbolNod.are_cerneala()` și tăierea drumurilor din `harta.gd`).
##
## Aceeași formulă chemată din două locuri e mai bună decât aceeași formulă
## SCRISĂ în două locuri: în varianta a doua, ziua în care schimbi proporția
## siluetei o schimbi doar într-una dintre copii și afli abia din desen.
func pregateste_caseta() -> void:
	var inaltime := size.y
	var latime := inaltime * proportie
	if latime > size.x:            # cutia e mai îngustă decât proporția cerută
		latime = size.x
		inaltime = latime / proportie
	_caseta = Rect2((size.x - latime) * 0.5, (size.y - inaltime) * 0.5, latime, inaltime)
	_pivot = _caseta.position + Vector2(_caseta.size.x * 0.5, _caseta.size.y * ancora_y)


## Suprascrisă de fiecare siluetă. Goală aici, intenționat.
func _deseneaza_silueta() -> void:
	pass


## Traduce un punct din fracțiuni (0..1 în casetă) în pixeli pe ecran,
## aplicând și respirația. Toate formele trec pe aici, deci toate se
## scalează la fel, automat.
func _punct(fractie: Vector2) -> Vector2:
	var brut := _caseta.position + fractie * _caseta.size
	# Lucrăm cu poziția FAȚĂ DE PIVOT: așa, și umflarea, și rotirea se fac în
	# jurul aceluiași punct fix, iar silueta nu „fuge" de la locul ei.
	var fata_de_pivot := (brut - _pivot) * _scara
	if not is_zero_approx(inclinare):
		fata_de_pivot = fata_de_pivot.rotated(deg_to_rad(inclinare))
	return _pivot + fata_de_pivot


## Desenează un poligon scris în fracțiuni. Asta face ca formele de mai jos
## să fie doar liste de numere între 0 și 1 — ușor de citit și de ajustat.
func _poligon(fractii: PackedVector2Array, culoare: Color) -> void:
	var puncte := PackedVector2Array()
	for fractie in fractii:
		puncte.append(_punct(fractie))
	draw_colored_polygon(puncte, culoare)


## Un cerc, cu raza dată ca fracțiune din ÎNĂLȚIMEA casetei (ca să rămână
## rotund, nu oval, indiferent de proporție).
func _cerc(centru: Vector2, raza: float, culoare: Color) -> void:
	draw_circle(_punct(centru), raza * _caseta.size.y * _scara, culoare)


# ─────────────────────────────────────────────────────────────
# CORECȚIA DE PROPORȚIE
# Caseta e mai înaltă decât lată, deci 0.1 pe orizontală înseamnă mai puțini
# pixeli decât 0.1 pe verticală. Cele două funcții traduc între „fracțiuni" și
# „cât se vede pe ecran" — fără ele, o margine zdrențuită iese mărunt pe
# laturile verticale și mare pe cele orizontale, iar cercurile ies ovale.
# ─────────────────────────────────────────────────────────────

## Un vector de direcție, ajustat ca să arate pe ecran cât zice că are.
func _corectat(vector: Vector2) -> Vector2:
	return Vector2(vector.x / proportie, vector.y)


## Lungimea unui vector așa cum se vede pe ecran, nu în fracțiuni.
func _lungime_reala(vector: Vector2) -> float:
	return Vector2(vector.x * proportie, vector.y).length()

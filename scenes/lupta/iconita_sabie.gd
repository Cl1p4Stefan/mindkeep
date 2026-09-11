extends Control
## Iconiță de sabie — DESENATĂ, nu scrisă.
##
## De ce nu un caracter: fontul implicit al Godot (Open Sans SemiBold) nu
## conține ⚔ (U+2694). Am verificat-o cu `Font.has_char()` înainte s-o folosim,
## iar un caracter care lipsește din font se afișează ca pătrat gol. Din toate
## simbolurile de tip armă, în Open Sans există doar „†" — care e o cruce, nu
## o sabie.
##
## `_draw()` e cea mai ieftină soluție: fără fișier de imagine, fără import,
## fără să depindem de un font. Formele se scalează singure la dimensiunea
## nodului, deci aceeași iconiță merge la 18px lângă inamic și la 64px într-un
## card, fără să se pixeleze. Când vine artă adevărată, înlocuiești tot nodul
## cu un TextureRect.

## Culoarea sabiei. Un `setter` (blocul `set:`) rulează la fiecare atribuire,
## deci nu poți uita să ceri redesenarea: se face singură.
@export var culoare := Color(0.96, 0.6, 0.5):
	set(valoare):
		culoare = valoare
		queue_redraw()


func _ready() -> void:
	# `_draw()` NU e chemată automat când nodul își schimbă mărimea.
	# Semnalul `resized` ne anunță, iar `queue_redraw` programează redesenarea.
	resized.connect(queue_redraw)


## Godot cheamă `_draw()` când nodul trebuie redesenat. Coordonatele sunt
## relative la colțul stânga-sus al nodului, iar toate valorile de mai jos
## sunt FRACȚIUNI din lățime/înălțime — de asta desenul se scalează singur.
func _draw() -> void:
	var l := size.x   # lățime
	var h := size.y   # înălțime

	# LAMA: un poligon cu vârful în sus. Cinci puncte, în sens orar:
	# vârf, umărul drept, baza dreaptă, baza stângă, umărul stâng.
	draw_colored_polygon(PackedVector2Array([
		Vector2(l * 0.50, h * 0.02),
		Vector2(l * 0.64, h * 0.20),
		Vector2(l * 0.64, h * 0.56),
		Vector2(l * 0.36, h * 0.56),
		Vector2(l * 0.36, h * 0.20),
	]), culoare)

	# GARDA transversală — bara lată care face silueta recognoscibilă.
	draw_rect(Rect2(l * 0.08, h * 0.56, l * 0.84, h * 0.11), culoare)

	# MÂNERUL
	draw_rect(Rect2(l * 0.42, h * 0.67, l * 0.16, h * 0.21), culoare)

	# MĂCIULIA de la capăt
	draw_rect(Rect2(l * 0.33, h * 0.88, l * 0.34, h * 0.11), culoare)

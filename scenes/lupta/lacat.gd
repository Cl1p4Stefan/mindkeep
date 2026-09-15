class_name Lacat
extends Control
## LACĂTUL de pe un Obelisc blocat. Un corp mic, un mâner deasupra, o gaură
## de cheie. Atât — la 14 pixeli, orice detaliu în plus devine o pată.
##
## DE CE DESENAT: același motiv ca la piesele de șah (vezi `glifa_sah.gd`).
## Fontul implicit nu are 🔒, iar `has_char(0x1F512)` întoarce `false` — s-ar fi
## văzut un pătrat gol fix pe butonul despre care jucătorul are cea mai mare
## nevoie să înțeleagă ce s-a întâmplat.
##
## DE CE UN LACĂT ȘI NU CUVÂNTUL „(blocat)": cuvântul ocupa un rând întreg sub
## numele disciplinei și muta tot ce era pe buton de fiecare dată când se
## aprindea sau se stingea. Un semn mic într-un colț nu mișcă nimic — și se
## citește dintr-o privire, ceea ce un rând de text nu face.

## Culoarea lacătului. O pune `obelisc.gd`: culoarea disciplinei, stinsă.
@export var culoare := Color(0.75, 0.75, 0.8):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Culoarea găurii de cheie — adică a fondului de sub lacăt.
@export var culoare_gol := Color(0.11, 0.11, 0.15):
	set(valoare):
		culoare_gol = valoare
		queue_redraw()

# Proporțiile, ca fracțiuni din cutia primită. Aceeași idee ca la siluete:
# numere între 0 și 1, deci lacătul iese la fel la orice mărime.
const CORP_SUS := 0.44         # unde începe corpul (sub mâner)
const CORP_JOS := 0.95
const CORP_LATIME := 0.72
const MANER_RAZA := 0.22       # raza mânerului, din lățimea cutiei
const MANER_GROSIME := 0.10
const GAURA_RAZA := 0.085


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var latime := size.x
	var inaltime := size.y
	var centru_x := latime * 0.5

	# MÂNERUL: o jumătate de cerc deschisă în jos. `draw_arc` desenează de la
	# un unghi la altul, în radiani; PI → TAU (adică 180° → 360°) e exact
	# jumătatea de sus a cercului.
	var centru_maner := Vector2(centru_x, inaltime * CORP_SUS)
	draw_arc(
		centru_maner,
		latime * MANER_RAZA,
		PI, TAU,
		12,
		culoare,
		latime * MANER_GROSIME,
		true   # antialiased: la mărimea asta, o linie zimțată se vede imediat
	)

	# CORPUL: un dreptunghi plin. La 14 pixeli, colțurile rotunjite ar fi o
	# muncă pe care n-ar vedea-o nimeni.
	var corp := Rect2(
		centru_x - latime * CORP_LATIME * 0.5,
		inaltime * CORP_SUS,
		latime * CORP_LATIME,
		inaltime * (CORP_JOS - CORP_SUS)
	)
	draw_rect(corp, culoare)

	# GAURA DE CHEIE: un punct în culoarea fondului. E ce transformă
	# dreptunghiul într-un lacăt — fără el, e doar o cutie cu o toartă.
	draw_circle(
		Vector2(centru_x, corp.position.y + corp.size.y * 0.45),
		latime * GAURA_RAZA,
		culoare_gol
	)

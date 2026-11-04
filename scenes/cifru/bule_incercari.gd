extends Control
## Cele trei bule ale încercărilor — DESENATE, nu scrise.
##
## De ce nu caractere: rândul era `"●".repeat(ramase) + "○".repeat(pierdute)`,
## iar `●` (U+25CF) și `○` (U+25CB) nu există în NICIUNUL din cele trei fonturi
## ale jocului — nici în cel implicit al Godot, nici în Cinzel, nici în
## Alegreya. Măsurat cu `Font.has_char()`, nu presupus.
##
## Pe Windows se vedeau totuși bulele, fiindcă `FontFile.allow_system_fallback`
## e aprins implicit: când fontul n-are un semn, Godot îl cere SISTEMULUI de
## operare și îl găsește în Segoe UI Symbol. Build-ul web n-are de unde să-l
## ceară — browserul nu-i dă lui Godot fișiere de font din care să caute — deci
## acolo rămâneau trei pătrate goale. Greșeala era în joc de la bun început,
## doar că fallback-ul o acoperea tăcut pe singura platformă pe care rulez.
##
## Aceeași judecată, și al patrulea caz, după `iconita_sabie.gd`, `lacat.gd` și
## `glifa_sah.gd`: un semn de care depinde ecranul nu se lasă pe seama unui
## font. `_draw()` nu are nevoie de niciun fișier, iese identic pe orice
## platformă, și dă pe deasupra ceva ce un caracter nu putea da — deosebirea
## dintre „rămasă" și „pierdută" e acum de CULOARE și de UMPLERE, nu de formă.

## Câte bule sunt cu totul, și câte sunt încă pline. Amândouă cer redesenarea
## din `set:`, deci nu se poate uita: se face singură la atribuire.
@export var total := 3:
	set(valoare):
		total = valoare
		update_minimum_size()
		queue_redraw()

@export var ramase := 3:
	set(valoare):
		ramase = valoare
		queue_redraw()

## Bula întreagă și cea cheltuită. Le pune `cifru.gd` din paleta lui, ca la
## toate celelalte culori ale scenei — nodul nu știe nimic despre Lacăt.
@export var culoare_plina := Color(0.80, 0.70, 0.50):
	set(valoare):
		culoare_plina = valoare
		queue_redraw()

@export var culoare_goala := Color(0.68, 0.62, 0.53):
	set(valoare):
		culoare_goala = valoare
		queue_redraw()

## Raza unei bule și distanța dintre centrele a două vecine, în pixeli.
##
## Raza e potrivită cu `MARIME_SUBTITLU` (14 px) al etichetei de lângă: o bulă
## cam cât un „o" al rândului, ca să citești un singur rând, nu un text și o
## podoabă alături de el.
const RAZA := 5.0
const DISTANTA := 16.0

## Cât de gros e conturul bulei goale. Sub 1,5 px conturul se subțiază atât
## încât, la o bulă mică, se citește ca o pată ștearsă în loc de un inel.
const GROSIME_CONTUR := 1.5


func _ready() -> void:
	# Bulele stau pe linia de bază a textului de lângă, nu lipite de marginea
	# de sus a rândului: fără asta, într-un `HBoxContainer` mai înalt decât ele
	# ar pluti în colț.
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# `_draw()` NU e chemată singură la redimensionare; semnalul ne anunță.
	resized.connect(queue_redraw)


## Cât loc CERE rândul de bule. Containerul întreabă, nodul răspunde — de-aia
## numărul de bule poate crește (un modificator „Lacăt cu 5 încercări") fără
## să se atingă nimic în scenă.
func _get_minimum_size() -> Vector2:
	if total <= 0:
		return Vector2.ZERO
	return Vector2(DISTANTA * (total - 1) + RAZA * 2.0, RAZA * 2.0)


func _draw() -> void:
	var y := size.y * 0.5
	for i in range(total):
		var centru := Vector2(RAZA + DISTANTA * i, y)
		if i < ramase:
			# Încercare neatinsă: bulă plină.
			draw_circle(centru, RAZA, culoare_plina, true, -1.0, true)
		else:
			# Încercare cheltuită: rămâne doar inelul. Locul ei se vede în
			# continuare — altfel bulele s-ar deplasa la fiecare greșeală, iar
			# „câte mai am" ar trebui numărat în loc de privit.
			draw_circle(centru, RAZA - GROSIME_CONTUR * 0.5, culoare_goala,
				false, GROSIME_CONTUR, true)

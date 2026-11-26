extends Control
## Semnul de ștergere de pe tasta din dreapta-jos a Cuvântului Ascuns, în
## portret: o săgeată-etichetă spre stânga, cu un X înăuntru, ca pe tastatura
## telefonului.
##
## DESENAT, NU SCRIS: „⌫" (U+232B) nu e în Cinzel, nu e în Alegreya și nu e în
## fontul implicit. Pe Windows ar fi fost împrumutat tăcut de la sistem, pe web
## ar fi ieșit un pătrat gol — exact greșeala de la bulele Lacătului și de la
## „✕"-ul Tavernei (vezi `inchide_x.gd`). Regula din CLAUDE.md: un semn care nu
## e literă sau cifră se desenează.
##
## Nu primește clicuri (`MOUSE_FILTER_IGNORE`, pus de masă): stă peste buton
## doar ca desen, iar atingerea ajunge la buton.

## Mărimea semnului, în pixeli de pânză. Fixă, nu după buton: butonul e cât
## tasta PLUS golurile ei (vezi „TASTATURA DE TELEFON" din `cuvantul.gd`).
const LATIME := 26.0
const INALTIME := 18.0
const GROSIME := 2.0

var culoare := Color.WHITE


func _draw() -> void:
	var c := size / 2.0
	var st := c.x - LATIME / 2.0
	var dr := c.x + LATIME / 2.0
	var sus := c.y - INALTIME / 2.0
	var jos := c.y + INALTIME / 2.0
	# Vârful săgeții e la stânga; corpul e un dreptunghi.
	var varf := st + INALTIME * 0.5
	var contur := PackedVector2Array([
		Vector2(st, c.y), Vector2(varf, sus), Vector2(dr, sus),
		Vector2(dr, jos), Vector2(varf, jos), Vector2(st, c.y),
	])
	draw_polyline(contur, culoare, GROSIME, true)
	# X-ul, în mijlocul dreptunghiului.
	var xc := Vector2((varf + dr) / 2.0, c.y)
	var r := INALTIME * 0.2
	draw_line(xc + Vector2(-r, -r), xc + Vector2(r, r), culoare, GROSIME, true)
	draw_line(xc + Vector2(r, -r), xc + Vector2(-r, r), culoare, GROSIME, true)

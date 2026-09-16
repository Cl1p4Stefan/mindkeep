extends Control
## PÂNZA — desenează DRUMURILE dintre nodurile hărții, și doar atât.
##
## Nodurile sunt butoane obișnuite, copii ai acestui Control. Ce nu se poate
## face cu butoane sunt LINIILE dintre ele: un container nu desenează legături,
## iar o legătură nu e un nod de interfață — e o relație între două.
##
## ─────────────────────────────────────────────────────────────
## DE CE UN FIȘIER SEPARAT PENTRU DOUĂSPREZECE LINII DE COD
##
## Fiindcă `_draw()` e o funcție specială: Godot o cheamă când nodul trebuie
## redesenat, iar ea are voie să deseneze DOAR atunci. Dacă ar sta în
## `harta.gd`, harta ar trebui să fie ea însăși un Control desenabil, iar
## desenul s-ar amesteca cu logica de expediție.
##
## Așa, `harta.gd` spune „astea sunt liniile" și uită de ele; pânza nu știe ce
## e un nod de expediție, un PV sau o luptă. Același contract subțire ca între
## luptă și disciplinele de puzzle.

## Liniile de desenat. Fiecare: { "de_la": Vector2, "la": Vector2,
## "culoare": Color, "grosime": float }.
var muchii: Array[Dictionary] = []


## Primește liniile și cere o redesenare.
##
## `queue_redraw()` NU desenează pe loc — pune nodul la coadă pentru cadrul
## următor. De-aia e ieftin s-o chemi de mai multe ori într-o funcție: zece
## apeluri înseamnă tot un singur desen.
func arata(muchii_noi: Array[Dictionary]) -> void:
	muchii = muchii_noi
	queue_redraw()


func _draw() -> void:
	for muchie in muchii:
		# `antialiased` (ultimul argument) netezește marginile liniei. Pe o
		# diagonală, fără el, se văd treptele pixelilor — iar o hartă e numai
		# diagonale.
		draw_line(
			muchie["de_la"], muchie["la"],
			muchie["culoare"], float(muchie["grosime"]), true
		)

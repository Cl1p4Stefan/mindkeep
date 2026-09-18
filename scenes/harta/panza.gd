extends Control
## PÂNZA — desenează DRUMURILE dintre nodurile hărții, și doar atât.
##
## Nodurile sunt `Control`-uri desenate (`simbol_nod.gd`), copii ai acestui
## Control. Ce nu se poate face cu ele sunt LEGĂTURILE dintre ele: un container
## nu desenează legături, iar o legătură nu e un nod de interfață — e o relație
## între două.
##
## ─────────────────────────────────────────────────────────────
## DE CE UN FIȘIER SEPARAT PENTRU O MÂNĂ DE LINII DE COD
##
## Fiindcă `_draw()` e o funcție specială: Godot o cheamă când nodul trebuie
## redesenat, iar ea are voie să deseneze DOAR atunci. Dacă ar sta în
## `harta.gd`, harta ar trebui să fie ea însăși un Control desenabil, iar
## desenul s-ar amesteca cu logica de expediție.
##
## Așa, `harta.gd` spune „astea sunt drumurile" și uită de ele; pânza nu știe
## ce e un nod de expediție, un PV sau o luptă.
##
## ─────────────────────────────────────────────────────────────
## DE CE PUNCTATE ȘI CURBE, ȘI NU SEGMENTE DREPTE
##
## O linie dreaptă și subțire între două dreptunghiuri arată a diagramă: spune
## „nodul A e legat de nodul B". Un șir de liniuțe care se îndoaie spune
## „de-aici se MERGE acolo" — e un drum pe un teren, cu tot cu ocolișul lui.
## Aceeași informație, altă poveste, și costă douăzeci de linii de cod.
##
## Curbura nu se inventează la desenare: vine gata calculată din `harta.gd`,
## din sămânța expediției. Dacă ar fi aleasă aici la întâmplare, drumurile
## s-ar unduli altfel la fiecare redesenare — adică la fiecare redimensionare
## de fereastră și la fiecare întoarcere din luptă.

## Lungimea unei liniuțe și a pauzei dintre ele, în pixeli.
const LUNGIME_LINIUTA := 9.0
const PAUZA_LINIUTA := 7.5

## Cât de des măsurăm curba. Mai mic = liniuțe mai exacte, mai multe apeluri de
## desen. 2 pixeli e sub pragul la care s-ar vedea diferența.
const PAS_ESANTION := 2.0

## Cât lăsăm liber la capete, în jurul simbolului. Fără asta, liniuțele ar
## intra pe sub craniu și pe sub halo-ul lui, iar drumul ar părea că trece
## PRIN nod, nu că ajunge la el.
const RAZA_NOD := 40.0

## Drumurile de desenat. Fiecare: { "de_la": Vector2, "la": Vector2,
## "culoare": Color, "grosime": float, "curbura": float }.
var muchii: Array[Dictionary] = []


## Primește drumurile și cere o redesenare.
##
## `queue_redraw()` NU desenează pe loc — pune nodul la coadă pentru cadrul
## următor. De-aia e ieftin s-o chemi de mai multe ori într-o funcție: zece
## apeluri înseamnă tot un singur desen.
func arata(muchii_noi: Array[Dictionary]) -> void:
	muchii = muchii_noi
	queue_redraw()


func _draw() -> void:
	for muchie in muchii:
		_deseneaza_drum(muchie)


## Un drum punctat, îndoit.
##
## Curba e o BÉZIER PĂTRATICĂ: două capete și un punct de control care trage de
## mijloc. Punctul de control e mijlocul segmentului împins PERPENDICULAR pe
## el — așa, indiferent cum stau cele două noduri față de altul, îndoitura iese
## mereu „în lateral", niciodată răsucită.
func _deseneaza_drum(muchie: Dictionary) -> void:
	var de_la: Vector2 = muchie["de_la"]
	var la: Vector2 = muchie["la"]
	var culoare: Color = muchie["culoare"]
	var grosime := float(muchie["grosime"])

	var directie := la - de_la
	var perpendiculara := Vector2(-directie.y, directie.x)
	var control := (de_la + la) * 0.5 + perpendiculara * float(muchie.get("curbura", 0.0))

	# Lungimea curbei, aproximată prin cele două laturi ale triunghiului de
	# control. E puțin mai mare decât lungimea adevărată, ceea ce înseamnă
	# doar câteva eșantioane în plus — exact greșeala pe care ți-o permiți.
	var lungime := de_la.distance_to(control) + control.distance_to(la)
	var esantioane := maxi(16, int(lungime / PAS_ESANTION))
	var pas := LUNGIME_LINIUTA + PAUZA_LINIUTA

	var parcurs := 0.0
	var anterior := de_la
	for i in range(1, esantioane + 1):
		var punct := _bezier(de_la, control, la, float(i) / esantioane)
		parcurs += anterior.distance_to(punct)

		# Liniuță sau pauză? Poziția pe drum, împărțită la pas, decide singură —
		# fără să numărăm liniuțe și fără să știm câte încap.
		var e_liniuta := fmod(parcurs, pas) < LUNGIME_LINIUTA
		var langa_capat := (
			punct.distance_to(de_la) < RAZA_NOD or punct.distance_to(la) < RAZA_NOD
		)
		if e_liniuta and not langa_capat:
			draw_line(anterior, punct, culoare, grosime, true)

		anterior = punct


## Un punct de pe curba Bézier pătratică, la fracțiunea `t` (0 = start, 1 = capăt).
##
## Toată formula e „interpolare de interpolări": mergi `t` de la A spre C,
## mergi `t` de la C spre B, apoi mergi `t` între rezultatele astea două.
## Trei `lerp`-uri, nicio formulă de memorat.
func _bezier(a: Vector2, c: Vector2, b: Vector2, t: float) -> Vector2:
	return a.lerp(c, t).lerp(c.lerp(b, t), t)

extends Control
## O ICONIȚĂ MICĂ DE RESURSĂ — inimă, monedă sau fragment.
##
## Întâi încearcă imaginea din `assets/art/resurse/` (pictată, realistă, în
## stilul figurinei și al nodurilor). Dacă fișierul lipsește, desenează forma
## din poligoane — exact modelul din `simbol_nod.gd`: un fișier șters sau prost
## exportat întoarce antetul la desen, nu-l rupe.
##
## Imaginile au venit ca JPG-uri pe fundal închis, la 2000 px. Au fost decupate
## (fundalul scos de pe contur, ca să nu facă găuri în obiect) și micșorate la
## 256×256, PNG cu alfa: pe ecran stau la ~26 px, iar 256 ajunge și pentru un
## ecran de densitate dublă, fără să umfle exportul web.
##
## Se folosește în antetul hărții (`harta.tscn`, `_actualizeaza_antet`).

enum Fel { PV, MONEDE, FRAGMENTE }

## Ce desenează. `set` cere o redesenare, ca schimbarea din inspector să se vadă.
@export var fel: Fel = Fel.PV:
	set(valoare):
		fel = valoare
		queue_redraw()

const DOSAR_IMAGINI := "res://assets/art/resurse/"
const IMAGINI := {
	Fel.PV: "pv.png",
	Fel.MONEDE: "monede.png",
	Fel.FRAGMENTE: "fragmente.png",
}

## Cerneala conturului, aceeași pentru toate trei: le leagă într-o familie.
const CONTUR := Color(0.10, 0.06, 0.03, 0.95)

## Umbra de sub imagine: o copie închisă, deplasată în jos-dreapta. Imaginea
## stă direct pe pergament, iar fără umbră cristalul, deschis la culoare, se
## topește în hârtie.
const UMBRA := Color(0.10, 0.06, 0.03, 0.45)
const DEPLASARE_UMBRA := Vector2(1.5, 2.0)

## Texturile încărcate, pe CLASĂ (o copie pentru toate iconițele), inclusiv
## eșecul (`null`), ca un fișier lipsă să nu fie căutat la fiecare redesenare.
static var _texturi := {}


static func _textura(fel_cerut: int) -> Texture2D:
	if _texturi.has(fel_cerut):
		return _texturi[fel_cerut]
	var textura: Texture2D = null
	var cale: String = DOSAR_IMAGINI + String(IMAGINI[fel_cerut])
	if ResourceLoader.exists(cale):
		textura = load(cale) as Texture2D
	if textura == null:
		print("IconitaResursa: %s lipseste sau nu s-a putut incarca; desenez din cod." % cale)
	_texturi[fel_cerut] = textura
	return textura


func _draw() -> void:
	var textura := _textura(fel)
	if textura != null:
		var latura := minf(size.x, size.y)
		var cutie := Rect2((size - Vector2(latura, latura)) / 2.0, Vector2(latura, latura))
		draw_texture_rect(textura, Rect2(cutie.position + DEPLASARE_UMBRA, cutie.size), false, UMBRA)
		draw_texture_rect(textura, cutie, false)
		return

	var c := size / 2.0
	# Raza ia latura cea mai mică, ca semnul să nu se lățească într-o cutie lată.
	var r := minf(size.x, size.y) / 2.0 - 1.0
	match fel:
		Fel.PV:
			_inima(c, r)
		Fel.MONEDE:
			_moneda(c, r)
		Fel.FRAGMENTE:
			_fragment(c, r)


## Inima: curba clasică x = 16 sin³t, y = 13 cos t − 5 cos 2t − 2 cos 3t − cos 4t,
## eșantionată în 32 de puncte. Iese o inimă rotunjită, nu două cercuri lipite.
func _inima(c: Vector2, r: float) -> void:
	var puncte := PackedVector2Array()
	for i in 32:
		var t := TAU * i / 32.0
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		# Curba are ~34 de unități pe lățime; o aducem la raza noastră și
		# întoarcem y-ul, fiindcă pe ecran y crește în jos.
		puncte.append(c + Vector2(x, -y - 2.0) * (r / 17.0))
	draw_colored_polygon(puncte, Color(0.72, 0.13, 0.12))
	# Lucirea din stânga-sus: o pată mică și deschisă, ca să nu fie plată.
	draw_circle(c + Vector2(-r * 0.38, -r * 0.30), r * 0.18, Color(1.0, 0.62, 0.55, 0.75))
	puncte.append(puncte[0])
	draw_polyline(puncte, CONTUR, 1.4, true)


## Moneda: disc auriu, un inel mai închis pe dinăuntru și o lucire.
func _moneda(c: Vector2, r: float) -> void:
	draw_circle(c, r, Color(0.86, 0.66, 0.24))
	draw_arc(c, r * 0.66, 0, TAU, 24, Color(0.58, 0.40, 0.12), 1.4, true)
	draw_circle(c + Vector2(-r * 0.32, -r * 0.34), r * 0.20, Color(1.0, 0.93, 0.66, 0.85))
	draw_arc(c, r, 0, TAU, 32, CONTUR, 1.4, true)


## Fragmentul: un cristal în șase colțuri, cu o față luminată și una în umbră,
## ca să citească „ciob de ceva prețios”, nu „romb”.
func _fragment(c: Vector2, r: float) -> void:
	var sus := c + Vector2(0, -r)
	var jos := c + Vector2(0, r)
	var st_sus := c + Vector2(-r * 0.62, -r * 0.30)
	var st_jos := c + Vector2(-r * 0.62, r * 0.36)
	var dr_sus := c + Vector2(r * 0.62, -r * 0.30)
	var dr_jos := c + Vector2(r * 0.62, r * 0.36)
	var mijloc := c + Vector2(0, -r * 0.05)
	draw_colored_polygon(PackedVector2Array([sus, st_sus, st_jos, jos, mijloc]),
		Color(0.62, 0.84, 0.92))
	draw_colored_polygon(PackedVector2Array([sus, mijloc, jos, dr_jos, dr_sus]),
		Color(0.27, 0.52, 0.68))
	draw_line(sus, mijloc, Color(0.90, 0.98, 1.0, 0.8), 1.0, true)
	draw_line(mijloc, jos, Color(0.12, 0.28, 0.40, 0.8), 1.0, true)
	draw_polyline(PackedVector2Array([sus, dr_sus, dr_jos, jos, st_jos, st_sus, sus]),
		CONTUR, 1.4, true)

extends Silueta
## Silueta inamicului: CAVALERUL ȘTERS. Armură, cască cu vizor, sabie ridicată —
## iar în locul chipului, un gol din care privesc doi ochi.
##
## Ideea vizuală: a fost un om. Ștergerea i-a luat chipul și numele, dar nu și
## postura — armura încă știe să lovească. De asta silueta e clar de adversar
## (umeri, armă ridicată), nu de obiect, dar se destramă la poale și poartă pe
## piept rânduri șterse, ca un blazon din care a fost radiat textul.
##
## Formele sunt scrise în fracțiuni din caseta de desen (0 = stânga/sus,
## 1 = dreapta/jos). Ce trebuie să pară neregulat — poalele destrămate, golul
## vizierei, rândurile șterse — e GENERAT, nu scris punct cu punct, cu o
## sămânță fixă (`seed`), ca să arate identic la fiecare pornire și să nu
## tremure în timp ce silueta respiră.

## Oțel șters: gri cu foarte puțină căldură, ca să nu pară albastru lângă rege.
@export var culoare := Color(0.60, 0.60, 0.57):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Golul din cască — mai închis decât fundalul luptei (0.09, 0.09, 0.12),
## ca să pară o gaură în armură, nu o vizieră vopsită.
@export var culoare_gol := Color(0.05, 0.05, 0.07):
	set(valoare):
		culoare_gol = valoare
		queue_redraw()

## Ochii. Chihlimbar, nu albastru: albastrul e culoarea regelui, iar cele două
## siluete trebuie să se citească diferit dintr-o privire.
@export var culoare_ochi := Color(1.0, 0.82, 0.42):
	set(valoare):
		culoare_ochi = valoare
		queue_redraw()

const SAMANTA := 20260901

# Golul vizierei, în straturi: de la unul abia mai închis decât armura până la
# negru. Straturi apropiate ca mărime și fiecare zdrențuit altfel = margine care
# se pierde în metal. Diferențe mari + aceeași formă ar da inele concentrice.
const STRATURI_GOL := [
	{"marime": 1.16, "amestec": 0.30},
	{"marime": 1.08, "amestec": 0.62},
	{"marime": 1.00, "amestec": 1.00},
]

# Formele generate. Calculate o dată, în `_ready()` — `_draw()` rulează de 60
# de ori pe secundă și n-au de ce să se schimbe.
var _trunchi := PackedVector2Array()
var _vizor: Array[PackedVector2Array] = []
var _linii_sterse: Array[PackedVector2Array] = []


## `_init()` rulează ÎNAINTE ca scena să aplice valorile din Inspector, deci
## astea rămân propuneri, pe care le poți suprascrie per nod. Bonusul: orice
## instanță a cavalerului (arena, portretul din card) pornește arătând la fel.
func _init() -> void:
	proportie = 0.72      # mai lat decât o filă: are umeri
	ancora_y = 1.0        # respiră din tălpi: stă înfipt, nu plutește


func _ready() -> void:
	super()               # `Silueta._ready()` — conectează `resized`, pornește respirația
	_trunchi = _genereaza_trunchi()
	_vizor = _genereaza_vizor()
	_linii_sterse = _genereaza_linii()


func _deseneaza_silueta() -> void:
	var umbra := culoare.darkened(0.38)

	_deseneaza_sabia()

	_poligon(_trunchi, culoare)
	_deseneaza_umerii()
	_deseneaza_bratul()

	# Rândurile șterse de pe piept — legătura cu Ștergerea, în două tonuri de gri.
	for linie in _linii_sterse:
		_poligon(linie, umbra)

	_deseneaza_casca()

	# GOLUL în locul chipului, în straturi (vezi STRATURI_GOL).
	for i in range(_vizor.size()):
		var amestec: float = STRATURI_GOL[i]["amestec"]
		_poligon(_vizor[i], culoare.lerp(culoare_gol, amestec))

	_deseneaza_ochii()


# ─────────────────────────────────────────────────────────────
# FORMELE FIXE
# Scrise de mână, pentru că trebuie să fie recognoscibile, nu organice.
# ─────────────────────────────────────────────────────────────

## Sabia ridicată, pe partea dreaptă. Desenată prima: brațul o va acoperi parțial,
## ca și cum ar fi ținută, nu lipită lângă corp.
func _deseneaza_sabia() -> void:
	# LAMA — se subțiază spre vârf.
	_poligon(PackedVector2Array([
		Vector2(0.845, 0.015),
		Vector2(0.888, 0.085),
		Vector2(0.879, 0.435),
		Vector2(0.811, 0.435),
		Vector2(0.802, 0.085),
	]), culoare)
	# GARDA — bara transversală, cea care face silueta „sabie" și nu „băț".
	_poligon(_dreptunghi(0.742, 0.435, 0.948, 0.482), culoare)
	# MÂNERUL
	_poligon(_dreptunghi(0.826, 0.482, 0.864, 0.572), culoare)
	# MĂCIULIA
	_poligon(_dreptunghi(0.812, 0.572, 0.878, 0.606), culoare)


## Umerii — două plăci unghiulare, peste trunchi. Ele dau lățimea de adversar.
## Sunt cu o idee mai deschise decât restul armurii: în aceeași culoare se
## topeau în trunchi și silueta ieșea un bloc, nu un om în platoșă.
func _deseneaza_umerii() -> void:
	var placa := culoare.lightened(0.12)
	_poligon(PackedVector2Array([
		Vector2(0.192, 0.462),
		Vector2(0.238, 0.342),
		Vector2(0.396, 0.296),
		Vector2(0.448, 0.404),
		Vector2(0.336, 0.492),
	]), placa)
	_poligon(PackedVector2Array([
		Vector2(0.808, 0.462),
		Vector2(0.762, 0.342),
		Vector2(0.604, 0.296),
		Vector2(0.552, 0.404),
		Vector2(0.664, 0.492),
	]), placa)


## Brațul care ține sabia: o bandă de la umărul drept până la mâner.
func _deseneaza_bratul() -> void:
	_poligon(PackedVector2Array([
		Vector2(0.646, 0.404),
		Vector2(0.740, 0.372),
		Vector2(0.856, 0.520),
		Vector2(0.812, 0.596),
		Vector2(0.664, 0.486),
	]), culoare)


## Casca: se îngustează spre creștet, cu o mică teșitură în față.
func _deseneaza_casca() -> void:
	_poligon(PackedVector2Array([
		Vector2(0.384, 0.312),
		Vector2(0.382, 0.176),
		Vector2(0.414, 0.088),
		Vector2(0.468, 0.050),
		Vector2(0.532, 0.050),
		Vector2(0.586, 0.088),
		Vector2(0.618, 0.176),
		Vector2(0.616, 0.312),
	]), culoare)


## Ochii: un punct tare, cu un halo mai palid în jur. Haloul e tot ce trebuie
## ca să pară că LUMINEAZĂ, nu că sunt două găuri mai mici în gol.
func _deseneaza_ochii() -> void:
	var halo := Color(culoare_ochi.r, culoare_ochi.g, culoare_ochi.b, 0.22)
	for x in [0.466, 0.534]:
		_cerc(Vector2(x, 0.198), 0.030, halo)
		_cerc(Vector2(x, 0.198), 0.015, culoare_ochi)


# ─────────────────────────────────────────────────────────────
# FORMELE GENERATE
# Fiecare cu altă sămânță, ca să nu iasă identice între ele.
# ─────────────────────────────────────────────────────────────

## Trunchiul: laturile sunt scrise de mână, dar poalele sunt zdrențuite —
## armura nu se termină, se destramă.
func _genereaza_trunchi() -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = SAMANTA

	var puncte := PackedVector2Array([
		Vector2(0.430, 0.298),   # gât, stânga
		Vector2(0.570, 0.298),   # gât, dreapta
		Vector2(0.662, 0.398),   # spre umărul drept
		Vector2(0.688, 0.672),   # talia dreaptă
		Vector2(0.706, 0.878),   # poalele se evazează, ca o fustă de zale
	])
	# Poalele: mergem de la dreapta la stânga, împingând fiecare pas în sus sau
	# în jos. Pași mulți și mărunți = zdrențe, nu valuri.
	var pasi := 13
	for pas in range(pasi + 1):
		var x := lerpf(0.706, 0.294, float(pas) / pasi)
		puncte.append(Vector2(x, 0.878 + rng.randf_range(-0.032, 0.080)))
	puncte.append_array(PackedVector2Array([
		Vector2(0.312, 0.672),   # talia stângă
		Vector2(0.338, 0.398),
	]))
	return puncte


## Golul vizierei, în straturi. Fiecare strat primește ALTĂ sămânță, deci
## conturul lui e zdrențuit altfel și marginea pare mâncată, nu desenată.
func _genereaza_vizor() -> Array[PackedVector2Array]:
	# Casca are interiorul intre x 0.392 si 0.610. Golul trebuie sa incapa in ea:
	# raza * factorul orizontal, impartite la `proportie`, dau jumatate din
	# latimea lui in fractiuni — 0.048 * 1.35 / 0.72 = 0.090, adica 0.18 in total.
	var centru := Vector2(0.500, 0.198)
	var raza := 0.048
	var laturi := 16

	var straturi: Array[PackedVector2Array] = []
	for indice in range(STRATURI_GOL.size()):
		# Tipul e scris explicit: valorile dintr-un Dictionary sunt „orice",
		# iar GDScript nu poate ghici singur că astea sunt numere.
		var marime: float = STRATURI_GOL[indice]["marime"]
		var rng := RandomNumberGenerator.new()
		rng.seed = SAMANTA + 1 + indice
		var puncte := PackedVector2Array()
		for i in range(laturi):
			var unghi := TAU * i / laturi
			var variatie := 1.0 + rng.randf_range(-0.14, 0.14)
			# Vizieră: mai lată decât înaltă. `_corectat` are grijă ca lățimea
			# în fracțiuni să însemne aceiași pixeli ca înălțimea.
			var directie := _corectat(Vector2(cos(unghi) * 1.35, sin(unghi)))
			puncte.append(centru + directie * raza * marime * variatie)
		straturi.append(puncte)
	return straturi


## Rândurile șterse de pe piept: dreptunghiuri joase care se opresc unde vor —
## un blazon din care a fost radiat textul.
func _genereaza_linii() -> Array[PackedVector2Array]:
	var rng := RandomNumberGenerator.new()
	rng.seed = SAMANTA + 5

	var linii: Array[PackedVector2Array] = []
	var y := 0.510
	for i in range(3):
		var start := 0.404 + rng.randf_range(0.0, 0.020)
		var final := start + rng.randf_range(0.075, 0.185)
		linii.append(PackedVector2Array([
			Vector2(start, y),
			Vector2(final, y + rng.randf_range(-0.004, 0.004)),
			Vector2(final, y + 0.011),
			Vector2(start, y + 0.011),
		]))
		y += 0.058
	return linii


## Un dreptunghi scris ca poligon, ca să treacă și el prin respirație și
## înclinare la fel ca restul formelor. (`draw_rect` n-ar face-o.)
func _dreptunghi(x1: float, y1: float, x2: float, y2: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(x1, y1), Vector2(x2, y1), Vector2(x2, y2), Vector2(x1, y2),
	])

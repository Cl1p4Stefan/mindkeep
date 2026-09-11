extends Silueta
## Silueta inamicului: PAGINA GOALĂ. O filă zdrențuită pe toate laturile, cu
## urme de rânduri șterse în partea de sus și o gaură în mijloc.
##
## Ideea vizuală: nu e o pagină care n-a fost scrisă niciodată — e una din care
## a fost ȘTERS ceva. Rândurile care se opresc brusc și golul cu marginile
## mâncate spun povestea asta fără niciun cuvânt.
##
## Formele NU sunt scrise de mână punct cu punct — ar fi însemnat peste 60 de
## perechi de numere, imposibil de ajustat. Sunt generate: pornim de la forme
## regulate (un dreptunghi, un cerc) și le stricăm puțin, la întâmplare.
##
## „La întâmplare", dar cu SĂMÂNȚĂ FIXĂ (`seed`): același număr de pornire dă
## mereu aceeași serie de valori. Fila arată identic la fiecare pornire a
## jocului, iar respirația nu o face să tremure. Dacă vrei altă ruptură,
## schimbi sămânța cu orice alt număr.

## Cremul filei, pe fundalul întunecat al arenei.
@export var culoare := Color(0.90, 0.87, 0.78):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Golul din centru — mai închis decât fundalul luptei (0.09, 0.09, 0.12),
## ca să pară o gaură în filă, nu o pată desenată pe ea.
@export var culoare_gol := Color(0.05, 0.05, 0.07):
	set(valoare):
		culoare_gol = valoare
		queue_redraw()

## Rândurile șterse. Gri, nu negru: text care a fost, nu text care e.
@export var culoare_text := Color(0.55, 0.53, 0.51):
	set(valoare):
		culoare_text = valoare
		queue_redraw()

const SAMANTA := 20260831

# Colțurile filei, în sens orar: stânga-sus, dreapta-sus, dreapta-jos, stânga-jos.
const COLTURI := [
	Vector2(0.08, 0.03), Vector2(0.92, 0.03),
	Vector2(0.92, 0.97), Vector2(0.08, 0.97),
]

# Cât de dese sunt zdrențele: o așchie la fiecare ~0.05 din ÎNĂLȚIMEA casetei.
# Fiind o distanță reală, nu un număr de pași, laturile lungi primesc automat
# mai multe așchii decât cele scurte — altfel latura lungă ar ieși netedă.
const DESIME_ZDRENTE := 0.05

# GOLUL e desenat în straturi suprapuse, de la cel mai mare la cel mai mic.
# Fiecare e cu un pas mai aproape de negru: 0.16 = abia mai închis decât fila,
# 1.0 = golul propriu-zis. Efectul e o margine care se pierde în pagină, în loc
# de un contur tăiat cu foarfeca. Numerele sunt „cât de mare" și „cât de închis".
#
# Straturile trebuie să fie APROAPE ca mărime și fiecare zdrențuit ALTFEL.
# Prima variantă le dădea aceeași sămânță și diferențe mari de mărime: ieșeau
# contururi perfect paralele, adică o țintă cu inele, nu o gaură.
const STRATURI_GOL := [
	{"marime": 1.20, "amestec": 0.16},
	{"marime": 1.13, "amestec": 0.38},
	{"marime": 1.06, "amestec": 0.66},
	{"marime": 1.00, "amestec": 1.00},
]

# Formele, în fracțiuni. Calculate o dată, în `_ready()`, nu la fiecare cadru:
# n-au de ce să se schimbe, iar `_draw()` rulează de 60 de ori pe secundă.
var _fila := PackedVector2Array()
var _linii_sterse: Array[PackedVector2Array] = []
var _gol: Array[PackedVector2Array] = []


## `_init()` rulează ÎNAINTE ca scena să aplice valorile puse în Inspector.
## De asta setăm aici valorile implicite ale filei, și nu în `_ready()`: rămân
## niște propuneri, pe care le poți suprascrie din editor pentru un nod anume.
## Bonusul: orice instanță a siluetei (arena, portretul din card) pornește la fel.
func _init() -> void:
	proportie = 0.62      # o filă e clar mai înaltă decât lată
	inclinare = 4.0       # câteva grade, cât să nu pară pusă cu rigla
	ancora_y = 0.5        # respiră din centru: plutește, nu stă pe ceva


func _ready() -> void:
	super()               # `Silueta._ready()` — conectează `resized`, pornește respirația
	_fila = _genereaza_fila()
	_linii_sterse = _genereaza_linii()
	_gol = _genereaza_gol()


func _deseneaza_silueta() -> void:
	_poligon(_fila, culoare)

	for linie in _linii_sterse:
		_poligon(linie, culoare_text)

	# `lerp` pe culori = „amestecă-le". 0.0 = cremul filei, 1.0 = negrul golului.
	for i in range(_gol.size()):
		var amestec: float = STRATURI_GOL[i]["amestec"]
		_poligon(_gol[i], culoare.lerp(culoare_gol, amestec))


# ─────────────────────────────────────────────────────────────
# GENERAREA FORMELOR
# Toate primesc un `seed` diferit, ca să nu iasă identice între ele.
# ─────────────────────────────────────────────────────────────

## Conturul filei: un dreptunghi cu toate cele patru laturi zdrențuite.
func _genereaza_fila() -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = SAMANTA

	var puncte := PackedVector2Array()
	for i in range(COLTURI.size()):
		var de_la: Vector2 = COLTURI[i]
		var pana_la: Vector2 = COLTURI[(i + 1) % COLTURI.size()]   # „%" ne întoarce la primul colț
		var directie := (pana_la - de_la).normalized()
		# Normala = direcția rotită cu 90°. Cu colțurile în sens orar, ea arată
		# spre EXTERIORUL filei, deci un offset pozitiv scoate o așchie afară.
		var normala := Vector2(directie.y, -directie.x)

		# Câți pași pe latura asta. `_lungime_reala` ține cont că un pas pe
		# orizontală e mai scurt în pixeli decât unul pe verticală (caseta e
		# îngustă) — fără corecția asta, laturile verticale ies mult mai netede.
		var pasi := maxi(4, int(round(_lungime_reala(pana_la - de_la) / DESIME_ZDRENTE)))
		for pas in range(pasi):
			# `lerp` = mergi de la un punct la altul; t merge de la 0 spre 1.
			var pe_muchie := de_la.lerp(pana_la, float(pas) / pasi)
			puncte.append(pe_muchie + _corectat(normala) * rng.randf_range(-0.022, 0.026))

	return puncte


## Rândurile șterse: dreptunghiuri joase, în partea de sus a filei.
## Fiecare începe cam de la aceeași margine, dar se oprește unde vrea el —
## de asta arată ca text întrerupt, nu ca un gard.
func _genereaza_linii() -> Array[PackedVector2Array]:
	var rng := RandomNumberGenerator.new()
	rng.seed = SAMANTA + 1

	var linii: Array[PackedVector2Array] = []
	var y := 0.13
	for i in range(5):
		var start := 0.19 + rng.randf_range(0.0, 0.03)
		var final := start + rng.randf_range(0.28, 0.60)
		var grosime := 0.011
		linii.append(PackedVector2Array([
			Vector2(start, y),
			Vector2(final, y + rng.randf_range(-0.004, 0.004)),   # rândul nu e perfect drept
			Vector2(final, y + grosime),
			Vector2(start, y + grosime),
		]))
		y += 0.058
	return linii


## Golul din centru, în straturi. Fiecare strat e un cerc căruia îi variem raza
## la fiecare punct — și fiecare primește ALTĂ sămânță, deci conturul lui iese
## zdrențuit altfel. Straturile se încalecă neregulat, iar marginea pare mâncată.
func _genereaza_gol() -> Array[PackedVector2Array]:
	var centru := Vector2(0.5, 0.60)
	var raza := 0.135            # fracțiune din înălțime; corectată pe orizontală
	var laturi := 22

	var straturi: Array[PackedVector2Array] = []
	for indice in range(STRATURI_GOL.size()):
		# Tipul e scris explicit: valorile dintr-un Dictionary sunt „orice",
		# iar GDScript nu poate ghici singur că astea sunt numere.
		var marime: float = STRATURI_GOL[indice]["marime"]
		var rng := RandomNumberGenerator.new()
		rng.seed = SAMANTA + 2 + indice
		var puncte := PackedVector2Array()
		for i in range(laturi):
			var unghi := TAU * i / laturi
			var variatie := 1.0 + rng.randf_range(-0.13, 0.13)
			var directie := _corectat(Vector2(cos(unghi), sin(unghi)))
			puncte.append(centru + directie * raza * marime * variatie)
		straturi.append(puncte)
	return straturi

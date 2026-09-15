class_name GlifaSah
extends Silueta
## PIESA DE ȘAH de pe butonul unui Obelisc: pionul, calul, nebunul.
##
## ─────────────────────────────────────────────────────────────
## DE CE DESENATĂ, ȘI NU SCRISĂ CU ♟ ♞ ♝
##
## Ăsta a fost primul lucru încercat, și nu merge: fontul implicit al lui Godot
## (Open Sans SemiBold) NU conține caracterele de șah. Verificat, nu presupus —
## `ThemeDB.fallback_font.has_char(0x265F)` întoarce `false` pentru toate trei.
## Pe ecran ar fi ieșit trei dreptunghiuri goale („tofu"), adică exact opusul a
## ce voiam.
##
## Se putea rezolva în două feluri, și amândouă costau mai mult decât desenul:
##   • un `SystemFont` (Segoe UI Symbol) — merge pe Windows, dar fonturile de
##     sistem nu există în export web, iar web-ul e pe lista de pași;
##   • un font adus în proiect — un fișier de câteva sute de KB și o licență de
##     verificat, pentru trei simboluri.
##
## Desenate, piesele merg oriunde (inclusiv pe web), se colorează cu culoarea
## disciplinei fără trucuri și sunt tăioase la orice mărime.
##
## ─────────────────────────────────────────────────────────────
## CUM E CONSTRUITĂ
##
## Moștenește `Silueta`, aceeași bază folosită de rege și de Pagina Goală: ea
## știe deja să potrivească o casetă cu proporții corecte în orice cutie îi dă
## containerul și să traducă „fracțiuni" (numere între 0 și 1) în pixeli.
## Formele de mai jos sunt deci liste de numere între 0 și 1 — ușor de citit,
## ușor de ajustat, independente de mărimea butonului.
##
## Singura diferență față de siluetele din arenă: piesa asta NU respiră
## (`amplitudine = 0`) și, ca urmare, nu are nevoie de `_process` — trei icoane
## care pulsează sub trei butoane ar fi zgomot, nu viață.

enum Piesa { PION, CAL, NEBUN }

## Culoarea piesei. O pune `obelisc.gd`, din tabelul disciplinelor.
@export var culoare := Color(0.85, 0.88, 1.0):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Culoarea GĂURILOR: ochiul și nara calului, fanta nebunului. Nu e „negru", e
## „culoarea a ceea ce se vede prin piesă" — adică fondul butonului. De-aia o
## primește din afară: dacă butonul își schimbă fondul, tăieturile îl urmează.
@export var culoare_gol := Color(0.11, 0.11, 0.15):
	set(valoare):
		culoare_gol = valoare
		queue_redraw()

## Cât de aprins e halo-ul din spatele piesei, de la 0 (deloc) la ~1.
## E o valoare ANIMATĂ din `obelisc.gd` (mai tare la hover), de-aia e o simplă
## proprietate cu setter: un Tween poate scrie în ea de 60 de ori pe secundă.
@export var glow := 0.32:
	set(valoare):
		glow = valoare
		queue_redraw()

## Desenăm doar halo-ul, fără piesă?
##
## Așa stă glifa sub un Obelisc care și-a primit ARTA ADEVĂRATĂ (vezi câmpul
## „imagine" din tabelul `OBELISCURI`): imaginea se pune peste nodul ăsta, iar
## nodul rămâne să facă singurul lucru pe care un PNG nu-l poate face singur —
## să se aprindă și să se stingă în culoarea disciplinei, la hover.
##
## De ce nu ștergem pur și simplu nodul când există imagine: atunci hover-ul ar
## trebui să anime altă proprietate pentru Obeliscurile cu artă decât pentru cele
## desenate, iar `obelisc.gd` ar avea două feluri de a se aprinde. Așa are unul.
@export var doar_aura := false:
	set(valoare):
		doar_aura = valoare
		queue_redraw()

## Ce piesă desenăm. Schimbarea ei schimbă și proporția casetei: un cal e mai
## lat decât un pion, iar o casetă comună ar turti-o pe una din ele.
@export var piesa: Piesa = Piesa.PION:
	set(valoare):
		piesa = valoare
		proportie = FORME[piesa]["proportie"]
		queue_redraw()

# ─────────────────────────────────────────────────────────────
# FORMELE, ÎN FRACȚIUNI
#
# (0,0) e colțul din stânga-sus al casetei, (1,1) cel din dreapta-jos.
# Deci y MIC = sus. Toate piesele sunt construite la fel, de sus în jos:
# cap sau mitră, guler, corp care se evazează, talpă.
# ─────────────────────────────────────────────────────────────

# DE CE `static var` ȘI NU `const`, deși numerele astea nu se schimbă niciodată:
# GDScript acceptă drept constantă doar o expresie pe care o poate calcula la
# citirea fișierului, iar `PackedVector2Array([...])` e o CHEMARE de funcție —
# deci refuză („Assigned value for constant isn't a constant expression").
# `static var` înseamnă „aparține SCRIPTULUI, nu fiecărui buton": se calculează
# o singură dată, la încărcarea scriptului, și e aceeași listă pentru toate cele
# trei butoane. Scrise cu MAJUSCULE fiindcă asta rămân: niște constante.

# PIONUL — cel mai simplu: o bilă, un guler, un corp care se lărgește, o talpă.
static var PION_GULER := PackedVector2Array([
	Vector2(0.355, 0.400), Vector2(0.645, 0.400),
	Vector2(0.625, 0.455), Vector2(0.375, 0.455),
])
static var PION_CORP := PackedVector2Array([
	Vector2(0.375, 0.450), Vector2(0.625, 0.450),
	Vector2(0.660, 0.620), Vector2(0.720, 0.780),
	Vector2(0.280, 0.780), Vector2(0.340, 0.620),
])
static var PION_TALPA := PackedVector2Array([
	Vector2(0.220, 0.770), Vector2(0.780, 0.770),
	Vector2(0.840, 0.895), Vector2(0.860, 0.965),
	Vector2(0.140, 0.965), Vector2(0.160, 0.895),
])

# NEBUNUL — mitra cu fantă, bila din vârf, același corp-talpă ca pionul.
static var NEBUN_MITRA := PackedVector2Array([
	Vector2(0.500, 0.140), Vector2(0.608, 0.190),
	Vector2(0.678, 0.288), Vector2(0.692, 0.382),
	Vector2(0.648, 0.458), Vector2(0.352, 0.458),
	Vector2(0.308, 0.382), Vector2(0.322, 0.288),
	Vector2(0.392, 0.190),
])
static var NEBUN_FANTA := PackedVector2Array([
	Vector2(0.452, 0.228), Vector2(0.478, 0.210),
	Vector2(0.612, 0.360), Vector2(0.586, 0.378),
])
static var NEBUN_GULER := PackedVector2Array([
	Vector2(0.330, 0.452), Vector2(0.670, 0.452),
	Vector2(0.648, 0.522), Vector2(0.352, 0.522),
])
static var NEBUN_CORP := PackedVector2Array([
	Vector2(0.378, 0.515), Vector2(0.622, 0.515),
	Vector2(0.700, 0.770), Vector2(0.300, 0.770),
])
static var NEBUN_TALPA := PackedVector2Array([
	Vector2(0.200, 0.760), Vector2(0.800, 0.760),
	Vector2(0.862, 0.890), Vector2(0.880, 0.965),
	Vector2(0.120, 0.965), Vector2(0.138, 0.890),
])

# CALUL — singura piesă care nu e o coloană cu ceva pe vârf, deci singura care
# NU se lasă scrisă ca un contur unic. Prima încercare a fost exact asta: un
# singur poligon de 35 de puncte, ajustat din ochi. Ieșea, pe rând, un iepure,
# o lamă și o lebădă — fiindcă într-un contur închis fiecare punct ține de doi
# vecini, iar când tragi de unul ca să lungești botul se strică falca.
#
# Acum calul e COMPUS din părți care se suprapun: talpă, gât, cap, două urechi,
# un obraz rotund. Toate se desenează în aceeași culoare, una peste alta, deci
# nu e nevoie de niciun calcul de reuniune — pata rezultată E silueta.
# Avantajul real: poți lungi botul fără să atingi gâtul.
static var CAL_TALPA := PackedVector2Array([
	Vector2(0.140, 0.968), Vector2(0.860, 0.968),
	Vector2(0.806, 0.884), Vector2(0.770, 0.848),
	Vector2(0.230, 0.848), Vector2(0.194, 0.884),
])
static var CAL_GAT := PackedVector2Array([
	Vector2(0.300, 0.856), Vector2(0.752, 0.856),
	Vector2(0.812, 0.470), Vector2(0.392, 0.500),
])
static var CAL_CAP := PackedVector2Array([
	Vector2(0.452, 0.150), Vector2(0.760, 0.146),
	Vector2(0.852, 0.360), Vector2(0.716, 0.560),
	Vector2(0.300, 0.604), Vector2(0.104, 0.512),
	Vector2(0.120, 0.360),
])
static var CAL_URECHE_FATA := PackedVector2Array([
	Vector2(0.566, 0.058), Vector2(0.628, 0.148), Vector2(0.524, 0.168),
])
static var CAL_URECHE_SPATE := PackedVector2Array([
	Vector2(0.700, 0.052), Vector2(0.768, 0.156), Vector2(0.648, 0.150),
])

## Catalogul formelor. Un rând per piesă: poligoanele pline, cercurile pline,
## „golurile" (desenate peste, în culoarea fondului) și proporția casetei.
## O a patra piesă — regina, dacă se întoarce vreodată — e un rând aici.
static var FORME := {
	Piesa.PION: {
		"proportie": 0.62,
		"poligoane": [PION_TALPA, PION_CORP, PION_GULER],
		"cercuri": [{"centru": Vector2(0.5, 0.262), "raza": 0.145}],
		"goluri": [],
		"cercuri_gol": [],
	},
	Piesa.CAL: {
		"proportie": 0.72,
		"poligoane": [CAL_TALPA, CAL_GAT, CAL_CAP, CAL_URECHE_FATA, CAL_URECHE_SPATE],
		"cercuri": [
			{"centru": Vector2(0.640, 0.330), "raza": 0.190},
			{"centru": Vector2(0.196, 0.430), "raza": 0.092},
		],
		"goluri": [],
		"cercuri_gol": [
			{"centru": Vector2(0.530, 0.268), "raza": 0.034},
			{"centru": Vector2(0.148, 0.430), "raza": 0.020},
		],
	},
	Piesa.NEBUN: {
		"proportie": 0.62,
		"poligoane": [NEBUN_TALPA, NEBUN_CORP, NEBUN_GULER, NEBUN_MITRA],
		"cercuri": [{"centru": Vector2(0.5, 0.086), "raza": 0.049}],
		"goluri": [NEBUN_FANTA],
		"cercuri_gol": [],
	},
}

## Cât de departe se întinde halo-ul dincolo de piesă, ca fracțiune din
## înălțimea casetei. Peste ~0.35 nu mai e un halo, e o ceață.
const RAZA_AURA := 0.34

## Halo-ul: o pată radială care se STINGE spre margini. E o textură generată din
## cod, nu un fișier — un degrade descris în patru rânduri.
##
## De ce o textură și nu conturul desenat de mai multe ori, din ce în ce mai
## mare: straturile suprapuse se văd ca inele, oricât de transparente le-ai
## face. Un degrade radial e o singură desenare și chiar se stinge, în loc să se
## oprească. `static` = se face o dată pentru tot jocul, nu o dată per buton.
static var _aura: GradientTexture2D = null


func _init() -> void:
	amplitudine = 0.0   # piesele de pe butoane nu respiră
	ancora_y = 0.5
	proportie = FORME[Piesa.PION]["proportie"]


func _ready() -> void:
	super()              # `Silueta._ready()` — conectează `resized`
	# Fără respirație n-avem ce calcula în fiecare cadru. `Silueta._process()`
	# ar chema `queue_redraw()` de 60 de ori pe secundă ca să deseneze exact
	# aceeași imagine. Redesenăm doar când chiar se schimbă ceva (culoare,
	# glow, piesă) — adică din seterele de sus.
	set_process(false)
	if _aura == null:
		_aura = _fa_aura()


## Degradeul radial, făcut o singură dată. ALB, nu colorat: îl colorăm la
## desenare, cu culoarea disciplinei, deci aceeași textură servește toate
## piesele (alb × culoare = culoare).
static func _fa_aura() -> GradientTexture2D:
	var degrade := Gradient.new()
	degrade.offsets = PackedFloat32Array([0.0, 0.42, 1.0])
	degrade.colors = PackedColorArray([
		Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0.0),
	])
	var textura := GradientTexture2D.new()
	textura.gradient = degrade
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)   # raza = jumătate din lățime
	textura.width = 64
	textura.height = 64
	return textura


func _deseneaza_silueta() -> void:
	var forma: Dictionary = FORME[piesa]

	# ÎNTÂI halo-ul, ca să rămână SUB piesă. Pătrat și centrat pe casetă:
	# un halo turtit după proporția piesei ar arăta ca o umbră, nu ca o lumină.
	if glow > 0.0:
		var latura := _caseta.size.y * (1.0 + RAZA_AURA * 2.0)
		var centru := _caseta.position + _caseta.size * 0.5
		draw_texture_rect(
			_aura,
			Rect2(centru - Vector2(latura, latura) * 0.5, Vector2(latura, latura)),
			false,
			Color(culoare, glow)
		)

	if doar_aura:
		return

	for poligon: PackedVector2Array in forma["poligoane"]:
		_poligon(poligon, culoare)
	for cerc: Dictionary in forma["cercuri"]:
		_cerc(cerc["centru"], cerc["raza"], culoare)

	# GOLURILE se desenează LA FINAL, peste piesă: sunt tăieturi în ea.
	for poligon: PackedVector2Array in forma["goluri"]:
		_poligon(poligon, culoare_gol)
	for cerc: Dictionary in forma["cercuri_gol"]:
		_cerc(cerc["centru"], cerc["raza"], culoare_gol)

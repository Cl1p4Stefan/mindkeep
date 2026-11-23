class_name SuneteIaz
extends Node
## SUNETELE IAZULUI — sintetizate în cod, cu loc pentru fișiere adevărate.
##
## Iazul n-are niciun fișier audio, la fel cum n-are nicio imagine: tot ce se
## aude e CALCULAT aici, eșantion cu eșantion, la prima deschidere. Pare mult,
## dar e aceeași judecată ca la desen — un sunet de plută care cade în apă e un
## „bloop" (o sinusoidă care coboară repede) plus un pic de zgomot, adică zece
## rânduri, nu un fișier căutat pe internet, cu licența lui de verificat.
##
## ÎNLOCUIREA CU FIȘIERE. Fiecare sunet are o CHEIE (`arunca`, `plici`, …).
## Dacă există `res://assets/audio/iazul/<cheie>.ogg`, se folosește fișierul și
## sinteza se sare. Deci ziua în care găsești un plescăit mai bun e o copiere
## în dosar, nu o sesiune de programare — aceeași plasă ca în `Sunet`, unde
## efectele fără fișier stau mute fără să strice nimic.
##
## DE CE NU PRIN `Sunet`: acolo efectele sunt un `enum` cu fișiere, scrise o
## dată pentru toată lupta. Ale iazului sunt ale iazului: nimeni altcineva nu
## va cere vreodată „greieri". Iar AMBIANȚA (apa, ploaia, greierii) e altceva
## decât un efect — buclă fără sfârșit, cu volumul care urcă și coboară după
## oră și vreme, deci ar fi cerut în `Sunet` un al patrulea fel de difuzor.
## Nodul ăsta trăiește și moare cu scena: ieși din iaz și se tace apa.

const RATA := 22050
const DOSAR_FISIERE := "res://assets/audio/iazul/"

## Efectele scurte și volumul lor, în dB. Clicul mulinetei e cel mai încet
## fiindcă se aude de zeci de ori pe luptă; plescăitul capturii cel mai tare
## fiindcă se aude o dată.
const EFECTE := {
	"arunca": -10.0,     # vâjâitul undiței
	"plici": -6.0,       # pluta cade în apă (mai încet cu cât e mai departe)
	"ciupitura": -9.0,   # pluta tresare
	"muscatura": -4.0,   # pluta trasă la fund: ACUM
	"clic": -20.0,       # mulineta, cât tragi
	"frana": -17.0,      # frâna mulinetei: peștele ia fir
	"scartait": -8.0,    # firul se întinde: dă drumul
	"rupt": -6.0,        # firul plesnește
	"stropi": -5.0,      # peștele scos din apă
	"ciripit": -22.0,    # o pasăre, ziua
}

## Ambianța: bucle care nu se opresc niciodată, doar se sting.
const AMBIANTA := {
	"apa": -15.0,        # mereu
	"ploaie": -13.0,     # când plouă
	"greieri": -25.0,    # noaptea și la amurg, dacă nu plouă
}

## Cât de repede urcă sau coboară o buclă de ambianță, în volum liniar pe
## secundă. 0,25 înseamnă patru secunde de la tăcere la plin: ploaia vine
## treptat, nu se aprinde ca un bec.
const VITEZA_AMBIANTA := 0.25

const VOCI := 6

## Sunetele construite, cheie → AudioStream. `static`: se calculează o singură
## dată pe toată durata jocului, nu la fiecare intrare în iaz.
static var _construite := {}

## Ce s-a auzit, în ordine. Îl citește `verifica_iazul`, care nu are urechi.
var auzite: Array[String] = []

var _voci: Array[AudioStreamPlayer] = []
var _voce := 0
var _bucle := {}        # cheie → AudioStreamPlayer
var _tinta := {}        # cheie → volum liniar dorit (0..1)


func _ready() -> void:
	_construieste_tot()
	for i in VOCI:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_voci.append(p)
	for cheie: String in AMBIANTA:
		var p := AudioStreamPlayer.new()
		p.stream = _construite[cheie]
		p.volume_db = -80.0
		add_child(p)
		p.play()
		_bucle[cheie] = p
		_tinta[cheie] = 0.0


## Redă un efect. `in_plus_db` îl face mai încet sau mai tare decât reglajul
## lui (pluta de departe), `ton` îl face mai grav sau mai ascuțit (peștele
## speriat e o ciupitură mai gravă, nu un sunet nou).
func reda(cheie: String, in_plus_db := 0.0, ton := 1.0) -> void:
	auzite.append(cheie)
	if not _construite.has(cheie):
		return
	var p := _voci[_voce]
	_voce = (_voce + 1) % VOCI
	p.stream = _construite[cheie]
	p.volume_db = float(EFECTE.get(cheie, -10.0)) + in_plus_db
	p.pitch_scale = ton
	p.play()


## Chemat la fiecare pas de iaz: hotărăște ce ambianță se aude acum.
func ambianta(dt: float, moment: String, vreme: String) -> void:
	_tinta["apa"] = 1.0
	_tinta["ploaie"] = 1.0 if vreme == "ploaie" else 0.0
	_tinta["greieri"] = 1.0 if (moment == "noapte" or moment == "amurg") and vreme != "ploaie" else 0.0
	for cheie: String in _bucle:
		var p: AudioStreamPlayer = _bucle[cheie]
		var acum := db_to_linear(p.volume_db) / db_to_linear(AMBIANTA[cheie])
		acum = move_toward(clampf(acum, 0.0, 1.0), _tinta[cheie], VITEZA_AMBIANTA * dt)
		p.volume_db = -80.0 if acum <= 0.001 else AMBIANTA[cheie] + linear_to_db(acum)


## Cât de tare se aude acum o buclă, de la 0 la 1. Pentru verificare.
func nivel_ambianta(cheie: String) -> float:
	var p: AudioStreamPlayer = _bucle[cheie]
	if p.volume_db <= -79.0:
		return 0.0
	return clampf(db_to_linear(p.volume_db) / db_to_linear(AMBIANTA[cheie]), 0.0, 1.0)


# ─────────────────────────────────────────────────────────────
# CONSTRUCȚIA — fișierul, dacă există; altfel sinteza
# ─────────────────────────────────────────────────────────────

static func _construieste_tot() -> void:
	for cheie: String in EFECTE.keys() + AMBIANTA.keys():
		if _construite.has(cheie):
			continue
		var cale := DOSAR_FISIERE + cheie + ".ogg"
		if ResourceLoader.exists(cale):
			var s: AudioStream = load(cale)
			if "loop" in s:
				s.set("loop", AMBIANTA.has(cheie))
			_construite[cheie] = s
		else:
			_construite[cheie] = _wav(esantioane(cheie), AMBIANTA.has(cheie))


## Eșantioanele unui sunet sintetizat, între -1 și 1. Publică: verificarea le
## măsoară (să nu taie, să se audă, buclele să se lege).
static func esantioane(cheie: String) -> PackedFloat32Array:
	var r := RandomNumberGenerator.new()
	r.seed = hash(cheie)   # același sunet la fiecare pornire
	match cheie:
		"arunca": return _arunca(r)
		"plici": return _bloop(r, 0.35, 900.0, 240.0, 0.06, 30.0, 0.45, 16.0)
		"ciupitura": return _bloop(r, 0.12, 1300.0, 650.0, 0.03, 55.0, 0.12, 50.0)
		"muscatura": return _muscatura(r)
		"clic": return _clic(r, 2900.0, 380.0, 0.035)
		"frana": return _clic(r, 4300.0, 520.0, 0.025)
		"scartait": return _scartait(r)
		"rupt": return _rupt(r)
		"stropi": return _stropi(r)
		"ciripit": return _ciripit(r)
		"apa": return _apa(r)
		"ploaie": return _ploaie(r)
		"greieri": return _greieri()
	return PackedFloat32Array()


static func _wav(s: PackedFloat32Array, bucla: bool) -> AudioStreamWAV:
	var b := PackedByteArray()
	b.resize(s.size() * 2)
	for i in s.size():
		b.encode_s16(i * 2, int(clampf(s[i], -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATA
	w.stereo = false
	w.data = b
	if bucla:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = s.size()
	return w


static func _gol(secunde: float) -> PackedFloat32Array:
	var s := PackedFloat32Array()
	s.resize(int(secunde * RATA))
	return s


## Un „bloop": o sinusoidă care cade repede de la `f0` la `f1` (bula de aer
## care se strânge), plus o pală de zgomot înăbușit (apa împinsă).
static func _bloop(r: RandomNumberGenerator, durata: float, f0: float, f1: float,
		cadere: float, stingere: float, zgomot: float, stingere_zgomot: float) -> PackedFloat32Array:
	var s := _gol(durata)
	var faza := 0.0
	var lp := 0.0
	for i in s.size():
		var t := float(i) / RATA
		var f := f1 + (f0 - f1) * exp(-t / cadere)
		faza += TAU * f / RATA
		lp += 0.18 * (r.randf_range(-1, 1) - lp)
		s[i] = 0.75 * sin(faza) * exp(-t * stingere) + zgomot * 2.5 * lp * exp(-t * stingere_zgomot)
	return _netezeste_capetele(s)


static func _arunca(r: RandomNumberGenerator) -> PackedFloat32Array:
	var s := _gol(0.42)
	var lp := 0.0
	var faza := 0.0
	for i in s.size():
		var t := float(i) / RATA
		var x := t / 0.42
		var a := 0.04 + 0.35 * sin(PI * x)          # filtrul se deschide și se închide
		lp += a * (r.randf_range(-1, 1) - lp)
		faza += TAU * (1900.0 - 900.0 * x) / RATA  # fluieratul firului
		var anv := pow(sin(PI * x), 2.0)
		s[i] = anv * (0.9 * lp + 0.05 * sin(faza))
	return s


static func _muscatura(r: RandomNumberGenerator) -> PackedFloat32Array:
	var a := _bloop(r, 0.55, 600.0, 150.0, 0.08, 10.0, 0.5, 8.0)
	var b := _bloop(r, 0.2, 1000.0, 400.0, 0.03, 40.0, 0.1, 40.0)
	var start := int(0.07 * RATA)
	for i in b.size():
		if start + i < a.size():
			a[start + i] += 0.5 * b[i]
	return _normalizeaza(a, 0.9)


static func _clic(r: RandomNumberGenerator, ton: float, stingere: float, durata: float) -> PackedFloat32Array:
	var s := _gol(durata)
	var lp := 0.0
	for i in s.size():
		var t := float(i) / RATA
		var n := r.randf_range(-1, 1)
		lp += 0.3 * (n - lp)
		s[i] = exp(-t * stingere) * (0.6 * (n - lp) + 0.5 * sin(TAU * ton * t))
	return s


## Firul care se întinde: frecare, adică impulsuri tot mai dese (25 → 70 pe
## secundă), fiecare făcând să sune scurt o rezonanță metalică.
static func _scartait(r: RandomNumberGenerator) -> PackedFloat32Array:
	var s := _gol(0.5)
	var faza_impuls := 0.0
	var de_la_impuls := 1.0
	var ton := 850.0
	for i in s.size():
		var t := float(i) / RATA
		var x := t / 0.5
		faza_impuls += (25.0 + 45.0 * x) / RATA
		if faza_impuls >= 1.0:
			faza_impuls -= 1.0
			de_la_impuls = 0.0
			ton = r.randf_range(780.0, 980.0)
		de_la_impuls += 1.0 / RATA
		var anv := minf(1.0, x * 8.0) * minf(1.0, (1.0 - x) * 6.0)
		s[i] = anv * 0.8 * exp(-de_la_impuls * 90.0) * sin(TAU * ton * de_la_impuls)
	return s


static func _rupt(r: RandomNumberGenerator) -> PackedFloat32Array:
	var s := _gol(0.6)
	var lp := 0.0
	for i in s.size():
		var t := float(i) / RATA
		var n := r.randf_range(-1, 1)
		lp += 0.25 * (n - lp)
		var pocnet := (n - lp) * exp(-t * 70.0)
		var vibrato := 1.0 + 0.04 * sin(TAU * 7.0 * t)
		var coarda := exp(-t * 7.0) * (sin(TAU * 196.0 * vibrato * t) + 0.4 * sin(TAU * 392.0 * vibrato * t))
		s[i] = 0.8 * pocnet + 0.35 * coarda
	return _normalizeaza(s, 0.9)


## Peștele scos din apă: un plescăit lung, apoi stropii care cad înapoi.
static func _stropi(r: RandomNumberGenerator) -> PackedFloat32Array:
	var s := _gol(0.9)
	var lp := 0.0
	for i in s.size():
		var t := float(i) / RATA
		lp += (0.08 + 0.25 * exp(-t * 6.0)) * (r.randf_range(-1, 1) - lp)
		s[i] = 1.6 * lp * exp(-t * 5.0) * minf(1.0, t * 60.0)
	for k in range(9):
		var picatura := _bloop(r, 0.08, r.randf_range(1400, 2600), r.randf_range(700, 1100), 0.015, 70.0, 0.0, 1.0)
		var start := int(r.randf_range(0.12, 0.7) * RATA)
		for i in picatura.size():
			if start + i < s.size():
				s[start + i] += 0.3 * picatura[i]
	return _normalizeaza(s, 0.9)


static func _ciripit(r: RandomNumberGenerator) -> PackedFloat32Array:
	var s := _gol(0.45)
	var note := r.randi_range(2, 3)
	var faza := 0.0
	for i in s.size():
		var t := float(i) / RATA
		var lung := 0.45 / note
		var k := int(t / lung)
		var u := fmod(t, lung) / lung
		var f := 2600.0 + 1400.0 * u + 120.0 * k + 180.0 * sin(TAU * 38.0 * t)
		faza += TAU * f / RATA
		var anv := sin(PI * clampf(u / 0.7, 0.0, 1.0)) if u < 0.7 else 0.0
		s[i] = 0.6 * anv * sin(faza)
	return s


## Apa de la mal: zgomot foarte înăbușit, care se umflă și se strânge de trei
## ori pe buclă (valurile mici), plus câteva clipociri joase.
static func _apa(r: RandomNumberGenerator) -> PackedFloat32Array:
	var durata := 4.0
	var s := _gol(durata + 0.3)
	var lp := 0.0
	var lp2 := 0.0
	for i in s.size():
		var t := float(i) / RATA
		lp += 0.03 * (r.randf_range(-1, 1) - lp)
		lp2 += 0.05 * (lp - lp2)
		var val := 0.55 + 0.45 * sin(TAU * 3.0 * t / durata)
		s[i] = 4.0 * lp2 * val
	for k in range(5):
		var c := _bloop(r, 0.18, r.randf_range(380, 560), r.randf_range(160, 240), 0.05, 22.0, 0.15, 25.0)
		var start := int(r.randf_range(0.1, durata - 0.4) * RATA)
		for i in c.size():
			s[start + i] += 0.25 * c[i]
	return _normalizeaza(_inchide_bucla(s, durata), 0.7)


static func _ploaie(r: RandomNumberGenerator) -> PackedFloat32Array:
	var durata := 3.0
	var s := _gol(durata + 0.3)
	var lp := 0.0
	for i in s.size():
		var n := r.randf_range(-1, 1)
		lp += 0.15 * (n - lp)
		s[i] = 0.35 * (n - lp) + 0.4 * lp
	for k in range(60):
		var start := int(r.randf_range(0.0, durata) * RATA)
		var ton := r.randf_range(2000, 4500)
		for i in int(0.012 * RATA):
			var t := float(i) / RATA
			s[start + i] += 0.25 * exp(-t * 300.0) * sin(TAU * ton * t)
	return _normalizeaza(_inchide_bucla(s, durata), 0.6)


## Doi greieri, cu perioade care încap exact în buclă (0,5 s și 0,8 s în 4 s),
## deci se leagă fără nicio cusătură. Un cântec de greier e un tril: câteva
## impulsuri scurte pe aceeași notă înaltă, apoi tăcere.
static func _greieri() -> PackedFloat32Array:
	var durata := 4.0
	var s := _gol(durata)
	for greier in [[0.5, 4400.0, 3, 0.0], [0.8, 4050.0, 4, 0.21]]:
		var perioada: float = greier[0]
		var ton: float = greier[1]
		var impulsuri: int = greier[2]
		var decalaj: float = greier[3]
		for i in s.size():
			var t := fmod(float(i) / RATA + decalaj, perioada)
			var k := int(t / 0.04)
			if k >= impulsuri:
				continue
			var u := fmod(t, 0.04) / 0.025
			if u > 1.0:
				continue
			s[i] += 0.3 * sin(PI * u) * sin(TAU * ton * float(i) / RATA)
	return s


## Leagă o buclă: ultimele eșantioane de după `durata` se topesc în primele,
## deci sfârșitul curge în început fără pocnet.
static func _inchide_bucla(s: PackedFloat32Array, durata: float) -> PackedFloat32Array:
	var n := int(durata * RATA)
	var f := s.size() - n
	for i in f:
		var x := float(i) / f
		s[i] = s[i] * x + s[n + i] * (1.0 - x)
	s.resize(n)
	return s


static func _netezeste_capetele(s: PackedFloat32Array) -> PackedFloat32Array:
	var f := mini(int(0.004 * RATA), s.size() / 2)
	for i in f:
		s[s.size() - 1 - i] *= float(i) / f
	return s


static func _normalizeaza(s: PackedFloat32Array, varf: float) -> PackedFloat32Array:
	var m := 0.0
	for x in s:
		m = maxf(m, absf(x))
	if m > 0.0:
		for i in s.size():
			s[i] *= varf / m
	return s

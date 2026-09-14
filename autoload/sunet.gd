extends Node
## REGIZORUL DE EFECTE SONORE — fratele lui `Muzica`, dar pentru sunete scurte.
##
## E tot un „autoload" (Project → Project Settings → Autoload), din exact
## aceleași motive ca `Muzica`: trăiește de la pornirea jocului până la
## închiderea lui, supraviețuiește schimbărilor de scenă, și poate fi chemat
## de oriunde cu o singură linie — `Sunet.reda(Sunet.Efect.CORECT)`.
##
## DE CE UN AL DOILEA REGIZOR, ȘI NU O METODĂ ÎN `Muzica`:
## muzica și efectele sunt două lucruri diferite care se ceartă pe același
## difuzor. Muzica e UNA, cântă minute întregi și are nevoie de fade-uri;
## efectele sunt MULTE, durează sub o secundă și trebuie să pornească instant.
## Dacă ar împărți un `AudioStreamPlayer`, un „corect" ar tăia muzica de luptă.
## Două regizoare = două volume reglabile separat, ceea ce e chiar ce ai vrut:
## poți da muzica mai încet fără să faci și verdictul de nedeslușit.

# ─────────────────────────────────────────────────────────────
# REGLAJE
# ─────────────────────────────────────────────────────────────
## Volumul efectelor, în decibeli. 0 = volumul original al fișierelor.
## Decibelii sunt logaritmici, nu procente: -6 dB ≈ jumătate din putere.
##
## Stă deliberat DEASUPRA muzicii (`Muzica.VOLUM_DB`, azi -12 dB): muzica e
## fundal și n-are voie să fie observată conștient, iar verdictul e informație
## și trebuie să treacă peste ea fără efort. Dacă vreodată sunetele acoperă
## muzica sau invers, ăsta e singurul număr de schimbat — e reglajul, nu o
## valoare de calcul, și de-aia e constantă cu nume, nu un număr rătăcit prin
## `reda()`.
const VOLUM_DB := -6.0

## Câte sunete pot cânta ÎN ACELAȘI TIMP.
##
## Un singur `AudioStreamPlayer` poate ține o singură voce: dacă îi ceri un al
## doilea sunet, îl TAIE pe primul în mijloc. Azi n-ar deranja (între două
## verdicte trec secunde), dar prima dată când adaugi un sunet de daune peste
## „corect" — și o să-l adaugi, e chiar următorul pas — s-ar tăia unul pe
## celălalt și ai căuta cauza în fișierul .ogg, nu aici.
##
## 3 voci e un compromis ieftin: trei noduri făcute o dată la pornire, care
## stau tăcute când nu fac nimic. Nu e o coadă și nu e un sistem de
## priorități — dacă toate trei cântă, a patra cerere o fură pe cea mai veche.
const VOCI := 3

# ─────────────────────────────────────────────────────────────
# CATALOGUL DE EFECTE
# Exact ca la `Muzica`: un rând în enum, un rând în tabel, și gata.
# Fișierele lipsă NU sunt o eroare fatală — vezi `_ready()`.
# ─────────────────────────────────────────────────────────────
enum Efect {
	CORECT,
	GRESIT,
}

const EFECTE := {
	Efect.CORECT: "res://assets/audio/correct_answer.ogg",
	Efect.GRESIT: "res://assets/audio/incorrect_answer.ogg",
}

# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
## Sunetele deja încărcate în memorie, indexate după `Efect`.
## Le încărcăm O DATĂ, la pornire, nu la fiecare `reda()`: `load()` citește de
## pe disc, iar o citire de pe disc în mijlocul unei lupte e exact genul de
## mică sacadare care strică sincronizarea cu flash-ul. Fișierele astea au
## zeci de kilobytes — să stea în RAM toată partida nu costă nimic.
var _incarcate := {}

## Difuzoarele. Le rotim pe rând, ca să nu se taie unul pe altul.
var _voci: Array[AudioStreamPlayer] = []
var _voce_urmatoare := 0


func _ready() -> void:
	# Difuzoarele le construim din cod, nu dintr-o scenă: sunt noduri identice,
	# fără nimic de aranjat vizual.
	for i in VOCI:
		var player := AudioStreamPlayer.new()
		player.name = "Voce%d" % i
		player.volume_db = VOLUM_DB
		add_child(player)
		_voci.append(player)

	# Efectele merg și când jocul e pus pe pauză. Nu avem încă pauză, dar când
	# o adaugi n-o să te întrebi de ce a amuțit jumătate de joc.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_incarca_efectele()


## Aduce toate fișierele din catalog în memorie.
##
## `ResourceLoader.exists()` întreabă ÎNAINTE de încărcare, deci un fișier
## lipsă (sau neimportat încă de editor) e un avertisment în consolă și un joc
## care merge mai departe în liniște — nu un crash. Aceeași plasă de siguranță
## ca la `Muzica`: sunetul e decor peste o buclă care trebuie să funcționeze
## și fără el.
func _incarca_efectele() -> void:
	for efect: int in EFECTE:
		var cale: String = EFECTE[efect]
		if not ResourceLoader.exists(cale):
			push_warning("Sunet: lipseste %s — efectul ramane mut." % cale)
			continue

		var stream: AudioStream = load(cale)

		# Un efect scurt NU are voie să se repete la nesfârșit. Importatorul
		# din Godot pune uneori bucla singur pe fișierele .ogg (o face pentru
		# muzică, unde e ce trebuie), iar un „corect" în buclă ar ține ecranul
		# de luptă într-un bâzâit până la sfârșitul partidei. O tăiem explicit,
		# ca să nu depindem de ce-a bifat cineva în panoul de import.
		if "loop" in stream:
			stream.set("loop", false)

		_incarcate[efect] = stream


## Redă un efect din catalog. Sigur de chemat oricând: dacă fișierul lipsește,
## nu se întâmplă nimic.
##
## Pornește ÎN CADRUL în care e chemată — de-asta poate sta lipită de un tween
## vizual și se citește ca un singur moment, nu ca două.
func reda(efect: int) -> void:
	if not _incarcate.has(efect):
		return   # fișier lipsă; avertismentul a fost deja dat la pornire

	# Rotim vocile în cerc. Nu căutăm o voce liberă: căutarea ar face ca două
	# sunete pornite în același cadru să nimerească uneori același difuzor
	# (niciunul n-a apucat să raporteze că e ocupat). Rotația e oarbă, dar
	# garantează că cereri consecutive nimeresc difuzoare diferite.
	var player := _voci[_voce_urmatoare]
	_voce_urmatoare = (_voce_urmatoare + 1) % VOCI

	player.stream = _incarcate[efect]
	# Volumul se rescrie la fiecare redare, nu doar la pornire: așa poți schimba
	# `VOLUM_DB` și îl auzi la reîncărcarea scenei, fără repornirea jocului.
	player.volume_db = VOLUM_DB
	player.play()


## Curățenie la închiderea jocului, ca la `Muzica`: oprim difuzoarele și le
## luăm sunetele din mână.
func _exit_tree() -> void:
	for player: AudioStreamPlayer in _voci:
		player.stop()
		player.stream = null
	_incarcate.clear()

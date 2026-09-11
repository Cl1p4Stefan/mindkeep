extends Node
## REGIZORUL DE MUZICĂ — un singur difuzor pentru tot jocul.
##
## E un „autoload" (Project → Project Settings → Autoload): Godot îl creează
## automat la pornire, îl agață direct sub rădăcina arborelui și îl ține viu
## până închizi jocul. De aceea îl poți chema de oriunde, scriind doar
## `Muzica.reda(...)`, fără să-l instanțiezi și fără să-i cauți nodul.
##
## De ce autoload și nu un AudioStreamPlayer pus în scena de luptă:
## când treci din Cetate în luptă, scena veche e DISTRUSĂ cu tot ce conține.
## Un player din scenă ar muri odată cu ea, iar muzica s-ar tăia brusc și ar
## reporni de la zero la fiecare ecran. Autoload-ul supraviețuiește tuturor
## schimbărilor de scenă, deci poate face tranziții line între piese.

# ─────────────────────────────────────────────────────────────
# REGLAJE
# ─────────────────────────────────────────────────────────────
## Volumul muzicii, în decibeli. 0 = volumul original al fișierului.
## Decibelii sunt logaritmici, nu procente: -6 dB ≈ jumătate din putere,
## -12 dB ≈ un sfert. Muzica de fundal stă deliberat mult sub voce și efecte —
## dacă o observi conștient în timp ce rezolvi un puzzle, e prea tare.
const VOLUM_DB := -12.0

## Cât durează intrarea (și ieșirea) muzicii, în secunde.
const DURATA_FADE := 2.0

## „Practic mut". Godot acceptă până la -80 dB, dar de pe la -60 nu se mai
## aude nimic, iar fade-ul pornește mai firesc dacă nu vine de la infinit.
const VOLUM_TACERE := -60.0

# ─────────────────────────────────────────────────────────────
# CATALOGUL DE PIESE
# Aici adaugi muzica pentru scenele viitoare: un rând în enum, un rând în
# tabel, și gata. Nicio altă modificare de cod, nicăieri.
# Fișierele lipsă NU sunt o eroare fatală — vezi `reda()`.
# ─────────────────────────────────────────────────────────────
enum Piesa {
	LUPTA,
	CETATE,
	HARTA,
}

const PIESE := {
	Piesa.LUPTA: "res://assets/audio/muzica_lupta.ogg",
	Piesa.CETATE: "res://assets/audio/muzica_cetate.ogg",
	Piesa.HARTA: "res://assets/audio/muzica_harta.ogg",
}

# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
var piesa_curenta := -1   # -1 = nu cântă nimic
var player: AudioStreamPlayer
var tween_volum: Tween


func _ready() -> void:
	# Difuzorul îl construim din cod, nu dintr-o scenă: e un singur nod,
	# fără nimic de aranjat vizual, deci un fișier .tscn ar fi doar încă un
	# fișier de ținut minte.
	player = AudioStreamPlayer.new()
	player.name = "Difuzor"
	player.volume_db = VOLUM_TACERE
	add_child(player)

	# Muzica merge mai departe și dacă jocul e pus pe pauză (meniu, pop-up).
	# Nu avem încă pauză, dar când o adaugi n-o să te întrebi de ce s-a oprit.
	process_mode = Node.PROCESS_MODE_ALWAYS


## Curățenie la închiderea jocului: oprim difuzorul și îi luăm piesa din mână.
## NOTĂ: la ieșire Godot raportează oricum „resource still in use" pentru
## fișierul .ogg. E o chestiune de ordine internă la oprirea motorului
## (serverul audio eliberează stream-ul după verificarea de scurgeri), nu o
## scurgere din codul nostru — am verificat că apare și cu difuzorul oprit
## aici. Nu afectează jocul; nu porni în căutarea ei.
func _exit_tree() -> void:
	_opreste_tween()
	player.stop()
	player.stream = null


## Pornește o piesă din catalog. Sigur de chemat de oricâte ori:
## dacă piesa cerută cântă deja, nu se întâmplă nimic — deci poți s-o chemi
## liniștit din `_ready()`-ul fiecărei scene, fără să repornească melodia.
func reda(piesa: int, cu_fade := true) -> void:
	if piesa == piesa_curenta and player.playing:
		return

	if not PIESE.has(piesa):
		push_warning("Muzica: piesa %d nu e in catalog." % piesa)
		return

	var cale: String = PIESE[piesa]

	# Fișierul poate lipsi (încă n-ai compus piesa pentru Cetate).
	# `ResourceLoader.exists()` întreabă ÎNAINTE să încerce încărcarea, deci
	# lipsa unui fișier e o linie în consolă, nu un joc care crapă.
	if not ResourceLoader.exists(cale):
		push_warning("Muzica: lipseste %s — merg mai departe in liniste." % cale)
		opreste()
		return

	var stream: AudioStream = load(cale)

	# Muzica de fundal trebuie să se reia la nesfârșit. Importatorul din Godot
	# o setează de obicei singur, dar o forțăm și aici ca o piesă adăugată
	# mâine, cu alte setări de import, să nu se oprească după 2 minute.
	if "loop" in stream:
		stream.set("loop", true)

	player.stream = stream
	piesa_curenta = piesa
	player.volume_db = VOLUM_TACERE if cu_fade else VOLUM_DB
	player.play()

	if cu_fade:
		_fade_catre(VOLUM_DB, DURATA_FADE)


## Oprește muzica, implicit stingând-o treptat.
func opreste(cu_fade := true) -> void:
	piesa_curenta = -1
	if not player.playing:
		return

	if not cu_fade:
		_opreste_tween()
		player.stop()
		return

	# `finished` se emite când tween-ul termină; abia atunci oprim playerul,
	# altfel am tăia sunetul în mijlocul stingerii.
	var tw := _fade_catre(VOLUM_TACERE, DURATA_FADE)
	tw.finished.connect(player.stop)


## Alunecă volumul către o valoare, în timp. Întoarce tween-ul, ca apelantul
## să se poată agăța de finalul lui dacă are nevoie.
func _fade_catre(db: float, durata: float) -> Tween:
	_opreste_tween()
	tween_volum = create_tween()
	tween_volum.tween_property(player, "volume_db", db, durata)
	return tween_volum


## Oprește un fade aflat în curs. Fără asta, două fade-uri suprapuse ar trage
## de același volum în direcții diferite (intri într-o luptă exact când se
## stingea muzica din Cetate).
func _opreste_tween() -> void:
	if tween_volum != null and tween_volum.is_valid():
		tween_volum.kill()

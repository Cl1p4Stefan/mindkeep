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

## Cât de mult se dă muzica mai încet cât timp e o întrebare pe ecran.
## Negativ = scădere. -9 dB e cam un sfert din putere: muzica nu dispare (ai
## observa golul), dar iese din prim-plan și nu se mai bate cu gândirea ta.
##
## E singurul număr de schimbat dacă atenuarea ți se pare prea slabă sau prea
## brutală. Sub -15 dB începe să sune ca o pană de curent; peste -5 dB nu se
## mai simte deloc.
const ATENUARE_DB := -9.0

## Cât durează coborârea (și urcarea) la atenuare, în secunde.
##
## Mult mai scurt decât `DURATA_FADE`: fade-ul de piesă e o schimbare de
## decor și are voie să dureze, atenuarea e o REACȚIE la o acțiune a ta și
## trebuie să pară cauzată de click. Dar nu zero — o scădere instantanee de
## 9 dB se aude ca un defect al difuzorului, nu ca o intenție.
const DURATA_ATENUARE := 0.3

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
var tween_atenuare: Tween

# ─────────────────────────────────────────────────────────────
# VOLUMUL, ÎN DOUĂ STRATURI
#
# Volumul real al difuzorului NU se scrie nicăieri direct. E întotdeauna suma
# a două valori independente, fiecare cu tween-ul ei:
#
#   volume_db = _volum_baza + _atenuare_db
#
# `_volum_baza` = „cât de tare e piesa asta" — de el trag fade-urile de
# intrare și de ieșire, cele de 2 secunde.
# `_atenuare_db` = „cu cât o dăm mai încet ACUM" — 0 în mod normal,
# `ATENUARE_DB` cât timp e o întrebare pe ecran.
#
# DE CE DOUĂ VALORI ȘI NU UNA. Dacă atenuarea ar trage direct de `volume_db`,
# cele două animații s-ar bate pe aceeași proprietate. Concret: intri în
# luptă, muzica urcă lin timp de 2 s, iar tu apeși un Obelisc la secunda 1 —
# atenuarea ar omorî fade-ul de intrare la mijloc, iar la închiderea panoului
# muzica ar SĂRI la volum plin, pentru că nimeni nu-și mai amintește că
# intrarea nu se terminase. Separate, cele două nu se văd una pe alta:
# intrarea își continuă drumul până la capăt, atenuarea doar o coboară cu 9 dB
# oriunde ar fi ajuns.
#
# `set(...)` de mai jos e un „setter": codul din el rulează de fiecare dată
# când cineva scrie în variabilă — inclusiv un Tween, care scrie în ea de
# ~60 de ori pe secundă. Așa recalculăm suma automat, fără `_process` și fără
# să ne amintim noi să o facem după fiecare modificare.
# ─────────────────────────────────────────────────────────────
var _volum_baza := VOLUM_TACERE:
	set(valoare):
		_volum_baza = valoare
		_aplica_volum()

var _atenuare_db := 0.0:
	set(valoare):
		_atenuare_db = valoare
		_aplica_volum()

## Ce VREM să facă atenuarea, nu unde a ajuns tween-ul chiar acum.
## Fără el, fiecare treaptă nouă de lanț ar reporni fade-ul de coborâre de la
## valoarea curentă — muzica ar tot „respira" între întrebări. Vezi `atenueaza()`.
var _atenuata := false


func _ready() -> void:
	# Difuzorul îl construim din cod, nu dintr-o scenă: e un singur nod,
	# fără nimic de aranjat vizual, deci un fișier .tscn ar fi doar încă un
	# fișier de ținut minte.
	player = AudioStreamPlayer.new()
	player.name = "Difuzor"
	add_child(player)
	# Difuzorul abia s-a născut, deci n-a apucat să fie atins de setere.
	# Îi scriem volumul o dată, de aici, prin aceeași cale ca toți ceilalți.
	_aplica_volum()

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
	if tween_atenuare != null and tween_atenuare.is_valid():
		tween_atenuare.kill()
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
	# Atenuarea NU se resetează aici. Dacă piesa se schimbă cât timp e o
	# întrebare pe ecran (nu se întâmplă azi, dar harta o să poată), noua piesă
	# intră tot atenuată — adică exact ce vrea jucătorul care citește.
	_volum_baza = VOLUM_TACERE if cu_fade else VOLUM_DB
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
		_reseteaza_atenuarea()
		return

	# `finished` se emite când tween-ul termină; abia atunci oprim playerul,
	# altfel am tăia sunetul în mijlocul stingerii.
	var tw := _fade_catre(VOLUM_TACERE, DURATA_FADE)
	tw.finished.connect(player.stop)
	# Piesa moare atenuată; următoarea trebuie să pornească de la zero curat,
	# altfel ar intra deja mai încet cu 9 dB fără ca nimeni să fi cerut asta.
	tw.finished.connect(_reseteaza_atenuarea)


## Alunecă volumul DE BAZĂ către o valoare, în timp. Întoarce tween-ul, ca
## apelantul să se poată agăța de finalul lui dacă are nevoie.
##
## Observă ce tweenuim: `self` și `"_volum_baza"`, nu `player` și
## `"volume_db"`. Tween-ul scrie în variabila noastră, setterul ei recalculează
## suma, și abia acolo ajunge în difuzor. E singurul motiv pentru care
## atenuarea poate trăi peste fade — dacă ambele ar scrie în `volume_db`,
## ultima pornită ar câștiga, iar cealaltă s-ar pierde.
func _fade_catre(db: float, durata: float) -> Tween:
	_opreste_tween()
	tween_volum = create_tween()
	tween_volum.tween_property(self, "_volum_baza", db, durata)
	return tween_volum


## Oprește un fade aflat în curs. Fără asta, două fade-uri suprapuse ar trage
## de același volum în direcții diferite (intri într-o luptă exact când se
## stingea muzica din Cetate).
func _opreste_tween() -> void:
	if tween_volum != null and tween_volum.is_valid():
		tween_volum.kill()


# ─────────────────────────────────────────────────────────────
# ATENUAREA („ducking")
#
# Termenul din audio e „ducking": muzica se dă la o parte când apare ceva mai
# important — la radio, vocea peste melodie; aici, o întrebare peste luptă.
#
# Cine cheamă: DOAR scena de luptă, din `deschide_panou()` și `inchide_panou()`.
# `Muzica` nu știe ce e un puzzle sau un lanț de combo, și e bine că nu știe —
# altfel n-ai mai putea folosi atenuarea și pentru o cinematică din Cetate.
# Ea primește o comandă („mai încet acum") și atât.
#
# AMÂNDOUĂ SUNT SIGURE DE CHEMAT DE ORICÂTE ORI. Asta nu e politețe, e chiar
# cerința din lanțul de combo: între treptele aceluiași lanț panoul rămâne
# deschis și doar conținutul se schimbă, dar codul de luptă trece oricum prin
# aceleași uși. Dacă a doua chemare ar reporni fade-ul, muzica ar tot urca și
# coborî între întrebări — exact zgomotul pe care atenuarea trebuia să-l
# scoată. Flagul `_atenuata` îi taie drumul: a doua chemare nu face nimic.
# ─────────────────────────────────────────────────────────────

## Dă muzica mai încet. Efectele sonore (`Sunet`) NU sunt atinse: au difuzoarele
## lor, cu volumul lor, și tocmai de asta verdictul „corect/greșit" se aude mai
## clar cât timp muzica e trasă în spate.
func atenueaza() -> void:
	if _atenuata:
		return   # deja atenuată (o treaptă nouă în același lanț): n-o mai mișcăm
	_atenuata = true
	_fade_atenuare_catre(ATENUARE_DB)


## Readuce muzica la volumul ei normal.
func restabileste() -> void:
	if not _atenuata:
		return
	_atenuata = false
	_fade_atenuare_catre(0.0)


## Alunecă atenuarea către o valoare. Tween separat de `tween_volum`, ca să
## poată rula peste un fade de piesă fără să-l omoare.
##
## Pornește DE UNDE E ACUM, nu de la capăt: dacă închizi panoul în primele
## 0,1 s de la deschidere (ai apăsat din greșeală), muzica urcă lin înapoi de
## la -3 dB, nu sare întâi la -9.
func _fade_atenuare_catre(db: float) -> void:
	if tween_atenuare != null and tween_atenuare.is_valid():
		tween_atenuare.kill()
	tween_atenuare = create_tween()
	tween_atenuare.tween_property(self, "_atenuare_db", db, DURATA_ATENUARE)


## Scoate atenuarea instantaneu, fără animație. O folosește doar oprirea
## muzicii: acolo nu mai e nimic de auzit, deci n-are ce anima.
func _reseteaza_atenuarea() -> void:
	if tween_atenuare != null and tween_atenuare.is_valid():
		tween_atenuare.kill()
	_atenuata = false
	_atenuare_db = 0.0


## Singurul loc din tot fișierul care scrie în difuzor. Chemat automat de
## seterele celor două straturi, deci nu trebuie chemat de mână nicăieri
## altundeva (excepția e `_ready()`, unde difuzorul tocmai s-a creat).
func _aplica_volum() -> void:
	# Seterele pot fi atinse înainte ca `_ready()` să fi creat difuzorul
	# (inițializarea variabilelor se întâmplă mai devreme). Fără garda asta,
	# jocul ar crăpa la pornire pe un `null`.
	if player == null:
		return
	player.volume_db = _volum_baza + _atenuare_db

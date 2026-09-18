class_name SimbolNod
extends Silueta
## UN NOD DE PE HARTĂ — un simbol de cerneală desenat pe pergament.
##
## Înainte era un `Button` cu chenar și cu textul „⚔ LUPTA" scris în el. Pe un
## fundal negru arăta acceptabil; pe pergament, un dreptunghi gri cu colțuri
## rotunjite e singurul lucru din tot ecranul care strigă „interfață". Harta
## trebuie să pară DESENATĂ pe hârtia aia, nu pusă deasupra ei.
##
## ─────────────────────────────────────────────────────────────
## DE CE MOȘTENEȘTE `Silueta`
##
## `Silueta` (din `scenes/lupta/`) știe deja exact ce-mi trebuie aici:
##   • potrivește o casetă cu proporții corecte în orice cutie primește;
##   • traduce „fracțiuni" (numere între 0 și 1) în pixeli, deci formele de mai
##     jos sunt liste de numere ușor de citit, independente de mărime;
##   • are o respirație pe `sin()`, cu decalaj de pornire.
##
## Respirația aia e, aici, PULSUL nodurilor accesibile. N-am scris nicio linie
## de animație: i-am dat `amplitudine` din tabelul de înfățișări, și gata. Așa
## arată reutilizarea când baza a fost desenată cum trebuie — a doua oară nu
## mai plătești.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU MAI E BUTON
##
## Un `Button` desenează întotdeauna ceva al lui: fond, chenar, stare de hover.
## Se pot goli toate cu StyleBox-uri, dar atunci rămâne un buton care nu mai e
## buton. Un `Control` obișnuit primește mouse-ul la fel de bine (`mouse_entered`,
## `_gui_input`) și desenează EXACT ce-i spun eu.
##
## Ce pierd: focusul cu tastatura. Harta n-a fost niciodată navigabilă cu
## săgețile, deci nu pierd nimic ce aveam.
##
## ─────────────────────────────────────────────────────────────
## CE NU ȘTIE FIȘIERUL ĂSTA
##
## Nu știe ce e o expediție, un PV sau o luptă. Primește „ce tip ești" și „în
## ce stare ești", desenează, și strigă înapoi când e apăsat sau survolat.
## Același contract subțire ca între luptă și disciplinele de puzzle.

## Apăsat — dar numai dacă e un nod în care chiar se poate intra.
signal apasat(id_nod: int)

## Mouse-ul a intrat pe el (`intrat = true`) sau a ieșit. Eticheta cu numele
## nodului o ține harta, nu nodul: o singură etichetă pentru toate nodurile nu
## se poate suprapune cu ea însăși, zece etichete se pot.
signal survolat(id_nod: int, intrat: bool)

## Cele patru stări în care poate fi un nod. NU sunt patru culori — sunt patru
## ROLURI în ierarhia vizuală cerută: unde ești, unde poți merge, pe unde ai
## fost, ce nu ți-e la îndemână.
enum Stare { INCHIS, ACCESIBIL, CURENT, PARCURS }

# ── PALETA DE CERNEALĂ ────────────────────────────────────────
# Toate culorile de aici sunt gândite PE PERGAMENT. Vechile culori ale hărții
# (text deschis, linii palide) erau făcute pentru fundal negru și pe hârtie
# veche pur și simplu dispăreau.

## Cerneala: maro foarte închis, nu negru. Negrul pur pe o textură caldă arată
## lipit deasupra; maro-ul închis arată absorbit în fibră.
const CERNEALA := Color(0.14, 0.09, 0.05)

## Halo-ul din spatele simbolului: o pată de lumină crem. Pergamentul are
## pete, cute și dealuri desenate — fără halo, o sabie neagră peste o umbră
## maro devine o mâzgăleală. Halo-ul nu e decor, e LIZIBILITATE.
##
## Aproape alb, nu crem: pe hârtie deja deschisă, un crem stins nu se vede
## deloc. Ce trebuie să pară e „aici hârtia e curată", nu „aici e o lumină".
const CULOARE_HALOU := Color(1.00, 0.97, 0.90)

## Aura caldă a nodului curent. Singurul lucru de pe hartă care emite lumină.
const CULOARE_AURA := Color(1.00, 0.72, 0.28)

## Cerneala roșie cu care se barează ce-ai lăsat în urmă. Aceeași convenție ca
## pe hărțile din care ne inspirăm: locul vizitat se taie cu un X.
const CULOARE_TAIERE := Color(0.52, 0.14, 0.09)

## Culoarea „găurilor" din simboluri (orbitele craniului, inima flăcării).
## Nu e o culoare de sine stătătoare, e culoarea halo-ului de dedesubt: tăiem
## în simbol ca să se vadă lumina din spatele lui.
const CULOARE_GOL := CULOARE_HALOU

# ── TABELUL DE ÎNFĂȚIȘĂRI ─────────────────────────────────────
# Ierarhia vizuală, ca TABEL, nu ca șir de `if`-uri prin `_draw()`. Un rând pe
# stare; o stare nouă („nod blocat de o cerință") ar fi un rând în plus.
#
#   cerneala   — cât de apăsat e desenat simbolul (opacitate)
#   halou      — cât de aprinsă e pata de lumină din spate
#   raza_halou — cât de mare e ea, ca fracțiune din casetă
#   puls       — cât respiră simbolul (0 = stă nemișcat)
#   aura       — cât de tare arde aura caldă (0 = deloc)
const INFATISARI := {
	Stare.INCHIS:    {"cerneala": 0.38, "halou": 0.30, "raza_halou": 0.32, "puls": 0.000, "aura": 0.0},
	Stare.PARCURS:   {"cerneala": 0.50, "halou": 0.45, "raza_halou": 0.34, "puls": 0.000, "aura": 0.0},
	Stare.ACCESIBIL: {"cerneala": 1.00, "halou": 0.95, "raza_halou": 0.41, "puls": 0.022, "aura": 0.0},
	Stare.CURENT:    {"cerneala": 1.00, "halou": 1.00, "raza_halou": 0.43, "puls": 0.030, "aura": 1.0},
}

## Câte cercuri suprapuse fac halo-ul. Godot n-are „umbră moale" la desen, dar
## cercuri concentrice cu opacitate mică fiecare dau exact aceeași degradare —
## cel mai ieftin gradient din lume. Cu opt straturi se vedeau inelele; cu
## paisprezece, treapta dintre ele scade sub ce distinge ochiul.
const STRATURI_HALOU := 14

## Cât se îngroașă lumina la survolare. Discret: hover-ul confirmă „da, pe ăsta
## îl arăt", nu anunță o schimbare de stare.
const SPOR_HOVER := 0.14

## Aura nodului curent: cât de mare e față de halo, și cât de tare pâlpâie.
const RAZA_AURA := 1.9
const PALPAIRE_AURA := 0.34
const DURATA_AURA := 3.2

var id := -1
var stare := Stare.INCHIS
var tip := 0

## Poate fi apăsat? Doar nodurile accesibile. Ținut separat de `stare` fiindcă
## sunt două întrebări diferite: „cum arăți" și „ce se întâmplă la click".
var activ := false

var _hover := false
## Cheia tipului → funcția care-l desenează. Construit în `_ready()` fiindcă
## un `Callable` către o metodă proprie are nevoie de `self`, iar `self` nu
## există încă la declararea constantelor.
var _desene := {}


func _ready() -> void:
	super()   # `Silueta._ready()`: leagă redimensionarea și pornește ceasul

	# Tabelul de desene, oglinda lui `DATE_NOD` din expediție: un tip de nod nou
	# e un rând aici plus o funcție, nu o ramură nouă prin `_draw()`.
	_desene = {
		Expeditie.Nod.LUPTA: _deseneaza_sabie,
		Expeditie.Nod.ELITA: _deseneaza_craniu,
		Expeditie.Nod.ODIHNA: _deseneaza_foc,
		Expeditie.Nod.EVENIMENT: _deseneaza_intrebare,
	}

	mouse_entered.connect(_pe_intrare)
	mouse_exited.connect(_pe_iesire)


## Tot ce trebuie să știe nodul ca să se deseneze. Un singur apel, cu tot, în
## loc de șase proprietăți puse pe rând din afară: așa nu poate exista un nod
## „pe jumătate configurat" care apucă să se deseneze o dată greșit.
##
## `samanta` vine din nodul de hartă și face două lucruri, amândouă pentru
## aceeași senzație de „desenat de mână": înclină simbolul cu câteva grade și
## decalează pornirea pulsului, ca nodurile să nu respire la unison.
func configureaza(id_nou: int, tip_nou: int, stare_noua: Stare, samanta: int) -> void:
	id = id_nou
	tip = tip_nou
	stare = stare_noua
	activ = stare == Stare.ACCESIBIL

	var infatisare: Dictionary = INFATISARI[stare]

	# Caseta e pătrată: un cerc desenat în ea rămâne cerc, iar `_corectat()`
	# din `Silueta` devine identitatea. Simbolurile de mai jos sunt scrise
	# pentru un pătrat.
	proportie = 1.0
	# Pulsul umflă simbolul din CENTRU, nu de la talpă: nodurile plutesc pe
	# hartă, nu stau pe un sol.
	ancora_y = 0.5
	amplitudine = float(infatisare["puls"])
	durata_respiratie = 2.4

	var rng := RandomNumberGenerator.new()
	rng.seed = samanta
	inclinare = rng.randf_range(-8.0, 8.0)
	decalaj = rng.randf_range(0.0, durata_respiratie)

	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if activ else Control.CURSOR_ARROW
	)

	# Un nod care nu pulsează n-are ce căuta în `_process`. Zece noduri care
	# se redesenează degeaba de 60 de ori pe secundă nu se văd azi, dar e
	# fix genul de risipă care se adună.
	set_process(amplitudine > 0.0 or stare == Stare.CURENT)
	queue_redraw()


# ─────────────────────────────────────────────────────────────
# DESENUL
# ─────────────────────────────────────────────────────────────

## Suprascrie metoda goală din `Silueta`. Ea a pregătit deja caseta, pivotul și
## scara de respirație — aici desenăm doar, în ordinea în care se așază
## straturile: aura, halo-ul, simbolul, bararea.
func _deseneaza_silueta() -> void:
	var infatisare: Dictionary = INFATISARI[stare]
	var spor := SPOR_HOVER if _hover else 0.0

	if float(infatisare["aura"]) > 0.0:
		_deseneaza_aura(float(infatisare["aura"]))

	_deseneaza_halou(
		float(infatisare["raza_halou"]) * (1.06 if _hover else 1.0),
		float(infatisare["halou"]) + spor
	)

	var cerneala := Color(CERNEALA, minf(1.0, float(infatisare["cerneala"]) + spor))
	if _desene.has(tip):
		_desene[tip].call(cerneala)

	if stare == Stare.PARCURS:
		_deseneaza_taietura()


## Halo-ul: cercuri concentrice, de la mare și transparent la mic și dens.
## Opacitățile se ADUNĂ acolo unde cercurile se suprapun, deci centrul iese
## luminos fără ca marginea să aibă un contur vizibil.
func _deseneaza_halou(raza: float, putere: float) -> void:
	if putere <= 0.0:
		return
	for i in range(STRATURI_HALOU):
		var t := float(i) / float(STRATURI_HALOU)
		var raza_strat := lerpf(raza, raza * 0.34, t)
		_cerc_moale(Vector2(0.5, 0.5), raza_strat, Color(CULOARE_HALOU, putere * 0.115))


## Aura nodului curent: aceeași tehnică, mai mare, mai caldă și pâlpâind.
## E singura lumină de pe hartă, deci e și singurul lucru pe care ochiul îl
## găsește fără să caute — exact ce vrei de la „unde sunt acum".
func _deseneaza_aura(putere: float) -> void:
	var palpaire := 1.0 + sin(_timp * TAU / DURATA_AURA) * PALPAIRE_AURA
	var raza := float(INFATISARI[stare]["raza_halou"]) * RAZA_AURA * palpaire
	for i in range(STRATURI_HALOU):
		var t := float(i) / float(STRATURI_HALOU)
		var raza_strat := lerpf(raza, raza * 0.3, t)
		_cerc_moale(Vector2(0.5, 0.5), raza_strat, Color(CULOARE_AURA, putere * 0.032))


## X-ul de pe nodurile prin care ai trecut deja. Nu e „dezactivat" (aia e
## starea ÎNCHIS, estompată) — e „rezolvat". Două lucruri diferite, două
## semne diferite.
func _deseneaza_taietura() -> void:
	var culoare := Color(CULOARE_TAIERE, 0.5)
	_linie(Vector2(0.26, 0.26), Vector2(0.74, 0.74), 0.055, culoare)
	_linie(Vector2(0.74, 0.26), Vector2(0.26, 0.74), 0.055, culoare)


# ─────────────────────────────────────────────────────────────
# SIMBOLURILE
#
# Fiecare e o listă de numere între 0 și 1, în caseta pătrată: 0.5 e mijlocul,
# 0 e sus/stânga, 1 e jos/dreapta. Nu apare niciun pixel — de-aia aceleași
# forme merg și la 84 de pixeli, și la 200, fără să se schimbe nimic.
#
# Sunt desenate în cod DEOCAMDATĂ. Când vine artă adevărată, fiecare funcție
# de aici devine un `draw_texture_rect` — tabelul `_desene` rămâne.
# ─────────────────────────────────────────────────────────────

## LUPTA — o sabie dreaptă, cu vârful în sus.
func _deseneaza_sabie(cerneala: Color) -> void:
	# Proporțiile contează mai mult decât forma: cu lama scurtă și garda lată,
	# sabia se citea drept CRUCE. Lama lungă cât două treimi din simbol și
	# garda strânsă sunt tot ce desparte una de alta.
	_poligon(PackedVector2Array([   # lama, cu vârf ascuțit
		Vector2(0.500, 0.035), Vector2(0.545, 0.160), Vector2(0.548, 0.620),
		Vector2(0.452, 0.620), Vector2(0.455, 0.160),
	]), cerneala)
	_poligon(PackedVector2Array([   # garda
		Vector2(0.325, 0.620), Vector2(0.675, 0.620),
		Vector2(0.675, 0.678), Vector2(0.325, 0.678),
	]), cerneala)
	_poligon(PackedVector2Array([   # mânerul
		Vector2(0.468, 0.678), Vector2(0.532, 0.678),
		Vector2(0.532, 0.872), Vector2(0.468, 0.872),
	]), cerneala)
	_cerc(Vector2(0.500, 0.898), 0.048, cerneala)   # măciulia


## ELITA — un craniu. Orbitele și nara sunt TĂIATE în el, cu culoarea
## halo-ului: o gaură adevărată, nu o pată deschisă pusă deasupra. De-aia
## craniul se citește și peste o cută a pergamentului.
func _deseneaza_craniu(cerneala: Color) -> void:
	_cerc(Vector2(0.500, 0.420), 0.245, cerneala)   # cutia craniană
	_poligon(PackedVector2Array([                   # maxilarul
		Vector2(0.330, 0.540), Vector2(0.670, 0.540),
		Vector2(0.628, 0.800), Vector2(0.372, 0.800),
	]), cerneala)

	var gol := Color(CULOARE_GOL, cerneala.a)
	_cerc(Vector2(0.408, 0.400), 0.078, gol)        # orbite
	_cerc(Vector2(0.592, 0.400), 0.078, gol)
	_poligon(PackedVector2Array([                   # nara
		Vector2(0.500, 0.455), Vector2(0.550, 0.545), Vector2(0.450, 0.545),
	]), gol)
	_linie(Vector2(0.500, 0.620), Vector2(0.500, 0.800), 0.030, gol)   # dinții
	_linie(Vector2(0.420, 0.620), Vector2(0.420, 0.800), 0.030, gol)
	_linie(Vector2(0.580, 0.620), Vector2(0.580, 0.800), 0.030, gol)


## ODIHNA — un foc de tabără: doi bușteni încrucișați și o flacără.
func _deseneaza_foc(cerneala: Color) -> void:
	# Buștenii: două linii groase care se încrucișează. Erau două poligoane
	# aproape orizontale și se citeau ca o singură bară — panta e cea care face
	# X-ul, nu grosimea.
	_linie(Vector2(0.145, 0.700), Vector2(0.855, 0.905), 0.095, cerneala)
	_linie(Vector2(0.855, 0.700), Vector2(0.145, 0.905), 0.095, cerneala)

	_poligon(PackedVector2Array([   # flacăra
		Vector2(0.500, 0.055), Vector2(0.588, 0.230), Vector2(0.558, 0.330),
		Vector2(0.650, 0.430), Vector2(0.660, 0.545), Vector2(0.588, 0.645),
		Vector2(0.412, 0.645), Vector2(0.340, 0.545), Vector2(0.350, 0.430),
		Vector2(0.442, 0.330), Vector2(0.412, 0.230),
	]), cerneala)
	# Inima flăcării, tăiată în ea. Mică: una mare golea flacăra pe dinăuntru
	# și o transforma într-o lalea.
	_poligon(PackedVector2Array([
		Vector2(0.500, 0.430), Vector2(0.552, 0.520), Vector2(0.535, 0.605),
		Vector2(0.465, 0.605), Vector2(0.448, 0.520),
	]), Color(CULOARE_GOL, cerneala.a))


## EVENIMENTUL — un semn de întrebare. Singurul simbol făcut din linii, nu din
## suprafețe: un „?" plin ar arăta a literă tipărită, iar restul hărții e
## desenată cu mâna.
func _deseneaza_intrebare(cerneala: Color) -> void:
	_arc(Vector2(0.500, 0.330), 0.180, 172.0, 392.0, 0.086, cerneala)
	_linie(Vector2(0.656, 0.420), Vector2(0.522, 0.620), 0.086, cerneala)
	_cerc(Vector2(0.500, 0.800), 0.058, cerneala)


# ─────────────────────────────────────────────────────────────
# UNELTE DE DESEN
#
# `Silueta` are deja `_punct`, `_poligon` și `_cerc`. Astea trei completează
# ce-mi lipsea: linii groase, arce și cercuri netezite — toate scrise tot în
# fracțiuni, deci toate se scalează odată cu restul.
# ─────────────────────────────────────────────────────────────

## O linie groasă între două puncte-fracțiune. Grosimea e și ea fracțiune din
## înălțimea casetei, ca să nu rămână de 4 pixeli când nodul crește.
func _linie(de_la: Vector2, la: Vector2, grosime: float, culoare: Color) -> void:
	draw_line(
		_punct(de_la), _punct(la), culoare,
		grosime * _caseta.size.y * _scara, true
	)


## Un arc de cerc, gros. Godot desenează arce din segmente: 24 de pași sunt de
## ajuns cât să nu se vadă colțurile la mărimea unui nod.
func _arc(
	centru: Vector2, raza: float, de_la_grade: float, pana_la_grade: float,
	grosime: float, culoare: Color
) -> void:
	var puncte := PackedVector2Array()
	for i in range(25):
		var unghi := deg_to_rad(lerpf(de_la_grade, pana_la_grade, i / 24.0))
		puncte.append(_punct(centru + Vector2(cos(unghi), sin(unghi)) * raza))
	draw_polyline(puncte, culoare, grosime * _caseta.size.y * _scara, true)


## Un cerc cu marginea netezită. `_cerc` din `Silueta` desenează fără
## antialiasing — pentru siluete e bine (sunt mari), pentru straturile de halo
## se vedeau treptele pe cercul cel mai mare.
func _cerc_moale(centru: Vector2, raza: float, culoare: Color) -> void:
	draw_circle(
		_punct(centru), raza * _caseta.size.y * _scara, culoare,
		true, -1.0, true
	)


# ─────────────────────────────────────────────────────────────
# MOUSE
# ─────────────────────────────────────────────────────────────

func _pe_intrare() -> void:
	_hover = true
	survolat.emit(id, true)
	queue_redraw()


func _pe_iesire() -> void:
	_hover = false
	survolat.emit(id, false)
	queue_redraw()


func _gui_input(eveniment: InputEvent) -> void:
	if not activ:
		return
	if eveniment is InputEventMouseButton:
		var clic := eveniment as InputEventMouseButton
		if clic.button_index == MOUSE_BUTTON_LEFT and clic.pressed:
			# `accept_event()` oprește evenimentul aici. Fără el, clicul ar
			# călători mai departe prin scenă și ar putea fi prins a doua oară.
			accept_event()
			apasat.emit(id)

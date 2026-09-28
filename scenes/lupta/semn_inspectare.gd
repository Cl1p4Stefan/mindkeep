class_name SemnInspectare
extends Button
## SEMNUL „i" DE PE FIGURĂ — și, în același timp, suprafața pe care se apasă.
##
## Cardul inamicului se deschidea până acum dintr-un „[i]" lipit de numele lui,
## sus. Antetul avea de dus trei lucruri deodată (numele, PV-ul și un buton),
## iar când panoul de întrebare îngusta coloana, tot rândul se revărsa peste
## întrebare. Sus au rămas doar PV-ul și sabia; butonul a coborât AICI.
##
## ─────────────────────────────────────────────────────────────
## O ȚINTĂ MARE, UN SEMN MIC
##
## Nodul e un `Button` întins peste toată zona inamicului, dar NU tot nodul e
## țintă: `_has_point()` spune că sunt ale noastre doar SILUETA (pixelii opaci ai
## texturii) și cercul cu „i". Restul dreptunghiului e aer transparent, prin care
## mouse-ul trece mai departe.
##
## Fără asta, hover-ul se aprindea de la doi centimetri distanță de cavaler —
## urcai mouse-ul de pe un Obelisc și figura „răspundea", deși nu erai pe ea. Un
## element care reacționează când nu-l atingi e mai rău decât unul care nu
## reacționează deloc: a doua oară nu mai știi ce anume ai apăsat.
##
## Ce se VEDE rămâne doar cercul mic. Ținta e mai mare decât el (toată silueta),
## fiindcă degetul pe telefon n-are vârf de pixel — dar mai mică decât nodul.
##
## ─────────────────────────────────────────────────────────────
## DE CE SEMNUL NU APARE DOAR LA HOVER
##
## Fiindcă pe telefon nu există hover. Un indiciu care se arată doar când treci
## cu mouse-ul peste el este, pe jumătate din dispozitive, un indiciu care nu
## există — iar atunci figura e clickabilă fără ca nimic să spună asta.
##
## Deci semnul stă pe ecran tot timpul, stins (`opacitate_stins`). La hover sau
## la apăsare se APRINDE, și asta e a doua jumătate a mesajului: primul strat
## spune „aici e ceva", al doilea confirmă „da, pe ăsta apeși". Aprinderea se
## face pe o pantă scurtă, nu dintr-un cadru în altul: o sclipire instantanee
## se citește drept clipire de ecran, nu drept răspuns.
##
## Aprinderea e TOT ce se întâmplă la hover. A existat aici, scurt, și un chenar
## în jurul figurii, ca să arate cât de mare e de fapt ținta de click — dar un
## dreptunghi alb peste arenă se citește drept element de interfață selectat, nu
## drept personaj. Cât de mare e ținta se află oricum apăsând; un chenar care se
## aprinde de fiecare dată când treci mouse-ul prin jumătatea aia de ecran era un
## preț prea mare pentru informația aia.

## Imaginea pe care stă semnul. De la ea vine poziția: nu de la nodul nostru,
## ci de la locul unde cade EFECTIV textura în el (vezi `UmbraContact`).
@export var imagine: NodePath

## Raza cercului, în pixeli logici.
@export var raza := 11.0:
	set(valoare):
		raza = valoare
		queue_redraw()

## Cât intră semnul spre interiorul texturii, din colțul ei din dreapta-sus.
## În pixeli: e o distanță de așezare între două lucruri desenate, ca
## `aer_langa_panou` din `asezare_coloana.gd`, nu o proporție de compoziție.
@export var retragere := Vector2(14.0, 10.0):
	set(valoare):
		retragere = valoare
		queue_redraw()

## Cât de vizibil e semnul în repaus, și cât când e aprins.
## Stins înseamnă „se vede dacă te uiți", nu „se ghicește": sub 0.3 devine o
## murdărie pe ecran, peste 0.5 începe să concureze cu PV-ul de deasupra.
@export_range(0.0, 1.0) var opacitate_stins := 0.38
@export_range(0.0, 1.0) var opacitate_aprins := 1.0

## Culoarea cernelii (cercul și litera). Fundalul cercului e derivat din ea,
## întunecat — un disc care taie figura de dedesubt, ca semnul să se citească
## și peste o armură deschisă, și peste piatră.
@export var culoare := Color(0.88, 0.88, 0.94)

## Cât durează aprinderea și stingerea, în secunde.
const DURATA_APRINDERE := 0.14

## Cât de mult crește cercul când e aprins. Mic intenționat: semnul confirmă,
## nu sare.
const CRESTERE_APRINS := 0.12

## De la ce opacitate încolo un pixel din textură se consideră „figură".
## Nu 0: marginile desenate sunt netezite, iar o bandă de pixeli aproape
## transparenți în jurul armurii ar întinde ținta cu câțiva pixeli de nimic.
const PRAG_ALFA := 0.25

# Cât de aprins e semnul ACUM, între 0 și 1. Se mișcă spre `_tinta` în
# `_process`. O variabilă, nu un `Tween`: starea se poate schimba de mai multe
# ori pe secundă (mouse-ul trece peste figură), iar un tween pornit peste altul
# neterminat ar trebui omorât de mână de fiecare dată.
var _aprindere := 0.0
var _tinta := 0.0


func _ready() -> void:
	# Butonul nu desenează nimic din el însuși: nici fundal, nici chenar de
	# focus. Tot ce se vede vine din `_draw()`. Fără asta, tema ar picta un
	# dreptunghi de hover cât toată figura — exact opusul lui „discret".
	for stare in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(stare, StyleBoxEmpty.new())
	# Fără inel de focus pe un buton cât un sfert de ecran. Tastatura are deja
	# scurtătura „I" (vezi `lupta.gd`), care nu cere ca butonul să fie selectat.
	focus_mode = Control.FOCUS_NONE

	mouse_entered.connect(_pe_hover.bind(true))
	mouse_exited.connect(_pe_hover.bind(false))
	button_down.connect(_pe_hover.bind(true))
	button_up.connect(func() -> void: _pe_hover(is_hovered()))

	resized.connect(queue_redraw)
	var tinta := _imagine()
	if tinta != null:
		# Cutia noastră poate rămâne aceeași în timp ce textura dinăuntru se
		# așază altfel — se schimbă inamicul, se deschide panoul de întrebare
		# și coloanele se îngustează. Semnul trebuie să plece cu ea.
		tinta.item_rect_changed.connect(queue_redraw)

	set_process(false)
	queue_redraw()


func _pe_hover(aprins: bool) -> void:
	_tinta = 1.0 if aprins else 0.0
	# `_process` pornește doar cât durează panta, și se oprește singur când
	# ajunge. Un semn care stă nemișcat nu are de ce să consume un cadru.
	set_process(true)


func _process(delta: float) -> void:
	var pas := delta / DURATA_APRINDERE
	_aprindere = move_toward(_aprindere, _tinta, pas)
	queue_redraw()
	if is_equal_approx(_aprindere, _tinta):
		set_process(false)


func _draw() -> void:
	var desenata := UmbraContact.caseta_desenata(_imagine())
	if desenata.size == Vector2.ZERO:
		return

	var colt := get_global_transform().affine_inverse() * _centrul_semnului(desenata)

	var alfa := lerpf(opacitate_stins, opacitate_aprins, _aprindere)
	var r := raza * (1.0 + CRESTERE_APRINS * _aprindere)

	# Discul de dedesubt: semnul trebuie să se citească și peste o armură
	# deschisă la culoare, și peste piatră. Fără el, un „i" alb pe un coif alb
	# dispare exact la inamicul care are nevoie de card.
	draw_circle(colt, r, Color(0.06, 0.06, 0.09, alfa * 0.72), true, -1.0, true)
	draw_circle(colt, r, Color(culoare, alfa), false, maxf(r * 0.10, 1.0), true)

	# Litera, desenată din două bucăți (punct + bară), nu din `draw_string`.
	# Un „i" de font s-ar fi așezat după linia de bază a fontului, nu după
	# centrul cercului, și ar fi ieșit descentrat pe verticală la orice mărime.
	var font_gros := maxf(r * 0.16, 1.0)
	draw_circle(colt + Vector2(0.0, -r * 0.40), font_gros, Color(culoare, alfa), true, -1.0, true)
	draw_line(
		colt + Vector2(0.0, -r * 0.08),
		colt + Vector2(0.0, r * 0.44),
		Color(culoare, alfa), font_gros * 2.0, true
	)


## Centrul cercului cu „i", în coordonate GLOBALE.
##
## Se agață de colțul din dreapta-sus al TEXTURII, nu al nodului. Între ele sunt
## zeci de pixeli de aer: nodul e întins pe toată coloana, iar imaginea stă
## centrată în el, cât încape întreagă. Un semn pus în colțul nodului ar pluti
## singur undeva lângă figură și s-ar muta la fiecare schimbare de lățime.
func _centrul_semnului(desenata: Rect2) -> Vector2:
	return Vector2(desenata.end.x - retragere.x, desenata.position.y + retragere.y)


## CE E AL NOSTRU ȘI CE NU — folosit de Godot și pentru hover, și pentru click.
##
## Răspunsul e „silueta, plus cercul", nu „dreptunghiul nodului". Ordinea
## verificărilor merge de la ieftin la scump, ca să nu citim un pixel din
## imagine de fiecare dată când mouse-ul trece prin jumătatea asta de ecran.
func _has_point(punct: Vector2) -> bool:
	var img := _imagine()
	var desenata := UmbraContact.caseta_desenata(img)
	if desenata.size == Vector2.ZERO:
		return false
	var global_pct := get_global_transform() * punct

	# CERCUL, primul. El stă peste aer transparent, lângă umărul figurii — deci
	# proba pe alfa de mai jos l-ar respinge tocmai pe el, singurul lucru care
	# se vede. Raza crescută cu `CRESTERE_APRINS` e cea aprinsă: zona de
	# atingere rămâne aceeași și stinsă, altfel semnul s-ar „feri" sub cursor.
	var r := raza * (1.0 + CRESTERE_APRINS)
	if global_pct.distance_to(_centrul_semnului(desenata)) <= r:
		return true

	# Dreptunghiul texturii, al doilea: o respingere ieftină pentru tot aerul
	# din jurul ei, care e cea mai mare parte a nodului.
	if not desenata.has_point(global_pct):
		return false

	# Abia acum pixelul. `poza` e ținută minte pe textură (vezi `_POZE`).
	var poza := _poza(img)
	if poza == null:
		# Fără imagine citibilă rămânem la dreptunghi. Mai generos decât trebuie,
		# dar niciodată mort: un inamic viitor cu o textură comprimată altfel se
		# apasă în continuare, doar cu marginile mai largi.
		return true
	var masura := Vector2(poza.get_size())
	var loc := (global_pct - desenata.position) / desenata.size * masura
	var px := Vector2i(loc.clamp(Vector2.ZERO, masura - Vector2.ONE))
	return poza.get_pixelv(px).a > PRAG_ALFA


## Imaginile deja decomprimate, ca „textura" → `Image`.
##
## `static`, din același motiv ca `_CHENARE` din `asezare_coloana.gd`: doi
## inamici care refolosesc o textură plătesc decomprimarea o singură dată pe tot
## jocul. `get_image()` desface imaginea întreagă în memorie — e o treabă care se
## face la prima atingere, nu la fiecare mișcare de mouse.
static var _POZE := {}

static func _poza(img: TextureRect) -> Image:
	if img == null or img.texture == null:
		return null
	var tex := img.texture
	var cheie := tex.resource_path if not tex.resource_path.is_empty() else str(tex.get_rid())
	if _POZE.has(cheie):
		return _POZE[cheie]

	var poza := tex.get_image()
	# O imagine comprimată (VRAM) n-are pixeli de citit până nu e desfăcută.
	# `decompress()` o poate refuza — de aia întoarcem `null` și nu presupunem.
	if poza != null and poza.is_compressed():
		if poza.decompress() != OK:
			poza = null
	_POZE[cheie] = poza
	return poza


func _imagine() -> TextureRect:
	if imagine.is_empty():
		return null
	return get_node_or_null(imagine) as TextureRect

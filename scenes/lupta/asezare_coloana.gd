class_name AsezareColoana
extends Control
## UNDE STĂ O COLOANĂ DE ARENĂ pe orizontală — și cât de aproape de panou.
##
## Nodul ăsta nu desenează nimic. Primește cutia pe care i-o dă `Arena`
## (`HBoxContainer`) și mută coloana dinăuntru — nume, PV, intenție, figură,
## umbră — la stânga sau la dreapta în ea.
##
## ─────────────────────────────────────────────────────────────
## DOUĂ POZIȚII, O SINGURĂ REGULĂ
##
## Fără panoul de întrebare, figurile stau într-o poziție ALEASĂ: trase spre
## centru cu o fracțiune din lățimea coloanei, cât să nu stea lipite de mobila
## din fundal. E o cifră de compoziție; nu se poate deduce din nimic.
##
## Cu panoul deschis, coloanele se string la jumătate ca să-i facă loc, iar
## poziția aleasă devine greșită: panoul ajunge peste bastonul Regelui și peste
## spada Soldatului. Aici NU mai e loc de o a doua cifră aleasă de mână — una
## potrivită azi ar fi greșită mâine, când un inamic primește o armă mai lată.
##
## Deci regula e o LIMITĂ, nu o a doua poziție: „stai unde ai fost ales, dar
## niciodată mai aproape de panou decât `aer_langa_panou`". Trei câștiguri față
## de o poziție-țintă separată:
##
##   (1) E CONTINUĂ. Panoul se deschide cu o animație, de la lățime zero. O
##       poziție-țintă calculată din marginea panoului ar cere, în prima
##       clipă, o deplasare uriașă — figura ar sări spre centru și s-ar
##       întoarce pe măsură ce panoul crește. Limita mușcă treptat, exact
##       cât trebuie, deci figura alunecă o dată, lin, în afară.
##   (2) N-are nevoie să știe cât de lat AJUNGE panoul. Se uită la cât e acum.
##   (3) Dacă poziția de bază e deja destul de în afară, nu face nimic. O
##       regulă care nu se activează degeaba e o regulă pe care n-o bănuiești
##       când ceva arată ciudat.
##
## ─────────────────────────────────────────────────────────────
## MARGINEA VIZIBILĂ, NU MARGINEA NODULUI
##
## „Cât de aproape de panou" se măsoară de la ultimul pixel care se VEDE, adică
## de la chenarul opac al texturii (`Image.get_used_rect()`), nu de la marginea
## `TextureRect`-ului. Între ele sunt zeci de pixeli de aer transparent, iar
## panoul care se oprește la marginea nodului tot ar acoperi bastonul.
##
## Chenarul se citește O SINGURĂ DATĂ per textură și se ține minte (vezi
## `_CHENARE`). `texture.get_image()` decomprimă imaginea întreagă — e o treabă
## de pornire, nu de cadru, iar aici funcția se cheamă la fiecare pas de
## animație a panoului.

## Coloana care se mută (un `VBoxContainer` ancorat pe toată cutia noastră).
@export var coloana: NodePath

## Imaginea personajului. De la ea vin și proporțiile, și chenarul opac.
@export var imagine: NodePath

## Panoul de întrebare, de care se ferește coloana.
@export var panou: NodePath

## Pe ce parte a coloanei se deschide panoul.
## Regele îl are la dreapta, inamicul la stânga — deci „marginea interioară" a
## fiecăruia e alta, și se ferește în alt sens.
@export var panoul_la_dreapta := true:
	set(valoare):
		panoul_la_dreapta = valoare
		_aseaza()

## POZIȚIA DE BAZĂ: cât se trage coloana spre centru, ca fracțiune din lățimea
## ei. Fracțiune, nu pixeli, ca să însemne același lucru pe orice ecran și în
## orice stare a panoului.
##
## E o cifră de COMPOZIȚIE: nu se deduce din nimic, se alege uitându-te la ecran.
## A crescut de la 0.11 la 0.15 — cam 19 px pe coloană în ecranul logic — fiindcă
## personajele stăteau prea aproape de mobila din margini. Se pune la fel pe
## amândouă coloanele: `panoul_la_dreapta` îi schimbă singur semnul, deci aceeași
## cifră înseamnă „spre centru" și la Rege, și la inamic, iar arena rămâne
## simetrică fără să ții minte două numere.
@export var deplasare_de_baza := 0.15:
	set(valoare):
		deplasare_de_baza = valoare
		_aseaza()

## Cât aer rămâne între marginea vizibilă a personajului și panou.
##
## În pixeli, nu în fracțiuni, și intenționat: e o distanță de ATINGERE între
## două lucruri desenate, nu o proporție de compoziție. Proiectul desenează
## într-un ecran logic fix (1152×648) pe care îl scalează la fereastră, deci
## pixelul de aici se mărește odată cu tot restul.
@export var aer_langa_panou := 12.0:
	set(valoare):
		aer_langa_panou = valoare
		_aseaza()

## Chenarele opace deja calculate, ca „textura" → dreptunghi în FRACȚIUNI din
## mărimea texturii. Static: cele două coloane și orice inamic viitor care
## refolosește o textură plătesc decomprimarea o singură dată pe tot jocul.
static var _CHENARE := {}

## Sub cât nu merită rescrise marginile. Fără pragul ăsta, scrierea ar declanșa
## o reașezare, care ar declanșa semnalul, care ar rescrie marginile — un
## du-te-vino de rotunjiri care nu se termină.
const PRAG_MISCARE := 0.5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_aseaza)
	var p := _panou()
	if p != null:
		# Panoul se deschide cu o animație pe lățime: fiecare cadru al ei e o
		# schimbare de dreptunghi, deci limita se recalculează exact de câte ori
		# trebuie și niciodată degeaba.
		p.item_rect_changed.connect(_aseaza)
		p.visibility_changed.connect(_aseaza)
	var img := _imagine()
	if img != null:
		img.item_rect_changed.connect(_aseaza)
	_aseaza()


func _aseaza() -> void:
	var col := get_node_or_null(coloana) as Control
	if col == null or size.x <= 0.0:
		return

	var semn := 1.0 if panoul_la_dreapta else -1.0
	var deplasare := deplasare_de_baza * size.x * semn
	deplasare = _limiteaza(col, deplasare)

	if absf(col.offset_left - deplasare) < PRAG_MISCARE:
		return
	col.offset_left = deplasare
	col.offset_right = deplasare


## Împinge deplasarea în afară, dacă poziția cerută ar băga personajul sub panou.
## Întoarce deplasarea nemodificată dacă panoul e închis sau destul de departe.
##
## „Închis" se citește din LĂȚIME, nu din `visible`: panoul nu se mai ascunde
## niciodată (s-ar fi schimbat brusc așezarea Arenei la finalul animației, iar
## figurile ar fi sărit câțiva pixeli după ce terminau de alunecat). Stinge
## din opacitate și rămâne în șir cu lățime zero — iar zero e exact cazul pe
## care linia de mai jos îl lăsa dintotdeauna să treacă nemodificat.
func _limiteaza(col: Control, deplasare: float) -> float:
	var p := _panou()
	if p == null or not p.is_visible_in_tree() or p.size.x <= 0.0:
		return deplasare

	var desen := _caseta_desenata(col)
	if desen.size.x <= 0.0:
		return deplasare
	var chenar: Rect2 = _chenar()

	if panoul_la_dreapta:
		# Marginea interioară e cea din DREAPTA desenului; panoul începe la
		# stânga lui. Deplasarea are voie să fie cel mult atât cât duce
		# marginea fix la limită.
		var margine := desen.position.x + desen.size.x * chenar.end.x
		var limita := p.global_position.x - aer_langa_panou
		return minf(deplasare, limita - margine)

	var margine_st := desen.position.x + desen.size.x * chenar.position.x
	var limita_st := p.global_position.x + p.size.x + aer_langa_panou
	return maxf(deplasare, limita_st - margine_st)


## Unde ar cădea textura dacă deplasarea ar fi ZERO.
##
## Se pornește de la dreptunghiul de acum al imaginii și se scade deplasarea
## aplicată — așa nu trebuie refăcută toată socoteala containerelor, și rezultatul
## e un punct fix: a doua chemare dă același răspuns ca prima.
func _caseta_desenata(col: Control) -> Rect2:
	var img := _imagine()
	if img == null or img.texture == null:
		return Rect2()
	var cutie := img.get_global_rect()
	cutie.position.x -= col.offset_left
	var tex := Vector2(img.texture.get_size())
	if tex.x <= 0.0 or tex.y <= 0.0:
		return Rect2()
	# „Păstrează proporția, centrat": scara e minimul, restul cutiei e aer.
	var scara := minf(cutie.size.x / tex.x, cutie.size.y / tex.y)
	return Rect2(cutie.position + (cutie.size - tex * scara) * 0.5, tex * scara)


## Chenarul opac al texturii, în fracțiuni. Calculat o dată, apoi ținut minte.
func _chenar() -> Rect2:
	var img := _imagine()
	var tex := img.texture
	var cheie := tex.resource_path if not tex.resource_path.is_empty() else str(tex.get_rid())
	if _CHENARE.has(cheie):
		return _CHENARE[cheie]

	var intreg := Rect2(0.0, 0.0, 1.0, 1.0)
	var poza := tex.get_image()
	if poza != null:
		var folosit := poza.get_used_rect()
		var m := Vector2(tex.get_size())
		if folosit.size.x > 0 and m.x > 0.0 and m.y > 0.0:
			intreg = Rect2(
				folosit.position.x / m.x, folosit.position.y / m.y,
				folosit.size.x / m.x, folosit.size.y / m.y
			)
	_CHENARE[cheie] = intreg
	return intreg


func _imagine() -> TextureRect:
	return get_node_or_null(imagine) as TextureRect


func _panou() -> Control:
	return get_node_or_null(panou) as Control


## Marginea vizibilă dinspre panou, în coordonate de ecran. Nu o folosește
## nimeni din joc — e pentru `tools/verificari/verifica_podeaua.gd`, ca verificarea să
## întrebe nodul unde crede EL că e marginea, în loc să refacă socoteala pe
## cont propriu și să confirme o greșeală cu o copie a ei.
func margine_interioara() -> float:
	var col := get_node_or_null(coloana) as Control
	if col == null:
		return 0.0
	var desen := _caseta_desenata(col)
	if desen.size.x <= 0.0:
		return 0.0
	var chenar: Rect2 = _chenar()
	var fractie := chenar.end.x if panoul_la_dreapta else chenar.position.x
	return desen.position.x + desen.size.x * fractie + col.offset_left

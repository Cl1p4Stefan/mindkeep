class_name PlansaReflex
extends Control
## PLANȘA REFLEXULUI: semne AȘEZATE, fără celule.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU E `PlansaSpatiala`
##
## Reținerea (a șaptea) a folosit chiar desenatorul Spațialului, și bine a
## făcut: caroiajul ei ERA un caroiaj. Aici întrebarea e alta, și de-aia
## răspunsul e altul.
##
## La Spațial, poziția unui semn e un NUMĂR DE CELULĂ: „linia 2, coloana 3". Ea
## e ce se întreabă, iar celulele desenate sunt chiar sistemul de coordonate
## care face întrebarea posibilă. Aici poziția nu e o coordonată, e CONȚINUT:
## cuvântul „SUS" scris jos nu stă în „linia 3, coloana 2", stă JOS — și dacă ar
## sta într-o celulă desenată, întrebarea „unde e scris?" ar avea deodată două
## răspunsuri, unul dintre ele spațial. Adică ar fi o întrebare de Spațial.
##
## Deci planșa asta NU desenează niciun chenar. Un semn are un loc în casetă,
## dat în fracțiuni, și nimic nu-l încadrează. Asta e și toată deosebirea de
## cod: `PlansaSpatiala` primește `linii`, `coloane` și celule; asta primește o
## casetă și o listă de semne cu `x` și `y` între 0 și 1.
##
## ─────────────────────────────────────────────────────────────
## CUM SE DESCRIE O PLANȘĂ
##
## Un dicționar de DATE pure, fără noduri — aceeași despărțire ca la Spațial, și
## pentru același motiv (vezi `_plansa_pentru` din `puzzle.gd`: nodul se naște o
## dată, pentru întrebarea aleasă, iar datele le poate citi și verificarea, fără
## să deschidă o fereastră):
##
##   {
##     "lat": 300, "inalt": 90,
##     "semne": [
##       {"x": 0.5, "y": 0.18, "fel": "text",    "text": "SUS", "marime": 20},
##       {"x": 0.2, "y": 0.50, "fel": "sageata", "incotro": "dreapta", "marime": 26},
##       {"x": 0.8, "y": 0.50, "fel": "forma",   "forma": "cerc", "marime": 34},
##     ]
##   }
##
## `x` și `y` sunt fracțiuni din casetă (0 = stânga / sus, 1 = dreapta / jos) și
## arată CENTRUL semnului, nu colțul lui. Fracțiuni, și nu pixeli, din același
## motiv pentru care formele din `glifa_sah.gd` sunt fracțiuni: un tipar scrie
## „la mijloc, jos" o dată și rămâne adevărat dacă mâine caseta se mărește.
##
## TREI FELURI DE SEMN, și nimic altceva:
##   „text"    — un cuvânt sau o cifră, de mărimea cerută;
##   „sageata" — un vârf și o coadă, întoarse în una din cele patru direcții;
##   „forma"   — un CONTUR (cerc, pătrat, triunghi, romb).
##
## Formele sunt contururi, nu pete pline, și asta nu e o preferință: tipul
## FORMELE scrie un cuvânt ÎNĂUNTRUL unei forme, iar într-o pată plină cuvântul
## n-ar încăpea. Un semn „forma" și un semn „text" cu același `x` și `y` sunt
## tocmai asta — iar planșa nu știe că merg împreună, ceea ce e tot ce trebuie
## ca următorul tipar să le poată pune oriunde altundeva.
##
## ─────────────────────────────────────────────────────────────
## O SINGURĂ CULOARE, ȘI DE CE ASTA E O DECIZIE
##
## Stroop-ul canonic e cu culori: cuvântul „ROSU" scris cu cerneală verde. Aici
## nu, și nu dintr-o lipsă de pricepere la desen.
##
## Verdele și roșul sunt deja CULORI DE VERDICT în scena asta (`CULOARE_BUN`,
## `CULOARE_RAU` din `puzzle.gd`) — de-aia roșul n-a putut fi culoarea niciunei
## discipline, și de-aia nici caroiajul Spațialului nu le folosește. O
## disciplină care și-ar scrie conținutul CHIAR în cele două culori prin care
## jocul spune „bine" și „greșit" ar învăța ochiul exact pe dos: ai vedea roșu
## într-o întrebare la care încă n-ai răspuns.
##
## Interferența n-are nevoie de culoare. Un cuvânt se bate la fel de bine cu
## LOCUL lui, cu CÂTE ori e scris, cu MĂRIMEA cu care e desenat și cu FORMA în
## care stă — și toate patru se desenează cu o singură cerneală. Vezi antetul
## lui `reflex.gd` pentru cele patru tipuri care ies din asta.

# Cerneala. Una singură, vezi mai sus. O temă pusă deasupra scenei o poate
# înlocui, sub tipul „Puzzle", exact ca la Spațial: cheia e `plansa_litera`,
# aceeași, fiindcă e aceeași întrebare („cu ce culoare se scrie pe planșă?") și
# ar fi fost o ciudățenie ca pergamentul din Practice să trebuiască s-o
# răspundă de două ori.
const CULOARE_SEMN := Color(0.92, 0.94, 1.0)

# Grosimea conturului unei forme. 2 px, din același motiv ca la Spațial: la
# 1 px laturile cad între pixeli când fereastra se redimensionează, iar un
# pătrat cu laturi inegale se citește ca un desen stricat — și aici ar fi mai
# rău, fiindcă forma e CHIAR răspunsul.
const GROSIME := 2.0

# Cât de mare e caseta, cel mult. Nu sunt preferințe, sunt limitele panoului:
# înălțimea e măsurată ca la Spațial (panoul are ~400 px, din care antetul,
# bara, enunțul și cele patru butoane iau ~300), iar lățimea e cu mult sub cei
# ~600 px pe care-i are panoul în luptă — o planșă lată ar împinge ochiul în
# lături tocmai într-o disciplină în care tot rostul e să te uiți la un loc.
#
# De-aia tiparele din `reflex.gd` nu cer niciodată mai mult de atât. Limita e
# AICI, în pixeli, nu acolo, în dificultate.
const LAT_MAXIM := 340.0
const INALT_MAXIM := 96.0

var lat := 100.0
var inalt := 40.0
## Semnele, ca mai sus. Se scriu ÎNAINTE de `add_child`, prin `din_date()`.
var semne: Array = []


## Fabrica. Primește datele din întrebare și întoarce nodul gata măsurat.
##
## `custom_minimum_size` se pune AICI, nu în `_draw`, exact ca la Spațial: cutia
## din `puzzle.gd` e un `CenterContainer`, iar el așază copilul după mărimea lui
## minimă. Un nod care și-ar afla mărimea abia la desenare ar fi centrat ca un
## nod de mărime zero.
static func din_date(date: Dictionary) -> PlansaReflex:
	var plansa := PlansaReflex.new()
	plansa.lat = clampf(float(date.get("lat", 100.0)), 1.0, LAT_MAXIM)
	plansa.inalt = clampf(float(date.get("inalt", 40.0)), 1.0, INALT_MAXIM)
	plansa.semne = date.get("semne", [])
	plansa.custom_minimum_size = Vector2(plansa.lat, plansa.inalt)
	# Planșa nu e un buton: nu prinde clickuri și nu le fură butoanelor de sub
	# ea. `IGNORE` lasă mouse-ul să treacă prin ea.
	plansa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return plansa


func _draw() -> void:
	var font := get_theme_default_font()
	var cerneala := _culoare("plansa_litera", CULOARE_SEMN)

	for semn in semne:
		var centru := Vector2(
			float(semn.get("x", 0.5)) * lat, float(semn.get("y", 0.5)) * inalt
		)
		var marime := float(semn.get("marime", 20.0))
		match String(semn.get("fel", "text")):
			"text":
				_scrie(font, centru, String(semn.get("text", "")), marime, cerneala)
			"sageata":
				_sageata(centru, String(semn.get("incotro", "dreapta")), marime, cerneala)
			"forma":
				_forma(centru, String(semn.get("forma", "cerc")), marime, cerneala)


## Un text CENTRAT pe punctul dat, pe amândouă axele.
##
## `draw_string` primește punctul de BAZĂ al textului (unde stau picioarele
## literelor), nu colțul de sus — de-aia centrarea pe verticală se face cu
## `ascent`, nu cu jumătate din înălțimea rândului. Aceeași socoteală ca la
## litera din celula Spațialului, și scrisă a doua oară fiindcă acolo era legată
## de o celulă: aici nu există celulă.
func _scrie(font: Font, centru: Vector2, text: String, marime: float, culoare: Color) -> void:
	if text == "" or font == null:
		return
	var marime_int := int(marime)
	var lat_text := font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, marime_int
	).x
	var baza := Vector2(
		centru.x - lat_text * 0.5,
		centru.y + font.get_ascent(marime_int) * 0.5
	)
	draw_string(font, baza, text, HORIZONTAL_ALIGNMENT_LEFT, -1, marime_int, culoare)


## O SĂGEATĂ: coadă plus vârf, întoarsă într-una din cele patru direcții.
##
## Construită întâi într-un pătrat de latură 1 cu centrul în origine și cu
## vârful spre DREAPTA, apoi rotită. Două poligoane, amândouă CONVEXE — aceeași
## grijă ca la clepsidra din `glifa_sah.gd`: o săgeată dintr-o singură bucată e
## concavă (se îngustează la gât), iar `draw_colored_polygon` ar trebui s-o
## taie singur în triunghiuri. Până la proba contrarie o taie bine, dar „până la
## proba contrarie" nu e un verdict, iar aici nu e nimic de câștigat: o coadă
## dreptunghiulară și un triunghi n-au nimic de dedus.
##
## Săgeata e lată de tot atât cât e înaltă, deci `marime` e latura pătratului.
func _sageata(centru: Vector2, incotro: String, marime: float, culoare: Color) -> void:
	var unghi := UNGHIURI.get(incotro, 0.0) as float
	var coada := PackedVector2Array()
	for punct in SAGEATA_COADA:
		coada.append(centru + punct.rotated(unghi) * marime)
	var varf := PackedVector2Array()
	for punct in SAGEATA_VARF:
		varf.append(centru + punct.rotated(unghi) * marime)
	draw_colored_polygon(coada, culoare)
	draw_colored_polygon(varf, culoare)


## O FORMĂ, ca CONTUR. Vezi antetul: înăuntrul ei încape un cuvânt.
##
## `marime` e lățimea formei, nu raza — ca o cifră și un cerc cerute la aceeași
## mărime să iasă la fel de mari pe ecran.
func _forma(centru: Vector2, forma: String, marime: float, culoare: Color) -> void:
	var jumatate := marime * 0.5
	match forma:
		"cerc":
			# `draw_arc` cu 48 de segmente, nu `draw_circle`: cel din urmă
			# desenează un DISC plin, iar aici ne trebuie conturul.
			draw_arc(centru, jumatate, 0.0, TAU, 48, culoare, GROSIME)
		"patrat":
			draw_rect(
				Rect2(centru - Vector2(jumatate, jumatate), Vector2(marime, marime)),
				culoare, false, GROSIME
			)
		_:
			# Triunghiul și rombul sunt amândouă liste de vârfuri, deci un
			# singur drum de desenare: conturul se închide la sfârșit.
			var puncte := VARFURI.get(forma, VARFURI["triunghi"]) as PackedVector2Array
			var contur := PackedVector2Array()
			for punct in puncte:
				contur.append(centru + punct * marime)
			contur.append(contur[0])
			draw_polyline(contur, culoare, GROSIME)


# ─────────────────────────────────────────────────────────────
# FORMELE, ÎN FRACȚIUNI DE LATURĂ
#
# Toate sunt scrise într-un pătrat cu centrul în (0,0) și latura 1, deci merg
# de la -0,5 la 0,5. Se înmulțesc cu `marime` la desenare. Aceeași convenție ca
# la glifele Obeliscurilor, doar cu originea mutată la mijloc: acolo un semn e
# așezat în casetă, aici e așezat în jurul unui PUNCT.
#
# DE CE `static var` ȘI NU `const`: GDScript acceptă drept constantă doar o
# expresie pe care o poate calcula la citirea fișierului, iar
# `PackedVector2Array([...])` e o CHEMARE de funcție. Aceeași însemnare ca la
# formele din `glifa_sah.gd` — și aceeași urmare: se calculează o dată pentru
# tot jocul, nu o dată pe planșă.
# ─────────────────────────────────────────────────────────────

# Coada săgeții, cu vârful spre dreapta. Nu ajunge până în vârf (se oprește la
# 0,08): dincolo de acolo începe triunghiul, iar o coadă care intră în el ar
# îngroșa vârful pe dinăuntru fără să se vadă de ce.
static var SAGEATA_COADA := PackedVector2Array([
	Vector2(-0.50, -0.11), Vector2(0.08, -0.11),
	Vector2(0.08, 0.11), Vector2(-0.50, 0.11),
])

# Vârful. Lat de 0,76 din latură, adică mult mai lat decât coada: la 26 px un
# vârf îngust se citește ca o linie, iar direcția e tot ce se întreabă.
static var SAGEATA_VARF := PackedVector2Array([
	Vector2(0.08, -0.38), Vector2(0.50, 0.00), Vector2(0.08, 0.38),
])

# Rotația, pe direcție. Ecranul are y în JOS, deci „jos" e un sfert de tură
# POZITIV — scris aici o dată, ca niciun tipar să nu trebuiască să-și amintească
# încotro se învârte lumea.
static var UNGHIURI := {
	"dreapta": 0.0,
	"jos": PI * 0.5,
	"stanga": PI,
	"sus": PI * 1.5,
}

# Vârfurile formelor care nu sunt nici cerc, nici pătrat.
#
# Triunghiul e ISOSCEL cu vârful în sus, nu echilateral: un triunghi
# echilateral înscris într-un pătrat lasă colțurile de jos în afara lui, iar
# atunci o literă scrisă în mijloc ar ieși prin latura de jos.
static var VARFURI := {
	"triunghi": PackedVector2Array([
		Vector2(0.00, -0.50), Vector2(0.50, 0.44), Vector2(-0.50, 0.44),
	]),
	"romb": PackedVector2Array([
		Vector2(0.00, -0.50), Vector2(0.50, 0.00),
		Vector2(0.00, 0.50), Vector2(-0.50, 0.00),
	]),
}


## Culoarea din temă, dacă tema o dă; altfel cea implicită. Aceeași funcție ca
## `_culoare()` din `puzzle.gd` și din planșa Spațialului, și pe același tip
## („Puzzle"): planșa e o bucată din scena de puzzle, nu un desen de-al ei.
func _culoare(nume: String, implicita: Color) -> Color:
	if has_theme_color(nume, "Puzzle"):
		return get_theme_color(nume, "Puzzle")
	return implicita

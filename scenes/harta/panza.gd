extends Control
## PÂNZA — desenează DRUMURILE dintre nodurile hărții, și doar atât.
##
## Nodurile sunt `Control`-uri desenate (`simbol_nod.gd`), copii ai acestui
## Control. Ce nu se poate face cu ele sunt LEGĂTURILE dintre ele: un container
## nu desenează legături, iar o legătură nu e un nod de interfață — e o relație
## între două.
##
## ─────────────────────────────────────────────────────────────
## DE CE UN FIȘIER SEPARAT PENTRU O MÂNĂ DE LINII DE COD
##
## Fiindcă `_draw()` e o funcție specială: Godot o cheamă când nodul trebuie
## redesenat, iar ea are voie să deseneze DOAR atunci. Dacă ar sta în
## `harta.gd`, harta ar trebui să fie ea însăși un Control desenabil, iar
## desenul s-ar amesteca cu logica de expediție.
##
## Așa, `harta.gd` spune „astea sunt drumurile" și uită de ele; pânza nu știe
## ce e un nod de expediție, un PV sau o luptă.
##
## ─────────────────────────────────────────────────────────────
## DE CE PUNCTATE ȘI CURBE, ȘI NU SEGMENTE DREPTE
##
## O linie dreaptă și subțire între două dreptunghiuri arată a diagramă: spune
## „nodul A e legat de nodul B". Un șir de liniuțe care se îndoaie spune
## „de-aici se MERGE acolo" — e un drum pe un teren, cu tot cu ocolișul lui.
## Aceeași informație, altă poveste, și costă douăzeci de linii de cod.
##
## ─────────────────────────────────────────────────────────────
## CURBURA NU MAI VINE DIN SĂMÂNȚĂ. VINE DIN GEOMETRIE.
##
## Înainte, fiecare drum primea din `harta.gd` un număr „curbura", tras la sorți
## din semințele celor două noduri, și se îndoia PERPENDICULAR pe segment, cu
## atât. Arăta bine luat drum cu drum, și prost luat harta întreagă: două drumuri
## între aceleași două straturi puteau primi îndoituri în direcții opuse, iar
## atunci se tăiau unul pe altul chiar dacă nodurile stăteau în ordine.
##
## Acum forma e FIXĂ și aceeași pentru toate: un „S" care pleacă orizontal din
## nodul din stânga și intră orizontal în cel din dreapta. Nu mai există niciun
## zar în desen — un drum arată la fel de câte ori l-ai redesena, iar două
## drumuri care pleacă în ordine ajung în ordine.
##
## De ce un S nu poate tăia alt S: forma merge MONOTON de la stânga la dreapta
## (x-ul crește tot timpul, fiindcă și cele două puncte de control stau între
## capete pe orizontală). Un drum monoton e, pentru fiecare x, exact un y. Două
## drumuri între aceleași straturi pornesc de pe aceeași verticală și ajung pe
## aceeași verticală; dacă la stânga unul e deasupra celuilalt ȘI la dreapta
## tot deasupra, cele două șiruri de y nu au cum să se întâlnească la mijloc —
## ar însemna să se inverseze și apoi să se inverseze la loc, adică să se taie
## de două ori. Verificarea din `tools/verifica_harta.gd` numără exact asta.

## Lungimea unei liniuțe și a pauzei dintre ele, în pixeli.
##
## Erau 9 și 7,5, cu linii de 5 pixeli grosime: la distanța de la care te uiți
## la hartă, ieșea un punctat mărunt care se pierdea în textura hârtiei. Acum
## sunt liniuțe LATE și rare — la fel ca pe hărțile de aventură desenate de
## mână, unde drumul e făcut din trăsături, nu din puncte.
const LUNGIME_LINIUTA := 15.0
const PAUZA_LINIUTA := 11.0

## Cât de des măsurăm curba. Mai mic = liniuțe mai exacte, mai multe apeluri de
## desen. 2 pixeli e sub pragul la care s-ar vedea diferența.
const PAS_ESANTION := 2.0

## CÂT DE TARE SE ÎNDOAIE S-UL, ca fracțiune din distanța dintre capete.
##
## `INTINDERE` (0,5) spune cât de departe pe ORIZONTALĂ pleacă punctele de
## control: exact la jumătatea drumului. E ce face capetele să iasă și să intre
## orizontal, ca șinele unui macaz.
##
## `INCLINARE` (0,15) le dă o mică împingere și pe VERTICALĂ, în sensul în care
## merge drumul. Fără ea, un drum care urcă mult ar avea un mijloc aproape
## vertical — o cotitură bruscă în loc de un S. Cu ea, îndoitura se întinde.
##
## Amândouă sunt constante, nu zaruri: vezi nota de mai sus.
const INTINDERE := 0.5
const INCLINARE := 0.15

## Cât lăsăm liber la capete dacă drumul nu spune singur. Numărul adevărat vine
## din hartă, în câmpul „oprire" al fiecărei muchii: ea știe cât de mare e un
## nod, pânza nu. Constanta de aici e doar plasa pentru o muchie venită fără el.
const OPRIRE_IMPLICITA := 48.0

var muchii: Array[Dictionary] = []


## Primește drumurile și cere o redesenare.
##
## `queue_redraw()` NU desenează pe loc — pune nodul la coadă pentru cadrul
## următor. De-aia e ieftin s-o chemi de mai multe ori într-o funcție: zece
## apeluri înseamnă tot un singur desen.
func arata(muchii_noi: Array[Dictionary]) -> void:
	muchii = muchii_noi
	queue_redraw()


func _draw() -> void:
	for muchie in muchii:
		_deseneaza_drum(muchie)


## Un drum punctat, în formă de S.
func _deseneaza_drum(muchie: Dictionary) -> void:
	var de_la: Vector2 = muchie["de_la"]
	var la: Vector2 = muchie["la"]
	var culoare: Color = muchie["culoare"]
	var grosime := float(muchie["grosime"])

	# Lungimea curbei, aproximată prin poligonul de control (capete + cele două
	# puncte de control). E puțin mai mare decât lungimea adevărată, ceea ce
	# înseamnă doar câteva eșantioane în plus — exact greșeala pe care ți-o
	# permiți.
	var c1 := _control_1(de_la, la)
	var c2 := _control_2(de_la, la)
	var lungime := (de_la.distance_to(c1) + c1.distance_to(c2) + c2.distance_to(la))
	var esantioane := maxi(16, int(lungime / PAS_ESANTION))
	var pas := LUNGIME_LINIUTA + PAUZA_LINIUTA

	# Cât de departe de fiecare capăt începe și se termină punctatul. Trimis de
	# hartă odată cu muchia: drumul trebuie să se OPREASCĂ vizibil înainte de
	# simbol, altfel pare că trece pe sub el.
	var oprire := float(muchie.get("oprire", OPRIRE_IMPLICITA))
	# Un drum mai scurt decât cele două opriri puse cap la cap n-ar avea ce
	# desena. Se întâmplă la două noduri apropiate de abaterea organică: fără
	# linia asta, muchia ar dispărea cu totul și s-ar vedea ca un drum lipsă.
	var capete := de_la.distance_to(la)
	if capete < oprire * 2.4:
		oprire = capete * 0.34

	var parcurs := 0.0
	var anterior := de_la
	for i in range(1, esantioane + 1):
		var punct := punct_pe_drum(de_la, la, float(i) / esantioane)
		parcurs += anterior.distance_to(punct)

		# Liniuță sau pauză? Poziția pe drum, împărțită la pas, decide singură —
		# fără să numărăm liniuțe și fără să știm câte încap.
		var e_liniuta := fmod(parcurs, pas) < LUNGIME_LINIUTA
		var langa_capat := (
			punct.distance_to(de_la) < oprire or punct.distance_to(la) < oprire
		)
		if e_liniuta and not langa_capat:
			draw_line(anterior, punct, culoare, grosime, true)

		anterior = punct


## Un punct de pe drumul dintre două noduri, la fracțiunea `t` (0 = start,
## 1 = capăt).
##
## E `static` ca să poată fi chemată din verificarea headless: acolo drumul
## trebuie transformat în linie frântă și tăiat cu celelalte, fără să existe
## vreo pânză pe ecran. Aceeași funcție desenează și verifică, deci verificarea
## nu poate trece pe o formă pe care jocul n-o desenează.
static func punct_pe_drum(de_la: Vector2, la: Vector2, t: float) -> Vector2:
	return _bezier(de_la, _control_1(de_la, la), _control_2(de_la, la), la, t)


## Primul punct de control: împins spre dreapta din nodul de plecare.
static func _control_1(de_la: Vector2, la: Vector2) -> Vector2:
	var d := la - de_la
	return de_la + Vector2(d.x * INTINDERE, d.y * INCLINARE)


## Al doilea: împins spre stânga din nodul de sosire.
static func _control_2(de_la: Vector2, la: Vector2) -> Vector2:
	var d := la - de_la
	return la - Vector2(d.x * INTINDERE, d.y * INCLINARE)


## Un punct de pe curba Bézier CUBICĂ: patru puncte în loc de trei.
##
## Pătratica (un singur punct de control) putea face o singură cocoașă. Cubica
## are două puncte de control, deci două cocoașe — și exact asta e un S: ieși
## într-o parte, intri în cealaltă.
##
## Formula e tot „interpolare de interpolări", doar cu un rând în plus:
## din patru puncte faci trei, din trei faci două, din două faci unul.
static func _bezier(a: Vector2, c1: Vector2, c2: Vector2, b: Vector2, t: float) -> Vector2:
	var p1 := a.lerp(c1, t)
	var p2 := c1.lerp(c2, t)
	var p3 := c2.lerp(b, t)
	return p1.lerp(p2, t).lerp(p2.lerp(p3, t), t)

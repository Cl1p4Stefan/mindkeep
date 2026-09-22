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
## DE CE PUNCTATE, ȘI NU LINII ÎNTREGI
##
## O linie continuă și subțire între două dreptunghiuri arată a diagramă: spune
## „nodul A e legat de nodul B". Un șir de liniuțe care se îndoaie spune
## „de-aici se MERGE acolo" — e un drum pe un teren, cu tot cu ocolișul lui.
## Aceeași informație, altă poveste, și costă douăzeci de linii de cod.
##
## ─────────────────────────────────────────────────────────────
## PÂNZA NU MAI CALCULEAZĂ FORMA DRUMULUI. O PRIMEȘTE.
##
## Înainte, pânza primea două centre și-și făcea singură un „S" din curbe
## Bézier. Mergea atâta vreme cât harta era o grilă dreaptă: două puncte și o
## regulă fixă ajungeau ca să reconstruiești drumul dintre ele.
##
## Acum nodurile stau pe o PANGLICĂ — o curbă care șerpuiește pe hârtie — iar
## drumul trebuie să meargă PE ea, nu să taie coarda dintre capete. Din două
## centre, panglica nu se poate ghici înapoi: aceleași două puncte pot sta pe o
## mie de curbe diferite.
##
## Deci harta, care știe panglica, calculează punctele; pânza primește un șir
## de puncte și desenează liniuțe pe el. Împărțirea e și mai curată decât
## înainte: pânza nu mai are nicio părere despre forma unui drum, iar cuvântul
## „panglică" nu apare în fișierul ăsta decât în comentariul de față.
##
## De ce asta ține drumurile să nu se taie: vezi nota lungă de la
## `puncte_drum()` din `harta.gd`. Verificarea din `tools/verifica_harta.gd`
## numără exact asta, pe aceleași puncte pe care le desenăm aici.

## Lungimea unei liniuțe și a pauzei dintre ele, în pixeli.
##
## Erau 9 și 7,5, cu linii de 5 pixeli grosime: la distanța de la care te uiți
## la hartă, ieșea un punctat mărunt care se pierdea în textura hârtiei. Acum
## sunt liniuțe LATE și rare — la fel ca pe hărțile de aventură desenate de
## mână, unde drumul e făcut din trăsături, nu din puncte.
const LUNGIME_LINIUTA := 15.0
const PAUZA_LINIUTA := 11.0

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


## Un drum punctat, pe punctele primite de la hartă.
func _deseneaza_drum(muchie: Dictionary) -> void:
	var puncte: PackedVector2Array = muchie["puncte"]
	if puncte.size() < 2:
		return

	var culoare: Color = muchie["culoare"]
	var grosime := float(muchie["grosime"])
	var de_la := puncte[0]
	var la := puncte[puncte.size() - 1]

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

	var pas := LUNGIME_LINIUTA + PAUZA_LINIUTA
	var parcurs := 0.0
	for i in range(1, puncte.size()):
		var anterior := puncte[i - 1]
		var punct := puncte[i]
		parcurs += anterior.distance_to(punct)

		# Liniuță sau pauză? Poziția pe drum, împărțită la pas, decide singură —
		# fără să numărăm liniuțe și fără să știm câte încap.
		var e_liniuta := fmod(parcurs, pas) < LUNGIME_LINIUTA
		var langa_capat := (
			punct.distance_to(de_la) < oprire or punct.distance_to(la) < oprire
		)
		if e_liniuta and not langa_capat:
			draw_line(anterior, punct, culoare, grosime, true)

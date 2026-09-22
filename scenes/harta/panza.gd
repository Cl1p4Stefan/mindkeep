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

## RITMUL PUNCTATULUI, dat în GROSIMI, nu în pixeli.
##
##   miezul liniuței  = grosime × 1,70   ← partea dreaptă, desenată ca linie
##   pauza dintre ele = grosime × 1,25
##
## De ce în grosimi și nu în pixeli, cum era înainte (15 și 11): fiindcă de la
## capetele rotunjite încoace, o liniuță e miezul PLUS un capac de o jumătate de
## grosime la fiecare capăt. Ce se vede pe hârtie e deci `miez + grosime` —
## adică 2,7 grosimi. Numărul ăsta, 2,7, e PROPORȚIA trăsăturii, și el e ce
## trebuie ținut constant: o trăsătură de 2,7 ori mai lungă decât lată se
## citește ca o urmă de peniță, una de 1,2 ori se citește ca o bulină.
##
## Cu numere fixe în pixeli, drumul ales (16,5 px gros, cel mai gros de pe
## hartă) ajungea fix la buline: 15 + 16,5 = 31,5 px lungime la 16,5 lățime.
## Adică tocmai drumul pe care trebuie să-l vezi cel mai bine arăta cel mai
## puțin a drum.
##
## Cifrele sunt alese ca la 9 px (grosimea obișnuită) să iasă 15,3 și 11,25 —
## adică exact punctatul de dinainte, cu care hărțile erau deja reglate. Nu e o
## schimbare de aspect, e aceeași regulă scrisă astfel încât să reziste și la
## alte grosimi.
const MIEZ_PE_GROSIME := 1.70
const PAUZA_PE_GROSIME := 1.25

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

	# Pasul = miezul + cele două jumătăți de capac (care fac un `grosime`
	# întreg) + pauza. Capacele sunt plătite AICI, în pas, ca pauza care se vede
	# pe hârtie să fie chiar cea cerută, nu ea minus capacele.
	var miez := grosime * MIEZ_PE_GROSIME
	var pas := miez + grosime + grosime * PAUZA_PE_GROSIME
	var parcurs := 0.0
	# Liniuța curentă, strânsă punct cu punct. O desenăm abia când se termină,
	# fiindcă un capac rotund are nevoie să ȘTIE unde e capătul — iar asta se
	# află doar după ce a trecut de el.
	var liniuta := PackedVector2Array()

	for i in range(1, puncte.size()):
		var anterior := puncte[i - 1]
		var punct := puncte[i]
		parcurs += anterior.distance_to(punct)

		# Liniuță sau pauză? Poziția pe drum, împărțită la pas, decide singură —
		# fără să numărăm liniuțe și fără să știm câte încap.
		var e_liniuta := fmod(parcurs, pas) < miez
		var langa_capat := (
			punct.distance_to(de_la) < oprire or punct.distance_to(la) < oprire
		)
		if e_liniuta and not langa_capat:
			if liniuta.is_empty():
				liniuta.append(anterior)
			liniuta.append(punct)
		else:
			_trage_liniuta(liniuta, culoare, grosime)
			liniuta = PackedVector2Array()

	# Drumul se poate termina în mijlocul unei liniuțe (la o pauză sau lângă un
	# nod, bucla de mai sus o închide singură; aici prindem doar ultimul caz).
	_trage_liniuta(liniuta, culoare, grosime)


## O liniuță: linia ei frântă, plus un cerc la fiecare capăt.
##
## DE CE CERCURI ȘI NU UN „capăt rotunjit"
##
## Fiindcă `draw_polyline` nu are așa ceva. În Godot, o linie desenată se
## termină TĂIAT, în unghi drept — la 6 px nu se vedea, la 9-16,5 px fiecare
## liniuță arată ca o cărămidă. Un cerc cu raza `grosime / 2` pus fix pe capăt
## umple exact colțurile care lipsesc, deci rezultatul e nedeosebit de un capăt
## rotund adevărat, și costă două apeluri de desen.
##
## Cercurile se desenează ANTIALIASATE (ultimul `true`). Fără el, capacul are
## trepte vizibile tocmai fiindcă e mic — iar o liniuță cu capete zimțate arată
## mai rău decât una tăiată drept.
func _trage_liniuta(
	liniuta: PackedVector2Array, culoare: Color, grosime: float
) -> void:
	if liniuta.size() < 2:
		return
	draw_polyline(liniuta, culoare, grosime, true)
	var raza := grosime * 0.5
	draw_circle(liniuta[0], raza, culoare, true, -1.0, true)
	draw_circle(liniuta[liniuta.size() - 1], raza, culoare, true, -1.0, true)

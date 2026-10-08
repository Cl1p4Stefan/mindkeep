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
## `puncte_drum()` din `harta.gd`. Verificarea din `tools/verificari/verifica_harta.gd`
## numără exact asta, pe aceleași puncte pe care le desenăm aici.

## Lungimea unei liniuțe și a pauzei dintre ele, în pixeli.
##
## Erau 9 și 7,5, cu linii de 5 pixeli grosime: la distanța de la care te uiți
## la hartă, ieșea un punctat mărunt care se pierdea în textura hârtiei. Acum
## sunt liniuțe LATE și rare — la fel ca pe hărțile de aventură desenate de
## mână, unde drumul e făcut din trăsături, nu din puncte.
const LUNGIME_LINIUTA := 15.0
const PAUZA_LINIUTA := 11.0

## ─────────────────────────────────────────────────────────────
## PÂNZA NU MAI ȘTIE NICI UNDE SE TERMINĂ DRUMUL
##
## Înainte primea, pe lângă puncte, un număr: „lasă atâta liber la fiecare
## capăt". Ea sărea liniuțele mai apropiate de capăt decât atât.
##
## Numărul ăla era o rază, deci presupunea că simbolul din capăt e un cerc.
## Nu e: la săbii, cerneala se termină la 8 px de centru pe orizontală, iar
## raza era 56 — un gol cât jumătate de nod, exact lucrul pe care drumul
## trebuia să-l acopere.
##
## Acum harta trimite drumul DEJA tăiat la marginea cernelii fiecărui simbol
## (vezi `_taiat_la_simboluri()` din `harta.gd`, unde e și explicația lungă).
## Pânza desenează de la primul punct până la ultimul, fără nicio rezervă.
## Ceea ce e și mai curat: un desenator care mai avea o părere despre capete
## acum n-o mai are deloc.

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
##
## ─────────────────────────────────────────────────────────────
## DE CE PAUZA SE ÎNTINDE, ȘI NU LINIUȚA
##
## Înainte, „liniuță sau pauză?" se răspundea cu `fmod(parcurs, pas)`: tiparul
## curgea la nesfârșit, iar drumul îl tăia unde se nimerea. Unde se nimerea
## înseamnă, în jumătate din cazuri, PE O PAUZĂ — adică drumul se termina cu
## aer, și părea că nu ajunge până la nod chiar și atunci când ajungea.
##
## Acum numărăm întâi câte liniuțe încap (`n`), apoi întindem PAUZELE ca cele
## `n` liniuțe să umple fix drumul. Liniuța rămâne exact cât era (15 px):
## lungimea ei e ce dă caracterul trăsăturii, deci ea nu se atinge. Pauza,
## în schimb, nu se citește ca mărime, ci ca ritm — o abatere de un pixel sau
## doi de la 11 nu se vede, iar în schimbul ei fiecare drum începe ȘI se
## termină cu o trăsătură plină.
func _deseneaza_drum(muchie: Dictionary) -> void:
	var puncte: PackedVector2Array = muchie["puncte"]
	if puncte.size() < 2:
		return

	var culoare: Color = muchie["culoare"]
	var grosime := float(muchie["grosime"])

	var total := 0.0
	for i in range(1, puncte.size()):
		total += puncte[i - 1].distance_to(puncte[i])
	if total <= 0.0:
		return

	# Câte liniuțe încap cel mai bine. `n` liniuțe și `n−1` pauze acoperă
	# `n·15 + (n−1)·11`; rotunjirea alege numărul care se apropie cel mai mult
	# de lungimea reală, în plus sau în minus.
	var n := int(round((total + PAUZA_LINIUTA) / (LUNGIME_LINIUTA + PAUZA_LINIUTA)))
	n = maxi(n, 1)
	# ...dar nu mai multe decât încap FĂRĂ pauze: pe un drum foarte scurt,
	# rotunjirea în sus ar cere liniuțe care s-ar suprapune.
	while n > 1 and float(n) * LUNGIME_LINIUTA > total:
		n -= 1

	# Un drum atât de scurt încât nu încap două liniuțe se desenează ca o
	# singură trăsătură, cât el. Alternativa ar fi o liniuță de 15 px într-un
	# drum de 20, adică tocmai capătul gol pe care îl reparăm aici.
	var liniuta := LUNGIME_LINIUTA
	var pauza := 0.0
	if n > 1:
		pauza = (total - float(n) * LUNGIME_LINIUTA) / float(n - 1)
	else:
		liniuta = total

	var pas := liniuta + pauza

	# O singură trecere prin puncte. Pentru fiecare segment aflăm ce bucăți de
	# liniuță cad în el și desenăm doar acele bucăți — așa liniuțele urmează
	# CURBA, nu coarda: o liniuță care prinde un cot se desenează din două
	# bucăți, câte una pe fiecare latură a cotului.
	var parcurs := 0.0
	for i in range(1, puncte.size()):
		var a := puncte[i - 1]
		var b := puncte[i]
		var lungime := a.distance_to(b)
		if lungime <= 0.0:
			continue
		var pana_la := parcurs + lungime

		var k := maxi(0, int(floor(parcurs / pas)))
		while k < n and float(k) * pas < pana_la:
			var de_la_liniuta := maxf(parcurs, float(k) * pas)
			var la_liniuta := minf(pana_la, float(k) * pas + liniuta)
			if la_liniuta > de_la_liniuta:
				draw_line(
					a.lerp(b, (de_la_liniuta - parcurs) / lungime),
					a.lerp(b, (la_liniuta - parcurs) / lungime),
					culoare, grosime, true)
			k += 1

		parcurs = pana_la

class_name UmbraContact
extends Control
## UMBRA DE CONTACT — pata întunecată de sub tălpi, care lipește o figură de podea.
##
## E cel mai ieftin truc de așezare din grafica de joc și singurul care chiar
## funcționează: ochiul nu judecă „la ce înălțime e personajul", ci caută unde
## atinge pământul. Fără umbră, o figură decupată stă în aer oricât de jos ai
## coborî-o; cu umbră, aceeași figură stă pe dale.
##
## ─────────────────────────────────────────────────────────────
## DE CE E NOD SEPARAT, ȘI NU UN DESEN ÎN `impact.gd`
##
## Fiindcă umbra trebuie să NU se miște și să NU se lumineze odată cu figura.
## Învelișul `impact.gd` face exact două lucruri copiilor lui: le clatină
## `position.x` la lovitură și le înmulțește `modulate` cu un alb aprins. O
## umbră pusă înăuntru ar aluneca pe podea la fiecare lovitură (ceea ce ar rupe
## fix iluzia de contact) și ar PĂLI la fulger — o umbră care se albește.
##
## Deci umbra stă ca FRATE al învelișului, desenat înaintea lui (fratele de
## deasupra în arbore se desenează dedesubt). Figura se zguduie peste o pată
## care rămâne pe loc — și asta arată chiar mai bine decât dacă ar sta nemișcate
## amândouă: lovitura pare să-l clatine pe personaj, nu camera.
##
## ─────────────────────────────────────────────────────────────
## DE CE CERCURI CONCENTRICE, ȘI NU O A TREIA TEHNICĂ
##
## Godot n-are „umbră moale" la desen. În proiect există deja două rezolvări:
##   • `StyleBoxFlat.shadow_size` — folosită de halo-ul Obeliscurilor
##     (`obelisc.gd`). Merge grozav pentru un dreptunghi cu colțuri rotunjite,
##     dar ce desenează e un dreptunghi: nu poate fi turtit 1:4 fără să
##     turtească și nodul, iar `shadow_size` crește la fel în toate direcțiile,
##     deci ar reumfla pe verticală exact ce turtisem.
##   • CERCURI CONCENTRICE cu opacitate mică — folosită de halo-ul nodurilor de
##     pe hartă (`simbol_nod._deseneaza_halou()`). Forma e liberă, degradarea e
##     netedă și costul e nimic.
##
## A doua câștigă, cu o singură completare: un cerc turtit e o elipsă, iar
## turtirea se face din transformarea de desen (`draw_set_transform`), nu din
## formulă. Așa rămâne LITERAL aceeași tehnică ca pe hartă — cercuri —, doar
## privită dintr-un plan înclinat. Exact ce e și o umbră pe podea.
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎȘI CAUTĂ SINGURĂ FIGURA
##
## Umbra nu primește o poziție. Primește NUMELE imaginii pe care o umbrește și
## reface singură socoteala „unde cade textura în cutie". Motivul e că poziția
## tălpilor nu e o cifră, ci un rezultat: depinde de cât de mare e cutia pe care
## i-o dă containerul, care depinde de rezoluție, de câte Obeliscuri are
## loadout-ul și de dacă panoul de întrebare e deschis sau nu. O umbră cu
## poziție scrisă de mână ar fi corectă pe ecranul pe care am scris-o.

## Imaginea umbrită. Se dă din scenă, ca `NodePath`.
@export var imagine: NodePath

## TALPA: pe ce fracțiune din înălțimea texturii e LINIA DE CONTACT.
##
## „Linia de contact" nu e marginea de jos a desenului, și aici a stat o
## greșeală măsurabilă. Cifrele de dinainte (0.985 la Rege, 0.970 la Soldat)
## erau ultimul pixel opac din textură — adică VÂRFUL bocancului din față.
## Bocancul din spate calcă cu 20 de pixeli mai sus, iar poalele hainei ating
## podeaua și mai sus de-atât. Cu umbra centrată pe vârful din față, jumătatea
## ei vizibilă cădea toată ÎNAINTEA piciorului: o baltă din care personajul
## iese, exact senzația de plutire pe care umbra trebuia s-o repare.
##
## Cifra corectă e MEDIANA marginii de jos pe toată amprenta (măsurată pe
## canalul alfa, coloană cu coloană): 0.9514 la Rege, 0.9454 la Soldat. Adică
## „unde atinge silueta podeaua, în general", nu „cel mai jos punct al ei".
@export var talpa := 0.9514:
	set(valoare):
		talpa = valoare
		queue_redraw()

## LĂȚIMEA umbrei, ca fracțiune din lățimea texturii desenate.
## Cât stau picioarele, nu cât e de lat personajul: o umbră cât umerii ar părea
## proiectată de sus, nu turtită de gravitație.
@export var latime := 0.55:
	set(valoare):
		latime = valoare
		queue_redraw()

## Unde cade centrul umbrei pe orizontală, ca fracțiune din lățimea texturii.
## 0.5 = exact sub mijloc. E aici fiindcă nu orice figură își ține greutatea în
## centru (Soldatul se sprijină în spadă, în stânga).
@export var centru := 0.5:
	set(valoare):
		centru = valoare
		queue_redraw()

## TURTIREA: înălțimea elipsei împărțită la lățimea ei. 0.25 = 1:4, adică o
## podea privită dintr-un unghi jos. Cu cât camera ar fi mai de sus, cu atât
## cifra ar crește spre 1 (un cerc, adică o privire perpendiculară).
@export var turtire := 0.25:
	set(valoare):
		turtire = valoare
		queue_redraw()

## Cât de întunecat ajunge MIEZUL umbrei. Marginea se stinge singură spre zero.
## 0.5 e plafonul cerut: peste el, pata începe să se citească drept gaură în
## podea, nu drept umbră.
@export_range(0.0, 1.0) var opacitate := 0.5:
	set(valoare):
		opacitate = valoare
		queue_redraw()

## Culoarea umbrei. Nu e negru: podeaua e piatră rece, iar o umbră neagră pe
## piatră albăstruie arată decupată. Un albastru foarte închis se citește ca
## lipsă de lumină, nu ca un obiect.
@export var culoare := Color(0.04, 0.04, 0.07):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Câte elipse suprapuse fac degradarea. Aceeași cifră ca la halo-ul nodurilor
## de pe hartă, din același motiv: sub paisprezece se văd inelele.
@export var straturi := 14:
	set(valoare):
		straturi = maxi(valoare, 1)
		queue_redraw()

## Cât de mult se strânge cea mai mică elipsă față de cea mai mare. Miezul ăsta
## e partea plină a umbrei; restul e trecerea spre nimic.
const MIEZ := 0.34


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	var tinta := _imagine()
	if tinta != null:
		# Nu e de ajuns semnalul propriu: cutia noastră poate rămâne aceeași în
		# timp ce textura dinăuntru se așază altfel (se schimbă imaginea, se
		# deschide panoul de întrebare și coloanele se îngustează).
		tinta.item_rect_changed.connect(queue_redraw)


func _draw() -> void:
	var desenata := _caseta_desenata()
	if desenata.size == Vector2.ZERO or opacitate <= 0.0:
		return

	# Punctul de sprijin, în coordonatele NOASTRE. Îl calculăm în coordonate
	# globale (acolo unde știm unde cade textura) și îl aducem înapoi aici —
	# așa umbra și figura pot atârna de părinți diferiți fără să conteze.
	var sprijin_global := desenata.position + Vector2(
		desenata.size.x * centru, desenata.size.y * talpa
	)
	var sprijin := get_global_transform().affine_inverse() * sprijin_global
	var raza := desenata.size.x * latime * 0.5

	# TURTIREA. Desenăm cercuri, dar într-un sistem de coordonate strivit pe
	# verticală — deci pe ecran ies elipse. Un cerc strivit e o elipsă exactă;
	# o elipsă „desenată din puncte" ar fi fost al treilea fel de umbră din
	# proiect, și încă unul cu colțuri.
	draw_set_transform(sprijin, 0.0, Vector2(1.0, turtire))

	# OPACITATEA PE STRAT, dedusă din cea cerută, nu ghicită. Straturile se
	# suprapun, deci opacitățile nu se adună — se compun: ce rămâne descoperit
	# după un strat e (1 - a), iar după `n` straturi (1 - a)^n. Punem asta egal
	# cu „ce vreau să rămână descoperit în miez" și scoatem `a`.
	#
	# Fără formula asta, schimbarea numărului de straturi ar schimba și cât de
	# întunecată e umbra — adică o cifră de netezime ar avea efect de culoare.
	var pe_strat := 1.0 - pow(1.0 - opacitate, 1.0 / float(straturi))

	for i in range(straturi):
		var t := float(i) / float(straturi)
		var raza_strat := lerpf(raza, raza * MIEZ, t)
		draw_circle(
			Vector2.ZERO, raza_strat, Color(culoare, pe_strat),
			true, -1.0, true  # umplut, fără contur, cu margine netezită
		)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _imagine() -> TextureRect:
	if imagine.is_empty():
		return null
	return get_node_or_null(imagine) as TextureRect


## UNDE CADE EFECTIV TEXTURA — nu unde e nodul.
##
## `TextureRect` cu „păstrează proporția, centrat" își întinde nodul pe toată
## cutia primită, dar desenează imaginea cât încape întreagă, la mijloc. Restul
## cutiei e aer transparent. Diferența dintre cele două e uneori de zeci de
## pixeli, iar umbra o simte întreagă.
##
## Aceeași socoteală o face și `tools/verifica_podeaua.gd`, ca să poată măsura
## tălpile fără să pornească umbra. Sunt două locuri, și asta e o datorie mică
## asumată: unealta trebuie să poată măsura o scenă în care umbra încă nu
## există, altfel n-ar mai fi o verificare independentă.
##
## E `static` fiindcă nu întreabă nimic despre umbră — doar despre un
## `TextureRect`. Așa o poate folosi și `semn_inspectare.gd`, care are nevoie de
## același răspuns pentru alt motiv (unde să pună semnul „i"), fără să ajungem
## la o a treia copie a formulei.
static func caseta_desenata(tinta: TextureRect) -> Rect2:
	if tinta == null or tinta.texture == null:
		return Rect2()
	var cutie := tinta.get_global_rect()
	var tex := Vector2(tinta.texture.get_size())
	if tex.x <= 0.0 or tex.y <= 0.0:
		return Rect2()
	var scara := minf(cutie.size.x / tex.x, cutie.size.y / tex.y)
	return Rect2(cutie.position + (cutie.size - tex * scara) * 0.5, tex * scara)


func _caseta_desenata() -> Rect2:
	return caseta_desenata(_imagine())

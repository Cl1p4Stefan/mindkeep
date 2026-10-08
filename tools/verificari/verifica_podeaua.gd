extends Node
## VERIFICAREA PODELEI — stau personajele pe dale, sau plutesc?
##
## Se cheamă CU fereastră (nu `--headless`), fiindcă face și capturi:
##   godot --path . res://tools/verificari/verifica_podeaua.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ FIȘIERUL ĂSTA
##
## „Personajele par că plutesc" e o impresie. Impresia nu se poate repara și
## nu se poate verifica — mâine, după alte trei ajustări, n-am cum să știu dacă
## am stricat-o la loc. Celelalte unelte din `tools/` fac exact conversia asta
## pentru hartă: impresie → număr → număr care poate ajunge unde trebuie.
##
## Aici numărul e simplu: pe ce FRACȚIUNE din înălțimea ecranului cad tălpile,
## față de linia unde peretele din fund întâlnește podeaua. Deasupra liniei =
## personajul e în perete. Lipit de linie = stă în fundul sălii, dar are mărime
## de prim-plan, deci plutește. Bine sub linie = stă pe dalele din față.
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎN FRACȚIUNI, ȘI NU ÎN PIXELI
##
## Fiindcă jocul nu se joacă doar la 1152×648. Un „tălpile la 420 px" e adevărat
## pe o fereastră și fals pe următoarea. Toate cifrele de mai jos sunt fracțiuni
## din înălțimea ecranului, iar unealta rulează DOUĂ rezoluții una după alta
## tocmai ca să se vadă dacă fracțiunile chiar rămân aceleași. Dacă o cifră
## diferă între cele două rulări, înseamnă că undeva a rămas un pixel bătut în
## cuie — și ăla e bug-ul, nu așezarea.

## Rezoluțiile pe care se măsoară. Prima e cea din discuție, a doua e ecranul
## obișnuit de azi.
##
## ATENȚIE la ce înseamnă „rezoluție" aici. Proiectul e pe `canvas_items` +
## `expand`: interfața se AȘAZĂ mereu într-un ecran logic de 1152×648 și abia
## apoi se scalează la fereastra reală. Deci la 1920×1080 nu se recalculează
## nimic — se mărește totul cu 1.667. De-aia toate cifrele de mai jos se
## raportează la ecranul LOGIC (`get_visible_rect()`), nu la fereastră: altfel
## a doua rulare ar raporta aceleași poziții ca fracțiuni diferite și ar părea
## că așezarea s-a stricat, când de fapt doar s-a mărit.
##
## Rulăm totuși amândouă, din două motive: capturile diferă (vreau să văd umbra
## la mărime mare), iar dacă cineva schimbă vreodată modul de întindere, a doua
## rulare începe să dea alte cifre — și atunci chiar e o problemă.
const REZOLUTII := [Vector2i(1152, 648), Vector2i(1920, 1080)]

## LINIA PERETELUI — unde se termină peretele din fund și încep dalele, ca
## fracțiune din înălțimea imaginii de fundal.
##
## Nu e o presupunere: e măsurată pe `fight_background.jpg`, la baza ferestrei
## gotice, acolo unde plinta se oprește și începe podeaua luminată (y ≈ 428 din
## 648, pe imaginea scalată la înălțimea ecranului).
##
## Merge ca fracțiune din ECRAN doar fiindcă imaginea (2752×1536, adică 1.792)
## și ecranul (16:9, adică 1.778) au aproape același raport: la potrivirea
## „acoperă", imaginea se așază pe înălțime și se taie 0.8% din lățime. Dacă
## într-o zi fundalul devine mai pătrat, cifra asta trebuie recalculată — de-aia
## e scrisă aici, o dată, și nu împrăștiată prin verificări.
const LINIA_PERETELUI := 0.66

## Cât de mult trebuie să treacă tălpile DINCOLO de linia peretelui, ca
## fracțiune din distanța dintre linie și marginea de sus a butoanelor.
##
## O treime e cerința: sub ea, personajul e „lângă perete" și mărimea lui de
## prim-plan se bate cu adâncimea sălii. Nu e o cifră estetică scoasă din
## burtă — e pragul de la care ochiul are ce compara: o bucată de podea ÎN
## FAȚA personajului, nu doar în spatele lui.
const PRAG_INAINTARE := 1.0 / 3.0

## Cât au voie să difere, în pixeli logici, mijloacele celor două rânduri cu
## nume. Nu zero: unul e Label, celălalt Button, iar înălțimile lor de rând pot
## diferi cu un pixel din rotunjiri. Doi pixeli nu se văd; opt se văd.
const TOLERANTA_NUME := 2.0

## PUPITRUL cu cartea deschisă, în fracțiuni din imaginea de fundal. Marginea
## lui dreaptă e reperul de care se ferește mantia Regelui: lipit de el,
## personajul pare sprijinit de mobilă, nu așezat în cameră.
const PUPITRU_DREAPTA := 0.2604

## MARGINEA MANTIEI în textura Regelui, ca fracțiune din lățimea ei.
##
## NU e marginea desenului. Canalul alfa începe la 9/379 = 0.024, dar acolo e
## VÂRFUL SPADEI — o lamă subțire, pe o singură bandă de înălțime. Masa pe care
## o vede ochiul (pânza mantiei) începe la 50/379. Măsurat pe benzi de câte 60
## de pixeli: 0.22 la umeri, 0.18 la mijloc, 0.13 la poale.
##
## Distincția contează: cu marginea desenului, orice socoteală ar trage Regele
## cu încă 30 px spre centru ca să dea loc unei lame de trei pixeli lățime.
const MANTIA_STANGA := 0.132

## Pragurile pentru aerul dintre pupitru și mantie, ca fracțiuni din LĂȚIMEA
## ecranului.
##
## Sunt DOUĂ, și distincția e tot rostul lor. Cerința reală e „Regele să nu
## acopere pupitrul" — asta e o limită tare, se trece sau nu (`AER_MINIM`).
## „Cât de mult aer arată bine" e altceva: o preferință, care s-a mai răzgândit
## o dată și se mai poate răzgândi. Un singur prag le-ar amesteca, iar atunci
## fiecare reglare de compoziție ar părea o stricare de regulă.
##
## Deci: sub zero = PICAT (se suprapun). Între zero și `AER_COMOD` = merge, dar
## se scrie cifra în raport, ca să se vadă cât de la limită e.
const AER_MINIM := 0.0
const AER_COMOD := 0.026

## Sfeșnicul cu lumânări din stânga, în fracțiuni din imaginea de fundal
## (măsurat pe pixelii aprinși). E singura sursă de lumină caldă din sală și
## motivul pentru care Regele e colorat cald — dacă un decupaj o taie,
## colorarea lui rămâne fără cauză pe ecran.
const LUMANARI := Rect2(0.0486, 0.3657, 0.1146, 0.0973)

## Cât aer cere regula între marginea vizibilă a personajului și panoul de
## întrebare. Aceeași cifră ca în scenă (`AsezareColoana.aer_langa_panou`) —
## scrisă aici ca AȘTEPTARE, nu ca sursă: dacă cineva o schimbă în scenă și
## uită de verificare, verificarea trebuie să se plângă, nu să se alinieze.
const AER_LANGA_PANOU := 12.0

## Cât poate să scape măsurătoarea față de cifra cerută. O jumătate de pixel e
## rotunjire; doi sunt deja o regulă care nu se aplică.
const TOLERANTA_PANOU := 1.5

## Unde se scriu capturile. `user://` e singurul loc în care un joc exportat
## are voie să scrie; calea reală se tipărește la final, ca s-o pot deschide.
const DOSAR_CAPTURI := "user://capturi"

const SCENA_LUPTA := preload("res://scenes/lupta/lupta.tscn")

## Nodurile măsurate, ca „nume afișat" → cale în scena de luptă. Lista e aici,
## nu împrăștiată prin cod, ca să se vadă dintr-o privire ce anume se
## urmărește — și ca să pot adăuga un rând când apare un element nou în arenă.
const DE_MASURAT := {
	"bara PV jucator": "Margini/Coloana/Arena/JucatorBaraPV",
	"bara PV inamic":  "Margini/Coloana/Arena/InamicBaraPV",
	"nume jucator":    "Margini/Coloana/Arena/ZonaJucator/ColoanaJucator/InfoJucator/JucatorNume",
	"PV jucator":      "Margini/Coloana/Arena/ZonaJucator/ColoanaJucator/InfoJucator/JucatorPV",
	"nume inamic":     "Margini/Coloana/Arena/ZonaInamic/ColoanaInamic/InfoInamic/InamicNume",
	"PV inamic":       "Margini/Coloana/Arena/ZonaInamic/ColoanaInamic/InfoInamic/InamicPV",
	"info jucator":    "Margini/Coloana/Arena/ZonaJucator/ColoanaJucator/InfoJucator",
	"info inamic":     "Margini/Coloana/Arena/ZonaInamic/ColoanaInamic/InfoInamic",
	"puncte PA":       "Margini/Coloana/PAPuncte",
	"rand obeliscuri": "Margini/Coloana/RandObeliscuri",
	"buton tura":      "Margini/Coloana/IncheieTura",
}

## Figurile, ca „nume" → [coloana în care stau, numele imaginii, talpa în textură].
##
## A treia cifră e cea care contează și e măsurată în PNG, nu ghicită: e
## MEDIANA marginii de jos a siluetei pe toată amprenta, coloană cu coloană pe
## canalul alfa. Adică „unde atinge figura podeaua, în general".
##
## Înainte scria aici ultimul pixel opac (0.9848 și 0.9697) — vârful bocancului
## din față. E un punct real, dar e capătul amprentei, nu mijlocul ei: umbra
## centrată acolo cădea toată în fața piciorului, iar măsurătoarea de aici
## raporta tălpi cu ~2% mai jos decât stau. Vezi `talpa` din `umbra_contact.gd`.
const FIGURI := {
	"REGE":   ["Margini/Coloana/Arena/ZonaJucator", "JucatorImagine", 0.9514],
	"INAMIC": ["Margini/Coloana/Arena/ZonaInamic", "InamicImagine", 0.9454],
}

var _lupta: Control = null


func _ready() -> void:
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(DOSAR_CAPTURI)

	var totul_bine := true
	for rezolutie in REZOLUTII:
		var rezultat: bool = await _masoara(rezolutie)
		totul_bine = rezultat and totul_bine

	# Scena de lupta se elibereaza inainte de iesire. Fara asta, Godot se
	# plange la inchidere ca au ramas resurse in folosinta — un ERROR fals
	# intr-o unealta a carei singura treaba e sa spuna daca e ceva in neregula.
	if _lupta != null:
		# `queue_free` doar PROGRAMEAZA stergerea, pentru sfarsitul cadrului.
		# Intre programare si iesire n-ar apuca sa se intample nimic, deci aici
		# se sterge pe loc, si abia apoi se lasa cateva cadre in care tween-urile
		# ramase (muzica atenuata, panouri in miscare) se sting singure.
		_lupta.free()
		_lupta = null
		for cadru in range(3):
			await get_tree().process_frame

	print("")
	print("Capturile: ", ProjectSettings.globalize_path(DOSAR_CAPTURI))
	print("VERDICT: ", "podeaua tine" if totul_bine else "INCA PLUTESTE")
	get_tree().quit(0 if totul_bine else 1)


## O rulare completă pe o rezoluție: pune fereastra, deschide lupta, lasă
## layout-ul să se așeze, măsoară, face captura.
func _masoara(rezolutie: Vector2i) -> bool:
	get_window().size = rezolutie
	# Două cadre nu ajung: containerele își recalculează copiii abia la
	# următoarea trecere, iar `TextureRect`-ul își află caseta abia după ce
	# părintele și-a aflat-o pe-a lui. Opt cadre sunt ieftine și sigure.
	for i in range(8):
		await get_tree().process_frame

	if _lupta != null:
		_lupta.queue_free()
		_lupta = null
		await get_tree().process_frame
	_lupta = SCENA_LUPTA.instantiate()
	add_child(_lupta)
	for i in range(8):
		await get_tree().process_frame

	# Ecranul LOGIC: în el trăiesc nodurile. Poate fi mai mic decât fereastra.
	var ecran := get_viewport().get_visible_rect().size
	var inaltime := ecran.y
	print("")
	print("======================================================")
	print("  fereastra %d x %d   (ecran logic %.0f x %.0f)"
		% [rezolutie.x, rezolutie.y, ecran.x, ecran.y])
	print("======================================================")

	# Reperele fixe: linia peretelui (din fundal) și tavanul butoanelor.
	var sus_obeliscuri := _dreptunghi(DE_MASURAT["rand obeliscuri"]).position.y / inaltime
	var adancime := sus_obeliscuri - LINIA_PERETELUI
	var prag := LINIA_PERETELUI + adancime * PRAG_INAINTARE
	print("  linia peretelui     %6.3f" % LINIA_PERETELUI)
	print("  sus butoane         %6.3f" % sus_obeliscuri)
	print("  podea utila         %6.3f  (prag de inaintare: %.3f)" % [adancime, prag])

	var bine := true

	print("")
	print("  -- TALPILE ---------------------------------------")
	for nume in FIGURI:
		var caseta := _caseta_desenata(FIGURI[nume][0], FIGURI[nume][1])
		if caseta.size == Vector2.ZERO:
			print("  %-8s  LIPSA (nodul nu s-a gasit)" % nume)
			bine = false
			continue
		var talpa := (caseta.position.y + caseta.size.y * float(FIGURI[nume][2])) / inaltime
		var trecut := talpa >= prag
		bine = bine and trecut
		print("  %-8s  talpa %6.3f   %-8s  (a inaintat %.0f%% din podea)" % [
			nume, talpa,
			"OK" if trecut else "PREA SUS",
			clampf((talpa - LINIA_PERETELUI) / maxf(adancime, 0.0001), 0.0, 9.0) * 100.0,
		])
		print("            figura desenata: stanga %6.3f  dreapta %6.3f  (lat %.3f)" % [
			caseta.position.x / ecran.x, caseta.end.x / ecran.x,
			caseta.size.x / ecran.x,
		])

	print("")
	print("  -- SUPRAPUNERI -----------------------------------")
	# Regula: nimic din informația de luptă (nume, PV, intenție) nu are voie
	# să calce peste punctele de PA sau peste butoane. Verificarea e pe
	# dreptunghiuri, nu pe ochi: o suprapunere de trei pixeli n-o vezi pe o
	# captură, dar o vezi pe alt ecran.
	for a in ["info jucator", "info inamic"]:
		for b in ["puncte PA", "rand obeliscuri", "buton tura"]:
			var ra := _dreptunghi_vizibil(DE_MASURAT[a])
			var rb := _dreptunghi_vizibil(DE_MASURAT[b])
			if ra.has_area() and rb.has_area() and ra.intersects(rb):
				print("  %s CALCA peste %s" % [a, b])
				bine = false
	print("  (nimic nelistat = nicio suprapunere)")

	print("")
	print("  -- PUPITRUL, CU PANOUL INCHIS SI DESCHIS ---------")
	# Fundalul e lipit de ECRAN; coloanele nu sunt. Cand se deschide panoul de
	# intrebare, cele doua coloane se string la jumatate si figurile se muta
	# spre margini — deci distanta pana la pupitru NU e un singur numar, ci
	# doua. Masurate amandoua, altfel „l-am dat la o parte de pupitru" e
	# adevarat doar in starea in care m-am uitat.
	var bine_pupitru: bool = await _masoara_pupitrul(ecran)
	bine = bine_pupitru and bine

	print("")
	print("  -- PANOUL DE INTREBARE, PE FIECARE INAMIC --------")
	var bine_panou: bool = await _masoara_panoul(ecran, rezolutie)
	bine = bine_panou and bine

	print("")
	print("  -- NUMELE PE ACEEASI LINIE -----------------------")
	# Cele doua nume sunt de tipuri diferite de nod (Label la jucator, Button
	# la inamic, fiindca pe al inamicului se apasa ca sa se deschida cardul).
	# Un Button are marginile lui de tema, deci „aceeasi pozitie in cutie" NU
	# inseamna „acelasi rand pe ecran". De-aia se compara MIJLOACELE randurilor,
	# nu marginile de sus.
	var r_rege := _dreptunghi_vizibil(DE_MASURAT["nume jucator"])
	var r_soldat := _dreptunghi_vizibil(DE_MASURAT["nume inamic"])
	var mijloc_rege := (r_rege.position.y + r_rege.end.y) * 0.5 / inaltime
	var mijloc_soldat := (r_soldat.position.y + r_soldat.end.y) * 0.5 / inaltime
	var abatere: float = absf(mijloc_rege - mijloc_soldat) * inaltime
	print("  REGELE  mijloc %6.3f    SOLDATUL  mijloc %6.3f    abatere %.1f px  %s" % [
		mijloc_rege, mijloc_soldat, abatere,
		"OK" if abatere <= TOLERANTA_NUME else "STRAMB",
	])
	if abatere > TOLERANTA_NUME:
		bine = false
	# Intentia ramane SUB numele inamicului.
	var r_intentie := _dreptunghi_vizibil(DE_MASURAT["intentie inamic"])
	if r_intentie.has_area() and r_intentie.position.y < r_soldat.end.y - 1.0:
		print("  intentia nu mai e sub numele inamicului")
		bine = false

	print("")
	print("  -- ASEZAREA, IN FRACTIUNI ------------------------")
	for nume in DE_MASURAT:
		# Un nod ascuns nu e așezat de container: ar raporta dreptunghiul cu
		# care a plecat din editor, adică o minciună curată. („Incheie tura" e
		# ascuns la pornire — tura se încheie singură.)
		var nod := _lupta.get_node_or_null(DE_MASURAT[nume]) as Control
		if nod != null and not nod.is_visible_in_tree():
			print("  %-16s  (ascuns)" % nume)
			continue
		var r := _dreptunghi(DE_MASURAT[nume])
		print("  %-16s  sus %6.3f  jos %6.3f  stanga %6.3f  dreapta %6.3f" % [
			nume, r.position.y / inaltime, r.end.y / inaltime,
			r.position.x / ecran.x, r.end.x / ecran.x,
		])

	print("")
	print("  -- LUMANARILE ------------------------------------")
	var lumini_bune := _verifica_lumanarile(ecran)
	bine = lumini_bune and bine

	# CAPTURA SE IA ÎNAINTE de proba de lovitură, și asta nu e o preferință de
	# ordine: proba cheamă `loveste()`, care aprinde un fulger alb și clatină
	# figura o jumătate de secundă. O captură luată după ar arăta două
	# personaje pe jumătate albe — adică n-ar mai arăta jocul.
	await RenderingServer.frame_post_draw
	var imagine := get_viewport().get_texture().get_image()
	var cale := "%s/lupta_%dx%d.png" % [DOSAR_CAPTURI, rezolutie.x, rezolutie.y]
	imagine.save_png(cale)
	print("")
	print("  captura: ", cale)

	print("")
	print("  -- UMBRA LA LOVITURA -----------------------------")
	# `await`: funcția așteaptă un cadru înăuntru, ca să apuce tremuratul să
	# se vadă. Fără `await`, apelul s-ar întoarce cu un semnal, nu cu un adevăr.
	var umbra_buna: bool = await _verifica_umbra_la_lovitura()
	bine = umbra_buna and bine

	return bine


## Cât aer rămâne între pupitru și marginea mantiei, în cele două stări ale
## panoului de întrebare.
##
## Marginea MANTIEI, nu marginea nodului: textura are aer transparent pe laturi
## (Regele 8 px din 379 în stânga), iar ochiul vede pânza, nu dreptunghiul.
func _masoara_pupitrul(ecran: Vector2) -> bool:
	var zona := _lupta.get_node_or_null("Margini/Coloana/Arena/ZonaPuzzle") as Control
	var bine := true
	for deschis in [false, true]:
		# Geometria panoului deschis, fără animație: exact ce lasă tween-ul în
		# urmă (`LATIME_PANOU` din lupta.gd).
		if zona != null:
			zona.visible = deschis
			zona.custom_minimum_size.x = 500.0 if deschis else 0.0
		for cadru in range(4):
			await get_tree().process_frame

		var caseta := _caseta_desenata(FIGURI["REGE"][0], FIGURI["REGE"][1])
		if caseta.size == Vector2.ZERO:
			continue
		var mantia := caseta.position.x + caseta.size.x * MANTIA_STANGA
		var aer := (mantia / ecran.x) - PUPITRU_DREAPTA
		var destul := aer >= AER_MINIM
		var verdict := "OK"
		if not destul:
			verdict = "se suprapun"
		elif aer < AER_COMOD:
			verdict = "ok, dar la limita"
		# Cu panoul deschis coloanele se string ca sa-i faca loc, iar figurile
		# TREBUIE sa se dea spre margini. Cifra se scrie ca sa se stie cat e,
		# dar nu e o promisiune incalcata — de-aia si cuvantul e altul.
		if deschis:
			verdict += "  (informativ: aici pupitrul nu e o promisiune)"
		print("  panou %-7s mantia la %6.3f   aer %6.3f (%.0f px)  %s" % [
			"DESCHIS" if deschis else "inchis", mantia / ecran.x, aer,
			aer * ecran.x, verdict,
		])
		# Doar starea cu panoul ÎNCHIS e o cădere. Cu panoul deschis, coloanele
		# se string ca să facă loc întrebării, iar figurile TREBUIE să se dea la
		# o parte — acolo cifra e informativă, nu o promisiune.
		if deschis:
			continue
		if not destul:
			bine = false

	if zona != null:
		zona.visible = false
		zona.custom_minimum_size.x = 0.0
		for cadru in range(4):
			await get_tree().process_frame
	return bine


## CU PANOUL DESCHIS: rămâne ceva din personaje sub panou?
##
## Se măsoară pe FIECARE inamic din tabel, nu doar pe cel care a ieșit azi.
## Motivul e chiar cerința: regula trebuie să țină și pentru un adversar cu o
## armă mai lată. Azi cei trei împart aceeași textură (`INAMICI` are `colorare`,
## nu imagine), deci cifrele ies identice — iar asta e o informație, nu o
## pierdere de vreme: arată că verificarea NU depinde de cine e în arenă, și va
## prinde diferența în ziua în care Lăncierul își primește propriul desen.
##
## Marginea vizibilă NU se recalculează aici. Se cere de la nodul care o
## folosește (`AsezareColoana.margine_interioara()`), fiindcă o verificare care
## își face singură socoteala poate confirma o greșeală cu o copie a ei.
func _masoara_panoul(ecran: Vector2, rezolutie: Vector2i) -> bool:
	var panoul := _lupta.get_node_or_null("Margini/Coloana/Arena/ZonaPuzzle") as Control
	var zone := {
		"REGE": _lupta.get_node_or_null("Margini/Coloana/Arena/ZonaJucator"),
		"INAMIC": _lupta.get_node_or_null("Margini/Coloana/Arena/ZonaInamic"),
	}
	if panoul == null or zone["REGE"] == null or zone["INAMIC"] == null:
		print("  LIPSA (panoul sau coloanele nu s-au gasit)")
		return false

	# Geometria panoului deschis, fără animație: exact ce lasă tween-ul în urmă.
	panoul.visible = true
	panoul.custom_minimum_size.x = 500.0

	var bine := true
	var inamici: Array = _lupta.get("INAMICI")
	for indice in range(inamici.size()):
		_lupta.set("inamic_curent", indice)
		_lupta.call("aplica_infatisarea")
		for cadru in range(4):
			await get_tree().process_frame

		print("  %s:" % str(inamici[indice]["nume"]))
		for nume in zone:
			var zona: Control = zone[nume]
			var margine: float = zona.call("margine_interioara")
			var spre_dreapta: bool = bool(zona.get("panoul_la_dreapta"))
			var marginea_panoului := (panoul.global_position.x if spre_dreapta
				else panoul.global_position.x + panoul.size.x)
			var aer: float = (marginea_panoului - margine) if spre_dreapta else (margine - marginea_panoului)
			var destul := aer >= AER_LANGA_PANOU - TOLERANTA_PANOU
			bine = bine and destul
			print("    %-7s margine vizibila %7.1f px   aer pana la panou %5.1f px  %s" % [
				nume, margine, aer,
				"OK" if destul else ("ACOPERIT" if aer < 0.0 else "PREA APROAPE"),
			])

			# Regula împinge spre exterior. Verificăm că n-a împins personajul
			# peste bara lui de PV — singurul lucru care stă în afara lui.
			var bara := _dreptunghi_vizibil(DE_MASURAT[
				"bara PV jucator" if nume == "REGE" else "bara PV inamic"])
			var figura := _caseta_desenata(FIGURI[nume][0], FIGURI[nume][1])
			if bara.has_area() and figura.size.x > 0.0:
				var calca := (figura.position.x < bara.end.x if nume == "REGE"
					else figura.end.x > bara.position.x)
				if calca:
					print("    %-7s CALCA peste bara de PV" % nume)
					bine = false

	_lupta.set("inamic_curent", 0)
	_lupta.call("aplica_infatisarea")

	# PROBA REGULII. Cu valorile de azi, poziția de bază nimerește singură la
	# fix 12 px de panou — deci măsurătoarea de mai sus ar trece la fel de bine
	# și dacă limita n-ar exista deloc. Ca să știu că regula chiar face ceva, o
	# pun într-o situație în care TREBUIE să intervină: împing poziția de bază
	# mult spre centru și mă uit dacă aerul rămâne tot 12.
	#
	# Fără proba asta, ziua în care cineva schimbă poziția de bază ar fi ziua în
	# care aflu, din joc, că regula era decor.
	# CAPTURA CU PANOUL DESCHIS. Panoul e gol (aici se deschide doar geometria
	# lui, nu o intrebare adevarata), si asta e exact ce trebuie vazut:
	# marginile lui fata de baston si de spada, fara continut care sa distraga.
	for cadru in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var poza := get_viewport().get_texture().get_image()
	var unde := "%s/lupta_panou_%dx%d.png" % [
		DOSAR_CAPTURI, rezolutie.x, rezolutie.y]
	poza.save_png(unde)
	print("  captura cu panoul deschis: ", unde)

	print("  proba regulii (pozitia de baza impinsa la 0.30):")
	var baza := {}
	for nume in zone:
		baza[nume] = zone[nume].get("deplasare_de_baza")
		zone[nume].set("deplasare_de_baza", 0.30)
	for cadru in range(4):
		await get_tree().process_frame
	for nume in zone:
		var zona: Control = zone[nume]
		var margine: float = zona.call("margine_interioara")
		var spre_dreapta: bool = bool(zona.get("panoul_la_dreapta"))
		var marginea_panoului := (panoul.global_position.x if spre_dreapta
			else panoul.global_position.x + panoul.size.x)
		var aer: float = (marginea_panoului - margine) if spre_dreapta else (margine - marginea_panoului)
		var tinut := aer >= AER_LANGA_PANOU - TOLERANTA_PANOU
		bine = bine and tinut
		print("    %-7s aer %5.1f px  %s" % [
			nume, aer, "OK (limita a muscat)" if tinut else "PICAT (limita n-a tinut)",
		])
	for nume in zone:
		zone[nume].set("deplasare_de_baza", baza[nume])

	panoul.visible = false
	panoul.custom_minimum_size.x = 0.0
	for cadru in range(4):
		await get_tree().process_frame
	return bine


## UMBRA RĂMÂNE PE LOC CÂND FIGURA ÎNCASEAZĂ.
##
## E singura verificare de-aici care nu măsoară o poziție, ci apără o DECIZIE
## de structură. `impact.gd` clatină toți copiii învelișului și le aprinde
## `modulate`. Dacă umbra ajunge vreodată copilul lui — o mutare de două
## secunde în editor, făcută cu cele mai bune intenții — atunci pata de sub
## tălpi alunecă pe podea la fiecare lovitură și se albește la fulger. Adică
## exact iluzia de contact pe care o cumpărăm cu ea se rupe fix în momentul în
## care te uiți cel mai atent la personaj.
##
## Nu se vede pe o captură: tremuratul ține 0.28 secunde. De-aia e test, nu ochi.
func _verifica_umbra_la_lovitura() -> bool:
	var bine := true
	for pereche in [["UmbraJucator", "FiguraJucator"], ["UmbraInamic", "FiguraInamic"]]:
		var umbra := _cauta(_lupta, pereche[0]) as Control
		var figura := _cauta(_lupta, pereche[1]) as Control
		if umbra == null or figura == null:
			print("  %s / %s: LIPSA" % [pereche[0], pereche[1]])
			bine = false
			continue
		if figura.is_ancestor_of(umbra):
			print("  %s e COPILUL invelisului — se va clatina si albi cu figura"
				% pereche[0])
			bine = false
			continue
		var inainte := umbra.global_position
		figura.call("loveste", 6)   # o lovitura critica: cel mai mare tremurat

		# Se urmărește câteva cadre, nu unul. `_process` pornește abia la
		# cadrul următor, iar tremuratul e un `sin`: nimerit într-un singur
		# cadru, poate fi chiar la trecerea prin zero. Maximul pe patru cadre
		# nu poate fi zero decât dacă nu s-a clătinat nimic — și atunci proba
		# n-a măsurat de fapt nimic, ceea ce e tot o cădere.
		var mutat := 0.0
		var alunecat := 0.0
		for cadru in range(4):
			await get_tree().process_frame
			mutat = maxf(mutat, absf(figura.get_child(0).position.x))
			alunecat = maxf(alunecat, umbra.global_position.distance_to(inainte))
		if is_zero_approx(mutat):
			print("  %s: figura nu s-a clatinat deloc — proba n-a masurat nimic"
				% pereche[1])
			bine = false
			continue
		print("  %-13s figura s-a clatinat %.1f px, umbra a alunecat %.1f px  %s" % [
			pereche[0], mutat, alunecat, "OK" if alunecat < 0.01 else "PICAT",
		])
		if alunecat >= 0.01:
			bine = false
	return bine


## Lumânările: mai sunt pe ecran, și nu intră sub bara de PV?
##
## Contează doar dacă fundalul a fost mărit. Cu `Peisaj` lipit de marginile
## ecranului (ancorele 0..1), decupajul e cel al potrivirii „acoperă" și nu se
## pierde aproape nimic; cu ancorele împinse în afară ca să urce linia podelei,
## exact colțul ăsta e primul care pleacă din cadru.
func _verifica_lumanarile(ecran: Vector2) -> bool:
	var peisaj := _lupta.get_node_or_null("Peisaj") as TextureRect
	if peisaj == null or peisaj.texture == null:
		print("  (fara fundal)")
		return true

	# Dreptunghiul pe care îl ocupă nodul, și cât din el umple imaginea la
	# potrivirea „acoperă": imaginea se mărește până când amândouă laturile
	# sunt acoperite, deci scara e MAXIMUL celor două rapoarte.
	var cutie := peisaj.get_global_rect()
	var tex := Vector2(peisaj.texture.get_size())
	var scara := maxf(cutie.size.x / tex.x, cutie.size.y / tex.y)
	var desenata := Rect2(
		cutie.position + (cutie.size - tex * scara) * 0.5, tex * scara
	)
	var pe_ecran := Rect2(
		desenata.position + LUMANARI.position * desenata.size,
		LUMANARI.size * desenata.size
	)
	var ecranul := Rect2(Vector2.ZERO, ecran)
	var bara := _dreptunghi(DE_MASURAT["bara PV jucator"])

	print("  lumanari pe ecran:  stanga %6.3f  dreapta %6.3f  sus %6.3f" % [
		pe_ecran.position.x / ecran.x, pe_ecran.end.x / ecran.x,
		pe_ecran.position.y / ecran.y,
	])
	var bine := true
	# CADEREA: o parte din sfeșnic a ieșit din cadru. Asta se întâmplă doar
	# dacă fundalul a fost mărit, și e motivul pentru care n-a fost.
	if not ecranul.encloses(pe_ecran):
		print("  PICAT: decupajul taie din lumanari")
		bine = false
	# AVERTISMENTUL: flacăra din marginea stângă intră în spatele barei de PV.
	# E adevărat și fără nicio mărire (bara e lată de 26 px, flacăra începe la
	# 0.049), deci nu e o regresie — e o cifră de urmărit. Dacă ajunge să
	# acopere mult, sfeșnicul dispare de tot și colorarea caldă a Regelui
	# rămâne fără sursă vizibilă.
	if pe_ecran.position.x < bara.end.x:
		print("  atentie: bara de PV acopera %.1f%% din latimea lumanarilor"
			% (minf(bara.end.x - pe_ecran.position.x, pe_ecran.size.x)
				/ pe_ecran.size.x * 100.0))
	return bine


## Dreptunghiul global al unui nod din scena de luptă, gol dacă nu există.
func _dreptunghi(cale: String) -> Rect2:
	var nod := _lupta.get_node_or_null(cale) as Control
	return Rect2() if nod == null else nod.get_global_rect()


## La fel, dar un nod ASCUNS întoarce un dreptunghi gol.
##
## Fără asta, verificarea de suprapuneri minte. Containerele nu așază copiii
## invizibili, deci nodul rămâne cu dreptunghiul primit în editor — iar
## „Incheie tura", ascuns la pornire, e desenat în scenă în colțul din
## stânga-sus. Raportul spunea că numele Regelui calcă peste el. Nu calcă peste
## nimic: butonul nu e nicăieri.
func _dreptunghi_vizibil(cale: String) -> Rect2:
	var nod := _lupta.get_node_or_null(cale) as Control
	if nod == null or not nod.is_visible_in_tree():
		return Rect2()
	return nod.get_global_rect()


## CASETA ÎN CARE CADE EFECTIV TEXTURA, nu cutia nodului.
##
## Distincția e tot rostul funcției. `JucatorImagine` întinde ancorele pe toată
## cutia primită, dar desenează cu „păstrează proporția, centrat": imaginea e
## înaltă și îngustă, cutia e altfel, deci rămâne aer pe laturi sau sus-jos.
## O umbră pusă la marginea cutiei ar cădea în aerul ăla.
##
## Prima cale e COLOANA (`ZonaJucator`), a doua e numele imaginii căutate
## oriunde sub ea. Așa, unealta nu se strică dacă figura se mută într-un nod
## intermediar — și fix asta urmează să se întâmple.
func _caseta_desenata(cale_zona: String, nume_imagine: String) -> Rect2:
	var zona := _lupta.get_node_or_null(cale_zona)
	if zona == null:
		return Rect2()
	var imagine := _cauta(zona, nume_imagine) as TextureRect
	if imagine == null or imagine.texture == null:
		return Rect2()
	var cutie := imagine.get_global_rect()
	var tex := Vector2(imagine.texture.get_size())
	# „Păstrează proporția" = scara e MINIMUL celor două rapoarte: imaginea
	# intră întreagă în cutie, oricât aer ar rămâne.
	var scara := minf(cutie.size.x / tex.x, cutie.size.y / tex.y)
	return Rect2(cutie.position + (cutie.size - tex * scara) * 0.5, tex * scara)


## Caută un nod după nume, oriunde în subarborele dat.
func _cauta(radacina: Node, nume: String) -> Node:
	if radacina.name == nume:
		return radacina
	for copil in radacina.get_children():
		var gasit := _cauta(copil, nume)
		if gasit != null:
			return gasit
	return null

class_name Plansa
extends RefCounted
## PLANȘA — o hartă DESENATĂ de mână, citită dintr-un fișier.
##
## Până acum harta avea o singură sursă: generatorul. El așază nodurile pe o
## panglică, după adâncime și coloană, iar drumurile ies din geometria aia. E
## bun la ce știe — o hartă nouă la fiecare sămânță, garantat fără încrucișări —
## dar nu poate desena UN LOC. O panglică nu are un râu care ocolește, nici o
## despicătură care se închide mai târziu; are doar benzi.
##
## Planșa e cealaltă sursă: un fișier în care nodurile și drumurile sunt puse cu
## mâna, exact unde vrei. Tipurile (Luptă, Elită, Magazin…) NU sunt în fișier —
## ele rămân trase din sămânță, ca până acum. Adică desenul e fix și conținutul
## e variabil, ceea ce e fix împărțirea pe care o vrei: forma o alegi tu o dată,
## surpriza o dă jocul de fiecare dată.
##
## ─────────────────────────────────────────────────────────────
## CE E ÎN FIȘIER (și de ce exact atât)
##
##   raport_latime_inaltime — proporția cutiei în care ai desenat
##   start, boss            — care nod e intrarea și care e capătul
##   noduri[]               — { id, poz: [x, y] }
##   drumuri[]              — { de_la, la, puncte: [[x, y], …] }
##
## COORDONATELE SUNT FRACȚIUNI (0..1) DINTR-O CUTIE, nu pixeli. Un desen în
## pixeli ar fi corect pe fereastra pe care l-ai desenat și greșit pe toate
## celelalte. Cu fracțiuni plus un raport, cutia se scalează UNIFORM în zona
## utilă și se centrează — adică forma pe care ai desenat-o rămâne forma aia,
## doar mai mare sau mai mică. (Uniform, nu „întinsă pe toată zona”: o cutie
## întinsă pe o zonă cu altă proporție ar turti curbele, iar un cerc desenat de
## tine ar ajunge pe ecran o elipsă.)
##
## UN DRUM E O LISTĂ DE PUNCTE, nu o formulă. Panglica putea calcula drumul
## dintre două noduri fiindcă știa terenul dintre ele; aici nu există teren, doar
## desenul tău. Punctele sunt „pe unde trece”, iar curba netedă prin ele (vezi
## `Harta.curba_neteda`) e doar ca să nu se vadă colțuri.
##
## TIPURILE NU SUNT ÎN FIȘIER, și merită spus de ce, fiindcă e tentant să le pui:
## un „aici e Magazinul” scris în planșă ar însemna că fiecare expediție pe harta
## asta are Magazinul în același loc. Atunci harta s-ar învăța pe de rost după
## trei runuri, iar sămânța n-ar mai însemna nimic.
##
## ─────────────────────────────────────────────────────────────
## CE NU FACE FIȘIERUL ĂSTA
##
## Nu verifică dacă harta e BUNĂ — dacă se poate ajunge peste tot, dacă drumurile
## se taie, dacă nodurile sunt prea apropiate. Aici se verifică doar dacă fișierul
## e CITIBIL: câmpurile există, au tipul potrivit, drumurile leagă noduri care
## există. Restul e treaba lui `tools/verifica_plansa.gd`, dintr-un motiv practic:
## o hartă prost desenată trebuie să se vadă la validare, nu să oprească jocul în
## mijlocul unei expediții.

## Unde stau planșele. Aici, ca să existe un singur loc care știe dosarul.
const DOSAR := "res://data/harti/"


## Planșele deja citite, ca să nu redeschidem fișierul la fiecare redimensionare
## de fereastră (`_aseaza_nodurile` e chemată de fiecare dată).
##
## Cheia ține și DATA MODIFICĂRII, nu doar calea. Pare un moft până desenezi:
## salvezi fișierul, te întorci în joc, redimensionezi fereastra — și vezi harta
## veche, fiindcă ea era în buzunar. Cu data în cheie, un fișier salvat e un
## fișier recitit, iar desenatul devine „schimbă, salvează, uită-te”.
static var _citite := {}


## Planșa de la calea dată, citită o dată și ținută minte.
static func incarca(cale: String) -> Dictionary:
	var cheie := "%s@%d" % [cale, FileAccess.get_modified_time(cale)]
	if not _citite.has(cheie):
		_citite[cheie] = citeste(cale)
	return _citite[cheie]


## Planșa citită PROASPĂT de pe disc, ocolind buzunarul.
##
## Întoarce ÎNTOTDEAUNA un dicționar cu toate câmpurile, chiar și când fișierul
## lipsește sau e stricat — cu „eroare” scris. Un `null` întors de aici ar fi
## crăpat două funcții mai încolo, într-un loc care n-are nicio legătură cu
## citirea fișierelor; un dicționar gol, dar întreg, se poate întreba liniștit.
static func citeste(cale: String) -> Dictionary:
	var plansa := {
		"cale": cale,
		"raport": 1.0,
		"start": "",
		"boss": "",
		## Reperele („id”-urile text din fișier), în ordinea în care le-ai scris.
		"ordine": [],
		## reper → Vector2 cu fracțiunile lui.
		"poz": {},
		## [{ de_la, la, puncte: Array[Vector2] }], în ordinea din fișier.
		"drumuri": [],
		## reper → Array[String] cu reperele în care duce. Graful, pe scurt.
		"spre": {},
		"eroare": "",
	}

	if not FileAccess.file_exists(cale):
		plansa["eroare"] = "nu există fișierul"
		return plansa

	var brut: Variant = JSON.parse_string(FileAccess.get_file_as_string(cale))
	if not (brut is Dictionary):
		plansa["eroare"] = "fișierul nu e un obiect JSON"
		return plansa
	var date: Dictionary = brut

	plansa["raport"] = float(date.get("raport_latime_inaltime", 0.0))
	if plansa["raport"] <= 0.0:
		plansa["eroare"] = "lipsește „raport_latime_inaltime” sau nu e pozitiv"
		return plansa

	var eroare := _citeste_nodurile(plansa, date)
	if eroare == "":
		eroare = _citeste_drumurile(plansa, date)
	if eroare == "":
		eroare = _citeste_capetele(plansa, date)
	plansa["eroare"] = eroare
	return plansa


static func _citeste_nodurile(plansa: Dictionary, date: Dictionary) -> String:
	var lista: Variant = date.get("noduri", null)
	if not (lista is Array) or (lista as Array).is_empty():
		return "lipsește lista „noduri” sau e goală"

	for brut in lista as Array:
		if not (brut is Dictionary):
			return "un nod nu e un obiect"
		var nod: Dictionary = brut
		var reper := String(nod.get("id", ""))
		if reper == "":
			return "un nod n-are „id”"
		if plansa["poz"].has(reper):
			return "două noduri cu același id: „%s”" % reper
		var poz: Variant = nod.get("poz", null)
		if not (poz is Array) or (poz as Array).size() != 2:
			return "nodul „%s” n-are „poz” de forma [x, y]" % reper
		plansa["ordine"].append(reper)
		plansa["poz"][reper] = Vector2(float(poz[0]), float(poz[1]))
		var fara_iesiri: Array[String] = []
		plansa["spre"][reper] = fara_iesiri
	return ""


static func _citeste_drumurile(plansa: Dictionary, date: Dictionary) -> String:
	var lista: Variant = date.get("drumuri", null)
	if not (lista is Array):
		return "lipsește lista „drumuri”"

	for brut in lista as Array:
		if not (brut is Dictionary):
			return "un drum nu e un obiect"
		var drum: Dictionary = brut
		var de_la := String(drum.get("de_la", ""))
		var la := String(drum.get("la", ""))
		if not plansa["poz"].has(de_la):
			return "un drum pleacă din nodul necunoscut „%s”" % de_la
		if not plansa["poz"].has(la):
			return "drumul %s → „%s” duce într-un nod necunoscut" % [de_la, la]
		if de_la == la:
			return "drumul %s → %s se întoarce în el însuși" % [de_la, la]
		if la in plansa["spre"][de_la]:
			return "drumul %s → %s e scris de două ori" % [de_la, la]

		var puncte: Variant = drum.get("puncte", null)
		if not (puncte is Array) or (puncte as Array).size() < 2:
			return "drumul %s → %s are mai puțin de două puncte" % [de_la, la]
		var trasate: Array[Vector2] = []
		for p in puncte as Array:
			if not (p is Array) or (p as Array).size() != 2:
				return "drumul %s → %s are un punct care nu e [x, y]" % [de_la, la]
			trasate.append(Vector2(float(p[0]), float(p[1])))

		plansa["spre"][de_la].append(la)
		plansa["drumuri"].append({"de_la": de_la, "la": la, "puncte": trasate})
	return ""


static func _citeste_capetele(plansa: Dictionary, date: Dictionary) -> String:
	plansa["start"] = String(date.get("start", ""))
	plansa["boss"] = String(date.get("boss", ""))
	if not plansa["poz"].has(plansa["start"]):
		return "„start” nu e un nod din planșă"
	if not plansa["poz"].has(plansa["boss"]):
		return "„boss” nu e un nod din planșă"
	if plansa["start"] == plansa["boss"]:
		return "„start” și „boss” sunt același nod"
	return ""


# ─────────────────────────────────────────────────────────────
# DIN FRACȚIUNI ÎN PIXELI
# ─────────────────────────────────────────────────────────────

## CUTIA DESENULUI, așezată în zona utilă: scalată UNIFORM și centrată.
##
## „Uniform” înseamnă că x și y se înmulțesc cu ACELAȘI număr. Dacă ar avea
## fiecare factorul lui (adică dacă aș întinde cutia peste toată zona), un drum
## desenat ca un arc de cerc ar ajunge pe ecran un arc de elipsă, iar două
## noduri la distanță egală pe desen ar ieși la distanțe diferite. Toate
## socotelile de mai târziu — „cea mai apropiată pereche de noduri”, „se taie
## drumurile?” — presupun că desenul n-a fost turtit.
##
## Ce se pierde: o fâșie de hârtie neatinsă, pe orizontală sau pe verticală,
## după care dintre proporții e mai „largă”. Prețul ăsta depinde de cât de
## aproape e zona de proporția desenului, și de-aia merită ținut minte cât a
## fost: când pânza stătea sub antet, zona avea 797 × 397 px (raport 2,01) și o
## planșă de raport 1,81 primea 717 × 397 — 40 px goi în stânga și 40 în
## dreapta. De când pânza ține toată pagina, zona are 805 × 459 (raport 1,75),
## planșa primește 805 × 446, iar fâșia pierdută e de 6 px sus și 6 jos.
##
## Morala e mai generală decât cifrele: cutia nu se întinde niciodată, deci
## singurul fel în care câștigi spațiu e să apropii proporția ZONEI de proporția
## desenului. Aici s-a făcut din amândouă părțile — zona a crescut în înălțime
## (vezi `_zona_utila()` din `harta.gd`), iar dacă vreodată e nevoie de și mai
## mult, următorul pas e o planșă desenată mai lată, nu o scalare mincinoasă.
static func cutie(zona: Rect2, raport: float) -> Rect2:
	var inaltime := minf(zona.size.y, zona.size.x / maxf(raport, 0.0001))
	var marime := Vector2(inaltime * raport, inaltime)
	return Rect2(zona.position + (zona.size - marime) * 0.5, marime)


## O fracțiune din cutie, în pixeli pe ecran.
static func in_pixeli(fractie: Vector2, cutia: Rect2) -> Vector2:
	return cutia.position + fractie * cutia.size


# ─────────────────────────────────────────────────────────────
# GRAFUL
# ─────────────────────────────────────────────────────────────

## ADÂNCIMEA fiecărui nod: CEA MAI SCURTĂ distanță, în pași, de la Start.
##
## Întoarce „reper → adâncime”. Nodurile în care nu se poate ajunge din Start
## LIPSESC din rezultat — ceea ce e și felul în care se află că există.
##
## E o parcurgere în lățime (BFS): iei Startul, apoi toți vecinii lui, apoi toți
## vecinii ăstora. Fiindcă mergi „inel cu inel”, prima dată când atingi un nod
## ai ajuns la el pe cel mai scurt drum — n-ai cum să-l atingi mai devreme.
##
## ─────────────────────────────────────────────────────────────
## CE NU MAI E ADEVĂRAT PE O PLANȘĂ, FAȚĂ DE HARTA GENERATĂ
##
## Pe harta generată, adâncimea era un STRAT: toate drumurile mergeau de la
## stratul `d` la `d + 1`, fără excepție. Pe o planșă desenată de mână, unde
## traseele au lungimi diferite, asta nu se mai ține. În `harta_01.json`,
## drumul W2 → C3 pleacă de la adâncimea 4 și ajunge la 3, fiindcă la C3 se mai
## poate ajunge și direct din K, pe un drum mai scurt.
##
## Nu e o greșeală de desen, e ce înseamnă „scurtătură”. Consecința se vede în
## dificultate: bugetul crește cu adâncimea, deci un nod luat pe ocolite poate fi
## mai ușor decât cel dinaintea lui. Alternativa — adâncimea = cel mai LUNG drum
## până la nod — ar fi făcut bugetul monoton, dar ar fi pedepsit scurtăturile:
## mergi pe drumul scurt și totuși te trezești cu inamicii drumului lung.
static func adancimi(plansa: Dictionary) -> Dictionary:
	var gasite := {}
	var start := String(plansa["start"])
	if not plansa["poz"].has(start):
		return gasite

	gasite[start] = 0
	var coada: Array[String] = [start]
	var i := 0
	while i < coada.size():
		var aici := coada[i]
		i += 1
		for spre in plansa["spre"].get(aici, []):
			var urmator := String(spre)
			if not gasite.has(urmator):
				gasite[urmator] = int(gasite[aici]) + 1
				coada.append(urmator)
	return gasite

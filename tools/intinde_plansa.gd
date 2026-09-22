extends Node
## ÎNTINDEREA PLANȘELOR PE CUTIA NOUĂ — o transformare, nu un desen refăcut.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/intinde_plansa.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ
##
## Zona planșelor s-a lărgit: până acum se oprea la 0,838 din lățimea ecranului,
## sub linia cărții, deși hârtia merge până pe la 0,95. Cutia de desen a crescut
## de la 797 la 928 px lățime — dar coordonatele din fișiere sunt fracțiuni
## 0..1 DIN CUTIE, deci o cutie mai lată le duce pe toate spre dreapta, inclusiv
## peste carte.
##
## Le puteam muta cu mâna. N-o fac din două motive: sunt 30 de noduri și 41 de
## drumuri, cu 150 de puncte între ele, iar mâna nu garantează nimic despre
## ordine; și, mai important, dacă mâine se mai schimbă o măsurătoare pe fundal,
## vreau să reglez un număr și să RULEZ, nu să redesenez.
##
## ─────────────────────────────────────────────────────────────
## TRANSFORMAREA: O FORFECARE PE ORIZONTALĂ
##
##   y' = y                               (înălțimea nu se atinge)
##   x' = x · (1 + k · (1 − y)) / (1 + k)
##
## În fișier, y crește ÎN JOS: 0 e marginea de sus a cutiei, 1 e cea de jos.
## Deci factorul e (1 + k) sus și 1 jos, iar împărțirea la (1 + k) îl readuce în
## 0..1 — cu 1,0 atins doar de marginea de sus. Cutia iese un TRAPEZ: lată sus,
## unde hârtia e liberă până la margine, îngustă jos, unde stă cartea.
##
## DE CE NU O SIMPLĂ MĂRIRE. O mărire uniformă ar fi dus și colțul de jos-dreapta
## spre dreapta, adică fix pe piele. Forfecarea dă lățimea acolo unde e hârtie
## liberă și o ia de unde nu e.
##
## DE CE NU STRICĂ ORDINEA. La o înălțime dată, `y` e fix, deci factorul e o
## constantă pozitivă: două puncte de pe același rând se înmulțesc cu același
## număr, deci cine era în stânga rămâne în stânga. Asta NU e o demonstrație că
## drumurile nu se încrucișează (două puncte de pe rânduri diferite se apropie
## sau se depărtează), e doar motivul pentru care nu mă aștept să se strice.
## Ultimul cuvânt îl are `verifica_plansa.gd`.
##
## ─────────────────────────────────────────────────────────────
## CE E MACHETA
##
## Fișierul dinainte de întindere, păstrat în `data/harti/machete/`. Se copiază
## acolo o singură dată, la prima rulare, și de atunci ÎNTOTDEAUNA de acolo se
## citește. Consecința e că unealta se poate rula de câte ori vrei fără să se
## „adune” transformările — a doua rulare nu întinde ce era deja întins, ci
## reface din original cu alt `k`.
##
## Machetele stau într-un SUBDOSAR, nu lângă planșe, fiindcă `verifica_plansa.gd`
## verifică tot ce e în `data/harti/` și n-ar avea cum să treacă: o machetă e
## desenul de dinainte de a ocoli cartea. Un subdosar e mai ieftin decât o
## excepție scrisă în validator.

const Harta := preload("res://scenes/harta/harta.gd")

## Fereastra implicită a proiectului — aceeași ca în validator, fiindcă pe ea se
## aleg și se verifică numerele.
const ECRAN := Vector2(1152.0, 648.0)

## Înălțimea antetului de deasupra pânzei, în scena hărții.
const INALTIME_ANTET := 84.0

## Originea pânzei în fereastră: sub antet, lipită de marginea din stânga.
const ORIGINE_PANZA := Vector2(0.0, INALTIME_ANTET)

const DOSAR_MACHETE := "res://data/harti/machete/"
const SUFIX_MACHETA := "_macheta.json"

## Cât spațiu se cere PESTE strictul necesar, între desen și carte.
##
## Zero ar însemna „atinge cartea, dar nu intră”, adică o planșă care pică la
## prima zecimală schimbată pe fundal. Opt pixeli e cam un sfert de simbol: se
## vede pe ecran că e loc, fără să coste lățime de pomană.
const MARJA := 8.0

## Cu ce pas se caută `k`. Mai fin n-ar schimba nimic vizibil (0,005 înseamnă
## sub un pixel de lățime la bază) și ar da numere urâte în fișier.
const PAS_K := 0.005

## Peste atât, forfecarea ar strânge baza mai mult decât jumătate — dacă o
## planșă cere asta, nu e o problemă de întindere, e un desen care trebuie
## refăcut.
const K_MAXIM := 1.0

## Sub atâția pixeli între două noduri, unealta se plânge — chiar dacă validatorul
## încă spune OK la pragul lui de 72.
##
## Diferența dintre cele două numere e intenționată: 72 e pragul la care două
## SIMBOLURI se ating, deci „stricat”; 80 e pragul la care mai am loc să greșesc
## o măsurătoare pe fundal fără să se strice. Un desen care trece cu un pixel nu
## e un desen bun, e un desen norocos.
const PRAG_COMOD := 80.0

## Câte zecimale se scriu în fișier. Patru înseamnă sub o zecime de pixel pe
## cutia asta — sub pragul la care vreo verificare s-ar clinti.
const ZECIMALE := 4


func _ready() -> void:
	var zona := Harta.zona_utila_din(
		Harta.ZONA_PLANSA, ECRAN, ORIGINE_PANZA,
		Vector2(ECRAN.x, ECRAN.y - INALTIME_ANTET))
	var raport := _raport_cutiei(zona)

	print("Cutia nouă de desen: %.1f × %.1f px, raport %.6f  (fereastra %.0f × %.0f)"
		% [zona.size.x, zona.size.y, raport, ECRAN.x, ECRAN.y])
	var carte := Harta.cartea_din(ECRAN, ORIGINE_PANZA, false)
	print("Cartea: x ≥ %.1f, y ≥ %.1f px; pentru noduri, x ≥ %.1f, y ≥ %.1f px"
		% [carte.position.x, carte.position.y,
			carte.position.x - Harta.retragere().x,
			carte.position.y - Harta.retragere().y])
	print("Margine cerută peste strictul necesar: %.0f px" % MARJA)

	if DirAccess.make_dir_recursive_absolute(DOSAR_MACHETE) != OK \
			and not DirAccess.dir_exists_absolute(DOSAR_MACHETE):
		printerr("nu pot face dosarul %s" % DOSAR_MACHETE)
		get_tree().quit(1)
		return

	var toate_bune := true
	for cale in _planse():
		toate_bune = _intinde(cale, zona, raport) and toate_bune

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"planșele s-au rescris" if toate_bune else "CEVA N-A MERS"])
	print("Rulează acum `verifica_plansa.tscn` — el are ultimul cuvânt.")
	get_tree().quit(0 if toate_bune else 1)


## RAPORTUL CUTIEI NOI: exact cât al zonei, rotunjit ÎN JOS.
##
## `Plansa.cutie()` scalează uniform și centrează, deci o cutie cu raportul zonei
## o umple fix. Rotunjirea în jos nu e un moft: dacă raportul scris în fișier ar
## ieși cu o miime peste cel al zonei, cutia n-ar mai încăpea pe înălțime și ar
## fi micșorată — desenul ar sta centrat, cu câte o fâșie goală sus și jos, în
## loc să atingă marginea din dreapta. În jos, pierzi o miime de pixel din
## lățime și nimic din înălțime.
static func _raport_cutiei(zona: Rect2) -> float:
	var zecimi := pow(10.0, 6)
	return floor(zona.size.x / zona.size.y * zecimi) / zecimi


## Planșele de întins: tot ce e .json direct în `data/harti/`.
func _planse() -> Array[String]:
	var gasite: Array[String] = []
	for nume in DirAccess.get_files_at(Plansa.DOSAR):
		if nume.get_extension().to_lower() == "json":
			gasite.append(Plansa.DOSAR + nume)
	gasite.sort()
	return gasite


func _macheta(cale: String) -> String:
	return DOSAR_MACHETE + cale.get_file().get_basename() + SUFIX_MACHETA


# ─────────────────────────────────────────────────────────────
# O PLANȘĂ, CAP-COADĂ
# ─────────────────────────────────────────────────────────────

func _intinde(cale: String, zona: Rect2, raport: float) -> bool:
	print("")
	print("═══ %s ═══" % cale.get_file())

	var macheta := _macheta(cale)
	if not FileAccess.file_exists(macheta):
		if not _copiaza(cale, macheta):
			return false
		print("    macheta salvată: %s" % macheta)
	else:
		print("    macheta găsită:  %s" % macheta)

	var brut: Variant = JSON.parse_string(FileAccess.get_file_as_string(macheta))
	if not (brut is Dictionary):
		printerr("    macheta nu e un obiect JSON")
		return false
	var date: Dictionary = brut

	var cutia := Plansa.cutie(zona, raport)
	var k := _cauta_k(date, cutia)
	if k < 0.0:
		printerr("    nu există k ≤ %.2f la care desenul să ocolească cartea." % K_MAXIM)
		printerr("    Planșa asta trebuie REDESENATĂ, nu întinsă.")
		return false

	var iesita := _cu_k(date, raport, k)
	var masuri := _masoara(iesita, cutia)

	print("    raport %.4f → %.6f   (cutia: %.0f × %.0f px)"
		% [float(date.get("raport_latime_inaltime", 0.0)), raport,
			cutia.size.x, cutia.size.y])
	print("    k = %.3f   →   lățimea de bază (jos) %.0f px, sus %.0f px"
		% [k, cutia.size.x / (1.0 + k), cutia.size.x])
	print("    spațiu rămas până la carte: noduri %.0f px, drumuri %.0f px"
		% [masuri["spatiu_noduri"], masuri["spatiu_drumuri"]])
	print("    cea mai apropiată pereche de noduri: %.1f px (%s)"
		% [masuri["pereche"], masuri["cine"]])
	if float(masuri["pereche"]) < PRAG_COMOD:
		print("    ATENȚIE: sub %.0f px. Trece de verificarea (7), dar abia."
			% PRAG_COMOD)
		print("    Forfecarea strânge baza trapezului, iar colțul de jos-dreapta al")
		print("    machetei e desenat pentru o bază mai lată. Reparația adevărată e să")
		print("    muți nodurile alea în MACHETĂ și să rulezi din nou, nu să scazi k.")

	return _scrie(cale, iesita)


## Fișierul copiat octet cu octet, ca macheta să fie chiar ce era, cu tot cu
## comentariile `_despre` și cu spațierea lui.
func _copiaza(de_la: String, la: String) -> bool:
	var text := FileAccess.get_file_as_string(de_la)
	if text == "":
		printerr("    nu pot citi %s" % de_la)
		return false
	var f := FileAccess.open(la, FileAccess.WRITE)
	if f == null:
		printerr("    nu pot scrie %s" % la)
		return false
	f.store_string(text)
	f.close()
	return true


func _scrie(cale: String, date: Dictionary) -> bool:
	var f := FileAccess.open(cale, FileAccess.WRITE)
	if f == null:
		printerr("    nu pot scrie %s" % cale)
		return false
	# `sort_keys = false`: altfel Godot scrie cheile alfabetic, iar „start” și
	# „boss” ajung după cele două liste lungi. Ordinea din machetă e ordinea în
	# care se citește un fișier scris de om, și merită păstrată.
	f.store_string(JSON.stringify(date, " ", false) + "\n")
	f.close()
	print("    scris: %s" % cale)
	return true


# ─────────────────────────────────────────────────────────────
# ALEGEREA LUI k
# ─────────────────────────────────────────────────────────────

## CEL MAI MIC `k` LA CARE NIMIC NU MAI CADE PE CARTE, cu `MARJA` pe deasupra.
##
## Cel mai mic, nu unul ales din ochi, fiindcă forfecarea are un preț: cu cât e
## mai mare, cu atât baza trapezului e mai îngustă, iar nodurile de jos se string
## unele în altele. Vreau exact atâta cât trebuie ca să ocolesc cartea, nici un
## pas mai mult.
##
## De ce o căutare și nu o formulă: formula ar fi ieșit din constrângerea unui
## singur nod (cel mai supărător), dar constrângerea se mută de la o planșă la
## alta și, mai ales, drumurile se verifică pe CURBA lor, nu pe punctele scrise.
## Curba iese puțin în afara punctelor la cotituri, iar „puțin” nu se pune într-o
## inegalitate — se măsoară. O căutare cu pas mic măsoară de vreo două sute de
## ori și termină într-o clipă.
##
## Întoarce −1 dacă nu există niciun `k` acceptabil sub `K_MAXIM`.
func _cauta_k(date: Dictionary, cutia: Rect2) -> float:
	var k := 0.0
	while k <= K_MAXIM + 0.0001:
		var masuri := _masoara(_cu_k(date, 1.0, k), cutia)
		if float(masuri["spatiu_noduri"]) >= MARJA \
				and float(masuri["spatiu_drumuri"]) >= MARJA:
			return k
		k += PAS_K
	return -1.0


## Planșa cu coordonatele forfecate. `raport` se scrie în copie; restul
## câmpurilor (`_despre`, `start`, `boss`, `adaugat`…) trec neatinse.
##
## Se lucrează pe o COPIE ADÂNCĂ, nu pe original: `_cauta_k` cheamă funcția asta
## de zeci de ori, iar dacă ar scrie peste date, a doua chemare ar forfeca ce era
## deja forfecat.
func _cu_k(date: Dictionary, raport: float, k: float) -> Dictionary:
	# Cheile de lămurire (cele cu „_”) se copiază întâi, apoi se strecoară nota
	# despre întindere lângă ele, apoi restul. Așa fișierul se citește tot de sus
	# în jos: ce e, cum e făcut, și abia pe urmă cifrele.
	var iesita := {}
	for cheie in date:
		if String(cheie).begins_with("_"):
			iesita[cheie] = date[cheie]
	iesita["_intins"] = ("facut de tools/intinde_plansa.gd din macheta; "
		+ "x' = x * (1 + k * (1 - y)) / (1 + k), k = %.3f; y neatins" % k)
	for cheie in date:
		if not String(cheie).begins_with("_"):
			iesita[cheie] = _copie(date[cheie])
	iesita["raport_latime_inaltime"] = raport

	for nod in iesita.get("noduri", []):
		nod["poz"] = _punct(nod["poz"], k)
	for drum in iesita.get("drumuri", []):
		var puncte := []
		for p in drum.get("puncte", []):
			puncte.append(_punct(p, k))
		drum["puncte"] = puncte
	return iesita


## Copie adâncă pentru liste și dicționare, valoarea însăși pentru restul.
## Numerele și textele n-au ce duplica; listele, da — altfel a doua chemare a lui
## `_cu_k` ar forfeca ce era deja forfecat.
static func _copie(v: Variant) -> Variant:
	if v is Array or v is Dictionary:
		return v.duplicate(true)
	return v


## Un punct [x, y] forfecat și rotunjit.
##
## Rotunjirea se face AICI, o dată, și nu la scris: capătul unui drum și centrul
## nodului lui pleacă din aceeași pereche de numere, deci trebuie să ajungă la
## aceeași pereche rotunjită — altfel verificarea (5) ar găsi o abatere apărută
## din senin, la a patra zecimală.
static func _punct(brut: Variant, k: float) -> Array:
	var x := float(brut[0])
	var y := float(brut[1])
	return [_rotunjit(x * (1.0 + k * (1.0 - y)) / (1.0 + k)), _rotunjit(y)]


static func _rotunjit(v: float) -> float:
	var zecimi := pow(10.0, ZECIMALE)
	return round(v * zecimi) / zecimi


# ─────────────────────────────────────────────────────────────
# MĂSURĂTOAREA
# ─────────────────────────────────────────────────────────────

## Cât spațiu mai e până la carte și cât de apropiate sunt nodurile.
##
## Aceleași două praguri ca în validator, și din același motiv: nodul e un
## simbol de 92 px, deci cartea i se umflă cu `Harta.retragere()`; drumul e o
## linie, deci o atinge așa cum e.
func _masoara(date: Dictionary, cutia: Rect2) -> Dictionary:
	var carte_noduri := Harta.cartea_din(ECRAN, ORIGINE_PANZA, true)
	var carte_drumuri := Harta.cartea_din(ECRAN, ORIGINE_PANZA, false)

	var centre: Array[Vector2] = []
	var nume: Array[String] = []
	var spatiu_noduri := INF
	for nod in date.get("noduri", []):
		var c := Plansa.in_pixeli(_vector(nod["poz"]), cutia)
		centre.append(c)
		nume.append(String(nod.get("id", "?")))
		spatiu_noduri = minf(spatiu_noduri, _cat_pana_la(c, carte_noduri))

	var spatiu_drumuri := INF
	for drum in date.get("drumuri", []):
		var puncte := []
		for p in drum.get("puncte", []):
			puncte.append(Plansa.in_pixeli(_vector(p), cutia))
		for punct in Harta.curba_neteda(puncte).get_baked_points():
			spatiu_drumuri = minf(spatiu_drumuri, _cat_pana_la(punct, carte_drumuri))

	var pereche := INF
	var cine := ""
	for i in range(centre.size()):
		for j in range(i + 1, centre.size()):
			var d := centre[i].distance_to(centre[j])
			if d < pereche:
				pereche = d
				cine = "%s – %s" % [nume[i], nume[j]]

	return {
		"spatiu_noduri": spatiu_noduri,
		"spatiu_drumuri": spatiu_drumuri,
		"pereche": pereche,
		"cine": cine,
	}


## Cât mai e de la punct până la carte, pe axa pe care scapă cel mai ușor.
## Negativ dacă e deja pe ea. Vezi gemenele din `verifica_plansa.gd`.
static func _cat_pana_la(p: Vector2, carte: Rect2) -> float:
	return maxf(carte.position.x - p.x, carte.position.y - p.y)


static func _vector(brut: Variant) -> Vector2:
	return Vector2(float(brut[0]), float(brut[1]))

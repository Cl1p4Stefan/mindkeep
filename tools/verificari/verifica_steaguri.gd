extends Control
## VERIFICAREA STEAGURILOR CU OCHIUL — toate, într-o grilă, cu numele sub fiecare.
##
## Se pornește cu F6 din editor, pe `tools/verificari/verifica_steaguri.tscn`.
##
## ─────────────────────────────────────────────────────────────
## DE CE O SCENĂ, ȘI NU ÎNCĂ UN VERDICT ÎN `verifica_trivia.gd`
##
## Fiindcă e singura verificare pe care un script NU o poate face. Acolo se poate
## afla că fișierul există, că are licență, că nimeni nu l-a uitat orfan în dosar.
## Ce nu se poate afla în niciun fel automat e dacă steagul e CEL BUN: unul vechi,
## unul al țării vecine sau varianta de stat în loc de cea națională trec prin
## toate verificările de mai sus, fiindcă sunt fișiere perfect valide.
##
## Iar riscul nu e închipuit. 21 din 126 de steaguri au fost alese de COD, prin
## rangul preferat din Wikidata, fiindcă țara avea mai multe declarații fără dată
## de sfârșit (vezi `alege_steagul` din `tools/fabrica/capitale.py`). Un mecanism
## care alege în locul meu are nevoie de un loc unde mă uit la ce a ales.
##
## ─────────────────────────────────────────────────────────────
## DE CE CITEȘTE FAPTELE, NU DOSARUL
##
## Ar fi fost mai simplu să înșir fișierele din `assets/imagini_fapte/steaguri/`.
## Dar atunci aș fi verificat un dosar, nu conținutul: un steag ajuns acolo dintr-o
## rulare veche, la care nu mai duce niciun fapt, ar apărea pe ecran ca și cum ar
## fi în joc.
##
## Așa, drumul parcurs aici e chiar drumul pe care-l va face Practice la pasul 13:
## fapt → lista `imagini` → intrarea de tip `steag` → fișierul. Ce nu se vede aici
## nu se va vedea nici acolo.
##
## Numele de sub steag vine din manifestul de credite, fiindcă faptul ține doar un
## `id` (`wd:Q142`), iar „Q142" nu e un lucru la care te poți uita ca să spui „ăsta
## nu e steagul Franței".

# Scriptul disciplinei, încărcat direct — ca în `verifica_trivia.gd`. `Trivia` nu
# e autoload, iar de aici ne trebuie doar căile și `fisierele_generate`, care sunt
# statice. Deci nu se deschide nicio scenă de luptă și nu pornește niciun sunet.
const TRIVIA := preload("res://scenes/trivia/trivia.gd")

const DOSAR_IMAGINI := "res://assets/imagini_fapte"
const CALE_CREDITE := "res://assets/imagini_fapte/steaguri/credite.json"

# Lățimea unei plăcuțe din grilă. Steagurile au rapoarte diferite (2:1 la Qatar,
# 3:2 la majoritate, 1:1 la Elveția), deci se potrivesc pe LĂȚIME și își păstrează
# raportul — un steag întins la o cutie fixă ar arăta greșit chiar dacă e cel bun,
# ceea ce ar strica exact judecata pentru care există scena.
const LATIME_PLACUTA := 168
const INALTIME_IMAGINE := 110


func _ready() -> void:
	var credite := _citeste_creditele()
	var randuri := _steagurile_din_fapte(credite)

	%Antet.text = "STEAGURILE DIN FAPTE — %d" % randuri.size()

	var lipsa := 0
	for r in randuri:
		var placuta := _o_placuta(r)
		if not r["gasit"]:
			lipsa += 1
		%Grila.add_child(placuta)

	# O linie în consolă, ca la celelalte unelte: scena se judecă cu ochiul, dar
	# „câte am văzut" trebuie să fie o cifră, nu o impresie.
	print("Steaguri: %d din fapte, %d fără fișier pe disc, %d fișiere în manifest." % [
		randuri.size(), lipsa, credite.size()
	])

	# Coloanele se recalculează la fiecare redimensionare, nu o dată în `_ready`.
	# În `_ready`, un Control încă n-are mărimea ferestrei — ar ieși o singură
	# coloană, iar scena ar părea stricată din primul moment.
	resized.connect(_aseaza_coloanele)
	_aseaza_coloanele()

	# Ce a rămas în manifest fără să fie cerut de vreun fapt. Nu e o eroare de
	# afișat cu roșu peste tot ecranul — verificatorul o numără oricum — dar
	# trebuie spus, altfel scena ar părea că arată „tot".
	var aratate := {}
	for r in randuri:
		aratate[r["fisier"]] = true
	var nearatate: Array[String] = []
	for fisier in credite:
		if not aratate.has(fisier):
			nearatate.append(fisier)
	if not nearatate.is_empty():
		%Subsol.text = "%d fișiere din manifest nu sunt cerute de niciun fapt: %s" % [
			nearatate.size(), ", ".join(nearatate)
		]
	else:
		%Subsol.text = "Fiecare fișier din manifest e cerut de un fapt."


## Câte plăcuțe încap pe lățimea de acum.
func _aseaza_coloanele() -> void:
	%Grila.columns = maxi(1, int(size.x / (LATIME_PLACUTA + 12.0)))


## Manifestul, pe numele fișierului. De aici vin numele țărilor și creditele.
func _citeste_creditele() -> Dictionary:
	var pe_fisier := {}
	for r in Puzzle.citeste_lista_json(CALE_CREDITE, "Steaguri"):
		pe_fisier[String(r.get("fisier", ""))] = r
	return pe_fisier


## Toate intrările de tip `steag` din toate fișierele de fapte, sortate pe nume.
##
## Se citesc ACELEAȘI fișiere pe care le citește și `trivia.gd`, prin aceeași
## funcție (`fisierele_generate`). O listă scrisă aici ar fi uitat, peste trei
## luni, tabelul adăugat între timp.
func _steagurile_din_fapte(credite: Dictionary) -> Array:
	var cai: Array[String] = [TRIVIA.CALE_FAPTE]
	cai.append_array(TRIVIA.fisierele_generate("_fapte.json"))

	var gasite: Array = []
	for cale in cai:
		for f in Puzzle.citeste_lista_json(cale, "Steaguri"):
			if not (f is Dictionary) or not (f.get("imagini") is Array):
				continue
			for img in f["imagini"]:
				if not (img is Dictionary) or String(img.get("tip", "")) != "steag":
					continue
				var fisier := String(img.get("fisier", ""))
				var din_manifest: Dictionary = credite.get(fisier, {})
				gasite.append({
					"fisier": fisier,
					"id": String(f.get("id", "?")),
					# Numele omenesc e în manifest. Unde lipsește, se arată id-ul —
					# tăcerea ar fi mai rea decât un nume urât.
					"nume": String(din_manifest.get("nume", String(f.get("id", "?")))),
					"licenta": String(img.get("licenta", "")),
					"autor": String(img.get("autor", "")),
					"atribuire": String(img.get("licenta_url", "")) != "",
					"gasit": ResourceLoader.exists("%s/%s" % [DOSAR_IMAGINI, fisier]),
				})
	gasite.sort_custom(func(a, b): return a["nume"].naturalnocasecmp_to(b["nume"]) < 0)
	return gasite


## O plăcuță: steagul, numele țării, și creditul care s-ar afișa în joc.
func _o_placuta(r: Dictionary) -> Control:
	var cutie := VBoxContainer.new()
	cutie.custom_minimum_size = Vector2(LATIME_PLACUTA, 0)
	cutie.add_theme_constant_override("separation", 2)

	var poza := TextureRect.new()
	poza.custom_minimum_size = Vector2(LATIME_PLACUTA, INALTIME_IMAGINE)
	# `KEEP_ASPECT_CENTERED`: raportul steagului e o însușire a steagului. Întins,
	# un steag corect ar părea greșit — și invers.
	poza.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poza.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	if r["gasit"]:
		poza.texture = load("%s/%s" % [DOSAR_IMAGINI, r["fisier"]])
	else:
		# Un chenar roșu în locul steagului. Scena nu se oprește pentru un fișier
		# lipsă: dacă lipsesc trei, vreau să le văd pe toate trei dintr-o privire,
		# nu una pe rulare.
		var lipsa := ColorRect.new()
		lipsa.color = Color(0.45, 0.10, 0.10)
		lipsa.custom_minimum_size = Vector2(LATIME_PLACUTA, INALTIME_IMAGINE)
		cutie.add_child(lipsa)
		poza = null

	if poza != null:
		cutie.add_child(poza)

	var nume := Label.new()
	nume.text = r["nume"]
	nume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nume.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nume.custom_minimum_size = Vector2(LATIME_PLACUTA, 0)
	cutie.add_child(nume)

	# CREDITUL, exact cum îl cere licența. La domeniul public nu e nimic de
	# respectat, deci scrie asta; unde licența cere atribuire, se arată autorul ȘI
	# numele licenței, fiindcă atribuirea CC le cere pe amândouă, nu doar pe unul.
	var credit := Label.new()
	credit.text = ("%s · %s" % [r["autor"], r["licenta"]]) if r["atribuire"] else "domeniu public"
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credit.custom_minimum_size = Vector2(LATIME_PLACUTA, 0)
	credit.add_theme_font_size_override("font_size", 11)
	credit.modulate = Color(1, 1, 1, 0.55)
	cutie.add_child(credit)

	return cutie

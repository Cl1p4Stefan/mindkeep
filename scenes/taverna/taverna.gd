extends Control
## TAVERNA — al treilea mod de joc, și camera în care stau jocurile de masă.
##
## Expediția e harta, luptele, cronometrul inamicului. Practice e cultură
## generală pe raftul ales. Taverna e locul în care te așezi la o masă și joci
## un joc întreg: Cuvântul Ascuns azi, Sudoku și Decretul Zilei scrise în
## catalog, stinse.
##
## ─────────────────────────────────────────────────────────────
## CE E, ȘI CE NU E
##
## **Nu e Turnul Perseverenței.** Turnul, din pitch, e un MOD DE RUN fără ceas:
## etaje, progresie, un capăt. Taverna nu are run — intri, joci o partidă,
## pleci. Au în comun doar lipsa cronometrului, iar aia nu e o mecanică, e o
## absență. Turnul rămâne în pitch și vine mai târziu, cu etajele lui; când
## vine, el poate FOLOSI mesele de aici, fiindcă `joc.gd` nu știe nimic despre
## cine l-a deschis — exact ca scenele de puzzle, care nu știu nimic despre
## luptă.
##
## **Nu plătește nimic.** Nici Monede, nici Fragmente, nicio statistică. Pitch-ul
## cere economie comună între moduri, și va fi — dar Cetatea nu există, deci nu
## se știe încă ce cumperi cu o Monedă. Un număr pus azi ar fi inventat, ar
## intra în save, și ar trebui reechilibrat mai târziu CU migrare. Deci ziua în
## care Taverna plătește e ziua în care există ce cumperi.
##
## Ce se scrie totuși pe disc: SACUL cuvintelor ieșite (`Sac.Durata.PERMANENT`).
## Nu e o recompensă, e o memorie — fără ea, al doilea cuvânt al zilei ar putea
## fi primul.
##
## ─────────────────────────────────────────────────────────────
## DE CE TAVERNA E ATÂT DE SUBȚIRE
##
## Aceeași regulă ca la meniul de start: ea DESCHIDE o masă și nu știe nimic
## despre ce se întâmplă acolo. Nu știe ce e o literă, un rând sau o grilă; nu
## știe când ai greșit; nu știe nici măcar dacă jocul are taste. Tot ce face e:
## instanțiază scena din catalog, o pune în chenar, îi cheamă `porneste()` și
## ascultă semnalul `terminat`.
##
## Dovada că despărțirea ține: când va intra Sudoku, fișierul ăsta nu se atinge.
## Dacă s-ar atinge, ar însemna că am scris aici ceva ce era al mesei.
##
## ─────────────────────────────────────────────────────────────
## DOUĂ ECRANE, CA LA PRACTICE
##
## `PanouMese` (alegi masa) și `PanouJoc` (joci). Nu două scene: trecerea între
## ele e instantanee și nu are nimic de încărcat, iar două scene ar fi însemnat
## două fundaluri și două teme care trebuie ținute la fel. Practice face la fel
## cu domeniu → raft → întrebare.
##
## MUZICA e `CETATE`, piesa liniștită — aceeași ca în meniu. `LUPTA` ar fi
## minciună într-o cameră fără ceas.

const SCENA_MENIU := "res://scenes/meniu/meniu.tscn"

## Lățimea unei mese pe ecran. Trei mese × 300 + două goluri de 28 = 956 px pe o
## pânză de 1152, cu margini de 28 — adică mai încap. A patra masă NU mai
## încape pe un rând, și atunci lista devine o grilă de două coloane, exact ce
## s-a întâmplat la ecranul de loadout când a venit a șaptea disciplină. Scris
## de pe acum ca ziua aia să fie o linie, nu o surpriză.
const LATIME_MASA := 300

## Culoarea rândului de rezultat: verdele și portocaliul de verdict din
## `Puzzle`, ca „am reușit" să arate la fel în tot jocul.
const CULOARE_REUSIT := Color(0.18, 0.42, 0.18)
const CULOARE_RATAT := Color(0.55, 0.22, 0.12)

@onready var titlu: Label = %Titlu
@onready var ajutor: Label = %Ajutor
@onready var panou_mese: Control = %PanouMese
@onready var lista_mese: HBoxContainer = %Mese
@onready var panou_joc: Control = %PanouJoc
@onready var zona_joc: PanelContainer = %ZonaJoc
@onready var rand_rezultat: Control = %RandRezultat
@onready var rezultat: Label = %Rezultat
@onready var buton_inca_unul: Button = %ButonIncaUnul
@onready var buton_mese: Button = %ButonMese
@onready var buton_meniu: Button = %ButonMeniu

## Masa deschisă acum (rândul din catalog), sau gol.
var masa_curenta := {}
## Jocul instanțiat, sau `null`.
var joc: Joc = null


func _ready() -> void:
	buton_meniu.pressed.connect(_pe_meniu)
	buton_mese.pressed.connect(_arata_mesele)
	buton_inca_unul.pressed.connect(_inca_unul)
	Muzica.reda(Muzica.Piesa.CETATE)
	_arata_mesele()


# ─────────────────────────────────────────────────────────────
# ECRANUL CU MESE
# ─────────────────────────────────────────────────────────────

func _arata_mesele() -> void:
	_inchide_jocul()
	panou_mese.visible = true
	panou_joc.visible = false
	# „Mesele" e drumul de întoarcere DIN joc; pe ecranul cu mese n-ar duce
	# nicăieri. Un buton care nu face nimic e mai rău decât niciunul: te face
	# să te întrebi ce-ai ratat.
	buton_mese.visible = false
	titlu.text = "TAVERNA"
	# Numărul nu e scris de mână: vine din catalog, deci rândul ăsta rămâne
	# adevărat când apare a doua masă. Aceeași regulă ca la „ALEGE 3 UNELTE".
	var gata := Mese.cate_sunt_gata()
	ajutor.text = "%s, fără cronometru. Joci cât vrei." % _jocuri(gata)

	for copil in lista_mese.get_children():
		copil.queue_free()
	for m in Mese.CATALOG:
		lista_mese.add_child(_carte_masa(m))


## „1 joc", „2 jocuri", „20 de jocuri" — aceeași politețe cu româna ca la
## nodurile din meniu.
func _jocuri(n: int) -> String:
	if n == 1:
		return "1 joc pe masă"
	var rest := n % 100
	if n < 20 or (rest >= 1 and rest <= 19):
		return "%d jocuri pe masă" % n
	return "%d de jocuri pe masă" % n


## O masă, ca pagină de pergament. Aceeași formă ca paginile din meniu, ca să
## se recunoască drept „locuri în care intri", nu butoane.
##
## O masă fără scenă apare STINSĂ, nu lipsește. Vezi antetul lui `mese.gd`:
## un raft ascuns e un raft despre care nu afli niciodată nimic.
func _carte_masa(m: Dictionary) -> Control:
	var gata := String(m["scena"]) != ""

	var carte := PanelContainer.new()
	carte.theme_type_variation = &"ChenarPergament"
	carte.custom_minimum_size = Vector2(LATIME_MASA, 0)
	if not gata:
		carte.modulate = Color(1, 1, 1, 0.55)

	var margini := MarginContainer.new()
	margini.add_theme_constant_override("margin_left", 20)
	margini.add_theme_constant_override("margin_right", 20)
	margini.add_theme_constant_override("margin_top", 16)
	margini.add_theme_constant_override("margin_bottom", 18)
	carte.add_child(margini)

	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 8)
	margini.add_child(coloana)

	var nume := Label.new()
	nume.text = String(m["nume"])
	nume.theme_type_variation = &"TitluPergament"
	nume.add_theme_font_size_override("font_size", 22)
	nume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nume.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coloana.add_child(nume)

	var rol := Label.new()
	rol.text = String(m["rol"])
	rol.theme_type_variation = &"SubtitluPergament"
	rol.add_theme_font_size_override("font_size", 15)
	rol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rol.custom_minimum_size = Vector2(0, 56)
	coloana.add_child(rol)

	var gol := Control.new()
	gol.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coloana.add_child(gol)

	var buton := Button.new()
	buton.theme_type_variation = &"ButonRubrica"
	buton.custom_minimum_size = Vector2(0, 42)
	buton.add_theme_font_size_override("font_size", 16)
	if gata:
		buton.text = "Așază-te"
		buton.pressed.connect(_deschide_masa.bind(m))
	else:
		buton.text = "În lucru"
		buton.disabled = true
	coloana.add_child(buton)

	return carte


# ─────────────────────────────────────────────────────────────
# MASA DESCHISĂ
# ─────────────────────────────────────────────────────────────

func _deschide_masa(m: Dictionary) -> void:
	masa_curenta = m
	panou_mese.visible = false
	panou_joc.visible = true
	buton_mese.visible = true
	titlu.text = String(m["nume"])
	_porneste_jocul()


## Instanțiază masa și pornește o partidă.
##
## Ordinea e cea din Practice, și contează: scena intră în arbore ÎNTÂI
## (`add_child`, deci `_ready`-ul ei a rulat și nodurile lui există) și abia pe
## urmă i se cheamă `porneste()`. Invers, `%Grila` ar fi fost încă `null`.
func _porneste_jocul() -> void:
	_inchide_jocul()
	rand_rezultat.visible = false

	var cale := String(masa_curenta["scena"])
	var scena: PackedScene = load(cale)
	if scena == null:
		ajutor.text = "Masa nu s-a putut deschide (%s)." % cale
		return

	var nou := scena.instantiate()
	joc = nou as Joc
	if joc == null:
		# O scenă care nu e un `Joc` nu poate fi pornită și n-ar striga
		# niciodată `terminat` — adică ecranul ar aștepta la nesfârșit. Mai bine
		# se spune. Bătut și de `verifica_taverna`, ca să nu se afle în joc.
		push_error("Masa %s nu extinde `Joc`." % cale)
		ajutor.text = "Masa nu e scrisă ca un joc de tavernă."
		nou.queue_free()
		return

	joc.terminat.connect(_pe_joc_terminat)
	zona_joc.add_child(joc)
	joc.porneste(Joc.SAMANTA_LIBERA)
	ajutor.text = joc.rand_de_ajutor()
	# Tastatura adevărată: `_unhandled_key_input` al jocului primește tastele
	# doar dacă nu le mănâncă altcineva înainte — iar un BUTON cu focus mănâncă
	# Enter (pentru el, Enter înseamnă „apasă-mă"). Deci focusul se eliberează
	# în clipa în care masa se deschide. Nu se MUTĂ pe joc: un `Control` n-are
	# focus (`FOCUS_NONE` e implicit), și oricum `_unhandled_key_input` ajunge
	# la toată scena, nu doar la nodul cu focus.
	get_viewport().gui_release_focus()


func _pe_joc_terminat(rez: Dictionary) -> void:
	var reusit := bool(rez.get("reusit", false))
	rezultat.text = ("Ai găsit! " if reusit else "Nu l-ai găsit. ") + String(rez.get("rezumat", ""))
	rezultat.add_theme_color_override("font_color",
		CULOARE_REUSIT if reusit else CULOARE_RATAT)
	rand_rezultat.visible = true
	# Jocul RĂMÂNE pe ecran, nu e înlocuit de un ecran de rezultat: la Cuvântul
	# Ascuns, grila terminată E ce vrei să te uiți la ea după ce s-a terminat.
	# Un panou peste ea ar fi ascuns exact lucrul pe care l-ai câștigat.
	buton_inca_unul.grab_focus()
	# Sacul cuvintelor ieșite trece pe disc. Apelul de salvare stă în SCENĂ, nu
	# în `Sac`, din motivul scris în CLAUDE.md: uneltele de verificare trag mii
	# de bilete și n-au voie să atingă save-ul adevărat.
	Arhiva.salveaza_permanent()


func _inca_unul() -> void:
	_porneste_jocul()


## Scoate jocul din arbore. `queue_free` singur n-ar fi de-ajuns: nodul mai
## trăiește până la finalul cadrului, iar semnalul lui tot ar putea ajunge la
## `_pe_joc_terminat` după ce ecranul s-a schimbat.
func _inchide_jocul() -> void:
	if joc == null:
		return
	if joc.terminat.is_connected(_pe_joc_terminat):
		joc.terminat.disconnect(_pe_joc_terminat)
	joc.queue_free()
	joc = null


func _pe_meniu() -> void:
	# Sacul se scrie și la plecare: un cuvânt consumat fără să-l termini e tot
	# un cuvânt consumat.
	Arhiva.salveaza_permanent()
	get_tree().change_scene_to_file(SCENA_MENIU)

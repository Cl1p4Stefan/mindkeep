extends Control
## TAVERNA — al treilea mod de joc, și camera în care stau jocurile de masă.
##
## Expediția e harta, luptele, cronometrul inamicului. Practice e cultură
## generală pe raftul ales. Taverna e locul în care te așezi la o masă și joci
## un joc întreg: Cuvântul Ascuns și Sudoku azi, Decretul Zilei scris în
## catalog, stins.
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
## Dovada s-a cerut pe 4 noiembrie 2026, când a intrat Sudoku, și e mai bună
## decât lauda scrisă aici înainte („fișierul ăsta nu se atinge"): s-a atins, în
## DOUĂ rânduri, și fiecare din ele era un loc în care scrisesem aici ceva ce
## era al mesei.
##
##   1. „Ai găsit! " — prefixul rândului de rezultat. Vocea Cuvântului Ascuns.
##      Vezi `_pe_joc_terminat`.
##   2. `pornita` — o masă se poate reporni singură, iar Taverna n-avea cum s-o
##      afle. Un semnal în `joc.gd`, un connect aici. Vezi `Joc.pornita`.
##
## Restul a ținut: nici alegerea mesei, nici panoul cu reguli, nici ecranele,
## nici ce se scrie pe disc n-au simțit nimic. O lăudăroșenie dovedită pe
## jumătate spune mai mult despre despărțire decât una nedovedită.
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
@onready var buton_reguli: Button = %ButonReguli
@onready var panou_reguli: Control = %PanouReguli
@onready var reguli_titlu: Label = %ReguliTitlu
@onready var reguli_cuprins: MarginContainer = %Cuprins
@onready var buton_inchide_reguli: Button = %ButonInchideReguli
@onready var suprapunere: Control = %Suprapunere

## Mesele la care regulile ți s-au arătat deja, pe cheie: `{"cuvantul_ascuns": true}`.
##
## `static`, ca `_nivel_atins` din Practice, și din același motiv: Taverna e o
## SCENĂ, care se naște din nou la fiecare intrare. O variabilă de instanță ar
## fi pornit goală, deci regulile s-ar fi arătat „o dată" la fiecare venire în
## tavernă — adică de fiecare dată.
##
## PE CHEIE, nu un singur adevăr: când Sudoku va fi scris, regulile LUI trebuie
## să se arate o dată, chiar dacă ai citit deja regulile Cuvântului Ascuns.
## Două mese, două prime dăți. Cheia e cea din catalog (un TEXT, nu poziția în
## listă), deci rândurile se pot muta între ele fără ca nimeni să-și uite
## regulile citite.
static var _reguli_vazute := {}

## Masa deschisă acum (rândul din catalog), sau gol.
var masa_curenta := {}
## Jocul instanțiat, sau `null`.
var joc: Joc = null


func _ready() -> void:
	buton_meniu.pressed.connect(_pe_meniu)
	buton_mese.pressed.connect(_arata_mesele)
	buton_inca_unul.pressed.connect(_inca_unul)
	buton_reguli.pressed.connect(_arata_regulile)
	buton_inchide_reguli.pressed.connect(_inchide_regulile)
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
	# Regulile sunt ale unei MESE. Pe ecranul cu mese n-ai deschis niciuna,
	# deci butonul n-ar ști ale cui reguli să arate — aceeași judecată ca la
	# „Mesele", care tot aici se ascunde.
	buton_reguli.visible = false
	_inchide_regulile()
	_goleste_cuprinsul()
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
	_poate_prima_oara()


## PRIMA AȘEZARE la o masă îi deschide regulile. A doua, nu.
##
## Se cheamă din `_deschide_masa`, nu din `_porneste_jocul`: a doua pornește și
## la „Încă unul", iar un panou de reguli peste a treia partidă la rând ar fi
## chiar lucrul pe care „o singură dată" îl promite că nu se întâmplă.
##
## Steagul se scrie pe disc IMEDIAT, nu la plecarea din tavernă: altfel un joc
## închis din colțul ferestrei ar fi lăsat „prima dată" nescrisă, iar regulile
## s-ar fi deschis a doua oară — adică exact ce ți s-a promis că nu face.
func _poate_prima_oara() -> void:
	if joc == null or not buton_reguli.visible:
		return
	var cheie := String(masa_curenta.get("cheie", ""))
	if cheie == "" or _reguli_vazute.has(cheie):
		return
	_reguli_vazute[cheie] = true
	Arhiva.salveaza_permanent()
	_arata_regulile()


# ─────────────────────────────────────────────────────────────
# PANOUL CU REGULI
#
# Un panou desenat de mine, nu un `AcceptDialog` — aceeași alegere, din același
# motiv, ca la popup-ul „Află mai multe" din Practice: o fereastră de sistem ar
# fi venit cu tema ei peste o cameră care și-a ales fiecare culoare.
#
# UMBRA E CE-L FACE MODAL pentru mouse (`ColorRect` oprește clickurile din
# fabrică). Pentru TASTE nu e de-ajuns, și aici e deosebirea față de Practice:
# masa ascultă tastatura adevărată prin `_unhandled_key_input`, deci cu panoul
# deschis ai fi scris litere în grilă în timp ce citeai regulile despre ea.
# De-aia jocului i se oprește ascultarea cât ține panoul.
# ─────────────────────────────────────────────────────────────

func _arata_regulile() -> void:
	if joc == null:
		return
	if reguli_cuprins.get_child_count() == 0:
		return
	panou_reguli.visible = true
	if joc != null:
		joc.set_process_unhandled_key_input(false)
	# Focusul pe buton, deci Enter sau Space închid panoul fără mouse.
	buton_inchide_reguli.grab_focus()


## Închide panoul. Fără gardă pe „era deschis?", ca la Practice: a-l închide de
## două ori trebuie să coste cât o dată, altfel fiecare loc care-l cheamă ar
## avea nevoie de propriul `if`.
func _inchide_regulile() -> void:
	if not panou_reguli.visible:
		return
	panou_reguli.visible = false
	if joc != null:
		joc.set_process_unhandled_key_input(true)
		# Focusul NU se mută pe alt buton, ci se eliberează: un buton cu focus
		# mănâncă Enter, iar Enter e tasta cu care trimiți rândul. Același
		# motiv, scris la fel, ca în `_porneste_jocul`.
		get_viewport().gui_release_focus()


## Îngroapă nodul cu reguli al mesei de dinainte. Chemat la fiecare deschidere
## de masă și la întoarcerea în sala cu mese — altfel regulile Cuvântului
## Ascuns ar fi rămas în panou când se va așeza cineva la Sudoku.
func _goleste_cuprinsul() -> void:
	for copil in reguli_cuprins.get_children():
		reguli_cuprins.remove_child(copil)
		copil.queue_free()


## ESCAPE închide panoul, fiindcă asta face Escape peste orice se deschide
## deasupra a altceva. `_unhandled_input`, deci butoanele primesc întâi ce e al
## lor.
func _unhandled_input(event: InputEvent) -> void:
	if not panou_reguli.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_inchide_regulile()
		get_viewport().set_input_as_handled()


## Instanțiază masa și pornește o partidă.
##
## Ordinea e cea din Practice, și contează: scena intră în arbore ÎNTÂI
## (`add_child`, deci `_ready`-ul ei a rulat și nodurile lui există) și abia pe
## urmă i se cheamă `porneste()`. Invers, `%Grila` ar fi fost încă `null`.
func _porneste_jocul() -> void:
	_inchide_jocul()
	_arata_rezultatul(false)

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
	# O masă se poate reporni singură (Sudoku, de pe tăblie): atunci rândul cu
	# rezultatul partidei de dinainte trebuie să se închidă. Vezi `Joc.pornita`.
	joc.pornita.connect(_pe_joc_pornit)
	zona_joc.add_child(joc)
	joc.porneste(Joc.SAMANTA_LIBERA)
	ajutor.text = joc.rand_de_ajutor()
	# Butonul „i" e al MESEI, nu al Tavernei: o masă care nu-și scrie regulile
	# (vezi `Joc.reguli`) nu primește un buton care deschide un panou gol.
	# Regulile se construiesc O DATĂ, la deschiderea mesei, și stau în panou
	# până pleci de la ea. Nu la fiecare apăsare pe „i": nodul nu se schimbă
	# între două deschideri, iar construit de fiecare dată ar fi însemnat și un
	# al doilea drum doar ca să aflu DACĂ masa are reguli.
	_goleste_cuprinsul()
	var cuprins := joc.reguli()
	buton_reguli.visible = cuprins != null
	if cuprins != null:
		reguli_cuprins.add_child(cuprins)
	# Suprapunerea e fratele jocului în același `PanelContainer`, iar un
	# `PanelContainer` desenează copiii în ordinea din arbore. Jocul tocmai a
	# intrat ULTIMUL, deci ar fi acoperit butonul — îl trimitem înapoi deasupra.
	#
	# Și de-aia suprapunerea trebuie să aibă `mouse_filter = IGNORE` (pus în
	# scenă): un `PanelContainer` întinde fiecare copil peste tot, deci
	# suprapunerea acoperă masa ÎNTREAGĂ, iar ea e deasupra. Cu `PASS` — ce
	# avea până pe 4 noiembrie 2026 — clicurile se opreau în ea: `PASS` nu
	# înseamnă „lasă-l să treacă la ce e dedesubt", înseamnă „primește-l și
	# trimite-l PĂRINTELUI". Nimic din masă n-a fost apăsabil cu mouse-ul: nici
	# pătratele de Sudoku, nici tastatura de pe ecran a Cuvântului Ascuns. S-a
	# văzut abia la a doua masă, fiindcă la prima mouse-ul avea un înlocuitor
	# (tastatura adevărată) și nimeni nu-l încercase. Cu `IGNORE`, căutarea
	# coboară în continuare la copiii suprapunerii, deci butonul „i" primește
	# ce e al lui — numai pânza goală din jurul lui nu mai oprește nimic.
	# Bătut de `verifica_taverna`, pe amândouă mesele.
	zona_joc.move_child(suprapunere, -1)
	# Tastatura adevărată: `_unhandled_key_input` al jocului primește tastele
	# doar dacă nu le mănâncă altcineva înainte — iar un BUTON cu focus mănâncă
	# Enter (pentru el, Enter înseamnă „apasă-mă"). Deci focusul se eliberează
	# în clipa în care masa se deschide. Nu se MUTĂ pe joc: un `Control` n-are
	# focus (`FOCUS_NONE` e implicit), și oricum `_unhandled_key_input` ajunge
	# la toată scena, nu doar la nodul cu focus.
	get_viewport().gui_release_focus()


## O partidă nouă a început — poate la cererea mea, poate pornită de masă.
func _pe_joc_pornit() -> void:
	_arata_rezultatul(false)


## Rândul de rezultat poartă FRAZA MESEI, întreagă.
##
## A fost, o zi, „Ai găsit! " + fraza, iar prefixul venea de aici. Sudoku l-a
## dat de gol: „Ai găsit! Grila mediu, completată fără nicio greșeală." Prefixul
## nu era al Tavernei, era VOCEA Cuvântului Ascuns, scrisă în fișierul greșit —
## iar antetul de mai sus se lăuda că fișierul ăsta nu se atinge când intră a
## doua masă. S-a atins, exact în rândul în care presupusese ceva despre ce se
## joacă la masă.
##
## Ce rămâne al Tavernei e CULOAREA, și ea pe bună dreptate: „reușit" e în
## contract, deci verdele și portocaliul sunt ale ei. Ce s-a reușit e al mesei.
func _pe_joc_terminat(rez: Dictionary) -> void:
	var reusit := bool(rez.get("reusit", false))
	rezultat.text = String(rez.get("rezumat", ""))
	rezultat.add_theme_color_override("font_color",
		CULOARE_REUSIT if reusit else CULOARE_RATAT)
	_arata_rezultatul(true)
	# Jocul RĂMÂNE pe ecran, nu e înlocuit de un ecran de rezultat: la Cuvântul
	# Ascuns, grila terminată E ce vrei să te uiți la ea după ce s-a terminat.
	# Un panou peste ea ar fi ascuns exact lucrul pe care l-ai câștigat.
	buton_inca_unul.grab_focus()
	# Sacul cuvintelor ieșite trece pe disc. Apelul de salvare stă în SCENĂ, nu
	# în `Sac`, din motivul scris în CLAUDE.md: uneltele de verificare trag mii
	# de bilete și n-au voie să atingă save-ul adevărat.
	Arhiva.salveaza_permanent()


## Rândul de rezultat se GOLEȘTE, nu se ascunde.
##
## Ascuns, el ieșea din socoteala containerului, iar la finalul partidei
## reintra și fura 52 px de la chenarul mesei — adică grila și tastatura, care
## intrau fix, cădeau brusc pe sub marginea de jos. Exact ce-ai fi văzut: un
## joc încadrat bine până în clipa în care l-ai câștigat.
##
## Deci locul lui e rezervat de la început (`custom_minimum_size` pe rând, în
## scenă), iar ce apare și dispare sunt cei doi copii ai lui. Un ecran care își
## schimbă înălțimea la jumătatea unui joc e un ecran care se poate strica doar
## într-una din stările lui — adică cea în care nu te uiți când îl măsori.
func _arata_rezultatul(da: bool) -> void:
	rezultat.visible = da
	buton_inca_unul.visible = da


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
	if joc.pornita.is_connected(_pe_joc_pornit):
		joc.pornita.disconnect(_pe_joc_pornit)
	joc.queue_free()
	joc = null


func _pe_meniu() -> void:
	# Sacul se scrie și la plecare: un cuvânt consumat fără să-l termini e tot
	# un cuvânt consumat.
	Arhiva.salveaza_permanent()
	get_tree().change_scene_to_file(SCENA_MENIU)


# ─────────────────────────────────────────────────────────────
# CE SE SCRIE PE DISC
#
# Doar regulile citite. Scorurile, seriile și Monedele nu există încă — vezi
# „Nu plătește nimic" din antet — iar un câmp pus azi ar fi un număr inventat
# care intră în save și cere migrare mâine.
#
# Forma e cea de la Practice: starea stă în SCENA care o produce, iar `Arhiva`
# doar adună dicționarele. O LISTĂ de chei, nu dicționarul din memorie: pe disc
# „ce mese am văzut" e o enumerare, iar valorile `true` ar fi fost un `da`
# scris de 10 ori lângă 10 chei care există tocmai fiindcă răspunsul e da.
# ─────────────────────────────────────────────────────────────

static func spre_dictionar() -> Dictionary:
	var chei := _reguli_vazute.keys()
	chei.sort()   # ca două salvări ale aceleiași stări să dea același fișier
	return {"reguli_vazute": chei}


## Citit strâmb, ca peste tot: cheie lipsă = n-ai văzut nimic, altceva decât o
## listă = la fel. Un save mai vechi (fără cheia asta) deschide regulile o dată,
## ceea ce e chiar purtarea de la prima instalare — deci nu are nevoie de
## migrare.
static func din_dictionar(date: Dictionary) -> void:
	_reguli_vazute.clear()
	var lista = date.get("reguli_vazute")
	if lista is Array:
		for cheie in lista:
			_reguli_vazute[String(cheie)] = true

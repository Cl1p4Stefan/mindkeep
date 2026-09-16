extends Control
## ECRANUL DE EXPEDIȚIE — loadout, hartă, sumar.
##
## Trei ecrane într-o scenă, fiindcă sunt trei momente ale ACELUIAȘI lucru:
## îți alegi uneltele, mergi pe drum, afli ce-a ieșit. Ca panourile din luptă
## (jurnal, card, verdict), stau unul peste altul și se arată pe rând.
##
## ─────────────────────────────────────────────────────────────
## CINE DEȚINE CE
##
## Ecranul ăsta nu deține NIMIC din expediție. Toată starea e în
## `autoload/expeditie.gd`; aici se citește și se desenează. Regula se vede cel
## mai bine la PV: harta îl AFIȘEAZĂ, lupta îl SCADE, dar niciuna nu-l ține —
## fiindcă amândouă sunt scene care mor la schimbarea de scenă, iar PV-ul nu
## are voie să moară cu ele.
##
## Consecința practică: poți închide jocul pe hartă, îl redeschizi, și dacă
## `Expeditie` a fost încărcată din save, ecranul ăsta se redesenează identic
## fără să știe că s-a întâmplat ceva.
##
## ─────────────────────────────────────────────────────────────
## CUM CURGE
##
##   `_ready()` se uită la starea expediției și deschide ecranul potrivit:
##     fără expediție        → LOADOUT
##     expediție încheiată   → SUMAR
##     expediție în mers     → HARTA
##
## Asta e tot. Nu există „de unde am venit": ecranul nu ține minte dacă ai
## ajuns aici din meniu, dintr-o victorie sau dintr-o înfrângere, fiindcă
## starea spune deja totul. Un ecran care ar trebui să știe pe ce drum a fost
## deschis e un ecran care se va deschide greșit, într-o zi, pe al patrulea drum.

const SCENA_LUPTA := "res://scenes/lupta/lupta.tscn"

# ── GEOMETRIA HĂRȚII ──────────────────────────────────────────
# Nodurile NU stau într-un container. Un VBox/HBox le-ar așeza în rânduri
# drepte, dar o hartă are nevoie ca nodul 3 de pe rândul 2 să fie EXACT
# deasupra spațiului dintre nodurile 1 și 2 — altfel liniile dintre ele nu mai
# arată a drum, ci a tabel. Deci le punem noi, cu `position`, iar pânza
# desenează liniile între centrele lor.
const MARIME_NOD := Vector2(120, 52)
const MARGINE_PANZA := 24.0       ## spațiu până la marginea zonei de hartă
const GROSIME_DRUM := 3.0
const GROSIME_DRUM_ALES := 4.0

## Culorile drumurilor. Trei stări, trei nuanțe:
##   parcurs   — pe unde ai fost deja. Auriu stins: e istorie, nu opțiune.
##   deschis   — de unde ești, spre unde poți merge. Cel mai luminos.
##   inchis    — restul hărții. Abia vizibil, dar VIZIBIL: vrei să vezi ce n-ai
##               ales, altfel alegerea nu are greutate.
const CULOARE_DRUM_PARCURS := Color(0.85, 0.72, 0.40, 0.55)
const CULOARE_DRUM_DESCHIS := Color(0.95, 0.85, 0.55, 0.95)
const CULOARE_DRUM_INCHIS := Color(0.40, 0.40, 0.50, 0.40)

const CULOARE_NOD_INCHIS := Color(0.45, 0.45, 0.55)
const CULOARE_NOD_PARCURS := Color(0.70, 0.62, 0.42)

@onready var eticheta_titlu: Label = %Titlu
@onready var eticheta_stare: Label = %Stare
@onready var eticheta_loadout: Label = %Loadout
@onready var eticheta_picior: Label = %Picior
@onready var panza: Control = %Panza

@onready var panou_loadout: Control = %PanouLoadout
@onready var loadout_subtitlu: Label = %LoadoutSubtitlu
@onready var loadout_lista: VBoxContainer = %LoadoutLista
@onready var camp_samanta: LineEdit = %CampSamanta
@onready var buton_loadout: Button = %LoadoutButon

@onready var panou_sumar: Control = %PanouSumar
@onready var sumar_titlu: Label = %SumarTitlu
@onready var sumar_text: Label = %SumarText
@onready var sumar_randuri: VBoxContainer = %SumarRanduri
@onready var buton_sumar: Button = %SumarButon

@onready var panou_mesaj: Control = %PanouMesaj
@onready var mesaj_titlu: Label = %MesajTitlu
@onready var mesaj_text: Label = %MesajText
@onready var buton_mesaj: Button = %MesajButon

## Ce discipline sunt bifate în ecranul de loadout. Trăiește doar cât ține
## ecranul: din clipa în care apeși „Pornește", adevărul e `Expeditie.loadout`.
var alese: Array[String] = []

## Butoanele nodurilor, ca să le pot reașeza la redimensionarea ferestrei
## fără să reconstruiesc harta. „id de nod → buton".
var butoane_nod := {}


func _ready() -> void:
	buton_loadout.pressed.connect(_pe_pornire)
	buton_sumar.pressed.connect(_pe_expeditie_noua)
	buton_mesaj.pressed.connect(_pe_mesaj_inchis)
	# Fereastra redimensionată ⇒ nodurile trebuie reașezate. Semnalul vine de
	# la pânză, nu de la fereastră: pe noi ne interesează cât spațiu a primit
	# ZONA DE HARTĂ, care depinde și de cât ocupă antetul de deasupra.
	panza.resized.connect(_aseaza_nodurile)

	panou_loadout.visible = false
	panou_sumar.visible = false
	panou_mesaj.visible = false

	Muzica.reda(Muzica.Piesa.HARTA)

	# Un singur loc în care se decide ce ecran vezi — vezi antetul.
	if Expeditie.final != "":
		_arata_sumar()
	elif not Expeditie.activa:
		_arata_loadout()
	else:
		_dupa_un_nod()


# ─────────────────────────────────────────────────────────────
# ECRANUL 1: LOADOUT — „alege N din M"
# ─────────────────────────────────────────────────────────────

func _arata_loadout() -> void:
	alese.clear()
	panou_loadout.visible = true
	eticheta_titlu.text = "EXPEDITIE"
	eticheta_stare.text = ""
	eticheta_loadout.text = ""
	eticheta_picior.text = ""
	var fara_muchii: Array[Dictionary] = []
	panza.arata(fara_muchii)
	_construieste_loadout()
	_actualizeaza_loadout()


## Un rând per disciplină din CATALOG. Nicio cifră scrisă de mână: numărul de
## rânduri e M, iar cât poți bifa e N. Când apare a patra disciplină, apare al
## patrulea rând, fără nicio linie schimbată aici.
func _construieste_loadout() -> void:
	for copil in loadout_lista.get_children():
		loadout_lista.remove_child(copil)
		copil.queue_free()

	for date in Discipline.CATALOG:
		loadout_lista.add_child(_rand_disciplina(date))


## `CheckButton` = un comutator care își ține singur starea apăsată. Pentru o
## alegere multiplă e mai cinstit decât un buton obișnuit: vezi dintr-o privire
## ce e bifat, fără să ții minte pe ce ai apăsat.
func _rand_disciplina(date: Dictionary) -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 0)

	var comutator := CheckButton.new()
	comutator.text = String(date["nume"])
	comutator.modulate = date["culoare"]
	comutator.toggled.connect(_pe_disciplina_bifata.bind(String(date["cheie"])))
	coloana.add_child(comutator)

	# Ce ANTRENEAZĂ, sub nume. O alegere între trei cuvinte fără explicație nu
	# e o alegere — e o ghicitoare. (Azi le iei pe toate trei, deci rândul ăsta
	# pare degeaba; cu opt discipline, el e tot ecranul.)
	var rol := Label.new()
	rol.text = String(date["rol"])
	rol.modulate = Color(0.58, 0.58, 0.66)
	rol.add_theme_font_size_override("font_size", 13)
	rol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coloana.add_child(rol)

	return coloana


func _pe_disciplina_bifata(bifat: bool, cheie: String) -> void:
	if bifat and not (cheie in alese):
		alese.append(cheie)
	elif not bifat:
		alese.erase(cheie)
	_actualizeaza_loadout()


## Subtitlul și butonul, scrise din N și M — niciodată din cifre.
func _actualizeaza_loadout() -> void:
	var n := Expeditie.DISCIPLINE_IN_LOADOUT
	var m := Discipline.cate()

	if m <= n:
		# Cazul de azi: ai exact atâtea discipline câte încap. Spune-o pe față,
		# în loc să ceri o „alegere" care n-are variante.
		loadout_subtitlu.text = "Ai %d discipline si incap toate %d. Alegerea incepe cand vei avea mai multe." % [m, n]
	else:
		loadout_subtitlu.text = "Alege %d din %d. Raman fixe pe toata expeditia." % [n, m]

	buton_loadout.disabled = alese.size() != n
	if alese.size() == n:
		buton_loadout.text = "Porneste expeditia"
	else:
		buton_loadout.text = "Alese: %d / %d" % [alese.size(), n]


func _pe_pornire() -> void:
	# Sămânța scrisă de mână e unealta de depanare: același număr, aceeași
	# hartă, de fiecare dată. Gol sau nenumeric = una la întâmplare, dar tot
	# ținută minte (vezi `Expeditie.incepe`).
	var text := camp_samanta.text.strip_edges()
	var samanta := int(text) if text.is_valid_int() else 0
	Expeditie.incepe(alese, samanta)
	panou_loadout.visible = false
	_arata_harta()


# ─────────────────────────────────────────────────────────────
# ECRANUL 2: HARTA
# ─────────────────────────────────────────────────────────────

func _arata_harta() -> void:
	panou_loadout.visible = false
	panou_sumar.visible = false
	_construieste_harta()
	_actualizeaza_antet()


## Antetul: unde ești, cât PV ai, ce ai adunat, cu ce lupți, din ce sămânță.
## Sămânța stă la vedere DINADINS — un bug raportat ca „se blochează la nodul
## 6" nu se poate reproduce dacă numărul ăla e ascuns în cod.
func _actualizeaza_antet() -> void:
	var pas := Expeditie.parcurse.size()
	var total := Expeditie.adancime_maxima() + 1
	eticheta_titlu.text = "EXPEDITIE  —  nodul %d din %d" % [mini(pas + 1, total), total]
	eticheta_stare.text = "%d / %d PV     %d Fragmente     samanta %d" % [
		Expeditie.pv, Expeditie.pv_max, Tezaur.cat(Tezaur.Resursa.FRAGMENTE), Expeditie.samanta
	]

	var nume: Array[String] = []
	for cheie in Expeditie.loadout:
		nume.append(Discipline.nume(cheie))
	eticheta_loadout.text = "Unelte: " + ", ".join(nume)

	eticheta_picior.text = "Alege un nod luminat. Drumul nu se poate reface."


## Construiește butoanele nodurilor. Poziția lor se pune în `_aseaza_nodurile`,
## fiindcă depinde de cât spațiu a primit pânza — iar asta se află abia după ce
## Godot a terminat de așezat containerele de deasupra.
func _construieste_harta() -> void:
	for copil in panza.get_children():
		panza.remove_child(copil)
		copil.queue_free()
	butoane_nod.clear()

	var accesibile := Expeditie.accesibile()

	for nod in Expeditie.harta:
		var id := int(nod["id"])
		var date_tip: Dictionary = Expeditie.DATE_NOD[nod["tip"]]
		var e_accesibil := id in accesibile
		var e_parcurs := id in Expeditie.parcurse

		var buton := Button.new()
		buton.custom_minimum_size = MARIME_NOD
		buton.size = MARIME_NOD
		# Simbolul, apoi numele: tipul nodului se vede dinainte, cum trebuie —
		# altfel alegerea drumului e o aruncare de zar, nu o decizie.
		buton.text = "%s  %s" % [date_tip["simbol"], String(date_tip["nume"]).to_upper()]
		buton.tooltip_text = String(date_tip["descriere"])
		buton.disabled = not e_accesibil

		if e_parcurs:
			buton.modulate = CULOARE_NOD_PARCURS
		elif e_accesibil:
			buton.modulate = date_tip["culoare"]
		else:
			buton.modulate = CULOARE_NOD_INCHIS

		buton.pressed.connect(_pe_nod_apasat.bind(id))
		panza.add_child(buton)
		butoane_nod[id] = buton

	_aseaza_nodurile()


## Pune fiecare buton la locul lui și cere pânzei liniile dintre ele.
##
## Adâncimea 0 e JOS, ca într-un drum pe care urci. Un nod de adâncime mai mare
## e mai sus și mai departe — mișcarea ochiului de jos în sus face singură
## povestea „am plecat de acolo și am ajuns aici".
func _aseaza_nodurile() -> void:
	if butoane_nod.is_empty():
		return

	var straturi := Expeditie.adancime_maxima() + 1
	var latime := panza.size.x
	var inaltime := panza.size.y
	if latime <= 0.0 or inaltime <= 0.0:
		return   # încă nu s-a așezat nimic; semnalul `resized` ne mai cheamă o dată

	# Câte noduri are fiecare strat — ca să le pot centra pe orizontală.
	var pe_strat := {}
	for nod in Expeditie.harta:
		var a := int(nod["adancime"])
		pe_strat[a] = int(pe_strat.get(a, 0)) + 1

	var utila_x := latime - 2.0 * MARGINE_PANZA - MARIME_NOD.x
	var utila_y := inaltime - 2.0 * MARGINE_PANZA - MARIME_NOD.y

	var centre := {}
	for nod in Expeditie.harta:
		var id := int(nod["id"])
		var adancime := int(nod["adancime"])
		var coloana := int(nod["coloana"])
		var cate: int = pe_strat[adancime]

		# Fracția (coloana + 0.5) / cate centrează stratul indiferent câte
		# noduri are: un strat cu unul singur iese la 0,5 — adică la mijloc.
		var fx := (coloana + 0.5) / float(cate)
		# `straturi - 1 - adancime` întoarce ordinea: adâncimea 0 ajunge jos.
		var fy := float(straturi - 1 - adancime) / float(maxi(straturi - 1, 1))

		var pozitie := Vector2(
			MARGINE_PANZA + utila_x * fx,
			MARGINE_PANZA + utila_y * fy
		)
		var buton: Button = butoane_nod[id]
		buton.position = pozitie
		buton.size = MARIME_NOD
		centre[id] = pozitie + MARIME_NOD * 0.5

	panza.arata(_muchii(centre))


## Liniile, cu starea lor. Se construiesc din aceleași date ca butoanele, deci
## nu pot ajunge să arate un drum care nu există.
func _muchii(centre: Dictionary) -> Array[Dictionary]:
	var accesibile := Expeditie.accesibile()
	var muchii: Array[Dictionary] = []

	for nod in Expeditie.harta:
		var id := int(nod["id"])
		for id_urmator in nod["spre"]:
			var urmator := int(id_urmator)
			if not (centre.has(id) and centre.has(urmator)):
				continue

			# Drumul e „parcurs" doar dacă AMÂNDOUĂ capetele sunt în urma ta ȘI
			# sunt vecine în drumul efectiv mers. Fără verificarea a doua, un
			# nod vizitat ar aprinde toate drumurile care pleacă din el, inclusiv
			# cele pe care NU le-ai luat.
			var parcurs := _sunt_vecini_in_drum(id, urmator)
			var deschis := id == Expeditie.pozitie and urmator in accesibile
			var culoare := CULOARE_DRUM_INCHIS
			var grosime := GROSIME_DRUM
			if parcurs:
				culoare = CULOARE_DRUM_PARCURS
			elif deschis:
				culoare = CULOARE_DRUM_DESCHIS
				grosime = GROSIME_DRUM_ALES

			muchii.append({
				"de_la": centre[id],
				"la": centre[urmator],
				"culoare": culoare,
				"grosime": grosime,
			})
	return muchii


## Au fost nodurile astea două, una după alta, chiar pe drumul meu?
func _sunt_vecini_in_drum(a: int, b: int) -> bool:
	for i in range(Expeditie.parcurse.size() - 1):
		if Expeditie.parcurse[i] == a and Expeditie.parcurse[i + 1] == b:
			return true
	return false


# ─────────────────────────────────────────────────────────────
# INTRAREA ÎNTR-UN NOD
# ─────────────────────────────────────────────────────────────

func _pe_nod_apasat(id: int) -> void:
	Expeditie.intra_in_nod(id)
	var nod := Expeditie.nod_curent()

	match int(nod["tip"]):
		Expeditie.Nod.LUPTA, Expeditie.Nod.ELITA:
			# Lupta e o SCENĂ ALTA. Tot ce trebuie să știe despre nodul ăsta
			# citește singură din `Expeditie.nod_curent()` — n-avem ce să-i
			# „trimitem", și e bine așa: un parametru pasat între scene ar fi
			# exact lucrul care se pierde la un save.
			get_tree().change_scene_to_file(SCENA_LUPTA)
		Expeditie.Nod.ODIHNA:
			var recuperat := Expeditie.odihneste()
			_arata_mesaj(
				"ODIHNA",
				"Regele isi recapata suflul: +%d PV.\nAcum %d / %d." % [
					recuperat, Expeditie.pv, Expeditie.pv_max]
			)
		Expeditie.Nod.EVENIMENT:
			# Placeholder, și scris ca atare. Un nod care nu face nimic dar
			# pretinde că face e mai rău decât unul care recunoaște.
			_arata_mesaj(
				"EVENIMENT",
				"Aici va fi o alegere, candva. Deocamdata drumul doar trece pe langa."
			)


## Ce se întâmplă după ce un nod s-a rezolvat pe loc (odihnă, eveniment) sau
## după ce te-ai întors dintr-o luptă. UN SINGUR loc, ca cele trei drumuri să
## nu poată ajunge la trei concluzii diferite despre același final.
func _dupa_un_nod() -> void:
	if Expeditie.e_doborat():
		Expeditie.incheie(false)
		_arata_sumar()
	elif Expeditie.la_capat():
		Expeditie.incheie(true)
		_arata_sumar()
	else:
		_arata_harta()


func _arata_mesaj(titlu: String, text: String) -> void:
	mesaj_titlu.text = titlu
	mesaj_text.text = text
	panou_mesaj.visible = true
	buton_mesaj.grab_focus()
	# Harta de sub voal se redesenează ACUM, ca să arate deja starea nouă
	# (PV-ul recuperat, nodul devenit „parcurs") când voalul se ridică.
	_arata_harta()


func _pe_mesaj_inchis() -> void:
	panou_mesaj.visible = false
	_dupa_un_nod()


# ─────────────────────────────────────────────────────────────
# ECRANUL 3: SUMARUL
# ─────────────────────────────────────────────────────────────

func _arata_sumar() -> void:
	var victorie := Expeditie.final == "victorie"

	panou_loadout.visible = false
	panou_mesaj.visible = false
	panou_sumar.visible = true
	_actualizeaza_antet()
	_construieste_harta()   # harta rămâne dedesubt: vezi drumul pe care l-ai mers

	sumar_titlu.text = "EXPEDITIE INCHEIATA" if victorie else "EXPEDITIE PIERDUTA"
	sumar_titlu.modulate = Color(1, 0.85, 0.45) if victorie else Color(0.72, 0.38, 0.38)

	if victorie:
		sumar_text.text = "Ai mers drumul pana la capat, cu %d / %d PV." % [
			Expeditie.pv, Expeditie.pv_max]
	else:
		sumar_text.text = "Regele a cazut la nodul %d din %d." % [
			Expeditie.parcurse.size(), Expeditie.adancime_maxima() + 1]

	_construieste_sumar()
	buton_sumar.grab_focus()


## Rândurile sumarului, din același tabel din care se desenează și defalcarea
## recompenselor din luptă: etichetă la stânga, cifră la dreapta.
##
## Fragmentele apar de DOUĂ ori dinadins — „în expediția asta" și „cu totul" —
## fiindcă sunt două lucruri diferite: primul măsoară runul, al doilea e averea
## care rămâne după el. Un singur număr ar fi ascuns exact despărțirea pe care
## se sprijină tot save-ul.
func _construieste_sumar() -> void:
	for copil in sumar_randuri.get_children():
		sumar_randuri.remove_child(copil)
		copil.queue_free()

	var linii := [
		["Noduri parcurse", "%d din %d" % [
			Expeditie.parcurse.size(), Expeditie.harta.size()]],
		["Lupte castigate", str(Expeditie.recorduri["lupte_castigate"])],
		["Cel mai lung lant", str(Expeditie.recorduri["cel_mai_lung_lant"])],
		["Lovituri critice", str(Expeditie.recorduri["critice"])],
		["Cea mai grea lupta", "%d daune" % Expeditie.recorduri["daune_intr_o_lupta"]],
		["Fragmente din expeditie", str(Expeditie.fragmente_castigate)],
		["Fragmente cu totul", str(Tezaur.cat(Tezaur.Resursa.FRAGMENTE))],
	]

	for linie in linii:
		sumar_randuri.add_child(_rand_sumar(String(linie[0]), String(linie[1])))

	sumar_randuri.add_child(_rand_sumar("Samanta", str(Expeditie.samanta)))


func _rand_sumar(eticheta: String, valoare: String) -> Control:
	var rand := HBoxContainer.new()

	var stanga := Label.new()
	stanga.text = eticheta
	stanga.modulate = Color(0.58, 0.58, 0.66)
	stanga.add_theme_font_size_override("font_size", 15)
	stanga.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dreapta := Label.new()
	dreapta.text = valoare
	dreapta.modulate = Color(0.82, 0.82, 0.90)
	dreapta.add_theme_font_size_override("font_size", 15)
	dreapta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	rand.add_child(stanga)
	rand.add_child(dreapta)
	return rand


func _pe_expeditie_noua() -> void:
	# `goleste()` face starea „nicio expediție", iar `_arata_loadout()` e
	# ecranul pentru starea aia. Nu reîncărcăm scena: n-ar aduce nimic în plus
	# și ar arunca muzica de la capăt.
	Expeditie.goleste()
	panou_sumar.visible = false
	_arata_loadout()

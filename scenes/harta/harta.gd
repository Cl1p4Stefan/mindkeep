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
# drepte, dar o hartă are nevoie ca nodul 3 de pe coloana 2 să fie EXACT în
# dreptul spațiului dintre nodurile 1 și 2 — altfel liniile dintre ele nu mai
# arată a drum, ci a tabel. Deci le punem noi, cu `position`, iar pânza
# desenează drumurile între centrele lor.
const MARIME_NOD := Vector2(92, 92)

## ÎNCOTRO MERGE DRUMUL: DE LA STÂNGA LA DREAPTA.
##
## Înainte creștea de jos în sus, ca un munte pe care urci. Pe hârtia asta a
## fost o greșeală, și una ușor de explicat: pergamentul e lat, nu înalt.
## Adâncimea pusă pe verticală însemna nouă straturi înghesuite pe înălțimea
## mică și două coloane răsfirate pe lățimea mare — adică exact pe dos față de
## cum e forma hârtiei. Pe orizontală, cele nouă straturi au unde să respire.
##
## Nu e doar o chestiune de spațiu: „de la stânga la dreapta" e și direcția în
## care citim. Un drum care merge încotro se uită ochiul nu mai are nevoie de
## nicio săgeată care să explice pe unde s-o iei.
##
## ZONA UTILĂ, în FRACȚIUNI DE ECRAN (0..1). Pergamentul nu acoperă toată
## fereastra: are margini arse în stânga și sus, se termină pe la 85% din
## lățime, iar în colțul din dreapta-jos stă cartea legată în piele. Nodurile
## au voie doar pe hârtie.
##
## De ce fracțiuni și nu pixeli: fundalul se întinde peste toată fereastra,
## deci marginea hârtiei rămâne „la 85% din lățime" indiferent cât de mare e
## fereastra. În pixeli, ar fi trebuit recalculată la fiecare redimensionare.
##
## Marginea din dreapta (0.838) e ALEASĂ SUB cartea din colț (care începe pe la
## 0.845): dacă niciun nod nu trece de linia aia, cartea nu mai are cum să
## încurce pe nimeni, iar tot codul care ocolea zona cărții a putut dispărea.
## O regulă de așezare e mai ieftină decât o excepție de ocolit.
const ZONA_PERGAMENT := Rect2(0.035, 0.050, 0.803, 0.890)

## Cât lăsăm liber între nodurile de pe marginea zonei și marginea ei.
const MARGINE_PANZA := 18.0

## ABATEREA ORGANICĂ
##
## Nodurile așezate exact pe o grilă arată a tabel, oricât de frumos le-ai
## desena. Fiecare primește deci o împingere într-o direcție oarecare, ca
## fracțiune din celula lui — destul cât să se simtă „așezat pe un teren",
## prea puțin cât să încurce citirea straturilor.
##
## Împingerea vine din SĂMÂNȚA NODULUI, nu din `randf()`: aceeași expediție
## trebuie să arate identic la fiecare redesenare, altfel harta ar tresări la
## fiecare redimensionare de fereastră și la fiecare întoarcere din luptă.
##
## Pe verticală e mai mare decât pe orizontală (0.22 față de 0.16), și asta e
## dinadins: pe orizontală, o abatere mare ar amesteca două straturi vecine și
## n-ai mai ști care vine după care. Pe verticală nu se poate amesteca nimic —
## sunt doar două rânduri — deci acolo îmi permit dezordinea care face drumul
## să arate desenat de mână.
const ABATERE_X := 0.16
const ABATERE_Y := 0.22
const ABATERE_MAXIMA := Vector2(34.0, 52.0)

## Cât din înălțimea zonei ocupă rândurile de noduri. 0.86 lasă sus și jos
## câte o șapte-la-sută de hârtie liberă: fără ea, rândul de sus s-ar lipi de
## marginea arsă a pergamentului, iar abaterea organică l-ar scoate de pe el.
const INTINDERE_VERTICALA := 0.86

## STRATURILE ALTERNATE SE STRÂNG SPRE MIJLOC.
##
## Cu două noduri pe strat, toate ies pe două rânduri — unul sus, unul jos —
## și rămâne o bandă goală fix pe mijlocul hârtiei. Se vedea din prima captură:
## harta avea noduri pe margini și nimic în centru, adică exact acolo unde se
## uită ochiul întâi.
##
## Leacul nu e să mai adaug noduri (ar însemna o expediție mai lungă ca să
## repar un desen), ci să TRAG stratul din doi în doi mai aproape de centru.
## Rândurile nu mai sunt două linii drepte, ci un zigzag lat — ceea ce umple
## mijlocul ȘI face harta să arate mai puțin a tabel.
const STRANGERE_ALTERNATA := 0.52

# ── DRUMURILE ─────────────────────────────────────────────────
# Erau gri-deschise și subțiri, adică invizibile: pe un pergament maro, o linie
# deschisă și de 5 pixeli nu spune nimic despre ce leagă de ce. Acum sunt
# CERNEALĂ: groase, închise, cu liniuțe lungi — ca traseele punctate de pe
# hărțile de aventură din care ne inspirăm.

const GROSIME_DRUM := 6.0
const GROSIME_DRUM_ALES := 11.0

## Cât se îndoaie un drum, ca fracțiune din distanța dintre capete.
const CURBURA_MINIMA := 0.08
const CURBURA_MAXIMA := 0.16

## Unde se OPRESC liniuțele, în jurul centrului unui nod. Mai mare decât
## jumătatea nodului (46), ca drumul să se termine VIZIBIL înainte de simbol:
## o liniuță care atinge haloul pare că trece prin nod, nu că ajunge la el.
const OPRIRE_LA_NOD := 56.0

## Culorile drumurilor, în tonuri de CERNEALĂ. Trei stări, trei nuanțe:
##   parcurs   — pe unde ai fost deja. Cerneală spălată: e istorie, nu opțiune.
##   deschis   — de unde ești, spre unde poți merge. Cea mai apăsată din tot
##               ecranul; practic negru-maro, opac.
##   inchis    — restul hărții. Mai stins, dar CITIBIL: vrei să vezi ce n-ai
##               ales, altfel alegerea nu are greutate. Vechea valoare (0.30
##               opacitate) făcea din „citibil" o vorbă goală.
const CULOARE_DRUM_PARCURS := Color(0.42, 0.28, 0.17, 0.45)
const CULOARE_DRUM_DESCHIS := Color(0.16, 0.08, 0.03, 1.00)
const CULOARE_DRUM_INCHIS := Color(0.31, 0.20, 0.10, 0.44)

## Cerneala textului care stă DIRECT pe pergament (eticheta de hover), cu
## conturul crem care o desprinde de textura de dedesubt.
const CULOARE_TEXT := Color(0.16, 0.10, 0.05)
const CULOARE_TEXT_SLAB := Color(0.30, 0.21, 0.13)
const CULOARE_CONTUR := Color(0.99, 0.95, 0.84, 0.90)
const GROSIME_CONTUR := 7
const LATIME_ETICHETA := 230.0

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

@onready var panou_magazin: Control = %PanouMagazin
@onready var magazin_subtitlu: Label = %MagazinSubtitlu
@onready var magazin_lista: VBoxContainer = %MagazinLista
@onready var buton_magazin: Button = %MagazinButon

@onready var panou_mesaj: Control = %PanouMesaj
@onready var mesaj_titlu: Label = %MesajTitlu
@onready var mesaj_text: Label = %MesajText
@onready var buton_mesaj: Button = %MesajButon

## Ce discipline sunt bifate în ecranul de loadout. Trăiește doar cât ține
## ecranul: din clipa în care apeși „Pornește", adevărul e `Expeditie.loadout`.
var alese: Array[String] = []

## Simbolurile nodurilor, ca să le pot reașeza la redimensionarea ferestrei
## fără să reconstruiesc harta. „id de nod → SimbolNod".
var simboluri_nod := {}

## Eticheta care apare sub nodul survolat. UNA singură, ținută de ecran, nu
## câte una în fiecare nod: zece etichete permanente ar acoperi harta, iar zece
## etichete ascunse s-ar putea suprapune între ele în clipa în care apar două.
var eticheta_nod: VBoxContainer
var eticheta_nod_nume: Label
var eticheta_nod_rol: Label

## Peste ce nod stă mouse-ul acum. `-1` = niciunul. Ținut minte ca să nu ascund
## eticheta când mouse-ul a ieșit dintr-un nod DUPĂ ce intrase deja în altul —
## semnalele vin în ordinea asta mai des decât te-ai aștepta.
var nod_survolat := -1


func _ready() -> void:
	buton_loadout.pressed.connect(_pe_pornire)
	buton_sumar.pressed.connect(_pe_expeditie_noua)
	buton_mesaj.pressed.connect(_pe_mesaj_inchis)
	buton_magazin.pressed.connect(_pe_magazin_inchis)
	# Fereastra redimensionată ⇒ nodurile trebuie reașezate. Semnalul vine de
	# la pânză, nu de la fereastră: pe noi ne interesează cât spațiu a primit
	# ZONA DE HARTĂ, care depinde și de cât ocupă antetul de deasupra.
	panza.resized.connect(_aseaza_nodurile)

	panou_loadout.visible = false
	panou_sumar.visible = false
	panou_mesaj.visible = false
	panou_magazin.visible = false

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
	_goleste_panza()
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
	# Monedele stau lângă Fragmente, dar înseamnă altceva, și antetul o spune:
	# Fragmentele sunt averea care rămâne, Monedele sunt ce ai pe drumul ăsta.
	# Un jucător care nu le vede crescând n-o să caute niciodată un Magazin.
	eticheta_stare.text = "%d / %d PV     %d Monede     %d Fragmente     samanta %d" % [
		Expeditie.pv, Expeditie.pv_max, Expeditie.monede,
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE), Expeditie.samanta
	]

	var nume: Array[String] = []
	for cheie in Expeditie.loadout:
		nume.append(Discipline.nume(cheie))
	eticheta_loadout.text = "Unelte: " + ", ".join(nume)

	# Acum că numele nodurilor apar doar la survolare, piciorul e locul în care
	# scrie CUM se citește harta. Un semn pe care nu știi să-l interoghezi e un
	# semn degeaba.
	eticheta_picior.text = "Treci peste un semn ca sa vezi ce te asteapta. Drumul nu se poate reface."


## Șterge tot ce e desenat pe pânză: simbolurile și eticheta lor.
##
## Cheamă-l ORIUNDE harta nu mai e valabilă, nu doar înainte de a o reconstrui.
## Un simbol rămas dintr-o expediție încheiată nu doar că se vede pe sub voal —
## continuă și să pulseze, fiindcă nu știe că datele din spatele lui au dispărut.
func _goleste_panza() -> void:
	for copil in panza.get_children():
		panza.remove_child(copil)
		copil.queue_free()
	simboluri_nod.clear()
	nod_survolat = -1


## Construiește simbolurile nodurilor. Poziția lor se pune în
## `_aseaza_nodurile`, fiindcă depinde de cât spațiu a primit pânza — iar asta
## se află abia după ce Godot a terminat de așezat containerele de deasupra.
##
## Starea fiecărui nod se alege AICI, într-un singur lanț de `if`-uri, și e
## singurul loc din tot ecranul care hotărăște „cum arată nodul ăsta". Nodul nu
## întreabă expediția nimic; primește o stare și o desenează.
func _construieste_harta() -> void:
	_goleste_panza()
	var accesibile := Expeditie.accesibile()

	for nod in Expeditie.harta:
		var id := int(nod["id"])
		# Ordinea contează: nodul curent e ȘI parcurs, deci trebuie întrebat
		# primul, altfel aura caldă n-ar apărea niciodată.
		var stare := SimbolNod.Stare.INCHIS
		if id == Expeditie.pozitie:
			stare = SimbolNod.Stare.CURENT
		elif id in Expeditie.parcurse:
			stare = SimbolNod.Stare.PARCURS
		elif id in accesibile:
			stare = SimbolNod.Stare.ACCESIBIL

		var simbol := SimbolNod.new()
		simbol.size = MARIME_NOD
		simbol.configureaza(id, int(nod["tip"]), stare, int(nod["samanta"]))
		simbol.apasat.connect(_pe_nod_apasat)
		simbol.survolat.connect(_pe_nod_survolat)
		panza.add_child(simbol)
		simboluri_nod[id] = simbol

	# Adăugată ULTIMA, deci desenată peste toate simbolurile: un nod vecin n-are
	# cum să treacă peste eticheta care tocmai a apărut.
	_creeaza_eticheta_nod()
	_aseaza_nodurile()


## Eticheta de hover: numele nodului și ce te așteaptă acolo.
##
## Textul nodurilor nu mai stă permanent pe hartă (patru cuvinte scrise peste
## pergament în zece locuri = zgomot). Simbolul spune TIPUL dintr-o privire;
## numele și descrierea sunt pentru clipa în care chiar te uiți la un nod anume.
##
## Nu are fond: are CONTUR crem în jurul literelor. Un dreptunghi opac ar fi un
## petic de interfață lipit pe hartă; conturul face literele lizibile peste
## orice textură, fără să acopere nimic.
func _creeaza_eticheta_nod() -> void:
	eticheta_nod = VBoxContainer.new()
	eticheta_nod.visible = false
	# IGNORE: eticheta apare exact sub cursor, iar dacă ar prinde ea mouse-ul,
	# nodul de dedesubt ar crede că i-ai ieșit de pe el — ar clipi la nesfârșit.
	eticheta_nod.mouse_filter = Control.MOUSE_FILTER_IGNORE
	eticheta_nod.add_theme_constant_override("separation", 1)

	eticheta_nod_nume = _eticheta_pe_pergament(16, CULOARE_TEXT)
	eticheta_nod_rol = _eticheta_pe_pergament(13, CULOARE_TEXT_SLAB)
	eticheta_nod.add_child(eticheta_nod_nume)
	eticheta_nod.add_child(eticheta_nod_rol)

	panza.add_child(eticheta_nod)


## O etichetă scrisă cu cerneală și conturată cu crem, lată cât să se poată
## rupe pe două rânduri.
func _eticheta_pe_pergament(marime: int, culoare: Color) -> Label:
	var eticheta := Label.new()
	eticheta.custom_minimum_size = Vector2(LATIME_ETICHETA, 0)
	eticheta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", culoare)
	eticheta.add_theme_color_override("font_outline_color", CULOARE_CONTUR)
	eticheta.add_theme_constant_override("outline_size", GROSIME_CONTUR)
	return eticheta


## Arată sau ascunde eticheta nodului survolat.
##
## Se arată pentru ORICE nod, inclusiv pentru cele în care nu poți intra: „ce
## mă așteaptă pe drumul pe care NU-l pot lua acum" e exact informația care
## face alegerea de la pasul următor o decizie.
func _pe_nod_survolat(id: int, intrat: bool) -> void:
	if not intrat:
		# Numai dacă mouse-ul a ieșit din nodul pe care chiar îl arătam: dacă a
		# intrat deja în altul, eticheta e a celuilalt acum.
		if id == nod_survolat:
			nod_survolat = -1
			eticheta_nod.visible = false
		return

	nod_survolat = id
	var date_tip := Expeditie.date_nod(int(Expeditie.harta[id]["tip"]))
	eticheta_nod_nume.text = String(date_tip["nume"]).to_upper()
	eticheta_nod_rol.text = String(date_tip["descriere"])
	eticheta_nod.visible = true
	# `reset_size()` strânge cutia la cât ocupă textul ACUM. Fără el, eticheta
	# ar păstra mărimea de la nodul dinainte și s-ar centra greșit.
	eticheta_nod.reset_size()
	_aseaza_eticheta(id)


## Sub nod, centrată pe el — dar întotdeauna în pânză. Un nod de pe marginea
## de jos și-ar arăta eticheta în afara ecranului, deci acolo o punem deasupra.
func _aseaza_eticheta(id: int) -> void:
	var simbol: Control = simboluri_nod[id]
	var centru := simbol.position + MARIME_NOD * 0.5
	var marime := eticheta_nod.size

	var loc := Vector2(
		centru.x - marime.x * 0.5,
		centru.y + MARIME_NOD.y * 0.42
	)
	if loc.y + marime.y > panza.size.y:
		loc.y = centru.y - MARIME_NOD.y * 0.42 - marime.y
	loc.x = clampf(loc.x, 0.0, maxf(0.0, panza.size.x - marime.x))
	eticheta_nod.position = loc


## Pune fiecare nod la locul lui și cere pânzei liniile dintre ele.
##
## Adâncimea 0 e în STÂNGA, capătul în dreapta — vezi nota de la
## `ZONA_PERGAMENT`. Coloana nodului devine poziția lui pe verticală.
func _aseaza_nodurile() -> void:
	if simboluri_nod.is_empty():
		return

	var zona := _zona_utila()
	if zona.size.x <= 0.0 or zona.size.y <= 0.0:
		return   # încă nu s-a așezat nimic; semnalul `resized` ne mai cheamă o dată

	var straturi := Expeditie.adancime_maxima() + 1

	# Câte noduri are fiecare strat — ca să le pot răsfira pe verticală.
	var pe_strat := {}
	for nod in Expeditie.harta:
		var a := int(nod["adancime"])
		pe_strat[a] = int(pe_strat.get(a, 0)) + 1

	# Cât spațiu revine unui strat pe orizontală și unui rând pe verticală.
	# De aici se calculează cât are voie să bată abaterea organică: legată de
	# distanța dintre vecini, nu de un număr fix de pixeli, ca harta să arate
	# la fel de „așezată" și pe o fereastră mică, și pe una mare.
	var pas_x := zona.size.x / float(maxi(straturi - 1, 1))
	var pas_y := zona.size.y * INTINDERE_VERTICALA / float(maxi(Expeditie.NODURI_PE_STRAT - 1, 1))

	# Un singur generator, reînsămânțat pentru fiecare nod din sămânța LUI.
	# Dacă l-aș lăsa să curgă de la un nod la altul, abaterea nodului 5 ar
	# depinde de câte numere a cerut nodul 4 — adică s-ar schimba în ziua în
	# care adaug o singură aruncare de zar mai sus.
	var rng := RandomNumberGenerator.new()

	var centre := {}
	for nod in Expeditie.harta:
		var id := int(nod["id"])
		var adancime := int(nod["adancime"])
		var coloana := int(nod["coloana"])
		var cate: int = pe_strat[adancime]

		# ORIZONTALA: stratul 0 lipit de marginea din stânga, ultimul de cea
		# din dreapta, restul împărțite egal între ele.
		var fx := float(adancime) / float(maxi(straturi - 1, 1))

		# VERTICALA: nodurile unui strat se răsfiră pe toată înălțimea utilă,
		# nu pe mijlocul ei. Cu formula veche ((coloana + 0.5) / cate) două
		# noduri ieșeau la 25% și 75% din înălțime, adică foloseau jumătate din
		# hârtie și lăsau sus și jos câte un sfert gol.
		#
		# Un strat cu un singur nod (primul și ultimul) iese la mijloc: nu ai
		# ce răsfira, iar mijlocul e locul de unde pleci și unde ajungi.
		var fy := 0.5
		if cate > 1:
			var intins := float(coloana) / float(cate - 1)   # 0 .. 1
			# Straturile impare se strâng spre centru — vezi `STRANGERE_ALTERNATA`.
			var deschidere := INTINDERE_VERTICALA
			if adancime % 2 == 1:
				deschidere *= STRANGERE_ALTERNATA
			fy = 0.5 + (intins - 0.5) * deschidere

		var centru := zona.position + Vector2(zona.size.x * fx, zona.size.y * fy)

		rng.seed = int(nod["samanta"])
		centru += Vector2(
			rng.randf_range(-1.0, 1.0) * minf(pas_x * ABATERE_X, ABATERE_MAXIMA.x),
			rng.randf_range(-1.0, 1.0) * minf(pas_y * ABATERE_Y, ABATERE_MAXIMA.y)
		)

		# Plasa de siguranță: abaterea n-are voie să scoată un nod de pe hârtie.
		# Aceeași plasă ține nodurile și la stânga de carte, fiindcă zona utilă
		# se termină înaintea ei — vezi nota de la `ZONA_PERGAMENT`.
		centru = _in_zona(centru, zona)

		var simbol: Control = simboluri_nod[id]
		simbol.position = centru - MARIME_NOD * 0.5
		simbol.size = MARIME_NOD
		centre[id] = centru

	panza.arata(_muchii(centre, zona))


## Dreptunghiul de hârtie pe care au voie să stea nodurile, în coordonatele
## PÂNZEI.
##
## Două traduceri într-una. Întâi `ZONA_PERGAMENT` (fracțiuni de ECRAN) devine
## pixeli și se mută în sistemul pânzei — cele două nu sunt același lucru,
## fiindcă fundalul se întinde peste toată fereastra, iar pânza e doar
## dreptunghiul rămas sub antet.
##
## Apoi o INTERSECTĂM cu pânza: hârtia începe mai sus decât pânza (acolo e
## antetul), deci partea aia nu ne e disponibilă oricum. Intersecția e
## răspunsul la „unde e ȘI hârtie, ȘI loc al meu".
##
## La final scădem jumătate de nod din fiecare margine: `zona` e locul unde pot
## sta CENTRELE, iar un centru lipit de margine ar însemna un simbol pe
## jumătate în afară.
func _zona_utila() -> Rect2:
	var ecran := get_viewport_rect().size
	var hartie := Rect2(ZONA_PERGAMENT.position * ecran, ZONA_PERGAMENT.size * ecran)
	hartie.position -= panza.global_position

	var zona := hartie.intersection(Rect2(Vector2.ZERO, panza.size))
	return zona.grow_individual(
		-(MARIME_NOD.x * 0.5 + MARGINE_PANZA), -(MARIME_NOD.y * 0.5 + MARGINE_PANZA),
		-(MARIME_NOD.x * 0.5 + MARGINE_PANZA), -(MARIME_NOD.y * 0.5 + MARGINE_PANZA)
	)


## Un punct adus înapoi în zonă, dacă a ieșit din ea.
func _in_zona(punct: Vector2, zona: Rect2) -> Vector2:
	return Vector2(
		clampf(punct.x, zona.position.x, zona.end.x),
		clampf(punct.y, zona.position.y, zona.end.y)
	)


## Liniile, cu starea lor. Se construiesc din aceleași date ca butoanele, deci
## nu pot ajunge să arate un drum care nu există.
func _muchii(centre: Dictionary, zona: Rect2) -> Array[Dictionary]:
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
				"curbura": _curbura(id, urmator, centre, zona),
				# Unde se opresc liniuțele la capete. Trimisă de AICI, nu
				# ghicită în pânză: harta e singura care știe cât de mare e un
				# nod, iar pânza nu are de ce să afle ce e un nod.
				"oprire": OPRIRE_LA_NOD,
			})
	return muchii


## Cât și în ce parte se îndoaie drumul dintre două noduri.
##
## Amestecăm semințele CELOR DOUĂ noduri, ca fiecare pereche să aibă îndoitura
## ei: dacă aș folosi doar sămânța nodului de plecare, toate drumurile care
## pleacă din același nod s-ar curba identic și s-ar suprapune două câte două.
## Numerele 31 și 7919 n-au nimic magic în ele — sunt doar primi, care amestecă
## mai bine decât un 2 sau un 10.
##
## Apoi VERIFICĂM unde ajunge îndoitura. O curbă lungă ajunge mai departe decât
## capetele ei, deci un drum poate ieși de pe hârtie chiar dacă amândouă
## nodurile lui sunt pe ea. Dacă partea trasă la sorți e proastă, o încercăm pe
## cealaltă; dacă amândouă sunt proaste, îndoim abia perceptibil. Tot
## deterministic, în toate cazurile.
func _curbura(a: int, b: int, centre: Dictionary, zona: Rect2) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(Expeditie.harta[a]["samanta"]) * 31 + int(Expeditie.harta[b]["samanta"]) * 7919
	var marime := rng.randf_range(CURBURA_MINIMA, CURBURA_MAXIMA)
	var semn := 1.0 if rng.randf() < 0.5 else -1.0

	# Punctul de control, calculat exact ca în pânză: mijlocul împins
	# perpendicular. El e vârful îndoiturii, deci e și cel mai depărtat punct.
	var de_la: Vector2 = centre[a]
	var la: Vector2 = centre[b]
	var mijloc := (de_la + la) * 0.5
	var perpendiculara := Vector2(-(la - de_la).y, (la - de_la).x)

	for incercare in [semn, -semn]:
		var control: Vector2 = mijloc + perpendiculara * marime * incercare
		if zona.has_point(control):
			return marime * incercare
	return CURBURA_MINIMA * 0.4 * semn


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
		Expeditie.Nod.LUPTA, Expeditie.Nod.ELITA, Expeditie.Nod.BOSS:
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
		Expeditie.Nod.MAGAZIN:
			_arata_magazin()
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


# ─────────────────────────────────────────────────────────────
# MAGAZINUL
#
# Singurul loc din expediție în care Monedele înseamnă ceva. Ecranul ăsta nu
# știe nicio regulă: citește `Expeditie.PUTERI`, cere `Expeditie.cumpara()`, și
# se redesenează după. Prețurile, efectele și ce se poate cumpăra de două ori
# stau toate în expediție — aici e doar vitrina.
#
# De ce nu se închide singur după o cumpărătură: fiindcă poți cumpăra mai
# multe, dacă ai Monede. Un magazin care te dă afară după primul lucru cumpărat
# te-ar face să numeri înainte, nu să alegi.
# ─────────────────────────────────────────────────────────────

func _arata_magazin() -> void:
	panou_magazin.visible = true
	_construieste_magazin()
	buton_magazin.grab_focus()
	# Harta de sub voal se redesenează ACUM, ca să arate deja nodul devenit
	# „parcurs" când voalul se ridică. Același tipar ca la `_arata_mesaj`.
	_arata_harta()


## Un rând per putere din tabel. Niciun nume scris de mână: o putere nouă e un
## rând în `Expeditie.PUTERI`, nu o linie aici.
func _construieste_magazin() -> void:
	magazin_subtitlu.text = "Ai %d Monede. Ce cumperi tine pana la capatul expeditiei — apoi dispare." % Expeditie.monede

	for copil in magazin_lista.get_children():
		magazin_lista.remove_child(copil)
		copil.queue_free()

	for fisa in Expeditie.PUTERI:
		magazin_lista.add_child(_rand_magazin(fisa))


func _rand_magazin(fisa: Dictionary) -> Control:
	var cheie := String(fisa["cheie"])

	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 2)

	# Butonul se stinge singur când nu se poate cumpăra, ȘI SPUNE DE CE — fie
	# „iti mai trebuie 8", fie „PV plin". Un buton stins fără explicație e o ușă
	# închisă fără tăbliță: te uiți la ea și nu știi dacă e vina ta sau a jocului.
	var refuz := Expeditie.motiv_refuz(cheie)

	var buton := Button.new()
	buton.text = "%s  —  %d Monede" % [String(fisa["nume"]), int(fisa["cost"])]
	if refuz != "":
		buton.text += "   (%s)" % refuz
	buton.custom_minimum_size = Vector2(0, 40)
	buton.disabled = refuz != ""
	buton.pressed.connect(_pe_putere_cumparata.bind(cheie))
	coloana.add_child(buton)

	var descriere := Label.new()
	descriere.text = String(fisa["descriere"])
	descriere.modulate = Color(0.58, 0.58, 0.66)
	descriere.add_theme_font_size_override("font_size", 13)
	descriere.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coloana.add_child(descriere)

	return coloana


func _pe_putere_cumparata(cheie: String) -> void:
	var urmare := Expeditie.cumpara(cheie)
	if urmare == "":
		return   # n-au ajuns Monedele; butonul era oricum stins

	Sunet.reda(Sunet.Efect.CORECT)
	# Rescriem vitrina: Monedele au scăzut, deci alte butoane trebuie stinse.
	_construieste_magazin()
	# Și antetul, fiindcă și el arată Monedele — și, la „Zale ferecate", PV-ul.
	_actualizeaza_antet()
	magazin_subtitlu.text = "%s  Ti-au ramas %d Monede." % [urmare, Expeditie.monede]


func _pe_magazin_inchis() -> void:
	panou_magazin.visible = false
	_dupa_un_nod()


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
		["Cumparat la magazin", Expeditie.puteri_pe_scurt()],
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

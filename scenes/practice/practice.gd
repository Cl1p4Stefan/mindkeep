extends Control
## ANTRENAMENT LIBER (Practice) — Cultura generală, pe raftul ales de tine.
##
## Prima felie din pasul 13 al rutei de construcție. Se deschide din meniul de
## start, și pornește și singură cu F6.
##
## ─────────────────────────────────────────────────────────────
## CE E ALTFEL FAȚĂ DE LUPTĂ, ȘI DE CE
##
## Trei lucruri, și fiecare din același motiv: aici scopul e să ÎNVEȚI, nu să
## reziști.
##
##   1. ALEGI TU domeniul (și, dacă vrei, raftul). În luptă alege jocul, cu
##      echilibru pe domenii și cu `PRAG_DOMENIU` — fiindcă acolo un domeniu
##      sărac ar lua 1/N din toată lupta. Aici nu există prag: dacă vreau să
##      exersez cele 9 întrebări de gastronomie, alea sunt 9 întrebări pe care
##      le vreau, nu un dezechilibru.
##   2. NU CURGE TIMPUL. Presiunea de timp e a luptei. Vezi `cu_cronometru`
##      din `puzzle.gd`: un comutator, nu o scenă a doua.
##   3. NU EXISTĂ PV, PA, LANȚ sau daune. Un răspuns greșit nu costă nimic în
##      afară de faptul că n-ai știut — exact ca în orice carte de exerciții.
##
## ─────────────────────────────────────────────────────────────
## CE REFOLOSEȘTE, ȘI DE CE NU SCRIE UN AL DOILEA UI DE ÎNTREBARE
##
## Întrebarea de pe ecran e CHIAR scena de trivia din luptă (`trivia.tscn`),
## instanțiată ca în `lupta.gd`: aceleași patru butoane, același antet, aceiași
## trei timpi ai verdictului. Un al doilea ecran de întrebare ar fi însemnat ca
## fiecare lustruire viitoare (un sunet, o animație, „Află mai multe") să se
## facă de două ori, cu două șanse să se despartă pe furiș.
##
## Tot ce-i spune ecranul ăsta scenei de trivia sunt TREI VALORI puse înainte de
## `porneste()`: `cu_cronometru`, `filtru_domeniu`, `filtru_subcategorie`.
## Nicio linie din `trage_intrebarea` (alegerea din luptă) nu e atinsă.
##
## ─────────────────────────────────────────────────────────────
## PROGRESUL SE PIERDE LA ÎNCHIDEREA JOCULUI. DINADINS, DEOCAMDATĂ.
##
## Save-ul e pasul 8 și nu există încă, deci nivelurile și întrebările știute
## trăiesc în `static var`-urile de mai jos: aparțin SCRIPTULUI, nu copiei de
## scenă, deci rezistă la plimbarea prin meniu și înapoi — dar mor cu procesul.
## Când apare Save-ul, cele două dicționare de mai jos sunt exact ce se scrie pe
## disc; forma lor (chei text, valori simple) e deja cea pe care `JSON.stringify`
## o înghite fără conversii, din același motiv ca la `Tezaur` și `Sac`.
##
## ─────────────────────────────────────────────────────────────
## CE NU INTRĂ ÎN FELIA ASTA (e în plan, în felii separate)
##
## Greșitele care revin, „învățat" și Jurnalul, amestecul de niveluri după
## deblocare, popup-ul „Află mai multe" cu note și imagini, istoricul comun cu
## expedițiile, Save. Nota faptului SE ÎNCARCĂ deja (câmpul `explicatie` din
## contract), doar că nimic n-o afișează încă — nici în luptă, nici aici.

const SCENA_MENIU := "res://scenes/meniu/meniu.tscn"

## Scena întrebării (pentru instanțiere) și scriptul ei (pentru tabele și
## funcții statice). Două preload-uri pentru același conținut, fiindcă sunt două
## întrebări diferite: „dă-mi o copie vie" și „ce scrie în `DOMENII`".
const SCENA_TRIVIA := preload("res://scenes/trivia/trivia.tscn")
const TRIVIA := preload("res://scenes/trivia/trivia.gd")

## CÂTE RĂSPUNSURI CORECTE LA ÎNTREBĂRI DISTINCTE DESCHID NIVELUL URMĂTOR.
##
## ─── DE CE UN PRAG FIX, ȘI NU „TOATE CORECTE" ─────────────────
## „Toate" e un zid care CREȘTE cu conținutul: ai 247 din 250 și rămâi blocat de
## trei întrebări grele, iar fiecare lot de întrebări noi te împinge înapoi.
## Pragul fix nu crește: la a 60-a întrebare distinctă știută, nivelul următor se
## deschide, oricât ar fi crescut baza între timp.
##
## ─── DE CE „DISTINCTE" ────────────────────────────────────────
## Fără asta, 60 de răspunsuri corecte s-ar putea face din 3 întrebări repetate
## de 20 de ori. Se numără `id`-uri, nu răspunsuri — iar `id` e singurul câmp al
## unei întrebări care nu se schimbă niciodată (vezi `sac.gd`).
##
## ─── DE CE PE DOMENIU, NU PE RAFT ─────────────────────────────
## Nivelul e o măsură a CÂT ȘTII DIN DOMENIU. Numărat pe raft, ai fi avut
## „geografie politică, nivelul II" lângă „geografie fizică, nivelul I" — adică
## 31 de progrese de ținut minte în loc de 8, și un nivel care sare în sus și-n
## jos după ce raft ai ales. Alegerea raftului e o lupă, nu un alt joc.
##
## 60 e CIFRĂ DE PORNIRE, nejucată (scrie și în `docs/progres.md`), reglabilă ca
## `DISCIPLINE_IN_LOADOUT`.
const PRAG_PRACTICE := 60

## Nivelul scris cu cifre romane, ca în pitch. Lista e o PLASĂ, nu o regulă: dacă
## apare vreodată un al patrulea nivel, `_roman` întoarce cifra arabă în loc să
## iasă din listă.
const CIFRE_ROMANE := ["I", "II", "III"]


# ─────────────────────────────────────────────────────────────
# PROGRESUL (în memorie, vezi antetul)
# ─────────────────────────────────────────────────────────────

## Nivelul atins pe fiecare domeniu: cheia domeniului → 1, 2 sau 3.
## Un domeniu care nu e în dicționar e la nivelul 1 — deci nu trebuie populat
## la pornire, și un domeniu NOU apare singur cu nivelul I.
static var _nivel_atins := {}

## Întrebările știute, ca „domeniu:nivel" → {id: true}.
##
## DE CE CHEIA CUPRINDE ȘI NIVELUL. Pragul se aplică din nou la fiecare
## treaptă („60 distincte la nivelul II deschid nivelul III"), deci contorul
## trebuie să pornească de la zero pe fiecare nivel. Cu o singură mulțime pe
## domeniu, cele 60 de la nivelul I ar fi deschis instantaneu și nivelul III.
##
## DICTIONARY FOLOSIT CA MULȚIME: valoarea `true` nu înseamnă nimic, se
## folosește doar cheia. La mii de id-uri, `Dictionary.has` rămâne instant, pe
## când un `Array.has` ar plimba toată lista la fiecare răspuns — aceeași
## schimbare pe care o anticipează deja comentariul din `sac.gd`.
static var _stiute := {}


# ─────────────────────────────────────────────────────────────
# STAREA ECRANULUI (nu a progresului)
# ─────────────────────────────────────────────────────────────

## CE ECRAN SE VEDE NU SE ȚINE MINTE NICIUNDE, și e dinadins.
##
## Prima versiune avea un `enum Ecran { DOMENII, RAFTURI, INTREBARE }` și o
## variabilă care-l urmărea. Nimeni n-o citea — fiindcă `visible` de pe cele
## două panouri spune deja același lucru, iar un al doilea loc care spune
## același lucru e un loc care se poate contrazice cu primul. Aceeași regulă ca
## la ticăitul din `puzzle.gd`: mai bine o gardă într-un singur loc decât o
## stare duplicată care trebuie resetată corect.
##
## Ce TREBUIE ținut minte e doar filtrul: pe ce domeniu și pe ce raft ești.
var domeniu_ales := ""
var subcategorie_aleasa := ""   # "" = tot domeniul

## Copia vie a scenei de trivia, cât timp e una pe ecran.
var puzzle: Control = null

## Contorul de SESIUNE: cât ai răspuns de când ai intrat pe ecranul ăsta.
## Nu se resetează la schimbarea domeniului — altfel „sesiune" ar însemna două
## lucruri, iar cifra n-ar mai spune „cât am lucrat azi".
var corecte_sesiune := 0
var total_sesiune := 0

@onready var eticheta_titlu: Label = %Titlu
@onready var eticheta_stare: Label = %Stare

@onready var panou_alegere: Control = %PanouAlegere
@onready var alegere_titlu: Label = %AlegereTitlu
@onready var alegere_subtitlu: Label = %AlegereSubtitlu
@onready var lista: VBoxContainer = %Lista
@onready var buton_inapoi: Button = %ButonInapoi
@onready var buton_meniu: Button = %ButonMeniu

@onready var panou_intrebare: Control = %PanouIntrebare
@onready var eticheta_anunt: Label = %Anunt
@onready var zona_puzzle: PanelContainer = %ZonaPuzzle
@onready var buton_urmatoarea: Button = %ButonUrmatoarea
@onready var buton_schimba: Button = %ButonSchimba


func _ready() -> void:
	buton_meniu.pressed.connect(_pe_meniu)
	buton_inapoi.pressed.connect(_arata_domenii)
	buton_urmatoarea.pressed.connect(_intrebare_noua)
	buton_schimba.pressed.connect(_arata_domenii)

	Muzica.reda(Muzica.Piesa.CETATE)

	# ÎNCĂRCAREA, CHEMATĂ DE AICI. În luptă o cheamă scena de trivia, în
	# `_pregateste_datele()`. Aici avem nevoie de întrebări ÎNAINTE să existe
	# vreo scenă de trivia: ecranul de alegere scrie pe fiecare buton câte
	# întrebări are raftul, deci trebuie să le poată număra.
	# Funcția e idempotentă (iese din prima linie a doua oară), deci chemarea de
	# aici nu face munca de două ori.
	TRIVIA.incarca_intrebari()

	_arata_domenii()


# ─────────────────────────────────────────────────────────────
# ECRANUL 1: DOMENIILE
# ─────────────────────────────────────────────────────────────

## Un buton pe domeniu, generat din `TRIVIA.DOMENII`.
##
## NICIO LISTĂ SCRISĂ AICI, aceeași regulă ca la ecranul de loadout: un domeniu
## nou e un rând în tabelul din `trivia.gd` și nimic altceva. Dacă ar fi scrisă
## și aici, ziua în care apare al nouălea domeniu ar fi ziua în care Practice
## are opt butoane și nimeni nu știe de ce.
func _arata_domenii() -> void:
	domeniu_ales = ""
	subcategorie_aleasa = ""
	_inchide_puzzle()

	panou_alegere.visible = true
	panou_intrebare.visible = false
	buton_inapoi.visible = false

	alegere_titlu.text = "ALEGE DOMENIUL"
	alegere_subtitlu.text = "Nivelul urca singur, pe fiecare domeniu. Fara cronometru."

	_goleste(lista)
	for cheie in TRIVIA.DOMENII:
		var domeniu := String(cheie)
		var nivel := nivelul(domeniu)
		var cate := TRIVIA.raftul(nivel, domeniu).size()
		lista.add_child(_buton_raft(
			String(TRIVIA.DOMENII[cheie]), cate, nivel,
			_pe_domeniu_ales.bind(domeniu)))

	_actualizeaza_antet()


func _pe_domeniu_ales(domeniu: String) -> void:
	domeniu_ales = domeniu
	_arata_rafturile()


# ─────────────────────────────────────────────────────────────
# ECRANUL 2: RAFTURILE DOMENIULUI
# ─────────────────────────────────────────────────────────────

## Butoanele subcategoriilor, generate din `TRIVIA.SUBCATEGORII[domeniu]`.
##
## PRIMUL E „TOT DOMENIUL", și nu e doar o comoditate: el e singurul care
## cuprinde ȘI întrebările fără subcategorie. Subcategoria e un câmp opțional
## (vezi `_intrebare_valida` din `trivia.gd`), deci fără butonul ăsta ar putea
## exista întrebări pe care niciun raft nu le arată — exact ce nu vrei de la un
## meniu care pretinde că împarte tot conținutul.
func _arata_rafturile() -> void:
	subcategorie_aleasa = ""
	_inchide_puzzle()

	panou_alegere.visible = true
	panou_intrebare.visible = false
	buton_inapoi.visible = true

	var nivel := nivelul(domeniu_ales)
	alegere_titlu.text = String(TRIVIA.DOMENII.get(domeniu_ales, domeniu_ales)).to_upper()
	alegere_subtitlu.text = "Alege raftul. Primul cuprinde tot domeniul, inclusiv intrebarile fara raft."

	_goleste(lista)
	lista.add_child(_buton_raft(
		"Tot domeniul", TRIVIA.raftul(nivel, domeniu_ales).size(), nivel,
		_pe_raft_ales.bind("")))

	var rafturi: Dictionary = TRIVIA.SUBCATEGORII.get(domeniu_ales, {})
	for cheie in rafturi:
		var raft := String(cheie)
		var cate := TRIVIA.raftul(nivel, domeniu_ales, raft).size()
		lista.add_child(_buton_raft(
			String(rafturi[cheie]), cate, nivel, _pe_raft_ales.bind(raft)))

	_actualizeaza_antet()


func _pe_raft_ales(raft: String) -> void:
	subcategorie_aleasa = raft
	panou_alegere.visible = false
	panou_intrebare.visible = true
	eticheta_anunt.text = ""
	_intrebare_noua()


# ─────────────────────────────────────────────────────────────
# UN BUTON DE RAFT
# ─────────────────────────────────────────────────────────────

## Numele raftului plus câte întrebări are. Gol = buton DEZACTIVAT, nu ascuns.
##
## ─── DE CE DEZACTIVAT ȘI NU ASCUNS ────────────────────────────
## Un raft ascuns e un raft despre care nu afli niciodată nimic: nu știi dacă
## nu există, dacă l-ai pierdut sau dacă n-am scris încă nimic în el. Unul
## stins, cu „0 întrebări" pe el, e o hartă a conținutului care lipsește —
## aceeași decizie ca la `PRAG_DOMENIU`, unde domeniile subțiri sunt SĂRITE,
## nu scoase din date.
##
## ─── CE CIFRĂ SCRIE PE EL ─────────────────────────────────────
## Câte întrebări are raftul LA NIVELUL TĂU CURENT, nu totalul pe trei niveluri.
## Fiindcă aia e cifra care se și joacă: un buton pe care scrie 500 și care
## n-are nimic de dat la nivelul I ar fi o minciună, iar aceeași cifră decide
## dacă butonul e activ. Prețul, spus pe față: când deblochezi nivelul II la un
## domeniu, un raft care are conținut doar la nivelul I se stinge.
func _buton_raft(nume: String, cate: int, nivel: int, la_apasare: Callable) -> Button:
	var buton := Button.new()
	buton.custom_minimum_size = Vector2(0, 42)
	buton.text = "%s   —   %d la nivelul %s" % [nume, cate, _roman(nivel)]
	buton.disabled = cate == 0
	buton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	buton.pressed.connect(la_apasare)
	return buton


# ─────────────────────────────────────────────────────────────
# ECRANUL 3: ÎNTREBĂRILE
# ─────────────────────────────────────────────────────────────

## O întrebare nouă din raftul ales. Chemată și de butonul „Următoarea".
func _intrebare_noua() -> void:
	_inchide_puzzle()
	buton_urmatoarea.disabled = true

	var nivel := nivelul(domeniu_ales)

	# RAFT GOL LA NIVELUL ĂSTA. Se poate întâmpla fără niciun bug: exersezi un
	# raft, treci pragul la jumătate, iar nivelul următor al lui n-are încă
	# conținut. Atunci se spune, în loc să ceri o întrebare care nu există —
	# `trage_din_raft` ar întoarce dicționar gol, iar `puzzle.gd` ar scoate
	# ecranul lui de EROARE, care aici ar fi o minciună: nu e nimic stricat,
	# doar n-am scris încă întrebările.
	if TRIVIA.raftul(nivel, domeniu_ales, subcategorie_aleasa).is_empty():
		zona_puzzle.visible = false
		eticheta_anunt.text = "Raftul asta nu are intrebari la nivelul %s. Alege altul." % _roman(nivel)
		buton_schimba.grab_focus()
		return

	zona_puzzle.visible = true

	# Cele trei valori pe care le pune Practice, TOATE înainte de `porneste()`:
	# acolo se compune întrebarea și (în luptă) pornește cronometrul.
	var nou := SCENA_TRIVIA.instantiate()
	nou.cu_cronometru = false
	nou.filtru_domeniu = domeniu_ales
	nou.filtru_subcategorie = subcategorie_aleasa
	zona_puzzle.add_child(nou)
	puzzle = nou
	nou.porneste(nivel)

	# `await` pe semnalul scenei, exact ca în `ruleaza_lant` din `lupta.gd`:
	# funcția asta se suspendă aici, restul jocului merge înainte, iar firul se
	# reia când jucătorul a răspuns ȘI s-a terminat pauza de feedback.
	var succes: bool = await nou.rezolvat

	# PLASA: între întrebare și răspuns, jucătorul a putut apăsa „Schimbă
	# domeniul". Atunci scena de atunci nu mai e cea de acum, iar răspunsul ei
	# n-are ce căuta în contorul raftului nou.
	if puzzle != nou:
		return

	_pe_raspuns(succes, nou)


## Ce se întâmplă cu un răspuns. Singurul loc care atinge progresul.
func _pe_raspuns(succes: bool, de_la: Node) -> void:
	total_sesiune += 1
	if succes:
		corecte_sesiune += 1

	var nivel := nivelul(domeniu_ales)

	# `ultima_trasa` e întrebarea BRUTĂ care stă pe ecran — singurul loc de unde
	# se poate afla `id`-ul ei (vezi variabila, în `trivia.gd`).
	var bruta: Dictionary = de_la.ultima_trasa
	var id := String(bruta.get("id", ""))
	if succes and id != "":
		_inregistreaza(domeniu_ales, nivel, id)

	buton_urmatoarea.disabled = false
	buton_urmatoarea.grab_focus()
	_actualizeaza_antet()


## Scoate întrebarea de pe ecran.
##
## `remove_child` ÎNAINTE de `queue_free`, și nu e paranoia: `queue_free` șterge
## nodul abia la finalul cadrului, deci dacă adaugi imediat următoarea întrebare,
## pentru un cadru `ZonaPuzzle` are doi copii — iar un `PanelContainer` le dă
## amândurora tot spațiul, suprapuse. Se vede ca un pâlpâit de litere duble.
func _inchide_puzzle() -> void:
	if puzzle == null:
		return
	zona_puzzle.remove_child(puzzle)
	puzzle.queue_free()
	puzzle = null


# ─────────────────────────────────────────────────────────────
# PROGRESUL
# ─────────────────────────────────────────────────────────────

## Nivelul la care ești pe domeniul ăsta. Lipsa din dicționar = nivelul I.
func nivelul(domeniu: String) -> int:
	return int(_nivel_atins.get(domeniu, 1))


## Câte întrebări distincte știi pe o celulă (domeniu × nivel).
func cate_stiute(domeniu: String, nivel: int) -> int:
	var pe_celula: Dictionary = _stiute.get(_cheia_celulei(domeniu, nivel), {})
	return pe_celula.size()


## Trece o întrebare în știute și, dacă pragul e atins, deschide nivelul următor.
##
## CELE DOUĂ TREBURI STAU ÎMPREUNĂ dinadins, ca la `Sac.retine`: despărțite în
## „numără" și „verifică pragul", ar exista un loc din care se poate uita a
## doua, iar bug-ul ăla n-ar arăta ca un bug — ar arăta ca un nivel care nu se
## mai deblochează niciodată.
func _inregistreaza(domeniu: String, nivel: int, id: String) -> void:
	var cheie := _cheia_celulei(domeniu, nivel)
	var pe_celula: Dictionary = _stiute.get(cheie, {})
	pe_celula[id] = true
	_stiute[cheie] = pe_celula

	if pe_celula.size() < PRAG_PRACTICE:
		return
	if nivel >= _nivel_maxim():
		return
	_nivel_atins[domeniu] = nivel + 1
	# Un nivel deblocat în tăcere e o răsplată pe care n-o observi. Rândul se
	# șterge la întrebarea următoare (vezi `_pe_raft_ales`).
	eticheta_anunt.text = "Nivelul %s deblocat la %s." % [
		_roman(nivel + 1), TRIVIA.DOMENII.get(domeniu, domeniu)]


## Cheia unei celule. Într-un singur loc, ca la cheile sacului: două locuri care
## compun același text ajung, într-o zi, să-l compună altfel.
func _cheia_celulei(domeniu: String, nivel: int) -> String:
	return "%s:%d" % [domeniu, nivel]


func _nivel_maxim() -> int:
	# Citit din `puzzle.gd`, nu scris aici: nivelurile sunt o proprietate a
	# disciplinei, iar un „3" scris în două locuri e un „3" care se desparte.
	return Puzzle.TIMP_PE_NIVEL.size()


# ─────────────────────────────────────────────────────────────
# ANTETUL
# ─────────────────────────────────────────────────────────────

## Progresul pe domeniul ales, plus contorul de sesiune.
##
## Pe ecranul de domenii nu există un domeniu ales, deci rămâne doar sesiunea:
## un rând care spune „nivel I" fără să spună al cui ar fi mai rău decât niciun
## rând.
func _actualizeaza_antet() -> void:
	eticheta_titlu.text = "PRACTICE"

	var bucati: Array[String] = []
	if domeniu_ales != "":
		bucati.append(_progresul(domeniu_ales))
	if total_sesiune > 0:
		bucati.append("Sesiune: %d / %d corecte" % [corecte_sesiune, total_sesiune])
	eticheta_stare.text = "      ".join(bucati)


## „Nivel I · 12 / 60 pana la nivelul II", sau „Nivel III · nivelul maxim".
func _progresul(domeniu: String) -> String:
	var nivel := nivelul(domeniu)
	if nivel >= _nivel_maxim():
		return "Nivel %s · nivelul maxim" % _roman(nivel)
	return "Nivel %s · %d / %d pana la nivelul %s" % [
		_roman(nivel), cate_stiute(domeniu, nivel), PRAG_PRACTICE, _roman(nivel + 1)]


# ─────────────────────────────────────────────────────────────
# MĂRUNȚIȘURI
# ─────────────────────────────────────────────────────────────

func _pe_meniu() -> void:
	get_tree().change_scene_to_file(SCENA_MENIU)


## Cifra romană a unui nivel, cu arabă pe post de plasă. Vezi `CIFRE_ROMANE`.
func _roman(nivel: int) -> String:
	if nivel >= 1 and nivel <= CIFRE_ROMANE.size():
		return String(CIFRE_ROMANE[nivel - 1])
	return str(nivel)


## Golește un container de copiii lui. `remove_child` înainte de `queue_free`,
## din același motiv ca la `_inchide_puzzle`: altfel butoanele vechi rămân în
## container încă un cadru și se amestecă cu cele noi.
func _goleste(container: Node) -> void:
	for copil in container.get_children():
		container.remove_child(copil)
		copil.queue_free()

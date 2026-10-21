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
## Tot ce-i spune ecranul ăsta scenei de trivia sunt CINCI VALORI puse înainte de
## `porneste()`: `cu_cronometru`, `filtru_domeniu`, `filtru_subcategorie`, plus
## `stiute_raft` și `recente_raft` (neștiutele întâi, greșitele la distanță —
## vezi `trage_din_raft`). Nicio linie din `trage_intrebarea` (alegerea din
## luptă) nu e atinsă.
##
## ─────────────────────────────────────────────────────────────
## RAFTUL PARCURS (21 octombrie 2026)
##
## Tragerea pune întâi întrebările pe care nu le-ai răspuns încă corect, deci
## fiecare răspuns bun mișcă pragul de nivel. O greșită rămâne neștiută și
## revine — dar abia după `DISTANTA_PRACTICE` alte întrebări, iar la finalul
## raftului distanța se umple cu întrebări știute. Când n-a mai rămas nicio
## neștiută, ecranul o spune (`_anunt_raft_parcurs`) și raftul continuă ca
## recapitulare. „Știut" înseamnă aici „corect o dată": regula mai strictă,
## „învățat", e felia următoare și schimbă doar cine iese din neștiute.
##
## ─────────────────────────────────────────────────────────────
## PROGRESUL TRECE PE DISC, DAR ÎNCĂ STĂ ÎN `static var`
##
## Nivelurile și întrebările știute trăiesc în `static var`-urile de mai jos:
## aparțin SCRIPTULUI, nu copiei de scenă, deci rezistă la plimbarea prin meniu
## și înapoi. Până la Save mureau cu procesul; de azi, `Arhiva` le duce în
## `permanent.json` prin cele două funcții statice de la finalul fișierului, și
## le aduce înapoi la pornire.
##
## CE A RĂMAS STRÂMB, ȘI MERITĂ SPUS. Starea care supraviețuiește unei scene
## aparține unui AUTOLOAD — regula scrisă în antetul lui `tezaur.gd`,
## `sac.gd` și `expeditie.gd`. Progresul ăsta o încalcă: stă într-un script de
## scenă, iar `Arhiva` ajunge la el cu un `preload`. Ziua în care se mută e
## felia următoare din Practice, cea cu greșitele care revin și cu Jurnalul —
## atunci apar și alte două-trei dicționare care n-au ce căuta într-un ecran.
## Azi ar fi fost un refactor într-o sesiune despre disc.
##
## ─────────────────────────────────────────────────────────────
## „AFLĂ MAI MULTE" — NOTA FAPTULUI (felia din 12 octombrie 2026)
##
## După fiecare răspuns, corect SAU greșit, apare un buton care deschide nota
## faptului. Patru lucruri merită spuse despre el:
##
##   1. VINE DIN CONTRACT, NU DIN DATE. Nota se citește din `explicatie`, câmpul
##      pe care `puzzle.gd` îl primește de la disciplină (vezi `_compune_intrebare`
##      din `trivia.gd`) — NU din `TRIVIA.fapte`. Ecranul ăsta nu știe nici că
##      există fapte, nici cum se leagă o întrebare de unul. O a doua căutare
##      scrisă aici ar fi fost un al doilea drum către aceeași notă, iar ziua în
##      care unul se schimbă e ziua în care Practice arată altceva decât lupta.
##      Pe deasupra, așa butonul merge din prima și pentru Logică sau Cuvinte,
##      fără nicio linie în plus: ele pun în `explicatie` regula rezolvării.
##   2. POARTA E NOTA, NU CÂMPUL `fapt`. Azi 646 de întrebări arată spre un fapt,
##      dar doar 96 ajung la o notă NEVIDĂ: cele 550 fabricate au fapte cu nota
##      goală, dinadins (vezi `_incarca_fapte`). Un fapt fără notă e, pe ecran,
##      exact același lucru ca o întrebare fără fapt — deci se întreabă ce se
##      afișează, nu ce se speră.
##   3. SE ARATĂ ȘI LA ÎNTREBĂRILE NEVERIFICATE. 2664 din 2692 au
##      `verificat: false`, deci un filtru pe flagul ăla ar fi golit ecranul.
##      Flagul spune dacă AM CITIT nota, nu dacă nota e bună — vezi `neverificate`
##      din `trivia.gd`. Nu există, și nu trebuie să existe, nicio linie aici
##      care să-l pomenească.
##   4. FĂRĂ NOTĂ, FĂRĂ URMĂ. Butonul e `visible = false`, nu dezactivat: într-un
##      VBoxContainer un copil invizibil nu ocupă loc, deci o întrebare fără notă
##      arată exact ca înainte. E pe dos față de rafturile goale din ecranul de
##      alegere, care apar STINSE — și dinadins: acolo un buton stins e o
##      informație („raftul există, dar e gol"), aici n-ar fi niciuna, doar o
##      promisiune care nu se ține. Prețul, spus pe față: când butonul apare,
##      rândul de dedesubt coboară cu ~44px. Ecranul face deja asta pentru
##      eticheta `Anunt`, deci nu e o mișcare nouă.
##
## ─────────────────────────────────────────────────────────────
## TRECEREA SINGURĂ, LA RĂSPUNS CORECT (21 octombrie 2026)
##
## După un răspuns CORECT, „Următoarea" se umple ca o bară în `PAUZA_AUTO`
## secunde, iar când s-a umplut vine întrebarea următoare fără niciun click.
## Trei reguli, fiecare cu motivul ei:
##
##   1. NUMAI LA CORECT. La greșit ai cea mai mare nevoie de notă (punctul de
##      mai sus), deci acolo nu curge nimic: citești în ritmul tău și apeși tu.
##      La corect știai deja, așa că nota pierdută e cea mai ieftină — iar
##      clicul care enerva era aproape tot aici.
##   2. SE VEDE. Un timer invizibil e o capcană: n-ai ști dacă mai apuci să
##      deschizi nota. Bara îți arată că urmează ceva, și cât mai ai.
##   3. ORICE GEST SPRE NOTĂ O OPREȘTE: mouse-ul pe „Află mai multe", focusul
##      pe el (Tab) sau apăsarea lui. Oprită, bara dispare și rămâi pe manual,
##      exact ca înainte. Click pe „Următoarea" trece imediat, ca întotdeauna.
##
## FĂRĂ COMUTATOR ON/OFF, dinadins: cu regulile de mai sus, cazul în care l-ai
## fi vrut oprit aproape dispare, iar o setare înseamnă un câmp în
## `permanent.json` și un loc în UI. Dacă se dovedește că trebuie, e o adăugare,
## nu o rescriere.
##
## ─────────────────────────────────────────────────────────────
## CE NU INTRĂ ÎN FELIA ASTA (e în plan, în felii separate)
##
## „Învățat" și Jurnalul (greșitele revin de pe 21 octombrie, pe raftul ales —
## vezi „Raftul parcurs" mai sus), amestecul de niveluri după
## deblocare, istoricul comun cu expedițiile. Și IMAGINEA din popup (hartă
## desenată din date sau imagine reală cu licență): `imagini` e deja un câmp al
## faptului, dar `_incarca_fapte` citește doar nota, deci imaginea n-are încă pe
## ce drum să ajungă aici. Când va avea, locul ei e în `PanouNota`, între titlu
## și text — restul ecranului nu se atinge.
##
## În LUPTĂ nota rămâne neafișată, și rămâne dinadins: un popup în mijlocul unui
## lanț ar rupe exact lucrul pentru care există lanțul.

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

## CÂT STĂ BARA PÂNĂ SĂ TREACĂ SINGURĂ, după un răspuns corect (vezi antetul).
##
## Se adună PESTE `PAUZA_SUSPANS` din `puzzle.gd` (0,35 s până încep culorile),
## fiindcă „Află mai multe" și bara apar odată cu verdictul. Pauza de citire a
## luptei nu se mai adaugă: Practice o stinge (`cu_pauza_citire`, din 21
## octombrie — înainte butonul apărea abia la 1,8 s după click). Deci de la click
## la întrebarea următoare trec ~2,35 s, iar fereastra în care poți opri bara e
## de 2 s. Cifră de pornire, nejucată: se reglează aici, jucând.
const PAUZA_AUTO := 2.0

## Nivelul scris cu cifre romane, ca în pitch. Lista e o PLASĂ, nu o regulă: dacă
## apare vreodată un al patrulea nivel, `_roman` întoarce cifra arabă în loc să
## iasă din listă.
const CIFRE_ROMANE := ["I", "II", "III"]


# ─────────────────────────────────────────────────────────────
# PROGRESUL (static, scris pe disc de `Arhiva` — vezi antetul)
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

## NOTA ÎNTREBĂRII LA CARE S-A RĂSPUNS, sau gol = n-are notă.
##
## ── DE CE O COPIE, ȘI NU `puzzle.explicatie` CITIT LA APĂSARE ─
## Fiindcă „ce scrie în popup" și „ce scenă stă pe ecran" ar fi devenit două
## lucruri care se pot contrazice. Copia se face o singură dată, în clipa
## răspunsului, și se șterge când întrebarea pleacă — deci nu există nicio
## fereastră de timp în care butonul e aprins și nota e a altei întrebări.
## Aceeași regulă ca la `ultima_trasa` din `trivia.gd`: ce ai nevoie mai târziu
## se reține CÂND e adevărat, nu se recitește când s-a schimbat.
##
## Gol înseamnă „fără notă", nu „n-am citit încă" — vezi punctul 2 din antet.
var nota_curenta := ""

## Contorul de SESIUNE: cât ai răspuns de când ai intrat pe ecranul ăsta.
## Nu se resetează la schimbarea domeniului — altfel „sesiune" ar însemna două
## lucruri, iar cifra n-ar mai spune „cât am lucrat azi".
var corecte_sesiune := 0
var total_sesiune := 0

## Id-urile trase ultimele pe raftul ales, cea mai nouă la coadă. Le citește
## `trage_din_raft`, ca să nu pună o întrebare înapoi pe masă prea repede.
##
## NU SE SCRIE PE DISC, dinadins. E o distanță de câteva întrebări, nu un
## istoric: cine închide jocul și revine mâine n-are cum să-și mai amintească
## varianta corectă de aseară. Se golește la schimbarea raftului, din același
## motiv — e un alt raft, alte întrebări.
var recente: Array = []

## Bara care curge pe „Următoarea", cât timp curge. `null` = nu curge nimic.
## Un Tween ucis nu mai cheamă nimic, deci a-l opri înseamnă și a opri trecerea.
var tween_auto: Tween = null

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
@onready var bara_auto: ColorRect = %BaraAuto
@onready var buton_schimba: Button = %ButonSchimba
@onready var buton_afla: Button = %ButonAfla

@onready var panou_nota: Control = %PanouNota
@onready var nota_text: Label = %NotaText
@onready var buton_inchide_nota: Button = %ButonInchideNota


func _ready() -> void:
	buton_meniu.pressed.connect(_pe_meniu)
	buton_inapoi.pressed.connect(_arata_domenii)
	buton_urmatoarea.pressed.connect(_intrebare_noua)
	buton_schimba.pressed.connect(_arata_domenii)
	buton_afla.pressed.connect(_deschide_nota)
	buton_inchide_nota.pressed.connect(_inchide_nota)
	# Gesturile care opresc bara înainte de click: mouse-ul ajuns pe „Află mai
	# multe" și focusul mutat pe el cu Tab. Apăsarea trece prin `_deschide_nota`.
	buton_afla.mouse_entered.connect(_opreste_auto)
	buton_afla.focus_entered.connect(_opreste_auto)

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
	recente.clear()
	panou_alegere.visible = false
	panou_intrebare.visible = true
	# Un raft parcurs deja (într-o sesiune de ieri) se anunță de la intrare: altfel
	# ai afla abia din contorul care nu se mișcă.
	eticheta_anunt.text = _anunt_raft_parcurs() if _raft_stiut() else ""
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

	# Valorile pe care le pune Practice, TOATE înainte de `porneste()`: acolo se
	# compune întrebarea și (în luptă) pornește cronometrul.
	var nou := SCENA_TRIVIA.instantiate()
	nou.cu_cronometru = false
	nou.cu_pauza_citire = false
	nou.filtru_domeniu = domeniu_ales
	nou.filtru_subcategorie = subcategorie_aleasa
	nou.stiute_raft = _stiute.get(_cheia_celulei(domeniu_ales, nivel), {})
	nou.recente_raft = recente
	zona_puzzle.add_child(nou)
	puzzle = nou
	nou.porneste(nivel)

	# Tras ACUM, nu la răspuns: o întrebare rămasă fără răspuns (ai apăsat
	# „Schimbă domeniul") tot a fost pe masă. Lista ține doar cât se folosește.
	var id_tras := String(nou.ultima_trasa.get("id", ""))
	if id_tras != "":
		recente.append(id_tras)
		if recente.size() > TRIVIA.DISTANTA_PRACTICE:
			recente.pop_front()

	# `await` pe semnalul scenei, exact ca în `ruleaza_lant` din `lupta.gd`:
	# funcția asta se suspendă aici, restul jocului merge înainte, iar firul se
	# reia când jucătorul a răspuns ȘI s-a dat verdictul (suspansul, fără pauza
	# de citire a luptei — vezi `cu_pauza_citire` mai sus).
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
		var era_stiut := _raft_stiut()
		_inregistreaza(domeniu_ales, nivel, id)
		# Anunțul, în clipa în care raftul a devenit știut tot. Dacă același
		# răspuns a deschis și nivelul următor, anunțul de nivel rămâne: e vestea
		# mai mare, iar raftul, la nivelul nou, nu mai e parcurs.
		if not era_stiut and nivelul(domeniu_ales) == nivel and _raft_stiut():
			eticheta_anunt.text = _anunt_raft_parcurs()

	# NOTA, ACUM. `explicatie` e câmpul din contractul cu `puzzle.gd`, pus de
	# `porneste()` din ce a întors disciplina — deci aici nu se întreabă nicio
	# bază de date, se citește ce a ajuns pe ecran. Vezi punctul 1 din antet.
	#
	# SE ÎNTÂMPLĂ LA FEL LA CORECT ȘI LA GREȘIT, și asta e chiar rostul feliei:
	# momentul în care ai cea mai mare nevoie de notă e cel în care n-ai știut.
	# „Ton sănătos" din CLAUDE.md — înveți ceva și când greșești.
	nota_curenta = String(de_la.explicatie)
	buton_afla.visible = nota_curenta != ""

	# FOCUSUL RĂMÂNE PE „URMĂTOAREA", chiar dacă butonul notei tocmai a apărut
	# deasupra lui. Drumul obișnuit e „răspund, merg înainte", iar un Enter care
	# deschide brusc un popup ar fi o surpriză plătită de cel care citea repede.
	# Nota e o alegere, nu un pas.
	buton_urmatoarea.disabled = false
	buton_urmatoarea.grab_focus()
	_actualizeaza_antet()

	if succes:
		_porneste_auto()


## Pornește bara pe „Următoarea". Vezi „Trecerea singură" din antet.
##
## `scale.x` de la 0 la 1, nu lățimea: bara e ancorată pe tot butonul, cu
## pivotul în stânga (implicit), deci scala o face să crească de la stânga fără
## să știe cât de lat e butonul.
func _porneste_auto() -> void:
	_opreste_auto()
	tween_auto = create_tween()
	tween_auto.tween_property(bara_auto, "scale:x", 1.0, PAUZA_AUTO).from(0.0)
	tween_auto.tween_callback(_intrebare_noua)


## Oprește bara și o face să dispară. Ieftină de chemat de câte ori vrei, ca
## `_inchide_nota`: un semnal de focus sau de mouse poate veni când nu curge nimic.
func _opreste_auto() -> void:
	if tween_auto != null:
		tween_auto.kill()
		tween_auto = null
	bara_auto.scale.x = 0.0


## Scoate întrebarea de pe ecran.
##
## `remove_child` ÎNAINTE de `queue_free`, și nu e paranoia: `queue_free` șterge
## nodul abia la finalul cadrului, deci dacă adaugi imediat următoarea întrebare,
## pentru un cadru `ZonaPuzzle` are doi copii — iar un `PanelContainer` le dă
## amândurora tot spațiul, suprapuse. Se vede ca un pâlpâit de litere duble.
func _inchide_puzzle() -> void:
	# NOTA PLEACĂ ÎNTÂI, și ÎNAINTE de ieșirea de mai jos. Dacă ștergerea ar fi
	# scrisă după `if puzzle == null`, un drum pe care nu există scenă de puzzle
	# (de pildă „raft gol la nivelul ăsta", care cheamă funcția și apoi se
	# oprește) ar lăsa pe ecran butonul notei de la întrebarea de dinainte —
	# adică o notă care nu mai are nicio întrebare deasupra ei.
	#
	# Un singur loc pentru amândouă fiindcă sunt un singur lucru: întrebarea și
	# nota ei se nasc și mor împreună. Despărțite în două funcții, ar fi existat
	# un drum din care se poate uita a doua.
	nota_curenta = ""
	buton_afla.visible = false
	_inchide_nota()
	# Și bara, din același motiv: e trecerea DE LA întrebarea asta. Rămasă vie
	# după „Schimbă domeniul", ar fi adus peste un minut o întrebare pe ecranul
	# de rafturi. Aici, nu în fiecare buton, ca să nu existe un drum care o uită.
	_opreste_auto()

	if puzzle == null:
		return
	zona_puzzle.remove_child(puzzle)
	puzzle.queue_free()
	puzzle = null


# ─────────────────────────────────────────────────────────────
# POPUP-UL „AFLĂ MAI MULTE"
#
# Un panou peste tot ecranul, nu un `AcceptDialog`. Motivul e felia următoare:
# nota va avea, cândva, o imagine deasupra ei (hartă desenată din date sau
# imagine reală cu licență), iar o fereastră de sistem s-ar fi redimensionat
# singură în jurul ei, cu temă proprie și cu alt fundal decât restul jocului.
# Un `Control` cu `visible` e un panou pe care îl desenez eu, în aceeași
# paletă — și e ȘI mai puțin cod decât un dialog configurat.
#
# UMBRA DE DEASUPRA NU E DECOR: `ColorRect` are `mouse_filter` pe STOP din
# fabrică, deci el e lucrul care face popup-ul MODAL. Fără ea, ai putut apăsa
# „Următoarea" prin umbră, iar întrebarea s-ar fi schimbat în spatele notei pe
# care o citeai.
# ─────────────────────────────────────────────────────────────

## Deschide nota întrebării la care s-a răspuns.
##
## Garda nu e paranoia: butonul e ascuns când nota lipsește, dar o tastă
## (Enter pe un buton care tocmai s-a ascuns) poate ajunge la un semnal cu un
## cadru întârziere. Un popup gol ar fi arătat ca un bug.
func _deschide_nota() -> void:
	if nota_curenta == "":
		return
	# Prima linie după gardă: o notă deschisă nu are voie să fie schimbată de
	# sub tine. Mouse-ul și focusul au oprit-o de obicei deja; asta e plasa
	# pentru un click venit pe alt drum.
	_opreste_auto()
	nota_text.text = nota_curenta
	panou_nota.visible = true
	# Focusul trece pe „Închide", deci Enter sau Space închid nota — tasta care
	# a deschis-o o și închide, fără să fie nevoie de mouse.
	buton_inchide_nota.grab_focus()


## Închide nota. Chemată de buton, de Escape și de `_inchide_puzzle`.
##
## Nu are nicio gardă și nu se plânge dacă popup-ul era deja închis: a-l închide
## de două ori trebuie să fie la fel de ieftin ca o dată, altfel fiecare loc care
## o cheamă ar fi avut nevoie de propriul `if`.
func _inchide_nota() -> void:
	if not panou_nota.visible:
		return
	panou_nota.visible = false
	# Înapoi de unde a plecat focusul. Fără rândul ăsta, după închidere nicio
	# tastă n-ar mai face nimic până la primul click.
	if not buton_urmatoarea.disabled:
		buton_urmatoarea.grab_focus()


## ESCAPE închide nota, fiindcă asta face Escape peste orice panou care s-a
## deschis deasupra a altceva. `_unhandled_input`, nu `_input`: așa butoanele
## primesc întâi ce e al lor, iar noi luăm doar ce n-a vrut nimeni.
##
## `set_input_as_handled` oprește tasta aici. Fără el, același Escape ar putea
## cădea mai departe la cine mai ascultă — azi nimeni, mâine poate un meniu de
## pauză, și atunci o apăsare ar fi făcut două lucruri.
func _unhandled_input(eveniment: InputEvent) -> void:
	if not panou_nota.visible:
		return
	if eveniment.is_action_pressed("ui_cancel"):
		_inchide_nota()
		get_viewport().set_input_as_handled()


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

	# PE DISC, ACUM. O întrebare știută e un lucru TERMINAT, iar regula Arhivei
	# e că ce s-a terminat se scrie — altfel o sesiune de antrenament de o
	# jumătate de oră ar atârna de felul în care se închide jocul. Fișierul are
	# câțiva kilobytes, deci o scriere la fiecare răspuns corect nu se simte.
	Arhiva.salveaza_permanent()

	if pe_celula.size() < PRAG_PRACTICE:
		return
	if nivel >= _nivel_maxim():
		return
	_nivel_atins[domeniu] = nivel + 1
	# A doua scriere, fiindcă s-a schimbat încă ceva: nivelul. Două scrieri la
	# a 60-a întrebare, una la toate celelalte — mai ieftin decât o funcție care
	# ar încerca să le unească și care s-ar putea încurca în ce s-a schimbat.
	Arhiva.salveaza_permanent()
	# Un nivel deblocat în tăcere e o răsplată pe care n-o observi. Rândul se
	# șterge la întrebarea următoare (vezi `_pe_raft_ales`).
	eticheta_anunt.text = "Nivelul %s deblocat la %s." % [
		_roman(nivel + 1), TRIVIA.DOMENII.get(domeniu, domeniu)]


## Cheia unei celule. Într-un singur loc, ca la cheile sacului: două locuri care
## compun același text ajung, într-o zi, să-l compună altfel.
static func _cheia_celulei(domeniu: String, nivel: int) -> String:
	return "%s:%d" % [domeniu, nivel]


## Câte întrebări din raft n-ai răspuns încă corect, la nivelul ăsta.
## Raftul gol = 0 neștiute, dar NU „parcurs" — vezi `raft_parcurs`.
##
## Statică, pe progresul static, ca s-o poată întreba și `verifica_trivia`
## fără un ecran deschis.
static func nestiute(nivel: int, domeniu: String, subcategorie := "") -> int:
	var pe_celula: Dictionary = _stiute.get(_cheia_celulei(domeniu, nivel), {})
	var cate := 0
	for q in TRIVIA.raftul(nivel, domeniu, subcategorie):
		if not pe_celula.has(String(q["id"])):
			cate += 1
	return cate


## Ai răspuns corect la TOATE întrebările raftului, la nivelul ăsta?
##
## Un raft gol nu e parcurs: n-ai ce anunța despre el, iar ecranul spune deja,
## altfel, că n-are întrebări (vezi `_intrebare_noua`).
static func raft_parcurs(nivel: int, domeniu: String, subcategorie := "") -> bool:
	return not TRIVIA.raftul(nivel, domeniu, subcategorie).is_empty() \
		and nestiute(nivel, domeniu, subcategorie) == 0


func _raft_stiut() -> bool:
	return raft_parcurs(nivelul(domeniu_ales), domeniu_ales, subcategorie_aleasa)


## Ce spune ecranul când raftul e știut tot.
##
## ─── DE CE E NEVOIE DE EL ─────────────────────────────────────
## Pragul de nivel numără întrebări DISTINCTE pe domeniu. Pe un raft știut tot,
## niciun răspuns nu-l mai mișcă — iar fără anunț, asta arată ca un contor
## stricat și ca un raft care a început să se repete. Anunțul spune ce s-a
## întâmplat (ai trecut prin tot), ce urmează (recapitulare, nu o ușă închisă:
## „Ton sănătos") și unde e drumul spre nivelul următor, cu cifra.
##
## Cifra din a doua propoziție e CINSTITĂ și când domeniul nu ajunge: dacă
## neștiutele rămase în tot domeniul sunt mai puține decât cere pragul, se spune
## asta, în loc să trimiți jucătorul după întrebări care nu există.
func _anunt_raft_parcurs() -> String:
	var nivel := nivelul(domeniu_ales)
	var ce := "tot domeniul" if subcategorie_aleasa == "" else "tot raftul"
	var inceput := "Ai raspuns corect la %s, la nivelul %s. De aici e recapitulare." % [
		ce, _roman(nivel)]
	if nivel >= _nivel_maxim():
		return inceput

	var lipsa := PRAG_PRACTICE - cate_stiute(domeniu_ales, nivel)
	var ramase := nestiute(nivel, domeniu_ales)
	if ramase >= lipsa:
		return "%s\nPentru nivelul %s mai ai nevoie de %d, din restul domeniului." % [
			inceput, _roman(nivel + 1), lipsa]
	return "%s\nNivelul %s cere inca %d, iar domeniul mai are doar %d nestiute." % [
		inceput, _roman(nivel + 1), lipsa, ramase]


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


# ─────────────────────────────────────────────────────────────
# SALVARE
#
# Statice, fiindcă starea pe care o duc e statică: `Arhiva` nu are o copie a
# ecranului ăsta la îndemână (și n-ar trebui să aibă — un ecran e o scenă, un
# progres e un fapt). Vezi antetul fișierului pentru ce a rămas strâmb aici.
#
# Progresul ăsta e PERMANENT: intră în `permanent.json`, nu în save-ul
# expediției. Ce știi nu se pierde când un run se încheie.
# ─────────────────────────────────────────────────────────────

## Progresul ca Dictionary cu chei text — forma pe care `JSON.stringify()` o
## înghite fără nicio conversie, din același motiv ca la `Tezaur` și `Sac`.
##
## `_stiute` e un dicționar de dicționare („geografie:2" → {id: true}), iar
## `duplicate(true)` copiază și cuiburile: fără `true`, save-ul ar ține
## REFERINȚE la mulțimile vii, care se schimbă până la scrierea pe disc.
static func spre_dictionar() -> Dictionary:
	return {
		"nivel_atins": _nivel_atins.duplicate(),
		"stiute": _stiute.duplicate(true),
	}


## Drumul invers. Pornim de la gol, deci un save căruia îi lipsește un domeniu
## nu lasă în urmă progres fantomă din rularea curentă.
##
## Tot ce vine de pe disc e curățat pe loc: nivelul prin `int()` (JSON întoarce
## toate numerele ca float, iar un nivel 2.0 ar sparge `CIFRE_ROMANE[nivel - 1]`),
## iar mulțimile de id-uri prin `String()`. Un domeniu care nu mai există în
## `DOMENII` e ignorat la afișare fără niciun cod special: ecranul își desenează
## butoanele din `DOMENII`, nu din progres.
static func din_dictionar(date: Dictionary) -> void:
	_nivel_atins.clear()
	_stiute.clear()

	var niveluri = date.get("nivel_atins")
	if niveluri is Dictionary:
		for domeniu in niveluri:
			# Strâns în intervalul care există: un nivel 7 dintr-un save umblat
			# cu mâna ar cere un raft care nu există, iar ecranul ar rămâne gol
			# fără să spună de ce.
			_nivel_atins[String(domeniu)] = clampi(
				int(niveluri[domeniu]), 1, Puzzle.TIMP_PE_NIVEL.size())

	var stiute = date.get("stiute")
	if stiute is Dictionary:
		for celula in stiute:
			if not (stiute[celula] is Dictionary):
				continue
			var ids := {}
			for id in stiute[celula]:
				ids[String(id)] = true
			_stiute[String(celula)] = ids

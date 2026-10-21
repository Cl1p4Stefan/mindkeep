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
## recapitulare. Anunțul vine O SINGURĂ DATĂ, în clipa în care ai terminat
## raftul, și pleacă la întrebarea următoare; de atunci încolo, faptul că
## raftul e parcurs îl spune butonul lui din lista de rafturi („Nivel I · 100%").
## „Știut" înseamnă aici „corect o dată": regula mai strictă, „învățat", e
## felia următoare și schimbă doar cine iese din neștiute.
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
## După fiecare răspuns, corect SAU greșit, se aprinde CREIERUL din colțul
## chenarului, și el deschide nota faptului. Până pe 21 octombrie 2026 era un
## buton „Afla mai multe" sub chenar (vezi punctul 4 pentru de ce s-a mutat).
## Patru lucruri merită spuse despre el:
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
##   4. MEREU ACOLO, APRINS DOAR CÂND ARE CE SPUNE. Creierul stă tot timpul în
##      colțul din dreapta-sus al chenarului: STINS cât timp n-ai răspuns (nota
##      ți-ar da răspunsul — nota Franței spune că Parisul e capitala), APRINS
##      după verdict dacă întrebarea are notă, și STINS în continuare dacă n-are.
##      Până pe 21 octombrie a fost pe dos: un buton sub chenar, ascuns când
##      lipsea nota, cu motivul că „un buton stins n-ar fi nicio informație".
##      S-a schimbat din două motive. Butonul ascuns, când apărea, împingea
##      rândul de dedesubt cu ~44px — chiar sub cursorul cu care tocmai
##      răspunseseși, deci mouse-ul ajungea pe el fără să-l miști și oprea
##      trecerea singură (vezi mai jos). Și o iconiță pe loc fix, care „nu se
##      aprinde", spune la fel de clar ca un buton ascuns că nota lipsește, fără
##      să miște nimic pe ecran. Iconița e a ecranului ăstuia, pusă PESTE
##      chenar (`StratNota`), nu în `trivia.tscn`: acolo ar fi apărut și în luptă.
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
##   3. NUMAI APĂSAREA CREIERULUI O OPREȘTE (cu mouse-ul sau cu tastatura).
##      Până pe 21 octombrie o opreau și mouse-ul ajuns pe „Afla mai multe" și
##      focusul pus pe el cu Tab — iar butonul apărea sub cursor (punctul 4 de
##      mai sus), deci bara se oprea singură când nu voiai. Survolarea apăra de
##      un lucru real (întrebarea să plece exact când întinzi mâna spre notă),
##      dar cu iconița pe loc fix, la care ajungi într-o clipă, riscul e mic.
##      Oprită, bara dispare și rămâi pe manual. Click pe „Următoarea" trece
##      imediat, ca întotdeauna.
##   4. UN ANUNȚ OPREȘTE ȘI EL TRECEREA. Când răspunsul a terminat raftul sau a
##      deschis un nivel, rândul de deasupra chenarului spune asta o singură
##      dată, iar două propoziții nu se citesc în 2 secunde. Bara nu pornește:
##      treci tu, după ce ai citit.
##
## FĂRĂ COMUTATOR ON/OFF, dinadins: cu regulile de mai sus, cazul în care l-ai
## fi vrut oprit aproape dispare, iar o setare înseamnă un câmp în
## `permanent.json` și un loc în UI. Dacă se dovedește că trebuie, e o adăugare,
## nu o rescriere.
##
## ─────────────────────────────────────────────────────────────
## ÎMBRĂCĂMINTEA: PERGAMENT ÎN BIBLIOTECĂ (21 octombrie 2026)
##
## Practice se petrece în biblioteca din luptă: `fight_background.jpg`, dar
## estompat, întunecat și cu colțurile stinse (`assets/tema/fundal_estompat
## .gdshader`). Peste ea stau PAGINI de pergament, scrise cu cerneală, cu
## titlurile în roșu de rubrică — culorile hărții de expediție.
##
## TOT ASPECTUL STĂ ÎNTR-O TEMĂ, `assets/tema/pergament.tres`, pusă pe
## rădăcina scenei. Trei lucruri merită știute despre ea:
##
##   1. O TEMĂ COBOARĂ ÎN ARBORE, inclusiv în scenele instanțiate. Scena de
##      trivia pusă în `ZonaPuzzle` se îmbracă singură în pergament, iar în
##      luptă, unde nimeni nu pune tema, rămâne exact cum era. Un singur ecran
##      de întrebare, două înfățișări, nicio linie de cod care să le aleagă.
##   2. FONTURILE SUNT DOUĂ: Cinzel pentru titluri, Alegreya pentru text, în
##      `assets/fonturi/`, amândouă sub licența OFL (textul ei e lângă ele și
##      trebuie să rămână acolo). Amândouă au ș și ț cu virgulă dedesubt.
##   3. VARIAȚIILE DE TIP. Un Label nu e „titlu" prin poziție, ci prin
##      `theme_type_variation`: `TitluPergament`, `SubtitluPergament`,
##      `RubricaPergament`, `AntetPergament` (text deschis, pe fundalul închis),
##      `ChenarPergament` (zona întrebării), `LegaturaPergament` (creierul
##      notei). Culorile nu se mai pun cu `modulate` pe noduri: `modulate`
##      ÎNMULȚEȘTE, iar auriul de pe un text închis la culoare iese maro.
##
## Culorile de verdict (verde, roșu, rama) le dă tot tema, sub tipul „Puzzle"
## — vezi `_culoare()` din `puzzle.gd`. Verdele luptei, înmulțit cu pergamentul,
## ieșea verde de semafor.
##
## Același `.tres`, pus pe rădăcina meniului de start, l-ar îmbrăca și pe el:
## e un rând, nefăcut încă.
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
## fiindcă creierul se aprinde și bara pornește odată cu verdictul. Pauza de citire a
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
@onready var lista: VBoxContainer = %Lista
@onready var buton_inapoi: Button = %ButonInapoi
@onready var buton_meniu: Button = %ButonMeniu

@onready var panou_intrebare: Control = %PanouIntrebare
@onready var eticheta_anunt: Label = %Anunt
@onready var zona_puzzle: PanelContainer = %ZonaPuzzle
@onready var buton_urmatoarea: Button = %ButonUrmatoarea
@onready var bara_auto: ColorRect = %BaraAuto
@onready var buton_schimba: Button = %ButonSchimba
@onready var buton_nota: Button = %ButonNota

@onready var panou_nota: Control = %PanouNota
@onready var nota_text: Label = %NotaText
@onready var buton_inchide_nota: Button = %ButonInchideNota


func _ready() -> void:
	buton_meniu.pressed.connect(_pe_meniu)
	buton_inapoi.pressed.connect(_arata_domenii)
	buton_urmatoarea.pressed.connect(_intrebare_noua)
	buton_schimba.pressed.connect(_arata_domenii)
	# Apăsarea e și SINGURUL gest care oprește bara (prin `_deschide_nota`).
	# Mouse-ul și focusul pe creier nu mai opresc nimic — vezi „Trecerea singură".
	buton_nota.pressed.connect(_deschide_nota)
	buton_inchide_nota.pressed.connect(_inchide_nota)

	Muzica.reda(Muzica.Piesa.CETATE)

	# ÎNCĂRCAREA, CHEMATĂ DE AICI. În luptă o cheamă scena de trivia, în
	# `_pregateste_datele()`. Aici avem nevoie de întrebări ÎNAINTE să existe
	# vreo scenă de trivia: ecranul de alegere stinge rafturile goale, deci
	# trebuie să poată număra câte întrebări are fiecare.
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

	_goleste(lista)
	for cheie in TRIVIA.DOMENII:
		var domeniu := String(cheie)
		var nivel := nivelul(domeniu)
		var cate := TRIVIA.raftul(nivel, domeniu).size()
		var buton := _buton_raft(
			String(TRIVIA.DOMENII[cheie]), cate, nivel,
			_pe_domeniu_ales.bind(domeniu), true)
		buton.icon = _iconita(domeniu)
		lista.add_child(buton)

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
##
## FĂRĂ SUBTITLU (de pe 21 octombrie 2026). Până atunci, sub titlu scria „Alege
## raftul. Primul cuprinde tot domeniul, inclusiv intrebarile fara raft." —
## o explicație citită o dată și apoi doar text în plus pe fereastră. Ecranul
## de domenii pierduse deja subtitlul, din același motiv, deci nodul a ieșit cu
## totul din scenă.
func _arata_rafturile() -> void:
	subcategorie_aleasa = ""
	_inchide_puzzle()

	panou_alegere.visible = true
	panou_intrebare.visible = false
	buton_inapoi.visible = true

	var nivel := nivelul(domeniu_ales)
	alegere_titlu.text = String(TRIVIA.DOMENII.get(domeniu_ales, domeniu_ales)).to_upper()

	_goleste(lista)
	lista.add_child(_buton_raft(
		"Tot domeniul", TRIVIA.raftul(nivel, domeniu_ales).size(), nivel,
		_pe_raft_ales.bind(""), false, raft_parcurs(nivel, domeniu_ales)))

	var rafturi: Dictionary = TRIVIA.SUBCATEGORII.get(domeniu_ales, {})
	for cheie in rafturi:
		var raft := String(cheie)
		var cate := TRIVIA.raftul(nivel, domeniu_ales, raft).size()
		lista.add_child(_buton_raft(
			String(rafturi[cheie]), cate, nivel, _pe_raft_ales.bind(raft),
			false, raft_parcurs(nivel, domeniu_ales, raft)))

	_actualizeaza_antet()


func _pe_raft_ales(raft: String) -> void:
	subcategorie_aleasa = raft
	recente.clear()
	panou_alegere.visible = false
	panou_intrebare.visible = true
	# Un raft parcurs deja NU se mai anunță la intrare: o spune butonul lui din
	# lista de rafturi, înainte să intri. Anunțul e pentru clipa în care l-ai
	# terminat, nu pentru fiecare vizită de după.
	_intrebare_noua()


## Rândul de anunț de deasupra întrebării. Gol = ASCUNS, nu doar fără text:
## un Label gol tot cere înălțimea unui rând, iar pe pagina de pergament asta
## se vedea ca o bandă goală deasupra chenarului.
func _anunta(text: String) -> void:
	eticheta_anunt.text = text
	eticheta_anunt.visible = text != ""


# ─────────────────────────────────────────────────────────────
# UN BUTON DE RAFT
# ─────────────────────────────────────────────────────────────

## Numele raftului, și în dreapta, mărunt, ce mai e de spus. Gol = buton
## DEZACTIVAT, nu ascuns.
##
## ─── DE CE DEZACTIVAT ȘI NU ASCUNS ────────────────────────────
## Un raft ascuns e un raft despre care nu afli niciodată nimic: nu știi dacă
## nu există, dacă l-ai pierdut sau dacă n-am scris încă nimic în el. Unul
## stins, cu „gol la nivelul I" pe el, e o hartă a conținutului care lipsește —
## aceeași decizie ca la `PRAG_DOMENIU`, unde domeniile subțiri sunt SĂRITE,
## nu scoase din date.
##
## ─── CE SCRIE ÎN DREAPTA (de pe 21 octombrie 2026) ────────────
## Până azi, pe fiecare buton: „117 la nivelul I". Era zgomot: pe un raft activ
## cifra nu decide nimic din ce faci, iar opt rânduri de cifre se citeau ca un
## tabel, nu ca un meniu. Au rămas doar cele două lucruri care spun ceva:
##
##   — pe un buton STINS, de ce e stins: „gol la nivelul II". Fără asta, un raft
##     stins n-ar mai fi harta de mai sus, ci doar un buton care nu merge.
##   — pe DOMENII (`arata_nivel`), nivelul tău, ca cifră romană. Nivelul e pe
##     domeniu, iar antetul îl arată abia după ce ai ales unul, deci ecranul cu
##     domenii e singurul loc unde le vezi pe toate opt odată.
##   — pe un raft PARCURS (`parcurs`), „Nivel I · 100%": ai răspuns corect la
##     tot ce are, la nivelul tău, deci ce urmează acolo e recapitulare și nu-ți
##     mai mișcă pragul. Până pe 21 octombrie asta o spunea un anunț deasupra
##     întrebării, la fiecare intrare pe raft; acum anunțul vine o singură dată,
##     iar butonul ține minte restul. Procentul apare DOAR la 100%, dinadins:
##     pe toate rafturile, ar fi fost din nou un tabel de cifre în loc de meniu.
##
## „Gol" se judecă tot LA NIVELUL TĂU CURENT, ca înainte. Prețul, spus pe față:
## când deblochezi nivelul II la un domeniu, un raft care are conținut doar la
## nivelul I se stinge.
##
## Eticheta din dreapta e un COPIL al butonului, nu un al doilea text: un Button
## are un singur `text` și o singură aliniere. Ignoră mouse-ul, deci click-ul
## trece la buton. Nu intră în lățimea minimă a butonului — panoul are 560 px,
## iar cel mai lung nume plus „gol la nivelul III" încap cu rezervă.
func _buton_raft(nume: String, cate: int, nivel: int, la_apasare: Callable,
		arata_nivel := false, parcurs := false) -> Button:
	var buton := Button.new()
	buton.custom_minimum_size = Vector2(0, 42)
	buton.text = nume
	buton.disabled = cate == 0
	buton.alignment = HORIZONTAL_ALIGNMENT_LEFT
	# Iconița (când există) se micșorează la înălțimea butonului.
	buton.expand_icon = true
	buton.pressed.connect(la_apasare)

	var dreapta := ""
	if cate == 0:
		dreapta = "gol la nivelul %s" % _roman(nivel)
	elif parcurs:
		dreapta = "Nivel %s · 100%%" % _roman(nivel)
	elif arata_nivel:
		dreapta = _roman(nivel)
	if dreapta != "":
		var eticheta := Label.new()
		eticheta.text = dreapta
		eticheta.theme_type_variation = &"SubtitluPergament"
		eticheta.add_theme_font_size_override("font_size", 15)
		eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		eticheta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		eticheta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		eticheta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		eticheta.offset_right = -14
		buton.add_child(eticheta)
	return buton


## Iconița domeniului, sau `null` dacă nu are.
##
## NICIUN TABEL: fișierul se numește după CHEIA domeniului, care nu se schimbă
## niciodată (vezi `DOMENII` din `trivia.gd`). Un domeniu nou rămâne un rând
## acolo plus un fișier aici; fără fișier, butonul iese fără iconiță, nu cu o
## eroare. Sursa și licența (CC BY 3.0, game-icons.net) sunt în `CREDITE.txt`
## din același dosar. Culoarea nu e în fișier (iconițele sunt albe): o dă tema,
## `Button/colors/icon_*`.
func _iconita(domeniu: String) -> Texture2D:
	var cale := "res://assets/iconite/domenii/%s.svg" % domeniu
	if not ResourceLoader.exists(cale):
		return null
	return load(cale)


# ─────────────────────────────────────────────────────────────
# ECRANUL 3: ÎNTREBĂRILE
# ─────────────────────────────────────────────────────────────

## O întrebare nouă din raftul ales. Chemată și de butonul „Următoarea".
func _intrebare_noua() -> void:
	_inchide_puzzle()
	buton_urmatoarea.disabled = true
	# Anunțul (raft parcurs, nivel deblocat) ține o singură întrebare: e despre
	# răspunsul de dinainte, nu despre cea care vine.
	_anunta("")

	var nivel := nivelul(domeniu_ales)

	# RAFT GOL LA NIVELUL ĂSTA. Se poate întâmpla fără niciun bug: exersezi un
	# raft, treci pragul la jumătate, iar nivelul următor al lui n-are încă
	# conținut. Atunci se spune, în loc să ceri o întrebare care nu există —
	# `trage_din_raft` ar întoarce dicționar gol, iar `puzzle.gd` ar scoate
	# ecranul lui de EROARE, care aici ar fi o minciună: nu e nimic stricat,
	# doar n-am scris încă întrebările.
	if TRIVIA.raftul(nivel, domeniu_ales, subcategorie_aleasa).is_empty():
		zona_puzzle.visible = false
		_anunta("Raftul asta nu are intrebari la nivelul %s. Alege altul." % _roman(nivel))
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
	# ÎN SPATELE creierului, nu peste el. `add_child` o pune ultima, adică
	# deasupra lui `StratNota`, iar rădăcina scenei de trivia prinde mouse-ul pe
	# toată suprafața — click-ul pe creier ar fi ajuns la ea.
	zona_puzzle.move_child(nou, 0)
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
			_anunta(_anunt_raft_parcurs())

	# NOTA, ACUM. `explicatie` e câmpul din contractul cu `puzzle.gd`, pus de
	# `porneste()` din ce a întors disciplina — deci aici nu se întreabă nicio
	# bază de date, se citește ce a ajuns pe ecran. Vezi punctul 1 din antet.
	#
	# SE ÎNTÂMPLĂ LA FEL LA CORECT ȘI LA GREȘIT, și asta e chiar rostul feliei:
	# momentul în care ai cea mai mare nevoie de notă e cel în care n-ai știut.
	# „Ton sănătos" din CLAUDE.md — înveți ceva și când greșești.
	_seteaza_nota(String(de_la.explicatie), true)

	# FOCUSUL RĂMÂNE PE „URMĂTOAREA", chiar dacă creierul tocmai s-a aprins.
	# Drumul obișnuit e „răspund, merg înainte", iar un Enter care deschide brusc
	# un popup ar fi o surpriză plătită de cel care citea repede. Nota e o
	# alegere, nu un pas.
	buton_urmatoarea.disabled = false
	buton_urmatoarea.grab_focus()
	_actualizeaza_antet()

	# Un anunț vizibil acum e al răspunsului ăstuia (`_intrebare_noua` îl
	# golește), deci bara nu pornește: vezi punctul 4 din „Trecerea singură".
	if succes and not eticheta_anunt.visible:
		_porneste_auto()


## Aprinde sau stinge creierul, după nota pe care o primește. Gol = stins.
##
## `raspuns_dat` alege doar ce spune iconița la survolare: înainte de verdict
## e stinsă fiindcă nota ți-ar da răspunsul, după el fiindcă nota nu există.
## Același aspect, două motive — iar fără text, al doilea ar fi arătat ca un
## buton care nu merge.
##
## La aprindere, un puls scurt: creierul se umflă și revine. E singurul semn
## că s-a schimbat ceva în colțul în care nu te uiți când răspunzi.
func _seteaza_nota(nota: String, raspuns_dat: bool) -> void:
	nota_curenta = nota
	buton_nota.disabled = nota == ""
	if nota != "":
		buton_nota.tooltip_text = "Afla mai multe"
		var puls := create_tween()
		puls.tween_property(buton_nota, "scale", Vector2.ONE, 0.3) \
			.from(Vector2.ONE * 1.3) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif raspuns_dat:
		buton_nota.tooltip_text = "Intrebarea asta nu are inca nota"
	else:
		buton_nota.tooltip_text = "Nota se aprinde dupa raspuns"


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
## `_inchide_nota`: o apăsare pe creier poate veni când nu curge nimic.
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
	# oprește) ar lăsa aprins creierul întrebării de dinainte — adică o notă
	# care nu mai are nicio întrebare deasupra ei.
	#
	# Un singur loc pentru amândouă fiindcă sunt un singur lucru: întrebarea și
	# nota ei se nasc și mor împreună. Despărțite în două funcții, ar fi existat
	# un drum din care se poate uita a doua.
	_seteaza_nota("", false)
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
## Garda nu e paranoia: creierul e stins când nota lipsește, dar o tastă
## (Enter pe un buton care tocmai s-a stins) poate ajunge la un semnal cu un
## cadru întârziere. Un popup gol ar fi arătat ca un bug.
func _deschide_nota() -> void:
	if nota_curenta == "":
		return
	# Prima linie după gardă: o notă deschisă nu are voie să fie schimbată de
	# sub tine. E singurul loc care oprește bara la cererea ta.
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
	# șterge la întrebarea următoare (vezi `_intrebare_noua`).
	_anunta("Nivelul %s deblocat la %s." % [
		_roman(nivel + 1), TRIVIA.DOMENII.get(domeniu, domeniu)])


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

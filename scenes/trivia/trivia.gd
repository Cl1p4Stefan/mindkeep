extends Control
## Puzzle de TRIVIA — scenă complet independentă.
##
## Nu știe absolut nimic despre luptă, PV, PA sau inamici. Contractul ei cu
## restul jocului are exact trei capete:
##   1. `porneste(nivel)`           — CE PRIMEȘTE (dificultatea)
##   2. semnalul `verdict(bun)`     — „am răspuns", strigat pe loc
##   3. semnalul `rezolvat(succes)` — CE RETURNEAZĂ (adevărat/fals), după pauză
##
## De ce contează izolarea asta: peste trei sesiuni o să faci Anagrama, iar
## ea va avea EXACT aceeași formă (porneste + rezolvat). Atunci Combat
## Controller-ul nu va trebui schimbat deloc — doar îi dai altă scenă.
## Bonus: poți testa scena singură cu F6, fără să treci prin luptă.

# Semnal = „strigătul" pe care nodul îl scoate când s-a întâmplat ceva.
# Astea sunt căile noastre de ieșire: cine ne-a deschis ne ascultă. Sunt două,
# și poartă ACELAȘI adevăr, dar în două momente diferite.
#
# `verdict` — strigat ÎN CLIPA răspunsului, nu după pauza de feedback.
# ASTĂZI NU-L ASCULTĂ NIMENI: reacția vizuală s-a mutat ÎN scenă, pe variante
# (vezi `_termina`), fiindcă butoanele sunt ale disciplinei, nu ale
# luptei. Rămâne declarat fiindcă e singurul moment „chiar acum" pe care
# puzzle-ul îl poate oferi în afară — de el se agață zguduirea ecranului sau
# un sunet NEUTRU de „am auzit clickul", când vor exista. Dacă până atunci nu
# se agață nimic de el, se poate șterge fără să atingi nimic altceva.
#
# SUNETUL DE VERDICT NU S-A AGĂȚAT AICI, deși aici părea locul lui: el sună
# altfel la bine decât la rău, deci E un verdict, iar un verdict dat în cadrul
# clickului ar strica pauza de suspans dinaintea culorilor. A plecat unde îi e
# locul, lângă ce anunță — în `_aprinde_raspunsul` (răspuns dat) și în
# `_fulgera_bara_expirata` (timp expirat).
signal verdict(bun: bool)
#
# `rezolvat` — REZULTATUL, strigat abia după pauza de feedback. El pune lupta
# în mișcare (daune, lanț), iar asta are voie să aștepte cât te uiți la
# răspunsul corect.
#
# Niciunul nu spune cine ascultă sau ce desenează acela: amândouă spun doar
# „bun" sau „greșit". Contractul rămâne la fel de subțire.
signal rezolvat(succes: bool)

# ─────────────────────────────────────────────────────────────
# REGULI
# ─────────────────────────────────────────────────────────────
# Secunde disponibile, pe nivel de dificultate (I, II, III).
# Nivelul III primește mai mult nu fiindcă e mai greu, ci fiindcă întrebările
# lui sunt mai LUNGI de citit — timpul plătește lectura, nu gândirea.
const TIMP_PE_NIVEL := [12.0, 12.0, 15.0]

# Podeaua: oricât ar cere apelantul, sub atât nu coborâm.
# E o regulă de corectitudine față de jucător și trăiește AICI, nu în luptă:
# scena de puzzle e singura care știe cât durează să citești o întrebare.
const TIMP_MINIM := 8.0

const PRAG_URGENTA := 5.0     # sub atâtea secunde, bara devine roșie

# Culorile de după răspuns: verdele care arată varianta corectă, roșul care
# marchează alegerea greșită. Nu există și un cuvânt scris („CORECT"): în
# clipa aia te uiți la butonul pe care ai apăsat, nu la un rând de text de
# deasupra lui — și exact acolo cade acum și semnalul.
# Rămân constante, nu numere scrise în mijlocul codului, fiindcă apar în două
# locuri și trebuie să fie exact aceleași.
const CULOARE_BUN := Color(0.45, 1, 0.55)
const CULOARE_RAU := Color(1, 0.4, 0.4)

# ── CUM APAR CULORILE ASTEA ───────────────────────────────────
# ÎN TREI TIMPI, nu într-unul. Ordinea contează mai mult decât culorile:
#
#   1. CONFIRMAREA — instantaneu, la click. Butonul pe care ai apăsat se
#      întunecă spre gri (CULOARE_ASTEPTARE). Spune doar „am auzit clickul",
#      nu spune dacă e bine sau rău — e ACEEAȘI culoare și când ai nimerit, și
#      când nu. Fără ea, butoanele s-ar bloca și ecranul ar îngheța o jumătate
#      de secundă fără explicație — iar o jumătate de secundă de nimic se
#      citește ca un bug, nu ca suspans.
#
#   2. SUSPANSUL — PAUZA_SUSPANS, în care nu se schimbă nimic pe ecran. Aici
#      stă tot efectul: o clipă în care ții cu tine însuți. Trebuie să fie
#      IDENTICĂ și la bine, și la rău — dacă greșeala ar fi arătată pe loc și
#      doar verdele ar întârzia, atunci ÎNTÂRZIEREA ÎNSĂȘI ar deveni răspunsul:
#      ai ști din primul cadru că ai nimerit, și n-ar mai rămâne niciun suspans.
#
#   3. VERDICTUL — verdele (și roșul, dacă e cazul) CRESC, nu se taie: fondul
#      urcă spre culoare, iar în jurul variantei corecte se desenează o ramă.
#      Când se termină creșterea, culoarea rămâne pusă până la întrebarea
#      următoare — ce e de citit stă nemișcat cât îl citești.
#
# Unde e granița dintre „fluid" și „agitat", fiindcă aici s-a greșit o dată:
# s-au încercat, pe rând, și o ramă de panou care tresărea, și un puls
# repetat pe butoane — amândouă țineau ochiul ocupat DUPĂ ce informația
# fusese deja transmisă. Regula rămasă din experiența aia: mișcarea are voie
# să ADUCĂ răspunsul, n-are voie să-l ÎNSOȚEASCĂ. O singură creștere, într-o
# singură direcție, care se termină clar — nu un puls, nu o pâlpâire.
#
# Regula scurtă: așteptarea e goală, culoarea CREȘTE o dată și apoi stă.
# Singura altă mișcare e bara de timp la timeout, mai jos.

# Culoarea de așteptare: butonul apăsat, cât ține suspansul. E o ÎNTUNECARE
# (gri-albăstrui sub alb), nu o culoare nouă — nu seamănă nici cu verdele, nici
# cu roșul, deci nu poate fi citită din greșeală ca un verdict pe jumătate dat.
const CULOARE_ASTEPTARE := Color(0.62, 0.62, 0.7)

# Cât ține AȘTEPTAREA GOALĂ, adică pauza dinainte să se miște ceva.
# E mai scurtă decât pare: suspansul întreg nu e doar ea, ci ea PLUS urcarea
# culorii de mai jos (0,35 + 0,28 ≈ 0,6 s până vezi limpede verdele). Când am
# adăugat creșterea, pauza goală a trebuit scurtată cu exact atât — altfel
# aceeași senzație ar fi durat de două ori mai mult. Dacă reglezi una, uită-te
# la sumă, nu la număr.
const PAUZA_SUSPANS := 0.35

# ── APRINDEREA RĂSPUNSULUI (TIMPUL 3) ─────────────────────────
# Fondul butonului nu sare în verde: urcă în două mișcări lipite.
#   URCAREA  — de la gri spre un verde mai DESCHIS decât cel final (VARF).
#   AȘEZAREA — din vârf înapoi în CULOARE_BUN, unde rămâne.
# De ce vârful, și nu o urcare dreaptă până la culoarea finală: o culoare care
# trece puțin peste țintă și se așază se citește ca o APRINDERE — ceva s-a
# aprins acolo. Una care urcă drept se citește ca o decolorare lentă, adică a
# unui lucru care se strică. Aceleași două culori, două înțelesuri diferite,
# și toată diferența stă în ultimele 0,22 s.
const DURATA_URCARE := 0.28
const DURATA_ASEZARE := 0.22
const CULOARE_BUN_VARF := Color(0.72, 1, 0.8)
const CULOARE_RAU_VARF := Color(1, 0.62, 0.6)

# CONTURUL: rama care se desenează în jurul variantei CORECTE, în același timp
# cu verdele. Fondul spune o stare („asta e bună"), rama arată cu degetul
# („aici"). De-aia o are doar varianta corectă — dacă ar avea-o și cea greșită,
# n-ar mai arăta nimic, ar fi doar decor pe ambele.
#
# Grosimea se pune o dată și NU se animează. Bordura unui StyleBoxFlat se
# desenează spre INTERIOR, așa că o ramă care se îngroașă cadru cu cadru împinge
# textul dinăuntru — exact textul pe care îl ai de citit. Se animează doar ALFA
# ei: de la invizibilă la plină. Rama apare din neant, dar nimic nu se mișcă.
const GROSIME_CONTUR := 3

# Culoarea ramei e aproape albă, nu verde, deși rama se vede verde: peste ea
# cade `modulate` al butonului, care în clipa aia e chiar verdele. Alb × verde
# = verde aprins; verde × verde = verde închis, adică o ramă care dispare în
# fondul ei. Când o culoare stă peste alta, o alegi gândindu-te la produs.
const CULOARE_CONTUR := Color(0.85, 1, 0.9)

# Rama crește cât durează TOATĂ mișcarea fondului, ca să se termine odată cu
# ea: două mișcări care se opresc în același moment se citesc ca una singură.
const DURATA_CONTUR := DURATA_URCARE + DURATA_ASEZARE

# ── FULGERUL BAREI DE TIMP (doar la timp expirat) ─────────────
# Dacă n-ai apăsat nimic, niciun buton nu poate purta vina, iar verdele singur
# arată ca un răspuns bun dat de altcineva: lipsește exact ce s-a întâmplat.
# Semnalul îl dă bara — lucrul care s-a terminat.
# Durata și curba sunt cele ale fostului fulger de panou; aici au rămas fiindcă
# ăsta e un EVENIMENT care trece, nu o culoare de citit.
const DURATA_APRINDERE_VERDICT := 0.10   # cât durează aprinderea
const PAUZA_VERDICT := 0.20              # cât stă în vârf
const DURATA_REVENIRE_VERDICT := 0.75    # cât durează stingerea

# Culoarea în care se aprinde ȘANȚUL barei de timp.
# De ce o culoare scrisă și nu `modulate`, ca la butoane: la timeout bara e
# goală, deci din ea nu se mai vede decât șanțul — iar șanțul din tema Godot e
# un gri aproape negru, și pe deasupra aproape transparent (alfa 0,3). Aproape
# negru ÎNMULȚIT cu roșu rămâne aproape negru. Ca să se vadă ceva, culoarea
# trebuie PUSĂ peste, nu înmulțită — și asta se face în stilul barei, nu în
# `modulate` (vezi `_pregateste_bara`).
# Alfa 1 e intenționat: în repaus șanțul abia se ghicește, iar la fulger devine
# o dungă plină. Diferența dintre cele două stări e jumătate din semnal.
#
# De ce un roșu ÎNCHIS și nu unul aprins: fulgerul e o dungă lată cât toată
# lățimea scenei, iar un roșu saturat pe o suprafață atât de mare țipă mai tare
# decât merită evenimentul — ți-a expirat timpul la o întrebare, n-ai pierdut
# lupta. E ACELAȘI roșu ca al barei în urgență (vezi CULOARE_URGENTA mai jos),
# doar coborât în luminozitate: aceeași nuanță înseamnă „tot despre timp e
# vorba", iar întunecarea îl ține în tonul gotic al jocului. Contrastul cu
# șanțul de repaus (aproape negru, aproape transparent) rămâne oricum mare —
# semnalul vine din alfa și din SCHIMBARE, nu din strident.
const CULOARE_BARA_EXPIRATA := Color(0.45, 0.16, 0.14, 1.0)

# Cele două stări NORMALE ale barei de timp, ca `modulate` (înmulțit peste
# umplutura deschisă a temei): albastru rece cât ai timp, roșu cald sub prag.
# Sunt constante ca să se vadă negru pe alb că roșul de expirare de mai sus e
# aceeași nuanță, doar mai închisă.
const CULOARE_URGENTA := Color(1, 0.35, 0.3)
const CULOARE_CALM := Color(0.55, 0.85, 1)

# Culorile liniei de context: aurie TOT TIMPUL. Portocaliul nu mai e o stare
# în care poate sta linia, ci culoarea unui singur moment — cel marcat prin
# `arata_combo()`. O culoare care ține minute întregi nu mai anunță nimic;
# una care ține o clipă e un semnal.
const CULOARE_CONTEXT := Color(1, 0.83, 0.42)
const CULOARE_ACCENT := Color(1, 0.45, 0.2)

# FLASH-ul liniei de context: culoarea din vârful pulsului, cât ține revenirea
# și cât se umflă eticheta. Alb, fiindcă e mai aprins decât ORICE culoare de
# bază — pulsul se vede la fel de bine și pe auriu, și pe portocaliu.
const CULOARE_FLASH := Color(1, 1, 1)
const DURATA_FLASH := 0.26
const SCARA_FLASH := 1.45

# MARCAJUL: eticheta scurtă care fulgeră lângă linia de context (lupta trimite
# acolo „CRITIC!"). Scena nu știe ce înseamnă textul — știe doar să-l aprindă,
# să-l țină cât să-l citești și să-l stingă.
#   DURATA_MARCAJ — cât stă tot momentul pe ecran, aprindere inclusă
#   DURATA_APARITIE_MARCAJ — cât durează aprinderea (scurtă: e o tresărire)
#   DURATA_REVENIRE — cât durează întoarcerea la normal. Mai lentă decât
#     aprinderea: ce apare trebuie să te ia prin surprindere, ce dispare nu
#     trebuie să pară că a fost șters.
const DURATA_MARCAJ := 0.4
const DURATA_APARITIE_MARCAJ := 0.1
const DURATA_REVENIRE := 0.2

const PAUZA_FEEDBACK := 1.8   # cât stai să vezi răspunsul corect, înainte de a te întoarce în luptă

# Pauza de după răspuns rămâne 1,8 s în TOTAL — ritmul lanțului nu se schimbă
# fiindcă am adăugat suspans. Ea doar se împarte acum în două: întâi aștepți
# (PAUZA_SUSPANS), apoi citești răspunsul corect (PAUZA_CITIRE). Scris ca
# scădere, nu ca număr nou: dacă mărești suspansul, timpul total nu crește pe
# furiș — se scurtează cititul, și vezi imediat dacă ai mers prea departe.
const PAUZA_CITIRE := PAUZA_FEEDBACK - PAUZA_SUSPANS

# ─────────────────────────────────────────────────────────────
# ÎNTREBĂRILE — acum într-un fișier JSON, nu în cod.
#
# De ce merită mutarea: conținutul se schimbă mult mai des decât regulile.
# Ca să adaugi o întrebare nu mai deschizi cod, nu mai riști o virgulă
# pusă greșit care refuză să compileze tot jocul, și poți edita fișierul
# de pe telefon dacă-ți vine o idee. E și primul pas către traduceri.
#
# Prețul: Godot nu mai poate verifica nimic la compilare. Un JSON stricat
# se vede abia la rulare — de aceea încărcătorul de mai jos VALIDEAZĂ
# fiecare intrare și sare peste cele stricate, cu un avertisment în consolă,
# în loc să crape lupta la mijloc.
# ─────────────────────────────────────────────────────────────
const CALE_INTREBARI := "res://data/intrebari_trivia.json"
const CATEGORII := ["istorie", "stiinta", "geografie", "arta"]

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de ~7 ori pe rundă; fără `static`, fișierul ar fi citit
# de pe disc de fiecare dată. Așa, se citește o singură dată pe rulare,
# iar toate instanțele viitoare folosesc aceeași listă.
static var intrebari: Array[Dictionary] = []
static var incarcare_incercata := false


## Citește și validează fișierul. Sigur de chemat de oricâte ori:
## după prima încercare nu mai face nimic.
static func incarca_intrebari() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	if not FileAccess.file_exists(CALE_INTREBARI):
		push_error("Trivia: nu gasesc fisierul %s" % CALE_INTREBARI)
		return

	var text := FileAccess.get_file_as_string(CALE_INTREBARI)

	# Folosim un obiect JSON, nu JSON.parse_string(), tocmai ca să putem
	# spune PE CE LINIE e greșeala. Într-un fișier scris de mână, asta e
	# diferența dintre „ceva e stricat" și „lipsește o virgulă la linia 214".
	var parser := JSON.new()
	if parser.parse(text) != OK:
		push_error("Trivia: JSON invalid la linia %d — %s" % [
			parser.get_error_line(), parser.get_error_message()
		])
		return

	var brute = parser.data
	if not (brute is Array):
		push_error("Trivia: %s trebuie sa contina o LISTA de intrebari." % CALE_INTREBARI)
		return

	for i in range(brute.size()):
		var q = brute[i]
		if not _intrebare_valida(q, i):
			continue
		# ATENȚIE, capcană clasică: JSON nu are numere întregi, doar zecimale.
		# „corect": 2 ajunge în Godot ca 2.0 (float), iar un float nu poate
		# indexa un Array. Convertim o dată, aici, ca restul codului să
		# lucreze liniștit cu int-uri.
		q["corect"] = int(q["corect"])
		q["nivel"] = int(q["nivel"])
		intrebari.append(q)

	print("Trivia: %d intrebari incarcate (din %d gasite)." % [intrebari.size(), brute.size()])


## Verifică o singură intrare. Întoarce false și explică în consolă,
## în loc să lase o întrebare stricată să ajungă în luptă.
static func _intrebare_valida(q, i: int) -> bool:
	if not (q is Dictionary):
		push_warning("Trivia: intrarea %d nu e un obiect." % i)
		return false

	for cheie in ["text", "variante", "corect", "nivel", "categorie"]:
		if not q.has(cheie):
			push_warning("Trivia: intrarea %d nu are campul '%s'." % [i, cheie])
			return false

	if not (q["variante"] is Array) or q["variante"].size() != 4:
		push_warning("Trivia: intrarea %d nu are exact 4 variante." % i)
		return false

	var corect := int(q["corect"])
	if corect < 0 or corect > 3:
		push_warning("Trivia: intrarea %d are 'corect' = %d, in afara intervalului 0-3." % [i, corect])
		return false

	var nivel := int(q["nivel"])
	if nivel < 1 or nivel > TIMP_PE_NIVEL.size():
		push_warning("Trivia: intrarea %d are nivelul %d, in afara intervalului 1-3." % [i, nivel])
		return false

	if not (q["categorie"] in CATEGORII):
		push_warning("Trivia: intrarea %d are categoria necunoscuta '%s'." % [i, q["categorie"]])
		return false

	return true


# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
var timp_ramas := 0.0
var indice_corect := -1
var raspuns_dat := false   # ca un al doilea click să nu poată răspunde de două ori
var pornit := false        # a chemat cineva porneste()?

@onready var eticheta_categorie: Label = %CategorieEticheta
@onready var eticheta_context: Label = %ContextEticheta
# Marcajul stă în STÂNGA contextului, în același rând. Rândul e aliniat la
# dreapta, deci un element nou apărut în stânga crește spre golul din mijloc
# și NU împinge cifra de combo din loc — altfel, exact în cadrul în care vrei
# să citești „×5", cifra ar sări lateral.
@onready var eticheta_marcaj: Label = %MarcajEticheta

# Pulsul liniei de context, ținut ca să-l putem OMORÎ când textul se schimbă
# din nou. Fără referință, două pulsuri suprapuse s-ar bate pe `modulate`.
var tween_context: Tween = null
# Același motiv pentru marcaj: două marcaje suprapuse s-ar bate pe alfa, iar
# al doilea ar putea rămâne pe ecran după ce primul îl stinge.
var tween_marcaj: Tween = null

# Fulgerul barei de timp, ținut ca să-l putem OMORÎ la întrebarea următoare.
var tween_bara: Tween = null

# Aprinderea răspunsului (fond + contur), ținută din același motiv: dacă
# întrebarea următoare începe înainte ca ea să termine, un tween rămas în viață
# ar continua să scrie verde peste butonul deja resetat. Un singur tween pentru
# toate bucățile mișcării, ca să existe o singură frână.
var tween_raspuns: Tween = null

# Rama variantei corecte, ca RESURSĂ, nu ca nod: alfa EI e ce animăm. Se naște
# la fiecare răspuns, în `_stil_contur_pentru()`, și e aruncată la întrebarea
# următoare. Vezi acolo de ce nu atingem niciodată stilul original al temei.
var stil_contur: StyleBoxFlat = null
# Stilul șanțului barei de timp, ca RESURSĂ, nu ca nod: culoarea LUI e ce
# animăm la timp expirat. Copia proprie se face în `_pregateste_bara()` —
# vezi acolo de ce nu atingem niciodată stilul original.
var stil_bara: StyleBoxFlat = null
var culoare_sant_repaus := Color.BLACK

@onready var bara_timp: ProgressBar = %BaraTimp
@onready var eticheta_intrebare: Label = %Intrebare
@onready var butoane := [%Varianta1, %Varianta2, %Varianta3, %Varianta4]


func _ready() -> void:
	# `_process` (cronometrul) e OPRIT până când cineva cheamă porneste().
	# Altfel timpul ar curge și pe scena goală, în editor.
	set_process(false)
	# Ascunsă până când cineva chiar are ceva de arătat acolo (ex. la F6,
	# când testezi scena singură, nu există niciun inamic).
	incarca_intrebari()   # citește fișierul o singură dată pe rulare
	_pregateste_bara()    # copia de stil pentru fulgerul de timp expirat
	for index in range(butoane.size()):
		var buton: Button = butoane[index]
		buton.pressed.connect(_pe_varianta_aleasa.bind(index))

	# Ca să poți testa scena singură cu F6: dacă nimeni n-a chemat porneste()
	# până la finalul acestui cadru, pornim noi, pe nivelul 1.
	await get_tree().process_frame
	if not pornit:
		porneste(1)


## PUNCTUL DE INTRARE. Asta e tot ce trebuie să știe lumea din afară.
##
## Toți parametrii în afară de `nivel` sunt opționali și NEUTRI — niciunul
## nu-i spune scenei ce e un lanț, o treaptă sau o lovitură critică:
##   `context`  — text scurt, lipit lângă categorie. Îl afișăm, nu-l citim.
##   `scurtare` — cu câte secunde să tăiem din timpul de bază (podeaua e a noastră).
## Așa lupta poate marca un streak cu un „×5" discret fără ca Trivia să
## învețe nimic despre luptă: contractul rămâne la fel de subțire.
##
## Culoarea NU se cere de afară. Un context proaspăt scris e mereu auriu;
## accentul e treaba lui `arata_combo()`, care marchează un MOMENT, nu o stare.
func porneste(nivel: int, context := "", scurtare := 0.0) -> void:
	pornit = true
	nivel = clampi(nivel, 1, TIMP_PE_NIVEL.size())   # apărare: nu accepta nivel 7
	incarca_intrebari()

	# `filter` trece prin array și păstrează doar elementele pentru care
	# funcția anonimă (lambda) întoarce true. Aici: doar întrebările de nivelul cerut.
	var pool: Array = intrebari.filter(func(q): return q["nivel"] == nivel)
	if pool.is_empty():
		pool = intrebari   # plasă de siguranță: mai bine o întrebare de alt nivel decât un crash

	# Dacă fișierul lipsește sau e complet stricat, nu avem NICIO întrebare.
	# Nu ne putem opri pur și simplu: lupta ne așteaptă semnalul, și ar
	# îngheța pentru totdeauna. Deci raportăm eșec, ordonat.
	if pool.is_empty():
		_fara_intrebari()
		return

	var q: Dictionary = pool.pick_random()
	indice_corect = q["corect"]
	raspuns_dat = false

	# Antetul are un singur rost acum: să-ți spui din ce domeniu e întrebarea.
	# Nivelul nu mai apare — îl simți oricum din cronometru și din dificultate,
	# iar scris pe ecran era o etichetă pe care n-o mai citeai.
	eticheta_categorie.text = String(q["categorie"]).to_upper()

	# Streak-ul, cât mai discret: un „×4" mic lângă categorie.
	# La deschiderea întrebării îl scriem TĂCUT, fără puls: cifra asta e deja
	# câștigată și deja văzută: a pulsat la răspunsul care a produs-o.
	# Pulsează doar prin `arata_combo()`, adică exact când crește.
	_scrie_context(context)
	eticheta_intrebare.text = q["text"]

	var variante: Array = q["variante"]
	# Oprim întâi aprinderea rămasă de la răspunsul precedent. Dacă un tween ar
	# mai rula, ar rescrie culorile după ce noi le punem la loc — și ai începe
	# întrebarea nouă cu un buton care se face verde singur.
	if tween_raspuns != null and tween_raspuns.is_valid():
		tween_raspuns.kill()
	stil_contur = null

	for index in range(butoane.size()):
		var buton: Button = butoane[index]
		buton.text = variante[index]
		buton.disabled = false
		buton.modulate = Color.WHITE   # ștergem verdele/roșul de la runda trecută
		# ...și rama: scoatem stilul propriu pus la răspunsul trecut, ca butonul
		# să se întoarcă la cel al temei. `remove_theme_stylebox_override` nu se
		# supără dacă nu era nimic de scos, deci nu trebuie întrebat înainte.
		buton.remove_theme_stylebox_override("disabled")

	# maxf() = maximul a două zecimale. Podeaua se aplică AICI, o singură dată,
	# deci nimeni din afară nu poate cere din greșeală o întrebare de 2 secunde.
	var timp_total: float = maxf(TIMP_PE_NIVEL[nivel - 1] - scurtare, TIMP_MINIM)
	timp_ramas = timp_total
	bara_timp.max_value = timp_total
	bara_timp.modulate = Color.WHITE
	# Bara: oprim întâi fulgerul rămas de la un timeout precedent. Dacă un tween
	# ar mai rula, ar rescrie culoarea șanțului după ce noi o punem la loc.
	if tween_bara != null and tween_bara.is_valid():
		tween_bara.kill()
	if stil_bara != null:
		stil_bara.bg_color = culoare_sant_repaus

	butoane[0].grab_focus()   # ca să meargă și cu tastatura (săgeți + Enter)
	actualizeaza_cronometru()
	set_process(true)         # ABIA ACUM pornește timpul


## INERTĂ ACUM, dar păstrată: face parte din contractul pe care îl are orice
## disciplină, iar lupta o cheamă la fiecare lovitură.
##
## Cât timp puzzle-ul acoperea tot ecranul, avea nevoie de bara ei proprie, ca
## să vezi inamicul slăbind. De când întrebarea stă într-un panou în mijlocul
## arenei, barele adevărate rămân vizibile în stânga și în dreapta — a doua
## bară ar fi fost aceeași informație, desenată de două ori.
##
## Rămâne aici fiindcă altundeva (un tur de antrenament în Cetate, de pildă)
## s-ar putea să nu existe o arenă în spate. Atunci se reumple; până atunci,
## contractul e respectat fără să deseneze nimic.
func arata_stare(_valoare: float, _maxim: float) -> void:
	pass


## ── MARCAJUL DE STREAK ─────────────────────────────────────────
## PARTE DIN CONTRACT, ca `porneste()` și `arata_stare()`. Lupta o cheamă
## după un răspuns corect, cât întrebarea e ÎNCĂ pe ecran, ca să vezi cifra
## urcând PESTE răspunsul tău — nu abia la întrebarea următoare.
##
## Primim un String gata compus. Scena tot nu știe ce e un combo, o treaptă
## sau un lanț: știe doar să scrie o linie și s-o facă să pulseze când e nouă.
## `marcaj` e al doilea capăt al aceluiași gest: un text scurt care FULGERĂ
## lângă context și dispare. Gol = momentul e obișnuit. Scena nu-l citește;
## îl aprinde. Așa lupta poate striga „CRITIC!" fără ca disciplina să afle
## vreodată ce e o lovitură critică.
func arata_combo(text: String, marcaj := "") -> void:
	var s_a_schimbat := text != eticheta_context.text
	_scrie_context(text)
	# Pulsăm la APARIȚIE și la CREȘTERE — adică ori de câte ori cifra e alta.
	# Un text identic (sau gol) nu merită un puls: n-ai ce observa.
	if text != "" and s_a_schimbat:
		_pulseaza_context(marcaj != "")
	# Marcajul e independent de cifră: e un eveniment, nu o valoare.
	if marcaj != "":
		_arata_marcaj(marcaj)


## Scrie linia de context și decide dacă ea există pe ecran.
## Un Label gol tot ocupă spațiu în container, deci text gol = ascuns de tot.
##
## Aici se OMOARĂ și pulsul în curs. `modulate` ține și culoarea, și albul de
## flash; dacă un tween vechi ar mai rula peste textul nou, ar trage culoarea
## înapoi spre ce era înainte.
func _scrie_context(text: String) -> void:
	if tween_context != null and tween_context.is_valid():
		tween_context.kill()
	eticheta_context.text = text
	eticheta_context.visible = text != ""
	# MEREU auriu. Portocaliul îl pune doar pulsul, și doar pentru o clipă.
	eticheta_context.modulate = CULOARE_CONTEXT
	eticheta_context.scale = Vector2.ONE
	# Marcajul însoțea contextul de dinainte. Context nou (întrebare nouă sau
	# serie ruptă) = el nu mai are ce descrie, deci pleacă odată cu ea.
	_ascunde_marcaj()


## Pulsul: eticheta se aprinde alb și se umflă, apoi revine la culoarea ei.
## De ce și mărime, nu doar culoare: în timpul unei întrebări te uiți la
## variante, nu la antet. O schimbare de MĂRIME se prinde cu coada ochiului;
## una de culoare, pe un text mic, deseori nu.
## `critic` nu schimbă pulsul, ci CULOAREA ÎN CARE SE AȘAZĂ el: portocaliu în
## loc de auriu, și doar cât ține marcajul de alături. Pe urmă linia se întoarce
## la auriu, ca la orice altă treaptă.
func _pulseaza_context(critic := false) -> void:
	var text_la_start := eticheta_context.text
	# Un cadru de așteptare. Tocmai am schimbat textul, dar containerul
	# reașază copiii abia la finalul cadrului — până atunci `size` (și cu ea
	# mijlocul etichetei) e cea de dinainte, iar pivotul ar cădea strâmb.
	await get_tree().process_frame
	# Între timp întrebarea s-ar fi putut încheia. Dacă pe ecran nu mai e
	# același text, pulsul ăsta n-are ce anima.
	if not is_instance_valid(eticheta_context) or eticheta_context.text != text_la_start:
		return
	if not eticheta_context.visible:
		return

	# `pivot_offset` = punctul în jurul căruia se scalează. Implicit e colțul
	# din stânga-sus, deci eticheta ar „crește spre dreapta-jos".
	# Îl punem pe marginea DIN DREAPTA, la mijlocul înălțimii: eticheta e
	# lipită de dreapta panoului (`alignment = END`), deci acolo are 14px de
	# margine și nimic altceva. Umflată din centru ar ieși din panou; umflată
	# din dreapta crește spre interior, unde e loc gol.
	eticheta_context.pivot_offset = Vector2(
		eticheta_context.size.x, eticheta_context.size.y / 2.0
	)

	# Culoarea în care se așază pulsul. La un moment obișnuit e auriul normal;
	# la unul marcat, portocaliul — dar ca escală, nu ca destinație.
	var culoare_baza := CULOARE_ACCENT if critic else CULOARE_CONTEXT
	eticheta_context.modulate = CULOARE_FLASH
	eticheta_context.scale = Vector2.ONE * SCARA_FLASH

	# `set_parallel(true)` = toți pașii pornesc odată, nu unul după altul:
	# vrem ca revenirea la mărime și cea la culoare să fie ACELAȘI gest.
	tween_context = create_tween().set_parallel(true)
	# TRANS_BACK + EASE_OUT trece puțin SUB mărimea normală înainte să se
	# așeze. Acel mic „recul" e ce face pulsul să pară o bătaie, nu o topire.
	var pas_scara := tween_context.tween_property(eticheta_context, "scale", Vector2.ONE, DURATA_FLASH)
	pas_scara.set_ease(Tween.EASE_OUT)
	pas_scara.set_trans(Tween.TRANS_BACK)
	tween_context.tween_property(eticheta_context, "modulate", culoare_baza, DURATA_FLASH)

	if not critic:
		return

	# Întoarcerea la auriu. `chain()` pune pasul următor DUPĂ ce se termină tot
	# ce rulează în paralel, nu odată cu el — de asta îl chemăm de două ori:
	# o dată pentru pauză, o dată pentru revenire. Fără el, într-un tween pus pe
	# paralel toți pașii ar porni în același cadru și portocaliul n-ar apuca
	# să existe.
	# `maxf(..., 0.0)`: dacă cineva scurtează cândva DURATA_MARCAJ sub durata
	# pulsului, vrem pauză zero, nu o durată negativă.
	tween_context.chain().tween_interval(maxf(DURATA_MARCAJ - DURATA_FLASH, 0.0))
	tween_context.chain().tween_property(
		eticheta_context, "modulate", CULOARE_CONTEXT, DURATA_REVENIRE
	)


## MARCAJUL. Apare, stă cât să-l citești, se stinge. E un EVENIMENT, nu o
## stare: dacă ar rămâne pe ecran, a doua oară n-ai mai vedea nimic
## întâmplându-se — și exact „s-a întâmplat ceva" e tot ce are de spus.
func _arata_marcaj(text: String) -> void:
	if tween_marcaj != null and tween_marcaj.is_valid():
		tween_marcaj.kill()
	eticheta_marcaj.text = text
	eticheta_marcaj.visible = true
	# Culoarea e pusă din primul cadru, iar apoi tragem DOAR de alfa
	# (`modulate:a`, transparența). Așa textul nu trece prin nicio nuanță
	# intermediară: apare direct portocaliu, doar din ce în ce mai opac.
	eticheta_marcaj.modulate = CULOARE_ACCENT
	eticheta_marcaj.modulate.a = 0.0

	# Tween NEparalel (implicit): pașii se execută unul după altul —
	# apare, stă, se stinge.
	tween_marcaj = create_tween()
	tween_marcaj.tween_property(eticheta_marcaj, "modulate:a", 1.0, DURATA_APARITIE_MARCAJ)
	tween_marcaj.tween_interval(maxf(DURATA_MARCAJ - DURATA_APARITIE_MARCAJ, 0.0))
	tween_marcaj.tween_property(eticheta_marcaj, "modulate:a", 0.0, DURATA_REVENIRE)
	# La final îl scoatem din layout de tot: un Label transparent tot ocupă
	# lățime, iar rândul ar rămâne împins degeaba.
	tween_marcaj.tween_callback(func(): eticheta_marcaj.visible = false)


## Stinge marcajul pe loc, fără animație. Îl cheamă `_scrie_context()`: acolo
## se schimbă chiar lucrul pe care marcajul îl însoțea.
func _ascunde_marcaj() -> void:
	if tween_marcaj != null and tween_marcaj.is_valid():
		tween_marcaj.kill()
	eticheta_marcaj.visible = false
	eticheta_marcaj.text = ""


## Ieșirea de avarie: fișierul de întrebări lipsește sau e nefolosibil.
## Arătăm de ce pe ecran (nu doar în consolă) și raportăm eșec, ca lupta
## să continue în loc să aștepte la nesfârșit un semnal care nu mai vine.
func _fara_intrebari() -> void:
	push_error("Trivia: nicio intrebare disponibila. Verifica %s" % CALE_INTREBARI)
	raspuns_dat = true
	set_process(false)
	_scrie_context("")
	eticheta_categorie.text = "EROARE"
	bara_timp.visible = false
	eticheta_intrebare.text = "Nu am putut incarca intrebarile.\n%s" % CALE_INTREBARI
	for buton: Button in butoane:
		buton.text = "—"
		buton.disabled = true
	await get_tree().create_timer(PAUZA_FEEDBACK).timeout
	rezolvat.emit(false)


## `_process` e chemată de Godot la FIECARE cadru (~60 pe secundă).
## `delta` = câte secunde au trecut de la cadrul precedent.
## Scădem delta, nu 1/60 — așa cronometrul e corect și dacă jocul încetinește.
func _process(delta: float) -> void:
	timp_ramas -= delta
	if timp_ramas <= 0.0:
		timp_ramas = 0.0
		actualizeaza_cronometru()
		_termina(false, -1)   # -1 = „n-a ales nimeni", adică timeout
		return
	actualizeaza_cronometru()


func actualizeaza_cronometru() -> void:
	bara_timp.value = timp_ramas
	# Cifra („9.7 s") a fost scoasă intenționat. Se schimba de 60 de ori pe
	# secundă chiar lângă întrebare, iar ochiul se duce automat la ce se mișcă.
	# Bara spune același lucru — cât a mai rămas — dar o spune periferic, fără
	# să-ți ceară să citești. Presiunea se simte, nu se numără.
	if timp_ramas <= PRAG_URGENTA:
		bara_timp.modulate = CULOARE_URGENTA
	else:
		bara_timp.modulate = CULOARE_CALM


## ── FULGERUL DE VERDICT ────────────────────────────────────────
## Pregătește șanțul barei de timp pentru fulgerul de timp expirat.
## Chemată o dată, în `_ready()`.
##
## `duplicate()` face o COPIE a stilului, numai pentru scena asta. Fără ea am
## anima chiar resursa din temă — iar o resursă în Godot e PARTAJATĂ: culoarea
## ar rămâne lipită de ea, și la întrebarea următoare (sau în cealaltă
## disciplină) bara ar porni deja roșie. Regula generală, bună de ținut minte:
## dacă animezi o resursă, animezi o copie a ei.
func _pregateste_bara() -> void:
	var stil := bara_timp.get_theme_stylebox("background")
	# Plasă de siguranță: dacă bara ajunge cândva să aibă alt fel de stil (o
	# textură, de pildă), nu mai avem ce colora — dar puzzle-ul merge mai
	# departe fără fulgerul de timp, în loc să crape.
	if not (stil is StyleBoxFlat):
		push_warning("Puzzle: santul barei de timp nu e StyleBoxFlat — fulgerul de timp expirat e dezactivat.")
		return
	stil_bara = stil.duplicate()
	# „override" = stilul ăsta bate tema, dar doar pentru nodul ăsta.
	bara_timp.add_theme_stylebox_override("background", stil_bara)
	culoare_sant_repaus = stil_bara.bg_color


## TIMP EXPIRAT: șanțul barei se aprinde roșu și se stinge înapoi.
## SINGURUL lucru animat din tot feedbackul, și singurul care nu rămâne aprins.
## Regula după care s-a păstrat: butoanele ARATĂ ceva de citit (care e răspunsul
## corect), iar ce se citește stă nemișcat; bara doar ANUNȚĂ un eveniment care a
## trecut („ți-a expirat timpul"), iar un eveniment are voie să treacă și el.
##
## Curba: TRANS_SINE + EASE_IN_OUT pentru tot drumul — pleacă încet, trece prin
## mijloc, se așază încet. EASE_OUT (curba panoului care alunecă) ar arunca
## aproape toată schimbarea în prima treime: potrivit pentru un obiect care
## AJUNGE undeva, nepotrivit pentru o culoare care se TRANSFORMĂ.
func _fulgera_bara_expirata() -> void:
	# SUNETUL, prima linie din funcție — și anume DEASUPRA plasei de siguranță
	# de mai jos. Dacă tema n-ar da vreodată un StyleBoxFlat, bara ar rămâne
	# fără fulger, dar timpul tot ți-a expirat și tot trebuie să afli: un
	# `return` pus înaintea lui ar lega tăcerea de o problemă de temă.
	#
	# E ACELAȘI sunet ca la răspunsul greșit, fiindcă e același rezultat — ai
	# pierdut treapta. Un al treilea sunet, numai pentru timp expirat, ar cere
	# jucătorului să învețe încă un cuvânt fără să-i spună nimic nou.
	Sunet.reda(Sunet.Efect.GRESIT)

	if stil_bara == null:
		return
	# `modulate` al barei e roșul de urgență de la ultimul cadru. Îl punem pe
	# alb ca să vezi FIX culoarea pe care o animăm mai jos — altfel șanțul ar
	# apărea înmulțit cu el, adică mai închis decât am cerut.
	bara_timp.modulate = Color.WHITE

	tween_bara = create_tween()
	tween_bara.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_bara.tween_property(
		stil_bara, "bg_color", CULOARE_BARA_EXPIRATA, DURATA_APRINDERE_VERDICT
	)
	# Pauza e un pas separat, deci se așază între celelalte două:
	# aprinde — stă — se stinge.
	tween_bara.tween_interval(PAUZA_VERDICT)
	tween_bara.tween_property(
		stil_bara, "bg_color", culoare_sant_repaus, DURATA_REVENIRE_VERDICT
	)


## Chemată de oricare dintre cele 4 butoane; `index` vine din .bind().
func _pe_varianta_aleasa(index: int) -> void:
	if raspuns_dat:
		return
	_termina(index == indice_corect, index)


## TIMPUL 3 — aprinderea răspunsului: fondul urcă, rama apare.
## Singurul loc din scenă care spune cine a avut dreptate, și singurul care
## atinge `tween_raspuns` / `stil_contur`. Dacă vrei alt efect de verdict, aici
## îl schimbi — `_termina` nu știe decât să-l ceară.
##
## Ce e un tween: un mic robot care schimbă o proprietate în timp, singur, cadru
## cu cadru, fără să blocheze jocul. Îi spui „du `modulate` până la verde în
## 0,28 s" și se ocupă de restul.
func _aprinde_raspunsul(ales: int, succes: bool) -> void:
	# SUNETUL, în același cadru cu tween-ul de mai jos. Asta e TOATĂ
	# sincronizarea: culoarea și sunetul pleacă din aceeași funcție, deci din
	# aceeași bătaie a jocului — nu e nimic de potrivit cu mâna, și nici nu se
	# poate desincroniza mai târziu. Regula de ținut minte: dacă muți vreodată
	# momentul verdictului, muți funcția asta întreagă, iar sunetul vine cu ea.
	#
	# DE CE AICI ȘI NU LA `verdict.emit()`, în cadrul clickului: un sunet care
	# sună altfel la bine decât la rău ESTE un verdict. Pus în clipa clickului,
	# ți-ar spune rezultatul înaintea butoanelor și ar goli de sens exact pauza
	# de suspans pe care `_termina` o construiește între cele două momente.
	#
	# EXCEPȚIA, `ales < 0` (timp expirat): verdictul a fost deja dat, cu tot cu
	# sunet, de fulgerul barei — acolo nu e niciun suspans de păstrat, fiindcă
	# n-ai pariat nimic. Verdele care se aprinde acum doar ARATĂ răspunsul bun;
	# un al doilea „greșit" peste el ar anunța a doua oară aceeași pierdere.
	if ales >= 0:
		Sunet.reda(Sunet.Efect.CORECT if succes else Sunet.Efect.GRESIT)

	if tween_raspuns != null and tween_raspuns.is_valid():
		tween_raspuns.kill()
	tween_raspuns = create_tween()
	# `set_parallel` = tot ce cerem mai jos pornește ÎN ACELAȘI moment, nu la
	# rând. Vrem o singură mișcare din mai multe bucăți; decalajul dintre urcare
	# și așezare îl cerem explicit, cu `set_delay`, nu implicit prin ordine.
	tween_raspuns.set_parallel(true)

	var buton_corect: Button = butoane[indice_corect]

	# 1. FONDUL variantei corecte: de unde e acum (gri, dacă tu l-ai apăsat; alb,
	# dacă nu) spre verdele de vârf, apoi înapoi în verdele final.
	# A doua bucată pleacă exact când se termină prima. Nu-i spunem de la ce
	# culoare să plece: un tween citește valoarea în clipa în care PORNEȘTE el,
	# deci va găsi acolo vârful, oricare ar fi fost punctul de plecare.
	tween_raspuns.tween_property(
		buton_corect, "modulate", CULOARE_BUN_VARF, DURATA_URCARE
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_raspuns.tween_property(
		buton_corect, "modulate", CULOARE_BUN, DURATA_ASEZARE
	).set_delay(DURATA_URCARE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 2. RAMA, pe același buton, crescând în același timp cu fondul.
	# Dacă tema n-ar da un stil pe care să-l putem contura, funcția întoarce
	# `null` și rămânem doar cu fondul — efectul e mai sărac, dar nimic nu crapă.
	stil_contur = _stil_contur_pentru(buton_corect)
	if stil_contur != null:
		tween_raspuns.tween_property(
			stil_contur, "border_color", CULOARE_CONTUR, DURATA_CONTUR
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# 3. GREȘEALA, dacă e cazul: roșul urcă pe butonul tău exact cu aceleași
	# durate ca verdele. Amândouă pornesc în același moment și se opresc în
	# același moment, ca să se citească drept o singură propoziție („nu asta, ci
	# asta"), nu ca două știri separate.
	# Când ai NIMERIT nu e nimic de făcut aici: butonul apăsat și cel corect sunt
	# același buton, deci verdele de mai sus a plecat chiar din griul de
	# așteptare — tocmai de-aia nu-i spunem tween-ului de la ce culoare să plece.
	if not succes and ales >= 0:
		var buton_gresit: Button = butoane[ales]
		tween_raspuns.tween_property(
			buton_gresit, "modulate", CULOARE_RAU_VARF, DURATA_URCARE
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_raspuns.tween_property(
			buton_gresit, "modulate", CULOARE_RAU, DURATA_ASEZARE
		).set_delay(DURATA_URCARE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Pregătește rama unui buton și o întoarce, ca s-o putem anima.
##
## DE CE „disabled" și nu „normal": în clipa asta butoanele sunt deja blocate
## (`_termina` le-a dezactivat), iar Godot desenează pentru un buton blocat
## stilul lui „disabled". Dacă am contura „normal", n-ar apărea nimic pe ecran
## și am căuta ore întregi de ce.
##
## DE CE `duplicate()`: stilurile temei sunt resurse PARTAJATE — același obiect
## e folosit de toate butoanele din joc. Dacă am scrie direct în el, s-ar
## contura toate patru variantele, ba chiar și butoanele din alte scene. Copia
## e a butonului ăstuia, pentru întrebarea asta, și se aruncă la următoarea.
func _stil_contur_pentru(buton: Button) -> StyleBoxFlat:
	var sursa: StyleBox = buton.get_theme_stylebox("disabled")
	if not (sursa is StyleBoxFlat):
		return null   # altă temă, alt fel de stil: renunțăm la ramă, nu la efect

	var stil: StyleBoxFlat = sursa.duplicate()
	stil.set_border_width_all(GROSIME_CONTUR)
	# Rama pleacă TRANSPARENTĂ: există de la primul cadru, dar nu se vede.
	# `Color(CULOARE_CONTUR, 0.0)` = aceeași culoare, cu alfa 0. Tween-ul de
	# afară nu face decât s-o aducă la alfa 1.
	stil.border_color = Color(CULOARE_CONTUR, 0.0)
	buton.add_theme_stylebox_override("disabled", stil)
	return stil


## Singura ieșire din scenă. `ales` = ce a apăsat jucătorul (-1 la timeout).
func _termina(succes: bool, ales: int) -> void:
	raspuns_dat = true
	set_process(false)   # oprim cronometrul IMEDIAT, înainte de orice așteptare

	for buton: Button in butoane:
		buton.disabled = true

	# TIMPUL 1 — CONFIRMAREA, în cadrul clickului. Neutră: butonul apăsat se
	# întunecă, atât. În clipa asta jocul ȘTIE deja dacă ai nimerit, dar nu
	# spune — și tocmai tăcerea lui e efectul cerut.
	if ales >= 0:
		butoane[ales].modulate = CULOARE_ASTEPTARE
	else:
		# TIMP EXPIRAT. N-ai apăsat nimic, deci niciun buton nu poate purta
		# vina — iar verdele singur, apărut de nicăieri, arată exact ca un
		# răspuns bun dat de altcineva. Lipsește tocmai ce s-a întâmplat: ai
		# pierdut prin timp. O spune bara, adică lucrul care s-a terminat.
		# Fulgeră ACUM, nu după suspans: e reacția la un eveniment petrecut
		# chiar acum (s-a scurs timpul), nu răspunsul la un gest de-al tău.
		# La timeout nu e niciun suspans de construit — n-ai pariat nimic.
		_fulgera_bara_expirata()

	# STRIGĂTUL DE VERDICT, chiar aici: în cadrul clickului, ÎNAINTE de pauza de
	# suspans. Azi nu-l ascultă nimeni (vezi comentariul semnalului, sus), dar
	# momentul lui trebuie să rămână ĂSTA — clipa răspunsului. Orice s-ar agăța
	# cândva de el (un sunet, o zguduire) trebuie să cadă peste gestul tău.
	# ATENȚIE când vei agăța ceva aici: un sunet care sună altfel la bine decât
	# la rău ar da răspunsul mai devreme decât îl dau butoanele și ar goli
	# suspansul de sens. Sunetul de „am auzit clickul" e același în ambele
	# cazuri; cel care JUDECĂ se pune la TIMPUL 3, jos, lângă culori.
	verdict.emit(succes)

	# TIMPUL 2 — SUSPANSUL. `create_timer` face un cronometru de unică
	# folosință; `await` pune funcția pe pauză până când el emite `timeout`.
	# Pe ecran nu se schimbă nimic în timpul ăsta — ăsta E efectul.
	#
	# `await` nu blochează jocul: doar funcția asta se suspendă, restul jocului
	# merge mai departe cadru cu cadru. Iar cronometrul întrebării e deja oprit
	# (`set_process(false)`, sus), deci pauza nu-ți mănâncă din timpul de
	# gândire al întrebării următoare.
	await get_tree().create_timer(PAUZA_SUSPANS).timeout

	# TIMPUL 3 — VERDICTUL. Arătăm mereu care era răspunsul bun.
	# Ton sănătos — înveți ceva și când greșești, nu ești doar pedepsit.
	_aprinde_raspunsul(ales, succes)

	# Tot ACUM, nu mai devreme: seria s-a rupt (răspuns greșit SAU timp expirat),
	# deci marcajul ei nu mai are ce descrie — ștergem o linie care a devenit
	# falsă. Rămâne o regulă neutră: scena nu știe ce e un combo, șterge doar un
	# text pe care lupta i l-a dat.
	#
	# DE CE AICI ȘI NU SUS, în cadrul clickului: linia care dispare e ea însăși
	# un verdict. Dacă s-ar stinge pe loc, ai afla din ea că ai greșit înainte ca
	# butoanele să-ți spună — iar suspansul de mai sus ar fi fost degeaba. Regula
	# generală, dacă mai adaugi ceva pe ecran: NIMIC din ce se schimbă între
	# TIMPUL 1 și TIMPUL 3 nu are voie să depindă de `succes`.
	if not succes:
		_scrie_context("")

	# ȘI ABIA ACUM începe pauza în care citești răspunsul corect.
	await get_tree().create_timer(PAUZA_CITIRE).timeout

	# ȘI ABIA ACUM strigăm rezultatul. Cine ne-a deschis primește `succes`.
	rezolvat.emit(succes)

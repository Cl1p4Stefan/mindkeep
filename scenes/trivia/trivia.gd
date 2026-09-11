extends Control
## Puzzle de TRIVIA — scenă complet independentă.
##
## Nu știe absolut nimic despre luptă, PV, PA sau inamici. Contractul ei cu
## restul jocului are exact două capete:
##   1. `porneste(nivel)`        — CE PRIMEȘTE (dificultatea)
##   2. semnalul `rezolvat(succes)` — CE RETURNEAZĂ (adevărat/fals)
##
## De ce contează izolarea asta: peste trei sesiuni o să faci Anagrama, iar
## ea va avea EXACT aceeași formă (porneste + rezolvat). Atunci Combat
## Controller-ul nu va trebui schimbat deloc — doar îi dai altă scenă.
## Bonus: poți testa scena singură cu F6, fără să treci prin luptă.

# Semnal = „strigătul" pe care nodul îl scoate când s-a întâmplat ceva.
# Aici e singura noastră cale de ieșire: cine ne-a deschis ne ascultă.
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

# VERDICTUL de după răspuns. Culorile sunt DELIBERAT aceleași cu ale butoanelor
# de răspuns: verdele de pe varianta corectă și roșul de pe cea greșită. Două
# nuanțe apropiate, dar diferite, ar fi arătat ca două informații; identice,
# se citesc ca una singură.
const CULOARE_VERDICT_BUN := Color(0.45, 1, 0.55)
const CULOARE_VERDICT_RAU := Color(1, 0.4, 0.4)

# Fade-ul verdictului. SCURT, nu lent: e informația după care te uiți imediat
# ce ai apăsat. Peste ~0.25 s ar începe să pară că jocul se gândește.
const DURATA_VERDICT := 0.18

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
# Nu mai arată timpul — bara singură face asta. Rămâne doar pentru verdict.
@onready var eticheta_verdict: Label = %VerdictEticheta

# Fade-ul verdictului, ținut ca să-l putem omorî dacă se scrie altul peste el.
var tween_verdict: Tween = null
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
	for index in range(butoane.size()):
		var buton: Button = butoane[index]
		buton.text = variante[index]
		buton.disabled = false
		buton.modulate = Color.WHITE   # ștergem verdele/roșul de la runda trecută

	# maxf() = maximul a două zecimale. Podeaua se aplică AICI, o singură dată,
	# deci nimeni din afară nu poate cere din greșeală o întrebare de 2 secunde.
	var timp_total: float = maxf(TIMP_PE_NIVEL[nivel - 1] - scurtare, TIMP_MINIM)
	timp_ramas = timp_total
	bara_timp.max_value = timp_total
	bara_timp.modulate = Color.WHITE

	# Verdictul de la întrebarea trecută se șterge, dar eticheta rămâne pe loc,
	# goală. Un Label gol tot cere înălțimea unui rând de text — exact ce vrem:
	# locul verdictului e păstrat, deci întrebarea nu sare în jos când apare el.
	_scrie_verdict("", true)

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


## Scrie verdictul și îl aduce pe ecran cu un fade scurt.
##
## De ce fade și nu apariție seacă: textul apare în același cadru în care
## butonul tău se colorează. Două schimbări instantanee în același loc se
## citesc ca o singură tresărire și nu știi la care să te uiți. Fade-ul le
## desparte în timp cu o fracțiune de secundă, cât să înregistrezi întâi
## butonul, apoi cuvântul.
##
## Text gol = doar ștergem (fără fade — n-ai ce vedea apărând).
func _scrie_verdict(text: String, bun: bool) -> void:
	if tween_verdict != null and tween_verdict.is_valid():
		tween_verdict.kill()
	eticheta_verdict.text = text
	eticheta_verdict.modulate = CULOARE_VERDICT_BUN if bun else CULOARE_VERDICT_RAU
	if text == "":
		return
	# `modulate:a` = doar canalul alfa (transparența) din culoare. Tragem de el
	# de la 0 la 1, deci culoarea rămâne cea de mai sus și doar apare.
	eticheta_verdict.modulate.a = 0.0
	tween_verdict = create_tween()
	tween_verdict.tween_property(eticheta_verdict, "modulate:a", 1.0, DURATA_VERDICT)


## Ieșirea de avarie: fișierul de întrebări lipsește sau e nefolosibil.
## Arătăm de ce pe ecran (nu doar în consolă) și raportăm eșec, ca lupta
## să continue în loc să aștepte la nesfârșit un semnal care nu mai vine.
func _fara_intrebari() -> void:
	push_error("Trivia: nicio intrebare disponibila. Verifica %s" % CALE_INTREBARI)
	raspuns_dat = true
	set_process(false)
	_scrie_context("")
	eticheta_categorie.text = "EROARE"
	_scrie_verdict("", true)
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
		bara_timp.modulate = Color(1, 0.35, 0.3)
	else:
		bara_timp.modulate = Color(0.55, 0.85, 1)


## Chemată de oricare dintre cele 4 butoane; `index` vine din .bind().
func _pe_varianta_aleasa(index: int) -> void:
	if raspuns_dat:
		return
	_termina(index == indice_corect, index)


## Singura ieșire din scenă. `ales` = ce a apăsat jucătorul (-1 la timeout).
func _termina(succes: bool, ales: int) -> void:
	raspuns_dat = true
	set_process(false)   # oprim cronometrul IMEDIAT, înainte de orice așteptare

	for buton: Button in butoane:
		buton.disabled = true

	# Feedback: arătăm mereu care era răspunsul bun.
	# Ton sănătos — înveți ceva și când greșești, nu ești doar pedepsit.
	butoane[indice_corect].modulate = Color(0.45, 1, 0.55)
	if not succes and ales >= 0:
		butoane[ales].modulate = Color(1, 0.4, 0.4)

	# Seria s-a rupt (răspuns greșit SAU timp expirat), deci marcajul ei nu mai
	# are ce descrie: dispare pe loc, nu peste 1,8 secunde, când se închide
	# panoul. Rămâne o regulă neutră — ștergem o linie care a devenit falsă,
	# fără să știm ce e un combo.
	if not succes:
		_scrie_context("")

	if succes:
		_scrie_verdict("CORECT", true)
	elif ales < 0:
		_scrie_verdict("TIMPUL A EXPIRAT", false)
	else:
		_scrie_verdict("INCORECT", false)

	# `create_timer` face un cronometru de unică folosință; `await` pune funcția
	# pe pauză până când el emite `timeout`. Scurtă pauză, ca să apuci să vezi.
	await get_tree().create_timer(PAUZA_FEEDBACK).timeout

	# ȘI ABIA ACUM strigăm rezultatul. Cine ne-a deschis primește `succes`.
	rezolvat.emit(succes)

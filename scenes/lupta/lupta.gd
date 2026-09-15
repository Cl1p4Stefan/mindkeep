extends Control
## Scena de luptă — PROTOTIP cu placeholder-e.
## Fără artă, fără puzzle-uri: validăm doar bucla
## „cheltuiesc PA -> lovesc -> încheie tura -> inamicul acționează -> rundă nouă".

# ─────────────────────────────────────────────────────────────
# REGULILE JOCULUI (constante)
# `const` = valoare care NU se schimbă în timpul rulării.
# Le ținem sus, toate la un loc: când vrei să reechilibrezi lupta,
# schimbi un număr aici, nu cauți prin tot codul.
# `:=` înseamnă „deduce tu tipul din valoare" (aici: int).
# ─────────────────────────────────────────────────────────────
const PA_PE_RUNDA := 3          # PA primite la începutul fiecărei runde (nu se reportează)
const COST_OBELISC := 1         # o activare = 1 PA, indiferent câte trepte urmează
const PV_MAX_JUCATOR := 15      # Regele = PV-ul tău
const PV_MAX_INAMIC := 30
const PAUZA_FINAL_TURA := 0.5   # secunde de respiro înainte să atace inamicul
const PAUZA_IMPACT := 0.95      # cât ține lovitura pe ecran, între două trepte de lanț
const DURATA_ANIMATIE_BARA := 0.35   # cât durează o bară să alunece la noua valoare

# PANOUL DE ÎNTREBARE. Lățimea lui e SINGURA cifră care decide cât spațiu mai
# rămâne figurilor: containerul împarte restul în două părți egale. O ținem
# aici, în cod, și nu în scenă, fiindcă acum e și valoarea la care se oprește
# animația de deschidere — o singură sursă de adevăr pentru layout și tween.
const LATIME_PANOU := 500.0
const DURATA_PANOU := 0.55      # cât ține alunecarea figurilor, în ambele sensuri
const DURATA_FADE_PANOU := 0.40 # fade-ul conținutului: puțin mai scurt decât mișcarea
const LINII_JURNAL := 80        # câte linii de istoric ținem în panoul de jurnal

# FULGERUL DE VERDICT NU MAI E AICI. A fost, o vreme: la fiecare răspuns,
# rama și fondul panoului tresăreau verde sau roșu. Suna bine pe hârtie, dar în
# joc semnalul cădea în locul greșit — panoul e mare și îți stă la marginea
# privirii, iar ochiul tău e lipit de butonul pe care tocmai l-ai apăsat.
# O suprafață mare care pulsează periferic nu se citește ca răspuns la gestul
# tău, ci ca un al doilea eveniment, în altă parte a ecranului.
# Acum se colorează VARIANTELE, iar asta e treaba puzzle-ului: butoanele sunt
# ale disciplinei, nu ale luptei (vezi `_termina` în trivia.gd / logica.gd).
# Lupta a rămas cu un panou care doar se deschide și se închide — și cu
# regula generală: cine deține nodul, îl și animează.

# Indicatorul de PA: cercuri care se sting, nu cifre.
const MARIME_PUNCT_PA := Vector2(14, 14)
const CULOARE_PA_PLIN := Color(0.95, 0.84, 0.5)
const CULOARE_PA_GOL := Color(0.2, 0.2, 0.24)
# Culorile intenției: normală, și cea de alarmă pentru lovitura devastatoare.
const CULOARE_INTENTIE := Color(0.96, 0.6, 0.5)
const CULOARE_INTENTIE_GREA := Color(1, 0.42, 0.3)
# Culorile titlului din panoul de verdict. Aurul e deja limbajul lucrurilor
# câștigate în joc (PA plin, ramele de panou); roșul stins al înfrângerii nu e
# roșul de alarmă al intenției inamicului — acela te avertizează că URMEAZĂ
# ceva, ăsta constată ceva ce s-a întâmplat deja. De-aia e desaturat și mai
# închis: un roșu aprins pe un titlu mare țipă, iar tonul jocului nu pedepsește.
const CULOARE_VICTORIE := Color(1, 0.85, 0.45)
const CULOARE_INFRANGERE := Color(0.72, 0.38, 0.38)

# ─────────────────────────────────────────────────────────────
# REGULA DE COST DE OPORTUNITATE
# Amândouă rezolvă aceeași problemă de design: „dacă am 3 PA și 3 piese,
# le apăs pe toate și n-am ales nimic". Dar o rezolvă opus —
# COMBO te răsplătește pentru consecvență și te pedepsește cu blocarea,
# RECARCARE îți ia pur și simplu opțiuni pentru o rundă.
# Comută linia REGULA_OBELISC și joacă o luptă cu fiecare.
# ─────────────────────────────────────────────────────────────
enum RegulaObelisc {
	COMBO,        ## o activare pornește un lanț I→II→III; greșeala îl rupe și blochează Obeliscul
	RECARCARE,    ## o singură întrebare per activare; Obeliscul folosit e blocat runda următoare
}

## COMUTATORUL.
const REGULA_OBELISC := RegulaObelisc.COMBO

const RUNDE_RECARCARE := 1      # (doar pentru RECARCARE) câte runde stă blocat

const NIVEL_MAX := 3            # câte niveluri de DIFICULTATE există (nu câte trepte)
const CIFRE_ROMANE := ["I", "II", "III"]

# Daunele fiecărei TREPTE, aplicate imediat ce ai răspuns corect la ea.
# Lista acoperă primele 3 trepte; de la a 4-a încolo rămâne ultima valoare.
# Lanțul nu se mai termină de la sine — deci daunele NU mai pot crește la
# nesfârșit, altfel treapta 12 ar decide singură lupta. Cresc scurt, apoi
# se așează: răsplata pentru un lanț lung vine din LUNGIME, nu din inflație.
const DAUNE_PE_TREAPTA := [1, 2, 3]

# La fiecare a 5-a treaptă, daunele se dublează. E un obiectiv intermediar
# vizibil: la treapta 4 știi deja că următoarea valorează dublu, deci ai un
# motiv concret să mai riști o întrebare.
const TREAPTA_CRITICA := 5
const MULTIPLICATOR_CRITIC := 2

# Ce SCRIE pe marcajul care fulgeră lângă combo la o treaptă critică.
# Cuvântul trăiește aici, nu în disciplină: „critic" e vocabular de luptă, iar
# Trivia și Logica primesc doar un String pe care îl aprind o clipă. Fără el,
# lovitura dublă s-ar vedea doar în bara inamicului — adică ai vedea EFECTUL
# fără să afli CAUZA.
const TEXT_CRITIC := "CRITIC!"

# De la al câtelea răspuns corect la rând se arată indicatorul de combo.
# 2, nu 1: un „×1" nu e un combo, e doar un răspuns corect — l-ai vedea la
# fiecare întrebare și ar înceta să însemne ceva. Indicatorul apare abia
# când ai făcut ceva ce se poate PIERDE.
const COMBO_MINIM_AFISAT := 2

# ─────────────────────────────────────────────────────────────
# ARHETIPURI DE INAMIC
# `enum` = o listă de nume pentru niște numere. În loc să scrii prin cod
# „if tip_inamic == 0", scrii „if tip_inamic == Arhetip.GRABNIC" — se citește
# singur și nu poți greși cifra.
#
# Ăsta e primul pas mic spre generatorul de inamici de la pasul 11: fiecare
# arhetip e un COMPORTAMENT, iar lupta doar întreabă „ce faci în tura ta?".
# ─────────────────────────────────────────────────────────────
enum Arhetip {
	ATAC_CONSTANT,   ## lovește în fiecare tură, puțin — presiune constantă
	GRABNIC,         ## încarcă un ceas câteva runde, apoi lovește devastator
}

## COMUTATORUL. Schimbă linia asta ca să testezi celălalt comportament.
const ARHETIP_INAMIC := Arhetip.ATAC_CONSTANT

# FIȘA fiecărui arhetip. E deliberat un tabel, nu niște constante separate:
# cardul de inamic se construiește CITIND de aici, deci un câmp nou (ex. „citat",
# „recompensa", „slabiciune") înseamnă o cheie în plus aici și un rând în
# `date_card_inamic()` — niciun cod nou de afișare.
#
# „factiune" și „arhetip" sunt DELIBERAT câmpuri separate, deși acum arată la
# fel de inerte. Arhetipul e regula de comportament — el va fi ales de
# generatorul de inamici (pasul 11) și el decide ce face inamicul în tură.
# Facțiunea e apartenența tematică: nu are niciun efect mecanic azi, dar e
# cârligul pentru zone de hartă și pentru echipament anti-facțiune. Dacă le-am
# fi ținut într-un singur câmp, despărțirea lor mai târziu ar fi însemnat
# rescris fiecare inamic.
const DATE_ARHETIP := {
	Arhetip.ATAC_CONSTANT: {
		"nume": "CAVALERUL STERS",
		"factiune": "Cei Stersi",
		"arhetip": "Atac constant",
		"descriere": "A avut un nume, un blazon si un juramant; Stergerea i le-a luat pe toate trei si a lasat armura sa mearga mai departe. Nu te uraste si nu te vede — a ramas cu un singur gest, si ti-l da tie.",
	},
	Arhetip.GRABNIC: {
		"nume": "GRABNICUL",
		"factiune": "Ecourile",
		"arhetip": "Grabnic",
		"descriere": "Nu se grabeste sa loveasca — se grabeste sa termine. Isi incarca lovitura cateva runde la vedere, apoi o descarca dintr-o data.",
	},
}

# Listele astea sunt goale intentionat. Sunt cârligele pentru pasul 11
# (generatorul de inamici): cand un inamic va primi „+50% PV" sau
# „vulnerabil la Ordine", modificatorii ajung aici si apar automat in card.
const MODIFICATORI_INAMIC: Array[String] = []
const VULNERABILITATI_INAMIC: Array[String] = []
const REZISTENTE_INAMIC: Array[String] = []

const DAUNE_ATAC_CONSTANT := 3   # cât lovește ATAC_CONSTANT, în fiecare tură
const CEAS_MAX := 3              # în câte runde se umple ceasul lui GRABNIC
const DAUNE_ATAC_GRABNIC := 8    # cât lovește GRABNIC când ceasul e plin

# `preload` încarcă scena o dată, la compilare, și o ține în memorie.
# Pentru ceva ce deschizi de zeci de ori pe luptă e exact ce vrei —
# `load` ar citi de pe disc de fiecare dată.
## COMUTATORUL DE ARTĂ. true = imaginile din assets/art, false = siluetele
## desenate în cod (`silueta_rege.gd`, `silueta_cavaler.gd`).
##
## Ambele variante trăiesc în scenă, una peste alta: cea ascunsă nu ocupă
## spațiu în container, deci schimbarea e curată în ambele sensuri.
## Le-am lăsat pe amândouă ca să poți compara — un `false` aici și repornești.
## Când te-ai hotărât, ștergi nodurile „...Silueta" și scripturile lor.
const FOLOSESTE_IMAGINI := true

const SCENA_TRIVIA := preload("res://scenes/trivia/trivia.tscn")
const SCENA_LOGICA := preload("res://scenes/logica/logica.tscn")
const SCENA_CUVINTE := preload("res://scenes/cuvinte/cuvinte.tscn")

# Datele celor 3 Obeliscuri, ca tabel.
# Un Array de Dictionary = cea mai simplă „bază de date" din GDScript.
# Avantajul: ca să adaugi al 4-lea Obelisc, adaugi o linie aici —
# nu scrii cod nou. Logica de mai jos merge pe orice număr de intrări.
# Sub COMBO, nivelul nu mai vine de aici: fiecare lanț pornește de la treapta 1
# și urcă singur. Câmpul „nivel" rămâne folosit doar de regula RECARCARE.
#
# „scena" e disciplina propriu-zisă. Toate scenele de puzzle au același contract
# (`porneste`, `arata_stare`, semnalul `rezolvat`), deci lupta le tratează la
# fel — nu știe și n-o interesează ce fel de puzzle e înăuntru. Ca să dai altă
# disciplină unui Obelisc, schimbi scena de pe linia lui. Atât.
# Din sesiunea în care a apărut `puzzle.gd`, toate trei au scena lor: fiecare
# moștenește aceeași bază (`scenes/puzzle/puzzle.tscn`) și schimbă doar de unde
# ia întrebările. De-aia a treia disciplină n-a costat nicio linie schimbată
# aici, în afară de numele scenei de pe rândul ei.
#
# „piesa" și „culoare" sunt înfățișarea Obeliscului, și stau AICI, nu în scenă.
# Înainte, culoarea trăia în `modulate`-ul butonului din editor și era citită de
# cod la pornire — adică identitatea unei discipline era împărțită între un tabel
# și un câmp dintr-un panou de Inspector. Un Obelisc nou însemna două locuri de
# atins și unul de uitat. Acum toată disciplina încape pe un rând.
#
# „imagine" e portofița de artă: gol = folosește piesa desenată (`piesa`), o cale
# = arată PNG-ul. Fișierul lipsă NU e o eroare — butonul se întoarce la desen și
# scrie un avertisment. Așa calea poate sta scrisă aici dinainte să existe arta,
# iar „piesa" rămâne plasa de siguranță: ștergi PNG-ul, jocul merge mai departe.
# CULORILE DISCIPLINELOR. Fiecare e folosită în patru locuri de pe butonul ei —
# bordura, numele, halo-ul și acum și piesa de șah — iar de aici se schimbă toate
# patru deodată. De-aia sunt constante cu nume și nu numere scrise în tabel: o
# nuanță ajustată într-un singur loc nu poate ieși pe jumătate.
#
# Imaginile de pe disc rămân GRI — culoarea se pune la desenare, cu `modulate`
# (vezi `obelisc.gd`). Așa o schimbare de nuanță e o cifră aici, nu un drum înapoi
# prin generatorul de imagini.
const CULOARE_MEMORIE := Color(0.60, 0.85, 1.00)   # albastru
const CULOARE_LOGICA := Color(0.70, 1.00, 0.60)    # verde
const CULOARE_CUVINTE := Color(1.00, 0.85, 0.55)   # auriu

const OBELISCURI := [
	{
		"disciplina": "Memorie", "piesa": GlifaSah.Piesa.PION,
		"imagine": "res://assets/art/pion_sah.png",
		"culoare": CULOARE_MEMORIE, "nivel": 1, "scena": SCENA_TRIVIA,
	},
	{
		"disciplina": "Logica", "piesa": GlifaSah.Piesa.CAL,
		"imagine": "res://assets/art/cal_sah.png",
		"culoare": CULOARE_LOGICA, "nivel": 1, "scena": SCENA_LOGICA,
	},
	{
		"disciplina": "Cuvinte", "piesa": GlifaSah.Piesa.NEBUN,
		"imagine": "res://assets/art/nebun_sah.png",
		"culoare": CULOARE_CUVINTE, "nivel": 1, "scena": SCENA_CUVINTE,
	},
]

# ─────────────────────────────────────────────────────────────
# STAREA LUPTEI (variabile)
# `var` = se schimbă în timpul jocului. Astea + jurnalul sunt TOATĂ
# starea luptei — exact ce va trebui, mai târziu, salvat în JSON.
# ─────────────────────────────────────────────────────────────
var runda := 1
var pa := 0
var pv_jucator := PV_MAX_JUCATOR
var pv_inamic := PV_MAX_INAMIC
var ceas_inamic := 0
var lupta_terminata := false
var puzzle_activ := false   # cât timp e deschis un puzzle, lupta e „înghețată"
var tura_se_incheie := false   # în pauza dintre ultima acțiune și atacul inamicului
var jurnal: Array[String] = []

# RECĂRCAREA. Câte o intrare per Obelisc: numărul rundei din care redevine
# folosibil. 0 = liber acum.
# De ce ținem minte o RUNDĂ, și nu un contor pe care-l scădem în fiecare rundă:
# un contor trebuie scăzut la momentul potrivit, iar dacă îl scazi cu o linie
# mai sus sau mai jos decât trebuie, obținem un bug de o rundă, greu de văzut.
# „Din ce rundă e liber" e un adevăr absolut — nu depinde de ordinea codului.
var disponibil_din: Array[int] = []

# LANȚUL ÎN CURS. Cât a acumulat lanțul de până acum — folosit în textul
# afișat pe ecranul de puzzle și în mesajele din jurnal.
# (Nu mai ținem „ce Obelisc" și „ce treaptă": ecranul de luptă e complet
# acoperit în timpul unui lanț, deci n-avea cine să le citească.)
var lant_daune := 0

# Câte răspunsuri corecte la rând ai dat în lanțul curent. E DIFERIT de
# treaptă: treapta e întrebarea la care ești ACUM (deschisă, încă fără
# răspuns), pe când asta numără doar ce ai câștigat deja. La întrebarea a
# treia, treapta e 3 dar combo-ul e 2 — și 2 e cifra corectă de arătat,
# fiindcă e cea pe care o pierzi dacă greșești.
var combo_corecte := 0

# Punctele de PA, construite din cod în `_ready()`.
# Ținem separat și stilurile: culoarea unui cerc se schimbă prin stil,
# nu direct pe nod.
var puncte_pa: Array[Panel] = []
var stiluri_pa: Array[StyleBoxFlat] = []

# Animația în curs a fiecărei bare. Ținem minte una per bară ca s-o putem
# OPRI dacă vine o valoare nouă înainte să se termine cea veche — altfel
# două animații ar trage de aceeași proprietate în direcții diferite.
var tweens_bare := {}

# Animația panoului de întrebare. Una singură: dacă închizi înainte să se fi
# terminat deschiderea, o omorâm pe cea veche și pornim de unde a rămas.
var tween_panou: Tween = null

# CE VREM să facă panoul, nu ce face el chiar acum. Nu e același lucru:
# `zona_puzzle.visible` rămâne true tot timpul închiderii animate (altfel
# figurile ar sări la loc instantaneu), deci nu poate răspunde la întrebarea
# „e panoul deschis?". Dacă apeși un Obelisc în cele 0,55 s de închidere,
# `visible` zice „da, e deschis" — și deschiderea nouă nu s-ar mai face,
# iar închiderea în curs ar continua peste întrebarea abia apărută.
var panou_deschis := false

# ─────────────────────────────────────────────────────────────
# REFERINȚE CĂTRE NODURI
# `@onready` = „ia nodul ăsta în momentul în care scena e gata".
# Fără @onready, codul ar rula înainte ca nodurile să existe → eroare.
# `%Nume` funcționează pentru nodurile marcate „Access as Unique Name"
# în editor (bifa % din arborele scenei). Avantaj față de $Cale/Lunga:
# dacă muți nodul în altă parte a arborelui, codul NU se strică.
# ─────────────────────────────────────────────────────────────
@onready var eticheta_runda: Label = %Runda
@onready var buton_inamic: Button = %InamicNume
@onready var bara_pv_inamic: ProgressBar = %InamicBaraPV
@onready var eticheta_intentie: Label = %InamicIntentie
@onready var iconita_sabie: Control = %IconitaSabie
@onready var bara_ceas: ProgressBar = %InamicBaraCeas
@onready var eticheta_pv_jucator: Label = %JucatorPV
@onready var bara_pv_jucator: ProgressBar = %JucatorBaraPV
@onready var rand_pa: HBoxContainer = %PAPuncte
@onready var buton_incheie_tura: Button = %IncheieTura
# Jurnalul nu mai stă pe ecranul de luptă: trăiește într-un panou separat,
# deschis din butonul mic din colțul dreapta-sus.
@onready var buton_jurnal: Button = %ButonJurnal
@onready var panou_jurnal: Control = %JurnalPanou
@onready var eticheta_jurnal: Label = %JurnalText
@onready var derulare_jurnal: ScrollContainer = %Derulare
@onready var buton_inchide_jurnal: Button = %ButonInchide
# Cardul de inamic: titlu, descriere și rândurile generate din date.
@onready var card_inamic: Control = %CardInamic
@onready var card_titlu: Label = %CardTitlu
@onready var card_descriere: Label = %CardDescriere
@onready var card_randuri: VBoxContainer = %CardRanduri
@onready var buton_inchide_card: Button = %CardInchide
# Voalul e dreptunghiul intunecat din spatele panoului. E si suprafata
# de "click in afara": tot ce nu e panoul, e el.
@onready var voal_card: ColorRect = %VoalCard
# Cele două variante de figuri, în perechi: desenată și imagine.
# Lupta nu le atinge altfel — doar decide care se vede.
# Învelișurile care clatină figura la lovitură. Ele stau în container;
# figura (siluetă sau imagine) atârnă înăuntru, unde n-o mișcă nimeni.
@onready var figura_jucator: Control = $Margini/Coloana/Arena/ZonaJucator/FiguraJucator
@onready var figura_inamic: Control = $Margini/Coloana/Arena/ZonaInamic/FiguraInamic
# Panoul in care se deschide intrebarea, intre cele doua figuri.
@onready var zona_puzzle: PanelContainer = %ZonaPuzzle
# Ecranul de verdict. UNUL singur, pentru amandoua finalurile: victoria si
# infrangerea nu se deosebesc prin structura, ci prin cuvinte si culoare.
# Doua panouri identice in scena ar insemna ca orice schimbare de forma
# (o margine, un buton nou, o animatie de intrare) se face de doua ori — si
# a doua oara se uita.
@onready var panou_verdict: Control = %PanouVerdict
@onready var verdict_titlu: Label = %VerdictTitlu
@onready var verdict_text: Label = %VerdictText
@onready var buton_verdict: Button = %VerdictButon
@onready var figuri_desenate: Array[Control] = [%JucatorSilueta, %InamicSilueta, %PortretInamic]
@onready var figuri_imagini: Array[Control] = [%JucatorImagine, %InamicImagine, %PortretImagine]
# Array simplu cu cele 3 butoane, ca să le putem trata în buclă.
@onready var butoane_obelisc := [%Obelisc1, %Obelisc2, %Obelisc3]


# `_ready()` e chemată automat de Godot o singură dată, când scena a intrat
# în joc și toate nodurile există. Aici punem tot ce se face o dată.
func _ready() -> void:
	# Configurăm butoanele DIN COD, pe baza tabelului OBELISCURI de sus.
	# `range(...)` ne dă indicii 0, 1, 2 — avem nevoie de index, nu doar de buton,
	# ca să știm mai târziu CARE Obelisc a fost apăsat.
	#
	# Ce ține de IDENTITATEA Obeliscului (nume, piesă, culoare) se pune o singură
	# dată, aici: nu se schimbă niciodată în timpul luptei. Ce ține de STAREA lui
	# (blocat, fără PA) merge prin `seteaza_stare()`, din `actualizeaza_ui()`, care
	# rulează de zeci de ori pe rundă.
	for index in range(butoane_obelisc.size()):
		var buton: Obelisc = butoane_obelisc[index]
		var date: Dictionary = OBELISCURI[index]
		buton.configureaza(
			date["disciplina"], date["piesa"], date["culoare"], date["imagine"]
		)
		# SEMNALE: „pressed" e semnalul emis de Button la click.
		# .connect(functie) = „când se emite, cheamă funcția asta".
		# .bind(index) = „și trimite-i index-ul ca argument".
		# Așa scriem O SINGURĂ funcție pentru toate cele 3 butoane.
		buton.pressed.connect(_pe_obelisc_apasat.bind(index))

	buton_incheie_tura.pressed.connect(_pe_incheie_tura_apasat)
	buton_jurnal.pressed.connect(_pe_jurnal_apasat)
	buton_inchide_jurnal.pressed.connect(_pe_inchide_jurnal_apasat)
	buton_inamic.pressed.connect(_pe_card_inamic_apasat)
	buton_inchide_card.pressed.connect(_pe_inchide_card_apasat)
	# "gui_input" e semnalul brut de mouse/tastatura primit de un Control.
	# Voalul nu e buton, deci nu are "pressed" — ascultam direct evenimentul.
	voal_card.gui_input.connect(_pe_voal_card_apasat)
	buton_verdict.pressed.connect(_pe_verdict_apasat)
	panou_jurnal.visible = false
	card_inamic.visible = false
	panou_verdict.visible = false
	ascunde_panou_acum()

	# Se vede un singur set; celălalt rămâne în scenă, ascuns.
	for figura in figuri_desenate:
		figura.visible = not FOLOSESTE_IMAGINI
	for figura in figuri_imagini:
		figura.visible = FOLOSESTE_IMAGINI

	# Pregătim barele o singură dată, din constante — ca să nu existe
	# două surse de adevăr: una în editor, alta în cod.
	bara_pv_inamic.max_value = PV_MAX_INAMIC
	bara_pv_jucator.max_value = PV_MAX_JUCATOR
	bara_ceas.max_value = CEAS_MAX

	# Punctele de PA le construim DIN COD, câte unul per PA disponibil.
	# Dacă mâine PA_PE_RUNDA devine 4, apar patru puncte fără să atingi scena.
	# (Iar când adaugi Regina, care costă 2 PA, se vor stinge două deodată —
	# tocmai ăsta e avantajul punctelor față de o cifră: vezi cât te costă.)
	for i in range(PA_PE_RUNDA):
		# Un `ColorRect` nu poate desena decât dreptunghiuri. Pentru cercuri
		# folosim un `Panel` cu un `StyleBoxFlat` a cărui rază de colț e
		# jumătate din latură — un pătrat cu colțurile rotunjite complet
		# ESTE un cerc.
		var stil := StyleBoxFlat.new()
		stil.bg_color = CULOARE_PA_PLIN
		var raza := int(MARIME_PUNCT_PA.x / 2.0)
		stil.corner_radius_top_left = raza
		stil.corner_radius_top_right = raza
		stil.corner_radius_bottom_left = raza
		stil.corner_radius_bottom_right = raza

		var punct := Panel.new()
		punct.custom_minimum_size = MARIME_PUNCT_PA
		# Fiecare cerc are stilul LUI: altfel toate trei ar împărți același
		# obiect și s-ar aprinde/stinge împreună.
		punct.add_theme_stylebox_override("panel", stil)

		rand_pa.add_child(punct)
		puncte_pa.append(punct)
		stiluri_pa.append(stil)

	# `resize` face lista exact cât trebuie și o umple cu 0 (= liber).
	# O derivăm din tabelul OBELISCURI, deci un al 4-lea Obelisc primește
	# automat propria recărcare, fără să ne amintim să adăugăm un zero aici.
	disponibil_din.resize(OBELISCURI.size())

	# `Muzica` e autoload-ul din autoload/muzica.gd — există global, nu trebuie
	# creat sau căutat. Dacă piesa cântă deja (ai revenit din altă scenă),
	# apelul nu face nimic, deci nu repornește melodia de la zero.
	Muzica.reda(Muzica.Piesa.LUPTA)

	scrie_in_jurnal("Lupta incepe.")
	incepe_runda()


# ─────────────────────────────────────────────────────────────
# BUCLA DE RUNDĂ
# ─────────────────────────────────────────────────────────────

## Începutul turei TALE: primești PA proaspăt.
func incepe_runda() -> void:
	pa = PA_PE_RUNDA   # PA nu se reportează — pur și simplu suprascriem
	tura_se_incheie = false
	scrie_in_jurnal("--- Runda %d: ai %d PA. ---" % [runda, pa])
	actualizeaza_ui()


## Chemată când apeși un Obelisc. `index` vine din .bind() de mai sus.
## Un click = 1 PA = UN LANȚ ÎNTREG. Funcția asta doar deschide ușa;
## ce se întâmplă înăuntru e treaba lui ruleaza_lant().
func _pe_obelisc_apasat(index: int) -> void:
	# „Gărzi": ieșim devreme din cazurile în care acțiunea n-are voie să se întâmple.
	# E mai ușor de citit decât un if care înghite tot restul funcției.
	if lupta_terminata or puzzle_activ:
		return
	if e_blocat(index):
		return
	if pa < COST_OBELISC:
		scrie_in_jurnal("Nu mai ai PA. Incheie tura.")
		return

	# PA-ul se cheltuie ACUM, o singură dată, indiferent câte trepte urmează.
	# Asta e ideea centrală a combo-ului: nu cumperi trepte, le CÂȘTIGI.
	pa -= COST_OBELISC

	# Sub RECARCARE, blocarea se plătește pentru ACTIVARE, nu pentru reușită.
	# Sub COMBO nu blocăm nimic aici — blocarea e pedeapsa pentru greșeală
	# și se decide în interiorul lanțului.
	if REGULA_OBELISC == RegulaObelisc.RECARCARE:
		# runda + 1 = runda următoare; + RUNDE_RECARCARE = cât stă blocat.
		disponibil_din[index] = runda + 1 + RUNDE_RECARCARE

	puzzle_activ = true
	# `await`: întâi se deschide panoul, ABIA APOI apare prima întrebare.
	# Vezi `deschide_panou()` pentru de ce contează ordinea.
	await deschide_panou()
	await ruleaza_lant(index)
	inchide_panou()
	puzzle_activ = false
	actualizeaza_ui()

	if lupta_terminata:
		return
	await verifica_final_de_tura()


## LANȚUL: nu are capăt. Merge treaptă după treaptă cât timp răspunzi corect
## și se rupe la prima greșeală sau la primul timeout. Daunele se aplică
## TREAPTĂ CU TREAPTĂ, imediat — ce ai câștigat rămâne câștigat.
##
## `while true` în loc de `for`: lanțul nu mai are o lungime cunoscută
## dinainte. Nu e o buclă infinită — are trei ieșiri (greșeală, inamic mort,
## regula RECARCARE), iar cronometrul care se scurtează garantează că, mai
## devreme sau mai târziu, una dintre ele se întâmplă.
func ruleaza_lant(index: int) -> void:
	var date: Dictionary = OBELISCURI[index]
	var disciplina: String = date["disciplina"]

	lant_daune = 0
	# Lanț nou = combo de la zero. Indicatorul rămâne ascuns până la al
	# doilea răspuns corect, deci prima întrebare pleacă fără el.
	combo_corecte = 0

	var treapta := 0
	while true:
		treapta += 1

		var nivel := nivel_treapta(treapta)
		var critica := e_critica(treapta)

		# Puzzle-ul primește trei lucruri, toate „neutre": ce dificultate, ce
		# text să afișeze deasupra și cu cât să-și scurteze cronometrul.
		# Niciunul nu-i spune ce e un lanț sau o lovitură critică.
		# Indicatorul pleacă cu valoarea DEJA câștigată (adică fără treapta
		# asta, la care încă n-ai răspuns). La prima întrebare e text gol.
		#
		# `critica` NU se mai trimite aici, deși o știm deja. Semnalul de critic
		# aparține momentului în care lovitura CHIAR se întâmplă — adică după
		# răspuns, prin `arata_combo()`. Trimis la deschidere, ar fi colorat
		# întrebarea de dinainte și pe cea de după, iar momentul s-ar fi diluat
		# în două întrebări în loc să tresară într-una.
		var puzzle := creeaza_puzzle(
			date["scena"],
			nivel,
			_text_combo(),
			reducere_timp(treapta)
		)
		# ATENȚIE la ordine: NU ștergem puzzle-ul imediat ce răspunzi.
		# Rămâne pe ecran cât aplicăm daunele, ca să vezi bara lui scăzând.
		var succes: bool = await puzzle.rezolvat

		if not succes:
			# Combo-ul dispare COMPLET, nu scade: e o serie, iar o serie
			# întreruptă nu mai e o serie. Puzzle-ul se șterge oricum imediat,
			# dar ținem contorul curat pentru lanțul următor.
			combo_corecte = 0
			inchide_puzzle(puzzle)
			# LANȚUL S-A RUPT. Daunele deja aplicate RĂMÂN — nu pierzi
			# retroactiv ce ai câștigat corect.
			var mesaj := "%s, treapta %d: gresit. Lantul se rupe" % [disciplina, treapta]
			if lant_daune > 0:
				mesaj += ", pastrezi %d daune" % lant_daune
			if REGULA_OBELISC == RegulaObelisc.COMBO:
				# runda + 1 = liber abia din runda următoare, adică blocat
				# tot restul rundei curente. Exact aceeași variabilă ca
				# Recărcarea — doar durata diferă.
				disponibil_din[index] = runda + 1
				mesaj += ". Obelisc blocat runda asta"
			scrie_in_jurnal(mesaj + ".")
			return

		# ABIA ACUM crește combo-ul: ai răspuns, deci l-ai câștigat.
		# Îl împingem în puzzle-ul care e ÎNCĂ pe ecran, ca să vezi cifra
		# urcând peste răspunsul tău — nu la întrebarea următoare.
		combo_corecte += 1
		# Al doilea argument e marcajul: text gol la o treaptă obișnuită,
		# „CRITIC!" la a 5-a, a 10-a, a 15-a. Puzzle-ul îl aprinde o clipă
		# lângă cifră, exact în cadrul în care bara inamicului scade dublu —
		# așa cauza și efectul se văd în același moment.
		puzzle.arata_combo(_text_combo(), TEXT_CRITIC if critica else "")
		if critica:
			# TUNETUL, în același cadru cu marcajul portocaliu de mai sus.
			# Asta e toată sincronizarea: sunetul și flash-ul pleacă din
			# aceeași linie de cod, deci din aceeași bătaie a jocului — n-ai
			# ce potrivi cu mâna și nu se pot desincroniza mai târziu.
			#
			# DE CE AICI ȘI NU ÎN DISCIPLINĂ: „critic" e vocabular de luptă,
			# exact ca `TEXT_CRITIC`. Trivia și Logica primesc un String pe
			# care îl aprind, fără să afle vreodată ce înseamnă; dacă sunetul
			# ar fi pornit de acolo, fiecare disciplină nouă ar trebui să-și
			# amintească să-l pună. Așa, a treia disciplină îl are pe gratis.
			Sunet.reda(Sunet.Efect.CRITIC)

		# Daunele treptei se aplică IMEDIAT, nu la finalul lanțului.
		var daune := daune_treapta(treapta)
		lant_daune += daune
		# maxi() = maximul a două int-uri. Îl folosim ca PV să nu scadă sub 0.
		pv_inamic = maxi(pv_inamic - daune, 0)
		figura_inamic.loveste()

		if critica:
			scrie_in_jurnal("%s, treapta %d: CRITIC! +%d daune (lant: %d)." % [
				disciplina, treapta, daune, lant_daune
			])
		else:
			scrie_in_jurnal("%s, treapta %d (Nivel %s): corect, +%d daune (lant: %d)." % [
				disciplina, treapta, CIFRE_ROMANE[nivel - 1], daune, lant_daune
			])

		# AICI se vede lovitura. Puzzle-ul e încă pe ecran, iar barele din
		# stânga și din dreapta lui alunecă la valorile noi — de asta panoul
		# nu se închide imediat ce ai răspuns.
		actualizeaza_ui()
		await get_tree().create_timer(PAUZA_IMPACT).timeout
		inchide_puzzle(puzzle)

		if pv_inamic == 0:
			# Panoul dispare INSTANT, nu alunecând. Închiderea animată își are
			# rostul între trepte, unde arată că arena se redeschide — dar sub
			# ecranul de victorie devine o mișcare fără cauză: figurile s-ar
			# lăți spre mijloc timp de 0,55 s în spatele voalului, ca și cum
			# lupta ar continua. Momentul câștigat merită o imagine care stă.
			# (`inchide_panou()` din apelant se retrage singur: panoul e
			# deja ascuns, iar el iese din prima linie.)
			ascunde_panou_acum()
			termina_lupta(true)
			return

		# Sub RECARCARE nu există lanț: o singură întrebare per activare.
		if REGULA_OBELISC != RegulaObelisc.COMBO:
			return


## Marcajul discret de streak, afișat lângă categorie pe ecranul de puzzle.
## Doar „×4" — câte răspunsuri corecte la rând ai dat. NU spunem disciplina
## (o știi, tu ai apăsat-o), nivelul (îl simți din cronometru) sau daunele
## acumulate (le vezi în bara inamicului, care scade sub ochii tăi).
##
## Sub prag întoarcem text GOL, iar eticheta se ascunde de tot — un „×1" la
## fiecare întrebare ar fi zgomot, nu informație.
##
## Îl compunem AICI, în luptă, fiindcă doar lupta știe ce e un lanț.
## Puzzle-ul primește un String și îl afișează — nu-l interpretează.
func _text_combo() -> String:
	if REGULA_OBELISC != RegulaObelisc.COMBO or combo_corecte < COMBO_MINIM_AFISAT:
		return ""
	return "COMBO ×%d" % combo_corecte


## Ce NIVEL DE DIFICULTATE cere o treaptă. Treptele 1-3 urcă I → II → III;
## de la a 4-a încolo rămân la III. Nu inventăm niveluri noi de dificultate —
## presiunea suplimentară vine din cronometru, nu din întrebări imposibile.
func nivel_treapta(treapta: int) -> int:
	return mini(treapta, NIVEL_MAX)


## E treapta asta o lovitură critică? (a 5-a, a 10-a, a 15-a...)
## `%` e restul împărțirii: 10 % 5 == 0, deci treapta 10 e critică.
func e_critica(treapta: int) -> bool:
	return treapta % TREAPTA_CRITICA == 0


## Câte daune dă o treaptă. O singură funcție folosită și de lanț, și de UI —
## deci ce scrie pe ecran e garantat ce se aplică.
func daune_treapta(treapta: int) -> int:
	# Peste lungimea listei, rămânem pe ultima valoare (treapta 7 = ca treapta 3).
	var baza: int = DAUNE_PE_TREAPTA[mini(treapta, DAUNE_PE_TREAPTA.size()) - 1]
	if e_critica(treapta):
		baza *= MULTIPLICATOR_CRITIC
	return baza


## Cu cât se scurtează cronometrul la treapta asta. Prima treaptă primește
## timpul întreg; fiecare treaptă următoare ia câte o secundă.
## Podeaua (cât de scurt poate ajunge) o decide scena de puzzle — e o regulă
## de corectitudine față de jucător, nu una de luptă.
func reducere_timp(treapta: int) -> float:
	return float(treapta - 1)


## „1 dauna" / „3 daune". Româna cere singular la 1, iar textul ăsta apare
## des în jurnal și pe ecranul de puzzle — merită cele două rânduri.
func text_daune(n: int) -> String:
	return "1 dauna" if n == 1 else "%d daune" % n


## Mută o bară către o valoare nouă ALUNECÂND, nu sărind.
## De ce contează: o bară care sare de la 30 la 21 nu se vede — creierul
## înregistrează doar starea nouă. Una care alunecă 0,35 secunde se vede
## MIȘCÂND, și abia atunci percepi „am lovit".
func anima_bara(bara: ProgressBar, valoare: float) -> void:
	if is_equal_approx(bara.value, valoare):
		return   # nimic de animat; altfel am crea zeci de tween-uri degeaba

	# Oprim animația veche a ACESTEI bare, dacă mai rulează una.
	if tweens_bare.has(bara) and tweens_bare[bara] != null and tweens_bare[bara].is_valid():
		tweens_bare[bara].kill()

	# Un Tween e un mic robot care schimbă o proprietate în timp, singur.
	# EASE_OUT = pornește repede și frânează la final — se simte ca un impact,
	# nu ca o mișcare uniformă de lift.
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(bara, "value", valoare, DURATA_ANIMATIE_BARA)
	tweens_bare[bara] = tw


## Mai există vreun Obelisc pe care îl poți folosi acum?
## Nu e același lucru cu „am PA": poți avea 2 PA și toate Obeliscurile blocate.
func mai_ai_ce_face() -> bool:
	if pa < COST_OBELISC:
		return false
	for index in range(OBELISCURI.size()):
		if not e_blocat(index):
			return true
	return false


## Un Obelisc e blocat cât timp runda curentă e mai mică decât runda din care
## redevine disponibil. Aceeași verificare servește ambele reguli — diferă
## doar cine scrie în `disponibil_din` și cu ce durată:
##   COMBO:     runda + 1                     → restul rundei curente
##   RECARCARE: runda + 1 + RUNDE_RECARCARE   → și runda următoare
func e_blocat(index: int) -> bool:
	return runda < disponibil_din[index]


## Chemată după FIECARE puzzle. Dacă nu mai ai PA, tura ta e oricum
## terminată — n-are rost să te punem să apeși un buton ca s-o confirmi.
## Pauza scurtă e ca să apuci să citești ce s-a întâmplat înainte
## să sară inamicul la tine.
func verifica_final_de_tura() -> void:
	if lupta_terminata or mai_ai_ce_face():
		return

	tura_se_incheie = true
	# Rămâi fără PA (sau cu tot ce ai blocat) = combo-ul se stinge, la fel ca
	# la o greșeală. În practică ajungi aici tocmai FIINDCĂ ai greșit — sub
	# COMBO un lanț se rupe doar așa — deci contorul e deja 0. Îl punem
	# oricum: regula e „combo-ul nu supraviețuiește turei tale", și vrem să
	# scrie asta în cod, nu să depindă de un noroc de ordine.
	combo_corecte = 0
	scrie_in_jurnal("Nimic de facut cu %d PA — tura se incheie." % pa)
	actualizeaza_ui()
	await get_tree().create_timer(PAUZA_FINAL_TURA).timeout

	# În jumătatea aia de secundă starea s-ar putea schimba (mai târziu:
	# otravă, efecte întârziate). Verificăm din nou înainte să acționăm.
	if lupta_terminata:
		return
	tura_inamicului()


## Creează puzzle-ul și îl pune pe ecran. NU îl șterge și NU așteaptă —
## de asta se ocupă lanțul, fiindcă el are nevoie ca puzzle-ul să rămână
## vizibil și după răspuns, cât alunecă bara de PV.
## (`await puzzle.rezolvat` și `puzzle.queue_free()` sunt acum în ruleaza_lant.)
##
## `scena` vine din tabelul OBELISCURI. Lupta nu știe CE fel de puzzle e —
## doar că primește un bool înapoi. De-asta, când adaugi Anagrama, aici nu se
## schimbă nimic: pui scena nouă pe linia Obeliscului ei și gata.
func creeaza_puzzle(scena: PackedScene, nivel: int, context := "", scurtare := 0.0) -> Control:
	# `instantiate()` face o COPIE vie a scenei, gata de adăugat în arbore.
	var puzzle := scena.instantiate()
	# O punem ÎN PANOU, nu peste toată lupta. Panoul e un copil al Arenei, deci
	# containerul reîmparte singur lățimea: figurile se strâng spre margini fără
	# ca noi să calculăm vreo poziție.
	zona_puzzle.add_child(puzzle)
	# Semnalul `verdict` al puzzle-ului (răspunsul, strigat pe loc) NU se mai
	# leagă de nimic: reacția vizuală s-a mutat în puzzle, pe variante. Rămâne
	# liber pentru prima nevoie reală a LUPTEI de a ști „chiar acum" — un sunet
	# sau o zguduire a figurii lovite. Dacă îl legi cândva, leagă-l ÎNAINTE de
	# `porneste()`: acolo pornește cronometrul, iar o întrebare cu timpul deja
	# curgând ar putea expira în cadrul următor și ar striga în gol.
	puzzle.porneste(nivel, context, scurtare)
	return puzzle


## Scoate întrebarea la care tocmai ai răspuns. NU închide panoul: între două
## trepte de lanț panoul rămâne deschis și doar conținutul se schimbă. Dacă ar
## închide, ai vedea figurile sărind mari-mici-mari la fiecare răspuns corect.
## Panoul se deschide o dată, la începutul lanțului, și se închide o dată,
## la finalul lui — vezi `deschide_panou()` / `inchide_panou()`.
func inchide_puzzle(puzzle: Control) -> void:
	puzzle.queue_free()


## ─────────────────────────────────────────────────────────────
## ANIMAȚIA PANOULUI
##
## Nu mutăm noi nicio figură. Tragem de O SINGURĂ valoare — lățimea minimă a
## panoului — iar `HBoxContainer` reface împărțirea la fiecare cadru: ce ia
## panoul, pierd figurile, jumătate-jumătate. Așa mărimea ȘI poziția lor se
## animează singure, garantat simetric, fără o poziție calculată de noi.
##
## Curba e EASE_OUT + TRANS_CUBIC: pleacă repede și se așază lin la final.
## Liniar ar arăta mecanic — ochiul citește o oprire bruscă drept „s-a blocat".
##
## SE AȘTEAPTĂ (`await`): funcția se întoarce abia când panoul e la lățimea
## finală. Apelantul creează întrebarea DUPĂ, nu înainte — și ăsta e tot rostul
## lui `await` aici.
##
## De ce: panoul e un container, iar întrebarea din el se reașază la FIECARE
## lățime prin care trece animația. Cu întrebarea înăuntru de la primul cadru,
## vedeai textul rescriindu-se singur — întâi un cuvânt pe rând, revărsat în
## afara panoului, apoi pe trei rânduri, apoi pe două, apoi pe unul. Nu erau
## alte întrebări; era ACEEAȘI întrebare, reașezată de vreo cinci ori în ~80 ms.
## Fade-ul nu ascundea nimic: el se termină în 0,40 s, mișcarea ține 0,55 s,
## deci ultimele reașezări se vedeau la opacitate plină.
##
## Bonus de corectitudine: cronometrul întrebării pornește în `porneste()`.
## Înainte, curgea deja în timpul deschiderii — pierdeai o jumătate de secundă
## dintr-o întrebare pe care încă n-o puteai citi.
func deschide_panou() -> void:
	# ÎNAINTE de gardă, intenționat. La o treaptă nouă din același lanț ieșim
	# pe linia următoare, deci codul de mai jos nu se mai execută — dar muzica
	# TREBUIE să rămână atenuată pe tot lanțul, nu doar la prima întrebare.
	# `atenueaza()` e făcut să suporte chemări repetate: a doua oară nu mișcă
	# nimic, deci muzica nu „respiră" între trepte.
	Muzica.atenueaza()
	if panou_deschis:
		return   # deja deschis (o treaptă nouă în același lanț): nu reanimăm
	panou_deschis = true
	# Pornim de la zero DOAR dacă panoul chiar e închis. Dacă prindem o
	# închidere la mijloc, `porneste_tween_panou()` o omoară și creștem înapoi
	# de la lățimea de acum — fără să sară întâi la 0.
	if not zona_puzzle.visible:
		zona_puzzle.visible = true
		zona_puzzle.custom_minimum_size.x = 0.0
		zona_puzzle.modulate.a = 0.0
	var tween := porneste_tween_panou()
	tween.tween_property(zona_puzzle, "custom_minimum_size:x", LATIME_PANOU, DURATA_PANOU)
	# `parallel()` = „pasul ăsta merge ÎN ACELAȘI TIMP cu cel dinainte",
	# nu după el. Fără el, fade-ul ar începe abia după ce s-a oprit mișcarea.
	tween.parallel().tween_property(zona_puzzle, "modulate:a", 1.0, DURATA_FADE_PANOU)
	# Așteptăm pe un CRONOMETRU, nu pe `tween.finished`. Un tween omorât (o
	# victorie, o resetare) nu-și mai emite niciodată semnalul, iar lupta ar
	# rămâne blocată pentru totdeauna într-un `await`. Cronometrul sună mereu.
	await get_tree().create_timer(DURATA_PANOU).timeout


func inchide_panou() -> void:
	if not zona_puzzle.visible:
		return
	# Muzica urcă ÎN ACELAȘI TIMP cu retragerea panoului, nu după ea. Fade-ul
	# ei (0,3 s) e mai scurt decât mișcarea (0,55 s), deci sunetul e înapoi la
	# normal cam când arena redevine vizibilă — o singură mișcare, nu două.
	Muzica.restabileste()
	panou_deschis = false
	var tween := porneste_tween_panou()
	tween.tween_property(zona_puzzle, "custom_minimum_size:x", 0.0, DURATA_PANOU)
	tween.parallel().tween_property(zona_puzzle, "modulate:a", 0.0, DURATA_FADE_PANOU)
	# Ascunderea vine ABIA la final. Dacă am ascunde acum, containerul ar
	# scoate panoul din calcul instantaneu și figurile ar sări la loc.
	tween.tween_callback(ascunde_panou_acum)


## Panoul dispare fără animație. Îl folosește resetarea luptei: acolo nu
## „închizi" ceva, ci pui totul la starea de start.
func ascunde_panou_acum() -> void:
	# Plasa de siguranță a atenuării. Pe drumul obișnuit `inchide_panou()` a
	# ridicat deja muzica (și a doua chemare nu face nimic), dar există căi
	# care sar peste el: victoria ascunde panoul instant, iar resetarea luptei
	# îl ascunde din starea de start. Fără linia asta, un inamic ucis în
	# mijlocul unui lanț ar lăsa muzica atenuată pentru tot restul partidei.
	Muzica.restabileste()
	if tween_panou != null and tween_panou.is_valid():
		tween_panou.kill()
	panou_deschis = false
	zona_puzzle.visible = false
	zona_puzzle.custom_minimum_size.x = 0.0
	zona_puzzle.modulate.a = 1.0


## Un tween nou, dar întâi îl omorâm pe cel vechi. Fără asta, o închidere
## pornită peste o deschidere neterminată ar lăsa două animații trăgând de
## aceeași proprietate în direcții opuse.
func porneste_tween_panou() -> Tween:
	if tween_panou != null and tween_panou.is_valid():
		tween_panou.kill()
	tween_panou = create_tween()
	tween_panou.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return tween_panou


## Butonul „Încheie tura". Dacă lupta s-a terminat, același buton repornește.
func _pe_incheie_tura_apasat() -> void:
	if puzzle_activ:
		return   # nu poți încheia tura cu un puzzle deschis
	if lupta_terminata:
		# Verificarea asta stă ÎNAINTEA lui `tura_se_incheie`, nu după ea:
		# „lupta s-a terminat" e starea mai tare dintre cele două. O tură
		# care „se încheie" într-o luptă deja încheiată nu mai are ce opri —
		# iar pusă la coadă, verificarea asta lăsa butonul mut exact în cazul
		# în care aveai cea mai mare nevoie de el: după înfrângere.
		reseteaza_lupta()
		return
	if tura_se_incheie:
		return   # tura se încheie deja singură — fără două ture de inamic
	tura_inamicului()


## Tura inamicului. Funcția asta NU mai știe cum atacă inamicul — doar
## întreabă arhetipul. `match` = un lanț de if-uri, dar citibil: pentru
## fiecare arhetip nou adaugi o ramură, fără să atingi restul buclei.
func tura_inamicului() -> void:
	match ARHETIP_INAMIC:
		Arhetip.ATAC_CONSTANT:
			_tura_atac_constant()
		Arhetip.GRABNIC:
			_tura_grabnic()

	# Verificarea morții stă AICI, într-un singur loc, nu în fiecare arhetip.
	# Așa, un arhetip viitor nu poate uita s-o facă.
	if pv_jucator == 0:
		termina_lupta(false)
		return

	runda += 1
	incepe_runda()


## Arhetipul de bază: lovește puțin, dar în fiecare tură. Fără surprize —
## presiunea vine din cronometrul puzzle-ului, nu din inamic.
func _tura_atac_constant() -> void:
	loveste_jucatorul(DAUNE_ATAC_CONSTANT)
	scrie_in_jurnal("Inamicul ataca pentru %d." % DAUNE_ATAC_CONSTANT)


## Arhetipul „Grabnic" — PĂSTRAT, dar inactiv. Ceasul urcă cu 1 pe tură;
## când se umple, lovește tare și o ia de la capăt. Lupta devine o cursă:
## îl dobori la timp, sau încasezi?
func _tura_grabnic() -> void:
	ceas_inamic += 1
	if ceas_inamic >= CEAS_MAX:
		ceas_inamic = 0
		loveste_jucatorul(DAUNE_ATAC_GRABNIC)
		scrie_in_jurnal("CEASUL S-A UMPLUT! Inamicul loveste pentru %d." % DAUNE_ATAC_GRABNIC)
	else:
		scrie_in_jurnal("Inamicul se incarca (%d/%d)." % [ceas_inamic, CEAS_MAX])


## O singură funcție prin care trec TOATE daunele către jucător.
## Mai târziu, scutul se scade într-un singur loc — aici.
func loveste_jucatorul(daune: int) -> void:
	# maxi() = maximul a două int-uri. Îl folosim ca PV să nu scadă sub 0.
	pv_jucator = maxi(pv_jucator - daune, 0)
	figura_jucator.loveste()


func termina_lupta(victorie: bool) -> void:
	lupta_terminata = true

	# MUZICA IESE DE TOT, nu se dă doar mai încet.
	#
	# La întrebări o atenuăm (`Muzica.atenueaza()`), pentru că lupta continuă
	# sub panou și tăcerea ar suna a pană de curent. Aici lupta NU mai continuă,
	# iar muzica de luptă e o promisiune că mai ai ceva de făcut. Ținută sub
	# fanfară, ar contrazice exact mesajul verdictului.
	#
	# În plus, cele două se bat pe același spațiu: fanfara de victorie e tot
	# muzică, cu tonalitate proprie. Două piese diferite în același timp nu sună
	# a „mai multă muzică", sună a greșeală.
	#
	# Stingerea durează 2 s (`Muzica.DURATA_FADE`) și se suprapune peste primele
	# secunde ale verdictului — asta nu e o scăpare, e chiar ce vrei: un
	# încrucișat, nu o tăietură. Muzica se întoarce în `reseteaza_lupta()`.
	Muzica.opreste()

	# `tura_se_incheie` e steagul „sunt în pauza dintre ultima ta acțiune și
	# atacul inamicului". Lupta s-a terminat, deci pauza aia nu mai există — iar
	# dacă steagul rămâne ridicat, codul care îl verifică (`_pe_incheie_tura_apasat`)
	# crede că inamicul e încă pe cale să lovească și refuză să facă orice.
	# Exact ăsta era bugul „butonul «Lupta din nou» nu face nimic după înfrângere":
	# la victorie lupta se încheie în timpul lanțului tău (steagul e jos), dar la
	# înfrângere se încheie CHIAR în tura inamicului, pornită din pauză — deci
	# steagul era sus și nu-l mai cobora nimeni.
	tura_se_incheie = false

	if victorie:
		scrie_in_jurnal("VICTORIE! Inamicul a cazut in runda %d." % runda)
		Sunet.reda_verdict(Sunet.Verdict.VICTORIE)
	else:
		scrie_in_jurnal("SAH MAT. Ai pierdut in runda %d." % runda)
		Sunet.reda_verdict(Sunet.Verdict.INFRANGERE)

	# Sunetul și panoul, în același cadru. `_arata_verdictul()` e o funcție
	# obișnuită, fără `await` — deci nu se așteaptă nimic între apelul de sunet
	# de mai sus și linia asta: verdictul se aude și se vede împreună. Dacă
	# vreodată pui aici o animație de intrare, ține apelul lipit de sunet, ca
	# să nu se desprindă unul de altul.
	_arata_verdictul(victorie)

	buton_incheie_tura.text = "Lupta din nou"
	actualizeaza_ui()


## Ecranul de verdict — ACELAȘI panou pentru amândouă finalurile.
##
## Înfrângerea se termina până acum doar cu un sunet și cu un buton care își
## schimba textul jos, sub restul ecranului. Un final care nu se vede nu se
## simte ca un final: bara ajunge la zero și pare mai degrabă că s-a blocat
## jocul decât că ai pierdut.
##
## De ce UN singur panou, nu două: victoria și înfrângerea au exact aceeași
## FORMĂ — titlu mare, o frază despre ce s-a întâmplat, un buton. Diferă doar
## cuvintele și culoarea. Două panouri în scenă ar însemna că orice schimbare
## de formă (o margine, un buton nou, o animație de intrare) se face de două
## ori — și a doua oară se uită. E aceeași regulă ca la Obeliscuri: un
## contract, mai multe conținuturi.
func _arata_verdictul(victorie: bool) -> void:
	var nume_inamic: String = DATE_ARHETIP[ARHETIP_INAMIC]["nume"]

	if victorie:
		verdict_titlu.text = "VICTORIE"
		verdict_titlu.modulate = CULOARE_VICTORIE
		verdict_text.text = "%s a cazut in runda %d.\nAi incheiat lupta cu %d / %d PV." % [
			nume_inamic, runda, pv_jucator, PV_MAX_JUCATOR
		]
		# „Continua", nu „Lupta din nou": după victorie drumul merge înainte.
		# Când apare harta de expediție, butonul te duce la nodul următor.
		buton_verdict.text = "Continua"
	else:
		verdict_titlu.text = "INFRANGERE"
		verdict_titlu.modulate = CULOARE_INFRANGERE
		# Oglinda textului de victorie: aceeași structură, cealaltă direcție.
		# A doua frază spune cât de aproape ai fost — „mai avea 3 PV" e un motiv
		# să reîncerci, „mai avea 28" spune că trebuie schimbat ceva, nu repetat.
		verdict_text.text = "%s te-a doborat in runda %d.\nMai avea %d / %d PV." % [
			nume_inamic, runda, pv_inamic, PV_MAX_INAMIC
		]
		buton_verdict.text = "Lupta din nou"

	panou_verdict.visible = true
	# Focus pe buton: se poate apăsa și cu Enter/Space, fără să cauți mouse-ul.
	buton_verdict.grab_focus()


## Butonul panoului de verdict — deocamdată reia lupta pe amândouă drumurile,
## fiindcă încă nu există unde să continui. Aici se leagă harta de expediție,
## când ajungem la ea: victoria te întoarce pe hartă, la nodul următor;
## înfrângerea încheie expediția și te trimite în cetate.
func _pe_verdict_apasat() -> void:
	panou_verdict.visible = false
	reseteaza_lupta()


## Readuce starea la valorile de start. Ca să testezi rapid, fără să dai F5.
func reseteaza_lupta() -> void:
	runda = 1
	pv_jucator = PV_MAX_JUCATOR
	pv_inamic = PV_MAX_INAMIC
	ceas_inamic = 0
	lupta_terminata = false
	puzzle_activ = false
	tura_se_incheie = false
	disponibil_din.fill(0)   # toate Obeliscurile, libere din nou
	lant_daune = 0
	combo_corecte = 0
	jurnal.clear()
	panou_verdict.visible = false
	ascunde_panou_acum()

	# Sunetul luptei încheiate se retrage, muzica luptei noi intră în locul lui.
	#
	# Amândouă apelurile sunt sigure oricând, deci nu trebuie să ne întrebăm pe
	# ce drum am ajuns aici: `opreste_verdict()` nu face nimic dacă nu cânta
	# nicio fanfară (reset cerut din butonul de test, fără victorie), iar
	# `Muzica.reda()` nu repornește piesa dacă ea cântă deja.
	#
	# Verdictul se stinge scurt, nu se taie: dacă apeși „Continuă" la o secundă
	# de la victorie, fanfara nu dispare brusc — se retrage în 0,4 s, fix cât
	# muzica de luptă are nevoie ca să se ridice de la tăcere.
	Sunet.opreste_verdict()
	Muzica.reda(Muzica.Piesa.LUPTA)

	buton_incheie_tura.text = "Incheie tura"
	scrie_in_jurnal("Lupta reincepe.")
	incepe_runda()


## Lovește inamicul în tura care urmează?
func inamicul_loveste_acum() -> bool:
	if ARHETIP_INAMIC == Arhetip.GRABNIC:
		return ceas_inamic + 1 >= CEAS_MAX
	return true


## E o lovitură din aia care doare? (deocamdată: doar descărcarea Grabnicului)
func lovitura_grea() -> bool:
	return ARHETIP_INAMIC == Arhetip.GRABNIC and inamicul_loveste_acum()


## Numărul de lângă sabie. Simbolul nu mai e text — e desenat, vezi
## `iconita_sabie.gd`. Cât timp Grabnicul se încarcă, arătăm doar contorul.
func text_intentie() -> String:
	if ARHETIP_INAMIC == Arhetip.GRABNIC and not inamicul_loveste_acum():
		return "%d/%d" % [ceas_inamic, CEAS_MAX]
	if ARHETIP_INAMIC == Arhetip.GRABNIC:
		return str(DAUNE_ATAC_GRABNIC)
	return str(DAUNE_ATAC_CONSTANT)


## Ce face inamicul, într-o frază. Folosită doar în card.
## Rândul „Comportament" din card. Regula generală o spune deja „Arhetip";
## aici scriem doar ce arhetipul NU-ți spune: cifrele exacte și condițiile.
## Dacă textul de aici ajunge să sune ca numele arhetipului, rândul e degeaba.
func text_comportament() -> String:
	match ARHETIP_INAMIC:
		Arhetip.ATAC_CONSTANT:
			return "%d daune in fiecare tura" % DAUNE_ATAC_CONSTANT
		Arhetip.GRABNIC:
			return "Ceasul se umple in %d runde; la %d/%d loveste %d, apoi se reseteaza." % [
				CEAS_MAX, CEAS_MAX, CEAS_MAX, DAUNE_ATAC_GRABNIC
			]
	return "—"


## O listă de etichete, sau o liniuță dacă e goală.
func _lista_sau_liniuta(valori: Array[String]) -> String:
	return "—" if valori.is_empty() else ", ".join(valori)


## CONȚINUTUL CARDULUI, ca listă de rânduri „etichetă → valoare".
## Aici adaugi câmpuri noi: o linie în listă, și cardul le desenează singur.
## Nu atinge nimic din afișare — de asta e o listă de date, nu cod de UI.
func date_card_inamic() -> Array:
	return [
		{"eticheta": "Factiune", "valoare": DATE_ARHETIP[ARHETIP_INAMIC]["factiune"]},
		{"eticheta": "Arhetip", "valoare": DATE_ARHETIP[ARHETIP_INAMIC]["arhetip"]},
		{"eticheta": "Comportament", "valoare": text_comportament()},
		{"eticheta": "Puncte de viata", "valoare": "%d / %d" % [pv_inamic, PV_MAX_INAMIC]},
		#{"eticheta": "Intentia acestei runde", "valoare": text_intentie()},
		{"eticheta": "Modificatori", "valoare": _lista_sau_liniuta(MODIFICATORI_INAMIC)},
		{"eticheta": "Vulnerabilitati", "valoare": _lista_sau_liniuta(VULNERABILITATI_INAMIC)},
		{"eticheta": "Rezistente", "valoare": _lista_sau_liniuta(REZISTENTE_INAMIC)},
	]


func _pe_card_inamic_apasat() -> void:
	construieste_card()
	card_inamic.visible = true


func _pe_inchide_card_apasat() -> void:
	card_inamic.visible = false


## Click pe voal (adica oriunde in afara panoului) inchide cardul.
## Panoul e un PanelContainer, care oprește el clickurile dinauntru — asa ca
## aici ajung doar cele din afara lui.
func _pe_voal_card_apasat(eveniment: InputEvent) -> void:
	if eveniment is InputEventMouseButton 			and eveniment.button_index == MOUSE_BUTTON_LEFT 			and eveniment.pressed:
		card_inamic.visible = false


## Reconstruiește cardul de fiecare dată când se deschide, ca PV-ul și
## intenția să fie cele de acum, nu cele de la începutul luptei.
func construieste_card() -> void:
	card_titlu.text = DATE_ARHETIP[ARHETIP_INAMIC]["nume"]
	card_descriere.text = DATE_ARHETIP[ARHETIP_INAMIC]["descriere"]

	# Ștergem rândurile vechi înainte să le desenăm pe cele noi.
	# `queue_free()` le scoate la finalul cadrului, dar containerul le-ar mai
	# număra o clipă — `remove_child` le scoate din socoteală imediat.
	for copil in card_randuri.get_children():
		card_randuri.remove_child(copil)
		copil.queue_free()

	for rand in date_card_inamic():
		card_randuri.add_child(_construieste_rand(rand["eticheta"], rand["valoare"]))


## Un rând de card: eticheta la stânga, valoarea la dreapta.
func _construieste_rand(eticheta: String, valoare: String) -> HBoxContainer:
	var rand := HBoxContainer.new()

	var stanga := Label.new()
	stanga.text = eticheta
	stanga.modulate = Color(0.58, 0.58, 0.66)
	stanga.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dreapta := Label.new()
	dreapta.text = valoare
	dreapta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dreapta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dreapta.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	rand.add_child(stanga)
	rand.add_child(dreapta)
	return rand


# ─────────────────────────────────────────────────────────────
# AFIȘARE
# Regulă de aur: logica de sus NU atinge niciodată direct un Label.
# Ea schimbă doar variabilele de stare, apoi cheamă actualizeaza_ui().
# Un singur loc care desenează = imposibil să ai bara și textul desincronizate.
# ─────────────────────────────────────────────────────────────
func actualizeaza_ui() -> void:
	eticheta_runda.text = "RUNDA %d" % runda

	# Numele e un BUTON: click pe el deschide cardul cu detaliile inamicului.
	# „[i]" e singurul indiciu că se poate apăsa — un buton plat, fără fundal,
	# nu se anunță singur.
	buton_inamic.text = "%s — %d/%d PV  [i]" % [
		DATE_ARHETIP[ARHETIP_INAMIC]["nume"], pv_inamic, PV_MAX_INAMIC
	]
	anima_bara(bara_pv_inamic, pv_inamic)

	# Intenția, anunțată dinainte (ca în Slay the Spire): decizi cu informație
	# completă, nu la noroc. Rămâne pe ecran permanent, dar minusculă:
	# o sabie desenată și un număr.
	eticheta_intentie.text = text_intentie()
	# Sabia apare doar când tura asta chiar lovește. Cât timp Grabnicul își
	# încarcă ceasul, rămâne doar contorul — n-ai ce încasa runda asta.
	iconita_sabie.visible = inamicul_loveste_acum()
	var culoare_intentie := CULOARE_INTENTIE_GREA if lovitura_grea() else CULOARE_INTENTIE
	iconita_sabie.culoare = culoare_intentie
	eticheta_intentie.modulate = culoare_intentie
	# Bara de ceas apare doar la arhetipurile care CHIAR au ceas —
	# altfel ar fi un element de UI care nu înseamnă nimic.
	bara_ceas.visible = ARHETIP_INAMIC == Arhetip.GRABNIC
	if bara_ceas.visible:
		anima_bara(bara_ceas, ceas_inamic)

	eticheta_pv_jucator.text = "REGELE (tu) — %d/%d PV" % [pv_jucator, PV_MAX_JUCATOR]
	anima_bara(bara_pv_jucator, pv_jucator)

	# Butoanele se sting singure când n-ai PA — feedback vizual gratuit,
	# în loc de un mesaj de eroare după click.
	# Punctele pline = PA rămase; cele stinse = PA cheltuite. Poziția fixă
	# contează: al treilea punct e mereu al treilea, deci „mi-au rămas două"
	# se citește din formă, fără să numeri.
	for i in range(stiluri_pa.size()):
		stiluri_pa[i].bg_color = CULOARE_PA_PLIN if i < pa else CULOARE_PA_GOL

	# Butonul de sub arenă rămâne ascuns TOT timpul.
	#
	# În timpul luptei n-are ce confirma: tura se încheie singură când nu mai
	# ai ce face. Iar la final nu mai e nici el butonul de repornire — acela
	# e acum în panoul de verdict, peste toată arena. Două butoane „Lupta din
	# nou" pe același ecran, unul dintre ele pe jumătate acoperit de voal,
	# nu sunt două șanse; sunt o întrebare inutilă despre care e cel adevărat.
	#
	# Nodul și handler-ul rămân în scenă: `_pe_incheie_tura_apasat()` e în
	# continuare drumul prin care se încheie o tură din cod, și e util să ai
	# un buton de pornit înapoi când testezi. Doar nu se vede.
	buton_incheie_tura.visible = false

	for index in range(butoane_obelisc.size()):
		var buton: Obelisc = butoane_obelisc[index]
		var blocat := e_blocat(index)

		# Un singur apel, două adevăruri: „e blocat runda asta" și „nu-l poți
		# apăsa acum". CUM se vede fiecare — lacătul, piesa stinsă, halo-ul —
		# decide butonul (vezi `obelisc.gd`). Lupta nu știe că există un lacăt:
		# dacă mâine blocarea se arată altfel, aici nu se schimbă nimic.
		#
		# Textul „(blocat)" a dispărut odată cu el. Ocupa un rând întreg sub nume
		# și muta tot ce era pe buton de fiecare dată când se aprindea sau se
		# stingea; lacătul din colț spune același lucru fără să miște nimic.
		buton.seteaza_stare(
			blocat,
			lupta_terminata or puzzle_activ or blocat or pa < COST_OBELISC
		)


## Scrie o linie în jurnal. Nu se mai vede pe ecranul de luptă — ajunge în
## panoul deschis din butonul JURNAL, și în consola Godot.
func scrie_in_jurnal(linie: String) -> void:
	jurnal.append(linie)
	if jurnal.size() > LINII_JURNAL:
		jurnal.remove_at(0)   # scoate cea mai veche linie
	eticheta_jurnal.text = "\n".join(jurnal)
	print(linie)


## Deschide panoul cu istoricul luptei.
func _pe_jurnal_apasat() -> void:
	panou_jurnal.visible = true
	# Derulăm la ultima linie. Avem nevoie de un cadru ca eticheta să-și
	# recalculeze înălțimea; înainte de asta, bara de derulare încă nu știe
	# cât de lung e textul și `max_value` ar fi vechi.
	await get_tree().process_frame
	derulare_jurnal.scroll_vertical = int(derulare_jurnal.get_v_scroll_bar().max_value)


func _pe_inchide_jurnal_apasat() -> void:
	panou_jurnal.visible = false

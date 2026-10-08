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
const PA_PE_RUNDA := 2          # PA primite la începutul fiecărei runde (nu se reportează)
const COST_OBELISC := 1         # o activare = 1 PA, indiferent câte trepte urmează
# PV-ul MAXIM nu mai e o constantă aici: e al expediției (`Expeditie.PV_MAX`).
# Regula „PV-ul nu se reface între lupte" înseamnă exact asta — lupta îl
# împrumută la început și îl dă înapoi la sfârșit, dar nu îl deține.
# `pv_max_jucator` de mai jos e copia lui de lucru, pusă în `reseteaza_lupta()`.
# PV-ul inamicului NU mai e o constantă: fiecare rând din tabelul `INAMICI`
# și-l aduce pe al lui. Valoarea de acum trăiește în `pv_max_inamic`, jos, în
# starea luptei — o constantă ar fi însemnat un singur inamic pentru totdeauna.
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
# Culorile titlului din panoul de verdict. Aurul e deja limbajul lucrurilor
# câștigate în joc (PA plin, ramele de panou); roșul stins al înfrângerii nu e
# roșul de alarmă cu care se scrie PV-ul inamicului — acela e o stare de acum,
# ăsta constată ceva ce s-a întâmplat deja. De-aia e desaturat și mai
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

# Câte trepte ține un nivel de dificultate înainte ca următorul să preia.
# Cu 3: treptele 1-3 sunt Nivel I, 4-6 sunt Nivel II, de la 7 încolo Nivel III.
# Adică nivelul urcă odată cu combo-ul afișat — ajungi la „COMBO x3" cu
# întrebări ușoare, iar Nivelul II începe exact la întrebarea care te duce la
# „x4". E un singur număr de reglat, nu o listă de praguri: dacă la joc se
# simte că nivelul urcă prea repede, pui 4 și ai patru trepte pe nivel.
const TREPTE_PE_NIVEL := 3

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
# RECOMPENSE
# Plăți din PERFORMANȚĂ, nu o sumă fixă pe victorie. Trei dintre cele patru
# linii de mai jos răsplătesc exact lucrurile pe care le vreau jucate:
#
#   PV rămas         → „nu te-a lovit" e o pricepere, nu noroc: fiecare lanț
#                       lung e o tură în care inamicul n-a apucat să lovească.
#   cel mai lung lanț → cel MAI LUNG, nu suma tuturor. Zece lanțuri de câte
#                       două trepte sunt un joc prudent; unul de douăzeci e un
#                       risc asumat, și doar al doilea merită plătit.
#   criticele        → obiectivul intermediar (treapta 5, 10, 15) primește și o
#                       răsplată în afara luptei, nu doar daune înăuntru.
#
# Cifrele sunt mici și rotunde intenționat: încă n-avem pe ce cheltui
# Fragmente, deci nu au cum să fie „echilibrate" azi. Sunt o SCARĂ, nu un
# echilibru — când apare cetatea, se reașază de aici, dintr-un singur loc.
# ─────────────────────────────────────────────────────────────
const FRAGMENTE_VICTORIE := 10        # simplul fapt că ai învins
const FRAGMENTE_PV_INTREG := 10       # cât ia cineva care termină cu PV plin
const FRAGMENTE_PE_TREAPTA_LANT := 1  # per treaptă din cel mai lung lanț
const FRAGMENTE_PE_CRITIC := 3        # per lovitură critică din toată lupta
# Bonusul fix al unui nod greu NU mai e o constantă aici: e coloana „bonus" din
# `Expeditie.DATE_NOD`. Elita avea 12, Bossul are nevoie de alt număr, iar a
# doua constantă lângă prima ar fi fost începutul unui `if` cu trei ramuri.

# Culorile panoului de recompensă. Liniile obișnuite sunt gri-calme, totalul e
# auriu (aurul e deja limbajul lucrurilor câștigate), iar o linie care a ieșit
# ZERO rămâne pe ecran, dar stinsă: o cifră lipsă e informație („n-ai prins
# niciun critic"), pe când un rând dispărut e doar o gaură pe care n-o observi.
const CULOARE_RECOMPENSA_ETICHETA := Color(0.58, 0.58, 0.66)
const CULOARE_RECOMPENSA_VALOARE := Color(0.82, 0.82, 0.9)
const CULOARE_RECOMPENSA_ZERO := Color(0.42, 0.42, 0.48)
const CULOARE_RECOMPENSA_TOTAL := Color(1, 0.85, 0.45)

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

# NU mai există un „COMUTATOR" de arhetip aici. Era o constantă pe care o
# schimbai în cod și reporneai jocul; acum inamicul se alege din joc, la
# pornirea luptei (vezi `_alege_inamicul()`). Diferența nu e de comoditate: o
# constantă poate ține UN inamic, un tabel plus o variabilă țin oricâți — iar
# harta de expediție va avea nevoie exact de al doilea lucru.

# NUMELE fiecărui arhetip, atât cât apare pe card. Doar atât — restul fișei
# s-a mutat în tabelul `INAMICI` de mai jos.
#
# Până acum, numele inamicului, facțiunea și descrierea lui stăteau CHIAR AICI,
# în tabelul arhetipurilor. Mergea, fiindcă exista un singur inamic per arhetip,
# deci „arhetip" și „inamic" păreau același lucru. Cu trei inamici și două
# arhetipuri, presupunerea cade: Soldatul și Spadasinul folosesc amândoi „Atac
# constant", dar sunt doi adversari diferiți, cu alte cifre și altă descriere.
#
# Un arhetip e o REGULĂ DE COMPORTAMENT, refolosibilă de oricâți inamici. E
# despărțirea anunțată la pasul 11 din ruta de construcție (generatorul de
# inamici), făcută acum fiindcă azi costă zece rânduri — iar după generator ar
# fi costat rescrierea lui.
const NUME_ARHETIP := {
	Arhetip.ATAC_CONSTANT: "Atac constant",
	Arhetip.GRABNIC: "Grabnic",
}

# ─────────────────────────────────────────────────────────────
# INAMICII, ca tabel
#
# Aceeași formă ca `OBELISCURI`: un Array de Dictionary. Un inamic nou e un RÂND
# aici, nu cod nou — lupta citește tabelul și nu știe câți sunt și nici care e
# „primul". La fel ca la discipline: proiectăm pentru mulți, scriem trei.
#
# CÂMPURILE
#   nume, factiune, descriere — IDENTITATEA. Facțiunea n-are efect mecanic azi;
#       e cârligul pentru zone de hartă și echipament anti-facțiune (CLAUDE.md).
#       Toți trei sunt din aceeași facțiune și au trei comportamente diferite —
#       exact de-aia facțiunea și arhetipul sunt două câmpuri, nu unul.
#   arhetip          — CE FACE în tura lui. O trimitere către o ramură din
#                      `tura_inamicului()`, nu un text.
#   cost             — DE LA CE BUGET are voie să apară. Nodurile de la
#                      începutul hărții au buget mic, cele de la final, mare
#                      (`Expeditie.BUGET_*`). Fără câmpul ăsta, primul nod al
#                      unei expediții ar putea fi cel mai greu adversar din joc.
#   pv               — cât ține. Aici, nu într-o constantă: doi inamici cu
#                      același PV ar fi o coincidență, nu o regulă.
#   daune            — cât lovește o lovitură a lui (la GRABNIC: descărcarea)
#   ceas             — DOAR la GRABNIC: în câte runde se umple. Lipsește la
#                      ceilalți, fiindcă n-au ce încărca (vezi `ceas_max()`).
#   vulnerabilitate  — numele unei discipline din `OBELISCURI`, sau "" dacă n-are
#   colorare         — aceeași siluetă, altă lumină pe ea (`aplica_infatisarea()`)
#
# CIFRELE, pe scurt: Soldatul e etalonul — cel pe care l-ai jucat până acum.
# Lăncierul are mai mult PV, dar te lasă în pace două runde din trei: lupta lui
# e o cursă contra ceasului, nu un schimb de lovituri. Spadasinul are cel mai
# mult PV și lovește cel mai des — fără să-i exploatezi slăbiciunea e o luptă
# lungă pe care o pierzi, cu ea e cea mai scurtă din trei. Ăsta e și testul
# vulnerabilității ca mecanică: dacă nu se simte diferența, cifra e greșită.
# ─────────────────────────────────────────────────────────────
const INAMICI := [
	{
		"nume": "SOLDATUL",
		"cost": 1.0,   # bugetul de la care are voie sa apara: de la primul nod
		"factiune": "Garnizoana",
		"arhetip": Arhetip.ATAC_CONSTANT,
		"descriere": "Nu e nimeni anume si nu vrea nimic de la tine. A primit un ordin vechi, pe care nu l-a mai anulat nimeni, si il duce la capat cu aceeasi lovitura, in fiecare tura, pana cade unul din voi.",
		"pv": 30,
		"daune": 3,
		"vulnerabilitate": "",
		"colorare": Color(1.00, 1.00, 1.00),
	},
	{
		"nume": "LANCIERUL",
		"cost": 1.6,   # bugetul de la care are voie sa apara: dupa un nod-doua
		"factiune": "Garnizoana",
		"arhetip": Arhetip.GRABNIC,
		"descriere": "Loveste o singura data, dar isi pregateste lovitura la vedere: numara rundele cu varful lancei coborat spre tine. Ai doua runde in care nu te atinge si una in care te costa jumatate din rege — deci intrebarea nu e daca ataca, ci daca apuci sa-l dobori inainte.",
		"pv": 34,
		"daune": 8,
		"ceas": 3,
		"vulnerabilitate": "",
		"colorare": Color(0.74, 0.86, 1.00),
	},
	{
		"nume": "SPADASINUL",
		"cost": 2.2,   # bugetul de la care are voie sa apara: spre mijlocul expeditiei
		"factiune": "Garnizoana",
		"arhetip": Arhetip.ATAC_CONSTANT,
		"descriere": "Rapid, si prea increzator in asta. A invatat sa citeasca arme, nu cuvinte: o intrebare de Cuvinte il prinde descoperit si intra de doua ori mai adanc. Pe restul disciplinelor te taie marunt, tura de tura, si asteapta sa obosesti.",
		"pv": 40,
		"daune": 4,
		"vulnerabilitate": "cuvinte",
		"colorare": Color(1.00, 0.82, 0.66),
	},
]

## Cât doare disciplina la care un inamic e vulnerabil. ×2, adică exact cât un
## critic — și se ÎNMULȚEȘTE cu el, nu îl înlocuiește: un critic dat pe
## disciplina slabă e ×2 din treaptă și încă ×2 de aici.
##
## De ce ×2 și nu „+2 daune": un bonus fix ar fi contat enorm la treapta 1 (unde
## dublează 1 în 3) și aproape deloc la treapta 10. Înmulțirea păstrează aceeași
## promisiune pe toată lungimea lanțului — „disciplina asta e de două ori mai
## bună aici" — și rămâne adevărată și când daunele de bază se vor schimba.
const MULTIPLICATOR_VULNERABILITATE := 2

## Cerneala secundară din panoul de alegere: ce face inamicul, scris sub numele
## lui. Mai stinsă decât textul obișnuit — e o notă de subsol, nu titlul.
const CULOARE_ALEGERE_DETALIU := Color(0.62, 0.62, 0.72)

## Culoarea slăbiciunii: chihlimbar, nu roșu. Roșul e deja al inamicului în
## interfața asta (bara lui de PV, cifra lui de PV) — o etichetă roșie ar
## fi citită ca „pericol", când ea spune exact pe dos: „aici e deschis".
const CULOARE_VULNERABIL := Color(1.00, 0.72, 0.35)

# Listele astea sunt goale intentionat. Sunt cârligele pentru pasul 11
# (generatorul de inamici): cand un inamic va primi „+50% PV", modificatorii
# ajung aici si apar automat in card.
#
# Vulnerabilitatea a plecat dintre ele: nu mai e o listă de etichete decorative,
# ci un câmp din `INAMICI` care CHIAR schimbă daunele. Rezistențele rămân aici
# până când vor face și ele ceva.
const MODIFICATORI_INAMIC: Array[String] = []
const REZISTENTE_INAMIC: Array[String] = []

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

## Scena unui buton de Obelisc. Se instanțiază de N ori în `_ready()`.
const SCENA_OBELISC := preload("res://scenes/lupta/obelisc.tscn")

## Unde se întoarce lupta când se termină. Text, nu `preload`: harta preload-ează
## lupta, iar lupta ar preload-a harta — două scene care se încarcă una pe alta,
## la infinit. `change_scene_to_file` citește calea abia când e nevoie.
const SCENA_HARTA := "res://scenes/harta/harta.tscn"

## Câți candidați rămân după ce se taie cei prea slabi pentru buget. Vezi
## `_alege_inamicul()`. Doi = destulă varietate ca două noduri alăturate să nu
## dea același adversar, destulă strâmtoare ca dificultatea să urce vizibil.
const FEREASTRA_INAMICI := 2

# ────────────────────────────────────────────────────────────
# OBELISCURILE — NU MAI SUNT UN TABEL AICI
#
# Erau. Tabelul `OBELISCURI` s-a mutat în `autoload/discipline.gd`, și mutarea
# n-a fost o curățenie: ecranul de loadout are nevoie de aceeași listă, iar el
# nu e o luptă. Un tabel de care au nevoie două scene nu mai poate sta în
# niciuna dintre ele.
#
# Ce rămâne aici e LOADOUT-UL: fișele celor N discipline cu care ai intrat în
# expediția asta, citite o dată în `_ready()` din `Expeditie.loadout`.
#
# Lupta nu mai știe câte discipline există în joc — știe doar cu ce a venit
# jucătorul. De-aia scena nu mai are trei noduri Obelisc scrise de mână:
# butoanele se construiesc, exact atâtea câte cere loadout-ul. Cu N variabilă,
# trei noduri fixe în scenă ar fi fost o minciună așteptată să se întâmple.
# ────────────────────────────────────────────────────────────
var loadout: Array[Dictionary] = []


# ─────────────────────────────────────────────────────────────
# STAREA LUPTEI (variabile)
# `var` = se schimbă în timpul jocului. Astea + jurnalul sunt TOATĂ
# starea luptei — exact ce va trebui, mai târziu, salvat în JSON.
# ─────────────────────────────────────────────────────────────
var runda := 1
var pa := 0
var pv_jucator := 0
var pv_max_jucator := 0

# CINE e inamicul: un index în tabelul `INAMICI`, nu o copie a rândului lui.
# Un index nu poate ajunge niciodată să difere de tabel; o copie, da — ai
# schimba o cifră în tabel și lupta ar juca mai departe cu cea veche.
# Se alege la pornirea luptei (`_alege_inamicul()`) și nu se schimbă în timpul ei.
var inamic_curent := 0

## CE FEL DE NOD e ăsta (`Expeditie.Nod.LUPTA`, `.ELITA`, `.BOSS`). Citit o
## dată, în `_alege_inamicul()`, și folosit în trei locuri: cifrele inamicului,
## titlul cardului și răsplata.
##
## Înainte era un `bool e_elita`, și a ținut exact până a apărut Bossul: un
## „da/nu" nu poate răspunde la întrebarea „cât de greu", iar al doilea bool
## lângă primul ar fi făcut patru combinații din care două n-au sens. Tipul
## nodului e o singură întrebare cu răspunsuri câte vrei, iar cifrele care
## atârnă de el stau în `Expeditie.DATE_NOD`.
var tip_nod := Expeditie.Nod.LUPTA

## Fișa tipului de mai sus, luată o dată ca să n-o căutăm în tabel la fiecare
## lovitură. „putere", „monede", „bonus" — vezi `Expeditie.DATE_NOD`.
var fisa_nod: Dictionary = Expeditie.DATE_NOD[Expeditie.Nod.LUPTA]

# PV-ul lui, și maximul LUI. Al doilea e o variabilă, nu o constantă, fiindcă
# fiecare inamic vine cu al lui — se copiază din tabel o singură dată, în
# `reseteaza_lupta()`, și de acolo îl citește toată interfața.
var pv_inamic := 0
var pv_max_inamic := 0
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

# STATISTICILE LUPTEI, strânse pentru recompensa de la final.
# Le ținem separat de `combo_corecte` și `lant_daune`, care se șterg la fiecare
# lanț nou: astea două trebuie să supraviețuiască întregii lupte. Se golesc
# doar în `reseteaza_lupta()`, alături de PV și rundă.
var cel_mai_lung_lant := 0   # cel mai lung șir de răspunsuri corecte, dintr-un singur lanț
var critice_totale := 0      # câte trepte critice ai atins în toată lupta

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
# panoul mai ocupă loc pe tot parcursul închiderii animate (altfel figurile ar
# sări la loc instantaneu), deci prezența lui nu poate răspunde la întrebarea
# „e panoul deschis?". Dacă apeși un Obelisc în cele 0,55 s de închidere,
# prezența zice „da, e deschis" — și deschiderea nouă nu s-ar mai face, iar
# închiderea în curs ar continua peste întrebarea abia apărută.
var panou_deschis := false

# CE FACE panoul chiar acum: ocupă loc în Arenă sau nu. Perechea celui de sus.
#
# Până acum întrebarea asta se punea nodului, prin `zona_puzzle.visible` — și
# de acolo venea saltul de la finalul închiderii. `HBoxContainer` nu doar că
# scoate din socoteală un copil ascuns, ci scoate și SPAȚIEREA de lângă el:
# 16 px de separare plus chenarul panoului dispăreau dintr-un cadru în
# următorul, iar cele două coloane se lățeau brusc cu ~9 px fiecare, exact
# după ce terminaseră de alunecat lin.
#
# Acum panoul nu se mai ascunde niciodată: se stinge din `modulate.a` și
# rămâne în așezare cu lățime zero (vezi `content_margin` zero din stilul lui,
# care îi taie și lățimea minimă). Așezarea nu se mai schimbă brusc nicăieri,
# fiindcă nu mai există un „înainte" și un „după" — există o singură lățime
# care merge continuu până la zero.
#
# Prețul: panoul stins ține în continuare o spațiere de 16 px în mijlocul
# Arenei, tot timpul. E o constantă, nu o săritură — și o constantă de 8 px pe
# coloană nu se vede, pe când o săritură de 8 px se vede de fiecare dată.
var panoul_e_pe_ecran := false

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
@onready var semn_info: SemnInspectare = %InamicSemnInfo
@onready var bara_pv_inamic: ProgressBar = %InamicBaraPV
@onready var eticheta_vulnerabil: Label = %InamicVulnerabil
# Plăcuța inamicului, construită după aceleași reguli ca a regelui: numele mic
# și stins deasupra, cifra de PV dedesubt — aici roșie, ca bara de lângă.
# Simetria nu e cochetărie: două plăcuțe la fel se citesc dintr-o privire,
# fiindcă ochiul caută cifra în același loc pe ambele coloane.
@onready var eticheta_pv_inamic: Label = %InamicPV
# Plăcuța regelui, pe două rânduri: numele mic și stins deasupra, cifra de PV
# dedesubt. Înainte era un singur rând alb, „REGELE (tu) — 15/15 PV", lipit de
# marginea de sus a coloanei, cu 56 de pixeli goi între el și figură: plutea.
# Ce citești des (cifra) e acum mare și verde ca bara de lângă; ce citești o
# dată (numele) e mic și stins.
#
# CUM STAU CELE DOUĂ PLĂCUȚE PE ACELAȘI CAIET DE DICTANDO
# Amândouă blocurile au 84 px înălțime fixă, separare ZERO, și aceeași schemă:
#   `Spatiu` (se întinde) → nume (30 px fix) → cifra de PV (24 px fix)
# Golul elastic e SUS. Tot ce e informație se adună jos, lipit, chiar deasupra
# figurii: numele și cifra sunt o singură plăcuță, nu două etichete puse în
# aceeași coloană. Diferențele dintre coloane le înghite golul de sus.
#
# La inamic mai intră eticheta de vulnerabilitate, dar DEASUPRA numelui, nu
# între nume și cifră. Locul ăsta e singurul care funcționează: e ultimul rând
# care poate să apară și să dispară (inamicii fără slăbiciune n-o au) fără să
# miște nimic din ce e sub el.
#
# Au fost două încercări greșite înainte, amândouă merită ținute minte:
#   1. Ambele blocuri aliniate la bază (`alignment = 2`), cu vulnerabilitatea
#      între nume și cifră. Numele inamicului urca cu un rând față de al
#      regelui, fiindcă avea un rând în plus sub el.
#   2. Golul elastic ÎNTRE nume și cifră. Alinia corect, dar rupea plăcuța în
#      două: numele plutea sus, cifra jos, și nu se mai citeau ca un întreg.
#
# Al doilea vinovat de la încercarea 1 era mai ascuns: numele inamicului e un
# Button, cel al regelui un Label, iar un Button își adaugă din temă vreo 8 px
# de margini — deci nici înălțimile cutiilor nu erau egale. De aia amândouă au
# acum `custom_minimum_size` de 30 px: e peste minimul natural al butonului,
# deci ambele cutii ajung exact 30 și textul se centrează la fel în ele.
@onready var eticheta_nume_jucator: Label = %JucatorNume
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
# Cardul de inamic: titlu și rândurile generate din date.
#
# `descriere` NU mai ajunge aici. Era un paragraf de atmosferă care ținea
# singur jumătate din fereastră și o umfla cât ecranul — iar în mijlocul unei
# lupte nu deschizi cardul ca să citești cine e adversarul, ci ca să afli
# câte daune dă și pe ce e vulnerabil. Câmpul rămâne în `INAMICI`: e
# identitate, și își găsește locul unde chiar se citește (hartă, sumar).
@onready var card_inamic: Control = %CardInamic
@onready var card_titlu: Label = %CardTitlu
@onready var card_randuri: VBoxContainer = %CardRanduri
@onready var buton_inchide_card: Button = %CardInchide
# Voalul e dreptunghiul intunecat din spatele panoului. E si suprafata
# de "click in afara": tot ce nu e panoul, e el.
@onready var voal_card: ColorRect = %VoalCard
# Cele două variante de figuri, în perechi: desenată și imagine.
# Lupta nu le atinge altfel — doar decide care se vede.
# Învelișurile care clatină figura la lovitură. Ele stau în container;
# figura (siluetă sau imagine) atârnă înăuntru, unde n-o mișcă nimeni.
# Se caută prin `%`, nu prin cale: învelișurile s-au mutat cu un nivel mai
# adânc (sub `ArenaJucator`/`ArenaInamic`, ca să aibă umbra unde sta ca frate),
# iar o cale scrisă cap-coadă s-ar fi rupt la mutare. Numele unic supraviețuiește
# oricărei rearanjări din editor.
@onready var figura_jucator: Control = %FiguraJucator
@onready var figura_inamic: Control = %FiguraInamic
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
@onready var verdict_recompense: VBoxContainer = %VerdictRecompense
@onready var buton_verdict: Button = %VerdictButon
# Panoul de alegere a inamicului: lista lui se umple din cod, din `INAMICI`.
# Toate înfățișările inamicului, la un loc: silueta desenată și imaginea din
# arenă, plus perechea lor din portretul cardului. Colorarea se pune pe toate
# patru deodată (`aplica_infatisarea()`) — altfel ai avea un Spadasin arămiu în
# arenă și unul alb în card, adică doi inamici.
@onready var figuri_inamic: Array[Control] = [
	%InamicSilueta, %InamicImagine, %PortretInamic, %PortretImagine
]
@onready var figuri_desenate: Array[Control] = [%JucatorSilueta, %InamicSilueta, %PortretInamic]
@onready var figuri_imagini: Array[Control] = [%JucatorImagine, %InamicImagine, %PortretImagine]
## Rândul în care se nasc butoanele de Obelisc. Gol în scenă: câte butoane
## are lupta e o întrebare la care răspunde loadout-ul, nu editorul.
@onready var rand_obeliscuri: HBoxContainer = %RandObeliscuri

## Butoanele construite, în aceeași ordine ca `loadout`. Indicele dintr-o
## listă e indicele din cealaltă — tot codul de mai jos se bazează pe asta.
var butoane_obelisc: Array[Obelisc] = []


# `_ready()` e chemată automat de Godot o singură dată, când scena a intrat
# în joc și toate nodurile există. Aici punem tot ce se face o dată.
func _ready() -> void:
	_pregateste_loadout()
	_construieste_obeliscurile()

	buton_incheie_tura.pressed.connect(_pe_incheie_tura_apasat)
	buton_jurnal.pressed.connect(_pe_jurnal_apasat)
	buton_inchide_jurnal.pressed.connect(_pe_inchide_jurnal_apasat)
	buton_inamic.pressed.connect(_pe_card_inamic_apasat)
	# A doua ușă spre același card: figura inamicului, cu semnul „i" pe ea.
	# Numele de sus rămâne apăsabil — nu strică nimic și e drumul pe care
	# îl are deja în deget cine juca înainte —, dar nu mai ANUNȚĂ nimic:
	# „[i]"-ul care îl anunța s-a mutat pe figură.
	semn_info.pressed.connect(_pe_card_inamic_apasat)
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

	# BARELE NU SE PREGĂTESC AICI. Niciuna — nici măcar a jucătorului, deși
	# maximul lui a fost cândva o constantă. Azi vine din `Expeditie`, ca și
	# cifrele inamicului, iar în clipa asta nu s-a citit încă nimic de acolo:
	# o bară pusă pe `pv_max_jucator` ar primi maximul 0.
	#
	# Toate trei se pun într-un singur loc, în `reseteaza_lupta()` (chemată la
	# capătul funcției ăsteia), și se pun cu tot cu valoare — vezi
	# `pune_bara_acum()`. Un maxim pus aici și o valoare pusă acolo sunt exact
	# felul în care bara ajunge, pentru un cadru, să arate o stare inventată.

	# Punctele de PA le construim DIN COD, câte unul per PA disponibil.
	# Dacă mâine PA_PE_RUNDA devine 4, apar patru puncte fără să atingi scena.
	# (Iar când adaugi Regina, care costă 2 PA, se vor stinge două deodată —
	# tocmai ăsta e avantajul punctelor față de o cifră: vezi cât te costă.)
	# `+ bonus_pa()`: Magazinul poate da PA în plus, iar un al patrulea PA fără
	# un al patrulea punct desenat ar fi un PA pe care nu-l vezi.
	for i in range(PA_PE_RUNDA + Expeditie.bonus_pa()):
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
	# O derivăm din LOADOUT, deci merge la fel cu trei Obeliscuri sau cu cinci.
	disponibil_din.resize(loadout.size())

	# `Muzica` e autoload-ul din autoload/muzica.gd — există global, nu trebuie
	# creat sau căutat. Dacă piesa cântă deja (ai revenit din altă scenă),
	# apelul nu face nimic, deci nu repornește melodia de la zero.
	Muzica.reda(Muzica.Piesa.LUPTA)

	# Nodul de expediție e deja ales când ajungem aici (harta l-a pus în
	# `Expeditie`), deci lupta poate porni pe loc, fără niciun panou între.
	reseteaza_lupta()


# ─────────────────────────────────────────────────────────────
# LEGĂTURA CU EXPEDIȚIA
#
# Lupta nu mai e un ecran de sine stătător. Ea împrumută trei lucruri de la
# `Expeditie` și dă înapoi două:
#
#   împrumută   loadout-ul (cu ce lupți), PV-ul (cât ți-a rămas), nodul (pe
#               cine întâlnești și cât de greu e)
#   dă înapoi   PV-ul rămas și raportul luptei (lanț, critice, daune)
#
# Nimic nu se transmite ca parametru între scene. Tot ce trebuie știut se
# citește din autoload — fiindcă un parametru pasat între scene e exact lucrul
# care se pierde la un save, iar o expediție trebuie să se poată relua.
# ─────────────────────────────────────────────────────────────

## Fișele disciplinelor cu care s-a intrat în expediție.
##
## Cheile necunoscute se sar, cu un avertisment: un save vechi poate cere o
## disciplină ștearsă între timp, și atunci e mai bine să lupți cu două
## Obeliscuri decât să nu poți porni lupta deloc.
##
## Plasa de siguranță de la final e pentru un singur caz, dar unul real: ai
## deschis `lupta.tscn` direct cu F6, ca să testezi ceva, și nu există nicio
## expediție. Atunci lupta își face singură un loadout și merge mai departe.
## O scenă care nu se mai poate porni singură e o scenă pe care n-o mai testezi.
func _pregateste_loadout() -> void:
	loadout.clear()
	for cheie in Expeditie.loadout:
		var date := Discipline.dupa_cheie(cheie)
		if date.is_empty():
			push_warning("Lupta: disciplina necunoscuta '%s' in loadout." % cheie)
			continue
		loadout.append(date)

	if loadout.is_empty():
		push_warning("Lupta: loadout gol — pornita in afara unei expeditii? Iau din catalog.")
		for i in range(mini(Expeditie.DISCIPLINE_IN_LOADOUT, Discipline.cate())):
			loadout.append(Discipline.CATALOG[i])


## Naște câte un buton pentru fiecare disciplină din loadout.
##
## Ce ține de IDENTITATEA Obeliscului (nume, piesă, culoare) se pune o singură
## dată, aici: nu se schimbă niciodată în timpul luptei. Ce ține de STAREA lui
## (blocat, fără PA) merge prin `seteaza_stare()`, din `actualizeaza_ui()`.
func _construieste_obeliscurile() -> void:
	for copil in rand_obeliscuri.get_children():
		rand_obeliscuri.remove_child(copil)
		copil.queue_free()
	butoane_obelisc.clear()

	for index in range(loadout.size()):
		var date: Dictionary = loadout[index]
		var buton: Obelisc = SCENA_OBELISC.instantiate()
		# EXPAND|FILL — cele N butoane își împart lățimea în părți egale,
		# oricâte ar fi. Cu trei noduri scrise de mână în scenă, al patrulea
		# Obelisc ar fi cerut o vizită în editor.
		buton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rand_obeliscuri.add_child(buton)
		buton.configureaza(
			date["nume"], date["piesa"], date["culoare"], date["imagine"]
		)
		# `.bind(index)` trimite indicele funcției: o singură funcție pentru
		# toate butoanele, oricâte ar fi.
		buton.pressed.connect(_pe_obelisc_apasat.bind(index))
		butoane_obelisc.append(buton)


## PE CINE ÎNTÂLNEȘTI LA NODUL ĂSTA.
##
## Aici se vede granița trasă dinadins între hartă și luptă: **expediția știe
## cât de GREU e un nod, lupta știe CINE poate fi inamicul.** `Expeditie` n-are
## niciun nume de inamic în ea și nici nu vrea să aibă — ea produce un buget și
## o sămânță; tabelul `INAMICI` rămâne treaba luptei.
##
## De ce contează: la pasul 10 (generatorul de inamici) tot ce se schimbă e
## funcția asta. Harta nu află niciodată că s-a întâmplat ceva.
##
## Sămânța e A NODULUI, nu a hărții: același nod dă același inamic de fiecare
## dată când reiei expediția, dar două noduri alăturate dau inamici diferiți.
## Asta e tot ce înseamnă „reproductibil".
func _alege_inamicul() -> void:
	var nod := Expeditie.nod_curent()
	if nod.is_empty():
		inamic_curent = 0     # F6 direct pe scena de luptă, fără expediție
		tip_nod = Expeditie.Nod.LUPTA
		fisa_nod = Expeditie.date_nod(tip_nod)
		return

	tip_nod = int(nod["tip"])
	fisa_nod = Expeditie.date_nod(tip_nod)
	var buget := float(nod["buget"])

	var rng := RandomNumberGenerator.new()
	rng.seed = int(nod["samanta"])

	# ── CINE ÎNCAPE ÎN BUGET ──────────────────────────────────
	# „cost" e cifra prin care un inamic spune cât de devreme are voie să
	# apară: Soldatul de la primul nod, Spadasinul mai târziu. Fără ea, primul
	# nod al unei expediții ar putea fi cel mai greu adversar din joc, și un run
	# s-ar termina în treizeci de secunde din pur ghinion.
	var candidati: Array[int] = []
	for i in range(INAMICI.size()):
		if float(INAMICI[i]["cost"]) <= buget:
			candidati.append(i)
	if candidati.is_empty():
		candidati.append(_cel_mai_ieftin())   # buget sub oricine: primul nod

	# ── ȘI CINE E DEJA SUB NIVEL ──────────────────────────────
	# „încape în buget" singur nu ajunge, și asta s-a văzut la prima rulare:
	# Soldatul încape în ORICE buget, deci putea ieși și la nodul de Elită de
	# la capătul hărții. O expediție care se termină cu același adversar cu
	# care a început n-are cum să se simtă ca un drum.
	#
	# Deci din cei care încap păstrăm doar pe cei mai SCUMPI, o fereastră de
	# `FEREASTRA_INAMICI`. Efectul secundar e chiar cel căutat: cu doi candidați
	# în loc de trei, două noduri alăturate au șanse mari să dea adversari
	# diferiți — alternanță, fără să fie nevoie de o listă de rotație.
	#
	# Nu se folosește `Sac` aici, deși ar da alternanță perfectă: sacul trage cu
	# generatorul GLOBAL, iar atunci același nod n-ar mai da același inamic la o
	# reluare. Reproductibilitatea e mai valoroasă decât ultimul pic de varietate.
	candidati.sort_custom(
		func(a, b): return float(INAMICI[a]["cost"]) > float(INAMICI[b]["cost"])
	)
	candidati = candidati.slice(0, maxi(FEREASTRA_INAMICI, 1))

	inamic_curent = candidati[rng.randi_range(0, candidati.size() - 1)]


## Indicele celui mai ieftin inamic din tabel. Căutat, nu presupus „0": ordinea
## rândurilor din `INAMICI` e o chestiune de citit, nu o promisiune.
func _cel_mai_ieftin() -> int:
	var ales := 0
	for i in range(INAMICI.size()):
		if float(INAMICI[i]["cost"]) < float(INAMICI[ales]["cost"]):
			ales = i
	return ales


## Cât de tare e inamicul de la nodul ăsta, ca înmulțitor peste cifrele lui din
## tabel. 1.0 la o luptă obișnuită, mai mult la Elită.
##
## Înmulțire, nu adunare, din același motiv ca la vulnerabilitate: un „+10 PV"
## ar fi însemnat enorm pentru Soldat și puțin pentru Spadasin, deci ar fi
## schimbat ECHILIBRUL dintre ei, nu doar dificultatea nodului.
func _multiplicator_nod() -> float:
	return float(fisa_nod["putere"])


## O cifră din tabelul `INAMICI`, trecută prin greutatea nodului.
##
## Rotunjire și `maxi(..., 1)` într-un SINGUR loc: un inamic cu 0 PV ar fi deja
## mort, unul cu 0 daune n-ar fi un adversar. Înainte, formula era scrisă de
## două ori (o dată pentru PV, o dată pentru daune) și a treia oară era UITATĂ —
## cardul citea `date["daune"]` direct din tabel, deci la o Elită scria „4 daune
## in fiecare tura" despre un adversar care lovea cu 6. Cifra afișată și cifra
## care doare trebuie să vină din aceeași funcție, altfel se despart în tăcere.
func _cu_puterea_nodului(valoare: int) -> int:
	return maxi(roundi(valoare * _multiplicator_nod()), 1)



# ─────────────────────────────────────────────────────────────
# BUCLA DE RUNDĂ
# ─────────────────────────────────────────────────────────────

## Începutul turei TALE: primești PA proaspăt.
func incepe_runda() -> void:
	# PA-ul de bază, plus ce ai cumpărat la Magazin. Adunarea se face AICI, la
	# fiecare rundă, nu o dată la începutul luptei: dacă vreodată o putere se va
	# putea pierde în mijlocul unei lupte, linia asta o va observa singură.
	pa = PA_PE_RUNDA + Expeditie.bonus_pa()   # PA nu se reportează
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
	var date: Dictionary = loadout[index]
	var disciplina: String = date["nume"]     # ce se scrie în jurnal
	var cheie: String = date["cheie"]         # ce se compară cu vulnerabilitatea

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
		# Vârful lanțului, ținut minte pentru recompensa de la finalul luptei.
		# `maxi` înseamnă că un lanț mai scurt de-acum înainte nu poate șterge
		# recordul: e „cel mai lung din luptă", nu „ultimul".
		cel_mai_lung_lant = maxi(cel_mai_lung_lant, combo_corecte)
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
			# Și un semn în răbojul luptei: fiecare critic se plătește la final.
			critice_totale += 1

		# Daunele treptei se aplică IMEDIAT, nu la finalul lanțului.
		#
		# Vulnerabilitatea se înmulțește PESTE treaptă și peste critic, nu în
		# locul lor: un critic dat pe disciplina slabă e ×2 din treaptă și încă
		# ×2 de aici. Ordinea nu contează matematic, dar contează pentru citit —
		# `daune_treapta()` răspunde la „cât valorează treapta asta", iar linia
		# de mai jos la „cât de tare o simte inamicul ăsta". Două întrebări
		# diferite, două locuri.
		var slabiciune := e_vulnerabil(cheie)
		var daune := daune_treapta(treapta)
		if slabiciune:
			daune *= MULTIPLICATOR_VULNERABILITATE
		lant_daune += daune
		# maxi() = maximul a două int-uri. Îl folosim ca PV să nu scadă sub 0.
		pv_inamic = maxi(pv_inamic - daune, 0)
		# Daunele merg mai departe la efectul de impact: o lovitură de 1 abia
		# tremură, una critică zguduie vizibil. Așa mărimea loviturii se vede,
		# nu doar se citește în jurnal.
		figura_inamic.loveste(daune)

		# Marcajul de vulnerabilitate NU se aprinde pe ecranul de puzzle, ca
		# „CRITIC!". Criticul e un EVENIMENT — a cincea treaptă, o dată la cinci
		# întrebări — deci merită un fulger. Vulnerabilitatea e o STARE: dublează
		# fiecare treaptă din lanț, la nesfârșit. Un marcaj la fiecare întrebare
		# n-ar mai fi un accent, ar fi tapet. Ea se anunță o dată, înainte de
		# luptă (panoul de alegere) și stă scrisă tot timpul sub numele
		# inamicului — iar în lanț se vede acolo unde contează: în bara lui,
		# care scade de două ori mai repede.
		var nota := " VULNERABIL!" if slabiciune else ""
		if critica:
			scrie_in_jurnal("%s, treapta %d: CRITIC!%s +%d daune (lant: %d)." % [
				disciplina, treapta, nota, daune, lant_daune
			])
		else:
			scrie_in_jurnal("%s, treapta %d (Nivel %s): corect.%s +%d daune (lant: %d)." % [
				disciplina, treapta, CIFRE_ROMANE[nivel - 1], nota, daune, lant_daune
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


## Ce NIVEL DE DIFICULTATE cere o treaptă. Nivelul urcă la fiecare
## `TREPTE_PE_NIVEL` trepte: cu 3, treptele 1-3 sunt I, 4-6 sunt II, iar de la
## 7 încolo rămân la III. Nu inventăm niveluri noi de dificultate — presiunea
## suplimentară de după treapta a 7-a vine din cronometru, nu din întrebări
## imposibile.
##
## De ce un PALIER și nu o treaptă pe nivel (cum era înainte): la a doua
## întrebare a unui lanț primeai deja Nivel II, iar la a treia Nivel III. Un
## lanț lung nu mai avea o pantă, ci un perete la început — cel mai prost loc
## pentru el, fiindcă acolo n-ai încă nimic acumulat de apărat. Cu trei trepte
## pe nivel, primele răspunsuri construiesc combo-ul, iar greul vine când ai
## deja ceva de pierdut.
##
## Împărțirea e cu numere întregi, deci retează singură: (treapta - 1) spune
## câte trepte ai lăsat în urmă, `/ TREPTE_PE_NIVEL` câte paliere complete sunt
## în ele, iar `+ 1` fiindcă nivelurile se numără de la 1, nu de la 0.
func nivel_treapta(treapta: int) -> int:
	return mini((treapta - 1) / TREPTE_PE_NIVEL + 1, NIVEL_MAX)


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


## Pune o bară pe o valoare PE LOC, fără alunecare. Perechea lui `anima_bara`,
## pentru momentele în care nu s-a întâmplat nimic de arătat.
##
## De ce e nevoie de ea: alunecarea spune „s-a schimbat ceva chiar acum". La
## ÎNCEPUTUL unei lupte nu s-a schimbat nimic — regele intră în arenă cu PV-ul
## cu care a ieșit din nodul de dinainte. Fără funcția asta, bara pornea de la
## valoarea rămasă în scenă (15, cât era în editor) și se umplea sub ochii tăi
## până la maximul adevărat: o fracțiune de secundă în care jocul părea că
## tocmai ți-a DAT viață, exact înainte de prima întrebare.
##
## Cazul apărea fiindcă `max_value` se pune în `reseteaza_lupta()`, dar `value`
## rămânea cea veche până la prima `actualizeaza_ui()` — iar aia animează. Două
## momente diferite pentru aceeași bară, deci un cadru în care bara arăta o
## stare care n-a existat niciodată.
##
## `kill()` pe tween-ul vechi nu e o precauție teoretică: o luptă resetată din
## butonul de test poate prinde o bară încă alunecând de la lovitura dinainte,
## iar tween-ul ăla ar continua să scrie în `value` peste ce punem noi aici.
func pune_bara_acum(bara: ProgressBar, maxim: float, valoare: float) -> void:
	if tweens_bare.has(bara) and tweens_bare[bara] != null and tweens_bare[bara].is_valid():
		tweens_bare[bara].kill()
	tweens_bare.erase(bara)
	bara.max_value = maxim
	bara.value = valoare


## Mai există vreun Obelisc pe care îl poți folosi acum?
## Nu e același lucru cu „am PA": poți avea 2 PA și toate Obeliscurile blocate.
func mai_ai_ce_face() -> bool:
	if pa < COST_OBELISC:
		return false
	for index in range(loadout.size()):
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
## `scena` vine din fișa disciplinei (`discipline.gd`). Lupta nu știe CE fel de puzzle e —
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
	if not panoul_e_pe_ecran:
		panoul_e_pe_ecran = true
		zona_puzzle.custom_minimum_size.x = 0.0
		zona_puzzle.modulate.a = 0.0
	# Antetele se rescriu ACUM, nu după animație: panoul deja „există" pentru
	# container, deci coloanele au început să se îngusteze în cadrul ăsta.
	actualizeaza_ui()
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
	if not panoul_e_pe_ecran:
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
	# ...și abia DUPĂ el punem numele la loc. Callback-urile se execută în
	# ordinea în care le-ai pus, deci aici `panoul_e_pe_ecran` e deja `false`
	# și `antetele_sunt_stramte()` răspunde „nu". Un `actualizeaza_ui()` mai
	# devreme ar fi scris numele peste un panou care încă se retrage.
	tween.tween_callback(actualizeaza_ui)


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
	panoul_e_pe_ecran = false
	zona_puzzle.custom_minimum_size.x = 0.0
	# Se stinge din transparență, NU din `visible`: nodul rămâne în așezare, cu
	# lățime zero. Vezi `panoul_e_pe_ecran` pentru de ce contează diferența.
	# Opacitatea se pune la loc pe 1 la deschidere, nu aici — aici starea de
	# repaus e „nu se vede".
	zona_puzzle.modulate.a = 0.0


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
		_inapoi_la_harta()
		return
	if tura_se_incheie:
		return   # tura se încheie deja singură — fără două ture de inamic
	tura_inamicului()


## Tura inamicului. Funcția asta NU mai știe cum atacă inamicul — doar
## întreabă arhetipul. `match` = un lanț de if-uri, dar citibil: pentru
## fiecare arhetip nou adaugi o ramură, fără să atingi restul buclei.
func tura_inamicului() -> void:
	match arhetip():
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
	var daune := daune_inamic()
	loveste_jucatorul(daune)
	scrie_in_jurnal("%s ataca pentru %d." % [nume_inamic(), daune])


## Arhetipul „Grabnic", acum CHIAR folosit: e Lăncierul. Ceasul urcă cu 1 pe
## tură; când se umple, lovește tare și o ia de la capăt. Lupta devine o cursă:
## îl dobori la timp, sau încasezi?
##
## Cifrele nu mai sunt constante de fișier, ci coloane în `INAMICI`: un al
## doilea Grabnic, cu alt ceas și altă lovitură, e un rând în tabel. Codul de
## aici rămâne exact cum e.
func _tura_grabnic() -> void:
	ceas_inamic += 1
	if ceas_inamic >= ceas_max():
		ceas_inamic = 0
		var daune := daune_inamic()
		loveste_jucatorul(daune)
		scrie_in_jurnal("CEASUL S-A UMPLUT! %s loveste pentru %d." % [nume_inamic(), daune])
	else:
		scrie_in_jurnal("%s se incarca (%d/%d)." % [nume_inamic(), ceas_inamic, ceas_max()])


## O singură funcție prin care trec TOATE daunele către jucător.
## Mai târziu, scutul se scade într-un singur loc — aici.
func loveste_jucatorul(daune: int) -> void:
	# maxi() = maximul a două int-uri. Îl folosim ca PV să nu scadă sub 0.
	pv_jucator = maxi(pv_jucator - daune, 0)
	figura_jucator.loveste(daune)


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

	# Recompensa se calculează ȘI se plătește aici, înainte de panou: panoul doar
	# CITEȘTE lista de linii pe care o primește. Dacă ar calcula-o el, cifra de pe
	# ecran și cifra din tezaur ar fi două socoteli diferite, care pot ajunge să
	# nu mai fie egale — exact felul de bug pe care nu-l vezi luni de zile.
	#
	# Lista rămâne goală la înfrângere, iar panoul își ascunde singur secțiunea.
	var recompensa: Array[Dictionary] = []

	if victorie:
		# Raportul întâi, răsplata după. Ordinea contează doar pentru citit:
		# „ce-ai făcut" e cauza, „cât iei" e urmarea.
		#
		# Un singur apel cu un dicționar, în loc de patru funcții: când lupta va
		# avea a cincea statistică, semnătura nu se schimbă.
		Expeditie.inregistreaza_lupta({
			"cel_mai_lung_lant": cel_mai_lung_lant,
			"critice": critice_totale,
			"daune": pv_max_inamic,
		})
		recompensa = acorda_recompensa()
		scrie_in_jurnal("VICTORIE! Inamicul a cazut in runda %d." % runda)
		scrie_in_jurnal(text_recompensa_jurnal(recompensa))
		# Monedele nu trec prin `acorda_recompensa()`: ele nu intră în tezaur, ci
		# în expediție, și au fost deja adăugate de `inregistreaza_lupta()`. Aici
		# doar SPUNEM, fiindcă o resursă care crește fără să anunțe e o resursă
		# pe care jucătorul n-o descoperă decât din greșeală.
		var monede_nod := int(fisa_nod["monede"])
		if monede_nod > 0:
			scrie_in_jurnal("Ai gasit %d Monede (ai %d pentru magazin)." % [
				monede_nod, Expeditie.monede])
		Sunet.reda_verdict(Sunet.Verdict.VICTORIE)
	else:
		scrie_in_jurnal("SAH MAT. Ai pierdut in runda %d." % runda)
		Sunet.reda_verdict(Sunet.Verdict.INFRANGERE)

	# Sunetul și panoul, în același cadru. `_arata_verdictul()` e o funcție
	# obișnuită, fără `await` — deci nu se așteaptă nimic între apelul de sunet
	# de mai sus și linia asta: verdictul se aude și se vede împreună. Dacă
	# vreodată pui aici o animație de intrare, ține apelul lipit de sunet, ca
	# să nu se desprindă unul de altul.
	_arata_verdictul(victorie, recompensa)

	buton_incheie_tura.text = "Inapoi pe harta"
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
func _arata_verdictul(victorie: bool, recompensa: Array[Dictionary] = []) -> void:
	# Defalcarea, înainte de titlu și text: așa panoul e complet în clipa în care
	# devine vizibil, fără un cadru în care rândurile s-ar așeza sub ochii tăi.
	_construieste_recompensa(recompensa)

	if victorie:
		verdict_titlu.text = "VICTORIE"
		verdict_titlu.modulate = CULOARE_VICTORIE
		verdict_text.text = "%s a cazut in runda %d.\nAi incheiat lupta cu %d / %d PV." % [
			nume_inamic(), runda, pv_jucator, pv_max_jucator
		]
		# „Continua", nu „Lupta din nou": după victorie drumul merge înainte.
		# Când apare harta de expediție, butonul te duce la nodul următor.
		buton_verdict.text = "Inapoi pe harta"
	else:
		verdict_titlu.text = "INFRANGERE"
		verdict_titlu.modulate = CULOARE_INFRANGERE
		# Oglinda textului de victorie: aceeași structură, cealaltă direcție.
		# A doua frază spune cât de aproape ai fost — „mai avea 3 PV" e un motiv
		# să reîncerci, „mai avea 28" spune că trebuie schimbat ceva, nu repetat.
		verdict_text.text = "%s te-a doborat in runda %d.\nMai avea %d / %d PV." % [
			nume_inamic(), runda, pv_inamic, pv_max_inamic
		]
		# NU „Luptă din nou". Înfrângerea nu se reia: PV-ul a ajuns zero, deci
		# expediția s-a încheiat și harta o să spună asta pe față, cu tot cu
		# sumar. Un buton care ar promite o reluare ar minti.
		buton_verdict.text = "Vezi sumarul"

	panou_verdict.visible = true
	# Focus pe buton: se poate apăsa și cu Enter/Space, fără să cauți mouse-ul.
	buton_verdict.grab_focus()


# ─────────────────────────────────────────────────────────────
# RECOMPENSE
#
# Trei funcții, cu trei treburi care nu se amestecă:
#   `calculeaza_recompensa()` socotește și nu schimbă nimic — poți s-o chemi de
#       zece ori la rând fără nicio urmare (util când vei vrea să arăți o
#       previzualizare, sau în teste).
#   `acorda_recompensa()` chiar plătește în tezaur și întoarce ce-a plătit.
#   `_construieste_recompensa()` doar DESENEAZĂ lista primită.
#
# Despărțirea asta e regula de aur a fișierului, aplicată încă o dată: cine
# socotește nu desenează, cine desenează nu socotește. De-aia cifra din panou nu
# poate ajunge niciodată alta decât cifra din tezaur — e aceeași listă.
# ─────────────────────────────────────────────────────────────

## Defalcarea recompensei, ca listă de linii „etichetă → cât și din ce resursă".
##
## E o LISTĂ și nu un total, din același motiv pentru care cardul de inamic e o
## listă: vreau să văd DE CE am primit atât. Un număr singur nu învață pe nimeni
## nimic; patru rânduri îmi arată ce s-a plătit și, mai ales, ce n-a fost plătit.
##
## Fiecare linie își spune ȘI resursa. Azi toate patru zic „Fragmente", deci pare
## o coloană degeaba — dar exact ea face ca a doua resursă (o relicvă, o relație,
## ce-o fi) să fie o linie în plus aici, nu o rescriere a panoului.
func calculeaza_recompensa() -> Array[Dictionary]:
	var linii: Array[Dictionary] = []

	linii.append({
		"eticheta": "Victorie",
		"resursa": Tezaur.Resursa.FRAGMENTE,
		"cantitate": FRAGMENTE_VICTORIE,
	})

	# PROCENT, nu PV brut. Dacă am plăti PV-ul direct, valoarea liniei ar depinde
	# de cât de mare e regele în lupta asta — iar când pv_max_jucator va crește
	# din upgrade-uri de cetate, recompensele ar crește singure, pe furiș.
	# Așa, „am terminat cu jumătate din viață" plătește la fel în orice luptă.
	var procent_pv := float(pv_jucator) / float(pv_max_jucator)
	linii.append({
		"eticheta": "PV ramas (%d / %d)" % [pv_jucator, pv_max_jucator],
		"resursa": Tezaur.Resursa.FRAGMENTE,
		# `roundi` = rotunjește și întoarce un întreg. Fără el am avea 6.67
		# Fragmente, iar resursele în virgulă nu se pot număra din priviri.
		"cantitate": roundi(procent_pv * FRAGMENTE_PV_INTREG),
	})

	linii.append({
		"eticheta": "Cel mai lung lant (×%d)" % cel_mai_lung_lant,
		"resursa": Tezaur.Resursa.FRAGMENTE,
		"cantitate": cel_mai_lung_lant * FRAGMENTE_PE_TREAPTA_LANT,
	})

	linii.append({
		"eticheta": "Lovituri critice (×%d)" % critice_totale,
		"resursa": Tezaur.Resursa.FRAGMENTE,
		"cantitate": critice_totale * FRAGMENTE_PE_CRITIC,
	})

	return linii


## Calculează ȘI plătește. Întoarce exact liniile plătite, ca panoul să arate
## fix ce a intrat în tezaur — nu o a doua socoteală care ar putea să difere.
func acorda_recompensa() -> Array[Dictionary]:
	var linii := calculeaza_recompensa()

	# UN NOD GREU PLĂTEȘTE MAI MULT, cu același multiplicator cu care lovește.
	# Un nod mai greu care ar da aceeași răsplată ca unul ușor n-ar fi o alegere,
	# ar fi o capcană pentru cine nu știe încă harta — iar jocul ăsta nu
	# pedepsește curiozitatea.
	#
	# Nicăieri aici nu scrie „Elită" sau „Boss": scrie „înmulțitorul nodului" și
	# „bonusul nodului". De-aia un tip de nod nou nu cere nicio linie în
	# funcția asta, doar un rând în `Expeditie.DATE_NOD`.
	var putere := float(fisa_nod["putere"])
	if putere > 1.0:
		for linie in linii:
			linie["cantitate"] = roundi(int(linie["cantitate"]) * putere)

	var bonus := int(fisa_nod["bonus"])
	if bonus > 0:
		linii.append({
			"eticheta": "%s infrant%s" % [
				String(fisa_nod["nume"]).to_upper(),
				"a" if tip_nod == Expeditie.Nod.ELITA else "",
			],
			"resursa": Tezaur.Resursa.FRAGMENTE,
			"cantitate": bonus,
		})

	# Prin EXPEDIȚIE, nu direct în tezaur. Ea le pune în amândouă locurile:
	# în averea permanentă și în socoteala runului, pe care o cere sumarul.
	# Două adăugiri separate ar fi însemnat două numere care pot ajunge să
	# difere — exact felul de bug pe care nu-l vezi luni de zile.
	for linie in linii:
		Expeditie.incaseaza(linie["resursa"], linie["cantitate"])
	return linii


## Adună liniile pe resurse: { Resursa.FRAGMENTE: 28 }.
## Folosită și de panou, și de jurnal — un singur loc în care se face suma.
func _totaluri(linii: Array[Dictionary]) -> Dictionary:
	var totaluri := {}
	for linie in linii:
		var resursa: int = linie["resursa"]
		totaluri[resursa] = totaluri.get(resursa, 0) + int(linie["cantitate"])
	return totaluri


## Un singur rând de jurnal, ca să poți reciti cât ai luat după ce închizi panoul.
func text_recompensa_jurnal(linii: Array[Dictionary]) -> String:
	var totaluri := _totaluri(linii)
	var bucati: Array[String] = []
	for resursa in totaluri:
		bucati.append("+%d %s (total: %d)" % [
			totaluri[resursa], Tezaur.nume(resursa), Tezaur.cat(resursa)
		])
	return "Rasplata: " + ", ".join(bucati) + "."


## DESENEAZĂ defalcarea în panoul de verdict. Nu socotește nimic: primește
## liniile gata făcute și le pune pe ecran, exact ca `construieste_card()`.
##
## Listă goală (adică înfrângere) = secțiunea dispare cu totul. Un „+0 Fragmente"
## după o înfrângere ar fi o palmă inutilă; jocul ăsta motivează prin curiozitate,
## nu prin pedeapsă.
func _construieste_recompensa(linii: Array[Dictionary]) -> void:
	# Ștergem rândurile luptei precedente. `remove_child` le scoate din socoteala
	# containerului IMEDIAT; `queue_free()` singur le-ar mai lăsa un cadru înăuntru,
	# iar panoul s-ar deschide o clipă cu două recompense una sub alta.
	for copil in verdict_recompense.get_children():
		verdict_recompense.remove_child(copil)
		copil.queue_free()

	verdict_recompense.visible = not linii.is_empty()
	if linii.is_empty():
		return

	var titlu := Label.new()
	titlu.text = "RASPLATA"
	titlu.modulate = CULOARE_RECOMPENSA_ETICHETA
	titlu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	verdict_recompense.add_child(titlu)

	for linie in linii:
		var cantitate: int = linie["cantitate"]
		verdict_recompense.add_child(_rand_recompensa(
			linie["eticheta"],
			"+%d" % cantitate,
			CULOARE_RECOMPENSA_VALOARE if cantitate > 0 else CULOARE_RECOMPENSA_ZERO,
			CULOARE_RECOMPENSA_ETICHETA if cantitate > 0 else CULOARE_RECOMPENSA_ZERO
		))

	# Linia de despărțire dinaintea totalului. `HSeparator` e un nod de interfață
	# gata făcut — o dungă orizontală care își ia singură culoarea din temă.
	verdict_recompense.add_child(HSeparator.new())

	# Câte un total per resursă, și cât ai în tezaur după lupta asta. Pe două
	# resurse vor fi două rânduri, fără nicio linie de cod în plus.
	var totaluri := _totaluri(linii)
	for resursa in totaluri:
		verdict_recompense.add_child(_rand_recompensa(
			Tezaur.nume(resursa),
			"+%d   (ai %d)" % [totaluri[resursa], Tezaur.cat(resursa)],
			CULOARE_RECOMPENSA_TOTAL,
			CULOARE_RECOMPENSA_TOTAL
		))


## Un rând de recompensă: eticheta la stânga, cifra la dreapta.
##
## Seamănă cu `_construieste_rand()` de la cardul de inamic, dar nu e același:
## acolo valoarea e un text lung care se înfășoară pe mai multe rânduri, aici e
## o cifră scurtă care are nevoie de culoare. Le-am fi putut uni printr-o funcție
## cu cinci argumente și două „dacă" — dar două funcții scurte, fiecare cu un
## singur scop, se citesc mai ușor decât una lungă care le face pe amândouă.
func _rand_recompensa(
	eticheta: String, valoare: String, culoare_valoare: Color, culoare_eticheta: Color
) -> HBoxContainer:
	var rand := HBoxContainer.new()

	var stanga := Label.new()
	stanga.text = eticheta
	stanga.modulate = culoare_eticheta
	stanga.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dreapta := Label.new()
	dreapta.text = valoare
	dreapta.modulate = culoare_valoare
	dreapta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	rand.add_child(stanga)
	rand.add_child(dreapta)
	return rand


## Butonul panoului de verdict. Amândouă drumurile duc în ACELAȘI loc — harta —
## fiindcă harta e cea care știe ce înseamnă fiecare: după victorie deschide
## nodurile următoare, după înfrângere încheie expediția și arată sumarul.
##
## Lupta NU decide asta. Ea nu știe dacă nodul ăsta era ultimul, și nici nu
## trebuie: singurul lucru pe care îl raportează e cât PV a mai rămas. Dacă
## ar decide ea, ar exista două locuri care socotesc „s-a terminat expediția?",
## iar al doilea s-ar înșela într-o zi.
func _pe_verdict_apasat() -> void:
	panou_verdict.visible = false
	_inapoi_la_harta()


## Predă PV-ul înapoi expediției și schimbă scena.
##
## PV-ul se scrie AICI, într-un singur loc, pe amândouă drumurile — și la
## victorie, și la înfrângere. Pus în `termina_lupta()`, ar fi trebuit scris de
## două ori; pus în două ramuri, ar fi fost uitat într-una.
func _inapoi_la_harta() -> void:
	Expeditie.seteaza_pv(pv_jucator)
	get_tree().change_scene_to_file(SCENA_HARTA)


## Readuce starea la valorile de start. Ca să testezi rapid, fără să dai F5.
func reseteaza_lupta() -> void:
	runda = 1

	# CINE ȘI CÂT DE GREU — din nodul de expediție, înainte de orice cifră.
	_alege_inamicul()

	# PV-UL NU SE REFACE ÎNTRE LUPTE. Se împrumută de la expediție așa cum a
	# rămas după nodul de dinainte, și se dă înapoi în `termina_lupta()`.
	# Asta e regula care transformă un șir de lupte într-o EXPEDIȚIE: fără ea,
	# fiecare nod ar fi un meci separat și drumul n-ar mai conta.
	pv_max_jucator = Expeditie.pv_max
	pv_jucator = Expeditie.pv
	# PE LOC, nu animat: vezi `pune_bara_acum()`. Bara trebuie să fie deja
	# corectă în PRIMUL cadru al luptei — cât PV ai e o stare moștenită, nu un
	# lucru care se întâmplă acum.
	pune_bara_acum(bara_pv_jucator, pv_max_jucator, pv_jucator)
	# Inamicul ales își aduce cifrele ACUM, o singură dată. De aici încolo lupta
	# citește variabilele, nu tabelul — deci nimic din ce se întâmplă în luptă
	# nu poate ajunge la datele de bază și nu le poate strica.
	# Cifrele trec prin multiplicatorul nodului: același Soldat, la o Elită,
	# are mai mult PV și lovește mai tare. `maxi(..., 1)` fiindcă un inamic cu
	# 0 PV ar fi deja mort, iar unul cu 0 daune n-ar fi un adversar.
	pv_max_inamic = _cu_puterea_nodului(int(inamic()["pv"]))
	pv_inamic = pv_max_inamic
	pune_bara_acum(bara_pv_inamic, pv_max_inamic, pv_inamic)
	# Ceasul pornește gol. Nu mai are bară de resetat: singurul lui martor pe
	# ecran e contorul „1/3" de lângă sabie, iar acela se rescrie din
	# `actualizeaza_ui()` ca orice alt text.
	ceas_inamic = 0
	lupta_terminata = false
	puzzle_activ = false
	tura_se_incheie = false
	disponibil_din.fill(0)   # toate Obeliscurile, libere din nou
	lant_daune = 0
	combo_corecte = 0
	cel_mai_lung_lant = 0
	critice_totale = 0
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

	# Colorarea inamicului ales, pusă pe toate înfățișările lui deodată.
	aplica_infatisarea()

	buton_incheie_tura.text = "Incheie tura"
	scrie_in_jurnal("%s intra in arena (%d PV)." % [nume_inamic(), pv_max_inamic])
	incepe_runda()


# ─────────────────────────────────────────────────────────────
# INAMICUL CURENT
#
# Șase funcții scurte, și toate răspund la aceeași întrebare pusă altfel:
# „ce scrie pe rândul lui din tabel?". Restul fișierului nu mai scrie niciodată
# `INAMICI[inamic_curent]["ceva"]` — cheamă una de aici.
#
# De ce contează: ziua în care un inamic va primi cifre modificate în timpul
# luptei (un bos care se înfurie, un modificator de generator), ele se schimbă
# ÎNTR-UN loc, aici. Cu tabelul citit direct din douăzeci de locuri, ar fi
# însemnat douăzeci de locuri de găsit — și al douăzeci și unulea, uitat.
# ─────────────────────────────────────────────────────────────

## Rândul din tabel al inamicului cu care lupți acum.
func inamic() -> Dictionary:
	return INAMICI[inamic_curent]


## Cât lovește inamicul, DUPĂ multiplicatorul nodului. Toate cele trei locuri
## care aveau nevoie de cifra asta (cele două ramuri de atac și cardul) trec
## acum pe aici — altfel Elita ar fi lovit ca un inamic obișnuit într-unul din
## ele, și nu s-ar fi văzut decât ca „parcă e prea ușoară".
func daune_inamic() -> int:
	return _cu_puterea_nodului(int(inamic()["daune"]))


func nume_inamic() -> String:
	return inamic()["nume"]


## CE FACE în tura lui. Numai `tura_inamicului()` are voie să se uite la asta
## ca să aleagă o ramură — restul codului întreabă lucruri concrete
## (`are_ceas()`, „câte daune"), nu arhetipul.
func arhetip() -> Arhetip:
	return inamic()["arhetip"]


## Are inamicul ăsta un ceas de încărcat?
##
## Întrebarea asta, și nu „e Grabnic?". Diferența pare de formă, dar nu e: cine
## se uită la ceas — azi doar rândul „Comportament" din card — are nevoie să
## știe dacă există o încărcare, nu CINE o face. Când va apărea al doilea arhetip cu ceas (un bos care își
## adună o descărcare, să zicem), interfața merge neatinsă — cu `== Arhetip.GRABNIC`
## scris prin patru locuri, ar fi trebuit corectată în toate patru.
func are_ceas() -> bool:
	return inamic().has("ceas")


## În câte runde se umple ceasul. 0 la inamicii fără ceas — cheia lipsește din
## rândul lor, iar `get` întoarce a doua valoare în loc să crape. Așa, un inamic
## fără ceas nu trebuie să scrie „ceas: 0" doar ca să tacă.
func ceas_max() -> int:
	return inamic().get("ceas", 0)


## Lovitura asta cade pe slăbiciunea lui?
##
## Se compară CHEIA disciplinei („cuvinte"), nu numele afișat („Cuvinte").
##
## Era invers, și comentariul de aici promitea că legătura se va strânge „când
## disciplinele vor deveni date". Au devenit (`autoload/discipline.gd`), deci
## s-a strâns: cheia e identificatorul stabil, numele afișat e liber să se
## schimbe. „Memorie" o să devină „Cultură generală" cândva — iar în ziua aia
## nicio vulnerabilitate nu trebuie să se strice în tăcere.
func e_vulnerabil(cheie: String) -> bool:
	return inamic()["vulnerabilitate"] == cheie


## Aceeași siluetă, altă lumină pe ea.
##
## `modulate` ÎNMULȚEȘTE culoarea peste pixelii existenți, deci nu e artă nouă:
## armura rămâne aceeași, dar una albăstrită citește „oțel rece", una arămie
## citește „cald, uzat". Pentru trei inamici timpurii e exact cât trebuie —
## principiul „prototip întâi, artă după" spune să nu desenez trei armuri până
## nu știu că cele trei comportamente merită desenate.
##
## Se pune pe FIGURILE inamicului, nu pe învelișul lor. Învelișul (`impact.gd`)
## își scrie singur `modulate` la fiecare lovitură și îl pune înapoi pe alb la
## final — colorarea pusă acolo ar fi ștearsă la prima lovitură încasată. Așa,
## cele două se înmulțesc cum trebuie: fulgerul aprinde figura colorată.
func aplica_infatisarea() -> void:
	var colorare: Color = inamic()["colorare"]
	for figura in figuri_inamic:
		figura.modulate = colorare


# ─────────────────────────────────────────────────────────────
# INTENȚIA TELEGRAFIATĂ A IEȘIT CU TOTUL
#
# Aici stăteau `inamicul_loveste_acum()`, `lovitura_grea()` și
# `text_intentie()` — trei funcții care răspundeau la o singură întrebare:
# „ce urmează să facă inamicul runda asta?". Răspunsul se vedea mai întâi în
# arenă (o sabie desenată și un număr), apoi, după ce sabia a ieșit, pe un rând
# din card. Acum nu se mai vede nicăieri, deci nu mai are cine să le cheme.
#
# Le-am șters, nu comentat: GDScript nu se plânge de o funcție nefolosită, iar
# o funcție care arată ca o unealtă bună și pe care n-o cheamă nimeni e mai rea
# decât una lipsă — o citești peste trei luni și crezi că afișarea ei există.
# Sunt în istoric, la un `git show` distanță, dacă intenția își găsește o casă
# mai bună (un contor discret pe bara de PV, un semn pe figură).
#
# CE RĂMÂNE DIN EA: rândul „Comportament" din card, mai jos. Acela spune regula
# („Ceasul se umple in 3 runde; la 3/3 loveste 6"), nu starea de acum. E mai
# puțin ajutor în mijlocul rundei, dar nu cere să fie actualizat la fiecare
# tură — și, spre deosebire de intenție, nu dispăruse niciodată de pe ecran.
# ─────────────────────────────────────────────────────────────


## Ce face inamicul, într-o frază. Folosită doar în card.
## Rândul „Comportament" din card. Regula generală o spune deja „Arhetip";
## aici scriem doar ce arhetipul NU-ți spune: cifrele exacte și condițiile.
## Dacă textul de aici ajunge să sune ca numele arhetipului, rândul e degeaba.
## Primește un INDEX, nu citește inamicul curent. Motivul: panoul de alegere îl
## cheamă pentru toți trei deodată, înainte să existe un „curent". O funcție
## care întreabă „cum se poartă inamicul ăsta?" merge pe orice rând din tabel;
## una care întreabă „cum se poartă inamicul MEU?" ar fi cerut o a doua funcție,
## aproape identică, pentru panou.
##
## CIFRELE TREC PRIN GREUTATEA NODULUI, ca și cele de pe bara de PV și ca cea de
## lângă sabie. Aici era o minciună: textul citea `date["daune"]` de-a dreptul
## din tabel, deci Spadasinul de la o Elită se prezenta cu „4 daune in fiecare
## tura" și lovea cu 6. Un card care spune altceva decât face lupta e mai rău
## decât niciun card — pe baza lui îți faci socoteala câte runde mai ai de trăit.
##
## Ceasul NU se înmulțește, fiindcă nici `ceas_max()` nu-l înmulțește: o Elită
## Grabnică lovește mai tare, nu mai des.
func text_comportament(index: int) -> String:
	var date: Dictionary = INAMICI[index]
	var daune := _cu_puterea_nodului(int(date["daune"]))
	match date["arhetip"]:
		Arhetip.ATAC_CONSTANT:
			return "%d daune in fiecare tura" % daune
		Arhetip.GRABNIC:
			return "Ceasul se umple in %d runde; la %d/%d loveste %d, apoi o ia de la capat" % [
				date["ceas"], date["ceas"], date["ceas"], daune
			]
	return "—"


## Slăbiciunea inamicului, scrisă pentru ochi. Liniuță dacă n-are — la fel ca
## modificatorii și rezistențele, ca rândurile cardului să arate la fel.
func text_vulnerabilitate(index: int) -> String:
	var cheie: String = INAMICI[index]["vulnerabilitate"]
	if cheie == "":
		return "—"
	# Pe ecran merge NUMELE, nu cheia. Tabelul ține „cuvinte", jucătorul
	# citește „Cuvinte" — catalogul e singurul care le leagă.
	return "%s (daune x%d)" % [Discipline.nume(cheie), MULTIPLICATOR_VULNERABILITATE]


## O listă de etichete, sau o liniuță dacă e goală.
func _lista_sau_liniuta(valori: Array[String]) -> String:
	return "—" if valori.is_empty() else ", ".join(valori)


## CONȚINUTUL CARDULUI, ca listă de rânduri „etichetă → valoare".
## Aici adaugi câmpuri noi: o linie în listă, și cardul le desenează singur.
## Nu atinge nimic din afișare — de asta e o listă de date, nu cod de UI.
func date_card_inamic() -> Array:
	var date := inamic()
	return [
		{"eticheta": "Factiune", "valoare": date["factiune"]},
		{"eticheta": "Arhetip", "valoare": NUME_ARHETIP[date["arhetip"]]},
		{"eticheta": "Comportament", "valoare": text_comportament(inamic_curent)},
		{"eticheta": "Puncte de viata", "valoare": "%d / %d" % [pv_inamic, pv_max_inamic]},
		{"eticheta": "Modificatori", "valoare": _lista_sau_liniuta(MODIFICATORI_INAMIC)},
		{"eticheta": "Vulnerabilitati", "valoare": text_vulnerabilitate(inamic_curent)},
		{"eticheta": "Rezistente", "valoare": _lista_sau_liniuta(REZISTENTE_INAMIC)},
	]


func _pe_card_inamic_apasat() -> void:
	construieste_card()
	card_inamic.visible = true


func _pe_inchide_card_apasat() -> void:
	card_inamic.visible = false


## Tasta I deschide și închide cardul inamicului.
##
## `_unhandled_key_input` (nu `_input`): primește tasta doar dacă n-a
## consumat-o nimeni dinainte — un câmp de text dintr-un puzzle viitor scrie
## „i" fără să deschidă cardul peste el.
##
## Aceeași tastă închide: un card deschis din greșeală se închide cu degetul
## rămas pe loc. Și cât e un puzzle pe ecran nu se deschide deloc — cardul ar
## acoperi întrebarea al cărei cronometru curge.
func _unhandled_key_input(eveniment: InputEvent) -> void:
	if not (eveniment is InputEventKey and eveniment.pressed and not eveniment.echo):
		return
	if eveniment.keycode != KEY_I:
		return
	if puzzle_activ and not card_inamic.visible:
		return
	card_inamic.visible = not card_inamic.visible
	if card_inamic.visible:
		construieste_card()
	get_viewport().set_input_as_handled()


## Click pe voal (adica oriunde in afara panoului) inchide cardul.
## Panoul e un PanelContainer, care oprește el clickurile dinauntru — asa ca
## aici ajung doar cele din afara lui.
func _pe_voal_card_apasat(eveniment: InputEvent) -> void:
	if eveniment is InputEventMouseButton 			and eveniment.button_index == MOUSE_BUTTON_LEFT 			and eveniment.pressed:
		card_inamic.visible = false


## Reconstruiește cardul de fiecare dată când se deschide, ca PV-ul să fie
## cel de acum, nu cel de la începutul luptei.
func construieste_card() -> void:
	card_titlu.text = nume_inamic()

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
	stanga.add_theme_font_size_override("font_size", 13)
	stanga.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dreapta := Label.new()
	dreapta.text = valoare
	dreapta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dreapta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dreapta.add_theme_font_size_override("font_size", 13)
	dreapta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Valoarea primește ceva mai mult decât eticheta: „Comportament" încape pe
	# un rând, fraza din dreptul lui nu. Fără asta, un card de 340 ar fi rupt
	# fiecare valoare lungă în patru rânduri și ar fi crescut la loc în sus.
	dreapta.size_flags_stretch_ratio = 1.6

	rand.add_child(stanga)
	rand.add_child(dreapta)
	return rand


# ─────────────────────────────────────────────────────────────
# CUM SE ALEGE INAMICUL — NU MAI E TREABA LUPTEI
#
# Aici era un panou cu trei rânduri, din care îți alegeai adversarul înainte de
# fiecare luptă. A dispărut, și nu fiindcă era prost scris: fiindcă harta de
# expediție face acum exact ce făcea el, o treaptă mai sus. Alegi un NOD, nodul
# spune cât e de greu, iar `_alege_inamicul()` traduce greutatea în adversar.
#
# Comentariul de atunci promitea: „când vine harta, dispare panoul, rămâne
# funcția". Exact asta s-a întâmplat — `reseteaza_lupta()` n-a trebuit
# schimbată deloc, doar cine o cheamă.
# ─────────────────────────────────────────────────────────────


# ─────────────────────────────────────────────────────────────
# AFIȘARE
# Regulă de aur: logica de sus NU atinge niciodată direct un Label.
# Ea schimbă doar variabilele de stare, apoi cheamă actualizeaza_ui().
# Un singur loc care desenează = imposibil să ai bara și textul desincronizate.
# ─────────────────────────────────────────────────────────────
## Sunt coloanele laterale strânse ca să facă loc întrebării?
##
## Panoul de puzzle se deschide ÎNTRE cele două figuri, iar `HBoxContainer`
## ia lățimea de la ele. Ce încape lejer în arena liberă — „BOSS LANCIERUL" —
## nu mai încape acolo: textul se lățea peste panou și acoperea un colț din
## întrebare. Atunci plăcuța se rezumă la singurul lucru pentru care te uiți
## într-acolo în mijlocul unui lanț: cifra de PV. Numele se ascunde, cifra
## rămâne — pe ambele coloane, după aceeași regulă.
##
## Întrebăm `panoul_e_pe_ecran`, NU `puzzle_activ`. Cele două nu se sting în
## același moment: `puzzle_activ` devine `false` când se DĂ comanda de
## retragere, iar panoul mai ocupă loc încă 0,55 s după aceea. Pe steagul de
## stare, numele ar fi reapărut peste un panou încă întins — exact bug-ul pe
## care îl reparăm. `panoul_e_pe_ecran` se stinge abia în
## `ascunde_panou_acum()`, deci e singurul care răspunde la întrebarea pusă:
## „mai e panoul pe ecran?".
func antetele_sunt_stramte() -> bool:
	return panoul_e_pe_ecran


func actualizeaza_ui() -> void:
	eticheta_runda.text = "RUNDA %d" % runda

	# Numele e tot un BUTON — click pe el deschide cardul —, dar acum duce DOAR
	# numele. Nu mai poartă nici indiciul („[i]" s-a mutat pe figură, vezi
	# `semn_inspectare.gd`), nici cifra de PV, care și-a luat rândul ei
	# dedesubt. Un rând care se îngusta odată cu coloana avea de dus trei
	# lucruri; acum duce unul.
	# „ELITA" / „BOSS" în fața numelui: același adversar, altă greutate. Trebuie
	# să se vadă în luptă, nu doar pe hartă — altfel cifrele mai mari par un bug.
	# Prefixul vine din tabel, deci un tip de nod nou se anunță singur.
	# Numele sunt scrise cu majuscule CHIAR ÎN TABEL, deci nu le mai urcăm aici:
	# un `to_upper()` peste ceva deja majuscul ascunde de unde vine forma.
	var prefix := ""
	if float(fisa_nod["putere"]) > 1.0:
		prefix = String(fisa_nod["nume"]).to_upper() + " "
	buton_inamic.text = "%s%s" % [prefix, nume_inamic()]
	# Cifra rămâne mereu; numele se dă la o parte când coloana se strânge —
	# vezi `antetele_sunt_stramte()`. Exact ca la rege, mai jos.
	buton_inamic.visible = not antetele_sunt_stramte()
	eticheta_pv_inamic.text = "%d/%d PV" % [pv_inamic, pv_max_inamic]
	anima_bara(bara_pv_inamic, pv_inamic)

	# SLĂBICIUNEA, scrisă deasupra numelui și lăsată acolo toată lupta.
	#
	# Nu e un secret de descoperit prin încercări: cerința de design e „afișată
	# vizibil ÎNAINTE de luptă". O vezi în panoul de alegere, o recitești în
	# card, și îți stă sub ochi cât joci — fiindcă e informația din care iese
	# decizia „pe ce Obelisc apăs acum", iar o decizie tactică luată din
	# memorie e doar o pedeapsă pentru cine a clipit.
	#
	# La inamicii fără slăbiciune eticheta DISPARE, nu scrie „niciuna": un rând
	# gol care spune „nu se aplică" e zgomot pe care ochiul îl citește oricum.
	var slabiciune: String = inamic()["vulnerabilitate"]
	eticheta_vulnerabil.visible = slabiciune != ""
	if eticheta_vulnerabil.visible:
		eticheta_vulnerabil.text = "VULNERABIL: %s  x%d" % [
			Discipline.nume(slabiciune), MULTIPLICATOR_VULNERABILITATE
		]

	# Aceeași regulă, simetric: coloana ta se îngustează odată cu cea a
	# inamicului, deci „REGELE (TU)" se dă și el la o parte cât ține întrebarea.
	# Cifra rămâne mereu — numele tău e informația pe care o știi deja.
	eticheta_pv_jucator.text = "%d/%d PV" % [pv_jucator, pv_max_jucator]
	eticheta_nume_jucator.visible = not antetele_sunt_stramte()
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

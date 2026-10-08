extends Node
## EXPEDIȚIA — tot ce ține o serie de lupte laolaltă.
##
## E autoload din exact motivul pentru care sunt și `Tezaur`, și `Sac`: o
## expediție trece prin mai multe SCENE (hartă → luptă → hartă → luptă…), iar
## tot ce ar fi ținut în oricare dintre ele ar dispărea la prima schimbare.
##
## ─────────────────────────────────────────────────────────────
## CUM E STRUCTURATĂ STAREA, ȘI DE CE AȘA
##
## Ăsta e fișierul care se va salva la pasul 8, deci forma lui contează mai
## mult decât codul din el. Trei reguli au decis tot ce urmează:
##
## 1. **STAREA E DATE, NU NODURI.** Nicăieri mai jos nu există o referință
##    către un Button, un Control sau o scenă. Harta e un Array de
##    dicționare; ecranul o DESENEAZĂ, dar nu o ține. Dacă starea ar fi
##    ținută în noduri de interfață, „salvează expediția” ar însemna
##    „salvează o bucată de scenă” — imposibil de scris în JSON și imposibil
##    de citit peste un an.
##
## 2. **TOTUL E TIP SIMPLU.** int, float, bool, String, Array, Dictionary.
##    Niciun `Color`, niciun `Vector2`, niciun `PackedScene`. Astea sunt
##    lucruri de DESENAT, nu de reținut — culoarea unei discipline se ia din
##    catalog, după cheie, în clipa desenării. Așa `spre_dictionar()` de la
##    final e o simplă copiere, nu o conversie cu douăzeci de cazuri.
##
## 3. **LEGĂTURILE SUNT CHEI TEXT ȘI INDICI, NU OBIECTE.** Loadout-ul ține
##    `["memorie", "logica"]`, nu fișele disciplinelor. Un nod ține `"spre":
##    [3, 4]`, nu nodurile următoare. Un save e o fotografie, iar o fotografie
##    nu poate conține obiecte vii.
##
## ─────────────────────────────────────────────────────────────
## CE SE SALVEAZĂ, PE TREI STRATURI
##
## Nu tot ce ține de joc are aceeași durată de viață, iar asta e prima decizie
## a oricărui save:
##
##   PERMANENT     — `Tezaur` (Fragmentele). Rămâne după ce expediția se
##                   încheie, oricum s-ar încheia. Nu e aici.
##   PE EXPEDIȚIE  — TOT ce e mai jos: harta, unde ești, PV-ul, loadout-ul,
##                   statisticile. Plus `Sac` (ce întrebări s-au pus deja) —
##                   de-aia `incepe()` cheamă `Sac.expeditie_noua()`.
##   PE LUPTĂ      — runda, PA, ceasul inamicului, lanțul. Trăiește în
##                   `lupta.gd` și moare cu lupta. Nu se salvează: dacă
##                   închizi jocul în mijlocul unei lupte, expediția se
##                   reia de la nodul ăla, nu din mijlocul turei 3.
##
## Despărțirea asta e ce face ca save-ul să fie o problemă mică mai târziu.

## Tipurile de nod. `enum` = nume pentru numere, ca să nu scrii cifre.
## Pe disc se scriu CHEI TEXT (vezi `DATE_NOD`), fiindcă valoarea unui enum e
## doar poziția lui în listă: un tip nou adăugat la mijloc ar muta numerele și
## un save vechi ar citi Odihna ca Eveniment.
enum Nod {
	LUPTA,       ## inamic obișnuit
	ELITA,       ## mai greu, răsplată mai mare
	ODIHNA,      ## singurul loc în care PV-ul se întoarce
	EVENIMENT,   ## placeholder: marcat pe hartă, fără conținut încă
	MAGAZIN,     ## singurul loc în care Monedele se transformă în ceva
	BOSS,        ## capătul drumului, mai greu decât o Elită
}

## FIȘA fiecărui tip de nod. Tabel, nu ramuri în cod: harta desenează de aici
## și nu conține niciun `if tip == ...`. Un tip nou (comoară, altar) e un rând
## în plus, plus ce face el la vizitare.
##
## CE ÎNSEAMNĂ FIECARE COLOANĂ:
##   cheie        — numele pe disc (vezi nota de la `enum Nod`)
##   nume         — ce scrie pe etichetă când survolezi nodul
##   descriere    — ce te așteaptă acolo, într-o propoziție
##   culoare      — HALOUL din spatele simbolului. Nu e decor: craniul Elitei
##                  și coiful Luptei sunt forme apropiate la 90 de pixeli, iar
##                  culoarea din spate e ce le desparte dintr-o privire.
##   putere       — cât de tare lovește inamicul de-acolo, ca înmulțitor peste
##                  cifrele lui din tabelul luptei
##   buget        — cât de SCUMP poate fi inamicul ales acolo (cine încape)
##   monede       — câte Monede cad la o victorie
##   bonus        — Fragmente în plus, o singură dată, pentru un nod greu
##
## „putere” și „buget” sunt două lucruri diferite, și merită două coloane:
## bugetul alege CINE apare (un Spadasin în loc de un Soldat), puterea îl umflă
## pe cel apărut. Un nod de Boss are nevoie de amândouă — cel mai scump adversar
## disponibil, și încă o dată pe-atât peste el.
const DATE_NOD := {
	Nod.LUPTA: {
		"cheie": "lupta", "nume": "Lupta",
		"descriere": "Un adversar obisnuit iti taie drumul.",
		"culoare": Color(0.96, 0.93, 0.86),
		"putere": 1.0, "buget": 1.0, "monede": 8, "bonus": 0,
	},
	Nod.ELITA: {
		"cheie": "elita", "nume": "Elita",
		"descriere": "Mai mult PV, lovituri mai grele — si o rasplata pe masura.",
		"culoare": Color(1.00, 0.62, 0.26),
		"putere": 1.6, "buget": 1.8, "monede": 16, "bonus": 12,
	},
	Nod.ODIHNA: {
		"cheie": "odihna", "nume": "Odihna",
		"descriere": "Singurul loc din expeditie in care regele isi revine.",
		"culoare": Color(1.00, 0.80, 0.52),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.EVENIMENT: {
		"cheie": "eveniment", "nume": "Eveniment",
		"descriere": "Un cufar incuiat. Cifrul nu e scris nicaieri — se deduce.",
		"culoare": Color(0.84, 0.82, 0.96),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.MAGAZIN: {
		"cheie": "magazin", "nume": "Magazin",
		"descriere": "Un negustor pe drum. Monedele stranse se schimba aici pe ajutor — doar pentru expeditia asta.",
		"culoare": Color(1.00, 0.86, 0.38),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.BOSS: {
		"cheie": "boss", "nume": "Boss",
		"descriere": "Capatul drumului. Mai greu decat orice Elita — si ultimul lucru dintre tine si sumar.",
		"culoare": Color(0.92, 0.30, 0.22),
		"putere": 2.3, "buget": 2.6, "monede": 30, "bonus": 30,
	},
}


## Fișa unui tip de nod, cu plasă de siguranță: un tip necunoscut (un save
## vechi, un enum umblat) întoarce fișa Luptei în loc să oprească jocul.
static func date_nod(tip: int) -> Dictionary:
	return DATE_NOD.get(tip, DATE_NOD[Nod.LUPTA])


# ─────────────────────────────────────────────────────────────
# REGULILE EXPEDIȚIEI
# ─────────────────────────────────────────────────────────────

## N-ul din „alege N din M”. M e `Discipline.cate()`.
## CLAUDE.md: „Numărul 3 e variabilă de reglat, nu presupunere.”
const DISCIPLINE_IN_LOADOUT := 3

## PV-ul regelui la pornirea expediției. NU se reface între lupte — doar la
## Odihnă. Asta e regula care transformă un șir de lupte într-o expediție:
## fără ea, fiecare nod ar fi un meci separat și drumul n-ar mai conta.
const PV_MAX := 15

## Cât recuperezi la un nod de Odihnă, ca fracțiune din maxim.
## Procent, nu cifră fixă: când PV_MAX va crește din upgrade-uri de cetate,
## odihna crește odată cu el, fără să umble nimeni la ea.
const ODIHNA_FRACTIUNE := 0.35

## DE UNDE VINE HARTA. ← comutatorul. O singură linie de schimbat:
##
##     const SURSA_HARTII := Sursa.DESENATA    planșa din `PLANSA_IMPLICITA` (activ)
##     const SURSA_HARTII := Sursa.GENERATA    panglica + straturi, ca înainte
##
## Cele două surse răspund la întrebări diferite, și de-aia coexistă în loc să
## se înlocuiască:
##
##   GENERATA  — o hartă nouă la fiecare sămânță, garantat fără încrucișări,
##               fiindcă geometria ei e demonstrată (vezi `harta.gd`). Nu poate
##               însă desena UN LOC anume.
##   DESENATA  — forma o pui tu, cu mâna, într-un fișier. În schimb, garanția se
##               mută de la demonstrație la VERIFICARE: `tools/verificari/verifica_plansa.gd`.
##
## Ce NU se schimbă între ele: tipurile nodurilor (Luptă, Elită, Magazin…) se
## trag din sămânță în amândouă cazurile, cu aceleași reguli. Planșa dă doar
## forma; conținutul rămâne al sămânței.
enum Sursa { GENERATA, DESENATA }
const SURSA_HARTII := Sursa.DESENATA

## Ce planșă se joacă, cât timp `SURSA_HARTII` e DESENATA.
const PLANSA_IMPLICITA := Plansa.DOSAR + "harta_01.json"

## Câte STRATURI are harta. Straturile hotărăsc numărul de noduri:
## primul și ultimul au câte unul, cele din mijloc câte `NODURI_PE_STRAT`.
##   7 straturi → 1 + 2·5 + 1 = 12 noduri
##   9 straturi → 1 + 2·7 + 1 = 16 noduri
##
## Cifrele astea au crescut de la 5-6 la 7-9 dintr-un motiv de DESEN, nu de
## dificultate: pe pergamentul întins pe toată fereastra, opt noduri arătau ca
## opt puncte răzlețe, nu ca un drum. Harta de referință are paisprezece, și
## abia la densitatea aia drumul începe să pară un TRASEU pe un teren.
##
## Dacă o expediție de 16 noduri se dovedește prea lungă pentru o sesiune de
## 15 minute, aici se taie — dar se taie știind că sub 12 noduri harta redevine
## un desen sărac.
const STRATURI_MIN := 7
const STRATURI_MAX := 9

## Sub atâtea noduri nu coborâm niciodată. E o PLASĂ, nu o regulă: astăzi
## `STRATURI_MIN` garantează deja 12, dar dacă mâine cineva scade straturile
## fără să se uite aici, generatorul adaugă straturi până iese numărul.
const NODURI_MINIME := 12

## Câte noduri are un strat din mijloc. Două = o alegere reală la fiecare pas,
## fără ca harta să devină un păienjeniș pe care nu-l mai citești dintr-o
## privire. Când va exista o expediție lungă, ăsta e numărul care crește.
const NODURI_PE_STRAT := 2

# ─────────────────────────────────────────────────────────────
# BUGETUL DE DIFICULTATE
#
# Fiecare nod primește un BUGET, care crește cu adâncimea. Azi el face două
# lucruri: alege tipul nodului și, mai târziu, spune luptei cât de tare poate
# fi inamicul. Mâine (pasul 10, generatorul de inamici) tot el va cumpăra
# modificatori: „+50% PV” costă atât, „lovește de două ori” costă atât.
#
# De ce un BUGET și nu un „nivel 1-2-3”: un număr continuu se poate împărți.
# Un nod de adâncime 4 cu buget 3,2 poate lua un inamic de 2 plus un
# modificator de 1, sau unul de 3 simplu. Un „nivel 2” nu poate cumpăra nimic,
# poate doar să fie.
#
# Scris acum, cât e ieftin, fiindcă e greu de introdus într-un generator care
# funcționează deja fără el.
# ─────────────────────────────────────────────────────────────
const BUGET_BAZA := 1.0
const BUGET_PE_ADANCIME := 0.55
# Multiplicatorul de buget al unui nod greu NU mai e o constantă aici: e
# coloana „buget” din `DATE_NOD`. Elita îl avea, Bossul avea nevoie de altul,
# iar două constante cu același rost sunt începutul unei a treia.

# ─────────────────────────────────────────────────────────────
# CÂTE NODURI DIN FIECARE TIP — proporții fixe, nu zaruri
#
# Aici stătea `PONDERI_NOD`: un tabel de probabilități, din care fiecare nod își
# trăgea tipul singur, cu o aruncare de zar, fără să știe nimic despre vecinii
# lui. Ponderile erau reglate frumos pe adâncime — Elita creștea spre final,
# Odihna la fel — și totuși ieșeau hărți proaste: Magazin după o singură luptă,
# două Odihne lipite, două Elite una lângă alta.
#
# Și nu era o reglare greșită, ci genul greșit de unealtă. O pondere răspunde la
# „cât de des vreau tipul ăsta?”. Plângerile de mai sus sunt despre cu totul
# altceva: „ce are voie să stea LÂNGĂ ce?” și „câte ies în total?”. Niciuna din
# cele două întrebări nu are cum să fie pusă unui zar aruncat per nod — zarul
# n-are nici vecini, nici memorie.
#
# Deci tipurile nu mai sunt trase, ci ÎMPĂRȚITE. Numărul din fiecare tip se
# hotărăște înainte să înceapă plasarea, iar plasarea trebuie să treacă un set
# de reguli de vecinătate. Sămânța rămâne stăpână pe UNDE cade fiecare, nu pe
# CÂTE sunt.
#
# Ce se câștigă, dincolo de plângerile reparate: o expediție are acum un profil
# garantat. Știi că ai exact două Magazine pe care să-ți planifici Monedele și
# exact trei Odihne pe care să-ți întinzi PV-ul. Cu ponderi, „câte Odihne am pe
# harta asta?” era o întrebare fără răspuns până la Boss.
# ─────────────────────────────────────────────────────────────

## CÂTE NODURI ARE HARTA DE REFERINȚĂ. Proporțiile de mai jos sunt scrise pentru
## ea; orice altă mărime le scalează (vezi `proportii()`).
const NODURI_DE_REFERINTA := 16

## REȚETA, pentru o hartă de `NODURI_DE_REFERINTA` noduri.
##
## Startul și Bossul nu sunt aici: ei nu se împart, sunt câte unul prin
## definiție. Lupta nu e nici ea aici, fiindcă e RESTUL — și asta e dinadins.
## Dacă ar avea și ea o cifră proprie, cele șase cifre ar trebui să dea exact
## suma nodurilor, iar la prima hartă de altă mărime una din ele ar ieși
## negativă. Cu Lupta ca rest, suma se închide singură.
##
## La 16 noduri iese: 1 Start, 1 Boss, 2 Elite, 3 Odihne, 2 Magazine,
## 3 Evenimente și 4 Lupte.
##
## „minim” e plasa pentru hărțile mici: sub el nu se coboară, oricât de tare ar
## scala. O expediție fără Magazin face Monedele o glumă proastă (era chiar
## motivul pentru care exista `_asigura_magazin()`, funcția de cârpit de dinainte);
## una fără Odihnă e o cursă de PV fără frână; una fără Elită n-are niciun vârf.
## Evenimentul n-are minim, fiindcă azi e doar marcat pe hartă — o expediție
## fără el nu pierde nimic ce se poate juca.
const PROPORTII := [
	{"tip": Nod.ELITA, "la_referinta": 2, "minim": 1},
	{"tip": Nod.ODIHNA, "la_referinta": 3, "minim": 1},
	{"tip": Nod.MAGAZIN, "la_referinta": 2, "minim": 1},
	{"tip": Nod.EVENIMENT, "la_referinta": 3, "minim": 0},
]

# ─────────────────────────────────────────────────────────────
# PRAGURILE DE ÎNCEPUT
#
# „Nu prea devreme” are două unități de măsură pe harta asta, și alegerea
# dintre ele nu e cosmetică.
#
# PAȘII sunt distanța pe hartă: câte noduri ai atins, orice ar fi fost ele.
# LUPTELE MINIME sunt câte noduri de Luptă sau Elită ai fost OBLIGAT să treci —
# cel mai ieftin drum de la Start până aici, socotind 1 pentru un nod de bătaie
# și 0 pentru restul.
#
# Un Magazin se măsoară în lupte, nu în pași: el vrea să apară după ce ai avut
# de unde strânge Monede, iar Monedele vin din lupte. Trei Evenimente la rând nu
# ți-au umplut punga, oricât de departe ar fi dus.
#
# O Odihnă se măsoară în pași, fiindcă ea nu-ți cere să fi câștigat ceva, ci să
# fi avut timp să pierzi ceva. La al doilea nod ești încă aproape de PV-ul plin,
# deci o Odihnă acolo e un nod irosit indiferent câte lupte au fost în el.
# ─────────────────────────────────────────────────────────────

## Câte lupte trebuie să ai în spate înainte de un Magazin.
const LUPTE_MINIME_MAGAZIN := 2

## Câte lupte trebuie să ai în spate înainte de o Elită.
##
## A fost cerut 3, și am scris 2 după o măsurătoare, nu dintr-o scăpare.
## Merită ținut minte de ce, fiindcă e o proprietate a FORMEI hărților, nu a
## cifrei: Startul e o Luptă, vecinii lui sunt Lupte (vezi regula), iar imediat
## după ei harta se despică deja în două brațe — amândouă la exact 2 lupte
## minime. Ca să urci un nod la 3, trebuie să pui un al treilea nod de bătaie pe
## FIECARE drum care ajunge la el, iar rețeta lasă doar 4 Lupte libere.
##
## Căutarea exhaustivă a confirmat-o: pe `harta_01` (1.663.200 de aranjamente
## posibile) și pe `harta_02` (25.225.200), pragul 3 dădea ZERO aranjamente
## valabile. Nu rar — imposibil. Toate celelalte reguli, luate împreună fără el,
## aveau soluții. La pragul 2: 28, respectiv 734 de aranjamente.
##
## Consecința de design, ca s-o vezi când te lovește: o Elită POATE cădea al
## treilea nod al expediției. Dacă vrei iar pragul 3, prețul nu e cifra de aici,
## ci rețeta — Evenimentele trebuie să scadă de la 3 la 1, ca Luptele să urce la
## 6 și să aibă cu ce gospodări brațele.
const LUPTE_MINIME_ELITA := 2

## La câți pași de Start poate apărea cea mai apropiată Odihnă.
const PASI_MINIMI_ODIHNA := 3

## Câte aranjări se încearcă până să ne dăm bătuți pe o sămânță.
##
## Nu e o limită de timp, ci o plasă împotriva buclei infinite: dacă regulile
## ajung vreodată să se bată cap în cap cu rețeta — pe o hartă nouă, sau după ce
## umbli la o cifră de mai sus — vreau un `push_error` cu numele regulii
## vinovate și o hartă jucabilă, nu un joc înghețat la pornirea expediției.
##
## Pe planșele de azi, media e 7 încercări (`harta_01`) și 23 (`harta_02`), cu
## maximul măsurat la 130 pe 500 de semințe. Marginea e de zece ori media, nu de
## două — dinadins: ziua în care o cifră de mai sus se schimbă, vreau ca harta
## să iasă mai greu, nu să nu mai iasă.
const INCERCARI_MAXIME := 200

## CE A PĂȚIT ULTIMA ATRIBUIRE DE TIPURI. Numai pentru unelte, nu pentru joc.
##
## Ține `{"incercari": int, "picate": {nume → de_câte_ori}}` de la ultima
## chemare a lui `_pune_tipurile()`. NU e stare de expediție și NU se salvează:
## e un martor lăsat în urmă, ca `tools/verificari/verifica_tipuri.gd` să poată spune cât
## de greu a ieșit harta.
##
## De ce aici și nu socotit din nou în unealtă: unealta ar fi trebuit să refacă
## pas cu pas ce trage generatorul din rng ca să nimerească aceleași
## sub-semințe. Ar fi mers — până în ziua în care generatorul trage un număr în
## plus, iar unealta ar fi raportat în continuare cifre, doar că ale altei hărți.
## Un martor care minte e mai rău decât niciun martor.
##
## `static`, ca tot ce e în jurul lui: generarea e statică dinadins (vezi antetul
## secțiunii), deci nu are o instanță în care să-și lase însemnările.
static var ultima_aranjare := {}

# ─────────────────────────────────────────────────────────────
# MONEDELE ȘI PUTERILE — economia care moare cu expediția
#
# Fragmentele sunt AVERE: rămân în `Tezaur` după ce runul se termină, oricum
# s-ar termina, și vor plăti clădirile cetății. Monedele sunt cu totul altceva:
# se strâng din lupte, se cheltuie la Magazin, și se evaporă la finalul
# expediției.
#
# De ce două monede și nu una: fiindcă întrebarea „ce cumpăr ACUM, cu ce am pe
# drumul ăsta" e o decizie complet diferită de „ce-mi construiesc în cetate
# peste zece runuri". Dacă ar fi aceeași resursă, a doua ar înghiți-o mereu pe
# prima — orice leu cheltuit pe un ajutor temporar ar fi un leu furat de la
# ceva permanent, deci n-ai cumpăra niciodată nimic pe drum.
#
# Monedele NU intră în `Tezaur`. Tezaurul e, prin definiție, ce supraviețuiește
# expediției; o resursă care se resetează n-are ce căuta acolo.
# ─────────────────────────────────────────────────────────────

## Ce se vinde la Magazin. Tabel, ca tot restul: o putere nouă e un rând.
##
## „efect” e cheia pe care o citește codul; restul e ce citește jucătorul.
## Puterile INSTANTANEE (PV, PV maxim) își fac treaba în clipa cumpărării și
## sunt trecute în istoric. Cele DURABILE („pa”) rămân în `puteri` și sunt
## întrebate de luptă la fiecare rundă — de-aia lista se salvează.
##
## Prețurile pornesc de la ce aduce un nod: o Luptă dă 8 Monede, o Elită 16.
## Deci „fiertura” e aproape un nod de luptă, iar „pana” e trei. Vrei ca
## alegerea de la Magazin să coste ceva, altfel nu e o alegere.
const PUTERI := [
	{
		"cheie": "pana", "nume": "Pana de otel", "cost": 24, "efect": "pa",
		"descriere": "+1 PA in fiecare runda, pana la capatul expeditiei.",
	},
	{
		"cheie": "zale", "nume": "Zale ferecate", "cost": 16, "efect": "pv_max",
		"cantitate": 4,
		"descriere": "+4 PV maxim, si tot atatia acum.",
	},
	{
		"cheie": "fiertura", "nume": "Fiertura calda", "cost": 9, "efect": "pv",
		"cantitate": 6,
		"descriere": "+6 PV pe loc. Nimic pe termen lung.",
	},
]

# ─────────────────────────────────────────────────────────────
# EVENIMENTUL: LACĂTUL
#
# Nodul de Eveniment deschide un cufăr cu cifru (`scenes/cifru/`). Tot ce
# hotărăște expediția despre el e aici, în date: ce NIVEL are lacătul și cât
# plătește. Ecranul hărții nu socotește nimic — întreabă `lacat_la()` și
# deschide scena.
#
# ── DE CE MONEDE, ȘI NU FRAGMENTE
#
# Granița dintre cele două e scrisă mai sus: Fragmentele sunt averea care
# rămâne după expediție, Monedele sunt ce ai pe drumul ăsta. Un lacăt care ar
# plăti în Fragmente ar deveni o sursă de progres PERMANENT complet ruptă de
# luptă — ai avansa în meta-joc rezolvând puzzle-uri care n-au nicio legătură
# cu loadout-ul ales.
#
# Plătit în Monede, Evenimentul devine în schimb o decizie de HARTĂ: „iau
# brațul cu cufărul, ca să-mi ajungă de Pana de otel când ajung la Magazin?”.
# Asta e exact ce lipsea unui nod care până acum nu făcea nimic.
#
# ── DE CE ZERO LA EȘEC
#
# Orice sumă fixă pe eșec s-ar putea strânge FĂRĂ SĂ JOCI: apeși „Deschide” de
# trei ori la întâmplare, în cinci secunde, și iei banii. Un joc de antrenament
# mental n-are voie să aibă o recompensă a cărei cale cea mai rapidă e să nu
# gândești.
#
# Iar consolarea la eșec există deja, și e cea potrivită: cufărul îți ARATĂ
# codul pe roți. Pleci știind răspunsul. Plătești cu Monedele pe care nu le-ai
# luat — nu cu PV, nu cu tura, nu cu timp.
# ─────────────────────────────────────────────────────────────

## Un rând pe nivel de lacăt. Nivelul e INDICELE + 1, ca în
## `GeneratorCifru.NIVELURI` — acolo e definit ce înseamnă un nivel (ce notă
## cere, ce alegere, câte egalități), aici doar cât plătește.
##
## CIFRELE, cu reperele lângă care au fost alese: o Luptă dă 8 Monede, o Elită
## 16; la Magazin fiertura costă 9, zalele 16, pana 24.
##
##   nivel 1 →  6  sub o Luptă: o roată îți e dăruită, sudată pe cifra bună
##   nivel 2 → 10  cât o Luptă și ceva — nu riști PV, dar plătești cu timp
##   nivel 3 → 14  sub o Elită; e nodul care te poate ține chiar cinci minute
##
## Trei Evenimente rezolvate fac ~30 de Monede, adică o Pană, dintr-un venit
## total de ~94 pe hartă. Deci merită să ocolești după cufere, fără să fie
## obligatoriu — exact greutatea pe care vrei s-o aibă o alegere de drum.
##
## Sunt un tabel, nu trei constante, ca reglarea de după primele partide jucate
## să fie o coloană de numere, nu o vânătoare prin fișier.
const LACAT := [
	{"nivel": 1, "monede": 6},
	{"nivel": 2, "monede": 10},
	{"nivel": 3, "monede": 14},
]

## Cu ce se amestecă sămânța nodului ca să iasă sămânța lacătului.
##
## De ce nu se folosește `nod["samanta"]` direct: nodul ar putea găzdui mâine
## și un al doilea eveniment (o fântână, un altar), iar amândouă ar porni din
## exact același număr. Un amestec cu o constantă proprie desparte lucrurile
## acum, cât e gratis. Numerele sunt prime, ca la `_sub_samanta()` — un
## înmulțitor cu factori comuni ar putea trimite semințe diferite în același loc.
const AMESTEC_LACAT := 1000003
const ADAOS_LACAT := 7919

# ─────────────────────────────────────────────────────────────
# STAREA (tot ce se salvează)
# ─────────────────────────────────────────────────────────────

## Emis când orice se schimbă: PV, poziție, statistici. Cârligul pentru harta
## care trebuie redesenată după ce te întorci dintr-o luptă.
signal s_a_schimbat

## E o expediție în desfășurare? `false` înseamnă „ești în meniu / la sumar”.
var activa := false

## Sămânța din care s-a generat harta. SE SALVEAZĂ, și ăsta e tot rostul ei:
## cu aceeași sămânță iese exact aceeași hartă, deci un bug raportat ca
## „expediția 12345 se blochează la nodul 6” e reproductibil pe loc.
var samanta := 0

## PE CE PLANȘĂ se joacă: calea fișierului, sau "" pentru o hartă generată.
##
## E STARE, nu constantă, și ăsta e tot rostul: `SURSA_HARTII` spune ce se
## alege la pornirea unei expediții NOI, dar o expediție deja pornită trebuie să
## se deseneze pe planșa pe care a pornit — inclusiv după un save reîncărcat
## peste o lună, când comutatorul o fi fost mutat de zece ori.
##
## Text, deci serializabil. Ecranul hărții întreabă câmpul ăsta, nu constanta:
## un singur adevăr, ținut într-un singur loc.
var plansa := ""

## Harta: un Array de dicționare, fiecare cu forma
##   { "id": 3, "adancime": 2, "coloana": 0, "tip": Nod.LUPTA,
##     "buget": 2.1, "samanta": 88123, "spre": [5, 6] }
##
## Pe o hartă DESENATĂ mai apare un câmp, "reper": id-ul text al nodului din
## planșă („S”, „C3”). E firul care leagă nodul de desen — poziția LUI nu se
## ține aici, fiindcă un `Vector2` n-are ce căuta în starea care se salvează
## (vezi regula 2 din antet). Ecranul deschide aceeași planșă și caută reperul.
##
## „spre” ține INDICI, nu noduri. Un nod care și-ar ține vecinii ca obiecte ar
## fi un graf de referințe încrucișate — imposibil de scris în JSON fără să-l
## desfaci oricum în indici.
##
## „spre” E SCRIS CU UN SINGUR SENS, DAR SE CITEȘTE CU DOUĂ. Câmpul spune cine a
## TRAS drumul, fiindcă așa îl produc și generatorul, și planșa desenată, și așa
## se salvează. Cine POATE MERGE pe el e altă întrebare, și are alt răspuns: un
## drum se poate lua în amândouă sensurile. Traducerea se face într-un singur
## loc, `vecini()`, și nicăieri altundeva — dacă vezi „spre” citit direct
## pentru navigare, e un bug.
##
## „samanta” e a nodului, nu a hărții: lupta de la nodul 6 își alege inamicul
## din ea, deci alege ACELAȘI inamic de fiecare dată când reiei expediția —
## fără ca expediția să fie nevoită să știe ce e un inamic.
var harta: Array[Dictionary] = []

## Unde ești. `-1` = încă n-ai intrat pe hartă (ești la loadout).
var pozitie := -1

## Drumul parcurs, în ordine. E ȘI istoricul pentru ecranul de sumar, ȘI
## sursa lui „ce noduri sunt în urma mea” pentru desenarea hărții.
var parcurse: Array[int] = []

## Cheile disciplinelor alese. Text, nu indici: vezi antetul lui
## `discipline.gd` pentru de ce.
var loadout: Array[String] = []

## PV-ul regelui, purtat de la un nod la altul. AICI, nu în `lupta.gd`, și
## asta e toată regula „PV-ul nu se reface între lupte”: lupta îl citește la
## început și îl scrie înapoi la sfârșit, dar nu-l deține.
var pv := 0
var pv_max := PV_MAX

## Ce a produs expediția asta. Separat de `Tezaur`, care ține totalul
## permanent: ecranul de sumar vrea să spună „ai câștigat 84 în expediția
## asta", nu „ai 312 cu totul”.
var fragmente_castigate := 0

## MONEDELE din expediția curentă. Se strâng din lupte, se cheltuie la Magazin,
## și mor odată cu runul — vezi nota de la `PUTERI`.
##
## Stau AICI, nu în `Tezaur`, exact fiindcă asta e granița dintre cele două
## fișiere: tezaurul e ce rămâne, expediția e ce trece.
var monede := 0

## Ce ai cumpărat la Magazin, în ordine. Chei text, cu dubluri permise: două
## „Pene de otel” înseamnă +2 PA, iar istoricul e și ce arată sumarul.
var puteri: Array[String] = []

## Cea mai bună performanță din run, pentru sumar. Un dicționar, nu patru
## variabile, din același motiv pentru care `Tezaur` e un dicționar: o
## statistică nouă e o cheie, nu un drum prin tot fișierul.
var recorduri := {
	"lupte_castigate": 0,
	"cel_mai_lung_lant": 0,
	"critice": 0,
	"daune_intr_o_lupta": 0,
}

## Cum s-a încheiat: "" cât e în desfășurare, "victorie" sau "infrangere" după.
var final := ""


func _ready() -> void:
	goleste()


# ─────────────────────────────────────────────────────────────
# CICLUL DE VIAȚĂ
# ─────────────────────────────────────────────────────────────

## Starea „nicio expediție”. Pornim de aici la fiecare joc nou.
func goleste() -> void:
	activa = false
	samanta = 0
	plansa = ""
	harta.clear()
	pozitie = -1
	parcurse.clear()
	loadout.clear()
	pv = PV_MAX
	pv_max = PV_MAX
	fragmente_castigate = 0
	monede = 0
	puteri.clear()
	recorduri = {
		"lupte_castigate": 0,
		"cel_mai_lung_lant": 0,
		"critice": 0,
		"daune_intr_o_lupta": 0,
	}
	final = ""


## Pornește o expediție nouă.
##
## `samanta_ceruta` = 0 înseamnă „alege una la întâmplare, dar ȚINE-O MINTE”.
## Asta e diferența dintre un joc care se poate depana și unul care nu se
## poate: fiecare expediție are o sămânță, chiar și cele „aleatoare”. Ca s-o
## reproduci, o citești din jurnal și o dai înapoi aici.
func incepe(discipline: Array[String], samanta_ceruta := 0) -> void:
	goleste()

	samanta = samanta_ceruta
	if samanta == 0:
		samanta = randi_range(1, 999999)

	loadout = _curata_loadout(discipline)
	plansa = _plansa_de_jucat()
	harta = genereaza_harta(samanta, plansa)
	pozitie = -1
	pv = pv_max
	activa = true
	final = ""

	# Întrebările redevin toate noi. Expediția e exact granița pe care `Sac` o
	# aștepta (vezi `autoload/sac.gd`): aici se naște noțiunea de „expediție
	# nouă", deci aici se cheamă.
	Sac.expeditie_noua()

	print("Expeditie noua: samanta %d, %d noduri, harta %s, loadout %s." % [
		samanta, harta.size(),
		plansa.get_file() if plansa != "" else "generata",
		", ".join(loadout)
	])
	s_a_schimbat.emit()


## CE PLANȘĂ SE JOACĂ ACUM — sau "" dacă harta se generează.
##
## Comutatorul spune ce vrem; funcția asta verifică dacă se poate. O planșă
## lipsă sau stricată NU are voie să oprească jocul: te întorci la generator,
## cu un avertisment în consolă. Un fișier de date prost scris e o greșeală de
## conținut, iar jocul trebuie să supraviețuiască greșelilor de conținut — altfel
## o virgulă uitată în JSON înseamnă „jocul nu mai pornește”.
static func _plansa_de_jucat() -> String:
	if SURSA_HARTII != Sursa.DESENATA:
		return ""
	var citita := Plansa.incarca(PLANSA_IMPLICITA)
	var eroare := String(citita["eroare"])
	if eroare == "":
		return PLANSA_IMPLICITA
	push_warning("Plansa %s nu se poate citi: %s. Harta se genereaza."
		% [PLANSA_IMPLICITA, eroare])
	return ""


## Intră în nodul cu indicele dat. Cheamă-l DOAR cu un nod din `accesibile()`.
func intra_in_nod(id: int) -> void:
	if id < 0 or id >= harta.size():
		push_warning("Expeditie: nod inexistent %d." % id)
		return
	pozitie = id
	parcurse.append(id)
	s_a_schimbat.emit()


## Încheie expediția. `victorie` = ai ajuns la capăt; altfel PV-ul a ajuns 0.
##
## NU golește starea: ecranul de sumar are nevoie de ea ca s-o poată arăta.
## Golirea vine abia când pornește următoarea expediție (`incepe()` cheamă
## `goleste()` pe prima linie). Regula generală: o stare se șterge când începe
## următoarea, nu când se termină cea de dinainte — altfel n-ai ce afișa
## între ele.
func incheie(victorie: bool) -> void:
	activa = false
	final = "victorie" if victorie else "infrangere"
	s_a_schimbat.emit()


# ─────────────────────────────────────────────────────────────
# NAVIGAREA
# ─────────────────────────────────────────────────────────────

## Nodul în care ești acum. Dicționar gol dacă n-ai intrat în niciunul.
func nod_curent() -> Dictionary:
	if pozitie < 0 or pozitie >= harta.size():
		return {}
	return harta[pozitie]


## TOATE NODURILE LEGATE DE `id`, în amândouă sensurile.
##
## Aici se întâmplă tot ce e nou în navigare, și merită spus încet.
##
## „spre” e scris cu UN SINGUR SENS, și așa rămâne: generatorul îl scrie așa
## (strat → strat), planșa îl scrie așa („de_la”/„la”), save-ul îl salvează așa.
## Formatul nu se atinge — o planșă desenată acum șase luni și un save vechi
## trebuie să se citească mâine la fel.
##
## Dar un drum DESENAT pe pergament n-are săgeată. Dacă din K pleacă o linie
## către C3, linia aia se vede exact la fel stând în C3 — iar un jucător care o
## vede și n-o poate lua nu descoperă o regulă, ci crede că e un bug. Și avea
## dreptate: harta minte, nu el.
##
## Deci sensul unic nu se șterge din DATE, ci se ignoră la CITIRE, într-un
## singur loc: aici. Nimic altceva din joc nu mai citește „spre” ca să
## NAVIGHEZE — nici `accesibile()`, nici BFS-ul până la Boss.
##
## Desenul îl citește mai departe, dar pune altă întrebare: „ce linii există pe
## hartă?”, la care sensul chiar e răspunsul bun — fiecare drum trebuie desenat
## o dată, nu de două ori. Ce STARE are linia (parcursă, deschisă) se întreabă
## acolo în amândouă sensurile; vezi `harta.gd::_muchii()`.
func vecini(id: int) -> Array[int]:
	return vecinii_din(harta, id)


## ACELAȘI LUCRU, DAR PE O HARTĂ CARE NU E ÎNCĂ A NIMĂNUI.
##
## `static`, deci se poate chema pe un Array de noduri proaspăt construit, în
## timpul generării, înainte ca vreo expediție să existe. De-aia e despărțită de
## `vecini()` de mai sus, care e doar ea aplicată pe harta curentă.
##
## Despărțirea are un singur motiv, și e cel din jurnalul de progres: regulile
## de atribuire a tipurilor se sprijină TOATE pe „cine e vecin cu cine”, iar
## dacă generatorul ar fi avut propria lui citire a lui „spre”, ar fi existat
## două definiții ale cuvântului „vecin” în același fișier. Una s-ar fi
## schimbat într-o zi, cealaltă nu, iar harta ar fi trecut o verificare pe care
## jocul n-o respectă. O regulă verificată pe alt graf decât cel jucat e mai
## rea decât nicio regulă.
static func vecinii_din(noduri: Array[Dictionary], id: int) -> Array[int]:
	var lista: Array[int] = []
	if id < 0 or id >= noduri.size():
		return lista

	for id_brut in noduri[id].get("spre", []):
		var inainte := int(id_brut)
		if not inainte in lista:
			lista.append(inainte)

	# Al doilea sens: cine are un drum CĂTRE mine. E o căutare prin toată harta,
	# nu un index ținut minte dinainte, și asta e o alegere: harta are
	# paisprezece noduri, deci costul e zero, pe când un index trebuie ținut în
	# acord cu datele la fiecare generare și la fiecare save reîncărcat. Un
	# index desincronizat e un bug tăcut; o căutare de paisprezece pași nu e
	# nimic.
	for nod in noduri:
		var alt := int(nod["id"])
		if alt == id or alt in lista:
			continue
		for id_brut in nod.get("spre", []):
			if int(id_brut) == id:
				lista.append(alt)
				break

	# Ordonată, ca lista să nu depindă de ordinea în care se nimeresc scrise
	# drumurile în fișier. Două hărți identice ca formă trebuie să dea aceleași
	# opțiuni, în aceeași ordine.
	lista.sort()
	return lista


## VECINĂTĂȚILE TUTUROR NODURILOR, socotite o dată.
##
## `vecinii_din()` costă o plimbare prin toată harta. Regulile de mai jos întreabă
## de vecini de câteva mii de ori pe expediție (200 de încercări × 9 reguli × 16
## noduri), deci aici se socotesc o dată și se dau mai departe ca listă.
##
## Indexul din Array E chiar id-ul nodului — asta ține numai fiindcă id-ul unui
## nod e, prin construcție, poziția lui în listă (vezi antetul lui `harta`).
static func _vecinatati(noduri: Array[Dictionary]) -> Array:
	var toate: Array = []
	for i in range(noduri.size()):
		toate.append(vecinii_din(noduri, i))
	return toate


## În ce noduri poți intra ACUM.
##
## La început (`pozitie == -1`) sunt toate nodurile de adâncime 0 — adică
## intrarea pe hartă. Intrarea NU trece prin regulile de mai jos: dacă harta e
## atât de stricată încât nici din Start nu se ajunge la Boss, vreau să pot
## intra și să văd cu ochii mei ce e stricat, nu un ecran pe care nu se poate
## apăsa nimic. Aia e treaba verificatorului de planșe, nu a jucătorului.
##
## După ce ai intrat, un vecin (în AMÂNDOUĂ sensurile, vezi `vecini()`) e o
## opțiune doar dacă trece de două reguli:
##
##   1. NU E DEJA PARCURS. Un nod jucat e tăiat definitiv — asta e ce ține în
##      frâu mersul înapoi. Fără regula asta, doi vecini ar fi o buclă în care
##      te-ai putea plimba la nesfârșit; cu ea, harta tot se consumă la fiecare
##      pas, doar că nu mai e obligatoriu să se consume spre dreapta.
##
##   2. DIN EL SE MAI AJUNGE LA BOSS, pe un drum care nu trece prin noduri deja
##      parcurse. Asta e regula fără de care tot restul ar fi o capcană: cu
##      mersul înapoi permis, te poți băga într-un braț al hărții din care
##      singura ieșire e chiar nodul pe care tocmai l-ai ars. Pe `harta_01`,
##      o simulare cu alegeri la întâmplare se înfunda în 59% din rulări dacă
##      regula asta lipsea (vezi `tools/verificari/verifica_drumuri.gd`).
##
##      De ce se REFUZĂ opțiunea, în loc să se detecteze înfundarea când s-a
##      produs: fiindcă o înfundare nu se poate repara. Când ai băgat de seamă
##      că ești blocat, mutarea greșită e cu cinci noduri în urmă, iar singurul
##      lucru pe care ți l-ar mai putea oferi jocul e „ai pierdut, din motive
##      care nu țin de tine”. Un drum care se închide ÎNAINTE să intri pe el nu
##      e o pedeapsă; e chiar felul în care harta rămâne o hartă.
##
## Bossul n-are opțiuni: acolo se termină expediția, chiar dacă drumul pe care
## ai venit are acum și el un al doilea sens. Vezi `la_capat()`.
func accesibile() -> Array[int]:
	var lista: Array[int] = []
	if pozitie < 0:
		for nod in harta:
			if int(nod["adancime"]) == 0:
				lista.append(int(nod["id"]))
		return lista

	if int(nod_curent().get("tip", -1)) == Nod.BOSS:
		return lista

	for id in vecini(pozitie):
		if id in parcurse:
			continue
		if _pasi_la_boss(id) < 0:
			continue
		lista.append(id)
	return lista


## Ai terminat drumul?
##
## Înainte întrebarea era „n-am unde merge”, și era destulă: graful mergea
## într-un singur sens, deci singurul nod fără ieșire era Bossul. Acum Bossul
## ARE vecini — cel puțin nodul din care ai venit — așa că „n-am unde merge” ar
## fi devenit fals chiar în clipa victoriei, iar expediția ar fi continuat pe
## lângă Boss.
##
## Deci capătul se numește pe nume: ești la Boss. Verificarea veche rămâne pe
## urmă, ca plasă pentru o hartă stricată — dacă `accesibile()` e goală înainte
## de Boss, expediția se încheie oricum, în loc să te lase într-un ecran mort.
func la_capat() -> bool:
	if pozitie < 0:
		return false
	if int(nod_curent().get("tip", -1)) == Nod.BOSS:
		return true
	return accesibile().is_empty()


## `adancime_maxima()` A DISPĂRUT de aici, și merită spus de ce, fiindcă e genul
## de funcție care pare nevinovată.
##
## Avea doi apelanți, amândoi în antetul hărții, amândoi ca să scrie „din câte
## noduri". Pe harta generată răspunsul era corect: toate traseele aveau exact
## câte un nod pe strat. Pe o planșă desenată, aceeași funcție ar fi răspuns „cel
## mai depărtat nod de Start" — un număr care ARATĂ ca lungimea drumului și nu e.
##
## Puteam s-o las, cu un comentariu de avertisment. Dar o funcție nefolosită al
## cărei nume minte e o capcană pusă pentru mine peste șase luni. Ce răspunde
## acum la aceeași nevoie e `pasi_pana_la_boss()`, de mai jos, care e adevărată
## pe orice hartă.


## Care nod e Bossul. `-1` dacă n-are (n-ar trebui să se întâmple).
##
## Se caută după TIP, nu după poziția în listă. Pe harta generată Bossul e
## ultimul nod și s-ar fi putut lua așa; pe o planșă desenată, „ultimul din
## listă" și „capătul drumului” sunt două lucruri care se nimeresc să coincidă,
## iar codul n-are voie să se sprijine pe o coincidență.
func id_boss() -> int:
	for nod in harta:
		if int(nod["tip"]) == Nod.BOSS:
			return int(nod["id"])
	return -1


## CÂȚI PAȘI MAI SUNT PÂNĂ LA BOSS, pe cel mai scurt drum.
##
## Înlocuiește vechiul „nodul 4 din 12” din antet, și motivul e că întrebarea
## veche n-are răspuns pe o hartă desenată. Pe harta generată toate traseele
## aveau exact atâtea noduri câte straturi, deci „din 12” era adevărat oricum ai
## fi mers. Pe o planșă, un traseu are 7 noduri și altul 9 — iar un antet care
## ar scrie „din 9” cât mergi pe drumul de 7 ar minți cu fiecare pas.
##
## „La cel puțin 3 pași” e adevărat pe orice hartă, pe orice drum. Pe harta
## generată dă exact numărul vechi (straturi rămase), deci nu s-a pierdut nimic
## din informație — s-a pierdut doar presupunerea că toate drumurile sunt egale.
##
## Tot un BFS, ca la adâncimi, dar pornit din nodul CURENT și mergând prin
## `vecini()`, nu prin „spre”: dacă poți merge înapoi pe un drum, atunci și
## scurtătura înapoi contează la „cât mai am”. Înainte de intrarea pe hartă
## (`pozitie == -1`) pornește din prima intrare.
func pasi_pana_la_boss() -> int:
	var pornire := pozitie
	if pornire < 0:
		var intrari := accesibile()
		if intrari.is_empty():
			return 0
		pornire = intrari[0]
	return maxi(_pasi_la_boss(pornire), 0)


## CÂȚI PAȘI SUNT DE LA `pornire` PÂNĂ LA BOSS, ocolind nodurile deja parcurse.
## `-1` înseamnă „nu se mai ajunge deloc” — și ăsta e răspunsul de care are
## nevoie `accesibile()` ca să nu-ți ofere o fundătură.
##
## Două lucruri fac funcția asta să nu fie un BFS oarecare:
##
##   NODURILE PARCURSE SUNT ZIDURI, nu doar „deja văzute”. Un drum care ar trece
##   prin ele nu se poate merge, deci nu se poate socoti. De-aia se pun în
##   `vazut` ÎNAINTE de căutare: BFS-ul nu le va deschide niciodată.
##
##   `pornire` E SCUTIT de regula de sus. Nodul în care stai chiar ACUM e
##   parcurs (`intra_in_nod()` îl pune acolo în clipa în care intri), și totuși
##   de acolo pleci. Scutirea se face punându-l în `vazut` explicit, după
##   ceilalți: se marchează ca deschis, nu ca zid.
##
## Se merge prin `vecini()`, deci în amândouă sensurile — altfel funcția ar
## răspunde la altă întrebare decât cea pe care o pune jocul.
func _pasi_la_boss(pornire: int) -> int:
	var tinta := id_boss()
	if tinta < 0 or pornire < 0 or pornire >= harta.size():
		return -1
	if pornire == tinta:
		return 0

	var vazut := {}
	for id in parcurse:
		vazut[int(id)] = true
	vazut[pornire] = true

	var pasi := {pornire: 0}
	var coada: Array[int] = [pornire]
	var i := 0
	while i < coada.size():
		var aici: int = coada[i]
		i += 1
		for urmator in vecini(aici):
			if vazut.has(urmator):
				continue
			vazut[urmator] = true
			pasi[urmator] = int(pasi[aici]) + 1
			if urmator == tinta:
				return int(pasi[urmator])
			coada.append(urmator)
	return -1


# ─────────────────────────────────────────────────────────────
# PV — o singură ușă, ca daunele din luptă
# ─────────────────────────────────────────────────────────────

## Scrie PV-ul întors din luptă. Lupta ține o copie cât se luptă (ca să nu
## emită un semnal la fiecare lovitură), apoi o predă aici, o dată.
func seteaza_pv(valoare: int) -> void:
	pv = clampi(valoare, 0, pv_max)
	s_a_schimbat.emit()


## Odihna. Întoarce cât s-a recuperat DE FAPT, ca ecranul să poată scrie
## „+5 PV” fără să facă el socoteala și fără să poată ajunge la alt număr.
func odihneste() -> int:
	var inainte := pv
	pv = mini(pv + ceili(pv_max * ODIHNA_FRACTIUNE), pv_max)
	s_a_schimbat.emit()
	return pv - inainte


func e_doborat() -> bool:
	return pv <= 0


# ─────────────────────────────────────────────────────────────
# REZULTATUL UNEI LUPTE
# ─────────────────────────────────────────────────────────────

## Ce raportează lupta după o victorie. Un singur apel, cu un dicționar, în
## loc de cinci funcții: când lupta va avea a șasea statistică, semnătura nu
## se schimbă.
func inregistreaza_lupta(raport: Dictionary) -> void:
	recorduri["lupte_castigate"] = int(recorduri["lupte_castigate"]) + 1
	# `maxi` fiindcă astea sunt RECORDURI, nu totaluri: „cel mai lung lanț din
	# expediție" e cel mai lung dintre lupte, nu suma lor.
	recorduri["cel_mai_lung_lant"] = maxi(
		int(recorduri["cel_mai_lung_lant"]), int(raport.get("cel_mai_lung_lant", 0)))
	recorduri["daune_intr_o_lupta"] = maxi(
		int(recorduri["daune_intr_o_lupta"]), int(raport.get("daune", 0)))
	# Criticele se ADUNĂ: aici întrebarea e „câte ai dat în tot runul”, nu
	# „care a fost cea mai bună luptă”. Două statistici, două feluri de a
	# aduna — de-aia stau într-un tabel și nu într-o buclă care le tratează la fel.
	recorduri["critice"] = int(recorduri["critice"]) + int(raport.get("critice", 0))

	# MONEDELE cad aici, nu în luptă, și nu e o chestiune de comoditate: ăsta e
	# singurul loc din tot jocul care știe ȘI că s-a câștigat o luptă, ȘI la ce
	# fel de nod. Lupta ar fi trebuit să întrebe harta ce nod e ca să afle cât
	# plătește — adică să repete o socoteală care se face oricum aici.
	castiga_monede(int(date_nod(int(nod_curent().get("tip", Nod.LUPTA)))["monede"]))
	s_a_schimbat.emit()


## Fragmentele intră ȘI în tezaurul permanent, ȘI în socoteala expediției.
## Un singur loc care face amândouă, ca să nu poată ajunge să difere.
func incaseaza(resursa: Tezaur.Resursa, cantitate: int) -> void:
	if cantitate <= 0:
		return
	Tezaur.adauga(resursa, cantitate)
	if resursa == Tezaur.Resursa.FRAGMENTE:
		fragmente_castigate += cantitate
	s_a_schimbat.emit()


# ─────────────────────────────────────────────────────────────
# MAGAZINUL
# ─────────────────────────────────────────────────────────────

## Fișa unei puteri, după cheie. Dicționar gol dacă nu există — apelantul
## verifică cu `is_empty()`, în loc să primească `null` și să crape două
## funcții mai încolo.
static func putere(cheie: String) -> Dictionary:
	for rand in PUTERI:
		if String(rand["cheie"]) == cheie:
			return rand
	return {}


## Poți cumpăra puterea asta ACUM? Două condiții, nu una.
##
## Prima e evidentă: să ai Monedele. A doua s-a văzut abia la prima probă —
## „Fiertura calda” (+6 PV) se putea cumpăra cu PV-ul plin, lua 9 Monede și
## răspundea „+0 PV”. Nu era un bug de cod; era un bug de vitrină. Un magazin
## n-are voie să-ți vândă nimic sub formă de ceva.
func pot_cumpara(cheie: String) -> bool:
	var fisa := putere(cheie)
	if fisa.is_empty() or monede < int(fisa["cost"]):
		return false
	return _are_efect(fisa)


## Ar schimba puterea asta ceva, în starea de acum?
##
## Doar vindecarea poate fi degeaba (PV plin). Un PV maxim în plus e mereu bun,
## iar un PA în plus la fel — de-aia funcția răspunde „da” pentru orice efect
## despre care n-are motiv să creadă altceva, în loc să ceară un rând nou în
## tabel pentru fiecare putere viitoare.
static func _are_efect_pentru(fisa: Dictionary, pv_acum: int, pv_maxim: int) -> bool:
	if String(fisa["efect"]) == "pv":
		return pv_acum < pv_maxim
	return true


func _are_efect(fisa: Dictionary) -> bool:
	return _are_efect_pentru(fisa, pv, pv_max)


## De ce nu poți cumpăra, într-un cuvânt — ca butonul stins să spună singur
## ce-i lipsește. "" înseamnă „poți”.
func motiv_refuz(cheie: String) -> String:
	var fisa := putere(cheie)
	if fisa.is_empty():
		return "nu exista"
	if not _are_efect(fisa):
		return "PV plin"
	if monede < int(fisa["cost"]):
		return "iti mai trebuie %d" % (int(fisa["cost"]) - monede)
	return ""


## Cumpără. Întoarce textul de arătat jucătorului („+6 PV”) sau ”" dacă n-a
## mers — un singur apel care ȘI plătește, ȘI aplică, ȘI spune ce s-a
## întâmplat. Trei apeluri separate ar fi însemnat că se poate plăti fără să se
## aplice nimic, iar ăla e exact bugul pe care nu-l observi decât ca jucător.
func cumpara(cheie: String) -> String:
	if not pot_cumpara(cheie):
		return ""

	var fisa := putere(cheie)
	monede -= int(fisa["cost"])
	puteri.append(cheie)

	# Efectele instantanee se consumă ACUM. Cele durabile n-au nimic de făcut
	# aici: ele trăiesc în `puteri` și sunt întrebate de luptă, la fiecare
	# rundă, prin `bonus_pa()`.
	var urmare := ""
	match String(fisa["efect"]):
		"pv":
			var inainte := pv
			pv = mini(pv + int(fisa["cantitate"]), pv_max)
			urmare = "+%d PV. Acum %d / %d." % [pv - inainte, pv, pv_max]
		"pv_max":
			pv_max += int(fisa["cantitate"])
			pv += int(fisa["cantitate"])
			urmare = "+%d PV maxim. Acum %d / %d." % [
				int(fisa["cantitate"]), pv, pv_max]
		"pa":
			# „Cu cât mai mult”, nu „câte cu totul”: PA-ul de bază e al luptei
			# (`PA_PE_RUNDA`), iar expediția n-are de ce să-l știe.
			urmare = "De acum, +%d PA in fiecare runda." % bonus_pa()

	s_a_schimbat.emit()
	return urmare


## Câte PA în plus dai în fiecare rundă, din puterile cumpărate.
##
## Se NUMĂRĂ, nu se ține un contor separat: lista de puteri e adevărul, iar un
## al doilea număr care ar trebui să fie mereu egal cu ea e un al doilea număr
## care într-o zi n-o să mai fie.
func bonus_pa() -> int:
	var spor := 0
	for cheie in puteri:
		var fisa := putere(cheie)
		if not fisa.is_empty() and String(fisa["efect"]) == "pa":
			spor += 1
	return spor


## Numele puterilor cumpărate, pentru sumar. Cu dubluri: „Pana de otel ×2”.
func puteri_pe_scurt() -> String:
	if puteri.is_empty():
		return "-"
	var cate := {}
	for cheie in puteri:
		cate[cheie] = int(cate.get(cheie, 0)) + 1
	var bucati: Array[String] = []
	for cheie in cate:
		var nume := String(putere(cheie).get("nume", cheie))
		bucati.append(nume if cate[cheie] == 1 else "%s x%d" % [nume, cate[cheie]])
	return ", ".join(bucati)


# ─────────────────────────────────────────────────────────────
# LACĂTUL UNUI NOD
# ─────────────────────────────────────────────────────────────

## TOT ce trebuie să știe cineva despre lacătul de la un nod, într-un apel:
##   { "nivel": 2, "samanta": 88123456, "monede": 10 }
##
## O singură funcție, și nu trei (una pentru nivel, una pentru sămânță, una
## pentru plată), fiindcă cele trei sunt un singur răspuns: „ce lacăt e aici?”.
## Trei funcții ar fi însemnat trei apeluri din hartă și trei locuri în care se
## poate uita unul.
##
## Dicționar gol pentru un id care nu există — apelantul verifică `is_empty()`,
## ca la `putere()`. Nu întrebăm dacă nodul e chiar de tip Eveniment: funcția
## răspunde la „ce lacăt ar fi aici”, iar cine deschide lacătul știe deja de ce.
## Un `if tip == EVENIMENT` aici ar însemna că un viitor „Lacăt” pus pe alt tip
## de nod (o Elită cu cufăr) ar primi un dicționar gol fără niciun motiv.
func lacat_la(id: int) -> Dictionary:
	if id < 0 or id >= harta.size():
		return {}
	var nod := harta[id]
	var nivel := nivel_lacat(int(nod["adancime"]), adancimea_bossului())
	return {
		"nivel": nivel,
		# Sămânța NODULUI, amestecată — vezi `AMESTEC_LACAT`. E aceeași sursă
		# din care lupta își alege inamicul (`lupta.gd`: `rng.seed =
		# int(nod["samanta"])`), deci jocul are UN singur mecanism pentru
		# „de unde își ia un nod conținutul", nu două.
		#
		# Reproductibilitatea cerută iese de la sine: `nod["samanta"]` se trage
		# o dată, la generarea hărții, din sămânța expediției — și se SALVEAZĂ
		# odată cu nodul. Aceeași expediție, reluată, dă același lacăt.
		"samanta": int(nod["samanta"]) * AMESTEC_LACAT + ADAOS_LACAT,
		"monede": int(LACAT[nivel - 1]["monede"]),
	}


## CÂT DE ADÂNC E BOSSUL. `0` dacă harta n-are Boss (n-ar trebui).
##
## Nu e „adâncimea maximă din hartă", și diferența e chiar motivul pentru care
## funcția asta există iar `adancime_maxima()` a fost ștearsă (vezi nota de la
## `la_capat()`): pe o planșă desenată de mână, cel mai depărtat nod de Start și
## capătul drumului sunt două lucruri care doar se nimeresc să coincidă.
## Lungimea drumului e a Bossului, fiindcă drumul se termină la el.
func adancimea_bossului() -> int:
	var id := id_boss()
	if id < 0:
		return 0
	return int(harta[id]["adancime"])


## CE NIVEL ARE LACĂTUL DE LA ADÂNCIMEA ASTA — drumul împărțit în treimi.
##
## `static` și pură: primește două numere, întoarce un număr. Nu atinge harta,
## deci se poate verifica headless pe adâncimi inventate, fără expediție.
##
## ── DE CE TREIMI DIN ADÂNCIMEA BOSSULUI, ȘI NU ADÂNCIMI FIXE
##
## „Adâncimea 4 ⇒ nivelul 3" e adevărat pe planșele de azi (Bossul stă la 6) și
## devine fals în ziua în care desenezi o hartă mai lungă: adâncimea 4 ar fi
## atunci mijlocul drumului, iar nivelul cel mai greu ar apărea la jumătate.
## Fracțiunea de drum rămâne adevărată pe orice planșă.
##
## ── DE CE ARITMETICĂ ÎNTREAGĂ
##
## Comparația firească ar fi `adancime / float(boss) <= 1.0 / 3.0`. Pe Bossul de
## la 6, adâncimea 2 dă 0,33333… în amândouă părțile — două numere care ar
## TREBUI să fie egale, scrise cu virgulă. Uneori sunt, uneori nu, și atunci
## nodul sare o bandă de dificultate fără ca nimeni să poată spune de ce.
## Înmulțite, comparația e între numere întregi și răspunsul e mereu același.
##
## ── DE CE FIECARE MARGINE CADE SPRE AFARĂ
##
## Un nod care stă EXACT pe o treime intră în banda dinspre capătul de hartă cel
## mai apropiat: cel de la o treime în banda 1, cel de la două treimi în banda 3.
## Regula e simetrică, și nu din dragoste de simetrie — cele două benzi de la
## capete sunt cele înguste în practică, iar marginile le lărgesc pe amândouă.
##
## Cât de înguste, măsurat cu `tools/verificari/verifica_eveniment.gd` pe cele două planșe:
##
##   BANDA 1 — adâncimea 1 e mereu o Luptă (regula „vecinii startului sunt
##   lupte"), deci Evenimentele încep de la 2. Dacă marginea de jos ar cădea în
##   sus, nivelul 1 — singurul cu o roată sudată, cel care te învață ce e un
##   lacăt — n-ar apărea niciodată.
##
##   BANDA 3 — pe `harta_01` există UN SINGUR nod la adâncimea 5, iar acela e
##   luat mereu de Odihna de dinaintea Bossului (`_regula_boss_cu_odihna_vecina`).
##   Cu marginea de sus căzând în jos, nivelul 3 ieșea de 0 ori din 200 de
##   semințe pe chiar planșa care se joacă. Cu ea căzând în sus, banda prinde și
##   adâncimea 4, unde stau patru noduri.
##
## Amândouă poveștile spun același lucru: pe o hartă adevărată, capetele drumului
## au puține noduri libere, iar mijlocul are multe. O împărțire care ar da
## marginile mijlocului ar lăsa nivelurile de la capete fără loc.
##
## Cum iese pe planșele de azi (Bossul la 6) și pe una lungă (Bossul la 8):
##
##   boss 6:  adâncime 1,2 → nivel 1 · 3 → nivel 2 · 4,5 → nivel 3
##   boss 8:  adâncime 1,2 → nivel 1 · 3,4,5 → nivel 2 · 6,7 → nivel 3
static func nivel_lacat(adancime: int, adancime_boss: int) -> int:
	# O hartă fără Boss, sau cu Bossul în Start: nu există „fracțiune de drum",
	# deci nu ghicim. Cel mai blând nivel, și jocul merge înainte.
	if adancime_boss <= 0:
		return 1
	if 3 * adancime <= adancime_boss:
		return 1
	if 3 * adancime >= 2 * adancime_boss:
		return 3
	return 2


## Monedele câștigate în afara unei lupte (azi: un lacăt deschis).
##
## Trece pe aici, și nu direct pe `monede += n`, dintr-un singur motiv: semnalul.
## Antetul hărții scrie Monedele, iar el se redesenează la `s_a_schimbat`. O
## adunare făcută pe lângă funcția asta ar fi un număr crescut pe care nu l-ai
## vedea crescând.
func castiga_monede(cantitate: int) -> void:
	if cantitate <= 0:
		return
	monede += cantitate
	s_a_schimbat.emit()


# ─────────────────────────────────────────────────────────────
# GENERAREA HĂRȚII
#
# Totul de aici trece printr-un `RandomNumberGenerator` cu sămânță pusă de
# mână — NU prin `randi()` global. Diferența e tot ce contează: `randi()`
# depinde de câte numere a cerut restul jocului înainte, deci aceeași sămânță
# ar da hărți diferite după o luptă mai lungă. Un generator propriu nu aude
# nimic din afară.
# ─────────────────────────────────────────────────────────────

## Construiește harta din sămânță. `static` fiindcă nu atinge starea: îi dai o
## sămânță, îți dă noduri. Așa se poate testa fără să pornești o expediție.
##
## `cale_plansa` gol = harta se generează, ca înainte. Altfel, FORMA vine din
## fișier și doar conținutul din sămânță. Parametrul are o valoare implicită ca
## apelurile vechi (verificarea headless) să meargă nemodificate.
static func genereaza_harta(samanta_harta: int, cale_plansa := "") -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = samanta_harta
	if cale_plansa != "":
		return _harta_din_plansa(rng, Plansa.incarca(cale_plansa))
	return _harta_generata(rng)


static func _harta_generata(rng: RandomNumberGenerator) -> Array[Dictionary]:
	var straturi := rng.randi_range(STRATURI_MIN, STRATURI_MAX)
	# Plasa de la `NODURI_MINIME`: un strat din mijloc aduce `NODURI_PE_STRAT`
	# noduri, deci creștem straturile până iese numărul cerut. Bucla asta nu
	# face nimic azi (7 straturi dau deja 12) — e acolo ca să NU se poată
	# ajunge, dintr-o reglare de dificultate, la o hartă de opt puncte răzlețe.
	while 2 + (straturi - 2) * NODURI_PE_STRAT < NODURI_MINIME:
		straturi += 1

	var noduri: Array[Dictionary] = []
	# „Cine e pe stratul de dinainte” — avem nevoie de indicii lor ca să
	# tragem muchiile înapoi, după ce stratul nou e construit.
	var stratul_trecut: Array[int] = []

	for adancime in range(straturi):
		# Primul și ultimul strat au un singur nod: expediția pornește dintr-un
		# punct și se termină într-unul. Fără asta, „ai ajuns la capăt” ar fi
		# două capete diferite, iar finalul ar depinde de coloana pe care ai mers.
		var cate := NODURI_PE_STRAT
		if adancime == 0 or adancime == straturi - 1:
			cate = 1

		var stratul_nou: Array[int] = []
		for coloana in range(cate):
			var id := noduri.size()
			noduri.append({
				"id": id,
				"adancime": adancime,
				"coloana": coloana,
				# Tipul și bugetul se pun ABIA DUPĂ ce harta e întreagă, în
				# `_pune_tipurile()`. Aici n-ar avea cum: regulile de atribuire
				# vorbesc despre VECINI, iar la nodul ăsta jumătate din vecinii
				# lui încă nu există. Un tip pus acum ar fi tot o aruncare de zar
				# oarbă — exact ce s-a scos.
				"tip": Nod.LUPTA,
				"buget": 0.0,
				# Sămânța nodului, trasă din același rng: reproductibilă, dar
				# independentă de ce va cere lupta din ea.
				"samanta": rng.randi_range(1, 999999),
				"spre": [],
			})
			stratul_nou.append(id)

		if not stratul_trecut.is_empty():
			_leaga(rng, noduri, stratul_trecut, stratul_nou)
		stratul_trecut = stratul_nou

	# Structura, verificată o dată. NU intră în bucla de reîncercări din
	# `_pune_tipurile()`, și e important de ce: o reîncercare schimbă TIPURILE,
	# nu forma. Dacă forma e stricată, a doua sută de încercări e la fel de
	# stricată ca prima — deci asta nu e o regulă de respins, ci o greșeală de
	# raportat.
	_verifica_structura(noduri, _vecinatati(noduri), 0, noduri.size() - 1)
	_pune_tipurile(_samanta_lui(rng), noduri, 0, noduri.size() - 1)
	return noduri


## HARTA DINTR-O PLANȘĂ DESENATĂ: forma din fișier, conținutul din sămânță.
##
## Planșa dă nodurile și drumurile. Tot restul — ce tip e fiecare nod, ce buget
## are, ce sămânță — se trage aici, exact cu regulile de la harta generată.
##
## ─────────────────────────────────────────────────────────────
## CE REGULI DEPINDEAU DE STRAT, ȘI CUM SE TRADUC
##
## Pe harta generată, „stratul” era trei lucruri deodată: adâncimea, ordinea în
## listă, și capătul drumului. Pe o planșă se despart, iar fiecare regulă
## trebuie să spună pe care din ele se sprijină de fapt:
##
##   ADÂNCIMEA (cea mai scurtă distanță de la Start, vezi `Plansa.adancimi`)
##   rămâne ce era: ponderile tipurilor și bugetul se calculează din ea, cu
##   aceleași formule. Singura diferență e că nu mai e monotonă de-a lungul
##   fiecărui drum — o scurtătură poate duce la un nod mai puțin adânc decât cel
##   din care ai plecat.
##
##   INTRAREA nu mai e „adâncimea 0”, ci nodul `start` din fișier. Se nimerește
##   să fie același lucru (Startul e singurul la distanța 0 de el însuși), dar
##   regula e citită din fișier, nu dedusă.
##
##   CAPĂTUL nu mai e „ultimul strat”, ci nodul `boss` din fișier — și aici
##   diferența e reală: pe o ocolitoare lungă poate sta un nod mai adânc decât
##   Bossul. De-aia `_pune_tipurile()` primește id-ul Bossului, nu îl ghicește
##   din adâncime.
##
##   ORDINEA ÎN LISTĂ („ultimul nod e Bossul”) era o consecință a generării. Aici
##   se construiește dinadins: nodurile se pun în ordinea adâncimii, iar Bossul
##   se pune ULTIMUL, oricât de adânc ar fi. Nu e cosmetic — `id`-ul unui nod e
##   chiar indicele lui, deci ordinea asta e ce face „Bossul e ultimul nod” să
##   rămână adevărat pentru verificări și pentru orice save vechi.
##
##   COLOANA nu mai înseamnă „a câta bandă de pe panglică”, fiindcă nu mai e
##   nicio panglică. Devine rangul nodului în stratul lui, de sus în jos pe
##   desen — adică tot „a câta bandă”, doar măsurată pe hârtie. E folosită numai
##   la diagnostic; desenul se face din poziția din fișier.
static func _harta_din_plansa(
	rng: RandomNumberGenerator, plansa: Dictionary
) -> Array[Dictionary]:
	var adanc := Plansa.adancimi(plansa)
	var start := String(plansa["start"])
	var boss := String(plansa["boss"])

	# Locul fiecărui reper în fișier: departajarea nodurilor de pe același strat.
	# Așa, două noduri la aceeași adâncime rămân în ordinea în care le-ai scris,
	# deci fișierul se poate citi alături de harta din joc.
	var rang := {}
	for i in range(plansa["ordine"].size()):
		rang[String(plansa["ordine"][i])] = i

	var repere: Array[String] = []
	for reper_brut in plansa["ordine"]:
		var reper := String(reper_brut)
		if not adanc.has(reper):
			# Un nod la care nu se poate ajunge e un nod care n-o să fie jucat
			# NICIODATĂ. L-am putea desena oricum, dar atunci harta ar minți:
			# ar arăta un loc unde nu se poate merge. Îl sărim, și o spunem.
			push_warning("Plansa %s: la nodul %s nu se poate ajunge din start."
				% [plansa["cale"], reper])
			continue
		if reper != boss:
			repere.append(reper)
	repere.sort_custom(func(a, b):
		var da := int(adanc[a])
		var db := int(adanc[b])
		if da != db:
			return da < db
		return int(rang[a]) < int(rang[b]))
	if adanc.has(boss):
		repere.append(boss)
	else:
		push_warning("Plansa %s: la Boss nu se poate ajunge din start."
			% plansa["cale"])

	# Coloana: rangul în stratul lui, de sus în jos pe desen.
	var coloane := {}
	var pe_strat := {}
	for reper in repere:
		var a := int(adanc[reper])
		if not pe_strat.has(a):
			pe_strat[a] = []
		pe_strat[a].append(reper)
	for a in pe_strat:
		var strat: Array = pe_strat[a]
		strat.sort_custom(func(x, y):
			var px: Vector2 = plansa["poz"][x]
			var py: Vector2 = plansa["poz"][y]
			if absf(px.y - py.y) > 0.0001:
				return px.y < py.y
			return px.x < py.x)
		for i in range(strat.size()):
			coloane[strat[i]] = i

	# Reper → id. Trebuie gata ÎNAINTE de bucla de mai jos: un nod își scrie
	# vecinii ca indici, iar vecinii lui pot fi noduri încă neconstruite.
	var id_al := {}
	var straturi := 0
	for i in range(repere.size()):
		id_al[repere[i]] = i
		straturi = maxi(straturi, int(adanc[repere[i]]) + 1)

	var noduri: Array[Dictionary] = []
	for reper in repere:
		var adancime := int(adanc[reper])
		var spre: Array = []
		for urmator in plansa["spre"].get(reper, []):
			if id_al.has(urmator):
				spre.append(int(id_al[urmator]))
		spre.sort()

		noduri.append({
			"id": int(id_al[reper]),
			# Firul către desen. Singurul câmp pe care harta generată nu-l are.
			"reper": reper,
			"adancime": adancime,
			"coloana": int(coloane.get(reper, 0)),
			# Ca la harta generată: tipul și bugetul vin după, când se cunosc
			# toți vecinii tuturor.
			"tip": Nod.LUPTA,
			"buget": 0.0,
			"samanta": rng.randi_range(1, 999999),
			"spre": spre,
		})

	# Structura unei PLANȘE nu se verifică aici, ci în `tools/verificari/verifica_plansa.gd`,
	# și despărțirea e dinadins. O planșă e conținut scris de mână: se verifică
	# atunci când o desenezi, cu o unealtă care are voie să-ți spună pe îndelete
	# ce ai stricat. Jocul, în schimb, trebuie să PORNEASCĂ — un fișier de date
	# prost n-are voie să oprească o expediție (vezi `_plansa_de_jucat()`).
	_pune_tipurile(_samanta_lui(rng), noduri,
		int(id_al.get(start, 0)), int(id_al.get(boss, -1)))
	return noduri


# ─────────────────────────────────────────────────────────────
# ATRIBUIREA TIPURILOR: împarte, plasează, verifică, reîncearcă
#
# Aici s-a mutat tot ce făceau `_alege_tip()`, `_pondere()` și
# `_asigura_magazin()`. Merită citit ca o schimbare de ÎNTREBARE, nu ca o
# rescriere: vechiul cod întreba „ce tip are nodul ĂSTA?” de paisprezece ori,
# de fiecare dată de la zero. Codul de-aici întreabă o singură dată „cum arată
# harta ASTA, luată întreagă?”.
#
# ─────────────────────────────────────────────────────────────
# CELE PATRU ETAPE
#
#   1. ÎMPARTE    — `proportii()` spune câte noduri din fiecare tip. Fix, din
#                   constante. Sămânța nu are niciun cuvânt aici.
#   2. PLASEAZĂ   — `_o_incercare()` așază tipurile pe noduri, de la cel mai
#                   constrâns tip la cel mai liber, respectând pe loc ce se
#                   poate respecta pe loc.
#   3. VERIFICĂ   — `_reguli_picate()` trece TOATE regulile peste harta gata.
#                   Nu e o formalitate: etapa 2 e lacomă, deci poate produce
#                   aranjări pe care nu le-a văzut venind.
#   4. REÎNCEARCĂ — dacă a picat ceva, se ia de la capăt cu altă sub-sămânță.
#
# ─────────────────────────────────────────────────────────────
# DE CE PLASAREA NU E O SIMPLĂ AMESTECARE
#
# Varianta evidentă era: pui tipurile într-un sac, amesteci sacul, împarți,
# verifici, reîncerci. Am măsurat-o înainte s-o scriu, și nu merge — nu „rar”,
# ci deloc. Pe `harta_01`, din cele 1.663.200 de aranjări posibile ale rețetei,
# doar 28 trec toate regulile. O șansă la ~59.000, deci în 200 de încercări
# n-ai nimeri niciodată una bună.
#
# De-aia plasarea e conștientă de reguli: fiecare tip se pune DOAR pe pozițiile
# pe care regula lui le permite, iar restricțiile de vecinătate se verifică în
# clipa așezării, nu la sfârșit. Cu asta, media a coborât la 7 încercări pe
# `harta_01` și 23 pe `harta_02`, cu 500 de semințe reușite din 500.
#
# Ordinea tipurilor NU e arbitrară, și a fost și ea măsurată. Odihna e cel mai
# greu de plasat (trei bucăți, cu două reguli de vecinătate peste ele), deci
# merge prima; Magazinul e printre cele mai ușoare, deci merge aproape ultimul.
# Cu ordinea inversă (Elitele întâi, Odihnele pe la mijloc), `harta_02` eșua pe
# 11 semințe din 500. Aceleași reguli, aceeași rețetă — doar altă ordine.
# Regula generală, dacă mai apare vreun tip: cel mai constrâns, primul.
#
# ─────────────────────────────────────────────────────────────
# DE CE REGULILE SUNT FUNCȚII SEPARATE, ȘI NU UN `if` MARE
#
# Fiindcă trebuie să pot spune CARE a picat. Când rețeta și regulile ajung să se
# bată cap în cap — și au ajuns deja o dată, vezi nota de la `LUPTE_MINIME_ELITA`
# — singurul lucru folositor e numele regulii vinovate. Un `if` mare ar fi spus
# doar „nu merge”, adică exact nimic.
# ─────────────────────────────────────────────────────────────

## CÂTE NODURI DIN FIECARE TIP, pentru o hartă de mărimea dată.
##
## Întoarce „tip → număr”, cu Lupta ca REST. Startul și Bossul sunt scoși din
## socoteală de la bun început: ei nu se împart, sunt câte unul prin definiție.
##
## Scalarea e proporțională și rotunjită, cu „minim” ca podea. Rotunjirea poate
## da, pe o hartă mică, mai multe noduri speciale decât încap — de-aia la final
## se taie din cel mai numeros tip până când mai rămâne loc și de Lupte. Fără
## tăietura aia, `_o_incercare()` ar eșua de 200 de ori la rând fără să poată
## spune de ce.
static func proportii(cate_noduri: int) -> Dictionary:
	var cate := {}
	# Nodurile care se împart: tot, minus Start, minus Boss.
	var de_impartit: int = maxi(cate_noduri - 2, 0)

	# Câte noduri se împărțeau pe harta de referință — numitorul proporției.
	# Se socotește din tabel, nu se scrie ca cifră: dacă mâine rețeta capătă un
	# tip nou, numitorul se mută singur.
	var la_referinta: int = maxi(NODURI_DE_REFERINTA - 2, 0)

	# ── Împărțirea cu REST, nu cu rotunjire pe fiecare rând ──
	#
	# Prima variantă rotunjea fiecare tip pe cont propriu. E greșit, și greșeala
	# nu se vede decât pe hărți mici: la 12 noduri, fiecare din cele patru
	# tipuri speciale pica pe „.5” și se rotunjea ÎN SUS, deci ieșeau 8 noduri
	# speciale din 10 în loc de 7. Luptele — singurele care nu au o cifră
	# proprie — plăteau toată rotunjirea, și tocmai ele sunt DISTANȚIERELE
	# dintre nodurile speciale. Cu 2 Lupte în loc de 3, regulile de vecinătate
	# n-aveau cu ce să respire.
	#
	# Aici se împarte întâi partea întreagă, apoi resturile se dau, în ordinea
	# mărimii lor, la cine a pierdut cel mai mult din rotunjire. E metoda
	# clasică de repartizare (aceeași care împarte mandate la voturi), și are
	# proprietatea pe care o vrem: suma iese EXACT, iar proporțiile rămân cât se
	# poate de aproape de rețetă.
	var resturi: Array = []
	var dati := 0
	for rand in PROPORTII:
		var exact := float(rand["la_referinta"]) * float(de_impartit) / float(maxi(la_referinta, 1))
		var intreg: int = maxi(int(floorf(exact)), int(rand["minim"]))
		cate[rand["tip"]] = intreg
		dati += intreg
		resturi.append({"tip": rand["tip"], "rest": exact - floorf(exact)})

	# Luptele iau și ele parte la împărțire, cu ponderea lor de pe harta de
	# referință — altfel resturile s-ar duce toate la tipurile speciale, adică
	# exact greșeala de mai sus, doar mai mică.
	var lupte_la_referinta := la_referinta
	for rand in PROPORTII:
		lupte_la_referinta -= int(rand["la_referinta"])
	var lupte_exact := float(lupte_la_referinta) * float(de_impartit) / float(maxi(la_referinta, 1))
	var lupte: int = int(floorf(lupte_exact))
	dati += lupte
	resturi.append({"tip": Nod.LUPTA, "rest": lupte_exact - floorf(lupte_exact)})

	resturi.sort_custom(func(a, b):
		if absf(float(a["rest"]) - float(b["rest"])) > 0.000001:
			return float(a["rest"]) > float(b["rest"])
		# Departajare stabilă, ca aceeași mărime de hartă să dea mereu aceeași
		# rețetă: ordinea tipurilor în enum, nu ordinea în care s-au nimerit.
		return int(a["tip"]) < int(b["tip"]))

	var i := 0
	while dati < de_impartit and not resturi.is_empty():
		var tip: int = resturi[i % resturi.size()]["tip"]
		if tip == Nod.LUPTA:
			lupte += 1
		else:
			cate[tip] = int(cate[tip]) + 1
		dati += 1
		i += 1

	# Prea multe? Taie din cel mai numeros tip SPECIAL, niciodată din Lupte.
	# Luptele sunt distanțierele; o rețetă care le taie pe ele ca să facă loc
	# unui Magazin în plus își taie chiar aerul de care are nevoie ca să încapă.
	while dati > de_impartit:
		var cel_mai_mare := -1
		var maximul := 0
		for rand in PROPORTII:
			var tip: int = rand["tip"]
			if int(cate[tip]) > maximul and int(cate[tip]) > int(rand["minim"]):
				maximul = int(cate[tip])
				cel_mai_mare = tip
		if cel_mai_mare < 0:
			break   # totul e deja la minim: harta e prea mică pentru rețetă
		cate[cel_mai_mare] = int(cate[cel_mai_mare]) - 1
		dati -= 1

	cate[Nod.LUPTA] = maxi(de_impartit - dati + lupte, 0)
	return cate


# ─────────────────────────────────────────────────────────────
# PLAFONUL: câte încap DE FAPT pe forma asta
#
# `proportii()` de mai sus știe o singură cifră: câte noduri are harta. Atât e
# destul pentru o planșă desenată, care e lată și ramificată — acolo rețeta
# încape mereu.
#
# Pe panglica generată nu încape, și de-aia există secțiunea asta. Panglica are
# două noduri pe strat, deci nodurile sunt așezate practic în lanț: al treilea
# și al patrulea sunt la doi pași unul de altul orice ai face. Regulile cer ca
# două Odihne să nu fie nici vecine, nici frați prin cineva — adică la cel puțin
# TREI pași una de alta. Pe o panglică de opt straturi, Odihnele au voie doar în
# straturile 3-6 (regula pașilor), una e fixată lângă Boss, iar pentru a treia
# pur și simplu nu mai rămâne loc.
#
# Măsurat: pe panglica de 14 noduri, rețeta cu 3 Odihne pica pe 29% din semințe;
# cu 2 Odihne, pe 0%. Aceeași panglică la 12 și la 16 noduri n-avea nicio
# problemă. Deci nu rețeta e greșită și nici regula — e forma care nu le încape
# pe amândouă.
#
# ─────────────────────────────────────────────────────────────
# DE CE UN PLAFON SOCOTIT, ȘI NU O CIFRĂ SCRISĂ DE MÂNĂ
#
# Varianta ieftină era „la 14 noduri, două Odihne”. Ar fi mers azi și ar fi
# mințit mâine: cifra 2 n-ar fi fost o regulă, ci amprenta unei forme anume.
# Prima planșă nouă de 14 noduri — mai lată, cu loc de trei Odihne — ar fi primit
# două fără ca nimeni să știe de ce.
#
# Deci plafonul se MĂSOARĂ pe harta din față: care sunt pozițiile pe care tipul
# ăsta are voie să stea, și câte din ele se pot alege deodată fără să se calce
# pe reguli. E cel mai mare grup de poziții care nu se ceartă între ele — și
# nicio plasare, oricât de norocoasă, nu poate pune mai multe.
#
# Ce se pierde din rețetă se dă Luptelor. Ele sunt distanțierele: un nod în plus
# de Luptă între două noduri speciale e exact ce le face pe celelalte să încapă.
# ─────────────────────────────────────────────────────────────

## REȚETA EFECTIVĂ pentru harta din față: proporțiile, tăiate la ce încape.
##
## Asta e funcția pe care o cheamă generatorul. `proportii()` rămâne separată și
## publică fiindcă răspunde la altă întrebare — „ce-ar trebui să iasă?” — iar
## uneltele au nevoie de amândouă ca să poată arăta diferența.
static func reteta(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int, id_boss: int
) -> Dictionary:
	var cate := proportii(noduri.size())
	var pasii := _toti_pasii(vecinatati)

	for rand in PROPORTII:
		var tip: int = rand["tip"]
		var cerute := int(cate.get(tip, 0))
		if cerute <= int(rand["minim"]):
			continue
		var incap := _cat_incap(tip, noduri, vecinatati, pasii, id_start, id_boss)
		var plafonat: int = maxi(mini(cerute, incap), int(rand["minim"]))
		if plafonat < cerute:
			cate[tip] = plafonat
			# Locurile eliberate se duc la Lupte, nu la alt tip special: dacă
			# le-ar lua Evenimentul, am fi înlocuit o îngrămădeală cu alta.
			cate[Nod.LUPTA] = int(cate.get(Nod.LUPTA, 0)) + (cerute - plafonat)
	return cate


## PAȘII ÎNTRE ORICARE DOUĂ NODURI. Un tabel, nu o funcție chemată de N² ori.
static func _toti_pasii(vecinatati: Array) -> Array:
	var tabel: Array = []
	for i in range(vecinatati.size()):
		tabel.append(_pasi_de_la(vecinatati, i))
	return tabel


## CÂTE NODURI DE TIPUL `tip` ÎNCAP, oricât de norocos ai plasa.
##
## Două lucruri hotărăsc răspunsul:
##
##   UNDE ARE VOIE SĂ STEA tipul — regula lui de poziție. Pentru Odihnă e
##   „la cel puțin `PASI_MINIMI_ODIHNA` pași de Start”. Pentru Elită și Magazin
##   e pragul de lupte, care aici se citește pe scurtătură: fiindcă Startul e
##   Luptă și vecinii lui sunt Lupte, orice nod în afară de ei are deja două
##   lupte în spate (vezi `_regula_vecinii_startului_sunt_lupte`). Deci pozițiile
##   permise sunt „tot, fără Start și fără vecinii lui” — exact, nu aproximativ.
##
##   CÂT DE DEPARTE trebuie să stea doi de același fel, din regulile de
##   vecinătate. Pentru Elită, Odihnă și Magazin: nici vecini (un pas), nici
##   frați prin cineva (doi pași) — deci cel puțin trei. Pentru Eveniment doar
##   „nu frați”, deci se ceartă la exact doi pași; vecine au voie să fie.
##
## Răspunsul e cel mai mare grup de poziții permise care nu se ceartă între ele.
static func _cat_incap(
	tip: int, noduri: Array[Dictionary], vecinatati: Array, pasii: Array,
	id_start: int, id_boss: int
) -> int:
	var permise: Array[int] = []
	for i in range(noduri.size()):
		if i == id_start or i == id_boss:
			continue
		# Vecinii Startului sunt Lupte prin regulă, deci niciun tip special
		# n-are ce căuta acolo.
		if id_start >= 0 and i in vecinatati[id_start]:
			continue
		if tip == Nod.ODIHNA and int(pasii[id_start][i]) < PASI_MINIMI_ODIHNA:
			continue
		if tip == Nod.ELITA and id_boss >= 0 and i in vecinatati[id_boss]:
			continue
		permise.append(i)

	return _cel_mai_mare_grup(permise, tip, pasii)


## Doi de același tip, la distanța asta — se ceartă?
static func _se_cearta(tip: int, pasi: int) -> bool:
	if tip == Nod.EVENIMENT:
		return pasi == 2   # doar „frați prin cineva”; vecini au voie
	return pasi <= 2       # nici vecini, nici frați


## CEL MAI MARE GRUP DE POZIȚII CARE NU SE CEARTĂ ÎNTRE ELE.
##
## Se încearcă pe rând: iau poziția asta sau n-o iau? Dacă o iau, scot din
## discuție tot ce se ceartă cu ea și merg mai departe; dacă n-o iau, merg mai
## departe fără ea. La final rămâne cel mai mare grup găsit.
##
## Sună scump, și în general chiar e — dar aici lista are cel mult șaisprezece
## poziții, iar socoteala se face O DATĂ pe hartă, nu la fiecare încercare.
## Tăietura de la `ramase` o scurtează mult: dacă tot ce a mai rămas de cercetat
## n-ar ajunge să bată grupul deja găsit, ramura se abandonează pe loc.
static func _cel_mai_mare_grup(permise: Array[int], tip: int, pasii: Array) -> int:
	return _cauta_grup(permise, 0, 0, tip, pasii, [0])


static func _cauta_grup(
	permise: Array[int], de_la: int, luate: int, tip: int, pasii: Array,
	cel_mai_bun: Array
) -> int:
	if luate > int(cel_mai_bun[0]):
		cel_mai_bun[0] = luate
	# Nici în cel mai bun caz n-am mai putea depăși ce am găsit deja.
	if luate + (permise.size() - de_la) <= int(cel_mai_bun[0]):
		return int(cel_mai_bun[0])

	for i in range(de_la, permise.size()):
		# Se ceartă cu ceva din grupul pe care tocmai îl construim?
		# Grupul curent nu e ținut într-o listă, ci refăcut din drumul
		# recursiv — de-aia funcția primește lista DEJA filtrată.
		var ramase: Array[int] = []
		for j in range(i + 1, permise.size()):
			if not _se_cearta(tip, int(pasii[permise[i]][permise[j]])):
				ramase.append(permise[j])
		_cauta_grup(ramase, 0, luate + 1, tip, pasii, cel_mai_bun)
	return int(cel_mai_bun[0])


## PASUL 4: încearcă până iese, apoi scrie tipurile și bugetele în noduri.
##
## Primește o SĂMÂNȚĂ, nu un generator, și asta e alegerea care ține
## reproductibilitatea: fiecare încercare își face propriul generator, dintr-o
## sub-sămânță derivată din ea. Un rng purtat de la o încercare la alta ar fi
## avansat cu un număr de pași care depinde de câte au picat — deci aceeași
## sămânță ar fi dat hărți diferite dacă mâine se schimbă o regulă.
static func _pune_tipurile(
	samanta_harta: int, noduri: Array[Dictionary], id_start: int, id_boss: int
) -> void:
	if noduri.is_empty():
		return

	var vecinatati := _vecinatati(noduri)
	# Rețeta EFECTIVĂ, nu cea de pe hârtie: `reteta()` taie ce nu încape pe forma
	# hărții ăsteia. Vezi secțiunea de mai sus pentru de ce diferența există.
	var cate := reteta(noduri, vecinatati, id_start, id_boss)

	# Câte încercări a stricat fiecare regulă: și pentru `push_error`-ul de mai
	# jos, și pentru `ultima_aranjare`.
	var vinovate := {}

	for incercare in range(INCERCARI_MAXIME):
		var rng := RandomNumberGenerator.new()
		rng.seed = _sub_samanta(samanta_harta, incercare)

		if not _o_incercare(rng, noduri, vecinatati, id_start, id_boss, cate):
			_numara(vinovate, "plasare imposibilă")
			continue

		var picate := _reguli_picate(noduri, vecinatati, id_start, id_boss)
		if picate.is_empty():
			_scrie_bugetele(noduri)
			ultima_aranjare = {
				"incercari": incercare + 1, "la_limita": false, "picate": vinovate}
			return
		for nume in picate:
			_numara(vinovate, nume)

	# N-a ieșit în 200 de încercări. Nu e ghinion: la ratele măsurate (media 7
	# și 23) două sute de eșecuri la rând e practic imposibil dintr-o nimereală.
	# Înseamnă că o regulă s-a certat cu rețeta, iar numele ei e singurul lucru
	# care ajută.
	var cea_mai_rea := ""
	var cel_mai_des := 0
	for nume in vinovate:
		if int(vinovate[nume]) > cel_mai_des:
			cel_mai_des = int(vinovate[nume])
			cea_mai_rea = String(nume)
	push_error(("Harta %d: nicio aranjare bună în %d încercări. "
		+ "Regula care pică cel mai des: „%s” (de %d ori). Se folosește harta de rezervă.")
		% [samanta_harta, INCERCARI_MAXIME, cea_mai_rea, cel_mai_des])
	_harta_de_rezerva(noduri, vecinatati, id_start, id_boss)
	_scrie_bugetele(noduri)
	ultima_aranjare = {
		"incercari": INCERCARI_MAXIME, "la_limita": true, "picate": vinovate}


## Sub-sămânța unei încercări, derivată DETERMINIST din sămânța hărții.
##
## Înmulțitorul e mare dinadins: două semințe vecine se despart cu 1.000.003,
## iar cele 200 de încercări ale uneia se întind pe doar 200 × 101 = 20.200.
## Deci nicio încercare a semințe 5 nu poate cădea peste o încercare a semințe 6
## — ceea ce ar fi însemnat două hărți „diferite” ieșite identice.
static func _sub_samanta(samanta_harta: int, incercare: int) -> int:
	return samanta_harta * 1000003 + incercare * 101 + 1


## Sămânța cu care a fost pornit un generator.
##
## Godot n-are un „rng.samanta_initiala”, iar `rng.seed` se schimbă pe măsură ce
## tragi din el — deci ASTA SE CITEȘTE ÎNAINTE de orice tragere. Funcția există
## ca să nu existe două locuri care presupun asta pe tăcute.
static func _samanta_lui(rng: RandomNumberGenerator) -> int:
	return int(rng.seed)


static func _numara(unde: Dictionary, cheie: String) -> void:
	unde[cheie] = int(unde.get(cheie, 0)) + 1


# ─────────────────────────────────────────────────────────────
# PASUL 2: O SINGURĂ ÎNCERCARE DE PLASARE
# ─────────────────────────────────────────────────────────────

## Așază toate tipurile pe hartă. `false` = s-a înfundat, încearcă altă sămânță.
##
## Scrie direct în `noduri`, chiar și când eșuează. E în regulă: fiecare
## încercare rescrie totul de la zero, iar cea care reușește e ultima.
static func _o_incercare(
	rng: RandomNumberGenerator, noduri: Array[Dictionary], vecinatati: Array,
	id_start: int, id_boss: int, cate: Dictionary
) -> bool:
	# Toată lumea pornește Luptă; tipurile speciale se așază peste. „Luptă” e
	# valoarea de pornire potrivită fiindcă e chiar restul rețetei — ce rămâne
	# neatins la final e exact ce trebuia să rămână.
	for nod in noduri:
		nod["tip"] = Nod.LUPTA
	if id_boss >= 0:
		noduri[id_boss]["tip"] = Nod.BOSS

	# Pozițiile libere: tot ce nu e Start și nu e Boss.
	var libere: Array[int] = []
	for i in range(noduri.size()):
		if i != id_start and i != id_boss:
			libere.append(i)

	# Vecinii Startului sunt Lupte, prin regulă. Îi scoatem din joc ACUM, nu îi
	# lăsăm să pice așa din întâmplare: pe ei se sprijină celelalte praguri
	# (vezi nota de la `_regula_vecinii_startului_sunt_lupte`).
	var lupte_ramase := int(cate.get(Nod.LUPTA, 0))
	if id_start >= 0 and id_start < vecinatati.size():
		for v in vecinatati[id_start]:
			var vecin := int(v)
			if vecin == id_boss or not vecin in libere:
				continue
			if lupte_ramase <= 0:
				return false   # rețeta n-are destule Lupte pentru forma asta
			libere.erase(vecin)
			lupte_ramase -= 1

	var pasi := _pasi_de_la(vecinatati, id_start)

	# ORDINEA: cel mai constrâns tip primul. Vezi nota lungă de la începutul
	# secțiunii — nu e o preferință, e diferența dintre 500/500 și 489/500.

	# (a) ODIHNA. Una trebuie să fie vecină cu Bossul, și aia se pune PRIMA: e
	#     poziția cea mai rară de pe hartă (Bossul are adesea un singur vecin),
	#     deci dacă o lași la urmă o găsești mereu ocupată.
	var cate_odihne := int(cate.get(Nod.ODIHNA, 0))
	if cate_odihne > 0 and id_boss >= 0:
		var langa_boss: Array[int] = []
		for v in vecinatati[id_boss]:
			if int(v) in libere and int(pasi[int(v)]) >= PASI_MINIMI_ODIHNA:
				langa_boss.append(int(v))
		if not _aseaza(rng, noduri, vecinatati, libere, Nod.ODIHNA, langa_boss, 1):
			return false
		cate_odihne -= 1
	var destul_de_departe: Array[int] = []
	for i in libere:
		if int(pasi[i]) >= PASI_MINIMI_ODIHNA:
			destul_de_departe.append(i)
	if not _aseaza(rng, noduri, vecinatati, libere, Nod.ODIHNA,
			destul_de_departe, cate_odihne):
		return false

	# (b) EVENIMENTUL. N-are nicio regulă de poziție — doar pe cea de vecinătate
	#     („nu doi de același fel la același nod”). Merge al doilea tocmai
	#     fiindcă e numeros: trei bucăți lăsate la urmă n-ar mai avea unde intra.
	if not _aseaza(rng, noduri, vecinatati, libere, Nod.EVENIMENT,
			libere.duplicate(), int(cate.get(Nod.EVENIMENT, 0))):
		return false

	# (c) ELITA. Pragul se măsoară pe nodurile de bătaie știute până acum, adică
	#     Luptele. E o socoteală PRUDENTĂ, nu una exactă: Elitele care urmează
	#     sunt și ele noduri de bătaie, deci cifra reală poate ieși doar mai
	#     mare, niciodată mai mică. O poziție acceptată aici rămâne deci
	#     acceptabilă și la verificarea finală — invers n-ar fi fost adevărat.
	var lupte_minime := _lupte_minime(noduri, vecinatati, id_start)
	var pentru_elita: Array[int] = []
	for i in libere:
		if int(lupte_minime[i]) < LUPTE_MINIME_ELITA:
			continue
		if id_boss >= 0 and i in vecinatati[id_boss]:
			continue   # niciun vecin al Bossului nu e Elită
		pentru_elita.append(i)
	if not _aseaza(rng, noduri, vecinatati, libere, Nod.ELITA,
			pentru_elita, int(cate.get(Nod.ELITA, 0))):
		return false

	# (d) MAGAZINUL. Acum se cunosc TOATE nodurile de bătaie (Lupte și Elite),
	#     deci „luptele minime” se poate socoti exact, nu prudent.
	lupte_minime = _lupte_minime(noduri, vecinatati, id_start)
	var pentru_magazin: Array[int] = []
	for i in libere:
		if int(lupte_minime[i]) >= LUPTE_MINIME_MAGAZIN:
			pentru_magazin.append(i)
	if not _aseaza(rng, noduri, vecinatati, libere, Nod.MAGAZIN,
			pentru_magazin, int(cate.get(Nod.MAGAZIN, 0))):
		return false

	# Ce a rămas e Luptă — și e deja Luptă, din prima buclă a funcției.
	return true


## Pune `cate` noduri de tipul `tip`, alese dintre `candidati`, în ordine
## amestecată. `false` = n-au încăput toate.
##
## Verificările de-aici sunt cele două reguli de vecinătate care se pot ține DIN
## MERS, adică fără să știi ce urmează:
##   — nu doi de același tip vecini între ei;
##   — nu doi de același tip la același nod (frați, printr-o răscruce).
## Restul regulilor depind de harta întreagă și de-aia există pasul 3.
static func _aseaza(
	rng: RandomNumberGenerator, noduri: Array[Dictionary], vecinatati: Array,
	libere: Array[int], tip: int, candidati: Array[int], cate: int
) -> bool:
	if cate <= 0:
		return true
	var amestecati := _amesteca(rng, candidati)
	var pusi := 0
	for p in amestecati:
		if pusi >= cate:
			break
		if not p in libere:
			continue
		if not _incape(noduri, vecinatati, p, tip):
			continue
		noduri[p]["tip"] = tip
		libere.erase(p)
		pusi += 1
	return pusi == cate


## Poate sta un nod de tipul `tip` pe poziția `p`, față de ce e deja pus?
static func _incape(
	noduri: Array[Dictionary], vecinatati: Array, p: int, tip: int
) -> bool:
	# Vecin direct de același tip — numai pentru tipurile la care regula o cere.
	if tip in [Nod.ELITA, Nod.ODIHNA, Nod.MAGAZIN]:
		for v in vecinatati[p]:
			if int(noduri[int(v)]["tip"]) == tip:
				return false
	# Frate printr-o răscruce: un vecin comun care ar ajunge să aibă doi vecini
	# de același tip special.
	for v in vecinatati[p]:
		for w in vecinatati[int(v)]:
			if int(w) != p and int(noduri[int(w)]["tip"]) == tip:
				return false
	return true


## Lista amestecată, cu un generator DAT — nu cu `Array.shuffle()`.
##
## `Array.shuffle()` folosește generatorul global al motorului, care e influențat
## de tot ce s-a întâmplat înainte în joc. Cu el, aceeași sămânță ar fi dat hărți
## diferite după o luptă mai lungă — exact ce apără antetul secțiunii de
## generare. Amestecul de mai jos e Fisher-Yates, scris pe față: iei ultimul
## element și-l schimbi cu unul ales la întâmplare dintre cele rămase, apoi
## cobori. Fiecare aranjare iese cu aceeași șansă, și nicio poziție nu e
## favorizată.
static func _amesteca(rng: RandomNumberGenerator, lista: Array[int]) -> Array[int]:
	var copie := lista.duplicate()
	for i in range(copie.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: int = copie[i]
		copie[i] = copie[j]
		copie[j] = t
	return copie


# ─────────────────────────────────────────────────────────────
# DISTANȚELE: două feluri de „cât de departe”
# ─────────────────────────────────────────────────────────────

## PAȘII de la un nod la toate celelalte: parcurgere în lățime, în AMÂNDOUĂ
## sensurile.
##
## „În amândouă sensurile” e alegerea care contează aici, și se deosebește de
## `Plansa.adancimi()`, care merge numai pe sensul scris. Nu e o scăpare — sunt
## două întrebări diferite. Adâncimea e ce a vrut DESENATORUL: a câta treaptă e
## nodul pe drum. Pașii de-aici sunt cât de departe e nodul PENTRU JUCĂTOR, iar
## jucătorul merge pe drumuri în amândouă sensurile (vezi `vecini()`). O Odihnă
## „la trei pași” trebuie să fie la trei pași de mers, nu de desen.
##
## Nodurile la care nu se ajunge primesc un număr foarte mare, nu -1: așa orice
## comparație „≥ prag” le acceptă în loc să crape, iar o hartă cu un nod izolat
## rămâne jucabilă. Izolarea se raportează în altă parte, unde se poate repara.
static func _pasi_de_la(vecinatati: Array, de_la: int) -> PackedInt32Array:
	var pasi := PackedInt32Array()
	pasi.resize(vecinatati.size())
	pasi.fill(999)
	if de_la < 0 or de_la >= vecinatati.size():
		return pasi

	pasi[de_la] = 0
	var coada: Array[int] = [de_la]
	var i := 0
	while i < coada.size():
		var aici: int = coada[i]
		i += 1
		for v in vecinatati[aici]:
			if pasi[int(v)] == 999:
				pasi[int(v)] = pasi[aici] + 1
				coada.append(int(v))
	return pasi


## LUPTELE MINIME pentru fiecare nod: câte noduri de Luptă sau Elită ești
## OBLIGAT să treci ca să ajungi acolo, pe cel mai ieftin drum de la Start.
## Nodul însuși nu se numără; Startul se numără, fiindcă te bați și acolo.
##
## E tot o căutare de drum scurt, dar cu COSTURI: un nod de bătaie costă 1, unul
## liniștit costă 0. De-aia nu merge o parcurgere în lățime obișnuită — aia
## presupune că toți pașii costă la fel, deci ar număra Evenimentele ca pe niște
## lupte.
##
## Se folosește parcurgerea „0-1”: un pas de cost 0 se bagă în FAȚA cozii (e tot
## atât de aproape ca nodul din care vii), unul de cost 1 la coadă. Coada rămâne
## astfel sortată de la sine, fără nicio sortare — trucul ieftin care ține locul
## unui Dijkstra când costurile sunt doar 0 și 1.
##
## Costul stă pe nodul din care PLECI, nu pe cel în care intri, și asta e chiar
## ce face ca nodul însuși să nu se numere: exact definiția cerută.
static func _lupte_minime(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int
) -> PackedInt32Array:
	var cat := PackedInt32Array()
	cat.resize(noduri.size())
	cat.fill(999)
	if id_start < 0 or id_start >= noduri.size():
		return cat

	cat[id_start] = 0
	var coada: Array[int] = [id_start]
	while not coada.is_empty():
		var aici: int = coada.pop_front()
		var cost := 1 if int(noduri[aici]["tip"]) in [Nod.LUPTA, Nod.ELITA] else 0
		for v in vecinatati[aici]:
			var urmator := int(v)
			if cat[aici] + cost < cat[urmator]:
				cat[urmator] = cat[aici] + cost
				if cost == 0:
					coada.push_front(urmator)
				else:
					coada.push_back(urmator)
	return cat


# ─────────────────────────────────────────────────────────────
# PASUL 3: REGULILE
#
# Fiecare e o funcție mică, cu nume, care întoarce „e respectată?”. Numele apare
# în `push_error` când o hartă nu iese, deci e scris ca să fie citit de cineva
# care nu se uită în cod: „odihnă prea aproape de start”, nu „regula 3”.
#
# TOATE se verifică pe PERECHI DE VECINI, în orice sens. Drumurile se merg în
# amândouă sensurile (vezi `vecini()`), deci „la rând” nu înseamnă „după”, ci
# „lipite”. O regulă scrisă pe `spre` ar fi fost adevărată pe desen și falsă în
# joc.
# ─────────────────────────────────────────────────────────────

## Toate regulile, trecute peste o hartă gata. Întoarce numele celor picate.
static func _reguli_picate(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int, id_boss: int
) -> Array[String]:
	var picate: Array[String] = []
	var pasi := _pasi_de_la(vecinatati, id_start)
	var lupte := _lupte_minime(noduri, vecinatati, id_start)

	if not _regula_magazin_dupa_lupte(noduri, lupte):
		picate.append("magazin prea devreme")
	if not _regula_elita_dupa_lupte(noduri, lupte):
		picate.append("elită prea devreme")
	if not _regula_odihna_departe_de_start(noduri, pasi):
		picate.append("odihnă prea aproape de start")
	if not _regula_vecinii_startului_sunt_lupte(noduri, vecinatati, id_start):
		picate.append("vecin al startului care nu e luptă")
	if not _regula_fara_gemeni_vecini(noduri, vecinatati):
		picate.append("două noduri de același fel, vecine")
	if not _regula_fara_gemeni_la_acelasi_nod(noduri, vecinatati):
		picate.append("două noduri de același fel, la același vecin")
	if not _regula_vecinatate_variata(noduri, vecinatati):
		picate.append("toți vecinii unui nod, de același fel")
	if not _regula_boss_fara_elite_vecine(noduri, vecinatati, id_boss):
		picate.append("elită lipită de boss")
	if not _regula_boss_cu_odihna_vecina(noduri, vecinatati, id_boss):
		picate.append("boss fără odihnă alături")
	return picate


## Un Magazin apare abia după ce ai avut de unde strânge Monede.
##
## Se măsoară în LUPTE, nu în pași: trei Evenimente la rând nu ți-au umplut
## punga, oricât de departe te-ar fi dus.
static func _regula_magazin_dupa_lupte(
	noduri: Array[Dictionary], lupte_minime: PackedInt32Array
) -> bool:
	for nod in noduri:
		if int(nod["tip"]) == Nod.MAGAZIN \
				and int(lupte_minime[int(nod["id"])]) < LUPTE_MINIME_MAGAZIN:
			return false
	return true


## O Elită apare abia după ce ai apucat să te încălzești.
static func _regula_elita_dupa_lupte(
	noduri: Array[Dictionary], lupte_minime: PackedInt32Array
) -> bool:
	for nod in noduri:
		if int(nod["tip"]) == Nod.ELITA \
				and int(lupte_minime[int(nod["id"])]) < LUPTE_MINIME_ELITA:
			return false
	return true


## O Odihnă prea aproape de Start e un nod irosit.
##
## Se măsoară în PAȘI, nu în lupte, și asta e simetricul notei de la Magazin.
## Odihna nu-ți cere să fi CÂȘTIGAT ceva, ci să fi avut timp să PIERZI ceva. La
## al doilea nod ești încă aproape de PV-ul plin, deci o Odihnă acolo e irosită
## indiferent câte lupte au fost în drum.
static func _regula_odihna_departe_de_start(
	noduri: Array[Dictionary], pasi: PackedInt32Array
) -> bool:
	for nod in noduri:
		if int(nod["tip"]) == Nod.ODIHNA \
				and int(pasi[int(nod["id"])]) < PASI_MINIMI_ODIHNA:
			return false
	return true


## Prima alegere de pe hartă e între lupte, nu între surprize.
##
## Regula asta face mai mult decât pare, și de-aia merită citită de două ori:
## fiindcă Startul e Luptă și vecinii lui sunt tot Lupte, ORICE alt nod de pe
## hartă are automat cel puțin două lupte minime în spate — orice drum trece
## întâi prin Start (1), apoi printr-un vecin al lui (1). Adică ea e chiar
## temelia pragurilor de la Magazin și Elită, nu o regulă de politețe.
static func _regula_vecinii_startului_sunt_lupte(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int
) -> bool:
	if id_start < 0 or id_start >= noduri.size():
		return true
	for v in vecinatati[id_start]:
		if int(noduri[int(v)]["tip"]) != Nod.LUPTA:
			return false
	return true


## Fără două Odihne, două Elite sau două Magazine lipite.
##
## Două Odihne legate printr-un drum sunt una lângă alta indiferent din care
## capăt vii — de-aia verificarea e pe perechi de vecini, nu pe „ce urmează
## după”.
static func _regula_fara_gemeni_vecini(
	noduri: Array[Dictionary], vecinatati: Array
) -> bool:
	for nod in noduri:
		var tip := int(nod["tip"])
		if not tip in [Nod.ELITA, Nod.ODIHNA, Nod.MAGAZIN]:
			continue
		for v in vecinatati[int(nod["id"])]:
			if int(noduri[int(v)]["tip"]) == tip:
				return false
	return true


## Vecinii aceluiași nod nu pot cuprinde doi de același fel special.
##
## Fără ea, o răscruce cu trei drumuri putea oferi „Magazin, Magazin, Eveniment”
## — adică o alegere care nu e o alegere. Regula de mai sus n-ar fi prins-o:
## cele două Magazine nu sunt vecine ÎNTRE ELE, ci frați prin răscruce.
static func _regula_fara_gemeni_la_acelasi_nod(
	noduri: Array[Dictionary], vecinatati: Array
) -> bool:
	var speciale := [Nod.ELITA, Nod.ODIHNA, Nod.MAGAZIN, Nod.EVENIMENT]
	for i in range(noduri.size()):
		var vazute := {}
		for v in vecinatati[i]:
			var tip := int(noduri[int(v)]["tip"])
			if not tip in speciale:
				continue
			if vazute.has(tip):
				return false
			vazute[tip] = true
	return true


## O răscruce adevărată nu are toate brațele la fel.
##
## Doar de la trei vecini în sus: la doi, „amândoi la fel” e des și inofensiv —
## ești pe un culoar, nu la o alegere. De la trei, toate la fel înseamnă că
## răscrucea nu decide nimic, iar harta ți-a promis o hotărâre pe care n-o ai.
static func _regula_vecinatate_variata(
	noduri: Array[Dictionary], vecinatati: Array
) -> bool:
	for i in range(noduri.size()):
		var vecinii_lui: Array = vecinatati[i]
		if vecinii_lui.size() < 3:
			continue
		var toti_la_fel := true
		var intaiul := int(noduri[int(vecinii_lui[0])]["tip"])
		for v in vecinii_lui:
			if int(noduri[int(v)]["tip"]) != intaiul:
				toti_la_fel = false
				break
		if toti_la_fel:
			return false
	return true


## Nicio Elită lipită de Boss.
##
## Două lupte grele una după alta, fără nimic între ele, nu e o culme — e o
## taxă. Elita ar consuma fix PV-ul cu care voiai să intri la Boss, iar
## expediția s-ar decide cu un nod mai devreme decât arată harta.
static func _regula_boss_fara_elite_vecine(
	noduri: Array[Dictionary], vecinatati: Array, id_boss: int
) -> bool:
	if id_boss < 0 or id_boss >= noduri.size():
		return true
	for v in vecinatati[id_boss]:
		if int(noduri[int(v)]["tip"]) == Nod.ELITA:
			return false
	return true


## Cel puțin un vecin al Bossului e Odihnă.
##
## Regula care transformă ultimul nod dintr-o loterie într-o luptă. Fără ea poți
## ajunge la Boss cu 2 PV fiindcă ultima Odihnă a căzut la mijlocul hărții — iar
## atunci finalul nu l-ai decis tu, l-a decis sămânța.
static func _regula_boss_cu_odihna_vecina(
	noduri: Array[Dictionary], vecinatati: Array, id_boss: int
) -> bool:
	if id_boss < 0 or id_boss >= noduri.size():
		return true
	for v in vecinatati[id_boss]:
		if int(noduri[int(v)]["tip"]) == Nod.ODIHNA:
			return true
	return false


# ─────────────────────────────────────────────────────────────
# STRUCTURA (numai pentru harta GENERATĂ)
#
# Regulile de mai sus vorbesc despre CE e fiecare nod. Cea de aici vorbește
# despre FORMA hărții, deci n-are ce căuta în bucla de reîncercări: forma nu se
# schimbă de la o încercare la alta, așa că o reîncercare n-ar repara-o
# niciodată — ar face doar două sute de pași degeaba.
#
# Pentru o PLANȘĂ desenată, aceeași verificare stă în `tools/verificari/verifica_plansa.gd`,
# unde o vezi cât desenezi. Distanța minimă dintre noduri e tot acolo, fiindcă e
# o măsură în PIXELI — iar pixelii unei hărți generate se nasc abia în `harta.gd`
# și se măsoară în `tools/verificari/verifica_harta.gd`. Regula e aceeași în toate trei
# locurile; doar unealta care o poate măsura diferă.
# ─────────────────────────────────────────────────────────────

## Orice nod în afară de Start și Boss are cel puțin doi vecini.
##
## Un nod cu un singur vecin e un nod în care intri și din care te întorci pe
## unde ai venit — numai că nodul din care ai venit e deja parcurs, deci
## `accesibile()` nu ți-l va oferi aproape niciodată. E desenat pe hartă și e
## mort: cel mai supărător fel de greșeală, fiindcă arată bine.
##
## Pe panglică regula se ține prin construcție (fiecare strat se leagă de cel
## dinainte ȘI de cel de după), deci verificarea e o plasă sub o demonstrație.
## Dacă vreodată sună, `_leaga()` s-a stricat.
static func _verifica_structura(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int, id_boss: int
) -> void:
	var singuratice: Array[String] = []
	for i in range(noduri.size()):
		if i == id_start or i == id_boss:
			continue
		if vecinatati[i].size() < 2:
			singuratice.append(str(i))
	if not singuratice.is_empty():
		push_error("Harta generată: nodurile %s au sub doi vecini."
			% ", ".join(singuratice))


# ─────────────────────────────────────────────────────────────
# PLASA DE SIGURANȚĂ
# ─────────────────────────────────────────────────────────────

## HARTA DE REZERVĂ: nu frumoasă, dar jucabilă.
##
## Se ajunge aici numai după `push_error`, deci e un drum pe care n-ar trebui să
## calce nimeni. Întrebarea nu e „cum salvez regulile?”, ci „ce e minimul fără
## de care expediția e STRICATĂ?”. Răspunsul are două lucruri:
##
##   O ODIHNĂ lângă Boss, ca finalul să fie o luptă, nu o execuție;
##   UN MAGAZIN, cât mai adânc, ca Monedele strânse să aibă unde se duce.
##
## Restul rămâne Lupte. E o hartă plicticoasă, dar una pe care o poți termina —
## și, mai ales, una din care se vede pe loc că ceva a mers prost, fiindcă arată
## altfel decât orice hartă adevărată. O rezervă care seamănă cu o hartă bună ar
## ascunde eroarea exact atunci când ai nevoie s-o vezi.
static func _harta_de_rezerva(
	noduri: Array[Dictionary], vecinatati: Array, id_start: int, id_boss: int
) -> void:
	for nod in noduri:
		nod["tip"] = Nod.LUPTA
	if id_boss >= 0:
		noduri[id_boss]["tip"] = Nod.BOSS

	var odihna := -1
	if id_boss >= 0:
		for v in vecinatati[id_boss]:
			if int(v) != id_start:
				odihna = int(v)
				noduri[odihna]["tip"] = Nod.ODIHNA
				break

	# Magazinul: nodul cel mai depărtat de Start care nu e deja luat. Cel mai
	# depărtat, fiindcă acolo ai strâns cel mai mult.
	var pasi := _pasi_de_la(vecinatati, id_start)
	var ales := -1
	var cel_mai_departe := -1
	for i in range(noduri.size()):
		if i == id_start or i == id_boss or i == odihna:
			continue
		if int(pasi[i]) < 999 and int(pasi[i]) > cel_mai_departe:
			cel_mai_departe = int(pasi[i])
			ales = i
	if ales >= 0:
		noduri[ales]["tip"] = Nod.MAGAZIN


## BUGETELE, socotite după ce tipurile sunt hotărâte.
##
## Formula era scrisă în TREI locuri (cele două generatoare și cârpitorul de
## Magazin), și exact de-aia al treilea a putut s-o uite în tăcere odată — e
## lecția din `docs/progres.md`, 23 septembrie. Acum are un nume și o singură
## casă. Se scrie la sfârșit fiindcă depinde de tip, iar tipul se știe abia la
## sfârșit.
static func _scrie_bugetele(noduri: Array[Dictionary]) -> void:
	for nod in noduri:
		nod["buget"] = _buget(int(nod["adancime"]), int(nod["tip"]))


## Bugetul unui nod: cât crește cu adâncimea, înmulțit cu greutatea tipului.
static func _buget(adancime: int, tip: int) -> float:
	return snappedf(
		(BUGET_BAZA + BUGET_PE_ADANCIME * adancime) * float(date_nod(tip)["buget"]),
		0.01)


## Trage muchiile dintre două straturi vecine — FĂRĂ SĂ SE ÎNCRUCIȘEZE.
##
## ─────────────────────────────────────────────────────────────
## CE ERA ÎNAINTE, ȘI DE CE NU MERGEA
##
## Regula veche era: fiecare nod de sus își alege 1-2 urmași la întâmplare,
## apoi reparăm nodurile de jos rămase fără părinte. Ambele jumătăți erau
## corecte luate separat — harta ieșea conectată, fiecare nod era accesibil —
## și totuși drumurile se tăiau unul pe altul la aproape fiecare sămânță
## (949 de încrucișări la 300 de hărți).
##
## Motivul e simplu odată văzut: „la întâmplare” înseamnă că nodul de sus de pe
## coloana 0 putea alege nodul de jos de pe coloana 1, iar cel de pe coloana 1
## pe cel de pe coloana 0. Două drumuri care își schimbă locurile. Nicio
## curbură frumoasă nu repară asta — e o încrucișare în GRAF, nu în desen.
##
## ─────────────────────────────────────────────────────────────
## REGULA NOUĂ: FIECARE NOD DE SUS IA O FELIE, ȘI FELIILE MERG ÎNAINTE
##
## Nodurile ambelor straturi sunt luate în ordinea coloanei. Fiecare nod de sus
## primește o felie CONTINUĂ de noduri de jos — de la `start` la `capat` — iar
## felia următoare nu are voie să înceapă înaintea locului unde s-a terminat
## cea dinainte.
##
## Două felii care merg înainte nu se pot inversa, iar dacă nu se inversează,
## drumurile nu se încrucișează. Asta e tot. Nu e o verificare („încrucișează
## muchia asta pe alta? atunci mai trag un zar") — e o construcție din care
## încrucișarea pur și simplu nu poate ieși, oricâte zaruri ai arunca.
##
## Feliile au voie să se ATINGĂ: `start` poate fi chiar ultimul nod al feliei
## de dinainte. Atunci două drumuri intră în același nod de jos — două cărări
## care se adună, care e exact ce vrei să vezi pe o hartă. Ce nu au voie e să
## se încalece pe dos.
##
## ─────────────────────────────────────────────────────────────
## CE RĂMÂNE GARANTAT
##
## 1. FIECARE NOD DE JOS E ACCESIBIL. Prima felie începe la 0, ultima se termină
##    la ultimul nod, iar între ele feliile sunt lipite cap la cap. Reuniunea lor
##    e tot stratul, fără găuri. Nu mai e nevoie de pasul de „reparație” de
##    dinainte, fiindcă nu mai există ce repara.
## 2. FIECARE NOD DE SUS ARE CEL PUȚIN O IEȘIRE. `capat` e mereu cel puțin egal
##    cu `start`, deci felia nu poate fi goală. Un nod fără ieșire ar fi fost un
##    drum înfundat — mergi acolo și nu mai ai unde.
##
## O CONDIȚIE pe care o presupune: `sus` și `jos` vin în ORDINEA COLOANEI. Le
## construiește `genereaza_harta()`, cu `for coloana in range(cate)`, deci așa
## sunt. Dacă într-o zi cineva le amestecă acolo, regula de aici devine o
## minciună — și nu se va plânge nimeni, doar drumurile se vor tăia iar.
static func _leaga(
	rng: RandomNumberGenerator,
	noduri: Array[Dictionary],
	sus: Array[int],
	jos: Array[int]
) -> void:
	var n := sus.size()
	var m := jos.size()
	if n == 0 or m == 0:
		return

	# Unde s-a terminat felia nodului de sus dinainte. Prima felie n-are una.
	var capat_anterior := -1

	for k in range(n):
		var start := 0
		if k > 0:
			# Două variante, și doar două. Ori pornim CHIAR din nodul unde s-a
			# oprit vecinul de deasupra (cele două drumuri se adună acolo), ori
			# de la următorul (drumuri complet separate). Orice altceva ar
			# însemna să dăm înapoi — adică o încrucișare.
			start = capat_anterior
			if start < m - 1 and rng.randf() < 0.5:
				start += 1

		# Ultimul nod de sus acoperă tot ce-a mai rămas: altfel ar rămâne
		# noduri de jos fără niciun părinte, adică bucăți de hartă în care nu
		# se poate ajunge.
		var capat := m - 1
		if k < n - 1:
			capat = rng.randi_range(start, m - 1)

		var legaturi: Array = noduri[sus[k]]["spre"]
		for indice in range(start, capat + 1):
			legaturi.append(jos[indice])
		legaturi.sort()
		capat_anterior = capat


## Loadout curățat: doar chei care există, fără dubluri, cel mult N.
## Completat din catalog dacă a venit prea scurt — un loadout incomplet ar
## însemna o luptă cu două Obeliscuri, fără ca nimeni să fi cerut asta.
static func _curata_loadout(cerute: Array[String]) -> Array[String]:
	var curat: Array[String] = []
	for cheie in cerute:
		if curat.size() >= DISCIPLINE_IN_LOADOUT:
			break
		if Discipline.exista(cheie) and not (cheie in curat):
			curat.append(cheie)
	for cheie in Discipline.chei():
		if curat.size() >= DISCIPLINE_IN_LOADOUT:
			break
		if not (cheie in curat):
			curat.append(cheie)
	return curat


# ─────────────────────────────────────────────────────────────
# SALVARE
#
# Oglinda celor trei reguli din antet: fiindcă starea e deja numai tipuri
# simple, funcțiile astea două n-au de făcut nicio conversie complicată.
# Singura traducere reală e `Nod` → cheie text și înapoi.
# ─────────────────────────────────────────────────────────────

func spre_dictionar() -> Dictionary:
	var noduri: Array = []
	for nod in harta:
		var copie := nod.duplicate(true)
		copie["tip"] = DATE_NOD[nod["tip"]]["cheie"]   # enum → text
		noduri.append(copie)
	return {
		"activa": activa,
		"samanta": samanta,
		"plansa": plansa,
		"harta": noduri,
		"pozitie": pozitie,
		"parcurse": parcurse.duplicate(),
		"loadout": loadout.duplicate(),
		"pv": pv,
		"pv_max": pv_max,
		"fragmente_castigate": fragmente_castigate,
		"monede": monede,
		"puteri": puteri.duplicate(),
		"recorduri": recorduri.duplicate(true),
		"final": final,
	}


func din_dictionar(date: Dictionary) -> void:
	goleste()
	samanta = int(date.get("samanta", 0))
	# Un save vechi n-are câmpul, deci "" — adică hartă generată. Exact ce era.
	plansa = String(date.get("plansa", ""))
	pozitie = int(date.get("pozitie", -1))
	pv = int(date.get("pv", PV_MAX))
	pv_max = int(date.get("pv_max", PV_MAX))
	fragmente_castigate = int(date.get("fragmente_castigate", 0))
	monede = int(date.get("monede", 0))
	final = String(date.get("final", ""))
	activa = bool(date.get("activa", false))

	for cheie in date.get("loadout", []):
		loadout.append(String(cheie))
	for cheie in date.get("puteri", []):
		puteri.append(String(cheie))
	for id in date.get("parcurse", []):
		parcurse.append(int(id))
	for cheie in recorduri:
		recorduri[cheie] = int(date.get("recorduri", {}).get(cheie, 0))

	for brut in date.get("harta", []):
		var nod: Dictionary = (brut as Dictionary).duplicate(true)
		nod["tip"] = _tip_din_cheie(String(nod.get("tip", "lupta")))
		# JSON întoarce toate numerele ca float. Convertim o dată, aici, ca
		# restul codului să lucreze liniștit cu int-uri (un float nu poate
		# indexa un Array).
		for camp in ["id", "adancime", "coloana", "samanta"]:
			nod[camp] = int(nod.get(camp, 0))
		nod["buget"] = float(nod.get("buget", BUGET_BAZA))
		var spre: Array = []
		for id in nod.get("spre", []):
			spre.append(int(id))
		nod["spre"] = spre
		harta.append(nod)

	s_a_schimbat.emit()


## Cheie text → enum. O cheie necunoscută (un tip de nod șters între versiuni)
## devine Luptă, în loc să oprească încărcarea: un save vechi trebuie să se
## deschidă chiar și strâmb.
static func _tip_din_cheie(cheie: String) -> Nod:
	for tip in DATE_NOD:
		if DATE_NOD[tip]["cheie"] == cheie:
			return tip
	return Nod.LUPTA

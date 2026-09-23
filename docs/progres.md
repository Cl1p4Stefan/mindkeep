# MINDKEEP — Jurnal de progres

*Ultima actualizare: 23 septembrie 2026*
*Atașează acest fișier la începutul fiecărei sesiuni noi, împreună cu `CLAUDE.md` și `docs/pitch-document.md`.*

---

## Unde suntem în ruta de construcție

| Pas | Stare |
|---|---|
| 1. Setup, Git | ✅ gata |
| 2. Scena de luptă cu placeholdere | ✅ gata |
| 3. Trivia, ca scenă independentă | ✅ gata |
| 4. Bucla completă a unei lupte | ✅ victorie · înfrângere · recompense (Fragmente) |
| 5. Trei inamici manuali | ✅ Soldatul · Lăncierul (ceas) · Spadasinul (vulnerabilitate), aleși din joc |
| 6. Harta de expediție | ✅ loadout „N din M" · **12-16 noduri**, ramificate, cu sămânță · Luptă / Elită / Odihnă / Eveniment / **Magazin** / **Boss** · **Monede + puteri temporare** · sumar de run · aspect: pergament, simboluri de cerneală, trasee punctate · **nodurile și drumurile stau pe o PANGLICĂ (curbă centrală + benzi)**, nu pe o grilă dreaptă · **patru trasee, toate verzi pe 300 de semințe** (POTCOAVĂ activă; POTCOAVA OGLINDITĂ e aceeași formă, întoarsă) · strat înclinat (forfecare) la ȘARPE · **drumuri care nu se încrucișează niciodată (0 la 300 de semințe)** · **nodul curent are și aură, și X** · **două surse de hartă: GENERATĂ (panglica) sau DESENATĂ dintr-un fișier `data/harti/*.json`** — comutatorul `Expeditie.SURSA_HARTII`; azi e pe DESENATĂ · **harta umple pergamentul**: pânza ține toată pagina, antetul plutește peste ea (805 × 427 px de hartă, de la 666 × 353) · **drumurile merg în amândouă sensurile**, cu nodul parcurs tăiat definitiv și cu garanția, verificată pe 16 000 de expediții simulate, că nu te poți înfunda · **figurina sare, cade ca un slam și zguduie ecranul la aterizare**, cu un răgaz de 0,5 s înainte să se deschidă nodul · **tipurile nodurilor se împart după o REȚETĂ fixă, nu se trag cu zarul**: 9 reguli de vecinătate și de început, plasare conștientă de reguli, verificare completă și reîncercare cu sub-sămânță (0 eșecuri pe 500 de semințe × 3 surse de hartă) · rețeta se **plafonează după forma hărții**, nu după numărul de noduri |
| 7. Cetatea | ❌ |
| 8. Save/Load | 🟡 tezaurul, sacul și expediția știu toate să se serializeze (`spre_dictionar` / `din_dictionar`), pe trei straturi de durată; scrierea pe disc, nu încă |
| 9. Celelalte discipline | 🟡 Cultură generală ✅ (135 de întrebări) · Logica ✅ (80 de categorii) · Cuvinte ✅ · toate trei fără repetiții pe expediție · celelalte 5 ❌ |
| 10–13. Generator de inamici, artă, web | ❌ (artă parțial: figurile principale și piesele de pe butoanele de Obelisc au imagini reale) · Regina: **amânată**, vezi CLAUDE.md |

Din pasul 10 (generatorul de inamici) s-a făcut deja partea care nu costa nimic
azi: **identitatea inamicului e separată de arhetip**. Restul (modificatori,
buget, generare) rămâne acolo unde era.

Am sărit peste ordinea recomandată la pasul 12 (artă): imaginile pentru rege,
cavaler și pentru cele trei piese de șah de pe butoane au intrat mai devreme, dar
restul rămâne placeholder. Bucla de luptă e în continuare cea validată, nu arta.

---

## TIPURILE NU MAI SE TRAG CU ZARUL (23 septembrie 2026) — rețetă, reguli, reîncercare

**Plângerea:** Magazin după o singură luptă, două Odihne una lângă alta, două
Elite una lângă alta.

**Cauza, și de ce nu era o reglare greșită.** Tipurile veneau din `PONDERI_NOD`:
un tabel de probabilități din care fiecare nod își trăgea tipul singur, cu o
aruncare de zar, fără să știe nimic despre vecinii lui. Ponderile erau reglate
frumos pe adâncime — Elita creștea spre final, Odihna la fel.

Numai că o pondere răspunde la o singură întrebare: „cât de des vreau tipul
ăsta?". Toate cele trei plângeri sunt despre cu totul altceva — „ce are voie să
stea LÂNGĂ ce?" și „câte ies în total?". Niciuna nu poate fi pusă unui zar
aruncat per nod: zarul n-are nici vecini, nici memorie. **Era genul greșit de
unealtă, nu o cifră prost aleasă.**

### Ce a luat locul ponderilor

Patru etape, în `autoload/expeditie.gd`:

| etapă | funcția | ce face |
|---|---|---|
| împarte | `proportii()` + `reteta()` | câte noduri din fiecare tip. Fix, din constante. Sămânța n-are niciun cuvânt |
| plasează | `_o_incercare()` | le așază, de la tipul cel mai constrâns la cel mai liber |
| verifică | `_reguli_picate()` | toate cele nouă reguli, peste harta gata |
| reîncearcă | `_pune_tipurile()` | altă sub-sămânță, până la 200 de ori |

Cele nouă reguli sunt nouă funcții mici, fiecare cu numele ei. **Nu un `if`
mare**, fiindcă atunci când rețeta se ceartă cu regulile — și s-a certat de două
ori în sesiunea asta — singurul lucru folositor e NUMELE regulii vinovate.

Toate se verifică pe PERECHI DE VECINI, în orice sens. Drumurile se merg în
amândouă sensurile, deci „la rând" nu înseamnă „după", ci „lipite". O regulă
scrisă pe `spre` ar fi fost adevărată pe desen și falsă în joc.

### Prima ceartă: „Elită după 3 lupte" n-avea nicio soluție

Cerută: o Elită apare abia după trei noduri de bătaie. Am căutat **exhaustiv**
înainte s-o scriu:

| | harta_01 (14 noduri) | harta_02 (16) |
|---|---|---|
| aranjamente posibile | 1.663.200 | 25.225.200 |
| cu pragul 3 | **0** | **0** |
| cu pragul 2 | 28 | 734 |

Zero. Nu rar — imposibil. Și e o proprietate a FORMEI, nu a cifrei: Startul e
Luptă, vecinii lui sunt Lupte, iar imediat după ei harta se despică în două
brațe, amândouă la exact 2 lupte minime. Ca să urci un nod la 3, trebuie un al
treilea nod de bătaie pe FIECARE drum care ajunge la el — iar rețeta lasă 4
Lupte libere.

**Decizie: pragul Elitei coboară la 2.** Consecința de acceptat: o Elită poate
cădea al treilea nod al expediției. Dacă vreodată revrem 3, prețul nu e cifra, ci
rețeta — Evenimentele trebuie să scadă de la 3 la 1 ca Luptele să urce la 6.

### A doua descoperire: amestecarea la întâmplare nu funcționează deloc

Planul era „pune tipurile într-un sac, amestecă, împarte, verifică, reîncearcă".
Măsurat înainte de scris: din 1.663.200 de aranjări ale rețetei pe `harta_01`,
doar **28** trec toate regulile. O șansă la ~59.000 — în 200 de încercări n-ai
nimeri niciodată.

Deci plasarea e conștientă de reguli: fiecare tip se pune DOAR pe pozițiile pe
care regula LUI le permite, iar restricțiile de vecinătate se verifică în clipa
așezării. Verificarea completă rămâne pe urmă, ca plasă — plasarea e lacomă,
deci produce aranjări pe care nu le-a văzut venind.

**Ordinea tipurilor contează, și a fost măsurată.** Odihna e cel mai greu de
plasat (trei bucăți, două reguli de vecinătate peste ele) și merge prima;
Magazinul e printre cele mai ușoare și merge aproape ultimul. Cu ordinea inversă,
`harta_02` eșua pe 11 semințe din 500. Aceleași reguli, aceeași rețetă, doar altă
ordine. **Regula generală, dacă mai apare un tip: cel mai constrâns, primul.**

### A treia ceartă: rețeta nu încăpea pe panglică

Panglica generată de 14 noduri pica pe 29% din semințe. Diagnostic: cu 2 Odihne
în loc de 3, rata cade la 0%; dacă scot în schimb regula „doi de același fel la
același vecin", rămâne la 30%. Deci vinovat e „fără două Odihne vecine" pe o
panglică lată de doar 2 noduri — Odihnele au voie doar în straturile 3–6, una e
fixată lângă Boss, iar a treia n-are unde sta.

**Reparația nu e o cifră, e un plafon măsurat.** `reteta()` întreabă harta din
față: care sunt pozițiile pe care tipul ăsta are voie să stea, și câte din ele se
pot alege deodată fără să se calce pe reguli. Nicio plasare, oricât de norocoasă,
nu poate pune mai multe. Ce se taie se dă Luptelor — ele sunt DISTANȚIERELE.

Varianta ieftină era „la 14 noduri, două Odihne". Ar fi mers azi și ar fi mințit
mâine: cifra 2 n-ar fi fost o regulă, ci amprenta unei forme anume. Prima planșă
nouă de 14 noduri, mai lată, ar fi primit două fără ca nimeni să știe de ce.

`harta_01` are tot 14 noduri și își păstrează cele 3 Odihne — fiindcă e mai
ramificată decât panglica. Plafonul se uită la formă, nu la numărul de noduri.

### Cifrele finale, pe 500 de semințe

| sursă | media încercărilor | maxim | semințe eșuate |
|---|---|---|---|
| `harta_01.json` (cea jucată) | **1,37** | 7 din 200 | **0 / 500** |
| `harta_02.json` | **2,86** | 18 din 200 | **0 / 500** |
| panglica generată (12/14/16) | **4,52** | 60 din 200 | **0 / 500** |

Aceeași sămânță dă aceeași hartă, verificată pe toate trei sursele, comparând
tot ce se salvează despre fiecare nod — nu doar tipurile. Un generator care dă
hărți bune, dar de fiecare dată altele, face imposibil orice raport de bug.

### Ce s-a mai curățat pe drum

- **`_asigura_magazin()` a dispărut.** Era cârpitul care transforma un nod în
  Magazin dacă zarurile nu scoseseră niciunul. Cu proporții fixe, Magazinul e
  garantat prin construcție — nu mai e nimic de cârpit.
- **Formula bugetului avea trei case** (cele două generatoare și cârpitorul), și
  exact de-aia al treilea o putuse uita în tăcere. Acum are un nume,
  `_buget()`, și o singură casă. Aceeași lecție ca la cardul care mințea.
- **`vecini()` are acum un frate static, `vecinii_din()`.** Regulile se sprijină
  toate pe „cine e vecin cu cine"; dacă generatorul ar fi avut citirea lui
  proprie a lui `spre`, ar fi existat două definiții ale cuvântului „vecin" în
  același fișier. Una s-ar fi schimbat într-o zi, cealaltă nu — iar harta ar fi
  trecut o verificare pe care jocul n-o respectă.
- **Scalarea proporțiilor se face cu rest**, nu rotunjind fiecare tip separat.
  Rotunjirea pe rând urca fiecare tip special la „.5" în sus, iar Luptele —
  singurele fără cifră proprie — plăteau toată nota. La 12 noduri ieșeau 8
  noduri speciale din 10 în loc de 7.

### Unelte

- **`tools/verifica_tipuri.gd`** (nou) — 500 de semințe × toate sursele. Media
  și maximul încercărilor, de câte ori a picat fiecare regulă, semințele care au
  atins limita, și proba că aceeași sămânță dă aceeași hartă. Avertizează singur
  când o regulă pică în peste jumătate din încercări: aia nu mai e o regulă
  strictă, e una care se ceartă cu altceva.
- **`tools/verifica_plansa.gd`** — verificare nouă (9): orice nod în afară de
  Start și Boss are cel puțin doi VECINI. Verificarea (4) de dinainte număra
  IEȘIRILE (drumurile cu sensul lor); asta numără vecinii, cum îi citește jocul.
  Distanța minimă dintre noduri era deja acolo, verificarea (7).

### Datorie tehnică deschisă

`Plansa.adancimi()` merge numai pe sensul scris al drumurilor, deși jucătorul
merge în amândouă. Nu e o scăpare — adâncimea e „a câta treaptă a vrut
desenatorul", iar bugetul se socotește din ea. Dar regulile noi folosesc
`_pasi_de_la()`, care merge în amândouă sensurile, fiindcă ele vorbesc despre cât
de departe e nodul PENTRU JUCĂTOR. Două măsuri, două scopuri, amândouă
documentate — dar merită reverificat când se atinge bugetul de dificultate
(pasul 10).

Fișiere atinse: `autoload/expeditie.gd`, `tools/verifica_plansa.gd`,
`tools/verifica_tipuri.gd` (nou), `tools/verifica_tipuri.tscn` (nou).

---

## CARDUL NU MAI MINTE (23 septembrie 2026) — cifra afișată = cifra care doare

**Plângerea:** la nodul de Elită, fereastra de info a Spadasinului scria „4 daune
in fiecare tura", dar el lovea cu 6.

**Cauza.** Greutatea nodului (`DATE_NOD[...]["putere"]`, 1,6 la Elită, 2,3 la
Boss) se aplica în două locuri — PV-ul inamicului și `daune_inamic()` (cifra de
lângă sabie și lovitura reală) — dar `text_comportament()`, care scrie rândul
„Comportament" din card, citea `date["daune"]` DIRECT din tabelul `INAMICI`.
Deci cardul raporta cifra de bază: 4. Lupta folosea 4 × 1,6 = 6.

**Reparația.** O funcție nouă, `_cu_puterea_nodului(valoare)`, care face
înmulțirea, rotunjirea și `maxi(..., 1)` într-un singur loc. Toate trei locurile
trec acum prin ea: PV-ul, `daune_inamic()` și textul cardului.

**Lecția, fiindcă e o lecție și nu un typo:** formula era scrisă de două ori, și
exact de-aia al treilea loc a putut s-o uite în tăcere. Când o cifră se
TRANSFORMĂ înainte de a fi folosită, transformarea trebuie să aibă un nume și o
singură casă — altfel fiecare consumator nou o reimplementează sau o sare, iar
bug-ul nu arată ca un bug, arată ca un dezechilibru („parcă Elita lovește prea
tare"). Același argument pentru care `inamic()` există în locul lui
`INAMICI[inamic_curent]`.

**Ceasul NU se înmulțește** — nici înainte, nici acum. `ceas_max()` întoarce
cifra din tabel neatinsă, deci o Elită Grabnică lovește mai tare, nu mai des.
Textul cardului respectă asta.

Fișier atins: `scenes/lupta/lupta.gd`.

---

## ATERIZAREA ARE GREUTATE (23 septembrie 2026) — slam, zguduit, răgaz

Patru reglaje mici, toate pe același moment: clipa în care figurina atinge nodul
ales. Trei erau plângeri („piesa e prea mare", „întrebările apar prea repede",
„bara verde se umple la început"), a patra o cerere („să arate ca un slam").
Le-am ținut într-o singură sesiune fiindcă primele trei sunt exact ce strica
momentul pe care a patra vrea să-l scoată în evidență.

### 1. Figurina, cu un sfert mai mică

`FigurinaHarta.INALTIME_FATA_DE_NOD`: **1,45 → 1,09**.

Un singur număr, fiindcă e un RAPORT față de latura nodului, nu pixeli — deci
rămâne valabil la orice mărime de fereastră. 1,45 era măsura din harta de
referință (acolo piesa era cu aproape jumătate mai înaltă decât semnul de sub
ea), dar pe harta noastră nodurile stau mai des decât acolo și umbra piesei
ajungea peste vecina de deasupra.

`ADANCIME_TALPA` a rămas 0,20 și e important că a rămas: adâncimea e o fracțiune
din NOD, nu din piesă. Talpa coboară la fel de mult sub centru ca înainte, deci
piesa stă în continuare PESTE semn, nu lângă el — doar că acum acoperă mai puțin
din X-ul de „parcurs". Exact ce vrei: mai vezi că ai fost acolo.

### 2. Săritura, desfăcută în două etape

Vechea săritură era un `sin` pe toată durata: un arc perfect, cu aceeași viteză
la plecare și la sosire. Arăta corect și nu se simțea nimic — **o mișcare cu
viteză constantă n-are moment.** Ochiul vedea un obiect plutind dintr-un loc în
altul, nu o piesă trântită pe masă.

Acum sunt două `tween_method` puse cap la cap, fiecare cu curba LUI:

| etapă | durată | curbă | ce face |
|---|---|---|---|
| urcare | 0,30 s | `EASE_OUT` + `TRANS_QUAD` | încetinește spre vârf, ca orice lucru aruncat în sus |
| slam | 0,09 s | `EASE_IN` + `TRANS_QUAD` | accelerează, aproape pe verticală |

Două lucruri de reținut din asta:

**Viteza slam-ului nu vine din altă formulă.** Vine din faptul că aceeași
înălțime se parcurge în a treia parte din timp. Raportul 0,30 / 0,09 ESTE
efectul; nu e nimic „de slam" scris nicăieri în cod.

**`PARTE_ORIZONTALA_LA_URCARE = 0,88`** e ce face căderea să fie „în pământ", nu
„spre nod". 0,5 ar fi însemnat un arc simetric, adică vechiul `sin` scris în două
bucăți. La 0,88, în vârf piesa e deja aproape deasupra țintei, deci la cădere
rămâne de făcut aproape numai verticala. Peste 0,95 începe să arate ca o oprire
în aer urmată de o cădere separată — două mișcări, nu una.

Curbele stau pe TWEENER, nu pe tween (`.tween_method(...).set_ease(...)`). Pe
tween ar fi fost o singură curbă pentru amândouă etapele — adică fix simetria pe
care voiam s-o rupem.

Suma (0,39 s) e aproape cât dura săritura veche: expediția nu s-a lungit, doar
timpul s-a împărțit altfel înăuntru.

### 3. Zguduitul — și de ce NU stă în figurină

Piesa cade greu; dacă harta de sub ea nu simte nimic, slam-ul rămâne o animație
a piesei, nu o lovitură dată hârtiei.

`_zguduie()` e în `harta.gd`, nu în `figurina_harta.gd`, și ăsta e același
principiu ca peste tot: **piesa nu știe că e un ecran în jurul ei.** Ea
semnalează „am ajuns" (`salt_terminat`), iar cine ascultă hotărăște ce face cu
informația — la fel ca la deschiderea nodului.

E scris ca `impact.gd` din luptă (cronometru + `sin` + stingere liniară), dar
n-am refolosit fișierul de acolo: acela e un ÎNVELIȘ, un nod care ține o figură
înăuntru și o clatină. Aici n-avem ce înveli — zguduim straturi care există deja.

Cifrele: 0,26 s, 7 px pe verticală (direcția loviturii) plus o treime din asta pe
orizontală, cu frecvențe în raport 1 : 0,63 ca traseul să nu treacă de două ori
prin același loc.

**Amănuntul care se vede imediat dacă îl greșești:** se clatină toți copiii
ecranului MAI PUȚIN `Fundal`. Fundalul acoperă exact fereastra, deci clătinat
odată cu restul ar lăsa la fiecare oscilație o dungă de câțiva pixeli pe margine,
prin care se vede culoarea cu care Godot șterge fereastra. Ținut nemișcat, dunga
aia ESTE fundalul — adică nu se vede nimic.

Și nu e o listă scrisă de mână („pergamentul, pânza, marginile"): e `get_children()`
minus fundalul, deci panoul următor adăugat în scenă se va clătina singur.

Pozițiile de bază se strâng la ÎNCEPUTUL fiecărui zguduit, nu la `_ready()` —
altfel o redimensionare de fereastră ar fi readus harta, după zguduit, exact unde
era înainte de ea. Poziția se scrie absolut (bază + abatere), niciodată adunând:
un efect întrerupt la mijloc ar fi lăsat harta mutată pe veci.

### 4. Răgazul de după aterizare

`PAUZA_DUPA_ATERIZARE := 0,5` în `harta.gd`, așteptat în `_sari_pe()` după
`salt_terminat`.

Fără el, ultimul cadru al săriturii și primul cadru al luptei erau unul lângă
altul: mutarea se juca degeaba, fiindcă n-apucai s-o vezi ÎNCHEIATĂ. Cele 0,26 s
ale zguduitului încap în cele 0,5 ale pauzei, deci apuci să vezi harta așezându-se
la loc înainte să plece ecranul.

**`_sare` și-a schimbat înțelesul, și e scris în cod.** Rămâne ridicat și în
timpul pauzei, deși piesa nu mai e în aer: în jumătatea aia de secundă harta e
încă pe ecran și nodurile ar primi clicuri, iar două clicuri repezi ar porni două
mutări — a doua peste un rezultat care încă nu s-a întâmplat. Acum nu mai
înseamnă „piesa e în aer", înseamnă „ecranul nu primește comenzi".

### 5. Barele de la începutul luptei

Bara verde de PV se umplea vizibil în prima fracțiune de secundă a luptei — ca și
cum jocul tocmai îți dăduse viață, exact înainte de prima întrebare.

Cauza n-a fost o animație pusă din greșeală, ci **o desincronizare între două
momente**: `reseteaza_lupta()` punea `max_value`, dar `value` rămânea cea salvată
în scenă (15, din editor) până la prima `actualizeaza_ui()` — iar aia ANIMEAZĂ.
Deci bara pornea de la o stare care n-a existat niciodată și aluneca spre cea
adevărată.

Soluția e o funcție nouă, `pune_bara_acum(bara, maxim, valoare)` — perechea fără
animație a lui `anima_bara()`. Pune maximul și valoarea ÎMPREUNĂ, într-un singur
loc, și omoară tween-ul rămas în curs (un reset cerut din butonul de test poate
prinde o bară încă alunecând de la lovitura dinainte).

Regula generală de reținut: **alunecarea spune „s-a schimbat ceva CHIAR ACUM".**
La începutul unei lupte nu s-a schimbat nimic — regele intră în arenă cu PV-ul cu
care a ieșit din nodul de dinainte. O stare moștenită se PUNE, nu se animează.

Aplicat la toate trei barele (PV jucător, PV inamic, ceas): inamicul avea exact
aceeași scăpare, doar că se vedea mai puțin. Am scos și linia rămasă din
`_ready()` care punea `bara_pv_jucator.max_value` cu `pv_max_jucator` încă 0 —
maximul lui nu mai e o constantă de când vine din `Expeditie`.

### Butoanele de reglat

`DURATA_SLAM` (mai mic = mai violent; sub 0,06 cade sub un cadru-două la 60 FPS
și dispare cu totul), `AMPLITUDINE_ZGUDUIT`, `PAUZA_DUPA_ATERIZARE`,
`INALTIME_FATA_DE_NOD`.

### Verificarea

Proiectul deschis în editor headless (`--headless --editor --quit`): toate
scripturile compilează, exit 0. Harta rulată 120 de cadre headless: fără erori de
script (doar avertismentul știut pentru fișierele audio, care nu sunt în repo).

---

## DRUMURILE MERG ÎN AMÂNDOUĂ SENSURILE (23 septembrie 2026)

Plângerea, la sămânța 37: stând în nodul C3 se putea merge doar spre dreapta,
deși pe pergament se vedeau limpede drumuri și spre stânga — către o Elită și
către o Luptă. Bănuiala era corectă: `accesibile()` citea doar câmpul „spre” al
nodului curent, iar „spre” e un graf cu UN SINGUR SENS. Un drum tras `W2 → C3`
nu apărea ca opțiune stând în C3, deși pe desen arată identic cu unul care pleacă
din el. Desenul nu are săgeți; datele aveau.

### Ce s-a schimbat, și ce NU s-a schimbat

**Formatul a rămas neatins.** „spre” se scrie mai departe cu un singur sens — așa
îl produce generatorul, așa e scris în planșele din `data/harti/`, așa se
salvează. Nimic din ce există pe disc nu s-a stricat.

S-a schimbat doar CITIREA, și într-un singur loc: `Expeditie.vecini(id)`. Ea
întoarce și nodurile din „spre”, și nodurile care au un „spre” către tine. Tot
restul jocului întreabă funcția asta; nimeni nu mai citește „spre” ca să
navigheze. Dacă vezi mâine `nod["spre"]` folosit pentru altceva decât desen sau
generare, e un bug.

### Cele două reguli din `accesibile()`

1. **Un nod parcurs e tăiat definitiv.** Înainte regula era gratuită (graful
   mergea într-un sens, deci n-aveai cum să te întorci); acum ea e singurul lucru
   care ține harta să se consume. Fără ea, doi vecini ar fi o buclă infinită.

2. **Din nodul oferit trebuie să se mai ajungă la Boss**, pe un drum care nu
   trece prin noduri parcurse. Asta a fost partea grea și e chiar miezul
   sesiunii.

### De ce a doua regulă nu era opțională

Cu mersul înapoi permis, te poți băga într-un braț al hărții a cărui singură
ieșire e chiar nodul pe care tocmai l-ai ars. Nu e un caz de colț:

| hărți | înfundări fără a doua regulă |
|---|---|
| `harta_01.json` | **59%** din rulări |
| `harta_02.json` | 40% |
| hărți generate (200 de semințe) | 48% |
| grafuri la întâmplare (400 de forme) | 23% |

Și o înfundare NU se poate repara la fața locului: când bagi de seamă că n-ai
unde merge, mutarea greșită e cu cinci noduri în urmă. Singurul lucru pe care
ți l-ar mai putea oferi jocul e „ai pierdut, din motive care nu țin de tine”.

De-aia drumul se închide ÎNAINTE să intri pe el, nu după. Un drum refuzat din
timp nu e o pedeapsă; e chiar felul în care harta rămâne o hartă.

### Verificarea: `tools/verifica_drumuri.gd`

```
godot --headless --path . res://tools/verifica_drumuri.tscn
```

16 000 de expediții jucate cu alegeri la întâmplare, pe planșele reale, pe hărți
generate și pe 400 de grafuri construite pe loc (cu aceleași garanții pe care
`verifica_plansa.gd` le cere de la o planșă desenată de mână). **Zero înfundări
cu regula din joc.**

Două lucruri l-au făcut să fie o verificare, nu o părere:

- **Nu-și scrie propriul `accesibile()`.** Pune harta în `Expeditie` și cheamă
  funcțiile adevărate, exact cum face ecranul când apeși pe un nod. O simulare
  care și-ar fi copiat regula ar fi verificat copia.
- **Are un martor.** Fiecare hartă se joacă de două ori: o dată cu regula din
  joc, o dată cu regula naivă („orice vecin nevizitat”). Coloana din tabelul de
  mai sus e chiar martorul ăsta. Fără el, „zero înfundări” ar fi putut însemna
  la fel de bine că harta n-avea cum să se înfunde.

  *Martorul a avut el însuși un bug, la prima rulare:* raporta 0 înfundări peste
  tot. Se oprea prin `la_capat()`, care întreabă `accesibile()` — adică tocmai
  plasa pe care se prefăcea că n-o are. Un martor care se sprijină pe ce testează
  nu e martor.

Pe lângă înfundări se verifică patru invarianți la fiecare pas: nicio opțiune
deja parcursă, fiecare opțiune chiar legată de nodul curent, distanța până la
Boss mereu un număr real, și expediția se încheie la Boss, nu oriunde.

### Ce s-a mai atins (locurile care presupuneau sens unic)

- **`pasi_pana_la_boss()`** — BFS-ul merge acum prin `vecini()` și ocolește
  nodurile parcurse. Altfel antetul ar fi răspuns la altă întrebare decât cea pe
  care o pune jucătorul.
- **`la_capat()`** — nu mai înseamnă „n-am unde merge”, fiindcă Bossul ARE acum
  vecini (măcar nodul din care ai venit). Capătul se numește pe nume: ești la
  Boss. Vechea verificare a rămas doar ca plasă pentru o hartă stricată.
- **Desenul drumurilor (`harta.gd::_muchii`)** — „parcurs” și „deschis” se
  întreabă în amândouă sensurile. Bucla merge pe „spre”, adică pe cine a TRAS
  drumul, ceea ce n-are nicio legătură cu încotro l-ai mers tu.
  `_sunt_vecini_in_drum()` a rămas cu sens (parcursul e un traseu, iar un traseu
  are o ordine); apelantul întreabă de două ori.
- **`verifica_plansa.gd`, regula (4)** — rămâne, dar cu alt motiv scris în
  comentariu. Un nod fără ieșire proprie nu mai încheie expediția la jumătate; e
  un nod din care nu se mai ajunge la Boss decât înapoi prin cel curent, deci
  unul pe care `accesibile()` nu ți-l va oferi aproape niciodată. Desenat pe
  hârtie și mort — cel mai supărător fel de greșeală, fiindcă arată bine.

### Efectul în joc

La sămânța 37, după `S → T → K → C3`, opțiunile sunt acum C4 (Luptă), W2 (Elită)
și W3 (Eveniment) — exact cele trei drumuri care se văd pe pergament. Pe
`harta_01`, un run poate ajunge de la 7 noduri (drumul scurt) la 14 (toată harta),
în loc de 7–9 cât era înainte. Harta a devenit brusc mai mare fără să i se adauge
niciun nod.

---

## COLȚUL DE JOS-DREAPTA (23 septembrie 2026) — un nod împins lângă Boss

Plângerea: nodul cel mai din dreapta din jumătatea de jos (la sămânța 556,
Monedele) se oprea cu vreo 40 px în stânga Bossului, deși în dreapta lui mai
era hârtie bună. Harta părea că se strânge la loc după ce ajunsese la capăt.

### Prima descoperire: pozițiile NU depind de sămânță

Bănuiala era că pozițiile se generează procedural. Nu se generează. De la
comutarea pe `SURSA_HARTII = DESENATA`, poziția fiecărui nod vine din
`data/harti/harta_01.json` și e **aceeași la orice sămânță** — sămânța alege
doar TIPURILE (Monede, Luptă, Elită…). De-aia la 556 acolo sunt Monedele și la
altă sămânță e altceva, dar mereu în același loc.

Nodul are în fișier `poz = [0.9475, 0.7157]`, Bossul `[1.0, 0.1546]`. Deci
diferența de 40 px nu era un jitter, nici o zonă de excludere: e chiar desenul.

### A doua descoperire: ce-l ținea acolo

`ZONA_PERGAMENT` se oprește la **0,838** din lățime, ales anume **sub** carte,
ca să nu mai fie nevoie de nicio excepție care s-o ocolească. E o margine
dreaptă trasă după cel mai îngust loc al hârtiei — și de-aia plătită peste tot.
Cotorul cărții e înclinat: măsurat în `campaign_map.jpg`, e pe la **0,905** la
înălțimea 0,60 și pe la **0,855** la 0,85. Fâșia dintre 0,838 și cotor e hârtie
bună, pe care marginea dreaptă o aruncă.

Pe scurt: o margine simplă, plătită cu un colț.

### Ce s-a schimbat

O **excepție țintită**, nu o lărgire a zonei — zona rămâne exact cum e, fiindcă
ea e ce ține toate celelalte noduri departe de carte fără niciun `if`.

`Harta.impinge_nodul_de_jos_dreapta()` rulează DUPĂ geometrie, pe centrele gata
calculate, și mută un singur nod pe orizontală:

- **cine e nodul** — o descriere, nu un id: dintre nodurile de sub mijlocul
  DESENULUI, cel cu x-ul cel mai mare, fără Boss. Merge pe orice planșă.
- **până unde** — `x_Boss + PESTE_BOSS` (24 px).
- **ce-l oprește** — cotorul cărții (`CARTE_SUS` / `CARTE_JOS`, două puncte pe o
  dreaptă, în fracțiuni din dreptunghiul REAL al texturii, deci corecte la orice
  mărime de fereastră), marginea pânzei, și `DISTANTA_MINIMA_NODURI = 72` față
  de orice vecin. Dacă limitele îl țin pe loc, nodul nu se mută — un nod la
  locul lui vechi e corect, unul peste carte nu e.
- **drumurile** — trase după el cu o pondere `smoothstep` care scade de la 1 în
  capăt la 0 după 260 px de drum. Nu se pot translata întregi: celălalt capăt e
  lipit de un nod care nu se mișcă. Tăierea la marginea cernelii se face după,
  ca la orice drum — `_muchii()` nu știe că s-a mutat ceva.

Structura nu se atinge: același număr de noduri, aceleași legături, aceeași
distanță în pași până la Boss.

### De ce doar pe planșă

Funcția n-ar avea nimic împotriva panglicii, dar chemarea se face doar pe harta
DESENATĂ. Măsurat pe 300 de semințe: pe panglică regula ar împinge nodul cu
**până la 326 px** și l-ar lipi de vecin la fix 72 px, fiindcă panglica își
termină ultimul strat departe de marginea din dreapta *cu intenție*. Încrucișări
noi n-ar apărea (verificat, 0 din 300) — deci nu ăsta e motivul. Motivul e că
panglica are deja un răspuns la „unde stă nodul ăsta", iar două sisteme care
răspund la aceeași întrebare sunt un sistem și o eroare.

### Verificarea

`tools/verifica_coltul.gd` — rulează fără fereastră:

```
godot --headless --path . res://tools/verifica_coltul.tscn
```

Pe amândouă planșele × 7 semințe (56, 556 și 5 luate la nimereală), plus
măsurătoarea de pe panglică. Rezultat pe `harta_01.json`, identic la toate
semințele (cum și trebuie):

| | înainte | după |
|---|---|---|
| x-ul nodului | 827,1 | **893,4** (Bossul: 869,4) |
| aer până la cotor — nod | — | 39,0 px |
| aer până la cotor — drumuri | — | 101,4 px |
| cea mai mică distanță între noduri | 125,2 px | 125,2 px |
| încrucișări de drumuri | 0 | 0 |

Pe `harta_02.json` (nejucată azi, dar a doua formă de digerat): 715,7 → 892,4,
aer 44,9 px, vecini 93,4 → 77,3 px (peste pragul de 72), 0 încrucișări.

**Niciun caz în care nodul n-a putut fi mutat.** Fișa întoarsă de funcție are
câmpul `oprit_de` (`carte` / `pânză` / `vecin`) tocmai pentru ziua în care va
exista unul.

### Datorie tehnică deschisă

`CARTE_SUS` / `CARTE_JOS` sunt **măsurate de mână din imagine**. Cartea e
pictată în `campaign_map.jpg`, nu e un nod de scenă, deci codul n-are pe cine
întreba unde e. Fracțiunile se întind peste dreptunghiul real al texturii, deci
ferestrele de alte mărimi sunt acoperite — dar **dacă se schimbă imaginea de
fundal, cele două perechi trebuie remăsurate.** Sunt singurul lucru din regulă
care nu se poate afla singur.

---

## DRUMUL AJUNGE LA ICOANĂ (23 septembrie 2026) — tăiat pe alfa, nu pe o rază

Plângerea: între capătul liniei punctate și simbolul nodului rămânea un gol.
Cel mai vizibil la săbii — subțiri și în diagonală — unde arăta ca și cum
drumul nici nu ducea acolo.

### De ce apărea

Nu din marginile transparente ale PNG-urilor (bounding box-ul alfa e strâns:
29–483 din 512) și nu din tiparul de liniuțe. Din `OPRIRE_LA_NOD := 56`:
**o rază fixă, aceeași în toate direcțiile.** O rază fixă presupune că fiecare
simbol e un DISC. Niciunul nu e. Măsurat, cerneala de la centru spre afară:

| icoană | pe orizontală | în diagonală | oprirea veche |
|---|---|---|---|
| săbii | 8 px | 42 px | 56 px |
| coroană (boss) | 30 px | 42 px | 56 px |
| craniu | 23 px | 40 px | 56 px |
| foc de tabără | 18 px | 32 px | 56 px |

La săbii, pe orizontală: **48 px de gol.** Exact ce se vedea.

### Ce s-a schimbat

Drumul se taie acum la **ultimul pixel de cerneală al icoanei**, citit din
imagine:

- `Silueta.pregateste_caseta()` — aritmetica de casetă și pivot a ieșit din
  `_draw()` ca s-o poată chema și altcineva. Aceeași formulă, un singur loc.
- `SimbolNod.are_cerneala(punct_local)` — merge PE DOS prin
  `_deseneaza_imaginea()`: din pixel pe ecran înapoi în alfa din PNG, desfăcând
  respirația (luată la maxim, ca drumul să nu intre sub simbol când pulsează) și
  înclinarea. `Image` cache-uit pe clasă, cu `decompress()`.
- `Harta._taiat_la_simboluri()` — pipăie drumul din centru spre afară, din
  pixel în pixel, **pe curbă**, pe o bandă lată cât liniuța, și ține ULTIMUL
  „da" (nu primul „nu": simbolurile au goluri — focul, coroana). Plus
  `RESPIRO_DRUM := 3`, singurul număr de reglat. Se calculează **o dată**, la
  reașezarea hărții.
- `panza.gd` — nu mai primește `"oprire"` și n-o mai folosește: primește drumul
  gata tăiat. În plus, tiparul de liniuțe nu mai curge cu `fmod`, ci se
  distribuie: `n` liniuțe de 15 px fix, cu pauzele întinse ca să umple exact
  drumul, deci **fiecare drum începe ȘI se termină cu o trăsătură plină**.

`OPRIRE_LA_NOD` rămâne, dar doar ca plasă: nodurile fără PNG (desenate din
poligoane) n-au alfa de citit. E folosită și în verificatoarele din `tools/`,
unde e zona de lângă nod în care încrucișările nu se numără.

Măsurat pe harta `harta_01.json`: tăieturile variază acum între **7,8 și 45,9 px**
per capăt, după icoană și direcție, față de 56 uniform. Amândouă verificatoarele
headless trec neschimbate.

### De reținut

Tăierea e literal „unde se termină cerneala PE DIRECȚIA AIA". La o icoană
concavă, ca săbiile încrucișate, asta înseamnă că linia poate intra în cutia
simbolului și se poate opri aproape de centru — acolo chiar nu e desen. Dacă
vreodată pare că drumul trece prin icoană, `RESPIRO_DRUM` e butonul.

---

## HARTA UMPLE PERGAMENTUL (23 septembrie 2026) — pânza ia toată pagina

Plângerea era simplă și se vedea dintr-o privire: nodurile stăteau înghesuite
în mijlocul hârtiei, cu pergament nefolosit sus, în stânga și în dreapta. Nu
era o problemă de „mai mărește ceva cu 20%", ci de unde venea dreptunghiul în
care încăpeau nodurile.

### De unde venea strâmtoarea

Trei lucruri mâncau hârtie, și doar unul se vedea:

1. **Pânza stătea sub antet.** În `harta.tscn`, pânza era ultima căsuță dintr-o
   coloană: antet, linia de unelte, pânză, picior. Coloana îi dădea ce rămânea —
   un dreptunghi care începea la 95 px de sus și se oprea la 87 px de jos. Din
   604 px de pagină, pânzei îi rămâneau 497.
2. **`ZONA_PERGAMENT` era trasă mai strâns decât hârtia.** Marginile de sus,
   stânga și jos lăsau liber mai mult decât cerea desenul fundalului.
3. **Cutia planșei se scalează UNIFORM.** Zona avea raportul 2,01, planșa
   1,8055 — deci planșa primea 717 din 797 px de lățime, iar 40 px rămâneau goi
   în fiecare parte. Asta NU e o greșeală (vezi `Plansa.cutie`: o cutie întinsă
   ar turti curbele), dar e o consecință: **cu cât zona seamănă mai puțin la
   proporție cu desenul, cu atât se pierde mai mult.**

Punctul 1 le rezolvă pe toate trei deodată, și ăsta e lucrul de reținut: o
pânză mai ÎNALTĂ nu doar că are mai mult loc, dar are și raportul mai aproape
de 1,8055 — deci fâșia pierdută la centrare se topește singură.

### Ce s-a schimbat

**Pânza ține toată pagina, iar textul plutește peste ea.** Antetul, linia de
unelte și piciorul nu mai sunt deasupra hărții; sunt SCRISE pe hârtie, cu
`mouse_filter = IGNORE`, ca să treacă clicurile prin ele la noduri. Pe o hartă
desenată de mână asta e și mai corect tematic: titlul și legenda se scriu pe
pergament, nu lângă el.

**Linia de unelte s-a mutat în dreapta-sus, sub stare.** Era singurul text care
ajungea peste un simbol după ce pânza a crescut. Colțul din dreapta-sus e
oricum al textului, deci acolo nu deranjează pe nimeni.

**`ZONA_PERGAMENT` s-a lipit de hârtie pe trei laturi:** de la
`(0.035, 0.050, 0.803, 0.890)` la `(0.026, 0.042, 0.812, 0.906)`. Marginea din
DREAPTA a rămas la 0.838, neatinsă — e regula veche „niciun nod nu trece de
linia asta", care ține cartea legată în piele din colțul de jos departe de
noduri fără nicio excepție în cod.

### Cifrele, înainte și după (fereastra implicită, 1152 × 648)

| | înainte | după |
|---|---|---|
| pânza | 1088 × 497 | 1088 × 604 |
| zona utilă | 797 × 369 (raport 2,16) | 805 × 459 (raport 1,75) |
| cutia hărții desenate | 666 × 353 | 805 × 427 |
| cele mai apropiate două noduri | 103,5 px | 125,2 px |

Distanța dintre noduri a crescut cu 21% **fără să fi atins vreo formulă de
așezare**. Era cerută („vreau distanța puțin mai mare") și a ieșit din geometrie,
nu dintr-o constantă nouă de reglat — care e întotdeauna varianta bună.

### Ce s-a verificat

`tools/verifica_harta.gd` a rulat pe 300 de semințe, pe toate patru traseele
generate, după schimbare: zero muchii sărite, zero încrucișări în graf, zero
încrucișări în desen, zero noduri ieșite din zonă. Harta GENERATĂ n-a fost
atinsă — doar dreptunghiul în care se desenează a crescut.

Verificatorul a trebuit reparat în două locuri:

- **`_zona_de_test()` copia vechea așezare** (scădea o înălțime de antet).
  Acum oglindește pagina nouă: pânza = ecranul minus marginile.
- **Un prag de zero a devenit un prag de o zecime de pixel.** Traseul VAL
  pleacă din fracțiunea 0,0 a zonei și se termină în 1,0 — adică exact pe
  margini. Un punct calculat prin curbe și normale nimerește marginea cu o
  eroare de **0,000122 px**, iar `> 0` citea asta ca ieșire din hârtie: 300 de
  hărți „picate" pentru o zecime de miime de pixel. `TOLERANTA_PIXEL := 0.1` e
  sub ce poate desena ecranul, deci sub ea nu mai e un defect, e aritmetică.
  (Aceeași lecție ca la `DISTANTA_MINIMA_BANDA`: cu virgulă mobilă nu ceri
  egalitate, lași o margine.)

### Ce a rămas gol, și de ce e în regulă

Fâșia de hârtie din dreapta-sus. Zona utilă e un DREPTUNGHI, iar unul care ar
ajunge până în colțul acela ar coborî și peste carte. Ca s-o folosim ar trebui
ori o zonă în formă de L — adică exact excepția de ocolit pe care am scos-o
odată —, ori o planșă desenată mai lată (raport spre 2,0 în loc de 1,8055).
A doua variantă e **date, nu cod**, deci e ieftină oricând, dacă merită.

---

## HĂRȚI DESENATE (22 septembrie 2026) — forma din fișier, conținutul din sămânță

Harta nu mai are o singură sursă. Pe lângă generator, există acum **planșa**: un
fișier JSON în care nodurile și drumurile sunt puse cu mâna. Comutatorul e o
linie în `autoload/expeditie.gd`:

```gdscript
const SURSA_HARTII := Sursa.DESENATA    # sau Sursa.GENERATA
const PLANSA_IMPLICITA := Plansa.DOSAR + "harta_01.json"
```

Generarea și cele patru trasee (VAL, POTCOAVĂ, POTCOAVA OGLINDITĂ, ȘARPE) n-au
fost atinse: pe `GENERATA`, harta iese exact ca înainte, verificată.

**Tipurile nodurilor rămân trase din sămânță, în amândouă cazurile.** Planșa dă
forma, sămânța dă conținutul. Dacă aș fi scris „aici e Magazinul" în fișier,
harta s-ar fi învățat pe de rost după trei runuri.

### Ce e în fișier

Fracțiuni 0..1 dintr-o cutie cu un raport dat, nu pixeli — cutia se scalează
UNIFORM în zona utilă și se centrează, deci forma desenată rămâne forma văzută.
Un drum e o listă de puncte prin care trece o curbă netedă (Catmull-Rom, aceeași
funcție ca panglica: `Harta.curba_neteda`). Formatul complet e în antetul lui
`scenes/harta/plansa.gd`.

### Ce s-a despărțit: „stratul" era trei lucruri deodată

Pe harta generată, stratul era în același timp adâncimea, ordinea în listă și
capătul drumului. Pe o planșă se despart, și fiecare regulă a trebuit să spună pe
care se sprijină de fapt:

| Regula | Înainte | Acum |
|---|---|---|
| Startul e mereu Luptă | `adancime == 0` | nodul `start` din fișier |
| Capătul e mereu Boss | `adancime == straturi - 1` | nodul `boss` din fișier |
| Ponderi + buget | din adâncime | **neschimbat**, cu adâncimea = cea mai scurtă distanță de la Start |
| Magazinul, în a doua jumătate | din adâncime | **neschimbat** |
| Bossul e ultimul nod din listă | ieșea din generare | se construiește dinadins: noduri în ordinea adâncimii, Bossul pus ultimul |
| Coloana | a câta bandă de pe panglică | rangul în strat, de sus în jos pe desen (doar diagnostic) |

`_alege_tip()` primește acum „e startul?" și „e bossul?" în loc de „al câtelea
strat". Regula n-a fost schimbată — a fost **citită cum trebuie**: ea vorbea
mereu despre intrare și capăt, doar că adâncimea era, până acum, un mod corect de
a le afla.

Adâncimea nu mai e monotonă de-a lungul fiecărui drum. În `harta_01.json`, drumul
W2 → C3 pleacă de la adâncimea 4 și ajunge la 3, fiindcă la C3 se ajunge și
direct din K, mai scurt. Nu e o greșeală: asta înseamnă o scurtătură. Alternativa
(adâncimea = cel mai LUNG drum) ar fi făcut bugetul monoton, dar ar fi pedepsit
scurtăturile — mergi pe drumul scurt și te trezești cu inamicii drumului lung.

### Ce a devenit „nodul X din Y"

A devenit **„nodul 4, Bossul la cel puțin 3 pași"**. Vechiul text era adevărat pe
harta generată fiindcă toate traseele aveau exact atâtea noduri câte straturi. Pe
o planșă, un traseu are 7 noduri și altul 9 — iar un antet care scrie „din 9" cât
timp mergi pe drumul de 7 minte la fiecare pas, și nu se repară alegând celălalt
număr: niciunul nu e al DRUMULUI TĂU, fiindcă drumul tău nu e ales încă.

„La cel puțin atât" e adevărat pe orice hartă și pe orice drum, iar pe harta
generată dă exact numărul vechi (straturile rămase). Nu s-a pierdut informație —
s-a pierdut presupunerea că toate drumurile sunt egale. La înfrângere, sumarul
spune acum „Bossul mai era la 4 pași", care chiar măsoară cât de aproape ai fost.

### Verificatorul: `tools/verifica_plansa.gd`

```
godot --headless --path . res://tools/verifica_plansa.tscn
```

Trece prin TOATE fișierele din `data/harti/`. Motivul pentru care există e mai
important decât ce măsoară: **harta generată nu se poate încrucișa fiindcă e
construită așa; o planșă desenată de mână n-are nicio demonstrație.** Aici
verificarea nu mai e o plasă sub un argument — e singura garanție. Deci nu e un
test de regresie, e unealta de desen: o rulezi în timp ce desenezi.

- **Graful:** toate nodurile se ating din Start · din orice nod se ajunge la Boss ·
  fără cicluri · nicio fundătură în afară de Boss.
- **Desenul:** capetele drumurilor pe centrele nodurilor · drumurile nu se taie ·
  cea mai apropiată pereche de noduri ≥ 72 px · totul stă pe hârtie.
- **Conținutul, pe 300 de semințe:** Bossul pe ultimul nod · Startul mereu Luptă ·
  Magazinul prezent · toate nodurile ajung în hartă.
- **Informativ:** cel mai scurt și cel mai lung traseu, cât de aproape trece un
  drum de un nod străin, cum se împart tipurile.

**Rezultatul, pe ambele fișiere: totul verde.**

| | `harta_01.json` | `harta_02.json` |
|---|---|---|
| noduri / drumuri | 14 / 18 | 16 / 23 |
| cutia pe ecran | 717 × 397 px | 695 × 397 px |
| cea mai apropiată pereche | 111,4 px (C3–W4) | 80,8 px (C4–D4) |
| cel mai scurt traseu | S→T→K→C1→F1→W1→B (7 noduri) | S→A→B1→C1→D1→E1→Z (7 noduri) |
| cel mai lung traseu | S→T→K→C2→W2→C3→W3→W1→B (9 noduri) | S→A→B3→C4→D4→D3→E2→Z (8 noduri) |
| tipuri, 300 de semințe | Boss ✅ · Magazin ✅ · Start ✅ | Boss ✅ · Magazin ✅ · Start ✅ |

`harta_02.json` e desenată de la zero, ca exemplu de format: un drum care se
desface în trei culoare și se adună la Boss, cu un ocol pe culoarul de jos ca să
existe trasee de lungimi diferite.

### Ce am aflat măsurând: „hârtie" înseamnă altceva pentru un nod decât pentru un drum

Prima rulare a dat PICAT la „totul stă pe hârtie": drumul C4 → W4 din
`harta_01.json` trecea cu **1,1 px** dincolo de marginea zonei utile, fiindcă are
un punct desenat fix pe fracțiunea 1,0, iar curba netedă iese puțin în afara
punctelor ei la cotituri — exact cum o coardă întinsă iese din potcoavă.

Verdictul era greșit, nu desenul. Zona utilă e pergamentul micșorat cu o
**jumătate de nod** (46 px) plus margine, fiindcă un nod e un simbol de 92 px și
trebuie să încapă întreg. Un drum e o linie de 6 px — n-are nicio jumătate de nod
de protejat, iar sub el mai erau 64 px de hârtie liberă.

Puteam „repara" strâmbând desenul (o cutie ceva mai mică decât zona). Ar fi fost
o minciună mică: forma desenată n-ar mai fi fost forma văzută, ca să treacă o
măsurătoare pusă greșit. Verificarea măsoară acum nodurile față de zona lor și
drumurile față de hârtie, iar cei 1,1 px rămân la vedere ca informație — nu
contează azi, dar dacă ajung vreodată 60, chiar ai desenat pe lângă pergament.

### Ce s-a refăcut în cod, și ce nu

`Harta.curba_neteda()` a ieșit din `panglica()` ca funcție de sine stătătoare:
aceeași Catmull-Rom cu mânerele scalate separat pe fiecare segment, folosită
acum și de drumurile desenate. La o planșă ajută și mai mult decât la panglică,
fiindcă acolo punctele sunt puse cu ochiul, deci niciodată răsfirate egal.

Granița dintre cele două surse e o singură funcție, `_geometria(zona)`, care
întoarce mereu aceleași două lucruri: `centre` (id → punct) și `drumuri`
(id → id → puncte). Deasupra ei, ecranul nu are de unde ști dacă nodurile vin
dintr-o panglică sau dintr-un fișier; dedesubt, cele două n-au nimic în comun.
`_muchii()` nu mai calculează nimic — primește drumurile gata făcute și adaugă
doar culoarea și grosimea.

`Expeditie.plansa` (text, "" = generată) e STARE, nu constantă: o expediție deja
pornită trebuie să se deseneze pe planșa pe care a pornit, inclusiv după un save
reîncărcat peste o lună, când comutatorul o fi fost mutat de zece ori. Fiecare
nod al unei hărți desenate ține un câmp `reper` — id-ul text din fișier. Poziția
NU se ține în stare (regula „niciun Vector2 în ce se salvează"): ecranul deschide
aceeași planșă și caută reperul.

Un fișier lipsă sau stricat nu oprește jocul: `push_warning` în consolă și harta
se generează.

---

## POTCOAVA OGLINDITĂ (22 septembrie 2026) — un traseu nou, fără puncte noi

Al patrulea traseu: aceeași potcoavă, întoarsă stânga-dreapta. Pleacă din
dreapta-sus, merge spre stânga-sus, cotește pe STÂNGA, coboară și se întoarce
spre dreapta-jos, unde stă Bossul. **Nu e activ** — `TRASEU` rămâne pe
`Traseu.POTCOAVA`; se schimbă tot dintr-o linie.

### Oglinda e o operație, nu un al doilea tabel

Puteam scrie cele nouăsprezece puncte cu x-ul deja scăzut din 1. Ar fi mers până
în ziua în care reglez culoarul de sus în POTCOAVĂ și uit de geamăna ei — iar
nepotrivirea aia n-o vezi decât dacă le compari punct cu punct.

Așa, un singur tabel rămâne adevărul, iar oglinda îl citește invers:

```gdscript
const OGLINDIRI := { Traseu.POTCOAVA_OGLINDITA: Traseu.POTCOAVA }

static func traseu_de_baza(traseu := TRASEU) -> int:
	return int(OGLINDIRI.get(traseu, traseu))
```

`traseu_de_baza()` răspunde „din ce traseu e făcut ăsta", iar `repere_traseu()` e
acum singurul loc care știe care tabel de puncte aparține cărui traseu —
`panglica()` cere puncte și primește puncte. Fiindcă o oglindă nu schimbă nicio
distanță, `LATIMI_PANGLICA` și `FORFECARI` n-au avut nevoie de rânduri noi: se
întreabă tot pe traseul de bază. Un `104.0` copiat în două tabele ar fi fost încă
un loc unde se poate uita ceva.

Reperele fiind FRACȚIUNI (0..1), oglinda e chiar `x → 1 − x`. În pixeli ar fi
fost `2·zona.x + lățime − x` — încă un motiv pentru care traseele se țin în
fracțiuni.

**Ordinea punctelor rămâne neschimbată.** Instinctul zice că un traseu întors se
parcurge și de la coadă la cap; dacă aș fi inversat și ordinea, Startul ar fi
căzut jos-stânga și ieșea potcoava ROTITĂ cu 180°, nu oglindită. Cu x-ul
răsturnat și ordinea păstrată, primul punct (0,035; 0,185) devine (0,965; 0,185):
dreapta-sus, exact de unde trebuie să plece. Startul rămâne primul punct, Bossul
ultimul — ca la toate celelalte trasee.

### Ce am aflat măsurând: nu e o fotografie întoarsă

Geometria panglicii iese identică — 1517 px lungime, rază minimă 101,5 px,
rezervă ×1,54 — dar **așezarea nodurilor nu**: distanța medie între noduri legate
214,9 px față de 215,2, iar cea mai apropiată pereche 86,9 px față de 84,2.

Cauza e un semn. Un nod se așază la `C(s) + dec · N(s)`, iar normala `N`, fiind
tangenta ROTITĂ cu 90°, iese din oglindire și oglindită, ȘI cu semn schimbat. Pe
traseul întors, `dec` pozitiv arată deci în partea cealaltă — iar `dec` vine din
coloană. Coloana 0 ajunge pe banda pe care stătea ultima coloană.

Măsurat nod cu nod pe sămânța 1000: x-urile se potrivesc la zecimală cu oglinda
perfectă, iar nodurile de pe același strat sunt exact interschimbate. Startul și
Bossul, singuri pe stratul lor, cad fix în oglindă (diferență 0,0 px).

L-am lăsat așa, și nu din lene: o oglindă perfectă ar fi dat același desen,
recunoscut din prima. Așa, cele două potcoave au aceeași formă și aranjamente
diferite — adică exact ce vrei de la un al doilea traseu. Dacă vreodată vrei
oglinda exactă, se face dintr-un semn: `dec` negat în `asezare()`.

### Verificarea

`tools/verifica_harta.gd` măsoară acum patru trasee în aceeași rulare. Pe 300 de
semințe, POTCOAVA OGLINDITĂ: **0 sărituri de strat, 0 încrucișări în graf, 0
ordini inversate, 0 încrucișări în desen**, cea mai apropiată pereche 86,9 px
(prag 72), 0 noduri și 0 px de drum ieșite din zona utilă. Celelalte trei au ieșit
neschimbate — semn că generalizarea n-a mișcat nimic din ce mergea.

---

## Sesiunea stratului înclinat (21–22 septembrie 2026) — ȘARPELE încape

Sesiunea trecută ȘARPELE pica: trei culoare cereau 466 px de înălțime, hârtia
are 397, lipseau 69. Acum trece tot, fără să se micșoreze niciun nod.

### Ideea: cumperi înălțime cu lungime

Nodurile unui strat nu mai stau pe normala panglicii, ci pe o DIAGONALĂ. Fiecare
bandă primește și un decalaj de-a lungul drumului, proporțional cu cel lateral:

    s' = s + k × dec

Două noduri de pe același strat sunt atunci despărțite și lateral (`lățime`), și
de-a lungul (`k × lățime`), deci distanța dintre ele e `lățime × √(1 + k²)`.
Aceiași 92 px se obțin cu o panglică de √(1 + k²) ori mai îngustă. La k = 2,0
factorul e 2,24: **o panglică de 50 px ține nodurile la 112 px.** Cei 92 px se
plătesc acum din lungimea drumului — unde ȘARPELE are 2339 px pentru 9 straturi.

Cu panglica de 50 în loc de 248, cele trei culoare încap la 161 px unul de
altul, cu 94 px de hârtie goală între benzile vecine.

### De ce forfecarea nu poate crea încrucișări

Fiindcă se aplică pe TOT drumul, nu doar pe capete. Un drum se calculează întâi
în coordonatele nepieptănate (s, dec), exact ca înainte, și abia punctul gata
calculat e mutat cu `s → s + k·dec`.

Transformarea Φ(s, dec) = (s + k·dec, dec) e o forfecare a planului: liniară, cu
determinantul 1, deci inversabilă. O aplicație inversabilă și continuă duce
curbe care nu se taie tot în curbe care nu se taie — dacă imaginile s-ar
intersecta, ar face-o și originalele în punctul de dinainte de transformare.

Deci argumentul vechi rămâne întreg: două drumuri între aceleași straturi au
același `s` la același `t` și diferă doar prin `dec`; ordinea laterală nu se
poate inversa. **Forfecarea nu atinge `dec`** — doar strâmbă `s`.

### Nodurile stau doar pe drepte

Cotiturile rămân drum curat. Pragul nu e o constantă pusă cu ochiul, ci se
CALCULEAZĂ: într-o cotitură de rază R, banda dinspre interior se scurtează cu
(R − dec)/R, iar scurtarea lovește exact partea de-a lungul, adică tocmai
contribuția forfecării. Din condiția „distanța rămâne ≥ 92" iese raza minimă.

Pentru un traseu fără forfecare pragul iese 0 — toată panglica e bună, deci VAL
și POTCOAVA se așază exact ca înainte, fără nicio excepție scrisă pentru ele.
Pentru ȘARPE iese 761 px, deci rămân doar cele trei culoare:
**[0–555] [989–1350] [1784–2339]**, iar straturile se împart între ele
proporțional cu lungimea, prin `s_la_fractie()`.

### Cifrele, 300 de semințe, 1152 × 648

| | VAL | POTCOAVĂ *(activ)* | **ȘARPE** |
|---|---|---|---|
| lățimea panglicii | 248 px | 104 px | **50 px** |
| forfecarea k | 0 | 0 | **2,0** |
| **încrucișări în desen** | **0** | **0** | **0** |
| cea mai apropiată pereche (prag 72) | 82,8 | 84,2 | **78,5** |
| pe același strat (cerut 92) | 94,0 | 94,0 | **94,8** |
| noduri / drumuri ieșite din zonă | 0 / 0 | 0 / 0 | **0 / 0** |
| rază peste abatere | ×1,26 | ×1,54 | **×2,05** |
| distanța medie între straturi | 119,7 px | 219,4 px | **212,8 px** |

VAL și POTCOAVA au exact aceleași cifre ca înainte — forfecarea e 0 la ele, deci
tot codul nou trece pe lângă.

### De ce k = 2,0 și nu mai puțin

Măsurat pe 300 de semințe, fereastra e îngustă: **sub 1,9 cade distanța pe
strat, peste 2,2 cade distanța dintre straturi** (forfecarea prea mare trage un
nod de pe un strat lângă vecinul de pe altul).

1,9 părea că merge într-o primă măsurătoare, dar nu merge: la k = 1,9 raza
cerută iese INFINIT — panglica de 50 px e prea îngustă chiar și pe o dreaptă
perfectă — nicio porțiune nu se califică, intră plasa „folosește toată
panglica", iar nodurile ajung înapoi în cotituri. Raportul arăta atunci
„o porțiune, toată panglica", care seamănă leit cu „totul e în regulă".

**Plasa scrie acum un avertisment**, iar raportul spune explicit ce rază s-a
cerut. O plasă tăcută care ascunde o configurare greșită e mai rea decât lipsa
ei.

### Ce a costat abaterea organică de-a lungul

Cele două noduri ale unui strat primesc abateri de-a lungul INDEPENDENTE, iar în
cel mai rău caz ele se apropie și mănâncă până la 2 × 8 = 16 px din despărțirea
dată de forfecare. Condiția corectă nu e `lățime × √(1 + k²) ≥ 92`, ci

    (k·x − 16)² + x² ≥ 94²

Fără abaterea de-a lungul, k ar fi putut rămâne 1,6. Cu ea, trebuie 2,0. Am
păstrat-o: altfel toate nodurile unui strat ar sta pe o diagonală perfectă și
s-ar vedea rigla.

---

## Sesiunea potcoavei (21 septembrie 2026) — al treilea traseu, și o bănuială greșită

### POTCOAVA

Stânga-sus → dreapta-sus → cotitură pe dreapta → dreapta-jos → stânga-jos
(Bossul). Două culoare în loc de trei, deci socoteala de la ȘARPE se schimbă:

    2 culoare × 94 px de panglică + 1 spațiu × 92 px = 280 px
    zona utilă are                                     397 px
    rămân libere                                       117 px

Cei 117 px liberi s-au dus **în spațiul dintre culoare**, nu într-o panglică mai
lată. O panglică lată ar fi însemnat două culoare groase și apropiate, care la o
privire se citesc ca o singură bandă de noduri. Așa, panglica e de 104 px
(aproape minimul la care două noduri de pe același strat nu se ating), culoarele
stau la 250 px unul de altul, și rămân **118 px de hârtie goală** între benzile
vecine. Se văd ca două rânduri.

### Cifrele (aceleași 300 de semințe, zonă utilă 797 × 397 px)

| | VAL *(activ)* | POTCOAVĂ | ȘARPE |
|---|---|---|---|
| lățimea panglicii | 248 px | 104 px | 248 px |
| lungimea panglicii | 827 px | 1517 px | 2390 px |
| raza celei mai strânse cotituri | 174,5 px | 101,5 px | 65,1 px |
| abatere laterală maximă | 138 px → **×1,26** | 66 px → **×1,54** | 138 px → ×0,47 |
| fâșia încape în zonă | colțuri, 19,9 px | **DA** | NU, 105 px |
| **încrucișări în desen** | **0** | **0** | 500 (pe 245 hărți) |
| distanța medie între straturi | 119,7 px | **219,4 px** | 343,7 px |
| cea mai apropiată pereche (prag 72) | **82,8** | **84,2** | 40,7 |
| noduri / drumuri ieșite din zonă | 0 / 0 | **0 / 0** | 1105 / 104 px |

POTCOAVA e verde peste tot, și are cel mai mult aer dintre toate: 219 px între
straturi, față de 120 la VAL.

### Cum se comută

O singură linie, în `scenes/harta/harta.gd`:

```gdscript
const TRASEU := Traseu.VAL        # ondulația — cea activă acum
const TRASEU := Traseu.POTCOAVA   # două rânduri și o cotitură
const TRASEU := Traseu.SARPE      # trei culoare — nu încape, vezi nota lui
```

Salvezi, redeschizi ecranul de expediție, gata. Nu trebuie repornit jocul:
`_aseaza_nodurile()` reconstruiește panglica de fiecare dată când pânza își
schimbă mărimea.

### Bănuiala greșită, ținută minte dinadins

La prima măsurătoare, cotitura POTCOAVEI avea raza 79 px în loc de 125 cât o
desenasem. Explicația care suna bine: punctele cotiturii sunt prea rare (din 45°
în 45°), iar curba netedă taie colțurile — exact ce pățiseră vârfurile VALULUI.
Le-am îndesit la 22,5°. Rezultat: **79,2 → 79,0**. Adică nimic.

Adevăratul vinovat era altul: **saltul de densitate** dintre culoar (puncte din
112 în 112 px) și cotitură (din 49 în 49). Formula Catmull-Rom folosită atunci
dădea ambelor capete ale unui punct același mâner; la trecerea dintre ele,
mânerul scurt al cotiturii trebuia să ducă o schimbare mare de direcție — și un
mâner scurt care întoarce mult înseamnă o cotitură strânsă.

Reparația e în `panglica()`: **mânerele se scalează după segmentul de lângă
fiecare**, separat pe stânga și pe dreapta. Când segmentele sunt egale, formula
dă exact ce dădea cea veche — deci e o generalizare, nu o schimbare de formă.
Ce s-a câștigat peste tot:

| | înainte | după |
|---|---|---|
| raza VAL | 166,9 px | **174,5 px** |
| raza POTCOAVĂ | 79,0 px | **101,5 px** |
| raza ȘARPE | 10,1 px | **65,1 px** |
| încrucișări ȘARPE | 871 | 500 |

Lecția: prima explicație care sună bine nu e neapărat cea adevărată, iar
verificarea headless costă patru minute și spune care e. Dacă aș fi îndesit
punctele și aș fi trecut mai departe fără să remăsor, aș fi rămas cu o reparație
care nu repara nimic — și cu convingerea că am înțeles problema.

---

## Sesiunea panglicii (21 septembrie 2026) — harta nu mai e o grilă

### Ce s-a schimbat, în două propoziții

Nodurile nu se mai așază pe o grilă dreaptă (x din adâncime, y din coloană), ci
pe o **panglică**: o curbă centrală care șerpuiește pe pergament, plus două
benzi paralele cu ea. Adâncimea = cât ai mers pe curbă (lungime de arc);
coloana = pe ce bandă ești.

### De ce harta veche era un caz particular

Dă-i panglicii ca traseu un singur segment orizontal: curba devine o dreaptă,
tangenta e mereu (1, 0), normala mereu (0, 1), iar formula `C(s) + N(s)·dec` se
citește `(stânga + s, mijloc + dec)` — exact vechiul „x din adâncime, y din
coloană". Nu s-a înlocuit un sistem cu altul; s-a scos din el presupunerea că
tangenta e constantă.

### Cine face ce acum

| Fișier | Ce știe |
|---|---|
| `harta.gd` | panglica, benzile, punctele fiecărui drum |
| `panza.gd` | primește un șir de puncte și desenează liniuțe pe el. Cuvântul „panglică" nu mai apare în el decât într-un comentariu |
| `tools/verifica_harta.gd` | măsoară AMÂNDOUĂ traseele, pe 300 de semințe |

Drumurile nu mai sunt Bézier între două centre. O Bézier nu știe nimic despre
teren: pe o panglică ondulată ar tăia coarda. Acum drumul merge PE curbă, cu
`P(t) = C(lerp(s_a, s_b, t)) + N · lerp(dec_a, dec_b, u)`, unde `u` amestecă
liniar cu `smoothstep` ca două drumuri care pleacă din același nod să se
despartă din prima clipă.

### Cifrele (fereastra implicită, zonă utilă 797 × 397 px)

**VAL** — de la stânga la dreapta, o ondulație și jumătate. **Tot verde:**

| Măsură | Valoare |
|---|---|
| lungimea panglicii | 827 px |
| raza celei mai strânse cotituri | 166,9 px |
| cea mai mare abatere laterală (bandă 124 + organic 14) | 138 px → rezervă ×1,21 |
| distanța medie între straturi, pe panglică | 119,7 px |
| încrucișări în desen, 300 de semințe | **0** |
| cea mai apropiată pereche de noduri | **82,6 px** (harta dreaptă de dinainte: 71,4) |
| noduri / drumuri ieșite din zona utilă | 0 / 0 px |

**ȘARPE** — trei culoare legate prin două întoarceri. **Nu încape, și se știe
de ce:** nu din cauza cotiturilor, ci a înălțimii hârtiei.

    3 culoare × 94 px de panglică + 2 spații × 92 px = 466 px
    zona utilă are                                     397 px
    lipsesc                                             69 px

Măsurat: distanța medie între straturi 345,7 px (loc berechet), dar cea mai
apropiată pereche de noduri ajunge la 36,8 px și 871 de drumuri se taie pe 293
de hărți din 300. Traseul rămâne în cod, verificat, ca să nu fie redescoperit de
la zero: l-ar debloca un pergament mai înalt, noduri mai mici, sau două culoare
în loc de trei (2 × 94 + 92 = 280 px, adică ar încăpea).

### Ce am învățat și merită ținut minte

**Lățimea panglicii și amplitudinea valului nu pot crește amândouă.** Raza
cotiturii scade cam invers proporțional cu amplitudinea (R ≈ 6000 / amplitudine,
pe lățimea hârtiei ăsteia, cu o ondulație și jumătate), iar pe banda dinspre
interiorul cotiturii drumul se scurtează cu (R − abatere) / R. La R = 167 și o
abatere de 138, 120 px de drum devin 20 px de hârtie — și două noduri se
suprapun. Produsul „lățime × amplitudine" e practic fix.

**Pragul de distanță dintre noduri nu e 92, ci 72.** 92 ar fi cifra evidentă
(două casete care se ating), dar harta dreaptă, pe care panglica o înlocuiește,
n-o trecea nici ea: cea mai apropiată pereche de pe ea era la 71,4 px, și arăta
bine — fiindcă imaginea ocupă 0,78 din casetă. Pragul corect nu e „cât de mari
sunt casetele", ci „cât de aproape ajungeau nodurile pe harta de dinainte".

**Strângerea alternată a benzilor nu e cosmetică.** Două noduri de pe straturi
vecine și de pe aceeași bandă sunt despărțite doar de cât înaintează drumul.
Strângând benzile din doi în doi, straturile vecine ajung pe benzi diferite,
deci se mai adaugă o despărțire laterală. Fără ea, minimul cădea la 29,9 px.

### Datorie tehnică deschisă aici

- Verificarea „fâșia plină încape în zonă" iese cu 19 px la cele două capete ale
  panglicii, unde banda iese în diagonală peste marginea hârtiei. Nu se vede
  nimic acolo: primul și ultimul strat au un singur nod, pe mijlocul panglicii,
  iar drumurile pleacă tot de pe mijloc. Verdictul care contează („ies
  DRUMURILE?") e 0 px. De curățat doar dacă vreodată un strat de capăt primește
  mai mult de un nod.

---

## Sesiunea nodului tăiat (21 septembrie 2026) — stai pe un loc deja bifat

O sesiune de câteva linii, dar cu o întrebare care merita pusă înainte de ele.

### Ce arăta greșit

Nodul pe care tocmai l-ai câștigat primea starea CURENT (aura caldă) și, fiindcă
lanțul de `if`-uri din `_construieste_harta()` îl prinde pe prima ramură, nu mai
ajungea niciodată la PARCURS — deci nu primea X-ul. Pe harta de referință, figura
stă pe un loc deja tăiat: ai ajuns acolo ȘI ai terminat treaba. Aura spune „aici
sunt", X-ul spune „aici s-a rezolvat". Sunt două informații, nu una.

### Întrebarea pusă întâi: e sigur că nodul curent e mereu terminat?

Verificat pe toate rutele, fiindcă un X pe un nod nejucat ar fi fost o minciună
vizuală mai rea decât lipsa lui:

- **Luptă / Elită / Boss** — `_pe_nod_apasat()` schimbă scena. Harta e distrusă
  și revine abia din `_inapoi_la_harta()` (`lupta.gd`), adică după verdict. Harta
  nu există niciodată în timpul unei lupte, deci nu poate desena nodul ei.
- **Odihnă / Magazin / Eveniment** — harta rămâne, iar `_arata_magazin()` și
  `_arata_mesaj()` cheamă dinadins `_arata_harta()` cât e voalul ridicat, exact
  ca nodul să fie deja tăiat când voalul se ridică. Era regula scrisă acolo de
  mai demult, nu o excepție nouă.
- **`pozitie == -1`** (loadout) — nu există nod curent, deci nici întrebare.
- **Reluare după închiderea jocului în mijlocul unei lupte** — nu există azi.
  `Expeditie.din_dictionar()` e scrisă, dar nimic n-o cheamă: scrierea pe disc e
  pasul 8.

### Ce s-a schimbat

`stare` și „e consumat?" au devenit două întrebări separate, ca `stare` și
`activ` de dinainte. `SimbolNod` are un câmp `terminat`, primit printr-un al
cincilea parametru al lui `configureaza()` (cu valoare implicită, deci un apel
vechi se comportă identic), iar X-ul se desenează pe
`PARCURS or (CURENT and terminat)`. Ordinea din `_construieste_harta()` n-a fost
atinsă — CURENT rămâne primul, deci aura nu se pierde; lângă lanț s-a adăugat o
singură linie, `var terminat := id in Expeditie.parcurse`, fiindcă `parcurse` îl
conține și pe nodul curent.

**De ce nu o a cincea stare.** Stările sunt ROLURI în ierarhia vizuală, iar rolul
nu se schimbă: un nod terminat pe care stai e tot „unde ești", doar că are un semn
în plus. Un `CURENT_TERMINAT` ar fi însemnat un rând în `INFATISARI` copiat cuvânt
cu cuvânt după CURENT — adică două locuri de reglat la fiecare ajustare de aură.

### Datoria lăsată în urmă, scrisă în cod

Regula „nodul curent e terminat" se sprijină pe faptul că harta se desenează doar
între noduri. **Save-ul (pasul 8) e singurul lucru care o poate sparge:** un save
făcut în mijlocul unei lupte trebuie să se întoarcă ÎN LUPTĂ, nu pe hartă — altfel
nodul ar apărea tăiat înainte să fi fost jucat. Dacă vreodată chiar e nevoie să se
reintre pe hartă cu un nod neterminat, `parcurse` nu ajunge: el înseamnă „am
intrat", nu „am terminat", și ar trebui un câmp explicit în `Expeditie`. Nu l-am
adăugat acum, fiindcă azi ar fi mereu `false`, iar o stare care nu se schimbă
niciodată e o minciună în cod. Avertismentul stă în docstring-ul lui
`_construieste_harta()`, unde îl citește cine scrie save-ul.

### Fișiere atinse

```
scenes/harta/simbol_nod.gd   - `var terminat`; al 5-lea parametru la `configureaza()`;
                               regula de desen a X-ului
scenes/harta/harta.gd        - `terminat` calculat si pasat; docstring-ul
                               `_construieste_harta()` explica regula noua
```

### Ce a rămas de verificat

Rulat cu ochii în joc: dacă X-ul peste aură e prea încărcat vizual, se scade
opacitatea lui doar pentru nodul curent, dintr-un singur loc
(`_deseneaza_taietura()`).

---

## Sesiunea hărții largi (18 septembrie 2026) — drumul umple pergamentul

Sesiunea de dinainte a făcut harta să arate a hartă. Asta a făcut-o să arate a
DRUM: mai lungă, întinsă pe toată hârtia, cu un capăt care se vede de departe
și cu un loc pe drum unde ce-ai strâns înseamnă ceva.

### 1. Drumul merge de la stânga la dreapta, nu de jos în sus

Adâncimea creștea pe verticală, „ca un munte pe care urci". Pe pergamentul ăsta
a fost o greșeală de formă: hârtia e lată, nu înaltă, deci cele 7-9 straturi se
înghesuiau pe înălțimea mică, iar cele 2 coloane se răsfirau pe lățimea mare —
exact pe dos. Pe orizontală, straturile au unde să respire.

Bonus care nu era planificat: de la stânga la dreapta e și direcția în care
citim. Un drum care merge încotro se uită ochiul nu mai are nevoie de nicio
săgeată care să explice pe unde s-o iei.

### 2. Nodurile acoperă toată hârtia, nu jumătatea stângă

Trei reparații, în ordinea în care s-au văzut:

- **Zona utilă e declarată, nu ghicită.** `ZONA_PERGAMENT` spune, în fracțiuni
  de ecran, unde e hârtie: pergamentul nu acoperă fereastra, are margini arse
  și se termină pe la 84% din lățime.
- **Marginea din dreapta trece PE SUB carte.** Cartea legată în piele stă în
  colț de la 0,845; zona utilă se oprește la 0,838. Rezultatul: tot codul care
  ocolea zona cărții a putut dispărea. *O regulă de așezare e mai ieftină decât
  o excepție de ocolit* — asta merită ținută minte, se mai repetă.
- **Rândurile se răsfiră pe toată înălțimea.** Formula veche așeza două noduri
  la 25% și 75% din înălțime, adică folosea jumătate din hârtie.

Iar pentru banda goală rămasă fix pe mijloc: straturile **impare se strâng spre
centru** (`STRANGERE_ALTERNATA`). Rândurile nu mai sunt două linii drepte, ci un
zigzag lat. Leacul n-a fost „mai multe noduri" — aia ar fi însemnat o expediție
mai lungă ca să repar un desen.

### 3. Traseele: cerneală, nu creion

Erau gri deschis, de 5 pixeli, cu liniuțe de 9. Pe maro, invizibile. Acum:
liniuțe de 15 pixeli lungime, culori de cerneală, și **trei greutăți clar
diferite** — drumul deschis e aproape negru și de 11 pixeli, restul sunt stinse
și subțiri.

Ce lipsea de fapt nu era grosimea, ci **oprirea**: liniuțele mergeau până în
centrul nodului, deci drumul părea că trece PRIN el. Acum fiecare muchie
primește de la hartă un câmp „oprire" și se termină vizibil înainte de simbol.
Pânza nu știe cât e de mare un nod și nu trebuie să știe.

### 4. Iconițe din fișiere, cu desenul din cod ca plasă

`simbol_nod.gd` încearcă întâi `assets/art/campaign_nodes/<fișier>.png`; dacă
lipsește sau nu se încarcă, desenează forma din poligoane, ca până acum.
Încercarea se face **o singură dată per tip** și se ține minte, inclusiv eșecul:
fără asta, un fișier lipsă ar fi însemnat o căutare pe disc la fiecare
redesenare a fiecărui nod.

Imaginea nu se pune cu `draw_texture_rect`, ci ca poligon cu textură, cu
colțurile trecute prin `_punct()` — așa moștenește gratis înclinarea de câteva
grade și respirația, exact ca formele desenate.

> ✅ **Rezolvat.** Fișierele erau, la prima încercare, JPEG-uri redenumite
> `.png`, cu un fundal în carouri PICTAT în ele; Godot le refuza cu „Not a PNG
> file" și harta desena plasa. Au fost reexportate ca PNG adevărate, 512×512,
> cu canal alfa. Toate **șase** tipurile de nod au acum imagine: Luptă, Elită,
> Odihnă, Magazin, Boss și **Eveniment** (`campaign_event.png`). Funcțiile de
> desen din cod rămân pe loc ca plasă — un fișier șters sau prost exportat
> întoarce harta la poligoane, nu o rupe.

### 5. Tip de nod nou: MAGAZIN, și moneda care moare cu runul

**Monedele** se strâng din lupte (8 la o Luptă, 16 la o Elită, 30 la Boss) și se
evaporă la finalul expediției. Fragmentele rămân în `Tezaur` și vor plăti
cetatea.

De ce două monede și nu una: „ce cumpăr ACUM, cu ce am pe drumul ăsta" e o
decizie complet diferită de „ce-mi construiesc peste zece runuri". Cu o singură
resursă, a doua ar înghiți-o mereu pe prima — orice leu dat pe un ajutor
temporar ar fi un leu furat de la ceva permanent, deci n-ai cumpăra niciodată
nimic pe drum.

Se vând trei puteri (`Expeditie.PUTERI`), toate valabile doar pe runul curent:
Pana de oțel (+1 PA pe rundă, 24), Zale ferecate (+4 PV maxim, 16), Fiertura
caldă (+6 PV, 9).

Două lucruri aflate la probă, nu la proiectare:

- **O hartă din 300 ieșea fără Magazin.** Pare puțin până înțelegi ce e: un run
  în care sistemul de Monede pur și simplu nu există, fără ca jucătorul să afle
  vreodată de ce. `_asigura_magazin()` transformă un nod liber dacă n-a ieșit
  niciunul. Acum: 0 din 300.
- **Fiertura se putea cumpăra cu PV plin** — lua 9 Monede și răspundea „+0 PV".
  Nu era un bug de cod, era un bug de vitrină. `motiv_refuz()` stinge butonul ȘI
  scrie de ce („PV plin", „iti mai trebuie 4").

### 6. Tip de nod nou: BOSS, și sfârșitul lui `e_elita`

Ultimul nod era o Elită — aceeași Elită pe care o întâlneai și la nodul 6.
Capătul drumului nu era un capăt, era încă un nod. Acum e un tip aparte, care
apare doar acolo.

Bossul a împins o curățenie care se cerea oricum: `lupta.gd` avea un
`bool e_elita` și două constante (`MULTIPLICATOR_ELITA`, `FRAGMENTE_ELITA`). Un
„da/nu" nu poate răspunde la „cât de greu", iar al doilea bool lângă primul ar
fi făcut patru combinații din care două n-au sens.

Acum `Expeditie.DATE_NOD` are patru coloane noi — `putere`, `buget`, `monede`,
`bonus` — iar lupta le citește. **În `acorda_recompensa()` nu mai scrie nicăieri
„Elită" sau „Boss".** Un tip de nod nou nu mai cere nicio linie acolo.

„putere" și „buget" sunt două coloane, nu una, fiindcă sunt două lucruri:
bugetul alege CINE apare (Spadasin în loc de Soldat), puterea îl umflă pe cel
apărut. Bossul are nevoie de amândouă.

### 7. Harta a crescut la 12-16 noduri

7-9 straturi în loc de 5-6. Motivul e de DESEN, nu de dificultate: pe
pergamentul întins pe toată fereastra, opt noduri arătau ca opt puncte răzlețe.
Referința (`assets/art/demons_hand_reference.png`) are paisprezece, și abia la
densitatea aia drumul pare un traseu pe un teren.

Pantele din `PONDERI_NOD` au fost înmuiate odată cu lungimea — aceeași pantă pe
9 straturi ar fi însemnat că ultimele trei sunt numai Elite. **Când schimbi
lungimea hărții, `pe_adancime` e numărul care se reglează odată cu ea.**

### Ce rămâne de reglat (numere, nu structură)

- **Bossul are 78 PV față de 15 ai regelui** (×2,3 peste Lăncier). E capătul
  unui run de 9 opriri, deci trebuie să fie greu — dar cifra n-a fost jucată,
  doar calculată. Se reglează din coloana „putere".
- **Focul de tabără desenat din cod** avea buștenii încrucișați de la un colț la
  altul — exact forma X-ului cu care se barează nodurile vizitate. S-au făcut
  scurți și joși. Merită ținut minte ca regulă: *un simbol n-are voie să semene
  cu o stare.*
- Expediție de 16 noduri × ~9 opriri: de văzut dacă încape într-o sesiune de 15
  minute. Dacă nu, se taie din `STRATURI_MAX`, nu din `STRATURI_MIN`.

### Verificat (rulare headless, 300 de semințe)

- 12-16 noduri, întotdeauna; Boss pe ultimul nod în 300 din 300
- Magazin prezent în 300 din 300
- Cumpărare, refuz, `bonus_pa()`, save/load dus-întors — toate corecte
- Lupta la nodul de Boss: „BOSS LANCIERUL — 78/78 PV", 4 puncte de PA cu Pana
  cumpărată

---

## Sesiunea drumurilor curate (21 septembrie 2026) — niciun traseu nu mai taie altul

Harta arăta a hartă și umplea hârtia, dar traseele se încălecau. Sesiunea asta
n-a adăugat nimic: a scos o problemă pe care ochiul o vedea și cifrele n-o
numărau.

### Întâi măsurat, apoi reparat (a treia oară, și tot merită)

`tools/verifica_harta.gd` — o SCENĂ headless, rulată cu
`godot --headless --path . res://tools/verifica_harta.tscn` — trece generatorul
prin 300 de semințe și numără patru lucruri:

| | ce numără | înainte | după |
|---|---|---|---|
| (a) | muchii care sar peste un strat | **0** | 0 |
| (b) | încrucișări în GRAF (coloane inversate la capete) | **949** (pe 298 de hărți) | **0** |
| (c) | straturi în care abaterea organică inversează ordinea pe verticală | **22** (pe 21 de hărți) | **0** |
| (d) | încrucișări în DESENUL efectiv, drumurile tăiate în linii frânte | **824** (pe 297 de hărți) | **0** |

(a) fiind deja zero, n-a fost nimic de decis acolo: generatorul nu leagă decât
straturi vecine.

**De ce e o scenă și nu un `--script`:** cu `--script`, Godot nu pornește
autoload-urile, iar `expeditie.gd` se referă la `Sac` și `harta.gd` la `Muzica`.
Nimic nu se compila. O scenă pornește jocul normal, doar fără fereastră.

**Testul nu are logică proprie.** Cheamă `Expeditie.genereaza_harta()`,
`Harta.centre_noduri()` și `Panza.punct_pe_drum()` — exact codul din joc. De-aia
`_aseaza_nodurile()` a fost spart în două: partea de geometrie pură a devenit
`centre_noduri()`, `static`, cu harta primită ca parametru. O funcție căreia îi
dai tot ce-i trebuie se poate chema din orice, inclusiv dintr-un test fără
fereastră. La final rulează și o probă de fum pe scena adevărată de hartă, ca să
nu iasă cifre bune dintr-un cod pe care jocul nu-l mai poate porni.

### Reparația 1 — muchiile: felii care merg înainte (`_leaga`)

Regula veche era „fiecare nod de sus își alege 1-2 urmași la întâmplare, apoi
reparăm nodurile de jos rămase fără părinte". Corectă pe bucăți, greșită pe
ansamblu: nodul de sus de pe coloana 0 putea alege nodul de jos de pe coloana 1
și invers — două drumuri care își schimbă locurile.

Regula nouă: fiecare nod de sus primește o **felie continuă** de noduri de jos,
iar felia următoare nu are voie să înceapă înaintea locului unde s-a terminat
cea dinainte. Feliile au voie să se ATINGĂ (două cărări care se adună într-un
nod — exact ce vrei pe o hartă), n-au voie să se încalece pe dos.

E o **construcție**, nu o verificare. N-am scris nicăieri „încrucișează muchia
asta pe alta? atunci mai trag un zar" — pur și simplu nu există aruncare de zar
care să producă o încrucișare. Diferența contează: o verificare cu reîncercări
poate intra în buclă sau poate rata un caz; o construcție nu are cum.

Ce a rămas garantat, și de ce: prima felie începe la 0, ultima se termină la
ultimul nod, iar feliile sunt lipite cap la cap — deci **fiecare nod de jos e
accesibil**, fără pasul vechi de „reparație". Și `capat >= start` mereu, deci
**fiecare nod de sus are cel puțin o ieșire**.

`_amesteca()` (Fisher-Yates cu generator propriu) a rămas fără utilizator și a
fost ștearsă din `expeditie.gd`.

### Reparația 2 — abaterea organică nu mai poate inversa un strat

Abaterea se trăgea nod cu nod, ±52 de pixeli. Pe straturile strânse spre mijloc
(`STRANGERE_ALTERNATA`) cele două noduri stau la 177 de pixeli: dacă cel de sus
e împins în jos cu 52 și cel de jos în sus cu 52, rămân 73. Nodul are 92. Se
suprapuneau, iar uneori se inversau — și atunci graful curat nu mai ajuta la
nimic, fiindcă nodurile își schimbau locurile pe hârtie.

`_potoleste_abaterea()` calculează, pentru fiecare strat, **un singur factor**
între 0 și 1 cu care se înmulțesc toate abaterile verticale de acolo.

Prima idee — „îl mut pe cel de jos cu încă 20 de pixeli mai jos" — e greșită:
nodul mutat poate ieși de pe pergament, iar oprit la margine se strâmbă și mai
tare. Înmulțind tot stratul, formele rămân proporționale, stratul arată la fel
(doar mai puțin dezordonat) și niciun nod nu se apropie de margine mai mult
decât se apropia înainte, fiindcă abaterea doar scade. Pe 279 de hărți din 300
factorul iese 1 și nu se schimbă nimic.

### Capcana zilei: egalitatea în virgulă mobilă

După reparație, (c) a scăzut de la 22 la **4**, nu la 0. Cazurile arătau așa:

```
strat 5: nodul 9 la y=215.6290, nodul 10 la y=307.6289  ->  92.0000 px (minim 92.0)
```

Formula nimerea fix pe limită, iar la a șaptea zecimală scăderea cădea când
deasupra, când dedesubtul ei. Leacul e `DISTANTA_MINIMA_VERTICALA =
MARIME_NOD.y + 2.0`: doi pixeli care nu se văd, dar scot condiția de pe muchia
de cuțit. **Regulă de ținut minte: când o condiție e „cel puțin atât", țintește
puțin peste, nu exact.**

### Reparația 3 — curbura nu mai vine din sămânță, vine din geometrie

Fiecare drum primea un număr `curbura`, tras la sorți din semințele celor două
noduri, și se îndoia PERPENDICULAR pe segment. Arăta bine luat drum cu drum și
prost luată harta întreagă: două drumuri între aceleași straturi puteau primi
îndoituri în direcții opuse.

Acum forma e fixă, aceeași pentru toate: o **Bézier cubică** (patru puncte, nu
trei) cu punctele de control la

```
c1 = de_la + Vector2(dx * 0.5, dy * 0.15)
c2 = la    - Vector2(dx * 0.5, dy * 0.15)
```

adică un „S" care pleacă orizontal din nodul din stânga și intră orizontal în
cel din dreapta, ca șinele unui macaz. Pătratica avea un singur punct de
control, deci o singură cocoașă; cubica are două, și exact asta e un S.

**De ce un S nu poate tăia alt S:** ambele coordonate ale punctelor de control
stau între capete, deci x-ul curbei crește tot timpul, iar y-ul merge într-un
singur sens. Un drum monoton e, pentru fiecare x, exact un y — adică e graficul
unei funcții, nu o buclă. Două drumuri între aceleași două straturi pleacă de pe
aceeași verticală și ajung pe aceeași verticală; dacă la stânga unul e deasupra
celuilalt ȘI la dreapta tot deasupra, ca să se întâlnească la mijloc ar trebui
să se inverseze și apoi să se inverseze la loc — adică să se taie de două ori.
De-aia (b) = 0 și (c) = 0 sunt tot ce trebuie ca să iasă (d) = 0.

Au dispărut: `_curbura()`, `CURBURA_MINIMA`, `CURBURA_MAXIMA`, câmpul `curbura`
din muchii și parametrul `zona` al lui `_muchii()`, care nu mai avea ce face
acolo. Desenul nu mai are niciun zar în el.

### Fișiere atinse pe 21 septembrie 2026

```
autoload/expeditie.gd        - `_leaga` rescrisa; `_amesteca` stearsa
scenes/harta/harta.gd        - `centre_noduri()` + `_potoleste_abaterea()` (noi, static)
                               `DISTANTA_MINIMA_VERTICALA`; fara `_curbura`
scenes/harta/panza.gd        - Bezier cubica, `punct_pe_drum()` static
tools/verifica_harta.gd      - NOU: verificarea headless
tools/verifica_harta.tscn    - NOU: scena care o porneste
```

### Ce a rămas de făcut aici

- `res://assets/audio/muzica_harta.ogg` lipsește. Nu oprește nimic (`Muzica`
  scrie un avertisment și merge mai departe în liniște), dar harta e singurul
  ecran fără muzică.
- Verificarea (d) e scumpă: drumurile se taie în bucăți de 16 segmente și se
  compară doar cutiile care se ating. Fără trucul ăsta, 300 de semințe însemnau
  miliarde de verificări de segmente și ore de așteptare. Dacă hărțile cresc,
  aici se optimizează mai departe.

---

## Sesiunea aspectului hărții (17 septembrie 2026) — harta arată a hartă

**Ce s-a schimbat:** nimic din reguli. Harta juca deja corect — doar că arăta ca
un tabel de dreptunghiuri gri pe fundal negru. Acum e un pergament cu simboluri
desenate cu cerneală și drumuri punctate. Zero linii atinse în `expeditie.gd`:
toată sesiunea a fost DESEN, și asta se vede în diff.

Reper de stil: harta din Demon's Hand (`assets/art/demons_hand_reference.png`).

### Inversarea paletei — de ce a atins mai mult decât părea

Tot ce era peste hartă fusese construit pentru fundal negru: text deschis, linii
palide, culori aprinse de disciplină. Pe hârtie veche **toate astea dispar**,
fiindcă pergamentul e mai luminos decât ele. Nu era o schimbare de culoare, era
o inversare: cerneală închisă pe deschis, peste tot.

Al doilea lucru, aflat pe parcurs: pe pergament nu ajunge să fie închis. Textura
are cute, pete și dealuri desenate, iar o sabie neagră peste o umbră maro e o
mâzgăleală. De-aia fiecare nod are un **halo** — nu e decor, e lizibilitate. Ce
trebuie să pară e „aici hârtia e curată", nu „aici e o lumină".

Godot n-are umbră moale la desen, dar 14 cercuri concentrice cu opacitate mică
fiecare dau exact aceeași degradare. (Cu 8 se vedeau inelele — cel mai ieftin
gradient din lume, dar are nevoie de destule straturi.)

### `scenes/harta/simbol_nod.gd` — un nod nu mai e buton

Un `Button` desenează întotdeauna ceva al lui: fond, chenar, stare de hover. Se
pot goli toate cu StyleBox-uri, dar atunci rămâne un buton care nu mai e buton.
Un `Control` obișnuit primește mouse-ul la fel de bine și desenează exact ce-i
spui. Ce se pierde: focusul cu tastatura — harta nu l-a folosit niciodată.

**Moștenește `Silueta`**, baza scrisă pe 1 septembrie pentru rege și pentru
piesele de șah. Ea știe deja să potrivească o casetă pătrată în orice cutie, să
traducă fracțiuni (0..1) în pixeli și să „respire" pe `sin()`. Respirația aia e,
aici, pulsul nodurilor accesibile: **n-am scris nicio linie de animație**, doar
i-am dat `amplitudine` din tabel. Așa arată reutilizarea când baza a fost
desenată cum trebuie — a doua oară nu mai plătești.

Patru simboluri, desenate în cod (sabie, craniu, foc de tabără, semn de
întrebare), fiecare o listă de numere între 0 și 1. Tipul → funcția de desen e un
**dicționar**, oglinda lui `DATE_NOD`: un tip de nod nou e un rând plus o
funcție, nu o ramură nouă prin `_draw()`.

Ierarhia vizuală cerută e și ea un tabel (`INFATISARI`), un rând pe stare:

| Stare | Cerneală | Halo | Puls | În plus |
|---|---|---|---|---|
| **Curent** | plină | maxim | da | **aură caldă, pâlpâind** — singura lumină de pe hartă |
| **Accesibil** | plină | mare | discret | — |
| **Parcurs** | pe jumătate | mic | — | **X roșu**: „rezolvat", nu „interzis" |
| **Închis** | estompată | mic | — | — |

Două lucruri diferite (unde ai fost / ce nu-ți e la îndemână) primesc două semne
diferite. Dacă ar fi amândouă doar „mai șterse", harta ar minți.

### Textul nodului, doar la survolare

Patru cuvinte scrise peste pergament în zece locuri = zgomot; simbolul spune
tipul dintr-o privire. Eticheta apare la hover, **una singură pentru toată
harta** (zece etichete ascunse se pot suprapune exact în clipa în care apar
două), și n-are fond: are **contur crem** în jurul literelor. Un dreptunghi opac
ar fi fost un petic de interfață lipit pe hartă.

Consecință: piciorul paginii spune acum cum se citește harta. Un semn pe care nu
știi să-l interoghezi e un semn degeaba.

### Trasee punctate, curbe — și de unde vine îndoitura

O linie dreaptă și subțire spune „nodul A e legat de nodul B". Un șir de liniuțe
care se îndoaie spune „de-aici se MERGE acolo". Aceeași informație, altă poveste,
douăzeci de linii de cod: o Bézier pătratică (mijlocul împins perpendicular),
măsurată din 2 în 2 pixeli, iar `fmod(parcurs, pas)` decide singur liniuță sau
pauză — fără să numere liniuțe și fără să știe câte încap.

### Ce ține totul reproductibil: sămânța nodului

Pozițiile pe grilă arătau a tabel, deci fiecare nod primește o abatere. Abaterea,
înclinarea simbolului, decalajul pulsului și îndoitura fiecărui drum ies din
**`nod["samanta"]`** — câmp care exista deja, scris sesiunea trecută pentru
inamici. Niciun câmp nou, niciun `randf()`.

Dacă ar fi fost trase la sorți, harta ar fi tresărit la fiecare redimensionare de
fereastră și la fiecare întoarcere din luptă, fiindcă `_aseaza_nodurile()` se
cheamă din nou de fiecare dată. Regula: **tot ce se redesenează des trebuie să
fie derivat, nu tras la sorți.**

### Zona interzisă (cartea)

Imaginea are o carte desenată în colțul din dreapta-jos. E scrisă ca `Rect2` în
**fracțiuni de ecran**, nu în pixeli — fundalul se întinde peste toată fereastra,
deci cartea e „a șasea parte din dreapta", nu „ultimii 180 de pixeli". Un nod
care cade acolo e împins spre stânga (în dreapta cărții nu mai e pergament).

Nodurile n-au fost singura problemă: **o curbă lungă ajunge mai departe decât
capetele ei**, iar un drum se umfla peste carte. Îndoitura se verifică acum și,
dacă partea trasă la sorți e proastă, se încearcă cealaltă.

### Capcana zilei: `campaign_map.png` nu era PNG

Godot refuza fișierul cu „Failed loading resource". Cauza: imaginea e un **JPEG
cu extensia .png** (începe cu `ffd8ffe0 JFIF`, nu cu `89504e47 PNG`), iar
importatorul se uită la conținut, nu la nume. Redenumită `campaign_map.jpg` și
importată fără nimic altceva schimbat.

Dacă mai apare vreodată „Failed loading resource" pe o imagine care se deschide
perfect în Windows: primii patru octeți spun adevărul.

Tot la import: **mipmaps pornite** pe pergament. Imaginea are 2816px lățime și se
vede la ~1150; fără mipmaps ar fi sclipit la fiecare redimensionare.

### Verificat, nu presupus

- Rulat cu `--headless`: nicio eroare de parsare, niciun avertisment nou.
- Captură de ecran la 1280×720, cu o expediție pornită din sămânța 4242 și două
  noduri parcurse: pergament, opt simboluri, drumuri punctate, aură pe nodul
  curent, X roșu pe cel parcurs, nimic peste carte.
- **Clic simulat pe un nod adevărat** (`Input.parse_input_event` pe centrul lui):
  semnalul `apasat` a ajuns. Un `Control` desenat primește mouse-ul la fel ca un
  buton — era singurul lucru pe care schimbarea îl putea rupe pe tăcute.

### Ce a rămas de făcut aici

- **Panourile (loadout, sumar, mesaj) au rămas închise la culoare**, sub un voal
  negru. Nu se bat cap în cap cu pergamentul (voalul le desparte), dar sunt
  singurele bucăți care n-au trecut prin inversarea paletei. Când vine rândul
  cetății, merită făcute din aceeași hârtie.
- `ZONA_CARTE` din `harta.gd` e măsurată din imaginea de azi. Dacă pergamentul se
  schimbă vreodată, ăla e singurul loc de reglat.
- Simbolurile sunt desenate în cod, deci nu costă nimic azi. Când vine artă
  adevărată, fiecare funcție devine un `draw_texture_rect`; tabelul rămâne.

### Fișiere atinse pe 17 septembrie 2026

```
assets/art/campaign_map.jpg (+ .import)  — redenumit din .png (era JPEG)
scenes/harta/simbol_nod.gd               — NOU: nodul desenat (class_name SimbolNod)
scenes/harta/panza.gd                    — rescris: drumuri punctate, curbe
scenes/harta/harta.gd                    — paletă de cerneală, abatere organică,
                                           zona cărții, eticheta de hover
scenes/harta/harta.tscn                  — fundal de pergament, texte de cerneală
```

---

## Sesiunea hărții (16 septembrie 2026) — pasul 6: lupta nu mai e tot jocul

**Ce s-a schimbat:** până acum jocul ERA o luptă, cu un panou din care îți
alegeai adversarul. Acum lupta e un NOD dintr-o expediție: îți alegi uneltele,
alegi un drum pe o hartă ramificată, iar PV-ul, Fragmentele și loadout-ul te
însoțesc de la un nod la altul.

Scena principală nu mai e `lupta.tscn`, ci `harta.tscn`.

### Cum e structurată starea expediției (partea care contează la Save)

Ăsta e răspunsul la întrebarea pusă în sesiune, și e cel mai important lucru
din tot ce s-a scris azi. Toată starea trăiește în `autoload/expeditie.gd`, iar
forma ei a fost decisă de **trei reguli**:

**1. Starea e DATE, nu noduri.** Nicăieri în `expeditie.gd` nu există o
referință către un Button, un Control sau o scenă. Harta e un `Array` de
dicționare; ecranul o *desenează*, dar nu o *ține*. Dacă starea ar sta în noduri
de interfață, „salvează expediția" ar însemna „salvează o bucată de scenă" —
imposibil de scris în JSON și imposibil de citit peste un an.

**2. Totul e tip simplu.** int, float, bool, String, Array, Dictionary. Niciun
`Color`, niciun `Vector2`, niciun `PackedScene`. Astea sunt lucruri de DESENAT,
nu de reținut: culoarea unei discipline se ia din catalog, după cheie, în clipa
desenării. De-aia `spre_dictionar()` e o copiere, nu o conversie cu douăzeci de
cazuri.

**3. Legăturile sunt chei text și indici, nu obiecte.** Loadout-ul ține
`["memorie", "logica"]`, nu fișele disciplinelor. Un nod ține `"spre": [3, 4]`,
nu nodurile următoare. Un save e o fotografie, iar o fotografie nu poate conține
obiecte vii.

Un nod de hartă arată așa:

```
{ "id": 3, "adancime": 2, "coloana": 0, "tip": Nod.LUPTA,
  "buget": 2.1, "samanta": 88123, "spre": [5, 6] }
```

#### Cele trei straturi de durată

Prima decizie a oricărui save nu e „cum scriu", ci „ce trăiește cât":

| Strat | Ce | Unde |
|---|---|---|
| **Permanent** | Fragmentele | `Tezaur` |
| **Pe expediție** | harta, poziția, PV-ul, loadout-ul, recordurile, **plus ce întrebări s-au pus deja** | `Expeditie` + `Sac` |
| **Pe luptă** | runda, PA, ceasul inamicului, lanțul | `lupta.gd` — **nu se salvează** |

Despărțirea asta e ce face save-ul o problemă mică mai târziu. Consecința
practică a stratului trei: dacă închizi jocul în mijlocul unei lupte, expediția
se reia **de la nodul ăla**, nu din mijlocul turei 3. E o alegere, nu o scăpare
— starea unei lupte în desfășurare (tween-uri, un puzzle deschis, un lanț la
treapta 7) e de zece ori mai greu de serializat decât merită.

Verificat: `spre_dictionar()` → `JSON.stringify()` → `parse` →
`din_dictionar()` întoarce harta identică, câmp cu câmp. 973 de octeți pentru o
expediție întreagă.

`Sac.expeditie_noua()` — scrisă acum două sesiuni și lăsată necheamată de nimeni
— se cheamă în sfârșit, din `Expeditie.incepe()`. Acolo îi era locul.

### „Alege N din M", fără să scrie 3 sau 8 nicăieri

Tabelul disciplinelor s-a mutat din `lupta.gd` în **`autoload/discipline.gd`**.
Mutarea n-a fost curățenie: ecranul de loadout are nevoie de aceeași listă, iar
el nu e o luptă. Un tabel de care au nevoie două scene nu mai poate sta în
niciuna dintre ele.

- **M** = `Discipline.cate()`
- **N** = `Expeditie.DISCIPLINE_IN_LOADOUT`

Nicăieri altundeva. Ecranul desenează M rânduri și numără până la N; **lupta
construiește exact atâtea Obeliscuri câte are loadout-ul**. De-aia scena de
luptă nu mai are trei noduri Obelisc scrise de mână — cu N variabilă, trei
noduri fixe în scenă ar fi fost o minciună așteptată să se întâmple.

Azi M = 3 și N = 3, deci „alegerea" e le-iei-pe-toate, iar ecranul o spune pe
față în loc să se prefacă. Singurul moment în care puteam scrie corect regula
era acum, cât e banală.

Bonus: vulnerabilitatea inamicului se compară acum pe **cheie** (`"cuvinte"`),
nu pe numele afișat (`"Cuvinte"`). Comentariul vechi promitea că legătura „se
strânge când disciplinele vor deveni date". Au devenit, deci s-a strâns.

### Harta: straturi, nu noduri răzlețe

Generată din sămânță, cu `RandomNumberGenerator` propriu — **nu** `randi()`
global, care depinde de câte numere a cerut restul jocului înainte și ar da alte
hărți după o luptă mai lungă.

5 sau 6 straturi; primul și ultimul cu un nod, cele din mijloc cu două:
**8 sau 10 noduri**. Primul strat e mereu Luptă (o expediție care începe cu
odihnă n-are ce odihni); ultimul e mereu Elită.

Legăturile se trag în doi pași, și al doilea e cel care face harta jucabilă:
fiecare nod primește 1-2 urmași la întâmplare, **apoi se repară** — orice nod
rămas fără părinte primește unul. Fără pasul doi, generatorul putea produce un
nod în care nu se poate ajunge. Verificat pe 200 de hărți: toate nodurile
accesibile, exact un capăt, de fiecare dată.

#### Bugetul de dificultate (pregătit pentru pasul 10)

Fiecare nod are un **buget** care crește cu adâncimea:
`BUGET_BAZA + BUGET_PE_ADANCIME × adâncime`, ×`BUGET_ELITA` la Elită.

De ce un buget și nu un „nivel 1-2-3": un număr continuu **se poate împărți**.
Un nod cu 3,2 poate lua un inamic de 2 plus un modificator de 1, sau unul de 3
simplu. Un „nivel 2" nu poate cumpăra nimic, poate doar să fie. Scris acum, cât
e ieftin — e greu de introdus într-un generator care merge deja fără el.

Bugetul alege azi tipul nodului, prin ponderi care se schimbă cu adâncimea
(`PONDERI_NOD`). Măsurat pe 500 de hărți:

| Adâncime | Luptă | Eveniment | Odihnă | Elită |
|---|---|---|---|---|
| 1 | 68% | 20% | 9% | 3% |
| 2 | 54% | 21% | 16% | 10% |
| 3 | 45% | 20% | 19% | 17% |

Elita pornește aproape imposibilă și devine probabilă; Odihna e rară la început
(n-ai ce recupera) și crește pe măsură ce expediția te macină.

### Granița dintre hartă și luptă

Cea mai importantă decizie de structură după forma stării:

> **Expediția știe cât de GREU e un nod. Lupta știe CINE poate fi inamicul.**

`Expeditie` n-are niciun nume de inamic în ea și nu vrea să aibă: produce un
buget și o sămânță. Tabelul `INAMICI` rămâne în `lupta.gd`, iar
`_alege_inamicul()` traduce greutatea în adversar. La pasul 10 (generatorul de
inamici), **tot ce se schimbă e funcția aia** — harta nu află niciodată că s-a
întâmplat ceva.

Sămânța e **a nodului**, nu a hărții: același nod dă același inamic de fiecare
dată când reiei expediția, dar două noduri alăturate dau adversari diferiți.

Fiecare inamic a primit un câmp **`cost`** — de la ce buget are voie să apară.
Fără el, primul nod al unei expediții putea fi cel mai greu adversar din joc.

**Și o corectură găsită la prima rulare:** „încape în buget" singur nu ajungea —
Soldatul încape în ORICE buget, deci ieșea și la nodul de Elită de la capăt. O
expediție care se termină cu același adversar cu care a început nu se simte ca
un drum. Acum din cei care încap se păstrează doar cei mai scumpi, o fereastră
de doi. Efectul secundar e chiar cel căutat: **alternanță**, fără o listă de
rotație.

N-am folosit `Sac` aici, deși ar da alternanță perfectă: sacul trage cu
generatorul global, iar atunci același nod n-ar mai da același inamic la o
reluare. Reproductibilitatea valorează mai mult decât ultimul pic de varietate.

### Regulile de run

| Regulă | Unde trăiește |
|---|---|
| PV-ul **nu** se reface între lupte | `Expeditie.pv`. Lupta îl împrumută în `reseteaza_lupta()` și îl dă înapoi în `_inapoi_la_harta()` — un singur loc, pe amândouă drumurile |
| Doar Odihna vindecă | `Expeditie.odihneste()`, procent din maxim (35%), nu cifră fixă: când PV_MAX va crește din cetate, odihna crește cu el |
| Fragmentele se acumulează | `Expeditie.incaseaza()` le pune ȘI în tezaurul permanent, ȘI în socoteala runului. Un singur loc care face amândouă — două adăugiri separate ar fi două numere care pot ajunge să difere |
| Loadout fix pe toată expediția | `Expeditie.loadout`, scris o dată în `incepe()` |

Elita înmulțește PV, daune **și răsplată** cu același 1,6 (plus un bonus fix).
Un nod mai greu care ar plăti la fel ar fi o capcană pentru cine nu știe încă
harta — iar jocul ăsta nu pedepsește curiozitatea.

### Finalul, decis într-un singur loc

Lupta nu știe dacă nodul ăsta era ultimul, și nici nu trebuie: singurul lucru pe
care îl raportează e PV-ul rămas. Amândouă butoanele de verdict duc în același
loc — harta —, iar `_dupa_un_nod()` din `harta.gd` e **singura** funcție care
decide: PV zero → înfrângere; fără noduri mai departe → victorie; altfel →
mergi mai departe. Dacă ar decide și lupta, ar exista două locuri care socotesc
„s-a terminat expediția?", iar al doilea s-ar înșela într-o zi.

Sumarul arată: noduri parcurse, lupte câștigate, cel mai lung lanț, critice, cea
mai grea luptă, Fragmente **din expediție** și Fragmente **cu totul** — două
cifre dinadins, fiindcă sunt două lucruri: una măsoară runul, alta averea care
rămâne. Și sămânța, la vedere.

Sămânța stă la vedere și în antetul hărții, tot timpul. Un bug raportat ca „se
blochează la nodul 6" nu se poate reproduce dacă numărul ăla e ascuns în cod.

### Verificat prin scenele reale, nu prin copii ale lor

- loadout: butonul stă blocat la 1/3 și 2/3, se deschide la 3/3;
- expediție întreagă parcursă nod cu nod: PV 15 → 12 → 9, Odihnă +6 → 15,
  Fragmente 18 → 34 → 75, Elita plătește 41;
- **aceeași sămânță, două rulări: drum identic, inamici identici**
  (`0XSOLD 1+ 3+ 5? 7!LANC` de două ori);
- semințe diferite → hărți diferite, 8 sau 10 noduri;
- înfrângere: butonul scrie „Vezi sumarul", harta arată „EXPEDITIE PIERDUTA";
- „Expediție nouă" întoarce la loadout, cu expediția golită.

### Ce a rămas de făcut aici

- **Evenimentul e placeholder** și o spune pe față în text. Un nod care nu face
  nimic dar pretinde că face e mai rău decât unul care recunoaște.
- Lipsește `assets/audio/muzica_harta.ogg` — harta merge în liniște, cu un
  avertisment în consolă. (`sound_castle.ogg`, netrackuit în repo, ar putea fi
  exact piesa.)
- Save/Load pe disc (pasul 8) are acum tot ce-i trebuie: `Tezaur`, `Expeditie`
  și `Sac` știu toate trei `spre_dictionar()` / `din_dictionar()`.
- Harta nu are încă zoom sau derulare. La 10 noduri încape; la o expediție
  lungă, nu va mai încăpea.

---

## Sesiunea măsurătorii (16 septembrie 2026) — Logica era dreaptă, ochiul nu

**Ce s-a schimbat:** bănuiala că Obeliscul Logicii dă prea des un anumit tip de
întrebare s-a dovedit **falsă, măsurat**. În schimb, măsurătoarea a scos la
iveală altceva: identitatea unei întrebări era greșit definită, iar
anti-repetiția de la Cultură generală nu acoperea celelalte două discipline.
Ambele sunt reparate. Baza de categorii a Logicii a crescut de la 51 la 80.

### Întâi măsurat, apoi reparat

Regulă pe care merită s-o țin: **nu repara o distribuție pe care n-ai
măsurat-o.** O întrebare de tipul „parcă vin prea multe șiruri numerice" se
simte adevărată și e imposibil de verificat din memorie — creierul ține minte
aglomerările, nu golurile dintre ele.

Măsurat prin scena reală (`_alege_reteta`, cu nivelul venind din treaptă exact
ca în `lupta.gd: nivel_treapta`):

| Trageri | ANALOGIE | DEDUCȚIE | INTRUS | SILOGISM | ȘIR |
|---|---|---|---|---|---|
| 200 | 27% | 21% | 16% | 16% | 21% |
| 2 000 | 19% | 22% | 20% | 19% | 20% |
| 20 000 | 19% | 20% | 20% | 20% | 20% |

**Mecanismul e perfect uniform.** Alegerea în două trepte din `_alege_reteta` —
întâi tipul, apoi tiparul — face exact ce promite: cele 9 tipare de șiruri
numerice nu trag ȘIR la 9/17, ci la 1/5, ca toate celelalte.

**Și totuși percepția nu minte.** Uită-te la primul rând: la 200 de trageri —
adică o sesiune lungă, cât un joc de seară — un tip poate ieși 27% și altul
16%. Aia e o diferență pe care ochiul o simte, și e pur noroc. Cifra care
liniștește (20%) se vede abia la 20 000 de trageri, adică la o sută de seri.
Deci răspunsul cinstit e: **distribuția e corectă, iar aglomerările dintr-o
sesiune sunt reale, nu imaginate — doar că nu sunt un bug.** Dacă vreodată
chiar deranjează, soluția nu e să umblu la probabilități, ci să trec și
alegerea tipului printr-un sac. Nu e cazul azi.

### Ce a găsit măsurătoarea în schimb: „Care nu se potrivește?"

Prima variantă a măsurătorii număra întrebări distincte după ENUNȚ. Rezultatul
pentru Intrusul, la toate nivelurile:

```
INTRUSUL: 1 distincte / 45 trageri (cea mai repetata: 45x)
```

Nu era un bug al generatorului — era unul al măsurătorii, și exact el m-a dus
la bugul real. Enunțul fiecărei întrebări de tip Intrusul este „Care nu se
potrivește?". **Tot ce face o astfel de întrebare să fie ea stă în variante.**

De aici, regula: **identitatea unei întrebări e enunțul PLUS variantele.**
Amândouă jumătățile, și fiecare pentru alt motiv:

- numai enunțul nu ajunge — vezi Intrusul, unde 45 de întrebări diferite arătau
  ca una repetată de 45 de ori;
- variantele trebuie **sortate**, fiindcă se amestecă la fiecare apariție
  (`_amesteca`). Nesortate, aceeași întrebare ar primi de fiecare dată altă
  identitate — adică nicio repetare n-ar fi detectată vreodată.

### Anti-repetiția s-a mutat în `puzzle.gd`, pentru toate disciplinele

Sesiunea trecută, sacul acoperea doar Cultura generală. Acum regula stă în baza
comună și se aplică oricărei discipline, **inclusiv celor care nu există încă**.
E același motiv pentru care există `puzzle.gd`: altfel ar fi trei copii ale
aceleiași reguli, cu trei șanse să se despartă pe furiș — iar la a opta
disciplină, opt.

`porneste()` nu mai cheamă `_compune_intrebare()` direct, ci
`_compune_nerepetata()`, care cere o întrebare până iese una nevăzută.

### Două mecanisme, fiindcă sunt două feluri de disciplină

Asta e decizia de proiectare a sesiunii, și merită ținută minte:

| Fel | Cine | Mecanism | Ce oferă |
|---|---|---|---|
| **alege** dintr-o listă finită | Cultură generală (135 de întrebări în fișier) | `Sac.extrage()` | **garanție**: nicio repetare cât mai există o întrebare nevăzută |
| **fabrică** întrebări | Logica, Cuvinte | `Sac.retine()` + reîncercare | **probabilitate**: se cere alta când iese una văzută |

Logica nu poate folosi sacul, oricât mi-aș dori: „șirul care adună 4, pornind de
la 7" nu e o intrare într-un tabel, e un rezultat care nu există până nu-l ceri.
Mulțimea întrebărilor ei posibile e uriașă și nu se poate scrie pe bilete. Ce se
poate face e un registru și o reîncercare — iar cu zeci de mii de întrebări
posibile și câteva zeci văzute, prima reîncercare reușește aproape întotdeauna.

Trivia își spune „mă ocup singură" întorcând șir gol din `_identitate_intrebare`.
Nu e o scutire, e unealta mai bună: două mecanisme peste aceleași întrebări ar fi
șters exact garanția pe care o dă sacul.

**Și nu eșuează niciodată.** Dacă după 12 încercări tot iese ceva văzut, se
acceptă repetarea și se deschide un ciclu nou. O repetare rară e un preț mult
mai mic decât un Obelisc care refuză să se deschidă în mijlocul unui lanț.

Eticheta sacului se deduce din numele fișierului (`logica.gd` → `"logica"`), ca
o disciplină nouă să nu poată uita să-și dea un nume — și nici să-l scrie din
greșeală pe al altcuiva, ceea ce le-ar amesteca registrele fără niciun semn
vizibil.

### Măsurat, înainte și după

120 de trageri pe disciplină și nivel — o expediție lungă:

| | înainte | după |
|---|---|---|
| Logica | până la 6% repetate (ȘIR NUMERIC) | **0 din 120** |
| Cuvinte | până la 19% repetate (DEFINIȚIE, nivel III) | **0 din 120** |
| Cultură generală | deja pe sac | 45 distincte, apoi ciclu nou |

Zero repetări consecutive peste tot, inclusiv la granițele dintre cicluri.

Cultura generală arată „45 distincte din 120" fiindcă poolul ei chiar are 45 de
întrebări pe nivel: la a 46-a tragere sacul se golește și începe un ciclu nou.
Nu e o scăpare, e limita de conținut — și se vede exact unde e.

### 51 → 80 de categorii la Logică

Regulile din antetul lui `logica.gd` sunt respectate și verificate automat la
scriere: minimum 4 membri per categorie, minimum 2 categorii per domeniu,
**categorii disjuncte** (niciun membru în două categorii — altfel „intrusul" ar
avea două răspunsuri bune).

| Domeniu | Înainte | Acum |
|---|---|---|
| natura | 12 | 16 |
| stiinta | 9 | 13 |
| geografie | 8 | 13 |
| obiecte | 7 | 11 |
| istorie | 5 | 10 |
| arta | 5 | 9 |
| abstract | 5 | 8 |
| **total** | **51** | **80** — 479 de membri unici |

Am adăugat dinadins **perechi în același domeniu**: „vicii" lângă „virtuți",
„piese de armură" lângă „arme medievale", „rozătoare" lângă „canide". Ele sunt
combustibil pentru generatoarele GRELE — `_intrus_din_acelasi_domeniu` și
`_analogie_stransa` —, cele care fac diferența dintre „leu, tigru, ghepard,
ciment" și o întrebare care chiar te pune să te uiți.

### Ce a rămas de făcut aici

- `Sac.expeditie_noua()` tot așteaptă harta (pasul 6).
- Cuvintele au 60 de cuvinte în 9 găleți; DEFINIȚIE la nivelul III era cel mai
  aglomerat colț înainte de reparație. Când extind vocabularul, acolo e nevoia.
- Dacă vreodată aglomerările dintr-o sesiune chiar deranjează, alegerea TIPULUI
  din `_alege_reteta` poate trece și ea prin sac. Măsurat, azi nu e nevoie.

---

## Sesiunea sacului (16 septembrie 2026) — 135 de întrebări, și niciuna de două ori

**Ce s-a schimbat:** baza de la Obeliscul Memoriei a crescut de la 45 la **135
de întrebări** (45 pe nivel), a căpătat două domenii noi, iar alegerea lor nu mai
e o aruncare de zar: e un sac din care biletele ies o singură dată.

### De ce 45 pe nivel, și nu „cât mai multe"

45 nu e o cifră rotundă din întâmplare. E cam de trei ori mai mult decât poate
consuma o expediție lungă, deci ai marjă să nu vezi sacul golindu-se. Sub atât,
extinderea ar fi fost o amânare; peste atât, aș fi scris conținut înainte să
știu dacă restul buclei merită conținut.

Împărțirea pe nivel a rămas cea de dinainte, și e singura măsură a dificultății:

| Nivel | Ce înseamnă |
|---|---|
| 1 | o știe orice adult, fără să fi studiat ceva anume |
| 2 | s-a predat la școală; îți amintești dacă ai fost atent |
| 3 | o știi doar dacă domeniul te-a interesat dincolo de școală |

Definițiile astea sunt scrise acum în antetul lui `trivia.gd`. Fără ele,
„nivelul 2" devine, după două luni, „cât de greu mi s-a părut în seara aia".

### Șase domenii, ținute în echilibru dinadins

**8 / 8 / 8 / 7 / 7 / 7 pe fiecare nivel** — istorie, geografie, știință, artă,
mitologie, literatură. Ultimele două sunt noi: **mitologia** n-avea nicio
întrebare, iar **literatura** stătea îndesată în „artă".

Despărțirea n-a fost estetică. La 45 de întrebări, cărțile încăpeau lângă
pictură și muzică. La 135, cine vrea să adauge o întrebare nu mai știe unde să
caute, și — mai rău — nu mai poți citi dintr-o privire dacă baza e echilibrată.

Iar echilibrul chiar contează, fiindcă **întrebarea nu-și alege domeniul: se
trage din tot nivelul**. Dacă istoria ar avea 20 de intrări și mitologia 3,
„Cultură generală" ar deveni în practică „Istorie, cu accidente" — și ai antrena
un singur colț de minte, deși Obeliscul promite altceva.

### `autoload/sac.gd` — al cincilea autoload

**Problema:** `pick_random()` n-are memorie. Cu 45 de întrebări pe nivel, șansa
ca a doua întrebare s-o repete pe prima e 1 din 45. Dar nu tragi două întrebări
pe expediție, tragi zeci — iar șansa ca în 20 de trageri să apară măcar o
repetare e de aproape 99%. (E „paradoxul zilelor de naștere": 23 de oameni
într-o cameră și e deja mai probabil decât nu ca doi să aibă aceeași zi.)

Și o repetare nu e doar plictisitoare: e o **întrebare gratis**. Un joc de
antrenament mental care-ți dă un punct fiindcă ții minte ce-ai apăsat acum două
minute se sabotează singur.

**Soluția, pe scurt:** toate întrebările sunt bilete într-un sac. Tragi unul, îl
citești, îl pui deoparte — nu înapoi. Următoarea tragere alege dintre cele
rămase, deci nu poate repeta. Când sacul se golește, biletele se întorc toate
înăuntru și începe un ciclu nou. Tiparul se cheamă „shuffle bag"; îl folosesc
jocurile pentru exact problema asta (piesele din Tetris vin la fel).

Singura subtilitate e la **răscrucea dintre cicluri**: dacă ultimul bilet al
ciclului vechi ar putea fi primul din cel nou, ai vedea aceeași întrebare de
două ori la rând — fix cazul care se simte cel mai prost. Sacul ține minte
ultima extragere și o exclude din prima tragere a ciclului nou.

**De ce e un autoload, și nu un `static var` în `trivia.gd`:** o expediție
înseamnă mai multe lupte, iar între două lupte scena se schimbă. Același motiv
pentru care `Tezaur` e autoload. Stă lângă `Muzica`, `Sunet`, `Fereastra`,
`Tezaur`.

**De ce e generic:** nimic din el nu știe ce e o întrebare. Primește o listă,
întoarce un element. A doua disciplină care are nevoie de „fără repetiții"
(Cuvinte are un fișier finit, la fel Logica pentru categorii) nu adaugă cod
acolo — adaugă o **cheie**. Cheia trebuie să cuprindă tot ce face lista să fie
alta, deci include și nivelul: `"cultura_generala:2"` e alt sac decât
`"cultura_generala:3"`.

**Identitatea unui bilet e textul întrebării, nu poziția în listă.** Poziția e
legată de ordinea din fișier: adaugi mâine o întrebare la mijloc și tot ce vine
după se mută cu unu, iar un save vechi ar crede că a văzut alte întrebări.
Aceeași decizie ca la `Tezaur`, unde resursele se salvează pe chei text.

`spre_dictionar()` / `din_dictionar()` există de pe acum, din același motiv ca
la tezaur. Ce salvează ele e memoria unei **expediții**, nu progres permanent.

**`expeditie_noua()` încă n-o cheamă nimeni, și e în regulă.** Harta (pasul 6) e
locul ei firesc — acolo se naște noțiunea de „expediție nouă". Până atunci o
expediție ține cât o rulare a jocului, fiindcă autoload-ul pornește gol; ceea ce
înseamnă că întrebările nu se repetă nici măcar între două lupte consecutive.

### Variantele se amestecă la fiecare apariție

Descoperire făcută în timpul lucrului, și mai importantă decât pare: în baza
scrisă de mână, **poziția a doua era răspunsul corect de patru ori mai des decât
ultima** (59 față de 13, din 135). Nimeni n-a vrut asta — așa scrie omul
întrebări.

Nu e un amănunt de statistică, e o **scurtătură**. Sub cronometru, un jucător
care nu știe răspunsul ghicește; dacă ghicitul are un favorit, îl găsește fără
să-l caute și marchează puncte fără să fi gândit. Într-un joc de antrenament
mental ăsta e cel mai rău lucru care se poate întâmpla.

Se putea rezolva rescriind fișierul până ies 25% pe fiecare poziție. Ar fi ținut
exact până la a 136-a întrebare scrisă noaptea. Amestecarea la rulare
(`_amesteca`, în `trivia.gd`) rezolvă problema o dată, pentru toate întrebările
care vor mai fi scrise vreodată. Măsurat pe 4000 de trageri: 1015 / 993 / 1033 /
959 — uniform.

Bonus: aceeași întrebare, revăzută peste două expediții, nu-ți mai poate fi
ghicită din poziția butonului. Ții minte **răspunsul** sau nimic.

`_amesteca` reține textul răspunsului bun, nu indicele — indicele e exact ce se
schimbă — apoi îl regăsește cu `find()`. Asta e corect doar fiindcă
încărcătorul refuză acum întrebările cu **două variante identice** (verificare
nouă): altfel „prima potrivire" ar putea fi cealaltă, iar răspunsul bun ar fi
marcat greșit. Verificarea aia nu e curățenie — ea e ce face `find()` sigur.

### Verificat, nu presupus

Rulat headless, pe toate trei nivelurile:

- 135 din 135 de întrebări trec validatorul (niciun câmp lipsă, nicio categorie
  scrisă greșit, nicio variantă dublată);
- în primul ciclu de 45 de trageri: **45 de întrebări distincte** — zero repetări;
- în 200 de trageri: **zero repetări consecutive**, inclusiv peste granițele
  dintre cicluri;
- `_amesteca` nu pierde niciodată răspunsul corect.

### Ce a rămas de făcut aici

- `Sac.expeditie_noua()` se cheamă când apare harta.
- Când se face save/load pe disc, `Sac.spre_dictionar()` intră în save-ul
  expediției în desfășurare, nu în progresul permanent.
- Disciplinele care citesc din fișiere finite (Cuvinte, Logica) ar trebui să
  treacă și ele prin sac. E o linie fiecare, dar merită făcută când le atingi
  oricum, nu într-o sesiune separată.

---

## Sesiunea celor trei inamici (16 septembrie 2026) — arhetipul nu mai e inamicul

**Ce s-a schimbat:** până acum exista UN inamic, ales dintr-o constantă din cod
(`ARHETIP_INAMIC`) pe care o schimbai și reporneai jocul. Acum sunt trei, aleși
dintr-un panou la pornirea luptei.

### Problema reală nu era „mai vreau doi inamici"

Numele, facțiunea și descrierea inamicului stăteau în `DATE_ARHETIP` — tabelul
**arhetipurilor**. Mergea perfect atâta timp cât era un singur inamic per
arhetip, fiindcă atunci „arhetip" și „inamic" păreau același lucru.

Al treilea inamic a spart presupunerea: **Soldatul și Spadasinul folosesc
amândoi „Atac constant"**, dar sunt doi adversari diferiți, cu alte cifre și
altă descriere. Un arhetip e o *regulă de comportament*, refolosibilă de
oricâți inamici — nu o fișă de personaj.

Așa că tabelul s-a rupt în două:

| Ce | Unde | Ce ține |
|---|---|---|
| `NUME_ARHETIP` | un dicționar de patru rânduri | doar numele afișat al regulii |
| `INAMICI` | un Array de Dictionary, ca `OBELISCURI` | nume, facțiune, descriere, PV, daune, ceas, vulnerabilitate, colorare |

E despărțirea anunțată la **pasul 11** din ruta de construcție, făcută mai
devreme fiindcă azi a costat zece rânduri. După generatorul de inamici ar fi
costat rescrierea lui.

### Cei trei

| Inamic | Arhetip | PV | Lovitură | Cârligul lui |
|---|---|---|---|---|
| **Soldatul** | Atac constant | 30 | 3 / tură | etalonul — e inamicul de până acum, redenumit |
| **Lăncierul** | Grabnic | 34 | 8 la ceas plin (3 runde) | cursa contra ceasului: te lasă în pace două runde din trei |
| **Spadasinul** | Atac constant | 40 | 4 / tură | vulnerabil la **Cuvinte**: daune ×2 |

Ceasul Grabnicului exista deja în cod, scris și nefolosit. N-a trebuit activat —
a trebuit doar ca cineva să-l aibă: `are_ceas()` întreabă dacă rândul din tabel
are cheia `ceas`, nu dacă inamicul e de un anume arhetip. Când va apărea al
doilea arhetip cu ceas (un boss care își adună o descărcare), interfața merge
neatinsă.

### Vulnerabilitatea: o stare, nu un eveniment

Daunele se **înmulțesc** cu 2, nu primesc un bonus fix. Un „+2 daune" ar fi
dublat treapta 1 și n-ar fi contat la treapta 10; înmulțirea păstrează aceeași
promisiune pe toată lungimea lanțului. Se aplică **peste** critic, nu în locul
lui — o treaptă critică pe disciplina slabă e ×2 din treaptă și încă ×2 de aici
(treapta 5 pe Cuvinte, contra Spadasinului: **12 daune**).

**Nu se aprinde un marcaj pe ecranul de puzzle,** cum face „CRITIC!". Criticul e
un *eveniment* — o dată la cinci întrebări — deci merită un fulger.
Vulnerabilitatea e o *stare*: dublează fiecare treaptă, la nesfârșit. Un marcaj
la fiecare întrebare n-ar mai fi un accent, ar fi tapet. Ea se anunță o dată,
înainte de luptă, și stă scrisă tot timpul sub numele inamicului — iar în lanț
se vede unde contează: în bara lui, care scade de două ori mai repede.

Eticheta e **chihlimbar, nu roșie**: roșul e deja al inamicului în interfața asta
(bara lui de PV, intenția lui de atac), iar o etichetă roșie s-ar fi citit
„pericol", când ea spune exact pe dos — *aici e deschis*.

### Alegerea inamicului e o unealtă de test, și scrie asta pe ea

Panoul de la pornirea luptei nu e o mecanică de joc: în jocul terminat
adversarul vine de la nodul de pe hartă (pasul 6). Dar nu e nici cod de aruncat
— citește tabelul `INAMICI` și cheamă `reseteaza_lupta()` cu un index, adică fix
interfața de care va avea nevoie harta („pornește lupta cu inamicul N"). Când
vine harta, dispare panoul și rămâne funcția.

Butonul de verdict duce acum înapoi în panou, pe amândouă drumurile, ca să se
poată juca trei lupte la rând fără repornire.

### Artă: zero fișiere noi

Toți trei folosesc aceeași siluetă, cu altă **colorare** (`modulate`, adică o
înmulțire de culoare peste pixelii existenți): Soldatul neutru, Lăncierul
albăstrit („oțel rece"), Spadasinul arămiu. Trei armuri desenate ar fi fost artă
făcută înainte ca cele trei comportamente să fi fost validate ca distractive —
adică exact ordinea pe care o evităm.

Colorarea se pune pe **figurile** inamicului, nu pe învelișul lor: `impact.gd`
își scrie singur `modulate` la fiecare lovitură și îl pune înapoi pe alb la
final, deci o culoare pusă acolo ar fi fost ștearsă la prima lovitură încasată.
Așa cele două se înmulțesc cum trebuie — fulgerul aprinde figura colorată.

### Ștergerea a ieșit din texte

Numele și descrierile nu mai trimit la rama narativă abandonată: „Cavalerul
Șters" → **Soldatul**, facțiunea „Cei Șterși" → **Garnizoana** (nume de lucru,
fără efect mecanic), iar descrierea Fragmentelor și comentariile siluetei s-au
rescris fără ea. Silueta desenată a rămas neschimbată ca formă — un adversar
fără chip funcționează în aproape orice ramă medieval-fantasy.

### Ce a rămas de făcut

- **Facțiunea e încă inertă.** Toți trei sunt „Garnizoana" și nu schimbă nimic
  mecanic. E cârligul pentru zone de hartă și echipament anti-facțiune.
- **Rezistențele** sunt tot o listă goală, spre deosebire de vulnerabilitate,
  care acum chiar face ceva.
- **Vulnerabilitatea se compară ca text** cu numele disciplinei din
  `OBELISCURI`. O scrii greșit și nu se întâmplă nimic, fără nicio eroare. Se
  strânge singură la pasul 1 (disciplinele devin date, cu identificatori).
- **Cifrele n-au fost jucate destul.** PV-urile (30/34/40) și daunele sunt o
  scară, nu un echilibru — Spadasinul mai ales: dacă lupta cu el nu se simte
  vizibil mai scurtă când ataci pe Cuvinte, cifra e greșită, nu ideea.

---

## Sesiunea recompenselor (16 septembrie 2026) — victoria plătește, și se vede de ce

**Ce s-a schimbat:** până acum victoria era un panou și o fanfară, apoi nimic.
Acum lasă ceva în urmă: **Fragmente** (nume provizoriu), prima resursă a jocului.

### Suma nu e fixă, e o defalcare

Patru linii, toate vizibile în panoul de verdict, sub text:

| Linia | Cât | De ce ea |
|---|---|---|
| Victorie | 10 | simplul fapt că ai învins |
| PV rămas | până la 10, proporțional | „nu te-a lovit" e o pricepere: fiecare lanț lung e o tură în care inamicul n-a apucat să lovească |
| Cel mai lung lanț | 1 / treaptă | cel MAI LUNG, nu suma tuturor — zece lanțuri de câte două trepte sunt un joc prudent, unul de douăzeci e un risc asumat |
| Lovituri critice | 3 / critic | treapta 5, 10, 15 primește o răsplată și în afara luptei, nu doar daune înăuntru |

Cifrele sunt o SCARĂ, nu un echilibru: încă n-avem pe ce cheltui Fragmente, deci
n-au cum să fie „echilibrate" azi. Toate patru stau în constante lângă regulile de
combo, în `lupta.gd` — reechilibrarea va fi un drum într-un singur loc.

Liniile care ies **zero rămân pe ecran, dar stinse**. „Lovituri critice (×0) +0"
e informație: îți arată ce ai lăsat pe masă. Un rând dispărut e doar o gaură pe
care n-o observi.

**La înfrângere secțiunea dispare cu totul.** Un „+0 Fragmente" după o înfrângere
ar fi o palmă inutilă, iar jocul ăsta motivează prin curiozitate, nu prin pedeapsă.

### `autoload/tezaur.gd` — al patrulea autoload

Resursele NU aparțin unei lupte. Ținute în `lupta.gd`, ar fi dispărut la prima
schimbare de scenă — adică fix când o să ai nevoie de ele (hartă, cetate, magazin).
De-aia `Tezaur` stă lângă `Muzica`, `Sunet` și `Fereastra`.

Înăuntru nu e `var fragmente := 0`, ci un dicționar „resursă → cantitate" și un
tabel `DATE_RESURSA` cu fișa fiecărei resurse (cheie de salvare, nume afișat,
descriere). A doua resursă e un RÂND în tabel: totalurile, panoul de verdict și
salvarea merg pe orice număr de intrări. Aceeași regulă ca la Obeliscuri și la
arhetipuri — datele într-un tabel, codul citește tabelul.

API: `cat()`, `nume()`, `adauga()`, `plateste()` (scade doar dacă ai destul și
spune dacă a reușit — încă nefolosită, e pentru cetate), `goleste()`, plus
semnalul `s_a_schimbat`, cârligul pentru o viitoare bară de resurse.

### Save-ul, decis acum cât e ieftin

`spre_dictionar()` / `din_dictionar()` există de pe acum deși pasul 8 e departe:
formatul e mai ușor de ales cât tezaurul are o resursă decât peste trei luni,
când are șase. Singura decizie reală e că pe disc se scriu **chei text**
(`"fragmente"`), nu numerele din `enum`: valoarea unui enum e doar poziția lui în
listă, deci o resursă adăugată la mijloc ar muta numerele și un save vechi ar citi
fragmentele ca fiind altceva. Un text nu se mută niciodată. La încărcare, o cheie
necunoscută e ignorată și o resursă lipsă rămâne zero — un save vechi trebuie să
se deschidă chiar și strâmb.

### Cine socotește nu desenează

Trei funcții în `lupta.gd`, cu trei treburi care nu se amestecă:

| Funcție | Ce face |
|---|---|
| `calculeaza_recompensa()` | socotește și nu schimbă nimic — poți s-o chemi de zece ori (util pentru o viitoare previzualizare) |
| `acorda_recompensa()` | plătește în tezaur și întoarce exact liniile plătite |
| `_construieste_recompensa()` | doar DESENEAZĂ lista primită |

Panoul nu recalculează nimic: primește lista pe care tezaurul a încasat-o. Așa
cifra de pe ecran și cifra din tezaur nu POT ajunge diferite — e aceeași listă.

Fiecare linie își spune Și resursa, deși azi toate patru zic „Fragmente". Coloana
aia aparent degeaba e exact ce face ca a doua resursă să fie o linie în plus, nu o
rescriere a panoului.

### Două variabile noi de stare

`cel_mai_lung_lant` și `critice_totale` se țin separat de `combo_corecte` și
`lant_daune`, care se șterg la fiecare lanț nou: astea două trebuie să
supraviețuiască întregii lupte. Se golesc doar în `reseteaza_lupta()`.

### Fișiere atinse

| Fișier | Ce |
|---|---|
| `autoload/tezaur.gd` | **nou** — 147 de linii |
| `project.godot` | `Tezaur` înregistrat ca autoload |
| `scenes/lupta/lupta.gd` | constante de recompensă, două statistici, cinci funcții noi |
| `scenes/lupta/lupta.tscn` | `VerdictRecompense`, un VBoxContainer între textul de verdict și buton |

### Ce a rămas deschis

- **Numele „Fragmente" e provizoriu.** Se schimbă dintr-un singur loc
  (`DATE_RESURSA`), așa că nu e grăbită decizia.
- **Tezaurul se pierde la închiderea jocului.** Serializarea există, scrierea pe
  disc nu — pasul 8.
- **Nu se vede nicăieri în afara verdictului.** O bară de resurse are sens abia
  când există cetatea sau harta; semnalul `s_a_schimbat` o așteaptă.
- **Înfrângerea nu plătește nimic.** Dacă o expediție pierdută ajunge să pară timp
  aruncat, aici se adaugă o recompensă de consolare — `calculeaza_recompensa()`
  e deja destul de mobilată ca să primească o a doua variantă.

---

## Sesiunea bazei comune (15 septembrie 2026) — `puzzle.gd` și a treia disciplină

**Ce s-a schimbat:** Trivia și Logica erau două scene independente cu același
contract — și cu aproape 500 de linii identice fiecare (cronometru, bară de
timp, cele patru butoane, cei trei timpi ai verdictului, linia de context,
marcajul de critic, sunetele). A treia disciplină ar fi făcut datoria de trei
ori. Acum toate trei moștenesc `scenes/puzzle/puzzle.gd`, iar fiecare fișier de
disciplină răspunde la o singură întrebare: **de unde vine întrebarea**.

| Fișier | Înainte | Acum |
|---|---|---|
| `scenes/puzzle/puzzle.gd` | — | 988, o singură copie |
| `scenes/trivia/trivia.gd` | 937 | 127 |
| `scenes/logica/logica.gd` | 1664 | 861 |
| `scenes/cuvinte/cuvinte.gd` | — | 556 |
| **total** | **2601** (2 discipline) | **2532** (3 discipline + baza) |

Socoteala care contează nu e cea de sus, ci următoarea: a patra disciplină
costa înainte ~500 de linii copiate înainte de a scrie primul ei generator.
Acum costă zero.

### Contractul dintre bază și o disciplină

Lupta nu simte nicio diferență: `porneste()`, `arata_stare()`, `arata_combo()`,
semnalele `verdict` și `rezolvat` sunt exact aceleași, doar că sunt definite o
singură dată. Ce e nou e contractul dinăuntru — o disciplină scrie `extends
Puzzle` și **două funcții**:

| Funcție | Ce face |
|---|---|
| `_pregateste_datele()` | își citește fișierele; chemată de mai multe ori, face ceva o dată |
| `_compune_intrebare(nivel)` | întoarce un Dictionary cu `categorie`, `text`, `variante`, `corect`, `explicatie` |
| `_descriere_sursa()` | opțional: ce fișier să cauți dacă apare ecranul de eroare |

`Dictionary` gol = „n-am putut". Baza arată atunci un ecran de eroare și
raportează eșec ordonat, în loc să lase lupta să aștepte un semnal care nu mai
vine. Tot în bază a intrat și o **vamă**: `_intrebare_buna()` verifică
dicționarul înainte să apuce să strice ceva pe ecran — un generator care
întoarce 3 variante în loc de 4 află pe loc, nu printr-un „index out of bounds"
în mijlocul luptei.

### Și scena, nu doar scriptul

`trivia.tscn` și `logica.tscn` erau două copii ale aceluiași layout, identice
în afară de textele-placeholder. Acum există `scenes/puzzle/puzzle.tscn`, iar
cele trei discipline sunt **scene moștenite** din ea: fiecare fișier `.tscn` are
șase rânduri și nu spune decât „sunt puzzle-ul de bază, cu scriptul ăsta".
Un buton mutat cu 4px se mută acum o singură dată.

### Disciplina a treia: Cuvinte

Trei tipuri de provocare, cu șanse egale, alese **în două trepte** ca la Logică
(întâi tipul, apoi tiparul — altfel un tip cu mai multe tipare ar apărea mai des
fără să-ți dai seama de ce):

| Tip | Tipare | Exemplu |
|---|---|---|
| SENS | sinonim, antonim | „Sinonimul lui «rapid»?" |
| DEFINITIE | cuvânt → sens, sens → cuvânt | „Ce înseamnă «efemer»?" |
| ANALOGIE | pe sinonime, pe antonime | „RAPID : IUTE :: VESEL : ?" |

Tabelul `GENERATOARE` de aici **n-are câmpul `niveluri`**, spre deosebire de cel
din Logică, și nu din uitare: acolo nivelul e o însușire a generatorului
(Fibonacci e greu prin construcție), aici e o însușire a **cuvântului**.
„Sinonimul lui «vesel»?" și „Sinonimul lui «caduc»?" sunt același tipar și două
lumi diferite.

Forma analogiei e împrumutată de la Logică, literă cu literă (`A : B` pe un
rând, `C : ?` pe altul, majuscule). O analogie e o diagramă, nu o propoziție —
iar o disciplină care inventează altă formă pentru același gest de gândire te
pune s-o înveți a doua oară degeaba.

### De unde vin variantele greșite — toată valoarea disciplinei

`data/cuvinte.json`, 60 de cuvinte, câmpuri: `cuvant`, `clasa`, `nivel`,
`domeniu`, `definitie`, `sinonime`, `antonime`. Câmpul `clasa` (substantiv /
verb / adjectiv) **nu era în lista cerută, dar e cerut de regulă**: distractorii
se aleg din aceeași clasă gramaticală ȘI de la același nivel, iar fără câmp nu
există „aceeași clasă". 60 de cuvinte = 9 gălăți (3 clase × 3 niveluri), fiecare
cu 6-7 cuvinte.

Două decizii care nu se văd, dar fac diferența:

1. **Distractorii vin din listele de SINONIME ale vecinilor, nu din câmpul
   `cuvant` al lor.** Dacă răspunsul bun ar veni mereu dintr-o listă de sinonime
   iar greșelile ar fi mereu cuvinte-intrare, ai învăța în zece minute că
   răspunsul e „ăla care nu seamănă cu celelalte trei" — și ai răspunde corect
   fără să știi cuvântul. Toate patru variantele trebuie să fie același FEL de
   lucru.
2. **Un singur cuvânt de la fiecare vecin.** Două variante din aceeași familie
   ar arăta amândouă la fel de bune și ar reduce întrebarea la o alegere între
   două, nu între patru.

Încărcătorul verifică și o **regulă de aur**, ca cea de la Logică: în aceeași
gălata, un cuvânt n-are voie să fie sinonimul a două intrări diferite (altfel
apare ca distractor un al doilea răspuns corect, pe care jocul îl marchează
roșu). Avertizează și pentru gălățile sub 4 cuvinte — ele n-ar apărea niciodată
în joc, iar fără avertisment n-ai avea de unde ști de ce.

### Bugul găsit rulând generatorul de 6000 de ori

„SFIALĂ : OBRĂZNICIE :: ÎNDRĂZNEALĂ : ?" — răspunsul corect pentru
„îndrăzneală" era chiar «sfială», scrisă deja cu majuscule în colțul din stânga
sus. Sfiala și îndrăzneala sunt antonime una alteia, deci analogia se oglindea.
Datele nu erau greșite; generatorul trebuia să știe să ocolească oglinda.
Reparat: tot ce se vede în enunț (ambele cuvinte ale modelului **și** cuvântul
țintă) e interzis printre variante, iar dacă după filtrare nu mai rămâne niciun
răspuns, tiparul spune „n-am putut" și se încearcă altul.

### Verificat

Rulat cu Godot 4.7.2 headless:

- cele trei scene de puzzle pornesc singure (F6) fără eroare, fiecare își
  încarcă datele: `Cuvinte: 60 cuvinte in 9 galeti`, `Trivia: 45 intrebari`,
  `Logica: 51 categorii in 7 domenii, 18 cuvinte`
- scena de luptă pornește normal (scenele moștenite se încarcă corect, deci
  `%BaraTimp` & co. se rezolvă prin moștenire)
- **30.000 de întrebări de Cuvinte generate**, zero probleme: mereu 4 variante
  distincte și nevide, `corect` în interval, nicio variantă care apare deja în
  enunț. Distribuția pe cele șase tipare: 4898-5181 fiecare (așteptat 5000).
  Pe niveluri: exact 10.000 / 10.000 / 10.000.

### Ce rămâne deschis

- **Nu am deschis proiectul în editor.** Scenele moștenite sunt scrise de mână;
  headless zice că merg, dar merită o privire vizuală la Cuvinte (mai ales
  definițiile lungi pe butoane de 36px — `autowrap` e pornit, dar dacă vreuna
  iese din buton, scurteaz-o în JSON).
- **Diacriticele** — verificat, nu e o problemă: `cuvinte.json` folosește
  ă/â/î/ș/ț peste tot (la o disciplină de vocabular ortografia E conținutul),
  iar `intrebari_trivia.json` conținea deja ș și ț („a pășit pe Lună",
  „București"), deci fontul temei le are.
- Obeliscul se numește în continuare **„Memorie"** în `OBELISCURI`, deși
  disciplina e Cultură generală. Redenumirea e pasul 2 din rută și n-a intrat
  în sesiunea asta.
- Câmpul `explicatie` e completat de toate trei disciplinele, dar tot nu se
  afișează nicăieri. La Cuvinte ar avea cel mai mult de spus („«efemer» = care
  ține foarte puțin") — e prima candidată dacă apare vreodată un rând de
  feedback sub butoane.
- Câmpul `domeniu` din `cuvinte.json` nu e folosit de niciun generator azi.
  Există pentru ce urmează: distractori aleși dinadins din alt domeniu, sau un
  „antrenament liber" filtrat pe domenii (pasul 13).

### Fișiere atinse

```
scenes/puzzle/puzzle.gd            — NOU, baza comună (class_name Puzzle)
scenes/puzzle/puzzle.tscn          — NOU, layout-ul, o singură copie
scenes/cuvinte/cuvinte.gd          — NOU, a treia disciplină
scenes/cuvinte/cuvinte.tscn        — NOU, scenă moștenită
data/cuvinte.json                  — NOU, 60 de cuvinte pe 3 niveluri
scenes/trivia/trivia.gd            — 937 → 127 de linii
scenes/trivia/trivia.tscn          — rescris ca scenă moștenită
scenes/logica/logica.gd            — 1664 → 861 de linii
scenes/logica/logica.tscn          — rescris ca scenă moștenită
scenes/lupta/lupta.gd              — `SCENA_CUVINTE`, un rând în `OBELISCURI`
```

---

## Sesiunea butoanelor de Obelisc (15 septembrie 2026) — piese de șah în locul dreptunghiurilor

**Ce s-a schimbat:** cele trei butoane erau dreptunghiuri plate cu text colorat.
Acum fiecare are o piesă de șah deasupra numelui, bordură în culoarea
disciplinei, colțuri rotunjite și un degrade vertical discret; la hover se
aprinde și se ridică 3px, la apăsare pare scobit, iar blocat își stinge piesa și
arată un lacăt mic. Al treilea Obelisc se numește acum **Cuvinte**, nu
„Cuvantul Adevarat" (se vede și în jurnal — e același câmp `disciplina`).

### Un Obelisc e acum o scenă, nu trei butoane copiate

`scenes/lupta/obelisc.tscn`, cu patru scripturi mici în spate:

| Fișier | Ce face |
|---|---|
| `obelisc.gd` | stările și animațiile (hover, apăsare, blocat, indisponibil) |
| `fata_obelisc.gd` | fondul cu degrade, colțurile, bordura |
| `glifa_sah.gd` | piesele desenate în cod |
| `lacat.gd` | semnul de blocat |

Aceeași regulă ca la panoul de verdict: un contract, mai multe conținuturi.
Cele trei butoane au formă identică și diferă prin trei valori (nume, piesă,
culoare). Scrise de trei ori în scena de luptă, orice schimbare de formă de
mâine s-ar fi făcut de trei ori — și a treia oară s-ar fi uitat.

Rădăcina a rămas un `Button`, doar cu hainele implicite stinse
(`StyleBoxEmpty` pe toate stările). Așa primim gratis zona de click, `disabled`,
`pressed` și navigarea cu tastatura, iar `lupta.gd` nu observă nicio diferență.

**`StyleBoxFlat` nu știe degradeuri** — are o singură `bg_color`, plată, și fix
fondul plat făcea butoanele să pară desenate cu chenarul din Paint. Soluția n-a
fost un shader și nici un `TextureRect` tăiat cu `clip_children`, ci
`draw_polygon()`: primește **o culoare per vârf** și le amestecă între ele, deci
un dreptunghi rotunjit cu vârfurile de sus deschise și cele de jos închise *e*
degradeul, într-o singură desenare, cu colțurile deja rotunde.

Halo-ul din spate a rămas totuși un `Panel` cu `StyleBoxFlat`: la umbre moi,
stilul chiar e mai bun decât desenul nostru. Fiecare unealtă face ce știe.

### Glifele ♟ ♞ ♝ nu există în fontul implicit

Verificat, nu presupus: `ThemeDB.fallback_font.has_char()` întoarce `false`
pentru toate trei, și la fel pentru 🔒. Pe ecran ar fi ieșit patru pătrate goale.
Un `SystemFont` (Segoe UI Symbol) ar fi mers pe Windows, dar fonturile de sistem
nu există în export web — iar web-ul e pe listă. Deci piesele și lacătul sunt
**desenate în `_draw()`**, ca siluetele din arenă; `glifa_sah.gd` moștenește
chiar `Silueta`, ca să refolosească caseta cu proporții și traducerea din
fracțiuni în pixeli.

Desenele rămân în cod ca plasă de siguranță, chiar dacă azi toate trei
Obeliscurile au artă adevărată: ștergi un PNG și butonul merge mai departe.

### Arta: trei PNG-uri cu tabla de șah desenată în pixeli

Imaginile generate aveau „fundal transparent" doar aparent — tabla gri era
scrisă în pixeli, fișierele fiind RGB curat, fără canal alfa. Puse direct pe
buton, ar fi ieșit trei timbre gri.

Decuparea a cerut trei întrebări, toate trei trebuind să spună „tablă":

1. **e aproape de una din cele două culori ale tablei?** (deduse din rama imaginii)
2. **e plat?** — tabla n-are textură, piatra are. Ăsta a fost testul decisiv:
   fără el, bila pionului, gri și netedă, era mâncată de umplere.
3. **în vecinătate apar amândouă griurile, cam jumate-jumate?** — semnătura pe
   care doar o tablă o are. O suprafață de piatră închisă seamănă la culoare cu
   pătratul închis, dar în jurul ei nu există și pătrate deschise. Fără asta,
   nebunul (piesă închisă) se golea pe dinăuntru.

Peste ele, două lucruri geometrice: umplerea pornește **din marginea imaginii**,
deci griurile din interiorul piesei rămân piesă fiindcă nu sunt legate de
exterior; iar la final se retează de jos rândurile mai înguste de 12% din cel
mai lat rând — o piesă de șah stă pe o talpă lată, deci **ce atârnă firav sub ea
nu e piesă** (așa a plecat o tijă de 4px rămasă sub cal, lipită solid de talpă,
pe care niciun filtru de cioburi n-o vedea).

Rezultatele sunt `pion_sah.png`, `cal_sah.png`, `nebun_sah.png` (256×256, alfa
adevărat). Sursele au rămas în repo, ca originale.

### Arta e GRI; culoarea se pune în joc

```gdscript
const CULOARE_MEMORIE := Color(0.60, 0.85, 1.00)   # albastru
const CULOARE_LOGICA := Color(0.70, 1.00, 0.60)    # verde
const CULOARE_CUVINTE := Color(1.00, 0.85, 0.55)   # auriu
```

Nu sunt constante doar pentru iconiță: sunt aceleași valori pe care le foloseau
deja bordura, numele și halo-ul, scoase din tabel și botezate. „Aceeași nuanță
ca textul" nu mai e o potrivire de ținut minte — e literalmente același număr.

Colorarea e o linie în `obelisc.gd`: `imagine.modulate = culoare`. `modulate`
înmulțește fiecare pixel cu culoarea dată, deci pe o piesă gri griul deschis
devine albastru deschis și griul închis albastru închis — **volumul și umbrele
rămân**, se schimbă doar nuanța. Pe o imagine deja colorată ar fi ieșit noroi;
de-aia arta viitoare merită generată tot gri.

Fișierele de pe disc rămân neatinse, deci aceeași imagine poate servi mâine
altei discipline, cu altă culoare.

**Proporțiile:** pionul e la 80% din înălțimea nebunului, toate trei pe aceeași
linie de talpă. Raportul e copt în PNG (cât din pânza de 256px ocupă piesa), nu
e un număr în cod.

### Bugul: butonul blocat se albea în loc să se stingă

`ALFA_INDISPONIBIL` face TOT conținutul semi-transparent, fața inclusiv. Iar
sub față stătea halo-ul, un `Panel` al cărui trup avea culoarea disciplinei —
complet acoperit în mod normal, deci „nu contează ce culoare are". Contează
exact în clipa în care fața devine translucidă: prin ea se vedea albastrul
aprins de dedesubt, și butonul blocat ieșea mai luminos decât unul liber.

Reparat punând trupul aurei în culoarea **fondului**. Lecția: „e acoperit, deci
nu contează" ține doar cât timp nimic nu devine transparent.

### Textul „(blocat)" a dispărut

Ocupa un rând întreg sub nume și **muta tot ce era pe buton** de fiecare dată
când se aprindea sau se stingea. Lacătul din colț spune același lucru fără să
miște nimic. Lupta nici nu știe că există un lacăt: trimite două adevăruri prin
`seteaza_stare(blocat, indisponibil)`, iar cum arată fiecare decide butonul.

### Verificat

Rulare headless după fiecare pas (fără erori, fără avertismente) și capturi de
ecran pentru fiecare stare: repaus, hover, apăsat, blocat, și cu o întrebare
deschisă. Piesele desenate au fost judecate mărite la 300px, nu la 46 — la
mărimea de pe buton vezi doar *că* o formă e greșită, nu *de ce*.

### Ce rămâne deschis

- **Mărimea iconiței**: 46px acum, cu butonul de 86. La 60/100 piesele se citesc
  clar mai bine, dar iau 14px din înălțimea arenei. Nedecis.
- **Unealta de decupare** trăiește în afara repo-ului. Dacă mai apar piese (turn,
  rege, regină), merită pusă la `tools/decupeaza_piesa.py`, cu proporțiile
  într-un dicționar.
- **Sursele cântăresc 6,4 MB** din cei 6,7 ai artei și ajung și în export, deși
  jocul nu le folosește. Înainte de build-ul web: ori mutate în afara
  proiectului, ori excluse din Project → Export → Resources.
- Cât timp e o întrebare pe ecran, butoanele rămân **aprinse** sub panou, deși
  clickul pe ele nu face nimic (`_pe_obelisc_apasat` are gardă).
  `actualizeaza_ui()` se cheamă abia după ce se termină lanțul. Se repară cu o
  linie, dar aceeași linie face și bulina de PA să dispară la deschiderea
  întrebării, nu la final — o schimbare de feedback, nu doar de aspect.

### Fișiere atinse

```
scenes/lupta/obelisc.tscn      — nou: scena butonului
scenes/lupta/obelisc.gd        — nou: stări, animații, seteaza_stare()
scenes/lupta/fata_obelisc.gd   — nou: degrade + bordură + colțuri, în _draw()
scenes/lupta/glifa_sah.gd      — nou: pion / cal / nebun desenate
scenes/lupta/lacat.gd          — nou: semnul de blocat
scenes/lupta/lupta.gd          — CULOARE_*, tabelul OBELISCURI (piesă, culoare,
                                 imagine), configureaza() în _ready(),
                                 seteaza_stare() în actualizeaza_ui(),
                                 culori_obelisc șters
scenes/lupta/lupta.tscn        — cele 3 butoane devin instanțe ale scenei
assets/art/pion_sah.png, cal_sah.png, nebun_sah.png   — noi (gri, cu alfa)
assets/art/pawn.png, knight.png, bishop.png           — surse
```

---

## Sesiunea sunetului de critic (14 septembrie 2026) — treapta a 5-a se aude

**Ce s-a schimbat:** la fiecare treaptă multiplu de 5, un tunet
(`critical_thunder.ogg`) sună în același cadru în care fulgeră marcajul
portocaliu „CRITIC!". Până acum lovitura dublă se vedea doar în bara inamicului.

**Sincronizarea e gratuită:** apelul stă lipit de `puzzle.arata_combo()`, în
`ruleaza_lant()`. Sunetul și flash-ul pleacă din aceeași linie de cod, deci din
aceeași bătaie a jocului — n-ai ce potrivi cu mâna și nu se pot desincroniza.

**De ce în luptă și nu în disciplină:** „critic" e vocabular de luptă, exact ca
`TEXT_CRITIC`. Trivia și Logica primesc un String pe care îl aprind, fără să
afle ce înseamnă. Dacă sunetul ar porni de acolo, fiecare disciplină nouă ar
trebui să-și amintească să-l pună; așa, Anagramele îl au pe gratis.

**Volum propriu** (`VOLUM_CRITIC_DB`, -4 dB, adică +2 față de restul efectelor).
„Corect"/„greșit" sună la fiecare răspuns, tunetul o dată la cinci — iar un
sunet rar are voie să fie mai mare decât unul des. La același volum cu bipul,
criticul ar fi fost doar încă un răspuns corect, cu alt timbru.

Ca să nu fie nevoie de un al treilea difuzor cu nume (ca la ticăit și verdicte),
excepția stă într-un tabel mic, `VOLUM_EFECT`. Tunetul e „dă-i drumul și uită de
el", ca bipurile: îi trebuie alt volum, nu alt difuzor.

**Efect secundar de reținut:** `reda()` scrie acum volumul din tabel la fiecare
redare. Era deja obligatoriu, dar acum chiar contează — vocile se rotesc, iar un
„corect" nimerit pe difuzorul folosit de tunet ar fi moștenit volumul lui: un
bip mai tare o dată la trei, fără nicio cauză vizibilă.

### Fișiere atinse

```
autoload/sunet.gd                  — VOLUM_CRITIC_DB, Efect.CRITIC, VOLUM_EFECT,
                                     reda() ia volumul din tabel
scenes/lupta/lupta.gd              — un if în ruleaza_lant()
assets/audio/critical_thunder.ogg  — nou
```

---

## Sesiunea panoului de verdict (14 septembrie 2026) — înfrângerea are și ea un ecran

**Ce s-a schimbat:** înfrângerea nu mai se termină doar cu un sunet. Apare
același panou ca la victorie, cu „SAH MAT" în roșu, cât de aproape ai fost
(„Mai avea 12 / 30 PV") și un buton „Lupta din nou" care chiar repornește lupta.

### Bugul: butonul „Lupta din nou" nu făcea nimic după înfrângere

Nu era o problemă de semnal neconectat — era o **ordine greșită de verificări**.

`_pe_incheie_tura_apasat()` avea gardienii în ordinea asta: „e puzzle deschis?",
„se încheie deja tura?", „s-a terminat lupta?". Steagul `tura_se_incheie` se
ridică în pauza scurtă dintre ultima ta acțiune și atacul inamicului, și se
coboară în `incepe_runda()` — adică la începutul rundei URMĂTOARE.

La victorie asta nu se vede niciodată: inamicul cade în timpul lanțului tău, cu
steagul jos. La înfrângere, tu mori **chiar în tura inamicului**, care a pornit
din acea pauză — deci `termina_lupta(false)` se apelează cu steagul sus, iar
`incepe_runda()` nu mai vine niciodată să-l coboare. Butonul intra în al doilea
gardian și se întorcea în tăcere.

Două reparații, fiindcă erau două greșeli:
- `termina_lupta()` coboară acum steagul explicit — o luptă terminată nu are
  „tură în curs de încheiere".
- `lupta_terminata` se verifică ÎNAINTEA lui `tura_se_incheie`. E starea mai
  tare din cele două: ce era „în curs" într-o luptă încheiată nu mai are ce opri.

Lecția generală: când un buton „nu face nimic", caută întâi un `return` dintr-un
gardian, nu un semnal lipsă. Un `return` tăcut arată exact ca un buton mort.

### Un singur panou pentru amândouă finalurile

`PanouVictorie` s-a redenumit `PanouVerdict`; `_arata_verdictul(victorie: bool)`
îi schimbă titlul, culoarea titlului, textul și eticheta butonului.

De ce nu două panouri în scenă: victoria și înfrângerea au **aceeași formă** —
titlu mare, o frază despre ce s-a întâmplat, un buton. Diferă doar cuvintele.
Două copii ar însemna că orice schimbare de formă de mâine (o margine, un buton
„Abandonează expediția", o animație de intrare) se face de două ori — și a doua
oară se uită. Aceeași regulă ca la Obeliscuri: un contract, mai multe conținuturi.

Textul de înfrângere e oglinda celui de victorie, intenționat. A doua frază spune
cât de aproape ai fost: „mai avea 3 PV" e un motiv să reîncerci imediat, „mai
avea 28" e informația că trebuie schimbat ceva, nu repetat.

### Butonul de sub arenă a dispărut de tot

Era ascuns în timpul luptei și reapărea la final ca buton de repornire. Acum
repornirea e în panou, peste toată arena — iar butonul de jos rămânea vizibil
sub voal, pe jumătate estompat. Două butoane „Lupta din nou" pe același ecran nu
sunt două șanse, sunt o întrebare inutilă despre care e cel adevărat.

Nodul și `_pe_incheie_tura_apasat()` rămân în scenă (e în continuare drumul prin
care se încheie o tură din cod); doar `visible` e acum `false` permanent.

### Ce rămâne deschis din pasul 4

Recompensele după victorie. Panoul de verdict e locul lor evident — sub text,
deasupra butonului — dar n-are ce afișa până nu există economia celor 4 resurse.

---

## Sesiunea verdictelor finale (14 septembrie 2026) — lupta nu se mai termină în tăcere

**Ce s-a schimbat:** când lupta se încheie, se aude. Victoria are fanfară
(`victory.ogg`), înfrângerea are „Șah Mat"-ul ei (`defeat.ogg`). Amândouă pornesc
în același cadru în care se încheie lupta — la victorie, exact odată cu panoul.
Muzica de luptă se stinge sub ele și se întoarce când lupta repornește.

### Muzica se OPREȘTE, nu se atenuează — și de ce nu e același lucru

La întrebări muzica se dă doar mai încet (`Muzica.atenueaza()`): lupta continuă
sub panou, iar tăcerea ar suna a pană de curent. La final lupta NU mai continuă,
iar muzica de luptă e o promisiune că mai ai ceva de făcut — ținută sub fanfară,
ar contrazice fix mesajul verdictului.

În plus, cele două se bat pe același spațiu: fanfara de victorie e tot muzică,
cu tonalitate proprie. Două piese diferite în același timp nu sună a „mai multă
muzică", sună a greșeală.

Stingerea muzicii durează 2 s (`Muzica.DURATA_FADE`) și se suprapune peste
primele secunde ale verdictului. Nu e o scăpare, e chiar ce vrei: un încrucișat,
nu o tăietură.

### Al doilea difuzor cu nume în `Sunet`

Verdictele n-au intrat în rotația de 3 voci, din același motiv ca ticăitul:
trebuie să poată fi **oprite la comandă**. Concret — apeși „Continuă" la două
secunde de la fanfară, lupta repornește, iar fanfara ar mai cânta încă cinci
secunde peste muzica luptei noi. Pe o voce din rotație n-ai avea de ce s-o apuci.

Și n-au nevoie de rotație: nu poți câștiga și pierde în același timp.

Trei lucruri le sunt proprii:

- **Catalog și enum separate** (`Verdict`, `VERDICTE`), nu un rând în plus în
  `EFECTE`. Ambele enum-uri încep de la 0, deci `Efect.CORECT` și
  `Verdict.VICTORIE` sunt amândouă `0`; două cataloage separate sunt exact ce
  împiedică un „0" rătăcit să cânte altceva decât crezi.
- **Volum propriu** (`VOLUM_VERDICT_DB`, azi -8 dB). „Corect"/„greșit" sunt
  bipuri de câteva zecimi de secundă, normalizate tare ca să treacă peste
  muzică. Verdictele sunt bucăți de muzică: la același nivel de vârf se aud mult
  mai tare, fiindcă stau tare tot timpul, nu doar o clipă.
- **Stingere scurtă la oprire** (`FADE_VERDICT`, 0,4 s), spre deosebire de
  ticăit, care se taie din cuțit. Ticăitul e făcut din pocnete — oriunde l-ai
  tăia nu tai nimic. Verdictul e o notă ținută, iar o tăietură peste o coardă
  care încă sună se aude ca un clic în difuzor.

### `Sunet` tot nu știe nimic despre muzică

Ar fi fost tentant: „dacă tot cânt fanfara, opresc eu și muzica". Dar atunci
`Sunet` ar trebui să ghicească dacă muzica se oprește de tot sau doar se dă mai
încet — și n-are de unde ști ce e pe ecran. Lupta decide, în `termina_lupta()`,
exact ca la atenuarea de la întrebări. Cele două regizoare rămân surde una la
alta, ca fanfara să poată fi folosită mâine și pe hartă, fără să oprească muzica
hărții.

### Două locuri în `lupta.gd`, și de ce exact acolo

| Unde | Ce face |
|---|---|
| `termina_lupta()` | `Muzica.opreste()`, apoi verdictul potrivit. La victorie apelul stă lipit de `_arata_victoria()` — care e o funcție obișnuită, fără `await`, deci sunetul și panoul chiar apar în același cadru |
| `reseteaza_lupta()` | `Sunet.opreste_verdict()` + `Muzica.reda(LUPTA)`. Un singur loc pentru toate drumurile înapoi: „Continuă", „Luptă din nou", și resetul de test |

Amândouă apelurile din reset sunt sigure oricând: `opreste_verdict()` nu face
nimic dacă nu cânta nicio fanfară, iar `Muzica.reda()` nu repornește piesa dacă
ea cântă deja.

### Înfrângerea încă n-are panou

Sunetul de înfrângere pornește la `termina_lupta(false)`, unde e singurul lucru
care marchează momentul. Panoul de „Șah Mat" rămâne pasul 1 din lista de
construcție; când apare, apelul se mută lângă el, ca la victorie.

### Verificat

Rulare headless a unei lupte adevărate, nu doar a scriptului:

- victorie → verdictul cântă, panoul e vizibil, `Muzica.piesa_curenta == -1`;
- „Continuă" la 0,5 s → muzica de luptă a revenit (`piesa_curenta == 0`, cântă),
  fanfara e încă în stingere; după `FADE_VERDICT` s-a oprit singură;
- înfrângere → verdictul cântă, muzica s-a oprit;
- două `reseteaza_lupta()` la rând, fără nimic în difuzoare → fără erori.

Numărul de „ObjectDB instances leaked" la ieșire e identic cu cel dinainte de
sesiune (verificat prin `git stash`) — difuzorul nou nu adaugă scurgeri.

### Fișiere atinse

```
autoload/sunet.gd            — VOLUM_VERDICT_DB, FADE_VERDICT, VOLUM_TACERE_DB,
                               enum Verdict + VERDICTE, _verdict, _tween_verdict,
                               _pregateste_verdictele(), reda_verdict(),
                               opreste_verdict(), curățenie în _exit_tree
scenes/lupta/lupta.gd        — termina_lupta(), reseteaza_lupta()
assets/audio/victory.ogg     — nou
assets/audio/defeat.ogg      — nou
(+ .import pentru amândouă, generate de editor)
```

**De curățat:** în `assets/audio/` au rămas `defeat_GOOD.ogg` și
`defeat_short.ogg`, variante de probă pe care nu le folosește nimeni. Dacă
`defeat.ogg` e alegerea finală, șterge-le — altfel peste o lună n-o să mai știi
care e cea bună (numele `_GOOD` o să spună contrariul).

---

## Sesiunea ticăitului (14 septembrie 2026) — ultimele cinci secunde se aud

**Ce s-a schimbat:** cât timp mai ai sub 5 secunde la o întrebare, un ceas
ticăie sub tine. Pornește exact odată cu roșul barei, are ritm constant (nu
accelerează), și tace în clipa în care timpul se oprește — la răspuns, la timp
expirat, sau când se închide panoul.

**De ce ticăit și nu altceva.** Bara roșie e informație periferică: o vezi doar
dacă îți muți privirea de pe întrebare, adică fix când n-ai voie s-o muți.
Sunetul ajunge fără să ceară nimic de la ochi — poți citi ultima variantă și
să știi, în același timp, că mai ai trei secunde.

### Difuzor propriu în `Sunet`, nu o voce din rotație

`Sunet` avea 3 voci rotite în cerc pentru sunete de unică folosință. Ticăitul
n-a intrat în rotația aia: e singurul sunet din joc care trebuie **oprit la
comandă**, iar pe o voce rotativă a treia cerere de „corect" i-ar fi furat
difuzorul și s-ar fi oprit singur, din senin. Are deci `_ticait`, un
`AudioStreamPlayer` cu numele lui.

| Ce | Valoare | De ce |
|---|---|---|
| `VOLUM_TICAIT_DB` | **-16 dB** | Sub muzica normală (-12), dar ~5 dB peste muzica atenuată (-21) — adică sub prag în restul timpului, audibil fix când contează |
| Bucla | forțată pe `true` în cod | Importul pune `loop=false`. Fișierul are ~8 s, fereastra e de 5, deci azi nu se ajunge la capăt — dar dacă muți pragul la 10, ceasul n-are voie să amuțească la jumătate |
| `process_mode` | `PAUSABLE` | Singura excepție de la `ALWAYS`-ul nodului `Sunet`. Cronometrul întrebării e un `_process`, deci pe pauză se oprește; un ceas care ticăie peste timp înghețat e o minciună |

Volumul e **independent de atenuarea muzicii**: `Sunet` și `Muzica` sunt două
autoload-uri cu difuzoare separate, deci ducking-ul din
[sesiunea atenuării](#sesiunea-atenuării-13-septembrie-2026--muzica-se-dă-la-o-parte)
nu-l atinge. Dacă ticăitul iese prea agresiv sau prea timid, `VOLUM_TICAIT_DB`
e singurul număr de schimbat.

### Cine îl pornește și cine îl oprește

`Sunet` nu știe ce e o întrebare sau un prag. Puzzle-urile îl comandă, din
cronometrul lor — deci ticăitul e deja refolosibil pentru un nod de hartă cu
limită de timp, fără nicio linie nouă în `sunet.gd`.

| Loc (identic în `trivia.gd` și `logica.gd`) | Chemare | De ce acolo |
|---|---|---|
| `actualizeaza_cronometru()`, ramura `<= PRAG_URGENTA` | `porneste_ticait()` | **Același prag ca roșul barei**, deliberat: două canale, un singur eveniment. Cu praguri separate, ai muta unul și ai uita de celălalt |
| aceeași funcție, ramura `else` | `opreste_ticait()` | `porneste()` trece pe aici cu timpul plin, înainte de a reporni cronometrul — deci întrebarea următoare stinge din oficiu un ticăit rămas în aer |
| `_termina()`, lângă `set_process(false)` | `opreste_ticait()` | Sus, nu după pauza de suspans. Un singur loc acoperă și clickul, și timpul expirat (timeout-ul vine prin `_termina(false, -1)`) |
| `_exit_tree()` | `opreste_ticait()` | Plasa de siguranță pentru închiderea panoului, victorie, schimbare de scenă. Difuzorul trăiește în autoload, care NU moare cu scena — fără ea, un ticăit scăpat ar merge peste ecranul de victorie și mai departe |

**Cheia care face totul să funcționeze:** `porneste_ticait()` e **idempotentă**
— e chemată de ~60 de ori pe secundă și doar prima contează (gardă pe
`playing`). Fără ea, fiecare cadru ar reporni sunetul de la capăt și ai auzi un
bâzâit, nu un ceas. Alternativa — un flag „am pornit deja" ținut în fiecare
disciplină, resetat corect în `porneste()` — e exact genul de stare duplicată
care se strică la a treia disciplină. Aceeași lecție ca la `_atenuata` din
`Muzica`: garda stă lângă difuzor, nu la apelant.

**Verificat prin rulare automată,** în ambele discipline: pornire la 4,9 s,
oprire la trecerea înapoi peste prag, oprire la timeout, oprire la distrugerea
scenei fără răspuns, plus dubla chemare în ambele sensuri. Ce **nu** s-a
verificat: dacă ritmul fișierului se potrivește cu senzația de presiune. Asta
se aude doar jucând.

**Notă de import:** `clock_tick.ogg` intrase în repo fără `.import` — Godot îl
generează la prima deschidere a editorului. E generat acum și trebuie comis
împreună cu fișierul audio.

### Fișiere atinse

```
autoload/sunet.gd                  — VOLUM_TICAIT_DB, CALE_TICAIT, _ticait,
                                     _pregateste_ticaitul(), porneste_ticait(),
                                     opreste_ticait(), curățenie în _exit_tree
scenes/trivia/trivia.gd            — 3 chemări + _exit_tree nou
scenes/logica/logica.gd            — aceleași, cuvânt cu cuvânt
assets/audio/clock_tick.ogg.import — generat de editor
```

**Datorie tehnică, tot mai scumpă:** astea sunt încă „aceleași, cuvânt cu
cuvânt" în două fișiere. `puzzle.gd` (`class_name Puzzle`) era deja pasul 3 din
lista de construcție; acum regula de timp e în **patru** locuri identice, nu
două. De rezolvat înainte de a treia disciplină.

---

## Sesiunea de scalare (14 septembrie 2026) — de ce se vedea textul pixelat

**Simptomul:** textul arăta moale și zimțat, iar jocul se deschidea într-o
fereastră de 922×518 în loc de 1152×648.

**Cauza, măsurată nu ghicită:** am fotografiat aceeași scenă la trei
dimensiuni de fereastră și am mărit zona de text de 7 ori.

| Fereastră | Factor de scalare | Cum arată textul |
|---|---|---|
| 922×518 | 0,80 | cuvintele se lipesc, liniile literelor au grosimi inegale |
| 1152×648 | 1,00 | curat |
| 1920×1080 | 1,67 | curat |

Regula pe care o arată tabelul: **modul `canvas_items` redesenează literele
când mărește, dar le micșorează ca pe o poză când scade sub 1,0.** Un „A"
desenat la 14 pixeli și înghesuit în 11 pixeli nu mai are din ce să-și facă
liniile. Nu e o setare greșită — e limita fizică a micșorării.

De unde venea 922×518: din Godot 4.4 încoace, editorul **încorporează jocul
într-un panou** (`Game`), iar panoul îi impune dimensiunea lui. Ecranul e
1920×1080 la DPI 96, deci nu era vorba de scalare Windows.

### Ce s-a schimbat

- **`autoload/fereastra.gd`** (nou, al treilea autoload) — fixează
  `min_size` la exact dimensiunea pânzei, citită din setările proiectului.
  Fereastra reală nu mai poate coborî sub factorul 1,0. Are o plasă de
  siguranță: pe un ecran mai mic decât pânza, minimul coboară la cât încape,
  ca fereastra să rămână apucabilă.
- **`project.godot`** — pânza de desen scrisă explicit (1152×648, cât era
  implicit, ca să nu se schimbe nimic vizual), `scale_mode=fractional`,
  filtrarea implicită a texturilor pe `Linear Mipmap`, MSAA 2D pe 2×.
- **`assets/art/*.import`** — `mipmaps/generate=true`. Sursele sunt 379×658
  dar portretul din cardul inamicului se afișează la 96×167 (micșorare de 4×);
  fără mipmaps, placa video citea 1 pixel din 16. În Godot 4 filtrarea NU mai
  e o opțiune de import ca în Godot 3 — s-a mutat pe nod, cu implicitul luat
  din `rendering/textures/canvas_textures/default_texture_filter`.
- `detect_3d/compress_to=0` pe ambele imagini, ca Godot să nu le reimporte
  singur cu compresie VRAM (cu pierderi) dacă ajung vreodată lângă ceva 3D.

### Ce a rămas deschis

**Panoul `Game` din editor ignoră `min_size`.** Dacă textul arată prost când
apeși Play dar bine în jocul rulat separat, ăla e panoul. Se dezactivează din
Editor Settings → Run → Window Placement → **Game Embed Mode = Disabled**
(e o setare a editorului, globală pe toate proiectele, de-aia n-a fost
schimbată automat).

**Arta finală să fie comandată la 2× față de cât se afișează** (~800 px lățime
pentru figurile din arenă, nu 379). Azi, pe un monitor 4K, scalarea ajunge la
2,2× și imaginile sunt afișate peste rezoluția lor nativă.

---

## Sesiunea atenuării (13 septembrie 2026) — muzica se dă la o parte

**Ce s-a schimbat:** cât timp e o întrebare pe ecran, muzica de luptă coboară
cu 9 dB și urcă la loc când panoul se închide. Fade de 0,3 s în ambele sensuri.
Efectele sonore (`Sunet`) nu sunt atinse — verdictul „corect/greșit" se aude
chiar mai clar, fiindcă muzica i-a făcut loc.

Termenul din audio e **ducking**: fundalul se retrage când apare ceva mai
important. La radio, vocea peste melodie; aici, întrebarea peste luptă.

### Volumul, în două straturi

Asta e schimbarea reală din `muzica.gd`. Difuzorul nu mai e scris direct
nicăieri; volumul lui e mereu suma a două valori independente:

```
volume_db = _volum_baza + _atenuare_db
```

| Strat | Ce înseamnă | Cine trage de el | Cât durează |
|---|---|---|---|
| `_volum_baza` | „cât de tare e piesa asta" | `reda()`, `opreste()` | 2 s (`DURATA_FADE`) |
| `_atenuare_db` | „cu cât o dăm mai încet ACUM" | `atenueaza()`, `restabileste()` | 0,3 s (`DURATA_ATENUARE`) |

**De ce două valori și nu una.** Cu o singură proprietate animată, cele două
fade-uri s-ar fi bătut pe ea. Cazul concret: intri în luptă, muzica urcă lin
timp de 2 s, tu apeși un Obelisc la secunda 1 — atenuarea ar fi omorât
intrarea la mijloc, iar la închiderea panoului muzica ar fi SĂRIT la volum
plin, pentru că nimeni nu mai ținea minte că intrarea nu se terminase.
Separate, nu se văd una pe alta. Verificat: fade de 2 s cu atenuare pornită la
0,5 s ajunge la exact -21 dB, iar restabilirea îl duce înapoi la -12 dB.

Suma se recalculează prin **setere** (`var x: set(valoare): ...`) — cod care
rulează automat de fiecare dată când cineva scrie în variabilă, inclusiv un
Tween care scrie de ~60 de ori pe secundă. Fără `_process` și fără să ne
amintim noi. Tween-urile animă acum `self:_volum_baza`, nu `player:volume_db`.

### Trei locuri în `lupta.gd`, și de ce exact acolo

| Loc | Apel | De ce acolo |
|---|---|---|
| `deschide_panou()` | `Muzica.atenueaza()` | **Înainte de gardă**, intenționat: la o treaptă nouă din același lanț funcția iese imediat, dar muzica trebuie să rămână jos pe tot lanțul |
| `inchide_panou()` | `Muzica.restabileste()` | La ÎNCEPUTUL animației, nu la final: muzica (0,3 s) urcă odată cu retragerea panoului (0,55 s), o singură mișcare |
| `ascunde_panou_acum()` | `Muzica.restabileste()` | Plasa de siguranță — victoria și resetarea sar peste închiderea animată. Fără ea, un inamic ucis în mijlocul unui lanț lăsa muzica atenuată pentru tot restul partidei |

**Cheia pentru lanțuri: ambele funcții sunt idempotente.** `atenueaza()` cheamă
a doua oară nu mișcă nimic (flagul `_atenuata`). Fără asta, muzica ar fi urcat
și coborât între fiecare două trepte — exact zgomotul pe care atenuarea trebuia
să-l scoată. Verificat: a doua chemare dă o deviație de 0,0000 dB.

**Reglajele**, dacă vrei alt echilibru: `ATENUARE_DB` (azi -9.0) și
`DURATA_ATENUARE` (azi 0.3), amândouă sus în `autoload/muzica.gd`.

**Ce NU știe `Muzica`:** ce e un puzzle, un panou sau un lanț de combo. Primește
o comandă („mai încet acum") și atât — deci atenuarea e refolosibilă pentru o
cinematică din Cetate sau un eveniment de pe hartă, fără nicio linie nouă.

**De testat pe mână:** atenuarea a fost verificată prin rulare automată
(valorile în dB sunt exacte), dar dacă -9 dB e alegerea bună se simte doar
jucând. Intră într-o luptă, pornește un lanț lung și vezi dacă muzica se retrage
suficient cât să te lase să gândești, fără să pară că s-a stricat ceva.

---

## Sesiunea sunetului (13 septembrie 2026) — verdictul se aude

**Ce s-a schimbat:** răspunsul are acum și sunet, nu doar culoare. Două fișiere
(`correct_answer.ogg`, `incorrect_answer.ogg`), un regizor nou, și exact două
locuri din care se cheamă.

| Situație | Ce se aude | Când, exact |
|---|---|---|
| Răspuns corect | `correct_answer.ogg` | TIMPUL 3, în același cadru cu verdele |
| Răspuns greșit | `incorrect_answer.ogg` | TIMPUL 3, în același cadru cu roșul + verdele |
| Timp expirat | `incorrect_answer.ogg` | TIMPUL 1, în același cadru cu fulgerul barei |

### `Sunet` — al doilea autoload, frate cu `Muzica`

`autoload/sunet.gd`, înregistrat în `project.godot` sub `Sunet`. Aceeași formă
ca `Muzica`: enum + tabel de căi, `ResourceLoader.exists()` ca plasă de
siguranță, difuzoare construite din cod. Un efect nou = un rând în enum, un
rând în tabel.

**De ce un al doilea regizor și nu o metodă în `Muzica`.** Muzica e UNA, cântă
minute întregi și are nevoie de fade-uri; efectele sunt MULTE, durează sub o
secundă și trebuie să pornească instant. Dacă ar împărți un
`AudioStreamPlayer`, un „corect" ar tăia muzica de luptă în mijloc. Două
regizoare înseamnă și două volume reglabile separat — `Sunet.VOLUM_DB` e
azi -6 dB, deasupra celor -12 dB ai muzicii, fiindcă muzica e fundal și n-are
voie să fie observată, iar verdictul e informație și trebuie să treacă peste ea
fără efort. Astea sunt singurele două numere de reglat dacă mixul sună prost.

**Trei voci, nu una.** Un singur `AudioStreamPlayer` ține o singură voce: la al
doilea sunet îl taie pe primul. Azi n-ar deranja (între două verdicte trec
secunde), dar primul sunet de daune pus peste „corect" s-ar tăia cu el, iar
cauza s-ar căuta în fișierul .ogg, nu în cod. `VOCI := 3`, rotite în cerc —
rotația e oarbă, dar garantează că două cereri din același cadru nimeresc
difuzoare diferite. O căutare de „voce liberă" n-ar garanta asta: în același
cadru niciuna n-a apucat încă să raporteze că e ocupată.

**Încărcate o dată, la pornire**, nu la fiecare `reda()`. `load()` citește de
pe disc, iar o citire de pe disc în mijlocul unei lupte e exact mica sacadare
care ar strica sincronizarea cerută.

### Sincronizarea: nu e o potrivire, e o poziție în cod

Cerința era ca sunetul și flash-ul să se simtă un singur moment. Soluția n-are
niciun număr în ea: `Sunet.reda()` stă **în interiorul funcțiilor care
desenează**, nu lângă ele.

- `_aprinde_raspunsul()` — prima linie, deasupra tween-ului de culoare;
- `_fulgera_bara_expirata()` — prima linie, deasupra tween-ului barei.

Culoarea și sunetul pleacă din aceeași funcție, deci din aceeași bătaie a
jocului. Nu e nimic de potrivit cu mâna și, mai important, **nu se pot
desincroniza mai târziu**: dacă muți vreodată momentul verdictului, muți
funcția întreagă și sunetul vine cu ea. Un `await` sau un decalaj scris undeva
ar fi fost o valoare de ținut sincronizată manual — adică al șaselea punct de
contract din lista de datorie tehnică de mai jos.

**În `_fulgera_bara_expirata()` sunetul e DEASUPRA plasei de siguranță**
(`if stil_bara == null: return`). Bara poate rămâne fără fulger dacă tema dă
altfel de stil, dar timpul tot ți-a expirat și tot trebuie să afli — un
`return` pus înaintea sunetului ar fi legat tăcerea de o problemă de temă.

### De ce NU s-a agățat de semnalul `verdict`

Comentariul semnalului spunea, de trei sesiuni, că „de el se agață sunetul când
va exista". Era greșit, și codul din `_termina` explica deja de ce, în avans:
**un sunet care sună altfel la bine decât la rău ESTE un verdict.** Emis în
cadrul clickului, ar fi dat rezultatul cu ~0,6 s înaintea butoanelor și ar fi
golit de sens exact pauza de suspans construită în sesiunea de pe 11
septembrie. Regula rămâne cea scrisă atunci: nimic din ce se schimbă între
TIMPUL 1 și TIMPUL 3 n-are voie să depindă de `succes`.

`verdict` a rămas declarat, dar comentariul lui s-a corectat: de el se poate
agăța zguduirea ecranului sau un sunet NEUTRU de „am auzit clickul" — nu unul
care judecă.

### Timeout-ul: același sunet, alt moment

Timp expirat primește `incorrect_answer.ogg`, nu un al treilea fișier: e
același rezultat (ai pierdut treapta), iar un sunet propriu ar cere jucătorului
să învețe încă un cuvânt fără să-i spună nimic nou.

Momentul e însă altul — TIMPUL 1, nu 3. Motivul e cel din sesiunea trecută: la
timeout nu există suspans de păstrat, fiindcă n-ai pariat nimic, și de-aia
fulgerul barei era deja acolo. Sunetul cade peste el. Iar `_aprinde_raspunsul`
tace la timeout (`if ales >= 0`), altfel aceeași pierdere s-ar anunța de două
ori: verdele de la TIMPUL 3 doar ARATĂ răspunsul bun, nu mai judecă nimic.

### Verificat

Rulare fără ecran (Godot `--headless`), cu un mic script care instanțiază
scena, cheamă `_termina()` în cele trei situații și citește ce difuzoare cântă
în cadrul imediat următor, apoi după pauza de suspans:

| Caz | La click / expirare | După suspans (TIMPUL 3) |
|---|---|---|
| Trivia, corect | tăcere | `correct_answer.ogg` ✅ |
| Trivia, greșit | tăcere | `incorrect_answer.ogg` ✅ |
| Trivia, timeout | `incorrect_answer.ogg` ✅ | niciun sunet nou ✅ |
| Logica, corect | tăcere | `correct_answer.ogg` ✅ |
| Logica, timeout | `incorrect_answer.ogg` ✅ | niciun sunet nou ✅ |

Tăcerea de la click e la fel de importantă ca sunetul: e dovada că suspansul a
rămas întreg. Cele două .ogg s-au importat curat (`--import`), amândouă cu
`loop=false`, iar lupta pornește fără avertismente de la `Sunet`.

**NU a fost ascultat pe mână.** Rularea fără ecran dovedește CÂND pornește
fiecare sunet, nu cum sună: volumul relativ față de muzică și o eventuală
liniște la începutul fișierelor (care ar întârzia atacul și ar strica exact
senzația de „un singur moment") se aud doar jucând. Dacă atacul se simte
întârziat, cauza e în .ogg, nu în cod.

---

## Sesiunea fulgerului mutat (11 septembrie 2026) — semnalul pe variante

**Ce s-a schimbat:** panoul de întrebare nu mai tresare deloc. Semnalul de
verdict s-a mutat pe VARIANTELE de răspuns, și arată așa:

| Situație | Ce se întâmplă |
|---|---|
| Răspuns corect | varianta aleasă devine verde, instantaneu, și rămâne așa |
| Răspuns greșit | varianta aleasă devine roșie, cea corectă verde — în același cadru, amândouă rămân |
| Timp expirat | varianta corectă devine verde, iar ȘANȚUL barei de timp fulgeră roșu și se stinge |

**Butoanele nu au NICIO animație.** Culoarea se scrie într-un cadru și stă până
la întrebarea următoare. S-au încercat, pe rând, și rama de panou care tresărea,
și un puls pe butoane (aprindere 0,10 s → vârf → așezare 0,75 s) — amândouă
aveau aceeași hibă: o culoare care CREȘTE nu mai e reacția la clickul tău, e o
mică poveste care începe după el. Pe un ecran unde ai deja un cronometru care
curge și un lanț de ținut minte, orice animație în plus e încă un lucru care se
mișcă. În plus, butonul verde e o informație de CITIT (care era răspunsul bun,
mai ales când ai greșit), iar ce se citește trebuie să stea nemișcat.

**Singurul lucru animat rămâne bara, la timeout** — 0,10 s aprinderea, 0,20 s
în vârf, 0,75 s stingerea, pe TRANS_SINE + EASE_IN_OUT (duratele fostului
fulger de panou). Regula care separă cele două cazuri: butoanele ARATĂ ceva de
citit, deci stau; bara ANUNȚĂ un eveniment care a trecut, deci trece și ea.

**De ce s-a mutat de pe panou:** motivul de ieri, dus până la capăt. Am scos
cuvântul „CORECT" fiindcă în clipa răspunsului te uiți la butonul apăsat — dar
apoi am pus semnalul pe ramă, adică pe cea mai mare și mai periferică suprafață
din ecran. O suprafață mare care pulsează la marginea câmpului vizual nu se
citește ca răspuns la gestul tău, ci ca un al doilea eveniment, în altă parte.
Acum semnalul cade fix pe lucrul la care privirea era deja.

**Cazul care a cerut o soluție proprie — timeout-ul.** Dacă n-ai apăsat nimic,
niciun buton nu poate purta vina, iar verdele singur, apărut de nicăieri, arată
ca un răspuns bun dat de altcineva: lipsește exact informația „ai pierdut prin
timp". O dă bara — adică lucrul care s-a terminat.

**Bara are nevoie de altă tehnică decât butoanele.** La timeout bara e goală,
deci din ea se mai vede doar șanțul: în tema Godot, un gri aproape negru cu
alfa 0,3. `modulate` ÎNMULȚEȘTE, iar aproape negru înmulțit cu roșu rămâne
aproape negru. Deci culoarea trebuie PUSĂ peste, în stilul barei, nu înmulțită
— de aici `_pregateste_bara()`, care face o COPIE a `StyleBoxFlat`-ului din
temă (o resursă e partajată: animată direct, culoarea ar rămâne lipită de ea).
Alfa 1 la fulger e intenționat: în repaus șanțul abia se ghicește, la fulger e
o dungă plină, iar diferența asta e jumătate din semnal.

**Capcană bună de ținut minte, găsită pe drum** (chiar dacă pulsul de buton
care a dezgropat-o nu mai există): `Color * float` atinge toate cele PATRU
canale, alfa inclusiv. `CULOARE_BUN * 1.8` dădea o transparență de 1,8, care
n-are niciun sens.

### Unde stă fiecare bucată acum

| Bucată | Unde | De ce acolo |
|---|---|---|
| culorile puse pe butoane, în `_termina()` | `trivia.gd`, `logica.gd` | butoanele sunt ale disciplinei |
| `_fulgera_bara_expirata()` | `trivia.gd`, `logica.gd` | bara e tot a disciplinei |
| `_pregateste_bara()` | `trivia.gd`, `logica.gd`, din `_ready()` | copia stilului de bară |
| ~~`fulgera_verdict()`, `pregateste_stilul_panoului()`~~ | șterse din `lupta.gd` | regula: cine deține nodul, îl animează |

**`verdict(bun)` a rămas declarat, dar nu-l mai ascultă nimeni.** Reacția
vizuală s-a mutat în puzzle, deci lupta nu mai conectează nimic. L-am păstrat
fiindcă e singurul moment „chiar acum" pe care puzzle-ul îl poate oferi în
afară — de el se va agăța sunetul sau zguduirea figurii lovite. Dacă până
atunci nu se agață nimic, se șterge fără să atingi nimic altceva.

**Datoria din `puzzle.gd` a crescut din nou:** `_pregateste_bara()` și
`_fulgera_bara_expirata()` sunt identice în `trivia.gd` și `logica.gd`, plus
constantele lor. Baza comună (pasul 3 din CLAUDE.md) trebuie făcută înainte de
a treia disciplină — acum e și mai adevărat decât ieri.

### Verificat

Rulare fără ecran (Godot `--headless`), cu scena de Trivia instanțiată și cele
trei situații declanșate din cod; citite `modulate`-urile butoanelor și
`bg_color`-ul barei în cadrul imediat următor răspunsului, la 0,30 s și la 1,3 s:

- corect — varianta corectă e `(0.45, 1, 0.55)` din primul cadru și NEschimbată la toate trei citirile; bara neatinsă;
- greșit — corectă verde ȘI aleasă `(1, 0.4, 0.4)`, amândouă din primul cadru, amândouă neschimbate;
- timeout — butoanele la fel de nemișcate, iar șanțul barei trece prin `(0.75, 0.18, 0.18, 1)` și se întoarce la `(0.1, 0.1, 0.1, 0.3)`.

Ambele discipline compilează (`--check-only`), iar lupta pornește curat. **Nu a
fost jucat pe mână** — ritmul real se simte doar jucând. Pasul 2 din lista
rămasă e în continuare deschis.

---

## Sesiunea verdictului (11 septembrie 2026) — rama panoului în loc de cuvânt

> **Parțial depășită de sesiunea de mai sus.** Fulgerul de ramă descris aici nu
> mai există; a fost mutat pe variante. Ce rămâne valabil: dispariția
> cuvintelor „CORECT" / „INCORECT" și motivul ei, plus semnalul `verdict`.

**Ce s-a schimbat:** cuvintele „CORECT" / „INCORECT" / „TIMPUL A EXPIRAT" au
dispărut. În locul lor, TOT panoul de întrebare tresare o clipă: rama devine
verde la răspuns corect, roșie la greșit sau la timp expirat, și se stinge
înapoi în ~0,5 s. Evidențierea variantelor a rămas neatinsă — verde pe
răspunsul corect, roșu pe alegerea greșită.

**De ce:** în clipa în care apeși, privirea ta e pe butonul apăsat, nu pe un
rând de text de deasupra lui. Un cuvânt trebuie CITIT ca să însemne ceva; o
margine colorată se vede cu coada ochiului, exact acolo unde te uitai deja.
Bonus de așezare: eticheta ocupa un rând tot timpul întrebării (locul îi era
păstrat ca să nu sară textul), iar acum rândul ăla a intrat înapoi în întrebare.

### Un semnal nou în contract: `verdict(bun)`

Problema de sincronizare: panoul e al LUPTEI, nu al disciplinei — deci lupta
trebuie să aprindă rama. Dar singurul lucru pe care îl auzea de la puzzle era
`rezolvat(succes)`, care sosește abia după pauza de feedback (1,8 s). O ramă
care se aprinde la o secundă și jumătate după click nu mai e reacție la click,
e un al doilea eveniment.

Soluția: un al doilea semnal, `verdict(bun: bool)`, emis în `_termina()` în
același cadru în care se colorează butoanele. Același adevăr ca `rezolvat`, dar
în momentul potrivit pentru reacția vizuală; `rezolvat` rămâne cel care pune
lupta în mișcare (daune, lanț) și are voie să aștepte.

**Contractul a rămas la fel de neutru.** Puzzle-ul spune „bun" sau „greșit" —
nu știe că există o ramă, un panou sau o luptă (la F6 nici nu există). Lupta
decide cum arată asta. Când vine Anagrama, `fulgera_verdict()` merge deja:
singurul lucru cerut de la scena nouă e să emită `verdict` la răspuns.

Contractul disciplinelor are acum cinci capete: `porneste()`, `arata_stare()`,
`arata_combo()`, `verdict(bun)`, `rezolvat(succes)`.

### Unde stă fiecare bucată

| Bucată | Unde | De ce acolo |
|---|---|---|
| `signal verdict(bun)` + `verdict.emit()` | `trivia.gd`, `logica.gd` | doar disciplina știe CÂND s-a răspuns |
| `fulgera_verdict()` | `lupta.gd` | rama e a panoului, iar panoul e al luptei |
| `pregateste_stilul_panoului()` | `lupta.gd`, chemat din `_ready()` | face o COPIE a stilului |

**De ce copie (`duplicate()`):** o resursă în Godot e PARTAJATĂ. Dacă animam
direct `StyleBoxFlat`-ul salvat în scenă, culoarea ar fi rămas lipită de
resursă, iar a doua luptă ar fi pornit cu panoul deja colorat. Regula generală:
dacă animezi o resursă, animezi o copie a ei.

**Reglajele, toate în vârful lui `lupta.gd`:** `PAUZA_VERDICT` (0,12 s cât stă
aprins), `DURATA_REVENIRE_VERDICT` (0,38 s stingerea), `AMESTEC_FOND_VERDICT`
(0,12 — cât din culoare intră în fondul panoului). Aprinderea e instantanee,
fără tween: un semnal care apare treptat nu mai e o tresărire. Doar stingerea
e animată. Fondul e colorat puțin, intenționat — rama poartă semnalul, fondul doar
îl duce peste toată suprafața; peste ~0,2 textul întrebării ar începe să-și
piardă contrastul, iar el trebuie să rămână lizibil fiindcă răspunsul corect e
încă pe ecran și e de învățat din el.

### Ce a dispărut din cod

- nodul `%VerdictEticheta` din `trivia.tscn` și `logica.tscn`;
- `_scrie_verdict()`, `eticheta_verdict`, `tween_verdict`, `DURATA_VERDICT` din
  ambele discipline (~25 de linii duplicate, în minus — prima sesiune care
  SCADE datoria din `puzzle.gd`, nu o crește);
- `CULOARE_VERDICT_BUN/RAU` s-au redenumit `CULOARE_BUN/RAU` în discipline (nu
  mai colorează un verdict scris, ci butoanele) și au apărut, cu numele vechi,
  în `lupta.gd`, unde colorează rama. Aceleași valori — aceeași informație nu
  are voie să aibă două nuanțe.

### Verificat

Driver de rulare automată, șters după: capturi la 0,00 / 0,10 / 0,40 / 0,90 s
după un răspuns corect și după unul greșit. Rama e verde, respectiv roșie, în
cadrul imediat următor clickului, iar la 0,90 s panoul e înapoi la culorile de
repaus. Butoanele își păstrează evidențierea în tot acest timp (la răspunsul
greșit se văd simultan: rama roșie, varianta corectă verde, alegerea ta roșie).
Verificat pe Memorie (Trivia); codul de flash e comun, deci Logica primește
exact același comportament.

---

## Sesiunea de reparat panoul (10 septembrie 2026) — „flash-ul” de întrebări

**Simptomul:** la apăsarea unui Obelisc se vedea, o fracțiune de secundă,
alt text înainte să apară întrebarea finală.

### Ce am găsit (înainte de a repara)

Nu era o selecție repetată. Verificat cu un driver de rulare automată
(șters după), pe o sesiune de 20.000 de cadre și ~1.600 de apăsări:

- `porneste()` se cheamă exact o dată per întrebare deschisă;
- în `ZonaPuzzle` există tot timpul un singur copil (la trecerea între trepte
  cele două se suprapun pentru o instrucțiune, dar cel vechi e șters înainte
  de desenare — capturile cadru-cu-cadru nu arată nicio fantomă);
- textul unei întrebări nu se schimbă niciodată după ce a fost scris.

Era o problemă de AȘEZARE. `deschide_panou()` făcea panoul vizibil cu
`custom_minimum_size.x = 0` și îl creștea până la 500 px în 0,55 s — iar
întrebarea era înăuntru de la primul cadru. Panoul fiind container, textul se
reformata la fiecare lățime prin care trecea: un cuvânt pe rând (revărsat în
afara panoului), apoi trei rânduri, apoi două, apoi unul. Cinci așezări
diferite în ~80 ms. Fade-ul nu ascundea nimic: el se termină în 0,40 s,
mișcarea ține 0,55 s, deci ultimele reformări se vedeau la opacitate plină.

### Ce am schimbat

**Întâi se deschide panoul, apoi apare întrebarea.** `deschide_panou()` se
așteaptă acum (`await`), iar `ruleaza_lant()` creează puzzle-ul abia după.
Panoul crește gol, ca o cortină, și întrebarea apare direct la lățimea finală,
așezată corect din primul cadru. Între trepte nu se schimbă nimic:
`deschide_panou()` iese din prima linie când panoul e deja deschis.

Așteptarea stă pe un cronometru, nu pe `tween.finished`: un tween omorât (o
victorie, o resetare) nu-și mai emite semnalul, iar lupta ar rămâne blocată
într-un `await` pentru totdeauna.

**Bonus de corectitudine:** cronometrul întrebării pornește în `porneste()`.
Înainte curgea deja în timpul deschiderii — pierdeai o jumătate de secundă
dintr-o întrebare pe care încă nu o puteai citi.

### Un al doilea bug, găsit pe drum și reparat

Dacă apăsai un Obelisc în cele 0,55 s cât ține închiderea animată a panoului,
întrebarea nouă apărea și imediat se micsora până la dispariție — cu
cronometrul curând în gol în spatele unui panou invizibil.

Cauza: `deschide_panou()` întreba `zona_puzzle.visible`, dar `visible` rămâne
`true` pe toată durata închiderii (altfel figurile ar sări la loc instantaneu),
deci răspundea „da, e deschis” și ieșea din prima linie — lăsând închiderea
în curs să continue peste întrebarea abia creată.

Reparat cu o variabilă nouă, `panou_deschis`: ce VREM să facă panoul, separat
de ce face el chiar acum. Dacă prindem o închidere la mijloc, o omorâm și
creștem înapoi de la lățimea de acum, fără să sărim întâi la 0.

### Verificat

Driver de rulare automată, șters după:

| ce | rezultat |
|---|---|
| cadrele de la apăsare până la întrebare | panou gol care crește, apoi întrebarea la 500 px, o singură așezare |
| trecerea între trepte de lanț | curată, fără fantoma întrebării vechi |
| Obelisc apăsat în timpul închiderii | închiderea se anulează, panoul crește înapoi de la 481 px, întrebarea apare normal |
| 20.000 de cadre, ~1.600 de apăsări, 3 runde până la victorie | fără blocaje, fără schimbări rapide de conținut |

---

## Ce s-a făcut în această sesiune (10 septembrie 2026) — semnalul de critic

Lovitura critică (fiecare a 5-a treaptă, daune dublate) exista de câteva
sesiuni, dar nu se ANUNȚA. Vedeai doar bara inamicului scăzând mai mult și
trăgeai singur concluzia — dacă o trăgeai.

### 1. Portocaliul nu mai e o stare, e un fulger

Înainte, `critica` se trimitea la `porneste()`, adică la DESCHIDEREA
întrebării. Efectul: linia de context sta portocalie pe toată întrebarea a 5-a
și rămânea portocalie și după răspuns — practic două întrebări colorate pentru
un singur moment. Un accent care ține 15 secunde nu mai e un accent.

Acum linia e **aurie tot timpul**. Portocaliul apare doar ca vârf al pulsului
care se întâmplă oricum la fiecare răspuns corect, și doar la treptele multiplu
de 5: pulsul se așază în portocaliu în loc de auriu, stă până la 0,4 s, apoi
revine la auriu în 0,2 s. `porneste()` nu mai primește deloc culoare.

### 2. Marcajul „CRITIC!"

O etichetă nouă în rândul de context (`%MarcajEticheta`), care apare în 0,1 s,
stă până la 0,4 s și se stinge în 0,2 s — apoi iese din layout de tot
(`visible = false`), ca să nu ocupe lățime degeaba.

**Stă în STÂNGA cifrei de combo.** Rândul e aliniat la dreapta, deci un element
nou apărut în stânga crește spre golul din mijlocul antetului și nu împinge
„×5" din loc. Pus în dreapta, cifra ar fi sărit lateral exact în cadrul în care
vrei s-o citești.

**Ambele apar DUPĂ răspunsul corect**, prin `arata_combo()`, nu la deschiderea
întrebării — în același cadru în care bara inamicului scade dublu. Cauza și
efectul se văd împreună.

### 3. Contractul a rămas la fel de subțire

Disciplinele tot nu știu ce e o lovitură critică. Contractul e acum:

| | Înainte | Acum |
|---|---|---|
| `porneste()` | `(nivel, context, scurtare, accent)` | `(nivel, context, scurtare)` |
| `arata_combo()` | `(text, accent: bool)` | `(text, marcaj: String)` |

`accent` era un bool: „textul ăsta merită culoarea de alarmă" — o decizie de
STIL luată în luptă și executată orbește în puzzle. `marcaj` e un String gol
sau plin: lupta trimite *ce scrie*, puzzle-ul îl aprinde o clipă. Cuvântul
„CRITIC!" trăiește în `lupta.gd` (`const TEXT_CRITIC`), fiindcă e vocabular de
luptă. Aceeași logică ca la textul de combo, care se compune tot acolo.

Funcții noi în ambele discipline: `_arata_marcaj()` și `_ascunde_marcaj()`.
`_pulseaza_context()` primește acum un `critic := false`.

### Verificat

Driver de rulare automată, șters după (ambele discipline, aceleași cifre):

| moment | context | marcaj |
|---|---|---|
| la deschiderea întrebării | auriu (1.00, 0.83, 0.42) | ascuns |
| după un răspuns obișnuit | auriu | ascuns |
| critic, la 0,28 s | **portocaliu (1.00, 0.45, 0.20)** | **vizibil, alfa 1.00** |
| critic, la 0,60 s | auriu | ascuns, alfa 0.00 |
| întrebare nouă peste un marcaj încă viu | auriu | ascuns, text șters |

Ultimul rând contează: `_scrie_context()` cheamă `_ascunde_marcaj()`, deci un
„CRITIC!" nu poate supraviețui într-o întrebare nouă sau într-o serie ruptă.

---

## Sesiunea de citire a ecranului (10 septembrie 2026)

Trei schimbări mici, toate despre același lucru: **ce ai voie să te uiți în
timpul unei întrebări.** Panoul cerea atenție în trei locuri deodată — cifra
cronometrului, verdictul, figurile care se mișcau — iar întrebarea era doar
unul dintre ele.

### 1. Cronometrul numeric a fost scos

„9.7 s" se schimba de 60 de ori pe secundă la 30 de pixeli de întrebare, iar
ochiul se duce automat la ce se mișcă. Bara spune același lucru — cât a mai
rămas — dar o spune periferic, fără să-ți ceară s-o citești. Presiunea se
simte, nu se numără. Bara își păstrează tot ce avea: golirea, și roșul de sub
`PRAG_URGENTA`.

O linie ștearsă din `actualizeaza_cronometru()`, în ambele discipline.

### 2. Verdictul apare cu fade, și e colorat

Eticheta care ținea cifrele era ACEEAȘI care scrie „CORECT". Fiindcă nu mai
arată niciodată timpul, s-a redenumit — `%TimpEticheta` → `%VerdictEticheta`,
`eticheta_timp` → `eticheta_verdict`, în ambele `.tscn` și ambele `.gd`. Un
nod numit „TimpEticheta" care nu arată timpul e o capcană pentru mine peste
trei săptămâni.

| | Înainte | Acum |
|---|---|---|
| în timpul întrebării | „9.7 s", alb | gol (dar locul e păstrat) |
| corect | „CORECT", alb, instantaneu | **CORECT**, verde, fade 0.18 s |
| greșit | „GREȘIT", alb, instantaneu | **INCORECT**, roșu, fade 0.18 s |
| timp expirat | „TIMPUL A EXPIRAT", alb | roșu, fade 0.18 s |

**Culorile sunt exact cele ale butoanelor de răspuns** — verdele de pe varianta
corectă, roșul de pe cea greșită. Două nuanțe apropiate dar diferite ar fi
arătat ca două informații separate; identice, se citesc ca una.

**De ce fade și nu apariție seacă:** verdictul apare în același cadru în care se
colorează butonul. Două schimbări instantanee în același loc se citesc ca o
singură tresărire și nu știi la care să te uiți. 0.18 s le desparte cât să
înregistrezi întâi butonul, apoi cuvântul. Deliberat SCURT — peste ~0.25 s ar
începe să pară că jocul se gândește.

**„GREȘIT" a devenit „INCORECT".** Era în cererea ta, dar se leagă și cu „ton
sănătos" din `CLAUDE.md`: „incorect" descrie răspunsul, „greșit" te descrie pe
tine.

**Eticheta rămâne pe loc când e goală.** Un Label gol tot cere înălțimea unui
rând de text, deci locul verdictului e păstrat tot timpul întrebării. Fără
asta, întrebarea ar sări în jos cu ~26px exact când răspunzi.

### 3. Figurile stau nemișcate sub ecranul de victorie

Când inamicul cădea, `inchide_panou()` pornea oricum: figurile se lățeau spre
mijloc timp de 0,55 s în spatele voalului, ca și cum lupta ar continua.
Animația aia își are rostul între trepte, unde arată că arena se redeschide —
sub ecranul de victorie e o mișcare fără cauză.

Fix: la `pv_inamic == 0` se cheamă `ascunde_panou_acum()` (funcția care exista
deja, pentru resetare) ÎNAINTE de `termina_lupta(true)`. Panoul dispare într-un
cadru, figurile sunt la mărimea lor plină când apare voalul, și rămân acolo.
`inchide_panou()` din apelant se retrage singur — panoul e deja ascuns, iar el
iese din prima linie.

### Verificat

Driver de rulare automată, șters după: în timpul întrebării verdictul e gol și
bara plină; „CORECT" prins la alfa 0.29 în verde (0.45, 1.00, 0.55) și
„INCORECT" la alfa 0.27 în roșu (1.00, 0.40, 0.40); la victorie panoul de
puzzle e deja ascuns (`latime_min=0`), iar zonele figurilor măsoară 494px și tot
494px după 0,7 s — adică statice. Verificat pe ambele discipline.

---

## Sesiunea indicatorului de combo (10 septembrie 2026)

Indicatorul din antetul întrebării spunea o minciună mică: îl compunea
`_context_lant(treapta)`, deci arăta TREAPTA la care ești, nu câte răspunsuri
ai dat. La a doua întrebare scria „COMBO ×2" înainte să răspunzi la ea — adică
îți lăuda ceva ce încă n-ai făcut. Și, fiind trimis la `porneste()`, se putea
schimba doar între întrebări: nu vedeai niciodată cifra crescând.

**Cifra e acum numărul de răspunsuri corecte la rând, nu treapta.**
`lupta.gd` ține `combo_corecte`, un contor separat de `treapta`:

| Moment | `treapta` | `combo_corecte` | Ce scrie pe ecran |
|---|---|---|---|
| întrebarea 1 se deschide | 1 | 0 | *(nimic)* |
| ai răspuns corect | 1 | 1 | *(nimic — vezi pragul)* |
| întrebarea 2 se deschide | 2 | 1 | *(nimic)* |
| ai răspuns corect | 2 | 2 | **COMBO ×2**, cu flash |
| întrebarea 3 se deschide | 3 | 2 | COMBO ×2 |
| ai răspuns corect | 3 | 3 | **COMBO ×3**, cu flash |

Pragul e `COMBO_MINIM_AFISAT := 2`. Nu se afișează niciodată „×1": ar apărea la
fiecare întrebare și n-ar mai însemna nimic. Indicatorul apare abia când ai
ceva ce se poate PIERDE.

**Contractul disciplinelor a primit o metodă nouă: `arata_combo(text, accent)`.**
Asta e schimbarea care contează arhitectural. Până acum lupta putea vorbi cu
puzzle-ul o singură dată, la `porneste()` — deci orice se schimba în timpul
unei întrebări era imposibil de arătat. Acum lupta îl cheamă imediat după un
răspuns corect, cât întrebarea e ÎNCĂ pe ecran (în `PAUZA_IMPACT`), și vezi
cifra urcând peste răspunsul tău, lângă bara inamicului care scade.

Metoda respectă aceeași regulă ca restul contractului: primește un `String`
gata compus. Disciplina scrie linia și o face să pulseze — nu știe ce e un
combo, o treaptă sau un lanț. Compunerea rămâne în `lupta.gd`, în `_text_combo()`
(fostul `_context_lant()`).

**Flash-ul** (`_pulseaza_context()` în `trivia.gd` și `logica.gd`): eticheta se
aprinde alb și se umflă la ×1.45, apoi revine în 0.26 s, pe `TRANS_BACK` +
`EASE_OUT` — curba care trece puțin SUB mărimea normală înainte să se așeze, ca
să pară o bătaie, nu o topire. Pulsează la apariție și la fiecare creștere,
adică ori de câte ori cifra e alta.

Două detalii care nu se văd, dar fără ele arăta prost:

- **Pivotul e pe marginea din DREAPTA**, nu în centru. Eticheta e lipită de
  dreapta panoului (`alignment = END`), unde are 14px de margine. Umflată din
  centru ar fi ieșit din panou; umflată din dreapta crește spre interior, unde
  e loc gol.
- **Un cadru de așteptare înainte de puls.** Textul tocmai s-a schimbat, dar
  containerul reașază copiii abia la finalul cadrului — până atunci `size` (și
  cu ea mijlocul etichetei) e cea veche, iar pivotul ar cădea strâmb.

**Dispariția are DOUĂ locuri, dinadins.** `combo_corecte = 0` în `lupta.gd`
(la greșeală, la începutul unui lanț nou și când tura se încheie fără PA), dar
ștergerea VIZUALĂ se face în puzzle, în `_termina()`, la răspuns greșit sau
timp expirat. Fără asta, „COMBO ×5" ar fi rămas 1,8 secunde lângă butonul roșu:
lupta află de greșeală abia după `PAUZA_FEEDBACK`, prin semnalul `rezolvat`,
deci nu are cum să reacționeze mai devreme. Regula rămâne neutră — puzzle-ul
șterge o linie care a devenit falsă, fără să știe ce descria.

Cazul „se termină PA-ul" e, azi, imposibil de atins: sub COMBO un lanț se rupe
doar la greșeală (sau la moartea inamicului), deci contorul e deja 0 când ajungi
acolo. E scris oricum, fiindcă regula e „combo-ul nu supraviețuiește turei tale"
și vrem să scrie asta în cod, nu să depindă de un noroc de ordine.

**Verificat** printr-un driver de rulare automată: 5 trepte corecte urmate de o
greșeală. Eticheta stă ascunsă la răspunsul 1, apare la răspunsul 2 cu
`scale=1.39` și alb aproape pur, se așază la auriu, crește la ×3/×4/×5 cu puls
la fiecare, își păstrează portocaliul de accent la treapta critică 5 (și revine
în el după puls), și dispare complet în cadrul imediat următor greșelii. Driverul
a fost șters după verificare.

**Neîncercat pe mână.** Ca tot restul: cifra care crește peste răspunsul corect,
cu bara inamicului scăzând în același timp, poate fi exact motivația căutată sau
un al treilea lucru care se mișcă odată. Se vede jucând.

---

## Sesiunea de RITM (10 septembrie 2026)

Sesiune scurtă, de RITM. Nicio funcționalitate nouă — doar patru constante,
pentru că tot ce ține de tempo era deja scos în constante de sesiunea trecută.
Nu s-a atins nicio linie de logică.

**Fade-ul panoului de întrebare e mai lent** (`scenes/lupta/lupta.gd`):

| Constantă | Înainte | Acum | Ce controlează |
|---|---|---|---|
| `DURATA_PANOU` | 0.28 s | **0.55 s** | alunecarea panoului, care strânge figurile spre margini |
| `DURATA_FADE_PANOU` | 0.18 s | **0.40 s** | opacitatea conținutului din panou |

Le-am mărit pe amândouă în același raport (~×2), nu doar fade-ul. Regula e că
fade-ul trebuie să rămână puțin mai SCURT decât mișcarea: dacă textul devine
vizibil după ce panoul s-a oprit deja, ochiul citește „lag", nu tranziție.
Ambele valori se folosesc și la `deschide_panou()`, și la `inchide_panou()`, deci
apariția și dispariția rămân simetrice automat.

**Pauza dintre întrebări e mai mare.** Sunt de fapt DOUĂ pauze consecutive, și
contează să le ții minte separat — stau în fișiere diferite fiindcă aparțin unor
straturi diferite:

| Constantă | Unde | Înainte | Acum | Când se aplică |
|---|---|---|---|---|
| `PAUZA_FEEDBACK` | `trivia.gd`, `logica.gd` | 1.2 s | **1.8 s** | în puzzle: cât vezi butonul verde/roșu înainte de `rezolvat` |
| `PAUZA_IMPACT` | `lupta.gd` | 0.55 s | **0.95 s** | în luptă, doar la răspuns corect: cât stă lovitura pe ecran |

`PAUZA_FEEDBACK` e în puzzle pentru că e feedback de întrebare (corect, greșit
și timp expirat, deopotrivă). `PAUZA_IMPACT` e în luptă pentru că doar lupta știe
că s-au dat daune. Fiind duplicată în două discipline, `PAUZA_FEEDBACK` e încă
un argument pentru `puzzle.gd` (vezi datoria tehnică mai jos).

**Efectul cumulat:** între două trepte de lanț, la răspuns corect, ai acum ~2.75 s
de respiro în loc de ~1.75 s. La greșit rămân cele 1.8 s de feedback, apoi panoul
se închide lent. Niciuna din pauze nu-ți consumă timp de întrebare — cronometrul
e deja oprit în `_termina()`, prin `set_process(false)`.

**Atenție:** valorile astea sunt o presupunere, nu o măsurătoare. Nu au fost
simțite jucând. Dacă ritmul lanțului pare moale, primul număr de scăzut înapoi e
`PAUZA_IMPACT` (încearcă 0.75), nu `PAUZA_FEEDBACK` — feedback-ul de răspuns e
partea din care înveți ceva, impactul e doar spectacol.

---

## Sesiunea din 1 septembrie 2026

### Interfață

**Cardul de detalii al inamicului** nu mai ocupă tot ecranul. E un panou centrat
de 560px, cu fundalul luptei vizibil și întunecat în spate, colțuri rotunjite și
bordură subtilă. Se închide din buton sau cu click în afara panoului.
Înălțimea se potrivește pe conținut — nu mai există spațiu gol dedesubt.

**Panoul de întrebare a intrat în arenă.** Până acum puzzle-ul acoperea tot
ecranul și trebuia să-și deseneze propria bară de PV, ca să vezi inamicul
slăbind. Acum întrebarea apare într-un panou de 500px între cele două figuri;
barele reale de PV, punctele de PA și efectele de impact rămân vizibile
permanent. Figurile se strâng spre margini (de la ~500px la ~214px fiecare) și
se micșorează, fără nicio poziție calculată de noi: panoul e un copil al
aceluiași `HBoxContainer`, iar containerul reîmparte lățimea singur.

**Ecran de victorie.** Când inamicul ajunge la 0 PV apare un panou cu numele
celui învins, runda și PV-ul rămas, plus un buton „Continuă". Înainte lupta se
termina în tăcere: bara ajungea la zero și butonul își schimba textul, atât.

### Artă și animație

**Siluete desenate în cod** (`silueta.gd` + `silueta_rege.gd`,
`silueta_cavaler.gd`, `silueta_pagina.gd`) — forme geometrice, fără fișiere de
imagine. Inamicul a evoluat de la „Pagina Goală" (o filă ruptă) la **Cavalerul
Șters**, care se citește ca un adversar: armură, vizor cu doi ochi de chihlimbar,
sabie ridicată, poale destrămate și rânduri șterse pe piept.

**Imagini reale** (`assets/art/rege.png`, `cavaler_sters.png`) în `TextureRect`.
Ambele variante trăiesc în scenă; comutatorul e o constantă în `lupta.gd`:

```gdscript
const FOLOSESTE_IMAGINI := true   # false = siluetele desenate
```

**Respirația a fost scoasă** de pe imagini (arăta artificial pe artă realistă) și
înlocuită cu **efecte de impact** (`impact.gd`): fulger scurt + tremurat care se
stinge, declanșate la fiecare lovitură. Siluetele desenate își păstrează
respirația.

**Imaginile decupate strâns au cerut trei corecții de layout** (`lupta.tscn`),
după ce `rege.png` și `cavaler_sters.png` au fost înlocuite cu versiuni tăiate
pe personaj (379x658, deci înalte și înguste):

- `stretch_mode` era `KEEP_ASPECT_COVERED` — modul care UMPLE cutia și taie ce
  iese din ea. Pe o imagine îngustă într-o cutie lată, asta reteza capul și
  picioarele. Acum e `KEEP_ASPECT_CENTERED`: imaginea INTRĂ în cutie, centrată,
  cu proporția păstrată. Aceeași schimbare și la portretul din cardul de inamic,
  a cărui ramă a primit proporția imaginii (96x167 în loc de 96x112), ca să nu
  rămână goluri pe laturi.
- **Simetria** era ruptă de TEXT, nu de imagini. Într-un `HBoxContainer`, lățimea
  minimă a unui copil e cea mai mare lățime minimă a copiilor lui — iar butonul
  cu numele inamicului („CAVALERUL STERS — 30/30 PV") e mult mai lat decât
  eticheta „REGELE (tu)". Zona inamicului ieșea mai lată, deci și figura din ea.
  Fix: `clip_text = true` pe ambele (lățimea minimă cerută de text devine 0) plus
  `custom_minimum_size.x = 190` identic pe cele două zone. Acum sunt egale
  garantat, nu din întâmplare.
- **Panoul de întrebare** nu era pe axa punctelor de PA din exact același motiv:
  cu zone laterale inegale, centrul panoului nu putea cădea în centrul arenei.
  Odată zonele egale, panoul e centrat de la sine — nicio poziție calculată de
  noi. Verificat prin măsurare: centrul panoului = centrul rândului de PA = 576.

Efect secundar acceptat: numele inamicului avea nevoie de mai mult loc decât are
zona simetrică (236px cu panoul deschis). Fontul a scăzut de la 15 la 14 și PV-ul
se scrie „30/30" în loc de „30 / 30". Butonul are și `text_overrun_behavior`
ellipsis, ca plasă de siguranță pentru un nume viitor mai lung.

**Panoul de întrebare se deschide și se închide cu animație.** Trecerea
figuri-mari → figuri-mici era instantanee. Acum e un tween pe `EASE_OUT` + `TRANS_CUBIC`
(pleacă repede, se așază lin — liniar se citește ca o oprire bruscă), plus un
fade pe conținutul panoului. *(Duratele de atunci, 0.28s și 0.18s, au fost
încetinite pe 10 septembrie — vezi sesiunea de sus.)*

Ideea care ține tot: **nu animăm nicio figură.** Tragem de o singură valoare —
`ZonaPuzzle.custom_minimum_size.x`, de la 0 la `LATIME_PANOU` — iar
`HBoxContainer` reface împărțirea la fiecare cadru. Ce ia panoul, pierd
figurile, jumătate-jumătate. Mărimea ȘI poziția lor se animează singure,
simetric prin construcție.

Ca să meargă, panoul a trebuit să RENUNȚE la `size_flags_horizontal = 3` și la
`size_flags_stretch_ratio = 2.0`. Cu ele, containerul îi dădea deja 486 din 500
px pe baza raportului, indiferent de lățimea minimă — tween-ul trăgea de o
valoare pe care nimeni n-o citea, iar animația arăta ca un salt urmat de o
alunecare de 14px. Fără expand, panoul primește EXACT lățimea lui minimă, deci
exact ce spune tween-ul. Așezarea finală e identică (500 / 236 / 236).

**Panoul se deschide o dată per LANȚ, nu per întrebare.** Înainte
`creeaza_puzzle()` îl arăta și `inchide_puzzle()` îl ascundea — adică la fiecare
răspuns corect. Cu animație, asta ar fi însemnat figuri sărind mari-mici-mari la
fiecare treaptă. Acum deschiderea și închiderea stau exact acolo unde stă și
`puzzle_activ`, în `_pe_obelisc_apasat()`; între trepte se schimbă doar
conținutul panoului.

**Bug rezolvat: figurile erau tăiate când nu era nicio întrebare deschisă.**
Cauza nu era în scenă, ci în cod: `_incadreaza_figurile()` din `lupta.gd`
rescria `stretch_mode` la runtime — `KEEP_ASPECT_CENTERED` cu panoul deschis,
dar `KEEP_ASPECT_COVERED` (adică „umple și taie") când se închidea. Pe imaginile
noi, decupate strâns, asta reteza personajele de la brâu. Se vedea abia după
primul puzzle, fiindcă la pornirea scenei funcția nu apucase să ruleze — de
asta trecuse de verificarea de sesiunea trecută. Funcția a fost ștearsă:
încadrarea e acum una singură, `KEEP_ASPECT_CENTERED`, în ambele stări.

**Antetul puzzle-ului: categoria e centrată pe panou, nu pe ce rămâne din el.**
`Antet` era un `HBoxContainer` cu categoria (expand) lângă „COMBO ×3". Într-un
HBox, copilul care se întinde primește spațiul RĂMAS după frații lui, deci
„INTRUSUL" se centra pe un dreptunghi mutat spre stânga de lățimea streak-ului.
Acum `Antet` e un `Control` simplu cu două STRATURI suprapuse: eticheta de
categorie ancorată pe toată lățimea (centrată de la sine, orice ar scrie
alături) și un `HBoxContainer` cu `alignment = END` care ține streak-ul lipit
de dreapta. Bonus: fiind ancorate, etichetele nu mai impun nicio lățime minimă
panoului — de asta animația poate porni chiar de la zero.

### Date de inamic

Cardul are acum **Facțiune** (Cei Șterși, Ecourile) separat de **Arhetip** (Atac
constant, Grabnic). Facțiunea n-are efect mecanic — e cârligul pentru zone de
hartă și echipament anti-facțiune. Câmpul **Comportament** a fost rescris ca să
conțină cifre și condiții („3 daune, din runda 1. Fără încărcare, fără tură
sărită"), nu o reformulare a arhetipului.

### Obeliscul Logicii

Scenă independentă (`scenes/logica/`), cu **exact același contract ca Trivia**:
`porneste(nivel, context, scurtare, accent)`, `arata_stare()`, semnalul
`rezolvat(succes)`. Integrarea în luptă a fost o linie în tabelul `OBELISCURI` —
scena e acum o coloană în tabel, nu o constantă în cod.

**Cinci tipuri de puzzle, cu șanse egale.** Alegerea se face în două trepte:
întâi tipul, apoi un tipar din el. Fără asta, tipul cu cele mai multe tipare ar
fi câștigat proporțional — 9 șiruri numerice contra unui silogism însemnau
aproape numai șiruri.

| Tip | Tipare | Sursă |
|---|---|---|
| Șiruri numerice | 9 (pas constant, factor, pas negativ, crescător, alternant, dublat, mixt, Fibonacci, pătrate) | pur generativ |
| Intrusul | 2 (din alt domeniu / din același domeniu) | `logica_categorii.json` |
| Analogii | 3 (largă, strânsă, membru-la-categorie) | `logica_categorii.json` |
| Silogisme | 3 (Barbara, Celarent, Darii) | `logica_vocabular.json` |
| Deducții de ordonare | 3 (în ordine, amestecat, lung) | pur generativ |

**Verificat:** 1800 de întrebări generate (600 × 3 niveluri), distribuție
19–22% pe fiecare tip la fiecare nivel, **0 întrebări invalide** (fără duplicate
între variante, fără variante goale, fără întrebări fără răspuns corect).

### Date pentru Logică

- `data/logica_categorii.json` — **51 de categorii, 309 membri, 7 domenii**
  (natura, stiinta, geografie, arta, istorie, obiecte, abstract)
- `data/logica_vocabular.json` — 18 cuvinte cu toate formele gramaticale

Structura unei categorii:

```json
{ "domeniu": "natura", "nume": "feline", "relatie": "sunt feline",
  "membri": ["leu", "tigru", "ghepard", "ras", "jaguar", "puma"] }
```

**Câmpul `domeniu` nu era în cerință, dar fără el întrebările erau de decor.**
Prima rulare a produs „TOPAZ : DIAMANT :: CAL : ?" cu variantele *sfecla, Alpi,
caramiziu, pion* — nu trebuie să știi nimic ca să răspunzi. Acum analogiile și
intrusul își aleg toate categoriile din aceeași familie, deci distractorii sunt
înrudiți cu răspunsul.

**Reguli când adaugi categorii** (detaliat și în comentariul din `logica.gd`):

- minimum 4 membri per categorie
- minimum 2 categorii per domeniu, altfel domeniul nu e folosit niciodată
- **categoriile trebuie să fie disjuncte** — un membru în două categorii face
  „intrusul" să aibă două răspunsuri bune

Încărcătorul validează totul la pornire și te avertizează în consolă, fără să
crape lupta: raportează linia exactă la JSON invalid, sare peste intrările
stricate, semnalează membrii duplicați și domeniile prea sărace.

---

## Ce a rămas de făcut

### Imediat (următoarea sesiune)

1. **Ecran de înfrângere.** Victoria are panou, „Șah Mat" nu — se termină în
   aceeași tăcere de dinainte. E aceeași structură, o oră de lucru.
2. **Recompense după luptă.** Pasul 4 din rută nu e complet fără ele.
3. **Testat pe mână — acum e blocajul principal.** Tot ce e mai sus a fost
   verificat prin rulare automată și capturi de ecran, dar **n-am jucat efectiv o
   luptă întreagă**. Cronometrul, ritmul lanțului și dificultatea reală se simt
   doar jucând — iar după sesiunea de tempo din 10 septembrie sunt patru valori
   noi care n-au fost simțite de nimeni. Un ecran de înfrângere în plus nu
   valorează cât o luptă jucată cap-coadă.

### Datorie tehnică de rezolvat înainte de disciplina a treia

**`trivia.gd` și `logica.gd` au ~180 de linii identice** — cronometrul,
butoanele, feedback-ul, contractul, marcajul de streak cu tot cu puls și, de
azi, marcajul de critic (`arata_combo`, `_scrie_context`, `_pulseaza_context`,
`_arata_marcaj`, `_ascunde_marcaj` — vreo 100 de linii copiate cuvânt cu cuvânt
în ambele fișiere). Merge acum, dar la a patra disciplină o schimbare de regulă
de timp — sau de curbă de flash — trebuie făcută în patru locuri.

Sesiunea de la 10 septembrie e dovada: semnalul de critic a fost o schimbare
de UN concept, aplicată prin script în două fișiere deodată ca să nu diveargă.
A doua oară n-o să mai am noroc. Sesiunea verdictului (11 septembrie) a mai
tăiat ~25 de linii duplicate din fiecare fișier, dar și ea a trebuit aplicată
în două locuri deodată — inclusiv semnalul nou `verdict`, care e acum al
cincilea punct de contract de ținut sincron manual.

Sesiunea sunetului (13 septembrie) a adăugat un al șaselea punct de contract
duplicat: cele două chemări `Sunet.reda()` sunt copiate identic în ambele
fișiere. Sunt scurte, dar poziția lor în cod E regula de sincronizare — dacă
diverg, o disciplină o să sune la alt moment decât cealaltă, și n-o să se vadă
în niciun test.

Mutarea evidentă: un `puzzle.gd` cu `class_name Puzzle`, exact ca `Silueta` la
siluete. Baza ține cronometrul, contractul ȘI antetul (categorie + marcaj de
streak + puls); fiecare disciplină furnizează doar „dă-mi o întrebare" (text +
4 variante + indicele corect). Atunci Anagrama și Sudoku sunt câte ~40 de linii,
nu 250.

**`DATE_ARHETIP` amestecă două lucruri.** E indexat după arhetip, dar ține și
nume, descriere și facțiune — care sunt proprietăți ale *inamicului*, nu ale
*regulii lui de comportament*. Merge cât ai un inamic per arhetip. La pasul 11
(generatorul), va trebui un al doilea tabel de identități. Comentariul din cod
explică de ce câmpurile sunt deja separate: atunci va fi o mutare de chei, nu o
rescriere.

### De curățat când te decizi

- `silueta_pagina.gd` — nefolosit, dar nefiind încă comis în Git, ștergerea e
  definitivă. Pagina Goală rămâne un concept bun pentru alt inamic.
- Nodurile `...Silueta` și scripturile lor, dacă rămâi la imaginile reale.

### Lucruri mici, observate dar neatinse

- Panoul de întrebare e cu ~21px la stânga față de centrul ecranului, fiindcă
  eticheta lungă a inamicului („CAVALERUL STERS — 30 / 30 PV [i]") lățește zona
  din dreapta. Sub 2% din lățime, nu se vede decât dacă îl cauți.
- Cardul de inamic măsoară 638px într-un viewport de 648. Încă două rânduri în
  tabel și iese din ecran; atunci va avea nevoie de un `ScrollContainer`.
- Silogismele și deducțiile primesc același timp ca un șir numeric, deși cer
  citit mult mai mult. Dacă se simte grăbit, `TIMP_PE_NIVEL` e în vârful
  fișierului și e singurul loc de schimbat.

---

## Fișiere adăugate pe 13 septembrie 2026

```
assets/audio/correct_answer.ogg, incorrect_answer.ogg   (+ .import)
autoload/sunet.gd                  — regizorul de efecte (autoload `Sunet`)
project.godot                      — un rând nou în [autoload]
scenes/trivia/trivia.gd            — 2 chemări de sunet, 1 comentariu corectat
scenes/logica/logica.gd            — aceleași, cuvânt cu cuvânt
```

---

## Fișiere adăugate în sesiunea din 1 septembrie

```
assets/art/rege.png, cavaler_sters.png
data/logica_categorii.json, logica_vocabular.json
scenes/logica/logica.gd, logica.tscn
scenes/lupta/silueta.gd            — baza comună (class_name Silueta)
scenes/lupta/silueta_rege.gd
scenes/lupta/silueta_cavaler.gd
scenes/lupta/silueta_pagina.gd     — nefolosit
scenes/lupta/impact.gd             — fulger + tremurat la daune
docs/progres.md                    — acest fișier
```

**Nimic din toate astea nu e comis în Git.** `git status` arată `assets/`,
`autoload/`, `data/`, `scenes/logica/`, `scenes/trivia/` și fișierele noi din
`scenes/lupta/` ca neurmărite. Merită un commit înainte de sesiunea următoare —
inclusiv fișierele `.uid`, care trebuie să meargă împreună cu scripturile lor.

# MINDKEEP — Context de Development

_Citește acest fișier la fiecare conversație nouă de development._

**Design-ul complet e în `docs/pitch-document.md` (v1.5).** Nu se atașează — e în
repo; deschide-l când ai nevoie de detalii despre sisteme (formule, rarități,
arhetipuri de inamici, economie).

**Starea curentă a proiectului e în `docs/progres.md` — citește-l la începutul
fiecărei sesiuni.** Acolo scrie ce s-a făcut ultima dată, ce a rămas imediat de
făcut și ce datorie tehnică e deschisă. Fișierul ăsta ține deciziile și
principiile; `progres.md` ține starea.

---

## Ce sunt eu

Solo developer, la primul joc. Fără experiență anterioară de gamedev.
Godot 4 + GDScript. Fără C# (și pentru că nu poate ținti export web).
Jocul e, în primul rând, pentru mine: antrenament mental zilnic.
Sesiunea de bază e proiectată să funcționeze în ~15 min (o zi aglomerată să nu însemne „sar peste"), dar jocul nu trebuie să mă OPREASCĂ acolo — dacă mă captivează, vreau să pot juca și 1-2 ore fără să lovesc un zid artificial.

## Ce construiesc

**Mindkeep** — un joc de brain-training deghizat în RPG tactic gotic-medieval.
Rezolvi puzzle-uri sub presiunea timpului (Trivia, Sudoku, Anagrame, Logică);
răspunsurile corecte devin atacuri. Hub tip cetate + hartă de expediție tip Slay the Spire.

Detaliile complete sunt în **Mindkeep-Pitch-Document.md** — atașează-l alături de acesta.

---

## Unelte

**Godot 4.7.2:** `C:\Users\stefa\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`
(varianta cu consolă, pentru ieșire în terminal: `…_console.exe` din același dosar).

```bash
# importă resursele noi (după ce fabrica a adus fișiere în assets/)
"$GODOT" --headless --path . --import

# verificările, fără fereastră; ies cu cod 1 dacă pică ceva
"$GODOT" --headless --path . res://tools/verificari/verifica_trivia.tscn
```

**`tools/verificari/` e suita de teste a proiectului.** Fiecare e o scenă (nu un
`--script`): cu `--script` Godot nu pornește autoload-urile, iar jumătate din
fișiere nici nu se compilează fără `Sac` și `Muzica`.

| scenă | ce bate | verdicte | durată |
|---|---|---|---|
| `verifica_trivia` | întrebările, faptele, echilibrul pe domenii, sacul, pragul, rafturile din Practice, neștiutele întâi și distanța; plus **grila pe cele 93 de celule**, cu treapta fiecăreia și cât lipsește până la RAFT | 39 | ~20 s |
| `verifica_logica` | cele **14 tipuri** și cele 47 de tipare: tabelul (metoda există, `necesita` e cunoscut, antetul e al unui singur tip), fiecare tip la toate trei nivelurile, contractul pe fiecare tipar, **răspunsul recalculat din enunț** la mulțimi / cel mai rău caz / calendar, **enigmele rezolvate din nou** la mincinoși / locuri / potrivire, **enunțul care se ține singur** (nimeni și nimic nu apare nedeclarat), echilibrul pe tipuri și repetițiile | 58 | ~6 s |
| `verifica_numere` | cele **4 tipuri** și cele 11 tipare: tabelul (metoda există, antetul e al unui singur tip, **fiecare tipar are cine să-i refacă socoteala**), contractul, **răspunsul recalculat din enunț la TOATE unsprezece** (enunțul e o expresie, iar o expresie se evaluează), estimarea cu varianta corectă cea mai apropiată și singura, cântarul fără două valori egale, **caracterele în Cinzel, Alegreya și fontul implicit**, numerele care cresc de la un nivel la altul, echilibrul și repetițiile | 19 | ~1,5 s |
| `verifica_tipare` | cele **4 tipuri** și cele 18 tipare: tabelul (metoda există, antetul e al unui singur tip, **fiecare tipar are cine să-i refacă socoteala**, fiecare tipar cu mai multe niveluri are o măsură), fiecare tip la toate trei nivelurile, contractul, **regula dedusă din numerele de pe ecran la toate optsprezece** (generatorul construiește șirul din pas și creștere, verificarea află pasul și creșterea din enunț), **intrusul rezolvat din nou prin ENUMERARE** (jocul își apără unicitatea cu determinanți, verificarea cu mii de reguli încercate — două metode care trebuie să cadă de acord), șablonul care e chiar pe butoane, alfabetul declarat în fiecare enunț de litere, caracterele în toate trei fonturile, echilibrul și repetițiile | 33 | ~1,5 s |
| `verifica_spatial` | cele **4 tipuri** și cele 12 tipare: tabelul (metoda există, antetul e al unui singur tip, **fiecare tipar are cine să-l rezolve din nou**), fiecare tip la toate trei nivelurile, contractul, **răspunsul rezolvat din nou cu ALTĂ metodă la toate douăsprezece** (rotațiile prin matrice întoarsă cu `Array.reverse()`, nu cu socoteală pe indici; plierea prin PLIEREA cubului, nu prin regula benzii; busola din tabele scrise de mână), **PLANȘELE** (nicio celulă în afara marginilor sau dublă, nicio planșă peste 4×4, caroiaj cu litere distincte, un singur punct și pe o celulă plină, desfășurată de 6 fețe) ȘI faptul că **BUSOLA nu desenează nimic iar celelalte trei desenează mereu**, caracterele în toate trei fonturile (inclusiv literele din celule), echilibrul și repetițiile | 29 | ~25 s |
| `verifica_harta` | generatorul de hărți, pe sute de semințe | 28 | ~40 s |
| `verifica_plansa` | fiecare hartă desenată din `data/harti/` | 26 | ~30 s |
| `verifica_eveniment` | lacătul pe care-l dă harta, nu cel din F6 | 22 | ~30 s |
| `verifica_tipuri` | rețeta tipurilor de nod, pe multe semințe | 9 | ~60 s |
| `verifica_drumuri` | se poate înfunda o expediție? | 4 | ~15 s |
| `verifica_coltul` | nodul împins lângă Boss | **tipărește măsurători, nu verdicte** | ~2 min |
| `verifica_cifru` | generatorul de lacăte și dificultatea măsurată | `VERDICT` | **~10 min** |
| `verifica_salvarea` | drumul stare → disc → stare, câmp cu câmp; chei lipsă și în plus; fișiere stricate; versiunea; nodul nerezolvat | 54 | ~1 s |
| `verifica_retragerea` | ieșirile din expediție, cu scenele adevărate: luptă → „HARTA” → hartă (nodul te așteaptă, fără fugă) → aceeași luptă → „Meniu” | 27 | ~2 s |
| `verifica_duelul` | bucla de luptă, jucată cap-coadă cu scenele adevărate: lanțul plafonat, blocarea la activare, **parada** (ținta, daunele, unealta pierdută), liniștea rundelor de încărcare ale Grabnicului, lipsa cumulului și imposibilitatea blocării totale | 29 | ~25 s |

**Două scot altceva decât „OK”**, deci nu le căuta verdictele cu grep:
`verifica_coltul` tipărește un tabel de distanțe pe semințe (se citește, nu se
bifează), iar `verifica_cifru` încheie cu „VERDICT: cifrurile ies bine”.

`verifica_cifru` e cu mult cea mai lentă fiindcă rezolvă fiecare lacăt generat ca
un om: **596 de secunde**, măsurat pe 7 octombrie, cu cod de ieșire 0. Merge, doar
că nu la fiecare schimbare — se rulează când atingi generatorul de lacăte. Dacă
devine o piedică, ce se reglează e numărul de semințe din ea, nu existența ei.

Trei se judecă altfel și nu ies cu cod de eroare:

- `verifica_steaguri` — **F6 din editor**, toate steagurile într-o grilă. E
  singura verificare pe care un script n-o poate face: „arată bine?” nu e un
  verdict.
- `verifica_podeaua` — **cu fereastră**, nu `--headless`, fiindcă face capturi.
- `verifica_mostrele` — câte o întrebare de Logică din **fiecare** din cele 56
  de tipare, tipărite ca să le citesc. `verifica_logica` bate FORMA (patru
  variante, răspunsul recalculat, enigma rezolvată); aici se vede ACORDUL și
  dacă propoziția sună a românește. „Emil e calugarita” trece orice verificare
  automată și e totuși greșit. Se rulează când se atinge un generator sau când
  se adaugă un cuvânt în `data/logica_vocabular.json`.

Nu se șterge niciuna fără să dispară o verificare: toate bat sisteme care sunt
încă în joc, iar cele două care par lente sunt lente fiindcă rulează mii de
semințe.

**Build-ul web** (demo pe https://gyarados9.itch.io/mindkeep, Restricted, cu parolă):

```bash
python tools/exporta_web.py      # export + ../mindkeep_web.zip
```

Exportă cu presetul „Web” (`export_presets.cfg`, local, în `.gitignore`) în
`../mindkeep_web/`, verifică că JSON-urile au intrat în pachet și face zip-ul cu
`index.html` la rădăcină. Presetul poartă eticheta `alergologie` (Custom
Features), care aprinde Alergologia DOAR în build; scriptul oprește dacă
eticheta lipsește din preset sau din pachet. Exportul ia
proiectul de pe DISC, nu din Git. `../mindkeep_web/` e o ieșire: nu se
modifică de mână. Urcarea zip-ului pe itch.io rămâne manuală.

**Fabrica de întrebări** (Python, nu are nevoie de Godot):

```bash
python tools/fabrica/capitale.py             # probă uscată, nu scrie nimic
python tools/fabrica/capitale.py --masoara   # numai măsurători
python tools/fabrica/capitale.py --descarca  # aduce imaginile în assets/
python tools/fabrica/capitale.py --scrie     # scrie în data/trivia_gen/
python tools/fabrica/capitale.py --propune   # candidați de ales, în date/*_propuse.json
python tools/fabrica/capitale.py --reincarca # reia din rețea, rescrie cache-ul
```

**Nouă tabele, aceleași flaguri** (`comun.Argumente`, dinadins: un tabel nou nu
vine cu o convenție nouă de linie de comandă):

| script | relația | întrebări |
|---|---|---|
| `elemente.py` | element ↔ simbol chimic, **un singur sens pe element** | 69 |
| `opere.py` | operă ↔ autor (`P50`) | 160 |
| `capitale.py` | țară ↔ capitală (`P36`), plus steagurile | 251 |
| `compozitori.py` | lucrare muzicală ↔ compozitor (`P86`) | 147 |
| `filme.py` | film ↔ regizor (`P57`) | 203 |
| `albume.py` | album ↔ interpret (`P175`) | 156 |
| `fotbal.py` | Cupa Mondială, CM feminin, Euro: câștigătoarea și gazda; Cupa/Liga Campionilor: câștigătoarea (`P1346`, `P17`) | 143 |
| `olimpiade.py` | Jocurile Olimpice de VARĂ ↔ orașul-gazdă (`P276`, numai așezări) | 27 |
| `formula1.py` | sezon → campionul la piloți și la constructori, pilot → anul titlului (`P1346` + `P2094`) | 158 |

Ultimele cinci (27 octombrie 2026) au un **motor comun, `tools/fabrica/tabel.py`**:
distractorii cei mai apropiați, un singur răspuns bun, dublurile cu ce există
(`DUBLURI` scoase, `NU_SUNT_DUBLURI` păstrate, amândouă păzite ca la celelalte),
unicitatea în tot conținutul, notele prin validator, raportul și scrierea. Scriptul
unui tabel ține doar ce e al lui: interogarea, capcanele, textul și nota. La
`filme.py` și `albume.py` lista e scrisă de mână pe QID-uri, deci **după orice
schimbare în `date/filme.json` sau `date/albume.json` se rulează cu `--reincarca`**
(interogarea cere exact filmele din listă; motorul refuză un cache făcut cu alte
interogări).

`tools/fabrica/date/` ține **intrările** fabricii, scrise de mână: `elemente.json`,
`opere.json`, `tari.json`, `autori.json`, `compozitori.json`, `lucrari.json`,
`filme.json`, `albume.json`, `fotbal.json`, `olimpiade.json`, `formula1.json`. Ieșirile lui `--propune`
(`*_propuse.json`) sunt în `.gitignore`: nu le citește niciun script, se refac
dintr-o comandă, iar comise erau 118 KB care se schimbau la fiecare rulare.

**Notele fabricate, în schimb, AU o unealtă**, și nu e o contrazicere a paragrafului de mai jos: acolo e vorba de a CITI o notă scrisă de mână, aici de a opri un șablon care inventează. `comun.verifica_nota()` cere ca fiecare cifră și fiecare nume propriu dintr-o notă fabricată să existe în datele din care a fost compusă, și oprește `--scrie` dacă nu. Gramatica n-o apră nimeni — pentru ea se citesc mostrele tipărite la fiecare rulare.

**Verificarea întrebărilor nu are unelte, și e dinadins așa.** Fiecare întrebare
din `data/intrebari_trivia.json` are un câmp `verificat`, `true` sau `false`.
Întrebarea intră în joc **oricum** — flagul nu decide nimic în luptă, spune doar
dacă am citit nota ei. Când o citesc și o găsesc corectă, deschid JSON-ul și scriu
`true`. Niciun script, niciun parametru, niciun al doilea flag.

---

## Decizii deja luate — nu le redeschide fără motiv

Fiecare din astea a fost dezbătută și decisă conștient. Dacă propui altceva, spune de ce.

| Decizie                                  | Motiv                                                                                                                                                           |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Godot 4 + GDScript**                   | 2D nativ, curbă blândă, export web din același proiect                                                                                                          |
| **2D / 2.5D — NU 3D**                    | 3D = pipeline de producție separat (modelare, rigging, animații); cel mai comun mod în care mor proiectele solo                                                 |
| **8 discipline**                         | Cultură generală, Logică, Cuvinte, Numere, Reținere, Tipare, Spațial, Reflex. Fiecare cu rol tactic distinct. Codul tratează numărul ca variabilă, nu constantă |
| **Loadout: 3 din 8**                     | 56 de combinații. Numărul 3 e variabilă de reglat, nu presupunere                                                                                               |
| **Rolurile tactice > temele**            | Fără ele, 8 discipline se joacă identic. Multi-hit, crit, ignoră armura = decizii tactice                                                                       |
| **Două moduri de joc**                   | Campanie + Turnul Perseverenței (fără timp: Sudoku, probleme). Economie comună. Ce le despărțea era „cronometru strict” vs. „fără timp”; de pe 31 octombrie cronometrul e al inamicului, deci rândul ăla nu mai e adevărat pentru toată Campania                                                              |
| **Piesele de șah = skin, nu mecanică**   | Fără mișcare/capturare reală de șah — a doua curbă de învățare, fără beneficiu                                                                                  |
| **Regele = PV-ul jucătorului**           | PV = zero este condiția de înfrângere                                                                                                                           |
| **Regina — AMÂNATĂ**                     | Condiția de deblocare venea exact când nu vrei să rupi lanțul de combo. Se reevaluează după hartă + run complet                                                 |
| **Inamici generați, nu scriși de mână**  | ~10 arhetipuri × ~10 modificatori = sute de comportamente din zeci de reguli. Fără live-service, fără pattern-uri de memorat                                    |
| **Boșii rămân manuali**                  | 5-6 lupte scrise, ca momente memorabile                                                                                                                         |
| **Legendarele amplifică, nu dețin**      | O relicvă nu trebuie să fie singura sursă a unui sistem — altfel devine obligatorie și restul devin decor                                                       |
| **Loadout per expediție, nu per luptă**  | Evită un meniu înainte de fiecare inamic, păstrează lupta fluidă                                                                                                |
| **Toate disciplinele dau daune de bază** | Altfel una devine „cea inutilă"; diferă doar efectul secundar                                                                                                   |
| **Greșeală = pierzi 1 PA, NU tura**      | Pierderea turii pedepsește ignoranța în loc s-o corecteze                                                                                                       |
| **Desktop = „casa" progresului**         | Build-ul web e demo; save-urile nu se sincronizează automat                                                                                                     |
| **Save: două fișiere, nu unul**          | `permanent.json` (Tezaur, Antrenament, sacurile permanente) și `expeditie.json`, care EXISTĂ doar cât e un run viu. Cu un singur fișier, „șterge expediția" ar fi însemnat „rescrie fișierul care ține și Fragmentele" — iar „e un run în curs?" devine o întrebare despre existența unui fișier, nu un câmp dinăuntru care se poate contrazice |
| **Apelurile de salvare stau în SCENE**   | `Arhiva` adună dicționarele celorlalți și nu știe nicio regulă de joc; nimeni nu depinde de ea. Dacă salvarea ar fi în autoload-uri, `verifica_drumuri` (~20.000 de expediții jucate, adică sute de mii de intrări în noduri) ar bate discul și ar scrie peste save-ul adevărat |
| **Nodul se scrie pe disc la INTRARE**    | Înainte să se deschidă ce te așteaptă, nu la finalul nodului — altfel un lacăt ratat se reia cu codul deja văzut pe roți. Consecința: un nod poate fi „intrat dar nerezolvat", iar ce se întâmplă la reluare e coloana `reluabil` din `DATE_NOD` (Evenimentul NU se reia; lupta repornește de la zero) |
| **Un save mai nou NU se citește**        | Vechi se deschide chiar și strâmb (cheie lipsă = implicit, cheie necunoscută = ignorată). Mai nou se pune deoparte: cheile pe care nu le știu pot însemna altceva decât cred. Un fișier ilizibil se redenumește, nu se șterge, și faptul se spune în meniu |
| **Alergologia: secțiune doar pentru Practice, stinsă implicit** | 300 de întrebări (`data/alergologie.json`) pentru o rezidentă la alergologie, pe 6 rafturi, fără niveluri. Comutatorul `ALERGOLOGIE` din `trivia.gd` o aprinde DOAR în build-ul de pe itch.io: e `OS.has_feature("alergologie")`, iar eticheta o poartă presetul de export „Web”, nu codul. În editor și pe desktop e stinsă; `ALERGOLOGIE_LOCAL` o aprinde pentru un test și se pune înapoi pe false. Eticheta e a presetului, nu `"web"`, ca un build web public să nu o primească pe nesimțite. Nu intră în luptă: listă separată (`intrebari_doar_practice`), domeniu separat (`DOMENII_DOAR_PRACTICE`). Excepție conștientă de la „modelul de limbaj nu informează”: le-a scris Claude din memorie, le citește un medic. Vezi sesiunea ALERGOLOGIE |
| **Meniul de start e scena principală**   | Două moduri de joc înseamnă o răscruce, iar răscrucea trebuie să fie un ecran, nu un `run/main_scene` schimbat de mână. Meniul ÎNCARCĂ o scenă și nu știe nimic despre ea: harta își alege singură ecranul (loadout / hartă / sumar) din starea lui `Expeditie`, exact ca până acum — deci `harta.tscn` și `lupta.tscn` pornesc în continuare singure cu F6. Ieșire spre meniu de pe loadout, de pe sumar și, **de pe 26 octombrie 2026, de pe hartă**: fără Save ar fi fost o abandonare deghizată în pauză, cu Save e o pauză adevărată. O expediție vie nu se golește la ieșire, una moartă da. Vezi sesiunea IEȘIRILE DIN EXPEDIȚIE |
| **Cronometrul e al INAMICULUI, nu al jocului** | Bara de timp apare doar la inamicii care o declară în rândul lor (`cronometru: true`; azi doar Lăncierul, singurul Grabnic). Era o constantă de mediu — prezentă în fiecare luptă, deci tactic invizibilă în toate; acum e o INFORMAȚIE DESPRE ADVERSAR, pe care o citești pe card (rândul „Cronometru”) și pentru care îți alegi loadout-ul. Un CÂMP, nu `== Arhetip.GRABNIC`, din exact motivul scris la `are_ceas()`: un bos care te grăbește fără să încarce nicio lovitură e un rând în tabel, nu o ramură nouă. Scena de puzzle n-a fost atinsă: comutatorul `cu_cronometru` exista de la Practice. Plătit conștient: fără ceas, LANȚUL NELIMITAT nu mai are nimic împotriva lui la 2 din 3 inamici, iar a doua limită e nehotărâtă. Și NICIUN sac nu s-a atins — costul de timp e al rețetei care generează întrebarea, nu al întrebării: la Logică nu există listă de filtrat, iar la Trivia un filtru sub aceeași cheie ar fi șters memoria întregului domeniu (vezi `trivia.gd`). Decis pe 31 octombrie 2026, vezi sesiunea CRONOMETRUL E AL INAMICULUI |
| **Logica are PATRUSPREZECE tipuri de întrebare, nu cinci** | Cincisprezece de pe 1 noiembrie 2026, patrusprezece de la sfârșitul aceleiași zile: SIR (șirurile numerice, nouă tipare) a plecat la TIPARE, disciplina a cincea — vezi rândul de mai jos și pasul 2 din rută. Drumul e cel scris în pitch (secțiunea „de ce rămânem la 4 discipline"): „varietate ÎN interiorul celor 4 — formate multiple de Logică — costă mult mai puțin decât o disciplină complet nouă și rezolvă aceeași problemă”. Un tip nou e o funcție și un rând în `GENERATOARE`; o disciplină nouă e o scenă, un Obelisc, o statistică și o clădire. Cele zece noi, pe familii: **logică propozițională** (DACA-ATUNCI, NEGATIA, SI/SAU, PREMISA LIPSA — propoziții din vocabular, rezolvate din formă), **enigme** (ADEVAR SI MINCIUNA), **numărătoare** (MULTIMI, CEL MAI RAU CAZ, CALENDAR), **constrângeri** (LOCURILE, POTRIVIRE). Fiecare are cel puțin un tipar pe fiecare nivel — regula era deja scrisă, acum o bate și `verifica_logica`. Consecința de echilibru a fost, o zi, că SIR a scăzut de la 1/5 la 1/15 din întrebări — iar asta a fost chiar semnul că nu era al Logicii: un tip care nu cerea nici vocabular, nici categorii, și care se rărea cu fiecare tip nou. Nu s-a atins nici contractul `Puzzle`, nici o linie din `lupta.gd`. Vezi sesiunile CINCISPREZECE TIPURI și AL CINCILEA OBELISC |
| **Enunțul unei enigme își declară distribuția** | Primul rând spune cine joacă și cu ce: „Anton, Emil si Radu au, fiecare, alt lucru: arc, buzdugan sau topor.”, „Anton, Bran, Grigore si Luca stau pe locurile 1-4, de la stanga la dreapta.”. Nu e o înfrumusețare, e condiția ca întrebarea să aibă un singur răspuns PENTRU CITITOR: la LOCURI și la POTRIVIRE indiciile se trag la întâmplare, deci un ins poate lipsi din toate, iar fără lista lucrurilor „Luca nu are pumnal” nu duce nicăieri. La DEDUCTIE și la MINCINOSI nu trebuie — acolo forma enunțului îi aduce pe toți de la sine. Costă un rând de citit (ASEZARE a urcat la 6,1 rânduri, cel mai lung tip din joc) și îl bate o secțiune din `verifica_logica`, care se uită la TEXT, nu la enigmă. Vezi sesiunea CINCISPREZECE TIPURI, „Enunțul care nu se ținea singur” |
| **Trei tipuri CAUTĂ răspunsul, nu-l construiesc** | MINCINOSI, LOCURILE și POTRIVIRE trag indicii la întâmplare despre o situație ascunsă, apoi trec prin toate situațiile posibile (8 atribuiri, 24 sau 120 de permutări) și păstrează enigma doar dacă răspunsul iese ACELAȘI peste tot. Aceeași metodă ca la Lacăt: un puzzle nu se crede pe cuvânt, se rezolvă. Două urmări care nu erau în cod înainte: un generator are voie să dea GREȘ (întoarce `{}`, iar `_compune_intrebare` alege altă rețetă — de-aia are acum o buclă), și se cere doar ca RĂSPUNSUL să fie determinat, nu toată soluția. A doua e o decizie de citibilitate, nu de lene: unicitatea întreagă ar fi cerut cinci indicii acolo unde doi ajung |
| **`om` în vocabular, singurul câmp care cere sens** | MULȚIMILE și CERTITUDINEA povestesc ceva („în cetate sunt 12 cavaleri și 9 santinele"), iar o poveste cu stele amestecate printre cărți se citește ca o greșeală de generator, nu ca un nonsens util. Steagul e OPȚIONAL (lipsa = `false`), deci un cuvânt nou intră la silogisme fără să fi hotărât nimic despre el. Tot de acord e și `masculine`, dedus din `gen`: tiparele cu UN personaj („Luca e cronicar") trag numai masculine, fiindcă toate numele din `NUME` sunt masculine. Distincția care pare o inconsecvență: nonsensul de ÎNȚELES („Toate stelele sunt corabii") e bun, te împiedică să răspunzi din memorie; o greșeală de ACORD („Emil e calugarita") nu aduce nimic, doar te face să te întrebi dacă generatorul e stricat |
| **Al patrulea Obelisc e NUMERE, și e primul fără fișier de date** | De pe 1 noiembrie 2026. Ruta spunea Numere la pasul 3, deci alegerea n-a fost deschisă; ce s-a hotărât azi e CE ÎNSEAMNĂ. Patru tipuri, unsprezece tipare: CALCUL (lanț, înmulțire, **ordinea operațiilor**, împărțire), PROCENTE (procent din, cât la sută, reducere), ESTIMARE (ordin de mărime, suma rotunjită), CÂNTARUL (cea mai mare, echivalența — fracții, zecimale și procente amestecate). **Numerele nu sunt conținut, sunt intervale**: „47 + 38 − 19" nu se scrie, se generează, deci e singura disciplină la care dificultatea se reglează cu un număr și nu cu o săptămână de scris, și singura la care `_pregateste_datele()` rămâne gol. Costul plătit conștient: nicio întrebare nu poate fi CITITĂ înainte de joc, deci nici corectată — apărarea e că fiecare se poate RECALCULA, iar `verifica_numere` o face la toate unsprezece tiparele. Piesa e TURNUL (a patra din `glifa_sah.gd`), culoarea violet (roșul e luat de `Puzzle.CULOARE_RAU`). Contractul `Puzzle` neatins, nicio linie; `lupta.gd` neatins, nicio linie. Vezi sesiunea AL PATRULEA OBELISC |
| **Variantele greșite sunt GREȘELI, nu numere** | Regula care ține toată disciplina Numere. La Cuvinte capcana era forma (patru variante din clase gramaticale diferite se elimină fără să știi cuvântul); la numere forma nu ajută niciodată, dar MĂRIMEA da: la „14 × 6 = ?" variantele 84, 9, 311, 1250 nu cer înmulțirea, cer o privire. Deci fiecare tipar își declară propriile greșeli, în ordinea în care sunt tentante, iar cele mai bune sunt chiar cele pe care le-ai face: **ordinea inversă** („4 + 3 × 5" de la stânga la dreapta dă 35, iar tiparul există PENTRU varianta aia), **virgula mutată** la procente, **întrebarea greșită** la reducere (reducerea în loc de prețul nou — corect calculată și totuși greșită), **semnul întors** la lanț. ±1 și ±10 sunt umplutură, la coada listei. Excepția conștientă: **la ESTIMARE variantele sunt dinadins la zece ori una de alta** — acolo priceperea măsurată E mărimea, deci variante apropiate ar fi cerut calculul exact, adică alt tipar. Regula adevărată nu e „variante apropiate", e „variantele să ceară chiar ce întreabă enunțul" |
| **O verificare care copiază formula nu verifică formula** | Învățat pe loc, la `_reducere`: tiparul calcula `procent * pret / 100` cu împărțire de ÎNTREGI, deci „10% din 75" ieșea 7 în loc de 7,5, iar nota scria negru pe alb „10% din 75 e 7" — aritmetică greșită într-un joc de învățat. `verifica_numere` a spus OK, fiindcă refăcea socoteala **cu aceeași formulă**, deci obținea aceeași greșeală. Ce a prins-o a fost un verdict care NU se uita la răspuns: „numerele cresc de la un nivel la altul". Urmarea, acum regulă: o socoteală de verificare bate întâi **condiția pe care formula o presupune** (aici: că procentul iese întreg) și abia apoi rezultatul; iar invarianta se scrie și în joc, ca gardă care întoarce `{}`, nu doar în comentariu |
| **Al cincilea Obelisc e TIPARE, și e primul care PRIMEȘTE conținut de la altă disciplină** | De pe 1 noiembrie 2026. Celelalte patru au început de la zero; asta începe cu nouă tipare deja scrise, jucate și verificate — **șirurile numerice, mutate din Logică**. Mutarea e pasul 2 din rută, cerut de pitch de la început („altfel același conținut apare în două Obeliscuri"): cu Logica și Tipare în același loadout, „2, 6, 12, 20, ?" ar fi venit din două butoane, iar una din cele două discipline ar fi arătat ca un decor. Patru tipuri, 18 tipare: SIR (cele nouă mutate), LITERE (alfabetul ca șir), CICLUL (șablonul care se repetă, locul 23, două roți de lungimi prime între ele), INTRUS (care număr strică regula). **Singura disciplină la care dificultatea e deodată a REGULII și a NUMERELOR**: `GENERATOARE` are coloana „niveluri" ca la Logică (Fibonacci e greu cu orice numere) ȘI fiecare metodă primește `nivel` ca la Numere (pasul în alfabet 2 sau 5 sunt două dificultăți). Piesa e REGINA, culoarea roz. Contractul `Puzzle` neatins, `lupta.gd` neatins, `harta.gd` neatins — loadout-ul a devenit „3 din 5" (10 combinații) fără ca nimic să fie căutat prin cod. Vezi sesiunea AL CINCILEA OBELISC |
| **Piesele de șah sunt skin-ul primelor CINCI Obeliscuri, nu al tuturor** | Întrebarea era pusă de mult, scrisă lângă formele reginei: șahul are șase piese, regele e luat (el E PV-ul jucătorului), deci cinci au fost tot ce se putea împărți — iar a șasea disciplină n-avea de unde să-și ia una. Răspunsul, dat la Spațial (1 noiembrie 2026): rămân skin-ul primelor cinci, iar de la a șasea încolo glifa unei discipline e SIMBOLUL ei, cel propus de pitch de la bun început (clepsidră, spirală, busolă, fulger). Cele cinci existente nu se ating: o renumerotare ar fi însemnat cinci siluete noi și patru PNG-uri aruncate, pentru o disciplină în plus. Fișierul se cheamă în continuare `glifa_sah.gd`, iar cheia din catalog `piesa`: o redenumire ar atinge `obelisc.gd`, `discipline.gd` și catalogul, adică o zi de curățenie pentru un cuvânt. Ce contează e scris în antetul lui. **Faptul că problema fusese scrisă înainte să existe e tot motivul pentru care a costat o decizie și nu o zi** |
| **Un enunț care are nevoie de o convenție o DECLARĂ** | A doua aplicare a regulii scrise la enigme („Enunțul unei enigme își declară distribuția"), și dovada că nu era o regulă despre enigme. „A, C, E, G, ?" are DOUĂ răspunsuri: în alfabetul românesc (31 de litere) după A vin Ă și Â, deci pasul 2 de la A dă Â, nu C — iar un jucător care numără pe alfabetul învățat la școală are dreptate, nu greșește. Deci fiecare întrebare de litere începe cu rândul „In alfabetul A-Z:". Costă 18 semne de citit la fiecare întrebare și scoate ambiguitatea cu totul; alternativa (să presupun alfabetul latin) ar fi fost un joc de învățare care marchează roșu un răspuns corect. Bătut de `verifica_tipare`, altfel ar fi doar o intenție |
| **Al șaselea Obelisc e SPAȚIAL, și e primul care DESENEAZĂ** | De pe 1 noiembrie 2026. Patru tipuri, 12 tipare: GRILA (caroiaj cu litere — vecinul, coordonata, drumul), ROTATIA (o figură cu un punct: oglindire, jumătate de tură, sfert de tură, două mișcări una după alta), BUSOLA (întoarceri, încotro e cetatea, drumul întors), PLIEREA (desfășurata cubului). Celelalte cinci se puteau scrie cu un rând de text și patru butoane; asta nu, iar **matricea 3×3 căzuse deja din Tipare pentru exact motivul ăsta** („un tabel scris ca text nu se aliniază" — Cinzel și Alegreya nu sunt monospațiate). Piesa e BUSOLA, prima glifă care nu e de șah; culoarea e ARGINTIU, prima nesaturată, fiindcă nuanțele s-au terminat (singurul gol rămas era verde-albastrul respins la Tipare). `lupta.gd`, `harta.gd` și `expeditie.gd` neatinse, nicio linie; loadout-ul a devenit „3 din 6" (20 de combinații) fără ca nimic să fie căutat prin cod. Vezi sesiunea AL ȘASELEA OBELISC |
| **`puzzle.gd` primește un singur cârlig de desenare, și e OPȚIONAL** | `_plansa_pentru(q)` întoarce un `Control` sau `null`; baza îl pune între bara de timp și enunț și îl îngroapă la întrebarea următoare. Un NOD, nu o listă de forme — altfel `puzzle.gd` ar fi trebuit să știe ce e o celulă, un chenar și o literă într-o casetă, adică ramura pe care o interzice „o disciplină nouă e un rând în tabel". Se cheamă DUPĂ ce întrebarea a fost aleasă, nu în `_compune_intrebare`: `_compune_nerepetata` cere până la 12 întrebări și păstrează una, deci 11 noduri din 12 ar fi rămas orfane la fiecare apăsare de Obelisc. Așa, întrebarea poartă DATE (pe care și verificarea le citește, fără fereastră), iar nodul se naște o dată. Cele cinci discipline de dinainte nu simt nimic: cârligul întoarce `null`, cutia se ascunde, ecranul e identic pixel cu pixel — iar tipul BUSOLA există ca PROBĂ că e opțional, nu doar ca intenție scrisă în comentarii |
| **La Spațial răspunsul e o CELULĂ, nu o imagine** | Varianta firească (patru butoane cu patru figuri desenate) a căzut din trei motive, al treilea fiind cel care decide: patru planșe 4×4 pe patru butoane dau celule de 12 px; butoanele sunt ale TUTUROR disciplinelor, deci un buton care poate purta un desen e o schimbare plătită de toate pentru una; și, mai important, **întrebarea devine mai SLABĂ** — cu patru figuri în față elimini trei din formă, fără să rotești nimic. O coordonată cerută („linia 2, coloana 3") nu se poate ghici din formă. Prețul, plătit conștient: un rând în plus de citit, cel care declară cum se numără liniile — a treia aplicare a regulii „un enunț care are nevoie de o convenție o DECLARĂ", după distribuția enigmelor și alfabetul literelor |
| **Figura are mai multe celule decât punctul, și ele NU intră în socoteală** | La rotații răspunsul atârnă numai de celula punctului; celelalte celule pline nu schimbă nimic. N-ar fi fost mai curat fără ele — ar fi fost altă disciplină: cu un punct singur pe o grilă goală, rotația se face cu o formulă („linia devine coloană"), adică e aritmetică. Cu o figură în jur, rotești o IMAGINE și citești unde a ajuns punctul. Celulele în plus nu sunt decor, ele SUNT sarcina. **Și punctul se ALEGE dintre celulele figurii, nu se trage la sorți**: prima scriere trăgea la sorți și renunța la pozițiile simetrice, iar `verifica_spatial` a măsurat 68% eșec la oglindirea de nivel I — cu urmarea că BUSOLA apărea de două ori mai rar decât celelalte tipuri, fiindcă alegerea în două trepte trece la alt tip când toate tiparele celui ales dau greș. Un tipar care eșuează des nu risipește doar cicluri, STRÂMBĂ echilibrul |
| **Retragerea din luptă: PV-ul pierdut rămâne, inamicul o ia de la capăt** | Butonul „HARTA” din luptă, cu confirmare. Lupta tot nu se salvează, dar PV-ul regelui se predă expediției la retragere — altfel butonul ar fi o reîncercare gratuită a oricărei lupte care merge prost. Nodul rămâne NEREZOLVAT: harta nu te lasă pe alt nod (`_optiuni()` în `harta.gd`) și îl redeschide la clic pe piesă, nu singură. Decis pe 26 octombrie 2026 |


### Bucla de luptă

| Decizie                                                            | Motiv                                                                                                                                                                                                                                                                                              |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Combo: o activare = un lanț nelimitat de întrebări**             | Plătești 1 PA o singură dată, apoi treptele se CÂȘTIGĂ, nu se cumpără. Lanțul nu se mai termină de la sine — se rupe doar când greșești sau expiră cronometrul                                                                                                                                     |
| **Daune pe treaptă: 1 / 2 / 3, apoi 3 fix de la treapta 4 în sus** | Cresc scurt, apoi se așează la valoarea treptei III. Fără plafon, treapta 12 ar decide singură lupta. Răsplata pentru un lanț lung vine din LUNGIME (multe trepte × 3) și din critice, nu din inflația unei singure trepte                                                                         |
| **Critic la fiecare a 5-a treaptă (5, 10, 15…)**                   | Daunele treptei se dublează (deci 6 în loc de 3). E un obiectiv intermediar vizibil: la treapta 4 știi deja că următoarea valorează dublu, deci ai un motiv concret să mai riști o întrebare                                                                                                       |
| **Daunele acumulate rămân când lanțul se rupe**                    | Greșeala oprește creșterea, nu șterge munca. Altfel un lanț lung ar fi prea riscant ca să merite pornit                                                                                                                                                                                            |
| **Greșeală = Obeliscul rămâne blocat până la finalul rundei**      | Înlocuiește vechea regulă „pierzi 1 PA". Cu lanțuri nelimitate, un PA nu mai e o pedeapsă reală; pierderea unei unelte pentru restul rundei te obligă să reorganizezi tura, nu doar să reîncerci imediat. Pedeapsa rămâne pe unealtă, nu pe tură — nu pierzi runda pentru că n-ai știut un răspuns |
| **Tura se încheie automat când nu mai ai Obeliscuri utilizabile**  | Fără PA, sau cu tot ce ai blocat, butonul „Încheie tura" e un click ceremonial. Jocul nu trebuie să-mi ceară să confirm că n-am ce face                                                                                                                                                            |
| **Facțiuni de inamic, separate de arhetip**                        | Facțiunea (Cei Șterși, Ecourile) e apartenența tematică: zero efect mecanic azi, dar e cârligul pentru zone de hartă și pentru echipament anti-facțiune. Arhetipul rămâne strict regula de comportament — două câmpuri, două scopuri                                                               |

### Cultura generală: conținut și Practice

Decise pe 27 septembrie 2026, cu domeniile retăiate pe 6 octombrie 2026. Contextul complet e în sesiunile CONȚINUTUL, DOMENIILE și PLANUL ȘI CIORNELE din `progres.md`; definițiile domeniilor și regulile pentru note, în `docs/ghid-note.md`; **ce conținut lipsește, de unde se ia și în ce ordine, în `docs/plan-continut.md`** (acolo stau și subcategoriile, cu capcanele fiecărui tabel propus).

| Decizie | Motiv |
|---|---|
| **Întrebările se fabrică offline, nu în joc** | Un script Python scrie `intrebari_trivia.json`; jocul trage în continuare dintr-o listă finită. Păstrează garanția sacului, fiecare întrebare poate fi citită și corectată, jocul nu cere internet |
| **Surse: Wikidata pentru volum, mâna pentru restul** | Wikidata e CC0, deci se poate folosi liber, inclusiv comercial. Cultura românească și întrebările cu personalitate se scriu de mână. Frazele din Wikipedia nu se copiază (CC BY-SA) |
| **Modelul de limbaj formulează, nu informează** | Primește fapte verificate și scrie din ele; nu e niciodată sursa unui fapt. O rată de 2% greșeli la 5000 de întrebări înseamnă 100 de fapte false predate de un joc de învățare |
| **Nota aparține faptului, nu întrebării** | Un fapt dă mai multe întrebări și o singură notă: mai puțină muncă, nicio contradicție. Nota intră în câmpul `explicatie` din contractul `puzzle.gd` |
| **Notele fabricate se compun din ȘABLOANE, nu se scriu** | Un fapt `wd:` își primește nota dintr-un șablon al scriptului, din coloanele tabelului lui (numărul atomic, anul apariției, descrierea țării de la Wikidata). Trei motive: rămâne adevărată regula de deasupra (sursa e tabelul, nu memoria mea); `comun.verifica_nota()` poate CERE ca fiecare cifră și fiecare nume propriu din notă să existe în datele sursă, și oprește `--scrie` dacă nu; și un șablon greșit se vede în toate notele tabelului deodată, nu într-una. Un șablon NU poate apăra gramatica — acordul și punctuația se citesc cu ochiul, din mostrele tipărite la fiecare rulare. Vezi sesiunea NOTELE SE FABRICĆ |
| **Întrebările fără sursă rămân fără notă** | Cele 2046 scrise de mână n-au niciun tabel în spate, deci o notă pentru ele ar avea ca sursă modelul de limbaj — vreo 5000 de afirmații, din care 1% greșite sunt 50 de fapte false predate de un joc de învățare. Decis pe 12 octombrie 2026, cu cifrele pe masă: **nu**. Drumul spre ele e mai multe TABELE în fabrică (fiecare aduce întrebări ȘI note în aceeași rulare), nu mai multă memorie de-a mea. **Și aritmetica drumului, măsurată în aceeași zi, ca să nu se redeschidă din senin:** fiecare tabel adaugă întrebări cu notă, dar crește și numitorul, iar cele 2046 rămân în el pentru totdeauna — un tabel duce acoperirea de la 24% la ~28%, cinci-șapte tabele la ~50%, iar 90% ar cere +17 800 de întrebări fabricate. „Fiecare întrebare” are deci două drumuri, și amândouă sunt decizii nedeschise: note scrise de mână pentru cele 2046, sau înlocuirea lor treptată cu conținut fabricat. **Legarea retroactivă a întrebărilor de mână la faptele care au deja note a fost probată și a căzut**: potrivirea pe nume dă „romanul” → România și „Africa” → Africa de Sud, iar potrivirile corecte dau non-răspunsuri (pentru o întrebare despre Napoleon, nota Franței spune că Parisul e capitala). Vezi sesiunea AL PATRULEA TABEL |
| **Fiecare întrebare are un `id` stabil** | Textul se schimbă la reformulare, iar sacul, save-ul și istoricul din Practice au nevoie de o identitate care nu se mișcă. Se face înainte de Save |
| **Ținte pe celulă (domeniu × nivel), inegale** | 500 unde domeniul le poartă; 150–250 de fapte la nivelul I acolo unde domeniul nu le duce. Nivelul I e plafonat de propria definiție („o știe orice adult”), iar de la paliere de 3 trepte e și nivelul CEL MAI TRAS în luptă (~49% din întrebări) — tensiunea e scrisă la „Rămas deschis” din `progres.md`, nehotărâtă |
| **Se numără faptele, nu doar întrebările** | Cel mult 2–3 întrebări pe fapt. 500 de întrebări construite din 100 de fapte se simt ca 100 |
| **O singură `categorie` pe întrebare, `etichete` pe fapt** | Categoria ține echilibrul din luptă și antetul de pe ecran. Filtrele transversale (ex. „romania”) vin din etichete, fără să înmulțească domeniile |
| **`subcategorie`: al doilea raft, tot pe întrebare, tot exact una** | În Practice vreau să pot alege „geografie → capitale”. Un meniu care alege are nevoie de cifre corecte și de garanția că nicio întrebare nu rămâne pe dinafară, adică de o ÎMPĂRȚIRE, nu de etichete care se suprapun. Se alege după aceeași regulă ca domeniul — ce trebuie să ȘTII, nu subiectul. Lista e închisă pe domeniu, cheie → nume afișat, ca `DOMENII`, și e completă de la bun început (36 de chei, 4 folosite): o subcategorie scrisă de la început e un rând, una adăugată după ce s-a scris conținut e o migrare. `etichete` rămâne doar pentru transversale |
| **La istorie, subcategoriile sunt ERELE, tăiate pe dată** | antichitate până la 476 · Ev Mediu 476–1500 · modern 1500–1914 · contemporan de la 1914. **Data decide, nu numele**: dinastia Yuan (1271) e `ev_mediu` deși „Evul Mediu” e o noțiune europeană. Subcategoria e un RAFT, nu o afirmație despre civilizația aia — altfel fiecare întrebare despre Asia ar cere o decizie de la mine, și raftul ar fi o părere. Prețul, scris: granița de la 1500 taie prin Evul Mediu românesc |
| **Un singur flag, pe întrebare, care nu ține nimic afară din joc** | `verificat: true/false` în `intrebari_trivia.json`, pus de mână. Întrebările intră în joc neverificate, fiindcă o întrebare necitită e tot o întrebare bună în 95% din cazuri, iar una ținută afară nu se joacă niciodată. A fost, o zi, altfel: un câmp `ciorna` ținea întrebarea afară până o confirmam cu un script, faptul avea propriul `verificat` cu `surse` și o listă de afirmații de bifat, iar două unelte cu parametri le citeau și le semnau. Mai multă mașinărie decât conținut — și munca de verificare n-a devenit mai ușoară, doar mai ceremonioasă. Verificarea e o citire, nu un flux de lucru |
| **Ținta pe celulă are trei trepte: 8 · 25 · plin** | PRAG 8 = celula intră în luptă. CONFORT 25 = 4-5 expediții lungi fără nicio repetiție în ea. PLIN = ținta din CONȚINUTUL (150–250 la nivelul I, 500 la II și III). Cele 500 nu-mi spun niciodată „celula asta e gata pentru azi”; orice celulă sub 500 arăta identic în grilă. Treapta care lipsește peste tot e CONFORT, și se atinge într-o săptămână de scris |
| **În luptă: întâi domeniul, apoi întrebarea** | Conținutul generat nu iese echilibrat (Wikidata e bogată în geografie și știință). Alegerea în două trepte ține echilibrul oricum ar arăta baza, ca la Logică |
| **OPT domenii, tăiate după cum se joacă, nu după cum a crescut baza** | Geografie și explorare · Istorie și societate · Știință și tehnologie · Artă și literatură · Divertisment și media · Sport și jocuri · Gastronomie și lifestyle · Diverse și curiozități. Șase, de pe 6 octombrie 2026; opt, de pe 8 octombrie, când Gastronomia a ieșit de sub Sport (nu se întreabă deloc la fel) și a apărut un raft pentru ce nu încape nicăieri — lingvistică, logică ca FAPT, curiozități. Fiecare domeniu are 3-4 subcategorii, deci 31 de rafturi de filtrat în Practice. Cheile `stiinta_natura` și `sport_timp_liber` au fost redenumite atunci, în singura zi în care se putea: domeniul nu intră în `id`-uri, iar Save-ul nu se scrie încă. Regula care a ținut la toate trei tăierile: un domeniu declarat devreme e un rând, iar unul adăugat după ce s-a scris conținut e o migrare — de-aia `diverse` există de azi, gol, în loc să apară peste trei luni |
| **Un domeniu intră în luptă doar peste un prag de 8 întrebări pe nivel** | Pragul se măsoară pe CELULĂ (domeniu × nivel), fiindcă un domeniu poate fi gros la nivelul I și gol la III. Socoteala: o expediție lungă trage ~45 de întrebări de Cultură generală, din care ~49% la nivelul I (paliere de 3 trepte), adică ~22; împărțite la cele 4 domenii care trec pragul, 5-6 pe celulă. Sacul nu repetă până se golește, deci la 8 nu se repetă nimic într-o expediție, la 4 se repetă o dată. 8 e și o celulă scrisă de mână (baza de 135 s-a construit 7-8 pe celulă) și cifra la care nu pierd nimic din ce am: istoria are exact 8 și trece la limită — ceea ce o numește drept următoarea țintă de conținut, în loc s-o ascundă. Sub prag domeniul e SĂRIT, nu golit, și reintră singur când celula se umple. Dacă niciunul nu trece, se joacă cu toate: o întrebare repetată e mai bună decât ecranul de eroare în mijlocul unui lanț |
| **Domeniul îl dă ce trebuie să ȘTII, nu subiectul** | „Unde se află Turnul Eiffel?” e geografie; „Cine l-a proiectat?” e artă și literatură. Fără regula asta, un subiect bogat (Egiptul, Leonardo, Dunărea) trage spre el întrebări din trei domenii, iar echilibrul din luptă devine o părere |
| **La Divertisment și Sport, numai trecut, cu data spusă** | Fără „actual”, fără „în prezent”; la celebrități, doar cariera publică. Un record sau un deținător de titlu se schimbă fără să se schimbe nimic în fișierul meu, deci o întrebare scrisă cu „actual” devine într-un an un fapt fals predat de un joc de învățare — aceeași greșeală ca la modelul de limbaj, venită din trecerea timpului, nu din halucinație. Cariera publică și nu viața privată ține și de „Ton sănătos” |
| **Practice: alegi domeniul și, dacă vrei, raftul — niciodată nivelul** | Domeniul și subcategoria sunt o LUPĂ peste conținut: în luptă alege jocul, uniform și peste `PRAG_DOMENIU`, fiindcă acolo un domeniu sărac ar lua 1/N din toată lupta; în Practice alegi tu, deci acolo NU există prag — un prag ar fi însemnat „nu ai voie să exersezi raftul care tocmai a apărut”. Primul buton e „Tot domeniul”, singurul care cuprinde și întrebările fără raft. Nivelul, în schimb, nu se alege: urcă singur, pe DOMENIU (nu pe raft — altfel ar fi 31 de progrese și un nivel care sare după ce raft ai deschis), la `PRAG_PRACTICE` = 60 de răspunsuri corecte la întrebări distincte. Cheia sacului cuprinde filtrul (`practice:<domeniu>:<raft sau tot>:<nivel>`), fiindcă `Sac.extrage` golește registrul unei chei când lista primită se epuizează |
| **Rafturile goale apar, dezactivate** | Un raft ascuns e un raft despre care nu afli niciodată nimic — nu știi dacă nu există, dacă l-ai pierdut sau dacă n-am scris încă nimic în el. Unul stins, cu „gol la nivelul II” pe el, e o hartă a conținutului care lipsește: aceeași decizie ca la `PRAG_DOMENIU`, unde domeniile subțiri sunt SĂRITE, nu scoase din date. „Gol” se judecă LA NIVELUL TĂU, nu pe trei niveluri. De pe 21 octombrie 2026 butoanele active nu mai poartă cifra întrebărilor (era zgomot): domeniile au o iconiță și nivelul tău, rafturile doar numele. Vezi sesiunea ICONIȚE PE DOMENII |
| **Nivelul următor se deblochează la un prag fix, nu la „toate corecte”** | „Toate” e un zid la final și crește odată cu conținutul. Pragul fix (de pornire: 60 de răspunsuri corecte la întrebări distincte) nu crește. După prag, nivelurile se amestecă |
| **Greșitele revin; „învățat” cere 2–3 răspunsuri corecte la distanță în timp** | Un singur răspuns corect poate fi ghicit (o șansă din patru). Întrebările învățate ies din joc și intră în Jurnal |
| **„Află mai multe” poate arăta și o imagine, câmp opțional ca nota** | Unde e Bolivia sau cum arată un monument se înțelege dintr-o privire, nu din 240 de caractere. Unde imaginea lipsește, popup-ul rămâne cum era |
| **Două feluri de imagini: desenate din date sau reale, cu licență** | Hărțile le desenează jocul din contururi în domeniul public (Natural Earth), în stilul lui: faptul ține doar ce se desenează (ex. codul țării), fără licențe și aproape fără greutate — la fel, axe ale timpului pentru datele istorice. Imaginile reale (tablouri, portrete, monumente) vin din Wikimedia Commons prin Wikidata, cu autor și licență salvate și creditul afișat în joc; fabrica refuză orice imagine fără licență clară, iar arta modernă protejată nu intră |
| **Mici (~400 px) și doar unde adaugă ceva** | Greutatea contează la exportul web: câteva mii de fapte cu câte o poză ar cântări mai mult decât tot restul jocului. Se implementează la pasul 13 |
| **Criteriul de intrare e o chestiune de fapt, nu o judecată** | Pentru țări: stat membru ONU (`P463`), nu clasa „stat suveran". „Suveran" e o judecată contestată, deci ar fi cerut o decizie de la mine pentru Kosovo, Taiwan, Palestina, Abhazia. Apartenența la ONU e verificabilă și nu e a mea, iar statele cu recunoaștere parțială ies de la sine. Prețul: Vaticanul, observator, nu intră |
| **Un răspuns disputat nu se prezintă ca fapt simplu** | Israelul e exclus de mână din tabelul capitalelor: capitala lui e contestată internațional. Un joc de învățare n-are voie să pună un răspuns disputat pe un singur buton verde. Excluderea stă scrisă, cu motivul, lângă `DUBLURI`, și OPREȘTE scriptul dacă rândul reapare — altfel ar fi o părere într-un comentariu |
| **Imaginile unui fapt sunt o LISTĂ, nu un câmp pe fel** | `imagini: [{tip, …}]`. Un câmp `steag` ar fi cerut un al doilea câmp la tablouri și un al treilea la portrete; cu o listă, popup-ul are o singură buclă, iar un fel nou de imagine e un caz în plus în desenator, nu o schimbare în datele deja scrise. De-aia și harta a intrat în listă, iar `cod_iso` a ieșit din vârful faptului: altfel Practice ar fi întrebat două lucruri diferite. Intrarea cu `fisier` cere licență; cea desenată n-are voie s-o aibă |
| **Lista albă de licențe, nu listă neagră** | O listă neagră apără doar împotriva a ce mi-am imaginat deja; prima licență la care nu m-am gândit trece în tăcere. Se acceptă `pd*`, `cc0`, `cc-by*`; orice altceva OPREȘTE. Un fișier pe care decid totuși să nu-l iau se declară scris, cu motivul — și declarația se verifică singură: dacă licența devine una recunoscută, scriptul oprește și cere ștergerea ei |
| **Rangul preferat din Wikidata poate alege, dacă măsurătoarea o cere** | La steaguri, 21 din 126 de țări aveau mai multe declarații „actuale", iar rangul preferat le-a decis pe toate 21, fără nicio ambiguitate. 21 de rânduri scrise de mână n-ar fi fost o listă citită. Rangul nu e o euristică inventată de mine, e o afirmație explicită a editorilor — dar alegerea rămâne cinstită doar cu trei lucruri: oprește când rangul NU decide, tipărește toate cele 21 la fiecare rulare (cu ce a lăsat pe dinafară), și există o scenă în care le văd cu ochiul |
| **Un câmp lipsă în Wikidata nu e un „NU"** | „Fără dată de sfârșit" înseamnă „nu scrie nicăieri că s-a terminat", nu „nu s-a terminat". Așa au intrat 10 state istorice printre cele 193 membre ONU. Orice filtru pe absența unui câmp are nevoie de un al doilea semn, iar cele două se compară înainte să fie crezute |

## Principii pe care vreau să le aperi

- **Scope-ul mic e o funcționalitate, nu o limitare.** Dacă o idee de-a mea umflă scope-ul, spune-mi direct.
- **Prototip întâi, artă după.** Placeholder-e până când bucla de luptă e validată ca distractivă.
- **Contract identic între discipline.** Fiecare Obelisc e o scenă independentă cu aceeași interfață către luptă (`porneste()`, `arata_stare()`, semnalul `rezolvat(succes)`). O disciplină nouă trebuie să fie un rând în tabel, nu o ramură nouă în cod.
- **Proiectează pentru 8, construiește 4.** Disciplinele sunt o listă în date, nu un enum fix. A 5-a trebuie să fie un update de conținut, nu o rescriere.
- **Save serializabil de la început.** Toată starea într-o structură clară, ușor de transformat în JSON — face orice migrare viitoare simplă.
- **Ton sănătos.** Jocul motivează prin curiozitate, nu prin FOMO sau pedeapsă.
- **Sesiuni scalabile, fără plafon artificial.** O sesiune trebuie să fie completă și satisfăcătoare în 15 minute, dar jocul nu mă blochează dacă vreau să continui ore în șir. Fără energie de tip mobile care mă dă afară. Dacă apare vreun cap (ex. „antrenamentul de azi e complet"), e un semnal pozitiv și un bonus, nu o ușă închisă.

---

## Ordinea de construcție (ruta recomandată)

**Făcut deja:** setup + Git, scena de luptă, sistemul de combo, Trivia + Logică integrate, arhetipuri de inamici (Atac constant / Grabnic), card de inamic, artă pentru rege și cavaler, audio (muzică, feedback, ticăit, victorie/înfrângere), UI lustruit, harta de expediție, meniul de start, prima felie din Practice și **Save/Load pe disc** (pasul 8).

**Ce urmează:**

1. **Refactor de structură** — disciplinele devin date, nu enum fix. Câmpurile noi în baza de date (`mecanica`, `mod`, `abilitate_cognitiva`). Fără asta, fiecare disciplină nouă e o rescriere.
2. **Separarea conținutului** — ~~seriile numerice se mută din Logică în Tipare~~ **FĂCUT** (1 noiembrie 2026, odată cu disciplina a cincea: tipul SIR, nouă tipare, a ieșit din `logica.gd` și a intrat în `tipare.gd`). A RĂMAS: „Memorie" se redenumește (trivia → Cultură generală).
3. ~~**Disciplinele 3 și 4**~~ — **FĂCUT**: Cuvinte (31 octombrie 2026, 180 de cuvinte pe 1 noiembrie) și **Numere** (1 noiembrie 2026) — `scenes/numere/`, 4 tipuri, 11 tipare, fără niciun fișier de date. Vezi sesiunea AL PATRULEA OBELISC.
4. **Bucla completă a unei lupte** — recompense (victoria/înfrângerea există deja)
5. **3 inamici manuali** — unul simplu, unul Barieră, unul cu vulnerabilitate
6. **Harta de expediție** — noduri, alegerea drumului, loadout-ul de 3 din N
7. **Cetatea** — clădiri, upgrade-uri, economia resurselor
8. ~~**Save/Load**~~ — **FĂCUT** (12 octombrie 2026). `autoload/arhiva.gd`, două fișiere în `user://`, scriere prin fișier temporar și redenumire, versiune în save, fișier ilizibil pus deoparte și anunțat în meniu. Vezi sesiunea SAVE din `progres.md`.
9. **Disciplinele 5-8** — ~~Tipare~~ **FĂCUT** (1 noiembrie 2026) — `scenes/tipare/`, 4 tipuri, 18 tipare, fără niciun fișier de date, cu șirurile numerice aduse din Logică. Vezi sesiunea AL CINCILEA OBELISC. ~~Spațial~~ **FĂCUT** (1 noiembrie 2026) — `scenes/spatial/`, 4 tipuri, 12 tipare, fără fișier de date, cu PRIMA schimbare de contract din `puzzle.gd` de la Practice încoace (cârligul de desenare) și cu prima glifă care nu e o piesă de șah. Vezi sesiunea AL ȘASELEA OBELISC. RĂMÂN: **Reținere, Reflex**. Reținerea folosește chiar cârligul deschis de Spațial, dar are nevoie de mai mult decât el: o fază de arătat-apoi-ascuns, adică un TIMP în contract, nu doar un loc de desen. Reflexul e, în schimb, blocat de o decizie, nu de cod — de pe 31 octombrie cronometrul e al INAMICULUI, deci o disciplină al cărei rost e viteza n-are ceas la 2 din 3 inamici
10. **Generatorul de inamici** — arhetipuri + modificatori + buget, după ce știi că piesele merită combinate. Aici se separă identitatea inamicului (nume, descriere, facțiune) de `DATE_ARHETIP`.
11. **Artă, VFX, „juice"** — parțial început (figurile principale au imagini reale); restul e placeholder.
12. **Turnul Perseverenței** — al doilea mod de joc
13. **Antrenament liber (Practice)** — Cultură generală pe domeniul ales. **Prima felie e făcută** (8 octombrie 2026): meniu de start, alegerea domeniului și a raftului din `DOMENII` și `SUBCATEGORII`, întrebările prin chiar scena de trivia a luptei, fără cronometru, cu nivel pe domeniu (`PRAG_PRACTICE` = 60) și progres pe disc de la Save (12 octombrie 2026). **A doua felie e făcută** (12 octombrie 2026): popup-ul „Află mai multe” cu NOTA faptului, după fiecare răspuns, corect sau greșit. Nota se citește din `explicatie` — câmpul din contractul cu `puzzle.gd` — nu din `TRIVIA.fapte`, deci ecranul nu știe că există fapte și butonul merge din prima și la celelalte discipline. **De pe 21 octombrie 2026 butonul e un CREIER în colțul chenarului**, mereu acolo: stins până la verdict (nota ți-ar da răspunsul), aprins după verdict dacă există notă. Înainte era un buton sub chenar, ascuns fără notă — dar când apărea împingea rândul de dedesubt sub cursor și oprea trecerea singură; vezi sesiunea CREIERUL DIN CHENAR. Poarta e NOTA, nu câmpul `fapt`. Acoperirea a crescut de două ori în aceeași zi: dimineață 96 din 2692 (1 din 28), după ce notele s-au FABRICAT din șabloane 646 din 2692, iar după al patrulea tabel (compozitorii) **793 din 2839, adică 1 din 3,6**. **A treia felie e făcută** (21 octombrie 2026): pe raftul ales se trag întâi întrebările NEȘTIUTE (fără răspuns corect la nivelul tău), o greșită revine abia după `DISTANTA_PRACTICE` = 3 alte întrebări (la finalul raftului distanța se umple cu știute), iar când raftul e știut tot ecranul o spune O SINGURĂ DATĂ — cu cifra care mai lipsește până la nivelul următor — și continuă ca recapitulare; după aceea raftul poartă „Nivel I · 100%” în listă. Vezi sesiunea RAFTUL PARCURS. **Trecerea singură** (21 octombrie 2026): după un răspuns CORECT, „Următoarea" se umple ca o bară în `PAUZA_AUTO` = 2 s și trece fără click; o oprește doar APĂSAREA creierului (survolarea nu, de pe 21 octombrie) sau un anunț care trebuie citit, iar la greșit nu curge nimic. Fără comutator on/off, dinadins — vezi sesiunea TRECEREA SINGURĂ. **Înfățișarea** (21 octombrie 2026): pagini de pergament peste biblioteca din luptă, estompată. Tot aspectul stă într-o TEMĂ, `assets/tema/pergament.tres`, pusă pe rădăcina scenei: coboară singură în scena de trivia instanțiată, iar lupta, fără temă, rămâne neatinsă. Fonturile sunt Cinzel + Alegreya (OFL, licența lângă ele, în `assets/fonturi/`). Culorile de verdict le poate da tema (`_culoare()` din `puzzle.gd`). Pașii următori propuși: progres vizibil, artă proprie, „juice” — vezi sesiunea PERGAMENT ÎN BIBLIOTECĂ. **A rămas:** „învățat” (2–3 corecte la distanță în timp) și Jurnalul, amestecul de niveluri după deblocare, IMAGINEA din popup (hartă desenată din date sau imagine reală cu licență — `imagini` e deja câmp al faptului, dar `_incarca_fapte` citește doar nota), istoricul comun cu expedițiile și istoricul permanent pe întrebare. Detaliile sunt în sesiunile CONȚINUTUL, MENIUL ȘI PRACTICE și AFLĂ MAI MULTE din `progres.md`.
14. **Export web pentru feedback**

**Pe o linie paralelă (conținut, nu cod):** fabrica de întrebări de Cultură generală. După proba cu un singur tabel din Wikidata, crește câte puțin, ghidată de grila pe celule. Nu blochează ruta și nu e blocată de ea.

---

## Șablon de prompt pentru fiecare sesiune

> Lucrez la Mindkeep — context în fișierele atașate.
> **Unde sunt:** [ex. „am terminat scena de luptă cu placeholder-e"]
> **Ce vreau azi:** [un singur obiectiv concret]
> **Problema:** [eroarea exactă / ce nu înțeleg, dacă e cazul]
>
> Explică-mi ca cuiva la primul joc — de ce, nu doar cum.

**Sfaturi pentru sesiuni bune:**

- Un singur obiectiv per sesiune. „Fă-mi jocul" nu funcționează; „fă bara de PA să scadă la click" funcționează.
- Lipește erorile complet, cu tot cu mesajul din consolă.
- Spune-mi când nu înțelegi ceva — nu presupune că e evident.
- Cere-mi să-ți explic codul înainte să-l copiezi. Scopul e să înveți Godot, nu să acumulezi cod străin.
- La finalul sesiunii, actualizează `docs/progres.md`.

## Ce vreau de la tine (Claude)

- Lead Game Designer + mentor tehnic pentru un începător
- Cod GDScript comentat, explicat linie cu linie când e ceva nou
- Onestitate despre scope: dacă cer ceva nerealist, spune-mi
- Amintește-mi de principiile de mai sus dacă mă abat de la ele

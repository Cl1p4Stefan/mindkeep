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

## Decizii deja luate — nu le redeschide fără motiv

Fiecare din astea a fost dezbătută și decisă conștient. Dacă propui altceva, spune de ce.

| Decizie                                  | Motiv                                                                                                                                                           |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Godot 4 + GDScript**                   | 2D nativ, curbă blândă, export web din același proiect                                                                                                          |
| **2D / 2.5D — NU 3D**                    | 3D = pipeline de producție separat (modelare, rigging, animații); cel mai comun mod în care mor proiectele solo                                                 |
| **8 discipline**                         | Cultură generală, Logică, Cuvinte, Numere, Reținere, Tipare, Spațial, Reflex. Fiecare cu rol tactic distinct. Codul tratează numărul ca variabilă, nu constantă |
| **Loadout: 3 din 8**                     | 56 de combinații. Numărul 3 e variabilă de reglat, nu presupunere                                                                                               |
| **Rolurile tactice > temele**            | Fără ele, 8 discipline se joacă identic. Multi-hit, crit, ignoră armura = decizii tactice                                                                       |
| **Două moduri de joc**                   | Campanie (cronometru strict) + Turnul Perseverenței (fără timp: Sudoku, probleme). Economie comună                                                              |
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

Decise pe 27 septembrie 2026. Contextul complet e în sesiunea CONȚINUTUL din `progres.md`; regulile pentru note, în `docs/ghid-note.md`.

| Decizie | Motiv |
|---|---|
| **Întrebările se fabrică offline, nu în joc** | Un script Python scrie `intrebari_trivia.json`; jocul trage în continuare dintr-o listă finită. Păstrează garanția sacului, fiecare întrebare poate fi citită și corectată, jocul nu cere internet |
| **Surse: Wikidata pentru volum, mâna pentru restul** | Wikidata e CC0, deci se poate folosi liber, inclusiv comercial. Cultura românească și întrebările cu personalitate se scriu de mână. Frazele din Wikipedia nu se copiază (CC BY-SA) |
| **Modelul de limbaj formulează, nu informează** | Primește fapte verificate și scrie din ele; nu e niciodată sursa unui fapt. O rată de 2% greșeli la 5000 de întrebări înseamnă 100 de fapte false predate de un joc de învățare |
| **Nota aparține faptului, nu întrebării** | Un fapt dă mai multe întrebări și o singură notă: mai puțină muncă, nicio contradicție. Nota intră în câmpul `explicatie` din contractul `puzzle.gd` |
| **Fiecare întrebare are un `id` stabil** | Textul se schimbă la reformulare, iar sacul, save-ul și istoricul din Practice au nevoie de o identitate care nu se mișcă. Se face înainte de Save |
| **Ținte pe celulă (domeniu × nivel), inegale** | 500 unde domeniul le poartă; 150–250 de fapte la nivelul I din mitologie și artă. Nivelul I e plafonat de propria definiție („o știe orice adult”) |
| **Se numără faptele, nu doar întrebările** | Cel mult 2–3 întrebări pe fapt. 500 de întrebări construite din 100 de fapte se simt ca 100 |
| **O singură `categorie` pe întrebare, `etichete` pe fapt** | Categoria ține echilibrul din luptă și antetul de pe ecran. Filtrele transversale (ex. „romania”) vin din etichete, fără să înmulțească domeniile |
| **În luptă: întâi domeniul, apoi întrebarea** | Conținutul generat nu iese echilibrat (Wikidata e bogată în geografie și știință). Alegerea în două trepte ține echilibrul oricum ar arăta baza, ca la Logică |
| **Practice: alegi domeniul, nu nivelul** | Nivelul urcă singur, separat pe fiecare domeniu |
| **Nivelul următor se deblochează la un prag fix, nu la „toate corecte”** | „Toate” e un zid la final și crește odată cu conținutul. Pragul fix (de pornire: 60 de răspunsuri corecte la întrebări distincte) nu crește. După prag, nivelurile se amestecă |
| **Greșitele revin; „învățat” cere 2–3 răspunsuri corecte la distanță în timp** | Un singur răspuns corect poate fi ghicit (o șansă din patru). Întrebările învățate ies din joc și intră în Jurnal |
| **„Află mai multe” poate arăta și o imagine, câmp opțional ca nota** | Unde e Bolivia sau cum arată un monument se înțelege dintr-o privire, nu din 240 de caractere. Unde imaginea lipsește, popup-ul rămâne cum era |
| **Două feluri de imagini: desenate din date sau reale, cu licență** | Hărțile le desenează jocul din contururi în domeniul public (Natural Earth), în stilul lui: faptul ține doar ce se desenează (ex. codul țării), fără licențe și aproape fără greutate — la fel, axe ale timpului pentru datele istorice. Imaginile reale (tablouri, portrete, monumente) vin din Wikimedia Commons prin Wikidata, cu autor și licență salvate și creditul afișat în joc; fabrica refuză orice imagine fără licență clară, iar arta modernă protejată nu intră |
| **Mici (~400 px) și doar unde adaugă ceva** | Greutatea contează la exportul web: câteva mii de fapte cu câte o poză ar cântări mai mult decât tot restul jocului. Se implementează la pasul 13 |

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

**Făcut deja:** setup + Git, scena de luptă, sistemul de combo, Trivia + Logică integrate, arhetipuri de inamici (Atac constant / Grabnic), card de inamic, artă pentru rege și cavaler, audio (muzică, feedback, ticăit, victorie/înfrângere), UI lustruit.

**Ce urmează:**

1. **Refactor de structură** — disciplinele devin date, nu enum fix. Câmpurile noi în baza de date (`mecanica`, `mod`, `abilitate_cognitiva`). Fără asta, fiecare disciplină nouă e o rescriere.
2. **Separarea conținutului** — seriile numerice se mută din Logică în Tipare; „Memorie" se redenumește (trivia → Cultură generală).
3. **Disciplinele 3 și 4** — Cuvinte, Numere
4. **Bucla completă a unei lupte** — recompense (victoria/înfrângerea există deja)
5. **3 inamici manuali** — unul simplu, unul Barieră, unul cu vulnerabilitate
6. **Harta de expediție** — noduri, alegerea drumului, loadout-ul de 3 din N
7. **Cetatea** — clădiri, upgrade-uri, economia resurselor
8. **Save/Load**
9. **Disciplinele 5-8** — Reținere, Tipare, Spațial, Reflex
10. **Generatorul de inamici** — arhetipuri + modificatori + buget, după ce știi că piesele merită combinate. Aici se separă identitatea inamicului (nume, descriere, facțiune) de `DATE_ARHETIP`.
11. **Artă, VFX, „juice"** — parțial început (figurile principale au imagini reale); restul e placeholder.
12. **Turnul Perseverenței** — al doilea mod de joc
13. **Antrenament liber (Practice)** — Cultură generală pe domeniul ales. Nivelul urcă singur, pe fiecare domeniu (prag fix, apoi amestec); „Află mai multe” afișează nota faptului și, opțional, o imagine (hartă desenată din date sau imagine reală cu licență); întrebările greșite revin. Are nevoie de: `id` stabil, note, istoric permanent pe întrebare (vine cu Save), conținut suficient pe celule. Detaliile sunt în sesiunea CONȚINUTUL din `progres.md`.
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

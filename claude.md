# MINDKEEP — Context de Development
*Citește acest fișier la fiecare conversație nouă de development.*

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

---

## Decizii deja luate — nu le redeschide fără motiv

Fiecare din astea a fost dezbătută și decisă conștient. Dacă propui altceva, spune de ce.

### Structură și tehnologie

| Decizie | Motiv |
|---|---|
| **Godot 4 + GDScript** | 2D nativ, curbă blândă, export web din același proiect |
| **2D / 2.5D — NU 3D** | 3D = pipeline de producție separat (modelare, rigging, animații); cel mai comun mod în care mor proiectele solo |
| **4 discipline, nu mai multe** | A 5-a = UI nou + generare nouă + probabil clădire și stat noi |
| **Desktop = „casa" progresului** | Build-ul web e demo; save-urile nu se sincronizează automat |

### Piese și roluri

| Decizie | Motiv |
|---|---|
| **Piesele de șah = skin, nu mecanică** | Fără mișcare/capturare reală de șah — a doua curbă de învățare, fără beneficiu |
| **Regele = PV-ul jucătorului** | Nu e activabil; „Șah Mat" = condiția de înfrângere |
| **Regina — AMÂNATĂ (nu ștearsă)** | Ideea rămâne bună pe hârtie (acces la disciplina neechipată, fără să ocupe slot), dar nu se leagă natural cu comboul: orice condiție de deblocare bazată pe lanț (treapta 4) sosește exact în momentul în care NU vrei să-ți rupi lanțul ca s-o folosești. Costul real nu e cel în PA, ci lanțul pierdut — deci n-o folosești niciodată. Se reevaluează după ce există harta și un run complet jucat; până atunci nu se implementează. **Loadout-ul rămâne 3 din 4.** |
| **Loadout: 3 din 4, per expediție** | Nu per luptă — evită un meniu înainte de fiecare inamic, păstrează lupta fluidă |
| **Toate disciplinele dau daune de bază** | Altfel una devine „cea inutilă"; diferă doar efectul secundar |
| **Legendarele amplifică, nu dețin** | O relicvă nu trebuie să fie singura sursă a unui sistem — altfel devine obligatorie și restul devin decor |

### Bucla de luptă

| Decizie | Motiv |
|---|---|
| **Combo: o activare = un lanț nelimitat de întrebări** | Plătești 1 PA o singură dată, apoi treptele se CÂȘTIGĂ, nu se cumpără. Lanțul nu se mai termină de la sine — se rupe doar când greșești sau expiră cronometrul |
| **Daune pe treaptă: 1 / 2 / 3, apoi 3 fix de la treapta 4 în sus** | Cresc scurt, apoi se așează la valoarea treptei III. Fără plafon, treapta 12 ar decide singură lupta. Răsplata pentru un lanț lung vine din LUNGIME (multe trepte × 3) și din critice, nu din inflația unei singure trepte |
| **Critic la fiecare a 5-a treaptă (5, 10, 15…)** | Daunele treptei se dublează (deci 6 în loc de 3). E un obiectiv intermediar vizibil: la treapta 4 știi deja că următoarea valorează dublu, deci ai un motiv concret să mai riști o întrebare |
| **Daunele acumulate rămân când lanțul se rupe** | Greșeala oprește creșterea, nu șterge munca. Altfel un lanț lung ar fi prea riscant ca să merite pornit |
| **Greșeală = Obeliscul rămâne blocat până la finalul rundei** | Înlocuiește vechea regulă „pierzi 1 PA". Cu lanțuri nelimitate, un PA nu mai e o pedeapsă reală; pierderea unei unelte pentru restul rundei te obligă să reorganizezi tura, nu doar să reîncerci imediat. Pedeapsa rămâne pe unealtă, nu pe tură — nu pierzi runda pentru că n-ai știut un răspuns |
| **Tura se încheie automat când nu mai ai Obeliscuri utilizabile** | Fără PA, sau cu tot ce ai blocat, butonul „Încheie tura" e un click ceremonial. Jocul nu trebuie să-mi ceară să confirm că n-am ce face |
| **Facțiuni de inamic, separate de arhetip** | Facțiunea (Cei Șterși, Ecourile) e apartenența tematică: zero efect mecanic azi, dar e cârligul pentru zone de hartă și pentru echipament anti-facțiune. Arhetipul rămâne strict regula de comportament — două câmpuri, două scopuri |
| **Inamici generați, nu scriși de mână** | ~10 arhetipuri × ~10 modificatori = sute de comportamente din zeci de reguli. Fără live-service, fără pattern-uri de memorat |
| **Boșii rămân manuali** | 5-6 lupte scrise, ca momente memorabile |

## Principii pe care vreau să le aperi

- **Scope-ul mic e o funcționalitate, nu o limitare.** Dacă o idee de-a mea umflă scope-ul, spune-mi direct.
- **Prototip întâi, artă după.** Placeholder-e până când bucla de luptă e validată ca distractivă.
- **Contract identic între discipline.** Fiecare Obelisc e o scenă independentă cu aceeași interfață către luptă (`porneste()`, `arata_stare()`, semnalul `rezolvat(succes)`). O disciplină nouă trebuie să fie un rând în tabel, nu o ramură nouă în cod.
- **Save serializabil de la început.** Toată starea într-o structură clară, ușor de transformat în JSON — face orice migrare viitoare simplă.
- **Ton sănătos.** Jocul motivează prin curiozitate, nu prin FOMO sau pedeapsă.
- **Sesiuni scalabile, fără plafon artificial.** O sesiune trebuie să fie completă și satisfăcătoare în 15 minute, dar jocul nu mă blochează dacă vreau să continui ore în șir. Fără energie de tip mobile care mă dă afară. Dacă apare vreun cap (ex. „antrenamentul de azi e complet"), e un semnal pozitiv și un bonus, nu o ușă închisă.

---

## Ce a rămas de construit

*Ordinea recomandată pentru ce urmează. Ce e deja funcțional — scena de luptă,
comboul, Memoria (Trivia), Logica, ecranul de victorie — e descris în
`docs/progres.md`; aici stau doar pașii deschiși.*

1. **Închiderea buclei de luptă** — ecran de înfrângere („Șah Mat") și recompense după victorie. Victoria are panou; înfrângerea se termină încă în tăcere.
2. **Jucat pe mână o luptă întreagă.** Totul a fost verificat prin rulare automată și capturi de ecran. Ritmul lanțului, cronometrul și dificultatea reală se simt doar jucând.
3. **Baza comună de puzzle** (`puzzle.gd`, `class_name Puzzle`) — `trivia.gd` și `logica.gd` au ~80 de linii identice. De rezolvat ÎNAINTE de a treia disciplină, altfel o regulă de timp se schimbă în patru locuri.
4. **Trei inamici manuali** — unul simplu, unul Barieră, unul Grabnic. Verifică dacă arhetipurile chiar se simt diferit.
5. **Harta de expediție** — noduri, alegerea drumului, loadout-ul de 3 din 4.
6. **Cetatea** — clădiri, upgrade-uri, economia celor 4 resurse.
7. **Save/Load.**
8. **Ultimele două discipline** — Cuvântul Adevărat (Anagrame) și Ordinea (Sudoku), pe rând.
9. ~~**Regina**~~ — **amânată.** Nu se implementează acum (vezi tabelul de decizii). Se reevaluează după harta de expediție și un run complet: dacă loadout-ul de 3 din 4 chiar creează ziduri frustrante, îi găsim altă condiție de deblocare — una care să nu ceară ruperea lanțului.
10. **Generatorul de inamici** — arhetipuri + modificatori + buget, după ce știi că piesele merită combinate. Aici se separă identitatea inamicului (nume, descriere, facțiune) de `DATE_ARHETIP`.
11. **Artă, VFX, „juice"** — parțial început (figurile principale au imagini reale); restul e placeholder.
12. **Export web pentru feedback.**

---

## Șablon de prompt pentru fiecare sesiune

> Lucrez la Mindkeep — context în `CLAUDE.md` și `docs/progres.md`.
> **Unde sunt:** [ex. „am terminat comboul și Obeliscul Logicii"]
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

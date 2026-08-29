# MINDKEEP — Context de Development
*Atașează acest fișier la fiecare conversație nouă de development, împreună cu Pitch Document-ul (v1.0).*

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

Detaliile complete sunt în **Mindkeep-Pitch-Document.md (v1.0)** — atașează-l alături de acesta.

---

## Decizii deja luate — nu le redeschide fără motiv

Fiecare din astea a fost dezbătută și decisă conștient. Dacă propui altceva, spune de ce.

| Decizie | Motiv |
|---|---|
| **Godot 4 + GDScript** | 2D nativ, curbă blândă, export web din același proiect |
| **2D / 2.5D — NU 3D** | 3D = pipeline de producție separat (modelare, rigging, animații); cel mai comun mod în care mor proiectele solo |
| **4 discipline, nu mai multe** | A 5-a = UI nou + generare nouă + probabil clădire și stat noi |
| **Piesele de șah = skin, nu mecanică** | Fără mișcare/capturare reală de șah — a doua curbă de învățare, fără beneficiu |
| **Regele = PV-ul jucătorului** | Nu e activabil; „Șah Mat" = condiția de înfrângere |
| **Regina = acces la disciplina lipsă** | Nu ocupă slot; se deblochează la 2 stack-uri de Claritate; costă 2 PA; 1x per luptă. Flexibilitate câștigată, zero conținut nou |
| **Inamici generați, nu scriși de mână** | ~10 arhetipuri × ~10 modificatori = sute de comportamente din zeci de reguli. Fără live-service, fără pattern-uri de memorat |
| **Boșii rămân manuali** | 5-6 lupte scrise, ca momente memorabile |
| **Legendarele amplifică, nu dețin** | O relicvă nu trebuie să fie singura sursă a unui sistem — altfel devine obligatorie și restul devin decor |
| **Loadout: 3 din 4, per expediție** | Nu per luptă — evită un meniu înainte de fiecare inamic, păstrează lupta fluidă |
| **Toate disciplinele dau daune de bază** | Altfel una devine „cea inutilă"; diferă doar efectul secundar |
| **Greșeală = pierzi 1 PA, NU tura** | Pierderea turii pedepsește ignoranța în loc s-o corecteze |
| **Desktop = „casa" progresului** | Build-ul web e demo; save-urile nu se sincronizează automat |

## Principii pe care vreau să le aperi

- **Scope-ul mic e o funcționalitate, nu o limitare.** Dacă o idee de-a mea umflă scope-ul, spune-mi direct.
- **Prototip întâi, artă după.** Placeholder-e până când bucla de luptă e validată ca distractivă.
- **O disciplină întâi.** Trivia complet funcțională, integrată în luptă, înainte de celelalte trei.
- **Save serializabil de la început.** Toată starea într-o structură clară, ușor de transformat în JSON — face orice migrare viitoare simplă.
- **Ton sănătos.** Jocul motivează prin curiozitate, nu prin FOMO sau pedeapsă.
- **Sesiuni scalabile, fără plafon artificial.** O sesiune trebuie să fie completă și satisfăcătoare în 15 minute, dar jocul nu mă blochează dacă vreau să continui ore în șir. Fără energie de tip mobile care mă dă afară. Dacă apare vreun cap (ex. „antrenamentul de azi e complet"), e un semnal pozitiv și un bonus, nu o ușă închisă.

---

## Ordinea de construcție (ruta recomandată)

1. **Setup** — Godot instalat, proiect creat, primul commit în Git
2. **Scena de luptă, cu placeholder-e** — PA, Obeliscuri activabile, PV, tura inamicului, **ceasul inamicului** (cel mai mare impact asupra senzației de joc, și ieftin de prototipat). Fără artă.
3. **Trivia, ca scenă independentă** — primește dificultate, returnează succes/eșec. Interfață curată către Combat Controller.
4. **Bucla completă a unei lupte** — victorie, înfrângere, recompense
5. **3 inamici manuali** — unul simplu, unul Barieră, unul Grabnic. Verifică dacă arhetipurile chiar se simt diferit.
6. **Harta de expediție** — noduri, alegerea drumului, loadout-ul de 3 din 4
7. **Cetatea** — clădiri, upgrade-uri, economia celor 4 resurse
8. **Save/Load**
9. **Celelalte 3 discipline**, pe rând
10. **Regina** — abia acum are ce împrumuta
11. **Generatorul de inamici** — arhetipuri + modificatori + buget, după ce știi că piesele merită combinate
12. **Artă, VFX, „juice"**
13. **Export web pentru feedback**

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

## Ce vreau de la tine (Claude)

- Lead Game Designer + mentor tehnic pentru un începător
- Cod GDScript comentat, explicat linie cu linie când e ceva nou
- Onestitate despre scope: dacă cer ceva nerealist, spune-mi
- Amintește-mi de principiile de mai sus dacă mă abat de la ele
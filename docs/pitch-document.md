# MINDKEEP — Pitch Document (Concept Inițial)

_v3.0 — document de lucru, menit să evolueze pe măsură ce construim GDD-ul complet_

**Elevator pitch:** Bookworm Adventures se întâlnește cu Slay the Spire și Darkest Dungeon — într-o cetate-bibliotecă, ultimul bastion al adevărului, într-o lume care își uită, literalmente, propria istorie.

Ideea centrală care leagă tot ce urmează: jucătorul nu colecționează carduri sau echipamente ca să lupte — colecționează **cunoaștere reală**. Fiecare fapt de istorie, fiecare cuvânt reconstruit, fiecare secvență logică rezolvată e literalmente arma cu care respingi golul. Cele patru tipuri de puzzle pe care le-ai listat (Trivia, Sudoku, Anagrame, Logică) nu sunt patru mini-jocuri lipite — sunt patru **discipline** ale aceleiași puteri, fiecare cu propriul loc în lume, propria clădire în Cetate și propriul rol tactic în luptă.

Referințe de gen (comps): **Puzzle Quest** (puzzle-uri ca sursă de daune RPG), **Bookworm Adventures** (compui cuvinte ca să lovești un dragon), **Slay the Spire** (harta cu noduri) și **Darkest Dungeon** (bucla Hub ↔ Expediție). Niciunul dintre ele nu combină toate patru — de-aici vine spațiul liber de diferențiere.

---

## 1. Titlul de Lucru — 3 Variante

### A. MINDKEEP _(recomandarea mea)_

Joc de cuvinte: _keep_ e turnul central al unei fortărețe medievale — se potrivește perfect cu structura de Town-Hub — dar înseamnă și _a păstra / a ține minte_. Scurt, internațional, sună ca un RPG serios de pe Steam, nu ca un app educațional care se preface a fi joc.

### B. ULTIMA ARHIVĂ _(The Last Archive)_

Titlu mai epic și narativ, care pune miza poveștii chiar în nume — bun pentru trailer și pagina de Steam, dar spune mai puțin despre gameplay decât Mindkeep.

### C. OBELISCURILE MEMORIEI _(Obelisks of Memory)_

Titlu care vinde direct mecanica ta centrală de luptă. Util dacă vrei ca marketingul să pună accent pe sistemul tactic unic (nu pe „încă-un-roguelike-cu-carduri"), și diferențiază clar produsul din prima secundă.

_În restul documentului folosesc **Mindkeep** ca nume de lucru, strict din motive de claritate — decizia finală rămâne complet deschisă._

---

## 2. Tematică — DE REDEFINIT

> **Starea acestei secțiuni:** povestea anterioară (Ștergerea, jucătorul, Cetatea) a fost scoasă. Rama narativă nouă nu e încă decisă. Restul documentului e scris ca să funcționeze independent de ea — sistemele de luptă, progresie și conținut nu depind de nicio poveste anume.

**Ce rămâne ferm, indiferent de temă:**

- **Wrapper de RPG tactic, nu aplicație educațională.** Regula originală a proiectului: jocul trebuie să arate și să se simtă ca un joc de strategie, nu ca un quiz cu puncte.
- **Cunoașterea jucătorului e arma.** Răspunsurile corecte se traduc în daune, apărare, efecte. Asta nu e o metaforă de decor — e mecanica centrală.
- **Ton gotic-medieval**, deja stabilit vizual: piatră, cerneală, lumânări, paletă desaturată. Arta existentă (regele, cavalerul) se încadrează aici.
- **Presiunea timpului e parte din fantezie**, nu doar o constrângere de joc: trebuie să existe un motiv în lume pentru care gândești sub cronometru.

**Ce trebuie redenumit când se decide tema:**

| Element           | Nume vechi (scos)    | Stare                     |
| ----------------- | -------------------- | ------------------------- |
| Jucătorul         | jucătorul            | de redefinit              |
| Baza / hub-ul     | Cetatea              | de redefinit              |
| Antagonistul      | Ștergerea            | de redefinit              |
| Moneda principală | Fragmente            | de redefinit              |
| Jurnalul de fapte | Jurnal               | de redefinit              |
| Facțiuni inamice  | Cei Șterși, Ecourile | de redefinit              |
| Locația de RNG    | Fântâna              | de redefinit              |
| Primul inamic     | Cavalerul Șters      | **există în cod și artă** |

**Notă practică:** Cavalerul Șters e deja construit — imagine, descriere, arhetip. Merită păstrat ca formă vizuală (cavaler în armură, fără chip, ochi luminoși) chiar dacă justificarea narativă se schimbă. Un adversar fără chip funcționează în aproape orice ramă medieval-fantasy.

---

## 3. Core Gameplay Loop — O Sesiune de 15 Minute

| Fază                           | Durată    | Ce se întâmplă                                                                                                                                            |
| ------------------------------ | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Cetatea**                 | ~2 min    | Colectezi ce s-a „copt" peste noapte (cercetare finalizată în Bibliotecă), verifici Decretul Zilnic, cheltui resurse pe un upgrade rapid dacă ai destule. |
| **2. Harta Expediției**        | ~1 min    | Alegi nodul de azi: Luptă, Eveniment sau Elită.                                                                                                           |
| **3. Lupta**                   | ~8-10 min | 1-2 încleștări tactice folosind Obeliscuri, sub presiunea timpului.                                                                                       |
| **4. Recompense & Întoarcere** | ~2 min    | Loot, Jurnalul se actualizează cu un fapt nou, pornești o cercetare nouă pentru mâine.                                                                    |

**Pas cu pas:**

1. **Deschizi jocul și ajungi în Cetate.** Vezi imediat ce s-a finalizat peste noapte (o cercetare din Bibliotecă, de exemplu) și dacă Decretul Zilnic (un singur puzzle special, gen Wordle) e disponibil.
2. **Cheltui, opțional, resursele de ieri.** Dacă ai destul Minereu Runic, faci un upgrade la Fierărie rezolvând un singur puzzle logic — cost mic de timp, beneficiu permanent.
3. **Treci pe Harta Expediției.** O hartă cu noduri, în stilul Slay the Spire, dar dimensionată pentru o sesiune scurtă — nu un maraton de o oră, ci 3-5 noduri active pe zi. Alegi calea de azi.
4. **Intri în Luptă.** Aici se consumă majoritatea celor 15 minute — vezi Secțiunea 4 pentru mecanica exactă.
5. **Colectezi recompensele** — Fragmente, poate un Relic random, și o intrare nouă în Jurnal cu faptul pe care tocmai l-ai „recuperat" în luptă.
6. **Te întorci în Cetate**, pornești o Cercetare nouă la Bibliotecă (timer de câteva ore, ca să ai ceva gata mâine) și închizi jocul.

**Flexibilitate reală.** Structura suportă atât o sesiune de 7-8 minute (o singură luptă, într-o zi aglomerată) cât și una de 20+ minute (două lupte plus un nod Elită, într-o zi liberă) — important pentru un obicei zilnic pe termen lung: jocul trebuie să se plieze pe viața ta, nu invers.

---

## 4. Sistemul de Luptă Detaliat

### Piesele de bază

- **Obelisc** — o poziție fixă pe câmpul de luptă (de regulă 3-4 active simultan). Fiecare Obelisc are o **disciplină** (Memorie/Trivia, Ordine/Sudoku, Cuvântul Adevărat/Anagramă, Logică) și un **Nivel** (I, II, III) care determină dificultatea puzzle-ului și costul în PA.
- **PA (Puncte de Acțiune)** — resursa cheltuită ca să activezi un Obelisc. Primești un număr fix de PA în fiecare rundă (ex: 3) — **PA nu se reportează** între runde, ca să țină regula simplă și ușor de implementat.
- **Recărcare** — după ce activezi un Obelisc, acesta intră în Recărcare pentru 1 rundă și nu poate fi reactivat imediat. Te forțează să rotești disciplinele, nu să folosești mereu aceeași.
- **Combo (lanțul)** — o activare de Obelisc nu înseamnă o singură întrebare, ci un **lanț nelimitat** de întrebări din aceeași disciplină. Plătești PA o singură dată, la pornire; după aceea fiecare treaptă se **câștigă** răspunzând corect, nu se cumpără. Treptele 1-3 urcă dificultatea I → II → III, apoi rămân la III.
  - **Daune pe treaptă:** **1** la treapta I, **2** la treapta II, **3** la treapta III, apoi **3 fix** la fiecare treaptă de la 4 în sus. Cresc scurt, apoi se așează: fără plafon, treapta 12 ar decide singură lupta. Răsplata pentru un lanț lung vine din LUNGIME (multe trepte × 3) și din critice, nu din inflația unei singure trepte.
  - **Critic la fiecare a 5-a treaptă** (5, 10, 15…): daunele treptei se dublează — 6 în loc de 3. E un obiectiv intermediar vizibil: la treapta 4 știi deja că următoarea valorează dublu, deci ai un motiv concret să mai riști o întrebare.
  - **Ruperea lanțului:** doar un răspuns greșit sau un timeout îl oprește — nu se termină de la sine. **Daunele acumulate rămân** (greșeala oprește creșterea, nu șterge munca), iar Obeliscul respectiv rămâne blocat până la finalul rundei. Pedeapsa cade pe unealtă, nu pe tură.
- **Scut** — un strat de apărare temporar, obținut de obicei din discipline defensive (Sudoku/Ordine), care absoarbe daune primite din atacul inamicului.
- **Cronometru per-puzzle** — fiecare Obelisc activat deschide o fereastră de timp (15-30 secunde, în funcție de Nivel) în care rezolvi puzzle-ul. Reușita la timp = efect complet; eșecul sau timeout-ul = PA-ul e oricum cheltuit, dar fără efect, iar Obeliscul respectiv devine vizibil „corupt" pentru o rundă (risc tactic real dacă activezi ceva ce nu știi sigur).

**Structura unei runde:** Tura ta (cheltuiești PA activând Obeliscuri) → Tura inamicului (execută atacul pe care și l-a anunțat la începutul rundei tale, ca în Slay the Spire — deci decizi cu informație completă, nu la noroc) → repetă.

> **De ce NU e un deckbuilder clasic.** Nu construiești un deck înainte de luptă și nu tragi cărți random dintr-un pool limitat. Fiecare Obelisc e o poziție FIXĂ, cu o disciplină fixă — controlul tău vine din CÂND și CE alegi să activezi, nu din ce „mână" ai primit. Conținutul provocării (întrebarea, anagrama, secvența) e generat proaspăt de fiecare dată, nu extras dintr-un pool finit de carduri unice — ceea ce înseamnă rejucabilitate practic infinită **fără să proiectezi și să echilibrezi sute de carduri**, un avantaj de scope semnificativ pentru un dev solo.

### Adâncime strategică: de ce alegerea contează

Fără constrângeri, „ce Obelisc activez" nu e o alegere reală — dacă am 3 PA și 3 piese disponibile, le apăs pe toate; puzzle-ul e greu, dar jocul din jurul lui nu e. Patru mecanisme creează cost de oportunitate, fără niciun conținut nou:

1. **PA insuficient, deliberat.** Mereu mai multe opțiuni decât PA disponibil (ex. 3 PA, 4 piese, una costând 2). Ceva rămâne mereu nefolosit — deci chiar alegi.
2. **Alegi înainte să vezi provocarea.** Activarea arată disciplina, categoria și Nivelul („Trivia · Istorie · Niv. II"), dar nu întrebarea în sine. Pariezi pe propria cunoaștere, nu pe ce ți-a picat pe ecran.
3. **Escaladare în cadrul rundei.** A doua activare a aceleiași discipline într-o rundă urcă un Nivel de dificultate. Rotirea disciplinelor devine avantajoasă mecanic, nu doar recomandată — și atacă problema zonei de confort dintr-un unghi diferit față de vulnerabilități.
4. **Inamicul are un ceas, nu doar PV.** Mulți inamici încarcă un atac devastator pe parcursul a 2-3 runde, vizibil pe ecran. Lupta devine o cursă, nu o listă de puzzle-uri de bifat: îl dobori la timp, sau construiești scut și încasezi?

### Adâncime la nivel de expediție

- **PV nu se refac complet între lupte.** Tensiunea centrală a unei expediții: victoria rapidă vs. victoria ieftină. Un fight câștigat cu 2 PV rămași e o problemă pentru nodul următor.
- **Ruta pe hartă e o decizie.** Nodurile își arată tipul dinainte (Elită = loot bun, risc mare; Eveniment = necunoscut; Odihnă = PV recuperate). Cu PV limitate și un loadout fix de 3 discipline, alegerea drumului devine strategie, nu plimbare.
- **Loadout-ul de 3 din 4** e prima decizie strategică a fiecărei expediții și influențează tot ce urmează pe hartă.

### Cele 8 Discipline

Fiecare Obelisc primește un **simbol propriu**, ales să sugereze tipul de gândire pe care îl cere. Simbolurile de mai jos sunt propuneri de lucru, nu decizii finale: ce contează e ca fiecare să fie distinct de celelalte la prima vedere, chiar și la 40px.

| #   | Disciplină           | Simbol propus  | Ce faci în 10-15s                                        | Rol tactic în luptă                             |
| --- | -------------------- | -------------- | -------------------------------------------------------- | ----------------------------------------------- |
| 1   | **Cultură generală** | Carte deschisă | Fapte: istorie, geografie, artă, știință, mitologie      | Gamble: daune aleatorii, varianță mare          |
| 2   | **Logică**           | Cheie / lacăt  | Deducție scurtă, cine minte, condiții                    | Daune mari, dar cost de timp mare               |
| 3   | **Cuvinte**          | Pană de scris  | Anagrame, intrus, sinonim, cuvânt lipsă                  | Constant, fără surprize                         |
| 4   | **Numere**           | Balanță        | Calcul rapid, procente, estimare                         | Multi-hit: 3 provocări mici într-un tur         |
| 5   | **Reținere**         | Clepsidră      | Vezi o secvență 3s, apoi o reproduci / „ce s-a schimbat" | Încărcare: rundă fără daune, apoi lovitură mare |
| 6   | **Tipare**           | Spirală / nod  | Serii de numere/simboluri, ce urmează                    | Crit: ori nimerești, ori pierzi turul           |
| 7   | **Spațial**          | Busolă / cub   | Rotații mentale, plieri, potrivire de forme              | Ignoră „armura" inamicului                      |
| 8   | **Reflex**           | Fulger         | Stroop, găsește intrusul, tap corect sub 3s              | Daune mici, dar poți ataca de două ori          |

**Criteriile pentru un simbol bun**, când le finalizezi:

- **Distinct ca siluetă**, nu doar ca detaliu — trebuie recunoscut periferic, în mijlocul unei ture cronometrate.
- **Lizibil la dimensiune mică.** Un simbol cu detalii fine devine o pată pe un buton de 40px.
- **Consistent ca stil** între toate 8. Un amestec de iconițe realiste și plate arată dezordonat.
- **Fără suprapunere conceptuală.** Carte și pană se pot confunda ca sens (ambele „scris") — merită verificat că fiecare pereche e clar diferită.

**De ce rolurile tactice contează mai mult decât simbolurile.** Fără ele, cele 8 sunt opt seturi de întrebări care se joacă identic — apeși, răspunzi, faci daune. Cu ele, alegerea unei discipline e o decizie tactică: iei Numere pentru multi-hit chiar dacă nu ești grozav la calcul, iei Spațial ca să treci de un inamic blindat. Disciplina devine o unealtă, nu doar un subiect.

**Condiția de înfrângere:** PV-ul jucătorului ajunge la 0.

### Loadout: 3 din 8

Jucătorul alege 3 discipline o dată, la începutul unei expediții (nu înainte de fiecare luptă) — **56 de combinații posibile**. Un moment strategic la început, apoi lupte fluide fără meniuri.

Diferența față de „3 din 4": alegerea nu mai e „la ce renunț?", ci „ce build îmi construiesc?". Mai aproape de un RPG, mai puțin de o constrângere roguelite — și face vulnerabilitățile și barierele mult mai grele, fiindcă 5 din 8 discipline lipsesc mereu din trusă.

_Numărul 3 e o presupunere de echilibrare. Dacă la testare se dovedește prea restrictiv, 4 din 8 e alternativa. Ține numărul ca variabilă în cod, nu ca o constantă presupusă._

**De ce nu devine deckbuilder.** Nu alegi din zeci de carduri unice și nu tragi random în luptă — alegi dintr-un set fix de discipline, iar cele 3 alese sunt mereu disponibile. Mai aproape de o trusă de unelte decât de un deck.

**Supapa pentru disciplina lipsă — AMÂNATĂ.** Exista o mecanică (fosta „Regina") care dădea acces, contra cost, la o disciplină neechipată. A fost amânată: condiția de deblocare venea exact în momentul în care nu vrei să-ți rupi lanțul de combo ca s-o folosești. Cu 8 discipline și 5 mereu lipsă din trusă, o supapă de acest fel devine mai importantă, nu mai puțin — merită regândită după ce există harta și un run complet.

### Risc de design: min-maxing

Cu 8 discipline și doar 3 alese, riscul crește: dacă ești bun la Cuvinte, Numere și Cultură generală, de ce ai lua vreodată Spațialul? Rezultatul ar fi 5 discipline neatinse — opusul scopului declarat al jocului.

**Trei pârghii, la intensități diferite:**

- **Vulnerabilități** (frecvente, bonus pozitiv) — inamicul primește daune duble de la o disciplină anume, afișată înainte de luptă. Motorul principal: recompensează adaptarea.
- **Bariere** (rare, inamici speciali/boși) — o disciplină e blocată de un scut care trebuie spart cu alta. Regulă de siguranță: bariera încetinește, nu blochează complet — fără soft-lock.
- **Lovitura de grație** — bonus de resurse rare dacă închei lupta cu disciplina la care ai statistica cea mai mică. Rulează în fundal, fără date noi despre inamici.

**Supapă de rezervă**, dacă min-maxing-ul persistă: interzicerea a 3 discipline din aceeași familie (ex. nu poți lua simultan Numere + Tipare + Logică). Nu e nevoie s-o decizi acum.

### Construcție etapizată: proiectează pentru 8, construiește 4

8 discipline înseamnă 8 generatoare, 8 interfețe, 8 clădiri în Cetate, 8 statistici. E o creștere de 4× peste tot ce s-a construit până acum — nerealist de livrat deodată, înainte ca harta, Cetatea și save-ul să existe.

**Soluția:** numărul de discipline e o listă, nu o constantă. Loadout-ul e „alege N din M". Vulnerabilitățile referă o disciplină prin ID, nu printr-un enum fix. Cetatea își generează clădirile dintr-un tabel de date.

Atunci disciplinele 5-8 sunt update-uri de conținut, nu rescrieri.

**Ordinea de construcție:** 1-4 fundația (Cultură generală, Logică, Cuvinte, Numere) → 5-6 cele mai vizuale și distincte (Reținere, Tipare) → 7-8 ultimele (Spațial, Reflex).

**Notă de verificat la balansare:** rolul Reținerii („rundă fără daune, apoi lovitură mare") e riscant într-o luptă de 3-4 runde — s-ar putea să nu apuci niciodată beneficiul, mai ales dacă greșești și Obeliscul se blochează.

### Conflicte de rezolvat în cod

- **Seriile numerice** sunt acum la Tipare (#6), nu la Logică (#2) — trebuie mutate din generatorul actual de Logică, altfel același conținut apare în două Obeliscuri.
- **„Memorie"** își schimbă sensul: în cod și UI e acum trivia, dar în structura nouă Cultură generală (#1) preia trivia, iar Reținere (#5) e memoria de lucru. Redenumire necesară ca să nu se încurce.
- **Mecanica „intrus"** apare la mai multe discipline — corect, dar cu conținut diferit (cuvinte la #3, forme la #7, simboluri la #8). Confirmă separarea axei _mecanică_ de axa _domeniu_.

### Exemplu de Luptă: vs. Cavalerul Șters

_Cavalerul Șters — 30 PV. Inamic timpuriu, arhetip „Atac constant": lovește 3 daune în fiecare tură, din runda 1, fără încărcare și fără tură sărită. Își anunță mereu intenția._

**Câmpul de luptă (loadout ales pentru expediție):**

| Obelisc        | Disciplină       | Rol tactic                  | Cost |
| -------------- | ---------------- | --------------------------- | ---- |
| Carte deschisă | Cultură generală | Gamble: daune variabile     | 1 PA |
| Cheie          | Logică           | Daune mari, timp mai scurt  | 1 PA |
| Balanță        | Numere           | Multi-hit: 3 provocări mici | 1 PA |

Jucătorul are 3 PA pe rundă și 15 PV.

**Runda 1 — Tura ta.** Cavalerul anunță: _⚔ 3_.
Activezi **Cultură generală** (1 PA) → cronometru 12s: _„În ce secol a început, convențional, Renașterea italiană?"_ Corect → 1 daună (Cavalerul: 29 PV). **Lanțul continuă automat:** întrebare de Nivel II, tot Cultură generală, 11s. Corect → +2 daune (27 PV). Nivel III, 10s: greșit. Lanțul se rupe, păstrezi cele 3 daune date, iar Obeliscul se blochează până la finalul rundei.

Mai ai 2 PA. Activezi **Logica** → lanț de 4 trepte reușite: 1+2+3+3 = 9 daune (18 PV). La treapta 5 greșești — se blochează și el.

Ultimul PA pe **Numere** → 2 trepte: 3 daune (15 PV). Nu mai ai PA, tura se încheie automat.

**Runda 1 — Tura inamicului.** Cavalerul lovește: 3 daune. Tu: 12/15 PV.

**Runda 2.** Toate Obeliscurile deblocate, 3 PA din nou. Un lanț bun pe Logică ajunge la treapta 5 — **CRITIC**, daune dublate. Cavalerul cade.

**Victorie.** Recompense: Fragmente + o intrare nouă în Jurnal — _„Renașterea italiană e plasată convențional la începutul secolului XIV, în Florența."_ Bucla se închide exact acolo unde trebuie: joc, apoi un fapt real, mic, dar câștigat.

---

## 5. Recomandare de Flow — Cetate ↔ Hartă

Principiul central: **nimic din ce ai nevoie ca să progresezi în Cetate nu poate fi cumpărat sau obținut pasiv — trebuie adus de pe Hartă.** Asta transformă fiecare clădire într-un motiv concret să pleci în expediție, și fiecare expediție într-un motiv să te întorci să investești.

### Harta de interconectare

| Clădire (Cetate)          | Disciplină   | Statistică | Efect în luptă             | Resursă necesară (de pe Hartă) |
| ------------------------- | ------------ | ---------- | -------------------------- | ------------------------------ |
| **Biblioteca**            | Trivia       | Intelect   | +daune, Obeliscul Memoriei | Fragmente, Însemnări           |
| **Sanctuarul Ordinii**    | Sudoku rapid | Claritate  | −Recărcare, +durată Combo  | Praf Astral                    |
| **Atelierul de Alchimie** | Anagrame     | Reziliență | +PV maxime, +valoare Scut  | Ierburi & Reactivi             |
| **Fierăria**              | Puzzle logic | Precizie   | +critic, +eficiență PA     | Minereu Runic                  |

_Toate cele 4 discipline dau daune de bază identice, pe același Nivel — coloana „Efect în luptă" arată doar bonusul SECUNDAR pe care fiecare statistică îl adaugă peste acea bază, nu o înlocuire a daunelor. Așa nicio disciplină nu se simte „inutilă" în luptă, oricât de mult ai investit în celelalte trei._

Fiecare rând e o buclă completă: clădirea îți dă un motiv să lupți (ai nevoie de resursa X), lupta îți dă resursa, resursa îmbunătățește exact disciplina cu care ai luptat ca s-o obții. Nu e o economie centrală unde totul se cumpără cu o singură monedă — e patru economii mici, paralele, fiecare legată de o abilitate mentală diferită.

### A cincea locație: Fântâna

Rezolvă o problemă reală: fără un sink, resursele în exces — după ce ai maximizat un upgrade — rămân moarte în inventar. O locație dedicată e soluția corectă. O singură ajustare, ca să rămână legată de Pilonul central (mintea, nu norocul pur): o poartă printr-un puzzle rapid, nu doar cheltuială directă.

**Cum funcționează:**

1. O dată pe zi (la fel ca Decretul Zilnic), vizitezi Fântâna și cheltui orice combinație de resurse în exces.
2. Primești un puzzle rapid, mixt — orice disciplină, miză mică, cronometru generos. Rezolvat corect → șansele pentru Rar/Epic/Legendar cresc vizibil. Greșit → tot primești o tragere, dar la șansele de bază — niciodată mână goală.
3. Șansele exacte sunt afișate înainte să te decizi.

**Funnel-ul rămâne clar:** Comun/Neobișnuit vin firesc din luptă și din Fierărie — activitatea de zi cu zi. Fântâna e special pentru Rar/Epic/Legendar — momentul „poate azi" al sesiunii.

Fără puzzle-ul de la pasul 2, Fântâna devine singurul loc din tot jocul unde nu ceri nimic de la mintea jucătorului — exact bucla de recompensă-aleatorie-fără-efort pe care ai vrut s-o eviți încă din primul mesaj, când ai spus clar că scopul e antrenament mental sănătos, nu o buclă de dopamină goală. Cu puzzle-ul și cu o singură vizită pe zi, rămâne senzația de „poate azi", nu de „încă o tragere".

Numele — Fântâna — e perfect tematic și îl păstrez întocmai: riști ceva de valoare direct în forța care mănâncă lumea, sperând să scoți ceva rar înainte să dispară pentru totdeauna.

### Motoare de reîntoarcere zilnică

1. **Decretul Zilnic** — un singur puzzle special, rotativ la 24h (gen Wordle), cu scor personal și o recompensă unică. Motiv să deschizi jocul chiar și într-o zi fără timp pentru o expediție completă.
2. **Cercetarea din Bibliotecă** — un timer de tip „idle" (12-24h) care deblochează categorii noi de întrebări. Trebuie pornit manual după ce se termină cel curent — te aduce înapoi periodic doar ca să apeși „start" pe tema următoare.
3. **Harta rotativă** — nodurile de tip Eveniment se schimbă la câteva zile. Ratarea unui nod înseamnă ratarea unui fragment unic de poveste sau a unui Relic rar — presiune blândă, nu punitivă.
4. **Jurnal** — fiecare fapt la care ai răspuns corect rămâne permanent într-un jurnal ilustrat, vizibil în Cetate. Practic, un jurnal real al lucrurilor pe care le-ai învățat — cu propriul lui hook de „completare a colecției".
5. **Fântâna** — o dată pe zi, riști resursele în exces + un puzzle rapid pentru o șansă la echipament Rar/Epic/Legendar. Rezolvă și problema resurselor „moarte" după ce ai maximizat un upgrade.

### O notă despre ritm

Scopul declarat e antrenament mental zilnic, susținut pe termen lung. O sesiune trebuie să fie completă și satisfăcătoare în ~15 minute — o zi aglomerată nu trebuie să însemne „sar peste" — dar jocul nu plafonează artificial pe cineva care vrea să continue: fără energie de tip mobile care te dă afară din joc. Dacă apare un semnal de tip „ai completat antrenamentul de azi!", e o confirmare pozitivă și eventual un mic bonus, nu o ușă închisă. Cele cinci motoare de mai sus funcționează prin curiozitate sau printr-un moment scurt de gândire, nu prin frica de-a pierde ceva sau prin recompensă pur aleatorie — o distincție importantă atât etic, cât și pentru longevitatea unui joc pe care chiar tu vrei să-l joci zilnic, ani de zile, fără să te epuizeze.

---

## 6. Sistem RPG — Stats & Echipament

_Adăugat după runda de feedback — extinde Secțiunile 4-5 cu o a doua axă de progresie_

### A. Ce ai deja, fără să știi că e un „stat system"

Cele 4 statistici din Secțiunea 5 — Intelect, Precizie, Reziliență, Claritate — sunt deja un sistem clasic de RPG, doar reflectat tematic în loc de etichetat generic:

| Stat-ul tău | Echivalent clasic | Sursă                       |
| ----------- | ----------------- | --------------------------- |
| Intelect    | INT               | Bibliotecă / Trivia         |
| Precizie    | DEX               | Fierărie / Logică           |
| Reziliență  | CON / VIT         | Atelier Alchimie / Anagrame |
| Claritate   | WIS / FOC         | Sanctuarul Ordinii / Sudoku |

Diferența față de STR/DEX/INT clasic: fiecare stat al tău explică DE CE există (Intelect vine din Trivia, pentru că ai memorat un fapt real) — un DEX generic dintr-un RPG clasic nu-ți spune nimic despre lume. Aș păstra numele tematice, dar decizia rămâne a ta — pot să le „traduc" 1:1 la STR/DEX/INT/CON/WIS dacă preferi convenția clasică, pentru familiaritate.

### B. Ce lipsea: Forță + Echipament

Ce nu aveai era o statistică și o progresie legate strict de ce GĂSEȘTI, nu de ce ÎNVEȚI. Propun:

**Forță — a 5-a statistică, exclusiv din echipament.** Nu se antrenează niciodată prin puzzle — crește DOAR prin arme sau armuri găsite ori forjate. Funcționează ca un multiplicator de daune, aplicat peste bonusul de disciplină (ex: un hit de bază de Trivia de 3 daune, cu +20% Forță din echipament, devine 4). Împarte clar lumea în două axe de progresie: mintea se antrenează în Cetate, trupul se echipează pe teren.

**3 sloturi de echipament**, găsite ca loot pe Hartă (fluxul deja descris în Secțiunea 5) sau forjate la **Fierărie** — care, la o recitire, chiar ar trebui să facă și asta: e un blacksmith, numele o cere.

| Slot        | Rol                                      | Exemplu                                                                                                                   |
| ----------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Armă**    | +Forță, uneori un efect ofensiv secundar | _Condeiul de Rezonanță_ — +3 Forță; 10% șansă ca un răspuns corect la Trivia să slăbească și atacul următor al inamicului |
| **Armură**  | +Reziliență, apărare                     | _Mantia Arhivarului_ — +3 Reziliență, +1 Scut la începutul fiecărei lupte                                                 |
| **Relicvă** | Efect unic, „build-defining"             | _Clepsidra Neclintită_ — +3 secunde la toate cronometrele de puzzle                                                       |

Fiecare piesă poate avea 2-3 nivele de upgrade la Fierărie (+1/+2/+3), consumând Minereu Runic suplimentar — un al doilea sink pentru resursa aia, în plus față de Precizie.

### C. O avertizare de scope

Aș evita un sistem complet D&D cu 6 statistici (STR/DEX/CON/INT/WIS/CHA) și formule derivate complexe (daune = STR × 1.5 + nivel etc.) — e complexitate care nu-ți servește jocul, doar îl încarcă la balansare, pentru un dev solo. 5 statistici (4 antrenate + Forță din echipament) și 3 sloturi dau deja senzația completă de „RPG cu progresie", fără un content pipeline mare: 12-15 piese de echipament bine gândite, combinate în 3 sloturi, dau destulă varietate de build-uri. Vizual, fiecare piesă e o singură iconiță într-un ecran de inventar — jucătorul nu trebuie să-și schimbe sprite-ul când echipează ceva, cel puțin nu de la început.

### D. Rarități — De la Comun la Legendar

Gruparea pe 3 nivele de complexitate — Comun/Neobișnuit = bonus static; Rar/Epic = mecanică secundară ușoară; Legendar = build-defining — e exact ce aș fi recomandat: 5 nume de raritate, pentru satisfacția de colecție, dar doar 3 șabloane de efect de construit efectiv, pentru un dev solo.

| Raritate   | Tip de efect                                  | Exemplu (Condei)                                                                  |
| ---------- | --------------------------------------------- | --------------------------------------------------------------------------------- |
| Comun      | Bonus static simplu                           | +1 Forță                                                                          |
| Neobișnuit | Bonus static, mai mare                        | +2 Forță                                                                          |
| Rar        | Bonus + mecanică secundară ușoară             | +3 Forță, +5% critic                                                              |
| Epic       | Bonus mare + mecanică secundară mai puternică | +5 Forță, +10% critic, −1s Recărcare                                              |
| Legendar   | Efect unic, „build-defining"                  | +8 Forță, +15% critic, „Primul răspuns corect din fiecare luptă e automat critic" |

Clepsidra Neclintită (Secțiunea 6B) rămâne reperul pentru ce înseamnă Legendar aici: nu „mai multe cifre", ci ceva care schimbă cum abordezi o luptă întreagă.

### E. Cum funcționează, exact — primele cifre de lucru

_(Cifrele de mai jos sunt un punct de plecare rezonabil, nu rezultat de playtesting — se rafinează la pasul „Balans & Progresie".)_

**Reguli de slot:**

- Exact 3 piese echipate simultan: 1 Armă + 1 Armură + 1 Relicvă. Nu poți purta 2 arme deodată.
- Restul găsit rămâne în inventar — schimbi loadout-ul doar din Cetate sau înainte de a intra pe un nod, niciodată în mijlocul unei lupte, ca să nu complice UI-ul de combat.
- Un duplicat găsit devine automat **Praf de Reforjare** — folosit ca discount la upgrade-uri la Fierărie, în loc să stea degeaba în inventar.

**Formula Forței:**

Daune Finale = Daune de Bază (Nivel Obelisc + Intelect) × (1 + 2 × Forță / 100)

Fiecare punct de Forță = +2% daune finale, aplicat ultimul, după orice alt bonus. Rotunjit la cel mai apropiat număr întreg.

**Arma (Forță) pe raritate** — cifrele din 6D, cu regula de upgrade adăugată:

| Raritate   | Forță de bază | Upgrade la Fierărie             |
| ---------- | ------------- | ------------------------------- |
| Comun      | +1            | +1 Forță / nivel (max 3 nivele) |
| Neobișnuit | +2            | +1 Forță / nivel                |
| Rar        | +3            | +1 Forță / nivel                |
| Epic       | +5            | +1 Forță / nivel                |
| Legendar   | +8            | +1 Forță / nivel                |

**Armura (Reziliență) pe raritate** — 1 punct de Reziliență = +2 PV maxime:

| Raritate   | Reziliență | Efect secundar                                         |
| ---------- | ---------- | ------------------------------------------------------ |
| Comun      | +1         | —                                                      |
| Neobișnuit | +2         | —                                                      |
| Rar        | +3         | +1 Scut la începutul luptei                            |
| Epic       | +5         | +2 Scut la începutul luptei                            |
| Legendar   | +8         | „Primul atac primit în fiecare luptă e complet blocat" |

**Relicva** rămâne intenționat în afara acestui tipar — n-are un stat fix de scalat, exact pentru că rolul ei e să fie diferită de fiecare dată, nu previzibilă.

**Exemplu complet:** Jucător cu 6 Intelect, poartă un Condei Epic (+5 Forță, neupgradat). Activează un Obelisc de Nivel II (bază 5 daune): 5 (bază) + 6 (Intelect) = 11 daune înainte de Forță → 11 × 1,10 (10% din +5 Forță) = 12,1 → **12 daune finale**.

---

## 7. Inamici — Sistem Generativ, nu Bestiary Scris de Mână

Problema pe care o rezolvă: un joc jucat zilnic, ani de zile, ar cere sute de inamici scriși manual plus conținut adăugat săptămânal — un model de live-service, imposibil pentru un dev solo. Soluția e aceeași care face deja puzzle-urile ieftine: **generare, nu enumerare.**

### Arhetipuri

Un arhetip e **regula centrală după care se poartă inamicul** — ce te forțează să joci altfel. Nu specia, nu aspectul, nu povestea.

| Arhetip     | Regulă                                                        | Te forțează să...                            |
| ----------- | ------------------------------------------------------------- | -------------------------------------------- |
| **Barieră** | O disciplină nu face daune până nu spargi scutul cu alta      | ...nu începi cu piesa preferată              |
| **Grabnic** | Ceas scurt, atac devastator la capăt                          | ...lovești tare și repede, fără combo lung   |
| **Oglindă** | Pedepsește activarea aceleiași discipline de două ori la rând | ...rotești disciplinele                      |
| **Sifon**   | Se vindecă la fiecare greșeală sau timeout                    | ...activezi doar ce știi sigur               |
| **Corupt**  | Își schimbă vulnerabilitatea în fiecare rundă                 | ...reevaluezi constant, nu planifici înainte |

**Testul pentru un arhetip valid:** dacă îl scot, dispare vreo decizie? Un inamic cu mai multe PV nu trece — joci la fel, doar mai mult. Sifonul trece.

### Modificatori

Un strat deasupra: ajustări mai mici, lipite pe orice arhetip — „+50% PV", „prima rundă ai doar 2 PA", „daunele de Trivia înjumătățite", „vulnerabil la Ordine". Nu redefinesc lupta, o înclină.

Din ~10 arhetipuri × ~10 modificatori ies sute de comportamente distincte, din câteva zeci de reguli scrise o singură dată. Un inamic devine, de exemplu: **Grabnic + barieră pe Sudoku + 30% mai puține PV**.

### Generatorul

- **Când:** o dată, la generarea expediției — nu zilnic, nu la intrarea în luptă. Reintri în același nod, întâlnești același inamic. Predictibil în interiorul unui run, diferit între run-uri.
- **Buget de dificultate** în funcție de adâncimea nodului și progresul jucătorului. Buget mic = arhetip simplu, fără modificatori. Buget mare = arhetip + 2 modificatori.
- **Reguli de excludere**, ca să nu iasă combinații stupide sau nedrepte: fără barieră și vulnerabilitate pe aceeași disciplină, fără două arhetipuri care ambele accelerează ceasul.
- **Conștient de loadout:** generatorul știe ce 3 discipline ai echipat. Poate garanta că cel puțin un nod cere disciplina lipsă (ca supapa pentru disciplina lipsă să conteze, când va exista) — dar niciodată toate, altfel devine pedeapsă, nu tensiune.
- **Seed fixat per expediție** — permite reproducerea exactă a unui run la debugging, și deschide gratuit un mod „provocarea zilei" (toți jucătorii, aceeași hartă).

### Aspectul se decuplează de reguli

Numele și sprite-ul se aleg separat, dintr-un set potrivit zonei hărții. Același arhetip Sifon poate fi un Gargui în zona de piatră și o Umbră în bibliotecă. Jucătorul vede varietate; tu ai scris o regulă.

### Boșii rămân scriși de mână

5-6 lupte manuale, cu reguli proprii și dramă vizuală, ca momente memorabile ale campaniei. Inamici obișnuiți generați, boși autentici — cel mai bun raport efort/impact.

### Notă despre rejucabilitate

Cantitatea de conținut rezolvă doar repetiția, și numai pentru Trivia (celelalte 3 discipline se generează procedural — practic infinite din prima zi). Riscul mai mare e ca **decizia** să devină plictisitoare înainte să se termine conținutul. De aceea contează, în ordine: (1) varietatea inamicilor ca reguli, nu ca sprite-uri; (2) build-uri care se joacă diferit; (3) dificultate care crește odată cu jucătorul — un avantaj specific acestui joc, unde progresul real al persoanei devine curba de dificultate.

Și un lucru care nu se epuizează niciodată: în Slay the Spire, când ai văzut toate cardurile, jocul s-a terminat. Aici „conținutul" e cunoașterea umană — istorie, știință, artă, mitologie. Există mereu un motiv real de revenire, chiar și când mecanica devine familiară.

**Pentru prototip:** nu construi generatorul. Codează manual 3 inamici — unul simplu (baseline), unul Barieră, unul Grabnic — și verifică dacă arhetipurile chiar se simt diferit. Generatorul are sens abia după ce știi că piesele merită combinate.

---

## 8. Cele Două Moduri de Joc

_Adăugat după revizuirea taxonomiei de brain training_

Cronometrul de 12-15 secunde e coloana vertebrală a campaniei — dar exclude o categorie întreagă de provocări valoroase: Sudoku, puzzle-uri de traversare, probleme de resurse, planificare în mai mulți pași. Nu încap în 15 secunde, și nu e o problemă de design: sunt pur și simplu un alt tip de gândire.

Soluția: două moduri, cu reguli de timp diferite.

|                | **Campanie**                        | **Turnul Perseverenței**                                  |
| -------------- | ----------------------------------- | --------------------------------------------------------- |
| Timp           | Cronometru strict, 12-15s           | Fără limită de timp                                       |
| Testează       | Recuperare rapidă sub presiune      | Gândire susținută, planificare                            |
| Conținut       | Cele 8 discipline, provocări scurte | Sudoku, probleme de resurse, puzzle-uri în mai mulți pași |
| Structură      | Expediții pe hartă, Obeliscuri, PA  | Etaje succesive, dificultate crescătoare                  |
| Sesiune tipică | 15 minute, zi aglomerată            | O seară liberă, afundare                                  |

**De ce ambele.** Cognitiv, acoperă lucruri diferite: campania antrenează viteza de recuperare, Turnul antrenează răbdarea și urmărirea mai multor constrângeri deodată. Pentru un joc gândit ca antrenament zilnic, acoperirea devine completă. Practic, se pliază pe ritmul real al vieții — 15 minute când n-ai timp, o oră când ai.

**Economie comună.** Turnul dă aceleași resurse ca expedițiile, nu o monedă proprie. Altfel devin două jocuri care nu se ating; cu economie comună, fiecare mod e un motiv să-l joci pe celălalt.

**Nu construi Turnul acum.** E un mod întreg, cu propriile reguli de progresie și propriul UI. Campania nu e completă — lipsesc harta, Cetatea, save-ul, 6 din 8 discipline. Turnul vine după.

**Ce trebuie făcut ACUM, însă:** fiecare provocare are nevoie de un câmp care spune unde poate apărea (`campanie`, `turn`, sau `ambele`). Sudoku e `turn`, trivia e `ambele`. Costă o linie acum, evită reetichetarea a mii de intrări mai târziu.

---

## 9. Formatul Bazei de Date

_Principiul central: Domeniu × Mecanică × Dificultate_

Același principiu care face inamicii ieftini (arhetip × modificator) se aplică și conținutului: varietatea vine din combinații, nu din enumerare. Aceeași mecanică („găsește intrusul") funcționează cu cuvinte, forme sau simboluri — trei provocări distincte dintr-un singur generator.

Câmpurile pe care le merită fiecare provocare, de la început:

```
id
disciplina          # una din cele 8 (Obeliscul de care aparține)
domeniu             # istorie, geografie, fizică, vocabular...
mecanica            # quiz, pattern, match, sort, memory, visual, logic_puzzle, rapid_calc
dificultate         # 1-3 (nivelul din lanțul de combo)
mod                 # campanie | turn | ambele
intrebare
optiuni
raspuns_corect
timp_limita
explicatie
abilitate_cognitiva
asset_vizual        # opțional
```

**De ce toate acum, chiar dacă nu le folosești.** `mecanica` și `abilitate_cognitiva` nu fac nimic azi, dar fac posibile mai târziu modul de antrenament liber (filtrare fină) și statisticile din Cetate (Intelect, Precizie, Reziliență, Claritate se calculează din ele). Adăugarea unui câmp acum costă o linie; reetichetarea a 2000 de întrebări costă o săptămână.

**Antrenament liber** — mod secundar, fără luptă, unde alegi exact ce exersezi (doar geografie, doar procente, doar memorie vizuală). Nu cere conținut nou sau generatoare noi: e un filtru peste aceeași bază de date, plus un ecran de selecție. Servește direct scopul declarat al proiectului — dacă profilul tău arată slab la Spațial, îl lucrezi fără presiunea unui run.

**Ce NU adoptăm: dashboard-ul de profil cognitiv.** Un ecran cu procente pe opt abilități e exact aspectul de aplicație educațională pe care wrapper-ul trebuie să-l ascundă. Ideea de sub el există deja în joc, în forma corectă: cele patru statistici din Cetate SUNT un profil cognitiv, exprimat ca stat-uri de RPG.

---

## Glosar Rapid

- **Cetatea** — baza / Town-Hub a jucătorului. _(nume provizoriu, până se decide tema)_
- **Fragmente** — moneda principală a jocului. _(nume provizoriu)_
- **Obelisc** — poziție fixă pe câmpul de luptă care, activată, declanșează un puzzle dintr-o disciplină specifică.
- **PA (Puncte de Acțiune)** — resursa cheltuită pentru activarea Obeliscurilor.
- **PV (Puncte de Viață)** — viața unei unități (jucător sau inamic).
- **Recărcare** — perioada în care un Obelisc folosit nu poate fi reactivat.
- **Claritate** — stack acumulat din răspunsuri corecte consecutive; oferă bonusuri crescânde.
- **Scut** — strat temporar care absoarbe daune.
- **Jurnal** — registrul permanent de fapte reale, învățate în joc. _(nume provizoriu)_
- **Forță** — a cincea statistică; crește exclusiv din echipament, niciodată prin puzzle-uri; multiplică daunele finale.
- **Echipament (Armă / Armură / Relicvă)** — cele 3 sloturi de gear, găsite ca loot pe Hartă sau forjate la Fierărie.
- **Raritate** — nivelul de putere al unei piese de echipament: Comun, Neobișnuit, Rar, Epic, Legendar.
- **Fântâna** — a cincea locație din Cetate; o dată pe zi, riști resurse în exces + un puzzle rapid pentru șanse mai mari la echipament Rar/Epic/Legendar. _(nume provizoriu)_
- **Praf de Reforjare** — obținut din piese de echipament duplicate; reduce costul upgrade-urilor la Fierărie.
- **Arhetip** — regula centrală după care se poartă un inamic în luptă (Barieră, Grabnic, Oglindă, Sifon, Corupt).
- **Modificator** — ajustare mai mică, lipită peste un arhetip (+PV, vulnerabilitate, PA redus în prima rundă).
- **Cele 8 discipline** — Cultură generală, Logică, Cuvinte, Numere, Reținere, Tipare, Spațial, Reflex. Fiecare cu simbol propriu și rol tactic distinct.
- **Rol tactic** — ce face o disciplină în luptă dincolo de daune (multi-hit, crit, ignoră armura, încărcare). Motivul pentru care alegi o disciplină chiar dacă nu e punctul tău forte.
- **Campanie** — modul principal: expediții pe hartă, cronometru strict de 12-15s.
- **Turnul Perseverenței** — mod secundar, fără limită de timp: Sudoku, probleme, puzzle-uri în mai mulți pași. Economie comună cu campania.
- **Antrenament liber** — mod fără luptă, unde alegi exact ce categorie exersezi. Filtru peste baza de date existentă.

---

## Notă Tehnică — Realism pentru un Dev Solo

Fiecare disciplină (Trivia, Sudoku, Anagramă, Logică) poate fi construită ca o scenă/prefab independentă, cu o interfață minimă și identică față de restul jocului: primește un nivel de dificultate, returnează succes/eșec + scor. Combat Controller-ul nu are nevoie să știe nimic despre cum arată un Sudoku pe interior — doar cheamă scena și așteaptă rezultatul. Practic, poți construi și lustrui **un singur** tip de puzzle complet funcțional, îl testezi în luptă, și abia apoi adaugi următoarele trei, fără să rescrii sistemul de luptă de fiecare dată.

**Recomandarea mea pentru primul prototip jucabil:** nu construi toate cele 4 discipline deodată. Pornește doar cu **Trivia** — cel mai simplu de implementat (UI de întrebare/răspuns + cronometru) — legată direct de sistemul de PA și Obeliscuri, ca să validezi rapid dacă bucla de luptă e distractivă, înainte să investești timp în celelalte trei tipuri de puzzle, fiecare cu UI-ul lui propriu.

**Un avertisment real de designer:** un joc bazat pe Trivia are nevoie de mult conținut — sute, apoi mii de întrebări — ca să nu se repete rapid. Merită gândită din timp o strategie de conținut: scris manual, treptat, pe categorii (mai ușor de gestionat solo dacă începi restrâns — ex. doar Istorie și Geografie — și extinzi), sau o bază de date/API de întrebări pe care o filtrezi și adaptezi tu. E o discuție bună pentru un pas viitor al GDD-ului.

**De ce rămânem la 4 discipline, nu mai multe — deocamdată:** cele 4 acoperă deja tipuri de gândire genuin diferite — memorie declarativă (Trivia), logică spațială (Sudoku), procesare verbală (Anagramă), deducție secvențială (Logică) — nu sunt patru variații ale aceluiași lucru. O a 5-a înseamnă UI nou + generare nouă +, probabil, o clădire și o statistică noi peste tot ce există deja. Pentru senzația de „mereu altceva" pe termen lung, varietate ÎN interiorul celor 4 (categorii de Trivia rotative, formate multiple de Logică, grid-uri Sudoku de mărimi diferite) costă mult mai puțin decât o disciplină complet nouă și rezolvă aceeași problemă. Rămâne o idee bună ca update post-lansare, după ce bucla de bază e validată ca distractivă — cel mai bun candidat ar fi ceva bazat pe memoria de lucru, nu declarativă: un „Obelisc al Ecoului", unde un pattern apare scurt și trebuie reprodus din memorie. Se generează 100% procedural, deci scapă de problema de content pipeline pe care o are Trivia.

---

## Pașii Următori Recomandați

1. **Balans & Progresie** — curbele statistice, scalarea dificultății, economia de resurse.
2. **Catalogul de Puzzle-uri** — regulile exacte pentru fiecare disciplină + strategia de conținut pentru Trivia.
3. **Structura Hărții/Run-urilor** — tipuri de noduri, lungimea unei expediții, generare procedurală.
4. **Meta-Progresia pe Termen Lung** — ce te ține în joc peste săptămâni/luni (talente, boss-uri rotative).
5. **Direcția Artistică & UI/UX** — mood board, paletă de culori, wireframe-uri pentru Cetate și Luptă.

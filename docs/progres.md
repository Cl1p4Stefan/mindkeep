# MINDKEEP — Jurnal de progres

*Ultima actualizare: 10 septembrie 2026*
*Atașează acest fișier la începutul fiecărei sesiuni noi, împreună cu `CLAUDE.md` și `docs/pitch-document.md`.*

---

## Unde suntem în ruta de construcție

| Pas | Stare |
|---|---|
| 1. Setup, Git | ✅ gata |
| 2. Scena de luptă cu placeholdere | ✅ gata |
| 3. Trivia, ca scenă independentă | ✅ gata |
| 4. Bucla completă a unei lupte | 🟡 victorie ✅ · înfrângere și recompense ❌ |
| 5. Trei inamici manuali | 🟡 doi arhetipi scriși, un singur inamic activ |
| 6. Harta de expediție | ❌ |
| 7. Cetatea | ❌ |
| 8. Save/Load | ❌ |
| 9. Celelalte discipline | 🟡 Logica ✅ · Memorie și Cuvântul Adevărat ❌ |
| 10–13. Generator de inamici, artă, web | ❌ (artă parțial: figurile principale au imagini reale) · Regina: **amânată**, vezi CLAUDE.md |

Am sărit peste ordinea recomandată la pasul 12 (artă): imaginile pentru rege și
cavaler au intrat mai devreme, dar restul rămâne placeholder. Bucla de luptă e
în continuare cea validată, nu arta.

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

Sesiunea de azi e dovada: semnalul de critic a fost o schimbare de UN concept,
aplicată prin script în două fișiere deodată ca să nu diveargă. A doua oară n-o
să mai am noroc. Ambele sesiuni de până acum au mărit datoria, nu au scăzut-o.

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

## Fișiere adăugate în această sesiune

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

# MINDKEEP — Jurnal de progres

*Ultima actualizare: 27 octombrie 2026*
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
| 6. Harta de expediție | ✅ loadout „N din M" · **12-16 noduri**, ramificate, cu sămânță · Luptă / Elită / Odihnă / Eveniment / **Magazin** / **Boss** · **Monede + puteri temporare** · sumar de run · aspect: pergament, simboluri de cerneală, trasee punctate · **nodurile și drumurile stau pe o PANGLICĂ (curbă centrală + benzi)**, nu pe o grilă dreaptă · **patru trasee, toate verzi pe 300 de semințe** (POTCOAVĂ activă; POTCOAVA OGLINDITĂ e aceeași formă, întoarsă) · strat înclinat (forfecare) la ȘARPE · **drumuri care nu se încrucișează niciodată (0 la 300 de semințe)** · **nodul curent are și aură, și X, și stă nemișcat sub figurină** · **două surse de hartă: GENERATĂ (panglica) sau DESENATĂ dintr-un fișier `data/harti/*.json`** — comutatorul `Expeditie.SURSA_HARTII`; azi e pe DESENATĂ · **harta umple pergamentul**: pânza ține toată pagina, antetul plutește peste ea (805 × 427 px de hartă, de la 666 × 353) · **drumurile merg în amândouă sensurile**, cu nodul parcurs tăiat definitiv și cu garanția, verificată pe 16 000 de expediții simulate, că nu te poți înfunda · **figurina sare, cade ca un slam și zguduie ecranul la aterizare**, cu un răgaz de 0,5 s înainte să se deschidă nodul · **tipurile nodurilor se împart după o REȚETĂ fixă, nu se trag cu zarul**: 11 reguli de vecinătate, de început și de FINAL, printre ele **o podea de 3 lupte pe cel mai ieftin drum Start → Boss** (21 octombrie), plasare conștientă de reguli, verificare completă și reîncercare cu sub-sămânță (0 eșecuri pe 500 de semințe × 3 surse de hartă) · **la cel mult 2 pași de Boss e garantat un nod de bătaie** (100% pe 300 de semințe × 3 surse, de la 85% / 96% / 81%) · **niciun nod special nu mai are un geamăn lipit**, nici Evenimentul (0 pe 900 de hărți) · **rețeta nu se mai crede pe cuvânt: se PROBEAZĂ** — plafonul comun încearcă plasarea adevărată și taie un nod când forma nu le încape pe toate · rețeta se **plafonează după forma hărții**, nu după numărul de noduri · **nodul de Eveniment deschide Lacătul** (nivel din adâncime, sămânță din nodul, 6/10/14 Monede la succes) |
| 7. Cetatea | ❌ |
| 8. Save/Load | ✅ **pe disc**, de pe 12 octombrie 2026. `autoload/arhiva.gd` — singurul fișier din joc care atinge discul, fără nicio regulă de joc în el; dependența merge într-un singur sens (apelurile de salvare stau în SCENE, ca uneltele de verificare să rămână uscate) · **două fișiere în `user://`**: `permanent.json` (Tezaur + progresul din Antrenament + sacurile permanente) și `expeditie.json`, care există doar cât e un run viu · **scriere prin fișier temporar și redenumire**, cu adoptarea unui `.nou` orfan la citire · **`versiune` în save**: mai vechi se citește prin `_migreaza()`, mai nou se pune deoparte · **un fișier ilizibil nu se șterge și nu se suprascrie** — se redenumește `*.stricat.json` (cu data în nume dacă e deja unul pus deoparte), iar meniul o spune, cu mesaje separate pentru progres și pentru expediție · **butonul din meniu devine „Continua expeditia"**, cu nodurile în urmă și PV-ul pe rândul de sub el · **sacul are acum DURATĂ pe cheie** (`Sac.Durata`): rafturile din Practice sunt permanente, sacurile de luptă rămân pe expediție · **nodul se scrie pe disc la INTRARE**, deci a apărut `nod_nerezolvat` și coloana `reluabil` din `DATE_NOD` — altfel o luptă întreruptă era sărită, iar la Boss era chiar victorie · 54 de verdicte în `verifica_salvarea`, ~1 s · vezi sesiunea SAVE
| 9. Celelalte discipline | 🟡 Cultură generală ✅ (**4731 de întrebări în joc, toate**: 3417 scrise de mână (`mana:0001`…, dintre care **600 de științe exacte**, `mana:2143`…`mana:2742`, **375 de Diverse**, `mana:2743`…`mana:3117`, și **300 de Istorie și societate**, `mana:3118`…`mana:3417`, toate pe 27 octombrie; vezi DIVERSE, +375 și ISTORIE ȘI SOCIETATE, +300) + **69 fabricate, elemente chimice** (`wd:Q556:simbol:…`; un singur sens pe element de pe 27 octombrie, vezi UN SENS PE ELEMENT) + **160 fabricate, operă → autor** (`wd:Q12730777:autor:…`) + **251 fabricate, țară ↔ capitală** (`wd:Q142:capitala:…`) + **147 fabricate, lucrare ↔ compozitor** (`wd:Q11980:compozitor:…`) + **687 fabricate de Divertisment și Sport** (27 octombrie: 203 film → regizor, 156 album → interpret, 143 de fotbal, 27 de Jocuri Olimpice, 158 de Formula 1; vezi DIVERTISMENT ȘI SPORT DIN FABRICĂ) — **conținutul fabricat stă într-un DOSAR**, `data/trivia_gen/`, citit întreg de încărcător: un tabel nou = două fișiere, zero linii de cod · **3413 fapte, TOATE cu notă** (cele 600 de științe exacte, cele 375 de Diverse și cele 300 de istorie au venit cu nota lor) (503 fabricate din șabloane: la elemente **la ce folosește elementul** (o propoziție scrisă de mână pe element, coloana `folosinta`, de pe 21 octombrie) plus simbolul și numărul atomic, anul apariției și anii autorului la opere, descrierea țării la capitale, anii compozitorului la lucrările muzicale · 92 scrise mai devreme de mână · **2046 scrise de mână în sesiunea TOATE AU NOTĂ**, câte una pentru fiecare întrebare rămasă fără) — deci **4731 din 4731 de întrebări ajung la o notă, de la 96 dimineață**, fiecare domeniu și fiecare dintre cele 31 de rafturi; sursa celor 2046 sunt EU, nu un tabel, deci nu le poate bate niciun validator și singura verificare e citirea (28 citite din 2142), iar un validator cere ca fiecare cifră și fiecare nume propriu dintr-o notă să existe în datele sursă · **OPT DOMENII** (Geografie și explorare, Istorie și societate, Știință și tehnologie, Artă și literatură, Divertisment și media, Sport și jocuri, Gastronomie și lifestyle, Diverse și curiozități), cu **31 de subcategorii** — **toate OPT domeniile sunt în luptă, niciunul din cele 31 de rafturi nu e gol și nicio întrebare nu e fără raft** (cele 135 scrise înaintea câmpului au fost clasificate, iar 21 de întrebări de mitologie au trecut de la Artă la Istorie); **toate cele 93 de celule (subdomeniu × nivel) au cel puțin 25 de întrebări** — treapta CONFORT din `plan-continut.md`, cea la care 4-5 expediții lungi nu repetă nimic; drumul până la 100 pe celulă cere încă 6631 și trece prin fabrică, nu prin scris de mână, tăiate după cum se joacă, nu după cum crescuse baza: artă + mitologie + literatură s-au unit, Divertisment și Sport pornesc goale · `CATEGORII` (listă) a devenit `DOMENII` (dicționar cheie → nume afișat), deci antetul scrie „ARTĂ ȘI LITERATURĂ”, nu cheia · **alegerea din luptă e în două trepte** — întâi domeniul, uniform, apoi întrebarea, cu sacul pe cheie de domeniu ȘI nivel — iar de azi **domeniul intră doar peste `PRAG_DOMENIU = 8` întrebări pe celulă**, cu plasă dacă nu trece niciunul; sub prag e sărit, nu golit (istoria trecea cu rezerva ZERO și era următoarea țintă de conținut; de pe 27 octombrie are 200 pe fiecare nivel) · comutator `FOLOSESTE_WIKIDATA` · **fabrica are un modul comun**, `tools/fabrica/comun.py`, iar grila marchează celulele sărite · **faptele capitalelor au o LISTĂ de imagini**, `imagini: [{tip, …}]`: **126 de steaguri pe disc** (`assets/imagini_fapte/steaguri/`, PNG 320 px, 0,53 MB sursă, toate în domeniul public, cu manifest de credite), plus o intrare de hartă pe fiecare din cele 127 de fapte; Omanul e singurul refuzat, cu motivul scris · **fiecare întrebare are și o `subcategorie`**, una singură, din listă închisă pe domeniu (36 de chei, 4 folosite; la istorie sunt erele, tăiate pe dată) — cele 135 scrise de mână o primesc într-un lot de clasificare, cu un clichet în verificator · **istoria e la 200 pe fiecare nivel**, câte 150 pe fiecare din cele patru rafturi (vezi ISTORIE ȘI SOCIETATE, +300), iar **Divertismentul și Sportul au câte 50 pe fiecare celulă**, pe 11 subcategorii cu care se poate filtra (filme 48, muzică 36, fotbal 30, olimpiade 30…) — deci **toate ȘASE domeniile sunt în luptă**, fiecare cu 1/6 din întrebări, și toate cele 11 subcategorii ale celor două domenii noi au conținut · **verificarea e un singur câmp**, `verificat: true/false` pe întrebare, pus de mână: întrebarea intră în joc oricum, iar flagul spune doar dacă i-am citit nota. Niciun script, niciun parametru — mecanismul de ciorne, al doilea flag de pe fapt și cele două unelte de confirmare s-au desfăcut (vezi UN SINGUR FLAG) · planul de conținut al tuturor celor șase domenii, cu subcategorii, tabele propuse și capcanele lor, e în **`docs/plan-continut.md`** · vezi sesiunile UN SINGUR FLAG, ȘASE DOMENII ÎN LUPTĂ, PLANUL ȘI CIORNELE, DOMENIILE, CONȚINUTUL, ID ȘI FAPT, FABRICA, AL DOILEA TABEL, MODULUL COMUN și STEAGURILE) · Logica ✅ (80 de categorii) · Cuvinte ✅ · toate trei fără repetiții pe expediție, **Cultura generală după `id`, nu după text** · celelalte 5 ❌ |
| 10–13. Generator de inamici, artă, web | ❌ (artă parțial: figurile principale și piesele de pe butoanele de Obelisc au imagini reale · **arena are fundal: biblioteca gotică**, cu personajele așezate pe dalele din prim-plan, umbră de contact și lumină de sală) · Regina: **amânată**, vezi CLAUDE.md · **pasul 13 (Practice) — prima felie ✅**: **meniu de start** (`scenes/meniu/`, de azi `run/main_scene`) cu două butoane, și **Antrenament liber** (`scenes/practice/`) — alegi domeniul, apoi raftul, din `DOMENII` și `SUBCATEGORII`, cu o iconiță și nivelul pe fiecare domeniu și rafturile goale stinse („gol la nivelul II”); întrebările vin prin **chiar scena de trivia a luptei**, fără cronometru (`cu_cronometru`, două linii în `puzzle.gd`); nivel pe DOMENIU, urcat singur la `PRAG_PRACTICE` = 60 de întrebări distincte știute; sac propriu, pe cheie cu filtru (`practice:<domeniu>:<raft>:<nivel>`); progres scris pe disc de la Save (12 octombrie), în `permanent.json` · **„Afla mai multe" ✓** (12 octombrie): după fiecare răspuns, corect sau greșit, un buton deschide nota faptului, citită din `explicatie` (contractul cu `puzzle.gd`), nu din `TRIVIA.fapte`; **de pe 21 octombrie butonul e un CREIER în colțul chenarului**, stins până la verdict și aprins când există notă — de azi apare la **TOATE cele 2839 de întrebări** (era 1 din 28 dimineață, apoi 1 din 3,6); imaginea din popup e felia următoare · **neștiutele întâi ✓** (21 octombrie): greșitele revin la distanță, iar raftul știut tot se anunță o singură dată și apoi poartă „Nivel I · 100%" în lista de rafturi · **trecerea singură ✓** (21 octombrie): după un răspuns CORECT, „Următoarea" se umple în 2 s și trece fără click; o oprește doar apăsarea creierului (sau un anunț), iar la greșit nu curge nimic · **pergament în bibliotecă ✓** (21 octombrie): o temă comună (`assets/tema/pergament.tres`), fonturile Cinzel + Alegreya (OFL) și biblioteca din luptă estompată ca fundal; scena de trivia se îmbracă singură în Practice și rămâne neschimbată în luptă · **meniul în bibliotecă ✓** (22 octombrie): aceeași temă, biblioteca abia estompată, două pagini (figurina, creierul), intrare scurtă și praf în lumină · **iconițe pictate ✓** (23 octombrie): domeniile și creierul sunt PNG-uri colorate (generate cu AI, decupate, 256 px), nu SVG-uri albe vopsite de temă · vezi sesiunile ICONIȚE PICTATE, MENIUL ÎN BIBLIOTECĂ, MENIUL ȘI PRACTICE, AFLĂ MAI MULTE, TOATE AU NOTĂ, RAFTUL PARCURS, TRECEREA SINGURĂ, PERGAMENT ÎN BIBLIOTECĂ, ICONIȚE PE DOMENII și CREIERUL DIN CHENAR |

Nodul de **Eveniment** are primul lui conținut: **Lacătul** — un cufăr cu cifru,
dedus din indicii, cu artă adevărată (roți care se învârt în spatele
ferestrelor, cufăr care se deschide). Dificultatea lui nu e presupusă, ci
**măsurată**: un rezolvitor separat deduce codul ca un om și spune de ce tehnică
a fost nevoie, iar generatorul păstrează doar puzzle-urile cu nota cerută de
nivel. Verificat pe 180 de puzzle-uri, **60/60 pe fiecare nivel nimeresc nota**.
**De azi e legat de hartă**: nodul de Eveniment îl deschide peste pergament, cu
nivelul din adâncimea nodului și sămânța din sămânța nodului, iar un cufăr
deschis plătește în Monede (vezi sesiunea EVENIMENTUL DESCHIDE CUFĂRUL).

Din pasul 10 (generatorul de inamici) s-a făcut deja partea care nu costa nimic
azi: **identitatea inamicului e separată de arhetip**. Restul (modificatori,
buget, generare) rămâne acolo unde era.

Am sărit peste ordinea recomandată la pasul 12 (artă): imaginile pentru rege,
cavaler și pentru cele trei piese de șah de pe butoane au intrat mai devreme, dar
restul rămâne placeholder. Bucla de luptă e în continuare cea validată, nu arta.

---

## ISTORIE ȘI SOCIETATE, +300 (27 octombrie 2026) — de la 300 la 600, scrise de mână

### Cererea

*„genereaza 300 de intrebari pentru domeniul «istorie si societate» (cate 75 pentru
fiecare subdomeniu). Noile intrebari generate sa nu coincida cu intrebarile curente
din domeniul «istorie si societate»”*.

### Ce s-a făcut

- **300 de întrebări noi**, `mana:3118`…`mana:3417`, toate `istorie`, toate
  `verificat: false`, fiecare cu nota ei în `fapte_trivia.json` (`fapt` = propriul
  `id`, ca la ȘTIINȚE EXACTE, 600 și la DIVERSE, +375). Ordinea în fișier: nivelul
  I (toate patru rafturile), apoi II, apoi III.
- Domeniul trece de la **100 / 100 / 100** la **200 / 200 / 200**, iar fiecare
  raft de la 75 la **150**, câte 50 pe nivel. E singurul domeniu cu grila
  perfect plină: 75 cerute × 4 rafturi, împărțite 25 pe celulă.
- Diff-ul e **numai inserții** la coada celor două fișiere de date.
  `CATE_INTREBARI_MANA`: 3117 → 3417.

Ce acoperă:

| raft | ce intră |
|---|---|
| antichitate_ev_mediu | Roma (Senat, sclavi, togă, apeduct, forum, Circ), Grecia (Termopile, Salamina, războiul peloponesiac), Egipt (faraon, mumificare, piramidă), viața feudală (vasal, zeciuială, breslele, turnir, pod mobil), biserica apuseană (Worms, dominicanii, templierii, Clermont), bătălii (Teutoburg, Cannae, Adrianopol, Grunwald, Hattin, Crécy, Rovine), state și popoare (ostrogoți, longobarzi, mameluci, olmeci, Mali, Moldova lui Bogdan), instituții otomane (devșirme, timar) |
| modern_contemporan | revoluțiile (1789, ghilotina, republica), cele două războaie mondiale (tranșee, tanc, gaze, Barbarossa, Stalingrad, Potsdam, Nürnberg), Războiul Rece (cortina de fier, Tratatul de la Varșovia, blocada Berlinului, Suez, 1956, Praga, Helsinki, Afganistan), istoria românească (1821, 1864, 1877, Plevna, 1907, Bucovina, 1812, Convenția de la Paris, Dictatul de la Viena, datoria externă), tratate și păci (Augsburg, Nantes, Karlowitz, Kuciuk-Kainargi, Brest-Litovsk, Ribbentrop-Molotov, Roma) |
| lideri_personalitati | conducători (Lenin, Hrușciov, Brejnev, Elțîn, Reagan, Nixon, Obama, Nasser, Cromwell, Henric IV, Puyi, Leopold II, Shaka), români (Decebal, Ferdinand, Carol II, Antonescu, Gheorghiu-Dej, Maniu, Avram Iancu, Bălcescu, Kogălniceanu, Ecaterina Teodoroiu, regina Maria, Saligny, Vlaicu, Paulescu, Racoviță, Palade, Ana Aslan, Elisa Leonida Zamfirescu), exploratori (Marco Polo, Pizarro, Diaz, Livingstone, Scott, Franklin, Leif Eriksson), femei (Ioana d'Arc, Elisabeta II, Maica Tereza, Maria Antoaneta, Nightingale, Eva Perón, Diana, Hatșepsut, Tereșkova, Earhart, Bandaranaike) |
| mitologie_religii | mitologia greacă (Hades, Apollo, Demetra, Olimp, Icar, Atlas, Cronos, Narcis, Midas, Dedal, Caron, Hidra, Pegas, Tartar, Hecate, Nemesis, Erinii, Asclepios), romană (Jupiter, Cupidon, lari, Mithra), nordică (Frigg, valkirii, Baldr, Sleipnir, Bifrost, asi și vani), egipteană (Osiris, Thot, Maat, Cartea Morților), mesopotamiană (Iștar, Enuma Eliș), religii (Șabat, Rusalii, Hajj, Talmud, Cabala, hadith, sunniți și șiiți, Calcedon, jainism, șintoism, Avesta, Popol Vuh), folclor românesc (zmeul, ielele, apostolul Andrei) |

### „Să nu coincidă”: ce s-a verificat, și de ce n-a fost destul domeniul

Cererea spunea „să nu coincidă cu întrebările din domeniul istorie”, dar lotul a
fost bătut contra **întregii baze de 4431**, și bine că așa: toate cele **31 de
dubluri reale** găsite erau în ALTE domenii, niciuna în istorie. Un fapt nu știe
pe ce raft l-am pus: „cine a ajuns primul la Polul Sud” e în istorie, iar
„Lalibela”, „Platon”, „Sfinxul”, „telegraful”, „Hanuka”, „Crăciunul” și
„hinduismul în India” stăteau în geografie, artă, știință și gastronomie.

Un script de lot (în scratchpad, nu în `tools/`) a cerut patru lucruri:

1. **text identic sau foarte apropiat** (potrivire pe cuvinte, peste 60%);
2. **același răspuns corect** cu text apropiat — și, separat, o listă fără prag a
   TUTUROR întrebărilor din bază cu același răspuns, citită cu ochiul: acolo s-au
   văzut cele mai multe dubluri, fiindcă două întrebări despre același fapt
   aproape niciodată nu seamănă la cuvinte;
3. **răspunsul în propriul text**, cu chiar funcția din `verifica_trivia`;
4. **nota care dă răspunsul altei întrebări** — a prins o duzină de scăpări
   (Churchill de două ori, Tratatul de la Varșovia, Coreea, Valea Regilor,
   Alhambra, Himera, Lenin, Poarta Brandenburg, regina Victoria, ielele), toate
   rescrise. Verdictul brut al probei ăsteia e plin de zgomot — orice notă care
   pomenește Franța „dă răspunsul” unei întrebări de geografie — deci lista se
   citește cu numele de țări și de orașe filtrate, nu se bifează.

Dublurile n-au fost șterse, ci **înlocuite**, ca lotul să rămână 75 pe raft.

### Notele: regula care a cerut 131 de rescrieri

Prima scriere a notelor a călcat **regula 1 din `ghid-note.md`** („se înțelege
singură: în Jurnal nu vezi întrebarea, deci nota conține răspunsul”). Măsurat:
din cele 300, **131 nu-și pomeneau răspunsul** — „Statuia era înaltă cam cât…”,
„Insula e la 2.000 de kilometri…”. În baza veche de istorie, 94% îl pomenesc,
deci lotul ar fi fost singurul strâmb. Toate 131 au fost rescrise, cu numele
așezat natural în prima propoziție, și verificarea trece azi cu 0.

Măsurătoarea asta n-ar fi existat fără un script de trei rânduri. Merită scris de
ce NU intră în `tools/verificari/`: regula are nevoie de judecată (un răspuns ca
„Zece” sau „Cursele de care” se pomenește altfel decât un nume propriu), iar un
verdict automat ar fi cerut un prag — exact felul de verificare pe care ajungi
s-o aprobi mecanic.

### Principiul călcat, spus pe față

Ca la ȘTIINȚE EXACTE, 600 și DIVERSE, +375: **întrebările și notele sunt scrise
de mine, din memorie**, deci exact ce interzice „Modelul de limbaj formulează, nu
informează”. `plan-continut.md` o spune limpede pentru domeniul ăsta: istoria are
cel mai puțin de luat de la mașină, fiindcă Wikidata are datele dar n-are ce să
întrebi — o relație de fabrică e unu-la-unu, iar istoria e făcută din cauze și
urmări. Ce a făcut paguba mai mică: unde faptul e disputat sau convențional, nota
spune „potrivit legendei”, „cel mai probabil”, „ar fi” (Coandă-1910, Rovine,
Clermont, Romulus și Remus, Canossa, mărul lui Newton, „să mănânce cozonac”), iar
mitologia e povestită din interiorul mitului („În mitologia nordică…”), nu ca
istorie.

### Verificat

- `verifica_trivia`: **TOTUL E BUN**, cod 0. „3417 din 3417 așteptate” în fișierul
  scris de mână, „4731 încărcate din 4731 găsite”, 4731 de id-uri și 4731 de texte
  distincte, „niciun răspuns în textul întrebării” pe toate 4731, **4731 din 4731
  ajung la o notă**, cea mai lungă notă 238 din 240, „niciun fapt nefolosit”.
- Grila istoriei, citită din raport: **200 / 200 / 200** pe niveluri și „istorie,
  subcategorii goale: niciuna din 4”.
- Echilibrul din luptă rămâne în limită la toate trei nivelurile (istoria trasă
  748 / 734 / 764 din 750 țintă, abaterea maximă a raportului 4,3% din 20%).
- Lotul a trecut și prin scriptul de lot din scratchpad: 12 celule × 25, 0 texte
  duplicate, 0 răspunsuri în propriul text, 0 note peste limită, 0 note fără
  răspunsul lor.
- **De ținut minte pentru worktree-uri:** în copia asta de lucru `.godot` nu
  exista, iar rularea scenei direct a atârnat ~95 de minute fără să scrie nimic.
  Întâi `--headless --path . --import` (un minut, cod 0), apoi scena — 20 de
  secunde, ca de obicei.

### Rămas deschis

- **Citirea.** 300 de întrebări și 300 de note, niciuna citită de un om;
  `verificat` e `false` pe toate.
- Trei semnalări lăsate dinadins în raport, fiindcă sunt fapte diferite cu
  răspuns diferit: „capitala Imperiului Roman” lângă „capitala Imperiului
  Bizantin”, „primul președinte de culoare” lângă „primul președinte” și Florența
  (Renașterea) lângă Florența (statuia David).
- Istoria are acum cel mai mult conținut dintre domeniile scrise de mână, dar
  **nivelul I e tot cel mai tras în luptă** (~49% din întrebări, paliere de 3
  trepte) — tensiunea de la „Rămas deschis” din CONȚINUTUL rămâne nehotărâtă.

---

## DIVERSE, +375 (27 octombrie 2026) — de la 225 la 600, scrise de mână

### Cererea

Din socoteala echilibrului pe domenii (ținta ~600 pe domeniu, 200 pe nivel),
punctul 1: *„genereaza intrebarile de la punctul 1: diverse +375. intrebarile noi
generate sa fie diferite fata de intrebarile existente in domeniul diverse”*.

### Ce s-a făcut

- **375 de întrebări noi**, `mana:2743`…`mana:3117`, toate `diverse`, toate
  `verificat: false`, fiecare cu nota ei în `fapte_trivia.json` (`fapt` = propriul
  `id`, ca la ȘTIINȚE EXACTE, 600). Ordinea în fișier: nivelul I (lingvistică,
  logică, curiozități), apoi II, apoi III.
- Domeniul trece de la **75 / 75 / 75** la **200 / 199 / 201**. Pe rafturi:
  lingvistica 42 / 42 / 41, logica 30 / 47 / 48, curiozitățile 53 / 35 / 37.
  Logica are mai puține la nivelul I fiindcă acolo „un fapt despre logică pe care
  îl știe orice adult” se termină repede, iar curiozitățile le-au preluat.
- Diff-ul e **numai inserții** la coada celor două fișiere, scrise ca text.
  `CATE_INTREBARI_MANA`: 2742 → 3117.

Ce acoperă:

| raft | ce intră |
|---|---|
| lingvistica | punctuație și părți de vorbire, expresii și proverbe românești, figuri de stil, etimologii (grecești, latinești, cuvinte venite din japoneză, swahili, nahuatl, taino, turcă, maghiară, slavă), scrieri (hangul, devanagari, glagolitică, ogham, Linear B), dicționare (Johnson, Webster, DLR, DOOM, Lexiconul de la Buda), lingviști (Jones, Grimm, Coșeriu, Pușcariu, Whorf) |
| logica_perspicacitate | puzzle-uri cu nume (tangram, nonograme, criptaritme, jocul de 15), erori de raționament (pantă alunecoasă, tu quoque, heringul roșu, afirmarea consecventului), erori cognitive (ancorare, halo, Dunning-Kruger, supraviețuitorul), paradoxuri (Tezeu, Buridan, Newcomb, Braess, Condorcet, Berry), logicieni (Frege, Boole, De Morgan, Łukasiewicz, Smullyan, Gardner) |
| curiozitati | semne (@, &, *, #), calendar și măsuri (luni, ani bisecți, carat, țol, milă, chenzină), fobii și colecționari, nume de obiecte (agletă, muselet, ferulă), legi glumețe (Murphy, Parkinson, Peter, Goodhart), iluzii și efecte de memorie, nume de mărci, hărți și calendare ciudate |

**Curiozitățile noi țin regula domeniului** („intră aici numai dacă nu încape în
niciunul din primele șapte”), spre deosebire de cele 75 vechi, care sunt mai ales
știință de manual (organe, animale, elemente). Ce era la graniță s-a lăsat pe
dinafară: invenții (tehnologie), steaguri (geografie), superstiții și sărbători
(gastronomie și lifestyle), televiziune (divertisment).

### „Să fie diferite”: ce s-a verificat

Un script de lot (în scratchpad, nu în `tools/`) a comparat fiecare întrebare nouă
cu **toată baza**, nu doar cu Diverse: text identic, același răspuns cu cuvinte
comune, răspunsul în text, variante duble, notă peste 240. A prins **19 dubluri**,
toate înlocuite. Aproape toate erau în lotul de științe exacte de ieri, nu în
Diverse: duzina, STOP-ul octogonal, minutele zilei, L roman, zerourile milionului,
orele săptămânii, googol, nodul, Rubik, cuvintele încrucișate, paradoxul zilelor de
naștere, Boole, Turing 1936, podurile din Königsberg. Plus filatelistul,
numismatul, Bluetooth, Ianus și Sudoku, din alte domenii. S-au mai scos câteva note
care dădeau răspunsul altei întrebări din lot.

### Principiul călcat, spus pe față

Ca la ȘTIINȚE EXACTE, 600: **întrebările și notele sunt scrise de mine, din
memorie**, deci exact ce interzice „Modelul de limbaj formulează, nu informează”.
Domeniul n-are tabele de fabrică (`plan-continut.md` o spune), deci nu exista altă
cale pentru cifra cerută. Ce l-a făcut mai mic: unde un fapt e disputat, nota spune
„potrivit legendei” sau „cel mai probabil” (SOS, Wi-Fi, „duzina brutarului”,
silueta, 10:10 pe ceasuri, „ghicitoarea lui Einstein”). Am evitat recordurile care
se mișcă și am scos din note câteva cifre de care nu eram sigur.

### Verificat

`verifica_trivia`: **TOTUL E BUN**, cod 0. Toate întrebările ajung la o notă, iar
cea mai lungă are 238 de caractere din 240. Echilibrul din luptă e în limită la
toate trei nivelurile (abatere maximă 6,3%). Cifrele totale includ și tabelele
Divertisment / Sport din fabrică, făcute în paralel (secțiunea de mai jos).

### Rămas deschis

- **Citirea.** 375 de întrebări și 375 de note, niciuna citită de un om.
- Nivelurile II și III au 199 și 201, nu 200 și 200: o întrebare de logică de
  nivel III s-ar putea muta la II.
- Cele 75 de curiozități vechi încalcă regula domeniului (sunt știință).
  Mutarea lor la `lumea_vie` / `stiinte_exacte` ar scădea Diverse înapoi la ~525.

---

## DIVERTISMENT ȘI SPORT DIN FABRICĂ (27 octombrie 2026) — +359 și +328, cinci tabele noi

### Cererea

*„Divertisment și Sport: +300 fiecare, cu fabrica”*, cu tabelele propuse în
`plan-continut.md` (film → regizor, album → interpret, Cupa Mondială, orașele
olimpice, campionii de F1, joc → studio) și cu condiția ca întrebările noi să
fie **diferite de cele existente** în cele două domenii.

### Ce s-a făcut

| tabel | relația | întrebări | I / II / III | raft |
|---|---|---|---|---|
| `filme.py` | film → regizor, regizor → film | 203 | 23 / 144 / 36 | `cinematografie` |
| `albume.py` | album → interpret, interpret → album | 156 | 11 / 81 / 64 | `muzica_moderna` |
| `fotbal.py` | CM, CM feminin, Euro: câștigătoare și gazdă; Cupa/Liga Campionilor | 143 | 9 / 48 / 86 | `sporturi_de_echipa` |
| `olimpiade.py` | Jocurile Olimpice de vară: oraș ↔ an | 27 | 4 / 9 / 14 | `individuale_olimpism` |
| `formula1.py` | campionul la piloți și la constructori, anul titlului | 158 | 12 / 42 / 104 | `motor_extreme` |

- **Divertisment: 300 → 659** (+359). **Sport: 300 → 628** (+328). Jocul are
  **4056 de întrebări**, toate cu notă (faptele noi au nota compusă din șabloane și
  trecută prin `comun.verifica_nota`).
- **Un motor comun, `tools/fabrica/tabel.py`**, pentru cele cinci: distractorii
  cei mai apropiați (cu zarul la egalitate), un singur răspuns bun pe datele
  complete, răspunsul nu e în text, dublurile cu ce există, unicitatea în tot
  conținutul, notele, raportul, scrierea. Cele patru tabele vechi n-au fost
  atinse.
- **`comun.nota_omului(..., prezent=True)`**: „este” în loc de „a fost” pentru
  oamenii fără an al morții. Implicit rămâne „a fost”, ca notele tabelelor vechi
  să nu se schimbe la următoarea rulare.
- **„Diferite de cele existente”, cum s-a păzit:** o întrebare generată se
  socotește dublură dacă una existentă (de mână SAU din alt tabel) are în text sau
  în răspuns și subiectul (anul, titlul, numele), și răspunsul. Găsite și scoase:
  **8 la fotbal, 12 la olimpiade, 13 la F1** (declarate în `DUBLURI`, cu id-ul
  întrebării de mână lângă fiecare); o potrivire falsă declarată în
  `NU_SUNT_DUBLURI` (Euro 2004 → Grecia vs. „Grecia a găzduit din nou JO în
  2004”). La F1, filme și albume, sensul invers alege dinadins un an / un titlu pe
  care nicio întrebare de mână nu-l spune deja (Senna primește 1990, nu 1988 sau
  1991). Filmele și albumele deja întrebate de mână nu s-au pus în listă.

### Capcanele găsite la măsurătoare (toate scrise în capul scriptului lor)

- **F1, 2018: campionul la piloți e „Moreno”** — un prenume, nu un om. Al doilea
  semn: ocupația „pilot de curse”, pe care o au ceilalți 73 de campioni. Sezonul
  rămâne fără întrebare, și nu ajunge nici distractor.
- **Joc → studio (`P178`) NU e curat**: Doom (1993) are drept unic dezvoltator
  „Nerve Software” (portarea), nu id Software. Tabelul **nu s-a făcut**; raftul
  `gaming` n-a primit nimic.
- **Jocurile Olimpice de iarnă** nu s-au făcut: `P276` dă locurile de concurs
  („Hafjell” pentru 1994, nu Lillehammer).
- **`P1346` ține și finalista** (Euro 2004), **Euro 2020 s-a jucat în 2021**,
  **Tokyo 2020 în 2021**, **un item contopit** la Cupa Campionilor (1985-86,
  1986-87, 2000-01), **etichete numai în limba `mul`** (Red Bull Racing, Lady Gaga).
- **Distractorii doar pe an amestecau lumile** la filme (Radu Jude pentru
  „Războiul stelelor”): se aleg întâi din aceeași limbă originală (`P364`).
- **Nume de țări echivalente** („Germania” / „Germania de Vest”, „Regatul Unit” /
  „Anglia”, „Uniunea Sovietică” / „Rusia”) nu pot fi distractori unul pentru
  altul (`ECHIVALENTE` în `fotbal.py`).
- **Ediții prea proaspete nu s-au luat**: CM 2026 și Liga Campionilor 2025-26 au
  câștigători la Wikidata, dar declarații de câteva luni.

### Verificat

- Fiecare tabel: „exact una din patru e corectă” pe datele complete, toate notele
  trec validatorul, `id`-uri, texte și fapte unice în tot conținutul; toate cinci
  rulate din nou după ultima scriere, fără nicio oprire.
- `verifica_trivia`: **TOTUL E BUN**, cod 0; „4056 încărcate din 4056 găsite”,
  „4056 din 4056” ajung la o notă, cea mai lungă notă 238 din 240.

### Rămas deschis

- **Echilibrul pe niveluri la Sport s-a înclinat spre III**: 125 / 199 / 304,
  față de ținta PLIN 200 / 300 / 150 din `plan-continut.md`. Vine din F1 și
  Cupa Campionilor, unde palmaresele vechi sunt, cinstit, de nivel III. Nivelul I
  e cel care lipsește, și nu se umple din palmarese.
- **O întrebare de mână pare greșită**: `mana:0440` despre Internazionale spune „trei
  Cupe ale Campionilor în anii 1960”; Wikidata (și palmaresul) dau două, 1964 și
  1965. N-am atins-o — e de citit și de corectat de mână.
- Toate cele 687 sunt `verificat: false`, ca orice întrebare nouă.
- Raftul `gaming` și Jocurile de iarnă așteaptă un al doilea semn; Tour de France
  (cu titlurile retrase ale lui Armstrong) e următorul palmares propus.

---

## UN SENS PE ELEMENT (27 octombrie 2026) — elementele chimice, de la 135 la 69 de întrebări

### Cererea

Întrebarea a fost *„care e șansa să pice o întrebare din elemente chimice la
«Științe exacte»?”*, și răspunsul măsurat a deranjat: **pe raft, ~16% la nivelul I
și ~19% la II și III** erau din tabelul `elemente.py`, adică vreo una din cinci.
Cu întrebările scrise de mână care ating și ele un element (fluorul, osmiul,
Ytterby…), ~17% / 23% / 25%.

### De ce era mult

Nu procentul în sine, ci CE stătea în el: 70 de elemente, fiecare întrebat **în
ambele sensuri** („simbolul argintului” și „ce element are simbolul Ag”), pe un
singur șablon. La nivelul I, 38 de întrebări veneau din 20 de elemente. Exact
capcana scrisă la „Se numără faptele, nu doar întrebările”. Plus un efect mic,
dar real: `DISTANTA_PRACTICE` ține distanța între ÎNTREBĂRI, nu între fapte, deci
cele două sensuri se puteau trage una după alta, iar a doua dădea răspunsul primei.

### Ce s-a făcut

- **`elemente.py` scrie o singură întrebare pe element.** Sensul îl dă **paritatea
  numărului atomic**: par → `cere_simbol`, impar → `cere_nume` (funcția `sensul`).
  Nu alternarea pe poziția din listă: un element adăugat ar fi mutat sensul
  tuturor celor de după el, deci și `id`-urile lor, iar `id`-ul ține progresul din
  Practice. Paritatea e a elementului, nu a tabelului.
- Dacă sensul ales nu se poate scrie (fără frate de literă), se ia celălalt.
- **Un element întrebat deja de mână (`DUBLURI`) nu mai primește nimic fabricat.**
  Azi e doar aurul: `mana:0018` („simbolul chimic al aurului”) rămâne, cu faptul
  ei de mână (`aur`), iar `wd:Q897:simbol:cere_nume` a ieșit. Faptul `wd:Q897` a
  ieșit odată cu ea — un fapt fără întrebare pică „niciun fapt nefolosit”.
  Aurul rămâne distractor în celelalte.
- **Rezultatul: 69 de întrebări (19 / 26 / 24 pe nivel), 69 de fapte.** Diff-ul
  pe `data/trivia_gen/elemente_intrebari.json` are **numai ștergeri**: cele
  păstrate au rămas identice, cu aceleași `id`-uri și aceleași variante, deci
  progresul din Practice pe ele nu se pierde.
- Pe raftul „Științe exacte”, partea elementelor fabricate scade la **~9% la
  nivelul I (19 din 221), ~11% la II (26 din 232) și ~10% la III (24 din 229)**. Jocul are acum **3369 de întrebări** (de la
  3435), toate cu notă.

### Verificat

- `python tools/fabrica/elemente.py --scrie`: „exact una din patru e corectă” pe
  toate 69, toate notele trec validatorul, `id`-uri unice peste tot conținutul.
- `verifica_trivia`: **38 din 38**, cod 0; „3369 încărcate din 3369 găsite”,
  „niciun fapt nefolosit” OK.

### Rămas deschis

- **Răspunsurile date deja la întrebările șterse rămân în `permanent.json`** și
  se numără în continuare spre `PRAG_PRACTICE` (`cate_stiute` numără cheile, nu le
  compară cu baza). E corect așa — au fost răspunsuri corecte adevărate —, dar
  înseamnă că cifra din listă poate fi cu câteva peste ce mai e pe raft.
- **Următorul tabel propus pentru raft, formula unei substanțe (`P274`), e tot
  chimie de tabel.** Aceeași regulă, de la început: un sens pe substanță. Altfel
  raftul se înclină din nou spre același șablon.
- Întrebările scrise de mână despre elemente (~25, mai ales la nivelul III) n-au
  fost atinse: sunt relații diferite (descoperitori, proprietăți, etimologii), nu
  „simbol ↔ nume”.

---

## ȘTIINȚE EXACTE, 600 (27 octombrie 2026) — 200 pe fiecare nivel, scrise de mână

### Cererea

*„genereaza 600 de intrebari pentru subdomeniul stiinte exacte (cate 200 pentru
fiecare nivel). Noile intrebari generate sa nu coincida cu intrebarile curente
din «Stiinte exacte»”.*

### Ce s-a făcut

- **600 de întrebări noi**, `mana:2143`…`mana:2742`, toate `stiinta_tehnologie` /
  `stiinte_exacte`, toate `verificat: false`: **200 la nivelul I** (`2143`–`2342`),
  **200 la II** (`2343`–`2542`), **200 la III** (`2543`–`2742`).
- **Fiecare are notă**, după convenția din TOATE AU NOTĂ: `fapt` = propriul `id`,
  iar nota stă în `data/fapte_trivia.json`. Invarianta „toate au notă” ține:
  **3435 din 3435**. Cea mai lungă notă nouă: 200 de caractere din 240.
- Structura nu s-a schimbat: diff-ul e **numai inserții** la finalul celor două
  fișiere (6600 de rânduri în întrebări, 2400 în fapte), scrise ca text, nu prin
  rescrierea JSON-ului. `CATE_INTREBARI_MANA` din `verifica_trivia.gd`: 2142 → 2742.
- Raftul `stiinte_exacte` trece de la **40 / 55 / 53** la **240 / 255 / 253** pe
  niveluri (148 → 748), adică peste ținta PLIN de la nivelul I (150–250) și la
  jumătatea ei la II și III (500).

Ce acoperă, pe niveluri:

| nivel | ce intră |
|---|---|
| I | geometrie de școală (unghiuri, poligoane, corpuri), operații și numere, unități și prefixe, stări de agregare, magneți, lumină și sunet de zi cu zi, chimia bucătăriei, câteva nume mari (Newton, Pitagora, Arhimede, Einstein) |
| II | unitățile SI și legile cu nume (Ohm, Hooke, Pascal, Bernoulli, Newton I și III), optică, electricitate, radioactivitate, pH și legături chimice, metode de separare, minerale și roci, statistică și trigonometrie de liceu |
| III | teoreme și probleme celebre (Fermat–Wiles, Poincaré, Riemann, Goldbach, Collatz), fizică modernă (Pauli, Dirac, Maxwell, efectele cu nume), istoria chimiei, geologia internă a Pământului, **matematicieni, fizicieni și chimiști români** (Țițeica, Moisil, Pompeiu, Haret, Lalescu, Onicescu, Marcus, Procopiu, Hulubei, Nenițescu, Edeleanu, Teclu) |

### „Să nu coincidă”: ce s-a verificat și cum

Un script de lot (în scratchpad, nu în `tools/`, ca în TOATE AU NOTĂ) a cerut,
înainte de orice scriere:

- **niciun text existent** în cele 3435 (normalizat: fără diacritice, fără punctuație);
- **nicio întrebare nouă cu același răspuns și cuvinte comune** cu una existentă —
  nu doar din `stiinte_exacte`, ci din toată baza, fiindcă lecția din CONFORT 25
  era că dublurile vin din rafturile TRANSVERSALE (`curiozitati`, `lumea_vie`,
  `astronomie_spatiu`, `tehnologie_inventii`, `logica_perspicacitate`);
- **niciun răspuns în textul întrebării**, aceeași regulă ca în verificator;
- **niciun „Care e simbolul chimic…” / „Ce element are simbolul…”**: tabelul
  fabricat al elementelor le are deja pe toate 135;
- la întrebările cu calcul (√81, 7 × 8, 5!, divizorii lui 12, suma divizorilor lui
  220, cel mai mic număr perfect…), **răspunsul e recalculat de Python**, nu crezut.

A prins **11 dubluri**, toate înlocuite: anul bisect (text identic, `mana:0721`),
Marie Curie cu două Nobeluri (`mana:1305`), termometrul (`mana:1433`), galben +
albastru (`mana:0029`), lingura „frântă” în apă (`mana:0838`), cerul albastru
(`mana:0777`), scara Mohs (`mana:1238`, text identic), reacția Maillard
(`mana:2031`), Mendeleev și tabelul periodic (`mana:0068`). Plus câteva perechi
între loturile noi, în care nota uneia dădea răspunsul alteia (Celsius, Boyle,
temperatura din centrul Soarelui, explicația mișcării browniene).

### Principiul călcat, spus pe față

**Întrebările și notele le-am scris eu, din memorie** — exact ce interzice
„Modelul de limbaj formulează, nu informează”. E același compromis ca la CONFORT
25 și la TOATE AU NOTĂ, luat de data asta fără să fi fost pus pe masă înainte:
cererea a venit cu cifra și raftul fixate. Ce l-a făcut mai mic decât acolo:

- științele exacte sunt raftul cu cele mai stabile fapte din toată baza: o
  teoremă, o unitate SI sau o lege cu nume nu se schimbă de la an la an, iar o
  parte din răspunsuri sunt calcule verificate de script;
- am evitat recordurile și cifrele care se mișcă (cel mai mare număr prim
  cunoscut, câte elemente există, câte Probleme ale Mileniului mai sunt
  deschise);
- la citirea notelor au fost corectate, înainte de scriere, câteva cifre puse pe
  lângă — tocmai forma pe care o iau greșelile de felul ăsta: anagrama lui Hooke
  (anunțată în 1676, nu publicată în 1678), vârsta lui Héroult în 1886, distanța
  până la găurile negre detectate de LIGO, doza unei radiografii, de ce a fost
  înnobilat lordul Kelvin.

Toate cele 600 au `verificat: false`. Dacă la citire rata de greșeli iese
neplăcută, se scot cu o singură operație: sunt un bloc continuu de `id`-uri la
coada ambelor fișiere.

### Verificat

`verifica_trivia`: **TOTUL E BUN**, cod 0 — 3435 de întrebări, 3435 cu notă,
echilibrul pe domenii în limită (Știința la nivelul III, 713 din 750, abaterea
cea mai mare: 4,9%, limita 20%). Celelalte verificări nu ating conținutul de
trivia și n-au fost rulate.

### Rămas deschis

- **Citirea.** 600 de întrebări și 600 de note, niciuna citită de un om.
- **Nivelul I e acum cel mai gros la științe exacte** (240), deși e nivelul pe
  care CONȚINUTUL îl plafona la 150–250 tocmai pentru că „o știe orice adult”.
  Unele întrebări de nivel I sunt de manual de gimnaziu (ipotenuza, raportorul,
  prefixele SI); dacă în joc se simt prea școlărești, se pot muta la II, nu șterge.
- În luptă nu se schimbă nimic la echilibru: domeniul se alege uniform, apoi
  întrebarea. Raftul gros se simte doar în Practice și în rata de repetiție din
  Știință.

---

## ANTETUL HĂRȚII (26 octombrie 2026) — fără titlu, resursele pe o plăcuță cu iconițe pictate

**Problema:** antetul hărții era un șir de text pe pergament — „EXPEDITIE — nodul
2, Bossul la cel putin 6 pasi” în stânga, „23 / 15 PV 37 Monede 297 Fragmente
samanta 4242” și „Unelte: …” în dreapta. Arăta ca o notă de depanare.

**Ce s-a făcut:**

- **Titlul a ieșit de tot.** Spunea ce arată deja harta. Distanța până la Boss a
  rămas în sumarul unei expediții pierdute, unde înseamnă ceva.
- **PV, Monede, Fragmente pe o PLĂCUȚĂ de piele**, un singur rând în dreapta-sus,
  cu ramă aurie și despărțitoare. Fiecare cifră are iconița ei, fără cuvânt;
  numele complet e în tooltip. PV-ul se înroșește sub o treime.
- **Iconițele sunt imagini pictate** (`assets/art/resurse/pv.png`, `monede.png`,
  `fragmente.png`): JPG-uri de 2000 px pe fundal închis, decupate (fundalul scos
  pornind de pe contur, ca umbrele din obiect să nu devină găuri), tăiate la
  obiect, 256×256, PNG cu alfa, **cu mipmap-uri la import** — altfel o imagine de
  256 px desenată la 26 px tremură pe margini. `iconita_resursa.gd` le încarcă o
  singură dată, după modelul din `simbol_nod.gd`, și desenează forma din cod dacă
  fișierul lipsește.
- **Uneltele au coborât în piciorul hărții**, stânga, ca etichete în culoarea
  disciplinei; **sămânța** stă mică în dreapta-jos (rămâne la vedere dinadins).
- **Apoi, tot azi, piciorul s-a golit:** au ieșit uneltele (le-ai ales chiar tu,
  nu se schimbă pe drum), sămânța din colț (rămâne în SUMAR, unde ajută la un bug
  raportat) și rândul „Treci peste un semn ca sa vezi ce te asteapta”. În locul
  rândului stă acum **butonul „Meniu”**, centrat sub hartă — a plecat din stânga
  antetului, care a rămas doar cu plăcuța. Singurul text care mai apărea acolo, deasupra
  butonului, era „X te asteapta. Apasa pe piesa…” când un nod e nerezolvat — și a
  ieșit și el, la cerere, tot azi: nodul care te așteaptă se vede pe hartă (piesa
  stă pe el și e singurul apăsabil). `verifica_retragerea`: 27 OK.
- **Butonul „Meniu” n-are fundal în repaus** (`StyleBoxEmpty`): text Cinzel crem
  cu contur, direct pe masă, iar plăcuța de piele apare doar sub mouse. Marginea
  de jos a coloanei a scăzut de la 24 la 12 px, ca butonul să stea pe lemn.
- **Cartea din colț („Cronicile”) se deschide la clic.** Arată uneltele cu care ai
  plecat: piesa în culoarea disciplinei, rolul și felurile de întrebări, plus
  cum urcă nivelul într-un lanț (citit din `TREPTE_PE_NIVEL` / `NIVEL_MAX` din
  `lupta.gd`, nu scris de mână). Cartea e pictată în fundal, deci
  `tools/decupeaza_cartea.py` o taie într-un PNG cu transparență
  (`assets/art/carte_cronici.png`), iar `scenes/harta/carte_harta.gd` îl desenează
  exact peste ea. **Sub mouse, cartea se ridică:** crește cu 7% dintr-un punct de
  pe marginea din dreapta a ecranului, deci alunecă spre stânga, cu umbră. O
  alunecare simplă ar fi dezvelit cartea pictată de dedesubt (două muchii);
  crescând din marginea ei, decupajul o acoperă mereu. Zona de clic e
  transparența PNG-ului (`_has_point`), deci conturul stă o singură dată, în
  scriptul Python. Drumul, ca să nu se reia: întâi un contur aprins sub mouse,
  care a prins întâi masă de sub carte, apoi a lăsat afară muchia groasă a
  copertei; cotorul și muchia de sus s-au măsurat în cele din urmă din pixeli
  (pergament deschis / piele închisă), nu din ochi. **La coborâre, cartea
  părea dublă sus**, din două cauze: conturul tăia SUB chenarul muchiei de sus
  (o dungă închisă și una aurie, 3-4 px), care ieșea apoi pe sub decupaj cât
  mai era ridicat puțin; iar decupajul n-avea mipmaps, deci la ~40% din mărime
  ieșea grăunțos față de fundal, și la capătul coborârii se vedea saltul.
  Muchia de sus a urcat cu 0,003, iar `carte_cronici.png` se importă cu
  mipmaps, ca fundalul. **Tot dublat la colțul de sus**, și aici s-au oprit
  măsurătorile: colțul cotorului e rotunjit și iese din orice contur din
  puncte, iar umbra era decupajul colorat în negru — o siluetă tăiată precis
  care, mutată spre stânga-jos, arăta ca o a doua carte. Scriptul scrie acum
  trei imagini din aceeași cutie: cartea (contur strâns, și zona de clic), o
  MARGINE lățită cu 6 px și estompată, desenată sub carte (acoperă orice rest
  al cărții pictate; ce ia în plus e hârtie peste hârtie), și UMBRA, silueta
  estompată cu 9 px. Ordinea la desen: margine, umbră, carte. Felurile de întrebări sunt câmpul nou „sarcini” din
  `Discipline.CATALOG`. Se închide din buton, cu Esc sau cu clic pe voal. Cât
  e deschisă, cartea rămâne RIDICATĂ (`tine_ridicata()`): voalul o acoperă,
  deci Godot anunță că mouse-ul a plecat, și ar fi coborât exact la deschidere.
  Coboară la închidere, oricum ai închis-o, dacă mouse-ul nu e pe ea. Se vede
  doar pe hartă, ca butonul Meniu.

**Drumul, ca să nu se reia:** întâi iconițe desenate din poligoane (prea „joc 2D
ieftin” lângă figurină și noduri), apoi rândul fără cutie direct pe pergament,
apoi o coloană în colț — s-a ales plăcuța pe un rând. Cu uneltele în ea pe al
doilea rând, plăcuța lua prea mult din hartă.

---

## IEȘIRILE DIN EXPEDIȚIE (26 octombrie 2026) — „HARTA" din luptă, „Meniu" de pe hartă

**Problema:** dintr-o expediție începută ieșeai doar terminând-o sau închizând
jocul forțat. Decizia veche („din mijlocul expediției, fără Save, ar fi o
abandonare deghizată în pauză”) își pierduse motivul de la Save (12 octombrie),
iar butonul stătea la „Rămas deschis” de două săptămâni.

**Ce s-a făcut:** două uși, care se înlănțuie — luptă → hartă → meniu.

- **„Meniu” în antetul hărții** (stânga, lângă titlu). Se vede doar pe ecranul
  de hartă: loadout-ul și sumarul își au butonul lor, iar cât e Lacătul deschis
  butonul se ascunde (Evenimentul nu e `reluabil`, deci o ieșire de acolo ar
  pierde cufărul). `_pe_meniu()` întreabă acum STAREA: o expediție vie se mai
  scrie o dată pe disc și NU se golește (meniul citește chiar starea din
  memorie ca să scrie „Continua expeditia”); una moartă se golește, ca înainte.
- **„HARTA” în colțul stânga-sus al luptei**, simetric cu JURNAL, cu o
  întrebare înainte (`ConfirmationDialog`: „Retrage-te” / „Ramai”) — un clic
  scăpat în colț n-are voie să-ți ia lupta. Stins cu o întrebare pe ecran, în
  pauza dinaintea loviturii inamicului și după verdict. Ascuns cu F6 (fără
  expediție n-ai unde te întoarce).

### Ce costă retragerea — decis azi, la întrebare

**PV-ul pierdut în lupta lăsată rămâne pierdut; inamicul o ia de la capăt.**
Lupta tot nu se salvează (decizia rămâne), dar PV-ul regelui se predă
expediției la retragere (`Expeditie.seteaza_pv(pv_jucator)` + salvare).
Alternativa, „pauză gratuită” (PV-ul de la intrare, ca la închiderea jocului),
ar fi făcut din buton o reîncercare: o luptă care merge prost se lasă și se
reia proaspătă până iese bine. Așa nu câștigi nimic retrăgându-te — inamicul
își recapătă PV-ul, tu nu — deci rămâne o pauză, nu o tactică.

Prețul, scris: **închiderea forțată a jocului în luptă e în continuare o
reîncercare gratuită** (PV-ul de pe disc e cel de la intrare). Butonul n-a
deschis gaura, doar a pus lângă ea o ușă cinstită.

### Nu e o fugă: nodul TE AȘTEAPTĂ pe hartă

Retragerea nu încheie nodul (`nod_nerezolvat` rămâne). Până azi, harta
redeschidea pe loc orice nod reluabil nerezolvat — cu butonul nou ar fi fost un
cerc: apeși „HARTA”, harta te trimite înapoi în luptă în același cadru. Acum:

- `_reia_nodul()` doar arată harta; **nodul se redeschide la clic pe piesă**
  (fără salt și fără `intra_in_nod`, deci nu intră a doua oară în `parcurse`);
- **`_optiuni()`** în `harta.gd` e `accesibile()` cât timp nu stai pe un nod
  nerezolvat, și listă goală cât stai: drumurile spre vecini sunt stinse și
  niciun alt nod nu e apăsabil;
- nodul care așteaptă nu poartă X (e în `parcurse`, dar nu e încheiat) și e
  apăsabil prin parametrul nou `apasabil` din `SimbolNod.configureaza()`;
- piciorul hărții scrie „Lupta te asteapta. Apasa pe piesa ca sa intri din nou.”

**De ce `_optiuni()` stă în hartă și nu în `Expeditie.accesibile()`:**
`verifica_drumuri` joacă zeci de mii de expediții cu `intra_in_nod()` fără să
cheme vreodată `incheie_nodul()`, iar `la_capat()` întreabă și el
`accesibile()`. Pentru ele un nod nerezolvat nu există; regula e a ecranului.

**Se schimbă și reluarea după un joc închis în luptă:** înainte lupta pornea
singură la „Continua expeditia”; acum vezi întâi harta, cu nodul care te
așteaptă. Aceeași ramură pentru amândouă drumurile, fiindcă ecranul nu știe pe
care ai venit — starea spune tot. La Odihnă și Magazin la fel (acolo fereastra
nerezolvată e practic de un cadru).

### Verificat

| unealtă | rezultat |
|---|---|
| `verifica_retragerea` | **nouă — 27/27 OK**, ~2 s, cod 0. Joacă cu scenele adevărate luptă → „HARTA” → hartă → clic pe piesă → victorie → hartă → „Meniu”, într-un dosar de probă. Ruptă o dată (`_optiuni()` lăsat să întoarcă vecinii): pică „niciun drum deschis spre vecini” și „niciun alt nod nu e apăsabil”, cod 1 |
| `verifica_salvarea` | 54/54 OK |
| `verifica_drumuri` · `verifica_eveniment` · `verifica_plansa` · `verifica_harta` | 0 picate |

**Nu s-a văzut cu ochiul:** nici butonul din antetul hărții, nici fereastra de
confirmare din luptă (tema implicită Godot, într-o scenă care n-are temă).
Nicio partidă jucată pe mână.

### Rămas deschis

- **Fereastra de confirmare are înfățișarea implicită Godot.** Dacă arată străin
  în luptă, se înlocuiește cu un panou ca verdictul sau cardul inamicului.
- **Abandonarea unui run** tot nu există: poți ieși, dar nu poți renunța la o
  expediție ca să pornești alta (SAVE, „Ce NU s-a făcut”).
- **Ieșire din Lacăt** nu există, dinadins (vezi mai sus).

### Fișiere

| fișier | ce |
|---|---|
| `scenes/harta/harta.tscn`, `harta.gd` | butonul `HartaMeniu`, `_pe_meniu()` pe stare, `_optiuni()`, nodul care așteaptă, piciorul |
| `scenes/harta/simbol_nod.gd` | parametrul `apasabil` |
| `scenes/lupta/lupta.tscn`, `lupta.gd` | `ButonHarta`, `ConfirmaRetragerea`, `_se_poate_retrage()`, retragerea |
| `tools/verificari/verifica_retragerea.gd`, `.tscn` | **nouă** — 27 de verdicte |
| `CLAUDE.md` | rândul despre meniu, decizia retragerii, rândul din tabelul verificărilor |

---

## PRIMUL BUILD WEB (25 octombrie 2026) — Practice pe itch.io, cu Alergologia aprinsă

**Ce s-a făcut:** un export web, urcat pe itch.io, ca să poată juca
Alergologia și de pe telefon. Nu e pasul 14: e un demo pentru o singură
persoană.

**Pagina:** https://gyarados9.itch.io/mindkeep

**Setările de pe itch.io** (nu stau nicăieri în repo, deci aici): Kind of
project = HTML; zip-ul din `../mindkeep_web/` cu „played in the browser”;
viewport 1152 × 648; Mobile friendly, orientare Landscape; Fullscreen button;
Visibility = Restricted, cu parolă (întrebările de alergologie au
`verificat: false`, deci nu public). O versiune nouă = alt zip pe aceeași
pagină, linkul rămâne.

**O versiune nouă, dintr-o comandă:** `python tools/exporta_web.py` face
exportul și zip-ul (~5 s). Oprește dacă eticheta `alergologie` lipsește din
preset sau din pachet ori dacă JSON-urile n-au intrat în pachet, și arată ce
nu e comis, fiindcă exportul ia proiectul de pe disc. Rămâne de mână doar
urcarea pe itch.io.

**Web aprins, local stins, fără să schimbi nimic de mână.** `ALERGOLOGIE` nu
mai e o constantă, ci `static var ALERGOLOGIE = ALERGOLOGIE_LOCAL or
OS.has_feature("alergologie")`. Eticheta `alergologie` stă în Custom Features
ale presetului „Web”; Godot o scrie în `project.binary` din pachet, iar jocul
o vede la pornire. Verificat în ambele sensuri: local, Practice nu încarcă
alergologia; în build, consola din browser spune „alergologie — 300 intrebari”
și butonul apare. Eticheta e proprie, nu `"web"`: pasul 14 va avea alt preset,
fără ea. Prețul: presetul e în `.gitignore`, deci eticheta trăiește doar pe
mașina asta — de-aia scriptul o caută și în preset, și în pachet.

**Presetul** (`export_presets.cfg`, în `.gitignore`, deci stă doar local):
Web, **fără fire** (`variant/thread_support=false` — merge pe itch.io și pe
iPhone fără anteturi speciale), `*.json` în filtrul de fișiere care nu sunt
resurse (altfel jocul pornea fără întrebări), iar afară: `tools/*`, sursele
pieselor de șah (`pawn/knight/bishop.png`) și `demons_hand_reference.png`
(pomenită doar într-un comentariu). Ieșirea: `../mindkeep_web/index.html`,
în afara repo-ului. Comanda:
`Godot_..._console.exe --headless --path . --export-release "Web" ../mindkeep_web/index.html`.

**Două probleme găsite abia în browser:**

- **Litere ciupite** („n” cu un picior șters, litere tăiate jos) în chenarul de
  pe itch.io, nu și pe ecran complet. Cauza: `default_texture_filter=3` în
  `project.godot` înseamnă **Nearest Mipmap**, nu Linear Mipmap (ăla e 2) —
  verificat în binarul Godot, lista e „Nearest, Linear, Linear Mipmap, Nearest
  Mipmap”. Sesiunea din septembrie voia Linear Mipmap și a scris 3. Pe desktop
  nu se vedea, fiindcă literele cad 1:1 pe pixeli; în browser, cu scalarea de
  125% din Windows, cad între pixeli, iar filtrul „cel mai apropiat” sare
  rânduri întregi. Acum e 2. **Schimbă și desktopul**: toate imaginile se
  filtrează acum liniar, cum fusese gândit.
- **Sacadare pe ecran complet** (și sunetul odată cu ea: în build-ul fără fire
  sunetul se amestecă pe același fir cu desenul). Cauza probabilă:
  `fundal_estompat.gdshader` rula la fiecare cadru, 24 de probe pe pixel, pe o
  imagine care nu se schimbă. Acum `assets/tema/fundal_estompat.gd` (pus pe
  `Biblioteca` din meniu și din Practice) îl desenează O DATĂ într-un
  `SubViewport` (`UPDATE_ONCE`) și arată poza; redesenează doar la
  redimensionare. FPS-ul nu s-a măsurat (panoul de browser era ascuns, deci
  cadrele erau frânate), dar **pe itch.io, pe ecran complet, lag-ul a
  dispărut** după al doilea upload — confirmat cu ochiul, tot pe 25 octombrie.
  Literele arată și ele corect.

### Rămas deschis

- **Telefonul n-a fost încercat.** Peisaj, nu portret: pânza e 1152×648.
- Lupta folosește `fight_background.jpg` fără estompare, deci n-are costul
  ăsta; Lacătul folosește fire (`WorkerThreadPool`), care în build-ul fără fire
  nu există — expedițiile pe web sunt neîncercate.
- Lipsesc `dial_click.ogg` și `chest_open.ogg` din `assets/audio/` (și pe
  desktop): Lacătul rămâne mut la cele două efecte.
- Progresul de pe web stă în browserul ei (IndexedDB), nu se sincronizează.

---

## ALERGOLOGIE (24 octombrie 2026) — o secțiune doar pentru Practice, cu comutator

### Cererea

O rezidentă de anul I la alergologie vrea să exerseze pe întrebări. 300 de
întrebări, fără niveluri, ca să poată trece prin toate. Secțiunea nu intră în
joc decât cât o las pe ea să joace: un buton aprins sau stins din cod.

### Ce s-a făcut

- **`data/alergologie.json`**: 300 de întrebări, `alerg:0001`…`alerg:0300`,
  toate cu `nivel: 1`, `verificat: false`, `corect: 0` (variantele se amestecă
  oricum la afișare), fără `fapt`. **Șase rafturi a câte 50**: imunologie de
  bază (inclusiv imunodeficiențe și mastocitoză), astm și rinită, alergii
  alimentare, anafilaxie/medicamente/venin, urticarie/angioedem/dermatite,
  diagnostic și imunoterapie.
- **Comutatorul `ALERGOLOGIE`** în `trivia.gd`, lângă `FOLOSESTE_WIKIDATA`.
  Stins (implicit), fișierul nici nu se citește și butonul nu apare.
- **Trei lucruri o țin departe de luptă**, fiecare suficient singur: întrebările
  stau în `intrebari_doar_practice`, nu în `intrebari`; cheia e în
  `DOMENII_DOAR_PRACTICE`, nu în `DOMENII` (deci verificatorul și echilibrul n-o
  văd); și comutatorul.
- **Practice citește `domenii_practice()` și `subcategorii_practice()`** în loc
  de `DOMENII` și `SUBCATEGORII`, iar `raftul()` alege lista după domeniu.
- **Fără niveluri**: `_nivel_maxim(domeniu)` întoarce 1 pentru secțiunile
  doar-Practice. Antetul scrie „45 / 300 stiute” în loc de „Nivel I · 45 / 60”,
  butonul domeniului n-are cifră romană, raftul parcurs scrie „100%”, iar
  anunțul de raft parcurs nu mai pomenește nivelul.
- Progresul ei intră în același `permanent.json`, pe celula `alergologie:1`.

### Principiul călcat, spus pe față

**Întrebările le-am scris eu, din memorie** — exact ce interzice „Modelul de
limbaj formulează, nu informează”. Excepția e conștientă: le citește un medic,
iar comutatorul le ține afară din jocul oricui altcuiva. De-aia n-au note (o
notă ar fi dublat numărul de afirmații nesusținute) și au toate `verificat: false`.
Am evitat cifrele care se schimbă des (dozele din ghiduri, treptele GINA pe
ani), dar ce e în ghiduri (praguri GINA, pași EAACI pentru urticarie, criterii
OMS pentru mastocitoză) poate fi depășit de o ediție nouă.

### Verificat

- `verifica_trivia` (38 de verdicte) și `verifica_salvarea` (54) trec cu
  comutatorul STINS; `verifica_trivia` trece și cu el APRINS, cu linia
  „alergologie — 300 intrebari (din 300 gasite), doar in Practice”.
- Capturi cu comutatorul aprins: lista de domenii (Alergologie e ultimul, fără
  iconiță), cele șase rafturi plus „Tot domeniul”, întrebări pe ecran, inclusiv
  cea cu variantele cele mai lungi (marșul atopic) — încap pe un rând. Scena de
  captură a fost ștearsă; nu s-a dat niciun răspuns, deci `permanent.json` n-a
  fost atins.

### Rămas deschis

- **Să le citească ea.** Ce găsește greșit se corectează direct în JSON; ce
  găsește corect primește `verificat: true`.
- ~~Iconiță pentru Alergologie~~ — **făcută în aceeași zi**: o albină,
  `assets/iconite/domenii/alergologie.png`, 256 px, cu mipmap-uri, ca
  celelalte. Fundalul era alb neted, deci s-a decupat fără rembg, prin
  „dezamestecare” din alb: corpul opac, aripile pe jumătate străvezii (detalii
  în `CREDITE.txt`). Văzută într-o captură, lângă nume, cu comutatorul aprins
  temporar. **Sursa și licența imaginii nu sunt scrise încă** — de completat în
  `CREDITE.txt` înainte de orice export public.
- ~~O răsplată ca să continue~~ — **făcută în aceeași zi: felicitarea la
  fiecare 20.** La a 20-a, a 40-a… întrebare DISTINCTĂ știută
  (`PAS_FELICITARE` = 20 în `practice.gd`), un popup: „Felicitări, ai atins
  nivelul X la alergologie!", cu „Ai răspuns corect la 40 din 300 întrebări."
  dedesubt. Nivelul pornește de la 0, deci 300 de întrebări înseamnă 15
  niveluri, și stă și în antet („Nivel 2 · 45 / 300 stiute"), ca să nu existe
  doar cât e deschis popup-ul. **Distincte, nu răspunsuri**: altfel
  recapitularea aceleiași întrebări ar urca nivelul. Doar pe secțiunile
  doar-Practice. Popup-ul e CHIAR panoul notei (titlul, textul și butonul se
  pun la fiecare deschidere), cu umbra modală și Escape; cât e deschis, bara
  „trecerii singure" nu pornește. Verificat cu o scenă temporară care a mutat
  `Arhiva.dosar` pe un dosar de probă, a pus 19 știute false și a răspuns
  corect o dată: popup-ul apare, bara nu curge, antetul scrie „Nivel 1 · 20 /
  300", iar nota deschisă după aceea are din nou „AFLA MAI MULTE". Scena și
  dosarul au fost șterse; `permanent.json` a rămas neatins. Cine are deja
  progres nu primește felicitările din urmă: următoarea vine la multiplul
  următor de 20.
- **Titluri pe niveluri** (tot 24 octombrie): `TITLURI_DOAR_PRACTICE` în
  `trivia.gd`, 16 nume pentru nivelurile 0–15, de la „Proaspăt sosit în
  clinică" și „Alergolog începător" (1) până la „Marele Maestru al
  Mastocitelor" (15, toate 300 știute). Scara amestecă cariera reală (rezident
  cu experiență la 5, specialist la 8, primar la 11, șef de secție, profesor)
  cu glume de meserie între ele („Vânător de polen", „Îmblânzitor de
  histamină", „Detectiv al IgE"). Popup-ul scrie „Noul tău titlu: …", iar la
  ultimul nivel „Ai răspuns corect la toate cele 300 de întrebări!"; antetul
  devine „Nivel 3 · Cititor de prick-uri · 60 / 300 stiute". Numele sunt doar
  text, se rescriu fără nicio altă schimbare. Verificat la fel ca felicitarea
  (dosar de probă, 59 și 299 de știute false): ambele popup-uri și antetul
  încap; `permanent.json` neatins.
- Dacă vrea explicații după răspuns, ar fi o notă pe întrebare. Merită doar
  scrise sau citite de ea, din același motiv ca mai sus.

---

## ICONIȚE PICTATE (23 octombrie 2026) — domeniile și creierul ies din alb, ca figurina

### Problema

Iconițele domeniilor și creierul erau SVG-uri albe de pe game-icons.net,
vopsite de temă în roșul de rubrică. Lângă figurina de pe hartă (un PNG pictat,
cu lumină și material), arătau ca dintr-un alt joc, mai ales pe meniu, unde
figurina și creierul stau una lângă alta.

### Ce s-a făcut

- **Nouă imagini generate cu o unealtă AI** (le-am făcut eu și le-am trimis ca
  JPG-uri de 2000 px), câte una pe domeniu, plus creierul.
- **Decupate pe transparent** cu `rembg` (modelul `isnet-general-use`), într-un
  mediu Python separat, în afara proiectului. Capcana: mai multe JPG-uri aveau o
  **tablă de șah de transparență PICTATĂ**, nu transparență adevărată. Două
  imagini au cerut mai mult:
  - **coroana**: rembg îi mânca panourile albastre, aproape la fel de închise ca
    fundalul. Fundalul ei e un gri neted, deci s-a scos după culoare (gri neutru
    legat de margini), iar umbrele închise din coroană au rămas. **În aceeași zi
    coroana a fost înlocuită de trei ori** (albastru cu aur, apoi toată de aur
    cu gravuri, apoi de aur netedă). La cele aurii, strălucirea încălzește
    fundalul din jur, deci cheia de culoare singură lăsa pete; soluția a fost
    s-o combin cu rembg: ce nu e gri neutru, dar numai înăuntrul siluetei, cu
    găurile umplute. Prețul aurului simplu: pe butonul bej se desprinde slab.
    **Pe 24 octombrie, a patra înlocuire**: aur cu pietre și perle, cea rămasă
    (pietrele colorate o desprind de bej; fiind lată, iese mai joasă pe buton).
    Ea stătea pe o tablă de șah pictată, care se vedea și prin golurile dintre
    vârfuri și flori, deci s-a scos tot griul neutru din plaja tablei, numai
    înăuntrul siluetei rembg, FĂRĂ să umplu găurile; perlele, mai luminoase
    decât tabla, au rămas;
  - **lupa**: prin lentilă se vedea tabla pictată. A fost înlocuită cu sticlă
    netedă, pe jumătate transparentă, iar semnul întrebării (auriu, deci ușor de
    separat de sticla rece) a rămas.
- **256 px, nu 512.** Pe butoane se văd la ~30 px, iar creierul din meniu la
  ~104 px; 256 acoperă și un ecran 2×. Toate nouă cântăresc 0,7 MB, față de
  2,4 MB la 512, și contează la exportul web.
- **Mipmap-uri în import**, pe toate nouă. Filtrul implicit al proiectului e
  deja „Linear Mipmap”, dar fără mipmap-uri generate, micșorarea de la 256 la 30
  fâlfâie.
- **Tema nu le mai vopsește.** `Button/colors/icon_*` din `pergament.tres` e
  acum alb (culoarea e în fișier), puțin mai luminos la survolare, mai închis la
  apăsare, și alb pe 35% când butonul e stins. `LegaturaPergament` (creierul din
  chenar) e alb pe 28% când e stins. Pe meniu, `modulate`-ul roșu de pe
  `Icoana` a ieșit.
- **`_iconita()` caută `.png`.** Regula a rămas: fișierul se numește după cheia
  domeniului, fără tabel, iar fără fișier butonul iese fără iconiță.
- **`nota.svg` → `nota.png`**, în ambele scene care îl folosesc (`meniu.tscn` și
  `practice.tscn`). SVG-urile vechi și `.import`-urile lor au ieșit.
- **Creditele**: CC BY pentru Lorc a ieșit odată cu fișierele lui. În
  `CREDITE.txt` scrie acum de unde vin imaginile (**Gemini**, Google) și ce
  prelucrare au primit.

### Verificat

Capturi cu `--write-movie`: meniul (figurina lângă creier), lista de domenii din
Practice și creierul din chenar înainte de răspuns (estompat) și după verdict
(în culori). Pentru ultima, o scenă temporară a apăsat butoanele; a fost ștearsă
după captură, iar `permanent.json` n-a fost atins. Starea de survolare nu a
fost capturată.

### Rămas deschis

- **De verificat termenii Gemini** pentru folosirea comercială a imaginilor
  generate, înainte de orice export public. Unealta e trecută în `CREDITE.txt`.
- Scriptul de decupare a stat în afara proiectului: reparațiile pentru coroană și
  lupă sunt făcute pe imaginile astea anume. Dacă iconițele se regenerează des,
  merită o unealtă în `tools/`. Altfel, nu.
- Sfera armilară (Știință) e cea mai încărcată la 30 px: carte, compas și sticlă
  în jurul sferei. Dacă nu se citește din prima, se poate regenera doar sfera.

---

## MENIUL ÎN BIBLIOTECĂ (22 octombrie 2026) — prima ușă primește înfățișarea din Practice

### Problema

Meniul de start era încă formularul de la început: un panou gri-albăstrui pe fond
plat, fontul implicit, butoanele implicite. Era singurul ecran rămas așa
(„Rămas deschis” din PERGAMENT ÎN BIBLIOTECĂ), și primul pe care-l vezi.

### Ce s-a făcut

- **Tema pergament pe rădăcina meniului**, ca la Practice. `StyleBoxFlat`-ul
  propriu din scenă și toate `modulate`-urile de culoare au ieșit; etichetele își
  iau rolul din `theme_type_variation`.
- **Fundalul**: biblioteca din luptă, prin același shader, dar abia estompată
  (`raza` 4, nu 22): aici nu se citește un paragraf peste ea, deci se vede ca loc
  — vitraliul, lumânările. Peste ea, o umbră în gradient pe jumătatea de jos, ca
  paginile să stea pe întuneric.
- **Titlul**: „MINDKEEP” în Cinzel 78, auriu, cu contur și umbră (variația nouă
  `TitluMeniu`), și o linie desenată dedesubt — două fire care se sting și un
  romb. Desenată, nu scrisă: un caracter decorativ ar fi depins de glifele
  fontului.
- **Două pagini una lângă alta** în locul a două butoane unul sub altul: o
  răscruce se vede ca două drumuri. Expediția poartă figurina de pe hartă
  (`campaign_token.png`), Practice creierul din chenar (`nota.svg`, colorat în
  roșul de rubrică). Fiecare are numele, rolul și un buton plin, roșu — variația
  nouă `ButonRubrica`, cu focus în ramă de cerneală (cea roșie nu s-ar fi văzut
  pe un buton roșu).
- **Mișcare puțină, dinadins** (meniul îl vezi în fiecare zi): un voal care se
  ridică în 0,7 s, paginile care apar pe rând, pagina cu focus ridicată cu 3,5%.
  Mouse-ul mută focusul, deci e mereu o singură pagină ridicată, cu mouse sau cu
  săgeți. Plus praf în lumina vitraliului: `CPUParticles2D` cu un gradient rotund
  generat de Godot, nicio imagine nouă.
- **Rândul de stare al expediției**: „0 noduri în urmă · 15 / 15 PV”, în roșu,
  pe pagina expediției. **Sămânța a ieșit de pe ecran** (e un număr pentru
  unelte) și se tipărește în consolă. „Noduri” se acordă: 1 nod, 2 noduri, 20 de
  noduri.
- **Diacritice** în textele meniului — Cinzel și Alegreya le au pe toate.
- **`nota.svg` se importă la 192 px, cu mipmap-uri** (era 64 px). Pe pagina din
  meniu creierul are ~104 px și ieșea pixelat; butonul din Practice are
  `expand_icon`, deci o textură mai mare se micșorează acolo singură, iar
  mipmap-urile țin micșorarea curată. Verificat cu o captură a întrebării.

Ce NU s-a schimbat: logica meniului. Încarcă o scenă și nu știe nimic despre ea;
harta își alege singură ecranul, la fel ca înainte.

### Verificat

Capturi cu `--write-movie`: meniul cu expediție în curs, un cadru din mijlocul
intrării și ecranul de întrebare din Practice (creierul din colț). Meniul fără
expediție și avertismentul pentru un save stricat n-au fost capturate.
`verifica_salvarea` trece.

### Rămas deschis

- ~~**Butonul de ieșire de pe hartă spre meniu**~~ — **făcut** pe 26 octombrie,
  vezi sesiunea IEȘIRILE DIN EXPEDIȚIE.
- Pagina Practice ar putea spune ceva viu (nivelul cel mai înalt, câte rafturi
  știute), dar asta ar fi meniul care începe să știe despre ecranul de după.
  Lăsat dinadins.

---

## SIMBOLURI CARE SEAMĂNĂ (21 octombrie 2026) — distractorii elementelor nu mai lasă răspunsul ghicit din alfabet

### Ce s-a văzut jucând

În Practice, Știință și tehnologie → Științe exacte: „Care este simbolul chimic al
iodului?” cu `Ne / C / I / Ni`. Răspunsul se ghicea fără să știi nimic: era
singurul buton care seamănă cu „iod”.

### Ce era, de fapt

La `cere_simbol` distractorii se alegeau dintre cele 70 de elemente din tabel, în
banda de nivel ±1. Iodul n-avea acolo niciun frate pe litera I, deci punctajul nu
deosebea pe nimeni și au ieșit cei aleși de zar. Măsurat pe toate 69 de întrebări
(aurul e în fișierul de mână), cu testul `seamana` (prima literă e a numelui, iar
celelalte apar în nume, în ordine): **la 20 răspunsul era singurul buton care se
poate citi ca prescurtare a numelui** (litiu, oxigen, iod, uraniu, zinc, xenon,
wolfram, cobalt, galiu, rubidiu, osmiu…).

### Ce s-a schimbat (doar `tools/fabrica/elemente.py` și fișierul de întrebări)

- **Fondul la `cere_simbol` sunt toate cele 118 elemente descoperite**, nu cele
  70. Banda de nivel apără de „trei nume obscure lângă unul celebru”, dar pe
  butoane stau simboluri, iar In și Ir nu arată mai obscur decât I.
- **Punctaj nou, `punctaj_simbol`**: aceeași primă literă ca răspunsul +100,
  seamănă cu numele +50 (oxigen → Og), prima literă apare în nume +20, e unul din
  cele 70 +5.
- **Unde alfabetul real se termină, simboluri INVENTATE din nume**: U, W și X
  n-au niciun frate printre cele 118, Z doar unul. Atunci litera întâi a numelui
  plus una din literele lui (uraniu → Ur, Un, Ua), fără diacritice și fără litera
  dublată (`Uu`, `Ii` se vedeau de departe). Stau sub orice simbol real cu litera
  răspunsului, deci apar doar unde cele reale nu ajung, și doar la elementele al
  căror simbol pornește de la numele românesc (nu la `DIN_LATINA`). Din cele
  inventate se scad toate cele 118 simboluri reale. Sunt **21 în 13
  întrebări**. E singurul loc din fabrică în care pe un buton stă ceva ce nu
  există. Nu predă nimic fals, fiindcă stă doar pe un buton greșit, iar întrebarea
  pe care o pune („U sau Ur?”) e chiar cea pe care trebuie s-o știi.
- **O a doua gardă, numai la sensul ăsta**: dacă niciun distractor nu seamănă cu
  numele, ultimul se schimbă cu primul care seamănă. Fără ea, sulful ieșea `S / Sb
  / Sc / Sn`: toate reale, toate pe S, niciunul citibil din „sulf”. Acum e `Sl`.
- Garda veche („grupul de litere care nu e despre întrebare”) a ieșit într-o
  funcție, `rupe_grupul_strain`, folosită de ambele sensuri.

Rezultatul: `iod → Ir / In / Io / I`, `uraniu → Ur / U / Un / Ua`, `oxigen → Og /
O / Os / Ox`, `zinc → Zn / Zr / Zi / Z`. **Ghicibile după `seamana`: de la 20 la
0.** S-au schimbat exact cele 69 de rânduri `cere_simbol`, niciun `cere_nume`, și
niciun `id`. Se schimbă doar ce e pe butoane, deci save-ul nu simte nimic.

### Verificat

- `elemente.py --scrie`: „exact una din patru e corectă” pe toate 139.
- `verifica_trivia`: TOTUL E BUN, cod 0.
- **Nevăzut în joc.** Cifrele vin din fișier, nu de pe ecran.

### Sensul invers, tot azi: „Ce element chimic are simbolul…?”

Jucând, imediat după: „Ce element chimic are simbolul U?” cu `siliciu / uraniu /
litiu / neon`. Răspunsul era singurul nume pe litera simbolului, la **10 din 70**
(litiu, oxigen, titan, zinc, iod, uraniu, kripton, xenon, wolfram, osmiu). Frații
de literă existau des, dar la doi niveluri distanță (indiu și iridiu lângă iod,
tantal lângă titan), iar banda de nivel îi tăia.

- **Banda de nivel rămâne**, cu motivul ei (trei nume obscure lângă unul celebru
  se recunosc). Dar dacă niciun distractor nu e pe litera simbolului, **ultimul se
  schimbă cu UN frate de literă**: întâi din restul tabelului, apoi dintr-o
  rezervă nouă — celelalte elemente descoperite, cu eticheta română de la
  Wikidata (lutețiu, zirconiu). Rezultat: `iod → siliciu / iod / sulf / iridiu`,
  `zinc → aluminiu / cupru / zinc / zirconiu`.
- **Unul singur, fiindcă prima probă a lăsat literele să bată nivelul peste tot**
  și a stricat 9 întrebări bune: neonul își pierdea capcanele (azot, sodiu)
  pentru niobiu și neodim, iar litiul primea trei nume pe care nu le-a auzit
  nimeni. Acum s-au schimbat exact 6 întrebări, restul sunt octet cu octet ca
  înainte.
- **Patru întrebări nu se mai scriu: U, Kr, Xe, W.** Printre toate cele 118 nu
  există niciun alt element pe U, K, X sau W, deci „ce element are simbolul U?” se
  rezolvă din alfabet, oricare ar fi distractorii. Un nume de element INVENTAT nu
  e o ieșire: „Ur” e o prescurtare care nu există, dar un element care nu există e
  un lucru fals de ținut minte. Sensul celălalt („simbolul uraniului”) rămâne. E o
  măsurătoare, nu o listă: dacă tabelul primește un frate de literă, întrebarea
  revine singură, cu același `id`. Scriptul tipărește la fiecare rulare câte a
  lăsat afară.
- **Elementele trec de la 139 la 135 de întrebări**, iar jocul de la 2839 la 2835.
  Un `id` dispărut care era deja în progresul din Practice rămâne acolo inofensiv
  (`din_dictionar` îl citește ca orice text), deci nimic nu se pierde.

`verifica_trivia`: TOTUL E BUN, cod 0. Nevăzut în joc nici sensul ăsta.

---

## LA CE FOLOSEȘTE ELEMENTUL (21 octombrie 2026) — notele elementelor chimice

### Cererea

Notele de la Știință și tehnologie → Științe exacte, la întrebările cu simboluri
chimice, spuneau toate același lucru: „Simbolul chimic al aluminiului este Al, iar
numărul lui atomic este 13.” Adică răspunsul de pe buton, înapoi. Cererea: să
spună și ceva util — la ce folosește aluminiul, la ce e bun carbonul.

### Ce s-a încercat întâi: Wikidata

Wikidata are proprietatea „has use” (`P366`). La cele 70 de elemente ale
tabelului e plină la **19** și, unde e plină, e de nefolosit: aluminiului îi
spune „colorant”, oxigenului „aditiv alimentar”. Descoperirea (anul `P575`,
descoperitorul `P61`) e plină la 65 din 70 și ar fi fost un cârlig curat, cu
sursă — dar e alt lucru decât cel cerut. A rămas nefolosită, ca opțiune.

### Ce s-a făcut

- **O coloană nouă, `folosinta`, în `tools/fabrica/date/elemente.json`**: o
  propoziție pe element, scrisă de mână, care începe cu numele lui („Aluminiul e
  ușor și nu ruginește, așa că din el se fac doze…”). Scriptul o cere la toate
  70 și verifică să înceapă cu numele elementului de pe rândul ei (prinde o
  propoziție lipită pe rândul vecinului) și să se termine cu punct.
- **Șablonul nou:** folosința, apoi „Are simbolul chimic Al și numărul atomic
  13.”, apoi, la cele 9 din `DIN_LATINA`, propoziția despre latină. Varianta
  veche, „numărul lui atomic”, era greșită la platină; cea nouă n-are gen.
- **Notele au acum 165–238 de caractere** (mediana 191), față de ~70 înainte.
  Întrebările nu s-au schimbat deloc: s-a rescris doar
  `data/trivia_gen/elemente_fapte.json`.

### Principiul călcat, spus pe față

„Modelul de limbaj formulează, nu informează”: propozițiile din `folosinta` au
ca sursă modelul, ca cele 2046 din TOATE AU NOTĂ. Prețul a fost ținut mic așa:

- conținut de manual — folosințele cunoscute (doze de aluminiu, filamente de
  wolfram, ceasuri atomice cu cesiu), fără detalii fine;
- **`folosinta` NU intră în `surse` la `comun.verifica_nota`**, deci validatorul
  interzice în continuare orice cifră și orice nume propriu în ea. Acolo stau
  greșelile care sună bine; ce rămâne neapărat e afirmația în cuvinte, care se
  citește.

Faptele rămân `verificat: false`. Cele care merită citite primele sunt cele de la
nivelul III, unde folosințele sunt cele mai puțin cunoscute (ruteniu, telur,
taliu, poloniu).

---

## CREIERUL DIN CHENAR (21 octombrie 2026) — „Afla mai multe" devine iconiță, anunțul vine o dată

### Ce s-a văzut jucând

1. Butonul „Afla mai multe" de sub chenar nu-mi plăcea acolo.
2. Trecerea singură se oprea când duceam mouse-ul spre butoanele de sub chenar.
   **Cauza:** butonul apărea la verdict și împingea rândul de dedesubt cu ~44px,
   deci ajungea chiar sub cursorul cu care tocmai răspunsesem, iar
   `mouse_entered` oprea bara fără să fi mișcat mâna.
3. „Ai raspuns corect la tot raftul… De aici e recapitulare" stătea deasupra
   întrebării toată sesiunea și reapărea la fiecare intrare pe raft.

### Ce s-a făcut

- **Un creier în colțul din dreapta-sus al chenarului** (`ButonNota`, game-icons
  „brain" de Lorc, CC BY 3.0, în `assets/iconite/practice/nota.svg` cu
  `CREDITE.txt` lângă). E mereu acolo: **stins** până la verdict (nota ți-ar da
  răspunsul), **aprins** în roșu de rubrică după verdict dacă întrebarea are
  notă, cu un puls scurt la aprindere; stins în continuare dacă n-are. Tooltip
  diferit pe fiecare stare. Stă într-un `StratNota` pus PESTE scena de trivia,
  în `practice.tscn`, deci lupta nu-l vede; copia de trivia se mută în spatele
  lui (`move_child(nou, 0)`), altfel rădăcina ei prindea click-ul.
- **Decizia veche s-a întors, cu motiv:** „fără notă, butonul nu există
  (`visible = false`)". Ascuns, butonul mișca ecranul și fura mouse-ul; o
  iconiță pe loc fix care nu se aprinde spune la fel de clar că nota lipsește.
  (Azi, de altfel, toate cele 2839 de întrebări au notă — starea „stins după
  verdict" contează pentru disciplinele care n-au pus încă nimic în `explicatie`.)
- **Tema:** `LegaturaPergament` are acum stiluri goale pe toate stările (altfel
  marginile butonului lăsau iconiței 12 px) și `icon_disabled_color` în cerneală
  la 28%.
- **Bara de trecere se oprește NUMAI la apăsarea creierului** (mouse sau
  tastatură). `mouse_entered` și `focus_entered` nu mai sunt legate.
- **Anunțul de raft parcurs vine o singură dată**, în clipa în care raftul s-a
  terminat, și pleacă la întrebarea următoare (`_intrebare_noua` îl golește; la
  fel și pe cel de nivel deblocat). Nu se mai anunță la intrarea pe un raft deja
  parcurs: o spune **„Nivel I · 100%"** în dreapta butonului din lista de rafturi
  (prima variantă, din aceeași zi, era cuvântul „parcurs"). Procentul apare
  doar la 100%: pe toate rafturile ar fi fost iar un tabel de cifre.
- **Subtitlul de pe ecranul de rafturi a ieșit** („Alege raftul. Primul
  cuprinde tot domeniul…"), cu nod cu tot: o explicație citită o dată, apoi
  doar text în plus. Ecranul de domenii îl pierduse deja.
- **Un anunț oprește trecerea singură**: două propoziții nu se citesc în 2 s,
  deci la răspunsul care termină raftul sau deschide nivelul bara nu pornește.

### Verificat

`verifica_trivia` trece. O probă temporară, cu fereastră și cu `Arhiva.dosar`
mutat într-un dosar de test (ștearsă după): creierul stins înainte de răspuns,
aprins după; anunțul apare la ultimul răspuns din raft, bara nu pornește, iar
la „Următoarea" anunțul pleacă; „Nivel I · 100%" pe raftul terminat; mouse-ul pe creier
nu mai oprește bara, apăsarea o oprește și deschide nota.

### Rămas deschis

- Mărimea creierului (30 px) și pulsul (1,3× → 1×, 0,3 s) sunt de pornire,
  nejucate.
- Anunțul încă împinge chenarul în sus când apare (era și înainte). Dacă
  deranjează, rândul poate avea înălțime rezervată.

---

## ICONIȚE PE DOMENII (21 octombrie 2026) — cifrele pleacă de pe butoanele din Practice

### Problema

Fiecare buton din „Alege domeniul" și din lista de rafturi scria „— 117 la
nivelul I". Opt rânduri de cifre se citeau ca un tabel, nu ca un meniu, iar pe
un raft activ cifra nu decide nimic din ce faci.

### Ce s-a făcut

- **O iconiță pe domeniu**, monocromă, de pe game-icons.net (CC BY 3.0), în
  `assets/iconite/domenii/`: glob, coroană, balon de laborator, pană cu
  călimară, măștile de teatru, cununa de lauri, pocal, clepsidră. Fișierul se
  numește după CHEIA domeniului, deci `_iconita()` din `practice.gd` îl găsește
  fără niciun tabel; fără fișier, butonul iese fără iconiță. Autorii și licența
  sunt în `CREDITE.txt` de lângă ele. Importate la `svg/scale=0.125` (64 px),
  micșorate la înălțimea butonului cu `expand_icon`.
- **Culoarea o dă tema**: `Button/colors/icon_*` în `pergament.tres`, roșul de
  rubrică (ca inițialele dintr-un manuscris), stins la 35% pe butoanele
  dezactivate. Iconițele sunt albe în fișier ca să le poată colora tema.
- **Pe domenii, în dreapta, doar nivelul**, cifră romană măruntă. Nivelul e pe
  domeniu, iar antetul îl arată abia după ce ai ales un domeniu, deci ăsta e
  singurul loc unde le vezi pe toate opt.
- **Pe rafturi, nimic — în afară de cele goale**, pe care scrie „gol la
  nivelul II". Decizia „Rafturile goale apar, dezactivate" rămâne în picioare:
  un raft stins tot îți spune de ce e stins, deci tot e o hartă a conținutului
  care lipsește. Cifra exactă a dispărut de pe ecran.

### De ce iconițe desenate și nu emoji

Emoji-urile nu sunt în Cinzel/Alegreya, deci Godot le-ar fi luat din fonturile
sistemului: colorate pe Windows, ca un sticker pe pergament, și probabil
pătrățele goale la exportul web, unde nu există fonturi de sistem. Și o singură
iconiță pe domeniu, nu minge + controller: două pe fiecare din opt butoane se
bat între ele.

**Sport și jocuri a schimbat iconița în aceeași zi.** Calul de șah (Skoll) arăta,
la 34 px, ca un cal cocoșat. Au fost puse alături, în joc, opt variante: capete
de cal, trofee, lauri, minge, turn de șah. Au rămas **lauri** (Lorc): se citesc
la mărimea butonului, spun „victorie" și pentru sport, și pentru jocuri, iar
trofeul semăna prea tare cu pocalul de la Gastronomie.

**Subtitlul a ieșit** de pe „Alege domeniul" („Nivelul urca singur… Fara
cronometru."): iconițele și nivelul din dreapta îl făceau de prisos. Pe ecranul
de rafturi subtitlul rămâne, fiindcă acolo explică „Tot domeniul".

### Verificat

`verifica_trivia` și `verifica_salvarea` trec. Ecranele capturate cu
`--write-movie`: domeniile cu iconițe și nivel; rafturile Geografiei, plus un
raft gol de probă (scos după captură), cu „gol la nivelul II" pe el.

### Rămas deschis

- **CC BY cere credit afișat.** Azi creditul e doar `CREDITE.txt`; când apare un
  ecran de credite în joc, rândurile de acolo intră în el (la fel și fonturile,
  și steagurile).
- Nivelul de pe domenii e un „I" singur. Dacă se dovedește neclar la joacă,
  „Nivel I" e un cuvânt în `_buton_raft`.

---

## PERGAMENT ÎN BIBLIOTECĂ (21 octombrie 2026) — Practice primește înfățișarea hărții

### Problema

Practice și meniul arătau ca un formular: panouri gri-albăstrui pe fond plat,
butoanele implicite din Godot. Harta are pergament pe masă, cerneală și obiecte
pictate. Am propus patru pași (temă și font · progres vizibil · artă proprie ·
„juice"); sesiunea asta e **pasul 1**.

### Ce s-a făcut

- **O temă comună**, `assets/tema/pergament.tres`, pusă pe rădăcina din
  `practice.tscn`: pagini de pergament cu umbră, butoane de hârtie cu ramă de
  cerneală, titluri în roșu de rubrică. Etichetele își iau rolul din
  `theme_type_variation` (`TitluPergament`, `SubtitluPergament`,
  `RubricaPergament`, `AntetPergament`, `AntetSecundar`, `ChenarPergament`,
  `LegaturaPergament`), nu din `modulate`.
- **Fonturi**: Cinzel (titluri) și Alegreya (text), variabile, din repo-ul
  Google Fonts, în `assets/fonturi/`, cu `OFL.txt` lângă fiecare. Au fost
  verificate pe glife înainte de folosire: ș, ț cu virgulă, Ă, Â, Î, „”, —, ·
  există toate. Licența permite vânzarea jocului cu ele înăuntru. Condiția e
  ca textul licenței să rămână lângă fișiere.
- **Fundalul**: `fight_background.jpg`, prin shaderul
  `assets/tema/fundal_estompat.gdshader` (estompare pe spirală, tentă caldă,
  vinietă pe ecran). Aceeași poză din luptă, fără o a doua copie.
- **Pagina întrebării**: tot panoul de întrebare (anunț, chenar, „Află mai
  multe", butoanele de jos) stă acum pe o singură pagină, `Pagina`, nu pe fond.
- **Culorile de verdict vin din temă**, când tema le dă: `_culoare()` în
  `puzzle.gd`, tipul „Puzzle” în temă. Verdele luptei, înmulțit prin
  `modulate` cu pergamentul, ieșea verde de semafor. Lupta nu pune nicio temă,
  deci acolo nu s-a schimbat nimic.
- **`Anunt` gol e ascuns** (`_anunta()` în `practice.gd`): un Label gol cerea
  un rând și lăsa o bandă goală pe pagină.

### Verificat

`verifica_trivia` 38, `verifica_salvarea` 54, `verifica_eveniment` 22, toate cu
cod 0; lupta pornește fără erori. Ecranele au fost capturate cu
`--write-movie` (domenii, rafturi, întrebare, verdict greșit, notă). Răspunsul
CORECT n-a fost capturat (ar fi scris pe disc), dar folosește aceleași culori.

### Rămas deschis

- ~~**Meniul de start** e încă formular.~~ **Făcut** pe 22 octombrie, vezi MENIUL ÎN BIBLIOTECĂ. Tema i se pune cu un rând, dar avea
  propriul `StyleBoxFlat` în scenă care trebuie scos.
- **Variantele de răspuns au 14 px**, scrise pe noduri în `puzzle.tscn`; tema
  nu le poate bate. Alegreya are litere mici mai scunde decât fontul implicit,
  deci arată mai mărunt. Se rezolvă scoțând override-ul din `puzzle.tscn` și
  dându-i luptei mărimea ei, nu aici.
- Pașii 2-4 din propunere (progres vizibil, artă proprie, „juice").
- Textele scrise fără diacritice („Inapoi", „Afla mai multe") se văd mai tare
  cu un font cu serife.

---

## PODEAUA DE LUPTE (21 octombrie 2026) — drumul spre Boss nu mai poate ocoli aproape tot

### Ce s-a văzut jucând

Sămânța 1000 pe `harta_01`: de la nodul 5 se putea merge Odihnă → Magazin →
Eveniment → Odihnă → Boss, adică toată expediția cu Startul și încă o luptă.
Nicio regulă nu întreba câte lupte are drumul ÎNTREG. Pragurile de început
(Magazin, Elită, Odihnă) și cel de final (bătaie la 2 pași de Boss) se țineau
toate, iar ocolul era strategia corectă, nu o alegere.

### Măsurat înainte de scris (500 de semințe, Startul numărat ca luptă)

| hartă | 2 lupte | 3 lupte | 4+ |
|---|---|---|---|
| `harta_01` | 10% | 90% | 0% |
| `harta_02` | 41% | 59% | 0% |
| panglica | 10% | 75% | 15% |

Pragul 4 dădea **0 plasări valabile din 4000** pe amândouă planșele, cu rețeta
de azi. Pe `harta_02` nu ajungea nici cu două Evenimente mutate în Lupte
(6,1%, sub cele 8% din `REUSITE_LA_PROBA`). Planșele se despică devreme în
brațe, iar fiecare braț ar cere propria bătaie: aceeași poveste ca la
`LUPTE_MINIME_ELITA`. Pragul 3 încăpea: `harta_01` 57%, panglica cel puțin
14,5% pe cea mai rea formă, iar `harta_02` **8,75%, adică la limită**.

### Ce s-a făcut

`LUPTE_MINIME_PANA_LA_BOSS` = 3 și regula `_regula_podea_de_lupte`
(„prea puține lupte până la boss”) în `_reguli_picate`. Citește tot
`_lupte_minime()`, ca pragurile Magazinului și Elitei, doar că în nodul Bossului.
`PROPORTII` NU s-a atins.

### Ce s-a întâmplat totuși cu rețeta, singură

Proba de rețetă (`_taiata_pana_incape`) folosește regulile adevărate, deci a
văzut regula nouă. Pe `harta_02`, cu rata la limită, a **tăiat un Eveniment pe
toate cele 500 de semințe**: harta are acum 2 Evenimente și 6 Lupte (cu Start),
nu 3 și 5. Exact pârghia propusă, doar că aplicată de mecanism, nu de mână, și
numai unde forma o cere. Pe panglică, hărțile tăiate de formă au crescut de la
22% la 34% (12 noduri) și de la 59% la 63% (14 noduri). `harta_01` n-a pierdut
nimic.

### Verificat

`verifica_tipuri`, `verifica_harta`, `verifica_plansa`, `verifica_drumuri`,
`verifica_eveniment` și `verifica_salvarea`: toate cu cod 0. Nicio sămânță n-a
atins limita de încercări. Maximul a rămas 9 / 19 / 83 din 200. Regula nouă pică
în 2-6% din încercări, deci filtrează, nu blochează.

### Rămas deschis

- Pe `harta_02`, tăietura Evenimentului e o DECIZIE luată de probă. Dacă vreau
  înapoi 3 cufere acolo, prețul e pragul, nu proba.
- Podeaua nu face luptele TENTANTE. Asta rămâne la recompense: ce dă o luptă și
  ce vinde Magazinul pentru Boss.

---

## TRECEREA SINGURĂ (21 octombrie 2026) — fără click pe „Următoarea" după un răspuns corect

### Problema

În Practice trebuia apăsat „Următoarea" după fiecare întrebare. Trecerea pur
automată ar fi luat însă fereastra în care poți deschide „Află mai multe".

### Ce s-a decis, și de ce nu toggle-ul propus inițial

Propunerea de la care am pornit: un comutator on/off și 3 secunde invizibile, în
care un click pe notă oprește trecerea. Ce s-a ales în loc:

- **Automat NUMAI la răspuns corect.** La greșit ai cea mai mare nevoie de notă,
  deci acolo nu curge nimic. La corect știai deja: e nota cea mai ieftină de
  pierdut, iar aproape tot clicul care enerva era aici.
- **Bara se vede**: „Următoarea" se umple de la stânga în `PAUZA_AUTO` = 2,0 s
  (`practice.gd`). Se adaugă peste `PAUZA_SUSPANS` (0,35 s), deci de la click la
  întrebarea următoare trec ~2,35 s. Cifră de pornire, nejucată. (Inițial se
  adăuga peste toată `PAUZA_FEEDBACK` de 1,8 s, adică ~3,8 s — vezi mai jos,
  „Află mai multe, fără așteptare”.)
- **Orice gest spre notă o oprește**: mouse-ul pe „Află mai multe", focusul pe
  el (Tab) sau apăsarea lui. Oprită, bara dispare și rămâi pe manual. Click
  pe „Următoarea" (sau Enter) trece imediat, ca înainte.
- **Fără comutator.** Cu regulile de mai sus, cazul în care l-ai vrea oprit
  aproape dispare, iar o setare ar fi însemnat un câmp în `permanent.json` și
  un loc în UI. Dacă jucând se dovedește că trebuie, e o adăugare.

### Cum e făcut

- `BaraAuto`, un `ColorRect` copil al lui `ButonUrmatoarea` (`practice.tscn`):
  ancorat pe tot butonul, `mouse_filter` pe IGNORE, galben-auriu la 22%.
  Tween-ul îi duce `scale.x` de la 0 la 1, apoi cheamă `_intrebare_noua`.
- `_porneste_auto` / `_opreste_auto`. Oprirea stă și în `_inchide_puzzle`, deci
  „Schimbă domeniul" și orice drum care scoate întrebarea omoară și bara. Altfel
  ar fi putut aduce o întrebare peste ecranul de rafturi.
- Un amănunt aflat la probă: `Control` nu acceptă scala exact 0 și o înlocuiește
  cu un epsilon. Bara e invizibilă oricum, dar o verificare cu `== 0.0` pică.

### Verificat

O probă temporară (ștearsă după rulare, cu `Arhiva.dosar` mutat ca să nu atingă
save-ul) a jucat ecranul și a dat **12 din 12**: la corect bara pornește, e la
jumătate după 1 s și trece singură; la greșit nu pornește și rămâne; mouse-ul pe
notă și deschiderea notei o opresc; „Schimbă domeniul" nu lasă nicio întrebare să
vină peste rafturi. `verifica_trivia` trece în continuare. **Nu e probat cu mâna,
în joc**: cum arată bara și dacă 2 s sunt prea multe sau prea puține.

### Află mai multe, fără așteptare (tot 21 octombrie)

Jucând: după răspuns, „Află mai multe” apărea abia după 1,8 s. Cauza era
`PAUZA_FEEDBACK` din `puzzle.gd` — `rezolvat` se strigă abia după ea, iar
Practice afla de răspuns tot din `rezolvat`. Pauza e făcută pentru luptă, unde
după `rezolvat` panoul se închide și e singurul timp în care vezi răspunsul
corect. În Practice răspunsurile colorate stau pe ecran până la „Următoarea”,
deci partea ei de citire (`PAUZA_CITIRE`, 1,45 s) nu mai făcea decât să țină
butonul ascuns.

- **Comutator nou în contract, `cu_pauza_citire`** (`puzzle.gd`, punctul 7):
  `true` în luptă, stins de Practice lângă `cu_cronometru`. Separat de el,
  fiindcă „curge timpul?” și „unde mă întorc după?” sunt două întrebări.
- **Suspansul de 0,35 s rămâne**, deci butonul apare odată cu culorile, nu în
  cadrul clickului. Bara de trecere pornește numai la corect: un `rezolvat`
  strigat înaintea culorilor ar fi spus verdictul prin bară.
- Probă temporară (ștearsă): de la click la `rezolvat`, **1,66 s în luptă**
  (neschimbat, primul cadru încărcat) și **0,35 s în Practice**.
  `verifica_trivia` trece (cod 0).
- Consecință: trecerea singură vine acum la ~2,35 s după click, nu ~3,8 s.
  Dacă se simte grăbită, se crește `PAUZA_AUTO`.

---

## RAFTUL PARCURS (21 octombrie 2026) — neștiutele întâi, greșita la distanță

### Ce s-a văzut jucând

În Practice, pe „Geografie fizică", întrebarea despre Kalahari a revenit la două
întrebări distanță, deși primise răspuns corect. Iar antetul stătea la
„Nivel I · 25 / 60", oricât ai fi răspuns.

### Ce era, de fapt

Nu era un bug în sac. Save-ul arăta 25 de știute la `geografie:1`, exact cele 25
de întrebări de nivel I ale raftului. Sacul se golise și pornise un ciclu nou,
iar regula de la răscruce exclude doar ULTIMUL bilet: Kalahari fusese printre
ultimele din ciclul vechi și a ieșit prima în cel nou. Contorul nu era nici el
stricat. Pragul de 60 se numără pe DOMENIU, iar geografia are 117 întrebări la
nivelul I, însă un raft știut tot nu-l mai poate mișca. Problema era că
ecranul nu spunea nimic din toate astea.

### Ce s-a schimbat

- **`trage_din_raft` primește `stiute` și `recente`** (`trivia.gd`) și trage în
  ordine din trei liste: neștiutele care nu sunt recente, apoi tot raftul fără
  cele recente (umplutura de la final și, după aceea, recapitularea), apoi
  raftul întreg dacă e prea mic. Sacul rămâne UNUL pe raft, cu aceeași cheie,
  iar o greșită revine de la sine DUPĂ celelalte neștiute.
- **`DISTANTA_PRACTICE = 3`**, cifră de pornire, nejucată. O întrebare nu
  revine înainte să treacă alte 3, ca varianta corectă văzută la feedback să nu
  fie răspunsul „gratis" de la tragerea următoare. Fereastra e `recente` din
  `practice.gd`. Nu se scrie pe disc și se golește la schimbarea raftului.
- **Anunțul** (`_anunt_raft_parcurs`) apare când raftul devine știut tot sau la
  intrarea pe un raft deja parcurs. Spune că de aici e recapitulare și câte mai
  lipsesc până la nivelul următor. Dacă domeniul n-are destule neștiute, spune
  și asta. Anunțul de nivel deblocat are prioritate.
- **`nestiute` și `raft_parcurs`** sunt statice în `practice.gd`, ca să le
  poată întreba verificarea. Tot de aceea `_cheia_celulei` a devenit statică.
- **`verifica_trivia`: 5 verdicte noi** (secțiunea 9b): o sesiune jucată de
  script, cu o întrebare greșită de două ori. Se cer patru lucruri: neștiutele
  vin întâi, nicio întrebare nu iese în 3 trageri, greșita revine și raftul
  ajunge știut tot, iar umplutura chiar apare. `raft_parcurs` trebuie să
  spună „nu" cu o neștiută și „da" cu zero.

Formatul save-ului nu s-a schimbat.

### Ce NU s-a făcut

- „Știut" înseamnă în continuare „corect o dată". Regula „învățat" (2–3
  corecte la distanță în timp) și Jurnalul rămân felia următoare. Ele schimbă
  doar cine iese din neștiute.
- Garanția sacului în LUPTĂ e neatinsă: la răscruce exclude tot numai ultimul
  bilet. Acolo sacul se golește la fiecare expediție, deci granița se atinge
  rar.
- Nimic nu e încă probat cu mâna, în joc. Scriptul bate tragerea și
  `raft_parcurs`, dar nu textul anunțului și nici cum încape el pe ecran.

---

## TOATE AU NOTĂ (12–13 octombrie 2026) — cele 2046 scrise de mână, și decizia răsturnată în aceeași zi

A treia cerere din aceeași zi, după NOTELE SE FABRICĂ și AL PATRULEA TABEL:
*„adauga nota si la intrebarile scrise de mana (cele 2142). fiecare intrebare sa
aiba o nota scrisa"*, completată imediat cu *„vreau ca intrebarile scrise de mana
sa aiba aceeasi structura ca pana acum, impartite pe rafturile corespunzatoare
(domenii, subdomenii etc), doar sa apara notele la fiecare"*.

Dimineață, cu cifrele pe masă, răspunsul fusese **nu**. Seara, cu aceleași cifre
pe masă, a fost **da** (scrisul celor 2046 a trecut peste miezul nopții, în 13). Sesiunea asta scrie amândouă, fiindcă a doua n-are sens
fără prima.

### Ce s-a spus înainte de a se scrie o literă

Decizia din CLAUDE.md, „Întrebările fără sursă rămân fără notă", a fost pusă pe
masă cu motivul ei: cele 2046 n-au niciun tabel în spate, deci singura sursă
posibilă sunt eu, modelul de limbaj — vreo 5000 de afirmații, din care 1% greșite
sunt 50 de fapte false predate de un joc de învățare. Aceeași greșeală pe care o
apără principiul „modelul de limbaj formulează, nu informează", doar venită pe
ușa din față.

Peste decizie s-au pus trei măsurători noi, care nu erau în ea:

- cele 2046 **nu au niciun câmp `fapt`** — zero. Nu era „leagă întrebările la
  faptele care au deja notă" (drumul ăla fusese probat și căzuse, vezi AL
  PATRULEA TABEL), era „scrie 2046 de fapte noi";
- sunt împărțite **egal pe cele 31 de rafturi**, ~66 fiecare. Nicio grămadă pe
  care un tabel din fabrică s-o poată mânca — deci drumul prin fabrică nu le
  atingea nici în cinci tabele;
- pe niveluri: **678 la I, 684 la II, 684 la III**. Asta era cifra care schimba
  socoteala, fiindcă nivelul I e, prin propria lui definiție, „o știe orice
  adult": zona în care e cel mai greu să mă înșel.

Au fost scrise atunci patru note de probă, pentru întrebări reale, iar una dintre
ele a fost chiar ilustrarea problemei: la `mana:2118` (Xhosa), prima variantă
spunea „trei consoane-clic", ceea ce e greșit — sunt trei *feluri* de clicuri,
dar cu mult mai multe consoane. A fost prinsă înainte de a intra. **Aia e forma
pe care o iau cele 1%**: nu o inventare pe față, un număr cu o jumătate de grad
pe lângă, într-o propoziție care sună perfect.

S-au propus patru drumuri: un raft ca probă (~66, citit integral, cu rata de
greșeli măsurată pe conținutul meu), nivelul I întâi (678), toate 2046 în loturi,
sau niciuna și încă un tabel în fabrică. **Alegerea a fost: toate 2046.** De
acolo încolo a fost execuție, nu dezbatere.

### Structura: nicio schimbare, doar un rând în plus

Cererea a doua a fixat forma: structura rămâne exact cum era. Ce s-a făcut:

- fiecare întrebare a primit un câmp **`fapt`, cu valoarea egală propriului `id`**
  (`"fapt": "mana:0001"`), așezat după `verificat`, exact unde stă la cele 96 care
  îl aveau deja. Niciun câmp nou, nicio cheie în afara lui `CAMPURI_INTREBARE`;
- fiecare a primit un fapt în **`data/fapte_trivia.json`** — fișierul care exista
  deja pentru faptele scrise de mână, deci **zero linii de cod schimbate**:
  încărcătorul îl citea oricum, iar popup-ul „Află mai multe" merge din prima;
- `categorie`, `subcategorie` și `nivel` **n-au fost atinse niciodată**. Verificat
  după: 8 domenii, 31 de subcategorii, 0 întrebări fără raft, aceleași 9 câmpuri.

Faptul cu `id`-ul întrebării e o alegere, nu o scăpare: aici raportul e 1:1, deci
faptul *e* întrebarea. La conținutul fabricat rămâne cum era, un fapt pentru mai
multe întrebări.

### Unealta: inserție în text, nu rescriere de JSON

Primul merge a fost scris ca writer de JSON și a fost **aruncat după prima
probă**: pe un lot gol, round-trip-ul ștergea 46 de rânduri goale — cele cu care
întrebările sunt grupate la fiecare ~8, scrise de mână. Un writer corect nu le
putea păstra, fiindcă pentru el nu există.

A doua variantă face **inserție de rând în text**: caută `"id": "mana:XXXX",`,
verifică dacă pe rândul următor e `"verificat"` și, dacă da, strecoară `"fapt"`
după el. Nimic altceva nu e atins. Proba: **pe un lot gol nu schimbă niciun
octet.** Faptele se adaugă tot textual, înaintea `]`-ului final. Scriptul se
oprește înainte de orice scriere dacă un `id` nu există, dacă nota e goală, dacă
întrebarea are deja `fapt` sau dacă fișierul de fapte nu se termină cum se
așteaptă, și recitește amândouă fișierele ca JSON după scriere. E în scratchpad,
nu în `tools/`: dacă s-ar fi adăugat în repo, ar fi fost mașinărie pentru o
muncă de o zi (vezi UN SINGUR FLAG).

Diff-ul final e **numai inserții**: 2046 de rânduri în `intrebari_trivia.json`,
8184 în `fapte_trivia.json`. Rândurile goale: 46, câte erau.

### Cum au fost scrise cele 2046

**Raft cu raft**, în 15 loturi de 118-150. Argumentul nu e de comoditate: notele
dintr-un domeniu scris într-o ședere ies consecvente între ele, iar la citire pot
fi verificate pe rafturi, nu la întâmplare. Fiecare lot a trecut prin merge
imediat, deci progresul a fost durabil în repo la fiecare pas — dacă sesiunea s-ar
fi oprit la lotul 7, cele 993 de până acolo rămâneau.

Regulile ținute la scris:

- nota **nu repetă răspunsul**, îl așază: de ce, de unde, ce urmează. „Jupiter e
  cea mai mare" nu e notă; „de două ori și jumătate mai masiv decât toate
  celelalte la un loc" e;
- cifrele doar unde sunt sigure, altfel formulare care nu minte: „peste 90 de
  luni", „circa 11 000 de metri", „sub jumătate de kilometru pătrat";
- la Divertisment și Sport, **numai trecut, cu data spusă**, exact cum cere
  CLAUDE.md. De-aia nota lui Burj Khalifa spune „la inaugurarea din 2010 a
  devenit cea mai înaltă clădire a lumii", nu „este"; iar la Real Madrid, „de
  cincisprezece ori până în 2024";
- unde subiectul e disputat sau contestat, nota o spune, nu o netezește
  (foie gras, Zidul Plângerii, originea pisco).

Limita de 240 de caractere (`MAX_NOTA`) e respectată la toate 2046: **zero note
peste**.

### Trei greșeli găsite ÎN ÎNTREBĂRI, nu în note

Scrisul notelor a fost și o citire atentă a celor 2046, pentru prima dată. Trei
întrebări au fapte greșite în ele, iar notele lor au fost scrise ocolind cifra
greșită, nu repetând-o:

| întrebare | ce scrie | ce e |
|---|---|---|
| `mana:0336` | serialul Naruto „început în 1997" | manga din 1999, serialul animat din 2002 |
| `mana:0423` | Gopo „premiat la Cannes în 1966" | Palme d'Or pentru scurtmetraj în **1957**, cu „Scurtă istorie" |
| `mana:0440` | Inter, „trei Cupe ale Campionilor în anii 1960" | **două**: 1964 și 1965 |

Plus două întrebări pe raftul greșit: `mana:1899` (Mike Tyson, box) și
`mana:1155` (vârfurile de peste 8000 m) stau amândouă pe `motor_extreme`.
**Niciuna din cele cinci nu a fost schimbată** — sunt întrebări, nu note, și
schimbarea unui text de întrebare e altă decizie decât asta. Rămân la „Rămas
deschis".

### Unde a ajuns acoperirea

| | dimineață | după fabricare | după al patrulea tabel | acum |
|---|---|---|---|---|
| întrebări cu notă | 96 / 2692 | 646 / 2692 | 793 / 2839 | **2839 / 2839** |
| adică | 1 din 28 | 1 din 4,2 | 1 din 3,6 | **toate** |

**2138 de fapte, toate cu notă.** Butonul „Află mai multe" apare de acum la
fiecare întrebare din joc, la toate cele opt domenii și toate cele 31 de rafturi,
și în luptă și în Practice.

`verifica_trivia` trece — 33 de verdicte, 2839 de întrebări încărcate din 2839
găsite, cod 0. `verifica_salvarea` și `verifica_eveniment`: cod 0.

### Ce rămâne scris negru pe alb

**Sursa celor 2046 de note sunt eu, nu un tabel.** Nu există validator care să le
bată, fiindcă nu există date din care să fi fost compuse — `comun.verifica_nota()`
poate cere ca fiecare cifră dintr-o notă fabricată să existe în tabelul ei, dar
aici nu e nici tabel, nici șablon. Singura verificare posibilă e citirea, iar
câmpul `verificat` e exact pentru asta: **28 din 2142 sunt citite**, restul nu.
Flagul nu ține nimic afară din joc, deci notele se joacă de azi, citite sau nu —
asta a fost decizia, luată cu riscul spus.

Dacă la citire rata de greșeli iese neplăcută, cele 2046 de note se pot scoate cu
o singură operație, fiindcă `id`-ul faptului e `id`-ul întrebării: se șterg
faptele cu prefixul `mana:` și câmpurile `fapt` care trimit la ele. Nimic din
conținutul fabricat nu e atins.

---

## AL PATRULEA TABEL (12 octombrie 2026) — compozitorii, și aritmetica lui „fiecare întrebare să aibă o notă"

Cererea a venit a doua oară în aceeași zi, după sesiunea NOTELE SE FABRICĂ: *„vreau
fiecare întrebare să aibă o notă, nu doar câteva."* Dimineața răspunsul fusese
„jumătate se poate, jumătate nu". Sesiunea asta a început prin a măsura dacă
jumătatea care nu se putea s-a mai mișcat de atunci. Nu s-a mișcat — dar acum
există cifra care spune de ce, și un tabel în plus.

### Aritmetica, scrisă o dată ca să nu se mai redeschidă din senin

| întrebări fabricate adăugate | acoperire |
|---|---|
| azi, înainte de sesiune | 646 din 2692 (24%) |
| +150 (un tabel) | ~28% |
| +400 (două-trei tabele) | ~34% |
| +1400 (5-7 tabele) | **50%** |
| pentru 90% | +17 800 — nu se întâmplă |

Socoteala e simplă și de-aia merită scrisă: fiecare tabel adaugă întrebări CU notă,
dar numitorul crește cu ele, iar cele **2046 scrise de mână fără notă rămân în
numitor pentru totdeauna.** „Fiecare întrebare" are, deci, exact două drumuri:
cele 2046 primesc note din altă parte decât un tabel (adică de la mine, ceea ce
`CLAUDE.md` interzice din motive scrise), sau ies din joc cu timpul, înlocuite de
conținut fabricat. Al doilea e un drum de luni, nu de o sesiune.

### Legarea retroactivă: ideea care părea gratuită și a căzut la măsurătoare

Dacă 449 de fapte au deja note, de ce să nu prind întrebările de mână de faptele
care există? „Cine a condus Franța ca împărat între 1804 și 1814?" ar deschide
nota Franței, cu steag și hartă, fără nicio notă nouă scrisă.

Probat pe toate 2046, cu potrivire pe cuvânt întreg și fără diacritice. **475 par
să numească o țară din tabel, și printre ele:**

```
„Cine a scris romanul «Robinson Crusoe»?"      -> România   (din „romanul")
„Ce zeu roman al războiului…"                  -> România   (din „roman")
„Care este cel mai lung fluviu din Africa?"    -> Africa de Sud
```

Iar potrivirile CORECTE nu sunt mai bune: pentru întrebarea despre Napoleon, nota
Franței spune „Capitala Franței este Paris". Adevărată, și un non-răspuns. Deci
drumul e închis, cu măsurătoarea pe masă — nu din principiu, din cifre.

Întrebările de mână nici nu se grupează pe subiecte: sunt întinse uniform pe toate
31 de rafturi, ~70 pe fiecare. Nu există cinci tabele care să le acopere.

### Tabelul: lucrare muzicală → compozitor, `P86`

Ales fiindcă are exact forma tabelului operelor (mulți-la-unu, deci aproape fără
cod nou) și fiindcă umple `cultura_clasica`, raftul care avea 75 de întrebări
scrise de mână și zero fabricate.

**147 de întrebări (109 directe, 38 inverse), 147 de fapte, TOATE cu notă.**
120 de lucrări alese din 212 propuneri cu titlu românesc, 38 de compozitori din 41.

Acoperirea notelor: **de la 646 din 2692 (24%) la 793 din 2839 (28%)**.

### Trei măsurători care au schimbat codul, nu stilul

**1. `P86` e pusă și pe FILME.** „Compozitor" la Wikidata înseamnă și „cine a scris
muzica filmului". Pe 6579 de lucrări ale celor 41 de oameni:

```
Bach      -> „Hannah și surorile ei", „Sacrificiul"
Gershwin  -> „Manhattan"
Grieg     -> „M - Un oraș își caută ucigașul"
Händel    -> „Imnul Ligii Campionilor UEFA"
```

De-aia `P31` e aici FILTRU — chiar proprietatea pe care `opere.py` a refuzat s-o
pună în TEXT. Trei liste, nu două: `TIPURI_MUZICALE` (admit), `TIPURI_RESPINSE`
(resping), `TIPURI_NEUTRE` (nu spun nimic). A treia nu e un lux: „operă creativă"
și „serie de opere" stau pe Bolero și pe L'estro Armonico ALĂTURI de tipul
muzical, deci în lista neagră ar fi aruncat lucrări bune, iar în lista albă ar fi
primit orice item „creativ". Un tip necunoscut OPREȘTE când e pe o lucrare aleasă,
și doar se raportează la `--propune`.

Lista albă a crescut o dată, și măsurat: prima rulare a lui `--propune` a scos ~60
de tipuri necunoscute, dar blocau doar **zece lucrări cu titlu românesc**, iar una
singură conta — „La traviata" (64 de ediții), ținută afară de „Italian opera".
Celelalte au confirmat că lista albă e lista bună: `P86` îl legase pe Schubert de
un scurtmetraj de animație („Flowers and Trees") și pe Grieg de o emisiune
norvegiană de televiziune.

**2. `P27` nu poate fi axa distractorilor.** La opere, axa era limba autorului. Muzica
nu are limbă, deci primul gând a fost cetățenia. Măsurată: **25 din 41 au mai
multe cetățenii**, iar numele lor sunt „Cisleithania", „Regatul Saxoniei",
„Episcopia Lübeckului", „principatul arhiepiscopal de Salzburg". O normalizare ar
fi fost 25 de rânduri de PĂREREA MEA despre ce state istorice sunt „de fapt"
aceeași țară — spre deosebire de `LIMBI_INRUDITE`, unde se contopesc variante ale
ACELEIAȘI limbi, o chestiune de fapt.

Deci distractorii se aleg pe EPOCĂ, singura axă, și e și cea adevărată la muzică:
pentru „Cine a compus «Flautul fermecat»?", Haydn și Gluck sunt distractori mai
buni decât „un alt austriac". Măsurat pe cele 147: **distanța până la cel mai
apropiat distractor e median 9 ani, cea mai mare 29.** Toți cei 41 au amândoi anii
vieții în Wikidata, deci epoca nu lipsește niciodată.

**3. Titlul poate scurge răspunsul, sau poate să nu fie un titlu.** Din 371 de
lucrări care trec filtrul de tip, rămân 264:

| refuzate | de ce |
|---|---|
| 77 | numerotate („Nocturne, Op. 32", „Simfonia nr. 1") sau cu paranteză de dezambiguizare, care uneori ȚINE răspunsul („Summertime (arie de George Gershwin)") |
| 26 | titlu purtat de mai mulți compozitori, pe 9 titluri |
| 4 | **titlul conține numele compozitorului**: „Simfonia a V-a de Beethoven", „Foc de artificii de Händel" |

### Opt opriri care au plătit în aceeași zi

1. **Franz Schubert sunt DOI.** Austriacul (Q7312) și un compozitor german din
   Dresda (Q322989), amândoi cu lucrări, amândoi cu aceeași etichetă română. Numele
   nu mai e cheie. Nu l-am scos din listă: un rând din `compozitori.json` poate fi
   acum un obiect, `{"nume": "Franz Schubert", "qid": "Q7312"}`, iar QID-ul trebuie
   să fie printre candidații GĂSIȚI, altfel oprește. Toate rândurile așa se
   tipăresc la fiecare rulare, cu ce s-a lăsat afară — aceeași regulă ca la
   `titlu_de_mana`: un câmp care ocolește o verificare trebuie să fie ZGOMOTOS.

2. **„Bolero" e și al lui Chopin.** Oprit, lucrarea scoasă. Chopin nu are nicio
   lucrare aleasă, deci n-ar fi ajuns niciodată pe un buton — dar o întrebare cu
   două răspunsuri adevărate în LUME nu intră, chiar dacă pe ecran ar fi unul.

3. **„Otello" e și al lui Rossini** — și asta a cerut o reparație, nu doar o
   ștergere. Verificarea titlurilor purtate de doi oameni se uita numai la
   etichetele ROMÂNEȘTI, iar itemul lui Rossini n-are una: ambiguitatea era în date,
   doar nu în limba în care mă uitam. Lărgită la toate trei etichetele (ro, mul,
   en), **a prins OPT din 128 de lucrări alese**, toate adevărate:

   | titlu | îl au |
   |---|---|
   | Clemența lui Titus | Mozart **și** Gluck |
   | Romeo și Julieta | Prokofiev **și** Ceaikovski |
   | Anotimpurile | Ceaikovski **și** Haydn |
   | Concertul pentru violoncel | Dvořák, Prokofiev, Schumann, Ceaikovski |
   | Otello · Rinaldo · Evgheni Oneghin · Dama de pică | +1 fiecare |

4. **11 dubluri cu fișierul scris de mână**, din ȘASE întrebări — fiecare numește
   câte două lucrări: „Ce compozitor italian a scris operele «Rigoletto» și
   «Aida»?". Aia e o întrebare mai bună decât „Cine a compus «Aida»?", deci cea de
   mână rămâne și sensul direct generat se sare.

5. **Trei dubluri PESTE LIMBI, pe care mecanismul nu le poate ține.** Ieșite din
   lista „de citit cu ochiul", care tocmai de-aia nu oprește, dar se tipărește:

   ```
   mana:0120  „Inelul Nibelungului"                eu aveam „Inelul Nibelungilor"
   mana:1641  „Rhapsody in Blue"                   eu aveam „Rapsodia albastră"
   mana:1630  „Preludiu la după-amiaza unui faun"  eu aveam titlul francez
   ```

   Nu se pot DECLARA în `DUBLURI`: `compara_dublurile` cere ca fiecare declarație
   să fie și găsită, altfel e „fantomă" și oprește. Deci leacul e în date: cele
   trei lucrări nu sunt în `lucrari.json`.

6. **Verificarea fantomelor a prins-o pe a mea.** Am declarat o dublură de sens
   invers pentru Ceaikovski (`mana:1050`, „Ce balet al lui Ceaikovski se joacă în
   preajma Crăciunului?"), pe modelul lui Jules Verne de la opere. A căzut ca
   fantomă: fișierul de mână scrie „Ceaikovski", iar numele meu e „Piotr Ilici
   Ceaikovski". Și a fost bine că a căzut, fiindcă m-a pus să mă uit mai atent —
   cele două întrebări au RĂSPUNSURI DIFERITE (cea de mână cere „Spărgătorul de
   nuci", indiciul fiind Crăciunul; cea generată cere reprezentanta, „Lacul
   lebedelor"). Nu e o repetiție, sunt două întrebări. Rămân amândouă.

7. **Anul se verifică împotriva vieții omului.** `P571` pe un item muzical e uneori
   anul unei prelucrări: „Rhapsody in Blue" iese 1973 (Gershwin a murit în 1937),
   „Lied der Deutschen" 1841 (Haydn, 1809), „Imnul Ligii Campionilor" 1992 (Händel,
   1759). Un an care nu încape nu intră în notă, lucrarea rămâne, iar cazul se
   tipărește. Niciuna din cele 120 alese nu-l declanșează azi (le-am lăsat afară pe
   toate trei din alte motive), deci garda e probată direct, nu prin date.

8. **Răspunsuri contestate, lăsate afară de mână, cu motivul:** imnul Ligii
   Campionilor (e aranjamentul lui Tony Britten pe Händel), imnul albanez atribuit
   lui Porumbescu, „Silfidele" (baletul lui Fokine pe muzica lui Chopin). Aceeași
   regulă ca la capitala Israelului din `capitale.py`.

### Refactorul: anii și apoziția au urcat în `comun.py`

`MAX_DESCRIERE`, `curata_descrierea`, `an_scris`, `anii_vietii` și nota OMULUI
(acum `comun.nota_omului`) erau în `opere.py`, scrise pentru autori. Un om e un om:
anii lui Mozart se scriu la fel ca anii lui Dostoievski, iar „-900" devine „900
î.Hr." după aceeași regulă în orice tabel. O a doua copie ar fi însemnat că lecția
cu Homer se poate pierde a doua oară.

Ce NU a urcat: nota OPEREI și nota LUCRĂRII. Alea sunt vocea tabelului
(„Autorul «…» este" / „Compozitorul «…» este") și stau lângă datele din care se
compun.

**Dovada că refactorul e neutru:** am regenerat cele 160 de întrebări de literatură
cu `opere.py --scrie`, iar `git diff data/` a ieșit **gol**.

### Șabloanele

**Lucrarea:** „Compozitorul „Flautul fermecat” este Wolfgang Amadeus Mozart
(1756–1791). Lucrarea a fost compusă în 1791." A doua propoziție o primesc 66 din
109 (atât au `P571` valid).

*Niciun pasiv cu titlul ca subiect*, din același motiv ca la opere: „«Aida» a fost
compusă de…" cere acordul cu genul gramatical al titlului. „Compozitorul «Aida»
este…" merge la orice titlu. A doua propoziție are subiectul „Lucrarea", cuvântul
MEU, mereu feminin singular — deci acolo „a fost compusă" e în siguranță.

**Compozitorul:** `comun.nota_omului`, același folosit de autori. „Piotr Ilici
Ceaikovski (1840–1893) a fost compozitor rus." Trei oameni (Purcell, Saint-Saëns,
Copland) cad pe forma de rezervă, fiindcă n-au apoziție română: „Henry Purcell s-a
născut în 1659 și a murit în 1695."

### De citit cu ochiul, rămas

- **Händel și Gluck ies „compozitor german".** E descrierea Wikidata, folosită ca
  dată (CC0), nu o clasificare de-a mea — dar Händel s-a naturalizat britanic și
  Gluck a lucrat o viață la Viena. Aceeași formă ca „stat suveran" la Danemarca:
  merită știut că e acolo.
- **„Johann Strauss II"** pe un buton românesc. Numele AFIȘAT trebuie să fie o
  etichetă Wikidata (așa se rezolvă), iar „Johann Strauss" în română îi duce și la
  tată, și la fiu. „II" e prețul; alternativa ar fi un câmp în plus care desparte
  numele căutat de numele afișat, și nu merită pentru un rând.
- **Chopin nu are nicio lucrare în tabel.** Faima lui stă în piese numerotate
  (nocturne, studii, poloneze op. …), iar regula care le refuză e corectă. Deci nu
  poate fi nici distractor. Dacă deranjează, leacul e o lucrare cu titlu
  („Marșul funebru"?), nu o slăbire a regulii.
- **Toate cele 147 de note**, la un moment dat. `verificat` rămâne `false` pe toate
  întrebările: notele sunt compuse din date verificate, dar n-a citit nimeni fiecare.

### Verificat

- `verifica_trivia`: **35/35 OK**, cod 0. Raportează acum „întrebări care ajung la o
  notă: **793 din 2839**", „note sub limită: cea mai lungă 232 din 240" și „niciun
  fapt nefolosit".
- Încărcătorul jocului: „compozitori_fapte.json — 147 fapte, **0 fara nota**".
- „Exact una din patru e corectă": verificat pe toate 147, pe mulțimea completă de
  compozitori de la Wikidata (`P86` cerut și liber în aceeași interogare).
- Id-uri și TEXTE unice peste tot conținutul (2142 + 550 + 147).
- `opere.py --scrie` regenerat după refactor: `git diff` gol.
- Garda de an, probată direct: 1797 trece pentru Haydn (1732–1809), 1841 nu, lipsa
  anilor în Wikidata nu trece.

### Fișiere

Noi: `tools/fabrica/compozitori.py`, `tools/fabrica/date/compozitori.json` (41 de
nume, unul ca obiect cu QID), `tools/fabrica/date/lucrari.json` (120 de rânduri, 5
cu `titlu_de_mana`), `tools/fabrica/cache/wikidata_compozitori.json` (3,5 MB, comis
ca celelalte), `data/trivia_gen/compozitori_intrebari.json`,
`data/trivia_gen/compozitori_fapte.json`.
Atinse: `tools/fabrica/comun.py` (cele cinci urcate), `tools/fabrica/opere.py`
(acum le cheamă).

### Rămas deschis

- **Acoperirea notelor rămâne 28%**, și n-o duce la „fiecare" niciun tabel. Decizia
  dintre cele două drumuri (note scrise de mână pentru cele 2046, sau înlocuirea
  lor treptată cu conținut fabricat) nu s-a luat azi. Aritmetica de la începutul
  sesiunii e materialul pentru ziua în care se ia.
- **Următorul tabel, dacă ținta rămâne acoperirea:** tablou → pictor (`P170`), care
  aduce și imagine (`P18`) — deci plătește și felia de IMAGINE din popup, nu doar
  nota. Sau monedă/limbă oficială (`P37`/`P38`), cel mai ieftin la volum, fiindcă
  lista de țări și cache-ul există deja; costul lui e că cere `id`-uri noi de fapt
  pentru țări (`wd:Q40` e luat de capitală) și e un fapt CARE SE SCHIMBĂ.
- **Încă ~90 de propuneri cu titlu românesc** au rămas nealese în
  `lucrari_propuse.json` (operă italiană de nivel III, mai ales). Se adaugă oricând,
  fără cod.

---

## NOTELE SE FABRICĂ (12 octombrie 2026) — de la 96 la 646, și un validator care nu mă lasă să inventez

Butonul „Află mai multe" s-a aprins dimineață și a arătat, în aceeași zi, că n-are
ce să arate: **96 de note din 2692 de întrebări, adică una din 28.** Cererea a fost
„toate întrebările să aibă note". Răspunsul cinstit a fost că jumătate din ea se
poate face corect, iar jumătate nu se poate face deloc — nu din lene, ci fiindcă ar
fi încălcat chiar regula pentru care există `CLAUDE.md`.

### Decizia, luată înainte de prima literă scrisă

Cele 2596 de întrebări fără notă se împart în două grămezi care n-au nimic în comun:

| grămadă | câte | ce are în spate |
|---|---|---|
| fabricate, cu fapt dar cu nota goală | **550** | un tabel verificat (Wikidata + coloanele mele) |
| scrise de mână, fără fapt deloc | **2046** | **nimic** |

Pentru a doua grămadă, singura sursă a faptelor aș fi fost **eu** — vreo 5000 de
afirmații scoase din memorie, toate cu `verificat: false`, toate arătate în joc de
dimineață încolo. Adică exact „modelul de limbaj formulează, nu informează", citit
invers. Întrebarea a fost pusă pe față, cu cifrele, și răspunsul a fost **„nu — doar
din surse verificabile"**. Cele 2046 rămân fără notă până au un tabel, iar drumul
spre ele e **mai multe tabele în fabrică, nu mai multă memorie de-a mea.**

### Ce s-a făcut

**Toate cele 449 de fapte fabricate au acum notă. Zero goale.**

| | înainte | acum |
|---|---|---|
| întrebări cu notă | 96 din 2692 (3,6%) | **646 din 2692 (24%)** |
| fapte cu notă | 92 din 449 | **449 din 449** |
| nota cea mai lungă | 232 | 232 (limita 240) |

În joc, măsurat pe drumul adevărat din Practice: **12 din 12** întrebări pe
„geografie → geografie politică", 9 din 12 pe „artă → literatură universală" (cele
trei rămase sunt scrise de mână). Zero dezacorduri între ce zic datele și ce arată
ecranul.

### Validatorul din ghid §4, care acum există

`comun.verifica_nota()` — scris o dată, folosit de toate trei tabelele. Cere ca
**fiecare bucată de cifre și fiecare nume propriu dintr-o notă să apară în datele
din care nota a fost compusă.** Primul cuvânt al fiecărei propoziții e scutit (are
majusculă din gramatică), iar singura excepție scrisă e `Hr`, din „î.Hr.".

La `--scrie`, o notă care nu trece **oprește scrierea întregului fișier**. Probat
rupându-l: cu un „Descoperit în 1766" strecurat în șablonul elementelor, toate cele
70 cad cu „cifra 1766 din notă nu e în datele sursă" și nu se scrie niciun octet.

**Ce prinde și ce nu, scris ca să nu mă mint:** prinde cifra inventată — greșeala
tipică a unui model de limbaj, și singura pe care o poate prinde o mașină. NU prinde
o afirmație falsă fără cifre („Parisul se află în Spania"). De-aia notele se compun
din **șabloane**, nu propoziție cu propoziție: un șablon greșit se vede la prima
rulare, în toate cele 127 de note deodată.

### Cele trei șabloane

**ELEMENTE (70).** „Simbolul chimic al sodiului este Na, iar numărul lui atomic este
11. Simbolul vine din numele latin, nu din cel românesc." Cârligul e **numărul
atomic**, singurul fapt în plus din tabel și unul pe care nu-l cere niciuna din cele
două întrebări. A doua propoziție o primesc doar cele **9 din `DIN_LATINA`** — acolo
cârligul e „confuzia frecventă" (§3), cea mai bună dintre toate, fiindcă jucătorul
care a greșit a greșit exact din motivul ăla. Afirmația nu e a mea: e înțelesul
declarat al lui `DIN_LATINA`, scris de mână și folosit deja ca regulă de nivel.

**OPERE (160), două șabloane.** Pentru operă: „Autorul „Furtuna” este William
Shakespeare (1564–1616). Opera a apărut în 1623." Pentru autor: „Gabriel García
Márquez (1927–2014) a fost scriitor, jurnalist colombian și laureat Nobel în
literatură." — apoziția e `schema:description` de la Wikidata, filtrată pe română,
deci text CC0 pe care-l pot folosi **ca dată**. E genul de cârlig pe care nu l-aș
putea scrie singur fără să devin sursa faptului.

*Niciun pasiv, și nu din stil:* „«Harap-Alb» a fost scris**ă** de…" cere acordul
participiului cu genul gramatical al titlului, care nu se poate deduce din nimic din
tabel. „Autorul „X” este…" merge la orice titlu. La fel „a apărut": cu auxiliarul
„a avea", participiul nu se schimbă.

**CAPITALE (127).** „Capitala Rusiei este Moscova. Rusia este o țară din Europa de
Est și Asia de Nord." Cârligul e tot descrierea Wikidata — **140 din 140 de țări o
au în română.**

### Două cârlige care arătau mai bune și au căzut la măsurătoare

Cache-ul capitalelor avea deja două câmpuri nefolosite, și amândouă păreau cârlige
mai interesante. Măsurate, niciunul nu ține:

- **`vecini` (P47).** „Franța are 11 state vecine." Wikidata numără și Brazilia și
  Surinamul, prin Guyana Franceză. Cifra e corectă pentru Wikidata și falsă pentru
  orice manual: Rusia iese cu 18, Indonezia cu 10, Turcia cu 10. Ar fi predat exact
  genul de lucru pentru care există regula despre modelul de limbaj — doar că
  greșeala ar fi venit din date, nu din mine.
- **`de_cand`** (calificatorul P580 de pe P36). „Parisul e capitala Franței din …" —
  **Franța întoarce ZECE ani diferiți**: 1682, 1789, 1871, 1940, 1942, 1944… Fiecare
  e o declarație adevărată despre o capitală de atunci (Versailles, Vichy), iar
  interogarea nu poate alege între ele. Un câmp cu zece valori dintre care una se ia
  la întâmplare nu e o dată, e un zar. Cele 27 de țări care-l aveau în cache îl
  aveau prin aceeași loterie.

### Decizia deschisă din sesiunea FABRICA s-a DIZOLVAT

Scria acolo, din 28 septembrie: *„`fapte_wd.json` se rescrie întreg la fiecare
rulare, deci notele pentru faptele `wd:` NU pot sta în el… decizia trebuie luată
înainte de prima notă scrisă."* Cele două variante erau „notele în fișierul de mână"
sau „scriptul păstrează notele vechi".

**Niciuna nu mai e necesară.** Grija presupunea note scrise DE MÂNĂ, care s-ar fi
pierdut la regenerare. O notă compusă de șablon **se recompune la fiecare rulare**,
din aceleași date — n-are ce să se piardă. (Varianta 1 ar fi fost și stricată:
`_incarca_fapte` refuză al doilea fapt cu același `id`, iar fișierul de mână se
citește primul, deci `imagini` ale celor 127 de capitale s-ar fi pierdut în tăcere.)

Dacă vreodată un fapt `wd:` cere o notă scrisă de mână, ziua aia readuce decizia —
dar atunci va fi despre UN fapt, nu despre toate.

### Ce a prins validatorul, și ce n-a putut prinde

**Validatorul a oprit 6 note bune**, toate din tokenizare, nu din date — și fiecare
a cerut o reparație în `_bucatile`:

| nota | de ce cădea |
|---|---|
| „Contele de Monte-Cristo” | sursa tăiată pe cratimă dă „monte" și „cristo"; în notă numele apare întreg |
| „Hobbitul”, „Stăpânul inelelor” | „J.R.R. Tolkien" tăiat pe spații dă „j.r.r."; în notă inițiala se citește „J" |
| „D-ale carnavalului” | cratima, iar |
| N'Djamena (Ciad) | apostroful, la fel |

Acum tăierea se face de două ori, cu două asprimi: o dată pe spații și paranteze, o
dată și pe cratimă, punct și apostrof. **Nu e o slăbire** — un „Madrid" pus în locul
Parisului cade în continuare, fiindcă nicio tăiere a sursei nu-l produce. (Probat.)

**Patru defecte le-a prins numai ochiul**, citind mostrele, fiindcă validatorul apără
faptele și nu gramatica:

| ce ieșea | ce e acum |
|---|---|
| `Homer (-900–-800)` | `Homer (900–800 î.Hr.)` — Wikidata dă anii dinaintea erei ca numere negative |
| `Daniel Defoe a trăit: 1660–1731.` | `…s-a născut în 1660 și a murit în 1731.` — două puncte în mijlocul unei note o fac să arate ca un câmp de bază de date |
| `…este Washington, D.C..` | un singur punct, când capitala se termină deja cu unul (1 din 127) |
| `Statele Unite ale Americii ESTE o țară…` | `…SUNT o țară…` — 3 nume de plural din 140 |

Cele trei plurale (`Emiratele Arabe Unite`, `Statele Unite ale Americii`, `Țările de
Jos`) sunt o listă scrisă, cu o plasă: un prim cuvânt terminat în „-ele" sau „-ile"
care NU e în listă oprește scriptul și cere decizia. La fel articolul („o țară", dar
„un oraș-stat"): măsurat pe toate 140, descrierea începe cu doar patru cuvinte —
`țară` (137), `stat`, `oraș-stat`, `monarhie` — deci e o listă de patru, care se
oprește la al cincilea.

**Și un bug care nu era al notelor:** cele 40 de note de autor ieșeau goale, în
tăcere. `candidati_autori` purta doar ce trebuia ca un autor să fie ALES ca
distractor — nu `nastere`, `moarte`, `descriere`. Datele existau un nivel mai sus.
Prins de raportul „148 din 188 fapte", adică de o cifră, nu de un verdict: de-aia
raportul tipărește cifra chiar și când totul e bun.

### De citit cu ochiul, rămas

- **Homer.** „Autorul „Iliada” este Homer (900–800 î.Hr.)." Atribuirea e tradițională
  și datele sunt disputate, iar `ghid-note.md` §2.6 cere „potrivit legendei" / „cel
  mai probabil" pentru ce nu e fapt sigur. Șablonul nu știe asta. E singurul autor
  antic din tabel; dacă deranjează, leacul e o excepție scrisă, nu o regulă.
- **Danemarca.** Descrierea Wikidata zice „stat suveran transcontinental și o
  monarhie constituțională". „Suveran" e cuvântul pe care tabelul l-a refuzat
  dinadins ca CRITERIU de intrare (de-aia criteriul e apartenența la ONU) — aici
  intră doar ca text descriptiv, al editorilor Wikidata, nu ca o clasificare de-a mea.
  Merită știut că e acolo.
- **Toate cele 449**, la un moment dat. `verificat` rămâne `false` pe toate
  întrebările: notele sunt compuse din date verificate, dar n-au fost citite de nimeni.

### Verificat

- `verifica_trivia`: **33/33 OK**, cod 0, iar verificarea însăși raportează acum
  „întrebări care ajung la o notă: 646 din 2692" și „note sub limită: OK — cea mai
  lungă 232 din 240".
- Încărcătorul jocului: „0 fara nota" pe toate patru fișierele de fapte (era „127
  fara nota", „70 fara nota", „160 fara nota").
- Validatorul, probat rupându-l: an inventat, nume inventat, notă prea lungă, notă
  goală — toate patru oprite.
- În joc, prin drumul adevărat din Practice: 12/12 pe geografie politică, 0
  dezacorduri între `explicatie` și date.

### Fișiere

Noi în `comun.py`: `MAX_NOTA`, `PERMISE_IN_NOTA`, `_bucatile`, `ca_text`,
`verifica_nota`, `raporteaza_notele`.
Atinse: `tools/fabrica/comun.py`, `elemente.py` (`compune_nota`), `opere.py`
(`an_scris`, `anii_vietii`, `curata_descrierea`, `nota_operei`, `nota_autorului`,
plus cele trei câmpuri în `candidati_autori`), `capitale.py` (`?descriere` în
interogare, gardă de cache, `ARTICOL`, `PLURAL`, `acordul`, `compune_nota`),
`data/trivia_gen/*_fapte.json` (rescrise), `tools/fabrica/cache/wikidata_capitale.json`
(reîncărcat, acum cu `descriere`).

**`capitale.py` cere `--reincarca` o singură dată** pentru oricine are un cache mai
vechi — garda o spune, cu motivul.

### Rămas deschis

**Cele 2046 de întrebări scrise de mână.** Drumul e tabele noi în fabrică. Cele din
`docs/plan-continut.md` care ar aduce și note aproape gratis, fiindcă Wikidata are
descrieri române pentru aproape orice entitate: filme → regizor, state → fluviu,
pictură → pictor, țară → monedă. Fiecare tabel nou aduce întrebări ȘI note în
aceeași rulare — asta e lecția zilei de azi.

**Notele sunt scurte:** mediana 69–79 de caractere, față de 120–200 cerute de §2.3.
Nu le-am umflat. Un element are atâtea de spus câte scrie în tabel, iar o propoziție
pusă ca să ajung la numărul de caractere ar fi exact felul de frază care sună bine și
nu se poate verifica. Dacă pe ecran arată prea sărace, leacul e o coloană nouă în
tabel, nu un adjectiv.

---

## AFLĂ MAI MULTE (12 octombrie 2026) — nota faptului ajunge pe ecran, după 14 zile în care s-a încărcat degeaba

Notele existau din 28 septembrie. `fapte_trivia.json` are 92, `_incarca_fapte`
le citea la fiecare pornire, `_compune_intrebare` le punea în `explicatie`, iar
`verifica_trivia` număra câte întrebări ajung la una. **Nimic nu le afișa.** Era
scris, cu drept, în comentariul din `trivia.gd`: „se umple de pe acum fiindcă e o
linie aici și un fișier de conținut în plus, iar conținutul e partea lentă".

Felia de azi e capătul celălalt al liniei ăsteia: un buton.

### Ce s-a făcut

**Un buton, un popup, și nicio linie nouă de conținut.** După fiecare răspuns în
Practice — corect SAU greșit — sub panoul întrebării apare „Afla mai multe".
Deschide un panou peste tot ecranul, cu nota faptului; se închide cu butonul
„Inchide" sau cu Escape.

| fișier | ce s-a schimbat |
|---|---|
| `scenes/practice/practice.tscn` | `ButonAfla` (plat, auriu, invizibil din start) între `ZonaPuzzle` și rândul de acțiuni; `PanouNota` — umbră + panou centrat, ultimul copil al rădăcinii |
| `scenes/practice/practice.gd` | `nota_curenta`, trei `@onready`, două linii în `_pe_raspuns`, trei în `_inchide_puzzle`, `_deschide_nota`, `_inchide_nota`, `_unhandled_input` |

### Cele patru decizii, fiecare cu prețul ei

**NOTA VINE DIN CONTRACT, NU DIN DATE.** Se citește din `puzzle.explicatie` —
câmpul pe care baza îl primește de la disciplină — nu din `TRIVIA.fapte`.
Practice nu știe nici că există fapte, nici cum se leagă o întrebare de unul. O
a doua căutare scrisă în ecran ar fi fost un al doilea drum către aceeași notă,
iar ziua în care unul se schimbă e ziua în care Practice arată altceva decât
lupta. Pe deasupra: butonul merge **din prima** și pentru Logică sau Cuvinte,
fără nicio linie în plus, fiindcă și ele pun ceva în `explicatie` (numele
regulii). N-a fost nevoie de niciun câmp nou în contract — exista deja.

**POARTA E NOTA, NU CÂMPUL `fapt`.** Cifra de azi: **646 de întrebări arată spre
un fapt, dar numai 96 ajung la o notă nevidă.** Cele 550 fabricate au fapte cu
nota goală, dinadins (există doar ca legăturile `wd:` să nu ducă nicăieri). Un
fapt fără notă e, pe ecran, exact același lucru ca o întrebare fără fapt, deci
se întreabă ce SE AFIȘEAZĂ, nu ce se speră. Consecința, spusă pe față:
**butonul apare la cam 1 întrebare din 14** (măsurat pe istorie, nivelul I:
3 din 20 de trageri). Nu e un bug, e grosimea conținutului — și e prima dată
când se vede.

**SE ARATĂ ȘI LA ÎNTREBĂRILE NEVERIFICATE.** 2664 din 2692 au
`verificat: false`. Un filtru pe flagul ăla ar fi golit ecranul aproape complet,
și pe un motiv greșit: flagul spune dacă AM CITIT nota, nu dacă nota e bună
(vezi sesiunea UN SINGUR FLAG). Nu există nicio linie în `practice.gd` care să-l
pomenească, și nu trebuie să existe.

**FĂRĂ NOTĂ, FĂRĂ URMĂ.** Butonul e `visible = false`, nu dezactivat: într-un
`VBoxContainer` un copil invizibil nu ocupă loc, deci cele 13 întrebări din 14
arată exact ca ieri. E **pe dos** față de rafturile goale din ecranul de alegere,
care apar STINSE — și dinadins: acolo un buton stins e o informație („raftul
există, dar e gol"), aici n-ar fi niciuna, doar o promisiune care nu se ține.
Prețul: când butonul apare, rândul de dedesubt coboară cu ~44 px. Ecranul face
deja asta pentru eticheta `Anunt`, deci nu e o mișcare nouă.

### Trei amănunte care păreau mărunte și nu sunt

**Nota se COPIAZĂ în clipa răspunsului, nu se recitește la apăsare.** Altfel „ce
scrie în popup" și „ce scenă stă pe ecran" ar fi fost două lucruri care se pot
contrazice. Aceeași regulă ca la `ultima_trasa` din `trivia.gd`: ce-ți trebuie
mai târziu se reține CÂND e adevărat.

**Ștergerea notei stă ÎNAINTE de `if puzzle == null` din `_inchide_puzzle`.**
Funcția se cheamă și pe un drum pe care nu există scenă de puzzle („raftul asta
nu are întrebări la nivelul X", care o cheamă și apoi se oprește). Scrisă după
ieșirea aia, nota de la întrebarea de dinainte ar fi rămas pe ecran fără nicio
întrebare deasupra ei. Întrebarea și nota ei se nasc și mor împreună, deci
locul e unul.

**Umbra popup-ului nu e decor.** `ColorRect` are `mouse_filter` pe STOP din
fabrică, deci EA e lucrul care face panoul modal. Fără ea, se putea apăsa
„Urmatoarea" prin umbră, iar întrebarea s-ar fi schimbat în spatele notei pe
care o citeai.

**Focusul rămâne pe „Urmatoarea"**, chiar dacă butonul notei tocmai a apărut
deasupra lui. Drumul obișnuit e „răspund, merg înainte", iar un Enter care
deschide brusc un popup ar fi o surpriză plătită de cel care citea repede. Nota
e o alegere, nu un pas. În popup, focusul trece pe „Inchide", deci aceeași tastă
care l-ar fi deschis îl și închide.

### Cum s-a probat

Cu o scenă de probă de unică folosință, ștearsă după (`--headless`, fără
fereastră): a intrat pe istorie, a tras 20 de întrebări, a apăsat de fiecare
dată **răspunsul GREȘIT** prin chiar butonul pe care l-ar apăsa jucătorul, și a
cerut patru lucruri:

- butonul apare la cele cu notă (3 din 20) și nu apare la celelalte (17);
- la cele fără buton, `nota_curenta` e goală — adică nu există o notă ținută
  ascunsă;
- textul din popup e **exact** `explicatie` al scenei care stă pe ecran;
- după `_inchide_puzzle`, butonul e stins și nota uitată.

Toate patru au trecut. S-a rulat și varianta cu răspunsuri CORECTE: identică,
fiindcă `_pe_raspuns` nu se uită la `succes` când pune nota — iar aia e chiar
decizia („ton sănătos": momentul în care ai cea mai mare nevoie de notă e cel în
care n-ai știut).

Suitele existente: `verifica_salvarea` 54/54, `verifica_trivia` 33/33, ambele
cod 0.

### Rămas deschis

**O verificare permanentă pentru „nota de pe ecran e a întrebării de pe ecran".**
Proba de azi a fost ștearsă, deci invariantul nu e păzit de nimic. E singurul
lucru din felia asta care se poate strica în tăcere: dacă `ultima_trasa = q` se
mută vreodată în `_compune_intrebare`, jucătorul ar citi nota unei alte
întrebări — adică un joc de învățare care predă o legătură falsă, exact clasa de
greșeli împotriva căreia există regula „modelul formulează, nu informează".
Ar fi vreo 25 de linii în `verifica_trivia`, într-o secțiune nouă care
instanțiază `trivia.tscn` și cheamă `porneste()` fără să răspundă (deci fără
pauze): se cere `explicatie == fapte[ultima_trasa.fapt]`. **Nu s-a făcut azi** —
ar fi fost al doilea obiectiv într-o sesiune cerută pentru unul.

**IMAGINEA din popup.** `imagini` e deja un câmp al faptului și e deja validat
(`CAMPURI_FAPT`), iar cele 126 de steaguri plus 127 de intrări de hartă sunt pe
disc — dar `_incarca_fapte` citește **doar nota**, deci imaginea n-are încă pe ce
drum să ajungă în `explicatie`. Asta e și prima limită a contractului: un câmp
text nu poate duce o imagine. Când se face, drumul cel mai ieftin e un al doilea
câmp opțional în dicționarul întrebării (`"imagini": [...]`), iar locul pe ecran
e în `PanouNota`, între titlu și text. Restul ecranului nu se atinge.

**Nota în LUPTĂ rămâne neafișată**, și rămâne dinadins: un popup în mijlocul unui
lanț ar rupe exact lucrul pentru care există lanțul. Dacă vreodată se vrea acolo,
locul e ecranul de verdict al luptei, nu întrebarea.

**Jucat pe mână.** Nimic din felia asta n-a fost văzut cu ochiul: panoul, umbra,
lungimea unei note de 232 de caractere în 620 px, și dacă butonul auriu plat se
citește ca un link sau se pierde. F6 pe `scenes/practice/practice.tscn`, domeniul
Istorie și societate — butonul apare la una din ~14 întrebări, deci răbdare.

---

## SAVE (12 octombrie 2026) — pasul 8: starea ajunge pe disc, și o gaură pe care doar Save-ul o putea deschide

Serializarea exista de trei luni: `Tezaur`, `Sac` și `Expeditie` știau toate să
se facă dicționar și să se citească înapoi, scrise devreme dinadins („formatul e
mai ușor de ales acum, cât e ieftin"). Ce lipsea era un fișier. Sesiunea asta
n-a reinventat formatul — l-a dus pe disc.

Și, făcând asta, a descoperit că scrierea pe disc deschide singură o gaură care
până azi nu putea exista. Secțiunea despre ea e cea mai importantă din sesiune.

### `Arhiva`: dependența merge într-un singur sens

Un autoload nou, `autoload/arhiva.gd`, înregistrat **ultimul** în
`project.godot`. Ordinea nu e cosmetică: autoload-urile intră în arbore în
ordinea din listă, deci `Tezaur._ready()` (care cheamă `goleste()`) rulează
înaintea lui `Arhiva._ready()` (care încarcă). Invers, golirea ar fi șters exact
ce se citise de pe disc.

`Arhiva` nu știe ce e un Fragment, ce e un nod de Boss sau ce înseamnă
„practice". Știe JSON, `FileAccess`, și numele celor patru dicționare pe care le
adună. Toate celelalte depind de ea; ea nu depinde de niciunul — iar asta se
vede în locul cel mai important:

**Apelurile de salvare stau în SCENE, nu în autoload-uri.** Motivul e
măsurabil, nu estetic: `verifica_drumuri.gd` joacă vreo 20.000 de expediții,
adică sute de mii de `intra_in_nod()`, iar `verifica_harta.gd` cheamă `incepe()`
pe sute de semințe. Dacă salvarea ar fi fost înăuntrul lor, fiecare verificare
ar fi bătut discul de sute de mii de ori **și** ar fi scris peste save-ul
adevărat. Așa, uneltele au rămas uscate fără să afle că există Save.

Prețul, scris: un viitor apelant al lui `intra_in_nod()` poate uita salvarea.
Azi e un singur ecran care-l cheamă.

### Două fișiere, fiindcă sunt două durate de viață

```
user://permanent.json    Tezaur · progresul din Antrenament · sacurile permanente
user://expeditie.json    expediția în curs + sacurile ei — EXISTĂ doar cât e un run viu
```

Trei motive, în ordinea importanței:

1. **Durate diferite înseamnă ȘTERGERI diferite.** Expediția se încheie →
   fișierul ei dispare. Cu un singur fișier, „șterge expediția" ar fi însemnat
   „rescrie fișierul care ține și Fragmentele" — adică singurul fișier de
   neînlocuit ar fi fost atins la fiecare final de run.
2. **Frecvențe diferite.** Expediția se scrie la fiecare nod; permanentul, rar.
   Un fișier scris des e un fișier mai des prins la mijloc.
3. **„E un run în curs?" devine `FileAccess.file_exists()`**, nu un câmp
   dinăuntru care se poate contrazice cu restul.

`user://` și nu `res://`, fiindcă într-un joc exportat `res://` e doar de citit;
pe Windows ajunge în `%APPDATA%\Godot\app_userdata\mindkeep\`. JSON cu taburi,
deci citibil cu ochiul — la un joc care e în primul rând pentru mine, un save pe
care-l poți deschide și citi e un save pe care-l poți depana.

### Scrierea nu poate lăsa un fișier tăiat

Se scrie în `expeditie.json.nou`, complet, se închide, și abia apoi se
**redenumește** peste cel adevărat. Redenumirea e un singur pas pentru sistemul
de fișiere, deci o închidere bruscă te lasă fie cu save-ul vechi întreg, fie cu
cel nou întreg — niciodată cu jumătate din fiecare.

Plasa în plus, la citire: **un `.nou` orfan se adoptă.** Pe Windows, redenumirea
peste un fișier existent îl șterge întâi, deci există o fereastră de o
microsecundă în care niciunul nu e la locul lui. Fișierul `.nou` e întreg (a fost
scris și închis înainte), deci aruncarea lui ar fi fost singura pierdere de date
pe care Save-ul ar fi putut-o face singur. Trei linii.

### Versiunea: vechi se deschide, nou nu

Fiecare fișier începe cu `"versiune": 1` și un `"scris_la"` pe care nu-l citește
nimeni din joc (e pentru ochii mei, când deschid fișierul ca să înțeleg ce s-a
întâmplat).

| ce găsește | ce face | de ce |
|---|---|---|
| mai mică (sau lipsă = 0) | se citește, prin `_migreaza()` | azi funcția nu face nimic, și exact de-aia merită să existe: prima cheie care-și va schimba înțelesul va fi un `if versiune < 2:`, nu o arheologie prin tot jocul |
| egală | se citește | — |
| mai mare | **NU se citește**, se pune deoparte ca `permanent.v99.json` | un save din viitor nu poate fi citit „strâmb": cheile pe care nu le știu pot însemna altceva decât cred |

Asimetria e tot rostul. „Se deschide chiar și strâmb" (cheie lipsă = valoarea
implicită, cheie necunoscută = ignorată, `int()` pe tot ce vine numeric) e regula
pentru save-uri VECHI. Pentru unul mai nou, singurul răspuns cinstit e să nu-l
atingi.

### Un fișier ilizibil se pune deoparte, nu se șterge

Decis în sesiunea asta, la întrebare: **se anunță.** Un progres pierdut în tăcere
arată exact ca „n-am jucat niciodată" — iar fișierul rămas pe disc e singurul loc
din care se mai poate salva ceva.

- fișierul se redenumește `permanent.stricat.json` (sau `expeditie.stricat.json`);
- dacă există deja unul pus deoparte altădată, cel nou primește **data în nume**,
  iar dacă și aia e luată (două stricări în aceeași secundă), un număr. O a doua
  stricare n-are voie s-o șteargă pe prima;
- meniul scrie un rând, cu **mesaje separate** pentru cele două fișiere:
  „Progresul salvat nu s-a putut citi" și „Expeditia salvata nu s-a putut citi".
  Pierderile sunt diferite — un run întrerupt e o seară, progresul permanent sunt
  toate serile;
- motivul tehnic („JSON invalid, linia 3") NU intră în frază: pe ecran e zgomot,
  iar în consolă `Arhiva` l-a scris deja, cu tot cu numele fișierului pus
  deoparte.

`Arhiva` ține FAPTUL (`stricate`: „ce fișier" → „de ce"); fraza o face meniul. Un
fișier care nu știe ce e un Fragment n-are de ce să știe cum se vorbește cu
jucătorul.

### GAURA: nodul e consumat la intrare, iar lupta nu se salvează

Cele două reguli erau decise de dinainte, fiecare pentru un motiv bun:

- **nodul se scrie pe disc la INTRARE** (`intra_in_nod`), înainte să se deschidă
  ce te așteaptă — altfel un lacăt ratat s-ar relua cu codul deja văzut pe roți
  (nota din sesiunea EVENIMENTUL DESCHIDE CUFĂRUL, scrisă cu două săptămâni
  înainte să existe vreun fișier);
- **lupta nu se salvează**: o expediție întreruptă în luptă se reia de la nodul
  acela.

Puse împreună, pe disc, dau altceva decât suma lor. Nodul intrat e deja în
`parcurse`, deci harta nu-l mai deschide: **lupta întreruptă era SĂRITĂ.** Iar la
Boss era mai rău decât o luptă pe gratis — `la_capat()` e adevărat în clipa în
care ești PE nodul Bossului, nu după ce l-ai bătut, deci reluarea ducea direct la
**ecranul de victorie**.

Până azi nimic din asta nu putea exista: starea trăia în memorie, deci dacă
ieșeai din joc, ieșeai din toată expediția. E o gaură pe care doar prima scriere
pe disc o putea deschide — și pe care numai o verificare a dus-întorsului o putea
găsi înainte de prima partidă.

**Leacul respectă amândouă deciziile, literă cu literă**, și costă un câmp și o
coloană:

- **`Expeditie.nod_nerezolvat`**, pus la intrare, șters de `incheie_nodul()`. Un
  int, nu un `bool in_nod`: spune CARE nod, deci se citește din save cu ochiul la
  depanare — iar dacă n-ar fi egal cu `pozitie`, asta e chiar semnul că cineva a
  uitat să-l șteargă. Un bool ar fi ascuns greșeala.
- **coloana `reluabil` în `DATE_NOD`.** Date, nu `if`-uri, ca tot tabelul:

| nod | reluabil | de ce |
|---|---|---|
| Luptă · Elită · Boss | ✅ | lupta repornește de la zero. Un adversar nu-ți spune nimic ce-ai putea folosi a doua oară |
| Odihnă · Magazin | ✅ | reluate, dau exact ce dădeau |
| **Eveniment** | ❌ | cufărul ți-a arătat codul pe roți, iar sămânța lacătului e deterministă. Nodul rămâne consumat, cufărul e pierdut |

La reluare, `harta.gd` citește fișa și face una din două. Pentru asta,
deschiderea nodului s-a despărțit de clic: `_deschide_nodul()` are acum doi
apelanți (clicul, după salt, și reluarea), fiindcă două locuri care știu ce face
un nod ajung într-o zi să știe altceva.

### Și o a doua fereastră, în luptă

PV-ul se predă expediției în `_inapoi_la_harta()`, adică la **apăsarea**
butonului de verdict. Mergea perfect cât nimic nu se scria pe disc: între verdict
și buton nu exista nicio cale de ieșire din joc.

Cu un save pe disc, fereastra aia devine o gaură cu capăt dublu. Fragmentele sunt
deja plătite în Tezaur (`acorda_recompensa()` se cheamă la verdict), dar nodul ar
fi rămas nerezolvat — deci o ieșire din joc pe ecranul de verdict ar fi **reluat
lupta și plătit răsplata a doua oară**, iar PV-ul scris pe disc ar fi fost cel de
DINAINTEA luptei.

Regula Arhivei spune exact unde e locul: **lupta se termină când cade cineva, nu
când apeși un buton.** Predarea PV-ului, `incheie_nodul()` și salvarea s-au mutat
în `termina_lupta()`; `_inapoi_la_harta()` schimbă acum doar scena.

### Unde se scrie, exact

Regula scurtă: **se scrie după fiecare lucru TERMINAT**, deci cel mai rău caz e
mereu „pierzi ce n-ai dus la capăt", niciodată „pierzi ce ai dus".

| unde | ce se scrie | de ce acolo |
|---|---|---|
| `harta.gd`, după `Expeditie.incepe()` | ambele | expediția se naște, iar `incepe()` a chemat `Sac.expeditie_noua()` |
| `harta.gd`, după `intra_in_nod()`, **înainte de `match`** | expediția | regula de care atârnă Lacătul |
| `harta.gd`, după `odihneste()` | expediția, **plus `incheie_nodul()`** | salvarea de la intrare e de DINAINTEA vindecării. Vezi regula nodurilor cu efect instantaneu, mai jos |
| `harta.gd`, după `cumpara()` | expediția | ce-ai cumpărat e câștigat |
| `harta.gd`, după plata cufărului | expediția, **plus `incheie_nodul()`** | la fel: verdictul a căzut, Monedele s-au plătit, mesajul de după e doar informație |
| `lupta.gd`, în `termina_lupta()` | ambele | vezi mai sus |
| `harta.gd::_dupa_un_nod()` | ambele | singurul loc în care se adună cele trei drumuri |
| `_dupa_un_nod()`, pe ramura `incheie()` | permanent, apoi **șterge** expediția | în ordinea asta: invers, o închidere între cele două ar fi lăsat un run fără fișier și fără Fragmentele lui scrise |
| `practice.gd`, după `_inregistreaza()` | permanent | o întrebare știută nu are voie să moară cu procesul |

Nimic nu se scrie la închiderea ferestrei. Cu punctele de mai sus, un
`NOTIFICATION_WM_CLOSE_REQUEST` ar fi salvat doar o luptă în curs — adică exact
ce decizia „lupta nu se salvează" spune să nu salvăm.

**Un nod cu efect INSTANTANEU se încheie când efectul s-a întâmplat**, nu când
apeși pe mesajul de după. Regula a ieșit la iveală pe Odihnă, și era o scurgere
în direcția proastă: salvarea de după `odihneste()` repara pierderea PV-ului, dar
lăsa nodul NEREZOLVAT pe disc — iar Odihna e `reluabil`, deci reluarea l-ar fi
deschis din nou și te-ar fi vindecat **a doua oară**. Ieși din joc pe mesaj și te
întorci cu 70% din PV în loc de 35%.

`incheie_nodul()` se cheamă deci în patru locuri, nu în unul: la Odihnă (după
vindecare), la cufăr (după plată), în `termina_lupta()`, și ca plasă pe prima
linie din `_dupa_un_nod()`. Ce rămâne pentru `reluabil` sunt exact nodurile
întrerupte ÎNAINTE de efectul lor — la Odihnă fereastra aia e același cadru, deci
practic nu există; la lacăt e tot timpul cât te uiți la roți, și aia e chiar
fereastra care trebuia închisă.

### Sacul are acum DURATĂ pe cheie

Întrebarea pusă la începutul sesiunii: sacul Culturii generale devine permanent,
iar `Expeditie.incepe()` → `Sac.expeditie_noua()` golea tot, inclusiv cheile
`practice:`. **Răspunsul: numai rafturile din Practice trec în permanent.**

`Sac` a învățat o `Durata`, declarată de APELANT la folosire:

```gdscript
Sac.extrage(cheie, pool, "id")                        # pe expediție
Sac.extrage(cheie, pool, "id", Sac.Durata.PERMANENT)  # rămâne
```

`sac.gd` nu știe ce e „practice" și n-are voie să afle — toată valoarea lui vine
din faptul că nu știe ce e un bilet. Singura linie din tot jocul care declară
permanența e în `trivia.gd::trage_din_raft()`, adică exact în fișierul care știe
că un raft de antrenament nu e o luptă. `expeditie_noua()` golește de acum numai
sacurile de expediție; pentru „șterge tot" (joc nou, unelte de verificare) există
`goleste_tot()` — care e chiar vechiul `expeditie_noua()`, deci cele 10 apeluri
din `verifica_trivia.gd` s-au mutat pe el fără să schimbe nimic.

Durata **nu se scrie în fișier**: FIȘIERUL o spune. Tot ce stă în save-ul
permanent e permanent, prin definiție, iar un câmp în plus ar fi fost un al
doilea loc care susține același lucru — adică un loc care se poate contrazice cu
primul.

**Ce s-a schimbat față de ce scria în CONȚINUTUL.** Acolo scrisesem că sacul de
LUPTĂ al Culturii generale devine permanent. Am ales altfel, deocamdată, ca să
văd cum se simt repetările între expediții — la un joc de învățare, repetarea la
DISTANȚĂ e ce vrei, nu ce eviți. Dacă se dovedesc deranjante, schimbarea e o
constantă și o structură de date: cheile de luptă trec pe `Durata.PERMANENT`, și
atunci `vazute` din `sac.gd` trebuie să devină un `Dictionary` folosit ca mulțime
— comentariul de acolo spune deja că `Array.has` e ieftin la 45 de bilete, nu la
2692.

### Progresul din Antrenament, și o datorie pe care o numesc

Nivelurile și întrebările știute din Practice trăiau în două `static var` și
mureau cu procesul. Acum `Arhiva` le duce în `permanent.json` prin două funcții
statice noi, și le aduce înapoi la pornire.

**A rămas strâmb, și merită spus:** starea care supraviețuiește unei scene
aparține unui AUTOLOAD — regula scrisă în antetul lui `tezaur.gd`, `sac.gd` și
`expeditie.gd`. Progresul ăsta o încalcă: stă într-un script de scenă, iar
`Arhiva` ajunge la el cu un `preload`. Ziua în care se mută e felia următoare din
Practice, cea cu greșitele care revin și cu Jurnalul, când apar oricum alte
două-trei dicționare care n-au ce căuta într-un ecran. Azi ar fi fost un refactor
într-o sesiune despre disc.

### Ce vede jucătorul

Două rânduri în meniu, și nimic altceva:

- butonul scrie **„Continua expeditia"**, cu `N noduri in urma, X / Y PV. Pornita
  cu samanta Z.` dedesubt. E o CITIRE a stării, nu o decizie despre ecranul de
  după: harta își alege singură ecranul, exact ca până acum, și ar fi arătat harta
  oricum. Fără rândul ăsta, apeși „Expeditie" așteptând un loadout și aterizezi în
  mijlocul unui run — iar primul lucru pe care l-ai crede e că jocul a uitat să-ți
  dea alegerea;
- rândul portocaliu de la fișierele puse deoparte, când e cazul.

### Verificarea: `tools/verificari/verifica_salvarea.gd`

`godot --headless --path . res://tools/verificari/verifica_salvarea.tscn` —
**54 de verdicte în ~1 secundă.** Scrie DOAR în `user://verificare_salvare/`
(`Arhiva.dosar` se mută pe prima linie, dosarul se golește la început și la
final): o verificare care poate suprascrie save-ul adevărat e o verificare pe
care n-o rulezi niciodată.

| secțiune | ce bate |
|---|---|
| 1. dus-întors | stare BOGATĂ (run pornit, 4 noduri parcurse, PV schimbat, Monede, o putere cumpărată, recorduri, Fragmente, bilete în amândouă felurile de sac, progres în Antrenament) → disc → **tot golit** → citit → comparat câmp cu câmp, cu calea primei diferențe tipărită. Plus o probă că golirea chiar golește: fără ea, comparația ar trece chiar dacă încărcarea n-ar face nimic |
| 2. tipurile | `typeof()` pe fiecare număr care a trecut prin JSON. **Verificarea pe care dus-întorsul n-o poate face:** în GDScript `3 == 3.0` e `true`, deci un `int()` uitat ar trece comparația fără o pată și ar crăpa abia când numărul ajunge să indexeze un Array |
| 3. chei lipsă | fișiere goale și un save pe jumătate scris → valorile implicite, zero crăpături |
| 4. chei în plus | o resursă ștearsă, un tip de nod inventat (→ Luptă), chei de nivel înalt necunoscute |
| 5. fișiere stricate | patru feluri de ilizibil (tăiat la mijloc, gunoi binar, gol, un Array în loc de obiect) × **ambele fișiere** |
| 6. două stricări la rând | trei la rând, în aceeași secundă → trei fișiere, cu trei conținuturi distincte |
| 7. versiunea | fără versiune se citește; una din viitor nu, și e pusă deoparte cu versiunea în nume |
| 8. atomicitatea | niciun `.nou` rămas după o scriere; un `.nou` orfan se adoptă ȘI se pune la locul lui |
| 9. nodul nerezolvat | ajunge pe disc, se șterge la încheiere, tabelul `reluabil` e cel așteptat, iar la Boss `la_capat()` e deja adevărat — deci nodul e singurul care decide |
| 10. duratele sacului | fiecare sac într-un singur fișier · `expeditie_noua()` golește doar ce trebuie · rămâne permanent și după disc · declarația din `trivia.gd`, probată prin chiar funcția ecranului |
| 11. expediția încheiată | fișierul dispare, Fragmentele rămân scrise, iar un fișier de expediție încheiată nu se reia |

**Ruptă de două ori, ca să știm că poate pica:**

| ce am rupt | ce a prins |
|---|---|
| scos `"id"` din bucla de `int()` din `din_dictionar` | `starea se întoarce întreagă PICAT /expeditie/harta/0/id: int față de float`, plus secțiunea 2 pe toate cele 14 noduri. Ieșire 1 |
| scos `nod_nerezolvat = id` din `intra_in_nod` | `nodul nerezolvat ajunge pe disc PICAT nod_nerezolvat=-1, pozitie=0`. Ieșire 1 |

Prima rupere spune și de ce comparația de la secțiunea 1 întreabă `typeof`
înaintea valorii: altfel un float strecurat ar fi trecut neatins.

### O capcană de unealtă, de ținut minte

**O eroare de PARSARE într-un script de verificare nu oprește Godot — îl lasă să
ruleze la infinit.** Scena se încarcă fără script, `_ready()` nu rulează
niciodată, deci `get_tree().quit()` nu se cheamă, iar procesul headless rămâne
agățat până îl omori. Prima rulare a arătat exact așa, și „se blochează" însemna
de fapt „nu compilează". Dacă vreodată o verificare pare să nu se mai termine,
prima întrebare e dacă s-a încărcat scriptul, nu ce buclă s-a învârtit.

Cauza, de reținut pentru GDScript: `var x := ceva_fără_tip.get_basename()` nu
compilează („cannot infer the type"), iar `DirAccess.get_files_at()` întoarce un
`PackedStringArray`, nu un `Array` — conversia la `return` nu se face singură.

### Verificat

| unealtă | rezultat |
|---|---|
| `verifica_salvarea` | **54/54 OK**, ~1 s, cod 0 (și cod 1 pe amândouă ruperile) |
| `verifica_trivia` | 0 picate, 15 s — sacul a trecut prin `Durata` și prin `goleste_tot` |
| `verifica_drumuri` | 0 picate, 19 s |
| `verifica_eveniment` | 0 picate, 9 s (de două ori: și după salvarea adăugată la plata cufărului) |
| `verifica_harta` | 0 picate, 16 s |
| `verifica_plansa` | 0 picate, 4 s |
| `verifica_tipuri` | 0 picate, 36 s |
| `--headless --quit` pe meniu | fără erori noi |

`verifica_cifru` NU s-a rulat: generatorul de lacăte n-a fost atins, iar costul e
10 minute.

### Ce NU s-a făcut

- **Nicio partidă jucată pe mână.** Tot ce scrie mai sus e verificat în date, nu
  pe ecran. Lista de probat cu mâna e la „Imediat".
- **Niciun buton de abandonare a unui run.** Cât timp un save de expediție
  există, nu poți porni alta: loadout-ul se vede doar când `Expeditie.activa` e
  fals. Așa face și Slay the Spire, deci nu e un bug — dar e o ușă care lipsește.
- **Nicio ieșire spre meniu din mijlocul expediției.** Decizia din CLAUDE.md
  spune că fără Save ar fi fost „o abandonare deghizată în pauză". Save-ul există
  de azi, deci butonul a devenit ieftin și cinstit — dar nu s-a adăugat.
- **Save-ul nu se vede nicăieri în joc** în afara meniului: nicio confirmare,
  niciun „s-a salvat". Pentru un joc care salvează singur la fiecare nod, e
  probabil bine așa.
- **Fără copie de rezervă rotativă.** Un save stricat se pune deoparte, dar nu
  există un „penultimul save" la care să cazi.

### Rămas deschis

- **Progresul din Antrenament stă încă într-un script de scenă.** Vezi secțiunea
  de mai sus; ziua mutării e felia următoare din Practice.
- **Sacul de luptă al Culturii generale a rămas pe expediție**, deși CONȚINUTUL
  spunea altceva. Dacă repetările între expediții deranjează:
  `Durata.PERMANENT` pe cheile de luptă, plus `Dictionary` ca mulțime în
  `sac.gd`.
- **F6 pe `lupta.tscn` scrie `permanent.json`.** O probă dată cu F6 câștigă
  Fragmente adevărate, care ajung pe disc. Expediția e apărată
  (`salveaza_expeditia` se dă la o parte când `Expeditie.activa` e fals, altfel
  meniul ar oferi un run fantomă), dar tezaurul nu. Se repară cu un comutator de
  „mod de probă" în `Arhiva`, dacă ajunge să deranjeze.
- **Ieși din joc cu sumarul pe ecran și nu-l mai vezi niciodată.** Cifrele sunt
  deja plătite în Tezaur, deci se pierde priveliștea, nu răsplata. Un „ultimul
  run" în meniu l-ar readuce.
- **`scris_la` nu se vede nicăieri.** E în fișier pentru depanare; meniul ar
  putea scrie „jucat ultima dată acum trei zile" fără nicio muncă.
- **Build-ul web.** `user://` merge și acolo (IndexedDB), dar save-urile nu se
  sincronizează cu desktopul — decizia din CLAUDE.md rămâne: desktopul e „casa"
  progresului.

### Fișiere

| fișier | ce |
|---|---|
| `autoload/arhiva.gd` | **nou** — singurul fișier din joc care atinge discul |
| `project.godot` | `Arhiva` înregistrată ULTIMA în `[autoload]` |
| `autoload/sac.gd` | `enum Durata`, `_durata` pe cheie, `expeditie_noua()` selectiv, `goleste_tot()` nou, serializare pe durată |
| `autoload/expeditie.gd` | `nod_nerezolvat`, `incheie_nodul()`, coloana `reluabil` în `DATE_NOD`, cele două capete de serializare |
| `scenes/trivia/trivia.gd` | o singură linie reală: `Durata.PERMANENT` la `trage_din_raft` |
| `scenes/harta/harta.gd` | `_deschide_nodul()` desprins din `_pe_nod_apasat`, `_reia_nodul()` nou, `_incheie_pe_disc()`, șase apeluri de salvare |
| `scenes/lupta/lupta.gd` | predarea PV-ului, `incheie_nodul()` și salvarea mutate în `termina_lupta()` |
| `scenes/practice/practice.gd` | `spre_dictionar()` / `din_dictionar()` statice, salvare după `_inregistreaza()` |
| `scenes/meniu/meniu.gd`, `.tscn` | butonul care spune adevărul, rândul de avertisment (`Avertisment`, ascuns) |
| `tools/verificari/verifica_salvarea.gd`, `.tscn` | **nouă** — 54 de verdicte, ~1 s |
| `tools/verificari/verifica_trivia.gd` | 10 × `expeditie_noua()` → `goleste_tot()` |
| `CLAUDE.md` | patru decizii noi, rândul din tabelul verificărilor, pasul 8 bifat |
| `docs/progres.md` | antetul, rândurile 8 și 13, sesiunea asta, lista „Imediat" |

---

## MENIUL ȘI PRACTICE (8 octombrie 2026) — a doua ușă a jocului, și prima felie din pasul 13

Până azi, jocul avea un singur drum: F5 deschidea harta, iar al doilea mod de
joc exista doar în pitch. Acum există o **răscruce** — un meniu de start cu două
butoane — și, în spatele celui de-al doilea, **Antrenament liber (Practice)**:
Cultura generală, pe domeniul și pe raftul ales de tine, fără cronometru.

Fișiere noi: `scenes/meniu/` și `scenes/practice/`. `run/main_scene` din
`project.godot` arată de azi spre meniu.

### Meniul nu știe nimic despre ce deschide

Regula pe care o apără fișierul de 59 de linii: meniul **încarcă** o scenă și
nimic mai mult. Harta își alege singură ecranul (loadout / hartă / sumar) în
`_ready`-ul ei, din starea lui `Expeditie`, exact ca până acum. Singurul lucru
pe care harta a aflat despre meniu e o **cale**, într-o constantă.

De-aia `harta.tscn` și `lupta.tscn` pornesc în continuare singure cu F6 — probat
headless pe amândouă, fără nicio eroare.

Un meniu de start e locul în care se adună, pe nesimțite, logica tuturor
celorlalte ecrane: „dacă ai un save, scrie Continuă”, „dacă n-ai deblocat
Turnul, ascunde butonul”, „dacă expediția e în curs, du-l direct acolo”. Fiecare
din astea aparține ecranului de DUPĂ, iar un meniu care le adună devine singurul
fișier pe care trebuie să-l deschizi ca să înțelegi orice.

### Ieșirea spre meniu: două butoane, nu trei

„Meniu” apare pe **ecranul de loadout** și pe **sumarul de final**, adică pe
singurele două ecrane unde nu e nimic de pierdut: pe primul expediția n-a
început, pe al doilea s-a terminat deja. Din **mijlocul** unei expediții nu
există ieșire, și nu din uitare: fără Save (pasul 8), tot ce ține expediția
trăiește în autoload, deci un buton de acolo n-ar fi o pauză, ar fi o abandonare
deghizată în pauză. Când apare Save-ul, butonul devine ieftin și cinstit.

**Capcana găsită la sumar.** `Expeditie.final` rămâne setat după un run încheiat,
iar `_ready` îl citește ca pe „arată sumarul”. Fără golire, ieși în meniu de pe
sumar, apeși din nou „Expediție” — și primești sumarul aceleiași expediții
moarte, fără nicio cale de a porni una nouă. Deci `_pe_meniu()` cheamă
`Expeditie.goleste()`, aceeași golire pe care o face deja butonul „Expediție
nouă”. Pe loadout nu face nimic, și e bine că nu face nimic **într-un singur
loc**, în loc să întrebe „de pe care ecran am fost chemat?”.

### Muzica meniului, și o cale moartă descoperită de ea

Meniul și Practice cântă `Piesa.CETATE` — piesa liniștită, cea care e deja „casa”
jocului. `HARTA` ar fi promis o expediție din meniu, `LUPTA` ar fi fost o
minciună.

Cerând-o, s-a văzut că **nu există**: tabelul din `muzica.gd` arăta spre
`muzica_cetate.ogg`, iar pe disc fișierul se numește de la început
`sound_castle.ogg`. Nu s-a observat până azi fiindcă nimeni nu cerea piesa
asta — Cetatea e pasul 7 și n-are încă scenă, iar un fișier lipsă nu e o eroare
fatală, doar liniște. Primul care a cerut-o a fost meniul, și atunci s-a auzit:
adică nu s-a auzit. Reparația e **un rând în tabel**, exact ce promite
comentariul de acolo.

### Practice refolosește scena de întrebare a luptei

Întrebarea de pe ecran e **chiar** `trivia.tscn`, instanțiată ca în `lupta.gd`:
aceleași patru butoane, același antet, aceiași trei timpi ai verdictului. Un al
doilea UI de întrebare ar fi însemnat ca fiecare lustruire viitoare (un sunet, o
animație, „Află mai multe”) să se facă de două ori, cu două șanse să se despartă
pe furiș.

Tot ce-i spune Practice scenei de trivia sunt **trei valori**, puse înainte de
`porneste()`: `cu_cronometru`, `filtru_domeniu`, `filtru_subcategorie`.

### Cronometrul: un comutator, nu o scenă a doua

`puzzle.gd` a primit `var cu_cronometru := true`. Lupta n-o atinge; Practice o
stinge. Au ajuns **două linii** în `porneste()`, fiindcă tot cronometrul atârnă
de `_process`, iar `_process` se pornește într-un singur loc:

```gdscript
bara_timp.visible = cu_cronometru
set_process(cu_cronometru)
```

Fără `_process` nu curge timpul, nu expiră nimic și nu pornește ticăitul —
`actualizeaza_cronometru()` e chemată o dată, cu timpul plin, deci trece pe
ramura care **stinge** ceasul. Nicio ramură nouă pe drumul răspunsului. Bara se
ascunde fiindcă o bară plină care nu se mișcă e o promisiune mincinoasă: ori
măsoară ceva, ori nu există.

### Tragerea pe raft: trei funcții, și nicio atingere la alegerea din luptă

`trage_intrebarea` (echilibrul pe domenii + `PRAG_DOMENIU`) a rămas neatinsă.
`_compune_intrebare` a primit **un ternar**, nu o ramură: filtru gol = lupta,
filtru pus = Practice. În `trivia.gd` sunt acum, `static`:

| funcție | ce face |
|---|---|
| `raftul(nivel, domeniu, subcategorie)` | lista raftului. Aceeași funcție dă și **lista din care se trage**, și **cifra scrisă pe buton** |
| `cheia_raftului(domeniu, subcategorie, nivel)` | `practice:<domeniu>:<raft sau „tot">:<nivel>` |
| `trage_din_raft(nivel, domeniu, subcategorie)` | `raftul()` + `Sac.extrage(..., "id")` |

**O singură funcție pentru numărat și pentru tras** nu e economie de linii: e
felul în care nu poți avea un buton pe care scrie 136 și un sac cu 140.

**Ce NU e acolo, dinadins:**

- **niciun prag.** `PRAG_DOMENIU` apără echilibrul LUPTEI, unde domeniul îl
  alege jocul. În Practice alegi tu, deci n-are ce echilibra nimeni — iar un
  prag ar fi însemnat „nu ai voie să exersezi raftul care tocmai a apărut”.
- **nicio plasă pe nivel.** `trage_intrebarea` cade pe alt nivel dacă cel cerut
  e gol, fiindcă în luptă alternativa ar fi ecranul de eroare în mijlocul unui
  lanț. Aici alternativa e mai bună: ecranul **dezactivează** rafturile goale.
  Un fallback ar fi amestecat nivelurile pe furiș (amestecul e o felie separată)
  și ar fi făcut invizibil un bug.

**De ce în cheie intră și raftul.** Aceeași regulă ca la cheia luptei, cu un
nivel mai jos: `Sac.extrage` golește registrul unei chei când lista primită se
epuizează. Fără raft în cheie, terminarea capitalelor ar șterge memoria întregii
geografii. Iar dacă Practice ar folosi **cheia luptei**, exersarea unui raft
dimineața ar face lupta de seara să repete întrebări — nu ar crăpa nimic, s-ar
vedea doar ca „parcă se repetă ceva, uneori”.

### Ecranele, și ce scrie pe butoane

Trei ecrane într-o scenă: domeniile, rafturile domeniului, întrebările.
**Nicio listă scrisă în scenă**: butoanele se generează din `DOMENII` și
`SUBCATEGORII[domeniu]`, ca rândurile din loadout. Al nouălea domeniu e un rând
în `trivia.gd` și nimic altceva.

Primul buton de pe ecranul rafturilor e **„Tot domeniul”**, și nu e o
comoditate: e singurul care cuprinde ȘI întrebările fără subcategorie. Câmpul e
opțional, deci fără butonul ăsta ar putea exista întrebări pe care niciun raft nu
le arată — exact ce nu vrei de la un meniu care pretinde că împarte tot
conținutul.

**Cifra de pe buton e câte întrebări are raftul LA NIVELUL TĂU**, nu totalul pe
trei niveluri: aia e cifra care se și joacă, și aceeași cifră decide dacă butonul
e activ. Prețul, spus pe față: când deblochezi nivelul II la un domeniu, un raft
care are conținut doar la nivelul I se stinge.

**Rafturile goale apar, dezactivate, nu ascunse.** Un raft ascuns e un raft
despre care nu afli niciodată nimic: nu știi dacă nu există, dacă l-ai pierdut
sau dacă n-am scris încă nimic în el. Aceeași decizie ca la `PRAG_DOMENIU`, unde
domeniile subțiri sunt SĂRITE, nu scoase din date. (Azi niciun raft nu e gol:
toate cele 93 de celule au cel puțin 25 de întrebări, de la CONFORT 25.)

### Nivelul, pragul și progresul

Nivelul **nu se alege**. Pornești de la I și urcă singur, pe **domeniu** — nu pe
raft: numărat pe raft, ar fi fost 31 de progrese de ținut minte și un nivel care
sare în sus și-n jos după ce raft ai deschis. Alegerea raftului e o lupă, nu un
alt joc.

`PRAG_PRACTICE = 60` răspunsuri corecte la **întrebări distincte** (pe `id`,
singurul câmp care nu se schimbă niciodată). Fără „distincte”, 60 s-ar fi putut
face din 3 întrebări repetate de 20 de ori.

Contorul **repornește pe fiecare nivel**: cheia e `domeniu:nivel`, deci cele 60
de la nivelul I nu deschid instantaneu și nivelul III. La nivelul III scrie
„nivelul maxim”. Pe ecran: `Nivel I · 12 / 60 pana la nivelul II`.

**Progresul se pierde la închiderea jocului.** Trăiește în două `static var`
(nivelul pe domeniu, mulțimea de `id`-uri știute pe celulă): aparțin
SCRIPTULUI, deci rezistă la plimbarea prin meniu și înapoi — probat: după o scenă
nouă, cele 3 știute erau încă acolo — dar mor cu procesul. Forma lor (chei text,
valori simple) e deja cea pe care `JSON.stringify` o înghite fără conversii, deci
la Save se scriu ca sunt.

### Două lucruri decise de fapte, nu de plan

**„Schimbă domeniul” stă vizibil tot timpul**, nu doar după răspuns. Planul era
să apară amândouă butoanele după răspuns — dar fără cronometru o întrebare **nu
se termină singură**, deci un ecran din care nu poți ieși decât răspunzând ar fi
fost un zid. „Următoarea” e cea care apare: stă dezactivată până răspunzi.
Bonus: layout-ul nu mai sare, fiindcă rândul de butoane are mereu aceeași formă.

**Raft gol la nivelul următor** — se poate întâmpla fără niciun bug: exersezi un
raft, treci pragul la jumătate, iar nivelul lui următor n-are încă conținut.
Atunci ecranul o **spune** („Raftul asta nu are intrebari la nivelul III. Alege
altul.”), în loc să ceară o întrebare care nu există și să primească ecranul de
EROARE din `puzzle.gd` — care aici ar fi fost o minciună: nu e nimic stricat,
doar n-am scris încă întrebările.

### Verificarea

`verifica_trivia` a primit secțiunea **9. RAFTURILE DIN PRACTICE**, cu patru
verdicte noi (29 → **33**). Toate verzi, cod de ieșire 0, **16,9 secunde** în
total:

```
  RAFTURILE DIN PRACTICE (tragerea filtrată, pe fiecare raft cu conținut)
    filtrul e respectat                 OK   2692 trageri, pe 93 rafturi
    rafturile împart tot domeniul       OK   24 celule
    un ciclu întreg, pe fiecare raft    OK   93 rafturi fără nicio repetiție
    cheile sunt separate pe filtru      OK   geografie:1 — geografie_politica a
                                             ținut minte după ce geografie_fizica
                                             s-a golit
```

- **filtrul**, probat prin **chiar** `trage_din_raft`, nu printr-o copie a
  filtrului scrisă în verificare: o verificare care-și rescrie obiectul probează
  copia, nu codul.
- **împărțirea**: „Tot domeniul” = suma rafturilor + cele fără raft, pe toate
  cele 24 de celule. Ăsta e chiar motivul pentru care `subcategorie` e un CÂMP și
  nu o etichetă: o împărțire, nu etichete care se suprapun. Dacă s-ar suprapune,
  cifrele de pe butoane ar fi false și n-ar avertiza nimic.
- **ciclul**: garanția sacului, pe toate cele 93 de rafturi cu conținut.
- **cheile pe filtru**: se golește un raft, apoi se întreabă **alt raft al
  aceluiași domeniu** ȘI **sacul de luptă al aceleiași celule** dacă își mai țin
  minte biletele. Dacă nu există nicio celulă cu două rafturi pline, verificarea
  **PICĂ** în loc să treacă în tăcere: „n-am avut ce proba” nu e același lucru cu
  „e bine”.

Pe lângă asta, scena întreagă a fost probată cap-coadă într-o scenă temporară,
ștearsă după: 8 butoane de domeniu cu cifrele lor, 5 rafturi la istorie,
cronometru stins și bară ascunsă, filtrul ajuns la scena de trivia
(`istorie / modern_contemporan`), trei răspunsuri corecte care urcă amândoi
contorii, un răspuns greșit care urcă doar sesiunea, pragul la 60 (nivelul se
deschide și anunțul apare), capul la nivelul III și textul de raft gol.

### Rămas deschis

- **`Expeditie.incepe()` cheamă `Sac.expeditie_noua()`, care golește TOT sacul**
  — inclusiv cheile `practice:`. Deci o expediție pornită între două sesiuni de
  Practice resetează garanția „fără repetiții” de acolo. Lăsat așa dinadins:
  leacul curat ar fi o golire selectivă, dar `sac.gd` e generic și nu are voie să
  știe ce e „practice”. Se decide la Save, unde sacul devine oricum permanent.
- **Lista de alegere nu are `ScrollContainer`.** Opt butoane de domeniu încap
  (~480 px din 648). Al doisprezecelea nu va încăpea, și atunci ăsta e locul.
- **Pragul de 60 e în continuare nejucat.** Prima cifră care se va simți greșită.
- **Istoricul nu e comun cu expedițiile** (recomandat în sesiunea CONȚINUTUL,
  încă neimplementat): exersez o întrebare dimineața și o pot primi gratis în
  luptă seara. Cere Save.
- **Nota faptului tot nu se vede nicăieri.** Se încarcă în `explicatie` de la
  sesiunea ID ȘI FAPT; „Află mai multe” e felia următoare din pasul 13, și ea e
  cea care-i dă primul ecran.
- **Ce face Practice cu `verificat: false`** — tot nedecis, și acum e locul unde
  se va decide: 2664 din 2692 de întrebări sunt neverificate, deci un filtru ar
  goli ecranul.

### Documentele vecine, aduse la zi pe 9 octombrie 2026

Trei locuri rămăseseră în urmă — nu din sesiunea asta, ci de dinainte, și s-au văzut
abia când codul a ajuns la ele:

- **`plan-continut.md`, cheia sacului.** Scria `practice:geografie:capitale`, cu
  trei bucăți. Cheia adevărată, de când există cod, are patru:
  `practice:<domeniu>:<raft sau „tot”>:<nivel>`. Nivelul TREBUIE să fie în ea —
  lista unui raft e alta pe fiecare nivel.
- **`plan-continut.md`, grila.** „6 × 3”, rămasă de dinaintea celor opt domenii.
  Acum 8 × 3. Plus un rând nou la „ce se măsoară singur”: împărțirea pe rafturi se
  probează de azi, iar ea e chiar ce deosebește o ÎMPĂRȚIRE de niște etichete.
- **`ghid-note.md`.** Spunea că `explicatie` e gol și că „Practice e primul loc care
  o va afișa”. Trivia îl umple de la sesiunea ID ȘI FAPT, iar Practice există de
  ieri și tot nu afișează nota: aia e felia următoare. Și întrebarea despre
  `verificat: false` are acum o cifră lângă ea — 2664 din 2692 — care spune de ce un
  filtru ar goli ecranul.

---

## DOUĂ CUFERE LA RÂND (8 octombrie 2026) — Evenimentul intră sub regula gemenilor, și rețeta începe să se probeze

Pe `harta_01`, sămânța 1, două Evenimente cădeau lipite. Nu era o scăpare: era
o **excepție scrisă** — `_se_cearta()` îi dădea Evenimentului un prag mai blând
decât celorlalte trei tipuri speciale.

| tip | se ceartă la | adică |
|---|---|---|
| Elită, Odihnă, Magazin | 1 sau 2 pași | nici vecini, nici frați printr-o răscruce |
| **Eveniment, până azi** | **exact 2 pași** | frați, nu. **Vecini, da** |

Motivul excepției era adevărat când s-a scris: Evenimentul era un placeholder,
marcat pe hartă și fără conținut. De când nodul deschide **Lacătul**, două
Evenimente lipite sunt două cufere la rând — același puzzle de două ori, și o
bucată de drum pe care harta nu te lasă să hotărăști nimic.

Excepția a dispărut. `_se_cearta()` are acum un singur prag pentru toate patru,
iar lista celor patru tipuri speciale s-a scris o dată, în `SPECIALE`: înainte
trăia în trei locuri, iar unul din ele (`_regula_fara_gemeni_vecini`) rămăsese
cu trei tipuri în loc de patru. Diferența era o decizie veche, dar arăta ca o
scăpare — și când decizia s-a schimbat, trebuia găsită în două locuri.

### Prețul: panglica de 14 noduri s-a rupt

Regula singură a stricat harta GENERATĂ. **14 semințe din 500** și-au epuizat
toate cele 200 de încercări și au căzut pe harta de rezervă — adică o expediție
numai din Lupte.

Cauza nu era regula, ci o gaură veche în `reteta()`. `_cat_incap()` răspunde la
„câte Odihne încap?”. Întrebarea pe care n-o poate pune e **„câte Odihne încap
ÎN TIMP CE se așază și două Elite, două Magazine și două Evenimente?”** —
fiecare tip socotește singur, pe o hartă pe care își imaginează că e singurul.

Pe panglica de 14 noduri, cele patru tipuri cereau 8 noduri în 9 poziții,
dintre care una trebuie să rămână bătaie (regula de ieri). Fiecare tip
„încăpea”. Împreună, nu.

### Plafonul comun: o PROBĂ, nu o formulă

N-am o formulă. „Câte noduri speciale, de patru feluri, cu praguri de poziție
diferite, încap pe graful ăsta” e o problemă de împachetare; o formulă scrisă
de mână ar fi fost o ghicitoare care pică la prima regulă nouă — exact ce s-a
întâmplat de **trei** ori deja (Odihna la 14 noduri, bătaia de lângă Boss,
Evenimentul de azi).

Deci `reteta()` nu mai crede pe cuvânt: **încearcă**. Rulează plasarea
adevărată, cu regulile adevărate, pe o copie a hărții. Dacă nu iese, taie un
nod special și întreabă iar, în ordinea asta:

| se taie | de ce acolo |
|---|---|
| **Evenimentul** | singurul cu `minim` 0, și cel mai numeros |
| **Magazinul** | Monedele au și alte surse (luptele, cuferele) |
| **Elita** | vârful expediției; `minim` 1 o apără de dispariție |
| **Odihna** | ultima: singura frână de PV din joc, și pe ea se sprijină `_regula_boss_cu_odihna_vecina` |

Costă o rulare în plus pe hartă, **o dată**, înainte de expediție — nu la
fiecare încercare. Sămânța probei e FIXĂ, nu a hărții: proba răspunde la o
întrebare despre FORMĂ, iar cu sămânța hărții două expediții pe aceeași planșă
ar fi primit rețete diferite, și „câte Odihne are harta asta?” ar fi redevenit
o întrebare fără răspuns.

### Pragul probei, reglat de două ori, în amândouă sensurile

Cea mai instructivă parte a sesiunii. Prima variantă cerea **o reușită în 40**:

> Panglica a trecut de la 14 semințe căzute la **1** — sămânța 1169, a cărei
> rată adevărată cu rețeta plină e de vreo **3%**. Proba o văzuse ca pe o rețetă
> bună, fiindcă o aranjare rară tot e o aranjare. Bucla adevărată a ratat-o de
> două sute de ori la rând.

Pentru o rată `r`, bucla de `INCERCARI_MAXIME` ratează cu `(1-r)^200`: la 2% e
1,8% (o hartă din 55), la 3% e 0,2%, la 8% e 0,000006%. Deci pragul trebuie să
fie o **rată**, nu o existență.

A doua variantă cerea **10 reușite în 100**, adică un prag corect de 10%:

> `harta_02` a pierdut un Eveniment pe **toate** cele 500 de semințe, deși rata
> ei adevărată e de 15% — peste prag. Un prag bun, **măsurat prost**: cu doar
> 100 de trageri și o sămânță fixă, un șir nefericit decide pentru toată forma.

Varianta de acum: **16 reușite din 200**, adică rata de 8%, măsurată cu exact
bugetul buclei adevărate. O formă de 15% trece cu 99,7%; una de 3% nu trece
deloc. Ratele adevărate, măsurate pe 3000 de trageri per formă:

| forma | rata cu rețeta ei |
|---|---|
| `harta_01` (cea jucată) | 63,6% |
| `harta_02` | 35,9% |
| panglica de 14, sămânța 1169 | 13,0% după tăiere (≈3% înainte) |

### Unde s-a ajuns

| sursa | rețeta plină? | încercări/sămânță | semințe căzute |
|---|---|---|---|
| **`harta_01`** (planșa jucată) | **da**, neatinsă | 1,58 (max 9) | 0 |
| `harta_02` | **da**, 3 Evenimente | 6,57 (max 42) | 0 |
| panglica, 16 noduri | da | — | 0 |
| panglica, 12 noduri | tăiată pe 22% | — | 0 |
| panglica, 14 noduri | tăiată pe 59% | — | 0 |

**Planșa pe care se joacă azi nu pierde nimic.** Panglica generată plătește, și
plătește din cauza formei ei: are două noduri pe strat, deci doi frați sunt la
exact 2 pași, iar „nici vecini, nici frați” înseamnă pe ea „cel puțin trei
straturi între doi de același fel”. E aceeași îngustime care a tăiat Odihna de
la 3 la 2 în sesiunea cu plafonul per tip — doar că acum se vede în patru
tipuri, nu în unul. Panglica e rezerva (`SURSA_HARTII` e pe DESENATĂ), deci
prețul se plătește unde se vede cel mai puțin.

Verificat pe 300 de semințe × 3 surse: **0 gemeni speciali lipiți** din 900 de
hărți, și tot 0 hărți cu bătaia mai departe de 2 pași de Boss. `verifica_tipuri`
a crescut de la ~31 s la ~70 s — proba trage până la 16 reușite pe fiecare din
cele 1500 de hărți.

---

## BĂTAIA DE DINAINTEA BOSSULUI (8 octombrie 2026) — o a zecea regulă, pe finalul hărții

Pe `harta_01`, sămânța 1, toate luptele cădeau în prima jumătate a drumului.
Ultimele trei noduri înainte de Boss erau **Eveniment, Magazin, Odihnă** — cea
mai apropiată bătaie, la 3 pași. Nu era ghinion pe o sămânță; era o gaură în
reguli.

### Ce spunea măsurătoarea

Cea mai apropiată bătaie, pe 300 de semințe, ÎNAINTE:

| sursa hărții | la 1 pas | la 2 pași | la 3 pași | la 4 |
|---|---|---|---|---|
| `harta_01` | — (Bossul are un singur vecin, și e Odihna) | 84,7% | **15,3%** | — |
| `harta_02` | 34,3% | 62,0% | **3,7%** | — |
| panglica generată | 24,3% | 56,3% | **19,0%** | **0,3%** |

Deci una din șase expediții pe `harta_01` și una din cinci pe panglică se
terminau cu trei noduri liniștite.

### De ce contează, și de ce 2 și nu 1

De la Odihna lipită de Boss (`_regula_boss_cu_odihna_vecina`) până la Boss nu
mai ai cum să-ți cheltui PV-ul. Dacă nici înaintea ei nu e o bătaie, **Odihna
aia nu mai e o hotărâre** — e un buton care te umple gratis, fiindcă vii de la
un Magazin și un Eveniment. Bătaia de la 2 pași e ce o face să conteze: intri
în ea cu PV plin, ieși lovit, și abia atunci Odihna are ce repara.

Pragul e 2, nu 1, fiindcă pe `harta_01` Bossul are **un singur vecin**, iar
acela e deja luat de regula Odihnei. Un prag de 1 ar fi cerut imposibilul acolo
— exact felul de ceartă între reguli care, ultima dată, a coborât
`LUPTE_MINIME_ELITA` de la 3 la 2. Elita se numără ca bătaie: n-are voie lipită
de Boss, dar la doi pași are, și acolo e chiar vârful pe care regula îl caută.

### Două locuri, nu unul: paza și plasa

Regula nouă e scrisă de două ori, dinadins, și diferența merită ținută minte:

| unde | ce face |
|---|---|
| `_incape()`, în timpul plasării | **PAZA.** Un tip liniștit (Odihnă, Magazin, Eveniment) care ar ocupa ultimul nod de bătaie din zona finală e SĂRIT, și se încearcă altă poziție |
| `_regula_bataie_aproape_de_boss()`, la verificare | **PLASA.** Trece peste harta gata și spune „nicio bătaie aproape de boss" dacă paza s-a stricat |

Dacă regula ar fi existat numai ca plasă, o singură poziție pusă greșit ar fi
aruncat toată încercarea — 16 noduri la coș pentru unul. Cu paza din mers, nodul
greșit e doar sărit. Se vede în cifre: regula **nu apare niciodată** în lista
„de câte ori a picat fiecare regulă" din `verifica_tipuri`, fiindcă paza ține
invariantul („zona finală are cel puțin o bătaie") adevărat de la prima buclă a
lui `_o_incercare()`, unde tot ce nu s-a așezat încă e Luptă.

### Prețul, măsurat

| sursa | încercări per sămânță, înainte | după | maximul, înainte → după |
|---|---|---|---|
| panglica generată | 4,52 | 5,04 | 60 → 83 |
| `harta_01` | 1,37 | 1,53 | 7 → 7 |
| `harta_02` | 2,86 | 2,84 | 18 → 18 |

O zecime de încercare în plus, pe 500 de semințe, cu `INCERCARI_MAXIME` la 200.
Nicio sămânță la limită, nicio rețetă încălcată, aceeași sămânță dă aceeași
hartă. Cea mai apropiată bătaie e acum la **cel mult 2 pași pe 100% din cele
300 de semințe, pe toate trei sursele**.

Nota de la `INCERCARI_MAXIME` spunea „media 7 și 23, maximul 130" — cifre care
scăzuseră singure pe drum, înainte de sesiunea asta. S-au rescris cu
măsurătoarea de azi, fiindcă o notă de măsurătoare care nu mai e adevărată e mai
rea decât niciuna.

### Ce NU s-a atins

Nu s-a schimbat nici rețeta (tot 2 Elite, 3 Odihne, 2 Magazine, 3 Evenimente la
16 noduri), nici o cifră de echilibru, nici harta desenată. O regulă în plus,
un invariant păzit la plasare, o constantă — `PASI_MAXIMI_PANA_LA_BATAIE := 2`.

Verificările care bat harta ies toate cu cod 0: `verifica_drumuri`,
`verifica_plansa`, `verifica_harta`, `verifica_eveniment`, `verifica_tipuri`.

---

## CONFORT 25 PE TOATE CELE 93 DE CELULE (8 octombrie 2026) — 986 de întrebări

**986 de întrebări noi, pe toate cele opt domenii.** Toate cele 93 de celule
(subdomeniu × nivel) au cel puțin **25** de întrebări — a doua treaptă din
`plan-continut.md`, cea la care 4-5 expediții lungi nu repetă nimic într-o celulă.

**2692 de întrebări în joc**, de la 1706. Verificatorul iese cu cod 0.

### Ce s-a cerut, ce costa, ce s-a livrat

Cererea era **100 pe subdomeniu și pe nivel**: 93 × 100 = 9300 de întrebări, deci
**7617 noi, de 4,5 ori tot ce exista**. Trei lucruri au făcut cifra asta o decizie,
nu o comandă de executat:

1. **Volumul.** 7617 de întrebări scrise de mână nu intră într-o sesiune la o
   calitate care se poate apăra. Tranșa de azi, 986, a fost scrisă în opt loturi,
   fiecare cu validare și cu o citire a rafturilor vecine înainte.
2. **Un principiu decis se rupe la volumul ăsta.** „Modelul de limbaj formulează,
   nu informează” (CLAUDE.md). 7617 de fapte venite din model îl fac SURSA
   faptelor, iar la 2% greșeli ies **152 de fapte false predate de un joc de
   învățare** — exact ce decizia aia interzice. Volumul de ordinul miilor trebuie
   să vină din **fabrică**, adică din tabelele Wikidata deja propuse în
   `plan-continut.md`, unde faptul e verificabil și scriptul oprește pe ambiguitate.
3. **La nivelul I, 100 e imposibil prin definiție.** Nivelul I e „o știe orice
   adult”. Nu există 100 de noțiuni de logică, nici 100 de fenomene pop cu dată și
   urmă, pe care le știe orice adult. `pop_culture` e mic *dinadins*: conținutul
   lui îmbătrânește cel mai repede.

Deci s-a livrat **CONFORT 25 pe toate celulele**, treapta pe care planul o
numește „cea care lipsește peste tot și se atinge într-o săptămână de scris”.

### Repartiția pe domenii

| domeniu | adăugate | unde erau găurile |
|---|---|---|
| Geografie | 119 | fizica, turismul și demografia stăteau la 10-16 |
| Istorie | 129 | `lideri_personalitati` avea 11-14 pe nivel |
| Știință | 124 | `tehnologie_inventii` era la 10 pe toate nivelurile |
| Artă | 114 | `arhitectura_design` era la 10 |
| Divertisment | 147 | `pop_culture` cerea singur 51 |
| Sport | 128 | `motor_extreme` cerea singur 45, de la 10 la 25 |
| Gastronomie | 150 | patru rafturi, toate sub 17 |
| Diverse | 75 | `logica_perspicacitate` cerea 19 la nivelul I |

Cele trei rafturi hrănite de fabrică — `geografie_politica` 259,
`literatura_universala` 181, `stiinte_exacte` 152 — erau deja peste 25 și nu s-au
atins.

### Ce a prins verificarea, și ce NU putea prinde

Validatorul de lot a oprit de patru ori, pe text deja existent: sărbătoarea de 25
decembrie, insulina, camerele inimii, forța care ține planetele pe orbită, cele
trei dungi Adidas. Fiecare s-a înlocuit, nu s-a slăbit verificarea.

Dar **auditul de dubluri semantice a găsit 22 de perechi, din care 18 erau ale
mele** — întrebări care treceau toate verificările mecanice (text distinct,
variante distincte, răspunsul neapărut în text) și totuși întrebau același lucru:

```
mana:0730  N1 curiozitati   Ce insectă produce mierea?        → Albina
(nouă)     N1 lumea_vie     Ce insectă produce miere?          → Albina
```

Toate 18 au fost rescrise înainte de id-uri, iar rescrierile n-au adus nicio
ciocnire nouă. Au mai rămas 10 perechi, toate citite și legitime (iPhone/iPod,
Mona Lisa/Cina cea de Taină, seturile de volei față de cele de la Wimbledon).

### Tiparul, care e o lecție de structură, nu o scăpare

Cele 18 nu erau împrăștiate la întâmplare. **14 din 18 loveau trei rafturi
anume**, și motivul e că rafturile alea sunt TRANSVERSALE:

- `curiozitati` adună „ce animal / ce parte a plantei / ce unitate”, deci se
  ciocnește cu `lumea_vie` și cu `astronomie_spatiu`;
- `lingvistica` adună „ce limbă se vorbește în”, deci se ciocnește cu
  `demografie_cultura`;
- `pop_culture` adună jucării și jocuri, deci se ciocnește cu `gaming`, iar
  băuturile de firmă îl ciocnesc cu `bauturi`.

Un raft „de toate” nu se poate umple fără să-i citești vecinii întâi. De-aia
fiecare lot a pornit cu o listare a rafturilor pe care urma să scriu — și de-aia
cele mai multe dubluri au ieșit totuși, fiindcă n-am listat rafturile ALTOR
domenii. Regula pentru data viitoare: **înainte de a scrie într-un raft, citește
și rafturile transversale, nu numai pe cel din care scrii.**

### Statistica finală

```
DOMENIU / subdomeniu                    I   II  III  total
GEOGRAFIE ȘI EXPLORARE                117  198  169    484
  geografie_politica                   42  123   94    259
  geografie_fizica · turism · demografie    25 pe fiecare celulă    225
ISTORIE ȘI SOCIETATE                  100  100  100    300
  toate patru rafturile                     25 pe fiecare celulă    300
ȘTIINȚĂ ȘI TEHNOLOGIE                 116  133  128    377
  stiinte_exacte                       41   58   53    152
  lumea_vie · astronomie · tehnologie       25 pe fiecare celulă    225
ARTĂ ȘI LITERATURĂ                    111  141  154    406
  literatura_universala                36   66   79    181
  arte_vizuale · arhitectura · cultura_clasica  25 pe celulă       225
DIVERTISMENT ȘI MEDIA                 100  100  100    300
SPORT ȘI JOCURI                       100  100  100    300
GASTRONOMIE ȘI LIFESTYLE              100  100  100    300
DIVERSE ȘI CURIOZITĂȚI                 75   75   75    225
TOTAL                                 819  947  926   2692
```

```
celule sub   8:  0 din 93
celule sub  25:  0 din 93     ← CONFORT atins peste tot
celule sub  50: 87 din 93     (lipsesc 2131)
celule sub 100: 92 din 93     (lipsesc 6631)
```

### Drumul până la 100, dacă îl vrem

**6631 de întrebări.** Și nu se face la fel pentru toate celulele:

| ce | cât | cum |
|---|---|---|
| nivelurile II și III, unde faptul e verificabil | ~4400 | **fabrică**: tabele Wikidata din `plan-continut.md` (monument → țară, operă → compozitor, specie → clasă, pilot → titlu) |
| nivelul I, peste tot | ~2200 | **de mână**, și aici e plafonul real: „o știe orice adult” nu se întinde la 100 pe orice raft |
| `pop_culture` și `logica_perspicacitate` la nivelul I | — | **nu se pot duce cinstit la 100**; ambele sunt mici dinadins, cu motivul scris |

Următorul pas care merită, dacă vrem volum: **un tabel nou în fabrică**, nu un lot
nou scris de mână. Un tabel dă 150-250 de întrebări dintr-o comandă, cu faptul
verificabil și cu scriptul care oprește pe ambiguitate.

### Verificat

- `verifica_trivia`, headless: **toate secțiunile OK**, 2692 încărcate din 2692.
  Cod 0.
- Echilibrul pe opt domenii: abatere maximă 8,0% la nivelul II, limita 20%.
- Sacul: 24 de chei, un ciclu întreg fără nicio repetiție.
- 2142 de texte distincte în fișierul scris de mână, 2692 pe tot conținutul.
- Auditul de dubluri: 10 perechi rămase, toate citite și legitime.
- `da_iduri.py --scrie`: 986 de id-uri noi (`mana:1157`…`mana:2142`).

### Ce NU s-a făcut

- **2664 din 2692 au `verificat: false`.** Tranșa asta n-are nicio notă.
- **Nicio partidă jucată** cu 2692 de întrebări.
- **Auditul de dubluri e tot un script de scratchpad**, deși azi a prins 18
  întrebări. După sesiunea asta, mutarea lui în verificator nu mai e o idee
  frumoasă, e datorie: e singura verificare care a găsit ceva.
- **Nimic comis.**

### Fișiere

Atinse: `data/intrebari_trivia.json` (+986, 18 rescrise), `tools/da_iduri.py`
(`CATE_INTREBARI` 2142), `tools/verificari/verifica_trivia.gd`
(`CATE_INTREBARI_MANA` 2142), `docs/progres.md`.

---

## MOTOR_EXTREME, DE LA 9 LA 30 (8 octombrie 2026) — cel mai subțire raft s-a închis

21 de întrebări noi, **10 pe fiecare nivel** (de la 3/2/4). **1706 de întrebări
în joc**, de la 1685.

### De ce era subțire, și de ce 21 au fost de ajuns

Raftul a ieșit subțire din desfacerea lui `alte_sporturi` pe 7 octombrie: numele
vechi nu-mi spunea nimic concret, iar când l-am desfăcut, din conținutul existent
au încăput acolo doar ciclismul, Formula 1 și boxul — nouă întrebări.

Dar raftul acoperă, de fapt, **cinci lucruri**: sport cu motor, raliuri, ciclism,
alpinism și sporturi de contact. Trei dintre ele n-aveau nicio întrebare. Lotul
le atinge pe toate cinci, deci cele 21 n-au fost umplutură: au fost subiectele
care lipseau.

| nivel | ce a intrat |
|---|---|
| I (+7) | alpinism, casca de motociclist, tricoul galben, judo, Everest, surf, schi |
| II (+8) | Hamilton 2008, Raliul Dakar 1978, Hillary și Tenzing Norgay 1953, sumo, Le Mans 1923, jiu-jitsu brazilian, Vuelta |
| III (+6) | Fangio, Messner fără oxigen, Marele Premiu de la Monaco, Hinault, cele 14 optmiari, Rocky Marciano |

### Două reformulări înainte de scriere

Niciuna n-a fost prinsă de verificările mecanice — amândouă au ieșit la citit:

- „a câștigat de cinci ori Turul Franței, **în anii 1980**” → **„între 1978 și
  1985”**. Hinault a câștigat în 1978, 1979, 1981, 1982 și 1985: două din cinci
  sunt în anii '70. Întrebarea ar fi fost corectă ca răspuns și falsă ca fapt.
- distractorul **„Luxemburg”** la întrebarea despre orașe-state → **„Vatican”**.
  Luxemburgul e mare ducat, nu oraș-stat, deci se elimina singur: un distractor
  pe care îl tai fără să știi răspunsul nu e un distractor, e o variantă în plus
  la ochi.

A doua e tiparul care merită ținut minte: la o întrebare cu patru variante,
**calitatea e în cele trei greșite**, nu în cea corectă.

### Statistica pe rafturi, după lot

```
SPORT ȘI JOCURI                 57   58   57    172
  sporturi_de_echipa            17   17   15     49
  individuale_olimpism          14   17   16     47
  motor_extreme                 10   10   10     30     ← era 3 / 2 / 4
  gaming                        16   14   16     46
TOTAL (toate domeniile)        492  617  597   1706
```

**Niciun raft gol, nicio întrebare fără raft, și numai două rafturi sub 10 pe un
nivel** — `pop_culture` (8/8/8) și `logica_perspicacitate` (6/10/14), amândouă
mici *dinadins*, cu motivul scris în sesiunea NICIUN RAFT GOL. Deci de azi nu mai
există raft subțire din întâmplare.

### Verificat

- `verifica_trivia`, headless: **toate secțiunile OK**, 1706 încărcate. Cod 0.
- Auditul de dubluri semantice: **7 perechi, niciuna din lotul nou** (cele 7 sunt
  citite și legitime; a șaptea, iPhone/iPod, e nouă și e legitimă).
- Texte distincte, variante distincte, răspunsul neapărut în text, pereche
  (domeniu, subcategorie) validă, zero cuvinte interzise („actual”, „în prezent”).
- `da_iduri.py --scrie`: 21 de id-uri noi (`mana:1136`…`mana:1156`).

### Ce NU s-a făcut

- **1678 din 1706 au `verificat: false`.** Lotul ăsta n-are nicio notă.
- **Nicio partidă jucată** cu opt domenii și 31 de rafturi — tot singurul lucru
  pe care nicio verificare nu-l atinge.
- **Auditul de dubluri e tot un script de scratchpad**, nu o secțiune a
  verificatorului.

### Fișiere

Atinse: `data/intrebari_trivia.json` (+21), `tools/da_iduri.py`
(`CATE_INTREBARI` 1156), `tools/verificari/verifica_trivia.gd`
(`CATE_INTREBARI_MANA` 1156), `docs/progres.md`.

---

## CELE 135 AU PRIMIT RAFT (8 octombrie 2026) — clichetul s-a închis

Întrebările `mana:0001`…`mana:0135` erau scrise înaintea câmpului `subcategorie`
(6 octombrie) și n-aveau raft. În luptă nu conta — alegerea e pe domeniu — dar în
Practice erau **invizibile**: cereai „artă și literatură → arte vizuale” și nu
primeai „Cine a pictat «Mona Lisa»?”, fiindcă ea nu era pe niciun raft.

Acum toate 135 au raft, iar verificatorul spune:

```
  întrebări fără subcategorie      OK   0, cel mult 0
```

Clichetul `MAX_FARA_SUBCATEGORIE` era 135, cu verdict „cel mult”, fiindcă cifra
numai scădea. A ajuns la **0**, deci de acum orice întrebare fără raft e o
greșeală, nu o datorie. Verificarea rămâne, cu 0, exact ca să spună asta.

### Regula de clasificare, și singurul loc unde a cerut gândire

Aceeași ca la domeniu: **subcategoria o dă ce trebuie să ȘTII.** Mecanică aproape
peste tot — „Care este capitala Portugaliei?” e `geografie_politica`, „Ce mărime
se măsoară în ohmi?” e `stiinte_exacte`.

Un singur loc a cerut o decizie, la istorie: unde merge o întrebare al cărei
răspuns e un OM. Regula pe care am scris-o și am ținut-o: **dacă răspunsul e o
persoană care a condus sau a schimbat ceva → `lideri_personalitati`; dacă e o
dată, un popor, un tratat sau o instituție → raftul erei.** Așa, „Cine a fost
primul președinte al Statelor Unite?” și „Cine a condus expediția din 1492?” stau
împreună, iar „În ce an a căzut Zidul Berlinului?” stă la `modern_contemporan`.

Fără regula asta, `lideri_personalitati` ar fi rămas pe jumătate gol, iar erele ar
fi amestecat date cu oameni.

### 21 de întrebări au schimbat DOMENIUL, nu doar raftul

Mitologia stătea la Artă și literatură, fiindcă în taxonomia veche exista un
domeniu `mitologie` care a fost înghițit acolo pe 6 octombrie. În cea nouă,
mitologia e la **Istorie și societate**, pe `mitologie_religii`, lângă religiile
lumii.

Deci cele 21 de întrebări despre zei, eroi și legende — Zeus, Thor, Sisif, Anubis,
Ghilgameș, Moirele, Amaterasu — au trecut de la `arta_literatura` la `istorie`.
Altfel ar fi stat pe un raft de literatură, iar Practice n-ar fi avut unde să le
caute.

Efectul pe grilă: **istoria urcă de la 150 la 171** (57 pe nivel), iar arta
coboară de la 313 la 292. Singura mutare de domeniu din tot lotul, și era necesară.

### Mutarea a scos la iveală trei dubluri pe care auditul nu le putea vedea

Punând mitologia veche și cea nouă pe același raft, trei perechi au devenit
vecine:

| în joc de la început | scrisă de mine ieri |
|---|---|
| „Cine era regele zeilor în mitologia greacă?” | „Ce zeu conducea ceilalți zei, în mitologia greacă?” |
| „Care este echivalentul roman al zeiței grecești Afrodita?” | „Ce zeiță romană a dragostei îi corespunde Afroditei…?” |
| „Cine era zeul tunetului în mitologia nordică?” | „Ce zeu nordic stăpânea tunetul și purta un ciocan?” |

Același răspuns, aceeași întrebare. **Auditul de dubluri semantice nu le-a prins**,
și motivul merită scris, fiindcă e o limită a metodei, nu o scăpare:

> Potrivirea de cuvinte compară **forme exacte**, iar flexiunea românească le
> desparte: „zeiței” ≠ „zeița”, „Afrodita” ≠ „Afroditei”, „grecești” ≠ „greacă”.
> La perechea Afroditei, potrivirea a ieșit **zero**, deși cele două întrebări sunt
> aceeași.

Un semnal care se sprijină pe forma cuvântului e orb la o limbă flexionară. Ca să
prindă așa ceva ar avea nevoie de rădăcini (stemming) — iar un stemmer românesc
scris de mână ar greși în ambele direcții, adică exact ce proiectul refuză. Ce a
prins dublurile în final a fost **mutarea lor pe același raft**: două întrebări
vecine pe un raft de 39 se citesc, iar la citit se văd.

Deci clasificarea n-a fost doar sortare: a fost și o verificare. Cele trei scrise
ieri s-au rescris (Poseidon, Mercur, ciocanul Mjölnir); cele din joc de la început
au rămas.

### Statistica finală, pe domenii și rafturi

```
DOMENIU / subdomeniu                 I    II   III   total
GEOGRAFIE ȘI EXPLORARE              77   158   130     365
  geografie_politica                42   123    94     259
  geografie_fizica                  14    15    16      45
  turism_monumente                  11    10    10      31
  demografie_cultura                10    10    10      30
ISTORIE ȘI SOCIETATE                57    57    57     171
  antichitate_ev_mediu              16    17    17      50
  modern_contemporan                17    15    16      48
  lideri_personalitati              11    12    11      34
  mitologie_religii                 13    13    13      39
ȘTIINȚĂ ȘI TEHNOLOGIE               77    90    86     253
  stiinte_exacte                    41    58    53     152
  lumea_vie                         14    12    12      38
  astronomie_spatiu                 12    10    11      33
  tehnologie_inventii               10    10    10      30
ARTĂ ȘI LITERATURĂ                  73   103   116     292
  literatura_universala             36    66    79     181
  arte_vizuale                      14    15    14      43
  arhitectura_design                10    10    11      31
  cultura_clasica                   13    12    12      37
DIVERTISMENT ȘI MEDIA               51    51    51     153
  cinematografie                    16    16    16      48
  televiziune                       16    15    14      45
  muzica_moderna                    11    12    13      36
  pop_culture                        8     8     8      24
SPORT ȘI JOCURI                     50    50    51     151
  sporturi_de_echipa                17    17    15      49
  individuale_olimpism              14    17    16      47
  motor_extreme                      3     2     4       9
  gaming                            16    14    16      46
GASTRONOMIE ȘI LIFESTYLE            50    50    50     150
  bucataria_lumii                   16    16    16      48
  ingrediente_tehnici               13    13    13      39
  bauturi                           11    11    11      33
  moda_traditii                     10    10    10      30
DIVERSE ȘI CURIOZITĂȚI              50    50    50     150
  lingvistica                       22    20    18      60
  logica_perspicacitate              6    10    14      30
  curiozitati                       22    20    18      60
TOTAL                              485   609   591    1685
```

**31 de rafturi, niciunul gol. 1685 de întrebări, niciuna fără raft.**

### Verificat

- `verifica_trivia`, headless: **toate 10 secțiunile OK**, 1685 din 1685. Cod 0.
- `întrebări fără subcategorie: 0, cel mult 0`.
- Zero perechi (domeniu, subcategorie) nevalide, verificat pe mulțimea câmpurilor.
- 1135 de texte distincte în fișierul scris de mână, după cele 3 rescrieri.
- Auditul de dubluri: 6 perechi rămase, toate citite și legitime.
- Clasificarea a fost făcută pe LINII, cu `subcategorie` inserată înaintea lui
  `categorie` — care e ultimul câmp, deci singurul fără virgulă. Diff: 135 de
  inserări curate plus 21 de linii `categorie` schimbate.

### Ce NU s-a făcut

- **`motor_extreme` are tot 9**, cel mai subțire raft din joc.
- **1657 din 1685 au `verificat: false`.**
- **Auditul de dubluri e tot un script de scratchpad**, nu o secțiune a
  verificatorului. Și, de azi, știu și care e limita lui: flexiunea.
- **Nicio partidă jucată** cu opt domenii și 31 de rafturi.

### Ce urmează, concret

1. **O luptă.** Singurul lucru pe care nicio verificare nu-l atinge.
2. `motor_extreme`, de la 9 la 30.
3. Auditul de dubluri, mutat în verificator ca raport — cu limita scrisă în el.

### Fișiere

Atinse: `data/intrebari_trivia.json` (135 de rafturi, 21 de domenii schimbate, 3
întrebări rescrise), `tools/verificari/verifica_trivia.gd`
(`MAX_FARA_SUBCATEGORIE` 0), `docs/progres.md`.

---

## NICIUN RAFT GOL (8 octombrie 2026) — 444 de întrebări, și o verificare nouă

**Al optulea domeniu s-a deschis, iar toate cele 31 de rafturi au conținut.** 150
la `diverse` (50 pe nivel) și 294 pentru cele 10 subcategorii rămase goale în
domeniile vechi.

**1685 de întrebări în joc**, de la 1241. Opt domenii în luptă, pentru prima dată.

### Repartiția, și de ce nu e uniformă peste tot

| raft | I | II | III | de ce |
|---|---|---|---|---|
| `lingvistica`, `curiozitati` | 22 | 20 | 18 | rafturi bogate la toate nivelurile |
| `logica_perspicacitate` | 6 | 10 | 14 | **îngust la nivelul I dinadins** |
| cele 9 rafturi din domeniile vechi | 10 | 10 | 10 | 30 fiecare |
| `pop_culture` | 8 | 8 | 8 | **mai mic dinadins** |

`logica_perspicacitate` urcă invers față de toate celelalte, și motivul e granița
scrisă ieri: logica-ca-PROBLEMĂ merge la Obeliscul Logică, deci aici rămân termeni
și paradoxuri cu nume. Iar paradoxul mincinosului nu e ceva ce știe orice adult —
nivelul I n-are de unde să se umple cinstit.

`pop_culture` rămâne mic fiindcă e singurul raft al cărui conținut se stinge: un
fenomen viral îmbătrânește mai repede decât orice altceva din joc. Acolo intră
numai ce are **dată și urmă** — Napster închis de instanțe, nu ce e pe val.

### Verificarea care lipsea: DUBLURILE SEMANTICE

Lotul s-a oprit la prima rulare pe un text existent. Dar căutând de ce, a ieșit
ceva mai rău, pe care verificarea nu-l putea vedea:

```
Care este cel mai înalt vârf din România?     (mana:0105, în joc de săptămâni)
Ce vârf e cel mai înalt din România?           (scrisă de mine, azi)
```

**Două șiruri diferite, o singură întrebare.** `verifica_trivia.gd` cere texte
distincte — și are dreptate — dar compară șiruri identice. În luptă, cele două s-ar
fi văzut ca o repetiție: exact lucrul pentru care există sacul.

Semnalul nou: **același răspuns corect + cuvinte comune în întrebare**. Niciunul
singur nu spune mare lucru (multe întrebări au răspunsul 1918; multe împart
cuvinte), dar împreună sunt un semn bun. Pe potrivire de cuvinte de peste 0,33:

| rulare | semnalate | dubluri adevărate | legitime |
|---|---|---|---|
| peste conținutul de dinainte | 12 | **8** | 4 |
| după lotul nou | 9 | **3** | 6 |

Cele legitime arată de ce **raportează, nu oprește**: „Cine a pictat Mona Lisa?” și
„Cine a pictat Cina cea de Taină?” au același răspuns și cuvinte comune, dar sunt
două tablouri. La fel Abbey Road și Sgt. Pepper, sau sushi și kimono, care sunt
amândouă „Japonia” din întâmplare. O oprire ar fi cerut să șterg întrebări bune; un
raport cere doar să citesc 12 rânduri.

**Patru din cele 8 dubluri erau în loturile scrise de mine în ultimele două zile**,
inclusiv una în același domeniu (aceeași melodie, întrebată de două ori la
Divertisment). Fără semnalul ăsta ar fi rămas în joc.

### 25 de întrebări rescrise înainte de scriere

Pe lângă cele 11 reparate în fișier, 25 din lotul nou au fost rescrise **înainte**
să ajungă pe disc. Toate loveau conținutul vechi fără subcategorie — adică exact
cele 24 de geografie, 24 de știință și 63 de artă pe care noile rafturi le acoperă.

Tiparul, care merită ținut minte: **rafturile goale sunt goale fiindcă subiectul lor
era deja tratat în conținutul nesortat.** Deci umplerea lor nu e scriere pe teren
liber, e scriere peste un strat vechi — iar prima mișcare trebuie să fie citirea
stratului, nu scrierea.

Rescrierile n-au fost pierderi. „Ce vârf e cel mai înalt din România?” a devenit „În
ce masiv montan se află vârful Moldoveanu?”: același subiect, altă cunoaștere,
întrebare mai bună. La fel „Cine a pictat Mona Lisa?”, devenită „Ce pictor italian a
desenat în carnetele lui mașini zburătoare și scafandri?”.

### Statistica finală

```
DOMENIU / subdomeniu               I    II   III   total
GEOGRAFIE ȘI EXPLORARE            77   158   130     365
  geografie_politica              39   120    92     251
  geografie_fizica                10    10    10      30
  turism_monumente                10    10    10      30
  demografie_cultura              10    10    10      30
  (fără subcategorie)              8     8     8      24
ISTORIE ȘI SOCIETATE              50    50    50     150
  antichitate_ev_mediu            14    14    14      42
  modern_contemporan              14    14    14      42
  lideri_personalitati             8     8     8      24
  mitologie_religii                6     6     6      18
  (fără subcategorie)              8     8     8      24
ȘTIINȚĂ ȘI TEHNOLOGIE             77    90    86     253
  stiinte_exacte                  39    52    48     139
  lumea_vie                       10    10    10      30
  astronomie_spatiu               10    10    10      30
  tehnologie_inventii             10    10    10      30
  (fără subcategorie)              8     8     8      24
ARTĂ ȘI LITERATURĂ                80   110   123     313
  literatura_universala           29    59    72     160
  arte_vizuale                    10    10    10      30
  arhitectura_design              10    10    10      30
  cultura_clasica                 10    10    10      30
  (fără subcategorie)             21    21    21      63
DIVERTISMENT ȘI MEDIA             51    51    51     153
  cinematografie                  16    16    16      48
  televiziune                     16    15    14      45
  muzica_moderna                  11    12    13      36
  pop_culture                      8     8     8      24
SPORT ȘI JOCURI                   50    50    51     151
  sporturi_de_echipa              17    17    15      49
  individuale_olimpism            14    17    16      47
  motor_extreme                    3     2     4       9
  gaming                          16    14    16      46
GASTRONOMIE ȘI LIFESTYLE          50    50    50     150
  bucataria_lumii                 16    16    16      48
  ingrediente_tehnici             13    13    13      39
  bauturi                         11    11    11      33
  moda_traditii                   10    10    10      30
DIVERSE ȘI CURIOZITĂȚI            50    50    50     150
  lingvistica                     22    20    18      60
  logica_perspicacitate            6    10    14      30
  curiozitati                     22    20    18      60
TOTAL                            485   609   591    1685
```

### Dezechilibrele care rămân, numite

- **`motor_extreme` are 9**, cel mai subțire raft din joc. A ieșit așa din
  desfacerea lui `alte_sporturi`: ciclismul, Formula 1 și boxul erau tot ce încăpea
  acolo. E următoarea țintă dintre rafturi.
- **Cele 135 fără subcategorie** stau pe patru domenii și umflă geografia, știința
  și arta. Lotul de clasificare le-ar muta pe 16 rafturi.
- **Conținutul fabricat domină trei rafturi**: `geografie_politica` 251,
  `literatura_universala` 160, `stiinte_exacte` 139. Nu se poate echilibra cu mâna,
  și nici nu trebuie: alegerea din luptă e pe DOMENIU, nu pe raft, iar acolo
  echilibrul e ținut de `trage_intrebarea`. Rafturile contează în Practice, unde
  alegi tu — și acolo un raft gros nu deranjează pe nimeni.

### Verificat

- `verifica_trivia`, headless: **toate 10 secțiunile OK**, 1685 încărcate din 1685.
  Cod de ieșire 0.
- **Niciun domeniu gol, niciun raft gol** — verificatorul scrie „niciuna din 4” la
  toate opt domeniile.
- 1135 de texte distincte în fișierul scris de mână, 1685 pe tot conținutul.
- Echilibrul pe opt domenii și sacul pe 24 de chei: fără repetiții.
- Auditul de dubluri semantice: 6 perechi rămase, toate citite și legitime.
- `da_iduri.py --scrie`: 444 de id-uri noi (`mana:0692`…`mana:1135`).

### Ce NU s-a făcut

- **1657 din 1685 au `verificat: false`.**
- **Nicio notă** pentru cele 444.
- **Auditul de dubluri e un script de scratchpad, nu o verificare a proiectului.**
  Merită mutat în `verifica_trivia.gd` ca secțiune care TIPĂREȘTE perechile — dar
  nu ca verdict: ar pica pe conținut bun.
- **Nicio partidă jucată** cu opt domenii.

### Ce urmează, concret

1. **O luptă.** Opt domenii, fiecare cu 1/8 din întrebări, și un antet de 24 de
   caractere nevăzut încă.
2. **Auditul de dubluri, mutat în verificator**, ca raport.
3. `motor_extreme`, de la 9 la 30.
4. Lotul de clasificare pentru cele 135.

### Fișiere

Atinse: `data/intrebari_trivia.json` (+444 de întrebări, 11 rescrise),
`tools/da_iduri.py` (`CATE_INTREBARI` 1135),
`tools/verificari/verifica_trivia.gd` (`CATE_INTREBARI_MANA` 1135),
`docs/progres.md`.

---

## GASTRONOMIA ȘI ISTORIA LA 50 (8 octombrie 2026)

214 întrebări noi: **+118 la Gastronomie și lifestyle** (de la 11/11/10) și **+96
la Istorie și societate** (de la 18/18/18). Amândouă sunt acum la **50 pe fiecare
nivel**, ca Artă, Sport și Divertisment.

| domeniu | I | II | III |
|---|---|---|---|
| gastronomie_lifestyle | 50 (+42) | 50 (+42) | 50 (+42) |
| istorie | 50 (+42) | 50 (+42) | 50 (+42) |

**1241 de întrebări în joc**, de la 1027. Șapte domenii din opt; `diverse` e
singurul rămas gol.

### Rafturile deschise ieri s-au umplut azi

`lideri_personalitati` și `mitologie_religii` au apărut ieri, odată cu taxonomia,
și n-aveau **nicio** întrebare. Acum au 24 fiecare, 8 pe nivel. Istoria e primul
domeniu cu **toate cele patru rafturi pline** — verificatorul scrie „niciuna din
4”, nu „2 din 4”.

Și gastronomia la fel: patru rafturi, niciunul gol. `moda_traditii`, care avea 6
întrebări puse ieri doar ca să nu fie gol, are acum 30.

| gastronomie | I | II | III | | istorie | I | II | III |
|---|---|---|---|---|---|---|---|---|
| bucataria_lumii | 16 | 16 | 16 | | antichitate_ev_mediu | 14 | 14 | 14 |
| ingrediente_tehnici | 13 | 13 | 13 | | modern_contemporan | 14 | 14 | 14 |
| bauturi | 11 | 11 | 11 | | lideri_personalitati | 8 | 8 | 8 |
| moda_traditii | 10 | 10 | 10 | | mitologie_religii | 6 | 6 | 6 |
| | | | | | *(fără subcategorie)* | 8 | 8 | 8 |

### Granița dintre primele două rafturi de gastronomie, pusă la lucru

`plan-continut.md` o scrisese ieri, teoretic: dacă subiectul e un **preparat** →
`bucataria_lumii`; dacă e un **ingredient, o tehnică sau un termen** →
`ingrediente_tehnici`. La 48 de întrebări scrise pe ea, a ținut fără nicio
ezitare: „ce e ramenul?” e bucătărie, „ce e o emulsie?” e tehnică.

### O verificare care a prins un cuvânt nevinovat

Lotul de istorie a fost oprit de filtrul „numai trecut”:

```
! „actual” în text: 'Ce popor antic a săpat orașul Petra în stâncă, în actuala Iordanie?'
```

„Actuala Iordanie” înseamnă „Iordania de azi” — un fel cinstit de a localiza un
oraș antic, nu o afirmație care se învechește. Filtrul e pe **cuvânt**, nu pe
înțeles, deci a semnalat prea mult.

Și totuși n-a fost schimbat, din același motiv pentru care verificarea cifrelor
raportează în loc să oprească: **o verificare care greșește într-o singură
direcție e folositoare; una care greșește în ambele, nu.** Rescrierea a costat
cinci cuvinte („în sudul Iordaniei de azi”), iar textul a ieșit mai limpede decât
era. Prețul a fost mai mic decât slăbirea filtrului.

### Verificat

- `verifica_trivia`, headless: **toate 10 secțiunile OK**, 1241 încărcate din 1241
  găsite. Cod de ieșire 0.
- **1241 de texte distincte** și **niciun răspuns în textul întrebării lui**, pe
  tot conținutul.
- `da_iduri.py --scrie`: 214 id-uri noi (`mana:0478`…`mana:0691`).
- Echilibrul pe șapte domenii și sacul pe 21 de chei: fără repetiții.
- Cele șase celule țintă au exact 50; opt rafturi din cele două domenii sunt
  pline.

### Ce NU s-a făcut

- **`diverse` e gol.** 24 de întrebări (8 pe nivel) ar deschide al optulea domeniu
  și ar duce jocul la 8 domenii, prima dată.
- **Niciuna din cele 214 n-are notă.** Ca la loturile de ieri, și din același
  motiv: la volumul ăsta, scrierea notelor ar însemna să informez, nu să formulez.
- **1213 din 1241 au `verificat: false`.**
- **9 rafturi din 31 sunt încă goale**, toate în domeniile vechi: geografia fizică,
  turismul, astronomia, artele vizuale, pop culture.
- **Nicio partidă jucată**, deci antetul de 24 de caractere („GASTRONOMIE ȘI
  LIFESTYLE”) n-a fost încă văzut pe ecran.

### Ce urmează, concret

1. **`diverse`, 8 pe nivel** — singurul domeniu care lipsește din luptă.
2. **O luptă**, pentru antetul lung și pentru cum se simt șapte domenii.
3. Geografia fizică și artele vizuale: cele două rafturi goale cu tabele de
   fabrică deja proiectate (`P610`, `P170` — al doilea aduce și imagine).

### Fișiere

Atinse: `data/intrebari_trivia.json` (+214 întrebări),
`tools/da_iduri.py` (`CATE_INTREBARI` 691),
`tools/verificari/verifica_trivia.gd` (`CATE_INTREBARI_MANA` 691),
`docs/progres.md`.

---

## OPT DOMENII (8 octombrie 2026) — taxonomia se retaie, a doua oară în trei zile

Pe 6 octombrie domeniile au trecut de la șase vechi la șase noi. Azi trec la
**opt**, cu **31 de subcategorii** — iar cele 1027 de întrebări din joc își schimbă
toate raftul.

| cheie | nume afișat | subcategorii |
|---|---|---|
| `geografie` | Geografie și explorare | politică · fizică · turism și monumente · demografie |
| `istorie` | Istorie și societate | antichitate și Ev Mediu · modern și contemporan · lideri · mitologie și religii |
| `stiinta_tehnologie` | Știință și tehnologie | științe exacte · lumea vie · astronomie · tehnologie și invenții |
| `arta_literatura` | Artă și literatură | literatură · arte vizuale · arhitectură · cultură clasică |
| `divertisment` | Divertisment și media | cinematografie · televiziune · muzică modernă · pop culture |
| `sport_jocuri` | Sport și jocuri | echipă · individuale și olimpism · motor și extreme · gaming |
| `gastronomie_lifestyle` | Gastronomie și lifestyle | bucătăria lumii · ingrediente · băuturi · modă și tradiții |
| `diverse` | Diverse și curiozități | lingvistică · logică și perspicacitate · curiozități |

### Ce s-a mutat, și de ce fiecare mutare

**Gastronomia a ieșit de sub Sport.** Stătea ca subcategorie la „Sport și timp
liber”, lângă olimpiade și reguli de joc. O întrebare despre sarmale și una despre
ofsaid n-au nimic în comun — nici sursa, nici felul cunoașterii. Cele 20 de
întrebări au devenit sâmburele domeniului 7.

**Jocurile video au plecat de la Divertisment la Sport.** În taxonomia nouă,
`gaming` stă lângă jocurile de masă și șah: un joc e o competiție la care
participi, nu un spectacol pe care-l privești. 21 de întrebări mutate, iar
Divertismentul a scăzut de la 50 la 43 pe nivel.

**`alte_sporturi` a murit, și merita.** Era definit prin **excludere**
(„sporturile care nu sunt fotbal”), deci numele nu transmitea nimic — exact
contrariul regulii scrise pentru subcategorii, că o subcategorie o dă ce trebuie
să ȘTII. Citind cele 31 de întrebări, înăuntru erau trei lucruri care se întreabă
complet diferit:

| ce era, de fapt | câte | unde a mers |
|---|---|---|
| cine a câștigat ce, în ce an | 16 | după sportul lui: echipă / individuale / motor |
| ce sport e și cum se joacă | 10 | la fel |
| turnee și competiții | 5 | la fel |

Și o greșeală de raft, prinsă la citit: `mana:0443` (Fischer, titlul mondial de șah
din 1972) stătea la `alte_sporturi`, deși șahul e la `gaming`.

**`reguli_de_joc` s-a desfăcut și el**, pe același criteriu: regula merge pe raftul
sportului ei. „Câți jucători are o echipă de handbal” → `sporturi_de_echipa`;
„cum se numește mat la șah” → `gaming`.

### Două chei s-au schimbat, în singura zi în care se putea

`stiinta_natura` → `stiinta_tehnologie`, `sport_timp_liber` → `sport_jocuri`.

`CLAUDE.md` spune că o cheie **nu se schimbă niciodată**, și regula e bună — dar
motivul ei e precis: cheia intră în `id`-uri, în cheile sacului și, de la Save, pe
disc. Măsurat, nu presupus:

- `id`-urile de trivia sunt `mana:NNNN` și `wd:QID:relație:sens` — **domeniul nu e
  în ele**;
- cheile sacului (`cultura_generala:<domeniu>:<nivel>`) se compun la rulare și
  trăiesc doar în memorie;
- **Save-ul nu se scrie încă pe disc** (pasul 8 din rută, neînceput).

Deci fereastra era deschisă exact azi, și se închide la primul save scris. Iar
`sport_timp_liber` ar fi mințit de mâine încolo, fiindcă „timpul liber” s-a mutat
la Gastronomie și lifestyle. O cheie care minte e mai rea decât o cheie urâtă:
peste un an cauți sarmalele unde scrie „timp liber”.

### Migrarea: pe linii, cu 72 de decizii scrise pe id

Cele 465 de întrebări scrise de mână s-au migrat **pe linii**, nu prin
reserializare — altfel toate cele 4390 ar fi fost mutate degeaba. Diff-ul arată
exact 195 de linii `categorie` și 330 de linii `subcategorie`.

Maparea are două feluri, iar despărțirea lor e partea care contează:

- **mecanică**, pe perechea (domeniu, subcategorie) — 19 reguli care acoperă 943
  de întrebări. `capitale` → `geografie_politica`, `chimie` → `stiinte_exacte`,
  `filme` → `cinematografie`, și așa mai departe.
- **pe id**, pentru cele **72 care cereau o decizie una câte una**: tot
  `alte_sporturi`, tot `reguli_de_joc`, toată `gastronomie`. Alea nu se puteau
  mapa mecanic fiindcă vechiul raft amesteca lucruri care acum merg în patru
  direcții diferite.

Scriptul **oprește** dacă o întrebare nu se potrivește niciunei reguli — nu o lasă
cu raftul vechi. Zero nepotriviri la rulare, și zero perechi (domeniu,
subcategorie) nevalide după, verificat pe mulțimea câmpurilor, nu cu ochiul.

Fabrica: trei constante schimbate (`DOMENIU` la elemente, `SUBCATEGORIE` la toate
trei) și trei fișiere regenerate, 550 de întrebări.

### Domeniul 7 ar fi pornit SĂRIT, deci a primit 12 întrebări

Prima rulare după migrare a arătat prețul tăcut al mutării:

```
  gastronomie_lifestyle 7 (SĂRIT) · 7 (SĂRIT) · 6 (SĂRIT)
```

Cele 20 de întrebări moștenite se împart 7/7/6 pe niveluri, iar `PRAG_DOMENIU` e 8.
Domeniul ar fi existat în `DOMENII`, cu patru rafturi, și n-ar fi apărut niciodată
în luptă — adică migrarea ar fi avut, pe ecran, **efect zero**.

Deci 12 întrebări scrise (4 pe nivel), care au adus domeniul la **11/11/10** și au
umplut și `moda_traditii`, singurul raft rămas gol din el. Acum **șapte domenii din
opt sunt în luptă**, fiecare cu 1/7 din întrebări.

`diverse` rămâne gol, dinadins — ca Divertismentul și Sportul pe 6 octombrie. Un
domeniu declarat devreme e un rând; unul adăugat după ce s-a scris conținut e o
migrare ca cea de azi.

### Două granițe scrise înainte să doară

**`logica_perspicacitate` vs Obeliscul Logică.** Punctul 8 din taxonomie cerea
„șiruri logice, deducții” — exact ce GENEREAZĂ Obeliscul Logică. Fără o graniță,
aceeași întrebare ar putea veni din două locuri, iar una din ele ar fi o copie
proastă a celeilalte (patru butoane în loc de un șir de completat).

Granița, scrisă în `trivia.gd` și în plan: aici intră **fapte despre logică** —
cum se numește paradoxul mincinosului, ce e un silogism, care e ghicitoarea
Sfinxului. **Dacă o întrebare se poate rezolva gândind, fără s-o fi auzit, ea
aparține Obeliscului.**

**`diverse` vs restul.** Un domeniu numit „diverse” e, prin construcție, ispita de
a pune acolo ce nu știi unde să pui — exact greșeala pentru care a murit
`alte_sporturi`, repetată la scară de domeniu. Deci are o regulă în plus, mai
strictă: **o întrebare intră aici numai dacă NU încape în niciunul din primele
șapte.** Dacă încape și acolo și aici, merge acolo.

Și `pop_culture`, al treilea raft cu risc: un fenomen viral se stinge, iar o
întrebare despre el îmbătrânește mai repede decât orice altceva din joc. Acolo
intră numai ce are **dată și urmă**.

### Antetele, și o cifră de ținut sub ochi

```
GEOGRAFIE ȘI EXPLORARE · ISTORIE ȘI SOCIETATE · ȘTIINȚĂ ȘI TEHNOLOGIE ·
ARTĂ ȘI LITERATURĂ · DIVERTISMENT ȘI MEDIA · SPORT ȘI JOCURI ·
GASTRONOMIE ȘI LIFESTYLE · DIVERSE ȘI CURIOZITĂȚI
```

Diacriticele trec prin `to_upper()`, ca și înainte. Dar **cel mai lung antet a
crescut de la 19 la 24 de caractere** („GASTRONOMIE ȘI LIFESTYLE”), iar antetul a
mai dat o dată peste margine — sesiunea ARENA SE LINIȘTEȘTE, 28 septembrie, „antetul
nu se mai revarsă peste întrebare”. Reparația de atunci ținea pentru 19. **De
văzut cu ochiul, într-o luptă.** Nicio verificare headless nu poate spune dacă un
text încape pe un buton.

De-aia numele punctului 8 a rămas „Diverse și curiozități” (22 de caractere) și nu
„Limbaj, logică și curiozități” (29): detaliul stă în subcategorii, care nu ajung
în antet.

### Grila de azi

```
                              nivelul I      nivelul II     nivelul III
  geografie                   47 (+39)       128 (+120)     100 (+92)
  istorie                     18 (+10)        18 (+10)       18 (+10)
  stiinta_tehnologie          47 (+39)        60 (+52)       56 (+48)
  arta_literatura             50 (+42)        80 (+72)       93 (+85)
  divertisment                43 (+35)        43 (+35)       43 (+35)
  sport_jocuri                50 (+42)        50 (+42)       51 (+43)
  gastronomie_lifestyle       11 (+3)         11 (+3)        10 (+2)
  diverse                      0 (SĂRIT)       0 (SĂRIT)      0 (SĂRIT)
  (1027 întrebări în joc: 477 de mână + 550 fabricate)

  subcategorii goale: geografie 3/4 · istorie 2/4 · stiinta_tehnologie 3/4
                      arta_literatura 3/4 · divertisment 1/4 · sport_jocuri 0/4
                      gastronomie_lifestyle 0/4 · diverse 3/3
```

14 rafturi din 31 sunt goale. Nu e o datorie ascunsă — e harta de lucru, tipărită
la fiecare rulare.

### Verificat

- `verifica_trivia`, headless: **toate 10 secțiunile OK**, 1027 încărcate din 1027
  găsite. Cod de ieșire 0.
- Zero perechi (domeniu, subcategorie) nevalide, pe toate cele 1027.
- Echilibrul pe **șapte** domenii, 6000 de trageri pe nivel: abatere maximă 4,9% /
  2,8% / 5,0%, cu limita la 20%. Ținta a scăzut de la 1000 la ~857.
- Sacul: 21 de chei (7 domenii × 3 niveluri) fără nicio repetiție pe un ciclu.
- Migrarea: 195 de linii `categorie`, 330 `subcategorie`, zero nepotriviri.
- Fabrica, toate trei tabelele regenerate, 550 de întrebări cu cheile noi.
- `da_iduri.py --scrie`: 12 id-uri noi (`mana:0466`…`mana:0477`).

### Ce NU s-a făcut

- **`diverse` e gol.** 24 de întrebări (8 pe nivel) l-ar deschide.
- **14 subcategorii din 31 sunt goale**, inclusiv `pop_culture`,
  `lideri_personalitati`, `astronomie_spatiu`, `arte_vizuale` — toate cu tabele de
  fabrică propuse în plan și niciunul scris.
- **Antetul de 24 de caractere n-a fost văzut în joc.**
- **Cele 135 de întrebări vechi n-au subcategorie.** Acum sunt împrăștiate pe
  patru domenii (63 artă, 24 geografie, 24 istorie, 24 știință), iar lotul de
  clasificare le-ar pune pe 16 rafturi din cele noi.
- **999 din 1027 au `verificat: false`.**

### Ce urmează, concret

1. **O luptă, ca să se vadă antetul de 24 de caractere.** Singurul lucru din
   sesiunea asta pe care nicio verificare nu-l atinge.
2. **`diverse`, 8 pe nivel** — deschide al optulea domeniu.
3. **Lotul de clasificare** pentru cele 135, acum cu 31 de rafturi în loc de 36.
4. Primul tabel de fabrică din cele propuse: `arte_vizuale` (tablou → pictor,
   `P170`), fiindcă **aduce imagine cu el** și ar umple „Află mai multe”.

### Fișiere

Atinse: `scenes/trivia/trivia.gd` (`DOMENII`, `SUBCATEGORII`),
`tools/fabrica/comun.py` (oglinda lor), `tools/fabrica/elemente.py`, `opere.py`,
`capitale.py` (`DOMENIU`, `SUBCATEGORIE`), `data/intrebari_trivia.json` (525 de
linii de raft + 12 întrebări noi), `data/trivia_gen/*_intrebari.json`
(regenerate), `tools/da_iduri.py` (`CATE_INTREBARI` 477),
`tools/verificari/verifica_trivia.gd` (`CATE_INTREBARI_MANA` 477),
`docs/ghid-note.md` (tabelul domeniilor), `docs/plan-continut.md` (secțiunea 3
rescrisă), `CLAUDE.md`, `docs/progres.md`.

---

## 50 PE CELULĂ (7 octombrie 2026) — Divertisment și Sport ajung la CONFORT

252 de întrebări noi, 42 pe fiecare din cele șase celule. Cele două domenii
deschise ieri la **prag** (8) sunt acum la **50** pe fiecare nivel — adică peste
treapta CONFORT din `docs/plan-continut.md`, prima din grilă care o atinge.

| | nivel I | nivel II | nivel III |
|---|---|---|---|
| divertisment | 50 (+42) | 50 (+42) | 50 (+42) |
| sport_timp_liber | 50 (+42) | 50 (+42) | 50 (+42) |

**1015 întrebări în joc**, de la 763.

### Subdomeniile se pot filtra, și n-a fost nevoie de nimic nou

Cerința era „etichete după subdomeniu, ca să pot selecta doar capitalele la
geografie”. Mecanismul exista: câmpul `subcategorie`, pus pe 6 octombrie, cu listă
închisă pe domeniu. Lotul de azi doar îl umple — și acum fiecare raft are destul
ca selecția să însemne ceva:

```
  DIVERTISMENT              I   II  III     SPORT                 I   II  III
    filme                  16   16   16       alte_sporturi      10   10   11
    muzica                 11   12   13       fotbal             10   10   10
    seriale                 9    9    9       olimpiade          10   10   10
    jocuri_video            7    7    7       reguli_de_joc       7    7    7
    animatie                7    6    5       gastronomie         7    7    6
                                              hobby_uri           6    6    6
```

Niciun raft sub 5. La `PRAG_DOMENIU = 8`, dacă vreodată pragul s-ar aplica și pe
subcategorie (nu se aplică azi, și nu e nevoie), ar trece 8 din 11.

### Ce NU au: fapt și notă

Niciuna din cele 252 n-are `fapt`, deci n-are notă. A fost o alegere, nu o
scăpare, și merită scris motivul:

> 252 de note ar fi fost ~750 de afirmații verificabile scrise de mine la volum.
> Regula din `CLAUDE.md` e că modelul **formulează, nu informează** — iar la
> volumul ăsta, scrierea notelor e exact locul unde ar informa.

Întrebarea în sine e deja o afirmație, dar e **o singură afirmație pe un rând**,
exact ce se verifică dintr-o privire. O notă adaugă trei, pe un rând pe care nu-l
citești decât în Practice. Notele se pot pune pe urmă, pe cele care merită.

Precedent: cele 135 de întrebări scrise la început n-au nici ele fapt — numai cele
18 din pilot au primit.

### Verificările au prins două lucruri, înainte de scriere

Scriptul de lot verifică tot ce se poate verifica mecanic: text unic față de tot
fișierul, patru variante distincte, răspunsul care nu apare în textul întrebării
(oglinda verificării din `verifica_trivia.gd`), subcategorie validă pe domeniul
ei, și lista de cuvinte interzise de regula „numai trecut”.

A oprit lotul de nivelul III pentru:

```
! răspunsul 'Roquefort' apare în text: 'Ce brânză franceză cu mucegai albastru
  se maturează în peșterile din Roquefort?'
```

Întrebarea se răspundea singură. Rescrisă: „…se maturează în peșteri de calcar,
din lapte de oaie?”.

Și una pe care am tăiat-o eu, nu scriptul: decatlonul olimpic din 1976. Sportiva
și-a schimbat numele mai târziu, iar o întrebare care cere numele de atunci cere o
grijă pe care n-o pot da la volum. Regula „doar cariera publică” nu rezolvă
problema numelui, deci întrebarea a ieșit. **Când o regulă nu acoperă un caz,
cazul iese — nu regula se întinde.**

### Verificat

- `verifica_trivia`, headless: **toate 10 secțiunile OK**, 1015 încărcate din 1015
  găsite. Cod de ieșire 0.
- **1015 texte distincte** și **niciun răspuns în textul întrebării lui**, pe tot
  conținutul — nu doar pe lotul nou.
- `da_iduri.py --scrie`: 252 de id-uri noi (`mana:0214`…`mana:0465`), toate unice.
- Cele șase celule au exact 50. Toate cele 11 subcategorii ale celor două domenii
  au conținut pe toate trei nivelurile.

### Ce NU s-a făcut

- **987 din 1015 au `verificat: false`.** Dintre cele scrise de mână, 437 din 465.
- **Nicio notă** pentru cele 252.
- **Nicio partidă jucată.** Cultura generală are acum șase domenii pline-pline;
  cum se simte e singura cifră care nu se poate calcula.
- Cele 135 de întrebări vechi n-au subcategorie (clichetul le numără).

### Ce urmează, concret

1. **O expediție jucată.** Cu 50 pe celulă la patru din șase domenii, sacul nu mai
   repetă nimic într-o expediție lungă, nicăieri.
2. **Cuvinte are 20 pe nivel** — acum e cel mai subțire Obelisc din joc, cu mult.
   La Cuvinte, cele 20 sunt și întrebările, și distractorii.
3. Lotul de clasificare pentru cele 135 fără subcategorie.
4. Istoria la 50 pe nivel, ca celelalte (acum 18).

### Fișiere

Atinse: `data/intrebari_trivia.json` (+252 de întrebări, 4390 de linii),
`tools/da_iduri.py` (`CATE_INTREBARI` 465),
`tools/verificari/verifica_trivia.gd` (`CATE_INTREBARI_MANA` 465),
`docs/progres.md`.

---

## `tools/` CURAT (7 octombrie 2026) — un dosar pentru verificări, două fișiere șterse

Continuarea simplificării, dar cu o concluzie pe jumătate diferită de ce părea la
prima vedere: **din cele 30 de fișiere din `tools/`, niciunul nu era inutil.**
Problema nu era ce conțineau, era unde stăteau.

### Ce părea de șters și nu era

Zece verificări, fiecare cu trei fișiere (`.gd`, `.gd.uid`, `.tscn`), adunau 30 de
intrări într-un dosar cu patru lucruri folositoare. Arăta ca gunoi.

Nu era. Au fost rulate toate, înainte să ating ceva:

| scenă | rezultat |
|---|---|
| `verifica_trivia` | 29 de verdicte OK |
| `verifica_harta` | 28 OK |
| `verifica_plansa` | 26 OK |
| `verifica_eveniment` | 22 OK |
| `verifica_tipuri` | 9 OK |
| `verifica_drumuri` | 4 OK |
| `verifica_coltul` | merge, dar tipărește MĂSURĂTORI, nu verdicte — se citește, nu se bifează (~2 min) |
| `verifica_cifru` | trece, în **596 de secunde**: rezolvă fiecare lacăt generat ca un om. Încheie cu „VERDICT: cifrurile ies bine”, nu cu „OK” |

Toate bat sisteme care sunt **încă în joc**: generatorul de hărți, rețeta tipurilor
de nod, garanția că o expediție nu se înfundă, generatorul de lacăte cu
dificultatea măsurată. A șterge una înseamnă a șterge o verificare, nu a face
curat. Deci au fost **mutate**, nu tăiate: `tools/verificari/`.

Acum `tools/` are trei intrări: `da_iduri.py`, `fabrica/`, `verificari/`.

**Mutarea n-a fost un `git mv` și gata.** Scenele trimit la scriptul lor prin
CALE (`res://tools/verifica_tipuri.gd`), nu prin uid, deci fiecare `.tscn` a
trebuit rescris. Și 22 de comentarii din joc trimit la verificări („socoteala e în
`tools/verifica_harta.gd`”) — alea sunt chiar ce face comentariile folositoare, deci
s-au rescris și ele. Plus 56 de căi din `progres.md`: o cale moartă într-un jurnal
e mai rea decât una actualizată.

Dovada că nu s-a rupt nimic: toate opt rulate din locul nou, aceleași verdicte.

### Două lucruri care erau, într-adevăr, de șters

`tools/fabrica/date/opere_propuse.json` (110 KB) și `tari_propuse.json` (8 KB) sunt
ieșirile lui `--propune`: liste de candidați din care aleg de mână ce intră în
tabel. Căutat cine le citește: **nimeni.** Apar numai la scriere, în `opere.py` și
`capitale.py`.

Erau comise în Git, deci 118 KB care se schimbau la fiecare rulare și pe care nu-i
citea nimic. Au ieșit din Git și au intrat în `.gitignore`. Probat că ștergerea nu
pierde nimic: `python tools/fabrica/capitale.py --propune` a refăcut fișierul,
octet cu octet aceeași mărime, din cache — deci fără rețea.

**Despărțirea care merita numită:** `tools/fabrica/date/` ține acum numai
**INTRĂRI** — `elemente.json`, `opere.json`, `tari.json`, `autori.json`, toate
scrise de mână, toate citite de fabrică. Ieșirile n-au ce căuta lângă ele, nici în
dosar, nici în Git. Cache-ul (`tools/fabrica/cache/`) rămâne comis, și e altceva:
el ÎNGHEAȚĂ o sursă vie, deci e o garanție de reproductibilitate, nu o ieșire.

### Lecția, dacă e una

Primul impuls la „dosarul e plin” e să ștergi. Dar un fișier de test arată exact
ca unul mort: nu-l deschizi niciodată, nu-l cheamă nimic din joc, și nu se vede
dacă e verde sau roșu până nu-l rulezi. **Diferența se află rulându-l, nu
privindu-l** — iar cele patru minute de rulat au salvat suita de regresie a
proiectului.

Al doilea criteriu, care a și decis cele două ștergeri: **cine citește fișierul?**
Nimeni → regenerabil → afară. `*_propuse.json` au picat la întrebarea asta;
verificările au trecut-o, fiindcă pe ele le citesc eu, la fiecare schimbare care
atinge harta sau conținutul.

### Verificat

- Toate cele 8 verificări headless, rulate din `tools/verificari/`: aceleași
  verdicte ca înainte de mutare, cod de ieșire 0.
- Nicio cale veche rămasă: `grep -rn "tools/verifica_"` nu mai întoarce nimic în
  afară de cache-ul editorului Godot, care se reface singur.
- `--propune` reface `tari_propuse.json` din cache, fără rețea.

### Fișiere

Mutate: toate cele 30 de fișiere `verifica_*` → `tools/verificari/`.
Șterse din Git: `tools/fabrica/date/opere_propuse.json`, `tari_propuse.json`.
Atinse: cele 19 fișiere mutate (căile din ele), `autoload/expeditie.gd`,
`scenes/cifru/generator_cifru.gd`, `scenes/harta/harta.gd`, `panza.gd`,
`plansa.gd`, `scenes/lupta/asezare_coloana.gd`, `umbra_contact.gd`,
`scenes/trivia/trivia.gd`, `tools/fabrica/comun.py` (toate, numai căi în
comentarii), `.gitignore`, `CLAUDE.md` (tabelul verificărilor),
`docs/progres.md`, `docs/plan-continut.md`.

---

## UN SINGUR FLAG (7 octombrie 2026) — mașinăria de verificare s-a desfăcut

**Zi de ȘTERS, nu de adăugat.** În două zile construisem un aparat de verificare
mai complicat decât conținutul pe care-l verifica: un câmp `ciorna` care ținea
întrebările afară din joc, un al doilea `verificat` pe fapt, cu `surse` și o listă
de afirmații de bifat, un câmp `wikidata`, și două unelte cu parametri
(`--confirma=tot`, `--verifica=…`, `--sursa=…`, `--domeniu=`, `--nivel=`).

Verdictul, de la cine o folosea: *„sunt prea multe variabile, parametri etc, prea
multe scripturi atunci când trebuie să verific întrebări.”* Corect, și merită
numit ce s-a întâmplat: am optimizat **ceremonia** verificării, nu verificarea.
Munca adevărată — a citi o notă și a căuta trei afirmații într-o sursă — n-a
devenit mai ușoară cu niciun parametru.

### Ce e acum

Fiecare întrebare din `data/intrebari_trivia.json` are un câmp:

```json
{
	"id": "mana:0001",
	"verificat": false,
	"fapt": "zidul_berlinului",
	"text": "În ce an a căzut Zidul Berlinului?",
	…
}
```

- **Întrebarea intră în joc oricum.** Flagul nu decide nimic în luptă.
- Când citesc nota și o găsesc corectă, scriu `true`. **De mână, în JSON.**
- Nimic altceva. Niciun script, niciun parametru, niciun al doilea flag.

Faptele au rămas cu **`nota` și `etichete`**. Au ieșit `verificat`, `surse`,
`de_verificat` și `wikidata`.

### Ce s-a șters

| ce | de ce |
|---|---|
| câmpul `ciorna` | ținea 48 de întrebări afară din joc. O întrebare necitită e tot o întrebare bună în majoritatea cazurilor; una ținută afară nu se joacă niciodată |
| `verificat` + `surse` pe fapt | al doilea flag pentru același lucru. Cel care rămâne stă pe întrebare, fiindcă acolo îl cauți când citești |
| `de_verificat` pe fapt | 92 de liste de afirmații. Erau un ajutor real la citit, dar încă un câmp de ținut minte |
| `wikidata` pe fapt | n-avea cine să-l mai folosească după ce a plecat unealta de sprijin |
| `tools/arata_ciornele.py` | 600 de linii, nouă opriri, cinci parametri — toate pentru un mecanism care nu mai există |
| `tools/sprijin_verificare.py` | aducea declarațiile de la Wikidata lângă notă. Chiar folositoare, și totuși: „prea multe scripturi” |
| `CATE_CU_NOTA`, `CATE_CIORNE` din verificator | două cifre de ținut la zi |

Niciuna din cele două unelte nu fusese comisă, deci sunt **definitiv duse**. Scris
aici ca să existe urma: dacă într-o zi verificarea notelor devine iar munca
principală, `sprijin_verificare.py` merită rescris — aducea declarațiile de la
Wikidata cu anii î.Hr. și calendarul iulian corectate, iar cele două lecții din el
sunt în sesiunea de deasupra.

### Cifra care a dovedit că aparatul era de prisos

`CATE_CU_NOTA` a trebuit schimbată de **patru ori în treizeci și șase de ore**:
18 → 28 → 38 → 48. De fiecare dată fiindcă urca la un lot confirmat, și de fiecare
dată am pus cifra pe care mi-o cerea verificarea.

**O verificare pe care o actualizezi mecanic, fără s-o mai citești, nu verifică
nimic** — a devenit o formalitate care îmi cerea o editare. A fost înlocuită cu o
cifră TIPĂRITĂ, fără verdict („întrebări cu nota citită: 28 din 763”), fiindcă nu
există nicio invariantă de cerut acolo: faptele fabricate au nota goală dinadins,
iar numărul celor citite crește pe măsură ce citesc.

Aceeași regulă a scos și verdictul de la secțiunea NOTELE. Ce a rămas acolo sunt
invariante adevărate, care nu se schimbă niciodată: nicio notă peste limită,
niciun fapt cu notă pe care nu-l cere nicio întrebare.

### Ce a câștigat jocul, nu doar codul

Cele 48 de ciorne de Divertisment și Sport au intrat în joc în clipa în care
`ciorna` a dispărut. Deci:

```
  domenii fără nicio întrebare               niciunul
  nivelul 1, pe domenii   arta_literatura 50 (+42), divertisment 8 (+0),
                          geografie 47 (+39), istorie 18 (+10),
                          sport_timp_liber 8 (+0), stiinta_natura 47 (+39)
```

**Toate șase domeniile sunt în luptă.** Echilibrul, măsurat pe 6000 de trageri pe
nivel, împarte acum la șase: ținta e 1000 în loc de 1500, iar Divertismentul și
Sportul ies cât celelalte (947–1015 la nivelul I, abatere maximă 8,2%).

Asta nu e un câștig al simplificării în sine — conținutul era scris de ieri. Dar
e ce s-ar fi întâmplat oricum, și mecanismul îl ținea pe loc **până găseam timp
pentru o ceremonie**.

### Două lucruri care NU s-au simplificat, dinadins

- **Listele închise de câmpuri au rămas**, și una s-a adăugat: faptele au acum și
  ele una (`CAMPURI_FAPT`). Un câmp scris greșit („verifcat”) ar fi o întrebare
  care se poartă altfel decât crezi, în tăcere. Lista nu e un parametru și nu cere
  nimic de la mine — doar refuză și spune care câmp.
- **`verificat` lipsă înseamnă `false`.** Așa, cele 550 de întrebări fabricate nu
  poartă câte un „false” degeaba: nimeni nu citește de mână conținut generat, iar
  un câmp pus peste tot e un câmp pe care-l ignori peste tot.

Și una care s-a simplificat fără să fie cerută: ordinea câmpurilor unui fapt era
scrisă de trei ori în fabrică, cu o mică diferență la capitale. A devenit
`comun.ORDINEA_FAPTULUI`, lângă `ORDINEA_INTREBARII`.

### Verificat

- `tools/verificari/verifica_trivia.tscn`, headless: **toate 10 secțiunile OK** (a 11-a,
  CIORNELE, a fost ștearsă), 763 de întrebări încărcate din 763 găsite, 449 de
  fapte. Cod de ieșire 0.
- Migrarea datelor: 213 întrebări au primit flagul, din care **28 au ieșit `true`**
  — cele 27 de fapte pe care le semnaseși, plus o întrebare care împărțea un fapt
  verificat. Nicio semnătură pierdută la mutare.
- Faptele scrise de mână: 92, cu `etichete, id, nota` și nimic altceva (verificat
  pe mulțimea câmpurilor, nu cu ochiul).
- Cele trei fișiere de fapte fabricate, regenerate: `surse` și `verificat` au ieșit
  din toate 357, iar capitalele au păstrat `imagini`.
- Echilibrul pe șase domenii, 6000 de trageri pe nivel: abatere maximă 8,2% /
  3,8% / 2,5%, cu limita la 20%.
- Sacul: 18 chei (6 domenii × 3 niveluri) fără nicio repetiție pe un ciclu întreg.

### Ce NU s-a făcut

- **735 din 763 de întrebări au `verificat: false`.** Din care 550 sunt fabricate,
  deci nu le va citi nimeni de mână; rămân ~185 scrise de mână de citit.
- **Cele 48 noi n-au fost citite de nimeni**, dar se joacă. Ăsta e chiar sensul
  schimbării, nu o datorie ascunsă.
- **Nicio partidă jucată** cu șase domenii.
- **Cele 135 de întrebări vechi n-au subcategorie.** Clichetul din verificator le
  numără.

### Ce urmează, concret

1. **O expediție jucată cu șase domenii.** Prima cifră care nu se poate calcula.
2. **De citit notele, în ritmul propriu.** Deschizi JSON-ul, citești, pui `true`.
   Verificatorul tipărește cât a mai rămas, fără să ceară nimic.
3. Lotul de clasificare pentru cele 135 fără subcategorie.
4. Primul tabel de fabrică din plan: `filme → regizor` (`P57`).

### Fișiere

Șterse: `tools/arata_ciornele.py`, `tools/sprijin_verificare.py`,
`tools/fabrica/cache/wikidata_fapte.json`.
Atinse: `scenes/trivia/trivia.gd` (`ciorne` și `unde_e` scoase, `CAMPURI_FAPT`
adăugat, `verificat` numărat, `_incarca_fapte` simplificat),
`tools/verificari/verifica_trivia.gd` (secțiunea 11 ștearsă, două constante scoase, două
verdicte devenite cifre), `data/intrebari_trivia.json` (flagul pe toate 213,
`ciorna` scos de pe 48), `data/fapte_trivia.json` (patru câmpuri scoase din 92),
`data/trivia_gen/*_fapte.json` (regenerate), `tools/fabrica/comun.py`
(`ORDINEA_FAPTULUI`), cele trei tabele, `CLAUDE.md`, `docs/ghid-note.md`,
`docs/plan-continut.md`, `.gitignore`, `docs/progres.md`.

---

## ȘASE DOMENII ÎN LUPTĂ (7 octombrie 2026) — 48 de ciorne care deschid două domenii

Ziua în care conținutul a ajuns din urmă mecanismul de ieri. Trei lucruri, în
ordinea în care au fost făcute: cele două note găsite greșite s-au reparat, cele
15 fapte din pilot au intrat în fluxul de verificare, iar Divertismentul și
Sportul au primit lotul de deschidere — **8 întrebări pe fiecare celulă, exact
pragul**.

### 1. Cele două note greșite, și o semnătură retrasă

`sprijin_verificare.py` le găsise ieri. Reparate:

| fapt | înainte | acum |
|---|---|---|
| `edirne` | capitală „din 1363”, „înaintea lui fusese Bursa” | „din 1365 până în 1453”, fără claim-ul despre Bursa |
| `zidul_lui_hadrian` | „aproape 120 de kilometri” | „pe 117 kilometri” |

La `edirne` a ieșit și o a doua corectură, pe care n-o ceruse nimeni: `P36` al
Imperiului Otoman arată **Didymoteicho între Bursa și Edirne** (1361–1363), deci
„înaintea lui fusese Bursa” era mai încurcat decât spunea nota. Claim-ul a ieșit
cu totul. Nu e o pierdere: o notă cu trei afirmații din care una e „aproape
adevărată” e mai rea decât una cu două afirmații sigure.

**Amândouă au pierdut `verificat: true` și sursa.** Fuseseră semnate, iar textul
pe care îl acopereau s-a schimbat. O semnătură care supraviețuiește rescrierii
textului nu mai înseamnă nimic — e chiar motivul pentru care `de_verificat` stă
lângă `verificat`. Se re-semnează după recitire.

### 2. Cele 15 fapte din pilot intră în flux

Erau în joc din 27 septembrie, cu note neverificate, fără `de_verificat` și fără
`wikidata` — deci nici unealta nouă nu le putea ajuta. Acum le au pe amândouă.

**Listele nu s-au scris acum: existau deja**, în `docs/ghid-note.md` §5, sub
fiecare notă a pilotului („De verificat: …”). Scriptul le-a MUTAT în date. Ăsta e
și argumentul pentru care câmpul merita să existe: informația era scrisă de două
săptămâni, într-un document, deci invizibilă pentru orice unealtă.

QID-urile, toate 15, căutate. Unde faptul vorbește despre două-trei entități,
câmpul le ține pe toate: `michelangelo` are omul, „David” și Capela Sixtină;
`impresionism` are curentul și tabloul; `constantinopol` are împăratul și orașul.

A ieșit și o proprietate lipsă: `aur` semnala „79” ca neregăsit, fiindcă `P1086`
(numărul atomic) nu era în lista uneltei. Trei rânduri în plus — `P1086`, `P246`,
`P274` — și faptul se potrivește singur.

### 3. Lotul de deschidere: Divertisment și Sport, 8 pe celulă

**48 de întrebări, 48 de fapte, 8 pe fiecare din cele 6 celule.** Exact
`PRAG_DOMENIU`, deci în clipa confirmării **jocul trece de la patru domenii la
șase** — prima schimbare din sesiunea DOMENIILE care se va simți jucând.

Cifra 8 n-a fost aleasă ca să fie rotundă. Era argumentul din `plan-continut.md`:
Divertismentul și Sportul nu erau „subțiri”, erau **invizibile**, iar 48 de
întrebări sunt cea mai mare schimbare pe cea mai mică muncă din tot planul.
Geografia până la PLIN are nevoie de mai mult decât toate celelalte la un loc, și
tot nu s-ar observa.

Repartiția pe subcategorii, și de ce contează: **toate cele 11 subcategorii ale
celor două domenii au conținut.** Verificatorul tipărea până ieri „divertisment,
subcategorii goale: 5 din 5”; azi scrie „niciuna din 5”. Rafturile declarate pe
6 octombrie nu mai sunt promisiuni.

| domeniu | nivel I | nivel II | nivel III |
|---|---|---|---|
| divertisment | animație 2, filme 2, jocuri 1, muzică 2, seriale 1 | filme 4, jocuri 1, muzică 2, seriale 1 | animație 1, filme 3, jocuri 1, muzică 2, seriale 1 |
| sport | olimpiade 2, gastronomie 2, fotbal 1, alte 1, reguli 1, hobby 1 | olimpiade 2, fotbal 2, gastronomie 1, alte 1, reguli 1, hobby 1 | olimpiade 2, alte 2, fotbal 1, gastronomie 1, reguli 1, hobby 1 |

Șase întrebări au eticheta `romania`: Nadia, Hagi, Năstase, mămăliga, sarmalele,
Phoenix, „4 luni, 3 săptămâni și 2 zile”.

### Regula „numai trecut, cu data spusă”, ținută de un verificator, nu de bunăvoință

Cele două domenii au o regulă pe care celelalte patru nu o au (`ghid-note.md`), și
ea e ușor de încălcat fără să bagi de seamă: „cel mai premiat film”, „actualul
campion”. Scriptul lotului o verifică pe o listă de cuvinte interzise — „actual”,
„în prezent”, „cel mai recent”, „momentan” — peste texte ȘI peste note.

Fiecare din cele 48 poartă un an, un titlu sau o regulă care nu se mișcă: „din
1937”, „în 1994”, „câți jucători are o echipă de baschet”. Niciuna nu poate
îmbătrâni.

**Ce am refuzat să scriu:** orice superlativ („cel mai bun film din istorie”),
viața privată a cuiva, și recordurile care se bat. La nivelul III al ambelor
domenii s-a simțit plafonul pe care îl anunța `plan-continut.md`: regula taie
exact întrebările de cunoscător despre ce se întâmplă acum, deci nivelul III e
făcut din istorie a divertismentului (Cetățeanul Kane, 1941) și palmarese închise
(Schumacher, ultimul titlu în 2004).

### O grafie disputată, prinsă de căutarea QID-urilor

`--cauta` pentru albumul Phoenix a întors **două entități cu două grafii**:
„Cantofabule” (Q12723391) și „Cantafabule – Bestiar” (Q12723384). Întrebarea mea
cerea grafia „Cantafabule” pe un buton.

Un titlu disputat pe un singur buton verde e **aceeași greșeală ca un fapt
disputat** — regula din `CLAUDE.md` care a scos Israelul din tabelul capitalelor.
Deci întrebarea nu mai cere titlul: „Ce formație rock românească a scos în 1975 un
album-bestiar, cu animale fabuloase?”, iar nota spune pe față că apare scris în
ambele feluri.

Căutarea a plătit și la `film_titanic`: Wikidata are `Q25173` (nava) și `Q44578`
(filmul din 1997). Ghicit, aș fi legat nota filmului de pachebot.

### Ce a prins unealta de sprijin pe lotul nou

Prima rulare a arătat o proprietate lipsă mai importantă decât toate celelalte:
**`P577`, data publicării, nu era în listă.** E scrisă în `plan-continut.md` ca
proprietate pentru tabelul de filme, dar nu intrase în unealtă. Opt proprietăți
noi (`P577`, `P495`, `P57`, `P175`, `P166`, `P1346`, `P641`, plus `P619` de ieri)
au dus Divertismentul de la **19 fapte cu cifre neregăsite la 9**.

La sport, patru fapte aveau data pe **altă entitate**: medalia Nadiei stă pe
ediția din 1976, nu pe ea; la fel Phelps, Owens și Hagi. Al doilea QID le-a
rezolvat.

Ce rămâne semnalat, și de ce e în regulă:

| fel | exemple | se poate automatiza? |
|---|---|---|
| reguli și numărători | 11 jucători, 64 de pătrate, 16 piese, 40 de minute | **nu** — Wikidata nu ține regulile unui joc |
| socoteli | „108 ani după 1896” | **nu** — e aritmetică, nu o declarație |
| date pe entități pe care nu le-am legat | 1863 (federația de fotbal), 1889 (pizza Margherita), 1800 (sfecla de zahăr) | da, cu încă un QID — dar nu merită la fiecare |

Niciuna nu oprește nimic: cifrele neregăsite se raportează, cu eticheta lor.
Scriptul spune de fiecare dată „nu e o greșeală: o notă are voie să spună ce
Wikidata nu ține”.

### Grila de azi

```
                              nivelul I              nivelul II             nivelul III
  geografie              47 (+39)               128 (+120)             100 (+92)
  istorie                18 (+10)                18 (+10)               18 (+10)
  stiinta_natura         47 (+39)                60 (+52)               56 (+48)
  arta_literatura        50 (+42)                80 (+72)               93 (+85)
  divertisment            0 (SĂRIT) +8 ciorne     0 (SĂRIT) +8 ciorne    0 (SĂRIT) +8 ciorne
  sport_timp_liber        0 (SĂRIT) +8 ciorne     0 (SĂRIT) +8 ciorne    0 (SĂRIT) +8 ciorne
  (715 în joc + 48 ciorne = 763; 449 fapte, din care 92 scrise de mână)

  subcategorii goale: geografie 6/7 · istorie 0/4 · stiinta_natura 7/8
                      arta_literatura 5/6 · divertisment 0/5 · sport 0/6
```

Istoria e la **18 pe toate trei nivelurile** — prima celulă scrisă de mână care nu
mai stă pe muchia pragului, și singura din grilă cu rezervă pe toată coloana.
Divertismentul și Sportul arată `0 (SĂRIT)` cu 8 ciorne alături: scrise, citibile,
în afara jocului. Cifra din paranteză e singurul lucru care se schimbă la
confirmare, și o schimbă din 0 în 8.

### Verificat

- `tools/verificari/verifica_trivia.tscn`, headless: **toate 11 secțiuni OK**, 715 întrebări
  + 48 ciorne = 763 din 763 găsite, 449 de fapte. Cod de ieșire 0.
- `CATE_INTREBARI_MANA` 213, `CATE_FAPTE` 92, `CATE_CIORNE` 48, `CATE_CU_NOTA` 48.
  Ultima a urcat de la 38 la 48 **prin confirmarea nivelului III al istoriei**, nu
  prin lotul nou — lotul nou n-a clintit-o, fiindcă e ciornă.
- `tools/da_iduri.py --scrie`: 48 de id-uri noi (`mana:0166`…`mana:0213`), toate
  unice, 96 de întrebări cu fapt.
- Lotul, verificat înainte de scriere: texte unice față de toate cele 165
  existente, variante distincte, niciun răspuns în textul întrebării lui,
  subcategorii valide pe domeniul lor, niciun cuvânt interzis, nicio notă peste
  240 de caractere (cea mai lungă: 187).
- `tools/sprijin_verificare.py` pe toate cele 48: 24 + 24 de fapte aduse, zero
  erori de interogare.
- Cele 92 de fapte scrise de mână au acum **toate** `de_verificat` și `wikidata`.

### Ce NU s-a făcut

- **Niciuna din cele 48 de ciorne nu e confirmată.** Deci Divertismentul și
  Sportul sunt tot sărite în luptă. Ăsta e rostul mecanismului, nu o scăpare.
- **65 de fapte din 92 sunt `verificat: false`**, inclusiv cele 48 noi, cele 15 din
  pilot și cele două corectate azi.
- **Nicio partidă jucată** cu conținut nou. Cifra care mă interesează — cum se
  simt șase domenii în loc de patru — nu se poate calcula.
- **Niciun tabel nou de fabrică.** `evenimente_datate` și `filme → regizor` sunt
  proiectate în plan, cu capcanele lor, și nescrise.
- **Cele 135 de întrebări vechi n-au subcategorie.** Clichetul din verificator le
  numără, iar lotul de clasificare nu s-a făcut.
- **Cele 28 de ciorne de opere** au rămas ciorne (al cincilea raport care o spune).

### Ce urmează, concret

1. **De citit cele 48 de ciorne și de confirmat.** Asta deschide două domenii.
   Sprijinul a potrivit deja cifrele la 39 din 48, deci rămâne citirea relațiilor.
2. **O expediție jucată cu șase domenii.** Prima cifră care nu se poate calcula:
   fiecare domeniu ia 1/6 în loc de 1/4, deci Cultura generală se lățește cu o
   treime peste noapte. De simțit, nu de socotit.
3. **Lotul de clasificare** pentru cele 135 de întrebări fără subcategorie.
4. **Primul tabel de fabrică din plan**: `filme → regizor` (`P57`) e cea mai curată
   relație din Divertisment, iar unealta de sprijin are deja proprietățile pentru
   el.

### Fișiere

Atinse: `data/intrebari_trivia.json` (+48 de ciorne, un text rescris),
`data/fapte_trivia.json` (+48 de fapte, `de_verificat` și `wikidata` pe toate
cele 92, două note corectate și de-semnate), `tools/sprijin_verificare.py`
(11 proprietăți noi), `tools/da_iduri.py` (`CATE_INTREBARI` 213),
`tools/verificari/verifica_trivia.gd` (cele patru cifre), `docs/progres.md`.

---

## PLANUL ȘI CIORNELE (6 octombrie 2026) — o hartă a conținutului, un mecanism și primul lot

Trei lucruri care se sprijină unul pe altul: un **plan** care spune ce lipsește și
de unde se ia, un **mecanism** prin care o întrebare scrisă de mână poate exista
fără să fie încă în joc, și **primul lot** scris cu el — 30 de ciorne de istorie,
10 pe nivel.

Sesiunea de dinainte (DOMENIILE) s-a încheiat cu o propoziție care cerea
continuare: *„istoria trece cu rezerva zero, deci e următoarea țintă de
conținut”*. Asta e continuarea.

### 1. `docs/plan-continut.md`: harta

Al treilea document de conținut, și fiecare răspunde la altă întrebare:
`ghid-note.md` spune **în ce domeniu** intră o întrebare și **cum se scrie o
notă**; `plan-continut.md` spune **ce lipsește, de unde se ia și în ce ordine**;
`progres.md` spune **ce s-a făcut**.

Ce conține: subdomeniile fiecărui domeniu (devenite subcategorii — vezi mai jos),
sursa fiecăruia (tabel de fabrică sau scris de mână), iar pentru fiecare tabel
propus **relația din Wikidata și capcanele ei**, scrise înainte să existe
scriptul. Plus ordinea de lucru și ce NU intră.

**Ținta pe celulă a primit două trepte intermediare.** Cea veche („500 unde
domeniul le poartă, 150–250 la nivelul I”) e bună și rămâne, dar are un defect
practic: nu se atinge în luni, deci nu-mi spune niciodată *„celula asta e gata
pentru azi”* — orice celulă sub 500 arată identic în grilă. Deci:

| treaptă | cifră | ce se schimbă în joc |
|---|---|---|
| PRAG | 8 | celula intră în luptă (`PRAG_DOMENIU`) |
| CONFORT | 25 | 4-5 expediții lungi fără nicio repetiție în ea |
| PLIN | 150–250 la I, 500 la II/III | ținta din CONȚINUTUL, neschimbată |

Fiecare treaptă are un **înțeles mecanic**, nu o senzație. Și treapta care
lipsește peste tot e CONFORT, nu PLIN: diferența dintre 8 și 25 e diferența
dintre „domeniul apare” și „domeniul nu se simte subțire”, și se atinge într-o
săptămână de scris.

**Ordinea de lucru nu e după cât lipsește, e după cât se schimbă pe unitate de
muncă scrisă.** Geografia până la PLIN are nevoie de mai mult decât toate
celelalte la un loc, și totuși e ultima. Întâi istoria (rezerva zero, deci
fragilă: o întrebare retrasă scoate domeniul din joc în tăcere), apoi
Divertisment și Sport — care nu sunt „subțiri”, sunt **invizibile**, iar 48 de
întrebări acolo fac jocul să aibă șase domenii în loc de patru.

**Cea mai folositoare pagină din document e lista capcanelor**, fiindcă e scrisă
înainte, nu după. Patru feluri, fiecare cu un exemplu care s-a întâmplat deja sau
era la un pas:

| capcană | exemplu | leacul |
|---|---|---|
| superlativul disputat | „cel mai lung fluviu” (Nil sau Amazon) | caut o DECLARAȚIE care îl spune (`P610`), nu un clasament calculat de mine |
| data incertă | datele antice au precizie de deceniu sau secol | se citește precizia și se refuză tot ce nu e exact pe an |
| faptul care se schimbă | Croația a trecut la euro în 2023 fără ca nimic din fișierul meu să se miște | întrebarea poartă data cu ea, sau faptul nu se ia |
| un câmp lipsă nu e un „NU” | 10 state istorice intrate printre cele 193 membre ONU | orice filtru pe absența unui câmp cere un al doilea semn |

Și două tabele **refuzate scris**, cu motivul: `P61` (inventatorul) — telefonul,
becul, radioul au fiecare două-trei revendicări reale, iar Wikidata le ține pe
toate; și `P47` (vecinii unei țări) — ține și granițe maritime, deci „cu cine se
învecinează Spania?” iese cu Algeria. Un tabel refuzat scris e mai folositor decât
unul nescris: peste trei luni n-am de unde să-mi amintesc de ce n-am făcut ceva.

Capcana cea mai instructivă din tot documentul e la palmarese: **titlurile
retrase.** Lance Armstrong a câștigat Tour de France din 1999 până în 2005 și apoi
nu le-a mai câștigat — palmaresul oficial n-are învingător pentru acei ani, dar
Wikidata poate să țină în continuare declarația. Un tabel care nu se oprește aici
predă **șapte fapte false**.

### 2. `subcategorie`: un câmp, nu o etichetă — și de ce asta a fost decizia zilei

Planul avea nevoie de un nume pentru „capitale” în interiorul geografiei. Prima
formă propusă a fost o **etichetă pe fapt**, lângă `romania`. A fost schimbată, și
motivul e unul despre care merită scris, fiindcă nu e evident:

> În Practice vreau să pot alege „geografie → capitale”. Un meniu care alege are
> nevoie de **cifre corecte** și de garanția că **nicio întrebare nu rămâne pe
> dinafară** — adică de o ÎMPĂRȚIRE, nu de etichete care se suprapun.

Cu etichete, „capitala României” ar fi avut și `capitale`, și `romania`, iar
meniul ar fi avut două răspunsuri la întrebarea „câte întrebări sunt aici?”. Cu un
câmp, o întrebare stă în exact una.

Și despărțirea se ține: **`etichete` rămâne pentru transversale.** `romania` taie
PESTE subcategorii — Posada e `istorie`/`ev_mediu` + etichetă `romania`, Dâmbovița
e `geografie`/`ape` + etichetă `romania`. Dacă `romania` ar fi fost subcategorie,
ar fi trebuit să aleg între „e despre România” și „e despre râuri”.

Se alege după **aceeași regulă ca domeniul**: ce trebuie să ȘTII, nu subiectul.
„Pe ce râu stă Viena?” e `orase`, nu `ape`.

**Lista e completă de la bun început: 36 de chei, din care azi se folosesc 4.**
Același argument pentru care Divertismentul și Sportul au fost scrise goale în
`DOMENII`: o subcategorie scrisă de la început e un rând, una adăugată după ce s-a
scris conținut e o migrare. Prețul e că 32 de rafturi sunt promisiuni — de-aia
verificatorul le **tipărește la fiecare rulare**, pe domeniu. Un raft declarat și
uitat ar sta acolo ani; așa se vede că e gol până îl umplu sau îl șterg.

**La istorie, subcategoriile sunt erele**, tăiate pe dată: antichitate până la
476, Ev Mediu 476–1500, modern 1500–1914, contemporan de la 1914. **Data decide,
nu numele** — dinastia Yuan (1271) e `ev_mediu` deși „Evul Mediu” e o noțiune
europeană. Subcategoria e un RAFT, nu o afirmație despre civilizația aia; altfel
fiecare întrebare despre Asia sau despre America precolumbiană ar cere o decizie
de la mine, și raftul ar fi o părere.

Prețul e scris în document, nu ascuns: **granița de la 1500 taie prin Evul Mediu
românesc** (Neagoe Basarab, 1512–1521, iese `modern`), iar 1914 pune Titanicul
(1912) în epoca modernă. Lotul de azi ocolește amândouă granițele, deci convenția
e scrisă dar încă neîncercată.

### Cele 550 de întrebări fabricate: un diff de 550 de inserări curate

Câmpul nou trebuia să intre și în conținutul fabricat, iar aici a fost o alegere
mică, cu un motiv care nu e estetic. În `ORDINEA_INTREBARII`, `subcategorie` stă
**înaintea** lui `categorie`, nu după.

`categorie` e ultimul câmp al unui obiect, deci singurul fără virgulă. Cu
`subcategorie` după el, linia lui ar fi primit o virgulă, iar regenerarea celor
550 de întrebări ar fi arătat **trei linii schimbate pe întrebare** în loc de una
adăugată — 1650 de linii în care cauți câmpul nou, adică un diff care nu se
citește.

Dovada s-a luat, nu s-a presupus: fișierele regenerate, comparate cu ce ar fi
scris fabrica de ieri (ordinea veche de câmpuri), dau **+550 linii, −0 linii**, și
toate cele 550 sunt `"subcategorie"`:

```
elemente    139 întrebări   +139 linii, -0 linii   adăugiri care nu sunt subcategorie: 0
opere       160 întrebări   +160 linii, -0 linii   adăugiri care nu sunt subcategorie: 0
capitale    251 întrebări   +251 linii, -0 linii   adăugiri care nu sunt subcategorie: 0
```

Și ordinea a ieșit din cele trei scripturi într-o constantă (`comun.ORDINEA_INTREBARII`):
era scrisă identic de trei ori, iar „identic” a devenit „trei locuri de ținut
sincronizate” exact în ziua în care a trebuit să primească un câmp.

Perechea (domeniu, subcategorie) se verifică **o dată, la pornirea fiecărui
tabel** (`comun.verifica_subcategoria`). Fără ea, un `SUBCATEGORIE` scris greșit
ar fi făcut ca `trivia.gd` să refuze toate cele 139 de întrebări ale tabelului —
s-ar fi văzut în bilanț, dar după ce scrisesem fișierul. Probat rupând: `"chimei"`
oprește scriptul, cu lista celor cunoscute.

**Cele 135 scrise de mână n-au primit subcategoria azi.** Clasificarea lor e un
lot separat, ca ciornă, pe care o confirm eu. Până atunci încărcătorul le acceptă,
cu **un rând** de bilanț („135 intrebari fara subcategorie”), nu cu 135 de
avertismente — iar verificatorul are un **clichet**: `MAX_FARA_SUBCATEGORIE = 135`,
verdict „cel mult”, fiindcă cifra numai scade. Nu trebuie atinsă când clasific, și
pică în clipa în care scriu conținut nou fără subcategorie.

### 3. Mecanismul ciornelor

Fabrica avea mecanismul de la al doilea tabel: un rând cu `"ciorna": true` intră
în raportul de probă și nu intră în fișierul scris. Partea scrisă de mână n-avea
echivalent, și asta era o gaură adevărată: **scriam întrebarea direct în joc**,
deci ori o verificam înainte s-o scriu, ori o jucam neverificată. La 30 de
întrebări pe lot, niciuna din cele două nu merge.

De azi, o întrebare din `data/intrebari_trivia.json` cu `"ciorna": true`:

- trece prin **toate** validările (patru variante, `corect` în interval, domeniu
  și subcategorie cunoscute, faptul există) — o ciornă stricată se plânge ACUM, nu
  în ziua în care o confirm;
- își înregistrează `id`-ul, deci nu se poate ciocni cu nimic;
- **își marchează faptul ca folosit** — fără asta, cele 29 de fapte ale lotului ar
  fi dat 29 de avertismente „faptul nu e folosit de nicio întrebare”, și de-acolo
  încolo consola nu mai e un loc unde se citește ceva;
- **nu intră în `intrebari`**, deci nici în luptă, nici în sac, nici în echilibru.

**Invarianta verificatorului s-a mutat, nu s-a slăbit.** Era „încărcate ==
găsite”; e acum „încărcate + ciorne == găsite”. O ciornă nu e o pierdere — e
scrisă, validată și ținută dinadins afară. Fără ea în partea stângă, invarianta ar
fi picat la primul lot și aș fi învățat s-o ignor, care e cel mai rău lucru care i
se poate întâmpla unei verificări. Ce rămâne prins e exact ce trebuie: o întrebare
**stricată** nu e nici în `intrebari`, nici în `ciorne`, deci lipsește din sumă.

### Lista închisă de câmpuri, și câmpul pe care am refuzat să-l adaug

`trivia.gd` n-avea nicio verificare pe câmpuri necunoscute. Acum are, și refuză
întrebarea. Motivul e chiar mecanismul de mai sus: **`"ciorne": true` (cu e) ar fi
o ciornă neconfirmată care intră în joc**, fără ca nimic să spună nimic nicăieri —
cel mai scump fel de greșeală, fiindcă nu se vede nici în cod, nici în date, doar
în luptă. Refuzată, se vede în linia de bilanț. Același argument ca la
`comun.verifica_campurile`, din fabrică; probat rupând: câmpul `ciorne` a scos
`mana:0136` din joc, cu mesajul lui.

Și o alegere care pare o scăpare și nu e: **`retras` NU e în listă**, deși e o
convenție scrisă din sesiunea ID ȘI FAPT („o întrebare scoasă din joc se
marchează `"retras": true` și rămâne pe loc”). Codul care sare peste retrase nu
există încă. Dacă pun câmpul în listă acum, prima întrebare retrasă ar rămâne în
joc în tăcere — exact felul de greșeală pe care lista închisă e pusă să o prindă.
Așa, ziua aia mă oprește și scriu codul de care e nevoie.

### `tools/arata_ciornele.py`

Comanda de citit, și singurul loc unde ciornele se confirmă:

```bash
python tools/arata_ciornele.py                      # toate, de citit
python tools/arata_ciornele.py --domeniu=istorie --nivel=1
python tools/arata_ciornele.py --confirma=mana:0136,mana:0137
python tools/arata_ciornele.py --confirma=tot
```

Cum arată o ciornă:

```
  mana:0136   contemporan
  În ce an s-a încheiat al Doilea Război Mondial?
      1944      1945  ✔      1946      1939
  faptul `al_doilea_razboi_mondial`  ·  verificat: NU  ·  etichete: —
      Al Doilea Război Mondial s-a încheiat în 1945: în mai, în Europa, și în
      septembrie, în Asia, după capitularea Japoniei. Începuse în 1939, cu
      invadarea Poloniei.
      [ ] capitularea Germaniei, mai 1945
      [ ] capitularea Japoniei, septembrie 1945
      [ ] începutul: invadarea Poloniei, 1939
```

Nouă opriri, și fiecare are un motiv, nu e curățenie: ciornă fără `fapt` (nu se
poate verifica), `fapt` inexistent (legătură falsă), notă goală sau peste limită,
`de_verificat` gol („confirmat” n-ar însemna nimic), `subcategorie` lipsă sau
străină domeniului, `verificat: true` cu `surse` gol, câmp necunoscut oriunde,
etichetă în afara vocabularului. **Niciuna nu e avertisment** — un avertisment
într-o unealtă pe care o rulezi ca să CITEȘTI se pierde printre 30 de ciorne
tipărite.

`--confirma=tot` înseamnă **tot ce s-a arătat**, nu tot ce există. Altfel
`--domeniu=istorie --confirma=tot` ar fi confirmat și ce n-am citit, adică exact
surpriza pe care o comandă de confirmare n-are voie s-o facă.

**De ce confirmarea e o comandă, nu o ștergere de mână.** Fiindcă ștergerea unui
rând dintr-un JSON scris de om e exact felul în care s-a pierdut odată câmpul
`nivel` de la „Divina Comedie”: ștergi rândul de deasupra, sau lași o virgulă, sau
o iei pe cea greșită din două obiecte asemănătoare. `--confirma` face chirurgie pe
text, ca `tools/da_iduri.py`, și citește fișierul înapoi ca dovadă. Probat pe
`mana:0136` și `mana:0140`, cu diff față de copia de dinainte:

```
-		"ciorna": true,
-		"ciorna": true,
```

Două linii, nimic altceva.

Și un amănunt mic cu un motiv real: **`ciorna` e al doilea câmp al obiectului, nu
ultimul.** Ultimă, ar fi fost singura linie fără virgulă, și ștergerea ar fi lăsat
o virgulă în aer pe linia dinainte — adică un JSON stricat la fiecare confirmare.
Unealta nu ghicește: dacă linia nu e exact `"ciorna": true,`, se oprește și spune
care e.

### `de_verificat`: lista de bifat devine DATE

Ghidul avea, sub fiecare notă a pilotului, un rând „De verificat: …”. Lista aia s-a
mutat pe fapt, ca listă de șiruri. Motivul:

> **`verificat: true` era un cuvânt de onoare.** Spunea că am verificat, nu CE am
> verificat. O notă cu trei afirmații din care am confirmat două arăta, în date,
> exact ca una verificată întreagă.

Cu lista alături, boolean-ul devine o semnătură pe ceva anume, iar unealta are de
unde s-o tipărească în loc s-o ghicească. Lista **rămâne** după verificare: e
procesul-verbal, nu o listă de cumpărături.

Ce NU face: nu numără afirmațiile din notă și nu le compară cu lista. Regula „cel
mult trei afirmații” rămâne de ochi — un validator care ar încerca să extragă
afirmații dintr-o frază românească ar greși în ambele direcții, iar o verificare
care greșește în ambele direcții e mai rea decât niciuna. Aceeași lecție ca la
„simbolul se deduce din nume?”, din sesiunea FABRICA.

Confirmarea întrebării și verificarea faptului rămân **două lucruri separate**:
`--confirma` zice „întrebarea e bună”, `verificat` zice „nota e de încredere”. Ce
face Practice cu `verificat: false` e tot decizia amânată din `ghid-note.md` §7.

### `--verifica`: a doua confirmare, adăugată tot pe 6 octombrie

`verificat: true` se punea de mână. Merge la 10 fapte și nu mai merge la 100, deci
a primit și ea comandă — dar **separată**, nu un al doilea efect al lui
`--confirma`:

```bash
python tools/arata_ciornele.py --verifica=tot --sursa="manual istorie cls. X"
python tools/arata_ciornele.py --verifica=mana:0136,pompei --sursa="…"
```

Despărțirea e tot argumentul de mai sus, privit din partea practică: o întrebare
poate fi perfect corectă cu o notă în care un an e greșit. Cu o singură comandă
n-ai mai putea spune „întrebarea intră în joc, dar nota mai are nevoie de o
căutare” — iar ăsta e **cazul obișnuit**, nu excepția.

Trei alegeri, fiecare venită din felul în care s-a folosit comanda în prima oră:

- **Ia și `id`-uri de ÎNTREBARE, nu doar de fapt.** Le citești pe întrebări, deci
  în cap ai `mana:0136`, nu `al_doilea_razboi_mondial`. Un `id` cu „:” e o
  întrebare și se traduce în faptul ei. Despărțirea e sigură fiindcă id-urile de
  fapt n-au „:” niciodată.
- **Merge pe orice fapt, nu doar pe cele ale ciornelor.** Imediat după ce am
  confirmat primele 10 întrebări, faptele lor nu mai erau ciorne — dar notele lor
  aveau nevoie de exact aceeași verificare. O comandă care ar fi mers numai pe
  ciorne ar fi fost inutilă chiar în clipa în care era nevoie de ea.
- **`--sursa` e obligatorie.** Regula „nu poți fi verificat fără să spui de unde”
  era ținută doar la CITIRE (`verificat: true` cu `surse` gol oprea unealta). Acum
  e ținută și la SCRIERE, deci nu mai există niciun drum prin care un fapt devine
  verificat fără sursă.

Un fapt deja verificat e **sărit**, nu o eroare — aceeași purtare ca `da_iduri.py`,
care lasă în pace un obiect ce are deja `id`. Altfel a doua rulare ar fi adăugat
sursa de două ori.

Chirurgia pe text a cerut grijă la un amănunt care ar fi stricat exact jumătate
din fapte: `"verificat": false` e **ultimul** câmp la faptele fără etichete și
**penultimul** la cele cu `etichete`. Rescrisă fără păstrarea virgulei, linia ar fi
dat JSON stricat la jumătate din fapte și bun la cealaltă jumătate — adică o
greșeală care trece o dată și cade a doua oară. `rescrie_campul` păstrează virgula
dacă era; probat pe `vlad_tepes` și `carol_i`, care au etichete.

Probat, pe date pe care le-am dat apoi înapoi: fără `--sursa` oprește; `--sursa`
singur oprește; un `id` de întrebare confirmată și unul de fapt, amestecate,
merg; a doua rulare sare peste cele deja verificate; `mana:9999` și un fapt
inexistent opresc; `--verifica=tot` pe nivelul II a prins și `revolutia_franceza`,
faptul împărțit cu nivelul I. Diff-ul pe disc: **două linii pe fapt**, `surse` și
`verificat`.

### `tools/sprijin_verificare.py`: mașina aduce sursa, omul judecă relațiile

Verificarea unei note cerea un browser pentru fiecare afirmație din
`de_verificat`. La 20 de ciorne și 60 de afirmații, aia e o seară. Unealta nouă
aduce declarațiile de la Wikidata și le pune **lângă** notă.

Ce NU face, și de ce merită scris mai apăsat decât ce face: **nu dă verdicte.**
Motivul e greșeala găsită cu ochiul la `mana:0150`, în aceeași zi:

> Nota spunea că armata lui Alexandru a refuzat să înainteze „la Indus”. **Anul
> era corect** — 326 î.Hr., exact. Răzvrătirea fusese la râul Hyphasis, mai la
> est. Orice verificare automată de date și cifre ar fi dat verde.

Notele sunt făcute din RELAȚII („cine pe cine”, „unde anume”), iar
`docs/ghid-note.md` §4 le pune separat de cifre, la punctul 2. Un script care ar
încerca să le judece ar greși în ambele direcții — aceeași lecție ca la „simbolul
se deduce din numele românesc?”, din sesiunea FABRICA. Deci:

    mașina ADUCE sursa și prinde cifrele
    omul   JUDECĂ relațiile

Faptele au primit un câmp `wikidata`, **listă** de QID-uri, din același motiv ca
`imagini`: un fapt poate vorbi despre două entități. Anii răscoalei lui Spartacus
nu stau pe om, stau pe răscoală; perioada în care Edirne a fost capitală stă pe
Imperiul Otoman, nu pe oraș.

**QID-urile nu s-au ghicit.** Toate 29 s-au căutat cu `--cauta`, iar unealta
tipărește la fiecare rulare eticheta și descrierea entității — deci un QID greșit
nu poate trece neobservat. Căutarea a și plătit imediat: pentru `pompei`,
Wikidata are și `Q36471` (comuna modernă) și `Q43332` (orașul roman). Ghicit, aș
fi luat prima.

### Trei capcane pe care unealta le-a scos la lumină în prima oră

Niciuna presupusă; toate măsurate pe datele venite. Și două din trei erau pe
punctul să mă trimită să „corectez” note corecte — adică o unealtă de verificare
gata să strice exact ce verifica.

**1. Calendarul iulian.** Prima dată adusă, la Hastings: `P585 = 1066-10-20`, iar
nota și toată lumea spun 14 octombrie. Valorile vin de la Wikidata **normalizate
în gregorian proleptic**, iar modelul de calendar al declarației e iulian. Șase
zile — exact decalajul secolului XI. Unealta tipărește acum modelul și
**convertește**: conversia e o socoteală (prin numărul zilei iuliene), nu o
judecată, deci are ce căuta într-un script. Probată pe trei cazuri cu răspuns
cunoscut: 1066-10-20 → 14 oct. 1066; 1917-11-07 → 25 oct. 1917; 1582-10-15 →
5 oct. 1582.

**2. Anii î.Hr., greșiți cu exact un an — un bug al meu.** Wikidata folosește
numerotarea **astronomică**, în care anul 0 există și ESTE anul 1 î.Hr. Deci
`-0062` e 63 î.Hr., nu 62. Prins fiindcă trei entități își spun datele în propria
descriere, iar raportul meu le contrazicea pe toate trei cu exact un an: Augustus
(descrierea zice 63 î.Hr., valoarea `-0062`), Alexandru cel Mare (356–323,
valorile `-0355`/`-0322`), Iulius Cezar (100–44, valoarea de rang preferat
`-0099`). După reparație, `spartacus` și `augustus` s-au potrivit singure.

**3. Perioadele stau în CALIFICATORI, nu în declarații.** „Iustinian a domnit
527–565” nu e pe persoană, e pe declarația `P39` (funcția deținută), ca
`pq:P580`/`pq:P582`. La fel „Edirne, capitală 1363–1453”, pe `P36` al Imperiului
Otoman. Fără ele, raportul semnala cifrele ca neregăsite la **tiparul cel mai des
din tot domeniul istoriei**. Lista proprietăților „cu perioadă” e un dicționar de
două rânduri, ca a treia să nu fie o ramură nouă.

### Și o a patra, despre raport: un „OK” care liniștește degeaba

Prima versiune a verificării de cifre întorcea `True`/`False`. A mințit la prima
ocazie: nota de la Edirne scrie „capitală din 1363”, iar „1363” s-a regăsit — în
rândul **altui oraș** (Didymoteicho, capitală 1361–1363). Raportul a scris „cifre
regăsite: 1363”.

Deci se întoarce acum **rândul în care s-a găsit**, și se tipărește:

```
    regăsit          1363  ←  capitala: Didymoteicho  (Q932648)   (de la 1361, până în 1363)
    regăsit          1453  ←  capitala: Edirne  (Q43387)   (de la 1365, până în 1453)
```

Aceeași idee ca `de_verificat` lângă `verificat: true`: o afirmație se vede cu
dovada alături, nu pe cuvânt. Iar potrivirea rămâne **dinadins slabă** (pe text,
ca „1066” să se găsească în „1066-10-20”), fiindcă un comparator mai strict ar fi
cerut să știu dinainte ce fel de valoare e fiecare cifră din notă — adică exact
judecata pe care scriptul n-o face.

Cifrele neregăsite se **raportează, nu opresc**: o notă are voie să spună ce
Wikidata nu ține („un zbor de 108 minute”, „cincisprezece state”). O verificare
care, prin construcție, greșește într-o singură direcție — semnalează prea mult,
niciodată prea puțin — n-are voie să oprească; altfel o pornești o dată și o
abandonezi.

### Ce a găsit, pe cele 10 ciorne de nivelul III

Opt din zece și-au potrivit toate cifrele singure, cu dovada alături. Două n-au,
și amândouă sunt **note de-ale mele de corectat**, nu scăpări ale uneltei:

| fapt | nota mea | ce spune sursa |
|---|---|---|
| `edirne` | capitală „din 1363” | `P36` al Imperiului Otoman: **de la 1365** (1363 e în rândul altui oraș) |
| `zidul_lui_hadrian` | „aproape 120 de kilometri” | `P2043`: **117,5 km** |

Prima e o confuzie reală: 1363 e anul cuceririi Adrianopolului, 1365 e mutarea
capitalei. Nota le amestecă. A doua e rotunjirea mea, și e o decizie, nu o
greșeală — dar e o decizie care trebuie luată, nu lăsată.

### Primul lot confirmat: nivelurile I și II ale istoriei

Cele 20 de ciorne de nivelurile I și II au fost citite și confirmate
(`mana:0136`…`mana:0155`), iar 19 fapte au fost semnate cu `--verifica`.
**Istoria e acum la 18 pe nivelurile I și II, adică rezerva +10** — primul domeniu
scris de mână care iese din zona pragului. Nivelul III are tot 8, cu 10 ciorne.

Și cele două cifre-martor s-au mișcat exact cum trebuia, ceea ce e singura dovadă
că mecanismul ține de la un cap la altul:

| cifră | la scrierea lotului | după 10 confirmate | după 20 |
|---|---|---|---|
| `CATE_CIORNE` | 30 | **20** | **10** |
| `CATE_CU_NOTA` | **18** (neschimbat) | **28** | **38** |

Prima linie e ce aștepți. A doua e cea care contează: `CATE_CU_NOTA` numără
întrebările care ajung cu notă **pe ecran**. N-a clintit când au intrat 29 de note
noi în fișier (erau ciorne), și a urcat cu exact 10 când am confirmat 10. Dacă s-ar
fi mișcat la scriere, mecanismul n-ar fi ținut; dacă n-ar fi urcat la confirmare,
confirmarea n-ar fi însemnat nimic.

### 4. Lotul: 30 de ciorne de istorie

10 pe nivel, `mana:0136`…`mana:0165`, cu 29 de fapte noi (una e împărțită: faptul
`revolutia_franceza` ține și „în ce an a început?”, la nivelul I, și „ce închisoare
a fost luată cu asalt pe 14 iulie 1789?”, la II — chiar regula de la secțiunea 1 a
ghidului, folosită).

| | antichitate | Ev Mediu | modern | contemporan |
|---|---|---|---|---|
| nivel I | 2 | 1 | 2 | 5 |
| nivel II | 2 | 3 | 3 | 2 |
| nivel III | 3 | 5 | 1 | 1 |

Șase din 30 au eticheta `romania` (Marea Unire, Carol I, Vlad Țepeș, Posada,
independența din 1877). Nivelul III se duce spre antichitate și Ev Mediu dinadins:
acolo „o știi doar dacă te-a interesat” e cinstit, iar la contemporan ar fi
alunecat spre trivia de almanah.

**Ce am refuzat să scriu**, deși ar fi fost ușor: inventatorul telefonului, al
becului, al radioului (disputate); orice superlativ; orice domnie medievală cu
date care se contrazic între surse; și datele cu precizie de secol prezentate ca
an. Vlad Țepeș are trei domnii, deci întrebarea din lot e despre **nume**, nu
despre ani — iar nota spune ce e verificabil (semnătura „Drăculea”, porecla
tatălui, romanul lui Stoker din 1897), nu cât l-a inspirat Stoker, care e
discutabil.

**Așezarea în fișier:** inserate la finalul celor trei blocuri de istorie
existente (după `mana:0008`, `mana:0053`, `mana:0098`), nu lipite la coadă.
Fișierul e organizat nivel → domeniu, deci o întrebare confirmată trebuie să fie
deja la locul ei; altfel într-o zi mut linii, iar mutatul de linii e exact ce
`da_iduri.py` se ferește să facă. Diff: **300 de inserări, zero linii mutate.**

`id`-urile le-a dat scriptul, nu mâna. `CATE_INTREBARI` din `da_iduri.py` a trecut
de la 135 la 165 — plasa lui, funcționând cum trebuie: se ridică de mână, odată cu
lotul, fiindcă dacă s-ar citi din fișier n-ar mai prinde nimic.

### Verificatorul: secțiunea 11, și de ce întreabă în trei feluri

**O ciornă care ar ajunge în luptă n-ar crăpa nimic.** Ar fi o întrebare
neverificată printre altele verificate, cu aceeași formă și același antet.
Singurul loc în care s-ar vedea e o partidă în care nimeresc chiar ea și bag de
seamă că n-am citit-o niciodată. Deci secțiunea 11 întreabă în trei feluri:

| probă | ce prinde |
|---|---|
| nicio ciornă în `intrebari` | despărțirea listelor din încărcător |
| nicio ciornă trasă în 1000 de trageri pe nivel | alegerea, pe drumul ei adevărat |
| fiecare ciornă are fapt, cu notă | o ciornă pe care n-ai ce s-o confirmi |

A doua nu se sprijină pe prima, și asta e tot rostul. Probat rupând codul în două
feluri diferite:

| ce am rupt | ce a picat |
|---|---|
| ciornele puse ȘI în `intrebari` | invarianta (745 ≠ 715), proba 1, proba 2 |
| `trage_intrebarea` trage din `intrebari + ciorne` | **numai proba 2** (425 de trageri de ciornă) — invarianta și proba 1 au trecut liniștite |

A doua linie e dovada că afirmația din comentariu nu e o vorbă: cu listele
despărțite corect și o a treia sursă de întrebări adăugată din alt motiv, singura
verificare care prinde scurgerea e cea care trage prin funcția luptei.

Celelalte schimbări din verificator:

- `CATE_INTREBARI_MANA` 135 → **165**; `CATE_FAPTE` 15 → **44**; `CATE_CIORNE` =
  **30**, verdict **exact**, nu „cel mult”: dacă `--confirma=tot` ar lua vreodată
  mai mult decât am citit, cifra asta pică.
- **`CATE_CU_NOTA` a rămas 18**, și asta e cea mai elocventă cifră din sesiune: un
  lot de 30 de ciorne cu 29 de note n-a mișcat numărul întrebărilor care ajung cu
  notă pe ecran. Dacă s-ar fi mișcat, mecanismul n-ar fi ținut.
- Secțiunea 5 socotește faptele ciornelor drept **folosite**, dar nu le numără la
  „întrebări cu notă”. Cele două registre răspund la întrebări diferite:
  `folosite` caută conținut MORT, iar o notă scrisă pentru o ciornă nu e moartă, e
  neconfirmată; `cu_nota` caută ce ajunge pe ecran, iar o ciornă nu ajunge.
- Grila arată ciornele **lângă** rezervă, nu în ea: `istorie 8 (+0) +10 ciorne`.
  Adunate la rezervă, grila ar fi spus că istoria are +10 când în luptă are tot
  +0 — exact minciuna pe care rezerva a fost pusă să o împiedice, cu semnul
  schimbat.
- Subcategoriile goale, tipărite pe domeniu (ciornele numărate: un raft pentru
  care AM scris conținut nu mai e o promisiune, chiar dacă nu e încă în joc).

### Grila de azi

```
                              nivelul I              nivelul II             nivelul III
  geografie              47 (+39)               128 (+120)             100 (+92)
  istorie                18 (+10)                 8 (+0)  +10 ciorne     8 (+0)  +10 ciorne
  stiinta_natura         47 (+39)                60 (+52)               56 (+48)
  arta_literatura        50 (+42)                80 (+72)               93 (+85)
  divertisment            0                       0                      0
  sport_timp_liber        0                       0                      0
  (695 în joc + 20 ciorne = 715; 401 fapte, din care 44 scrise de mână)

  subcategorii goale: geografie 6/7 · istorie 0/4 · stiinta_natura 7/8
                      arta_literatura 5/6 · divertisment 5/5 · sport 6/6
```

Nivelul I e confirmat (18, rezerva +10). II și III sunt tot la 8, cu lotul lor
scris și necitit — și așa trebuie să fie: o ciornă nu apără nimic până nu e citită.

### Verificat

- `tools/verificari/verifica_trivia.tscn`, headless: **toate 11 secțiunile OK**, 685 de
  întrebări + 30 de ciorne = 715 din 715 găsite, 401 fapte. Cod de ieșire 0.
- Secțiunea 11, probată rupând codul în două feluri (tabelul de mai sus); a doua
  rupere arată că proba 2 prinde ce proba 1 nu poate.
- Lista închisă de câmpuri, probată: `"ciorne": true` scoate întrebarea din joc,
  cu mesaj.
- `comun.verifica_subcategoria`, probată: `"chimei"` oprește tabelul elementelor.
- `tools/arata_ciornele.py`: cele 30 de ciorne tipărite întregi (346 de rânduri),
  și **șase opriri probate** fiecare pe date stricate dinadins — fapt fără
  `de_verificat`, `verificat: true` cu `surse` gol, etichetă „Romania” cu R mare,
  subcategorie străină domeniului, câmp `ciorne`, `--confirma` pe o întrebare care
  nu e ciornă.
- `--confirma` probat pe două ciorne, cu diff față de copia de dinainte: exact
  două linii șterse. Dat înapoi, lotul e iar întreg.
- Fabrica, toate trei tabelele regenerate: **+550 de linii, −0**, toate
  `subcategorie`. Citite înapoi, id-uri unice peste tot conținutul.
- `tools/da_iduri.py --scrie`: 30 de id-uri noi, 165 de întrebări cu id unic, 48
  cu fapt.

### Ce NU s-a făcut

- **Nicio notă verificată.** Toate cele 44 de fapte scrise de mână sunt
  `verificat: false`, inclusiv cele 15 din pilot. Lotul de azi are listele
  `de_verificat` scrise; bifatul lor e muncă de citit, nu de scris cod.
- **Nivelul III al lotului (10 ciorne) nu e confirmat.** Nivelurile I și II au
  fost citite și confirmate în aceeași zi; restul așteaptă, și e în regulă — ăsta e
  chiar rostul mecanismului.
- **Cele două note găsite greșite nu sunt reparate** (`edirne`, 1363 în loc de
  1365; `zidul_lui_hadrian`, rotunjirea la 120 km). Sunt ciorne, deci se repară
  înainte de confirmare.
- **Cele 15 fapte din pilot n-au `wikidata`.** Numai cele 29 din lotul nou au.
- **Cele 135 scrise de mână n-au subcategorie.** Lot separat, ca ciornă.
- **Divertismentul și Sportul sunt tot goale.** Planul spune ce să scriu acolo;
  n-am scris nimic azi.
- **Niciun tabel nou de fabrică.** `evenimente_datate` e proiectat în plan, cu
  capcanele lui, și nescris.
- **Nicio partidă jucată** cu conținutul nou — e ciornă, deci nici n-ar fi apărut.
- **Cele 28 de ciorne de opere** au rămas ciorne (al patrulea raport care spune
  asta).

### Ce urmează, concret

1. **Reparat cele două note găsite greșite** (`edirne`, `zidul_lui_hadrian`), apoi
   citite și confirmate cele 10 ciorne de nivelul III. Asta duce istoria la 18 pe
   toate trei nivelurile.
3. **`--verifica` pe cele 44 de fapte scrise de mână.** Toate sunt încă
   `verificat: false`, inclusiv cele 15 din pilot — comanda există de azi,
   bifatul listelor nu s-a făcut.
4. **Divertisment și sport, 8 pe nivel** — cea mai mare schimbare pe cea mai mică
   muncă din tot planul: 48 de întrebări fac jocul să aibă șase domenii.
5. Lotul de clasificare pentru cele 135 scrise de mână.

### Fișiere

Nou: `docs/plan-continut.md`, `tools/arata_ciornele.py`,
`tools/sprijin_verificare.py`, `tools/fabrica/cache/wikidata_fapte.json`.
Atinse: `scenes/trivia/trivia.gd` (`SUBCATEGORII`, `CAMPURI_INTREBARE`, `ciorne`,
`fara_subcategorie`, `unde_e`, validările noi, bilanțul),
`tools/verificari/verifica_trivia.gd` (constante, invarianta, grila, subcategoriile goale,
secțiunea 5, secțiunea 11), `tools/fabrica/comun.py` (`SUBCATEGORII`,
`ORDINEA_INTREBARII`, `verifica_subcategoria`, `pune_la_locul_lui`, antetul),
`tools/fabrica/elemente.py`, `opere.py`, `capitale.py` (`SUBCATEGORIE`, ordinea,
verificarea la pornire), `tools/da_iduri.py` (`CATE_INTREBARI` 165),
`data/intrebari_trivia.json` (+300 de linii, 30 de ciorne, din care 10 confirmate),
`data/fapte_trivia.json` (+208 linii, 29 de fapte),
`data/trivia_gen/*_intrebari.json` (+550 de linii, toate `subcategorie`),
`docs/ghid-note.md` (`de_verificat`, `subcategorie`), `CLAUDE.md`, `docs/progres.md`.

---

## DOMENIILE (6 octombrie 2026) — șase domenii noi și un prag de intrare în luptă

**Zi de migrare și de reguli, zero conținut nou.** Cele șase domenii ale Culturii
generale au fost retăiate, iar alegerea din luptă a primit o regulă pe care n-o
avea: un domeniu intră în joc doar dacă are destul conținut la nivelul cerut.

### Domeniile vechi erau tăiate după cum crescuse baza, nu după cum se joacă

| vechi | nou |
|---|---|
| istorie | `istorie` — Istorie |
| geografie | `geografie` — Geografie |
| stiinta | `stiinta_natura` — Știință și natură |
| arta + mitologie + literatura | `arta_literatura` — Artă și literatură |
| — | `divertisment` — Divertisment |
| — | `sport_timp_liber` — Sport și timp liber |

Artă, mitologie și literatură erau trei domenii cu 21 de întrebări fiecare, care
se întreabă **identic**: cine a scris, cine a pictat, cine a compus. Trei celule
subțiri în loc de una groasă — iar subțirimea costă, de când alegerea e uniformă
pe domenii: fiecare lua 1/6 din luptă cu 7 întrebări pe nivel.

În locul lor au intrat două care lipseau cu totul. Divertismentul și Sportul
**pornesc goale, dinadins**: un domeniu scris în `DOMENII` de la început e un
rând; unul adăugat după ce s-a scris conținut e o migrare ca cea de azi.

Ce intră în fiecare, cu regula pentru cazurile de graniță, e în
**`docs/ghid-note.md`**, în secțiunea nouă de la început.

### `CATEGORII` (listă) a devenit `DOMENII` (dicționar)

```gdscript
const DOMENII := {
	"geografie": "Geografie",
	"istorie": "Istorie",
	"stiinta_natura": "Știință și natură",
	"arta_literatura": "Artă și literatură",
	"divertisment": "Divertisment",
	"sport_timp_liber": "Sport și timp liber",
}
```

Un dicționar face amândouă treburile: validează cheia la încărcare
(`DOMENII.has`) și dă numele din antetul întrebării (`DOMENII[cheie]`). Cu o
listă de chei lângă un dicționar de nume, un domeniu nou ar fi fost două locuri
de ținut sincronizate, iar al doilea se uită.

**Cheia nu e numele** — iar despărțirea asta nu exista înainte, fiindcă până azi
`arta` era și una, și alta. Cheia intră în `id`-uri, în cheile sacului și, de la
Save, pe disc, deci n-are diacritice și nu se schimbă niciodată. Numele e text pe
ecran. Fără despărțire, antetul ar fi scris „ARTA_LITERATURA”; acum scrie
„ARTĂ ȘI LITERATURĂ”, iar Logica afișa oricum etichete de două-trei cuvinte
(„SIR NUMERIC”, „MIXT: x2, APOI +3”), deci forma exista deja pe ecran.

### Pragul: 8 întrebări pe celulă, și socoteala din care iese

Regula veche de echilibru (8/8/8/7/7/7 pe nivel, ținut de mână în fișier) nu mai
are sens de când artă, mitologie și literatură sunt un singur domeniu. O
înlocuiește una care nu depinde de cât de mare crește un domeniu:

> Un domeniu intră în alegerea din luptă, la un nivel, doar dacă are acolo cel
> puțin **8 întrebări**. Sub prag e **sărit, nu golit**.

**1. Câte trage o expediție lungă.** Sesiunea CONȚINUTUL a fixat cifra: ~15 pe
nivel, adică ~45 de întrebări de Cultură generală pe o expediție lungă. Dar cifra
aia e de **dinainte de paliere**. Pe 30 septembrie nivelul urca la fiecare
treaptă (`mini(treapta, 3)`): treapta 1 era nivelul I, treapta 2 nivelul II, iar
treapta 3 și tot restul lanțului nivelul III — deci grosul cădea pe III. Cu
`TREPTE_PE_NIVEL = 3`, repartiția s-a întors.

Un lanț cu rata de reușită 0,8 pe întrebare (șansa de a ajunge la treapta *k* e
0,8^(k-1)) dă în medie, pe activare:

| nivel | treptele | întrebări pe activare |
|---|---|---|
| I | 1, 2, 3 | 1 + 0,8 + 0,64 = **2,4** |
| II | 4, 5, 6 | 0,51 + 0,41 + 0,33 = **1,25** |
| III | 7 încolo | 0,26 / 0,2 = **1,3** |

≈ 5 întrebări pe activare, din care **49% la nivelul I**. Pe 45 de întrebări:
~22 la nivelul I, ~11 la II, ~12 la III. **Nivelul încărcat nu mai e III, e I** —
și acolo se decide pragul.

**2. Cât ia un domeniu.** Alegerea e uniformă pe domeniile admise. Azi trec
patru, deci ~5-6 trageri pe celulă la nivelul I. Cu toate șase pline, ~4.

**3. Cât de des s-ar repeta.** Sacul garantează „nicio repetiție până se
golește”, pe cheie domeniu × nivel:

| întrebări în celulă | într-o expediție lungă |
|---|---|
| 8 | 5-6 trageri < 8 → **zero repetiții** |
| 4 | sacul reciclează → aceeași întrebare **de două ori** |
| 2 | de trei ori — și 1/6 din toată lupta ar fi acele două |

**De ce 8 și nu alt număr.** Trei lucruri, și toate trei trebuiau să fie
adevărate deodată:

- **E cifra pe care o cere socoteala.** Primul număr la care garanția sacului mai
  înseamnă ceva pentru o expediție lungă. Sub el, pragul ar lăsa să intre exact
  domeniile care se repetă — adică n-ar apăra nimic.
- **E o celulă scrisă de mână.** Baza de 135 s-a construit 7-8 pe celulă, deci 8
  e cea mai mică porție de conținut pe care o produc dinadins.
- **Nu arunc nimic din ce am.** Istoria are exact 8 pe fiecare nivel și trece la
  limită. La 10, o regulă introdusă ca să apere echilibrul ar fi șters istoria din
  joc. Și cu `FOLOSESTE_WIKIDATA` stins rămâne mâna: 8/8/8 la geografie, istorie
  și știință, 21 la artă și literatură — toate trec. **La 9, stingerea
  comutatorului ar lăsa în luptă trei domenii, și istoria ar ieși prima.**

### Prețul, spus pe față: istoria trece cu rezerva zero

La 8 pe nivel și 5-6 trageri, fiecare expediție lungă îmi arată 5-6 din cele 8
întrebări de istorie ale unui nivel. Pragul nu ascunde asta, **o numește**:
istoria e celula subțire și e următoarea țintă de conținut.

Și mai e un fel în care tăcerea ar fi costat: dacă retrag vreodată o întrebare de
istorie, domeniul iese din luptă fără nicio eroare, fără niciun avertisment — pur
și simplu nu mai apare. De-aia verificatorul tipărește acum **rezerva fiecărei
celule peste prag**, nu doar dacă trece:

```
  nivelul 1, pe domenii   arta_literatura 50 (+42), geografie 47 (+39),
                          istorie 8 (+0), stiinta_natura 47 (+39)
  domenii fără nicio întrebare   divertisment, sport_timp_liber
```

`(+0)` e ce vreau să văd. O coloană „trece / nu trece” ar fi arătat istoria exact
ca geografia.

Și, în aceeași secțiune, un rând care pare banal și nu e:

```
  antetele, cum ajung pe ecran   GEOGRAFIE · ISTORIE · ȘTIINȚĂ ȘI NATURĂ ·
                                 ARTĂ ȘI LITERATURĂ · DIVERTISMENT · SPORT ȘI TIMP LIBER
```

E singurul lucru din sesiunea asta pe care nicio altă verificare nu-l poate
atinge: `to_upper()` pe diacritice românești. Dacă ar da „ARTA SI LITERATURA”,
nimic n-ar crăpa și nimic n-ar avertiza — s-ar vedea doar într-o luptă, pe o
întrebare din domeniul ăla, dacă mă uit la antet. Acum se vede dintr-o rulare
headless. (Godot îl face corect.)

### Plasa: dacă niciun domeniu nu trece, se joacă cu toate

`trage_intrebarea` putea întoarce dicționar gol, iar `puzzle.gd` scoate pentru el
ecranul de eroare. În mijlocul unui lanț, asta nu e o apărare împotriva
conținutului subțire, e o **pedeapsă pentru el** — pierzi lanțul fiindcă n-am
scris destule întrebări. Deci dacă nicio celulă nu trece pragul, se trage din
toate, cu un avertisment.

Avertismentul a fost și prima greșeală a zilei, prinsă de verificator în aceeași
rulare: scris fără registru, a ieșit **de o mie de ori** la o mie de trageri,
fiindcă locul ăla e pe drumul fiecărei întrebări, nu al încărcării. Într-o luptă
ar fi însemnat o consolă în care nu se mai poate citi nimic altceva — adică exact
opusul a ce vrea un avertisment. Acum se spune o dată pe nivel, pe toată rularea
(`_plasa_spusa`).

### Verificatorul: echilibrul doar peste prag, și o secțiune care RUPE pragul

**Secțiunea 6 (ECHILIBRUL)** socotea ținta ca 1/N peste domeniile *prezente*. De
azi, „prezent” și „jucat” nu mai sunt același lucru: un domeniu cu trei întrebări
e în date și nu e în luptă. Cu el în numitor, verificarea ar fi cerut 1/5 când
lupta împarte la 4, și **ar fi picat pe un cod corect**. Ținta se socotește acum
peste domeniile care trec pragul, cu aceeași constantă pe care o citește și lupta
(`TRIVIA.PRAG_DOMENIU`), nu cu o cifră rescrisă în verificator.

Plus o afirmație mai tare decât proporția: **niciuna din cele 6000 de trageri
n-are voie să vină dintr-un domeniu sub prag.** Proporția e o măsură cu toleranță
de 20%; asta e zero sau nimic.

**Secțiunea 10 (PRAGUL) e cea care contează**, și motivul ei merită scris, fiindcă
e o lecție care se repetă:

> Azi **toate** domeniile cu conținut trec pragul. Deci dacă mâine scot filtrul
> din `trage_intrebarea`, secțiunea 6 trece mai departe, neschimbată. **O regulă
> care nu e niciodată încălcată nu e niciodată probată** — e doar un comentariu
> care se întâmplă să fie adevărat.

Deci se calcă dinadins. `TRIVIA.intrebari` e `static var`, adică aparține
scriptului: se pune în locul lui o bază sintetică, se trage prin **chiar funcția
pe care o folosește lupta**, și se pune conținutul la loc. Patru probe, fiindcă un
prag greșit poate cădea în patru feluri și numai unul s-ar vedea jucând:

| probă | ce prinde |
|---|---|
| un domeniu cu `prag - 1` nu iese niciodată | filtrul șters cu totul |
| un domeniu cu exact `prag` IESE | un `>` scris în loc de `>=` — adică istoria tăiată în tăcere |
| pragul se judecă pe celulă, nu pe domeniu | un filtru pus pe domeniul întreg |
| toate sub prag → se trage totuși ceva | plasa ruptă, deci ecran de eroare în luptă |

Rulează **ultima** din `_ready`, fiindcă e singura care mișcă pământul de sub
celelalte, și pune conținutul la loc fără nicio ieșire devreme din funcție.

Pragul s-a probat și pe datele adevărate, nu doar pe baza sintetică: pus la 9
pentru o rulare, istoria apare `8 (SĂRIT)` la toate trei nivelurile, ținta devine
1/3, și „niciun domeniu sub prag n-a ieșit” rămâne OK cu „1 domenii sub prag,
niciunul tras”.

### Migrarea: pe linie, nu prin reserializare

`data/intrebari_trivia.json` e scris de mână, întrebare cu întrebare — deci
migrarea a atins **numai liniile `"categorie": "…"`**, ca la `tools/da_iduri.py`.
Nimic altceva din fișier nu s-a putut mișca, iar dovada e `git diff --numstat`:
87 de linii schimbate (21 artă + 21 mitologie + 21 literatură + 24 știință), și
zero linii schimbate care nu sunt `categorie`.

Tabelele fabricii s-au **regenerat**, nu editat: `DOMENIU` e o constantă în
fiecare script (`elemente.py` → `stiinta_natura`, `opere.py` → `arta_literatura`,
`capitale.py` neatins). Hash-urile fișierelor s-au schimbat, și asta era
intenționat — diff-ul arată exact 299 de linii (139 elemente + 160 opere), toate
`categorie`, zero altceva. Faptele nu s-au atins deloc: ele nu poartă domeniu.

### Grila nouă

```
                                 nivelul I          nivelul II         nivelul III         total
    geografie              8+39  ( 1+20 )     8+120 ( 1+61 )     8+92  ( 1+46 )    275 (130)
    istorie                8+0   ( 1+0  )     8+0   ( 2+0  )     8+0   ( 1+0  )     24 (  3)
    stiinta_natura         8+39  ( 2+20 )     8+52  ( 1+26 )     8+48  ( 1+24 )    163 ( 73)
    arta_literatura       21+29  ( 3+29 )    21+59  ( 2+59 )    21+72  ( 1+72 )    223 (166)
    divertisment        ·  0+0   ( 0+0  )  ·  0+0   ( 0+0  )  ·  0+0   ( 0+0  )      0 (  0)
    sport_timp_liber    ·  0+0   ( 0+0  )  ·  0+0   ( 0+0  )  ·  0+0   ( 0+0  )      0 (  0)
    (mână + fabricate; parantezele sunt fapte distincte; 685 întrebări în total)
    („·” = sub pragul de 8, deci domeniul e SĂRIT în luptă la nivelul acela: 6 celule din 18)
```

Marcajul `·` nu e decor: o celulă subțire e conținut care **există în fișier și
nu ajunge niciodată în luptă**, iar fără semn ar arăta în grilă exact ca una care
joacă.

Și `cat_din_lupta` împărțea la `len(DOMENII)`, adică la 6. Lupta împarte la 4,
deci raportul spunea cu o treime mai puțin decât adevărul — exact despre tabelul
pe care tocmai îl rulasem. Acum împarte la câte domenii trec pragul la nivelul
ăla, și scrie câte sunt.

### Verificat

- `tools/verificari/verifica_trivia.tscn`, headless: **toate 10 secțiunile OK**, 685 de
  întrebări încărcate din 685 găsite, 372 de fapte. Cod de ieșire 0.
- Antetele, tipărite: diacriticele trec prin `to_upper()` („ȘTIINȚĂ ȘI NATURĂ”).
- Echilibrul, 6000 de trageri pe nivel: abaterea maximă 3,9% / 2,1% / 2,5%, cu
  limita la 20%. Țintă 1500, 4 domenii peste prag la fiecare nivel.
- Sacul: 12 chei (4 domenii × 3 niveluri) fără nicio repetiție pe un ciclu întreg.
- Secțiunea 10, toate patru probele: sub prag nu iese, la prag iese, se judecă pe
  celulă, plasa ține.
- Pragul pus la 9 pentru o rulare: istoria `(SĂRIT)` pe toate nivelurile, țintă
  1/3, nimic tras de sub prag. Pus la loc la 8.
- `python tools/fabrica/elemente.py --scrie` și `opere.py --scrie`: scrise, citite
  înapoi, id-uri unice peste tot conținutul, texte unice.

### Ce NU s-a făcut

- **Niciun conținut nou.** Divertismentul și Sportul sunt goale, iar istoria are
  tot 24 de întrebări. Ziua a fost despre reguli și despre mutat, nu despre scris.
- **„Memorie” e tot „Memorie”** pe butonul de Obelisc. Redenumirea în „Cultură
  generală” e pasul 2 din rută, alt obiectiv.
- **`data/logica_categorii.json` n-a fost atins.** Are și el un câmp `domeniu`
  („natura”, „obiecte”, „abstract”), dar e spațiul de nume al Logicii, nu al
  Culturii generale. Două câmpuri cu același nume și scopuri diferite — verificat
  înainte, nu presupus.
- **Cele 28 de ciorne de opere** au rămas ciorne.

### Ce urmează, concret

1. **Istoria, de la 8 la 20+ pe nivel.** E singura celulă cu rezerva zero, deci e
   și singurul loc unde o întrebare retrasă ar scoate un domeniu din joc.
2. **Un tabel de fabrică pentru istorie** — datele istorice din Wikidata sunt
   bogate, iar axa timpului era deja gândită ca imagine desenată din date.
3. Divertisment și Sport rămân deschise, cu regula „numai trecut” scrisă
   înainte să existe prima întrebare.

### Fișiere

Atinse: `scenes/trivia/trivia.gd` (`DOMENII`, `PRAG_DOMENIU`, pragul în
`trage_intrebarea`, numele afișat în antet, `_plasa_spusa`),
`data/intrebari_trivia.json` (87 de linii de `categorie`),
`tools/fabrica/comun.py` (`DOMENII`, `PRAG_DOMENIU`, `celulele`,
`domenii_in_lupta`, grila cu marcaj, `cat_din_lupta` cu numitorul bun),
`tools/fabrica/elemente.py` și `opere.py` (`DOMENIU`),
`data/trivia_gen/elemente_intrebari.json` și `opere_intrebari.json`
(regenerate, 299 de linii), `tools/verificari/verifica_trivia.gd` (secțiunea 6 rescrisă,
secțiunea 10 nouă, rezerva în grilă), `docs/ghid-note.md` (secțiunea
domeniilor), `CLAUDE.md`, `docs/progres.md`.

---

## NIVELUL URCĂ ÎN PALIERE (30 septembrie 2026) — trei trepte pe nivel, nu una

Dificultatea întrebărilor dintr-un lanț nu mai crește la fiecare treaptă.
Acum ține un **palier de 3 trepte** pe fiecare nivel:

| trepte | nivel | combo pe care îl construiești |
|---|---|---|
| 1, 2, 3 | I | până la „COMBO x3" |
| 4, 5, 6 | II | de la x4 la x6 |
| 7 încolo | III | de la x7 |

Înainte era `mini(treapta, NIVEL_MAX)`: la a doua întrebare a lanțului primeai
deja Nivel II, iar la a treia Nivel III. Un lanț lung n-avea o pantă, avea un
**perete la început** — și exact acolo e cel mai prost loc pentru el, fiindcă
n-ai încă nimic acumulat de apărat. Cu paliere, primele răspunsuri construiesc
combo-ul, iar greul vine când ai deja ceva de pierdut. Prima treaptă critică
(a 5-a) cade acum în mijlocul Nivelului II, nu în platoul de III.

Nu s-a adăugat nicio ramură: e un singur număr, `TREPTE_PE_NIVEL := 3` în
`scenes/lupta/lupta.gd`, și o împărțire cu numere întregi în `nivel_treapta()`.
Dacă la joc se simte că urcă prea repede, se pune 4. Funcția era deja chemată
dintr-un singur loc, deci n-a fost nevoie să se atingă nici disciplinele, nici
`puzzle.gd`.

Cronometrul rămâne cum era (`TIMP_PE_NIVEL` = 12 / 12 / 15 secunde, minus o
secundă pe treaptă, cu podea la 8). Efectul secundar e că presiunea de timp și
dificultatea întrebării nu mai urcă în același cadru — ceea ce e de dorit: două
lucruri care se înăspresc simultan se simt ca un zid, nu ca o pantă.

`tools/verificari/verifica_trivia.tscn` trece, cu tot cu echilibrul pe domenii la 6000 de
trageri pe nivel.

---

## STEAGURILE (30 septembrie 2026) — o formă pentru imaginile faptelor

**Rezultat: 126 de steaguri pe disc, 0,53 MB, toate în domeniul public** — și,
mai important decât steagurile, **forma în care un fapt ține imagini**, gândită
ca să primească și harta de azi, și tablourile de mâine.

Nimic nu se afișează încă. Afișarea vine la pasul 13, cu Practice. Ce s-a făcut
azi e partea care, dacă o amânam, ar fi însemnat peste trei luni o rulare pe tot
conținutul ca să recuperez ceva ce era deja sub mână.

---

### Forma: o LISTĂ de imagini, nu un câmp pe fel

```json
{
	"id": "wd:Q142",
	"nota": "",
	"surse": ["https://www.wikidata.org/wiki/Q142"],
	"verificat": false,
	"imagini": [
		{"tip": "harta", "cod": "FR"},
		{"tip": "steag", "fisier": "steaguri/Q142.png",
		 "licenta": "Public domain", "autor": "SKopp",
		 "sursa": "https://commons.wikimedia.org/wiki/File:Flag_of_France.svg"}
	]
}
```

Un câmp `steag` ar fi fost cel mai simplu lucru de scris azi și cel mai scump
peste trei luni: ziua în care un fapt de artă vrea un tablou, popup-ul ar fi
trebuit să învețe un al doilea câmp; ziua în care vrea și un portret al
autorului, un al treilea. E exact forma pe care principiul din `CLAUDE.md` o
refuză la discipline — **o disciplină nouă e un rând în tabel, nu o ramură nouă
în cod.**

Cu o listă, desenatorul de la pasul 13 are **o singură buclă**: pentru fiecare
intrare, se uită la `tip` și desenează.

### De ce a ieșit `cod_iso` din vârful faptului

Dacă rămânea sus, Practice ar fi întrebat două lucruri diferite: „ce imagini ai
în listă?" **și** „ai cumva un cod ISO, ca să-ți desenez și o hartă?". Adică fix
ramura pe care lista există ca s-o evite. Deci `cod_iso: "FR"` a devenit
`{"tip": "harta", "cod": "FR"}`.

Diff-ul pe toate cele 127 de fapte a fost declarat înainte, nu descoperit după.

### Două feluri de intrări, deosebite prin ce LIPSEȘTE

| | desenată de joc | fișier real |
|---|---|---|
| exemplu | `{"tip": "harta", "cod": "FR"}` | `{"tip": "steag", "fisier": …}` |
| greutate | zero | octeți pe disc |
| licență | n-are voie s-o aibă | obligatorie |

Regula pe care o pune verificatorul e **în amândouă direcțiile**: o intrare cu
`fisier` trebuie să aibă licență, una fără fișier n-are voie. Așa, „am uitat
licența" e o eroare, nu o omisiune tăcută.

### Trei alegeri mici, fiecare cu un motiv care ține

**Calea e relativă** (`steaguri/Q142.png`), cu rădăcina `assets/imagini_fapte/`
scrisă o dată în Python și o dată în GDScript. Cu calea `res://` întreagă în
JSON, ziua în care mut dosarul ar cere regenerarea faptelor fabricate — și
repararea **de mână** a celor din `data/fapte_trivia.json`, care nu se
regenerează. Faptul scris de mână e argumentul care decide.

**Dosar propriu, `assets/imagini_fapte/`, nu `assets/art/`.** Acolo stă arta
jocului, aici numai material străin, cu licență de onorat. Granița de dosar face
ca „ce am în joc care nu-mi aparține?" să aibă un răspuns dintr-o privire.

**Numele fișierului e QID-ul**, nu codul ISO. `fr.png` s-ar citi mai frumos, dar
codul ISO are deja o excepție (Danemarca îl are doar de mână) și la tablouri nu
există deloc — ar fi fost o regulă cu excepții încă de la al doilea fel de
imagine. Citibilitatea o dă `credite.json` de lângă fișiere.

---

### Măsurat înainte: PNG de la Commons, nu SVG

Tentația era SVG-ul: P41 arată aproape mereu spre unul, e vectorial, „cântărește
nimic". Măsurat, e o capcană: un tricolor are 300 de octeți în SVG, dar unul cu
stemă (Turkmenistan, Sri Lanka, Serbia) are între 1 și 5 MB de contururi — mai
mult decât tot dosarul. Deci rasterizarea o face Commons, o dată, prin
`iiurlwidth`.

```
cerut 320 px:  126 fișiere, 0,53 MB  (median 2,2 KB, maxim 30,7 KB — San Marino)
după importul Godot, .ctex:           0,32 MB   ← cifra care contează la export
fișierele .import (doar în Git):      0,11 MB
```

De zece ori mai puțin decât estimasem înainte de măsurătoare. E loc și de mai
mare, dacă la pasul 13 se dovedește că 320 px nu ajung.

Commons rotunjește la raportul steagului (a întors 330 px pentru 320 cerut), deci
câmpul din manifest se numește `latime_ceruta`, nu `latime`. Un câmp care spune
altceva decât conține e o minciună mică pe care o crezi peste șase luni.

---

### Lecția zilei: rangul preferat, și de ce planul meu era greșit

Planul confirmat spunea: nu ating rangul preferat, „mai multe steaguri actuale"
oprește ca la capitale, alegerea o scriu de mână. **Măsurătoarea a spus altceva.**

```
țări din tabel cu mai multe steaguri „actuale":  21  (18 cu două, 2 cu trei, 1 cu patru)
decise de rangul preferat:                       21
rămase nehotărâte:                                0
```

Pe toate cele 195 de state membre ONU: 28 din 28.

Capitalele multiple erau 8, și 0 în tabel. 21 din 126 e altă cifră: **21 de
rânduri scrise de mână nu sunt o listă citită**, sunt exact ce spune sesiunea
capitalelor despre excepțiile declarate mecanic.

Și cele 21 nu sunt ambiguități reale. Ce rămâne pe dinafară sunt **variante**
(`Flag of Belgium (civil).svg`, `War flag of Peru.svg`,
`Flag of Bulgaria (digital).svg`, `Civil Ensign of Switzerland (Pantone).svg`) și
**steaguri istorice a căror declarație n-are dată de sfârșit scrisă**
(`Flag of Rhodesia (1968–1979).svg` la Zimbabwe, `Flag of Sudan (1956–1970).svg`
la Sudan) — adică lecția „un câmp lipsă nu e un NU", **a treia oară**, acum la al
treilea fel de date.

Rangul preferat nu e o euristică inventată de mine: e o declarație explicită a
editorilor Wikidata, „dintre astea, asta e cea curentă". Diferența față de „ia
prima" e diferența dintre a citi o afirmație și a ghici.

**Ce ține alegerea cinstită, fiindcă tot e o alegere făcută de cod:**

1. Zero sau două ranguri preferate → **oprește**, cu `steag_de_mana` ca ieșire.
   Azi pornește de 0 ori, dar fără ea pasul de sus ar fi o presupunere.
2. Toate cele 21 se **tipăresc la fiecare rulare**, cu ce au lăsat pe dinafară.
3. Scena F6 le arată cu ochiul.

**Două de verificat cu ochiul mai întâi:** Afganistanul iese cu
`Flag of the Taliban.svg` (corect pentru 2021 încoace, dar e o alegere care merită
văzută), iar Costa Rica cu steagul civil, nu cu cel de stat cu stemă.

---

### Licențele: 139 din 140 `pd`, una refuzată scris

```
pd                    139   domeniu public
fără cod de licență     1   Flag of Oman.svg  —  'OGL-om 1.0', Copyrighted: True
```

Lista e **albă, nu neagră**: se acceptă `pd*`, `cc0`, `cc-by*`, iar orice altceva
oprește. O listă neagră apără numai împotriva a ce mi-am imaginat deja; prima
licență la care nu m-am gândit ar trece în tăcere. Iar aici greșeala nu e o
întrebare urâtă, e un fișier pe care n-am dreptul să-l dau mai departe.

**Omanul rămâne fără steag**, declarat în `STEAGURI_REFUZATE`, lângă `EXCLUSE`, cu
motivul scris: „Open Government Licence – Oman 1.0" nu e nici domeniu public,
nici Creative Commons, iar o licență guvernamentală străină nu e ceva ce pot
judeca singur. Întrebările și harta Omanului nu sunt atinse — iese doar imaginea.
Diferența față de `EXCLUSE`, unde iese țara întreagă.

Și **refuzul se verifică singur**: dacă fișierul primește pe Commons o licență
recunoscută, scriptul oprește și cere ștergerea declarației. Un refuz al cărui
motiv nu mai e adevărat e la fel de rău ca unul lipsă, doar mai tăcut — aceeași
regulă ca la „fantomele" din `DUBLURI`.

Pentru `cc-by*`, faptul ține și `licenta_url`, nu doar autorul: atribuirea CC cere
autorul, sursa **și** licența. Azi niciun steag nu e în cazul ăsta, dar câmpul e
scris și verificat, fiindcă tablourile vor fi.

---

### Unde stă codul, și de ce nu tot în `comun.py`

Aceeași linie ca la faza 1 a modulului comun: **intră ce n-are nicio părere
despre steaguri.**

| `comun.py` | `capitale.py` |
|---|---|
| metadatele Commons, în loturi de 50 | interogarea P41 |
| lista albă de licențe, și oprirea | „care e steagul de azi" |
| descărcarea la o lățime, o singură dată | `STEAGURI_REFUZATE`, `steag_de_mana` |
| cache-ul, manifestul, cântărirea dosarului | lista `imagini` din fapt |

E fix separarea `comun.interogheaza` (rețea) față de `INTEROGARE_TARI`
(judecată). Mecanismul refuzului e în comun; **lista** refuzurilor, în tabel.

Cache-ul metadatelor, `tools/fabrica/cache/commons.json`, **crește în loc să se
rescrie**: la tablouri, fișierele de azi rămân pe loc, iar `--reincarca`
împrospătează doar ce cere tabelul care rulează.

**`--descarca` e un flag separat de `--scrie`**, dinadins: una atinge `assets/`,
cealaltă `data/`. O rulare care scrie întrebări n-are de ce să plece la Commons.
Și `--scrie` **oprește** dacă un fapt trimite la un fișier care nu e pe disc:
verificatorul din Godot prinde și el asta, dar între `--scrie` și verificare e un
commit.

---

### Verificatorul: a noua secțiune

`tools/verificari/verifica_trivia.gd`, secțiunea **IMAGINILE FAPTELOR**, peste tot
conținutul, inclusiv cel scris de mână:

- `tip` dintr-o listă închisă — `"stag"` n-ar da nicio eroare nicăieri, imaginea
  pur și simplu n-ar apărea;
- fișierul există, verificat **în două feluri**: pe disc (`FileAccess`) și ca
  resursă importată (`ResourceLoader`). Al doilea pică pe un repo proaspăt clonat
  în care nu s-a deschis editorul — și e bine să se vadă ca atare, nu ca „fișier
  lipsă";
- licență obligatorie unde e fișier, interzisă unde nu e; autor obligatoriu unde
  licența cere atribuire;
- **fapt ↔ manifest**: aceeași licență și același autor în amândouă locurile.
  Duplicarea ar fi fost un risc de divergență; comparată la fiecare rulare,
  devine o probă;
- **niciun fișier orfan** — un steag la care nu duce niciun fapt e greutate curată
  în exportul web.

Probată rupând patru lucruri dinadins, toate patru au picat cu mesajul lor:

| ce am stricat | ce a picat |
|---|---|
| șters `Q142.png` | `fișierul lipsește de pe disc — steaguri/Q142.png` |
| `"tip": "stag"` la Bulgaria | `tip necunoscut 'stag'` |
| `"cod": "cze"` la Cehia | `harta are codul 'cze', care nu arată a cod ISO` |
| licența schimbată în faptul Austriei | `faptul zice 'CC BY-SA 4.0', manifestul 'Public domain'` |
| un PNG copiat în plus în dosar | `niciun fișier orfan → steaguri/Q99999.png` |

### Scena F6: `tools/verificari/verifica_steaguri.tscn`

Toate steagurile într-o grilă, cu numele țării sub fiecare și cu creditul care
s-ar afișa în joc („domeniu public", sau „autor · licență").

Există fiindcă e **singura verificare pe care un script nu o poate face**: un
steag vechi, unul al țării vecine sau varianta de stat trec prin toate
verdictele de mai sus, fiindcă sunt fișiere perfect valide. Iar 21 din 126 au
fost alese de cod.

**Citește faptele, nu dosarul.** Drumul parcurs aici e chiar drumul pe care-l va
face Practice: fapt → lista `imagini` → intrarea `steag` → fișierul. Un steag
rămas dintr-o rulare veche nu apare, fiindcă nu e în joc. Numele omenesc vine din
manifest — faptul ține doar `wd:Q142`, iar la „Q142" nu te poți uita ca să spui
„ăsta nu e steagul Franței".

---

### Două bug-uri găsite rupând codul dinadins

Amândouă în ce scrisesem chiar atunci, amândouă tăcute:

1. **`steag_de_mana` nu apărea în „PUSE DE MÂNĂ".** Adăugasem tipărirea, nu și
   filtrul care alege rândurile. Un câmp care ocolește o verificare și nu se
   tipărește e exact felul comod de a face o greșeală să dispară.
2. **Fișierele refuzate nu erau nici măcar întrebate.** Părea firesc — „oricum nu
   le folosesc" — și cu asta murea tăcut tocmai verificarea că refuzul mai e
   justificat: `metadate_commons` nu poate observa că o licență s-a schimbat
   pentru un fișier despre care nu întreabă.

Niciunul n-ar fi fost găsit de o rulare care merge bine.

---

### Verificat

- `--descarca`: 126 aduse; a doua rulare, **0 aduse, 126 deja pe disc**;
- `--masoara` pe toate cele 195 de state: rangul preferat decide 28 din 28;
- cele patru hash-uri ale celorlalte două tabele, **identice octet cu octet**
  după schimbările din `comun.py`; singurul fișier schimbat sub `data/` e
  `capitale_fapte.json`;
- cinci opriri probate rupând datele: fișier lipsă la `--scrie`, `steag_de_mana`
  inexistent, refuz nejustificat (`Flag of France.svg`), licență necunoscută cu
  declarația Omanului ștearsă, `steag_de_mana` valid (Belgia iese din alegerea
  automată, 21 → 20);
- verificarea headless: **TOTUL E BUN**, 21 de verdicte, 0 picate;
- secțiunea nouă, probată că pică pe cinci feluri de stricăciune;
- scena F6 rulează curat: `126 din fapte, 0 fără fișier pe disc`.

### Ce NU s-a făcut

- **Nu s-a văzut niciun steag cu ochiul.** Captura pe care am încercat-o a prins
  altă fereastră. **Ăsta e primul lucru de făcut: F6 pe
  `tools/verificari/verifica_steaguri.tscn`**, cu Afganistanul și Costa Rica primele pe
  listă.
- **Nimic nu se afișează în joc.** `imagini` e scris, citit și verificat, dar
  niciun desenator nu-l folosește — vine la pasul 13.
- **Harta nu se desenează.** Intrarea `{"tip": "harta", "cod": "…"}` există pe
  toate cele 127 de fapte; contururile Natural Earth și desenatorul, nu.
- **Nicio notă.** Tot 0 din cele 127 de fapte ale capitalelor.
- **Omanul rămâne fără steag**, cu motivul scris.
- **Banda de distanță** la distractori și **cele 28 de ciorne de la opere** —
  neatinse, ca la sesiunea trecută.

### Ce urmează, concret

1. **F6 pe scena steagurilor.** Afganistan (steagul talibanilor) și Costa Rica
   (civil, nu de stat) sunt cele două alegeri de confirmat; restul e o trecere cu
   privirea peste 126 de plăcuțe.
2. Dacă un steag e greșit: `"steag_de_mana": "Flag of ….svg"` pe rândul din
   `tari.json`, apoi `--descarca` și `--scrie`. Probat pe Belgia.
3. **Contururile pentru hărți** (Natural Earth) și desenatorul — pasul 13, nu
   acum.
4. Când vin tablourile: `{"tip": "tablou", …}` e un caz în plus în
   `TIPURI_DE_IMAGINE` din verificator și un dosar nou lângă `steaguri/`. Restul
   mecanismului există.

### Fișiere

Nou: `tools/verificari/verifica_steaguri.gd`, `tools/verificari/verifica_steaguri.tscn`,
`assets/imagini_fapte/steaguri/` (126 PNG + `credite.json`),
`tools/fabrica/cache/commons.json`.
Atinse: `tools/fabrica/comun.py` (secțiunea IMAGINILE DE PE WIKIMEDIA COMMONS,
`--descarca` în `Argumente`, `cat_cantareste` cu filtru de sufixe),
`tools/fabrica/capitale.py` (interogarea P41, `alege_steagul`,
`STEAGURI_REFUZATE`, `steag_de_mana`, `cale_de_steag`, `arata_steagurile`,
`pune_metadatele_steagurilor`, `descarca_steagurile`, `fapt_cu_imagini`),
`tools/verificari/verifica_trivia.gd` (secțiunea IMAGINILE FAPTELOR),
`data/trivia_gen/capitale_fapte.json` (toate cele 127),
`tools/fabrica/cache/wikidata_capitale.json`, `docs/progres.md`,
`CLAUDE.md` (secțiunea „Unelte" cu calea Godot, trei decizii noi).

---

## MODULUL COMUN ȘI AL TREILEA TABEL (29 septembrie 2026) — țară ↔ capitală

Două faze, în ordine. **Faza 1: modulul comun al fabricii**, fără nicio schimbare
de conținut, cu hash-urile ca dovadă. **Faza 2: al treilea tabel**, țara și
capitala ei, pentru domeniul `geografie`, construit pe modul — **140 de țări,
251 de întrebări, toate în ciornă.**

Momentul a fost stabilit de mine însumi, la sesiunea trecută: „al treilea tabel =
modulul comun. Nu mai devreme: două exemple arată ce se repetă, unul singur ar fi
ghicit." Ăsta e al treilea tabel.

---

### FAZA 1 — `tools/fabrica/comun.py`

Regula după care s-a decis ce se mută: **se mută ce e identic, sau
identic-cu-un-parametru; rămâne pe loc orice judecată despre un tabel anume.**
Care entități sunt cultură generală, ce nivel are fiecare, cum se punctează
distractorii, ce anume e o dublură — alea sunt DECIZII, iar o decizie mutată
într-un modul „comun" devine, în șase luni, un `if tabel == "opere"`, adică
duplicarea de azi, doar ascunsă.

**Dovada că cele șapte funcții mutate erau într-adevăr aceleași** s-a luat înainte
de mutare, cu un script care le-a extras din amândouă fișierele, a scos
docstring-urile și comentariile, și a comparat codul rămas:

```
scrie_lista              elemente:27 opere:28   COD IDENTIC
verifica_inapoi          elemente:24 opere:19   COD IDENTIC
citeste_dosarul_generat  elemente:17 opere:27   COD IDENTIC
mostre                   elemente:16 opere:16   COD IDENTIC
contactul                elemente:31 opere:28   COD IDENTIC
zar                      elemente:17 opere:15   COD IDENTIC
ca_json                  elemente: 4 opere: 4   COD IDENTIC
```

Diferența de lungime e numai comentariu: `zar` avea hidrogenul ca exemplu într-un
fișier și pe Shakespeare în celălalt. Bine de știut că *asta* era toată diferența,
fiindcă înseamnă că extragerea e o mutare, nu o rescriere.

### Cele două bucăți care au cerut gândire, nu mutare

**1. „Exact una din patru e corectă" nu se putea muta ca funcție.** În `opere.py`
știa despre `autori_wd` și despre titluri. Ce e cu adevărat comun nu e funcția, e
**forma verificării**: numără câte dintre cele patru variante sunt corecte după
datele complete de la Wikidata, cere exact una, cere să fie cea marcată, adună
toate problemele, oprește tot. Deci în comun a intrat

```python
def verifica_un_singur_raspuns(intrebari, este_corect):
```

iar fiecare tabel scrie trei rânduri de predicat. Diferența dintre „a extrage o
funcție" și „a extrage forma unei verificări" e că a doua supraviețuiește la al
patrulea tabel.

**Și a plătit imediat: elementele n-aveau verificarea asta.** Se sprijineau doar
pe `verifica_relatia` (relația e unu-la-unu) plus pe cele patru variante
distincte — care apără PRESUPUNEREA, nu REZULTATUL. Acum o au, și a trecut din
prima, fără să schimbe niciun octet. Exact ce ar trebui să facă un modul comun: o
plasă scrisă pentru un tabel ajunge la toate.

**2. Dublurile.** Potrivirea rămâne a tabelului (titluri între ghilimele la opere,
cuvinte întregi la elemente), dar comparația declarate ↔ găsite ↔ fantome e
aceeași peste tot. La mutare, `compara_dublurile` a luat forma mai bună din cele
două: mesajul din `opere.py`, care tipărește rândurile **gata de copiat** în tabel.
Nu e cosmetică — la opere ieșiseră 16 deodată, iar o listă din care trebuie să
retipărești 16 rânduri e o listă la care faci o greșeală de tipar.

### Coloanele elementelor au ieșit din cod

`ALESE`, 70 de tuple `(simbol, nume, genitiv, nivel)`, → `tools/fabrica/date/elemente.json`,
un obiect pe rând, ca la opere și la capitale.

Nu din simetrie: e ce face ca **`ciorna` să însemne același lucru la toate trei
tabelele.** Un câmp de date nu poate trăi într-o listă de tuple. Azi elementele
n-au nicio ciornă, dar mecanismul e acolo și e același.

`DIN_LATINA` a **rămas în cod**, împreună cu `DUBLURI`. Amândouă nu sunt coloane,
sunt **reguli despre tabel**: `DIN_LATINA` există ca să verifice coloana `nivel`,
iar o regulă și verificarea ei stau în același loc.

Ordinea rândurilor din JSON e exact cea din `ALESE`, deși nimic nu depinde de ea
(egalitățile se rup pe `zar`, nu pe poziție). Motivul e despre probă, nu despre
cod: dacă schimbam și ordinea, un hash diferit n-ar mai fi spus *ce* s-a rupt.

### Dovada: hash identic, octet cu octet

```
                            înainte            după
elemente_fapte.json        68930ada3f7d69d8   68930ada3f7d69d8   ✔
elemente_intrebari.json    01bc69eebbbfd31f   01bc69eebbbfd31f   ✔
opere_fapte.json           55bfd5fdf15dc7d8   55bfd5fdf15dc7d8   ✔
opere_intrebari.json       bc0cc23492fd5279   bc0cc23492fd5279   ✔
```

`git status` nu arată nicio modificare sub `data/`. Toate comenzile probate pe
amândouă scripturile: `--masoara`, probă uscată, `--scrie`, `--propune`.

**Ce S-A schimbat, declarat dinainte:** raportul de pe ecran al lui `elemente.py`.
`grila` unificată e cea din `opere.py` (are rândul de total), iar `cat_din_lupta`
e una singură, cu eticheta ca parametru. Alternativa ar fi fost să păstrez două
`grila` aproape identice — adică să nu fac refactorul.

Bilanț de linii: −745 din cele două scripturi, +815 în `comun.py`. Aproape
neutru la număr, dar diferența e că cele 815 sunt scrise o dată, citite de trei
scripturi, și că jumătate din ele sunt docstring-uri care spun DE CE.

---

### FAZA 2 — `tools/fabrica/capitale.py`

**Rezultat: 251 de întrebări din 140 de țări, în ambele sensuri, toate în ciornă.**
Zero în joc până la confirmare, ca la opere.

### Cine intră: stat membru ONU, nu clasa „stat suveran"

Decizia e a ta, și s-a dovedit mai bună decât planul meu. `P463 = Q1065`
(„membru al ONU") cu declarația fără dată de sfârșit.

Rostul: **„suveran" e o judecată, apartenența la ONU e o chestiune de fapt.** Pe
Wikidata, clasa „stat suveran" ar fi adus Kosovo, Taiwan, Palestina, Abhazia,
Sahara Occidentală, Ciprul de Nord — fiecare o decizie pe care ar fi trebuit s-o
apăr, într-o dezbatere în care un joc de brain-training n-are ce căuta. Cu ONU,
statele cu recunoaștere parțială ies **de la sine**, nu pe o listă de excluderi.

Prețul, mic și cinstit plătit: Vaticanul și Palestina sunt observatori, nu membri,
deci nu intră — iar Vaticanul chiar e cultură generală.

### Cea mai folositoare lecție: un CÂMP LIPSĂ nu e un „NU"

Criteriul de mai sus, singur, a dat **203 țări, nu 193.**

Cele în plus sunt state ÎNCHEIATE a căror apartenență la ONU pur și simplu n-are
dată de sfârșit scrisă în Wikidata: Republica Populară Mongolă, Regatul Nepalului,
Statul Islamic Afganistan, Republica Democratică Somalia, Republica Afganistan,
Republica Congo (cea din 1960), Regatul Laosului, Republica Populară Mozambic.

`FILTER NOT EXISTS { pq:P582 }` înseamnă **„nu scrie nicăieri că s-a terminat"**,
nu „nu s-a terminat". Pe o bază editată de oameni, cele două nu sunt același
lucru, iar diferența e exact conținutul greșit. Aceeași formă ca la ediții la
opere: cifra (sau lipsa ei) separă ceva, dar nu ce credeai.

Leacul, măsurat înainte de a fi adoptat: două semne în plus, `P576` (data
desființării) și „instanță de țară istorică". **Cad pe EXACT aceleași 8
entități**, deci sunt de acord între ele, și niciuna dintre cele 8 n-are cod ISO,
deci nu se pierde nimic. 203 − 8 = 195.

### Codul ISO se raportează, nu se cere — și de ce, în trei rânduri: Danemarca

Prima idee a fost să cer `P297` (ISO 3166-1 alpha-2) ca filtru de intrare. E
frumos: îl au 192 din 203, și cele 11 care nu-l au sunt exact suspecții. Măsurat,
zero coduri duble.

**Dar pierde Danemarca.** Membrul ONU e „Regatul Danemarcei" (`Q756617`), care
n-are cod ISO; codul DK stă pe „Danemarca" (`Q35`), care nu e membru. Aceeași
poveste la Țările de Jos, doar că acolo codul stă pe Regat (`Q29999`, cu NL) — și
de-aia Țările de Jos n-au apărut niciodată în lista celor cu capitală multiplă:
entitatea-Regat are doar Amsterdam.

Deci ISO-ul e **raportat, nu cerut**: absența lui înseamnă doar „țara asta nu va
putea avea hartă la pasul 13", ceea ce nu e un motiv să nu fie întrebată. Cele
două entități fără ISO care mai rămân după filtrul de stat istoric (`Q17765809` și
„Regatul Coroanei", cu 2 ediții Wikipedia) n-au nici etichetă română, iar numele e
o afirmație verificată — deci nu pot intra în tăcere.

Ambele intrate în tabel cu `tara_de_mana`: „Danemarca" în loc de „Regatul
Danemarcei", „Țările de Jos" în loc de „Regatul Țărilor de Jos".

### Capitala actuală: prin nodul de declarație, nu prin scurtătură

Capitalele se cer prin `p:P36` → `ps:P36`, nu prin `wdt:P36`.

„Fără dată de sfârșit" e o însușire a **declarației**, nu a valorii. Cu `wdt:P36`,
Kazahstanul ar fi venit cu Astana ȘI cu Almatî, iar scriptul n-ar fi avut de unde
să știe care e care. Cu nodul de declarație, `pq:P582` se poate întreba, iar
fostele capitale cad singure.

Măsurat: **187 de țări au o capitală actuală, 7 au două, una are trei.**

```
Africa de Sud   Pretoria, Cape Town, Bloemfontein
Benin           Cotonou, Porto Novo
Bolivia         La Paz, Sucre
Eswatini        Mbabane, Lobamba
Malaezia        Kuala Lumpur, Putrajaya
Pakistan        Islamabad, Rawalpindi
Sri Lanka       Sri Jayewardanapura Kotte, Colombo
Yemen           Sana'a, Aden
```

**Scriptul nu alege niciodată prima.** Se oprește și le tipărește, fiindcă „mai
multe capitale actuale" nu e o eroare în date, e un fapt despre țară. Ieșirea e a
omului: ori scoți rândul, ori pui `"capitala_qid"` și alegerea e scrisă, deci se
vede în diff. Probat pe Bolivia: cu `"capitala_qid": "Q2907"` intră cu Sucre, iar
La Paz nu apare nicăieri.

Niciuna din cele 8 nu e în ciorna de azi.

### Gramatica: iar de mână, iar o coloană

Sensul direct cere genitivul („Care este capitala **Franței**?"), iar el nu se
calculează: Franței, Japoniei, Egiptului, Statelor Unite ale Americii, Țărilor de
Jos, Coastei de Fildeș. La elemente erau substantive comune cu vreo trei tipare;
aici sunt nume proprii, fiecare cu forma lui. 140 de genitive propuse de mine, de
verificat de tine.

Sensul invers **nu cere nicio declinare**: „Canberra este capitala cărei țări?"
— „cărei țări" ține toată gramatica, iar capitala stă la nominativ.

Relația e unu-la-unu după filtrare, deci **ambele sensuri sunt per țară**. La
opere, sensul invers a trebuit să fie per autor, ca să nu iasă întrebări cu text
repetat; aici problema nu poate apărea, și tocmai filtrul de capitală actuală e ce
face relația unu-la-unu în primul rând.

### Strictețea a prins două lucruri la prima rulare

Oslo (`Q585`) și Abuja (`Q3787`) **n-au etichetă română în Wikidata.** Numele e
același în română, deci `"capitala_de_mana": true` e marcajul potrivit — și, ca la
`titlu_de_mana` de la opere, rândurile astea se **tipăresc la fiecare rulare**, cu
ce spune Wikidata alături. Un câmp care ocolește o verificare trebuie să fie
zgomotos, altfel devine în trei luni felul comod de a face o greșeală de tipar să
dispară.

### Întrebările care se răspund singure: 13, și o regulă venită din mostre

Prima regulă, cea din plan: **conținere, în ambele direcții**, fără diacritice și
fără majuscule. Kuweit → Orașul Kuweit, Mexic → Ciudad de México, Tunisia → Tunis,
Algeria → Alger, Monaco, Singapore, Luxemburg, San Marino, Andorra, Chile,
Guatemala, Panama. **12 sărite.**

A doua regulă **n-a fost planificată, a ieșit din mostre**: „San Salvador este
capitala cărei țări?" cu răspunsul „El Salvador" printre Honduras, Nicaragua și
Haiti. Niciunul nu-l conține pe celălalt, deci prima regulă o rata — dar cuvântul
„Salvador" **e chiar răspunsul, scris în întrebare.**

Deci: **un cuvânt întreg împărțit, de cel puțin 4 litere.** Măsurată pe tabelul
întreg, prinde **exact un caz nou și niciun fals pozitiv**. Sub 4 litere,
potrivirile devin articole („de", „la", „san"), pe care multe capitale le au fără
să dea nimic de gol.

Și cele două se completează, niciuna nu o înlocuiește: Mexic ↔ Ciudad de México,
Tunisia ↔ Tunis și Algeria ↔ Alger **nu împart niciun cuvânt întreg**, deci prima
rămâne necesară.

Ce nu prinde niciuna: **Brazilia → Brasília**, unde ochiul îl vede pe loc. Pentru
alea e lista **„de citit cu ochiul"** (asemănare `difflib`, nu oprește nimic): azi
arată Brazilia/Brasília, Kazahstan/Astana, Maldive/Malé, Nicaragua/Managua. Prima
e reală, celelalte trei sunt zgomot — și e bine așa, fiindcă **lista aia a
schimbat o regulă**: El Salvador a ieșit din ea. O listă de citit care schimbă o
regulă și-a plătit locul.

Perechile sărite **rămân în tabel** și rămân distractori. Nu generează întrebări,
dar Luxemburg și Monaco sunt butoane bune la o întrebare despre Belgia.

### Nivelul: a treia măsurătoare, al treilea eșec — și era de așteptat

```
toate cele 195 de țări:   min 2   median 319   maxim 428
decile:  2  265  287  301  309  319  331  348  361  387
```

Decila 1 e „Regatul Coroanei" cu 2 ediții; între țările adevărate banda e
**265–387, adică vreo 1,5×** — exact cifra de la elemente, și din același motiv:
fiecare stat membru ONU are articol pe fiecare wiki, fiindcă boții l-au scris.

Față de coloana de mână (20 / 70 / 50):

| nivel | țări | min | median | maxim |
|---|---|---|---|---|
| I | 20 | 348 | 391 | 428 |
| II | 70 | 107 | 336 | 425 |
| III | 50 | 235 | 302 | 349 |

Medianele scad, deci cifra nu e pe dos. Dar suprapunerea e aproape totală, iar
`min = 107` la nivelul II e Regatul Țărilor de Jos, care n-are legătură cu
dificultatea.

**Deci nivelul rămâne coloană de mână**, a treia oară din trei. Meritul
măsurătorii nu e că a găsit ceva, e că știu *cât* de bună ar fi automatizarea, în
loc să presupun.

### Distractorii: punctajul, și cifra pe care am ales s-o NUMĂR în loc s-o repar

| | |
|---|---|
| **+100** | același continent (`P30`) |
| **+40** | vecin de graniță (`P47`) |
| **+10 / +5** | același nivel / nivel vecin |

O singură funcție pentru ambele sensuri, spre deosebire de elemente, unde
punctajul depindea de sens: aici opțiunile sunt mereu de același fel ca entitatea
întrebată (capitale lângă capitale, țări lângă țări), iar toate însușirile
punctate stau pe **pereche**, nu pe una din cele două fețe.

Ce ies: „Care este capitala Elveției? Viena / Berlin / Vaduz / **Berna**",
„Skopje este capitala cărei țări? Albania / Serbia / Grecia / **Macedonia de
Nord**". Banda de nivel (±1) e aceeași plasă ca la celelalte două tabele.

**Slăbiciunea, găsită în mostre și apoi măsurată.** „Care este capitala Libanului?
Damasc / **Beirut** / Pyongyang / New Delhi" — continentul e prea gros pentru
Asia, care ține Libanul, Coreea de Nord și India în aceeași cutie. Măsurat cu
coordonatele (`P625`): **15 din 251 de întrebări (6%) au un distractor la peste
5000 km.**

O bandă de distanță ar repara-o și ar fi ieftină. **N-am scris-o**, fiindcă
măsurătoarea arată că nu e în principal o problemă de punctaj: cele trei cele mai
rele sunt Australia și Noua Zeelandă, singurele două țări din Oceania din tabel —
pentru ele **nu EXISTĂ** un distractor apropiat, oricât de fin ar fi punctajul.
E exact forma lecției de la opere, unde 11 din 188 de întrebări n-aveau niciun
distractor de aceeași limbă fiindcă autorul era singur pe limba lui: **leacul e un
rând în plus în tabel, nu cod.**

Deci cifra a intrat în raport, sub ochi, ca `fara_frate_de_limba`. Dacă după
revizuirea tabelului rămâne pe la 6% și restul nu mai e Oceania, ATUNCI banda de
distanță merită scrisă — cu o măsurătoare care s-o ceară, nu cu o presimțire.

Și un lucru pe care măsurătoarea NU-l vede, ca să nu fie citită ca mai tare decât
e: distanța se ia între **centrele țărilor**, nu între capitale. Centrul Rusiei e
în Siberia, deci „Care este capitala Rusiei? Beijing / Tokyo / **Moscova** / Kiev"
nu apare în listă, deși Moscova e la 5800 km de Beijing.

### Garda pe care am păstrat-o deși pornește de 0 ori

„Nicio capitală a țării întrebate nu are voie ca distractor", pe **QID-ul
capitalei**, nu pe numele afișat. Diferența contează exact când o țară are mai
multe capitale actuale: a doua n-ar fi un distractor nefericit, ar fi **un al
doilea răspuns corect**.

Măsurat: pornește de **0 ori din 16 256 de perechi** de candidați, fiindcă niciuna
dintre cele 8 țări cu mai multe capitale nu e în ciorna de azi.

Și totuși rămâne — spre deosebire de garda de limbă de la opere, care a fost
**ștearsă** tot după ce s-a măsurat că pornește de 0 ori. Diferența e ce apără:
aceea era o euristică de calitate (un distractor mai puțin potrivit), asta e o
**gardă de corectitudine** (o întrebare cu două răspunsuri bune). O gardă care
costă o intersecție de mulțimi și previne un răspuns greșit nu are nevoie să
pornească des ca să merite. Probată pe Bolivia, cu `capitala_qid` pus.

### Israelul, exclus de mână, cu motivul scris lângă `DUBLURI`

```python
EXCLUSE = {
	"Q801": "Israel — capitala e contestată internațional (Ierusalim / Tel Aviv). "
	        "Un joc de învățare n-are voie să prezinte un răspuns disputat ca pe un "
	        "fapt simplu, cu un singur buton verde.",
}
```

Stă lângă `DUBLURI` dinadins, ca să se vadă că e o **decizie, nu o scăpare**: un
rând lipsă dintr-un tabel de 140 nu se observă niciodată, iar o excludere scrisă,
cu motivul ei, se citește la fiecare deschidere a fișierului.

Și **oprește**: dacă `Q801` apare totuși în `tari.json`, scriptul se opune cu
motivul întreg. Altfel excluderea ar fi fost o părere într-un comentariu, iar
Israelul ar fi reintrat în ziua în care copiez un rând din propuneri fără să mă
uit. Probat.

### `cod_iso_de_mana`: un câmp care ADUCE o valoare, nu unul care ocolește o verificare

Măsurat: din cele 140 de țări, **una singură n-are cod ISO în Wikidata** —
Danemarca, din motivul de mai sus (codul DK stă pe `Q35`, membrul ONU e `Q756617`).
Deci `"cod_iso_de_mana": "DK"` se scrie pe un singur rând.

**De ce ține o VALOARE, nu un `true`**, spre deosebire de `tara_de_mana` și
`capitala_de_mana`. Alea sunt marcaje care spun „nu verifica afirmația mea
împotriva etichetei": valoarea există deja în rând, iar marcajul doar oprește
comparația. Aici Wikidata nu dă NIMIC de comparat, deci un `true` n-ar avea ce să
ocolească — câmpul trebuie să aducă el codul.

Restul urmează modelul: se tipărește la fiecare rulare, alături de ce spune
Wikidata, fiindcă un câmp pus de mână trebuie să fie ZGOMOTOS.

```
  ── PUSE DE MÂNĂ (4 rânduri) ──
    țară      Danemarca                   Wikidata: Regatul Danemarcei
    capitală  Abuja                       Wikidata: Abuja
    capitală  Oslo                        Wikidata: Oslo
    țară      Țările de Jos               Wikidata: Regatul Țărilor de Jos
    cod ISO   DK   (Danemarca           ) Wikidata: — (fără cod)
```

Și o listă nouă, **FĂRĂ COD ISO**, tot la fiecare rulare: țările care așteaptă
un cod. Nu oprește nimic — codul e pentru hărțile de la pasul 13, iar o țară fără
hartă e tot o țară bună de întrebat — dar se vede, ca lista să se scurteze, nu să
se uite.

**Două opriri, și a doua e cea care contă peste șase luni:**

1. Un cod care nu arată a cod (două litere mari) oprește. `"dk"` sau `"DNK"` ar
   ajunge tăcut în fapt, iar desenatorul de hărți ar căuta un contur care nu
   există — eroarea ar apărea la o întrebare, nu aici.
2. Un cod scris de mână pentru care Wikidata a ÎNCEPUT să dea unul oprește și el,
   **chiar dacă cele două coincid.** E aceeași regulă ca „fantomele" din `DUBLURI`:
   o declarație care nu mai e necesară e la fel de rea ca una lipsă, doar mai
   tăcută. Fără ea, `tari.json` ar strânge în câteva luni coduri de mână pe care
   nimeni nu le mai folosește, iar ziua în care unul ar contrazice Wikidata n-ar
   mai fi de găsit.

Toate trei drumurile probate:

| ce am pus | ce a ieșit |
|---|---|
| `"cod_iso_de_mana": "DK"` pe Danemarca | tipărit în „PUSE DE MÂNĂ", cu „Wikidata: — (fără cod)" alături; faptul `wd:Q756617` iese cu `"cod_iso": "DK"` |
| `"dnk"` | OPRIT — „nu arată a cod ISO 3166-1 alpha-2" |
| `"FR"` pe Franța, unde Wikidata dă deja FR | OPRIT — „Wikidata dă acum codul 'FR', deci cod_iso_de_mana nu mai e necesar" |

Cu codul completat, **toate cele 127 de fapte au `cod_iso`**, de la 126.

### Capitalele mutate recent: de citit cu ochiul, fără oprire

Orice capitală a cărei declarație are dată de început după 2000 se tipărește
separat. Azi: **Myanmar → Naypyidaw, din 2005.**

Indonezia (Jakarta / Nusantara) **nu apare**, fiindcă Wikidata încă n-are
Nusantara ca declarație de capitală fără dată de sfârșit — deci pentru joc
capitala Indoneziei e Jakarta. Rămâne rândul pe care îl verifici tu de mână
înainte să-l confirmi.

O oprire aici ar fi fost greșită: m-ar fi obligat să declar o excepție pentru
fiecare mutare, iar excepțiile declarate mecanic nu se mai citesc.

### Dublurile cu fișierul scris de mână: 3, toate de sens direct

```
cere_capitala  Portugalia   ← mana:0009
cere_capitala  Australia    ← mana:0057
cere_capitala  Kazahstan    ← mana:0101
```

Se caută doar prin întrebările de mână care conțin cuvântul „capital", ca la
elemente cu „simbol": altfel „Care este cel mai mare oraș al României?" ar fi
părut dublură, deși e **altă relație**, chiar dacă răspunsul e tot Bucureștiul.

Se blochează **doar sensul care se suprapune**, ca la opere: Portugalia rămâne
fără „Care este capitala Portugaliei?", dar păstrează „Lisabona este capitala
cărei țări?".

Și se caută pe **tabelul întreg, ciorne incluse** — lecția de la opere, unde prima
versiune căuta pe lista filtrată și, cu tot tabelul în ciornă, a raportat toate
cele 16 declarate ca fantome.

### Codul ISO în fapt, pentru o zi care n-a venit încă

```json
{"id": "wd:Q142", "nota": "", "surse": ["…"], "verificat": false, "cod_iso": "FR"}
```

**Un fapt pe țară**, folosit de amândouă sensurile: relația e unu-la-unu, deci e
chiar același fapt („capitala Franței e Parisul"). La opere erau două feluri de
fapte fiindcă entitățile celor două sensuri erau două, opera și autorul.

`cod_iso` nu se folosește azi. E cheia pentru **hărțile desenate din date** de la
pasul 13, iar motivul pentru care intră ACUM e că altfel ar fi însemnat, peste
trei luni, o rulare `--reincarca` pe tot tabelul ca să recuperez un câmp care era
deja sub mână. Verificat că nu strică nimic: `_incarca_fapte` din `trivia.gd` cere
doar `id` și `nota`, și ignoră restul câmpurilor.

---

### Verificatorul: o secțiune nouă, probată că pică

`tools/verificari/verifica_trivia.gd` are acum **opt secțiuni**. Cea nouă, a patra:
**RĂSPUNSURILE NU SE AUTODEZVĂLUIE** — niciun răspuns corect nu apare în textul
întrebării lui, peste tot conținutul, inclusiv cel scris de mână.

**Sensibilitatea la majuscule e întreaga subtilitate**, și s-a decis prin
măsurătoare, pe cele 434 de întrebări de dinaintea capitalelor:

| varianta | câte pică |
|---|---|
| conținere brută, fără diacritice | **43** |
| cuvânt întreg, fără majuscule | **1** |
| **cuvânt întreg, cu majuscule** | **0** |

Cele 43 sunt toate de forma „Care este simbolul chimic al carbonului? → C". Alea
**nu sunt cadouri, sunt chiar lecția**: simbolul SE DEDUCE din nume, și exact
de-aia carbonul e la nivelul I. O verificare care le-ar fi tăiat ar fi cerut să
șterg cele mai bune întrebări de nivel I din joc.

Singura care pica la varianta fără majuscule era `Al` din „**al** aluminiului" —
prepoziția românească, nu simbolul. La simboluri, majuscula E parte din simbol, nu
ortografie.

Deci verdictul e strict de la bun început, ca la TEXTELE. Un prag ar fi fost o
poartă deschisă.

**Cum se află dacă un caracter e literă**, fără o listă scrisă de mine: prin
`c.to_lower() != c.to_upper()`. Merge și pentru ș, ț, â — unde o listă scrisă de
mână ar fi uitat pe una din ele.

Probată rupând codul dinadins:

| ce am pus | ce a picat |
|---|---|
| o întrebare „Care este capitala Kuweitului, adică Orașul Kuweit?" | `niciun răspuns în textul întrebării` → PICAT, 1 se autodezvăluie: `wd:Q817:capitala:cere_capitala` („Orașul Kuweit") |

Și de reținut de ce filtrul din `capitale.py` **nu** o înlocuiește: acela compară
numele țării cu numele capitalei și apără doar tabelul lui. Verdictul din
verificator se uită la **textul de pe ecran**, deci apără și întrebările scrise de
mână, și orice tabel viitor.

`forma id-ului` n-a cerut nimic: `wd:Q142:capitala:cere_capitala` trece prin
regula scrisă pentru `wd:Q897:simbol:cere_nume`. **A doua dată** când o regulă
scrisă pentru un tabel ține la următorul fără nicio atingere.

---

### Cele 15 mostre (sămânța 4242)

Puse în răspunsul sesiunii. Câteva, ca reper pentru ce se simte bine:

```
Care este capitala Elveției?      Viena / Berlin / Vaduz / BERNA
Skopje este capitala cărei țări?  Albania / Serbia / Grecia / MACEDONIA DE NORD
Naypyidaw este capitala cărei?    MYANMAR / Bangladesh / Laos / Thailanda
Juba este capitala cărei țări?    SUDANUL DE SUD / Sudan / Uganda / RD Congo
Care este capitala Guineei?       Bamako / Dakar / Yamoussoukro / CONAKRY
```

### Ce s-a măsurat la final

```
în tabel:   140 țări  (nivel I: 20, II: 70, III: 50) — TOATE ciorne
generate:   251 întrebări (124 directe, 127 inverse), 127 fapte
sărite:     13 (se răspund singure)
dubluri:    3 cu fișierul de mână
scrise:     0 — perechea din data/trivia_gen/ e goală, ca la opere în prima zi
```

Grila, cu ciornele confirmate ipotetic, arată geografia la **277 de întrebări**
(de la 24) și tot conținutul la **687** (de la 434). Cifra de urmărit:
**41–45% din întrebările de luptă ar fi fabricate**, de la 27–30%. Pârghia rămâne
lățimea conținutului scris de mână, nu o treaptă de alegere în plus.

### Verificat

- cele patru hash-uri din faza 1, identice octet cu octet; `git status` curat sub `data/`;
- toate comenzile, pe toate trei tabelele: `--masoara`, probă uscată, `--scrie`, `--propune`;
- `--masoara`: 195 de țări de azi (din 203 aduse), 194 cu etichetă română, 192 cu ISO, distribuția edițiilor;
- probă uscată: 251 de întrebări, „exact una din patru e corectă" verificat pe toate, pe mulțimea completă de capitale actuale;
- `--scrie`: două fișiere goale (totul e ciornă), JSON valid citit înapoi, 140 de ciorne raportate;
- trei opriri probate rupând datele dinadins: Israel în tabel, Bolivia fără `capitala_qid`, ieșirea prin `capitala_qid`;
- verificarea headless: **TOTUL E BUN**, 18 verdicte, 0 picate;
- verdictul nou, probat că pică.

### Ce NU s-a făcut

- **Nimic n-a intrat în joc.** Toate cele 140 de rânduri sunt ciorne; jocul are tot 434 de întrebări.
- **Nicio notă.** Cele 127 de fapte ar avea `nota: ""`, plus cele 190 de la literatură și 70 de la elemente.
- **Nicio partidă jucată** cu conținutul nou.
- **Banda de distanță** la distractori — măsurată, amânată cu motiv (vezi mai sus).
- **Cele 28 de ciorne de la opere** — încă acolo, neatinse.

### Ce urmează, concret

1. **Confirmarea celor 140 de rânduri**, cu ochiul: genitivele întâi (alea sunt
   ale mele, nu ale Wikidatei), apoi nivelurile. Aceiași pași ca la opere: șterge
   `"ciorna": true`, rulează `--scrie`, verifică headless.
   **Verifică fișierul cu un script mic înainte de `--scrie`**, nu doar cu ochiul
   pe diff — lecția de la „Divina Comedie", care a pierdut și `"nivel": 2` odată cu
   marcajul.
2. **Codul ISO al Danemarcei**: `"cod_iso_de_mana": "DK"` pe rândul `Q756617`.
   E singurul din 140. Lista se tipărește la fiecare rulare, sub „FĂRĂ COD ISO".
3. **Indonezia**, de verificat de mână (Jakarta / Nusantara).
4. **Un rând sau două din Oceania**, dacă cifra de 6% deranjează. Rezolvă mai mult
   decât orice cod.
5. **Cele 8 țări cu capitală multiplă**, dacă le vrei: `capitala_qid` e acolo și e
   probat.

### Fișiere

Nou: `tools/fabrica/comun.py`, `tools/fabrica/capitale.py`,
`tools/fabrica/date/elemente.json`, `tools/fabrica/date/tari.json`,
`tools/fabrica/date/tari_propuse.json`,
`tools/fabrica/cache/wikidata_capitale.json`,
`data/trivia_gen/capitale_intrebari.json`, `data/trivia_gen/capitale_fapte.json`.
Atinse: `tools/fabrica/elemente.py` (−651 de linii: modulul comun, coloanele în
date, verificarea „exact una din patru"), `tools/fabrica/opere.py` (−698 de linii:
modulul comun), `tools/verificari/verifica_trivia.gd` (secțiunea RĂSPUNSURILE,
renumerotare), `docs/progres.md`, `CLAUDE.md` (două decizii noi).

---

## AL DOILEA TABEL (29 septembrie 2026) — operă → autor, și șase lecții din date

Al doilea tabel al fabricii: **operele literare și autorii lor**, pentru domeniul
`literatura`. Rezultat: **188 de întrebări din 163 de opere și 41 de autori**, în
ambele sensuri — plus `data/trivia_gen/`, dosarul pe care încărcătorul îl citește
întreg, plus mecanismul de **ciorne**, care ține conținutul nou afară din joc
până îl confirm eu, rând cu rând.

Scris inițial cu toate cele 163 de rânduri ca ciorne — nimic nu intra în joc
până nu le confirmam cu ochiul. **Confirmarea s-a făcut chiar în aceeași zi**:
135 din 163 au trecut, 28 au rămas ciorne pentru altă dată. Vezi „CONFIRMAREA",
mai jos, pentru ce s-a scris efectiv și ce a picat la prima trecere.

### Ce e altfel față de elemente, și de ce

Nu din gust — din relația însăși.

**1. Relația e mulți-la-unu, deci sensurile nu sunt simetrice.** O operă are un
autor; un autor are mai multe opere. Sensul direct („Cine a scris «Ion»?") e o
întrebare **per operă**. Sensul invers nu poate fi: Shakespeare cu 10 opere alese
ar da **10 întrebări cu exact același text** și 10 răspunsuri corecte diferite.
Măsurat pe tabelul de azi: per operă ar fi ieșit 163 de întrebări inverse cu doar
**41 de texte distincte**, dintre care 36 repetate. Nu sunt greșite — dar în joc
se văd ca o repetiție, iar **sacul nu te apără**: pentru el sunt `id`-uri
diferite. Deci sensul invers e o întrebare **per AUTOR**, cu răspunsul pus pe
opera lui cea mai recognoscibilă și cu toate celelalte opere ale lui scoase din
distractori.

| | entitate | `id` | câte |
|---|---|---|---|
| `cere_autor` | opera | `wd:Q12730777:autor:cere_autor` | 148 |
| `cere_opera` | autorul | `wd:Q462220:autor:cere_opera` | 40 |

**2. Zero coloane de gramatică.** La elemente au fost 70 de genitive scrise de
mână (`aur→aurului`, `platină→platinei`). Aici titlul stă între ghilimele,
neflexionat, iar „Care dintre aceste opere a fost **scrisă** de X?" are subiectul
„care (dintre opere)", mereu feminin singular. Relația asta pur și simplu nu cere
gramatică.

**3. Nu se spune felul operei** („Cine a scris **romanul** «Ion»?"), deși sună
mai bine și deși întrebările mele de mână o fac. Ar trebui să vină din `P31`, iar
`P31` măsurat arată de ce nu: 2044 „operă literară", 300 „ediție", 180 „lucrare
scrisă", 100 „novella in the Decameron", 66 „capitol"… plus **123 de opere cu mai
multe tipuri deodată** și 11 fără niciunul. Un cuvânt de fel greșit nu e o
stângăcie, e o **greșeală de fapt** predată de un joc de învățare.

**4. QID-urile nu se scriu de mână, dar cheia nu mai e citibilă.** La elemente
cheia era simbolul, tocmai ca să nu scrii 70 de `Q897`. Titlurile nu sunt unice
în Wikidata, deci cheia e QID-ul — dar nu-l scriu eu: îl scrie `--propune`, eu
copiez rândul. `titlu` și `autor_nume` rămân **afirmații verificate** la fiecare
rulare împotriva etichetei române.

### Cele patru surprize din date

Toate patru au oprit scriptul sau au stricat conținutul înainte să le găsesc.
Merită scrise, fiindcă niciuna nu se putea ghici.

**a) Wikidata mută etichetele în limba `mul`.** Victor Hugo n-are etichetă „en"
și n-are etichetă „ro": are una singură, `mul` — limba specială pentru numele
care se scriu la fel peste tot. Scriptul a răspuns „Victor Hugo: niciun om cu
numele ăsta". Deci `mul` nu e o lipsă, e **afirmația explicită** că eticheta e
aceeași și în română, și se ia ca atare (Shakespeare la fel).

**b) Homer nu e `P31 = om`.** E `Q21070568`, „om care poate fi ficțional". Ai
spus-o singur când ai adăugat numele: atribuirea tradițională se spune în notă,
nu în întrebare. Wikidata e de acord, și de-aia filtrul acceptă acum amândouă
felurile de om.

**c) Autorul „necunoscut" vine ca nod anonim.** O operă poate avea la `P50` o
valoare de tip „există, dar nu se știe care", iar SPARQL o întoarce ca
`…/.well-known/genid/1986ff00…`. Scriptul s-a oprit cu „URI pe care nu-l
recunosc" — cel mai bun lucru care se putea întâmpla, fiindcă **exact ăsta e
cazul operelor anonime**, pe care regula le scoate. Acum nodul anonim se numără
ca autor, deci o carte scrisă de cineva cunoscut împreună cu un anonim are doi
autori și pică regula unui singur autor, cum se cuvine.

**d) „Ion" al lui Rebreanu e catalogat ca EDIȚIE, nu ca operă.** Prima versiune
avea `FILTER NOT EXISTS { ?opera wdt:P31 wd:Q3331189 }`, ca să nu apară „Ion
(ediția din 1920)" ca operă separată. Filtrul a șters „Ion" **cu totul**:
articolul de pe ro.wikipedia e legat de un item catalogat ca ediție
(`Q12730777`), iar itemul-operă ori nu există, ori n-are autor. Nu e o excepție —
multe articole de literatură română de pe ro.wikipedia stau așa. Regula corectă:
o ediție se scoate **doar dacă e ediția unei opere pe care o avem deja** (`P629`
duce la un QID din mulțime). O ediție care stă singură e singura reprezentare a
cărții.

### Cea mai importantă: edițiile Wikipedia măsoară răspândirea, nu celebritatea

Pragul de propunere a fost întâi **5 ediții Wikipedia**. Cu el, cei 41 de autori
au dat 459 de propuneri, din care literatura română a rămas cu **nouă**. „Ion",
„Amintiri din copilărie", „Moromeții", tot Arghezi, tot Blaga, tot Coșbuc, tot
Călinescu, tot Stănescu — dispăruseră. Nu fiindcă ar fi obscure: un roman
românesc are articol în două-trei ediții Wikipedia, iar „Inferno, cântul VIII"
are în șase.

**`wikibase:sitelinks` măsoară răspândirea internațională, nu celebritatea în
România.** Pentru un joc scris în română, un prag pe el nu e o curățenie, e o
ștergere — și taie exact conținutul care contează cel mai mult. Aceeași formă ca
lecția de la elemente (unde cifra separa „real" de „ipotetic", nu „ușor" de
„greu"): **cifra separă ceva, dar nu ce credeai.**

Pragul a rămas la 1 („există măcar un articol undeva"). Tăierea o face
`CATE_PROPUNERI`, care ia cele mai cunoscute 20 ale **fiecărui** autor — deci nu
compară niciodată un poet român cu Shakespeare.

### Nivelul: măsurat, și de data asta cifra chiar spune ceva

Măsurătoarea cerută înainte de metodă, în două trepte.

**Distribuția, pe toate cele 2969 de opere aduse:** min 1, median 2, maxim 181;
decila 1 = 1, decila 9 = 23. **O bandă de 23×**, față de ~1,5× la elemente. Deci
aici cifra chiar separă ceva, fiindcă nu există boți care să genereze un articol
pe operă pe fiecare wiki mic.

**Față de nivelul pus de mână, pe cele 163 alese:**

| nivel | opere | min | median | maxim |
|---|---|---|---|---|
| I | 22 | 4 | 99 | 181 |
| II | 42 | 1 | 68 | 131 |
| III | 99 | 1 | 25 | 72 |

Ordinea e corectă — medianele scad frumos. Dar suprapunerea e mare, și **cel mai
bun prag automat posibil** (căutat exhaustiv, deci o limită superioară, nu o
încercare) **ar greși 36 din 163, adică 22%**. Pentru comparație, a ghici mereu
nivelul cel mai des greșește 39%. Deci cifra aduce ceva, dar nu destul: un sfert
din tabel ar fi etichetat greșit, iar `min = 1` la nivelurile I și II sunt exact
operele românești.

**Concluzie: nivelul rămâne coloană de mână**, dar acum știm *cât* de bună ar fi
automatizarea, nu doar că n-a mers.

### Distractorii: regula, și cele trei lucruri care au stricat-o

Punctajul, pentru „la «Ion», alți romancieri români din aceeași perioadă, nu
Shakespeare":

| | |
|---|---|
| **+100** | aceeași limbă |
| **+60 / +30 / +15 / +8** | la cel mult 50 / 100 / 200 / 400 de ani distanță |
| **+10 / +5** | același nivel / nivel vecin |

Treptele largi (200, 400) nu spun că 400 de ani e „aceeași perioadă" — ele **rup
egalitățile cu sens**. Fără ele, la „Cine a scris «Decameronul»?" al treilea
distractor ieșea Goethe, ales de zar dintr-o duzină de autori cu același punctaj.
Cu ele, se duce la Molière sau Voltaire.

**Prima greșeală: banda de nivel se centra pe nivelul ÎNTREBĂRII, nu al
OPȚIUNILOR.** „Cine a scris «Jucătorul»?" e o întrebare de nivel III, dar
butoanele arată autori — iar Tolstoi e un autor de nivel I, deci ieșea din bandă.
Rezultatul: singurul alt rus posibil nu putea fi distractor, și în locul lui
veneau doi români. Banda apără o disparitate între **opțiuni**; atunci trebuie
măsurată pe opțiuni.

**A doua: Wikidata are patru cutii pentru engleză.** Dickens și Orwell scriu în
„engleza britanică" (Q7979), Twain în „American English" (Q7976), Shakespeare în
„engleza modernă timpurie" (Q1472196), Austen și Christie în „engleză" (Q1860).
Din cauza asta, „Cine a scris «Persuasiune»?" primea un distractor român. Există
acum un tabel mic, `LIMBI_INRUDITE`, care contopește **variantele aceleiași
limbi** (nu limbi înrudite: portugheza nu devine spaniolă), și `LIMBI_INVENTATE`,
care scoate novlimba, quenya și sindarina — limbile din cărți, nu ale autorilor.

**A treia, mai subtilă: limba unui autor se numără, nu se citește.** `P6886`
(„limba în care scrie") e o listă: Eminescu are acolo germană și română, Twain
engleză și germană, Tolstoi franceză și rusă. Din egalitatea asta ieșea „Cine a
scris «Faust»?" cu Twain printre distractori. Cărțile rezolvă fără să judece
nimeni: Twain are 72 de cărți în engleză și niciuna în germană. Deci limba
autorului e cea a **majorității operelor lui** din Wikidata, cu variantele
contopite întâi; `P6886` și `P103` rămân rezervă. Rezultat: o singură limbă
curată pentru 39 din 41 de autori.

Cei doi rămași sunt **Arghezi și Blaga**: Wikidata n-are pentru ei nici `P6886`,
nici `P103`, iar operele lor n-au limbă. Nu primesc niciodată bonusul de limbă —
și e cinstit așa: mai bine o întrebare fără o însușire decât o însușire
inventată. (În practică epoca îi salvează: „Cine a scris «Testament»?" iese
Coșbuc / Arghezi / Blaga / Stănescu.)

**Garda de limbă a fost scrisă și apoi ștearsă.** Planul avea una: „dacă toți
trei distractorii sunt de altă limbă decât răspunsul, schimbă unul". Spre
deosebire de garda de la elemente (aruncată fiindcă tiparul ducea *departe* de
răspuns), aici tiparul duce *spre* el — dacă la „Baltagul" distractorii sunt
Kafka, Camus și Márquez, alegi singurul român fără să știi nimic. Am scris-o, am
rulat-o: **a pornit de 0 ori din 188.** Nu din noroc — e imposibil să pornească.
Un candidat de aceeași limbă ia cel puțin 105 puncte, unul de altă limbă cel mult
70, deci orice candidat de aceeași limbă e deja în primii trei. Dacă nu e acolo,
nu există. Garda nu repara nimic, doar **dădea impresia că cineva e de pază**.
În locul ei se numără: **11 întrebări din 188 (6%) n-au niciun distractor de
aceeași limbă** — autori singuri pe limba lor în `autori.json`, iar leacul e un
autor în plus acolo, nu cod.

### Ciornele

Un rând din `opere.json` cu `"ciorna": true` e o propunere neconfirmată.

- rularea de probă îl ia în seamă: grilă, mostre, **toate** verificările;
- `--scrie` îl lasă afară și raportează câte au mai rămas.

Amănuntul care nu e evident: **ciornele se scot înainte de construirea
întrebărilor, nu la sfârșit.** Distractorii se aleg dintre operele alese, deci o
ciornă lăsată în listă ar ajunge distractor într-o întrebare scrisă în `data/`.
Raportul de probă și fișierul scris pot să difere — ăsta **e** înțelesul lor:
proba arată ce-ai avea dacă ai confirma tot.

Un caz care a ieșit la iveală chiar în prima rulare cu `--scrie`: **dublurile se
caută pe tabelul întreg, ciorne incluse.** Prima versiune le căuta pe lista
filtrată; cu tot tabelul în ciornă lista era goală, nu se găsea nicio dublură, și
toate cele 16 declarate au ieșit „fantome". Verificarea fantomelor și-a făcut
treaba: a arătat că întrebam lucrul greșit. Suprapunerea cu fișierul de mână e o
însușire a **tabelului**, nu a ce s-a confirmat azi.

### Titlul de mână

Eticheta română de la Wikidata nu e mereu titlul sub care e cunoscută opera.
Atunci rândul primește `"titlu_de_mana": true`, iar titlul e crezut pe cuvânt în
loc să fie verificat. Nu e o portiță: rândurile astea se **tipăresc toate la
fiecare rulare**, cu ce spune Wikidata alături. Azi e unul singur: „Hanul
Ancuței", unde Wikidata scrie „Hanul Ancuței (operă literară)" — dezambiguizarea
de pe wiki, intrată în etichetă.

### Dublurile: 16, dintre care una inversă

Regula e mai precisă decât la elemente, fiindcă se uită la **răspuns**, nu doar
la text:

- **dublură de sens direct** — răspunsul corect e numele unui autor ales, iar în
  text apare, între ghilimele, titlul unei opere alese;
- **dublură de sens invers** — răspunsul corect e titlul unei opere alese, iar în
  text apare numele unui autor ales.

A prins toate cele 15 directe (inclusiv `mana:0041` și `mana:0133`, care citează
câte **două** titluri) și una inversă: `mana:0090`, „Ce roman al lui Jules Verne
pornește de la un pariu al lui Phileas Fogg?" — în fond „care operă e a lui
Verne?", cu un indiciu în plus. Verne rămâne fără întrebare inversă generată, și
e bine: cea scrisă de mână e mai bună.

Potrivirea e **fără majuscule**, în amândouă direcțiile. `mana:0044` scrie „Micul
Prinț", titlul de la Wikidata e „Micul prinț": aceeași carte, un P mare
diferență. Cu potrivire sensibilă la majuscule, dublura ar fi trecut.

Ce NU prinde regula, dinadins: „Ce fel de operă literară este «Iliada»?" are
răspunsul „Epopee", deci nici una, nici alta — și corect, e **altă relație**,
exact ca „numărul atomic 79" față de „simbolul aurului". Iar pentru cazurile de
la limită există o listă **„de citit cu ochiul"**, care nu oprește nimic: azi
arată `mana:0043`, unde răspunsul e Caragiale și textul citează „D-l Goe...",
care nu e printre operele alese. Dacă mâine adaug „D-l Goe" cu altă ortografie,
lista îmi spune să mă uit.

### `data/trivia_gen/`: un dosar, nu o constantă pe fișier

```
data/trivia_gen/elemente_intrebari.json   ← mutat din data/intrebari_trivia_wd.json
data/trivia_gen/elemente_fapte.json       ← mutat din data/fapte_trivia_wd.json
data/trivia_gen/opere_intrebari.json      nou (azi gol: totul e ciornă)
data/trivia_gen/opere_fapte.json          nou (azi gol)
```

Convenția: `<tabel>_intrebari.json` și `<tabel>_fapte.json`. `trivia.gd` citește
**tot dosarul**, sortat pe nume, și n-are nicio constantă per fișier. Cu o
constantă pe fișier, fiecare tabel nou ar fi însemnat o linie în `trivia.gd`, una
în încărcător și una în verificator — exact ce spune `CLAUDE.md` că n-are voie să
se întâmple. Acum un tabel nou e două fișiere puse acolo și **nicio linie de
cod**.

`FOLOSESTE_WIKIDATA` stinge dosarul întreg, ca înainte. **`id`-urile nu s-au
schimbat** (se calculează din QID, nu din numele fișierului): rescrierea
fișierului elementelor la calea nouă a dat **diff gol, octet cu octet**.

Sortarea pe nume nu e cochetărie: ordinea în care sistemul de fișiere enumeră un
dosar nu e garantată, iar de la ea depinde ordinea din `intrebari`. Costă un
`sort()` și scoate din joc o familie întreagă de „la mine merge".

**Plasă pentru export, pusă acum:** într-un build exportat, fișierele care nu
sunt resurse Godot ajung în pachet doar dacă presetul le prinde în filtrul de
resurse ne-Godot (`*.json`). Dacă nu, `DirAccess` vede un dosar gol și jocul
pornește cu jumătate din conținut, fără niciun semn. Încărcătorul spune asta cu
tot cu cauza probabilă, iar verificatorul o cere ca verdict.

### Fluxul de lucru

Două fișiere de mână, în `tools/fabrica/date/` — sub `tools/`, nu sub `data/`,
fiindcă sunt **intrări ale fabricii**, nu conținut de joc.

| comandă | ce face |
|---|---|
| `--propune` | pentru fiecare autor, cele mai cunoscute 20 de opere **care nu sunt deja în `opere.json`**, cu tip, an, ediții. Scrie **doar** `date/opere_propuse.json` |
| `--masoara` | autorii, etichetele, tipurile, distribuția edițiilor, nivelul față de ediții. Nu scrie nimic în `data/` |
| (fără flag) | probă uscată: raport, grilă, 15 mostre, **cu tot cu ciorne** |
| `--scrie` | scrie perechea din `data/trivia_gen/`, **fără ciorne** |
| `--reincarca` | reia din rețea și rescrie cache-ul |
| `--seed=N` | fixează sămânța mostrelor |

**Scriptul nu scrie niciodată în `opere.json`.** Un script care fuzionează în
fișierul unde stă judecata omului e un script care într-o zi i-o șterge.

**Autorii se rezolvă din nume**, în două treceri: întâi etichetele (ieftin),
apoi alias-urile, doar pentru numele rămase. Prima variantă le cerea pe amândouă
într-un `UNION`, pentru toate cele 41 de nume deodată — Wikidata a răspuns **504
Gateway Timeout**. Azi un singur nume are nevoie de alias: „Feodor Dostoievski"
(eticheta oficială e altă transliterare). Un nume ambiguu sau negăsit **oprește
scriptul**: n-am voie să aleg „cel mai probabil", fiindcă un QID greșit leagă
întrebarea de alt om și nicio validare n-ar prinde-o.

**Cache-ul** (`tools/fabrica/cache/wikidata_opere.json`, 3,5 MB, comis în Git)
ține și **pentru ce** a fost luat: lista de nume și pragul de ediții. Adaugi un
autor și uiți `--reincarca` → scriptul se oprește, în loc să genereze în tăcere
fără el.

Două lucruri l-au ținut la 3,5 MB în loc de 8,6: `GROUP_CONCAT` în loc de rânduri
simple (o carte cu 2 autori, 3 tipuri și 2 ani venea pe 12 rânduri identice în
rest), și cererea explicită de **măcar o etichetă** ro/mul/en (fără ea veneau
8700 de itemi fără nicio etichetă, pe care nici nu-i poți citi ca să-i judeci).

### Ce s-a măsurat la final

```
în opere.json: 163 opere  (nivel I: 22, II: 42, III: 99) — toate ciorne
generate:      188 întrebări (148 directe, 40 inverse), 188 fapte
```

Grila, cu ciornele confirmate ipotetic:

| | nivelul I | nivelul II | nivelul III | total |
|---|---|---|---|---|
| istorie | 8+0 (1) | 8+0 (2) | 8+0 (1) | 24 (3) |
| geografie | 8+0 (1) | 8+0 (1) | 8+0 (1) | 24 (3) |
| stiinta | 8+39 (2+20) | 8+52 (1+26) | 8+48 (1+24) | 163 (73) |
| arta | 7+0 (1) | 7+0 (1) | 7+0 (0) | 21 (2) |
| mitologie | 7+0 (1) | 7+0 (0) | 7+0 (1) | 21 (2) |
| **literatura** | **7+31 (1+31)** | **7+54 (1+54)** | **7+103 (0+103)** | **209 (190)** |

**462 de întrebări în total**, de la 274. Literatura devine 82–94% „operă ↔
autor", ca știința care e ~85% chimie. Cu alegerea uniformă pe domenii, asta
înseamnă **cam 1 din 7 întrebări de luptă „operă ↔ autor"**, peste cea care e
deja „element ↔ simbol": **27–30% din întrebările de luptă ar fi fabricate**, de
la 14%. Cifra merită ținută sub ochi — dar pârghia rămâne lățimea conținutului,
nu o treaptă de alegere în plus.

Un lucru de simțit, nu de calculat: **190 de fapte distincte la literatură**,
toate cu nota goală. Cele 188 de întrebări vin din 163 de opere + 40 de autori,
deci raportul e ~1 întrebare pe fapt — sub plafonul de 2–3 din decizia
CONȚINUTUL, dar înseamnă și 190 de note de scris când se ajunge acolo.

### Verificatorul: o secțiune nouă și un verdict nou, amândouă probate

`tools/verificari/verifica_trivia.gd` are acum **șapte secțiuni**.

- **ÎNCĂRCAREA** citește **dosarul**, nu un fișier, și tipărește câte întrebări
  are fiecare fișier din el. Verdict nou: **dosarul fabricat are fișiere**.
- **TEXTELE** (nouă): două întrebări nu pot avea același text. Mecanic nu strică
  nimic — au `id`-uri diferite — și exact asta e problema: sacul nu te apără, iar
  în joc se văd ca o repetiție. E plasa de dedesubt pentru ziua în care cineva
  (eu, peste un an) „simplifică" sensul invers la per operă. Azi toate 274 sunt
  distincte, deci verdictul e strict de la bun început; un prag („cel mult 3
  repetate") ar fi fost o poartă deschisă.
- **forma `id`-ului**: nimic de schimbat. `wd:Q462220:autor:cere_opera` trece
  prin regula scrisă pentru `wd:Q897:simbol:cere_nume` — patru bucăți, QID,
  relație, sens. Prima dată când o regulă scrisă pentru un tabel a ținut la
  următorul fără nicio atingere.

Amândouă probate rupând codul intenționat:

| ce am rupt | ce a picat |
|---|---|
| o întrebare în plus cu text copiat (alt `id`) | `texte unice` → PICAT, 1 repetat: „Care este simbolul chimic al hidrogenului?" |
| dosarul `data/trivia_gen/` redenumit | `dosarul fabricat are fișiere` → PICAT, 0 fișiere; plus avertismentul cu cauza probabilă |

Rezultat final: **TOTUL E BUN**, 16 verdicte OK.

### Verificat

- `--masoara`: 41 de autori din 41 de nume, fiecare cu un singur om; 2969 de
  opere; 32% cu etichetă română; 60% cu an; distribuția edițiilor și pragul
  automat posibil (22% eroare).
- Probă uscată: 188 de întrebări, „exact una din patru e corectă" verificat pe
  toate, pe mulțimea completă de autori de la Wikidata.
- `--scrie`: două fișiere goale (totul e ciornă), JSON valid citit înapoi,
  id-uri și **texte** unice peste tot conținutul, 163 de ciorne raportate.
- `elemente.py --scrie` la calea nouă: **diff gol**.
- Verificarea headless: TOTUL E BUN.
- Citite cu ochiul toate cele 188 de întrebări generate.

### Ce NU s-a făcut

- ~~Nimic n-a intrat în joc~~ — confirmat ulterior aceeași zi, vezi CONFIRMAREA
  mai jos. 28 de rânduri rămân ciorne.
- **Nicio notă.** Cele 190 de fapte ar avea `nota: ""`.
- **Modulul comun** al fabricii. `elemente.py` și `opere.py` repetă acum `zar`,
  scrierea JSON-ului, cache-ul, contactul, grila și `citeste_dosarul_generat`.
  Duplicare **cunoscută și acceptată**, nu uitată: se unifică la al treilea
  tabel, odată cu mutarea coloanelor elementelor din cod în `tools/fabrica/date/`.
- **Nicio partidă jucată** cu conținutul nou.

### Ce urmează, concret

1. **Restul de 28 de ciorne**, când e vremea — Camus, Kafka, Goethe, Hugo,
   Rebreanu, Sadoveanu și alții. Aceiași pași: șterge `"ciorna": true`, rulează
   `--scrie`, verifică headless.
2. **Autori pentru limbile singuratice.** Cele 11 întrebări fără distractor de
   aceeași limbă sunt Dante și Boccaccio (singurii italieni), Cervantes și
   Márquez (singurii spanioli), Goethe și Kafka (singurii germani), Homer
   (singurul grec). Un al treilea italian sau german ar rezolva mai mult decât
   orice cod.
3. **Al treilea tabel = modulul comun.** Nu mai devreme: două exemple arată ce se
   repetă, unul singur ar fi ghicit.

### Fișiere

Nou: `tools/fabrica/opere.py`, `tools/fabrica/date/autori.json`,
`tools/fabrica/date/opere.json`, `tools/fabrica/date/opere_propuse.json`,
`tools/fabrica/cache/wikidata_opere.json`, `data/trivia_gen/opere_intrebari.json`,
`data/trivia_gen/opere_fapte.json`.
Mutate: `data/intrebari_trivia_wd.json` → `data/trivia_gen/elemente_intrebari.json`,
`data/fapte_trivia_wd.json` → `data/trivia_gen/elemente_fapte.json`.
Atinse: `scenes/trivia/trivia.gd` (`DOSAR_GEN` în locul celor două constante,
`fisierele_generate()`, încărcarea pe dosar), `tools/verificari/verifica_trivia.gd`
(secțiunea TEXTELE, dosarul, renumerotare), `tools/fabrica/elemente.py` (căile
noi, grila peste tot dosarul), `.gitignore` (`__pycache__`), `docs/progres.md`.

### CONFIRMAREA (tot 29 septembrie 2026, a doua trecere)

135 din cele 163 de rânduri au fost confirmate cu ochiul (`"ciorna": true` șters),
28 au rămas ciorne. `python tools/fabrica/opere.py --scrie` a scris cele 135 în
`data/trivia_gen/opere_intrebari.json` — **160 de întrebări** (148 directe + 40
inverse, minus 28 din dubluri cu fișierul de mână care nu generează).

**Un rând s-a stricat la editare, și scriptul l-a prins.** „Divina Comedie" a
pierdut nu doar `"ciorna": true`, ci și `"nivel": 2` — probabil ștergerea a luat
o bucată mai mare decât marcajul. `leaga_tabelul` cere câmpul, deci proba uscată
ar fi picat cu un mesaj clar dacă n-aș fi verificat manual înainte; l-am prins
citind fișierul cu Python, nu din eroarea scriptului. De reținut pentru viitor:
**verific fișierul cu un script mic înainte de `--scrie`**, nu doar cu ochiul pe
diff — un JSON care încă parsează, dar cu un câmp lipsă, nu sare în ochi la o
citire rapidă.

Verificarea headless, după scriere: **TOTUL E BUN**, 16 verdicte OK. Jocul are
acum **434 de întrebări** de Cultură generală (135 mână + 139 elemente + 160
opere), de la 274 înainte de sesiune. Grila pe literatură, la nivelul confirmat:

```
nivelul 1: 36 întrebări de literatură (7 mână + 29 fabricate)
nivelul 2: 67 întrebări de literatură (7 mână + 60 fabricate)
nivelul 3: 106 întrebări de literatură (7 mână + 99 fabricate)
```

Cele 28 rămase ciorne (Camus, Kafka, Goethe, Hugo, Rebreanu, Sadoveanu și alții)
așteaptă o trecere viitoare — nimic nu s-a pierdut, sunt încă în `opere.json`.

---

## DOUĂ PLĂCUȚE ȘI UN CARD (29 septembrie 2026) — arena își strânge textul

O reclamație de o frază, după o luptă: rândul alb de deasupra regelui, „REGELE
(tu) — 15/15 PV", stătea prea sus și nu arăta a joc; iar fereastra care se
deschidea la click pe inamic era cât tot ecranul, cu lore în ea.

### Plăcuța regelui: de ce plutea

Nu poziția era problema, ci golul. Blocul de informație are 84 px înălțime
fixă, iar înăuntru era un singur rând de 28: restul de 56 rămâneau goi între
text și figură. Un rând singur într-o cutie mare nu se citește ca un antet, se
citește ca ceva scăpat acolo.

Acum sunt două rânduri, cu roluri separate după cât de des le citești:

| Rând | Mărime | Culoare | De ce |
|---|---|---|---|
| `REGELE (TU)` | 12 px | gri stins | îl citești o dată pe luptă |
| `15/15 PV` | 19 px | verde `0.55/0.88/0.62` | îl citești în fiecare tură |

Verdele e al barei de lângă, dar mai deschis. Motivul: o bară e o suprafață, o
cifră e o linie subțire — la aceeași valoare de culoare, cifra se citește mai
greu.

### Plăcuța inamicului: aceeași, în roșu

Inamicul a primit exact aceeași construcție (nume mic stins + cifră mare roșie
`0.93/0.45/0.46`), fiindcă simetria nu e cochetărie: două plăcuțe la fel se
citesc dintr-o privire, ochiul găsind cifra în același loc pe ambele coloane.
Numele a rămas buton — click pe el deschide cardul —, dar acum duce doar numele,
cu prefixul „ELITA" / „BOSS" înainte. Cifra de PV i s-a luat de pe umeri.

### Cum se aliniază două coloane care n-au același conținut

Aici au fost **trei** încercări, și merită toate ținute minte, fiindcă fiecare
pare corectă până o vezi pe ecran:

1. **Ambele blocuri aliniate la bază** (`alignment = 2`), cu eticheta de
   vulnerabilitate între numele inamicului și cifra lui. Numele inamicului urca
   cu un rând față de al regelui — avea un rând în plus sub el.
2. **Un gol elastic între nume și cifră.** Alinia corect, dar rupea plăcuța în
   două: numele plutea sus, cifra jos, nu se mai citeau ca un întreg.
3. **Golul elastic SUS, separare zero jos.** Asta a rămas.

Schema finală, identică pe ambele coloane:

```
( gol elastic )      ← aici se duce toată diferența dintre coloane
[VULNERABIL: …]      ← doar la inamic
nume      30 px fix  ┐ o singură plăcuță,
PV        24 px fix  ┘ lipite, separare 0
```

Două lucruri de reținut din asta:

**Vulnerabilitatea a trecut DEASUPRA numelui.** E singurul loc care merge: e un
rând care apare și dispare (inamicii fără slăbiciune n-au eticheta), iar de sus
poate s-o facă fără să miște nimic de sub el. Între nume și cifră ar fi împins
numele inamicului cu un rând — exact bug-ul de la încercarea 1.

**Al doilea vinovat de la încercarea 1 era ascuns:** numele inamicului e un
`Button`, cel al regelui un `Label`, iar un Button își adaugă din temă vreo
8 px de margini. Nici înălțimile cutiilor nu erau egale, deși fontul era
același. De aia amândouă au acum `custom_minimum_size` de 30 px: e peste
minimul natural al butonului, deci ambele cutii ajung exact 30 și textul se
centrează la fel în ele.

Bonus care iese gratis: când panoul de întrebări se deschide și numele se ascund
(vezi `antetele_sunt_stramte()`), golul de sus crește și **cifrele de PV nu se
mișcă din loc**. La fel când un inamic n-are vulnerabilitate. Înainte, orice
rând care apărea sau dispărea împingea restul.

### Sabia a ieșit din arenă

Odată cu asta au dispărut sabia desenată și numărul de intenție de sub numele
inamicului. A fost o cerere explicită („să rămână doar PV-ul deasupra siluetei"),
dar are un cost real, scris aici ca să nu fie uitat: **intenția telegrafiată era
informație tactică**, nu decor. La Soldat (Atac constant) pierderea e mică —
lovește cu aceeași cifră în fiecare tură. La Lăncier (Grabnic) e reală: „2/3" îți
spunea că mai ai o rundă până la lovitura care ia jumătate din rege.

A fost mutată întâi pe un rând de card, apoi scoasă și de acolo, tot la cerere.
Odată cu rândul au fost șterse `text_intentie()`, `lovitura_grea()` și
`inamicul_loveste_acum()` — nu mai avea cine să le cheme. Șterse, nu comentate:
GDScript nu se plânge de o funcție nefolosită, iar o unealtă care arată bună și
pe care n-o cheamă nimeni e mai rea decât una lipsă. Logica de luptă nu depindea
de ele — `_tura_grabnic()` își numără singur ceasul.

Ce rămâne din informația aia: rândul **Comportament** din card („Ceasul se umple
in 3 runde; la 3/3 loveste 6, apoi o ia de la capat"). Spune regula, nu starea de
acum. Dacă la prima luptă cu Lăncierul se simte lipsa, varianta care nu strică
liniștea arenei e un contor discret pe bara lui de PV sau un semn pe figură —
nu un rând nou sub nume. `iconita_sabie.gd` a rămas în repo pentru ziua aia.

### Cardul de inamic a devenit un card

Fereastra era cât ecranul dintr-un motiv măsurabil: `descriere` — două-trei
fraze de atmosferă cu autowrap — ținea singură jumătate din ea. A ieșit cu
totul. În mijlocul unei lupte nu deschizi cardul ca să afli cine e adversarul,
ci ca să afli câte daune dă și pe ce e vulnerabil. Câmpul rămâne în `INAMICI`:
e identitate, și își găsește locul unde chiar se citește.

| | Înainte | Acum |
|---|---|---|
| Lățime panou | 560 | 340 |
| Portret | 96 × 167 | 70 × 122 |
| Titlu | 24 px | 17 px |
| Rânduri | 16 px (implicitul Godot) | 13 px |
| Descriere (lore) | un paragraf | scoasă |
| Buton de închidere | 44 px | 34 px |

Un detaliu care conta la 340 px: valoarea din dreapta primește
`size_flags_stretch_ratio = 1.6`. Fără asta, „Ceasul se umple in 3 runde…" s-ar
fi rupt în patru rânduri și cardul ar fi crescut la loc pe verticală — cu alte
cifre, aceeași fereastră.

### Ce s-a atins

`scenes/lupta/lupta.tscn` (ambele blocuri de informație, cardul),
`scenes/lupta/lupta.gd` (afișarea, cardul, funcțiile șterse),
`tools/verificari/verifica_podeaua.gd` (căile măsurate — `RandIntentie` nu mai există, și
au apărut rândurile „PV jucator" și „PV inamic").

---

## SABIA NU SE MAI ZBATE (28 septembrie 2026) — pulsul nodului pe care stai

O reclamație de o linie, după o luptă câștigată: sabia de sub figurină se mișca.
Reparația e o singură cifră, dar motivul merită scris, fiindcă e o regulă de
citire, nu o preferință.

**Ce se vedea.** Te întorci din luptă, figurina stă pe nodul de Luptă, iar
simbolul de dedesubt respira — se umfla și se dezumfla cu 3%. Cum piesa acoperă
mijlocul simbolului și lasă afară doar capetele lamei, mișcarea nu se mai citea
ca „nod viu": se citea ca o sabie care se zbate sub talpa figurinei.

**De ce era acolo.** `INFATISARI`, tabelul de stări din `simbol_nod.gd`, dădea
nodului CURENT `puls: 0.030`. Pulsul e moștenit de la `Silueta` (respirația
personajelor din arenă) și are un rost precis pe hartă: spune **„aici se poate
apăsa"**. De-aia îl au nodurile ACCESIBILE. Pe nodul curent însă nu se poate
apăsa — pe el stai deja — deci pulsul nu comunica nimic acolo; doar se mișca.

**Ce s-a schimbat.** `Stare.CURENT` are acum `puls: 0.000`. Localizarea („unde
sunt acum") rămâne în întregime pe seama AUREI, care e oricum singura lumină de
pe pergament și are propria ei pâlpâire (`PALPAIRE_AURA`, ciclu de 3,2 s). Nodul
curent nu devine mort — mișcarea lui e de-acum lumină, nu geometrie.

**De ce a fost de ajuns o cifră.** Scara respirației e `1.0 + sin(...) *
amplitudine`; cu amplitudinea zero rămâne fix 1,0, iar tot ce se desenează în
transformarea aia încremenește odată cu ea — inclusiv X-ul de „parcurs", care se
suprapune peste sabie pe nodul unde tocmai ai luptat. Aura nu depinde de scară,
ci de `_timp`, iar `configureaza()` pornea deja `_process` cu
`set_process(amplitudine > 0.0 or stare == Stare.CURENT)`: condiția a doua exista
tocmai pentru cazul ăsta, cu pulsul stins și timpul curgând mai departe pentru
lumină. N-a trebuit atinsă.

**Se aplică pe orice nod pe care stă figurina**, nu doar pe cel de Luptă — și e
bine așa: pulsul rămâne semnul lucrului pe care poți apăsa, adică exact acolo
unde înseamnă ceva.

*Atins:* `scenes/harta/simbol_nod.gd` (un rând din `INFATISARI` + nota de ce).

---

## ARENA SE LINIȘTEȘTE (28 septembrie 2026) — antetul, panoul și podeaua

Trei reclamații de pe ecran, toate din aceeași familie: lucruri care se mișcă sau
stau unde nu trebuie în timpul luptei. Nimic nou ca sistem; trei reparații, dintre
care una a cerut o măsurătoare ca să se vadă că nu era acolo unde credeam.

### 1. Antetul nu se mai revarsă peste întrebare

Când se deschide panoul de puzzle, cele două coloane se string la jumătate.
„BOSS LĂNCIERUL — 41/78 PV [i]" nu mai încape în ce rămâne, iar textul acoperea un
colț din întrebare.

Acum, cât timp panoul e pe ecran, antetul se rezumă la cifră: `41/78 PV` la
inamic, `15/15 PV` la Rege. Numele (și prefixul ELITĂ / BOSS) se întorc când
panoul s-a retras de tot. Regula e într-un singur loc, `antetele_sunt_stramte()`
din `lupta.gd`, și e citită de amândouă etichetele.

**Momentul contează mai mult decât textul.** Steagul întrebat NU e `puzzle_activ`:
acela devine `false` când se DĂ comanda de retragere, iar panoul mai ocupă loc
încă 0,55 s după aceea. Pe el, numele ar fi reapărut peste un panou încă întins —
exact bug-ul de reparat. Se întreabă `panoul_e_pe_ecran`, care se stinge în
`ascunde_panou_acum()`, la capătul animației.

### 2. Bara galbenă a ceasului a dispărut

Ceasul Grabnicului avea două voci: o bară galbenă deasupra siluetei și contorul
„1/3" de lângă sabie. A rămas cifra — bara era cea lată și cea care acoperea.
Nodul a ieșit din scenă, nu doar din vedere.

### 3. Figurile nu mai sar câțiva pixeli la finalul glisării

Simptomul: după ce panoul se retrage lin, figurile mai fac un salt scurt.

Cauza e un amănunt de `HBoxContainer`: un copil ASCUNS nu iese doar el din
socoteală, ci iese și SPAȚIEREA de lângă el. La `visible = false` se eliberau
dintr-un cadru în altul 16 px de separare plus chenarul panoului — ~9 px pe
fiecare coloană, fără animație.

Animația nu putea acoperi diferența: pentru un final continuu, lățimea ar fi
trebuit să ajungă la MINUS 18, ceea ce nu există. Deci **panoul nu se mai ascunde
niciodată**: se stinge din `modulate.a` și rămâne în așezare cu lățime zero
(`content_margin` zero în stilul lui îi taie și lățimea minimă). Nu mai există un
„înainte" și un „după" — există o singură lățime care merge continuu până la zero.

Prețul, asumat: panoul stins ține tot timpul o spațiere de 16 px în mijlocul
Arenei. E o constantă, nu o săritură. Opt pixeli pe coloană nu se văd; o săritură
de opt pixeli se vede de fiecare dată.

### 4. „[i]" a coborât pe figură

Antetul avea de dus trei lucruri pe un rând care se îngustează: nume, PV și un
buton. Sus au rămas PV-ul și sabia. Cardul se deschide acum de pe FIGURĂ
(`scenes/lupta/semn_inspectare.gd`): un `Button` întins peste toată zona
inamicului, din care se vede doar un cerc mic cu „i" în colțul din dreapta-sus al
texturii. Numele de sus rămâne apăsabil, dar nu mai anunță nimic.

Ținta de atingere și semnul nu sunt același dreptunghi, intenționat: degetul pe
telefon n-are vârf de pixel, iar semnul vrea să fie discret.

Dar nici ținta nu e tot nodul. Prima variantă lua tot dreptunghiul — de 2,5 ori
mai lat decât cavalerul — și hover-ul se aprindea de la doi centimetri distanță
de el: urcai mouse-ul de pe un Obelisc și figura „răspundea" fără s-o atingi.
`_has_point()` spune acum că sunt ale noastre doar SILUETA (pixelii cu alfa peste
0,25, citiți din textură) și cercul cu „i". Ordinea verificărilor merge de la
ieftin la scump — cercul, apoi dreptunghiul texturii, abia apoi pixelul —, iar
imaginile decomprimate se țin minte pe textură, ca `_CHENARE` din
`asezare_coloana.gd`. Cercul se verifică PRIMUL fiindcă el stă peste aer
transparent, lângă umăr: proba pe alfa l-ar fi respins tocmai pe el.

**Semnul stă pe ecran tot timpul, stins.** Pe telefon nu există hover: un indiciu
care apare doar la trecerea mouse-ului e, pe jumătate din dispozitive, un indiciu
care nu există. La hover sau la apăsare se aprinde, pe o pantă de 0,14 s. Tasta
**I** deschide și închide același card.

A existat aici, scurt, și un chenar în jurul figurii, ca să arate cât de mare e de
fapt ținta de click. A ieșit după o singură privire: un dreptunghi alb peste arenă
se citește drept element de interfață selectat, nu drept personaj — iar cât de
mare e ținta se află oricum apăsând.

Poziția semnului vine din locul unde cade EFECTIV textura, nu din colțul nodului
(între ele sunt zeci de pixeli de aer transparent). Formula era deja scrisă în
`umbra_contact.gd`; a devenit `static func UmbraContact.caseta_desenata()`, ca să
n-ajungem la a treia copie a ei.

### 5. Umbra de contact stătea pe vârful bocancului, nu pe talpă

Reclamația: „par că plutesc, e o distanță între picioare și umbră".

**Întâi măsurat, apoi reparat.** O unealtă de o singură folosință a randat scena
de două ori — o dată cu umbre, o dată cu `opacitate = 0` — iar diferența dintre
cele două imagini e exact ce pune umbra, fără zgomotul dalelor pictate. Răspunsul:
umbra era fix pe `talpa`, la un pixel. Deci nu era decalată; era pusă la reperul
greșit.

`talpa` era ultimul pixel opac din textură (0.9848 la Rege, 0.9697 la Soldat) —
adică **vârful bocancului din față**. Bocancul din spate calcă cu ~20 px mai sus,
poalele hainei și mai sus. Cu umbra centrată acolo, jumătatea ei vizibilă cădea
toată ÎNAINTEA piciorului: o baltă din care personajul iese.

Cifra corectă e MEDIANA marginii de jos a siluetei pe toată amprenta, măsurată pe
canalul alfa coloană cu coloană: **0.9514** la Rege, **0.9454** la Soldat. Plus
`centru = 0.462` la Soldat (amprenta lui nu e la mijlocul texturii) și opacitate
0.85 la amândoi — vârful de întunecare era 4% din 255, prea puțin ca să lipească
ceva; e acum 11% la Rege (podeaua de sub el e deja închisă) și 21% la Soldat.

`tools/verificari/verifica_podeaua.gd` ținea o copie a cifrelor vechi; a primit și ea
reperul nou, cu explicația de ce s-a mutat. Rulat după: **VERDICT: podeaua ține**.

### 6. Personajele s-au tras spre centru

`deplasare_de_baza` din `asezare_coloana.gd`: 0.11 → **0.15**, pe amândouă
coloanele. Cam 19 px pe coloană în ecranul logic. Stăteau prea aproape de mobila
din margini; aerul dintre mantia Regelui și pupitru a crescut de la 2 px la 21 px.

Aceeași cifră pe amândouă, fiindcă `panoul_la_dreapta` îi schimbă singur semnul:
„spre centru" înseamnă dreapta la Rege și stânga la inamic, iar arena rămâne
simetrică fără să ții minte două numere.

### Datorie deschisă

- Semnul „i" ar putea pulsa o dată la prima luptă, apoi să rămână discret. Cere un
  steag care supraviețuiește pornirii, deci așteaptă Save-ul.

## ID ȘI FAPT (28 septembrie 2026) — o întrebare are acum un nume care nu se mișcă

Pasul 3 din lista „Imediat”. Cele 135 de întrebări de Cultură generală au primit
un `id` stabil, notele pilotului au intrat în `data/fapte_trivia.json`, iar sacul
a trecut de la text la `id`. Nimic nu se vede în joc: e sesiunea care face
posibile Save-ul și Practice, nu una care adaugă ceva pe ecran.

### De ce „înainte de Save” nu era o vorbă în vânt

Până azi, sacul recunoștea o întrebare după TEXTUL ei (`Sac.extrage(..., "text")`).
Cât timp nimic nu se scrie pe disc, asta merge: memoria trăiește o rulare, iar
dacă rescriu mâine o întrebare ca să sune mai bine, se pierde odată cu ea.

După Save, aceeași reformulare ar fi însemnat altceva: save-ul ar fi conținut
textul vechi, iar întrebarea rescrisă i-ar fi părut nevăzută — deci gratis, exact
lucrul împotriva căruia există sacul. Iar la Practice, unde istoricul spune
„învățat”, meritul a doi-trei răspunsuri corecte s-ar fi lipit de un text care se
poate schimba oricând.

**Verificat înainte de orice:** `grep` după `FileAccess.open`, `WRITE` și `user://`
în tot codul de joc dă zero rezultate. `spre_dictionar()` există la Tezaur, Sac și
Expediție, dar nimeni nu-l duce într-un fișier. **Deci n-a fost nevoie de nicio
migrare** — singura fereastră în care schimbarea asta e gratuită, și e încă
deschisă.

### Scriptul: chirurgie pe text, nu reserializare

`tools/da_iduri.py`, rulat cu `--scrie` (fără, e probă uscată).

Varianta evidentă ar fi `json.load`, adaugi cheia, `json.dump`. **Nu e bună**: ca
să iasă fișierul de pe disc, `json.dump` ar trebui convins să scoată taburi, nu
spații, `variante` pe un singur rând, ghilimelele românești neescapate și cheile
în ordinea de acum. Orice nepotrivire rescrie toate cele 965 de linii, iar în Git
ai un diff în care câmpurile noi nu se mai văd printre 800 de linii mutate degeaba.

Scriptul inserează linii într-un fișier text, imediat după acolada de deschidere.
**Rezultatul: 153 de inserări, 0 ștergeri** — 135 de `id` plus 18 de `fapt`, și
nicio linie existentă atinsă.

Prețul e că scriptul trebuie să știe forma fișierului. De aceea e **strict**:
orice linie pe care nu o recunoaște îl oprește cu eroare și cu numărul liniei, în
loc s-o sară. Probat pe un câmp indentat cu un spațiu în loc de tab: „OPRIT: linia
381: așteptam un câmp la două taburi”, fișierul neatins. Un script care sare peste
ce nu înțelege ar da, în tăcere, 134 de id-uri din 135 — iar întrebarea fără id ar
dispărea din joc, fiindcă încărcătorul o sare.

**Idempotent prin construcție:** un obiect care are deja `id` e lăsat în pace.
A doua rulare spune „Nimic de schimbat” și verifică fișierul de pe disc.

**Legăturile cu faptele sunt după TEXTUL întrebării, nu după id-uri prezise.** Un
tabel de forma „mana:0038 → aur” nu se poate citi cu ochiul: o cifră greșită ar
lega întrebarea de alt fapt, iar nicio validare n-ar prinde-o (id-ul există,
faptul există, legătura e doar falsă). Scriptul cere ca fiecare text să apară
exact o dată în fișier, se oprește dacă un text din tabel nu se găsește, și
tipărește la final toate cele 18 legături ca „id · fapt · întrebare”, de citit.

**După scriere, scriptul își citește fișierul înapoi** cu `json.load` — același
parser pe care-l va folosi Godot — și confirmă 135 de obiecte, fiecare cu id unic.
A umblat pe text, deci nu are nicio altă dovadă că a scris JSON valid; e ieftin și
e singurul lucru care prinde o virgulă pierdută.

### REGULA: un `id` nu se refolosește niciodată

Numărul următor se află ca „cel mai mare id din fișier, plus unu”. Corect **doar**
cât timp nimic nu se șterge. Dacă ștergi ultima întrebare, `mana:0135` dispare,
iar următoarea adăugată primește chiar `mana:0135`. De acolo încolo, save-ul unui
jucător ar crede că a văzut o întrebare pe care n-a văzut-o, iar istoricul din
Practice i-ar trece meritul unei întrebări cu totul alteia. **Nimic nu prinde
asta:** fișierul e valid, id-urile sunt unice, jocul pornește.

**Deci întrebările nu se șterg din fișier.** Una scoasă din joc se marchează
`"retras": true` și rămâne pe loc, cu id-ul ei. Încărcătorul va învăța să sară
peste ele **când va fi nevoie** — azi nu e nimic retras, deci nu există codul.
Regula e scrisă în antetul lui `tools/da_iduri.py` și în antetul lui `trivia.gd`,
fiindcă e o regulă pe care niciun cod nu o apără.

### Faptele: `data/fapte_trivia.json`

Cele 15 fapte din pilot (`docs/ghid-note.md`, secțiunea 5), cu notele copiate
cuvânt cu cuvânt. Câmpuri: `id`, `nota`, `surse: []`, `verificat: false`, plus
`etichete: ["romania"]` la `stefan_cel_mare` și `dambovita`. Restul n-au etichete:
una pusă „ca să fie” e conținut mort care arată ca structură.

Lungimile ies 115–232, media 164 — exact cifrele pe care ghidul le dă pentru
pilot, deci notele au ajuns nemodificate. **Toate 15 sunt `verificat: false`**:
verificarea lor e punctul 2 din „Imediat”, încă nefăcut.

### Încărcătorul: cinci validări care avertizează, nu opresc

Faptele se citesc **întâi**, din două motive: întrebările au nevoie de mulțimea de
fapte ca să-și verifice legătura, iar după ce s-au citit amândouă se poate pune
întrebarea inversă — există fapte pe care nu le cere nimeni?

| Problemă | Ce face | De ce |
|---|---|---|
| `id` lipsă sau gol | avertisment + **sare peste întrebare** | De azi `id` e obligatoriu ca `text`. Pare dur pentru un câmp nevăzut, dar el e cel prin care sacul, save-ul și istoricul din Practice recunosc întrebarea; fără el n-ar putea intra cinstit în niciunul. Avertismentul spune chiar comanda de rulat |
| `id` duplicat | avertisment + **sare peste a doua** | Două întrebări cu același `id` sunt, pentru sac, o singură întrebare: una n-ar mai ieși NICIODATĂ, și nu s-ar vedea ca un bug, s-ar vedea ca o bază mai săracă decât e |
| `fapt` inexistent | avertisment, **întrebarea rămâne**, legătura cade | O legătură scrisă greșit e o scăpare de tastat; întrebarea e în continuare bună și apare fără notă, ca înainte |
| notă peste 240 | avertisment, **nota rămâne întreagă** | 240 e limită de stil și încă nejucată (`MAX_NOTA`, de recalibrat pe popup). O notă bună nu se taie pentru o cifră provizorie |
| fapt nefolosit | avertisment după ambele fișiere | Conținut mort. Nu strică nimic în joc și exact de-aia n-ar fi găsit niciodată altfel |

Sărirea nu e o dispariție tăcută: se vede în linia de bilanț, „133 incarcate din
135 gasite”.

### Nota intră în `explicatie`

Câmpul exista deja în contractul din `puzzle.gd`, gol la Trivia — vezi sesiunea
CONȚINUTUL. Acum ia nota faptului spre care arată întrebarea, sau rămâne gol dacă
nu e niciunul. **Nimeni nu-l afișează încă**, și e în regulă: se umple de pe acum
fiindcă e o linie de cod și un fișier de conținut, iar conținutul e partea lentă.
Notele se pot scrie și verifica luni de zile înainte să existe ecranul care le
arată.

### Verificarea: `tools/verificari/verifica_trivia.gd`

`godot --headless --path . res://tools/verificari/verifica_trivia.tscn` — instant, fără
fereastră. Nu deschide nicio scenă: tot ce citește stă în `static var`-uri, deci
aparține scriptului, nu unei copii a scenei.

```
  ÎNCĂRCAREA
    întrebări încărcate      OK   135 din 135 așteptate
    fapte încărcate          OK   15 din 15 așteptate
    pe niveluri                   1: 45, 2: 45, 3: 45
  ID-URILE
    toate au id              OK
    id-uri unice             OK   135 distincte
    forma 'prefix:cifre'     OK
  NOTELE
    întrebări cu notă        OK   18 din 18 așteptate
    note sub limită          OK   cea mai lungă: 232 din 240
    niciun fapt nefolosit    OK
  SACUL (pe `id`, un ciclu întreg pe fiecare nivel)
    nivelul 1, un ciclu      OK   45 trageri, 45 întrebări distincte
    nivelul 1, răscrucea     OK   mana:0015 după mana:0032
    … la fel pe nivelurile 2 și 3
```

Numerele așteptate (135, 15, 18) sunt scrise în unealtă, nu citite din fișier: o
verificare care-și ia așteptările din lucrul verificat nu verifică nimic — „am
găsit câte am găsit” ar trece liniștită și după ce dispar 10 întrebări. Când baza
crește, cele trei constante se mută cu ea, dinadins.

„Întrebări cu notă” NU numără câmpul `fapt`, cere nota însăși, prin același drum
pe care-l face lupta: fapt → notă. O legătură care duce nicăieri e chiar greșeala
de prins.

### Și drumurile de eșec au fost probate

O validare pe care n-ai văzut-o niciodată dând alarma e doar o intenție. Am stricat
dinadins fișierele, pe o copie de siguranță, cu toate cinci defectele deodată:
fiecare a dat avertismentul lui, cu numele exact al intrării, nimic n-a crăpat,
codul de ieșire a fost 1. Întrebarea cu legătura ruptă **a rămas** (133 = 135 − 2
sărite pentru `id`, nu 3) și a apărut fără notă: 17 în loc de 18.

### Ce NU s-a făcut, dinadins

- **A 19-a întrebare.** Ghidul cere, la `stefan_cel_mare`, și „În ce perioadă a
  domnit Ștefan cel Mare?”, marcată *de adăugat*. Nu există în bază și n-am
  scris-o: e conținut nou, nu pasul de azi. Faptul o așteaptă (nota vorbește deja
  despre domnia 1457–1504).
- **Sacul permanent.** Rămâne pe expediție, cum e. La Save trece în stratul
  permanent, iar `Array.has()` din `sac.gd` devine un Dictionary folosit ca
  mulțime — comentariul de acolo o anticipează deja.
- **Afișarea notei.** Nimic. Primul loc va fi „Află mai multe” din Practice.
- **`retras`.** Regula e scrisă, codul nu există: nu e nimic retras.

### Fișiere

Nou: `tools/da_iduri.py`, `data/fapte_trivia.json`, `tools/verificari/verifica_trivia.gd` +
`.tscn`. Atinse: `data/intrebari_trivia.json` (+153 de linii, 0 ștergeri),
`scenes/trivia/trivia.gd` (faptele, cele cinci validări, sacul pe `id`, nota în
`explicatie`), `autoload/sac.gd` (doar comentariul lui `_identitate`, care încă
dădea textul întrebării ca exemplu), `docs/progres.md`.

---

## EVENIMENTUL DESCHIDE CUFĂRUL (27 septembrie 2026) — Lacătul intră în expediție

Lacătul nu mai trăiește singur cu F6. Nodul de Eveniment îl deschide, cu nivelul
și sămânța luate din hartă, iar un cufăr deschis plătește. **Contractul n-a fost
atins:** `porneste(nivel, samanta)` și `rezolvat(succes)`, exact ca înainte.

Merită spus cât a costat legarea: **zero linii schimbate în `cifru.gd`**, în
afara unui comentariu care nu mai era adevărat. Ăsta e dividendul contractului —
scena fusese scrisă acum trei zile pentru un apelant care nu exista încă, și
apelantul s-a potrivit din prima.

### PESTE hartă, nu o scenă nouă

Lupta se deschide cu `change_scene_to_file()`. Lacătul se **instanțiază peste
harta vie**, ca panourile de Odihnă și de Magazin.

Diferența nu e de gust. `change_scene_to_file()` DISTRUGE harta, iar lupta
suportă asta fiindcă e alt LOC: întoarcerea trece prin `_ready()`, care se uită
la starea expediției și redeschide ecranul potrivit. Un Eveniment nu e alt loc, e
o oprire pe drum. Trei lucruri concrete, în ordinea în care m-ar fi durut:

1. **Lacătul ar fi trebuit să știe cum se cheamă fișierul hărții**, ca să se
   întoarcă. Un ecran de puzzle care știe despre expediții e exact legătura pe
   care contractul o evită.
2. **Muzica ar fi repornit.** `harta.gd::_ready()` cheamă
   `Muzica.reda(Piesa.HARTA)`; cu o scenă nouă, piesa hărții ar fi luat-o de la
   zero la fiecare cufăr.
3. **`cifru.gd` fusese scris pentru asta.** Camera lui e un `Node2D` mutat cu
   mâna și nu un `Camera2D`, FIINDCĂ un `Camera2D` ar trage pergamentul după el.
   Decizia aia, luată acum trei zile „pentru mai târziu", s-a plătit azi.

Nu se vede nimic din hartă pe dedesubt — fundalul Lacătului e opac — și e bine:
un cufăr se privește de aproape.

**Momentul generării nu s-a mai mutat.** Nota veche („generarea de nivel 3 costă
~0,47 s, momentul bun e în timpul tranziției de la hartă") a fost rezolvată de
altcineva între timp: din sesiunea DIFICULTATEA, generarea pleacă pe
`WorkerThreadPool` în prima linie din `porneste()` și se suprapune peste răgazul
de o jumătate de secundă în care vezi cufărul întreg. Deci `porneste()` se cheamă
DUPĂ săritura piesei, ca la orice alt nod. S-o pornesc mai devreme ar cere
spartul lui `porneste()` în două (calcul / desen), pentru un câștig de ~0,8 s pe
care jocul îl umple oricum cu animație.

### Sămânța: un mecanism, nu două

Cerința era „sămânța expediției plus id-ul nodului". Există însă deja exact ceva
care face asta: **fiecare nod are câmpul `samanta`**, tras la generarea hărții
din sămânța expediției și salvat odată cu nodul. `lupta.gd` face
`rng.seed = int(nod["samanta"])` ca să-și aleagă inamicul.

Deci sămânța lacătului e sămânța nodului, amestecată:

```gdscript
samanta_lacat = int(nod["samanta"]) * AMESTEC_LACAT + ADAOS_LACAT
```

Reproductibilitatea cerută iese de la sine, iar jocul are UN singur răspuns la
întrebarea „de unde își ia un nod conținutul", nu două. Amestecul cu o constantă
proprie desparte lacătul de un eventual al doilea eveniment pe același nod (o
fântână, un altar), cât despărțirea e gratis.

### Nivelul: drumul împărțit în treimi

`Expeditie.nivel_lacat(adancime, adancime_boss)` — funcție `static` și pură, deci
verificabilă pe adâncimi inventate, fără nicio hartă.

```gdscript
if 3 * adancime <= adancime_boss:        return 1
if 3 * adancime >= 2 * adancime_boss:    return 3
return 2
```

**Fracțiune de drum, nu adâncime fixă.** „Adâncimea 4 ⇒ nivelul 3" e adevărat pe
planșele de azi (Bossul stă la 6) și devine fals în ziua în care desenezi o hartă
mai lungă, unde 4 e mijlocul drumului.

**Raportat la adâncimea BOSSULUI, nu la cea maximă din hartă** — din motivul
scris chiar în `expeditie.gd`, la înmormântarea lui `adancime_maxima()`: pe o
planșă desenată de mână, „cel mai depărtat nod de Start" și „capătul drumului"
sunt două lucruri care doar se nimeresc să coincidă.

**Aritmetică întreagă, nu împărțire cu virgulă.** Comparația firească ar fi
`adancime / float(boss) <= 1.0 / 3.0`. Pe Bossul de la 6, adâncimea 2 dă
0,33333… în amândouă părțile — două numere care ar TREBUI să fie egale, scrise cu
virgulă. Uneori sunt, uneori nu, și atunci nodul sare o bandă de dificultate fără
ca nimeni să poată spune de ce. Înmulțite, răspunsul e mereu același.

### Marginile cad spre AFARĂ — și de ce am aflat-o de la verificator

Prima variantă avea amândouă marginile căzând spre banda mai ușoară (`<=` de două
ori). Pare firesc, și pe hârtie era în regulă. Verificatorul a raportat, pe prima
rulare:

```
═══ harta_01.json ═══
    apar toate trei nivelurile    PICAT   nivel 1: 105 · nivel 2: 295 · nivel 3: 0
```

**Zero lacăte de nivel 3 pe planșa care se joacă**, din 200 de semințe. Cauza e
în forma hărții, nu în formulă: pe `harta_01`, nivelul 3 cerea adâncimea 5, iar
la adâncimea 5 există UN SINGUR nod — cel de dinaintea Bossului, pe care
`_regula_boss_cu_odihna_vecina` îl face mereu Odihnă. Nivelul cel mai greu al
Lacătului, cu tot rezolvitorul scris pentru el, era cod mort.

Marginea de sus cade acum spre banda 3, deci nivelul 3 prinde și adâncimea 4,
unde stau patru noduri. Regula e simetrică — fiecare margine cade spre capătul de
hartă cel mai apropiat — și simetria are un motiv, nu e estetică: **pe o hartă
adevărată, capetele drumului au puține noduri libere, iar mijlocul are multe.**
Adâncimea 1 e mereu Luptă (regula „vecinii startului sunt lupte"), deci banda 1 e
îngustă la fel de tare pe dedesubt; dacă marginea de jos ar fi căzut în sus,
nivelul 1 — singurul cu roată sudată, cel care te învață ce e un lacăt — ar fi
dispărut la rândul lui.

| Bossul la | nivel 1 | nivel 2 | nivel 3 |
|---|---|---|---|
| 6 (planșele de azi) | adâncimea 1, 2 | 3 | 4, 5 |
| 8 (o hartă lungă) | 1, 2 | 3, 4, 5 | 6, 7 |

Merită ținut minte ce s-a întâmplat aici, fiindcă e a doua oară: **o regulă de
design corectă în abstract poate fi goală în practică, iar diferența nu se vede
citind codul.** Prima dată a fost `LUPTE_MINIME_ELITA` (pragul 3 dădea zero
aranjamente valabile). Amândouă s-au aflat măsurând, nu gândind.

### Recompensa: Monede, 6 / 10 / 14, zero la eșec

`Expeditie.LACAT` — un rând pe nivel, ca să se regleze după primele partide:

| nivel | Monede | reperul lângă care a fost aleasă cifra |
|---|---|---|
| 1 | 6 | sub o Luptă (8): o roată îți e dăruită, sudată pe cifra bună |
| 2 | 10 | cât o Luptă și ceva — nu riști PV, dar plătești cu timp |
| 3 | 14 | sub o Elită (16); e nodul care te poate ține chiar cinci minute |

**De ce Monede și nu Fragmente.** Granița e scrisă în `expeditie.gd`: Fragmentele
sunt averea care rămâne după expediție (viitoarea cetate), Monedele sunt ce ai pe
drumul ăsta. Un lacăt plătit în Fragmente ar fi devenit o sursă de progres
PERMANENT complet ruptă de luptă — ai fi avansat în meta-joc rezolvând puzzle-uri
care n-au nicio legătură cu loadout-ul ales. Plătit în Monede, Evenimentul devine
în schimb o decizie de HARTĂ: „iau brațul cu cufărul, ca să-mi ajungă de Pana de
otel când ajung la Magazin?". Asta lipsea unui nod care până acum nu făcea nimic.

**De ce zero la eșec.** Orice sumă fixă pe eșec s-ar putea strânge *fără să
joci*: apeși „Deschide" de trei ori la întâmplare, în cinci secunde, și iei banii.
Un joc de antrenament mental n-are voie să aibă o recompensă a cărei cale cea mai
rapidă e să nu gândești. Iar consolarea la eșec există deja și e cea potrivită:
cufărul îți ARATĂ codul pe roți. Pleci știind răspunsul — plătești cu Monedele pe
care nu le-ai luat, nu cu PV, nu cu tura, nu cu timp.

Cât cântărește, măsurat pe 200 de semințe: o expediție are 2–3 Evenimente, iar
deschise toate dau **20,5 Monede pe `harta_01`** și 33,2 pe `harta_02`, dintr-un
venit total de ~94 de pe hartă. Deci merită ocolit după cufere, fără să fie
obligatoriu — exact greutatea pe care vrei s-o aibă o alegere de drum.

### Harta de dedesubt nu reacționează deloc

Cât Lacătul e deschis, harta nu primește nici clic, nici survolare, nici
tastatură. Aproape nimic nu e scris pentru asta, și merită spus de ce:

- **Mouse-ul** — rădăcina scenei Lacătului e un `Control` întins pe tot ecranul,
  cu `mouse_filter` implicit (`STOP`). Clicurile și mișcarea se opresc în ea.
  Tot ce e înăuntru e pe `IGNORE` (fundalul, `Interfata`, panoul, coloana),
  singura excepție fiind butonul „Deschide" — care are nevoie de clicuri. Deci
  nodurile de dedesubt nu primesc nici `_gui_input`, nici `mouse_entered`, deci
  **nici eticheta de survolare nu poate apărea**.
- **Tastatura** — `get_viewport().gui_release_focus()` se cheamă la deschidere.
  Lacătul citește săgețile și cifrele din `_unhandled_input()`, adică din
  evenimentele pe care nu le-a luat nimeni înainte; un buton rămas cu focus de la
  panoul de dinainte le-ar fi luat primul, și ai fi avut un cufăr care nu
  răspunde la săgeți fără niciun motiv vizibil. Nodurile de pe hartă nu sunt
  `Button`, sunt `Control`-uri desenate, deci nu pot lua focus oricum.

### Nodul e consumat la INTRARE, nu la verdict

`Expeditie.intra_in_nod()` pune nodul în `parcurse` **înainte** ca lacătul să se
deschidă. Deci un cufăr ratat nu se poate reîncerca: `accesibile()` sare peste
nodurile parcurse, iar simbolul lui nu mai e `activ`, deci nici nu primește clic.
Verificat, nu presupus (vezi proba de integrare mai jos).

Asta e regula hărții pentru TOATE nodurile („Drumul nu se poate reface"), nu o
pedeapsă pusă pe lacăt — și e și motivul pentru care eșecul nu trebuie să doară:
nu pierzi nimic, doar nu câștigi.

> **NOTĂ PENTRU PASUL 8 (SAVE).** Aici e o scurgere, ușor de închis acum și greu
> de găsit peste trei luni. Eșecul îți ARATĂ codul pe roți, iar sămânța lacătului
> e deterministă. Deci dacă ieși din joc pe ecranul de eșec și reiei expediția,
> ai primi **exact același lacăt, cu codul deja știut** — trei încercări pe un
> puzzle la care ai răspunsul scris pe hârtie.
>
> Regula, când save-ul se scrie: **lacătul se marchează ca folosit în clipa
> DESCHIDERII scenei, nu la verdict.** Azi nu e o problemă, fiindcă nu există
> salvare pe disc; nodul e consumat la intrare, iar starea trăiește doar în
> memorie. Iar `intra_in_nod()` e deja locul care face marcarea la momentul
> potrivit, deci soluția nu cere un câmp nou — cere doar ca save-ul să nu fie
> scris ÎNAINTE de ea. Concret: prima scriere pe disc a unei expediții trebuie să
> se întâmple la `intra_in_nod()`, nu la `_dupa_un_nod()`.

### Verificarea headless: `tools/verificari/verifica_eveniment.gd`

`godot --headless --path . res://tools/verificari/verifica_eveniment.tscn` — **sub un
minut**, pe 200 de semințe × 3 surse de hartă.

Încă o unealtă pe lângă `verifica_cifru.gd`, fiindcă pune altă întrebare.
`verifica_cifru` întreabă dacă LACĂTUL e bun (soluție unică, nota cerută, niciun
indiciu care dictează), cu niveluri și semințe alese de el. Asta întreabă **ce
lacăt îți dă HARTA**: între sămânța unei expediții și `porneste()` stau trei
socoteli — adâncime → nivel, sămânța nodului → sămânța lacătului, nivel → Monede
— și toate trei pot fi greșite fără să strice niciun puzzle. Un lacăt perfect
corect, dar de nivel 3 la al doilea nod, ar trece verificarea cealaltă fără o
vorbă.

Ce verifică: aceeași sămânță dă aceleași lacăte (tripleta, pe toate Evenimentele
de pe toate semințele, PLUS puzzle-ul întreg, generat de două ori pe câte un nod
de fiecare nivel) · marginile treimilor, pe adâncimi inventate, cu tabelul
așteptat scris de mână · apar toate trei nivelurile · nivelul cerut există în
tabel (`specificatie()` strânge orice număr în tăcere, deci se verifică acolo
unde se NAȘTE) · sămânța lacătului e pozitivă · câte Evenimente are o expediție.

**Rezultatul: verde peste tot.**

| | harta generată | harta_01 | harta_02 |
|---|---|---|---|
| nivel 1 / 2 / 3, de câte ori | 100 / 182 / 179 | 105 / 165 / 130 | 136 / 170 / 294 |
| Evenimente pe expediție | 2,31 (minim 2) | 2,00 | 3,00 |
| Monede, dacă le deschizi pe toate | 24,6 | 20,5 | 33,2 |

Generarea unui puzzle, măsurată aici din nou: 68 ms la nivelul 1, 146 ms la
nivelul 2, 476 ms la nivelul 3.

Plus o **probă de integrare** rulată o dată, pe mână (nepăstrată în `tools/`,
fiindcă ar fi chemat funcții private ale hărții): pe sămânța 1007 a lui
`harta_01`, nodul 10 de la adâncimea 4 a dat un lacăt de nivel 3 cu sămânța
540420629176; nivelul și sămânța ajunse în puzzle coincid cu cele cerute,
succesul a plătit exact 14 Monede, eșecul 0, scena s-a eliberat, iar nodul era
deja în `parcurse` și nu mai era în `accesibile()`.

### Ce să testezi pe mână

Verificarea headless spune că numerele se leagă. Nu poate spune niciunul din
lucrurile de mai jos.

1. **CÂT DUREAZĂ CHIAR UN LACĂT DE NIVEL 3.** Cronometrul pornit, de la momentul
   în care roțile devin atingibile până la „Deschide". Ăsta e singurul număr
   pentru care s-a scris tot rezolvitorul. Reper de comparație: o luptă întreagă
   durează 2–4 minute. Un lacăt care trece de 5 minute nu e greu, e alt joc —
   și-atunci se umblă la `NIVELURI` din `generator_cifru.gd` (nota cerută sau
   `indicii_maxime`), nu la recompensă. Sămânța de probă: **1007 pe `harta_01`
   dă un nivel 3 la nodul 10.**
2. **Cele trei niveluri, în aceeași expediție**, ca să simți diferența dintre
   ele. Cel de nivel 1 are o roată aprinsă de la început (cea sudată); cel de
   nivel 3 e cel de dinaintea Bossului sau cel de lângă el.
3. **Harta de dedesubt e complet moartă cât cufărul e pe ecran.** Încearcă, în
   ordine: clic pe unde știi că e un nod · mișcă mouse-ul peste zona hărții (nu
   trebuie să apară eticheta de survolare) · apasă săgeți și Enter (trebuie să
   ducă la roți, nu la altceva) · Tab, care e cel mai bun test de focus rătăcit.
4. **Ieșirea din lacăt.** După ce se deschide (sau după a treia greșeală), apare
   panoul cu verdictul, iar în spatele lui nodul trebuie să fie deja tăiat ca
   parcurs. Apoi harta trebuie să te lase să mergi mai departe, și **nodul de
   Eveniment nu mai trebuie să fie apăsabil.**
5. **Monedele din antet** cresc cu exact cât scrie panoul, iar la eșec nu cresc.
6. **Cât aștepți până apare cufărul.** De la clic pe nod până când roțile se pot
   atinge trec săritura (0,35 s), răgazul de după aterizare (0,5 s), răgazul de
   pe cufărul întreg (0,5 s) și apropierea — plus generarea, dacă e nivel 3 și
   nu s-a terminat în răgaz. Dacă se simte lung, numărul de tăiat e
   `PAUZA_DUPA_ATERIZARE` din `harta.gd`, fiindcă e singurul care nu arată nimic
   nou.
7. **Muzica hărții nu repornește** când se deschide cufărul, și nici când te
   întorci. (E jumătate din motivul pentru care Lacătul se deschide peste hartă
   și nu ca scenă nouă — merită auzit o dată că funcționează.)

### Ce s-a atins

| fișier | ce |
|---|---|
| `autoload/expeditie.gd` | descrierea reală a nodului de Eveniment · `LACAT`, `AMESTEC_LACAT`, `ADAOS_LACAT` · `lacat_la()`, `adancimea_bossului()`, `nivel_lacat()`, `castiga_monede()` (prin care trec de-acum și Monedele din lupte, ca semnalul să nu poată fi uitat) |
| `scenes/harta/harta.gd` | `SCENA_CIFRU` · ramura `EVENIMENT` → `_deschide_lacatul()` · `_pe_lacat_rezolvat()` |
| `scenes/cifru/cifru.gd` | **doar un comentariu** din antet, care nu mai era adevărat |
| `tools/verificari/verifica_eveniment.gd` + `.tscn` | nou |

Neatinse: `generator_cifru.gd`, `rezolvitor_cifru.gd`, `banda_cifre.gd`,
`cifru.tscn`, contractul.

### Ce urmează, concret

1. **Jucat pe mână** — cât durează CHIAR un lacăt de nivel 3, cu ceasul pornit.
   Din statistici nu se află: 476 ms e cât îi ia GENERATORULUI, nu mie.
   Verificarea e verde; reglajul nu se poate face decât jucând.
2. **Un al doilea eveniment**, ca nodul să nu însemne mereu „iar lacătul". Trei
   Evenimente pe hartă și un singur conținut e exact felul în care un nod bun
   devine plictisitor.
3. **Nota pentru Save** de mai sus, când se ajunge la pasul 8.

---

## FABRICA (28 septembrie 2026) — primul tabel din Wikidata, elementele chimice

Punctul 4 din lista „Imediat”. Scopul n-a fost volumul, a fost o întrebare: **cum
arată întrebările generate lângă cele scrise de mână?** Răspunsul e mai bun decât
mă așteptam, dar lecția cea mai folositoare e despre CE anume poate da un tabel de
date și ce nu.

Rezultat: **139 de întrebări** din 70 de elemente, în două sensuri („simbolul
aurului?” și „ce element are simbolul Au?”), plus alegerea din luptă rescrisă și
două verificări noi, amândouă probate că pot pica.

### Wikidata îți dă faptul, niciodată pedagogia și niciodată gramatica

Asta e concluzia sesiunii, și merită ținută minte înainte de următorul tabel.

Mașina a adus: simbolul (autoritar, CC0), dovada că relația element ↔ simbol e
unu-la-unu, distractorii, id-urile, ambele sensuri, JSON-ul. Adică relațiile și
combinatorica.

Ce a rămas de mână, și n-avea cum să fie altfel:

- **CARE elemente sunt cultură generală** pentru un adult român. Wikidata știe
  toate cele 118, plus 56 ipotetice.
- **CE NIVEL are fiecare.** Vezi mai jos de ce măsurătoarea a picat.
- **GRAMATICA.** „Care este simbolul chimic al aurului?” cere genitivul cu
  articol, iar el nu se calculează din nominativ: aur→aurului, platină→platinei.
  70 de forme, scrise de mână. Plata: întrebarea generată iese **identică** cu
  `mana:0018`, cea scrisă de mână — care e chiar proba pe care voiam s-o dau.

### Nivelul: două măsurători automate, amândouă picate

Cerința era să MĂSOR înainte să aleg metoda, nu s-o presupun. Bine că așa a fost,
fiindcă datele au ieșit altfel decât ghicisem.

**Numărul de ediții Wikipedia** (`wikibase:sitelinks`) separă foarte bine ceva —
doar că nu ce trebuie. Elementele reale stau între 124 și 277 de ediții; cele
ipotetice, între 0 și 57. Deci măsura deosebește „element real” de „căsuță goală
din tabelul periodic”, ceea ce numărul atomic face deja și mai bine. **Între
elementele reale**, decila 1 și decila 9 sunt 132 și 176: o bandă de vreo 1,5×,
pentru o diferență de dificultate care merge de la „o știe oricine” la „doar dacă
te-a interesat”. Și ordinea se contrazice pe bucăți: radonul (nivel III) are 155
de ediții, wolframul (nivel II) are 150; neodimul (III) are 134, molibdenul (III)
are 147. Zgomot cu aspect de cifră.

**„Simbolul se deduce din numele românesc?”** era ideea mai bună — dificultatea
reală nu e cât de celebru e elementul, ci cât de departe e simbolul de cuvântul pe
care-l știi (`oxigen → O` e deducție, `argint → Ag` e memorare). **N-a putut fi
scrisă cinstit.** Testul „subșir” zice că Ag se deduce din argint (a…g, în ordine).
Testul „prefix exact” zice că Zn NU se deduce din zinc și Mg nu se deduce din
magneziu. Un clasificator care greșește în ambele direcții e mai rău decât nicio
automatizare: ascunde o judecată într-o formulă care pare obiectivă.

**Deci nivelul e o coloană scrisă de mână** (20 la nivelul I, 26 la II, 24 la III).
Automat a rămas o singură verificare, îngustă și de încredere: `DIN_LATINA` —
elementele al căror simbol vine dintr-un nume latin DIFERIT de cel românesc (Na,
K, Fe, Ag, Hg, Pb, Sn, Sb, N) nu au voie la nivelul I, fiindcă simbolul lor nu
poate fi dedus, doar știut. Aurul și cuprul vin și ele din latină (*aurum*,
*cuprum*) dar COINCID cu românescul — și exact de-aia aurul e nivelul I, iar
argintul nivelul II.

### Descoperirea din date: Wikidata are 174 de elemente, nu 118

Peste cele descoperite, ține și elementele **ipotetice**, cu numele lor sistematic
(ununennium, unbinilium, unbiquadiu…). Iar **nouă dintre ele au etichetă în
română**, deci filtrul „are etichetă română” — cel decis în sesiunea CONȚINUTUL ca
semn de cultură generală — le-ar fi lăsat să treacă. Nu ajung în joc, fiindcă
tabelul e scris de mână, dar exact așa arată greșeala pe care n-o vezi: într-o zi
în care selecția ar fi mai automată, „unbiquadiu” ar intra ca element de cultură
generală. De aceea scriptul cere acum numărul atomic de la fiecare element ales și
refuză orice Z peste 118 (`ZMAX`).

### Distractorii: regula, și garda care a fost aruncată

Punctajul pornește de la cerință: la „simbolul aurului”, Ag și Al, nu Xe.

| | `cere_simbol` (răspunsul e un simbol) | `cere_nume` (răspunsul e un nume) |
|---|---|---|
| **+100** | simbol cu aceeași primă literă ca cel corect (Au → Ag, Al, Ar, As) | element al cărui simbol începe cu litera simbolului cerut (Hg → hidrogen, heliu) |
| **+50** | simbol care ar putea fi o prescurtare a numelui cerut (sodiu → S, Si, Sc) | nume care începe cu litera simbolului cerut |
| **+10/5** | același nivel / nivel vecin | la fel |

Egalitățile se rup cu un `blake2b` peste (QID-ul întrebării, sens, QID-ul
candidatului) — nu pe QID crescător. Motivul: în Wikidata QID-urile mici sunt
exact elementele celebre (hidrogenul e Q556), deci „la egalitate, QID-ul mai mic”
punea hidrogenul și heliul ca distractori la jumătate din întrebări. „Răspunsul nu
e niciodată hidrogenul” e o scurtătură prin care marchezi puncte fără să gândești,
adică exact ce `_amesteca` din `trivia.gd` a fost scrisă să închidă, reapărută pe
alt drum. `hash()` din Python n-ar fi mers: e sărat la fiecare pornire, deci ar da
alt fișier la fiecare rulare.

**Garda aruncată** merită scrisă, fiindcă e o greșeală de design pe care măsurarea
a oprit-o. Scrisesem „dacă toți trei distractorii încep cu o literă pe care
răspunsul n-o are, schimbă unul”. Am măsurat: tiparul „alege-l pe cel diferit”
mergea la **4 din 139** de întrebări — iar trei dintre ele erau cele mai bune
întrebări din tot lotul:

```
Ce element chimic are simbolul N?   neon / neodim / nichel / AZOT
Ce element chimic are simbolul Na?  niobiu / neodim / neon / SODIU
Ce element chimic are simbolul P?   plumb / poloniu / platină / FOSFOR
```

Grupul de „n”-uri **este** lecția (N e azotul, nu neonul), iar tiparul duce
DEPARTE de răspuns, deci cine se ia după el greșește. Sunt exact elementele din
`DIN_LATINA`. Garda le-ar fi stricat pe toate trei.

A patra era însă un accident curat: `Care este simbolul chimic al uraniului? Cl /
Cu / C / U` — trei simboluri de carbon în jurul uraniului, ieșite din ruperea
egalităților, fiindcă uraniul n-are niciun frate pe litera U.

**Deci regula finală nu e „nu lăsa un grup de litere”, e: un grup e LEGITIM dacă
litera lui e despre întrebare** — prima literă a simbolului cerut sau a numelui
cerut. Altfel e o coincidență și se rupe. A schimbat exact o întrebare din 139 și
n-a atins niciuna din cele trei bune.

Cât de des ies distractori cu aceeași literă: **91 din 139** au toți trei, 18 n-au
niciunul (elementele singure pe litera lor — Li, O, U, Zn, Xe, W, Ti, I, Os). La
alea distractorii sunt metale plauzibile, fără confuzie de litere; sunt întrebări
cinstite, doar mai puțin elegante.

### Fișiere și unelte

`tools/fabrica/elemente.py`, în Python, **numai cu biblioteca standard**:

| comandă | ce face |
|---|---|
| `--masoara` | interoghează (sau citește cache-ul), verifică relația, tipărește distribuția sitelinks și etichetele lipsă. Nu scrie nimic în `data/` |
| (fără flag) | probă uscată: raportul întreg, grila și 15 mostre, fără să scrie |
| `--scrie` | scrie cele două fișiere din `data/` |
| `--reincarca` | reia din rețea și rescrie cache-ul |
| `--seed=N` | fixează sămânța mostrelor, ca să poți reciti exact aceleași 15 |

**Cache comis în Git** (`tools/fabrica/cache/wikidata_elemente.json`), cu data și
interogarea alături de răspuns. Wikidata se editează; vreau să văd diferența CÂND
O CER, nu să apară singură într-un diff din `data/`. Un generator care depinde de o
sursă vie și n-o îngheață nu e un generator, e o rulare norocoasă.

**Contactul pentru User-Agent nu stă în cod.** Wikimedia cere un User-Agent
descriptiv cu un om de contact; scriptul îl citește din `MINDKEEP_CONTACT` sau din
`tools/fabrica/contact.txt` (în `.gitignore`), și se oprește cu un mesaj clar dacă
lipsește — dar **numai când atinge rețeaua**. O rulare din cache nu-l cere, deci
scriptul merge pe orice mașină care are cache-ul.

**Opririle stricte**, în spiritul lui `da_iduri.py`:

- relația element ↔ simbol, verificată unu-la-unu pe toate cele 174;
- fiecare simbol din tabel trebuie să existe, iar eticheta română de la Wikidata
  trebuie să se potrivească cu numele scris de mână (toate neconcordanțele se adună
  și se arată dintr-o dată, nu prima);
- numărul atomic între 1 și 118;
- `DIN_LATINA` la nivelul I;
- **dublurile**, în ambele sensuri: o întrebare scrisă de mână care se suprapune și
  nu e declarată în `DUBLURI` oprește scriptul, dar și o declarație din `DUBLURI`
  care nu se mai găsește în fișier. Prima prinde ziua în care scriu de mână
  „simbolul chimic al fierului” și uit să vin aici; a doua prinde o întrebare bună
  scoasă din joc degeaba.

Azi e o singură dublură: `Au / cere_simbol ← mana:0018`. („Ce element chimic are
numărul atomic 79?” nu e dublură — e altă relație, chiar dacă răspunsul e tot
aurul.)

Fișierul generat se scrie în **același format** ca cel scris de mână (taburi,
`variante` pe un singur rând, linii goale între niveluri), nu cu `json.dump`. Nu e
cochetărie: `json.dump` ar pune fiecare variantă pe rândul ei, iar fișierul ar sări
de la 1200 la 2000 de linii, cu diff-uri pe care nu le mai poți citi când adaugi
patru elemente.

### În joc: alegerea în două trepte

Datele **nu mai sunt echilibrate** și nu pot fi: știința are 47/60/56 de întrebări
pe nivel, mitologia 7/7/7. Dacă alegerea ar fi rămas „trage din tot nivelul”,
știința ar fi luat 55–62% din întrebări (măsurat) și „Cultură generală” ar fi
devenit „Chimie, cu accidente”.

Deci **echilibrul s-a mutat din date în ALEGERE**, unde nu depinde de cât de mare
crește un domeniu: întâi domeniul, uniform între cele prezente la nivelul cerut,
apoi întrebarea. Aceeași formă ca la Logică, unde alegerea în două trepte e chiar
ce împiedică „Fibonacci” să apară cât toate celelalte la un loc.

Alegerea a ieșit din `_compune_intrebare` într-o funcție **statică**,
`trage_intrebarea(nivel)`, ca s-o poată chema verificarea headless. Altfel
verificarea ar fi trebuit să rescrie alegerea la ea, și ar fi probat copia, nu
codul.

**Capcana sacului, cea despre care eram avertizat.** `Sac.extrage` golește tot
registrul unei chei când lista primită se epuizează. Alegerea în două trepte îi dă
o listă filtrată pe UN domeniu, deci cu cheia veche `cultura_generala:1` epuizarea
științei ar fi șters și memoria geografiei, a istoriei și a celorlalte de pe același
nivel. Cheia e acum `cultura_generala:<domeniu>:<nivel>`, compusă într-un singur
loc (`cheia_sacului`), ca verificarea să folosească exact cheia luptei. Efect
secundar bun: garanția devine „nicio repetiție ÎN CADRUL unui domeniu”, care e mai
tare, nu mai slabă.

**Comutatorul** e o singură constantă: `FOLOSESTE_WIKIDATA` în `trivia.gd`. `false`
și jocul nu mai vede nici întrebările fabricate, nici faptele lor.

### Cifra pe care vreau s-o am sub ochi

Știința e acum ~85% chimie la fiecare nivel. Cu alegerea uniformă pe domenii,
știința ia o șesime din întrebări, deci **cam 1 din 7 întrebări de luptă e
„element ↔ simbol”**. Pentru un pilot e bine — le vezi destul ca să-ți formezi o
părere. Dacă se simte prea mult, pârghia NU e o a treia treaptă de alegere
(mașinărie care ascunde problema), e lățimea conținutului. Sau comutatorul.

Alt lucru de urmărit pe mână: la nivelul I s-a format un **cvartet închis** —
`C / Ca / Cl / Cu` apar ca aceleași patru butoane la opt întrebări (carbon,
calciu, clor, cupru, în ambele sensuri). Ca exercițiu de discriminare e bun; ca
senzație într-o luptă, poate părea că baza e subțire. De văzut jucând.

### Verificatorul: două verificări noi, amândouă probate că pot pica

`tools/verificari/verifica_trivia.gd` are acum șase secțiuni. Cele noi:

**ECHILIBRUL PE DOMENII** — 6000 de trageri pe fiecare nivel, prin chiar
`TRIVIA.trage_intrebarea`, cu cerința ca fiecare domeniu să iasă la 1/N ± 20%.
Ținta e 1/N, nu 1/6: dacă un nivel n-are mitologie, celelalte cinci împart tot.
Rezultat: abatere maximă 5,3%.

**SACURILE NU SE AMESTECĂ** — se golește complet știința de nivelul I, apoi se
întreabă arta dacă își mai ține minte biletele.

Amândouă au fost **probate rupând codul intenționat**, fiindcă un test care nu
poate pica nu verifică nimic:

| ce am rupt | ce a picat |
|---|---|
| scos treapta domeniului din alegere | echilibrul: știința 3294 din 6000 la nivelul I, abatere 229% |
| scos domeniul din cheia sacului | „arta își ține minte”: `mana:0029` a ieșit de două ori într-un ciclu |

Și un rezultat care justifică singur testul țintit: **cu cheia ruptă, secțiunea
SACUL a trecut liniștită** („18 chei fără nicio repetiție”). Fiecare buclă de acolo
trage exact cât are lista ei, deci nu ajunge niciodată la reciclare. Doar testul
care golește un domeniu și întreabă altul prinde greșeala.

Celelalte schimbări din verificator:

- `CATE_INTREBARI` a devenit `CATE_INTREBARI_MANA` (135). Pentru fișierul fabricat
  nu se scrie nicio cifră: crește de câte ori adaug un element, iar o cifră aici ar
  fi o a doua editare la fiecare schimbare de conținut — adică exact felul de
  verificare pe care începi s-o actualizezi mecanic. Pentru el se cere
  **invarianta**: încărcate == găsite (274 din 274).
- **forma id-ului e acum pe prefix.** Verificarea veche cerea „prefix, două puncte,
  cifre” pentru orice id, scrisă dinadins ca să nu depindă de prefix — și a fost
  picată de chiar primul prefix nou: `wd:Q897:simbol:cere_nume` are patru bucăți și
  niciuna nu e un număr. Acum `mana:` cere cifre, `wd:` cere `Q<cifre>:relație:sens`,
  iar un prefix necunoscut **cade dinadins**: dacă apare o fabrică nouă, vreau să
  vin să scriu ce formă are.
- SACUL probează 18 chei (domeniu × nivel), nu 3, și **sare peste sacurile cu o
  singură întrebare** la proba răscrucii: acolo regula nu se poate respecta, iar
  `sac.gd` o încalcă dinadins.

### Regula care trebuie scrisă acum, ca să nu se piardă

`data/fapte_trivia_wd.json` se **rescrie întreg** la fiecare rulare. Deci
**notele pentru faptele `wd:` NU pot sta în el** — prima regenerare le-ar șterge.
Când vor exista note, ele vor sta într-unul din două locuri:

1. în `data/fapte_trivia.json`, cel scris de mână, cu `id`-ul `wd:Q897` — generarea
   nu-l atinge niciodată; **sau**
2. scriptul învață să PĂSTREZE `nota`, `surse` și `verificat` pentru id-urile care
   există deja în fișierul generat, și rescrie doar restul.

Nu s-a implementat nimic azi, dinadins: cele 70 de fapte au nota goală și n-are ce
să se piardă. Dar decizia trebuie luată **înainte** de prima notă scrisă.

Fișierul de fapte fabricate există dintr-un motiv mai mic și mai practic: fără el,
jocul ar porni cu 139 de avertismente „faptul `wd:Q897` nu există”, iar de-acolo
încolo consola nu mai e un loc unde se citește ceva.

### Verificat

- `--masoara`: relația unu-la-unu pe 174 de elemente, 118 reale, 118 cu etichetă
  română, 9 ipotetice care trec prin filtrul de etichetă.
- `--scrie`: 139 de întrebări, 70 de fapte, JSON valid citit înapoi, id-uri unice
  în fișier și peste cel scris de mână (135 + 139).
- Citite cu ochiul toate cele 139 de întrebări, în ambele sensuri.
- Verificarea headless: **TOTUL E BUN**, 15 verdicte OK.
- Ambele verificări noi, probate rupând codul (tabelul de mai sus).

### Ce NU s-a făcut

- **Nicio notă.** Cele 70 de fapte fabricate au `nota: ""`.
- **Nicio partidă jucată** cu conținutul nou. Cifra de 1 din 7 și cvartetul
  `C/Ca/Cl/Cu` sunt de simțit, nu de calculat.
- **Verificarea notelor din pilot** (punctul 2 din „Imediat”) rămâne nefăcută.

### Fișiere

Nou: `tools/fabrica/elemente.py`, `tools/fabrica/cache/wikidata_elemente.json`,
`data/intrebari_trivia_wd.json`, `data/fapte_trivia_wd.json`.
Atinse: `scenes/trivia/trivia.gd` (comutator, al doilea fișier, `trage_intrebarea`
și `cheia_sacului` scoase ca funcții statice, `_incarca_fisier`, `_incarca_fapte`
pe cale), `tools/verificari/verifica_trivia.gd` (șase secțiuni), `.gitignore`
(`tools/fabrica/contact.txt`), `docs/progres.md`.

---

## CONȚINUTUL (27 septembrie 2026) — de la 135 de întrebări la câteva mii

**Sesiune de design, fără nicio linie de cod.** A pornit de la o problemă
simplă: cele 135 de întrebări de Cultură generală le știu deja pe de rost. S-a
încheiat cu un plan pentru mii de întrebări, pentru notele „Află mai multe” și
pentru modul Practice. Deciziile stau acum și în `CLAUDE.md`, într-un tabel nou
(„Cultura generală: conținut și Practice”).

### Problema nu e doar a mea

Sacul se golește la fiecare expediție nouă, deci fiecare expediție trage din
aceleași 45 de întrebări pe nivel. Eu am ajuns primul la capăt fiindcă joc mult,
dar cineva care joacă 15 minute pe zi ajunge acolo în câteva săptămâni. Iar o
întrebare învățată e o întrebare gratis, exact argumentul din `sac.gd`.

Nici „mai scriu 100” nu rezolvă: e o bandă rulantă. Scrii 100, le înveți, scrii
alte 100.

### Fabrica de întrebări

Un script Python care rulează pe calculator, nu în joc: ia fapte din surse
verificabile, compune întrebările, le validează și scrie un singur JSON. Jocul
rămâne cum e, cu `trivia.gd` trăgând dintr-o listă finită, doar mai lungă.

De ce nu în joc: generarea din tabele în timpul jocului (ca la Logică) ar muta
Cultura generală de pe garanție pe reîncercare și n-aș mai putea verifica
întrebările una câte una. Generarea cu un model de limbaj în timpul jocului e și
mai rea: internet, cost la fiecare întrebare, întârzieri peste cronometrul de
12 s și nicio verificare înainte să ajungă la jucător.

| Sursă | Ce aduce | Atenție |
|---|---|---|
| Wikidata | Volumul: țări, elemente, opere, autori, planete, cu etichete în română. Numărul de ediții Wikipedia ale unui subiect dă un prim nivel automat | Subiectele fără etichetă în română probabil nu sunt cultură generală pentru un jucător român |
| Scrise de mână | Istoria, literatura, geografia României; întrebările cu personalitate | Lente, deci rămân nucleul, nu volumul |
| Model de limbaj | Formularea întrebărilor și a notelor, din fapte date | Niciodată sursa faptului |

Ca reper: 5000 de întrebări înseamnă aproximativ 110 expediții lungi fără nicio
repetare (o expediție lungă consumă ~15 pe nivel), adică 3–4 luni de joc zilnic.

### Notele „Află mai multe”

Regulile sunt în **`docs/ghid-note.md`**, cu un pilot de 15 fapte care acoperă 18
întrebări existente. Toate notele pilotului sunt `verificat: false`.

Descoperirea sesiunii: contractul din `puzzle.gd` are deja un câmp `explicatie`,
pe care Trivia îl lasă gol și pe care nimic nu-l afișează încă. Nota e ce intră
acolo, iar Practice va fi primul loc care arată câmpul, pentru toate
disciplinele.

Nota stă pe **fapt**, nu pe întrebare: faptul `aur` acoperă și „simbolul
aurului” (nivelul I), și „numărul atomic 79” (nivelul III). Faptele vor sta în
`data/fapte_trivia.json`, tot ca listă, ca să le poată citi
`citeste_lista_json` fără nicio schimbare.

### Practice (pasul 13)

- Alegi **domeniul**, nu nivelul.
- Pornești de la nivelul I. **Nivelul II se deblochează la un prag fix**: 60 de
  răspunsuri corecte la întrebări distincte, ca cifră de pornire, reglabilă ca
  `DISCIPLINE_IN_LOADOUT`. Nu „toate corecte”: aia ar fi fost un zid la final
  (247 din 250, blocat de trei întrebări grele) și ar fi crescut odată cu
  conținutul.
- După deblocare, **nivelurile se amestecă**: majoritatea din nivelul curent,
  plus întrebări de dedesubt nevăzute sau greșite. Nimic nu se pierde.
- **Greșitele revin**, la orice nivel. **„Învățat”** cere 2–3 răspunsuri
  corecte la distanță în timp; învățatele ies din joc și intră în Jurnal.
- **Conținutul nou intră în amestec**, nu te trimite înapoi la un nivel
  terminat.
- **Progresul se vede** pe fiecare domeniu: „Nivel I · 42 / 60 până la nivelul
  II”.
- „Află mai multe” apare după greșeli și, mai discret, și după răspunsurile
  corecte, fiindcă unul din patru poate fi ghicit.

### Imagini la „Află mai multe” (decis 29 septembrie 2026)

Pe lângă notă, un fapt poate ține o **imagine**, tot ca **câmp opțional**: unde
nu există, popup-ul arată exact ce arăta și înainte. Motivul: unele fapte se
înțeleg dintr-o privire, nu din 240 de caractere — unde e Bolivia, cum arată
„Coloana fără sfârșit”, în ce ordine vin trei domnitori.

Două feluri, cu costuri complet diferite:

**1. Desenate de joc, din date.** Hărțile se desenează în Godot din contururi
vectoriale în domeniul public (Natural Earth), în stilul jocului: pergament,
cerneală, culorile hărții de expediție. Faptul nu ține o poză, ține doar **ce se
desenează** (ex. codul țării), iar același desenator servește toate faptele de
geografie. Aceeași unealtă poate da **axe ale timpului** pentru întrebările cu
date istorice — o linie, un semn, un an. Avantajul: nicio licență de urmărit,
aproape nicio greutate (contururi simplificate, nu imagini) și arată a joc, nu a
captură de ecran.

**2. Imagini reale**, pentru ce nu se poate desena: tablouri, portrete,
monumente. Sursa e **Wikimedia Commons, prin Wikidata** — imaginea stă ca
proprietate pe entitate, deci vine în aceeași interogare cu faptul. Fiecare
imagine salvează **autorul și licența**, fabrica **refuză orice imagine fără
licență clară** (aceeași regulă ca la frazele din Wikipedia: nu se ia ce nu se
poate da mai departe), iar jocul **arată creditul** lângă imagine. **Arta
modernă protejată nu intră**: un tablou din 1950 rămâne sub drepturi chiar dacă
fotografia lui stă pe Commons.

Constrângerea care le ține pe amândouă cinstite: **mici (~400 px) și doar unde
adaugă ceva**. Build-ul web e demo, iar câteva mii de fapte cu câte o poză ar
cântări mai mult decât tot restul jocului. O imagine care doar însoțește textul e
greutate; una care răspunde la „unde?” sau „cum arăta?” e conținut.

Se implementează la **pasul 13**, odată cu Practice — mai devreme n-ar avea unde
să se vadă.

### Țintele: 500 pe celulă, dar nu peste tot

6 domenii × 3 niveluri = 18 celule. Ținta e 500 de întrebări pe celulă acolo
unde domeniul le poartă. Nivelul I e plafonat de propria definiție: din folclor,
un adult obișnuit știe poate 100–150 de lucruri. Umflarea lui ar însemna ori
întrebări mai grele cu eticheta greșită, ori același fapt în multe formulări,
adică o repetare deghizată.

*Rescris pe 6 octombrie 2026, pe domeniile noi. Artă, mitologie și literatură
erau trei rânduri cu „greu” și „la limită” la nivelul I; unite, duc nivelul I
mult mai bine decât oricare din ele separat — pictura, cărțile, muzica clasică și
folclorul au împreună destule lucruri pe care le știe orice adult. Asta n-a fost
motivul unirii, dar e un câștig care merită numit.*

| Domeniu | Nivel I | Nivel II | Nivel III |
|---|---|---|---|
| Știință și natură | realist | realist | realist |
| Geografie | realist | realist | realist |
| Artă și literatură | realist | realist | realist |
| Istorie | la limită | realist | realist |
| Divertisment | realist | realist | la limită |
| Sport și timp liber | realist | realist | la limită |

Divertismentul și Sportul sunt pe dos față de celelalte: nivelul I e ușor (filme
și campioni pe care îi știe toată lumea), iar nivelul III e greu **nu din lipsă
de fapte, ci din regula „numai trecut, cu data spusă”** (`docs/ghid-note.md`) —
care taie exact întrebările de cunoscător despre ce se întâmplă acum.

Designul Practice face asta acceptabil: jucătorul stă pe nivelul I doar cât îi ia
pragul, deci nivelul I are nevoie de 150–250 de fapte bune, nu de 500. Cele 500
contează la nivelurile II și III, acolo unde conținutul le poate susține.
**Atenție**: ultima propoziție a fost scrisă înainte de paliere și e acum în
tensiune cu ce trage lupta — vezi „Rămas deschis”, în aceeași sesiune.

Raportul fabricii arată la fiecare rulare **grila de 6 × 3, cu întrebări ȘI
fapte** pe fiecare celulă. Cel mult 2–3 întrebări pe fapt.

Efortul real e în note, nu în întrebări: 9000 de întrebări înseamnă poate
3000–4000 de fapte, fiecare cu o notă de verificat. Chiar cu validatorul automat,
citirea unei mostre e muncă de luni.

### Decizii ieftine acum, scumpe mai târziu

- **`id` stabil pe fiecare întrebare** (`mana:0001`, `wd:…`). Azi identitatea din
  sac e textul; la prima reformulare, save-ul ar crede că e o întrebare nouă. Se
  face **înainte de Save**, cât identitățile n-au ajuns încă pe disc.
- **Sacul Culturii generale devine permanent**, la Save. Azi se golește la
  fiecare expediție, deci chiar și cu mii de întrebări ar apărea repetări după
  câteva expediții (paradoxul zilelor de naștere, între expediții). La mii de
  elemente, `Array.has()` din `sac.gd` se înlocuiește cu un Dictionary folosit ca
  mulțime, cum anticipează deja comentariul de acolo.
- **În Practice, cheia sacului include filtrul** (`practice:istorie:2`).
  Capcana: `Sac.extrage` golește tot registrul unei chei când se termină lista
  primită. Cu cheia din luptă și o listă filtrată doar pe istorie, terminarea
  istoriei ar șterge și memoria geografiei.
- **`etichete` pe fapt**, opționale, de acum, chiar dacă interfața vine abia la
  pasul 13.

### Atenție la testare

Cât timp știu toate răspunsurile, luptele mele nu mai spun nimic despre
dificultatea Culturii generale: recunosc întrebarea în loc să mă gândesc la ea.
**Nu reglez cronometrul sau daunele Culturii generale pe baza propriilor lupte**
până nu apare conținut nou.

### Rămas deschis

- **Deblocarea treptată a disciplinelor** — propunere discutată, nedecisă. Ideea:
  pornești cu puține discipline și le deblochezi pe celelalte. Recomandarea a fost
  **două la început, nu una** (Cultură generală + Logică): cu un singur Obelisc,
  prima greșeală îl blochează până la final de rundă, PA 2 și 3 nu mai folosesc la
  nimic și lupta devine un quiz. Deblocarea ar veni prin clădirile Cetății, prima
  încă din prima sesiune. Depinde de Cetate (7) și Save (8). În cod: loadout-ul
  filtrează `CATALOG` după cele deblocate, N devine minimul dintre N și câte ai,
  `_curata_loadout` completează doar din cele deblocate, iar alegerea inamicului
  ține cont de ele (Spadasinul, vulnerabil la Cuvinte, nu apare înainte de
  Cuvinte).
- **Istoric comun între Practice și expediții, cu sacuri separate** — recomandat,
  de confirmat la pasul 13. Altfel exersez o întrebare dimineața și o primesc
  gratis în luptă seara.
- **Pragul de 60** — cifră de pornire, nejucată.
- **Lungimea notelor** — maximum 240 de caractere, de recalibrat pe popup, pe
  telefon.
- **`explicatie` la Logică** e numele regulii cu majuscule („FIBONACCI”). E bun ca
  etichetă, nu ca notă; pentru „Află mai multe” va trebui o propoziție.
- **Ce face Practice cu faptele `verificat: false`** — le refuză sau le arată fără
  notă. Se decide când există modul.
- **Nivelul I e cel mai greu de umplut ȘI cel mai tras în luptă** — tensiune
  văzută pe 6 octombrie 2026, nehotărâtă dinadins.

  Țintele de mai sus („nivelului I îi ajung 150–250 de fapte, cele 500 contează
  la II și III”) au fost gândite pe **30 septembrie**, când nivelul urca la
  fiecare treaptă: treapta 1 era nivelul I, treapta 2 nivelul II, iar toată coada
  lanțului nivelul III. Pe atunci nivelul I primea o întrebare pe activare, deci
  „mai puțin conținut la I” era o economie care nu se simțea.

  De când `TREPTE_PE_NIVEL = 3`, repartiția s-a întors: **~49% din întrebările
  unui lanț cad pe nivelul I**, ~25% pe II, ~26% pe III (socoteala e în sesiunea
  DOMENIILE). Deci nivelul cu cel mai puțin conținut *posibil* — plafonat de
  propria definiție, „o știe orice adult” — e acum cel mai consumat. Cele două
  decizii sunt amândouă bune și se bat cap în cap.

  Două ieșiri, și aleg una când simt problema jucând, nu acum:

  1. **Mai mult conținut de nivel I**, adică ținta de la I urcă spre 400-500 și
     accept că o parte din el va fi greu de scris fără să alunece spre nivelul II.
     Prețul: exact repetarea deghizată de care se ferea plafonul.
  2. **Altă valoare pentru `TREPTE_PE_NIVEL`** — 2 ar muta ~33% pe fiecare nivel
     și ar apropia consumul de conținutul disponibil. Prețul: se pierde chiar ce a
     adus paliere pe 30 septembrie, panta de la începutul lanțului, și prima
     treaptă critică (a 5-a) ar cădea iar în platoul de nivelul III.

  Nu se hotărăște din socoteală: cifrele spun doar că tensiunea e reală, nu care
  jumătate doare mai mult. Ce lipsește e o expediție jucată cu conținut de nivel I
  pe care **nu-l știu pe de rost** — adică nu se poate afla înainte să existe.

### Fișiere

Nou: `docs/ghid-note.md`. Atinse: `CLAUDE.md` (tabelul de decizii, pasul 13 din
rută), `docs/progres.md` (antetul, rândul 9, sesiunea asta, lista „Imediat”).
Cod: niciunul.

---

## DIFICULTATEA SE MĂSOARĂ (25 septembrie 2026) — un rezolvitor care gândește ca un om

Toate cele trei niveluri ale Lacătului erau prea ușoare, nivelul 3 inclusiv.
Cauza nu era în tabelul de dificultate, era în **alegerea lacomă**: la fiecare
pas, generatorul lua indiciul care taie cele mai multe coduri, iar campionul
absolut la tăiat e egalitatea („A și B sunt egale") — scoate 8 din 9 coduri
dintr-o lovitură. Două egalități și o sumă, și codul pica singur.

Și, ironia întreagă: **plafonul de 3 indicii pus ca să facă nivelul 3 greu era
exact ce-l făcea ușor.** Cerându-i generatorului să încapă în trei rânduri, îl
obligam să aleagă numai indicii brutale.

Deci dificultatea nu se mai reglează din numărul de indicii. Se **măsoară**.

### `RezolvitorCifru` — deduce, nu caută

Fișier nou, lângă generator. Nu verifică unicitatea (aia rămâne dovedită prin
forță brută, unde ai nevoie de certitudine, nu de imitarea unui om). Singurul
lui rost e să dea o NOTĂ.

Ține, pentru fiecare roată, lista cifrelor încă posibile — „domeniul" — exact ca
un om cu creionul. Are trei unelte, încercate mereu de la ieftin la scump:

| | ce face |
|---|---|
| **T1** | un singur indiciu, stors de unul singur: taie cifrele pentru care nu mai există nicio completare a celorlalte roți |
| **T2** | două indicii cerute simultan; perechile fără roată comună se sar, fiindcă acolo n-ai afla nimic peste T1 |
| **T3** | presupui o cifră, propagi cu T1/T2, iar dacă ajungi la o roată fără nicio cifră posibilă, presupunerea era falsă — o elimini și te întorci la T1 |

**Nota = cea mai grea unealtă de care a fost nevoie.** Ordinea contează enorm:
dacă ar sări direct la T3, toate puzzle-urile ar primi nota 3. „Nota 3" înseamnă
„a existat un moment în care nimic mai simplu nu mai mergea".

T3 nu rezolvă puzzle-ul, îl **deblochează**: se oprește după prima eliminare și
urcă înapoi la T1, fiindcă de obicei tăietura repornește o cascadă de deducții
simple. E ranga, nu ciocanul. Și e o tehnică cinstită, nu ghicit, pentru că nu
păstrăm niciodată o presupunere care a MERS — doar concluzii negative obținute
din contradicție.

### Tabelul de dificultate, rescris

| nivel | nota | alegere | egalități | indicii |
|---|---|---|---|---|
| 1 | T1 | lacom | fără limită | ≤ 6 |
| 2 | T2 | lacom | fără limită | ≤ 6 |
| 3 | **T3** | **cumpătat** | **cel mult 1** | ≤ 8 |

Puzzle-ul se generează ca înainte, apoi trece prin rezolvitor; dacă nota nu e cea
cerută, se aruncă și se încearcă altul. Plafonul de 3 indicii de la nivelul 3 a
dispărut — `indicii_maxime` și-a recăpătat înțelesul onest de limită de ECRAN
(coloana are loc de vreo 13 rânduri; 8 e prudent).

**„Cumpătat"** e reglajul care contează: alegerea nu mai ia mușcătura cea mai
mare, ci merge printr-o ordine trasă la sorți. Cu două excepții, amândouă
descoperite măsurând:

- **deschidere lacomă de 2 indicii** — nicăieri nu stă dificultatea în prima
  tăietură. Fără ea, plimbarea pornea de la 6561 de coduri cu mușcături mici și
  aduna 40 de indicii până să izoleze codul;
- **se sare peste indiciile care nu mai taie nimic**, definitiv — un indiciu care
  nu taie acum nu va tăia nici mai târziu, fiindcă mulțimea doar se micșorează.

Limita de egalități se aplică **după semn, nu după tip**: orice „=" plus
DIFERENTA. O listă de nume de tipuri ar rămâne în urmă la primul tip nou.

### Un singur tip `SUMA`

`SUMA_DOUA` și `SUMA_TOTALA` s-au contopit în `SUMA {pozitii, semn, valoare}`.
Nevoia a venit din **sumele de trei** — cele mai bune indicii pentru nivelul 3,
fiindcă vorbesc despre trei roți și îți spun pe ocolite ceva și despre a patra.
Ca tip separat, ar fi fost a treia copie a aceleiași idei în `evalueaza()`, în
`text()` și în `_candidati()`, iar un lacăt de 5 roți ar fi cerut a patra. Acum
„suma a k roți" e o buclă peste submulțimi, nu un tip.

Textul e uniform: „A + C + D e mai mică decât 17", inclusiv pentru suma completă
(a înlocuit „Suma tuturor cifrelor e…"). Mai lung cu câteva litere, dar toate
sumele arată la fel.

### Ce a costat, și cum s-a plătit

O generare de nivel 3 a ajuns, în prima variantă care mergea, la **18,7
secunde**. Profilarea pe faze (candidați / plimbare / curățare / notare) a arătat
patru cauze, toate ascunse:

1. **`da_o_cifra()` parcurgea universul în ordine de contor**, iar ultima roată
   stă neschimbată 729 de coduri la rând — ieșirea devreme nu se declanșa
   niciodată. Acum sare cu un pas prim față de mărimea listei: atinge fiecare cod
   exact o dată, dar vede valori variate din primele zeci.
2. **`egalitati_maxime: 1` înfometa poolul.** Scoțând sumele exacte ȘI
   diferențele, rămâneau ordine, paritate, extreme și o inegalitate pe sumă —
   de multe ori pur și simplu insuficient ca să izolezi un cod. 95% din încercări
   se aruncau. Rezolvat cu **trei praguri diferite pe aceeași sumă** în loc de
   unul: „A + C + D > 12" și „A + C + D < 19" sunt afirmații diferite, amândouă
   adevărate.
3. **`_curata()` refăcea de zece ori aceeași filtrare.** Acum ține un **lanț de
   prefixe**: `prefix[k]` = codurile care trec de primele `k` indicii, iar proba
   pentru indiciul `i` pornește din veriga `i`, nu de la 6561.
4. **Sonda de alegere era de 1500 de coduri**, pentru o întrebare care n-are
   nevoie de precizie („care candidat taie cel mai mult?"). Coborâtă la 200.

Rezultat: **18,7 s → 1,24 s** în medie la nivelul 3 (64 ms la nivelul 1, 104 ms
la nivelul 2).

### Firul separat

1,24 s pe firul principal înseamnă un joc care pare mort. Generarea pleacă acum
pe `WorkerThreadPool` în prima linie din `porneste()`, iar așteptarea se
**suprapune peste răgazul de o jumătate de secundă** în care vezi cufărul întreg
— răgaz care exista oricum. Bucla cedează un cadru la fiecare tur în loc să
cheme `wait_for_task_completion()` direct, ca jocul să continue să deseneze.

E sigur fiindcă `GeneratorCifru` e logică pură: niciun nod, niciun `Tween`, RNG
propriu. Ăsta e dividendul regulii „cine calculează nu desenează" — separarea
făcută din curățenie e ce face mutarea posibilă în zece rânduri.

Măsurat în joc: 2,06 s de la `porneste()` la apropiere pe o sămânță nefericită
de nivel 3, cu jocul viu tot timpul. La nivelurile 1 și 2, puzzle-ul e gata mult
înainte, deci așteptarea e exact răgazul de dinainte, neschimbat.

### Verificatorul raportează dificultate, nu doar corectitudine

Pe fiecare nivel: **distribuția notelor**, tipurile de indiciu (cu `SUMA`
desfăcută pe număr de poziții și semn — `SUMA-3 <` și `SUMA-2 =` sunt unelte
diferite cu același nume de tip), media indiciilor, timpul unei generări și al
unei notări. Plus trei verificări noi:

- **nota livrată e cea cerută de nivel**;
- **rezolvitorul și forța brută ajung la același cod** — păzitorul păzitorului: un
  bug în rezolvitor n-ar crăpa nimic și n-ar da niciun simptom, ar da doar note
  greșite, adică un tabel de dificultate care minte în tăcere;
- **cel mult o egalitate la nivelul 3**, prin aceeași funcție pe care o folosește
  generatorul.

Cu o nuanță care a ieșit din prima rulare mare: puzzle-urile care ies pe **ușa
din dos** (toate cele 60 de încercări epuizate, se livrează cel mai apropiat
puzzle corect) se numără SEPARAT și au voie până la 2%. Supapa aia e proiectată,
nu stricată — mai bine un lacăt cu o treaptă mai jos decât un joc care se oprește
din mers. Ce rămâne eroare e nota greșită FĂRĂ ca rezerva să fi intrat în joc:
aia ar însemna că filtrul de dificultate a acceptat ceva ce trebuia să respingă.

`SEMINTE` a scăzut de la 500 la 200: la o secundă și un sfert pe generare, 500 ar
fi însemnat peste o jumătate de oră, iar o unealtă pe care n-o mai pornești nu
mai apără nimic.

**Rezultatul pe 600 de puzzle-uri (200 pe nivel):**

| nivel | nota livrată | indicii | o generare |
|---|---|---|---|
| 1 | T1 **200/200** | 3,00 | 68 ms |
| 2 | T2 **200/200** | 3,98 | 116 ms |
| 3 | T3 **199/200** | 6,70 | 1387 ms |

Singura excepție de la nivelul 3 e o sămânță din 200 (0,5%) care a epuizat
încercările și a primit un puzzle T2 — supapa, în limitele ei. Distribuția de
tipuri de la nivelul 3 e exact pe brief: paritate 20%, inegalități de sumă 37%,
extreme 12%, relații de ordine 13%, egalități sub 8%.

---

## CUFĂRUL (24 septembrie 2026) — Lacătul nu mai e un desen, e un obiect

Lacătul are de azi artă adevărată: două imagini de cufăr (închis și deschis),
cu **ferestrele tăiate ca găuri transparente** în placa de metal. Toată scena
s-a rescris în jurul lor. Contractul a rămas neatins: `porneste(nivel, samanta)`
și `rezolvat(succes)`.

`assets/art/cifru/` — `cufar_inchis.png`, `cufar_deschis.png` (1990 × 1529,
încadrate identic la pixel) și `ferestre.json`, cu pozițiile celor patru
ferestre. Pozițiile se CITESC din JSON; niciun număr de artă nu e scris în cod.
Dacă arta se redesenează, fișierul vine odată cu ea și codul nu află niciodată.

### Straturile, și de ce ordinea lor e tot desenul

```
Cifru (Control)
├─ Fundal                        o culoare caldă, întunecată
├─ Platou (Node2D)  ← CAMERA: tot ce e aici se apropie împreună
│   ├─ Halou                     pată de lumină caldă, sub cufăr
│   ├─ Benzi (4 × BandaCifre)    cifrele, desenate din cod
│   ├─ Cufar (Sprite2D)          IMAGINEA, cu ferestrele transparente
│   ├─ Litere (A B C D)          peste placă, sub ferestre
│   └─ Stralucire (Sprite2D)     a doua copie a imaginii: fulgerul
└─ Interfata (Control)           indicii, încercări, buton — nemișcate
```

**POZA E MASCA.** Banda de cifre se desenează ÎNAINTE de imaginea cufărului,
deci imaginea se așază peste ea. Poza e opacă peste tot în afară de cele patru
ferestre, care sunt găuri adevărate în PNG — așa că ce se vede din bandă e exact
ce lasă gaura să treacă. N-am tăiat nimic și n-am scris nicio mască.

Singura grijă care rămâne: banda n-are voie să crească mai mare decât placa de
metal din jurul ferestrei, fiindcă dincolo de marginile cufărului poza e iar
transparentă și cifrele ar ieși în aer. De-aia desenează doar cinci cifre în
jurul celei curente, nu toate nouă. Și tot de-aia banda își pictează ÎNTÂI un
fond întunecat: altfel s-ar vedea prin gaură fundalul scenei, și ai avea un
lacăt cu ferestre spre nicăieri.

### Camera, din două cifre

`Platou` e un `Node2D` căruia i se schimbă `position` și `scale`. **Nu**
`Camera2D`: aia nu mișcă un obiect, ci pânza întregului viewport — iar Lacătul
o să fie deschis din nodul de Eveniment, adică PESTE hartă, și ar trage
pergamentul după el. Cauza ar fi de negăsit dintr-un fișier care nici nu
pomenește harta.

Tot calculul iese din două constante: cât de lată vrei o fereastră pe ecran
(`LATIME_FEREASTRA_TINTA = 80`) și în ce punct al ecranului vrei centrul celor
patru (`TINTA_APROAPE = 0.33, 0.42` — stânga de centru, ca să rămână loc de
indicii în dreapta). Scara iese din prima, poziția din a doua. Măsurat: o
fereastră ajunge la **78,9 px** pe un ecran de 1152 × 648, iar placa ocupă cam
două treimi din lățime.

La pornire se vede cufărul ÎNTREG, o jumătate de secundă (`RAGAZ_DEPARTE`), și
abia apoi se apropie. Răgazul nu e decor: prima versiune pleca direct în
apropiere și, cu o mișcare care începe repede, cufărul întreg se vedea două
cadre — adică deloc. Primul lucru pe care trebuie să-l pricepi e CE e obiectul;
abia al doilea, la ce te uiți din el. Roțile se pot atinge doar după ce
apropierea s-a terminat.

### Roțile: o bandă fără capete

`banda_cifre.gd` desenează o panglică de cifre care se repetă la infinit
(`posmod` peste numărul treptei: treapta −1 e tot o cifră bună). Peste cifre, un
degrade întunecat sus și jos — fără el banda arată ca o listă care alunecă; cu
el, ca o suprafață care se curbează și fuge din fața ochiului.

**În repaus se vede exact o cifră**, întreagă, iar vecinele stau ascunse în
spatele metalului: pasul dintre cifre (`PAS_CIFRA = 1,12`) e mai mare decât
înălțimea ferestrei. Sub 1, vecinele își arătau permanent câte o bucată, iar
fereastra devenea o listă din care citești, nu un cifru. Cât tragi de roată,
cifrele intră și ies prin fereastră ca înainte, doar că trec una câte una.

Mărimea cifrei nu mai e o mărime de font, ci o **fracțiune din fereastră**
(`INALTIME_CIFRA = 0,70`), tradusă în font prin `RAPORT_CIFRA = 0,72` — cât din
mărimea unui font ocupă efectiv o cifră. Sunt două constante, nu una, fiindcă
prima e o preferință de compoziție, iar a doua o proprietate a fontului: în ziua
în care Mindkeep primește un font propriu, se re-măsoară doar a doua.

Controlul:

- **tragi** — banda urmărește mouse-ul 1:1. Pixelii de ecran se împart la scara
  camerei ca să devină pixeli de imagine: altfel tragerea ar fi de trei ori mai
  „grea" când placa domină ecranul;
- **la eliberare** — inerție cu frânare exponențială (`exp(-k·dt)`, ca să nu
  depindă de câte cadre pe secundă merge jocul), apoi așezare lină exact pe o
  cifră;
- **rotița și tastatura** — un pas animat; tastarea unei cifre o duce pe drumul
  cel mai scurt (de la 9 la 1 e o treaptă în sus, nu opt în jos);
- **un clic** la fiecare cifră peste care trece centrul ferestrei.

Toate numerele de senzație — `FRECARE`, `VITEZA_DE_ASEZARE`, `ASEZARE`,
`VITEZA_MAXIMA`, `PAS_CIFRA`, `DURATA_UNUI_PAS` — sunt constante cu nume, sus în
fișier, cu explicația în ce direcție să le muți.

### Deschiderea, și cum ascunde fulgerul înlocuirea imaginii

Cinci mișcări, ≈2,6 s în total, fiecare cu constanta ei:

1. roțile se aprind pe rând, stânga → dreapta, cu câte un clic (0,12 s fiecare);
2. camera se retrage la cufărul întreg (0,7 s), iar panoul de indicii se stinge
   în 0,3 s — mai repede decât camera, ca să fie dus înainte ca respectivul colț
   al cufărului să crească sub el. Cealaltă rezolvare (să micșorez cufărul cât
   să încapă în stânga panoului) era și mai complicată, și mai proastă: în
   clipa aia lacătul e deschis, deci indiciile sunt informație moartă, iar
   cufărul întreg e singurul lucru care contează. Mesajul rămâne pe ecran —
   **centrat pe tot ecranul, cu fâșia întunecată strânsă pe text**: stă
   într-un `CenterContainer` lat cât fereastra, iar un container își strânge
   copilul la mărimea lui minimă, care pentru o etichetă fără autowrap e chiar
   lățimea vorbelor. (Înainte era un dreptunghi fix care se oprea la marginea
   panoului, deci fâșia rămânea lungă și goală, iar textul apărea centrat pe
   jumătatea stângă. Din același motiv, mesajul de după o încercare greșită s-a
   scurtat: centrat pe tot ecranul, propoziția lungă ajungea cu capătul sub
   panou.) Tot atunci **se șterge și selecția** — din clipa în care inputul e
   blocat, nicio literă nu mai e evidențiată, fiindcă „aici lucrezi acum" ar fi
   o minciună; aprinderea roților de la deschidere e altceva și rămâne;
3. cufărul tresare scurt (0,18 s);
4. **fulgerul urcă (0,16 s), iar ÎN VÂRFUL lui se schimbă textura** închis →
   deschis;
5. lumina se stinge (0,55 s), cufărul rămâne deschis, pauză, `rezolvat(true)`.

**De ce funcționează.** Ochiul nu vede „o imagine", vede DIFERENȚE. Când ecranul
e acoperit de o lumină care aproape îneacă desenul, nu mai are ce compara între
cadrul de dinainte și cel de după — iar când lumina scade, primește un cufăr
deschis și presupune că s-a deschis SUB lumină. Trucul nu e lumina, e clipa
aleasă: schimbarea se face fix în vârf, nu la urcare și nu la coborâre.

Merge doar fiindcă cele două poze sunt încadrate identic, la pixel. Dacă lacătul
ar sări cu cinci pixeli, l-ai prinde chiar și prin fulger: **mișcarea se vede
prin lumină, culoarea nu.**

Fulgerul e din două lumini, nu una. Prima e o A DOUA COPIE a imaginii, desenată
peste prima cu amestecare prin ADUNARE (`BLEND_MODE_ADD`): fiecare pixel al ei
se adaugă la ce e dedesubt, deci lumina aprinde exact silueta cufărului — lemn,
fier și alamă, fiecare de la culoarea lui în sus. O pată albă peste tot ar fi
arătat ca un cearșaf. A doua e haloul din jur, și el e cel care acoperă
CONTURUL: capacul deschis are altă siluetă decât cel închis, iar fără o lumină
care se revarsă dincolo de margini s-ar vedea cum sare marginea.

### Eșecul

După trei greșeli, roțile se rotesc singure până la codul corect, decalat, cu o
tură întreagă înainte de aterizare (altfel o roată deja pe cifra bună n-ar face
nimic și dezvăluirea ar arăta a defecțiune). Cufărul rămâne închis. Fără tremur,
fără sunet dur: e un eveniment, nu o pedeapsă. Pleci știind cifrul, nu doar că
ai greșit.

### Regulile s-au mutat după artă

| Nivel | Roți | Cifre | Indicii, cel mult | Ce dă gratis |
|---|---|---|---|---|
| 1 | 4 | 1–9 | 6 | **o roată sudată pe cifra corectă** |
| 2 | 4 | 1–9 | 6 | — |
| 3 | 4 | 1–9 | **3** | — |

Toate nivelurile au acum 4 roți cu cifre 1–9, fiindcă arta are patru ferestre:
un lacăt de 3 roți ar fi însemnat o fereastră goală. Diferența dintre niveluri
s-a mutat în altă parte: nivelul 1 îți dă o roată (rămân 3 cifre de dedus dintr-un
spațiu de 729 de coduri în loc de 6561), iar nivelul 3 are cel mult **3 indicii**
— mai puține indicii nu înseamnă mai puțin de gândit, ci invers: cu 3 rânduri
pentru 4 necunoscute nu există niciun indiciu de rezervă pe care să te sprijini
dacă unul ți-a scăpat.

**Roata blocată a adus o capcană pe care merită s-o știi.** Cu o roată sudată pe
5, indiciul „A e cu 2 mai mare decât roata aia" DICTEAZĂ cifra lui A — deși e
scris ca o relație. Verificarea „niciun indiciu nu dă direct o cifră" se face
deci pe mulțimea RESTRÂNSĂ de roata blocată... dar acolo roata blocată are, prin
definiție, o singură valoare posibilă, deci ar reclama absolut orice indiciu.
Poziția blocată se exclude explicit din verificare. Nu e o excepție
convenabilă — e chiar distincția dintre „ți se dictează o cifră" și „ți se ARATĂ
o cifră, iar tu deduci restul".

Din același motiv, toată socoteala (unicitate, alegere lacomă, curățare) se face
în universul restrâns: altfel generatorul ar adăuga indicii ca să excludă coduri
pe care jucătorul le-a exclus deja uitându-se la cufăr.

### O optimizare care nu slăbește nicio garanție

Alegerea lacomă își CÂNTĂREȘTE de azi candidații pe o **sondă** de 1500 de
coduri (luate din k în k din mulțimea încă posibilă), nu pe toată mulțimea.
Diferența dintre „taie 5900" și „taie 5880" nu schimbă nicio decizie, iar prima
rundă era partea cea mai scumpă din tot generatorul.

Nimic din ce garantează puzzle-ul nu trece pe acolo: tăierea, curățarea și
unicitatea se fac tot pe mulțimea întreagă. Sonda poate cel mult să facă
alegerea lacomă să ia al doilea cel mai bun candidat — adică exact greșeala pe
care metoda lacomă o face oricum, prin natura ei, și pe care o repară pasul de
curățare. Rezultat: o generare de nivel 3 a scăzut de la ~985 ms la ~480 ms,
cu aceleași puzzle-uri ca înainte ca formă și lungime.

### Verificarea: 500 de semințe × 3 niveluri

`godot --headless --path . res://tools/verificari/verifica_cifru.tscn`. Verificatorul știe
acum de roata blocată (cere unicitatea în universul restrâns) și raportează, pe
lângă ce raporta, **media indiciilor** și **timpul unei generări**.

**Rezultatul: verde peste tot, zero probleme pe toate cele 1500 de puzzle-uri.**

| | nivel 1 | nivel 2 | nivel 3 |
|---|---|---|---|
| **media indiciilor** | **2,84** | **3,75** | **3,00** |
| **o generare** | **46 ms** | **150 ms** | **469 ms** |
| indicii, cel mai des | 3 (419/500) | 4 (371/500) | 3 (488/500) |
| reîncercări, media | 1,00 | 1,00 | 3,27 |
| reîncercări, maximul | 1 | 2 | 12 (plafonul) |
| durata verificării | 50 s | 175 s | 486 s |

Nivelul 1 iese cu 2,84 indicii în loc de 3,75 — exact ce face roata sudată: îți
dă o cifră, deci nu mai trebuie indicii ca s-o deducă. Roata blocată cade
uniform pe cele patru poziții (117 / 125 / 135 / 123 din 500), deci lacătele de
nivel 1 nu au toate aceeași formă. Nivelul 3 are 3,00 fix,
adică plafonul lui, la 488 din 500 de semințe.

**Șapte semințe din 500 (1,4%) au ieșit pe ușa din dos** cu 4 indicii în loc de
3, după 12 încercări — cu avertisment în consolă. Verificatorul le-a controlat
ca pe toate celelalte: unice, fără indicii redundante, fără dictare. Asta e
fix schimbul pentru care am strâns `INCERCARI_MAXIME` de la 30 la 12: la 30,
cea mai nefericită sămânță din 500 cerea 25 de încercări, adică aproape trei
secunde de ecran înghețat pentru un singur indiciu în minus.

Distribuția tipurilor a rămas cea de dinainte (≈72% `DIFERENTA` + `SUMA_DOUA`):
alegerea lacomă ia mereu indiciul care taie cel mai mult, iar cele aritmetice
taie cel mai mult. Pentru un joc de antrenament mental e pe temă, nu pe lângă
ea; butonul de reglat, dacă se simte monoton, rămâne `CANDIDATI`.

### Sunete de căutat

Două rânduri noi în catalogul lui `Sunet`, fără fișiere: `_incarca_efectele()`
avertizează o dată la pornire și lasă efectul mut, iar Lacătul merge mai departe
fără el. Când fișierele apar în dosar, merg singure.

- **`assets/audio/dial_click.ogg`** — 50-120 ms, metalic și uscat, clicul unei
  roți care trece peste o cifră. Caută „combination lock dial click", „ratchet
  click", „cog tick". Volum propriu (`VOLUM_CLIC_DB = -19`), sub ticăit: e un
  sunet care se repetă de zeci de ori pe secundă când tragi de-o roată.
- **`assets/audio/chest_open.ogg`** — 1-2 s, balamale care scârțâie și capac
  care se oprește. Caută „wooden chest lid open creak", „treasure chest open".

### Fișiere

Nou: `scenes/cifru/banda_cifre.gd`. Rescrise: `cifru.gd`, `cifru.tscn`. Atinse:
`generator_cifru.gd` (tabelul, roata blocată, sonda), `tools/verificari/verifica_cifru.gd`,
`autoload/sunet.gd` (două rânduri în catalog). Șters: `roata_cifra.gd` —
plăcuțele desenate n-au ce căuta peste o poză reală; e în Git dacă va fi nevoie.
**Neatinse:** contractul, `autoload/expeditie.gd`, `scenes/harta/`.

### Ce urmează, și două lucruri de ținut minte

1. **Legarea de nodul de Eveniment** — sămânța cifrului derivată din a
   expediției plus id-ul nodului, nivelul din adâncime, recompensă la succes.
2. **Generarea de nivel 3 costă ~0,47 s** (cel mult ~1,5 s, fiindcă bugetul de
   12 încercări o mărginește). Azi se întâmplă în `porneste()`, adică într-o
   clipă în care ecranul e deja pe loc. Când Lacătul se leagă de hartă, momentul
   bun e în timpul tranziției de la hartă, nu după ea.
3. **Cele două PNG-uri au ~5 MB fiecare** și ocupă ~12 MB de memorie video
   fiecare. Pentru desktop e irelevant; pentru exportul web de la pasul 14 vor
   vrea o versiune la ~1000 px.

---

## LACĂTUL (24 septembrie 2026) — un cifru care se deduce, nu se ghicește

*Secțiunea asta descrie PRIMA versiune, cu roți desenate pe pergament. Sesiunea
„CUFĂRUL", de mai sus, a înlocuit scena întreagă și tabelul de dificultate
(acum: 4 roți cu cifre 1–9 la toate nivelurile). Algoritmul generatorului —
alegerea lacomă, curățarea, forța brută — a rămas cel de aici, plus roata
blocată și sonda.*

Primul conținut al nodului de **Eveniment**: un cufăr cu cifru, al cărui cod nu
e scris nicăieri. Îl afli din indicii („D e cu 3 mai mare decât C", „suma
tuturor cifrelor e exact 13"), potrivești roțile și deschizi. Trei încercări.

**Nu e legat încă de hartă.** Sesiunea asta a construit piesa și i-a dovedit
corectitudinea; legarea de nodul de Eveniment (și sămânța derivată din a
expediției) e sesiunea următoare. `autoload/expeditie.gd` și `scenes/harta/` **nu
au fost atinse**. Scena se rulează singură cu F6, ca orice disciplină.

### Trei fișiere, trei treburi

| Fișier | Ce face | Ce NU știe |
|---|---|---|
| `scenes/cifru/generator_cifru.gd` (`GeneratorCifru`) | logică pură, statică: naște puzzle-ul, evaluează un indiciu, îl scrie în românește | nimic despre noduri, scene, pixeli |
| `scenes/cifru/roata_cifra.gd` (`RoataCifra`) | o roată desenată din cod: literă, cifră, săgeți, vecine | nimic despre cifruri, indicii, încercări |
| `scenes/cifru/cifru.gd` + `.tscn` | ecranul: roțile, lista de indicii, cele trei încercări, verdictul | nimic despre cum se naște un puzzle |

Plus `tools/verificari/verifica_cifru.gd` + `.tscn`, headless, ca celelalte verificatoare.

### Cum se naște un cifru

Ideea, în cinci rânduri. „Deduci un cod din indicii" înseamnă, pentru
calculator: există o mulțime de coduri posibile, fiecare indiciu o TAIE, iar
puzzle-ul e bun când rămâne exact unul.

1. **Alege un cod la întâmplare** — ăsta e răspunsul.
2. **Fabrică afirmații adevărate despre el.** Nu „inventează și verifică": CITEȘTE
   codul și scrie ce vede în el. De-aia nu poate ieși niciodată un puzzle
   contradictoriu — afirmații adevărate despre același cod nu se pot contrazice.
3. **Alege lacom:** la fiecare pas, indiciul care lasă cele mai puține coduri în
   picioare, până rămâne unul singur.
4. **Curăță:** scoate pe rând fiecare indiciu; dacă soluția rămâne unică fără el,
   era redundant.
5. **Dacă a ieșit mai lung decât încape pe ecran,** ia-o de la capăt cu altă
   sub-sămânță (cel mult 30 de încercări).

**De ce „lacom" (greedy) e sigur aici.** Metoda e miopă prin definiție: ia
mușcătura cea mai mare disponibilă ACUM, fără să se uite înainte. Poate deci să
producă un puzzle mai LUNG decât ar fi fost nevoie (două indicii medii s-ar fi
completat mai bine decât unul tare urmat de unul care repetă aceeași
informație) — dar nu poate produce unul ambiguu sau fără soluție, fiindcă se
oprește doar când a rămas un singur cod, iar acel cod e obligatoriu al nostru:
toate indiciile sunt adevărate despre el, deci supraviețuiește oricărei tăieri.
Alegerea optimă („cele mai puține indicii posibile") e o rudă a problemei
acoperirii de mulțimi, pentru care nimeni nu știe o metodă rapidă și exactă;
n-avem nevoie de optim, avem nevoie de scurt, rapid și de încredere.

**Pasul 4 repară fix miopia pasului 3.** Un indiciu luat devreme tăia mult
ATUNCI; după alte două tăieri, se poate ca tot ce tăia el să fie deja tăiat de
ceilalți. E ca și cum ai da patru indicații de drum, iar a doua să fie „nu o lua
spre nord" — adevărată, dar inutilă, fiindcă a patra spunea deja „mergi spre
sud". Un rând inutil pe ecran nu e doar zgomot: jucătorul presupune (pe drept)
că fiecare indiciu e acolo ca să fie folosit, și pierde timp căutând ce aduce
nou unul care nu aduce nimic.

**De ce forța brută e metoda corectă aici.** Unicitatea se verifică încercând
TOATE codurile, unul câte unul. E metoda cea mai proastă din lume în general, și
cea mai bună aici:

- **mulțimea e minusculă** — cel mai mare lacăt are 4 roți × 10 cifre = 10 000
  de coduri (un lacăt de 6 roți ar avea un milion; de-aia tabelul de dificultate
  e o listă scurtă, nu o invitație la orice);
- **e o dovadă, nu un eșantion** — nu „n-am găsit altă soluție în o mie de
  încercări", ci „le-am încercat pe toate". Un al doilea cod valid ar însemna un
  jucător care deduce corect, tastează corect și pierde o încercare;
- **folosește exact regula jocului** — numărătoarea trece prin `evalueaza()`,
  aceeași funcție pe care o cheamă scena. Un verificator „mai deștept" ar fi a
  doua implementare a acelorași reguli, iar două implementări se despart mereu.

### Dificultatea, ca tabel

| Nivel | Roți | Cifre | Indicii, cel mult | Coduri posibile |
|---|---|---|---|---|
| 1 | 3 | 1–6 | 4 | 216 |
| 2 | 4 | 1–6 | 5 | 1 296 |
| 3 | 4 | 0–9 | 6 | 10 000 |

Maximul de indicii e o limită de **ecran și de răbdare**, nu una matematică:
generatorul reîncearcă până intră sub ea. Lista trebuie să încapă mereu întreagă
pe ecran, fiindcă un puzzle de deducție e o socoteală ținută în cap — orice
indiciu pe care trebuie să-l cauți din nou e un pas de socoteală pierdut.

### Șapte tipuri de indiciu, și o regulă

`RELATIE` (A > C, A = C) · `DIFERENTA` (A e cu 2 mai mare decât D) ·
`SUMA_DOUA` (A + B e exact 7 / mai mare decât 5) · `PARITATE` (B e pară) ·
`EXTREM` (nicio cifră nu e mai mare decât B) · `FARA_REPETITIE` ·
`SUMA_TOTALA`.

**Regula: niciun indiciu nu dă direct o cifră.** „A = 7" ar transforma deducția
în dictare. Regula nu e apărată doar prin lipsa unui tip potrivit, ci verificată
prin EFECT: dacă toate codurile care respectă un indiciu au aceeași cifră pe o
poziție, indiciul ăla dictează, oricum ar fi scris. „Suma tuturor cifrelor e
exact 3", pe un lacăt de 3 roți cu minimul 1, e o propoziție despre sumă care
spune, de fapt, „toate sunt 1". Candidații se nasc deja ocolind capcana (o
diferență de 5 pe un interval 1–6 nici nu se generează), iar verificarea finală
e plasa de siguranță.

**Un singur `evalueaza(indiciu, cod)`.** Aceeași funcție e folosită de alegerea
lacomă, de curățare, de verificarea unicității, de verificator ȘI de scenă, când
colorează în roșu indiciile încălcate. Dacă scena ar avea o verificare „mai
simplă, doar pentru feedback", ar exista două definiții ale aceleiași reguli —
identice exact până în ziua în care una e corectată și cealaltă nu. Atunci jocul
ți-ar spune că toate indiciile sunt respectate și ar refuza să deschidă lacătul.

Din același motiv, **„corect" înseamnă „codul respectă toate indiciile"**, nu
„codul e egal cu cel secret". Prin unicitate sunt același lucru — dar așa
deschiderea lacătului și rândurile roșii ies din aceeași socoteală, deci starea
absurdă „niciun indiciu roșu, dar nu se deschide" nu poate exista.

**Indiciile sunt date, nu propoziții.** Un indiciu e
`{"tip": "RELATIE", "a": 0, "b": 2, "semn": ">"}`; textul se compune la afișare.
Textul e înfățișare: dacă ar fi salvat, în ziua în care schimbi o formulare (sau
traduci jocul), save-urile vechi ar purta propozițiile vechi pe veci. Tot
puzzle-ul e numai tipuri simple — regula de save din `CLAUDE.md`.

### Scena: de ce NU moștenește `Puzzle`

`Puzzle` e o bază foarte concretă: o întrebare, patru variante, un cronometru,
un verdict în trei timpi, un marcaj de combo. Un `extends Puzzle` ar fi adus
`@onready var butoane := [%Varianta1, …]` — noduri care nu există în
`cifru.tscn`, deci scena ar fi crăpat la `_ready()`; ar fi cerut un
`_compune_intrebare()` cu patru variante (un lacăt cu patru variante nu mai e un
lacăt); și ar fi adus cronometrul, care acolo e obligatoriu.

Moștenirea e pentru lucruri care sunt același lucru în esență. Lacătul nu e a
patra întrebare cu variante — e altă formă de interacțiune. Le leagă doar
**contractul**: `porneste(nivel, samanta)` și semnalul `rezolvat(succes)`,
aceleași nume și aceeași formă ca la discipline. Cine cheamă scena nu învață
nimic nou, dar scena nu cară o mașinărie străină. Regula, pe scurt: moștenește
implementarea doar când chiar o refolosești; împrumută INTERFAȚA ori de câte ori
poți.

### Cum se joacă

- **Roțile** se mută cu săgețile sus/jos, cu rotița mouse-ului, cu clic pe
  săgețile desenate, sau tastând cifra direct (după care sare pe roata
  următoare). Stânga/dreapta schimbă roata. Trec de la un capăt la altul: de la
  9 la 0 e o apăsare, nu nouă.
- **Literele roților** (A, B, C, D) vin din `GeneratorCifru.litera()`, aceeași
  funcție care scrie literele din indicii. Două locuri care numără pozițiile ar
  fi însemnat, într-o zi, indicii care vorbesc despre altă roată.
- **Trei încercări**, cu cercuri pline/goale. La o greșeală, indiciile pe care
  codul tău le încalcă se fac **roșii** — o încercare greșită e o măsurătoare,
  nu o taxă. Roșul se stinge abia când clintești o roată (adică fix când a
  încetat să fie adevărat), nu imediat.
- **După trei greșeli**, codul corect apare **pe roți**, cu verde de cerneală. Un
  puzzle de deducție pierdut fără să afli răspunsul nu te învață nimic — și, mai
  rău, te lasă cu bănuiala că poate n-avea soluție.
- **Fără cronometru.** `SECUNDE = 0` în `cifru.gd`; e un reglaj, nu o absență
  („Lacăt cronometrat" e un modificator evident pentru mai târziu). Presiunea de
  timp e unealta luptei; evenimentele sunt respirația dintre lupte.
- Sunetele sunt cele existente (`Sunet.Efect.CORECT` / `GRESIT`), niciunul nou.
- Aspectul: **cerneală pe pergament**, ca harta, fiindcă acolo va apărea. Tot
  desenat din cod, nicio imagine nouă.

### Verificatorul: 500 de semințe × 3 niveluri

`godot --headless --path . res://tools/verificari/verifica_cifru.tscn` — **durează ~8
minute** (nivelul 3 are 10 000 de coduri de parcurs la fiecare întrebare pusă) și
verifică, pentru fiecare din cele 1500 de puzzle-uri: soluția e unică; codul
respectă toate indiciile; niciun indiciu redundant; niciun indiciu care fixează
singur o cifră; fiecare indiciu are o propoziție; aceeași sămânță dă același
puzzle (comparat prin JSON, deci verifică și că puzzle-ul încape în JSON fără
traducător).

**Rezultatul: verde peste tot, 0 probleme.**

| | nivel 1 | nivel 2 | nivel 3 |
|---|---|---|---|
| indicii, cel mai des | 3 (336/500) | 4 (255/500) | 4 (375/500) |
| la maximul permis | 2 puzzle-uri | 3 | 2 |
| reîncercări, media | 1,00 | 1,00 | 1,00 |
| reîncercări, maximul | 1 | 2 | 2 |
| durata | 8 s | 52 s | 422 s |

Media de o singură încercare spune că tabelul de dificultate e larg, nu strâmt:
limita de 30 de reîncercări nu e nici pe departe atinsă. Dacă vreodată se
atinge des, semnul nu e că trebuie mărită, ci că `indicii_maxime` e prea strâns
pentru nivelul ăla.

**Ce arată distribuția tipurilor, și ce am ales să nu schimb.** ~75% din indicii
sunt `DIFERENTA` + `SUMA_DOUA`, iar `FARA_REPETITIE` apare de 6 ori în 500 de
puzzle-uri. Nu e un bug: alegerea lacomă ia mereu indiciul care taie cel mai
mult, iar cele aritmetice taie cel mai mult. Cifrurile ies deci mai degrabă
socoteli decât ordonări — ceea ce, pentru un joc de antrenament mental, e pe
temă, nu pe lângă ea. Butonul de reglat, dacă vreodată se simte monoton, e
`CANDIDATI` (câți candidați intră în concurs la o încercare) sau compoziția
grămezii din `_candidati()` — nu algoritmul.

Eșantionul ăla are, de altfel, un rost dublu: fără el, „suma tuturor cifrelor e
exact N" (indiciul care taie cel mai brutal) ar fi fost primul indiciu în
aproape fiecare puzzle din joc, fiindcă alegerea lacomă e deterministă.

### Ce urmează, concret

1. **Legarea de nodul de Eveniment** — `autoload/expeditie.gd` și
   `scenes/harta/`: sămânța cifrului derivată din sămânța expediției plus id-ul
   nodului (ca la tipurile de nod), nivelul din adâncimea nodului, recompensă la
   succes, nimic (sau puțin) la eșec.
2. **Jucat pe mână.** Nivelul 3 pare, pe hârtie, cel mai lung de dedus; cât
   durează CHIAR o deducție de 4 indicii nu se află din statistici.
3. Eventual **un al doilea eveniment**, ca nodul să nu însemne mereu „iar
   lacătul".

---

## POZIȚIA PERSONAJELOR, DOUĂ STĂRI (24 septembrie 2026) — o cifră aleasă și o regulă

Până acum poziția pe orizontală era o singură cifră, folosită în amândouă
stările. De azi sunt două lucruri de feluri diferite, și distincția e tot
conținutul sesiunii: **poziția de bază e o alegere de compoziție**, iar
**poziția lângă panou e o consecință măsurată**.

Amândouă stau în `scenes/lupta/asezare_coloana.gd`, pus pe `ZonaJucator` și
`ZonaInamic`.

### 1. Poziția de bază: înapoi spre exterior

`deplasare_de_baza` **0.20 → 0.11** din lățimea coloanei (99 → 54 px la
1152×648, adică **45 px spre exterior** pentru fiecare, simetric).

| | înainte | acum |
|---|---|---|
| Rege, figura desenată | 0.278–0.451 | **0.240–0.412** |
| Soldat, figura desenată | 0.550–0.721 | **0.588–0.760** |
| marginea mantiei | 0.301 | **0.262** |
| aer față de pupitru | 47 px | **2 px** |

**Cei 2 px trebuie citiți cu grijă, și de-aia și-au schimbat pragurile.** Cifra
se măsoară de la cel mai din stânga punct al mantiei, **pe toată înălțimea
figurii** — un punct care apare o singură dată, la poalele hainei. Pe captură,
pupitrul se vede ÎNTREG: cartea, sfeșnicele de pe el, corpul de dedesubt. Nu e
acoperit nimic. Dar marja e subțire, deci merita spus pe față, nu ascuns într-un
„OK".

Verificarea are de azi **două praguri, nu unul**: sub zero = PICAT (chiar se
suprapun), iar între zero și 30 px trece cu mențiunea „ok, dar la limită".
Motivul e că amestecasem două lucruri într-un singur număr: „Regele nu are voie
să acopere pupitrul" e o limită tare, pe când „cât aer arată bine" e o
preferință, care s-a răzgândit deja o dată. Cu un singur prag, orice reglare de
compoziție ar fi arătat ca o regulă încălcată.

**Dacă marja de 2 px se dovedește prea strânsă:** `deplasare_de_baza` 0.11 →
0.13 dă înapoi 10 px de aer și costă 10 px de spațiu în centru.

### 2. Poziția lângă panou: o limită, nu o a doua cifră

Panoul de întrebare acoperea bastonul Regelui și spada Soldatului. Regula
cerută: marginea **vizibilă** a personajului stă la marginea panoului + 12 px.

Trei lucruri de apărat în implementare:

**Marginea vizibilă, nu marginea nodului.** Se citește din `Image.get_used_rect()`
pe textură — chenarul opac, nu dreptunghiul `TextureRect`-ului, între care sunt
zeci de pixeli de aer transparent. Se calculează **o dată per textură** și se
ține minte într-un dicționar static: `get_image()` decomprimă imaginea întreagă,
iar funcția se cheamă la fiecare cadru al animației de deschidere.

**E o LIMITĂ, nu o poziție-țintă.** „Stai unde ai fost ales, dar niciodată mai
aproape de panou decât 12 px." Trei câștiguri față de o a doua poziție calculată:
- **e continuă** — panoul se deschide cu o animație, de la lățime zero; o
  poziție-țintă ar fi cerut, în prima clipă, o deplasare uriașă, deci figura ar
  fi sărit spre centru și s-ar fi întors pe măsură ce panoul crește. Limita
  mușcă treptat, deci figura alunecă o dată, lin, în afară.
- **nu trebuie să știe cât de lat ajunge panoul** — se uită la cât e acum, deci
  nu duplică `LATIME_PANOU` din `lupta.gd`.
- **nu face nimic dacă poziția de bază e deja destul de în afară.**

**Cei 12 px sunt în pixeli, nu în fracțiuni, și intenționat.** E o distanță de
atingere între două lucruri desenate, nu o proporție de compoziție. Proiectul
desenează într-un ecran logic fix (1152×648) pe care îl scalează la fereastră,
deci pixelul se mărește odată cu tot restul — la 1920×1080 iese exact aceeași
cifră.

**Măsurat, pe toți trei inamicii:**

| | margine vizibilă | aer până la panou |
|---|---|---|
| REGE | 314.0 px | **12.0 px** |
| INAMIC | 838.8 px | **12.8 px** |

Identic pentru Soldat, Lăncier și Spadasin — fiindcă **azi cei trei împart
aceeași textură**: `INAMICI` are `colorare`, nu imagine. Verificarea trece
oricum prin toți trei, și asta nu e timp pierdut: arată că regula nu depinde de
cine e în arenă, și va prinde diferența în ziua în care Lăncierul își primește
propriul desen, cu lancea lui.

**Proba regulii.** Cu valorile de azi, poziția de bază nimerește singură la fix
12 px de panou — deci măsurătoarea de mai sus ar fi trecut la fel de bine și
dacă limita n-ar fi existat deloc. Verificarea împinge acum poziția de bază la
0.30 și se uită dacă aerul rămâne 12. Rămâne. Fără proba asta, ziua în care
cineva schimbă poziția de bază ar fi fost ziua în care aflu, din joc, că regula
era decor.

### 3. Bara de PV: nu se atinge, deci panoul rămâne lat

Întrebarea pusă înainte de a schimba altceva: împinge regula vreun personaj
peste bara lui de PV? **Nu, și nici nu poate, în situația de azi.** Regula
împinge Regele spre DREAPTA și Soldatul spre STÂNGA — adică pe amândoi
*dinspre* barele lor, nu spre ele. Barele stau la 0.028–0.050 și 0.950–0.972;
figurile nu se apropie de ele în niciuna din stări.

Deci **nu e nevoie de îngustarea panoului cu 30–40 px.** Alternativa rămâne
valabilă dacă vreodată un inamic primește o armă atât de lată încât limita să-l
împingă în bară — verificarea măsoară și asta și se plânge înainte să se vadă
în joc.

### Valorile de acum

| Ce | Unde | Acum |
|---|---|---|
| poziția de bază | `ZonaJucator` / `ZonaInamic`, `deplasare_de_baza` | **0.11** din lățimea coloanei |
| aerul lângă panou | aceleași, `aer_langa_panou` | **12.0** px logici |
| partea pe care e panoul | `panoul_la_dreapta` | `true` la Rege, `false` la inamic |

Restul (talpă, umbre, lumini, linia numelor) neschimbat față de secțiunile de
mai jos.

### Ce s-a mai învățat

**Panoul deschis duce Regele peste pupitru** (mantia la 0.125, adică 156 px
peste) și nu se poate repara din poziția figurii: coloanele se string ca să facă
loc întrebării. Nu e o regresie și nu e o promisiune încălcată — verificarea o
scrie ca pe o cifră informativă, cu alt cuvânt decât o cădere. Reparația, dacă
va fi vreodată nevoie, e la panou (să se suprapună în loc să împingă).

**Capturile sunt acum patru**, nu două: fiecare rezoluție, cu panoul închis și
cu el deschis. Cea cu panoul deschis arată un panou GOL — se deschide doar
geometria lui, nu o întrebare adevărată — și e exact ce trebuie văzut acolo:
marginile lui față de baston și de spadă, fără conținut care să distragă.

---

## ARENA, TREI AJUSTĂRI FINE (24 septembrie 2026) — pupitrul, linia numelor, umbrele

Trei retușuri peste sesiunea de mai jos. Valorile de aici **le înlocuiesc** pe
cele din tabelul secțiunii următoare acolo unde se contrazic.

### 1. Regele nu mai stă lipit de pupitru

Mantia lui acoperea colțul din dreapta al pupitrului cu cartea deschisă. Măsurat:
marginea dreaptă a pupitrului e la **0.2604** din lățimea ecranului, iar mantia
începea la **0.196** — adică se suprapuneau pe 74 px.

Amândouă figurile se trag spre centru cu **0.2 din lățimea coloanei lor**
(99 px la 1152×648), simetric. Rezultatul: mantia la **0.301**, adică **47 px de
aer** față de pupitru; figurile stau la 0.1355 de o parte și de alta a centrului
ecranului, deci exact simetrice față de fereastră.

**De ce 47 px și nu 60-80.** Mai mult decât atât împinge bastonul Regelui peste
ancadramentul ferestrei din fund și strânge coridorul dintre cele două figuri —
adică repară o vecinătate stricând alta. 47 px se citesc clar ca spațiu, fără să
mute problema în altă parte.

**De ce „marginea mantiei" nu e marginea desenului.** Canalul alfa al texturii
începe la 9/379 = 0.024, dar acolo e VÂRFUL SPADEI — o lamă subțire, prezentă pe
o singură bandă de înălțime. Masa pe care o vede ochiul (pânza) începe la
**50/379 = 0.132**. Socotit pe marginea desenului, Regele ar fi fost tras cu încă
30 px spre centru ca să facă loc unei lame de trei pixeli.

**S-a mutat COLOANA, nu figura.** Prima încercare a mutat doar figura, prin
ancorele ei — și a rupt altceva: eticheta cu numele a rămas centrată pe coloana
nemișcată, deci nu mai stătea deasupra personajului. Acum `ZonaJucator` și
`ZonaInamic` sunt `Control`-uri simple, iar înăuntrul lor stă câte un
`ColoanaJucator` / `ColoanaInamic` (`VBoxContainer`) ancorat cu deplasarea. Se
mută tot: nume, PV, intenție, figură, umbră.

**Ce NU se poate repara așa, și de ce.** Când se deschide panoul de întrebare
(500 px), cele două coloane se string la jumătate și figurile se dau spre
margini: mantia Regelui ajunge la **0.144**, adică 134 px PESTE pupitru. Nu e o
regresie — așa era și înainte — și nici nu se poate rezolva ancorând figura de
ecran, fiindcă atunci panoul ar trece peste ea. E o compoziție care se strică
într-o stare în care oricum te uiți la întrebare, nu la cameră. Unealta o
măsoară și o raportează, dar NU o consideră o cădere; dacă vreodată deranjează,
reparația e la panou (să se suprapună în loc să împingă), nu la figuri.

### 2. Numele pe aceeași linie

„REGELE" era cu 35 px sub „SOLDATUL", fiindcă blocul inamicului are patru
rânduri (nume, vulnerabilitate, ceas, intenție) și amândouă blocurile se lipeau
de JOS. Acum se lipesc de SUS: primul rând al fiecăruia pornește de la aceeași
înălțime, indiferent câte rânduri are inamicul dedesubt. Intenția rămâne sub
numele lui.

**Capcana:** numele Regelui e un `Label`, al inamicului un `Button` (pe el se
apasă pentru card). Butonul e mai înalt cu 8 px din marginile temei, deci
„aceeași poziție în cutie" NU însemna „același rând pe ecran". Înălțimea se
egalează explicit (28 px) și textul se centrează în ea. Abaterea măsurată acum:
**0.0 px**.

**A doua capcană, plătită pe loc:** am încercat să string butonul pe lățimea
textului (`SHRINK_CENTER`), ca să nu mai prindă click pe jumătate de ecran.
Butonul s-a strâns la 8 px — fiindcă are `clip_text`, iar `clip_text` înseamnă
tocmai „ai voie să fii mai mic decât textul tău", deci mărimea lui minimă e
zero. Am lăsat butonul pe toată lățimea coloanei.

### 3. Umbrele, mai apăsate

`opacitate` **0.50 → 0.68** la Rege, **0.50 → 0.58** la Soldat. Regele are mai
mult fiindcă stă pe dalele luminate din stânga, unde o umbră slabă se pierde;
Soldatul stă pe o zonă deja întunecată, cu moloz, și n-are nevoie de la fel de
mult. Restul (lățime, turtire, culoare) neschimbat — s-a mărit doar cât de
întunecat e miezul, nu forma.

### Valorile de acum

| Ce | Unde | Acum |
|---|---|---|
| deplasarea spre centru | `ColoanaJucator` / `ColoanaInamic`, ancorele | ±0.2 din lățimea coloanei (99 px la 1152×648) |
| înălțimea rândului cu nume | `JucatorPV` / `InamicNume`, `custom_minimum_size.y` | 28 |
| opacitate umbră Rege | `UmbraJucator.opacitate` | **0.68** |
| opacitate umbră Soldat | `UmbraInamic.opacitate` | **0.58** |

Restul rămâne ca în tabelul de mai jos (talpă, lățime, turtire, culoare, lumini).

### Ce mai verifică unealta de acum

Trei probe noi în `tools/verificari/verifica_podeaua.gd`: aerul dintre pupitru și mantie
(în amândouă stările panoului), numele pe aceeași linie (toleranță 2 px, cu
intenția obligatoriu sub numele inamicului) și marginile orizontale ale figurii
desenate. Plus o curățenie: scena se eliberează înainte de ieșire, altfel Godot
raporta la închidere „2 resources still in use" — un ERROR fals într-o unealtă a
cărei singură treabă e să spună dacă e ceva în neregulă.

---

## PERSONAJELE STAU PE PODEA (24 septembrie 2026) — așezare, umbră, lumină

**Plângerea:** după ce a intrat fundalul (biblioteca gotică), Regele și Soldatul
păreau că plutesc. Măsurat, nu bănuit: linia unde peretele din fund întâlnește
podeaua e la **0.660** din înălțimea ecranului, iar tălpile erau la **0.612** —
adică deasupra ei. Personajele stăteau, literal, în perete, dar cu mărime de
prim-plan. De aici impresia de decupaj lipit peste o fotografie.

### Cele două variante, și de ce a câștigat una singură

**(a) Mărirea fundalului, ancorat jos-centru.** Ideea e corectă: scalând imaginea
în jurul marginii de jos, linia podelei urcă și rămâne mai multă podea în față.
Am renunțat la ea din cauza unei coincidențe de proporții. Fundalul e 2752×1536
(raport **1.792**), ecranul e 16:9 (**1.778**) — practic același. Nu există
surplus de imagine pe laturi din care să tai: orice mărire cu factorul `z` urcă
linia podelei cu `0.34·(z−1)` din înălțime, dar taie `0.5·(z−1)` din LĂȚIME, în
fiecare parte. Ca să aduc linia de la 0.660 la 0.580 mi-ar fi trebuit `z ≈ 1.24`,
adică **12% tăiat din fiecare margine** — pleacă sfeșnicul cu lumânări și pupitrul
din stânga, adică exact singura sursă de lumină caldă din sală. Plătit scump,
pentru un câștig pe care varianta (b) îl dă gratis.

**(b) Coborârea personajelor — aleasă.** Nu prin împingere cu pixeli, ci prin
schimbarea ORDINII din coloană. Numele și PV-ul (iar la inamic: numele,
vulnerabilitatea, ceasul și intenția „sabie + 3") stăteau SUB figură și-i tăiau
ultimii 92 px de spațiu. Le-am mutat DEASUPRA, lipite de capul figurii
(`alignment = END`), iar figura a primit tot ce rămâne, până jos.

Mutarea asta e mai bună decât o simplă coborâre din două motive care n-au de-a
face cu podeaua: intenția inamicului se citește acum **deasupra capului lui**,
unde o caută ochiul (aceeași convenție ca în Slay the Spire), iar textul a plecat
de pe dalele luminate pe bolta întunecată — adică pe fundalul pe care e citibil.

**Rezultatul, măsurat:** tălpile la **0.754** (Rege) și **0.746** (Soldat), adică
**55% și 51%** din banda de podea dintre linia peretelui (0.660) și marginea de
sus a butoanelor (0.830). Cerința era o treime; pragul e 0.717.

**Mărimea personajelor n-a fost atinsă.** Cutia figurii a rămas practic la fel
(342 → 344 px la 1152×648), fiindcă exact atâta spațiu s-a mutat de sub figură
deasupra ei. Coborârea a fost o MUTARE, nu o micșorare — și așa trebuie să
rămână: mărimea de prim-plan nu mai e o problemă odată ce personajul stă chiar
în prim-plan.

### Umbra de contact — `scenes/lupta/umbra_contact.gd`

Nod nou, cu o singură treabă: pata turtită de sub tălpi. Ochiul nu judecă „la ce
înălțime e personajul", ci caută unde atinge pământul.

**N-am inventat o a treia tehnică de umbră.** În proiect existau două:
`StyleBoxFlat.shadow_size` (halo-ul Obeliscurilor) și **cercuri concentrice cu
opacitate mică** (halo-ul nodurilor de pe hartă). A doua a câștigat: prima
desenează un dreptunghi și își umflă umbra egal în toate direcțiile, deci ar fi
reumflat pe verticală exact ce turtisem. Cercurile se turtesc din transformarea
de desen (`draw_set_transform` cu scară `(1, 0.25)`) — un cerc strivit e o
elipsă exactă, deci e **literal** tehnica de pe hartă, privită dintr-un plan
înclinat. Exact ce e și o umbră pe podea.

Două decizii pe care merită să le apăr dacă se atinge cineva de ele:

- **Umbra e FRATE al învelișului `impact.gd`, nu copil.** Învelișul face copiilor
  lui două lucruri la fiecare lovitură: îi clatină pe orizontală și le înmulțește
  `modulate` cu un alb aprins. O umbră dinăuntru ar aluneca pe podea la fiecare
  lovitură și s-ar ALBI la fulger. Verificarea din unealtă apără fix asta.
- **Umbra își calculează singură poziția**, din caseta în care cade efectiv
  textura („păstrează proporția, centrat" lasă aer în cutie) și din fracțiunea
  `talpa`, măsurată pe canalul alfa al PNG-ului: **0.985** la Rege, **0.970** la
  Soldat. Restul e aer transparent — o umbră pusă la marginea de jos a nodului ar
  fi căzut în fața personajului, ca o baltă din care el iese.

Opacitatea pe strat NU e o constantă: se deduce din opacitatea cerută, cu
`1 − (1 − opacitate)^(1/straturi)`. Fără formula asta, schimbarea numărului de
straturi (o cifră de NETEZIME) ar fi schimbat și cât de întunecată e umbra (o
cifră de CULOARE).

### Lumina — discret, prin `self_modulate`

Regele spre cald (`1.06, 1.00, 0.90` — stă lângă sfeșnic), Soldatul spre rece
(`0.93, 0.98, 1.10` — stă în lumina rece a ferestrei). Variații de ±10%, cât să
se simtă că sunt în aceeași încăpere, nu atât cât să se întunece.

**De ce `self_modulate` și nu `modulate`:** `modulate` al imaginii de inamic e
deja ocupat — `aplica_infatisarea()` îl scrie din `colorare`, culoarea
arhetipului. `self_modulate` se înmulțește peste el și nu-l calcă. Rezultatul e
un lanț de trei înmulțiri care se compun corect: fulgerul de la lovitură
(învelișul) × identitatea inamicului (`modulate`) × lumina sălii
(`self_modulate`).

### Unealta: `tools/verificari/verifica_podeaua.gd`

`godot --path . res://tools/verificari/verifica_podeaua.tscn` — **cu fereastră**, fiindcă
face și capturi. Măsoară tălpile față de linia peretelui, verifică să nu se calce
informația de luptă cu punctele de PA sau cu butoanele, urmărește sfeșnicul din
stânga, probează că umbra nu se clatină la lovitură, și scrie câte o captură în
`user://capturi/` pentru fiecare rezoluție.

Două lucruri învățate scriind-o, care merită ținute minte:

- **Proiectul e pe `canvas_items` + `expand`.** Interfața se așază MEREU într-un
  ecran logic de 1152×648 și abia apoi se scalează. La 1920×1080 nu se
  recalculează nimic — se mărește totul cu 1.667. Deci „merge și la altă
  rezoluție" e garantat de modul de întindere, nu de ancorele mele; ancorele în
  fracțiuni contează pentru ziua în care se schimbă RAPORTUL, nu mărimea.
- **Un nod ascuns nu e așezat de container** și raportează dreptunghiul cu care a
  plecat din editor. „Incheie tura" e ascuns la pornire (tura se încheie singură),
  iar prima versiune a uneltei a raportat o suprapunere care nu există.

### Valorile de reglat de mână

| Ce | Unde | Acum |
|---|---|---|
| zoom fundal | `Peisaj`, ancorele | **1.0** (fără mărire; motivul e mai sus) |
| voalul peste fundal | `Voal`, canalul A | 0.55 |
| talpa Rege / Soldat | `UmbraJucator` / `UmbraInamic`, `talpa` | 0.985 / 0.970 |
| lățimea umbrei | `latime` | 0.68 (Rege, cu mantia pe jos) / 0.50 (Soldat) |
| turtirea | `turtire` | 0.25 (adică 1:4) |
| opacitatea umbrei | `opacitate` | 0.50 |
| culoarea umbrei | `culoare` | `(0.04, 0.04, 0.07)` — albastru foarte închis, nu negru |
| lumina Regelui | `JucatorImagine.self_modulate` | `(1.06, 1.00, 0.90)` |
| lumina Soldatului | `InamicImagine.self_modulate` | `(0.93, 0.98, 1.10)` |

Umbra se citește discret la prima privire — podeaua e deja întunecată de voal.
Dacă vreau contact mai apăsat, butonul e `opacitate`; peste 0.5 începe să arate
a gaură în piatră, nu a umbră.

### Rămas deschis

Flacăra din marginea stângă a sfeșnicului intră pe **4.6%** din lățimea ei în
spatele barei verzi de PV. E adevărat și înainte de sesiunea asta, deci nu e o
regresie — dar unealta o numără de acum, fiindcă dacă bara se lățește vreodată,
sfeșnicul dispare și colorarea caldă a Regelui rămâne fără sursă vizibilă.

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

- **`tools/verificari/verifica_tipuri.gd`** (nou) — 500 de semințe × toate sursele. Media
  și maximul încercărilor, de câte ori a picat fiecare regulă, semințele care au
  atins limita, și proba că aceeași sămânță dă aceeași hartă. Avertizează singur
  când o regulă pică în peste jumătate din încercări: aia nu mai e o regulă
  strictă, e una care se ceartă cu altceva.
- **`tools/verificari/verifica_plansa.gd`** — verificare nouă (9): orice nod în afară de
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

Fișiere atinse: `autoload/expeditie.gd`, `tools/verificari/verifica_plansa.gd`,
`tools/verificari/verifica_tipuri.gd` (nou), `tools/verificari/verifica_tipuri.tscn` (nou).

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

### Verificarea: `tools/verificari/verifica_drumuri.gd`

```
godot --headless --path . res://tools/verificari/verifica_drumuri.tscn
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

`tools/verificari/verifica_coltul.gd` — rulează fără fereastră:

```
godot --headless --path . res://tools/verificari/verifica_coltul.tscn
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

`tools/verificari/verifica_harta.gd` a rulat pe 300 de semințe, pe toate patru traseele
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

### Verificatorul: `tools/verificari/verifica_plansa.gd`

```
godot --headless --path . res://tools/verificari/verifica_plansa.tscn
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

`tools/verificari/verifica_harta.gd` măsoară acum patru trasee în aceeași rulare. Pe 300 de
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
| `tools/verificari/verifica_harta.gd` | măsoară AMÂNDOUĂ traseele, pe 300 de semințe |

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

`tools/verificari/verifica_harta.gd` — o SCENĂ headless, rulată cu
`godot --headless --path . res://tools/verificari/verifica_harta.tscn` — trece generatorul
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
tools/verificari/verifica_harta.gd      - NOU: verificarea headless
tools/verificari/verifica_harta.tscn    - NOU: scena care o porneste
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

*Rescrisă pe 27 septembrie 2026. Punctul 1 bifat în aceeași zi (sesiunea
EVENIMENTUL DESCHIDE CUFĂRUL), punctul 3 pe 28 septembrie (sesiunea ID ȘI FAPT).
Punctul 0 adăugat pe 30 septembrie (sesiunea STEAGURILE).*

0. **F6 pe `tools/verificari/verifica_steaguri.tscn`.** Cele 126 de steaguri sunt pe disc și
   trec toate verificările automate — dar niciunul n-a fost văzut cu ochiul, iar
   21 dintre ele au fost alese de cod, prin rangul preferat din Wikidata. Un
   steag vechi sau al altei țări e un fișier perfect valid, deci nicio validare
   nu-l poate prinde. **Primele două de confirmat:** Afganistan
   (`Flag of the Taliban.svg`) și Costa Rica (steagul civil, nu cel de stat cu
   stemă). Dacă unul e greșit: `"steag_de_mana"` pe rândul din `tari.json`, apoi
   `--descarca` și `--scrie`. Zece minute.
1. **Lacătul de pe hartă, jucat pe mână.** Legarea e făcută și verificată
   headless; ce NU se poate afla din verificare e cât durează, cu ceasul pornit,
   un lacăt de nivel 3 — și dacă nodul se simte ca o respirație între lupte sau
   ca o temă pentru acasă. Lista de testat e în sesiunea de azi. Dacă nivelul 3 e
   prea lung, butonul nu e `LACAT` (recompensa), ci tabelul de dificultate din
   `generator_cifru.gd`.
2. **Verificarea notelor din pilot** (`docs/ghid-note.md`, secțiunea 5). Fără cod,
   cam o jumătate de oră.
3. ~~**`id` și `fapt` pentru Cultura generală.**~~ **FĂCUT** pe 28 septembrie
   (sesiunea ID ȘI FAPT): `tools/da_iduri.py` (idempotent, strict, +153 de linii
   și 0 ștergeri), `data/fapte_trivia.json` cu cele 15 fapte din pilot, cinci
   validări în încărcător, sacul pe `id`, nota în `explicatie`, verificare
   headless cu `tools/verificari/verifica_trivia.tscn`. **Nicio migrare n-a fost nevoie** —
   confirmat prin `grep`: nimic nu scrie pe disc. A rămas nescrisă a 19-a
   întrebare din pilot („În ce perioadă a domnit Ștefan cel Mare?”), și **regula
   nouă: un `id` nu se refolosește niciodată**, deci întrebările nu se șterg din
   fișier, se marchează `"retras": true`.
4. ~~**Un tabel de probă din Wikidata.**~~ **FĂCUT** pe 28 septembrie (sesiunea
   FABRICA): `tools/fabrica/elemente.py`, 139 de întrebări din 70 de elemente,
   alegerea din luptă în două trepte, sacul pe cheie de domeniu, două verificări
   noi probate rupând codul. **Ce a rămas de aici:**
   - **jucat pe mână**, ca să văd dacă „1 din 7 întrebări de luptă e element ↔
     simbol” se simte mult, și dacă cvartetul `C / Ca / Cl / Cu` de la nivelul I
     pare exercițiu sau conținut subțire. Pârghia e `FOLOSESTE_WIKIDATA`.
   - **decizia despre notele `wd:`**, ÎNAINTE de prima notă scrisă: fișierul
     generat se rescrie întreg, deci notele nu pot sta în el. Cele două variante
     sunt în sesiunea FABRICA, la „Regula care trebuie scrisă acum”.
5. ~~**Apoi înapoi pe rută: Cetatea (7), Save (8).**~~ **Save FĂCUT** pe 12
   octombrie (sesiunea SAVE): `autoload/arhiva.gd`, două fișiere în `user://`,
   scriere prin fișier temporar și redenumire, `versiune` în save, fișier ilizibil
   pus deoparte și anunțat în meniu, 54 de verdicte în `verifica_salvarea`. Sacul
   Culturii generale a trecut în permanent **numai pentru rafturile din Practice**
   (`Sac.Durata`), nu și pentru cele de luptă — motivul și pârghia sunt în
   sesiune. Regula Lacătului e respectată: prima scriere se face la
   `intra_in_nod()`, înainte de `match`. **Rămâne Cetatea (pasul 7).**
6. **SAVE-UL, JUCAT PE MÂNĂ.** Nimic din pasul 8 n-a fost încă văzut pe ecran —
   tot ce s-a verificat e în date. Lista, în ordinea în care se poate face dintr-o
   singură sesiune de joc:
   - pornește o expediție, mergi două noduri, **închide jocul din fereastră** (nu
     din editor). La repornire, meniul trebuie să scrie „Continua expeditia", cu
     nodurile și PV-ul corecte, iar harta trebuie să se deschidă exact de unde ai
     rămas;
   - **închide jocul în mijlocul unei lupte.** Lupta trebuie să repornească de la
     zero, cu același inamic. (Dacă sare lupta, `nod_nerezolvat` nu ajunge pe
     disc — dar verificarea ar fi prins asta.)
   - **închide jocul pe ecranul de verdict al unei lupte câștigate.** Fragmentele
     trebuie să fie deja în tezaur, iar lupta să NU se repete;
   - **ratează un cufăr și închide jocul pe ecranul de eșec.** La repornire
     trebuie să primești mesajul „ai lăsat locul ăsta în urmă", nu același lacăt;
   - **închide jocul pe mesajul de Odihnă** și verifică DOUĂ lucruri: că PV-ul
     recuperat a rămas, și că nu te-a vindecat a doua oară la repornire (vezi
     regula nodurilor cu efect instantaneu, în sesiunea SAVE — e singura
     scurgere pe care verificarea headless nu o poate prinde, fiindcă trăiește
     în `harta.gd`, nu în date);
   - Practice: răspunde corect la câteva întrebări, închide, repornește — cifra de
     progres trebuie să fie acolo;
   - și, la final, uită-te cu ochiul în `%APPDATA%\Godot\app_userdata\mindkeep\`:
     cele două fișiere trebuie să fie citibile, iar `scris_la` să aibă data bună.

### Datorie tehnică deschisă

Cea de aici („`trivia.gd` și `logica.gd` au ~180 de linii identice” și
„`DATE_ARHETIP` amestecă două lucruri”) e **rezolvată**: duplicarea a dispărut în
sesiunea bazei comune (15 septembrie, `puzzle.gd`), iar identitatea inamicului
s-a despărțit de arhetip în sesiunea celor trei inamici (16 septembrie,
`INAMICI` + `NUME_ARHETIP`). Datoria tehnică încă deschisă e notată în sesiunile
mai noi, la locul ei.

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

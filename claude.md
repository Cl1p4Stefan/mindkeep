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
| `verifica_trivia` | întrebările, faptele, echilibrul pe domenii, sacul, pragul | 29 | ~20 s |
| `verifica_harta` | generatorul de hărți, pe sute de semințe | 28 | ~40 s |
| `verifica_plansa` | fiecare hartă desenată din `data/harti/` | 26 | ~30 s |
| `verifica_eveniment` | lacătul pe care-l dă harta, nu cel din F6 | 22 | ~30 s |
| `verifica_tipuri` | rețeta tipurilor de nod, pe multe semințe | 9 | ~60 s |
| `verifica_drumuri` | se poate înfunda o expediție? | 4 | ~15 s |
| `verifica_coltul` | nodul împins lângă Boss | **tipărește măsurători, nu verdicte** | ~2 min |
| `verifica_cifru` | generatorul de lacăte și dificultatea măsurată | `VERDICT` | **~10 min** |

**Două scot altceva decât „OK”**, deci nu le căuta verdictele cu grep:
`verifica_coltul` tipărește un tabel de distanțe pe semințe (se citește, nu se
bifează), iar `verifica_cifru` încheie cu „VERDICT: cifrurile ies bine”.

`verifica_cifru` e cu mult cea mai lentă fiindcă rezolvă fiecare lacăt generat ca
un om: **596 de secunde**, măsurat pe 7 octombrie, cu cod de ieșire 0. Merge, doar
că nu la fiecare schimbare — se rulează când atingi generatorul de lacăte. Dacă
devine o piedică, ce se reglează e numărul de semințe din ea, nu existența ei.

Două se judecă altfel și nu ies cu cod de eroare:

- `verifica_steaguri` — **F6 din editor**, toate steagurile într-o grilă. E
  singura verificare pe care un script n-o poate face: „arată bine?” nu e un
  verdict.
- `verifica_podeaua` — **cu fereastră**, nu `--headless`, fiindcă face capturi.

Nu se șterge niciuna fără să dispară o verificare: toate bat sisteme care sunt
încă în joc, iar cele două care par lente sunt lente fiindcă rulează mii de
semințe.

**Fabrica de întrebări** (Python, nu are nevoie de Godot):

```bash
python tools/fabrica/capitale.py             # probă uscată, nu scrie nimic
python tools/fabrica/capitale.py --masoara   # numai măsurători
python tools/fabrica/capitale.py --descarca  # aduce imaginile în assets/
python tools/fabrica/capitale.py --scrie     # scrie în data/trivia_gen/
python tools/fabrica/capitale.py --propune   # candidați de ales, în date/*_propuse.json
```

`tools/fabrica/date/` ține **intrările** fabricii, scrise de mână: `elemente.json`,
`opere.json`, `tari.json`, `autori.json`. Ieșirile lui `--propune`
(`*_propuse.json`) sunt în `.gitignore`: nu le citește niciun script, se refac
dintr-o comandă, iar comise erau 118 KB care se schimbau la fiecare rulare.

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

Decise pe 27 septembrie 2026, cu domeniile retăiate pe 6 octombrie 2026. Contextul complet e în sesiunile CONȚINUTUL, DOMENIILE și PLANUL ȘI CIORNELE din `progres.md`; definițiile domeniilor și regulile pentru note, în `docs/ghid-note.md`; **ce conținut lipsește, de unde se ia și în ce ordine, în `docs/plan-continut.md`** (acolo stau și subcategoriile, cu capcanele fiecărui tabel propus).

| Decizie | Motiv |
|---|---|
| **Întrebările se fabrică offline, nu în joc** | Un script Python scrie `intrebari_trivia.json`; jocul trage în continuare dintr-o listă finită. Păstrează garanția sacului, fiecare întrebare poate fi citită și corectată, jocul nu cere internet |
| **Surse: Wikidata pentru volum, mâna pentru restul** | Wikidata e CC0, deci se poate folosi liber, inclusiv comercial. Cultura românească și întrebările cu personalitate se scriu de mână. Frazele din Wikipedia nu se copiază (CC BY-SA) |
| **Modelul de limbaj formulează, nu informează** | Primește fapte verificate și scrie din ele; nu e niciodată sursa unui fapt. O rată de 2% greșeli la 5000 de întrebări înseamnă 100 de fapte false predate de un joc de învățare |
| **Nota aparține faptului, nu întrebării** | Un fapt dă mai multe întrebări și o singură notă: mai puțină muncă, nicio contradicție. Nota intră în câmpul `explicatie` din contractul `puzzle.gd` |
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
| **Practice: alegi domeniul, nu nivelul** | Nivelul urcă singur, separat pe fiecare domeniu |
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

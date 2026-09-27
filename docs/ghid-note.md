# Ghid pentru notele de Cultură generală

*Scris pe 27 septembrie 2026. Locul lui: `docs/ghid-note.md`, lângă `progres.md`.*

O **notă** e fraza care apare după ce ai răspuns la o întrebare: în modul
Practice, la butonul „Află mai multe”; în sumarul luptei, pentru întrebările
greșite; în Jurnal, ca fapt câștigat. Același text, trei locuri.

Contractul din `puzzle.gd` are deja câmpul pentru ea: `explicatie`. Trivia îl
lasă azi gol, iar un comentariu din `puzzle.gd` spune că explicația „nu are,
deocamdată, un loc unde să fie afișată”. Practice e primul loc care o va afișa.
Nota e ce pune Trivia în câmpul ăla.

---

## 1. Nota aparține faptului, nu întrebării

Un **fapt** e un lucru despre lume care poate fi întrebat în mai multe feluri.
Aurul e un singur fapt, dar dă două întrebări deja existente în bază, pe niveluri
diferite: „Care este simbolul chimic al aurului?” (I) și „Ce element chimic are
numărul atomic 79?” (III). Amândouă primesc aceeași notă.

De ce contează:

- **Mai puțină muncă.** 5000 de întrebări vor avea nevoie de poate 2000 de note,
  nu de 5000.
- **Mai puține greșeli.** Un fapt verificat o dată e corect peste tot unde apare.
  Două note scrise separat despre același lucru ajung, într-o zi, să se contrazică.

**Regula de granularitate:** dacă nota ar trebui să vorbească despre două lucruri
fără legătură între ele ca să acopere ambele întrebări, sunt două fapte, nu unul.
Michelangelo sculptând „David” și pictând Capela Sixtină încap într-o notă,
fiindcă legătura dintre ele (un sculptor care pictează) e chiar cârligul. Leonardo
și Michelangelo nu încap, chiar dacă apar ca distractori unul la celălalt.

---

## 2. Regulile unei note

1. **Se înțelege singură.** În Jurnal nu vezi întrebarea, deci nota conține
   răspunsul corect, spus natural, o dată. Nu „Da, 1989.”, ci „Zidul Berlinului a
   căzut pe 9 noiembrie 1989…”.

2. **Adaugă un cârlig, nu repetă întrebarea.** Răspunsul corect e deja aprins pe
   butoane când apare nota (TIMPUL 3 din `puzzle.gd`). Nota trebuie să dea ceva
   în plus, un motiv să ții minte. Vezi tipurile de cârlig la secțiunea 3.

3. **Una sau două propoziții, 120–200 de caractere, maximum 240.** Pilotul de mai
   jos are între 115 și 232, cu media 164. Cifrele se recalibrează când există
   popup-ul și se vede pe telefon câte rânduri încap fără derulare.

4. **Cel mult trei afirmații verificabile.** Fiecare an, număr și nume propriu e
   ceva ce poate fi greșit și trebuie verificat. O notă cu șapte cifre e o notă cu
   șapte șanse de a preda ceva fals, iar jucătorul nu ține minte șapte cifre
   oricum.

5. **Concret în loc de superlativ.** „Unul dintre cei mai importanți lideri” e
   greu de verificat și nu ajută memoria. „A învins oastea otomană la Vaslui, în
   1475” face și una, și alta.

6. **Precizie la ce nu e fapt sigur.** Convenția se spune „convențional”, legenda
   „potrivit legendei”, ipoteza acceptată „cel mai probabil”. Mitologia se
   povestește din interiorul mitului („În mitologia nordică, Odin…”), nu ca
   istorie.

7. **Fapt, nu consolare.** Nota nu se adresează jucătorului și nu comentează
   greșeala: fără „Nu-i nimic!”, fără „Mulți greșesc aici”. Tonul e al unui prieten
   care știe o poveste bună, nu al unui profesor care corectează.

8. **Scrisă de la zero.** Faptele se pot lua din orice sursă de încredere; frazele
   din Wikipedia nu se copiază (licența CC BY-SA). Scrie din fapte, nu din text.

9. **Diacritice și ghilimele românești.** ș și ț cu virgulă, „ghilimele” ca în
   `intrebari_trivia.json`.

---

## 3. Tipuri de cârlig

| Cârlig | Când îl folosești | Din pilot |
|---|---|---|
| **Confuzia frecventă** | Un distractor e greșeala pe care o face lumea. Nota apare exact după greșeala aia, deci o poate numi. | Canberra, nu Sydney · Dâmbovița, nu Dunărea |
| **Originea numelui** | Numele ascunde explicația. | Au din „aurum” · „impresioniști” · „călcâiul lui Ahile” |
| **Cauza** | Răspunsul pare arbitrar, dar are un motiv. | Canberra, compromis între două orașe · Odin, cu un singur ochi |
| **Legătura** | Faptul se leagă de altă întrebare din bază. | Zidul Berlinului → Revoluția Română · Constantin → 1453 |
| **Categoria** | Răspunsul spune ceva despre ce FEL de lucru e subiectul. | Păianjenul nu e insectă |
| **Detaliul surprinzător** | Un fapt mic care schimbă felul în care vezi subiectul. | Mitocondriile au ADN propriu · Saint-Exupéry chiar a căzut în Sahara |

Când un distractor e o confuzie reală (Sydney, Dunărea, Ag pentru aur), cârligul
de confuzie e aproape mereu cea mai bună alegere: vorbește exact despre greșeala
pe care jucătorul tocmai a făcut-o.

---

## 4. Verificarea

Fiecare fapt are câmpul `verificat`. Pornește `false` și devine `true` abia după ce
**fiecare afirmație din notă** a fost confirmată într-o sursă, nu doar răspunsul
întrebării. În `surse` se scrie de unde, scurt: un nume de manual, un link, un
identificator Wikidata.

Ce verifici, în ordine:

1. fiecare an, număr și nume propriu;
2. direcția relațiilor (cine pe cine a învins, ce vine din ce);
3. ce e legendă, convenție sau ipoteză, și dacă nota o spune.

Încărcătorul poate refuza mai târziu, în Practice, faptele cu `verificat: false`,
sau le poate lăsa să apară fără notă. Decizia se ia când există modul.

**În fabrica de întrebări** (scriptul Python), verificarea devine parțial
automată: nota e scrisă din faptele sursă, iar validatorul cere ca fiecare an,
număr și nume propriu din notă să apară în acele fapte. Prinde exact greșeala
tipică a unui model de limbaj, un an inventat care sună plauzibil. Nu prinde
tot, deci o mostră din note se citește în continuare de mână.

---

## 5. Pilotul: 15 fapte, 18 întrebări din baza existentă

Toate cu `verificat: false`. Le-am scris eu, deci sunt exact cazul pentru care
există secțiunea 4: fiecare afirmație trebuie confirmată înainte să intre în joc.
Sub fiecare notă e lista afirmațiilor de bifat.

### Istorie

**`zidul_berlinului`** · „În ce an a căzut Zidul Berlinului?” (I)
> Zidul Berlinului a căzut pe 9 noiembrie 1989, după ce despărțise orașul timp de
> 28 de ani. Câteva săptămâni mai târziu, în decembrie, a urmat Revoluția Română.

De verificat: 9 noiembrie 1989 · construit în 1961 (deci 28 de ani) · Revoluția
Română în decembrie 1989

**`stefan_cel_mare`** · „Ce domnitor a câștigat lupta de la Vaslui…?” (II) ·
*de adăugat:* „În ce perioadă a domnit Ștefan cel Mare?”
> Ștefan cel Mare a domnit în Moldova 47 de ani, între 1457 și 1504. În 1475 a
> învins oastea otomană la Vaslui, iar mormântul lui se află la Putna, mănăstirea
> pe care a ctitorit-o.

De verificat: domnia 1457–1504 · Vaslui, 1475, împotriva otomanilor · înmormântat
la Putna, ctitoria lui

**`constantinopol`** · „Ce împărat roman a mutat capitala imperiului la Bizanț?”
(III) · „În ce an a căzut Constantinopolul sub stăpânire otomană?” (II)
> Constantin cel Mare a inaugurat în anul 330 noua capitală, pe locul vechiului
> Bizanț, iar orașul i-a primit numele: Constantinopol, azi Istanbul. A rămas
> capitala Imperiului Roman de Răsărit până în 1453, când l-au cucerit otomanii.

De verificat: inaugurarea în 330 · numele după Constantin · cucerirea otomană în 1453

### Geografie

**`dambovita`** · „Ce râu trece prin București?” (I)
> Dâmbovița străbate centrul Bucureștiului. Dunărea, mult mai mare, curge la
> aproximativ 60 de kilometri sud de oraș.

De verificat: distanța până la Dunăre (circa 60 km)

**`canberra`** · „Care este capitala Australiei?” (II)
> Capitala Australiei e Canberra, nu Sydney. Orașul a fost ales la începutul
> secolului XX ca un compromis între Sydney și Melbourne, care își disputau
> amândouă titlul.

De verificat: amplasamentul ales în 1908 · rivalitatea Sydney–Melbourne ca motiv

**`congo`** · „Care este singurul fluviu care traversează Ecuatorul de două ori?”
(III)
> Fluviul Congo traversează Ecuatorul de două ori, într-un arc larg prin Africa
> Centrală. Este al doilea fluviu din lume ca debit, după Amazon.

De verificat: al doilea ca debit, după Amazon

### Știință

**`paianjen`** · „Câte picioare are un păianjen?” (I)
> Păianjenii au opt picioare, deci nu sunt insecte, care au șase. Fac parte din
> arahnide, alături de scorpioni și căpușe.

De verificat: scorpionii și căpușele sunt arahnide

**`mitocondria`** · „Ce organit produce energia în celulă?” (II)
> Mitocondriile produc cea mai mare parte a energiei de care are nevoie celula. Au
> propriul lor ADN, semn că strămoșii lor au fost, cel mai probabil, bacterii care
> trăiau independent.

De verificat: ADN propriu · teoria endosimbiotică drept explicația acceptată
(de aici „cel mai probabil”)

**`aur`** · „Care este simbolul chimic al aurului?” (I) · „Ce element chimic are
numărul atomic 79?” (III)
> Aurul are numărul atomic 79. Simbolul lui, Au, vine din latinescul „aurum”, la
> fel cum Ag, simbolul argintului, vine din „argentum”.

De verificat: Z = 79 · etimologiile Au și Ag

### Artă

**`impresionism`** · „Ce curent artistic și-a luat numele de la tabloul „Impresie,
răsărit de soare”?” (II)
> „Impresie, răsărit de soare” e un tablou de Claude Monet. Un critic i-a folosit
> titlul ca să-i ironizeze pe pictorii din jurul lui, numindu-i „impresioniști”,
> iar ei au adoptat numele.

De verificat: autorul tabloului · criticul (Louis Leroy, 1874) și tonul ironic ·
adoptarea numelui de către pictori

**`michelangelo`** · „Cine a pictat tavanul Capelei Sixtine?” (I) · „Din ce
material este sculptată statuia „David”…?” (I)
> Michelangelo se considera mai ales sculptor: a cioplit „David” din marmură, între
> 1501 și 1504. A pictat totuși și tavanul Capelei Sixtine, lucrând la el între
> 1508 și 1512.

De verificat: „David”, 1501–1504 · tavanul Sixtinei, 1508–1512 · că se considera
în primul rând sculptor

### Mitologie

**`ahile`** · „Ce erou grec era invulnerabil peste tot, în afară de călcâi?” (I)
> Potrivit legendei, mama lui Ahile, Thetis, l-a scufundat în râul Styx ca să-l
> facă invulnerabil, ținându-l de călcâi. De aici vine expresia „călcâiul lui
> Ahile”, adică punctul slab al cuiva.

De verificat: episodul cu Styx (e o variantă târzie a mitului, nu apare la Homer,
de aici „potrivit legendei”)

**`odin`** · „Ce a dat Odin în schimbul unei sorbituri din fântâna înțelepciunii?”
(III)
> În mitologia nordică, Odin și-a dat un ochi pentru o sorbitură din fântâna lui
> Mimir, care dădea înțelepciune. De aceea e înfățișat de obicei cu un singur ochi.

De verificat: numele fântânii (a lui Mimir)

### Literatură

**`sonet`** · „Câte versuri are un sonet?” (II)
> Sonetul are 14 versuri. În forma italiană, ele se împart în două catrene și două
> terține; Shakespeare le-a grupat altfel, în trei catrene și un distih final.

De verificat: structura italiană 4+4+3+3 · structura shakespeariană 4+4+4+2

**`micul_print`** · „Cine a scris „Micul Prinț”?” (I)
> Antoine de Saint-Exupéry era pilot, iar „Micul Prinț”, apărut în 1943, pornește
> de la o aterizare forțată în deșert. Autorul trăise una cu adevărat, în Sahara,
> în 1935.

De verificat: apariția în 1943 · prăbușirea din Sahara, 1935

---

## 6. Cum arată în date

Faptele stau într-un fișier separat, `data/fapte_trivia.json`. Tot o **listă**,
ca `citeste_lista_json` din `puzzle.gd` să-l poată citi fără nicio schimbare:

```json
[
	{
		"id": "aur",
		"nota": "Aurul are numărul atomic 79. Simbolul lui, Au, vine din latinescul „aurum”, la fel cum Ag, simbolul argintului, vine din „argentum”.",
		"surse": [],
		"verificat": false
	}
]
```

Fiecare întrebare din `intrebari_trivia.json` primește două câmpuri noi: un `id`
stabil și `fapt`, legătura spre notă.

```json
{
	"id": "mana:0038",
	"fapt": "aur",
	"text": "Care este simbolul chimic al aurului?",
	"variante": ["Ag", "Fe", "Cu", "Au"],
	"corect": 3,
	"nivel": 1,
	"categorie": "stiinta"
}
```

- **`id`-ul faptului** e un nume scurt, fără diacritice, cu `_`. Nu se schimbă
  niciodată, chiar dacă nota se rescrie.
- **`id`-ul întrebării**: `mana:` plus un număr, pentru cele scrise de mână, dat o
  singură dată și niciodată refolosit. Cele generate vor avea forma lor
  (`wd:…`). Numărul din exemplu e doar ilustrativ.
- **`fapt` e opțional** cât timp pilotul e în lucru. O întrebare fără fapt apare
  fără notă, exact ca azi.

Încărcătorul ar trebui să verifice, cu avertisment în consolă, ca la restul
fișierelor:

- `fapt` care nu există în `fapte_trivia.json`;
- note peste limita de lungime;
- fapte pe care nu le folosește nicio întrebare (conținut mort, care nu se vede
  altfel);
- `id`-uri de întrebare duplicate.

---

## 7. Ce rămâne de stabilit

- **Lungimea reală.** 240 de caractere e o estimare; se reglează pe popup, pe
  telefon.
- **Logica și Cuvintele.** Au deja `explicatie`, dar la Logică e numele regulii cu
  majuscule („FIBONACCI”, „MIXT: x2, APOI +3”). E bun ca etichetă, nu ca notă. Dacă
  „Află mai multe” apare și acolo, va trebui o propoziție („Fiecare termen e suma
  celor doi dinainte”), generată din aceeași regulă.
- **`id`-urile pentru cele 135 de întrebări existente.** Se dau o singură dată,
  printr-un script, în ordinea din fișier, și de atunci nu se mai mișcă.

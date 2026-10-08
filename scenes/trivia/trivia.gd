extends Puzzle
## Disciplina CULTURĂ GENERALĂ (în luptă încă apare ca „Memorie" — redenumirea
## e pasul 2 din ruta de construcție).
##
## Tot ce ține de cronometru, butoane, culori, sunete și contractul cu lupta
## trăiește în `puzzle.gd`. Fișierul ăsta răspunde la o singură întrebare:
## DE UNDE VINE ÎNTREBAREA — și de unde vine ORDINEA variantelor ei.
##
## Întrebările stau într-un fișier JSON, nu în cod. De ce merită mutarea:
## conținutul se schimbă mult mai des decât regulile. Ca să adaugi o întrebare
## nu mai deschizi cod, nu mai riști o virgulă pusă greșit care refuză să
## compileze tot jocul, și poți edita fișierul de pe telefon dacă-ți vine o
## idee. E și primul pas către traduceri.
##
## Prețul: Godot nu mai poate verifica nimic la compilare. Un JSON stricat se
## vede abia la rulare — de aceea încărcătorul de mai jos VALIDEAZĂ fiecare
## intrare și sare peste cele stricate, cu un avertisment în consolă, în loc să
## crape lupta la mijloc.
##
## ── CE CONȚINE BAZA ───────────────────────────────────────────
## Șase domenii (vezi `DOMENII`) pe trei niveluri. Nivelul e singura măsură a
## dificultății, iar înțelesul lui e ăsta, și trebuie păstrat când adaugi
## întrebări:
##
##   nivelul 1 — o știe orice adult, fără să fi studiat ceva anume
##   nivelul 2 — s-a predat la școală; îți amintești dacă ai fost atent
##   nivelul 3 — o știi doar dacă domeniul te-a interesat dincolo de școală
##
## Ce intră în fiecare domeniu, cu regula pentru cazurile de graniță, e în
## `docs/ghid-note.md`. Aici e doar lista, fiindcă aici se validează.
##
## ── ECHILIBRUL PE DOMENII STĂ ÎN ALEGERE, NU ÎN DATE ──────────
## Cele 135 de întrebări scrise de mână erau ținute în echilibru DINADINS, iar
## întrebarea se trăgea din tot nivelul. Mergea fiindcă fișierul era scris de om,
## deci echilibrul era o decizie.
##
## Cu întrebări FABRICATE nu mai merge: conținutul generat nu iese echilibrat și
## nu poate. Deci alegerea e acum în DOUĂ TREPTE — întâi domeniul, uniform între
## cele care trec `PRAG_DOMENIU` la nivelul cerut, apoi întrebarea din el. Așa
## echilibrul nu mai depinde de cât de mare crește un domeniu. Motivul lung e în
## `trage_intrebarea`; aceeași formă ca la Logică, unde se alege întâi
## categoria de regulă și abia apoi șirul.
##
## ── FĂRĂ REPETIȚII ────────────────────────────────────────────
## Întrebările NU se aleg pur aleatoriu. Se trag dintr-un „sac" care ține
## minte ce a ieșit deja în expediția curentă (`autoload/sac.gd`), iar
## variantele se amestecă la fiecare apariție (`_amesteca`, mai jos).
##
## Sacul recunoaște o întrebare după `id`, nu după text — vezi de ce în
## `trage_intrebarea`. Cheia lui cuprinde domeniul ȘI nivelul; de ce trebuie
## să cuprindă domeniul e scris la `SAC`, și e o capcană care nu s-ar fi văzut
## niciodată jucând.
##
## ── DOUĂ FELURI DE CONȚINUT, UN FIȘIER ȘI UN DOSAR ────────────
## Scris de mână:  `data/intrebari_trivia.json` + `data/fapte_trivia.json`
## Fabricat:       tot ce e în `data/trivia_gen/` (vezi `DOSAR_GEN`)
##
## Nota stă pe FAPT, nu pe întrebare, iar întrebarea arată spre fapt printr-un
## câmp `fapt`. Regulile de scris ale unei note sunt în `docs/ghid-note.md`.
##
## Fișierele fabricate se rescriu ÎNTREGI de `tools/fabrica/elemente.py`. Nu se
## editează de mână — se editează tabelul din script.
##
## ── DOUĂ REGULI DESPRE `id`, PE CARE NIMIC DIN COD NU LE APĂRĂ ─
## 1. Un `id` NU SE REFOLOSEȘTE NICIODATĂ. Deci întrebările nu se șterg din
##    fișier: una scoasă din joc se marchează `"retras": true` și rămâne pe loc,
##    cu id-ul ei. Încărcătorul de aici va învăța să sară peste ele când va fi
##    nevoie — azi nu e nimic retras, deci nu există codul. Motivul întreg e în
##    antetul lui `tools/da_iduri.py`: un id refolosit dă unei întrebări noi
##    istoricul altei întrebări, iar nimic nu poate prinde asta.
## 2. `id`-urile se dau cu scriptul, nu de mână: `python tools/da_iduri.py --scrie`.

const CALE_INTREBARI := "res://data/intrebari_trivia.json"

# ─────────────────────────────────────────────────────────────
# DOSARUL CU CONȚINUT FABRICAT
#
# `intrebari_trivia.json` e scris de mână, întrebare cu întrebare. Tot ce e în
# `data/trivia_gen/` e SCRIS DE SCRIPTURILE din `tools/fabrica/`, din date luate
# de la Wikidata, și se rescrie ÎNTREG la fiecare rulare a scriptului care l-a
# produs. Nu se editează de mână: orice corectură pusă direct în el dispare la
# prima regenerare. Ce se editează e tabelul scriptului.
#
# De ce despărțit de fișierul scris de mână: ca acela să nu fie NICIODATĂ atins
# de un script. 135 de întrebări scrise una câte una sunt câteva săptămâni de
# muncă; un generator cu un bug care le rescrie e o pierdere din care nu te mai
# întorci. Despărțirea nu e curățenie, e o asigurare.
#
# DE CE UN DOSAR ȘI NU O CONSTANTĂ PE FIȘIER. Fabrica are azi două tabele
# (elementele chimice, operele literare) și va avea mai multe. Cu o constantă pe
# fișier, fiecare tabel nou ar însemna o linie în `trivia.gd`, una în încărcător
# și una în verificator — adică exact ce spune CLAUDE.md că n-are voie să se
# întâmple: „o disciplină nouă trebuie să fie un rând în tabel, nu o ramură nouă
# în cod". Cu un dosar, un tabel nou e două fișiere puse acolo și nicio linie de
# cod, nicăieri.
#
# Convenția de nume, pe care se sprijină citirea:
#   <tabel>_intrebari.json   întrebările
#   <tabel>_fapte.json       faptele lor
const DOSAR_GEN := "res://data/trivia_gen"

# COMUTATORUL. `false` și jocul nu mai vede NIMIC din dosarul fabricat — nici
# întrebările, nici faptele — fără să se atingă nimic altceva.
#
# Există fiindcă conținutul fabricat poate să nu-mi placă. Azi sunt trei relații
# („element ↔ simbol" în știință și natură, „operă ↔ autor" în artă și
# literatură, „țară ↔ capitală" în geografie), fiecare umplând grosul domeniului
# ei. Dacă se simte prea mult, se stinge de aici, iar leacul adevărat nu e o
# treaptă de alegere în plus, e lățimea conținutului.
#
# Cu el stins rămâne numai mâna: 8/8/8 pe nivel la geografie, istorie și știință
# și natură, 21 la artă și literatură. Toate trec `PRAG_DOMENIU`, deci jocul
# rămâne cu patru domenii, nu cu unul — vezi socoteala de acolo.
const FOLOSESTE_WIKIDATA := true

# FAPTELE. Un „fapt" e un lucru despre lume care poate fi întrebat în mai multe
# feluri, iar NOTA („Află mai multe") stă pe fapt, nu pe întrebare: faptul `aur`
# acoperă și „simbolul chimic al aurului" (nivelul I), și „ce element are numărul
# atomic 79" (nivelul III), cu o singură notă pentru amândouă. Motivul lung e în
# `docs/ghid-note.md`, secțiunea 1. Pe scurt: mai puțină muncă (5000 de întrebări
# au nevoie de vreo 2000 de note) și mai puține greșeli, fiindcă un fapt verificat
# o dată e corect peste tot unde apare. Două note scrise separat despre același
# lucru ajung, într-o zi, să se contrazică.
const CALE_FAPTE := "res://data/fapte_trivia.json"

# Faptele fabricate stau tot în `DOSAR_GEN`, în fișierele `*_fapte.json`.
#
# Toate au NOTA GOALĂ, deocamdată, deci nu aduc nimic pe ecran. Fișierele există
# dintr-un motiv mai mic și mai practic: fiecare întrebare fabricată arată spre
# un `fapt` (`wd:Q897`), iar `_intrebare_valida` se plânge, cu drept, pentru un
# `fapt` care nu duce nicăieri. Fără ele, jocul ar porni cu peste 300 de
# avertismente — iar de-acolo încolo consola nu mai e un loc unde se citește ceva.
#
# ATENȚIE, e scris și în `docs/progres.md`: fiindcă fișierele se REscriu întregi,
# notele pentru faptele `wd:` NU pot sta în ele. Când vor exista, vor sta într-un
# loc pe care generarea nu-l atinge.

# Lungimea maximă a unei note, în caractere. Cifră PROVIZORIE: se reglează când
# există popup-ul din Practice și se vede pe telefon câte rânduri încap fără
# derulare (`docs/ghid-note.md`, secțiunea 7). Depășirea e un avertisment, nu un
# refuz — e o limită de stil, nu de corectitudine, iar o notă bună nu merită
# tăiată ca să respecte o cifră nejucată.
const MAX_NOTA := 240

# DOMENIILE: cheia din JSON → numele care se vede în antetul întrebării.
#
# Lista NU e decor: o cheie scrisă greșit în JSON („istoire") e prinsă la
# încărcare, cu un avertisment în consolă, în loc să ajungă în luptă ca antet
# fără sens.
#
# DE CE UN DICTIONARY, NU DOUĂ LISTE. Are două treburi — validează cheia
# (`DOMENII.has`) și dă numele afișat (`DOMENII[cheie]`). Cu o listă de chei
# lângă un dicționar de nume, un domeniu nou ar fi două locuri de ținut
# sincronizate, iar al doilea se uită. Așa rămâne un rând, ca la Obeliscuri.
#
# CHEIA NU E NUMELE. Cheia intră în `id`-uri, în cheile sacului și, mâine, în
# save — deci n-are diacritice și nu se schimbă niciodată. Numele e doar text pe
# ecran și se poate rescrie oricând. Antetul le pune cu majuscule
# („ARTĂ ȘI LITERATURĂ"); Logica afișează deja etichete de două-trei cuvinte.
#
# CELE ȘASE, și de ce astea. Vechile șase (istorie, geografie, stiinta, arta,
# mitologie, literatura) erau tăiate după cum crescuse baza scrisă de mână, nu
# după cum arată cultura generală pentru cineva care joacă. Artă, mitologie și
# literatură erau trei domenii subțiri care se întreabă la fel (cine a scris,
# cine a pictat, cine a compus) — acum sunt unul singur, destul de gros. În
# locul lor au intrat două care lipseau cu totul: Divertisment și Sport.
# Amândouă pornesc GOALE, deci azi sunt sărite (vezi `PRAG_DOMENIU`); există în
# listă fiindcă un domeniu scris de la început e un rând, iar unul adăugat după
# ce s-a scris conținut e o migrare.
#
# Ce intră în fiecare, cu regula pentru cazurile de graniță și cu regula
# „numai trecut" de la Divertisment și Sport: `docs/ghid-note.md`.
const DOMENII := {
	"geografie": "Geografie și explorare",
	"istorie": "Istorie și societate",
	"stiinta_tehnologie": "Știință și tehnologie",
	"arta_literatura": "Artă și literatură",
	"divertisment": "Divertisment și media",
	"sport_jocuri": "Sport și jocuri",
	"gastronomie_lifestyle": "Gastronomie și lifestyle",
	"diverse": "Diverse și curiozități",
}


# SUBCATEGORIILE: domeniu → (cheie din JSON → numele care se va vedea în Practice).
#
# ─── DE CE UN CÂMP PE ÎNTREBARE, NU O ETICHETĂ PE FAPT ────────
# În Practice vreau să pot alege „geografie → capitale”. Un meniu care alege are
# nevoie de două lucruri: cifre corecte și garanția că nicio întrebare nu rămâne
# pe dinafară. Adică de o ÎMPĂRȚIRE, nu de etichete care se suprapun — fiecare
# întrebare stă în exact o subcategorie.
#
# `etichete`, de pe fapt, rămâne pentru filtrele TRANSVERSALE, care taie peste
# subcategorii: `romania` e singura de azi. O întrebare despre Posada e
# `istorie` / `ev_mediu` / etichetă `romania`; una despre Dâmbovița e
# `geografie` / `ape` / etichetă `romania`. Dacă `romania` ar fi fost
# subcategorie, ar fi trebuit să aleg între „e despre România” și „e despre
# râuri”, iar meniul ar fi avut două răspunsuri la aceeași întrebare.
#
# ─── CUM SE ALEGE, ACEEAȘI REGULĂ CA LA DOMENIU ───────────────
# Subcategoria o dă CE TREBUIE SĂ ȘTII ca să răspunzi, nu subiectul. „Pe ce râu
# stă Viena?” e `orase` (poziția unui oraș), nu `ape`. Înțelesul fiecărei chei,
# cu cazurile de graniță, e în `docs/plan-continut.md`; aici e doar lista,
# fiindcă aici se validează.
#
# ─── CHEIA NU E NUMELE ────────────────────────────────────────
# Ca la `DOMENII`: cheia intră în cheile sacului din Practice
# („practice:geografie:capitale”) și, de la Save, pe disc — deci fără diacritice
# și nu se schimbă niciodată. Numele e text pe ecran.
#
# ─── TOATE ȘASE DOMENIILE, DE LA BUN ÎNCEPUT ──────────────────
# Lista e completă, deși azi se folosesc patru chei din 36. Același motiv pentru
# care Divertismentul și Sportul au fost scrise goale în `DOMENII`: o
# subcategorie scrisă de la început e un rând, iar una adăugată după ce s-a scris
# conținut e o migrare. Ca să nu rămână promisiuni uitate, verificatorul
# tipărește la fiecare rulare subcategoriile care n-au nicio întrebare.
const SUBCATEGORII := {
	"geografie": {
		"geografie_politica": "Geografie politică",
		"geografie_fizica": "Geografie fizică",
		"turism_monumente": "Turism și monumente",
		"demografie_cultura": "Demografie și cultură",
	},
	"istorie": {
		"antichitate_ev_mediu": "Antichitate și Ev Mediu",
		"modern_contemporan": "Istorie modernă și contemporană",
		"lideri_personalitati": "Lideri și personalități",
		"mitologie_religii": "Mitologie și religii",
	},
	"stiinta_tehnologie": {
		"stiinte_exacte": "Științe exacte",
		"lumea_vie": "Lumea vie",
		"astronomie_spatiu": "Astronomie și spațiu",
		"tehnologie_inventii": "Tehnologie și invenții",
	},
	"arta_literatura": {
		"literatura_universala": "Literatură universală",
		"arte_vizuale": "Arte vizuale",
		"arhitectura_design": "Arhitectură și design",
		"cultura_clasica": "Cultură clasică",
	},
	"divertisment": {
		"cinematografie": "Cinematografie",
		"televiziune": "Televiziune",
		"muzica_moderna": "Muzică modernă",
		"pop_culture": "Pop culture și internet",
	},
	"sport_jocuri": {
		"sporturi_de_echipa": "Sporturi de echipă",
		"individuale_olimpism": "Sporturi individuale și olimpism",
		"motor_extreme": "Sporturi cu motor și extreme",
		"gaming": "Gaming și jocuri de masă",
	},
	"gastronomie_lifestyle": {
		"bucataria_lumii": "Bucătăria lumii",
		"ingrediente_tehnici": "Ingrediente și tehnici",
		"bauturi": "Băuturi",
		"moda_traditii": "Modă și tradiții",
	},
	# LOGICA DE AICI NU E OBELISCUL LOGICĂ, și granița merită scrisă fiindcă
	# altfel aceeași întrebare ar putea veni din două locuri.
	#
	# Obeliscul Logică GENEREAZĂ șiruri și deducții de rezolvat: „4, 8, 12, ?”.
	# `logica_perspicacitate` de aici ține FAPTE despre logică — un paradox cu
	# nume, o ghicitoare celebră, un termen. Prima e o problemă pe care o rezolvi,
	# a doua e un lucru pe care îl știi. Dacă vreodată o întrebare de aici se poate
	# rezolva gândind, fără s-o fi auzit, ea aparține Obeliscului.
	"diverse": {
		"lingvistica": "Lingvistică",
		"logica_perspicacitate": "Logică și perspicacitate",
		"curiozitati": "Curiozități",
	},
}

# CÂMPURILE pe care le poate avea o întrebare. Lista e ÎNCHISĂ, iar un câmp
# necunoscut REFUZĂ întrebarea — un câmp scris greșit („verifcat”) ar fi o
# întrebare care se poartă altfel decât crezi, fără ca nimic să spună nimic.
# Refuzată, se vede în linia de bilanț („212 încărcate din 213 găsite”).
#
# `retras` NU E ÎN LISTĂ, deși e o convenție scrisă (`tools/da_iduri.py`: o
# întrebare scoasă din joc se marchează retrasă și rămâne pe loc, cu id-ul ei).
# Codul care sare peste retrase nu există încă. Dacă pun câmpul în listă acum,
# prima întrebare retrasă ar rămâne în joc, în tăcere; așa, ziua aia mă oprește și
# scriu codul de care e nevoie.
const CAMPURI_INTREBARE := ["id", "verificat", "fapt", "text", "variante",
	"corect", "nivel", "subcategorie", "categorie"]

# CÂMPURILE unui fapt. Tot închisă, din același motiv.
const CAMPURI_FAPT := ["id", "nota", "etichete", "imagini"]

# CÂTE ÎNTREBĂRI TREBUIE SĂ AIBĂ UN DOMENIU LA UN NIVEL ca să intre în alegerea
# din luptă. Se măsoară pe CELULĂ (domeniu × nivel), nu pe domeniu: un domeniu
# poate fi gros la nivelul I și gol la III, iar alegerea se face oricum pe
# nivelul cerut.
#
# ─── DE CE EXISTĂ ─────────────────────────────────────────────
# Alegerea e uniformă pe domenii (vezi `trage_intrebarea`), deci un domeniu ia
# 1/N din întrebările de luptă oricât de sărac ar fi. Un domeniu cu două
# întrebări ar da două întrebări în 1/6 din luptă — adică exact o întrebare
# gratis, repetată, care e cel mai rău lucru într-un joc de antrenament mental.
# Sub prag domeniul e SĂRIT, nu golit: întrebările rămân încărcate, numărate de
# verificator, și domeniul reintră singur în clipa în care celula se umple.
#
# ─── DE CE 8, ȘI NU ALT NUMĂR ─────────────────────────────────
# 1. E cât trage o expediție lungă dintr-un domeniu. O expediție lungă consumă
#    ~45 de întrebări de Cultură generală. Cu `TREPTE_PE_NIVEL = 3` și o rată de
#    reușită de 0,8, un lanț dă în medie 2,4 întrebări de nivelul I, 1,25 de II
#    și 1,3 de III — deci ~49% din trageri cad pe nivelul I, adică ~22. Împărțite
#    la cele 4 domenii care trec pragul azi: 5-6 trageri pe celulă. Sacul
#    garantează „nicio repetiție până se golește", deci la 8 nu se repetă nimic
#    într-o expediție; la 4 s-ar repeta o dată, la 2 de două ori.
# 2. E o celulă scrisă de mână. Baza de 135 a fost construită 7-8 pe celulă,
#    deci 8 e cea mai mică porție de conținut pe care o produc dinadins.
# 3. Nu aruncă nimic din ce am. Istoria are exact 8 pe fiecare nivel și trece la
#    limită; la 10 aș fi pierdut istoria din joc printr-o regulă pusă să apere
#    echilibrul. Și cu `FOLOSESTE_WIKIDATA` stins rămâne 8/8/8/21 pe nivel, deci
#    toate trec — la 9, stingerea comutatorului ar lăsa un singur domeniu.
#
# PREȚUL, spus pe față: istoria trece cu zero rezervă, deci fiecare expediție
# lungă îți arată 5-6 din cele 8 întrebări de istorie ale unui nivel. Pragul nu
# ascunde asta, o numește — istoria e următoarea țintă de conținut, iar
# verificatorul tipărește rezerva fiecărei celule, nu doar dacă trece.
const PRAG_DOMENIU := 8

# Cheia sacului din care se trag întrebările, fără repetiții, cât ține o
# expediție. Vezi `autoload/sac.gd`.
#
# ÎN CHEIE INTRĂ ȘI DOMENIUL, ȘI NIVELUL, și nu e o alegere de stil — e o
# obligație. Regula sacului e: cheia trebuie să cuprindă TOT ce face lista să fie
# alta. De când alegerea e în două trepte (vezi `trage_intrebarea`), lista
# primită de sac e filtrată pe UN domeniu, deci domeniul face parte din ce
# deosebește lista.
#
# Ce s-ar întâmpla altfel, cu cheia veche `cultura_generala:1` și o listă doar de
# știință: `Sac.extrage` golește tot registrul unei chei când lista primită se
# epuizează (`sac.gd`, „sacul s-a golit → ciclu nou"). Adică în clipa în care se
# termină întrebările de știință de nivelul I, sacul ar șterge și memoria
# geografiei, a istoriei și a celorlalte de pe același nivel. Nu ar crăpa nimic;
# s-ar vedea doar ca „uneori se repetă ceva", adică bug-ul pe care nu-l prinzi
# jucând.
#
# Efectul secundar e bun: garanția devine „nicio repetiție ÎN CADRUL unui
# domeniu", care e mai tare decât cea de dinainte, nu mai slabă.
const SAC := "cultura_generala"

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de ~7 ori pe rundă; fără `static`, fișierul ar fi citit
# de pe disc de fiecare dată. Așa, se citește o singură dată pe rulare,
# iar toate instanțele viitoare folosesc aceeași listă.
static var intrebari: Array[Dictionary] = []
static var incarcare_incercata := false

## Câte întrebări n-au încă `subcategorie`. Cele 135 scrise de mână înaintea
## câmpului o primesc într-un lot separat de clasificare; până atunci sunt
## acceptate, cu UN rând de bilanț la încărcare, nu cu 135 de avertismente.
static var fara_subcategorie := 0

## Câte întrebări au `verificat: false`, adică notele lor n-au fost încă citite
## de nimeni.
##
## ─── DE CE E DOAR O CIFRĂ, NU UN FILTRU ───────────────────────
## Fiindcă o întrebare NEVERIFICATĂ INTRĂ ÎN JOC. Flagul nu decide nimic în
## luptă: spune doar dacă am citit nota ei și am găsit afirmațiile într-o sursă.
##
## A fost, o zi, altfel: exista un câmp `ciorna` care ținea întrebarea afară din
## joc până o confirmam cu un script, iar faptul avea și el un `verificat`, cu
## `surse` și o listă de afirmații de bifat. Două flaguri, două fișiere și două
## unelte cu parametri — mai multă mașinărie decât conținut. S-a desfăcut tot:
## un singur câmp, pe întrebare, pe care-l pui pe `true` de mână, în JSON, când
## ai citit nota. Nimic nu-l cere și nimic nu se schimbă în joc când îl pui.
##
## Cifra se tipărește la încărcare, într-un rând, ca să se vadă cât a mai rămas
## de citit. Nu e un verdict și n-are nevoie de nimeni ca s-o actualizeze.
static var neverificate := 0

## Faptele, ca `id` → notă. Un Dictionary, nu o listă, fiindcă singura întrebare
## pusă vreodată aici e „ce notă are faptul ăsta?" — o căutare pe cheie, de câteva
## ori pe rundă.
static var fapte := {}

## Nivelurile la care s-a spus deja că alegerea a căzut pe plasa din
## `trage_intrebarea`. Folosit ca mulțime: valoarea nu înseamnă nimic.
static var _plasa_spusa := {}


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește fișierul. Chemată de mai multe ori, face ceva o singură dată.
func _pregateste_datele() -> void:
	incarca_intrebari()


## A doua: produce o întrebare. Tot ce urmează după — cronometru, culori,
## verdict — e treaba bazei, care nu știe că a primit trivia.
func _compune_intrebare(nivel: int) -> Dictionary:
	var q := trage_intrebarea(nivel)

	# Dicționar gol = „n-am putut": baza arată ecranul de eroare și raportează
	# eșec ordonat, în loc să lase lupta să aștepte un semnal care nu mai vine.
	if q.is_empty():
		return {}

	# Variantele se amestecă ACUM, la fiecare apariție a întrebării.
	var amestecate := _amesteca(q)

	return {
		# Antetul spune doar din ce domeniu e întrebarea. Nivelul nu apare —
		# îl simți oricum din cronometru și din dificultate.
		#
		# Se afișează NUMELE, nu cheia: „ARTĂ ȘI LITERATURĂ", nu
		# „ARTA_LITERATURA". `get` cu cheia pe post de rezervă e o plasă care
		# n-ar trebui să prindă niciodată — încărcătorul refuză deja întrebările
		# cu domeniu necunoscut — dar, dacă prinde, pe ecran apare ceva citibil
		# în loc de gol.
		"categorie": String(DOMENII.get(String(q["categorie"]), q["categorie"])).to_upper(),
		"text": q["text"],
		"variante": amestecate["variante"],
		"corect": amestecate["corect"],
		# NOTA faptului, dacă întrebarea e legată de unul. Câmpul `explicatie` din
		# contractul cu `puzzle.gd` exista deja, gol: la Logică ține numele regulii
		# („FIBONACCI"), la Trivia nu ținea nimic, fiindcă la o întrebare de cultură
		# generală ori știi, ori nu — n-are „regulă de rezolvare".
		#
		# Nota e ce intră acolo. Rămâne gol pentru întrebările fără fapt, iar baza
		# acceptă gol: câmpul e opțional tocmai pentru cazul ăsta.
		#
		# NIMENI NU-L AFIȘEAZĂ ÎNCĂ. Primul loc va fi „Află mai multe" din Practice
		# (pasul 13), pentru toate disciplinele deodată. Se umple de pe acum fiindcă
		# e o linie aici și un fișier de conținut în plus, iar conținutul e partea
		# lentă: notele se pot scrie și verifica luni de zile înainte să existe
		# ecranul care le arată.
		"explicatie": String(fapte.get(String(q.get("fapt", "")), "")),
	}


## ÎNTÂI DOMENIUL, APOI ÎNTREBAREA. Întoarce întrebarea BRUTĂ, așa cum stă în
## fișier — fără amestecare, fără împachetare pentru ecran. Dicționar gol dacă nu
## s-a putut trage nimic.
##
## DE CE E `static`, ȘI DESPĂRȚITĂ DE `_compune_intrebare`. Ca s-o poată chema
## verificarea din `tools/verificari/verifica_trivia.gd`, fără fereastră și fără scenă.
## Echilibrul pe domenii și sacul sunt exact lucrurile care NU se pot proba
## jucând — ca să vezi cu ochiul că știința nu ia 85% din întrebări, ar trebui să
## numeri câteva mii de lupte. Alternativa ar fi fost să rescrie verificarea
## alegerea asta la ea, și atunci ar fi probat copia, nu codul.
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎN DOUĂ TREPTE
##
## Până la conținutul fabricat, întrebarea se trăgea din TOT nivelul, iar
## echilibrul pe domenii era ținut de mână în fișier. Mergea fiindcă fișierul era
## scris de om, deci echilibrul era o decizie.
##
## Conținutul generat nu iese echilibrat și nu POATE ieși: Wikidata e bogată în
## geografie, științe și date, și săracă în folclor românesc. Cele 139 de
## întrebări despre elemente intră toate în știință, iar dacă alegerea ar rămâne
## „trage din tot nivelul", știința ar lua 85% din întrebări și „Cultură
## generală" ar deveni, în practică, „Chimie, cu accidente" — adică ai antrena un
## singur colț de minte.
##
## Deci echilibrul se mută din date în ALEGERE, unde nu mai depinde de cât de
## mare crește un domeniu. Aceeași formă ca la Logică, unde se alege întâi
## categoria de regulă și abia apoi șirul: acolo alegerea în două trepte e chiar
## ce împiedică „Fibonacci" să apară cât toate celelalte la un loc.
##
## ─────────────────────────────────────────────────────────────
## ȘI DE CE ALEGEREA SARE DOMENIILE SUBȚIRI
##
## Uniformitatea taie în amândouă sensurile: ea e cea care împiedică știința să
## ia 85%, dar tot ea RIDICĂ un domeniu cu două întrebări la 1/N din toată
## lupta. Fără prag, ziua în care deschid Divertismentul cu trei întrebări ar fi
## ziua în care una din șase întrebări de luptă e una din acele trei.
##
## Deci un domeniu intră în alegere doar dacă are `PRAG_DOMENIU` întrebări la
## nivelul cerut. Cele de sub prag sunt SĂRITE, nu scoase: rămân în `intrebari`,
## rămân numărate de verificator, și reintră singure când celula se umple.
static func trage_intrebarea(nivel: int) -> Dictionary:
	# `filter` trece prin array și păstrează doar elementele pentru care
	# funcția anonimă (lambda) întoarce true. Aici: doar întrebările de nivelul cerut.
	var pool: Array = intrebari.filter(func(q): return int(q["nivel"]) == nivel)
	if pool.is_empty():
		pool = intrebari   # plasă de siguranță: mai bine o întrebare de alt nivel decât niciuna
	if pool.is_empty():
		return {}          # fișierele lipsesc sau sunt complet stricate

	# TREAPTA 1: domeniul.
	var pe_domenii := {}
	for q in pool:
		var domeniu := String(q["categorie"])
		if not pe_domenii.has(domeniu):
			pe_domenii[domeniu] = []
		pe_domenii[domeniu].append(q)

	# PRAGUL. Domeniile prea subțiri la nivelul ăsta ies din alegere — nu din
	# date. Motivul e la `PRAG_DOMENIU`: alegerea uniformă ar ridica un domeniu cu
	# trei întrebări la 1/N din toată lupta.
	var destule: Array = []
	for domeniu in pe_domenii:
		if (pe_domenii[domeniu] as Array).size() >= PRAG_DOMENIU:
			destule.append(domeniu)

	# PLASA. Dacă NICIUN domeniu nu trece pragul, se joacă cu toate cele prezente.
	# O întrebare repetată e mult mai bună decât un Obelisc care întoarce dicționar
	# gol și scoate ecranul de eroare în mijlocul unui lanț. Nu se poate întâmpla
	# cu conținutul de azi; se poate întâmpla la prima disciplină nouă de conținut
	# care pornește de la zero, și atunci vreau să fie spus, nu descoperit.
	if destule.is_empty():
		# O DATĂ PE NIVEL, PE TOATĂ RULAREA. Întâi am scris-o fără registru, și
		# verificarea a tipărit același avertisment de o mie de ori — fiindcă locul
		# ăsta e pe drumul FIECĂREI întrebări, nu al încărcării. Într-o luptă ar fi
		# însemnat o consolă în care nu se mai poate citi nimic altceva, adică exact
		# opusul a ce vrea un avertisment.
		if not _plasa_spusa.has(nivel):
			_plasa_spusa[nivel] = true
			push_warning(("Trivia: la nivelul %d niciun domeniu nu are %d intrebari; " +
				"joc cu toate cele %d prezente.") % [nivel, PRAG_DOMENIU, pe_domenii.size()])
		destule = pe_domenii.keys()

	# Ordinea din `destule` nu contează, și nici nu e promisă. Ce ne trebuie e ca
	# fiecare domeniu ADMIS să aibă șansa 1/N, indiferent câte întrebări are — și
	# asta o dă `pick_random` peste lista de CHEI, nu peste întrebări.
	var domeniu_ales: String = String(destule.pick_random())
	pool = pe_domenii[domeniu_ales]

	# TREAPTA 2: întrebarea.
	#
	# Aici NU folosim `pool.pick_random()`. Sacul e cel care ține minte ce
	# s-a pus deja pe masă în expediția asta și trage doar dintre întrebările
	# rămase — motivul lung e scris în `autoload/sac.gd`. Pe scurt: alegerea
	# pur aleatoare repetă mai des decât crezi, iar o întrebare repetată e o
	# întrebare gratis într-un joc de antrenament mental.
	#
	# „id" e câmpul după care sacul recunoaște o întrebare.
	#
	# Nu poziția în listă: aia se mută de fiecare dată când adaugi o întrebare la
	# mijlocul fișierului. Dar nici TEXTUL, care a fost identitatea de până acum:
	# textul se schimbă la fiecare reformulare, iar în ziua în care rescriu o
	# întrebare ca să sune mai bine, un save ar crede că e o întrebare cu totul
	# nouă — nevăzută, deci gratis. `id`-ul e singurul câmp care nu se mișcă
	# niciodată, tocmai pentru că nu înseamnă nimic pentru jucător.
	#
	# CHEIA CUPRINDE DOMENIUL, nu doar nivelul — vezi nota lungă de la `SAC`. Lista
	# pe care o primește sacul e filtrată pe un singur domeniu, iar o cheie comună
	# ar face ca epuizarea unui domeniu să golească registrul tuturor celorlalte
	# de pe același nivel.
	var tras = Sac.extrage(cheia_sacului(domeniu_ales, nivel), pool, "id")
	if tras == null:
		return {}
	return tras


## Cheia sacului pentru un domeniu și un nivel. Un rând, dar într-un singur loc:
## verificarea are nevoie de aceeași cheie ca lupta, iar două locuri care compun
## același text ajung, într-o zi, să-l compună altfel.
static func cheia_sacului(domeniu: String, nivel: int) -> String:
	return "%s:%s:%d" % [SAC, domeniu, nivel]


## Ce fișier să cauți dacă ecranul de eroare apare vreodată în luptă.
func _descriere_sursa() -> String:
	if FOLOSESTE_WIKIDATA:
		return "%s + %s/" % [CALE_INTREBARI, DOSAR_GEN]
	return CALE_INTREBARI


## Trivia ÎȘI POARTĂ SINGURĂ de grijă la repetiții, deci întoarce șir gol și
## oprește reîncercarea din `puzzle.gd`.
##
## Nu e o scutire, e o unealtă mai bună. Baza nu poate decât să ceară din nou
## și să spere, fiindcă o disciplină generativă nu-și poate enumera
## întrebările. Trivia ȘI LE POATE: sunt 45 pe nivel, într-un fișier. De aceea
## trage din sac (`Sac.extrage`), care nu repetă niciuna cât timp mai există
## una nevăzută — o garanție, nu o probabilitate. Două mecanisme peste
## aceleași întrebări ar fi șters exact garanția asta.
func _identitate_intrebare(_q: Dictionary) -> String:
	return ""


# ─────────────────────────────────────────────────────────────
# AMESTECAREA VARIANTELOR
# ─────────────────────────────────────────────────────────────

## Întoarce aceleași patru variante, în altă ordine, plus noul indice corect.
##
## DE CE E NEVOIE DE EA. Într-un fișier scris de mână, răspunsul bun nu cade
## uniform pe cele patru poziții — cine scrie întrebări are obiceiuri. În
## baza de acum, înainte de amestecare, poziția a doua era corectă de patru
## ori mai des decât ultima. Asta nu e un amănunt de statistică: e o
## SCURTĂTURĂ. Sub cronometru, un jucător care nu știe răspunsul ghicește, iar
## dacă ghicitul are un favorit, el îl va găsi fără să-l caute — și va marca
## puncte fără să fi gândit. Într-un joc de antrenament mental, asta e cel
## mai rău lucru care se poate întâmpla.
##
## Se putea și rescriind fișierul, mutând răspunsurile până ies 25% pe
## fiecare poziție. Ar fi ținut exact până la a 136-a întrebare scrisă
## noaptea, când obiceiul revine. Amestecarea la rulare rezolvă problema o
## dată, pentru toate întrebările care vor mai fi scrise vreodată.
##
## BONUS: aceeași întrebare, văzută a doua oară peste două expediții, nu-ți
## mai poate fi ghicită din poziția butonului. Ții minte RĂSPUNSUL sau nimic.
static func _amesteca(q: Dictionary) -> Dictionary:
	# `duplicate()` face o COPIE. Fără el, `shuffle()` ar amesteca chiar
	# lista din `intrebari`, care e ținută în memorie pentru toată rularea:
	# ai amesteca originalul, nu afișarea lui.
	var variante: Array = (q["variante"] as Array).duplicate()

	# Reținem TEXTUL răspunsului bun, nu indicele: indicele e exact lucrul
	# care se schimbă în rândurile următoare.
	var raspuns: String = String(variante[int(q["corect"])])
	variante.shuffle()

	# `find()` întoarce prima poziție pe care apare textul. E corect FIINDCĂ
	# încărcătorul refuză întrebările cu două variante identice — altfel
	# „prima potrivire" ar putea fi cealaltă, iar răspunsul bun ar fi
	# marcat greșit. Verificarea de acolo nu e curățenie: ea e ce face
	# linia asta sigură.
	return {"variante": variante, "corect": variante.find(raspuns)}


# ─────────────────────────────────────────────────────────────
# ÎNCĂRCAREA
# ─────────────────────────────────────────────────────────────

## Citește și validează amândouă fișierele. Sigur de chemat de oricâte ori:
## după prima încercare nu mai face nimic.
##
## FAPTELE ÎNTÂI, din două motive. Unul: întrebările au nevoie de mulțimea de
## fapte ca să-și poată verifica legătura. Celălalt: după ce s-au citit amândouă
## se poate pune întrebarea inversă — există fapte pe care nu le folosește nicio
## întrebare? Aia e singura verificare care are nevoie de ambele fișiere deodată,
## și e cea care prinde conținut mort: o notă scrisă degeaba nu se vede altfel
## niciodată, fiindcă lipsa ei nu strică nimic.
static func incarca_intrebari() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	_incarca_fapte(CALE_FAPTE)
	if FOLOSESTE_WIKIDATA:
		for cale in fisierele_generate("_fapte.json"):
			_incarca_fapte(cale)

	# `folosite` strânge, cât trec întrebările, faptele de care se agață măcar una.
	# `id_uri` prinde duplicatele: două întrebări cu același `id` sunt, pentru sac,
	# o singură întrebare — una din ele n-ar mai ieși NICIODATĂ, fără niciun semn.
	#
	# Amândouă trec prin TOATE fișierele, nu se iau de la capăt la fiecare.
	# `id_uri` mai ales: dacă o întrebare fabricată ar avea același `id` ca una
	# scrisă de mână, sacul le-ar crede una singură. Prefixele (`mana:`, `wd:`) fac
	# ciocnirea aproape imposibilă, dar verificarea nu se sprijină pe asta —
	# convențiile de nume se respectă până când cineva nu le mai respectă.
	var folosite := {}
	var id_uri := {}

	var cate_gasite := _incarca_fisier(CALE_INTREBARI, folosite, id_uri)
	if FOLOSESTE_WIKIDATA:
		for cale in fisierele_generate("_intrebari.json"):
			cate_gasite += _incarca_fisier(cale, folosite, id_uri)

	print("Trivia: %d intrebari incarcate (din %d gasite), %d neverificate." % [
		intrebari.size(), cate_gasite, neverificate
	])
	# UN RÂND, nu un avertisment pe întrebare. Cele 135 scrise înaintea câmpului
	# `subcategorie` îl vor primi într-un lot de clasificare; până atunci lipsa e o
	# muncă rămasă, nu o greșeală — iar 135 de avertismente ar îngropa consola și
	# ar face exact ce-i reproșez unui avertisment prost: să nu mai poată fi citit.
	if fara_subcategorie > 0:
		print("Trivia: %d intrebari fara subcategorie (de clasificat; vezi docs/plan-continut.md)."
			% fara_subcategorie)

	# Fapte pe care nu le cere nimeni. Nu strică nimic în joc, și exact de-aia
	# merită un avertisment: altfel e muncă de scris și de verificat care nu ajunge
	# niciodată la un jucător, iar la mii de fapte n-ai cum s-o mai găsești.
	#
	# Merge și peste faptele fabricate, dinadins: dacă stingi comutatorul
	# `FOLOSESTE_WIKIDATA`, nu se mai încarcă NIMIC din dosarul fabricat, deci nici
	# faptele lui nu rămân orfane. Cele două `if`-uri de mai sus trebuie să rămână
	# împreună — altfel verificarea asta ar țipa de câteva sute de ori.
	for id_fapt in fapte:
		if not folosite.has(id_fapt):
			push_warning("Trivia: faptul '%s' nu e folosit de nicio intrebare." % id_fapt)


## Fișierele din `DOSAR_GEN` care se termină cu sufixul dat, sortate pe nume.
##
## SORTATE, nu în ordinea de pe disc. Ordinea în care sistemul de fișiere
## enumeră un dosar nu e garantată, iar de la ea depinde ordinea din `intrebari`
## — deci și ce se întâmplă la o egalitate oriunde mai încolo. O ordine stabilă
## costă un `sort()` și scoate din joc o întreagă familie de „la mine merge".
##
## DOSARUL GOL E UN AVERTISMENT, NU O TĂCERE. Într-un joc EXPORTAT, fișierele
## care nu sunt resurse Godot ajung în pachet doar dacă presetul de export le
## prinde în filtrul lui (`*.json`). Dacă nu, `DirAccess` vede un dosar gol, iar
## jocul ar porni cu jumătate din conținut și fără niciun semn. De-aia lipsa e
## spusă, cu tot cu cauza probabilă: e genul de problemă care apare o singură
## dată, la primul export, și mănâncă o oră dacă nu ți-o spune nimeni.
static func fisierele_generate(sufix: String) -> Array[String]:
	var gasite: Array[String] = []
	var dosar := DirAccess.open(DOSAR_GEN)
	if dosar == null:
		push_warning("Trivia: nu pot deschide %s. Continui doar cu ce e scris de mana." % DOSAR_GEN)
		return gasite
	for nume in dosar.get_files():
		if nume.ends_with(sufix):
			gasite.append("%s/%s" % [DOSAR_GEN, nume])
	gasite.sort()
	if gasite.is_empty():
		push_warning(("Trivia: %s nu are niciun fisier '*%s'. Intr-un build exportat, " +
			"asta inseamna de obicei ca presetul de export nu include '*.json' in " +
			"filtrul de resurse ne-Godot.") % [DOSAR_GEN, sufix])
	return gasite


## Citește UN fișier de întrebări, validează fiecare intrare și adaugă cele bune
## în `intrebari`. Întoarce câte intrări s-au găsit în fișier (nu câte au trecut).
##
## Despărțită din `incarca_intrebari` când a apărut al doilea fișier. Argumentul
## care contează e că `folosite` și `id_uri` vin din AFARĂ: sunt registre comune
## celor două fișiere, nu ale unuia. Un al treilea fișier de conținut n-ar trebui
## să adauge cod aici, doar o linie sus — aceeași regulă ca la Obeliscuri.
static func _incarca_fisier(cale: String, folosite: Dictionary, id_uri: Dictionary) -> int:
	var brute := Puzzle.citeste_lista_json(cale, "Trivia")
	for i in range(brute.size()):
		var q = brute[i]
		if not _intrebare_valida(q, i, id_uri, cale):
			continue
		# ATENȚIE, capcană clasică: JSON nu are numere întregi, doar zecimale.
		# „corect": 2 ajunge în Godot ca 2.0 (float), iar un float nu poate
		# indexa un Array. Convertim o dată, aici, ca restul codului să
		# lucreze liniștit cu int-uri.
		q["corect"] = int(q["corect"])
		q["nivel"] = int(q["nivel"])
		id_uri[String(q["id"])] = "intrarea %d din %s" % [i, cale.get_file()]
		if q.get("fapt", "") != "":
			folosite[String(q["fapt"])] = true
		if String(q.get("subcategorie", "")) == "":
			fara_subcategorie += 1
		# `verificat` LIPSĂ ÎNSEAMNĂ `false`. Așa, fișierele fabricate nu trebuie
		# să poarte câte un „false” pe fiecare din cele 550 de întrebări: nimeni
		# nu citește de mână conținut generat, iar un câmp pus degeaba e un câmp
		# pe care-l ignori peste tot.
		if not bool(q.get("verificat", false)):
			neverificate += 1

		intrebari.append(q)
	return brute.size()


## Citește `fapte_trivia.json` în `fapte` (id → notă).
##
## Un fișier de fapte care lipsește NU e o eroare: întrebările merg mai departe
## fără note, exact ca înainte de sesiunea asta. De-aia întoarce în tăcere dacă
## `citeste_lista_json` n-a găsit nimic — funcția aia s-a plâns deja în consolă.
static func _incarca_fapte(cale: String) -> void:
	var brute := Puzzle.citeste_lista_json(cale, "Fapte")
	var fara_nota := 0
	var adaugate := 0
	for i in range(brute.size()):
		var f = brute[i]
		var unde := "faptul %d din %s" % [i, cale.get_file()]
		if not Puzzle.are_campurile(f, ["id", "nota"], "Fapte", unde):
			continue

		# Câmpuri necunoscute, ca la întrebări: un fapt n-are decât `nota`,
		# `etichete` și (la cele fabricate) `imagini`. Flagul de verificare nu mai
		# stă aici — stă pe întrebare, fiindcă acolo îl cauți.
		var necunoscute_f: Array[String] = []
		for cheie in f:
			if not CAMPURI_FAPT.has(String(cheie)):
				necunoscute_f.append(String(cheie))
		if not necunoscute_f.is_empty():
			necunoscute_f.sort()
			push_warning("Fapte: %s are cimpuri pe care nu le cunosc: %s. Il sarim." % [
				unde, ", ".join(necunoscute_f)
			])
			continue

		var id_fapt := String(f["id"])
		if id_fapt == "":
			push_warning("Fapte: %s are id gol." % unde)
			continue
		if fapte.has(id_fapt):
			push_warning("Fapte: id-ul '%s' apare de doua ori; a doua nota e ignorata." % id_fapt)
			continue

		var nota := String(f["nota"])
		if nota.length() > MAX_NOTA:
			# AVERTISMENT, nu refuz: nota rămâne întreagă și ajunge în joc. Limita
			# e de stil și e încă neverificată pe ecran, deci o notă bună nu se
			# pierde pentru ea — se rescurtează când o citești.
			push_warning("Fapte: nota faptului '%s' are %d caractere (maximum %d)." % [
				id_fapt, nota.length(), MAX_NOTA
			])

		# Notele goale se numără separat, fiindcă nu sunt o greșeală, sunt MUNCĂ
		# RĂMASĂ. Toate cele 70 de fapte fabricate pornesc așa. O notă goală nu
		# strică nimic: `explicatie` rămâne gol, exact ca la o întrebare fără fapt.
		if nota == "":
			fara_nota += 1
		fapte[id_fapt] = nota
		adaugate += 1

	if not brute.is_empty():
		print("Trivia: %s — %d fapte (din %d gasite), %d fara nota." % [
			cale.get_file(), adaugate, brute.size(), fara_nota
		])


## Verifică o singură intrare. Întoarce false și explică în consolă,
## în loc să lase o întrebare stricată să ajungă în luptă.
##
## `id_uri` e registrul întrebărilor acceptate până acum, ca să se poată prinde
## un `id` folosit de două ori.
static func _intrebare_valida(q, i: int, id_uri: Dictionary, cale := CALE_INTREBARI) -> bool:
	# Numele fișierului intră în fiecare mesaj de acum, fiindcă sunt două fișiere:
	# „intrarea 47" singură n-ar spune în care să te uiți, iar unul din ele nici
	# nu se editează de mână.
	var unde := "intrarea %d din %s" % [i, cale.get_file()]
	if not Puzzle.are_campurile(q, ["id", "text", "variante", "corect", "nivel", "categorie"], "Trivia", unde):
		return false

	# ─── CÂMPURI NECUNOSCUTE ───
	# Lista e închisă dinadins. Vezi `CAMPURI_INTREBARE`: un câmp scris greșit
	# („verifcat”) ar trece neobservat, iar întrebarea s-ar purta altfel decât
	# crezi. Refuzată, se vede în bilanț.
	var necunoscute: Array[String] = []
	for cheie in q:
		if not CAMPURI_INTREBARE.has(String(cheie)):
			necunoscute.append(String(cheie))
	if not necunoscute.is_empty():
		necunoscute.sort()
		push_warning("Trivia: %s are cimpuri pe care nu le cunosc: %s. O sarim." % [
			unde, ", ".join(necunoscute)
		])
		return false

	# ─── IDENTITATEA ───
	# De azi, `id` e câmp obligatoriu ca `text`, iar o întrebare fără el e SĂRITĂ.
	# Pare dur pentru un câmp care nu se vede pe ecran, dar el e cel prin care
	# sacul, save-ul și (mai târziu) istoricul din Practice recunosc întrebarea. O
	# întrebare fără `id` n-ar putea intra cinstit în niciunul din cele trei, iar
	# leacul e o singură comandă — de aia o spune chiar avertismentul.
	#
	# Pierderea se vede și în linia de bilanț de mai sus („134 incarcate din 135
	# gasite"), care e motivul pentru care sărirea nu e o dispariție tăcută.
	var id_intrebare := String(q["id"])
	if id_intrebare == "":
		push_warning("Trivia: %s are id gol. Ruleaza `python tools/da_iduri.py --scrie`." % unde)
		return false
	if id_uri.has(id_intrebare):
		push_warning("Trivia: %s are id-ul '%s', deja folosit de %s; o sarim." % [
			unde, id_intrebare, id_uri[id_intrebare]
		])
		return false

	# ─── LEGĂTURA CU FAPTUL ───
	# `fapt` e OPȚIONAL: o întrebare fără fapt apare fără notă, exact ca înainte.
	# Dar un `fapt` care arată spre un id inexistent e o scăpare de tastat, și
	# atunci nota lipsește în tăcere — nimic nu crapă, doar „Află mai multe" nu are
	# ce arăta. Întrebarea rămâne (e în continuare bună), legătura cade.
	if q.get("fapt", "") != "" and not fapte.has(String(q["fapt"])):
		push_warning("Trivia: %s trimite la faptul '%s', care nu exista in niciun fisier de fapte." % [
			unde, q["fapt"]
		])
		q.erase("fapt")

	if not (q["variante"] is Array) or q["variante"].size() != 4:
		push_warning("Trivia: %s nu are exact 4 variante." % unde)
		return false

	# Două variante identice ar face întrebarea ambiguă pe ecran ȘI ar strica
	# amestecarea (vezi `_amesteca`). Le prindem aici, unde costă un
	# avertisment în consolă, nu în luptă, unde ar costa un răspuns bun
	# marcat ca greșit.
	var distincte := {}
	for varianta in q["variante"]:
		distincte[String(varianta)] = true
	if distincte.size() != 4:
		push_warning("Trivia: %s are doua variante identice." % unde)
		return false

	var corect := int(q["corect"])
	if corect < 0 or corect > 3:
		push_warning("Trivia: %s are 'corect' = %d, in afara intervalului 0-3." % [unde, corect])
		return false

	var nivel := int(q["nivel"])
	if nivel < 1 or nivel > Puzzle.TIMP_PE_NIVEL.size():
		push_warning("Trivia: %s are nivelul %d, in afara intervalului 1-3." % [unde, nivel])
		return false

	var domeniu := String(q["categorie"])
	if not DOMENII.has(domeniu):
		push_warning("Trivia: %s are domeniul necunoscut '%s'." % [unde, domeniu])
		return false

	# ─── SUBCATEGORIA ───
	# OPȚIONALĂ, dar nu la liber: lipsa e numărată într-un rând de bilanț (cele 135
	# scrise înaintea câmpului), iar o cheie care EXISTĂ trebuie să fie una din
	# cele ale domeniului ei. Perechea contează, nu cheia singură: o întrebare de
	# istorie cu subcategoria `capitale` e la fel de stricată ca una cu o
	# subcategorie inventată, și în Practice ar fi un raft pe care nu-l deschide
	# nimeni niciodată.
	var subcategorie := String(q.get("subcategorie", ""))
	if subcategorie != "":
		var ale_domeniului: Dictionary = SUBCATEGORII.get(domeniu, {})
		if not ale_domeniului.has(subcategorie):
			push_warning("Trivia: %s are subcategoria '%s', care nu e a domeniului '%s'." % [
				unde, subcategorie, domeniu
			])
			return false

	return true

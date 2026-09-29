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
## Șase domenii (istorie, geografie, știință, artă, mitologie, literatură) pe
## trei niveluri. Nivelul e singura măsură a dificultății, iar înțelesul lui e
## ăsta, și trebuie păstrat când adaugi întrebări:
##
##   nivelul 1 — o știe orice adult, fără să fi studiat ceva anume
##   nivelul 2 — s-a predat la școală; îți amintești dacă ai fost atent
##   nivelul 3 — o știi doar dacă domeniul te-a interesat dincolo de școală
##
## ── ECHILIBRUL PE DOMENII STĂ ÎN ALEGERE, NU ÎN DATE ──────────
## Cele 135 de întrebări scrise de mână erau ținute în echilibru DINADINS
## (8/8/8/7/7/7 pe nivel), iar întrebarea se trăgea din tot nivelul. Mergea
## fiindcă fișierul era scris de om, deci echilibrul era o decizie.
##
## Cu întrebări FABRICATE nu mai merge: conținutul generat nu iese echilibrat și
## nu poate. Deci alegerea e acum în DOUĂ TREPTE — întâi domeniul, uniform între
## cele prezente la nivelul cerut, apoi întrebarea din el. Așa echilibrul nu mai
## depinde de cât de mare crește un domeniu. Motivul lung e în
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
# Există fiindcă conținutul fabricat poate să nu-mi placă. Azi sunt două relații
# („element ↔ simbol" în știință, „operă ↔ autor" în literatură), fiecare
# umplând ~85-90% din domeniul ei. În luptă asta înseamnă cam 2 din 7 întrebări
# fabricate. Dacă se simte prea mult, se stinge de aici, iar leacul adevărat nu
# e o treaptă de alegere în plus, e lățimea conținutului.
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

# Categoriile acceptate. Lista NU e decor: o categorie scrisă greșit în JSON
# („istoire") e prinsă la încărcare, cu un avertisment în consolă, în loc să
# ajungă în luptă ca antet fără sens.
#
# „literatura" s-a desprins din „arta" când baza a crescut la ~135 de
# întrebări. La 45, cărțile încăpeau lângă pictură și muzică; la 135, cine
# vrea să adauge întrebări nu mai știe unde să caute, iar echilibrul pe
# domenii nu se mai poate citi dintr-o privire. „mitologie" e nouă.
const CATEGORII := [
	"istorie", "geografie", "stiinta", "arta", "mitologie", "literatura",
]

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

## Faptele, ca `id` → notă. Un Dictionary, nu o listă, fiindcă singura întrebare
## pusă vreodată aici e „ce notă are faptul ăsta?" — o căutare pe cheie, de câteva
## ori pe rundă.
static var fapte := {}


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
		"categorie": String(q["categorie"]).to_upper(),
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
## verificarea din `tools/verifica_trivia.gd`, fără fereastră și fără scenă.
## Echilibrul pe domenii și sacul sunt exact lucrurile care NU se pot proba
## jucând — ca să vezi cu ochiul că știința nu ia 85% din întrebări, ar trebui să
## numeri câteva mii de lupte. Alternativa ar fi fost să rescrie verificarea
## alegerea asta la ea, și atunci ar fi probat copia, nu codul.
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎN DOUĂ TREPTE
##
## Până la conținutul fabricat, întrebarea se trăgea din TOT nivelul, iar
## echilibrul pe domenii era ținut de mână în fișier (8/8/8/7/7/7 pe nivel).
## Mergea fiindcă fișierul era scris de om, deci echilibrul era o decizie.
##
## Conținutul generat nu iese echilibrat și nu POATE ieși: Wikidata e bogată în
## geografie, științe și date, și săracă în mitologie românească. Cele 139 de
## întrebări despre elemente intră toate în știință, iar dacă alegerea ar rămâne
## „trage din tot nivelul", știința ar lua 85% din întrebări și „Cultură
## generală" ar deveni, în practică, „Chimie, cu accidente" — adică ai antrena un
## singur colț de minte.
##
## Deci echilibrul se mută din date în ALEGERE, unde nu mai depinde de cât de
## mare crește un domeniu. Aceeași formă ca la Logică, unde se alege întâi
## categoria de regulă și abia apoi șirul: acolo alegerea în două trepte e chiar
## ce împiedică „Fibonacci" să apară cât toate celelalte la un loc.
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

	# `keys()` nu promite nicio ordine anume, dar nici nu ne trebuie. Ce ne trebuie
	# e ca fiecare domeniu PREZENT să aibă șansa 1/N, indiferent câte întrebări
	# are — și asta o dă `pick_random` peste lista de CHEI, nu peste întrebări.
	var domenii: Array = pe_domenii.keys()
	var domeniu_ales: String = String(domenii.pick_random())
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

	print("Trivia: %d intrebari incarcate (din %d gasite)." % [intrebari.size(), cate_gasite])

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
		intrebari.append(q)
	return brute.size()


## Citește `fapte_trivia.json` în `fapte` (id → notă).
##
## Un fișier de fapte care lipsește NU e o eroare: întrebările merg mai departe
## fără note, exact ca înainte de sesiunea asta. De-aia întoarce în tăcere dacă
## `citeste_lista_json` n-a găsit nimic — funcția aia s-a plâns deja în consolă.
static func _incarca_fapte(cale: String) -> void:
	var brute := Puzzle.citeste_lista_json(cale, "Fapte")
	var neverificate := 0
	var fara_nota := 0
	var adaugate := 0
	for i in range(brute.size()):
		var f = brute[i]
		var unde := "faptul %d din %s" % [i, cale.get_file()]
		if not Puzzle.are_campurile(f, ["id", "nota"], "Fapte", unde):
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

		if not bool(f.get("verificat", false)):
			neverificate += 1
		# Notele goale se numără separat, fiindcă nu sunt o greșeală, sunt MUNCĂ
		# RĂMASĂ. Toate cele 70 de fapte fabricate pornesc așa. O notă goală nu
		# strică nimic: `explicatie` rămâne gol, exact ca la o întrebare fără fapt.
		if nota == "":
			fara_nota += 1
		fapte[id_fapt] = nota
		adaugate += 1

	if not brute.is_empty():
		print("Trivia: %s — %d fapte (din %d gasite), %d neverificate, %d fara nota." % [
			cale.get_file(), adaugate, brute.size(), neverificate, fara_nota
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

	if not (q["categorie"] in CATEGORII):
		push_warning("Trivia: %s are categoria necunoscuta '%s'." % [unde, q["categorie"]])
		return false

	return true

extends Node
## SACUL — memoria a ce s-a pus deja pe masă în expediția curentă.
##
## E un „autoload" (Project → Project Settings → Autoload), ca `Tezaur`:
## pornește o dată, înaintea oricărei scene, și rămâne în picioare până
## închizi jocul. Aici asta e chiar motivul pentru care există fișierul.
## O expediție înseamnă mai multe lupte, iar între două lupte scena se
## schimbă — tot ce ar ține minte `trivia.gd` despre ce a întrebat ar
## dispărea exact atunci când ai nevoie de el.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU E DE-AJUNS `pick_random()`
##
## Alegerea pur aleatoare n-are memorie. Cu 45 de întrebări pe nivel, șansa
## ca a doua întrebare s-o repete pe prima e 1 din 45 — mică. Dar nu tragi
## două întrebări pe expediție, tragi zeci. Iar șansa ca ÎN 20 de trageri
## să apară măcar o repetare e de aproape 99%. (E „paradoxul zilelor de
## naștere": 23 de oameni într-o cameră și e deja mai probabil decât nu ca
## doi să aibă aceeași zi.)
##
## Și o repetare nu e doar plictisitoare: e o întrebare GRATIS. Un joc de
## antrenament mental care-ți dă un punct pentru că ții minte ce-ai apăsat
## acum două minute se sabotează singur.
##
## ─────────────────────────────────────────────────────────────
## CUM FUNCȚIONEAZĂ: SACUL DE BILETE
##
## Numele nu e poetic, e chiar mecanismul. Imaginează-ți toate întrebările
## scrise pe bilete, într-un sac. Tragi un bilet, îl citești și îl pui
## DEOPARTE, nu înapoi. Următoarea tragere alege dintre cele rămase, deci
## nu poate repeta. Când sacul se golește, biletele se întorc toate înăuntru
## și începe un ciclu nou.
##
## Rezultatul: nicio repetare cât timp mai există întrebări nevăzute, și
## distanța maximă posibilă între două apariții ale aceleiași întrebări.
## În engleză, tiparul se cheamă „shuffle bag" — îl folosesc jocurile
## pentru exact problema asta (piesele din Tetris vin la fel).
##
## SINGURA SUBTILITATE e la răscrucea dintre cicluri: dacă ultimul bilet
## din ciclul vechi ar putea fi primul din cel nou, ai vedea aceeași
## întrebare de două ori LA RÂND — fix cazul care se simte cel mai prost.
## De aceea sacul ține minte ultima extragere și o exclude din prima
## tragere a ciclului nou.
##
## ─────────────────────────────────────────────────────────────
## DE CE E GENERIC, ȘI NU „sacul de trivia"
##
## Nimic de mai jos nu știe ce e o întrebare. Primește o listă (sau un text)
## și întoarce un răspuns. O disciplină nouă nu adaugă cod aici — adaugă o
## CHEIE. Aceeași regulă ca la Obeliscuri și la resurse: datele într-un
## tabel, codul citește tabelul.
##
## ────────────────────────────────────────────────────────────
## DOUĂ FORME, FIINDCĂ SUNT DOUĂ FELURI DE DISCIPLINĂ
##
##   `extrage()` — pentru cine ALEGE dintr-o listă finită (Trivia, cu cele
##                 135 de întrebări din fișier). E o GARANȚIE: nu poți vedea
##                 de două ori aceeași întrebare cât timp mai există una
##                 nevăzută.
##
##   `retine()`  — pentru cine FABRICĂ întrebări (Logica, Cuvinte). Nu se
##                 poate garanta nimic, fiindcă lista nu există ca să fie
##                 golită; se ține un registru și se cere altă întrebare când
##                 iese una văzută. Vezi nota dinaintea funcției.
##
## Amândouă scriu în aceleași sertare, deci `expeditie_noua()` și save-ul
## nu trebuie să știe care disciplină folosește care formă.
##
## ────────────────────────────────────────────────────────────
## CÂT TRĂIEȘTE UN SAC: `Durata`, DECLARATĂ DE APELANT
##
## Nu toate sacurile au aceeași durată de viață, și diferența nu e o chestiune
## de gust:
##
##   Sacul de LUPTĂ al unui domeniu („cultura_generala:geografie:2") trebuie să
##   se golească la fiecare expediție nouă. Altfel, după zece runuri, lupta ar
##   trage din ce-a rămas pe fundul sacului — iar la un joc de învățare
##   repetarea LA DISTANȚĂ e exact ce vrei, nu ce eviți.
##
##   Sacul unui RAFT din Practice („practice:geografie:capitale:2") trebuie să
##   supraviețuiască expedițiilor. Exersezi un raft dimineața, pornești o
##   expediție la prânz, te întorci la raft seara: dacă memoria s-a șters,
##   garanția „fără repetiții" a dispărut fără ca nimeni să fi cerut asta.
##
## CINE DECIDE. Nu sacul: `sac.gd` nu știe, și n-are voie să știe, ce e
## „practice" sau ce e un domeniu — toată valoarea lui vine din faptul că nu
## știe ce e un bilet. Deci durata o DECLARĂ apelantul, la folosire:
##
##     Sac.extrage(cheie, pool, "id")                        ← pe expediție
##     Sac.extrage(cheie, pool, "id", Sac.Durata.PERMANENT)  ← rămâne
##
## Iar cunoștința aia stă exact acolo unde trebuie: `trivia.gd` e singurul
## fișier care știe că un raft din Practice nu e o luptă.
##
## CE SE VEDE DIN AFARĂ. `expeditie_noua()` golește numai sacurile de
## expediție. Pentru „șterge tot" (joc nou, unelte de verificare) e
## `goleste_tot()`. Iar la salvare, durata nu se scrie în fișier: FIȘIERUL e
## cel care o spune — tot ce stă în save-ul permanent e, prin definiție,
## permanent. Vezi `spre_dictionar()`.


## Cât trăiește un sac. Pe disc nu ajunge niciodată ca număr (vezi nota de sus),
## deci ordinea din listă nu e o capcană aici — dar `enum`, nu `bool`, fiindcă
## „durată" are nume, iar `true` n-ar spune care dintre cele două.
enum Durata {
	EXPEDITIE,   ## se golește la fiecare expediție nouă
	PERMANENT,   ## trece în save-ul permanent și supraviețuiește runurilor
}

## Ce s-a tras deja, în ciclul curent: „cheia sacului" → listă de identități.
## O identitate e un text — vezi `_identitate()` mai jos pentru de ce un text
## și nu un număr. Underscore = privat: nimeni din afară nu scrie direct aici.
var _extrase := {}

## Ultima identitate trasă din fiecare sac. Există doar pentru regula de la
## răscrucea dintre cicluri, explicată sus.
var _ultima := {}

## Durata fiecărui sac: cheie → `Durata`. Se scrie la fiecare folosire a cheii,
## nu doar la prima: o atribuire în plus e mai ieftină decât un `if` care
## întreabă dacă cheia e deja cunoscută, și amândouă pun aceeași valoare.
##
## O cheie care nu e aici e de expediție. Asta e valoarea implicită DINADINS:
## un sac nou, scris de cineva care n-a citit nota de sus, se va goli prea des
## — adică va repeta o întrebare. Invers, un sac rămas permanent din neatenție
## ar opri repetarea pe veci, și aia nu se vede ca un bug, se vede ca o bază de
## întrebări care s-a terminat.
var _durata := {}


# ─────────────────────────────────────────────────────────────
# PRIMA FORMĂ: SACUL PROPRIU-ZIS
# Pentru disciplinele care ALEG dintr-o listă finită, scrisă într-un fișier.
# ─────────────────────────────────────────────────────────────

## Trage un element din `elemente` care n-a mai ieșit în ciclul curent.
##
##   `cheie`    — ce sac. Sacurile sunt complet separate între ele, deci
##                cheia trebuie să cuprindă TOT ce face lista să fie alta:
##                disciplina ȘI nivelul. „cultura_generala:2" e un sac,
##                „cultura_generala:3" e alt sac. Dacă ai folosi aceeași
##                cheie pentru două liste diferite, sacul ar crede că a
##                văzut bilete care nici nu existau.
##
##   `camp_id`  — numele câmpului care identifică un element, când elementele
##                sunt dicționare (pentru întrebări: „text"). Lăsat gol,
##                elementul însuși devine identitatea lui — bun pentru
##                liste de șiruri simple.
##
##   `durata`   — cât trăiește sacul ăsta. Vezi `Durata` în antet. Implicit „pe
##                expediție", fiindcă aia e regula pentru lupte.
##
## Întoarce `null` dacă lista e goală: apelantul decide ce înseamnă asta
## (la Trivia, ecranul de eroare).
func extrage(cheie: String, elemente: Array, camp_id := "",
		durata := Durata.EXPEDITIE) -> Variant:
	if elemente.is_empty():
		return null

	_durata[cheie] = durata

	# `Array.has()` peste o listă de câteva zeci de elemente e ieftin, iar o
	# listă simplă se salvează pe disc fără nicio conversie. Cu mii de
	# elemente ar merita un Dictionary folosit ca mulțime; cu 45, nu.
	var vazute: Array = _extrase.get(cheie, [])

	# Biletele rămase în sac: tot ce n-a ieșit încă.
	var ramase := elemente.filter(
		func(e): return not vazute.has(_identitate(e, camp_id))
	)

	# Sacul s-a golit → ciclu nou. Biletele se întorc toate înăuntru, mai
	# puțin ultimul tras: altfel aceeași întrebare ar putea veni de două ori
	# la rând, peste granița dintre cicluri.
	if ramase.is_empty():
		vazute = []
		var ultima_id: String = _ultima.get(cheie, "")
		ramase = elemente.filter(
			func(e): return _identitate(e, camp_id) != ultima_id
		)
		# Plasă de siguranță: dacă lista are UN singur element, filtrul de
		# mai sus o golește. Atunci regula „nu de două ori la rând" pur și
		# simplu nu se poate respecta, și e mai bine s-o încalci decât să
		# întorci `null`.
		if ramase.is_empty():
			ramase = elemente

	var ales = ramase.pick_random()
	var id := _identitate(ales, camp_id)
	vazute.append(id)
	_extrase[cheie] = vazute
	_ultima[cheie] = id
	return ales


# ────────────────────────────────────────────────────────────
# CEALALTĂ FORMĂ: REGISTRUL
#
# `extrage()` de mai sus cere un lucru pe care nu orice disciplină îl poate
# da: LISTA ÎNTREAGĂ din care alege. Trivia o are — 135 de întrebări scrise
# într-un fișier. Logica și Cuvintele nu: ele nu ALEG întrebări, ele le
# FABRICĂ. „Șirul care adună 4, pornind de la 7" nu e o intrare într-un
# tabel, e un rezultat care nu există până nu-l ceri. Mulțimea tuturor
# întrebărilor posibile e uriașă și nu se poate scrie pe bilete.
#
# Deci sacul nu se aplică, și rămâne singurul lucru care se poate face: le
# lași să fabrice, iar dacă iese ceva ce s-a mai văzut, ceri alta. Nu mai e
# o garanție, e o reîncercare — dar cu zeci de mii de întrebări posibile și
# câteva zeci văzute, prima reîncercare reușește aproape întotdeauna.
#
# Registrul folosește ACELEAȘI sertare ca sacul (`_extrase`), deci „expediție
# nouă" golește și una, și alta, iar save-ul le ia pe amândouă dintr-un foc.
# ────────────────────────────────────────────────────────────

## „Am mai văzut asta?" Și, dacă nu, o trece în registru.
##
## Întoarce `true` dacă identitatea e NOUĂ (și atunci o reține), `false` dacă
## a mai apărut în expediția curentă. Cele două treburi stau într-o singură
## funcție dinadins: despărțite în „verifică" și „reține", ar exista un loc
## în care se poate uita a doua, iar bug-ul ăla nu se vede decât ca „parcă
## se repetă ceva, uneori".
func retine(cheie: String, identitate: String, durata := Durata.EXPEDITIE) -> bool:
	_durata[cheie] = durata
	var vazute: Array = _extrase.get(cheie, [])
	if vazute.has(identitate):
		return false
	vazute.append(identitate)
	_extrase[cheie] = vazute
	_ultima[cheie] = identitate
	return true


## Ciclu nou pentru UN singur sac: tot ce s-a văzut se uită.
##
## Chemată când reîncercările nu mai găsesc nimic nou — semn că fântâna a
## secat pentru combinația asta de disciplină și nivel. Alternativa ar fi să
## refuzi întrebarea, iar asta ar opri lupta. O repetare e un preț mult mai
## mic decât un Obelisc care nu mai răspunde.
func recicleaza(cheie: String) -> void:
	_extrase[cheie] = []


## Expediție nouă: sacurile DE EXPEDIȚIE redevin pline, cele permanente nu se
## ating. O cheamă `Expeditie.incepe()`.
##
## Până la Save golea tot, fiindcă tot era de expediție. Despărțirea a venit
## odată cu Practice: o expediție pornită între două sesiuni de antrenament
## ștergea garanția „fără repetiții" de pe rafturi — scris la „Rămas deschis"
## în sesiunea MENIUL ȘI PRACTICE, reparat la Save.
##
## Se umblă pe o COPIE a cheilor (`_extrase.keys()` întoarce un Array nou), nu
## direct pe dicționar: ștergi din ce parcurgi și ai o buclă care sare intrări.
func expeditie_noua() -> void:
	for cheie in _extrase.keys():
		if int(_durata.get(cheie, Durata.EXPEDITIE)) == Durata.EXPEDITIE:
			_extrase.erase(cheie)
			_ultima.erase(cheie)
			_durata.erase(cheie)


## Șterge TOT, inclusiv sacurile permanente.
##
## Două apelante, amândouă din afara jocului jucat: un „joc nou" care aruncă
## progresul, și uneltele din `tools/verificari/`. O verificare pleacă mereu de
## la zero — de-aia acolo se cheamă asta, nu `expeditie_noua()`, deși până la
## Save cele două făceau exact același lucru.
func goleste_tot() -> void:
	_extrase.clear()
	_ultima.clear()
	_durata.clear()


# ─────────────────────────────────────────────────────────────
# IDENTITATEA UNUI ELEMENT
# ─────────────────────────────────────────────────────────────

## Ce anume ține sacul minte despre un bilet.
##
## DE CE UN TEXT, ȘI NU POZIȚIA ÎN LISTĂ. Poziția pare mai ieftină, dar e
## legată de ordinea din fișier. Adaugi mâine o întrebare la mijlocul
## `intrebari_trivia.json` și toate pozițiile de după se mută cu unu — iar
## un save vechi ar crede că a văzut cu totul alte întrebări. E aceeași
## decizie ca la `Tezaur`, unde resursele se salvează pe chei text, nu pe
## numere din `enum`.
##
## CE text, asta alege apelantul, prin `camp_id`. Trivia dă „id" (`mana:0001`),
## un câmp care nu înseamnă nimic pentru jucător și de-aia nu se schimbă
## niciodată. Până la sesiunea id-urilor dădea „text", care se schimbă la
## fiecare reformulare — adică o întrebare rescrisă părea nevăzută, deci
## gratis. Un identificator bun e unul pe care n-ai niciun motiv să-l atingi.
func _identitate(element, camp_id: String) -> String:
	if camp_id != "" and element is Dictionary and element.has(camp_id):
		return String(element[camp_id])
	return str(element)


# ─────────────────────────────────────────────────────────────
# SALVARE
# Scrise de pe acum, din același motiv ca la `Tezaur`: formatul e mai ușor
# de ales azi, cu un singur fel de sac, decât peste trei luni cu șase.
#
# SACUL SE SALVEAZĂ ÎN DOUĂ FIȘIERE, și de-aia funcțiile cer o `durata`:
# sacurile de expediție intră în save-ul expediției, cele permanente în
# progresul permanent. Închizi jocul la jumătatea unei expediții și revii:
# întrebările deja văzute rămân văzute, din amândouă felurile de sac.
#
# DURATA NU SE SCRIE ÎN FIȘIER, și merită spus de ce, fiindcă e tentant s-o
# scrii „ca să fie". FIȘIERUL e cel care o spune: tot ce stă în save-ul
# permanent e permanent, prin definiție. Un câmp în plus ar fi un al doilea loc
# care susține același lucru — adică un loc care se poate contrazice cu primul.
# Aceeași regulă ca la ecranul din Practice, care nu-și ține minte ce ecran e.
# ─────────────────────────────────────────────────────────────

## Sacurile de o durată anume, ca Dictionary cu chei text — exact forma pe care
## `JSON.stringify()` o înghite fără nicio conversie.
func spre_dictionar(durata := Durata.EXPEDITIE) -> Dictionary:
	var extrase := {}
	var ultima := {}
	for cheie in _extrase:
		if int(_durata.get(cheie, Durata.EXPEDITIE)) != durata:
			continue
		extrase[cheie] = (_extrase[cheie] as Array).duplicate()
		if _ultima.has(cheie):
			ultima[cheie] = _ultima[cheie]
	return {"extrase": extrase, "ultima": ultima}


## Drumul invers, pentru o durată. Sacurile de durata ASTA se golesc întâi, deci
## un save căruia îi lipsește un sac nu lasă în urmă bilete fantomă din rularea
## curentă; celelalte nu se ating, fiindcă cele două fișiere se citesc unul după
## altul și al doilea n-are voie să șteargă ce-a adus primul.
func din_dictionar(date: Dictionary, durata := Durata.EXPEDITIE) -> void:
	for cheie in _extrase.keys():
		if int(_durata.get(cheie, Durata.EXPEDITIE)) == durata:
			_extrase.erase(cheie)
			_ultima.erase(cheie)
			_durata.erase(cheie)

	var extrase = date.get("extrase")
	if extrase is Dictionary:
		for cheie in extrase:
			# Tot ce vine dintr-un fișier trece prin filtrul ăsta: o cheie a
			# cărei valoare nu e o listă e sărită, nu crapă încărcarea. Un save
			# vechi trebuie să se deschidă chiar și strâmb.
			if not (extrase[cheie] is Array):
				continue
			var identitati: Array = []
			for id in extrase[cheie]:
				identitati.append(String(id))
			_extrase[String(cheie)] = identitati
			_durata[String(cheie)] = durata

	var ultima = date.get("ultima")
	if ultima is Dictionary:
		for cheie in ultima:
			# Numai pentru sacurile care au ajuns înăuntru: un „ultima" fără
			# „extrase" ar fi o cheie cunoscută pe jumătate, iar `expeditie_noua`
			# n-ar avea ce să golească din ea.
			if _extrase.has(String(cheie)):
				_ultima[String(cheie)] = String(ultima[cheie])

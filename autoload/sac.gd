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


## Ce s-a tras deja, în ciclul curent: „cheia sacului" → listă de identități.
## O identitate e un text — vezi `_identitate()` mai jos pentru de ce un text
## și nu un număr. Underscore = privat: nimeni din afară nu scrie direct aici.
var _extrase := {}

## Ultima identitate trasă din fiecare sac. Există doar pentru regula de la
## răscrucea dintre cicluri, explicată sus.
var _ultima := {}


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
## Întoarce `null` dacă lista e goală: apelantul decide ce înseamnă asta
## (la Trivia, ecranul de eroare).
func extrage(cheie: String, elemente: Array, camp_id := "") -> Variant:
	if elemente.is_empty():
		return null

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
func retine(cheie: String, identitate: String) -> bool:
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


## Golește toate sacurile: expediție nouă, toate întrebările redevin noi.
##
## NU O CHEAMĂ ÎNCĂ NIMENI, și e în regulă. Harta de expediție (pasul 6 din
## ruta de construcție) e locul ei firesc: acolo se naște noțiunea de
## „expediție nouă". Până atunci, o expediție ține cât o rulare a jocului,
## fiindcă autoload-ul pornește gol — ceea ce înseamnă că întrebările nu se
## repetă nici măcar între două lupte consecutive, exact ce vrei.
func expeditie_noua() -> void:
	_extrase.clear()
	_ultima.clear()


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
# Ce se salvează e memoria unei EXPEDIȚII, deci intră în save-ul unei
# expediții în desfășurare — nu în progresul permanent. Dacă închizi jocul
# la jumătatea unei expediții și revii, întrebările deja văzute rămân văzute.
# ─────────────────────────────────────────────────────────────

## Starea ca Dictionary cu chei text — exact forma pe care
## `JSON.stringify()` o înghite fără nicio conversie.
func spre_dictionar() -> Dictionary:
	return {
		"extrase": _extrase.duplicate(true),
		"ultima": _ultima.duplicate(true),
	}


## Drumul invers. Pornim de la gol, deci un save vechi, căruia îi lipsește
## un sac, nu lasă în urmă bilete fantomă din rularea curentă.
func din_dictionar(date: Dictionary) -> void:
	expeditie_noua()
	if date.get("extrase") is Dictionary:
		_extrase = (date["extrase"] as Dictionary).duplicate(true)
	if date.get("ultima") is Dictionary:
		_ultima = (date["ultima"] as Dictionary).duplicate(true)

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
## Nimic de mai jos nu știe ce e o întrebare. Primește o listă și întoarce
## un element din ea. Asta înseamnă că a doua disciplină care are nevoie de
## „fără repetiții" (Cuvinte are un fișier finit, la fel Logica pentru
## categorii) nu adaugă cod aici — adaugă o CHEIE. Aceeași regulă ca la
## Obeliscuri și la resurse: datele într-un tabel, codul citește tabelul.


## Ce s-a tras deja, în ciclul curent: „cheia sacului" → listă de identități.
## O identitate e un text — vezi `_identitate()` mai jos pentru de ce un text
## și nu un număr. Underscore = privat: nimeni din afară nu scrie direct aici.
var _extrase := {}

## Ultima identitate trasă din fiecare sac. Există doar pentru regula de la
## răscrucea dintre cicluri, explicată sus.
var _ultima := {}


# ─────────────────────────────────────────────────────────────
# SINGURA FUNCȚIE PE CARE O CHEAMĂ O DISCIPLINĂ
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
## un save vechi ar crede că a văzut cu totul alte întrebări. Textul
## întrebării nu se mută niciodată. E aceeași decizie ca la `Tezaur`, unde
## resursele se salvează pe chei text, nu pe numere din `enum`.
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

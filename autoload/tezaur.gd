extends Node
## TEZAURUL — tot ce ai adunat, în afara unei lupte.
##
## E un „autoload" (Project → Project Settings → Autoload), ca `Muzica`,
## `Sunet` și `Fereastra`: pornește o dată, înaintea oricărei scene, și rămâne
## în picioare până închizi jocul. Aici asta e chiar motivul pentru care există
## fișierul: resursele NU aparțin unei lupte. Dacă le-am ține în `lupta.gd`,
## ar dispărea în clipa în care scena se schimbă — adică fix atunci când ai
## nevoie de ele (harta de expediție, cetatea, magazinul).
##
## ─────────────────────────────────────────────────────────────
## DE CE E UN DICȚIONAR, ȘI NU `var fragmente := 0`
##
## O variabilă per resursă pare mai simplă — până la a doua resursă. Atunci ai
## nevoie de a doua funcție de adăugat, de al doilea rând în fiecare panou, de
## a doua ramură în save. Cu un dicționar „resursă → cantitate", a doua resursă
## e un RÂND în `DATE_RESURSA` de mai jos și nimic altceva: totalurile, panoul
## de verdict și salvarea merg pe orice număr de intrări.
##
## E aceeași regulă ca la Obeliscuri și la arhetipuri: datele într-un tabel,
## codul citește tabelul. „Proiectează pentru 8, construiește 1."
##
## ─────────────────────────────────────────────────────────────
## DE CE E DEJA SERIALIZABIL, DEȘI SAVE-UL VINE ABIA LA PASUL 8
##
## `spre_dictionar()` / `din_dictionar()` există de pe acum pentru că formatul
## de salvare e mai ușor de ales ACUM, când tezaurul are o resursă, decât peste
## trei luni, când are șase și jumătate din ele sunt scrise în cod cu numele
## lor. Mai jos vezi singura decizie reală: pe disc salvăm CHEI TEXT
## („fragmente"), nu numerele din `enum`.
##
## Motivul: valoarea unui `enum` e doar poziția lui în listă. Dacă mâine adaugi
## o resursă între cele existente, numerele se mută — iar un save vechi ar citi
## fragmentele ca fiind altceva. Un text nu se mută niciodată.


## Resursele jocului. `enum` = o listă de nume pentru niște numere: scrii
## `Tezaur.Resursa.FRAGMENTE`, nu `0`, deci nu poți greși cifra și editorul
## îți completează numele.
enum Resursa {
	FRAGMENTE,   ## rămășițe de gând, moneda de bază a expedițiilor
}

## FIȘA fiecărei resurse. Deliberat un tabel, nu constante separate: panoul de
## verdict citește de aici numele afișat, deci o resursă nouă nu cere niciun
## cod nou de afișare.
##
## „cheie" e numele ei pe disc (vezi nota de sus). „nume" e ce se vede în joc —
## fără diacritice, ca tot textul din interfață.
const DATE_RESURSA := {
	Resursa.FRAGMENTE: {
		"cheie": "fragmente",
		"nume": "Fragmente",
		"descriere": "Cioburi de gand limpede, ramase dupa ce un Sters se destrama.",
	},
}


## Emis de fiecare dată când o cantitate se schimbă.
## Nimeni nu ascultă încă; e cârligul pentru bara de resurse din cetate, ca ea
## să nu fie nevoită să întrebe tezaurul în fiecare cadru „s-a schimbat ceva?".
signal s_a_schimbat(resursa: Resursa, cantitate_noua: int)


## Starea propriu-zisă: „resursă → cât ai". Underscore-ul din față e o
## convenție GDScript pentru „privat": nimeni din afară nu scrie direct în el,
## ci trece prin `adauga()` / `plateste()`. Așa semnalul se emite MEREU, iar o
## viitoare bară de resurse nu poate rămâne în urmă.
var _cantitati := {}


func _ready() -> void:
	goleste()


## Pune toate resursele pe zero. Folosită la pornire și, mai târziu, când începi
## un joc nou. Pleacă de la `DATE_RESURSA`, deci nu poate „uita" o resursă.
func goleste() -> void:
	_cantitati.clear()
	for resursa in DATE_RESURSA:
		_cantitati[resursa] = 0


## Cât ai dintr-o resursă.
## `.get(cheie, implicit)` întoarce valoarea implicită dacă cheia lipsește —
## mai sigur decât `_cantitati[resursa]`, care ar crăpa pe o cheie necunoscută.
func cat(resursa: Resursa) -> int:
	return int(_cantitati.get(resursa, 0))


## Numele de afișat. Trece prin tabel ca panourile să nu scrie „Fragmente"
## cu mâna — altfel o redenumire ar însemna un drum prin tot proiectul.
## (Numele e provizoriu, deci drumul ăla chiar se poate întâmpla.)
func nume(resursa: Resursa) -> String:
	return DATE_RESURSA[resursa]["nume"]


## Adaugă (sau scade, cu un număr negativ). Nu coboară niciodată sub zero.
func adauga(resursa: Resursa, cantitate: int) -> void:
	if cantitate == 0:
		return
	_cantitati[resursa] = maxi(cat(resursa) + cantitate, 0)
	s_a_schimbat.emit(resursa, _cantitati[resursa])


## Plata: scade DOAR dacă ai destul, și spune dacă a reușit.
## Întoarce `bool` ca apelantul să poată scrie `if Tezaur.plateste(...)`, în loc
## să verifice el suma și apoi s-o scadă — două locuri în care s-ar putea
## strecura o neconcordanță. Încă n-o folosește nimeni; e pentru cetate.
func plateste(resursa: Resursa, cost: int) -> bool:
	if cost <= 0:
		return true
	if cat(resursa) < cost:
		return false
	adauga(resursa, -cost)
	return true


# ─────────────────────────────────────────────────────────────
# SALVARE
# Două funcții, una oglinda celeilalte. Amândouă trec prin „cheie", nu prin
# numărul din enum — vezi nota de la începutul fișierului.
# ─────────────────────────────────────────────────────────────

## Starea tezaurului ca Dictionary cu chei text: { "fragmente": 28 }.
## Exact forma pe care `JSON.stringify()` o înghite fără nicio conversie.
func spre_dictionar() -> Dictionary:
	var date := {}
	for resursa in DATE_RESURSA:
		date[DATE_RESURSA[resursa]["cheie"]] = cat(resursa)
	return date


## Drumul invers: un dicționar citit din save devine starea de acum.
##
## Pornim de la `goleste()`, deci o resursă care NU e în save rămâne pe zero —
## exact ce vrei când un save vechi întâlnește o versiune nouă a jocului.
## Iar o cheie necunoscută (o resursă ștearsă între timp) e IGNORATĂ în loc să
## oprească încărcarea: un save vechi trebuie să se deschidă chiar și strâmb.
func din_dictionar(date: Dictionary) -> void:
	goleste()
	for resursa in DATE_RESURSA:
		var cheie: String = DATE_RESURSA[resursa]["cheie"]
		if date.has(cheie):
			# `int(...)` pentru că JSON întoarce toate numerele ca float.
			_cantitati[resursa] = maxi(int(date[cheie]), 0)
			s_a_schimbat.emit(resursa, _cantitati[resursa])

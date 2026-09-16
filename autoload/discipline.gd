extends Node
## CATALOGUL DISCIPLINELOR — toate cele pe care le poți învăța, într-un tabel.
##
## Până acum, tabelul ăsta se numea `OBELISCURI` și trăia în `lupta.gd`. Mutarea
## lui aici e prima jumătate din pasul 1 al rutei de construcție („disciplinele
## devin date, nu enum fix"), și a devenit necesară în clipa în care a apărut
## harta de expediție: **ecranul de loadout trebuie să știe ce discipline
## există, iar el nu e o luptă.** Un tabel de care are nevoie și lupta, și
## harta, nu mai poate sta în niciuna din ele.
##
## ─────────────────────────────────────────────────────────────
## „ALEGE N DIN M" — DE CE NU SCRIE NICĂIERI 3, ȘI NICI 8
##
## Azi M e 3 și N e 3, deci loadout-ul e „le iei pe toate" și pare că n-are
## rost. Are: singurul moment în care poți scrie corect regula e ACUM, cât
## e banală. Peste câteva luni, cu M = 8, un „3" scris în cinci locuri ar
## însemna cinci locuri de găsit, iar al șaselea, uitat.
##
## Deci:
##   M = `CATALOG.size()`             — câte discipline există
##   N = `Expeditie.DISCIPLINE_IN_LOADOUT` — câte iei într-o expediție
##
## Nicăieri altundeva. Ecranul de loadout desenează M rânduri și numără până la
## N; lupta construiește exact atâtea Obeliscuri câte are loadout-ul. Când apare
## a patra disciplină, ea e un RÂND în tabelul de mai jos și nimic altceva.
##
## ─────────────────────────────────────────────────────────────
## CÂMPURILE
##
##   „cheie"      — numele ei pe disc și în legături. Un TEXT, nu poziția în
##                  listă: poziția se mută când adaugi o disciplină la mijloc,
##                  iar un save vechi ar încărca atunci cu totul altceva.
##                  Aceeași decizie ca la `Tezaur` și la `Sac`.
##   „nume"       — ce se vede în joc. Se poate schimba fără să strice nimic,
##                  tocmai fiindcă legăturile merg pe „cheie".
##   „rol"        — o frază despre ce antrenează. Apare în ecranul de loadout:
##                  o alegere pe care o faci pe nume, fără să știi ce e
##                  înăuntru, nu e o alegere.
##   „piesa"      — piesa de șah desenată pe buton (`glifa_sah.gd`)
##   „imagine"    — PNG-ul, dacă există. Lipsă = se desenează „piesa".
##   „culoare"    — identitatea vizuală: bordura, numele, halo-ul, piesa
##   „scena"      — disciplina propriu-zisă. Toate respectă același contract
##                  (`porneste`, `arata_stare`, semnalul `rezolvat`), deci
##                  lupta le tratează la fel și nu știe ce e înăuntru.

const SCENA_TRIVIA := preload("res://scenes/trivia/trivia.tscn")
const SCENA_LOGICA := preload("res://scenes/logica/logica.tscn")
const SCENA_CUVINTE := preload("res://scenes/cuvinte/cuvinte.tscn")

## CULORILE. Fiecare e folosită în patru locuri de pe butonul ei — bordura,
## numele, halo-ul, piesa — iar de aici se schimbă toate patru deodată.
## Imaginile de pe disc rămân gri: culoarea se pune la desenare, cu `modulate`.
const CULOARE_MEMORIE := Color(0.60, 0.85, 1.00)   # albastru
const CULOARE_LOGICA := Color(0.70, 1.00, 0.60)    # verde
const CULOARE_CUVINTE := Color(1.00, 0.85, 0.55)   # auriu

const CATALOG := [
	{
		"cheie": "memorie", "nume": "Memorie",
		"rol": "Cultura generala: intrebari cu patru variante, din sase domenii.",
		"piesa": GlifaSah.Piesa.PION,
		"imagine": "res://assets/art/pion_sah.png",
		"culoare": CULOARE_MEMORIE, "scena": SCENA_TRIVIA,
	},
	{
		"cheie": "logica", "nume": "Logica",
		"rol": "Siruri, intrusul, analogii, silogisme, ordonari.",
		"piesa": GlifaSah.Piesa.CAL,
		"imagine": "res://assets/art/cal_sah.png",
		"culoare": CULOARE_LOGICA, "scena": SCENA_LOGICA,
	},
	{
		"cheie": "cuvinte", "nume": "Cuvinte",
		"rol": "Sinonime, antonime, definitii, analogii de vocabular.",
		"piesa": GlifaSah.Piesa.NEBUN,
		"imagine": "res://assets/art/nebun_sah.png",
		"culoare": CULOARE_CUVINTE, "scena": SCENA_CUVINTE,
	},
]


## Câte discipline există. ĂSTA e M-ul din „alege N din M" — citit, nu scris.
func cate() -> int:
	return CATALOG.size()


## Toate cheile, în ordinea din tabel. Folosită de ecranul de loadout ca să
## deseneze rândurile, și de expediție ca plasă de siguranță (vezi
## `loadout_implicit()`).
func chei() -> Array[String]:
	var lista: Array[String] = []
	for date in CATALOG:
		lista.append(String(date["cheie"]))
	return lista


## Fișa unei discipline, după cheie. Dicționar GOL dacă cheia nu există —
## se poate întâmpla la un save vechi, scris când disciplina încă exista.
## Apelantul verifică `is_empty()` și sare peste ea, în loc să crape.
func dupa_cheie(cheie: String) -> Dictionary:
	for date in CATALOG:
		if String(date["cheie"]) == cheie:
			return date
	return {}


## Numele de afișat, pentru mesaje. Cheia necunoscută se întoarce ca atare:
## într-un jurnal, „cuvinte_vechi" e mai util decât un rând gol.
func nume(cheie: String) -> String:
	var date := dupa_cheie(cheie)
	return String(date["nume"]) if not date.is_empty() else cheie


## Există disciplina asta?
func exista(cheie: String) -> bool:
	return not dupa_cheie(cheie).is_empty()

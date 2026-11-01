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
## Regula a fost scrisă pe vremea când M era 3 și N era 3, deci loadout-ul era
## „le iei pe toate" și părea că n-are rost. Avea: singurul moment în care poți
## scrie corect regula e cât e banală. Astăzi M e 5 și N e 3 — „alege 3 din 5",
## 10 combinații — iar niciun „3" și niciun „5" n-a trebuit căutat prin cod.
##
## Deci:
##   M = `CATALOG.size()`             — câte discipline există
##   N = `Expeditie.DISCIPLINE_IN_LOADOUT` — câte iei într-o expediție
##
## Nicăieri altundeva. Ecranul de loadout desenează M rânduri și numără până la
## N; lupta construiește exact atâtea Obeliscuri câte are loadout-ul. A patra
## disciplină (Numere) și a cincea (Tipare) au fost, fiecare, un RÂND în
## tabelul de mai jos și nimic altceva — proba promisiunii, făcută de două ori.
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
##   „sarcini"    — ce FELURI de întrebări pune, câte un rând pe fel. Le arată
##                  cartea de pe hartă („Cronicile"): „rol" spune într-o frază
##                  ce antrenează, „sarcini" spune ce o să ai în față. Scrise
##                  după generatoarele din scena disciplinei, nu după dorințe —
##                  un fel nou de întrebare e un rând nou și aici.
##   „scena"      — disciplina propriu-zisă. Toate respectă același contract
##                  (`porneste`, `arata_stare`, semnalul `rezolvat`), deci
##                  lupta le tratează la fel și nu știe ce e înăuntru.

const SCENA_TRIVIA := preload("res://scenes/trivia/trivia.tscn")
const SCENA_LOGICA := preload("res://scenes/logica/logica.tscn")
const SCENA_CUVINTE := preload("res://scenes/cuvinte/cuvinte.tscn")
const SCENA_NUMERE := preload("res://scenes/numere/numere.tscn")
const SCENA_TIPARE := preload("res://scenes/tipare/tipare.tscn")

## CULORILE. Fiecare e folosită în patru locuri de pe butonul ei — bordura,
## numele, halo-ul, piesa — iar de aici se schimbă toate patru deodată.
## Imaginile de pe disc rămân gri: culoarea se pune la desenare, cu `modulate`.
const CULOARE_MEMORIE := Color(0.60, 0.85, 1.00)   # albastru
const CULOARE_LOGICA := Color(0.70, 1.00, 0.60)    # verde
const CULOARE_CUVINTE := Color(1.00, 0.85, 0.55)   # auriu
# Violetul e a patra fiindcă roșul NU e liber: `Puzzle.CULOARE_RAU` e un roșu
# deschis, iar un Obelisc roșu lângă un buton de răspuns greșit ar fi fost
# aceeași culoare cu două înțelesuri. La fel se vor alege și următoarele:
# culorile de verdict se ocolesc, nu se împart.
const CULOARE_NUMERE := Color(0.78, 0.66, 1.00)    # violet
# A cincea: ROZ. S-au cântărit două, și motivul pentru care a câștigat rozul e
# o regulă pentru următoarele. Celălalt candidat era un verde-albastru (teal),
# care ar fi fost o culoare frumoasă și o greșeală: pe un buton de 40 px, lângă
# albastrul Memoriei și verdele Logicii, el ar fi fost „a treia nuanță dintre
# ele". O culoare de disciplină nu trebuie să fie plăcută, trebuie să fie
# RECUNOSCUTĂ periferic, în mijlocul unei ture — același criteriu care alege și
# siluetele din `glifa_sah.gd`.
# Rozul e departe de toate patru, și destul de departe și de roșu: `CULOARE_RAU`
# e un roșu-somon (1, 0.4, 0.4), iar aici verdele e urcat la 0.66 tocmai ca
# nuanța să cadă limpede în roz, nu la jumătatea drumului spre el.
const CULOARE_TIPARE := Color(1.00, 0.66, 0.88)    # roz

const CATALOG := [
	{
		"cheie": "memorie", "nume": "Memorie",
		"rol": "Cultura generala: intrebari cu patru variante, din opt domenii.",
		"sarcini": [
			"Opt domenii: geografie, istorie, stiinta, arta si literatura, divertisment, sport, gastronomie, diverse.",
		],
		"piesa": GlifaSah.Piesa.PION,
		"imagine": "res://assets/art/pion_sah.png",
		"culoare": CULOARE_MEMORIE, "scena": SCENA_TRIVIA,
	},
	{
		"cheie": "logica", "nume": "Logica",
		"rol": "Deductii, enigme, silogisme, numaratori, ordonari.",
		# Cele PATRUSPREZECE tipuri ale Logicii nu încap aici ca patrusprezece
		# rânduri — cartea de pe hartă ar fi devenit un perete de text. Deci
		# rândurile sunt FAMILIILE, cele cinci din antetul lui `logica.gd`, și
		# fiecare le numește pe ale ei. Regula din antetul fișierului („un fel
		# nou de întrebare e un rând nou și aici") ține în continuare, numai că
		# unitatea e familia: un tip nou intră în rândul familiei lui, iar o
		# familie nouă e un rând nou.
		"sarcini": [
			"Intrusul si analogiile: ce nu e din familie, si A e fata de B cum e C fata de ...",
			"Logica propozitionala: silogisme, daca-atunci, negatii, si/sau, premisa lipsa.",
			"Enigme: cine minte si cine spune adevarul.",
			"Numaratori: multimi, cel mai rau caz, roata saptamanii.",
			"Constrangeri: din cateva indicii, afli cine sta unde si cine are ce.",
		],
		"piesa": GlifaSah.Piesa.CAL,
		"imagine": "res://assets/art/cal_sah.png",
		"culoare": CULOARE_LOGICA, "scena": SCENA_LOGICA,
	},
	{
		"cheie": "cuvinte", "nume": "Cuvinte",
		"rol": "Sinonime, antonime, definitii, analogii de vocabular.",
		"sarcini": [
			"Sinonime si antonime.",
			"Definitii: ce inseamna un cuvant, si invers, cuvantul dupa definitie.",
			"Cuvantul lipsa: deduci relatia din prima pereche.",
		],
		"piesa": GlifaSah.Piesa.NEBUN,
		"imagine": "res://assets/art/nebun_sah.png",
		"culoare": CULOARE_CUVINTE, "scena": SCENA_CUVINTE,
	},
	{
		"cheie": "numere", "nume": "Numere",
		"rol": "Calcul rapid, procente, estimare, fractii si zecimale.",
		"sarcini": [
			"Calcul: lanturi de adunari, inmultiri, impartiri, ordinea operatiilor.",
			"Procente: cat la suta, procent dintr-un numar, reduceri de pret.",
			"Estimare: cam cat e, fara sa calculezi exact.",
			"Cantarul: care valoare e cea mai mare, intre fractii, zecimale si procente.",
		],
		"piesa": GlifaSah.Piesa.TURN,
		# Fără artă încă: turnul se desenează. `_pune_imaginea` acceptă șirul
		# gol, deci rândul merge așa cum e până apare PNG-ul.
		"imagine": "",
		"culoare": CULOARE_NUMERE, "scena": SCENA_NUMERE,
	},
	{
		"cheie": "tipare", "nume": "Tipare",
		"rol": "Siruri, litere, sabloane care se repeta, numarul care strica regula.",
		"sarcini": [
			"Siruri de numere: gasesti termenul care urmeaza.",
			"Siruri de litere: acelasi lucru, dar numarat pe alfabet.",
			"Sabloane: ce urmeaza, si ce semn e pe locul 23.",
			"Intrusul din sir: care numar nu respecta regula.",
		],
		"piesa": GlifaSah.Piesa.REGINA,
		# Fără artă încă, ca la Numere: regina se desenează.
		"imagine": "",
		"culoare": CULOARE_TIPARE, "scena": SCENA_TIPARE,
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

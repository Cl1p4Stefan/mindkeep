extends Joc
## FIOLELE — masa a patra din Tavernă.
##
## Un „water sort": câteva fiole de sticlă, fiecare cu loc pentru
## `CAPACITATE` straturi de lichid, amestecate. N culori în N + 2 fiole, deci
## două pornesc goale. Alegi o fiolă, apoi alta, și torni. Câștigi când fiecare
## fiolă e plină cu o singură culoare, sau goală. Fără ceas, fără pierdere.
##
## Se poate juca singură, cu F6: nu știe nimic despre Tavernă, exact ca
## celelalte mese.
##
## ─────────────────────────────────────────────────────────────
## CE ANTRENEAZĂ
##
## Planificarea câțiva pași înainte — familia Turnului din Hanoi. Cuvântul
## Ascuns e căutare cu constrângeri (afli ceva la fiecare rând), Sudoku e
## constrângeri urmărite deodată (totul e pe ecran, nimic nu se mișcă). Aici
## totul e pe ecran și TOTUL SE MIȘCĂ: o turnare bună acum poate înfunda o
## fiolă de care ai nevoie peste trei turnări.
##
## ─────────────────────────────────────────────────────────────
## REGULA TURNĂRII, întreagă
##
## Se toarnă TOT STRATUL de aceeași culoare de deasupra, CÂT ÎNCAPE — nu câte o
## unitate. Ai voie doar dacă fiola în care torni e goală sau are deasupra
## aceeași culoare, și dacă mai are loc. Water sort, nu ball sort (decis pe 4
## noiembrie 2026): mai puține clicuri, mai multă planificare, fiindcă un strat
## întreg mutat o dată schimbă mai mult decât o bilă.
##
## ─────────────────────────────────────────────────────────────
## GARANȚIA E REZOLVABILITATEA, NU UNICITATEA
##
## La Sudoku se cere un singur răspuns. Aici pot fi multe, și nu interesează
## câte: ce se dovedește e că EXISTĂ unul. Un amestec la întâmplare se poate
## înfunda din prima, deci generatorul amestecă, iar un rezolvitor caută
## soluția; dacă n-o găsește, alt amestec. Metoda Lacătului și a lui Sudoku: un
## puzzle nu se crede pe cuvânt, se rezolvă.
##
## Rezolvitorul are un BUGET de stări. Un amestec pe care nu-l rezolvă în
## buget e aruncat la fel ca unul fără soluție — deci garanția rămâne întreagă
## („tot ce ajunge pe masă a fost rezolvat"), iar ce se pierde e doar câte un
## amestec greu de dovedit. `verifica_taverna` măsoară cât de des se întâmplă.
##
## ─────────────────────────────────────────────────────────────
## DIFICULTATEA E NUMĂRUL DE CULORI — deocamdată
##
## Planul cerea dificultatea MĂSURATĂ: mutările celei mai scurte soluții. Cel
## mai scurt drum cere o căutare în lățime, iar la nouă culori ea trece prin
## sute de mii de stări — în GDScript, secunde la fiecare amestec. Rezolvitorul
## de aici caută în ADÂNCIME: găsește repede UN drum, nu pe cel mai scurt. Deci
## nivelurile sunt 5 / 7 / 9 culori, iar `verifica_taverna` tipărește cât de
## lungi ies soluțiile pe fiecare nivel. Un prag pe mutări minime rămâne de
## pus când se va ști dacă trebuie.
##
## ─────────────────────────────────────────────────────────────
## FĂRĂ SEMNE PE STRATURI, deci paleta e o MĂSURĂTOARE
##
## Deosebirea o duce numai culoarea, deci paleta nu e „roșu, verde,
## albastru…": e aleasă și măsurată (distanța dintre culori în Oklab, și
## luminozitatea fiecăreia pe fondul închis), iar `verifica_taverna` cere amândouă.
## Roșul și verdele NU sunt interzise aici: regula cu culorile de verdict e a
## scenei de puzzle, iar masa n-are verdict pe parcurs. Ordinea din `PALETA`
## contează — nivelul ușor ia primele cinci, cele mai depărtate între ele.
##
## ─────────────────────────────────────────────────────────────
## CE NU SE POATE PIERDE
##
## Te poți înfunda, și de-aia există „Înapoi" (nelimitat) și „Reia" (aceeași
## partidă, de la capăt). Masa poate spune „nu mai ai nicio turnare", dar nu
## te dă afară — „Ton sănătos". `termina(true, …)` e singurul final, ca la
## Sudoku. Amestecurile sunt generate, deci nu se repetă, iar `Sac` n-are ce
## ține minte; pe disc stă un singur număr, treapta (vezi mai jos).
##
## ─────────────────────────────────────────────────────────────
## TREPTELE — al doilea fel de a alege dificultatea
##
## Lângă Ușor / Mediu / Greu, un drum fără capăt: treapta 1, 2, 3… Câștigi o
## treaptă, urmează următoarea; „Încă unul" al Tavernei te duce chiar acolo,
## fiindcă treapta e `static` și pe disc. Treapta 1 e cel mai mic joc cu putință
## (2 culori în 3 fiole), iar de acolo cresc, pe rând, două lucruri:
##
##   1. CULORILE, după `TREPTE_CULORI`, până la toată paleta (9). Cu una și două
##      culori se lasă o singură fiolă goală — cu două, jocul s-ar rezolva
##      singur;
##   2. STRATURILE ASCUNSE, de la `TREAPTA_PRIMA_ASCUNSA` încolo, câte unul la
##      `TREPTE_PE_ASCUNS` trepte: un strat ascuns se desenează cu „?" și își
##      arată culoarea abia când ajunge DEASUPRA într-o fiolă. Stratul de
##      deasupra nu e ascuns niciodată, deci regula turnării nu atârnă de ce nu
##      vezi: ce poți turna e mereu pe ecran.
##
## Rețeta e o FUNCȚIE de treaptă (`reteta_treptei`), nu un tabel de o mie de
## rânduri. Se ÎNCHIDE cinstit: când toate straturile de sub vârf sunt ascunse
## pe nouă culori, rețeta nu mai crește (`TREAPTA_PLAFON`) — treptele merg mai
## departe la nesfârșit, cu amestecuri noi de aceeași greutate. Altă axă
## (o singură fiolă goală pe nouă culori) ar fi lovit rezolvabilitatea, nu
## gândirea.
##
## Treapta N e MEREU aceeași masă: sămânța ei e treapta, amestecată prin
## `hash` (vezi „O sămânță dată mai departe se amestecă întâi" din CLAUDE.md).
## Așa „treapta 37" e un loc, nu o tragere la sorți — și verificarea o poate
## bate fără să joace treptele de dinainte.
##
## CE S-A VĂZUT NU SE MAI ASCUNDE. Un strat ascuns e pe locul lui de la start
## până îl vezi (de sub el nu se poate lua nimic, iar el n-a plecat), deci
## identitatea lui e chiar locul de start, `Vector2i(fiolă, rând)`. Ce ai
## văzut intră în `dezvaluite`, care doar crește: „Înapoi" și „Reia" întorc
## lichidul, nu și ce ai aflat — o informație nu se dezvață.

const FIOLA := preload("res://scenes/taverna/fiolele/fiola.gd")

## Câte straturi ține o fiolă. VARIABILĂ, ca `LATURA` la Sudoku.
const CAPACITATE := 4
## Câte fiole pornesc goale. Cu una singură, cele mai multe amestecuri se
## înfundă din prima; cu trei, jocul se rezolvă aproape singur.
const GOALE := 2

## Nivelurile: câte culori sunt pe masă (deci culori + `GOALE` fiole).
const NIVELURI := [
	{"nume": "Ușor", "culori": 5},
	{"nume": "Mediu", "culori": 7},
	{"nume": "Greu", "culori": 9},
]

## Paleta, în ordinea în care intră pe niveluri. Măsurată în Oklab pe 4
## noiembrie 2026: cea mai apropiată pereche e albastru–violet (0,147), care
## intră abia la nivelul mediu; cea mai întunecată culoare are L = 0,57, pe un
## fond de 0,2. Numele nu apar pe ecran — sunt aici pentru verificare și pentru
## cine citește codul.
const PALETA := [
	{"nume": "roșu", "culoare": Color(0.86, 0.18, 0.2)},
	{"nume": "galben", "culoare": Color(0.96, 0.84, 0.22)},
	{"nume": "albastru", "culoare": Color(0.22, 0.42, 0.95)},
	{"nume": "verde", "culoare": Color(0.22, 0.7, 0.3)},
	{"nume": "roz", "culoare": Color(0.98, 0.52, 0.78)},
	{"nume": "violet", "culoare": Color(0.6, 0.3, 0.85)},
	{"nume": "turcoaz", "culoare": Color(0.2, 0.82, 0.82)},
	{"nume": "portocaliu", "culoare": Color(0.96, 0.52, 0.12)},
	{"nume": "alb", "culoare": Color(0.94, 0.93, 0.88)},
]

## De câte ori se amestecă până iese un amestec dovedit rezolvabil. Măsurat:
## aproape totdeauna iese din prima; plafonul e o plasă, nu o țintă.
## TREPTELE (vezi antetul): `[de la treapta, culori]`, în ordine.
const TREPTE_CULORI := [[1, 2], [3, 3], [6, 4], [10, 5], [15, 6], [21, 7], [28, 8], [36, 9]]
## Până la câte culori se lasă o singură fiolă goală.
const TREPTE_O_GOALA := 3
const TREAPTA_PRIMA_ASCUNSA := 20
const TREPTE_PE_ASCUNS := 6
## Treapta de la care rețeta nu mai crește: toate straturile de sub vârf
## ascunse, pe toată paleta. Socotită, nu scrisă: 20 + 6 × (9 × 3 − 1) = 176.
const TREAPTA_PLAFON := TREAPTA_PRIMA_ASCUNSA \
	+ TREPTE_PE_ASCUNS * (9 * (CAPACITATE - 1) - 1)

const INCERCARI_GENERARE := 400
## Câte stări are voie să viziteze rezolvitorul pe un amestec. Vezi
## „GARANȚIA E REZOLVABILITATEA" din antet.
const BUGET_REZOLVITOR := 40000

# ─────────────────────────────────────────────────────────────
# ÎNFĂȚIȘAREA — ca la Sudoku: culorile textului și ale butoanelor sunt ale
# mesei, fiindcă masa stă pe biblioteca estompată, nu pe pergament.
# ─────────────────────────────────────────────────────────────
const CULOARE_TEXT := Color(0.98, 0.95, 0.88)
const CULOARE_BUTON := Color(0.68, 0.82, 0.93)
const CULOARE_CHENAR := Color(0.58, 0.5, 0.4)

const LATIME_FIOLA := 58.0
const INALTIME_STRAT := 54.0
const SEPARARE_FIOLE := 18
## Fiolele din panoul cu reguli: mai scunde, fiindcă panoul decretului le pune
## sub paragraful lui și trebuie să încapă tot pe pânză. ACEEAȘI funcție le
## face, doar cu alt număr.
const INALTIME_STRAT_REGULI := 24.0
const MARIME_TASTA := 18
const INALTIME_TASTA := 30
const INALTIME_NIVEL := 28

## TURNAREA CARE SE VEDE, în secunde: fiola se duce deasupra țintei și se
## înclină până ajunge lichidul la buză, curge (mai mult cu cât sunt mai multe
## straturi), apoi se întoarce. Sub o secundă pentru un strat: destul cât să
## vezi ce s-a mutat, nu atât cât să aștepți.
const DURATA_APROPIERE := 0.26
const DURATA_CURGERE := 0.12
const DURATA_STRAT := 0.16
const DURATA_INTOARCERE := 0.26
## Cât de sus deasupra gurii țintei stă buza din care se toarnă, în pixeli.
const INALTIME_JET := 30.0

## Nivelul ales de pe tăblie. `static` — vezi „NIVELURILE STAU PE TĂBLIE" din
## `sudoku.gd`; aceeași decizie, din același motiv.
static var _nivel_ales := 1
## Joci pe trepte, nu pe un nivel? Și treapta la care ai ajuns — cea pe care
## n-ai câștigat-o încă. Pe disc stă numai treapta (`spre_dictionar`).
static var _pe_trepte := false
static var _treapta := 1

## Amestecul de la început, pentru „Reia". Nu se schimbă în timpul partidei.
var start: Array = []
## Ce e acum pe masă: o listă de fiole, fiecare o listă de culori de jos în sus.
var fiole: Array = []
## Stările de dinainte de fiecare turnare, pentru „Înapoi". Stări ÎNTREGI, nu
## turnări de desfăcut: „Înapoi întoarce exact starea de dinainte" e atunci
## adevărat prin construcție, nu printr-o socoteală inversă care poate greși.
var istoric: Array = []
## Nivelul partidei, sau -1 pe trepte.
var nivel := 1
## Treapta partidei, sau 0 când se joacă pe un nivel.
var treapta := 0
## Straturile ascunse la start, ca `Vector2i(fiolă, rând)` → true, și cele
## dintre ele care s-au văzut între timp. Vezi „CE S-A VĂZUT" din antet.
var ascunse_start := {}
var dezvaluite := {}
## Fiola aleasă, sau -1.
var aleasa := -1

## Nodurile desenate, pe index.
var vase: Array[FIOLA] = []
var butoane_nivel: Array[Button] = []
var buton_trepte: Button = null
var rand_niveluri: HBoxContainer = null
var buton_inapoi: Button = null
var buton_reia: Button = null

## Turnarea animată în curs, sau `null`. ANIMAȚIA NU E STAREA: `fiole` se
## schimbă pe loc, la clic, iar tot ce urmează e doar desen. Așa regula,
## „Înapoi", finalul și verificarea nu știu că există o animație — și nu pot
## greși din cauza ei.
var _turnare: Tween = null
## Tot ce-i trebuie animației: fiolele, partea, buza, unghiurile, straturile.
var _anim := {}

@onready var rand_fiole: HBoxContainer = %Fiole
@onready var mesaj: Label = %Mesaj
@onready var rand_taste: HBoxContainer = %Taste


func _ready() -> void:
	_construieste_nivelurile()
	_construieste_tastele()
	mesaj.text = ""
	# F6 — același tipar ca la Sudoku și la Cuvântul Ascuns.
	await get_tree().process_frame
	if not pornit:
		porneste()
	if rand_niveluri != null and rand_niveluri.get_parent() == null:
		$RandSus.add_child(rand_niveluri)
		$RandSus.move_child(rand_niveluri, 0)


## Vezi `_exit_tree` din `sudoku.gd`: un nod fără părinte nu moare odată cu cel
## care l-a făcut.
func _exit_tree() -> void:
	if _turnare != null:
		_turnare.kill()
	if rand_niveluri != null and rand_niveluri.get_parent() == null:
		rand_niveluri.queue_free()


# ─────────────────────────────────────────────────────────────
# PORNIREA
# ─────────────────────────────────────────────────────────────

func _porneste(cu_samanta: int) -> void:
	_grabeste()
	var rng := RandomNumberGenerator.new()
	treapta = 0
	ascunse_start = {}
	dezvaluite = {}
	if cu_samanta == SAMANTA_LIBERA and _pe_trepte:
		# Pe trepte, sămânța e TREAPTA: decretul trimite mereu o sămânță, deci
		# nu ajunge niciodată aici, iar o partidă a zilei nu urcă trepte.
		treapta = maxi(_treapta, 1)
		nivel = -1
		var masa := genereaza_treapta(treapta)
		start = masa["fiole"]
		for poz in masa["ascunse"]:
			ascunse_start[poz] = true
	elif cu_samanta == SAMANTA_LIBERA:
		rng.randomize()
		nivel = _nivel_ales
		start = genereaza(nivel, rng)
	else:
		# Sămânța hotărăște TOT jocul, nivelul inclus — ca la Sudoku.
		rng.seed = cu_samanta
		nivel = cu_samanta % NIVELURI.size()
		start = genereaza(nivel, rng)

	fiole = start.duplicate(true)
	istoric.clear()
	aleasa = -1
	_construieste_fiolele()
	_zugraveste_nivelurile()
	_zugraveste_tot()
	if treapta == TREAPTA_PRIMA_ASCUNSA:
		_spune("De aici, unele straturi sunt ascunse: le afli când ajung deasupra.")
	else:
		_spune("")


func rand_de_ajutor() -> String:
	return "Toarnă până fiecare fiolă are o singură culoare."


func unelte() -> Control:
	return rand_niveluri


## Regulile, pentru panoul Tavernei (vezi `Joc.reguli`).
##
## Exemplul e o turnare ADEVĂRATĂ: starea de „după" nu e scrisă de mână, e
## starea de „înainte" trecută prin `turna()` — chiar funcția cu care se joacă.
## Iar fiolele sunt născute de `_fiola_noua` și îmbrăcate de `_imbraca_fiola`,
## ca la celelalte mese: exemplul nu poate ajunge să arate altfel decât masa.
func reguli() -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 12)
	coloana.add_child(_rand_de_reguli(
		"Fiecare fiolă ține %d straturi. Sortează-le: la final, fiecare fiolă e plină"
		% CAPACITATE + " cu o singură culoare, sau goală.", 17))
	coloana.add_child(_rand_de_reguli(
		"Clic pe o fiolă, apoi pe alta: se toarnă tot stratul de deasupra, cât încape."
		+ " Torni doar peste aceeași culoare sau într-o fiolă goală:", 15))
	coloana.add_child(_exemplu_de_turnare())
	coloana.add_child(_rand_de_reguli(
		"Fără cronometru și fără pierdere: Înapoi (sau Backspace) desface ultima turnare,"
		+ " Reia pornește aceeași partidă de la capăt.", 15))
	coloana.add_child(_rand_de_reguli(
		"Treptele urcă singure, de la cel mai mic joc. De la treapta %d, unele straturi"
		% TREAPTA_PRIMA_ASCUNSA + " stau sub un ? și își arată culoarea când ajung deasupra.", 15))
	return coloana


## Exemplul din reguli: un strat de două galbene turnat ÎNTREG peste galben.
## Amestecul e FIX, ca pătratul din regulile lui Sudoku: două citiri ale
## aceluiași panou trebuie să fie același panou.
const EXEMPLU_REGULI := [[0, 1, 1], [2, 1]]

func _exemplu_de_turnare() -> Control:
	var inainte: Array = EXEMPLU_REGULI.duplicate(true)
	var dupa: Array = inainte.duplicate(true)
	turna(dupa, 0, 1)

	var centru := CenterContainer.new()
	var rand := HBoxContainer.new()
	rand.add_theme_constant_override("separation", 48)
	rand.add_child(_pereche_de_exemplu("înainte", inainte, 0))
	rand.add_child(_pereche_de_exemplu("după", dupa, -1))
	centru.add_child(rand)
	return centru


func _pereche_de_exemplu(titlu: String, stare: Array, ridicata: int) -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 4)
	var eticheta := _rand_de_reguli(titlu, 14)
	eticheta.autowrap_mode = TextServer.AUTOWRAP_OFF
	coloana.add_child(eticheta)
	var rand := HBoxContainer.new()
	rand.add_theme_constant_override("separation", 12)
	rand.alignment = BoxContainer.ALIGNMENT_CENTER
	for i in stare.size():
		var fiola := _fiola_noua(INALTIME_STRAT_REGULI)
		_imbraca_fiola(fiola, stare[i], i == ridicata)
		rand.add_child(fiola)
	coloana.add_child(rand)
	return coloana


func _rand_de_reguli(text: String, marime: int) -> Label:
	var eticheta := Label.new()
	eticheta.text = text
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", CULOARE_TEXT)
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return eticheta


# ─────────────────────────────────────────────────────────────
# REGULA ȘI GENERATORUL — PARTEA CARE N-ARE NEVOIE DE ECRAN
#
# Tot ce urmează e `static`, ca la Sudoku: verificarea bate amestecuri pe zeci
# de semințe fără să deschidă nicio fereastră.
#
# O stare e un `Array` de fiole, iar o fiolă un `Array` de culori (indici în
# `PALETA`), DE JOS ÎN SUS: ultimul element e stratul de deasupra, deci
# turnarea e `pop_back` dintr-una și `append` în alta.
# ─────────────────────────────────────────────────────────────

## Câte straturi s-ar turna din fiola `din` în fiola `in_`. 0 = turnarea nu e
## voie. Toată regula jocului stă în funcția asta; celelalte o folosesc.
static func cat_se_toarna(stare: Array, din: int, in_: int) -> int:
	if din == in_ or din < 0 or in_ < 0 or din >= stare.size() or in_ >= stare.size():
		return 0
	var sursa: Array = stare[din]
	var tinta: Array = stare[in_]
	if sursa.is_empty() or tinta.size() >= CAPACITATE:
		return 0
	var sus: int = sursa[-1]
	if not tinta.is_empty() and int(tinta[-1]) != sus:
		return 0
	# Cât de gros e stratul de deasupra: câte straturi de aceeași culoare, de
	# sus în jos, până la prima altfel.
	var strat := 0
	for i in range(sursa.size() - 1, -1, -1):
		if int(sursa[i]) != sus:
			break
		strat += 1
	return mini(strat, CAPACITATE - tinta.size())


static func poate_turna(stare: Array, din: int, in_: int) -> bool:
	return cat_se_toarna(stare, din, in_) > 0


## Toarnă, PE LOC, în starea primită. Întoarce câte straturi au trecut (0 dacă
## turnarea nu era voie, și atunci starea rămâne neatinsă).
static func turna(stare: Array, din: int, in_: int) -> int:
	var cat := cat_se_toarna(stare, din, in_)
	for k in cat:
		(stare[in_] as Array).append((stare[din] as Array).pop_back())
	return cat


## E masa sortată? Fiecare fiolă goală, sau plină cu o singură culoare.
static func e_gata(stare: Array) -> bool:
	for f in stare:
		var fiola: Array = f
		if fiola.is_empty():
			continue
		if fiola.size() != CAPACITATE or not _o_singura_culoare(fiola):
			return false
	return true


## Mai e vreo turnare cu putință?
static func are_turnari(stare: Array) -> bool:
	for din in stare.size():
		for in_ in stare.size():
			if poate_turna(stare, din, in_):
				return true
	return false


## O fiolă care primește dop: plină, și toată de o culoare. Nu e `e_gata`:
## acolo se întreabă de TOATĂ masa, aici de o singură fiolă.
static func _e_inchisa(fiola: Array) -> bool:
	return fiola.size() == CAPACITATE and _o_singura_culoare(fiola)


static func _o_singura_culoare(fiola: Array) -> bool:
	for v in fiola:
		if int(v) != int(fiola[0]):
			return false
	return true


## Un amestec dovedit rezolvabil, pe nivelul cerut.
static func genereaza(nivel_cerut: int, rng: RandomNumberGenerator) -> Array:
	var culori := int(NIVELURI[clampi(nivel_cerut, 0, NIVELURI.size() - 1)]["culori"])
	return _genereaza_din(culori, GOALE, rng)


## Ce se pune pe masă la treapta `n`: câte culori, câte fiole goale, câte
## straturi ascunse. Vezi „TREPTELE" din antet.
static func reteta_treptei(n: int) -> Dictionary:
	n = maxi(n, 1)
	var culori := 2
	for prag in TREPTE_CULORI:
		if n >= int(prag[0]):
			culori = int(prag[1])
	var ascunse := 0
	if n >= TREAPTA_PRIMA_ASCUNSA:
		ascunse = mini(culori * (CAPACITATE - 1),
			1 + (n - TREAPTA_PRIMA_ASCUNSA) / TREPTE_PE_ASCUNS)
	return {"culori": culori, "goale": 1 if culori <= TREPTE_O_GOALA else GOALE,
		"ascunse": ascunse}


## Masa treptei `n`: `{fiole, ascunse}`, cu `ascunse` o listă de `Vector2i`.
## Aceeași de fiecare dată — vezi antetul.
static func genereaza_treapta(n: int) -> Dictionary:
	var reteta := reteta_treptei(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("fiolele:treapta:%d" % maxi(n, 1))
	var stare := _genereaza_din(int(reteta["culori"]), int(reteta["goale"]), rng)
	return {"fiole": stare, "ascunse": _alege_ascunse(stare, int(reteta["ascunse"]), rng)}


## `cate` locuri ascunse, trase dintre straturile care NU sunt deasupra.
static func _alege_ascunse(stare: Array, cate: int, rng: RandomNumberGenerator) -> Array:
	var locuri: Array = []
	for f in stare.size():
		for k in (stare[f] as Array).size() - 1:
			locuri.append(Vector2i(f, k))
	for i in range(locuri.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t = locuri[i]
		locuri[i] = locuri[j]
		locuri[j] = t
	return locuri.slice(0, mini(cate, locuri.size()))


static func _genereaza_din(culori: int, goale: int, rng: RandomNumberGenerator) -> Array:
	var ultimul: Array = []
	for incercare in INCERCARI_GENERARE:
		var stare := _amesteca(culori, goale, rng)
		ultimul = stare
		# O fiolă sortată din prima e o fiolă pe care n-o joci.
		if _are_fiola_gata(stare):
			continue
		if not rezolva(stare).is_empty():
			return stare
	# N-ar trebui să se ajungă aici — verificarea măsoară câte încercări cer
	# amestecurile. Dacă se ajunge, se SPUNE: un amestec nedovedit pe masă ar
	# fi exact promisiunea încălcată.
	push_error("Fiolele: niciun amestec rezolvabil în %d încercări." % INCERCARI_GENERARE)
	return ultimul


## Toate straturile (fiecare culoare de `CAPACITATE` ori), amestecate cu RNG-ul
## PRIMIT — nu `shuffle()`, din motivul scris la `_cifre_amestecate` din
## Sudoku — împărțite în fiole pline, plus cele goale.
static func _amesteca(culori: int, goale: int, rng: RandomNumberGenerator) -> Array:
	var straturi: Array[int] = []
	for c in culori:
		for k in CAPACITATE:
			straturi.append(c)
	for i in range(straturi.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t := straturi[i]
		straturi[i] = straturi[j]
		straturi[j] = t
	var stare: Array = []
	for f in culori:
		stare.append(straturi.slice(f * CAPACITATE, (f + 1) * CAPACITATE))
	for g in goale:
		stare.append([])
	return stare


static func _are_fiola_gata(stare: Array) -> bool:
	for f in stare:
		var fiola: Array = f
		if fiola.size() == CAPACITATE and _o_singura_culoare(fiola):
			return true
	return false


## UN drum de turnări până la masa sortată, ca perechi `[din, in_]`. Gol dacă
## n-a găsit niciunul în buget — sau dacă starea e deja sortată, caz pe care
## generatorul nu-l dă niciodată (vezi `_are_fiola_gata`).
##
## Caută în ADÂNCIME, cu o stivă a ei și nu prin recursie: un drum găsit așa
## poate avea zeci de turnări, iar fiecare treaptă de recursie e un cadru pe
## stiva lui GDScript, care are fund. Și ține minte stările VĂZUTE, cu fiolele
## SORTATE în cheie (`cheie_stare`), ca aceeași masă cu fiolele în altă ordine
## să nu se cerceteze de două ori.
static func rezolva(stare: Array) -> Array:
	var f: Array = stare.duplicate(true)
	if e_gata(f):
		return []
	var vazute := {cheie_stare(f): true}
	var drum: Array = []
	var stiva: Array = [{"mutari": _turnari_utile(f), "i": 0, "cat": 0}]
	var vizitate := 0
	while not stiva.is_empty():
		var varf: Dictionary = stiva[-1]
		# Întâi se desface turnarea făcută de pe treapta asta, dacă a fost una:
		# ori ne-am întors dintr-o ramură fără ieșire, ori urmează alta.
		if int(varf["cat"]) > 0:
			var ultima: Array = drum.pop_back()
			_desface(f, ultima[0], ultima[1], int(varf["cat"]))
			varf["cat"] = 0
		var mutari: Array = varf["mutari"]
		if int(varf["i"]) >= mutari.size():
			stiva.pop_back()
			continue
		var m: Array = mutari[int(varf["i"])]
		varf["i"] = int(varf["i"]) + 1
		var cat := turna(f, m[0], m[1])
		var cheie := cheie_stare(f)
		if vazute.has(cheie):
			_desface(f, m[0], m[1], cat)
			continue
		vazute[cheie] = true
		drum.append(m)
		varf["cat"] = cat
		if e_gata(f):
			return drum
		vizitate += 1
		if vizitate >= BUGET_REZOLVITOR:
			return []
		stiva.append({"mutari": _turnari_utile(f), "i": 0, "cat": 0})
	return []


## Pune înapoi `cat` straturi din `in_` în `din`. Sunt toate de aceeași
## culoare (au plecat ca un singur strat), deci ordinea nu contează.
static func _desface(f: Array, din: int, in_: int, cat: int) -> void:
	for k in cat:
		(f[din] as Array).append((f[in_] as Array).pop_back())


## Turnările pe care rezolvitorul le încearcă, în ordinea în care le încearcă.
##
## Taie trei feluri de turnări care nu duc nicăieri — și NUMAI pe ele, fiindcă
## o tăietură greșită ar face rezolvitorul să declare fără soluție un amestec
## bun:
##   - dintr-o fiolă deja gata (plină, o culoare): n-are unde merge;
##   - o fiolă de o singură culoare într-una goală: aceeași masă, cu fiolele
##     în altă ordine;
##   - în a doua fiolă goală, când e și o primă: aceeași turnare, de două ori.
## Și le pune întâi pe cele PESTE ACEEAȘI CULOARE, care strâng straturi, apoi pe
## cele în fiole goale, care doar le mută.
static func _turnari_utile(f: Array) -> Array:
	var peste: Array = []
	var in_gol: Array = []
	for din in f.size():
		var sursa: Array = f[din]
		if sursa.is_empty():
			continue
		var uniforma := _o_singura_culoare(sursa)
		if uniforma and sursa.size() == CAPACITATE:
			continue
		var goala_folosita := false
		for in_ in f.size():
			if not poate_turna(f, din, in_):
				continue
			if (f[in_] as Array).is_empty():
				if uniforma or goala_folosita:
					continue
				goala_folosita = true
				in_gol.append([din, in_])
			else:
				peste.append([din, in_])
	return peste + in_gol


## Cheia unei stări, fără ordinea fiolelor: fiecare fiolă ca un șir de litere,
## șirurile sortate. Două mese cu aceleași fiole puse altfel sunt aceeași masă.
static func cheie_stare(f: Array) -> String:
	var bucati := PackedStringArray()
	for fiola in f:
		var s := ""
		for v in fiola:
			s += char(65 + int(v))
		bucati.append(s)
	bucati.sort()
	return "|".join(bucati)


# ─────────────────────────────────────────────────────────────
# CE APEȘI
# ─────────────────────────────────────────────────────────────

func _unhandled_key_input(event: InputEvent) -> void:
	if terminat_deja:
		return
	var tasta := event as InputEventKey
	if tasta == null or not tasta.pressed or tasta.echo:
		return
	if tasta.keycode == KEY_BACKSPACE or (tasta.keycode == KEY_Z and tasta.ctrl_pressed):
		inapoi()
		accept_event()


## Un clic pe fiola `i`. Prima alege, a doua toarnă.
##
## O turnare care nu e voie NU pierde clicul: fiola apăsată devine cea aleasă
## (dacă are ce turna), fiindcă de cele mai multe ori asta voiai — te-ai
## răzgândit asupra sursei. Și ecranul spune de ce n-a mers.
func apasa(i: int) -> void:
	if terminat_deja or i < 0 or i >= fiole.size():
		return
	# O turnare încă în aer se termină pe loc dacă clicul o atinge: ori e pe
	# una din cele două fiole, ori ar porni o turnare nouă. Alegerea unei
	# fiole a treia o lasă să curgă mai departe.
	if _turnare != null and (aleasa >= 0 or vase[i] == _anim["sursa"] or vase[i] == _anim["tinta"]):
		_grabeste()
	if aleasa < 0:
		if (fiole[i] as Array).is_empty():
			_spune("Fiola e goală — alege una cu lichid.")
			return
		aleasa = i
		_spune("")
		_zugraveste_tot()
		return
	if aleasa == i:
		aleasa = -1
		_spune("")
		_zugraveste_tot()
		return

	var din := aleasa
	if not poate_turna(fiole, din, i):
		_spune(_de_ce_nu(din, i))
		aleasa = -1 if (fiole[i] as Array).is_empty() else i
		_zugraveste_tot()
		return

	istoric.append(fiole.duplicate(true))
	# Ce era ascuns ÎNAINTE, pentru animație: stratul care rămâne deasupra în
	# sursă își arată culoarea abia când s-a terminat de turnat.
	var ascunse_inainte := [ascunse_in(din), ascunse_in(i)]
	var inaltime_sursa := (fiole[din] as Array).size()
	var cat := turna(fiole, din, i)
	# Un strat ascuns poate pleca fără să fi fost deasupra: sub un strat de
	# aceeași culoare, se toarnă odată cu el. Plecat, e văzut.
	for k in range(inaltime_sursa - cat, inaltime_sursa):
		dezvaluite[Vector2i(din, k)] = true
	_dezvaluie_varfurile()
	aleasa = -1
	_spune("")
	# Animația întâi: ea marchează cele două fiole ca animate, iar zugrăveala
	# de după le lasă în pace straturile și dopul — dopul fiolei umplute cade
	# abia când s-a terminat de turnat (`_incheie_turnarea`).
	_anima_turnarea(din, i, cat, istoric[-1], ascunse_inainte)
	_zugraveste_tot()

	if e_gata(fiole):
		Sunet.reda(Sunet.Efect.CORECT)
		# Treapta urcă ÎNAINTE de `termina`: Taverna scrie discul chiar în
		# clipa în care primește semnalul.
		if treapta > 0 and treapta == _treapta:
			_treapta += 1
		termina(true, rezumat())
	elif not are_turnari(fiole):
		_spune("Nu mai ai nicio turnare. Înapoi sau Reia.")


## E ascuns acum stratul de pe rândul `k` al fiolei `f`? Pe locul unui strat
## ascuns nevăzut stă mereu chiar stratul de la start (vezi antetul), deci
## întrebarea se pune pe LOC.
func e_ascuns(f: int, k: int) -> bool:
	var loc := Vector2i(f, k)
	return ascunse_start.has(loc) and not dezvaluite.has(loc)


## Straturile ascunse ale fiolei `f`, de jos în sus, pentru desen.
func ascunse_in(f: int) -> Array[bool]:
	var rez: Array[bool] = []
	for k in (fiole[f] as Array).size():
		rez.append(e_ascuns(f, k))
	return rez


## Stratul de deasupra al fiecărei fiole se vede. Chemată după orice schimbă
## lichidul — o plasă: „Înapoi" și „Reia" ajung numai în stări în care
## vârfurile se văzuseră deja.
func _dezvaluie_varfurile() -> void:
	for f in fiole.size():
		var n := (fiole[f] as Array).size()
		if n > 0 and ascunse_start.has(Vector2i(f, n - 1)):
			dezvaluite[Vector2i(f, n - 1)] = true


func _de_ce_nu(_din: int, in_: int) -> String:
	if (fiole[in_] as Array).size() >= CAPACITATE:
		return "Fiola e plină."
	return "Torni doar peste aceeași culoare sau într-o fiolă goală."


## Desface ultima turnare.
func inapoi() -> void:
	if terminat_deja:
		return
	if istoric.is_empty():
		_spune("N-ai ce desface.")
		return
	_grabeste()
	fiole = istoric.pop_back()
	aleasa = -1
	_dezvaluie_varfurile()
	_spune("")
	_zugraveste_tot()


## Aceeași partidă, de la capăt. NU `porneste()`: aceea ar trage alt amestec.
func reia() -> void:
	if terminat_deja:
		return
	_grabeste()
	fiole = start.duplicate(true)
	istoric.clear()
	aleasa = -1
	_dezvaluie_varfurile()
	_spune("")
	_zugraveste_tot()


## Un alt nivel repornește partida — prin `porneste()`, ca Taverna să afle
## (vezi `schimba_nivelul` din `sudoku.gd`). Și te scoate de pe trepte.
func schimba_nivelul(n: int) -> void:
	if n < 0 or n >= NIVELURI.size():
		return
	_nivel_ales = n
	_pe_trepte = false
	porneste(SAMANTA_LIBERA)


## Pe trepte, la treapta la care ai ajuns. Tot prin `porneste()`.
func urca_pe_trepte() -> void:
	_pe_trepte = true
	porneste(SAMANTA_LIBERA)


## Fraza de la final. Turnările sunt cele RĂMASE — cele desfăcute cu „Înapoi"
## nu se socotesc: ce se laudă e drumul cu care ai ieșit, nu cel căutat.
func rezumat() -> String:
	if treapta > 0:
		return "Gata! Treapta %d, sortată în %s. Urmează treapta %d." % [
			treapta, _turnari(istoric.size()), treapta + 1]
	return "Gata! Nivel %s, sortat în %s." % [
		String(NIVELURI[nivel]["nume"]).to_lower(), _turnari(istoric.size())]


## „o turnare", „7 turnări", „23 de turnări" — politețea cu româna de la
## `_jocuri` din `taverna.gd`.
static func _turnari(n: int) -> String:
	if n == 1:
		return "o turnare"
	var rest := n % 100
	if n < 20 or (rest >= 1 and rest <= 19):
		return "%d turnări" % n
	return "%d de turnări" % n


func _spune(text: String) -> void:
	mesaj.text = text


# ─────────────────────────────────────────────────────────────
# ECRANUL
# ─────────────────────────────────────────────────────────────

## Fiolele, de la zero: câte sunt atârnă de nivel, deci la fiecare pornire.
## `remove_child` înainte de `queue_free`, ca la `_goleste_cuprinsul` din
## Tavernă: un nod care mai trăiește un cadru ar fi intrat în lățimea rândului
## exact în cadrul în care se măsoară.
func _construieste_fiolele() -> void:
	for copil in rand_fiole.get_children():
		rand_fiole.remove_child(copil)
		copil.queue_free()
	vase.clear()
	for i in fiole.size():
		var fiola := _fiola_noua(INALTIME_STRAT)
		fiola.gui_input.connect(_pe_clic_fiola.bind(i))
		rand_fiole.add_child(fiola)
		vase.append(fiola)


func _pe_clic_fiola(event: InputEvent, i: int) -> void:
	var clic := event as InputEventMouseButton
	if clic != null and clic.pressed and clic.button_index == MOUSE_BUTTON_LEFT:
		apasa(i)


## O fiolă goală. Folosită de masă ȘI de exemplul din reguli.
func _fiola_noua(inaltime_strat: float) -> FIOLA:
	var fiola: FIOLA = FIOLA.new()
	fiola.capacitate = CAPACITATE
	fiola.latime = LATIME_FIOLA
	fiola.inaltime_strat = inaltime_strat
	fiola.update_minimum_size()
	return fiola


## Pune straturile (indici în `PALETA`) într-o fiolă desenată.
func _imbraca_fiola(fiola: FIOLA, straturi: Array, ridicata: bool,
		ascunse: Array[bool] = []) -> void:
	fiola.aseaza(_culori_din(straturi), ridicata, ascunse)


## Cu `capace_animate`, un dop nou CADE; altfel apare pe loc. Numai sfârșitul
## unei turnări le animă: un dop care cade la „Înapoi" ar sărbători o fiolă pe
## care n-ai umplut-o tu acum. Fără sunet, deocamdată: `Sunet.Efect.CAPAC` e
## capacul CUFĂRULUI care se deschide, adică exact pe dos.
func _zugraveste_tot(capace_animate := false) -> void:
	for i in vase.size():
		_imbraca_fiola(vase[i], fiole[i], i == aleasa, ascunse_in(i))
		# Cât curge, dopul fiolelor din turnare îl hotărăște animația.
		if not vase[i].animata:
			vase[i].seteaza_capac(_e_inchisa(fiole[i]), capace_animate)
	if buton_inapoi != null:
		buton_inapoi.modulate = Color(1, 1, 1, 0.4 if istoric.is_empty() else 1.0)


# ─────────────────────────────────────────────────────────────
# TURNAREA ANIMATĂ
#
# Trei timpi, fiecare un `tween_method` cu t de la 0 la 1. În toți trei, fiola
# sursă e așezată prin BUZA ei: se spune unde trebuie să fie colțul gurii și
# cât de înclinată e fiola, iar `_aseaza_sursa` află de acolo cât s-o mute.
# Așa buza stă nemișcată deasupra țintei cât timp fiola se înclină — cum ține
# mâna o sticlă când toarnă — și jetul cade mereu din același loc.
# ─────────────────────────────────────────────────────────────

func _anima_turnarea(din: int, in_: int, cat: int, inainte: Array, ascunse: Array) -> void:
	var sursa: FIOLA = vase[din]
	var tinta: FIOLA = vase[in_]
	var s := 1.0 if tinta.position.x > sursa.position.x else -1.0
	var vol := float((inainte[din] as Array).size())
	# Unghiul de curgere pe fiecare strat întreg; între ele, linie dreaptă.
	var unghiuri: Array[float] = []
	for k in cat + 1:
		unghiuri.append(sursa.unghi_de_curgere(vol - k, s))
	var buza := tinta.position - sursa.position \
		+ Vector2(tinta.size.x / 2.0, FIOLA.RIDICARE) + Vector2(-s * 4.0, -INALTIME_JET)
	_anim = {
		"sursa": sursa, "tinta": tinta, "s": s, "cat": cat, "buza": buza,
		"unghiuri": unghiuri,
		"culoare": PALETA[int((inainte[din] as Array)[-1])]["culoare"],
		"seg_sursa": FIOLA.segmente_din(_culori_din(inainte[din]), ascunse[0]),
		"seg_tinta": FIOLA.segmente_din(_culori_din(inainte[in_]), ascunse[1]),
		"durata_curgere": DURATA_CURGERE + DURATA_STRAT * cat,
	}
	sursa.animata = true
	tinta.animata = true
	# O fiolă gata se poate turna întreagă într-una goală (regula n-o oprește),
	# deci dopul ei sare înainte să se încline.
	sursa.seteaza_capac(false, false)
	sursa.segmente = (_anim["seg_sursa"] as Array).duplicate(true)
	tinta.segmente = (_anim["seg_tinta"] as Array).duplicate(true)
	# Sursa trece PESTE celelalte fiole: în rând, una din dreapta ei s-ar fi
	# desenat deasupra.
	sursa.z_index = 1

	_turnare = create_tween()
	_turnare.tween_method(_apropie, 0.0, 1.0, DURATA_APROPIERE) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_turnare.tween_method(_curge, 0.0, 1.0, _anim["durata_curgere"])
	_turnare.tween_method(_intoarce, 0.0, 1.0, DURATA_INTOARCERE) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_turnare.tween_callback(_incheie_turnarea)


## Pune fiola sursă cu buza în `punct`, înclinată cu `a`.
func _aseaza_sursa(a: float, punct: Vector2) -> void:
	var sursa: FIOLA = _anim["sursa"]
	sursa.unghi = a
	sursa.deplasare = punct - sursa.ancora_baza() - sursa.buza(_anim["s"]).rotated(a)
	sursa.queue_redraw()


## Unde ar fi buza dacă fiola ar sta la locul ei, dreaptă.
func _buza_de_repaus() -> Vector2:
	var sursa: FIOLA = _anim["sursa"]
	return sursa.ancora_baza() + sursa.buza(_anim["s"])


## 1. Se duce deasupra țintei și se înclină până la pragul de curgere.
func _apropie(t: float) -> void:
	_aseaza_sursa(float(_anim["unghiuri"][0]) * t, _buza_de_repaus().lerp(_anim["buza"], t))


## 2. Curge: sursa scade, ținta crește, fiola se înclină tot mai tare.
func _curge(t: float) -> void:
	var sursa: FIOLA = _anim["sursa"]
	var tinta: FIOLA = _anim["tinta"]
	var cat: int = _anim["cat"]
	var curs := t * cat
	var unghiuri: Array[float] = _anim["unghiuri"]
	var k := mini(int(curs), cat - 1)
	_aseaza_sursa(lerpf(unghiuri[k], unghiuri[k + 1], curs - k), _anim["buza"])

	var seg_sursa: Array = (_anim["seg_sursa"] as Array).duplicate(true)
	seg_sursa[-1][1] = float(seg_sursa[-1][1]) - curs
	sursa.segmente = seg_sursa
	var seg_tinta: Array = (_anim["seg_tinta"] as Array).duplicate(true)
	if seg_tinta.is_empty() or not (seg_tinta[-1][0] as Color).is_equal_approx(_anim["culoare"]):
		seg_tinta.append([_anim["culoare"], 0.0])
	seg_tinta[-1][1] = float(seg_tinta[-1][1]) + curs
	tinta.segmente = seg_tinta
	tinta.agitatie = 1.0
	tinta.queue_redraw()

	# Jetul ajunge jos în primele 0,08 s, nu dintr-o dată.
	var de_la := sursa.pe_ecran(sursa.buza(_anim["s"]))
	var jos := tinta.suprafata_y() + (tinta.position - sursa.position).y
	var crestere := clampf(t * float(_anim["durata_curgere"]) / 0.08, 0.0, 1.0)
	sursa.jet = {"de_la": de_la, "pana_la": lerpf(de_la.y, jos, crestere),
		"culoare": _anim["culoare"], "s": _anim["s"]}
	_anim["capat_jet"] = de_la
	_anim["jos_jet"] = jos


## 3. Se îndreaptă și se întoarce la loc. Coada jetului cade după ea.
func _intoarce(t: float) -> void:
	var sursa: FIOLA = _anim["sursa"]
	var unghiuri: Array[float] = _anim["unghiuri"]
	_aseaza_sursa(lerpf(unghiuri[-1], 0.0, t), (_anim["buza"] as Vector2).lerp(_buza_de_repaus(), t))
	var coada := clampf(t / 0.3, 0.0, 1.0)
	if coada < 1.0 and _anim.has("capat_jet"):
		var capat: Vector2 = _anim["capat_jet"]
		var jos: float = _anim["jos_jet"]
		sursa.jet = {"de_la": Vector2(capat.x, lerpf(capat.y, jos, coada)), "pana_la": jos,
			"culoare": _anim["culoare"], "s": _anim["s"]}
	else:
		sursa.jet = {}
	var tinta: FIOLA = _anim["tinta"]
	tinta.agitatie = 1.0 - t
	tinta.queue_redraw()


## Fiolele se întorc la ce e LOGIC în ele — chiar dacă animația a fost tăiată
## la jumătate.
func _incheie_turnarea() -> void:
	_turnare = null
	for cheie in ["sursa", "tinta"]:
		var fiola = _anim.get(cheie)
		if fiola == null or not is_instance_valid(fiola):
			continue
		fiola.animata = false
		fiola.unghi = 0.0
		fiola.deplasare = Vector2.ZERO
		fiola.jet = {}
		fiola.agitatie = 0.0
		fiola.z_index = 0
	_anim = {}
	_zugraveste_tot(true)


## O turnare în aer se termină pe loc. Chemată de orice schimbă masa altfel
## decât o turnare care curge: „Înapoi", „Reia", o partidă nouă.
func _grabeste() -> void:
	if _turnare == null:
		return
	_turnare.kill()
	_incheie_turnarea()


func _culori_din(straturi: Array) -> Array[Color]:
	var rez: Array[Color] = []
	for v in straturi:
		rez.append(PALETA[int(v)]["culoare"])
	return rez


func _construieste_nivelurile() -> void:
	rand_niveluri = HBoxContainer.new()
	rand_niveluri.add_theme_constant_override("separation", 6)
	rand_niveluri.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	butoane_nivel.clear()
	for n in NIVELURI.size():
		var buton := _buton(String(NIVELURI[n]["nume"]), 62, INALTIME_NIVEL)
		buton.pressed.connect(schimba_nivelul.bind(n))
		rand_niveluri.add_child(buton)
		butoane_nivel.append(buton)
	# Treptele, despărțite de niveluri printr-un rost: sunt alt fel de a alege,
	# nu al patrulea nivel.
	var rost := Control.new()
	rost.custom_minimum_size = Vector2(6, 0)
	rand_niveluri.add_child(rost)
	buton_trepte = _buton("", 104, INALTIME_NIVEL)
	buton_trepte.pressed.connect(urca_pe_trepte)
	rand_niveluri.add_child(buton_trepte)


func _zugraveste_nivelurile() -> void:
	for n in butoane_nivel.size():
		_zugraveste_alegerea(butoane_nivel[n], n == nivel)
	# Treapta la care ai ajuns, și când joci pe un nivel: butonul spune unde
	# te-ar duce.
	buton_trepte.text = "Treapta %d" % (treapta if treapta > 0 else maxi(_treapta, 1))
	_zugraveste_alegerea(buton_trepte, treapta > 0)


func _zugraveste_alegerea(buton: Button, ales: bool) -> void:
	if ales:
		buton.add_theme_stylebox_override("normal", _stil_buton(Color(1, 1, 1, 0.2)))
		buton.add_theme_color_override("font_color", CULOARE_TEXT)
	else:
		_imbraca_buton_stins(buton)


func _construieste_tastele() -> void:
	for copil in rand_taste.get_children():
		copil.queue_free()
	buton_inapoi = _buton("Înapoi", 96)
	buton_inapoi.pressed.connect(inapoi)
	rand_taste.add_child(buton_inapoi)
	buton_reia = _buton("Reia", 96)
	buton_reia.pressed.connect(reia)
	rand_taste.add_child(buton_reia)


func _buton(text: String, latime: int, inaltime := INALTIME_TASTA) -> Button:
	var buton := Button.new()
	buton.text = text
	buton.custom_minimum_size = Vector2(latime, inaltime)
	buton.add_theme_font_size_override("font_size", MARIME_TASTA)
	# Fără focus, din motivul de la Sudoku: un buton cu focus mănâncă tastele.
	buton.focus_mode = Control.FOCUS_NONE
	_imbraca_buton_stins(buton)
	return buton


func _imbraca_buton_stins(buton: Button) -> void:
	buton.add_theme_stylebox_override("normal", _stil_buton(Color(1, 1, 1, 0.05)))
	buton.add_theme_stylebox_override("hover", _stil_buton(Color(1, 1, 1, 0.14)))
	buton.add_theme_stylebox_override("pressed", _stil_buton(Color(1, 1, 1, 0.2)))
	for nume in ["font_color", "font_hover_color", "font_pressed_color"]:
		buton.add_theme_color_override(nume, CULOARE_BUTON)


func _stil_buton(culoare: Color) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = culoare
	stil.corner_radius_top_left = 3
	stil.corner_radius_top_right = 3
	stil.corner_radius_bottom_left = 3
	stil.corner_radius_bottom_right = 3
	stil.border_color = CULOARE_CHENAR
	stil.set_border_width_all(1)
	return stil


# ─────────────────────────────────────────────────────────────
# CE SE SCRIE PE DISC
#
# Doar treapta. Nici „joci pe trepte?" (o alegere de azi, nu un progres), nici
# nivelul ales — exact ce ține minte Sudoku: nimic. O cheie a MESEI în
# `permanent.json`, din motivul scris la `DECRETUL` în `arhiva.gd`.
# ─────────────────────────────────────────────────────────────

static func spre_dictionar() -> Dictionary:
	return {"treapta": _treapta}


## Citit strâmb, ca peste tot: lipsă sau ceva ce nu e un număr pozitiv = treapta 1.
static func din_dictionar(date: Dictionary) -> void:
	var t = date.get("treapta")
	_treapta = maxi(int(t), 1) if (t is int or t is float) else 1

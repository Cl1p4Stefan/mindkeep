extends Node
## EXPEDIȚIA — tot ce ține o serie de lupte laolaltă.
##
## E autoload din exact motivul pentru care sunt și `Tezaur`, și `Sac`: o
## expediție trece prin mai multe SCENE (hartă → luptă → hartă → luptă…), iar
## tot ce ar fi ținut în oricare dintre ele ar dispărea la prima schimbare.
##
## ─────────────────────────────────────────────────────────────
## CUM E STRUCTURATĂ STAREA, ȘI DE CE AȘA
##
## Ăsta e fișierul care se va salva la pasul 8, deci forma lui contează mai
## mult decât codul din el. Trei reguli au decis tot ce urmează:
##
## 1. **STAREA E DATE, NU NODURI.** Nicăieri mai jos nu există o referință
##    către un Button, un Control sau o scenă. Harta e un Array de
##    dicționare; ecranul o DESENEAZĂ, dar nu o ține. Dacă starea ar fi
##    ținută în noduri de interfață, „salvează expediția" ar însemna
##    „salvează o bucată de scenă" — imposibil de scris în JSON și imposibil
##    de citit peste un an.
##
## 2. **TOTUL E TIP SIMPLU.** int, float, bool, String, Array, Dictionary.
##    Niciun `Color`, niciun `Vector2`, niciun `PackedScene`. Astea sunt
##    lucruri de DESENAT, nu de reținut — culoarea unei discipline se ia din
##    catalog, după cheie, în clipa desenării. Așa `spre_dictionar()` de la
##    final e o simplă copiere, nu o conversie cu douăzeci de cazuri.
##
## 3. **LEGĂTURILE SUNT CHEI TEXT ȘI INDICI, NU OBIECTE.** Loadout-ul ține
##    `["memorie", "logica"]`, nu fișele disciplinelor. Un nod ține `"spre":
##    [3, 4]`, nu nodurile următoare. Un save e o fotografie, iar o fotografie
##    nu poate conține obiecte vii.
##
## ─────────────────────────────────────────────────────────────
## CE SE SALVEAZĂ, PE TREI STRATURI
##
## Nu tot ce ține de joc are aceeași durată de viață, iar asta e prima decizie
## a oricărui save:
##
##   PERMANENT     — `Tezaur` (Fragmentele). Rămâne după ce expediția se
##                   încheie, oricum s-ar încheia. Nu e aici.
##   PE EXPEDIȚIE  — TOT ce e mai jos: harta, unde ești, PV-ul, loadout-ul,
##                   statisticile. Plus `Sac` (ce întrebări s-au pus deja) —
##                   de-aia `incepe()` cheamă `Sac.expeditie_noua()`.
##   PE LUPTĂ      — runda, PA, ceasul inamicului, lanțul. Trăiește în
##                   `lupta.gd` și moare cu lupta. Nu se salvează: dacă
##                   închizi jocul în mijlocul unei lupte, expediția se
##                   reia de la nodul ăla, nu din mijlocul turei 3.
##
## Despărțirea asta e ce face ca save-ul să fie o problemă mică mai târziu.

## Tipurile de nod. `enum` = nume pentru numere, ca să nu scrii cifre.
## Pe disc se scriu CHEI TEXT (vezi `DATE_NOD`), fiindcă valoarea unui enum e
## doar poziția lui în listă: un tip nou adăugat la mijloc ar muta numerele și
## un save vechi ar citi Odihna ca Eveniment.
enum Nod {
	LUPTA,       ## inamic obișnuit
	ELITA,       ## mai greu, răsplată mai mare
	ODIHNA,      ## singurul loc în care PV-ul se întoarce
	EVENIMENT,   ## placeholder: marcat pe hartă, fără conținut încă
}

## FIȘA fiecărui tip de nod. Tabel, nu ramuri în cod: harta desenează de aici
## și nu conține niciun `if tip == ...`. Un tip nou (magazin, comoară) e un
## rând în plus, plus ce face el la vizitare.
##
## „cheie" e numele pe disc. „simbol" e ce se vede în cerculețul de pe hartă.
const DATE_NOD := {
	Nod.LUPTA: {
		"cheie": "lupta", "nume": "Lupta", "simbol": "X",
		"culoare": Color(0.82, 0.82, 0.90),
		"descriere": "Un adversar obisnuit iti taie drumul.",
	},
	Nod.ELITA: {
		"cheie": "elita", "nume": "Elita", "simbol": "!",
		"culoare": Color(1.00, 0.55, 0.45),
		"descriere": "Mai mult PV, lovituri mai grele — si o rasplata pe masura.",
	},
	Nod.ODIHNA: {
		"cheie": "odihna", "nume": "Odihna", "simbol": "+",
		"culoare": Color(0.55, 0.95, 0.65),
		"descriere": "Singurul loc din expeditie in care regele isi revine.",
	},
	Nod.EVENIMENT: {
		"cheie": "eveniment", "nume": "Eveniment", "simbol": "?",
		"culoare": Color(0.75, 0.70, 1.00),
		"descriere": "Ceva se va intampla aici. Deocamdata, doar trecem.",
	},
}

# ─────────────────────────────────────────────────────────────
# REGULILE EXPEDIȚIEI
# ─────────────────────────────────────────────────────────────

## N-ul din „alege N din M". M e `Discipline.cate()`.
## CLAUDE.md: „Numărul 3 e variabilă de reglat, nu presupunere."
const DISCIPLINE_IN_LOADOUT := 3

## PV-ul regelui la pornirea expediției. NU se reface între lupte — doar la
## Odihnă. Asta e regula care transformă un șir de lupte într-o expediție:
## fără ea, fiecare nod ar fi un meci separat și drumul n-ar mai conta.
const PV_MAX := 15

## Cât recuperezi la un nod de Odihnă, ca fracțiune din maxim.
## Procent, nu cifră fixă: când PV_MAX va crește din upgrade-uri de cetate,
## odihna crește odată cu el, fără să umble nimeni la ea.
const ODIHNA_FRACTIUNE := 0.35

## Câte STRATURI are harta. Straturile hotărăsc numărul de noduri:
## primul și ultimul au câte unul, cele din mijloc câte două.
##   5 straturi → 1 + 2 + 2 + 2 + 1 =  8 noduri
##   6 straturi → 1 + 2 + 2 + 2 + 2 + 1 = 10 noduri
const STRATURI_MIN := 5
const STRATURI_MAX := 6

## Câte noduri are un strat din mijloc. Două = o alegere reală la fiecare pas,
## fără ca harta să devină un păienjeniș pe care nu-l mai citești dintr-o
## privire. Când va exista o expediție lungă, ăsta e numărul care crește.
const NODURI_PE_STRAT := 2

# ─────────────────────────────────────────────────────────────
# BUGETUL DE DIFICULTATE
#
# Fiecare nod primește un BUGET, care crește cu adâncimea. Azi el face două
# lucruri: alege tipul nodului și, mai târziu, spune luptei cât de tare poate
# fi inamicul. Mâine (pasul 10, generatorul de inamici) tot el va cumpăra
# modificatori: „+50% PV" costă atât, „lovește de două ori" costă atât.
#
# De ce un BUGET și nu un „nivel 1-2-3": un număr continuu se poate împărți.
# Un nod de adâncime 4 cu buget 3,2 poate lua un inamic de 2 plus un
# modificator de 1, sau unul de 3 simplu. Un „nivel 2" nu poate cumpăra nimic,
# poate doar să fie.
#
# Scris acum, cât e ieftin, fiindcă e greu de introdus într-un generator care
# funcționează deja fără el.
# ─────────────────────────────────────────────────────────────
const BUGET_BAZA := 1.0
const BUGET_PE_ADANCIME := 0.55
const BUGET_ELITA := 1.8   ## multiplicatorul pe care Elita îl pune peste buget

## PONDERILE tipurilor de nod, ca tabel. Ponderea finală a unui tip e
## `pondere + pe_adancime * adancime`, tăiată la zero.
##
## Cifrele spun o poveste, și merită citită așa: LUPTA pornește dominantă și
## scade; ELITA pornește imposibilă (0) și devine probabilă spre final;
## ODIHNA e rară la început (n-ai ce recupera) și crește pe măsură ce
## expediția te macină; EVENIMENTul e constant, fiindcă nu e o chestiune de
## dificultate.
const PONDERI_NOD := [
	{"tip": Nod.LUPTA, "pondere": 6.0, "pe_adancime": -0.6},
	{"tip": Nod.ELITA, "pondere": -0.5, "pe_adancime": 0.7},
	{"tip": Nod.ODIHNA, "pondere": 0.2, "pe_adancime": 0.5},
	{"tip": Nod.EVENIMENT, "pondere": 1.8, "pe_adancime": 0.0},
]

# ─────────────────────────────────────────────────────────────
# STAREA (tot ce se salvează)
# ─────────────────────────────────────────────────────────────

## Emis când orice se schimbă: PV, poziție, statistici. Cârligul pentru harta
## care trebuie redesenată după ce te întorci dintr-o luptă.
signal s_a_schimbat

## E o expediție în desfășurare? `false` înseamnă „ești în meniu / la sumar".
var activa := false

## Sămânța din care s-a generat harta. SE SALVEAZĂ, și ăsta e tot rostul ei:
## cu aceeași sămânță iese exact aceeași hartă, deci un bug raportat ca
## „expediția 12345 se blochează la nodul 6" e reproductibil pe loc.
var samanta := 0

## Harta: un Array de dicționare, fiecare cu forma
##   { "id": 3, "adancime": 2, "coloana": 0, "tip": Nod.LUPTA,
##     "buget": 2.1, "samanta": 88123, "spre": [5, 6] }
##
## „spre" ține INDICI, nu noduri. Un nod care și-ar ține vecinii ca obiecte ar
## fi un graf de referințe încrucișate — imposibil de scris în JSON fără să-l
## desfaci oricum în indici.
##
## „samanta" e a nodului, nu a hărții: lupta de la nodul 6 își alege inamicul
## din ea, deci alege ACELAȘI inamic de fiecare dată când reiei expediția —
## fără ca expediția să fie nevoită să știe ce e un inamic.
var harta: Array[Dictionary] = []

## Unde ești. `-1` = încă n-ai intrat pe hartă (ești la loadout).
var pozitie := -1

## Drumul parcurs, în ordine. E ȘI istoricul pentru ecranul de sumar, ȘI
## sursa lui „ce noduri sunt în urma mea" pentru desenarea hărții.
var parcurse: Array[int] = []

## Cheile disciplinelor alese. Text, nu indici: vezi antetul lui
## `discipline.gd` pentru de ce.
var loadout: Array[String] = []

## PV-ul regelui, purtat de la un nod la altul. AICI, nu în `lupta.gd`, și
## asta e toată regula „PV-ul nu se reface între lupte": lupta îl citește la
## început și îl scrie înapoi la sfârșit, dar nu-l deține.
var pv := 0
var pv_max := PV_MAX

## Ce a produs expediția asta. Separat de `Tezaur`, care ține totalul
## permanent: ecranul de sumar vrea să spună „ai câștigat 84 în expediția
## asta", nu „ai 312 cu totul".
var fragmente_castigate := 0

## Cea mai bună performanță din run, pentru sumar. Un dicționar, nu patru
## variabile, din același motiv pentru care `Tezaur` e un dicționar: o
## statistică nouă e o cheie, nu un drum prin tot fișierul.
var recorduri := {
	"lupte_castigate": 0,
	"cel_mai_lung_lant": 0,
	"critice": 0,
	"daune_intr_o_lupta": 0,
}

## Cum s-a încheiat: "" cât e în desfășurare, "victorie" sau "infrangere" după.
var final := ""


func _ready() -> void:
	goleste()


# ─────────────────────────────────────────────────────────────
# CICLUL DE VIAȚĂ
# ─────────────────────────────────────────────────────────────

## Starea „nicio expediție". Pornim de aici la fiecare joc nou.
func goleste() -> void:
	activa = false
	samanta = 0
	harta.clear()
	pozitie = -1
	parcurse.clear()
	loadout.clear()
	pv = PV_MAX
	pv_max = PV_MAX
	fragmente_castigate = 0
	recorduri = {
		"lupte_castigate": 0,
		"cel_mai_lung_lant": 0,
		"critice": 0,
		"daune_intr_o_lupta": 0,
	}
	final = ""


## Pornește o expediție nouă.
##
## `samanta_ceruta` = 0 înseamnă „alege una la întâmplare, dar ȚINE-O MINTE".
## Asta e diferența dintre un joc care se poate depana și unul care nu se
## poate: fiecare expediție are o sămânță, chiar și cele „aleatoare". Ca s-o
## reproduci, o citești din jurnal și o dai înapoi aici.
func incepe(discipline: Array[String], samanta_ceruta := 0) -> void:
	goleste()

	samanta = samanta_ceruta
	if samanta == 0:
		samanta = randi_range(1, 999999)

	loadout = _curata_loadout(discipline)
	harta = genereaza_harta(samanta)
	pozitie = -1
	pv = pv_max
	activa = true
	final = ""

	# Întrebările redevin toate noi. Expediția e exact granița pe care `Sac` o
	# aștepta (vezi `autoload/sac.gd`): aici se naște noțiunea de „expediție
	# nouă", deci aici se cheamă.
	Sac.expeditie_noua()

	print("Expeditie noua: samanta %d, %d noduri, loadout %s." % [
		samanta, harta.size(), ", ".join(loadout)
	])
	s_a_schimbat.emit()


## Intră în nodul cu indicele dat. Cheamă-l DOAR cu un nod din `accesibile()`.
func intra_in_nod(id: int) -> void:
	if id < 0 or id >= harta.size():
		push_warning("Expeditie: nod inexistent %d." % id)
		return
	pozitie = id
	parcurse.append(id)
	s_a_schimbat.emit()


## Încheie expediția. `victorie` = ai ajuns la capăt; altfel PV-ul a ajuns 0.
##
## NU golește starea: ecranul de sumar are nevoie de ea ca s-o poată arăta.
## Golirea vine abia când pornește următoarea expediție (`incepe()` cheamă
## `goleste()` pe prima linie). Regula generală: o stare se șterge când începe
## următoarea, nu când se termină cea de dinainte — altfel n-ai ce afișa
## între ele.
func incheie(victorie: bool) -> void:
	activa = false
	final = "victorie" if victorie else "infrangere"
	s_a_schimbat.emit()


# ─────────────────────────────────────────────────────────────
# NAVIGAREA
# ─────────────────────────────────────────────────────────────

## Nodul în care ești acum. Dicționar gol dacă n-ai intrat în niciunul.
func nod_curent() -> Dictionary:
	if pozitie < 0 or pozitie >= harta.size():
		return {}
	return harta[pozitie]


## În ce noduri poți intra ACUM.
##
## La început (`pozitie == -1`) sunt toate nodurile de adâncime 0 — adică
## intrarea pe hartă. După aceea, exact ce scrie în „spre" la nodul curent.
## Lista goală înseamnă „ai ajuns la capăt": vezi `la_capat()`.
func accesibile() -> Array[int]:
	var lista: Array[int] = []
	if pozitie < 0:
		for nod in harta:
			if int(nod["adancime"]) == 0:
				lista.append(int(nod["id"]))
		return lista
	for id in nod_curent().get("spre", []):
		lista.append(int(id))
	return lista


## Ai terminat drumul? (Ultimul nod n-are unde să ducă.)
func la_capat() -> bool:
	return pozitie >= 0 and accesibile().is_empty()


## Câte straturi are harta. Folosit de ecran ca să deseneze rândurile.
func adancime_maxima() -> int:
	var maxim := 0
	for nod in harta:
		maxim = maxi(maxim, int(nod["adancime"]))
	return maxim


# ─────────────────────────────────────────────────────────────
# PV — o singură ușă, ca daunele din luptă
# ─────────────────────────────────────────────────────────────

## Scrie PV-ul întors din luptă. Lupta ține o copie cât se luptă (ca să nu
## emită un semnal la fiecare lovitură), apoi o predă aici, o dată.
func seteaza_pv(valoare: int) -> void:
	pv = clampi(valoare, 0, pv_max)
	s_a_schimbat.emit()


## Odihna. Întoarce cât s-a recuperat DE FAPT, ca ecranul să poată scrie
## „+5 PV" fără să facă el socoteala și fără să poată ajunge la alt număr.
func odihneste() -> int:
	var inainte := pv
	pv = mini(pv + ceili(pv_max * ODIHNA_FRACTIUNE), pv_max)
	s_a_schimbat.emit()
	return pv - inainte


func e_doborat() -> bool:
	return pv <= 0


# ─────────────────────────────────────────────────────────────
# REZULTATUL UNEI LUPTE
# ─────────────────────────────────────────────────────────────

## Ce raportează lupta după o victorie. Un singur apel, cu un dicționar, în
## loc de cinci funcții: când lupta va avea a șasea statistică, semnătura nu
## se schimbă.
func inregistreaza_lupta(raport: Dictionary) -> void:
	recorduri["lupte_castigate"] = int(recorduri["lupte_castigate"]) + 1
	# `maxi` fiindcă astea sunt RECORDURI, nu totaluri: „cel mai lung lanț din
	# expediție" e cel mai lung dintre lupte, nu suma lor.
	recorduri["cel_mai_lung_lant"] = maxi(
		int(recorduri["cel_mai_lung_lant"]), int(raport.get("cel_mai_lung_lant", 0)))
	recorduri["daune_intr_o_lupta"] = maxi(
		int(recorduri["daune_intr_o_lupta"]), int(raport.get("daune", 0)))
	# Criticele se ADUNĂ: aici întrebarea e „câte ai dat în tot runul", nu
	# „care a fost cea mai bună luptă". Două statistici, două feluri de a
	# aduna — de-aia stau într-un tabel și nu într-o buclă care le tratează la fel.
	recorduri["critice"] = int(recorduri["critice"]) + int(raport.get("critice", 0))
	s_a_schimbat.emit()


## Fragmentele intră ȘI în tezaurul permanent, ȘI în socoteala expediției.
## Un singur loc care face amândouă, ca să nu poată ajunge să difere.
func incaseaza(resursa: Tezaur.Resursa, cantitate: int) -> void:
	if cantitate <= 0:
		return
	Tezaur.adauga(resursa, cantitate)
	if resursa == Tezaur.Resursa.FRAGMENTE:
		fragmente_castigate += cantitate
	s_a_schimbat.emit()


# ─────────────────────────────────────────────────────────────
# GENERAREA HĂRȚII
#
# Totul de aici trece printr-un `RandomNumberGenerator` cu sămânță pusă de
# mână — NU prin `randi()` global. Diferența e tot ce contează: `randi()`
# depinde de câte numere a cerut restul jocului înainte, deci aceeași sămânță
# ar da hărți diferite după o luptă mai lungă. Un generator propriu nu aude
# nimic din afară.
# ─────────────────────────────────────────────────────────────

## Construiește harta din sămânță. `static` fiindcă nu atinge starea: îi dai o
## sămânță, îți dă noduri. Așa se poate testa fără să pornești o expediție.
static func genereaza_harta(samanta_harta: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = samanta_harta

	var straturi := rng.randi_range(STRATURI_MIN, STRATURI_MAX)
	var noduri: Array[Dictionary] = []
	# „Cine e pe stratul de dinainte" — avem nevoie de indicii lor ca să
	# tragem muchiile înapoi, după ce stratul nou e construit.
	var stratul_trecut: Array[int] = []

	for adancime in range(straturi):
		# Primul și ultimul strat au un singur nod: expediția pornește dintr-un
		# punct și se termină într-unul. Fără asta, „ai ajuns la capăt" ar fi
		# două capete diferite, iar finalul ar depinde de coloana pe care ai mers.
		var cate := NODURI_PE_STRAT
		if adancime == 0 or adancime == straturi - 1:
			cate = 1

		var stratul_nou: Array[int] = []
		for coloana in range(cate):
			var id := noduri.size()
			var buget := BUGET_BAZA + BUGET_PE_ADANCIME * adancime
			var tip := _alege_tip(rng, adancime, straturi)
			if tip == Nod.ELITA:
				buget *= BUGET_ELITA
			noduri.append({
				"id": id,
				"adancime": adancime,
				"coloana": coloana,
				"tip": tip,
				"buget": snappedf(buget, 0.01),
				# Sămânța nodului, trasă din același rng: reproductibilă, dar
				# independentă de ce va cere lupta din ea.
				"samanta": rng.randi_range(1, 999999),
				"spre": [],
			})
			stratul_nou.append(id)

		if not stratul_trecut.is_empty():
			_leaga(rng, noduri, stratul_trecut, stratul_nou)
		stratul_trecut = stratul_nou

	return noduri


## Ce fel de nod e ăsta.
##
## Primul strat e MEREU o luptă obișnuită: o expediție care începe cu odihnă
## („n-ai ce odihni") sau cu o elită („n-ai apucat să înveți nimic") pornește
## prost, indiferent ce spun ponderile. Ultimul e MEREU elită: ăla e finalul,
## și un final trebuie să fie ceva.
##
## Restul se trage din `PONDERI_NOD`, cu ponderile crescute de adâncime.
static func _alege_tip(rng: RandomNumberGenerator, adancime: int, straturi: int) -> Nod:
	if adancime == 0:
		return Nod.LUPTA
	if adancime == straturi - 1:
		return Nod.ELITA

	# „Roata norocului": fiecare tip primește o felie cât ponderea lui, apoi
	# aruncăm o singură dată în tot cercul. Ponderea zero = felie inexistentă,
	# deci tipul pur și simplu nu poate ieși.
	var total := 0.0
	for rand in PONDERI_NOD:
		total += _pondere(rand, adancime)
	if total <= 0.0:
		return Nod.LUPTA   # plasă de siguranță: ponderi prost reglate

	var aruncare := rng.randf() * total
	for rand in PONDERI_NOD:
		aruncare -= _pondere(rand, adancime)
		if aruncare <= 0.0:
			return rand["tip"]
	return Nod.LUPTA


## Ponderea unui tip la adâncimea dată, tăiată la zero.
static func _pondere(rand: Dictionary, adancime: int) -> float:
	return maxf(0.0, float(rand["pondere"]) + float(rand["pe_adancime"]) * adancime)


## Trage muchiile dintre două straturi vecine.
##
## Regula are două jumătăți, și a doua e cea care face harta jucabilă:
##   1. fiecare nod de sus primește 1-2 urmași, la întâmplare;
##   2. apoi REPARĂM: orice nod de jos rămas fără niciun părinte primește
##      unul. Fără pasul 2, generatorul ar putea produce un nod în care nu se
##      poate ajunge — adică o bucată de hartă desenată degeaba, și, dacă
##      nimereai prost, un drum înfundat.
static func _leaga(
	rng: RandomNumberGenerator,
	noduri: Array[Dictionary],
	sus: Array[int],
	jos: Array[int]
) -> void:
	for id_sus in sus:
		var cati := 1 if jos.size() == 1 else rng.randi_range(1, jos.size())
		var candidati := jos.duplicate()
		# `shuffle` pe un rng cu sămânță — nu `Array.shuffle()`, care folosește
		# generatorul global și ar rupe reproductibilitatea.
		_amesteca(rng, candidati)
		var legaturi: Array = noduri[id_sus]["spre"]
		for i in range(cati):
			legaturi.append(candidati[i])
		legaturi.sort()

	# Reparația.
	for id_jos in jos:
		var are_parinte := false
		for id_sus in sus:
			if id_jos in noduri[id_sus]["spre"]:
				are_parinte = true
				break
		if not are_parinte:
			var parinte: int = sus[rng.randi_range(0, sus.size() - 1)]
			var legaturi: Array = noduri[parinte]["spre"]
			legaturi.append(id_jos)
			legaturi.sort()


## Amestecare cu generator propriu (Fisher-Yates). `Array.shuffle()` n-ar
## merge: el folosește generatorul global, iar atunci harta n-ar mai fi
## reproductibilă din sămânță.
static func _amesteca(rng: RandomNumberGenerator, lista: Array) -> void:
	for i in range(lista.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = lista[i]
		lista[i] = lista[j]
		lista[j] = tmp


## Loadout curățat: doar chei care există, fără dubluri, cel mult N.
## Completat din catalog dacă a venit prea scurt — un loadout incomplet ar
## însemna o luptă cu două Obeliscuri, fără ca nimeni să fi cerut asta.
static func _curata_loadout(cerute: Array[String]) -> Array[String]:
	var curat: Array[String] = []
	for cheie in cerute:
		if curat.size() >= DISCIPLINE_IN_LOADOUT:
			break
		if Discipline.exista(cheie) and not (cheie in curat):
			curat.append(cheie)
	for cheie in Discipline.chei():
		if curat.size() >= DISCIPLINE_IN_LOADOUT:
			break
		if not (cheie in curat):
			curat.append(cheie)
	return curat


# ─────────────────────────────────────────────────────────────
# SALVARE
#
# Oglinda celor trei reguli din antet: fiindcă starea e deja numai tipuri
# simple, funcțiile astea două n-au de făcut nicio conversie complicată.
# Singura traducere reală e `Nod` → cheie text și înapoi.
# ─────────────────────────────────────────────────────────────

func spre_dictionar() -> Dictionary:
	var noduri: Array = []
	for nod in harta:
		var copie := nod.duplicate(true)
		copie["tip"] = DATE_NOD[nod["tip"]]["cheie"]   # enum → text
		noduri.append(copie)
	return {
		"activa": activa,
		"samanta": samanta,
		"harta": noduri,
		"pozitie": pozitie,
		"parcurse": parcurse.duplicate(),
		"loadout": loadout.duplicate(),
		"pv": pv,
		"pv_max": pv_max,
		"fragmente_castigate": fragmente_castigate,
		"recorduri": recorduri.duplicate(true),
		"final": final,
	}


func din_dictionar(date: Dictionary) -> void:
	goleste()
	samanta = int(date.get("samanta", 0))
	pozitie = int(date.get("pozitie", -1))
	pv = int(date.get("pv", PV_MAX))
	pv_max = int(date.get("pv_max", PV_MAX))
	fragmente_castigate = int(date.get("fragmente_castigate", 0))
	final = String(date.get("final", ""))
	activa = bool(date.get("activa", false))

	for cheie in date.get("loadout", []):
		loadout.append(String(cheie))
	for id in date.get("parcurse", []):
		parcurse.append(int(id))
	for cheie in recorduri:
		recorduri[cheie] = int(date.get("recorduri", {}).get(cheie, 0))

	for brut in date.get("harta", []):
		var nod: Dictionary = (brut as Dictionary).duplicate(true)
		nod["tip"] = _tip_din_cheie(String(nod.get("tip", "lupta")))
		# JSON întoarce toate numerele ca float. Convertim o dată, aici, ca
		# restul codului să lucreze liniștit cu int-uri (un float nu poate
		# indexa un Array).
		for camp in ["id", "adancime", "coloana", "samanta"]:
			nod[camp] = int(nod.get(camp, 0))
		nod["buget"] = float(nod.get("buget", BUGET_BAZA))
		var spre: Array = []
		for id in nod.get("spre", []):
			spre.append(int(id))
		nod["spre"] = spre
		harta.append(nod)

	s_a_schimbat.emit()


## Cheie text → enum. O cheie necunoscută (un tip de nod șters între versiuni)
## devine Luptă, în loc să oprească încărcarea: un save vechi trebuie să se
## deschidă chiar și strâmb.
static func _tip_din_cheie(cheie: String) -> Nod:
	for tip in DATE_NOD:
		if DATE_NOD[tip]["cheie"] == cheie:
			return tip
	return Nod.LUPTA

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
##    ținută în noduri de interfață, „salvează expediția” ar însemna
##    „salvează o bucată de scenă” — imposibil de scris în JSON și imposibil
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
	MAGAZIN,     ## singurul loc în care Monedele se transformă în ceva
	BOSS,        ## capătul drumului, mai greu decât o Elită
}

## FIȘA fiecărui tip de nod. Tabel, nu ramuri în cod: harta desenează de aici
## și nu conține niciun `if tip == ...`. Un tip nou (comoară, altar) e un rând
## în plus, plus ce face el la vizitare.
##
## CE ÎNSEAMNĂ FIECARE COLOANĂ:
##   cheie        — numele pe disc (vezi nota de la `enum Nod`)
##   nume         — ce scrie pe etichetă când survolezi nodul
##   descriere    — ce te așteaptă acolo, într-o propoziție
##   culoare      — HALOUL din spatele simbolului. Nu e decor: craniul Elitei
##                  și coiful Luptei sunt forme apropiate la 90 de pixeli, iar
##                  culoarea din spate e ce le desparte dintr-o privire.
##   putere       — cât de tare lovește inamicul de-acolo, ca înmulțitor peste
##                  cifrele lui din tabelul luptei
##   buget        — cât de SCUMP poate fi inamicul ales acolo (cine încape)
##   monede       — câte Monede cad la o victorie
##   bonus        — Fragmente în plus, o singură dată, pentru un nod greu
##
## „putere” și „buget” sunt două lucruri diferite, și merită două coloane:
## bugetul alege CINE apare (un Spadasin în loc de un Soldat), puterea îl umflă
## pe cel apărut. Un nod de Boss are nevoie de amândouă — cel mai scump adversar
## disponibil, și încă o dată pe-atât peste el.
const DATE_NOD := {
	Nod.LUPTA: {
		"cheie": "lupta", "nume": "Lupta",
		"descriere": "Un adversar obisnuit iti taie drumul.",
		"culoare": Color(0.96, 0.93, 0.86),
		"putere": 1.0, "buget": 1.0, "monede": 8, "bonus": 0,
	},
	Nod.ELITA: {
		"cheie": "elita", "nume": "Elita",
		"descriere": "Mai mult PV, lovituri mai grele — si o rasplata pe masura.",
		"culoare": Color(1.00, 0.62, 0.26),
		"putere": 1.6, "buget": 1.8, "monede": 16, "bonus": 12,
	},
	Nod.ODIHNA: {
		"cheie": "odihna", "nume": "Odihna",
		"descriere": "Singurul loc din expeditie in care regele isi revine.",
		"culoare": Color(1.00, 0.80, 0.52),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.EVENIMENT: {
		"cheie": "eveniment", "nume": "Eveniment",
		"descriere": "Ceva se va intampla aici. Deocamdata, doar trecem.",
		"culoare": Color(0.84, 0.82, 0.96),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.MAGAZIN: {
		"cheie": "magazin", "nume": "Magazin",
		"descriere": "Un negustor pe drum. Monedele stranse se schimba aici pe ajutor — doar pentru expeditia asta.",
		"culoare": Color(1.00, 0.86, 0.38),
		"putere": 1.0, "buget": 1.0, "monede": 0, "bonus": 0,
	},
	Nod.BOSS: {
		"cheie": "boss", "nume": "Boss",
		"descriere": "Capatul drumului. Mai greu decat orice Elita — si ultimul lucru dintre tine si sumar.",
		"culoare": Color(0.92, 0.30, 0.22),
		"putere": 2.3, "buget": 2.6, "monede": 30, "bonus": 30,
	},
}


## Fișa unui tip de nod, cu plasă de siguranță: un tip necunoscut (un save
## vechi, un enum umblat) întoarce fișa Luptei în loc să oprească jocul.
static func date_nod(tip: int) -> Dictionary:
	return DATE_NOD.get(tip, DATE_NOD[Nod.LUPTA])


# ─────────────────────────────────────────────────────────────
# REGULILE EXPEDIȚIEI
# ─────────────────────────────────────────────────────────────

## N-ul din „alege N din M”. M e `Discipline.cate()`.
## CLAUDE.md: „Numărul 3 e variabilă de reglat, nu presupunere.”
const DISCIPLINE_IN_LOADOUT := 3

## PV-ul regelui la pornirea expediției. NU se reface între lupte — doar la
## Odihnă. Asta e regula care transformă un șir de lupte într-o expediție:
## fără ea, fiecare nod ar fi un meci separat și drumul n-ar mai conta.
const PV_MAX := 15

## Cât recuperezi la un nod de Odihnă, ca fracțiune din maxim.
## Procent, nu cifră fixă: când PV_MAX va crește din upgrade-uri de cetate,
## odihna crește odată cu el, fără să umble nimeni la ea.
const ODIHNA_FRACTIUNE := 0.35

## DE UNDE VINE HARTA. ← comutatorul. O singură linie de schimbat:
##
##     const SURSA_HARTII := Sursa.DESENATA    planșa din `PLANSA_IMPLICITA` (activ)
##     const SURSA_HARTII := Sursa.GENERATA    panglica + straturi, ca înainte
##
## Cele două surse răspund la întrebări diferite, și de-aia coexistă în loc să
## se înlocuiască:
##
##   GENERATA  — o hartă nouă la fiecare sămânță, garantat fără încrucișări,
##               fiindcă geometria ei e demonstrată (vezi `harta.gd`). Nu poate
##               însă desena UN LOC anume.
##   DESENATA  — forma o pui tu, cu mâna, într-un fișier. În schimb, garanția se
##               mută de la demonstrație la VERIFICARE: `tools/verifica_plansa.gd`.
##
## Ce NU se schimbă între ele: tipurile nodurilor (Luptă, Elită, Magazin…) se
## trag din sămânță în amândouă cazurile, cu aceleași reguli. Planșa dă doar
## forma; conținutul rămâne al sămânței.
enum Sursa { GENERATA, DESENATA }
const SURSA_HARTII := Sursa.DESENATA

## Ce planșă se joacă, cât timp `SURSA_HARTII` e DESENATA.
const PLANSA_IMPLICITA := Plansa.DOSAR + "harta_01.json"

## Câte STRATURI are harta. Straturile hotărăsc numărul de noduri:
## primul și ultimul au câte unul, cele din mijloc câte `NODURI_PE_STRAT`.
##   7 straturi → 1 + 2·5 + 1 = 12 noduri
##   9 straturi → 1 + 2·7 + 1 = 16 noduri
##
## Cifrele astea au crescut de la 5-6 la 7-9 dintr-un motiv de DESEN, nu de
## dificultate: pe pergamentul întins pe toată fereastra, opt noduri arătau ca
## opt puncte răzlețe, nu ca un drum. Harta de referință are paisprezece, și
## abia la densitatea aia drumul începe să pară un TRASEU pe un teren.
##
## Dacă o expediție de 16 noduri se dovedește prea lungă pentru o sesiune de
## 15 minute, aici se taie — dar se taie știind că sub 12 noduri harta redevine
## un desen sărac.
const STRATURI_MIN := 7
const STRATURI_MAX := 9

## Sub atâtea noduri nu coborâm niciodată. E o PLASĂ, nu o regulă: astăzi
## `STRATURI_MIN` garantează deja 12, dar dacă mâine cineva scade straturile
## fără să se uite aici, generatorul adaugă straturi până iese numărul.
const NODURI_MINIME := 12

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
# modificatori: „+50% PV” costă atât, „lovește de două ori” costă atât.
#
# De ce un BUGET și nu un „nivel 1-2-3”: un număr continuu se poate împărți.
# Un nod de adâncime 4 cu buget 3,2 poate lua un inamic de 2 plus un
# modificator de 1, sau unul de 3 simplu. Un „nivel 2” nu poate cumpăra nimic,
# poate doar să fie.
#
# Scris acum, cât e ieftin, fiindcă e greu de introdus într-un generator care
# funcționează deja fără el.
# ─────────────────────────────────────────────────────────────
const BUGET_BAZA := 1.0
const BUGET_PE_ADANCIME := 0.55
# Multiplicatorul de buget al unui nod greu NU mai e o constantă aici: e
# coloana „buget” din `DATE_NOD`. Elita îl avea, Bossul avea nevoie de altul,
# iar două constante cu același rost sunt începutul unei a treia.

## PONDERILE tipurilor de nod, ca tabel. Ponderea finală a unui tip e
## `pondere + pe_adancime * adancime`, tăiată la zero.
##
## Cifrele spun o poveste, și merită citită așa: LUPTA pornește dominantă și
## scade; ELITA pornește imposibilă (0) și devine probabilă spre final;
## ODIHNA e rară la început (n-ai ce recupera) și crește pe măsură ce
## expediția te macină; MAGAZINul urcă și el, fiindcă la început n-ai Monede
## cu ce cumpăra; EVENIMENTul e constant, fiindcă nu e o chestiune de
## dificultate.
##
## Pantele sunt mai blânde decât la harta de 5-6 straturi: aceeași pantă pe un
## drum de 9 straturi ar fi însemnat că ultimele trei straturi sunt numai Elite.
## Când schimbi lungimea hărții, `pe_adancime` e numărul care trebuie reglat
## odată cu ea — de-aia stă într-un tabel și nu împrăștiat prin cod.
const PONDERI_NOD := [
	{"tip": Nod.LUPTA, "pondere": 6.0, "pe_adancime": -0.40},
	{"tip": Nod.ELITA, "pondere": -0.8, "pe_adancime": 0.50},
	{"tip": Nod.ODIHNA, "pondere": 0.2, "pe_adancime": 0.30},
	{"tip": Nod.EVENIMENT, "pondere": 1.6, "pe_adancime": 0.0},
	{"tip": Nod.MAGAZIN, "pondere": 0.3, "pe_adancime": 0.26},
]

# ─────────────────────────────────────────────────────────────
# MONEDELE ȘI PUTERILE — economia care moare cu expediția
#
# Fragmentele sunt AVERE: rămân în `Tezaur` după ce runul se termină, oricum
# s-ar termina, și vor plăti clădirile cetății. Monedele sunt cu totul altceva:
# se strâng din lupte, se cheltuie la Magazin, și se evaporă la finalul
# expediției.
#
# De ce două monede și nu una: fiindcă întrebarea „ce cumpăr ACUM, cu ce am pe
# drumul ăsta" e o decizie complet diferită de „ce-mi construiesc în cetate
# peste zece runuri". Dacă ar fi aceeași resursă, a doua ar înghiți-o mereu pe
# prima — orice leu cheltuit pe un ajutor temporar ar fi un leu furat de la
# ceva permanent, deci n-ai cumpăra niciodată nimic pe drum.
#
# Monedele NU intră în `Tezaur`. Tezaurul e, prin definiție, ce supraviețuiește
# expediției; o resursă care se resetează n-are ce căuta acolo.
# ─────────────────────────────────────────────────────────────

## Ce se vinde la Magazin. Tabel, ca tot restul: o putere nouă e un rând.
##
## „efect” e cheia pe care o citește codul; restul e ce citește jucătorul.
## Puterile INSTANTANEE (PV, PV maxim) își fac treaba în clipa cumpărării și
## sunt trecute în istoric. Cele DURABILE („pa”) rămân în `puteri` și sunt
## întrebate de luptă la fiecare rundă — de-aia lista se salvează.
##
## Prețurile pornesc de la ce aduce un nod: o Luptă dă 8 Monede, o Elită 16.
## Deci „fiertura” e aproape un nod de luptă, iar „pana” e trei. Vrei ca
## alegerea de la Magazin să coste ceva, altfel nu e o alegere.
const PUTERI := [
	{
		"cheie": "pana", "nume": "Pana de otel", "cost": 24, "efect": "pa",
		"descriere": "+1 PA in fiecare runda, pana la capatul expeditiei.",
	},
	{
		"cheie": "zale", "nume": "Zale ferecate", "cost": 16, "efect": "pv_max",
		"cantitate": 4,
		"descriere": "+4 PV maxim, si tot atatia acum.",
	},
	{
		"cheie": "fiertura", "nume": "Fiertura calda", "cost": 9, "efect": "pv",
		"cantitate": 6,
		"descriere": "+6 PV pe loc. Nimic pe termen lung.",
	},
]

# ─────────────────────────────────────────────────────────────
# STAREA (tot ce se salvează)
# ─────────────────────────────────────────────────────────────

## Emis când orice se schimbă: PV, poziție, statistici. Cârligul pentru harta
## care trebuie redesenată după ce te întorci dintr-o luptă.
signal s_a_schimbat

## E o expediție în desfășurare? `false` înseamnă „ești în meniu / la sumar”.
var activa := false

## Sămânța din care s-a generat harta. SE SALVEAZĂ, și ăsta e tot rostul ei:
## cu aceeași sămânță iese exact aceeași hartă, deci un bug raportat ca
## „expediția 12345 se blochează la nodul 6” e reproductibil pe loc.
var samanta := 0

## PE CE PLANȘĂ se joacă: calea fișierului, sau "" pentru o hartă generată.
##
## E STARE, nu constantă, și ăsta e tot rostul: `SURSA_HARTII` spune ce se
## alege la pornirea unei expediții NOI, dar o expediție deja pornită trebuie să
## se deseneze pe planșa pe care a pornit — inclusiv după un save reîncărcat
## peste o lună, când comutatorul o fi fost mutat de zece ori.
##
## Text, deci serializabil. Ecranul hărții întreabă câmpul ăsta, nu constanta:
## un singur adevăr, ținut într-un singur loc.
var plansa := ""

## Harta: un Array de dicționare, fiecare cu forma
##   { "id": 3, "adancime": 2, "coloana": 0, "tip": Nod.LUPTA,
##     "buget": 2.1, "samanta": 88123, "spre": [5, 6] }
##
## Pe o hartă DESENATĂ mai apare un câmp, "reper": id-ul text al nodului din
## planșă („S”, „C3”). E firul care leagă nodul de desen — poziția LUI nu se
## ține aici, fiindcă un `Vector2` n-are ce căuta în starea care se salvează
## (vezi regula 2 din antet). Ecranul deschide aceeași planșă și caută reperul.
##
## „spre” ține INDICI, nu noduri. Un nod care și-ar ține vecinii ca obiecte ar
## fi un graf de referințe încrucișate — imposibil de scris în JSON fără să-l
## desfaci oricum în indici.
##
## „samanta” e a nodului, nu a hărții: lupta de la nodul 6 își alege inamicul
## din ea, deci alege ACELAȘI inamic de fiecare dată când reiei expediția —
## fără ca expediția să fie nevoită să știe ce e un inamic.
var harta: Array[Dictionary] = []

## Unde ești. `-1` = încă n-ai intrat pe hartă (ești la loadout).
var pozitie := -1

## Drumul parcurs, în ordine. E ȘI istoricul pentru ecranul de sumar, ȘI
## sursa lui „ce noduri sunt în urma mea” pentru desenarea hărții.
var parcurse: Array[int] = []

## Cheile disciplinelor alese. Text, nu indici: vezi antetul lui
## `discipline.gd` pentru de ce.
var loadout: Array[String] = []

## PV-ul regelui, purtat de la un nod la altul. AICI, nu în `lupta.gd`, și
## asta e toată regula „PV-ul nu se reface între lupte”: lupta îl citește la
## început și îl scrie înapoi la sfârșit, dar nu-l deține.
var pv := 0
var pv_max := PV_MAX

## Ce a produs expediția asta. Separat de `Tezaur`, care ține totalul
## permanent: ecranul de sumar vrea să spună „ai câștigat 84 în expediția
## asta", nu „ai 312 cu totul”.
var fragmente_castigate := 0

## MONEDELE din expediția curentă. Se strâng din lupte, se cheltuie la Magazin,
## și mor odată cu runul — vezi nota de la `PUTERI`.
##
## Stau AICI, nu în `Tezaur`, exact fiindcă asta e granița dintre cele două
## fișiere: tezaurul e ce rămâne, expediția e ce trece.
var monede := 0

## Ce ai cumpărat la Magazin, în ordine. Chei text, cu dubluri permise: două
## „Pene de otel” înseamnă +2 PA, iar istoricul e și ce arată sumarul.
var puteri: Array[String] = []

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

## Starea „nicio expediție”. Pornim de aici la fiecare joc nou.
func goleste() -> void:
	activa = false
	samanta = 0
	plansa = ""
	harta.clear()
	pozitie = -1
	parcurse.clear()
	loadout.clear()
	pv = PV_MAX
	pv_max = PV_MAX
	fragmente_castigate = 0
	monede = 0
	puteri.clear()
	recorduri = {
		"lupte_castigate": 0,
		"cel_mai_lung_lant": 0,
		"critice": 0,
		"daune_intr_o_lupta": 0,
	}
	final = ""


## Pornește o expediție nouă.
##
## `samanta_ceruta` = 0 înseamnă „alege una la întâmplare, dar ȚINE-O MINTE”.
## Asta e diferența dintre un joc care se poate depana și unul care nu se
## poate: fiecare expediție are o sămânță, chiar și cele „aleatoare”. Ca s-o
## reproduci, o citești din jurnal și o dai înapoi aici.
func incepe(discipline: Array[String], samanta_ceruta := 0) -> void:
	goleste()

	samanta = samanta_ceruta
	if samanta == 0:
		samanta = randi_range(1, 999999)

	loadout = _curata_loadout(discipline)
	plansa = _plansa_de_jucat()
	harta = genereaza_harta(samanta, plansa)
	pozitie = -1
	pv = pv_max
	activa = true
	final = ""

	# Întrebările redevin toate noi. Expediția e exact granița pe care `Sac` o
	# aștepta (vezi `autoload/sac.gd`): aici se naște noțiunea de „expediție
	# nouă", deci aici se cheamă.
	Sac.expeditie_noua()

	print("Expeditie noua: samanta %d, %d noduri, harta %s, loadout %s." % [
		samanta, harta.size(),
		plansa.get_file() if plansa != "" else "generata",
		", ".join(loadout)
	])
	s_a_schimbat.emit()


## CE PLANȘĂ SE JOACĂ ACUM — sau "" dacă harta se generează.
##
## Comutatorul spune ce vrem; funcția asta verifică dacă se poate. O planșă
## lipsă sau stricată NU are voie să oprească jocul: te întorci la generator,
## cu un avertisment în consolă. Un fișier de date prost scris e o greșeală de
## conținut, iar jocul trebuie să supraviețuiască greșelilor de conținut — altfel
## o virgulă uitată în JSON înseamnă „jocul nu mai pornește”.
static func _plansa_de_jucat() -> String:
	if SURSA_HARTII != Sursa.DESENATA:
		return ""
	var citita := Plansa.incarca(PLANSA_IMPLICITA)
	var eroare := String(citita["eroare"])
	if eroare == "":
		return PLANSA_IMPLICITA
	push_warning("Plansa %s nu se poate citi: %s. Harta se genereaza."
		% [PLANSA_IMPLICITA, eroare])
	return ""


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
## intrarea pe hartă. După aceea, exact ce scrie în „spre” la nodul curent.
## Lista goală înseamnă „ai ajuns la capăt”: vezi `la_capat()`.
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


## `adancime_maxima()` A DISPĂRUT de aici, și merită spus de ce, fiindcă e genul
## de funcție care pare nevinovată.
##
## Avea doi apelanți, amândoi în antetul hărții, amândoi ca să scrie „din câte
## noduri". Pe harta generată răspunsul era corect: toate traseele aveau exact
## câte un nod pe strat. Pe o planșă desenată, aceeași funcție ar fi răspuns „cel
## mai depărtat nod de Start" — un număr care ARATĂ ca lungimea drumului și nu e.
##
## Puteam s-o las, cu un comentariu de avertisment. Dar o funcție nefolosită al
## cărei nume minte e o capcană pusă pentru mine peste șase luni. Ce răspunde
## acum la aceeași nevoie e `pasi_pana_la_boss()`, de mai jos, care e adevărată
## pe orice hartă.


## Care nod e Bossul. `-1` dacă n-are (n-ar trebui să se întâmple).
##
## Se caută după TIP, nu după poziția în listă. Pe harta generată Bossul e
## ultimul nod și s-ar fi putut lua așa; pe o planșă desenată, „ultimul din
## listă" și „capătul drumului” sunt două lucruri care se nimeresc să coincidă,
## iar codul n-are voie să se sprijine pe o coincidență.
func id_boss() -> int:
	for nod in harta:
		if int(nod["tip"]) == Nod.BOSS:
			return int(nod["id"])
	return -1


## CÂȚI PAȘI MAI SUNT PÂNĂ LA BOSS, pe cel mai scurt drum.
##
## Înlocuiește vechiul „nodul 4 din 12” din antet, și motivul e că întrebarea
## veche n-are răspuns pe o hartă desenată. Pe harta generată toate traseele
## aveau exact atâtea noduri câte straturi, deci „din 12” era adevărat oricum ai
## fi mers. Pe o planșă, un traseu are 7 noduri și altul 9 — iar un antet care
## ar scrie „din 9” cât mergi pe drumul de 7 ar minți cu fiecare pas.
##
## „La cel puțin 3 pași” e adevărat pe orice hartă, pe orice drum. Pe harta
## generată dă exact numărul vechi (straturi rămase), deci nu s-a pierdut nimic
## din informație — s-a pierdut doar presupunerea că toate drumurile sunt egale.
##
## Tot un BFS, ca la adâncimi, dar pornit din nodul CURENT. Înainte de intrarea
## pe hartă (`pozitie == -1`) pornește din prima intrare.
func pasi_pana_la_boss() -> int:
	var tinta := id_boss()
	if tinta < 0:
		return 0

	var pornire := pozitie
	if pornire < 0:
		var intrari := accesibile()
		if intrari.is_empty():
			return 0
		pornire = intrari[0]

	var pasi := {pornire: 0}
	var coada: Array[int] = [pornire]
	var i := 0
	while i < coada.size():
		var aici: int = coada[i]
		i += 1
		if aici == tinta:
			return int(pasi[aici])
		for id in harta[aici].get("spre", []):
			var urmator := int(id)
			if not pasi.has(urmator):
				pasi[urmator] = int(pasi[aici]) + 1
				coada.append(urmator)
	return 0


# ─────────────────────────────────────────────────────────────
# PV — o singură ușă, ca daunele din luptă
# ─────────────────────────────────────────────────────────────

## Scrie PV-ul întors din luptă. Lupta ține o copie cât se luptă (ca să nu
## emită un semnal la fiecare lovitură), apoi o predă aici, o dată.
func seteaza_pv(valoare: int) -> void:
	pv = clampi(valoare, 0, pv_max)
	s_a_schimbat.emit()


## Odihna. Întoarce cât s-a recuperat DE FAPT, ca ecranul să poată scrie
## „+5 PV” fără să facă el socoteala și fără să poată ajunge la alt număr.
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
	# Criticele se ADUNĂ: aici întrebarea e „câte ai dat în tot runul”, nu
	# „care a fost cea mai bună luptă”. Două statistici, două feluri de a
	# aduna — de-aia stau într-un tabel și nu într-o buclă care le tratează la fel.
	recorduri["critice"] = int(recorduri["critice"]) + int(raport.get("critice", 0))

	# MONEDELE cad aici, nu în luptă, și nu e o chestiune de comoditate: ăsta e
	# singurul loc din tot jocul care știe ȘI că s-a câștigat o luptă, ȘI la ce
	# fel de nod. Lupta ar fi trebuit să întrebe harta ce nod e ca să afle cât
	# plătește — adică să repete o socoteală care se face oricum aici.
	monede += int(date_nod(int(nod_curent().get("tip", Nod.LUPTA)))["monede"])
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
# MAGAZINUL
# ─────────────────────────────────────────────────────────────

## Fișa unei puteri, după cheie. Dicționar gol dacă nu există — apelantul
## verifică cu `is_empty()`, în loc să primească `null` și să crape două
## funcții mai încolo.
static func putere(cheie: String) -> Dictionary:
	for rand in PUTERI:
		if String(rand["cheie"]) == cheie:
			return rand
	return {}


## Poți cumpăra puterea asta ACUM? Două condiții, nu una.
##
## Prima e evidentă: să ai Monedele. A doua s-a văzut abia la prima probă —
## „Fiertura calda” (+6 PV) se putea cumpăra cu PV-ul plin, lua 9 Monede și
## răspundea „+0 PV”. Nu era un bug de cod; era un bug de vitrină. Un magazin
## n-are voie să-ți vândă nimic sub formă de ceva.
func pot_cumpara(cheie: String) -> bool:
	var fisa := putere(cheie)
	if fisa.is_empty() or monede < int(fisa["cost"]):
		return false
	return _are_efect(fisa)


## Ar schimba puterea asta ceva, în starea de acum?
##
## Doar vindecarea poate fi degeaba (PV plin). Un PV maxim în plus e mereu bun,
## iar un PA în plus la fel — de-aia funcția răspunde „da” pentru orice efect
## despre care n-are motiv să creadă altceva, în loc să ceară un rând nou în
## tabel pentru fiecare putere viitoare.
static func _are_efect_pentru(fisa: Dictionary, pv_acum: int, pv_maxim: int) -> bool:
	if String(fisa["efect"]) == "pv":
		return pv_acum < pv_maxim
	return true


func _are_efect(fisa: Dictionary) -> bool:
	return _are_efect_pentru(fisa, pv, pv_max)


## De ce nu poți cumpăra, într-un cuvânt — ca butonul stins să spună singur
## ce-i lipsește. "" înseamnă „poți”.
func motiv_refuz(cheie: String) -> String:
	var fisa := putere(cheie)
	if fisa.is_empty():
		return "nu exista"
	if not _are_efect(fisa):
		return "PV plin"
	if monede < int(fisa["cost"]):
		return "iti mai trebuie %d" % (int(fisa["cost"]) - monede)
	return ""


## Cumpără. Întoarce textul de arătat jucătorului („+6 PV”) sau ”" dacă n-a
## mers — un singur apel care ȘI plătește, ȘI aplică, ȘI spune ce s-a
## întâmplat. Trei apeluri separate ar fi însemnat că se poate plăti fără să se
## aplice nimic, iar ăla e exact bugul pe care nu-l observi decât ca jucător.
func cumpara(cheie: String) -> String:
	if not pot_cumpara(cheie):
		return ""

	var fisa := putere(cheie)
	monede -= int(fisa["cost"])
	puteri.append(cheie)

	# Efectele instantanee se consumă ACUM. Cele durabile n-au nimic de făcut
	# aici: ele trăiesc în `puteri` și sunt întrebate de luptă, la fiecare
	# rundă, prin `bonus_pa()`.
	var urmare := ""
	match String(fisa["efect"]):
		"pv":
			var inainte := pv
			pv = mini(pv + int(fisa["cantitate"]), pv_max)
			urmare = "+%d PV. Acum %d / %d." % [pv - inainte, pv, pv_max]
		"pv_max":
			pv_max += int(fisa["cantitate"])
			pv += int(fisa["cantitate"])
			urmare = "+%d PV maxim. Acum %d / %d." % [
				int(fisa["cantitate"]), pv, pv_max]
		"pa":
			# „Cu cât mai mult”, nu „câte cu totul”: PA-ul de bază e al luptei
			# (`PA_PE_RUNDA`), iar expediția n-are de ce să-l știe.
			urmare = "De acum, +%d PA in fiecare runda." % bonus_pa()

	s_a_schimbat.emit()
	return urmare


## Câte PA în plus dai în fiecare rundă, din puterile cumpărate.
##
## Se NUMĂRĂ, nu se ține un contor separat: lista de puteri e adevărul, iar un
## al doilea număr care ar trebui să fie mereu egal cu ea e un al doilea număr
## care într-o zi n-o să mai fie.
func bonus_pa() -> int:
	var spor := 0
	for cheie in puteri:
		var fisa := putere(cheie)
		if not fisa.is_empty() and String(fisa["efect"]) == "pa":
			spor += 1
	return spor


## Numele puterilor cumpărate, pentru sumar. Cu dubluri: „Pana de otel ×2”.
func puteri_pe_scurt() -> String:
	if puteri.is_empty():
		return "-"
	var cate := {}
	for cheie in puteri:
		cate[cheie] = int(cate.get(cheie, 0)) + 1
	var bucati: Array[String] = []
	for cheie in cate:
		var nume := String(putere(cheie).get("nume", cheie))
		bucati.append(nume if cate[cheie] == 1 else "%s x%d" % [nume, cate[cheie]])
	return ", ".join(bucati)


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
##
## `cale_plansa` gol = harta se generează, ca înainte. Altfel, FORMA vine din
## fișier și doar conținutul din sămânță. Parametrul are o valoare implicită ca
## apelurile vechi (verificarea headless) să meargă nemodificate.
static func genereaza_harta(samanta_harta: int, cale_plansa := "") -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = samanta_harta
	if cale_plansa != "":
		return _harta_din_plansa(rng, Plansa.incarca(cale_plansa))
	return _harta_generata(rng)


static func _harta_generata(rng: RandomNumberGenerator) -> Array[Dictionary]:
	var straturi := rng.randi_range(STRATURI_MIN, STRATURI_MAX)
	# Plasa de la `NODURI_MINIME`: un strat din mijloc aduce `NODURI_PE_STRAT`
	# noduri, deci creștem straturile până iese numărul cerut. Bucla asta nu
	# face nimic azi (7 straturi dau deja 12) — e acolo ca să NU se poată
	# ajunge, dintr-o reglare de dificultate, la o hartă de opt puncte răzlețe.
	while 2 + (straturi - 2) * NODURI_PE_STRAT < NODURI_MINIME:
		straturi += 1

	var noduri: Array[Dictionary] = []
	# „Cine e pe stratul de dinainte” — avem nevoie de indicii lor ca să
	# tragem muchiile înapoi, după ce stratul nou e construit.
	var stratul_trecut: Array[int] = []

	for adancime in range(straturi):
		# Primul și ultimul strat au un singur nod: expediția pornește dintr-un
		# punct și se termină într-unul. Fără asta, „ai ajuns la capăt” ar fi
		# două capete diferite, iar finalul ar depinde de coloana pe care ai mers.
		var cate := NODURI_PE_STRAT
		if adancime == 0 or adancime == straturi - 1:
			cate = 1

		var stratul_nou: Array[int] = []
		for coloana in range(cate):
			var id := noduri.size()
			var tip := _alege_tip(
				rng, adancime, adancime == 0, adancime == straturi - 1)
			# Bugetul crește cu adâncimea, apoi îl înmulțește tipul nodului.
			# Multiplicatorul vine din `DATE_NOD`, nu dintr-un `if tip == ELITA`:
			# de-aia Bossul n-a cerut nicio linie de cod aici, doar un rând în tabel.
			var buget: float = (BUGET_BAZA + BUGET_PE_ADANCIME * adancime) 				* float(date_nod(tip)["buget"])
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

	_asigura_magazin(rng, noduri, straturi)
	return noduri


## HARTA DINTR-O PLANȘĂ DESENATĂ: forma din fișier, conținutul din sămânță.
##
## Planșa dă nodurile și drumurile. Tot restul — ce tip e fiecare nod, ce buget
## are, ce sămânță — se trage aici, exact cu regulile de la harta generată.
##
## ─────────────────────────────────────────────────────────────
## CE REGULI DEPINDEAU DE STRAT, ȘI CUM SE TRADUC
##
## Pe harta generată, „stratul” era trei lucruri deodată: adâncimea, ordinea în
## listă, și capătul drumului. Pe o planșă se despart, iar fiecare regulă
## trebuie să spună pe care din ele se sprijină de fapt:
##
##   ADÂNCIMEA (cea mai scurtă distanță de la Start, vezi `Plansa.adancimi`)
##   rămâne ce era: ponderile tipurilor și bugetul se calculează din ea, cu
##   aceleași formule. Singura diferență e că nu mai e monotonă de-a lungul
##   fiecărui drum — o scurtătură poate duce la un nod mai puțin adânc decât cel
##   din care ai plecat.
##
##   INTRAREA nu mai e „adâncimea 0”, ci nodul `start` din fișier. Se nimerește
##   să fie același lucru (Startul e singurul la distanța 0 de el însuși), dar
##   regula e citită din fișier, nu dedusă.
##
##   CAPĂTUL nu mai e „ultimul strat”, ci nodul `boss` din fișier — și aici
##   diferența e reală: pe o ocolitoare lungă poate sta un nod mai adânc decât
##   Bossul. Vezi nota de la `_alege_tip`.
##
##   ORDINEA ÎN LISTĂ („ultimul nod e Bossul”) era o consecință a generării. Aici
##   se construiește dinadins: nodurile se pun în ordinea adâncimii, iar Bossul
##   se pune ULTIMUL, oricât de adânc ar fi. Nu e cosmetic — `id`-ul unui nod e
##   chiar indicele lui, deci ordinea asta e ce face „Bossul e ultimul nod” să
##   rămână adevărat pentru verificări și pentru orice save vechi.
##
##   COLOANA nu mai înseamnă „a câta bandă de pe panglică”, fiindcă nu mai e
##   nicio panglică. Devine rangul nodului în stratul lui, de sus în jos pe
##   desen — adică tot „a câta bandă”, doar măsurată pe hârtie. E folosită numai
##   la diagnostic; desenul se face din poziția din fișier.
static func _harta_din_plansa(
	rng: RandomNumberGenerator, plansa: Dictionary
) -> Array[Dictionary]:
	var adanc := Plansa.adancimi(plansa)
	var start := String(plansa["start"])
	var boss := String(plansa["boss"])

	# Locul fiecărui reper în fișier: departajarea nodurilor de pe același strat.
	# Așa, două noduri la aceeași adâncime rămân în ordinea în care le-ai scris,
	# deci fișierul se poate citi alături de harta din joc.
	var rang := {}
	for i in range(plansa["ordine"].size()):
		rang[String(plansa["ordine"][i])] = i

	var repere: Array[String] = []
	for reper_brut in plansa["ordine"]:
		var reper := String(reper_brut)
		if not adanc.has(reper):
			# Un nod la care nu se poate ajunge e un nod care n-o să fie jucat
			# NICIODATĂ. L-am putea desena oricum, dar atunci harta ar minți:
			# ar arăta un loc unde nu se poate merge. Îl sărim, și o spunem.
			push_warning("Plansa %s: la nodul %s nu se poate ajunge din start."
				% [plansa["cale"], reper])
			continue
		if reper != boss:
			repere.append(reper)
	repere.sort_custom(func(a, b):
		var da := int(adanc[a])
		var db := int(adanc[b])
		if da != db:
			return da < db
		return int(rang[a]) < int(rang[b]))
	if adanc.has(boss):
		repere.append(boss)
	else:
		push_warning("Plansa %s: la Boss nu se poate ajunge din start."
			% plansa["cale"])

	# Coloana: rangul în stratul lui, de sus în jos pe desen.
	var coloane := {}
	var pe_strat := {}
	for reper in repere:
		var a := int(adanc[reper])
		if not pe_strat.has(a):
			pe_strat[a] = []
		pe_strat[a].append(reper)
	for a in pe_strat:
		var strat: Array = pe_strat[a]
		strat.sort_custom(func(x, y):
			var px: Vector2 = plansa["poz"][x]
			var py: Vector2 = plansa["poz"][y]
			if absf(px.y - py.y) > 0.0001:
				return px.y < py.y
			return px.x < py.x)
		for i in range(strat.size()):
			coloane[strat[i]] = i

	# Reper → id. Trebuie gata ÎNAINTE de bucla de mai jos: un nod își scrie
	# vecinii ca indici, iar vecinii lui pot fi noduri încă neconstruite.
	var id_al := {}
	var straturi := 0
	for i in range(repere.size()):
		id_al[repere[i]] = i
		straturi = maxi(straturi, int(adanc[repere[i]]) + 1)

	var noduri: Array[Dictionary] = []
	for reper in repere:
		var adancime := int(adanc[reper])
		var tip := _alege_tip(rng, adancime, reper == start, reper == boss)
		var buget: float = (BUGET_BAZA + BUGET_PE_ADANCIME * adancime) \
			* float(date_nod(tip)["buget"])

		var spre: Array = []
		for urmator in plansa["spre"].get(reper, []):
			if id_al.has(urmator):
				spre.append(int(id_al[urmator]))
		spre.sort()

		noduri.append({
			"id": int(id_al[reper]),
			# Firul către desen. Singurul câmp pe care harta generată nu-l are.
			"reper": reper,
			"adancime": adancime,
			"coloana": int(coloane.get(reper, 0)),
			"tip": tip,
			"buget": snappedf(buget, 0.01),
			"samanta": rng.randi_range(1, 999999),
			"spre": spre,
		})

	_asigura_magazin(rng, noduri, straturi)
	return noduri


## O hartă FĂRĂ Magazin face Monedele o glumă proastă: le-ai strâns toată
## expediția și n-ai avut unde să le dai. Ponderile îl fac probabil, dar
## „probabil” nu e „sigur”, iar un jucător care nimerește sămânța nefericită
## nu află niciodată că sistemul există.
##
## Deci: dacă n-a ieșit niciun Magazin, transformăm unul. Alegem din a DOUA
## JUMĂTATE a drumului (ai apucat să aduni ceva) și numai un nod care nu are
## deja un rol propriu — o Luptă sau un Eveniment, niciodată o Odihnă, o Elită
## sau Bossul, fiindcă alea sunt trepte de dificultate, nu spațiu liber.
static func _asigura_magazin(
	rng: RandomNumberGenerator, noduri: Array[Dictionary], straturi: int
) -> void:
	for nod in noduri:
		if int(nod["tip"]) == Nod.MAGAZIN:
			return

	# Două căutări, în ordinea preferinței. Prima e cea dorită: a doua jumătate
	# a drumului, unde ai apucat să aduni Monede. A doua acceptă orice nod liber,
	# oriunde pe drum — un Magazin prea devreme e tot mai bun decât niciunul.
	#
	# La 300 de semințe încercate, a doua căutare salvează o hartă. Una la trei
	# sute pare puțin până înțelegi ce e: un run în care sistemul de Monede pur
	# și simplu nu există, fără ca jucătorul să afle vreodată de ce.
	var candidati := _noduri_libere(noduri, straturi / 2, straturi - 1)
	if candidati.is_empty():
		candidati = _noduri_libere(noduri, 1, straturi - 1)
	if candidati.is_empty():
		return   # hartă numai din Elite și Odihne: rară, dar n-o stricăm cu forța

	var ales: int = candidati[rng.randi_range(0, candidati.size() - 1)]
	noduri[ales]["tip"] = Nod.MAGAZIN
	# Bugetul se recalculează: nodul nu mai e o luptă, deci multiplicatorul lui
	# de dificultate s-a schimbat. Fără linia asta, un Magazin făcut dintr-o
	# Elită ar fi rămas cu bugetul Elitei — invizibil azi, otravă la pasul 10.
	noduri[ales]["buget"] = snappedf(
		(BUGET_BAZA + BUGET_PE_ADANCIME * int(noduri[ales]["adancime"]))
		* float(DATE_NOD[Nod.MAGAZIN]["buget"]), 0.01)


## Nodurile care pot fi transformate în altceva, între două adâncimi.
##
## „Liber” înseamnă Luptă sau Eveniment: nodurile care nu au un rol propriu în
## economia drumului. O Odihnă, o Elită sau Bossul sunt trepte puse dinadins —
## dacă le-am rescrie, am repara o problemă stricând alta.
static func _noduri_libere(
	noduri: Array[Dictionary], de_la_adancime: int, pana_la_adancime: int
) -> Array[int]:
	var gasite: Array[int] = []
	for nod in noduri:
		var adancime := int(nod["adancime"])
		var e_liber: bool = int(nod["tip"]) in [Nod.LUPTA, Nod.EVENIMENT]
		if e_liber and adancime >= de_la_adancime and adancime < pana_la_adancime:
			gasite.append(int(nod["id"]))
	return gasite


## Ce fel de nod e ăsta.
##
## Nodul de START e MEREU o luptă obișnuită: o expediție care începe cu odihnă
## („n-ai ce odihni”) sau cu o elită („n-ai apucat să înveți nimic”) pornește
## prost, indiferent ce spun ponderile.
##
## Nodul de CAPĂT e MEREU Boss. Era Elită, și asta era o scăpare de design pe
## care harta o arăta pe față: dacă la nodul 6 întâlnești o Elită și la nodul 12
## tot o Elită, capătul drumului nu e un capăt — e încă un nod. Un tip aparte,
## doar acolo, face finalul un LOC, nu o repetare.
##
## ─────────────────────────────────────────────────────────────
## DE CE PRIMEȘTE „E STARTUL?” ȘI „E BOSSUL?” ÎN LOC DE „AL CÂTELEA STRAT”
##
## Vechea semnătură era `(adancime, straturi)`, și citea regulile ca
## `adancime == 0` și `adancime == straturi - 1`. Pe harta generată, cele două
## întrebări sunt același lucru: primul strat ESTE intrarea, ultimul ESTE
## capătul.
##
## Pe o planșă desenată nu mai sunt. „Cel mai depărtat nod de Start” poate fi un
## nod de pe o ocolitoare lungă, iar Bossul poate sta la o adâncime mai mică
## decât el. Cine e capătul o spune fișierul, prin câmpul `boss`.
##
## Deci regula n-a fost schimbată, ci CITITĂ CUM TREBUIE: ea vorbea mereu despre
## intrare și capăt, doar că adâncimea era, până acum, un mod corect de a le
## afla. Cele două surse răspund fiecare cum știe, iar tabelul de ponderi rămâne
## singurul lucru din mijloc.
##
## Restul se trage din `PONDERI_NOD`, cu ponderile crescute de adâncime.
static func _alege_tip(
	rng: RandomNumberGenerator, adancime: int, e_start: bool, e_boss: bool
) -> Nod:
	if e_start:
		return Nod.LUPTA
	if e_boss:
		return Nod.BOSS

	# „Roata norocului”: fiecare tip primește o felie cât ponderea lui, apoi
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


## Trage muchiile dintre două straturi vecine — FĂRĂ SĂ SE ÎNCRUCIȘEZE.
##
## ─────────────────────────────────────────────────────────────
## CE ERA ÎNAINTE, ȘI DE CE NU MERGEA
##
## Regula veche era: fiecare nod de sus își alege 1-2 urmași la întâmplare,
## apoi reparăm nodurile de jos rămase fără părinte. Ambele jumătăți erau
## corecte luate separat — harta ieșea conectată, fiecare nod era accesibil —
## și totuși drumurile se tăiau unul pe altul la aproape fiecare sămânță
## (949 de încrucișări la 300 de hărți).
##
## Motivul e simplu odată văzut: „la întâmplare” înseamnă că nodul de sus de pe
## coloana 0 putea alege nodul de jos de pe coloana 1, iar cel de pe coloana 1
## pe cel de pe coloana 0. Două drumuri care își schimbă locurile. Nicio
## curbură frumoasă nu repară asta — e o încrucișare în GRAF, nu în desen.
##
## ─────────────────────────────────────────────────────────────
## REGULA NOUĂ: FIECARE NOD DE SUS IA O FELIE, ȘI FELIILE MERG ÎNAINTE
##
## Nodurile ambelor straturi sunt luate în ordinea coloanei. Fiecare nod de sus
## primește o felie CONTINUĂ de noduri de jos — de la `start` la `capat` — iar
## felia următoare nu are voie să înceapă înaintea locului unde s-a terminat
## cea dinainte.
##
## Două felii care merg înainte nu se pot inversa, iar dacă nu se inversează,
## drumurile nu se încrucișează. Asta e tot. Nu e o verificare („încrucișează
## muchia asta pe alta? atunci mai trag un zar") — e o construcție din care
## încrucișarea pur și simplu nu poate ieși, oricâte zaruri ai arunca.
##
## Feliile au voie să se ATINGĂ: `start` poate fi chiar ultimul nod al feliei
## de dinainte. Atunci două drumuri intră în același nod de jos — două cărări
## care se adună, care e exact ce vrei să vezi pe o hartă. Ce nu au voie e să
## se încalece pe dos.
##
## ─────────────────────────────────────────────────────────────
## CE RĂMÂNE GARANTAT
##
## 1. FIECARE NOD DE JOS E ACCESIBIL. Prima felie începe la 0, ultima se termină
##    la ultimul nod, iar între ele feliile sunt lipite cap la cap. Reuniunea lor
##    e tot stratul, fără găuri. Nu mai e nevoie de pasul de „reparație” de
##    dinainte, fiindcă nu mai există ce repara.
## 2. FIECARE NOD DE SUS ARE CEL PUȚIN O IEȘIRE. `capat` e mereu cel puțin egal
##    cu `start`, deci felia nu poate fi goală. Un nod fără ieșire ar fi fost un
##    drum înfundat — mergi acolo și nu mai ai unde.
##
## O CONDIȚIE pe care o presupune: `sus` și `jos` vin în ORDINEA COLOANEI. Le
## construiește `genereaza_harta()`, cu `for coloana in range(cate)`, deci așa
## sunt. Dacă într-o zi cineva le amestecă acolo, regula de aici devine o
## minciună — și nu se va plânge nimeni, doar drumurile se vor tăia iar.
static func _leaga(
	rng: RandomNumberGenerator,
	noduri: Array[Dictionary],
	sus: Array[int],
	jos: Array[int]
) -> void:
	var n := sus.size()
	var m := jos.size()
	if n == 0 or m == 0:
		return

	# Unde s-a terminat felia nodului de sus dinainte. Prima felie n-are una.
	var capat_anterior := -1

	for k in range(n):
		var start := 0
		if k > 0:
			# Două variante, și doar două. Ori pornim CHIAR din nodul unde s-a
			# oprit vecinul de deasupra (cele două drumuri se adună acolo), ori
			# de la următorul (drumuri complet separate). Orice altceva ar
			# însemna să dăm înapoi — adică o încrucișare.
			start = capat_anterior
			if start < m - 1 and rng.randf() < 0.5:
				start += 1

		# Ultimul nod de sus acoperă tot ce-a mai rămas: altfel ar rămâne
		# noduri de jos fără niciun părinte, adică bucăți de hartă în care nu
		# se poate ajunge.
		var capat := m - 1
		if k < n - 1:
			capat = rng.randi_range(start, m - 1)

		var legaturi: Array = noduri[sus[k]]["spre"]
		for indice in range(start, capat + 1):
			legaturi.append(jos[indice])
		legaturi.sort()
		capat_anterior = capat


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
		"plansa": plansa,
		"harta": noduri,
		"pozitie": pozitie,
		"parcurse": parcurse.duplicate(),
		"loadout": loadout.duplicate(),
		"pv": pv,
		"pv_max": pv_max,
		"fragmente_castigate": fragmente_castigate,
		"monede": monede,
		"puteri": puteri.duplicate(),
		"recorduri": recorduri.duplicate(true),
		"final": final,
	}


func din_dictionar(date: Dictionary) -> void:
	goleste()
	samanta = int(date.get("samanta", 0))
	# Un save vechi n-are câmpul, deci "" — adică hartă generată. Exact ce era.
	plansa = String(date.get("plansa", ""))
	pozitie = int(date.get("pozitie", -1))
	pv = int(date.get("pv", PV_MAX))
	pv_max = int(date.get("pv_max", PV_MAX))
	fragmente_castigate = int(date.get("fragmente_castigate", 0))
	monede = int(date.get("monede", 0))
	final = String(date.get("final", ""))
	activa = bool(date.get("activa", false))

	for cheie in date.get("loadout", []):
		loadout.append(String(cheie))
	for cheie in date.get("puteri", []):
		puteri.append(String(cheie))
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

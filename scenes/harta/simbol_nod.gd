class_name SimbolNod
extends Silueta
## UN NOD DE PE HARTĂ — un simbol de cerneală desenat pe pergament.
##
## Înainte era un `Button` cu chenar și cu textul „⚔ LUPTA" scris în el. Pe un
## fundal negru arăta acceptabil; pe pergament, un dreptunghi gri cu colțuri
## rotunjite e singurul lucru din tot ecranul care strigă „interfață". Harta
## trebuie să pară DESENATĂ pe hârtia aia, nu pusă deasupra ei.
##
## ─────────────────────────────────────────────────────────────
## DE CE MOȘTENEȘTE `Silueta`
##
## `Silueta` (din `scenes/lupta/`) știe deja exact ce-mi trebuie aici:
##   • potrivește o casetă cu proporții corecte în orice cutie primește;
##   • traduce „fracțiuni" (numere între 0 și 1) în pixeli, deci formele de mai
##     jos sunt liste de numere ușor de citit, independente de mărime;
##   • are o respirație pe `sin()`, cu decalaj de pornire.
##
## Respirația aia e, aici, PULSUL nodurilor accesibile. N-am scris nicio linie
## de animație: i-am dat `amplitudine` din tabelul de înfățișări, și gata. Așa
## arată reutilizarea când baza a fost desenată cum trebuie — a doua oară nu
## mai plătești.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU MAI E BUTON
##
## Un `Button` desenează întotdeauna ceva al lui: fond, chenar, stare de hover.
## Se pot goli toate cu StyleBox-uri, dar atunci rămâne un buton care nu mai e
## buton. Un `Control` obișnuit primește mouse-ul la fel de bine (`mouse_entered`,
## `_gui_input`) și desenează EXACT ce-i spun eu.
##
## Ce pierd: focusul cu tastatura. Harta n-a fost niciodată navigabilă cu
## săgețile, deci nu pierd nimic ce aveam.
##
## ─────────────────────────────────────────────────────────────
## CE NU ȘTIE FIȘIERUL ĂSTA
##
## Nu știe ce e o expediție, un PV sau o luptă. Primește „ce tip ești" și „în
## ce stare ești", desenează, și strigă înapoi când e apăsat sau survolat.
## Același contract subțire ca între luptă și disciplinele de puzzle.

## Apăsat — dar numai dacă e un nod în care chiar se poate intra.
signal apasat(id_nod: int)

## Mouse-ul a intrat pe el (`intrat = true`) sau a ieșit. Eticheta cu numele
## nodului o ține harta, nu nodul: o singură etichetă pentru toate nodurile nu
## se poate suprapune cu ea însăși, zece etichete se pot.
signal survolat(id_nod: int, intrat: bool)

## Cele patru stări în care poate fi un nod. NU sunt patru culori — sunt patru
## ROLURI în ierarhia vizuală cerută: unde ești, unde poți merge, pe unde ai
## fost, ce nu ți-e la îndemână.
enum Stare { INCHIS, ACCESIBIL, CURENT, PARCURS }

# ── PALETA DE CERNEALĂ ────────────────────────────────────────
# Toate culorile de aici sunt gândite PE PERGAMENT. Vechile culori ale hărții
# (text deschis, linii palide) erau făcute pentru fundal negru și pe hârtie
# veche pur și simplu dispăreau.

## Cerneala: maro foarte închis, nu negru. Negrul pur pe o textură caldă arată
## lipit deasupra; maro-ul închis arată absorbit în fibră.
const CERNEALA := Color(0.14, 0.09, 0.05)

## Halo-ul din spatele simbolului: o pată de lumină. Pergamentul are pete,
## cute și dealuri desenate — fără halo, o sabie închisă peste o umbră maro
## devine o mâzgăleală. Halo-ul nu e decor, e LIZIBILITATE.
##
## CULOAREA lui vine din `Expeditie.DATE_NOD`, nu de aici, și asta e o decizie
## de lizibilitate, nu de stil: craniul Elitei și coiful Luptei sunt forme
## apropiate la 90 de pixeli pe un fundal aglomerat. Forma nu le desparte —
## culoarea din spate le desparte. Crem pentru Luptă, portocaliu pentru Elită,
## cald pentru Odihnă, auriu pentru Magazin, roșu pentru Boss.
##
## DAR SE DESENEAZĂ DOAR SUB DESENELE DIN POLIGOANE. Amândouă treburile de
## mai sus — „despart tipurile prin culoare" și „umplu găurile tăiate în
## simbol" — sunt treburi pe care le are numai un simbol desenat din
## poligoane: el e o siluetă plată de o singură culoare, cu găuri prin care
## trebuie să se vadă ceva. O imagine nu are niciuna din problemele astea:
## are propriile ei culori, propriile ei umbre și propriul ei contur, deci
## se desparte de vecini singură. Peste ea, pata de lumină nu mai adaugă
## lizibilitate — doar spală culorile, fiindcă e un strat deschis așezat
## exact sub zona pe care o acoperă imaginea.
##
## De-aia e OPRITĂ la imagini, nu ȘTEARSĂ: desenul din poligoane e în
## continuare plasa de siguranță (vezi `IMAGINI`), iar în ziua în care un PNG
## lipsește sau e prost exportat, nodul cade înapoi pe poligoane — și acolo
## halo-ul e tot ce-l ține citibil. Ștergându-l, plasa ar exista în cod, dar
## ar prinde un simbol ilizibil.
##
## Constanta de mai jos e doar PLASA: ce se desenează dacă un tip de nod n-are
## culoare în tabel. Aproape alb, fiindcă pe hârtie deja deschisă un crem stins
## nu se vede deloc: ce trebuie să pară e „aici hârtia e curată".
const HALOU_IMPLICIT := Color(1.00, 0.97, 0.90)

## Aura caldă a nodului curent. Singurul lucru de pe hartă care emite lumină.
const CULOARE_AURA := Color(1.00, 0.72, 0.28)

## Cerneala roșie cu care se barează ce-ai lăsat în urmă. Aceeași convenție ca
## pe hărțile din care ne inspirăm: locul vizitat se taie cu un X.
const CULOARE_TAIERE := Color(0.52, 0.14, 0.09)

## Culoarea „găurilor" din simboluri (orbitele craniului, inima flăcării).
## Nu e o culoare de sine stătătoare, e culoarea halo-ului de dedesubt: tăiem
## în simbol ca să se vadă lumina din spatele lui. De-aia e o VARIABILĂ, pusă
## la fiecare desen din culoarea nodului: pe un halo auriu, o gaură crem ar fi
## o pată, nu o gaură.
var _culoare_gol := HALOU_IMPLICIT

# ── TABELUL DE ÎNFĂȚIȘĂRI ─────────────────────────────────────
# Ierarhia vizuală, ca TABEL, nu ca șir de `if`-uri prin `_draw()`. Un rând pe
# stare; o stare nouă („nod blocat de o cerință") ar fi un rând în plus.
#
#   cerneala   — cât de apăsat e desenat simbolul (opacitate)
#   halou      — cât de aprinsă e pata de lumină din spate
#   raza_halou — cât de mare e ea, ca fracțiune din casetă
#   puls       — cât respiră simbolul (0 = stă nemișcat)
#   aura       — cât de tare arde aura caldă (0 = deloc)
##
## Cifrele lui INCHIS au crescut (0,38 → 0,58 cerneală) după prima hartă
## desenată cu paisprezece noduri: pe o hârtie cu pete, cute și dealuri
## desenate, un simbol la 38% opacitate nu e „estompat", e invizibil. Iar un
## nod pe care nu-l vezi nu e o alegere pe care o refuzi — e una pe care n-ai
## știut c-o ai. Contrastul dintre „poți" și „nu poți" rămâne, dar e dat acum
## de puls și de halo, nu de dispariție.
const INFATISARI := {
	Stare.INCHIS:    {"cerneala": 0.58, "halou": 0.55, "raza_halou": 0.34, "puls": 0.000, "aura": 0.0},
	Stare.PARCURS:   {"cerneala": 0.62, "halou": 0.62, "raza_halou": 0.35, "puls": 0.000, "aura": 0.0},
	Stare.ACCESIBIL: {"cerneala": 1.00, "halou": 0.95, "raza_halou": 0.41, "puls": 0.022, "aura": 0.0},
	Stare.CURENT:    {"cerneala": 1.00, "halou": 1.00, "raza_halou": 0.43, "puls": 0.030, "aura": 1.0},
}

## Câte cercuri suprapuse fac halo-ul. Godot n-are „umbră moale" la desen, dar
## cercuri concentrice cu opacitate mică fiecare dau exact aceeași degradare —
## cel mai ieftin gradient din lume. Cu opt straturi se vedeau inelele; cu
## paisprezece, treapta dintre ele scade sub ce distinge ochiul.
const STRATURI_HALOU := 14

## Cât se îngroașă lumina la survolare. Discret: hover-ul confirmă „da, pe ăsta
## îl arăt", nu anunță o schimbare de stare.
const SPOR_HOVER := 0.14

## Aura nodului curent: cât de mare e față de halo, și cât de tare pâlpâie.
const RAZA_AURA := 1.9
const PALPAIRE_AURA := 0.34
const DURATA_AURA := 3.2

var id := -1
var stare := Stare.INCHIS
var tip := 0

## Poate fi apăsat? Doar nodurile accesibile. Ținut separat de `stare` fiindcă
## sunt două întrebări diferite: „cum arăți" și „ce se întâmplă la click".
var activ := false

## Nodul ăsta s-a consumat deja? Din nou o întrebare SEPARATĂ de `stare`, și
## din nou pentru că e alta: `stare` spune „unde ești pe hartă", asta spune
## „ce s-a întâmplat aici". Pentru PARCURS răspunsul e mereu da, dar nodul
## CURENT le poate avea pe amândouă — stai pe el ȘI l-ai terminat — iar
## harta e cea care știe asta, nu simbolul.
##
## De ce nu o a cincea stare („CURENT_TERMINAT"): stările sunt roluri în
## ierarhia vizuală, iar rolul nu se schimbă. Un nod terminat pe care stai
## rămâne „unde ești"; se adaugă doar un semn peste el. O stare în plus ar
## fi însemnat un rând nou în `INFATISARI` care repetă cuvânt cu cuvânt
## rândul lui CURENT — adică două locuri de schimbat la fiecare reglaj.
var terminat := false

## Stă figurina pe nodul ăsta? (vezi `figurina.gd`)
##
## A treia întrebare independentă, după stare și `terminat`, și tot dintr-un
## motiv de rol: ea nu spune nimic despre nod, spune ce se întâmplă DEASUPRA
## lui. Un nod acoperit nu mai desenează nici aura, nici simbolul tipului —
## primul fiindcă figurina răspunde deja la „unde sunt acum" mai bine decât o
## pată de lumină, al doilea fiindcă ar rămâne oricum sub soclul ei, iar un
## simbol pe jumătate ascuns arată a greșeală de desen. Rămâne X-ul, care e
## lat cât nodul și se vede de jur împrejurul tălpii.
##
## Nu e „starea CURENT face asta". E răspunsul hărții la o întrebare de
## FIȘIERE: dacă PNG-ul figurinei lipsește, nimeni nu acoperă nimic și nodul
## curent se desenează exact ca înainte, cu aură și cu sabia lui.
var acoperit := false

## ─────────────────────────────────────────────────────────────
## IMAGINI, CU DESENUL DIN COD CA PLASĂ
##
## Fiecare tip de nod are DOUĂ înfățișări: un fișier din
## `assets/art/campaign_nodes/` și o funcție care-l desenează din poligoane.
## Se încearcă întâi fișierul; dacă lipsește sau nu s-a putut încărca, se
## desenează.
##
## De ce amândouă, și nu doar imaginile: fiindcă o imagine e un fișier care
## poate lipsi, poate fi prost exportat, sau poate să nu fi fost încă desenat.
## Un joc care crapă sau arată un pătrat gol fiindcă un PNG n-a ajuns în
## folder e un joc pe care nu poți lucra. Cu plasa asta, arta se poate adăuga
## un fișier pe rând, iar harta rămâne jucabilă tot timpul.
##
## CERINȚE PENTRU FIȘIERE: PNG ADEVĂRAT, cu transparență reală (canal alfa),
## decupat strâns pe formă și pătrat. Un JPEG redenumit `.png` NU se încarcă
## în Godot, iar un „fundal în carouri" desenat în imagine se vede pe hartă
## exact ca un fundal în carouri.
const DOSAR_IMAGINI := "res://assets/art/campaign_nodes/"

## Un rând per tip de nod: ce fișier și, dacă el lipsește, ce se desenează.
## Numele funcției se pune în `_ready()` (vezi de ce, mai jos).
const IMAGINI := {
	Expeditie.Nod.LUPTA: "campaign_sword.png",
	Expeditie.Nod.ELITA: "campaign_skull.png",
	Expeditie.Nod.ODIHNA: "campaign_bonfire.png",
	Expeditie.Nod.MAGAZIN: "campaign_shop.png",
	Expeditie.Nod.BOSS: "campaign_boss.png",
	Expeditie.Nod.EVENIMENT: "campaign_event.png",
}

## Cât din casetă ocupă imaginea, ÎNAINTE de corecția pe tip de mai jos.
## Mai mică decât halo-ul era gândită ca lumina să se vadă de jur împrejur;
## acum că halo-ul nu se mai desenează sub imagini, marginea liberă rămâne
## tot utilă — în ea încape umbra desenată direct în PNG.
const MARIME_IMAGINE := 0.78

## MĂRIMEA PE TIP DE NOD — ierarhia, dată în mărime.
##
## Oglinda lui `IMAGINI`: aceleași chei, un multiplicator per tip, înmulțit cu
## `MARIME_IMAGINE`. Toate nodurile au aceeași casetă (`MARIME_NOD` din
## `harta.gd`), fiindcă așezarea lor pe pergament trebuie să rămână o grilă
## uniformă — dar un boss desenat la fel de mare ca o luptă oarecare spune
## „încă un nod", nu „capătul drumului". Aici se rupe uniformitatea, în DESEN,
## fără să se atingă layout-ul.
##
## Un tip care lipsește din tabel primește 1.0, adică exact ce avea înainte —
## tabelul ăsta nu poate strica un tip de nod pe care uiți să-l treci în el.
##
## NOTĂ, măsurată, nu presupusă: caseta e de 92 px (`MARIME_NOD`), iar BOSS la
## 1.45 dă 0.78 × 1.45 = 1.131 din casetă ≈ 104 px, deci ~6 px pe fiecare
## latură ÎN AFARA ei (cu pulsul nodului curent, ~7,5 px). Nu se retează
## nimic — `clip_contents` e fals, deci desenul iese liniștit peste margine,
## iar bossul e singur pe ultimul strat, deci n-are ce lovi. Ce rămâne: zona
## de click a nodului tot 92×92 e, iar eticheta (pusă la 42% din casetă sub
## centru) intră câțiva pixeli peste marginea de jos a imaginii. Decizie
## luată în cunoștință de cauză: se acceptă, ca să nu crească TOATE nodurile.
const MARIMI := {
	Expeditie.Nod.BOSS: 1.45,
	Expeditie.Nod.ELITA: 1.15,
	Expeditie.Nod.LUPTA: 1.0,
	Expeditie.Nod.EVENIMENT: 0.85,
	Expeditie.Nod.MAGAZIN: 0.9,
	Expeditie.Nod.ODIHNA: 0.9,
}

## CÂT DE MULT POATE SĂ DIFERE UN NOD DE FRATELE LUI, ca fracțiune: 0.12 = ±12%.
##
## Ierarhia din `MARIMI` spune „bossul e mai important decât o luptă". Asta e
## altceva, și e singurul scop: o hartă pe care toate Luptele sunt milimetric
## identice arată ȘTAMPILATĂ, nu desenată. Douăsprezece săbii de aceeași
## mărime, la aceeași distanță, sunt o grilă oricât de șerpuit ar fi drumul
## dintre ele.
##
## ±12% e pragul la care ochiul simte neregularitatea fără s-o poată măsura.
## Sub 8% nu se vede deloc; peste 20% începi să crezi că mărimea ÎNSEAMNĂ ceva
## — iar dacă ar însemna, ar contrazice `MARIMI`, care e singurul loc unde
## mărimea chiar spune ceva.
##
## Vine din sămânța nodului, nu dintr-un zar proaspăt: aceeași expediție
## reluată arată la fel, iar o captură de ecran dintr-un bug raportat se poate
## reproduce. Regula întregii hărți, ținută și aici.
const VARIATIE_MARIME := 0.12

## Texturile încărcate, ținute pe CLASĂ, nu pe nod: paisprezece noduri pe
## hartă ar fi însemnat paisprezece încărcări ale aceluiași fișier. `static
## var` = o singură copie pentru toți. Cheia e tipul, valoarea e textura sau
## `null` dacă s-a încercat și n-a mers (încercăm o singură dată).
static var _texturi := {}

var _hover := false
## Cheia tipului → funcția care-l desenează. Construit în `_ready()` fiindcă
## un `Callable` către o metodă proprie are nevoie de `self`, iar `self` nu
## există încă la declararea constantelor.
var _desene := {}


func _ready() -> void:
	super()   # `Silueta._ready()`: leagă redimensionarea și pornește ceasul

	# Tabelul de desene, oglinda lui `DATE_NOD` din expediție: un tip de nod nou
	# e un rând aici plus o funcție, nu o ramură nouă prin `_draw()`.
	_desene = {
		Expeditie.Nod.LUPTA: _deseneaza_sabie,
		Expeditie.Nod.ELITA: _deseneaza_craniu,
		Expeditie.Nod.ODIHNA: _deseneaza_foc,
		Expeditie.Nod.EVENIMENT: _deseneaza_intrebare,
		Expeditie.Nod.MAGAZIN: _deseneaza_punga,
		Expeditie.Nod.BOSS: _deseneaza_coarne,
	}

	mouse_entered.connect(_pe_intrare)
	mouse_exited.connect(_pe_iesire)


## Textura tipului dat, sau `null` dacă nu există fișier pentru el.
##
## Se încearcă O SINGURĂ DATĂ per tip, și rezultatul (inclusiv „n-a mers") se
## ține minte în `_texturi`. Fără memorare, un fișier lipsă ar însemna o
## căutare pe disc la fiecare redesenare a fiecărui nod — adică de zeci de ori
## pe secundă, pentru un fișier despre care știm deja că nu e acolo.
##
## `ResourceLoader.exists()` înainte de `load()` nu e paranoia: `load()` pe o
## cale inexistentă scrie o eroare roșie în consolă la fiecare apel, iar o
## consolă plină de erori așteptate e o consolă în care nu mai vezi erorile
## adevărate.
static func _textura(tip_cerut: int) -> Texture2D:
	if _texturi.has(tip_cerut):
		return _texturi[tip_cerut]

	var textura: Texture2D = null
	if IMAGINI.has(tip_cerut):
		var cale: String = DOSAR_IMAGINI + String(IMAGINI[tip_cerut])
		if ResourceLoader.exists(cale):
			textura = load(cale) as Texture2D
		if textura == null:
			print("SimbolNod: %s lipseste sau nu s-a putut incarca; desenez din cod." % cale)

	_texturi[tip_cerut] = textura
	return textura


## Tot ce trebuie să știe nodul ca să se deseneze. Un singur apel, cu tot, în
## loc de șase proprietăți puse pe rând din afară: așa nu poate exista un nod
## „pe jumătate configurat" care apucă să se deseneze o dată greșit.
##
## `samanta` vine din nodul de hartă și face două lucruri, amândouă pentru
## aceeași senzație de „desenat de mână": înclină simbolul cu câteva grade și
## decalează pornirea pulsului, ca nodurile să nu respire la unison.
## `terminat` și `acoperit` vin ultimele și cu valori implicite fiindcă sunt
## informație EN PLUS, nu una de care desenul are neapărat nevoie: un apel
## vechi, cu patru argumente, se comportă exact ca înainte.
func configureaza(
	id_nou: int, tip_nou: int, stare_noua: Stare, samanta: int,
	terminat_nou := false, acoperit_nou := false
) -> void:
	id = id_nou
	tip = tip_nou
	stare = stare_noua
	terminat = terminat_nou
	acoperit = acoperit_nou
	activ = stare == Stare.ACCESIBIL

	var infatisare: Dictionary = INFATISARI[stare]

	# Caseta e pătrată: un cerc desenat în ea rămâne cerc, iar `_corectat()`
	# din `Silueta` devine identitatea. Simbolurile de mai jos sunt scrise
	# pentru un pătrat.
	proportie = 1.0
	# Pulsul umflă simbolul din CENTRU, nu de la talpă: nodurile plutesc pe
	# hartă, nu stau pe un sol.
	ancora_y = 0.5
	amplitudine = float(infatisare["puls"])
	durata_respiratie = 2.4

	var rng := RandomNumberGenerator.new()
	rng.seed = samanta
	inclinare = rng.randf_range(-8.0, 8.0)
	decalaj = rng.randf_range(0.0, durata_respiratie)
	# Al TREILEA zar, și e trecut ultimul dinadins: fiecare `randf_range` mută
	# generatorul mai departe, deci o extragere strecurată înaintea celorlalte
	# le-ar fi schimbat și pe ele. Adăugat la coadă, înclinările și decalajele
	# de până acum rămân bit cu bit aceleași — harta e doar mai puțin regulată,
	# nu alta.
	scara_fixa = rng.randf_range(1.0 - VARIATIE_MARIME, 1.0 + VARIATIE_MARIME)

	mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND if activ else Control.CURSOR_ARROW
	)

	# Un nod acoperit nu desenează decât un X. Un X care pulsează sub o
	# figurină nemișcată nu arată a nod viu, arată a eroare de desen — și, pe
	# deasupra, l-ar redesena de 60 de ori pe secundă degeaba.
	if acoperit:
		amplitudine = 0.0

	# Un nod care nu pulsează n-are ce căuta în `_process`. Zece noduri care
	# se redesenează degeaba de 60 de ori pe secundă nu se văd azi, dar e
	# fix genul de risipă care se adună.
	set_process(amplitudine > 0.0 or (stare == Stare.CURENT and not acoperit))
	queue_redraw()


# ─────────────────────────────────────────────────────────────
# DESENUL
# ─────────────────────────────────────────────────────────────

## Suprascrie metoda goală din `Silueta`. Ea a pregătit deja caseta, pivotul și
## scara de respirație — aici desenăm doar, în ordinea în care se așază
## straturile: aura, halo-ul, simbolul, bararea.
##
## Dacă nodul e ACOPERIT de figurină, primele trei sar cu totul și rămâne doar
## bararea. Un singur `if`, în jurul straturilor care s-ar fi desenat sub talpa
## ei — motivul întreg e la `acoperit`, sus.
func _deseneaza_silueta() -> void:
	if not acoperit:
		_deseneaza_straturile()

	# X-ul nu ține de stare, ci de „s-a consumat nodul ăsta?". PARCURS e
	# consumat prin definiție; CURENT numai dacă harta ne-a spus-o. Așa nodul
	# pe care stai apare ca în referință: tăiat, cu figurina peste tăietură.
	if stare == Stare.PARCURS or (stare == Stare.CURENT and terminat):
		_deseneaza_taietura()


## Aura, halo-ul și simbolul tipului — tot ce ar fi rămas ascuns sub o figurină.
func _deseneaza_straturile() -> void:
	var infatisare: Dictionary = INFATISARI[stare]
	var spor := SPOR_HOVER if _hover else 0.0

	# Culoarea halo-ului vine din fișa tipului. Ea e ȘI culoarea „găurilor" din
	# simbolurile desenate: o orbită de craniu trebuie să arate ca o gaură prin
	# care se vede lumina de dedesubt, deci trebuie să fie exact lumina aia.
	var halou: Color = Expeditie.date_nod(tip).get("culoare", HALOU_IMPLICIT)
	_culoare_gol = halou

	# Ce umple caseta se hotărăște ÎNAINTE de straturile de dedesubt, fiindcă
	# de răspunsul ăsta depinde dacă mai desenăm halo sau nu.
	var textura := _textura(tip)

	# AURA rămâne în amândouă cazurile. Ea nu e lizibilitate, e localizare:
	# răspunde la „unde sunt acum", iar întrebarea aia n-are nicio legătură cu
	# felul în care e desenat simbolul. E și mai mare decât imaginea (vezi
	# `RAZA_AURA`), deci se vede de jur împrejurul ei, nu pe sub ea.
	if float(infatisare["aura"]) > 0.0:
		_deseneaza_aura(float(infatisare["aura"]))

	# HALO-UL, doar sub desenul din poligoane. Motivul întreg e la
	# `HALOU_IMPLICIT`, pe scurt: pata de lumină desparte tipurile și umple
	# găurile tăiate în simbol — două servicii de care are nevoie numai o
	# siluetă plată de o singură culoare. Sub o imagine, care are culorile și
	# conturul ei, nu mai adaugă nimic; doar o spală, fiindcă e un strat
	# deschis exact acolo unde imaginea are nevoie de contrast.
	#
	# Oprit, nu șters: imaginea poate lipsi (vezi `IMAGINI`), iar pe ruta de
	# rezervă halo-ul e tot ce ține simbolul citibil pe pergament.
	if textura == null:
		_deseneaza_halou(
			float(infatisare["raza_halou"]) * (1.06 if _hover else 1.0),
			float(infatisare["halou"]) + spor,
			halou
		)

	var cerneala := Color(CERNEALA, minf(1.0, float(infatisare["cerneala"]) + spor))

	# Imaginea întâi, desenul ca plasă. Un singur `if`, în singurul loc din
	# fișier care hotărăște „cu ce se umple caseta".
	if textura != null:
		_deseneaza_imaginea(textura, cerneala.a)
	elif _desene.has(tip):
		_desene[tip].call(cerneala)


## Imaginea nodului, pusă în casetă ca un poligon cu textură.
##
## NU `draw_texture_rect`: ăla desenează un dreptunghi drept, iar simbolurile
## noastre sunt înclinate câteva grade și respiră. Un poligon cu patru colțuri
## trecute prin `_punct()` moștenește amândouă, gratis — aceleași colțuri prin
## care trec și sabia, și craniul desenate din poligoane.
##
## „uv" spune ce colț din imagine ajunge în ce colț din poligon. Ordinea celor
## patru perechi trebuie să fie aceeași în amândouă listele, altfel imaginea
## iese răsucită ca o panglică.
##
## Opacitatea e a STĂRII, nu a imaginii: un nod închis se stinge la fel de
## mult fie că e desenat, fie că e pictat. Culoarea rămâne albă, fiindcă alb
## înmulțit cu imaginea înseamnă „lasă imaginea în pace".
func _deseneaza_imaginea(textura: Texture2D, opacitate: float) -> void:
	# Mărimea de bază, corectată pe tip. `get` cu 1.0 înseamnă că un tip
	# netrecut în `MARIMI` se desenează exact ca înainte de tabel.
	var latura := MARIME_IMAGINE * float(MARIMI.get(tip, 1.0))

	var jos := 0.5 - latura * 0.5
	var sus := 0.5 + latura * 0.5
	var colturi := PackedVector2Array([
		_punct(Vector2(jos, jos)), _punct(Vector2(sus, jos)),
		_punct(Vector2(sus, sus)), _punct(Vector2(jos, sus)),
	])
	var uv := PackedVector2Array([
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
	])
	draw_colored_polygon(colturi, Color(1, 1, 1, opacitate), uv, textura)


## Halo-ul: cercuri concentrice, de la mare și transparent la mic și dens.
## Opacitățile se ADUNĂ acolo unde cercurile se suprapun, deci centrul iese
## luminos fără ca marginea să aibă un contur vizibil.
##
## Se cheamă DOAR pe ruta desenului din poligoane — vezi `_deseneaza_silueta`
## și motivul lung de la `HALOU_IMPLICIT`. Funcția rămâne exact cum era, cu
## toți parametrii ei (inclusiv sporul de hover): nu e cod mort, e codul care
## ține harta citibilă în ziua în care un PNG lipsește din
## `assets/art/campaign_nodes/`.
func _deseneaza_halou(raza: float, putere: float, culoare: Color) -> void:
	if putere <= 0.0:
		return
	for i in range(STRATURI_HALOU):
		var t := float(i) / float(STRATURI_HALOU)
		var raza_strat := lerpf(raza, raza * 0.34, t)
		_cerc_moale(Vector2(0.5, 0.5), raza_strat, Color(culoare, putere * 0.115))


## Aura nodului curent: aceeași tehnică, mai mare, mai caldă și pâlpâind.
## E singura lumină de pe hartă, deci e și singurul lucru pe care ochiul îl
## găsește fără să caute — exact ce vrei de la „unde sunt acum".
func _deseneaza_aura(putere: float) -> void:
	var palpaire := 1.0 + sin(_timp * TAU / DURATA_AURA) * PALPAIRE_AURA
	var raza := float(INFATISARI[stare]["raza_halou"]) * RAZA_AURA * palpaire
	for i in range(STRATURI_HALOU):
		var t := float(i) / float(STRATURI_HALOU)
		var raza_strat := lerpf(raza, raza * 0.3, t)
		_cerc_moale(Vector2(0.5, 0.5), raza_strat, Color(CULOARE_AURA, putere * 0.032))


## X-ul de pe nodurile consumate — și cele din urmă, și cel pe care stai, dacă
## l-ai terminat. Nu e „dezactivat" (aia e starea ÎNCHIS, estompată) — e
## „rezolvat". Două lucruri diferite, două semne diferite.
func _deseneaza_taietura() -> void:
	var culoare := Color(CULOARE_TAIERE, 0.5)
	_linie(Vector2(0.26, 0.26), Vector2(0.74, 0.74), 0.055, culoare)
	_linie(Vector2(0.74, 0.26), Vector2(0.26, 0.74), 0.055, culoare)


# ─────────────────────────────────────────────────────────────
# SIMBOLURILE
#
# Fiecare e o listă de numere între 0 și 1, în caseta pătrată: 0.5 e mijlocul,
# 0 e sus/stânga, 1 e jos/dreapta. Nu apare niciun pixel — de-aia aceleași
# forme merg și la 84 de pixeli, și la 200, fără să se schimbe nimic.
#
# Sunt desenate în cod DEOCAMDATĂ. Când vine artă adevărată, fiecare funcție
# de aici devine un `draw_texture_rect` — tabelul `_desene` rămâne.
# ─────────────────────────────────────────────────────────────

## LUPTA — o sabie dreaptă, cu vârful în sus.
func _deseneaza_sabie(cerneala: Color) -> void:
	# Proporțiile contează mai mult decât forma: cu lama scurtă și garda lată,
	# sabia se citea drept CRUCE. Lama lungă cât două treimi din simbol și
	# garda strânsă sunt tot ce desparte una de alta.
	_poligon(PackedVector2Array([   # lama, cu vârf ascuțit
		Vector2(0.500, 0.035), Vector2(0.545, 0.160), Vector2(0.548, 0.620),
		Vector2(0.452, 0.620), Vector2(0.455, 0.160),
	]), cerneala)
	_poligon(PackedVector2Array([   # garda
		Vector2(0.325, 0.620), Vector2(0.675, 0.620),
		Vector2(0.675, 0.678), Vector2(0.325, 0.678),
	]), cerneala)
	_poligon(PackedVector2Array([   # mânerul
		Vector2(0.468, 0.678), Vector2(0.532, 0.678),
		Vector2(0.532, 0.872), Vector2(0.468, 0.872),
	]), cerneala)
	_cerc(Vector2(0.500, 0.898), 0.048, cerneala)   # măciulia


## ELITA — un craniu. Orbitele și nara sunt TĂIATE în el, cu culoarea
## halo-ului: o gaură adevărată, nu o pată deschisă pusă deasupra. De-aia
## craniul se citește și peste o cută a pergamentului.
func _deseneaza_craniu(cerneala: Color) -> void:
	_cerc(Vector2(0.500, 0.420), 0.245, cerneala)   # cutia craniană
	_poligon(PackedVector2Array([                   # maxilarul
		Vector2(0.330, 0.540), Vector2(0.670, 0.540),
		Vector2(0.628, 0.800), Vector2(0.372, 0.800),
	]), cerneala)

	var gol := Color(_culoare_gol, cerneala.a)
	_cerc(Vector2(0.408, 0.400), 0.078, gol)        # orbite
	_cerc(Vector2(0.592, 0.400), 0.078, gol)
	_poligon(PackedVector2Array([                   # nara
		Vector2(0.500, 0.455), Vector2(0.550, 0.545), Vector2(0.450, 0.545),
	]), gol)
	_linie(Vector2(0.500, 0.620), Vector2(0.500, 0.800), 0.030, gol)   # dinții
	_linie(Vector2(0.420, 0.620), Vector2(0.420, 0.800), 0.030, gol)
	_linie(Vector2(0.580, 0.620), Vector2(0.580, 0.800), 0.030, gol)


## ODIHNA — un foc de tabără: o grămadă de bușteni și o flacără mare.
##
## Buștenii au fost la început două linii lungi încrucișate, de la un colț la
## altul. Arăta a foc de tabără pe hârtie albă și a NOD BARAT pe hartă: exact
## aceeași formă cu `_deseneaza_taietura()`, X-ul cu care se taie ce-ai vizitat
## deja. La mărimea unui nod, un jucător n-avea cum să le deosebească.
##
## Acum sunt SCURȚI și JOȘI, strânși în treimea de jos, sub o flacără care ține
## restul casetei. Silueta nu mai e „un X", e „ceva care arde deasupra a ceva
## stivuit" — și nu se mai poate confunda cu o barare care taie tot pătratul.
func _deseneaza_foc(cerneala: Color) -> void:
	_linie(Vector2(0.255, 0.800), Vector2(0.745, 0.880), 0.080, cerneala)
	_linie(Vector2(0.745, 0.800), Vector2(0.255, 0.880), 0.080, cerneala)

	_poligon(PackedVector2Array([   # flacăra
		Vector2(0.500, 0.075), Vector2(0.596, 0.255), Vector2(0.562, 0.360),
		Vector2(0.660, 0.455), Vector2(0.672, 0.570), Vector2(0.596, 0.688),
		Vector2(0.404, 0.688), Vector2(0.328, 0.570), Vector2(0.340, 0.455),
		Vector2(0.438, 0.360), Vector2(0.404, 0.255),
	]), cerneala)
	# Inima flăcării, tăiată în ea. Mică: una mare golea flacăra pe dinăuntru
	# și o transforma într-o lalea.
	_poligon(PackedVector2Array([
		Vector2(0.500, 0.455), Vector2(0.554, 0.548), Vector2(0.536, 0.638),
		Vector2(0.464, 0.638), Vector2(0.446, 0.548),
	]), Color(_culoare_gol, cerneala.a))


## EVENIMENTUL — un semn de întrebare. Singurul simbol făcut din linii, nu din
## suprafețe: un „?" plin ar arăta a literă tipărită, iar restul hărții e
## desenată cu mâna.
func _deseneaza_intrebare(cerneala: Color) -> void:
	_arc(Vector2(0.500, 0.330), 0.180, 172.0, 392.0, 0.086, cerneala)
	_linie(Vector2(0.656, 0.420), Vector2(0.522, 0.620), 0.086, cerneala)
	_cerc(Vector2(0.500, 0.800), 0.058, cerneala)


## MAGAZINUL — o pungă de bani, cu gâtul legat și o monedă rezemată de ea.
##
## Nu o monedă singură: un cerc cu un semn în el se confundă, la 90 de pixeli,
## cu orice alt cerc de pe hartă. Silueta unei pungi — lată jos, strânsă sus —
## se recunoaște din formă, fără să fie nevoie să distingi ce e desenat în ea.
func _deseneaza_punga(cerneala: Color) -> void:
	_poligon(PackedVector2Array([   # trupul pungii
		Vector2(0.415, 0.330), Vector2(0.585, 0.330), Vector2(0.720, 0.470),
		Vector2(0.760, 0.680), Vector2(0.680, 0.855), Vector2(0.320, 0.855),
		Vector2(0.240, 0.680), Vector2(0.280, 0.470),
	]), cerneala)
	_linie(Vector2(0.395, 0.305), Vector2(0.605, 0.305), 0.075, cerneala)   # legătura
	_poligon(PackedVector2Array([   # gâtul strâns, deasupra legăturii
		Vector2(0.440, 0.150), Vector2(0.560, 0.150),
		Vector2(0.585, 0.290), Vector2(0.415, 0.290),
	]), cerneala)

	# Semnul de pe pungă, tăiat în ea: două monede suprapuse. Gaură, nu pată —
	# vezi nota de la `_culoare_gol`.
	var gol := Color(_culoare_gol, cerneala.a)
	_cerc(Vector2(0.455, 0.610), 0.105, gol)
	_cerc(Vector2(0.455, 0.610), 0.062, cerneala)
	_cerc(Vector2(0.575, 0.690), 0.088, gol)


## BOSSUL — un craniu cu coarne, privit din față.
##
## Trebuia să semene cu craniul Elitei cât să spună „tot un adversar", și să
## difere cât să spună „altceva decât până acum". Coarnele fac amândouă: e
## aceeași cutie craniană, cu ceva care iese din ea. Iar dacă la mărimea de pe
## hartă coarnele nu se citesc, haloul roșu din spate termină treaba — de-aia
## culoarea nu e decor.
func _deseneaza_coarne(cerneala: Color) -> void:
	_poligon(PackedVector2Array([   # cornul stâng
		Vector2(0.330, 0.400), Vector2(0.180, 0.215), Vector2(0.075, 0.075),
		Vector2(0.150, 0.235), Vector2(0.245, 0.330), Vector2(0.300, 0.470),
	]), cerneala)
	_poligon(PackedVector2Array([   # cornul drept, oglindit
		Vector2(0.670, 0.400), Vector2(0.820, 0.215), Vector2(0.925, 0.075),
		Vector2(0.850, 0.235), Vector2(0.755, 0.330), Vector2(0.700, 0.470),
	]), cerneala)

	_poligon(PackedVector2Array([   # cutia craniană, ascuțită spre bot
		Vector2(0.500, 0.230), Vector2(0.720, 0.360), Vector2(0.700, 0.620),
		Vector2(0.500, 0.900), Vector2(0.300, 0.620), Vector2(0.280, 0.360),
	]), cerneala)

	var gol := Color(_culoare_gol, cerneala.a)
	_poligon(PackedVector2Array([   # orbita stângă, tăiată oblic: o privire
		Vector2(0.345, 0.420), Vector2(0.470, 0.480),
		Vector2(0.450, 0.575), Vector2(0.345, 0.545),
	]), gol)
	_poligon(PackedVector2Array([   # orbita dreaptă
		Vector2(0.655, 0.420), Vector2(0.550, 0.480),
		Vector2(0.570, 0.575), Vector2(0.655, 0.545),
	]), gol)
	_poligon(PackedVector2Array([   # botul
		Vector2(0.500, 0.640), Vector2(0.548, 0.730), Vector2(0.452, 0.730),
	]), gol)


# ─────────────────────────────────────────────────────────────
# UNELTE DE DESEN
#
# `Silueta` are deja `_punct`, `_poligon` și `_cerc`. Astea trei completează
# ce-mi lipsea: linii groase, arce și cercuri netezite — toate scrise tot în
# fracțiuni, deci toate se scalează odată cu restul.
# ─────────────────────────────────────────────────────────────

## O linie groasă între două puncte-fracțiune. Grosimea e și ea fracțiune din
## înălțimea casetei, ca să nu rămână de 4 pixeli când nodul crește.
func _linie(de_la: Vector2, la: Vector2, grosime: float, culoare: Color) -> void:
	draw_line(
		_punct(de_la), _punct(la), culoare,
		grosime * _caseta.size.y * _scara, true
	)


## Un arc de cerc, gros. Godot desenează arce din segmente: 24 de pași sunt de
## ajuns cât să nu se vadă colțurile la mărimea unui nod.
func _arc(
	centru: Vector2, raza: float, de_la_grade: float, pana_la_grade: float,
	grosime: float, culoare: Color
) -> void:
	var puncte := PackedVector2Array()
	for i in range(25):
		var unghi := deg_to_rad(lerpf(de_la_grade, pana_la_grade, i / 24.0))
		puncte.append(_punct(centru + Vector2(cos(unghi), sin(unghi)) * raza))
	draw_polyline(puncte, culoare, grosime * _caseta.size.y * _scara, true)


## Un cerc cu marginea netezită. `_cerc` din `Silueta` desenează fără
## antialiasing — pentru siluete e bine (sunt mari), pentru straturile de halo
## se vedeau treptele pe cercul cel mai mare.
func _cerc_moale(centru: Vector2, raza: float, culoare: Color) -> void:
	draw_circle(
		_punct(centru), raza * _caseta.size.y * _scara, culoare,
		true, -1.0, true
	)


# ─────────────────────────────────────────────────────────────
# MOUSE
# ─────────────────────────────────────────────────────────────

func _pe_intrare() -> void:
	_hover = true
	survolat.emit(id, true)
	queue_redraw()


func _pe_iesire() -> void:
	_hover = false
	survolat.emit(id, false)
	queue_redraw()


func _gui_input(eveniment: InputEvent) -> void:
	if not activ:
		return
	if eveniment is InputEventMouseButton:
		var clic := eveniment as InputEventMouseButton
		if clic.button_index == MOUSE_BUTTON_LEFT and clic.pressed:
			# `accept_event()` oprește evenimentul aici. Fără el, clicul ar
			# călători mai departe prin scenă și ar putea fi prins a doua oară.
			accept_event()
			apasat.emit(id)

class_name FigurinaHarta
extends Control
## FIGURINA DE PE HARTĂ — piesa care stă pe nodul unde te afli ACUM.
##
## Pe harta de referință (`assets/art/demons_hand_reference.png`), locul în
## care ești nu e marcat cu un chenar sau cu o săgeată: e marcat cu un OBIECT
## pus pe masă, o piesă care stă peste semnul de dedesubt. Diferența nu e de
## stil, e de citire: un chenar spune „nodul ăsta e selectat" (limbaj de
## interfață), o piesă spune „eu sunt aici" (limbaj de joc de masă). Harta
## noastră e un pergament cu simboluri de cerneală; o piesă așezată pe el e
## singurul fel de „unde sunt" care nu strică iluzia.
##
## ─────────────────────────────────────────────────────────────
## CE ȘTIE ȘI CE NU ȘTIE FIȘIERUL ĂSTA
##
## Nu știe ce e o expediție, un nod, un PV sau un drum. Primește un PUNCT
## (centrul nodului pe care trebuie să stea) și se așază pe el. Harta hotărăște
## PE CARE nod stă; figurina hotărăște CUM stă pe el.
##
## E aceeași împărțire ca între `harta.gd` și `simbol_nod.gd`, și există din
## același motiv: săritura de la un nod la altul e o animație, adică ceva ce se
## întâmplă ÎN piesă, nu în ecranul care o ține. Harta spune doar „du-te acolo"
## (`sare_la`) și așteaptă să audă `salt_terminat`; cât ține, cât de sus urcă și
## pe ce curbă — toate stau aici.
##
## ─────────────────────────────────────────────────────────────
## DE CE STĂ PE NOD, NU PE CENTRUL LUI
##
## Un `TextureRect` centrat pe nod ar acoperi simbolul și ar arăta ca o
## insignă lipită deasupra. O piesă adevărată atinge masa cu TALPA: ancorarea e
## jos-centru, nu centru-centru, iar nodul de dedesubt își păstrează și aura, și
## X-ul de „parcurs" — figurina stă peste ele, nu în locul lor.
##
## Dar talpa NU se oprește pe centrul nodului. Prima variantă făcea exact asta
## și se vedea greșit: piesa părea că plutește deasupra semnului, fiindcă
## simbolul rămânea întreg sub ea, citibil, ca și cum ar fi fost două lucruri
## așezate unul lângă altul. Pe harta de referință, piesa stă PESTE semn: îi
## acoperă cea mai mare parte, iar din X se mai văd doar capetele. Două numere
## fac diferența — `INALTIME_FATA_DE_NOD` și `ADANCIME_TALPA` — și amândouă
## sunt scrise mai jos cu tot cu ce anume se vede când le miști.

## Săritura s-a terminat și piesa stă pe nodul cerut.
##
## Harta îl AȘTEAPTĂ (`await`) înainte să deschidă ce urmează la nodul ăla — lupta,
## odihna, magazinul. De-aia e semnal și nu `finished`-ul tween-ului lăsat la
## vedere: chemătorul are nevoie de „am ajuns", nu de unealta cu care am ajuns,
## iar coborârea de la prima alegere trebuie să-l anunțe la fel ca o săritură
## obișnuită, deși e altă mișcare.
signal salt_terminat


## Unde e imaginea. Dacă fișierul lipsește sau nu s-a importat încă, harta
## merge mai departe exact ca înainte — vezi `creeaza()`.
const CALE_IMAGINE := "res://assets/art/campaign_token.png"

## Cât de înaltă e piesa, față de latura unui nod.
##
## E un RAPORT, nu un număr de pixeli, și ăsta e tot rostul lui: mărimea
## nodului e aceeași la orice mărime de fereastră, deci și figurina arată la
## fel peste tot, fără să depindă de rezoluție. Dacă mâine nodurile se măresc,
## piesa se mărește odată cu ele, fără să umble nimeni aici.
##
## 1,09 e 1,45 (măsura din referință) micșorat cu un sfert, cerut dinadins.
## Referința desena piesa mai înaltă decât nodul cu aproape jumătate — bine ca
## să domine semnul, dar pe harta noastră nodurile stau mai des decât acolo, iar
## o piesă atât de mare intra cu umbra peste vecina de deasupra. La 1,09 piesa
## rămâne puțin mai înaltă decât nodul (deci tot se citește ca un OBIECT pus pe
## semn, nu ca încă un simbol), dar nu mai atinge nimic în jur.
##
## Marginile rămân cele măsurate atunci: sub 1,0 piesa intră în silueta nodului
## și redevine simbol; peste 1,5 ajunge peste nodul de deasupra, fiindcă două
## noduri vecine au între ele cam 125 px.
const INALTIME_FATA_DE_NOD := 1.09

## CÂT DE ADÂNC INTRĂ TALPA ÎN NOD, tot ca fracțiune din latura lui.
##
## 0 înseamnă „talpa fix pe centrul nodului" — și e greșit, deși sună corect:
## piesa crește atunci numai în sus, iar jumătatea de jos a simbolului rămâne
## neatinsă. Ochiul citește două desene, nu o piesă pusă pe un semn.
##
## 0,20 (≈18 px la un nod de 92) coboară talpa sub centru, cât să ascundă
## încrucișarea X-ului și partea de jos a simbolului. Numărul are o margine
## fizică, nu e doar gust: X-ul de „parcurs" se desenează între 0,26 și 0,74
## din caseta nodului, deci capetele lui de jos stau la 0,24 sub centru. Orice
## valoare sub 0,24 lasă capetele alea afară — exact cum arată referința. La
## 0,24 sau mai mult, X-ul dispare complet sub piesă și nu mai știi că ai fost
## acolo.
const ADANCIME_TALPA := 0.20

# ─────────────────────────────────────────────────────────
# SĂRITURA
#
# De ce sare, în loc să apară direct pe nodul nou: pe o tablă adevărată, mutarea
# se VEDE. Dacă piesa dispare de aici și apare acolo, legătura dintre nodul
# apăsat și noul „aici" e ceva ce jucătorul deduce; dacă sare, e ceva ce vede.
#
# Are și un rost practic, dincolo de „juice": la un nod de luptă, ecranul e
# înlocuit cu totul. Fără săritură, ultimul cadru de hartă pe care-l vezi e cel
# de DINAINTE de mutare — pleci în luptă fără să fi văzut niciodată piesa pe nodul
# ales. Cele câteva zecimi de secundă sunt exact răgazul în care ochiul leagă
# clicul de rezultatul lui.
#
# ─────────────────────────────────────────────────────────
# DE CE SĂRITURA NU E SIMETRICĂ
#
# Prima variantă urca și cobora la fel: un `sin` pe toată durata, adică un arc
# perfect, cu aceeași viteză la plecare și la sosire. Arăta corect și nu se
# simțea nimic — fiindcă o mișcare cu viteză constantă n-are moment. Ochiul
# vede un obiect plutind dintr-un loc în altul, nu o piesă trântită pe masă.
#
# Acum mișcarea are DOUĂ jumătăți cu caractere diferite:
#
#   URCAREA — lungă (0,30 s) și încetinind spre vârf, ca orice lucru aruncat în
#             sus. Tot aici se face aproape tot drumul pe ORIZONTALĂ: până în
#             vârf piesa e deja aproape deasupra nodului țintă.
#   CĂDEREA — scurtă (0,09 s) și accelerând, aproape pe verticală. Aceeași
#             înălțime străbătută în a treia parte din timp înseamnă de vreo
#             trei ori viteza — și exact raportul ăsta se citește ca un SLAM.
#
# Suma lor (0,39 s) e aproape cât dura săritura veche, deci expediția nu s-a
# lungit; doar timpul s-a împărțit altfel înăuntru.
#
# Aterizarea e momentul în care harta zguduie ecranul (vezi `_zguduie()` în
# `harta.gd`). Zguduitul nu stă aici dinadins: piesa nu știe că e un ecran în
# jurul ei, așa că semnalează „am ajuns" și cine ascultă hotărăște ce face cu
# informația — la fel ca la deschiderea nodului.
# ─────────────────────────────────────────────────────────

## Cât ține URCAREA, în secunde — de la nodul de plecare până în vârful arcului.
##
## Sub 0,25 nu se citește ca o mișcare, ci ca o tresărire. Peste 0,5 devine ceva
## ce AȘTEPȚI — iar o expediție are zeci de mutări, deci fiecare zecime se
## plătește de zeci de ori.
const DURATA_URCARE := 0.30

## Cât ține CĂDEREA. E scurtă dinadins: viteza slam-ului nu vine din altă
## formulă, ci din faptul că aceeași distanță se face în mai puțin timp.
##
## Sub 0,06 cade sub un cadru-două la 60 FPS și dispare pur și simplu: ai piesa
## sus, apoi jos, fără nimic între. Peste 0,15 raportul față de urcare scade sub
## dublu și redevine o coborâre obișnuită.
const DURATA_SLAM := 0.09

## Cât din drumul pe ORIZONTALĂ e gata în vârful arcului (0–1).
##
## 0,5 ar însemna un arc simetric — adică vechiul `sin`, doar scris în două
## bucăți. 0,88 împinge aproape tot mersul înainte în urcare, ca să rămână de
## făcut, la cădere, aproape numai verticala: piesa cade ÎN nod, nu spre el.
##
## Peste 0,95 începe să arate ca o oprire în aer urmată de o cădere separată —
## două mișcări, nu una.
const PARTE_ORIZONTALA_LA_URCARE := 0.88

## Cât de sus se ridică piesa, ca fracțiune din distanța dintre cele două noduri.
##
## Proporțional, nu fix, fiindcă un pas scurt și unul lung trebuie să arate ca
## aceeași mișcare făcută cu mai multă sau mai puțină forță. O înălțime fixă ar
## face pasul scurt să pară o trambulină și pe cel lung o târâre.
const INALTIME_SALT := 0.38

## Marginile înălțimii, în pixeli. Fără ele, un pas foarte scurt n-ar ridica
## piesa aproape deloc (ar aluneca, nu ar sări), iar unul foarte lung ar
## trimite-o în afara pergamentului.
const INALTIME_SALT_MINIMA := 24.0
const INALTIME_SALT_MAXIMA := 110.0

## De la ce înălțime cade piesa la PRIMA alegere din expediție, ca fracțiune din
## latura nodului.
##
## Cazul există fiindcă la începutul expediției (`pozitie == -1`) piesa nu stă
## nicăieri: n-are de UNDE să sară. Fără tratarea asta, prima mutare ar fi
## singura din toată expediția în care piesa pur și simplu apare — exact lucrul
## pe care săritura vine să-l scoată. Așa, intră în joc căzând pe nodul ales:
## aceeași aterizare, doar că venind de sus.
const INALTIME_COBORARE := 2.6

## Cât ține coborârea de la prima alegere.
##
## Nu e `DURATA_SLAM`, deși amândouă sunt căderi: de acolo de sus, 0,09 s ar
## însemna o viteză de câteva mii de pixeli pe secundă — piesa n-ar fi văzută
## venind, ar apărea direct aterizată. Drum mai lung, timp mai lung, aceeași
## accelerație la ochi.
const DURATA_COBORARE := 0.32

# ─────────────────────────────────────────────────────────────
# IMAGINEA, ȚINUTĂ PE CLASĂ
#
# `static` = un singur exemplar pentru tot jocul, nu unul per figurină. Azi e
# oricum o singură figurină pe ecran, dar încărcarea se face și la fiecare
# reconstruire a hărții (întorsul dintr-o luptă, ieșitul din magazin), iar
# `load()` + `get_image()` de fiecare dată ar fi o plimbare pe disc și o copiere
# din memoria plăcii video pentru un fișier pe care îl avem deja.
#
# `_incercat` ține minte și EȘECUL, nu doar reușita: un fișier lipsă trebuie
# căutat o singură dată, nu la fiecare hartă desenată.
# ─────────────────────────────────────────────────────────────

static var _textura: Texture2D = null
static var _regiune := Rect2()
static var _incercat := false

## UNDE E TALPA ÎN DREPTUNGHIUL DESENAT, ca fracțiune din el (0–1).
##
## Nu e (0,5 , 1) — adică nici mijlocul, nici marginea de jos — și ăsta e un
## amănunt pe care l-am aflat măsurând, nu privind:
##
##   • pe VERTICALĂ, ultimii 19 pixeli ai imaginii sunt UMBRA piesei, o pată
##     care se stinge de la 35% opacitate la zero. Cu talpa pe marginea de jos,
##     piesa s-ar sprijini pe umbra ei și ar sta cu vreo 5 px mai sus decât
##     trebuie. Talpa adevărată e ultimul rând de CERNEALĂ, nu ultimul rând de
##     pixeli.
##   • pe ORIZONTALĂ, umbra se revarsă spre dreapta, deci mijlocul
##     dreptunghiului (264) nu e mijlocul piesei (256). Centrată pe dreptunghi,
##     piesa ar sta cu 8 px de imagine pe lângă nod.
##
## Nici una din cifrele astea nu e scrisă în cod: se măsoară în `_masoara()`.
## Aici trăiește doar rezultatul, ca fracțiune — deci rămâne valabil la orice
## mărime desenăm piesa.
static var _talpa := Vector2(0.5, 1.0)

## De la ce opacitate în sus un pixel se pune la socoteală drept CERNEALĂ, nu
## umbră. Același prag ca în `simbol_nod.gd`, din același motiv: marginile
## desenelor au un halou de antialiasing care ar întinde forma cu o margine
## falsă.
const PRAG_CERNEALA := 0.35

## Latura nodului pe care a fost măsurată figurina. Ținută ca s-o poată folosi
## `ADANCIME_TALPA`: adâncimea e o fracțiune din NOD, nu din piesă — nodul e
## cel care are un X de acoperit.
var _inaltime_nod := 0.0

## Punctul din pergament deasupra căruia stă talpa, în coordonatele pânzei.
##
## În repaus e centrul nodului pe care ești; în timpul unei sărituri alunecă
## între centrul de plecare și cel de sosire. Înălțimea la care e ridicată piesa
## nu intră aici — vezi `_ridicare`.
##
## Poziția din ecran NU se ține separat: se calculează din ancoră (și din
## ridicare) la fiecare mișcare. Două surse pentru același adevăr înseamnă,
## într-o zi, o figurină care stă lângă nodul ei fiindcă una din ele n-a fost
## actualizată.
var ancora := Vector2.ZERO

## Cât de sus e ridicată piesa FAȚĂ DE ancoră, în pixeli. 0 = stă pe pergament.
##
## Ținută separat de ancoră, deși amândouă mișcă piesa, fiindcă răspund la două
## întrebări diferite: ancora spune PESTE CE PUNCT din pergament stă piesa (așa
## rămâne corectă și în zbor, alunecänd între cele două centre), iar asta spune
## cât de departe de pergament e talpa. Amestecate într-o singură poziție, n-am
## mai ști, la mijlocul unei sărituri, pe ce nod e piesa.
var _ridicare := 0.0

## Săritura în curs, dacă e vreuna. Ținută ca s-o putem OPRI: două sărituri
## suprapuse ar trage aceeași piesă spre două noduri deodată.
var _salt: Tween = null


## Fabrica figurinei: întoarce o piesă gata măsurată, sau `null` dacă imaginea
## nu e acolo.
##
## De ce `null` și nu o figurină goală: fiindcă „harta fără figurină" trebuie
## să fie exact harta de dinainte, fără niciun dreptunghi invizibil care
## prinde clicuri și fără vreo linie de „dacă n-am imagine, nu desena" pe
## traseul de desenare. Chemătorul are o singură întrebare de pus — „a ieșit
## ceva?" — și o pune o dată.
##
## `inaltime_nod` e latura nodului (`MARIME_NOD.y` în hartă). Nu o citim de
## acolo direct: fișierul ăsta n-are voie să știe de `harta.gd`, altfel n-ar
## mai fi o clasă separată, ar fi aceeași clasă scrisă în două fișiere.
static func creeaza(inaltime_nod: float) -> FigurinaHarta:
	if not _pregateste():
		return null

	var figurina := FigurinaHarta.new()
	# IGNORE, din același motiv ca la eticheta de hover: piesa stă PESTE nodul
	# curent și pe lângă vecinii lui. Dacă ar prinde ea mouse-ul, nodul de
	# dedesubt ar fi de neapăsat, iar vecinii atinși de umbra ei la fel.
	figurina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	figurina._inaltime_nod = inaltime_nod

	# Înălțimea vine din nod; lățimea vine din PROPORȚIA imaginii, ca piesa să
	# nu iasă turtită dacă altcineva schimbă desenul cu unul mai lat.
	var inaltime := inaltime_nod * INALTIME_FATA_DE_NOD
	figurina.size = Vector2(
		inaltime * _regiune.size.x / _regiune.size.y,
		inaltime
	)
	return figurina


## PUNE piesa cu talpa pe punctul dat, pe loc, fără animație.
##
## Așa ajunge piesa pe hartă la construirea ei și așa se mută când fereastra se
## redimensionează — ambele cazuri în care nu s-a MIȘCAT nimic în joc, doar s-a
## mutat hârtia de sub ea. O săritură acolo ar minți: ar arăta ca o mutare.
##
## Taie o săritură în curs, dacă există: o așezare e un ordin mai tare decât o
## animație — vezi `_opreste_saltul()` pentru ce se întâmplă cu cel care aștepta.
func aseaza_la(centru_nod: Vector2) -> void:
	_opreste_saltul()
	ancora = centru_nod
	_ridicare = 0.0
	_repoziteaza()


## SARE de pe nodul de acum pe cel dat, și strigă `salt_terminat` la aterizare.
##
## Mișcarea e desfăcută în două, exact ca o săritură adevărată: pe ORIZONTALĂ
## piesa înaintează de la un centru la altul, pe VERTICALĂ se ridică și cade.
## Ce le leagă nu mai e un arc simetric, ci două etape puse cap la cap — vezi
## nota lungă de la `DURATA_URCARE` pentru de ce.
##
## Tween-ul are AICI două `tween_method` la rând, nu paralele: puse unul după
## altul, al doilea pornește exact când primul s-a terminat, deci nu există
## nicio clipă în care două formule să tragă aceeași piesă. Fiecare etapă își
## primește propria „personalitate" (`set_ease` / `set_trans`) pe tweener-ul ei,
## nu pe tween: pe tween ar fi fost o singură curbă pentru amândouă, adică fix
## simetria pe care vrem s-o rupem.
##
## Ce NU s-a schimbat: în fiecare etapă, poziția și înălțimea se mișcă dintr-un
## SINGUR progres de la 0 la 1. Două tween-uri paralele pe x și pe y ar fi două
## ceasuri pentru aceeași mișcare, iar în ziua în care unul primește altă durată
## piesa ar ateriza pe lângă nod.
func sare_la(centru_nod: Vector2) -> void:
	_opreste_saltul()

	var plecare := ancora
	var distanta := plecare.distance_to(centru_nod)

	# Nod atins fără să te fi mișcat. Nu se întâmplă azi (nu poți apăsa nodul pe
	# care stai), dar o animație de zero pași ar fi un `await` care nu se mai
	# întoarce — iar harta ÎL AȘTEAPTĂ, deci ar rămâne înțepenită pe veci.
	if distanta < 1.0:
		aseaza_la(centru_nod)
		salt_terminat.emit()
		return

	var inaltime := clampf(
		distanta * INALTIME_SALT, INALTIME_SALT_MINIMA, INALTIME_SALT_MAXIMA)

	# Punctul din pergament peste care e piesa în vârful arcului. Nu e la
	# jumătatea drumului: e aproape deasupra nodului țintă, ca să rămână de
	# făcut la cădere aproape numai verticala.
	var varf := plecare.lerp(centru_nod, PARTE_ORIZONTALA_LA_URCARE)

	# `bind` lipește de funcție lucrurile care nu se schimbă în timpul etapei
	# (de unde, până unde, cât de sus). Tween-ul dă progresul ca PRIM argument,
	# iar ce e legat cu `bind` vine după el.
	_salt = create_tween()

	# URCAREA. `EASE_OUT` = pornește repede și încetinește — un obiect aruncat
	# în sus își pierde viteza pe măsură ce urcă. `TRANS_QUAD` fiindcă asta e
	# chiar forma căderii libere (distanța crește cu pătratul timpului).
	_salt.tween_method(
		_pe_pas_urcare.bind(plecare, varf, inaltime), 0.0, 1.0, DURATA_URCARE
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# CĂDEREA. Aceeași curbă citită invers: `EASE_IN` = pornește moale și se
	# grăbește. Pe o durată de trei ori mai scurtă, ultimii pixeli de dinainte
	# de impact sunt parcurși cu o viteză care se vede.
	_salt.tween_method(
		_pe_pas_cadere.bind(varf, centru_nod, inaltime), 0.0, 1.0, DURATA_SLAM
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	_salt.finished.connect(_pe_salt_terminat)


## COBOARĂ pe nod, venind de sus. Intrarea în joc, la prima alegere din
## expediție — vezi `INALTIME_COBORARE` pentru de ce există cazul ăsta.
##
## `EASE_IN` cu `TRANS_QUAD` = pornește încet și se grăbește, adică exact ce face
## un obiect care cade. Restul e identic cu o săritură — aceeași aterizare,
## același semnal la final — ca harta să nu aibă două feluri de așteptat.
func coboara_pe(centru_nod: Vector2) -> void:
	_opreste_saltul()

	var de_sus := _inaltime_nod * INALTIME_COBORARE
	ancora = centru_nod
	_ridicare = de_sus
	_repoziteaza()
	# Abia acum devine vizibilă: până aici era ascunsă fiindcă nu stătea pe
	# niciun nod, iar dacă am arăta-o înainte de `_repoziteaza()` ar clipi un
	# cadru în colțul pânzei, acolo unde o lasă un `position` încă nepus.
	visible = true

	_salt = create_tween()
	_salt.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_salt.tween_method(_pe_pas_coborare, de_sus, 0.0, DURATA_COBORARE)
	_salt.finished.connect(_pe_salt_terminat)


## Un cadru din URCARE. `pas` merge de la 0 (nodul de plecare, pe pergament) la
## 1 (vârful arcului, ridicat cu `inaltime`).
##
## Înălțimea urcă LINIAR în `pas`, nu după vreo formulă proprie: curba e deja în
## tween (`EASE_OUT`), care nu dă progresul uniform, ci încetinind. Dacă am pune
## o a doua curbă aici, s-ar înmulți cu prima și n-am mai ști din ce iese
## mișcarea pe care o vedem pe ecran.
func _pe_pas_urcare(
	pas: float, plecare: Vector2, varf: Vector2, inaltime: float
) -> void:
	ancora = plecare.lerp(varf, pas)
	_ridicare = pas * inaltime
	_repoziteaza()


## Un cadru din CĂDERE. `pas` merge de la 0 (vârful) la 1 (talpa pe nod).
## Restul de drum pe orizontală e mic — vezi `PARTE_ORIZONTALA_LA_URCARE` —
## deci ce se vede aici e aproape numai coborârea.
func _pe_pas_cadere(
	pas: float, varf: Vector2, sosire: Vector2, inaltime: float
) -> void:
	ancora = varf.lerp(sosire, pas)
	_ridicare = (1.0 - pas) * inaltime
	_repoziteaza()


## Un cadru din coborâre. Aici ancora nu se mișcă: doar înălțimea scade.
func _pe_pas_coborare(inaltime: float) -> void:
	_ridicare = inaltime
	_repoziteaza()


## Aterizarea, comună săriturii și coborârii: nimic nu mai e ridicat, talpa e pe
## nod, iar cine aștepta află.
##
## Punem explicit `_ridicare = 0` în loc să ne bazăm pe ultimul cadru al
## tween-ului: un tween se poate încheia cu o fracțiune de pixel rămasă, iar
## piesa trebuie să ATINGĂ nodul, nu să plutească aproape de el.
func _pe_salt_terminat() -> void:
	_salt = null
	_ridicare = 0.0
	_repoziteaza()
	salt_terminat.emit()


## Oprește o săritură începută, FĂRĂ să strige `salt_terminat`.
##
## Semnalul înseamnă „am ajuns", iar o săritură tăiată la mijloc n-a ajuns
## nicăieri; dacă ar striga, harta ar deschide nodul pentru o mutare care s-a
## anulat. (`kill()` nu emite nici `finished`, tocmai de-asta.)
##
## Obligația care vine la pachet: cine taie o săritură lasă un `await` atârnat.
## De-aia harta nu cheamă `aseaza_la()` cât timp piesa e în aer (vezi
## `_aseaza_nodurile`), iar singurul lucru care ar mai putea tăia săritura —
## reconstruirea hărții — se întâmplă abia DUPĂ ce s-a terminat.
func _opreste_saltul() -> void:
	if _salt != null:
		_salt.kill()
		_salt = null


## Din ancoră și ridicare → `position`. Singurul loc care atinge poziția.
func _repoziteaza() -> void:
	# Unde trebuie să AJUNGĂ talpa: sub centrul nodului, cât spune
	# `ADANCIME_TALPA`, minus cât e ridicată piesa de la pergament.
	var tinta := ancora + Vector2(
		0.0, _inaltime_nod * ADANCIME_TALPA - _ridicare)

	# `position` e colțul STÂNGA-SUS al oricărui Control, iar talpa nu e nici
	# în colț, nici la mijlocul marginii de jos: e punctul `_talpa` din
	# dreptunghi. Mergem înapoi din țintă exact cu cât stă talpa înăuntru.
	position = tinta - Vector2(size.x * _talpa.x, size.y * _talpa.y)


func _draw() -> void:
	# Desenăm doar DREPTUNGHIUL CU CERNEALĂ din PNG (`_regiune`), întins pe
	# toată caseta. Dacă am desena imaginea întreagă, cei ~137 de pixeli goi
	# din stânga și din dreapta ar intra la socoteală: piesa ar ieși mai mică
	# decât am cerut și decentrată față de nod, fiindcă golul nu e egal pe
	# ambele laturi.
	draw_texture_rect_region(_textura, Rect2(Vector2.ZERO, size), _regiune)


## Încarcă imaginea și îi măsoară conturul, o singură dată pentru tot jocul.
## Întoarce „avem cu ce desena?".
static func _pregateste() -> bool:
	if _incercat:
		return _textura != null
	_incercat = true

	# `exists()` înainte de `load()`: `load()` pe o cale inexistentă scrie o
	# eroare roșie în consolă, iar o consolă plină de erori AȘTEPTATE e o
	# consolă în care nu se mai văd erorile adevărate. (Același motiv ca în
	# `simbol_nod.gd`.)
	#
	# Atenție la un caz care arată ca un fișier lipsă fără să fie: un PNG
	# copiat în `assets/` cât timp editorul e închis nu există ca RESURSĂ până
	# nu-l importă Godot. Se importă singur la prima deschidere a editorului.
	if not ResourceLoader.exists(CALE_IMAGINE):
		print("FigurinaHarta: %s lipseste (sau nu e importat inca); harta merge fara figurina." % CALE_IMAGINE)
		return false

	_textura = load(CALE_IMAGINE) as Texture2D
	if _textura == null:
		print("FigurinaHarta: %s nu s-a putut incarca; harta merge fara figurina." % CALE_IMAGINE)
		return false

	_masoara(_textura)
	return true


## Măsoară, din imagine, DOUĂ lucruri diferite:
##
##   `_regiune` — ce DESENĂM: tot ce nu e transparent, umbra piesei inclusă.
##                Umbra face parte din desen; tăiată, piesa ar sta pe pergament
##                ca un autocolant.
##   `_talpa`   — unde ATINGE: ultimul rând și mijlocul CERNELII, adică ale
##                piesei fără umbră. Vezi nota lungă de la `_talpa`.
##
## Se măsoară, nu se scriu de mână, fiindcă numerele sunt ale imaginii de azi.
## În ziua în care desenul se reexportă cu alt spațiu în jur sau cu altă umbră,
## măsurătoarea se corectează singură; niște constante scrise aici ar rămâne
## greșite în tăcere, iar figurina ar pluti pe lângă nod fără nicio eroare.
##
## Plasa de siguranță, la orice pas care poate eșua: imaginea ÎNTREAGĂ și talpa
## în mijlocul marginii de jos. Piesa ar ieși ceva mai mică și cu câțiva pixeli
## mai sus, dar harta ar arăta-o.
static func _masoara(textura: Texture2D) -> void:
	_regiune = Rect2(Vector2.ZERO, textura.get_size())
	_talpa = Vector2(0.5, 1.0)

	var imagine := textura.get_image()
	if imagine == null:
		return

	# Godot importă PNG-urile comprimate pentru placa video, iar citirea
	# pixelilor pe o imagine comprimată ori se plânge, ori întoarce gunoi.
	# `duplicate()` înainte, fiindcă imaginea primită poate fi chiar cea a
	# texturii — n-avem de ce s-o stricăm pe a altcuiva.
	if imagine.is_compressed():
		imagine = imagine.duplicate() as Image
		if imagine.decompress() != OK:
			return

	# `get_used_rect()` face exact „cel mai mic dreptunghi în afara căruia
	# totul e transparent", și e scris în C++ — deci n-avem de parcurs din
	# GDScript cei 262 144 de pixeli ai imaginii.
	var folosit := imagine.get_used_rect()
	if folosit.size.x <= 0 or folosit.size.y <= 0:
		return
	_regiune = Rect2(folosit)

	var cerneala := _cutia_cernelii(imagine, folosit)
	if cerneala.size.x <= 0.0 or cerneala.size.y <= 0.0:
		return

	_talpa = Vector2(
		(cerneala.position.x + cerneala.size.x * 0.5 - _regiune.position.x) / _regiune.size.x,
		(cerneala.position.y + cerneala.size.y - _regiune.position.y) / _regiune.size.y
	)


## Cutia pixelilor cu adevărat opaci, căutată dinspre marginile regiunii spre
## înăuntru.
##
## De ce nu „parcurg toată imaginea și rețin minimul și maximul": fiindcă
## `get_pixel()` chemat de 262 144 de ori din GDScript e o pauză simțită, iar
## noi avem nevoie de trei margini, nu de toate. Căutarea se oprește la primul
## rând (sau prima coloană) care are cerneală, deci citește câteva mii de
## pixeli, nu sute de mii.
##
## `PAS` sare din doi în doi pixeli de-a lungul marginii cercetate. O margine
## poate ieși cu un pixel greșită — adică un sfert de pixel pe ecran, la cât de
## mult micșorăm imaginea. Pentru asta nu merită de patru ori munca.
##
## Marginea de SUS nu se caută: nimic din ce calculăm nu depinde de ea. Talpa e
## jos, mijlocul se află din stânga și dreapta, iar înălțimea desenată e a
## regiunii, nu a cernelii.
static func _cutia_cernelii(imagine: Image, zona: Rect2i) -> Rect2:
	const PAS := 2
	var x0 := zona.position.x
	var x1 := zona.end.x - 1
	var y0 := zona.position.y
	var y1 := zona.end.y - 1

	var jos := -1
	for y in range(y1, y0 - 1, -1):
		if _are_cerneala(imagine, x0, x1, y, true, PAS):
			jos = y
			break
	if jos < 0:
		return Rect2()

	var stanga := -1
	for x in range(x0, x1 + 1):
		if _are_cerneala(imagine, y0, y1, x, false, PAS):
			stanga = x
			break

	var dreapta := -1
	for x in range(x1, x0 - 1, -1):
		if _are_cerneala(imagine, y0, y1, x, false, PAS):
			dreapta = x
			break

	if stanga < 0 or dreapta < stanga:
		return Rect2()
	# Înălțimea nu contează pentru nimeni: din cutia asta se citesc doar
	# marginea de jos și mijlocul pe orizontală. O pornim de la capătul de sus
	# al zonei, ca să fie totuși un dreptunghi valid.
	return Rect2(stanga, y0, dreapta - stanga + 1, jos - y0 + 1)


## Are rândul (`orizontal = true`) sau coloana (`false`) `unde` măcar un pixel
## mai opac decât pragul, între `de_la` și `pana_la`?
static func _are_cerneala(
	imagine: Image, de_la: int, pana_la: int, unde: int, orizontal: bool, pas: int
) -> bool:
	for i in range(de_la, pana_la + 1, pas):
		var culoare := imagine.get_pixel(i, unde) if orizontal else imagine.get_pixel(unde, i)
		if culoare.a > PRAG_CERNEALA:
			return true
	return false

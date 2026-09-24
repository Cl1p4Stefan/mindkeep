class_name BandaCifre
extends Node2D
## O ROATĂ A CUFĂRULUI — o bandă de cifre care se învârte la nesfârșit.
##
## Nu e un obiect rotund: e o panglică de cifre desenată de sus în jos, care se
## repetă. Prin fereastra tăiată în placa de metal se vede o bucată din ea — în
## repaus, exact o cifră — iar umbra de sus și de jos face restul: ochiul
## completează un cilindru care se rotește. Cât tragi de roată, cifrele intră și
## ies prin fereastră, una câte una.
##
## ─────────────────────────────────────────────────────────────
## DE CE STĂ ÎN SPATELE IMAGINII, ȘI DE CE ASTA E TOT TRUCUL
##
## Banda se desenează ÎNAINTE de imaginea cufărului, deci imaginea se așază
## peste ea. Poza e opacă peste tot, în afară de cele patru ferestre — care sunt
## găuri adevărate în PNG. Deci ce se vede din bandă e exact ce lasă gaura să
## treacă: NU tai nimic, nu scriu nicio mască. **Poza cufărului E masca.**
##
## Singura grijă care rămâne: banda nu are voie să crească mai mare decât placa
## de metal din jurul ferestrei, fiindcă dincolo de marginile cufărului poza e
## iar transparentă și cifrele ar ieși în aer. De-aia desenează doar câteva
## cifre în jurul celei curente (`CIFRE_DESENATE`), nu toate nouă.
##
## Tot de-aia banda își pictează ÎNTÂI un fond întunecat: prin gaură s-ar vedea
## altfel fundalul scenei, și ai avea un lacăt cu ferestre spre nicăieri.
##
## ─────────────────────────────────────────────────────────────
## CE NU ȘTIE
##
## Nu știe ce e un cifru, un indiciu, o încercare sau o victorie. Știe să stea
## pe o cifră, să fie trasă cu mouse-ul, să se oprească frumos și să strige când
## trece peste o cifră. Restul e treaba lui `cifru.gd`.

## A trecut peste o cifră nouă — momentul clicului mecanic.
signal clic

## S-a oprit exact pe o cifră. `cifru.gd` nu-l folosește azi, dar e semnalul
## după care se așteaptă „s-au liniștit toate roțile".
signal asezata


# ─────────────────────────────────────────────────────────────
# SENZAȚIA — toate numerele care fac roata să pară grea sau ușoară
#
# Sunt aici, sus, împreună, fiindcă se reglează ÎMPREUNĂ: o roată bună e un
# echilibru între cât de departe zboară și cât de repede se oprește. Dacă
# umbli la unul singur, o să-l cauți pe celălalt imediat.
# ─────────────────────────────────────────────────────────────

## Distanța dintre două cifre pe bandă, ca fracțiune din înălțimea ferestrei.
##
## PESTE 1 înseamnă că pasul e mai mare decât fereastra, deci ÎN REPAUS se vede
## o singură cifră, întreagă, iar vecinele stau ascunse în spatele metalului.
## Așa arată un cifru de cufăr adevărat: o fereastră, o cifră. Sub 1, vecinele
## își arată o bucată permanent, iar fereastra devine o listă din care citești.
##
## Nu schimbă nimic la mișcare: cât tragi de roată, cifrele intră și ies prin
## fereastră exact ca înainte, doar că trec una câte una, fără să se vadă două
## deodată decât în treacăt.
##
## 1,12 lasă ~50 de pixeli de metal între cifra din fereastră și marginea
## vecinei. Mai mic = vecinele încep să se iţească; mult mai mare = între cifre
## apare un gol negru lung când tragi, și banda pare goală.
const PAS_CIFRA := 1.12

## Câte cifre se desenează, în total, în jurul celei curente. Cu pasul de mai
## sus ar ajunge trei (centru + una sus + una jos); cinci e marja, și nu costă
## nimic — cele care cad complet în afara ferestrei sunt sărite la desen, deci
## nu pot ajunge niciodată dincolo de placa de metal.
const CIFRE_DESENATE := 5

## Cât de tare frânează inerția, pe secundă. E un factor de amortizare
## exponențială: la 6, viteza scade la un sfert în ~0,23 s. Mai mic = roata
## zboară mult (pare ușoară, de plastic); mai mare = se oprește imediat (pare
## înțepenită).
const FRECARE := 6.0

## Sub câte cifre pe secundă se consideră că roata „s-a oprit" și începe
## așezarea pe cifra cea mai apropiată.
const VITEZA_DE_ASEZARE := 0.7

## Cât de repede se lipește de cifră, odată ce s-a hotărât. Tot amortizare
## exponențială: la 14, ajunge la 1% din distanță în ~0,33 s. E numărul care
## face diferența dintre „se așază" și „sare".
const ASEZARE := 14.0

## Plafonul de viteză, în cifre pe secundă. Fără el, o smucitură scurtă de
## mouse poate arunca roata în zeci de rotații, iar banda devine o ceață.
const VITEZA_MAXIMA := 26.0

## Cât ține pasul cerut de rotiță sau de tastatură. Nu e o durată exactă
## (așezarea e exponențială, deci teoretic infinită), ci ordinul de mărime al
## mișcării — sub 0,1 s pasul pare o tăietură, peste 0,3 s pare leneș.
const DURATA_UNUI_PAS := 0.16

## Cât de departe de cifră se consideră „ajuns" și se oprește socoteala.
const PRAG_OPRIRE := 0.004


# ── ÎNFĂȚIȘAREA ───────────────────────────────────────────────

## CÂT DIN ÎNĂLȚIMEA FERESTREI ocupă o cifră. E o fracțiune, nu o mărime de
## font, fiindcă asta e proprietatea care contează: o cifră trebuie să umple
## fereastra, oricât de mare ar fi ea. Dacă arta se redesenează cu ferestre mai
## înalte, cifrele cresc odată cu ele, singure.
##
## 0,70 lasă câte 15% de metal deasupra și dedesubt — destul cât cifra să pară
## încadrată, nu înghesuită. Peste ~0,85 începe să atingă marginile.
const INALTIME_CIFRA := 0.70

## CÂT DIN MĂRIMEA FONTULUI e, efectiv, înălțimea unei cifre.
##
## „Mărimea fontului" nu e înălțimea literelor: e o măsură din care fiecare font
## își croiește literele cum vrea, plus spațiul de deasupra și de dedesubt (unde
## încap accentele și coada lui „p"). Pentru fontul implicit al motorului, o
## cifră ocupă cam 72% din ea — măsurat pe ecran, nu citit din documentație.
##
## E constantă separată tocmai fiindcă e o proprietate A FONTULUI, nu o
## preferință: în ziua în care Mindkeep primește un font propriu, ăsta e numărul
## de re-măsurat, iar `INALTIME_CIFRA` rămâne neatins.
const RAPORT_CIFRA := 0.72

## Fundul lacătului: metal neluminat. Se vede prin gaură, în spatele cifrelor.
const CULOARE_FUND := Color(0.085, 0.068, 0.056)

## Cifrele: alamă caldă, ca inelele de pe placă.
const CULOARE_CIFRA := Color(0.93, 0.85, 0.66)

## Cifra roții SUDATE. Mai stinsă și mai verzuie — patina de pe colțarele
## cufărului. Nu e „gri, deci dezactivat": e o piesă de metal, nu un buton.
const CULOARE_CIFRA_BLOCATA := Color(0.62, 0.66, 0.55)

## Fundul roții sudate: un dop de metal, mai deschis decât gaura, ca să se vadă
## că ACOLO nu e o bandă care se învârte, ci o placă.
const CULOARE_FUND_BLOCAT := Color(0.16, 0.15, 0.13)

## Cât de tare întunecă umbra de cilindru la marginea de sus și de jos.
const UMBRA := 0.85

## Cât din înălțimea ferestrei ocupă umbra, la fiecare capăt.
const INALTIME_UMBRA := 0.34

## Aurul aprinderii, la deschidere.
const CULOARE_APRINSA := Color(1.0, 0.92, 0.62)


enum Stare { STATIVA, TRASA, INERTIE, ASEZARE }


# ── STAREA ────────────────────────────────────────────────────

## Fereastra, în pixelii imaginii: doar MĂRIMEA. Poziția e `position`, pusă de
## `cifru.gd` din `ferestre.json`.
var fereastra := Vector2(104, 182)

var minim := 1
var maxim := 9

## Unde e banda, în „cifre". Numărul întreg `n` înseamnă „cifra n e fix în
## mijlocul ferestrei"; 2,5 înseamnă că e la jumătatea drumului spre următoarea.
## Poate fi orice număr, inclusiv negativ: cifra se află din `posmod`, deci
## banda chiar n-are capete.
var pozitie := 0.0

var viteza := 0.0
var stare: int = Stare.STATIVA
var tinta := 0.0

## Roata sudată: nu se mai atinge, nu se mai învârte, arată altfel.
var blocata := false

## Cât de aprinsă e roata, de la 0 la 1. Se animează la deschiderea cufărului.
var stralucire := 0.0:
	set(valoare):
		stralucire = valoare
		queue_redraw()

## Ultima cifră peste care a trecut centrul ferestrei. Ca să știu CÂND să
## strig clicul: nu la fiecare cadru, ci la fiecare cifră trecută.
var _ultima_cifra := 0

## Umbra de cilindru, construită o dată. E un degrade vertical: întunecat sus,
## limpede la mijloc, întunecat jos. Un `GradientTexture2D` în loc de douăzeci
## de dreptunghiuri desenate manual — e mai lin și se desenează dintr-o mișcare.
var _umbra: GradientTexture2D = null


func _ready() -> void:
	set_process(false)   # nimic nu se mișcă până nu e clintit ceva
	_ultima_cifra = roundi(pozitie)
	_pregateste_umbra()


func _pregateste_umbra() -> void:
	var degrade := Gradient.new()
	degrade.offsets = PackedFloat32Array([0.0, INALTIME_UMBRA, 1.0 - INALTIME_UMBRA, 1.0])
	degrade.colors = PackedColorArray([
		Color(0, 0, 0, UMBRA), Color(0, 0, 0, 0.0),
		Color(0, 0, 0, 0.0), Color(0, 0, 0, UMBRA)])
	_umbra = GradientTexture2D.new()
	_umbra.gradient = degrade
	# Degradeul merge de sus în jos: două puncte pe verticală, în coordonate
	# relative (0 = marginea de sus a texturii, 1 = cea de jos).
	_umbra.fill_from = Vector2(0, 0)
	_umbra.fill_to = Vector2(0, 1)
	_umbra.width = 4          # e un degrade vertical: lățimea nu contează
	_umbra.height = 128       # destul cât să nu se vadă trepte


# ─────────────────────────────────────────────────────────────
# CE POATE FACE ROATA
# ─────────────────────────────────────────────────────────────

## Cifra din mijlocul ferestrei acum.
func cifra() -> int:
	return _cifra_la(roundi(pozitie))


## Ce cifră stă pe treapta `n` a benzii. Aici se vede că banda n-are capete:
## `posmod` întoarce mereu un rest pozitiv, deci treapta −1 e tot o cifră bună.
func _cifra_la(n: int) -> int:
	return minim + posmod(n, maxim - minim + 1)


## Pune roata direct pe o cifră, fără animație. Pentru așezarea inițială.
func pune_direct(c: int) -> void:
	pozitie = float(c - minim)
	tinta = pozitie
	viteza = 0.0
	stare = Stare.STATIVA
	_ultima_cifra = roundi(pozitie)
	set_process(false)
	queue_redraw()


## Mută roata cu un pas, animat. Rotița mouse-ului și săgețile.
func pas(directie: int) -> void:
	if blocata:
		return
	_spre(roundi(tinta if stare == Stare.ASEZARE else pozitie) + directie)


## Du roata pe cifra cerută, pe drumul cel mai scurt. Tastarea unei cifre.
##
## „Cel mai scurt" e important pe o bandă fără capete: de la 9 la 1 sunt opt
## trepte în jos și una în sus, iar roata trebuie s-o ia pe unde ar lua-o mâna.
func spre_cifra(c: int, ture := 0) -> void:
	if blocata:
		return
	var interval := maxim - minim + 1
	var acum := roundi(pozitie)
	var diferenta := posmod(c - _cifra_la(acum), interval)
	if diferenta > interval / 2 and ture == 0:
		diferenta -= interval      # mai aproape pe drumul celălalt
	_spre(acum + diferenta + ture * interval)


func _spre(treapta: int) -> void:
	tinta = float(treapta)
	stare = Stare.ASEZARE
	set_process(true)


## Începe tragerea cu mouse-ul.
func prinde() -> void:
	if blocata:
		return
	stare = Stare.TRASA
	viteza = 0.0
	set_process(true)


## Trage banda cu `cifre` trepte (poate fi fracționar). 1:1 cu mouse-ul:
## conversia din pixeli în trepte o face `cifru.gd`, fiindcă doar el știe cât
## de aproape e camera.
func trage(cifre: float, viteza_acum: float) -> void:
	if blocata or stare != Stare.TRASA:
		return
	pozitie += cifre
	viteza = clampf(viteza_acum, -VITEZA_MAXIMA, VITEZA_MAXIMA)
	_verifica_clicul()
	queue_redraw()


## Dă drumul: de aici încolo o duce inerția.
func elibereaza() -> void:
	if blocata or stare != Stare.TRASA:
		return
	stare = Stare.INERTIE
	set_process(true)


func _process(delta: float) -> void:
	match stare:
		Stare.INERTIE:
			pozitie += viteza * delta
			# Amortizare exponențială: viteza se înmulțește cu un număr
			# subunitar la fiecare cadru. `exp(-k·dt)` face frânarea să nu
			# depindă de câte cadre pe secundă merge jocul — cu o scădere
			# liniară, roata ar zbura mai departe pe un calculator rapid.
			viteza *= exp(-FRECARE * delta)
			if absf(viteza) < VITEZA_DE_ASEZARE:
				tinta = roundf(pozitie)
				stare = Stare.ASEZARE
		Stare.ASEZARE:
			# Același fel de mișcare, dar spre un punct: se apropie repede la
			# început și tot mai lin la final. Asta e „se așază", nu „ajunge".
			pozitie = lerpf(pozitie, tinta, 1.0 - exp(-ASEZARE * delta))
			if absf(tinta - pozitie) < PRAG_OPRIRE:
				pozitie = tinta
				viteza = 0.0
				stare = Stare.STATIVA
				set_process(false)
				_verifica_clicul()
				queue_redraw()
				asezata.emit()
				return
		_:
			return   # STATIVA sau TRASA: nu se mișcă singură

	_verifica_clicul()
	queue_redraw()


## Clicul mecanic: o dată la fiecare cifră peste care trece centrul ferestrei.
func _verifica_clicul() -> void:
	var acum := roundi(pozitie)
	if acum != _ultima_cifra:
		_ultima_cifra = acum
		clic.emit()


# ─────────────────────────────────────────────────────────────
# DESENUL
# ─────────────────────────────────────────────────────────────

func _draw() -> void:
	var caseta := Rect2(Vector2.ZERO, fereastra)

	# 1. FUNDUL. Fără el s-ar vedea prin gaură fundalul scenei.
	draw_rect(caseta, CULOARE_FUND_BLOCAT if blocata else CULOARE_FUND)

	var font := ThemeDB.fallback_font
	var pas := fereastra.y * PAS_CIFRA
	var mijloc := fereastra.y * 0.5

	if blocata:
		# 2a. ROATA SUDATĂ: o singură cifră, pe o placă. Fără vecine, fără umbră
		# de cilindru — n-are ce să se rotească. Asta e tot ce trebuie ca să se
		# vadă din prima că roata aia nu se atinge; nicio explicație scrisă
		# n-ar face-o mai clar.
		_scrie(font, mijloc, str(cifra()), CULOARE_CIFRA_BLOCATA)
		draw_rect(caseta, Color(0, 0, 0, 0.18))
		return

	# 2b. BANDA. Cifra `n` stă la (pozitie − n) pași de mijloc: când `pozitie`
	# crește, cifrele coboară — exact cum se mișcă sub deget.
	var centru := roundi(pozitie)
	var margine: int = (CIFRE_DESENATE - 1) / 2
	for k in range(-margine, margine + 1):
		var n := centru + k
		var y := mijloc + (pozitie - n) * pas
		if y < -pas or y > fereastra.y + pas:
			continue   # cifra a ieșit complet din fereastră
		var culoare := CULOARE_CIFRA
		if stralucire > 0.0:
			culoare = CULOARE_CIFRA.lerp(CULOARE_APRINSA, stralucire)
		_scrie(font, y, str(_cifra_la(n)), culoare)

	# 3. UMBRA DE CILINDRU, peste cifre: întuneric la capete, lumină la mijloc.
	# Fără ea, banda arată ca o listă care alunecă; cu ea, ca o suprafață care
	# se curbează și fuge din fața ochiului.
	if _umbra != null:
		draw_texture_rect(_umbra, caseta, false)

	# 4. APRINDEREA, la deschiderea cufărului: o pată caldă peste tot geamul.
	if stralucire > 0.0:
		draw_rect(caseta, Color(CULOARE_APRINSA, 0.42 * stralucire))


## Mărimea de font care face cifra să ocupe `INALTIME_CIFRA` din fereastră.
## Se calculează din fereastră, deci se potrivește singură la orice artă.
func _marime_cifra() -> int:
	return maxi(int(round(fereastra.y * INALTIME_CIFRA / RAPORT_CIFRA)), 1)


## Scrie o cifră CENTRATĂ pe orizontală în fereastră, cu mijlocul ei la `y`.
##
## `draw_string` primește linia de bază (talpa literelor), nu mijlocul lor — de
## aia nu e destul să dai `y`. Iar centrarea se face după înălțimea CIFREI, nu
## după înălțimea rândului: rândul include spațiul pentru accente și pentru
## coada lui „p", pe care o cifră nu-l folosește. Centrat după rând, „7" ar sta
## vizibil prea sus în fereastră.
func _scrie(font: Font, y: float, text: String, culoare: Color) -> void:
	if font == null:
		return
	var marime := _marime_cifra()
	var baza := y + marime * RAPORT_CIFRA * 0.5
	draw_string(font, Vector2(0, baza), text, HORIZONTAL_ALIGNMENT_CENTER,
		fereastra.x, marime, culoare)

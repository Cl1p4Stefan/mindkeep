extends Control
## Reacția unei figuri când încasează daune: un fulger scurt și un tremurat
## care se stinge. Înlocuiește respirația de dinainte — o imagine realistă care
## se umflă ritmic arată artificial, dar una care încasează o lovitură arată viu
## exact în momentul în care trebuie.
##
## Efectul e PROPORȚIONAL cu daunele, nu fix. Într-un lanț lung, o lovitură de
## 1 și una critică de 6 arătau identic: tremuratul devenea zgomot de fundal, iar
## criticul — momentul pentru care riști treapta a 5-a — nu se distingea cu
## nimic. Acum mărimea loviturii se VEDE, deci ecranul îți spune același lucru
## ca jurnalul, doar mai repede.
##
## Nodul ăsta e un ÎNVELIȘ: nu desenează nimic el însuși, doar ține figura
## înăuntru (silueta desenată sau imaginea) și o clatină.
##
## De ce e nevoie de înveliș, și nu clătinăm direct imaginea: figura stătea
## direct într-un `VBoxContainer`, iar containerele REscriu `position` la
## fiecare recalculare de layout. Prima recalculare vine exact când se schimbă
## textul de PV — adică fix la lovitură — și ar fi retezat tremuratul în cadrul
## în care contează. Învelișul rămâne copilul containerului și e poziționat de
## el; figura dinăuntru atârnă de un `Control` obișnuit, care nu-i mișcă nimic.
##
## De ce nu `Tween`: efectul se poate declanșa din nou înainte să se termine
## (lanț rapid, lovituri în serie). Cu două cronometre pe care le pui la loc pe
## maxim, o lovitură nouă o reia curat pe cea veche — cu tween-uri ar fi trebuit
## să le omori manual și să repari poziția rămasă la jumătatea drumului.

## Cât ține fulgerul, și cât durează tremuratul, pentru o lovitură de mărime
## normală. Scurt: e un accent, nu o lumină aprinsă.
const DURATA_FLASH := 0.12
const DURATA_TREMUR := 0.28

## Cât de tare clatină la început (în pixeli), tot pentru lovitura normală.
const AMPLITUDINE := 8.0

## Cât de repede oscilează. Mai mare = mai nervos.
const FRECVENTA := 42.0

## Culoarea la vârful fulgerului. Peste 1.0 înseamnă „mai luminos decât
## originalul" — pe o armură întunecată, un alb obișnuit n-ar face nimic.
const CULOARE_FLASH := Color(2.4, 2.2, 2.0)

## Lovitura de REFERINȚĂ: câte daune înseamnă „normal", adică exact valorile
## scrise mai sus. E 3 fiindcă asta e treapta III, valoarea la care se așază
## lanțul și deci lovitura pe care o vezi cel mai des. O lovitură de 1 iese la
## o treime din efect; una critică de 6, la dublu.
const DAUNE_REFERINTA := 3.0

## Podeaua și plafonul intensității.
## Podeaua (0.4) ține lovitura de 1 la un fior abia perceptibil, dar nu la
## nimic — o lovitură care nu se vede deloc pare un bug, nu o lovitură slabă.
## Plafonul (2.0) e plasa de siguranță pentru mai târziu: când o relicvă sau un
## bos va lovi cu 20, figura nu trebuie să sară din ecran.
const INTENSITATE_MIN := 0.4
const INTENSITATE_MAX := 2.0

## Cât din intensitate se scurge în DURATĂ. Amplitudinea se scalează integral
## (dublu = dublu), dar durata doar puțin: un tremurat de două ori mai lung ar
## încetini lanțul, iar lanțul e tot ce ține combo-ul viu. Formula de mai jos dă
## ×0.76 la lovitura minimă, ×1 la cea normală și ×1.4 la critic — cât să simți
## că lovitura critică „atârnă" o clipă în plus.
const DURATA_BAZA := 0.6
const DURATA_PE_INTENSITATE := 0.4

var _timp_flash := 0.0
var _timp_tremur := 0.0

# Cât DE MULT durează efectul aflat acum în curs. Nu mai sunt constante,
# fiindcă se recalculează la fiecare lovitură — dar `_process` are nevoie de
# ele ca să știe cât din efect a trecut (t = cât a rămas / cât a fost total).
var _durata_flash := DURATA_FLASH
var _durata_tremur := DURATA_TREMUR

# Mărimea loviturii care se joacă acum, ca multiplicator față de normal.
var _intensitate := 1.0


func _ready() -> void:
	# `_process` stă oprit cât nu se întâmplă nimic: o figură nelovită nu are
	# de ce să consume un cadru.
	set_process(false)


## SINGURUL punct de intrare. Lupta cheamă asta când figura încasează daune,
## și îi spune CÂTE. Valoarea implicită (daunele de referință) e acolo ca un
## `loveste()` fără argument să însemne „o lovitură normală" — dacă apare un
## efect viitor care lovește fără un număr, nu trebuie să inventeze unul.
func loveste(daune: int = int(DAUNE_REFERINTA)) -> void:
	var intensitate := clampf(daune / DAUNE_REFERINTA, INTENSITATE_MIN, INTENSITATE_MAX)

	# Dacă un tremurat e deja în curs, păstrăm intensitatea mai MARE dintre
	# cele două. Altfel, o lovitură de 1 căzută imediat după un critic ar
	# retrograda pe loc efectul criticului la un fior — adică exact momentul pe
	# care vrem să-l scoatem în evidență ar fi șters de următorul răspuns.
	if _timp_tremur > 0.0:
		intensitate = maxf(intensitate, _intensitate)
	_intensitate = intensitate

	# Durata se recalculează o dată aici, nu la fiecare cadru în `_process`:
	# e aceeași pentru tot efectul, iar `_process` doar o citește.
	var factor_durata := DURATA_BAZA + DURATA_PE_INTENSITATE * _intensitate
	_durata_flash = DURATA_FLASH * factor_durata
	_durata_tremur = DURATA_TREMUR * factor_durata

	# Punem cronometrele la maxim. Dacă efectul era deja în curs, o lovitură
	# nouă îl reia de la capăt — exact ce vrei într-un lanț rapid.
	_timp_flash = _durata_flash
	_timp_tremur = _durata_tremur
	set_process(true)


func _process(delta: float) -> void:
	_timp_flash = maxf(_timp_flash - delta, 0.0)
	_timp_tremur = maxf(_timp_tremur - delta, 0.0)

	# FULGERUL. `t` merge de la 1 (chiar acum) spre 0 (gata), iar `lerp` pe
	# culori amestecă între alb normal și alb aprins. Modulate se moștenește
	# de copii, deci figura dinăuntru se luminează odată cu învelișul.
	#
	# `_intensitate` intră ÎNMULȚIND distanța până la culoarea de vârf. Peste
	# 1.0, `lerp` nu se oprește la capăt — continuă dincolo de el (extrapolare),
	# deci un critic chiar arde mai tare decât „maximul" scris în constantă.
	var t_flash := _timp_flash / _durata_flash
	modulate = Color.WHITE.lerp(CULOARE_FLASH, t_flash * _intensitate)

	# TREMURATUL. `sin` dă oscilația, iar `t` o stinge treptat: puternic la
	# impact, aproape nimic la final. Fără stingere ar arăta ca o vibrație
	# care se oprește brusc, nu ca o lovitură încasată.
	var t_tremur := _timp_tremur / _durata_tremur
	var amplitudine := AMPLITUDINE * _intensitate
	_deplaseaza(sin(_timp_tremur * FRECVENTA) * amplitudine * t_tremur)

	if _timp_flash == 0.0 and _timp_tremur == 0.0:
		_deplaseaza(0.0)
		modulate = Color.WHITE
		set_process(false)


## Mută figurile dinăuntru pe orizontală. Scriem poziția ABSOLUT, nu adunăm la
## ea: așa nu se poate acumula o derivă dacă efectul e întrerupt la mijloc.
func _deplaseaza(dx: float) -> void:
	for copil in get_children():
		var control := copil as Control
		if control != null:
			control.position.x = dx

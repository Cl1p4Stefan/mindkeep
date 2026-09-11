extends Control
## Reacția unei figuri când încasează daune: un fulger scurt și un tremurat
## care se stinge. Înlocuiește respirația de dinainte — o imagine realistă care
## se umflă ritmic arată artificial, dar una care încasează o lovitură arată viu
## exact în momentul în care trebuie.
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

## Cât ține fulgerul. Scurt: e un accent, nu o lumină aprinsă.
const DURATA_FLASH := 0.12

## Cât ține tremuratul, și cât de tare clatină la început (în pixeli).
const DURATA_TREMUR := 0.28
const AMPLITUDINE := 8.0

## Cât de repede oscilează. Mai mare = mai nervos.
const FRECVENTA := 42.0

## Culoarea la vârful fulgerului. Peste 1.0 înseamnă „mai luminos decât
## originalul" — pe o armură întunecată, un alb obișnuit n-ar face nimic.
const CULOARE_FLASH := Color(2.4, 2.2, 2.0)

var _timp_flash := 0.0
var _timp_tremur := 0.0


func _ready() -> void:
	# `_process` stă oprit cât nu se întâmplă nimic: o figură nelovită nu are
	# de ce să consume un cadru.
	set_process(false)


## SINGURUL punct de intrare. Lupta cheamă asta când figura încasează daune.
func loveste() -> void:
	# Punem cronometrele la maxim. Dacă efectul era deja în curs, o lovitură
	# nouă îl reia de la capăt — exact ce vrei într-un lanț rapid.
	_timp_flash = DURATA_FLASH
	_timp_tremur = DURATA_TREMUR
	set_process(true)


func _process(delta: float) -> void:
	_timp_flash = maxf(_timp_flash - delta, 0.0)
	_timp_tremur = maxf(_timp_tremur - delta, 0.0)

	# FULGERUL. `t` merge de la 1 (chiar acum) spre 0 (gata), iar `lerp` pe
	# culori amestecă între alb normal și alb aprins. Modulate se moștenește
	# de copii, deci figura dinăuntru se luminează odată cu învelișul.
	var t_flash := _timp_flash / DURATA_FLASH
	modulate = Color.WHITE.lerp(CULOARE_FLASH, t_flash)

	# TREMURATUL. `sin` dă oscilația, iar `t` o stinge treptat: puternic la
	# impact, aproape nimic la final. Fără stingere ar arăta ca o vibrație
	# care se oprește brusc, nu ca o lovitură încasată.
	var t_tremur := _timp_tremur / DURATA_TREMUR
	_deplaseaza(sin(_timp_tremur * FRECVENTA) * AMPLITUDINE * t_tremur)

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

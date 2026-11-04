extends Button
class_name InchideX
## Butonul „închide" al panoului cu reguli: două linii desenate, fără nimic în
## jur.
##
## ─────────────────────────────────────────────────────────────
## DE CE E DESENAT, ȘI NU SCRIS
##
## A fost un `Button` cu textul „✕" și cu un inel în jur. Într-o captură făcută
## pe 4 noiembrie 2026 se vedea inelul și NIMIC înăuntru: „✕" (U+2715) nu e în
## Cinzel, nu e în Alegreya și nu e în fontul implicit, deci jocul nu l-a
## desenat niciodată — pe Windows îl împrumuta de la sistem
## (`FontFile.allow_system_fallback`), tăcut, iar aici nici atât.
##
## E a cincea oară, după `iconita_sabie.gd`, `lacat.gd`, `glifa_sah.gd` și
## bulele Lacătului, și regula e scrisă de atunci în CLAUDE.md: un semn care nu
## e literă sau cifră ori se probează cu `has_char()` în toate trei fonturile,
## ori se desenează. Verificarea Tavernei strângea caracterele din NODURILE
## MESELOR, iar ăsta era al Tavernei — de-aia a trecut nevăzut.
##
## Inelul a plecat odată cu litera. Pe un buton care se vede o singură dată și
## nu se caută, conturul cerea mai multă atenție decât fapta lui.

## Cât de departe de margine încep liniile, ca fracțiune din latura butonului.
const MARGINE := 0.3
const GROSIME := 2.0

const CULOARE := Color(0.72, 0.64, 0.52)
const CULOARE_APRINSA := Color(0.97, 0.93, 0.85)

var _aprins := false


func _ready() -> void:
	# Fără stiluri: butonul e doar o suprafață care primește clicuri.
	for stare in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		add_theme_stylebox_override(stare, StyleBoxEmpty.new())
	mouse_entered.connect(_aprinde.bind(true))
	mouse_exited.connect(_aprinde.bind(false))
	focus_entered.connect(_aprinde.bind(true))
	focus_exited.connect(_aprinde.bind(false))


func _aprinde(da: bool) -> void:
	_aprins = da
	queue_redraw()


func _draw() -> void:
	var latura := minf(size.x, size.y)
	var m := latura * MARGINE
	var col := CULOARE_APRINSA if _aprins else CULOARE
	# `true` la final = linii netezite: la 2 px o diagonală crenelată se vede.
	draw_line(Vector2(m, m), Vector2(size.x - m, size.y - m), col, GROSIME, true)
	draw_line(Vector2(size.x - m, m), Vector2(m, size.y - m), col, GROSIME, true)

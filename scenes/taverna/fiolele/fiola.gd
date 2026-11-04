extends Control
## O FIOLĂ DE STICLĂ, desenată — piesa de pe masa Fiolelor.
##
## Nu știe nimic despre joc: primește culorile straturilor (de jos în sus) și
## dacă e ridicată, și le desenează. Regula turnării, numărătoarea, alegerea —
## toate sunt ale mesei (`fiolele.gd`). Aceeași despărțire ca între
## `PlansaSpatiala` și disciplina care o folosește.
##
## DESENATĂ, NU IMAGINE ȘI NU FONT. Regula din CLAUDE.md („un semn de care
## depinde ecranul se DESENEAZĂ"): o fiolă nu e o literă, deci n-are ce căuta
## într-un font, iar o imagine ar fi cerut câte una pe fiecare umplere. Cu
## `_draw()`, straturile sunt dreptunghiuri, iar sticla e un chenar rotunjit.
##
## FĂRĂ SEMNE PE STRATURI, dinadins (vezi antetul mesei): deosebirea o duce
## numai culoarea. Două straturi la fel, unul peste altul, se lipesc fără nicio
## linie între ele — și asta e informație, nu o scăpare: un strat de trei
## galbene se toarnă ÎNTREG, deci trebuie să se vadă ca un singur lucru.

## Cât de sus stă fiola când e ALEASĂ. Locul e rezervat și când nu e, altfel
## rândul de fiole și-ar fi schimbat înălțimea la fiecare clic.
const RIDICARE := 14.0
## Gâtul: aerul de deasupra ultimului strat, ca o fiolă plină să arate tot a
## fiolă, nu a coloană de culori.
const GAT := 16.0
## Cât coboară sticla sub ultimul strat — fundul rotunjit.
const FUND := 7.0
## Cât de groși sunt pereții, pe dinăuntru: lichidul nu atinge chenarul.
const PERETE := 5.0
const RAZA_FUND := 18
const GROSIME_STICLA := 2

const CULOARE_STICLA := Color(1, 1, 1, 0.05)
const CULOARE_CHENAR := Color(0.58, 0.5, 0.4)
## Chenarul fiolei alese: același crem ca cifrele date din Sudoku. Nu verde și
## nu chihlimbar — alegerea nu e un verdict și nici o avertizare.
const CULOARE_CHENAR_ALEASA := Color(0.98, 0.95, 0.88)

## Culorile straturilor, de jos în sus.
var culori: Array[Color] = []
var capacitate := 4
var latime := 52.0
var inaltime_strat := 44.0
var ridicata := false


## Pune o umplere nouă și se redesenează.
func aseaza(culori_noi: Array[Color], ridicata_acum: bool) -> void:
	culori = culori_noi
	ridicata = ridicata_acum
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(latime, RIDICARE + GAT + capacitate * inaltime_strat + FUND)


func _draw() -> void:
	var x0 := (size.x - latime) / 2.0
	var sus := 0.0 if ridicata else RIDICARE
	var corp := Rect2(x0, sus, latime, GAT + capacitate * inaltime_strat + FUND)
	var fund_lichid := sus + GAT + capacitate * inaltime_strat

	# Întâi sticla goală, apoi lichidul, apoi chenarul peste: așa chenarul nu
	# e acoperit de culoarea stratului de jos.
	_stil(CULOARE_STICLA, Color(0, 0, 0, 0), 0).draw(get_canvas_item(), corp)

	var interior := latime - 2 * PERETE
	for i in culori.size():
		var y := fund_lichid - (i + 1) * inaltime_strat
		if i == 0:
			# Stratul de jos coboară în fundul rotunjit și se rotunjește cu el.
			var raza := RAZA_FUND - int(PERETE)
			var jos := Rect2(x0 + PERETE, y, interior, inaltime_strat + FUND - PERETE + 2)
			var stil := _stil(culori[i], Color(0, 0, 0, 0), 0)
			stil.corner_radius_bottom_left = raza
			stil.corner_radius_bottom_right = raza
			stil.corner_radius_top_left = 0
			stil.corner_radius_top_right = 0
			stil.draw(get_canvas_item(), jos)
		else:
			# Un pixel în plus în jos, ca două straturi lipite să nu lase între
			# ele o linie de fond la rotunjirea coordonatelor.
			draw_rect(Rect2(x0 + PERETE, y, interior, inaltime_strat + 1), culori[i])

	# Luciul sticlei: o dungă subțire pe stânga, peste lichid.
	draw_rect(Rect2(x0 + PERETE + 3, sus + GAT, 3, capacitate * inaltime_strat - 6),
		Color(1, 1, 1, 0.14))

	var chenar := CULOARE_CHENAR_ALEASA if ridicata else CULOARE_CHENAR
	_stil(Color(0, 0, 0, 0), chenar, GROSIME_STICLA).draw(get_canvas_item(), corp)
	# Buza fiolei: o linie puțin mai lată decât gura.
	draw_rect(Rect2(x0 - 3, sus, latime + 6, 3), chenar)


func _stil(fond: Color, chenar: Color, grosime: int) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = fond
	stil.border_color = chenar
	stil.set_border_width_all(grosime)
	stil.corner_radius_top_left = 3
	stil.corner_radius_top_right = 3
	stil.corner_radius_bottom_left = RAZA_FUND
	stil.corner_radius_bottom_right = RAZA_FUND
	stil.anti_aliasing = true
	return stil

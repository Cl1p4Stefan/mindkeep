extends Control
## O FIOLĂ DE STICLĂ, desenată — piesa de pe masa Fiolelor.
##
## Nu știe nimic despre joc: primește culorile straturilor (de jos în sus) și
## dacă e ridicată, și le desenează. Regula turnării, numărătoarea, alegerea —
## toate sunt ale mesei (`fiolele.gd`). Aceeași despărțire ca între
## `PlansaSpatiala` și disciplina care o folosește. Chiar și turnarea animată e
## a mesei: fiola doar se lasă înclinată și mutată, și desenează ce i se spune.
##
## DESENATĂ, NU IMAGINE ȘI NU FONT. Regula din CLAUDE.md („un semn de care
## depinde ecranul se DESENEAZĂ"): o fiolă nu e o literă, deci n-are ce căuta
## într-un font, iar o imagine ar fi cerut câte una pe fiecare umplere — și
## n-ar fi putut ÎNCLINA lichidul.
##
## ─────────────────────────────────────────────────────────────
## LICHIDUL SE MĂSOARĂ ÎN ARIE, NU ÎN ÎNĂLȚIME
##
## Asta e toată „fizica" de aici, și e singurul motiv pentru care o fiolă
## înclinată arată a fiolă înclinată. Un strat nu e un dreptunghi de
## `inaltime_strat` pixeli, e o CANTITATE: o felie din aria interiorului. Când
## fiola se înclină, suprafața rămâne ORIZONTALĂ (gravitația nu se rotește cu
## sticla), iar înălțimea ei se caută prin înjumătățire: „la ce y aria de sub
## linie e exact cât lichid am?" (`_nivel`). Urmări care vin gratis:
##   - fundul rotunjit ține mai puțin, deci stratul de jos e mai înalt — ca la
##     o eprubetă adevărată;
##   - unghiul la care lichidul ajunge la buză se poate CALCULA
##     (`unghi_de_curgere`), deci o fiolă plină se înclină puțin, iar una
##     aproape goală aproape se răstoarnă;
##   - în timpul turnării un strat scade continuu, nu sare.
##
## FĂRĂ SEMNE PE STRATURI, dinadins (vezi antetul mesei): deosebirea o duce
## numai culoarea. Două straturi la fel, unul peste altul, se lipesc fără nicio
## linie între ele (`segmente_din` le contopește) — și asta e informație, nu o
## scăpare: un strat de trei galbene se toarnă ÎNTREG, deci trebuie să se vadă
## ca un singur lucru.
##
## STRATURILE ASCUNSE (treptele mesei): un strat cu `ascunse[k]` se desenează
## cu `CULOARE_ASCUNSA` și un „?" pe el, și NU se contopește cu nimic — nici cu
## un vecin ascuns, nici cu unul de aceeași culoare. Contopit, ar fi spus
## exact ce ascunde.

## Cât de sus stă fiola când e ALEASĂ. Locul e rezervat și când nu e, altfel
## rândul de fiole și-ar fi schimbat înălțimea la fiecare clic.
const RIDICARE := 14.0
## Gâtul: aerul de deasupra ultimului strat, ca o fiolă plină să arate tot a
## fiolă, nu a coloană de culori.
const GAT := 16.0
## Cât coboară sticla sub ultimul strat.
const FUND := 7.0
## Cât e interiorul mai îngust decât linia sticlei: MAI PUȚIN decât jumătate
## din `GROSIME_STICLA`, deci marginea lichidului intră SUB contur. Cu 4 px
## rămânea între ele o dungă de fond, care se citea ca un gol între lichid și
## sticlă. Și nu exact jumătate: lichidul și benzile de lumină sunt poligoane
## fără netezire, iar pe curbura fundului muchia lor face scări de pixeli —
## ascunse numai dacă stau sub miezul OPAC al conturului, nu sub marginea lui
## netezită.
const PERETE := 0.5
const GROSIME_STICLA := 2.6
## Jetul, în pixeli: cât de gros iese din buză și cât de gros ajunge jos.
const LATIME_JET_SUS := 14.0
const LATIME_JET_JOS := 9.0
## Dopul: cât cade (în secunde, cu săritura cu tot), de cât de sus vine, și cât
## ține strălucirea de după el.
const DURATA_CAPAC := 0.5
const CADERE_CAPAC := 46.0
const DURATA_STRALUCIRE := 0.55
## Pluta: lemn deschis, cu o muchie mai închisă și una luminată.
const CULOARE_PLUTA := Color(0.71, 0.52, 0.32)
const CULOARE_PLUTA_UMBRA := Color(0.5, 0.34, 0.2)
const CULOARE_PLUTA_LUMINA := Color(0.86, 0.7, 0.5)
## Cât durează urcarea sau coborârea fiolei alese, în secunde.
const DURATA_RIDICARE := 0.12
## Cel mai mult cât se poate înclina o fiolă (≈ 118°): o fiolă aproape goală
## nu se întoarce cu fundul în sus, se oprește aici.
const UNGHI_MAXIM := 2.06

## Sticla: palidă și puțin rece, cum e sticla adevărată pe un fond cald.
const CULOARE_STICLA := Color(1, 1, 1, 0.05)
## OPAC, dinadins: un contur pe jumătate transparent lăsa să se vadă prin el
## scările de pixeli ale lichidului (vezi `PERETE`). Culoarea e cea pe care o
## avea conturul vechi amestecat cu fondul.
const CULOARE_CHENAR := Color(0.62, 0.66, 0.66)
## Chenarul fiolei alese: același crem ca cifrele date din Sudoku. Nu verde și
## nu chihlimbar — alegerea nu e un verdict și nici o avertizare.
const CULOARE_CHENAR_ALEASA := Color(0.98, 0.95, 0.88)
## Un strat ascuns: un cenușiu tulbure, mai închis decât orice culoare din
## paletă (toate au L ≥ 0,5), ca să nu se confunde cu una din ele.
const CULOARE_ASCUNSA := Color(0.27, 0.26, 0.29)
const MARIME_SEMN := 24

## Rotunjimea sticlei, ca benzi verticale de umbră și lumină: x e de la -1
## (peretele stâng) la 1 (cel drept), iar între capete culoarea curge liniar.
## Negru la margini (acolo privești prin mai multă sticlă), o dungă albă pe
## stânga (lumina camerei) și una slabă pe dreapta (reflexul ei).
const BENZI_LUMINA := [
	[-1.0, Color(0, 0, 0, 0.34), -0.66, Color(0, 0, 0, 0)],
	[-0.62, Color(1, 1, 1, 0), -0.5, Color(1, 1, 1, 0.3)],
	[-0.5, Color(1, 1, 1, 0.3), -0.36, Color(1, 1, 1, 0)],
	[0.2, Color(0, 0, 0, 0), 0.78, Color(0, 0, 0, 0.24)],
	[0.78, Color(0, 0, 0, 0.24), 1.0, Color(0, 0, 0, 0.42)],
	[0.56, Color(1, 1, 1, 0), 0.63, Color(1, 1, 1, 0.12)],
	[0.63, Color(1, 1, 1, 0.12), 0.7, Color(1, 1, 1, 0)],
]

## Culorile straturilor, de jos în sus — ce e LOGIC în fiolă. Le citește și
## verificarea.
var culori: Array[Color] = []
## Care straturi sunt ascunse, de jos în sus. Gol = niciunul.
var ascunse: Array[bool] = []
var capacitate := 4
var latime := 52.0
var inaltime_strat := 44.0
var ridicata := false

## Ce se DESENEAZĂ: perechi `[culoare, cantitate]`, de jos în sus, cu straturile
## la fel contopite. De obicei e chiar `culori`, strânse; în timpul unei
## turnări îl scrie masa, cu cantități care nu sunt întregi.
var segmente: Array = []
## Cât timp e `true`, `aseaza` nu mai atinge `segmente`: masa animă turnarea și
## ea hotărăște cât lichid e în fiecare clipă.
var animata := false
## Înclinarea, în radiani, în jurul gurii fiolei. Pozitivă = gura spre dreapta.
var unghi := 0.0
## Cât s-a mutat fiola de la locul ei, în pixeli.
var deplasare := Vector2.ZERO
## Jetul care iese din gură: `{de_la, pana_la, culoare}` în coordonatele
## fiolei, sau gol.
var jet := {}
## Cât de agitat e lichidul (0..1): bule care urcă, cât timp curge ceva în el.
var agitatie := 0.0
## Unde e fiola între jos (0) și ridicată (1). Urcă singură spre `ridicata`.
var inaltare := 0.0
## Are dop: fiola e plină cu o singură culoare. O spune masa, nu fiola — fiola
## nu știe nici ce e „plin", nici ce e „gata".
var inchisa := false
## Unde e dopul în căderea lui: 0 = sus, nevăzut; 1 = pus pe gură.
var capac := 0.0
## Strălucirea de după dop, de la 1 la 0.
var stralucire := 0.0
var _anim_capac: Tween = null

# Forma, în coordonatele TUBULUI: originea e mijlocul gurii, y coboară de-a
# lungul fiolei. Se refac doar când se schimbă dimensiunile.
var _interior := PackedVector2Array()
var _exterior := PackedVector2Array()
var _benzi: Array = []
## Aria unui strat întreg, în pixeli pătrați.
var _unitate := 1.0
var _forma_pentru := Vector3.ZERO


## Pune o umplere nouă și se redesenează.
func aseaza(culori_noi: Array[Color], ridicata_acum: bool,
		ascunse_noi: Array[bool] = []) -> void:
	culori = culori_noi
	ascunse = ascunse_noi
	ridicata = ridicata_acum
	if not animata:
		segmente = segmente_din(culori, ascunse)
	# O fiolă care încă n-a ajuns pe ecran nu urcă: se naște direct sus (ca în
	# exemplul din reguli), altfel panoul s-ar fi deschis cu o mișcare.
	if not is_inside_tree():
		inaltare = 1.0 if ridicata else 0.0
	set_process(true)
	queue_redraw()


## Pune sau scoate dopul. Cu `animat`, dopul CADE (cu o săritură, ca o plută
## adevărată) și fiola strălucește o clipă — semnul că fiola asta e gata. Fără,
## apare sau dispare pe loc: „Înapoi" și „Reia" nu sunt momente de sărbătorit.
## Întoarce `true` dacă a pornit o cădere, ca masa să știe când să dea sunetul.
func seteaza_capac(da: bool, animat: bool) -> bool:
	if da == inchisa:
		return false
	inchisa = da
	if _anim_capac != null:
		_anim_capac.kill()
		_anim_capac = null
	stralucire = 0.0
	capac = 1.0 if da else 0.0
	queue_redraw()
	if not da or not animat or not is_inside_tree():
		return false
	capac = 0.0
	_anim_capac = create_tween()
	_anim_capac.tween_method(_pune_capacul, 0.0, 1.0, DURATA_CAPAC) 		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_anim_capac.parallel().tween_method(_straluceste, 1.0, 0.0, DURATA_STRALUCIRE) 		.set_delay(DURATA_CAPAC * 0.45)
	return true


func _pune_capacul(t: float) -> void:
	capac = t
	queue_redraw()


func _straluceste(t: float) -> void:
	stralucire = t
	queue_redraw()


## Culorile, strânse în straturi: trei galbene la rând sunt UN segment de 3.
## Un strat ascuns e un segment al lui, `[CULOARE_ASCUNSA, 1, true]`.
static func segmente_din(lista: Array, ascunse_lista: Array = []) -> Array:
	var rez: Array = []
	for k in lista.size():
		if k < ascunse_lista.size() and ascunse_lista[k]:
			rez.append([CULOARE_ASCUNSA, 1.0, true])
			continue
		var c: Color = lista[k]
		if not rez.is_empty() and not _e_ascuns(rez[-1]) 				and (rez[-1][0] as Color).is_equal_approx(c):
			rez[-1][1] = float(rez[-1][1]) + 1.0
		else:
			rez.append([c, 1.0])
	return rez


static func _e_ascuns(segment: Array) -> bool:
	return segment.size() > 2 and bool(segment[2])


func _process(delta: float) -> void:
	var tinta := 1.0 if ridicata else 0.0
	if is_equal_approx(inaltare, tinta):
		inaltare = tinta
		set_process(false)
		return
	inaltare = move_toward(inaltare, tinta, delta / DURATA_RIDICARE)
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return Vector2(latime, RIDICARE + _inaltime_corp())


func _inaltime_corp() -> float:
	return GAT + capacitate * inaltime_strat + FUND


# ─────────────────────────────────────────────────────────────
# CE ÎNTREABĂ MASA
# ─────────────────────────────────────────────────────────────

## Unde stă gura fiolei NEÎNCLINATE, în coordonatele ei.
func ancora_baza() -> Vector2:
	return Vector2(size.x / 2.0, RIDICARE * (1.0 - _neted(inaltare)))


## Mijlocul gurii, în coordonatele fiolei, cu tot cu înclinare și mutare.
func gura() -> Vector2:
	return ancora_baza() + deplasare


## Colțul buzei pe partea `s` (+1 dreapta, -1 stânga), în coordonatele tubului.
func buza(s: float) -> Vector2:
	return Vector2(s * latime / 2.0, 0.0)


## Un punct din tub, adus pe ecran (în coordonatele fiolei).
func pe_ecran(p_tub: Vector2) -> Vector2:
	return gura() + p_tub.rotated(unghi)


## Unde e suprafața lichidului, pe verticală, în coordonatele fiolei.
func suprafata_y() -> float:
	_pregateste()
	var interior := _interior_pe_ecran()
	return _nivel(interior, _volum_total() * _unitate)


## Cât trebuie înclinată fiola spre partea `s` ca un lichid de `volum` straturi
## să ajungă exact la buză. Înjumătățire pe unghi, iar la fiecare pas o
## înjumătățire pe nivel — „suprafața e deasupra buzei?" crește cu unghiul.
func unghi_de_curgere(volum: float, s: float) -> float:
	_pregateste()
	if volum <= 0.001:
		return UNGHI_MAXIM * s
	var jos := 0.0
	var sus := UNGHI_MAXIM
	for pas in 14:
		var a := (jos + sus) / 2.0 * s
		var rotit := PackedVector2Array()
		for p in _interior:
			rotit.append(p.rotated(a))
		var y := _nivel(rotit, volum * _unitate)
		if y <= Vector2(s * (latime / 2.0 - PERETE), 0.0).rotated(a).y:
			sus = (jos + sus) / 2.0
		else:
			jos = (jos + sus) / 2.0
	return sus * s


# ─────────────────────────────────────────────────────────────
# FORMA
# ─────────────────────────────────────────────────────────────

## O eprubetă: pereți drepți și un fund de semicerc, interiorul cu `PERETE`
## mai îngust decât sticla.
func _pregateste() -> void:
	var cheie := Vector3(latime, inaltime_strat, capacitate)
	if cheie == _forma_pentru:
		return
	_forma_pentru = cheie
	var a := latime / 2.0
	var b := a - PERETE
	var centru := _inaltime_corp() - a
	_interior = _contur(b, centru)
	_exterior = _contur(a, centru)

	# Unitatea: aria de sub gât, împărțită la câte straturi încap. O fiolă
	# plină are deci suprafața exact la `GAT`, ca înainte.
	_unitate = _arie_sub(_interior, GAT) / float(capacitate)

	# Benzile de lumină: interiorul tăiat în fâșii verticale, cu culoarea pe
	# fiecare vârf după x. Pe un poligon convex, o culoare liniară în x se
	# interpolează EXACT între vârfuri, deci dunga nu se strâmbă pe fund.
	_benzi.clear()
	for banda in BENZI_LUMINA:
		var x1: float = banda[0] * b
		var x2: float = banda[2] * b
		var taietura := PackedVector2Array([Vector2(x1, -1), Vector2(x2, -1),
			Vector2(x2, centru + b + 1), Vector2(x1, centru + b + 1)])
		for bucata in Geometry2D.intersect_polygons(_interior, taietura):
			var vf: PackedVector2Array = bucata
			var cul := PackedColorArray()
			for p in vf:
				var t := clampf((p.x - x1) / maxf(x2 - x1, 0.001), 0.0, 1.0)
				cul.append((banda[1] as Color).lerp(banda[3], t))
			_benzi.append([vf, cul])


## Conturul unui U: în jos pe stânga, semicercul, în sus pe dreapta. Același
## șir e poligonul interiorului (se închide singur, pe la gură) și linia
## sticlei (desenată deschisă, fiindcă gura e deschisă).
func _contur(raza: float, centru: float) -> PackedVector2Array:
	var p := PackedVector2Array()
	p.append(Vector2(-raza, 0))
	var pasi := 18
	for i in pasi + 1:
		var t := PI - PI * float(i) / float(pasi)
		p.append(Vector2(raza * cos(t), centru + raza * sin(t)))
	p.append(Vector2(raza, 0))
	return p


func _interior_pe_ecran() -> PackedVector2Array:
	var g := gura()
	var rez := PackedVector2Array()
	for p in _interior:
		rez.append(g + p.rotated(unghi))
	return rez


func _volum_total() -> float:
	var v := 0.0
	for s in segmente:
		v += float(s[1])
	return v


static func _arie(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in p.size():
		var j := (i + 1) % p.size()
		s += p[i].x * p[j].y - p[j].x * p[i].y
	return absf(s) * 0.5


## Partea poligonului de SUB linia orizontală `y` (y crește în jos).
static func _sub_linie(poligon: PackedVector2Array, y: float) -> Array:
	var r := Rect2(poligon[0], Vector2.ZERO)
	for p in poligon:
		r = r.expand(p)
	var jos := r.end.y + 4.0
	var semiplan := PackedVector2Array([Vector2(r.position.x - 4, y),
		Vector2(r.end.x + 4, y), Vector2(r.end.x + 4, jos), Vector2(r.position.x - 4, jos)])
	if y >= jos:
		return []
	return Geometry2D.intersect_polygons(poligon, semiplan)


static func _arie_sub(poligon: PackedVector2Array, y: float) -> float:
	var s := 0.0
	for bucata in _sub_linie(poligon, y):
		s += _arie(bucata)
	return s


## La ce înălțime are poligonul exact `arie` pixeli pătrați sub linie.
static func _nivel(poligon: PackedVector2Array, arie: float) -> float:
	var sus := INF
	var jos := -INF
	for p in poligon:
		sus = minf(sus, p.y)
		jos = maxf(jos, p.y)
	if arie <= 0.0:
		return jos
	for pas in 20:
		var mijloc := (sus + jos) / 2.0
		if _arie_sub(poligon, mijloc) > arie:
			sus = mijloc
		else:
			jos = mijloc
	return (sus + jos) / 2.0


static func _neted(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)


# ─────────────────────────────────────────────────────────────
# DESENUL
#
# În ordinea în care se suprapun în realitate: umbra pe masă, spatele
# sticlei, lichidul, bulele, rotunjimea sticlei peste tot, conturul și buza,
# iar la urmă jetul, care e ÎN FAȚA fiolei în care cade.
# ─────────────────────────────────────────────────────────────

func _draw() -> void:
	_pregateste()
	var g := gura()
	var aleasa := ridicata and inaltare > 0.01
	var chenar := CULOARE_CHENAR.lerp(CULOARE_CHENAR_ALEASA, _neted(inaltare)) \
		if ridicata else CULOARE_CHENAR

	_deseneaza_umbra()

	var interior := _interior_pe_ecran()
	draw_colored_polygon(interior, CULOARE_STICLA)
	_deseneaza_lichid(interior)
	_deseneaza_bulele(interior)

	draw_set_transform(g, unghi, Vector2.ONE)
	if aleasa:
		# Un halou cald în jurul fiolei alese, sub contur.
		draw_polyline(_exterior, Color(CULOARE_CHENAR_ALEASA, 0.16 * inaltare), 7.0, true)
	for banda in _benzi:
		draw_polygon(banda[0], banda[1])
	if stralucire > 0.0:
		# Fiola gata se luminează o clipă pe dinăuntru, sub contur.
		draw_colored_polygon(_interior, Color(1, 1, 1, 0.16 * stralucire))
	if inchisa:
		_deseneaza_dopul()
	draw_polyline(_exterior, chenar, GROSIME_STICLA, true)
	var a := latime / 2.0
	# Buza: un inel puțin mai lat decât gura, cu lumina pe muchia de sus.
	draw_line(Vector2(-a - 2.5, 1.5), Vector2(a + 2.5, 1.5), chenar, 3.5, true)
	draw_line(Vector2(-a - 1.5, 0.2), Vector2(a * 0.2, 0.2), Color(1, 1, 1, 0.35), 1.0, true)
	if stralucire > 0.0:
		_deseneaza_stralucirea()
	draw_set_transform_matrix(Transform2D.IDENTITY)

	_deseneaza_jetul()


## Dopul de plută, în coordonatele TUBULUI (se înclină odată cu fiola, dacă
## ar fi înclinată). Două bucăți: cea care intră în gât, îngustă cât gura, și
## gulerul de deasupra, mai lat decât buza. Partea din gât e desenată ÎNAINTEA
## buzei, ca sticla să rămână în fața ei.
func _deseneaza_dopul() -> void:
	var a := latime / 2.0
	var b := a - PERETE
	var sus := -(1.0 - capac) * CADERE_CAPAC
	var opac := clampf(capac * 3.0, 0.0, 1.0)
	var gat := Rect2(-b + 1.0, sus - 1.0, 2.0 * b - 2.0, 10.0)
	draw_rect(gat, Color(CULOARE_PLUTA_UMBRA, opac))
	draw_rect(gat.grow_side(SIDE_LEFT, -2.0).grow_side(SIDE_RIGHT, -2.0)
		.grow_side(SIDE_BOTTOM, -3.0), Color(CULOARE_PLUTA, opac))
	var guler := _stil_dop(Color(CULOARE_PLUTA, opac), Color(CULOARE_PLUTA_UMBRA, opac))
	guler.draw(get_canvas_item(), Rect2(-a - 3.0, sus - 10.0, 2.0 * a + 6.0, 9.0))
	# Lumina pe muchia de sus și câțiva pori de plută.
	draw_line(Vector2(-a, sus - 9.0), Vector2(a * 0.4, sus - 9.0),
		Color(CULOARE_PLUTA_LUMINA, opac), 1.2, true)
	for i in 5:
		var x := -a + 6.0 + i * (2.0 * a - 10.0) / 4.0 + sin(i * 2.7) * 2.0
		draw_circle(Vector2(x, sus - 5.5 + sin(i * 1.9) * 1.5), 0.9,
			Color(CULOARE_PLUTA_UMBRA, opac * 0.8), true, -1.0, true)


func _stil_dop(fond: Color, chenar: Color) -> StyleBoxFlat:
	var stil := StyleBoxFlat.new()
	stil.bg_color = fond
	stil.border_color = chenar
	stil.set_border_width_all(1)
	stil.set_corner_radius_all(3)
	stil.anti_aliasing = true
	return stil


## După dop: un halou pe sticlă și un inel care se lărgește din gură.
func _deseneaza_stralucirea() -> void:
	var a := latime / 2.0
	var crem := CULOARE_CHENAR_ALEASA
	draw_polyline(_exterior, Color(crem, 0.35 * stralucire), 7.0, true)
	var raza := a * (1.1 + (1.0 - stralucire) * 0.9)
	draw_set_transform(gura() + Vector2(0, -5.0).rotated(unghi), unghi, Vector2(1.0, 0.4))
	draw_arc(Vector2.ZERO, raza, 0.0, TAU, 32, Color(crem, 0.6 * stralucire), 2.0, true)
	draw_set_transform(gura(), unghi, Vector2.ONE)
	# Trei scântei în jurul dopului, care se strâng odată cu strălucirea.
	for i in 3:
		var p := Vector2((i - 1) * a * 0.95, -16.0 + absf(i - 1) * 6.0 - (1.0 - stralucire) * 6.0)
		var l := 4.0 * stralucire
		draw_line(p - Vector2(l, 0), p + Vector2(l, 0), Color(crem, stralucire), 1.2, true)
		draw_line(p - Vector2(0, l), p + Vector2(0, l), Color(crem, stralucire), 1.2, true)


## O umbră moale pe masă, sub fund. Se strânge când fiola urcă și dispare cât
## timp e dusă să toarne.
func _deseneaza_umbra() -> void:
	var a := latime / 2.0
	var tarie := 0.3 * (1.0 - 0.4 * _neted(inaltare)) \
		* clampf(1.0 - deplasare.length() / 60.0, 0.0, 1.0)
	if tarie <= 0.01:
		return
	var centru := Vector2(gura().x, RIDICARE + _inaltime_corp() + 3.0)
	draw_set_transform(centru, 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, a * 1.2, Color(0, 0, 0, tarie * 0.45), true, -1.0, true)
	draw_circle(Vector2.ZERO, a * 0.85, Color(0, 0, 0, tarie * 0.6), true, -1.0, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)


## Straturile, de SUS în jos: fiecare acoperă tot ce e sub suprafața lui, iar
## următorul, mai jos, se pune peste. Așa nu rămâne nicio linie de fond între
## două straturi la rotunjirea coordonatelor.
func _deseneaza_lichid(interior: PackedVector2Array) -> void:
	var cumul := 0.0
	var suprafete: Array[float] = []
	for s in segmente:
		cumul += float(s[1])
		suprafete.append(_nivel(interior, cumul * _unitate))
	if cumul <= 0.001:
		return
	for k in range(segmente.size() - 1, -1, -1):
		if float(segmente[k][1]) <= 0.001:
			continue
		var culoare: Color = segmente[k][0]
		for bucata in _sub_linie(interior, suprafete[k]):
			draw_colored_polygon(bucata, culoare)
		# O umbră subțire sub fiecare graniță dintre două culori: lichidele nu
		# se amestecă, dar lumina se frânge altfel la trecere.
		if k > 0:
			_banda(interior, suprafete[k - 1], 2.0, Color(0, 0, 0, 0.12))

	# Semnul de întrebare pe fiecare strat ascuns, drept, în mijlocul feliei
	# lui (suprafața e orizontală oricât s-ar înclina fiola, deci și semnul).
	for k in segmente.size():
		if not _e_ascuns(segmente[k]) or float(segmente[k][1]) <= 0.001:
			continue
		var jos_felie: float = suprafete[k - 1] if k > 0 else _nivel(interior, 0.0)
		_deseneaza_semnul(interior, suprafete[k], jos_felie)

	# Suprafața de sus: un menisc mai deschis, cu o linie de lumină pe ea.
	var sus := suprafete[-1]
	var culoare_sus: Color = segmente[-1][0]
	_banda(interior, sus, 3.0, culoare_sus.lightened(0.28))
	_banda(interior, sus, 1.0, Color(culoare_sus.lightened(0.6), 0.85))


## Un „?" în mijlocul feliei dintre `sus` și `jos`. E o literă a fontului, nu
## un desen: semnul există în toate trei fonturile jocului, iar regulile mesei îl
## scriu ca text, deci `verifica_taverna` îl bate odată cu caracterele mesei.
func _deseneaza_semnul(interior: PackedVector2Array, sus: float, jos: float) -> void:
	var felie := PackedVector2Array([Vector2(-1e4, sus), Vector2(1e4, sus),
		Vector2(1e4, jos), Vector2(-1e4, jos)])
	var bucati := Geometry2D.intersect_polygons(interior, felie)
	if bucati.is_empty():
		return
	var r := Rect2((bucati[0] as PackedVector2Array)[0], Vector2.ZERO)
	for bucata in bucati:
		for p in bucata:
			r = r.expand(p)
	var font := get_theme_default_font()
	var marime := mini(MARIME_SEMN, int(r.size.y * 0.8))
	if font == null or marime < 8:
		return
	var lat := font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, marime).x
	var linie := r.get_center().y + (font.get_ascent(marime) - font.get_descent(marime)) / 2.0
	draw_string(font, Vector2(r.get_center().x - lat / 2.0, linie), "?",
		HORIZONTAL_ALIGNMENT_LEFT, -1, marime, Color(CULOARE_CHENAR_ALEASA, 0.85))


## O fâșie orizontală de `grosime` pixeli sub linia `y`, tăiată la interior.
func _banda(interior: PackedVector2Array, y: float, grosime: float, culoare: Color) -> void:
	var taietura := PackedVector2Array([Vector2(-1e4, y), Vector2(1e4, y),
		Vector2(1e4, y + grosime), Vector2(-1e4, y + grosime)])
	for felie in Geometry2D.intersect_polygons(interior, taietura):
		draw_colored_polygon(felie, culoare)


## Bulele care urcă în fiola în care se toarnă. Poziții fixe pe index, mișcate
## de ceas: nu e nimic de ținut minte, deci nici `RandomNumberGenerator`.
func _deseneaza_bulele(interior: PackedVector2Array) -> void:
	if agitatie <= 0.01 or segmente.is_empty():
		return
	var sus := _nivel(interior, _volum_total() * _unitate)
	var jos := 0.0
	for p in interior:
		jos = maxf(jos, p.y)
	var adancime := minf(jos - sus - 6.0, 46.0)
	if adancime <= 4.0:
		return
	var ceas := Time.get_ticks_msec() / 1000.0
	var b := latime / 2.0 - PERETE
	for i in 7:
		var faza := fposmod(ceas * (0.9 + 0.17 * i) + i * 0.37, 1.0)
		var x := gura().x + sin(i * 2.3) * b * 0.6 + sin(ceas * 6.0 + i) * 1.5
		var y := sus + 3.0 + adancime * (1.0 - faza)
		draw_circle(Vector2(x, y), 1.2 + (i % 3) * 0.6,
			Color(1, 1, 1, 0.45 * agitatie * (1.0 - faza * 0.6)), true, -1.0, true)


## Jetul: iese din buză puțin în afară, apoi cade drept. Mai lat sus, unde
## lichidul încă e adunat, și cu o dungă de lumină pe el.
func _deseneaza_jetul() -> void:
	if jet.is_empty():
		return
	var de_la: Vector2 = jet["de_la"]
	var pana_la: float = jet["pana_la"]
	var culoare: Color = jet["culoare"]
	var s: float = jet.get("s", 1.0)
	if pana_la <= de_la.y + 1.0:
		return
	var ceas := Time.get_ticks_msec() / 1000.0
	var cadere := de_la.x + s * 3.0
	# Mijlocul jetului și lățimea lui, pe puncte. Lichidul iese pe toată
	# lățimea buzei, deci sus jetul e GROS și stă în afara ei (marginea dinăuntru
	# lipită de buză); pe măsură ce cade se subțiază și se strânge spre axă.
	var puncte := PackedVector2Array()
	var latimi := PackedFloat32Array()
	var lungime := pana_la - de_la.y
	var y := de_la.y
	while true:
		# Pe toată lungimea, dar abia spre capăt: jumătatea de sus rămâne groasă.
		var t := clampf((y - de_la.y) / maxf(lungime, 1.0), 0.0, 1.0)
		var lat := lerpf(LATIME_JET_SUS, LATIME_JET_JOS, t * t)
		var x := lerpf(de_la.x + s * LATIME_JET_SUS / 2.0, cadere, _neted(t))
		puncte.append(Vector2(x + sin(y * 0.15 - ceas * 18.0) * 0.6 * t, y))
		latimi.append(lat + sin(y * 0.3 - ceas * 22.0) * 0.5 * t)
		if y >= pana_la:
			break
		y = minf(y + 4.0, pana_la)
	# O fâșie: marginea stângă de sus în jos, apoi cea dreaptă de jos în sus.
	var fasie := PackedVector2Array()
	for i in puncte.size():
		fasie.append(puncte[i] - Vector2(latimi[i] / 2.0, 0))
	for i in range(puncte.size() - 1, -1, -1):
		fasie.append(puncte[i] + Vector2(latimi[i] / 2.0, 0))
	if puncte.size() >= 2:
		draw_colored_polygon(fasie, culoare)
		# Margini netede (poligonul n-are antialiasing) și o dungă de lumină
		# pe partea dinspre sursă.
		draw_polyline(fasie, culoare, 1.0, true)
		var lumina := PackedVector2Array()
		for i in puncte.size():
			lumina.append(puncte[i] - Vector2(s * latimi[i] * 0.22, 0))
		draw_polyline(lumina, Color(culoare.lightened(0.5), 0.55), 1.6, true)
	# Unde cade: un mic vârtej de spumă pe suprafață.
	draw_set_transform(Vector2(cadere, pana_la + 1.0), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 6.0 + sin(ceas * 25.0), Color(culoare.lightened(0.45), 0.7),
		true, -1.0, true)
	draw_set_transform_matrix(Transform2D.IDENTITY)

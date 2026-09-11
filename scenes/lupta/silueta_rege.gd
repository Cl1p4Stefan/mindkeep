extends Silueta
## Silueta jucătorului: REGELE. Coroană, cap, umeri, mantie.
##
## Toate numerele sunt fracțiuni din caseta de desen: 0 = stânga/sus,
## 1 = dreapta/jos. Dacă vrei coroana mai lată, schimbi două numere — nu
## recalculezi nimic, pentru că nimic nu e în pixeli.

## Albastrul de dinainte, cel al dreptunghiului placeholder.
@export var culoare := Color(0.31, 0.42, 0.58):
	set(valoare):
		culoare = valoare
		queue_redraw()


func _deseneaza_silueta() -> void:
	# Deschizătura mantiei: aceeași culoare, doar mai închisă. `darkened(0.35)`
	# înseamnă „cu 35% mai spre negru" — nu trebuie să inventăm a doua culoare,
	# deci dacă schimbi albastrul de sus, se schimbă și umbra odată cu el.
	var umbra := culoare.darkened(0.35)

	# MANTIA: gâtul sus, umerii care se lărgesc, poalele evazate până jos.
	# Opt puncte, în sens orar, pornind din umărul stâng al gâtului.
	_poligon(PackedVector2Array([
		Vector2(0.43, 0.36),   # gât, stânga
		Vector2(0.57, 0.36),   # gât, dreapta
		Vector2(0.73, 0.47),   # umărul drept
		Vector2(0.80, 0.72),   # mantia se lărgește
		Vector2(0.85, 0.97),   # poala dreaptă
		Vector2(0.15, 0.97),   # poala stângă
		Vector2(0.20, 0.72),
		Vector2(0.27, 0.47),   # umărul stâng
	]), culoare)

	# Deschizătura mantiei — o pană subțire care coboară din piept.
	# E singurul „detaliu": fără ea, mantia e o pată compactă.
	_poligon(PackedVector2Array([
		Vector2(0.500, 0.44),
		Vector2(0.545, 0.97),
		Vector2(0.455, 0.97),
	]), umbra)

	# CAPUL
	_cerc(Vector2(0.50, 0.29), 0.078, culoare)

	# COROANA: un poligon în zigzag — trei vârfuri și două scobituri —
	# așezat pe o bandă. Vârfurile sunt punctele cu y mic (mai sus).
	# Banda coboară până la 0.245, sub creștetul capului (0.212), ca să se
	# SUPRAPUNĂ peste el: altfel coroana pare că plutește deasupra regelui.
	_poligon(PackedVector2Array([
		Vector2(0.355, 0.245),   # colțul stânga-jos al benzii
		Vector2(0.355, 0.150),
		Vector2(0.390, 0.040),   # vârful stâng
		Vector2(0.445, 0.135),   # scobitură
		Vector2(0.500, 0.020),   # vârful din mijloc, cel mai înalt
		Vector2(0.555, 0.135),   # scobitură
		Vector2(0.610, 0.040),   # vârful drept
		Vector2(0.645, 0.150),
		Vector2(0.645, 0.245),   # colțul dreapta-jos al benzii
	]), culoare)

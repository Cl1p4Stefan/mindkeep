class_name PlansaSpatiala
extends Control
## PLANȘA: grila desenată a disciplinei Spațial. Un singur desenator pentru
## toate tipurile care au nevoie de o imagine.
##
## ─────────────────────────────────────────────────────────────
## DE CE O SINGURĂ GRILĂ, ȘI NU UN DESEN PE TIP
##
## Fiecare tip al disciplinei ar fi putut avea desenul lui: un pătrat cu un
## punct la rotații, un tabel de litere la grilă, o cruce de fețe la pliere.
## Ar fi fost trei desenatoare, cu trei feluri de a plasa textul într-o celulă
## și trei șanse ca unul să iasă strâmb — exact duplicarea împotriva căreia
## există `puzzle.gd`.
##
## Așa, toate trei sunt ACEEAȘI figură: un caroiaj din care unele celule
## există și altele nu, unele au o literă, una e însemnată cu un punct. Plierea
## nu e „altă formă", e o grilă cu găuri; rotația e o grilă cu un punct. Un tip
## nou de întrebare spațială se scrie, până la proba contrarie, cu aceeași
## grilă — iar dacă vreodată nu se poate, atunci chiar merită un desenator al
## lui.
##
## ─────────────────────────────────────────────────────────────
## CUM SE DESCRIE O PLANȘĂ
##
## Un dicționar de DATE pure, fără noduri (vezi `_plansa_pentru` din
## `puzzle.gd` pentru de ce datele și nodul sunt despărțite):
##
##   {
##     "linii": 3, "coloane": 4,
##     "celule": [ {"linie": 2, "coloana": 1, "text": "A"}, … ]
##   }
##
## O celulă are: `linie` și `coloana` (de la 1, numărate de SUS și de la
## STÂNGA — convenția e scrisă în enunțul tiparelor care întreabă coordonate),
## iar opțional `text` (litera dinăuntru), `plin` (fond aprins) și `marcat`
## (punctul).
##
## CELULELE NEDECLARATE NU SE DESENEAZĂ, și ăsta e tot trucul care face
## plierea posibilă fără cod nou: desfășurata unui cub e un dreptunghi 4×3 din
## care sunt declarate doar șase celule. Un caroiaj „plin cu goluri" ar fi cerut
## un al doilea câmp care spune care celule sunt reale; aici lista ESTE
## răspunsul la întrebarea asta.

# Latura unei celule, în pixeli. 30 nu e o alegere estetică, e o măsurătoare:
# panoul de puzzle din luptă are în jur de 400 px pe înălțime, din care antetul,
# bara de timp, enunțul și cele patru butoane iau deja ~300. O grilă 4×4 la 30
# px intră în ce rămâne; una la 38 nu intră, iar o planșă tăiată de marginea
# panoului e mai rea decât niciuna.
#
# De-aia tiparele din `spatial.gd` nu cer niciodată mai mult de 4×4: limita e
# aici, în pixeli, nu acolo, în dificultate.
const LATURA := 30.0

# Grosimea chenarului unei celule. 2 px, nu 1: la 1 px conturul se subțiază
# neuniform când fereastra e redimensionată (marginile cad între pixeli), iar o
# grilă cu laturi inegale se citește ca un desen stricat.
const GROSIME := 2.0

# Mărimea literei dintr-o celulă. Măsurată pentru o celulă de 30 px: la 20 litera
# atinge chenarul, la 14 se pierde.
const MARIME_LITERA := 17

# ── CULORILE ──────────────────────────────────────────────────
# Implicite, pentru luptă (fond închis). O temă pusă deasupra scenei le poate
# înlocui, sub tipul „Puzzle", exact ca la culorile de verdict din `puzzle.gd`:
# `plansa_contur`, `plansa_plin`, `plansa_marcaj`, `plansa_litera`.
#
# Nu se folosesc nici verdele, nici roșul: amândouă sunt culori de VERDICT în
# scena asta (`CULOARE_BUN`, `CULOARE_RAU`), iar o celulă verde într-o întrebare
# încă fără răspuns ar fi o culoare cu două înțelesuri — aceeași grijă care a
# ținut roșul departe de culorile disciplinelor.
const CULOARE_CONTUR := Color(0.62, 0.66, 0.78)
const CULOARE_PLIN := Color(0.40, 0.46, 0.62, 0.55)
const CULOARE_MARCAJ := Color(1.0, 0.87, 0.52)
const CULOARE_LITERA := Color(0.92, 0.94, 1.0)

var linii := 1
var coloane := 1
## Celulele, ca mai sus. Se scriu ÎNAINTE de `add_child`, prin `din_date()`.
var celule: Array = []


## Fabrica. Primește datele din întrebare și întoarce nodul gata măsurat.
##
## `custom_minimum_size` se pune AICI, nu în `_draw`: cutia din `puzzle.gd` e un
## `CenterContainer`, iar el așază copilul după mărimea lui minimă. Un nod care
## și-ar afla mărimea abia la desenare ar fi centrat ca un nod de mărime zero.
static func din_date(date: Dictionary) -> PlansaSpatiala:
	var plansa := PlansaSpatiala.new()
	plansa.linii = maxi(1, int(date.get("linii", 1)))
	plansa.coloane = maxi(1, int(date.get("coloane", 1)))
	plansa.celule = date.get("celule", [])
	plansa.custom_minimum_size = Vector2(
		plansa.coloane * LATURA, plansa.linii * LATURA
	)
	# Grila nu e un buton: nu prinde clickuri și nu le fură butoanelor de sub
	# ea. `IGNORE` lasă mouse-ul să treacă prin ea.
	plansa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return plansa


func _draw() -> void:
	var font := get_theme_default_font()
	var c_contur := _culoare("plansa_contur", CULOARE_CONTUR)
	var c_plin := _culoare("plansa_plin", CULOARE_PLIN)
	var c_marcaj := _culoare("plansa_marcaj", CULOARE_MARCAJ)
	var c_litera := _culoare("plansa_litera", CULOARE_LITERA)

	for celula in celule:
		var linie := int(celula.get("linie", 1))
		var coloana := int(celula.get("coloana", 1))
		var caseta := Rect2(
			Vector2((coloana - 1) * LATURA, (linie - 1) * LATURA),
			Vector2(LATURA, LATURA)
		)

		# ÎNTÂI fondul, apoi chenarul: chenarul se desenează pe DINĂUNTRUL
		# casetei, deci un fond pus peste el l-ar mânca pe jumătate.
		if bool(celula.get("plin", false)):
			draw_rect(caseta, c_plin, true)
		draw_rect(caseta, c_contur, false, GROSIME)

		# Litera, centrată pe caseta celulei. `draw_string` primește punctul de
		# BAZĂ al textului (unde stau picioarele literelor), nu colțul de sus —
		# de-aia centrarea pe verticală se face cu `ascent`, nu cu jumătate din
		# înălțimea rândului.
		var text := String(celula.get("text", ""))
		if text != "" and font != null:
			var lat := font.get_string_size(
				text, HORIZONTAL_ALIGNMENT_LEFT, -1, MARIME_LITERA
			).x
			var baza := Vector2(
				caseta.position.x + (LATURA - lat) * 0.5,
				caseta.position.y + LATURA * 0.5 + font.get_ascent(MARIME_LITERA) * 0.5
			)
			draw_string(
				font, baza, text, HORIZONTAL_ALIGNMENT_LEFT, -1,
				MARIME_LITERA, c_litera
			)

		# PUNCTUL. Un disc, nu o literă sau un „×": semnul care se ROTEȘTE n-are
		# voie să aibă el însuși o orientare, altfel întrebarea ar avea două
		# răspunsuri (unde ajunge punctul, și cum arată după ce s-a rotit).
		# Un cerc e singura formă care arată la fel din toate părțile.
		if bool(celula.get("marcat", false)):
			draw_circle(caseta.get_center(), LATURA * 0.24, c_marcaj)


## Culoarea din temă, dacă tema o dă; altfel cea implicită. Aceeași funcție ca
## `_culoare()` din `puzzle.gd`, și pe același tip („Puzzle"): planșa e o
## bucată din scena de puzzle, nu un desen de-al ei.
func _culoare(nume: String, implicita: Color) -> Color:
	if has_theme_color(nume, "Puzzle"):
		return get_theme_color(nume, "Puzzle")
	return implicita

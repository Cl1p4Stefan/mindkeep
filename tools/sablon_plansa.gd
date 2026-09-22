extends Node
## ȘABLONUL DE DESEN — fundalul, cu cutia conturată și cartea hașurată.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/sablon_plansa.tscn
##
## Scoate `docs/sablon_plansa.png`: pergamentul la mărimea ferestrei implicite,
## peste care sunt desenate exact regulile pe care le verifică
## `verifica_plansa.gd`. Îl deschizi într-un editor de imagini, pui punctele pe
## el, citești fracțiunile și le scrii în JSON.
##
## ─────────────────────────────────────────────────────────────
## DE CE O IMAGINE ȘI NU O LISTĂ DE NUMERE
##
## Numerele există deja: sunt în `ZONA_PLANSA` și în `CARTEA`. Problema e că un
## desen se face cu ochiul, iar ochiul nu poate ține minte că „0,838 pe lățime,
## dar numai sub 0,530 pe înălțime, și încă 64 de pixeli mai încolo dacă e nod”.
## Șablonul mută regula din cap pe hârtie: dacă punctul e în dreptunghiul
## albastru și nu e pe hașură, e bun.
##
## Validatorul rămâne cel care dă verdictul. Șablonul e ca să nu ajungi la el cu
## un desen greșit din capul locului.
##
## ─────────────────────────────────────────────────────────────
## CE SE VEDE PE EL
##
##   linie plină albastră   CUTIA DE DESEN: fracțiunea 0,0 e colțul ei din
##                          stânga-sus, 1,1 cel din dreapta-jos. Aici stau
##                          CENTRELE nodurilor.
##   grilă subțire          din zece în zece sutimi, ca să citești fracțiunile
##                          fără riglă
##   linie punctată         marginea hârtiei: cu jumătate de nod plus
##                          `MARGINE_PANZA` mai încolo. Un nod n-are voie
##                          acolo (n-ar încăpea simbolul), un DRUM are.
##   hașură roșie           CARTEA — nimic pe ea, nici nod, nici drum
##   hașură roșie deschisă  cartea umflată cu jumătate de nod: drumurile au
##                          voie aici, nodurile nu

const Harta := preload("res://scenes/harta/harta.gd")

const FUNDAL := "res://assets/art/campaign_map.jpg"
const IESIRE := "res://docs/sablon_plansa.png"

## Fereastra implicită a proiectului — aceeași ca în validator și în unealta de
## întins, fiindcă pe ea sunt alese toate numerele.
const ECRAN := Vector2i(1152, 648)

## Înălțimea antetului de deasupra pânzei, în scena hărții.
const INALTIME_ANTET := 84.0
const ORIGINE_PANZA := Vector2(0.0, INALTIME_ANTET)

const ALBASTRU := Color(0.10, 0.35, 0.72)
const ROSU := Color(0.68, 0.10, 0.08)


func _ready() -> void:
	# Prin `load()`, nu prin `Image.load_from_file()`: a doua citește fișierul de
	# pe disc și se plânge (pe drept) că așa ceva n-ar merge într-un build
	# exportat. Textura importată e oricum deja în proiect.
	var textura: Texture2D = load(FUNDAL)
	if textura == null:
		printerr("nu pot citi %s" % FUNDAL)
		get_tree().quit(1)
		return
	var poza := textura.get_image()
	if poza.is_compressed():
		poza.decompress()
	poza.resize(ECRAN.x, ECRAN.y, Image.INTERPOLATE_LANCZOS)
	poza.convert(Image.FORMAT_RGB8)

	var ecran := Vector2(ECRAN)
	var panza := Vector2(ecran.x, ecran.y - INALTIME_ANTET)
	var zona := Harta.zona_utila_din(Harta.ZONA_PLANSA, ecran, ORIGINE_PANZA, panza)

	# Din coordonatele PÂNZEI înapoi în cele ale ECRANULUI: șablonul e o poză a
	# ferestrei întregi, nu a dreptunghiului de sub antet.
	var cutia := Rect2(zona.position + ORIGINE_PANZA, zona.size)
	var hartia := cutia.grow_individual(
		Harta.retragere().x, Harta.retragere().y,
		Harta.retragere().x, Harta.retragere().y)
	var carte := Rect2(Harta.CARTEA.position * ecran, Harta.CARTEA.size * ecran)
	var carte_noduri := carte.grow_individual(
		Harta.retragere().x, Harta.retragere().y, 0.0, 0.0)

	# Ordinea contează: întâi cele palide, peste ele cele tari, ca o linie
	# importantă să nu fie acoperită de o hașură.
	_hasura(poza, carte_noduri, ROSU, 16, 0.40)
	_punctata(poza, carte_noduri, ROSU, 2, 8, 0.85)
	_hasura(poza, carte, ROSU, 8, 0.75)
	_contur(poza, carte, ROSU, 3, 1.0)
	_punctata(poza, hartia, ALBASTRU, 2, 10, 0.75)
	_grila(poza, cutia, ALBASTRU, 10, 0.22)
	_contur(poza, cutia, ALBASTRU, 3, 1.0)
	_repere(poza, cutia, ALBASTRU, 2)

	var eroare := poza.save_png(IESIRE)
	if eroare != OK:
		printerr("nu pot scrie %s (cod %d)" % [IESIRE, eroare])
		get_tree().quit(1)
		return

	print("Șablon scris: %s  (%d × %d px)" % [IESIRE, ECRAN.x, ECRAN.y])
	print("  cutia de desen (fracțiunile 0..1): %.0f, %.0f → %.0f, %.0f   (%.0f × %.0f px, raport %.4f)"
		% [cutia.position.x, cutia.position.y, cutia.end.x, cutia.end.y,
			cutia.size.x, cutia.size.y, cutia.size.x / cutia.size.y])
	print("  hârtia (până unde au voie DRUMURILE): %.0f, %.0f → %.0f, %.0f"
		% [hartia.position.x, hartia.position.y, hartia.end.x, hartia.end.y])
	print("  cartea: x ≥ %.0f, y ≥ %.0f   (pentru noduri: x ≥ %.0f, y ≥ %.0f)"
		% [carte.position.x, carte.position.y,
			carte_noduri.position.x, carte_noduri.position.y])
	get_tree().quit(0)


# ─────────────────────────────────────────────────────────────
# DESENAT PE O IMAGINE
#
# `Image` n-are nici linii, nici transparență la scris: `fill_rect` pune culoarea
# peste ce era, cu totul. Deci amestecul îl fac eu, pixel cu pixel — de-aia toate
# funcțiile de aici primesc o „putere” 0..1 și trec prin `_pixel`.
#
# E lent (câteva sute de mii de pixeli), dar rulează o dată la câteva luni, când
# se mai schimbă o măsurătoare pe fundal.
# ─────────────────────────────────────────────────────────────

## Un pixel amestecat peste ce era, dacă e în poză.
static func _pixel(poza: Image, x: int, y: int, culoare: Color, putere: float) -> void:
	if x < 0 or y < 0 or x >= poza.get_width() or y >= poza.get_height():
		return
	poza.set_pixel(x, y, poza.get_pixel(x, y).lerp(culoare, clampf(putere, 0.0, 1.0)))


## Un dreptunghi plin, amestecat.
static func _bara(poza: Image, r: Rect2, culoare: Color, putere: float) -> void:
	for y in range(int(floor(r.position.y)), int(ceil(r.end.y))):
		for x in range(int(floor(r.position.x)), int(ceil(r.end.x))):
			_pixel(poza, x, y, culoare, putere)


## Conturul unui dreptunghi: patru bare, desenate SPRE INTERIOR.
##
## Spre interior, nu călare pe linie, ca marginea desenată să fie chiar marginea
## permisă: dacă ai pus un punct lipit pe dinăuntru de linie, e bun.
static func _contur(
	poza: Image, r: Rect2, culoare: Color, grosime: int, putere: float
) -> void:
	var g := float(grosime)
	_bara(poza, Rect2(r.position, Vector2(r.size.x, g)), culoare, putere)
	_bara(poza, Rect2(r.position.x, r.end.y - g, r.size.x, g), culoare, putere)
	_bara(poza, Rect2(r.position.x, r.position.y, g, r.size.y), culoare, putere)
	_bara(poza, Rect2(r.end.x - g, r.position.y, g, r.size.y), culoare, putere)


## Același contur, dar întrerupt — ca să se citească „altă regulă decât linia
## plină”, fără să am nevoie de o a doua culoare.
static func _punctata(
	poza: Image, r: Rect2, culoare: Color, grosime: int, pas: int, putere: float
) -> void:
	var g := float(grosime)
	for x in range(int(r.position.x), int(r.end.x)):
		if (x / pas) % 2 == 0:
			_bara(poza, Rect2(float(x), r.position.y, 1.0, g), culoare, putere)
			_bara(poza, Rect2(float(x), r.end.y - g, 1.0, g), culoare, putere)
	for y in range(int(r.position.y), int(r.end.y)):
		if (y / pas) % 2 == 0:
			_bara(poza, Rect2(r.position.x, float(y), g, 1.0), culoare, putere)
			_bara(poza, Rect2(r.end.x - g, float(y), g, 1.0), culoare, putere)


## Grila din `impartiri` în `impartiri` părți, pe amândouă axele.
##
## Liniile de la jumătate sunt puțin mai tari: pe zece diviziuni identice
## numeri cu degetul, pe două jumătăți te uiți o dată.
static func _grila(
	poza: Image, r: Rect2, culoare: Color, impartiri: int, putere: float
) -> void:
	for i in range(1, impartiri):
		var tare := putere * (2.0 if i * 2 == impartiri else 1.0)
		var x := r.position.x + r.size.x * float(i) / float(impartiri)
		_bara(poza, Rect2(x, r.position.y, 1.0, r.size.y), culoare, tare)
		var y := r.position.y + r.size.y * float(i) / float(impartiri)
		_bara(poza, Rect2(r.position.x, y, r.size.x, 1.0), culoare, tare)


## Repere pe cele patru laturi, din zecime în zecime, scoase ÎN AFARĂ.
## În afară, ca să nu încurce desenul dinăuntru.
static func _repere(poza: Image, r: Rect2, culoare: Color, grosime: int) -> void:
	for i in range(11):
		var lung := 12.0 if i % 5 == 0 else 6.0
		var x := r.position.x + r.size.x * float(i) / 10.0
		_bara(poza, Rect2(x, r.position.y - lung, float(grosime), lung), culoare, 1.0)
		_bara(poza, Rect2(x, r.end.y, float(grosime), lung), culoare, 1.0)
		var y := r.position.y + r.size.y * float(i) / 10.0
		_bara(poza, Rect2(r.position.x - lung, y, lung, float(grosime)), culoare, 1.0)
		_bara(poza, Rect2(r.end.x, y, lung, float(grosime)), culoare, 1.0)


## Hașură la 45°, din `pas` în `pas` pixeli.
##
## Merg pe diagonale (x − y = constant) fiindcă o hașură oblică se vede ca
## „interzis” dintr-o privire, iar liniile drepte s-ar fi confundat cu grila.
static func _hasura(
	poza: Image, r: Rect2, culoare: Color, pas: int, putere: float
) -> void:
	var x0 := int(floor(r.position.x))
	var y0 := int(floor(r.position.y))
	var x1 := int(ceil(r.end.x))
	var y1 := int(ceil(r.end.y))
	for y in range(y0, y1):
		for x in range(x0, x1):
			if posmod(x - y, pas) < 2:
				_pixel(poza, x, y, culoare, putere)

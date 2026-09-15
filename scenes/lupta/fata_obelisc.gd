class_name FataObelisc
extends Control
## FAȚA unui buton de Obelisc: dreptunghiul cu colțuri rotunjite, degradeul
## vertical discret și bordura subțire în culoarea disciplinei.
##
## ─────────────────────────────────────────────────────────────
## DE CE DESENATĂ ÎN COD, ȘI NU UN `StyleBoxFlat`
##
## `StyleBoxFlat` — stilul cu care sunt făcute celelalte panouri din luptă —
## știe colțuri rotunjite, bordură și umbră, dar NU știe degradeuri: are o
## singură `bg_color`, plată. Iar un fond perfect plat e exact ce făcea
## butoanele să pară desenate cu chenarul din Paint.
##
## Alternativele încercate pe hârtie și de ce n-au trecut:
##   • un `TextureRect` cu degrade peste un `StyleBoxFlat` rotunjit — degradeul
##     ar fi ieșit dreptunghiular peste colțurile rotunde, deci ar fi trebuit
##     tăiat cu `clip_children`, care copiază ecranul într-un buffer pentru
##     fiecare buton și se ceartă cu anti-aliasing-ul 2D pornit în proiect;
##   • un shader — un al doilea limbaj, pentru un degrade.
##
## `draw_polygon()` primește o culoare PER VÂRF și le amestecă între ele. Deci
## un dreptunghi rotunjit cu vârfurile de sus deschise și cele de jos închise
## E degradeul, într-o singură desenare, cu colțurile deja rotunde.
##
## ─────────────────────────────────────────────────────────────
## CE NU FACE
##
## Nu are umbră și nu are glow. Halo-ul din spatele butonului e un `Panel`
## separat (vezi `obelisc.tscn`), fiindcă `StyleBoxFlat` chiar se pricepe la
## umbre moi — fiecare unealtă face ce știe mai bine.

## Culoarea disciplinei. Din ea ies TOATE culorile de mai jos, prin amestec cu
## fondul întunecat al arenei: un singur număr de schimbat per disciplină.
@export var culoare := Color(0.6, 0.85, 1.0):
	set(valoare):
		culoare = valoare
		queue_redraw()

## Cât de „aprins" e butonul, de la 0 (în repaus) la 1 (mouse-ul deasupra).
## Valoare ANIMATĂ din `obelisc.gd`: bordura și fondul urcă odată cu ea, deci
## trecerea la hover e o singură mișcare continuă, nu o comutare.
@export var evidentiere := 0.0:
	set(valoare):
		evidentiere = valoare
		queue_redraw()

## Butonul e ținut apăsat? Atunci degradeul se INVERSEAZĂ (închis sus, deschis
## jos). Ăsta e tot trucul „apăsării": o suprafață luminată de sus pare bombată,
## una luminată de jos pare scobită. Ochiul citește adâncimea din lumină.
@export var apasat := false:
	set(valoare):
		apasat = valoare
		queue_redraw()

## Raza colțurilor, în pixeli. 12 e raza panourilor din restul luptei
## (`StyleBoxFlat_puzzle`, `StyleBoxFlat_card`) — butoanele trebuie să pară din
## aceeași familie, nu din alt joc.
@export var raza := 12.0

## Câte segmente are fiecare colț. 6 e destul la raza 12: peste, adaugi vârfuri
## pe care nimeni nu le vede; sub, colțul începe să arate tăiat cu fața.
const SEGMENTE_COLT := 6

## Fondul întunecat al arenei (`Fundal` din `lupta.tscn`). Punctul de plecare al
## tuturor culorilor de aici: butonul e arena, colorată puțin spre disciplină.
const FOND := Color(0.105, 0.105, 0.14)

## Cât din culoarea disciplinei intră în fond. 0.10 = o nuanță, nu o vopsea:
## trebuie să simți că butonul Logicii e verzui, nu să vezi un buton verde.
const AMESTEC_FOND := 0.10
const AMESTEC_FOND_HOVER := 0.20

## Degradeul, ca abateri de la fond: sus mai deschis, jos mai închis.
## Discret cu intenție — dacă poți spune unde se termină, e prea mult.
const LUMINA_SUS := 0.10
const UMBRA_JOS := 0.35

## Transparența bordurii în repaus și la hover. Bordura e SINGURUL loc unde
## culoarea disciplinei apare pură; în rest e amestecată în fond.
const ALFA_BORDURA := 0.45
const ALFA_BORDURA_HOVER := 1.0
const GROSIME_BORDURA := 1.5


## Fondul butonului pentru o culoare de disciplină, în repaus.
##
## E `static` ca să poată fi întrebată din afară fără să existe un buton: `obelisc.gd`
## are nevoie de exact această culoare pentru găurile din piesă și din lacăt.
## Scrisă o dată, aici, lângă formula pe care o folosește și desenul — copiată
## în două fișiere, s-ar fi desincronizat la prima ajustare de nuanță, iar
## tăieturile ar fi încetat să mai pară găuri.
static func fond(culoare_disciplina: Color) -> Color:
	return FOND.lerp(culoare_disciplina, AMESTEC_FOND)


func _ready() -> void:
	# `_draw()` nu e chemată automat la redimensionare — semnalul ne anunță.
	# Aceeași legătură ca la `Silueta`, din același motiv.
	resized.connect(queue_redraw)


func _draw() -> void:
	var contur := _contur_rotunjit()

	# `lerp` pe culori = „amestecă-le". Fondul butonului e arena trasă puțin
	# spre culoarea disciplinei, cu atât mai mult cu cât e mai evidențiat.
	var baza := FOND.lerp(culoare, lerpf(AMESTEC_FOND, AMESTEC_FOND_HOVER, evidentiere))
	var sus := baza.lightened(LUMINA_SUS)
	var jos := baza.darkened(UMBRA_JOS)
	if apasat:
		# Lumina vine de jos: suprafața pare scobită. Vezi comentariul de sus.
		var temp := sus
		sus = jos
		jos = temp

	# O culoare pentru fiecare vârf, aleasă după cât de jos e el în buton.
	# Vârfurile colțurilor de sus ies aproape identice între ele, deci colțul
	# nu se rupe cromatic de latura de care aparține.
	var culori := PackedColorArray()
	for punct in contur:
		culori.append(sus.lerp(jos, punct.y / maxf(size.y, 1.0)))
	draw_polygon(contur, culori)

	# BORDURA. `draw_polyline` desenează o linie frântă prin puncte, deci ca să
	# se închidă la loc trebuie să-i dăm primul punct și la sfârșit — altfel
	# rămâne o crestătură fix în colțul din stânga-sus.
	var linie := contur.duplicate()
	linie.append(contur[0])
	var alfa := lerpf(ALFA_BORDURA, ALFA_BORDURA_HOVER, evidentiere)
	draw_polyline(linie, Color(culoare, alfa), GROSIME_BORDURA, true)


## Conturul dreptunghiului cu colțuri rotunjite, în sens orar, începând din
## colțul din stânga-sus.
##
## Fiecare colț e un sfert de cerc desenat din `SEGMENTE_COLT` bucăți: pornim
## din centrul cercului colțului și ne mișcăm pe rază, rotind unghiul cu 90°.
## Laturile drepte dintre colțuri nu au nevoie de puncte proprii — linia dintre
## ultimul punct al unui colț și primul punct al următorului E latura.
func _contur_rotunjit() -> PackedVector2Array:
	# Bordura se desenează pe linia conturului, deci jumătate din grosimea ei ar
	# cădea în afara butonului și s-ar tăia. Tragem conturul înăuntru cu exact
	# atât. (`PI` peste tot mai jos e în radiani: PI = 180°.)
	var marja := GROSIME_BORDURA * 0.5
	var r: float = minf(raza, minf(size.x, size.y) * 0.5 - marja)
	var stanga := marja
	var sus := marja
	var dreapta := size.x - marja
	var jos := size.y - marja

	# Centrele celor patru sferturi de cerc, în ordinea parcurgerii (orar),
	# și unghiul de la care pornește fiecare.
	var colturi := [
		{"centru": Vector2(stanga + r, sus + r), "start": PI},          # stânga-sus
		{"centru": Vector2(dreapta - r, sus + r), "start": PI * 1.5},   # dreapta-sus
		{"centru": Vector2(dreapta - r, jos - r), "start": 0.0},        # dreapta-jos
		{"centru": Vector2(stanga + r, jos - r), "start": PI * 0.5},    # stânga-jos
	]

	var puncte := PackedVector2Array()
	for colt: Dictionary in colturi:
		var centru: Vector2 = colt["centru"]
		var start: float = colt["start"]
		for pas in range(SEGMENTE_COLT + 1):
			var unghi: float = start + (PI * 0.5) * float(pas) / SEGMENTE_COLT
			puncte.append(centru + Vector2(cos(unghi), sin(unghi)) * r)
	return puncte

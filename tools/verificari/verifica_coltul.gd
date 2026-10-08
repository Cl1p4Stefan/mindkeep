extends Node
## VERIFICAREA COLȚULUI DE JOS-DREAPTA — nodul împins lângă Boss.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_coltul.tscn
##
## E o scenă, nu un `--script`, din același motiv ca `verifica_harta.gd`: fără
## autoload-uri, `expeditie.gd` nici nu se compilează.
##
## ─────────────────────────────────────────────────────────────
## CE MĂSOARĂ
##
## Pentru fiecare sămânță, pe planșa implicită:
##   (1) a ajuns nodul la x-ul Bossului plus `PESTE_BOSS`?
##   (2) cât aer a rămas până la cotorul cărții, pentru NOD și pentru DRUMURILE
##       care ajung în el (un drum peste carte ar fi la fel de urât);
##   (3) cea mai mică distanță până la alt nod, înainte și după;
##   (4) a ieșit ceva din pânză?
##
## ─────────────────────────────────────────────────────────────
## DE CE UN FIȘIER SEPARAT DE `verifica_harta.gd`
##
## Acela măsoară PANGLICA: încrucișări, benzi, raze de cotitură — lucruri care
## există doar pe harta generată. Ăsta măsoară o regulă care se aplică la
## AMÂNDOUĂ sursele, dar care se vede doar pe planșă (acolo e cartea, acolo e
## colțul). Două întrebări diferite, două fișiere.

const Harta := preload("res://scenes/harta/harta.gd")

## Semințele din discuție (56, 556) plus câteva luate la nimereală. Nu e un test
## statistic: pe planșă POZIȚIILE nu depind de sămânță — doar tipurile nodurilor
## depind. Lista e aici ca să se VADĂ asta: dacă vreodată o coloană din tabel
## începe să difere de la o sămânță la alta, înseamnă că altceva s-a schimbat.
const SEMINTE := [56, 556, 1, 1000, 4242, 90210, 777777]

## Planșele din `data/harti/`. A doua nu e cea jucată azi, dar e a doua FORMĂ
## pe care o are regula de digerat — iar o regulă care merge pe un singur desen
## nu e o regulă, e o potriveală.
const PLANSE := [
	"res://data/harti/harta_01.json",
	"res://data/harti/harta_02.json",
]

## Câte semințe pe harta generată. Acolo forma chiar depinde de sămânță, deci
## are rost un număr mare.
const SEMINTE_GENERATE := 300

const ECRAN := Vector2(1152.0, 648.0)

## Marginile paginii din `harta.tscn` (nodul `Panza`): stânga, sus, dreapta, jos.
const MARGINI_PAGINA := Rect2(32.0, 20.0, 32.0, 24.0)


func _ready() -> void:
	var panza := Rect2(
		MARGINI_PAGINA.position,
		ECRAN - MARGINI_PAGINA.position - MARGINI_PAGINA.size)
	# `Pergament` acoperă toată fereastra; în coordonatele pânzei, colțul lui
	# din stânga-sus e minus colțul pânzei.
	var pergament := Rect2(-panza.position, ECRAN)
	var zona := _zona_de_test(panza)

	print("")
	print("Zona utilă: %s" % zona)
	print("Pânza: %s   Pergamentul, în pânză: %s" % [panza.size, pergament])
	print("")

	var probleme: Array[String] = []
	for cale in PLANSE:
		probleme.append_array(_masoara_plansa(cale, zona, panza, pergament))
	probleme.append_array(_masoara_generata(zona, panza, pergament))

	print("")
	if probleme.is_empty():
		print("Nicio problemă.")
	else:
		print("PROBLEME:")
		for p in probleme:
			print("    " + p)
	print("")
	get_tree().quit(0 if probleme.is_empty() else 1)


## O planșă, pe toate semințele.
func _masoara_plansa(
	cale: String, zona: Rect2, panza: Rect2, pergament: Rect2
) -> Array[String]:
	print("═══ PLANȘA %s ═══" % cale.get_file())
	print("sămânță │ nod │ x vechi →  x nou │ x Boss │ țintă │ max │ oprit de")
	print("────────┼─────┼─────────────────┼────────┼───────┼─────┼─────────")

	var probleme: Array[String] = []

	for samanta in SEMINTE:
		var harta := Expeditie.genereaza_harta(samanta, cale)
		var plansa := Plansa.incarca(cale)
		var geo := Harta.geometrie_desenata(harta, plansa, zona)
		var centre: Dictionary = geo["centre"]
		var drumuri: Dictionary = geo["drumuri"]

		var x_boss := _x_bossului(harta, centre)
		var inainte := _distanta_minima(centre)
		var taieri_inainte := _numara_taieri(drumuri)

		var fisa := Harta.impinge_nodul_de_jos_dreapta(
			harta, centre, drumuri, pergament, panza.size.x)
		var id := int(fisa["id"])
		if id < 0:
			probleme.append("sămânța %d: regula n-a găsit niciun nod" % samanta)
			continue

		print("%7d │ %3d │ %6.1f → %6.1f │ %6.1f │ %5.1f │ %3.0f │ %s" % [
			samanta, id, fisa["x_vechi"], fisa["x_nou"],
			x_boss, fisa["x_tinta"], fisa["x_maxim"],
			"—" if String(fisa["oprit_de"]) == "" else fisa["oprit_de"],
		])

		var centru: Vector2 = centre[id]
		var jumate := Harta.MARIME_NOD * 0.5

		# (1) a trecut de Boss?
		if centru.x < x_boss:
			probleme.append(
				"sămânța %d: nodul %d a rămas în stânga Bossului (%.1f < %.1f)"
				% [samanta, id, centru.x, x_boss])

		# (2) aerul până la cotor, pentru nod și pentru drumuri
		var aer_nod := minf(
			Harta.x_cotorului(centru.y - jumate.y, pergament),
			Harta.x_cotorului(centru.y + jumate.y, pergament)
		) - (centru.x + jumate.x)
		if aer_nod < 0.0:
			probleme.append("sămânța %d: nodul %d intră în carte cu %.1f px"
				% [samanta, id, -aer_nod])

		var aer_drum := _aerul_drumurilor(drumuri, id, pergament)
		if aer_drum < 0.0:
			probleme.append("sămânța %d: un drum al nodului %d intră în carte"
				% [samanta, id])

		# (3) vecinii
		var dupa := _distanta_minima(centre)
		if dupa < Harta.DISTANTA_MINIMA_NODURI - 0.01:
			probleme.append(
				"sămânța %d: două noduri la %.1f px (prag %.0f)"
				% [samanta, dupa, Harta.DISTANTA_MINIMA_NODURI])

		# (4) în pânză
		var iesit := (centru.x + jumate.x) - panza.size.x
		if iesit > 0.0:
			probleme.append("sămânța %d: nodul %d iese din pânză cu %.1f px"
				% [samanta, id, iesit])

		# (5) drumurile îndoite n-au voie să taie altele
		var taieri_dupa := _numara_taieri(drumuri)
		if taieri_dupa > taieri_inainte:
			probleme.append(
				"sămânța %d: mutarea a adus %d încrucișări de drumuri"
				% [samanta, taieri_dupa - taieri_inainte])

		print("         │     │ aer până la carte: nod %.1f px, drumuri %.1f px │ vecini: %.1f → %.1f px │ încrucișări: %d → %d" % [
			aer_nod, aer_drum, inainte, dupa, taieri_inainte, taieri_dupa])

	print("")
	return probleme


## HARTA GENERATĂ, pe panglică — unde regula NU se aplică.
##
## Secțiunea asta măsoară ce-ar face dacă s-ar aplica, fiindcă „nu se aplică" e
## o decizie, iar o decizie merită cifra care a luat-o. Ce iese: nodul ar fi
## împins cu sute de pixeli și lipit de vecin la fix pragul minim — panglica își
## termină ultimul strat departe de marginea din dreapta cu intenție, iar
## excepția n-are ce căuta peste intenția aia. (Încrucișări noi nu apar, deci
## nu ăsta e motivul; motivul e că panglica are deja un răspuns.)
func _masoara_generata(
	zona: Rect2, panza: Rect2, pergament: Rect2
) -> Array[String]:
	print("═══ HARTA GENERATĂ (panglică) ═══")
	var probleme: Array[String] = []
	var mutate := 0
	var taiate := 0
	var taieri_noi := 0
	var cea_mai_mare := 0.0
	var aer_minim := INF
	var vecini_minim := INF

	for i in range(SEMINTE_GENERATE):
		var samanta := 1000 + i
		var harta := Expeditie.genereaza_harta(samanta)
		var geo := Harta.geometrie_pe_panglica(harta, zona)
		var centre: Dictionary = geo["centre"]
		var drumuri: Dictionary = geo["drumuri"]

		var taieri_inainte := _numara_taieri(drumuri)

		var fisa := Harta.impinge_nodul_de_jos_dreapta(
			harta, centre, drumuri, pergament, panza.size.x)
		var id := int(fisa["id"])
		if id < 0:
			probleme.append("sămânța %d (generată): fără nod ales" % samanta)
			continue

		var taieri_dupa := _numara_taieri(drumuri)
		if taieri_dupa > taieri_inainte:
			taiate += 1
			taieri_noi += taieri_dupa - taieri_inainte

		var mutare: float = float(fisa["x_nou"]) - float(fisa["x_vechi"])
		if mutare > 0.5:
			mutate += 1
			cea_mai_mare = maxf(cea_mai_mare, mutare)

		var centru: Vector2 = centre[id]
		var jumate := Harta.MARIME_NOD * 0.5
		var aer := minf(
			Harta.x_cotorului(centru.y - jumate.y, pergament),
			Harta.x_cotorului(centru.y + jumate.y, pergament)
		) - (centru.x + jumate.x)
		aer_minim = minf(aer_minim, aer)
		vecini_minim = minf(vecini_minim, _distanta_minima(centre))

	print("    (măsurătoare, nu verificare: pe panglică regula nu se cheamă)")
	print("    semințe: %d,  noduri care S-AR muta: %d,  cea mai mare: %.1f px"
		% [SEMINTE_GENERATE, mutate, cea_mai_mare])
	print("    hărți cu încrucișări NOI de drumuri: %d  (%d încrucișări)"
		% [taiate, taieri_noi])
	print("    cel mai mic aer până la carte: %.1f px" % aer_minim)
	print("    cea mai mică distanță între noduri: %.1f px (prag %.0f)"
		% [vecini_minim, Harta.DISTANTA_MINIMA_NODURI])
	print("")
	return probleme


## Zona utilă, pentru fereastra implicită. Aceeași copie de formulă ca în
## `verifica_harta.gd`, și din același motiv: `_zona_utila()` întreabă
## viewport-ul, care nu există în afara jocului.
func _zona_de_test(panza: Rect2) -> Rect2:
	var hartie := Rect2(
		Harta.ZONA_PERGAMENT.position * ECRAN, Harta.ZONA_PERGAMENT.size * ECRAN)
	hartie.position -= panza.position
	var zona := hartie.intersection(Rect2(Vector2.ZERO, panza.size))
	var margine := Vector2(
		Harta.MARIME_NOD.x * 0.5 + Harta.MARGINE_PANZA,
		Harta.MARIME_NOD.y * 0.5 + Harta.MARGINE_PANZA)
	return zona.grow_individual(-margine.x, -margine.y, -margine.x, -margine.y)


func _x_bossului(harta: Array, centre: Dictionary) -> float:
	for nod in harta:
		if int(nod["tip"]) == Expeditie.Nod.BOSS and centre.has(int(nod["id"])):
			return float(centre[int(nod["id"])].x)
	return 0.0


func _distanta_minima(centre: Dictionary) -> float:
	var minim := INF
	var ids := centre.keys()
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			minim = minf(minim, centre[ids[i]].distance_to(centre[ids[j]]))
	return minim


## Câte perechi de drumuri se taie, pe punctele EFECTIV desenate.
##
## Se compară numai drumuri care n-au niciun capăt comun: două drumuri care
## pleacă din același nod se ating acolo prin definiție, și aia nu e o
## încrucișare.
func _numara_taieri(drumuri: Dictionary) -> int:
	var toate := []
	for de_la in drumuri:
		for la in drumuri[de_la]:
			toate.append([int(de_la), int(la), drumuri[de_la][la]])

	var cate := 0
	for i in range(toate.size()):
		for j in range(i + 1, toate.size()):
			var a: Array = toate[i]
			var b: Array = toate[j]
			if a[0] == b[0] or a[0] == b[1] or a[1] == b[0] or a[1] == b[1]:
				continue
			if _se_taie(a[2], b[2]):
				cate += 1
	return cate


func _se_taie(d1: PackedVector2Array, d2: PackedVector2Array) -> bool:
	for i in range(1, d1.size()):
		for j in range(1, d2.size()):
			if Geometry2D.segment_intersects_segment(
					d1[i - 1], d1[i], d2[j - 1], d2[j]) != null:
				return true
	return false


## Cel mai mic aer rămas între un punct de drum al nodului și cotorul cărții.
## Negativ = un drum a intrat peste carte.
func _aerul_drumurilor(
	drumuri: Dictionary, id_nod: int, pergament: Rect2
) -> float:
	var minim := INF
	for id_brut in drumuri:
		for id_la_brut in drumuri[id_brut]:
			if int(id_brut) != id_nod and int(id_la_brut) != id_nod:
				continue
			for punct in drumuri[id_brut][id_la_brut]:
				minim = minf(
					minim, Harta.x_cotorului(punct.y, pergament) - punct.x)
	return minim

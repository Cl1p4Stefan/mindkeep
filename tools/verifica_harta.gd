extends Node
## VERIFICAREA HĂRȚII — rulează generatorul pe multe semințe și numără defecte.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verifica_harta.tscn
##
## E o SCENĂ, nu un `--script`, dintr-un motiv pe care l-am aflat pe pielea
## mea: cu `--script`, Godot nu pornește autoload-urile. `expeditie.gd` se
## referă la `Sac`, `harta.gd` la `Muzica`, iar fără ele niciunul din fișiere
## nu se compilează — testul pica înainte să apuce să măsoare ceva. O scenă
## pornește jocul normal, doar fără fereastră.
##
## De ce există: „am impresia că drumurile se încrucișează" nu e o observație pe
## care s-o poți repara. „La 300 de semințe sunt N încrucișări" este. Fișierul
## ăsta transformă o impresie într-un număr, iar numărul în ceva care poate
## ajunge la zero.
##
## NU e o copie a jocului. Cheamă exact `Expeditie.genereaza_harta()`,
## `Harta.centre_noduri()` și `Panza.punct_pe_drum()` — dacă repar jocul și uit
## testul, testul pică, fiindcă n-are logică proprie pe care s-o repar greșit.

# `Expeditie` vine de la sine: e autoload. Celelalte două se încarcă de mână,
# fiindcă sunt scripturi de scenă, nu singletoni.
const Harta := preload("res://scenes/harta/harta.gd")
const Panza := preload("res://scenes/harta/panza.gd")

const SEMINTE := 300

## Fereastra implicită a proiectului. Zona de pergament e dată în fracțiuni de
## ecran, deci am nevoie de o mărime concretă ca să obțin pixeli.
const ECRAN := Vector2(1152.0, 648.0)

## Înălțimea antetului de deasupra pânzei, în scena hărții. O aproximare bună
## e de-ajuns: numărăm încrucișări, nu pixeli.
const INALTIME_ANTET := 84.0

## Cât de des eșantionăm un drum când îl transformăm în linie frântă.
const PAS_ESANTION := 2.0

## Câte segmente intră într-o „bucată" de drum, la verificarea (d). Vezi nota
## de la `_linie_franta`.
const SEGMENTE_PE_BUCATA := 16

## Ultimul strat prins cu ordinea stricată, ca text — pentru diagnostic.
var ultim_caz_c := ""


func _ready() -> void:
	var zona := _zona_de_test()
	print("Zona utilă de test: ", zona)
	print("Semințe verificate: ", SEMINTE)
	print("")

	var a_sare_strat := 0
	var b_incrucisari_graf := 0
	var c_ordine_inversata := 0
	var d_incrucisari_desen := 0
	var harti_cu_a := 0
	var harti_cu_b := 0
	var harti_cu_c := 0
	var harti_cu_d := 0
	var primul_caz_c := ""
	var primul_caz_d := ""

	# Verificările vechi, ca să știu că reparația n-a stricat altceva.
	var noduri_min := 999
	var noduri_max := 0
	var fara_boss_la_capat := 0
	var fara_magazin := 0

	for i in range(SEMINTE):
		var samanta := 1000 + i
		var harta := Expeditie.genereaza_harta(samanta)
		var centre := Harta.centre_noduri(harta, zona)

		var na := _numara_sarituri(harta)
		var nb := _numara_incrucisari_graf(harta)
		var nc := _numara_ordine_inversata(harta, centre)
		var nd := _numara_incrucisari_desen(harta, centre)

		a_sare_strat += na
		b_incrucisari_graf += nb
		c_ordine_inversata += nc
		d_incrucisari_desen += nd
		if na > 0:
			harti_cu_a += 1
		if nb > 0:
			harti_cu_b += 1
		if nc > 0:
			harti_cu_c += 1
			if primul_caz_c == "":
				primul_caz_c = "    sămânța %d" % samanta + char(10) + ultim_caz_c
		if nd > 0:
			harti_cu_d += 1
			if primul_caz_d == "":
				primul_caz_d = _descrie_caz(samanta, harta, centre)

		noduri_min = mini(noduri_min, harta.size())
		noduri_max = maxi(noduri_max, harta.size())
		if int(harta[harta.size() - 1]["tip"]) != Expeditie.Nod.BOSS:
			fara_boss_la_capat += 1
		if not _are_magazin(harta):
			fara_magazin += 1

	print("(a) muchii care sar peste un strat : %d  (pe %d hărți din %d)"
		% [a_sare_strat, harti_cu_a, SEMINTE])
	print("(b) încrucișări în GRAF            : %d  (pe %d hărți din %d)"
		% [b_incrucisari_graf, harti_cu_b, SEMINTE])
	print("(c) straturi cu ordinea inversată  : %d  (pe %d hărți din %d)"
		% [c_ordine_inversata, harti_cu_c, SEMINTE])
	print("(d) încrucișări în DESEN           : %d  (pe %d hărți din %d)"
		% [d_incrucisari_desen, harti_cu_d, SEMINTE])
	print("")
	print("Verificări vechi:")
	print("    noduri: între %d și %d  (cerut 12-16)   %s" % [
		noduri_min, noduri_max,
		"OK" if noduri_min >= 12 and noduri_max <= 16 else "PICAT"])
	print("    Boss pe ultimul nod: %s" % [
		"OK" if fara_boss_la_capat == 0 else "PICAT (%d hărți)" % fara_boss_la_capat])
	print("    Magazin prezent:     %s" % [
		"OK" if fara_magazin == 0 else "PICAT (%d hărți)" % fara_magazin])

	if primul_caz_c != "":
		print("")
		print("Primul caz de ordine stricată:")
		print(primul_caz_c)

	if primul_caz_d != "":
		print("")
		print("Primul caz de încrucișare în desen:")
		print(primul_caz_d)

	await _proba_pe_scena_adevarata()
	get_tree().quit()


## PROBA DE FUM: pornim ecranul de hartă adevărat și-l lăsăm să deseneze.
##
## Verificările de mai sus măsoară funcții luate separat. Asta răspunde la o
## întrebare pe care ele n-o ating: mai merge jocul? `_aseaza_nodurile()` și
## `_muchii()` au fost rescrise, iar o funcție care dă cifre bune dintr-un test
## poate totuși să crape când e chemată de o scenă vie.
##
## Nu verifică nimic despre desen. Dacă ceva s-a stricat, Godot scrie o eroare
## în consolă și o vezi deasupra liniei de la final.
func _proba_pe_scena_adevarata() -> void:
	print("")
	print("Proba de fum, pe scena adevărată:")
	Expeditie.incepe(["memorie", "logica"], 1000)

	var ecran: Node = load("res://scenes/harta/harta.tscn").instantiate()
	add_child(ecran)
	# Două cadre: unul ca să se așeze containerele, al doilea ca pânza să apuce
	# să deseneze. Un singur cadru ar fi trecut înainte ca harta să aibă mărime.
	await get_tree().process_frame
	await get_tree().process_frame

	print("    ecranul s-a construit, %d simboluri așezate" % ecran.simboluri_nod.size())
	ecran.queue_free()


## Zona utilă, pentru fereastra implicită.
##
## Aici SE COPIAZĂ o formulă din joc, și e singura copie din tot fișierul.
## Motivul: `_zona_utila()` întreabă `get_viewport_rect()` și poziția pânzei,
## adică lucruri care există doar când jocul chiar rulează. Ce se copiază e
## doar traducerea „fracțiuni de ecran → pixeli", nu așezarea nodurilor.
func _zona_de_test() -> Rect2:
	var hartie := Rect2(
		Harta.ZONA_PERGAMENT.position * ECRAN, Harta.ZONA_PERGAMENT.size * ECRAN)
	hartie.position.y -= INALTIME_ANTET
	var zona := hartie.intersection(
		Rect2(Vector2.ZERO, Vector2(ECRAN.x, ECRAN.y - INALTIME_ANTET)))
	var margine := Vector2(
		Harta.MARIME_NOD.x * 0.5 + Harta.MARGINE_PANZA,
		Harta.MARIME_NOD.y * 0.5 + Harta.MARGINE_PANZA)
	return zona.grow_individual(-margine.x, -margine.y, -margine.x, -margine.y)


# ─────────────────────────────────────────────────────────────
# (a) MUCHII CARE SAR PESTE UN STRAT
# ─────────────────────────────────────────────────────────────

func _numara_sarituri(harta: Array) -> int:
	var cate := 0
	for nod in harta:
		for id_urmator in nod["spre"]:
			var salt := int(harta[int(id_urmator)]["adancime"]) - int(nod["adancime"])
			if salt != 1:
				cate += 1
	return cate


# ─────────────────────────────────────────────────────────────
# (b) ÎNCRUCIȘĂRI ÎN GRAF
#
# Două muchii între aceleași două straturi se încrucișează dacă ordinea
# coloanelor e inversată la capete: una pleacă de deasupra celeilalte, dar
# ajunge dedesubtul ei. Nu e nevoie de geometrie — doar de semnele a două
# diferențe de coloană.
# ─────────────────────────────────────────────────────────────

func _numara_incrucisari_graf(harta: Array) -> int:
	var muchii := _muchii_hartii(harta)
	var cate := 0
	for i in range(muchii.size()):
		for j in range(i + 1, muchii.size()):
			if _se_incruciseaza(harta, muchii[i], muchii[j]):
				cate += 1
	return cate


## Toate muchiile hărții, ca perechi [de_la, la].
func _muchii_hartii(harta: Array) -> Array:
	var lista := []
	for nod in harta:
		for id_urmator in nod["spre"]:
			lista.append([int(nod["id"]), int(id_urmator)])
	return lista


func _se_incruciseaza(harta: Array, m1: Array, m2: Array) -> bool:
	if int(harta[m1[0]]["adancime"]) != int(harta[m2[0]]["adancime"]):
		return false
	if int(harta[m1[1]]["adancime"]) != int(harta[m2[1]]["adancime"]):
		return false
	var ds := int(harta[m1[0]]["coloana"]) - int(harta[m2[0]]["coloana"])
	var dj := int(harta[m1[1]]["coloana"]) - int(harta[m2[1]]["coloana"])
	return ds * dj < 0


# ─────────────────────────────────────────────────────────────
# (c) ABATEREA CARE INVERSEAZĂ ORDINEA PE VERTICALĂ
#
# Coloana 0 trebuie să rămână DEASUPRA coloanei 1, cu cel puțin o înălțime de
# nod între ele. Dacă abaterea organică împinge nodul 0 în jos și nodul 1 în
# sus destul cât să se încalece, drumurile desenate se vor încrucișa chiar
# dacă graful e curat.
# ─────────────────────────────────────────────────────────────

func _numara_ordine_inversata(harta: Array, centre: Dictionary) -> int:
	var pe_strat := {}
	for nod in harta:
		var a := int(nod["adancime"])
		if not pe_strat.has(a):
			pe_strat[a] = []
		pe_strat[a].append(int(nod["id"]))

	ultim_caz_c = ""
	var cate := 0
	for a in pe_strat:
		var ids: Array = pe_strat[a]
		var rau := false
		for i in range(ids.size()):
			for j in range(ids.size()):
				if int(harta[ids[i]]["coloana"]) >= int(harta[ids[j]]["coloana"]):
					continue
				# i e pe o coloană mai mică, deci trebuie să fie mai SUS.
				var dif: float = centre[ids[j]].y - centre[ids[i]].y
				if dif < Harta.MARIME_NOD.y:
					rau = true
					if ultim_caz_c == "":
						ultim_caz_c = ("    strat %d: nodul %d la y=%.4f, nodul %d la y=%.4f"
							+ "  →  %.4f px între ele (minim %.1f)") % [
							a, ids[i], centre[ids[i]].y, ids[j], centre[ids[j]].y,
							dif, Harta.MARIME_NOD.y]
		if rau:
			cate += 1
	return cate


# ─────────────────────────────────────────────────────────────
# (d) ÎNCRUCIȘĂRI ÎN DESENUL EFECTIV
#
# Verificarea finală, și singura care spune adevărul despre ce vede jucătorul:
# fiecare drum devine o linie frântă (un punct la PAS_ESANTION pixeli), apoi
# numărăm intersecțiile dintre două drumuri diferite. Zonele de lângă capete
# sunt sărite — acolo drumurile converg spre același nod prin construcție, iar
# liniuțele nici nu se desenează (vezi „oprire" în `panza.gd`).
# ─────────────────────────────────────────────────────────────

func _numara_incrucisari_desen(harta: Array, centre: Dictionary) -> int:
	var drumuri := []
	for m in _muchii_hartii(harta):
		drumuri.append(_linie_franta(centre[m[0]], centre[m[1]]))

	var cate := 0
	for i in range(drumuri.size()):
		for j in range(i + 1, drumuri.size()):
			if _drumuri_se_taie(drumuri[i], drumuri[j]):
				cate += 1
	return cate


## Un drum eșantionat, fără capetele ascunse sub „oprire".
##
## Întoarce și niște CUTII, nu doar punctele, și merită explicat de ce. Testul
## cinstit e „taie vreun segment din drumul A vreun segment din drumul B" —
## adică, la 140 de puncte pe drum, douăzeci de mii de verificări pentru o
## singură pereche, și miliarde pe 300 de semințe. A durat prea mult ca să fie
## folosibil.
##
## Leacul e clasic în grafică: împarți drumul în BUCĂȚI și ții minte
## dreptunghiul în care încape fiecare. Două bucăți ale căror dreptunghiuri nu
## se ating n-au cum să se taie, deci nici nu le mai deschizi. Rămân de
## verificat câteva perechi în loc de toate.
func _linie_franta(de_la: Vector2, la: Vector2) -> Dictionary:
	var oprire := Harta.OPRIRE_LA_NOD
	var capete := de_la.distance_to(la)
	if capete < oprire * 2.4:
		oprire = capete * 0.34

	var puncte := []
	var esantioane := maxi(16, int(capete * 1.4 / PAS_ESANTION))
	for i in range(esantioane + 1):
		var t := float(i) / float(esantioane)
		var p := Panza.punct_pe_drum(de_la, la, t)
		if p.distance_to(de_la) < oprire or p.distance_to(la) < oprire:
			continue
		puncte.append(p)

	# Cutiile bucăților, plus cutia întregului drum.
	var cutii := []
	var k := 0
	while k < puncte.size() - 1:
		var pana_la: int = mini(k + SEGMENTE_PE_BUCATA, puncte.size() - 1)
		cutii.append({
			"de_la": k, "la": pana_la,
			"cutie": _cutie(puncte, k, pana_la),
		})
		k = pana_la
	return {"puncte": puncte, "cutii": cutii, "cutie": _cutie(puncte, 0, puncte.size() - 1)}


## Dreptunghiul în care încap punctele de la `a` la `b`, umflat cu un pixel.
##
## Umflarea nu e cosmetică: un drum aproape orizontal are un dreptunghi de
## înălțime zero, iar `Rect2.intersects()` spune „nu se ating" pentru
## dreptunghiuri degenerate. Un pixel în plus e mult sub orice încrucișare
## adevărată și scapă de cazul ăla.
func _cutie(puncte: Array, a: int, b: int) -> Rect2:
	if puncte.is_empty():
		return Rect2()
	var r := Rect2(puncte[a], Vector2.ZERO)
	for i in range(a + 1, b + 1):
		r = r.expand(puncte[i])
	return r.grow(1.0)


func _drumuri_se_taie(d1: Dictionary, d2: Dictionary) -> bool:
	if not d1["cutie"].intersects(d2["cutie"]):
		return false
	var p1: Array = d1["puncte"]
	var p2: Array = d2["puncte"]
	for b1 in d1["cutii"]:
		for b2 in d2["cutii"]:
			if not b1["cutie"].intersects(b2["cutie"]):
				continue
			for i in range(int(b1["de_la"]), int(b1["la"])):
				for j in range(int(b2["de_la"]), int(b2["la"])):
					if Geometry2D.segment_intersects_segment(
							p1[i], p1[i + 1], p2[j], p2[j + 1]) != null:
						return true
	return false


func _descrie_caz(samanta: int, harta: Array, centre: Dictionary) -> String:
	var text := "    sămânța %d, %d noduri\n" % [samanta, harta.size()]
	for nod in harta:
		text += "      nod %2d  strat %d  col %d  la %s  →  %s\n" % [
			int(nod["id"]), int(nod["adancime"]), int(nod["coloana"]),
			str(centre[int(nod["id"])].round()), str(nod["spre"])]
	return text


func _are_magazin(harta: Array) -> bool:
	for nod in harta:
		if int(nod["tip"]) == Expeditie.Nod.MAGAZIN:
			return true
	return false

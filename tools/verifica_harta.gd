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
## `Harta.panglica()`, `Harta.asezare()` și `Harta.puncte_drum()` — dacă repar
## jocul și uit testul, testul pică, fiindcă n-are logică proprie pe care s-o
## repar greșit.
##
## ─────────────────────────────────────────────────────────────
## CE MĂSOARĂ, DE LA IEFTIN LA SCUMP
##
##   (0) PANGLICA în sine: raza celei mai strânse cotituri și dacă benzile
##       încap pe hârtie. Nu depinde de semințe — e geometrie curată.
##   (a) muchii care sar peste un strat        — greșeală de GENERATOR
##   (b) încrucișări în graf                   — greșeală de LEGĂTURI
##   (c) ordinea benzilor stricată de abatere  — greșeală de AȘEZARE
##   (d) încrucișări în desenul efectiv        — singura care spune ce vezi
##
## Amândouă traseele se măsoară în aceeași rulare, fiindcă întrebarea nu e
## „merge traseul din joc?", ci „care traseu merge?".

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

## Câte segmente intră într-o „bucată" de drum, la verificarea (d). Vezi nota
## de la `_linie_franta`.
const SEGMENTE_PE_BUCATA := 16

## Cât de des măsurăm curbura panglicii, în pixeli de arc. Trei puncte la
## distanța asta unul de altul dau cercul care trece prin ele.
const PAS_CURBURA := 4.0

## PRAGUL DE DISTANȚĂ ÎNTRE NODURI, în pixeli.
##
## NU e `MARIME_NOD.y` (92), și merită spus de ce, fiindcă 92 e cifra pe care
## ai alege-o din prima: două casete de 92 care se ating au centrele la 92 unul
## de altul.
##
## Numai că harta DREAPTĂ, cea de dinaintea panglicii, nu trecea nici ea pragul
## ăsta: măsurată pe aceleași 300 de semințe, cea mai apropiată pereche de
## noduri de pe ea era la 71,4 px. Și arăta bine — fiindcă imaginea desenată
## ocupă 0,78 din casetă (vezi `MARIME_IMAGINE` din `simbol_nod.gd`), adică
## vreo 72 px, iar restul e margine transparentă.
##
## Deci pragul corect nu e „cât de mari sunt casetele", ci „cât de aproape
## ajungeau nodurile pe harta pe care o înlocuiesc". 72 e numărul ăla,
## rotunjit în sus. O hartă nouă care stă peste el nu e o hartă perfectă; e o
## hartă care nu a stricat nimic.
const DISTANTA_PRAG := 72.0

## Ultimul strat prins cu ordinea stricată, ca text — pentru diagnostic.
var ultim_caz_c := ""


func _ready() -> void:
	var zona := _zona_de_test()
	print("Zona utilă de test: ", zona, "  (%.0f × %.0f px)" % [zona.size.x, zona.size.y])
	print("Semințe verificate: ", SEMINTE)
	print("Traseul din joc:    %s" % _nume_traseu(Harta.TRASEU))

	# Toate traseele, în aceeași rulare. Întrebarea nu e „merge cel din joc?",
	# ci „care merge?" — iar pe aia n-o poți răspunde măsurând unul singur.
	_masoara_traseu("VAL", Harta.Traseu.VAL, zona)
	_masoara_traseu("POTCOAVĂ", Harta.Traseu.POTCOAVA, zona)
	_masoara_traseu("POTCOAVĂ OGLINDITĂ", Harta.Traseu.POTCOAVA_OGLINDITA, zona)
	_masoara_traseu("ȘARPE", Harta.Traseu.SARPE, zona)

	await _proba_pe_scena_adevarata()
	get_tree().quit()


# ─────────────────────────────────────────────────────────────
# O RULARE COMPLETĂ, PE UN TRASEU
# ─────────────────────────────────────────────────────────────

func _masoara_traseu(nume: String, traseu: int, zona: Rect2) -> void:
	print("")
	print("═══ TRASEUL %s ═══%s" % [
		nume, "   ← cel din joc" if traseu == Harta.TRASEU else ""])

	var pang := Harta.panglica(zona, traseu)
	var latime: float = Harta.latime_panglica(zona, traseu)
	var k: float = Harta.forfecare(traseu)
	print("    lățimea panglicii:             %.1f px" % latime)
	print("    forfecarea stratului (k):      %.2f  →  stratul ține %.1f px cu %.1f px de lățime"
		% [k, latime * sqrt(1.0 + k * k), latime])
	_raport_panglica(pang, latime, zona, k)

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

	# Distanțele: ce ne spune dacă harta respiră sau e înghesuită.
	var suma_pas_strat := 0.0
	var suma_intre_straturi := 0.0
	var cate_intre_straturi := 0
	var minim_pe_strat := 99999.0
	var minim_oriunde := 99999.0
	var iesite_din_zona := 0
	var iesire_drum := 0.0

	for i in range(SEMINTE):
		var samanta := 1000 + i
		var harta := Expeditie.genereaza_harta(samanta)
		var asez := Harta.asezare(harta, pang, latime, k)

		var na := _numara_sarituri(harta)
		var nb := _numara_incrucisari_graf(harta)
		var nc := _numara_ordine_inversata(harta, asez, k)
		var nd := _numara_incrucisari_desen(harta, asez, pang, k)

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
				primul_caz_d = _descrie_caz(samanta, harta, asez)

		noduri_min = mini(noduri_min, harta.size())
		noduri_max = maxi(noduri_max, harta.size())
		if int(harta[harta.size() - 1]["tip"]) != Expeditie.Nod.BOSS:
			fara_boss_la_capat += 1
		if not _are_magazin(harta):
			fara_magazin += 1

		suma_pas_strat += pang.lungime_utila / float(_straturi(harta) - 1)
		for m in _muchii_hartii(harta):
			suma_intre_straturi += asez[m[0]]["centru"].distance_to(asez[m[1]]["centru"])
			cate_intre_straturi += 1
		minim_pe_strat = minf(minim_pe_strat, _cea_mai_mica_distanta_pe_strat(harta, asez))
		minim_oriunde = minf(minim_oriunde, _cea_mai_mica_distanta(asez))
		iesite_din_zona += _numara_iesite(asez, zona)
		iesire_drum = maxf(iesire_drum, _cat_ies_drumurile(harta, asez, pang, zona, k))

	print("")
	print("(a) muchii care sar peste un strat : %d  (pe %d hărți din %d)"
		% [a_sare_strat, harti_cu_a, SEMINTE])
	print("(b) încrucișări în GRAF            : %d  (pe %d hărți din %d)"
		% [b_incrucisari_graf, harti_cu_b, SEMINTE])
	print("(c) straturi cu ordinea inversată  : %d  (pe %d hărți din %d)"
		% [c_ordine_inversata, harti_cu_c, SEMINTE])
	print("(d) încrucișări în DESEN           : %d  (pe %d hărți din %d)"
		% [d_incrucisari_desen, harti_cu_d, SEMINTE])
	print("")
	print("Distanțe:")
	print("    între două straturi, PE PANGLICĂ : %.1f px (medie)"
		% [suma_pas_strat / float(SEMINTE)])
	print("    între două noduri legate, pe ecran: %.1f px (medie)"
		% [suma_intre_straturi / float(maxi(cate_intre_straturi, 1))])
	print("    cea mai mică distanță în același strat: %.1f px  (cerut %.1f)   %s"
		% [minim_pe_strat, Harta.MARIME_NOD.y,
			"OK" if minim_pe_strat >= Harta.MARIME_NOD.y else "PICAT"])
	# Aceeași întrebare, pusă pe TOATĂ harta. Pe un traseu care se întoarce
	# (ȘARPE), două noduri pot fi departe unul de altul PE PANGLICĂ și lipite pe
	# ecran, fiindcă panglica trece de două ori prin dreptul aceleiași fâșii de
	# hârtie. Verificarea „pe strat" n-are cum să prindă asta.
	print("    cea mai mică distanță între oricare două: %.1f px  (prag %.1f)   %s"
		% [minim_oriunde, DISTANTA_PRAG,
			"OK" if minim_oriunde >= DISTANTA_PRAG else "PICAT"])
	print("    noduri ieșite din zona utilă: %d   %s"
		% [iesite_din_zona, "OK" if iesite_din_zona == 0 else "PICAT"])
	print("    cât ies DRUMURILE din zona utilă: %.1f px   %s"
		% [iesire_drum, "OK" if iesire_drum <= 0.0 else "PICAT"])
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


# ─────────────────────────────────────────────────────────────
# (0) PANGLICA ÎN SINE
#
# Două condiții, amândouă despre geometrie, niciuna despre semințe.
#
# RAZA DE CURBURĂ. Pe o cotitură de rază R, banda dinspre INTERIOR are raza
# R − dec. Dacă dec ≥ R, raza devine zero sau negativă: banda trece dincolo de
# centrul cotiturii, se întoarce pe ea însăși și face o buclă. Deci jumătatea
# de lățime a panglicii trebuie să fie strict mai mică decât cea mai mică rază
# de pe tot traseul.
#
# ÎNCĂPEREA. Marginile panglicii (curba centrală ± jumătate de lățime) trebuie
# să stea în zona utilă — care e deja micșorată cu o jumătate de nod, deci un
# punct în zonă înseamnă un NOD întreg pe hârtie.
# ─────────────────────────────────────────────────────────────

func _raport_panglica(pang, latime: float, zona: Rect2, k: float) -> void:
	var lungime: float = pang.lungime
	# Nu jumătatea de lățime, ci CEA MAI MARE abatere laterală la care poate
	# ajunge un nod: banda plus abaterea organică. Fold-over-ul se întâmplă la
	# nodul cel mai depărtat de curbă, nu la banda „de manual".
	var jumatate: float = Harta.abatere_maxima_dec(latime)

	var raza_minima := INF
	var unde_minim := 0.0
	var iesire_maxima := 0.0

	var s := PAS_CURBURA
	while s < lungime - PAS_CURBURA:
		var r: float = pang.raza(s)
		if r < raza_minima:
			raza_minima = r
			unde_minim = s
		s += PAS_CURBURA

	s = 0.0
	while s <= lungime:
		for semn in [-1.0, 1.0]:
			var p: Vector2 = pang.punct(s, jumatate * semn)
			iesire_maxima = maxf(iesire_maxima, _cat_iese(p, zona))
		s += PAS_CURBURA

	print("    lungimea panglicii:            %.0f px" % lungime)
	print("    raza celei mai strânse cotituri: %.1f px (la %.0f px pe drum)"
		% [raza_minima, unde_minim])
	print("    cea mai mare abatere laterală:   %.1f px  (bandă %.1f + organic %.1f)"
		% [jumatate, latime * 0.5, jumatate - latime * 0.5])
	print("    (1) abatere < rază:   %s%s" % [
		"DA" if jumatate < raza_minima else "NU",
		"   (rezervă ×%.2f)" % (raza_minima / jumatate) if jumatate > 0.0 else ""])
	# Fâșia plină e o supraestimare, dinadins: include și cele două capete ale
	# panglicii, unde banda iese în diagonală peste marginea hârtiei, dar unde
	# nu stă niciodată niciun nod (primul și ultimul strat au un singur nod, pe
	# mijlocul panglicii, iar drumurile pleacă din el tot de pe mijloc).
	# Verdictul care contează e „ies DRUMURILE?", mai jos.
	var drepte := ""
	for portiune in pang.portiuni:
		drepte += "  [%.0f–%.0f]" % [portiune.x, portiune.y]
	# O singură porțiune, cât toată panglica, înseamnă două lucruri opuse: ori
	# traseul n-are nicio cotitură prea strânsă (bine), ori pragul e atât de
	# mare încât n-a calificat nimic și a intrat plasa (rău). Le deosebim după
	# prag, nu după cum arată rezultatul.
	var prag: float = Harta.raza_minima_noduri(latime, k)
	var semn := ""
	if prag == INF:
		semn = "   ← PLASĂ: nimic nu e destul de drept, nodurile intră în cotituri"
	print("    porțiuni pe care se așază noduri: %d,%s   (%.0f px din %.0f)%s"
		% [pang.portiuni.size(), drepte, pang.lungime_utila, lungime, semn])
	print("    rază cerută pentru noduri:     %s"
		% ["oricare (fără forfecare)" if prag <= 0.0 else "%.0f px" % prag])
	print("    (2) fâșia plină încape în zonă: %s" % [
		"DA" if iesire_maxima <= 0.0 else "NU — colțurile ei ies cu %.1f px" % iesire_maxima])


## Raza cercului care trece prin trei puncte. Trei puncte pe o dreaptă dau
## suprafață zero, adică rază infinită — exact ce vrem pe porțiunile drepte.
func _raza_prin_trei_puncte(a: Vector2, b: Vector2, c: Vector2) -> float:
	var l1 := a.distance_to(b)
	var l2 := b.distance_to(c)
	var l3 := c.distance_to(a)
	var arie: float = absf((b - a).cross(c - a)) * 0.5
	if arie < 0.000001:
		return INF
	return (l1 * l2 * l3) / (4.0 * arie)


## Cu câți pixeli iese punctul din dreptunghi (0 dacă e înăuntru).
func _cat_iese(p: Vector2, zona: Rect2) -> float:
	return maxf(
		maxf(zona.position.x - p.x, p.x - zona.end.x),
		maxf(zona.position.y - p.y, p.y - zona.end.y))


func _numara_iesite(asez: Dictionary, zona: Rect2) -> int:
	var cate := 0
	for id in asez:
		if _cat_iese(asez[id]["centru"], zona) > 0.0:
			cate += 1
	return cate


func _straturi(harta: Array) -> int:
	var maxim := 0
	for nod in harta:
		maxim = maxi(maxim, int(nod["adancime"]))
	return maxim + 1


## Cea mai mică distanță între oricare două noduri ale hărții.
func _cea_mai_mica_distanta(asez: Dictionary) -> float:
	var ids := asez.keys()
	var minim := 99999.0
	for i in range(ids.size()):
		for j in range(i + 1, ids.size()):
			minim = minf(minim,
				asez[ids[i]]["centru"].distance_to(asez[ids[j]]["centru"]))
	return minim


## Cu cât ies punctele DRUMURILOR din zona utilă.
##
## Verificarea asta e cea corectă pentru „încap benzile?". Fâșia plină (curba
## ± jumătate de lățime) e o supraestimare: la capetele panglicii nu stă niciun
## nod pe bandă (primul și ultimul strat au un singur nod, pe mijloc), deci
## colțurile fâșiei de acolo nu se desenează niciodată. Drumurile, în schimb,
## sunt exact ce se vede.
func _cat_ies_drumurile(
	harta: Array, asez: Dictionary, pang, zona: Rect2, k: float
) -> float:
	var maxim := 0.0
	for m in _muchii_hartii(harta):
		var a: Dictionary = asez[m[0]]
		var b: Dictionary = asez[m[1]]
		for punct in Harta.puncte_drum(pang, a["s"], a["dec"], b["s"], b["dec"], k):
			maxim = maxf(maxim, _cat_iese(punct, zona))
	return maxim


func _cea_mai_mica_distanta_pe_strat(harta: Array, asez: Dictionary) -> float:
	var pe_strat := {}
	for nod in harta:
		var a := int(nod["adancime"])
		if not pe_strat.has(a):
			pe_strat[a] = []
		pe_strat[a].append(int(nod["id"]))

	var minim := 99999.0
	for a in pe_strat:
		var ids: Array = pe_strat[a]
		for i in range(ids.size()):
			for j in range(i + 1, ids.size()):
				minim = minf(minim,
					asez[ids[i]]["centru"].distance_to(asez[ids[j]]["centru"]))
	return minim


## PROBA DE FUM: pornim ecranul de hartă adevărat și-l lăsăm să deseneze.
##
## Verificările de mai sus măsoară funcții luate separat. Asta răspunde la o
## întrebare pe care ele n-o ating: mai merge jocul? O funcție care dă cifre
## bune dintr-un test poate totuși să crape când e chemată de o scenă vie.
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
## Nu mai e nicio formulă copiată aici: `Harta.zona_utila_din()` e chiar
## socoteala jocului, doar cu ecranul și pânza primite din afară — fiindcă
## `_zona_utila()` le-ar cere de la `get_viewport_rect()` și de la pânză, adică
## de la lucruri care există numai când jocul chiar rulează.
##
## Harta GENERATĂ stă pe `ZONA_PERGAMENT`, cea tăiată sub linia cărții. Vezi
## nota de acolo: panglica e un dreptunghi cu benzi, deci nu poate ocoli un colț
## interzis. Planșele desenate au zona lor, mai largă (`ZONA_PLANSA`), verificată
## în `verifica_plansa.gd`.
func _zona_de_test() -> Rect2:
	return Harta.zona_utila_din(
		Harta.ZONA_PERGAMENT, ECRAN, Vector2(0.0, INALTIME_ANTET),
		Vector2(ECRAN.x, ECRAN.y - INALTIME_ANTET))


# ─────────────────────────────────────────────────────────────
# (a) MUCHII CARE SAR PESTE UN STRAT
# ─────────────────────────────────────────────────────────────

func _nume_traseu(traseu: int) -> String:
	match traseu:
		Harta.Traseu.VAL:
			return "VAL"
		Harta.Traseu.POTCOAVA:
			return "POTCOAVĂ"
		Harta.Traseu.POTCOAVA_OGLINDITA:
			return "POTCOAVĂ OGLINDITĂ"
		Harta.Traseu.SARPE:
			return "ȘARPE"
	return "?"


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
# (c) ABATEREA CARE INVERSEAZĂ ORDINEA BENZILOR
#
# Verificarea se face acum pe `dec` — poziția LATERALĂ pe panglică — nu pe `y`
# de pe ecran, și asta e schimbarea importantă a fișierului.
#
# De ce: pe un traseu care întoarce (ȘARPE), „coloana 0 e mai sus pe ecran" e
# pur și simplu fals pe porțiunile unde drumul merge de la dreapta la stânga —
# acolo, banda 0 e dedesubt, și e corect să fie. Ce trebuie să rămână adevărat
# e că ordinea BENZILOR nu se inversează, fiindcă asta e ordinea pe care se
# bazează drumurile ca să nu se taie.
# ─────────────────────────────────────────────────────────────

func _numara_ordine_inversata(harta: Array, asez: Dictionary, k: float) -> int:
	# Pragul pe `dec` scade cu forfecarea, din același motiv ca în `asezare()`:
	# pe un strat înclinat, o parte din distanța dintre noduri vine din lungime,
	# nu din lateral. Fără corecția asta, verificarea ar cere lățimea pe care
	# forfecarea tocmai a făcut-o de prisos — și ar raporta „PICAT" pe o hartă
	# care arată bine. (A și făcut-o: 1801 straturi „stricate", toate în ordine.)
	var minim: float = Harta.MARIME_NOD.y / sqrt(1.0 + k * k)
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
				# i e pe o coloană mai mică, deci trebuie să fie pe o bandă mai mică.
				var dif: float = asez[ids[j]]["dec"] - asez[ids[i]]["dec"]
				if dif < minim:
					rau = true
					if ultim_caz_c == "":
						ultim_caz_c = ("    strat %d: nodul %d pe banda %.4f, nodul %d pe %.4f"
							+ "  →  %.4f px între ele (minim %.1f)") % [
							a, ids[i], asez[ids[i]]["dec"], ids[j], asez[ids[j]]["dec"],
							dif, minim]
		if rau:
			cate += 1
	return cate


# ─────────────────────────────────────────────────────────────
# (d) ÎNCRUCIȘĂRI ÎN DESENUL EFECTIV
#
# Verificarea finală, și singura care spune adevărul despre ce vede jucătorul:
# fiecare drum e transformat în linie frântă CU ACEEAȘI FUNCȚIE care o desenează
# în joc (`Harta.puncte_drum`), apoi se numără intersecțiile dintre două drumuri
# diferite. Zonele de lângă capete sunt sărite — acolo drumurile converg spre
# același nod prin construcție, iar liniuțele nici nu se desenează (vezi
# „oprire" în `panza.gd`).
# ─────────────────────────────────────────────────────────────

func _numara_incrucisari_desen(harta: Array, asez: Dictionary, pang, k: float) -> int:
	var drumuri := []
	for m in _muchii_hartii(harta):
		drumuri.append(_linie_franta(pang, asez[m[0]], asez[m[1]], k))

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
func _linie_franta(pang, a: Dictionary, b: Dictionary, forf: float) -> Dictionary:
	var toate := Harta.puncte_drum(pang, a["s"], a["dec"], b["s"], b["dec"], forf)
	var de_la: Vector2 = toate[0]
	var la: Vector2 = toate[toate.size() - 1]

	var oprire: float = Harta.OPRIRE_LA_NOD
	var capete := de_la.distance_to(la)
	if capete < oprire * 2.4:
		oprire = capete * 0.34

	var puncte := []
	for p in toate:
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


func _descrie_caz(samanta: int, harta: Array, asez: Dictionary) -> String:
	var text := "    sămânța %d, %d noduri\n" % [samanta, harta.size()]
	for nod in harta:
		var id := int(nod["id"])
		text += "      nod %2d  strat %d  col %d  s=%.0f dec=%+.0f  la %s  →  %s\n" % [
			id, int(nod["adancime"]), int(nod["coloana"]),
			asez[id]["s"], asez[id]["dec"],
			str(asez[id]["centru"].round()), str(nod["spre"])]
	return text


func _are_magazin(harta: Array) -> bool:
	for nod in harta:
		if int(nod["tip"]) == Expeditie.Nod.MAGAZIN:
			return true
	return false

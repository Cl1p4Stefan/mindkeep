extends Node
## VERIFICAREA PLANȘELOR — trece prin fiecare hartă desenată și o măsoară.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verifica_plansa.tscn
##
## Verifică TOATE fișierele din `data/harti/`, nu doar cea jucată. Motivul e
## practic: o planșă pe care n-o joci azi e o planșă pe care o joci peste o lună,
## după ce ai uitat ce voiai de la ea. Dacă e stricată, vrei să afli acum.
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ FIȘIERUL ĂSTA, ȘI DE CE E ALTFEL DECÂT `verifica_harta.gd`
##
## Harta generată nu se poate încrucișa. Nu fiindcă am verificat-o, ci fiindcă e
## CONSTRUITĂ așa: feliile merg înainte, drumurile stau pe o panglică, iar
## argumentul de la `puncte_drum()` arată de ce două drumuri nu se pot inversa.
## `verifica_harta.gd` măsoară ca să prindă o demonstrație greșită.
##
## O planșă desenată de mână nu are nicio demonstrație. Nodurile sunt unde le-ai
## pus, drumurile trec pe unde le-ai tras. Aici verificarea nu mai e o plasă sub
## o demonstrație — E SINGURA GARANȚIE. Asta e prețul formei libere, și e un preț
## corect: în schimbul lui poți desena un loc, nu doar o bandă.
##
## Deci ăsta nu e un test „de regresie”, ci UNEALTA DE DESEN. Îl rulezi în timp
## ce desenezi, ca să vezi ce ai stricat.
##
## ─────────────────────────────────────────────────────────────
## CE MĂSOARĂ
##
## GRAFUL — poate fi greșit chiar dacă desenul arată bine:
##   (1) toate nodurile se pot atinge din Start
##   (2) din orice nod se poate ajunge la Boss
##   (3) nu există cicluri
##   (4) niciun nod fără ieșire, în afară de Boss
##
## DESENUL — poate fi greșit chiar dacă graful e curat:
##   (5) capetele drumurilor cad pe centrele nodurilor
##   (6) drumurile nu se taie între ele
##   (7) cea mai apropiată pereche de noduri e la cel puțin 72 px
##   (8) totul stă pe hârtie
##
## CONȚINUTUL — regulile care trag tipurile din sămânță, pe 300 de semințe:
##   Bossul pe ultimul nod, Magazinul prezent, Startul mereu o Luptă obișnuită.
##
## Plus, ca informație: cel mai scurt și cel mai lung traseu de la Start la Boss.

const Harta := preload("res://scenes/harta/harta.gd")

const SEMINTE := 300

## Fereastra implicită a proiectului. Zona de pergament e dată în fracțiuni de
## ecran, deci am nevoie de o mărime concretă ca să obțin pixeli.
const ECRAN := Vector2(1152.0, 648.0)

## Înălțimea antetului de deasupra pânzei, în scena hărții.
const INALTIME_ANTET := 84.0

## PRAGUL DE DISTANȚĂ ÎNTRE NODURI, în pixeli. Același cu cel din
## `verifica_harta.gd`, și din același motiv: imaginea desenată ocupă 0,78 din
## caseta de 92 px, adică vreo 72 px — deci sub 72 două SIMBOLURI se ating, chiar
## dacă până la 92 doar casetele lor invizibile se suprapun.
const DISTANTA_PRAG := 72.0

## Cât are voie să fie depărtat capătul unui drum de centrul nodului lui.
## Câțiva pixeli nu se văd (drumul se oprește oricum la `OPRIRE_LA_NOD` de nod);
## mai mult înseamnă că ai tras drumul spre alt nod decât ai crezut.
const ABATERE_CAPAT := 4.0

## Câte segmente intră într-o bucată de drum, la verificarea încrucișărilor.
const SEGMENTE_PE_BUCATA := 16


func _ready() -> void:
	var zona := _zona_de_test()
	print("Zona utilă de test: %.0f × %.0f px  (fereastra %.0f × %.0f)"
		% [zona.size.x, zona.size.y, ECRAN.x, ECRAN.y])
	print("Semințe verificate pentru tipuri: %d" % SEMINTE)

	var cai := _planse()
	if cai.is_empty():
		print("Niciun fișier .json în %s" % Plansa.DOSAR)
		get_tree().quit(1)
		return

	var toate_bune := true
	for cale in cai:
		toate_bune = _verifica(cale, zona) and toate_bune

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % ["toate planșele sunt bune" if toate_bune else "CEVA E STRICAT"])
	get_tree().quit(0 if toate_bune else 1)


## Toate planșele din dosar, în ordine alfabetică.
func _planse() -> Array[String]:
	var gasite: Array[String] = []
	for nume in DirAccess.get_files_at(Plansa.DOSAR):
		if nume.get_extension().to_lower() == "json":
			gasite.append(Plansa.DOSAR + nume)
	gasite.sort()
	return gasite


# ─────────────────────────────────────────────────────────────
# O PLANȘĂ, CAP-COADĂ
# ─────────────────────────────────────────────────────────────

func _verifica(cale: String, zona: Rect2) -> bool:
	print("")
	print("═══ %s ═══" % cale.get_file())

	# `citeste`, nu `incarca`: verificarea trebuie să vadă fișierul de pe disc,
	# nu ce-a ținut minte cineva mai devreme în aceeași rulare.
	var plansa := Plansa.citeste(cale)
	if String(plansa["eroare"]) != "":
		print("    FIȘIER STRICAT: %s" % plansa["eroare"])
		return false

	var cutia := Plansa.cutie(zona, float(plansa["raport"]))
	print("    %d noduri, %d drumuri, raport %.4f"
		% [plansa["ordine"].size(), plansa["drumuri"].size(), plansa["raport"]])
	print("    cutia desenului, pe ecran: %.0f × %.0f px, colț la (%.0f, %.0f)"
		% [cutia.size.x, cutia.size.y, cutia.position.x, cutia.position.y])

	var bun := true
	print("")
	print("  GRAFUL")
	bun = _toate_atinse(plansa) and bun
	bun = _toti_ajung_la_boss(plansa) and bun
	var topologic := _ordine_topologica(plansa)
	bun = _fara_cicluri(plansa, topologic) and bun
	bun = _fara_fundaturi(plansa) and bun

	print("")
	print("  DESENUL")
	bun = _capete_pe_noduri(plansa, cutia) and bun
	bun = _fara_incrucisari(plansa, cutia) and bun
	bun = _noduri_departate(plansa, cutia) and bun
	bun = _totul_pe_hartie(plansa, cutia, zona) and bun
	_drumuri_pe_langa_noduri(plansa, cutia)

	print("")
	print("  TRASEELE")
	_trasee(plansa, topologic)

	print("")
	print("  TIPURILE, PE %d DE SEMINȚE" % SEMINTE)
	bun = _tipuri_pe_seminte(cale, plansa) and bun

	return bun


func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-44s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


# ─────────────────────────────────────────────────────────────
# GRAFUL
# ─────────────────────────────────────────────────────────────

## (1) Toate nodurile se pot atinge din Start.
##
## `Plansa.adancimi()` face deja parcurgerea în lățime și întoarce doar nodurile
## atinse — deci „cine lipsește din rezultat” e chiar răspunsul. Folosim aceeași
## funcție pe care o folosește jocul, nu una scrisă aici: dacă ea s-ar strica,
## verificarea trebuie să se strice odată cu ea, nu să rămână verde.
func _toate_atinse(plansa: Dictionary) -> bool:
	var adanc := Plansa.adancimi(plansa)
	var lipsa: Array[String] = []
	for reper in plansa["ordine"]:
		if not adanc.has(reper):
			lipsa.append(String(reper))
	return _verdict("(1) toate nodurile se ating din Start", lipsa.is_empty(),
		"" if lipsa.is_empty() else "izolate: %s" % ", ".join(lipsa))


## (2) Din orice nod se poate ajunge la Boss.
##
## Aceeași parcurgere, dar PE DRUMURI ÎNTOARSE: pleci din Boss și mergi înapoi.
## Cine e atins așa e cine poate ajunge la el. Mult mai ieftin decât o căutare
## separată din fiecare nod, și mai ușor de citit: o singură parcurgere, nu N.
func _toti_ajung_la_boss(plansa: Dictionary) -> bool:
	var inapoi := {}
	for reper in plansa["ordine"]:
		inapoi[reper] = []
	for reper in plansa["ordine"]:
		for spre in plansa["spre"][reper]:
			inapoi[spre].append(reper)

	var atinse := {String(plansa["boss"]): true}
	var coada: Array[String] = [String(plansa["boss"])]
	var i := 0
	while i < coada.size():
		var aici := coada[i]
		i += 1
		for inainte in inapoi[aici]:
			if not atinse.has(inainte):
				atinse[inainte] = true
				coada.append(String(inainte))

	var infundate: Array[String] = []
	for reper in plansa["ordine"]:
		if not atinse.has(reper):
			infundate.append(String(reper))
	return _verdict("(2) din orice nod se ajunge la Boss", infundate.is_empty(),
		"" if infundate.is_empty() else "nu ajung: %s" % ", ".join(infundate))


## ORDINEA TOPOLOGICĂ: nodurile aranjate așa încât fiecare drum să meargă
## înainte în listă. Array gol = există un ciclu.
##
## E algoritmul lui Kahn: scoți întâi nodurile în care nu intră niciun drum, apoi
## tai drumurile lor și repeți. Dacă la final au rămas noduri nescoase, alea sunt
## prinse într-un ciclu — fiecare așteaptă pe altul din ciclu să iasă primul.
##
## O folosesc la două lucruri: verificarea de cicluri și cel mai lung traseu.
## Amândouă au nevoie de ea, deci se calculează o dată.
func _ordine_topologica(plansa: Dictionary) -> Array:
	var intrari := {}
	for reper in plansa["ordine"]:
		intrari[reper] = 0
	for reper in plansa["ordine"]:
		for spre in plansa["spre"][reper]:
			intrari[spre] = int(intrari[spre]) + 1

	var ordine: Array = []
	for reper in plansa["ordine"]:
		if int(intrari[reper]) == 0:
			ordine.append(reper)

	var i := 0
	while i < ordine.size():
		var aici = ordine[i]
		i += 1
		for spre in plansa["spre"][aici]:
			intrari[spre] = int(intrari[spre]) - 1
			if int(intrari[spre]) == 0:
				ordine.append(spre)

	if ordine.size() < plansa["ordine"].size():
		return []
	return ordine


## (3) Fără cicluri.
##
## Un ciclu pe hartă ar fi un drum care se întoarce de unde ai plecat. Nu e o
## catastrofă tehnică — jocul l-ar desena — dar strică regula pe care se sprijină
## tot restul: adâncimea, bugetul care crește, senzația că drumul MERGE undeva.
## Cu un ciclu, poți învârti la nesfârșit un nod de Odihnă.
func _fara_cicluri(plansa: Dictionary, topologic: Array) -> bool:
	var bun := not topologic.is_empty()
	var amanunt := ""
	if not bun:
		var in_ciclu: Array[String] = []
		for reper in plansa["ordine"]:
			if not (reper in topologic):
				in_ciclu.append(String(reper))
		amanunt = "prinse în ciclu: %s" % ", ".join(in_ciclu)
	return _verdict("(3) fără cicluri", bun, amanunt)


## (4) Niciun nod fără ieșire, în afară de Boss.
##
## Un nod fără ieșire e o fundătură: intri și expediția se termină acolo, fiindcă
## `Expeditie.la_capat()` înseamnă chiar „n-am unde merge”. Ai câștiga runul la
## jumătatea hărții, fără să dai de Boss.
func _fara_fundaturi(plansa: Dictionary) -> bool:
	var fundaturi: Array[String] = []
	for reper in plansa["ordine"]:
		if reper != plansa["boss"] and plansa["spre"][reper].is_empty():
			fundaturi.append(String(reper))
	var boss_are_iesire: bool = not plansa["spre"][plansa["boss"]].is_empty()
	if boss_are_iesire:
		fundaturi.append("(Bossul ARE ieșire, deși n-ar trebui)")
	return _verdict("(4) fără fundături, în afară de Boss", fundaturi.is_empty(),
		"" if fundaturi.is_empty() else ", ".join(fundaturi))


# ─────────────────────────────────────────────────────────────
# DESENUL
# ─────────────────────────────────────────────────────────────

## Punctele unui drum, în pixeli, exact cum le calculează jocul.
##
## `Harta.curba_neteda(...).get_baked_points()` e chiar linia din
## `geometrie_desenata()`. Dacă mâine se schimbă netezirea, se schimbă și ce
## măsoară verificarea — care e singurul fel în care o verificare rămâne
## adevărată.
func _puncte(plansa: Dictionary, drum: Dictionary, cutia: Rect2) -> PackedVector2Array:
	var puncte := []
	for fractie in drum["puncte"]:
		puncte.append(Plansa.in_pixeli(fractie, cutia))
	return Harta.curba_neteda(puncte).get_baked_points()


## (5) Capetele drumurilor cad pe centrele nodurilor.
##
## Greșeala clasică la desenat: muți un nod și uiți să muți și capătul drumului.
## Nu se vede pe ecran, fiindcă drumul se oprește oricum la 56 px de simbol —
## deci arată perfect normal, doar pornește din altă parte decât crezi. Iar dacă
## l-ai mutat mult, drumul pleacă spre nodul greșit și tu te uiți la desen
## întrebându-te de ce nu se leagă.
func _capete_pe_noduri(plansa: Dictionary, cutia: Rect2) -> bool:
	var cea_mai_mare := 0.0
	var vinovat := ""
	for drum in plansa["drumuri"]:
		var puncte: Array = drum["puncte"]
		var perechi := [
			[puncte[0], plansa["poz"][drum["de_la"]], drum["de_la"]],
			[puncte[puncte.size() - 1], plansa["poz"][drum["la"]], drum["la"]],
		]
		for pereche in perechi:
			var abatere: float = Plansa.in_pixeli(pereche[0], cutia).distance_to(
				Plansa.in_pixeli(pereche[1], cutia))
			if abatere > cea_mai_mare:
				cea_mai_mare = abatere
				vinovat = "%s → %s, la capătul %s" % [
					drum["de_la"], drum["la"], pereche[2]]

	return _verdict("(5) capetele drumurilor, pe centrele nodurilor",
		cea_mai_mare <= ABATERE_CAPAT,
		"cea mai mare abatere %.1f px (prag %.1f)%s" % [
			cea_mai_mare, ABATERE_CAPAT,
			"" if cea_mai_mare <= ABATERE_CAPAT else "  ← %s" % vinovat])


## (6) Drumurile nu se taie între ele.
##
## Fiecare drum devine o linie frântă, fără capetele ascunse sub „oprire” (acolo
## drumurile care intră în același nod converg prin construcție, iar liniuțele
## nici nu se desenează). Apoi se caută intersecții între oricare două.
##
## Ca să nu dureze o veșnicie, drumurile se taie în bucăți cu cutia lor: două
## bucăți ale căror dreptunghiuri nu se ating n-au cum să se taie. E leacul
## clasic, același ca în `verifica_harta.gd`.
func _fara_incrucisari(plansa: Dictionary, cutia: Rect2) -> bool:
	var drumuri := []
	for drum in plansa["drumuri"]:
		drumuri.append(_linie_franta(_puncte(plansa, drum, cutia), drum))

	var gasite: Array[String] = []
	for i in range(drumuri.size()):
		for j in range(i + 1, drumuri.size()):
			if _se_taie(drumuri[i], drumuri[j]):
				gasite.append("%s × %s" % [drumuri[i]["nume"], drumuri[j]["nume"]])

	return _verdict("(6) drumurile nu se taie", gasite.is_empty(),
		"" if gasite.is_empty() else "%d perechi: %s" % [
			gasite.size(), ", ".join(gasite)])


func _linie_franta(toate: PackedVector2Array, drum: Dictionary) -> Dictionary:
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

	var cutii := []
	var k := 0
	while k < puncte.size() - 1:
		var pana_la: int = mini(k + SEGMENTE_PE_BUCATA, puncte.size() - 1)
		cutii.append({"de_la": k, "la": pana_la, "cutie": _cutie(puncte, k, pana_la)})
		k = pana_la

	return {
		"nume": "%s→%s" % [drum["de_la"], drum["la"]],
		"puncte": puncte,
		"cutii": cutii,
		"cutie": _cutie(puncte, 0, maxi(puncte.size() - 1, 0)),
	}


## Dreptunghiul în care încap punctele de la `a` la `b`, umflat cu un pixel.
## Umflarea nu e cosmetică: un drum aproape orizontal are un dreptunghi de
## înălțime zero, iar `Rect2.intersects()` spune „nu se ating” pentru
## dreptunghiuri degenerate.
func _cutie(puncte: Array, a: int, b: int) -> Rect2:
	if puncte.is_empty():
		return Rect2()
	var r := Rect2(puncte[a], Vector2.ZERO)
	for i in range(a + 1, b + 1):
		r = r.expand(puncte[i])
	return r.grow(1.0)


func _se_taie(d1: Dictionary, d2: Dictionary) -> bool:
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


## (7) Cea mai apropiată pereche de noduri.
func _noduri_departate(plansa: Dictionary, cutia: Rect2) -> bool:
	var repere: Array = plansa["ordine"]
	var minim := INF
	var pereche := ""
	for i in range(repere.size()):
		for j in range(i + 1, repere.size()):
			var d: float = Plansa.in_pixeli(plansa["poz"][repere[i]], cutia).distance_to(
				Plansa.in_pixeli(plansa["poz"][repere[j]], cutia))
			if d < minim:
				minim = d
				pereche = "%s – %s" % [repere[i], repere[j]]
	return _verdict("(7) noduri destul de depărtate", minim >= DISTANTA_PRAG,
		"cea mai apropiată pereche %.1f px (prag %.1f): %s" % [
			minim, DISTANTA_PRAG, pereche])


## (8) Totul stă pe hârtie — dar „hârtie" înseamnă altceva pentru un nod decât
## pentru un drum, și asta e toată subtilitatea verificării.
##
## Un NOD e un simbol de 92 px. Ca să încapă întreg, CENTRUL lui trebuie să stea
## în `zona` — care e chiar pergamentul micșorat cu o jumătate de nod plus o
## margine (vezi `_zona_utila()` din hartă). Nodurile nu pot ieși de acolo dacă
## fracțiunile sunt între 0 și 1, fiindcă toată cutia desenului e, prin
## construcție, în zonă.
##
## Un DRUM e o linie de 6 px. N-are nicio jumătate de nod de protejat, deci
## măsura pentru el e HÂRTIA ÎNTREAGĂ — `zona` crescută înapoi cu marginea aia.
##
## Am aflat diferența dintr-un PICAT: drumul C4 → W4 din `harta_01.json` trece cu
## 1,1 px dincolo de marginea zonei nodurilor, fiindcă are un punct desenat fix
## pe fracțiunea 1,0 (marginea de jos a cutiei), iar curba netedă trasă prin
## puncte iese puțin în afara lor la cotituri — exact cum o coardă întinsă iese
## din potcoavă. Verdictul „PICAT" era însă greșit, nu desenul: acolo mai erau 64
## px de hârtie liberă sub el.
##
## Puteam „repara" strâmbând desenul (o cutie ceva mai mică decât zona). Ar fi
## fost o minciună mică: forma pe care o desenezi n-ar mai fi fost forma pe care
## o vezi, ca să treacă o măsurătoare pusă greșit. Mai bine pusă cum trebuie.
##
## Cei 1,1 px rămân la vedere, ca informație: nu contează azi, dar dacă vreodată
## ajung 60, înseamnă că ai desenat un drum care chiar iese de pe pergament.
func _totul_pe_hartie(plansa: Dictionary, cutia: Rect2, zona: Rect2) -> bool:
	var hartia := zona.grow_individual(
		Harta.MARIME_NOD.x * 0.5 + Harta.MARGINE_PANZA,
		Harta.MARIME_NOD.y * 0.5 + Harta.MARGINE_PANZA,
		Harta.MARIME_NOD.x * 0.5 + Harta.MARGINE_PANZA,
		Harta.MARIME_NOD.y * 0.5 + Harta.MARGINE_PANZA)

	var iesire_noduri := 0.0
	var nod_vinovat := ""
	for reper in plansa["ordine"]:
		var cat := _cat_iese(Plansa.in_pixeli(plansa["poz"][reper], cutia), zona)
		if cat > iesire_noduri:
			iesire_noduri = cat
			nod_vinovat = String(reper)

	var iesire_drumuri := 0.0
	var peste_zona := 0.0
	var drum_vinovat := ""
	for drum in plansa["drumuri"]:
		for punct in _puncte(plansa, drum, cutia):
			iesire_drumuri = maxf(iesire_drumuri, _cat_iese(punct, hartia))
			var cat := _cat_iese(punct, zona)
			if cat > peste_zona:
				peste_zona = cat
				drum_vinovat = "%s→%s" % [drum["de_la"], drum["la"]]

	var bun := iesire_noduri <= 0.0 and iesire_drumuri <= 0.0
	_verdict("(8) totul stă pe hârtie", bun,
		"noduri %.1f px peste zona lor, drumuri %.1f px peste hârtie%s" % [
			iesire_noduri, iesire_drumuri,
			"" if nod_vinovat == "" else "  ← %s" % nod_vinovat])
	print("    %-44s %.1f px%s   (mai e hârtie: %.0f px)" % [
		"(i) cât ies drumurile din zona nodurilor", peste_zona,
		"" if drum_vinovat == "" else " (%s)" % drum_vinovat,
		Harta.MARIME_NOD.y * 0.5 + Harta.MARGINE_PANZA])
	return bun


## Cu câți pixeli iese punctul din dreptunghi (0 dacă e înăuntru).
func _cat_iese(p: Vector2, zona: Rect2) -> float:
	return maxf(
		maxf(zona.position.x - p.x, p.x - zona.end.x),
		maxf(zona.position.y - p.y, p.y - zona.end.y))


## INFORMATIV: cât de aproape trece un drum de un nod CU CARE N-ARE TREABĂ.
##
## Nu e o regulă, fiindcă nu există un prag adevărat — dar e numărul care explică
## cea mai enervantă greșeală de desen. Un drum care trece pe sub un simbol arată
## exact ca un drum care intră în el: te uiți la hartă, crezi că poți merge
## acolo, dai click și nu se întâmplă nimic.
##
## Sub o jumătate de nod (46 px) e sigur o problemă. Între 46 și 70 merită o
## privire. Peste — e doar un drum care trece pe lângă.
func _drumuri_pe_langa_noduri(plansa: Dictionary, cutia: Rect2) -> void:
	var minim := INF
	var unde := ""
	for drum in plansa["drumuri"]:
		var puncte := _puncte(plansa, drum, cutia)
		for reper in plansa["ordine"]:
			if reper == drum["de_la"] or reper == drum["la"]:
				continue
			var centru := Plansa.in_pixeli(plansa["poz"][reper], cutia)
			for punct in puncte:
				var d := punct.distance_to(centru)
				if d < minim:
					minim = d
					unde = "%s→%s pe lângă %s" % [drum["de_la"], drum["la"], reper]
	print("    %-44s %.1f px   (%s)" % [
		"(i) drum străin pe lângă un nod", minim, unde])


# ─────────────────────────────────────────────────────────────
# TRASEELE
# ─────────────────────────────────────────────────────────────

## CEL MAI SCURT ȘI CEL MAI LUNG TRASEU de la Start la Boss.
##
## Astea două sunt, de fapt, cea mai importantă informație de design din tot
## fișierul. Diferența dintre ele e cât de mult contează alegerea drumului: dacă
## toate traseele au 7 noduri, ramificațiile sunt decor. Dacă unul are 7 și altul
## 11, drumul lung e o decizie — mai multe lupte, mai multe Monede, mai mult PV
## pierdut.
##
## SCURTUL vine din parcurgerea în lățime (`Plansa.adancimi`, refăcută aici cu
## părinți, ca să pot spune și PE UNDE trece).
##
## LUNGUL nu se poate afla la fel, și merită știut de ce: „cel mai lung drum”
## într-un graf oarecare e o problemă fără soluție practică. Într-un graf FĂRĂ
## CICLURI e ușoară — iei nodurile în ordine topologică și, pentru fiecare, ții
## minte cel mai lung drum până la el. Când ajungi la un nod, toți cei care duc
## în el au fost deja socotiți. De-aia verificarea (3) trebuie să treacă înainte.
func _trasee(plansa: Dictionary, topologic: Array) -> void:
	var start := String(plansa["start"])
	var boss := String(plansa["boss"])

	# Cel mai SCURT: parcurgere în lățime, cu părinți.
	var parinte_scurt := {start: ""}
	var coada: Array[String] = [start]
	var i := 0
	while i < coada.size():
		var aici := coada[i]
		i += 1
		for spre in plansa["spre"][aici]:
			if not parinte_scurt.has(spre):
				parinte_scurt[spre] = aici
				coada.append(String(spre))
	print("    cel mai scurt: %s" % _drum_ca_text(parinte_scurt, start, boss))

	if topologic.is_empty():
		print("    cel mai lung:  nu se poate socoti (harta are cicluri)")
		return

	# Cel mai LUNG: programare dinamică pe ordinea topologică.
	var lung := {start: 0}
	var parinte_lung := {start: ""}
	for aici in topologic:
		if not lung.has(aici):
			continue   # nod în care nu se ajunge din Start
		for spre in plansa["spre"][aici]:
			var candidat := int(lung[aici]) + 1
			if not lung.has(spre) or candidat > int(lung[spre]):
				lung[spre] = candidat
				parinte_lung[spre] = aici
	print("    cel mai lung:  %s" % _drum_ca_text(parinte_lung, start, boss))


func _drum_ca_text(parinti: Dictionary, start: String, boss: String) -> String:
	if not parinti.has(boss):
		return "nu există (la Boss nu se ajunge)"
	var invers: Array[String] = []
	var aici := boss
	while aici != "":
		invers.append(aici)
		if aici == start:
			break
		aici = String(parinti[aici])
	invers.reverse()
	return "%s   (%d noduri)" % [" → ".join(invers), invers.size()]


# ─────────────────────────────────────────────────────────────
# TIPURILE, PE MULTE SEMINȚE
#
# Forma hărții e fixă; conținutul nu. Deci întrebarea aici nu e „arată bine?”,
# ci „regulile care trag tipurile din sămânță mai țin pe forma asta?”.
#
# Cheamă `Expeditie.genereaza_harta(sămânță, cale)` — exact funcția jocului, cu
# exact planșa asta.
# ─────────────────────────────────────────────────────────────

func _tipuri_pe_seminte(cale: String, plansa: Dictionary) -> bool:
	var fara_boss_la_capat := 0
	var fara_magazin := 0
	var start_nelupta := 0
	var noduri_lipsa := 0
	var cate_de_tip := {}

	for tip in Expeditie.DATE_NOD:
		cate_de_tip[tip] = 0

	for i in range(SEMINTE):
		var harta := Expeditie.genereaza_harta(1000 + i, cale)
		if harta.size() != plansa["ordine"].size():
			noduri_lipsa += 1
		if harta.is_empty():
			continue
		if int(harta[harta.size() - 1]["tip"]) != Expeditie.Nod.BOSS:
			fara_boss_la_capat += 1
		if int(harta[0]["tip"]) != Expeditie.Nod.LUPTA:
			start_nelupta += 1
		var are_magazin := false
		for nod in harta:
			cate_de_tip[int(nod["tip"])] = int(cate_de_tip[int(nod["tip"])]) + 1
			if int(nod["tip"]) == Expeditie.Nod.MAGAZIN:
				are_magazin = true
		if not are_magazin:
			fara_magazin += 1

	var bun := true
	bun = _verdict("toate nodurile ajung în hartă", noduri_lipsa == 0,
		"" if noduri_lipsa == 0 else "%d hărți cu noduri sărite" % noduri_lipsa) and bun
	bun = _verdict("Bossul, pe ultimul nod", fara_boss_la_capat == 0,
		"" if fara_boss_la_capat == 0 else "%d hărți" % fara_boss_la_capat) and bun
	bun = _verdict("Startul, mereu o Luptă obișnuită", start_nelupta == 0,
		"" if start_nelupta == 0 else "%d hărți" % start_nelupta) and bun
	bun = _verdict("Magazinul, prezent", fara_magazin == 0,
		"" if fara_magazin == 0 else "%d hărți" % fara_magazin) and bun

	# Cum se împart tipurile, ca informație: o planșă pe care ies numai Lupte e
	# o planșă plictisitoare, chiar dacă trece toate verificările.
	var total := 0
	for tip in cate_de_tip:
		total += int(cate_de_tip[tip])
	var bucati: Array[String] = []
	for tip in cate_de_tip:
		bucati.append("%s %.1f%%" % [
			Expeditie.DATE_NOD[tip]["nume"],
			100.0 * float(cate_de_tip[tip]) / float(maxi(total, 1))])
	print("    %-44s %s" % ["(i) cum se împart tipurile", ", ".join(bucati)])

	return bun


# ─────────────────────────────────────────────────────────────

## Zona utilă, pentru fereastra implicită.
##
## Copiată din `_zona_utila()` a hărții, fiindcă aia întreabă `get_viewport_rect()`
## și poziția pânzei — lucruri care există doar când jocul rulează. Se copiază
## doar traducerea „fracțiuni de ecran → pixeli”.
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

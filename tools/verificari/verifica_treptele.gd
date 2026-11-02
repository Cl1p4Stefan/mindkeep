extends Node
## VERIFICAREA TREPTELOR — două trepte la rând nu sunt din același tip.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_treptele.tscn
##
## ─────────────────────────────────────────────────────────────
## CE BATE, ȘI DE CE NU PUTEA STA ÎN NICIUNA DIN CELELALTE
##
## Regula trăiește în `puzzle.gd`, în secțiunea „FĂRĂ DOUĂ TREPTE DIN ACELAȘI
## TIP": la un Obelisc, tipul servit la o treaptă se trimite la coada tragerii
## la treapta următoare. Deci e o regulă a BAZEI, nu a vreunei discipline — iar
## una a bazei se bate o dată, pentru toate opt, exact ca expunerea din
## `verifica_retinere`.
##
## Mai e și ceva ce celelalte opt verificări nu POT vedea, oricât ar crește: ele
## cheamă `_compune_intrebare` de-a dreptul, de mii de ori, fiindcă așa se
## măsoară echilibrul fără fereastră. Numai că memoria tipului se scrie în
## `porneste()` — adică pe drumul pe care umblă LUPTA, nu ele. Pentru ele regula
## nici nu există: `tip_de_ocolit()` le întoarce mereu „", iar tragerea lor e cea
## curată. Ăsta e un noroc (echilibrul pe care-l măsoară rămâne cel al tabelului,
## nu cel al regulii), dar înseamnă că ele nu pot da niciun verdict despre ea.
##
## ─────────────────────────────────────────────────────────────
## TREI FELURI DE PROBĂ, PENTRU TREI LUCRURI DIFERITE
##
##   1. REGULA, pe loc — `tipuri_amestecate` e o funcție cu patru rânduri de
##      cod și patru feluri de a fi greșită. Se bate direct, fără nimic în jur.
##   2. ȘIRUL SIMULAT — un lanț de 20.000 de trepte, jucat numai pe regulă.
##      Aici se vede singurul lucru care nu se vede nicăieri altundeva: că a nu
##      repeta NU ÎNCLINĂ echilibrul. Măsurat, nu dedus: e tocmai genul de
##      afirmație care sună evident și se poate strica dintr-o linie.
##   3. LANȚUL JUCAT CU SCENELE ADEVĂRATE — toate cele opt discipline, prin
##      `porneste()`, treaptă după treaptă, pe nivel fix. Asta e proba că cele
##      două jumătăți se leagă: disciplina scrie câmpul `tip`, baza îl ține
##      minte, iar întrebarea următoare îl ocolește. Oricare jumătate lipsită,
##      secțiunile 1 și 2 ar trece la fel de frumos.
##
## PE NIVEL FIX, și nu pe niveluri amestecate: ce tipuri sunt disponibile se
## schimbă cu nivelul, iar un lanț care sare între ele n-ar mai putea deosebi „a
## repetat" de „n-a avut din ce alege". Cu nivelul ținut pe loc, cele două
## verdicte se despart curat: „au apărut cel puțin două tipuri" spune că a FOST
## din ce alege, „nicio pereche lipită" spune că s-a și ales.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## **Dacă se SIMTE.** Că un lanț cu tipuri împrăștiate e mai bun decât unul cu
## perechi lipite e o decizie de design, scrisă în `puzzle.gd` cu motivul ei
## (a doua întrebare din același tip o prinzi cu metoda deja încălzită). Nu e un
## verdict, și nicio verificare nu poate s-o facă să fie.
##
## **Repetarea la DISTANȚĂ.** Regula ține minte o treaptă, nu trei. Un lanț de
## forma A-B-A-B-A e permis și nu e o scăpare: altceva ar fi cerut un istoric,
## iar un istoric ar fi început să refuze tipuri — adică exact interdicția de
## care secțiunea din `puzzle.gd` se ferește.

const PUZZLE := preload("res://scenes/puzzle/puzzle.gd")

# Secțiunea 1: de câte ori se trage, ca „ultimul" să nu fie noroc.
const TRAGERI_REGULA := 2000

# Secțiunea 2: cât ține lanțul simulat, și cât poate să se abată un tip.
# 20.000 de pași peste 4 tipuri dau ~5000 fiecare; 5% e larg pentru zgomot și
# strâns pentru o înclinare adevărată (a repeta jumătate din trepte s-ar vedea
# ca o abatere de 50%).
const PASI_SIMULATI := 20000
const TOLERANTA_ECHILIBRU := 0.05

# Secțiunea 3: câte trepte se joacă din fiecare disciplină, la fiecare nivel.
# 20 e destul: o pereche lipită apare, fără regulă, cam o dată la patru trepte
# (cu patru tipuri), deci 20 de trepte × 3 niveluri × 8 discipline ar fi arătat
# vreo 120 de perechi. Ce se bate aici e CONTACTUL dintre părți, nu statistica —
# aia e la secțiunea 2, unde o treaptă costă microsecunde, nu o scenă.
const TREPTE_PE_NIVEL := 20

# Patru nume de probă pentru secțiunile fără scene. Nu sunt tipuri adevărate
# dinadins: regula nu știe nimic despre ce înseamnă un tip, iar o probă scrisă
# cu „CONDITIONAL" și „INTRUS" ar fi sugerat că știe.
const TIPURI_DE_PROBA := ["A", "B", "C", "D"]

var tot_bun := true


func _ready() -> void:
	print("\n══ VERIFICAREA TREPTELOR ══\n")

	tot_bun = _regula() and tot_bun
	tot_bun = _sirul_simulat() and tot_bun
	tot_bun = await _lanturile_jucate() and tot_bun

	print("\n══ %s ══\n" % ("TOTUL E BUN" if tot_bun else "SUNT PROBLEME, vezi mai sus"))
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. REGULA
#
# `tipuri_amestecate(tipuri, de_ocolit)` e tot ce stă între o disciplină și
# regula asta. Patru rânduri de cod, și fiecare verdict de mai jos ține unul.
# ─────────────────────────────────────────────────────────────

func _regula() -> bool:
	print("  REGULA")
	var rezultat := true

	# a) Cel de ocolit ajunge ultimul. De fiecare dată, nu de obicei.
	var nu_la_coada := 0
	var pierdute := 0
	for _tragere in range(TRAGERI_REGULA):
		var de_ocolit: String = TIPURI_DE_PROBA.pick_random()
		var ordine := PUZZLE.tipuri_amestecate(TIPURI_DE_PROBA, de_ocolit)
		if String(ordine[ordine.size() - 1]) != de_ocolit:
			nu_la_coada += 1
		# ...și nimic nu se pierde pe drum. O regulă care SCOATE un tip în loc
		# să-l amâne ar trece verdictul de deasupra fără să clipească.
		if ordine.size() != TIPURI_DE_PROBA.size():
			pierdute += 1
		else:
			for tip in TIPURI_DE_PROBA:
				if not ordine.has(tip):
					pierdute += 1
					break

	rezultat = _verdict(
		"tipul de ocolit ajunge mereu ULTIMUL", nu_la_coada == 0,
		"%d din %d nu" % [nu_la_coada, TRAGERI_REGULA]
	) and rezultat
	rezultat = _verdict(
		"se amana, nu se scoate: lista rămâne întreagă", pierdute == 0,
		"%d stricate" % pierdute
	) and rezultat

	# b) Lista primită nu se atinge. Disciplinele trec `pe_tip.keys()`, iar o
	# funcție care amestecă pe loc ar amesteca cheile unui dicționar viu.
	var lista: Array = TIPURI_DE_PROBA.duplicate()
	var inainte: Array = lista.duplicate()
	for _tragere in range(50):
		PUZZLE.tipuri_amestecate(lista, "B")
	rezultat = _verdict(
		"lista primită rămâne neatinsă", lista == inainte, str(lista)
	) and rezultat

	# c) UN SINGUR TIP: rămâne primul, chiar dacă e chiar el cel de ocolit. Ăsta
	# e verdictul care spune că regula amână și nu interzice — fără el, o
	# disciplină cu un singur tip la un nivel ar rămâne fără întrebare.
	var singur := PUZZLE.tipuri_amestecate(["A"], "A")
	rezultat = _verdict(
		"cu un singur tip, el rămâne primul",
		singur.size() == 1 and String(singur[0]) == "A", str(singur)
	) and rezultat

	# d) Fără nimic de ocolit, tragerea e curată: fiecare tip ajunge primul cam
	# la fel de des. Așa arată prima treaptă a fiecărui lanț.
	var primul_fara := {}
	for _tragere in range(TRAGERI_REGULA):
		var ordine := PUZZLE.tipuri_amestecate(TIPURI_DE_PROBA, "")
		var tip := String(ordine[0])
		primul_fara[tip] = int(primul_fara.get(tip, 0)) + 1
	rezultat = _verdict(
		"fara nimic de ocolit, toate patru ajung primele",
		primul_fara.size() == TIPURI_DE_PROBA.size(), str(primul_fara.keys())
	) and rezultat

	# e) Un tip de ocolit care nu e în listă nu strică nimic. Se întâmplă chiar
	# în joc: la Tipare nivelul trecut putea avea un tip pe care ăsta nu-l are.
	var strain := PUZZLE.tipuri_amestecate(TIPURI_DE_PROBA, "Z")
	rezultat = _verdict(
		"un tip de ocolit care nu e în listă nu strică nimic",
		strain.size() == TIPURI_DE_PROBA.size(), str(strain)
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 2. ȘIRUL SIMULAT
#
# Un lanț lung, jucat numai pe regulă: la fiecare pas se ia primul tip din
# ordine, iar el devine „de ocolit" la pasul următor — exact ce face `porneste`
# cu tipul servit.
#
# AICI SE MĂSOARĂ CE NU SE VEDE ALTUNDEVA: că regula nu înclină echilibrul.
# Lanțul e un drum care sare mereu la altceva decât unde e, iar la capătul lui
# fiecare tip trebuie să fi fost vizitat cam la fel de des. Sună evident; se
# strică dintr-o singură linie (un tip mutat la coadă care rămâne acolo, o
# ordine care nu se mai amestecă), și atunci o disciplină cu patru tipuri ar
# ajunge să joace trei.
# ─────────────────────────────────────────────────────────────

func _sirul_simulat() -> bool:
	print("  SIRUL SIMULAT (%d pasi)" % PASI_SIMULATI)
	var rezultat := true

	var de_ocolit := ""
	var lipite := 0
	var pe_tip := {}
	for _pas in range(PASI_SIMULATI):
		var ales := String(PUZZLE.tipuri_amestecate(TIPURI_DE_PROBA, de_ocolit)[0])
		if ales == de_ocolit:
			lipite += 1
		pe_tip[ales] = int(pe_tip.get(ales, 0)) + 1
		de_ocolit = ales

	rezultat = _verdict(
		"nicio pereche de trepte lipită", lipite == 0, "%d lipite" % lipite
	) and rezultat

	var asteptat := float(PASI_SIMULATI) / float(TIPURI_DE_PROBA.size())
	var strambe: Array[String] = []
	for tip in pe_tip:
		var abatere: float = absf(float(pe_tip[tip]) - asteptat) / asteptat
		if abatere > TOLERANTA_ECHILIBRU:
			strambe.append("%s %d (%.0f%%)" % [tip, pe_tip[tip], abatere * 100.0])
	rezultat = _verdict(
		"a nu repeta nu înclină echilibrul", strambe.is_empty(),
		_primele(strambe, 4)
	) and rezultat

	# DOUĂ TIPURI: lanțul alternează strict. Nu e un caz de colț, e chiar
	# capătul la care regula devine o constrângere tare — și cel în care o
	# greșeală de semn s-ar vedea cel mai limpede.
	var doua := ["A", "B"]
	var ultim := ""
	var lipite_doua := 0
	for _pas in range(1000):
		var ales := String(PUZZLE.tipuri_amestecate(doua, ultim)[0])
		if ales == ultim:
			lipite_doua += 1
		ultim = ales
	rezultat = _verdict(
		"cu două tipuri, lanțul alternează strict", lipite_doua == 0,
		"%d lipite" % lipite_doua
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 3. LANȚUL JUCAT CU SCENELE ADEVĂRATE
#
# Toate disciplinele din `Discipline.CATALOG`, pe rând: scena adevărată,
# `porneste()` la fiecare treaptă, și întrebarea „ce tip s-a servit?" pusă chiar
# bazei, prin `tip_de_ocolit()` — adică exact valoarea pe care o va citi treapta
# următoare.
#
# DIN CATALOG, ȘI NU DINTR-O LISTĂ SCRISĂ AICI: așa a noua disciplină intră în
# verificarea asta fără ca nimeni să-și amintească s-o adauge — iar dacă uită
# să scrie câmpul `tip`, primul verdict o spune pe nume.
#
# SCENELE SE ÎNCHID ÎNTRE TREPTE, ca în luptă (`creeaza_puzzle` /
# `inchide_puzzle` la fiecare întrebare). Nu e o economie, e chiar proba: dacă
# memoria tipului ar fi fost o variabilă de instanță, ea s-ar naște goală la
# fiecare treaptă și regula n-ar exista — iar singurul loc în care asta se vede
# e aici, cu scenele deschise și închise una după alta.
# ─────────────────────────────────────────────────────────────

func _lanturile_jucate() -> bool:
	print("  LANTURILE JUCATE CU SCENELE ADEVARATE (%d trepte x 3 niveluri)"
		% TREPTE_PE_NIVEL)
	var rezultat := true

	var fara_tip: Array[String] = []
	var lipite: Array[String] = []
	var fara_alegere: Array[String] = []
	var masuratori: Array[String] = []

	for date in Discipline.CATALOG:
		var nume := String(date["nume"])
		var scena: PackedScene = date["scena"]
		var tipuri_vazute := {}

		for nivel in [1, 2, 3]:
			var sirul: Array[String] = []
			for treapta in range(TREPTE_PE_NIVEL):
				var puzzle: Puzzle = scena.instantiate()
				add_child(puzzle)
				puzzle.porneste(nivel)
				# `tip_de_ocolit()` e tipul pe care `porneste` tocmai l-a scris:
				# întrebăm baza ce a servit, nu generatorul ce a compus.
				sirul.append(puzzle.tip_de_ocolit())
				remove_child(puzzle)
				puzzle.free()
				# Un cadru între trepte: scena a avut tween-uri și un ceas, iar
				# `_exit_tree` are de stins ticăitul.
				await get_tree().process_frame

			for i in range(sirul.size()):
				if sirul[i] == "":
					fara_tip.append("%s nivelul %d" % [nume, nivel])
					break
				tipuri_vazute[sirul[i]] = true
				if i > 0 and sirul[i] == sirul[i - 1]:
					lipite.append("%s nivelul %d: %s de două ori" % [
						nume, nivel, sirul[i],
					])

			# A FOST din ce alege? Fără verdictul ăsta, o disciplină care la un
			# nivel are un singur tip ar „trece" fără să fi fost pusă la probă.
			var deosebite := {}
			for tip in sirul:
				deosebite[tip] = true
			if deosebite.size() < 2:
				fara_alegere.append("%s nivelul %d: %d tip(uri)" % [
					nume, nivel, deosebite.size(),
				])

		masuratori.append("%-12s %d tipuri" % [nume, tipuri_vazute.size()])

	rezultat = _verdict(
		"fiecare întrebare poartă un tip", fara_tip.is_empty(),
		_primele(fara_tip, 4)
	) and rezultat
	rezultat = _verdict(
		"nicio pereche de trepte lipită", lipite.is_empty(),
		_primele(lipite, 4)
	) and rezultat
	rezultat = _verdict(
		"la fiecare nivel a fost din ce alege", fara_alegere.is_empty(),
		_primele(fara_alegere, 4)
	) and rezultat

	# FIECARE DISCIPLINĂ CU REGISTRUL EI. Dacă memoria ar fi fost un singur șir
	# în loc de un dicționar pe etichetă, ar fi rămas o intrare, iar o întrebare
	# de Logică ar fi ocolit un tip de la Numere — un tip care la ea nici nu
	# există, deci o regulă care nu face nimic, fără niciun semn.
	rezultat = _verdict(
		"fiecare disciplină cu registrul ei",
		PUZZLE.tip_servit.size() == Discipline.CATALOG.size(),
		"%d registre pentru %d discipline: %s" % [
			PUZZLE.tip_servit.size(), Discipline.CATALOG.size(),
			", ".join(PUZZLE.tip_servit.keys()),
		]
	) and rezultat

	print("")
	print("  CATE TIPURI S-AU VAZUT (nu e verdict, e masuratoare)")
	for rand in masuratori:
		print("    %s" % rand)

	print("")
	return rezultat


func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-50s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array, cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(String(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

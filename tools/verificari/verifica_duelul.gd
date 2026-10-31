extends Node
## VERIFICAREA DUELULUI — bucla de luptă, jucată cap-coadă.
##
## `godot --headless --path . res://tools/verificari/verifica_duelul.tscn`
##
## Sesiunea de dinainte a notat că „ar merita o verificare permanentă,
## `verifica_duelul`" și n-a scris-o fiindcă jumătate din buclă (parada) lipsea.
## Acum nu mai lipsește, deci iată-o. Bate cele patru reguli ale DUELULUI:
##
##   1. lanțul tău se oprește la `PLAFON_TREPTE` și face 15 daune
##   2. folosirea blochează Obeliscul o rundă
##   3. inamicul lovește → PARADĂ; corect = zero daune, greșit = daune + unealta
##   4. blocarea NU e cumulativă, deci blocarea totală e imposibilă
##
## și, în plus, că rundele de ÎNCĂRCARE ale Grabnicului rămân liniștite — regula
## pentru care parada stă în `_ataca_jucatorul()` și nu în `tura_inamicului()`.
##
## ─── CUM JOACĂ ─────────────────────────────────────────────────
## Cu scenele adevărate, nu cu o simulare: aceeași `lupta.tscn`, aceleași scene
## de Trivia și Logică, aceleași întrebări din JSON. Se răspunde chemând
## `_pe_varianta_aleasa()` cu indicele bun (sau cu alt indice, pentru greșit) —
## adică exact pe unde intră un click. `Engine.time_scale` urcă, deci pauzele de
## suspans și animațiile trec repede, fără să fie sărite.
##
## ─── CE NU BATE ────────────────────────────────────────────────
## Nimic din ce se VEDE. Dacă marcajul „PARADA!" se desenează peste cronometru
## sau întrebarea de paradă arată ca orice altă întrebare, verificarea asta
## spune „OK" — ca `verifica_steaguri`, aia se judecă cu ochiul, în F6.

const SAMANTA := 4242          # aceeași ca la `verifica_retragerea`: primul nod e SOLDATUL
const VITEZA := 20.0           # de câte ori mai repede curg pauzele și animațiile
const SCENA_LUPTA := "res://scenes/lupta/lupta.tscn"

## Cât așteptăm, în cadre, o întrebare sau o schimbare de stare. Generos:
## la `VITEZA` ori mai repede, un lanț întreg trece în câteva zeci de cadre.
const CADRE_ASTEPTARE := 1200

var tot_bun := true


func _ready() -> void:
	print("VERIFICAREA DUELULUI (lantul, blocarea, parada)")
	Engine.time_scale = VITEZA
	_drumul.call_deferred()


func _drumul() -> void:
	# Jocul citește regula din constantă. Dacă comutatorul e pe COMBO,
	# verificarea asta n-are ce verifica — și e mai cinstit s-o spună decât să
	# picheze 20 de verdicte.
	var lupta_mostra := load(SCENA_LUPTA)
	var regula: int = lupta_mostra.instantiate().REGULA_OBELISC
	if regula != 2:   # RegulaObelisc.DUEL
		print("\n  Comutatorul `REGULA_OBELISC` NU e pe DUEL — nimic de verificat.")
		print("  (Nu e o picare: pune-l pe DUEL si reia.)")
		get_tree().quit(0)
		return

	Tezaur.goleste()
	Sac.goleste_tot()
	var discipline: Array[String] = ["memorie", "logica", "cuvinte"]
	Expeditie.incepe(discipline, SAMANTA)
	Expeditie.intra_in_nod(Expeditie.accesibile()[0])

	var lupta := await _schimba_in(SCENA_LUPTA)
	if lupta == null:
		_verdict("lupta pornește", false)
		_incheie()
		return
	_verdict("primul nod e SOLDATUL (Atac constant)", lupta.nume_inamic() == "SOLDATUL",
		lupta.nume_inamic())

	await _proba_lantul(lupta)
	await _proba_parada_reusita(lupta)
	await _proba_parada_ratata(lupta)
	await _proba_grabnicul_liniste(lupta)
	await _proba_fara_cumul(lupta)
	_proba_blocarea_totala(lupta)

	_incheie()


# ─────────────────────────────────────────────────────────────
# PROBELE
# ─────────────────────────────────────────────────────────────

## 1. UN LANȚ. Cinci trepte, 15 daune (1+2+3+3+6, treapta a 5-a critică), apoi
## tura se încheie singură și Obeliscul folosit e blocat în runda următoare.
func _proba_lantul(lupta: Node) -> void:
	print("\n  1. LANTUL TAU")
	await _reporneste(lupta)

	var pv_start: int = lupta.pv_inamic
	lupta._pe_obelisc_apasat(0)
	var cate := await _raspunde_la(lupta, [], lupta.PLAFON_TREPTE)

	_verdict("lanțul se oprește la plafon", cate == lupta.PLAFON_TREPTE,
		"%d trepte (plafon %d)" % [cate, lupta.PLAFON_TREPTE])
	_verdict("un lanț complet = 15 daune", pv_start - lupta.pv_inamic == 15,
		"%d daune" % [pv_start - lupta.pv_inamic])
	_verdict("Obeliscul folosit se blochează",
		lupta.disponibil_din[0] == 1 + 1 + lupta.RUNDE_BLOCAT_DUEL,
		"liber din runda %d" % lupta.disponibil_din[0])
	_verdict("celelalte două rămân libere",
		lupta.disponibil_din[1] == 0 and lupta.disponibil_din[2] == 0)

	# Tura se încheie SINGURĂ după lanț — nu există un buton de apăsat. Dar
	# „se încheie" nu mai înseamnă „runda crește pe loc": între tura ta și runda
	# următoare stă acum tura inamicului, iar ea conține o întrebare.
	var puzzle := await _asteapta_intrebare(lupta)
	_verdict("tura ta se încheie într-o paradă", puzzle != null
		and _cate_in_jurnal(lupta, "parada prin") == 1)
	if puzzle == null:
		return
	_verdict("runda NU a crescut cât parada e pe ecran", lupta.runda == 1,
		"runda %d" % lupta.runda)
	_raspunde(puzzle, true)

	var a_trecut := await _asteapta(lupta, func(): return lupta.runda == 2)
	_verdict("după paradă, runda 2", a_trecut, "runda %d" % lupta.runda)
	_verdict("Obeliscul folosit e încă blocat în runda 2", lupta.e_blocat(0))
	_verdict("celelalte două se pot apăsa", not lupta.e_blocat(1) and not lupta.e_blocat(2))


## 2. PARADA, PARATĂ. Joc perfect vs. SOLDATUL: 11 întrebări (5 + 1 paradă + 5),
## două runde, regele neatins. Cifra din design — și, mai important, înțelesul
## ei: zero daune devine CÂȘTIGAT, nu primit cadou pentru că inamicul n-a apucat
## să se miște.
func _proba_parada_reusita(lupta: Node) -> void:
	print("\n  2. PARADA, PARATA (joc perfect vs. SOLDATUL)")
	await _reporneste(lupta)
	var pv_start: int = lupta.pv_jucator

	var cate := await _joaca(lupta, [])

	_verdict("lupta s-a terminat", lupta.lupta_terminata)
	_verdict("inamicul a căzut", lupta.pv_inamic == 0, "%d PV" % lupta.pv_inamic)
	_verdict("11 întrebări (5 + parada + 5)", cate == 11, "%d intrebari" % cate)
	_verdict("o singură paradă", _cate_in_jurnal(lupta, "parada prin") == 1,
		"%d parade" % _cate_in_jurnal(lupta, "parada prin"))
	_verdict("parada a ținut", _cate_in_jurnal(lupta, "PARAT!") == 1)
	_verdict("regele e neatins", lupta.pv_jucator == pv_start,
		"%d/%d PV" % [lupta.pv_jucator, lupta.pv_max_jucator])


## 3. PARADA, RATATĂ. Aceeași luptă, dar la întrebarea de paradă (a 6-a)
## răspundem greșit: încasezi daunele ȘI Obeliscul prin care a lovit se
## blochează o rundă.
func _proba_parada_ratata(lupta: Node) -> void:
	print("\n  3. PARADA, RATATA")
	await _reporneste(lupta)
	var pv_start: int = lupta.pv_jucator
	var daune: int = lupta.daune_inamic()

	# Un lanț întreg, apoi lovitura lui. Ne oprim la parada și răspundem GREȘIT.
	lupta._pe_obelisc_apasat(0)
	var cate := await _raspunde_la(lupta, [], lupta.PLAFON_TREPTE)
	_verdict("lanțul a mers întreg", cate == lupta.PLAFON_TREPTE, "%d trepte" % cate)

	var puzzle := await _asteapta_intrebare(lupta)
	_verdict("vine parada", puzzle != null and _cate_in_jurnal(lupta, "parada prin") == 1)
	if puzzle == null:
		return
	# RUNDA SE CITEȘTE ACUM, nu se presupune: blocarea se scrie cu runda în
	# care cade parada, iar o probă care scrie „1" aici ar trece din noroc.
	var runda_paradei: int = lupta.runda
	_raspunde(puzzle, false)
	await _asteapta(lupta, func(): return lupta.runda > runda_paradei)

	_verdict("parada a căzut", _cate_in_jurnal(lupta, "Parada a cazut") == 1)
	_verdict("încasezi daunele lui", pv_start - lupta.pv_jucator == daune,
		"-%d PV (lovitura lui: %d)" % [pv_start - lupta.pv_jucator, daune])

	# Care Obelisc a fost ținta? `tinta` e aleatoriu, deci nu-l ghicim: ne uităm
	# la ce s-a blocat. Ori unul (ținta a fost chiar Obeliscul folosit), ori
	# două — niciodată trei.
	var blocate: Array[int] = []
	for i in range(lupta.loadout.size()):
		if lupta.disponibil_din[i] > 0:
			blocate.append(i)
	_verdict("se blochează cel mult două Obeliscuri", blocate.size() <= 2,
		"blocate: %s" % str(blocate))
	_verdict("și ținta, și cel folosit — exact o rundă",
		_toate_egale(lupta, blocate, runda_paradei + 1 + lupta.RUNDE_BLOCAT_DUEL),
		"liber din: %s (parada in runda %d)" % [_valorile(lupta, blocate), runda_paradei])
	_verdict("rămâne cel puțin un Obelisc liber",
		_primul_liber(lupta) >= 0, "primul liber: %d" % _primul_liber(lupta))


## 4. GRABNICUL: rundele de ÎNCĂRCARE sunt LINIȘTITE. Două runde în care ceasul
## urcă și nimeni nu te întreabă nimic, a treia o singură întrebare terifiantă.
##
## Asta e proba regulii „parada se declanșează doar când lovește de-adevărat".
## Pusă în `tura_inamicului()`, ceasul Lăncierului și-ar fi pierdut tot rostul:
## ai fi răspuns la o întrebare în fiecare rundă oricum.
func _proba_grabnicul_liniste(lupta: Node) -> void:
	print("\n  4. GRABNICUL — rundele de incarcare sunt liniste")
	await _reporneste(lupta)

	# Îl punem pe Lăncier în arenă de mână. `_alege_inamicul()` merge pe sămânța
	# nodului, iar sămânța care dă un Grabnic la primul nod n-ar fi o cifră de
	# ținut minte — ar fi o cifră de regăsit la fiecare schimbare a hărții.
	var grabnic := -1
	for i in range(lupta.INAMICI.size()):
		if int(lupta.INAMICI[i]["arhetip"]) == lupta.Arhetip.GRABNIC:
			grabnic = i
			break
	if grabnic < 0:
		_verdict("există un Grabnic în tabel", false)
		return
	lupta.inamic_curent = grabnic
	lupta.ceas_inamic = 0
	var pv_start: int = lupta.pv_jucator

	var ceas: int = lupta.ceas_max()
	for runda in range(1, ceas):
		await lupta._tura_grabnic()
		_verdict("runda %d de încărcare: nicio întrebare" % runda,
			_cate_in_jurnal(lupta, "parada prin") == 0 and lupta.pv_jucator == pv_start,
			"ceas %d/%d" % [lupta.ceas_inamic, ceas])

	# A treia: ceasul se umple, deci lovește — deci PARADĂ.
	lupta._tura_grabnic()
	var puzzle := await _asteapta_intrebare(lupta)
	_verdict("la ceasul plin vine o întrebare", puzzle != null)
	if puzzle == null:
		return
	_verdict("și e o paradă", _cate_in_jurnal(lupta, "parada prin") == 1)
	_raspunde(puzzle, true)
	await _asteapta(lupta, func(): return not lupta.puzzle_activ)
	_verdict("parată, deci jumătatea de rege rămâne", lupta.pv_jucator == pv_start,
		"%d PV (lovitura lui: %d)" % [lupta.pv_jucator, lupta.daune_inamic()])


## 5. FĂRĂ CUMUL. `maxi` e acolo ca să nu SCURTEZE un blocaj, nu ca să-l
## lungească. Două probe, pentru cele două direcții:
##   - un Obelisc deja blocat până la `runda + 2` rămâne la `runda + 2`
##   - un Obelisc blocat mai DEPARTE nu e adus mai aproape
func _proba_fara_cumul(lupta: Node) -> void:
	print("\n  5. FARA CUMUL")

	# (a) toate trei blocate exact cât le-ar bloca parada: nimic nu crește.
	await _reporneste(lupta)
	var asteptat: int = lupta.runda + 1 + lupta.RUNDE_BLOCAT_DUEL
	lupta.disponibil_din.fill(asteptat)
	await _o_parada_ratata(lupta)
	_verdict("un blocaj de aceeași lungime nu se lungește",
		_toate_egale(lupta, [0, 1, 2], asteptat),
		"liber din: %s" % _valorile(lupta, [0, 1, 2]))

	# (b) toate trei blocate MAI MULT decât pune parada: nimic nu scade.
	# Starea asta nu se poate naște din regulile de azi — dar `maxi` există
	# exact pentru ziua în care se va putea (un bos care blochează 2 runde),
	# iar o gardă netestată e o gardă pe care o ștergi din greșeală.
	await _reporneste(lupta)
	var departe: int = lupta.runda + 5
	lupta.disponibil_din.fill(departe)
	await _o_parada_ratata(lupta)
	_verdict("un blocaj mai lung nu se scurtează",
		_toate_egale(lupta, [0, 1, 2], departe),
		"liber din: %s" % _valorile(lupta, [0, 1, 2]))


## 6. BLOCAREA TOTALĂ E IMPOSIBILĂ. Aici nu se joacă nicio luptă: se bate
## FORMULA, pe toate drumurile pe care le poate lua o luptă lungă.
##
## Regula întreagă: într-o rundă se scriu cel mult două blocaje (Obeliscul
## folosit + ținta paradei ratate), amândouă cu `runda + 1 + RUNDE_BLOCAT_DUEL`.
## Deci la începutul oricărei runde ai cel puțin un Obelisc liber din trei.
##
## De ce merită o buclă și nu doar demonstrația din comentariu: demonstrația
## ține de o singură cifră (`RUNDE_BLOCAT_DUEL = 1`). Dacă mâine devine 2,
## verdictul de aici pică — și așa trebuie, fiindcă atunci bucla e ruptă.
func _proba_blocarea_totala(lupta: Node) -> void:
	print("\n  6. BLOCAREA TOTALA, pe toate drumurile")

	var n: int = lupta.loadout.size()
	var durata: int = 1 + lupta.RUNDE_BLOCAT_DUEL
	var rng := RandomNumberGenerator.new()
	rng.seed = 1312
	var cea_mai_rea := n          # câte Obeliscuri au fost libere, în cel mai rău caz
	var runde_jucate := 0

	for proba in range(2000):
		var disponibil := [0, 0, 0]
		for runda in range(1, 15):
			# Câte sunt libere ACUM? Asta e tot ce decide dacă bucla ține.
			var libere: Array[int] = []
			for i in range(n):
				if runda >= disponibil[i]:
					libere.append(i)
			cea_mai_rea = mini(cea_mai_rea, libere.size())
			runde_jucate += 1
			if libere.is_empty():
				break   # ar fi o picare; verdictul de jos o prinde
			# Ataci prin unul liber (oricare — îl alegi TU, deci se încearcă
			# toate drumurile), iar inamicul lovește prin oricare din trei.
			var folosit: int = libere[rng.randi_range(0, libere.size() - 1)]
			disponibil[folosit] = runda + durata
			var tinta := rng.randi_range(0, n - 1)
			# Exact linia din `_parada()`, inclusiv `maxi`.
			disponibil[tinta] = maxi(disponibil[tinta], runda + durata)

	_verdict("cu toate drumurile încercate, rămâne mereu un Obelisc liber",
		cea_mai_rea >= 1, "cel mai rau caz: %d libere din %d, in %d runde" % [
			cea_mai_rea, n, runde_jucate
		])


# ─────────────────────────────────────────────────────────────
# CUM SE JOACĂ O LUPTĂ DE AICI
# ─────────────────────────────────────────────────────────────

## O luptă nouă, cu regele întreg. `reseteaza_lupta()` împrumută PV-ul de la
## expediție (așa transformă regulile un șir de lupte într-o expediție), deci
## i-l punem la loc înainte — altfel a doua probă ar porni cu regele ciobit de
## prima.
func _reporneste(lupta: Node) -> void:
	# ÎNTÂI se închide ce e deschis, și asta nu e o curățenie de formă: o probă
	# se poate încheia cu o întrebare de paradă încă pe ecran, iar
	# `reseteaza_lupta()` golește jurnalul și pune runda la 1 fără să OPREASCĂ
	# corutina care așteaptă `puzzle.rezolvat`. Ea se trezește în mijlocul
	# probei următoare și joacă o a doua luptă peste prima — două lanțuri
	# întrețesute, întrebări numărate de două ori, blocări scrise cu runda
	# altei lupte. (Exact asta a picat la prima rulare.)
	await _goleste_ecranul(lupta)
	Expeditie.seteaza_pv(Expeditie.pv_max)
	lupta.reseteaza_lupta()


## Duce la capăt ce a rămas în aer: răspunde corect la orice întrebare de pe
## ecran până nu mai vine niciuna și nimeni nu mai așteaptă nimic.
func _goleste_ecranul(lupta: Node) -> void:
	var liniste := 0
	for cadru in range(CADRE_ASTEPTARE):
		var puzzle := _intrebarea_de_pe_ecran(lupta)
		if puzzle != null:
			_raspunde(puzzle, true)
			liniste = 0
		elif not lupta.puzzle_activ and not lupta.tura_se_incheie:
			# Nimic pe ecran, nu e nici tura inamicului: liniște. Numărăm
			# câteva cadre, fiindcă între două trepte de lanț există o pauză
			# de impact în care ecranul e tot gol.
			liniste += 1
			if liniste > 30:
				return
		else:
			liniste = 0
		await get_tree().process_frame


## Joacă lupta până la verdict: când e o întrebare pe ecran o răspunde, când nu
## e și e rândul tău apasă primul Obelisc liber. Întoarce câte întrebări a
## primit.
##
## `gresite` sunt numerele întrebărilor la care să răspundă GREȘIT (1 = prima).
func _joaca(lupta: Node, gresite: Array, maxim := 40) -> int:
	var numar := 0
	var liniste := 0
	while numar < maxim and not lupta.lupta_terminata:
		await get_tree().process_frame
		var puzzle := _intrebarea_de_pe_ecran(lupta)
		if puzzle != null:
			numar += 1
			_raspunde(puzzle, not gresite.has(numar))
			liniste = 0
			continue
		# E rândul tău? `puzzle_activ` e sus cât e o întrebare pe ecran (a ta
		# sau o paradă), iar `tura_se_incheie` cât ține tura inamicului.
		if not lupta.puzzle_activ and not lupta.tura_se_incheie:
			var liber := _primul_liber(lupta)
			if liber >= 0:
				lupta._pe_obelisc_apasat(liber)
				liniste = 0
				continue
		liniste += 1
		if liniste > CADRE_ASTEPTARE:
			break
	return numar


## Ca `_joaca`, dar fără să apese niciun Obelisc: răspunde doar la întrebările
## care vin de la o activare pornită de apelant, și se oprește după `maxim`.
## Așa se poate prinde starea EXACT după a n-a întrebare.
func _raspunde_la(lupta: Node, gresite: Array, maxim: int) -> int:
	var numar := 0
	while numar < maxim and not lupta.lupta_terminata:
		var puzzle := await _asteapta_intrebare(lupta)
		if puzzle == null:
			break
		numar += 1
		_raspunde(puzzle, not gresite.has(numar))
	# După ultimul răspuns, daunele și blocările se scriu încă câteva cadre
	# (pauza de impact, barele). Le lăsăm să se așeze înainte de verdicte.
	await _asteapta(lupta, func(): return not lupta.puzzle_activ)
	return numar


## O paradă ratată, luată separat de orice luptă: cheamă `_parada()` direct și
## răspunde greșit. Pentru probele în care contează doar ce scrie în
## `disponibil_din`, nu cum s-a ajuns acolo.
func _o_parada_ratata(lupta: Node) -> void:
	lupta._parada(lupta.daune_inamic(), "PROBA")
	var puzzle := await _asteapta_intrebare(lupta)
	if puzzle == null:
		_verdict("parada deschide o întrebare", false)
		return
	_raspunde(puzzle, false)
	await _asteapta(lupta, func(): return not lupta.puzzle_activ)


## Întrebarea de pe ecran, dacă e una gata de răspuns. `null` altfel.
## Trei condiții, toate necesare: scena există, s-a așezat în arbore
## (`indice_corect` se scrie în `porneste()`) și n-a primit deja un răspuns.
func _intrebarea_de_pe_ecran(lupta: Node) -> Node:
	if lupta.zona_puzzle.get_child_count() == 0:
		return null
	var puzzle: Node = lupta.zona_puzzle.get_child(0)
	if not puzzle.is_node_ready() or puzzle.indice_corect < 0 or puzzle.raspuns_dat:
		return null
	return puzzle


func _asteapta_intrebare(lupta: Node) -> Node:
	for i in range(CADRE_ASTEPTARE):
		await get_tree().process_frame
		var puzzle := _intrebarea_de_pe_ecran(lupta)
		if puzzle != null:
			return puzzle
	return null


## Răspunde, pe unde intră un click: `_pe_varianta_aleasa()`. Pentru greșit,
## oricare alt buton — scena compară indicele cu `indice_corect`, deci „alt
## indice" ESTE un răspuns greșit, fără să ne uităm la textele variantelor.
func _raspunde(puzzle: Node, corect: bool) -> void:
	var index: int = puzzle.indice_corect
	if not corect:
		index = (index + 1) % puzzle.butoane.size()
	puzzle._pe_varianta_aleasa(index)


func _primul_liber(lupta: Node) -> int:
	for i in range(lupta.loadout.size()):
		if not lupta.e_blocat(i):
			return i
	return -1


## Așteaptă până condiția e adevărată. `false` dacă n-a devenit.
func _asteapta(lupta: Node, conditie: Callable) -> bool:
	for i in range(CADRE_ASTEPTARE):
		if conditie.call():
			return true
		await get_tree().process_frame
	return conditie.call()


# ─────────────────────────────────────────────────────────────
# UNELTE
# ─────────────────────────────────────────────────────────────

## Câte linii din jurnalul luptei cuprind textul dat. Jurnalul e martorul cel
## mai bun pentru „ce s-a întâmplat": e scris de luptă, pentru jucător, deci
## dacă o linie lipsește de aici lipsește și de pe ecranul lui.
func _cate_in_jurnal(lupta: Node, bucata: String) -> int:
	var cate := 0
	for linie in lupta.jurnal:
		if String(linie).contains(bucata):
			cate += 1
	return cate


func _toate_egale(lupta: Node, indici: Array, valoare: int) -> bool:
	for i in indici:
		if lupta.disponibil_din[int(i)] != valoare:
			return false
	return true


func _valorile(lupta: Node, indici: Array) -> String:
	var bucati: Array[String] = []
	for i in indici:
		bucati.append(str(lupta.disponibil_din[int(i)]))
	return ", ".join(bucati)


func _verdict(eticheta: String, bun: bool, amanunt := "") -> void:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-48s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	if not bun:
		tot_bun = false


func _incheie() -> void:
	Engine.time_scale = 1.0
	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"duelul se joaca dupa reguli" if tot_bun else "O REGULA A DUELULUI NU TINE"])
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# SCENELE
# ─────────────────────────────────────────────────────────────

## Pune scena ca `current_scene`, ca jocul. Prima mișcare e o scenă-paravan:
## schimbarea ELIBEREAZĂ scena curentă, care pornită din linia de comandă e
## chiar verificarea asta. (Același truc ca în `verifica_retragerea`.)
func _schimba_in(cale: String) -> Node:
	if get_tree().current_scene == self:
		var paravan := Node.new()
		get_tree().root.add_child(paravan)
		get_tree().current_scene = paravan
	get_tree().change_scene_to_file(cale)
	for i in range(60):
		await get_tree().process_frame
		var scena := get_tree().current_scene
		if scena != null and scena.scene_file_path == cale and scena.is_node_ready():
			return scena
	return null

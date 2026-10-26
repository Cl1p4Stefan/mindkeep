extends Node
## VERIFICAREA RETRAGERII — ieșirile din mijlocul expediției.
##
## `godot --headless --path . res://tools/verificari/verifica_retragerea.tscn`
##
## Joacă, cu scenele adevărate, drumul pe care butoanele noi îl deschid:
##
##   luptă → „HARTA" → hartă (nodul te așteaptă) → clic pe piesă → aceeași luptă
##   → victorie → hartă (drumurile s-au redeschis) → „Meniu" → meniu
##
## și se uită la fiecare pas la ce contează: PV-ul pierdut rămâne pierdut, nodul
## rămâne nerezolvat (și pe disc), harta nu te lasă să fugi pe alt nod, nodul nu
## intră de două ori în `parcurse`, iar ieșirea spre meniu nu golește o
## expediție vie.
##
## Scrie DOAR în `user://verificare_retragere/`, ca `verifica_salvarea`: o
## verificare care poate suprascrie save-ul adevărat e o verificare pe care n-o
## rulezi niciodată.
##
## ─── CUM SUPRAVIEȚUIEȘTE SCHIMBĂRILOR DE SCENĂ ─────────────────
## Butoanele schimbă scena (`change_scene_to_file`), iar schimbarea ELIBEREAZĂ
## scena curentă — care, pornită cu linia de comandă, e chiar verificarea asta.
## Deci prima mișcare e o scenă-paravan: un nod gol pus ca `current_scene`.
## Schimbarea îl eliberează pe el, iar verificarea rămâne în arbore și se uită.

const DOSAR := "user://verificare_retragere/"
const SAMANTA := 4242
## Cât PV „pierde" regele în lupta din care se retrage.
const PV_PIERDUT := 7

const SCENA_LUPTA := "res://scenes/lupta/lupta.tscn"
const SCENA_HARTA := "res://scenes/harta/harta.tscn"
const SCENA_MENIU := "res://scenes/meniu/meniu.tscn"


func _ready() -> void:
	print("VERIFICAREA RETRAGERII (lupta → harta → lupta → meniu)")
	print("Dosar de probă: %s" % DOSAR)

	Arhiva.dosar = DOSAR
	_goleste_dosarul()

	# `_ready` nu poate aștepta cadre fără să întârzie restul arborelui; drumul
	# merge într-o funcție a lui, chemată după ce arborele s-a așezat.
	_drumul.call_deferred()


func _drumul() -> void:
	var tot_bun := true

	# ── 0. o expediție, intrată într-o luptă ────────────────────
	Tezaur.goleste()
	Sac.goleste_tot()
	var discipline: Array[String] = ["memorie", "logica"]
	Expeditie.incepe(discipline, SAMANTA)
	var id := Expeditie.accesibile()[0]
	var tip := int(Expeditie.harta[id]["tip"])
	tot_bun = _verdict("primul nod e o luptă", tip == Expeditie.Nod.LUPTA,
		"tip %d" % tip) and tot_bun
	Expeditie.intra_in_nod(id)
	Arhiva.salveaza_tot()
	var pv_intrare := Expeditie.pv

	# ── 1. în luptă ─────────────────────────────────────────────
	print("\n  1. ÎN LUPTĂ")
	var lupta := await _schimba_in(SCENA_LUPTA)
	tot_bun = _verdict("butonul HARTA se vede", lupta.buton_harta.visible) and tot_bun
	tot_bun = _verdict("butonul HARTA e aprins", not lupta.buton_harta.disabled) and tot_bun

	lupta.puzzle_activ = true
	tot_bun = _verdict("cu o întrebare pe ecran nu te retragi",
		not lupta._se_poate_retrage()) and tot_bun
	lupta.puzzle_activ = false
	lupta.tura_se_incheie = true
	tot_bun = _verdict("în pauza dinaintea inamicului nu te retragi",
		not lupta._se_poate_retrage()) and tot_bun
	lupta.tura_se_incheie = false

	lupta._pe_harta_apasat()
	tot_bun = _verdict("întâi se întreabă", lupta.confirma_retragerea.visible) and tot_bun
	lupta.confirma_retragerea.hide()

	# Regele a pierdut ceva PV în lupta asta; apoi se retrage.
	lupta.pv_jucator = pv_intrare - PV_PIERDUT
	lupta._pe_retragere_confirmata()

	# ── 2. pe hartă, după retragere ─────────────────────────────
	print("\n  2. PE HARTĂ, DUPĂ RETRAGERE")
	var harta := await _asteapta_scena(SCENA_HARTA)
	tot_bun = _verdict("retragerea duce pe hartă", harta != null) and tot_bun
	if harta == null:
		_incheie(false)
		return

	tot_bun = _verdict("PV-ul pierdut rămâne pierdut", Expeditie.pv == pv_intrare - PV_PIERDUT,
		"%d PV (intrat cu %d)" % [Expeditie.pv, pv_intrare]) and tot_bun
	tot_bun = _verdict("nodul rămâne nerezolvat", Expeditie.nod_nerezolvat == id,
		"nod_nerezolvat=%d" % Expeditie.nod_nerezolvat) and tot_bun
	tot_bun = _verdict("harta NU redeschide lupta singură",
		harta.scene_file_path == SCENA_HARTA) and tot_bun
	tot_bun = _verdict("niciun drum deschis spre vecini", harta._optiuni().is_empty()) and tot_bun
	tot_bun = _verdict("nodul luptei e apăsabil", harta.simboluri_nod[id].activ) and tot_bun
	var alt_activ := 0
	for alt in harta.simboluri_nod:
		if int(alt) != id and harta.simboluri_nod[alt].activ:
			alt_activ += 1
	tot_bun = _verdict("niciun alt nod nu e apăsabil", alt_activ == 0,
		"%d apăsabile" % alt_activ) and tot_bun
	tot_bun = _verdict("butonul Meniu se vede pe hartă", harta.buton_harta_meniu.visible) and tot_bun

	# Și pe disc la fel: retragerea a scris, nu doar a schimbat memoria.
	var pv_memorie := Expeditie.pv
	Expeditie.goleste()
	Arhiva.incarca()
	tot_bun = _verdict("pe disc: PV-ul de după retragere", Expeditie.pv == pv_memorie,
		"%d PV" % Expeditie.pv) and tot_bun
	tot_bun = _verdict("pe disc: nodul nerezolvat", Expeditie.nod_nerezolvat == id) and tot_bun

	# ── 3. clic pe piesă: aceeași luptă, fără a doua intrare ────
	print("\n  3. CLIC PE PIESĂ")
	var parcurse_inainte := Expeditie.parcurse.size()
	harta._pe_nod_apasat(id)
	lupta = await _asteapta_scena(SCENA_LUPTA)
	tot_bun = _verdict("clicul redeschide lupta", lupta != null) and tot_bun
	if lupta == null:
		_incheie(false)
		return
	tot_bun = _verdict("nodul nu intră a doua oară în parcurse",
		Expeditie.parcurse.size() == parcurse_inainte and Expeditie.parcurse.count(id) == 1,
		"%d noduri parcurse" % Expeditie.parcurse.size()) and tot_bun
	tot_bun = _verdict("lupta pornește cu PV-ul de după retragere",
		lupta.pv_jucator == pv_intrare - PV_PIERDUT, "%d PV" % lupta.pv_jucator) and tot_bun

	# ── 4. victorie: harta se redeschide ────────────────────────
	print("\n  4. DUPĂ VICTORIE")
	lupta.termina_lupta(true)
	tot_bun = _verdict("după verdict nu te mai retragi", lupta.buton_harta.disabled) and tot_bun
	lupta._inapoi_la_harta()
	harta = await _asteapta_scena(SCENA_HARTA)
	tot_bun = _verdict("înapoi pe hartă", harta != null) and tot_bun
	if harta == null:
		_incheie(false)
		return
	tot_bun = _verdict("nodul e încheiat", Expeditie.nod_nerezolvat == -1) and tot_bun
	tot_bun = _verdict("drumurile spre vecini s-au redeschis", not harta._optiuni().is_empty(),
		"%d opțiuni" % harta._optiuni().size()) and tot_bun
	tot_bun = _verdict("nodul încheiat nu mai e apăsabil", not harta.simboluri_nod[id].activ) and tot_bun

	# ── 5. „Meniu" de pe hartă: expediția rămâne vie ────────────
	print("\n  5. MENIU DE PE HARTĂ")
	var samanta := Expeditie.samanta
	harta._pe_meniu()
	var meniu := await _asteapta_scena(SCENA_MENIU)
	tot_bun = _verdict("butonul duce în meniu", meniu != null) and tot_bun
	tot_bun = _verdict("expediția nu s-a golit", Expeditie.activa and Expeditie.samanta == samanta) and tot_bun
	Expeditie.goleste()
	Arhiva.incarca()
	tot_bun = _verdict("expediția e și pe disc", Expeditie.activa and Expeditie.samanta == samanta) and tot_bun

	_incheie(tot_bun)


func _incheie(tot_bun: bool) -> void:
	_goleste_dosarul()
	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"ieșirile din expediție sunt pauze cinstite" if tot_bun else "O IEȘIRE PIERDE SAU DĂ CEVA"])
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# SCENELE
# ─────────────────────────────────────────────────────────────

## Pune scena ca `current_scene`, ca jocul, și o întoarce după ce i-a rulat
## `_ready`. Prima oară, verificarea însăși e scena curentă: pune întâi un
## paravan (vezi antetul).
func _schimba_in(cale: String) -> Node:
	if get_tree().current_scene == self:
		var paravan := Node.new()
		get_tree().root.add_child(paravan)
		get_tree().current_scene = paravan
	get_tree().change_scene_to_file(cale)
	return await _asteapta_scena(cale)


## Așteaptă până când scena curentă e cea cerută (câteva cadre: schimbarea se
## face la capătul cadrului). `null` dacă n-a venit.
func _asteapta_scena(cale: String) -> Node:
	for i in range(30):
		await get_tree().process_frame
		var scena := get_tree().current_scene
		if scena != null and scena.scene_file_path == cale and scena.is_node_ready():
			return scena
	return null


# ─────────────────────────────────────────────────────────────
# UNELTE
# ─────────────────────────────────────────────────────────────

func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-48s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _goleste_dosarul() -> void:
	if not DirAccess.dir_exists_absolute(DOSAR):
		DirAccess.make_dir_recursive_absolute(DOSAR)
		return
	for nume in DirAccess.get_files_at(DOSAR):
		DirAccess.remove_absolute(Arhiva.cale_catre(String(nume)))

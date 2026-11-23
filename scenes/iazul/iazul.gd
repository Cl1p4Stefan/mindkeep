extends Control
## IAZUL DE SUB CETATE — al patrulea mod, cel în care nu se învață nimic.
##
## De pe 16 noiembrie 2026. Locul în care vii după un raft de Cultură generală
## parcurs, ca să-ți odihnești mintea. Fără întrebări, fără ceas, fără
## înfrângere: un pește scăpat nu costă nimic, doar se întoarce apa la liniște.
##
## ─────────────────────────────────────────────────────────────
## BUCLA, ÎN TREI GESTURI CU UN SINGUR BUTON (clic stânga sau Spațiu)
##
##   1. ARUNCI   — ții apăsat, bara de putere urcă și coboară, dai drumul.
##                 Aproape = pești mărunți; departe = rari și grei.
##   2. AȘTEPȚI  — pluta tremură de câteva ori (ciupituri), apoi se scufundă
##                 de-adevăratelea. Lovești ABIA atunci. Cine lovește la o
##                 ciupitură sperie peștele — inhibiția Obeliscului Reflex,
##                 deghizată în pescuit.
##   3. TRAGI    — vezi `firul.gd`: ții apăsat, dar dai drumul când peștele
##                 smucește.
##
## ─────────────────────────────────────────────────────────────
## DE CE TE ȚINE AICI („HOOKED”), ȘI DE CE E CINSTIT
##
## Nu prin serii zilnice, nu prin „revino mâine sau pierzi", nu prin cutii cu
## surprize — toate trei ar încălca „Ton sănătos" din principii. Te ține
## CURIOZITATEA: jurnalul are 16 siluete negre, fiecare cu un indiciu („Departe,
## noaptea, pe ceață"), iar ora și vremea se schimbă singure cât stai la iaz.
## O vreme nouă e o promisiune: altceva mușcă acum. Plus recordul de masă pe
## fiecare specie, care face și un caras al zecelea să conteze.
##
## ─────────────────────────────────────────────────────────────
## CE SE SCRIE PE DISC
##
## Doar jurnalul: pe fiecare specie, câte ai prins și cel mai mare. Fără
## Monede, fără Fragmente — din exact motivul de la Tavernă („nu plătește
## nimic"): Cetatea nu există încă, deci orice preț ar fi inventat. Starea e
## `static`, ca la `taverna.gd`, iar `Arhiva` o adună sub cheia „iazul".
##
## ─────────────────────────────────────────────────────────────
## IMAGINI PICTATE, CU DESENUL CA REZERVĂ (de pe 17 noiembrie 2026)
##
## Fundalul (zi, amurg, noapte), pontonul și undița sunt imagini din
## `assets/iazul/`, pregătite cu `tools/iazul_imagini.py`. Restul rămâne
## desenat: pluta, firul, peștii, undele, ploaia, ceața, licuricii — tot ce
## SE MIȘCĂ. Fundalurile se topesc unul în altul după oră (zorii împrumută
## amurgul), iar pontonul și undița primesc lumina momentului (`lumina` din
## `PALETE`), altfel ar fi lemn în plină zi pe un cer înstelat.
##
## Fiecare imagine e opțională: dacă lipsește, se desenează ca înainte, din
## `_draw()`. Deci desenul vechi nu e cod mort, e plasa de siguranță.

const SCENA_MENIU := "res://scenes/meniu/meniu.tscn"

const IMAGINI := {
	"zi": "res://assets/iazul/fundal_zi.jpg",
	"amurg": "res://assets/iazul/fundal_amurg.jpg",
	"noapte": "res://assets/iazul/fundal_noapte.jpg",
	"ponton": "res://assets/iazul/ponton.png",
	"undita": "res://assets/iazul/undita.png",
}
## Linia apei în cele trei fundaluri, ca fracțiune din înălțimea imaginii.
## Toate trei sunt pictate pe aceeași compoziție, deci e una singură.
const ORIZONT_FUNDAL := 0.547
## În pixelii lui `undita.png`: mijlocul mânerului pe marginea de jos și vârful.
## Undița se ROTEȘTE și se SCALEAZĂ ca punctele astea două să cadă pe `MANER`
## și pe vârful calculat — deci se apleacă spre pește la fel ca cea desenată.
const UNDITA_MANER := Vector2(885, 558)
const UNDITA_VARF := Vector2(347, 0)
## În pixelii lui `ponton.png`: muchia scândurilor dinspre apă.
const PONTON_MUCHIE := 288.0
## Pe ecran: cât de lat e pontonul și unde cade muchia lui dinspre apă.
## Partea de jos a imaginii iese pe sub marginea ecranului — stai PE ponton.
const PONTON_LATIME := 0.78
const PONTON_MUCHIE_Y := 0.80

## Imaginile încărcate, cheie → Texture2D. `static`, ca sunetele: o dată pe joc.
static var _imagini := {}

enum Stare { GATA, INCARCA, ZBOR, ASTEAPTA, TRAGERE, CAPTURA }

## O zi la iaz durează 15 minute: o sesiune întreagă vede ciclul o dată, iar
## fiecare parte a zilei ține câteva minute, nu câteva zeci de secunde — cu
## 6 minute (până pe 17 noiembrie) amurgul trecea cât ai fi tras un pește.
const ZI_SECUNDE := 900.0
## Momentele zilei, ca intervale în ciclu (început, cheie). Zori ~2 min, zi
## ~5,5, amurg ~3, noapte ~4,3. Hotarele cad la mijlocul trecerilor de
## culoare din `CHEI_CULOARE`, deci titlul se schimbă când cerul e pe jumătate.
const ORAR := [[0.0, "zori"], [125.0, "zi"], [455.0, "amurg"], [640.0, "noapte"]]
## Cât ține o vreme până se poate schimba.
const VREME_MIN := 70.0
const VREME_MAX := 140.0
## Cât stă pluta sub apă la mușcătura adevărată. Generos: e un mod de
## relaxare, iar priceperea cerută e să NU lovești devreme, nu viteza.
const FEREASTRA_MUSCATURA := 0.95
const DURATA_CIUPITURA := 0.28
const DURATA_ZBOR := 0.6

## Jurnalul: cheie → {"prinsi": int, "record": float}. Vezi „CE SE SCRIE PE DISC".
static var _jurnal := {}

var stare := Stare.GATA
var rng := RandomNumberGenerator.new()

# — ziua și vremea —
var ora := 0.0                 # secunde în ciclul zilei
var vreme := "senin"
var _ceas_vreme := 90.0

# — aruncarea —
var putere := 0.0
var _sens_putere := 1.0
var distanta := 0.0            # 0..1, unde a căzut pluta
var _abatere := 0.0            # -1..1, cât de la stânga/dreapta a căzut
var zona := 0
var _zbor := 0.0

# — așteptarea —
var _ceas_sosire := 0.0        # până vine un pește
var specie_curenta := {}       # peștele care stă la momeală, sau {}
var _ciupituri_ramase := 0
var _ceas_eveniment := 0.0     # până la următoarea ciupitură / mușcătură
var _ceas_ciupitura := 0.0     # cât mai ține ciupitura de acum (pluta în jos)
var _ceas_muscatura := 0.0     # cât mai e pluta sub apă

# — tragerea —
var firul: Firul = null
var masa_curenta := 0.0
var apasat := false

# — de pe ecran —
var _timp := 0.0
var _cercuri: Array = []       # [poziție, vârstă, mărime] — undele de pe apă
var _stele := PackedVector2Array()
var _mesaj_ceas := 0.0
var _captura_noua := false
var _record_nou := false

# — sunetele —
var sunete: SuneteIaz
var _ceas_clic := 0.0          # până la următorul clic de mulinetă
var _faza_inainte := -1        # faza firului de la pasul trecut
var _ceas_ciripit := 6.0       # până cântă iar o pasăre

var _lbl_ora: Label
var _lbl_indiciu: Label
var _lbl_mesaj: Label
var _btn_jurnal: Button
var _btn_meniu: Button
var _card: PanelContainer
var _card_titlu: Label
var _card_desen: Control
var _card_nume: Label
var _card_masa: Label
var _card_detaliu: Label
var _card_buton: Button
var _jurnal_panou: Control
var _jurnal_grila: GridContainer
var _jurnal_titlu: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	rng.randomize()
	# Începi după-amiaza târziu: în primele minute vezi deja cum vine amurgul,
	# adică afli din prima sesiune că ora se schimbă.
	ora = 330.0
	_ceas_vreme = rng.randf_range(VREME_MIN, VREME_MAX)
	var r := RandomNumberGenerator.new()
	r.seed = 7
	for i in range(70):
		_stele.append(Vector2(r.randf(), r.randf()))
	_incarca_imaginile()
	_construieste_ecranul()
	_actualizeaza_textele()
	sunete = SuneteIaz.new()
	add_child(sunete)
	# Fără muzică la iaz: aici fundalul e apa, greierii și păsările. Muzica se
	# stinge treptat, iar la întoarcere meniul o pornește iar din `_ready`.
	Muzica.opreste()


# ─────────────────────────────────────────────────────────────
# ZIUA ȘI VREMEA
# ─────────────────────────────────────────────────────────────

func moment() -> String:
	var m: String = ORAR[0][1]
	for intrare in ORAR:
		if ora >= float(intrare[0]):
			m = intrare[1]
	return m


func _avanseaza_ziua(dt: float) -> void:
	var inainte := moment()
	ora = fmod(ora + dt, ZI_SECUNDE)
	_ceas_vreme -= dt
	var vreme_inainte := vreme
	if _ceas_vreme <= 0.0:
		_ceas_vreme = rng.randf_range(VREME_MIN, VREME_MAX)
		var r := rng.randf()
		vreme = "senin" if r < 0.55 else ("ceata" if r < 0.78 else "ploaie")
	if moment() != inainte or vreme != vreme_inainte:
		_actualizeaza_textele()
		if vreme != vreme_inainte:
			_arata_mesaj({"senin": "Cerul s-a limpezit.", "ceata": "Se lasă ceața peste apă.",
				"ploaie": "A început să plouă."}[vreme])


# ─────────────────────────────────────────────────────────────
# INTRAREA — un singur buton
# ─────────────────────────────────────────────────────────────

func _unhandled_input(e: InputEvent) -> void:
	var apasare = null
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		apasare = e.pressed
	elif e is InputEventKey and e.keycode == KEY_SPACE and not e.echo:
		apasare = e.pressed
	elif e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_J:
		_comuta_jurnalul()
		get_viewport().set_input_as_handled()
		return
	if apasare == null:
		return
	if _jurnal_panou.visible:
		return
	get_viewport().set_input_as_handled()
	if stare == Stare.CAPTURA:
		if apasare:
			_inchide_cartea()
		return
	apasat = apasare
	if apasare:
		la_apasare()
	else:
		la_eliberare()


## Publice (fără `_`) fiindcă le cheamă și `verifica_iazul`, care joacă scena
## fără mouse.
func la_apasare() -> void:
	match stare:
		Stare.GATA:
			stare = Stare.INCARCA
			putere = 0.0
			_sens_putere = 1.0
		Stare.ASTEAPTA:
			if _ceas_muscatura > 0.0:
				_incepe_tragerea()
			elif not specie_curenta.is_empty():
				# Ai lovit la o ciupitură: peștele a simțit cârligul.
				_arata_mesaj("Prea devreme. Peștele s-a speriat.")
				sunete.reda("ciupitura", 3.0, 0.7)
				_pleaca_pestele(rng.randf_range(2.5, 5.0))
				_unda(_pozitia_plutei(), 18.0)
			else:
				_arata_mesaj("Ai strâns firul.")
				sunete.reda("clic")
				stare = Stare.GATA
	_actualizeaza_textele()


func la_eliberare() -> void:
	if stare == Stare.INCARCA:
		_arunca()
	_actualizeaza_textele()


func _arunca() -> void:
	distanta = putere
	zona = 0 if distanta < 0.4 else (1 if distanta < 0.75 else 2)
	_abatere = rng.randf_range(-1.0, 1.0)
	stare = Stare.ZBOR
	sunete.reda("arunca", 0.0, 1.15 - 0.3 * distanta)
	_zbor = 0.0


# ─────────────────────────────────────────────────────────────
# PASUL — despărțit de `_process` ca verificarea să poată da timpul cu mâna
# ─────────────────────────────────────────────────────────────

func _process(dt: float) -> void:
	pas(dt)


func pas(dt: float) -> void:
	_timp += dt
	_avanseaza_ziua(dt)
	if _mesaj_ceas > 0.0:
		_mesaj_ceas -= dt
		_lbl_mesaj.modulate.a = clampf(_mesaj_ceas / 0.6, 0.0, 1.0)

	match stare:
		Stare.INCARCA:
			putere += _sens_putere * dt * 0.85
			if putere >= 1.0:
				putere = 1.0
				_sens_putere = -1.0
			elif putere <= 0.0:
				putere = 0.0
				_sens_putere = 1.0
		Stare.ZBOR:
			_zbor += dt / DURATA_ZBOR
			if _zbor >= 1.0:
				stare = Stare.ASTEAPTA
				_unda(_pozitia_plutei(), 26.0)
				# Pluta de departe se aude mai încet: e la 10 dB sub cea de lângă mal.
				sunete.reda("plici", -10.0 * distanta, rng.randf_range(0.9, 1.1))
				_pleaca_pestele(rng.randf_range(1.5, 4.0))
				_actualizeaza_textele()
		Stare.ASTEAPTA:
			_pas_asteptare(dt)
		Stare.TRAGERE:
			firul.pas(dt, apasat)
			_sunetele_tragerii(dt)
			if firul.faza == Firul.Faza.SMUCITURA and rng.randf() < dt * 6.0:
				_unda(_pozitia_pestelui() + Vector2(rng.randf_range(-12, 12), 0), 10.0)
			if firul.rupt:
				sunete.reda("rupt")
				_arata_mesaj("Firul s-a rupt. %s a scăpat." % _cu_articol(specie_curenta))
				specie_curenta = {}
				firul = null
				stare = Stare.GATA
				_actualizeaza_textele()
			elif firul.prins:
				_prinde()

	# Undele îmbătrânesc și pier.
	for i in range(_cercuri.size() - 1, -1, -1):
		_cercuri[i][1] += dt
		if _cercuri[i][1] > 1.6:
			_cercuri.remove_at(i)
	_sunetele_locului(dt)
	if vreme == "ploaie" and rng.randf() < dt * 10.0:
		var y0 := size.y * 0.42
		_unda(Vector2(rng.randf() * size.x, rng.randf_range(y0 + 10, size.y)), 5.0)
	queue_redraw()


func _pas_asteptare(dt: float) -> void:
	if _ceas_ciupitura > 0.0:
		_ceas_ciupitura -= dt
	if _ceas_muscatura > 0.0:
		_ceas_muscatura -= dt
		if _ceas_muscatura <= 0.0:
			_arata_mesaj("Peștele a plecat cu momeala. Mai așteaptă.")
			_pleaca_pestele(rng.randf_range(2.0, 4.5))
		return
	if specie_curenta.is_empty():
		_ceas_sosire -= dt
		if _ceas_sosire <= 0.0:
			specie_curenta = Pesti.trage_specia(zona, moment(), vreme, rng)
			_ciupituri_ramase = rng.randi_range(0, 3)
			_ceas_eveniment = 0.0
		return
	_ceas_eveniment -= dt
	if _ceas_eveniment <= 0.0:
		if _ciupituri_ramase > 0:
			_ciupituri_ramase -= 1
			_ceas_ciupitura = DURATA_CIUPITURA
			_ceas_eveniment = rng.randf_range(0.9, 2.0)
			sunete.reda("ciupitura", 0.0, rng.randf_range(0.9, 1.15))
			_unda(_pozitia_plutei(), 8.0)
		else:
			_ceas_muscatura = FEREASTRA_MUSCATURA
			sunete.reda("muscatura", 0.0, rng.randf_range(0.92, 1.05))
			_unda(_pozitia_plutei(), 22.0)
			_unda(_pozitia_plutei(), 14.0)


## Ce se aude cât tragi. Trei sunete, fiecare cu altă veste:
##   clicul mulinetei — tragi, totul e bine (des cât tragi, rar cât nu);
##   scârțâitul firului — AVERTIZAREA: peștele se pregătește să smucească;
##   frâna — SMUCITURA: peștele ia fir, iar tu ar trebui să nu ții apăsat.
## Deci lupta se poate juca și cu ochii închiși, ceea ce la un mod de relaxare
## e mai mult decât o podoabă: semnul de pe ecran are acum un frate în ureche.
func _sunetele_tragerii(dt: float) -> void:
	var faza := int(firul.faza)
	if faza != _faza_inainte and firul.faza == Firul.Faza.AVERTIZARE:
		sunete.reda("scartait", 0.0, 0.9 + 0.08 * float(specie_curenta.get("forta", 1)))
	_faza_inainte = faza
	_ceas_clic -= dt
	if _ceas_clic > 0.0:
		return
	if firul.faza == Firul.Faza.SMUCITURA:
		sunete.reda("frana", 0.0, rng.randf_range(0.95, 1.05))
		_ceas_clic = 0.035
	elif apasat:
		sunete.reda("clic", 0.0, rng.randf_range(0.95, 1.05))
		_ceas_clic = 0.09


## Ambianța: apa mereu, ploaia când plouă, greierii seara; păsările ziua, din
## când în când, nu în buclă — un ciripit repetat la fix se recunoaște în a
## doua minută.
func _sunetele_locului(dt: float) -> void:
	sunete.ambianta(dt, moment(), vreme)
	_ceas_ciripit -= dt
	if _ceas_ciripit <= 0.0:
		var m := moment()
		if vreme != "ploaie" and (m == "zori" or m == "zi"):
			sunete.reda("ciripit", rng.randf_range(-6.0, 0.0), rng.randf_range(0.85, 1.2))
		_ceas_ciripit = rng.randf_range(3.0, 7.0) if moment() == "zori" else rng.randf_range(8.0, 18.0)


func _pleaca_pestele(peste_cat: float) -> void:
	specie_curenta = {}
	_ceas_sosire = peste_cat
	_ceas_muscatura = 0.0
	_ceas_ciupitura = 0.0
	_ciupituri_ramase = 0


func _incepe_tragerea() -> void:
	_ceas_muscatura = 0.0
	masa_curenta = Pesti.trage_masa(specie_curenta, rng)
	firul = Firul.new(int(specie_curenta["forta"]), zona,
		Pesti.masa_relativa(specie_curenta, masa_curenta), rng)
	stare = Stare.TRAGERE
	_unda(_pozitia_plutei(), 30.0)
	_faza_inainte = -1
	_ceas_clic = 0.0


func _prinde() -> void:
	var cheie: String = specie_curenta["cheie"]
	var intrare: Dictionary = _jurnal.get(cheie, {"prinsi": 0, "record": 0.0})
	_captura_noua = int(intrare["prinsi"]) == 0
	_record_nou = not _captura_noua and masa_curenta > float(intrare["record"])
	intrare["prinsi"] = int(intrare["prinsi"]) + 1
	intrare["record"] = maxf(float(intrare["record"]), masa_curenta)
	_jurnal[cheie] = intrare
	# Pe disc imediat: un joc închis din colțul ferestrei n-are voie să piardă
	# un pește prins. Aceeași grijă ca la regulile citite din Tavernă.
	Arhiva.salveaza_permanent()
	sunete.reda("stropi")
	Sunet.reda(Sunet.Efect.CORECT)
	stare = Stare.CAPTURA
	firul = null
	_arata_cartea()
	_actualizeaza_textele()


static func _cu_articol(s: Dictionary) -> String:
	return "Peștele" if s.is_empty() else String(s["nume"])


# ─────────────────────────────────────────────────────────────
# JURNALUL PE DISC
# ─────────────────────────────────────────────────────────────

static func spre_dictionar() -> Dictionary:
	var chei := _jurnal.keys()
	chei.sort()
	var specii := {}
	for cheie in chei:
		specii[cheie] = {"prinsi": int(_jurnal[cheie]["prinsi"]),
			"record": snappedf(float(_jurnal[cheie]["record"]), 0.001)}
	return {"jurnal": specii}


## Citit strâmb, ca peste tot: o specie necunoscută (scoasă din catalog) se
## IGNORĂ, nu se șterge din fișier pe nesimțite — dar nici nu intră în joc.
static func din_dictionar(date: Dictionary) -> void:
	_jurnal.clear()
	var specii = date.get("jurnal")
	if not specii is Dictionary:
		return
	for cheie in specii:
		var intrare = specii[cheie]
		if not intrare is Dictionary or Pesti.specie(String(cheie)).is_empty():
			continue
		var prinsi := int(intrare.get("prinsi", 0))
		if prinsi <= 0:
			continue
		_jurnal[String(cheie)] = {"prinsi": prinsi, "record": maxf(0.0, float(intrare.get("record", 0.0)))}


static func cate_specii_prinse() -> int:
	return _jurnal.size()


# ─────────────────────────────────────────────────────────────
# GEOMETRIA SCENEI
# ─────────────────────────────────────────────────────────────

func _orizont() -> float:
	if _are_fundal():
		var r := _dreptunghi_fundal()
		return r.position.y + r.size.y * ORIZONT_FUNDAL
	return size.y * 0.42


## Unde stă muchia pontonului dinspre apă, pe ecran.
func _muchia_pontonului() -> float:
	if _imagini.has("ponton"):
		return size.y * PONTON_MUCHIE_Y
	return size.y - 104.0


static func _incarca_imaginile() -> void:
	for cheie: String in IMAGINI:
		if not _imagini.has(cheie) and ResourceLoader.exists(IMAGINI[cheie]):
			_imagini[cheie] = load(IMAGINI[cheie])


func _are_fundal() -> bool:
	return _imagini.has("zi") and _imagini.has("amurg") and _imagini.has("noapte")


## Fundalul acoperă tot ecranul păstrându-și proporțiile; ce prisosește se taie
## pe margini, egal. La 1152 × 648 imaginile încap aproape exact.
func _dreptunghi_fundal() -> Rect2:
	var t: Texture2D = _imagini["zi"]
	var scara := maxf(size.x / t.get_width(), size.y / t.get_height())
	var marime := t.get_size() * scara
	return Rect2((size - marime) / 2.0, marime)


## VEDEREA E A PESCARULUI (de pe 16 noiembrie 2026, a doua zi a iazului).
## Stai la capătul pontonului și te uiți drept înainte: mânerul undiței iese
## prin marginea de jos, puțin la dreapta mijlocului (mâna dreaptă), iar
## distanța aruncării e doar ÎNĂLȚIMEA pe ecran — jos lângă mal, sus lângă
## orizont. Prima scriere vedea scena din lateral, cu pluta pe o diagonală,
## unde „departe” se amesteca cu „la dreapta”.
##
## Vârful se oprește pe la jumătatea ecranului (`VARF_Y`), ca să nu acopere
## pluta aruncată departe, care stă aproape de orizont (0,42).
const MANER := Vector2(0.80, 1.06)     # în fracțiuni din ecran
const VARF := Vector2(0.56, 0.50)


func _varful_unditei() -> Vector2:
	var varf := Vector2(size.x * VARF.x, size.y * VARF.y)
	if stare == Stare.TRAGERE and firul != null:
		# Vârful se apleacă spre pește, cu atât mai mult cu cât firul e întins.
		var spre := (_pozitia_pestelui() - varf).normalized()
		varf += spre * firul.tensiune * 42.0 + Vector2(0, firul.tensiune * 18.0)
		if firul.faza == Firul.Faza.AVERTIZARE:
			varf.x += sin(_timp * 60.0) * 4.0
	elif stare == Stare.INCARCA:
		# Ridici undița înapoi, peste umăr, ca să arunci.
		varf += Vector2(putere * 24.0, -putere * 90.0)
	return varf


func _pozitia_plutei() -> Vector2:
	# Lângă mal pluta poate cădea puțin în stânga sau în dreapta; departe,
	# perspectiva strânge abaterea spre mijloc.
	var aproape := Vector2(size.x * 0.45 + _abatere * 70.0, _muchia_pontonului() - 26.0)
	var departe := Vector2(size.x * 0.49 + _abatere * 18.0, _orizont() + 26.0)
	return aproape.lerp(departe, pow(distanta, 0.8))


func _pozitia_pestelui() -> Vector2:
	if firul == null:
		return _pozitia_plutei()
	# Peștele vine spre capătul pontonului și dă din coadă lateral.
	var mal := Vector2(size.x * 0.48, _muchia_pontonului() - 6.0)
	var p := _pozitia_plutei().lerp(mal, firul.progres * 0.85)
	var amplitudine := 14.0 + (36.0 if firul.faza == Firul.Faza.SMUCITURA else 0.0)
	p.x += sin(_timp * (3.0 + firul.forta * 0.6)) * amplitudine
	return p


func _unda(p: Vector2, marime: float) -> void:
	_cercuri.append([p, 0.0, marime])


# ─────────────────────────────────────────────────────────────
# CULORILE ZILEI — patru chei pe ciclu, amestecate lin
# ─────────────────────────────────────────────────────────────

const PALETE := {
	"zori":   {"sus": Color(0.36, 0.36, 0.52), "jos": Color(0.92, 0.66, 0.58), "apa": Color(0.30, 0.32, 0.42), "mal": Color(0.16, 0.14, 0.20), "lumina": Color(0.86, 0.76, 0.78)},
	"zi":     {"sus": Color(0.42, 0.58, 0.72), "jos": Color(0.82, 0.86, 0.84), "apa": Color(0.24, 0.38, 0.44), "mal": Color(0.20, 0.24, 0.24), "lumina": Color(1.0, 1.0, 1.0)},
	"amurg":  {"sus": Color(0.26, 0.20, 0.38), "jos": Color(0.96, 0.56, 0.32), "apa": Color(0.26, 0.20, 0.30), "mal": Color(0.12, 0.08, 0.12), "lumina": Color(0.80, 0.62, 0.56)},
	"noapte": {"sus": Color(0.03, 0.04, 0.10), "jos": Color(0.10, 0.14, 0.26), "apa": Color(0.04, 0.07, 0.14), "mal": Color(0.02, 0.03, 0.06), "lumina": Color(0.30, 0.34, 0.48)},
}
## Punctele în care paleta e „curată", pe ciclu; între ele se amestecă.
## Trecerile țin 50-90 de secunde, iar între ele fiecare culoare STĂ: zi
## 250 s, amurg 100 s, noapte 220 s — fundalul nu e mereu în drum spre altul.
const CHEI_CULOARE := [[0.0, "noapte"], [50.0, "zori"], [95.0, "zori"], [160.0, "zi"],
	[410.0, "zi"], [500.0, "amurg"], [600.0, "amurg"], [680.0, "noapte"], [900.0, "noapte"]]
## Soarele răsare în zori curați și apune spre noapte; luna ia restul ciclului.
const RASARIT := 50.0
const APUS := 620.0


func _paleta() -> Dictionary:
	for i in range(CHEI_CULOARE.size() - 1):
		var a = CHEI_CULOARE[i]
		var b = CHEI_CULOARE[i + 1]
		if ora >= float(a[0]) and ora <= float(b[0]):
			var t := (ora - float(a[0])) / maxf(0.001, float(b[0]) - float(a[0]))
			var pa: Dictionary = PALETE[a[1]]
			var pb: Dictionary = PALETE[b[1]]
			var p := {}
			for k in pa:
				p[k] = (pa[k] as Color).lerp(pb[k], t)
			return p
	return PALETE["noapte"]


## 0 ziua, 1 noaptea în toată puterea ei — pentru stele, licurici, ferestre.
func _intuneric() -> float:
	var p := _paleta()
	var l: float = (p["sus"] as Color).get_luminance()
	return clampf(1.0 - (l - 0.04) / 0.5, 0.0, 1.0)


# ─────────────────────────────────────────────────────────────
# DESENUL
# ─────────────────────────────────────────────────────────────

func _draw() -> void:
	# Fără pânză (o scenă pusă sub un `Node`, ca în verificare) nu e nimic de
	# desenat, iar poligoanele turtite la lățime zero nu se pot triangula.
	if size.x < 64.0 or size.y < 64.0:
		return
	var p := _paleta()
	var w := size.x
	var h := size.y
	var y0 := _orizont()
	var noapte := _intuneric()
	if _are_fundal():
		_deseneaza_fundalul()
	else:
		_deseneaza_cerul_si_apa(p, w, h, y0, noapte)

	# Undele.
	for c in _cercuri:
		var varsta: float = c[1]
		var r: float = c[2] * (0.4 + varsta * 1.2)
		var alfa := clampf(1.0 - varsta / 1.6, 0.0, 1.0) * 0.6
		_elipsa(c[0], r, r * 0.32, Color(1, 1, 1, alfa), 1.5)

	if _imagini.has("ponton"):
		_deseneaza_pontonul_pictat(p)
	else:
		_deseneaza_pontonul(p, h)
	_deseneaza_undita()
	_deseneaza_vremea(w, h, y0, noapte)

	if stare == Stare.INCARCA:
		_deseneaza_puterea()
	if stare == Stare.TRAGERE and firul != null:
		_deseneaza_tensiunea()


## Desenul vechi al cerului, malului și apei — rezerva când lipsesc fundalurile.
func _deseneaza_cerul_si_apa(p: Dictionary, w: float, h: float, y0: float, noapte: float) -> void:

	# Cerul, în fâșii.
	var fasii := 24
	for i in range(fasii):
		var t := float(i) / fasii
		draw_rect(Rect2(0, y0 * t, w, y0 / fasii + 1), (p["sus"] as Color).lerp(p["jos"], t))

	# Stelele.
	if noapte > 0.3:
		for i in range(_stele.size()):
			var s := _stele[i]
			var clipit := 0.6 + 0.4 * sin(_timp * 1.3 + i)
			draw_circle(Vector2(s.x * w, s.y * y0 * 0.8), 1.1, Color(1, 1, 0.9, (noapte - 0.3) * clipit))

	# Soarele sau luna, pe un arc peste ciclu.
	var astru := _pozitia_astrului()
	var e_luna := noapte > 0.5
	var c_astru := Color(1.0, 0.95, 0.80) if e_luna else Color(1.0, 0.88, 0.62)
	if astru.y < y0:
		draw_circle(astru, 34.0, Color(c_astru, 0.12))
		draw_circle(astru, 22.0, c_astru)
		if e_luna:
			draw_circle(astru + Vector2(-6, -4), 4.0, Color(0.85, 0.82, 0.70))
			draw_circle(astru + Vector2(7, 6), 3.0, Color(0.85, 0.82, 0.70))

	_deseneaza_malul(p, w, y0, noapte)

	# Apa.
	for i in range(fasii):
		var t := float(i) / fasii
		var y := y0 + (h - y0) * t
		draw_rect(Rect2(0, y, w, (h - y0) / fasii + 1), (p["jos"] as Color).lerp(p["apa"], 0.55 + 0.45 * t).darkened(0.15 + 0.25 * t))
	# Reflexia astrului.
	if astru.y < y0:
		for i in range(14):
			var y := y0 + 6 + i * 9.0
			var lat := (30.0 - i) * (0.6 + 0.4 * sin(_timp * 2.0 + i))
			draw_line(Vector2(astru.x - lat, y), Vector2(astru.x + lat, y), Color(c_astru, 0.35 - i * 0.02), 2.0)
	# Sclipiri pe apă.
	for i in range(40):
		var fx := fmod(i * 97.13 + _timp * (6.0 + i % 5), w + 80) - 40
		var fy := y0 + 12 + fmod(i * 53.7, h - y0 - 20)
		var lung := 6.0 + (fy - y0) * 0.08
		draw_line(Vector2(fx, fy), Vector2(fx + lung, fy), Color(1, 1, 1, 0.07 + 0.05 * sin(_timp + i)), 1.5)

	# Stuful din dreapta, care se leagănă.
	for i in range(18):
		var x := w - 150 + i * 9.0 + sin(i * 3.1) * 6
		var baza := Vector2(x, h + 4)
		var leganare := sin(_timp * 0.9 + i * 0.7) * 8.0
		var varf := Vector2(x + leganare, h - 120 - (i % 4) * 22)
		draw_line(baza, varf, (p["mal"] as Color).lightened(0.12), 2.5)
		if i % 3 == 0:
			_elipsa(varf + Vector2(0, 10), 3.0, 10.0, (p["mal"] as Color).lightened(0.05), 0.0)



## Ploaia, ceața și licuricii: peste tot, imagine sau desen.
func _deseneaza_vremea(w: float, h: float, y0: float, noapte: float) -> void:
	# Ploaia.
	if vreme == "ploaie":
		for i in range(140):
			var vx := fmod(i * 73.31 + _timp * 60.0, w + 40)
			var vy := fmod(i * 41.7 + _timp * 520.0, h + 40) - 20
			draw_line(Vector2(vx, vy), Vector2(vx - 4, vy + 14), Color(0.8, 0.85, 0.95, 0.35), 1.0)
	# Ceața: benzi care plutesc peste orizont.
	if vreme == "ceata":
		for i in range(5):
			var cy := y0 - 40 + i * 38.0
			var dx := sin(_timp * 0.12 + i) * 80.0
			for j in range(6):
				draw_rect(Rect2(-100 + dx, cy + j * 6, w + 200, 6), Color(0.85, 0.86, 0.88, 0.05 + 0.02 * (3 - abs(j - 3))))
		draw_rect(Rect2(0, 0, w, h), Color(0.75, 0.77, 0.80, 0.14))
	# Licuricii, la amurg și noaptea.
	if noapte > 0.35:
		for i in range(14):
			var lx := w * 0.55 + sin(_timp * 0.3 + i * 1.7) * w * 0.4
			var ly := h * 0.78 + cos(_timp * 0.45 + i * 2.3) * 70.0
			var a := (0.5 + 0.5 * sin(_timp * 2.5 + i * 1.1)) * (noapte - 0.35)
			draw_circle(Vector2(lx, ly), 5.0, Color(1.0, 0.92, 0.45, a * 0.25))
			draw_circle(Vector2(lx, ly), 1.8, Color(1.0, 0.95, 0.6, a))
	# Pe ploaie, tot locul e mai stins.
	if vreme == "ploaie" and _are_fundal():
		draw_rect(Rect2(0, 0, w, h), Color(0.10, 0.12, 0.16, 0.30))


## Cele trei fundaluri, topite după oră: cel de dinainte întreg, cel care
## urmează peste el, tot mai opac. Zorii împrumută amurgul (n-au imaginea lor).
func _deseneaza_fundalul() -> void:
	var r := _dreptunghi_fundal()
	for i in range(CHEI_CULOARE.size() - 1):
		var a = CHEI_CULOARE[i]
		var b = CHEI_CULOARE[i + 1]
		if ora >= float(a[0]) and ora <= float(b[0]):
			var t := (ora - float(a[0])) / maxf(0.001, float(b[0]) - float(a[0]))
			draw_texture_rect(_imagini[_fundal_pentru(a[1])], r, false)
			if t > 0.0 and _fundal_pentru(b[1]) != _fundal_pentru(a[1]):
				draw_texture_rect(_imagini[_fundal_pentru(b[1])], r, false, Color(1, 1, 1, t))
			break
	# Sclipiri pe apă, mai discrete decât pe apa desenată: apa pictată are
	# deja reflexiile ei, sclipirile doar o fac să nu stea pe loc.
	var y0 := _orizont()
	for i in range(30):
		var fx := fmod(i * 97.13 + _timp * (5.0 + i % 5), size.x + 80) - 40
		var fy := y0 + 10 + fmod(i * 53.7, size.y - y0 - 20)
		var lung := 5.0 + (fy - y0) * 0.07
		draw_line(Vector2(fx, fy), Vector2(fx + lung, fy), Color(1, 1, 1, 0.04 + 0.03 * sin(_timp + i)), 1.5)


func _fundal_pentru(moment_culoare: String) -> String:
	return "amurg" if moment_culoare == "zori" else moment_culoare


## Lumina momentului, pentru ce stă în primul plan (pontonul, undița).
func _lumina(p: Dictionary) -> Color:
	var c: Color = p["lumina"]
	if vreme == "ploaie":
		c = c.darkened(0.2)
	elif vreme == "ceata":
		c = c.lerp(Color(0.8, 0.82, 0.86), 0.2)
	return c


func _deseneaza_pontonul_pictat(p: Dictionary) -> void:
	var t: Texture2D = _imagini["ponton"]
	var scara := size.x * PONTON_LATIME / t.get_width()
	var marime := t.get_size() * scara
	var poz := Vector2((size.x - marime.x) / 2.0, _muchia_pontonului() - PONTON_MUCHIE * scara)
	draw_texture_rect(t, Rect2(poz, marime), false, _lumina(p))


func _pozitia_astrului() -> Vector2:
	# Ziua: soarele de la `RASARIT` la `APUS`. Noaptea: luna, pe restul
	# ciclului. Un singur arc, două corpuri.
	var t: float
	if ora >= RASARIT and ora < APUS:
		t = (ora - RASARIT) / (APUS - RASARIT)
	else:
		var o := ora if ora >= APUS else ora + ZI_SECUNDE
		t = (o - APUS) / (ZI_SECUNDE - APUS + RASARIT)
	var x := lerpf(size.x * 0.12, size.x * 0.88, t)
	var y := _orizont() + 20.0 - sin(PI * t) * _orizont() * 0.8
	return Vector2(x, y)


func _deseneaza_malul(p: Dictionary, w: float, y0: float, noapte: float) -> void:
	var mal: Color = p["mal"]
	# Dealurile.
	var dealuri := PackedVector2Array([Vector2(0, y0)])
	for i in range(13):
		var x := w * i / 12.0
		dealuri.append(Vector2(x, y0 - 26 - 12 * sin(i * 1.3) - 6 * sin(i * 3.7)))
	dealuri.append(Vector2(w, y0))
	draw_colored_polygon(dealuri, mal.lightened(0.08))
	# Cetatea, pe malul celălalt.
	var cx := w * 0.72
	var baza := y0 - 20
	var cetate := Color(mal, 1.0)
	draw_rect(Rect2(cx - 90, baza - 40, 180, 42), cetate)
	for t in [[-90, 26, 78], [-20, 30, 104], [60, 24, 70]]:
		var tx: float = cx + float(t[0])
		var lat: float = float(t[1])
		var inalt: float = float(t[2])
		draw_rect(Rect2(tx, baza - inalt, lat, inalt), cetate)
		draw_colored_polygon(PackedVector2Array([Vector2(tx - 4, baza - inalt),
			Vector2(tx + lat / 2.0, baza - inalt - lat * 0.9), Vector2(tx + lat + 4, baza - inalt)]), cetate)
	# Crenelurile zidului.
	for i in range(9):
		draw_rect(Rect2(cx - 88 + i * 20, baza - 48, 10, 9), cetate)
	# Ferestrele se aprind seara.
	if noapte > 0.25:
		var lumina := Color(1.0, 0.78, 0.38, (noapte - 0.25) * 1.2)
		for f in [Vector2(-80, -60), Vector2(-10, -84), Vector2(-10, -58), Vector2(70, -50), Vector2(30, -28)]:
			draw_rect(Rect2(cx + f.x, baza + f.y, 5, 8), lumina)
	# Reflexia malului în apă, întunecată.
	var reflexie := PackedVector2Array([Vector2(0, y0)])
	for i in range(13):
		var x := w * i / 12.0
		reflexie.append(Vector2(x, y0 + 10 + 6 * sin(i * 1.3)))
	reflexie.append(Vector2(w, y0))
	draw_colored_polygon(reflexie, Color(mal, 0.45))


func _deseneaza_pontonul(p: Dictionary, h: float) -> void:
	var lemn := (p["mal"] as Color).lerp(Color(0.36, 0.25, 0.16), 0.55)
	var w := size.x
	# Capătul pontonului, văzut de pe el: un trapez care fuge spre apă, cu
	# scândurile puse de-a curmezișul. Cu cât e mai departe, cu atât mai îngustă
	# și mai subțire e scândura — asta e toată perspectiva.
	var sus := h - 104.0
	var stanga_jos := w * 0.16
	var dreapta_jos := w * 0.84
	var stanga_sus := w * 0.33
	var dreapta_sus := w * 0.67
	draw_colored_polygon(PackedVector2Array([Vector2(stanga_jos, h), Vector2(stanga_sus, sus),
		Vector2(dreapta_sus, sus), Vector2(dreapta_jos, h)]), lemn.darkened(0.1))
	var y := sus
	var grosime := 7.0
	var i := 0
	while y < h:
		var t := (y - sus) / (h - sus)
		var x1 := lerpf(stanga_sus, stanga_jos, t)
		var x2 := lerpf(dreapta_sus, dreapta_jos, t)
		draw_rect(Rect2(x1, y, x2 - x1, grosime - 1.5), lemn.darkened(0.08 * (i % 2)))
		draw_line(Vector2(x1, y + grosime - 1.5), Vector2(x2, y + grosime - 1.5), lemn.darkened(0.45), 1.5)
		y += grosime
		grosime *= 1.32
		i += 1
	# Muchia dinspre apă și cei doi stâlpi de la capăt.
	draw_line(Vector2(stanga_sus, sus), Vector2(dreapta_sus, sus), lemn.darkened(0.5), 3.0)
	for x in [stanga_sus + 4.0, dreapta_sus - 18.0]:
		draw_rect(Rect2(x, sus - 34, 14, 40), lemn.darkened(0.3))
		draw_rect(Rect2(x - 1, sus - 36, 16, 4), lemn.darkened(0.15))
	# O găleată în stânga, ca să se vadă că aici stă cineva.
	var g := Vector2(w * 0.27, h - 24)
	draw_colored_polygon(PackedVector2Array([g + Vector2(-24, -34), g + Vector2(24, -34),
		g + Vector2(18, 16), g + Vector2(-18, 16)]), lemn.darkened(0.2))
	draw_arc(g + Vector2(0, -34), 24, PI, TAU, 16, lemn.darkened(0.5), 2.5)


func _deseneaza_undita() -> void:
	var h := size.y
	var maner := Vector2(size.x * MANER.x, h * MANER.y)
	var varf := _varful_unditei()
	if _imagini.has("undita"):
		_deseneaza_undita_pictata(maner, varf)
	else:
		_deseneaza_bata(maner, varf)
	_deseneaza_firul(varf)


## Undița din imagine, potrivită pe două puncte: mânerul pe `maner`, vârful
## pe `varf`. Rotație și scară uniformă — ce se mișcă e vârful, deci undița
## pictată se apleacă și se ridică la fel ca cea desenată.
func _deseneaza_undita_pictata(maner: Vector2, varf: Vector2) -> void:
	var t: Texture2D = _imagini["undita"]
	var in_imagine := UNDITA_VARF - UNDITA_MANER
	var pe_ecran := varf - maner
	var scara := pe_ecran.length() / in_imagine.length()
	var unghi := in_imagine.angle_to(pe_ecran)
	draw_set_transform(maner, unghi, Vector2(scara, scara))
	draw_texture(t, -UNDITA_MANER, _lumina(_paleta()))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Undița desenată — rezerva când lipsește imaginea.
func _deseneaza_bata(maner: Vector2, varf: Vector2) -> void:
	var h := size.y
	# Undița: groasă jos, unde e aproape de ochi, subțire spre vârf. Mijlocul
	# stă pe dreapta drumului, iar vârful îndoit trage după el doar partea de sus.
	var mijloc := maner.lerp(Vector2(size.x * VARF.x, h * VARF.y), 0.5)
	draw_line(maner, mijloc, Color(0.24, 0.16, 0.10), 17.0)
	draw_line(mijloc, varf, Color(0.36, 0.25, 0.15), 5.0)
	# Mulineta, sub mâner, cu manivela.
	var mulineta := maner.lerp(mijloc, 0.28) + Vector2(16, 6)
	draw_circle(mulineta, 17.0, Color(0.20, 0.15, 0.10))
	draw_circle(mulineta, 10.0, Color(0.55, 0.42, 0.22))
	var unghi := _timp * 9.0 if (stare == Stare.TRAGERE and apasat) else 0.6
	draw_line(mulineta, mulineta + Vector2(cos(unghi), sin(unghi)) * 20.0, Color(0.30, 0.22, 0.14), 4.0)
	# Inelele pe care trece firul.
	for t in [0.62, 0.8, 0.93]:
		draw_circle(mijloc.lerp(varf, t), 2.5, Color(0.6, 0.55, 0.45))


func _deseneaza_firul(varf: Vector2) -> void:
	var fir := Color(0.92, 0.92, 0.88, 0.75)
	match stare:
		Stare.GATA, Stare.INCARCA:
			var atarna := varf + Vector2(0, 70)
			draw_line(varf, atarna, fir, 1.0)
			_deseneaza_pluta(atarna, false)
		Stare.ZBOR:
			var tinta := _pozitia_plutei()
			var start := varf + Vector2(0, 70)
			var t := _zbor
			var poz := start.lerp(tinta, t) + Vector2(0, -sin(PI * t) * 140.0)
			draw_line(varf, poz, fir, 1.0)
			_deseneaza_pluta(poz, false)
		Stare.ASTEAPTA, Stare.CAPTURA:
			var pp := _pozitia_plutei()
			var cufundare := 0.0
			if _ceas_ciupitura > 0.0:
				cufundare = 5.0 * sin(PI * _ceas_ciupitura / DURATA_CIUPITURA)
			var sub_apa := _ceas_muscatura > 0.0
			pp.y += sin(_timp * 2.2) * 1.5 + cufundare
			_curba_fir(varf, pp, fir, 0.25)
			if stare == Stare.ASTEAPTA:
				_deseneaza_pluta(pp, sub_apa)
		Stare.TRAGERE:
			var pf := _pozitia_pestelui()
			_curba_fir(varf, pf, fir, 1.0 - firul.tensiune)
			# Umbra peștelui sub apă, cu silueta speciei — o vezi înainte s-o prinzi.
			var lungime := 40.0 + 30.0 * Pesti.masa_relativa(specie_curenta, masa_curenta) + 6.0 * firul.forta
			var umbra := Color(0.02, 0.03, 0.05, 0.35 + 0.35 * firul.progres)
			Pesti.deseneaza(self, specie_curenta, pf + Vector2(0, 14), lungime, true, umbra)
			if firul.faza == Firul.Faza.AVERTIZARE:
				var r := 18.0 + 6.0 * sin(_timp * 30.0)
				_elipsa(pf, r, r * 0.35, Color(1.0, 0.75, 0.3, 0.8), 2.5)
			elif firul.faza == Firul.Faza.SMUCITURA:
				for i in range(6):
					var a := _timp * 8.0 + i
					draw_line(pf, pf + Vector2(cos(a) * 18, -abs(sin(a)) * 20), Color(1, 1, 1, 0.6), 2.0)


## Firul cade în arc când e slăbit și se întinde drept când e tras.
func _curba_fir(a: Vector2, b: Vector2, culoare: Color, slabire: float) -> void:
	var puncte := PackedVector2Array()
	for i in range(17):
		var t := float(i) / 16.0
		var p := a.lerp(b, t)
		p.y += sin(PI * t) * 40.0 * clampf(slabire, 0.0, 1.0)
		puncte.append(p)
	draw_polyline(puncte, culoare, 1.0, true)


func _deseneaza_pluta(p: Vector2, sub_apa: bool) -> void:
	if sub_apa:
		# Doar vârful roșu, abia la suprafață — semnul de „ACUM".
		draw_circle(p + Vector2(0, 4), 3.0, Color(0.9, 0.25, 0.2))
		return
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -12), p + Vector2(4, -2),
		p + Vector2(0, 4), p + Vector2(-4, -2)]), Color(0.92, 0.28, 0.22))
	draw_line(p + Vector2(-4, -2), p + Vector2(4, -2), Color(0.95, 0.93, 0.85), 2.0)
	draw_line(p + Vector2(0, -12), p + Vector2(0, -18), Color(0.95, 0.93, 0.85), 1.5)


func _deseneaza_puterea() -> void:
	# Bara de aruncare, lângă undiță, cu cele trei zone marcate.
	var r := Rect2(70, size.y - 360, 22, 260)
	draw_rect(r, Color(0, 0, 0, 0.45))
	var praguri := [0.4, 0.75]
	var culori := [Color(0.55, 0.70, 0.62), Color(0.52, 0.62, 0.78), Color(0.72, 0.58, 0.85)]
	var jos := 0.0
	for i in range(3):
		var sus: float = praguri[i] if i < 2 else 1.0
		var y_sus := r.end.y - r.size.y * sus
		var y_jos := r.end.y - r.size.y * jos
		draw_rect(Rect2(r.position.x + 2, y_sus, r.size.x - 4, y_jos - y_sus), Color(culori[i], 0.30))
		jos = sus
	var y := r.end.y - r.size.y * putere
	draw_rect(Rect2(r.position.x - 4, y - 3, r.size.x + 8, 6), Color(1, 0.95, 0.8))
	draw_rect(r, Color(1, 1, 1, 0.5), false, 1.5)
	# Unde va cădea pluta: un cerc pe apă.
	var d := distanta
	distanta = putere
	var tinta := _pozitia_plutei()
	distanta = d
	_elipsa(tinta, 16.0, 5.0, Color(1, 1, 1, 0.5), 1.5)


func _deseneaza_tensiunea() -> void:
	var r := Rect2(size.x - 80, size.y * 0.24, 24, size.y * 0.46)
	draw_rect(r, Color(0, 0, 0, 0.5))
	var t := clampf(firul.tensiune, 0.0, 1.0)
	var c := Color(0.62, 0.80, 0.70).lerp(Color(0.95, 0.70, 0.30), clampf(t * 1.4, 0.0, 1.0))
	if t > 0.78:
		c = Color(0.95, 0.40, 0.30)
	draw_rect(Rect2(r.position.x + 3, r.end.y - r.size.y * t, r.size.x - 6, r.size.y * t), c)
	# Zona de rupere, sus.
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, r.size.y * 0.15), Color(0.9, 0.3, 0.25, 0.22))
	var contur := Color(1, 1, 1, 0.5)
	if firul.faza == Firul.Faza.AVERTIZARE:
		contur = Color(1.0, 0.75, 0.3, 0.6 + 0.4 * sin(_timp * 30.0))
	draw_rect(r, contur, false, 2.0)
	# Progresul: o bară jos, „cât mai e până la mal".
	# Sus, sub antet: jos e acum undița.
	var b := Rect2(size.x * 0.5 - 180, 132, 360, 10)
	draw_rect(b, Color(0, 0, 0, 0.5))
	draw_rect(Rect2(b.position, Vector2(b.size.x * firul.progres, b.size.y)), Color(0.95, 0.85, 0.6))
	draw_rect(b, Color(1, 1, 1, 0.4), false, 1.0)


func _elipsa(c: Vector2, rx: float, ry: float, culoare: Color, grosime: float) -> void:
	var puncte := PackedVector2Array()
	for i in range(25):
		var a := TAU * i / 24.0
		puncte.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	if grosime <= 0.0:
		draw_colored_polygon(puncte, culoare)
	else:
		draw_polyline(puncte, culoare, grosime, true)


# ─────────────────────────────────────────────────────────────
# ECRANUL: antet, indiciu, cartea de captură, jurnalul
# Construite în cod, nu în `.tscn`: sunt câteva etichete, iar jurnalul are oricum
# câte o carte pe specie, făcută dintr-o buclă peste catalog.
# ─────────────────────────────────────────────────────────────

func _construieste_ecranul() -> void:
	var antet := HBoxContainer.new()
	antet.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	antet.offset_left = 18
	antet.offset_right = -18
	antet.offset_top = 14
	antet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(antet)

	_btn_meniu = _buton("Meniu", 120)
	_btn_meniu.pressed.connect(func() -> void: get_tree().change_scene_to_file(SCENA_MENIU))
	antet.add_child(_btn_meniu)

	_lbl_ora = Label.new()
	_lbl_ora.theme_type_variation = &"TitluPergament"
	_lbl_ora.add_theme_font_size_override("font_size", 22)
	_lbl_ora.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	_lbl_ora.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_lbl_ora.add_theme_constant_override("outline_size", 6)
	_lbl_ora.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_ora.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	antet.add_child(_lbl_ora)

	_btn_jurnal = _buton("Jurnal", 170)
	_btn_jurnal.pressed.connect(_comuta_jurnalul)
	antet.add_child(_btn_jurnal)

	_lbl_indiciu = _eticheta_pe_apa(18)
	# Indiciul și mesajele stau SUS, sub antet: jos sunt pontonul și undița.
	_lbl_indiciu.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_lbl_indiciu.offset_left = 200
	_lbl_indiciu.offset_right = -200
	_lbl_indiciu.offset_top = 58
	_lbl_indiciu.offset_bottom = 86
	add_child(_lbl_indiciu)

	_lbl_mesaj = _eticheta_pe_apa(20)
	_lbl_mesaj.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_lbl_mesaj.offset_top = 92
	_lbl_mesaj.offset_left = -400
	_lbl_mesaj.offset_right = 400
	_lbl_mesaj.modulate.a = 0.0
	add_child(_lbl_mesaj)

	_construieste_cartea()
	_construieste_jurnalul()


func _buton(text: String, latime: float) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = &"ButonRubrica"
	b.custom_minimum_size = Vector2(latime, 40)
	b.focus_mode = Control.FOCUS_NONE   # Spațiul e al undiței, nu al butonului
	b.add_theme_font_size_override("font_size", 16)
	return b


func _eticheta_pe_apa(marime: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", marime)
	l.add_theme_color_override("font_color", Color(0.96, 0.93, 0.85))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _construieste_cartea() -> void:
	_card = PanelContainer.new()
	_card.custom_minimum_size = Vector2(380, 0)
	_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_card.grow_vertical = Control.GROW_DIRECTION_BOTH
	_card.visible = false
	add_child(_card)
	var m := MarginContainer.new()
	for latura in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + latura, 22)
	_card.add_child(m)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	m.add_child(col)

	_card_titlu = Label.new()
	_card_titlu.theme_type_variation = &"RubricaPergament"
	_card_titlu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_card_titlu)
	_card_desen = Control.new()
	_card_desen.custom_minimum_size = Vector2(0, 120)
	_card_desen.draw.connect(func() -> void:
		if not specie_curenta.is_empty():
			var lung := 150.0 + 110.0 * Pesti.masa_relativa(specie_curenta, masa_curenta)
			Pesti.deseneaza(_card_desen, specie_curenta, _card_desen.size / 2.0, minf(lung, _card_desen.size.x - 20)))
	col.add_child(_card_desen)
	_card_nume = Label.new()
	_card_nume.theme_type_variation = &"TitluPergament"
	_card_nume.add_theme_font_size_override("font_size", 30)
	_card_nume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_card_nume)
	_card_masa = Label.new()
	_card_masa.theme_type_variation = &"SubtitluPergament"
	_card_masa.add_theme_font_size_override("font_size", 22)
	_card_masa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_card_masa)
	_card_detaliu = Label.new()
	_card_detaliu.add_theme_font_size_override("font_size", 15)
	_card_detaliu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_card_detaliu)
	_card_buton = _buton("Mai arunc o dată", 0)
	_card_buton.pressed.connect(_inchide_cartea)
	col.add_child(_card_buton)


func _arata_cartea() -> void:
	var intrare: Dictionary = _jurnal[specie_curenta["cheie"]]
	if _captura_noua:
		_card_titlu.text = "SPECIE NOUĂ ÎN JURNAL"
	elif _record_nou:
		_card_titlu.text = "RECORD NOU"
	else:
		_card_titlu.text = "AI PRINS"
	_card_nume.text = String(specie_curenta["nume"]).to_upper()
	_card_masa.text = Pesti.scrie_masa(masa_curenta)
	_card_detaliu.text = "Prinși până acum: %d · Cel mai mare: %s" % [int(intrare["prinsi"]), Pesti.scrie_masa(float(intrare["record"]))]
	_card.visible = true
	_card.pivot_offset = _card.size / 2.0
	_card.scale = Vector2.ONE * 0.85
	_card.modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(_card, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(_card, "modulate:a", 1.0, 0.2)
	_card_desen.queue_redraw()
	for i in range(4):
		_unda(_pozitia_plutei(), 12.0 + i * 8.0)


func _inchide_cartea() -> void:
	_card.visible = false
	specie_curenta = {}
	stare = Stare.GATA
	apasat = false
	_actualizeaza_textele()


func _construieste_jurnalul() -> void:
	_jurnal_panou = ColorRect.new()
	(_jurnal_panou as ColorRect).color = Color(0, 0, 0, 0.55)
	_jurnal_panou.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_jurnal_panou.visible = false
	_jurnal_panou.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_jurnal_panou)
	var centru := CenterContainer.new()
	centru.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	centru.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_jurnal_panou.add_child(centru)
	var panou := PanelContainer.new()
	centru.add_child(panou)
	var m := MarginContainer.new()
	for latura in ["left", "right"]:
		m.add_theme_constant_override("margin_" + latura, 20)
	m.add_theme_constant_override("margin_top", 12)
	m.add_theme_constant_override("margin_bottom", 14)
	panou.add_child(m)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	m.add_child(col)
	var antet := HBoxContainer.new()
	col.add_child(antet)
	_jurnal_titlu = Label.new()
	_jurnal_titlu.theme_type_variation = &"TitluPergament"
	_jurnal_titlu.add_theme_font_size_override("font_size", 24)
	_jurnal_titlu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	antet.add_child(_jurnal_titlu)
	var inchide := _buton("Închide", 120)
	inchide.pressed.connect(_comuta_jurnalul)
	antet.add_child(inchide)
	_jurnal_grila = GridContainer.new()
	_jurnal_grila.columns = 4
	_jurnal_grila.add_theme_constant_override("h_separation", 8)
	_jurnal_grila.add_theme_constant_override("v_separation", 8)
	col.add_child(_jurnal_grila)


func _comuta_jurnalul() -> void:
	if stare == Stare.TRAGERE or stare == Stare.INCARCA:
		return
	_jurnal_panou.visible = not _jurnal_panou.visible
	if _jurnal_panou.visible:
		_umple_jurnalul()


## Câte o carte pe specie, din catalog. Necunoscutele: siluetă neagră, „???" și
## indiciul — chiar întrebarea care te aduce înapoi la apă.
func _umple_jurnalul() -> void:
	for c in _jurnal_grila.get_children():
		c.queue_free()
	_jurnal_titlu.text = "JURNALUL PESCARULUI   %d / %d" % [_jurnal.size(), Pesti.CATALOG.size()]
	for s in Pesti.CATALOG:
		var stiut := _jurnal.has(s["cheie"])
		var carte := PanelContainer.new()
		carte.custom_minimum_size = Vector2(226, 0)
		carte.theme_type_variation = &"ChenarPergament"
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 0)
		carte.add_child(col)
		var desen := Control.new()
		desen.custom_minimum_size = Vector2(0, 50)
		desen.draw.connect(func() -> void:
			Pesti.deseneaza(desen, s, desen.size / 2.0, 92.0, not stiut))
		col.add_child(desen)
		var nume := Label.new()
		nume.theme_type_variation = &"TitluPergament"
		nume.add_theme_font_size_override("font_size", 16)
		nume.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nume.text = String(s["nume"]).to_upper() if stiut else "???"
		col.add_child(nume)
		var det := Label.new()
		det.add_theme_font_size_override("font_size", 13)
		det.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		det.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		det.custom_minimum_size = Vector2(0, 34)
		if stiut:
			var i: Dictionary = _jurnal[s["cheie"]]
			det.text = "Prinși: %d · Record: %s\n%s" % [int(i["prinsi"]), Pesti.scrie_masa(float(i["record"])), Pesti.indiciu(s)]
		else:
			det.text = Pesti.indiciu(s)
		col.add_child(det)
		_jurnal_grila.add_child(carte)


func _arata_mesaj(text: String) -> void:
	_lbl_mesaj.text = text
	_lbl_mesaj.modulate.a = 1.0
	_mesaj_ceas = 3.0


func _actualizeaza_textele() -> void:
	if _lbl_ora == null:
		return
	_lbl_ora.text = "%s · %s" % [Pesti.TITLU_MOMENT[moment()], Pesti.TITLU_VREME[vreme]]
	_btn_jurnal.text = "Jurnal %d / %d" % [_jurnal.size(), Pesti.CATALOG.size()]
	match stare:
		Stare.GATA:
			_lbl_indiciu.text = "Ține apăsat ca să arunci. Mai departe mușcă pești mai rari."
		Stare.INCARCA:
			_lbl_indiciu.text = "Dă drumul când bara e unde vrei."
		Stare.ZBOR:
			_lbl_indiciu.text = ""
		Stare.ASTEAPTA:
			_lbl_indiciu.text = "Așteaptă. Lovește abia când pluta se scufundă, nu la ciupituri. (%s)" % Pesti.ZONE[zona]
		Stare.TRAGERE:
			_lbl_indiciu.text = "Ține apăsat ca să tragi. Când apa se încrețește, dă drumul."
		Stare.CAPTURA:
			_lbl_indiciu.text = ""

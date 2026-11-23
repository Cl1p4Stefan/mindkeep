extends Node
## VERIFICAREA IAZULUI — pescuitul, al patrulea mod.
##
## Se rulează fără fereastră:
##   "$GODOT" --headless --path . res://tools/verificari/verifica_iazul.tscn
##
## Ce bate:
##   1. CATALOGUL — chei distincte, câmpuri cu valori cunoscute, ȘI promisiunea
##      din antetul lui `pesti.gd`: oriunde și oricând arunci, ceva mușcă; și
##      fiecare condiție (noaptea, amurgul, ceața, ploaia, departele) are o
##      specie care apare NUMAI acolo. Fără a doua, vremea ar fi decor.
##   2. FIRUL — fiecare specie, prin sute de lupte, cu trei jucători închipuiți.
##      Cel ATENT (dă drumul la avertizare și când firul e prea întins) trebuie
##      să câștige aproape mereu; cel care ȚINE APĂSAT tot timpul trebuie să
##      piardă peștii puternici; cel care se uită DOAR LA TENSIUNE, nu și la
##      semne, trebuie să piardă vizibil mai des decât cel atent la cei mai
##      puternici. Adică: priceperea contează, și contează CITIREA semnului, nu
##      doar dozarea. Plus un tabel cu cât durează o luptă (măsurătoare).
##   3. SCENA JUCATĂ — aruncare, ciupituri, mușcătură, tragere, captură, cu
##      timpul dat de mână prin `pas()`; plus lovitura prea devreme și
##      mușcătura ratată.
##      Și SUNETELE: fiecare se aude fără să taie, buclele se leagă fără
##      pocnet, iar în partida jucată se aude ce trebuie, când trebuie —
##      scârțâitul la FIECARE avertizare, greierii noaptea, ploaia când plouă.
##   4. SALVAREA — jurnalul dus și întors, cu specii necunoscute și valori strâmbe.
##   5. MĂSURĂTORILE — meniul cu patru pagini și jurnalul plin încap în 1152 × 648.
##   6. FONTURILE — fiecare caracter din texte, în Cinzel, Alegreya și implicit.
##
## La ieșire Godot scrie „N ObjectDB instances were leaked" (8-14, după ce
## sunete prind cadrul de închidere) și „4 resources
## still in use". NU e o scurgere a iazului: sunt sunetele iazului și cel de
## captură, care încă sună în cadrul în care verificarea închide jocul (le
## numește `--verbose`). Codul de ieșire e 0.

const DOSAR := "user://verificare_iazul/"
const SCENA_IAZ := "res://scenes/iazul/iazul.tscn"
const SCENA_MENIU := "res://scenes/meniu/meniu.tscn"
const IAZUL := preload("res://scenes/iazul/iazul.gd")
const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"
const PANZA := Vector2(1152, 648)

var _texte := {}   # tot ce s-a scris pe ecran, pentru FONTURILE


func _ready() -> void:
	print("VERIFICAREA IAZULUI")
	Arhiva.dosar = DOSAR
	if not DirAccess.dir_exists_absolute(DOSAR):
		DirAccess.make_dir_recursive_absolute(DOSAR)
	_drumul.call_deferred()


func _drumul() -> void:
	var bun := true
	bun = _catalogul() and bun
	bun = _firul() and bun
	bun = await _scena() and bun
	bun = _salvarea() and bun
	bun = await _masuratorile() and bun
	bun = _fonturile() and bun
	print("\n%s" % ("TOATE VERIFICĂRILE AU TRECUT" if bun else "AU PICAT VERIFICĂRI"))
	get_tree().quit(0 if bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. CATALOGUL
# ─────────────────────────────────────────────────────────────

func _catalogul() -> bool:
	print("\n  1. CATALOGUL")
	var bun := true
	var chei := {}
	var strambe: Array[String] = []
	for s in Pesti.CATALOG:
		var cheie: String = s["cheie"]
		if chei.has(cheie):
			strambe.append(cheie + " (dublă)")
		chei[cheie] = true
		for z in s["zone"]:
			if int(z) < 0 or int(z) >= Pesti.ZONE.size():
				strambe.append(cheie + " zona %s" % z)
		if (s["zone"] as Array).is_empty():
			strambe.append(cheie + " fără zone")
		for m in s["momente"]:
			if not Pesti.MOMENTE.has(m):
				strambe.append(cheie + " moment " + String(m))
		for v in s["vreme"]:
			if not Pesti.VREMI.has(v):
				strambe.append(cheie + " vreme " + String(v))
		var masa: Array = s["masa"]
		if not (float(masa[0]) > 0.0 and float(masa[0]) < float(masa[1])):
			strambe.append(cheie + " masa")
		if int(s["forta"]) < 1 or int(s["forta"]) > 5 or float(s["frecventa"]) <= 0.0:
			strambe.append(cheie + " forta/frecventa")
		_texte[s["nume"]] = true
		_texte[String(s["nume"]).to_upper()] = true
		_texte[Pesti.indiciu(s)] = true
	bun = _verdict("fiecare specie are câmpuri cunoscute", strambe.is_empty(), _primele(strambe, 6)) and bun

	# Oriunde și oricând, ceva mușcă.
	var goale: Array[String] = []
	for z in range(Pesti.ZONE.size()):
		for m in Pesti.MOMENTE:
			for v in Pesti.VREMI:
				if Pesti.potrivite(z, m, v).is_empty():
					goale.append("%d/%s/%s" % [z, m, v])
	bun = _verdict("în orice zonă, la orice oră, pe orice vreme mușcă ceva", goale.is_empty(), _primele(goale, 6)) and bun

	# Fiecare condiție are o specie care o CERE.
	var fara: Array[String] = []
	for m in ["zori", "amurg", "noapte"]:
		if not Pesti.CATALOG.any(func(s): return (s["momente"] as Array).has(m)):
			fara.append(m)
	for v in ["ceata", "ploaie"]:
		if not Pesti.CATALOG.any(func(s): return (s["vreme"] as Array).has(v)):
			fara.append(v)
	if not Pesti.CATALOG.any(func(s): return s["zone"] == [2]):
		fara.append("departe")
	bun = _verdict("fiecare condiție are o specie a ei", fara.is_empty(), _primele(fara, 6)) and bun

	# Fiecare specie se poate prinde: undeva are măcar 2% șanse.
	var rngul := RandomNumberGenerator.new()
	rngul.seed = 11
	var rare: Array[String] = []
	for s in Pesti.CATALOG:
		var cea_mai_buna := 0.0
		for z in s["zone"]:
			for m in Pesti.MOMENTE:
				for v in Pesti.VREMI:
					var lista := Pesti.potrivite(int(z), m, v)
					if not lista.has(s):
						continue
					var total := 0.0
					for x in lista:
						total += float(x["frecventa"])
					cea_mai_buna = maxf(cea_mai_buna, float(s["frecventa"]) / total)
		if cea_mai_buna < 0.02:
			rare.append("%s %.1f%%" % [s["cheie"], cea_mai_buna * 100])
	bun = _verdict("fiecare specie are undeva măcar 2% șanse", rare.is_empty(), _primele(rare, 6)) and bun

	# Masa trasă stă în interval.
	var afara := 0
	for s in Pesti.CATALOG:
		for i in range(200):
			var m := Pesti.trage_masa(s, rngul)
			if m < float(s["masa"][0]) or m > float(s["masa"][1]):
				afara += 1
	bun = _verdict("masa trasă e mereu în intervalul speciei", afara == 0, "%d în afară" % afara) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 2. FIRUL
# ─────────────────────────────────────────────────────────────

enum Jucator { ATENT, TINE_APASAT, DOAR_TENSIUNE }

const DT := 1.0 / 60.0
const LUPTE := 300


## Cât de târziu vede un om ce se întâmplă pe ecran. Fără întârziere, jucătorii
## închipuiți ar fi roboți, iar verdictele n-ar spune nimic despre unul adevărat:
## prima rulare a dat 100% și jucătorului care nu citește semnul, fiindcă el
## dădea drumul în același cadru în care bara trecea de prag.
const REACTIE := 0.22


## Joacă o luptă; întoarce [prins?, secunde]. Jucătorul hotărăște după ce a
## fost pe ecran acum `REACTIE` secunde, nu după ce e acum.
func _lupta(s: Dictionary, zona: int, masa_rel: float, jucator: int, rng: RandomNumberGenerator) -> Array:
	var f := Firul.new(int(s["forta"]), zona, masa_rel, rng)
	var t := 0.0
	var apasat := true
	var intarziere := int(round(REACTIE / DT))
	var trecut: Array = []   # [tensiune, semn] pe fiecare cadru
	while not f.rupt and not f.prins and t < 300.0:
		trecut.append([f.tensiune, f.faza != Firul.Faza.LINISTE])
		var vazut: Array = trecut[maxi(0, trecut.size() - 1 - intarziere)]
		var tensiune: float = vazut[0]
		var semn: bool = vazut[1]
		match jucator:
			Jucator.TINE_APASAT:
				apasat = true
			Jucator.DOAR_TENSIUNE:
				# Histerezis, ca un om: dă drumul la 0,85, reia la 0,55.
				if tensiune > 0.85:
					apasat = false
				elif tensiune < 0.55:
					apasat = true
			Jucator.ATENT:
				if semn or tensiune > 0.85:
					apasat = false
				elif tensiune < 0.55:
					apasat = true
		f.pas(DT, apasat)
		t += DT
	return [f.prins, t]


func _firul() -> bool:
	print("\n  2. FIRUL (%d lupte pe specie și jucător, în zona cea mai depărtată, cu peștele cel mai mare)" % LUPTE)
	var bun := true
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var atent_slab: Array[String] = []
	var apasat_castiga: Array[String] = []
	var tensiunea_ajunge: Array[String] = []
	var prea_lungi: Array[String] = []
	print("    %-10s %5s %8s %8s %8s %8s" % ["specia", "forța", "atent", "apasat", "tensiune", "durata"])
	for s in Pesti.CATALOG:
		var zona: int = (s["zone"] as Array).max()
		var rate := [0, 0, 0]
		var durata := 0.0
		for j in [Jucator.ATENT, Jucator.TINE_APASAT, Jucator.DOAR_TENSIUNE]:
			for i in range(LUPTE):
				var r := _lupta(s, zona, 1.0, j, rng)
				if r[0]:
					rate[j] += 1
					if j == Jucator.ATENT:
						durata += float(r[1])
		var atent := float(rate[0]) / LUPTE
		var apasat := float(rate[1]) / LUPTE
		var tens := float(rate[2]) / LUPTE
		var medie := durata / maxf(1.0, rate[0])
		print("    %-10s %5d %7.0f%% %7.0f%% %7.0f%% %7.1fs" % [s["cheie"], s["forta"], atent * 100, apasat * 100, tens * 100, medie])
		if atent < 0.95:
			atent_slab.append("%s %.0f%%" % [s["cheie"], atent * 100])
		if int(s["forta"]) >= 3 and apasat > 0.10:
			apasat_castiga.append("%s %.0f%%" % [s["cheie"], apasat * 100])
		if int(s["forta"]) >= 4 and tens > atent - 0.25:
			tensiunea_ajunge.append("%s %.0f%% vs %.0f%%" % [s["cheie"], tens * 100, atent * 100])
		if medie > 45.0:
			prea_lungi.append("%s %.0fs" % [s["cheie"], medie])
	bun = _verdict("jucătorul atent prinde ≥ 95% din fiecare specie", atent_slab.is_empty(), _primele(atent_slab, 6)) and bun
	bun = _verdict("cine ține apăsat pierde peștii de forță ≥ 3", apasat_castiga.is_empty(), _primele(apasat_castiga, 6)) and bun
	bun = _verdict("la forță ≥ 4, citirea semnului face diferența", tensiunea_ajunge.is_empty(), _primele(tensiunea_ajunge, 6)) and bun
	bun = _verdict("nicio luptă nu ține în medie peste 45 s", prea_lungi.is_empty(), _primele(prea_lungi, 6)) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 3. SCENA JUCATĂ
# ─────────────────────────────────────────────────────────────

func _scena() -> bool:
	print("\n  3. SCENA JUCATĂ")
	var bun := true
	IAZUL.din_dictionar({})
	var iaz: Control = load(SCENA_IAZ).instantiate()
	add_child(iaz)
	await get_tree().process_frame
	iaz.set_process(false)   # timpul îl dă verificarea
	iaz.rng.seed = 99

	# Aruncarea: ține apăsat 1,0 s → departe? Puterea urcă cu 0,85/s.
	iaz.la_apasare()
	bun = _sunetele_construite() and bun
	bun = _verdict("la iaz muzica tace", Muzica.piesa_curenta == -1) and bun
	bun = _verdict("apăsarea începe aruncarea", iaz.stare == iaz.Stare.INCARCA) and bun
	for i in range(60):
		iaz.pas(1.0 / 60.0)
	iaz.la_eliberare()
	bun = _verdict("eliberarea aruncă", iaz.stare == iaz.Stare.ZBOR, "zona %d, putere %.2f" % [iaz.zona, iaz.distanta]) and bun
	bun = _verdict("după o secundă de încărcare, pluta merge departe", iaz.zona == 2) and bun
	for i in range(60):
		iaz.pas(1.0 / 60.0)
	bun = _verdict("pluta cade în apă și se așteaptă", iaz.stare == iaz.Stare.ASTEAPTA) and bun

	# Așteaptă mușcătura, numărând ciupiturile.
	var ciupituri := 0
	var era := false
	var t := 0.0
	while iaz._ceas_muscatura <= 0.0 and t < 60.0:
		iaz.pas(0.02)
		t += 0.02
		var acum: bool = iaz._ceas_ciupitura > 0.0
		if acum and not era:
			ciupituri += 1
		era = acum
	bun = _verdict("vine o mușcătură", iaz._ceas_muscatura > 0.0, "după %.1f s, %d ciupituri" % [t, ciupituri]) and bun
	var specia: Dictionary = iaz.specie_curenta
	bun = _verdict("peștele de la momeală e din zona aruncării", (specia["zone"] as Array).has(iaz.zona), String(specia.get("cheie", ""))) and bun

	iaz.la_apasare()
	bun = _verdict("lovitura la timp începe tragerea", iaz.stare == iaz.Stare.TRAGERE) and bun
	t = 0.0
	var avertizari := 0
	var faza_inainte := -1
	var scartaituri_inainte: int = iaz.sunete.auzite.count("scartait")
	while iaz.stare == iaz.Stare.TRAGERE and t < 200.0:
		var f: Firul = iaz.firul
		if int(f.faza) != faza_inainte and f.faza == Firul.Faza.AVERTIZARE:
			avertizari += 1
		faza_inainte = int(f.faza)
		var semn: bool = f.faza != Firul.Faza.LINISTE
		if semn or f.tensiune > 0.85:
			iaz.apasat = false
		elif f.tensiune < 0.55:
			iaz.apasat = true
		iaz.pas(1.0 / 60.0)
		t += 1.0 / 60.0
	bun = _verdict("peștele e prins", iaz.stare == iaz.Stare.CAPTURA, "%.1f s" % t) and bun
	bun = _verdict("cartea de captură se vede", iaz._card.visible) and bun
	var auzite: Array[String] = iaz.sunete.auzite
	var lipsa := []
	for cheie in ["arunca", "plici", "muscatura", "clic", "stropi"]:
		if not auzite.has(cheie):
			lipsa.append(cheie)
	bun = _verdict("o captură se aude de la aruncare la stropi", lipsa.is_empty(), "lipsesc " + str(lipsa)) and bun
	bun = _verdict("ordinea: aruncare, plută, mușcătură, captură",
		auzite.find("arunca") < auzite.find("plici") and auzite.find("plici") < auzite.find("muscatura")
		and auzite.rfind("stropi") == auzite.size() - 1, str(auzite.slice(0, 6))) and bun
	var scartaituri: int = auzite.count("scartait") - scartaituri_inainte
	bun = _verdict("scârțâie la fiecare avertizare, nu altfel", scartaituri == avertizari,
		"%d avertizări, %d scârțâituri, %d frâne" % [avertizari, scartaituri, auzite.count("frana")]) and bun
	bun = _verdict("jurnalul are o specie", IAZUL.cate_specii_prinse() == 1) and bun
	bun = _verdict("prima captură e SPECIE NOUĂ", iaz._card_titlu.text.begins_with("SPECIE NOUĂ")) and bun
	for l in [iaz._card_titlu, iaz._card_nume, iaz._card_masa, iaz._card_detaliu, iaz._lbl_ora, iaz._btn_jurnal]:
		_texte[l.text] = true
	var pe_disc := FileAccess.get_file_as_string(Arhiva.cale_catre(Arhiva.NUME_PERMANENT))
	bun = _verdict("captura e scrisă pe disc pe loc", pe_disc.contains("\"iazul\"") and pe_disc.contains(String(specia["cheie"]))) and bun
	iaz._inchide_cartea()
	bun = _verdict("după carte se poate arunca din nou", iaz.stare == iaz.Stare.GATA) and bun

	# Lovitura prea devreme: aruncă aproape, așteaptă PRIMA ciupitură, lovește.
	var speriat := false
	for incercare in range(20):
		iaz.la_apasare()
		iaz.pas(0.1)
		iaz.la_eliberare()
		for i in range(60):
			iaz.pas(1.0 / 60.0)
		t = 0.0
		while iaz._ceas_ciupitura <= 0.0 and iaz._ceas_muscatura <= 0.0 and t < 60.0:
			iaz.pas(0.02)
			t += 0.02
		if iaz._ceas_ciupitura > 0.0:
			iaz.la_apasare()
			speriat = iaz.specie_curenta.is_empty() and iaz.stare == iaz.Stare.ASTEAPTA
			break
		iaz.la_apasare()   # a venit direct mușcătura; o tragem și o lăsăm
		iaz.firul.tensiune = 2.0
		iaz.pas(0.02)
	bun = _verdict("lovitura la ciupitură sperie peștele, pluta rămâne", speriat) and bun
	_texte[iaz._lbl_mesaj.text] = true

	# Mușcătura ratată: așteaptă mușcătura și nu face nimic.
	t = 0.0
	while iaz._ceas_muscatura <= 0.0 and t < 60.0:
		iaz.pas(0.02)
		t += 0.02
	for i in range(60):
		iaz.pas(1.0 / 60.0)
	bun = _verdict("mușcătura ratată: peștele pleacă, pluta rămâne", iaz.specie_curenta.is_empty() and iaz.stare == iaz.Stare.ASTEAPTA) and bun
	_texte[iaz._lbl_mesaj.text] = true

	# Un clic în liniște strânge firul.
	iaz._pleaca_pestele(10.0)
	iaz.la_apasare()
	bun = _verdict("un clic fără pește strânge firul", iaz.stare == iaz.Stare.GATA) and bun

	# Firul rupt, adus de mână: un crap pe cârlig și tensiunea peste prag.
	iaz.stare = iaz.Stare.ASTEAPTA
	iaz.specie_curenta = Pesti.specie("crap")
	iaz._incepe_tragerea()
	iaz.firul.tensiune = 2.0
	iaz.pas(0.02)
	bun = _verdict("firul rupt se aude", iaz.stare == iaz.Stare.GATA and iaz.sunete.auzite.back() == "rupt", str(iaz.sunete.auzite.slice(-3))) and bun

	# Ziua trece și vremea se schimbă.
	var momente := {}
	var vremi := {}
	# O zi întreagă, cât spune `ZI_SECUNDE` — nu un număr scris de mână, care
	# a rămas 800 când ziua a urcat la 900 și trecea doar din noroc.
	var lungime := int(IAZUL.ZI_SECUNDE)
	for i in range(lungime):
		iaz.pas(1.0)
		momente[iaz.moment()] = true
		vremi[iaz.vreme] = true
	bun = _verdict("într-o zi (%d s) trec toate momentele" % lungime, momente.size() == Pesti.MOMENTE.size(), str(momente.keys())) and bun
	bun = _verdict("și se schimbă vremea", vremi.size() >= 2, str(vremi.keys())) and bun
	bun = _ambianta(iaz) and bun
	for m in Pesti.MOMENTE:
		for v in Pesti.VREMI:
			_texte["%s · %s" % [Pesti.TITLU_MOMENT[m], Pesti.TITLU_VREME[v]]] = true
	for stare in iaz.Stare.values():
		iaz.stare = stare
		iaz._actualizeaza_textele()
		_texte[iaz._lbl_indiciu.text] = true
	_texte["Cerul s-a limpezit. Se lasă ceața peste apă. A început să plouă. Firul s-a rupt. RECORD NOU AI PRINS Închide Meniu Mai arunc o dată JURNALUL PESCARULUI ??? Prinși: Record:"] = true
	iaz.queue_free()
	await get_tree().process_frame
	return bun


## Fiecare sunet sintetizat: se aude (vârf ≥ 0,2), nu taie (≤ 1, fără NaN),
## iar buclele se leagă: saltul de la ultimul eșantion la primul nu e mai
## mare decât cel mai mare salt dintre doi vecini DIN buclă. Nu „aproape de
## zero": ploaia e zgomot, deci doi vecini oarecare sar și cu 0,13, iar prima
## scriere a verdictului a picat pe o cusătură perfect bună.
func _sunetele_construite() -> bool:
	var bun := true
	var strambe := []
	var cusaturi := []
	var inceput := Time.get_ticks_msec()
	for cheie: String in SuneteIaz.EFECTE.keys() + SuneteIaz.AMBIANTA.keys():
		var s := SuneteIaz.esantioane(cheie)
		var varf := 0.0
		var nan := false
		for x in s:
			if is_nan(x):
				nan = true
			varf = maxf(varf, absf(x))
		if s.is_empty() or nan or varf > 1.0 or varf < 0.2:
			strambe.append("%s (vârf %.2f, %d eșantioane)" % [cheie, varf, s.size()])
		if SuneteIaz.AMBIANTA.has(cheie):
			var cel_mai_mare := 0.0
			for i in range(1, s.size()):
				cel_mai_mare = maxf(cel_mai_mare, absf(s[i] - s[i - 1]))
			var cusatura := absf(s[0] - s[s.size() - 1])
			if cusatura > cel_mai_mare:
				cusaturi.append("%s (%.3f > %.3f)" % [cheie, cusatura, cel_mai_mare])
	print("    (sinteza tuturor: %d ms)" % (Time.get_ticks_msec() - inceput))
	bun = _verdict("toate %d sunetele se aud și nu taie" % (SuneteIaz.EFECTE.size() + SuneteIaz.AMBIANTA.size()), strambe.is_empty(), _primele(strambe, 6)) and bun
	bun = _verdict("buclele de ambianță se leagă fără pocnet", cusaturi.is_empty(), _primele(cusaturi, 6)) and bun
	return bun


## Ambianța urmează ora și vremea. Vremea e oprită pe loc (ceasul ei e pus
## departe), altfel s-ar putea schimba singură în mijlocul probei.
func _ambianta(iaz: Control) -> bool:
	var bun := true
	iaz._ceas_vreme = 10000.0
	# Orele se iau din `ORAR`, nu se scriu de mână: când s-a lungit ziua,
	# „100 = zi” a devenit zori și proba ar fi bătut alt moment decât scrie.
	var zi := _mijlocul_momentului("zi")
	var noapte := _mijlocul_momentului("noapte")
	var cazuri := [[zi, "senin", 0.0, 0.0], [noapte, "senin", 1.0, 0.0], [noapte, "ploaie", 0.0, 1.0], [zi, "ploaie", 0.0, 1.0]]
	var gresite := []
	for c in cazuri:
		iaz.ora = c[0]
		iaz.vreme = c[1]
		for i in range(10):
			iaz.pas(1.0)
		var greieri: float = iaz.sunete.nivel_ambianta("greieri")
		var ploaie: float = iaz.sunete.nivel_ambianta("ploaie")
		var apa: float = iaz.sunete.nivel_ambianta("apa")
		if not (is_equal_approx(greieri, c[2]) and is_equal_approx(ploaie, c[3]) and is_equal_approx(apa, 1.0)):
			gresite.append("%s/%s: greieri %.2f, ploaie %.2f, apă %.2f" % [iaz.moment(), c[1], greieri, ploaie, apa])
	bun = _verdict("greierii noaptea, ploaia când plouă, apa mereu", gresite.is_empty(), _primele(gresite, 4)) and bun
	return bun


func _mijlocul_momentului(cheie: String) -> float:
	var orar: Array = IAZUL.ORAR
	for i in range(orar.size()):
		if orar[i][1] == cheie:
			var capat: float = orar[i + 1][0] if i + 1 < orar.size() else IAZUL.ZI_SECUNDE
			return (float(orar[i][0]) + capat) / 2.0
	return 0.0


# ─────────────────────────────────────────────────────────────
# 4. SALVAREA
# ─────────────────────────────────────────────────────────────

func _salvarea() -> bool:
	print("\n  4. SALVAREA")
	var bun := true
	IAZUL.din_dictionar({"jurnal": {
		"crap": {"prinsi": 3, "record": 7.25},
		"balaur": {"prinsi": 1, "record": 99.0},
		"somn": {"prinsi": "multi", "record": "mare"},
		"biban": "nu e dicționar",
		"lin": {"prinsi": 0, "record": 1.0},
	}})
	bun = _verdict("se păstrează doar intrările bune", IAZUL.cate_specii_prinse() == 1, str(IAZUL._jurnal.keys())) and bun
	var dus := IAZUL.spre_dictionar()
	IAZUL.din_dictionar({})
	IAZUL.din_dictionar(JSON.parse_string(JSON.stringify(dus)))
	bun = _verdict("jurnalul se întoarce la fel prin JSON", IAZUL.spre_dictionar() == dus or JSON.stringify(IAZUL.spre_dictionar()) == JSON.stringify(dus)) and bun
	bun = _verdict("recordul trece întreg", is_equal_approx(float(IAZUL._jurnal["crap"]["record"]), 7.25)) and bun
	bun = _verdict("Arhiva îl pune în permanent.json", Arhiva._date_permanente().has("iazul")) and bun
	IAZUL.din_dictionar({"jurnal": 5})
	bun = _verdict("un jurnal strâmb dă jurnal gol", IAZUL.cate_specii_prinse() == 0) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 5. MĂSURĂTORILE
# ─────────────────────────────────────────────────────────────

func _masuratorile() -> bool:
	print("\n  5. MĂSURĂTORILE (pe pânza de %d × %d)" % [PANZA.x, PANZA.y])
	var bun := true
	var meniu: Control = load(SCENA_MENIU).instantiate()
	add_child(meniu)
	await get_tree().process_frame
	var cere: Vector2 = meniu.get_node("Margini").get_combined_minimum_size()
	bun = _verdict("meniul cu patru pagini încape", cere.x <= PANZA.x and cere.y <= PANZA.y, "cere %d × %d" % [cere.x, cere.y]) and bun
	bun = _verdict("pagina PESCUIT există și are buton", meniu.get_node_or_null("%ButonIaz") != null) and bun
	for l in meniu.find_children("*", "Label", true, false):
		_texte[(l as Label).text] = true
	for b in meniu.find_children("*", "Button", true, false):
		_texte[(b as Button).text] = true
	meniu.queue_free()
	bun = await _imaginile() and bun

	# Jurnalul plin: toate speciile prinse, deci cele mai lungi rânduri.
	var plin := {}
	for s in Pesti.CATALOG:
		plin[s["cheie"]] = {"prinsi": 123, "record": float(s["masa"][1])}
	IAZUL.din_dictionar({"jurnal": plin})
	var iaz: Control = load(SCENA_IAZ).instantiate()
	add_child(iaz)
	await get_tree().process_frame
	iaz.set_process(false)
	iaz._comuta_jurnalul()
	await get_tree().process_frame
	await get_tree().process_frame
	var panou: Control = iaz._jurnal_grila.get_parent().get_parent().get_parent()
	# Se citește `size`, nu minimul: cărțile au text cu autowrap (vezi excepția
	# scrisă în CLAUDE.md, la „un ecran se măsoară pe cât CERE").
	bun = _verdict("jurnalul plin încape", panou.size.x <= PANZA.x and panou.size.y <= PANZA.y, "%d × %d" % [panou.size.x, panou.size.y]) and bun
	for l in iaz._jurnal_grila.find_children("*", "Label", true, false):
		_texte[(l as Label).text] = true
	_texte[iaz._jurnal_titlu.text] = true
	iaz.queue_free()
	IAZUL.din_dictionar({})
	await get_tree().process_frame
	return bun


## Imaginile pictate: toate cinci se încarcă, iar geometria pe care o cer
## ține. Pluta aruncată aproape cade pe apă, NU pe ponton; cea aruncată
## departe stă sub linia apei din fundal, nu pe dealuri; și peștele tras la mal
## se oprește înaintea muchiei pontonului. Asta nu se vede fără fereastră —
## dar numerele care o hotărăsc, da.
func _imaginile() -> bool:
	var bun := true
	var iaz: Control = load(SCENA_IAZ).instantiate()
	add_child(iaz)
	await get_tree().process_frame
	iaz.set_process(false)
	iaz.size = PANZA
	var lipsa := []
	for cheie in IAZUL.IMAGINI:
		if not IAZUL._imagini.has(cheie):
			lipsa.append(cheie)
	bun = _verdict("cele %d imagini se încarcă" % IAZUL.IMAGINI.size(), lipsa.is_empty(), "lipsesc " + str(lipsa)) and bun
	var orizont: float = iaz._orizont()
	var muchie: float = iaz._muchia_pontonului()
	var strambe := []
	for abatere in [-1.0, 0.0, 1.0]:
		iaz._abatere = abatere
		iaz.distanta = 0.0
		var aproape: Vector2 = iaz._pozitia_plutei()
		iaz.distanta = 1.0
		var departe: Vector2 = iaz._pozitia_plutei()
		if not (aproape.y < muchie - 10.0 and departe.y > orizont + 8.0 and departe.y < aproape.y - 60.0):
			strambe.append("abatere %.0f: aproape %.0f, departe %.0f" % [abatere, aproape.y, departe.y])
	bun = _verdict("pluta cade pe apă, între linia apei și ponton", strambe.is_empty(),
		"apa %.0f, ponton %.0f; %s" % [orizont, muchie, _primele(strambe, 3)]) and bun
	iaz.queue_free()
	await get_tree().process_frame
	return bun


# ─────────────────────────────────────────────────────────────
# 6. FONTURILE
# ─────────────────────────────────────────────────────────────

func _fonturile() -> bool:
	print("\n  6. FONTURILE")
	var bun := true
	var fonturi := {"Cinzel": load(CALE_CINZEL), "Alegreya": load(CALE_ALEGREYA), "implicit": ThemeDB.fallback_font}
	var caractere := {}
	for t in _texte:
		for ch in String(t):
			caractere[ch] = true
	for nume in fonturi:
		var font: Font = fonturi[nume]
		var lipsa: Array[String] = []
		for ch in caractere:
			var cod: int = String(ch).unicode_at(0)
			if cod < 32:
				continue
			if not font.has_char(cod):
				lipsa.append("„%s” (U+%04X)" % [ch, cod])
		bun = _verdict("%s are toate caracterele (%d)" % [nume, caractere.size()], lipsa.is_empty(), _primele(lipsa, 8)) and bun
	return bun


# ─────────────────────────────────────────────────────────────

func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-56s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array, cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(String(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

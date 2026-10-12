extends Node
## VERIFICAREA SALVĂRII — starea ajunge pe disc și se întoarce întreagă?
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_salvarea.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ, DEȘI SERIALIZAREA ERA SCRISĂ DE TREI LUNI
##
## `spre_dictionar()` / `din_dictionar()` existau la `Tezaur`, `Sac` și
## `Expeditie` cu mult înainte de pasul 8 — dar nimeni nu le pusese niciodată
## cap la cap. Un drum dus-întors are patru locuri în care se poate rupe, și
## niciunul nu se vede din citirea codului:
##
##   1. CÂMP UITAT. Adaugi `nod_nerezolvat` în stare și uiți un capăt. Jocul
##      merge perfect până la prima reîncărcare, și atunci pierde un lucru.
##   2. TIPUL, nu valoarea. JSON întoarce TOATE numerele ca float. Un `int()`
##      uitat trece neobservat luni de zile, fiindcă în GDScript `3 == 3.0` e
##      `true` — și crapă abia când numărul ajunge să indexeze un Array.
##   3. FIȘIER STRICAT. Un JSON tăiat la mijloc nu e o ipoteză: e ce rămâne pe
##      disc dacă se închide calculatorul în timpul scrierii.
##   4. VERSIUNEA. Un save din viitor nu trebuie citit, iar unul vechi trebuie.
##
## ─────────────────────────────────────────────────────────────
## SCRIE DOAR ÎN DOSARUL EI
##
## `Arhiva.dosar` se mută pe `user://verificare_salvare/` pe prima linie, și
## dosarul se golește la început și la final. O verificare care poate suprascrie
## save-ul adevărat e o verificare pe care n-o rulezi niciodată.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## Nimic despre ce se vede pe ecran. Că harta redeschide un nod nerezolvat și că
## meniul scrie „Continua expeditia" sunt întrebări de ecran — ce se poate
## verifica aici e ce se poate verifica în DATE: că nodul nerezolvat ajunge pe
## disc, și că fișa lui spune dacă e reluabil. Restul se vede cu ochiul.

const PRACTICE := preload("res://scenes/practice/practice.gd")
const TRIVIA := preload("res://scenes/trivia/trivia.gd")

## Dosarul de probă. Sub `user://`, ca să nu ceară drepturi și ca să dispară cu
## tot cu datele jocului dacă vreodată ștergi dosarul lui.
const DOSAR := "user://verificare_salvare/"

## Sămânța expediției de probă. Fixă: dacă verificarea pică, trebuie să pice la
## fel a doua oară.
const SAMANTA := 4242

## Câte noduri se parcurg înainte de salvare. Trei, nu unul: vrem `parcurse` cu
## mai multe intrări, ca o listă citită pe dos sau trunchiată să se vadă.
const PASI := 3


func _ready() -> void:
	print("VERIFICAREA SALVĂRII (drumul stare → disc → stare)")
	print("Dosar de probă: %s" % DOSAR)

	Arhiva.dosar = DOSAR
	_goleste_dosarul()

	var tot_bun := true
	tot_bun = _dus_intors() and tot_bun
	tot_bun = _tipurile() and tot_bun
	tot_bun = _chei_lipsa() and tot_bun
	tot_bun = _chei_in_plus() and tot_bun
	tot_bun = _fisiere_stricate() and tot_bun
	tot_bun = _doua_stricari_la_rand() and tot_bun
	tot_bun = _versiunea() and tot_bun
	tot_bun = _atomicitatea() and tot_bun
	tot_bun = _nodul_nerezolvat() and tot_bun
	tot_bun = _duratele_sacului() and tot_bun
	tot_bun = _expeditia_incheiata() and tot_bun

	_goleste_dosarul()

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"save-ul duce și aduce tot" if tot_bun else "CEVA SE PIERDE PE DRUM"])
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. DUS-ÎNTORS, CÂMP CU CÂMP
# ─────────────────────────────────────────────────────────────

## Cea mai importantă secțiune, fiindcă e singura care ar prinde un câmp uitat.
##
## Starea se construiește BOGAT dinadins: o expediție pornită, câțiva noduri
## parcurși, PV schimbat, Monede strânse și cheltuite, o putere cumpărată,
## recorduri, Fragmente în tezaur, bilete în amândouă felurile de sac, progres
## în Antrenament. Un câmp rămas pe valoarea implicită ar fi trecut verificarea
## fără o vorbă — zero scris pe disc se citește ca zero.
func _dus_intors() -> bool:
	print("\n  1. DUS-ÎNTORS (stare bogată → disc → stare)")
	_construieste_o_stare()

	var inainte := _fotografia()
	Arhiva.salveaza_tot()

	# GOLIREA E PARTEA CARE CONTEAZĂ. Fără ea, comparația ar trece chiar dacă
	# încărcarea n-ar face absolut nimic: starea din memorie era deja bună.
	_goleste_totul()
	var gol := _fotografia()
	var bun := _la_fel(inainte, gol, "") != ""
	_verdict("golirea chiar golește", bun,
		"" if bun else "fotografia goală e identică cu cea plină")

	Arhiva.incarca()
	var dupa := _fotografia()

	var diferenta := _la_fel(inainte, dupa, "")
	bun = _verdict("starea se întoarce întreagă", diferenta == "",
		"%d chei de nivel înalt" % inainte.size() if diferenta == ""
		else diferenta) and bun

	# Și o privire separată peste HARTĂ, nod cu nod: e cea mai mare bucată de
	# stare și singura cu enum tradus în text și înapoi.
	var noduri_inainte: Array = inainte["expeditie"]["harta"]
	var noduri_dupa: Array = dupa["expeditie"]["harta"]
	bun = _verdict("harta are tot atâtea noduri",
		noduri_inainte.size() == noduri_dupa.size(),
		"%d noduri" % noduri_dupa.size()) and bun

	var tipuri := {}
	for nod in noduri_dupa:
		tipuri[String(nod.get("tip", "?"))] = true
	# Dacă traducerea enum → cheie s-ar rupe, toate nodurile ar ieși „lupta":
	# `_tip_din_cheie` întoarce Luptă pentru orice cheie necunoscută, ca un save
	# vechi să se deschidă strâmb în loc să nu se deschidă. Plasa aia e bună în
	# joc și mincinoasă într-o verificare, deci se întreabă direct.
	bun = _verdict("tipurile nodurilor nu s-au turtit", tipuri.size() >= 3,
		"%d tipuri distincte: %s" % [tipuri.size(), ", ".join(tipuri.keys())]) and bun

	return bun


# ─────────────────────────────────────────────────────────────
# 2. TIPURILE, NU DOAR VALORILE
# ─────────────────────────────────────────────────────────────

## VERIFICAREA PE CARE DUS-ÎNTORSUL N-O POATE FACE.
##
## În GDScript `3 == 3.0` e `true`, deci un `int()` uitat în `din_dictionar`
## trece comparația de mai sus fără nicio pată. Se vede abia când numărul ajunge
## să indexeze un Array — `harta[pozitie]` cu un float e o eroare de rulare, la
## mijlocul unei expediții, pe un save vechi.
##
## Deci aici nu se compară valori, se întreabă TIPUL fiecărui număr care a trecut
## prin JSON.
func _tipurile() -> bool:
	print("\n  2. TIPURILE (JSON întoarce orice număr ca float)")
	# Starea e cea încărcată de secțiunea 1, adică chiar venită de pe disc.
	var bun := true

	bun = _e_int("pozitie", Expeditie.pozitie) and bun
	bun = _e_int("nod_nerezolvat", Expeditie.nod_nerezolvat) and bun
	bun = _e_int("pv", Expeditie.pv) and bun
	bun = _e_int("pv_max", Expeditie.pv_max) and bun
	bun = _e_int("monede", Expeditie.monede) and bun
	bun = _e_int("samanta", Expeditie.samanta) and bun
	bun = _e_int("fragmente din tezaur",
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE)) and bun

	for cheie in Expeditie.recorduri:
		bun = _e_int("recorduri[%s]" % cheie, Expeditie.recorduri[cheie]) and bun

	var parcurse_bune := true
	for id in Expeditie.parcurse:
		parcurse_bune = parcurse_bune and typeof(id) == TYPE_INT
	bun = _verdict("parcurse ține int-uri", parcurse_bune,
		"%d noduri" % Expeditie.parcurse.size()) and bun

	# Nodurile: patru câmpuri care INDEXEAZĂ sau se compară cu indici, plus
	# bugetul, care trebuie să rămână float — un buget rotunjit la int ar schimba
	# ce inamici încap la nodul ăla, fără să crape nimic.
	var rele: Array[String] = []
	for nod in Expeditie.harta:
		for camp in ["id", "adancime", "coloana", "samanta", "tip"]:
			if typeof(nod.get(camp)) != TYPE_INT:
				rele.append("%s al nodului %s e %s" % [
					camp, nod.get("id", "?"), type_string(typeof(nod.get(camp)))])
		if typeof(nod.get("buget")) != TYPE_FLOAT:
			rele.append("bugetul nodului %s e %s" % [
				nod.get("id", "?"), type_string(typeof(nod.get("buget")))])
		for id in nod.get("spre", []):
			if typeof(id) != TYPE_INT:
				rele.append("spre al nodului %s ține %s" % [
					nod.get("id", "?"), type_string(typeof(id))])
	bun = _verdict("nodurile au int-uri și un buget float", rele.is_empty(),
		"%d noduri × 6 câmpuri" % Expeditie.harta.size() if rele.is_empty()
		else _primele(rele, 3)) and bun

	# Nivelul din Antrenament: ajunge în `CIFRE_ROMANE[nivel - 1]`, deci un float
	# ar pica acolo, pe ecran, nu aici.
	var niveluri: Dictionary = PRACTICE.spre_dictionar()["nivel_atins"]
	var niveluri_bune := true
	for domeniu in niveluri:
		niveluri_bune = niveluri_bune and typeof(niveluri[domeniu]) == TYPE_INT
	bun = _verdict("nivelurile din Antrenament sunt int", niveluri_bune,
		"%d domenii" % niveluri.size()) and bun

	return bun


func _e_int(eticheta: String, valoare) -> bool:
	return _verdict(eticheta, typeof(valoare) == TYPE_INT,
		type_string(typeof(valoare)))


# ─────────────────────────────────────────────────────────────
# 3. CHEI LIPSĂ
# ─────────────────────────────────────────────────────────────

## Un save vechi, căruia îi lipsesc câmpuri apărute între timp. Regula e scrisă
## în antetul lui `arhiva.gd`: cheie lipsă = valoarea implicită, și nicio
## crăpătură. Se probează cu cazul cel mai sărac cu putință — un obiect gol — și
## cu unul pe jumătate scris, care e cazul adevărat.
func _chei_lipsa() -> bool:
	print("\n  3. CHEI LIPSĂ (un save mai vechi decât jocul)")

	_goleste_dosarul()
	_goleste_totul()
	_scrie_brut(Arhiva.NUME_PERMANENT, '{"versiune": 1}')
	_scrie_brut(Arhiva.NUME_EXPEDITIE, '{"versiune": 1}')
	Arhiva.incarca()

	var bun := _verdict("fișiere goale: nimic stricat",
		Arhiva.stricate.is_empty(), str(Arhiva.stricate))
	bun = _verdict("tezaurul rămâne pe zero",
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE) == 0,
		str(Tezaur.cat(Tezaur.Resursa.FRAGMENTE))) and bun
	# `activa` lipsă = `false`, deci `incarca()` șterge fișierul: o expediție
	# despre care nu scrie că e în curs nu e în curs.
	bun = _verdict("expediția nu pornește din nimic",
		not Expeditie.activa and Expeditie.harta.is_empty(),
		"activa=%s, %d noduri" % [Expeditie.activa, Expeditie.harta.size()]) and bun

	# PE JUMĂTATE: are câteva câmpuri, îi lipsesc restul. Cazul care se întâmplă
	# cu adevărat, când starea crește de la o versiune la alta.
	_goleste_dosarul()
	_goleste_totul()
	_scrie_brut(Arhiva.NUME_EXPEDITIE, JSON.stringify({
		"versiune": 1,
		"expeditie": {"activa": true, "samanta": 777, "pozitie": 2},
	}))
	Arhiva.incarca()
	bun = _verdict("save pe jumătate: ce era se citește",
		Expeditie.activa and Expeditie.samanta == 777 and Expeditie.pozitie == 2,
		"activa=%s, samanta=%d, pozitie=%d" % [
			Expeditie.activa, Expeditie.samanta, Expeditie.pozitie]) and bun
	bun = _verdict("ce lipsea ia valoarea implicită",
		Expeditie.pv == Expeditie.PV_MAX and Expeditie.nod_nerezolvat == -1
		and Expeditie.monede == 0 and Expeditie.final == "",
		"pv=%d, nod_nerezolvat=%d, monede=%d" % [
			Expeditie.pv, Expeditie.nod_nerezolvat, Expeditie.monede]) and bun

	return bun


# ─────────────────────────────────────────────────────────────
# 4. CHEI ÎN PLUS
# ─────────────────────────────────────────────────────────────

## Un save mai NOU la câmpuri, dar nu la versiune: o resursă ștearsă între timp,
## un tip de nod care nu mai există, chei pe care nu le știe nimeni. Toate
## trebuie IGNORATE. Pragul e scris în antetul lui `tezaur.gd`: un save vechi
## trebuie să se deschidă chiar și strâmb.
func _chei_in_plus() -> bool:
	print("\n  4. CHEI ÎN PLUS (o resursă ștearsă, un tip de nod inventat)")

	_goleste_dosarul()
	_goleste_totul()
	_scrie_brut(Arhiva.NUME_PERMANENT, JSON.stringify({
		"versiune": 1,
		"tezaur": {"fragmente": 12, "lacrimi_de_cristal": 999},
		"un_sistem_care_nu_exista": {"orice": true},
	}))
	_scrie_brut(Arhiva.NUME_EXPEDITIE, JSON.stringify({
		"versiune": 1,
		"expeditie": {
			"activa": true,
			"harta": [
				{"id": 0, "adancime": 0, "coloana": 0, "tip": "lupta",
					"buget": 1.0, "samanta": 5, "spre": [1]},
				{"id": 1, "adancime": 1, "coloana": 0, "tip": "altar_de_fum",
					"buget": 1.0, "samanta": 6, "spre": []},
			],
		},
	}))
	Arhiva.incarca()

	var bun := _verdict("resursa necunoscută e ignorată",
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE) == 12 and Arhiva.stricate.is_empty(),
		"fragmente=%d" % Tezaur.cat(Tezaur.Resursa.FRAGMENTE))
	bun = _verdict("un tip de nod necunoscut devine Luptă",
		Expeditie.harta.size() == 2
		and int(Expeditie.harta[1]["tip"]) == Expeditie.Nod.LUPTA,
		"%d noduri" % Expeditie.harta.size()) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 5. FIȘIERE STRICATE
# ─────────────────────────────────────────────────────────────

## Patru feluri de ilizibil, fiecare cu alt drum prin cod:
##   tăiat la mijloc        — parserul se oprește cu o linie și un mesaj
##   gunoi binar            — nu e nici măcar text
##   gol                    — zero octeți, JSON invalid
##   un Array, nu un obiect — JSON perfect valid, fără înțeles pentru noi
##
## În toate cele patru trebuie să se întâmple același lucru: fișierul e PUS
## DEOPARTE (nu șters), faptul ajunge în `Arhiva.stricate` ca să-l poată scrie
## meniul, iar jocul pornește curat în loc să crape.
##
## Se probează pe AMÂNDOUĂ fișierele, și nu de prisos: sunt două apeluri
## diferite, cu două mesaje diferite în meniu, iar un `permanent` uitat ar
## însemna tot progresul pierdut în tăcere.
func _fisiere_stricate() -> bool:
	print("\n  5. FIȘIERE STRICATE (patru feluri de ilizibil, pe ambele fișiere)")
	var bun := true
	var stricaturi := {
		"tăiat la mijloc": '{"versiune": 1, "expeditie": {"pv": 7',
		"gunoi binar": "\u0001\u0002\u0003 nu e text",
		"gol": "",
		"un Array, nu un obiect": '[1, 2, 3]',
	}

	for brut in [Arhiva.NUME_PERMANENT, Arhiva.NUME_EXPEDITIE]:
		var nume := String(brut)
		var baza := nume.get_basename()
		for descriere in stricaturi:
			_goleste_dosarul()
			_goleste_totul()
			_scrie_brut(nume, String(stricaturi[descriere]))
			Arhiva.incarca()

			var pus_deoparte := FileAccess.file_exists(
				Arhiva.cale_catre("%s.stricat.json" % baza))
			var originalul_dispare := not FileAccess.file_exists(
				Arhiva.cale_catre(nume))
			bun = _verdict("%s, %s" % [baza, descriere],
				Arhiva.stricate.has(baza) and pus_deoparte and originalul_dispare,
				"stricate=%s, pus deoparte=%s" % [
					Arhiva.stricate.keys(), pus_deoparte]) and bun

	# Și jocul e într-adevăr curat după o stricare, nu pe jumătate încărcat.
	bun = _verdict("după o stricare, jocul pornește curat",
		not Expeditie.activa and Tezaur.cat(Tezaur.Resursa.FRAGMENTE) == 0,
		"activa=%s" % Expeditie.activa) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 6. DOUĂ STRICĂRI LA RÂND
# ─────────────────────────────────────────────────────────────

## Un fișier pus deoparte e singurul loc din care se mai poate salva ceva, deci
## a doua stricare n-are voie s-o șteargă pe prima. A doua primește data în
## nume; dacă și aia e luată (două stricări în aceeași secundă), un număr.
##
## Se probează de TREI ori, nu de două: a treia e cea care cade pe ramura cu
## număr, fiindcă toate trei se întâmplă în aceeași secundă de ceas.
func _doua_stricari_la_rand() -> bool:
	print("\n  6. DOUĂ STRICĂRI LA RÂND (prima pusă deoparte nu se pierde)")
	_goleste_dosarul()
	_goleste_totul()

	var bun := true
	for incercare in range(3):
		# Fiecare stricare are un conținut DIFERIT, ca să se poată citi după
		# aceea care e care: altfel „trei fișiere" nu dovedește că nu s-au
		# suprascris, doar că sunt trei nume.
		_scrie_brut(Arhiva.NUME_PERMANENT, "stricat numarul %d {" % incercare)
		Arhiva.incarca()

	var puse: Array[String] = []
	for fisier in _fisierele_din_dosar():
		if String(fisier).begins_with("permanent.stricat"):
			puse.append(String(fisier))
	puse.sort()

	bun = _verdict("trei stricări → trei fișiere puse deoparte",
		puse.size() == 3, ", ".join(puse)) and bun

	var continuturi := {}
	for fisier in puse:
		continuturi[_citeste_brut(fisier)] = true
	bun = _verdict("niciunul nu l-a suprascris pe altul",
		continuturi.size() == 3, "%d conținuturi distincte" % continuturi.size()) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 7. VERSIUNEA
# ─────────────────────────────────────────────────────────────

## Vechi se citește (prin `_migreaza`), nou NU se citește. Asimetria e toată
## ideea: o cheie pe care n-o știu poate însemna altceva decât cred, deci un
## save din viitor nu se poate deschide „strâmb" — se pune deoparte, cu
## versiunea în nume, ca să se vadă de ce.
func _versiunea() -> bool:
	print("\n  7. VERSIUNEA (vechi se citește, nou nu)")

	_goleste_dosarul()
	_goleste_totul()
	# Fără câmp = „versiunea 0", adică mai veche decât orice. Se citește.
	_scrie_brut(Arhiva.NUME_PERMANENT, '{"tezaur": {"fragmente": 5}}')
	Arhiva.incarca()
	var bun := _verdict("un save fără versiune se citește",
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE) == 5 and Arhiva.stricate.is_empty(),
		"fragmente=%d" % Tezaur.cat(Tezaur.Resursa.FRAGMENTE))

	_goleste_dosarul()
	_goleste_totul()
	var viitoare := Arhiva.VERSIUNE + 98
	_scrie_brut(Arhiva.NUME_PERMANENT, '{"versiune": %d, "tezaur": {"fragmente": 5}}'
		% viitoare)
	Arhiva.incarca()
	bun = _verdict("un save din viitor NU se citește",
		Tezaur.cat(Tezaur.Resursa.FRAGMENTE) == 0 and Arhiva.stricate.has("permanent"),
		"fragmente=%d, stricate=%s" % [
			Tezaur.cat(Tezaur.Resursa.FRAGMENTE), Arhiva.stricate.keys()]) and bun
	bun = _verdict("și e pus deoparte cu versiunea în nume",
		FileAccess.file_exists(Arhiva.cale_catre("permanent.v%d.json" % viitoare)),
		", ".join(_fisierele_din_dosar())) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 8. ATOMICITATEA
# ─────────────────────────────────────────────────────────────

## Scrierea trece printr-un fișier `.nou` care apoi se redenumește. Două lucruri
## de verificat, și amândouă sunt despre ce rămâne pe disc:
##
##   DUPĂ o scriere reușită nu trebuie să mai existe niciun `.nou`. Unul rămas
##   ar însemna că redenumirea n-a avut loc — adică save-ul care se vede nu e cel
##   care s-a scris.
##
##   UN `.nou` ORFAN (fără fișier adevărat lângă el) se adoptă. Așa arată discul
##   dacă jocul s-a închis în fereastra de o microsecundă dintre ștergerea
##   vechiului și redenumirea noului. Fișierul e întreg, deci aruncarea lui ar
##   fi singura pierdere de date pe care Save-ul ar putea-o face singur.
func _atomicitatea() -> bool:
	print("\n  8. ATOMICITATEA (fișierul temporar, și ce rămâne după el)")
	_goleste_dosarul()
	_goleste_totul()
	_construieste_o_stare()
	Arhiva.salveaza_tot()

	var ramase: Array[String] = []
	for fisier in _fisierele_din_dosar():
		if String(fisier).ends_with(Arhiva.SUFIX_TEMPORAR):
			ramase.append(String(fisier))
	var bun := _verdict("nicio urmă de .nou după o scriere",
		ramase.is_empty(), ", ".join(_fisierele_din_dosar()))

	# ORFANUL. Mutăm save-ul adevărat în `.nou` cu mâna: exact ce ar fi rămas pe
	# disc la o închidere bruscă în clipa redenumirii.
	var monede_inainte := Expeditie.monede
	DirAccess.rename_absolute(
		Arhiva.cale_catre(Arhiva.NUME_EXPEDITIE),
		Arhiva.cale_catre(Arhiva.NUME_EXPEDITIE + Arhiva.SUFIX_TEMPORAR))
	_goleste_totul()
	Arhiva.incarca()
	bun = _verdict("un .nou orfan se adoptă",
		Expeditie.activa and Expeditie.monede == monede_inainte,
		"activa=%s, monede=%d (erau %d)" % [
			Expeditie.activa, Expeditie.monede, monede_inainte]) and bun
	bun = _verdict("și e pus la locul lui, nu doar citit",
		FileAccess.file_exists(Arhiva.cale_catre(Arhiva.NUME_EXPEDITIE))
		and not FileAccess.file_exists(
			Arhiva.cale_catre(Arhiva.NUME_EXPEDITIE + Arhiva.SUFIX_TEMPORAR)),
		", ".join(_fisierele_din_dosar())) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 9. NODUL INTRAT ȘI NEREZOLVAT
# ─────────────────────────────────────────────────────────────

## Gaura pe care a deschis-o chiar prima scriere pe disc, și pe care verificarea
## asta o ține închisă.
##
## Nodul se consumă la INTRARE (`intra_in_nod`), iar expediția se scrie imediat,
## înainte să se deschidă ce te așteaptă — ca un lacăt ratat să nu se poată relua
## cu codul deja văzut. Consecința: un joc închis în mijlocul luptei lasă pe disc
## un nod trecut în `parcurse`, care nu s-a întâmplat.
##
## Dacă nimeni nu s-ar uita la asta, harta l-ar trata ca încheiat și l-ar sări:
## lupta pe gratis, iar la BOSS chiar ecranul de victorie, fiindcă `la_capat()`
## e adevărat în clipa în care ești pe nodul lui. Deci: câmpul ajunge pe disc, și
## fișa nodului spune dacă se poate relua.
func _nodul_nerezolvat() -> bool:
	print("\n  9. NODUL INTRAT ȘI NEREZOLVAT (lupta nu se sare, cufărul nu se reia)")
	_goleste_dosarul()
	_goleste_totul()

	var discipline: Array[String] = ["memorie", "logica"]
	Expeditie.incepe(discipline, SAMANTA)
	var optiuni := Expeditie.accesibile()
	Expeditie.intra_in_nod(optiuni[0])
	var unde := Expeditie.pozitie
	Arhiva.salveaza_expeditia()

	_goleste_totul()
	Arhiva.incarca()
	var bun := _verdict("nodul nerezolvat ajunge pe disc",
		Expeditie.nod_nerezolvat == unde,
		"nod_nerezolvat=%d, pozitie=%d" % [Expeditie.nod_nerezolvat, unde])

	# Și se ȘTERGE când nodul se încheie. Fără asta, harta ar redeschide la
	# infinit nodul de dinainte: te întorci din luptă, iar ea ți-o deschide iar.
	Expeditie.incheie_nodul()
	Arhiva.salveaza_expeditia()
	_goleste_totul()
	Arhiva.incarca()
	bun = _verdict("nodul încheiat nu mai e nerezolvat",
		Expeditie.nod_nerezolvat == -1,
		"nod_nerezolvat=%d" % Expeditie.nod_nerezolvat) and bun

	# TABELUL, nu codul: cine se reia și cine nu. O singură linie schimbată în
	# `DATE_NOD` ar putea face cufărul reluabil, iar atunci codul lui ar fi
	# arătat de două ori — fără ca nimic să crape.
	var reluabile := {
		Expeditie.Nod.LUPTA: true, Expeditie.Nod.ELITA: true,
		Expeditie.Nod.BOSS: true, Expeditie.Nod.ODIHNA: true,
		Expeditie.Nod.MAGAZIN: true, Expeditie.Nod.EVENIMENT: false,
	}
	var gresite: Array[String] = []
	for tip in reluabile:
		var fisa := Expeditie.date_nod(tip)
		if bool(fisa.get("reluabil", true)) != bool(reluabile[tip]):
			gresite.append(String(fisa["cheie"]))
	bun = _verdict("tabelul spune cine se reia", gresite.is_empty(),
		"Evenimentul NU, celelalte cinci DA" if gresite.is_empty()
		else ", ".join(gresite)) and bun

	# Și Bossul: dacă ai închis jocul în lupta lui, `la_capat()` e deja adevărat,
	# deci singurul lucru care stă între tine și o victorie nemeritată e câmpul
	# de mai sus.
	var boss := Expeditie.id_boss()
	if boss >= 0:
		Expeditie.pozitie = boss
		Expeditie.nod_nerezolvat = boss
		bun = _verdict("la Boss, capătul e deja atins — nodul decide",
			Expeditie.la_capat() and Expeditie.nod_nerezolvat >= 0
			and bool(Expeditie.date_nod(Expeditie.Nod.BOSS)["reluabil"]),
			"la_capat=%s, nerezolvat=%d" % [
				Expeditie.la_capat(), Expeditie.nod_nerezolvat]) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# 10. DURATELE SACULUI
# ─────────────────────────────────────────────────────────────

## Decizia luată la Save: sacurile din Antrenament devin permanente, cele de
## luptă rămân pe expediție. Trei lucruri de ținut, și fiecare se poate rupe
## separat:
##
##   DESPĂRȚIREA PE FIȘIERE. Un sac permanent n-are ce căuta în save-ul
##   expediției și invers — altfel ștergerea fișierului de expediție ar lua cu
##   ea și memoria rafturilor.
##   `expeditie_noua()` GOLEȘTE DOAR CE TREBUIE. Asta e chiar scurgerea scrisă
##   la „Rămas deschis" în sesiunea MENIUL ȘI PRACTICE.
##   DECLARAȚIA DIN `trivia.gd`. Mecanismul poate fi perfect, iar singura linie
##   care-l folosește poate lipsi. Se probează prin chiar funcția pe care o
##   cheamă ecranul.
func _duratele_sacului() -> bool:
	print("\n  10. DURATELE SACULUI (rafturile rămân, lupta se golește)")
	_goleste_dosarul()
	Sac.goleste_tot()
	_goleste_totul()

	var pool := [{"id": "x1"}, {"id": "x2"}, {"id": "x3"}]
	Sac.extrage("practice:proba:tot:1", pool, "id", Sac.Durata.PERMANENT)
	Sac.extrage("cultura_generala:proba:1", pool, "id")

	var in_permanent: Dictionary = Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"]
	var in_expeditie: Dictionary = Sac.spre_dictionar(Sac.Durata.EXPEDITIE)["extrase"]
	var bun := _verdict("fiecare sac într-un singur fișier",
		in_permanent.has("practice:proba:tot:1")
		and not in_permanent.has("cultura_generala:proba:1")
		and in_expeditie.has("cultura_generala:proba:1")
		and not in_expeditie.has("practice:proba:tot:1"),
		"permanent=%s, expediție=%s" % [in_permanent.keys(), in_expeditie.keys()])

	Sac.expeditie_noua()
	bun = _verdict("expediție nouă: raftul ține minte, lupta uită",
		not Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"].is_empty()
		and Sac.spre_dictionar(Sac.Durata.EXPEDITIE)["extrase"].is_empty(),
		"permanent=%d sacuri, expediție=%d" % [
			Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"].size(),
			Sac.spre_dictionar(Sac.Durata.EXPEDITIE)["extrase"].size()]) and bun

	# Și trece prin disc: un sac permanent care s-ar încărca drept „de expediție"
	# ar fi șters de prima expediție pornită după reîncărcare.
	Arhiva.salveaza_permanent()
	Sac.goleste_tot()
	Arhiva.incarca()
	Sac.expeditie_noua()
	bun = _verdict("și după disc rămâne permanent",
		Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"].has("practice:proba:tot:1"),
		str(Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"].keys())) and bun

	# DECLARAȚIA ADEVĂRATĂ, prin funcția pe care o cheamă ecranul din Practice.
	TRIVIA.incarca_intrebari()
	Sac.goleste_tot()
	var cheie := _trage_un_raft()
	if cheie == "":
		bun = _verdict("trage_din_raft declară sacul permanent", false,
			"niciun raft cu conținut — n-am avut ce proba") and bun
	else:
		Sac.expeditie_noua()
		bun = _verdict("trage_din_raft declară sacul permanent",
			Sac.spre_dictionar(Sac.Durata.PERMANENT)["extrase"].has(cheie),
			cheie) and bun
	return bun


## Trage o întrebare din primul raft cu conținut și întoarce cheia sacului lui,
## sau "" dacă n-a găsit niciunul. Prin CHIAR funcția ecranului.
func _trage_un_raft() -> String:
	for domeniu in TRIVIA.DOMENII:
		var nume_domeniu := String(domeniu)
		for raft in TRIVIA.SUBCATEGORII.get(nume_domeniu, {}):
			var nume_raft := String(raft)
			if TRIVIA.raftul(1, nume_domeniu, nume_raft).is_empty():
				continue
			TRIVIA.trage_din_raft(1, nume_domeniu, nume_raft)
			return TRIVIA.cheia_raftului(nume_domeniu, nume_raft, 1)
	return ""


# ─────────────────────────────────────────────────────────────
# 11. EXPEDIȚIA ÎNCHEIATĂ
# ─────────────────────────────────────────────────────────────

## Fișierul expediției există doar cât e un run viu: ăsta e tot rostul celor
## două fișiere. Două lucruri:
##
##   ȘTERGEREA. După încheiere, nu mai e nimic de continuat — iar meniul
##   întreabă exact fișierul ăsta.
##   FIȘIERUL FANTOMĂ. Un save de expediție încheiată n-ar trebui să existe. Dacă
##   totuși apare (o versiune mai veche, o închidere în clipa greșită), nu se
##   reia: expediția e deja plătită în Tezaur, iar reluarea ar fi a doua plată.
func _expeditia_incheiata() -> bool:
	print("\n  11. EXPEDIȚIA ÎNCHEIATĂ (fișierul ei dispare)")
	_goleste_dosarul()
	_goleste_totul()
	_construieste_o_stare()
	Arhiva.salveaza_tot()

	var bun := _verdict("cât e un run viu, fișierul e acolo",
		Arhiva.exista_expeditie(), ", ".join(_fisierele_din_dosar()))

	Expeditie.incheie(true)
	Arhiva.salveaza_permanent()
	Arhiva.sterge_expeditia()
	bun = _verdict("după încheiere, nu mai e",
		not Arhiva.exista_expeditie(), ", ".join(_fisierele_din_dosar())) and bun
	bun = _verdict("dar Fragmentele au rămas scrise",
		FileAccess.file_exists(Arhiva.cale_catre(Arhiva.NUME_PERMANENT))) and bun

	# FANTOMA: un fișier de expediție cu `activa: false`.
	_scrie_brut(Arhiva.NUME_EXPEDITIE, JSON.stringify({
		"versiune": 1,
		"expeditie": {"activa": false, "samanta": 999, "pozitie": 4},
	}))
	_goleste_totul()
	Arhiva.incarca()
	bun = _verdict("un fișier de expediție încheiată nu se reia",
		not Expeditie.activa and Expeditie.samanta == 0
		and not Arhiva.exista_expeditie(),
		"activa=%s, samanta=%d, fișier=%s" % [
			Expeditie.activa, Expeditie.samanta, Arhiva.exista_expeditie()]) and bun
	return bun


# ─────────────────────────────────────────────────────────────
# STAREA DE PROBĂ
# ─────────────────────────────────────────────────────────────

## O stare în care fiecare câmp are o valoare NEIMPLICITĂ. Vezi nota de la
## secțiunea 1 pentru de ce contează.
func _construieste_o_stare() -> void:
	Sac.goleste_tot()

	var discipline: Array[String] = ["memorie", "logica"]
	Expeditie.incepe(discipline, SAMANTA)

	for _i in range(PASI):
		var optiuni := Expeditie.accesibile()
		if optiuni.is_empty():
			break
		Expeditie.intra_in_nod(optiuni[0])
		Expeditie.incheie_nodul()

	# PV schimbat (nu maximul), Monede, o putere cumpărată, recorduri, Fragmente.
	Expeditie.seteaza_pv(Expeditie.pv_max - 4)
	Expeditie.castiga_monede(60)
	Expeditie.cumpara("fiertura")
	Expeditie.inregistreaza_lupta({
		"cel_mai_lung_lant": 11, "critice": 2, "daune": 19,
	})
	Expeditie.incaseaza(Tezaur.Resursa.FRAGMENTE, 37)

	# Un nod intrat și NEÎNCHEIAT, ca `nod_nerezolvat` să nu fie -1.
	var ultime := Expeditie.accesibile()
	if not ultime.is_empty():
		Expeditie.intra_in_nod(ultime[0])

	# Bilete în amândouă felurile de sac.
	var pool := [{"id": "q1"}, {"id": "q2"}, {"id": "q3"}, {"id": "q4"}]
	Sac.extrage("cultura_generala:geografie:1", pool, "id")
	Sac.extrage("practice:geografie:capitale:2", pool, "id", Sac.Durata.PERMANENT)
	Sac.retine("logica:3", "serie:4:7")

	# Progres în Antrenament, prin chiar funcția de încărcare.
	PRACTICE.din_dictionar({
		"nivel_atins": {"geografie": 2, "istorie": 1},
		"stiute": {
			"geografie:1": {"mana:0001": true, "mana:0002": true},
			"geografie:2": {"wd:Q142:capitala:fr": true},
		},
	})


## Tot ce se salvează, într-un singur dicționar. Comparația din secțiunea 1 se
## face pe el, deci TREBUIE să cuprindă exact ce duce `Arhiva` pe disc — altfel
## un câmp s-ar putea pierde chiar sub ochii verificării.
func _fotografia() -> Dictionary:
	return {
		"tezaur": Tezaur.spre_dictionar(),
		"expeditie": Expeditie.spre_dictionar(),
		"practice": PRACTICE.spre_dictionar(),
		"sac_permanent": Sac.spre_dictionar(Sac.Durata.PERMANENT),
		"sac_expeditie": Sac.spre_dictionar(Sac.Durata.EXPEDITIE),
	}


## Starea „jocul abia a pornit", pe toate straturile. Exact ce fac `_ready`-urile
## autoload-urilor, chemate cu mâna.
func _goleste_totul() -> void:
	Tezaur.goleste()
	Expeditie.goleste()
	Sac.goleste_tot()
	PRACTICE.din_dictionar({})
	Arhiva.stricate.clear()


# ─────────────────────────────────────────────────────────────
# COMPARAȚIA
# ─────────────────────────────────────────────────────────────

## Întoarce "" dacă cele două sunt la fel, altfel CALEA primei diferențe.
##
## Calea, nu doar „diferă": într-o fotografie cu sute de câmpuri, un „nu se
## potrivește" te lasă să cauți cu ochiul. „expeditie/harta/4/spre/1: 7 ≠ 8" îți
## spune unde să te uiți.
func _la_fel(a, b, cale: String) -> String:
	if typeof(a) != typeof(b):
		return "%s: %s față de %s" % [
			cale, type_string(typeof(a)), type_string(typeof(b))]

	if a is Dictionary:
		for cheie in a:
			if not b.has(cheie):
				return "%s/%s: lipsește după încărcare" % [cale, cheie]
			var mai_jos := _la_fel(a[cheie], b[cheie], "%s/%s" % [cale, cheie])
			if mai_jos != "":
				return mai_jos
		for cheie in b:
			if not a.has(cheie):
				return "%s/%s: apărut din senin" % [cale, cheie]
		return ""

	if a is Array:
		if a.size() != b.size():
			return "%s: %d elemente față de %d" % [cale, a.size(), b.size()]
		for i in range(a.size()):
			var mai_jos := _la_fel(a[i], b[i], "%s/%d" % [cale, i])
			if mai_jos != "":
				return mai_jos
		return ""

	if a is float:
		# Float-urile nu se compară cu `==`: drumul prin text poate schimba
		# ultimul bit. `is_equal_approx` e exact unealta pentru asta.
		if not is_equal_approx(a, b):
			return "%s: %f față de %f" % [cale, a, b]
		return ""

	if a != b:
		return "%s: %s față de %s" % [cale, str(a), str(b)]
	return ""


# ─────────────────────────────────────────────────────────────
# DOSARUL DE PROBĂ
# ─────────────────────────────────────────────────────────────

func _goleste_dosarul() -> void:
	if not DirAccess.dir_exists_absolute(DOSAR):
		DirAccess.make_dir_recursive_absolute(DOSAR)
		return
	for nume in _fisierele_din_dosar():
		DirAccess.remove_absolute(Arhiva.cale_catre(String(nume)))


func _fisierele_din_dosar() -> Array:
	# `get_files_at` întoarce un PackedStringArray, iar funcția asta promite un
	# Array: conversia e explicită, fiindcă GDScript n-o face singur la `return`.
	var gasite := Array(DirAccess.get_files_at(DOSAR))
	gasite.sort()
	return gasite


func _scrie_brut(nume: String, text: String) -> void:
	var fisier := FileAccess.open(Arhiva.cale_catre(nume), FileAccess.WRITE)
	if fisier == null:
		push_error("Verificarea: nu pot scrie %s." % nume)
		return
	fisier.store_string(text)
	fisier.close()


func _citeste_brut(nume: String) -> String:
	var fisier := FileAccess.open(Arhiva.cale_catre(nume), FileAccess.READ)
	if fisier == null:
		return ""
	var text := fisier.get_as_text()
	fisier.close()
	return text


# ─────────────────────────────────────────────────────────────
# RAPORTUL
# Aceleași două ajutoare ca la celelalte unelte, ca rapoartele să se citească la
# fel. Copiate dinadins, nu puse într-o bază comună: sunt patru rânduri de
# `print`, iar o bază comună de unelte ar fi un fișier pe care l-ai atinge de
# fiecare dată când o unealtă vrea o coloană în plus.
# ─────────────────────────────────────────────────────────────

func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-48s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array[String], cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(lista[i])
	if lista.size() > cate:
		bucati.append("…")
	return " · ".join(bucati)

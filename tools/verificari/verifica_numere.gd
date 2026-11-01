extends Node
## VERIFICAREA NUMERELOR — cele 4 tipuri, cele 11 tipare, și socoteala.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_numere.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE E CEA MAI STRICTĂ VERIFICARE DIN JOC, ȘI DE CE ERA USOR SĂ FIE
##
## La Logică se putea recalcula răspunsul din enunț la trei tipare din
## cincisprezece (mulțimi, cel mai rău caz, calendar); restul se bătea pe
## formă, fiindcă „ce rezultă din două premise" nu se verifică cu o socoteală.
## La Numere se poate TOT: enunțul e o expresie, iar o expresie se evaluează.
##
## Deci regula de aici e cea mai tare pe care o poate avea o verificare de
## disciplină: **nicio întrebare nu e crezută pe cuvânt.** Pentru fiecare dintre
## cele 11 tipare, la toate trei nivelurile, se citește ENUNȚUL, se reface
## socoteala și se compară cu butonul marcat corect. Dacă `_procent_din` ar
## împărți la 10 în loc de 100, întrebarea ar arăta perfect normală — patru
## numere, unul verde — și ar fi greșită. Asta e singurul loc unde se vede.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   TABELUL ESTE ÎNTREG. Fiecare `metoda` din `GENERATOARE` există pe script
##   (un nume scris greșit ar fi o eroare în mijlocul luptei, nu la pornire) și
##   fiecare `categorie` e a unui singur tip — două tipuri cu același antet ar
##   fi un amestec invizibil.
##
##   TOATE TIPARELE SUNT VERIFICATE. Nu „cele pe care le-am scris": tabelul
##   `SOCOTELI` de mai jos trebuie să acopere FIECARE metodă din `GENERATOARE`,
##   altfel verificarea pică. Fără clichetul ăsta, un tipar adăugat mâine ar
##   trece neverificat și eu aș crede că verificarea îl acoperă.
##
##   CONTRACTUL, PE FIECARE TIPAR. Exact patru variante, toate DIFERITE (două
##   butoane cu același text sunt două răspunsuri bune), `corect` în interval,
##   enunț și notă nevide.
##
##   RĂSPUNSUL, RECALCULAT DIN ENUNȚ. Vezi mai sus. Plus, la cele două tipare
##   de ESTIMARE, o cerință în plus: varianta corectă trebuie să fie CEA MAI
##   APROPIATĂ de valoarea exactă, și singura. „Cam cât e" cu două variante la
##   fel de aproape nu e o estimare, e o păcăleală.
##
##   CÂNTARUL NU ARE DOUĂ RĂSPUNSURI BUNE. Cele patru valori, citite din
##   butoane și trecute în sutimi, trebuie să fie diferite între ele — 2/5 și
##   0,4 și 40% sunt același număr — iar cea marcată corect trebuie să fie
##   chiar cea mai mare. Și cel puțin două scrieri diferite printre ele.
##
##   FONTURILE AU CARACTERELE. Verificarea pe care niciun test de logică n-ar
##   avea nevoie s-o facă, și de care tiparul ăsta are: „×", „:", „,", „%" se
##   desenează ca un dreptunghi gol într-un font care nu le are. Se cer în
##   Cinzel și Alegreya (tema de pergament) ȘI în fontul implicit (lupta).
##   Exact proba din care s-au născut piesele desenate în `glifa_sah.gd`,
##   făcută înainte și nu după.
##
##   ECHILIBRUL PE TIPURI. Alegerea e în două trepte (întâi tipul, apoi
##   tiparul) tocmai ca CALCUL, cu patru tipare, să nu apară de două ori mai
##   des decât ESTIMARE, cu două. E o probabilitate, nu o listă: se vede la zeci
##   de mii de trageri, nu la o partidă.
##
##   FĂRĂ REPETIȚII PE EXPEDIȚIE. `_compune_nerepetata` din `puzzle.gd` nu
##   poate GARANTA nimic la o disciplină generativă; ce se poate afla e cât de
##   rar repetă de fapt.
##
##   CÂT SE CITEȘTE. Ultima secțiune nu dă verdicte, TIPĂREȘTE — ca
##   `verifica_mostrele` și `verifica_coltul`. Un enunț corect poate fi
##   nejucabil: la inamicul cu cronometru ai 12 secunde pentru tot, cititul
##   inclus. Aici se vede cea mai lungă întrebare a fiecărui tipar și o mostră
##   din fiecare, cu variantele ei, ca să le citesc cu ochiul.
##
## Ce NU verifică: dacă o întrebare e GREA cât trebuie. Că „7 × 8" e nivelul I
## și „24 × 17" nivelul III e o judecată, nu o socoteală — singura probă e să
## joc. Ce se poate verifica (și se verifică) e că numerele CRESC de la un
## nivel la altul, deci că tabelele de intervale n-au fost scrise strâmb.

const NUMERE := preload("res://scenes/numere/numere.gd")

# Câte întrebări se trag din fiecare tipar, la fiecare nivel. 200 e mult peste
# cât trebuie ca să iasă toate ramurile dinăuntru, și destul de puțin ca toată
# verificarea să treacă în câteva secunde.
const TRAGERI_PE_TIPAR := 200

# Câte trageri la măsurarea echilibrului, pe nivel. La 4 tipuri ar trebui să
# iasă pe la 2000 fiecare; împrăștierea întâmplătoare e de vreo ±45, deci
# toleranța e cu mult peste ea. Pică doar dacă alegerea e strâmbă.
const TRAGERI_ECHILIBRU := 8000
const TOLERANTA_ECHILIBRU := 0.20

# Cât poate pica un tipar fără ca asta să fie o problemă. Un tipar are voie să
# întoarcă gol (greșelile tipice ies uneori identice între ele, iar cântarul nu
# găsește întotdeauna patru valori destul de depărtate). Peste jumătate, însă,
# tiparul se rărește în tăcere: `_compune_intrebare` alege altă rețetă.
const MAX_RATA_DE_ESEC := 0.5

# Câte trageri la proba „fără repetiții pe expediție".
const TRAGERI_SAC := 300

# Fonturile în care trebuie să existe fiecare caracter al fiecărei întrebări.
const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"

# ─────────────────────────────────────────────────────────────
# CINE RECALCULEAZĂ CE
#
# Un rând pe tipar: metoda din `GENERATOARE` → funcția de aici care-i reface
# socoteala din enunț. Tabelul e și CLICHETUL: `_tabelul()` cere ca fiecare
# metodă din joc să aibă un rând aici, deci un tipar nou nu poate intra
# neverificat fără ca verificarea să pice.
# ─────────────────────────────────────────────────────────────
const SOCOTELI := {
	"_lant": "_bate_expresia",
	"_inmultire": "_bate_expresia",
	"_ordinea_operatiilor": "_bate_expresia",
	"_impartire": "_bate_expresia",
	"_procent_din": "_bate_procent_din",
	"_cat_la_suta": "_bate_cat_la_suta",
	"_reducere": "_bate_reducere",
	"_ordin_de_marime": "_bate_ordin_de_marime",
	"_suma_rotunjita": "_bate_suma_rotunjita",
	"_cea_mai_mare": "_bate_cea_mai_mare",
	"_echivalenta": "_bate_echivalenta",
}

var scena = null
var tot_bun := true

# Enunțurile, pe tipare, culese în timpul probelor și tipărite la final.
var cel_mai_lung := {}
var o_mostra := {}


func _ready() -> void:
	print("\n══ VERIFICAREA NUMERELOR ══\n")

	# Scriptul, nu scena: toate generatoarele lucrează pe numere, niciunul nu
	# atinge un buton. Deci nu se deschide nicio fereastră și nu pornește
	# niciun cronometru.
	scena = NUMERE.new()

	tot_bun = _tabelul() and tot_bun
	tot_bun = _contractul_si_socoteala() and tot_bun
	tot_bun = _nivelurile_cresc() and tot_bun
	tot_bun = _fonturile() and tot_bun
	tot_bun = _echilibrul() and tot_bun
	tot_bun = _fara_repetitii() and tot_bun
	_cat_se_citeste()

	scena.free()
	print("\n══ %s ══\n" % ("TOTUL E BUN" if tot_bun else "SUNT PROBLEME, vezi mai sus"))
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. TABELUL
# ─────────────────────────────────────────────────────────────

func _tabelul() -> bool:
	print("  TABELUL")
	var rezultat := true

	var lipsa: Array[String] = []
	var neverificate: Array[String] = []
	for generator in NUMERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		if not scena.has_method(metoda):
			lipsa.append(metoda)
		if not SOCOTELI.has(metoda):
			neverificate.append(metoda)

	rezultat = _verdict(
		"toate metodele exista pe script",
		lipsa.is_empty(),
		_primele(lipsa, 5)
	) and rezultat

	# CLICHETUL. Un tipar nou intră în joc cu un rând în `GENERATOARE`; dacă
	# n-are și un rând în `SOCOTELI`, verificarea pică aici și nu trece drept
	# acoperit.
	rezultat = _verdict(
		"fiecare tipar are cine sa-i refaca socoteala",
		neverificate.is_empty(),
		_primele(neverificate, 5)
	) and rezultat

	# Și invers: o socoteală scrisă pentru un tipar care nu mai există e cod
	# mort care arată ca o verificare.
	var orfane: Array[String] = []
	var metode_din_joc := {}
	for generator in NUMERE.GENERATOARE:
		metode_din_joc[String(generator["metoda"])] = true
	for metoda in SOCOTELI:
		if not metode_din_joc.has(metoda):
			orfane.append(String(metoda))
	rezultat = _verdict(
		"nicio socoteala fara tiparul ei",
		orfane.is_empty(),
		_primele(orfane, 5)
	) and rezultat

	# Un antet împărțit de două tipuri ar face echilibrul imposibil de măsurat:
	# `_echilibrul` deduce tipul din `categorie`.
	var tip_pe_antet := {}
	var antete_duble: Array[String] = []
	for generator in NUMERE.GENERATOARE:
		var antet := String(generator["categorie"])
		var tip := String(generator["tip"])
		if tip_pe_antet.has(antet) and tip_pe_antet[antet] != tip:
			antete_duble.append(antet)
		tip_pe_antet[antet] = tip
	rezultat = _verdict(
		"fiecare antet e al unui singur tip",
		antete_duble.is_empty(),
		_primele(antete_duble, 5)
	) and rezultat

	rezultat = _verdict(
		"cele 4 tipuri si cele 11 tipare",
		_tipurile().size() == 4 and NUMERE.GENERATOARE.size() == 11,
		"%d tipuri, %d tipare" % [_tipurile().size(), NUMERE.GENERATOARE.size()]
	) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 2. CONTRACTUL ȘI SOCOTEALA — miezul verificării
#
# O singură buclă pentru amândouă, dinadins: n-are rost să tragi de două ori
# 6600 de întrebări ca să te uiți o dată la formă și o dată la cifre.
# ─────────────────────────────────────────────────────────────

func _contractul_si_socoteala() -> bool:
	print("  CONTRACTUL SI SOCOTEALA (%d trageri pe tipar, pe nivel)" % TRAGERI_PE_TIPAR)
	var rezultat := true

	var stricate: Array[String] = []
	var gresite: Array[String] = []
	var prea_des_gol: Array[String] = []

	for generator in NUMERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var socoteala := String(SOCOTELI.get(metoda, ""))
		for nivel in [1, 2, 3]:
			var goale := 0
			for i in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, nivel)
				if q.is_empty():
					goale += 1
					continue
				_culege(metoda, q)

				var problema := _problema_de_contract(q)
				if problema != "":
					stricate.append("%s/%d: %s" % [metoda, nivel, problema])
					break
				if socoteala != "":
					var greseala: String = call(socoteala, q)
					if greseala != "":
						gresite.append("%s/%d: %s" % [metoda, nivel, greseala])
						break
			var rata := float(goale) / float(TRAGERI_PE_TIPAR)
			if rata > MAX_RATA_DE_ESEC:
				prea_des_gol.append("%s/%d: %d%%" % [metoda, nivel, int(rata * 100.0)])

	rezultat = _verdict(
		"toate tiparele respecta contractul",
		stricate.is_empty(),
		_primele(stricate, 5)
	) and rezultat
	rezultat = _verdict(
		"RASPUNSUL, recalculat din enunt",
		gresite.is_empty(),
		_primele(gresite, 5)
	) and rezultat
	rezultat = _verdict(
		"niciun tipar nu pica mai des de %d%%" % int(MAX_RATA_DE_ESEC * 100.0),
		prea_des_gol.is_empty(),
		_primele(prea_des_gol, 5)
	) and rezultat

	# Și prin poarta pe care o folosește chiar lupta: un dicționar gol de acolo
	# e ecranul de eroare în mijlocul unui lanț.
	var goale_la_compunere := 0
	for nivel in [1, 2, 3]:
		for i in range(TRAGERI_PE_TIPAR * 5):
			if scena._compune_intrebare(nivel).is_empty():
				goale_la_compunere += 1
	rezultat = _verdict(
		"`_compune_intrebare` nu intoarce niciodata gol",
		goale_la_compunere == 0,
		"%d goale din %d" % [goale_la_compunere, TRAGERI_PE_TIPAR * 15]
	) and rezultat

	return rezultat


## Ce e în neregulă cu întrebarea, sau șir gol dacă e bună. Aceleași cerințe pe
## care le-ar verifica `puzzle.gd` în luptă, plus una pe care el NU o verifică:
## variantele să fie diferite între ele.
func _problema_de_contract(q: Dictionary) -> String:
	for cheie in ["text", "variante", "corect", "explicatie"]:
		if not q.has(cheie):
			return "lipseste „%s”" % cheie
	if String(q["text"]).strip_edges() == "":
		return "enunt gol"
	if String(q["explicatie"]).strip_edges() == "":
		return "nota goala"

	var variante: Array = q["variante"]
	if variante.size() != 4:
		return "%d variante" % variante.size()

	var vazute := {}
	for varianta in variante:
		var text := String(varianta).strip_edges()
		if text == "":
			return "varianta goala"
		if vazute.has(text):
			return "doua variante identice: „%s”" % text
		vazute[text] = true

	var corect := int(q["corect"])
	if corect < 0 or corect >= variante.size():
		return "corect = %d" % corect
	return ""


# ─────────────────────────────────────────────────────────────
# 3. SOCOTELILE — câte una pe tipar
#
# Toate întorc șir gol dacă e bine, sau ce anume nu se potrivește. Toate
# citesc ENUNȚUL, nu un câmp pus deoparte pentru ele: un câmp ar fi fost
# aceeași cifră calculată de același cod, deci n-ar fi verificat nimic.
# ─────────────────────────────────────────────────────────────

## Cele patru tipare de CALCUL: enunțul E o expresie, deci se evaluează.
func _bate_expresia(q: Dictionary) -> String:
	var text := String(q["text"])
	if not text.ends_with(" = ?"):
		return "enuntul nu se termina cu „ = ?”: %s" % text
	var valoare = _evalueaza(text.trim_suffix(" = ?"))
	if valoare == null:
		return "nu pot evalua: %s" % text
	return _compara(q, int(valoare))


## „15% din 240 = ?"
func _bate_procent_din(q: Dictionary) -> String:
	var cifre := _potrivit(q, r"^(\d+)% din (\d+) = \?$")
	if cifre.is_empty():
		return "enunt necitibil: %s" % q["text"]
	# Aceeași condiție ca la reducere: dacă procentul din bază nu iese întreg,
	# întrebarea n-are răspuns exact printre patru numere întregi.
	if cifre[0] * cifre[1] % 100 != 0:
		return "procentul nu iese intreg: %d%% din %d" % [cifre[0], cifre[1]]
	return _compara(q, cifre[0] * cifre[1] / 100)


## „Cat la suta din 240 e 36?"
func _bate_cat_la_suta(q: Dictionary) -> String:
	var cifre := _potrivit(q, r"^Cat la suta din (\d+) e (\d+)\?$")
	if cifre.is_empty():
		return "enunt necitibil: %s" % q["text"]
	var total := cifre[0]
	var parte := cifre[1]
	if total == 0 or parte * 100 % total != 0:
		return "nu iese procent intreg: %d din %d" % [parte, total]
	return _compara(q, parte * 100 / total)


## „Un pret de 240 de monede scade cu 15%. / Cat devine?"
func _bate_reducere(q: Dictionary) -> String:
	var cifre := _potrivit(q, r"^Un pret de (\d+) de monede scade cu (\d+)%\.\nCat devine\?$")
	if cifre.is_empty():
		return "enunt necitibil: %s" % q["text"]
	var pret := cifre[0]
	var procent := cifre[1]
	# ÎNTÂI exactitatea, și abia apoi răspunsul. Prima versiune a verificării
	# ăsteia sărea pasul: calcula `pret - procent * pret / 100` cu aceeași
	# împărțire de întregi ca jocul, deci pentru „10% din 75" obținea 7 — exact
	# ca greșeala, deci spunea OK. O verificare care copiază formula nu verifică
	# formula; ea trebuie să verifice CONDIȚIA pe care formula o presupune.
	if procent * pret % 100 != 0:
		return "reducerea nu iese intreaga: %d%% din %d" % [procent, pret]
	return _compara(q, pret - procent * pret / 100)


## „Cam cat e 312 × 48?" — plus cerința de ESTIMARE: varianta corectă e cea mai
## apropiată de valoarea exactă, și singura.
func _bate_ordin_de_marime(q: Dictionary) -> String:
	var cifre := _potrivit(q, r"^Cam cat e (\d+) %s (\d+)\?$" % NUMERE.ORI)
	if cifre.is_empty():
		return "enunt necitibil: %s" % q["text"]
	var exact := cifre[0] * cifre[1]
	return _cea_mai_apropiata(q, exact)


## „Cam cat fac 198 + 403 + 299?"
func _bate_suma_rotunjita(q: Dictionary) -> String:
	var text := String(q["text"])
	if not (text.begins_with("Cam cat fac ") and text.ends_with("?")):
		return "enunt necitibil: %s" % text
	var expresie := text.trim_prefix("Cam cat fac ").trim_suffix("?")
	var valoare = _evalueaza(expresie)
	if valoare == null:
		return "nu pot evalua: %s" % expresie
	return _cea_mai_apropiata(q, int(valoare))


## „Care valoare e cea mai mare?" — se citesc cele patru butoane.
func _bate_cea_mai_mare(q: Dictionary) -> String:
	var variante: Array = q["variante"]
	var sutimi: Array[int] = []
	var feluri := {}
	for varianta in variante:
		var text := String(varianta)
		var v := _sutimi(text)
		if v < 0:
			return "varianta necitibila: „%s”" % text
		if v in sutimi:
			# ĂSTA e verdictul care contează la tiparul ăsta: două butoane cu
			# valori egale sunt două răspunsuri bune, oricât de diferit s-ar
			# scrie („2/5" și „40%").
			return "doua valori egale: %d sutimi" % v
		sutimi.append(v)
		feluri[_felul(text)] = true

	if feluri.size() < 2:
		return "toate patru scrise in acelasi fel (%s)" % feluri.keys()[0]

	var maxim := sutimi[0]
	for v in sutimi:
		maxim = maxi(maxim, v)
	var ales := _sutimi(String(variante[int(q["corect"])]))
	if ales != maxim:
		return "corect = %d sutimi, dar maximul e %d" % [ales, maxim]
	return ""


## Cele trei forme ale echivalenței: fracție → procent, fracție → zecimală,
## procent → fracție.
func _bate_echivalenta(q: Dictionary) -> String:
	var text := String(q["text"])
	var corect := String(q["variante"][int(q["corect"])])

	var ca_procent := _potrivit(q, r"^Cat e (\d+)/(\d+), in procente\?$")
	if not ca_procent.is_empty():
		var sutimi := ca_procent[0] * 100 / ca_procent[1]
		if ca_procent[0] * 100 % ca_procent[1] != 0:
			return "fractie fara procent intreg: %s" % text
		return _compara(q, sutimi)

	var ca_zecimal := _potrivit(q, r"^Cat e (\d+)/(\d+), ca numar zecimal\?$")
	if not ca_zecimal.is_empty():
		var sutimi := ca_zecimal[0] * 100 / ca_zecimal[1]
		var citit := _sutimi(corect)
		if citit != sutimi:
			return "„%s” nu e %d sutimi" % [corect, sutimi]
		return ""

	var ca_fractie := _potrivit(q, r"^Care fractie e egala cu (\d+)%\?$")
	if not ca_fractie.is_empty():
		var citit := _sutimi(corect)
		if citit != ca_fractie[0]:
			return "„%s” nu e %d%%" % [corect, ca_fractie[0]]
		return ""

	return "enunt necitibil: %s" % text


# ─────────────────────────────────────────────────────────────
# UNELTELE SOCOTELII
# ─────────────────────────────────────────────────────────────

## Butonul marcat corect, citit ca număr, comparat cu ce-a ieșit din enunț.
func _compara(q: Dictionary, asteptat: int) -> String:
	var text := String(q["variante"][int(q["corect"])])
	var citit = _numar_din(text)
	if citit == null:
		return "butonul corect nu e un numar: „%s”" % text
	if int(citit) != asteptat:
		return "butonul spune %s, enuntul da %d" % [text, asteptat]
	return ""


## Cerința de ESTIMARE: varianta corectă e cea mai apropiată de valoarea
## exactă — și SINGURA cea mai apropiată. Două la fel de aproape ar fi două
## răspunsuri bune, chiar dacă unul dintre ele e cel pe care-l aștepta codul.
func _cea_mai_apropiata(q: Dictionary, exact: int) -> String:
	var variante: Array = q["variante"]
	var distante: Array[int] = []
	for varianta in variante:
		var v = _numar_din(String(varianta))
		if v == null:
			return "varianta necitibila: „%s”" % varianta
		distante.append(absi(int(v) - exact))

	var corect := int(q["corect"])
	for i in range(distante.size()):
		if i == corect:
			continue
		if distante[i] <= distante[corect]:
			return "„%s” e la fel de aproape (sau mai aproape) de %d ca „%s”" % [
				variante[i], exact, variante[corect]
			]
	return ""


## Evaluează o expresie cu „+", „-", „×" și „:", cu precedența corectă.
## `null` = n-am putut (operator necunoscut, împărțire cu rest).
##
## Se sprijină pe o însușire a enunțurilor din `numere.gd`: operatorii au
## SPAȚII în jurul lor și numerele din enunț n-au separator de mii. Dacă asta
## se schimbă vreodată, verificarea pică (nu trece în tăcere) — ceea ce e exact
## purtarea dorită.
func _evalueaza(expresie: String):
	var bucati: Array = Array(expresie.split(" ", false))
	if bucati.is_empty():
		return null

	# Întâi înmulțirile și împărțirile — ASTA e precedența pe care tiparul
	# `_ordinea_operatiilor` o pune la încercare, deci e și locul unde
	# verificarea ar trebui să fie cel mai greu de scris din greșeală la fel ca
	# jocul. Aici e scrisă pe tokenuri, acolo cu paranteze în GDScript.
	var i := 1
	while i < bucati.size() - 1:
		var op := String(bucati[i])
		if op == NUMERE.ORI or op == NUMERE.IMPARTIT:
			var a := int(bucati[i - 1])
			var b := int(bucati[i + 1])
			if op == NUMERE.IMPARTIT:
				if b == 0 or a % b != 0:
					return null
				bucati[i - 1] = a / b
			else:
				bucati[i - 1] = a * b
			bucati.remove_at(i)
			bucati.remove_at(i)
			continue
		i += 2

	var total := int(bucati[0])
	var j := 1
	while j < bucati.size() - 1:
		var op := String(bucati[j])
		if op == NUMERE.PLUS:
			total += int(bucati[j + 1])
		elif op == NUMERE.MINUS:
			total -= int(bucati[j + 1])
		else:
			return null
		j += 2
	return total


## Cifrele din enunț, după un tipar. Listă goală dacă nu se potrivește.
func _potrivit(q: Dictionary, tipar: String) -> Array[int]:
	var regex := RegEx.create_from_string(tipar)
	var potrivire := regex.search(String(q["text"]))
	var cifre: Array[int] = []
	if potrivire == null:
		return cifre
	for i in range(1, potrivire.get_group_count() + 1):
		cifre.append(int(potrivire.get_string(i)))
	return cifre


## Textul unui buton, ca număr întreg. Spațiile de grupare și „%" se scot.
## `null` = nu e un număr.
func _numar_din(text: String):
	var curat := text.replace(" ", "").replace("%", "")
	if not curat.is_valid_int():
		return null
	return int(curat)


## Textul unui buton de pe cântar, în SUTIMI. -1 = n-am putut citi.
## Trei scrieri, aceleași trei pe care le produce `_scrie_valoare`.
func _sutimi(text: String) -> int:
	if "/" in text:
		var bucati := text.split("/")
		if bucati.size() != 2:
			return -1
		var jos := int(bucati[1])
		if jos == 0 or int(bucati[0]) * 100 % jos != 0:
			return -1
		return int(bucati[0]) * 100 / jos
	if text.ends_with("%"):
		var cifre := text.trim_suffix("%")
		return int(cifre) if cifre.is_valid_int() else -1
	if text.begins_with("0,"):
		var zecimale := text.substr(2)
		if not zecimale.is_valid_int():
			return -1
		return int(zecimale) * 10 if zecimale.length() == 1 else int(zecimale)
	return -1


## În ce fel e scrisă valoarea: fracție, procent sau zecimală.
func _felul(text: String) -> String:
	if "/" in text:
		return "fractie"
	if "%" in text:
		return "procent"
	return "zecimal"


func _tipurile() -> Array:
	var tipuri := {}
	for generator in NUMERE.GENERATOARE:
		tipuri[String(generator["tip"])] = true
	return tipuri.keys()


# ─────────────────────────────────────────────────────────────
# 4. NUMERELE CRESC DE LA UN NIVEL LA ALTUL
#
# Singura parte din „cât de greu e" care se poate măsura. Că „7 × 8" e nivelul
# I și „24 × 17" al III-lea rămâne o judecată — dar dacă tabelele de intervale
# din `numere.gd` ar fi scrise strâmb (nivelul II cu numere mai mici decât I),
# s-ar vedea aici și nicăieri altundeva: în joc, o întrebare prea ușoară la
# nivelul III arată exact ca o întrebare.
#
# Se măsoară pe SUMA numerelor din enunț, mediată pe multe trageri. Două
# alegeri, și fiecare a fost o greșeală înainte:
#
#   NU pe rezultat — la împărțire rezultatul SCADE când divizorul crește, deci
#   un nivel mai greu ar fi arătat ca un nivel mai ușor.
#
#   NU pe cel mai mare număr, cum era la prima scriere. Măsura aia nu vede
#   LUNGIMEA: `_ordinea_operatiilor` are trei termeni la nivelul I și patru la
#   III, iar mai mulți termeni e mai greu chiar cu aceleași cifre. Suma vede
#   amândouă creșterile, fiindcă un termen în plus o urcă la fel ca un termen
#   mai mare. (Măsura veche a prins totuși ceva adevărat când a picat: la
#   tiparul ăla factorii erau 2..9 la toate trei nivelurile, deci nivelul I
#   servea „8 + 9 × 7". Acum cresc.)
# ─────────────────────────────────────────────────────────────

func _nivelurile_cresc() -> bool:
	print("  NIVELURILE CRESC")
	var rezultat := true

	var cifre := RegEx.create_from_string(r"\d+")
	var strambe: Array[String] = []

	for generator in NUMERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var medii: Array[float] = []
		for nivel in [1, 2, 3]:
			var suma := 0.0
			var cate := 0
			for i in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, nivel)
				if q.is_empty():
					continue
				var din_enunt := 0
				for potrivire in cifre.search_all(String(q["text"])):
					din_enunt += int(potrivire.get_string())
				suma += float(din_enunt)
				cate += 1
			medii.append(suma / maxf(1.0, float(cate)))

		# CÂNTARUL e scutit, și dinadins: acolo valorile sunt din același tabel
		# la toate trei nivelurile (10…90 de sutimi), iar dificultatea urcă
		# prin DISTANȚA dintre ele și prin scriere, nu prin mărimea numerelor.
		# O verificare care ar cere și de la el numere mai mari ar fi cerut
		# schimbarea tipului ca să treacă testul.
		if String(generator["tip"]) == "CANTARUL":
			continue
		if medii[1] < medii[0] or medii[2] < medii[1]:
			strambe.append("%s: %d → %d → %d" % [
				metoda, int(medii[0]), int(medii[1]), int(medii[2])
			])

	rezultat = _verdict(
		"numerele nu scad de la un nivel la altul",
		strambe.is_empty(),
		_primele(strambe, 5)
	) and rezultat
	return rezultat


# ─────────────────────────────────────────────────────────────
# 5. FONTURILE AU CARACTERELE
#
# Verificarea pentru care disciplina asta e singura candidată din joc: ea e
# singura care scrie semne de operații. „×", „:", „,", „%" — fiecare, într-un
# font care nu-l are, se desenează ca un dreptunghi gol.
#
# Se cer în amândouă fonturile temei (Practice) ȘI în cel implicit (lupta).
# Verificat, nu presupus — exact ca `ThemeDB.fallback_font.has_char(0x265F)`
# din `glifa_sah.gd`, de unde a plecat regula.
# ─────────────────────────────────────────────────────────────

func _fonturile() -> bool:
	print("  FONTURILE")
	var rezultat := true

	var fonturi := {}
	for cale in [CALE_CINZEL, CALE_ALEGREYA]:
		if not ResourceLoader.exists(cale):
			rezultat = _verdict("fontul %s exista" % cale.get_file(), false) and rezultat
			continue
		fonturi[cale.get_file()] = load(cale)
	fonturi["implicit (lupta)"] = ThemeDB.fallback_font

	# Toate caracterele care apar în întrebări, strânse la o parte. Se trag din
	# nou, pe toate tiparele și nivelurile: enunț, variante și notă.
	var caractere := {}
	for generator in NUMERE.GENERATOARE:
		for nivel in [1, 2, 3]:
			for i in range(20):
				var q: Dictionary = scena.call(String(generator["metoda"]), nivel)
				if q.is_empty():
					continue
				var tot := "%s %s %s" % [
					q["text"], " ".join(q["variante"]), q["explicatie"]
				]
				for ch in tot:
					caractere[ch] = true

	for nume in fonturi:
		var font: Font = fonturi[nume]
		var lipsa: Array[String] = []
		for ch in caractere:
			var cod: int = String(ch).unicode_at(0)
			# Sub 32 sunt spațiul și linia nouă: fonturile nu le declară, iar
			# desenarea lor nu trece prin glife.
			if cod < 32:
				continue
			if not font.has_char(cod):
				lipsa.append("„%s” (U+%04X)" % [ch, cod])
		rezultat = _verdict(
			"%s are toate caracterele" % nume,
			lipsa.is_empty(),
			_primele(lipsa, 8)
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 6. ECHILIBRUL PE TIPURI
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL (%d trageri pe nivel)" % TRAGERI_ECHILIBRU)
	var rezultat := true

	var tip_pe_antet := {}
	for generator in NUMERE.GENERATOARE:
		tip_pe_antet[String(generator["categorie"])] = String(generator["tip"])

	var tipuri := _tipurile()
	for nivel in [1, 2, 3]:
		var numarate := {}
		for i in range(TRAGERI_ECHILIBRU):
			var q: Dictionary = scena._compune_intrebare(nivel)
			if q.is_empty():
				continue
			var tip: String = tip_pe_antet[String(q["categorie"])]
			numarate[tip] = int(numarate.get(tip, 0)) + 1

		var tinta := float(TRAGERI_ECHILIBRU) / float(tipuri.size())
		var strambe: Array[String] = []
		for tip in tipuri:
			var cate := int(numarate.get(tip, 0))
			if absf(float(cate) - tinta) / tinta > TOLERANTA_ECHILIBRU:
				strambe.append("%s %d" % [tip, cate])

		rezultat = _verdict(
			"nivelul %d: %d tipuri, ~%d fiecare" % [nivel, tipuri.size(), int(tinta)],
			strambe.is_empty(),
			_primele(strambe, 5)
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 7. FĂRĂ REPETIȚII PE EXPEDIȚIE
#
# La Numere fântâna e cu mult mai adâncă decât la Cuvinte (numerele se trag din
# intervale, nu dintr-o listă), deci cifra de aici ar trebui să fie aproape
# zero. Dacă sare, a plecat identitatea întrebării din `puzzle.gd`.
# ─────────────────────────────────────────────────────────────

func _fara_repetitii() -> bool:
	print("  FARA REPETITII (%d trageri pe nivel)" % TRAGERI_SAC)
	var rezultat := true

	for nivel in [1, 2, 3]:
		Sac.expeditie_noua()
		var vazute := {}
		for i in range(TRAGERI_SAC):
			var q: Dictionary = scena._compune_nerepetata(nivel)
			if q.is_empty():
				continue
			vazute[scena._identitate_intrebare(q)] = true
		var repetari := TRAGERI_SAC - vazute.size()
		rezultat = _verdict(
			"nivelul %d: cel mult 5%% repetari" % nivel,
			repetari <= TRAGERI_SAC / 20,
			"%d repetari din %d" % [repetari, TRAGERI_SAC]
		) and rezultat
	Sac.expeditie_noua()

	return rezultat


# ─────────────────────────────────────────────────────────────
# 8. CÂT SE CITEȘTE — nu dă verdicte, TIPĂREȘTE
#
# Ca `verifica_mostrele` la Logică: „arată bine?" și „se citește în 12
# secunde?" nu sunt verdicte. Aici se vede, pe tipar, cea mai lungă întrebare
# întâlnită în toate probele de mai sus și o mostră cu variantele ei.
# ─────────────────────────────────────────────────────────────

func _cat_se_citeste() -> void:
	print("\n  CAT SE CITESTE (cea mai lunga intrebare, pe tipar)")
	for generator in NUMERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var lung := String(cel_mai_lung.get(metoda, ""))
		print("    %-24s %3d semne   %s" % [
			metoda, lung.length(), lung.replace("\n", " / ")
		])

	print("\n  O MOSTRA DIN FIECARE TIPAR")
	for generator in NUMERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var q: Dictionary = o_mostra.get(metoda, {})
		if q.is_empty():
			continue
		print("\n    [%s]  %s" % [generator["categorie"], String(q["text"]).replace("\n", " / ")])
		var variante: Array = q["variante"]
		for i in range(variante.size()):
			print("       %s %s" % ["→" if i == int(q["corect"]) else " ", variante[i]])
		print("       nota: %s" % q["explicatie"])


## Ține minte cea mai lungă întrebare și una la întâmplare, pe tipar.
## Culesul se face în bucla care verifică oricum, nu într-o trecere a lui —
## 6600 de întrebări trase a doua oară doar ca să le măsor lungimea ar fi fost
## două secunde irosite la fiecare rulare.
func _culege(metoda: String, q: Dictionary) -> void:
	var text := String(q["text"])
	if text.length() > String(cel_mai_lung.get(metoda, "")).length():
		cel_mai_lung[metoda] = text
	if not o_mostra.has(metoda) or randf() < 0.01:
		o_mostra[metoda] = q


func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-46s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array, cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(String(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

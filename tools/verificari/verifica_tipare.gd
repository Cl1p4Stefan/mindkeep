extends Node
## VERIFICAREA TIPARELOR — cele 4 tipuri, cele 18 tipare, și regula fiecăruia.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_tipare.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE DISCIPLINA ASTA NU POATE FI VERIFICATĂ CU OCHIUL
##
## Nu are niciun fișier de date, ca și Numerele: nu există o listă de șiruri de
## citit, deci nici de corectat. Există doar ce se poate RECALCULA — iar aici se
## poate la toate cele 18 tipare, fiindcă un tipar e, prin definiție, o regulă
## care se poate aplica din nou.
##
## Deci regula de aici e cea mai tare pe care o poate avea o verificare de
## disciplină, aceeași ca la Numere: **nicio întrebare nu e crezută pe cuvânt.**
## Pentru fiecare tipar, la fiecare nivel din care face parte, se citește
## ENUNȚUL, se deduce regula din el și se verifică butonul marcat corect.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   TABELUL ESTE ÎNTREG. Fiecare `metoda` din `GENERATOARE` există pe script,
##   fiecare `categorie` e a unui singur tip, și — CLICHETUL — fiecare metodă
##   are un rând în `SOCOTELI`. Un tipar adăugat mâine fără socoteala lui PICĂ
##   aici, în loc să treacă drept acoperit.
##
##   FIECARE TIP LA TOATE TREI NIVELURILE. Regula e scrisă în `tipare.gd`
##   („altfel la nivelul unde lipsește ceilalți își împart între ei toată
##   probabilitatea"), iar o regulă scrisă și nebătută e o intenție.
##
##   CONTRACTUL, PE FIECARE TIPAR. Exact patru variante, toate DIFERITE,
##   `corect` în interval, enunț și notă nevide.
##
##   RĂSPUNSUL, RECALCULAT DIN ENUNȚ. Vezi mai sus. Socotelile sunt scrise cu
##   altă unealtă decât generatoarele: unde `tipare.gd` CONSTRUIEȘTE șirul din
##   pas și creștere, verificarea deduce pasul și creșterea din numerele de pe
##   ecran. O verificare care ar copia formula n-ar verifica formula — lecția
##   plătită la `_reducere` din Numere.
##
##   INTRUSUL E SINGUR. Verdictul care contează cel mai mult din toată
##   verificarea, fiindcă e singurul loc din joc unde o întrebare poate avea
##   DOUĂ răspunsuri bune fără ca nimic să arate ciudat. Jocul își apără
##   unicitatea cu `_pozitii_posibile` (algebră cu determinanți); verificarea o
##   bate ALTFEL, prin enumerare: încearcă mii de reguli cu parametri din
##   intervale scrise aici și numără câte poziții pot fi intrusul. Dacă
##   determinanții din joc ar fi scriși greșit, singurul loc unde s-ar vedea e
##   dezacordul dintre cele două metode.
##
##   ȘABLONUL E CHIAR PE BUTOANE. La CICLU, decizia de design spune că cele
##   patru variante sunt semne din șablon (vezi `tipare.gd`), tocmai ca niciun
##   buton să nu se poată elimina din formă. Se verifică, altfel e o intenție.
##
##   ALFABETUL SE DECLARĂ. Fiecare întrebare de litere trebuie să înceapă cu
##   rândul care spune pe ce alfabet se numără. Fără el, „A, C, E, G, ?" are
##   două răspunsuri (alfabetul românesc are 31 de litere), iar jocul ar marca
##   roșu un răspuns corect. Decizia e scrisă în `tipare.gd`; verdictul de aici
##   e ce o ține în viață.
##
##   NIVELUL SE VEDE, la tiparele care apar la mai multe niveluri. Al doilea
##   clichet: un tipar cu două niveluri trebuie să aibă și o măsură în
##   `CRESC_PE_NIVEL`. Cele care stau la un singur nivel n-au ce să crească —
##   la disciplina asta dificultatea e și a REGULII (Fibonacci e greu cu orice
##   numere), nu numai a numerelor, și de-aia secțiunea nu seamănă cu cea de la
##   Numere.
##
##   FONTURILE AU CARACTERELE. „×" din note se desenează ca un dreptunghi gol
##   într-un font care nu-l are. Se cer în Cinzel și Alegreya (tema de
##   pergament) ȘI în fontul implicit (lupta).
##
##   ECHILIBRUL PE TIPURI, și FĂRĂ REPETIȚII PE EXPEDIȚIE. Ca la Numere:
##   alegerea e în două trepte tocmai ca SIR, cu nouă tipare, să nu apară de
##   trei ori mai des decât LITERE, cu trei.
##
##   CÂT SE CITEȘTE. Ultima secțiune nu dă verdicte, TIPĂREȘTE: cea mai lungă
##   întrebare a fiecărui tipar și o mostră cu variantele ei. Un enunț corect
##   poate fi nejucabil — la inamicul cu cronometru ai 12 secunde pentru tot,
##   cititul inclus.

const TIPARE := preload("res://scenes/tipare/tipare.gd")

# Câte întrebări se trag din fiecare tipar, la fiecare nivel al lui.
const TRAGERI_PE_TIPAR := 200

# Câte la proba de unicitate a intrusului. MAI PUȚINE, fiindcă acolo fiecare
# întrebare costă mii de reguli încercate (vezi `_intrusul_e_singur`). 60 e
# destul: la 9 combinații de tipar și nivel ies 540 de enigme rezolvate din
# nou, iar o întrebare cu două răspunsuri nu e un caz rar — ori tiparul o
# produce des, ori nu o produce.
const TRAGERI_INTRUS := 60

const TRAGERI_ECHILIBRU := 8000
const TOLERANTA_ECHILIBRU := 0.20

# Cât poate pica un tipar fără ca asta să fie o problemă. La disciplina asta
# picarea e a INTRUSULUI, care aruncă enigmele cu două răspunsuri.
const MAX_RATA_DE_ESEC := 0.5

const TRAGERI_SAC := 300

const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"

# ─────────────────────────────────────────────────────────────
# CINE RECALCULEAZĂ CE
#
# Un rând pe tipar: metoda din `GENERATOARE` → funcția de aici care-i reface
# socoteala din enunț. Tabelul e și CLICHETUL (vezi `_tabelul`).
#
# Două tipare pot împărți o socoteală când regula e aceeași și doar semnul
# diferă (pasul constant, în sus sau în jos), sau când forma întrebării e
# aceeași (cele trei feluri de intrus). Nu e o scurtătură: socoteala deduce
# pasul din numere, deci nu știe și nu are nevoie să știe dacă e pozitiv.
# ─────────────────────────────────────────────────────────────
const SOCOTELI := {
	"_pas_constant": "_bate_pas_constant",
	"_pas_negativ": "_bate_pas_constant",
	"_factor_constant": "_bate_factor_constant",
	"_pas_crescator": "_bate_pas_crescator",
	"_alternant": "_bate_alternant",
	"_pas_dublat": "_bate_pas_dublat",
	"_mixt": "_bate_mixt",
	"_fibonacci": "_bate_fibonacci",
	"_patrate": "_bate_patrate",

	"_litere_pas": "_bate_litere_pas",
	"_litere_fire": "_bate_litere_fire",
	"_litere_pas_crescator": "_bate_litere_pas_crescator",

	"_ciclu_urmatorul": "_bate_ciclu_urmatorul",
	"_ciclu_pe_loc": "_bate_ciclu_pe_loc",
	"_ciclu_doua_roti": "_bate_ciclu_doua_roti",

	"_intrus_din_pas": "_bate_intrusul",
	"_intrus_din_factor": "_bate_intrusul",
	"_intrus_din_pas_crescator": "_bate_intrusul",
}

# ─────────────────────────────────────────────────────────────
# CE CREȘTE DE LA UN NIVEL LA ALTUL
#
# Numai tiparele care apar la mai multe niveluri au ce să crească, iar fiecare
# crește pe altceva: `_litere_pas` pe pasul din alfabet, `_litere_fire` pe pasul
# fiecărui fir (care se vede între literele 1 și 3, nu între 1 și 2 — alea sunt
# din fire diferite), `_ciclu_pe_loc` pe cifrele din enunț.
#
# De-aia e un TABEL și nu o măsură unică: la Numere suma cifrelor din enunț
# servea toate tiparele, aici nu există o măsură care să aibă sens la toate
# trei. `_tabelul` cere ca fiecare tipar cu mai multe niveluri să aibă un rând
# aici — altfel un tipar lărgit mâine la două niveluri ar putea servi aceeași
# dificultate la amândouă, iar nimic n-ar spune nimic.
# ─────────────────────────────────────────────────────────────
const CRESC_PE_NIVEL := {
	"_litere_pas": "_masoara_pasul",
	"_litere_fire": "_masoara_pasul_firului",
	"_ciclu_pe_loc": "_masoara_cifrele",
}

var scena = null
var tot_bun := true

var cel_mai_lung := {}
var o_mostra := {}


func _ready() -> void:
	print("\n══ VERIFICAREA TIPARELOR ══\n")

	# Scriptul, nu scena: toate generatoarele lucrează pe numere și litere,
	# niciunul nu atinge un buton.
	scena = TIPARE.new()

	tot_bun = _tabelul() and tot_bun
	tot_bun = _nivelurile() and tot_bun
	tot_bun = _contractul_si_socoteala() and tot_bun
	tot_bun = _intrusul_singur() and tot_bun
	tot_bun = _sablonul_pe_butoane() and tot_bun
	tot_bun = _alfabetul_declarat() and tot_bun
	tot_bun = _nivelul_se_vede() and tot_bun
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
	var fara_masura: Array[String] = []
	for generator in TIPARE.GENERATOARE:
		var metoda := String(generator["metoda"])
		if not scena.has_method(metoda):
			lipsa.append(metoda)
		if not SOCOTELI.has(metoda):
			neverificate.append(metoda)
		# Al doilea clichet: mai multe niveluri = o măsură care să arate că nu
		# sunt la fel.
		var niveluri: Array = generator["niveluri"]
		if niveluri.size() > 1 and not CRESC_PE_NIVEL.has(metoda):
			fara_masura.append(metoda)

	rezultat = _verdict(
		"toate metodele exista pe script", lipsa.is_empty(), _primele(lipsa, 5)
	) and rezultat
	rezultat = _verdict(
		"fiecare tipar are cine sa-i refaca socoteala",
		neverificate.is_empty(), _primele(neverificate, 5)
	) and rezultat
	rezultat = _verdict(
		"fiecare tipar cu mai multe niveluri are o masura",
		fara_masura.is_empty(), _primele(fara_masura, 5)
	) and rezultat

	# Și invers: o socoteală scrisă pentru un tipar care nu mai există e cod
	# mort care arată ca o verificare.
	var metode_din_joc := {}
	for generator in TIPARE.GENERATOARE:
		metode_din_joc[String(generator["metoda"])] = true
	var orfane: Array[String] = []
	for metoda in SOCOTELI:
		if not metode_din_joc.has(metoda):
			orfane.append(String(metoda))
	for metoda in CRESC_PE_NIVEL:
		if not metode_din_joc.has(metoda):
			orfane.append(String(metoda))
	rezultat = _verdict(
		"nicio socoteala fara tiparul ei", orfane.is_empty(), _primele(orfane, 5)
	) and rezultat

	# Toate socotelile și măsurile numite în tabele trebuie să existe aici: un
	# nume scris greșit ar fi o eroare în mijlocul verificării, adică exact
	# momentul în care nu te uiți.
	var socoteli_lipsa: Array[String] = []
	for metoda in SOCOTELI:
		if not has_method(String(SOCOTELI[metoda])):
			socoteli_lipsa.append(String(SOCOTELI[metoda]))
	for metoda in CRESC_PE_NIVEL:
		if not has_method(String(CRESC_PE_NIVEL[metoda])):
			socoteli_lipsa.append(String(CRESC_PE_NIVEL[metoda]))
	rezultat = _verdict(
		"socotelile si masurile exista", socoteli_lipsa.is_empty(),
		_primele(socoteli_lipsa, 5)
	) and rezultat

	# Un antet împărțit de două tipuri ar face echilibrul imposibil de măsurat:
	# `_echilibrul` deduce tipul din `categorie`.
	var tip_pe_antet := {}
	var antete_duble: Array[String] = []
	for generator in TIPARE.GENERATOARE:
		var antet := String(generator["categorie"])
		var tip := String(generator["tip"])
		if tip_pe_antet.has(antet) and tip_pe_antet[antet] != tip:
			antete_duble.append(antet)
		tip_pe_antet[antet] = tip
	rezultat = _verdict(
		"fiecare antet e al unui singur tip", antete_duble.is_empty(),
		_primele(antete_duble, 5)
	) and rezultat

	rezultat = _verdict(
		"cele 4 tipuri si cele 18 tipare",
		_tipurile().size() == 4 and TIPARE.GENERATOARE.size() == 18,
		"%d tipuri, %d tipare" % [_tipurile().size(), TIPARE.GENERATOARE.size()]
	) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 2. FIECARE TIP LA TOATE TREI NIVELURILE
# ─────────────────────────────────────────────────────────────

func _nivelurile() -> bool:
	print("  NIVELURILE")
	var rezultat := true

	for nivel in [1, 2, 3]:
		var cu_tipar := {}
		for generator in TIPARE.GENERATOARE:
			if nivel in generator["niveluri"]:
				cu_tipar[String(generator["tip"])] = true
		var lipsa: Array[String] = []
		for tip in _tipurile():
			if not cu_tipar.has(tip):
				lipsa.append(tip)
		rezultat = _verdict(
			"nivelul %d are toate tipurile" % nivel, lipsa.is_empty(),
			"lipsesc: %s" % _primele(lipsa, 5) if not lipsa.is_empty() else "%d tipuri" % cu_tipar.size()
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 3. CONTRACTUL ȘI SOCOTEALA — miezul verificării
#
# O singură buclă pentru amândouă: n-are rost să tragi de două ori mii de
# întrebări ca să te uiți o dată la formă și o dată la regulă.
#
# Se trag numai nivelurile pe care tiparul le declară. La Numere se trăgeau
# toate trei la toate tiparele, fiindcă acolo fiecare tipar merge la toate trei;
# aici `_fibonacci` la nivelul I n-ar fi o verificare, ar fi o întrebare pe care
# jocul n-o pune niciodată.
# ─────────────────────────────────────────────────────────────

func _contractul_si_socoteala() -> bool:
	print("  CONTRACTUL SI SOCOTEALA (%d trageri pe tipar, pe nivelul lui)" % TRAGERI_PE_TIPAR)
	var rezultat := true

	var stricate: Array[String] = []
	var gresite: Array[String] = []
	var prea_des_gol: Array[String] = []

	for generator in TIPARE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var socoteala := String(SOCOTELI.get(metoda, ""))
		for nivel in generator["niveluri"]:
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
		"toate tiparele respecta contractul", stricate.is_empty(), _primele(stricate, 5)
	) and rezultat
	rezultat = _verdict(
		"RASPUNSUL, recalculat din enunt", gresite.is_empty(), _primele(gresite, 5)
	) and rezultat
	rezultat = _verdict(
		"niciun tipar nu pica mai des de %d%%" % int(MAX_RATA_DE_ESEC * 100.0),
		prea_des_gol.is_empty(), _primele(prea_des_gol, 5)
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


## Ce e în neregulă cu întrebarea, sau șir gol dacă e bună.
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
# 4. SOCOTELILE ȘIRURILOR NUMERICE
#
# Toate întorc șir gol dacă e bine, sau ce anume nu se potrivește. Toate deduc
# regula DIN NUMERELE DE PE ECRAN, nu din parametrii cu care a fost construit
# șirul: generatorul pleacă de la pas și creștere și scrie numerele, socoteala
# pleacă de la numere și află pasul și creșterea. Drumul invers e singurul care
# verifică ceva.
# ─────────────────────────────────────────────────────────────

## „3, 7, 11, 15, 19, ?" — pas constant, în sus sau în jos.
func _bate_pas_constant(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	if vazute.size() < 3:
		return "enunt necitibil: %s" % q["text"]

	var pas: int = vazute[1] - vazute[0]
	if pas == 0:
		return "pas zero"
	for i in range(1, vazute.size()):
		if vazute[i] - vazute[i - 1] != pas:
			return "pasul nu e constant: %s" % _ca_text(vazute)
	return _compara(q, vazute[-1] + pas)


## „3, 6, 12, 24, 48, ?" — factor constant.
func _bate_factor_constant(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	if vazute.size() < 3:
		return "enunt necitibil: %s" % q["text"]
	if vazute[0] == 0 or vazute[1] % vazute[0] != 0:
		return "primul raport nu e intreg: %s" % _ca_text(vazute)

	var factor: int = vazute[1] / vazute[0]
	if factor < 2:
		return "factor %d" % factor
	for i in range(1, vazute.size()):
		if vazute[i] != vazute[i - 1] * factor:
			return "factorul nu e constant: %s" % _ca_text(vazute)
	return _compara(q, vazute[-1] * factor)


## „2, 3, 5, 8, 12, ?" — pasul crește cu o constantă.
func _bate_pas_crescator(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	var pasi := _diferentele(vazute)
	if pasi.size() < 3:
		return "enunt necitibil: %s" % q["text"]

	var crestere: int = pasi[1] - pasi[0]
	if crestere <= 0:
		return "pasul nu creste: %s" % _ca_text(vazute)
	for i in range(1, pasi.size()):
		if pasi[i] - pasi[i - 1] != crestere:
			return "creșterea nu e constanta: %s" % _ca_text(vazute)
	return _compara(q, vazute[-1] + pasi[-1] + crestere)


## „5, 12, 10, 17, 15, ?" — două operații care se schimbă între ele.
func _bate_alternant(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	var pasi := _diferentele(vazute)
	if pasi.size() < 4:
		return "enunt necitibil: %s" % q["text"]

	for i in range(2, pasi.size()):
		if pasi[i] != pasi[i - 2]:
			return "pasii nu alterneaza: %s" % _ca_text(vazute)
	if pasi[0] <= 0 or pasi[1] >= 0:
		return "nu urca in zigzag (%d, %d): %s" % [pasi[0], pasi[1], _ca_text(vazute)]
	# Pasul care urmează e cel de acum două trepte.
	return _compara(q, vazute[-1] + pasi[pasi.size() - 2])


## „3, 5, 9, 17, 33, ?" — pasul se dublează.
func _bate_pas_dublat(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	var pasi := _diferentele(vazute)
	if pasi.size() < 3:
		return "enunt necitibil: %s" % q["text"]
	if pasi[0] <= 0:
		return "primul pas %d" % pasi[0]

	for i in range(1, pasi.size()):
		if pasi[i] != pasi[i - 1] * 2:
			return "pasul nu se dubleaza: %s" % _ca_text(vazute)
	return _compara(q, vazute[-1] + pasi[-1] * 2)


## „3, 6, 8, 16, 18, ?" — ori 2, apoi +adaos, pe rând.
##
## Adaosul se DEDUCE din al doilea pas, apoi se verifică la toate treptele
## impare: dacă generatorul ar schimba adaosul pe parcurs, aici s-ar vedea.
func _bate_mixt(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	if vazute.size() < 4:
		return "enunt necitibil: %s" % q["text"]

	var adaos: int = vazute[2] - vazute[1]
	if adaos <= 0:
		return "adaos %d: %s" % [adaos, _ca_text(vazute)]
	for i in range(vazute.size() - 1):
		var asteptat: int = vazute[i] * 2 if i % 2 == 0 else vazute[i] + adaos
		if vazute[i + 1] != asteptat:
			return "treapta %d nu se potriveste: %s" % [i + 1, _ca_text(vazute)]

	var ultima := vazute.size() - 1
	return _compara(q, vazute[-1] * 2 if ultima % 2 == 0 else vazute[-1] + adaos)


## „2, 5, 7, 12, 19, ?" — fiecare termen e suma celor doi dinainte.
func _bate_fibonacci(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	if vazute.size() < 4:
		return "enunt necitibil: %s" % q["text"]

	for i in range(2, vazute.size()):
		if vazute[i] != vazute[i - 1] + vazute[i - 2]:
			return "nu e suma celor doi dinainte: %s" % _ca_text(vazute)
	return _compara(q, vazute[-1] + vazute[-2])


## „9, 16, 25, 36, 49, ?" — pătrate perfecte, uneori decalate.
##
## Socoteala nu caută rădăcini: diferența a doua a pătratelor e MEREU 2, iar din
## primul pas (2n+1) se află n. Apoi se verifică și decalajul, deci verdictul
## spune nu doar „e un șir pătratic", ci chiar „sunt pătratele numerelor de la n
## în sus, plus o constantă" — adică exact ce spune nota.
func _bate_patrate(q: Dictionary) -> String:
	var vazute := _numerele_din_sir(q)
	var pasi := _diferentele(vazute)
	if pasi.size() < 3:
		return "enunt necitibil: %s" % q["text"]

	for i in range(1, pasi.size()):
		if pasi[i] - pasi[i - 1] != 2:
			return "diferenta a doua nu e 2: %s" % _ca_text(vazute)
	if pasi[0] % 2 == 0:
		return "primul pas e par (%d), deci nu e 2n+1: %s" % [pasi[0], _ca_text(vazute)]

	var n: int = (pasi[0] - 1) / 2
	var adaos: int = vazute[0] - n * n
	if n <= 0 or adaos < 0 or adaos > 2:
		return "n = %d, adaos = %d: %s" % [n, adaos, _ca_text(vazute)]
	for i in range(vazute.size()):
		var rad := n + i
		if vazute[i] != rad * rad + adaos:
			return "%d nu e %d² + %d: %s" % [vazute[i], rad, adaos, _ca_text(vazute)]

	var urmatorul := n + vazute.size()
	return _compara(q, urmatorul * urmatorul + adaos)


# ─────────────────────────────────────────────────────────────
# 5. SOCOTELILE LITERELOR
#
# Aceleași reguli, numărate pe alfabet. Literele se trec în indici (A = 0), iar
# de acolo încolo socoteala e aritmetică — adică exact ce face și jucătorul.
# ─────────────────────────────────────────────────────────────

## „A, C, E, G, ?" — pas constant în alfabet.
func _bate_litere_pas(q: Dictionary) -> String:
	var vazute := _literele_din_sir(q)
	if vazute.size() < 3:
		return "enunt necitibil: %s" % q["text"]

	var pas: int = vazute[1] - vazute[0]
	if pas < 2:
		return "pas %d (sub 2 ar fi chiar alfabetul)" % pas
	for i in range(1, vazute.size()):
		if vazute[i] - vazute[i - 1] != pas:
			return "pasul nu e constant: %s" % q["text"]
	return _compara_litera(q, vazute[-1] + pas)


## „A, Z, B, Y, C, ?" — două fire împletite, unul în sus, unul în jos.
func _bate_litere_fire(q: Dictionary) -> String:
	var vazute := _literele_din_sir(q)
	if vazute.size() != 5:
		return "aștept 5 litere vizibile, am %d: %s" % [vazute.size(), q["text"]]

	# Firul întâi: locurile 1, 3, 5. Firul doi: locurile 2, 4 (și al șaselea,
	# care e răspunsul).
	var intai: Array[int] = [vazute[0], vazute[2], vazute[4]]
	var doi: Array[int] = [vazute[1], vazute[3]]

	var pas_intai: int = intai[1] - intai[0]
	if intai[2] - intai[1] != pas_intai:
		return "firul intai nu are pas constant: %s" % q["text"]
	var pas_doi: int = doi[1] - doi[0]
	if pas_intai == 0 or pas_doi == 0:
		return "un fir sta pe loc: %s" % q["text"]
	# Unul urcă, celălalt coboară — asta e chiar tiparul.
	if (pas_intai > 0) == (pas_doi > 0):
		return "amandoua firele merg in aceeasi direcție: %s" % q["text"]
	if absi(pas_intai) != absi(pas_doi):
		return "firele au pasi diferiti (%d, %d): %s" % [pas_intai, pas_doi, q["text"]]

	return _compara_litera(q, doi[1] + pas_doi)


## „A, B, D, G, K, ?" — pasul crește, numărat pe alfabet.
func _bate_litere_pas_crescator(q: Dictionary) -> String:
	var vazute := _literele_din_sir(q)
	var pasi := _diferentele(vazute)
	if pasi.size() < 3:
		return "enunt necitibil: %s" % q["text"]

	var crestere: int = pasi[1] - pasi[0]
	if crestere <= 0:
		return "pasul nu creste: %s" % q["text"]
	for i in range(1, pasi.size()):
		if pasi[i] - pasi[i - 1] != crestere:
			return "creșterea nu e constanta: %s" % q["text"]
	return _compara_litera(q, vazute[-1] + pasi[-1] + crestere)


# ─────────────────────────────────────────────────────────────
# 6. SOCOTELILE CICLULUI
# ─────────────────────────────────────────────────────────────

## „Q, M, B, F, Q, M, ?" — ce urmează.
##
## Perioada se AFLĂ din șir (cea mai mică lungime care se repetă peste tot), nu
## se presupune că e 4. Dacă generatorul ar scrie un șablon de altă lungime
## decât are, s-ar vedea aici.
func _bate_ciclu_urmatorul(q: Dictionary) -> String:
	var text := String(q["text"])
	if not text.ends_with(", ?"):
		return "enuntul nu se termina cu „, ?”: %s" % text
	var semne := _bucati(text.trim_suffix(", ?"))
	if semne.size() < 6:
		return "prea puține semne: %s" % text

	var perioada := _perioada(semne)
	if perioada <= 1 or perioada > semne.size() / 2:
		return "perioada %d din %d semne: %s" % [perioada, semne.size(), text]

	var asteptat: String = semne[semne.size() % perioada]
	var dat := String(q["variante"][int(q["corect"])])
	if dat != asteptat:
		return "butonul spune „%s”, sablonul da „%s”" % [dat, asteptat]
	return ""


## „Sablonul Q, M, B, F se repeta la nesfarsit. Ce semn e pe locul 23?"
func _bate_ciclu_pe_loc(q: Dictionary) -> String:
	var regex := RegEx.create_from_string(
		r"^Sablonul (.+) se repeta la nesfarsit\.\nCe semn e pe locul (\d+)\?$"
	)
	var potrivire := regex.search(String(q["text"]))
	if potrivire == null:
		return "enunt necitibil: %s" % String(q["text"]).replace("\n", " / ")

	var sablon := _bucati(potrivire.get_string(1))
	var loc := int(potrivire.get_string(2))
	if sablon.size() < 2 or loc < 1:
		return "sablon de %d, locul %d" % [sablon.size(), loc]

	# Pe locul 1 e primul semn, deci restul se ia din `loc - 1`.
	var asteptat: String = sablon[(loc - 1) % sablon.size()]
	var dat := String(q["variante"][int(q["corect"])])
	if dat != asteptat:
		return "butonul spune „%s”, locul %d cere „%s”" % [dat, loc, asteptat]
	return ""


## „Doua roti se intorc cu un semn la fiecare pas: Q, M, B si 1, 2, 3, 4.
##  La pasul 1 arata Q1. Ce arata la pasul 10?"
##
## Se verifică ȘI ce spune enunțul despre pasul 1: el e declarația din care
## pornește toată socoteala jucătorului, deci dacă n-ar fi chiar primul semn al
## fiecărei roți, întrebarea ar minți fără să se vadă nicăieri.
func _bate_ciclu_doua_roti(q: Dictionary) -> String:
	var regex := RegEx.create_from_string(
		r"^Doua roti se intorc cu un semn la fiecare pas: (.+) si (.+)\.\nLa pasul 1 arata (.+)\. Ce arata la pasul (\d+)\?$"
	)
	var potrivire := regex.search(String(q["text"]))
	if potrivire == null:
		return "enunt necitibil: %s" % String(q["text"]).replace("\n", " / ")

	var una := _bucati(potrivire.get_string(1))
	var alta := _bucati(potrivire.get_string(2))
	var la_unu := potrivire.get_string(3)
	var pas := int(potrivire.get_string(4))
	if una.size() < 2 or alta.size() < 2 or pas < 2:
		return "roti de %d si %d, pasul %d" % [una.size(), alta.size(), pas]

	if la_unu != "%s%s" % [una[0], alta[0]]:
		return "la pasul 1 enuntul spune „%s”, rotile dau „%s%s”" % [la_unu, una[0], alta[0]]
	# Lungimi prime între ele: altfel o parte din perechi nu apar niciodată, iar
	# întrebarea e despre o singură roată.
	if _cmmdc(una.size(), alta.size()) != 1:
		return "lungimile %d si %d nu sunt prime intre ele" % [una.size(), alta.size()]

	var asteptat := "%s%s" % [
		una[(pas - 1) % una.size()], alta[(pas - 1) % alta.size()]
	]
	var dat := String(q["variante"][int(q["corect"])])
	if dat != asteptat:
		return "butonul spune „%s”, pasul %d da „%s”" % [dat, pas, asteptat]
	return ""


# ─────────────────────────────────────────────────────────────
# 7. SOCOTEALA INTRUSULUI, plus proba de unicitate
# ─────────────────────────────────────────────────────────────

## Nota spune ce ar fi trebuit să fie pe locul intrusului; se verifică amândouă
## capetele: că numărul „greșit" din notă e chiar cel din enunț, și că șirul
## REPARAT se ține pe o regulă.
func _bate_intrusul(q: Dictionary) -> String:
	var text := String(q["text"])
	if not text.begins_with("Care numar strica regula?\n"):
		return "enunt necitibil: %s" % text.replace("\n", " / ")
	var termeni := _numerele(text.trim_prefix("Care numar strica regula?\n"))
	if termeni.size() < 5:
		return "prea puține numere: %s" % text.replace("\n", " / ")

	var dat := String(q["variante"][int(q["corect"])])
	if not dat.is_valid_int():
		return "butonul corect nu e un numar: „%s”" % dat
	var intrus := int(dat)

	# Butonul corect trebuie să fie UN NUMĂR DIN ȘIR, nu unul inventat: tot
	# rostul tiparului e să alegi dintre numerele de pe ecran.
	var k := termeni.find(intrus)
	if k < 0:
		return "butonul „%s” nu e in sir: %s" % [dat, _ca_text(termeni)]
	# Și toate celelalte variante, la fel.
	for varianta in q["variante"]:
		var v := String(varianta)
		if not v.is_valid_int() or not (int(v) in termeni):
			return "varianta „%s” nu e in sir: %s" % [v, _ca_text(termeni)]

	var nota := RegEx.create_from_string(
		r"Pe locul (\d+) ar fi trebuit (-?\d+), nu (-?\d+)\."
	).search(String(q["explicatie"]))
	if nota == null:
		return "nota necitibila: %s" % q["explicatie"]
	var locul := int(nota.get_string(1))
	var curat := int(nota.get_string(2))
	var stricat := int(nota.get_string(3))

	if locul - 1 != k:
		return "nota zice locul %d, butonul e pe locul %d" % [locul, k + 1]
	if stricat != intrus:
		return "nota zice ca e gresit %d, butonul spune %d" % [stricat, intrus]

	var reparat := termeni.duplicate()
	reparat[k] = curat
	if not _se_tine_pe_o_regula(reparat, -1):
		return "sirul reparat nu se tine pe nicio regula: %s" % _ca_text(reparat)
	return ""


## PROBA DE UNICITATE, și cea mai importantă din toată verificarea.
##
## Jocul își apără unicitatea cu `_pozitii_posibile` din `tipare.gd`, care
## REZOLVĂ un sistem (determinanți). Aici se face altfel, dinadins: se
## ENUMERĂ regulile, cu parametri din intervalele scrise mai jos, și se numără
## câte poziții pot fi intrusul. Două metode diferite care dau același răspuns
## e singura dovadă pe care o poate avea oricare din ele.
##
## Ce acoperă, scris pe față: cele TREI FAMILII pe care disciplina le predă.
## Vezi antetul tipului INTRUS din `tipare.gd` — garanția nu e „niciun cititor
## nu poate născoci altă regulă", e „printre regulile pe care jocul le-a arătat
## vreodată, răspunsul e unul singur".
func _intrusul_singur() -> bool:
	print("  INTRUSUL E SINGUR (%d enigme pe tipar, rezolvate din nou)" % TRAGERI_INTRUS)
	var rezultat := true

	for generator in TIPARE.GENERATOARE:
		if String(generator["tip"]) != "INTRUS":
			continue
		var metoda := String(generator["metoda"])
		var cu_doua: Array[String] = []
		var fara_niciuna: Array[String] = []
		var rezolvate := 0
		for nivel in generator["niveluri"]:
			for i in range(TRAGERI_INTRUS):
				var q: Dictionary = scena.call(metoda, nivel)
				if q.is_empty():
					continue
				rezolvate += 1
				var termeni := _numerele(
					String(q["text"]).trim_prefix("Care numar strica regula?\n")
				)
				var posibile := _pozitii_posibile(termeni)
				var intrus := int(String(q["variante"][int(q["corect"])]))
				if posibile.size() > 1:
					cu_doua.append("%s: %s (pozitiile %s)" % [
						metoda, _ca_text(termeni), _ca_text(posibile)
					])
				elif posibile.size() == 0 or termeni[posibile[0]] != intrus:
					fara_niciuna.append("%s: %s" % [metoda, _ca_text(termeni)])

		rezultat = _verdict(
			"%s: raspunsul e unul singur" % metoda,
			cu_doua.is_empty() and fara_niciuna.is_empty(),
			_primele(cu_doua + fara_niciuna, 3) if not (cu_doua + fara_niciuna).is_empty()
				else "%d enigme" % rezolvate
		) and rezultat

	return rezultat


## Pozițiile care ar putea fi intrusul, aflate prin ENUMERARE.
func _pozitii_posibile(termeni: Array[int]) -> Array[int]:
	var posibile: Array[int] = []
	for k in range(termeni.size()):
		if _se_tine_pe_o_regula(termeni, k):
			posibile.append(k)
	return posibile


## Restul termenilor (toți, dacă `k` e -1) stau pe o regulă din cele trei
## familii? Se încearcă, pe rând, fiecare combinație de parametri.
func _se_tine_pe_o_regula(termeni: Array[int], k: int) -> bool:
	var pozitii: Array[int] = []
	for p in range(termeni.size()):
		if p != k:
			pozitii.append(p)
	if pozitii.size() < 4:
		return true

	var p0: int = pozitii[0]
	var t0: int = termeni[p0]

	# PAS CONSTANT: t[p] = t0 + d·(p − p0).
	for d in range(-24, 25):
		if d == 0:
			continue
		var bun := true
		for p in pozitii:
			if termeni[p] != t0 + d * (p - p0):
				bun = false
				break
		if bun:
			return true

	# FACTOR CONSTANT: t[p] = t0 · r^(p − p0). Numai factori întregi mici —
	# un raport fracționar n-ar da șiruri de întregi, deci nu poate veni din
	# niciun generator de aici.
	for r in range(2, 6):
		var bun := true
		for p in pozitii:
			var asteptat := t0
			for i in range(p - p0):
				asteptat *= r
			if termeni[p] != asteptat:
				bun = false
				break
		if bun:
			return true

	# PAS CRESCĂTOR: pasul pornește de la `s` și crește cu `c` la fiecare
	# treaptă. Se construiește șirul de la p0 în sus și se compară.
	for s in range(-20, 21):
		for c in range(1, 9):
			var valoare := t0
			var pas := s
			# Pașii de dinaintea lui p0 nu există: p0 e primul termen rămas, deci
			# „s" e chiar pasul de la el încolo.
			var asteptate := {p0: t0}
			for p in range(p0 + 1, termeni.size()):
				valoare += pas
				pas += c
				asteptate[p] = valoare
			var bun := true
			for p in pozitii:
				if termeni[p] != int(asteptate[p]):
					bun = false
					break
			if bun:
				return true

	return false


# ─────────────────────────────────────────────────────────────
# 8. ȘABLONUL E CHIAR PE BUTOANE (decizie de design, la CICLU)
# ─────────────────────────────────────────────────────────────

func _sablonul_pe_butoane() -> bool:
	print("  SABLONUL PE BUTOANE")
	var rezultat := true

	for metoda in ["_ciclu_urmatorul", "_ciclu_pe_loc"]:
		var strainte: Array[String] = []
		for generator in TIPARE.GENERATOARE:
			if String(generator["metoda"]) != metoda:
				continue
			for nivel in generator["niveluri"]:
				for i in range(TRAGERI_PE_TIPAR):
					var q: Dictionary = scena.call(metoda, nivel)
					if q.is_empty():
						continue
					var sablon := _sablonul_din(q)
					if sablon.is_empty():
						strainte.append("%s: nu gasesc sablonul" % metoda)
						break
					for varianta in q["variante"]:
						if not (String(varianta) in sablon):
							strainte.append("%s: „%s” nu e in sablon" % [metoda, varianta])
							break
		rezultat = _verdict(
			"%s: toate variantele sunt semne din sablon" % metoda,
			strainte.is_empty(), _primele(strainte, 3)
		) and rezultat

	return rezultat


## Semnele șablonului, oricare din cele două forme de enunț.
func _sablonul_din(q: Dictionary) -> Array[String]:
	var text := String(q["text"])
	if text.begins_with("Sablonul "):
		var pana_la := text.find(" se repeta")
		if pana_la < 0:
			return []
		return _bucati(text.substr(9, pana_la - 9))
	if text.ends_with(", ?"):
		var semne := _bucati(text.trim_suffix(", ?"))
		var perioada := _perioada(semne)
		if perioada <= 1:
			return []
		var sablon: Array[String] = []
		for i in range(perioada):
			sablon.append(semne[i])
		return sablon
	return []


# ─────────────────────────────────────────────────────────────
# 9. ALFABETUL SE DECLARĂ (decizie de design, la LITERE)
# ─────────────────────────────────────────────────────────────

func _alfabetul_declarat() -> bool:
	print("  ALFABETUL DECLARAT")
	var rezultat := true

	var fara: Array[String] = []
	for generator in TIPARE.GENERATOARE:
		if String(generator["tip"]) != "LITERE":
			continue
		var metoda := String(generator["metoda"])
		for nivel in generator["niveluri"]:
			for i in range(20):
				var q: Dictionary = scena.call(metoda, nivel)
				if q.is_empty():
					continue
				if not String(q["text"]).begins_with(TIPARE.ANTET_ALFABET):
					fara.append("%s/%d" % [metoda, nivel])
					break

	rezultat = _verdict(
		"fiecare intrebare de litere spune pe ce alfabet se numara",
		fara.is_empty(), _primele(fara, 5)
	) and rezultat
	# Și alfabetul însuși: 26 de litere latine, fără diacritice. Un „Ă" strecurat
	# în el ar aduce înapoi chiar ambiguitatea pentru care există antetul.
	rezultat = _verdict(
		"alfabetul are 26 de litere, A-Z",
		TIPARE.ALFABET == "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		TIPARE.ALFABET
	) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 10. NIVELUL SE VEDE
#
# Numai la tiparele care apar la mai multe niveluri, și fiecare cu măsura lui
# (vezi `CRESC_PE_NIVEL`). La celelalte nu există ce să crească: dificultatea e
# a REGULII, iar că Fibonacci e mai greu decât pasul constant e o judecată, nu
# o socoteală.
# ─────────────────────────────────────────────────────────────

func _nivelul_se_vede() -> bool:
	print("  NIVELUL SE VEDE (la tiparele cu mai multe niveluri)")
	var rezultat := true

	for generator in TIPARE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var niveluri: Array = generator["niveluri"]
		if niveluri.size() < 2:
			continue
		var masura := String(CRESC_PE_NIVEL[metoda])

		var medii: Array[float] = []
		for nivel in niveluri:
			var suma := 0.0
			var cate := 0
			for i in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, nivel)
				if q.is_empty():
					continue
				suma += float(call(masura, q))
				cate += 1
			medii.append(suma / maxf(1.0, float(cate)))

		var creste := true
		for i in range(1, medii.size()):
			if medii[i] <= medii[i - 1]:
				creste = false
		var scris: Array[String] = []
		for medie in medii:
			scris.append("%.1f" % medie)
		rezultat = _verdict(
			"%s creste de la un nivel la altul" % metoda, creste, " → ".join(scris)
		) and rezultat

	return rezultat


## Distanța dintre primele două litere — pasul, la șirurile simple.
func _masoara_pasul(q: Dictionary) -> float:
	var litere := _literele_din_sir(q)
	if litere.size() < 2:
		return 0.0
	return absf(float(litere[1] - litere[0]))


## Distanța dintre literele 1 și 3 — pasul unui FIR. Între 1 și 2 n-ar fi o
## măsură: alea sunt din fire diferite, iar distanța dintre ele e cât de
## departe au pornit firele, nu cât de repede merg.
func _masoara_pasul_firului(q: Dictionary) -> float:
	var litere := _literele_din_sir(q)
	if litere.size() < 3:
		return 0.0
	return absf(float(litere[2] - litere[0]))


## Suma cifrelor din enunț. La `_ciclu_pe_loc` cresc amândouă deodată: lungimea
## șablonului (împărțitorul) și locul cerut.
func _masoara_cifrele(q: Dictionary) -> float:
	var suma := 0
	for potrivire in RegEx.create_from_string(r"\d+").search_all(String(q["text"])):
		suma += int(potrivire.get_string())
	return float(suma)


# ─────────────────────────────────────────────────────────────
# 11. FONTURILE AU CARACTERELE
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

	var caractere := {}
	for generator in TIPARE.GENERATOARE:
		for nivel in generator["niveluri"]:
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
			# Sub 32 sunt spațiul și linia nouă: fonturile nu le declară.
			if cod < 32:
				continue
			if not font.has_char(cod):
				lipsa.append("„%s” (U+%04X)" % [ch, cod])
		rezultat = _verdict(
			"%s are toate caracterele" % nume, lipsa.is_empty(), _primele(lipsa, 8)
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 12. ECHILIBRUL PE TIPURI
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL (%d trageri pe nivel)" % TRAGERI_ECHILIBRU)
	var rezultat := true

	var tip_pe_antet := {}
	for generator in TIPARE.GENERATOARE:
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
			strambe.is_empty(), _primele(strambe, 5)
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 13. FĂRĂ REPETIȚII PE EXPEDIȚIE
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
# 14. CÂT SE CITEȘTE — nu dă verdicte, TIPĂREȘTE
# ─────────────────────────────────────────────────────────────

func _cat_se_citeste() -> void:
	print("\n  CAT SE CITESTE (cea mai lunga intrebare, pe tipar)")
	for generator in TIPARE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var lung := String(cel_mai_lung.get(metoda, ""))
		print("    %-26s %3d semne   %s" % [
			metoda, lung.length(), lung.replace("\n", " / ")
		])

	print("\n  O MOSTRA DIN FIECARE TIPAR")
	for generator in TIPARE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var q: Dictionary = o_mostra.get(metoda, {})
		if q.is_empty():
			continue
		print("\n    [%s]  %s" % [generator["categorie"], String(q["text"]).replace("\n", " / ")])
		var variante: Array = q["variante"]
		for i in range(variante.size()):
			print("       %s %s" % ["→" if i == int(q["corect"]) else " ", variante[i]])
		print("       nota: %s" % q["explicatie"])


func _culege(metoda: String, q: Dictionary) -> void:
	var text := String(q["text"])
	if text.length() > String(cel_mai_lung.get(metoda, "")).length():
		cel_mai_lung[metoda] = text
	if not o_mostra.has(metoda) or randf() < 0.01:
		o_mostra[metoda] = q


# ─────────────────────────────────────────────────────────────
# UNELTELE
# ─────────────────────────────────────────────────────────────

## Butonul marcat corect, citit ca număr, comparat cu ce-a ieșit din regulă.
func _compara(q: Dictionary, asteptat: int) -> String:
	var text := String(q["variante"][int(q["corect"])])
	if not text.is_valid_int():
		return "butonul corect nu e un numar: „%s”" % text
	if int(text) != asteptat:
		return "butonul spune %s, regula da %d" % [text, asteptat]
	return ""


## La fel, pentru litere: indicele așteptat se trece în literă.
func _compara_litera(q: Dictionary, indice: int) -> String:
	if indice < 0 or indice >= TIPARE.ALFABET.length():
		return "regula cere indicele %d, care nu e o litera" % indice
	var asteptat: String = TIPARE.ALFABET[indice]
	var dat := String(q["variante"][int(q["corect"])])
	if dat != asteptat:
		return "butonul spune „%s”, regula da „%s”" % [dat, asteptat]
	return ""


## „3, 7, 11, 15, 19, ?" → [3, 7, 11, 15, 19].
func _numerele_din_sir(q: Dictionary) -> Array[int]:
	var text := String(q["text"])
	if not text.ends_with(", ?"):
		return []
	return _numerele(text.trim_suffix(", ?"))


## „In alfabetul A-Z:\nA, C, E, G, ?" → [0, 2, 4, 6], ca indici.
func _literele_din_sir(q: Dictionary) -> Array[int]:
	var text := String(q["text"])
	if not (text.begins_with(TIPARE.ANTET_ALFABET) and text.ends_with(", ?")):
		return []
	var curat := text.trim_prefix(TIPARE.ANTET_ALFABET).trim_suffix(", ?")
	var indici: Array[int] = []
	for bucata in _bucati(curat):
		var indice := TIPARE.ALFABET.find(bucata)
		if bucata.length() != 1 or indice < 0:
			return []
		indici.append(indice)
	return indici


## „2, 5, 8, 12" → [2, 5, 8, 12]. Listă goală dacă ceva nu e un număr.
func _numerele(text: String) -> Array[int]:
	var numere: Array[int] = []
	for bucata in _bucati(text):
		if not bucata.is_valid_int():
			return []
		numere.append(int(bucata))
	return numere


## Textul tăiat pe „, ".
func _bucati(text: String) -> Array[String]:
	var bucati: Array[String] = []
	for bucata in text.split(", "):
		bucati.append(String(bucata).strip_edges())
	return bucati


## Diferențele dintre termenii vecini.
func _diferentele(valori: Array[int]) -> Array[int]:
	var diferente: Array[int] = []
	for i in range(1, valori.size()):
		diferente.append(valori[i] - valori[i - 1])
	return diferente


## Cea mai mică lungime care se repetă în tot șirul. `semne.size()` dacă nu se
## repetă nimic.
func _perioada(semne: Array[String]) -> int:
	for p in range(1, semne.size()):
		var bun := true
		for i in range(semne.size()):
			if semne[i] != semne[i % p]:
				bun = false
				break
		if bun:
			return p
	return semne.size()


## Cel mai mare divizor comun — pentru „lungimile sunt prime între ele".
func _cmmdc(a: int, b: int) -> int:
	while b != 0:
		var r := a % b
		a = b
		b = r
	return a


func _ca_text(valori: Array) -> String:
	var bucati: Array[String] = []
	for valoare in valori:
		bucati.append(str(valoare))
	return ", ".join(bucati)


func _tipurile() -> Array:
	var tipuri := {}
	for generator in TIPARE.GENERATOARE:
		tipuri[String(generator["tip"])] = true
	return tipuri.keys()


func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-48s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array, cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(String(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

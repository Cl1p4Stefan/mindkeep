extends Node
## VERIFICAREA REFLEXULUI — cele 4 tipuri, cele 12 tipare, și IMPULSUL.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_reflex.tscn
##
## ─────────────────────────────────────────────────────────────
## CE E ALTFEL AICI: SE VERIFICĂ ȘI CĂ ÎNTREBAREA E GREA
##
## Toate celelalte șapte verificări bat un singur fel de adevăr: răspunsul
## marcat drept corect ESTE corect. Se recalculează din enunț (Numere), se
## rezolvă din nou cu altă metodă (Spațial), se citește din ce s-a arătat
## (Reținere) — dar întrebarea e, în toate, „e bun răspunsul?".
##
## Aici ăsta e doar jumătate din treabă, fiindcă disciplina nu promite un
## răspuns corect, promite o CAPCANĂ (vezi antetul lui `reflex.gd`: „răspunsul
## care-ți vine primul e greșit"). Un tipar de Reflex poate avea răspunsul
## perfect calculat și totuși să nu fie un tipar de Reflex: dacă pe butoane nu
## stă și impulsul, întrebarea e corectă și nu măsoară nimic.
##
## Deci există o secțiune a doua, IMPULSUL, care pentru fiecare tipar calculează
## răspunsul GREȘIT pe care l-ar da o mână mai rapidă decât mintea, și cere două
## lucruri: că e ALTUL decât răspunsul bun, și că e PE UN BUTON. Niciunul din ele
## nu crapă nimic și niciunul nu se vede în altă verificare.
##
## Secțiunea asta e singurul loc din tot proiectul în care se verifică o
## intenție de DESIGN, nu o socoteală — și se poate verifica doar fiindcă
## intenția a fost scrisă ca o regulă („primul candidat e impulsul"), nu ca o
## speranță.
##
## ─────────────────────────────────────────────────────────────
## DRUMUL INVERS, CA LA REȚINERE
##
## Răspunsul se reface din PLANȘĂ, nu din ce-și amintește generatorul. El
## pornește de la o așezare trasă la sorți și COMPUNE semnele; verificarea
## pornește de la SEMNE și află așezarea: citește locurile, felurile,
## direcțiile, mărimile, și răspunde singură.
##
## Aici drumul invers prinde ceva ce la alte discipline nici n-ar fi existat: un
## cuvânt desenat la alt loc decât cel pe care-l crede generatorul ar lăsa
## răspunsul „corect" și întrebarea imposibilă, fiindcă la disciplina asta
## PLANȘA E ÎNTREBAREA. Enunțul „Unde e scris cuvantul DREAPTA?" are patru
## forme posibile în tot tiparul; tot restul e în desen.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## **Dacă interferența se simte.** Nu e un verdict, e o măsurătoare pe un om, și
## antetul lui `reflex.gd` spune pe față care e îndoiala: cu 12 secunde pe
## întrebare, un jucător răbdător învinge orice Stroop. Ce se poate verifica (și
## se verifică) e că impulsul există, că e pe un buton, și că numărul de semne
## crește de la un nivel la altul.
##
## **Dacă fulgerul arată ca un fulger.** Glifa se judecă cu ochiul, pe butonul
## de 40 px, într-o luptă adevărată — „arată bine?" n-a fost niciodată un
## verdict în proiectul ăsta (vezi `verifica_steaguri`).

const REFLEX := preload("res://scenes/reflex/reflex.gd")
const PLANSA := preload("res://scenes/reflex/plansa.gd")

# Câte întrebări se trag din fiecare tipar, la fiecare nivel din tabelul lui.
const TRAGERI_PE_TIPAR := 200

# Echilibrul pe tipuri. La 4 tipuri ar trebui să iasă ~2000 fiecare.
const TRAGERI_ECHILIBRU := 8000
const TOLERANTA_ECHILIBRU := 0.20

# Cât poate pica un tipar fără ca asta să fie o problemă.
#
# 0,35 e mai sus decât la Reținere (0,2) și mai jos decât la Spațial (0,5), și
# cifra are un vinovat anume: `_cifre_mai_mare` aruncă așezările de mărimi în
# care răspunsul ar sta pe cifra desenată cel mai mare sau cel mai mic — adică
# jumătate din ele, prin construcție (vezi comentariul din el). Restul tiparelor
# nu au niciun motiv structural să cadă, deci dacă unul din ele urcă aproape de
# plafon, ascunde o scăpare.
const MAX_RATA_DE_ESEC := 0.35

const TRAGERI_SAC := 300

# Cât de puține întrebări deosebite poate avea o combinație de tipar și nivel.
# Vezi `_fara_repetitii()` pentru de unde vine cifra — și pentru pragul greșit
# care a stat aici înainte.
const MINIM_PE_TIPAR := 8

const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"

# ─────────────────────────────────────────────────────────────
# CINE REZOLVĂ CE
#
# Un rând pe tipar, și `_tabelul()` cere ca fiecare metodă din `GENERATOARE` să
# aibă unul: un tipar adăugat mâine fără rezolvitor face verificarea să PICE, în
# loc să treacă drept acoperit.
#
# Fiecare rezolvitor întoarce un dicționar cu DOUĂ câmpuri, și asta e deosebirea
# față de celelalte șapte verificări:
#   „corect" — răspunsul, refăcut din planșă;
#   „impuls" — răspunsul greșit care trebuie să fie pe un buton.
# Unde impulsul e o LISTĂ (mai multe cuvinte pe ecran, oricare putând fi citit
# primul), se cere ca MĂCAR unul să fie pe buton și NICIUNUL să fie corect.
# ─────────────────────────────────────────────────────────────
const REZOLVARI := {
	"_cuvant_unde": "_bate_cuvant_unde",
	"_cuvant_care": "_bate_cuvant_care",
	"_cuvant_incotro": "_bate_cuvant_incotro",
	"_cifre_cate": "_bate_cifre_cate",
	"_cifre_care": "_bate_cifre_care",
	"_cifre_mai_mare": "_bate_cifre_mai_mare",
	"_sageti_mijlocul": "_bate_sageti_mijlocul",
	"_sageti_cate": "_bate_sageti_cate",
	"_sageti_opusul": "_bate_sageti_opusul",
	"_forme_care": "_bate_forme_care",
	"_forme_scrie": "_bate_forme_scrie",
	"_forme_cate": "_bate_forme_cate",
}

# ─────────────────────────────────────────────────────────────
# TABELELE, SCRISE A DOUA OARĂ
#
# Locurile, numele locurilor, numele sensurilor, cuvintele direcțiilor și
# numele formelor — toate scrise aici de mână, nu luate din `reflex.gd`.
#
# Din același motiv pentru care Spațialul își rescrie tabelele de întoarceri și
# Reținerea antetele expunerii: o verificare care citește chiar tabelul din care
# vine răspunsul e de acord cu el orice ar scrie în el. Dacă mâine „la stanga"
# devine „in stanga" în joc, aici trebuie să PICE — iar atunci mă uit dacă e o
# îmbunătățire sau o scăpare, în loc ca schimbarea să treacă în tăcere.
# ─────────────────────────────────────────────────────────────
const LOCURI := {
	"sus": Vector2(0.50, 0.15),
	"jos": Vector2(0.50, 0.85),
	"stanga": Vector2(0.20, 0.50),
	"dreapta": Vector2(0.80, 0.50),
}

const NUME_LOC := {
	"sus": "sus", "jos": "jos", "stanga": "la stanga", "dreapta": "la dreapta",
}

const NUME_SENS := {
	"sus": "in sus", "jos": "in jos", "stanga": "la stanga", "dreapta": "la dreapta",
}

const CUVANT_DIRECTIE := {
	"sus": "SUS", "jos": "JOS", "stanga": "STANGA", "dreapta": "DREAPTA",
}

const OPUSE := {"sus": "jos", "jos": "sus", "stanga": "dreapta", "dreapta": "stanga"}

const NUME_FORMA := {
	"cerc": "cerc", "patrat": "patrat", "triunghi": "triunghi", "romb": "romb",
}

const CUVANT_FORMA := {
	"cerc": "CERC", "patrat": "PATRAT", "triunghi": "TRIUNGHI", "romb": "ROMB",
}

const PLURAL_FORMA := {
	"cerc": "cercuri", "patrat": "patrate",
	"triunghi": "triunghiuri", "romb": "romburi",
}

# Cât de aproape trebuie să cadă un semn de locul lui ca să-l recunoaștem.
# 0,02 din casetă, adică vreo 7 px pe lățime: destul ca o virgulă mutată într-un
# tabel de locuri să nu treacă, și larg cât să nu depindă de rotunjiri.
const APROAPE := 0.02

var scena = null
var tot_bun := true

var cel_mai_lung := {}
var o_mostra := {}


func _ready() -> void:
	print("\n══ VERIFICAREA REFLEXULUI ══\n")

	# Scriptul, nu scena: niciun generator nu atinge un buton, iar planșa se
	# citește ca date. Deci nu se deschide nicio fereastră.
	scena = REFLEX.new()

	tot_bun = _tabelul() and tot_bun
	tot_bun = _nivelurile() and tot_bun
	tot_bun = _contractul_si_rezolvarea() and tot_bun
	tot_bun = _impulsul() and tot_bun
	tot_bun = _plansele() and tot_bun
	tot_bun = _cat_de_mult() and tot_bun
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
	var nerezolvate: Array[String] = []
	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		if not scena.has_method(metoda):
			lipsa.append(metoda)
		if not REZOLVARI.has(metoda):
			nerezolvate.append(metoda)

	rezultat = _verdict(
		"toate metodele exista pe script", lipsa.is_empty(), _primele(lipsa, 5)
	) and rezultat

	# CLICHETUL: un tipar nou nu poate intra neverificat.
	rezultat = _verdict(
		"fiecare tipar are cine sa-l rezolve din nou",
		nerezolvate.is_empty(), _primele(nerezolvate, 5)
	) and rezultat

	var metode_din_joc := {}
	for generator in REFLEX.GENERATOARE:
		metode_din_joc[String(generator["metoda"])] = true
	var orfane: Array[String] = []
	for metoda in REZOLVARI:
		if not metode_din_joc.has(metoda):
			orfane.append(String(metoda))
	rezultat = _verdict(
		"nicio rezolvare fara tiparul ei", orfane.is_empty(), _primele(orfane, 5)
	) and rezultat

	# ANTETUL E AL UNUI SINGUR TIP. Dacă două tipuri ar folosi aceeași
	# categorie, antetul de pe ecran ar minți despre ce fel de întrebare e —
	# singura informație pe care o ai înainte s-o citești.
	var tip_pe_categorie := {}
	var impartite: Array[String] = []
	for generator in REFLEX.GENERATOARE:
		var categorie := String(generator["categorie"])
		var tip := String(generator["tip"])
		if tip_pe_categorie.has(categorie) and tip_pe_categorie[categorie] != tip:
			impartite.append(categorie)
		tip_pe_categorie[categorie] = tip
	rezultat = _verdict(
		"antetul e al unui singur tip", impartite.is_empty(), _primele(impartite, 5)
	) and rezultat

	# Cele patru tipuri și cele douăsprezece tipare, numărate. Nu e o
	# formalitate: un tipar șters din greșeală la o curățenie nu se vede altfel.
	var tipuri := {}
	for generator in REFLEX.GENERATOARE:
		tipuri[String(generator["tip"])] = true
	rezultat = _verdict(
		"patru tipuri", tipuri.size() == 4, "%d" % tipuri.size()
	) and rezultat
	rezultat = _verdict(
		"douasprezece tipare", REFLEX.GENERATOARE.size() == 12,
		"%d" % REFLEX.GENERATOARE.size()
	) and rezultat

	# Nivelurile declarate sunt 1, 2, 3 și nimic altceva — un „4" strecurat
	# într-un rând ar face tiparul invizibil, fără nicio eroare.
	var niveluri_rele: Array[String] = []
	for generator in REFLEX.GENERATOARE:
		for nivel in generator["niveluri"]:
			if not (int(nivel) in [1, 2, 3]):
				niveluri_rele.append("%s:%s" % [generator["metoda"], nivel])
	rezultat = _verdict(
		"niveluri numai 1-3", niveluri_rele.is_empty(), _primele(niveluri_rele, 5)
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 2. NIVELURILE
# ─────────────────────────────────────────────────────────────

func _nivelurile() -> bool:
	print("  NIVELURILE")
	var rezultat := true

	# FIECARE TIP LA TOATE TREI NIVELURILE. Regula e scrisă în antetul lui
	# `reflex.gd`; aici o bate un verdict. Un tip care ar lipsi de la un nivel
	# ar face disciplina să se joace altfel la nivelul ăla, fără niciun semn.
	var pe_tip := {}
	for generator in REFLEX.GENERATOARE:
		var tip := String(generator["tip"])
		if not pe_tip.has(tip):
			pe_tip[tip] = {}
		for nivel in generator["niveluri"]:
			pe_tip[tip][int(nivel)] = true

	var gauri: Array[String] = []
	for tip in pe_tip:
		for nivel in [1, 2, 3]:
			if not pe_tip[tip].has(nivel):
				gauri.append("%s@%d" % [tip, nivel])
	rezultat = _verdict(
		"fiecare tip la toate trei nivelurile", gauri.is_empty(), _primele(gauri, 6)
	) and rezultat

	# Și niciun nivel fără tipare, altfel ar fi un ecran de eroare în mijlocul
	# unui lanț (vezi plasa de siguranță din `_retete_amestecate`).
	var goale: Array[String] = []
	for nivel in [1, 2, 3]:
		var cate := 0
		for generator in REFLEX.GENERATOARE:
			if nivel in generator["niveluri"]:
				cate += 1
		if cate == 0:
			goale.append(str(nivel))
	rezultat = _verdict(
		"niciun nivel fara tipare", goale.is_empty(), _primele(goale, 3)
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 3. CONTRACTUL ȘI RĂSPUNSUL REFĂCUT DIN PLANȘĂ
# ─────────────────────────────────────────────────────────────

func _contractul_si_rezolvarea() -> bool:
	print("  CONTRACTUL SI RASPUNSUL REFACUT DIN PLANSA")
	var rezultat := true

	var contract_rele: Array[String] = []
	var raspuns_rele: Array[String] = []
	var esecuri: Array[String] = []

	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		var rezolvitor := String(REZOLVARI.get(metoda, ""))
		if rezolvitor == "":
			continue
		for nivel in generator["niveluri"]:
			var picate := 0
			for _tragere in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					picate += 1
					continue
				_culege(metoda, q)

				var plangere := _contractul_unei_intrebari(q)
				if plangere != "":
					contract_rele.append("%s@%s %s" % [metoda, nivel, plangere])
					continue

				var bate: Dictionary = call(rezolvitor, q)
				if bate.has("eroare"):
					raspuns_rele.append("%s@%s %s" % [metoda, nivel, bate["eroare"]])
					continue
				if String(bate["corect"]) != _corecta(q):
					raspuns_rele.append("%s@%s zice %s, jocul %s" % [
						metoda, nivel, bate["corect"], _corecta(q)
					])

			var rata := float(picate) / float(TRAGERI_PE_TIPAR)
			if rata > MAX_RATA_DE_ESEC:
				esecuri.append("%s@%s %.0f%%" % [metoda, nivel, rata * 100.0])

	rezultat = _verdict(
		"contractul (4 variante, raspuns, nota)",
		contract_rele.is_empty(), _primele(contract_rele, 4)
	) and rezultat
	rezultat = _verdict(
		"raspunsul refacut din plansa la toate 12",
		raspuns_rele.is_empty(), _primele(raspuns_rele, 4)
	) and rezultat
	rezultat = _verdict(
		"niciun tipar nu pica prea des", esecuri.is_empty(), _primele(esecuri, 4)
	) and rezultat

	print("")
	return rezultat


## Ce trebuie să fie adevărat despre ORICE întrebare, oricare ar fi tiparul.
## Întoarce plângerea, sau șir gol dacă e în regulă.
func _contractul_unei_intrebari(q: Dictionary) -> String:
	if not q.has("text") or String(q["text"]) == "":
		return "fara enunt"
	var variante: Array = q.get("variante", [])
	if variante.size() != 4:
		return "%d variante" % variante.size()
	var vazute := {}
	for varianta in variante:
		var v := String(varianta)
		if v == "":
			return "varianta goala"
		if vazute.has(v):
			return "varianta dubla: %s" % v
		vazute[v] = true
	var corect := int(q.get("corect", -1))
	if corect < 0 or corect >= variante.size():
		return "indice de raspuns: %d" % corect
	if not q.has("explicatie") or String(q["explicatie"]) == "":
		return "fara nota"
	# Expunerea e a Reținerii. Un câmp `expunere` strecurat aici ar ascunde
	# planșa exact în disciplina la care ea ESTE întrebarea — iar nimeni n-ar
	# vedea de ce, fiindcă ecranul ar fi corect construit.
	if q.has("expunere") or q.has("text_expunere"):
		return "are expunere, desi Reflexul nu ascunde nimic"
	return ""


# ─────────────────────────────────────────────────────────────
# 4. IMPULSUL — secțiunea care nu există la nicio altă disciplină
#
# Vezi antetul fișierului. Două cerințe pe fiecare întrebare:
#   • impulsul NU e răspunsul corect — altfel întrebarea răsplătește tocmai ce
#     disciplina cere să ții deoparte;
#   • impulsul E pe un buton — altfel nu există nicio capcană, iar întrebarea
#     e doar o întrebare.
# ─────────────────────────────────────────────────────────────

func _impulsul() -> bool:
	print("  IMPULSUL (greseala care-ti vine prima)")
	var rezultat := true

	var impuls_corect: Array[String] = []
	var impuls_lipsa: Array[String] = []
	var fara_impuls: Array[String] = []

	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		var rezolvitor := String(REZOLVARI.get(metoda, ""))
		if rezolvitor == "":
			continue
		for nivel in generator["niveluri"]:
			for _tragere in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				var bate: Dictionary = call(rezolvitor, q)
				if bate.has("eroare"):
					continue   # raportat deja de secțiunea de dinainte

				var impulsuri: Array[String] = bate.get("impuls", [] as Array[String])
				if impulsuri.is_empty():
					fara_impuls.append("%s@%s" % [metoda, nivel])
					continue

				var corecta := _corecta(q)
				var pe_buton := false
				for impuls in impulsuri:
					if impuls == corecta:
						impuls_corect.append("%s@%s impulsul %s E raspunsul" % [
							metoda, nivel, impuls
						])
					if impuls in q["variante"]:
						pe_buton = true
				if not pe_buton:
					impuls_lipsa.append("%s@%s impulsul %s nu e pe buton" % [
						metoda, nivel, _primele(impulsuri, 2)
					])

	rezultat = _verdict(
		"fiecare tipar are un impuls", fara_impuls.is_empty(), _primele(fara_impuls, 4)
	) and rezultat
	rezultat = _verdict(
		"impulsul nu e niciodata raspunsul bun",
		impuls_corect.is_empty(), _primele(impuls_corect, 4)
	) and rezultat
	rezultat = _verdict(
		"impulsul e pe un buton", impuls_lipsa.is_empty(), _primele(impuls_lipsa, 4)
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 5. PLANȘELE
#
# Reflexul e prima disciplină la care DESENEAZĂ toate tiparele (Spațialul avea
# 11 din 12, Reținerea 1 tip din 4). Deci aici „fiecare tipar cere o planșă" e
# un verdict, nu o observație — un tipar care uită desenul n-ar crăpa, ar pune
# o întrebare fără cu ce să fie răspunsă.
# ─────────────────────────────────────────────────────────────

func _plansele() -> bool:
	print("  PLANSELE")
	var rezultat := true

	var fara_plansa: Array[String] = []
	var afara: Array[String] = []
	var prea_mare: Array[String] = []
	var semne_rele: Array[String] = []
	var suprapuse: Array[String] = []
	var taiate: Array[String] = []

	var font := ThemeDB.fallback_font

	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		for nivel in generator["niveluri"]:
			for _tragere in range(40):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				var date: Dictionary = q.get("plansa", {})
				if date.is_empty() or (date.get("semne", []) as Array).is_empty():
					fara_plansa.append("%s@%s" % [metoda, nivel])
					continue

				var lat := float(date["lat"])
				var inalt := float(date["inalt"])
				if lat > PLANSA.LAT_MAXIM or inalt > PLANSA.INALT_MAXIM:
					prea_mare.append("%s %.0fx%.0f" % [metoda, lat, inalt])

				var locuri_vazute := {}
				for semn in date["semne"]:
					var x := float(semn.get("x", -1.0))
					var y := float(semn.get("y", -1.0))
					if x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0:
						afara.append("%s %.2f,%.2f" % [metoda, x, y])
					var plangere := _semnul_e_bun(semn)
					if plangere != "":
						semne_rele.append("%s %s" % [metoda, plangere])
						continue
					# Două semne de același fel în același punct ar fi două
					# desene unul peste altul — adică un semn pe care nu-l
					# poate citi nimeni, nici jucătorul, nici verificarea.
					var cheie := "%s:%.3f:%.3f" % [semn.get("fel", ""), x, y]
					if locuri_vazute.has(cheie):
						suprapuse.append("%s %s" % [metoda, cheie])
					locuri_vazute[cheie] = true

					# TEXTUL NU IESE DIN CASETĂ. Comentariul de la `LOCURI` din
					# `reflex.gd` spune că 0,20 și 0,80 au fost MĂSURATE pe cel
					# mai lung cuvânt; de azi măsurătoarea e un verdict. Un
					# cuvânt tăiat de marginea planșei e cu atât mai rău aici:
					# el E întrebarea.
					if String(semn.get("fel", "")) == "text":
						var lat_text := font.get_string_size(
							String(semn["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1,
							int(semn["marime"])
						).x
						var stanga := x * lat - lat_text * 0.5
						var dreapta := x * lat + lat_text * 0.5
						if stanga < 0.0 or dreapta > lat:
							taiate.append("%s \"%s\" %.0f..%.0f din %.0f" % [
								metoda, semn["text"], stanga, dreapta, lat
							])

	rezultat = _verdict(
		"fiecare tipar cere o plansa", fara_plansa.is_empty(), _primele(fara_plansa, 4)
	) and rezultat
	rezultat = _verdict(
		"nicio plansa peste plafonul panoului",
		prea_mare.is_empty(), _primele(prea_mare, 4)
	) and rezultat
	rezultat = _verdict(
		"niciun semn in afara casetei", afara.is_empty(), _primele(afara, 4)
	) and rezultat
	rezultat = _verdict(
		"fiecare semn e bine descris", semne_rele.is_empty(), _primele(semne_rele, 4)
	) and rezultat
	rezultat = _verdict(
		"niciun semn peste altul", suprapuse.is_empty(), _primele(suprapuse, 4)
	) and rezultat
	rezultat = _verdict(
		"niciun cuvant taiat de margine", taiate.is_empty(), _primele(taiate, 4)
	) and rezultat

	print("")
	return rezultat


## Un semn e bine descris? Întoarce plângerea, sau șir gol.
##
## Desenatorul nu crapă pe un semn stricat — `match` cade pe ramura implicită
## și desenează un triunghi, sau nimic. Adică exact felul de greșeală care se
## vede doar pe ecran, și numai dacă te uiți la întrebarea potrivită.
func _semnul_e_bun(semn: Dictionary) -> String:
	if float(semn.get("marime", 0.0)) <= 0.0:
		return "marime %s" % semn.get("marime", "?")
	match String(semn.get("fel", "")):
		"text":
			if String(semn.get("text", "")) == "":
				return "text gol"
		"sageata":
			if not PLANSA.UNGHIURI.has(String(semn.get("incotro", ""))):
				return "direcție necunoscuta: %s" % semn.get("incotro", "?")
		"forma":
			var forma := String(semn.get("forma", ""))
			if not (forma in ["cerc", "patrat"] or PLANSA.VARFURI.has(forma)):
				return "forma necunoscuta: %s" % forma
		_:
			return "fel necunoscut: %s" % semn.get("fel", "?")
	return ""


# ─────────────────────────────────────────────────────────────
# 6. CÂT DE MULT — gradientul pe niveluri
#
# La disciplina asta dificultatea NU e în regulă (toate nivelurile pun aceeași
# întrebare), e în CÂTE semne ai de ținut deoparte. Deci dacă numărul de semne
# nu crește de la un nivel la altul, nivelurile sunt o decorație.
#
# Verdictul ăsta e cel care a prins greșeala de la Numere („o verificare care
# copiază formula nu verifică formula"): el nu se uită deloc la răspuns.
# ─────────────────────────────────────────────────────────────

func _cat_de_mult() -> bool:
	print("  CAT DE MULT SE DESENEAZA, PE NIVEL")
	var rezultat := true

	var nu_cresc: Array[String] = []
	for generator in REFLEX.GENERATOARE:
		var niveluri: Array = generator["niveluri"]
		if niveluri.size() < 2:
			continue
		var metoda := String(generator["metoda"])
		var medii: Array[float] = []
		for nivel in niveluri:
			var total := 0
			var cate := 0
			for _tragere in range(120):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				total += (q["plansa"]["semne"] as Array).size()
				cate += 1
			medii.append(0.0 if cate == 0 else float(total) / float(cate))
		# `_cifre_mai_mare` desenează MEREU patru cifre: gradientul lui nu e
		# numărul de semne, e cât de apropiate sunt valorile (vezi
		# `_patru_cifre`). Deci acolo se cere doar să nu SCADĂ.
		for i in range(1, medii.size()):
			var creste := medii[i] > medii[i - 1] + 0.01
			var la_fel := absf(medii[i] - medii[i - 1]) <= 0.01
			if not creste and not (la_fel and metoda == "_cifre_mai_mare"):
				nu_cresc.append("%s %.1f -> %.1f" % [metoda, medii[i - 1], medii[i]])

	rezultat = _verdict(
		"semnele nu scad de la un nivel la altul",
		nu_cresc.is_empty(), _primele(nu_cresc, 4)
	) and rezultat

	# Și valorile de la `_cifre_mai_mare` se apropie, altfel nivelul III ar fi
	# identic cu I. Măsurat pe distanța dintre cea mai mare și a doua.
	var distante: Array[float] = []
	for nivel in [1, 2, 3]:
		var total := 0
		var cate := 0
		for _tragere in range(200):
			var q: Dictionary = scena.call("_cifre_mai_mare", nivel)
			if q.is_empty():
				continue
			var cifre := _cifrele_din(q)
			cifre.sort()
			cifre.reverse()
			total += cifre[0] - cifre[1]
			cate += 1
		distante.append(0.0 if cate == 0 else float(total) / float(cate))
	rezultat = _verdict(
		"la valoarea mai mare, cifrele se apropie",
		distante[0] > distante[2] + 0.5,
		"I %.2f -> III %.2f" % [distante[0], distante[2]]
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 7. FONTURILE
#
# Tot ce se DESENEAZĂ pe planșă e text, iar textul are nevoie de caractere care
# există în font. Aceeași secțiune ca la Numere, Tipare, Spațial și Reținere, și
# tot cu trei fonturi: fontul implicit (luptă), Cinzel și Alegreya (pergamentul
# din Practice). Un caracter lipsă ar ieși „tofu" — un dreptunghi gol — adică
# exact la disciplina asta un semn nedesenat în locul întrebării.
# ─────────────────────────────────────────────────────────────

func _fonturile() -> bool:
	print("  FONTURILE")
	var rezultat := true

	var de_desenat := ""
	for cheie in CUVANT_DIRECTIE:
		de_desenat += String(CUVANT_DIRECTIE[cheie])
	for cheie in CUVANT_FORMA:
		de_desenat += String(CUVANT_FORMA[cheie])
	de_desenat += "0123456789"

	for nume in [["implicit", null], ["Cinzel", CALE_CINZEL], ["Alegreya", CALE_ALEGREYA]]:
		var font: Font = ThemeDB.fallback_font
		if nume[1] != null:
			if not ResourceLoader.exists(String(nume[1])):
				rezultat = _verdict(
					"fontul %s exista" % nume[0], false, String(nume[1])
				) and rezultat
				continue
			font = load(String(nume[1]))
		var lipsa := ""
		for i in range(de_desenat.length()):
			if not font.has_char(de_desenat.unicode_at(i)):
				lipsa += de_desenat[i]
		rezultat = _verdict(
			"toate caracterele in %s" % nume[0], lipsa == "", lipsa
		) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 8. ECHILIBRUL
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL")
	var rezultat := true

	# Categoria de pe ecran spune din ce tipar e întrebarea; de la ea se ajunge
	# la tip. Alegerea e în două trepte (întâi tipul), deci cele patru tipuri
	# trebuie să iasă aproape egale — altfel un tip cu trei tipare ar înghiți
	# unul cu două, iar jucătorul ar crede că disciplina e despre săgeți.
	var tip_pe_categorie := {}
	for generator in REFLEX.GENERATOARE:
		tip_pe_categorie[String(generator["categorie"])] = String(generator["tip"])

	var pe_tip := {}
	var fara_categorie := 0
	for _tragere in range(TRAGERI_ECHILIBRU):
		var nivel := randi_range(1, 3)
		var q: Dictionary = scena._compune_intrebare(nivel)
		if q.is_empty():
			continue
		var tip := String(tip_pe_categorie.get(String(q.get("categorie", "")), ""))
		if tip == "":
			fara_categorie += 1
			continue
		pe_tip[tip] = int(pe_tip.get(tip, 0)) + 1

	rezultat = _verdict(
		"fiecare intrebare poarta o categorie din tabel", fara_categorie == 0,
		"%d fara" % fara_categorie
	) and rezultat

	var tipuri := pe_tip.keys()
	rezultat = _verdict(
		"toate patru tipurile apar", tipuri.size() == 4, "%d" % tipuri.size()
	) and rezultat

	var asteptat := float(TRAGERI_ECHILIBRU) / 4.0
	var strambe: Array[String] = []
	for tip in pe_tip:
		var abatere: float = absf(float(pe_tip[tip]) - asteptat) / asteptat
		if abatere > TOLERANTA_ECHILIBRU:
			strambe.append("%s %d (%.0f%%)" % [tip, pe_tip[tip], abatere * 100.0])
	rezultat = _verdict(
		"tipurile ies aproape egale", strambe.is_empty(), _primele(strambe, 4)
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# 9. FĂRĂ REPETIȚII
#
# `_identitate_intrebare` din `reflex.gd` cuprinde PLANȘA, și trebuie: enunțul
# „Unde e scris cuvantul DREAPTA?" are patru forme în tot tiparul, iar
# variantele sunt mereu aceleași patru locuri. Fără planșă în identitate, tot
# tiparul ar fi arătat ca patru întrebări.
# ─────────────────────────────────────────────────────────────

func _fara_repetitii() -> bool:
	print("  FARA REPETITII")
	var rezultat := true

	# CE S-A ÎNVĂȚAT SCRIIND SECȚIUNEA ASTA, fiindcă primul prag pe care l-am
	# pus aici era o presupunere, nu o măsurătoare.
	#
	# Credeam că o rată mică de întrebări distincte înseamnă o identitate care
	# nu deosebește. Nu: disciplina asta ARE puține întrebări posibile pe tipar,
	# și nu din lene. `_sageti_opusul` desenează un rând cu o săgeată la mijloc
	# și restul pe axa cealaltă — patru direcții × două flancuri = OPT planșe,
	# cu tot. `_cuvant_unde` la nivelul I: patru locuri × trei cuvinte care nu-l
	# numesc = douăsprezece. Nicio identitate, oricât de amănunțită, nu poate
	# scoate mai mult decât atât.
	#
	# Deci primul prag (95% la nivelul III) măsura altceva decât credeam, și a
	# fost ȘTERS în loc să fie coborât până trecea. Ce se cere acum sunt două
	# lucruri care chiar se pot cere: că identitatea deosebește ÎN GENERAL, și
	# că nicio combinație de tipar și nivel nu are fântâna atât de mică încât să
	# se repete în aceeași expediție. A doua e cea care contează, și ea se
	# măsoară pe tipar, nu pe disciplină.
	var identitati := {}
	var cate := 0
	for _tragere in range(TRAGERI_SAC):
		var q: Dictionary = scena._compune_intrebare(randi_range(1, 3))
		if q.is_empty():
			continue
		identitati[scena._identitate_intrebare(q)] = true
		cate += 1
	var proaspete := 0.0 if cate == 0 else float(identitati.size()) / float(cate)
	rezultat = _verdict(
		"identitatea deosebeste intrebarile", proaspete > 0.70,
		"%d din %d distincte" % [identitati.size(), cate]
	) and rezultat

	# CÂTE ÎNTREBĂRI ARE FIECARE TIPAR, de fapt. O expediție lungă trage ~45 de
	# întrebări dintr-o disciplină, împărțite pe douăsprezece tipare și trei
	# niveluri — adică una sau două pe combinație. Deci `MINIM_PE_TIPAR` = 8 e
	# cu mult deasupra a ce se atinge într-o expediție, și totuși prinde cazul
	# rău: un tipar cu trei întrebări posibile s-ar repeta chiar în aceeași
	# luptă, iar asta nu se vede în nicio altă verificare.
	var subtiri: Array[String] = []
	var masurate: Array[String] = []
	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		for nivel in generator["niveluri"]:
			var vazute := {}
			for _tragere in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				vazute[scena._identitate_intrebare(q)] = true
			masurate.append("%4d  %s@%s" % [vazute.size(), metoda, nivel])
			if vazute.size() < MINIM_PE_TIPAR:
				subtiri.append("%s@%s doar %d" % [metoda, nivel, vazute.size()])
	rezultat = _verdict(
		"niciun tipar sub %d intrebari deosebite" % MINIM_PE_TIPAR,
		subtiri.is_empty(), _primele(subtiri, 4)
	) and rezultat

	masurate.sort()
	print("    cele mai subtiri combinatii (intrebari deosebite din %d trageri):" % TRAGERI_PE_TIPAR)
	for i in range(mini(5, masurate.size())):
		print("      %s" % masurate[i])

	# Și identitatea CHIAR cuprinde planșa: două întrebări cu același enunț și
	# aceleași variante, dar alt desen, nu au voie să fie una.
	var amprente := {}
	var pe_enunt := {}
	for _tragere in range(TRAGERI_SAC):
		var q: Dictionary = scena.call("_cuvant_unde", 1)
		if q.is_empty():
			continue
		amprente[scena._identitate_intrebare(q)] = true
		pe_enunt[String(q["text"])] = true
	rezultat = _verdict(
		"plansa intra in identitate", amprente.size() > pe_enunt.size(),
		"%d identitati pentru %d enunturi" % [amprente.size(), pe_enunt.size()]
	) and rezultat

	print("")
	return rezultat


# ─────────────────────────────────────────────────────────────
# REZOLVITORII — drumul invers, din planșă spre răspuns
#
# Fiecare întoarce {"corect": …, "impuls": [ … ]} sau {"eroare": …}.
# ─────────────────────────────────────────────────────────────

## „Unde e scris cuvantul DREAPTA?" — se caută cuvântul pe planșă și se traduce
## locul lui. Impulsul: locul pe care cuvântul îl NUMEȘTE.
func _bate_cuvant_unde(q: Dictionary) -> Dictionary:
	var cuvantul := _intre(String(q["text"]), "cuvantul ", "?")
	if cuvantul == "":
		return {"eroare": "nu scrie despre ce cuvant"}
	var numita := _directia_cuvantului(cuvantul)
	if numita == "":
		return {"eroare": "cuvant necunoscut: %s" % cuvantul}

	var unde := ""
	for semn in q["plansa"]["semne"]:
		if String(semn.get("fel", "")) == "text" and String(semn["text"]) == cuvantul:
			unde = _locul_din_punct(Vector2(semn["x"], semn["y"]))
	if unde == "":
		return {"eroare": "%s nu e desenat la niciun loc cunoscut" % cuvantul}

	return {
		"corect": String(NUME_LOC[unde]),
		"impuls": [String(NUME_LOC[numita])] as Array[String],
	}


## „Ce cuvant e scris la stanga?" — se traduce locul și se citește ce e acolo.
## Impulsul: cuvântul care numește locul din întrebare.
func _bate_cuvant_care(q: Dictionary) -> Dictionary:
	var nume_loc := _intre(String(q["text"]), "e scris ", "?")
	var loc := ""
	for cheie in NUME_LOC:
		if String(NUME_LOC[cheie]) == nume_loc:
			loc = String(cheie)
	if loc == "":
		return {"eroare": "loc necunoscut: %s" % nume_loc}

	var acolo := ""
	for semn in q["plansa"]["semne"]:
		if String(semn.get("fel", "")) != "text":
			continue
		if Vector2(semn["x"], semn["y"]).distance_to(LOCURI[loc]) <= APROAPE:
			acolo = String(semn["text"])
	if acolo == "":
		return {"eroare": "nimic desenat %s" % nume_loc}

	return {
		"corect": acolo,
		"impuls": [String(CUVANT_DIRECTIE[loc])] as Array[String],
	}


## „Incotro arata sageata?" — se citește direcția săgeții. Impulsul: sensul
## fiecărui cuvânt desenat lângă ea (oricare poate fi citit primul).
func _bate_cuvant_incotro(q: Dictionary) -> Dictionary:
	var sageti := _semnele(q, "sageata")
	if sageti.size() != 1:
		return {"eroare": "%d sageti, trebuia una" % sageti.size()}

	var impuls: Array[String] = []
	for semn in _semnele(q, "text"):
		var directie := _directia_cuvantului(String(semn["text"]))
		if directie == "":
			return {"eroare": "cuvant necunoscut: %s" % semn["text"]}
		impuls.append(String(NUME_SENS[directie]))
	if impuls.is_empty():
		return {"eroare": "nicio interferenta: sageata fara cuvant"}

	return {
		"corect": String(NUME_SENS[String(sageti[0]["incotro"])]),
		"impuls": impuls,
	}


## „Cate cifre sunt?" — se NUMĂRĂ semnele. Impulsul: cifra scrisă.
func _bate_cifre_cate(q: Dictionary) -> Dictionary:
	var cifre := _cifrele_din(q)
	if cifre.is_empty():
		return {"eroare": "nicio cifra desenata"}
	for cifra in cifre:
		if cifra != cifre[0]:
			return {"eroare": "cifre diferite intr-un rand care trebuia identic"}
	return {"corect": str(cifre.size()), "impuls": [str(cifre[0])] as Array[String]}


## „Ce cifra e scrisa?" — oglinda celui de mai sus. Impulsul: câte sunt.
func _bate_cifre_care(q: Dictionary) -> Dictionary:
	var cifre := _cifrele_din(q)
	if cifre.is_empty():
		return {"eroare": "nicio cifra desenata"}
	for cifra in cifre:
		if cifra != cifre[0]:
			return {"eroare": "cifre diferite intr-un rand care trebuia identic"}
	return {"corect": str(cifre[0]), "impuls": [str(cifre.size())] as Array[String]}


## „Care cifra are VALOAREA cea mai mare?" — se compară cifrele, nu mărimile.
##
## Impulsul: cifra desenată cel mai mare. Plus verdictul care ține tiparul
## cinstit, și care e CHIAR aici fiindcă nu se vede altundeva: răspunsul nu are
## voie să stea nici pe cea mai mare, nici pe cea mai mică — altfel „apasă pe
## cea mai mică" ar fi o regulă care merge mereu (vezi `_cifre_mai_mare`).
func _bate_cifre_mai_mare(q: Dictionary) -> Dictionary:
	var semne := _semnele(q, "text")
	if semne.size() != 4:
		return {"eroare": "%d cifre, trebuiau patru" % semne.size()}

	var cea_mare := -1
	var marimea_ei := 0
	var cea_mai_mare_pe_ecran := -1
	var marime_maxima := -1
	var marime_minima := 99999
	for semn in semne:
		var cifra := int(String(semn["text"]))
		var marime := int(semn["marime"])
		if cifra > cea_mare:
			cea_mare = cifra
			marimea_ei = marime
		if marime > marime_maxima:
			marime_maxima = marime
			cea_mai_mare_pe_ecran = cifra
		marime_minima = mini(marime_minima, marime)

	if marimea_ei == marime_maxima or marimea_ei == marime_minima:
		return {"eroare": "raspunsul sta pe cifra cea mai mare sau cea mai mica de pe ecran"}

	return {
		"corect": str(cea_mare),
		"impuls": [str(cea_mai_mare_pe_ecran)] as Array[String],
	}


## „Incotro arata sageata din MIJLOC?" — se iau săgețile în ordinea de pe ecran
## și se citește cea de la mijloc. Impulsul: direcția celorlalte.
func _bate_sageti_mijlocul(q: Dictionary) -> Dictionary:
	var directii := _sagetile_in_ordine(q)
	if directii.is_empty():
		return {"eroare": "nicio sageata"}
	if directii.size() % 2 == 0:
		return {"eroare": "%d sageti: rand par, deci fara mijloc" % directii.size()}

	var la_mijloc: String = directii[directii.size() / 2]
	var flancul := ""
	for i in range(directii.size()):
		if i != directii.size() / 2:
			if flancul != "" and directii[i] != flancul:
				return {"eroare": "flancurile nu arata toate la fel"}
			flancul = String(directii[i])
	if flancul == la_mijloc:
		return {"eroare": "mijlocul arata ca flancurile, deci nicio interferenta"}

	return {
		"corect": String(NUME_SENS[la_mijloc]),
		"impuls": [String(NUME_SENS[flancul])] as Array[String],
	}


## „Cate sageti arata la dreapta?" — se numără. Impulsul: câte arată invers, și
## totalul.
func _bate_sageti_cate(q: Dictionary) -> Dictionary:
	var cerut := _intre(String(q["text"]), "arata ", "?")
	var directia := ""
	for cheie in NUME_SENS:
		if String(NUME_SENS[cheie]) == cerut:
			directia = String(cheie)
	if directia == "":
		return {"eroare": "sens necunoscut: %s" % cerut}

	var directii := _sagetile_in_ordine(q)
	var ale_ei := directii.count(directia)
	if ale_ei == 0:
		return {"eroare": "niciuna %s: raspunsul ar fi zero" % cerut}
	var celelalte := directii.size() - ale_ei
	if celelalte == ale_ei:
		return {"eroare": "jumatate-jumatate, deci impulsul e chiar raspunsul"}

	return {
		"corect": str(ale_ei),
		"impuls": [str(celelalte), str(directii.size())] as Array[String],
	}


## „Apasa partea OPUSA." — se citește mijlocul și se întoarce. Impulsul:
## direcția adevărată a mijlocului, adică răspunsul la altă întrebare.
func _bate_sageti_opusul(q: Dictionary) -> Dictionary:
	var directii := _sagetile_in_ordine(q)
	if directii.is_empty():
		return {"eroare": "nicio sageata"}
	if directii.size() % 2 == 0:
		return {"eroare": "%d sageti: rand par, deci fara mijloc" % directii.size()}

	var la_mijloc: String = directii[directii.size() / 2]
	var flancul := ""
	for i in range(directii.size()):
		if i != directii.size() / 2:
			flancul = String(directii[i])
	# Flancurile pe axa mijlocului ar arăta ele însele spre răspuns. Regula e
	# scrisă în `_sageti_opusul`; aici e un verdict.
	if flancul == la_mijloc or flancul == String(OPUSE[la_mijloc]):
		return {"eroare": "flancurile sunt pe axa mijlocului, deci dau raspunsul"}

	return {
		"corect": String(NUME_SENS[String(OPUSE[la_mijloc])]),
		"impuls": [String(NUME_SENS[la_mijloc])] as Array[String],
	}


## „Ce forma e desenata?" — se citește forma. Impulsul: cuvintele de lângă ea.
func _bate_forme_care(q: Dictionary) -> Dictionary:
	var forme := _semnele(q, "forma")
	if forme.size() != 1:
		return {"eroare": "%d forme, trebuia una" % forme.size()}
	var desenata := String(forme[0]["forma"])
	if not NUME_FORMA.has(desenata):
		return {"eroare": "forma necunoscuta: %s" % desenata}

	var impuls: Array[String] = []
	for semn in _semnele(q, "text"):
		var cheie := _forma_cuvantului(String(semn["text"]))
		if cheie == "":
			return {"eroare": "cuvant necunoscut: %s" % semn["text"]}
		impuls.append(String(NUME_FORMA[cheie]))
	if impuls.is_empty():
		return {"eroare": "nicio interferenta: forma fara cuvant"}

	return {"corect": String(NUME_FORMA[desenata]), "impuls": impuls}


## „Ce cuvant e scris?" — oglinda celui de mai sus. Impulsul: numele formelor.
func _bate_forme_scrie(q: Dictionary) -> Dictionary:
	var texte := _semnele(q, "text")
	if texte.size() != 1:
		return {"eroare": "%d cuvinte, trebuia unul" % texte.size()}
	var cuvantul := String(texte[0]["text"])
	if _forma_cuvantului(cuvantul) == "":
		return {"eroare": "cuvant necunoscut: %s" % cuvantul}

	var impuls: Array[String] = []
	for semn in _semnele(q, "forma"):
		var cheie := String(semn["forma"])
		if not CUVANT_FORMA.has(cheie):
			return {"eroare": "forma necunoscuta: %s" % cheie}
		impuls.append(String(CUVANT_FORMA[cheie]))
	if impuls.is_empty():
		return {"eroare": "nicio interferenta: cuvant fara forma"}

	return {"corect": cuvantul, "impuls": impuls}


## „Cate triunghiuri sunt DESENATE?" — se numără FORMELE, nu cuvintele.
## Impulsul: de câte ori apare cuvântul cerut, și totalul perechilor.
func _bate_forme_cate(q: Dictionary) -> Dictionary:
	var plural := _intre(String(q["text"]), "Cate ", " sunt")
	var cheie := ""
	for forma in PLURAL_FORMA:
		if String(PLURAL_FORMA[forma]) == plural:
			cheie = String(forma)
	if cheie == "":
		return {"eroare": "plural necunoscut: %s" % plural}

	var desenate := 0
	for semn in _semnele(q, "forma"):
		if String(semn["forma"]) == cheie:
			desenate += 1
	var scrise := 0
	for semn in _semnele(q, "text"):
		if String(semn["text"]) == String(CUVANT_FORMA[cheie]):
			scrise += 1

	if desenate == 0:
		return {"eroare": "niciun %s desenat: raspunsul ar fi zero" % cheie}
	if desenate == scrise:
		return {"eroare": "atatea forme cate cuvinte, deci nicio interferenta"}
	# Fiecare cuvânt trebuie să fie greșit pentru forma de deasupra lui. Se
	# verifică prin locuri: cuvântul de pe coloana i stă sub forma de pe aceeași
	# coloană, deci au același `x`.
	for text in _semnele(q, "text"):
		for forma in _semnele(q, "forma"):
			if absf(float(text["x"]) - float(forma["x"])) > APROAPE:
				continue
			if _forma_cuvantului(String(text["text"])) == String(forma["forma"]):
				return {"eroare": "un cuvant isi numeste propria forma"}

	return {
		"corect": str(desenate),
		"impuls": [str(scrise), str(_semnele(q, "forma").size())] as Array[String],
	}


# ─────────────────────────────────────────────────────────────
# UNELTELE DE CITIT PLANȘA
# ─────────────────────────────────────────────────────────────

## Semnele de un anume fel, în ordinea din listă.
func _semnele(q: Dictionary, fel: String) -> Array:
	var gasite: Array = []
	for semn in q["plansa"]["semne"]:
		if String(semn.get("fel", "")) == fel:
			gasite.append(semn)
	return gasite


## Cifrele desenate, în ordinea de pe ecran (de la stânga la dreapta).
func _cifrele_din(q: Dictionary) -> Array[int]:
	var semne := _semnele(q, "text")
	semne.sort_custom(func(a, b): return float(a["x"]) < float(b["x"]))
	var cifre: Array[int] = []
	for semn in semne:
		var text := String(semn["text"])
		if text.is_valid_int():
			cifre.append(int(text))
	return cifre


## Direcțiile săgeților, ÎN ORDINEA DE PE ECRAN.
##
## Sortarea pe `x` nu e un amănunt: „săgeata din mijloc" e o afirmație despre
## ecran, nu despre ordinea din listă. Dacă generatorul ar pune vreodată semnele
## în altă ordine decât de la stânga la dreapta, aici tot mijlocul adevărat s-ar
## citi — iar un tipar care se bazează pe ordinea listei ar pica, cum trebuie.
func _sagetile_in_ordine(q: Dictionary) -> Array[String]:
	var semne := _semnele(q, "sageata")
	semne.sort_custom(func(a, b): return float(a["x"]) < float(b["x"]))
	var directii: Array[String] = []
	for semn in semne:
		directii.append(String(semn["incotro"]))
	return directii


## Locul (cheia) cel mai apropiat de un punct, sau șir gol.
func _locul_din_punct(punct: Vector2) -> String:
	for cheie in LOCURI:
		if punct.distance_to(LOCURI[cheie]) <= APROAPE:
			return String(cheie)
	return ""


## Direcția al cărei cuvânt desenat e ăsta: „DREAPTA" → „dreapta".
func _directia_cuvantului(cuvant: String) -> String:
	for cheie in CUVANT_DIRECTIE:
		if String(CUVANT_DIRECTIE[cheie]) == cuvant:
			return String(cheie)
	return ""


## Forma al cărei cuvânt desenat e ăsta: „ROMB" → „romb".
func _forma_cuvantului(cuvant: String) -> String:
	for cheie in CUVANT_FORMA:
		if String(CUVANT_FORMA[cheie]) == cuvant:
			return String(cheie)
	return ""


## Bucata de text dintre două repere. Șir gol dacă vreunul lipsește.
func _intre(text: String, dupa: String, inainte: String) -> String:
	var start := text.find(dupa)
	if start < 0:
		return ""
	start += dupa.length()
	var stop := text.find(inainte, start)
	if stop < 0:
		return ""
	return text.substr(start, stop - start)


func _corecta(q: Dictionary) -> String:
	return String(q["variante"][int(q["corect"])])


# ─────────────────────────────────────────────────────────────
# TIPĂRIREA
# ─────────────────────────────────────────────────────────────

## Ține minte cea mai lungă întrebare și una la întâmplare, pe tipar. Culesul se
## face în bucla care verifică oricum.
func _culege(metoda: String, q: Dictionary) -> void:
	var text := String(q["text"])
	if text.length() > String(cel_mai_lung.get(metoda, "")).length():
		cel_mai_lung[metoda] = text
	if not o_mostra.has(metoda) or randf() < 0.01:
		o_mostra[metoda] = q


## MOSTRELE ȘI LUNGIMILE, tipărite ca să fie CITITE.
##
## Nu sunt verdicte, și de-aia nu intră în `tot_bun`. Ce se vede aici și nu se
## poate verifica: dacă propoziția sună a românește, dacă nota lămurește
## capcana, și dacă enunțul intră în cele 12 secunde ale Lăncierului — cititul
## inclus. Aceeași regulă ca la `verifica_mostrele` de la Logică.
func _cat_se_citeste() -> void:
	print("  CE SE CITESTE (nu sunt verdicte, se citesc)")
	var lungimi: Array[String] = []
	for metoda in cel_mai_lung:
		lungimi.append("%d %s" % [String(cel_mai_lung[metoda]).length(), metoda])
	lungimi.sort()
	lungimi.reverse()
	print("    cele mai lungi enunturi, in semne:")
	for rand in lungimi:
		print("      %s" % rand)

	print("\n    o mostra din fiecare tipar:")
	for generator in REFLEX.GENERATOARE:
		var metoda := String(generator["metoda"])
		if not o_mostra.has(metoda):
			continue
		var q: Dictionary = o_mostra[metoda]
		print("\n      [%s] %s" % [generator["categorie"], q["text"]])
		print("      plansa: %s" % _plansa_scrisa(q))
		var variante: Array = q["variante"]
		for i in range(variante.size()):
			print("        %s %s" % ["->" if i == int(q["corect"]) else "  ", variante[i]])
		print("      nota: %s" % q["explicatie"])
	print("")


## Planșa, scrisă ca text, pentru ochi. Nu e amprenta din `reflex.gd` (aceea e
## pentru comparație): aici semnele se scriu în ordinea de pe ecran, cu locul
## lor tradus, ca să se poată citi ce vede jucătorul fără să deschizi jocul.
func _plansa_scrisa(q: Dictionary) -> String:
	var semne: Array = (q["plansa"]["semne"] as Array).duplicate()
	semne.sort_custom(func(a, b):
		if absf(float(a["y"]) - float(b["y"])) > 0.05:
			return float(a["y"]) < float(b["y"])
		return float(a["x"]) < float(b["x"])
	)
	var bucati: Array[String] = []
	for semn in semne:
		match String(semn["fel"]):
			"text":
				bucati.append("\"%s\"/%d" % [semn["text"], int(semn["marime"])])
			"sageata":
				bucati.append("->%s" % semn["incotro"])
			"forma":
				bucati.append("[%s]" % semn["forma"])
	return " ".join(bucati)


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

extends Node
## VERIFICAREA REȚINERII — cele 4 tipuri, cele 13 tipare, și EXPUNEREA.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_retinere.tscn
##
## ─────────────────────────────────────────────────────────────
## CE E ALTFEL AICI: SE VERIFICĂ CE A FOST PE ECRAN, NU CE E PE EL
##
## La toate celelalte șase discipline, enunțul e sursa adevărului: scrie negru
## pe alb „14 × 6 = ?" sau „Ce literă e la dreapta lui M", iar verificarea
## reface socoteala din el. Aici enunțul nu spune aproape nimic — „Ce cifră era
## pe locul 3?" e identic la toate întrebările tiparului. Tot ce face întrebarea
## să fie ea stă în EXPUNERE, adică în ce s-a văzut și a dispărut.
##
## Deci verificarea citește `text_expunere` și `plansa` — exact bucățile pe care
## le-a avut jucătorul în față — le descompune în semne (cifre, litere, cuvinte,
## perechi) și răspunde singură la întrebare. E un drum diferit de al jocului:
## generatorul pornește de la șirul tras la sorți și COMPUNE textul; verificarea
## pornește de la TEXT și află șirul. O greșeală de scriere (două cifre lipite,
## un separator greșit, o literă pierdută) n-ar atinge șirul din generator, dar
## schimbă ce a văzut jucătorul — și atunci picăm aici, cum trebuie.
##
## ─────────────────────────────────────────────────────────────
## SECȚIUNEA CARE NU EXISTĂ LA NICIO ALTĂ DISCIPLINĂ: EXPUNERILE
##
## Reținerea e singura care folosește al doilea cârlig din `puzzle.gd` (vezi
## `_incepe_expunerea`), iar el se poate strica în feluri în care un enunț nu
## poate:
##
##   • un tipar care UITĂ să ceară o expunere ar pune întrebarea cu șirul încă
##     pe ecran — adică ar deveni o întrebare de citit. Nu crapă nimic și nu se
##     vede în nicio altă verificare;
##   • un tipar care numără greșit SEMNELE (perechile sunt dubluri: trei
##     perechi sunt șase semne, nu trei) ar primi jumătate din secundele
##     cuvenite, deci ar fi imposibil fără să fie greșit;
##   • un enunț care repetă ce s-a arătat ar da răspunsul;
##   • o notă care NU repetă ce s-a arătat lasă jucătorul fără nicio cale de a
##     afla ce a ratat (vezi antetul lui `retinere.gd`).
##
## Toate patru sunt verdicte, nu intenții scrise în comentarii.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## Dacă 2,5 secunde sunt destule pentru patru cifre. Aia nu e un verdict, e o
## măsurătoare pe un om — se joacă scena cu F6. Ce se poate verifica (și se
## verifică) e că durata nu se bate cu numărul de semne arătate, și că ea crește
## de la un nivel la altul.
##
## Nici gramatica formei hotărâte („toporul", „cupa"), fiindcă n-are de unde:
## verificarea ar citi chiar tabelul `LUCRURI` din care vine forma, deci ar fi
## de acord cu ea orice ar scrie în el. Acordul se citește cu ochiul, din
## mostrele tipărite la finalul rulării — aceeași regulă ca la notele fabricii.

const RETINERE := preload("res://scenes/retinere/retinere.gd")

# SCENELE, pentru singura secțiune care chiar le deschide. Vezi
# `_expunerea_jucata()`: expunerea nu trăiește în generator, trăiește în
# `puzzle.gd`, deci acolo trebuie și bătută.
const SCENA_RETINERE := preload("res://scenes/retinere/retinere.tscn")
const SCENA_NUMERE := preload("res://scenes/numere/numere.tscn")

# De câte ori se joacă o întrebare cu scena adevărată. Destul ca printre ele să
# cadă și un CAROIAJ (un tip din patru), fără să dureze.
const JOCURI_CU_SCENA := 16

# Câte întrebări se trag din fiecare tipar, la fiecare nivel din tabelul lui.
const TRAGERI_PE_TIPAR := 200

# Echilibrul pe tipuri. La 4 tipuri ar trebui să iasă ~2000 fiecare.
const TRAGERI_ECHILIBRU := 8000
const TOLERANTA_ECHILIBRU := 0.20

# Cât poate pica un tipar fără ca asta să fie o problemă. Mai jos decât la
# Spațial (0,5), fiindcă aici niciun tipar nu are motiv structural să cadă: nu
# există poziții simetrice în care două variante să însemne același lucru. Un
# tipar care totuși cade des ascunde o scăpare.
const MAX_RATA_DE_ESEC := 0.2

const TRAGERI_SAC := 300

# Cât poate fi un caroiaj. Prima cifră e a desenatorului (4 × 30 px, vezi
# `LATURA` din `plansa.gd`), a doua e a DISCIPLINEI și e mult mai strânsă:
# nouă litere e marginea a ce ține un om minte dintr-o privire. Vezi
# `CAROIAJ_PE_NIVEL` din `retinere.gd`.
const MAX_LATURA_PLANSA := 4
const MAX_LITERE_PLANSA := 9

# Secundele de expunere pe semn, ca interval și nu ca formulă. Jocul calculează
# `semne × 0,62`; aici se cere doar să cadă între o jumătate de secundă și trei
# sferturi pe semn — adică să fie numărate semnele CORECT, nu să iasă la virgulă
# aceeași înmulțire. „O verificare care copiază formula nu verifică formula"
# (CLAUDE.md), iar greșeala de prins aici e tocmai numărătoarea: un tipar de
# perechi care trimite `cate` în loc de `cate * 2`.
const MIN_PE_SEMN := 0.50
const MAX_PE_SEMN := 0.75

const CALE_CINZEL := "res://assets/fonturi/Cinzel.ttf"
const CALE_ALEGREYA := "res://assets/fonturi/Alegreya.ttf"

# ─────────────────────────────────────────────────────────────
# CINE REZOLVĂ CE
#
# Un rând pe tipar, și `_tabelul()` cere ca fiecare metodă din `GENERATOARE` să
# aibă unul: un tipar adăugat mâine fără rezolvitor face verificarea să PICE, în
# loc să treacă drept acoperit.
# ─────────────────────────────────────────────────────────────
const REZOLVARI := {
	"_sir_locul": "_bate_locul",
	"_sir_vecinul": "_bate_vecinul",
	"_sir_capetele": "_bate_capetele",
	"_sir_lipsa": "_bate_cifra_lipsa",
	"_sir_invers": "_bate_inversul",
	"_caroiaj_celula": "_bate_celula",
	"_caroiaj_unde": "_bate_unde",
	"_caroiaj_lipsa": "_bate_litera_lipsa",
	"_lista_intrusul": "_bate_intrusul",
	"_lista_cate": "_bate_cate",
	"_lista_al_catelea": "_bate_al_catelea",
	"_pereche_ce_avea": "_bate_ce_avea",
	"_pereche_cine_avea": "_bate_cine_avea",
}

# ─────────────────────────────────────────────────────────────
# ANTETELE EXPUNERII, SCRISE A DOUA OARĂ
#
# Patru feluri de a arăta ceva, patru rânduri. Scrise aici, nu luate din joc,
# din același motiv pentru care Spațialul își rescrie tabelele de întoarceri: o
# formulare schimbată în joc trebuie să PICE aici, nu să treacă în tăcere.
#
# Rândul decide și cum se descompune ce s-a arătat: cifre despărțite prin
# spații, cuvinte prin virgulă, perechi pe rânduri, litere luate din planșă.
# ─────────────────────────────────────────────────────────────
const ANTETE := {
	"Tine minte sirul:": "cifre",
	"Tine minte lista, in ordine:": "cuvinte",
	"Tine minte cine are ce:": "perechi",
	"Tine minte caroiajul.": "caroiaj",
}

var scena = null
var tot_bun := true

var cel_mai_lung := {}
var o_mostra := {}


func _ready() -> void:
	print("\n══ VERIFICAREA RETINERII ══\n")

	# Scriptul, nu scena: niciun generator nu atinge un buton, iar planșa și
	# expunerea se citesc ca date. Deci nu se deschide nicio fereastră.
	scena = RETINERE.new()

	tot_bun = _tabelul() and tot_bun
	tot_bun = _nivelurile() and tot_bun
	tot_bun = _contractul_si_rezolvarea() and tot_bun
	tot_bun = _expunerile() and tot_bun
	tot_bun = _plansele() and tot_bun
	tot_bun = _fonturile() and tot_bun
	tot_bun = _echilibrul() and tot_bun
	tot_bun = _fara_repetitii() and tot_bun
	tot_bun = await _expunerea_jucata() and tot_bun
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
	for generator in RETINERE.GENERATOARE:
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
	for generator in RETINERE.GENERATOARE:
		metode_din_joc[String(generator["metoda"])] = true
	var orfane: Array[String] = []
	for metoda in REZOLVARI:
		if not metode_din_joc.has(metoda):
			orfane.append(String(metoda))
	rezultat = _verdict(
		"nicio rezolvare fara tiparul ei", orfane.is_empty(), _primele(orfane, 5)
	) and rezultat

	# Un antet împărțit de două tipuri ar face echilibrul imposibil de măsurat:
	# `_echilibrul` deduce tipul din `categorie`.
	var tip_pe_antet := {}
	var antete_duble: Array[String] = []
	for generator in RETINERE.GENERATOARE:
		var antet := String(generator["categorie"])
		var tip := String(generator["tip"])
		if tip_pe_antet.has(antet) and tip_pe_antet[antet] != tip:
			antete_duble.append(antet)
		tip_pe_antet[antet] = tip
	rezultat = _verdict(
		"fiecare antet e al unui singur tip",
		antete_duble.is_empty(), _primele(antete_duble, 5)
	) and rezultat

	rezultat = _verdict(
		"cele 4 tipuri si cele 13 tipare",
		_tipurile().size() == 4 and RETINERE.GENERATOARE.size() == 13,
		"%d tipuri, %d tipare" % [_tipurile().size(), RETINERE.GENERATOARE.size()]
	) and rezultat

	# Lucrurile au DOUĂ forme, iar a doua e singurul loc din disciplină unde se
	# poate strecura o greșeală de gramatică. Nu se poate verifica dacă e
	# corectă, dar se poate verifica să EXISTE și să nu fie o copie leneșă a
	# primei peste tot: dacă toate ar fi identice, cineva a umplut coloana cu
	# `unul` și întrebările ar spune „Cine avea arc?".
	var fara_hotarat: Array[String] = []
	var identice := 0
	for lucru in RETINERE.LUCRURI:
		var unul := String(lucru.get("unul", ""))
		var acela := String(lucru.get("acela", ""))
		if unul == "" or acela == "":
			fara_hotarat.append("%s / %s" % [unul, acela])
		elif unul == acela:
			identice += 1
	rezultat = _verdict(
		"fiecare lucru are amandoua formele",
		fara_hotarat.is_empty(), _primele(fara_hotarat, 5)
	) and rezultat
	# „candela" și „cupa" sunt, fără diacritice, aceleași în amândouă formele —
	# deci câteva identice sunt corecte. Toate ar fi o coloană necompletată.
	rezultat = _verdict(
		"forma hotarata nu e o copie a celeilalte",
		identice < RETINERE.LUCRURI.size() / 2,
		"%d din %d identice" % [identice, RETINERE.LUCRURI.size()]
	) and rezultat

	return rezultat


func _tipurile() -> Array:
	var tipuri := {}
	for generator in RETINERE.GENERATOARE:
		tipuri[String(generator["tip"])] = true
	return tipuri.keys()


# ─────────────────────────────────────────────────────────────
# 2. FIECARE TIP, LA TOATE TREI NIVELURILE
#
# Regula de echilibru a disciplinei, bătută și nu doar scrisă: dacă PERECHILE
# ar lipsi la nivelul I, celelalte trei tipuri și-ar împărți acolo toată
# probabilitatea, iar un sfert din disciplină n-ar apărea niciodată la începutul
# unei expediții.
# ─────────────────────────────────────────────────────────────

func _nivelurile() -> bool:
	print("  NIVELURILE")
	var rezultat := true

	for nivel in [1, 2, 3]:
		var cu_tipare := {}
		for generator in RETINERE.GENERATOARE:
			if nivel in generator["niveluri"]:
				cu_tipare[String(generator["tip"])] = true
		var lipsa: Array[String] = []
		for tip in _tipurile():
			if not cu_tipare.has(tip):
				lipsa.append(String(tip))
		rezultat = _verdict(
			"nivelul %d are toate cele %d tipuri" % [nivel, _tipurile().size()],
			lipsa.is_empty(), _primele(lipsa, 5)
		) and rezultat

	# Și invers: un tipar fără niciun nivel e cod mort care arată ca un tipar.
	var fara_nivel: Array[String] = []
	for generator in RETINERE.GENERATOARE:
		var niveluri: Array = generator["niveluri"]
		if niveluri.is_empty():
			fara_nivel.append(String(generator["metoda"]))
		for nivel in niveluri:
			if int(nivel) < 1 or int(nivel) > 3:
				fara_nivel.append("%s: nivelul %d" % [generator["metoda"], int(nivel)])
	rezultat = _verdict(
		"niciun tipar fara nivel, niciun nivel in afara 1-3",
		fara_nivel.is_empty(), _primele(fara_nivel, 5)
	) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 3. CONTRACTUL ȘI REZOLVAREA — miezul
#
# O singură buclă pentru amândouă, ca la Numere și Spațial: n-are rost să tragi
# de două ori aceleași mii de întrebări.
# ─────────────────────────────────────────────────────────────

func _contractul_si_rezolvarea() -> bool:
	print("  CONTRACTUL SI REZOLVAREA (%d trageri pe tipar, pe nivel)" % TRAGERI_PE_TIPAR)
	var rezultat := true

	var stricate: Array[String] = []
	var gresite: Array[String] = []
	var prea_des_gol: Array[String] = []

	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var rezolvare := String(REZOLVARI.get(metoda, ""))
		for nivel in generator["niveluri"]:
			var goale := 0
			for i in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					goale += 1
					continue
				_culege(metoda, q)

				var problema := _problema_de_contract(q)
				if problema != "":
					stricate.append("%s/%d: %s" % [metoda, int(nivel), problema])
					break
				if rezolvare != "":
					var greseala: String = call(rezolvare, q)
					if greseala != "":
						gresite.append("%s/%d: %s" % [metoda, int(nivel), greseala])
						break
			var rata := float(goale) / float(TRAGERI_PE_TIPAR)
			if rata > MAX_RATA_DE_ESEC:
				prea_des_gol.append("%s/%d: %d%%" % [metoda, int(nivel), int(rata * 100.0)])

	rezultat = _verdict(
		"toate tiparele respecta contractul",
		stricate.is_empty(), _primele(stricate, 5)
	) and rezultat
	rezultat = _verdict(
		"RASPUNSUL, rezolvat din nou din CE S-A ARATAT",
		gresite.is_empty(), _primele(gresite, 5)
	) and rezultat
	rezultat = _verdict(
		"niciun tipar nu pica mai des de %d%%" % int(MAX_RATA_DE_ESEC * 100.0),
		prea_des_gol.is_empty(), _primele(prea_des_gol, 5)
	) and rezultat

	# Și prin poarta pe care o folosește chiar lupta.
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
		return "„corect” = %d" % corect

	var nota := String(q["explicatie"])
	if nota.contains("{") or nota.contains("}"):
		return "nota are un loc necompletat: „%s”" % nota

	return ""


# ─────────────────────────────────────────────────────────────
# REZOLVĂRILE — fiecare tipar, rezolvat din nou din CE S-A ARĂTAT
#
# Toate pornesc de la `text_expunere` sau de la `plansa`, nu de la ce a avut
# generatorul în minte. Vezi antetul fișierului.
# ─────────────────────────────────────────────────────────────

## „Ce cifra era pe locul 3?"
func _bate_locul(q: Dictionary) -> String:
	var sir := _cifrele_aratate(q)
	var loc := _numarul_dupa(String(q["text"]), "pe locul ")
	if loc < 1 or loc > sir.size():
		return "locul %d, dar s-au aratat %d cifre" % [loc, sir.size()]
	var asteptat: String = sir[loc - 1]
	if _corecta(q) != asteptat:
		return "pe locul %d era %s, nu %s" % [loc, asteptat, _corecta(q)]
	# Greșelile trebuie să fie celelalte cifre ARĂTATE. Vezi antetul lui
	# `retinere.gd`: cifre la întâmplare ar fi făcut întrebarea mai slabă.
	for greseala in _greselile(q):
		if not (greseala in sir):
			return "greseala %s nu era in sirul aratat" % greseala
	return ""


## „Ce cifra venea DUPA 9?"
func _bate_vecinul(q: Dictionary) -> String:
	var sir := _cifrele_aratate(q)
	var text := String(q["text"])
	var dupa := text.contains("venea DUPA ")
	var reper := _cifra_dupa(text, "venea DUPA " if dupa else "venea INAINTE de ")
	if reper == "":
		return "nu se citeste reperul din „%s”" % text

	var poz := sir.find(reper)
	if poz < 0:
		return "reperul %s nu e in sirul aratat" % reper
	var indice := poz + 1 if dupa else poz - 1
	if indice < 0 or indice >= sir.size():
		return "reperul %s n-are vecin in sensul cerut" % reper
	var asteptat: String = sir[indice]
	if _corecta(q) != asteptat:
		return "%s %s era %s, nu %s" % [
			"dupa" if dupa else "inainte de", reper, asteptat, _corecta(q),
		]
	# Reperul se vede în enunț, deci un buton cu el pe ecran ar fi o variantă
	# eliminată pe gratis.
	if reper in q["variante"]:
		return "reperul %s e si pe un buton" % reper
	return ""


## „Care era PRIMA cifra din sir?"
func _bate_capetele(q: Dictionary) -> String:
	var sir := _cifrele_aratate(q)
	if sir.size() < 2:
		return "sir de %d cifre" % sir.size()
	var prima := String(q["text"]).contains("PRIMA")
	var asteptat: String = sir[0] if prima else sir[sir.size() - 1]
	if _corecta(q) != asteptat:
		return "%s cifra era %s, nu %s" % [
			"prima" if prima else "ultima", asteptat, _corecta(q),
		]
	# Celălalt capăt e greșeala care dă tiparului rostul lui: dacă lipsește,
	# întrebarea și-a pierdut singurul distractor care cere o amintire.
	var celalalt: String = sir[sir.size() - 1] if prima else sir[0]
	if not (celalalt in _greselile(q)):
		return "celalalt capat (%s) nu e intre greseli" % celalalt
	return ""


## „Care din cifrele astea NU era in sir?"
func _bate_cifra_lipsa(q: Dictionary) -> String:
	var sir := _cifrele_aratate(q)
	if _corecta(q) in sir:
		return "raspunsul bun (%s) ERA in sirul aratat" % _corecta(q)
	for greseala in _greselile(q):
		if not (greseala in sir):
			return "greseala %s nu era nici ea in sir" % greseala
	return ""


## „Cum arata sirul citit de la sfarsit spre inceput?"
func _bate_inversul(q: Dictionary) -> String:
	var sir := _cifrele_aratate(q)
	var intors: Array = sir.duplicate()
	intors.reverse()
	var asteptat := "  ".join(intors)
	if _corecta(q) != asteptat:
		return "intors e „%s”, nu „%s”" % [asteptat, _corecta(q)]
	# Șirul NEÎNTORS trebuie să fie între greșeli: tiparul există pentru el.
	var neintors := "  ".join(sir)
	if not (neintors in _greselile(q)):
		return "sirul neintors („%s”) nu e intre greseli" % neintors
	return ""


## „Ce litera era in linia 2, coloana 3?"
func _bate_celula(q: Dictionary) -> String:
	var text := String(q["text"])
	var linie := _numarul_dupa(text, "in linia ")
	var coloana := _numarul_dupa(text, "coloana ")
	var asteptat := _litera_la(q, linie, coloana)
	if asteptat == "":
		return "celula %d,%d nu e pe caroiajul aratat" % [linie, coloana]
	if _corecta(q) != asteptat:
		return "in %d,%d era %s, nu %s" % [linie, coloana, asteptat, _corecta(q)]
	for greseala in _greselile(q):
		if not (greseala in _literele_aratate(q)):
			return "greseala %s nu era pe caroiaj" % greseala
	return ""


## „In ce celula era litera K?"
func _bate_unde(q: Dictionary) -> String:
	var litera := _litera_dupa(String(q["text"]), "era litera ")
	if litera == "":
		return "nu se citeste litera din „%s”" % String(q["text"])
	var unde := _unde_e_litera(q, litera)
	if unde == Vector2i(-1, -1):
		return "litera %s nu e pe caroiajul aratat" % litera
	var asteptat := "linia %d, coloana %d" % [unde.x, unde.y]
	if _corecta(q) != asteptat:
		return "%s era in %s, nu in %s" % [litera, asteptat, _corecta(q)]
	# Toate variantele trebuie să fie celule care EXISTĂ pe caroiaj: „linia 4,
	# coloana 1" pe o planșă de trei linii s-ar elimina fără nicio amintire.
	for varianta in q["variante"]:
		var nume := String(varianta)
		var l := _numarul_dupa(nume, "linia ")
		var c := _numarul_dupa(nume, "coloana ")
		if _litera_la(q, l, c) == "":
			return "varianta „%s” nu e o celula a caroiajului" % nume
	return ""


## „Care din literele astea NU era pe caroiaj?"
func _bate_litera_lipsa(q: Dictionary) -> String:
	var litere := _literele_aratate(q)
	if _corecta(q) in litere:
		return "raspunsul bun (%s) ERA pe caroiaj" % _corecta(q)
	for greseala in _greselile(q):
		if not (greseala in litere):
			return "greseala %s nu era nici ea pe caroiaj" % greseala
	return ""


## „Care din cuvintele astea NU era in lista?"
func _bate_intrusul(q: Dictionary) -> String:
	var lista := _cuvintele_aratate(q)
	if _corecta(q) in lista:
		return "raspunsul bun (%s) ERA in lista" % _corecta(q)
	for greseala in _greselile(q):
		if not (greseala in lista):
			return "greseala %s nu era nici ea in lista" % greseala
	return ""


## „Cate cuvinte erau in lista?"
func _bate_cate(q: Dictionary) -> String:
	var lista := _cuvintele_aratate(q)
	if _corecta(q) != str(lista.size()):
		return "s-au aratat %d cuvinte, raspunsul bun zice %s" % [
			lista.size(), _corecta(q),
		]
	return ""


## „Pe ce loc in lista era cuvantul scut?"
func _bate_al_catelea(q: Dictionary) -> String:
	var lista := _cuvintele_aratate(q)
	var cuvant := String(q["text"]).get_slice("era cuvantul ", 1).trim_suffix("?")
	var loc := lista.find(cuvant)
	if loc < 0:
		return "cuvantul „%s” nu e in lista aratata" % cuvant
	var asteptat := "locul %d" % (loc + 1)
	if _corecta(q) != asteptat:
		return "„%s” era pe %s, nu pe %s" % [cuvant, asteptat, _corecta(q)]
	for varianta in q["variante"]:
		var numar := _numarul_dupa(String(varianta), "locul ")
		if numar < 1 or numar > lista.size():
			return "varianta „%s” e in afara listei" % String(varianta)
	return ""


## „Ce avea Emil?"
func _bate_ce_avea(q: Dictionary) -> String:
	var perechi := _perechile_aratate(q)
	var cine := String(q["text"]).get_slice("Ce avea ", 1).trim_suffix("?")
	if not perechi.has(cine):
		return "„%s” nu e intre cei aratati" % cine
	var asteptat := String(perechi[cine])
	if _corecta(q) != asteptat:
		return "%s avea %s, nu %s" % [cine, asteptat, _corecta(q)]
	# Greșelile sunt lucrurile celorlalți — în afară de umplutura de la nivelul
	# I, care e un lucru nearătat (vezi antetul tiparului). Deci se cere doar ca
	# ele să NU fie lucrul lui: o greșeală egală cu răspunsul ar fi un buton
	# corect marcat greșit.
	for greseala in _greselile(q):
		if greseala == asteptat:
			return "o greseala e chiar lucrul lui %s" % cine
	return ""


## „Cine avea toporul?"
func _bate_cine_avea(q: Dictionary) -> String:
	var perechi := _perechile_aratate(q)
	var hotarat := String(q["text"]).get_slice("Cine avea ", 1).trim_suffix("?")
	# Forma hotărâtă vine din tabelul jocului, deci gramatica NU se verifică
	# aici (vezi antetul fișierului). Ce se verifică e POTRIVIREA: cine avea
	# lucrul ăla, pe perechile citite din ce s-a arătat.
	var nehotarat := ""
	for lucru in RETINERE.LUCRURI:
		if String(lucru["acela"]) == hotarat:
			nehotarat = String(lucru["unul"])
			break
	if nehotarat == "":
		return "„%s” nu e forma hotarata a niciunui lucru" % hotarat

	var asteptat := ""
	for cine in perechi:
		if String(perechi[cine]) == nehotarat:
			asteptat = String(cine)
			break
	if asteptat == "":
		return "lucrul „%s” nu e intre cele aratate" % nehotarat
	if _corecta(q) != asteptat:
		return "%s il avea %s, nu %s" % [nehotarat, asteptat, _corecta(q)]
	for varianta in q["variante"]:
		if not perechi.has(String(varianta)):
			return "varianta „%s” nu e un nume aratat" % String(varianta)
	return ""


# ─────────────────────────────────────────────────────────────
# 4. EXPUNERILE — secțiunea care nu există la nicio altă disciplină
#
# Vezi antetul fișierului pentru cele patru feluri în care cârligul de expunere
# se poate strica fără să crape nimic.
# ─────────────────────────────────────────────────────────────

func _expunerile() -> bool:
	print("  EXPUNERILE")
	var rezultat := true

	var fara_expunere: Array[String] = []
	var antet_necunoscut: Array[String] = []
	var durata_stramba: Array[String] = []
	var enunt_scurs: Array[String] = []
	var nota_sageata: Array[String] = []
	var deseneaza_gresit: Array[String] = []
	# Durata pe tipar și nivel, pentru verdictul „crește de la un nivel la altul".
	var durate := {}

	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var tip := String(generator["tip"])
		for nivel in generator["niveluri"]:
			for i in range(20):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				var eticheta := "%s/%d" % [metoda, int(nivel)]

				# A. CERE O EXPUNERE. Un tipar fără ea ar pune întrebarea cu
				# tot ce trebuia ținut minte încă pe ecran.
				var durata := float(q.get("expunere", 0.0))
				var aratat_tot := String(q.get("text_expunere", ""))
				if durata <= 0.0 or aratat_tot.strip_edges() == "":
					fara_expunere.append(eticheta)
					break
				durate[eticheta] = durata

				# B. ANTETUL e unul din cele patru scrise aici, nu în joc.
				var fel := _felul_expunerii(aratat_tot)
				if fel == "":
					antet_necunoscut.append("%s: „%s”" % [
						eticheta, aratat_tot.get_slice("\n", 0),
					])
					break

				# C. DURATA se potrivește cu CÂTE SEMNE s-au arătat. Greșeala
				# de prins: perechile numărate o dată în loc de două ori.
				var semne := _semnele(q)
				var jos := clampf(
					float(semne.size()) * MIN_PE_SEMN,
					RETINERE.EXPUNERE_MINIMA, RETINERE.EXPUNERE_MAXIMA
				)
				var sus := clampf(
					float(semne.size()) * MAX_PE_SEMN,
					RETINERE.EXPUNERE_MINIMA, RETINERE.EXPUNERE_MAXIMA
				)
				if durata < jos - 0.01 or durata > sus + 0.01:
					durata_stramba.append("%s: %d semne, %.2f s" % [
						eticheta, semne.size(), durata,
					])
					break

				# D. ENUNȚUL nu arată ce trebuia ținut minte. Cel mult UN semn
				# are voie să apară în el — reperul („dupa 9"), cuvântul
				# căutat, numele celui întrebat.
				#
				# Se numără CUVINTE ÎNTREGI, nu bucăți de text, și prima
				# scriere a verificării a picat exact pe asta: literele unui
				# caroiaj au un singur caracter, iar „L" se găsește în
				# „Liniile se numara…", adică în chiar rândul care declară
				# convenția. Un semn găsit la mijlocul unui cuvânt nu e o
				# scurgere; unul care stă singur este.
				var in_enunt := _semnele_din_enunt(String(q["text"]), semne)
				if in_enunt > 1:
					enunt_scurs.append("%s: %d semne in enunt" % [eticheta, in_enunt])
					break
				# Și, separat, tot ce s-a arătat, lipit: un tipar care ar pune
				# șirul întreg în enunț ar fi prins și de numărătoarea de sus,
				# dar ăsta e verdictul care spune de ce.
				var aratat_bloc := _aratat(q)
				if aratat_bloc != "" and String(q["text"]).contains(aratat_bloc):
					enunt_scurs.append("%s: enuntul cuprinde toata expunerea" % eticheta)
					break

				# E. NOTA repetă TOT ce s-a arătat. Singura cale prin care afli
				# ce ai ratat, fiindcă figura a dispărut (vezi `retinere.gd`).
				var nota := String(q["explicatie"])
				var lipsa_din_nota: Array[String] = []
				for semn in semne:
					if not nota.contains(semn):
						lipsa_din_nota.append(semn)
				if not lipsa_din_nota.is_empty():
					nota_sageata.append("%s: lipsesc %s" % [
						eticheta, _primele(lipsa_din_nota, 3),
					])
					break

				# F. DESENEAZĂ doar CAROIAJUL. Oglinda verdictului de la
				# Spațial („BUSOLA nu desenează nimic"): aici trei tipuri din
				# patru nu desenează, iar al patrulea desenează mereu. Dacă
				# vreodată nu mai e așa, cârligul a încetat să fie opțional.
				var are_plansa: bool = not (q.get("plansa", {}) as Dictionary).is_empty()
				if (tip == "CAROIAJUL") != are_plansa:
					deseneaza_gresit.append("%s: tip %s, plansa %s" % [
						eticheta, tip, are_plansa,
					])
					break

	rezultat = _verdict(
		"fiecare tipar cere o expunere",
		fara_expunere.is_empty(), _primele(fara_expunere, 5)
	) and rezultat
	rezultat = _verdict(
		"fiecare expunere are un antet cunoscut",
		antet_necunoscut.is_empty(), _primele(antet_necunoscut, 5)
	) and rezultat
	rezultat = _verdict(
		"durata se potriveste cu CATE semne s-au aratat",
		durata_stramba.is_empty(), _primele(durata_stramba, 5)
	) and rezultat
	rezultat = _verdict(
		"enuntul nu arata ce trebuia tinut minte",
		enunt_scurs.is_empty(), _primele(enunt_scurs, 5)
	) and rezultat
	rezultat = _verdict(
		"nota repeta TOT ce s-a aratat",
		nota_sageata.is_empty(), _primele(nota_sageata, 5)
	) and rezultat
	rezultat = _verdict(
		"deseneaza numai CAROIAJUL, si el mereu",
		deseneaza_gresit.is_empty(), _primele(deseneaza_gresit, 5)
	) and rezultat

	# G. DURATA CREȘTE DE LA UN NIVEL LA ALTUL. Verdictul ăsta e cel care prinde
	# o greșeală pe care niciunul de mai sus n-ar prinde-o: un tabel
	# `..._PE_NIVEL` scris cu aceeași cifră de trei ori. Totul ar fi corect,
	# nimic n-ar crăpa, și nivelurile n-ar însemna nimic. Aceeași lecție ca la
	# `_reducere` din Numere (vezi CLAUDE.md).
	var nu_cresc: Array[String] = []
	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var niveluri: Array = generator["niveluri"]
		if niveluri.size() < 2:
			continue   # un tipar cu un singur nivel n-are ce să crească
		for i in range(niveluri.size() - 1):
			var acum := float(durate.get("%s/%d" % [metoda, int(niveluri[i])], 0.0))
			var apoi := float(durate.get("%s/%d" % [metoda, int(niveluri[i + 1])], 0.0))
			if apoi <= acum:
				nu_cresc.append("%s: %.2f s la %d, %.2f s la %d" % [
					metoda, acum, int(niveluri[i]), apoi, int(niveluri[i + 1]),
				])
	rezultat = _verdict(
		"se arata mai mult de la un nivel la altul",
		nu_cresc.is_empty(), _primele(nu_cresc, 5)
	) and rezultat

	# Și plafonul: nicio expunere nu poate ieși din intervalul declarat.
	var in_afara: Array[String] = []
	for eticheta in durate:
		var durata := float(durate[eticheta])
		if durata < RETINERE.EXPUNERE_MINIMA - 0.01 or durata > RETINERE.EXPUNERE_MAXIMA + 0.01:
			in_afara.append("%s: %.2f s" % [eticheta, durata])
	rezultat = _verdict(
		"nicio expunere sub %.1f s sau peste %.1f s" % [
			RETINERE.EXPUNERE_MINIMA, RETINERE.EXPUNERE_MAXIMA,
		],
		in_afara.is_empty(), _primele(in_afara, 5)
	) and rezultat

	return rezultat


## Câte dintre semnele arătate apar în enunț ca CUVINTE ÎNTREGI.
##
## Textul se taie în cuvinte la orice caracter care nu e literă sau cifră, iar
## un semn se numără doar dacă e unul din cuvintele alea. Vezi verdictul D din
## `_expunerile()` pentru de ce nu se poate căuta pur și simplu cu `contains`.
func _semnele_din_enunt(text: String, semne: Array[String]) -> int:
	var cuvinte := {}
	var acum := ""
	for i in range(text.length() + 1):
		var ch := text[i] if i < text.length() else " "
		if (ch >= "0" and ch <= "9") or (ch >= "A" and ch <= "Z") or (ch >= "a" and ch <= "z"):
			acum += ch
		else:
			if acum != "":
				cuvinte[acum] = true
			acum = ""
	var cate := 0
	for semn in semne:
		if cuvinte.has(semn):
			cate += 1
	return cate


## Ce fel de expunere e, după antetul ei. Șir gol = antet necunoscut.
func _felul_expunerii(text: String) -> String:
	for antet in ANTETE:
		if text.begins_with(String(antet)):
			return String(ANTETE[antet])
	return ""


## Semnele arătate, ca listă de șiruri. Ce vede jucătorul, descompus — nu ce a
## tras generatorul la sorți.
##
## La PERECHI sunt DOUĂ semne pe rând (numele și lucrul), și aici e tot rostul
## funcției: un tipar de perechi care numără trei în loc de șase ar primi
## jumătate din secunde, iar singurul loc în care se vede e numărătoarea asta,
## făcută din ce e pe ecran.
func _semnele(q: Dictionary) -> Array[String]:
	match _felul_expunerii(String(q.get("text_expunere", ""))):
		"cifre":
			return _cifrele_aratate(q)
		"cuvinte":
			return _cuvintele_aratate(q)
		"perechi":
			var semne: Array[String] = []
			var perechi := _perechile_aratate(q)
			for cine in perechi:
				semne.append(String(cine))
				semne.append(String(perechi[cine]))
			return semne
		"caroiaj":
			return _literele_aratate(q)
	return []


# ─────────────────────────────────────────────────────────────
# 5. CAROIAJELE
#
# Aceeași grijă ca la Spațial (celule în afara marginilor, celule duble), plus
# două care sunt ale disciplinei ăsteia:
#
#   • caroiajul e PLIN. La Spațial o planșă poate avea găuri (desfășurata
#     cubului); aici o celulă nedeclarată ar fi un loc gol pe care întrebarea
#     „ce literă era în linia 2, coloana 3" l-ar putea nimeri;
#   • cel mult NOUĂ litere. Plafonul desenatorului (4×4 = 16) e mult deasupra:
#     șaisprezece litere arătate pentru o întrebare despre una singură e o
#     întrebare pe care o nimerești cu noroc.
# ─────────────────────────────────────────────────────────────

func _plansele() -> bool:
	print("  CAROIAJELE")
	var rezultat := true

	var margini: Array[String] = []
	var duble: Array[String] = []
	var gauri: Array[String] = []
	var prea_mari: Array[String] = []
	var litere_duble: Array[String] = []

	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		if String(generator["tip"]) != "CAROIAJUL":
			continue
		for nivel in generator["niveluri"]:
			for i in range(TRAGERI_PE_TIPAR):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				var eticheta := "%s/%d" % [metoda, int(nivel)]
				var plansa: Dictionary = q.get("plansa", {})
				var linii := int(plansa.get("linii", 0))
				var coloane := int(plansa.get("coloane", 0))
				var celule: Array = plansa.get("celule", [])

				if linii > MAX_LATURA_PLANSA or coloane > MAX_LATURA_PLANSA:
					prea_mari.append("%s: %dx%d" % [eticheta, linii, coloane])
					break
				if celule.size() > MAX_LITERE_PLANSA:
					prea_mari.append("%s: %d litere" % [eticheta, celule.size()])
					break

				var pe_loc := {}
				var o_problema := false
				for celula in celule:
					var l := int(celula.get("linie", 0))
					var c := int(celula.get("coloana", 0))
					if l < 1 or l > linii or c < 1 or c > coloane:
						margini.append("%s: celula %d,%d pe %dx%d" % [
							eticheta, l, c, linii, coloane,
						])
						o_problema = true
						break
					var cheie := "%d,%d" % [l, c]
					if pe_loc.has(cheie):
						duble.append("%s: doua celule la %s" % [eticheta, cheie])
						o_problema = true
						break
					pe_loc[cheie] = String(celula.get("text", ""))
				if o_problema:
					break

				# PLIN: fiecare loc din dreptunghi are o celulă cu o literă.
				if pe_loc.size() != linii * coloane:
					gauri.append("%s: %d celule pentru %dx%d" % [
						eticheta, pe_loc.size(), linii, coloane,
					])
					break
				var fara_litera := false
				for cheie in pe_loc:
					if String(pe_loc[cheie]) == "":
						gauri.append("%s: celula %s fara litera" % [eticheta, cheie])
						fara_litera = true
						break
				if fara_litera:
					break

				# LITERE DISTINCTE: „unde era K" ar avea două răspunsuri cu
				# două K-uri pe caroiaj.
				var vazute := {}
				var repetata := ""
				for cheie in pe_loc:
					var litera := String(pe_loc[cheie])
					if vazute.has(litera):
						repetata = litera
						break
					vazute[litera] = true
				if repetata != "":
					litere_duble.append("%s: %s de doua ori" % [eticheta, repetata])
					break

	rezultat = _verdict(
		"nicio celula in afara marginilor", margini.is_empty(), _primele(margini, 5)
	) and rezultat
	rezultat = _verdict(
		"nicio celula de doua ori", duble.is_empty(), _primele(duble, 5)
	) and rezultat
	rezultat = _verdict(
		"caroiajul e plin, fara gauri", gauri.is_empty(), _primele(gauri, 5)
	) and rezultat
	rezultat = _verdict(
		"cel mult %dx%d si %d litere" % [
			MAX_LATURA_PLANSA, MAX_LATURA_PLANSA, MAX_LITERE_PLANSA,
		],
		prea_mari.is_empty(), _primele(prea_mari, 5)
	) and rezultat
	rezultat = _verdict(
		"literele unui caroiaj sunt distincte",
		litere_duble.is_empty(), _primele(litere_duble, 5)
	) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 6. FONTURILE AU CARACTERELE
#
# Aceeași verificare ca la Numere, Tipare și Spațial, cu o bucată în plus:
# TEXTUL DE EXPUNERE. El se desenează printr-un `Label` (deci fontul temei), iar
# literele caroiajului prin `draw_string` — un caracter lipsă din font ar fi un
# dreptunghi gol exact în lucrul pe care trebuie să-l ții minte.
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
	for generator in RETINERE.GENERATOARE:
		for nivel in generator["niveluri"]:
			for i in range(20):
				var q: Dictionary = scena.call(String(generator["metoda"]), int(nivel))
				if q.is_empty():
					continue
				var tot := "%s %s %s %s" % [
					q["text"], " ".join(q["variante"]), q["explicatie"],
					q.get("text_expunere", ""),
				]
				for litera in _literele_aratate(q):
					tot += litera
				for ch in tot:
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
		rezultat = _verdict(
			"%s are toate caracterele" % nume,
			lipsa.is_empty(), _primele(lipsa, 8)
		) and rezultat

	return rezultat


# ─────────────────────────────────────────────────────────────
# 7. ECHILIBRUL PE TIPURI
#
# Alegerea e în două trepte (întâi tipul, apoi tiparul) tocmai ca SIRUL, cu
# cinci tipare, să nu apară de două ori și jumătate mai des decât PERECHILE, cu
# două. E o probabilitate, nu o listă: se vede la mii de trageri.
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL (%d trageri pe nivel)" % TRAGERI_ECHILIBRU)
	var rezultat := true

	var tip_pe_antet := {}
	for generator in RETINERE.GENERATOARE:
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
# 8. FĂRĂ REPETIȚII PE EXPEDIȚIE
#
# Aici cifra înseamnă mai mult decât la oricare altă disciplină, Spațialul
# inclusiv: la „ce cifră era pe locul 3" enunțul e IDENTIC la toate întrebările
# tiparului, iar variantele sunt cifrele șirului. Fără `_identitate_intrebare`
# suprascrisă (care cuprinde expunerea), două șiruri care sunt permutări unul
# altuia ar fi socotite aceeași întrebare — și, fiind multe astfel de perechi,
# s-ar „repeta" mereu.
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
# 9. EXPUNEREA, JUCATĂ CU SCENA ADEVĂRATĂ
#
# Singura secțiune care deschide scene, și singura care nu e despre conținut.
# Tot ce e mai sus verifică GENERATORUL: că întrebarea cere o expunere, că
# durata se potrivește cu ce se arată, că nota repetă tot. Niciuna din ele nu
# atinge faza propriu-zisă — ea trăiește în `puzzle.gd`, adică în al doilea
# cârlig din contractul tuturor disciplinelor, iar un cârlig din contract se
# bate cu scena, nu cu scriptul (aceeași alegere ca la `verifica_duelul`).
#
# CEASUL SE ÎNVÂRTE DE MÂNĂ, nu se așteaptă. O expunere ține 2-6,5 secunde, iar
# șaisprezece întrebări × două moduri ar fi fost un minut și jumătate la fiecare
# rulare. `_process(delta)` E tot cronometrul (vezi `puzzle.gd`), deci se cheamă
# direct cu un delta cât toată expunerea: același drum prin cod, într-o clipă.
#
# SE JOACĂ ȘI ÎN MODUL PRACTICE (`cu_cronometru = false`), fiindcă ACOLO e
# decizia care se poate strica în tăcere: ceasul ÎNTREBĂRII e stins, dar cel al
# EXPUNERII trebuie să curgă oricum — altfel ce trebuie ținut minte rămâne pe
# ecran la nesfârșit și disciplina încetează să existe. Un `set_process` legat
# greșit de `cu_cronometru` n-ar crăpa nimic și n-ar fi prins nicăieri altundeva.
#
# ȘI SE JOACĂ O DISCIPLINĂ FĂRĂ EXPUNERE, la final: celelalte șase nu trebuie
# să simtă nimic. Dacă vreodată faza s-ar aprinde și la ele, ecranul lor s-ar
# umple de „?" pentru câteva secunde, iar niciuna din verificările lor nu se
# uită la asta.
# ─────────────────────────────────────────────────────────────

func _expunerea_jucata() -> bool:
	print("  EXPUNEREA, JUCATA CU SCENA ADEVARATA (%d intrebari x 2 moduri)" % JOCURI_CU_SCENA)
	var rezultat := true

	var probleme: Array[String] = []
	var cu_plansa := 0

	for cu_ceas in [true, false]:
		var mod := "lupta" if cu_ceas else "practice"
		for i in range(JOCURI_CU_SCENA):
			var puzzle: Puzzle = SCENA_RETINERE.instantiate()
			# ÎNAINTE de `porneste`, ca orice altceva din contract.
			puzzle.cu_cronometru = cu_ceas
			puzzle.cu_pauza_citire = cu_ceas
			add_child(puzzle)
			puzzle.porneste(1 + i % 3)

			var greseala := _problema_de_expunere(puzzle, mod)
			if greseala == "" and puzzle.cutia_plansa.get_child_count() > 0:
				cu_plansa += 1
			if greseala == "":
				greseala = _problema_de_dupa_expunere(puzzle, mod)
			if greseala != "":
				probleme.append(greseala)

			remove_child(puzzle)
			puzzle.free()
			# Un cadru între întrebări: scena a avut tween-uri și un ceas, iar
			# `_exit_tree` are de stins ticăitul.
			await get_tree().process_frame

	rezultat = _verdict(
		"faza de expunere merge in amandoua modurile",
		probleme.is_empty(), _primele(probleme, 5)
	) and rezultat
	rezultat = _verdict(
		"printre ele a picat si un caroiaj desenat",
		cu_plansa > 0, "%d din %d" % [cu_plansa, JOCURI_CU_SCENA * 2]
	) and rezultat

	# O DISCIPLINĂ FĂRĂ EXPUNERE: Numere, aleasă fiindcă n-are fișier de date,
	# deci nu poate pica aici din alt motiv.
	var altele: Array[String] = []
	for cu_ceas in [true, false]:
		var puzzle: Puzzle = SCENA_NUMERE.instantiate()
		puzzle.cu_cronometru = cu_ceas
		add_child(puzzle)
		puzzle.porneste(2)
		if puzzle.in_expunere:
			altele.append("Numere a intrat in expunere")
		if puzzle.bara_timp.visible != cu_ceas:
			altele.append("Numere: bara vizibila %s cu ceasul %s" % [
				puzzle.bara_timp.visible, cu_ceas,
			])
		for buton: Button in puzzle.butoane:
			if buton.disabled or buton.text == "?":
				altele.append("Numere: buton „%s”, disabled %s" % [
					buton.text, buton.disabled,
				])
				break
		remove_child(puzzle)
		puzzle.free()
		await get_tree().process_frame
	rezultat = _verdict(
		"o disciplina fara expunere nu simte nimic",
		altele.is_empty(), _primele(altele, 5)
	) and rezultat

	return rezultat


## Ce e în neregulă CÂT ȚINE expunerea. Șir gol dacă totul e cum trebuie.
func _problema_de_expunere(puzzle: Puzzle, mod: String) -> String:
	if not puzzle.in_expunere:
		return "%s: n-a intrat in expunere" % mod
	if puzzle.expunere_ramasa <= 0.0:
		return "%s: expunere de %.2f s" % [mod, puzzle.expunere_ramasa]

	# Pe ecran stă textul de expunere, nu întrebarea.
	if _felul_expunerii(puzzle.eticheta_intrebare.text) == "":
		return "%s: pe ecran scrie „%s”" % [mod, puzzle.eticheta_intrebare.text]

	# Variantele sunt ascunse sub un semn și nu se pot apăsa. Dacă s-ar citi,
	# „ține minte caroiajul" ar deveni „ține minte dacă era K, M, T sau V".
	for buton: Button in puzzle.butoane:
		if buton.text != "?":
			return "%s: buton cu „%s” in timpul expunerii" % [mod, buton.text]
		if not buton.disabled:
			return "%s: buton apasabil in timpul expunerii" % mod

	# BARA MĂSOARĂ EXPUNEREA — și în Practice, unde altminteri e ascunsă.
	if not puzzle.bara_timp.visible:
		return "%s: bara ascunsa in timpul expunerii" % mod
	if absf(puzzle.bara_timp.max_value - puzzle.expunere_ramasa) > 0.01:
		return "%s: bara pe %.2f, expunerea %.2f" % [
			mod, puzzle.bara_timp.max_value, puzzle.expunere_ramasa,
		]
	# Și ceasul chiar curge, orice ar zice `cu_cronometru`.
	if not puzzle.is_processing():
		return "%s: ceasul expunerii nu curge" % mod
	return ""


## Ce e în neregulă DUPĂ ce expunerea s-a scurs. Învârte chiar ceasul.
func _problema_de_dupa_expunere(puzzle: Puzzle, mod: String) -> String:
	var avea_plansa := puzzle.cutia_plansa.get_child_count() > 0
	var timp_cerut: float = puzzle.timp_dupa_expunere

	# Un singur cadru, cât toată expunerea: `_process` E cronometrul.
	puzzle._process(puzzle.expunere_ramasa + 0.01)

	if puzzle.in_expunere:
		return "%s: expunerea nu s-a terminat" % mod
	# CE TREBUIA ȚINUT MINTE A DISPĂRUT. Verdictul pentru care există faza.
	if avea_plansa and puzzle.cutia_plansa.get_child_count() > 0:
		return "%s: caroiajul a ramas pe ecran" % mod
	if avea_plansa and puzzle.cutia_plansa.visible:
		return "%s: cutia plansei a ramas vizibila" % mod
	# Întrebarea a luat locul textului de expunere.
	if _felul_expunerii(puzzle.eticheta_intrebare.text) != "":
		return "%s: pe ecran a ramas textul expunerii" % mod
	# Variantele au apărut și se pot apăsa.
	var vazute := {}
	for buton: Button in puzzle.butoane:
		if buton.text == "?" or buton.text.strip_edges() == "":
			return "%s: buton gol dupa expunere" % mod
		if buton.disabled:
			return "%s: buton blocat dupa expunere" % mod
		if vazute.has(buton.text):
			return "%s: doua butoane cu „%s”" % [mod, buton.text]
		vazute[buton.text] = true
	# ABIA ACUM începe timpul întrebării, întreg.
	if absf(puzzle.timp_ramas - timp_cerut) > 0.01:
		return "%s: intrebarea a pornit cu %.2f s din %.2f" % [
			mod, puzzle.timp_ramas, timp_cerut,
		]
	# Și bara se întoarce la regula ei obișnuită: măsoară doar ce există.
	if puzzle.bara_timp.visible != puzzle.cu_cronometru:
		return "%s: bara vizibila %s dupa expunere" % [mod, puzzle.bara_timp.visible]
	if puzzle.is_processing() != puzzle.cu_cronometru:
		return "%s: ceasul intrebarii curge %s" % [mod, puzzle.is_processing()]
	return ""


# ─────────────────────────────────────────────────────────────
# 10. CÂT SE CITEȘTE — nu dă verdicte, TIPĂREȘTE
#
# Aici se citesc DOUĂ texte, nu unul: ce se arată și ce se întreabă. Iar între
# ele e o expunere de câteva secunde, deci tot ce e lung se plătește de două
# ori. Dacă ceva din disciplina asta e nejucabil, aici se vede.
#
# Mostrele sunt și singurul loc în care se vede GRAMATICA formei hotărâte
# („Cine avea cupa?" față de „Cine avea cupaul?"), fiindcă pe aia n-o poate
# bate nicio verificare — vezi antetul fișierului.
# ─────────────────────────────────────────────────────────────

func _cat_se_citeste() -> void:
	print("\n  CAT SE CITESTE (cea mai lunga intrebare, pe tipar)")
	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var lung := String(cel_mai_lung.get(metoda, ""))
		print("    %-24s %3d semne   %s" % [
			metoda, lung.length(), lung.replace("\n", " / "),
		])

	print("\n  O MOSTRA DIN FIECARE TIPAR")
	for generator in RETINERE.GENERATOARE:
		var metoda := String(generator["metoda"])
		var q: Dictionary = o_mostra.get(metoda, {})
		if q.is_empty():
			continue
		print("\n    [%s]  se arata %.1f s:  %s" % [
			generator["categorie"], float(q.get("expunere", 0.0)),
			String(q.get("text_expunere", "")).replace("\n", " / "),
		])
		for rand in _caroiajul_ca_text(q):
			print("       %s" % rand)
		print("       apoi: %s" % String(q["text"]).replace("\n", " / "))
		var variante: Array = q["variante"]
		for i in range(variante.size()):
			print("       %s %s" % ["→" if i == int(q["corect"]) else " ", variante[i]])
		print("       nota: %s" % q["explicatie"])


## Caroiajul desenat cu caractere, ca să-l pot citi în terminal.
func _caroiajul_ca_text(q: Dictionary) -> Array[String]:
	var plansa: Dictionary = q.get("plansa", {})
	if plansa.is_empty():
		return []
	var randuri: Array[String] = []
	for linie in range(1, int(plansa["linii"]) + 1):
		var bucati: Array[String] = []
		for coloana in range(1, int(plansa["coloane"]) + 1):
			var litera := _litera_la(q, linie, coloana)
			bucati.append(litera if litera != "" else ".")
		randuri.append(" ".join(bucati))
	return randuri


# ─────────────────────────────────────────────────────────────
# UNELTELE DE CITIT CE S-A ARĂTAT
#
# Toate pornesc de la `text_expunere` sau de la `plansa`. Vezi antetul
# fișierului: ăsta e drumul al doilea, cel care pleacă de la ecran spre date, în
# timp ce jocul pleacă de la date spre ecran.
# ─────────────────────────────────────────────────────────────

## Partea de DUPĂ antet: ce s-a arătat propriu-zis. Șir gol la caroiaj, fiindcă
## acolo ce s-a arătat e în planșă, nu în text.
func _aratat(q: Dictionary) -> String:
	var text := String(q.get("text_expunere", ""))
	var taietura := text.find("\n\n")
	if taietura < 0:
		return ""
	return text.substr(taietura + 2).strip_edges()


func _cifrele_aratate(q: Dictionary) -> Array[String]:
	var cifre: Array[String] = []
	for bucata in _aratat(q).split(" ", false):
		var curat := String(bucata).strip_edges()
		if curat != "":
			cifre.append(curat)
	return cifre


func _cuvintele_aratate(q: Dictionary) -> Array[String]:
	var cuvinte: Array[String] = []
	for bucata in _aratat(q).split(",", false):
		var curat := String(bucata).strip_edges()
		if curat != "":
			cuvinte.append(curat)
	return cuvinte


## Perechile arătate, ca dicționar nume → lucru.
func _perechile_aratate(q: Dictionary) -> Dictionary:
	var perechi := {}
	for rand in _aratat(q).split("\n", false):
		var bucati := String(rand).split(" - ")
		if bucati.size() != 2:
			continue
		perechi[String(bucati[0]).strip_edges()] = String(bucati[1]).strip_edges()
	return perechi


## Literele de pe caroiaj, în ordinea de citire.
func _literele_aratate(q: Dictionary) -> Array[String]:
	var litere: Array[String] = []
	var plansa: Dictionary = q.get("plansa", {})
	for celula in plansa.get("celule", []):
		var text := String(celula.get("text", ""))
		if text != "":
			litere.append(text)
	return litere


## Litera de pe caroiaj la coordonata dată, citită din celule (nu din indici).
## Șir gol dacă nu există nicio celulă acolo.
func _litera_la(q: Dictionary, linie: int, coloana: int) -> String:
	var plansa: Dictionary = q.get("plansa", {})
	for celula in plansa.get("celule", []):
		if int(celula.get("linie", 0)) == linie and int(celula.get("coloana", 0)) == coloana:
			return String(celula.get("text", ""))
	return ""


## Unde e litera pe caroiaj, ca (linie, coloana). (-1, -1) dacă nu e.
func _unde_e_litera(q: Dictionary, litera: String) -> Vector2i:
	var plansa: Dictionary = q.get("plansa", {})
	for celula in plansa.get("celule", []):
		if String(celula.get("text", "")) == litera:
			return Vector2i(int(celula.get("linie", 0)), int(celula.get("coloana", 0)))
	return Vector2i(-1, -1)


## Numărul scris imediat după o bucată de text. -1 dacă bucata nu e acolo.
func _numarul_dupa(text: String, inainte: String) -> int:
	var unde := text.find(inainte)
	if unde < 0:
		return -1
	var cifre := ""
	for i in range(unde + inainte.length(), text.length()):
		var ch := text[i]
		if ch >= "0" and ch <= "9":
			cifre += ch
		else:
			break
	return int(cifre) if cifre != "" else -1


## O singură cifră, scrisă imediat după o bucată de text.
func _cifra_dupa(text: String, inainte: String) -> String:
	var numar := _numarul_dupa(text, inainte)
	return "" if numar < 0 else str(numar)


## O singură literă, scrisă imediat după o bucată de text.
func _litera_dupa(text: String, inainte: String) -> String:
	var unde := text.find(inainte)
	if unde < 0:
		return ""
	var i := unde + inainte.length()
	return "" if i >= text.length() else text[i]


func _corecta(q: Dictionary) -> String:
	return String(q["variante"][int(q["corect"])])


## Cele trei variante care nu sunt răspunsul bun.
func _greselile(q: Dictionary) -> Array[String]:
	var gresite: Array[String] = []
	var variante: Array = q["variante"]
	for i in range(variante.size()):
		if i != int(q["corect"]):
			gresite.append(String(variante[i]))
	return gresite


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

extends Node
## VERIFICAREA SPAȚIALULUI — cele 4 tipuri, cele 12 tipare, și figurile.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_spatial.tscn
##
## ─────────────────────────────────────────────────────────────
## CE E ALTFEL AICI: SE VERIFICĂ ȘI CE SE VEDE
##
## La celelalte cinci discipline, tot ce putea fi greșit era în TEXT. Aici
## jumătate din întrebare e o planșă desenată, iar o planșă poate fi stricată
## în feluri în care un enunț nu poate: o celulă în afara marginilor, două
## celule pe același loc, două litere identice pe un caroiaj la care tocmai
## întrebi „ce e la dreapta lui M", niciun punct sau două puncte la o rotație.
## Niciuna n-ar crăpa jocul; toate ar face întrebarea nedreaptă.
##
## De-aia planșa are secțiunea ei, și de-aia ea se citește ca DATE: întrebarea
## poartă un dicționar de celule, nu un nod (vezi `_plansa_pentru` din
## `puzzle.gd`), deci verificarea se uită la exact ce se va desena.
##
## ─────────────────────────────────────────────────────────────
## REZOLVAREA A DOUA, ȘI DE CE NU E O COPIE A PRIMEI
##
## Lecția e scrisă în CLAUDE.md și a fost plătită la `_reducere`: „o verificare
## care copiază formula nu verifică formula". Jocul rotește o celulă cu o
## socoteală pe indici (`linia devine coloană, coloana devine n+1-linie`). Dacă
## verificarea ar face aceeași socoteală, ar obține aceeași greșeală.
##
## Deci aici rotația se face ALTFEL: se construiește MATRICEA planșei, cu un
## `true` în celula punctului, și se rotește cu operații de LISTĂ —
## transpunere și întoarcerea rândurilor. Fără nicio adunare pe indici. Apoi se
## caută unde a ajuns `true`. Două drumuri cu totul diferite, care trebuie să
## cadă de acord.
##
## La pliere, la fel, dar mai tare: jocul știe perechile opuse din CONSTRUCȚIE
## (banda de patru se închide, deci prima e opusă celei de-a treia). Verificarea
## nu știe nimic despre bandă — ea PLIAZĂ desfășurata, mergând din celulă în
## celulă și rotind un sistem de axe în trei dimensiuni, și află la final ce
## normală are fiecare față. Aceeași metodă ca la Lacăt și ca la intrusul de la
## Tipare: un puzzle nu se crede pe cuvânt, se rezolvă.
##
## La busolă, întoarcerile se refac din TABELE SCRISE DE MÂNĂ (douăsprezece
## rânduri: „NORD + la DREAPTA = EST"), nu cu `posmod(+1)` ca în joc. Un semn
## întors în joc n-are cum să se strecoare și în douăsprezece rânduri scrise
## separat.
##
## ─────────────────────────────────────────────────────────────
## CE NU VERIFICĂ
##
## Dacă figura ARATĂ bine. Că o planșă 4×4 cu patru celule pline și un punct se
## citește dintr-o privire pe un panou de luptă nu e un verdict — e „arată
## bine?", întrebarea care are, în proiectul ăsta, un singur răspuns cinstit:
## F6 și ochiul. Ce se poate verifica (și se verifică) e că planșa INTRĂ în
## spațiul de care dispune: cel mult 4×4 celule de 30 px.

const SPATIAL := preload("res://scenes/spatial/spatial.gd")

# Câte întrebări se trag din fiecare tipar, la fiecare nivel din tabelul lui.
const TRAGERI_PE_TIPAR := 200

# Echilibrul pe tipuri. La 4 tipuri ar trebui să iasă ~2000 fiecare.
const TRAGERI_ECHILIBRU := 8000
const TOLERANTA_ECHILIBRU := 0.20

# Cât poate pica un tipar fără ca asta să fie o problemă. Aici pragul contează
# mai mult decât la Numere: tipul ROTATIA cade des și legitim, fiindcă punctul
# nimerește poziții simetrice în care două din cele patru variante ar fi aceeași
# celulă (vezi `_celule_deosebite`). Jumătate rămâne însă limita: peste ea,
# tiparul se rărește în tăcere și eu aș crede că-l joc.
const MAX_RATA_DE_ESEC := 0.5

const TRAGERI_SAC := 300

# Cât de mare poate fi o planșă. Nu e o preferință, e măsura panoului de puzzle
# din luptă: 4 × 30 px plus antetul, bara, enunțul și cele patru butoane umplu
# ce e disponibil. Vezi `LATURA` din `plansa.gd`.
const MAX_LATURA_PLANSA := 4

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
	"_grila_vecin": "_bate_vecinul",
	"_grila_coordonata": "_bate_coordonata",
	"_grila_drum": "_bate_drumul",
	"_oglindire": "_bate_miscarea",
	"_rotatie_jumatate": "_bate_miscarea",
	"_rotatie_sfert": "_bate_miscarea",
	"_rotatie_dubla": "_bate_miscarea",
	"_busola_intoarceri": "_bate_intoarcerile",
	"_busola_spre_casa": "_bate_spre_casa",
	"_busola_drum_intors": "_bate_drumul_intors",
	"_pliere_perechea": "_bate_perechea",
	"_pliere_opusa": "_bate_opusa",
}

# ─────────────────────────────────────────────────────────────
# TABELELE SCRISE DE MÂNĂ
#
# Astea sunt a doua metodă, și de-aia sunt scrise, nu calculate. În joc o
# întoarcere e `posmod(unde + 1, 4)`; aici e un rând într-un tabel. Dacă
# vreodată semnul din joc se întoarce, cele douăsprezece rânduri de mai jos nu
# se întorc cu el.
# ─────────────────────────────────────────────────────────────
const INTOARCERI := {
	"NORD|la DREAPTA": "EST", "NORD|la STANGA": "VEST", "NORD|cu SPATELE": "SUD",
	"EST|la DREAPTA": "SUD", "EST|la STANGA": "NORD", "EST|cu SPATELE": "VEST",
	"SUD|la DREAPTA": "VEST", "SUD|la STANGA": "EST", "SUD|cu SPATELE": "NORD",
	"VEST|la DREAPTA": "NORD", "VEST|la STANGA": "SUD", "VEST|cu SPATELE": "EST",
}

## Pașii pe (est, nord). Aceleași valori ca `PAS` din joc, scrise a doua oară
## dinadins: două copii care trebuie să rămână egale sunt o verificare, una
## singură folosită de amândoi e un acord cu sine însuși.
const DEPLASARE := {
	"NORD": Vector2i(0, 1), "EST": Vector2i(1, 0),
	"SUD": Vector2i(0, -1), "VEST": Vector2i(-1, 0),
}

const OPUS := {
	"NORD": "SUD", "NORD-EST": "SUD-VEST", "EST": "VEST", "SUD-EST": "NORD-VEST",
	"SUD": "NORD", "SUD-VEST": "NORD-EST", "VEST": "EST", "NORD-VEST": "SUD-EST",
}

## Semnele deplasării → brațul rozei. Cheia e „semnul pe est, semnul pe nord".
const BRAT := {
	"0,1": "NORD", "1,1": "NORD-EST", "1,0": "EST", "1,-1": "SUD-EST",
	"0,-1": "SUD", "-1,-1": "SUD-VEST", "-1,0": "VEST", "-1,1": "NORD-VEST",
}

## Direcțiile de pe planșă, așa cum apar în enunțuri, cu pasul lor în
## (linie, coloană). Tot scrise, nu deduse.
const PE_PLANSA := {
	"DEASUPRA lui": Vector2i(-1, 0), "DEDESUBTUL lui": Vector2i(1, 0),
	"la STANGA lui": Vector2i(0, -1), "la DREAPTA lui": Vector2i(0, 1),
	"SUS": Vector2i(-1, 0), "JOS": Vector2i(1, 0),
	"la STANGA": Vector2i(0, -1), "la DREAPTA": Vector2i(0, 1),
}

## Mișcările de planșă, recunoscute după cum sunt scrise în enunț. Numele
## trebuie căutate în ordinea asta: „STANGA-DREAPTA" ar fi găsit în „la
## DREAPTA" dacă s-ar căuta bucăți mai scurte întâi.
const MISCARI := {
	"STANGA-DREAPTA": "laterala",
	"SUS-JOS": "orizontala",
	"JUMATATE de tura": "jumatate",
	"SFERT de tura la DREAPTA": "dreapta",
	"SFERT de tura la STANGA": "stanga",
}

var scena = null
var tot_bun := true

var cel_mai_lung := {}
var o_mostra := {}


func _ready() -> void:
	print("\n══ VERIFICAREA SPATIALULUI ══\n")

	# Scriptul, nu scena: niciun generator nu atinge un buton, iar planșa se
	# citește ca date. Deci nu se deschide nicio fereastră.
	scena = SPATIAL.new()

	tot_bun = _tabelul() and tot_bun
	tot_bun = _nivelurile() and tot_bun
	tot_bun = _contractul_si_rezolvarea() and tot_bun
	tot_bun = _plansele() and tot_bun
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
	for generator in SPATIAL.GENERATOARE:
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
	for generator in SPATIAL.GENERATOARE:
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
	for generator in SPATIAL.GENERATOARE:
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
		"cele 4 tipuri si cele 12 tipare",
		_tipurile().size() == 4 and SPATIAL.GENERATOARE.size() == 12,
		"%d tipuri, %d tipare" % [_tipurile().size(), SPATIAL.GENERATOARE.size()]
	) and rezultat

	return rezultat


func _tipurile() -> Array:
	var tipuri := {}
	for generator in SPATIAL.GENERATOARE:
		tipuri[String(generator["tip"])] = true
	return tipuri.keys()


# ─────────────────────────────────────────────────────────────
# 2. FIECARE TIP, LA TOATE TREI NIVELURILE
#
# Regula de echilibru a disciplinei, bătută și nu doar scrisă: dacă PLIEREA ar
# lipsi la nivelul I, celelalte trei tipuri și-ar împărți acolo toată
# probabilitatea, iar un sfert din disciplină n-ar apărea niciodată la începutul
# unei expediții.
# ─────────────────────────────────────────────────────────────

func _nivelurile() -> bool:
	print("  NIVELURILE")
	var rezultat := true

	for nivel in [1, 2, 3]:
		var cu_tipare := {}
		for generator in SPATIAL.GENERATOARE:
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
	for generator in SPATIAL.GENERATOARE:
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
# O singură buclă pentru amândouă, ca la Numere: n-are rost să tragi de două ori
# aceleași mii de întrebări.
#
# Se trage NUMAI pe nivelurile pe care tiparul le declară. La Numere se trăgea
# pe toate trei, fiindcă acolo tabelul n-are coloana „niveluri"; aici un tipar
# chemat la un nivel la care nu apare niciodată ar fi fost verificat într-o
# stare în care jocul nu-l aduce.
# ─────────────────────────────────────────────────────────────

func _contractul_si_rezolvarea() -> bool:
	print("  CONTRACTUL SI REZOLVAREA (%d trageri pe tipar, pe nivel)" % TRAGERI_PE_TIPAR)
	var rezultat := true

	var stricate: Array[String] = []
	var gresite: Array[String] = []
	var prea_des_gol: Array[String] = []

	for generator in SPATIAL.GENERATOARE:
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
		"RASPUNSUL, rezolvat din nou cu alta metoda",
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

	# Nota nu trebuie să conțină un loc de completat nelocuit: `{fata}` lăsat
	# așa ar fi apărut negru pe alb în creierul din chenar.
	var nota := String(q["explicatie"])
	if nota.contains("{") or nota.contains("}"):
		return "nota are un loc necompletat: „%s”" % nota

	return ""


# ─────────────────────────────────────────────────────────────
# REZOLVĂRILE — fiecare tipar, rezolvat din nou, pe alt drum
# ─────────────────────────────────────────────────────────────

## CAROIAJ: „Ce litera e imediat DEASUPRA lui M?"
##
## Se citește direcția și litera de pornire DIN ENUNȚ (nu din ce a avut
## generatorul în minte), se caută litera pe planșă după câmpurile `linie` și
## `coloana` ale celulelor, se face pasul, se citește ce e acolo.
##
## De-aia e un drum diferit: generatorul umple planșa dintr-o listă plată
## (`litere[(linie-1) * n + (coloana-1)]`), iar aici se citesc celulele una cu
## una. O greșeală în socoteala aia ar da o planșă pe care răspunsul e altul
## decât scrie generatorul — și se vede exact aici.
func _bate_vecinul(q: Dictionary) -> String:
	var text := String(q["text"])
	var cheie := ""
	for nume in ["DEASUPRA lui", "DEDESUBTUL lui", "la STANGA lui", "la DREAPTA lui"]:
		if text.contains(nume):
			cheie = nume
			break
	if cheie == "":
		return "nu gasesc direcția in enunt: „%s”" % text

	var pornire := text.substr(text.find(cheie) + cheie.length()).strip_edges().trim_suffix("?")
	var de_la := _unde_e_litera(q, pornire)
	if de_la == Vector2i.ZERO:
		return "litera „%s” nu e pe plansa" % pornire

	var ajunge: Vector2i = de_la + Vector2i(PE_PLANSA[cheie])
	var gasita := _litera_la(q, ajunge)
	if gasita == "":
		return "„%s” de la %s cade in afara plansei" % [cheie, pornire]
	if gasita != _corecta(q):
		return "„%s” %s e „%s”, nu „%s”" % [cheie, pornire, gasita, _corecta(q)]
	return ""


## COORDONATE: „Pe ce linie si coloana se afla litera M?"
func _bate_coordonata(q: Dictionary) -> String:
	var text := String(q["text"])
	var unde := text.find("litera ")
	if unde < 0:
		return "nu gasesc litera in enunt: „%s”" % text
	var litera := text.substr(unde + 7).strip_edges().trim_suffix("?")

	var celula := _unde_e_litera(q, litera)
	if celula == Vector2i.ZERO:
		return "litera „%s” nu e pe plansa" % litera

	var asteptat := "linia %d, coloana %d" % [celula.x, celula.y]
	if asteptat != _corecta(q):
		return "„%s” e in %s, nu in „%s”" % [litera, asteptat, _corecta(q)]
	return ""


## DRUM PE CAROIAJ: „Pornesti de la M: 1 SUS, apoi 2 la DREAPTA. Pe ce litera
## ajungi?" Drumul se reface pas cu pas, din enunț.
func _bate_drumul(q: Dictionary) -> String:
	var text := String(q["text"])
	var de_la := text.find("Pornesti de la ")
	var pana_la := text.find(":")
	if de_la < 0 or pana_la < 0:
		return "enunt necitibil: „%s”" % text
	var pornire := text.substr(de_la + 15, pana_la - de_la - 15).strip_edges()

	var sfarsit := text.find(". Pe ce litera")
	if sfarsit < 0:
		return "nu gasesc intrebarea: „%s”" % text
	var pasii := text.substr(pana_la + 1, sfarsit - pana_la - 1).split(", apoi ")

	var pozitie := _unde_e_litera(q, pornire)
	if pozitie == Vector2i.ZERO:
		return "litera „%s” nu e pe plansa" % pornire

	for pas in pasii:
		var bucati := String(pas).strip_edges().split(" ", false, 1)
		if bucati.size() != 2:
			return "pas necitibil: „%s”" % pas
		var cat := int(bucati[0])
		var nume := String(bucati[1])
		if not PE_PLANSA.has(nume):
			return "direcție necunoscuta: „%s”" % nume
		pozitie += Vector2i(PE_PLANSA[nume]) * cat

	var gasita := _litera_la(q, pozitie)
	if gasita == "":
		return "drumul iese din plansa (ajunge in %d,%d)" % [pozitie.x, pozitie.y]
	if gasita != _corecta(q):
		return "drumul ajunge pe „%s”, nu pe „%s”" % [gasita, _corecta(q)]
	return ""


## ROTAȚII ȘI OGLINDIRI — toate patru tiparele tipului, pe același drum.
##
## AICI E MIEZUL VERIFICĂRII, și singurul loc din joc unde o socoteală se reface
## cu o metodă de altă natură. Jocul mută punctul cu aritmetică pe indici; aici
## se construiește matricea planșei, cu `true` în celula punctului, și se
## rotește cu OPERAȚII DE LISTĂ: transpunere și `Array.reverse()`. Niciun indice
## nu se adună nicăieri.
##
## Dacă `_spre_dreapta` ar avea un `n` în loc de `n + 1`, punctul ar ajunge cu o
## celulă mai încolo, întrebarea ar arăta perfect normală (patru coordonate,
## una verde) și ar fi greșită. Numai o a doua metodă o prinde.
func _bate_miscarea(q: Dictionary) -> String:
	var n := _latura(q)
	if n == 0:
		return "intrebarea nu are plansa"
	var punct := _punctul(q)
	if punct == Vector2i.ZERO:
		return "plansa nu are punct"

	var miscari := _miscarile_din(String(q["text"]))
	if miscari.is_empty():
		return "nu gasesc nicio miscare in enunt: „%s”" % String(q["text"])

	var matrice := _matricea(n, punct)
	for miscare in miscari:
		match String(miscare):
			"laterala":
				matrice = _intoarce_fiecare_rand(matrice)
			"orizontala":
				matrice = _intoarce_ordinea(matrice)
			"dreapta":
				matrice = _intoarce_fiecare_rand(_transpune(matrice))
			"stanga":
				matrice = _transpune(_intoarce_fiecare_rand(matrice))
			"jumatate":
				matrice = _intoarce_ordinea(_intoarce_fiecare_rand(matrice))
			_:
				return "miscare necunoscuta: „%s”" % miscare

	var ajunge := _unde_e_adevarat(matrice)
	if ajunge == Vector2i.ZERO:
		return "punctul s-a pierdut din matrice"
	var asteptat := "linia %d, coloana %d" % [ajunge.x, ajunge.y]
	if asteptat != _corecta(q):
		return "din %d,%d prin [%s] se ajunge in %s, nu in „%s”" % [
			punct.x, punct.y, ", ".join(miscari), asteptat, _corecta(q),
		]
	return ""


## INTOARCERI: „Privesti spre NORD. Te intorci la STANGA, apoi la DREAPTA."
## Refăcut din tabelul de douăsprezece rânduri, nu cu `posmod`.
func _bate_intoarcerile(q: Dictionary) -> String:
	var text := String(q["text"])
	var de_la := text.find("Privesti spre ")
	var punct := text.find(".")
	if de_la < 0 or punct < 0:
		return "enunt necitibil: „%s”" % text
	var unde := text.substr(de_la + 14, punct - de_la - 14).strip_edges()
	if not DEPLASARE.has(unde):
		return "direcție de pornire necunoscuta: „%s”" % unde

	var start_intoarceri := text.find("Te intorci ")
	var sfarsit := text.find(". Incotro")
	if start_intoarceri < 0 or sfarsit < 0:
		return "nu gasesc intoarcerile: „%s”" % text
	var lista := text.substr(
		start_intoarceri + 11, sfarsit - start_intoarceri - 11
	).split(", apoi ")

	for intoarcere in lista:
		var cheie := "%s|%s" % [unde, String(intoarcere).strip_edges()]
		if not INTOARCERI.has(cheie):
			return "intoarcere necunoscuta: „%s”" % cheie
		unde = String(INTOARCERI[cheie])

	if unde != _corecta(q):
		return "ajungi spre %s, nu spre „%s”" % [unde, _corecta(q)]
	return ""


## INCOTRO E CETATEA: pașii se adună, apoi direcția se ÎNTOARCE.
##
## Două verdicte într-unul, fiindcă al doilea nu există nicăieri altundeva:
## dacă răspunsul e o diagonală, deplasarea trebuie să fie egală pe cele două
## axe. „3 est, 7 nord" nu e NORD-EST pentru nimeni, iar o întrebare cu două
## răspunsuri apărabile e greșită chiar dacă e consecventă cu sine.
func _bate_spre_casa(q: Dictionary) -> String:
	var text := String(q["text"])
	var de_la := text.find("cetate: ")
	var sfarsit := text.find(". Incotro")
	if de_la < 0 or sfarsit < 0:
		return "enunt necitibil: „%s”" % text
	var pasii := text.substr(de_la + 8, sfarsit - de_la - 8).split(", ")

	var total := Vector2i.ZERO
	for pas in pasii:
		var bucati := String(pas).strip_edges().split(" ")
		if bucati.size() < 2:
			return "pas necitibil: „%s”" % pas
		var cat := int(bucati[0])
		var nume := String(bucati[bucati.size() - 1])
		if not DEPLASARE.has(nume):
			return "direcție necunoscuta: „%s”" % nume
		total += Vector2i(DEPLASARE[nume]) * cat

	if total == Vector2i.ZERO:
		return "drumul se intoarce de unde a plecat, deci cetatea nu e nicaieri"

	var cheie := "%d,%d" % [signi(total.x), signi(total.y)]
	if not BRAT.has(cheie):
		return "deplasare fara brat: %s" % cheie
	var spre_casa := String(OPUS[String(BRAT[cheie])])
	if spre_casa != _corecta(q):
		return "te-ai depărtat spre %s, deci cetatea e spre %s, nu spre „%s”" % [
			BRAT[cheie], spre_casa, _corecta(q),
		]

	if total.x != 0 and total.y != 0 and absi(total.x) != absi(total.y):
		return "diagonala strambă: %d pe est, %d pe nord" % [total.x, total.y]
	return ""


## DRUMUL INTORS: ordinea inversă ȘI direcțiile opuse. Se recompune textul
## așteptat și se compară cu butonul marcat corect.
func _bate_drumul_intors(q: Dictionary) -> String:
	var text := String(q["text"])
	var de_la := text.find("Ai mers ")
	var sfarsit := text.find(". Cum te intorci")
	if de_la < 0 or sfarsit < 0:
		return "enunt necitibil: „%s”" % text
	var pasii := text.substr(de_la + 8, sfarsit - de_la - 8).split(", apoi ")
	if pasii.size() != 2:
		return "%d pasi, asteptam 2" % pasii.size()

	var cati: Array[int] = []
	var directii: Array[String] = []
	for pas in pasii:
		var bucati := String(pas).strip_edges().split(" ")
		if bucati.size() < 2:
			return "pas necitibil: „%s”" % pas
		cati.append(int(bucati[0]))
		var nume := String(bucati[bucati.size() - 1])
		if not OPUS.has(nume):
			return "direcție necunoscuta: „%s”" % nume
		directii.append(nume)

	var asteptat := "%d spre %s, apoi %d spre %s" % [
		cati[1], OPUS[directii[1]], cati[0], OPUS[directii[0]],
	]
	if asteptat != _corecta(q):
		return "drumul intors e „%s”, nu „%s”" % [asteptat, _corecta(q)]
	return ""


## FETE OPUSE: perechea marcată corect trebuie să fie una din cele aflate prin
## PLIEREA desfășuratei, iar niciuna din cele trei greșite nu are voie să fie.
##
## A doua jumătate contează la fel de mult: o întrebare cu două perechi opuse
## printre variante are două răspunsuri bune, iar asta nu se vede nicăieri în
## joc — butonul greșit se colorează roșu exact la fel.
func _bate_perechea(q: Dictionary) -> String:
	var pliat := _plierea(q)
	if String(pliat["problema"]) != "":
		return String(pliat["problema"])
	var perechi: Dictionary = pliat["perechi"]

	if not perechi.has(_corecta(q)):
		return "„%s” nu sunt opuse pe cubul pliat (opuse: %s)" % [
			_corecta(q), ", ".join(perechi.keys()),
		]
	for varianta in q["variante"]:
		var text := String(varianta)
		if text != _corecta(q) and perechi.has(text):
			return "„%s” e tot o pereche opusa, deci intrebarea are doua raspunsuri" % text
	return ""


## CUBUL PLIAT: fața opusă celei întrebate, aflată prin pliere.
func _bate_opusa(q: Dictionary) -> String:
	var text := String(q["text"])
	var de_la := text.find("fetei ")
	if de_la < 0:
		return "nu gasesc fata intrebata: „%s”" % text
	var intrebata := text.substr(de_la + 6).strip_edges().trim_suffix("?")

	var pliat := _plierea(q)
	if String(pliat["problema"]) != "":
		return String(pliat["problema"])
	var opuse: Dictionary = pliat["opuse"]

	if not opuse.has(intrebata):
		return "fata „%s” nu e pe desfasurata" % intrebata
	if String(opuse[intrebata]) != _corecta(q):
		return "opusa lui %s e %s, nu „%s”" % [
			intrebata, opuse[intrebata], _corecta(q),
		]
	return ""


# ─────────────────────────────────────────────────────────────
# PLIEREA, FĂCUTĂ CU ADEVĂRAT
#
# Jocul nu pliază nimic: el AȘEAZĂ literele știind deja regula („banda de patru
# se închide, deci prima e opusă celei de-a treia"). Verificarea nu are voie să
# folosească regula aia — ar fi aceeași afirmație verificată cu ea însăși.
#
# Deci aici desfășurata se pliază de-adevăratelea. Fiecărei fețe i se dă o
# NORMALĂ, adică direcția în care privește ea pe cubul închis, iar normalele se
# află mergând din celulă în celulă pe desfășurată și rotind un sistem de trei
# axe:
#
#   n — încotro privește fața de acum
#   r — ce direcție din spațiu înseamnă „o coloană la dreapta" pe planșă
#   d — ce direcție din spațiu înseamnă „o linie mai jos" pe planșă
#
# Un pas la dreapta pe planșă înseamnă că te-ai rostogolit peste muchia din
# dreapta: fața nouă privește încotro privea `r`, iar `r` nou privește de unde
# veneai (`-n`). `d` nu se schimbă, fiindcă rostogolirea s-a făcut în jurul axei
# lui. Celelalte trei direcții sunt aceeași mișcare cu semnele schimbate.
#
# La final, două fețe sunt opuse exact când normalele lor sunt una minus
# cealaltă. Nimic din asta nu știe ce e o „bandă".
#
# ȘI VERIFICĂ DESFĂȘURATA, nu doar perechile: dacă cele șase celule n-ar forma
# o desfășurată validă (două fețe căzând pe aceeași normală, adică suprapuse pe
# cub), plierea ar da mai puțin de șase normale distincte și s-ar opri aici.
# ─────────────────────────────────────────────────────────────

func _plierea(q: Dictionary) -> Dictionary:
	var gol := {"problema": "", "opuse": {}, "perechi": {}}

	# Literele, pe locul lor în caroiaj.
	var la_celula := {}
	for celula in _celule(q):
		var cheie := "%d,%d" % [int(celula.get("linie", 0)), int(celula.get("coloana", 0))]
		la_celula[cheie] = String(celula.get("text", ""))
	if la_celula.size() != 6:
		gol["problema"] = "desfasurata are %d fete, nu 6" % la_celula.size()
		return gol

	# Plierea: un mers în lățime prin celulele lipite, cu sistemul de axe purtat
	# după el.
	var pasi := {
		"0,1": "dreapta", "0,-1": "stanga", "1,0": "jos", "-1,0": "sus",
	}
	var prima: String = la_celula.keys()[0]
	var cadre := {
		prima: {
			"n": Vector3i(0, 0, 1), "r": Vector3i(1, 0, 0), "d": Vector3i(0, 1, 0),
		},
	}
	var coada: Array[String] = [prima]
	while not coada.is_empty():
		var cheie: String = coada.pop_front()
		var bucati := cheie.split(",")
		var linie := int(bucati[0])
		var coloana := int(bucati[1])
		var cadru: Dictionary = cadre[cheie]

		for deplasare in pasi:
			var d_bucati := String(deplasare).split(",")
			var vecin := "%d,%d" % [linie + int(d_bucati[0]), coloana + int(d_bucati[1])]
			if not la_celula.has(vecin) or cadre.has(vecin):
				continue
			var n: Vector3i = cadru["n"]
			var r: Vector3i = cadru["r"]
			var dj: Vector3i = cadru["d"]
			match String(pasi[deplasare]):
				"dreapta":
					cadre[vecin] = {"n": r, "r": -n, "d": dj}
				"stanga":
					cadre[vecin] = {"n": -r, "r": n, "d": dj}
				"jos":
					cadre[vecin] = {"n": dj, "r": r, "d": -n}
				"sus":
					cadre[vecin] = {"n": -dj, "r": r, "d": n}
			coada.append(vecin)

	if cadre.size() != 6:
		gol["problema"] = "desfasurata nu e dintr-o bucata: %d fete lipite din 6" % cadre.size()
		return gol

	# Normalele, pe litere. Șase fețe pe un cub = șase direcții distincte.
	var normale := {}
	for cheie in cadre:
		var litera: String = la_celula[cheie]
		var n: Vector3i = cadre[cheie]["n"]
		var scrisa := "%d,%d,%d" % [n.x, n.y, n.z]
		if normale.values().has(scrisa):
			gol["problema"] = "doua fete cad pe aceeasi fata a cubului (%s)" % scrisa
			return gol
		normale[litera] = scrisa

	# Opusele: normalele una minus cealaltă.
	var opuse := {}
	var perechi := {}
	for a in normale:
		var n_bucati := String(normale[a]).split(",")
		var intoarsa := "%d,%d,%d" % [-int(n_bucati[0]), -int(n_bucati[1]), -int(n_bucati[2])]
		for b in normale:
			if String(normale[b]) == intoarsa:
				opuse[a] = b
				perechi[_perechea(String(a), String(b))] = true
	if opuse.size() != 6 or perechi.size() != 3:
		gol["problema"] = "plierea a dat %d opuse si %d perechi" % [opuse.size(), perechi.size()]
		return gol

	return {"problema": "", "opuse": opuse, "perechi": perechi}


## Perechea, scrisă ca pe buton. Alfabetic, ca să se poată compara.
func _perechea(a: String, b: String) -> String:
	return "%s si %s" % [a, b] if a < b else "%s si %s" % [b, a]


# ─────────────────────────────────────────────────────────────
# 4. PLANȘELE
#
# Secțiunea care nu există la nicio altă disciplină, fiindcă nicio alta nu
# desenează. Toate verdictele de aici bat lucruri care NU AR CRĂPA JOCUL și ar
# face întrebarea nedreaptă — adică exact genul de greșeală pe care n-o vezi
# până nu pierzi o luptă din cauza ei.
#
# Primul verdict e și cel care apără contractul din `puzzle.gd`: BUSOLA nu
# trebuie să deseneze NIMIC, iar celelalte trei tipuri trebuie să deseneze
# mereu. Dacă n-ar fi bătut, „cârligul e opțional" ar fi o intenție scrisă în
# comentarii, pe care primul tipar nou ar putea s-o strice fără să se vadă.
# ─────────────────────────────────────────────────────────────

func _plansele() -> bool:
	print("  PLANSELE")
	var rezultat := true

	var cu_plansa_degeaba: Array[String] = []
	var fara_plansa: Array[String] = []
	var margini: Array[String] = []
	var prea_mari: Array[String] = []
	var caroiaje: Array[String] = []
	var rotatii: Array[String] = []
	var plieri: Array[String] = []

	for generator in SPATIAL.GENERATOARE:
		var metoda := String(generator["metoda"])
		var tip := String(generator["tip"])
		for nivel in generator["niveluri"]:
			for i in range(60):
				var q: Dictionary = scena.call(metoda, int(nivel))
				if q.is_empty():
					continue
				var unde := "%s/%d" % [metoda, int(nivel)]
				var are := not _plansa(q).is_empty()

				if tip == "BUSOLA":
					if are:
						cu_plansa_degeaba.append(unde)
					continue
				if not are:
					fara_plansa.append(unde)
					continue

				var problema := _problema_de_margini(q)
				if problema != "":
					margini.append("%s: %s" % [unde, problema])
				if _plansa(q).get("linii", 0) > MAX_LATURA_PLANSA \
						or _plansa(q).get("coloane", 0) > MAX_LATURA_PLANSA:
					prea_mari.append("%s: %dx%d" % [
						unde, _plansa(q)["linii"], _plansa(q)["coloane"],
					])

				match tip:
					"GRILA":
						var p := _problema_de_caroiaj(q)
						if p != "":
							caroiaje.append("%s: %s" % [unde, p])
					"ROTATIA":
						var p := _problema_de_figura(q)
						if p != "":
							rotatii.append("%s: %s" % [unde, p])
					"PLIEREA":
						var p := _problema_de_desfasurata(q)
						if p != "":
							plieri.append("%s: %s" % [unde, p])

	rezultat = _verdict(
		"BUSOLA nu deseneaza nimic",
		cu_plansa_degeaba.is_empty(), _primele(cu_plansa_degeaba, 5)
	) and rezultat
	rezultat = _verdict(
		"celelalte trei tipuri deseneaza mereu",
		fara_plansa.is_empty(), _primele(fara_plansa, 5)
	) and rezultat
	rezultat = _verdict(
		"nicio celula in afara marginilor, niciuna dubla",
		margini.is_empty(), _primele(margini, 5)
	) and rezultat
	rezultat = _verdict(
		"nicio plansa peste %dx%d (incape in panou)" % [MAX_LATURA_PLANSA, MAX_LATURA_PLANSA],
		prea_mari.is_empty(), _primele(prea_mari, 5)
	) and rezultat
	rezultat = _verdict(
		"caroiajul: toate celulele au litere, toate distincte",
		caroiaje.is_empty(), _primele(caroiaje, 5)
	) and rezultat
	rezultat = _verdict(
		"figura: un singur punct, pe o celula plina",
		rotatii.is_empty(), _primele(rotatii, 5)
	) and rezultat
	rezultat = _verdict(
		"desfasurata: 6 fete cu litere distincte",
		plieri.is_empty(), _primele(plieri, 5)
	) and rezultat

	return rezultat


## Celule în afara caroiajului declarat, sau două celule pe același loc. A doua
## n-ar crăpa desenarea — s-ar desena una peste alta, iar litera de dedesubt
## ar dispărea în tăcere.
func _problema_de_margini(q: Dictionary) -> String:
	var plansa := _plansa(q)
	var linii := int(plansa.get("linii", 0))
	var coloane := int(plansa.get("coloane", 0))
	if linii < 1 or coloane < 1:
		return "caroiaj %dx%d" % [linii, coloane]

	var vazute := {}
	for celula in _celule(q):
		var l := int(celula.get("linie", 0))
		var c := int(celula.get("coloana", 0))
		if l < 1 or l > linii or c < 1 or c > coloane:
			return "celula %d,%d in afara lui %dx%d" % [l, c, linii, coloane]
		var cheie := "%d,%d" % [l, c]
		if vazute.has(cheie):
			return "doua celule pe %s" % cheie
		vazute[cheie] = true
	return ""


## Caroiajul tipului GRILA: pătrat, plin, cu litere distincte. Două litere
## identice fac „ce e la dreapta lui M" o întrebare fără răspuns unic — iar
## greșeala n-ar fi a jucătorului.
func _problema_de_caroiaj(q: Dictionary) -> String:
	var plansa := _plansa(q)
	var n := int(plansa.get("coloane", 0))
	if int(plansa.get("linii", 0)) != n:
		return "caroiaj nepatrat"
	var celule := _celule(q)
	if celule.size() != n * n:
		return "%d celule pe un caroiaj %dx%d" % [celule.size(), n, n]
	var litere := {}
	for celula in celule:
		var text := String(celula.get("text", ""))
		if text == "":
			return "celula %d,%d fara litera" % [
				int(celula.get("linie", 0)), int(celula.get("coloana", 0)),
			]
		if litere.has(text):
			return "litera „%s” de doua ori" % text
		litere[text] = true
	return ""


## Figura tipului ROTATIA: caroiaj pătrat și plin, exact un punct, iar punctul
## pe o celulă plină (el e un colț al figurii, nu un rătăcit lângă ea).
func _problema_de_figura(q: Dictionary) -> String:
	var plansa := _plansa(q)
	var n := int(plansa.get("coloane", 0))
	if int(plansa.get("linii", 0)) != n:
		return "caroiaj nepatrat"
	var celule := _celule(q)
	if celule.size() != n * n:
		return "%d celule pe un caroiaj %dx%d" % [celule.size(), n, n]

	var marcate := 0
	var pline := 0
	var punctul_e_plin := false
	for celula in celule:
		if bool(celula.get("plin", false)):
			pline += 1
		if bool(celula.get("marcat", false)):
			marcate += 1
			punctul_e_plin = bool(celula.get("plin", false))
	if marcate != 1:
		return "%d puncte" % marcate
	if not punctul_e_plin:
		return "punctul nu e pe o celula plina"
	if pline < 3:
		return "figura are %d celule pline" % pline
	return ""


## Desfășurata tipului PLIEREA: exact șase fețe, fiecare cu o literă, toate
## distincte. Plierea însăși o verifică `_plierea()`, în rezolvare.
func _problema_de_desfasurata(q: Dictionary) -> String:
	var celule := _celule(q)
	if celule.size() != 6:
		return "%d fete" % celule.size()
	var litere := {}
	for celula in celule:
		var text := String(celula.get("text", ""))
		if text == "":
			return "o fata fara litera"
		if litere.has(text):
			return "litera „%s” de doua ori" % text
		litere[text] = true
	return ""


# ─────────────────────────────────────────────────────────────
# 5. FONTURILE AU CARACTERELE
#
# Aceeași verificare ca la Numere și Tipare, și aici cu un motiv în plus:
# literele de pe PLANȘĂ se desenează cu `draw_string`, nu printr-un `Label`,
# deci o literă lipsă din font s-ar desena ca un dreptunghi gol în mijlocul
# caroiajului. Se cer în Cinzel și Alegreya (tema de pergament) ȘI în fontul
# implicit (lupta).
#
# Se strâng și caracterele din celulele planșei, nu doar din enunț, variante și
# notă — altfel verificarea s-ar uita exact lângă locul nou.
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
	for generator in SPATIAL.GENERATOARE:
		for nivel in generator["niveluri"]:
			for i in range(20):
				var q: Dictionary = scena.call(String(generator["metoda"]), int(nivel))
				if q.is_empty():
					continue
				var tot := "%s %s %s" % [
					q["text"], " ".join(q["variante"]), q["explicatie"],
				]
				for celula in _celule(q):
					tot += String(celula.get("text", ""))
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
# 6. ECHILIBRUL PE TIPURI
#
# Alegerea e în două trepte (întâi tipul, apoi tiparul) tocmai ca ROTATIA, cu
# patru tipare, să nu apară de două ori mai des decât PLIEREA, cu două. E o
# probabilitate, nu o listă: se vede la mii de trageri.
# ─────────────────────────────────────────────────────────────

func _echilibrul() -> bool:
	print("  ECHILIBRUL (%d trageri pe nivel)" % TRAGERI_ECHILIBRU)
	var rezultat := true

	var tip_pe_antet := {}
	for generator in SPATIAL.GENERATOARE:
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
# 7. FĂRĂ REPETIȚII PE EXPEDIȚIE
#
# Aici cifra înseamnă mai mult decât la celelalte discipline: Spațialul e prima
# disciplină care își SUPRASCRIE `_identitate_intrebare` (ca să cuprindă și
# planșa), iar motivul e scris acolo — pe o planșă 4×4, două puncte diferite pot
# da aceleași patru variante și același enunț. Dacă suprascrierea ar fi ștearsă
# vreodată, repetările ar sări aici și nicăieri altundeva.
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
# Disciplina asta are cele mai lungi enunțuri din joc: rândul care declară cum
# se numără liniile, plus descrierea mișcării. La inamicul cu cronometru ai 12
# secunde pentru TOT, cititul inclus — iar `_rotatie_dubla` cere, pe lângă
# citit, și o figură rotită de două ori. Dacă ceva din disciplina asta e
# nejucabil, aici se vede, nu într-un verdict.
#
# Planșa se tipărește și ea, ca text: ea e jumătate din întrebare, iar o mostră
# fără figură nu se poate citi.
# ─────────────────────────────────────────────────────────────

func _cat_se_citeste() -> void:
	print("\n  CAT SE CITESTE (cea mai lunga intrebare, pe tipar)")
	for generator in SPATIAL.GENERATOARE:
		var metoda := String(generator["metoda"])
		var lung := String(cel_mai_lung.get(metoda, ""))
		print("    %-24s %3d semne   %s" % [
			metoda, lung.length(), lung.replace("\n", " / "),
		])

	print("\n  O MOSTRA DIN FIECARE TIPAR")
	for generator in SPATIAL.GENERATOARE:
		var metoda := String(generator["metoda"])
		var q: Dictionary = o_mostra.get(metoda, {})
		if q.is_empty():
			continue
		print("\n    [%s]  %s" % [
			generator["categorie"], String(q["text"]).replace("\n", " / "),
		])
		for rand in _plansa_ca_text(q):
			print("       %s" % rand)
		var variante: Array = q["variante"]
		for i in range(variante.size()):
			print("       %s %s" % ["→" if i == int(q["corect"]) else " ", variante[i]])
		print("       nota: %s" % q["explicatie"])


## Planșa desenată cu caractere, ca s-o pot citi în terminal. NU e cum arată în
## joc (acolo sunt chenare și un disc) — e doar destul ca să văd figura: litera
## celulei, „#" pentru plin, „o" pentru punct, „." pentru celulă goală, spațiu
## pentru celulă care nu există.
func _plansa_ca_text(q: Dictionary) -> Array[String]:
	var plansa := _plansa(q)
	if plansa.is_empty():
		return []
	var pe_loc := {}
	for celula in _celule(q):
		var semn := String(celula.get("text", ""))
		if bool(celula.get("marcat", false)):
			semn = "o"
		elif semn == "":
			semn = "#" if bool(celula.get("plin", false)) else "."
		pe_loc["%d,%d" % [int(celula.get("linie", 0)), int(celula.get("coloana", 0))]] = semn

	var randuri: Array[String] = []
	for linie in range(1, int(plansa["linii"]) + 1):
		var bucati: Array[String] = []
		for coloana in range(1, int(plansa["coloane"]) + 1):
			bucati.append(String(pe_loc.get("%d,%d" % [linie, coloana], " ")))
		randuri.append(" ".join(bucati))
	return randuri


# ─────────────────────────────────────────────────────────────
# UNELTELE DE CITIT PLANȘA ȘI DE ROTIT MATRICEA
# ─────────────────────────────────────────────────────────────

func _plansa(q: Dictionary) -> Dictionary:
	return q.get("plansa", {})


func _celule(q: Dictionary) -> Array:
	return _plansa(q).get("celule", [])


## Latura caroiajului. Zero dacă întrebarea n-are planșă.
func _latura(q: Dictionary) -> int:
	return int(_plansa(q).get("coloane", 0))


## Unde stă o literă pe planșă. `Vector2i.ZERO` dacă nu e acolo — celulele se
## numără de la 1, deci zero nu poate fi o celulă adevărată.
func _unde_e_litera(q: Dictionary, litera: String) -> Vector2i:
	for celula in _celule(q):
		if String(celula.get("text", "")) == litera:
			return Vector2i(int(celula.get("linie", 0)), int(celula.get("coloana", 0)))
	return Vector2i.ZERO


## Ce literă e în celula dată. Șir gol dacă celula nu există.
func _litera_la(q: Dictionary, celula: Vector2i) -> String:
	for c in _celule(q):
		if int(c.get("linie", 0)) == celula.x and int(c.get("coloana", 0)) == celula.y:
			return String(c.get("text", ""))
	return ""


## Celula cu punctul.
func _punctul(q: Dictionary) -> Vector2i:
	for celula in _celule(q):
		if bool(celula.get("marcat", false)):
			return Vector2i(int(celula.get("linie", 0)), int(celula.get("coloana", 0)))
	return Vector2i.ZERO


## Textul butonului marcat corect.
func _corecta(q: Dictionary) -> String:
	return String(q["variante"][int(q["corect"])])


## Mișcările din enunț, în ordinea în care sunt scrise. Ordinea e chiar ce
## verifică `_rotatie_dubla`, deci se ia din POZIȚIA în text, nu din tabel.
func _miscarile_din(text: String) -> Array:
	var gasite: Array = []
	for nume in MISCARI:
		var unde := text.find(String(nume))
		if unde >= 0:
			gasite.append({"unde": unde, "ce": String(MISCARI[nume])})
	gasite.sort_custom(func(a, b): return int(a["unde"]) < int(b["unde"]))
	var lista: Array = []
	for g in gasite:
		lista.append(String(g["ce"]))
	return lista


## Matricea planșei: `true` doar în celula punctului.
func _matricea(n: int, punct: Vector2i) -> Array:
	var m: Array = []
	for linie in range(n):
		var rand: Array = []
		for coloana in range(n):
			rand.append(Vector2i(linie + 1, coloana + 1) == punct)
		m.append(rand)
	return m


## Transpunerea: liniile devin coloane. Jumătate din orice rotație.
func _transpune(m: Array) -> Array:
	var n := m.size()
	var nou: Array = []
	for linie in range(n):
		var rand: Array = []
		for coloana in range(n):
			rand.append(m[coloana][linie])
		nou.append(rand)
	return nou


## Fiecare rând, întors. ASTA e oglindirea stânga-dreapta, și e un
## `Array.reverse()`, nu o scădere de indici.
func _intoarce_fiecare_rand(m: Array) -> Array:
	var nou: Array = []
	for rand in m:
		var copie: Array = (rand as Array).duplicate()
		copie.reverse()
		nou.append(copie)
	return nou


## Ordinea rândurilor, întoarsă. Oglindirea sus-jos.
func _intoarce_ordinea(m: Array) -> Array:
	var nou: Array = m.duplicate()
	nou.reverse()
	return nou


## În ce celulă a ajuns punctul.
func _unde_e_adevarat(m: Array) -> Vector2i:
	for linie in range(m.size()):
		var rand: Array = m[linie]
		for coloana in range(rand.size()):
			if bool(rand[coloana]):
				return Vector2i(linie + 1, coloana + 1)
	return Vector2i.ZERO


# ─────────────────────────────────────────────────────────────
# TIPĂRIREA
# ─────────────────────────────────────────────────────────────

## Ține minte cea mai lungă întrebare și una la întâmplare, pe tipar. Culesul se
## face în bucla care verifică oricum: mii de întrebări trase a doua oară doar
## ca să le măsor lungimea ar fi fost timp irosit la fiecare rulare.
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

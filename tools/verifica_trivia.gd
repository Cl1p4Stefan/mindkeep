extends Node
## VERIFICAREA CULTURII GENERALE — întrebările, faptele și legătura dintre ele.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verifica_trivia.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE O UNEALTĂ, ȘI NU O PARTIDĂ
##
## Conținutul Culturii generale nu se poate proba jucând. Ca să vezi în luptă că
## `mana:0088` are notă, trebuie să pici pe ea: una din câteva zeci, pe un nivel,
## cu Obeliscul potrivit. Ca să vezi că sacul nu repetă, ar trebui să le tragi pe
## toate și să ții minte care au ieșit. Cu 135 de întrebări ar fi obositor; cu 274
## (de când există conținut fabricat) nu se mai poate; cu mii, e de neînchipuit.
##
## Iar de azi se verifică și lucruri care nu sunt „conținut": ECHILIBRUL pe domenii
## la alegerea din luptă e o probabilitate, nu o listă. O probabilitate strâmbă nu
## se vede la o partidă, se vede la o mie.
##
## Aici totul se citește dintr-un foc, fără fereastră și fără cronometru.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   TOATE ÎNTREBĂRILE AU TRECUT. Încărcătorul SARE peste intrările stricate, cu
##   un avertisment — iar `push_warning` nu oprește nimic și se pierde ușor într-o
##   consolă plină. „135 încărcate din 135 găsite" e singurul loc unde o întrebare
##   pierdută se vede ca un număr. E prima verificare fiindcă, dacă ea cade,
##   celelalte măsoară un conținut incomplet.
##
##   ID-URI PREZENTE, UNICE ȘI DE FORMĂ BUNĂ. Unicitatea e cea care contează cu
##   adevărat: două întrebări cu același `id` sunt, pentru sac, o singură
##   întrebare, iar una din ele n-ar mai ieși niciodată. Nu s-ar vedea ca un bug,
##   s-ar vedea ca o bază mai săracă decât e.
##
##   FIECARE `fapt` DUCE LA O NOTĂ. Încărcătorul rupe legăturile greșite și se
##   plânge, deci o notă poate lipsi fără să strice nimic. Aici se numără câte
##   întrebări ajung chiar cu notă în mână: 18, pentru pilot.
##
##   NOTELE, LUNGIMEA ȘI VERIFICAREA LOR. Lungimea, fiindcă limita de 240 e un
##   avertisment, nu un refuz (`MAX_NOTA` din `trivia.gd`). Câte sunt
##   `verificat: false`, fiindcă asta e o măsură de muncă rămasă, nu o eroare:
##   toate notele pilotului pornesc neverificate, dinadins.
##
##   NICIUN FAPT NEFOLOSIT. Conținut mort. Nu strică nimic în joc și exact de-aia
##   n-ar fi găsit niciodată altfel.
##
##   ECHILIBRUL PE DOMENII, la alegerea din luptă. Datele nu mai sunt echilibrate
##   (știința are ~160 de întrebări, mitologia 21); echilibrul stă acum în
##   ALEGERE, în două trepte. Se trag câteva mii de întrebări pe fiecare nivel,
##   prin chiar funcția pe care o folosește lupta, și se cere ca fiecare domeniu
##   să iasă pe la 1/N. Verificarea asta e cea mai greu de înlocuit cu ochiul.
##
##   SACUL NU REPETĂ PE UN CICLU. E o GARANȚIE, nu o probabilitate: se trage un
##   sac întreg și se numără id-urile distincte — trebuie să iasă exact câte
##   întrebări are. Apoi încă o tragere, prima din ciclul nou, care nu trebuie
##   s-o repete pe ultima din ciclul vechi (regula de la răscruce din `sac.gd`).
##   Cheile sunt pe DOMENIU și nivel, deci se probează 18 sacuri, nu 3.
##
##   SACURILE NU SE AMESTECĂ ÎNTRE DOMENII. Cea mai țintită: se golește complet un
##   domeniu și se întreabă altul dacă își mai ține minte biletele. `Sac.extrage`
##   golește registrul unei chei când lista se epuizează, deci o cheie care n-ar
##   cuprinde domeniul ar șterge memoria tuturor celorlalte. Nu s-ar fi văzut ca
##   un bug — s-ar fi văzut ca „parcă se repetă ceva, uneori".
##
## Ce NU verifică: nimic despre CE SCRIE în note. Că un an e corect sau că nota
## se înțelege singură se citește cu ochiul, după `docs/ghid-note.md` — niciun
## script nu poate face asta, și e chiar motivul pentru care `verificat` e un
## câmp pus de mână.

# Scriptul disciplinei, încărcat direct. Nu avem nevoie de scenă: tot ce se
# verifică aici stă în `static var`-uri și funcții statice, adică aparțin
# SCRIPTULUI, nu unei copii a scenei. Deci nu se deschide nicio fereastră, nu
# pornește niciun cronometru și nu se sună niciun sunet.
const TRIVIA := preload("res://scenes/trivia/trivia.gd")

# Câte întrebări ar trebui să fie în FIȘIERUL SCRIS DE MÂNĂ, și câte fapte cu
# notă. Scrise aici, nu citite din fișier, fiindcă o verificare care-și ia
# așteptările din lucrul verificat nu verifică nimic: dacă mâine dispar 10
# întrebări, „am găsit câte am găsit" ar trece liniștită.
#
# DE CE NUMAI PENTRU CELE SCRISE DE MÂNĂ. Fișierul fabricat crește de câte ori
# adaug un element în tabelul din `tools/fabrica/elemente.py`, deci o cifră scrisă
# aici ar fi o a doua editare, într-un alt fișier, la fiecare schimbare de
# conținut — adică exact felul de verificare pe care începi s-o actualizezi
# mecanic, fără s-o mai citești. Pentru cele fabricate se verifică INVARIANTA:
# câte s-au încărcat = câte s-au găsit. Aia nu se schimbă niciodată, oricât crește
# fișierul, și e chiar ce vrei să afli (o întrebare stricată e sărită în tăcere).
const CATE_INTREBARI_MANA := 135
const CATE_FAPTE := 15
const CATE_CU_NOTA := 18

# Câte trageri se fac ca să se măsoare echilibrul pe domenii. Destule ca abaterea
# întâmplătoare să scadă sub ce ne interesează: la 6000 de trageri și 6 domenii,
# fiecare ar trebui să iasă pe la 1000, iar împrăștierea normală e de vreo ±30.
# Toleranța de mai jos e cu mult peste ea, deci verificarea pică doar dacă
# alegerea e într-adevăr strâmbă, nu dacă zarul a avut o zi.
const TRAGERI_ECHILIBRU := 6000
const TOLERANTA_ECHILIBRU := 0.20


func _ready() -> void:
	print("\n══ VERIFICAREA CULTURII GENERALE ══\n")

	TRIVIA.incarca_intrebari()
	var intrebari: Array = TRIVIA.intrebari
	var fapte: Dictionary = TRIVIA.fapte
	print("")

	var tot_bun := true
	tot_bun = _incarcarea(intrebari, fapte) and tot_bun
	tot_bun = _identitatile(intrebari) and tot_bun
	tot_bun = _textele(intrebari) and tot_bun
	tot_bun = _raspunsurile(intrebari) and tot_bun
	tot_bun = _notele(intrebari, fapte) and tot_bun
	tot_bun = _echilibrul(intrebari) and tot_bun
	tot_bun = _sacul(intrebari) and tot_bun
	tot_bun = _sacurile_nu_se_amesteca(intrebari) and tot_bun

	print("\n══ %s ══\n" % ("TOTUL E BUN" if tot_bun else "SUNT PROBLEME, vezi mai sus"))
	# Codul de ieșire, ca verificarea să poată fi pusă într-un script care
	# oprește totul la primul eșec.
	get_tree().quit(0 if tot_bun else 1)


# ─────────────────────────────────────────────────────────────
# 1. A TRECUT TOT CONȚINUTUL?
# ─────────────────────────────────────────────────────────────

func _incarcarea(intrebari: Array, fapte: Dictionary) -> bool:
	print("  ÎNCĂRCAREA")
	var tot_bun := true

	# Fișierele, citite A DOUA OARĂ, direct de pe disc. Pare risipă, dar e chiar
	# ce face verificarea posibilă: `intrebari` de mai sus e ce a TRECUT, iar
	# singurul lucru care ne interesează aici e dacă s-a pierdut ceva pe drum.
	# Fără numărul brut n-am cu ce compara.
	var brute_mana := Puzzle.citeste_lista_json(TRIVIA.CALE_INTREBARI, "Verificare")
	var brute_wd: Array = []
	var fisiere_gen: Array[String] = []
	if TRIVIA.FOLOSESTE_WIKIDATA:
		# DOSARUL, nu un fișier: de când fabrica are mai multe tabele, verificarea
		# trebuie să citească exact ce citește și jocul — altfel un tabel nou intră
		# în joc fără ca nimic să-l fi numărat vreodată.
		fisiere_gen = TRIVIA.fisierele_generate("_intrebari.json")
		for cale in fisiere_gen:
			brute_wd.append_array(Puzzle.citeste_lista_json(cale, "Verificare"))

	# Fișierul scris de mână are o cifră așteptată, fiindcă nu crește decât când
	# scriu o întrebare. Cel fabricat nu are — vezi comentariul de la constante.
	tot_bun = _verdict("fișierul scris de mână", brute_mana.size() == CATE_INTREBARI_MANA,
		"%d din %d așteptate" % [brute_mana.size(), CATE_INTREBARI_MANA]) and tot_bun

	# INVARIANTA, și cea mai importantă verificare din secțiune: încărcătorul SARE
	# peste intrările stricate, cu un `push_warning` care nu oprește nimic și se
	# pierde ușor într-o consolă plină. „274 încărcate din 274 găsite" e singurul
	# loc unde o întrebare pierdută se vede ca un număr.
	var gasite := brute_mana.size() + brute_wd.size()
	tot_bun = _verdict("toate întrebările au trecut", intrebari.size() == gasite,
		"%d încărcate din %d găsite" % [intrebari.size(), gasite]) and tot_bun

	# DOSARUL NU E GOL. Într-un build exportat, fișierele care nu sunt resurse
	# Godot ajung în pachet doar dacă presetul le prinde în filtru; altfel
	# `DirAccess` vede un dosar gol și jocul pornește cu jumătate din conținut,
	# fără niciun semn. E o verificare care azi trece banal și care, într-o zi,
	# va fi singurul lucru care spune de ce lipsesc 300 de întrebări.
	if TRIVIA.FOLOSESTE_WIKIDATA:
		tot_bun = _verdict("dosarul fabricat are fișiere", not fisiere_gen.is_empty(),
			"%d fișiere în %s" % [fisiere_gen.size(), TRIVIA.DOSAR_GEN]) and tot_bun
		for cale in fisiere_gen:
			print("    %-42s %d" % ["  " + cale.get_file(),
				Puzzle.citeste_lista_json(cale, "Verificare").size()])
	print("    %-42s %d de mână + %d fabricate" % [
		"din ce fișiere", brute_mana.size(), brute_wd.size()])

	tot_bun = _verdict("fapte încărcate (ambele fișiere)", fapte.size() >= CATE_FAPTE,
		"%d, dintre care cel puțin %d scrise de mână" % [fapte.size(), CATE_FAPTE]) and tot_bun

	# Echilibrul pe niveluri. Nu e o regulă de cod, e o regulă de conținut
	# (`trivia.gd`, antet): un nivel mai sărac decât celelalte se golește mai
	# repede, deci repetă mai des — iar asta nu se simte ca „mai puțin conținut",
	# se simte ca „nivelul 3 se repetă".
	var pe_nivel := {}
	for q in intrebari:
		var nivel := int(q["nivel"])
		pe_nivel[nivel] = int(pe_nivel.get(nivel, 0)) + 1
	var niveluri: Array = pe_nivel.keys()
	niveluri.sort()
	var bucati: Array[String] = []
	for nivel in niveluri:
		bucati.append("%d: %d" % [nivel, pe_nivel[nivel]])
	print("    %-42s %s" % ["pe niveluri", ", ".join(bucati)])

	# Și pe domenii, ca să se VADĂ dezechilibrul din date — cel pe care alegerea
	# în două trepte îl face să nu mai conteze. Nu e un verdict: un domeniu de
	# patru ori mai mare decât altul nu mai e o greșeală, de când echilibrul stă
	# în alegere. Dar e o cifră pe care vreau s-o am sub ochi.
	for nivel in range(1, 4):
		var pe_domenii := {}
		for q in intrebari:
			if int(q["nivel"]) != nivel:
				continue
			var d := String(q["categorie"])
			pe_domenii[d] = int(pe_domenii.get(d, 0)) + 1
		var domenii: Array = pe_domenii.keys()
		domenii.sort()
		var b: Array[String] = []
		for d in domenii:
			b.append("%s %d" % [d, pe_domenii[d]])
		print("    %-42s %s" % ["  nivelul %d, pe domenii" % nivel, ", ".join(b)])

	return tot_bun


# ─────────────────────────────────────────────────────────────
# 2. ID-URILE
# ─────────────────────────────────────────────────────────────

func _identitatile(intrebari: Array) -> bool:
	print("\n  ID-URILE")
	var vazute := {}
	var goale := 0
	var duplicate: Array[String] = []
	var forme_ciudate: Array[String] = []

	for q in intrebari:
		var id_intrebare := String(q.get("id", ""))
		if id_intrebare == "":
			goale += 1
			continue
		if vazute.has(id_intrebare):
			duplicate.append(id_intrebare)
		vazute[id_intrebare] = true

		if not _forma_buna(id_intrebare):
			forme_ciudate.append(id_intrebare)

	var tot_bun := true
	tot_bun = _verdict("toate au id", goale == 0,
		"" if goale == 0 else "%d fără id" % goale) and tot_bun
	tot_bun = _verdict("id-uri unice", duplicate.is_empty(),
		"%d distincte" % vazute.size() if duplicate.is_empty()
		else "duplicate: %s" % _primele(duplicate, 5)) and tot_bun
	tot_bun = _verdict("forma id-ului, pe prefix", forme_ciudate.is_empty(),
		"" if forme_ciudate.is_empty() else _primele(forme_ciudate, 5)) and tot_bun

	# Câte din fiecare fabrică. Nu e un verdict, e o cifră de citit: dacă mâine
	# `FOLOSESTE_WIKIDATA` e stins fără să-mi amintesc, se vede aici imediat.
	var pe_prefix := {}
	for id_intrebare in vazute:
		# Tipul scris pe față, nu dedus: cheile unui Dictionary vin ca Variant, iar
		# `split()` pe un Variant nu-i spune nimic lui Godot despre ce iese.
		var prefix: String = String(id_intrebare).split(":")[0]
		pe_prefix[prefix] = int(pe_prefix.get(prefix, 0)) + 1
	var prefixe: Array = pe_prefix.keys()
	prefixe.sort()
	var b: Array[String] = []
	for prefix in prefixe:
		b.append("%s: %d" % [prefix, pe_prefix[prefix]])
	print("    %-42s %s" % ["pe fabrică", ", ".join(b)])
	return tot_bun


## Are id-ul forma cuvenită pentru prefixul lui?
##
## Verificarea de dinainte cerea „prefix, două puncte, cifre" pentru ORICE id, și
## era scrisă dinadins ca să nu depindă de prefix — „un prefix nou nu trebuie să
## picheze verificarea asta". A picat-o chiar primul prefix nou:
## `wd:Q897:simbol:cere_nume` are patru bucăți și niciuna nu e un număr.
##
## Deci regula se leagă de prefix, nu se mai generalizează. E mai mult cod, dar e
## cod care spune ceva: fiecare fabrică are o formă, iar o formă greșită înseamnă
## că un generator a scăpat ceva. Un prefix necunoscut cade, dinadins — dacă apare
## o fabrică nouă, vreau să vin aici să scriu ce formă are, nu să treacă în tăcere.
func _forma_buna(id_intrebare: String) -> bool:
	var bucati := id_intrebare.split(":")
	if bucati.size() < 2 or bucati[0] == "":
		return false
	match bucati[0]:
		# `mana:0001` — prefix și un număr, dat de `tools/da_iduri.py`.
		"mana":
			return bucati.size() == 2 and bucati[1].is_valid_int()
		# `wd:Q897:simbol:cere_nume` — QID, relația, sensul. Scris de
		# `tools/fabrica/elemente.py`.
		"wd":
			if bucati.size() != 4:
				return false
			if not bucati[1].begins_with("Q") or not bucati[1].substr(1).is_valid_int():
				return false
			return bucati[2] != "" and bucati[3] != ""
		_:
			return false


# ─────────────────────────────────────────────────────────────
# 3. TEXTELE
# ─────────────────────────────────────────────────────────────

## Două întrebări nu pot avea același text.
##
## DE CE E UN VERDICT, NU O CIFRĂ. Mecanic, două întrebări cu același text nu
## strică nimic: au `id`-uri diferite, deci sacul le tratează ca pe două bilete.
## Exact asta e problema — sacul NU te apără de ele, iar în joc se văd ca o
## repetiție, adică fix lucrul pentru care există sacul.
##
## Verificarea a apărut odată cu al doilea tabel al fabricii, și are un caz
## concret în minte. Relația „operă → autor" e mulți-la-unu, deci sensul invers
## („Care dintre aceste opere a fost scrisă de X?") NU poate fi generat per
## operă: un autor cu cinci opere alese ar da cinci întrebări cu exact același
## text și cinci răspunsuri corecte diferite. `tools/fabrica/opere.py` îl
## generează per AUTOR tocmai de-aia — iar verificarea asta e plasa de dedesubt,
## pentru ziua în care cineva (eu, peste un an) „simplifică" bucla aia.
##
## Azi trece: toate textele sunt distincte, deci verdictul poate fi strict de la
## bun început. Un prag („cel mult 3 repetate") ar fi fost o poartă deschisă.
func _textele(intrebari: Array) -> bool:
	print("
  TEXTELE")
	var vazute := {}
	var repetate: Array[String] = []
	for q in intrebari:
		var text := String(q.get("text", ""))
		if text == "":
			continue
		if vazute.has(text):
			repetate.append(text)
		vazute[text] = true
	return _verdict("texte unice", repetate.is_empty(),
		"%d distincte" % vazute.size() if repetate.is_empty()
		else "%d repetate: %s" % [repetate.size(), _primele(repetate, 3)])



# ─────────────────────────────────────────────────────────────
# 4. RĂSPUNSURILE NU SE AUTODEZVĂLUIE
# ─────────────────────────────────────────────────────────────

## Niciun răspuns corect nu apare în textul întrebării lui.
##
## DE CE E O INVARIANTĂ PESTE TOT CONȚINUTUL, nu un filtru în fabrică.
## `tools/fabrica/capitale.py` are și el un filtru, dar acela compară NUMELE
## țării cu NUMELE capitalei (Kuweit → Kuweit, Mexic → Ciudad de Mexico) și apară
## doar tabelul lui. Asta se uită la textul de pe ecran, deci apară și întrebările
## scrise de mână, și orice tabel viitor.
##
## SENSIBILĂ LA MAJUSCULE, și asta e întreaga subtilitate. Măsurat pe cele 434 de
## întrebări de dinaintea capitalelor:
##
##   conținere brută, fără diacritice   43 pică
##   cuvânt întreg, fără majuscule      1 pică
##   cuvânt întreg, cu majuscule       0 pică
##
## Cele 43 sunt toate de forma „Care este simbolul chimic al carbonului? → C".
## Alea NU sunt cadouri, sunt chiar lecția: simbolul SE DEDUCE din nume, și exact
## de-aia carbonul e la nivelul I. O verificare care le-ar tăia ar cere să șterg
## cele mai bune întrebări de nivel I din joc.
##
## Singura care pica la varianta fără majuscule era `Al` din „**al** aluminiului"
## — prepoziția românească, nu simbolul. Cu majuscule, dispare: la simboluri
## majuscula E parte din simbol, nu ortografie.
##
## Azi trece curat, deci verdictul e strict de la bun început. Un prag ar fi fost
## o poartă deschisă.
func _raspunsurile(intrebari: Array) -> bool:
	print("\n  RĂSPUNSURILE")
	var autodezvaluite: Array[String] = []
	for q in intrebari:
		var text := String(q.get("text", ""))
		var variante: Array = q.get("variante", [])
		var corect := int(q.get("corect", -1))
		if corect < 0 or corect >= variante.size():
			continue
		var raspuns := String(variante[corect])
		if raspuns == "" or text == "":
			continue
		if _apare_ca_cuvant(text, raspuns):
			autodezvaluite.append("%s („%s”)" % [String(q.get("id", "?")), raspuns])
	return _verdict("niciun răspuns în textul întrebării", autodezvaluite.is_empty(),
		"%d verificate" % intrebari.size() if autodezvaluite.is_empty()
		else "%d se autodezvăluie: %s" % [autodezvaluite.size(), _primele(autodezvaluite, 3)])


## `ce` apare în `unde` ca CUVÎNT ÎNTREG, cu majuscule la fel?
##
## Pe cuvânt întreg, nu pe bucată de cuvânt: altfel „Ion" s-ar găsi în „Ion
## Creangă" și „Mali" în „Somalia". Un caracter e parte din cuvânt dacă e literă
## sau cifră — iar „literă" se află întrebând dacă se schimbă la schimbarea
## mărimii, ceea ce merge și pentru diacritice, unde o listă scrisă de mine ar fi
## uitat pe ș, ț sau â.
func _apare_ca_cuvant(unde: String, ce: String) -> bool:
	var de_la := 0
	while true:
		var la := unde.find(ce, de_la)
		if la == -1:
			return false
		var inainte := unde.substr(la - 1, 1) if la > 0 else ""
		var dupa := unde.substr(la + ce.length(), 1)
		if not _e_din_cuvant(inainte) and not _e_din_cuvant(dupa):
			return true
		de_la = la + 1
	return false


func _e_din_cuvant(c: String) -> bool:
	if c == "":
		return false
	if c.to_lower() != c.to_upper():
		return true
	return "0123456789".contains(c)


# ─────────────────────────────────────────────────────────────
# 5. NOTELE
# ─────────────────────────────────────────────────────────────

func _notele(intrebari: Array, fapte: Dictionary) -> bool:
	print("\n  NOTELE")

	# Câte întrebări ajung cu notă în mână. NU se numără câmpul `fapt`, se cere
	# nota însăși, prin același drum pe care-l face lupta: fapt → notă. O legătură
	# care duce nicăieri e chiar greșeala de prins, deci n-are ce să treacă aici.
	var cu_nota := 0
	var folosite := {}
	for q in intrebari:
		var id_fapt := String(q.get("fapt", ""))
		if id_fapt == "":
			continue
		folosite[id_fapt] = true
		if String(fapte.get(id_fapt, "")) != "":
			cu_nota += 1

	var prea_lungi: Array[String] = []
	var maxim := 0
	for id_fapt in fapte:
		var lungime := String(fapte[id_fapt]).length()
		maxim = maxi(maxim, lungime)
		if lungime > TRIVIA.MAX_NOTA:
			prea_lungi.append("%s (%d)" % [id_fapt, lungime])

	var nefolosite: Array[String] = []
	for id_fapt in fapte:
		if not folosite.has(id_fapt):
			nefolosite.append(id_fapt)

	var tot_bun := true
	tot_bun = _verdict("întrebări cu notă", cu_nota == CATE_CU_NOTA,
		"%d din %d așteptate" % [cu_nota, CATE_CU_NOTA]) and tot_bun
	tot_bun = _verdict("note sub limită", prea_lungi.is_empty(),
		"cea mai lungă: %d din %d" % [maxim, TRIVIA.MAX_NOTA] if prea_lungi.is_empty()
		else _primele(prea_lungi, 5)) and tot_bun
	tot_bun = _verdict("niciun fapt nefolosit", nefolosite.is_empty(),
		"" if nefolosite.is_empty() else _primele(nefolosite, 5)) and tot_bun
	return tot_bun


# ───────────────────────────────────────────────────────────
# 6. ECHILIBRUL LA ALEGEREA DIN LUPTĂ
#
# Verificarea care n-avea de ce să existe înainte de conținutul fabricat, și care
# e acum cea mai greu de înlocuit cu ochiul.
#
# Datele NU mai sunt echilibrate: știința are ~160 de întrebări, mitologia 21.
# Echilibrul s-a mutat în ALEGERE (`trage_intrebarea`, în două trepte). Numai că o
# alegere e o probabilitate, iar o probabilitate nu se vede jucând: ca să bagi de
# seamă cu ochiul că știința iese de patru ori mai des decât ar trebui, ar trebui
# să ții socoteala câtorva sute de lupte. Aici se trag câteva mii dintr-un foc.
#
# Se cheamă chiar `TRIVIA.trage_intrebarea`, nu o copie a ei scrisă aici. Dacă
# alegerea se rescrie vreodată și uită treapta domeniului, verificarea asta cade —
# ceea ce e chiar rostul ei. O copie ar fi trecut liniștită.
# ───────────────────────────────────────────────────────────

func _echilibrul(intrebari: Array) -> bool:
	print("\n  ECHILIBRUL PE DOMENII, la %d trageri pe nivel" % TRAGERI_ECHILIBRU)
	var tot_bun := true

	for nivel in range(1, 4):
		# Câte domenii SUNT la nivelul ăsta. Ținta nu e „1/6", e „1/N": dacă un
		# nivel n-are întrebări de mitologie, celelalte cinci trebuie să împartă
		# tot, iar verificarea n-are de ce să ceară șasea parte pentru nimic.
		var prezente := {}
		for q in intrebari:
			if int(q["nivel"]) == nivel:
				prezente[String(q["categorie"])] = true
		if prezente.is_empty():
			tot_bun = _verdict("nivelul %d" % nivel, false, "nicio întrebare") and tot_bun
			continue

		var tinta := float(TRAGERI_ECHILIBRU) / float(prezente.size())
		var numarate := {}
		for _i in range(TRAGERI_ECHILIBRU):
			var q := TRIVIA.trage_intrebarea(nivel)
			if q.is_empty():
				break
			var d := String(q["categorie"])
			numarate[d] = int(numarate.get(d, 0)) + 1

		# Cel mai depărtat domeniu de țintă. Un singur număr, fiindcă ce ne
		# interesează e cazul cel mai rău, nu media — o medie ar ascunde exact
		# domeniul care iese de patru ori prea des.
		var cea_mai_mare_abatere := 0.0
		var vinovat := ""
		var domenii: Array = prezente.keys()
		domenii.sort()
		var bucati: Array[String] = []
		for d in domenii:
			var cate := int(numarate.get(d, 0))
			var abatere: float = absf(float(cate) - tinta) / tinta
			if abatere > cea_mai_mare_abatere:
				cea_mai_mare_abatere = abatere
				vinovat = d
			bucati.append("%s %d" % [d.substr(0, 4), cate])

		print("    %-42s %s" % ["  nivelul %d (țintă %d)" % [nivel, int(tinta)],
			", ".join(bucati)])
		tot_bun = _verdict("nivelul %d, uniform pe domenii" % nivel,
			cea_mai_mare_abatere <= TOLERANTA_ECHILIBRU,
			"abaterea maximă %.1f%% (%s), limita %.0f%%" % [
				cea_mai_mare_abatere * 100.0, vinovat, TOLERANTA_ECHILIBRU * 100.0
			]) and tot_bun

		# Tragerile de mai sus au umplut sacurile. Le golim, ca secțiunile de mai
		# jos să pornească de la zero — altfel ar măsura un sac deja pe jumătate
		# consumat și ar pica pe drept, dar din vina noastră.
		Sac.expeditie_noua()

	return tot_bun


# ───────────────────────────────────────────────────────────
# 7. SACUL
# ───────────────────────────────────────────────────────────

func _sacul(intrebari: Array) -> bool:
	print("\n  SACUL (pe `id`, un ciclu întreg pe fiecare domeniu × nivel)")
	var tot_bun := true

	# Cheile sunt acum pe DOMENIU și nivel, nu doar pe nivel — deci se probează 18
	# sacuri, nu 3. Merită numărate toate: dacă o cheie se compune greșit, se vede
	# doar pe una din ele, iar aia s-ar pierde într-un raport care măsoară media.
	var chei_picate: Array[String] = []
	var chei_bune := 0
	var rascruci_picate: Array[String] = []

	for nivel in range(1, 4):
		var domenii := {}
		for q in intrebari:
			if int(q["nivel"]) == nivel:
				if not domenii.has(String(q["categorie"])):
					domenii[String(q["categorie"])] = []
				domenii[String(q["categorie"])].append(q)

		var nume: Array = domenii.keys()
		nume.sort()
		for domeniu in nume:
			var pool: Array = domenii[domeniu]

			# ACEEAȘI CHEIE pe care o folosește lupta, luată din `trivia.gd`, nu
			# scrisă din nou aici. Dacă forma cheii se schimbă vreodată, se schimbă
			# într-un singur loc — altfel verificarea ar proba un sac pe care jocul
			# nu-l folosește, și ar trece în vreme ce lupta repetă întrebări.
			var cheie := TRIVIA.cheia_sacului(domeniu, nivel)
			var vazute := {}
			var repetari := 0
			var ultima_id := ""

			# Exact atâtea trageri câte întrebări are sacul: un ciclu întreg, până
			# la ultimul bilet.
			for _i in range(pool.size()):
				var tras = Sac.extrage(cheie, pool, "id")
				if tras == null:
					break
				ultima_id = String(tras["id"])
				if vazute.has(ultima_id):
					repetari += 1
				vazute[ultima_id] = true

			if repetari == 0 and vazute.size() == pool.size():
				chei_bune += 1
			else:
				chei_picate.append("%s (%d din %d)" % [cheie, vazute.size(), pool.size()])

			# Răscrucea dintre cicluri. Sacul s-a golit la tragerile de mai sus, deci
			# următoarea deschide un ciclu nou — și singurul lucru care n-are voie să
			# iasă din el e chiar ultimul bilet al ciclului vechi, fiindcă aceeași
			# întrebare de două ori LA RÂND e cazul care se simte cel mai prost.
			#
			# Se sare peste sacurile cu o singură întrebare: acolo regula nu se POATE
			# respecta, iar `sac.gd` o încalcă dinadins („mai bine s-o încalci decât
			# să întorci null"). O verificare care ar cere-o oricum ar pica pe un
			# comportament corect.
			if pool.size() > 1:
				var prima = Sac.extrage(cheie, pool, "id")
				var id_nou := String(prima["id"]) if prima != null else ""
				if id_nou == "" or id_nou == ultima_id:
					rascruci_picate.append(cheie)

	tot_bun = _verdict("un ciclu întreg, pe fiecare cheie", chei_picate.is_empty(),
		"%d chei fără nicio repetiție" % chei_bune if chei_picate.is_empty()
		else _primele(chei_picate, 4)) and tot_bun
	tot_bun = _verdict("răscrucea dintre cicluri", rascruci_picate.is_empty(),
		"" if rascruci_picate.is_empty() else _primele(rascruci_picate, 4)) and tot_bun

	Sac.expeditie_noua()
	return tot_bun


# ───────────────────────────────────────────────────────────
# 8. SACURILE NU SE AMESTECĂ ÎNTRE DOMENII
#
# Verificarea cea mai țintită din fișier, scrisă pentru O SINGURĂ greșeală, pe
# care nimic altceva n-ar prinde-o.
#
# `Sac.extrage` golește tot registrul unei chei când lista primită se epuizează
# („sacul s-a golit → ciclu nou"). Alegerea în două trepte îi dă o listă filtrată
# pe UN domeniu. Dacă cheia n-ar cuprinde domeniul, atunci în clipa în care se
# termină întrebările de știință de nivelul I, sacul ar șterge și memoria
# geografiei, a istoriei și a celorlalte de pe același nivel.
#
# CE S-AR FI VĂZUT: nimic. Niciun avertisment, niciun crash. Doar „parcă se
# repetă ceva, uneori" — și, cu sacul devenit permanent la Save, repetări într-o
# expediție de peste o săptămână. Exact felul de bug pe care nu-l găsești
# niciodată jucând.
#
# Deci: se GOLEȘTE complet un domeniu, apoi se întreabă altul dacă își mai ține
# minte biletele.
# ───────────────────────────────────────────────────────────

func _sacurile_nu_se_amesteca(intrebari: Array) -> bool:
	print("\n  SACURILE NU SE AMESTECĂ (se epuizează un domeniu, se întreabă altul)")

	var nivel := 1
	var pe_domenii := {}
	for q in intrebari:
		if int(q["nivel"]) == nivel:
			if not pe_domenii.has(String(q["categorie"])):
				pe_domenii[String(q["categorie"])] = []
			pe_domenii[String(q["categorie"])].append(q)

	if pe_domenii.size() < 2:
		return _verdict("nivelul %d are cel puțin două domenii" % nivel, false,
			"%d domenii" % pe_domenii.size())

	var nume: Array = pe_domenii.keys()
	nume.sort()
	var martor: String = String(nume[0])                  # cel care trebuie să-și țină minte
	var epuizat: String = String(nume[nume.size() - 1])   # cel pe care-l golim

	# O tragere din martor: de acum are un bilet pus deoparte.
	var pool_martor: Array = pe_domenii[martor]
	var tras_martor = Sac.extrage(TRIVIA.cheia_sacului(martor, nivel), pool_martor, "id")
	var id_martor := String(tras_martor["id"]) if tras_martor != null else ""

	# Golim celălalt domeniu de tot, plus o tragere peste, ca să declanșăm chiar
	# reciclarea. Aia e clipa în care un sac cu cheie comună ar șterge tot.
	var pool_epuizat: Array = pe_domenii[epuizat]
	for _i in range(pool_epuizat.size() + 1):
		Sac.extrage(TRIVIA.cheia_sacului(epuizat, nivel), pool_epuizat, "id")

	# Martorul: dacă memoria lui a supraviețuit, biletul tras la început NU poate
	# ieși din nou cât mai există altele nevăzute.
	var repetat := false
	for _i in range(pool_martor.size() - 1):
		var tras = Sac.extrage(TRIVIA.cheia_sacului(martor, nivel), pool_martor, "id")
		if tras != null and String(tras["id"]) == id_martor:
			repetat = true
			break

	Sac.expeditie_noua()
	return _verdict("%s își ține minte după ce %s s-a golit" % [martor, epuizat],
		not repetat,
		"" if not repetat else "%s a ieșit de două ori într-un ciclu" % id_martor)


# ─────────────────────────────────────────────────────────────
# RAPORTUL
# Aceleași două ajutoare ca la celelalte unelte, ca rapoartele să se citească la
# fel. Copiate dinadins, nu puse într-o bază comună: sunt patru rânduri de
# `print`, iar o bază comună de unelte ar fi un fișier pe care l-ai atinge de
# fiecare dată când o unealtă vrea o coloană în plus.
# ─────────────────────────────────────────────────────────────

func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-42s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array[String], cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(lista[i])
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

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
## `mana:0088` are notă, trebuie să pici pe ea: una din 45, pe un nivel, cu
## Obeliscul potrivit. Ca să vezi că sacul nu repetă, ar trebui să tragi toate
## cele 45 și să ții minte care au ieșit. Cu 135 de întrebări ar fi obositor; cu
## mii (ținta din sesiunea CONȚINUTUL) e imposibil.
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
##   SACUL NU REPETĂ PE UN CICLU. Cea mai importantă, fiindcă e o GARANȚIE, nu o
##   probabilitate, și fiindcă e singura care s-a schimbat azi: sacul recunoaște
##   întrebările după `id` în loc de text. Se trage un nivel întreg și se numără
##   id-urile distincte — trebuie să iasă exact câte întrebări are nivelul. Apoi
##   încă o tragere, prima din ciclul nou, care nu trebuie s-o repete pe ultima
##   din ciclul vechi (regula de la răscruce din `sac.gd`).
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

# Câte întrebări ar trebui să fie în fișier, și câte fapte. Scrise aici, nu
# citite din fișier, fiindcă o verificare care-și ia așteptările din lucrul
# verificat nu verifică nimic: dacă mâine dispar 10 întrebări, „am găsit câte am
# găsit" ar trece liniștită.
const CATE_INTREBARI := 135
const CATE_FAPTE := 15
const CATE_CU_NOTA := 18


func _ready() -> void:
	print("\n══ VERIFICAREA CULTURII GENERALE ══\n")

	TRIVIA.incarca_intrebari()
	var intrebari: Array = TRIVIA.intrebari
	var fapte: Dictionary = TRIVIA.fapte
	print("")

	var tot_bun := true
	tot_bun = _incarcarea(intrebari, fapte) and tot_bun
	tot_bun = _identitatile(intrebari) and tot_bun
	tot_bun = _notele(intrebari, fapte) and tot_bun
	tot_bun = _sacul(intrebari) and tot_bun

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
	tot_bun = _verdict("întrebări încărcate", intrebari.size() == CATE_INTREBARI,
		"%d din %d așteptate" % [intrebari.size(), CATE_INTREBARI]) and tot_bun
	tot_bun = _verdict("fapte încărcate", fapte.size() == CATE_FAPTE,
		"%d din %d așteptate" % [fapte.size(), CATE_FAPTE]) and tot_bun

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

		# Forma așteptată: un prefix, două puncte, și cifre. Prefixul spune din ce
		# fabrică vine întrebarea (`mana:` = scrisă de mână, `wd:` = din Wikidata),
		# deci verificăm forma, nu prefixul: un prefix nou nu trebuie să picheze
		# verificarea asta.
		var bucati := id_intrebare.split(":")
		if bucati.size() != 2 or bucati[0] == "" or not bucati[1].is_valid_int():
			forme_ciudate.append(id_intrebare)

	var tot_bun := true
	tot_bun = _verdict("toate au id", goale == 0,
		"" if goale == 0 else "%d fără id" % goale) and tot_bun
	tot_bun = _verdict("id-uri unice", duplicate.is_empty(),
		"%d distincte" % vazute.size() if duplicate.is_empty()
		else "duplicate: %s" % _primele(duplicate, 5)) and tot_bun
	tot_bun = _verdict("forma 'prefix:cifre'", forme_ciudate.is_empty(),
		"" if forme_ciudate.is_empty() else _primele(forme_ciudate, 5)) and tot_bun
	return tot_bun


# ─────────────────────────────────────────────────────────────
# 3. NOTELE
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


# ─────────────────────────────────────────────────────────────
# 4. SACUL
# ─────────────────────────────────────────────────────────────

func _sacul(intrebari: Array) -> bool:
	print("\n  SACUL (pe `id`, un ciclu întreg pe fiecare nivel)")
	var tot_bun := true

	for nivel in range(1, 4):
		var pool: Array = intrebari.filter(func(q): return int(q["nivel"]) == nivel)
		if pool.is_empty():
			tot_bun = _verdict("nivelul %d" % nivel, false, "nicio întrebare") and tot_bun
			continue

		# Cheie proprie verificării, ca să nu se amestece cu nimic: sacul e un
		# autoload, deci trăiește tot atât cât rularea asta.
		var cheie := "verificare:%d" % nivel
		var vazute := {}
		var repetari := 0
		var ultima_id := ""

		# Exact atâtea trageri câte întrebări are nivelul: un ciclu întreg, până
		# la ultimul bilet din sac.
		for _i in range(pool.size()):
			var tras = Sac.extrage(cheie, pool, "id")
			if tras == null:
				break
			ultima_id = String(tras["id"])
			if vazute.has(ultima_id):
				repetari += 1
			vazute[ultima_id] = true

		tot_bun = _verdict("nivelul %d, un ciclu" % nivel,
			repetari == 0 and vazute.size() == pool.size(),
			"%d trageri, %d întrebări distincte" % [pool.size(), vazute.size()]
			) and tot_bun

		# Răscrucea dintre cicluri. Sacul s-a golit la tragerea de mai sus, deci
		# următoarea deschide un ciclu nou — și singurul lucru care n-are voie să
		# iasă din el e chiar ultimul bilet al ciclului vechi, fiindcă aceeași
		# întrebare de două ori LA RÂND e cazul care se simte cel mai prost.
		var prima_din_ciclu_nou = Sac.extrage(cheie, pool, "id")
		var id_nou := String(prima_din_ciclu_nou["id"]) if prima_din_ciclu_nou != null else ""
		tot_bun = _verdict("nivelul %d, răscrucea" % nivel,
			id_nou != "" and id_nou != ultima_id,
			"%s după %s" % [id_nou, ultima_id]) and tot_bun

	return tot_bun


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

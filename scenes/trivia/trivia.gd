extends Puzzle
## Disciplina CULTURĂ GENERALĂ (în luptă încă apare ca „Memorie" — redenumirea
## e pasul 2 din ruta de construcție).
##
## Tot ce ține de cronometru, butoane, culori, sunete și contractul cu lupta
## trăiește în `puzzle.gd`. Fișierul ăsta răspunde la o singură întrebare:
## DE UNDE VINE ÎNTREBAREA — și de unde vine ORDINEA variantelor ei.
##
## Întrebările stau într-un fișier JSON, nu în cod. De ce merită mutarea:
## conținutul se schimbă mult mai des decât regulile. Ca să adaugi o întrebare
## nu mai deschizi cod, nu mai riști o virgulă pusă greșit care refuză să
## compileze tot jocul, și poți edita fișierul de pe telefon dacă-ți vine o
## idee. E și primul pas către traduceri.
##
## Prețul: Godot nu mai poate verifica nimic la compilare. Un JSON stricat se
## vede abia la rulare — de aceea încărcătorul de mai jos VALIDEAZĂ fiecare
## intrare și sare peste cele stricate, cu un avertisment în consolă, în loc să
## crape lupta la mijloc.
##
## ── CE CONȚINE BAZA ───────────────────────────────────────────
## ~135 de întrebări: 45 pe fiecare nivel, împărțite pe șase domenii
## (istorie, geografie, știință, artă, mitologie, literatură). Nivelul e
## singura măsură a dificultății, iar înțelesul lui e ăsta, și trebuie
## păstrat când adaugi întrebări:
##
##   nivelul 1 — o știe orice adult, fără să fi studiat ceva anume
##   nivelul 2 — s-a predat la școală; îți amintești dacă ai fost atent
##   nivelul 3 — o știi doar dacă domeniul te-a interesat dincolo de școală
##
## Domeniile sunt ținute în echilibru DINADINS (8/8/8/7/7/7 pe nivel).
## Întrebarea nu-și alege domeniul: se trage din tot nivelul. Dacă istoria
## ar avea 20 de intrări și mitologia 3, „Cultură generală" ar deveni, în
## practică, „Istorie, cu accidente" — și ai antrena un singur colț de minte.
##
## ── FĂRĂ REPETIȚII ────────────────────────────────────────────
## Întrebările NU se aleg pur aleatoriu. Se trag dintr-un „sac" care ține
## minte ce a ieșit deja în expediția curentă (`autoload/sac.gd`), iar
## variantele se amestecă la fiecare apariție (`_amesteca`, mai jos).

const CALE_INTREBARI := "res://data/intrebari_trivia.json"
# Categoriile acceptate. Lista NU e decor: o categorie scrisă greșit în JSON
# („istoire") e prinsă la încărcare, cu un avertisment în consolă, în loc să
# ajungă în luptă ca antet fără sens.
#
# „literatura" s-a desprins din „arta" când baza a crescut la ~135 de
# întrebări. La 45, cărțile încăpeau lângă pictură și muzică; la 135, cine
# vrea să adauge întrebări nu mai știe unde să caute, iar echilibrul pe
# domenii nu se mai poate citi dintr-o privire. „mitologie" e nouă.
const CATEGORII := [
	"istorie", "geografie", "stiinta", "arta", "mitologie", "literatura",
]

# Cheia sacului din care se trag întrebările, fără repetiții, cât ține o
# expediție. Nivelul intră în cheie fiindcă fiecare nivel e o listă ALTA:
# un sac per nivel, nu unul comun. Vezi `autoload/sac.gd`.
const SAC := "cultura_generala"

# `static var` = aparține SCRIPTULUI, nu fiecărei copii a scenei.
# Deschizi puzzle-ul de ~7 ori pe rundă; fără `static`, fișierul ar fi citit
# de pe disc de fiecare dată. Așa, se citește o singură dată pe rulare,
# iar toate instanțele viitoare folosesc aceeași listă.
static var intrebari: Array[Dictionary] = []
static var incarcare_incercata := false


# ─────────────────────────────────────────────────────────────
# CELE DOUĂ FUNCȚII DIN CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Prima: citește fișierul. Chemată de mai multe ori, face ceva o singură dată.
func _pregateste_datele() -> void:
	incarca_intrebari()


## A doua: produce o întrebare. Tot ce urmează după — cronometru, culori,
## verdict — e treaba bazei, care nu știe că a primit trivia.
func _compune_intrebare(nivel: int) -> Dictionary:
	# `filter` trece prin array și păstrează doar elementele pentru care
	# funcția anonimă (lambda) întoarce true. Aici: doar întrebările de nivelul cerut.
	var pool: Array = intrebari.filter(func(q): return q["nivel"] == nivel)
	if pool.is_empty():
		pool = intrebari   # plasă de siguranță: mai bine o întrebare de alt nivel decât niciuna

	# Dacă fișierul lipsește sau e complet stricat, nu avem NICIO întrebare.
	# Dicționar gol = „n-am putut": baza arată ecranul de eroare și raportează
	# eșec ordonat, în loc să lase lupta să aștepte un semnal care nu mai vine.
	if pool.is_empty():
		return {}

	# Aici NU folosim `pool.pick_random()`. Sacul e cel care ține minte ce
	# s-a pus deja pe masă în expediția asta și trage doar dintre întrebările
	# rămase — motivul lung e scris în `autoload/sac.gd`. Pe scurt: alegerea
	# pur aleatoare repetă mai des decât crezi, iar o întrebare repetată e o
	# întrebare gratis într-un joc de antrenament mental.
	#
	# „text" e câmpul după care sacul recunoaște o întrebare. Nu poziția în
	# listă: aia se mută de fiecare dată când adaugi o întrebare la mijlocul
	# fișierului.
	var tras = Sac.extrage("%s:%d" % [SAC, nivel], pool, "text")
	if tras == null:
		return {}
	var q: Dictionary = tras

	# Variantele se amestecă ACUM, la fiecare apariție a întrebării.
	var amestecate := _amesteca(q)

	return {
		# Antetul spune doar din ce domeniu e întrebarea. Nivelul nu apare —
		# îl simți oricum din cronometru și din dificultate.
		"categorie": String(q["categorie"]).to_upper(),
		"text": q["text"],
		"variante": amestecate["variante"],
		"corect": amestecate["corect"],
		# Trivia n-are „regulă de rezolvare": ori știi, ori nu. Câmpul rămâne
		# gol, iar baza îl acceptă gol — e opțional tocmai pentru cazul ăsta.
		"explicatie": "",
	}


## Ce fișier să cauți dacă ecranul de eroare apare vreodată în luptă.
func _descriere_sursa() -> String:
	return CALE_INTREBARI


# ─────────────────────────────────────────────────────────────
# AMESTECAREA VARIANTELOR
# ─────────────────────────────────────────────────────────────

## Întoarce aceleași patru variante, în altă ordine, plus noul indice corect.
##
## DE CE E NEVOIE DE EA. Într-un fișier scris de mână, răspunsul bun nu cade
## uniform pe cele patru poziții — cine scrie întrebări are obiceiuri. În
## baza de acum, înainte de amestecare, poziția a doua era corectă de patru
## ori mai des decât ultima. Asta nu e un amănunt de statistică: e o
## SCURTĂTURĂ. Sub cronometru, un jucător care nu știe răspunsul ghicește, iar
## dacă ghicitul are un favorit, el îl va găsi fără să-l caute — și va marca
## puncte fără să fi gândit. Într-un joc de antrenament mental, asta e cel
## mai rău lucru care se poate întâmpla.
##
## Se putea și rescriind fișierul, mutând răspunsurile până ies 25% pe
## fiecare poziție. Ar fi ținut exact până la a 136-a întrebare scrisă
## noaptea, când obiceiul revine. Amestecarea la rulare rezolvă problema o
## dată, pentru toate întrebările care vor mai fi scrise vreodată.
##
## BONUS: aceeași întrebare, văzută a doua oară peste două expediții, nu-ți
## mai poate fi ghicită din poziția butonului. Ții minte RĂSPUNSUL sau nimic.
static func _amesteca(q: Dictionary) -> Dictionary:
	# `duplicate()` face o COPIE. Fără el, `shuffle()` ar amesteca chiar
	# lista din `intrebari`, care e ținută în memorie pentru toată rularea:
	# ai amesteca originalul, nu afișarea lui.
	var variante: Array = (q["variante"] as Array).duplicate()

	# Reținem TEXTUL răspunsului bun, nu indicele: indicele e exact lucrul
	# care se schimbă în rândurile următoare.
	var raspuns: String = String(variante[int(q["corect"])])
	variante.shuffle()

	# `find()` întoarce prima poziție pe care apare textul. E corect FIINDCĂ
	# încărcătorul refuză întrebările cu două variante identice — altfel
	# „prima potrivire" ar putea fi cealaltă, iar răspunsul bun ar fi
	# marcat greșit. Verificarea de acolo nu e curățenie: ea e ce face
	# linia asta sigură.
	return {"variante": variante, "corect": variante.find(raspuns)}


# ─────────────────────────────────────────────────────────────
# ÎNCĂRCAREA
# ─────────────────────────────────────────────────────────────

## Citește și validează fișierul. Sigur de chemat de oricâte ori:
## după prima încercare nu mai face nimic.
static func incarca_intrebari() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	var brute := Puzzle.citeste_lista_json(CALE_INTREBARI, "Trivia")
	for i in range(brute.size()):
		var q = brute[i]
		if not _intrebare_valida(q, i):
			continue
		# ATENȚIE, capcană clasică: JSON nu are numere întregi, doar zecimale.
		# „corect": 2 ajunge în Godot ca 2.0 (float), iar un float nu poate
		# indexa un Array. Convertim o dată, aici, ca restul codului să
		# lucreze liniștit cu int-uri.
		q["corect"] = int(q["corect"])
		q["nivel"] = int(q["nivel"])
		intrebari.append(q)

	print("Trivia: %d intrebari incarcate (din %d gasite)." % [intrebari.size(), brute.size()])


## Verifică o singură intrare. Întoarce false și explică în consolă,
## în loc să lase o întrebare stricată să ajungă în luptă.
static func _intrebare_valida(q, i: int) -> bool:
	var unde := "intrarea %d" % i
	if not Puzzle.are_campurile(q, ["text", "variante", "corect", "nivel", "categorie"], "Trivia", unde):
		return false

	if not (q["variante"] is Array) or q["variante"].size() != 4:
		push_warning("Trivia: %s nu are exact 4 variante." % unde)
		return false

	# Două variante identice ar face întrebarea ambiguă pe ecran ȘI ar strica
	# amestecarea (vezi `_amesteca`). Le prindem aici, unde costă un
	# avertisment în consolă, nu în luptă, unde ar costa un răspuns bun
	# marcat ca greșit.
	var distincte := {}
	for varianta in q["variante"]:
		distincte[String(varianta)] = true
	if distincte.size() != 4:
		push_warning("Trivia: %s are doua variante identice." % unde)
		return false

	var corect := int(q["corect"])
	if corect < 0 or corect > 3:
		push_warning("Trivia: %s are 'corect' = %d, in afara intervalului 0-3." % [unde, corect])
		return false

	var nivel := int(q["nivel"])
	if nivel < 1 or nivel > Puzzle.TIMP_PE_NIVEL.size():
		push_warning("Trivia: %s are nivelul %d, in afara intervalului 1-3." % [unde, nivel])
		return false

	if not (q["categorie"] in CATEGORII):
		push_warning("Trivia: %s are categoria necunoscuta '%s'." % [unde, q["categorie"]])
		return false

	return true

extends Puzzle
## Disciplina CULTURĂ GENERALĂ (în luptă încă apare ca „Memorie" — redenumirea
## e pasul 2 din ruta de construcție).
##
## Tot ce ține de cronometru, butoane, culori, sunete și contractul cu lupta
## trăiește în `puzzle.gd`. Fișierul ăsta răspunde la o singură întrebare:
## DE UNDE VINE ÎNTREBAREA. Erau ~700 de linii; au rămas ~120, și toate sunt
## despre trivia.
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

const CALE_INTREBARI := "res://data/intrebari_trivia.json"
const CATEGORII := ["istorie", "stiinta", "geografie", "arta"]

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

	var q: Dictionary = pool.pick_random()
	return {
		# Antetul spune doar din ce domeniu e întrebarea. Nivelul nu apare —
		# îl simți oricum din cronometru și din dificultate.
		"categorie": String(q["categorie"]).to_upper(),
		"text": q["text"],
		"variante": q["variante"],
		"corect": q["corect"],
		# Trivia n-are „regulă de rezolvare": ori știi, ori nu. Câmpul rămâne
		# gol, iar baza îl acceptă gol — e opțional tocmai pentru cazul ăsta.
		"explicatie": "",
	}


## Ce fișier să cauți dacă ecranul de eroare apare vreodată în luptă.
func _descriere_sursa() -> String:
	return CALE_INTREBARI


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

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
##
## Sacul recunoaște o întrebare după `id`, nu după text — vezi de ce în
## `_compune_intrebare`.
##
## ── DOUĂ FIȘIERE, DOUĂ FELURI DE CONȚINUT ─────────────────────
## `intrebari_trivia.json` ține întrebările. `fapte_trivia.json` ține NOTELE,
## câte una pe fapt, iar întrebarea arată spre fapt printr-un câmp `fapt`.
## Regulile de scris ale unei note sunt în `docs/ghid-note.md`.
##
## ── DOUĂ REGULI DESPRE `id`, PE CARE NIMIC DIN COD NU LE APĂRĂ ─
## 1. Un `id` NU SE REFOLOSEȘTE NICIODATĂ. Deci întrebările nu se șterg din
##    fișier: una scoasă din joc se marchează `"retras": true` și rămâne pe loc,
##    cu id-ul ei. Încărcătorul de aici va învăța să sară peste ele când va fi
##    nevoie — azi nu e nimic retras, deci nu există codul. Motivul întreg e în
##    antetul lui `tools/da_iduri.py`: un id refolosit dă unei întrebări noi
##    istoricul altei întrebări, iar nimic nu poate prinde asta.
## 2. `id`-urile se dau cu scriptul, nu de mână: `python tools/da_iduri.py --scrie`.

const CALE_INTREBARI := "res://data/intrebari_trivia.json"

# FAPTELE. Un „fapt" e un lucru despre lume care poate fi întrebat în mai multe
# feluri, iar NOTA („Află mai multe") stă pe fapt, nu pe întrebare: faptul `aur`
# acoperă și „simbolul chimic al aurului" (nivelul I), și „ce element are numărul
# atomic 79" (nivelul III), cu o singură notă pentru amândouă. Motivul lung e în
# `docs/ghid-note.md`, secțiunea 1. Pe scurt: mai puțină muncă (5000 de întrebări
# au nevoie de vreo 2000 de note) și mai puține greșeli, fiindcă un fapt verificat
# o dată e corect peste tot unde apare. Două note scrise separat despre același
# lucru ajung, într-o zi, să se contrazică.
const CALE_FAPTE := "res://data/fapte_trivia.json"

# Lungimea maximă a unei note, în caractere. Cifră PROVIZORIE: se reglează când
# există popup-ul din Practice și se vede pe telefon câte rânduri încap fără
# derulare (`docs/ghid-note.md`, secțiunea 7). Depășirea e un avertisment, nu un
# refuz — e o limită de stil, nu de corectitudine, iar o notă bună nu merită
# tăiată ca să respecte o cifră nejucată.
const MAX_NOTA := 240

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

## Faptele, ca `id` → notă. Un Dictionary, nu o listă, fiindcă singura întrebare
## pusă vreodată aici e „ce notă are faptul ăsta?" — o căutare pe cheie, de câteva
## ori pe rundă.
static var fapte := {}


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
	# „id" e câmpul după care sacul recunoaște o întrebare.
	#
	# Nu poziția în listă: aia se mută de fiecare dată când adaugi o întrebare la
	# mijlocul fișierului. Dar nici TEXTUL, care a fost identitatea de până acum:
	# textul se schimbă la fiecare reformulare, iar în ziua în care rescriu o
	# întrebare ca să sune mai bine, un save ar crede că e o întrebare cu totul
	# nouă — nevăzută, deci gratis. `id`-ul e singurul câmp care nu se mișcă
	# niciodată, tocmai pentru că nu înseamnă nimic pentru jucător.
	#
	# Se schimbă ACUM, înainte de Save (pasul 8), fiindcă azi identitățile trăiesc
	# doar în memorie: nu scrie nimeni nimic pe disc, deci nu e nimic de migrat.
	# După Save, aceeași schimbare ar fi cerut o conversie a fiecărui save existent.
	var tras = Sac.extrage("%s:%d" % [SAC, nivel], pool, "id")
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
		# NOTA faptului, dacă întrebarea e legată de unul. Câmpul `explicatie` din
		# contractul cu `puzzle.gd` exista deja, gol: la Logică ține numele regulii
		# („FIBONACCI"), la Trivia nu ținea nimic, fiindcă la o întrebare de cultură
		# generală ori știi, ori nu — n-are „regulă de rezolvare".
		#
		# Nota e ce intră acolo. Rămâne gol pentru întrebările fără fapt, iar baza
		# acceptă gol: câmpul e opțional tocmai pentru cazul ăsta.
		#
		# NIMENI NU-L AFIȘEAZĂ ÎNCĂ. Primul loc va fi „Află mai multe" din Practice
		# (pasul 13), pentru toate disciplinele deodată. Se umple de pe acum fiindcă
		# e o linie aici și un fișier de conținut în plus, iar conținutul e partea
		# lentă: notele se pot scrie și verifica luni de zile înainte să existe
		# ecranul care le arată.
		"explicatie": String(fapte.get(String(q.get("fapt", "")), "")),
	}


## Ce fișier să cauți dacă ecranul de eroare apare vreodată în luptă.
func _descriere_sursa() -> String:
	return CALE_INTREBARI


## Trivia ÎȘI POARTĂ SINGURĂ de grijă la repetiții, deci întoarce șir gol și
## oprește reîncercarea din `puzzle.gd`.
##
## Nu e o scutire, e o unealtă mai bună. Baza nu poate decât să ceară din nou
## și să spere, fiindcă o disciplină generativă nu-și poate enumera
## întrebările. Trivia ȘI LE POATE: sunt 45 pe nivel, într-un fișier. De aceea
## trage din sac (`Sac.extrage`), care nu repetă niciuna cât timp mai există
## una nevăzută — o garanție, nu o probabilitate. Două mecanisme peste
## aceleași întrebări ar fi șters exact garanția asta.
func _identitate_intrebare(_q: Dictionary) -> String:
	return ""


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

## Citește și validează amândouă fișierele. Sigur de chemat de oricâte ori:
## după prima încercare nu mai face nimic.
##
## FAPTELE ÎNTÂI, din două motive. Unul: întrebările au nevoie de mulțimea de
## fapte ca să-și poată verifica legătura. Celălalt: după ce s-au citit amândouă
## se poate pune întrebarea inversă — există fapte pe care nu le folosește nicio
## întrebare? Aia e singura verificare care are nevoie de ambele fișiere deodată,
## și e cea care prinde conținut mort: o notă scrisă degeaba nu se vede altfel
## niciodată, fiindcă lipsa ei nu strică nimic.
static func incarca_intrebari() -> void:
	if incarcare_incercata:
		return
	incarcare_incercata = true

	_incarca_fapte()

	# `folosite` strânge, cât trec întrebările, faptele de care se agață măcar una.
	# `id_uri` prinde duplicatele: două întrebări cu același `id` sunt, pentru sac,
	# o singură întrebare — una din ele n-ar mai ieși NICIODATĂ, fără niciun semn.
	var folosite := {}
	var id_uri := {}

	var brute := Puzzle.citeste_lista_json(CALE_INTREBARI, "Trivia")
	for i in range(brute.size()):
		var q = brute[i]
		if not _intrebare_valida(q, i, id_uri):
			continue
		# ATENȚIE, capcană clasică: JSON nu are numere întregi, doar zecimale.
		# „corect": 2 ajunge în Godot ca 2.0 (float), iar un float nu poate
		# indexa un Array. Convertim o dată, aici, ca restul codului să
		# lucreze liniștit cu int-uri.
		q["corect"] = int(q["corect"])
		q["nivel"] = int(q["nivel"])
		id_uri[String(q["id"])] = i
		if q.get("fapt", "") != "":
			folosite[String(q["fapt"])] = true
		intrebari.append(q)

	print("Trivia: %d intrebari incarcate (din %d gasite)." % [intrebari.size(), brute.size()])

	# Fapte pe care nu le cere nimeni. Nu strică nimic în joc, și exact de-aia
	# merită un avertisment: altfel e muncă de scris și de verificat care nu ajunge
	# niciodată la un jucător, iar la mii de fapte n-ai cum s-o mai găsești.
	for id_fapt in fapte:
		if not folosite.has(id_fapt):
			push_warning("Trivia: faptul '%s' nu e folosit de nicio intrebare." % id_fapt)


## Citește `fapte_trivia.json` în `fapte` (id → notă).
##
## Un fișier de fapte care lipsește NU e o eroare: întrebările merg mai departe
## fără note, exact ca înainte de sesiunea asta. De-aia întoarce în tăcere dacă
## `citeste_lista_json` n-a găsit nimic — funcția aia s-a plâns deja în consolă.
static func _incarca_fapte() -> void:
	var brute := Puzzle.citeste_lista_json(CALE_FAPTE, "Fapte")
	var neverificate := 0
	for i in range(brute.size()):
		var f = brute[i]
		var unde := "faptul %d" % i
		if not Puzzle.are_campurile(f, ["id", "nota"], "Fapte", unde):
			continue

		var id_fapt := String(f["id"])
		if id_fapt == "":
			push_warning("Fapte: %s are id gol." % unde)
			continue
		if fapte.has(id_fapt):
			push_warning("Fapte: id-ul '%s' apare de doua ori; a doua nota e ignorata." % id_fapt)
			continue

		var nota := String(f["nota"])
		if nota.length() > MAX_NOTA:
			# AVERTISMENT, nu refuz: nota rămâne întreagă și ajunge în joc. Limita
			# e de stil și e încă neverificată pe ecran, deci o notă bună nu se
			# pierde pentru ea — se rescurtează când o citești.
			push_warning("Fapte: nota faptului '%s' are %d caractere (maximum %d)." % [
				id_fapt, nota.length(), MAX_NOTA
			])

		if not bool(f.get("verificat", false)):
			neverificate += 1
		fapte[id_fapt] = nota

	if not brute.is_empty():
		print("Trivia: %d fapte incarcate (din %d gasite), %d neverificate." % [
			fapte.size(), brute.size(), neverificate
		])


## Verifică o singură intrare. Întoarce false și explică în consolă,
## în loc să lase o întrebare stricată să ajungă în luptă.
##
## `id_uri` e registrul întrebărilor acceptate până acum, ca să se poată prinde
## un `id` folosit de două ori.
static func _intrebare_valida(q, i: int, id_uri: Dictionary) -> bool:
	var unde := "intrarea %d" % i
	if not Puzzle.are_campurile(q, ["id", "text", "variante", "corect", "nivel", "categorie"], "Trivia", unde):
		return false

	# ─── IDENTITATEA ───
	# De azi, `id` e câmp obligatoriu ca `text`, iar o întrebare fără el e SĂRITĂ.
	# Pare dur pentru un câmp care nu se vede pe ecran, dar el e cel prin care
	# sacul, save-ul și (mai târziu) istoricul din Practice recunosc întrebarea. O
	# întrebare fără `id` n-ar putea intra cinstit în niciunul din cele trei, iar
	# leacul e o singură comandă — de aia o spune chiar avertismentul.
	#
	# Pierderea se vede și în linia de bilanț de mai sus („134 incarcate din 135
	# gasite"), care e motivul pentru care sărirea nu e o dispariție tăcută.
	var id_intrebare := String(q["id"])
	if id_intrebare == "":
		push_warning("Trivia: %s are id gol. Ruleaza `python tools/da_iduri.py --scrie`." % unde)
		return false
	if id_uri.has(id_intrebare):
		push_warning("Trivia: %s are id-ul '%s', deja folosit de intrarea %d; o sarim." % [
			unde, id_intrebare, id_uri[id_intrebare]
		])
		return false

	# ─── LEGĂTURA CU FAPTUL ───
	# `fapt` e OPȚIONAL: o întrebare fără fapt apare fără notă, exact ca înainte.
	# Dar un `fapt` care arată spre un id inexistent e o scăpare de tastat, și
	# atunci nota lipsește în tăcere — nimic nu crapă, doar „Află mai multe" nu are
	# ce arăta. Întrebarea rămâne (e în continuare bună), legătura cade.
	if q.get("fapt", "") != "" and not fapte.has(String(q["fapt"])):
		push_warning("Trivia: %s trimite la faptul '%s', care nu exista in %s." % [
			unde, q["fapt"], CALE_FAPTE
		])
		q.erase("fapt")

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

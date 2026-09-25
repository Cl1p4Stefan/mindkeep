extends Node
## VERIFICAREA CIFRURILOR — bate generatorul de lacăte pe multe semințe.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verifica_cifru.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE ARE NEVOIE LACĂTUL DE O UNEALTĂ A LUI
##
## Restul verificatoarelor întreabă lucruri despre DESEN sau despre DRUMURI.
## Ăsta întreabă singurul lucru care contează la un puzzle de deducție: se
## poate rezolva, și se poate rezolva ÎNTR-UN SINGUR FEL?
##
## E o întrebare care nu se poate testa jucând. Un cifru cu două soluții arată
## perfect normal: indiciile se citesc, deducția pare să meargă, iar jucătorul
## tastează un cod care respectă TOATE indiciile — și lacătul refuză să se
## deschidă. Nu ai raporta asta ca bug, ai crede că ai greșit tu. De-aia
## unicitatea trebuie dovedită pe mii de puzzle-uri, mecanic, înainte ca vreunul
## să ajungă în fața ta.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   UNICITATEA — există exact un cod care respectă toate indiciile. Dovedită
##   prin forță brută peste TOATE codurile posibile (vezi comentariul mare din
##   `generator_cifru.gd`), nu prin eșantion.
##
##   CODUL RESPECTĂ INDICIILE — soluția anunțată e chiar o soluție. Pare de la
##   sine înțeles (indiciile se nasc citind codul), dar e exact genul de lucru
##   care se strică tăcut când adaugi un tip nou și `evalueaza()` îl înțelege
##   altfel decât îl scria `_candidati()`.
##
##   NICIUN INDICIU REDUNDANT — scoate-l și puzzle-ul devine ambiguu; dacă nu
##   devine, indiciul ăla era decor. Un rând care nu servește la nimic îl pune
##   pe jucător să caute ce aduce nou, și nu aduce nimic.
##
##   NICIUN INDICIU CARE DĂ DIRECT O CIFRĂ — regula de design a Lacătului. Nu
##   se verifică după numele tipului, ci după efect: dacă toate codurile care
##   respectă un indiciu au aceeași cifră pe o poziție, indiciul ăla dictează.
##
##   ACEEAȘI SĂMÂNȚĂ → ACELAȘI PUZZLE — cea mai ușor de uitat și cea mai
##   scumpă când lipsește: fără ea, „evenimentul din expediția 12345 are un
##   lacăt imposibil" nu se poate reproduce niciodată.
##
##   FIECARE INDICIU ARE O PROPOZIȚIE — prinde tipul adăugat în `evalueaza()`
##   și uitat în `text()`. Fără verificarea asta, l-ai găsi pe ecran, în joc.
##
##   NOTA E CEA CERUTĂ DE NIVEL — de când dificultatea se măsoară cu
##   `RezolvitorCifru`, un nivel e definit de cât de greu se deduce codul, nu de
##   câte indicii are. Verificarea asta e singurul loc din care afli dacă
##   tabelul de dificultate chiar livrează ce promite. Cu o nuanță: puzzle-urile
##   ieșite pe ușa din dos (toate încercările epuizate) se numără separat și au
##   voie până la `REZERVA_ACCEPTATA` la sută — supapa aia e proiectată, nu
##   stricată. Nota greșită FĂRĂ ca rezerva să fi intrat în joc rămâne eroare.
##
##   REZOLVITORUL ȘI FORȚA BRUTĂ SPUN ACELAȘI LUCRU — codul la care ajunge
##   rezolvitorul e chiar codul puzzle-ului. E verificarea care păzește
##   verificarea: un bug în rezolvitor n-ar crăpa nimic și n-ar da niciun
##   simptom, ar da doar note greșite — adică un tabel de dificultate care
##   minte, în tăcere, pentru totdeauna.
##
##   CEL MULT O EGALITATE LA NIVELUL 3 — regula de design a nivelului greu.
##   Se verifică prin `GeneratorCifru.e_egalitate()`, aceeași funcție pe care o
##   folosește generatorul; două definiții s-ar despărți la primul tip nou.
##
## Plus profilul care se citește ca un raport de design: distribuția notelor,
## câte indicii are un puzzle, ce tipuri apar și cât de des, câte reîncercări
## cere o sămânță.

## Câte semințe pe nivel.
##
## A scăzut de la 500, și merită spus de ce: de când fiecare încercare trece și
## prin rezolvitor, o generare de nivel 3 ia în jur de o secundă și un sfert în
## loc de câteva zecimi. La 500 de semințe unealta ar fi durat peste o
## jumătate de oră, iar o unealtă pe care n-o mai pornești fiindcă durează prea
## mult nu mai apără nimic. La 200 durează vreo zece minute — destul de puțin
## cât s-o chemi după fiecare umblătură la generator, și destul de multe
## semințe cât o problemă de una la cincizeci să iasă la iveală.
const SEMINTE := 200

## De la ce sămânță pornim. Nu de la 0, din același motiv ca la celelalte
## unelte: `_sub_samanta()` înmulțește, iar sămânța 0 ar da aceeași sub-sămânță
## pentru toate încercările ei.
const PRIMA_SAMANTA := 1000

## Cât la sută dintre semințe au voie să primească puzzle-ul de rezervă, cu altă
## notă decât cea cerută de nivel.
##
## Nu zero, și e o alegere conștientă. Generatorul caută un puzzle de nota
## cerută în `INCERCARI_MAXIME` încercări; când nu-l găsește, livrează cel mai
## apropiat puzzle CORECT în loc să lase jucătorul fără lacăt. E supapa
## documentată în `genereaza()`, și prețul ei e o treaptă de dificultate, o dată
## la câteva sute de lacăte.
##
## Ce apără pragul e altceva: ca supapa să nu devină regulă. Dacă rata urcă,
## înseamnă că nivelul cere o notă pe care generatorul n-o prea poate produce —
## și atunci `alegere`, `egalitati_maxime` sau `candidati` sunt de reglat, nu
## `INCERCARI_MAXIME`. Măsurat azi: 1,1% la nivelul 3, zero la celelalte.
const REZERVA_ACCEPTATA := 2.0


func _ready() -> void:
	print("VERIFICAREA CIFRURILOR (Lacătul)")
	print("Semințe: %d pe nivel, pornind de la %d. Limita de încercări: %d."
		% [SEMINTE, PRIMA_SAMANTA, GeneratorCifru.INCERCARI_MAXIME])

	var toate_bune := true
	for nivel in range(1, GeneratorCifru.NIVELURI.size() + 1):
		toate_bune = _verifica(nivel) and toate_bune

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"cifrurile ies bine" if toate_bune else "CEVA E STRICAT"])
	get_tree().quit(0 if toate_bune else 1)


# ─────────────────────────────────────────────────────────────
# UN NIVEL, PE TOATE SEMINȚELE
# ─────────────────────────────────────────────────────────────

func _verifica(nivel: int) -> bool:
	var spec: Dictionary = GeneratorCifru.specificatie(nivel)
	print("")
	print("═══ NIVELUL %d — %d roți, cifre %d-%d, cel mult %d indicii, nota %s, alegere %s ═══" % [
		nivel, spec["cifre"], spec["minim"], spec["maxim"], spec["indicii_maxime"],
		RezolvitorCifru.nume_nota(int(spec["nota"])), spec.get("alegere", "lacom")])

	# Toate codurile, o singură dată pentru tot nivelul. Verificările de mai jos
	# le parcurg de zeci de mii de ori; reconstruite la fiecare sămânță, ele
	# singure ar dubla durata uneltei.
	var toate: Array = GeneratorCifru.toate_codurile(spec)

	# Ce s-a stricat: nume de problemă → lista semințelor vinovate.
	var probleme := {}
	# Câte indicii are puzzle-ul: număr de indicii → de câte ori.
	var cate_indicii := {}
	# Tipurile: nume → de câte ori apare, peste toate puzzle-urile.
	var tipuri := {}
	var incercari: Array[int] = []
	var la_limita: Array[int] = []
	# Semințele care au primit puzzle-ul de rezerva, cu alta nota decat cea
	# ceruta. Asteptat si rar; devine problema doar peste `REZERVA_ACCEPTATA`.
	var pe_rezerva: Array[int] = []
	var goale := 0
	# Pe ce poziție a căzut roata blocată: pozitie → de câte ori. Gol la
	# nivelurile fără roată blocată. E o verificare de împrăștiere, nu de
	# corectitudine: dacă ar ieși mereu roata A, puzzle-urile ar avea toate
	# aceeași formă fără ca vreo altă verificare să se plângă.
	var blocate := {}
	# Cât a durat DOAR generarea, fără verificări. Microsecunde, adunate.
	var timp_generare := 0
	# Notele livrate: nota → de câte ori. La un nivel sănătos, un singur rând.
	var note := {}
	# Cât a durat DOAR notarea unui puzzle gata făcut. Nu e timpul din
	# generator (acolo se notează zeci de puzzle-uri respinse pentru unul bun),
	# dar spune cât costă o notare, ceea ce e numărul de care ai nevoie când te
	# întrebi de ce generarea a devenit lentă.
	var timp_notare := 0

	var start := Time.get_ticks_msec()

	for i in range(SEMINTE):
		var samanta := PRIMA_SAMANTA + i
		var pornit := Time.get_ticks_usec()
		var puzzle: Dictionary = GeneratorCifru.genereaza(nivel, samanta)
		timp_generare += Time.get_ticks_usec() - pornit

		if puzzle.is_empty():
			# Generatorul a strigat deja în consolă; aici doar numărăm.
			goale += 1
			_noteaza(probleme, "niciun puzzle generat", samanta)
			continue

		var indicii: Array = puzzle["indicii"]
		var cod: Array = puzzle["cod"]
		var blocata := int(puzzle["blocata"])

		# UNIVERSUL: codurile pe care puzzle-ul trebuie să le deosebească. Cu o
		# roată blocată sunt doar cele care se potrivesc cu ea. Cerut de la
		# generator, nu construit aici: două definiții ale aceleiași mulțimi ar
		# însemna un verificator care, într-o zi, declară stricate puzzle-uri
		# perfect bune — sau, mai rău, invers.
		var universul: Array = GeneratorCifru.universul(toate, cod, blocata)
		incercari.append(int(puzzle["incercari"]))
		if bool(puzzle["la_limita"]):
			la_limita.append(samanta)
		_numara(cate_indicii, indicii.size())
		for indiciu: Dictionary in indicii:
			_numara(tipuri, GeneratorCifru.eticheta(indiciu))

		# ── 1. Codul anunțat respectă toate indiciile ─────────
		for k in indicii.size():
			if not GeneratorCifru.evalueaza(indicii[k], cod):
				_noteaza(probleme, "codul își încalcă propriul indiciu", samanta)
				break

		# ── 2. Soluția e unică ────────────────────────────────
		var solutii: int = GeneratorCifru.cate_solutii_pentru(indicii, universul, 2)
		if solutii != 1:
			_noteaza(probleme, "soluția NU e unică" if solutii > 1 else "puzzle fără soluție",
				samanta)

		# ── 3. Niciun indiciu redundant ───────────────────────
		# Scoatem pe rând câte unul: dacă soluția rămâne unică fără el, indiciul
		# nu ținea nimic în picioare.
		for k in indicii.size():
			var fara := indicii.duplicate()
			fara.remove_at(k)
			if GeneratorCifru.cate_solutii_pentru(fara, universul, 2) == 1:
				_noteaza(probleme, "indiciu redundant", samanta)
				break

		# ── 4. Niciun indiciu nu dă direct o cifră ────────────
		# Tot pe univers, și cu roata blocată scoasă din socoteală: acolo ea are
		# o singură valoare posibilă prin definiție, deci ar face orice indiciu
		# să pară că dictează o cifră.
		if GeneratorCifru.indiciu_care_da_o_cifra(indicii, universul, blocata) != -1:
			_noteaza(probleme, "un indiciu fixează singur o cifră", samanta)

		# ── 4b. Roata blocată e cea promisă de tabel ──────────
		var trebuie_blocata := int(spec.get("blocate", 0)) > 0
		if trebuie_blocata != (blocata >= 0):
			_noteaza(probleme, "roata blocată nu se potrivește cu nivelul", samanta)
		elif blocata >= 0:
			if blocata >= cod.size():
				_noteaza(probleme, "roata blocată e în afara codului", samanta)
			else:
				_numara(blocate, blocata)

		# ── 5. Fiecare indiciu are o propoziție ───────────────
		for indiciu: Dictionary in indicii:
			var propozitie: String = GeneratorCifru.text(indiciu)
			if propozitie.is_empty() or propozitie.begins_with("(indiciu"):
				_noteaza(probleme, "indiciu fără text", samanta)
				break

		# ── 6. Dificultatea e cea cerută de nivel ─────────────
		# Notăm din nou puzzle-ul livrat, nu ne încredem în ce scrie în el:
		# `nota` e pusă de generator, iar dacă generatorul a uitat s-o pună (sau
		# a pus-o greșit), o verificare care citește cheia n-ar afla niciodată.
		var pornit_notare := Time.get_ticks_usec()
		var raport: Dictionary = RezolvitorCifru.noteaza(puzzle)
		timp_notare += Time.get_ticks_usec() - pornit_notare

		_numara(note, int(raport["nota"]) if bool(raport["rezolvat"]) else -1)

		if bool(raport["contrazis"]):
			_noteaza(probleme, "indiciile se contrazic între ele", samanta)
		elif not bool(raport["rezolvat"]):
			# Are soluție (punctul 2 a dovedit-o), dar nu există drum către ea
			# cu T1-T3: jucătorul ar ajunge să ghicească.
			_noteaza(probleme, "codul nu se poate DEDUCE, doar ghici", samanta)
		else:
			# PĂZITORUL REZOLVITORULUI. Dacă rezolvitorul ajunge la alt cod
			# decât cel adevărat, notele lui sunt gunoi — și nimic altceva
			# n-ar semnala asta, fiindcă un puzzle cu notă greșită arată perfect
			# normal. E singura verificare de aici care apără o VERIFICARE, nu
			# jocul.
			if JSON.stringify(raport["cod"]) != JSON.stringify(cod):
				_noteaza(probleme, "rezolvitorul ajunge la alt cod decât cel adevărat",
					samanta)
			if int(raport["nota"]) != int(spec["nota"]):
				# DOUĂ LUCRURI DIFERITE, care nu se pun în aceeași găleată.
				#
				# Dacă puzzle-ul a ieșit pe UȘA DIN DOS (`la_limita`), generatorul
				# a căutat cinstit toate încercările permise, n-a găsit nota
				# cerută și a livrat cel mai apropiat puzzle corect, cu un
				# avertisment în consolă. Ăsta e comportamentul PROIECTAT: mai
				# bine un lacăt cu o treaptă mai jos decât un joc care se oprește
				# din mers. Se numără, ca să știm cât de des, dar nu e o
				# defecțiune.
				#
				# Dacă nota e greșită FĂRĂ ca rezerva să fi intrat în joc,
				# generatorul a acceptat un puzzle pe care trebuia să-l respingă.
				# Aia e o defecțiune, și e gravă: filtrul de dificultate nu-și
				# face treaba.
				if bool(puzzle["la_limita"]):
					pe_rezerva.append(samanta)
				else:
					_noteaza(probleme, "nota greșită, deși rezerva n-a intrat în joc",
						samanta)
			if int(puzzle.get("nota", 0)) != int(raport["nota"]):
				_noteaza(probleme, "nota scrisă în puzzle nu e nota reală", samanta)

		# ── 7. Cel mult atâtea egalități câte permite nivelul ─
		var plafon_egalitati := int(spec.get("egalitati_maxime", -1))
		if plafon_egalitati >= 0:
			var egalitati := 0
			for indiciu: Dictionary in indicii:
				if GeneratorCifru.e_egalitate(indiciu):
					egalitati += 1
			if egalitati > plafon_egalitati:
				_noteaza(probleme, "prea multe egalități pentru nivel", samanta)

		# ── 8. Aceeași sămânță, de două ori ───────────────────
		# Comparăm prin JSON, nu cu `==`: JSON compară pe conținut, la orice
		# adâncime, și e exact forma în care puzzle-ul ar ajunge într-un save.
		# Deci verificarea asta spune, pe lângă „e reproductibil", și „încape
		# în JSON fără traducător" — regula de save din CLAUDE.md.
		var din_nou: Dictionary = GeneratorCifru.genereaza(nivel, samanta)
		if JSON.stringify(din_nou) != JSON.stringify(puzzle):
			_noteaza(probleme, "aceeași sămânță dă alt puzzle", samanta)

	var durata := (Time.get_ticks_msec() - start) / 1000.0

	# ── RAPORTUL ──────────────────────────────────────────────
	print("")
	print("  Cât de greu se deduce codul (nota = cea mai grea tehnică cerută):")
	var chei_note := note.keys()
	chei_note.sort()
	for nota in chei_note:
		var cate: int = note[nota]
		var nume := "NEDEDUCTIBIL" if int(nota) < 0 else RezolvitorCifru.nume_nota(int(nota))
		print("    %-12s %4d puzzle-uri (%s)" % [nume, cate, _bara(cate, SEMINTE)])

	print("")
	print("  Câte indicii are un puzzle:")
	var marimi := cate_indicii.keys()
	marimi.sort()
	var suma_indicii := 0
	var cate_puzzle := 0
	for marime in marimi:
		var cate: int = cate_indicii[marime]
		suma_indicii += int(marime) * cate
		cate_puzzle += cate
		print("    %d indicii: %4d puzzle-uri (%s)" % [
			marime, cate, _bara(cate, SEMINTE)])
	print("    MEDIA: %.2f indicii pe puzzle." % [
		float(suma_indicii) / maxi(cate_puzzle, 1)])

	if not blocate.is_empty():
		var pozitii := blocate.keys()
		pozitii.sort()
		var linii := PackedStringArray()
		for poz in pozitii:
			linii.append("%s: %d" % [GeneratorCifru.litera(int(poz)), blocate[poz]])
		print("  Roata blocată, pe poziții — %s" % [", ".join(linii)])

	print("")
	print("  Ce tipuri de indiciu apar:")
	var total_indicii := 0
	for nume in tipuri:
		total_indicii += int(tipuri[nume])
	var nume_tipuri := tipuri.keys()
	nume_tipuri.sort()
	for nume in nume_tipuri:
		var cate: int = tipuri[nume]
		print("    %-16s %5d  (%4.1f%% din indicii)" % [
			nume, cate, 100.0 * cate / maxi(total_indicii, 1)])

	var medie := 0.0
	var maxim := 0
	for c in incercari:
		medie += c
		maxim = maxi(maxim, c)
	if not incercari.is_empty():
		medie /= incercari.size()
	print("")
	print("  Reîncercări: media %.2f, maximul %d (din %d permise)." % [
		medie, maxim, GeneratorCifru.INCERCARI_MAXIME])
	if not la_limita.is_empty():
		print("  Pe ușa din dos (toate încercările epuizate): %d semințe (%.1f%%): %s" % [
			la_limita.size(), 100.0 * la_limita.size() / maxi(SEMINTE, 1),
			_primele(la_limita)])
	print("  O GENERARE: %.1f ms în medie (doar generatorul, fără verificări)." % [
		timp_generare / 1000.0 / maxi(SEMINTE, 1)])
	print("  O NOTARE:   %.1f ms în medie (rezolvitorul, pe un puzzle gata făcut)." % [
		timp_notare / 1000.0 / maxi(SEMINTE, 1)])
	print("  Durata: %.1f s pentru %d puzzle-uri (plus încă %d, pentru determinism)."
		% [durata, SEMINTE, SEMINTE])

	# Rezerva are voie să intre în joc, dar rar. Peste prag, nu mai e o supapă —
	# e semn că nivelul cere ceva ce generatorul nu prea poate livra, iar
	# jucătorul primește des altceva decât scrie în tabel.
	var rata := 100.0 * pe_rezerva.size() / maxi(SEMINTE, 1)
	if not pe_rezerva.is_empty():
		print("  Rezerva, cu altă notă decât cea cerută: %d semințe (%.1f%%, prag %.1f%%): %s"
			% [pe_rezerva.size(), rata, REZERVA_ACCEPTATA, _primele(pe_rezerva)])
	if rata > REZERVA_ACCEPTATA:
		_noteaza(probleme, "rezerva intră în joc prea des", pe_rezerva[0])

	if probleme.is_empty():
		print("  ✔ Nicio problemă.")
		return true

	print("")
	for nume in probleme:
		var lista: Array = probleme[nume]
		print("  ✘ %s — %d semințe: %s" % [nume, lista.size(), _primele(lista)])
	return false


# ─────────────────────────────────────────────────────────────
# MĂRUNȚIȘURI DE RAPORT
# ─────────────────────────────────────────────────────────────

func _noteaza(unde: Dictionary, problema: String, samanta: int) -> void:
	if not unde.has(problema):
		unde[problema] = []
	unde[problema].append(samanta)


func _numara(unde: Dictionary, cheie) -> void:
	unde[cheie] = int(unde.get(cheie, 0)) + 1


## Primele câteva semințe dintr-o listă. Lista întreagă ar umple ecranul, iar
## pentru reprodus îți trebuie una singură.
func _primele(lista: Array, cate := 6) -> String:
	var scurta := lista.slice(0, cate)
	var text := ", ".join(scurta.map(func(s): return str(s)))
	if lista.size() > cate:
		text += ", …"
	return text


## O bară de text, ca distribuția să se vadă dintr-o privire.
func _bara(cate: int, din: int, latime := 28) -> String:
	var plin := int(round(latime * float(cate) / maxi(din, 1)))
	return "█".repeat(plin) + "·".repeat(latime - plin)

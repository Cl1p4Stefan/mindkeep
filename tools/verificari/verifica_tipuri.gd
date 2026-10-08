extends Node
## VERIFICAREA TIPURILOR — bate generatorul de tipuri pe multe semințe.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_tipuri.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎNCĂ O UNEALTĂ, PE LÂNGĂ CELELALTE TREI
##
## `verifica_plansa.gd` măsoară DESENUL: se taie drumurile, se ating nodurile,
## stă totul pe hârtie. `verifica_harta.gd` face același lucru pentru panglica
## generată. `verifica_drumuri.gd` întreabă dacă expediția se poate înfunda.
##
## Niciuna nu poate răspunde la întrebarea de-aici, fiindcă e despre CONȚINUT:
## „ce fel de noduri ies, și cât de des nu ies deloc?”. Tipurile nu se mai trag
## cu zarul, ci se așază după reguli, iar un set de reguli are o proprietate pe
## care un tabel de ponderi n-o avea niciodată — POATE SĂ NU AIBĂ SOLUȚIE. Asta
## e unealta care măsoară cât de aproape de imposibil suntem.
##
## ─────────────────────────────────────────────────────────────
## CE RAPORTEAZĂ, ȘI CUM SE CITEȘTE FIECARE CIFRĂ
##
##   MEDIA ȘI MAXIMUL ÎNCERCĂRILOR — cât de greu iese o hartă. Media spune cât
##   de strâmtă e rețeta; MAXIMUL spune cât de aproape de `INCERCARI_MAXIME` a
##   ajuns cea mai nefericită sămânță. Maximul e cifra care contează: media poate
##   fi 7 și tot să existe o sămânță care pică.
##
##   DE CÂTE ORI A PICAT FIECARE REGULĂ — aici se vede o ceartă între reguli
##   înainte să devină o hartă stricată. O regulă care pică în peste jumătate din
##   încercări NU e o regulă strictă, e o regulă care se bate cu alta sau cu
##   rețeta. Unealta o spune pe față, cu un avertisment.
##
##   SEMINȚELE CARE AU ATINS LIMITA — lista de reprodus. O sămânță de aici se
##   dă înapoi în joc și vezi cu ochii tăi harta de rezervă.
##
##   ACEEAȘI SĂMÂNȚĂ, DE DOUĂ ORI — confirmarea că generarea e reproductibilă.
##   E cea mai importantă verificare din tot fișierul, și cea mai ușor de uitat:
##   un generator care dă hărți bune, dar de fiecare dată altele, face imposibil
##   orice raport de bug („expediția 12345 se blochează la nodul 6”).
##
## Plus un profil al hărții: câte noduri din fiecare tip, ca să se vadă dintr-o
## privire că rețeta chiar e respectată.

const SEMINTE := 500

## De la ce sămânță pornim. Nu de la 0, fiindcă `_sub_samanta()` înmulțește:
## sămânța 0 ar da aceleași sub-semințe pentru toate încercările ei.
const PRIMA_SAMANTA := 1000

## Peste cât „a picat des” devine „se ceartă cu altceva”. Jumătate din
## încercări, adică pragul de la care regula nu mai filtrează, ci blochează.
const PRAG_INGRIJORARE := 0.5

## Numele sub care generatorul trece o încercare care s-a înfundat la plasare,
## înainte să se ajungă la reguli. Scris o dată, fiindcă e o înțelegere între
## două fișiere: dacă textul din `Expeditie._pune_tipurile()` se schimbă,
## raportul de mai jos ar tăcea în loc să crape.
const PLASARE := "plasare imposibilă"


func _ready() -> void:
	print("VERIFICAREA TIPURILOR DE NOD")
	print("Semințe: %d, pornind de la %d. Limita de încercări: %d."
		% [SEMINTE, PRIMA_SAMANTA, Expeditie.INCERCARI_MAXIME])

	var toate_bune := true
	for cale in _surse():
		toate_bune = _verifica(cale) and toate_bune

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"tipurile ies bine" if toate_bune else "CEVA E STRICAT"])
	get_tree().quit(0 if toate_bune else 1)


## Ce hărți se verifică: toate planșele din dosar, PLUS harta generată.
##
## Generata e în listă chiar dacă azi nu se joacă (`SURSA_HARTII` e pe DESENATA).
## E rezerva pe care cade jocul dacă o planșă se strică — deci dacă ea are
## reguli care nu ies, afli în ziua în care ai nevoie de ea cel mai tare.
func _surse() -> Array[String]:
	var gasite: Array[String] = [""]   # "" = harta generată
	for nume in DirAccess.get_files_at(Plansa.DOSAR):
		if nume.get_extension().to_lower() == "json":
			gasite.append(Plansa.DOSAR + nume)
	gasite.sort()
	return gasite


func _nume(cale: String) -> String:
	return "harta generată (panglică)" if cale == "" else cale.get_file()


# ─────────────────────────────────────────────────────────────
# O SURSĂ DE HARTĂ, PE TOATE SEMINȚELE
# ─────────────────────────────────────────────────────────────

func _verifica(cale: String) -> bool:
	print("")
	print("═══ %s ═══" % _nume(cale))

	# Câte încercări a cerut fiecare sămânță, ca să pot scoate media și maximul.
	var incercari: Array[int] = []
	var la_limita: Array[int] = []
	# Nume de regulă → de câte ori a picat, peste toate semințele.
	var picate := {}
	var incercari_totale := 0
	# Câte noduri din fiecare tip, GRUPATE PE MĂRIMEA HĂRȚII.
	#
	# Gruparea nu e un moft: panglica generată are 12, 14 sau 16 noduri, după
	# sămânță, iar rețeta e alta la fiecare mărime. O medie peste toate ar fi
	# arătat „2,47 Odihne” — un număr care nu descrie nicio hartă și care nu se
	# poate compara cu nimic. Planșele au o singură mărime, deci pentru ele
	# gruparea are o singură găleată și nu schimbă nimic.
	var pe_marime := {}
	# Semințele a căror hartă nu respectă propria ei rețetă efectivă.
	var gresite: Array[int] = []

	for i in range(SEMINTE):
		var samanta := PRIMA_SAMANTA + i
		var harta := Expeditie.genereaza_harta(samanta, cale)
		if harta.is_empty():
			print("    sămânța %d: hartă goală" % samanta)
			return false
		var cate_noduri := harta.size()
		if not pe_marime.has(cate_noduri):
			var gol := {}
			for tip in Expeditie.DATE_NOD:
				gol[tip] = 0
			pe_marime[cate_noduri] = {"harti": 0, "pe_tip": gol, "plafonate": 0}
		pe_marime[cate_noduri]["harti"] = int(pe_marime[cate_noduri]["harti"]) + 1

		# Cât de greu a ieșit: martorul lăsat de generator. Nu refacem socoteala
		# pe cont propriu — vezi nota de la `Expeditie.ultima_aranjare` pentru de ce
		# o unealtă care își reface singură cifrele ajunge, într-o zi, să mintă.
		var raport: Dictionary = Expeditie.ultima_aranjare
		incercari.append(int(raport["incercari"]))
		incercari_totale += int(raport["incercari"])
		if bool(raport["la_limita"]):
			la_limita.append(samanta)
		for nume in raport["picate"]:
			picate[nume] = int(picate.get(nume, 0)) + int(raport["picate"][nume])

		var pe_tip: Dictionary = pe_marime[cate_noduri]["pe_tip"]
		var numarate := {}
		for nod in harta:
			pe_tip[int(nod["tip"])] = int(pe_tip[int(nod["tip"])]) + 1
			numarate[int(nod["tip"])] = int(numarate.get(int(nod["tip"]), 0)) + 1

		# Rețeta se verifică PE FIECARE HARTĂ, față de cea efectivă — nu pe o
		# medie, și nu față de cea de pe hârtie. De când rețeta se plafonează
		# după formă (`Expeditie.reteta`), două hărți de aceeași mărime pot
		# cere lucruri diferite, iar o medie n-ar mai putea deosebi „plafonat
		# corect" de „greșit".
		var vecinatati := Expeditie._vecinatati(harta)
		var id_boss := harta.size() - 1
		for nod in harta:
			if int(nod["tip"]) == Expeditie.Nod.BOSS:
				id_boss = int(nod["id"])
		var efectiva := Expeditie.reteta(harta, vecinatati, 0, id_boss)
		var pe_hartie := Expeditie.proportii(cate_noduri)
		if str(efectiva) != str(pe_hartie):
			pe_marime[cate_noduri]["plafonate"] = int(
				pe_marime[cate_noduri].get("plafonate", 0)) + 1
		if not _respecta(numarate, efectiva):
			gresite.append(samanta)

	var bun := true

	# ── media și maximul ──────────────────────────────────────
	var suma := 0
	var maximul := 0
	for c in incercari:
		suma += c
		maximul = maxi(maximul, c)
	print("    %-42s %.2f   (maximul: %d din %d)" % [
		"încercări per sămânță, în medie",
		float(suma) / float(maxi(incercari.size(), 1)),
		maximul, Expeditie.INCERCARI_MAXIME])

	# ── rețeta ────────────────────────────────────────────────
	var marimi: Array = pe_marime.keys()
	marimi.sort()
	for cate_noduri in marimi:
		var galeata: Dictionary = pe_marime[cate_noduri]
		var pe_tip: Dictionary = galeata["pe_tip"]
		var harti := int(galeata["harti"])
		var bucati: Array[String] = []
		for tip in pe_tip:
			bucati.append("%s %.2f" % [
				Expeditie.DATE_NOD[tip]["nume"],
				float(pe_tip[tip]) / float(maxi(harti, 1))])
		print("    %d noduri (%d hărți): %s" % [cate_noduri, harti, ", ".join(bucati)])
		print("      %-40s %s" % ["rețeta pe hârtie",
			_ca_reteta(Expeditie.proportii(cate_noduri))])
		var plafonate := int(galeata.get("plafonate", 0))
		if plafonate > 0:
			# Nu e un eșec: e chiar mecanismul de plafonare care-și face treaba.
			# Merită însă văzut, fiindcă o hartă plafonată des e o hartă a cărei
			# formă nu încape rețeta — semn că forma trebuie lărgită, nu rețeta
			# strâmtată.
			print("      %-40s %d din %d hărți (%.0f%%)" % [
				"rețetă tăiată de formă", plafonate, harti,
				100.0 * float(plafonate) / float(maxi(harti, 1))])

	bun = _verdict("fiecare hartă își respectă rețeta", gresite.is_empty(),
		"" if gresite.is_empty() else "%d semințe: %s" % [
			gresite.size(), _primele(gresite, 10)]) and bun

	# ── regulile picate ───────────────────────────────────────
	#
	# „Plasare imposibilă" se raportează SEPARAT de reguli, fiindcă nu e o
	# regulă: e pasul lacom de așezare care s-a înfundat și a renunțat. E
	# așteptat să se întâmple des — plasarea e ieftină dinadins, tocmai ca să
	# se poată relua — deci a-l pune în același tabel cu regulile ar fi declanșat
	# avertismentul de conflict pe ceva ce funcționează exact cum trebuie.
	var abandonate := int(picate.get(PLASARE, 0))
	print("")
	print("    %-42s %6d   %5.1f%%  (din %d încercări)" % [
		"aranjări abandonate la plasare", abandonate,
		100.0 * float(abandonate) / float(maxi(incercari_totale, 1)),
		incercari_totale])

	print("")
	print("  DE CÂTE ORI A PICAT FIECARE REGULĂ")
	var doar_reguli := {}
	for nume in picate:
		if String(nume) != PLASARE:
			doar_reguli[nume] = picate[nume]
	if doar_reguli.is_empty():
		print("    niciuna — ce a trecut de plasare a trecut și de reguli")
	var nume_sortate: Array = doar_reguli.keys()
	nume_sortate.sort_custom(func(a, b): return int(doar_reguli[a]) > int(doar_reguli[b]))
	for nume in nume_sortate:
		var cat := int(doar_reguli[nume])
		var fractie := float(cat) / float(maxi(incercari_totale, 1))
		var semn := "  ←  SE CEARTĂ CU ALTCEVA" if fractie > PRAG_INGRIJORARE else ""
		print("    %-42s %6d   %5.1f%%%s" % [nume, cat, fractie * 100.0, semn])
		if fractie > PRAG_INGRIJORARE:
			# NU e un eșec: harta tot iese. E un avertisment de design — regula
			# aia nu mai alege între aranjări, ci le respinge aproape pe toate,
			# iar cine o relaxează trebuie s-o facă în cunoștință de cauză.
			print("        (peste %.0f%% înseamnă că regula se bate cu rețeta sau"
				% (PRAG_INGRIJORARE * 100.0))
			print("        cu altă regulă. Vezi care cedează ÎNAINTE s-o schimbi.)")

	# ── semințele care au atins limita ────────────────────────
	print("")
	bun = _verdict("nicio sămânță n-a atins limita", la_limita.is_empty(),
		"" if la_limita.is_empty() else "%d semințe: %s" % [
			la_limita.size(), _primele(la_limita, 15)]) and bun

	# ── reproductibilitatea ───────────────────────────────────
	bun = _acelasi_de_doua_ori(cale) and bun
	return bun


## Numără nodurile de fiecare tip și compară cu rețeta. Startul și Bossul se
## adaugă la socoteală: rețeta împarte numai ce e între ele.
func _respecta(numarate: Dictionary, ceruta: Dictionary) -> bool:
	for tip in Expeditie.DATE_NOD:
		var are := int(numarate.get(tip, 0))
		var trebuie := int(ceruta.get(tip, 0))
		if tip == Expeditie.Nod.BOSS:
			trebuie = 1
		elif tip == Expeditie.Nod.LUPTA:
			trebuie += 1   # Startul e o Luptă peste rețetă
		if are != trebuie:
			return false
	return true


## O rețetă, scrisă cu nume în loc de numere de enum.
func _ca_reteta(ceruta: Dictionary) -> String:
	var bucati: Array[String] = []
	for rand in Expeditie.PROPORTII:
		bucati.append("%s %d" % [
			Expeditie.DATE_NOD[rand["tip"]]["nume"], int(ceruta.get(rand["tip"], 0))])
	bucati.append("%s %d" % [
		Expeditie.DATE_NOD[Expeditie.Nod.LUPTA]["nume"],
		int(ceruta.get(Expeditie.Nod.LUPTA, 0)) + 1])
	return ", ".join(bucati)


func _verdict(eticheta: String, bun: bool, amanunt := "") -> bool:
	var coada := "" if amanunt == "" else "   %s" % amanunt
	print("    %-42s %s%s" % [eticheta, "OK" if bun else "PICAT", coada])
	return bun


func _primele(lista: Array[int], cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(str(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)


# ─────────────────────────────────────────────────────────────
# REPRODUCTIBILITATEA
# ─────────────────────────────────────────────────────────────

## Aceeași sămânță, generată de două ori, dă aceeași hartă?
##
## Se compară TOT ce se salvează despre fiecare nod, nu doar tipurile: dacă
## bugetul sau sămânța nodului ar sări, hărțile ar arăta la fel și s-ar juca
## diferit — cel mai urât fel de nedeterminism, fiindcă nu se vede.
func _acelasi_de_doua_ori(cale: String) -> bool:
	var diferite: Array[int] = []
	for i in range(SEMINTE):
		var samanta := PRIMA_SAMANTA + i
		var intai := Expeditie.genereaza_harta(samanta, cale)
		var adoua := Expeditie.genereaza_harta(samanta, cale)
		if _ca_text(intai) != _ca_text(adoua):
			diferite.append(samanta)
	return _verdict("aceeași sămânță dă aceeași hartă", diferite.is_empty(),
		"" if diferite.is_empty() else "%d semințe diferă: %s" % [
			diferite.size(), _primele(diferite, 10)])


## O hartă, ca text, pentru comparat. Câmpurile sunt scrise pe nume și în
## ordine, nu lăsate pe seama lui `str(Dictionary)` — ordinea cheilor într-un
## dicționar e o presupunere pe care nu vreau să se sprijine un test.
func _ca_text(harta: Array[Dictionary]) -> String:
	var bucati: Array[String] = []
	for nod in harta:
		bucati.append("%d|%d|%d|%.2f|%d|%s" % [
			int(nod["id"]), int(nod["adancime"]), int(nod["tip"]),
			float(nod["buget"]), int(nod["samanta"]), str(nod["spre"])])
	return "\n".join(bucati)

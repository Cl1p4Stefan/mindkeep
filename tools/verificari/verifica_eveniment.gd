extends Node
## VERIFICAREA EVENIMENTULUI — lacătul pe care ți-l dă harta, nu cel din F6.
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_eveniment.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE ÎNCĂ O UNEALTĂ, PE LÂNGĂ `verifica_cifru.gd`
##
## `verifica_cifru.gd` întreabă dacă LACĂTUL e bun: soluția e unică, nota e cea
## cerută, niciun indiciu nu dictează o cifră. Întrebarea lui e despre generator,
## și e pusă cu niveluri și semințe alese de el.
##
## Unealta asta întreabă cu totul altceva: **ce lacăt îți dă HARTA?** Între
## sămânța unei expediții și `porneste(nivel, samanta)` stau acum trei socoteli
## — adâncimea → nivel, sămânța nodului → sămânța lacătului, nivelul → Monede —
## și toate trei pot fi greșite fără să strice niciun puzzle. Un lacăt perfect
## corect, dar de nivel 3 la al doilea nod al expediției, ar trece verificarea
## cealaltă fără o vorbă.
##
## ─────────────────────────────────────────────────────────────
## CE VERIFICĂ, ȘI DE CE FIECARE
##
##   ACEEAȘI SĂMÂNȚĂ → ACELAȘI LACĂT. Cea mai importantă, fiindcă e promisiunea
##   pe care se sprijină tot restul: o expediție reluată trebuie să dea exact
##   aceleași cufere. Se verifică pe două niveluri — întâi tripleta (nivel,
##   sămânță, Monede) pentru toate Evenimentele de pe multe semințe, apoi
##   PUZZLE-UL ÎNTREG, chemând chiar `GeneratorCifru.genereaza()` de două ori pe
##   câteva noduri. A doua e scumpă (un lacăt de nivel 3 costă peste o secundă),
##   de-aia se face pe un eșantion mic; prima e ieftină și acoperă tot.
##
##   MARGINILE TREIMILOR. `nivel_lacat()` e o funcție pură de două numere, deci
##   se poate proba pe adâncimi INVENTATE, fără nicio hartă. Verificarea asta e
##   plasa pusă pentru ziua în care desenezi o planșă mai lungă: dacă formula
##   încetează să împartă drumul în treimi, afli aici, nu după zece partide în
##   care lacătele s-au simțit ciudat.
##
##   APAR TOATE TREI NIVELURILE. Un nivel care nu iese niciodată în practică e
##   cod mort, iar cel mai expus e NIVELUL 1 — singurul cu o roată sudată, adică
##   singurul care te învață ce e un lacăt. Pe planșele de azi Evenimentele nu
##   pot cădea la adâncimea 1 (vecinii Startului sunt Lupte), deci nivelul 1
##   depinde de o singură bandă de adâncime. Dacă histograma de mai jos arată
##   zero pe un nivel, marginile din `nivel_lacat()` sunt de mutat.
##
##   CÂTE EVENIMENTE ARE O EXPEDIȚIE. Rețeta le dă „minim 0” (vezi `PROPORTII`),
##   deci o hartă fără niciun cufăr e legală. Dacă media iese aproape de zero,
##   toată socoteala cu Monedele e despre ceva ce nu se întâmplă.
##
##   NIVELUL CERUT E UN NIVEL CARE EXISTĂ. `GeneratorCifru.specificatie()`
##   strânge orice nivel în intervalul lui, deci un „nivel 7" n-ar crăpa — ar da
##   în tăcere cel mai greu lacăt din joc. De-aia se verifică aici, unde se
##   NAȘTE numărul, nu acolo unde e primit.
##
## Ce NU verifică: nimic despre puzzle-ul propriu-zis (unicitate, notă, indicii
## redundante). Alea sunt în `verifica_cifru.gd`, și n-au ce căuta în două
## locuri — două verificări ale aceleiași reguli se despart într-o zi.


## Câte semințe de expediție se bat. Ieftin: nu se generează niciun puzzle aici,
## doar hărți.
const SEMINTE := 200

## De la ce sămânță pornim. Nu de la 0, din același motiv ca la celelalte
## unelte: sub-semințele se obțin prin înmulțire, iar zero înmulțit rămâne zero.
const PRIMA_SAMANTA := 1000

## Câte lacăte se generează CHIAR, ca puzzle, ca să se compare de două ori.
## Trei, nu trei sute: un lacăt de nivel 3 costă peste o secundă, iar întrebarea
## („iese același puzzle din aceeași sămânță?") are același răspuns la a treia ca
## la a trei suta. Unicitatea și nota sunt treaba lui `verifica_cifru.gd`.
const LACATE_GENERATE := 3


func _ready() -> void:
	print("VERIFICAREA EVENIMENTULUI (lacătul nodului de Eveniment)")
	print("Semințe: %d, pornind de la %d." % [SEMINTE, PRIMA_SAMANTA])

	var toate_bune := true
	toate_bune = _marginile_treimilor() and toate_bune
	for cale in _surse():
		toate_bune = _verifica(cale) and toate_bune
	toate_bune = _acelasi_puzzle_de_doua_ori() and toate_bune

	print("")
	print("═══════════════════════════════════════════")
	print("VERDICT: %s" % [
		"evenimentul dă lacătele promise" if toate_bune else "CEVA E STRICAT"])
	get_tree().quit(0 if toate_bune else 1)


## Ce hărți se verifică: toate planșele din dosar, PLUS harta generată.
## Aceeași listă ca la `verifica_tipuri.gd`, și din același motiv: generata e
## rezerva pe care cade jocul dacă o planșă se strică.
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
# MARGINILE TREIMILOR
#
# Se probează pe adâncimi INVENTATE, nu pe hărți. `nivel_lacat()` e o funcție
# pură de două numere întregi — e exact genul de lucru care se poate verifica
# exhaustiv, deci se verifică exhaustiv.
#
# Tabelul de mai jos e scris cu MÂNA, dinadins. Dacă l-aș calcula cu aceeași
# formulă pe care o verific, aș verifica doar că 3 × 2 face tot 6 de două ori.
# Un test trebuie să știe răspunsul din altă parte decât codul testat.
# ─────────────────────────────────────────────────────────────

## `[adâncimea Bossului, [nivelul așteptat la adâncimea 0, 1, 2, …]]`.
##
## Trei lungimi de drum: planșele de azi (Boss la 6), o hartă lungă (8) și una
## scurtă (4), fiindcă marginile se pot strica doar la un capăt.
const TREIMI := [
	[6, [1, 1, 1, 2, 3, 3, 3]],
	[8, [1, 1, 1, 2, 2, 2, 3, 3, 3]],
	[4, [1, 1, 2, 3, 3]],
]


func _marginile_treimilor() -> bool:
	print("")
	print("═══ marginile treimilor (fără nicio hartă) ═══")

	var toate_bune := true
	for rand in TREIMI:
		var boss := int(rand[0])
		var asteptate: Array = rand[1]
		var gresite: Array[String] = []
		for adancime in range(asteptate.size()):
			var iesit := Expeditie.nivel_lacat(adancime, boss)
			if iesit != int(asteptate[adancime]):
				gresite.append("adâncimea %d: %d în loc de %d" % [
					adancime, iesit, int(asteptate[adancime])])
		toate_bune = _verdict("Bossul la %d" % boss, gresite.is_empty(),
			", ".join(gresite)) and toate_bune

	# O hartă fără Boss nu are „fracțiune de drum". Nu ghicim și nu crăpăm: cel
	# mai blând nivel. Verificat fiindcă e ramura pe care n-o va atinge nicio
	# partidă, deci singura care se poate strica în tăcere.
	toate_bune = _verdict("hartă fără Boss → nivelul 1",
		Expeditie.nivel_lacat(3, 0) == 1 and Expeditie.nivel_lacat(0, -1) == 1
	) and toate_bune
	return toate_bune


# ─────────────────────────────────────────────────────────────
# O SURSĂ DE HARTĂ, PE TOATE SEMINȚELE
# ─────────────────────────────────────────────────────────────

func _verifica(cale: String) -> bool:
	print("")
	print("═══ %s ═══" % _nume(cale))

	# Nivel → de câte ori a apărut, peste toate semințele.
	var pe_nivel := {1: 0, 2: 0, 3: 0}
	# Câte Evenimente are fiecare expediție, ca să pot scoate media și minimul.
	var cate_evenimente: Array[int] = []
	# Semințele la care ceva nu s-a legat.
	var nereproductibile: Array[int] = []
	var nivel_inexistent: Array[int] = []
	var plata_gresita: Array[int] = []
	var samanta_stricata: Array[int] = []

	for i in range(SEMINTE):
		var samanta := PRIMA_SAMANTA + i
		var harta := Expeditie.genereaza_harta(samanta, cale)
		var adoua := Expeditie.genereaza_harta(samanta, cale)

		var fise := _lacatele(harta)
		if _ca_text(fise) != _ca_text(_lacatele(adoua)):
			nereproductibile.append(samanta)

		cate_evenimente.append(fise.size())
		for fisa in fise:
			var nivel := int(fisa["nivel"])
			if not pe_nivel.has(nivel):
				# Un nivel în afara tabelului. `specificatie()` l-ar strânge în
				# tăcere la cel mai apropiat, deci fără verificarea asta ai fi
				# jucat lacăte de nivel 3 crezând că sunt de 5.
				nivel_inexistent.append(samanta)
				continue
			pe_nivel[nivel] = int(pe_nivel[nivel]) + 1

			if int(fisa["monede"]) != int(Expeditie.LACAT[nivel - 1]["monede"]):
				plata_gresita.append(samanta)

			# O sămânță de puzzle trebuie să fie un număr pozitiv: `rng.seed`
			# primește orice, dar `_sub_samanta()` înmulțește, iar zero
			# înmulțit rămâne zero — toate încercările ar porni din același loc.
			if int(fisa["samanta"]) <= 0:
				samanta_stricata.append(samanta)

	var toate_bune := true
	toate_bune = _verdict("aceeași sămânță dă aceleași lacăte",
		nereproductibile.is_empty(),
		"" if nereproductibile.is_empty() else "%d semințe diferă: %s" % [
			nereproductibile.size(), _primele(nereproductibile, 10)]
	) and toate_bune
	toate_bune = _verdict("nivelul cerut există în tabel",
		nivel_inexistent.is_empty(), _primele(nivel_inexistent, 10)) and toate_bune
	toate_bune = _verdict("plata e cea din tabel",
		plata_gresita.is_empty(), _primele(plata_gresita, 10)) and toate_bune
	toate_bune = _verdict("sămânța lacătului e pozitivă",
		samanta_stricata.is_empty(), _primele(samanta_stricata, 10)) and toate_bune

	var total := int(pe_nivel[1]) + int(pe_nivel[2]) + int(pe_nivel[3])
	toate_bune = _verdict("apar toate trei nivelurile",
		pe_nivel[1] > 0 and pe_nivel[2] > 0 and pe_nivel[3] > 0,
		"nivel 1: %d · nivel 2: %d · nivel 3: %d" % [
			pe_nivel[1], pe_nivel[2], pe_nivel[3]]
	) and toate_bune

	# Rapoarte, nu verdicte: cifrele de mai jos nu pot fi „greșite", dar sunt
	# ce te ajută să reglezi plata după primele partide jucate.
	var suma := 0
	var minim := 99
	var fara := 0
	for cate in cate_evenimente:
		suma += cate
		minim = mini(minim, cate)
		if cate == 0:
			fara += 1
	print("    %-42s %.2f (minim %d; %d hărți fără niciun cufăr)" % [
		"Evenimente pe expediție, media", float(suma) / maxi(cate_evenimente.size(), 1),
		minim, fara])
	if total > 0:
		var plata_totala := 0
		for nivel in [1, 2, 3]:
			plata_totala += int(pe_nivel[nivel]) * int(Expeditie.LACAT[nivel - 1]["monede"])
		print("    %-42s %.1f Monede" % [
			"dacă le deschizi pe toate, o expediție",
			float(plata_totala) / maxi(cate_evenimente.size(), 1)])
	return toate_bune


## Fișele lacătelor de pe o hartă, în ordinea nodurilor.
##
## Nu trece prin `Expeditie.lacat_la()`, fiindcă aia citește harta CURENTĂ, iar
## aici avem una proaspătă care nu e a nimănui — exact despărțirea pentru care
## există `vecinii_din()` alături de `vecini()`. Socoteala rămâne totuși a
## expediției: `nivel_lacat()` și `LACAT` sunt chemate, nu copiate.
func _lacatele(harta: Array[Dictionary]) -> Array[Dictionary]:
	var adancime_boss := 0
	for nod in harta:
		if int(nod["tip"]) == Expeditie.Nod.BOSS:
			adancime_boss = int(nod["adancime"])

	var fise: Array[Dictionary] = []
	for nod in harta:
		if int(nod["tip"]) != Expeditie.Nod.EVENIMENT:
			continue
		var nivel := Expeditie.nivel_lacat(int(nod["adancime"]), adancime_boss)
		fise.append({
			"id": int(nod["id"]),
			"adancime": int(nod["adancime"]),
			"nivel": nivel,
			"samanta": int(nod["samanta"]) * Expeditie.AMESTEC_LACAT + Expeditie.ADAOS_LACAT,
			"monede": int(Expeditie.LACAT[nivel - 1]["monede"]),
		})
	return fise


## Fișele ca text, pentru comparat. Câmpurile pe nume și în ordine, nu
## `str(Dictionary)`: ordinea cheilor într-un dicționar e o presupunere pe care
## nu vreau să se sprijine un test.
func _ca_text(fise: Array[Dictionary]) -> String:
	var bucati: Array[String] = []
	for f in fise:
		bucati.append("%d|%d|%d|%d|%d" % [
			int(f["id"]), int(f["adancime"]), int(f["nivel"]),
			int(f["samanta"]), int(f["monede"])])
	return "\n".join(bucati)


# ─────────────────────────────────────────────────────────────
# PUZZLE-UL ÎNTREG, DE DOUĂ ORI
#
# Verificările de mai sus compară NUMERELE care ajung la `porneste()`. Asta e
# aproape tot — dar „aproape" nu e ce promite harta. Promisiunea e că vezi
# același cufăr, cu aceleași indicii, pe aceeași cifre.
#
# Deci se cheamă chiar generatorul, de două ori, pe lacăte luate din hărți
# adevărate, și se compară puzzle-urile prin JSON. Comparația prin JSON verifică
# pe gratis și altceva: că tot puzzle-ul încape în tipuri simple, adică e
# salvabil fără traducător (regula din `CLAUDE.md`).
# ─────────────────────────────────────────────────────────────

func _acelasi_puzzle_de_doua_ori() -> bool:
	print("")
	print("═══ puzzle-ul întreg, generat de două ori ═══")

	# Un lacăt din fiecare nivel, dacă hărțile dau atâtea. Nivelurile sunt cele
	# scumpe de verificat și cele care se pot strica altfel: nivelul 1 are o
	# roată sudată, nivelul 3 o limită de egalități.
	var alese := {}
	var samanta := PRIMA_SAMANTA
	while alese.size() < LACATE_GENERATE and samanta < PRIMA_SAMANTA + SEMINTE:
		# Planșa implicită, nu cea aleasă de `SURSA_HARTII`: aici nu contează pe
		# ce formă de hartă cad lacătele, ci că un nivel și o sămânță ieșite
		# dintr-un nod ADEVĂRAT dau de două ori același puzzle.
		for fisa in _lacatele(Expeditie.genereaza_harta(samanta, Expeditie.PLANSA_IMPLICITA)):
			if not alese.has(int(fisa["nivel"])):
				alese[int(fisa["nivel"])] = fisa
		samanta += 1

	if alese.is_empty():
		return _verdict("există lacăte de generat", false,
			"niciun Eveniment pe primele %d semințe" % SEMINTE)

	var toate_bune := true
	for nivel in alese:
		var fisa: Dictionary = alese[nivel]
		var pornit := Time.get_ticks_msec()
		var intai := GeneratorCifru.genereaza(int(fisa["nivel"]), int(fisa["samanta"]))
		var durata := Time.get_ticks_msec() - pornit
		var adoua := GeneratorCifru.genereaza(int(fisa["nivel"]), int(fisa["samanta"]))

		var acelasi := JSON.stringify(intai) == JSON.stringify(adoua)
		var amanunt := "%d indicii, %d ms" % [
			intai.get("indicii", []).size(), durata]
		if not acelasi:
			amanunt = "puzzle-urile diferă"
		toate_bune = _verdict("nivel %d (nodul %d, adâncimea %d)" % [
			int(fisa["nivel"]), int(fisa["id"]), int(fisa["adancime"])],
			acelasi and not intai.is_empty(), amanunt) and toate_bune
	return toate_bune


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


func _primele(lista: Array[int], cate: int) -> String:
	var bucati: Array[String] = []
	for i in range(mini(cate, lista.size())):
		bucati.append(str(lista[i]))
	if lista.size() > cate:
		bucati.append("…")
	return ", ".join(bucati)

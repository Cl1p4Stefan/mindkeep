extends Node
## VERIFICAREA DRUMURILOR — se poate înfunda o expediție?
##
## Se cheamă din afara jocului, fără fereastră:
##   godot --headless --path . res://tools/verificari/verifica_drumuri.tscn
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ FIȘIERUL ĂSTA
##
## Cât timp harta mergea într-un singur sens, întrebarea „mă pot înfunda?” avea
## un răspuns structural: nu, fiindcă fiecare pas te ducea mai aproape de capăt
## și niciun drum nu se întorcea. Regula nouă — un drum se poate merge în
## amândouă sensurile, dar un nod parcurs e tăiat definitiv — strică fix
## demonstrația aia. Acum te poți băga într-un braț al hărții a cărui singură
## ieșire e chiar nodul pe care tocmai l-ai ars.
##
## Iar o înfundare NU se poate repara la fața locului: când bagi de seamă că
## n-ai unde merge, mutarea greșită e cu cinci noduri în urmă. Deci nu e destul
## să știu că se întâmplă rar — trebuie să nu se poată întâmpla.
##
## Apărarea e în `Expeditie.accesibile()`: un vecin e ofertă doar dacă DIN EL se
## mai ajunge la Boss ocolind nodurile parcurse. Fișierul ăsta nu presupune că
## apărarea e corectă: joacă expediții întregi cu alegeri la întâmplare și se
## uită dacă rămâne vreodată fără opțiuni înainte de Boss.
##
## ─────────────────────────────────────────────────────────────
## CE SE JOACĂ
##
##   (1) PLANȘELE REALE din `data/harti/` — hărțile pe care se joacă efectiv.
##   (2) HĂRȚI GENERATE, semințe la rând — cealaltă sursă de hartă.
##   (3) GRAFURI LA ÎNTÂMPLARE, construite aici. Astea contează cel mai mult:
##       planșele de azi sunt două, iar o regulă care merge pe două hărți nu e
##       verificată, ci doar n-a fost prinsă încă. Grafurile aleatoare au brațe
##       oarbe, scurtături și noduri cu multe intrări — adică fix formele care
##       pot închide o ieșire în urma ta.
##
## Fiecare hartă se joacă de două ori, cu DOUĂ REGULI diferite, și comparația
## dintre ele e tot rostul raportului:
##
##   CU PLASĂ    — regula din joc, cu tot cu verificarea „mai ajung la Boss?”.
##                 Aici înfundările trebuie să fie ZERO. Orice altceva e un bug.
##   FĂRĂ PLASĂ  — doar „vecin nevizitat”, adică ce ar fi ieșit dacă aș fi
##                 implementat mersul în ambele sensuri fără să mă mai gândesc.
##                 Aici înfundările sunt de așteptat, și numărul lor e singurul
##                 lucru care arată cât de necesară era plasa.
##
## Pe lângă înfundări se verifică, la fiecare pas, patru lucruri care trebuie să
## fie adevărate prin construcție (vezi `_joaca`) — dacă vreunul cade, greșeala
## nu e în plasă, ci mai jos.

const Plansa := preload("res://scenes/harta/plansa.gd")

## Câte expediții se joacă pe fiecare familie de hărți. „Câteva mii” înseamnă
## aici vreo douăzeci de mii cu totul: destul cât alegerile la întâmplare să
## treacă prin toate combinațiile de brațe ale unei hărți cu paisprezece noduri.
const RULARI_PE_PLANSA := 3000
const RULARI_GENERATE := 4000
const RULARI_ALEATOARE := 6000

## Câte hărți generate diferite se ating (semințe la rând, de la 1).
const SEMINTE_GENERATE := 200

## Mărimea grafurilor construite aici. Marginea de jos e mică dinadins: o hartă
## de patru noduri e locul în care o regulă greșită se vede imediat.
const NODURI_MIN := 4
const NODURI_MAX := 22

## Un pas în plus peste orice hartă cu putință, ca o expediție care s-ar învârti
## în cerc din cauza unui bug să se oprească cu un mesaj, nu să înghețe.
const PASI_MAXIMI := 200

enum Regula { CU_PLASA, FARA_PLASA }


func _ready() -> void:
	print("VERIFICAREA DRUMURILOR — se poate înfunda o expediție?")
	print("Regula: un drum merge în amândouă sensurile; un nod parcurs e tăiat.")
	print("")

	var bun := true
	bun = _verifica_planse() and bun
	bun = _verifica_generate() and bun
	bun = _verifica_aleatoare() and bun

	print("")
	if bun:
		print("TOTUL E BINE: nicio înfundare cu regula din joc.")
	else:
		print("PICAT: vezi mai sus.")
	get_tree().quit(0 if bun else 1)


# ─────────────────────────────────────────────────────────────
# CELE TREI FAMILII DE HĂRȚI
# ─────────────────────────────────────────────────────────────

func _verifica_planse() -> bool:
	var cai: Array[String] = []
	for nume in DirAccess.get_files_at(Plansa.DOSAR):
		if nume.get_extension().to_lower() == "json":
			cai.append(Plansa.DOSAR + nume)
	cai.sort()

	if cai.is_empty():
		print("(1) PLANȘE DESENATE: niciun fișier în %s — sărit." % Plansa.DOSAR)
		return true

	var bun := true
	for cale in cai:
		var harti: Array[Array] = []
		# Fiecare sămânță dă ALT CONȚINUT pe aceeași formă. Forma e ce ne
		# interesează aici, deci ajung câteva semințe — dar nu una singură:
		# `_asigura_magazin()` poate schimba tipul unui nod, iar tipul hotărăște
		# unde e Bossul, deci și unde se termină drumul.
		for i in range(8):
			harti.append(Expeditie.genereaza_harta(100 + i, cale))
		bun = _raporteaza(
			"(1) PLANȘA %s" % cale.get_file(), harti, RULARI_PE_PLANSA) and bun
	return bun


func _verifica_generate() -> bool:
	var harti: Array[Array] = []
	for i in range(SEMINTE_GENERATE):
		harti.append(Expeditie.genereaza_harta(1 + i))
	return _raporteaza(
		"(2) HĂRȚI GENERATE (%d semințe)" % SEMINTE_GENERATE,
		harti, RULARI_GENERATE)


func _verifica_aleatoare() -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260923   # fix, ca o picătură să fie reproductibilă
	var harti: Array[Array] = []
	for i in range(400):
		harti.append(_graf_la_intamplare(rng))
	return _raporteaza(
		"(3) GRAFURI LA ÎNTÂMPLARE (%d forme)" % harti.size(),
		harti, RULARI_ALEATOARE)


# ─────────────────────────────────────────────────────────────
# JOCUL PROPRIU-ZIS
# ─────────────────────────────────────────────────────────────

## Joacă `rulari` expediții pe hărțile date, cu amândouă regulile, și scrie
## verdictul. Întoarce `false` dacă regula DIN JOC s-a înfundat măcar o dată.
func _raporteaza(titlu: String, harti: Array[Array], rulari: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242

	var cu := _serie(rng, harti, rulari, Regula.CU_PLASA)
	var fara := _serie(rng, harti, rulari, Regula.FARA_PLASA)

	var bun: bool = int(cu["infundari"]) == 0 and String(cu["stricat"]) == ""
	print("%s  —  %s" % [titlu, "OK" if bun else "PICAT"])
	print("    cu plasă (regula din joc): %d înfundări din %d rulări  ·  drum de %d–%d noduri, în medie %.1f"
		% [int(cu["infundari"]), rulari,
			int(cu["min"]), int(cu["max"]), float(cu["medie"])])
	print("    fără plasă (doar „vecin nevizitat”): %d înfundări din %d rulări  (%.0f%%)"
		% [int(fara["infundari"]), rulari,
			100.0 * float(fara["infundari"]) / float(maxi(rulari, 1))])
	if String(cu["stricat"]) != "":
		print("    INVARIANT CĂZUT: %s" % cu["stricat"])
	if int(cu["infundari"]) > 0:
		print("    PRIMA ÎNFUNDARE: %s" % cu["exemplu"])
	return bun


func _serie(
	rng: RandomNumberGenerator, harti: Array[Array], rulari: int, regula: Regula
) -> Dictionary:
	var infundari := 0
	var exemplu := ""
	var stricat := ""
	var suma := 0
	var cel_mai_scurt := 99999
	var cel_mai_lung := 0

	for i in range(rulari):
		var harta: Array = harti[rng.randi_range(0, harti.size() - 1)]
		var rezultat := _joaca(rng, harta, regula)
		if String(rezultat["stricat"]) != "" and stricat == "":
			stricat = String(rezultat["stricat"])
		if bool(rezultat["infundat"]):
			infundari += 1
			if exemplu == "":
				exemplu = "drumul %s, iar de acolo nicio ieșire" % str(rezultat["drum"])
		else:
			var lungime := int(rezultat["pasi"])
			suma += lungime
			cel_mai_scurt = mini(cel_mai_scurt, lungime)
			cel_mai_lung = maxi(cel_mai_lung, lungime)

	var reusite := rulari - infundari
	return {
		"infundari": infundari,
		"exemplu": exemplu,
		"stricat": stricat,
		"min": cel_mai_scurt if reusite > 0 else 0,
		"max": cel_mai_lung,
		"medie": float(suma) / float(maxi(reusite, 1)),
	}


## O EXPEDIȚIE ÎNTREAGĂ, cu alegeri la întâmplare.
##
## Nu simulează regulile, ci le FOLOSEȘTE: pune harta în `Expeditie` și cheamă
## `accesibile()` și `intra_in_nod()`, exact cum face ecranul hărții când apeși
## pe un nod. Dacă mâine cineva schimbă regula din joc, verificarea asta o
## urmează singură — o simulare care și-ar fi scris propriul `accesibile()` ar
## fi verificat o copie, adică nimic.
##
## Pe lângă înfundare se cer patru lucruri la fiecare pas. Nu sunt „încă niște
## teste”, ci exact presupunerile pe care se sprijină regula:
##
##   (a) nicio opțiune nu e un nod deja parcurs — altfel „tăiat definitiv” e o
##       vorbă goală și te poți plimba în cerc;
##   (b) fiecare opțiune chiar e legată de nodul curent, într-unul din sensuri;
##   (c) drumul până la Boss, socotit din nodul curent, e un număr real —
##       adică antetul hărții nu poate ajunge să scrie „la cel puțin 0 pași”
##       stând în mijlocul hărții;
##   (d) expediția se termină LA BOSS, nu oriunde s-a nimerit să nu mai fie
##       ieșiri.
func _joaca(
	rng: RandomNumberGenerator, harta: Array, regula: Regula
) -> Dictionary:
	var noduri: Array[Dictionary] = []
	for nod in harta:
		noduri.append(nod)
	Expeditie.harta = noduri
	Expeditie.pozitie = -1
	Expeditie.parcurse = []

	var stricat := ""
	var drum: Array[int] = []

	for pas in range(PASI_MAXIMI):
		# Capătul se citește DIN REGULA CARE SE JOACĂ, nu din `la_capat()`.
		# Altfel rularea „fără plasă" s-ar opri politicos exact acolo unde ar
		# trebui să se înfunde — `la_capat()` întreabă `accesibile()`, adică
		# tocmai plasa pe care rularea aia se preface că n-o are — iar martorul
		# ar raporta zero înfundări, oricât de greșită ar fi regula lui.
		var la_boss := Expeditie.pozitie >= 0 \
			and int(Expeditie.nod_curent().get("tip", -1)) == Expeditie.Nod.BOSS
		if la_boss:
			if regula == Regula.CU_PLASA and not Expeditie.la_capat():
				stricat = "(d) ești la Boss, dar `la_capat()` spune că nu"
			return {"infundat": false, "pasi": drum.size(), "drum": drum,
				"stricat": stricat}

		var optiuni := _optiuni(regula)
		if optiuni.is_empty():
			return {"infundat": true, "pasi": drum.size(), "drum": drum,
				"stricat": stricat}

		if stricat == "":
			stricat = _verifica_optiunile(optiuni)

		var ales: int = optiuni[rng.randi_range(0, optiuni.size() - 1)]
		Expeditie.intra_in_nod(ales)
		drum.append(ales)

	return {"infundat": false, "pasi": drum.size(), "drum": drum,
		"stricat": "expediția n-a ajuns la capăt în %d pași — se învârte în cerc?"
			% PASI_MAXIMI}


## Ce oferă fiecare din cele două reguli.
##
## CU_PLASA e chiar funcția din joc. FARA_PLASA e scrisă aici, și e singurul loc
## din fișier în care se rescrie o regulă — dinadins: e regula care NU există în
## joc, ținută ca martor. Fără ea n-aș avea cu ce compara, și „zero înfundări”
## ar putea la fel de bine să însemne că harta n-avea cum să se înfunde.
func _optiuni(regula: Regula) -> Array[int]:
	if regula == Regula.CU_PLASA:
		return Expeditie.accesibile()

	var lista: Array[int] = []
	if Expeditie.pozitie < 0:
		for nod in Expeditie.harta:
			if int(nod["adancime"]) == 0:
				lista.append(int(nod["id"]))
		return lista
	if int(Expeditie.nod_curent().get("tip", -1)) == Expeditie.Nod.BOSS:
		return lista
	for id in Expeditie.vecini(Expeditie.pozitie):
		if not id in Expeditie.parcurse:
			lista.append(id)
	return lista


func _verifica_optiunile(optiuni: Array[int]) -> String:
	if Expeditie.pozitie < 0:
		return ""
	for id in optiuni:
		if id in Expeditie.parcurse:
			return "(a) nodul %d e oferit deși e deja parcurs" % id
		if not id in Expeditie.vecini(Expeditie.pozitie):
			return "(b) nodul %d e oferit deși nu e legat de %d" \
				% [id, Expeditie.pozitie]
	if int(Expeditie.nod_curent().get("tip", -1)) != Expeditie.Nod.BOSS \
			and Expeditie.pasi_pana_la_boss() <= 0:
		return "(c) din nodul %d antetul ar scrie că Bossul e la 0 pași" \
			% Expeditie.pozitie
	return ""


# ─────────────────────────────────────────────────────────────
# GRAFURI LA ÎNTÂMPLARE
#
# Se construiesc cu aceleași garanții pe care le cere `verifica_plansa.gd` de la
# o planșă desenată de mână — altfel aș verifica regula pe hărți pe care jocul
# le-ar refuza oricum, iar o înfundare găsită acolo n-ar însemna nimic:
#
#   fără cicluri          — nodurile se leagă doar de la indice mic la mare;
#   totul se atinge din Start — fiecare nod (afară de 0) primește un părinte;
#   din orice nod se ajunge la Boss — fiecare nod (afară de ultimul) primește
#                           un copil, iar copilul are indicele mai mare, deci
#                           lanțul urcă până la ultimul nod prin inducție;
#   un singur Start, un singur Boss.
#
# Peste scheletul ăsta se toarnă muchii în plus, la întâmplare: ele sunt cele
# care fac brațe oarbe și scurtături, adică singurele forme în care mersul
# înapoi poate închide o ieșire.
# ─────────────────────────────────────────────────────────────

func _graf_la_intamplare(rng: RandomNumberGenerator) -> Array:
	var cate := rng.randi_range(NODURI_MIN, NODURI_MAX)
	var spre := []
	for i in range(cate):
		spre.append([])

	# Un părinte pentru fiecare nod în afară de Start.
	for i in range(1, cate):
		var parinte := rng.randi_range(0, i - 1)
		spre[parinte].append(i)

	# Un copil pentru fiecare nod în afară de Boss.
	for i in range(cate - 1):
		if spre[i].is_empty():
			spre[i].append(rng.randi_range(i + 1, cate - 1))

	# Muchii în plus: cam una la două noduri, tot de la mic la mare.
	for i in range(cate / 2):
		var de_la := rng.randi_range(0, cate - 2)
		var la := rng.randi_range(de_la + 1, cate - 1)
		if not la in spre[de_la]:
			spre[de_la].append(la)

	# Adâncimile, ca pe o planșă: cea mai scurtă distanță de la Start, pe
	# muchii orientate. `accesibile()` le folosește ca să știe care e intrarea.
	var adanc := {0: 0}
	var coada: Array[int] = [0]
	var i_coada := 0
	while i_coada < coada.size():
		var aici: int = coada[i_coada]
		i_coada += 1
		for urmator in spre[aici]:
			if not adanc.has(urmator):
				adanc[urmator] = int(adanc[aici]) + 1
				coada.append(urmator)

	var harta: Array[Dictionary] = []
	for i in range(cate):
		var lista: Array = spre[i]
		lista.sort()
		harta.append({
			"id": i,
			"adancime": int(adanc.get(i, 0)),
			"coloana": 0,
			"tip": Expeditie.Nod.BOSS if i == cate - 1 else Expeditie.Nod.LUPTA,
			"buget": 1.0,
			"samanta": rng.randi_range(1, 999999),
			"spre": lista,
		})
	return harta

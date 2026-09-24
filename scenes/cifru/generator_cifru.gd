class_name GeneratorCifru
extends RefCounted
## GENERATORUL DE CIFRURI — creierul „Lacătului", fără niciun pixel.
##
## Fișierul ăsta nu are noduri, nu desenează nimic și nu poate fi pus într-o
## scenă. E o CUTIE DE FUNCȚII STATICE: îi ceri un puzzle, îți dă un puzzle.
##
## ─────────────────────────────────────────────────────────────
## DE CE E SEPARAT DE SCENĂ
##
## Aceeași regulă ca peste tot în proiect: cine CALCULEAZĂ nu desenează, cine
## desenează nu calculează. Aici nu e doar curățenie, sunt trei lucruri
## concrete:
##
##   1. Verificatorul din `tools/verifica_cifru.gd` poate bate generatorul pe
##      1500 de puzzle-uri fără fereastră, fără sunet, fără să construiască un
##      singur `Control`. Un generator lipit de scenă n-ar putea fi verificat
##      decât pornind jocul și jucând.
##   2. Mai târziu, un tipar `CIFRU` din `logica.gd` poate folosi EXACT aceste
##      funcții ca să nască o întrebare de luptă, fără să instanțieze scena.
##   3. Logica pură se poate citi de sus în jos ca un raționament. Când vei
##      vrea, peste un an, să afli de ce un puzzle a ieșit greu, citești un
##      fișier, nu un fișier plus un arbore de noduri.
##
## ─────────────────────────────────────────────────────────────
## CE ÎNTOARCE (și de ce arată așa)
##
## Un `Dictionary` cu tipuri SIMPLE — numere, șiruri, `Array`, `Dictionary`.
## Niciun `Vector2`, niciun `Color`, niciun obiect. E regula de save din
## CLAUDE.md: tot ce e stare trebuie să treacă prin JSON fără traducător, iar
## un cifru început, dar neterminat, trebuie să poată sta într-un save.
##
## De-aia nici TEXTELE indiciilor nu sunt în puzzle: un indiciu e
## `{"tip": "RELATIE", "a": 0, "b": 2, "semn": ">"}`, iar propoziția „A e mai
## mare decât C" se compune la afișare, cu `text()`. Textul e ÎNFĂȚIȘARE.
## Dacă ar fi salvat, în ziua în care schimbi o formulare (sau traduci jocul)
## save-urile vechi ar purta propozițiile vechi pe veci.
##
## ─────────────────────────────────────────────────────────────
## CUM SE CITEȘTE ALGORITMUL, PE SCURT
##
## „Deduci un cod din indicii" înseamnă, pentru un calculator, exact asta:
## există o mulțime de coduri posibile, fiecare indiciu o TAIE, iar puzzle-ul
## e bun când ce rămâne e un singur cod. Tot fișierul e despre tăierea aia.
##
##   1. Alege un cod la întâmplare — ăsta e răspunsul.
##   2. Fabrică o grămadă de afirmații ADEVĂRATE despre el (candidații).
##   3. Alege lacom dintre ele: la fiecare pas, pe cea care taie cel mai mult.
##   4. Curăță: scoate indiciile care, între timp, au ajuns să nu mai conteze.
##   5. Dacă au ieșit prea multe ca să încapă pe ecran, ia-o de la capăt cu
##      altă sub-sămânță.
##
## Pașii 3 și 4 merită fiecare explicația lui; sunt mai jos, la locul lor.


# ─────────────────────────────────────────────────────────────
# DIFICULTATEA, CA TABEL
# ─────────────────────────────────────────────────────────────
## Un rând pe nivel. Nivelul 4 trebuie să fie un rând nou aici, nu un `if` nou
## în cod — e aceeași regulă ca la discipline („un rând în tabel, nu o ramură
## nouă"), fiindcă dificultatea unui cifru are exact patru numere:
##
##   `cifre`          — câte roți are lacătul;
##   `minim`, `maxim` — ce cifre are fiecare roată (INCLUSIV amândouă capetele);
##   `indicii_maxime` — câte rânduri de indicii încap pe ecran fără să devină
##                      o pagină de citit. E o limită de ECRAN și de răbdare,
##                      nu una matematică: generatorul reîncearcă până intră
##                      sub ea (vezi `genereaza()`).
##
## De ce saltul de la 6 la 9 abia la nivelul 3: numărul de coduri posibile sare
## de la 1296 (6⁴) la 10000 (10⁴). Nu e „un pic mai greu", e de opt ori mai
## mult spațiu de eliminat — deci și un indiciu în plus de ținut în cap.
const NIVELURI := [
	{"cifre": 3, "minim": 1, "maxim": 6, "indicii_maxime": 4},
	{"cifre": 4, "minim": 1, "maxim": 6, "indicii_maxime": 5},
	{"cifre": 4, "minim": 0, "maxim": 9, "indicii_maxime": 6},
]

## Numele roților, în ordine. Jucătorul nu vede „poziția 0" — vede „A".
## Indiciile vorbesc despre litere, roțile poartă aceleași litere, iar codul
## intern rămâne pe indici de la zero. O singură traducere, într-un singur loc.
const LITERE := "ABCDEFGH"

## CÂȚI CANDIDAȚI INTRĂ ÎN CONCURS la o încercare.
##
## Generatorul fabrică o grămadă de afirmații adevărate (30-45, după cod), dar
## alege lacom doar dintr-un EȘANTION de mărimea asta. Două motive, amândouă
## importante:
##
##   VARIETATEA. Alegerea lacomă e deterministă: dintre aceiași candidați,
##   alege mereu la fel. Dacă i-aș da toată grămada, „suma tuturor cifrelor e
##   exact 14" (indiciul care taie cel mai brutal) ar fi primul indiciu în
##   aproape fiecare puzzle din joc. Eșantionul îl face să apară uneori, nu
##   mereu — iar puzzle-urile nu mai seamănă între ele.
##
##   TIMPUL. Prima rundă a alegerii lacome întreabă fiecare candidat despre
##   fiecare cod încă posibil: 20 × 10000 la nivelul 3. Cu 45 de candidați,
##   verificatorul de 1500 de puzzle-uri ar dura de două ori mai mult fără să
##   producă puzzle-uri mai bune.
const CANDIDATI := 20

## De câte ori reîncercăm până ne dăm bătuți.
##
## O încercare poate să nu iasă din două motive cinstite: eșantionul de
## candidați nu conține destulă informație cât să izoleze un singur cod, sau
## izolează, dar cu prea multe indicii. Amândouă se rezolvă cu alt eșantion,
## deci cu altă sub-sămânță.
##
## 30 e generos față de ce s-a măsurat (vezi `tools/verifica_cifru.gd`). Nu e o
## valoare de reglat des — dacă vreodată se atinge frecvent, semnul nu e că
## trebuie mărită, ci că `indicii_maxime` e prea strâmt pentru nivelul ăla.
const INCERCARI_MAXIME := 30


# ─────────────────────────────────────────────────────────────
# TIPURILE DE INDICIU
#
# Numele lor sunt ȘIRURI, nu un `enum`, dintr-un singur motiv: un `enum` se
# salvează ca număr, iar numerele își schimbă înțelesul în ziua în care inserezi
# un tip nou la mijlocul listei. Un save vechi ar citi atunci „PARITATE" acolo
# unde scria „EXTREM". Șirurile nu au problema asta.
#
# REGULA CARE NU SE ÎNCALCĂ: niciun tip nu spune direct o cifră. „A = 7" ar
# transforma deducția în dictare — ai completa roata și ai trece mai departe,
# fără să fi gândit nimic. Toate tipurile de mai jos vorbesc despre RELAȚII
# (între roți, sau între o roată și restul), deci fiecare indiciu în parte lasă
# mai multe posibilități, iar codul iese doar din combinarea lor.
# `_indiciu_care_da_o_cifra()` verifică regula asta la propriu, la final.
# ─────────────────────────────────────────────────────────────

## `{a, b, semn}` — cifra de pe poziția `a` față de cea de pe `b`: ">", "<", "=".
const RELATIE := "RELATIE"

## `{a, b, valoare}` — cod[a] − cod[b] == valoare (valoare > 0 mereu).
const DIFERENTA := "DIFERENTA"

## `{a, b, semn, valoare}` — suma a două cifre, comparată cu un număr.
const SUMA_DOUA := "SUMA_DOUA"

## `{a, para}` — cifra de pe poziția `a` e pară (sau impară).
const PARITATE := "PARITATE"

## `{a, maxim}` — nicio cifră nu e mai mare (sau mai mică) decât cea de pe `a`.
## „Nu e mai mare", nu „e strict cea mai mare": așa rămâne adevărat și când două
## roți au aceeași cifră, deci indiciul se poate genera pentru orice cod.
const EXTREM := "EXTREM"

## `{}` — toate cifrele sunt diferite. Singurul tip fără parametri.
const FARA_REPETITIE := "FARA_REPETITIE"

## `{semn, valoare}` — suma tuturor cifrelor, comparată cu un număr.
const SUMA_TOTALA := "SUMA_TOTALA"


# ─────────────────────────────────────────────────────────────
# INTRAREA PRINCIPALĂ
# ─────────────────────────────────────────────────────────────

## Specificația unui nivel, cu nivelul strâns în intervalul care există.
## Orice cerere din afară trece pe aici, ca un „nivel 7" venit dintr-un nod de
## hartă prost configurat să nu crape, ci să dea cel mai greu nivel existent.
static func specificatie(nivel: int) -> Dictionary:
	return NIVELURI[clampi(nivel, 1, NIVELURI.size()) - 1]


## PUZZLE-UL. Aceeași sămânță + același nivel = exact același puzzle, de fiecare
## dată, pe orice calculator.
##
## De ce contează atât determinismul, cât să merite un `RandomNumberGenerator`
## propriu în loc de `randi()`: harta întreagă e deja reproductibilă dintr-o
## sămânță, iar nodul de eveniment o să-și ceară cifrul cu o sămânță derivată
## din a hărții. Dacă cifrul ar trage din generatorul GLOBAL, două expediții cu
## aceeași sămânță ar avea aceeași hartă, dar alte lacăte — și un raport de
## genul „expediția 12345, al doilea eveniment, indiciile se contrazic" ar
## deveni imposibil de reprodus.
##
## Întoarce un Dictionary gol DOAR dacă n-a ieșit nimic în `INCERCARI_MAXIME`
## încercări — adică practic niciodată. Scena tratează cazul ca pe o eroare
## ordonată, nu crapă.
static func genereaza(nivel: int, samanta: int) -> Dictionary:
	var spec := specificatie(nivel)

	# Toate codurile posibile, o singură dată pentru toate încercările. E cea
	# mai scumpă construcție din fișier (10000 de mici `Array`-uri la nivelul 3)
	# și nu depinde de nimic din ce se schimbă între încercări.
	var toate := toate_codurile(spec)

	var rng := RandomNumberGenerator.new()

	# Cel mai bun rezultat de până acum, dacă niciunul n-a încăput sub limită.
	# Îl păstrăm ca să avem ce juca chiar și în ziua nefericită: un puzzle
	# corect, dar cu un indiciu în plus, e infinit mai bun decât un lacăt care
	# nu se deschide.
	var rezerva := {}

	for incercare in INCERCARI_MAXIME:
		rng.seed = _sub_samanta(samanta, nivel, incercare)

		# Codul se trage LA FIECARE încercare, nu o dată la început. Dacă ar fi
		# fixat, o reîncercare ar schimba doar candidații — iar un cod nefericit
		# (toate cifrele egale, de pildă) ar rămâne nefericit de 30 de ori la rând.
		var cod := _cod_la_intamplare(spec, rng)
		var indicii := _o_incercare(cod, toate, spec, rng)
		if indicii.is_empty():
			continue

		# Plasa de siguranță a regulii „niciun indiciu nu dă direct o cifră".
		# Candidații sunt deja fabricați ca s-o respecte (vezi `_candidati()`),
		# dar regula e prea importantă ca să fie apărată doar de bună intenție:
		# aici se verifică EFECTUL, nu intenția.
		if _indiciu_care_da_o_cifra(indicii, toate) != -1:
			continue

		# Ordinea în care le-a ales alegerea lacomă e „de la cel mai tare la cel
		# mai slab" — o informație pe care jucătorul n-are de ce s-o primească
		# gratis. Amestecul o șterge.
		_amesteca(indicii, rng)

		var puzzle := _puzzle(spec, nivel, samanta, cod, indicii, incercare + 1, false)
		if indicii.size() <= int(spec["indicii_maxime"]):
			return puzzle
		if rezerva.is_empty() or indicii.size() < rezerva["indicii"].size():
			rezerva = puzzle

	if rezerva.is_empty():
		# N-a ieșit NIMIC în 30 de încercări. Nu e ghinion — e semn că tabelul
		# de dificultate cere ceva imposibil (un interval de o singură cifră, de
		# pildă). Mesajul din consolă e tot ce ajută atunci.
		push_error("GeneratorCifru: niciun cifru bun in %d incercari (nivel %d, samanta %d)."
			% [INCERCARI_MAXIME, nivel, samanta])
		return {}

	push_warning(("GeneratorCifru: nivel %d, samanta %d — cel mai scurt cifru are %d indicii, "
		+ "peste maximul de %d. Se joaca asa. Daca vezi des avertismentul, "
		+ "maximul e prea strans; nu semintele sunt de vina.")
		% [nivel, samanta, rezerva["indicii"].size(), spec["indicii_maxime"]])
	rezerva["la_limita"] = true
	rezerva["incercari"] = INCERCARI_MAXIME
	return rezerva


## Forma finală a puzzle-ului. Un singur loc care o construiește, ca să nu
## existe două variante ale aceluiași dicționar, cu chei diferite.
static func _puzzle(spec: Dictionary, nivel: int, samanta: int, cod: Array,
		indicii: Array, incercari: int, la_limita: bool) -> Dictionary:
	return {
		"nivel": nivel,
		"samanta": samanta,
		"cifre": int(spec["cifre"]),
		"minim": int(spec["minim"]),
		"maxim": int(spec["maxim"]),
		"cod": cod,
		"indicii": indicii,
		# Câte încercări a cerut. Nu e folosit în joc — e pentru verificator,
		# care măsoară cât de strâmt e tabelul de dificultate.
		"incercari": incercari,
		# `true` = am ieșit pe ușa din dos, cu mai multe indicii decât maximul.
		"la_limita": la_limita,
	}


## Sub-sămânța unei încercări. Aceeași idee (și aceleași numere prime) ca la
## `Expeditie._sub_samanta()`: înmulțirea cu un număr mare împrăștie semințele
## vecine, ca sămânța 7 și sămânța 8 să nu dea puzzle-uri înrudite.
##
## `nivel` intră în formulă fiindcă altfel aceeași sămânță ar porni cele trei
## niveluri din același punct — iar un jucător care întâlnește două lacăte
## într-o expediție ar vedea, la niveluri diferite, aceeași structură.
static func _sub_samanta(samanta: int, nivel: int, incercare: int) -> int:
	return samanta * 1000003 + nivel * 7919 + incercare * 101 + 1


# ─────────────────────────────────────────────────────────────
# O SINGURĂ ÎNCERCARE: ALEGEREA LACOMĂ
# ─────────────────────────────────────────────────────────────

## Ce înseamnă „lacom" (greedy) aici, în cuvinte simple.
##
## Ai o mulțime de 10000 de coduri posibile și o mână de afirmații adevărate
## despre codul tău. Vrei să alegi câteva afirmații care, împreună, lasă un
## singur cod în picioare — și vrei să fie CÂT MAI PUȚINE, ca să încapă pe ecran.
##
## „Cât mai puține" e o problemă grea în general (e o rudă a problemei acoperirii
## de mulțimi, pentru care nimeni nu știe o metodă rapidă și exactă). Dar nu ne
## trebuie OPTIMUL: ne trebuie ceva scurt, rapid și de încredere. Metoda lacomă
## e exact asta — la fiecare pas ia mușcătura cea mai mare disponibilă ACUM,
## fără să se uite înainte:
##
##   posibile = toate codurile
##   cât timp posibile > 1:
##       alege indiciul care lasă cele mai puține coduri în picioare
##       taie mulțimea cu el
##
## E „lacomă" (adică miopă) fiindcă o alegere bună acum poate fi o alegere
## proastă în ansamblu: două indicii medii s-ar putea completa mai bine decât
## unul tare urmat de unul care repetă aproape aceeași informație. De-aia există
## pasul de CURĂȚARE de după — el repară exact genul ăsta de miopie.
##
## Și, cel mai important: metoda nu poate greși periculos. Se oprește doar când
## a rămas un singur cod, iar acel cod e obligatoriu al nostru — toate indiciile
## sunt adevărate despre el, deci el supraviețuiește oricărei tăieri. Deci
## „lacom" poate produce un puzzle mai lung decât ar fi trebuit; niciodată unul
## ambiguu sau fără soluție.
##
## Întoarce un Array gol dacă eșantionul de candidați nu izolează codul.
static func _o_incercare(cod: Array, toate: Array, spec: Dictionary,
		rng: RandomNumberGenerator) -> Array:
	var candidati := _candidati(cod, spec, rng)
	var folositi := {}
	var posibile := toate
	var alese := []

	while posibile.size() > 1:
		var cel_mai_bun := -1
		# Pragul pornește de la câte coduri sunt ACUM: un candidat care lasă tot
		# atâtea nu taie nimic, deci nu merită ales. Așa, o singură comparație
		# („mai mic decât pragul") înseamnă și „cel mai bun de până acum", și
		# „chiar taie ceva".
		var cate_ramane := posibile.size()
		for k in candidati.size():
			if folositi.has(k):
				continue
			var cate := _cate_trec(candidati[k], posibile)
			if cate < cate_ramane:
				cate_ramane = cate
				cel_mai_bun = k

		if cel_mai_bun == -1:
			# Niciun candidat rămas nu mai taie nimic: codurile care au
			# supraviețuit sunt, pentru eșantionul ăsta, de nedeosebit între ele.
			# Nu e o eroare — e un eșantion sărac. Altă sub-sămânță.
			return []

		alese.append(candidati[cel_mai_bun])
		folositi[cel_mai_bun] = true
		posibile = _filtreaza(candidati[cel_mai_bun], posibile)

	return _curata(alese, toate)


## CURĂȚAREA — scoate indiciile care, la final, nu mai contează.
##
## De ce apar deloc: alegerea lacomă e miopă. Indiciul luat la pasul 2 tăia mult
## ATUNCI; după ce pasul 4 a mai tăiat o dată, se poate întâmpla ca tot ce tăia
## el să fie deja tăiat de ceilalți. E ca și cum ai da patru indicații de drum,
## iar a doua să fie „nu o lua spre nord" — adevărată, dar inutilă, fiindcă a
## patra spunea deja „mergi spre sud".
##
## Un indiciu inutil nu e doar zgomot: e o promisiune mincinoasă. Jucătorul
## presupune (pe drept) că fiecare rând de pe ecran e acolo ca să fie folosit, și
## pierde timp căutând ce aduce nou un rând care nu aduce nimic.
##
## Testul e simplu și cinstit: îl scoatem și întrebăm dacă soluția rămâne unică.
## Dacă da, era redundant — rămâne scos. Dacă nu, îl punem înapoi.
##
## Ordinea: mergem prin listă o singură dată, de la primul la ultimul, și NU
## reluăm de la capăt după fiecare scoatere. Motivul e că scoaterea unui indiciu
## nu poate face redundant un altul — dimpotrivă, îi crește importanța. Deci o
## singură trecere ajunge; a doua n-ar mai găsi nimic.
static func _curata(alese: Array, toate: Array) -> Array:
	var rezultat := alese.duplicate()
	var i := 0
	while i < rezultat.size():
		var proba := rezultat.duplicate()
		proba.remove_at(i)
		if cate_solutii_pentru(proba, toate, 2) == 1:
			rezultat = proba   # era redundant: nu creștem `i`, lista s-a scurtat
		else:
			i += 1
	return rezultat


# ─────────────────────────────────────────────────────────────
# CANDIDAȚII: AFIRMAȚII ADEVĂRATE DESPRE COD
# ─────────────────────────────────────────────────────────────

## Fabrică grămada de indicii posibile, apoi taie un eșantion din ea.
##
## TOATE afirmațiile de aici sunt adevărate despre `cod`, prin construcție: nu
## „inventăm un indiciu și verificăm dacă se potrivește", ci CITIM codul și
## scriem ce vedem în el. De-aia nu există nicăieri riscul unui puzzle
## contradictoriu: un set de afirmații adevărate despre același cod nu se poate
## contrazice, oricâte ar fi.
##
## Unde apar numere trase cu zarul (pragurile sumelor), intervalul din care se
## trag e calculat ca afirmația să rămână adevărată ȘI să nu fixeze o cifră.
static func _candidati(cod: Array, spec: Dictionary, rng: RandomNumberGenerator) -> Array:
	var n := cod.size()
	var minim := int(spec["minim"])
	var maxim := int(spec["maxim"])
	var pool := []

	# ── Relații și diferențe între două roți ──────────────────
	for i in n:
		for j in n:
			if i == j:
				continue
			if i < j:
				# O singură relație pe pereche (perechea {0,2}, nu și {2,0}):
				# „A > C" și „C < A" sunt aceeași propoziție, scrisă invers.
				if cod[i] > cod[j]:
					pool.append({"tip": RELATIE, "a": i, "b": j, "semn": ">"})
				elif cod[i] < cod[j]:
					pool.append({"tip": RELATIE, "a": i, "b": j, "semn": "<"})
				else:
					pool.append({"tip": RELATIE, "a": i, "b": j, "semn": "="})
			# Diferența, în schimb, are nevoie de perechi ORDONATE: ne trebuie
			# cea în care iese un număr pozitiv, ca propoziția să sune firesc
			# („A e cu 2 mai mare decât D", nu „cu −2").
			var d: int = int(cod[i]) - int(cod[j])
			# `d == maxim - minim` e singura diferență care fixează amândouă
			# cifrele (pe un interval 1-6, doar 6−1 dă 5). Ar încălca regula
			# „niciun indiciu nu dă direct o cifră", deci nici nu se naște.
			if d > 0 and d < maxim - minim:
				pool.append({"tip": DIFERENTA, "a": i, "b": j, "valoare": d})

	# ── Suma a două roți ──────────────────────────────────────
	for i in n:
		for j in range(i + 1, n):
			var s: int = int(cod[i]) + int(cod[j])
			# Suma exactă, dar nu la capetele intervalului: „A + B e exact 2" pe
			# un lacăt 1-6 înseamnă că amândouă sunt 1, adică două cifre dictate.
			if s > 2 * minim and s < 2 * maxim:
				pool.append({"tip": SUMA_DOUA, "a": i, "b": j, "semn": "=", "valoare": s})
			var inegalitate := _prag(rng, s, 2 * minim, 2 * maxim)
			if not inegalitate.is_empty():
				inegalitate["tip"] = SUMA_DOUA
				inegalitate["a"] = i
				inegalitate["b"] = j
				pool.append(inegalitate)

	# ── Paritatea unei roți ───────────────────────────────────
	for i in n:
		pool.append({"tip": PARITATE, "a": i, "para": int(cod[i]) % 2 == 0})

	# ── Extremele ─────────────────────────────────────────────
	var cel_mai_mare: int = cod.max()
	var cel_mai_mic: int = cod.min()
	for i in n:
		if int(cod[i]) == cel_mai_mare:
			pool.append({"tip": EXTREM, "a": i, "maxim": true})
		if int(cod[i]) == cel_mai_mic:
			pool.append({"tip": EXTREM, "a": i, "maxim": false})

	# ── Fără repetiție ────────────────────────────────────────
	# Se naște doar dacă e adevărat. Când codul ARE cifre repetate, afirmația
	# contrară („două cifre se repetă") n-ar fi un indiciu de aceeași calitate:
	# taie mult mai puțin și sună a ghicitoare, nu a constrângere.
	var distincte := {}
	for c in cod:
		distincte[c] = true
	if distincte.size() == n:
		pool.append({"tip": FARA_REPETITIE})

	# ── Suma tuturor cifrelor ─────────────────────────────────
	var total := 0
	for c in cod:
		total += int(c)
	if total > n * minim and total < n * maxim:
		pool.append({"tip": SUMA_TOTALA, "semn": "=", "valoare": total})
	var ineg_total := _prag(rng, total, n * minim, n * maxim)
	if not ineg_total.is_empty():
		ineg_total["tip"] = SUMA_TOTALA
		pool.append(ineg_total)

	_amesteca(pool, rng)
	if pool.size() > CANDIDATI:
		pool.resize(CANDIDATI)
	return pool


## Un prag pentru o inegalitate adevărată despre `valoare`, tras cu zarul.
##
## Pentru „mai mare decât P" avem nevoie de P < valoare, dar și de P ≤ maxim−2:
## un prag lipit de capătul de sus („suma e mai mare decât 11", pe un maxim de
## 12) ar lăsa o singură sumă posibilă, ceea ce poate fixa cifre. Simetric
## pentru „mai mică decât".
##
## Întoarce `{}` când nu există niciun prag cinstit (valoarea e chiar la capăt).
static func _prag(rng: RandomNumberGenerator, valoare: int, cel_mai_mic: int,
		cel_mai_mare: int) -> Dictionary:
	var jos_max: int = mini(valoare - 1, cel_mai_mare - 2)     # praguri pentru ">"
	var sus_min: int = maxi(valoare + 1, cel_mai_mic + 2)      # praguri pentru "<"
	var poate_mai_mare := jos_max >= cel_mai_mic
	var poate_mai_mic := sus_min <= cel_mai_mare
	if not poate_mai_mare and not poate_mai_mic:
		return {}
	# Când amândouă sunt posibile, alegem cu zarul: altfel toate inegalitățile
	# din joc ar fi în aceeași direcție, iar asta se simte după trei puzzle-uri.
	var in_sus := poate_mai_mare and (not poate_mai_mic or rng.randi_range(0, 1) == 0)
	if in_sus:
		return {"semn": ">", "valoare": rng.randi_range(cel_mai_mic, jos_max)}
	return {"semn": "<", "valoare": rng.randi_range(sus_min, cel_mai_mare)}


static func _cod_la_intamplare(spec: Dictionary, rng: RandomNumberGenerator) -> Array:
	var cod := []
	for i in int(spec["cifre"]):
		cod.append(rng.randi_range(int(spec["minim"]), int(spec["maxim"])))
	return cod


## Amestec Fisher-Yates cu RNG-UL NOSTRU.
##
## `Array.shuffle()` ar fi fost un rând, dar folosește generatorul GLOBAL al
## motorului — adică exact ce n-avem voie: aceeași sămânță ar da altă ordine la
## fiecare pornire a jocului, iar reproductibilitatea s-ar pierde fix la pasul
## ăsta, unde nimeni nu s-ar uita după ea.
static func _amesteca(lista: Array, rng: RandomNumberGenerator) -> void:
	for i in range(lista.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp = lista[i]
		lista[i] = lista[j]
		lista[j] = temp


# ─────────────────────────────────────────────────────────────
# FORȚA BRUTĂ: DE CE E SIGURĂ AICI
#
# „Forță brută" înseamnă: încearcă TOATE codurile, unul câte unul, și numără
# câte trec de indicii. E metoda cea mai proastă din lume în general — și cea
# mai bună aici, din trei motive:
#
#   1. MULȚIMEA E MINUSCULĂ. Cel mai mare lacăt din joc are 4 roți × 10 cifre =
#      10⁴ = 10000 de coduri. Un calculator le parcurge de mii de ori pe secundă.
#      (Un lacăt de 6 roți × 10 cifre ar avea un milion — de-aia tabelul de
#      dificultate e o listă scurtă, nu o invitație la orice.)
#
#   2. E O DOVADĂ, NU UN EȘANTION. Nu „am încercat o mie de coduri și n-am găsit
#      altă soluție", ci „le-am încercat pe toate". Unicitatea unui puzzle n-are
#      voie să fie probabilă: un al doilea cod valid înseamnă un jucător care
#      deduce corect, tastează corect și pierde o încercare.
#
#   3. FOLOSEȘTE EXACT REGULA JOCULUI. Numărătoarea trece prin `evalueaza()`,
#      adică prin funcția pe care o cheamă și scena când verifică ce ai tastat.
#      Un verificator „mai deștept" ar fi a doua implementare a acelorași reguli,
#      iar două implementări se despart mereu — de obicei la un caz limită, la
#      două luni după ce le-ai scris.
# ─────────────────────────────────────────────────────────────

## Toate codurile posibile, în ordine fixă.
##
## Numărăm ca într-o bază de numerație: fiecare cod e un număr scris cu `cifre`
## cifre în baza `maxim − minim + 1`. Așa lista iese deterministă, fără
## recursivitate și fără să depindă de ceva tras cu zarul.
static func toate_codurile(spec: Dictionary) -> Array:
	var cifre := int(spec["cifre"])
	var minim := int(spec["minim"])
	var baza := int(spec["maxim"]) - minim + 1
	var total := 1
	for i in cifre:
		total *= baza

	var toate := []
	toate.resize(total)
	for n in total:
		var cod := []
		var rest := n
		for i in cifre:
			cod.append(minim + rest % baza)
			rest /= baza
		toate[n] = cod
	return toate


## Câte coduri din `lista` respectă indiciul. Inima alegerii lacome.
static func _cate_trec(indiciu: Dictionary, lista: Array) -> int:
	var cate := 0
	for cod in lista:
		if evalueaza(indiciu, cod):
			cate += 1
	return cate


static func _filtreaza(indiciu: Dictionary, lista: Array) -> Array:
	var ramase := []
	for cod in lista:
		if evalueaza(indiciu, cod):
			ramase.append(cod)
	return ramase


## Câte coduri respectă TOATE indiciile. Se oprește la `plafon`, fiindcă
## întrebarea reală nu e „câte", ci „una sau mai multe?" — iar diferența dintre
## 2 și 300 nu schimbă nicio decizie.
static func cate_solutii_pentru(indicii: Array, toate: Array, plafon := 2) -> int:
	var cate := 0
	for cod in toate:
		var bun := true
		for indiciu: Dictionary in indicii:
			if not evalueaza(indiciu, cod):
				bun = false
				break
		if bun:
			cate += 1
			if cate >= plafon:
				return cate
	return cate


## Câte soluții are un puzzle întreg. Pentru verificator; în joc nu e nevoie de
## ea, fiindcă generatorul garantează deja unicitatea.
static func cate_solutii(puzzle: Dictionary, plafon := 2) -> int:
	if puzzle.is_empty():
		return 0
	var spec := {"cifre": puzzle["cifre"], "minim": puzzle["minim"], "maxim": puzzle["maxim"]}
	return cate_solutii_pentru(puzzle["indicii"], toate_codurile(spec), plafon)


## Același lucru ca `_indiciu_care_da_o_cifra()`, dar pentru un puzzle întreg și
## pentru cine e din afară (verificatorul). Întoarce indicele indiciului vinovat,
## sau −1 dacă toate sunt curate.
##
## Regula „niciun indiciu nu dă direct o cifră" e apărată în două locuri:
## generatorul o verifică înainte să întoarcă puzzle-ul, iar verificatorul o
## verifică din nou pe 1500 de puzzle-uri. Amândouă cheamă ACEEAȘI funcție — o
## a doua definiție a regulii ar fi exact felul în care o regulă ajunge să fie
## respectată de verificator și încălcată de joc.
static func indiciu_care_da_o_cifra(puzzle: Dictionary) -> int:
	if puzzle.is_empty():
		return -1
	var spec := {"cifre": puzzle["cifre"], "minim": puzzle["minim"], "maxim": puzzle["maxim"]}
	return _indiciu_care_da_o_cifra(puzzle["indicii"], toate_codurile(spec))


## Găsește un indiciu care, DE UNUL SINGUR, fixează o cifră. Întoarce indicele
## lui, sau −1 dacă niciunul nu face asta.
##
## E verificarea la propriu a regulii „fără indicii care dau direct o cifră". Nu
## se uită la TIPUL indiciului (niciun tip nu e de forma „A = 7"), ci la EFECTUL
## lui: dacă toate codurile care respectă indiciul au aceeași cifră pe o
## poziție, atunci indiciul dictează cifra aia — indiferent cum e scris. „Suma
## tuturor cifrelor e exact 3", pe un lacăt de 3 roți cu minimul 1, e o
## propoziție despre sumă care spune, de fapt, „toate sunt 1".
static func _indiciu_care_da_o_cifra(indicii: Array, toate: Array) -> int:
	var cifre: int = toate[0].size()
	for k in indicii.size():
		# Pentru fiecare poziție, ce valori apar printre codurile care trec.
		var vazute := []
		for i in cifre:
			vazute.append({})
		var libere := 0   # câte poziții au deja cel puțin două valori diferite
		for cod in toate:
			if not evalueaza(indicii[k], cod):
				continue
			for i in cifre:
				var set: Dictionary = vazute[i]
				if not set.has(cod[i]):
					set[cod[i]] = true
					if set.size() == 2:
						libere += 1
			if libere == cifre:
				break   # toate pozițiile au scăpat: indiciul ăsta e curat
		if libere < cifre:
			return k
	return -1


# ─────────────────────────────────────────────────────────────
# SINGURUL ADEVĂR: CE ÎNSEAMNĂ UN INDICIU
# ─────────────────────────────────────────────────────────────

## Respectă codul indiciul? Funcția asta e folosită de TOT: de alegerea lacomă,
## de curățare, de verificarea unicității, de verificatorul din `tools/` și de
## scena care colorează în roșu indiciile încălcate.
##
## De ce e important că e UNA singură: dacă scena ar avea propria ei verificare
## („mai simplă, doar pentru feedback"), ar exista două definiții ale aceleiași
## reguli. Ele funcționează identic exact până în ziua în care una e corectată
## și cealaltă nu — și atunci jocul îți spune că indiciul e respectat, dar refuză
## să deschidă lacătul. Un joc care se contrazice singur.
##
## Un tip necunoscut (o greșeală de scriere într-un save vechi, de pildă)
## întoarce `false` și strigă în consolă: mai bine un lacăt pe care nu-l poți
## deschide, cu motivul scris, decât unul care se deschide din greșeală.
static func evalueaza(indiciu: Dictionary, cod: Array) -> bool:
	match String(indiciu.get("tip", "")):
		RELATIE:
			var a := int(cod[int(indiciu["a"])])
			var b := int(cod[int(indiciu["b"])])
			match String(indiciu["semn"]):
				">":
					return a > b
				"<":
					return a < b
				_:
					return a == b
		DIFERENTA:
			return int(cod[int(indiciu["a"])]) - int(cod[int(indiciu["b"])]) == int(indiciu["valoare"])
		SUMA_DOUA:
			var s := int(cod[int(indiciu["a"])]) + int(cod[int(indiciu["b"])])
			return _compara(s, String(indiciu["semn"]), int(indiciu["valoare"]))
		PARITATE:
			return (int(cod[int(indiciu["a"])]) % 2 == 0) == bool(indiciu["para"])
		EXTREM:
			var a := int(cod[int(indiciu["a"])])
			var e_maxim := bool(indiciu["maxim"])
			for c in cod:
				if e_maxim and int(c) > a:
					return false
				if not e_maxim and int(c) < a:
					return false
			return true
		FARA_REPETITIE:
			var vazute := {}
			for c in cod:
				if vazute.has(c):
					return false
				vazute[c] = true
			return true
		SUMA_TOTALA:
			var total := 0
			for c in cod:
				total += int(c)
			return _compara(total, String(indiciu["semn"]), int(indiciu["valoare"]))
	push_error("GeneratorCifru: indiciu de tip necunoscut: %s" % [indiciu])
	return false


static func _compara(stanga: int, semn: String, dreapta: int) -> bool:
	match semn:
		">":
			return stanga > dreapta
		"<":
			return stanga < dreapta
		_:
			return stanga == dreapta


## Indiciile pe care codul dat NU le respectă, ca listă de indici.
##
## Scena o cheamă după fiecare încercare greșită, ca să știe ce rânduri să
## coloreze în roșu. Trece tot prin `evalueaza()`, deci feedback-ul din scenă și
## verificarea soluției nu pot ajunge niciodată să spună lucruri diferite.
static func indicii_incalcate(indicii: Array, cod: Array) -> Array[int]:
	var gresite: Array[int] = []
	for k in indicii.size():
		if not evalueaza(indicii[k], cod):
			gresite.append(k)
	return gresite


# ─────────────────────────────────────────────────────────────
# DIN DICȚIONAR ÎN ROMÂNEȘTE
# ─────────────────────────────────────────────────────────────

## Litera unei roți. Indici de la zero în cod, litere pe ecran.
static func litera(pozitie: int) -> String:
	if pozitie < 0 or pozitie >= LITERE.length():
		return "?"
	return LITERE[pozitie]


## Propoziția unui indiciu. Textele sunt despre CIFRE (substantiv feminin în
## română), de-aia „mai mică", „pară", „nicio cifră" — acordul e cu „cifra A",
## chiar dacă cuvântul nu apare de fiecare dată în propoziție.
static func text(indiciu: Dictionary) -> String:
	match String(indiciu.get("tip", "")):
		RELATIE:
			var a := litera(int(indiciu["a"]))
			var b := litera(int(indiciu["b"]))
			match String(indiciu["semn"]):
				">":
					return "%s e mai mare decât %s." % [a, b]
				"<":
					return "%s e mai mică decât %s." % [a, b]
				_:
					return "%s și %s sunt egale." % [a, b]
		DIFERENTA:
			return "%s e cu %d mai mare decât %s." % [
				litera(int(indiciu["a"])), int(indiciu["valoare"]), litera(int(indiciu["b"]))]
		SUMA_DOUA:
			var pereche := "%s + %s" % [litera(int(indiciu["a"])), litera(int(indiciu["b"]))]
			match String(indiciu["semn"]):
				">":
					return "%s e mai mare decât %d." % [pereche, int(indiciu["valoare"])]
				"<":
					return "%s e mai mică decât %d." % [pereche, int(indiciu["valoare"])]
				_:
					return "%s e exact %d." % [pereche, int(indiciu["valoare"])]
		PARITATE:
			return "%s e %s." % [
				litera(int(indiciu["a"])), "pară" if bool(indiciu["para"]) else "impară"]
		EXTREM:
			if bool(indiciu["maxim"]):
				return "Nicio cifră nu e mai mare decât %s." % litera(int(indiciu["a"]))
			return "Nicio cifră nu e mai mică decât %s." % litera(int(indiciu["a"]))
		FARA_REPETITIE:
			return "Nicio cifră nu se repetă."
		SUMA_TOTALA:
			match String(indiciu["semn"]):
				">":
					return "Suma tuturor cifrelor e mai mare decât %d." % int(indiciu["valoare"])
				"<":
					return "Suma tuturor cifrelor e mai mică decât %d." % int(indiciu["valoare"])
				_:
					return "Suma tuturor cifrelor e exact %d." % int(indiciu["valoare"])
	# Un tip fără propoziție e o scăpare de programator, nu o stare de joc: se
	# întâmplă doar dacă ai adăugat un tip și ai uitat un rând aici. Textul
	# întors e vizibil urât, ca să nu treacă neobservat prin testare.
	push_error("GeneratorCifru: indiciu fara text: %s" % [indiciu])
	return "(indiciu necunoscut)"

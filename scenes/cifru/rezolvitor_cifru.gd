class_name RezolvitorCifru
extends RefCounted
## REZOLVITORUL DE CIFRURI — rezolvă un lacăt așa cum l-ar rezolva un om, ca să
## putem MĂSURA cât e de greu.
##
## ─────────────────────────────────────────────────────────────
## DE CE EXISTĂ FIȘIERUL ĂSTA
##
## Generatorul știa deja să facă lacăte corecte: cu o singură soluție, fără
## indicii de prisos, fără vreun rând care să dicteze o cifră. Nu știa însă
## singurul lucru care contează pentru un jucător: dacă e GREU.
##
## Iar dificultatea nu se poate citi din numărul de indicii. Trei indicii pot
## fi banale („A = B", „B = C", „suma e 20" — le pui cap la cap și ai terminat)
## și cinci pot fi chinuitoare. Ce deosebește cele două puzzle-uri nu e cât de
## multe rânduri ai, ci CE FEL DE GÂNDIRE îți cer.
##
## Deci ne trebuie un rezolvitor care nu ghicește și nu caută prin forță brută,
## ci deduce ca un om — și care la final poate spune: „am reușit, dar a trebuit
## să presupun de două ori". Nota aia devine dificultatea puzzle-ului, iar
## generatorul păstrează doar puzzle-urile cu nota cerută de nivel.
##
## ATENȚIE la ce NU e fișierul ăsta. Nu verifică unicitatea (aia rămâne dovedită
## prin forță brută, în generator: acolo ai nevoie de certitudine, nu de
## imitarea unui om). Nu rezolvă cifrul în locul jucătorului în joc. Singurul
## lui rost e să dea o NOTĂ.
##
## ─────────────────────────────────────────────────────────────
## CUM GÂNDEȘTE: „DOMENIILE"
##
## Un om care rezolvă un lacăt nu ține minte coduri întregi. Ține minte, pentru
## fiecare roată, ce cifre mai sunt posibile — și taie din ele pe măsură ce
## citește indiciile. Exact asta ține și rezolvitorul, într-o listă pe roată,
## numită DOMENIU:
##
##     A: [1 2 3 4 5 6 7 8 9]
##     B: [1 2 3 4 5 6 7 8 9]
##     C: [1 2 3 4 5 6 7 8 9]
##     D: [1 2 3 4 5 6 7 8 9]
##
## La nivelul 1, roata sudată pornește deja cu o singură cifră — fiindcă
## jucătorul chiar o vede pe cufăr.
##
## PUZZLE-UL E REZOLVAT când toate cele patru liste au ajuns la o singură cifră.
## Un domeniu GOL înseamnă „aici nu mai poate sta nimic" — adică o stare
## imposibilă. Ține minte cuvântul ăsta, e toată tehnica T3 de mai jos.
##
## ─────────────────────────────────────────────────────────────
## SCARA DE TEHNICI
##
## Rezolvitorul are trei unelte, de la ieftin la scump, și le încearcă MEREU în
## ordinea asta. Nota puzzle-ului e cea mai grea unealtă de care a avut nevoie.
## Ordinea contează enorm: dacă ar sări direct la T3, ar rezolva orice puzzle
## cu T3 și toate ar primi nota 3. „Nota 3" înseamnă „a existat un moment în
## care NIMIC mai simplu nu mai mergea".
##
## ── T1: un singur indiciu, luat de unul singur ───────────────
##
## Iei un rând de pe ecran și îl storci complet, fără să te uiți la celelalte.
## Pentru fiecare cifră din fiecare domeniu întrebi: mai există vreo completare
## a celorlalte roți (din ce le-a rămas LOR posibil) care să facă indiciul
## adevărat? Dacă nu există niciuna, cifra se taie.
##
## Exemplu. Indiciul „A + B + C + D e mai mică decât 12", toate domeniile pline
## (1-9). Poate A să fie 9? Atunci B, C și D ar trebui să adune sub 3, dar cel
## mai puțin pot aduna e 3 (câte 1 fiecare). Nu se poate: 9 iese din domeniul
## lui A. La fel 8. Rezultatul: A, B, C și D rămân toate cu [1..8], iar apoi cu
## mai puțin, pe măsură ce alte indicii taie și ele.
##
## ── T2: două indicii puse alături ────────────────────────────
##
## Aceeași întrebare, dar cerând ca DOUĂ indicii să fie adevărate în același
## timp. E treapta „combină două rânduri" — și e altceva decât T1 aplicat de
## două ori, fiindcă fiecare indiciu în parte poate să nu taie nimic, iar
## împreună să taie.
##
## Exemplu. „A e pară" nu taie nimic dacă A mai poate fi 2, 4 sau 5. „A + B e
## exact 11" nu taie nimic dacă toate perechile sunt încă posibile. Împreună
## însă: dacă A e pară, A + B = 11 cere ca B să fie impară, și dintr-o dată
## domeniul lui B se subțiază.
##
## Perechile de indicii care n-au NICIO roată comună se sar: acolo T2 n-ar afla
## nimic peste T1 (două afirmații despre lucruri complet diferite nu se pot
## ajuta între ele).
##
## ── T3: presupunerea ─────────────────────────────────────────
##
## Vezi explicația lungă de deasupra funcției `_t3()`. E tehnica pe care o
## cere nivelul 3 și singura care nu se citește direct de pe ecran.


# ─────────────────────────────────────────────────────────────
# NOTELE
#
# Sunt numere mici și crescătoare fiindcă „mai greu" înseamnă „mai mare", iar
# codul le compară cu `maxi()`. Nu e `enum`, din același motiv ca la tipurile
# de indiciu: un `enum` se salvează ca număr fără nume, iar nota unui puzzle
# ajunge în tabelul de dificultate din generator, unde trebuie să se citească.
# ─────────────────────────────────────────────────────────────

## N-a fost nevoie de nicio tehnică (sau n-a mers niciuna).
const NIMIC := 0

## Un singur indiciu, luat de unul singur, taie cifre.
const T1 := 1

## Două indicii combinate taie cifre; niciunul singur n-ar fi tăiat.
const T2 := 2

## Presupui o cifră, propagi, dai de contradicție, o elimini.
const T3 := 3


## CÂTE COMBINAȚII ACCEPTĂM SĂ PARCURGEM pentru un indiciu (sau o pereche).
##
## `_propaga()` încearcă toate potrivirile posibile ale roților de care vorbește
## indiciul. Pentru lacătul de azi — 4 roți × 9 cifre — asta înseamnă cel mult
## 6561, adică nimic pentru un calculator. Plafonul nu are niciun efect azi.
##
## E aici ca plasă pentru ziua în care cineva pune în tabel un lacăt de 6 roți:
## atunci un indiciu care vorbește despre toate șase ar cere peste jumătate de
## milion de combinații, de zeci de ori într-o singură notare, iar generarea ar
## părea că a înghețat. Peste plafon, indiciul e pur și simplu SĂRIT: rezolvarea
## devine mai slabă (deci puzzle-ul poate fi respins pe nedrept), niciodată
## greșită. Un puzzle respins se înlocuiește cu altul; unul greșit ajunge în joc.
const PLAFON_COMBINATII := 60000


# ─────────────────────────────────────────────────────────────
# INTRAREA PRINCIPALĂ
# ─────────────────────────────────────────────────────────────

## Notează un puzzle: cât de greu e, și se poate deduce deloc?
##
## Întoarce un Dictionary cu:
##   `nota`      — NIMIC / T1 / T2 / T3, cea mai grea tehnică de care a fost
##                 nevoie;
##   `rezolvat`  — `true` doar dacă toate roțile au ajuns la o singură cifră
##                 folosind DOAR tehnicile de mai sus. `false` înseamnă „un om
##                 care gândește așa rămâne blocat", nu „puzzle-ul n-are
##                 soluție" — unicitatea e treaba forței brute din generator;
##   `cod`       — codul la care a ajuns, dacă `rezolvat`. Altfel, lista goală.
##                 Verificatorul îl compară cu codul adevărat: dacă cele două
##                 se despart, rezolvitorul are un bug, iar notele pe care le-a
##                 dat până atunci sunt gunoi;
##   `blocat`    — `true` dacă s-a oprit fiindcă nicio tehnică n-a mai avut
##                 efect (spre deosebire de o contradicție);
##   `contrazis` — `true` dacă a ajuns la o stare imposibilă. Pentru un puzzle
##                 corect nu se poate întâmpla; dacă apare, indiciile se bat cap
##                 în cap și generatorul are o problemă gravă.
static func noteaza(puzzle: Dictionary) -> Dictionary:
	if puzzle.is_empty():
		return _raport(NIMIC, [], false, true)

	var cifre := int(puzzle["cifre"])
	var minim := int(puzzle["minim"])
	var maxim := int(puzzle["maxim"])
	var blocata := int(puzzle.get("blocata", -1))
	var cod: Array = puzzle["cod"]
	var indicii: Array = puzzle["indicii"]

	# Starea de pornire: fiecare roată poate fi orice, în afară de cea sudată.
	# Roata sudată nu e o scurtătură a rezolvitorului — e o cifră pe care
	# jucătorul o CITEȘTE de pe cufăr înainte să se uite la vreun indiciu.
	var domenii := []
	for i in cifre:
		if i == blocata:
			domenii.append([int(cod[i])])
		else:
			var toate := []
			for v in range(minim, maxim + 1):
				toate.append(v)
			domenii.append(toate)

	# Ce roți atinge fiecare indiciu. Se calculează O SINGURĂ DATĂ aici, nu la
	# fiecare trecere: T2 ar cere-o de zeci de ori pentru același indiciu.
	var roti := []
	for indiciu: Dictionary in indicii:
		roti.append(_roti(indiciu, cifre))

	var nota := NIMIC
	var contrazis := false
	var blocat := false

	while not _gata(domenii):
		# Întâi tot ce se poate face fără să presupui nimic: T1 până se oprește,
		# apoi T2, apoi iar T1 — adică `_pana_se_opreste()`.
		var usor := _pana_se_opreste(domenii, indicii, roti, T2)
		if usor < 0:
			contrazis = true
			break
		nota = maxi(nota, usor)
		if _gata(domenii):
			break

		# Blocat cu uneltele ieftine. Singura care mai rămâne e presupunerea.
		var progres := _t3(domenii, indicii, roti)
		if progres < 0:
			contrazis = true
			break
		if progres == 0:
			# Nici măcar T3 nu mai taie nimic. Puzzle-ul nu se poate deduce cu
			# tehnicile astea — generatorul îl va respinge.
			blocat = true
			break
		nota = T3

	if contrazis:
		return _raport(nota, [], false, true)
	if blocat:
		return _raport(nota, [], true, false)
	return _raport(nota, _cod_din(domenii), false, false)


## Forma raportului, într-un singur loc, ca toate ieșirile funcției de mai sus
## să aibă exact aceleași chei.
static func _raport(nota: int, cod: Array, blocat: bool, contrazis: bool) -> Dictionary:
	return {
		"nota": nota,
		"rezolvat": not cod.is_empty(),
		"cod": cod,
		"blocat": blocat,
		"contrazis": contrazis,
	}


## Numele unei note, pentru rapoarte. „T2" se citește, „2" trebuie tradus.
static func nume_nota(nota: int) -> String:
	match nota:
		T1:
			return "T1"
		T2:
			return "T2"
		T3:
			return "T3"
	return "—"


# ─────────────────────────────────────────────────────────────
# TEHNICILE
# ─────────────────────────────────────────────────────────────

## T1 și T2, alternate până când niciuna nu mai taie nimic.
##
## De ce ALTERNATE, și nu „tot T1, apoi tot T2": după ce T2 taie o cifră, e
## foarte probabil ca T1 să poată continua singur o bucată bună de drum. Un om
## face la fel — după ce a scos ceva cu un raționament mai complicat, se
## întoarce la rândurile simple, fiindcă acum spun mai mult.
##
## `pana_la` spune cât de sus urcăm: `T1` = numai T1 (nu se folosește azi),
## `T2` = T1 și T2. T3 nu intră niciodată aici, fiindcă T3 CHEAMĂ funcția asta
## (vezi `_t3()`) și s-ar chema pe sine la nesfârșit.
##
## Întoarce −1 la contradicție, altfel cea mai grea tehnică folosită.
static func _pana_se_opreste(domenii: Array, indicii: Array, roti: Array,
		pana_la: int) -> int:
	var folosit := NIMIC
	while not _gata(domenii):
		var taiate := _t1(domenii, indicii, roti)
		if taiate < 0:
			return -1
		if taiate > 0:
			folosit = maxi(folosit, T1)
			continue

		# T1 s-a oprit. Dacă n-avem voie mai sus, aici se termină drumul.
		if pana_la < T2:
			break

		taiate = _t2(domenii, indicii, roti)
		if taiate < 0:
			return -1
		if taiate == 0:
			break   # nici T2 nu mai taie: blocat cu uneltele ieftine
		folosit = maxi(folosit, T2)

	return folosit


## T1 — fiecare indiciu, pe rând, de unul singur.
static func _t1(domenii: Array, indicii: Array, roti: Array) -> int:
	var taiate := 0
	for k in indicii.size():
		var rezultat := _propaga(domenii, [indicii[k]], roti[k])
		if rezultat < 0:
			return -1
		taiate += rezultat
	return taiate


## T2 — fiecare pereche de indicii care au măcar o roată comună.
##
## Fără roată comună, cele două afirmații vorbesc despre bucăți diferite ale
## lacătului; cerându-le împreună n-ai afla nimic ce nu afli cerându-le pe rând.
## Săritura nu e o optimizare, e definiția treptei: T2 înseamnă „două indicii
## care se ating".
static func _t2(domenii: Array, indicii: Array, roti: Array) -> int:
	var taiate := 0
	for i in indicii.size():
		for j in range(i + 1, indicii.size()):
			if not _se_ating(roti[i], roti[j]):
				continue
			var rezultat := _propaga(domenii, [indicii[i], indicii[j]],
				_reuniune(roti[i], roti[j]))
			if rezultat < 0:
				return -1
			taiate += rezultat
	return taiate


## T3 — PRESUPUNEREA. Tehnica pentru care există nivelul 3.
##
## ─────────────────────────────────────────────────────────────
## CE SE ÎNTÂMPLĂ, ÎN CUVINTE
##
## Ai stors toate rândurile. T1 nu mai taie nimic, T2 nici atât, și totuși
## roțile n-au ajuns la o cifră. Nu mai există niciun raționament care să
## înceapă cu „deci". Ce face un om aici?
##
## Presupune. Ia o roată nehotărâtă și o cifră din cele rămase ei — să zicem
## „hai să zic că C e 4" — și o scrie cu creionul, nu cu pixul. Nu are niciun
## motiv s-o creadă: e o IPOTEZĂ, nu o deducție.
##
## Apoi dă drumul deducției obișnuite peste ipoteza asta, ca la o reacție în
## lanț: dacă C e 4, atunci indiciul cu suma cere ca B să fie 7 sau 8; dacă B e
## 7 sau 8, atunci indiciul cu paritatea scoate una din ele; și tot așa. Toată
## cascada asta e fix `_pana_se_opreste()` — adică T1 și T2, uneltele ieftine,
## rulate pe o stare INVENTATĂ.
##
## Se poate întâmpla una din două:
##
##   1. Lanțul se termină liniștit. N-ai aflat NIMIC — C chiar poate să fie 4.
##      Ștergi creionul și încerci altă cifră. (Aici e și motivul pentru care
##      tehnica e obositoare pentru un om: de cele mai multe ori nu iese nimic.)
##
##   2. Lanțul ajunge la o roată fără nicio cifră posibilă. Asta e
##      CONTRADICȚIA. O stare imposibilă nu poate ieși dintr-un puzzle corect,
##      iar tot ce am folosit ca s-ajungem acolo au fost indicii adevărate —
##      plus un singur lucru inventat. Vinovatul e obligatoriu invenția:
##      **C NU e 4.**
##
## Și ăsta e un fapt adevărat, obținut fără să știi nimic în plus. Îl tai din
## domeniul real, cu pixul.
##
## ─────────────────────────────────────────────────────────────
## DE CE SE OPREȘTE DUPĂ PRIMA TĂIETURĂ
##
## Fiindcă T3 nu rezolvă puzzle-ul — îl DEBLOCHEAZĂ. După ce a scos o cifră,
## de obicei T1 poate din nou să meargă singur o bucată bună de drum, și acolo
## trebuie să se întoarcă: la unealta ieftină. De-aia funcția întoarce imediat
## ce a reușit o eliminare, iar bucla din `noteaza()` urcă înapoi la T1.
##
## T3 e ranga, nu ciocanul. Un puzzle de nivel 3 nu e unul rezolvat „din
## presupuneri", ci unul care are nevoie de rangă în două-trei momente.
##
## ─────────────────────────────────────────────────────────────
## DE CE E O TEHNICĂ CINSTITĂ, ȘI NU GHICIT
##
## Pentru că nu păstrăm niciodată o presupunere care a MERS. Dacă lanțul se
## termină fără contradicție, nu concluzionăm „deci C e 4" — aia chiar ar fi
## ghicit, și ar putea fi greșit. Păstrăm doar concluziile NEGATIVE, iar o
## concluzie negativă obținută din contradicție e o demonstrație, nu un pariu.
##
## Ordinea (roata 0 spre ultima, cifrele crescător) e fixă și nu se trage cu
## zarul: altfel același puzzle ar primi note diferite la rulări diferite, iar
## tabelul de dificultate n-ar mai însemna nimic.
##
## Întoarce −1 dacă starea REALĂ e contradictorie, 1 dacă a eliminat o cifră,
## 0 dacă nicio presupunere n-a dus la contradicție.
static func _t3(domenii: Array, indicii: Array, roti: Array) -> int:
	for r in domenii.size():
		var domeniu: Array = domenii[r]
		if domeniu.size() <= 1:
			continue
		for cifra in domeniu:
			# Copie completă: presupunerea n-are voie să atingă starea reală.
			var proba := _copie(domenii)
			proba[r] = [cifra]
			if _pana_se_opreste(proba, indicii, roti, T2) < 0:
				var ramase := domeniu.duplicate()
				ramase.erase(cifra)
				if ramase.is_empty():
					# Fiecare cifră posibilă duce la contradicție: nu
					# presupunerea e vinovată, ci puzzle-ul.
					return -1
				domenii[r] = ramase
				return 1
	return 0


# ─────────────────────────────────────────────────────────────
# MOTORUL: O SINGURĂ TĂIERE
# ─────────────────────────────────────────────────────────────

## Taie din domenii tot ce nu poate face adevărate TOATE indiciile din `grup`.
##
## `roti` sunt pozițiile despre care vorbesc indiciile din grup. Funcția
## încearcă toate potrivirile posibile ale acelor roți (luate din domeniile lor
## CURENTE) și notează ce cifre au apărut măcar o dată într-o potrivire bună.
## Cifrele care n-au apărut niciodată nu mai au niciun sprijin: pentru ele nu
## mai există nicio lume în care indiciile să fie adevărate. Se taie.
##
## Roțile din afara grupului nu se ating: indiciile din grup nici nu se uită la
## ele. (Excepțiile sunt „nicio cifră nu se repetă" și „nicio cifră nu e mai
## mare decât A", care vorbesc despre TOATE roțile — iar pentru ele `_roti()`
## întoarce, corect, toate pozițiile.)
##
## Întoarce −1 dacă un domeniu a rămas gol (contradicție), altfel câte cifre a
## tăiat.
static func _propaga(domenii: Array, grup: Array, roti: Array) -> int:
	var cate_roti := roti.size()
	if cate_roti == 0:
		return 0

	var combinatii := 1
	for r in roti:
		combinatii *= domenii[int(r)].size()
	if combinatii > PLAFON_COMBINATII:
		return 0

	# Pentru fiecare roată din grup: ce cifre au fost văzute într-o potrivire
	# bună. `necesar` e câte cifre ar trebui sprijinite ca să nu tăiem nimic.
	var sustinute := []
	var necesar := 0
	for i in cate_roti:
		sustinute.append({})
		necesar += domenii[int(roti[i])].size()

	# Un cod de lucru, de mărimea lacătului. Pozițiile din grup se schimbă la
	# fiecare pas; celelalte rămân pe o valoare oarecare și nu sunt citite
	# niciodată de indiciile din grup.
	var cod := []
	for domeniu: Array in domenii:
		cod.append(domeniu[0])

	# CONTORUL DE KILOMETRAJ: `indici[i]` e poziția din domeniul roții `i`.
	# Îl rotim ca pe un contor de mașină — ultima cifră crește, iar când dă pe
	# dinafară o duce pe cea dinaintea ei. Așa parcurgem toate combinațiile fără
	# recursivitate și în aceeași ordine de fiecare dată.
	var indici := []
	indici.resize(cate_roti)
	indici.fill(0)

	var gasite := 0
	while true:
		for i in cate_roti:
			cod[int(roti[i])] = domenii[int(roti[i])][indici[i]]

		var bun := true
		for indiciu: Dictionary in grup:
			if not GeneratorCifru.evalueaza(indiciu, cod):
				bun = false
				break

		if bun:
			for i in cate_roti:
				var valoare: int = cod[int(roti[i])]
				var vazute: Dictionary = sustinute[i]
				if not vazute.has(valoare):
					vazute[valoare] = true
					gasite += 1
			# Toate cifrele au deja un sprijin: orice am mai găsi de acum nu
			# poate schimba nimic. Ieșirea asta devreme scutește grosul muncii
			# la indiciile slabe, care sunt majoritatea.
			if gasite == necesar:
				return 0

		var p := cate_roti - 1
		while p >= 0:
			indici[p] += 1
			if indici[p] < domenii[int(roti[p])].size():
				break
			indici[p] = 0
			p -= 1
		if p < 0:
			break

	var taiate := 0
	for i in cate_roti:
		var r := int(roti[i])
		var ramase := []
		for valoare in domenii[r]:
			if sustinute[i].has(valoare):
				ramase.append(valoare)
			else:
				taiate += 1
		if ramase.is_empty():
			return -1
		domenii[r] = ramase
	return taiate


# ─────────────────────────────────────────────────────────────
# DESPRE CE ROȚI VORBEȘTE UN INDICIU
# ─────────────────────────────────────────────────────────────

## Pozițiile atinse de un indiciu, în ordine crescătoare.
##
## E singurul loc din fișier care se uită la TIPUL unui indiciu. Tot restul
## trece prin `GeneratorCifru.evalueaza()`, adică prin aceeași regulă pe care o
## folosește și jocul când verifică ce ai tastat — deci rezolvitorul nu poate
## ajunge să creadă altceva decât lacătul.
##
## Un tip adăugat în generator și uitat aici s-ar purta ca un indiciu despre
## nicio roată: n-ar tăia nimic, puzzle-urile ar părea mai grele decât sunt.
## De-aia cazul necunoscut strigă în consolă în loc să întoarcă tăcut o listă
## goală.
static func _roti(indiciu: Dictionary, cifre: int) -> Array:
	match String(indiciu.get("tip", "")):
		GeneratorCifru.RELATIE, GeneratorCifru.DIFERENTA:
			var a := int(indiciu["a"])
			var b := int(indiciu["b"])
			return [mini(a, b), maxi(a, b)]
		GeneratorCifru.SUMA:
			var pozitii := []
			for p in indiciu["pozitii"]:
				pozitii.append(int(p))
			pozitii.sort()
			return pozitii
		GeneratorCifru.PARITATE:
			return [int(indiciu["a"])]
		GeneratorCifru.EXTREM, GeneratorCifru.FARA_REPETITIE:
			# „Nicio cifră nu e mai mare decât A" și „nicio cifră nu se repetă"
			# sunt afirmații despre tot lacătul, nu despre o poziție.
			var toate := []
			for i in cifre:
				toate.append(i)
			return toate
	push_error("RezolvitorCifru: nu stiu ce roti atinge indiciul: %s" % [indiciu])
	return []


## Au cele două liste de roți vreo poziție comună? Listele sunt sortate și
## scurte (cel mult 4-8), deci o parcurgere simplă e mai rapidă decât orice
## structură mai deșteaptă.
static func _se_ating(unele: Array, altele: Array) -> bool:
	for r in unele:
		if altele.has(r):
			return true
	return false


## Reuniunea a două liste sortate de roți, fără duplicate, tot sortată.
static func _reuniune(unele: Array, altele: Array) -> Array:
	var rezultat := unele.duplicate()
	for r in altele:
		if not rezultat.has(r):
			rezultat.append(r)
	rezultat.sort()
	return rezultat


# ─────────────────────────────────────────────────────────────
# MĂRUNȚIȘURI DE STARE
# ─────────────────────────────────────────────────────────────

## Au ajuns toate roțile la o singură cifră?
static func _gata(domenii: Array) -> bool:
	for domeniu: Array in domenii:
		if domeniu.size() != 1:
			return false
	return true


## Codul citit dintr-o stare rezolvată.
static func _cod_din(domenii: Array) -> Array:
	var cod := []
	for domeniu: Array in domenii:
		cod.append(domeniu[0])
	return cod


## Copie ADÂNCĂ a domeniilor: și lista de roți, și lista de cifre a fiecăreia.
##
## `domenii.duplicate()` (fără adâncime) ar copia lista exterioară, dar cele
## patru liste de cifre ar rămâne ACELEAȘI obiecte — iar o presupunere din T3
## ar tăia atunci direct în starea reală. E exact genul de greșeală care nu
## crapă nimic: puzzle-ul ar ieși „rezolvat", doar că din informație inventată.
static func _copie(domenii: Array) -> Array:
	var copie := []
	for domeniu: Array in domenii:
		copie.append(domeniu.duplicate())
	return copie

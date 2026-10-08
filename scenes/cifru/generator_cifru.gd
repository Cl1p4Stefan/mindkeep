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
##   1. Verificatorul din `tools/verificari/verifica_cifru.gd` poate bate generatorul pe
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
## nouă"), fiindcă dificultatea unui cifru are exact cinci numere:
##
##   `cifre`          — câte roți are lacătul;
##   `minim`, `maxim` — ce cifre are fiecare roată (INCLUSIV amândouă capetele);
##   `indicii_maxime` — câte rânduri de indicii încap pe ecran fără să devină
##                      o pagină de citit. E o limită de ECRAN și de răbdare,
##                      nu una matematică: generatorul reîncearcă până intră
##                      sub ea (vezi `genereaza()`);
##   `blocate`        — câte roți primești deja pe cifra corectă, sudate.
##
## DE CE TOATE NIVELURILE AU ACUM 4 ROȚI, 1-9. Fiindcă lacătul nu mai e un
## desen, e un CUFĂR: arta are patru ferestre tăiate în placa de metal, la
## poziții fixe. Un lacăt de 3 roți ar fi însemnat o fereastră goală, adică
## exact genul de mică minciună vizuală pe care nimeni n-o poate ignora. Iar
## cifra 0 a ieșit fiindcă o roată de cifru de cufăr arată 1-9; e o convenție
## veche și n-are rost contrazisă pentru un singur simbol în plus.
##
## CE A RĂMAS SĂ DEOSEBEASCĂ NIVELURILE, atunci: **cât de greu se DEDUCE codul**.
## Nu câte indicii are.
##
## Asta e o schimbare de fond față de prima versiune, și merită povestită,
## fiindcă e o lecție de design care se repetă peste tot.
##
## La început, nivelurile se deosebeau prin `indicii_maxime`: nivelul 3 primea
## cel mult 3 rânduri, pe ideea că mai puțină informație înseamnă mai mult de
## gândit. Ideea era greșită, și se vede de ce dacă te uiți la ce face
## `_o_incercare()`: alege de fiecare dată indiciul care taie CEL MAI MULT din
## codurile rămase. Campionul absolut la tăiat e egalitatea („A și B sunt
## egale") — scoate 8 din 9 coduri dintr-o lovitură. Cerându-i generatorului să
## încapă în 3 rânduri, îl obligam să aleagă numai indicii brutale. Două
## egalități și o sumă, și codul pica singur. Nivelul „greu" era cel mai ușor
## dintre toate, exact din cauza plafonului pus ca să-l facă greu.
##
## Deci plafonul a plecat, iar dificultatea se MĂSOARĂ acum, cu
## `RezolvitorCifru`: un rezolvitor care deduce ca un om și spune de ce tehnică
## a avut nevoie. Trei câmpuri noi în tabel:
##
##   `nota`             — ce trebuie să ceară puzzle-ul ca să fie păstrat:
##                        T1 (fiecare rând se storce singur), T2 (trebuie
##                        combinate două rânduri), T3 (trebuie să presupui o
##                        cifră și să dai de contradicție). Un puzzle cu altă
##                        notă e aruncat și se încearcă altul.
##   `alegere`          — cum alege `_o_incercare()` următorul indiciu:
##                        "lacom" ia mușcătura cea mai mare (puzzle-uri scurte
##                        și tari), "cumpatat" ia unul la întâmplare dintre
##                        cele care mai taie ceva (puzzle-uri mai lungi și mai
##                        subtile). Fără "cumpatat" la nivelul 3, filtrul de
##                        notă ar respinge aproape tot: alegerea lacomă produce
##                        din construcție puzzle-uri de nota T1.
##   `egalitati_maxime` — câte indicii „exacte" (orice semn „=", plus
##                        DIFERENTA) încap în concurs. −1 = fără limită.
##                        Egalitățile sunt utile, dar două dintre ele aproape
##                        că dictează codul.
##
##   nivelul 1 — o roată e deja pusă și SUDATĂ. Rămân 3 cifre de dedus dintr-un
##               spațiu de 729 de coduri (în loc de 6561), și fiecare rând se
##               storce de unul singur. E lacătul „de învățat cum funcționează".
##   nivelul 2 — toate patru de dedus. Undeva pe drum va trebui să pui două
##               rânduri cap la cap; niciunul singur nu te mai duce mai departe.
##   nivelul 3 — toate patru, și cel puțin o dată rămâi complet blocat: ai
##               stors fiecare rând, le-ai combinat două câte două, și tot nu
##               poți continua. Acolo trebuie să presupui o cifră pe hârtie și
##               să vezi unde se rupe socoteala.
##
## `indicii_maxime` a rămas, dar și-a recăpătat înțelesul onest: e o limită de
## ECRAN și de răbdare (câte rânduri încap fără să devină o pagină de citit),
## nu o pârghie de dificultate. Pârghiile de dificultate sunt `nota` și
## `alegere`.
const NIVELURI := [
	{"cifre": 4, "minim": 1, "maxim": 9, "indicii_maxime": 6, "blocate": 1,
		"nota": RezolvitorCifru.T1, "alegere": "lacom", "egalitati_maxime": -1},
	{"cifre": 4, "minim": 1, "maxim": 9, "indicii_maxime": 6, "blocate": 0,
		"nota": RezolvitorCifru.T2, "alegere": "lacom", "egalitati_maxime": -1},
	{"cifre": 4, "minim": 1, "maxim": 9, "indicii_maxime": 8, "blocate": 0,
		"nota": RezolvitorCifru.T3, "alegere": "cumpatat", "egalitati_maxime": 1,
		"candidati": 55, "deschidere_lacoma": 2},
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
##   fiecare cod din sondă. Cu toată grămada în concurs, verificatorul ar dura
##   de două ori mai mult fără să producă puzzle-uri mai bune.
##
## E o VALOARE IMPLICITĂ: un nivel o poate rescrie prin câmpul `candidati` din
## tabel. Nivelul 3 o rescrie, fiindcă alegerea „cumpătată" arde candidați mult
## mai repede decât cea lacomă — ia indicii slabe, deci are nevoie de mai multe
## ca să ajungă la un singur cod. Cu doar 20, majoritatea încercărilor de nivel
## 3 rămâneau fără candidați înainte să izoleze codul și se aruncau degeaba.
const CANDIDATI := 20

## CÂTE PRAGURI DIFERITE se nasc pentru aceeași sumă (vezi `_candidati()`).
## Trei, fiindcă e diferența dintre un pool de vreo 40 de afirmații și unul de
## vreo 70 — iar nivelul 3, unde egalitățile sunt plafonate, trăiește din ele.
## Mai multe n-ar strica, dar ar umple eșantionul cu variații ale aceleiași
## sume în loc de idei diferite.
const PRAGURI_PE_SUMA := 3

## De câte ori reîncercăm până ne mulțumim cu ce avem.
##
## O încercare poate să nu iasă din trei motive cinstite: eșantionul de
## candidați nu conține destulă informație cât să izoleze un singur cod;
## izolează, dar cu prea multe indicii; sau iese un puzzle corect, doar că de
## altă dificultate decât cere nivelul. Toate trei se rezolvă cu alt eșantion,
## deci cu altă sub-sămânță.
##
## Al treilea motiv e cel nou, și e și cel scump: la nivelul 3 cerem T3, iar un
## puzzle care chiar te blochează nu iese la fiecare aruncare de zar. De-aia
## numărul a urcat de la 12 la 60 — nu fiindcă generatorul ar fi devenit
## nesigur, ci fiindcă acum are un examen de trecut, nu doar o formă de
## respectat.
##
## Numărul ăsta rămâne totuși un BUGET DE TIMP, nu o măsură de siguranță. Dacă
## îl ridici și mai mult, semințele nefericite vor primi puzzle-ul potrivit, dar
## vor sta și mai mult la generat — iar generarea se face pe un fir separat
## tocmai fiindcă poate dura. Dacă vezi că se atinge des maximul, semn că
## `alegere` sau `egalitati_maxime` sunt prost reglate pentru nota cerută; nu
## numărul ăsta e de vină.
const INCERCARI_MAXIME := 60


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
# `indiciu_care_da_o_cifra()` verifică regula asta la propriu, la final.
# ─────────────────────────────────────────────────────────────

## `{a, b, semn}` — cifra de pe poziția `a` față de cea de pe `b`: ">", "<", "=".
const RELATIE := "RELATIE"

## `{a, b, valoare}` — cod[a] − cod[b] == valoare (valoare > 0 mereu).
const DIFERENTA := "DIFERENTA"

## `{pozitii, semn, valoare}` — suma cifrelor de pe pozițiile date, comparată
## cu un număr: „A + C + D e mai mică decât 17".
##
## DE CE UN SINGUR TIP PENTRU TOATE SUMELE. Au fost, la început, două tipuri
## separate: suma a două roți și suma tuturor. Când a apărut nevoia de sume de
## TREI (indiciile cele mai bune pentru nivelul 3: vorbesc despre trei roți, dar
## îți spun implicit ceva și despre a patra), al treilea tip ar fi însemnat a
## treia copie a aceleiași idei — în `evalueaza()`, în `text()`, în
## `_candidati()`. Iar un lacăt de 5 roți ar fi cerut a patra.
##
## Cu `pozitii` ca listă, „suma a k roți" e o BUCLĂ, nu un tip. E aceeași regulă
## ca la discipline, din CLAUDE.md: ceva nou trebuie să fie un rând în date, nu
## o ramură nouă în cod.
const SUMA := "SUMA"

## `{a, para}` — cifra de pe poziția `a` e pară (sau impară).
const PARITATE := "PARITATE"

## `{a, maxim}` — nicio cifră nu e mai mare (sau mai mică) decât cea de pe `a`.
## „Nu e mai mare", nu „e strict cea mai mare": așa rămâne adevărat și când două
## roți au aceeași cifră, deci indiciul se poate genera pentru orice cod.
const EXTREM := "EXTREM"

## `{}` — toate cifrele sunt diferite. Singurul tip fără parametri.
const FARA_REPETITIE := "FARA_REPETITIE"


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
	# mai scumpă construcție din fișier (6561 de mici `Array`-uri: 9⁴) și nu
	# depinde de nimic din ce se schimbă între încercări.
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

		# Ce roată e sudată pe cifra ei, sau −1. Se trage tot din `rng`, deci
		# ține de sămânță ca tot restul: același cifru are mereu aceeași roată
		# blocată.
		var blocata := -1
		if int(spec.get("blocate", 0)) > 0:
			blocata = rng.randi_range(0, int(spec["cifre"]) - 1)

		# UNIVERSUL: codurile pe care puzzle-ul trebuie să le deosebească.
		# Fără roată blocată sunt toate. Cu o roată blocată, jucătorul VEDE deja
		# cifra aia, deci codurile care n-o au sunt eliminate înainte să înceapă
		# — iar unicitatea trebuie cerută AICI, nu în mulțimea mare. Altfel i-am
		# cere să deducă ceva ce are deja sub ochi.
		var universul := universul(toate, cod, blocata)

		var indicii := _o_incercare(cod, universul, spec, rng, blocata)
		if indicii.is_empty():
			continue

		# Plasa de siguranță a regulii „niciun indiciu nu dă direct o cifră".
		# Candidații sunt deja filtrați unul câte unul (vezi `_candidati()`), dar
		# regula e prea importantă ca să fie apărată într-un singur loc.
		if indiciu_care_da_o_cifra(indicii, universul, blocata) != -1:
			continue

		# Ordinea în care le-a ales alegerea lacomă e „de la cel mai tare la cel
		# mai slab" — o informație pe care jucătorul n-are de ce s-o primească
		# gratis. Amestecul o șterge.
		_amesteca(indicii, rng)

		var puzzle := _puzzle(spec, nivel, samanta, cod, indicii, blocata,
			incercare + 1, false)

		# ── EXAMENUL DE DIFICULTATE ───────────────────────────
		#
		# Puzzle-ul e deja corect: unic, fără indicii de prisos, fără vreun rând
		# care să dicteze o cifră. Întrebarea care a mai rămas e singura care
		# contează pentru jucător: cât de greu se deduce?
		#
		# Rezolvitorul îl rezolvă ca un om și spune de ce tehnică a avut nevoie.
		# Dacă nota nu e cea cerută de nivel, puzzle-ul e perfect bun — doar că
		# nu e bun AICI. Se aruncă și se încearcă altul.
		#
		# `rezolvat == false` înseamnă că un om care gândește cu T1-T3 rămâne
		# blocat. Puzzle-ul are soluție (forța brută a dovedit-o), dar n-are
		# DRUM către ea — ai ajunge să ghicești. Ăla nu e un lacăt greu, e un
		# lacăt nedrept, și se aruncă fără să ajungă nici măcar rezervă.
		var raport := RezolvitorCifru.noteaza(puzzle)
		if not bool(raport["rezolvat"]):
			continue
		puzzle["nota"] = int(raport["nota"])

		if int(raport["nota"]) == int(spec["nota"]) \
				and indicii.size() <= int(spec["indicii_maxime"]):
			return puzzle

		# REZERVA: cel mai bun rezultat de până acum, dacă nimic n-a trecut
		# examenul. Se preferă puzzle-ul cu nota cea mai apropiată de cea
		# cerută, iar la note egale cel mai scurt. Un lacăt corect de altă
		# dificultate e infinit mai bun decât niciun lacăt — jucătorul pierde o
		# nuanță de reglaj, nu evenimentul.
		if rezerva.is_empty() or _mai_bun(puzzle, rezerva, int(spec["nota"]),
				int(spec["indicii_maxime"])):
			rezerva = puzzle

	if rezerva.is_empty():
		# N-a ieșit NIMIC în toate încercările. Nu e ghinion — e semn că tabelul
		# de dificultate cere ceva imposibil (un interval de o singură cifră, de
		# pildă). Mesajul din consolă e tot ce ajută atunci.
		push_error("GeneratorCifru: niciun cifru bun in %d incercari (nivel %d, samanta %d)."
			% [INCERCARI_MAXIME, nivel, samanta])
		return {}

	push_warning(("GeneratorCifru: nivel %d, samanta %d — n-a iesit un cifru de nota %s "
		+ "sub %d indicii. Se joaca cel mai apropiat: nota %s, %d indicii. Daca vezi des "
		+ "avertismentul, `alegere` sau `egalitati_maxime` sunt prost reglate pentru nota "
		+ "ceruta; nu semintele sunt de vina.")
		% [nivel, samanta, RezolvitorCifru.nume_nota(int(spec["nota"])),
			int(spec["indicii_maxime"]),
			RezolvitorCifru.nume_nota(int(rezerva.get("nota", 0))),
			rezerva["indicii"].size()])
	rezerva["la_limita"] = true
	rezerva["incercari"] = INCERCARI_MAXIME
	return rezerva


## Care dintre două puzzle-uri respinse e mai aproape de ce cerea nivelul?
##
## Întâi nota: distanța până la nota cerută (o notă alăturată e o nuanță, două
## note mai jos e alt joc). La note la fel de apropiate, cel mai scurt — fiindcă
## acolo criteriul care mai contează e să încapă pe ecran.
static func _mai_bun(candidat: Dictionary, actual: Dictionary, nota_ceruta: int,
		indicii_maxime: int) -> bool:
	var d_candidat: int = absi(int(candidat.get("nota", 0)) - nota_ceruta)
	var d_actual: int = absi(int(actual.get("nota", 0)) - nota_ceruta)
	if d_candidat != d_actual:
		return d_candidat < d_actual
	# La note egale, contează doar dacă încape pe ecran; dincolo de maxim, mai
	# scurt e mai bine.
	var l_candidat: int = maxi(candidat["indicii"].size() - indicii_maxime, 0)
	var l_actual: int = maxi(actual["indicii"].size() - indicii_maxime, 0)
	return l_candidat < l_actual


## Forma finală a puzzle-ului. Un singur loc care o construiește, ca să nu
## existe două variante ale aceluiași dicționar, cu chei diferite.
static func _puzzle(spec: Dictionary, nivel: int, samanta: int, cod: Array,
		indicii: Array, blocata: int, incercari: int, la_limita: bool) -> Dictionary:
	return {
		"nivel": nivel,
		"samanta": samanta,
		"cifre": int(spec["cifre"]),
		"minim": int(spec["minim"]),
		"maxim": int(spec["maxim"]),
		"cod": cod,
		"indicii": indicii,
		# Ce roată e sudată pe cifra corectă, sau −1 dacă niciuna. Cifra ei e
		# `cod[blocata]` — nu se salvează separat, fiindcă ar fi același adevăr
		# scris de două ori, cu șansa ca cele două să se despartă.
		"blocata": blocata,
		# Cea mai grea tehnică de care are nevoie deducția (vezi
		# `RezolvitorCifru`). Se completează imediat după, în `genereaza()`;
		# cheia e declarată aici ca forma dicționarului să fie aceeași de
		# fiecare dată, indiferent pe ce drum a ieșit puzzle-ul.
		"nota": RezolvitorCifru.NIMIC,
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
## Ai o mulțime de 6561 de coduri posibile și o mână de afirmații adevărate
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
## ─────────────────────────────────────────────────────────────
## „CUMPĂTAT": DE CE ALEGEREA LACOMĂ NU POATE FACE PUZZLE-URI GRELE
##
## Tot ce scrie mai sus e adevărat și rămâne — dar are un efect secundar pe care
## nu-l vezi până nu măsori dificultatea: alegerea lacomă produce, din
## construcție, puzzle-uri UȘOARE.
##
## Gândește-te ce înseamnă „indiciul care taie cel mai mult". Un indiciu care
## reduce 6561 de coduri la 700 e un indiciu care spune aproape totul despre o
## roată. Trei la rând, și fiecare roată are un rând al ei care o rezolvă
## singură — adică exact definiția lui T1, cea mai ușoară tehnică. Nu ai cum să
## rămâi blocat într-un puzzle în care fiecare rând îți dă un răspuns.
##
## Un puzzle care te blochează are nevoie de contrariul: indicii SLABE, care
## fiecare taie puțin și niciunul nu decide nimic singur. De-aia există al
## doilea mod:
##
##   "lacom"    — ia mușcătura cea mai mare. Puzzle-uri scurte, tari, T1/T2.
##   "cumpatat" — merge printr-o ordine trasă la sorți, sărind doar peste
##                indiciile care nu mai taie nimic. Puzzle-uri mai lungi, cu
##                rânduri care se sprijină unul pe altul. Aici crește T3.
##
## Singura condiție păstrată în amândouă modurile e „să taie ceva": un indiciu
## care nu elimină niciun cod ar fi redundant din start, iar `_curata()` l-ar
## scoate oricum la final.
##
## CE NU DEPINDE DE MOD, și de-aia „cumpătat" e o schimbare fără risc: toate
## garanțiile puzzle-ului — soluție unică, niciun indiciu de prisos, niciun rând
## care dictează o cifră — ies din faptul că ne oprim abia când a rămas UN
## SINGUR COD, și din pașii de după. Nu din felul în care alegem. „Cumpătat"
## poate produce un puzzle mai lung sau mai greu; nu poate produce unul stricat.
##
## Întoarce un Array gol dacă eșantionul de candidați nu izolează codul.
static func _o_incercare(cod: Array, universul: Array, spec: Dictionary,
		rng: RandomNumberGenerator, blocata := -1) -> Array:
	var candidati := _candidati(cod, spec, rng, universul, blocata)
	var cumpatat := String(spec.get("alegere", "lacom")) == "cumpatat"
	var deschidere := int(spec.get("deschidere_lacoma", 0))
	# Ordinea în care modul cumpătat consumă candidații: o singură amestecare,
	# la început. Vezi `_urmatorul()`.
	var ordine := []
	for k in candidati.size():
		ordine.append(k)
	_amesteca(ordine, rng)
	var folositi := {}
	var posibile := universul
	var alese := []

	while posibile.size() > 1:
		# CÂNTĂRIREA SE FACE PE O SONDĂ, nu pe toată mulțimea (vezi `_sonda()`).
		# Tăierea de mai jos rămâne exactă; doar COMPARAȚIA dintre candidați e
		# făcută pe un eșantion.
		var sonda := _sonda(posibile)
		# DESCHIDEREA LACOMĂ: primele câteva tăieturi se iau cu mușcătura cea
		# mai mare chiar și în modul cumpătat. Nicăieri nu stă dificultatea în
		# prima tăietură — oricum ai lua-o, rămâi cu sute de coduri posibile și
		# nicio roată hotărâtă. Ce câștigi în schimb e enorm: fără ea, plimbarea
		# cumpătată pornea de la 6561 de coduri cu mușcături mici și aduna
		# 30-40 de indicii până să izoleze codul, iar curățarea de după trebuia
		# să-i cearnă pe toți. Cu două tăieturi lacome la început, plimbarea
		# pornește de la câteva sute și se termină în 6-8 indicii.
		var acum_lacom := not cumpatat or alese.size() < deschidere
		var ales := _alege_lacom(candidati, folositi, sonda) if acum_lacom \
			else _urmatorul(candidati, ordine, folositi, sonda)

		if ales == -1:
			# Niciun candidat rămas nu mai taie nimic: codurile care au
			# supraviețuit sunt, pentru eșantionul ăsta, de nedeosebit între ele.
			# Nu e o eroare — e un eșantion sărac. Altă sub-sămânță.
			return []

		alese.append(candidati[ales])
		folositi[ales] = true
		posibile = _filtreaza(candidati[ales], posibile)

	return _curata(alese, universul)


## Alegerea LACOMĂ: candidatul care lasă cele mai puține coduri în picioare.
##
## Pragul pornește de la câte coduri are sonda: un candidat care lasă tot atâtea
## nu taie nimic, deci nu merită ales. Așa, o singură comparație („mai mic decât
## pragul") înseamnă și „cel mai bun de până acum", și „chiar taie ceva".
static func _alege_lacom(candidati: Array, folositi: Dictionary, sonda: Array) -> int:
	var cel_mai_bun := -1
	var cate_ramane := sonda.size()
	for k in candidati.size():
		if folositi.has(k):
			continue
		var cate := _cate_trec(candidati[k], sonda)
		if cate < cate_ramane:
			cate_ramane = cate
			cel_mai_bun = k
	return cel_mai_bun


## Alegerea CUMPĂTATĂ: următorul candidat nefolosit CARE MAI TAIE CEVA, dintr-o
## ordine trasă la sorți o singură dată, la începutul încercării.
##
## Nu cântărește candidații ca să-l aleagă pe cel mai bun — ăsta e tot rostul
## modului. Îi cere doar să nu fie inutil, și pentru asta îl măsoară O SINGURĂ
## DATĂ în toată încercarea: un indiciu care nu taie nimic ACUM nu va tăia nimic
## nici mai târziu, fiindcă mulțimea codurilor posibile doar se micșorează de
## aici înainte. Deci îl scoatem din joc pe loc, nu-l mai întrebăm la runda
## următoare.
##
## Fără condiția asta, plimbarea aduna cincizeci de indicii înainte de curățare
## — iar `_curata()`, care le încearcă pe fiecare pe rând, ajungea la cinci
## secunde de o singură chemare. Cu ea, lista rămâne pe la zece.
##
## Măsurătoarea e pe SONDĂ, adică pe un eșantion (vezi `_sonda()`), deci teoretic
## un indiciu ar putea tăia un cod pe care sonda nu-l conține și să fie scos pe
## nedrept. În practică nu se întâmplă: sonda e mulțimea întreagă de îndată ce
## au rămas sub 1500 de coduri, iar modul cumpătat intră în joc abia după
## deschiderea lacomă, care coboară mult sub pragul ăsta. Iar dacă totuși s-ar
## întâmpla, cel mai rău lucru posibil e o încercare aruncată.
static func _urmatorul(candidati: Array, ordine: Array, folositi: Dictionary,
		sonda: Array) -> int:
	for k in ordine:
		if folositi.has(k):
			continue
		if _cate_trec(candidati[k], sonda) < sonda.size():
			return k
		folositi[k] = true
	return -1


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
##
## ─────────────────────────────────────────────────────────────
## LANȚUL DE PREFIXE, sau cum să nu faci de zece ori aceeași muncă
##
## Varianta simplă a funcției ăsteia scotea indiciul `i` și număra soluțiile de
## la zero, pornind de fiecare dată de la toate cele 6561 de coduri. Adică
## refăcea, pentru fiecare `i`, filtrarea cu indiciile dinaintea lui — care era
## exact aceeași de fiecare dată.
##
## `prefix[k]` ține codurile care trec de PRIMELE `k` indicii. E un lanț:
## `prefix[0]` e universul întreg, iar fiecare verigă se naște filtrând-o pe
## cea dinainte. Ca să încercăm scoaterea indiciului `i`, pornim direct de la
## `prefix[i]` (deja calculat, și deja mic) și mai filtrăm doar cu indiciile de
## DUPĂ el.
##
## Când un indiciu chiar se scoate, verigile de dinaintea lui rămân valabile —
## ele nu știu nimic despre ce vine după. Se aruncă doar coada lanțului.
##
## Curățarea era, înainte de asta, aproape trei sferturi din timpul de generare
## al nivelului 3.
static func _curata(alese: Array, universul: Array) -> Array:
	var rezultat := alese.duplicate()
	# Lanțul, construit leneș: `prefix[k]` apare abia când ajungem la el.
	var prefix := [universul]
	var i := 0

	while i < rezultat.size():
		# Codurile care trec de TOATE indiciile în afară de al `i`-lea: pornim
		# din veriga `i` a lanțului și filtrăm cu cele de după.
		var ramase: Array = prefix[i]
		for k in range(i + 1, rezultat.size()):
			ramase = _filtreaza(rezultat[k], ramase)
			if ramase.size() < 2:
				break   # a rămas un singur cod: știm deja răspunsul

		if ramase.size() == 1:
			# Soluția rămâne unică fără el: era decor. Nu creștem `i` — lista
			# s-a scurtat, iar pe poziția asta e acum indiciul următor. Coada
			# lanțului nu mai corespunde, deci o tăiem.
			rezultat.remove_at(i)
			prefix.resize(i + 1)
		else:
			# Rămâne. Mergem mai departe și lungim lanțul cu o verigă.
			if prefix.size() <= i + 1:
				prefix.append(_filtreaza(rezultat[i], prefix[i]))
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
static func _candidati(cod: Array, spec: Dictionary, rng: RandomNumberGenerator,
		universul: Array, blocata := -1) -> Array:
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

	# ── Sumele: de două, de trei, de toate roțile ─────────────
	#
	# O singură buclă peste TOATE submulțimile de cel puțin două roți. Pentru
	# lacătul de 4 roți asta înseamnă 6 perechi + 4 triplete + 1 total = 11
	# submulțimi, fiecare cu până la două afirmații (una exactă, una cu prag).
	#
	# Tripletele sunt aici pentru nivelul 3, și sunt cele mai frumoase indicii
	# din tot lacătul: „A + C + D e mai mică decât 17" nu-ți spune nimic despre
	# nicio roată anume, dar te obligă să ții minte ceva despre TREI deodată —
	# și, pe ocolite, îți spune ceva și despre a patra.
	for pozitii: Array in _submultimi(n):
		var s := 0
		for p in pozitii:
			s += int(cod[int(p)])
		var k := pozitii.size()
		# Suma exactă, dar nu la capetele intervalului: „A + B e exact 2" pe un
		# lacăt 1-6 înseamnă că amândouă sunt 1, adică două cifre dictate.
		if s > k * minim and s < k * maxim:
			pool.append({"tip": SUMA, "pozitii": pozitii.duplicate(),
				"semn": "=", "valoare": s})
		# MAI MULTE PRAGURI PE ACEEAȘI SUMĂ, nu unul singur.
		#
		# „A + C + D e mai mică decât 19" și „A + C + D e mai mare decât 12"
		# sunt două afirmații diferite despre aceeași sumă, cu puteri diferite,
		# și amândouă adevărate. Un singur prag tras cu zarul lăsa poolul
		# nivelului 3 înfometat: acolo egalitățile sunt plafonate, deci
		# inegalitățile sunt aproape tot ce rămâne, iar cu una pe sumă
		# majoritatea încercărilor nu izolau niciun cod și se aruncau.
		#
		# Pragurile duplicate se sar: același prag de două ori ar fi același
		# rând scris de două ori pe ecran.
		var vazute_praguri := {}
		for incercare in PRAGURI_PE_SUMA:
			var inegalitate := _prag(rng, s, k * minim, k * maxim)
			if inegalitate.is_empty():
				break
			var cheie := "%s%d" % [inegalitate["semn"], inegalitate["valoare"]]
			if vazute_praguri.has(cheie):
				continue
			vazute_praguri[cheie] = true
			inegalitate["tip"] = SUMA
			inegalitate["pozitii"] = pozitii.duplicate()
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

	_amesteca(pool, rng)

	# VAMA: niciun candidat care, de unul singur, fixează o cifră.
	#
	# Regulile aritmetice de mai sus (diferența maximă, suma la capăt) prind
	# cazurile evidente, dar nu pot prinde cazul apărut odată cu roata blocată:
	# „A e cu 2 mai mare decât B", cu B sudată pe 5, îți DĂ un 7. Propoziția e
	# despre o relație, dar efectul e o dictare — iar efectul e ce contează.
	#
	# De-aia filtrul întreabă mulțimea, nu forma indiciului, și o întreabă pe
	# UNIVERS (mulțimea restrânsă de roata blocată), nu pe toate codurile. Costă
	# puțin: `da_o_cifra()` se oprește la primul cod care arată că fiecare
	# poziție are cel puțin două valori posibile, ceea ce se întâmplă, pentru un
	# indiciu cinstit, în câteva zeci de coduri.
	# A DOUA VAMĂ: câte indicii „exacte" au voie în concurs.
	#
	# O egalitate e o afirmație care leagă două lucruri cu semnul „=": „A și B
	# sunt egale", „A + C e exact 11", „A e cu 2 mai mare decât D". Toate taie
	# brutal — și tocmai de-aia alegerea lacomă le adoră. Două dintre ele
	# ajung aproape să dicteze codul, iar puzzle-ul devine o socoteală, nu o
	# deducție.
	#
	# Limita se aplică după SEMN, nu după tipul indiciului: un „=" e un „="
	# indiferent dacă vorbește despre o relație sau despre o sumă, iar
	# DIFERENTA e o ecuație exactă chiar dacă n-are semnul scris în ea.
	# Verificarea după tip ar fi o listă de nume care rămâne în urmă la primul
	# tip nou; verificarea după semn ține de la sine.
	#
	# `egalitati_maxime == -1` înseamnă „fără limită" (nivelurile 1 și 2).
	# Limita e pe CANDIDAȚI, nu pe puzzle-ul final: dacă intră în concurs cel
	# mult una, în puzzle nu poate ajunge mai mult de una. Se apără la intrare,
	# nu la ieșire — la ieșire ar însemna să arunci o încercare bună.
	var plafon_egalitati := int(spec.get("egalitati_maxime", -1))
	var cati := int(spec.get("candidati", CANDIDATI))
	var egalitati := 0

	var alesi := []
	for indiciu: Dictionary in pool:
		if alesi.size() >= cati:
			break
		if da_o_cifra(indiciu, universul, blocata):
			continue
		if e_egalitate(indiciu):
			if plafon_egalitati >= 0 and egalitati >= plafon_egalitati:
				continue
			egalitati += 1
		alesi.append(indiciu)
	return alesi


## TOATE SUBMULȚIMILE DE CEL PUȚIN DOUĂ ROȚI, în ordine fixă.
##
## Numărăm în binar de la 0 la 2ⁿ−1 și citim fiecare număr ca pe un set de
## întrerupătoare: bitul `i` aprins înseamnă „roata `i` face parte". E cel mai
## scurt mod de a le enumera pe toate, o singură dată fiecare, fără
## recursivitate — și e DETERMINIST, ceea ce contează aici la fel de mult ca
## peste tot în fișier.
##
## Submulțimile de 0 și de 1 element se sar: „suma cifrei A e 6" ar fi exact
## indiciul care dictează o cifră, adică singura regulă de design pe care
## lacătul n-o încalcă.
static func _submultimi(n: int) -> Array:
	var rezultat := []
	for masca in range(1, 1 << n):
		var pozitii := []
		for i in n:
			if masca & (1 << i) != 0:
				pozitii.append(i)
		if pozitii.size() >= 2:
			rezultat.append(pozitii)
	return rezultat


## E indiciul o EGALITATE — adică o afirmație exactă, nu una cu joc în ea?
##
## Două forme: orice indiciu cu semnul „=" (relație, sumă) și DIFERENTA, care e
## o ecuație („A − D = 2") chiar dacă nu poartă semnul scris.
##
## Publică fiindcă verificatorul are nevoie de EXACT aceeași definiție. Dacă
## și-ar scrie-o pe a lui, în ziua în care apare un tip nou cele două s-ar
## despărți, iar raportul ar declara curate niveluri care nu mai sunt.
static func e_egalitate(indiciu: Dictionary) -> bool:
	if String(indiciu.get("tip", "")) == DIFERENTA:
		return true
	return String(indiciu.get("semn", "")) == "="


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
#   1. MULȚIMEA E MINUSCULĂ. Lacătul din joc are 4 roți × 9 cifre = 9⁴ = 6561
#      de coduri (729, când o roată e blocată). Un calculator le parcurge de
#      mii de ori pe secundă. (Un lacăt de 6 roți ar avea peste jumătate de
#      milion — de-aia tabelul de dificultate e o listă scurtă, nu o invitație
#      la orice.)
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


## SONDA: un eșantion din mulțimea încă posibilă, pe care se CÂNTĂRESC
## candidații. Tăierea propriu-zisă se face mereu pe mulțimea întreagă.
##
## DE CE. Prima rundă a alegerii lacome întreabă fiecare candidat despre fiecare
## cod posibil: 20 × 6561. E partea cea mai scumpă din tot generatorul, și e
## cheltuită pe o întrebare care nu are nevoie de precizie: „care candidat taie
## cel mai mult?". Diferența dintre „taie 5900" și „taie 5880" nu schimbă nicio
## decizie — iar pe 1500 de coduri luate din nouă în nouă ordinea candidaților
## iese practic aceeași.
##
## DE CE E SIGUR. Nimic din ce garantează puzzle-ul nu trece pe aici:
## `_filtreaza()` taie pe mulțimea întreagă, `_curata()` verifică pe mulțimea
## întreagă, iar unicitatea finală e tot pe mulțimea întreagă. Sonda poate cel
## mult să facă alegerea lacomă să aleagă al doilea cel mai bun candidat —
## adică exact greșeala pe care metoda lacomă o face oricum, prin natura ei, și
## pe care o repară pasul de curățare.
##
## DE CE DIN NOUĂ ÎN NOUĂ, și nu la întâmplare: un eșantion tras cu zarul ar
## avea nevoie de RNG în mijlocul unei bucle fierbinți, iar unul „primele 1500"
## ar fi toate codurile care încep la fel (lista e ordonată ca un număr). Pasul
## trebuie doar să nu fie multiplu de 3: cifrele merg de la 1 la 9, iar un pas
## divizibil cu 3 ar atinge mereu aceleași resturi, deci ar vedea numai o parte
## din valorile ultimei roți.
## DE CE A SCĂZUT DE LA 1500 LA 400. Prima rundă a alegerii lacome întreabă
## fiecare candidat despre fiecare cod din sondă, iar nivelul 3 pune în concurs
## 55 de candidați: 55 × 1500 de verificări, într-o singură rundă, repetate la
## fiecare încercare. Era jumătate din timpul de generare.
##
## Iar precizia pe care o plăteam acolo nu cumpăra nimic. Întrebarea e „care
## candidat taie cel mai mult?", și pe 200 de coduri luate din loc în loc
## ordinea iese practic aceeași ca pe 1500. Singura urmare posibilă e ca
## alegerea lacomă să ia al doilea cel mai bun candidat în loc de primul — adică
## exact greșeala pe care metoda lacomă o face oricum, prin natura ei, și pe
## care o repară pasul de curățare.
const ESANTION_ALEGERE := 200

static func _sonda(lista: Array) -> Array:
	if lista.size() <= ESANTION_ALEGERE:
		return lista
	var pas: int = lista.size() / ESANTION_ALEGERE
	if pas % 3 == 0:
		pas += 1
	var esantion := []
	var i := 0
	while i < lista.size():
		esantion.append(lista[i])
		i += pas
	return esantion


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
##
## DE CE FILTREAZĂ ÎN LANȚ, ȘI NU CU DOUĂ BUCLE ÎNCRUCIȘATE.
##
## Varianta evidentă e „pentru fiecare cod, verifică fiecare indiciu". E
## corectă, și a fost aici mult timp — dar face aceeași muncă de n ori: fiecare
## dintre cele 6561 de coduri e întrebat despre TOATE indiciile.
##
## Varianta de aici taie mulțimea pas cu pas: primul indiciu vede toate cele
## 6561 de coduri, dar lasă în urmă vreo 700; al doilea vede doar acele 700 și
## lasă 90; al treilea vede 90. Suma muncii e ~7400 de verificări în loc de
## ~30000, și diferența crește cu numărul de indicii.
##
## Nu e o subtilitate de performanță de dragul performanței. Funcția asta e
## chemată de `_curata()` o dată pentru FIECARE indiciu al FIECĂREI încercări,
## iar de când nivelul 3 generează puzzle-uri lungi înainte de curățare, ea
## singură era jumătate din timpul de generare.
static func cate_solutii_pentru(indicii: Array, toate: Array, plafon := 2) -> int:
	var ramase := toate
	for indiciu: Dictionary in indicii:
		ramase = _filtreaza(indiciu, ramase)
		if ramase.is_empty():
			return 0
	return mini(ramase.size(), plafon)


## Câte soluții are un puzzle întreg. Pentru verificator; în joc nu e nevoie de
## ea, fiindcă generatorul garantează deja unicitatea.
static func cate_solutii(puzzle: Dictionary, plafon := 2) -> int:
	if puzzle.is_empty():
		return 0
	return cate_solutii_pentru(puzzle["indicii"], universul_lui(puzzle), plafon)


## Universul unui puzzle gata făcut: codurile pe care chiar trebuie să le
## deosebească, adică toate cele care se potrivesc cu roata blocată.
##
## Publică fiindcă verificatorul are nevoie de exact aceeași mulțime ca
## generatorul. Dacă și-ar construi-o singur, ar putea uita roata blocată — și
## atunci ar raporta „soluția nu e unică" pentru puzzle-uri perfect corecte,
## sau, mai rău, invers.
static func universul_lui(puzzle: Dictionary) -> Array:
	var spec := {"cifre": puzzle["cifre"], "minim": puzzle["minim"], "maxim": puzzle["maxim"]}
	return universul(toate_codurile(spec), puzzle["cod"], int(puzzle.get("blocata", -1)))


## Codurile pe care puzzle-ul chiar trebuie să le deosebească.
##
## Fără roată blocată, sunt toate. Cu o roată blocată, jucătorul pleacă văzând
## cifra ei — deci codurile care n-o au nu sunt „eliminate prin deducție", sunt
## eliminate din start. Toată socoteala (unicitate, alegere lacomă, curățare,
## indicii care dictează) se face în mulțimea asta, nu în cea mare.
##
## Dacă s-ar face în cea mare, generatorul ar adăuga indicii ca să excludă
## coduri pe care jucătorul le-a exclus deja uitându-se la cufăr: indicii
## adevărate, dar inutile — exact ce scoate pasul de curățare, doar că de data
## asta n-ar avea cum să le vadă ca inutile.
static func universul(toate: Array, cod: Array, blocata: int) -> Array:
	if blocata < 0:
		return toate
	var ramase := []
	for c in toate:
		if c[blocata] == cod[blocata]:
			ramase.append(c)
	return ramase


## Fixează indiciul ăsta, de unul singur, vreo cifră?
##
## E verificarea la propriu a regulii „fără indicii care dau direct o cifră". Nu
## se uită la TIPUL indiciului (niciun tip nu e de forma „A = 7"), ci la EFECTUL
## lui: dacă toate codurile din univers care respectă indiciul au aceeași cifră
## pe o poziție, atunci indiciul dictează cifra aia — indiferent cum e scris.
## „Suma tuturor cifrelor e exact 4", pe un lacăt de 4 roți cu minimul 1, e o
## propoziție despre sumă care spune, de fapt, „toate sunt 1".
##
## `ignorata` e roata BLOCATĂ, și trebuie ignorată, altfel verificarea ar
## reclama absolut orice indiciu: în universul restrâns, roata blocată are o
## singură valoare posibilă prin definiție. Nu e o excepție convenabilă — e
## chiar distincția dintre „ți se dictează o cifră" și „ți se ARATĂ o cifră,
## iar tu deduci restul".
## DE CE PARCURGE UNIVERSUL ÎN SALTURI, ȘI NU DE LA CAP LA COADĂ.
##
## Funcția răspunde „nu" imediat ce a văzut două valori diferite pe fiecare
## poziție — și asta e ieșirea care o face ieftină, fiindcă majoritatea
## indiciilor sunt cinstite și se dovedesc cinstite din câteva zeci de coduri.
##
## Numai că lista de coduri e construită ca un CONTOR (vezi `toate_codurile()`):
## prima roată se schimbă la fiecare pas, ultima o dată la 729 de pași. Citită
## în ordine, ieșirea devreme nu se putea declanșa niciodată înainte de al
## 730-lea cod — iar pentru un indiciu restrictiv, ca „A + B + C + D e exact
## 21", codurile care trec sunt rare, așa că se ajungea să se parcurgă tot
## universul. De aproape 30 de ori pe încercare. Asta singură făcea o generare
## de nivel 3 să dureze 18 secunde.
##
## Cu un pas mare, PRIM FAȚĂ DE mărimea listei, sărim prin listă atingând
## fiecare cod exact o dată (deci răspunsul rămâne la fel de sigur), dar
## întâlnim valori variate pe toate roțile din primele zeci de coduri. Ordinea
## nu poate schimba rezultatul: „indiciul dictează o cifră" e o proprietate a
## întregii mulțimi, nu a drumului prin ea.
static func da_o_cifra(indiciu: Dictionary, universul: Array, ignorata := -1) -> bool:
	var total := universul.size()
	var cifre: int = universul[0].size()
	# Pentru fiecare poziție, ce valori apar printre codurile care trec.
	var vazute := []
	for i in cifre:
		vazute.append({})
	# Câte poziții au deja cel puțin două valori diferite. Roata blocată n-are
	# cum să ajungă acolo, deci pornește numărătoarea de la 1 pentru ea.
	var libere := 1 if ignorata >= 0 else 0
	var pas := _pas_prin(total)
	var unde := 0
	for n in total:
		var cod: Array = universul[unde]
		unde = (unde + pas) % total
		if not evalueaza(indiciu, cod):
			continue
		for i in cifre:
			if i == ignorata:
				continue
			var set: Dictionary = vazute[i]
			if not set.has(cod[i]):
				set[cod[i]] = true
				if set.size() == 2:
					libere += 1
		if libere == cifre:
			return false   # toate pozițiile au scăpat: indiciul e curat
	return true


## Un pas care, adunat mereu la sine modulo `total`, atinge fiecare poziție din
## listă exact o dată.
##
## Condiția e ca pasul și mărimea listei să nu aibă niciun divizor comun în
## afară de 1 (să fie „prime între ele"). Dacă ar avea unul — să zicem 3 —
## saltul s-ar învârti la nesfârșit printr-o treime din listă și n-ar vedea
## restul niciodată. Pornim de la un număr mare și prim, și urcăm până dăm de
## unul care se potrivește cu lista asta.
static func _pas_prin(total: int) -> int:
	if total <= 2:
		return 1
	var pas := 1237
	while _cmmdc(pas, total) != 1:
		pas += 1
	return pas


## Cel mai mare divizor comun, prin algoritmul lui Euclid: împarți, păstrezi
## restul, repeți până restul e zero.
static func _cmmdc(a: int, b: int) -> int:
	while b != 0:
		var rest := a % b
		a = b
		b = rest
	return a


## Primul indiciu din listă care fixează singur o cifră, sau −1 dacă toate sunt
## curate. Aceeași regulă ca mai sus, aplicată unei liste.
static func indiciu_care_da_o_cifra(indicii: Array, universul: Array, ignorata := -1) -> int:
	for k in indicii.size():
		if da_o_cifra(indicii[k], universul, ignorata):
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
		SUMA:
			var s := 0
			for p in indiciu["pozitii"]:
				s += int(cod[int(p)])
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
		SUMA:
			# „A + C + D", oricâte roți ar fi. Forma asta a înlocuit vechiul
			# „Suma tuturor cifrelor e…" pentru suma completă: e cu câteva
			# litere mai lungă, dar toate sumele arată acum la fel, iar
			# jucătorul nu mai are de recunoscut două formulări pentru aceeași
			# idee.
			var nume := PackedStringArray()
			for p in indiciu["pozitii"]:
				nume.append(litera(int(p)))
			var suma := " + ".join(nume)
			match String(indiciu["semn"]):
				">":
					return "%s e mai mare decât %d." % [suma, int(indiciu["valoare"])]
				"<":
					return "%s e mai mică decât %d." % [suma, int(indiciu["valoare"])]
				_:
					return "%s e exact %d." % [suma, int(indiciu["valoare"])]
		PARITATE:
			return "%s e %s." % [
				litera(int(indiciu["a"])), "pară" if bool(indiciu["para"]) else "impară"]
		EXTREM:
			if bool(indiciu["maxim"]):
				return "Nicio cifră nu e mai mare decât %s." % litera(int(indiciu["a"]))
			return "Nicio cifră nu e mai mică decât %s." % litera(int(indiciu["a"]))
		FARA_REPETITIE:
			return "Nicio cifră nu se repetă."
	# Un tip fără propoziție e o scăpare de programator, nu o stare de joc: se
	# întâmplă doar dacă ai adăugat un tip și ai uitat un rând aici. Textul
	# întors e vizibil urât, ca să nu treacă neobservat prin testare.
	push_error("GeneratorCifru: indiciu fara text: %s" % [indiciu])
	return "(indiciu necunoscut)"


## ETICHETA unui indiciu pentru rapoarte: numele lui, plus ce-l deosebește de
## frații lui de același tip.
##
## Fără ea, raportul verificatorului ar spune doar „SUMA: 1200" — adevărat și
## complet nefolositor, fiindcă exact ăsta e tipul care s-a unificat. Nu vrei
## să știi dacă generatorul alege sume; vrei să știi dacă alege sume de TREI
## (indiciile subtile, cele bune pentru nivelul 3) sau sume exacte de două
## (indiciile brutale), și în ce proporție. „SUMA-3 <" și „SUMA-2 =" sunt două
## unelte diferite, cu același nume de tip.
##
## Trăiește aici, nu în verificator, ca să fie o singură definiție: orice unealtă
## viitoare care raportează indicii vede aceleași etichete.
static func eticheta(indiciu: Dictionary) -> String:
	var tip := String(indiciu.get("tip", "?"))
	match tip:
		SUMA:
			return "SUMA-%d %s" % [indiciu["pozitii"].size(), String(indiciu["semn"])]
		RELATIE:
			return "RELATIE %s" % String(indiciu["semn"])
		EXTREM:
			return "EXTREM %s" % ["max" if bool(indiciu["maxim"]) else "min"]
	return tip

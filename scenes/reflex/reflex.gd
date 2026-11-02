extends Puzzle
## Disciplina REFLEX — a opta, și singura la care răspunsul greșit e CHIAR cel
## care-ți vine primul.
##
## ─────────────────────────────────────────────────────────────
## DE CE NU E O DISCIPLINĂ DE VITEZĂ, DEȘI AȘA O CEREA PITCH-UL
##
## Rândul din pitch spunea „tap corect sub 3s", iar disciplina a stat blocată
## câteva zile exact pe asta, cu motivul scris în trei locuri (CLAUDE.md,
## `discipline.gd`, `progres.md`): **de pe 31 octombrie cronometrul e al
## INAMICULUI**, nu al jocului. Doar Lăncierul numără secundele; la ceilalți doi
## bara de timp nici nu se vede. O disciplină al cărei singur rost e viteza n-ar
## fi avut, deci, de ce să se agațe în două lupte din trei — ar fi fost opt
## întrebări ca oricare altele, cu o promisiune neîndeplinită pe card.
##
## Se putea plăti: un al treilea câmp opțional în contract, prin care disciplina
## își declară un ceas scurt al ei, cum Reținerea își declară expunerea. A fost
## cântărit și lăsat: `TIMP_PE_NIVEL` din `puzzle.gd` e o PROMISIUNE făcută
## jucătorului (comentariul de acolo o spune: „dacă fiecare disciplină ar avea
## alt ritm, ar trebui să reînveți presiunea de fiecare dată când schimbi
## Obeliscul"), iar în Practice, unde ceasul e stins cu totul, disciplina ar fi
## rămas fără rostul ei — adică exact blocajul de azi, doar mutat.
##
## ─────────────────────────────────────────────────────────────
## CE ESTE, ATUNCI: INHIBIȚIA
##
## Priceperea pe care o antrenează nu e „cât de repede apeși", e **cât de bine
## nu faci ce-ți vine să faci**. Măsurată în laborator cu un cronometru, fiindcă
## acolo toți răspund corect dacă au timp; măsurată aici cu GREȘELI, fiindcă un
## joc nu poate citi milisecunde dintr-un click de mouse.
##
## Deci capcana s-a mutat ÎN întrebare — exact mutarea pe care o făcuse
## Reținerea cu timpul ei. Cuvântul „DREAPTA" e scris la stânga; „4 4 4 4 4 4"
## are șase cifre, nu patru; săgeata din mijlocul unui rând de săgeți spre
## stânga arată în sus; sub un pătrat scrie „TRIUNGHI". În fiecare din cele
## douăsprezece tipare, **prima variantă tentantă e cea pe care generatorul o
## pune întâi în listă, și e greșită**.
##
## Asta e sora regulii de la Numere („variantele greșite sunt GREȘELI, nu
## numere") și a celei de la Reținere („greșelile sunt lucruri care AU FOST pe
## ecran"), dusă la capăt: aici greșeala nu e doar plauzibilă, e CEA PE CARE AI
## FI DAT-O. Un tipar din disciplina asta la care varianta greșită e un număr la
## întâmplare nu e un tipar slab, e un tipar care nu aparține disciplinei.
##
## ─────────────────────────────────────────────────────────────
## PATRU TIPURI, DOUĂSPREZECE TIPARE
##
##   CUVANTUL  — cuvântul se bate cu LOCUL lui. „SUS" scris jos, „DREAPTA"
##               scris la stânga. Se întreabă, pe rând, și locul, și cuvântul:
##               vezi mai jos de ce amândouă.
##   CIFRELE   — cifra se bate cu CÂTE sunt și cu CÂT e desenată. „7 7 7" are
##               trei cifre; dintre patru cifre, cea mai mare la valoare nu e
##               cea mai mare pe ecran.
##   SAGETILE  — rândul se bate cu MIJLOCUL lui. Șase săgeți spre stânga și una
##               în sus, la mijloc. Plus un tipar în care regula însăși e
##               întoarsă: se cere direcția OPUSĂ.
##   FORMELE   — cuvântul se bate cu FORMA de lângă el. Sub un romb scrie
##               „CERC". Se întreabă, pe rând, și forma, și cuvântul.
##
## ─────────────────────────────────────────────────────────────
## DE CE SE ÎNTREABĂ AMÂNDOUĂ DIRECȚIILE, DEȘI UNA PARE UȘOARĂ
##
## La CUVANTUL și la FORMELE, două tipare pun ACELAȘI fel de imagine și
## întreabă invers: o dată locul (ignoră cuvântul), o dată cuvântul (ignoră
## locul). Pare că al doilea e cadoul: cititul e automat, deci ce poate fi greu
## la „ce cuvânt e scris"?
##
## Ar fi fost, dacă ar fi existat singur. Împreună nu: **dacă disciplina ar
## întreba mereu locul, ai învăța în trei întrebări să nu mai citești deloc, iar
## interferența ar dispărea cu totul.** Exact ce măsoară proba e faptul că nu
## poți ști dinainte care dimensiune va conta — deci trebuie să le ții pe
## amândouă, și atunci fiecare o încurcă pe cealaltă. Al doilea tipar nu e mai
## ușor, e ce ține primul greu.
##
## Și nu e un cadou nici pe dinăuntru: locurile și cuvintele sunt amestecate
## complet (niciun cuvânt nu stă vreodată la locul pe care-l numește), deci
## „ce cuvânt e scris sus?" are ca impuls chiar „SUS" — care nu e niciodată
## răspunsul.
##
## ─────────────────────────────────────────────────────────────
## CE COSTĂ DISCIPLINA, SPUS PE FAȚĂ
##
## **Cu 12 secunde pe întrebare, un jucător răbdător poate învinge orice
## interferență.** Asta e adevărat, e cunoscut (în laborator Stroop-ul se vede
## în milisecunde, nu în greșeli, când ai timp) și nu se ascunde aici.
##
## Ce ține disciplina în picioare în locul vitezei sunt două lucruri, amândouă
## măsurabile:
##
##   • patru tipare din douăsprezece cer o NUMĂRĂTOARE (câte cifre, câte
##     săgeți, câte forme, plus comparația de valori) — iar o numărătoare printre
##     semne care se bat între ele costă secunde chiar fără grabă, și greșește
##     chiar făcută atent;
##   • `_sageti_opusul` întoarce REGULA, nu stimulul. O regulă întoarsă se
##     greșește și pe îndelete, fiindcă mâna apucă răspunsul citit înainte ca
##     mintea să-l întoarcă.
##
## Iar pârghia de reglat, dacă se dovedește prea ușoară, e CÂTE semne sunt pe
## ecran — o cifră în tabelele de mai jos — nu un ceas propriu. Cu Lăncierul în
## față, aceleași întrebări mușcă de la sine.
##
## ─────────────────────────────────────────────────────────────
## CE NU S-A ADUS, DEȘI PITCH-UL ÎL PROPUNEA
##
## **„Găsește intrusul".** Două motive, și al doilea e cel care decide:
## mecanica „intrus" e deja la trei discipline (cuvinte la Cuvinte, familii la
## Logică, numărul care strică regula la Tipare), iar pitch-ul chiar prevedea
## suprapunerea și o accepta — dar aici n-ar fi avut IMPULS GREȘIT. Căutarea
## unui semn diferit printre semne identice e atenție, nu inhibiție: nu există
## un răspuns care să-ți vină primul și să fie greșit, deci tiparul ar fi fost
## singurul din disciplină care nu respectă regula ei. O disciplină cu un tipar
## care nu e de-al ei își pierde definiția.
##
## ─────────────────────────────────────────────────────────────
## CÂRLIGUL DE DESENARE: FOLOSIT DE TOATE DOUĂSPREZECE
##
## Spațialul a adus cârligul `_plansa_pentru()` și îl folosea la 11 tipare din
## 12 (BUSOLA nu desenează nimic, dinadins, ca probă că e opțional). Reținerea
## l-a folosit la un tip din patru. Aici îl folosesc TOATE: o întrebare de
## inhibiție fără imagine n-ar avea cu ce să se bată — textul singur n-are nici
## loc, nici mărime, nici direcție.
##
## În schimb, al DOILEA cârlig (expunerea Reținerii) nu se folosește deloc:
## planșa stă pe ecran cât răspunzi. Cele două sunt independente, și asta se
## vede acum din amândouă părțile — Reținerea le folosește pe amândouă, Reflexul
## doar pe primul, Spațialul doar pe primul, celelalte cinci pe niciunul.

const VARIANTE := 4

# ─────────────────────────────────────────────────────────────
# CELE PATRU DIRECȚII, CU TREI NUME FIECARE
#
# Trei coloane, fiindcă aceeași direcție apare în joc în trei feluri, iar un
# singur nume le-ar fi amestecat:
#
#   „cuvant" — ce se DESENEAZĂ pe planșă, cu majuscule, ca orice semn scris;
#   „loc"    — cum se numește un LOC, pe buton: „Unde e scris? la stanga";
#   „sens"   — cum se numește o MIȘCARE: „Incotro arata? in sus".
#
# Deosebirea dintre ultimele două nu e înfrumusețare, e românește: un lucru e
# scris „sus", dar o săgeată arată „în sus". Dacă butoanele ar folosi același
# cuvânt pentru amândouă, unul din cele două tipuri ar suna strâmb — iar aici
# butonul CHIAR e răspunsul, nu o parafrază a lui.
# ─────────────────────────────────────────────────────────────
const DIRECTII := {
	"sus": {"cuvant": "SUS", "loc": "sus", "sens": "in sus"},
	"jos": {"cuvant": "JOS", "loc": "jos", "sens": "in jos"},
	"stanga": {"cuvant": "STANGA", "loc": "la stanga", "sens": "la stanga"},
	"dreapta": {"cuvant": "DREAPTA", "loc": "la dreapta", "sens": "la dreapta"},
}

# Direcția opusă. Un tabel, nu o socoteală: `_sageti_opusul` întoarce o
# direcție, iar o funcție care ar deduce opusul dintr-un unghi ar fi un loc în
# plus în care se poate greși semnul.
const OPUSE := {"sus": "jos", "jos": "sus", "stanga": "dreapta", "dreapta": "stanga"}

# UNDE pe planșă stă fiecare din cele patru locuri, în fracțiuni de casetă.
#
# Nu sunt 0,1 și 0,9: un cuvânt e desenat CENTRAT pe punctul lui (vezi
# `plansa.gd`), iar „DREAPTA" la mărimea 18 e lat de vreo 80 px. La x = 0,9
# jumătate din el ar ieși din casetă. 0,20 și 0,80 pe o casetă de 340 px lasă
# 68 px de fiecare parte — măsurat pe cel mai lung cuvânt din tabel.
const LOCURI := {
	"sus": Vector2(0.50, 0.15),
	"jos": Vector2(0.50, 0.85),
	"stanga": Vector2(0.20, 0.50),
	"dreapta": Vector2(0.80, 0.50),
}

# ─────────────────────────────────────────────────────────────
# CELE PATRU FORME, CU TREI NUME FIECARE
#
# Aceeași socoteală ca la direcții: „cerc" e ce desenează planșa, „CERC" e ce
# scrie pe ea, „cercuri" e ce se numără. Pluralul e scris de mână și nu dedus
# cu o regulă („+uri"), fiindcă regula ar fi greșit la „triunghiuri" și ar fi
# greșit tăcut — exact ca formele hotărâte ale lucrurilor de la Reținere.
# ─────────────────────────────────────────────────────────────
const FORME := {
	"cerc": {"cuvant": "CERC", "unul": "cerc", "multe": "cercuri"},
	"patrat": {"cuvant": "PATRAT", "unul": "patrat", "multe": "patrate"},
	"triunghi": {"cuvant": "TRIUNGHI", "unul": "triunghi", "multe": "triunghiuri"},
	"romb": {"cuvant": "ROMB", "unul": "romb", "multe": "romburi"},
}

# ─────────────────────────────────────────────────────────────
# CÂT SE DESENEAZĂ, PE NIVEL
#
# Toate tabelele sunt citite cu `nivel - 1`, deci au exact trei intrări — chiar
# și acolo unde tiparul nu apare la toate trei niveluri (intrarea nefolosită
# rămâne, ca tabelul să se citească la fel oriunde).
#
# TOATE sunt NUMERE DE SEMNE, și ăsta e tot felul în care disciplina are
# niveluri: nu există „întrebări grele" și „întrebări ușoare" la inhibiție,
# există mai mult sau mai puțin de ținut deoparte. Vezi antetul: dacă
# disciplina se dovedește prea ușoară, ce se reglează sunt cifrele de mai jos.
# ─────────────────────────────────────────────────────────────
const CUVINTE_PE_NIVEL: Array[int] = [1, 2, 3]       # câte cuvinte de direcție pe planșă
const CUVINTE_LANGA_SAGEATA: Array[int] = [1, 1, 2]  # câte cuvinte stau lângă săgeată
const CIFRE_PE_NIVEL := [[2, 4], [3, 6], [4, 8]]  # de câte ori se scrie cifra
const SAGETI_IN_RAND: Array[int] = [3, 5, 7]         # rândul de săgeți (mereu impar)
const SAGETI_DE_NUMARAT: Array[int] = [4, 6, 8]      # rândul de numărat (poate fi par)
const CUVINTE_LANGA_FORMA: Array[int] = [1, 2, 3]    # câte cuvinte în jurul unei forme
const FORME_LANGA_CUVANT: Array[int] = [1, 2, 2]     # câte forme în jurul unui cuvânt
const FORME_DE_NUMARAT: Array[int] = [4, 4, 5]       # câte perechi formă+cuvânt se numără

# Mărimile cifrelor la `_cifre_mai_mare`. Patru trepte distincte, de la „mică
# dar citibilă" la „cât încape". Distincte și nu apropiate: dacă două cifre ar
# părea la fel de mari, impulsul n-ar mai avea o singură țintă, deci întrebarea
# ar fi doar o comparație de valori — adică un tipar de Numere.
const MARIMI_CIFRE: Array[int] = [17, 23, 31, 41]

# De câte ori se încearcă o așezare de mărimi care nu se trădează. Vezi
# `_cifre_mai_mare`: cifra cea mai mare la valoare nu are voie să fie nici cea
# mai mare, nici cea mai mică pe ecran. Jumătate din așezări cad, deci 20 de
# încercări sunt de ajuns de multe ori ca tiparul să nu pice niciodată în
# practică — iar dacă totuși cade, întoarce `{}` și rândul trece la alt tipar.
const INCERCARI_MARIMI := 20

# CASETA PLANȘEI, aceeași pentru toate cele douăsprezece tipare.
#
# O planșă care și-ar alege lățimea după conținut ar face semnele să sară de la
# o întrebare la alta — iar la o disciplină în care tot rostul e să te uiți la
# UN loc, ecranul care se mișcă e el însuși o interferență, una care nu măsoară
# nimic. Amândouă cifrele sunt sub plafoanele desenatorului (vezi `LAT_MAXIM` și
# `INALT_MAXIM` din `plansa.gd`), care sunt la rândul lor măsurători ale
# panoului, nu preferințe.
const LAT_PLANSA := 340.0
const INALT_PLANSA := 92.0

# Locurile celor până la trei cuvinte din jurul unei forme, în ORDINEA în care
# se adaugă: sub, deasupra, în stânga. Ordinea nu e indiferentă — sub e locul în
# care un cuvânt se citește împreună cu desenul (eticheta unei figuri), deci cel
# care interferează cel mai tare, și el e primul.
const LOCURI_CUVINTE: Array[Vector2] = [
	Vector2(0.50, 0.90), Vector2(0.50, 0.10), Vector2(0.17, 0.50),
]

# ─────────────────────────────────────────────────────────────
# GENERATOARELE
#
# Tabelul obișnuit: un tipar nou e o funcție și un rând. Coloanele sunt cele de
# la Tipare, Spațial și Reținere.
#
#   „tip"      — familia. Se alege PRIMA, ca un tip cu trei tipare să nu apară
#                mai des decât altul cu trei: alegerea în două trepte ține
#                echilibrul pe TIPURI, nu pe tipare.
#   „niveluri" — la ce dificultăți poate apărea tiparul.
#   „categorie"— ce scrie în antet. Ce FEL de sarcină e, nu care e răspunsul.
#   „metoda"   — numele funcției, ca text. `call(nume, nivel)` o cheamă.
#
# N-are coloana „necesita": a cincea disciplină care nu citește nimic de pe
# disc, după Numere, Tipare, Spațial și Reținere. Cele patru direcții și cele
# patru forme de mai sus sunt un vocabular de desen, nu conținut.
#
# ECHILIBRUL: fiecare TIP există la toate cele trei niveluri. `verifica_reflex`
# bate regula, nu doar o scrie.
# ─────────────────────────────────────────────────────────────
const GENERATOARE := [
	# CUVANTUL — cuvântul se bate cu locul. Două tipare care pun aceeași
	# imagine și întreabă invers; vezi antetul pentru de ce amândouă.
	{"tip": "CUVANTUL", "niveluri": [1, 2, 3], "categorie": "UNDE E SCRIS", "metoda": "_cuvant_unde"},
	{"tip": "CUVANTUL", "niveluri": [1, 2, 3], "categorie": "CE E SCRIS ACOLO", "metoda": "_cuvant_care"},
	{"tip": "CUVANTUL", "niveluri": [2, 3], "categorie": "SAGEATA SAU CUVANTUL", "metoda": "_cuvant_incotro"},

	# CIFRELE — cifra se bate cu numărul lor și cu mărimea. „Ce cifră e scrisă"
	# nu urcă la III: cu opt cifre identice pe ecran, întrebarea devine mai
	# UȘOARĂ, nu mai grea (cifra se vede de opt ori), deci un nivel III ar fi
	# fost un nivel III mincinos.
	{"tip": "CIFRELE", "niveluri": [1, 2, 3], "categorie": "CATE CIFRE SUNT", "metoda": "_cifre_cate"},
	{"tip": "CIFRELE", "niveluri": [1, 2], "categorie": "CE CIFRA E SCRISA", "metoda": "_cifre_care"},
	{"tip": "CIFRELE", "niveluri": [1, 2, 3], "categorie": "VALOAREA CEA MAI MARE", "metoda": "_cifre_mai_mare"},

	# SAGETILE — rândul se bate cu mijlocul lui. Regula întoarsă nu coboară la
	# I: la primul nivel se învață ce cere disciplina, iar o regulă întoarsă
	# înainte de a fi înțeleasă regula dreaptă e o întrebare-capcană, nu un
	# antrenament.
	{"tip": "SAGETILE", "niveluri": [1, 2, 3], "categorie": "SAGEATA DIN MIJLOC", "metoda": "_sageti_mijlocul"},
	{"tip": "SAGETILE", "niveluri": [1, 2, 3], "categorie": "CATE SAGETI ARATA", "metoda": "_sageti_cate"},
	{"tip": "SAGETILE", "niveluri": [2, 3], "categorie": "DIRECTIA OPUSA", "metoda": "_sageti_opusul"},

	# FORMELE — cuvântul se bate cu forma. Aceeași pereche de tipare inverse ca
	# la CUVANTUL, și tot din același motiv.
	{"tip": "FORMELE", "niveluri": [1, 2, 3], "categorie": "CE FORMA E DESENATA", "metoda": "_forme_care"},
	{"tip": "FORMELE", "niveluri": [1, 2], "categorie": "CE CUVANT E SCRIS", "metoda": "_forme_scrie"},
	{"tip": "FORMELE", "niveluri": [2, 3], "categorie": "CATE FORME SUNT", "metoda": "_forme_cate"},
]


# ─────────────────────────────────────────────────────────────
# CONTRACTUL CU `Puzzle`
# ─────────────────────────────────────────────────────────────

## Datele. N-are ce să citească — a cincea disciplină fără fișier, după Numere,
## Tipare, Spațial și Reținere. Rămâne scrisă, goală, fiindcă e jumătate din
## contract.
func _pregateste_datele() -> void:
	pass


## Produce o întrebare pentru nivelul cerut. Alegerea e în două trepte (întâi
## tipul, apoi tiparul din el), iar lista întoarsă de `_retete_amestecate()` e și
## ordinea de rezervă: un tipar are voie să dea greș și să lase rândul altuia.
func _compune_intrebare(nivel: int) -> Dictionary:
	for reteta in _retete_amestecate(nivel):
		var intrebare: Dictionary = call(reteta["metoda"], nivel)
		if not intrebare.is_empty():
			intrebare["categorie"] = reteta["categorie"]
			return intrebare
	return {}


## De unde vin întrebările, pentru ecranul de eroare. Nu e un fișier.
func _descriere_sursa() -> String:
	return "generate din `scenes/reflex/reflex.gd` (fara fisier de date)"


## PLANȘA. Aici o cer TOATE tiparele, nu unul din patru ca la Reținere — vezi
## antetul: o întrebare de inhibiție fără imagine n-are cu ce să se bată.
##
## Desenatorul e al Reflexului, nu al Spațialului, și `plansa.gd` de lângă
## explică de ce: acolo un loc e un număr de celulă, aici locul e conținutul.
func _plansa_pentru(q: Dictionary) -> Control:
	var date: Dictionary = q.get("plansa", {})
	if date.is_empty():
		return null
	return PlansaReflex.din_date(date)


## CE ANUME face două întrebări „aceeași întrebare".
##
## Enunțul și variantele nu ajung — și aici mai puțin decât oriunde. La
## `_cuvant_unde`, enunțul e „Unde e scris cuvantul DREAPTA?" (patru enunțuri
## posibile în tot tiparul), iar variantele sunt MEREU aceleași patru locuri.
## Fără planșă în identitate, tot tiparul ar fi arătat ca patru întrebări, iar
## `_compune_nerepetata` ar fi reciclat sacul la fiecare a cincea apăsare.
##
## Deci identitatea cuprinde PLANȘA — adică exact ce se vede pe ecran. Aceeași
## concluzie ca la Reținere, pe alt drum: acolo imaginea era întrebarea fiindcă
## dispărea, aici fiindcă enunțul nu spune aproape nimic fără ea.
func _identitate_intrebare(q: Dictionary) -> String:
	var variante: Array = (q.get("variante", []) as Array).duplicate()
	variante.sort()
	return "%s|%s|%s" % [
		q.get("text", ""), "|".join(variante), _amprenta_plansei(q.get("plansa", {})),
	]


## Planșa, strânsă într-un șir. Nu e pentru ochi, e pentru comparație — deci
## cuprinde tot ce deosebește două planșe: locul, felul și conținutul fiecărui
## semn. Mărimea intră și ea, fiindcă la `_cifre_mai_mare` ea E jumătate din
## întrebare.
func _amprenta_plansei(date: Dictionary) -> String:
	if date.is_empty():
		return ""
	var bucati: Array[String] = []
	for semn in date.get("semne", []):
		bucati.append("%.2f,%.2f,%s,%s,%s,%d" % [
			semn.get("x", 0.0), semn.get("y", 0.0), semn.get("fel", ""),
			semn.get("text", ""), semn.get("incotro", "") + semn.get("forma", ""),
			int(semn.get("marime", 0)),
		])
	return ";".join(bucati)


## Tiparele potrivite nivelului, în ordinea în care merită încercate. Copie după
## `retinere.gd`: filtru pe nivel plus ordine de rezervă amestecată, grupată pe
## tip ca familiile mari să nu înghită pe cele mici.
func _retete_amestecate(nivel: int) -> Array:
	var disponibile: Array = GENERATOARE.filter(func(g): return nivel in g["niveluri"])
	# Plasă de siguranță: un nivel rămas fără tipare ar fi un ecran de eroare în
	# mijlocul unui lanț. Nu se poate întâmpla azi (`verifica_reflex` bate exact
	# asta), dar un tabel editat mâine nu trebuie să poată.
	if disponibile.is_empty():
		disponibile = GENERATOARE.duplicate()

	var pe_tip := {}
	for generator in disponibile:
		var tip: String = generator["tip"]
		if not pe_tip.has(tip):
			pe_tip[tip] = []
		pe_tip[tip].append(generator)

	var tipuri: Array = pe_tip.keys()
	tipuri.shuffle()

	var ordine: Array = []
	for tip in tipuri:
		var tipare: Array = pe_tip[tip].duplicate()
		tipare.shuffle()
		ordine.append_array(tipare)
	return ordine


# ─────────────────────────────────────────────────────────────
# UNELTELE COMUNE
# ─────────────────────────────────────────────────────────────

## Întrebarea gata făcută. Aceeași formă ca la Numere, Spațial și Reținere:
## răspunsul bun plus o listă de greșeli ÎN ORDINEA ÎN CARE SUNT TENTANTE.
##
## Ordinea candidaților e, la disciplina asta, jumătate din conținut. La toate
## celelalte ea hotărăște doar care greșeli ajung pe butoane când sunt mai multe
## candidate decât locuri; aici primul candidat e CHIAR impulsul — răspunsul pe
## care l-ar da o mână mai rapidă decât mintea. Un tipar care pune impulsul al
## treilea în listă încă funcționează, dar nu mai măsoară ce scrie în el.
func _intrebare(
	text: String,
	corect: String,
	candidati: Array,
	nota: String,
	plansa: Dictionary
) -> Dictionary:
	var gresite: Array[String] = []
	for candidat in candidati:
		if gresite.size() == VARIANTE - 1:
			break
		var c := String(candidat)
		if c == "" or c == corect or c in gresite:
			continue
		gresite.append(c)
	if gresite.size() < VARIANTE - 1:
		return {}

	var variante: Array[String] = [corect]
	variante.append_array(gresite)
	variante.shuffle()

	return {
		"text": text,
		"variante": variante,
		"corect": variante.find(corect),
		"explicatie": nota,
		"plansa": plansa,
	}


## Caseta planșei, cu semnele date. Vezi `LAT_PLANSA` pentru de ce e aceeași la
## toate cele douăsprezece tipare.
func _plansa(semne: Array) -> Dictionary:
	return {"lat": LAT_PLANSA, "inalt": INALT_PLANSA, "semne": semne}


## Un semn scris.
func _semn_text(loc: Vector2, text: String, marime: int) -> Dictionary:
	return {"x": loc.x, "y": loc.y, "fel": "text", "text": text, "marime": marime}


## O săgeată.
func _semn_sageata(loc: Vector2, incotro: String, marime: int) -> Dictionary:
	return {"x": loc.x, "y": loc.y, "fel": "sageata", "incotro": incotro, "marime": marime}


## Un contur de formă.
func _semn_forma(loc: Vector2, forma: String, marime: int) -> Dictionary:
	return {"x": loc.x, "y": loc.y, "fel": "forma", "forma": forma, "marime": marime}


## Locurile de pe un RÂND, așezate la distanțe egale. `(i + 0,5) / cate` și nu
## `i / (cate - 1)`: a doua formulă lipește semnele de margini, iar un semn pe
## marginea casetei pare tăiat. Așa, fiecare semn stă în mijlocul feliei lui.
func _rand(cate: int, y: float) -> Array[Vector2]:
	var locuri: Array[Vector2] = []
	for i in range(cate):
		locuri.append(Vector2((float(i) + 0.5) / float(cate), y))
	return locuri


## Cele patru direcții, amestecate.
func _directii_amestecate() -> Array[String]:
	var lista: Array[String] = []
	for cheie in DIRECTII:
		lista.append(String(cheie))
	lista.shuffle()
	return lista


## Cele patru forme, amestecate.
func _forme_amestecate() -> Array[String]:
	var lista: Array[String] = []
	for cheie in FORME:
		lista.append(String(cheie))
	lista.shuffle()
	return lista


## CUVINTE AȘEZATE GREȘIT ÎNADINS: `cate` locuri, fiecare cu un cuvânt de
## direcție care NU numește locul lui.
##
## Întoarce o listă de `{"loc": "sus", "directie": "dreapta"}` — adică „la locul
## de SUS e desenat cuvântul care numește DREAPTA".
##
## Amândouă câmpurile sunt CHEI de direcție, nu cuvinte desenate, și asta e o
## corectură plătită: prima scriere punea în al doilea câmp cheia și o desena ca
## atare, deci pe planșă apărea „dreapta" în loc de „DREAPTA", iar
## `_cheia_cuvantului` n-o mai găsea — `_cuvant_unde` eșua la fiecare tragere,
## tăcut, fiindcă un generator are voie să dea greș. Numele câmpului e acum
## `directie`, nu `cuvant`: un câmp care se cheamă „cuvant" și nu ține un cuvânt
## e o invitație la aceeași greșeală.
##
## Amestecarea completă (niciun cuvânt la locul lui) nu e o rafinare, e
## condiția ca tiparele să aibă un impuls: dacă „SUS" ar putea sta sus, atunci
## la întrebarea „unde e scris SUS?" răspunsul ar fi chiar impulsul, iar
## întrebarea ar răsplăti exact ce disciplina cere să ții deoparte.
##
## Alegerea e lacomă și nu poate eșua cu `cate` ≤ 3: la fiecare pas rămân cel
## puțin două cuvinte neluate din patru, iar cel mult unul din ele poate fi
## chiar numele locului.
func _cuvinte_asezate(cate: int) -> Array:
	var locuri := _directii_amestecate()
	locuri = locuri.slice(0, cate)
	var libere := _directii_amestecate()

	var asezate: Array = []
	for loc in locuri:
		for i in range(libere.size()):
			if libere[i] != loc:
				asezate.append({"loc": loc, "directie": libere[i]})
				libere.remove_at(i)
				break
	# Nu se poate întâmpla (vezi mai sus), dar un tabel schimbat mâine n-are
	# voie să producă o planșă cu mai puține cuvinte decât cere enunțul.
	if asezate.size() < cate:
		return []
	return asezate


## Numele unui LOC, pentru butoane și note: „sus", „la stanga".
func _loc(directie: String) -> String:
	return String(DIRECTII[directie]["loc"])


## Numele unui SENS, pentru butoane și note: „in sus", „la dreapta".
func _sens(directie: String) -> String:
	return String(DIRECTII[directie]["sens"])


## Cuvântul desenat al unei direcții: „SUS", „DREAPTA".
func _cuvant(directie: String) -> String:
	return String(DIRECTII[directie]["cuvant"])


## Numele celor patru locuri, în altă ordine decât cea dată. Folosit ca rezervă
## de greșeli: după impuls, orice loc rămas e o variantă bună de umplutură.
func _locurile_afara(afara: Array) -> Array[String]:
	var lista: Array[String] = []
	for directie in _directii_amestecate():
		if not (directie in afara):
			lista.append(_loc(directie))
	return lista


## Numerele din jurul unuia, ca greșeli de umplutură: n+1, n-1, n+2, n-2, n+3.
##
## Niciodată sub 1 — „zero cifre" pe un ecran plin de cifre nu e o greșeală
## tentantă, e o variantă pe care o elimină și cine nu s-a uitat.
##
## CINCI candidați, nu trei, și asta e o măsurătoare, nu o abundență: la n = 1
## trei din ei cad (0, -1, -2), deci ar fi rămas doi, iar `_cifre_care` cu cifra
## 1 ar fi întors `{}` de fiecare dată când impulsul se nimerea să fie vecinul
## care mai rămăsese. Un tipar care eșuează pe o cifră anume nu risipește doar
## cicluri, STRÂMBĂ echilibrul — vezi punctul din CLAUDE.md despre punctul care
## se alege, nu se trage la sorți.
func _numere_vecine(n: int) -> Array[String]:
	var lista: Array[String] = []
	for candidat in [n + 1, n - 1, n + 2, n - 2, n + 3]:
		if candidat >= 1:
			lista.append(str(candidat))
	return lista


# ─────────────────────────────────────────────────────────────
# TIPUL 1 — CUVANTUL
#
# Cuvântul se bate cu locul lui. Trei tipare: locul, cuvântul, și săgeata.
# ─────────────────────────────────────────────────────────────

## „Unde e scris cuvantul DREAPTA?" — scris la stânga.
##
## Impulsul e locul pe care cuvântul îl NUMEȘTE, adică tocmai răspunsul pe care
## l-ai da fără să te uiți. El e primul candidat; după el vin locurile
## CELORLALTE cuvinte de pe planșă (la nivelurile mari), fiindcă o greșeală care
## e un loc ocupat cere să fi căutat, iar una care e un loc gol nu.
func _cuvant_unde(nivel: int) -> Dictionary:
	var asezate := _cuvinte_asezate(CUVINTE_PE_NIVEL[nivel - 1])
	if asezate.is_empty():
		return {}

	var ales: Dictionary = asezate[randi() % asezate.size()]
	# `numita` e direcția pe care o NUMEȘTE cuvântul, `locul` e unde stă el.
	# Niciodată aceeași — vezi `_cuvinte_asezate`.
	var numita := String(ales["directie"])
	var locul := String(ales["loc"])
	var cuvantul := _cuvant(numita)

	# Impulsul: locul pe care-l numește cuvântul citit.
	var candidati: Array[String] = [_loc(numita)]
	for altul in asezate:
		if String(altul["loc"]) != locul:
			candidati.append(_loc(String(altul["loc"])))
	candidati.append_array(_locurile_afara([locul]))

	return _intrebare(
		"Unde e scris cuvantul %s?" % cuvantul,
		_loc(locul),
		candidati,
		"Cuvantul %s era scris %s, nu %s." % [cuvantul, _loc(locul), _loc(numita)],
		_plansa(_semne_cuvinte(asezate))
	)


## „Ce cuvant e scris sus?" — acolo scrie „JOS".
##
## Oglinda tiparului de mai sus, pe aceeași imagine. Impulsul e cuvântul care
## NUMEȘTE locul din întrebare — și el nu e niciodată răspunsul, fiindcă nicio
## așezare nu pune un cuvânt la locul lui.
func _cuvant_care(nivel: int) -> Dictionary:
	var asezate := _cuvinte_asezate(CUVINTE_PE_NIVEL[nivel - 1])
	if asezate.is_empty():
		return {}

	var ales: Dictionary = asezate[randi() % asezate.size()]
	var locul := String(ales["loc"])
	var cuvantul := _cuvant(String(ales["directie"]))

	# Impulsul: cuvântul care numește locul din întrebare.
	var candidati: Array[String] = [_cuvant(locul)]
	for altul in asezate:
		if String(altul["directie"]) != String(ales["directie"]):
			candidati.append(_cuvant(String(altul["directie"])))
	for directie in _directii_amestecate():
		candidati.append(_cuvant(directie))

	return _intrebare(
		"Ce cuvant e scris %s?" % _loc(locul),
		cuvantul,
		candidati,
		"Acolo scria %s, nu %s: niciun cuvant nu sta la locul pe care-l numeste." % [
			cuvantul, _cuvant(locul)
		],
		_plansa(_semne_cuvinte(asezate))
	)


## „Incotro arata sageata?" — iar lângă ea scrie altceva.
##
## Al treilea tipar al tipului, și singurul la care impulsul nu e o așezare, ci
## un CUVÂNT citit peste un desen. Săgeata stă la mijloc, cuvintele în lături:
## la nivelul III sunt două, deci două citiri de pus deoparte, nu una.
func _cuvant_incotro(nivel: int) -> Dictionary:
	var directii := _directii_amestecate()
	var incotro := directii[0]

	# Cuvintele de lângă: oricare, numai nu cel care spune adevărul. Un cuvânt
	# care ar numi direcția săgeții ar face întrebarea mai ușoară decât fără
	# niciun cuvânt — ar fi un indiciu, nu o interferență.
	var cuvinte: Array[String] = []
	for directie in directii:
		if directie != incotro:
			cuvinte.append(directie)
	cuvinte = cuvinte.slice(0, CUVINTE_LANGA_SAGEATA[nivel - 1])

	var semne: Array = [_semn_sageata(Vector2(0.5, 0.5), incotro, 34)]
	var locuri: Array[Vector2] = [LOCURI["stanga"], LOCURI["dreapta"]]
	for i in range(cuvinte.size()):
		semne.append(_semn_text(locuri[i], _cuvant(cuvinte[i]), 18))

	# Impulsul: primul cuvânt citit.
	var candidati: Array[String] = []
	for directie in cuvinte:
		candidati.append(_sens(directie))
	for directie in _directii_amestecate():
		candidati.append(_sens(directie))

	var scrise: Array[String] = []
	for directie in cuvinte:
		scrise.append(_cuvant(directie))

	return _intrebare(
		"Incotro arata sageata?",
		_sens(incotro),
		candidati,
		"Sageata arata %s. Scria %s, dar cuvantul nu e sageata." % [
			_sens(incotro), ", ".join(scrise)
		],
		_plansa(semne)
	)


## Semnele unei așezări de cuvinte. Cuvântul DESENAT se ia din tabel, aici, în
## singurul loc în care se desenează — nu se cară prin așezare ca text.
func _semne_cuvinte(asezate: Array) -> Array:
	var semne: Array = []
	for intrare in asezate:
		semne.append(_semn_text(
			LOCURI[String(intrare["loc"])], _cuvant(String(intrare["directie"])), 18
		))
	return semne


# ─────────────────────────────────────────────────────────────
# TIPUL 2 — CIFRELE
#
# Cifra se bate cu câte sunt și cu cât e desenată. Stroop-ul numeric, și
# singurul tip al disciplinei la care răspunsul e un NUMĂR — ceea ce îl face și
# singurul la care greșelile pot fi vecine („cinci în loc de șase"), nu doar
# impulsuri.
# ─────────────────────────────────────────────────────────────

## „4 4 4 4 4 4" → „Cate cifre sunt?"
##
## Impulsul e CIFRA, citită în loc de numărată. De-aia ea e aleasă din același
## interval ca numărul lor: un 9 lângă trei cifre n-ar fi un impuls, ar fi o
## variantă pe care o elimină privirea.
func _cifre_cate(nivel: int) -> Dictionary:
	var interval: Array = CIFRE_PE_NIVEL[nivel - 1]
	var cate := randi_range(int(interval[0]), int(interval[1]))
	var cifra := _cifra_diferita_de(cate, int(interval[0]), int(interval[1]))
	if cifra < 0:
		return {}

	var candidati: Array[String] = [str(cifra)]
	candidati.append_array(_numere_vecine(cate))

	return _intrebare(
		"Cate cifre sunt?",
		str(cate),
		candidati,
		"Cifra %d era scrisa de %d ori, deci sunt %d cifre." % [cifra, cate, cate],
		_plansa(_semne_cifre(cate, cifra))
	)


## Aceeași imagine → „Ce cifra e scrisa?"
##
## Oglinda tiparului de mai sus, și impulsul e numărul lor. Nu urcă la nivelul
## III: vezi rândul din `GENERATOARE` — cu opt cifre identice, întrebarea
## devine mai ușoară, nu mai grea.
func _cifre_care(nivel: int) -> Dictionary:
	var interval: Array = CIFRE_PE_NIVEL[nivel - 1]
	var cate := randi_range(int(interval[0]), int(interval[1]))
	var cifra := _cifra_diferita_de(cate, int(interval[0]), int(interval[1]))
	if cifra < 0:
		return {}

	var candidati: Array[String] = [str(cate)]
	candidati.append_array(_numere_vecine(cifra))

	return _intrebare(
		"Ce cifra e scrisa?",
		str(cifra),
		candidati,
		"Scria cifra %d, de %d ori. Intrebarea era CE cifra, nu cate." % [cifra, cate],
		_plansa(_semne_cifre(cate, cifra))
	)


## O cifră din intervalul dat, dar nu numărul `interzis`.
##
## Intervalul se lărgește la 1-9 dacă e prea strâmt, fiindcă la nivelul I
## intervalul e [2,4]: fără lărgire ar fi rămas două cifre posibile, iar
## impulsul s-ar fi repetat la fiecare a doua întrebare.
func _cifra_diferita_de(interzis: int, jos: int, sus: int) -> int:
	var posibile: Array[int] = []
	for c in range(maxi(1, jos - 1), mini(9, sus + 2) + 1):
		if c != interzis:
			posibile.append(c)
	if posibile.is_empty():
		return -1
	return posibile[randi() % posibile.size()]


## Rândul de cifre identice. Toate la aceeași mărime: dacă una ar fi mai mare,
## ochiul ar grupa restul în jurul ei și ar număra altfel.
func _semne_cifre(cate: int, cifra: int) -> Array:
	var semne: Array = []
	for loc in _rand(cate, 0.5):
		semne.append(_semn_text(loc, str(cifra), 26))
	return semne


## Patru cifre desenate la patru mărimi → „Care are valoarea cea mai mare?"
##
## CE FACE TIPARUL CINSTIT: cifra cea mai mare la valoare nu are voie să fie
## nici cea mai MARE, nici cea mai MICĂ pe ecran.
##
## Prima scriere o desena mereu pe cea mai mică — conflict maxim, și o greșeală:
## după trei întrebări ai fi învățat „apasă pe cea mai mică" și ai fi răspuns
## corect fără să te uiți la valori. Un impuls pe care-l poți inversa odată
## pentru totdeauna nu e un impuls, e o regulă ascunsă. Cu mărimea răspunsului
## la mijloc, nici „cea mai mare", nici „cea mai mică" nu merg, iar singura cale
## rămasă e să compari CIFRELE.
##
## Impulsul rămâne cifra desenată cel mai mare, și ea e primul candidat.
func _cifre_mai_mare(nivel: int) -> Dictionary:
	var cifre := _patru_cifre(nivel)
	if cifre.is_empty():
		return {}

	var cea_mare: int = cifre.max()
	var unde_e_mare := cifre.find(cea_mare)

	# Mărimile, amestecate până când răspunsul nu stă nici pe cea mai mare,
	# nici pe cea mai mică.
	var marimi: Array = MARIMI_CIFRE.duplicate()
	var bune := false
	for _incercare in range(INCERCARI_MARIMI):
		marimi.shuffle()
		var a_lui: int = marimi[unde_e_mare]
		if a_lui != marimi.max() and a_lui != marimi.min():
			bune = true
			break
	if not bune:
		return {}

	var semne: Array = []
	var locuri := _rand(cifre.size(), 0.5)
	for i in range(cifre.size()):
		semne.append(_semn_text(locuri[i], str(cifre[i]), int(marimi[i])))

	# Impulsul: cifra desenată cel mai mare. După ea, celelalte în ordinea
	# descrescătoare a mărimii desenate — adică în ordinea în care ochiul le-ar
	# fi luat în seamă.
	var dupa_marime: Array[int] = []
	for i in range(cifre.size()):
		dupa_marime.append(i)
	dupa_marime.sort_custom(func(a, b): return int(marimi[a]) > int(marimi[b]))
	var candidati: Array[String] = []
	for i in dupa_marime:
		candidati.append(str(cifre[i]))

	var scrise: Array[String] = []
	for cifra in cifre:
		scrise.append(str(cifra))

	return _intrebare(
		"Care cifra are VALOAREA cea mai mare?",
		str(cea_mare),
		candidati,
		"Cifrele erau %s, deci %d e cea mai mare. Marimea desenului nu conteaza." % [
			" ".join(scrise), cea_mare
		],
		_plansa(semne)
	)


## Patru cifre distincte, mai apropiate la nivel mare.
##
## Nivelul I le vrea DEPĂRTATE (diferențe de cel puțin 2), nivelul III
## CONSECUTIVE. Asta e tot gradientul tiparului, și e singurul din disciplină
## care nu e un număr de semne: aici greul nu e cât ai de ignorat, e cât de
## aproape sunt valorile pe care le compari după ce ai ignorat mărimea.
func _patru_cifre(nivel: int) -> Array[int]:
	var cifre: Array[int] = []
	if nivel >= 3:
		# Consecutive: 3 4 5 6, amestecate pe ecran.
		var start := randi_range(1, 6)
		for i in range(4):
			cifre.append(start + i)
	elif nivel == 2:
		var toate: Array[int] = []
		for c in range(1, 10):
			toate.append(c)
		toate.shuffle()
		cifre = toate.slice(0, 4)
	else:
		# Depărtate: pasul e 2, deci 1 3 5 7 sau 3 5 7 9 — diferențe de cel
		# puțin 2 între oricare două, adică o comparație pe care o faci fără
		# să te concentrezi. Tot greul nivelului I rămâne mărimea desenului.
		var start := randi_range(1, 3)
		for i in range(4):
			cifre.append(start + i * 2)
	cifre.shuffle()
	return cifre


# ─────────────────────────────────────────────────────────────
# TIPUL 3 — SAGETILE
#
# Rândul se bate cu mijlocul lui. Proba clasică de flanker, și singurul tip la
# care interferența vine din CÂTE semne spun altceva, nu din ce spun ele.
# ─────────────────────────────────────────────────────────────

## „Incotro arata sageata din MIJLOC?" — restul rândului arată altundeva.
##
## Impulsul e direcția celorlalte, fiindcă ele sunt majoritatea și se văd
## primele. Rândul are mereu un număr IMPAR de săgeți: fără un mijloc adevărat,
## întrebarea ar avea nevoie de o convenție în plus („a câta e mijlocul?"), iar
## o convenție care se poate ocoli se ocolește.
func _sageti_mijlocul(nivel: int) -> Dictionary:
	var cate := SAGETI_IN_RAND[nivel - 1]
	var directii := _directii_amestecate()
	var la_mijloc := directii[0]
	var restul := directii[1]

	var semne := _semne_sageti(cate, restul, {int(cate / 2): la_mijloc})

	var candidati: Array[String] = [_sens(restul)]
	for directie in _directii_amestecate():
		candidati.append(_sens(directie))

	return _intrebare(
		"Incotro arata sageata din MIJLOC?",
		_sens(la_mijloc),
		candidati,
		"Celelalte %d arata %s, dar cea din mijloc arata %s." % [
			cate - 1, _sens(restul), _sens(la_mijloc)
		],
		_plansa(semne)
	)


## „Cate sageti arata la dreapta?" — iar restul arată invers.
##
## Două direcții, nu patru, și OPUSE una altuia: un rând cu patru direcții s-ar
## număra pe grupuri (ochiul le separă singur), iar un rând de stânga-dreapta
## cere să te uiți la fiecare.
##
## Impulsul e numărul CELORLALTE — greșeala pe care o face cine numără grupul
## mai vizibil. După el vine totalul, greșeala celui care nu desparte deloc.
func _sageti_cate(nivel: int) -> Dictionary:
	var cate := SAGETI_DE_NUMARAT[nivel - 1]
	var directii := _directii_amestecate()
	var una := directii[0]
	var alta: String = OPUSE[una]

	# Câte din direcția întrebată. Nu jumătate-jumătate: cu numere egale,
	# impulsul (numărul celorlalte) ar fi CHIAR răspunsul, deci tiparul n-ar
	# mai avea o greșeală tentantă.
	var ale_ei := randi_range(2, cate - 2)
	if ale_ei * 2 == cate:
		ale_ei += 1

	var unde: Dictionary = {}
	var locuri: Array[int] = []
	for i in range(cate):
		locuri.append(i)
	locuri.shuffle()
	for i in locuri.slice(0, ale_ei):
		unde[i] = una

	var semne := _semne_sageti(cate, alta, unde)

	var candidati: Array[String] = [str(cate - ale_ei), str(cate)]
	candidati.append_array(_numere_vecine(ale_ei))

	return _intrebare(
		"Cate sageti arata %s?" % _sens(una),
		str(ale_ei),
		candidati,
		"Din %d sageti, %d arata %s si %d arata %s." % [
			cate, ale_ei, _sens(una), cate - ale_ei, _sens(alta)
		],
		_plansa(semne)
	)


## „Apasa directia OPUSA celei din mijloc."
##
## Singurul tipar al disciplinei la care se întoarce REGULA, nu stimulul — și
## de-aia e și singurul care rămâne greu cu tot timpul din lume: un stimul se
## poate privi atent, o regulă întoarsă trebuie întoarsă de fiecare dată.
##
## Impulsul e direcția ADEVĂRATĂ a săgeții din mijloc: răspunsul corect la o
## altă întrebare, pe care l-ai citit deja de pe ecran.
##
## Flancurile arată pe CEALALTĂ axă (dacă mijlocul e sus sau jos, ele arată în
## lături). Nu e estetică: dacă flancurile ar arăta chiar în direcția opusă
## mijlocului, ele ar da răspunsul fără niciun efort — un rând de săgeți care
## arată toate spre răspuns.
func _sageti_opusul(nivel: int) -> Dictionary:
	var cate := SAGETI_IN_RAND[nivel - 1]
	var directii := _directii_amestecate()
	var la_mijloc := directii[0]
	var opusul: String = OPUSE[la_mijloc]

	# Flancurile, pe axa cealaltă: nici direcția mijlocului, nici opusul ei.
	var pe_cealalta_axa: Array[String] = []
	for directie in directii:
		if directie != la_mijloc and directie != opusul:
			pe_cealalta_axa.append(directie)
	if pe_cealalta_axa.is_empty():
		return {}
	var restul := pe_cealalta_axa[0]

	var semne := _semne_sageti(cate, restul, {int(cate / 2): la_mijloc})

	var candidati: Array[String] = [_sens(la_mijloc), _sens(restul), _sens(OPUSE[restul])]

	# ENUNȚUL ÎNTREABĂ „INCOTRO", nu „ce parte", și asta e o corectură de acord:
	# prima scriere spunea „Apasa partea OPUSA", iar butoanele răspundeau „la
	# stanga" și „in sus" — adică un enunț care cere o PARTE și patru variante
	# care dau un SENS. Se citea strâmb la fiecare a treia întrebare de săgeți.
	return _intrebare(
		"Incotro arata OPUSUL sagetii din mijloc?",
		_sens(opusul),
		candidati,
		"Cea din mijloc arata %s, deci opusul e %s." % [
			_sens(la_mijloc), _sens(opusul)
		],
		_plansa(semne)
	)


## Rândul de săgeți: toate în direcția `implicita`, în afară de locurile din
## `altfel` (indice → direcție).
##
## Mărimea scade cu lungimea rândului, ca șapte săgeți să intre în aceeași
## casetă în care intră trei. Un rând mai lat ar fi fost mai simplu de scris și
## mai rău de jucat: vezi `_plansa()` pentru de ce caseta nu se mișcă.
func _semne_sageti(cate: int, implicita: String, altfel: Dictionary) -> Array:
	var marime := 30 if cate <= 4 else (24 if cate <= 6 else 20)
	var semne: Array = []
	var locuri := _rand(cate, 0.5)
	for i in range(cate):
		var incotro: String = String(altfel.get(i, implicita))
		semne.append(_semn_sageata(locuri[i], incotro, marime))
	return semne


# ─────────────────────────────────────────────────────────────
# TIPUL 4 — FORMELE
#
# Cuvântul se bate cu forma de lângă el. Interferența imagine-cuvânt, adică
# Stroop-ul fără culoare: vezi antetul lui `plansa.gd` pentru de ce fără.
#
# DE CE CUVÂNTUL NU STĂ ÎN FORMĂ, deși acolo ar fi bătut mai tare. Măsurat, nu
# presupus: „TRIUNGHI" la mărimea 14 e lat de vreo 60 px, iar un triunghi are la
# jumătatea înălțimii cam jumătate din lățime — deci ar fi trebuit un triunghi
# de 120 px ca să încapă în el un cuvânt citibil, adică mai înalt decât toată
# caseta. Un cuvânt LÂNGĂ formă interferează oricum (e chiar proba clasică de
# interferență imagine-cuvânt), și intră în panou.
# ─────────────────────────────────────────────────────────────

## „Ce forma e desenata?" — iar lângă ea scrie numele altei forme.
##
## Impulsul e cuvântul citit. Nivelul adaugă cuvinte de pus deoparte: unul sub
## formă, apoi unul deasupra, apoi unul în stânga — niciunul numind forma.
func _forme_care(nivel: int) -> Dictionary:
	var forme := _forme_amestecate()
	var forma := forme[0]
	var cuvinte := forme.slice(1, 1 + CUVINTE_LANGA_FORMA[nivel - 1])
	if cuvinte.is_empty():
		return {}

	var semne: Array = [_semn_forma(Vector2(0.5, 0.5), forma, 46)]
	for i in range(cuvinte.size()):
		semne.append(_semn_text(LOCURI_CUVINTE[i], _numele_mare(cuvinte[i]), 17))

	var candidati: Array[String] = []
	for cheie in cuvinte:
		candidati.append(_numele_mic(cheie))
	for cheie in _forme_amestecate():
		candidati.append(_numele_mic(cheie))

	var scrise: Array[String] = []
	for cheie in cuvinte:
		scrise.append(_numele_mare(cheie))

	return _intrebare(
		"Ce forma e desenata?",
		_numele_mic(forma),
		candidati,
		"Desenul era un %s. Scria %s, dar cuvantul nu e desenul." % [
			_numele_mic(forma), ", ".join(scrise)
		],
		_plansa(semne)
	)


## „Ce cuvant e scris?" — iar în jurul lui sunt desenate alte forme.
##
## Oglinda tiparului de mai sus, pe aceeași idee: un cuvânt la mijloc, forme în
## lături, niciuna numită de cuvânt. Impulsul e numele formei desenate — ce-ți
## spune ochiul înainte să citești.
func _forme_scrie(nivel: int) -> Dictionary:
	var forme := _forme_amestecate()
	var cuvantul := forme[0]
	var desenate := forme.slice(1, 1 + FORME_LANGA_CUVANT[nivel - 1])
	if desenate.is_empty():
		return {}

	var semne: Array = [_semn_text(Vector2(0.5, 0.5), _numele_mare(cuvantul), 21)]
	var locuri: Array[Vector2] = [LOCURI["stanga"], LOCURI["dreapta"]]
	for i in range(desenate.size()):
		semne.append(_semn_forma(locuri[i], desenate[i], 44))

	var candidati: Array[String] = []
	for cheie in desenate:
		candidati.append(_numele_mare(cheie))
	for cheie in _forme_amestecate():
		candidati.append(_numele_mare(cheie))

	# ACORDUL, pe ramuri. „Desenat era un romb, cerc" (prima scriere, cu două
	# forme pe ecran) nu e românește, iar niciun verdict n-ar fi prins-o: nota
	# există, e nevidă, și pomenește exact ce trebuie. Se citește cu ochiul, din
	# mostre — aceeași regulă ca la `_forme_cate` și la notele fabricii.
	var nume_desenate: Array[String] = []
	for cheie in desenate:
		nume_desenate.append("un %s" % _numele_mic(cheie))
	var ce_era_desenat := "Desenat era %s" % nume_desenate[0]
	if nume_desenate.size() > 1:
		ce_era_desenat = "Desenate erau %s" % " si ".join(nume_desenate)

	return _intrebare(
		"Ce cuvant e scris?",
		_numele_mare(cuvantul),
		candidati,
		"Scria %s. %s, dar desenul nu e cuvantul." % [
			_numele_mare(cuvantul), ce_era_desenat
		],
		_plansa(semne)
	)


## „Cate patrate sunt?" — iar sub forme scrie altceva decât sunt.
##
## Numărătoare sub interferență, adică singurul tipar al tipului la care
## răspunsul e un număr. Impulsul e de câte ori apare CUVÂNTUL cerut: cine
## citește rândul de jos în loc să se uite la rândul de sus numără tocmai
## cuvintele.
##
## Fiecare cuvânt e greșit pentru forma de deasupra lui, ca în tot restul
## disciplinei — deci numărul formelor și numărul cuvintelor nu pot fi egale
## decât din întâmplare, iar tiparul cere să NU fie: altfel nu e nimic de pus
## deoparte.
func _forme_cate(nivel: int) -> Dictionary:
	var cate := FORME_DE_NUMARAT[nivel - 1]

	# Formele desenate și cuvintele de sub ele. `_forme_amestecate()` întoarce
	# toate patru în altă ordine, deci primele două sunt mereu diferite: cuvântul
	# e greșit pentru forma de deasupra lui, ca în tot restul disciplinei.
	var desenate: Array[String] = []
	var scrise: Array[String] = []
	for _i in range(cate):
		var forme := _forme_amestecate()
		desenate.append(forme[0])
		scrise.append(forme[1])

	# CE SE ÎNTREABĂ SE ALEGE DUPĂ CE S-A DESENAT, nu înainte.
	#
	# Prima scriere trăgea forma la sorți și pe urmă desena: la patru perechi,
	# forma cerută lipsea cu totul din desen în vreo treime din cazuri, iar
	# tiparul renunța. Un tipar care cade des nu risipește doar cicluri, STRÂMBĂ
	# echilibrul — alegerea în două trepte trece la alt TIP când toate tiparele
	# celui ales dau greș (vezi `_retete_amestecate`), deci FORMELE ar fi apărut
	# mai rar decât celelalte trei tipuri. Aceeași greșeală, și același leac, ca
	# la punctul rotațiilor din Spațial.
	var potrivite: Array[String] = []
	for cheie in _forme_amestecate():
		var ale_formei := desenate.count(cheie)
		# Trei condiții, și fiecare scoate un fel de întrebare degenerată:
		#   ZERO ar face răspunsul „zero", adică un buton pe care-l apeși fără
		#     să numeri;
		#   TOATE ar face răspunsul egal cu numărul perechilor de pe ecran — iar
		#     ăsta e chiar unul din impulsurile tiparului („nu le-am despărțit,
		#     le-am numărat pe toate"), deci impulsul ar fi fost corect;
		#   ATÂTEA CÂTE CUVINTE ar lăsa tiparul fără nimic de pus deoparte,
		#     adică fără interferență.
		if ale_formei >= 1 and ale_formei < cate and ale_formei != scrise.count(cheie):
			potrivite.append(cheie)
	if potrivite.is_empty():
		return {}

	var cheie: String = potrivite[0]
	var cate_forme := desenate.count(cheie)
	var cate_cuvinte := scrise.count(cheie)

	var semne: Array = []
	var locuri_sus := _rand(cate, 0.34)
	var locuri_jos := _rand(cate, 0.84)
	for i in range(cate):
		semne.append(_semn_forma(locuri_sus[i], desenate[i], 30))
		semne.append(_semn_text(locuri_jos[i], _numele_mare(scrise[i]), 12))

	var candidati: Array[String] = [str(cate_cuvinte), str(cate)]
	candidati.append_array(_numere_vecine(cate_forme))

	# ACORDUL, scris pe ramuri și nu dintr-un șablon. „Era 1 patrate desenate"
	# și „cuvantul PATRAT apare de 0 ori" ar fi trecut orice verificare automată
	# și sunt totuși greșite — aceeași regulă ca la formele hotărâte de la
	# Reținere și la „Emil e calugarita" de la Logică. Un `if` scris o dată nu
	# poate greși decât o dată, iar atunci se vede în mostre.
	var ce_era_desenat := "Erau desenate %d %s" % [cate_forme, _numele_multe(cheie)]
	if cate_forme == 1:
		ce_era_desenat = "Era desenat un %s" % _numele_mic(cheie)
	var ce_scria := "cuvantul %s apare de %d ori" % [_numele_mare(cheie), cate_cuvinte]
	if cate_cuvinte == 0:
		ce_scria = "cuvantul %s nu apare deloc" % _numele_mare(cheie)
	elif cate_cuvinte == 1:
		ce_scria = "cuvantul %s apare o data" % _numele_mare(cheie)

	return _intrebare(
		"Cate %s sunt DESENATE?" % _numele_multe(cheie),
		str(cate_forme),
		candidati,
		"%s; %s." % [ce_era_desenat, ce_scria],
		_plansa(semne)
	)


## „CERC" — cuvântul desenat al unei forme.
func _numele_mare(forma: String) -> String:
	return String(FORME[forma]["cuvant"])


## „cerc" — numele de pe buton și din notă.
func _numele_mic(forma: String) -> String:
	return String(FORME[forma]["unul"])


## „cercuri" — pluralul, pentru numărătoare.
func _numele_multe(forma: String) -> String:
	return String(FORME[forma]["multe"])

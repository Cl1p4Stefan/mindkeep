extends Joc
## DECRETUL ZILEI — masa a treia, și prima care nu e un joc.
##
## Celelalte două știu să facă un lucru: una ascunde un cuvânt, alta scoate
## cifre dintr-o grilă. Asta nu știe să facă niciunul. Tot ce face e să ALEAGĂ
## — ce se joacă azi și cu ce sămânță — și apoi să dea deoparte, lăsând masa
## aleasă să ocupe ecranul.
##
## ─────────────────────────────────────────────────────────────
## DE CE E O MASĂ, ȘI NU UN SISTEM
##
## Era scris de la prima masă, în antetul lui `joc.gd`: „Decretul Zilei e atunci
## o masă care trimite `data de azi` ca sămânță — adică un rând în catalog și un
## calcul de dată, nu un sistem." Fișierul ăsta e proba. Ce a trebuit:
##
##   • un calcul de dată (`zi_de_azi`)
##   • o rotație (`masa_zilei`)
##   • o sămânță (`samanta_pentru`)
##   • un steag pe disc („am jucat decretul din ziua N")
##
## `taverna.gd` nu s-a atins, nicio linie. Nici `joc.gd`: cele trei cârlige
## opționale — `reguli()`, `unelte()`, `rand_de_ajutor()` — erau exact cât
## trebuia. Masa asta e cea care spune dacă contractul scris pe 3 noiembrie
## ținea: o masă care GĂZDUIEȘTE altă masă nu seamănă cu niciuna din cele
## pentru care a fost scris.
##
## ─────────────────────────────────────────────────────────────
## SĂMÂNȚA DECRETULUI E O ZI
##
## Contractul spune „0 = alege tu, orice altceva = exact jocul ăsta". Pentru o
## masă obișnuită, „exact jocul ăsta" e un cuvânt sau o grilă. Pentru asta e o
## ZI: `porneste(19300)` joacă decretul zilei 19300, cu masa și cu grila zilei
## acelea.
##
## Nu e o șmecherie de citit sămânța, e singurul înțeles care are sens aici — și
## plătește imediat: verificarea poate juca sute de zile fără să mintă ceasul
## sistemului, iar o zi anume se poate redeschide ca să se vadă ce a fost. Un
## decret care nu se poate juca decât „azi" ar fi un cod care se poate proba
## doar o dată la 24 de ore.
##
## ─────────────────────────────────────────────────────────────
## O ROTAȚIE, NU O TRAGERE LA SORȚI
##
## `zi % câte mese sunt`. Nu o alegere pseudo-aleatoare din sămânță, și nu
## fiindcă e mai simplu: o tragere la sorți dă, din când în când, aceeași masă
## două zile la rând. Exact regula scrisă pe 2 noiembrie pentru treptele de
## combo („două trepte consecutive nu sunt din același TIP"), și pentru același
## motiv: a doua zi de Sudoku o începi cu metoda deja încălzită, deci ziua care
## ar trebui să valoreze mai mult cere mai puțin.
##
## O rotație nu poate greși așa, și n-are nevoie de nicio memorie ca să n-o
## facă. Prețul, plătit conștient: cu două mese, decretul e previzibil pe o zi
## înainte. Nu e o pierdere — „mâine e zi de Sudoku" e un motiv să te întorci,
## nu o scăpare.
##
## ─────────────────────────────────────────────────────────────
## DE CE SĂMÂNȚA NU E CHIAR ZIUA — O CORELAȚIE CARE AR FI OMORÂT UN NIVEL
##
## Rândul cel mai puțin evident din fișier, și singurul care nu s-ar fi văzut
## niciodată din joc. Sudoku își ia nivelul din sămânță: `nivel = samanta % 3`
## (vezi „CU SĂMÂNȚĂ DATĂ" din `sudoku.gd`). Dacă sămânța ar fi fost ziua, cele
## două socoteli ar fi împărțit același număr:
##
##   zilele de Sudoku  = acelea cu  `zi % N == poziția lui în listă`
##   nivelul grilei    = `zi % 3`
##
## Cu N = 2 iese bine din noroc (zilele pare trec prin toate trei nivelurile).
## Cu N = 3 — adică în ziua în care a patra masă se aprinde în catalog — `zi % 3`
## e CONSTANT pe zilele de Sudoku, deci decretul ar fi avut pe veci același
## nivel. Un joc care funcționează azi și se strică singur la o schimbare care
## nu-l atinge.
##
## Deci sămânța e un HASH al zilei, nu ziua: `hash("decretul:%d" % zi)`. Rămâne
## așezată (aceeași zi, aceeași sămânță, pentru totdeauna) și rupe legătura
## dintre rotație și orice socoteală pe care o masă face cu restul împărțirii.
## Regula, scrisă ca să se poată apăra: **o sămânță dată mai departe altui
## generator se amestecă întâi.**
##
## ─────────────────────────────────────────────────────────────
## O DATĂ PE ZI — ȘI DE CE ASTA NU ÎNCALCĂ „FĂRĂ PLAFON ARTIFICIAL"
##
## Decretul terminat se închide până la miezul nopții. Asta e chiar lucrul care
## face un decret să fie un decret: cu reîncercări nelimitate, masa asta ar fi
## fost Sudoku cu alt titlu, iar „un singur joc, altul în fiecare zi" ar fi fost
## o frază de pe un buton.
##
## CLAUDE.md cere „sesiuni scalabile, fără plafon artificial… fără energie de
## tip mobile care mă dă afară", și adaugă chiar excepția: „dacă apare vreun cap
## (ex. «antrenamentul de azi e complet»), e un semnal pozitiv și un bonus, nu o
## ușă închisă." Capul ăsta e legitim pentru un singur motiv, și el trebuie să
## rămână adevărat: **celelalte mese sunt nelimitate și stau în aceeași
## cameră.** Decretul e bonusul; jocul e Taverna. Ziua în care decretul ar fi
## singura masă din tavernă, regula asta ar trebui ștearsă.
##
## De-aia pagina de după nu e un refuz: spune ce ai făcut, când se schimbă, și
## arată spre mesele libere. Și se închide la TERMINAT, câștigat sau pierdut —
## un cuvânt pierdut își arată răspunsul în rezumat, deci „încă o dată" ar fi
## fost o reîncercare cu răspunsul în mână.
##
## ─────────────────────────────────────────────────────────────
## CE NU ȚINE MINTE, DINADINS
##
## O ZI, nu un istoric: `_zi_jucata` și dacă a ieșit bine. Nicio serie, niciun
## scor, nicio statistică. Pitch-ul cere „scor personal și o recompensă unică"
## la Decretul Zilnic — și tot pitch-ul leagă recompensele de Cetate, care nu
## există. O serie pusă azi ar fi un număr care intră în save și pe care l-aș
## reechilibra mâine CU migrare. Aceeași judecată, scrisă în antetul lui
## `taverna.gd`: „ziua în care Taverna plătește e ziua în care există ce
## cumperi."
##
## Un steag care se scrie și nu se citește niciodată n-ar fi o funcție, ar fi un
## câmp. Ăsta se citește: el e pagina de mai jos.

## Cheia mesei în catalog. Scrisă aici ca să se poată SĂRI pe sine: fără rândul
## ăsta, rotația ar fi putut nimeri decretul, care ar fi deschis un decret, care
## ar fi deschis un decret.
const CHEIE := "decretul_zilei"

const SECUNDE_PE_ZI := 86400

## Cerneala paginii. A MESEI, nu a temei, din motivul scris la `reguli()` în
## `cuvantul.gd`: masa nu mai are tăblie de pergament, deci cerneala neagră a
## temei ar fi fost neagră pe fundalul închis al camerei.
const CULOARE_TEXT := Color(0.93, 0.89, 0.8)
## Rândul care spune cum a ieșit. Verdele și portocaliul de verdict din
## `Puzzle`, ca „am reușit" să arate la fel în tot jocul — aceleași două pe care
## le folosește și Taverna pentru rândul ei de rezultat, deschise ca să se
## citească pe fond închis.
const CULOARE_REUSIT := Color(0.42, 0.68, 0.38)
const CULOARE_RATAT := Color(0.86, 0.5, 0.34)

## Lățimea unui rând de pe pagină. Un rând de 1000 px nu se citește, se caută cu
## ochii de la un capăt la altul.
const LATIME_RAND := 520

## Ziua decretului jucat, ca număr de zile de la 1 ianuarie 1970. 0 = niciunul.
##
## `static`, ca `_reguli_vazute` din `taverna.gd` și `_nivel_ales` din Sudoku,
## și din același motiv: masa se naște din nou la fiecare „Încă unul" și la
## fiecare intrare în tavernă. O variabilă de instanță s-ar fi născut goală,
## deci „o dată pe zi" ar fi însemnat „o dată pe deschidere" — adică nimic.
static var _zi_jucata := 0
## Cum a ieșit decretul din ziua aia.
static var _reusit := false

## Ziua jucată acum (vezi „SĂMÂNȚA DECRETULUI E O ZI").
var zi := 0
## Rândul din catalog al mesei de azi, sau gol.
var masa_de_azi := {}
## Masa găzduită, sau `null` — `null` și cât timp pagina e deschisă.
var masa: Joc = null
## Uneltele mesei găzduite, ținute în viață și nearătate. Vezi `_ia_uneltele`.
var unelte_ingropate: Control = null

@onready var gazda: VBoxContainer = %Gazda


func _ready() -> void:
	# Ca să poți juca masa singură, cu F6: dacă nimeni n-a chemat `porneste()`
	# până la finalul cadrului, pornim noi. Același tipar, din același motiv, ca
	# în `cuvantul.gd` și în `sudoku.gd`.
	await get_tree().process_frame
	if not pornit:
		porneste()


# ─────────────────────────────────────────────────────────────
# CINE E MASA ZILEI
#
# Tot ce urmează e `static`: alegerea e o socoteală pe catalog și pe un număr,
# deci se poate proba pe sute de zile fără să se deschidă nicio scenă. Aceeași
# regulă, scrisă la generatorul lui Sudoku: „o regulă care are nevoie de scenă
# ca să fie probată se probează mai rar."
# ─────────────────────────────────────────────────────────────

## Ce zi e azi, numărată de la 1 ianuarie 1970.
##
## LOCALĂ, nu UTC (`get_date_dict_from_system()` întoarce ora locală): decretul
## se schimbă la miezul nopții TALE. Cu UTC, un jucător din România ar fi primit
## decretul nou la 1 sau 2 noaptea, iar „azi" ar fi însemnat altceva pe ecran
## decât pe ceasul din perete.
static func zi_de_azi() -> int:
	var d := Time.get_date_dict_from_system()
	var unix := Time.get_unix_time_from_datetime_dict({
		"year": d["year"], "month": d["month"], "day": d["day"],
		"hour": 0, "minute": 0, "second": 0,
	})
	return floori(unix / float(SECUNDE_PE_ZI))


## Mesele care pot fi decretul: cele scrise, fără decretul însuși.
static func mesele_de_rand() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for m in Mese.CATALOG:
		if String(m["cheie"]) == CHEIE:
			continue
		if String(m["scena"]) == "":
			continue
		lista.append(m)
	return lista


## Masa zilei, pe rotație. Gol dacă nu e niciuna de jucat.
static func masa_zilei(zi_ceruta: int) -> Dictionary:
	var lista := mesele_de_rand()
	if lista.is_empty():
		return {}
	# `posmod`, nu `%`: ziua 0 e 1 ianuarie 1970, dar o zi dinaintea ei e
	# negativă, iar `-1 % 2` dă -1 în GDScript, adică un index în afara listei.
	# Nu se poate întâmpla din joc; se poate întâmpla dintr-o verificare care
	# probează marginile, și acolo vreau un răspuns, nu o cădere.
	return lista[posmod(zi_ceruta, lista.size())]


## Sămânța cu care se joacă masa zilei — un hash al zilei, nu ziua.
##
## DE CE SE AMESTECĂ: vezi „O CORELAȚIE CARE AR FI OMORÂT UN NIVEL" din antet.
## Pe scurt: Sudoku își ia nivelul din `samanta % 3`, iar rotația ia masa din
## `zi % N`; cu sămânța egală cu ziua, cele două socoteli împart același număr
## și, la N = 3, nivelul decretului ar fi înghețat pe veci.
static func samanta_pentru(zi_ceruta: int) -> int:
	var s := absi(hash("decretul:%d" % zi_ceruta))
	# 0 înseamnă „alege tu" în contract, deci e singura valoare care n-are voie
	# să iasă de aici. Un hash care nimerește 0 ar fi făcut decretul unei zile
	# anume să se joace liber — adică altul la fiecare deschidere, exact ce
	# promite că nu face.
	return s if s != SAMANTA_LIBERA else 1


# ─────────────────────────────────────────────────────────────
# PORNIREA
# ─────────────────────────────────────────────────────────────

func _porneste(cu_samanta: int) -> void:
	_goleste()
	zi = cu_samanta if cu_samanta != SAMANTA_LIBERA else zi_de_azi()
	masa_de_azi = masa_zilei(zi)

	if masa_de_azi.is_empty():
		# Nu se poate întâmpla cât timp decretul e în catalog lângă alte mese
		# scrise — dar „nu se poate întâmpla" e chiar felul în care o scenă
		# rămâne goală fără să spună nimeni de ce.
		push_error("Decretul nu are din ce alege: nicio altă masă nu e scrisă.")
		_arata_pagina(_pagina_fara_mese())
		return

	if _zi_jucata == zi:
		# Terminat azi. NU se cheamă `termina()`: Taverna ar fi pus rândul de
		# rezultat și butonul „Încă unul" sub o pagină care spune chiar că nu
		# mai e nimic de jucat, iar apăsarea lui ar fi dus înapoi la pagină —
		# un buton care se învârte în loc.
		_arata_pagina(_pagina_incheiata())
		return

	var cale := String(masa_de_azi["scena"])
	var scena: PackedScene = load(cale)
	if scena == null:
		push_error("Masa zilei nu s-a putut încărca (%s)." % cale)
		_arata_pagina(_pagina_fara_mese())
		return
	var nod := scena.instantiate()
	masa = nod as Joc
	if masa == null:
		# Aceeași grijă, din același motiv, ca în `taverna.gd`: o scenă care nu
		# e un `Joc` n-ar striga niciodată `terminat`, deci ecranul ar aștepta
		# la nesfârșit. Bătut și de `verifica_taverna`, pe tot catalogul.
		push_error("Masa %s nu extinde `Joc`." % cale)
		nod.queue_free()
		_arata_pagina(_pagina_fara_mese())
		return

	masa.terminat.connect(_pe_masa_terminata)
	gazda.add_child(masa)
	masa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Fără niciun cadru între `add_child` și `porneste`, exact ca în Tavernă:
	# `_ready`-ul mesei a rulat deja (deci nodurile ei există), iar steagul
	# `pornit` trebuie pus înainte să se termine cadrul — altfel masa pornește
	# și ea singură, adică două partide pentru o singură așezare.
	masa.porneste(samanta_pentru(zi))
	_ia_uneltele()


## UNELTELE MESEI GĂZDUITE NU AJUNG PE ECRAN, și nici nu se pot arunca.
##
## Cele trei butoane de nivel ale lui Sudoku repornesc partida cu
## `SAMANTA_LIBERA` — adică exact ce un decret promite că nu se întâmplă. Dar
## nici `queue_free` nu merge: `_zugraveste_nivelurile()` trece prin ele la
## fiecare pornire, deci niște butoane îngropate ar fi fost noduri moarte atinse
## de masă.
##
## Deci li se dă un părinte (eu) și se sting. Contractul permite chiar asta:
## „nodul nu mai e al tău după ce-l dai." Și mai are un rost ascuns: cu părinte,
## `_ready`-ul lui Sudoku nu-și mai pune rândul pe tăblie (verifică exact
## `get_parent() == null`), deci butoanele nu reapar nici pe masă.
##
## Regula de deasupra, scrisă o dată: **uneltele unei mese reglează partida, iar
## decretul e o partidă care nu se reglează.**
func _ia_uneltele() -> void:
	if masa == null:
		return
	var scule := masa.unelte()
	if scule == null or scule.get_parent() != null:
		return
	scule.visible = false
	add_child(scule)
	unelte_ingropate = scule


## Scoate masa de ieri (sau pagina de ieri) de pe ecran.
func _goleste() -> void:
	if masa != null:
		if masa.terminat.is_connected(_pe_masa_terminata):
			masa.terminat.disconnect(_pe_masa_terminata)
		masa = null
	if unelte_ingropate != null:
		unelte_ingropate.queue_free()
		unelte_ingropate = null
	# `remove_child` înainte de `queue_free`, ca în `_goleste_cuprinsul` din
	# `taverna.gd`: nodul mai trăiește până la finalul cadrului, iar un copil
	# încă în arbore ar fi intrat în socoteala de înălțime a containerului fix
	# în cadrul în care se măsoară ecranul nou.
	for copil in gazda.get_children():
		gazda.remove_child(copil)
		copil.queue_free()


func _pe_masa_terminata(rez: Dictionary) -> void:
	_zi_jucata = zi
	_reusit = bool(rez.get("reusit", false))
	# Pe disc IMEDIAT, nu la plecarea din tavernă — aceeași judecată, scrisă la
	# `_poate_prima_oara` în `taverna.gd`: un joc închis din colțul ferestrei ar
	# fi lăsat decretul nescris, adică l-ai fi putut juca din nou. Taverna
	# salvează și ea la `terminat`, iar dubla scriere costă nimic; ce nu se
	# poate presupune e că decretul se joacă într-o Tavernă — F6 îl deschide
	# singur.
	Arhiva.salveaza_permanent()
	# Rezumatul mesei, întreg și neatins. Vocea e a jocului care s-a jucat —
	# chiar greșeala pe care Taverna a făcut-o o zi, cu prefixul „Ai găsit! ".
	termina(_reusit, String(rez.get("rezumat", "")))


# ─────────────────────────────────────────────────────────────
# PAGINA DE DUPĂ
# ─────────────────────────────────────────────────────────────

func _arata_pagina(pagina: Control) -> void:
	var centru := CenterContainer.new()
	centru.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centru.add_child(pagina)
	gazda.add_child(centru)


## „Decretul de azi e încheiat." Vezi „O DATĂ PE ZI" din antet: pagina spune ce
## ai făcut, când se schimbă, și arată spre mesele libere. Nu e un refuz.
func _pagina_incheiata() -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 14)

	var titlu := _rand("DECRETUL DE AZI E ÎNCHEIAT", 26)
	titlu.theme_type_variation = &"TitluPergament"
	coloana.add_child(titlu)

	var cum := _rand("L-ai scos." if _reusit else "Nu l-ai scos.", 20)
	cum.add_theme_color_override("font_color",
		CULOARE_REUSIT if _reusit else CULOARE_RATAT)
	coloana.add_child(cum)

	# CE A FOST, nu doar „ai jucat": peste o zi n-ai de unde să-ți amintești ce
	# masă a dat decretul. Numele vine din catalog, deci rândul rămâne adevărat
	# când se aprinde a patra masă.
	coloana.add_child(_rand("Azi pe masă a fost %s." % String(masa_de_azi["nume"]), 17))
	coloana.add_child(_rand(
		"Se schimbă la miezul nopții. Până atunci, mesele libere te așteaptă"
		+ " oricând: la ele nu se termină nimic.", 17))
	return coloana


## Nicio masă de ales. O pagină, nu o scenă goală — vezi `_porneste`.
func _pagina_fara_mese() -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 12)
	coloana.add_child(_rand("Decretul de azi nu s-a putut deschide.", 20))
	coloana.add_child(_rand("Alege o masă din cele libere.", 17))
	return coloana


## Un rând de text de pe pagină.
func _rand(text: String, marime: int) -> Label:
	var eticheta := Label.new()
	eticheta.text = text
	eticheta.add_theme_font_size_override("font_size", marime)
	eticheta.add_theme_color_override("font_color", CULOARE_TEXT)
	eticheta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eticheta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	eticheta.custom_minimum_size = Vector2(LATIME_RAND, 0)
	return eticheta


# ─────────────────────────────────────────────────────────────
# CELE TREI CÂRLIGE OPȚIONALE DIN CONTRACT
# ─────────────────────────────────────────────────────────────

## Fraza de ajutor din antetul Tavernei. CARE MASĂ E AZI se spune aici, și nu
## altundeva: titlul e „DECRETUL ZILEI" (îl pune Taverna, din catalog), deci
## fără rândul ăsta ar fi trebuit să ghicești din ecran la ce te-ai așezat.
func rand_de_ajutor() -> String:
	if masa == null:
		return "Un joc, altul în fiecare zi. Pe azi s-a încheiat."
	return "Azi: %s. %s" % [String(masa_de_azi["nume"]), masa.rand_de_ajutor()]


## Regulile: ale decretului, apoi ale mesei de azi, în aceeași pagină.
##
## „O SINGURĂ DATĂ" E AL DECRETULUI, nu al mesei găzduite, și e o alegere, nu o
## scăpare. Taverna ține minte „ți-am arătat regulile" pe cheia mesei deschise
## (vezi `_reguli_vazute`), iar cheia asta e `decretul_zilei`. Deci panoul se
## deschide singur o dată — prima așezare — și nu se mai deschide când, peste o
## zi, decretul e alt joc.
##
## Aș fi putut cere Tavernei să țină minte pe cheia mesei DE DEDESUBT. Ar fi
## însemnat ca Taverna să știe că o masă poate găzdui alta, adică exact ce nu
## știe și nu trebuie să știe. Iar ce se pierde e mic: butonul „i" e acolo în
## fiecare zi, iar regulile pe care le ratezi sunt ale unui joc pe care-l poți
## deschide liber, cu regulile lui, pe masa lui.
func reguli() -> Control:
	var coloana := VBoxContainer.new()
	coloana.add_theme_constant_override("separation", 10)
	if masa == null:
		coloana.add_child(_rand_de_reguli(
			"Un singur joc, altul în fiecare zi, același de câte ori îl deschizi"
			+ " în ziua aceea. Îl joci o dată: când se termină, se termină până"
			+ " la miezul nopții. Mesele libere rămân nelimitate.", 17))
		return coloana
	# UN SINGUR PARAGRAF, cu numele mesei în el, nu două cu un rând „Azi pe masă
	# e SUDOKU:" între ele. Nu e o preferință de scriitură, e o MĂSURĂTOARE:
	# panoul decretului e paragraful lui PLUS panoul întreg al mesei de azi, iar
	# cu rândul acela în plus ieșea 672 px pe o pânză de 648 — tăiat sus și jos,
	# fiindcă `PanouReguli` e un `CenterContainer` și nu se derulează. Bătut de
	# `verifica_taverna`, pe fiecare masă de rând: ziua în care o masă nouă vine
	# cu reguli mai lungi, verdictul o spune înainte s-o vadă cineva tăiată.
	coloana.add_child(_rand_de_reguli(
		"Un singur joc, altul în fiecare zi: azi, %s. Îl joci o dată — când se"
		% String(masa_de_azi["nume"])
		+ " termină, se termină până la miezul nopții, iar mesele libere rămân"
		+ " nelimitate.", 17))
	# Regulile mesei de azi, construite de MASĂ. Un rezumat scris aici ar fi
	# fost un al doilea text despre același joc, cu toate șansele să rămână în
	# urmă — chiar motivul pentru care regulile sunt ale mesei și nu ale
	# Tavernei (vezi `Joc.reguli`).
	var ale_mesei := masa.reguli()
	if ale_mesei != null:
		coloana.add_child(ale_mesei)
	return coloana


## Un rând din panoul cu reguli. Ca la celelalte două mese: panoul stă pe fond
## închis, deci cerneala e a mesei. Fără lățime minimă — panoul Tavernei o dă,
## iar una pusă aici s-ar fi bătut cu a lui.
func _rand_de_reguli(text: String, marime: int) -> Label:
	var eticheta := _rand(text, marime)
	eticheta.custom_minimum_size = Vector2.ZERO
	return eticheta


## Niciuna. Vezi `_ia_uneltele`: uneltele unei mese reglează partida, iar
## decretul e o partidă care nu se reglează.
func unelte() -> Control:
	return null


# ─────────────────────────────────────────────────────────────
# CE SE SCRIE PE DISC
#
# O zi și un rezultat. Forma e cea de la Practice și de la Tavernă: starea stă
# în SCENA care o produce, iar `Arhiva` doar adună dicționarele.
# ─────────────────────────────────────────────────────────────

static func spre_dictionar() -> Dictionary:
	return {"zi_jucata": _zi_jucata, "reusit": _reusit}


## Citit strâmb, ca peste tot: cheie lipsă = n-ai jucat niciun decret, altceva
## decât un număr = la fel. Un save mai vechi (fără cheile astea) deschide
## decretul de azi, ceea ce e chiar purtarea de la prima instalare — deci nu are
## nevoie de migrare.
##
## O zi NEGATIVĂ sau din viitor se citește cum e scrisă, dinadins: o „curățare"
## care ar arunca ziua din viitor ar fi fost chiar calea prin care un ceas de
## sistem dus înainte și întors deschide decretul a doua oară.
static func din_dictionar(date: Dictionary) -> void:
	var zi_citita = date.get("zi_jucata")
	var e_numar: bool = typeof(zi_citita) == TYPE_INT or typeof(zi_citita) == TYPE_FLOAT
	_zi_jucata = int(zi_citita) if e_numar else 0
	# `is bool`, nu `bool(...)`: GDScript nu are un constructor `bool` dintr-un
	# text, deci un save în care „reusit" e scris ca „poate" ar fi căzut cu
	# „Nonexistent 'bool' constructor" — adică un fișier strâmb ar fi oprit
	# încărcarea, exact ce nu are voie să facă (vezi „Un save mai nou NU se
	# citește" din CLAUDE.md: vechi sau strâmb se deschide, cu valori implicite).
	var reusit_citit = date.get("reusit")
	_reusit = reusit_citit is bool and reusit_citit

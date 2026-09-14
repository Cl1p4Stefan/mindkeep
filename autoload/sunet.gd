extends Node
## REGIZORUL DE EFECTE SONORE — fratele lui `Muzica`, dar pentru sunete scurte.
##
## E tot un „autoload" (Project → Project Settings → Autoload), din exact
## aceleași motive ca `Muzica`: trăiește de la pornirea jocului până la
## închiderea lui, supraviețuiește schimbărilor de scenă, și poate fi chemat
## de oriunde cu o singură linie — `Sunet.reda(Sunet.Efect.CORECT)`.
##
## DE CE UN AL DOILEA REGIZOR, ȘI NU O METODĂ ÎN `Muzica`:
## muzica și efectele sunt două lucruri diferite care se ceartă pe același
## difuzor. Muzica e UNA, cântă minute întregi și are nevoie de fade-uri;
## efectele sunt MULTE, durează sub o secundă și trebuie să pornească instant.
## Dacă ar împărți un `AudioStreamPlayer`, un „corect" ar tăia muzica de luptă.
## Două regizoare = două volume reglabile separat, ceea ce e chiar ce ai vrut:
## poți da muzica mai încet fără să faci și verdictul de nedeslușit.

# ─────────────────────────────────────────────────────────────
# REGLAJE
# ─────────────────────────────────────────────────────────────
## Volumul efectelor, în decibeli. 0 = volumul original al fișierelor.
## Decibelii sunt logaritmici, nu procente: -6 dB ≈ jumătate din putere.
##
## Stă deliberat DEASUPRA muzicii (`Muzica.VOLUM_DB`, azi -12 dB): muzica e
## fundal și n-are voie să fie observată conștient, iar verdictul e informație
## și trebuie să treacă peste ea fără efort. Dacă vreodată sunetele acoperă
## muzica sau invers, ăsta e singurul număr de schimbat — e reglajul, nu o
## valoare de calcul, și de-aia e constantă cu nume, nu un număr rătăcit prin
## `reda()`.
const VOLUM_DB := -6.0

## Câte sunete pot cânta ÎN ACELAȘI TIMP.
##
## Un singur `AudioStreamPlayer` poate ține o singură voce: dacă îi ceri un al
## doilea sunet, îl TAIE pe primul în mijloc. Azi n-ar deranja (între două
## verdicte trec secunde), dar prima dată când adaugi un sunet de daune peste
## „corect" — și o să-l adaugi, e chiar următorul pas — s-ar tăia unul pe
## celălalt și ai căuta cauza în fișierul .ogg, nu aici.
##
## 3 voci e un compromis ieftin: trei noduri făcute o dată la pornire, care
## stau tăcute când nu fac nimic. Nu e o coadă și nu e un sistem de
## priorități — dacă toate trei cântă, a patra cerere o fură pe cea mai veche.
const VOCI := 3

## Volumul TUNETULUI de critic, în decibeli. Al doilea reglaj de volum pentru
## efectele din rotație — și singurul care iese din `VOLUM_DB` de mai sus.
##
## De ce nu împarte volumul cu „corect"/„greșit": alea sună la FIECARE răspuns,
## iar tunetul o dată la cinci. Un sunet rar are voie să fie mai mare decât unul
## des — asta e chiar diferența dintre „ai răspuns" și „ai făcut ceva special".
## La același volum cu bipul, criticul ar fi doar încă un răspuns corect, cu alt
## timbru.
##
## +2 dB peste restul efectelor, nu mai mult: tunetul e deja un sunet lat, care
## ocupă mult spectru, deci pare mai tare decât arată numărul. Dacă te face să
## tresari, ĂSTA e singurul număr de schimbat — nu `VOLUM_DB`, care ar trage și
## verdictele după el.
const VOLUM_CRITIC_DB := -4.0

## Volumul TICĂITULUI de ceas, în decibeli. Reglaj propriu, separat de
## `VOLUM_DB` de mai sus — și trebuie să rămână separat.
##
## De ce nu împarte volumul cu restul efectelor: „corect"/„greșit" sunt
## VERDICTE, sună o dată și au voie să fie cele mai tari lucruri de pe ecran.
## Ticăitul e PRESIUNE: stă sub tine cinci secunde la rând, iar un sunet care
## se repetă obosește mult mai repede decât unul care trece. Dacă ar urca și
## el când dai efectele mai tari, ultima secundă a fiecărei întrebări ar
## deveni de nesuportat.
##
## Cum a fost ales numărul, ca să știi în ce direcție să-l muți:
##   • muzica de fundal stă la -12 dB (`Muzica.VOLUM_DB`);
##   • cât e o întrebare pe ecran, muzica e trasă la -21 dB (cu `ATENUARE_DB`).
## -16 dB cade fix între ele: SUB muzica normală (deci nu e un sunet care se
## impune), dar cu ~5 dB DEASUPRA muzicii atenuate — adică exact cât trebuie
## ca să treacă peste ea în clipa în care chiar contează.
##
## Decibelii nu spun totul: fișierele pot fi înregistrate la volume diferite,
## deci dacă ticăitul iese prea agresiv sau prea timid, ĂSTA e singurul număr
## de schimbat. Nu umbla la `VOLUM_DB` pentru el.
const VOLUM_TICAIT_DB := -16.0

## Fișierul ticăitului. Nu stă în catalogul `EFECTE` de mai jos, și nu e o
## scăpare: catalogul ăla e pentru sunete de UNICĂ FOLOSINȚĂ, aruncate pe
## prima voce liberă și uitate. Ticăitul e opusul — e UNUL singur, ține cât
## ține, și cineva trebuie să poată spune „gata, taci". Are nevoie de un
## difuzor cu nume, nu de o voce din rotație, deci are și o cale cu nume.
const CALE_TICAIT := "res://assets/audio/clock_tick.ogg"

## Volumul VERDICTELOR FINALE (victorie / înfrângere), în decibeli.
## Al patrulea reglaj de volum din fișier, și ultimul.
##
## De ce nu împarte `VOLUM_DB` cu „corect"/„greșit": alea sunt bipuri de câteva
## zecimi de secundă, tăiate scurt și normalizate tare ca să treacă peste
## muzică. Verdictele sunt bucăți de MUZICĂ — au orchestrație, cresc și se
## sting singure, țin câteva secunde. Un fișier muzical adus la același vârf ca
## un bip se aude mult mai tare, fiindcă stă tare tot timpul, nu doar o clipă.
## De-aia pornesc mai jos, nu mai sus.
##
## Dacă victoria te sperie sau înfrângerea abia se aude, ĂSTA e singurul număr
## de schimbat.
const VOLUM_VERDICT_DB := -8.0

## Cât durează stingerea unui verdict întrerupt (vezi `opreste_verdict()`).
##
## Scurt, dar nu zero — și aici e diferența față de ticăit, care se taie din
## cuțit. Ticăitul e făcut din pocnete: între două pocnete e liniște, deci
## oriunde l-ai tăia nu tai nimic. Verdictul e o notă ținută, iar o tăietură
## peste o coardă care încă sună se aude ca un clic în difuzor.
const FADE_VERDICT := 0.4

## „Practic mut", ținta stingerii de mai sus. Aceeași valoare și același motiv
## ca `Muzica.VOLUM_TACERE`: de pe la -60 dB nu se mai aude nimic, iar drumul
## până acolo e destul de scurt cât să nu pară că sunetul se târăște.
const VOLUM_TACERE_DB := -60.0

# ─────────────────────────────────────────────────────────────
# CATALOGUL DE EFECTE
# Exact ca la `Muzica`: un rând în enum, un rând în tabel, și gata.
# Fișierele lipsă NU sunt o eroare fatală — vezi `_ready()`.
# ─────────────────────────────────────────────────────────────
enum Efect {
	CORECT,
	GRESIT,
	CRITIC,
}

const EFECTE := {
	Efect.CORECT: "res://assets/audio/correct_answer.ogg",
	Efect.GRESIT: "res://assets/audio/incorrect_answer.ogg",
	Efect.CRITIC: "res://assets/audio/critical_thunder.ogg",
}

## EXCEPȚIILE DE VOLUM. Un efect care nu apare aici cântă la `VOLUM_DB`; unul
## care apare își aduce propriul număr.
##
## De ce un tabel și nu încă un `AudioStreamPlayer` cu nume, ca la ticăit și la
## verdicte: alea au nevoie de un difuzor al lor fiindcă trebuie să poată fi
## OPRITE la comandă. Tunetul e „dă-i drumul și uită de el", exact ca bipurile —
## îi trebuie doar alt volum, nu alt difuzor. Un tabel de excepții ține reglajul
## aici, lângă celelalte, în loc să-l trimită ca argument din scena de luptă,
## unde ar deveni un număr rătăcit prin cod de joc.
const VOLUM_EFECT := {
	Efect.CRITIC: VOLUM_CRITIC_DB,
}

## VERDICTELE FINALE — sfârșitul unei lupte, într-un sunet.
##
## Catalog separat de `EFECTE`, cu enum separat, și nu din simetrie: așa nu poți
## cere din greșeală o fanfară acolo unde vrei un bip. `reda()` primește
## `Efect`, `reda_verdict()` primește `Verdict`, și cele două nu se amestecă.
## (Tehnic, ambele enum-uri sunt întregi care încep de la 0 — `Efect.CORECT` și
## `Verdict.VICTORIE` sunt amândouă 0 — deci două cataloage separate sunt exact
## ce împiedică un „0" rătăcit să cânte altceva decât crezi.)
enum Verdict {
	VICTORIE,
	INFRANGERE,
}

const VERDICTE := {
	Verdict.VICTORIE: "res://assets/audio/victory.ogg",
	Verdict.INFRANGERE: "res://assets/audio/defeat.ogg",
}

# ─────────────────────────────────────────────────────────────
# STARE
# ─────────────────────────────────────────────────────────────
## Sunetele deja încărcate în memorie, indexate după `Efect`.
## Le încărcăm O DATĂ, la pornire, nu la fiecare `reda()`: `load()` citește de
## pe disc, iar o citire de pe disc în mijlocul unei lupte e exact genul de
## mică sacadare care strică sincronizarea cu flash-ul. Fișierele astea au
## zeci de kilobytes — să stea în RAM toată partida nu costă nimic.
var _incarcate := {}

## Difuzoarele. Le rotim pe rând, ca să nu se taie unul pe altul.
var _voci: Array[AudioStreamPlayer] = []
var _voce_urmatoare := 0

## Difuzorul ticăitului. Al lui și numai al lui, pentru că e singurul sunet
## din joc care trebuie OPRIT la comandă. Dacă ar cânta pe o voce din rotație,
## a treia cerere de „corect" de după i-ar fura difuzorul și ticăitul s-ar
## opri singur, din senin, la mijlocul unei secunde.
var _ticait: AudioStreamPlayer = null

## Verdictele încărcate în memorie, și difuzorul lor.
##
## Al doilea difuzor cu nume din fișier, din același motiv ca ticăitul: trebuie
## să poată fi OPRIT la comandă. Concret — apeși „Continuă" pe ecranul de
## victorie la două secunde de la fanfară, lupta repornește, iar fanfara ar mai
## cânta încă cinci secunde peste muzica luptei noi. Pe o voce din rotație
## n-ai avea de ce s-o apuci.
##
## Și n-are nevoie de rotație, spre deosebire de efecte: nu poți câștiga și
## pierde în același timp. Un verdict, un difuzor.
var _verdicte_incarcate := {}
var _verdict: AudioStreamPlayer = null

## Stingerea verdictului întrerupt. O ținem într-o variabilă, n-o uităm după
## `create_tween()`, ca s-o putem omorî dacă cineva cere alt verdict în timpul
## ei — altfel tween-ul vechi ar ajunge la capăt și ar chema `stop()` peste
## sunetul nou.
var _tween_verdict: Tween = null


func _ready() -> void:
	# Difuzoarele le construim din cod, nu dintr-o scenă: sunt noduri identice,
	# fără nimic de aranjat vizual.
	for i in VOCI:
		var player := AudioStreamPlayer.new()
		player.name = "Voce%d" % i
		player.volume_db = VOLUM_DB
		add_child(player)
		_voci.append(player)

	# Efectele merg și când jocul e pus pe pauză. Nu avem încă pauză, dar când
	# o adaugi n-o să te întrebi de ce a amuțit jumătate de joc.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_incarca_efectele()
	_pregateste_ticaitul()
	_pregateste_verdictele()


## Aduce toate fișierele din catalog în memorie.
##
## `ResourceLoader.exists()` întreabă ÎNAINTE de încărcare, deci un fișier
## lipsă (sau neimportat încă de editor) e un avertisment în consolă și un joc
## care merge mai departe în liniște — nu un crash. Aceeași plasă de siguranță
## ca la `Muzica`: sunetul e decor peste o buclă care trebuie să funcționeze
## și fără el.
func _incarca_efectele() -> void:
	for efect: int in EFECTE:
		var cale: String = EFECTE[efect]
		if not ResourceLoader.exists(cale):
			push_warning("Sunet: lipseste %s — efectul ramane mut." % cale)
			continue

		var stream: AudioStream = load(cale)

		# Un efect scurt NU are voie să se repete la nesfârșit. Importatorul
		# din Godot pune uneori bucla singur pe fișierele .ogg (o face pentru
		# muzică, unde e ce trebuie), iar un „corect" în buclă ar ține ecranul
		# de luptă într-un bâzâit până la sfârșitul partidei. O tăiem explicit,
		# ca să nu depindem de ce-a bifat cineva în panoul de import.
		if "loop" in stream:
			stream.set("loop", false)

		_incarcate[efect] = stream


## Redă un efect din catalog. Sigur de chemat oricând: dacă fișierul lipsește,
## nu se întâmplă nimic.
##
## Pornește ÎN CADRUL în care e chemată — de-asta poate sta lipită de un tween
## vizual și se citește ca un singur moment, nu ca două.
func reda(efect: int) -> void:
	if not _incarcate.has(efect):
		return   # fișier lipsă; avertismentul a fost deja dat la pornire

	# Rotim vocile în cerc. Nu căutăm o voce liberă: căutarea ar face ca două
	# sunete pornite în același cadru să nimerească uneori același difuzor
	# (niciunul n-a apucat să raporteze că e ocupat). Rotația e oarbă, dar
	# garantează că cereri consecutive nimeresc difuzoare diferite.
	var player := _voci[_voce_urmatoare]
	_voce_urmatoare = (_voce_urmatoare + 1) % VOCI

	player.stream = _incarcate[efect]
	# Volumul se rescrie la fiecare redare, nu doar la pornire: așa poți schimba
	# reglajul și îl auzi la reîncărcarea scenei, fără repornirea jocului.
	#
	# Și TREBUIE rescris, nu doar pus o dată în `_ready()`: vocile se rotesc, deci
	# difuzorul ăsta a cântat data trecută alt efect, poate cu alt volum. Fără
	# linia asta, un „corect" nimerit pe voce după un tunet ar moșteni volumul
	# tunetului — un bip mai tare o dată la trei, fără nicio cauză vizibilă.
	player.volume_db = VOLUM_EFECT.get(efect, VOLUM_DB)
	player.play()


# ─────────────────────────────────────────────────────────────
# TICĂITUL DE CEAS
#
# Singurul sunet din fișierul ăsta care are un ÎNCEPUT și un SFÂRȘIT date de
# altcineva. Toate celelalte sunt „dă-i drumul și uită de el"; ăsta trebuie
# pornit când presiunea începe și oprit în clipa în care se termină.
#
# Cine cheamă: DOAR puzzle-urile (Trivia, Logica, și cele care vor veni), din
# cronometrul lor. `Sunet` nu știe ce e o întrebare, un prag sau o secundă —
# și e bine că nu știe: mâine vrei poate același ticăit pe un nod de hartă
# cu limită de timp, și o să meargă fără să atingi nimic aici.
# ─────────────────────────────────────────────────────────────

## Construiește difuzorul ticăitului. Chemată o dată, din `_ready()`.
func _pregateste_ticaitul() -> void:
	_ticait = AudioStreamPlayer.new()
	_ticait.name = "Ticait"
	_ticait.volume_db = VOLUM_TICAIT_DB

	# ATENȚIE, asta e diferența față de nodul-părinte: `Sunet` e pus pe
	# PROCESS_MODE_ALWAYS (vezi `_ready()`), adică efectele merg și cu jocul
	# pus pe pauză. Pentru un verdict e corect. Pentru ticăit ar fi o minciună:
	# cronometrul întrebării e un `_process` în puzzle, deci pe pauză se
	# OPREȘTE — iar un ceas care ticăie peste un timp înghețat îți spune că
	# pierzi secunde pe care nu le pierzi. PAUSABLE îl leagă de aceeași pauză
	# ca timpul pe care îl numără.
	_ticait.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_ticait)

	# Aceeași plasă de siguranță ca la efecte: fișier lipsă (sau neimportat
	# încă de editor) = un avertisment și un joc care merge mai departe mut,
	# nu un crash. `_ticait.stream` rămâne `null`, iar `porneste_ticait()` se
	# retrage singur.
	if not ResourceLoader.exists(CALE_TICAIT):
		push_warning("Sunet: lipseste %s — ticaitul ramane mut." % CALE_TICAIT)
		return

	var stream: AudioStream = load(CALE_TICAIT)

	# Aici bucla e CERUTĂ, spre deosebire de efecte, unde o tăiem.
	# Fișierul are ~8 secunde de ticăit, iar fereastra de urgență e de 5, deci
	# în practică nu se ajunge niciodată la capăt. O punem totuși: ziua în care
	# muți pragul la 10 secunde nu trebuie să fie și ziua în care ceasul
	# amuțește la jumătate, fără niciun indiciu de ce.
	if "loop" in stream:
		stream.set("loop", true)

	_ticait.stream = stream


## Pornește ticăitul. SIGURĂ de chemat de oricâte ori — și chiar e chemată de
## ~60 de ori pe secundă, din cronometrul puzzle-ului.
##
## Garda `playing` e tot ce face idempotența asta să funcționeze, și e esențială:
## fără ea, fiecare cadru ar reporni sunetul de la capăt, iar rezultatul n-ar fi
## un ticăit, ci un bâzâit continuu — primele milisecunde ale fișierului, redate
## la infinit. Cu ea, apelantul n-are de ținut minte nicio stare: spune „acum e
## urgent" în fiecare cadru în care e adevărat, și atât.
func porneste_ticait() -> void:
	if _ticait == null or _ticait.stream == null:
		return   # fișier lipsă; avertismentul a fost deja dat la pornire
	if _ticait.playing:
		return   # ticăie deja: NU-l repornim (vezi mai sus)

	# Volumul se rescrie la fiecare pornire, ca la `reda()`: așa poți schimba
	# `VOLUM_TICAIT_DB` și îl auzi la reîncărcarea scenei, fără repornirea jocului.
	_ticait.volume_db = VOLUM_TICAIT_DB
	_ticait.play()


## Oprește ticăitul, pe loc. Fără fade: un ticăit stins lin ar suna ca un ceas
## care se îndepărtează, iar mesajul e opusul — timpul NU mai curge, punct.
## Sunetul e oricum din transiente scurte, deci tăietura nu pocnește.
##
## La fel de sigură de chemat de oricâte ori, inclusiv când nu ticăia nimic:
## de asta puzzle-ul își permite s-o pună în toate ieșirile lui, fără să țină
## minte dacă apucase să pornească.
func opreste_ticait() -> void:
	if _ticait == null or not _ticait.playing:
		return
	_ticait.stop()


# ─────────────────────────────────────────────────────────────
# VERDICTELE FINALE
#
# Sunetele care marchează sfârșitul unei lupte: fanfara de victorie și
# „Șah Mat"-ul. Se aud O SINGURĂ DATĂ, în cadrul în care apare panoul.
#
# Cine cheamă: DOAR scena de luptă, din `termina_lupta()`. `Sunet` nu știe ce e
# o victorie, o rundă sau un rege căzut — primește un verdict și îl cântă.
#
# ȘI NU SE ATINGE DE MUZICĂ. Ar fi fost tentant: „dacă tot cânt fanfara, opresc
# eu și muzica de fundal". Dar atunci `Sunet` ar trebui să știe ce e pe ecran ca
# să ghicească dacă muzica se oprește de tot sau doar se dă mai încet — și n-are
# de unde. Lupta decide (`Muzica.opreste()`, din `termina_lupta()`), exact ca la
# atenuarea de la întrebări. Cele două regizoare rămân surde una la alta, ca
# fanfara să poată fi folosită mâine și pe hartă, fără să oprească muzica hărții.
# ─────────────────────────────────────────────────────────────

## Construiește difuzorul verdictelor și aduce fișierele în memorie.
## Chemată o dată, din `_ready()`.
func _pregateste_verdictele() -> void:
	_verdict = AudioStreamPlayer.new()
	_verdict.name = "Verdict"
	_verdict.volume_db = VOLUM_VERDICT_DB
	add_child(_verdict)

	for verdict: int in VERDICTE:
		var cale: String = VERDICTE[verdict]

		# Aceeași plasă de siguranță ca peste tot în fișierul ăsta: fișier
		# lipsă (sau neimportat încă de editor) = un avertisment în consolă și
		# o luptă care se termină în tăcere, nu un crash.
		if not ResourceLoader.exists(cale):
			push_warning("Sunet: lipseste %s — verdictul ramane mut." % cale)
			continue

		var stream: AudioStream = load(cale)

		# Bucla se taie, ca la efecte — dar aici contează mai mult decât acolo.
		# Fișierele astea SUNT muzicale, iar importatorul din Godot pune bucla
		# tocmai pe ce sună a muzică; o fanfară în buclă ar ține peste ecranul
		# de victorie până apeși „Continuă".
		if "loop" in stream:
			stream.set("loop", false)

		_verdicte_incarcate[verdict] = stream


## Redă un verdict. Sigură de chemat oricând: dacă fișierul lipsește, nu se
## întâmplă nimic.
##
## Pornește ÎN CADRUL în care e chemată, ca `reda()` — de-aia apelul poate sta
## lipit de linia care aprinde panoul, iar cele două se citesc ca un singur
## moment, nu ca un sunet și, separat, o imagine.
func reda_verdict(verdict: int) -> void:
	if _verdict == null or not _verdicte_incarcate.has(verdict):
		return   # fișier lipsă; avertismentul a fost deja dat la pornire

	# Dacă tocmai se stingea un verdict, oprim stingerea: altfel tween-ul ei ar
	# continua să coboare volumul peste sunetul nou și ar chema `stop()` pe el.
	_opreste_tween_verdict()

	_verdict.stream = _verdicte_incarcate[verdict]
	# Volumul se rescrie la fiecare redare — și aici nu e doar comoditatea de a
	# schimba constanta fără să repornești jocul, ca la `reda()`. E obligatoriu:
	# `opreste_verdict()` lasă difuzorul coborât la `VOLUM_TACERE_DB`, deci fără
	# linia asta al doilea verdict ar porni mut.
	_verdict.volume_db = VOLUM_VERDICT_DB
	_verdict.play()


## Oprește verdictul, stingându-l scurt (vezi `FADE_VERDICT`).
##
## La fel de sigură de chemat de oricâte ori, inclusiv când nu cânta nimic:
## de-asta lupta o pune liniștită în `reseteaza_lupta()`, fără să țină minte
## dacă apucase să pornească vreun verdict.
func opreste_verdict() -> void:
	if _verdict == null or not _verdict.playing:
		return

	_opreste_tween_verdict()
	_tween_verdict = create_tween()
	_tween_verdict.tween_property(_verdict, "volume_db", VOLUM_TACERE_DB, FADE_VERDICT)
	# `tween_callback` pus DUPĂ `tween_property` rulează după el, nu odată cu
	# el: difuzorul se oprește abia la finalul stingerii. Dacă l-am opri acum,
	# n-ar mai avea ce să se stingă.
	_tween_verdict.tween_callback(_verdict.stop)


## Omoară stingerea în curs, dacă există. Aceeași grijă ca la `Muzica`: două
## tween-uri care trag de același `volume_db` se calcă unul pe altul, iar cel
## vechi ar câștiga jumătate din cadre.
func _opreste_tween_verdict() -> void:
	if _tween_verdict != null and _tween_verdict.is_valid():
		_tween_verdict.kill()


## Curățenie la închiderea jocului, ca la `Muzica`: oprim difuzoarele și le
## luăm sunetele din mână.
func _exit_tree() -> void:
	for player: AudioStreamPlayer in _voci:
		player.stop()
		player.stream = null
	_incarcate.clear()
	if _ticait != null:
		_ticait.stop()
		_ticait.stream = null
	_opreste_tween_verdict()
	if _verdict != null:
		_verdict.stop()
		_verdict.stream = null
	_verdicte_incarcate.clear()

extends Node
## ARHIVA — singurul fișier din joc care atinge discul.
##
## E autoload, ca `Tezaur`, `Sac` și `Expeditie`, dar cu un rol diferit de al
## lor: ele ȘTIU starea, ea doar o DUCE pe disc și o aduce înapoi. Arhiva nu
## conține nicio regulă de joc — nu știe ce e un Fragment, ce e un nod de Boss,
## ce înseamnă „practice". Știe trei lucruri: JSON, `FileAccess`, și numele
## celor patru dicționare pe care le adună.
##
## ─────────────────────────────────────────────────────────────
## DEPENDENȚA MERGE ÎNTR-UN SINGUR SENS
##
## Arhiva depinde de toate; nimeni nu depinde de Arhivă. `Tezaur` nu se
## salvează singur, `Expeditie` nu cheamă nicio salvare. Ăsta nu e purism:
##
## APELURILE DE SALVARE STAU ÎN SCENE (`harta.gd`, `lupta.gd`, `practice.gd`),
## nu în autoload-uri, și motivul e măsurabil. `tools/verificari/verifica_drumuri.gd`
## joacă vreo 20.000 de expediții — adică sute de mii de `intra_in_nod()` —, iar
## `verifica_harta.gd` cheamă `incepe()` pe sute de semințe. Dacă salvarea ar fi
## înăuntrul lor, fiecare verificare ar bate discul de sute de mii de ori ȘI ar
## scrie peste save-ul adevărat. Așa, uneltele rămân uscate fără să știe că
## există Save.
##
## Prețul, scris: un viitor apelant al lui `intra_in_nod()` poate uita
## salvarea. Azi există un singur ecran care-l cheamă.
##
## ─────────────────────────────────────────────────────────────
## DOUĂ FIȘIERE, FIINDCĂ SUNT DOUĂ DURATE DE VIAȚĂ
##
##   `permanent.json`   Tezaurul, progresul din Antrenament, sacurile permanente.
##                      Se scrie rar. E fișierul pe care n-ai voie să-l pierzi.
##   `expeditie.json`   Expediția în curs + sacurile ei. EXISTĂ doar cât e un
##                      run viu; se șterge când expediția se încheie.
##
## De ce nu unul singur, în ordinea importanței:
##
## 1. DURATE DIFERITE ÎNSEAMNĂ ȘTERGERI DIFERITE. Cu un singur fișier, „șterge
##    expediția" ar însemnat „rescrie fișierul care ține și Fragmentele" — adică
##    singurul fișier de neînlocuit ar fi atins la fiecare final de run.
## 2. FRECVENȚE DIFERITE. Expediția se scrie la fiecare nod; permanentul, rar.
##    Un fișier scris des e un fișier mai des prins la mijloc.
## 3. „E un run în curs?" devine `FileAccess.file_exists()`, nu un câmp dinăuntru
##    care se poate contrazice cu restul.
##
## De ce `user://` și nu `res://`: într-un joc exportat, `res://` e doar de
## citit. Pe Windows, `user://` ajunge în
## `%APPDATA%\Godot\app_userdata\mindkeep\`.
##
## JSON cu taburi, deci citibil cu ochiul. Pentru un joc single-player care e în
## primul rând pentru mine, ăsta e un câștig, nu o scurgere: un save pe care-l
## poți deschide și citi e un save pe care-l poți depana.
##
## ─────────────────────────────────────────────────────────────
## SCRIEREA NU POATE LĂSA UN FIȘIER TĂIAT
##
## Se scrie în `expeditie.json.nou`, complet, se închide, și abia apoi se
## REDENUMEȘTE peste cel adevărat. Redenumirea e un singur pas pentru sistemul
## de fișiere, deci o închidere bruscă te lasă fie cu save-ul vechi întreg, fie
## cu cel nou întreg — niciodată cu jumătate din fiecare.
##
## Plasa în plus, la citire: dacă fișierul adevărat lipsește dar `.nou` e acolo,
## `.nou` se adoptă. Pe Windows, redenumirea peste un fișier existent îl șterge
## întâi, deci există o fereastră de o microsecundă în care niciunul nu e la
## locul lui. Trei linii, și acoperă exact fereastra aia.
##
## ─────────────────────────────────────────────────────────────
## UN SAVE VECHI SE DESCHIDE; UNUL MAI NOU, NU
##
## Fiecare fișier începe cu `versiune`. O versiune mai MICĂ se citește, prin
## `_migreaza()` — azi o funcție care nu face nimic, dar care e locul în care
## migrarea de peste trei luni e o funcție, nu o arheologie. Egală se citește.
##
## Mai MARE nu se citește. Un save din viitor (ai jucat pe o versiune mai nouă
## și ai revenit) nu poate fi citit „strâmb": cheile pe care nu le știu pot
## însemna altceva decât cred. Regula „se deschide chiar și strâmb" e pentru
## save-uri vechi; pentru unul mai nou, singurul răspuns cinstit e să nu-l
## atingi.
##
## ─────────────────────────────────────────────────────────────
## CE SE ÎNTÂMPLĂ CU UN FIȘIER PE CARE NU-L POT CITI
##
## Nu se șterge și nu se suprascrie: se PUNE DEOPARTE, cu un nume nou
## (`permanent.stricat.json`), și faptul se spune pe ecran, în meniu. Un
## progres pierdut în tăcere arată exact ca „n-am jucat niciodată" — iar
## fișierul rămas pe disc e singurul loc din care se mai poate salva ceva.
##
## Iar dacă există deja un `.stricat.json` pus deoparte altădată, cel nou
## primește data în nume. O a doua stricare n-are voie s-o șteargă pe prima.
##
## ARHIVA NU SCRIE PROPOZIȚII, ci fapte: `stricate` ține „ce fișier" → „de ce",
## iar meniul face din ele o frază. Un fișier care nu știe ce e un Fragment
## n-are de ce să știe cum se vorbește cu jucătorul.

## Progresul din Antrenament trăiește în două `static var` din `practice.gd`.
## Corect ar fi un autoload al lui — starea care supraviețuiește scenei aparține
## unui autoload, regula din antetul celorlalte trei. Ziua lui e felia următoare
## din Practice (greșitele care revin, Jurnalul); până atunci, un `preload` și
## două funcții statice. Scris la „Rămas deschis" în jurnalul de progres.
const PRACTICE := preload("res://scenes/practice/practice.gd")

## Versiunea formatului de pe disc. Crește când o cheie își schimbă ÎNȚELESUL,
## nu când se adaugă una nouă: o cheie în plus e citită de un joc vechi ca
## „lipsește", adică prin valoarea implicită, și aia e deja corect.
const VERSIUNE := 1

const NUME_PERMANENT := "permanent.json"
const NUME_EXPEDITIE := "expeditie.json"

## Sufixul fișierului pe jumătate scris. Nu `.tmp`: când îl vezi în dosar, vrei
## să știe pe loc că e un save nou, nu un fișier oarecare.
const SUFIX_TEMPORAR := ".nou"

## DE UNDE SE CITEȘTE ȘI UNDE SE SCRIE. Variabilă, nu constantă, cu un singur
## apelant care o mută: `tools/verificari/verifica_salvarea.gd`. O verificare
## care poate suprascrie save-ul tău adevărat e o verificare pe care n-o rulezi.
var dosar := "user://"

## CE N-A PUTUT FI CITIT LA PORNIRE: „permanent" / „expeditie" → motivul, în
## cuvinte scurte. Gol = totul a mers. Îl citește meniul, o dată, ca să scrie
## rândul de sub butoane.
var stricate := {}


func _ready() -> void:
	# Arhiva e înregistrată ULTIMA în `project.godot`, și nu e o întâmplare:
	# autoload-urile intră în arbore în ordinea din listă, deci `_ready()`-ul
	# lui `Tezaur` (care cheamă `goleste()`) rulează înaintea ăstuia. Invers,
	# golirea ar șterge exact ce s-a citit de pe disc.
	incarca()


# ─────────────────────────────────────────────────────────────
# ÎNCĂRCAREA
# ─────────────────────────────────────────────────────────────

## Citește tot ce există pe disc. Chemată o dată, la pornire.
##
## Fișierele lipsă NU sunt o eroare: așa arată un joc jucat prima dată.
func incarca() -> void:
	stricate.clear()

	var permanent = _citeste(NUME_PERMANENT)
	if permanent is Dictionary:
		# Fiecare bucată trece prin `din_dictionar()`-ul deținătorului ei, deci
		# regulile de citit strâmb (cheie lipsă = implicit, cheie necunoscută =
		# ignorată) stau tot acolo unde stă starea.
		Tezaur.din_dictionar(_sub(permanent, "tezaur"))
		Sac.din_dictionar(_sub(permanent, "sac"), Sac.Durata.PERMANENT)
		PRACTICE.din_dictionar(_sub(permanent, "practice"))

	var expeditie = _citeste(NUME_EXPEDITIE)
	if expeditie is Dictionary:
		Expeditie.din_dictionar(_sub(expeditie, "expeditie"))
		Sac.din_dictionar(_sub(expeditie, "sac"), Sac.Durata.EXPEDITIE)

		# UN FIȘIER DE EXPEDIȚIE ÎNCHEIATĂ N-AR TREBUI SĂ EXISTE: se șterge la
		# `incheie()`. Dacă totuși e acolo (un joc închis în clipa greșită, un
		# fișier rămas de la o versiune mai veche), nu se reia: o expediție
		# încheiată e deja plătită în Tezaur, iar reluarea ei ar fi a doua plată.
		if not Expeditie.activa:
			Expeditie.goleste()
			sterge_expeditia()


## O bucată din fișier, garantat Dictionary. Un save strâmb (cheia lipsește, sau
## e un număr în loc de obiect) întoarce `{}`, iar `din_dictionar()`-urile știu
## deja ce să facă cu gol: pornesc de la valorile implicite.
func _sub(date: Dictionary, cheie: String) -> Dictionary:
	var bucata = date.get(cheie)
	return bucata if bucata is Dictionary else {}


# ─────────────────────────────────────────────────────────────
# SALVAREA
# Cine le cheamă și de ce exact acolo: vezi tabelul din sesiunea SAVE a
# jurnalului. Regula scurtă: se scrie după fiecare lucru TERMINAT, deci cel mai
# rău caz e mereu „pierzi ce n-ai dus la capăt", niciodată „pierzi ce ai dus".
# ─────────────────────────────────────────────────────────────

func salveaza_permanent() -> bool:
	return _scrie(NUME_PERMANENT, {
		"tezaur": Tezaur.spre_dictionar(),
		"sac": Sac.spre_dictionar(Sac.Durata.PERMANENT),
		"practice": PRACTICE.spre_dictionar(),
	})


## O expediție care nu e activă nu are ce salva, și asta nu e o plasă teoretică:
## `lupta.tscn` pornește singură cu F6, fără nicio expediție în spate (vezi
## `_alege_inamicul`), iar la finalul luptei cheamă salvarea ca orice luptă. Fără
## garda de mai jos, o probă dată cu F6 ar lăsa pe disc un run fantomă, pe care
## meniul l-ar oferi la pornire ca „Continuă expediția".
func salveaza_expeditia() -> bool:
	if not Expeditie.activa:
		return true

	return _scrie(NUME_EXPEDITIE, {
		"expeditie": Expeditie.spre_dictionar(),
		"sac": Sac.spre_dictionar(Sac.Durata.EXPEDITIE),
	})


## Amândouă, pentru clipele în care s-au schimbat amândouă (sfârșit de luptă,
## început de expediție). Două scrieri, nu una: fișierele rămân despărțite.
func salveaza_tot() -> bool:
	# `and` ar fi sărit a doua scriere dacă prima picase („short-circuit"), iar
	# aia e exact invers de ce vrei: dacă un fișier n-a putut fi scris, celălalt
	# trebuie încercat oricum.
	var permanent := salveaza_permanent()
	var expeditie := salveaza_expeditia()
	return permanent and expeditie


## Expediția s-a încheiat: fișierul ei dispare. Starea din memorie NU se atinge
## — ecranul de sumar are nevoie de ea ca s-o poată arăta.
func sterge_expeditia() -> bool:
	var cale := cale_catre(NUME_EXPEDITIE)
	if not FileAccess.file_exists(cale):
		return true
	var eroare := DirAccess.remove_absolute(cale)
	if eroare != OK:
		push_error("Arhiva: nu pot sterge %s (eroarea %d)." % [cale, eroare])
		return false
	return true


## E un run în curs pe disc? Întrebarea meniului.
func exista_expeditie() -> bool:
	return FileAccess.file_exists(cale_catre(NUME_EXPEDITIE))


## Calea întreagă a unui fișier de save. Într-un singur loc, ca la cheile
## sacului: două locuri care compun același text ajung să-l compună altfel.
func cale_catre(nume: String) -> String:
	return dosar.path_join(nume)


# ─────────────────────────────────────────────────────────────
# DISCUL
# Singurele patru funcții din tot jocul care deschid un fișier de scris.
# ─────────────────────────────────────────────────────────────

## Scrie un dicționar, în siguranță. Vezi „SCRIEREA NU POATE LĂSA UN FIȘIER
## TĂIAT" în antet.
func _scrie(nume: String, date: Dictionary) -> bool:
	# Antetul fiecărui fișier. Pus aici, nu de apelanți: așa nu poate exista un
	# save fără versiune, oricine l-ar fi cerut.
	date["versiune"] = VERSIUNE
	# Numai pentru ochii mei, când deschid fișierul ca să înțeleg ce s-a
	# întâmplat. Nimic din joc nu-l citește.
	date["scris_la"] = Time.get_datetime_string_from_system(false, true)

	if not DirAccess.dir_exists_absolute(dosar):
		DirAccess.make_dir_recursive_absolute(dosar)

	var cale := cale_catre(nume)
	var temporar := cale + SUFIX_TEMPORAR

	var fisier := FileAccess.open(temporar, FileAccess.WRITE)
	if fisier == null:
		push_error("Arhiva: nu pot deschide %s (eroarea %d)." % [
			temporar, FileAccess.get_open_error()])
		return false
	fisier.store_string(JSON.stringify(date, "\t"))
	# `close()` explicit, deși fișierul s-ar închide singur când variabila iese
	# din funcție: aici ordinea CONTEAZĂ. Redenumirea de mai jos trebuie să vină
	# după ce tot ce-am scris a ajuns efectiv pe disc.
	fisier.close()

	var eroare := DirAccess.rename_absolute(temporar, cale)
	if eroare != OK:
		push_error("Arhiva: nu pot redenumi %s in %s (eroarea %d)." % [
			temporar, cale, eroare])
		return false
	return true


## Citește un dicționar, sau `null` dacă nu se poate.
##
## `null` are DOUĂ înțelesuri, și amândouă duc la același lucru pentru apelant
## („n-ai ce încărca"): fișierul nu există (joc nou), sau nu se poate citi (și
## atunci e pus deoparte și trecut în `stricate`).
func _citeste(nume: String) -> Variant:
	var cale := cale_catre(nume)
	var temporar := cale + SUFIX_TEMPORAR

	# PLASA DE LA REDENUMIRE. Un `.nou` fără fișier adevărat lângă el înseamnă
	# că jocul s-a închis în fereastra de o microsecundă dintre ștergerea
	# vechiului și redenumirea noului. Fișierul `.nou` e întreg — a fost scris
	# și închis înainte de redenumire — deci se adoptă.
	if not FileAccess.file_exists(cale) and FileAccess.file_exists(temporar):
		push_warning("Arhiva: %s lipsea, dar %s era intreg. Il adopt." % [
			nume, nume + SUFIX_TEMPORAR])
		DirAccess.rename_absolute(temporar, cale)

	if not FileAccess.file_exists(cale):
		return null   # joc nou. Nu e o eroare.

	var fisier := FileAccess.open(cale, FileAccess.READ)
	if fisier == null:
		# NU se pune deoparte: un fișier care nu se poate nici deschide poate fi
		# ținut de altcineva (un antivirus, o copie de rezervă în curs), iar o
		# redenumire ar pica oricum. Se spune, și se pornește curat.
		stricate[nume.get_basename()] = "nu se poate deschide (eroarea %d)" % \
			FileAccess.get_open_error()
		push_error("Arhiva: nu pot deschide %s (eroarea %d)." % [
			cale, FileAccess.get_open_error()])
		return null
	var text := fisier.get_as_text()
	fisier.close()

	var cititor := JSON.new()
	if cititor.parse(text) != OK:
		return _strica(nume, "JSON invalid, linia %d: %s" % [
			cititor.get_error_line(), cititor.get_error_message()])
	var date = cititor.data
	if not (date is Dictionary):
		# Un JSON valid care nu e un obiect: o listă, un număr, `null`. Valid
		# pentru parser, fără înțeles pentru noi.
		return _strica(nume, "nu e un obiect JSON, ci %s" % type_string(typeof(date)))

	# Un fișier fără `versiune` e „versiunea 0", adică mai veche decât orice —
	# deci se citește, prin migrare. Nicio versiune n-a existat vreodată fără
	# câmpul ăsta, dar asta e exact felul de presupunere care nu merită făcută.
	var versiune := int((date as Dictionary).get("versiune", 0))
	if versiune > VERSIUNE:
		return _strica(nume,
			"e din versiunea %d, iar jocul stie pana la %d" % [versiune, VERSIUNE],
			"v%d" % versiune)

	return _migreaza(date as Dictionary, versiune)


## Un fișier ilizibil: pus deoparte, motivul reținut pentru meniu, `null`
## întors ca să fie o singură linie la fiecare apelant.
func _strica(nume: String, motiv: String, eticheta := "stricat") -> Variant:
	var pus := _pune_deoparte(nume, eticheta)
	stricate[nume.get_basename()] = motiv
	push_error("Arhiva: %s nu se poate citi (%s). Pus deoparte ca %s." % [
		nume, motiv, pus])
	return null


## Mută un fișier într-un nume liber și-l întoarce. NU suprascrie niciodată:
## o a doua stricare n-are voie s-o șteargă pe prima, fiindcă fișierul pus
## deoparte e singurul loc din care se mai poate salva ceva.
##
## Numele se încearcă în ordinea asta:
##   permanent.stricat.json
##   permanent.stricat.2026-10-12T14-33-02.json      ← data, dacă primul e luat
##   permanent.stricat.2026-10-12T14-33-02.2.json    ← și un număr, dacă și ea
##
## A treia pare de prisos, și e ieftină: două stricări în aceeași secundă ar
## nimeri același nume cu dată, iar atunci redenumirea ar pica și fișierul ar
## rămâne la locul lui — adică exact în calea primei scrieri care urmează.
func _pune_deoparte(nume: String, eticheta: String) -> String:
	var baza := nume.get_basename()
	var candidati: Array[String] = [
		"%s.%s.json" % [baza, eticheta],
		"%s.%s.%s.json" % [baza, eticheta, _acum_pentru_nume()],
	]
	for i in range(2, 20):
		candidati.append("%s.%s.%s.%d.json" % [
			baza, eticheta, _acum_pentru_nume(), i])

	for tinta in candidati:
		if FileAccess.file_exists(cale_catre(tinta)):
			continue
		if DirAccess.rename_absolute(cale_catre(nume), cale_catre(tinta)) == OK:
			return tinta
		break

	# Niciun nume liber, sau redenumirea a picat. Nu ne mai putem apăra de
	# suprascriere, deci măcar se spune — și fișierul rămâne cum e până la
	# prima scriere.
	push_error("Arhiva: nu pot pune deoparte %s. Fisierul ramane pe loc." % nume)
	return nume


## Data, în formă care încape într-un nume de fișier. `:` e interzis în
## numele de fișiere pe Windows, iar `T`-ul îl las: ține data și ora lipite,
## deci numele se sortează singur alfabetic.
func _acum_pentru_nume() -> String:
	return Time.get_datetime_string_from_system(false, false).replace(":", "-")


## LOCUL MIGRĂRILOR. Azi nu face nimic, fiindcă nu există încă nicio versiune
## veche — și exact de-aia merită să existe de pe acum: când prima cheie își va
## schimba înțelesul, ce se scrie aici e un `if versiune < 2:`, nu o arheologie
## prin tot jocul.
##
## Un save fără cheia nouă nu are nevoie de migrare: `din_dictionar()`-urile
## citesc o cheie lipsă prin valoarea implicită. Migrarea e doar pentru cheile
## care EXISTĂ și înseamnă altceva.
func _migreaza(date: Dictionary, _de_la: int) -> Dictionary:
	return date

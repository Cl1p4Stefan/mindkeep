class_name Mese
extends RefCounted
## CATALOGUL MESELOR DIN TAVERNĂ — toate jocurile de aici, într-un tabel.
##
## Fratele lui `Discipline.CATALOG`, și scris dinadins la fel: un joc nou e un
## RÂND plus o scenă, nu o ramură în `taverna.gd`. Promisiunea a fost probată de
## cinci ori la disciplinele 4-8; aici începe de la zero, deci tabelul există de
## la primul joc, nu de la al treilea — singurul moment în care se poate scrie
## fără migrare (vezi `subcategorie` la Trivia: o listă scrisă la început e un
## rând, una adăugată după ce s-a scris conținut e o migrare).
##
## ─────────────────────────────────────────────────────────────
## DE CE NU E UN AUTOLOAD, DEȘI `Discipline` E
##
## `Discipline` e autoload fiindcă de catalogul disciplinelor au nevoie DOUĂ
## scene care nu se cunosc: lupta (construiește Obeliscuri) și harta (desenează
## loadout-ul). Un tabel de care are nevoie și una, și alta, nu mai poate sta
## în niciuna din ele.
##
## De mese are nevoie o singură scenă: Taverna. Deci `class_name`, nu autoload:
## un global în plus e un global pe care orice fișier îl poate atinge, iar
## lista autoload-urilor din `project.godot` e locul în care se adună, pe
## nesimțite, tot ce „era mai ușor așa". Ziua în care mesele vor fi cerute și
## din altă parte (Cetatea, când Taverna devine o clădire), mutarea e un rând
## în `project.godot`.
##
## ─────────────────────────────────────────────────────────────
## CÂMPURILE
##
##   „cheie" — numele ei pe disc și în sacuri. Un TEXT, nu poziția în listă,
##             pentru exact motivul scris la `Discipline`: poziția se mută când
##             adaugi un joc la mijloc, iar un sac salvat ar crede atunci că a
##             văzut biletele altui joc.
##   „nume"  — ce se vede pe masă. Se poate schimba fără să strice nimic.
##   „rol"   — o frază despre ce e jocul ȘI ce antrenează. O alegere pe care o
##             faci pe nume, fără să știi ce e înăuntru, nu e o alegere —
##             aceeași regulă ca la ecranul de loadout. SCRISĂ FĂRĂ RUPTURI DE
##             RÂND: eticheta de pe masă încadrează singură, iar o ruptură pusă
##             de mână se bate cu ea și lasă rânduri schiloade. Prima scriere
##             le avea, și se vedea.
##   „scena" — calea scenei, sau "" dacă jocul nu e scris încă.
##
## ─────────────────────────────────────────────────────────────
## DE CE STAU ÎN TABEL ȘI MESELE CARE NU EXISTĂ
##
## `scena: ""` e o masă care apare pe ecran, STINSĂ, cu „în lucru" pe ea. E
## chiar decizia luată la rafturile din Practice: „un raft ascuns e un raft
## despre care nu afli niciodată nimic — nu știi dacă nu există, dacă l-ai
## pierdut sau dacă n-am scris încă nimic în el". O masă stinsă e o hartă a
## jocului care urmează, iar pentru mine (singurul jucător, deocamdată) e și
## lista de lucru, la vedere, în joc.
##
## Cele stinse nu sunt puse ca să umple ecranul, și amândouă s-au aprins în
## aceeași zi, 4 noiembrie 2026: Sudoku dimineața, Decretul Zilei după el. Deci
## coloana nu mai are, azi, niciun rând gol — iar asta nu e o invitație să se
## scrie unul „ca să fie": o masă intră aici când se știe CE joc e, nu când se
## știe că ar fi frumos să existe. Și ordinea n-a fost o întâmplare: decretul nu
## se putea aprinde înaintea lui Sudoku, fiindcă n-avea din ce alege — cu o
## singură masă scrisă, „altul în fiecare zi" ar fi fost mereu același.
##
## Decretul e și masa care arată că tabelul ăsta se citește din cod, nu doar din
## ochi: rotația lui e `zi % câte mese sunt de rând`, cu el însuși sărit. Deci o
## masă nouă intră în decret fără să se atingă nimic, iar o masă stinsă nu intră
## — amândouă din rândul `scena`.
const CATALOG: Array[Dictionary] = [
	{
		"cheie": "cuvantul_ascuns",
		"nume": "CUVÂNTUL ASCUNS",
		"rol": "Șase încercări pentru un cuvânt de cinci litere. Fiecare încercare îți spune ce ai nimerit.",
		"scena": "res://scenes/taverna/cuvantul/cuvantul.tscn",
	},
	{
		"cheie": "sudoku",
		"nume": "SUDOKU",
		"rol": "Nouă pe nouă, fără nicio repetiție. Răbdare și constrângeri urmărite deodată.",
		"scena": "res://scenes/taverna/sudoku/sudoku.tscn",
	},
	{
		"cheie": "fiolele",
		"nume": "FIOLELE",
		"rol": "Poțiuni amestecate, de turnat până fiecare fiolă are o singură culoare. Planificare cu câțiva pași înainte.",
		"scena": "res://scenes/taverna/fiolele/fiolele.tscn",
	},
	{
		"cheie": "decretul_zilei",
		"nume": "DECRETUL ZILEI",
		"rol": "Un singur joc, altul în fiecare zi. Același pentru toată ziua, oricâte ori îl deschizi.",
		"scena": "res://scenes/taverna/decretul/decretul.tscn",
	},
]


## Masa cu cheia asta, sau un dicționar gol.
##
## `static`: catalogul e o constantă, deci n-are rost să existe un `Mese` ca
## obiect. Se cheamă `Mese.masa("sudoku")`, ca `Sac.extrage(...)`.
static func masa(cheie: String) -> Dictionary:
	for m in CATALOG:
		if m["cheie"] == cheie:
			return m
	return {}


## Câte mese se pot juca ACUM. Numărul ăsta nu e scris nicăieri de mână: el e
## ce scrie pe antetul Tavernei.
static func cate_sunt_gata() -> int:
	var cate := 0
	for m in CATALOG:
		if String(m["scena"]) != "":
			cate += 1
	return cate

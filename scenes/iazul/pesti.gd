class_name Pesti
extends RefCounted
## CATALOGUL PEȘTILOR DE LA IAZ — speciile, unde și când apar, cum se zbat.
##
## Fratele lui `Mese.CATALOG` și `Discipline.CATALOG`, scris la fel: o specie
## nouă e un RÂND aici, nu o ramură în `iazul.gd`. Jurnalul, aruncarea și lupta
## cu firul citesc toate din tabelul ăsta și nu știu niciun nume de pește.
##
## ─────────────────────────────────────────────────────────────
## SPECII REALE, DAR NICIO AFIRMAȚIE DESPRE ELE
##
## Peștii sunt specii românești de apă dulce, pe numele lor. Ce NU scrie
## nicăieri e un fapt despre ei („somnul trăiește până la…", „știuca e
## răpitoare…"): o notă scrisă din memoria modelului de limbaj ar fi exact ce
## refuză decizia „modelul de limbaj formulează, nu informează". Masele de mai
## jos sunt valori de JOC, alese ca recordurile să aibă unde să crească; locul
## și ora în care apare fiecare sunt REGULI de joc, scrise în jurnal ca indiciu
## („Departe, noaptea"), nu ca biologie. Dacă vreodată vrei note adevărate,
## drumul e cel al fabricii de întrebări: un tabel cu sursă, nu memoria mea.
##
## ─────────────────────────────────────────────────────────────
## CÂMPURILE
##
##   „cheie"     — numele pe disc (jurnalul). Text, nu poziție: vezi `Mese`.
##   „nume"      — ce se vede.
##   „zone"      — unde se poate prinde: 0 lângă mal, 1 în larg, 2 departe.
##                 Distanța aruncării alege zona.
##   „momente"   — când: "zori", "zi", "amurg", "noapte". Gol = oricând.
##   „vreme"     — pe ce vreme: "senin", "ceata", "ploaie". Gol = pe orice.
##   „frecventa" — greutatea la tragerea la sorți, printre cele care se
##                 potrivesc ACUM. 10 = obișnuit, sub 1 = legendă.
##   „masa"      — [cel mai mic, cel mai mare], în kg. Se trage strâmb, spre
##                 cel mic (vezi `trage_masa`), ca un record mare să fie rar.
##   „forta"     — 1..5. Cât de tare smucește la tragere (vezi `Firul`).
##   „corp"      — cum se desenează: lungime/înălțime, culoare, semne.
##
## ─────────────────────────────────────────────────────────────
## CÂRLIGUL JOCULUI E AICI, NU ÎN LUPTA CU FIRUL
##
## Ce te ține la iaz e întrebarea „ce e silueta aia neagră din jurnal?".
## Fiecare condiție (noaptea, ceața, ploaia, departele) are cel puțin o specie
## care apare NUMAI acolo, deci o vreme nouă e o promisiune, nu decor. Asta e
## regula pe care o bate `verifica_iazul`, nu doar o intenție.

const ZONE := ["lângă mal", "în larg", "departe"]
const MOMENTE := ["zori", "zi", "amurg", "noapte"]
const VREMI := ["senin", "ceata", "ploaie"]

## Cum se scriu condițiile în jurnal. Separate de cheile de mai sus fiindcă
## cheile sunt fără diacritice (stau pe disc și în cod), iar textul e pentru om.
const NUME_MOMENT := {"zori": "în zori", "zi": "ziua", "amurg": "la amurg", "noapte": "noaptea"}
const NUME_VREME := {"senin": "pe senin", "ceata": "pe ceață", "ploaie": "pe ploaie"}
const TITLU_MOMENT := {"zori": "Zori", "zi": "Zi", "amurg": "Amurg", "noapte": "Noapte"}
const TITLU_VREME := {"senin": "Senin", "ceata": "Ceață", "ploaie": "Ploaie"}

const CATALOG: Array[Dictionary] = [
	{"cheie": "babusca", "nume": "Babușcă", "zone": [0], "momente": [], "vreme": [],
		"frecventa": 10.0, "masa": [0.05, 0.4], "forta": 1,
		"corp": {"inaltime": 0.34, "culoare": Color(0.72, 0.74, 0.70), "aripioare": Color(0.80, 0.35, 0.25)}},
	{"cheie": "caras", "nume": "Caras", "zone": [0, 1], "momente": [], "vreme": [],
		"frecventa": 10.0, "masa": [0.1, 1.4], "forta": 1,
		"corp": {"inaltime": 0.42, "culoare": Color(0.70, 0.66, 0.48)}},
	{"cheie": "rosioara", "nume": "Roșioară", "zone": [0, 1], "momente": [], "vreme": [],
		"frecventa": 8.0, "masa": [0.05, 0.6], "forta": 1,
		"corp": {"inaltime": 0.36, "culoare": Color(0.74, 0.70, 0.56), "aripioare": Color(0.86, 0.30, 0.22)}},
	{"cheie": "biban", "nume": "Biban", "zone": [0, 1], "momente": ["zori", "zi", "amurg"], "vreme": [],
		"frecventa": 7.0, "masa": [0.1, 1.8], "forta": 2,
		"corp": {"inaltime": 0.36, "culoare": Color(0.55, 0.60, 0.36), "dungi": 6, "aripioare": Color(0.84, 0.42, 0.22)}},
	{"cheie": "platica", "nume": "Plătică", "zone": [1, 2], "momente": [], "vreme": [],
		"frecventa": 6.0, "masa": [0.3, 3.5], "forta": 2,
		"corp": {"inaltime": 0.48, "culoare": Color(0.60, 0.56, 0.44)}},
	{"cheie": "clean", "nume": "Clean", "zone": [1], "momente": [], "vreme": [],
		"frecventa": 5.0, "masa": [0.3, 3.2], "forta": 2,
		"corp": {"inaltime": 0.27, "culoare": Color(0.56, 0.58, 0.54)}},
	{"cheie": "lin", "nume": "Lin", "zone": [0], "momente": ["amurg", "noapte"], "vreme": [],
		"frecventa": 4.0, "masa": [0.3, 2.8], "forta": 2,
		"corp": {"inaltime": 0.34, "culoare": Color(0.42, 0.50, 0.28)}},
	{"cheie": "crap", "nume": "Crap", "zone": [1, 2], "momente": [], "vreme": [],
		"frecventa": 4.0, "masa": [1.0, 18.0], "forta": 4,
		"corp": {"inaltime": 0.38, "culoare": Color(0.64, 0.52, 0.30), "mustati": true}},
	{"cheie": "stiuca", "nume": "Știucă", "zone": [0, 1], "momente": [], "vreme": [],
		"frecventa": 3.0, "masa": [1.0, 14.0], "forta": 4,
		"corp": {"inaltime": 0.20, "culoare": Color(0.46, 0.54, 0.34), "pete": true, "bot": 0.18}},
	{"cheie": "mreana", "nume": "Mreană", "zone": [1, 2], "momente": [], "vreme": ["ploaie"],
		"frecventa": 4.0, "masa": [0.5, 5.0], "forta": 3,
		"corp": {"inaltime": 0.24, "culoare": Color(0.62, 0.54, 0.40), "mustati": true}},
	{"cheie": "tipar", "nume": "Țipar", "zone": [0], "momente": ["amurg", "noapte"], "vreme": ["ploaie", "ceata"],
		"frecventa": 3.0, "masa": [0.1, 0.6], "forta": 2,
		"corp": {"inaltime": 0.10, "culoare": Color(0.44, 0.38, 0.26), "dungi": 0, "mustati": true}},
	{"cheie": "salau", "nume": "Șalău", "zone": [2], "momente": ["amurg", "noapte"], "vreme": [],
		"frecventa": 3.0, "masa": [1.0, 10.0], "forta": 3,
		"corp": {"inaltime": 0.24, "culoare": Color(0.58, 0.60, 0.52), "dungi": 5}},
	{"cheie": "avat", "nume": "Avat", "zone": [2], "momente": ["zori", "zi"], "vreme": [],
		"frecventa": 2.5, "masa": [1.0, 7.0], "forta": 3,
		"corp": {"inaltime": 0.30, "culoare": Color(0.66, 0.68, 0.66)}},
	{"cheie": "cega", "nume": "Cegă", "zone": [2], "momente": [], "vreme": ["ceata"],
		"frecventa": 2.0, "masa": [1.0, 6.0], "forta": 4,
		"corp": {"inaltime": 0.18, "culoare": Color(0.48, 0.44, 0.36), "bot": 0.22, "solzi_os": true}},
	{"cheie": "somn", "nume": "Somn", "zone": [2], "momente": ["noapte"], "vreme": [],
		"frecventa": 1.2, "masa": [5.0, 60.0], "forta": 5,
		"corp": {"inaltime": 0.22, "culoare": Color(0.30, 0.30, 0.26), "mustati": true, "lat": true}},
	{"cheie": "lostrita", "nume": "Lostriță", "zone": [2], "momente": ["zori", "noapte"], "vreme": ["ceata"],
		"frecventa": 0.8, "masa": [3.0, 22.0], "forta": 5,
		"corp": {"inaltime": 0.22, "culoare": Color(0.72, 0.50, 0.42), "pete": true}},
]


static func specie(cheie: String) -> Dictionary:
	for s in CATALOG:
		if s["cheie"] == cheie:
			return s
	return {}


## Se potrivește specia cu locul și ora de acum?
static func se_potriveste(s: Dictionary, zona: int, moment: String, vreme: String) -> bool:
	if not (s["zone"] as Array).has(zona):
		return false
	var momente: Array = s["momente"]
	if not momente.is_empty() and not momente.has(moment):
		return false
	var vremi: Array = s["vreme"]
	if not vremi.is_empty() and not vremi.has(vreme):
		return false
	return true


## Toate speciile care pot mușca acum.
static func potrivite(zona: int, moment: String, vreme: String) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for s in CATALOG:
		if se_potriveste(s, zona, moment, vreme):
			lista.append(s)
	return lista


## Cine mușcă, tras la sorți după „frecventa". Niciodată gol: fiecare zonă are
## măcar o specie fără condiții, iar `verifica_iazul` o cere.
static func trage_specia(zona: int, moment: String, vreme: String, rng: RandomNumberGenerator) -> Dictionary:
	var lista := potrivite(zona, moment, vreme)
	var total := 0.0
	for s in lista:
		total += float(s["frecventa"])
	var r := rng.randf() * total
	for s in lista:
		r -= float(s["frecventa"])
		if r <= 0.0:
			return s
	return lista.back() if not lista.is_empty() else {}


## Masa, strâmbă spre cel mic: la puterea 2,4, jumătate din pești ies în
## primul 25% al intervalului, iar ultimul 10% vine o dată la vreo 30.
## Asta face un record să fie o ÎNTÂMPLARE, nu o așteptare.
static func trage_masa(s: Dictionary, rng: RandomNumberGenerator) -> float:
	var m: Array = s["masa"]
	return float(m[0]) + (float(m[1]) - float(m[0])) * pow(rng.randf(), 2.4)


## Cât de mare e peștele ăsta PENTRU specia lui, 0..1. Lupta cu firul îl
## folosește: un crap de 15 kg trage mai mult decât unul de 2.
static func masa_relativa(s: Dictionary, masa: float) -> float:
	var m: Array = s["masa"]
	return clampf((masa - float(m[0])) / maxf(0.001, float(m[1]) - float(m[0])), 0.0, 1.0)


## „3,25 kg" — cu virgulă, ca în română, și cu mai puține zecimale la pești mari.
static func scrie_masa(masa: float) -> String:
	var text := ("%.2f" % masa) if masa < 10.0 else ("%.1f" % masa)
	return text.replace(".", ",") + " kg"


## Indiciul din jurnal, scris din condițiile speciei: „Departe, noaptea, pe ceață".
## Compus, nu scris de mână, ca să nu poată rămâne în urma tabelului.
static func indiciu(s: Dictionary) -> String:
	var parti: Array[String] = []
	var zone: Array[String] = []
	for z in s["zone"]:
		zone.append(ZONE[int(z)])
	parti.append(_majuscula(" sau ".join(zone)))
	var momente: Array[String] = []
	for m in s["momente"]:
		momente.append(NUME_MOMENT[m])
	if not momente.is_empty():
		parti.append(" sau ".join(momente))
	var vremi: Array[String] = []
	for v in s["vreme"]:
		vremi.append(NUME_VREME[v])
	if not vremi.is_empty():
		parti.append(" sau ".join(vremi))
	return ", ".join(parti)


static func _majuscula(t: String) -> String:
	return t.substr(0, 1).to_upper() + t.substr(1)


# ─────────────────────────────────────────────────────────────
# DESENUL
# Un pește desenat din câțiva parametri, nu o imagine: 16 specii ar fi fost 16
# PNG-uri de făcut înainte ca jocul să fie jucabil („prototip întâi, artă
# după"). Aceeași funcție desenează peștele din apă, cel de pe cartea de
# captură și silueta neagră din jurnal — deci silueta e EXACT forma pe care o
# vei prinde.
# ─────────────────────────────────────────────────────────────

## Desenează specia `s` pe `ci`, cu centrul în `centru`, lungă de `lungime` px,
## cu capul spre dreapta. `silueta` = o singură culoare plină (jurnalul).
static func deseneaza(ci: CanvasItem, s: Dictionary, centru: Vector2, lungime: float,
		silueta := false, culoare_silueta := Color(0.08, 0.07, 0.06, 0.9)) -> void:
	var corp: Dictionary = s["corp"]
	var h := lungime * float(corp.get("inaltime", 0.3))
	var culoare: Color = culoare_silueta if silueta else corp["culoare"]
	var aripa: Color = culoare_silueta if silueta else corp.get("aripioare", culoare.darkened(0.25))
	var L := lungime
	var coada_l := L * 0.22
	var trup_l := L - coada_l
	var bot := float(corp.get("bot", 0.0))

	# Trupul: o formă de picătură, mai groasă spre față. Puncte pe un contur
	# parametric, nu o elipsă, ca să aibă bot și pedunculul cozii subțire.
	var stanga := centru.x - L / 2.0 + coada_l
	var puncte := PackedVector2Array()
	var pasi := 28
	for i in range(pasi + 1):
		var t := float(i) / pasi            # 0 = coadă, 1 = bot
		var x := stanga + t * trup_l
		var grosime := pow(sin(PI * clampf(t * (1.0 - bot * 0.5) + 0.06, 0.0, 1.0)), 0.75)
		grosime = maxf(grosime, 0.16 * (1.0 - t))  # pedunculul cozii
		puncte.append(Vector2(x, centru.y - grosime * h * 0.5))
	for i in range(pasi, -1, -1):
		var t := float(i) / pasi
		var x := stanga + t * trup_l
		var grosime := pow(sin(PI * clampf(t * (1.0 - bot * 0.5) + 0.06, 0.0, 1.0)), 0.75)
		grosime = maxf(grosime, 0.16 * (1.0 - t))
		var jos := 0.5 if not corp.get("lat", false) else 0.42
		puncte.append(Vector2(x, centru.y + grosime * h * jos))

	# Coada: două lobi.
	var baza := Vector2(stanga + 2.0, centru.y)
	var coada := PackedVector2Array([
		baza + Vector2(0, -h * 0.10),
		baza + Vector2(-coada_l, -h * 0.55),
		baza + Vector2(-coada_l * 0.62, 0),
		baza + Vector2(-coada_l, h * 0.55),
		baza + Vector2(0, h * 0.10),
	])
	ci.draw_colored_polygon(coada, aripa)

	# Aripioara de pe spate.
	var spate_x := stanga + trup_l * 0.42
	var spate_y := centru.y - h * 0.46
	var dorsala := PackedVector2Array([
		Vector2(spate_x - trup_l * 0.14, spate_y + h * 0.06),
		Vector2(spate_x - trup_l * 0.02, spate_y - h * 0.28),
		Vector2(spate_x + trup_l * 0.14, spate_y + h * 0.04),
	])
	ci.draw_colored_polygon(dorsala, aripa)

	ci.draw_colored_polygon(puncte, culoare)
	if silueta:
		return

	# Burta mai deschisă: a doua formă, mai mică, pe jumătatea de jos.
	var burta := PackedVector2Array()
	for i in range(4, pasi - 1):
		var t := float(i) / pasi
		var grosime := pow(sin(PI * clampf(t * (1.0 - bot * 0.5) + 0.06, 0.0, 1.0)), 0.75)
		burta.append(Vector2(stanga + t * trup_l, centru.y + grosime * h * 0.12))
	for i in range(pasi - 2, 3, -1):
		var t := float(i) / pasi
		var grosime := pow(sin(PI * clampf(t * (1.0 - bot * 0.5) + 0.06, 0.0, 1.0)), 0.75)
		burta.append(Vector2(stanga + t * trup_l, centru.y + grosime * h * 0.40))
	if burta.size() >= 3:
		ci.draw_colored_polygon(burta, culoare.lightened(0.28))

	# Dungi verticale (biban, șalău).
	var dungi := int(corp.get("dungi", 0))
	for i in range(dungi):
		var x := stanga + trup_l * (0.25 + 0.55 * float(i) / maxf(1.0, dungi - 1))
		ci.draw_line(Vector2(x, centru.y - h * 0.36), Vector2(x - 2, centru.y + h * 0.05),
			culoare.darkened(0.35), maxf(1.5, L * 0.02))

	# Pete (știucă, lostriță).
	if corp.get("pete", false):
		for i in range(9):
			var px := stanga + trup_l * (0.18 + 0.07 * i)
			var py := centru.y - h * (0.12 if i % 2 == 0 else -0.06)
			ci.draw_circle(Vector2(px, py), maxf(1.2, L * 0.012), culoare.lightened(0.35) if s["cheie"] == "stiuca" else culoare.darkened(0.35))

	# Plăcile de os ale cegii: un rând de romburi pe spate.
	if corp.get("solzi_os", false):
		for i in range(6):
			var px := stanga + trup_l * (0.22 + 0.11 * i)
			ci.draw_circle(Vector2(px, centru.y - h * 0.30), maxf(1.2, L * 0.014), culoare.lightened(0.4))

	# Ochiul și mustățile.
	var ochi := Vector2(stanga + trup_l * 0.86, centru.y - h * 0.10)
	ci.draw_circle(ochi, maxf(1.5, L * 0.03), Color(0.95, 0.92, 0.80))
	ci.draw_circle(ochi, maxf(0.8, L * 0.016), Color(0.08, 0.07, 0.06))
	if corp.get("mustati", false):
		var gura := Vector2(stanga + trup_l * 0.99, centru.y + h * 0.05)
		var lung := L * (0.16 if corp.get("lat", false) else 0.08)
		ci.draw_line(gura, gura + Vector2(lung * 0.5, lung * 0.9), culoare.darkened(0.3), maxf(1.0, L * 0.01))
		ci.draw_line(gura, gura + Vector2(lung, lung * 0.4), culoare.darkened(0.3), maxf(1.0, L * 0.01))

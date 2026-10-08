#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DĂ ID-URI ÎNTREBĂRILOR DE CULTURĂ GENERALĂ.

    python tools/da_iduri.py            arată ce ar schimba, fără să scrie
    python tools/da_iduri.py --scrie    scrie fișierul

Fiecare întrebare din `data/intrebari_trivia.json` primește un `id` stabil
(`mana:0001`, `mana:0002`, …), în ordinea din fișier. Cele 18 întrebări din
pilotul de note (`docs/ghid-note.md`, secțiunea 5) primesc și câmpul `fapt`.

Rulat a doua oară, nu schimbă nimic: un obiect care are deja `id` e lăsat în
pace. Asta îl face sigur de chemat oricând — inclusiv după ce adaugi întrebări
noi la mijlocul fișierului, când numerotează doar noile.

─────────────────────────────────────────────────────────────
DE CE SCRIPTUL UMBLĂ PE TEXT, ȘI NU PE JSON

Varianta evidentă ar fi `json.load()`, adaugi cheia, `json.dump()`. Nu face
asta. Ca să iasă fișierul care e acum pe disc, `json.dump` ar trebui convins să
scoată exact taburi în loc de spații, `variante` pe un singur rând, ghilimelele
românești („”) neescapate și cheile în ordinea de acum. Orice nepotrivire
rescrie toate cele 965 de linii, iar în Git ai un diff în care cele 135 de
câmpuri noi nu se mai văd printre 800 de linii mutate degeaba.

Aici se inserează linii într-un fișier text. Diff-ul e exact ce s-a adăugat.

Prețul e că scriptul trebuie să știe forma fișierului, iar dacă forma se
schimbă, el nu mai are de ce să se agațe. De aceea e STRICT: orice linie pe
care nu o recunoaște oprește scriptul cu eroare. Un script care „sare peste ce
nu înțelege” ar da o dată, în tăcere, 134 de id-uri din 135 — iar întrebarea
fără id ar dispărea din joc, fiindcă încărcătorul o sare (vezi `trivia.gd`).
Mai bine se oprește și-ți spune linia.

─────────────────────────────────────────────────────────────
REGULA CARE ȚINE NUMEROTAREA CINSTITĂ: UN ID NU SE REFOLOSEȘTE NICIODATĂ

Numărul următor se află ca „cel mai mare id din fișier, plus unu”. Asta e
corect DOAR cât timp nimic nu se șterge din fișier. Dacă ștergi ultima
întrebare, `mana:0135` dispare, iar următoarea adăugată primește chiar
`mana:0135` — un id refolosit. De acolo încolo, save-ul unui jucător ar crede
că a văzut deja o întrebare pe care n-a văzut-o niciodată, iar istoricul din
Practice („învățat”) i-ar trece meritul unei întrebări cu totul alteia. Nimic
nu prinde asta: fișierul e valid, id-urile sunt unice, jocul pornește.

DECI: întrebările nu se șterg din fișier. Una scoasă din joc se marchează
retrasă (`"retras": true`) și rămâne pe loc, cu id-ul ei. Încărcătorul va
învăța să le sară când va fi nevoie — azi nu e, fiindcă nu e nimic retras.

Regula e scrisă și în `docs/progres.md`, ca să existe și în afara acestui
fișier.
"""

import io
import json
import os
import sys

# Consola Windows nu e pe UTF-8 din oficiu, iar tot ce tipărim aici are
# diacritice. Fără linia asta, scriptul crapă la primul `print`.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

RADACINA = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CALE_INTREBARI = os.path.join(RADACINA, "data", "intrebari_trivia.json")
CALE_FAPTE = os.path.join(RADACINA, "data", "fapte_trivia.json")

# `mana:` = scris de mână. Cele generate din Wikidata vor avea prefixul lor
# (`wd:`), deci prefixul spune din ce fabrică vine întrebarea — util când
# cauți o greșeală într-un fișier de câteva mii de intrări.
PREFIX = "mana"
CIFRE = 4               # mana:0001. Ajunge până la 9999; peste, doar crește.

# Câte întrebări se așteaptă la final. Nu e o limită, e o plasă: dacă
# verificarea de la final găsește alt număr, ceva a mers prost la scriere și
# vrei să afli acum, nu în joc.
#
# 135 la început; 165 cu lotul de 30 de ciorne de istorie (6 octombrie 2026);
# 213 cu lotul de deschidere pentru Divertisment și Sport (7 octombrie);
# 465 când cele două domenii au ajuns la 50 pe nivel (7 octombrie).
# 477 la trecerea pe opt domenii, 691 când gastronomia și istoria au ajuns
# și ele la 50 pe nivel (8 octombrie).
# Cifra se ridică DE MÂNĂ, odată cu lotul — și e bine așa: dacă s-ar citi din
# fișier, n-ar mai prinde nimic.
CATE_INTREBARI = 1156


# ─────────────────────────────────────────────────────────────
# PUNTEA CĂTRE FAPTE — o singură dată, pentru pilot
#
# Legăturile sunt după TEXTUL întrebării, nu după id. Un tabel de forma
# „mana:0038 → aur” nu se poate citi cu ochiul: o cifră greșită ar lega
# întrebarea de alt fapt, iar nicio validare n-ar prinde-o (id-ul există,
# faptul există, legătura e doar falsă). Textul se verifică dintr-o privire.
#
# Scriptul cere ca fiecare text de mai jos să apară EXACT O DATĂ în fișier și
# tipărește la final toate legăturile, ca să le poți reciti.
#
# Punte de o singură dată: întrebările care vin din fabrica de întrebări vor
# primi `fapt` la naștere, nu de aici.
# ─────────────────────────────────────────────────────────────
FAPTE_PILOT = {
	"În ce an a căzut Zidul Berlinului?": "zidul_berlinului",
	"Ce domnitor a câștigat lupta de la Vaslui, împotriva otomanilor, în 1475?": "stefan_cel_mare",
	"Ce împărat roman a mutat capitala imperiului la Bizanț?": "constantinopol",
	"În ce an a căzut Constantinopolul sub stăpânire otomană?": "constantinopol",
	"Ce râu trece prin București?": "dambovita",
	"Care este capitala Australiei?": "canberra",
	"Care este singurul fluviu care traversează Ecuatorul de două ori?": "congo",
	"Câte picioare are un păianjen?": "paianjen",
	"Ce organit produce energia în celulă?": "mitocondria",
	"Care este simbolul chimic al aurului?": "aur",
	"Ce element chimic are numărul atomic 79?": "aur",
	"Ce curent artistic și-a luat numele de la tabloul „Impresie, răsărit de soare”?": "impresionism",
	"Cine a pictat tavanul Capelei Sixtine?": "michelangelo",
	"Din ce material este sculptată statuia „David” a lui Michelangelo?": "michelangelo",
	"Ce erou grec era invulnerabil peste tot, în afară de călcâi?": "ahile",
	"Ce a dat Odin în schimbul unei sorbituri din fântâna înțelepciunii?": "odin",
	"Câte versuri are un sonet?": "sonet",
	"Cine a scris „Micul Prinț”?": "micul_print",
}


class Eroare(Exception):
	"""Ceva ce scriptul nu recunoaște. Oprește tot, nu se sare peste."""


# ─────────────────────────────────────────────────────────────
# CITIREA FORMEI
# ─────────────────────────────────────────────────────────────

class Obiect:
	"""O întrebare, ca felie de linii. `campuri` e nume → indice de linie."""

	def __init__(self, inceput, sfarsit, campuri):
		self.inceput = inceput      # linia cu `\t{`
		self.sfarsit = sfarsit      # linia cu `\t}` sau `\t},`
		self.campuri = campuri


def valoare_de_pe_linie(linie, numar_linie):
	"""Valoarea unui câmp, citită ca JSON — nu cu tăiat de șiruri.

	`linie` arată așa: `\t\t"text": "În ce an…?",`. O punem între acolade și o
	dăm lui `json.loads`, ca escapările și ghilimelele să fie tratate de cine
	știe regulile, nu de noi.
	"""
	frag = linie.strip()
	if frag.endswith(","):
		frag = frag[:-1]
	try:
		return list(json.loads("{" + frag + "}").values())[0]
	except (ValueError, IndexError) as e:
		raise Eroare("linia %d: nu pot citi câmpul (%s)\n  %r" % (numar_linie, e, linie))


def gaseste_obiectele(linii):
	"""Împarte fișierul în obiecte. Orice linie nerecunoscută = eroare."""
	if linii[0] != "[":
		raise Eroare("prima linie ar trebui să fie '[', am găsit %r" % linii[0])
	if linii[-1] != "" or linii[-2] != "]":
		raise Eroare("fișierul ar trebui să se termine cu ']' și o linie goală")

	obiecte = []
	i = 1
	final = len(linii) - 2          # indicele liniei ']'
	while i < final:
		if linii[i] == "":          # liniile goale despart domeniile; le păstrăm
			i += 1
			continue
		if linii[i] != "\t{":
			raise Eroare("linia %d: așteptam '\\t{' sau o linie goală, am găsit %r"
			             % (i + 1, linii[i]))

		inceput = i
		i += 1
		campuri = {}
		while i < final and linii[i] not in ("\t}", "\t},"):
			if not linii[i].startswith("\t\t\""):
				raise Eroare("linia %d: așteptam un câmp la două taburi, am găsit %r"
				             % (i + 1, linii[i]))
			nume = linii[i].split("\"")[1]
			if nume in campuri:
				raise Eroare("linia %d: câmpul '%s' apare de două ori în același obiect"
				             % (i + 1, nume))
			campuri[nume] = i
			i += 1
		if i >= final:
			raise Eroare("obiectul început la linia %d nu se închide" % (inceput + 1))
		if "text" not in campuri:
			raise Eroare("obiectul din linia %d nu are câmpul 'text'" % (inceput + 1))

		obiecte.append(Obiect(inceput, i, campuri))
		i += 1
	return obiecte


def urmatorul_numar(linii, obiecte):
	"""Cel mai mare număr de id din fișier, plus unu.

	Corect doar sub regula din antet: nimic nu se șterge din fișier. Vezi
	acolo de ce un id refolosit e o greșeală pe care nimic n-o prinde.
	"""
	maxim = 0
	for ob in obiecte:
		if "id" not in ob.campuri:
			continue
		numar_linie = ob.campuri["id"]
		id_intrebare = str(valoare_de_pe_linie(linii[numar_linie], numar_linie + 1))
		if not id_intrebare.startswith(PREFIX + ":"):
			continue        # alt prefix (`wd:` etc.) — nu intră în numerotarea de mână
		coada = id_intrebare.split(":", 1)[1]
		if not coada.isdigit():
			raise Eroare("linia %d: id-ul '%s' nu se termină în cifre"
			             % (numar_linie + 1, id_intrebare))
		maxim = max(maxim, int(coada))
	return maxim + 1


# ─────────────────────────────────────────────────────────────
# SCRIEREA
# ─────────────────────────────────────────────────────────────

def compune(linii, obiecte):
	"""Întoarce (linii noi, lista de legături adăugate).

	Nu modifică nicio linie existentă: doar inserează, imediat după `\t{`.
	Ordinea câmpurilor iese `id`, `fapt`, `text`, … ca în `docs/ghid-note.md`.
	"""
	numar = urmatorul_numar(linii, obiecte)

	# Câte întrebări are fiecare text: puntea cere „exact o dată”.
	cate_cu_textul = {}
	for ob in obiecte:
		numar_linie = ob.campuri["text"]
		text = str(valoare_de_pe_linie(linii[numar_linie], numar_linie + 1))
		cate_cu_textul[text] = cate_cu_textul.get(text, 0) + 1

	lipsa = [t for t in FAPTE_PILOT if t not in cate_cu_textul]
	if lipsa:
		raise Eroare("texte din FAPTE_PILOT care nu există în fișier:\n  "
		             + "\n  ".join(repr(t) for t in lipsa))
	ambigue = [t for t in FAPTE_PILOT if cate_cu_textul[t] > 1]
	if ambigue:
		raise Eroare("texte din FAPTE_PILOT care apar de mai multe ori:\n  "
		             + "\n  ".join(repr(t) for t in ambigue))

	inserari = {}           # indice de linie → linii de pus înaintea ei
	legaturi = []           # (text, fapt), pentru raportul de la final
	id_uri_noi = 0

	for ob in obiecte:
		noi = []
		if "id" not in ob.campuri:
			noi.append("\t\t\"id\": \"%s:%0*d\"," % (PREFIX, CIFRE, numar))
			numar += 1
			id_uri_noi += 1

		numar_linie = ob.campuri["text"]
		text = str(valoare_de_pe_linie(linii[numar_linie], numar_linie + 1))
		if text in FAPTE_PILOT and "fapt" not in ob.campuri:
			fapt = FAPTE_PILOT[text]
			noi.append("\t\t\"fapt\": \"%s\"," % fapt)
			legaturi.append((text, fapt))

		if noi:
			inserari[ob.inceput + 1] = noi

	rezultat = []
	for i, linie in enumerate(linii):
		rezultat.extend(inserari.get(i, []))
		rezultat.append(linie)
	return rezultat, legaturi, id_uri_noi


# ─────────────────────────────────────────────────────────────
# VERIFICAREA DE DUPĂ SCRIERE
#
# Scriptul a umblat pe text, deci nu are nicio dovadă că a scris JSON valid.
# Dovada se ia citind fișierul înapoi, cu acelaș parser pe care-l va folosi și
# Godot. E ieftin și e singurul lucru care prinde o virgulă pierdută.
# ─────────────────────────────────────────────────────────────

def verifica_fisierul(cale):
	with io.open(cale, encoding="utf-8") as f:
		date = json.load(f)

	if not isinstance(date, list):
		raise Eroare("%s nu mai conține o listă" % cale)
	if len(date) != CATE_INTREBARI:
		raise Eroare("am găsit %d întrebări, așteptam %d" % (len(date), CATE_INTREBARI))

	vazute = {}
	fara_id = []
	for i, q in enumerate(date):
		if not isinstance(q, dict) or "id" not in q:
			fara_id.append(i)
			continue
		id_intrebare = str(q["id"])
		if id_intrebare in vazute:
			raise Eroare("id duplicat '%s': intrările %d și %d"
			             % (id_intrebare, vazute[id_intrebare], i))
		vazute[id_intrebare] = i
	if fara_id:
		raise Eroare("intrări rămase fără id: %s" % fara_id)

	cu_fapt = [q for q in date if q.get("fapt")]
	return date, cu_fapt


def verifica_faptele(cu_fapt):
	"""Faptele pomenite de întrebări există cu adevărat?

	Verificarea o face și încărcătorul din joc, dar acolo o vezi abia la
	rulare. Aici o vezi în secunda în care s-a scris greșit.
	"""
	if not os.path.exists(CALE_FAPTE):
		print("  ! %s nu există încă — legăturile nu se pot verifica." % CALE_FAPTE)
		return
	with io.open(CALE_FAPTE, encoding="utf-8") as f:
		fapte = json.load(f)
	cunoscute = set(str(x.get("id", "")) for x in fapte if isinstance(x, dict))
	necunoscute = sorted(set(str(q["fapt"]) for q in cu_fapt) - cunoscute)
	if necunoscute:
		raise Eroare("întrebări legate de fapte care nu există în %s: %s"
		             % (os.path.basename(CALE_FAPTE), ", ".join(necunoscute)))


# ─────────────────────────────────────────────────────────────

def main():
	scrie = "--scrie" in sys.argv

	with io.open(CALE_INTREBARI, encoding="utf-8", newline="") as f:
		brut = f.read()
	if "\r\n" in brut:
		raise Eroare("fișierul are sfârșituri de linie CRLF; scriptul lucrează pe LF")

	linii = brut.split("\n")
	obiecte = gaseste_obiectele(linii)
	print("%s: %d obiecte, %d linii." % (
		os.path.relpath(CALE_INTREBARI, RADACINA), len(obiecte), len(linii) - 1))

	noi_linii, legaturi, id_uri_noi = compune(linii, obiecte)
	print("  id-uri noi: %d   legături 'fapt' noi: %d" % (id_uri_noi, len(legaturi)))

	if id_uri_noi == 0 and not legaturi:
		print("  Nimic de schimbat. (Scriptul a mai rulat.)")
		verifica_fisierul(CALE_INTREBARI)
		print("  Fișierul de pe disc e valid și complet.")
		return 0

	if not scrie:
		print("\n  Probă uscată. Rulează cu --scrie ca să scrie fișierul.")
		return 0

	with io.open(CALE_INTREBARI, "w", encoding="utf-8", newline="") as f:
		f.write("\n".join(noi_linii))
	print("  Scris.")

	date, cu_fapt = verifica_fisierul(CALE_INTREBARI)
	verifica_faptele(cu_fapt)
	print("  Verificat înapoi: %d întrebări, toate cu id unic, %d cu fapt."
	      % (len(date), len(cu_fapt)))

	# Legăturile, citite pe text, ca să se poată verifica cu ochiul.
	print("\n  CELE %d LEGĂTURI CU FAPTELE:" % len(cu_fapt))
	for q in date:
		if q.get("fapt"):
			print("    %-22s  %s  %s" % (q["id"], q["fapt"], q["text"]))
	return 0


if __name__ == "__main__":
	try:
		sys.exit(main())
	except Eroare as e:
		print("\nOPRIT: %s" % e)
		sys.exit(1)

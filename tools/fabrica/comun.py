#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MODULUL COMUN AL FABRICII DE ÎNTREBĂRI.

Nu se rulează singur. Îl importă fiecare tabel al fabricii:

    tools/fabrica/elemente.py    element ↔ simbol        (domeniul „stiinta")
    tools/fabrica/opere.py       operă ↔ autor           (domeniul „literatura")
    tools/fabrica/capitale.py    țară ↔ capitală         (domeniul „geografie")

─────────────────────────────────────────────────────────────
DE CE EXISTĂ ABIA ACUM, LA AL TREILEA TABEL

Scris după primul tabel, ar fi fost o ghicitoare: n-aveam de unde să știu ce se
repetă și ce doar pare să se repete. Scris după al doilea, cu două exemple
alături, duplicarea s-a putut CITI — și s-a văzut și unde cele două scripturi
făceau același lucru cu mici diferențe nedorite (`grila` cu alte lățimi de
coloană, `interogheaza` cu alt timeout).

Duplicarea a fost, până azi, o datorie SCRISĂ, nu o scăpare: e în
`docs/progres.md`, la sesiunea AL DOILEA TABEL, cu termenul „al treilea tabel".
Ăsta e al treilea tabel.

─────────────────────────────────────────────────────────────
CE INTRĂ AICI ȘI CE NU — REGULA, CA SĂ NU SE UMFLE

INTRĂ ce e identic, sau identic-cu-un-parametru, între tabele: rețeaua, cache-ul,
scrierea fișierelor, `zar`, raportul, marcajul de ciornă, FORMA verificărilor.

NU INTRĂ nicio judecată despre un tabel anume: care entități sunt cultură
generală, ce nivel are fiecare, cum se punctează distractorii, ce anume e o
dublură. Alea rămân în scriptul lor, fiindcă sunt DECIZII, iar o decizie mutată
într-un modul „comun" devine, în șase luni, un `if tabel == "opere"` — adică
duplicarea de azi, doar ascunsă.

Proba pe care am dat-o la refactor: după mutare, toate cele patru fișiere din
`data/trivia_gen/` au ieșit IDENTICE, octet cu octet. Un modul comun care schimbă
o virgulă din conținut nu e un refactor, e o rescriere nedeclarată.

─────────────────────────────────────────────────────────────
CE ANUME E „FORMA UNEI VERIFICĂRI"

Merită spus, fiindcă e diferența dintre un modul care ține și unul care se rupe
la al patrulea tabel.

`verifica_un_singur_raspuns` nu poate ști ce înseamnă „corect" — la elemente e
un simbol, la opere un autor, la capitale o capitală. Dar poate ști ce înseamnă
VERIFICAREA: numără câte dintre cele patru variante sunt corecte după datele
complete de la Wikidata, cere exact una, cere să fie cea marcată, adună toate
problemele și oprește tot. Tabelul dă trei rânduri de predicat; numărarea,
mesajele și oprirea sunt scrise o dată.

Același lucru la dubluri: POTRIVIREA e a tabelului (titluri între ghilimele la
opere, cuvinte întregi la elemente), dar COMPARAȚIA declarate ↔ găsite ↔ fantome
e aceeași peste tot, inclusiv lecția că o declarație rămasă fără acoperire e la
fel de rea ca una lipsă, doar mai tăcută.
"""

import difflib
import hashlib
import io
import json
import os
import random
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request


# ─────────────────────────────────────────────────────────────
# CĂILE ȘI CONSTANTELE COMUNE
# ─────────────────────────────────────────────────────────────

AICI = os.path.dirname(os.path.abspath(__file__))
RADACINA = os.path.dirname(os.path.dirname(AICI))

CALE_CONTACT = os.path.join(AICI, "contact.txt")
DOSAR_DATE = os.path.join(AICI, "date")
DOSAR_CACHE = os.path.join(AICI, "cache")

CALE_MANA = os.path.join(RADACINA, "data", "intrebari_trivia.json")
CALE_FAPTE_MANA = os.path.join(RADACINA, "data", "fapte_trivia.json")

# Dosarul pe care `trivia.gd` îl citește ÎNTREG, sortat pe nume. Convenția:
# `<tabel>_intrebari.json` și `<tabel>_fapte.json`. Un tabel nou = două fișiere
# puse acolo și nicio linie de cod, nici în joc, nici în verificator.
DOSAR_GEN = os.path.join(RADACINA, "data", "trivia_gen")

ENDPOINT = "https://query.wikidata.org/sparql"

# Aceleași șase, în aceeași ordine ca `CATEGORII` din `trivia.gd`. Scrise aici,
# nu citite din date: raportul trebuie să arate o celulă GOALĂ dacă un domeniu
# rămâne fără întrebări, iar un raport care-și ia lista din date n-o poate face.
DOMENII = ["istorie", "geografie", "stiinta", "arta", "mitologie", "literatura"]

NIVELURI = (1, 2, 3)


class Eroare(Exception):
	"""Ceva ce scriptul nu recunoaște. Oprește tot, nu se sare peste."""


def consola_pe_utf8():
	"""Consola Windows nu e pe UTF-8 din oficiu, iar tot ce tipărim are diacritice."""
	if hasattr(sys.stdout, "reconfigure"):
		sys.stdout.reconfigure(encoding="utf-8")


def relativ(cale):
	"""Calea, scurtată la rădăcina repo-ului. Doar pentru mesaje."""
	return os.path.relpath(cale, RADACINA)


# ─────────────────────────────────────────────────────────────
# FIȘIERE
# ─────────────────────────────────────────────────────────────

def citeste_json(cale, ce):
	if not os.path.exists(cale):
		raise Eroare("lipsește %s (%s)" % (relativ(cale), ce))
	with io.open(cale, encoding="utf-8") as f:
		try:
			return json.load(f)
		except ValueError as e:
			raise Eroare("%s nu e JSON valid: %s" % (relativ(cale), e))


def citeste_lista(cale, ce="listă"):
	date = citeste_json(cale, ce)
	if not isinstance(date, list):
		raise Eroare("%s nu conține o listă" % relativ(cale))
	return date


def ca_json(valoare):
	"""Un singur câmp, scris ca JSON. `ensure_ascii=False` ca diacriticele și
	ghilimelele românești să rămână litere, nu `\\u0103`."""
	return json.dumps(valoare, ensure_ascii=False)


def scrie_lista(cale, obiecte, ordinea, separa_pe):
	"""Scrie o listă de obiecte, cu câmpurile în `ordinea` dată.

	Nu `json.dump`: fișierul iese în ACELAȘI format ca `intrebari_trivia.json`
	(taburi, `variante` pe un singur rând, linii goale între niveluri). `json.dump`
	ar pune fiecare variantă pe rândul ei, iar fișierul ar sări de la 1200 la 2000
	de linii, cu diff-uri pe care nu le mai poți citi când adaugi patru rânduri.

	`separa_pe` e un câmp: când valoarea lui se schimbă, se pune o linie goală.
	La întrebări e `nivel`, deci fișierul se citește pe felii, ca cel scris de
	mână, unde liniile goale despart domeniile.
	"""
	rand = ["["]
	anterior = None
	for i, ob in enumerate(obiecte):
		if separa_pe and anterior is not None and ob[separa_pe] != anterior:
			rand.append("")
		anterior = ob[separa_pe] if separa_pe else None

		rand.append("\t{")
		chei = [c for c in ordinea if c in ob]
		for j, cheie in enumerate(chei):
			virgula = "," if j < len(chei) - 1 else ""
			rand.append("\t\t%s: %s%s" % (ca_json(cheie), ca_json(ob[cheie]), virgula))
		rand.append("\t}" + ("," if i < len(obiecte) - 1 else ""))
	rand.append("]")
	rand.append("")

	os.makedirs(os.path.dirname(cale), exist_ok=True)
	# `newline="\n"`: .gitattributes cere LF pentru tot repo-ul.
	with io.open(cale, "w", encoding="utf-8", newline="\n") as f:
		f.write("\n".join(rand))


def scrie_pe_rand(cale, obiecte, ordinea, separa_pe=None):
	"""Ca `scrie_lista`, dar cu UN OBIECT PE UN RÂND.

	Pentru fișierele de mână și pentru propuneri. Un fișier pe care-l citește și-l
	taie un om trebuie să se poată sorta, filtra și șterge pe rânduri; cinci rânduri
	per intrare ar face 700 de rânduri dintr-un tabel de 140.
	"""
	rand = ["["]
	anterior = None
	for i, ob in enumerate(obiecte):
		if separa_pe and anterior is not None and ob.get(separa_pe) != anterior:
			rand.append("")
		anterior = ob.get(separa_pe) if separa_pe else None
		bucati = ["%s: %s" % (ca_json(c), ca_json(ob[c])) for c in ordinea if c in ob]
		rand.append("\t{%s}%s" % (", ".join(bucati), "," if i < len(obiecte) - 1 else ""))
	rand.append("]")
	rand.append("")
	os.makedirs(os.path.dirname(cale), exist_ok=True)
	with io.open(cale, "w", encoding="utf-8", newline="\n") as f:
		f.write("\n".join(rand))


def verifica_inapoi(cale, cate_asteptate):
	"""Scriptul a scris text, deci n-are nicio dovadă că a scris JSON valid.

	Dovada se ia citind fișierul înapoi, cu același fel de parser pe care-l va
	folosi și Godot. Ieftin, și singurul lucru care prinde o virgulă pierdută.
	"""
	date = citeste_lista(cale)
	if len(date) != cate_asteptate:
		raise Eroare("%s: am citit %d intrări, scrisesem %d"
		             % (os.path.basename(cale), len(date), cate_asteptate))
	vazute = set()
	for q in date:
		id_ = str(q.get("id", ""))
		if not id_:
			raise Eroare("%s: o intrare fără id" % os.path.basename(cale))
		if id_ in vazute:
			raise Eroare("%s: id duplicat %r" % (os.path.basename(cale), id_))
		vazute.add(id_)
	return date


# ─────────────────────────────────────────────────────────────
# REȚEAUA
# ─────────────────────────────────────────────────────────────

def contactul(script="elemente.py"):
	"""Adresa de contact pentru User-Agent. NU stă în cod.

	Wikimedia cere un User-Agent descriptiv, cu un om de contact, ca să poată
	scrie cuiva dacă un script le face rău. Corect — dar adresa nu are ce căuta
	într-un fișier comis în Git, deci se citește din afară:

	    MINDKEEP_CONTACT=cineva@exemplu.ro python tools/fabrica/<script> --reincarca

	sau, mai comod, se scrie o dată în `tools/fabrica/contact.txt`, care e în
	`.gitignore`.

	Cerută DOAR când se atinge rețeaua. O rulare din cache nu are nevoie de
	nimic, deci scriptul merge pe orice mașină care are cache-ul.
	"""
	din_mediu = os.environ.get("MINDKEEP_CONTACT", "").strip()
	if din_mediu:
		return din_mediu
	if os.path.exists(CALE_CONTACT):
		with io.open(CALE_CONTACT, encoding="utf-8") as f:
			din_fisier = f.read().strip()
		if din_fisier:
			return din_fisier
	raise Eroare(
		"nu am un contact pentru User-Agent, iar Wikimedia îl cere.\n"
		"  Pune-l într-unul din două locuri:\n"
		"    MINDKEEP_CONTACT=adresa@ta  (variabilă de mediu)\n"
		"    %s  (o singură linie; e în .gitignore)\n"
		"  Cache-ul existent se folosește fără contact — doar --reincarca are nevoie de el."
		% relativ(CALE_CONTACT)
	)


def interogheaza(interogare, ce, timeout=180):
	"""O cerere la Wikidata. Întoarce răspunsul brut, ca dicționar."""
	contact = contactul()
	antet = "Mindkeep-fabrica/0.1 (%s) Python-urllib" % contact

	cerere = urllib.request.Request(
		ENDPOINT,
		data=urllib.parse.urlencode({"query": interogare}).encode("utf-8"),
		headers={
			"User-Agent": antet,
			"Accept": "application/sparql-results+json",
			"Content-Type": "application/x-www-form-urlencoded",
		},
		method="POST",
	)
	print("    întreb Wikidata: %s…  (User-Agent: %s)" % (ce, antet))
	try:
		with urllib.request.urlopen(cerere, timeout=timeout) as raspuns:
			return json.loads(raspuns.read().decode("utf-8"))
	except urllib.error.HTTPError as e:
		# 403 și 429 de la Wikimedia înseamnă aproape mereu User-Agent, nu
		# interogare — merită spus, altfel cauți o oră în SPARQL.
		detaliu = ""
		if e.code in (403, 429):
			detaliu = ("\n  Codul %d de la Wikimedia e aproape mereu despre User-Agent "
			           "sau despre prea multe cereri, nu despre interogare." % e.code)
		raise Eroare("Wikidata a răspuns %d %s (%s)%s" % (e.code, e.reason, ce, detaliu))
	except urllib.error.URLError as e:
		raise Eroare("nu ajung la Wikidata (%s): %s" % (ce, e.reason))


def cache_citeste(cale):
	"""Pachetul din cache, sau `None` dacă nu există.

	CE VALIDEAZĂ PACHETUL rămâne în scriptul lui: la opere, lista de autori și
	pragul de ediții; la capitale, lista de criterii. Aici e doar citirea și
	tipărirea datei — restul e o judecată despre tabel.
	"""
	if not os.path.exists(cale):
		return None
	with io.open(cale, encoding="utf-8") as f:
		pachet = json.load(f)
	print("  Cache: %s (luat la %s)" % (relativ(cale), pachet.get("luat_la", "?")))
	return pachet


def cache_scrie(cale, pachet):
	"""Scrie cache-ul, cu proveniența pusă aici.

	DE CE UN CACHE COMIS ÎN GIT. Wikidata se editează. Dacă mâine cineva schimbă
	eticheta română a unei entități, vreau să văd diferența CÂND O CER
	(`--reincarca`), nu să apară singură într-un diff din `data/`. Un generator
	care depinde de o sursă vie și n-o îngheață nu e un generator, e o rulare
	norocoasă.

	Și de-aia pachetul ține CÂND a fost luat, și de la ce endpoint: fără ele,
	peste șase luni ai un fișier de date fără proveniență.
	"""
	intreg = dict(pachet)
	intreg["luat_la"] = time.strftime("%Y-%m-%dT%H:%M:%S")
	intreg["endpoint"] = ENDPOINT
	os.makedirs(os.path.dirname(cale), exist_ok=True)
	with io.open(cale, "w", encoding="utf-8", newline="\n") as f:
		json.dump(intreg, f, ensure_ascii=False, indent="\t", sort_keys=True)
		f.write("\n")
	print("  Scris cache: %s (%.1f MB)"
	      % (relativ(cale), os.path.getsize(cale) / 1048576.0))
	return intreg


def legaturi(raspuns):
	"""Rândurile unui răspuns SPARQL."""
	return raspuns.get("results", {}).get("bindings", [])


def qid_din(uri):
	"""QID-ul dintr-un URI de entitate. Orice altceva oprește scriptul."""
	q = uri.rsplit("/", 1)[-1]
	if not re.fullmatch(r"Q\d+", q):
		raise Eroare("URI pe care nu-l recunosc: %r" % uri)
	return q


def qid_sau_nimic(uri):
	"""Ca `qid_din`, dar întoarce `None` pentru un NOD ANONIM.

	Wikidata are valori de tip „există, dar nu se știe care" — autor necunoscut,
	dată necunoscută — iar SPARQL le întoarce ca
	`…/.well-known/genid/1986ff00…`. Nu e o eroare în date, e o afirmație: „se
	știe că are un autor, nu se știe cine".

	Cine cheamă funcția asta trebuie să NUMERE nodul anonim, nu să-l ignore: o
	carte scrisă de cineva cunoscut împreună cu un anonim are doi autori, deci
	pică regula unui singur autor, cum se cuvine.
	"""
	if "/.well-known/genid/" in uri:
		return None
	return qid_din(uri)


def multe(rand, camp):
	"""Un `GROUP_CONCAT` de URI-uri de entitate, desfăcut în QID-uri.

	Nodurile anonime ies ca `?`, nu se pierd. Vezi `qid_sau_nimic` pentru de ce
	trebuie NUMĂRATE: o operă scrisă de cineva cunoscut împreună cu un anonim are
	doi autori, deci pică regula unui singur autor, cum se cuvine.

	Cererile folosesc `GROUP_CONCAT` în loc de rânduri simple fiindcă altfel o
	entitate cu 2 autori, 3 tipuri și 2 ani vine pe 12 rânduri identice în rest —
	la opere, diferența a fost între un cache de 3,5 MB și unul de 8,6 MB.
	"""
	brut = rand.get(camp, {}).get("value", "").strip()
	if not brut:
		return set()
	iesite = set()
	for bucata in brut.split(" "):
		if not bucata:
			continue
		q = qid_sau_nimic(bucata)
		iesite.add(q if q else "?")
	return iesite


# ─────────────────────────────────────────────────────────────
# RÂNDURILE SCRISE DE MÂNĂ
# ─────────────────────────────────────────────────────────────

def verifica_campurile(rand, permise, unde, probleme):
	"""Un rând de mână n-are voie să aibă câmpuri pe care scriptul nu le cunoaște.

	Lista e ÎNCHISĂ dinadins. „ciorne" în loc de „ciorna" ar fi o ciornă care
	ajunge în joc, fără ca nimic să spună nimic — cel mai scump fel de greșeală,
	fiindcă nu se vede nici în cod, nici în date, doar în joc.

	Întoarce `True` dacă rândul e curat.
	"""
	if not isinstance(rand, dict):
		probleme.append("%s nu e un obiect" % unde)
		return False
	necunoscute = sorted(set(rand) - set(permise))
	if necunoscute:
		probleme.append("%s are câmpuri pe care nu le cunosc: %s"
		                % (unde, ", ".join(necunoscute)))
		return False
	return True


def raporteaza_ciornele(lista_toata, ciorne, cate_se_scriu, scrie, ce="rânduri"):
	"""Blocul de raport despre ciorne.

	CE E O CIORNĂ: un rând cu `"ciorna": true` e o propunere pe care n-am
	confirmat-o încă cu ochiul. Rularea de probă o ia în seamă (grilă, mostre,
	TOATE verificările); `--scrie` o lasă afară.

	AMĂNUNTUL CARE NU E EVIDENT, și care a fost învățat la opere: ciornele se
	scot ÎNAINTE de construirea întrebărilor, nu la sfârșit. Distractorii se aleg
	dintre rândurile alese, deci o ciornă lăsată în listă ar ajunge distractor
	într-o întrebare scrisă în `data/`.

	Deci raportul de probă și fișierul scris pot să difere — și ăsta E înțelesul
	lor: proba arată ce-ai avea dacă ai confirma tot.
	"""
	print("\n  ── TABELUL ──")
	print("    în tabel: %d %s  (nivel I: %d, II: %d, III: %d)" % (
		len(lista_toata), ce,
		sum(1 for e in lista_toata if e["nivel"] == 1),
		sum(1 for e in lista_toata if e["nivel"] == 2),
		sum(1 for e in lista_toata if e["nivel"] == 3)))
	print("    dintre care ciorne (neconfirmate): %d" % len(ciorne))
	if scrie:
		print("    SE SCRIU doar cele %d confirmate." % cate_se_scriu)
	elif ciorne:
		print("    proba de mai jos le ia în seamă PE TOATE, ciornele incluse.")


# ─────────────────────────────────────────────────────────────
# ZARUL ȘI FORMA UNEI ÎNTREBĂRI
# ─────────────────────────────────────────────────────────────

def zar(*bucati):
	"""Un număr stabil dintr-un text: același la fiecare rulare, pe orice mașină.

	`hash()` din Python NU e bun aici: e sărat la fiecare pornire a
	interpretorului, deci ar da alt fișier la fiecare rulare.

	DE CE E NEVOIE DE EL. Ruperea egalităților trebuie să fie deterministă (ca
	fișierul să nu se schimbe degeaba), dar nu are voie să fie ORDONATĂ. Prima
	variantă rupea egalitățile pe QID crescător, iar în Wikidata QID-urile mici
	sunt exact subiectele celebre (hidrogenul e Q556, Shakespeare e Q692, Franța
	e Q142). Rezultatul: aceleași câteva subiecte apăreau ca distractori la
	jumătate din întrebări — iar un jucător care observă „răspunsul nu e
	niciodată hidrogenul" marchează puncte fără să gândească. Exact scurtătura pe
	care `_amesteca` din `trivia.gd` a fost scrisă s-o închidă, reapărută pe alt
	drum.
	"""
	cheie = "|".join(str(b) for b in bucati).encode("utf-8")
	return int.from_bytes(hashlib.blake2b(cheie, digest_size=8).digest(), "big")


def pune_la_locul_lui(cheie, relatie, sens, text, bun, restul, nivel, fapt, domeniu,
                      eticheta=None):
	"""O întrebare gata de scris, cu răspunsul bun pus pe o poziție împrăștiată.

	`trivia.gd` amestecă variantele la fiecare apariție (`_amesteca`), deci poziția
	din fișier nu ajunge niciodată pe ecran. O punem totuși împrăștiată: dacă
	amestecarea e vreodată scoasă sau ocolită, fișierul să nu aibă răspunsul bun
	mereu pe primul buton. Două plase peste aceeași greșeală, niciuna scumpă.

	Prin `zar`, nu prin `QID % 4`: QID-ul singur iese grămădit (40/27/36/36 pe cele
	patru locuri, măsurat la elemente) și dă ambelor întrebări ale unei entități
	același loc, fiindcă amândouă pornesc de la același QID. Sensul intră în cheie,
	deci cele două se despart.

	`id`-ul iese `wd:<QID>:<relație>:<sens>` — patru bucăți, forma pe care
	`tools/verifica_trivia.gd` o cere de la orice `id` cu prefixul `wd:`. Relația
	e în el fiindcă o entitate poate apărea în mai multe tabele: Franța ar putea
	fi mâine și într-un tabel „țară → limbă", și cele două întrebări n-au voie să
	aibă același `id`.
	"""
	loc = zar(cheie, sens, "poziție") % 4
	variante = list(restul)
	variante.insert(loc, bun)
	if len(set(variante)) != 4:
		raise Eroare("%s / %s: variante identice → %s"
		             % (eticheta or cheie, sens, variante))
	return {
		"id": "wd:%s:%s:%s" % (cheie, relatie, sens),
		"fapt": fapt,
		"text": text,
		"variante": variante,
		"corect": loc,
		"nivel": nivel,
		"categorie": domeniu,
	}


def verifica_un_singur_raspuns(intrebari, este_corect):
	"""Exact una dintre cele patru variante e corectă? Pe date complete.

	`este_corect(q, varianta) -> bool` îl dă tabelul, fiindcă numai el știe ce
	înseamnă „corect": la elemente un simbol, la opere un autor, la capitale o
	capitală. Ce e comun e verificarea însăși.

	DE CE NU E DE PRISOS, deși fiecare tabel are deja opriri când își leagă
	rândurile la Wikidata: aceea apără PRESUPUNEREA („fiecare operă are exact un
	autor"), asta apără REZULTATUL. Dacă mâine o schimbare în date sau în codul
	de construire ar scoate o întrebare cu două răspunsuri bune, aici se oprește
	tot, și se spune care.

	Se verifică pe mulțimea COMPLETĂ de la Wikidata, nu pe coloana de mână: dacă
	cineva adaugă în Wikidata un al doilea autor sau o a doua capitală, se vede
	la prima `--reincarca`, nu într-o partidă.
	"""
	probleme = []
	for q in intrebari:
		corecte = [v for v in q["variante"] if este_corect(q, v)]
		if len(corecte) != 1:
			probleme.append("%s — %s   variante: %s   corecte după Wikidata: %s"
			                % (q["id"], q["text"], " / ".join(q["variante"]),
			                   ", ".join(corecte) or "NICIUNA"))
		elif corecte[0] != q["variante"][q["corect"]]:
			probleme.append("%s — marcat corect %r, dar Wikidata spune %r"
			                % (q["id"], q["variante"][q["corect"]], corecte[0]))

	if probleme:
		raise Eroare("întrebări la care nu e exact un răspuns corect:\n  - "
		             + "\n  - ".join(probleme))


# ─────────────────────────────────────────────────────────────
# TEXTUL: POTRIVIRI PESTE DIACRITICE ȘI MAJUSCULE
# ─────────────────────────────────────────────────────────────

def fara_semne(text):
	"""Textul micșorat și fără diacritice, pentru potriviri.

	„Franța" și „franta" trebuie să se potrivească: numele proprii se scriu cu
	diacritice în fișierele mele și fără ele în jumătate din lume, iar o
	potrivire care le deosebește ratează exact cazurile pe care e pusă să prindă.
	"""
	descompus = unicodedata.normalize("NFKD", text.lower())
	return "".join(c for c in descompus if not unicodedata.combining(c))


def cuvant_in(text, forma):
	"""`forma` apare în `text` ca CUVÂNT ÎNTREG, fără majuscule?

	Pe cuvânt întreg, nu pe bucată de cuvânt: altfel „bor" s-ar găsi în
	„laborator" și „iod" în „perioada". Lecția vine de la elemente, unde prima
	versiune căuta bucăți și găsea dubluri care nu existau.
	"""
	return re.search(r"\b%s\b" % re.escape(forma.lower()), text.lower()) is not None


def seamana(a, b, prag=0.62):
	"""Cât de asemănătoare sunt două nume, peste diacritice.

	NU oprește nimic niciodată. Rostul e o listă „de citit cu ochiul": lucruri
	care nu încalcă nicio regulă scrisă, dar pe care ochiul le vede. „Brazilia" și
	„Brasília" nu se conțin una pe alta, deci niciun filtru de conținere nu le
	prinde — dar un jucător le vede pe loc.

	Un filtru care ar ÎNCERCA să prindă și cazurile de la limită ar tăia și
	perechi bune. Unul care le ARATĂ lasă decizia la om.
	"""
	return difflib.SequenceMatcher(None, fara_semne(a), fara_semne(b)).ratio() >= prag


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

def compara_dublurile(gasite, declarate, nume_tabel="DUBLURI"):
	"""Ce s-a găsit prin fișierul de mână, față de ce e declarat în cod.

	Două opriri, nu una, și a doua e cea pe care ai uita-o:

	1. O SUPRAPUNERE NEDECLARATĂ oprește scriptul. Prinde ziua în care scriu de
	   mână „simbolul chimic al fierului" și uit să vin în tabel — adică ziua în
	   care jocul capătă două întrebări identice.

	2. O DECLARAȚIE CARE NU SE MAI GĂSEȘTE („fantomă") oprește la fel. E mai
	   rea, fiindcă e mai tăcută: scoate din joc o întrebare bună fără să spună
	   de ce. Verificarea asta și-a plătit prețul deja — la opere a arătat că
	   dublurile se căutau pe lista filtrată, nu pe tabelul întreg.

	`gasite` și `declarate` sunt dicționare cu aceeași formă de cheie; cheia o
	alege tabelul (la elemente `(simbol, sens)`, la capitale `(qid, sens)`).
	"""
	nedeclarate = sorted(k for k in gasite if k not in declarate)
	if nedeclarate:
		# Rândurile ies GATA DE COPIAT în tabel, nu ca o listă de citit. Diferența
		# nu e cosmetică: la opere au ieșit 16 deodată, iar o listă din care trebuie
		# să retipărești 16 rânduri e o listă la care faci o greșeală de tipar.
		raise Eroare(
			"întrebări scrise de mână care se suprapun cu ce generăm, nedeclarate în "
			"%s:\n" % nume_tabel + "\n".join(
				'\t(%s): %s,' % (", ".join(ca_json(b) for b in k), ca_json(gasite[k]))
				for k in nedeclarate)
			+ "\n  Copiază rândurile de mai sus în %s (sau schimbă întrebarea de mână)."
			% nume_tabel)

	fantome = sorted(k for k in declarate if k not in gasite)
	if fantome:
		raise Eroare(
			"%s declară suprapuneri care nu se mai găsesc în fișierul scris de "
			"mână:\n  - " % nume_tabel + "\n  - ".join(
				" / ".join(str(b) for b in k) for k in fantome)
			+ "\n  Dacă întrebarea de mână s-a schimbat, șterge rândul din %s." % nume_tabel)

	return gasite


# ─────────────────────────────────────────────────────────────
# RAPORTUL
# ─────────────────────────────────────────────────────────────

def citeste_dosarul_generat(fara):
	"""Toate întrebările din `data/trivia_gen/`, în afară de fișierul dat.

	Grila trebuie să arate ADEVĂRUL, adică tot conținutul din joc, nu doar tabelul
	pe care-l rulez acum: de când sunt mai multe fabrici, un raport care se uită
	doar la el însuși minte cu jumătăți de adevăr.

	Fișierul propriu se scoate și se înlocuiește cu ce s-a construit în memorie —
	altfel raportul ar arăta versiunea de pe disc, cea dinaintea rulării.
	"""
	altele = []
	if not os.path.isdir(DOSAR_GEN):
		return altele
	for nume in sorted(os.listdir(DOSAR_GEN)):
		if not nume.endswith("_intrebari.json"):
			continue
		cale = os.path.join(DOSAR_GEN, nume)
		if os.path.abspath(cale) == os.path.abspath(fara):
			continue
		altele.extend(citeste_lista(cale))
	return altele


def grila(intrebari_mana, intrebari_gen):
	"""Grila de 6 domenii × 3 niveluri, cu întrebări ȘI fapte.

	Faptele se numără separat fiindcă ele sunt măsura adevărată: 500 de întrebări
	construite din 100 de fapte se simt ca 100 (decizia din sesiunea CONȚINUTUL).
	"""
	def strange(intrebari):
		celule = {}
		for q in intrebari:
			cheie = (str(q.get("categorie", "?")), int(q.get("nivel", 0)))
			c = celule.setdefault(cheie, {"q": 0, "fapte": set()})
			c["q"] += 1
			if q.get("fapt"):
				c["fapte"].add(str(q["fapt"]))
		return celule

	mana = strange(intrebari_mana)
	gen = strange(intrebari_gen)

	print("\n  ── GRILA: întrebări (fapte) ──")
	print("    %-12s %18s %18s %18s %13s" % (
		"", "nivelul I", "nivelul II", "nivelul III", "total"))
	total_general = 0
	for domeniu in DOMENII:
		bucati = []
		total_q = 0
		total_f = set()
		for nivel in NIVELURI:
			m = mana.get((domeniu, nivel), {"q": 0, "fapte": set()})
			w = gen.get((domeniu, nivel), {"q": 0, "fapte": set()})
			total_q += m["q"] + w["q"]
			total_f |= m["fapte"] | w["fapte"]
			bucati.append("%3d+%-3d (%2d+%-3d)" % (
				m["q"], w["q"], len(m["fapte"]), len(w["fapte"])))
		total_general += total_q
		print("    %-12s %s %12s" % (domeniu, " ".join("%17s" % b for b in bucati),
		                             "%4d (%3d)" % (total_q, len(total_f))))
	print("    (mână + fabricate; parantezele sunt fapte distincte; %d întrebări în total)"
	      % total_general)


def cat_din_lupta(intrebari_mana, intrebari_gen, intrebarile_mele, domeniu, eticheta):
	"""Ce parte din luptă devine relația asta.

	Alegerea din `trivia.gd` e în două trepte: întâi domeniul, uniform, apoi
	întrebarea — deci fiecare domeniu ia 1/6 din întrebări oricât de mare ar fi el.
	Ce se schimbă e ce se întâmplă ÎN domeniu, și cifra aia merită văzută, nu
	ghicită: pârghia rămâne lățimea conținutului, nu o treaptă de alegere în plus.
	"""
	print("\n  ── CÂT DIN LUPTĂ DEVINE %s ──" % eticheta)
	ale_mele = {q["id"] for q in intrebarile_mele}
	for nivel in NIVELURI:
		in_domeniu = [q for q in intrebari_mana + intrebari_gen
		              if str(q.get("categorie")) == domeniu and int(q.get("nivel", 0)) == nivel]
		mele = [q for q in in_domeniu if str(q.get("id")) in ale_mele]
		if not in_domeniu:
			continue
		print("    nivelul %d: %d din %d întrebări de %s (%.0f%%), "
		      "adică %.0f%% din toate întrebările de luptă"
		      % (nivel, len(mele), len(in_domeniu), domeniu,
		         100.0 * len(mele) / len(in_domeniu),
		         100.0 * len(mele) / len(in_domeniu) / len(DOMENII)))

	print("\n  ── CÂT DIN LUPTĂ E CONȚINUT FABRICAT (toate tabelele) ──")
	for nivel in NIVELURI:
		parti = []
		for dom in DOMENII:
			m = sum(1 for q in intrebari_mana
			        if str(q.get("categorie")) == dom and int(q.get("nivel", 0)) == nivel)
			g = sum(1 for q in intrebari_gen
			        if str(q.get("categorie")) == dom and int(q.get("nivel", 0)) == nivel)
			if m + g:
				parti.append(1.0 * g / (m + g))
		if parti:
			print("    nivelul %d: %.0f%% din întrebările de luptă sunt fabricate"
			      % (nivel, 100.0 * sum(parti) / len(parti)))


def mostre(intrebari, cate, samanta):
	"""Câteva întrebări generate, întregi, ca să se poată citi.

	Sămânța se tipărește și se poate fixa cu `--seed`: dacă una din cele 15 pare
	greșită, vrei să te poți uita din nou la exact aceleași 15.
	"""
	print("\n  ── %d ÎNTREBĂRI GENERATE, LA ÎNTÂMPLARE (sămânța %d) ──" % (cate, samanta))
	alese = random.Random(samanta).sample(intrebari, min(cate, len(intrebari)))
	for q in alese:
		print("\n    [nivel %d]  %s" % (q["nivel"], q["text"]))
		for i, v in enumerate(q["variante"]):
			print("        %s %s" % ("→" if i == q["corect"] else " ", v))
		print("        %s" % q["id"])


def decile(valori):
	"""Cele zece repere ale unei distribuții, ca text. Pentru `--masoara`."""
	v = sorted(valori)
	if not v:
		return "—"
	return "  ".join("%4d" % v[min(len(v) - 1, int(len(v) * k / 10))] for k in range(10))


def cat_de_bun_ar_fi_un_prag(perechi, unitate="ediții"):
	"""Cel mai bun clasificator „două praguri pe o cifră" — și cât greșește.

	`perechi` e o listă de `(cifra_măsurată, nivelul_pus_de_mână)`.

	ASTA E CIFRA CARE SPUNE CINSTIT dacă nivelul ar putea fi vreodată automat.
	Caută pragurile care reproduc cel mai bine coloana de mână și raportează
	eroarea. NU schimbă nimic: decizia rămâne a omului, oricât de frumos ar ieși.

	DE CE E O LIMITĂ SUPERIOARĂ, NU O ÎNCERCARE. Pragurile se caută exhaustiv pe
	ACELEAȘI date pe care se măsoară eroarea, deci cifra iese mai bună decât ar
	fi în realitate. Dacă nici cel mai bun prag posibil nu e bun, niciun prag nu
	e — iar „cifra ar greși 22% din rânduri, unde a ghici mereu cel mai des
	greșește 39%" e un rezultat, în timp ce „cifra nu merge" e o părere.
	"""
	perechi = sorted(perechi)
	valori = sorted({p[0] for p in perechi})
	if len(valori) < 3:
		return
	cel_mai_bun = None
	for i in range(len(valori)):
		for j in range(i + 1, len(valori)):
			a, b = valori[i], valori[j]
			# Mai mare = mai cunoscut = nivel mai mic.
			gresite = sum(1 for cifra, niv in perechi
			              if (1 if cifra > b else 2 if cifra > a else 3) != niv)
			if cel_mai_bun is None or gresite < cel_mai_bun[0]:
				cel_mai_bun = (gresite, a, b)
	gresite, a, b = cel_mai_bun
	print("    cel mai bun prag automat posibil: III sub %d %s, II sub %d, I peste"
	      % (a + 1, unitate, b + 1))
	print("      ar greși %d din %d (%.0f%%). Pentru comparație, a ghici mereu"
	      % (gresite, len(perechi), 100.0 * gresite / len(perechi)))
	niveluri = [n for _, n in perechi]
	celmaides = max(niveluri.count(n) for n in NIVELURI)
	print("      nivelul cel mai des ar greși %d din %d (%.0f%%)."
	      % (len(perechi) - celmaides, len(perechi),
	         100.0 * (len(perechi) - celmaides) / len(perechi)))


# ─────────────────────────────────────────────────────────────
# ARGUMENTELE
# ─────────────────────────────────────────────────────────────

class Argumente(object):
	"""Flagurile, citite o dată. Aceleași la toate tabelele, dinadins:
	un tabel nou nu trebuie să vină și cu o convenție nouă de linie de comandă."""

	def __init__(self, argv):
		self.scrie = "--scrie" in argv
		self.masoara = "--masoara" in argv
		self.propune = "--propune" in argv
		self.reincarca = "--reincarca" in argv
		self.samanta = random.randrange(1, 10 ** 6)
		for arg in argv[1:]:
			if arg.startswith("--seed="):
				self.samanta = int(arg.split("=", 1)[1])


def argumentele():
	return Argumente(sys.argv)


def ruleaza(main):
	"""Pornirea, aceeași la toate tabelele.

	O `Eroare` iese ca un mesaj de o linie și cod de ieșire 1, nu ca un traceback:
	opririle scriptului sunt lucruri pe care le-am scris eu ca să fie CITITE, iar
	un traceback de 20 de rânduri îngroapă mesajul în mijlocul lui. Orice altă
	excepție rămâne traceback, fiindcă aia e un bug, nu un mesaj.
	"""
	try:
		sys.exit(main())
	except Eroare as e:
		print("\nOPRIT: %s\n" % e)
		sys.exit(1)

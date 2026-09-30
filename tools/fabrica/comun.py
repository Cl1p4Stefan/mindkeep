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
import html
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
# IMAGINILE DE PE WIKIMEDIA COMMONS
#
# CE E AICI ȘI CE NU, după aceeași regulă ca restul modulului. Aici stă tot ce
# nu are nicio părere despre CE fel de imagine se aduce: cererea la API, lista
# albă de licențe, descărcarea, cache-ul, manifestul, măsurarea dosarului.
# Rămâne în scriptul tabelului: CARE imagine e cea bună (steagul actual, nu unul
# vechi), ce se face când sunt mai multe, și cum intră în fapt.
#
# E aceeași despărțire ca `interogheaza` (aici) față de `INTEROGARE_TARI`
# (acolo): rețeaua e o unealtă, alegerea e o decizie.
#
# DE CE O LISTĂ ALBĂ DE LICENȚE, ȘI NU UNA NEAGRĂ. O listă neagră apără numai
# împotriva a ce mi-am imaginat deja; prima licență la care nu m-am gândit trece
# în tăcere. O listă albă mă obligă să mă uit la fiecare caz nou — iar aici
# greșeala nu e o întrebare urâtă, e un fișier pe care n-am dreptul să-l dau mai
# departe, într-un joc pe care vreau să-l pot publica.
# ─────────────────────────────────────────────────────────────

# Rădăcina imaginilor care ÎNSOȚESC FAPTE. Dinadins în afara lui `assets/art/`:
# acolo stă arta jocului, aici stă numai material străin, cu licență de onorat.
# Granița de dosar e ce face întrebarea „ce am în joc care nu-mi aparține?" să
# aibă un răspuns dintr-o privire, nu dintr-o căutare.
#
# Aceeași cale e scrisă și în GDScript, în `tools/verifica_trivia.gd`. Se repetă
# fiindcă sunt două limbi, nu fiindcă ar fi două decizii.
DOSAR_IMAGINI = os.path.join(RADACINA, "assets", "imagini_fapte")

# Cache-ul metadatelor de pe Commons, COMUN pe toate tabelele și pe toate
# felurile de imagini. Crește în loc să se rescrie: la tablouri, fișierele de
# azi rămân pe loc. De-aia `--reincarca` împrospătează doar intrările cerute de
# tabelul care rulează, nu tot fișierul.
CALE_CACHE_COMMONS = os.path.join(DOSAR_CACHE, "commons.json")

API_COMMONS = "https://commons.wikimedia.org/w/api.php"

# API-ul Commons primește până la 50 de titluri pe cerere. 127 de steaguri =
# 3 cereri, nu 127.
CATE_PE_CERERE = 50

# Câmpurile manifestului, în ordine. Manifestul stă LÂNGĂ FIȘIERE, nu în
# `tools/`: dacă cineva copiază dosarul, creditele pleacă cu el.
ORDINEA_MANIFEST = ["fisier", "qid", "nume", "latime_ceruta", "octeti",
                    "sursa", "licenta", "licenta_url", "autor"]


def antet_user_agent():
	"""User-Agent-ul cerut de Wikimedia, la fel pentru SPARQL și pentru Commons."""
	return "Mindkeep-fabrica/0.1 (%s) Python-urllib" % contactul()


def curata_html(text):
	"""HTML → text simplu. Commons dă autorul ca `<a href=…>SKopp</a>`.

	Nu e o curățenie de lene: câmpul `Artist` e HTML prin definiție (poate avea
	legături, `<span>`-uri, `<br>`), iar în fapt trebuie să ajungă un nume pe
	care jocul îl poate scrie sub imagine. Un `<a>` ajuns în JSON s-ar vedea ca
	atare pe ecran.
	"""
	fara_taguri = re.sub(r"<[^>]+>", " ", str(text))
	intreg = html.unescape(fara_taguri)
	return re.sub(r"\s+", " ", intreg).strip()


def nume_de_fisier_commons(uri):
	"""`…/Special:FilePath/Flag%20of%20France.svg` → `Flag of France.svg`.

	Wikidata întoarce imaginile ca URL-uri codate, nu ca titluri. Decodarea se
	face aici o dată, ca să nu ajungă `%20` nici în cache, nici în cererile către
	API.
	"""
	bucata = str(uri).rsplit("/", 1)[-1]
	nume = urllib.parse.unquote(bucata).replace("_", " ").strip()
	if not nume:
		raise Eroare("URI de imagine pe care nu-l recunosc: %r" % uri)
	return nume


def _cere_atribuire(cod):
	"""`True` / `False` pentru licențele cunoscute, `None` pentru orice altceva.

	`None` NU înseamnă „probabil e în regulă". Cine cheamă funcția OPREȘTE pe el.
	"""
	if cod == "cc0" or cod.startswith("pd"):
		return False
	if cod.startswith("cc-by"):
		return True
	return None


def clasifica_licenta(ext, nume):
	"""Metadatele Commons → licența, sau o oprire.

	CE OPREȘTE, și de ce fiecare:

	1. Fără cod de licență. Un fișier fără licență declarată nu e „probabil
	   liber", e un fișier despre care nu se știe nimic.
	2. Un cod pe care lista albă nu-l cunoaște. Aici intră „fair use",
	   „non-commercial", licențele personalizate — și, important, orice cod nou
	   apărut pe Commons după ziua de azi.
	3. O licență care cere atribuire, dar fără autor sau fără linkul licenței.
	   Atribuirea CC cere autorul, sursa ȘI licența; cu unul din ele lipsă,
	   creditul afișat de joc ar fi incomplet — adică o încălcare politicoasă.
	"""
	cod = str(ext.get("License", {}).get("value", "")).strip().lower()
	scurt = curata_html(ext.get("LicenseShortName", {}).get("value", ""))
	url = str(ext.get("LicenseUrl", {}).get("value", "")).strip()
	autor = curata_html(ext.get("Artist", {}).get("value", ""))

	if not cod:
		raise Eroare(
			"%s nu are cod de licență în metadatele Commons.\n"
			"  Fabrica refuză orice fișier fără licență clară. Scoate rândul sau "
			"caută alt fișier." % nume)

	atribuire = _cere_atribuire(cod)
	if atribuire is None:
		raise Eroare(
			"%s are licența %r, pe care nu o cunosc (%s).\n"
			"  Lista albă e `pd*`, `cc0`, `cc-by*`. Dacă licența asta e într-adevăr\n"
			"  bună de folosit, adaug-o în `_cere_atribuire` — dinadins nu se poate\n"
			"  trece peste ea dintr-un flag de linie de comandă."
			% (nume, cod, scurt or "fără nume scurt"))

	if atribuire:
		if not autor:
			raise Eroare("%s are licența %s, care cere atribuire, dar Commons nu dă "
			             "niciun autor." % (nume, scurt or cod))
		if not url:
			raise Eroare("%s are licența %s, care cere atribuire, dar Commons nu dă "
			             "linkul licenței." % (nume, scurt or cod))

	return {
		"cod": cod,
		# Numele scurt e ce se afișează. Unde lipsește, codul e mai bun decât
		# nimic — dar nu se inventează o etichetă frumoasă peste un cod necitit.
		"licenta": scurt or cod,
		"licenta_url": url,
		"autor": autor,
		"cere_atribuire": atribuire,
	}


def metadate_commons(nume_fisiere, latime, reia=False, refuzate=None):
	"""Licența, autorul și adresa miniaturii, pentru fiecare fișier. Din cache.

	Cache-ul se completează, nu se rescrie: un fișier deja cunoscut, cerut la
	aceeași lățime, nu mai atinge rețeaua. `reia=True` (adică `--reincarca`)
	împrospătează DOAR fișierele cerute acum, ca să nu șteargă intrările altui
	tabel.

	Lățimea intră în condiție fiindcă `thumburl` depinde de ea. Un cache care
	n-ar ține minte parametrul cu care a fost umplut e un cache care într-o zi
	îți dă un fișier de altă mărime fără să spună nimic.

	`refuzate` e un dicționar `nume fișier → motiv`, scris de tabel: fișiere
	despre care AM DECIS deja că nu intră (o licență pe care n-o pot judeca).
	Ele nu opresc scriptul, dar nici nu se strecoară: ies cu un câmp `refuzat`,
	iar cine cheamă funcția le lasă afară și le tipărește.

	DE CE LISTA STĂ LA TABEL ȘI MECANISMUL AICI: „ce fișier refuz" e o decizie
	despre conținut, ca `EXCLUSE`; „cum se ține minte un refuz și cum se verifică
	el" e formă, deci se scrie o dată. Aceeași despărțire ca la `DUBLURI`.
	"""
	cache = {}
	if os.path.exists(CALE_CACHE_COMMONS):
		with io.open(CALE_CACHE_COMMONS, encoding="utf-8") as f:
			cache = json.load(f)

	refuzate = refuzate or {}
	de_cerut = []
	for nume in nume_fisiere:
		vechi = cache.get(nume)
		if reia or vechi is None or int(vechi.get("latime_ceruta", 0)) != int(latime):
			de_cerut.append(nume)
		elif (nume in refuzate) != ("refuzat" in vechi):
			# Lista de refuzuri s-a schimbat de la ultima rulare. Intrarea din cache
			# răspunde la altă întrebare decât cea pusă acum, deci nu se folosește.
			de_cerut.append(nume)

	if de_cerut:
		antet = antet_user_agent()
		print("    cer metadate de la Commons: %d fișiere, %d cereri  (User-Agent: %s)"
		      % (len(de_cerut),
		         (len(de_cerut) + CATE_PE_CERERE - 1) // CATE_PE_CERERE, antet))
		for i in range(0, len(de_cerut), CATE_PE_CERERE):
			lot = de_cerut[i:i + CATE_PE_CERERE]
			for nume, intrare in _un_lot_de_metadate(
					lot, latime, antet, refuzate or {}).items():
				cache[nume] = intrare
			time.sleep(0.2)

		os.makedirs(os.path.dirname(CALE_CACHE_COMMONS), exist_ok=True)
		with io.open(CALE_CACHE_COMMONS, "w", encoding="utf-8", newline="\n") as f:
			json.dump(cache, f, ensure_ascii=False, indent="\t", sort_keys=True)
			f.write("\n")
		print("    scris cache: %s (%d fișiere cunoscute)"
		      % (relativ(CALE_CACHE_COMMONS), len(cache)))
	else:
		print("    metadatele Commons: toate %d din cache (%s)"
		      % (len(nume_fisiere), relativ(CALE_CACHE_COMMONS)))

	return {nume: cache[nume] for nume in nume_fisiere}


def _un_lot_de_metadate(lot, latime, antet, refuzate):
	"""O singură cerere la API-ul Commons, pentru până la 50 de titluri."""
	parametri = {
		"action": "query",
		"format": "json",
		"formatversion": "2",
		"prop": "imageinfo",
		"iiprop": "url|extmetadata|size|mime",
		"iiurlwidth": str(int(latime)),
		"titles": "|".join("File:%s" % n for n in lot),
	}
	cerere = urllib.request.Request(
		API_COMMONS + "?" + urllib.parse.urlencode(parametri),
		headers={"User-Agent": antet, "Accept": "application/json"},
	)
	try:
		with urllib.request.urlopen(cerere, timeout=120) as raspuns:
			date = json.loads(raspuns.read().decode("utf-8"))
	except urllib.error.HTTPError as e:
		raise Eroare("Commons a răspuns %d %s la metadate" % (e.code, e.reason))
	except urllib.error.URLError as e:
		raise Eroare("nu ajung la Commons: %s" % e.reason)

	# API-ul normalizează titlurile (`_` → spațiu) și urmează redirectările. Fără
	# hărțile astea, un fișier redenumit pe Commons ar apărea ca „lipsă", deși
	# există — iar scriptul ar opri pentru un motiv fals.
	inapoi = {}
	for cheie in ("normalized", "redirects"):
		for r in date.get("query", {}).get(cheie, []):
			inapoi[r["to"]] = inapoi.get(r["from"], r["from"])

	iesite = {}
	for pagina in date.get("query", {}).get("pages", []):
		titlu = pagina.get("title", "")
		original = inapoi.get(titlu, titlu)
		nume = original[len("File:"):] if original.startswith("File:") else original

		if pagina.get("missing"):
			raise Eroare("Commons nu are fișierul %r, deși Wikidata trimite la el.\n"
			             "  Ori a fost șters, ori declarația arată greșit." % nume)

		info = (pagina.get("imageinfo") or [{}])[0]

		# UN REFUZ DECLARAT SE VERIFICĂ, NU SE CREDE PE CUVÂNT. Dacă fișierul a
		# primit între timp o licență pe care lista albă o cunoaște, declarația
		# nu mai are acoperire — și o declarație fără acoperire e la fel de rea ca
		# una lipsă, doar mai tăcută. Deci atunci se OPREȘTE.
		if nume in refuzate:
			try:
				buna = clasifica_licenta(info.get("extmetadata", {}), nume)
			except Eroare:
				buna = None
			if buna is not None:
				raise Eroare(
					"%s e declarat refuzat, dar acum are licența %r, pe care o "
					"recunosc.\n  Șterge declarația de refuz — altfel rămâne acolo "
					"un motiv care nu mai e adevărat." % (nume, buna["licenta"]))
			iesite[nume] = {
				"refuzat": refuzate[nume],
				"latime_ceruta": int(latime),
				"licenta": curata_html(info.get("extmetadata", {})
				                       .get("LicenseShortName", {}).get("value", "")),
				"luat_la": time.strftime("%Y-%m-%dT%H:%M:%S"),
			}
			continue

		licenta = clasifica_licenta(info.get("extmetadata", {}), nume)
		thumb = info.get("thumburl") or info.get("url")
		if not thumb:
			raise Eroare("Commons nu dă nicio adresă de fișier pentru %r" % nume)

		iesite[nume] = dict(licenta, **{
			"latime_ceruta": int(latime),
			"thumburl": thumb,
			"sursa": info.get("descriptionurl")
			         or ("https://commons.wikimedia.org/wiki/File:%s"
			             % urllib.parse.quote(nume.replace(" ", "_"))),
			"mime_original": info.get("mime", ""),
			"octeti_original": int(info.get("size", 0)),
			"luat_la": time.strftime("%Y-%m-%dT%H:%M:%S"),
		})

	lipsa = sorted(set(lot) - set(iesite))
	if lipsa:
		raise Eroare("Commons n-a răspuns pentru: %s" % ", ".join(lipsa))
	return iesite


def descarca_fisierul(url, cale):
	"""Un fișier de pe Commons, pe disc. Întoarce câți octeți a scris."""
	cerere = urllib.request.Request(url, headers={"User-Agent": antet_user_agent()})
	try:
		with urllib.request.urlopen(cerere, timeout=120) as raspuns:
			continut = raspuns.read()
	except urllib.error.HTTPError as e:
		raise Eroare("Commons a răspuns %d %s la %s" % (e.code, e.reason, url))
	except urllib.error.URLError as e:
		raise Eroare("nu ajung la %s: %s" % (url, e.reason))
	if not continut:
		raise Eroare("fișier gol de la %s" % url)
	os.makedirs(os.path.dirname(cale), exist_ok=True)
	# `wb`, fără `newline`: e un PNG, nu text. Pe Windows, un fișier binar scris
	# în mod text ar primi un `\r` în mijlocul octeților și n-ar mai fi o imagine.
	with io.open(cale, "wb") as f:
		f.write(continut)
	return len(continut)


def citeste_manifestul(cale):
	"""Manifestul de credite → dicționar pe numele fișierului. Gol dacă nu există."""
	if not os.path.exists(cale):
		return {}
	lista = citeste_lista(cale, "manifestul de credite")
	return {str(r.get("fisier", "")): r for r in lista}


def scrie_manifestul(cale, randuri):
	"""Manifestul, un rând pe fișier, sortat pe numele fișierului.

	Sortat, nu în ordinea descărcării: altfel o rulare care adaugă trei steaguri
	ar da un diff în care nu se vede care sunt cele trei.
	"""
	scrie_pe_rand(cale, sorted(randuri, key=lambda r: r["fisier"]), ORDINEA_MANIFEST)


def cat_cantareste(dosar, sarim_sufixele=()):
	"""`(câte fișiere, câți octeți)` sub un dosar. Doar pentru raport.

	`sarim_sufixele` există ca să se poată măsura CONȚINUTUL separat de
	contabilitatea din jurul lui: după ce Godot importă, lângă fiecare PNG stă un
	`.import`, iar o cifră care le adună pe amândouă răspunde la altă întrebare
	decât „cât cântăresc imaginile".
	"""
	cate, octeti = 0, 0
	for radacina, _, fisiere in os.walk(dosar):
		for f in fisiere:
			if any(f.endswith(s) for s in sarim_sufixele):
				continue
			cate += 1
			octeti += os.path.getsize(os.path.join(radacina, f))
	return cate, octeti


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
		# Descărcarea imaginilor e un flag SEPARAT de `--scrie` dinadins: una
		# atinge `data/`, cealaltă `assets/`. O rulare care scrie întrebări n-are
		# de ce să plece la Commons, iar una care aduce fișiere n-are de ce să
		# atingă conținutul.
		self.descarca = "--descarca" in argv
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

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — operă → autor, pentru domeniul literatura.

    python tools/fabrica/opere.py --propune     propune opere pentru autorii din
                                                `date/autori.json`. Scrie DOAR
                                                `date/opere_propuse.json`
    python tools/fabrica/opere.py --masoara     doar măsoară: rezolvarea autorilor,
                                                etichetele, distribuția edițiilor,
                                                tipurile. Nu scrie nimic
    python tools/fabrica/opere.py               raportul întreg, fără să scrie.
                                                CIORNELE INTRĂ în raport
    python tools/fabrica/opere.py --scrie       scrie perechea din data/trivia_gen/,
                                                FĂRĂ ciorne
    python tools/fabrica/opere.py --reincarca   reia din rețea și rescrie cache-ul

Produce două fișiere, rescrise ÎNTREGI la fiecare rulare cu `--scrie`:

    data/trivia_gen/opere_intrebari.json   întrebările
    data/trivia_gen/opere_fapte.json       faptele, deocamdată cu note goale

Fișierul scris de mână (`data/intrebari_trivia.json`) nu se atinge niciodată. E
citit, ca să se poată număra grila și ca să se prindă dublurile, și atât.

─────────────────────────────────────────────────────────────
AL DOILEA TABEL. CE E ALTFEL FAȚĂ DE `elemente.py`

Multe sunt la fel (cache înghețat, User-Agent din afară, opriri stricte, `zar`
pentru ruperea egalităților, scrierea JSON-ului pe același format). Ce e ALTFEL
merită citit, fiindcă vine din relație, nu din gust:

1. RELAȚIA E MULȚI-LA-UNU, nu unu-la-unu. O operă are un autor; un autor are mai
   multe opere. De-aia sensul invers e o întrebare PER AUTOR, nu per operă — vezi
   `construieste`. Dacă ar fi per operă, Rebreanu cu cinci opere ar da cinci
   întrebări cu EXACT același text și cinci răspunsuri corecte diferite.

2. NU E NEVOIE DE NICIO COLOANĂ DE GRAMATICĂ. „Cine a scris «Ion»?" ține titlul
   între ghilimele, neflexionat; „Care dintre aceste opere a fost scrisă de Liviu
   Rebreanu?" are subiectul „care (dintre opere)", mereu feminin singular, și
   numele după „de", la nominativ. La elemente au fost 70 de genitive scrise de
   mână. Aici, zero.

3. NU SE SPUNE FELUL OPEREI („Cine a scris ROMANUL «Ion»?"), deși sună mai bine.
   Ar trebui să vină din `P31`, iar `P31` la opere e o mlaștină: „operă literară",
   „operă scrisă", „roman", „ciclu de romane", „tragedie", uneori toate deodată.
   Un cuvânt de fel greșit nu e o stângăcie, e o GREȘEALĂ DE FAPT predată de un
   joc de învățare. Formularea neutră e mereu corectă. `--masoara` tipărește
   distribuția `P31`, ca să se poată decide altă dată în cunoștință de cauză.

4. COLOANELE DE MÂNĂ NU MAI STAU ÎN COD, stau în `tools/fabrica/date/`. La
   elemente stau încă în `ALESE`; se mută la al treilea tabel, odată cu modulul
   comun. Până atunci, ce se repetă între cele două scripturi se repetă — o
   duplicare cunoscută, scrisă în `docs/progres.md`, nu una uitată.

5. QID-URILE NU SE SCRIU DE MÂNĂ. La elemente cheia era simbolul, tocmai ca să nu
   scrii 70 de `Q897` de mână. Aici nu există o cheie la fel de citibilă (titlurile
   NU sunt unice în Wikidata), dar nici nu e nevoie: QID-ul îl scrie `--propune`,
   omul doar copiază rândul și-i pune nivelul. `titlu` și `autor_nume` rămân
   AFIRMAȚII verificate la fiecare rulare împotriva etichetei române.

─────────────────────────────────────────────────────────────
CIORNELE

Un rând din `opere.json` cu `"ciorna": true` e o propunere neconfirmată de om.

  - rularea de probă îl ia în seamă (grila, mostrele, toate verificările);
  - `--scrie` îl LASĂ AFARĂ și raportează câte ciorne au mai rămas.

Deci nimic nu ajunge în joc înainte ca cineva să șteargă marcajul, iar până
atunci se poate vedea exact ce-ar intra dacă l-ar șterge.

Atenție la un lucru care nu e evident: ciornele nu se scot la sfârșit, se scot
ÎNAINTE de construirea întrebărilor. Distractorii se aleg dintre operele alese,
deci o ciornă lăsată în listă ar ajunge distractor într-o întrebare scrisă în
`data/`. Raportul de probă și fișierul scris pot să difere — asta E înțelesul lor:
proba arată ce-ai avea dacă ai confirma tot.

─────────────────────────────────────────────────────────────
TITLUL DE MÂNĂ

Eticheta română de la Wikidata nu e mereu titlul sub care e cunoscută opera în
România, și uneori lipsește cu totul. Atunci rândul primește
`"titlu_de_mana": true`, iar `titlu` e crezut pe cuvânt în loc să fie verificat.

Nu e o portiță: rândurile astea se TIPĂRESC toate la fiecare rulare, cu ce spune
Wikidata alături, ca diferența să se vadă. Un câmp care ocolește o verificare și
o face în tăcere e mai rău decât lipsa verificării.

─────────────────────────────────────────────────────────────
ACELEAȘI DOUĂ REGULI CA LA `da_iduri.py` ȘI `elemente.py`

STRICT: orice lucru pe care scriptul nu-l recunoaște oprește tot.

UN `id` NU SE REFOLOSEȘTE NICIODATĂ. Id-ul se calculează din QID și din sensul
relației (`wd:Q3511423:autor:cere_autor` pentru operă, `wd:Q302525:autor:cere_opera`
pentru autor), deci e același la fiecare rulare și nu depinde de ordinea din
fișier. Ce n-ai voie e să schimbi FORMA id-ului: aia rupe legătura cu orice save.
"""

import hashlib
import io
import json
import os
import random
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# Consola Windows nu e pe UTF-8 din oficiu, iar tot ce tipărim are diacritice.
if hasattr(sys.stdout, "reconfigure"):
	sys.stdout.reconfigure(encoding="utf-8")

AICI = os.path.dirname(os.path.abspath(__file__))
RADACINA = os.path.dirname(os.path.dirname(AICI))

CALE_CACHE = os.path.join(AICI, "cache", "wikidata_opere.json")
CALE_CONTACT = os.path.join(AICI, "contact.txt")

CALE_AUTORI = os.path.join(AICI, "date", "autori.json")
CALE_OPERE = os.path.join(AICI, "date", "opere.json")
CALE_PROPUSE = os.path.join(AICI, "date", "opere_propuse.json")

CALE_MANA = os.path.join(RADACINA, "data", "intrebari_trivia.json")

# DOSARUL, nu fișierul. Încărcătorul din `trivia.gd` citește tot dosarul, iar un
# tabel nou înseamnă două fișiere puse aici, zero linii de cod în joc.
DOSAR_GEN = os.path.join(RADACINA, "data", "trivia_gen")
CALE_INTREBARI = os.path.join(DOSAR_GEN, "opere_intrebari.json")
CALE_FAPTE = os.path.join(DOSAR_GEN, "opere_fapte.json")

# Aceleași șase, în aceeași ordine ca `CATEGORII` din `trivia.gd`. Scrise aici,
# nu citite din cod: raportul trebuie să arate o celulă GOALĂ dacă un domeniu
# rămâne fără întrebări, iar un raport care-și ia lista din date n-o poate face.
DOMENII = ["istorie", "geografie", "stiinta", "arta", "mitologie", "literatura"]

DOMENIU = "literatura"

ENDPOINT = "https://query.wikidata.org/sparql"

# Cele două sensuri. Numele spune ce se CERE.
#   cere_autor — se arată opera, se cer autorii.  O întrebare PER OPERĂ.
#   cere_opera — se arată autorul, se cer operele. O întrebare PER AUTOR.
SENSURI = ["cere_autor", "cere_opera"]

# Câte opere propune `--propune` pentru fiecare autor.
CATE_PROPUNERI = 20

# Ediții (`wikibase:sitelinks`) sub care o operă nici nu se cere de la Wikidata.
#
# CIFRA A FOST 5, ȘI A FOST O GREȘEALĂ CARE MERITĂ PĂSTRATĂ ÎN SCRIS. La 5, cei
# 41 de autori au dat 459 de propuneri, dintre care literatura română a rămas cu
# NOUĂ: „Ion", „Amintiri din copilărie", „Moromeții", tot Arghezi, tot Blaga,
# tot Coșbuc, tot Călinescu, tot Stănescu dispăruseră. Nu fiindcă ar fi obscure —
# fiindcă un roman românesc are articol în două-trei ediții Wikipedia, iar
# „Inferno, cântul VIII" are în șase.
#
# Deci: NUMĂRUL DE EDIȚII WIKIPEDIA MĂSOARĂ RĂSPÂNDIREA INTERNAȚIONALĂ, NU
# CELEBRITATEA ÎN ROMÂNIA. Pentru un joc scris în română, un prag pe el nu e o
# curățenie, e o ștergere — și taie exact conținutul care contează cel mai mult.
# Aceeași formă ca lecția de la elemente (unde cifra separa „real" de „ipotetic",
# nu „ușor" de „greu"): cifra separă ceva, dar nu ce credeai.
#
# Rămâne 1 — adică „există măcar un articol de Wikipedia undeva în lume". Sub
# atât nu e o operă despre care s-a scris ceva, e o intrare de catalog. Tăierea
# adevărată o face `CATE_PROPUNERI`, care ia cele mai cunoscute N ale FIECĂRUI
# autor, deci nu compară niciodată un poet român cu Shakespeare.
#
# Pragul stă în interogare, deci schimbarea lui cere `--reincarca`; cache-ul îl
# ține scris lângă răspuns.
MINIM_EDITII = 1

# Câmpurile îngăduite într-un rând din `opere.json`. Lista e închisă DINADINS:
# o cheie scrisă greșit („ciorne" în loc de „ciorna") ar însemna o ciornă care
# ajunge în joc, și nimic n-ar spune nimic.
CAMPURI_OPERA = {"qid", "titlu", "autor_nume", "nivel", "ciorna", "titlu_de_mana"}

# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
#
# Cheia e (titlu, "cere_autor") pentru sensul direct și (autor, "cere_opera")
# pentru cel invers — adică ENTITATEA întrebării, nu QID-ul. Se citește dintr-o
# privire, iar unicitatea amândurora e dovedită mai jos, în `leaga_tabelul`.
#
# Tabelul singur ar rezolva ziua de azi. De-aia există și `verifica_dublurile()`,
# care caută singură prin fișierul de mână și OPREȘTE scriptul dacă găsește una
# nedeclarată — și invers, dacă o declarație nu mai corespunde nimănui.
# ─────────────────────────────────────────────────────────────
DUBLURI = {
	# Sensul direct: fișierul de mână întreabă deja „cine a scris «X»?".
	("Amintiri din copilărie", "cere_autor"): "mana:0040",
	("Baltagul", "cere_autor"): "mana:0086",
	("Crimă și pedeapsă", "cere_autor"): "mana:0085",
	("Divina Comedie", "cere_autor"): "mana:0087",
	("Hamlet", "cere_autor"): "mana:0041",
	("Ion", "cere_autor"): "mana:0084",
	("Luceafărul", "cere_autor"): "mana:0039",
	("Metamorfoza", "cere_autor"): "mana:0133",
	("Micul prinț", "cere_autor"): "mana:0044",
	("Moromeții", "cere_autor"): "mana:0089",
	("Procesul", "cere_autor"): "mana:0133",
	("Robinson Crusoe", "cere_autor"): "mana:0042",
	("Romeo și Julieta", "cere_autor"): "mana:0041",
	("Ultima noapte de dragoste, întâia noapte de război", "cere_autor"): "mana:0130",
	("Un veac de singurătate", "cere_autor"): "mana:0131",

	# Sensul invers, o singură dată: „Ce roman al lui Jules Verne pornește de la
	# un pariu al lui Phileas Fogg?" e, în fond, „care operă e a lui Verne?", cu
	# un indiciu în plus. Verne rămâne fără întrebare inversă generată — și e
	# bine: cea scrisă de mână e mai bună.
	("Jules Verne", "cere_opera"): "mana:0090",
}


# ─────────────────────────────────────────────────────────────
# LIMBILE, NORMALIZATE
#
# Wikidata deosebește lucruri pe care distractorii n-au niciun motiv să le
# deosebească. Dickens și Orwell scriu în „engleza britanică" (Q7979), Twain în
# „American English" (Q7976), Shakespeare în „engleza modernă timpurie"
# (Q1472196), Austen și Christie în „engleză" (Q1860) — patru cutii pentru
# aceeași limbă. Rezultatul, până la tabelul ăsta: „Cine a scris «Persuasiune»?"
# primea un distractor român, fiindcă Dickens nu se potrivea cu Austen.
#
# Ce se mapează sunt variante ale ACELEIAȘI limbi (istorice sau regionale), nu
# limbi înrudite: „portugheza" nu devine „spaniolă", oricât ar semăna.
LIMBI_INRUDITE = {
	"Q7979": "Q1860",       # engleza britanică        → engleză
	"Q7976": "Q1860",       # American English         → engleză
	"Q1472196": "Q1860",    # engleza modernă timpurie → engleză
	"Q5364419": "Q1321",    # Early Modern Spanish     → spaniolă
	"Q56649449": "Q1321",   # Latin American Spanish   → spaniolă
	"Q1990745": "Q652",     # toscana                  → italiană
	"Q21550769": "Q652",    # italiana medievală       → italiană
	"Q1163234": "Q397",     # latina medievală         → latină
	"Q1248221": "Q397",     # neolatina                → latină
	"Q990062": "Q35497",    # greaca homerică          → greacă veche
	"Q258318": "Q188",      # German Standard German   → germană
	"Q1473289": "Q150",     # franceza medie           → franceză
}

# Limbi INVENTATE, care nu spun nimic despre autor. Novlimba e limba din „1984",
# nu o limbă în care scrie Orwell; la fel quenya și sindarina la Tolkien. Fără
# lista asta, Orwell și Tolkien ar fi „de aceeași limbă" cu nimeni și cu ei
# înșiși.
LIMBI_INVENTATE = {"Q654101", "Q56383", "Q56437"}


def limba_curata(qiduri):
	"""Un set de limbi, cu variantele contopite și cele inventate scoase."""
	iesite = set()
	for q in qiduri:
		if q in LIMBI_INVENTATE or q == "?":
			continue
		iesite.add(LIMBI_INRUDITE.get(q, q))
	return iesite


class Eroare(Exception):
	"""Ceva ce scriptul nu recunoaște. Oprește tot, nu se sare peste."""


# ─────────────────────────────────────────────────────────────
# FIȘIERE
# ─────────────────────────────────────────────────────────────

def citeste_json(cale, ce):
	if not os.path.exists(cale):
		raise Eroare("lipsește %s (%s)" % (os.path.relpath(cale, RADACINA), ce))
	with io.open(cale, encoding="utf-8") as f:
		try:
			return json.load(f)
		except ValueError as e:
			raise Eroare("%s nu e JSON valid: %s" % (os.path.relpath(cale, RADACINA), e))


def citeste_lista(cale, ce="listă"):
	date = citeste_json(cale, ce)
	if not isinstance(date, list):
		raise Eroare("%s nu conține o listă" % os.path.relpath(cale, RADACINA))
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
	de linii, cu diff-uri pe care nu le mai poți citi.
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
	per operă ar face 700 de rânduri dintr-un tabel de 140.
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


# ─────────────────────────────────────────────────────────────
# REȚEAUA
# ─────────────────────────────────────────────────────────────

def contactul():
	"""Adresa de contact pentru User-Agent. NU stă în cod.

	Wikimedia cere un User-Agent descriptiv, cu un om de contact. Corect — dar
	adresa nu are ce căuta într-un fișier comis în Git, deci se citește din afară:

	    MINDKEEP_CONTACT=cineva@exemplu.ro python tools/fabrica/opere.py --reincarca

	sau se scrie o dată în `tools/fabrica/contact.txt`, care e în `.gitignore`.

	Cerută DOAR când se atinge rețeaua. O rulare din cache nu are nevoie de nimic.
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
		% os.path.relpath(CALE_CONTACT, RADACINA)
	)


def interogheaza(interogare, ce):
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
	print("    întreb Wikidata: %s…" % ce)
	try:
		with urllib.request.urlopen(cerere, timeout=180) as raspuns:
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


def legaturi(raspuns):
	return raspuns.get("results", {}).get("bindings", [])


def qid_din(uri):
	q = uri.rsplit("/", 1)[-1]
	if not re.fullmatch(r"Q\d+", q):
		raise Eroare("URI pe care nu-l recunosc: %r" % uri)
	return q


# ─────────────────────────────────────────────────────────────
# INTEROGĂRILE
# ─────────────────────────────────────────────────────────────

def interogare_autori(nume, prin_alias):
	"""Numele → oameni. Potrivește eticheta sau, la a doua trecere, aliasul.

	DOUĂ TRECERI, NU UN `UNION`. Prima variantă cerea eticheta SAU aliasul într-un
	singur `UNION`, pentru toate cele 41 de nume deodată. Wikidata a răspuns 504:
	potrivirea pe `skos:altLabel` peste zeci de literali e scumpă, fiindcă un om
	celebru are sute de alias-uri, în toate limbile.

	Deci: întâi etichetele (ieftin, rezolvă aproape tot), apoi alias-urile, DOAR
	pentru numele rămase. Aliasul e trapa de scăpare pentru transliterări —
	„Feodor Dostoievski" și „Fiodor Dostoievski" sunt același om, iar care dintre
	ele e eticheta oficială la Wikidata se schimbă de la o lună la alta.

	`P31 wd:Q5` (e om) plus `EXISTS { ?ceva wdt:P50 ?autor }` (are măcar o operă)
	taie omonimiile care n-au ce căuta aici: comune, filme, trupe, omonimi fără
	nicio scriere.
	"""
	valori = " ".join('"%s"@ro "%s"@en "%s"@mul' % ((n.replace('"', '\\"'),) * 3)
	                  for n in nume)
	potrivirea = ("?autor skos:altLabel ?cautat . BIND(\"alias\" AS ?fel)" if prin_alias
	              else "?autor rdfs:label ?cautat . BIND(\"etichetă\" AS ?fel)")
	return """
SELECT ?autor ?cautat ?fel ?eticheta ?descriere ?nastere ?moarte ?limba ?limba_nativa WHERE {
  VALUES ?cautat { %s }
  %s
  ?autor wdt:P31 ?fel_de_om .
  VALUES ?fel_de_om { wd:Q5 wd:Q21070568 }
  FILTER EXISTS { ?ceva wdt:P50 ?autor }
  OPTIONAL { ?autor rdfs:label ?eticheta . FILTER(lang(?eticheta) IN ("ro", "mul")) }
  OPTIONAL { ?autor schema:description ?descriere . FILTER(lang(?descriere) = "ro") }
  OPTIONAL { ?autor wdt:P569 ?data_n . BIND(YEAR(?data_n) AS ?nastere) }
  OPTIONAL { ?autor wdt:P570 ?data_m . BIND(YEAR(?data_m) AS ?moarte) }
  OPTIONAL { ?autor wdt:P6886 ?limba . }
  OPTIONAL { ?autor wdt:P103 ?limba_nativa . }
}
""" % (valori, potrivirea)


def interogare_opere(qiduri):
	"""Operele unui grup de autori, cu TOȚI autorii fiecăreia.

	`?opera wdt:P50 ?autor` apare de DOUĂ ori dinadins: o dată legat de autorul
	cerut (ca să iasă doar operele lui), o dată liber (ca să vină TOȚI autorii
	operei). A doua e ce face posibilă regula „exact una din patru e corectă":
	fără ea, un roman scris în doi ar arăta ca scris de unul singur.

	EDIȚIILE NU SE SCOT DIN INTEROGARE, deși ar părea firesc. Prima versiune avea
	`FILTER NOT EXISTS { ?opera wdt:P31 wd:Q3331189 }`, ca să nu apară „Ion (ediția
	din 1920)" ca operă distinctă cu același titlu. Filtrul a șters „Ion" al lui
	Rebreanu cu totul: articolul de pe Wikipedia în română e legat de un item
	catalogat ca EDIȚIE (`Q12730777`), nu ca operă, iar itemul-operă ori nu există,
	ori n-are autor. Nu e o excepție — multe articole de literatură română de pe
	ro.wikipedia stau așa.

	Deci regula e alta, și e cea corectă: o ediție se scoate DOAR dacă e ediția
	unei opere pe care o avem deja (`P629` duce la un QID din mulțime). O ediție
	care stă singură e singura reprezentare a cărții, deci rămâne. Vezi
	`scoate_editiile_duble`.

	DE CE `GROUP_CONCAT` ȘI NU RÂNDURI SIMPLE. O operă are mai mulți autori, mai
	multe tipuri, mai multe limbi și mai mulți ani de publicare; cerute simplu,
	SPARQL întoarce produsul lor cartezian — o carte cu 2 autori, 3 tipuri și 2 ani
	vine pe 12 rânduri identice în rest. Prima versiune a scos un cache de 5 MB
	pentru 3000 de opere. Cu `GROUP_CONCAT`, un rând per operă.

	Contează fiindcă acest cache se COMITE ÎN GIT: 5 MB la fiecare `--reincarca`
	ar umfla repo-ul cu fiecare autor adăugat. Răspunsul rămâne brut, neprelucrat —
	doar cerut mai deștept.

	Se cer doar operele care au MĂCAR O ETICHETĂ în română, engleză sau `mul`.
	Fără filtrul ăsta, cei 41 de autori aduc 8700 de itemi fără nicio etichetă —
	ediții, manuscrise, fragmente de catalog — care nu pot fi nici alese, nici
	măcar citite, dar care umflă cache-ul comis în Git de la 3 la 8,6 MB.

	Etichetele pentru tip și limbă NU se cer aici. Se iau la sfârșit, într-o
	interogare mică, pentru QID-urile care chiar au apărut.
	"""
	valori = " ".join("wd:%s" % q for q in qiduri)
	return """
SELECT ?opera ?titlu_ro ?titlu_mul ?titlu_en ?editii
       (MIN(?an_unul) AS ?an)
       (GROUP_CONCAT(DISTINCT STR(?autor); SEPARATOR=" ") AS ?autori)
       (GROUP_CONCAT(DISTINCT STR(?tip); SEPARATOR=" ") AS ?tipuri)
       (GROUP_CONCAT(DISTINCT STR(?limba); SEPARATOR=" ") AS ?limbi)
       (GROUP_CONCAT(DISTINCT STR(?opera_mama); SEPARATOR=" ") AS ?mame)
WHERE {
  VALUES ?cerut { %s }
  ?opera wdt:P50 ?cerut .
  ?opera wikibase:sitelinks ?editii .
  FILTER(?editii >= %d)
  FILTER EXISTS { ?opera rdfs:label ?oricare . FILTER(lang(?oricare) IN ("ro", "mul", "en")) }
  ?opera wdt:P50 ?autor .
  OPTIONAL { ?opera rdfs:label ?titlu_ro . FILTER(lang(?titlu_ro) = "ro") }
  OPTIONAL { ?opera rdfs:label ?titlu_mul . FILTER(lang(?titlu_mul) = "mul") }
  OPTIONAL { ?opera rdfs:label ?titlu_en . FILTER(lang(?titlu_en) = "en") }
  OPTIONAL { ?opera wdt:P31 ?tip . }
  OPTIONAL { ?opera wdt:P407 ?limba . }
  OPTIONAL { ?opera wdt:P577 ?data . BIND(YEAR(?data) AS ?an_unul) }
  OPTIONAL { ?opera wdt:P629 ?opera_mama . }
}
GROUP BY ?opera ?titlu_ro ?titlu_mul ?titlu_en ?editii
""" % (valori, MINIM_EDITII)


def interogare_etichete(qiduri):
	valori = " ".join("wd:%s" % q for q in qiduri)
	return """
SELECT ?x ?ro ?en WHERE {
  VALUES ?x { %s }
  OPTIONAL { ?x rdfs:label ?ro . FILTER(lang(?ro) IN ("ro", "mul")) }
  OPTIONAL { ?x rdfs:label ?en . FILTER(lang(?en) = "en") }
}
""" % valori


# ─────────────────────────────────────────────────────────────
# CACHE-UL
#
# Comis în Git, ca la elemente: Wikidata se editează, iar diferența trebuie
# văzută CÂND O CER (`--reincarca`), nu să apară singură într-un diff din `data/`.
#
# Ce e în plus față de elemente: cache-ul ține și PENTRU CE a fost luat — lista
# de nume și mulțimea de QID-uri. Fără asta, adaugi un autor în `autori.json`,
# uiți `--reincarca`, iar scriptul generează liniștit fără el. O ipoteză tăcută
# care se vede abia peste trei luni, într-o grilă care nu crește.
# ─────────────────────────────────────────────────────────────

def ia_datele(reincarca, nume_autori):
	if not reincarca and os.path.exists(CALE_CACHE):
		with io.open(CALE_CACHE, encoding="utf-8") as f:
			pachet = json.load(f)
		print("  Cache: %s (luat la %s)" % (
			os.path.relpath(CALE_CACHE, RADACINA), pachet.get("luat_la", "?")))
		if int(pachet.get("minim_editii", -1)) != MINIM_EDITII:
			raise Eroare(
				"cache-ul e luat cu pragul de %s ediții, iar acum MINIM_EDITII e %d.\n"
				"  Pragul stă în interogare, deci schimbarea lui cere --reincarca."
				% (pachet.get("minim_editii", "?"), MINIM_EDITII))
		vechi = list(pachet.get("pentru_nume", []))
		if vechi != list(nume_autori):
			lipsa = [n for n in nume_autori if n not in vechi]
			scoși = [n for n in vechi if n not in nume_autori]
			raise Eroare(
				"cache-ul e luat pentru altă listă de autori.\n"
				"  în plus în autori.json: %s\n"
				"  scoși din autori.json: %s\n"
				"  Rulează cu --reincarca."
				% (", ".join(lipsa) or "—", ", ".join(scoși) or "—"))
		return pachet

	print("  Reîncarc din rețea.")
	# Prima trecere: etichetele, pe bucăți de câte 12 nume.
	raspunsuri_autori = []
	gasite = set()
	for i in range(0, len(nume_autori), 12):
		grup = nume_autori[i:i + 12]
		r = interogheaza(interogare_autori(grup, False),
		                 "autorii, etichete (%d-%d)" % (i + 1, i + len(grup)))
		raspunsuri_autori.append(r)
		gasite |= {b["cautat"]["value"] for b in legaturi(r)}

	# A doua trecere: alias-urile, DOAR pentru numele pe care etichetele nu le-au
	# găsit. Scump, deci se plătește numai unde e nevoie.
	ramase = [n for n in nume_autori if n not in gasite]
	for i in range(0, len(ramase), 6):
		grup = ramase[i:i + 6]
		raspunsuri_autori.append(interogheaza(
			interogare_autori(grup, True), "autorii, alias-uri (%s)" % ", ".join(grup)))

	# Autorii rezolvați ACUM, ca să știm pentru cine cerem operele. Rezolvarea e
	# oricum verificată mai jos, pe datele din cache — aici e doar ca să se poată
	# compune a doua interogare.
	qiduri = sorted({qid_din(r["autor"]["value"])
	                 for raspuns in raspunsuri_autori for r in legaturi(raspuns)})
	if not qiduri:
		raise Eroare("niciun autor găsit pentru lista dată. Numele sunt scrise corect?")

	# Pe bucăți de câte cinci autori. Shakespeare singur are sute de itemi legați
	# prin P50; toți 41 deodată ar putea trece de cele 60 de secunde ale
	# endpointului, iar un timeout la jumătatea listei e cel mai prost fel de eșec:
	# pare o listă scurtă, nu o eroare.
	bucati = []
	for i in range(0, len(qiduri), 5):
		grup = qiduri[i:i + 5]
		bucati.append(interogheaza(interogare_opere(grup),
		                           "operele (%d-%d din %d)" % (i + 1, i + len(grup), len(qiduri))))

	# Etichetele pentru tipuri și limbi, o singură dată, pentru ce a apărut.
	de_etichetat = set()
	for b in bucati:
		for r in legaturi(b):
			for camp in ("tipuri", "limbi"):
				de_etichetat |= {q for q in _multe(r, camp) if q != "?"}
	etichete = []
	lista_et = sorted(de_etichetat)
	for i in range(0, len(lista_et), 300):
		etichete.append(interogheaza(interogare_etichete(lista_et[i:i + 300]),
		                             "etichetele (%d)" % len(lista_et[i:i + 300])))

	pachet = {
		"luat_la": time.strftime("%Y-%m-%dT%H:%M:%S"),
		"endpoint": ENDPOINT,
		"pentru_nume": list(nume_autori),
		"minim_editii": MINIM_EDITII,
		"autori": raspunsuri_autori,
		"opere": bucati,
		"etichete": etichete,
	}
	os.makedirs(os.path.dirname(CALE_CACHE), exist_ok=True)
	with io.open(CALE_CACHE, "w", encoding="utf-8", newline="\n") as f:
		json.dump(pachet, f, ensure_ascii=False, indent="\t", sort_keys=True)
		f.write("\n")
	print("  Scris cache: %s (%.1f MB)" % (
		os.path.relpath(CALE_CACHE, RADACINA),
		os.path.getsize(CALE_CACHE) / 1048576.0))
	return pachet


# ─────────────────────────────────────────────────────────────
# CITIREA RĂSPUNSURILOR
# ─────────────────────────────────────────────────────────────

def desfa_etichetele(pachet):
	et = {}
	for raspuns in pachet.get("etichete", []):
		for r in legaturi(raspuns):
			q = qid_din(r["x"]["value"])
			et[q] = {
				"ro": r["ro"]["value"] if "ro" in r else None,
				"en": r["en"]["value"] if "en" in r else None,
			}
	return et


def rezolva_autorii(pachet, nume_autori):
	"""Numele din `autori.json` → un autor și numai unul. Strict.

	Un nume care iese ambiguu sau negăsit OPREȘTE tot. N-am voie să „aleg cel mai
	probabil": un QID greșit leagă întrebarea de alt om, iar nicio validare n-ar
	prinde-o — omul există, opera există, legătura e doar falsă. Exact greșeala
	pentru care `elemente.py` refuză QID-urile scrise de mână.
	"""
	pe_nume = {}
	randuri = []
	for raspuns in pachet["autori"]:
		randuri.extend(legaturi(raspuns))
	for r in randuri:
		cautat = r["cautat"]["value"]
		qid = qid_din(r["autor"]["value"])
		a = pe_nume.setdefault(cautat, {}).setdefault(qid, {
			"qid": qid,
			"feluri": set(),
			"eticheta": None,
			"descriere": None,
			"nastere": None,
			"moarte": None,
			"limbi": set(),
			"limbi_native": set(),
		})
		a["feluri"].add(r["fel"]["value"])
		if "eticheta" in r:
			a["eticheta"] = r["eticheta"]["value"]
		if "descriere" in r:
			a["descriere"] = r["descriere"]["value"]
		for camp in ("nastere", "moarte"):
			if camp in r:
				a[camp] = int(float(r[camp]["value"]))
		if "limba" in r:
			a["limbi"].add(qid_din(r["limba"]["value"]))
		if "limba_nativa" in r:
			a["limbi_native"].add(qid_din(r["limba_nativa"]["value"]))

	probleme = []
	autori = []
	for nume in nume_autori:
		gasiti = pe_nume.get(nume, {})
		if not gasiti:
			probleme.append("%s: niciun om cu numele ăsta care să aibă opere" % nume)
			continue
		if len(gasiti) > 1:
			lista = "; ".join(
				"%s (%s)" % (q, a["descriere"] or a["eticheta"] or "fără descriere")
				for q, a in sorted(gasiti.items()))
			probleme.append("%s: mai mulți candidați — %s" % (nume, lista))
			continue
		a = list(gasiti.values())[0]
		a["cautat"] = nume
		# Numele AFIȘAT în joc e cel din `autori.json`, nu eticheta de la Wikidata.
		# Wikidata scrie „Ion Luca Caragiale"; un jucător român citește „I. L.
		# Caragiale" la fel de bine, iar alegerea felului în care se scrie un nume
		# pe un buton e o decizie de joc, nu un fapt.
		a["nume"] = nume
		autori.append(a)

	if probleme:
		raise Eroare("autori pe care nu-i pot rezolva:\n  - " + "\n  - ".join(probleme)
		             + "\n  Scrie numele exact ca la Wikidata, sau scoate-l din listă.")

	# Doi autori care s-au rezolvat la același om: „Voltaire" și „François-Marie
	# Arouet" ar fi două rânduri pentru un singur QID, deci două întrebări inverse
	# identice.
	pe_qid = {}
	for a in autori:
		pe_qid.setdefault(a["qid"], []).append(a["nume"])
	ciocniri = {q: n for q, n in pe_qid.items() if len(n) > 1}
	if ciocniri:
		raise Eroare("nume diferite care duc la același om:\n  - " + "\n  - ".join(
			"%s → %s" % (q, ", ".join(n)) for q, n in sorted(ciocniri.items())))

	return autori


def qid_sau_nimic(uri):
	"""QID-ul dintr-un URI, sau `None` dacă e un nod anonim.

	NODURILE ANONIME SUNT „VALOARE NECUNOSCUTĂ", ȘI EXACT ELE NE INTERESEAZĂ.
	Wikidata poate spune „această operă ARE un autor, dar nu se știe cine" —
	`somevalue` —, iar SPARQL îl întoarce ca `…/.well-known/genid/1986ff00…`.
	Prima versiune a scriptului s-a oprit cu „URI pe care nu-l recunosc", ceea ce
	a fost, din întâmplare, cel mai bun lucru care se putea întâmpla: e chiar
	cazul operelor anonime și populare, pe care regula ta le scoate.

	Deci nu se sare peste el în tăcere. Pentru autori se păstrează ca `?`, adică
	„un autor, dar nu se știe care" — și așa o operă scrisă de cineva cunoscut
	ÎMPREUNĂ cu un anonim are doi autori și pică regula unui singur autor, cum se
	cuvine. Pentru tipuri și limbi n-are ce spune, deci se lasă deoparte.
	"""
	q = uri.rsplit("/", 1)[-1]
	if re.fullmatch(r"Q\d+", q):
		return q
	if "/.well-known/genid/" in uri:
		return None
	raise Eroare("URI pe care nu-l recunosc: %r" % uri)


def _multe(rand, camp):
	"""Un `GROUP_CONCAT` desfăcut în QID-uri, cu nodurile anonime ca `?`."""
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


def scoate_editiile_duble(opere):
	"""Scoate din mulțime edițiile care dublează o operă pe care o avem deja.

	`P629` („ediție a") duce de la ediție la operă. Dacă opera-mamă e și ea în
	mulțime, ediția e un duplicat curat: același titlu, același autor, două
	rânduri. Dacă opera-mamă NU e în mulțime, ediția e singura reprezentare a
	cărții și rămâne — vezi „Ion" al lui Rebreanu, în comentariul interogării.

	Ce NU face: nu se uită la `P31`. O ediție care stă singură e o carte, oricât
	de nefericit ar fi catalogată; iar o operă care are ediții nu e o ediție.
	"""
	de_scos = [q for q, o in opere.items() if o["mame"] & set(opere)]
	for q in de_scos:
		del opere[q]
	return len(de_scos)


def imbogateste_limbile(autori, opere):
	"""Limba fiecărui autor: limba în care e scrisă MAJORITATEA cărților lui.

	DE CE SE NUMĂRĂ CĂRȚILE ȘI NU SE CITEȘTE CÂMPUL. Wikidata are un câmp exact
	pentru asta, `P6886` („limba în care scrie"), și la prima vedere e răspunsul.
	Dar el e o listă, nu o limbă: Eminescu are acolo „germană" și „română", Twain
	„engleză" și „germană", Tolstoi „franceză" și „rusă". Toate adevărate, și
	toate egale — iar din egalitatea asta ieșeau întrebări ca „Cine a scris
	«Faust»?" cu Twain și Eminescu printre distractori, fiindcă și ei „scriu în
	germană".

	Cărțile rezolvă fără să judece nimeni: Twain are 72 de cărți în engleză și
	niciuna în germană. Deci limba unui autor e cea a majorității operelor lui
	din Wikidata (toate, nu doar cele alese), cu variantele contopite mai întâi —
	vezi `LIMBI_INRUDITE`, fără de care engleza lui Dickens și engleza lui Austen
	sunt limbi diferite.

	`P6886` și `P103` rămân rezervă, pentru autorii ale căror opere n-au limbă în
	Wikidata. Cine n-are nici atât (azi: Arghezi și Blaga) nu primește niciodată
	bonusul de limbă. E cinstit: mai bine o întrebare fără o însușire decât o
	însușire inventată.
	"""
	numarate = {}
	for o in opere.values():
		for q in o["autori"]:
			if q == "?":
				continue
			c = numarate.setdefault(q, {})
			for limba in limba_curata(o["limbi"]):
				c[limba] = c.get(limba, 0) + 1

	for a in autori:
		c = numarate.get(a["qid"], {})
		if c:
			# Nu doar cea mai deasă: și cele care ajung măcar la jumătatea ei.
			# Un autor cu adevărat bilingv (jumătate din cărți într-o limbă) le
			# păstrează pe amândouă; una din zece nu.
			varf = max(c.values())
			a["limbi_sigure"] = {q for q, n in c.items() if n * 2 >= varf}
		else:
			a["limbi_sigure"] = (limba_curata(a["limbi"])
			                     or limba_curata(a["limbi_native"]))
	return autori


def desfa_operele(pachet):
	"""Rândurile SPARQL → un dicționar QID → operă, cu TOȚI autorii ei."""
	opere = {}
	for raspuns in pachet["opere"]:
		for r in legaturi(raspuns):
			qid = qid_din(r["opera"]["value"])
			o = opere.setdefault(qid, {
				"qid": qid,
				"titlu_ro": None,
				"titlu_mul": None,
				"titlu_en": None,
				"editii": 0,
				"autori": set(),
				"tipuri": set(),
				"limbi": set(),
				"mame": set(),
				"an": None,
			})
			o["editii"] = max(o["editii"], int(r["editii"]["value"]))
			o["autori"] |= _multe(r, "autori")
			o["tipuri"] |= {t for t in _multe(r, "tipuri") if t != "?"}
			o["limbi"] |= {l for l in _multe(r, "limbi") if l != "?"}
			o["mame"] |= {m for m in _multe(r, "mame") if m != "?"}
			for camp in ("titlu_ro", "titlu_mul", "titlu_en"):
				if camp in r and r[camp]["value"].strip():
					o[camp] = r[camp]["value"].strip()
			if "an" in r:
				# Anul operei = CEL MAI VECHI an de publicare, luat cu `MIN` chiar
				# în interogare. Wikidata ține și reeditări la `P577`; „Ion, 1920"
				# și „Ion, 1993" sunt aceeași carte, iar perioada ei e prima.
				an = int(float(r["an"]["value"]))
				o["an"] = an if o["an"] is None else min(o["an"], an)

	scoate_editiile_duble(opere)

	for o in opere.values():
		# ETICHETA `mul`, ȘI DE CE E CA ȘI CUM AR FI ROMÂNEASCĂ.
		#
		# Wikidata a început să mute etichetele care sunt LA FEL în toate limbile
		# într-o limbă specială, `mul`. Victor Hugo n-are etichetă „en" și n-are
		# etichetă „ro": are una singură, `mul`, fiindcă numele lui se scrie la fel
		# peste tot. Prima versiune a scriptului a căzut exact aici — „Victor Hugo:
		# niciun om cu numele ăsta".
		#
		# Deci `mul` NU e o lipsă, e opusul: e afirmația explicită că eticheta e
		# aceeași și în română. Se ia ca titlu românesc, dar se NUMĂRĂ separat în
		# `--masoara`, ca să se vadă din ce vine fiecare.
		if not o["titlu_ro"] and o["titlu_mul"]:
			o["titlu_ro"] = o["titlu_mul"]
	return opere


# ─────────────────────────────────────────────────────────────
# PROPUNERILE
# ─────────────────────────────────────────────────────────────

def propune(autori, opere, etichete, alese_deja):
	"""Scrie `date/opere_propuse.json`: ce-ar putea intra, ca omul să aleagă.

	Scriptul NU scrie niciodată în `opere.json`. Un script care fuzionează în
	fișierul unde stă judecata omului e un script care într-o zi îi șterge
	judecata — aceeași logică pentru care `intrebari_trivia.json` nu e atins de
	nimic.

	Ce se lasă afară, și de ce:
	  - operele deja alese (altfel lista crește la fiecare rulare cu ce-ai ales deja);
	  - operele cu mai mulți autori (regula ta: nu intră);
	  - operele fără nicio etichetă, ro sau en (n-ai ce citi ca să le judeci).

	Pragul de ediții nu se aplică aici: e deja în interogare, vezi `MINIM_EDITII`.
	"""
	pe_autor = {a["qid"]: a for a in autori}
	propuneri = []
	sarite = {"alese": 0, "mai_multi_autori": 0, "fara_eticheta": 0}

	for o in opere.values():
		if o["qid"] in alese_deja:
			sarite["alese"] += 1
			continue
		if len(o["autori"]) != 1:
			sarite["mai_multi_autori"] += 1
			continue
		if not o["titlu_ro"] and not o["titlu_en"]:
			sarite["fara_eticheta"] += 1
			continue
		autor = pe_autor.get(list(o["autori"])[0])
		if autor is None:
			continue
		propuneri.append({
			"qid": o["qid"],
			"titlu": o["titlu_ro"] or "",
			"titlu_en": o["titlu_en"] or "",
			"autor_nume": autor["nume"],
			"tip": ", ".join(sorted(
				(etichete.get(t, {}).get("ro") or etichete.get(t, {}).get("en") or t)
				for t in o["tipuri"])),
			"an": o["an"] if o["an"] is not None else 0,
			"editii": o["editii"],
			"nivel": 0,
		})

	# Ordinea: autorii ca în `autori.json` (adică grupați cum i-a grupat omul),
	# iar în cadrul unui autor, cele mai cunoscute întâi.
	rang = {a["nume"]: i for i, a in enumerate(autori)}
	propuneri.sort(key=lambda p: (rang[p["autor_nume"]], -p["editii"], p["qid"]))

	# Cele mai cunoscute `CATE_PROPUNERI` pe autor. Restul e coadă lungă: ediții
	# critice, povestiri de cinci pagini, fragmente. Dacă lipsește ceva anume, se
	# ridică cifra.
	taiate = []
	cate = {}
	for p in propuneri:
		cate[p["autor_nume"]] = cate.get(p["autor_nume"], 0) + 1
		if cate[p["autor_nume"]] <= CATE_PROPUNERI:
			taiate.append(p)

	scrie_pe_rand(CALE_PROPUSE, taiate,
	              ["qid", "titlu", "titlu_en", "autor_nume", "tip", "an", "editii", "nivel"],
	              "autor_nume")
	print("\n  ── PROPUNERI ──")
	print("    scris: %s" % os.path.relpath(CALE_PROPUSE, RADACINA))
	print("    %d opere propuse, %d pe autor cel mult" % (len(taiate), CATE_PROPUNERI))
	print("    lăsate afară: %d deja alese, %d cu mai mulți autori (sau cu autor "
	      "necunoscut), %d fără etichetă" % (sarite["alese"], sarite["mai_multi_autori"],
	                                         sarite["fara_eticheta"]))
	print("    Copiază rândurile pe care le vrei în %s, pune-le nivelul (1/2/3)"
	      % os.path.relpath(CALE_OPERE, RADACINA))
	print("    și marchează-le \"ciorna\": true cât timp nu sunt confirmate.")
	return taiate


# ─────────────────────────────────────────────────────────────
# MĂSURĂTOAREA
# ─────────────────────────────────────────────────────────────

def decile(valori):
	v = sorted(valori)
	if not v:
		return "—"
	return "  ".join("%4d" % v[min(len(v) - 1, int(len(v) * k / 10))] for k in range(10))


def masoara(autori, opere, etichete, lista):
	"""Ce se poate afla din date, înainte să se aleagă ceva.

	Rostul funcției e să DOVEDEASCĂ, nu să presupună. La elemente a dovedit că
	numărul de ediții Wikipedia NU deosebește elementele celebre de cele obscure
	(toate au articol pe wiki-urile mici, generat de boți). Întrebarea de azi e
	dacă la opere se poartă altfel.
	"""
	print("\n  ── AUTORII ──")
	prin_alias = [a for a in autori if "etichetă" not in a["feluri"]]
	print("    %d rezolvați, %d numai prin alias%s" % (
		len(autori), len(prin_alias),
		(" (%s)" % ", ".join(a["nume"] for a in prin_alias)) if prin_alias else ""))
	fara_limba = [a["nume"] for a in autori if not a["limbi_sigure"]]
	if fara_limba:
		print("    fără nicio limbă în Wikidata (nici P6886, nici P103, nici pe opere): %s"
		      % ", ".join(fara_limba))

	print("\n  ── CE A VENIT DIN WIKIDATA ──")
	print("    %d opere legate de cei %d autori" % (len(opere), len(autori)))
	cu_ro = sum(1 for o in opere.values() if o["titlu_ro"])
	multi = sum(1 for o in opere.values() if len(o["autori"]) != 1)
	print("    cu etichetă română: %d (%.0f%%)   cu alt număr de autori decât unul: %d"
	      % (cu_ro, 100.0 * cu_ro / max(1, len(opere)), multi))
	cu_an = sum(1 for o in opere.values() if o["an"])
	cu_limba = sum(1 for o in opere.values() if o["limbi"])
	print("    cu an de publicare: %d (%.0f%%)   cu limbă: %d (%.0f%%)"
	      % (cu_an, 100.0 * cu_an / max(1, len(opere)),
	         cu_limba, 100.0 * cu_limba / max(1, len(opere))))

	# `P31`: DE CE NU SE SPUNE FELUL OPEREI ÎN ÎNTREBARE. Cifrele de aici sunt
	# argumentul, nu o presupunere.
	print("\n  ── TIPURILE (P31), cele mai dese ──")
	cate_tip = {}
	for o in opere.values():
		for t in o["tipuri"]:
			cate_tip[t] = cate_tip.get(t, 0) + 1
	for t, n in sorted(cate_tip.items(), key=lambda x: -x[1])[:12]:
		nume = etichete.get(t, {}).get("ro") or etichete.get(t, {}).get("en") or t
		print("      %4d  %s" % (n, nume))
	fara_tip = sum(1 for o in opere.values() if not o["tipuri"])
	mai_multe = sum(1 for o in opere.values() if len(o["tipuri"]) > 1)
	print("      %d opere fără niciun tip, %d cu mai multe deodată"
	      % (fara_tip, mai_multe))
	print("      → de-aia întrebarea NU spune felul operei: „roman\" ar fi o")
	print("        afirmație în plus, pe care datele n-o susțin curat.")

	print("\n  ── EDIȚIILE WIKIPEDIA: SEPARĂ CEVA? ──")
	toate = [o["editii"] for o in opere.values()]
	print("    toate operele (%d): min %d   median %d   maxim %d" % (
		len(toate), min(toate), sorted(toate)[len(toate) // 2], max(toate)))
	print("      decile: %s" % decile(toate))
	print("    → la elemente banda era de ~1,5× între decila 1 și decila 9, fiindcă")
	print("      boții generaseră un articol pe element pe fiecare wiki mic. Aici")
	print("      nu există boți, deci banda arată altfel. Cifra de sus e proba.")

	if lista:
		print("\n  ── EDIȚIILE FAȚĂ DE NIVELUL PUS DE MÂNĂ ──")
		for nivel in (1, 2, 3):
			v = sorted(e["editii"] for e in lista if e["nivel"] == nivel)
			if not v:
				continue
			print("    nivelul %d (%2d opere): min %3d   median %3d   maxim %3d"
			      % (nivel, len(v), v[0], v[len(v) // 2], v[-1]))
		_cat_de_bun_ar_fi_un_prag(lista)


def _cat_de_bun_ar_fi_un_prag(lista):
	"""Cel mai bun clasificator „două praguri pe ediții" — și cât greșește.

	Asta e cifra care spune cinstit dacă nivelul ar putea fi vreodată automat.
	Caută pragurile care reproduc cel mai bine coloana de mână și raportează
	eroarea. NU schimbă nimic: decizia rămâne a omului, oricât de frumos ar ieși.
	"""
	perechi = sorted((e["editii"], e["nivel"]) for e in lista)
	valori = sorted({p[0] for p in perechi})
	if len(valori) < 3:
		return
	cel_mai_bun = None
	for i in range(len(valori)):
		for j in range(i + 1, len(valori)):
			a, b = valori[i], valori[j]
			# Mai multe ediții = mai cunoscut = nivel mai mic.
			gresite = sum(1 for ed, niv in perechi
			              if (1 if ed > b else 2 if ed > a else 3) != niv)
			if cel_mai_bun is None or gresite < cel_mai_bun[0]:
				cel_mai_bun = (gresite, a, b)
	gresite, a, b = cel_mai_bun
	print("    cel mai bun prag automat posibil: III sub %d ediții, II sub %d, I peste"
	      % (a + 1, b + 1))
	print("      ar greși %d din %d (%.0f%%). Pentru comparație, a ghici mereu"
	      % (gresite, len(perechi), 100.0 * gresite / len(perechi)))
	celmaides = max(sum(1 for e in lista if e["nivel"] == n) for n in (1, 2, 3))
	print("      nivelul cel mai des ar greși %d din %d (%.0f%%)."
	      % (len(lista) - celmaides, len(lista),
	         100.0 * (len(lista) - celmaides) / len(lista)))


# ─────────────────────────────────────────────────────────────
# TABELUL, CONFRUNTAT CU WIKIDATA
# ─────────────────────────────────────────────────────────────

def leaga_tabelul(alese, autori, opere):
	"""`opere.json` + datele de la Wikidata → lista de lucru. Strict la fiecare pas.

	Adună TOATE neconcordanțele înainte să se oprească. Un script care cade la
	prima nepotrivire te pune să rulezi de 20 de ori ca să repari 20 de rânduri.
	"""
	probleme = []
	pe_nume = {a["nume"]: a for a in autori}

	qiduri = [str(r.get("qid", "")) for r in alese]
	duble = sorted({q for q in qiduri if qiduri.count(q) > 1})
	if duble:
		probleme.append("QID-uri repetate în opere.json: %s" % ", ".join(duble))

	lista = []
	for i, rand in enumerate(alese):
		unde = "rândul %d din opere.json" % (i + 1)
		if not isinstance(rand, dict):
			probleme.append("%s nu e un obiect" % unde)
			continue
		necunoscute = sorted(set(rand) - CAMPURI_OPERA)
		if necunoscute:
			# Lista de câmpuri e închisă dinadins: „ciorne" în loc de „ciorna" ar
			# fi o ciornă care ajunge în joc, fără ca nimic să spună nimic.
			probleme.append("%s are câmpuri pe care nu le cunosc: %s"
			                % (unde, ", ".join(necunoscute)))
			continue

		qid = str(rand.get("qid", ""))
		titlu = str(rand.get("titlu", "")).strip()
		autor_nume = str(rand.get("autor_nume", "")).strip()
		nivel = rand.get("nivel")
		de_mana = bool(rand.get("titlu_de_mana", False))
		ciorna = bool(rand.get("ciorna", False))

		if not re.fullmatch(r"Q\d+", qid):
			probleme.append("%s: qid %r nu arată a QID" % (unde, qid))
			continue
		if nivel not in (1, 2, 3):
			probleme.append("%s (%s): nivelul %r nu e 1, 2 sau 3" % (unde, titlu, nivel))
			continue
		if not titlu:
			probleme.append("%s: titlu gol" % unde)
			continue
		if autor_nume not in pe_nume:
			probleme.append("%s (%s): autorul %r nu e în autori.json"
			                % (unde, titlu, autor_nume))
			continue
		o = opere.get(qid)
		if o is None:
			probleme.append("%s (%s): %s nu e printre operele autorilor din autori.json"
			                % (unde, titlu, qid))
			continue

		# OPRIREA CARE ȚINE REGULA „exact una din patru e corectă". Se face pe
		# mulțimea COMPLETĂ de autori de la Wikidata, nu pe coloana `autor_nume`:
		# dacă mâine cineva adaugă în Wikidata un al doilea autor la o operă aleasă,
		# se vede aici, la prima `--reincarca`.
		if len(o["autori"]) != 1:
			probleme.append("%s (%s): Wikidata îi dă %d autori, nu unul — nu intră"
			                % (unde, titlu, len(o["autori"])))
			continue
		autor = pe_nume[autor_nume]
		if list(o["autori"])[0] != autor["qid"]:
			probleme.append("%s (%s): în tabel scrie %s, Wikidata spune %s"
			                % (unde, titlu, autor_nume, list(o["autori"])[0]))
			continue

		# TITLUL. Fără marcaj, e o AFIRMAȚIE verificată împotriva etichetei române.
		# Cu `titlu_de_mana`, e crezut pe cuvânt — dar se tipărește la fiecare
		# rulare, alături de ce spune Wikidata (vezi `arata_titlurile_de_mana`).
		if not de_mana:
			if not o["titlu_ro"]:
				probleme.append(
					"%s (%s): Wikidata n-are etichetă română pentru %s. Dacă titlul e "
					"bun, adaugă \"titlu_de_mana\": true" % (unde, titlu, qid))
				continue
			if o["titlu_ro"].lower() != titlu.lower():
				probleme.append(
					"%s: în tabel scrie %r, Wikidata (%s) spune %r. Dacă titlul tău e cel "
					"cunoscut în română, adaugă \"titlu_de_mana\": true"
					% (unde, titlu, qid, o["titlu_ro"]))
				continue

		lista.append({
			"qid": qid,
			# Titlul vine din tabel, nu din Wikidata — spre deosebire de elemente,
			# unde numele venea de la ei. Aici coloana poate fi, dinadins, o decizie
			# („Ocolul Pământului în 80 de zile" e mai cunoscut decât ce scrie
			# eticheta), deci tabelul e sursa, iar Wikidata e verificarea.
			"titlu": titlu,
			"titlu_wd": o["titlu_ro"] or o["titlu_en"] or "",
			"titlu_de_mana": de_mana,
			"autor": autor,
			"nivel": int(nivel),
			"ciorna": ciorna,
			"editii": o["editii"],
			"an": o["an"],
			# LIMBA OPEREI E LIMBA AUTORULUI EI, nu `P407` de pe item. Vezi
			# `imbogateste_limbile` pentru de ce.
			"limbi": set(autor["limbi_sigure"]),
			"autori_wd": set(o["autori"]),
		})

	# UNICITATEA CELOR DOUĂ FEȚE. Două opere alese cu același titlu afișat ar da,
	# la sensul invers, două butoane identice — iar dacă amândouă sunt ale
	# autorului cerut, două răspunsuri corecte. Aceeași poveste pentru două nume
	# de autor identice la sensul direct. Nu e o curățenie, e chiar garanția.
	titluri = [e["titlu"] for e in lista]
	duble = sorted({t for t in titluri if titluri.count(t) > 1})
	if duble:
		probleme.append("titluri afișate identice: %s" % ", ".join(duble))

	if probleme:
		raise Eroare("opere.json nu se potrivește cu Wikidata:\n  - " + "\n  - ".join(probleme))

	# Ordinea din fișier: pe nivel, apoi pe autor, apoi pe an. Un titlu adăugat
	# mai târziu cade la locul lui, deci diff-ul din Git arată ce s-a adăugat, nu
	# o rearanjare.
	lista.sort(key=lambda e: (e["nivel"], e["autor"]["nume"], e["an"] or 9999, e["titlu"]))
	return lista


def arata_titlurile_de_mana(lista):
	"""Tipărește toate titlurile puse de mână, cu ce spune Wikidata alături.

	Rostul: un câmp care ocolește o verificare trebuie să fie ZGOMOTOS. Dacă
	`titlu_de_mana` ar trece în tăcere, ar deveni, în trei luni, felul comod de a
	face o greșeală de tipar să dispară.
	"""
	de_mana = [e for e in lista if e["titlu_de_mana"]]
	if not de_mana:
		return
	print("\n  ── TITLURI PUSE DE MÂNĂ (%d) ──" % len(de_mana))
	for e in de_mana:
		print("    %-42s  Wikidata: %s" % (e["titlu"], e["titlu_wd"] or "— (fără etichetă)"))


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

# Ghilimelele românești din fișierul scris de mână. Titlurile se caută ÎNTRE
# ghilimele, nu ca text liber: „Ion" ca text liber s-ar găsi în „Ion Creangă",
# iar jumătate din întrebările de literatură ar părea dubluri.
GHILIMELE = ("„", "”")


def verifica_dublurile(lista, intrebari_mana):
	"""Caută în fișierul scris de mână întrebări care spun deja ce vrem să generăm.

	Regula e mai precisă decât la elemente, fiindcă se uită la RĂSPUNS, nu doar la
	text:

	  dublură de sens direct  — răspunsul corect e numele unui autor ales,
	                            iar în text apare, între ghilimele, titlul unei
	                            opere alese;
	  dublură de sens invers  — răspunsul corect e titlul unei opere alese,
	                            iar în text apare numele unui autor ales.

	Uită-te la ce NU prinde regula: „Ce fel de operă literară este «Iliada»?" are
	răspunsul „Epopee", deci nu e nici una, nici alta — și corect, fiindcă e ALTĂ
	RELAȚIE. Aceeași judecată ca la elemente, unde „numărul atomic 79" nu era
	dublură pentru „simbolul aurului".
	"""
	# FĂRĂ MAJUSCULE, în amândouă direcțiile. Întrebarea `mana:0044` scrie „Micul
	# Prinț", iar titlul de la Wikidata e „Micul prinț": aceeași carte, un P mare
	# diferență. O potrivire care ține cont de majuscule ar fi lăsat dublura să
	# treacă, și ar fi ajuns în joc aceeași întrebare de două ori.
	titluri = {e["titlu"].lower(): e for e in lista}
	autori = {e["autor"]["nume"].lower(): e["autor"] for e in lista}

	gasite = {}
	aproape = []
	for q in intrebari_mana:
		text = str(q.get("text", ""))
		variante = q.get("variante", [])
		try:
			corect = str(variante[int(q.get("corect", -1))])
		except (IndexError, ValueError, TypeError):
			continue

		citate = re.findall("%s([^%s]*)%s" % (GHILIMELE[0], GHILIMELE[1], GHILIMELE[1]), text)

		if corect.lower() in autori:
			potrivite = [c for c in citate if c.lower() in titluri]
			for c in potrivite:
				gasite[(titluri[c.lower()]["titlu"], "cere_autor")] = str(q.get("id", "?"))
			if citate and not potrivite:
				aproape.append("%s  răspuns „%s\", citează %s — niciun titlu ales"
				               % (q.get("id", "?"), corect,
				                  ", ".join("„%s”" % c for c in citate)))
		if corect.lower() in titluri:
			numiti = [autori[n]["nume"] for n in autori
			          if re.search(r"\b%s\b" % re.escape(n), text.lower())]
			for n in numiti:
				gasite[(n, "cere_opera")] = str(q.get("id", "?"))
			if not numiti:
				aproape.append("%s  răspuns „%s\" e o operă aleasă, dar nu numește "
				               "niciun autor ales" % (q.get("id", "?"), corect))

	nedeclarate = sorted(k for k in gasite if k not in DUBLURI)
	if nedeclarate:
		raise Eroare(
			"întrebări scrise de mână care se suprapun cu ce generăm, nedeclarate în "
			"DUBLURI:\n" + "\n".join(
				'\t("%s", "%s"): "%s",' % (k[0], k[1], gasite[k]) for k in nedeclarate)
			+ "\n  Copiază rândurile de mai sus în DUBLURI (sau schimbă întrebarea de mână).")

	# Și invers: o declarație care nu mai corespunde nimic e la fel de rea, doar
	# mai tăcută — scoate din joc o întrebare bună fără să spună de ce.
	fantome = sorted(k for k in DUBLURI if k not in gasite)
	if fantome:
		raise Eroare(
			"DUBLURI declară suprapuneri care nu se mai găsesc în fișierul scris de "
			"mână:\n  - " + "\n  - ".join("%s / %s" % (a, b) for a, b in fantome)
			+ "\n  Dacă întrebarea de mână s-a schimbat, sau opera a ieșit din tabel, "
			"șterge rândul din DUBLURI.")

	return gasite, aproape


# ─────────────────────────────────────────────────────────────
# DISTRACTORII
# ─────────────────────────────────────────────────────────────

def zar(*bucati):
	"""Un număr stabil dintr-un text: același la fiecare rulare, pe orice mașină.

	`hash()` din Python NU e bun aici: e sărat la fiecare pornire a
	interpretorului, deci ar da alt fișier la fiecare rulare.

	DE CE E NEVOIE DE EL, și de ce nu se rup egalitățile pe QID crescător: în
	Wikidata QID-urile mici sunt exact subiectele celebre (Shakespeare e Q692).
	„La egalitate, QID-ul mai mic" l-ar pune distractor la jumătate din întrebări,
	iar „răspunsul nu e niciodată Shakespeare" e o scurtătură prin care marchezi
	puncte fără să gândești — exact ce `_amesteca` din `trivia.gd` a fost scrisă
	să închidă, reapărută pe alt drum.
	"""
	cheie = "|".join(str(b) for b in bucati).encode("utf-8")
	return int.from_bytes(hashlib.blake2b(cheie, digest_size=8).digest(), "big")


def epoca(autor, operele_lui):
	"""Anul în jurul căruia a scris un autor.

	Mijlocul vieții, când Wikidata îl are — e mai stabil decât media publicărilor,
	fiindcă `P577` lipsește la multe opere vechi. Altfel, medianul anilor operelor
	alese. Altfel, nimic, și autorul nu primește niciodată bonusul de epocă.
	"""
	if autor["nastere"] and autor["moarte"]:
		return (autor["nastere"] + autor["moarte"]) // 2
	ani = sorted(o["an"] for o in operele_lui if o["an"])
	if ani:
		return ani[len(ani) // 2]
	if autor["nastere"]:
		return autor["nastere"] + 40
	return None


def punctaj(tinta, candidat, sens):
	"""Cât de plauzibil e `candidat` ca distractor la întrebarea despre `tinta`.

	Regula pornește de la cerință: la „Cine a scris «Ion»?", alți romancieri
	români din aceeași perioadă, nu Shakespeare.

	  +100  aceeași limbă.
	  +60 / +30 / +15 / +8   la cel mult 50 / 100 / 200 / 400 de ani distanță.
	  +10/5 același nivel / nivel vecin.

	Limba întâi, epoca după: „un alt autor român" e o confuzie mai firească decât
	„un alt autor din 1920". Amândouă contează, dar nu la fel.

	DE CE TREPTE PÂNĂ LA 400 DE ANI, deși 400 nu mai e „aceeași perioadă". Nu ca
	să spună ceva despre apropiere, ci ca să RUPĂ EGALITĂȚILE CU SENS. Fără ele,
	la „Cine a scris «Decameronul»?" al treilea distractor ieșea Goethe, ales de
	`zar` dintr-o duzină de autori cu același punctaj — și nu fiindcă Goethe ar fi
	confundabil cu Boccaccio, ci fiindcă zarul trebuia să aleagă pe cineva. Cu
	treptele largi, locul trei se duce la Shakespeare sau Cervantes. Zarul rămâne
	pentru egalitățile adevărate.
	"""
	p = 0
	if tinta["limbi"] & candidat["limbi"]:
		p += 100
	if tinta["an_reper"] is not None and candidat["an_reper"] is not None:
		distanta = abs(tinta["an_reper"] - candidat["an_reper"])
		for prag, puncte in ((50, 60), (100, 30), (200, 15), (400, 8)):
			if distanta <= prag:
				p += puncte
				break
	p += 10 if candidat["nivel"] == tinta["nivel"] else 5
	return p


def alege_distractorii(tinta, candidati, sens, cheie_zar):
	"""Cei trei distractori, deterministic.

	BANDA DE NIVEL e aceeași plasă ca la elemente: toate patru opțiunile stau în
	aceeași bandă (±1), fiindcă trei nume obscure lângă unul celebru se recunosc
	fără să știi nimic. Ce e diferit aici e CE nivel se ia ca centru — al
	opțiunilor, nu al întrebării; vezi comentariul din `construieste`.

	── GARDA DE LIMBĂ, CARE A FOST SCRISĂ ȘI APOI ȘTEARSĂ ──

	Planul avea o gardă: „dacă toți trei distractorii sunt de altă limbă decât
	răspunsul, schimbă unul". Motivul era bun, și rămâne adevărat: dacă la „Cine a
	scris «Baltagul»?" distractorii sunt Kafka, Camus și Márquez, marchezi punctul
	fără să știi nimic — alegi singurul român. Spre deosebire de garda de la
	elemente (aruncată fiindcă tiparul ducea DEPARTE de răspuns), aici tiparul
	duce SPRE el, deci e o scurtătură adevărată.

	Am scris-o, am rulat-o, și a pornit de 0 ori din 188. Nu din noroc: e
	IMPOSIBIL să pornească. Un candidat de aceeași limbă ia cel puțin 100+5 = 105
	puncte, iar unul de altă limbă cel mult 60+10 = 70 — deci orice candidat de
	aceeași limbă e deja înaintea tuturor celorlalți în sortare. Dacă există unul,
	e în primii trei; dacă nu e în primii trei, nu există.

	Deci garda nu repara nimic, doar dădea impresia că cineva e de pază. Am
	șters-o, și în locul ei se NUMĂRĂ cazurile: `fara_frate_de_limba` din raport
	spune la câte întrebări nu s-a găsit niciun distractor de aceeași limbă. Alea
	nu sunt un bug de reparat în cod — sunt un autor singur pe limba lui în
	`autori.json`, și singurul leac e un autor în plus acolo.
	"""
	banda = [c for c in candidati if abs(c["nivel"] - tinta["nivel"]) <= 1]
	if len(banda) < 3:
		banda = list(candidati)
	if len(banda) < 3:
		raise Eroare("%s / %s: mai puțin de 3 distractori posibili" % (tinta["cheie"], sens))

	banda.sort(key=lambda c: (-punctaj(tinta, c, sens), zar(cheie_zar, sens, c["cheie"])))
	alesi = banda[:3]
	fara_frate = not any(c["limbi"] & tinta["limbi"] for c in alesi) if tinta["limbi"] else True
	return alesi, fara_frate


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ÎNTREBĂRILOR
# ─────────────────────────────────────────────────────────────

def construieste(lista, autori):
	"""Lista de opere alese → (întrebări, fapte, statistici).

	DE CE SENSUL INVERS E PER AUTOR, nu per operă. Relația e mulți-la-unu: un
	autor are mai multe opere. „Care dintre aceste opere a fost scrisă de Liviu
	Rebreanu?" generată per operă ar da, pentru cinci opere alese ale lui, cinci
	întrebări cu EXACT același text și cinci răspunsuri corecte diferite. Nu sunt
	greșite — dar în joc ar apărea aceeași propoziție de mai multe ori într-o
	expediție, iar sacul nu te apără: pentru el sunt `id`-uri diferite.

	Deci entitatea sensului direct e OPERA, iar a celui invers e AUTORUL. Cifra
	iese din cardinalitatea relației, nu dintr-o preferință.
	"""
	intrebari = []
	statistici = {"fara_frate_de_limba": 0}

	# Operele grupate pe autor, ca să se poată alege reprezentanta și ca să se
	# poată exclude surorile din distractori.
	pe_autor = {}
	for e in lista:
		pe_autor.setdefault(e["autor"]["qid"], []).append(e)

	# Anul de reper al fiecărei opere și al fiecărui autor. Se calculează O DATĂ,
	# aici, fiindcă `punctaj` se cheamă de zeci de mii de ori.
	for e in lista:
		e["an_reper"] = e["an"]
		e["cheie"] = e["qid"]
	candidati_autori = []
	for a in autori:
		ale_lui = pe_autor.get(a["qid"], [])
		if not ale_lui:
			continue
		candidati_autori.append({
			"qid": a["qid"],
			"cheie": a["qid"],
			"nume": a["nume"],
			"limbi": set(a["limbi_sigure"]),
			"an_reper": epoca(a, ale_lui),
			# Nivelul unui autor = cel mai mic nivel al operelor lui alese. Dacă
			# una dintre cărțile lui e cunoscută de oricine, autorul e cunoscut de
			# oricine, oricât de obscur ar fi restul raftului.
			"nivel": min(o["nivel"] for o in ale_lui),
			"opere": ale_lui,
		})
	pe_qid_autor = {c["qid"]: c for c in candidati_autori}

	# ── SENSUL DIRECT: o întrebare per operă ──
	for e in lista:
		if (e["titlu"], "cere_autor") in DUBLURI:
			continue
		autor_tinta = pe_qid_autor[e["autor"]["qid"]]
		ceilalti = [c for c in candidati_autori if c["qid"] != autor_tinta["qid"]]
		tinta = {
			"limbi": autor_tinta["limbi"],
			"an_reper": e["an"] if e["an"] is not None else autor_tinta["an_reper"],
			# NIVELUL BENZII E AL AUTORULUI, NU AL OPEREI, fiindcă butoanele arată
			# AUTORI. Prima versiune folosea nivelul operei, iar rezultatul a fost
			# o greșeală tăcută: „Cine a scris «Jucătorul»?" (operă de nivel III)
			# îl scotea pe Tolstoi din bandă, fiindcă Tolstoi e un autor de nivel I
			# — deci singurul alt rus posibil nu putea fi distractor, iar în locul
			# lui au venit doi români. Banda apără o disparitate între OPȚIUNI;
			# atunci trebuie măsurată pe opțiuni.
			"nivel": autor_tinta["nivel"],
			"cheie": e["qid"],
		}
		distractorii, fara_frate = alege_distractorii(tinta, ceilalti, "cere_autor", e["qid"])
		if fara_frate:
			statistici["fara_frate_de_limba"] += 1

		intrebari.append(_pune_la_locul_lui(
			cheie=e["qid"],
			sens="cere_autor",
			text="Cine a scris „%s”?" % e["titlu"],
			bun=autor_tinta["nume"],
			restul=[d["nume"] for d in distractorii],
			nivel=e["nivel"],
			fapt="wd:%s" % e["qid"],
		))

	# ── SENSUL INVERS: o întrebare per autor ──
	for a in candidati_autori:
		if (a["nume"], "cere_opera") in DUBLURI:
			continue
		# Reprezentanta: opera cea mai recognoscibilă a autorului — nivelul cel mai
		# mic, la egalitate cea cu mai multe ediții Wikipedia. Întrebarea inversă
		# întreabă „recunoști o carte a omului ăstuia?", deci merită pusă pe cartea
		# pe care ar recunoaște-o.
		reprezentanta = sorted(
			a["opere"], key=lambda o: (o["nivel"], -o["editii"], zar(o["qid"])))[0]
		# TOATE operele autorului ies din distractori, nu doar reprezentanta:
		# altfel întrebarea ar avea două răspunsuri corecte.
		ale_lui = {o["qid"] for o in a["opere"]}
		ceilalti = [o for o in lista if o["qid"] not in ale_lui]
		tinta = {
			"limbi": a["limbi"],
			"an_reper": reprezentanta["an"] if reprezentanta["an"] is not None
			else a["an_reper"],
			"nivel": reprezentanta["nivel"],
			"cheie": a["qid"],
		}
		distractorii, fara_frate = alege_distractorii(tinta, ceilalti, "cere_opera", a["qid"])
		if fara_frate:
			statistici["fara_frate_de_limba"] += 1

		intrebari.append(_pune_la_locul_lui(
			cheie=a["qid"],
			sens="cere_opera",
			text="Care dintre aceste opere a fost scrisă de %s?" % a["nume"],
			bun=reprezentanta["titlu"],
			restul=[d["titlu"] for d in distractorii],
			nivel=reprezentanta["nivel"],
			fapt="wd:%s" % a["qid"],
		))

	intrebari.sort(key=lambda q: (q["nivel"], q["id"]))

	# ── VERIFICAREA „EXACT UNA DIN PATRU E CORECTĂ" ──
	# Făcută pe datele complete de la Wikidata, pe fiecare întrebare, DUPĂ ce s-a
	# construit. Pare de prisos după opririle din `leaga_tabelul` — nu e: aceea
	# apără presupunerea („fiecare operă are exact un autor"), asta apără
	# REZULTATUL. Dacă mâine o schimbare în date sau în codul de mai sus ar face
	# să iasă o întrebare cu două răspunsuri bune, aici se oprește tot, și se
	# spune care.
	_verifica_un_singur_raspuns(intrebari, lista, candidati_autori)

	# Faptele. Nota e goală: tabelul cere întrebări, nu note (aceeași decizie ca
	# la elemente). Câmpul EXISTĂ fiindcă altfel încărcătorul din `trivia.gd` se
	# plânge pentru fiecare întrebare care arată spre un fapt inexistent, iar de la
	# al 180-lea avertisment consola nu mai e un loc unde se citește ceva.
	#
	# DOUĂ FELURI DE FAPTE, fiindcă sunt două feluri de întrebări: opera (pentru
	# sensul direct) și autorul (pentru cel invers). Amândouă sub `wd:Q…`, ca la
	# elemente, deci nu se pot ciocni între ele.
	folosite = {q["fapt"] for q in intrebari}
	fapte = []
	for e in lista:
		if "wd:%s" % e["qid"] in folosite:
			fapte.append({"id": "wd:%s" % e["qid"], "nota": "",
			              "surse": ["https://www.wikidata.org/wiki/%s" % e["qid"]],
			              "verificat": False})
	for a in candidati_autori:
		if "wd:%s" % a["qid"] in folosite:
			fapte.append({"id": "wd:%s" % a["qid"], "nota": "",
			              "surse": ["https://www.wikidata.org/wiki/%s" % a["qid"]],
			              "verificat": False})

	return intrebari, fapte, statistici


def _pune_la_locul_lui(cheie, sens, text, bun, restul, nivel, fapt):
	"""O întrebare gata de scris, cu răspunsul bun pus pe o poziție împrăștiată.

	`trivia.gd` amestecă variantele la fiecare apariție (`_amesteca`), deci poziția
	din fișier nu ajunge niciodată pe ecran. O punem totuși împrăștiată: dacă
	amestecarea e vreodată scoasă sau ocolită, fișierul să nu aibă răspunsul bun
	mereu pe primul buton. Două plase peste aceeași greșeală, niciuna scumpă.

	Prin `zar`, nu prin `QID % 4`: QID-ul singur iese grămădit și dă ambelor
	întrebări ale unei entități același loc. Sensul intră în cheie, deci se despart.
	"""
	loc = zar(cheie, sens, "poziție") % 4
	variante = list(restul)
	variante.insert(loc, bun)
	if len(set(variante)) != 4:
		raise Eroare("%s / %s: variante identice → %s" % (cheie, sens, variante))
	return {
		"id": "wd:%s:autor:%s" % (cheie, sens),
		"fapt": fapt,
		"text": text,
		"variante": variante,
		"corect": loc,
		"nivel": nivel,
		"categorie": DOMENIU,
	}


def _verifica_un_singur_raspuns(intrebari, lista, candidati_autori):
	"""Exact una dintre cele patru variante e corectă? Pe date complete."""
	pe_titlu = {e["titlu"]: e for e in lista}
	pe_nume = {a["nume"]: a for a in candidati_autori}
	probleme = []

	for q in intrebari:
		sens = q["id"].rsplit(":", 1)[-1]
		if sens == "cere_autor":
			# Se arată o operă, se cer autorii. Câți dintre cei patru autori afișați
			# se află în mulțimea COMPLETĂ de autori a operei, cea de la Wikidata?
			qid_opera = q["id"].split(":")[1]
			opera = next(e for e in lista if e["qid"] == qid_opera)
			corecti = [v for v in q["variante"]
			           if v in pe_nume and pe_nume[v]["qid"] in opera["autori_wd"]]
		else:
			# Se arată un autor, se cer operele. Câte dintre cele patru opere afișate
			# îl au pe el printre autori?
			qid_autor = q["id"].split(":")[1]
			corecti = [v for v in q["variante"]
			           if v in pe_titlu and qid_autor in pe_titlu[v]["autori_wd"]]
		if len(corecti) != 1:
			probleme.append("%s — %s   variante: %s   corecte după Wikidata: %s"
			                % (q["id"], q["text"], " / ".join(q["variante"]),
			                   ", ".join(corecti) or "NICIUNA"))
		elif corecti[0] != q["variante"][q["corect"]]:
			probleme.append("%s — marcat corect %r, dar Wikidata spune %r"
			                % (q["id"], q["variante"][q["corect"]], corecti[0]))

	if probleme:
		raise Eroare("întrebări la care nu e exact un răspuns corect:\n  - "
		             + "\n  - ".join(probleme))


# ─────────────────────────────────────────────────────────────
# SCRIEREA ȘI CITIREA ÎNAPOI
# ─────────────────────────────────────────────────────────────

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


def citeste_dosarul_generat(fara):
	"""Toate întrebările din `data/trivia_gen/`, în afară de fișierul dat.

	Grila trebuie să arate ADEVĂRUL, adică tot conținutul din joc, nu doar tabelul
	pe care-l rulez acum. Fișierul propriu se scoate și se înlocuiește cu ce s-a
	construit în memorie — altfel raportul ar arăta versiunea de pe disc, cea
	dinaintea rulării.

	(Duplicare cunoscută: `elemente.py` are nevoie de același lucru. Se unifică la
	al treilea tabel, odată cu modulul comun — scris și în `docs/progres.md`.)
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


# ─────────────────────────────────────────────────────────────
# RAPORTUL
# ─────────────────────────────────────────────────────────────

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
		for nivel in (1, 2, 3):
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


def cat_din_lupta(intrebari_mana, intrebari_gen, intrebarile_mele):
	"""Ce parte din luptă devine relația asta.

	Alegerea din `trivia.gd` e în două trepte: întâi domeniul, uniform, apoi
	întrebarea — deci fiecare domeniu ia 1/6 din întrebări oricât de mare ar fi el.
	Ce se schimbă e ce se întâmplă ÎN domeniu, și cifra aia merită văzută.
	"""
	print("\n  ── CÂT DIN LUPTĂ DEVINE „OPERĂ ↔ AUTOR\" ──")
	ale_mele = {q["id"] for q in intrebarile_mele}
	for nivel in (1, 2, 3):
		in_domeniu = [q for q in intrebari_mana + intrebari_gen
		              if str(q.get("categorie")) == DOMENIU and int(q.get("nivel", 0)) == nivel]
		mele = [q for q in in_domeniu if str(q.get("id")) in ale_mele]
		if not in_domeniu:
			continue
		print("    nivelul %d: %d din %d întrebări de literatură (%.0f%%), "
		      "adică %.0f%% din toate întrebările de luptă"
		      % (nivel, len(mele), len(in_domeniu), 100.0 * len(mele) / len(in_domeniu),
		         100.0 * len(mele) / len(in_domeniu) / len(DOMENII)))

	# Și cifra care contează cu adevărat acum, când sunt două fabrici: cât din
	# luptă e conținut fabricat, peste tot.
	print("\n  ── CÂT DIN LUPTĂ E CONȚINUT FABRICAT (toate tabelele) ──")
	for nivel in (1, 2, 3):
		parti = []
		for domeniu in DOMENII:
			m = sum(1 for q in intrebari_mana
			        if str(q.get("categorie")) == domeniu and int(q.get("nivel", 0)) == nivel)
			g = sum(1 for q in intrebari_gen
			        if str(q.get("categorie")) == domeniu and int(q.get("nivel", 0)) == nivel)
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


# ─────────────────────────────────────────────────────────────

def main():
	scrie = "--scrie" in sys.argv
	doar_masoara = "--masoara" in sys.argv
	doar_propune = "--propune" in sys.argv
	reincarca = "--reincarca" in sys.argv
	samanta = random.randrange(1, 10 ** 6)
	for arg in sys.argv[1:]:
		if arg.startswith("--seed="):
			samanta = int(arg.split("=", 1)[1])

	print("\n══ FABRICA: OPERĂ → AUTOR ══\n")

	nume_autori = citeste_lista(CALE_AUTORI, "lista de autori")
	for n in nume_autori:
		if not isinstance(n, str) or not n.strip():
			raise Eroare("autori.json trebuie să fie o listă de nume; am găsit %r" % n)
	if len(set(nume_autori)) != len(nume_autori):
		duble = sorted({n for n in nume_autori if nume_autori.count(n) > 1})
		raise Eroare("nume repetate în autori.json: %s" % ", ".join(duble))

	pachet = ia_datele(reincarca, nume_autori)
	autori = rezolva_autorii(pachet, nume_autori)
	opere = desfa_operele(pachet)
	imbogateste_limbile(autori, opere)
	etichete = desfa_etichetele(pachet)
	print("  Autori: %d din %d nume, fiecare cu un singur om." % (len(autori), len(nume_autori)))

	alese = citeste_lista(CALE_OPERE, "operele alese") if os.path.exists(CALE_OPERE) else []

	if doar_propune:
		propune(autori, opere, etichete, {str(r.get("qid", "")) for r in alese})
		print("\n══ DOAR PROPUS. Nimic scris în data/. ══\n")
		return 0

	lista_toata = leaga_tabelul(alese, autori, opere)

	if doar_masoara:
		masoara(autori, opere, etichete, lista_toata)
		print("\n══ DOAR MĂSURAT. Nimic scris. ══\n")
		return 0

	# ── CIORNELE SE SCOT AICI, ÎNAINTE DE CONSTRUIRE, NU LA SFÂRȘIT ──
	# Distractorii se aleg dintre operele alese, deci o ciornă lăsată în listă ar
	# ajunge distractor într-o întrebare scrisă în `data/`. Raportul de probă și
	# fișierul scris pot să difere — ăsta E înțelesul lor: proba arată ce-ai avea
	# dacă ai confirma tot.
	ciorne = [e for e in lista_toata if e["ciorna"]]
	lista = [e for e in lista_toata if not e["ciorna"]] if scrie else lista_toata

	print("\n  ── TABELUL ──")
	print("    în opere.json: %d opere  (nivel I: %d, II: %d, III: %d)" % (
		len(lista_toata),
		sum(1 for e in lista_toata if e["nivel"] == 1),
		sum(1 for e in lista_toata if e["nivel"] == 2),
		sum(1 for e in lista_toata if e["nivel"] == 3)))
	print("    dintre care ciorne (neconfirmate): %d" % len(ciorne))
	if scrie:
		print("    SE SCRIU doar cele %d confirmate." % len(lista))
	else:
		print("    proba de mai jos le ia în seamă PE TOATE, ciornele incluse.")
	arata_titlurile_de_mana(lista_toata)

	intrebari_mana = citeste_lista(CALE_MANA, "întrebările scrise de mână")
	# DUBLURILE SE CAUTĂ PE TABELUL ÎNTREG, CIORNE INCLUSE, chiar și la `--scrie`.
	# Suprapunerea cu fișierul de mână e o însușire a TABELULUI, nu a ce s-a
	# confirmat azi: o ciornă care dublează o întrebare scrisă de mână trebuie
	# declarată ACUM, altfel ziua în care îi ștergi marcajul e ziua în care apar
	# două întrebări identice, fără ca nimic să fi semnalat.
	#
	# (Prima versiune o chema pe lista filtrată. Cu tot tabelul în ciornă, lista
	# era goală, deci nu se găsea nicio dublură — iar cele 16 declarate în
	# `DUBLURI` au ieșit toate „fantome". Verificarea fantomelor și-a făcut
	# treaba: a arătat că întrebam lucrul greșit.)
	dubluri, aproape = verifica_dublurile(lista_toata, intrebari_mana)
	print("\n  ── DUBLURI CU FIȘIERUL SCRIS DE MÂNĂ ──")
	print("    declarate și găsite: %d" % len(dubluri))
	for (cheie, sens), id_ in sorted(dubluri.items()):
		print("      %-14s %-40s ← %s" % (sens, cheie, id_))
	if aproape:
		# NU e o oprire, e o listă de citit cu ochiul. Prinde ziua în care titlul
		# meu și titlul din întrebarea scrisă de mână diferă printr-un semn —
		# „D-l Goe..." și „D-l Goe" — iar dublura scapă printre degete.
		print("    de citit cu ochiul (nu opresc, dar seamănă a dublură):")
		for r in aproape:
			print("      %s" % r)

	if len(lista) < 4:
		print("\n  Mai puțin de patru opere confirmate: nu se pot face nici măcar")
		print("  distractorii unei singure întrebări.")
		intrebari, fapte, statistici = [], [], {"fara_frate_de_limba": 0}
	else:
		intrebari, fapte, statistici = construieste(lista, autori)

	directe = sum(1 for q in intrebari if q["id"].endswith("cere_autor"))
	inverse = len(intrebari) - directe
	print("\n    generate: %d întrebări (%d directe, %d inverse), %d fapte"
	      % (len(intrebari), directe, inverse, len(fapte)))
	print("    „exact una din patru e corectă\": verificat pe toate %d, pe mulțimea"
	      % len(intrebari))
	print("      completă de autori de la Wikidata.")
	print("    fără niciun distractor de aceeași limbă: %d întrebări (%.0f%%) — autori"
	      % (statistici["fara_frate_de_limba"],
	         100.0 * statistici["fara_frate_de_limba"] / max(1, len(intrebari))))
	print("      singuri pe limba lor în autori.json; leacul e un autor în plus, nu cod")

	celelalte_gen = citeste_dosarul_generat(CALE_INTREBARI)
	grila(intrebari_mana, celelalte_gen + intrebari)
	cat_din_lupta(intrebari_mana, celelalte_gen + intrebari, intrebari)
	if intrebari:
		mostre(intrebari, 15, samanta)

	if not scrie:
		print("\n══ PROBĂ USCATĂ. Rulează cu --scrie ca să scrie fișierele. ══\n")
		return 0

	scrie_lista(CALE_INTREBARI, intrebari,
	            ["id", "fapt", "text", "variante", "corect", "nivel", "categorie"], "nivel")
	scrie_lista(CALE_FAPTE, fapte, ["id", "nota", "surse", "verificat"], "")
	print("\n  Scris:")
	print("    %s" % os.path.relpath(CALE_INTREBARI, RADACINA))
	print("    %s" % os.path.relpath(CALE_FAPTE, RADACINA))

	verifica_inapoi(CALE_INTREBARI, len(intrebari))
	verifica_inapoi(CALE_FAPTE, len(fapte))
	print("  Citit înapoi: JSON valid, id-uri unice în amândouă.")

	# Unicitatea id-urilor PESTE tot conținutul, nu doar în fișierul propriu.
	# Prefixele fac ciocnirea aproape imposibilă, dar verificarea nu se sprijină
	# pe asta — convențiile de nume se respectă până când cineva nu le mai respectă.
	toate = [str(q.get("id", "")) for q in intrebari_mana + celelalte_gen]
	ciocniri = sorted(set(toate) & {q["id"] for q in intrebari})
	if ciocniri:
		raise Eroare("id-uri folosite și în alt fișier: %s" % ", ".join(ciocniri))
	print("  Id-uri unice și peste restul conținutului (%d + %d + %d)."
	      % (len(intrebari_mana), len(celelalte_gen), len(intrebari)))

	# Și textele. Două întrebări cu același text nu strică nimic mecanic, dar în
	# joc arată ca o repetiție — iar sacul nu le apără, fiindcă pentru el sunt
	# id-uri diferite. E chiar plasa peste greșeala de a genera sensul invers per
	# operă în loc de per autor.
	texte = [str(q.get("text", "")) for q in intrebari_mana + celelalte_gen]
	ciocniri_text = sorted(set(texte) & {q["text"] for q in intrebari})
	if ciocniri_text:
		raise Eroare("texte care apar și în alt fișier:\n  - " + "\n  - ".join(ciocniri_text))
	print("  Texte unice peste tot conținutul.")

	if ciorne:
		print("\n  ATENȚIE: %d ciorne NU au fost scrise. Sunt în opere.json cu"
		      % len(ciorne))
		print("  \"ciorna\": true; șterge marcajul de pe rândurile pe care le confirmi.")
		for e in sorted(ciorne, key=lambda x: (x["nivel"], x["titlu"]))[:8]:
			print("    nivel %d  %s — %s" % (e["nivel"], e["titlu"], e["autor"]["nume"]))
		if len(ciorne) > 8:
			print("    … și încă %d" % (len(ciorne) - 8))

	print("\n══ GATA ══\n")
	return 0


if __name__ == "__main__":
	try:
		sys.exit(main())
	except Eroare as e:
		print("\nOPRIT: %s\n" % e)
		sys.exit(1)

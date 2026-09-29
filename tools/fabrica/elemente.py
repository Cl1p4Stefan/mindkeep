#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — elementele chimice, din Wikidata.

    python tools/fabrica/elemente.py --masoara     doar măsoară: relația, etichetele,
                                                   distribuția sitelinks. Nu scrie nimic
    python tools/fabrica/elemente.py               raportul întreg, fără să scrie
    python tools/fabrica/elemente.py --scrie       scrie fișierele din data/
    python tools/fabrica/elemente.py --reincarca   reia din rețea și rescrie cache-ul

Produce două fișiere, rescrise ÎNTREGI la fiecare rulare:

    data/trivia_gen/elemente_intrebari.json   întrebările
    data/trivia_gen/elemente_fapte.json       faptele, deocamdată cu note goale

Dosarul `data/trivia_gen/` ține câte o pereche pentru fiecare tabel al fabricii,
iar `trivia.gd` îl citește ÎNTREG. Un tabel nou înseamnă două fișiere puse acolo,
nu o constantă în plus în joc.

Fișierul scris de mână (`data/intrebari_trivia.json`) nu se atinge niciodată. E
citit, ca să se poată număra grila și ca să se prindă dublurile, și atât.

─────────────────────────────────────────────────────────────
CE FACE MAȘINA ȘI CE NU

Mașina aduce simbolul (din Wikidata, CC0, deci se poate folosi liber), dovedește
că relația element ↔ simbol e unu-la-unu, alege distractorii, dă id-urile, scoate
ambele sensuri ale relației și scrie JSON-ul.

Ce NU poate aduce, și de-aia sunt scrise de mână în `ALESE`, mai jos:

  CARE elemente sunt cultură generală pentru un adult român. Wikidata știe toate
  cele 118, inclusiv oganesson, din care s-au făcut vreo cinci atomi în total.

  CE NIVEL are fiecare. Vezi de ce a picat măsurătoarea automată la `NIVELUL`.

  GRAMATICA. „Care este simbolul chimic al aurului?" cere genitivul cu articol,
  iar el nu se poate calcula din nominativ: aur→aurului, platină→platinei.

Asta e, cred, lecția pilotului, scrisă înainte să-l rulez: Wikidata îți dă
faptul, niciodată pedagogia și niciodată gramatica.

─────────────────────────────────────────────────────────────
DE CE UN CACHE COMIS ÎN GIT

Răspunsul brut de la Wikidata se salvează în `tools/fabrica/cache/`, iar
rulările următoare îl citesc de acolo. Fără rețea, fără așteptare, și — partea
care contează — același rezultat peste șase luni.

Wikidata se editează. Dacă mâine cineva schimbă eticheta română a unui element,
vreau să văd diferența CÂND O CER (`--reincarca`), nu să apară singură într-un
diff din `data/`. Un generator care depinde de o sursă vie și n-o îngheață nu e
un generator, e o rulare norocoasă.

─────────────────────────────────────────────────────────────
NIVELUL: DE CE E SCRIS DE MÂNĂ

Am încercat două măsurători automate. Amândouă au picat, și merită scris de ce,
ca să nu le mai încerce nimeni:

1. NUMĂRUL DE EDIȚII WIKIPEDIA (`wikibase:sitelinks`). Nu deosebește elementele:
   aproape toate au articol în peste 100 de limbi, fiindcă pe wiki-urile mici
   boții au generat câte un articol pe element. Vezi cifrele cu `--masoara`.

2. „SIMBOLUL SE DEDUCE DIN NUMELE ROMÂNESC?" Ideea era bună — dificultatea reală
   nu e cât de celebru e elementul, ci cât de departe e simbolul de cuvântul pe
   care-l știi (`oxigen → O` e deducție, `argint → Ag` e memorare). N-am reușit
   s-o scriu cinstit. Testul „subșir" zice că Ag se deduce din argint (a…g, în
   ordine). Testul „prefix exact" zice că Zn NU se deduce din zinc și Mg nu se
   deduce din magneziu. Un clasificator care greșește în ambele direcții e mai
   rău decât nicio automatizare: ascunde o judecată într-o formulă care pare
   obiectivă.

Deci nivelul e o coloană din `ALESE`, pusă de mână. Automat rămâne o singură
verificare, îngustă și de încredere: `DIN_LATINA`.

─────────────────────────────────────────────────────────────
ACELEAȘI DOUĂ REGULI CA LA `da_iduri.py`

STRICT: orice lucru pe care scriptul nu recunoaște oprește tot. Un script care
„sare peste ce nu înțelege" produce o dată, în tăcere, o întrebare cu două
răspunsuri corecte — și n-o mai găsești niciodată între câteva mii.

UN `id` NU SE REFOLOSEȘTE NICIODATĂ. Aici e ușor: id-ul se calculează din QID-ul
elementului și din sensul relației (`wd:Q897:simbol:cere_nume`), deci e același
la fiecare rulare și nu depinde de ordinea din fișier. Dar înseamnă și că un
element SCOS din `ALESE` își ia id-urile cu el. Dacă îl pui înapoi mai târziu,
primește exact aceleași id-uri — ceea ce e corect, fiindcă e aceeași întrebare.
Ce n-ai voie e să schimbi forma id-ului: aia rupe legătura cu orice save.
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

RADACINA = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CALE_CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cache",
                          "wikidata_elemente.json")
CALE_CONTACT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "contact.txt")

CALE_MANA = os.path.join(RADACINA, "data", "intrebari_trivia.json")
CALE_FAPTE_MANA = os.path.join(RADACINA, "data", "fapte_trivia.json")
DOSAR_GEN = os.path.join(RADACINA, "data", "trivia_gen")
CALE_WD = os.path.join(DOSAR_GEN, "elemente_intrebari.json")
CALE_FAPTE_WD = os.path.join(DOSAR_GEN, "elemente_fapte.json")

# Aceleași șase, în aceeași ordine ca `CATEGORII` din `trivia.gd`. Scrise aici,
# nu citite din cod: raportul trebuie să arate o celulă GOALĂ dacă un domeniu
# rămâne fără întrebări, iar un raport care-și ia lista din date n-o poate face.
DOMENII = ["istorie", "geografie", "stiinta", "arta", "mitologie", "literatura"]

# Domeniul în care intră tot ce fabricăm aici. O singură `categorie` pe
# întrebare, ca în decizia din CLAUDE.md; filtrele transversale vor veni din
# `etichete`, pe fapt.
DOMENIU = "stiinta"

ENDPOINT = "https://query.wikidata.org/sparql"

# Cel mai mare număr atomic al unui element DESCOPERIT (oganesson, 118).
#
# Există fiindcă măsurătoarea a scos la iveală ceva ce nu bănuiam: Wikidata are
# 174 de „elemente chimice", nu 118. Restul sunt IPOTETICE, căsuțe din tabelul
# periodic cu nume sistematic (ununennium, unbinilium…), pe care nimeni nu le-a
# umplut. Iar nouă dintre ele AU etichetă în română, deci filtrul „are etichetă
# română" le-ar fi lăsat să treacă.
#
# Nu ajung în joc oricum, fiindcă tabelul `ALESE` e scris de mână. Dar exact
# ăsta e felul de greșeală pe care n-o vezi: într-o zi în care aș extinde
# selecția mai automat, „unbiquadiu" ar intra ca element de cultură generală.
# Deci se cere numărul atomic de la fiecare element ales, și se cere aici.
ZMAX = 118

# Elementele al căror simbol vine dintr-un nume latin DIFERIT de cel românesc.
# Niciunul n-are ce căuta la nivelul I: simbolul nu poate fi dedus, doar știut.
#
# Aur (aurum) și cupru (cuprum) vin și ele din latină, dar COINCID cu românescul
# — și exact de-aia aurul e nivelul I, iar argintul nivelul II. Lista asta e
# singurul lucru din tabel care se poate scrie greșit fără să se vadă, deci e
# singurul verificat automat.
DIN_LATINA = {"Na", "K", "Fe", "Ag", "Hg", "Pb", "Sn", "Sb", "N"}

# Întrebări din fișierul scris de mână care spun deja ce-am vrea să generăm.
# Cheia e (simbol, sens); valoarea e id-ul întrebării care ocupă locul.
#
# Tabelul singur ar rezolva ziua de azi. De-aia există și `verifica_dublurile()`,
# care caută singură prin fișierul de mână și OPREȘTE scriptul dacă găsește una
# nedeclarată: prinde ziua în care scriu de mână „simbolul chimic al fierului" și
# uit să vin aici.
DUBLURI = {
	("Au", "cere_simbol"): "mana:0018",
}

# Cele două sensuri ale relației. Numele spune ce se CERE, fiindcă asta
# deosebește întrebările: `cere_simbol` arată numele și cere simbolul.
SENSURI = ["cere_simbol", "cere_nume"]


# ─────────────────────────────────────────────────────────────
# ELEMENTELE ALESE — (simbol, nume, genitiv, nivel)
#
# CHEIA E SIMBOLUL, NU QID-UL. N-am vrut să scriu 70 de `Q897` de mână: o cifră
# greșită ar lega întrebarea de alt element, iar nicio validare n-ar prinde-o
# (QID-ul există, elementul există, legătura e doar falsă). Simbolul se citește
# dintr-o privire, e unic — tocmai o dovedim — și QID-ul vine din Wikidata prin
# el. Aceeași logică pentru care `da_iduri.py` leagă faptele pe text.
#
# `nume` nu e folosit ca dată, e o AFIRMAȚIE: scriptul cere ca eticheta română
# de la Wikidata să se potrivească (fără majuscule) și se oprește dacă nu. Deci
# coloana e verificată, nu copiată needitat.
#
# Nivelurile, după definiția din `trivia.gd`:
#   I   — o știe orice adult, fără să fi studiat ceva anume
#   II  — s-a predat la școală; îți amintești dacă ai fost atent
#   III — o știi doar dacă domeniul te-a interesat dincolo de școală
# ─────────────────────────────────────────────────────────────
ALESE = [
	# ── NIVELUL I: cuvântul e cunoscut ȘI simbolul se citește din el ──
	("H",  "hidrogen",  "hidrogenului",  1),
	("He", "heliu",     "heliului",      1),
	("Li", "litiu",     "litiului",      1),
	("C",  "carbon",    "carbonului",    1),
	("O",  "oxigen",    "oxigenului",    1),
	("Ne", "neon",      "neonului",      1),
	("Mg", "magneziu",  "magneziului",   1),
	("Al", "aluminiu",  "aluminiului",   1),
	("Si", "siliciu",   "siliciului",    1),
	("S",  "sulf",      "sulfului",      1),
	("Cl", "clor",      "clorului",      1),
	("Ca", "calciu",    "calciului",     1),
	("Ti", "titan",     "titanului",     1),
	("Ni", "nichel",    "nichelului",    1),
	("Cu", "cupru",     "cuprului",      1),
	("Zn", "zinc",      "zincului",      1),
	("I",  "iod",       "iodului",       1),
	("Pt", "platină",   "platinei",      1),
	("Au", "aur",       "aurului",       1),
	("U",  "uraniu",    "uraniului",     1),

	# ── NIVELUL II: s-a predat la școală, SAU element celebru cu simbol
	#    care trebuie știut (toate cele din DIN_LATINA sunt aici) ──
	("Be", "beriliu",   "beriliului",    2),
	("B",  "bor",       "borului",       2),
	("N",  "azot",      "azotului",      2),
	("F",  "fluor",     "fluorului",     2),
	("Na", "sodiu",     "sodiului",      2),
	("P",  "fosfor",    "fosforului",    2),
	("Ar", "argon",     "argonului",     2),
	("K",  "potasiu",   "potasiului",    2),
	("Cr", "crom",      "cromului",      2),
	("Mn", "mangan",    "manganului",    2),
	("Fe", "fier",      "fierului",      2),
	("Co", "cobalt",    "cobaltului",    2),
	("As", "arsen",     "arsenului",     2),
	("Se", "seleniu",   "seleniului",    2),
	("Br", "brom",      "bromului",      2),
	("Kr", "kripton",   "kriptonului",   2),
	("Cd", "cadmiu",    "cadmiului",     2),
	("Sn", "staniu",    "staniului",     2),
	("Xe", "xenon",     "xenonului",     2),
	("Ba", "bariu",     "bariului",      2),
	("W",  "wolfram",   "wolframului",   2),
	("Hg", "mercur",    "mercurului",    2),
	("Pb", "plumb",     "plumbului",     2),
	("Bi", "bismut",    "bismutului",    2),
	("Ra", "radiu",     "radiului",      2),
	("Ag", "argint",    "argintului",    2),

	# ── NIVELUL III: numele însuși cere să te fi interesat domeniul ──
	("Sc", "scandiu",   "scandiului",    3),
	("Ga", "galiu",     "galiului",      3),
	("Ge", "germaniu",  "germaniului",   3),
	("Rb", "rubidiu",   "rubidiului",    3),
	("Sr", "stronțiu",  "stronțiului",   3),
	("Nb", "niobiu",    "niobiului",     3),
	("Mo", "molibden",  "molibdenului",  3),
	("Ru", "ruteniu",   "ruteniului",    3),
	("Rh", "rodiu",     "rodiului",      3),
	("Pd", "paladiu",   "paladiului",    3),
	("In", "indiu",     "indiului",      3),
	("Sb", "stibiu",    "stibiului",     3),
	("Te", "telur",     "telurului",     3),
	("Cs", "cesiu",     "cesiului",      3),
	("Nd", "neodim",    "neodimului",    3),
	("Ta", "tantal",    "tantalului",    3),
	("Re", "reniu",     "reniului",      3),
	("Os", "osmiu",     "osmiului",      3),
	("Ir", "iridiu",    "iridiului",     3),
	("Tl", "taliu",     "taliului",      3),
	("Po", "poloniu",   "poloniului",    3),
	("Rn", "radon",     "radonului",     3),
	("Th", "toriu",     "toriului",      3),
	("Pu", "plutoniu",  "plutoniului",   3),
]


# Interogarea. `wdt:P31 wd:Q11344` = „instanță de element chimic", `P246` =
# simbolul, `P1086` = numărul atomic, `wikibase:sitelinks` = în câte ediții
# Wikipedia are articol.
#
# Eticheta română o cerem cu `rdfs:label` filtrat EXPLICIT pe „ro", nu prin
# serviciul de etichete al Wikidata. Serviciul are limbi de rezervă, deci un
# element fără etichetă română ar veni cu una englezească strecurată pe ușa din
# dos — și ai crede că ai un nume românesc când n-ai. Așa, lipsa se vede ca
# lipsă.
INTEROGARE = """
SELECT ?element ?simbol ?numar ?sitelinks ?eticheta WHERE {
  ?element wdt:P31 wd:Q11344 .
  ?element wdt:P246 ?simbol .
  ?element wikibase:sitelinks ?sitelinks .
  OPTIONAL { ?element wdt:P1086 ?numar . }
  OPTIONAL { ?element rdfs:label ?eticheta . FILTER(lang(?eticheta) = "ro") }
}
"""


class Eroare(Exception):
	"""Ceva ce scriptul nu recunoaște. Oprește tot, nu se sare peste."""


# ─────────────────────────────────────────────────────────────
# REȚEAUA
# ─────────────────────────────────────────────────────────────

def contactul():
	"""Adresa de contact pentru User-Agent. NU stă în cod.

	Wikimedia cere un User-Agent descriptiv, cu un om de contact, ca să poată
	scrie cuiva dacă un script le face rău. Corect — dar adresa nu are ce căuta
	într-un fișier comis în Git, deci se citește din afară:

	    MINDKEEP_CONTACT=cineva@exemplu.ro python tools/fabrica/elemente.py --reincarca

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
		% os.path.relpath(CALE_CONTACT, RADACINA)
	)


def interogheaza():
	"""O cerere la Wikidata. Întoarce răspunsul brut, ca dicționar."""
	contact = contactul()
	antet = "Mindkeep-fabrica/0.1 (%s) Python-urllib" % contact

	cerere = urllib.request.Request(
		ENDPOINT,
		data=urllib.parse.urlencode({"query": INTEROGARE}).encode("utf-8"),
		headers={
			"User-Agent": antet,
			"Accept": "application/sparql-results+json",
			"Content-Type": "application/x-www-form-urlencoded",
		},
		method="POST",
	)
	print("  Întreb Wikidata (User-Agent: %s)…" % antet)
	try:
		with urllib.request.urlopen(cerere, timeout=120) as raspuns:
			return json.loads(raspuns.read().decode("utf-8"))
	except urllib.error.HTTPError as e:
		# 403 și 429 de la Wikimedia înseamnă aproape mereu User-Agent, nu
		# interogare — merită spus, altfel cauți o oră în SPARQL.
		detaliu = ""
		if e.code in (403, 429):
			detaliu = ("\n  Codul %d de la Wikimedia e aproape mereu despre User-Agent "
			           "sau despre prea multe cereri, nu despre interogare." % e.code)
		raise Eroare("Wikidata a răspuns %d %s%s" % (e.code, e.reason, detaliu))
	except urllib.error.URLError as e:
		raise Eroare("nu ajung la Wikidata: %s" % e.reason)


def ia_datele(reincarca):
	"""Răspunsul brut, din cache sau din rețea. Scrie cache-ul când îl ia."""
	if not reincarca and os.path.exists(CALE_CACHE):
		with io.open(CALE_CACHE, encoding="utf-8") as f:
			pachet = json.load(f)
		print("  Cache: %s (luat la %s)" % (
			os.path.relpath(CALE_CACHE, RADACINA), pachet.get("luat_la", "?")))
		return pachet["raspuns"]

	brut = interogheaza()
	# Cache-ul ține și CÂND și CU CE interogare a fost luat. Fără ele, peste
	# șase luni ai un fișier de date fără proveniență, iar dacă interogarea se
	# schimbă n-ai cum să știi că cache-ul e din cea veche.
	pachet = {
		"luat_la": time.strftime("%Y-%m-%dT%H:%M:%S"),
		"endpoint": ENDPOINT,
		"interogare": INTEROGARE,
		"raspuns": brut,
	}
	os.makedirs(os.path.dirname(CALE_CACHE), exist_ok=True)
	with io.open(CALE_CACHE, "w", encoding="utf-8", newline="\n") as f:
		json.dump(pachet, f, ensure_ascii=False, indent="\t", sort_keys=True)
		f.write("\n")
	print("  Scris cache: %s" % os.path.relpath(CALE_CACHE, RADACINA))
	return brut


# ─────────────────────────────────────────────────────────────
# CITIREA RĂSPUNSULUI
# ─────────────────────────────────────────────────────────────

def desfa(brut):
	"""Rândurile SPARQL → un dicționar QID → date.

	Un element poate veni pe MAI MULTE rânduri, dacă are mai multe simboluri în
	Wikidata. Nu le contopim: le strângem într-o mulțime, ca `verifica_relatia`
	să le poată vedea. Contopirea în tăcere ar fi exact greșeala pe care
	verificarea unu-la-unu există ca s-o prindă.
	"""
	legaturi = brut.get("results", {}).get("bindings", [])
	if not legaturi:
		raise Eroare("Wikidata n-a întors niciun rând. Interogarea sau endpointul?")

	elemente = {}
	for rand in legaturi:
		uri = rand["element"]["value"]
		qid = uri.rsplit("/", 1)[-1]
		if not re.fullmatch(r"Q\d+", qid):
			raise Eroare("URI de element pe care nu-l recunosc: %r" % uri)

		e = elemente.setdefault(qid, {
			"qid": qid,
			"simboluri": set(),
			"numar": None,
			"sitelinks": 0,
			"eticheta": None,
		})
		e["simboluri"].add(rand["simbol"]["value"].strip())
		e["sitelinks"] = int(rand["sitelinks"]["value"])
		if "numar" in rand:
			e["numar"] = int(float(rand["numar"]["value"]))
		if "eticheta" in rand:
			e["eticheta"] = rand["eticheta"]["value"].strip()
	return elemente


def verifica_relatia(elemente):
	"""Element ↔ simbol e unu-la-unu? Dacă nu, oprește tot.

	DE CE E PRIMA VERIFICARE, ȘI DE CE OPREȘTE. Toată fabrica se sprijină pe
	relația asta în două locuri. La `cere_simbol`, un element cu două simboluri
	ar da o întrebare cu două răspunsuri corecte, dintre care unul marcat
	greșit. La `cere_nume`, un simbol purtat de două elemente ar face la fel. Și
	mai e un al treilea loc, mai ascuns: tot tabelul `ALESE` e cheiat pe simbol,
	deci un simbol dublu ar însemna că nu mai știu despre CARE element vorbesc.

	Niciuna dintre cele trei nu s-ar vedea în joc ca eroare. S-ar vedea ca o
	întrebare la care „jocul greșește" — cel mai scump fel de bug pentru un joc
	de învățare, fiindcă predă un lucru fals cu toată încrederea.
	"""
	multe_simboluri = sorted(
		(e["qid"], sorted(e["simboluri"])) for e in elemente.values()
		if len(e["simboluri"]) != 1
	)
	if multe_simboluri:
		raise Eroare("elemente cu alt număr de simboluri decât unul:\n  " + "\n  ".join(
			"%s → %s" % (qid, s) for qid, s in multe_simboluri))

	pe_simbol = {}
	for e in elemente.values():
		simbol = next(iter(e["simboluri"]))
		e["simbol"] = simbol
		pe_simbol.setdefault(simbol, []).append(e["qid"])

	impartite = sorted((s, sorted(q)) for s, q in pe_simbol.items() if len(q) > 1)
	if impartite:
		raise Eroare("simboluri purtate de mai multe elemente:\n  " + "\n  ".join(
			"%s → %s" % (s, q) for s, q in impartite))

	return pe_simbol


# ─────────────────────────────────────────────────────────────
# MĂSURĂTOAREA
# ─────────────────────────────────────────────────────────────

def masoara(elemente, pe_simbol):
	"""Ce se poate afla din date, înainte să se aleagă ceva.

	Rostul funcției e să DOVEDEASCĂ, nu să presupună, de ce nivelul e scris de
	mână. Măsurătoarea a mai scos la iveală și altceva, care a schimbat scriptul:
	vezi `ZMAX` mai jos.
	"""
	print("\n  ── CE A VENIT DIN WIKIDATA ──")
	print("    rânduri distincte: %d elemente, %d simboluri" % (len(elemente), len(pe_simbol)))

	# WIKIDATA NU ARE 118 ELEMENTE, ARE 174. Peste cele descoperite, ține și
	# elementele IPOTETICE, cu numele lor sistematic (ununennium, unbinilium…):
	# căsuțe din tabelul periodic pe care nimeni nu le-a umplut încă.
	#
	# Nu sunt o greșeală în date, sunt o categorie de lucruri despre care nu se
	# poate pune o întrebare de cultură generală. Filtrul care le scoate e numărul
	# atomic, nu eticheta română — vezi mai jos de ce.
	reale = [e for e in elemente.values() if e["numar"] and 1 <= e["numar"] <= ZMAX]
	ipotetice = [e for e in elemente.values() if e not in reale]
	print("    reale (Z ≤ %d): %d     ipotetice sau fără număr atomic: %d"
	      % (ZMAX, len(reale), len(ipotetice)))

	numere = sorted(e["numar"] for e in reale)
	if numere != list(range(1, len(numere) + 1)):
		print("    ! numerele atomice nu sunt 1…%d fără goluri" % len(numere))

	# Etichetele române. Decizia din sesiunea CONȚINUTUL era: un subiect fără
	# etichetă română probabil nu e cultură generală pentru un jucător român. Se
	# ține, dar măsurătoarea a arătat că nu e SUFICIENTĂ.
	print("\n  ── ETICHETELE ROMÂNE ──")
	print("    dintre cele reale:     %d din %d"
	      % (sum(1 for e in reale if e["eticheta"]), len(reale)))
	strecurate = sorted((e["numar"] or 999, e["simbol"], e["eticheta"])
	                    for e in ipotetice if e["eticheta"])
	print("    dintre cele ipotetice: %d din %d" % (len(strecurate), len(ipotetice)))
	if strecurate:
		# ASTA E DESCOPERIREA. Nouă elemente care nu există au etichetă română
		# („ununennium", Z = 119), deci filtrul „are etichetă română" le-ar fi lăsat
		# să treacă. Singurul filtru cinstit e numărul atomic, și de-aia
		# `leaga_tabelul` îl cere acum de la fiecare element ales.
		print("      trec prin filtrul de etichetă, deși nu există: %s"
		      % ", ".join("%s (Z=%d)" % (s, z) for z, s, _ in strecurate))

	# Distribuția sitelinks, pe cele două grupuri separat. Amestecate, par să
	# separe ceva; despărțite, se vede CE separă.
	print("\n  ── DISTRIBUȚIA SITELINKS (câte ediții Wikipedia) ──")
	for eticheta, grup in (("reale     ", reale), ("ipotetice ", ipotetice)):
		if not grup:
			continue
		v = sorted(e["sitelinks"] for e in grup)
		print("    %s min %3d   median %3d   maxim %3d   decile: %s" % (
			eticheta, v[0], v[len(v) // 2], v[-1],
			"  ".join("%3d" % v[min(len(v) - 1, int(len(v) * k / 10))] for k in range(10))))
	print("    → separă REAL de IPOTETIC, ceea ce numărul atomic face deja și mai bine.")
	print("      Între elementele reale, decila 1 și decila 9 stau într-o bandă de")
	print("      vreo 1,5× — prea strâns ca să deosebească „o știe oricine\" de")
	print("      „doar dacă te-a interesat\".")

	# Reperele: elemente despre care ȘTIU în ce nivel le-am pus, ca să se vadă
	# dacă cifra merge în aceeași direcție cu judecata. Nu merge.
	repere = ["O", "Au", "Fe", "Ag", "U", "Hg", "W", "Rn", "Mo", "Os", "Nd", "Re"]
	nivel_din_tabel = {s: n for s, _, _, n in ALESE}
	print("\n    repere (nivelul pus de mână, sitelinks):")
	for simbol in repere:
		qid_uri = pe_simbol.get(simbol)
		if not qid_uri:
			continue
		e = elemente[qid_uri[0]]
		print("      %-3s  nivel %d   %3d ediții   %s" % (
			simbol, nivel_din_tabel.get(simbol, 0), e["sitelinks"], e["eticheta"] or "—"))
	print("      → ordinea se contrazice pe bucăți: radonul (nivel III) are mai multe")
	print("        ediții decât wolframul (nivel II), iar neodimul (III) mai puține")
	print("        decât molibdenul (III). Zgomot cu aspect de cifră.")


# ─────────────────────────────────────────────────────────────
# TABELUL, CONFRUNTAT CU WIKIDATA
# ─────────────────────────────────────────────────────────────

def leaga_tabelul(elemente, pe_simbol):
	"""`ALESE` + datele de la Wikidata → lista de lucru. Strict la fiecare pas.

	Adună TOATE neconcordanțele înainte să se oprească. Un script care cade la
	prima nepotrivire de etichetă te pune să rulezi de 20 de ori ca să repari 20
	de rânduri; ăsta le arată pe toate dintr-o dată.
	"""
	probleme = []

	simboluri = [s for s, _, _, _ in ALESE]
	if len(set(simboluri)) != len(simboluri):
		duble = sorted({s for s in simboluri if simboluri.count(s) > 1})
		probleme.append("simboluri repetate în ALESE: %s" % ", ".join(duble))
	nume = [n for _, n, _, _ in ALESE]
	if len(set(nume)) != len(nume):
		duble = sorted({n for n in nume if nume.count(n) > 1})
		probleme.append("nume repetate în ALESE: %s" % ", ".join(duble))

	lista = []
	for simbol, nume_asteptat, genitiv, nivel in ALESE:
		if nivel not in (1, 2, 3):
			probleme.append("%s: nivelul %r nu e 1, 2 sau 3" % (simbol, nivel))
			continue
		if simbol in DIN_LATINA and nivel == 1:
			# Singura verificare automată de nivel care rămâne. Vezi DIN_LATINA.
			probleme.append(
				"%s e la nivelul I, dar simbolul vine dintr-un nume latin diferit de "
				"cel românesc (%s) — nu poate fi dedus, doar știut" % (simbol, nume_asteptat))
			continue
		if simbol not in pe_simbol:
			probleme.append("%s (%s): nu există în Wikidata ca simbol de element"
			                % (simbol, nume_asteptat))
			continue

		e = elemente[pe_simbol[simbol][0]]
		# Elementul există cu adevărat? Vezi ZMAX: Wikidata ține și căsuțe goale
		# din tabelul periodic, iar nouă dintre ele au chiar etichetă română.
		if not e["numar"] or not 1 <= e["numar"] <= ZMAX:
			probleme.append("%s (%s): numărul atomic e %r — element ipotetic, nu descoperit"
			                % (simbol, nume_asteptat, e["numar"]))
			continue
		if not e["eticheta"]:
			probleme.append("%s (%s): Wikidata nu are etichetă română pentru %s"
			                % (simbol, nume_asteptat, e["qid"]))
			continue
		if e["eticheta"].lower() != nume_asteptat.lower():
			probleme.append("%s: în tabel scrie %r, Wikidata (%s) spune %r"
			                % (simbol, nume_asteptat, e["qid"], e["eticheta"]))
			continue

		lista.append({
			"qid": e["qid"],
			"simbol": simbol,
			# Numele vine de la WIKIDATA, nu din tabel — datele sunt ale lor,
			# coloana mea era doar afirmația care s-a verificat mai sus. Micșorat,
			# ca toate cele patru butoane să arate la fel.
			"nume": e["eticheta"].lower(),
			"genitiv": genitiv,
			"nivel": nivel,
			"numar": e["numar"],
			"sitelinks": e["sitelinks"],
		})

	if probleme:
		raise Eroare("tabelul ALESE nu se potrivește cu Wikidata:\n  - " + "\n  - ".join(probleme))

	# Ordinea din fișier: pe nivel, apoi pe numărul atomic. Numărul atomic e
	# ordinea în care un om se uită la tabelul periodic, deci fișierul se poate
	# citi, iar un element adăugat mai târziu cade la locul lui — deci diff-ul
	# din Git arată ce s-a adăugat, nu o rearanjare.
	lista.sort(key=lambda e: (e["nivel"], e["numar"] if e["numar"] else 999))
	return lista


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

def citeste_lista(cale):
	with io.open(cale, encoding="utf-8") as f:
		date = json.load(f)
	if not isinstance(date, list):
		raise Eroare("%s nu conține o listă" % cale)
	return date


def verifica_dublurile(lista, intrebari_mana):
	"""Caută în fișierul scris de mână întrebări care spun deja ce vrem să generăm.

	Caută doar prin întrebările care conțin cuvântul „simbol": restul nu pot fi
	dubluri ale relației asta. („Ce element chimic are numărul atomic 79?" are
	tot aurul ca răspuns, dar e o RELAȚIE ALTA, deci nu e dublură.)

	Potrivirea e pe cuvânt întreg, nu pe bucată de cuvânt: altfel „bor" s-ar
	găsi în „laborator" și „iod" în „perioada".

	Ce găsește și nu e declarat în DUBLURI oprește scriptul. Tabelul singur ar
	fi rezolvat ziua de azi; căutarea prinde ziua în care scriu de mână „simbolul
	chimic al fierului" și uit să vin aici.
	"""
	gasite = {}
	for q in intrebari_mana:
		text = str(q.get("text", ""))
		if "simbol" not in text.lower():
			continue
		jos = text.lower()
		for e in lista:
			# Numele sau genitivul în text → întrebarea cere SIMBOLUL.
			for forma in (e["nume"], e["genitiv"]):
				if re.search(r"\b%s\b" % re.escape(forma), jos):
					gasite[(e["simbol"], "cere_simbol")] = str(q.get("id", "?"))
			# Simbolul ca token în text → întrebarea cere NUMELE.
			if re.search(r"\b%s\b" % re.escape(e["simbol"]), text):
				gasite[(e["simbol"], "cere_nume")] = str(q.get("id", "?"))

	nedeclarate = sorted(k for k in gasite if k not in DUBLURI)
	if nedeclarate:
		raise Eroare(
			"întrebări scrise de mână care se suprapun cu ce generăm, nedeclarate în "
			"DUBLURI:\n  - " + "\n  - ".join(
				"%s / %s  ← %s" % (s, sens, gasite[(s, sens)]) for s, sens in nedeclarate)
			+ "\n  Adaugă-le în DUBLURI (sau schimbă întrebarea scrisă de mână).")

	# Și invers: o declarație care nu mai corespunde nimic e la fel de rea, doar
	# mai tăcută — scoate din joc o întrebare bună fără să spună de ce.
	fantome = sorted(k for k in DUBLURI if k not in gasite)
	if fantome:
		raise Eroare(
			"DUBLURI declară suprapuneri care nu se mai găsesc în fișierul scris de "
			"mână:\n  - " + "\n  - ".join("%s / %s" % (s, sens) for s, sens in fantome)
			+ "\n  Dacă întrebarea de mână s-a schimbat, șterge rândul din DUBLURI.")

	return gasite


# ─────────────────────────────────────────────────────────────
# DISTRACTORII
# ─────────────────────────────────────────────────────────────

def zar(*bucati):
	"""Un număr stabil dintr-un text: același la fiecare rulare, pe orice mașină.

	`hash()` din Python NU e bun aici: e sărat la fiecare pornire a
	interpretorului, deci ar da alt fișier la fiecare rulare.

	DE CE E NEVOIE DE EL. Ruperea egalităților trebuie să fie deterministă (ca
	fișierul să nu se schimbe degeaba), dar nu are voie să fie ORDONATĂ. Prima
	variantă rupea egalitățile pe QID crescător, iar în Wikidata QID-urile mici
	sunt exact elementele celebre (hidrogenul e Q556). Rezultatul: hidrogenul și
	heliul apăreau ca distractori la jumătate din întrebări — iar un jucător
	care observă „răspunsul nu e niciodată hidrogenul" marchează puncte fără să
	gândească. Exact scurtătura pe care `_amesteca` din `trivia.gd` a fost
	scrisă s-o închidă, reapărută pe alt drum.
	"""
	cheie = "|".join(str(b) for b in bucati).encode("utf-8")
	return int.from_bytes(hashlib.blake2b(cheie, digest_size=8).digest(), "big")


def punctaj(tinta, e, sens):
	"""Cât de plauzibil e `e` ca distractor la întrebarea despre `tinta`.

	Regula pornește de la cerința ta: la „simbolul aurului", Ag și Al, nu Xe.

	  +100  la `cere_simbol`: simbol cu aceeași primă literă ca cel corect
	        (Au → Ag, Al, Ar, As). La `cere_nume`: element al cărui simbol
	        începe cu litera simbolului cerut (Hg → hidrogen, heliu) — adică
	        exact confuzia „H trebuie să fie hidrogen".
	  +50   la `cere_simbol`: simbol care ar putea fi o prescurtare a numelui
	        cerut (sodiu → S, Si, Sc, Se), adică întrebarea „de ce nu e S?".
	        La `cere_nume`: nume care începe cu litera simbolului cerut.
	  +10/5 același nivel / nivel vecin.
	"""
	p = 0
	if e["simbol"][0] == tinta["simbol"][0]:
		p += 100
	if sens == "cere_simbol":
		if e["simbol"][0].lower() == tinta["nume"][0].lower():
			p += 50
	else:
		if e["nume"][0].lower() == tinta["simbol"][0].lower():
			p += 50
	p += 10 if e["nivel"] == tinta["nivel"] else 5
	return p


def alege_distractorii(tinta, lista, sens):
	"""Cei trei distractori, deterministic.

	SINGURA PLASĂ E BANDA DE NIVEL, și merită spus de ce nu e alta. Am scris
	întâi o gardă „dacă toți trei distractorii încep cu o literă pe care
	răspunsul n-o are, schimbă unul" — și am aruncat-o. „Ce element are simbolul
	Hg?" cu mercur / hidrogen / heliu e o întrebare bună, iar garda ar fi
	stricat-o: tiparul acolo duce DEPARTE de răspuns, deci cine se ia după el
	greșește. Aia e pedagogie, nu scurtătură.

	O scurtătură e tiparul care duce SPRE răspuns, iar singura formă în care
	apare aici e disparitatea de familiaritate: trei nume obscure lângă unul
	celebru se recunoaște fără să știi nimic. De-aia toate patru opțiunile stau
	în aceeași bandă de nivel (±1).
	"""
	banda = [e for e in lista
	         if e["simbol"] != tinta["simbol"] and abs(e["nivel"] - tinta["nivel"]) <= 1]
	if len(banda) < 3:
		banda = [e for e in lista if e["simbol"] != tinta["simbol"]]
	if len(banda) < 3:
		raise Eroare("%s: mai puțin de 3 distractori posibili" % tinta["simbol"])

	banda.sort(key=lambda e: (-punctaj(tinta, e, sens), zar(tinta["qid"], sens, e["qid"])))
	alesi = banda[:3]

	# ── SINGURA GARDĂ: GRUPUL DE LITERE CARE NU E DESPRE ÎNTREBARE ──
	#
	# Măsurând cele 139 de întrebări, „alege-l pe cel diferit" mergea la 4. Trei
	# din ele erau cele mai bune întrebări din tot lotul:
	#
	#   Ce element chimic are simbolul N?   neon / neodim / nichel / AZOT
	#   Ce element chimic are simbolul Na?  niobiu / neodim / neon / SODIU
	#   Ce element chimic are simbolul P?   plumb / poloniu / platină / FOSFOR
	#
	# Alea NU se repară. Grupul de „n"-uri e chiar lecția (N e azotul, nu neonul),
	# iar tiparul duce DEPARTE de răspuns, deci cine se ia după el greșește. Sunt
	# exact elementele din DIN_LATINA, și de-aia există disciplina.
	#
	# A patra era un accident curat:
	#
	#   Care este simbolul chimic al uraniului?   Cl / Cu / C / U
	#
	# Trei simboluri de carbon în jurul uraniului. Litera „c" nu are nicio
	# legătură nici cu U, nici cu „uraniu" — a ieșit din ruperea egalităților,
	# fiindcă uraniul n-are niciun frate pe litera U.
	#
	# Deci regula nu e „nu lăsa un grup de litere", e: UN GRUP DE LITERE E
	# LEGITIM DACĂ LITERA LUI E DESPRE ÎNTREBARE — prima literă a simbolului
	# cerut sau a numelui cerut. Altfel e o coincidență și se rupe.
	fata = (lambda e: e["simbol"]) if sens == "cere_simbol" else (lambda e: e["nume"])
	litere = {fata(e)[0].lower() for e in alesi}
	if len(litere) == 1:
		litera = next(iter(litere))
		despre_intrebare = {tinta["simbol"][0].lower(), tinta["nume"][0].lower()}
		if litera not in despre_intrebare:
			for candidat in banda[3:]:
				if fata(candidat)[0].lower() != litera:
					alesi[2] = candidat
					break

	return alesi


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ÎNTREBĂRILOR
# ─────────────────────────────────────────────────────────────

def construieste(lista):
	"""Lista de elemente → (întrebări, fapte)."""
	intrebari = []
	for e in lista:
		for sens in SENSURI:
			if (e["simbol"], sens) in DUBLURI:
				continue

			distractorii = alege_distractorii(e, lista, sens)
			if sens == "cere_simbol":
				text = "Care este simbolul chimic al %s?" % e["genitiv"]
				bun = e["simbol"]
				restul = [d["simbol"] for d in distractorii]
			else:
				text = "Ce element chimic are simbolul %s?" % e["simbol"]
				bun = e["nume"]
				restul = [d["nume"] for d in distractorii]

			# POZIȚIA RĂSPUNSULUI BUN. `trivia.gd` amestecă variantele la fiecare
			# apariție (`_amesteca`), deci poziția din fișier nu ajunge niciodată
			# pe ecran. O punem totuși împrăștiată: dacă amestecarea e vreodată
			# scoasă sau ocolită, fișierul să nu aibă răspunsul bun mereu pe
			# primul buton. Două plase peste aceeași greșeală, niciuna scumpă.
			#
			# Prin `zar`, nu prin `QID % 4`. QID-ul singur ieșea grămădit
			# (40/27/36/36 pe cele patru locuri) și dădea ambelor întrebări ale
			# unui element același loc, fiindcă amândouă pornesc de la același
			# QID. Sensul intră în cheie, deci cele două se despart.
			loc = zar(e["qid"], sens, "poziție") % 4
			variante = list(restul)
			variante.insert(loc, bun)

			if len(set(variante)) != 4:
				raise Eroare("%s / %s: variante identice → %s" % (e["simbol"], sens, variante))

			intrebari.append({
				"id": "wd:%s:simbol:%s" % (e["qid"], sens),
				"fapt": "wd:%s" % e["qid"],
				"text": text,
				"variante": variante,
				"corect": loc,
				"nivel": e["nivel"],
				"categorie": DOMENIU,
			})

	# Faptele. Nota e goală: pilotul cere întrebări, nu note. Câmpul EXISTĂ
	# fiindcă altfel încărcătorul din `trivia.gd` se plânge pentru fiecare
	# întrebare care arată spre un fapt inexistent — 139 de avertismente la
	# fiecare pornire, iar de-acolo încolo consola nu mai e un loc unde se
	# citește ceva.
	#
	# ATENȚIE, e scris și în `docs/progres.md`: fișierul ăsta se REscrie întreg
	# la fiecare rulare, deci notele pentru faptele `wd:` NU pot sta în el. Când
	# vor exista, vor sta într-un loc pe care generarea nu-l atinge.
	fapte = [{
		"id": "wd:%s" % e["qid"],
		"nota": "",
		"surse": ["https://www.wikidata.org/wiki/%s" % e["qid"]],
		"verificat": False,
	} for e in lista]

	return intrebari, fapte


# ─────────────────────────────────────────────────────────────
# SCRIEREA
#
# Nu `json.dump`. Fișierul iese în ACELAȘI format ca `intrebari_trivia.json`:
# taburi, `variante` pe un singur rând, linii goale între niveluri. Nu e
# cochetărie — `json.dump` ar pune fiecare variantă pe rândul ei, iar fișierul
# ar sări de la 1200 la 2000 de linii, cu diff-uri pe care nu le mai poți citi
# când adaugi patru elemente.
# ─────────────────────────────────────────────────────────────

def ca_json(valoare):
	"""Un singur câmp, scris ca JSON. `ensure_ascii=False` ca diacriticele și
	ghilimelele românești să rămână litere, nu `\\u0103`."""
	return json.dumps(valoare, ensure_ascii=False)


def scrie_lista(cale, obiecte, ordinea, separa_pe):
	"""Scrie o listă de obiecte, cu câmpurile în `ordinea` dată.

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
# RAPORTUL
# ─────────────────────────────────────────────────────────────

def citeste_dosarul_generat(fara):
	"""Toate întrebările din `data/trivia_gen/`, în afară de fișierul dat.

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


def grila(intrebari_mana, intrebari_wd):
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
	wd = strange(intrebari_wd)

	print("\n  ── GRILA: întrebări (fapte) ──")
	print("    %-12s %19s %19s %19s %13s" % (
		"", "nivelul I", "nivelul II", "nivelul III", "total"))
	for domeniu in DOMENII:
		bucati = []
		total_q = 0
		total_f = set()
		for nivel in (1, 2, 3):
			m = mana.get((domeniu, nivel), {"q": 0, "fapte": set()})
			w = wd.get((domeniu, nivel), {"q": 0, "fapte": set()})
			total_q += m["q"] + w["q"]
			total_f |= m["fapte"] | w["fapte"]
			bucati.append("%3d+%-3d (%2d+%-3d)" % (
				m["q"], w["q"], len(m["fapte"]), len(w["fapte"])))
		bucati.append("%4d (%3d)" % (total_q, len(total_f)))
		print("    %-12s %s" % (domeniu, " ".join("%18s" % b for b in bucati[:3])
		                        + " %12s" % bucati[3]))
	print("    (mână + wikidata; parantezele sunt fapte distincte)")

	# Ce înseamnă asta în luptă. Alegerea din `trivia.gd` e în două trepte: întâi
	# domeniul, uniform, apoi întrebarea — deci fiecare domeniu ia 1/6 din
	# întrebări oricât de mare ar fi el. Ce se schimbă e ce se întâmplă ÎN
	# știință, și cifra aia merită văzută, nu ghicită.
	print("\n  ── CÂT DIN LUPTĂ DEVINE CHIMIE ──")
	for nivel in (1, 2, 3):
		m = mana.get((DOMENIU, nivel), {"q": 0})["q"]
		w = wd.get((DOMENIU, nivel), {"q": 0})["q"]
		if m + w == 0:
			continue
		print("    nivelul %d: %d din %d întrebări de știință (%.0f%%), "
		      "adică %.0f%% din toate întrebările de luptă"
		      % (nivel, w, m + w, 100.0 * w / (m + w), 100.0 * w / (m + w) / len(DOMENII)))


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
	reincarca = "--reincarca" in sys.argv
	samanta = random.randrange(1, 10 ** 6)
	for arg in sys.argv[1:]:
		if arg.startswith("--seed="):
			samanta = int(arg.split("=", 1)[1])

	print("\n══ FABRICA: ELEMENTELE CHIMICE ══\n")

	brut = ia_datele(reincarca)
	elemente = desfa(brut)
	pe_simbol = verifica_relatia(elemente)
	print("  Relația element ↔ simbol: unu-la-unu, verificată pe toate cele %d."
	      % len(elemente))

	masoara(elemente, pe_simbol)
	if doar_masoara:
		print("\n══ DOAR MĂSURAT. Nimic scris. ══\n")
		return 0

	lista = leaga_tabelul(elemente, pe_simbol)
	print("\n  ── TABELUL ──")
	print("    alese: %d elemente  (nivel I: %d, II: %d, III: %d)" % (
		len(lista),
		sum(1 for e in lista if e["nivel"] == 1),
		sum(1 for e in lista if e["nivel"] == 2),
		sum(1 for e in lista if e["nivel"] == 3)))

	intrebari_mana = citeste_lista(CALE_MANA)
	dubluri = verifica_dublurile(lista, intrebari_mana)
	print("    dubluri cu fișierul scris de mână: %d  (%s)" % (
		len(dubluri),
		", ".join("%s/%s ← %s" % (s, sens, id_) for (s, sens), id_ in sorted(dubluri.items()))
		or "niciuna"))

	intrebari, fapte = construieste(lista)
	print("    generate: %d întrebări, %d fapte (toate cu nota goală)"
	      % (len(intrebari), len(fapte)))

	# Grila arată TOT conținutul din joc, nu doar tabelul rulat acum: de când sunt
	# două fabrici, un raport care se uită doar la el însuși minte cu jumătăți de
	# adevăr. (Duplicare cunoscută cu `opere.py`; se unifică la al treilea tabel,
	# odată cu modulul comun.)
	celelalte_gen = citeste_dosarul_generat(CALE_WD)
	grila(intrebari_mana, celelalte_gen + intrebari)
	mostre(intrebari, 15, samanta)

	if not scrie:
		print("\n══ PROBĂ USCATĂ. Rulează cu --scrie ca să scrie fișierele. ══\n")
		return 0

	scrie_lista(CALE_WD, intrebari,
	            ["id", "fapt", "text", "variante", "corect", "nivel", "categorie"], "nivel")
	scrie_lista(CALE_FAPTE_WD, fapte, ["id", "nota", "surse", "verificat"], "")
	print("\n  Scris:")
	print("    %s" % os.path.relpath(CALE_WD, RADACINA))
	print("    %s" % os.path.relpath(CALE_FAPTE_WD, RADACINA))

	verifica_inapoi(CALE_WD, len(intrebari))
	verifica_inapoi(CALE_FAPTE_WD, len(fapte))
	print("  Citit înapoi: JSON valid, id-uri unice în amândouă.")

	# Și unicitatea PESTE cele două fișiere de întrebări. `mana:` și `wd:` nu se
	# pot ciocni, dar verificarea nu costă nimic și nu se sprijină pe asta.
	toate = {str(q.get("id", "")) for q in intrebari_mana + celelalte_gen}
	ciocniri = sorted(toate & {q["id"] for q in intrebari})
	if ciocniri:
		raise Eroare("id-uri folosite în amândouă fișierele: %s" % ", ".join(ciocniri))
	print("  Id-uri unice și peste restul conținutului (%d + %d + %d)."
	      % (len(intrebari_mana), len(celelalte_gen), len(intrebari)))

	print("\n══ GATA ══\n")
	return 0


if __name__ == "__main__":
	try:
		sys.exit(main())
	except Eroare as e:
		print("\nOPRIT: %s\n" % e)
		sys.exit(1)

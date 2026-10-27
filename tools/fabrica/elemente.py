#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — elementele chimice, din Wikidata.

    python tools/fabrica/elemente.py --masoara     doar măsoară: relația, etichetele,
                                                   distribuția sitelinks. Nu scrie nimic
    python tools/fabrica/elemente.py               raportul întreg, fără să scrie
    python tools/fabrica/elemente.py --scrie       scrie fișierele din data/
    python tools/fabrica/elemente.py --reincarca   reia din rețea și rescrie cache-ul

Coloanele scrise de mână stau în `tools/fabrica/date/elemente.json`, iar ce e comun
cu celelalte tabele ale fabricii în `tools/fabrica/comun.py`.

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

Ce NU poate aduce, și de-aia sunt scrise de mână în
`tools/fabrica/date/elemente.json`:

  CARE elemente sunt cultură generală pentru un adult român. Wikidata știe toate
  cele 118, inclusiv oganesson, din care s-au făcut vreo cinci atomi în total.

  CE NIVEL are fiecare. Vezi de ce a picat măsurătoarea automată la `NIVELUL`.

  GRAMATICA. „Care este simbolul chimic al aurului?" cere genitivul cu articol,
  iar el nu se poate calcula din nominativ: aur→aurului, platină→platinei.

  LA CE FOLOSEȘTE elementul (coloana `folosinta`, de pe 21 octombrie 2026).
  Wikidata are o proprietate pentru asta, „has use” (`P366`), dar e goală la 51
  din cele 70 de elemente, iar unde e plină e de nefolosit: aluminiului îi
  spune „colorant”, oxigenului „aditiv alimentar”. Vezi NOTA.

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

Deci nivelul e o coloană din `date/elemente.json`, pusă de mână. Automat rămâne o
singură verificare, îngustă și de încredere: `DIN_LATINA`.

─────────────────────────────────────────────────────────────
ACELEAȘI DOUĂ REGULI CA LA `da_iduri.py`

STRICT: orice lucru pe care scriptul nu recunoaște oprește tot. Un script care
„sare peste ce nu înțelege" produce o dată, în tăcere, o întrebare cu două
răspunsuri corecte — și n-o mai găsești niciodată între câteva mii.

UN `id` NU SE REFOLOSEȘTE NICIODATĂ. Aici e ușor: id-ul se calculează din QID-ul
elementului și din sensul relației (`wd:Q897:simbol:cere_nume`), deci e același
la fiecare rulare și nu depinde de ordinea din fișier. Dar înseamnă și că un
element SCOS din tabel își ia id-urile cu el. Dacă îl pui înapoi mai târziu,
primește exact aceleași id-uri — ceea ce e corect, fiindcă e aceeași întrebare.
Ce n-ai voie e să schimbi forma id-ului: aia rupe legătura cu orice save.
"""

import os
import re

import comun
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_elemente.json")

# Coloanele scrise de mână. Au stat până la al treilea tabel al fabricii într-o
# listă de tuple, aici în cod; acum stau în date, ca la opere și la capitale.
# Sunt o INTRARE A FABRICII, nu conținut de joc — de-aia sub `tools/`, nu sub
# `data/`.
CALE_ALESE = os.path.join(comun.DOSAR_DATE, "elemente.json")

CALE_WD = os.path.join(comun.DOSAR_GEN, "elemente_intrebari.json")
CALE_FAPTE_WD = os.path.join(comun.DOSAR_GEN, "elemente_fapte.json")

# Domeniul în care intră tot ce fabricăm aici. O singură `categorie` pe
# întrebare, ca în decizia din CLAUDE.md; filtrele transversale vor veni din
# `etichete`, pe fapt.
DOMENIU = "stiinta_tehnologie"

# Subcategoria, pe care o poartă fiecare întrebare scrisă de aici. Vezi
# `comun.SUBCATEGORII` pentru listă și `docs/plan-continut.md` pentru înțeles.
# Perechea (domeniu, subcategorie) se verifică la pornire, nu pe fiecare rând.
SUBCATEGORIE = "stiinte_exacte"

# Relația, din care se compune `id`-ul: `wd:Q897:simbol:cere_nume`.
RELATIE = "simbol"

# Cel mai mare număr atomic al unui element DESCOPERIT (oganesson, 118).
#
# Există fiindcă măsurătoarea a scos la iveală ceva ce nu bănuiam: Wikidata are
# 174 de „elemente chimice", nu 118. Restul sunt IPOTETICE, căsuțe din tabelul
# periodic cu nume sistematic (ununennium, unbinilium…), pe care nimeni nu le-a
# umplut. Iar nouă dintre ele AU etichetă în română, deci filtrul „are etichetă
# română" le-ar fi lăsat să treacă.
#
# Nu ajung în joc oricum, fiindcă tabelul e scris de mână. Dar exact
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

# UN SINGUR SENS PE ELEMENT, de pe 27 octombrie 2026. Cu amândouă, cele 70 de
# elemente dădeau 135 de întrebări — ~20% din raftul „Științe exacte” la fiecare
# nivel, pe un singur șablon, iar „simbolul argintului” și „ce element are
# simbolul Ag” se puteau trage una după alta, a doua dând răspunsul primei
# (`DISTANTA_PRACTICE` ține distanța între întrebări, nu între fapte). Al doilea
# sens nu antrenează altceva în mod real pe un raft de ~240: e același fapt,
# întâlnit de două ori în aceeași sesiune. Vezi sesiunea UN SENS PE ELEMENT.
#
# SENSUL ÎL DĂ PARITATEA NUMĂRULUI ATOMIC: par → `cere_simbol`, impar →
# `cere_nume`. Nu ordinea din listă (alternarea pe poziție), fiindcă un element
# adăugat ar muta sensul tuturor celor de după el, deci și `id`-urile lor — iar
# `id`-ul ține progresul din Practice. Paritatea e a elementului, nu a tabelului.
# Iese și aproape egal pe fiecare nivel, deci ambele forme apar peste tot.
#
# Cele două excepții, amândouă scrise în `construieste`:
#   · sensul ales nu se poate scrie (K, fără frate de literă) → celălalt;
#   · elementul e deja întrebat de mână (`DUBLURI`) → niciunul. Faptul lui
#     rămâne cel scris de mână, cu nota lui, iar elementul rămâne distractor.
def sensul(e):
	return "cere_simbol" if e["numar"] % 2 == 0 else "cere_nume"


# ─────────────────────────────────────────────────────────────
# ELEMENTELE ALESE — `tools/fabrica/date/elemente.json`
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
#
# DE CE AU IEȘIT DIN COD, la al treilea tabel. Cât timp fabrica avea un singur
# tabel, o listă de tuple în script era cel mai scurt drum. Cu trei tabele, un
# fișier de date e ce pot deschide, sorta și tăia fără să deschid un fișier de
# cod — și, mai important, e ce face ca `ciorna` să însemne același lucru la toate
# trei. Un câmp de date nu poate trăi într-o listă de tuple.
# ─────────────────────────────────────────────────────────────
CAMPURI = {"simbol", "nume", "genitiv", "nivel", "folosinta", "ciorna"}


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


# ─────────────────────────────────────────────────────────────
# REȚEAUA
# ─────────────────────────────────────────────────────────────

def ia_datele(reincarca):
	"""Răspunsul brut, din cache sau din rețea. Scrie cache-ul când îl ia.

	CE validează cache-ul stă aici, nu în modulul comun: pentru elemente e doar
	interogarea însăși, fiindcă nu se cere nimic pe bucăți. La opere sunt lista de
	autori și pragul de ediții; la capitale, criteriile de intrare.
	"""
	if not reincarca:
		pachet = comun.cache_citeste(CALE_CACHE)
		if pachet is not None:
			return pachet["raspuns"]

	brut = comun.interogheaza(INTEROGARE, "elementele chimice")
	comun.cache_scrie(CALE_CACHE, {"interogare": INTEROGARE, "raspuns": brut})
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
	randuri = comun.legaturi(brut)
	if not randuri:
		raise Eroare("Wikidata n-a întors niciun rând. Interogarea sau endpointul?")

	elemente = {}
	for rand in randuri:
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
	mai e un al treilea loc, mai ascuns: tot tabelul de mână e cheiat pe simbol,
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

def masoara(elemente, pe_simbol, randuri):
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
	nivel_din_tabel = {str(r.get("simbol", "")): int(r.get("nivel", 0)) for r in randuri}
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

def leaga_tabelul(randuri, elemente, pe_simbol):
	"""`date/elemente.json` + datele de la Wikidata → lista de lucru. Strict la fiecare pas.

	Adună TOATE neconcordanțele înainte să se oprească. Un script care cade la
	prima nepotrivire de etichetă te pune să rulezi de 20 de ori ca să repari 20
	de rânduri; ăsta le arată pe toate dintr-o dată.
	"""
	probleme = []

	simboluri = [str(r.get("simbol", "")) for r in randuri if isinstance(r, dict)]
	if len(set(simboluri)) != len(simboluri):
		duble = sorted({s for s in simboluri if simboluri.count(s) > 1})
		probleme.append("simboluri repetate în elemente.json: %s" % ", ".join(duble))
	nume = [str(r.get("nume", "")) for r in randuri if isinstance(r, dict)]
	if len(set(nume)) != len(nume):
		duble = sorted({n for n in nume if nume.count(n) > 1})
		probleme.append("nume repetate în elemente.json: %s" % ", ".join(duble))

	lista = []
	for i, rand in enumerate(randuri):
		unde = "rândul %d din elemente.json" % (i + 1)
		if not comun.verifica_campurile(rand, CAMPURI, unde, probleme):
			continue
		simbol = str(rand.get("simbol", "")).strip()
		nume_asteptat = str(rand.get("nume", "")).strip()
		genitiv = str(rand.get("genitiv", "")).strip()
		nivel = rand.get("nivel")
		folosinta = str(rand.get("folosinta", "")).strip()
		ciorna = bool(rand.get("ciorna", False))

		if not simbol or not nume_asteptat or not genitiv:
			probleme.append("%s: simbol, nume sau genitiv gol" % unde)
			continue
		# Propoziția începe cu elementul ei („Platina…", „Aurul…"), fiindcă
		# șablonul o continuă cu „Are simbolul…" — subiectul e ea. Verificarea
		# prinde și o propoziție lipită pe rândul vecinului, cea mai probabilă
		# greșeală într-un fișier de 70 de rânduri care arată toate la fel.
		if not folosinta.endswith("."):
			probleme.append("%s: `folosinta` lipsește sau nu se termină cu punct" % simbol)
			continue
		if not folosinta.lower().startswith(nume_asteptat.lower().rstrip("ă")):
			probleme.append("%s: `folosinta` nu începe cu numele elementului (%s)"
			                % (simbol, nume_asteptat))
			continue
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
			"folosinta": folosinta,
			"ciorna": ciorna,
			"numar": e["numar"],
			"sitelinks": e["sitelinks"],
		})

	if probleme:
		raise Eroare("elemente.json nu se potrivește cu Wikidata:\n  - " + "\n  - ".join(probleme))

	# Ordinea din fișier: pe nivel, apoi pe numărul atomic. Numărul atomic e
	# ordinea în care un om se uită la tabelul periodic, deci fișierul se poate
	# citi, iar un element adăugat mai târziu cade la locul lui — deci diff-ul
	# din Git arată ce s-a adăugat, nu o rearanjare.
	lista.sort(key=lambda e: (e["nivel"], e["numar"] if e["numar"] else 999))
	return lista


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

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
		for e in lista:
			# Numele sau genitivul în text → întrebarea cere SIMBOLUL.
			for forma in (e["nume"], e["genitiv"]):
				if comun.cuvant_in(text, forma):
					gasite[(e["simbol"], "cere_simbol")] = str(q.get("id", "?"))
			# Simbolul ca token în text → întrebarea cere NUMELE.
			#
			# Aici potrivirea rămâne SENSIBILĂ LA MAJUSCULE, singurul loc din
			# fabrică unde e așa: „Ce element are simbolul N?" trebuie să prindă
			# „N", dar nu fiecare „n" din text. La simboluri, majuscula e parte din
			# simbol, nu ortografie.
			if re.search(r"\b%s\b" % re.escape(e["simbol"]), text):
				gasite[(e["simbol"], "cere_nume")] = str(q.get("id", "?"))

	return comun.compara_dublurile(gasite, DUBLURI)


# ─────────────────────────────────────────────────────────────
# DISTRACTORII
# ─────────────────────────────────────────────────────────────

def punctaj(tinta, e):
	"""Cât de plauzibil e `e` ca distractor la `cere_nume` (numele pe butoane).

	Regula pornește de la cerința ta: la „simbolul aurului", Ag și Al, nu Xe.

	  +100  element al cărui simbol începe cu litera simbolului cerut
	        (Hg → hidrogen, heliu) — adică exact confuzia „H trebuie să fie
	        hidrogen".
	  +50   nume care începe cu litera simbolului cerut.
	  +10/5 același nivel / nivel vecin; 0 la doi niveluri distanță.

	La `cere_simbol` (simbolurile pe butoane) e `punctaj_simbol`, mai jos.
	"""
	p = 0
	if e["simbol"][0] == tinta["simbol"][0]:
		p += 100
	if e["nume"][0].lower() == tinta["simbol"][0].lower():
		p += 50
	if e["nivel"] == tinta["nivel"]:
		p += 10
	elif abs(e["nivel"] - tinta["nivel"]) == 1:
		p += 5
	return p


# ── LA `cere_simbol`: TOATE CELE 118, PLUS SIMBOLURI INVENTATE ──
#
# Până pe 21 octombrie 2026 și simbolurile se alegeau dintre cele 70 din tabel,
# în banda de nivel. Așa a ieșit, în Practice:
#
#   Care este simbolul chimic al iodului?   Ne / C / I / Ni
#
# Iodul n-avea niciun frate pe litera I în bandă, deci distractorii au ieșit din
# ruperea egalităților, iar răspunsul era singurul buton care seamănă cu
# „iod”. Măsurat pe toate 69 (aurul e în fișierul de mână): la 20 răspunsul era
# SINGURUL buton care se poate citi ca prescurtare a numelui (`seamana`) — de la
# litiu, oxigen, iod și uraniu până la galiu, rubidiu și osmiu. După: la 0, cu
# 21 de simboluri inventate în 13 întrebări.
#
# DOUĂ SCHIMBĂRI, și amândouă țin numai de sensul ăsta:
#
# 1. FONDUL SUNT TOATE CELE 118 ELEMENTE DESCOPERITE, nu cele 70. Banda de nivel
#    apără de „trei nume obscure lângă unul celebru”, dar pe butoane stau
#    SIMBOLURI, iar In și Ir nu arată mai obscur decât I. Iodul primește așa In
#    și Ir, oxigenul Os și Og.
#
# 2. UNDE ALFABETUL REAL SE TERMINĂ, SIMBOLURI INVENTATE. U, W, X și Z n-au
#    frați deloc printre cele 118 (Zn are doar Zr), deci la uraniu, wolfram,
#    xenon și zinc niciun fond real nu poate ascunde răspunsul. Atunci se
#    inventează din numele cerut: litera lui întâi plus una din literele lui
#    (uraniu → Ur, Un, Ua). Numai la elementele al căror simbol pornește de la
#    numele românesc, fiindcă acolo e scurtătura; nu la cele din `DIN_LATINA`.
#
#    E singurul loc din fabrică în care pe un buton stă ceva ce nu există, și
#    l-am cântărit: nu predă nimic fals, fiindcă stă doar pe un buton GREȘIT, iar
#    întrebarea pe care o pune („U sau Ur?”) e exact cea pe care trebuie s-o
#    știi. Un „inventat” care se întâmplă să fie real (Ir la iod) nu e lăsat
#    să treacă drept inventat: `simbolurile_inventate` scade toate cele 118.
#
# Ordinea: întâi simbolurile reale cu litera răspunsului, apoi cele inventate,
# apoi restul. Deci inventatele apar DOAR unde cele reale nu ajung.

def seamana(simbol, nume):
	"""Se poate citi `simbol` ca prescurtare a lui `nume`? (Og ← oxigen, Ag ← argint)

	Prima literă a simbolului e prima a numelui, iar celelalte apar în nume, în
	ordine. E testul „subșir” pe care docstring-ul de sus îl respinge ca măsură a
	NIVELULUI — acolo greșea în ambele direcții. Aici nu decide nimic despre
	element, doar ordonează distractorii: un simbol care SEAMĂNĂ cu numele e mai
	tentant decât unul care doar începe la fel.
	"""
	s = simbol.lower()
	n = nume.lower()
	if s[0] != n[0]:
		return False
	de_la = 1
	for litera in s[1:]:
		gasit = n.find(litera, de_la)
		if gasit < 0:
			return False
		de_la = gasit + 1
	return True


def simbolurile_inventate(tinta, reale):
	"""Simbolurile care NU există, făcute din numele cerut. Vezi mai sus.

	Doar litere fără diacritice: un simbol chimic n-are niciodată „ț” sau „ă”.
	Și fără litera întâi dublată: „Uu” din uraniu și „Ii” din indiu se văd de
	departe că nu sunt simboluri, deci n-ar ascunde nimic.
	"""
	if tinta["simbol"] in DIN_LATINA:
		return []
	if tinta["simbol"][0].lower() != tinta["nume"][0].lower():
		return []
	prima = tinta["nume"][0].upper()
	inventate = {prima} | {prima + l for l in tinta["nume"][1:]
	                         if "a" <= l <= "z" and l != prima.lower()}
	inventate.discard(tinta["simbol"])
	return sorted(inventate - reale)


def punctaj_simbol(tinta, simbol, inventat, alese):
	"""Cât de plauzibil e `simbol` ca distractor la `cere_simbol`.

	  +100  aceeași primă literă ca simbolul corect (I → In, Ir)
	  +50   seamănă cu numele cerut (oxigen → Og)
	  +20   prima lui literă apare în numele cerut (zinc → Nb)
	  +5    e unul din cele 70 din tabel: un distractor pe care-l vei întâlni și
	        ca răspuns devine o lecție mai târziu
	  110   fix, pentru unul inventat: sub orice simbol real cu litera
	        răspunsului (cel puțin 120), peste orice alt simbol real (cel mult 25)
	"""
	if inventat:
		return 110
	p = 0
	if simbol[0] == tinta["simbol"][0]:
		p += 100
	if seamana(simbol, tinta["nume"]):
		p += 50
	if simbol[0].lower() in tinta["nume"]:
		p += 20
	if simbol in alese:
		p += 5
	return p


def alege_simbolurile(tinta, lista, reale):
	"""Cei trei distractori la `cere_simbol`, deterministic. Întoarce simboluri."""
	alese = {e["simbol"] for e in lista}
	inventate = simbolurile_inventate(tinta, reale)
	candidati = ([(s, False) for s in sorted(reale) if s != tinta["simbol"]]
	             + [(s, True) for s in inventate])
	candidati.sort(key=lambda c: (-punctaj_simbol(tinta, c[0], c[1], alese),
	                              comun.zar(tinta["qid"], "cere_simbol", c[0])))
	ordonati = [s for s, _ in candidati]
	alesi = rupe_grupul_strain(tinta, ordonati)

	# A DOUA GARDĂ, numai aici: răspunsul n-are voie să fie SINGURUL buton care
	# seamănă cu numele. Punctajul nu ajunge singur la sulf: S, Sb, Sc, Sn sunt
	# toate reale și pe litera S, deci trec înaintea celor inventate, dar niciunul
	# nu se citește din „sulf”. Atunci ultimul se schimbă cu primul care seamănă,
	# real dacă există, inventat dacă nu.
	if not any(seamana(s, tinta["nume"]) for s in alesi):
		for candidat in ordonati[3:]:
			if seamana(candidat, tinta["nume"]):
				alesi[2] = candidat
				break
	return alesi


def alege_distractorii(tinta, lista, rezerva):
	"""Cei trei distractori la `cere_nume`, deterministic. Întoarce nume.

	PRIMA PLASĂ E BANDA DE NIVEL, și merită spus de ce nu e alta. Am scris
	întâi o gardă „dacă toți trei distractorii încep cu o literă pe care
	răspunsul n-o are, schimbă unul" — și am aruncat-o. „Ce element are simbolul
	Hg?" cu mercur / hidrogen / heliu e o întrebare bună, iar garda ar fi
	stricat-o: tiparul acolo duce DEPARTE de răspuns, deci cine se ia după el
	greșește. Aia e pedagogie, nu scurtătură.

	O scurtătură e tiparul care duce SPRE răspuns, iar singura formă în care
	apare aici e disparitatea de familiaritate: trei nume obscure lângă unul
	celebru se recunoaște fără să știi nimic. De-aia toate patru opțiunile stau
	în aceeași bandă de nivel (±1).

	A DOUA PLASĂ, de pe 21 octombrie 2026: banda poate tăia ALFABETUL. Jucând
	s-a văzut „Ce element chimic are simbolul U?” cu siliciu / uraniu / litiu /
	neon: răspunsul era singurul nume pe litera simbolului. Măsurat, așa erau 10
	din 70 (litiu, oxigen, titan, zinc, iod, uraniu, kripton, xenon, wolfram,
	osmiu), fiindcă frații lor de literă (indiu și iridiu lângă iod, tantal lângă
	titan) stăteau la doi niveluri distanță.

	Deci, dacă niciun distractor nu e pe litera simbolului, ULTIMUL se schimbă cu
	un frate de literă: întâi din restul tabelului, apoi din `rezerva` —
	celelalte elemente descoperite, cu eticheta lor română de la Wikidata
	(lutețiu lângă litiu, zirconiu lângă zinc). UNUL SINGUR, dinadins. Prima
	probă a lăsat literele să bată nivelul peste tot, și a stricat întrebări bune:
	neonul își pierdea capcanele (azot, sodiu) pentru niobiu și neodim, iar
	litiul primea trei nume pe care nu le-a auzit nimeni. Cu un singur frate,
	alfabetul nu mai ajunge, iar familiaritatea nici ea: lângă lutețiu mai stau
	titan și heliu, la fel de cunoscute ca litiul.
	"""
	banda = [e for e in lista
	         if e["simbol"] != tinta["simbol"] and abs(e["nivel"] - tinta["nivel"]) <= 1]
	if len(banda) < 3:
		banda = [e for e in lista if e["simbol"] != tinta["simbol"]]
	if len(banda) < 3:
		raise Eroare("%s: mai puțin de 3 distractori posibili" % tinta["simbol"])

	banda.sort(key=lambda e: (-punctaj(tinta, e),
	                          comun.zar(tinta["qid"], "cere_nume", e["qid"])))
	alesi = rupe_grupul_strain(tinta, [e["nume"] for e in banda])

	litera = tinta["simbol"][0].lower()
	if not any(n[0] == litera for n in alesi):
		din_banda = {e["simbol"] for e in banda}
		restul_tabelului = sorted(
			(e for e in lista if e["simbol"] != tinta["simbol"] and e["simbol"] not in din_banda),
			key=lambda e: (-punctaj(tinta, e), comun.zar(tinta["qid"], "cere_nume", e["qid"])))
		din_rezerva = sorted(rezerva, key=lambda e: comun.zar(tinta["qid"], "cere_nume", e["qid"]))
		for e in restul_tabelului + din_rezerva:
			if e["nume"][0] == litera:
				alesi[2] = e["nume"]
				break
	return alesi


def rupe_grupul_strain(tinta, ordonati):
	"""Primii trei din `ordonati` (textele de pe butoane), cu singura gardă a ambelor sensuri."""
	alesi = ordonati[:3]

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
	litere = {a[0].lower() for a in alesi}
	if len(litere) == 1:
		litera = next(iter(litere))
		despre_intrebare = {tinta["simbol"][0].lower(), tinta["nume"][0].lower()}
		if litera not in despre_intrebare:
			for candidat in ordonati[3:]:
				if candidat[0].lower() != litera:
					alesi[2] = candidat
					break

	return alesi


# ─────────────────────────────────────────────────────────────
# NOTA („AFLĂ MAI MULTE")
#
# TREI BUCĂȚI: la ce folosește elementul, simbolul cu numărul atomic, și, la
# cele 9 din `DIN_LATINA`, de unde vine simbolul.
#
# ── ÎNTÂI FOLOSINȚA, SCRISĂ DE MÂNĂ (21 octombrie 2026) ───────
# Până azi nota era doar „Simbolul chimic al aluminiului este Al, iar numărul lui
# atomic este 13." — corectă, dar goală: îți spunea înapoi răspunsul de pe
# buton. Cererea a fost „vreau să aflu la ce e folosit aluminiul". Wikidata nu
# poate răspunde (vezi docstring-ul, la `P366`), deci propoziția stă în coloana
# `folosinta` din `elemente.json`, una pe element, scrisă de mână.
#
# Asta calcă principiul „modelul de limbaj formulează, nu informează", și o spun
# pe față: sursa propozițiilor sunt eu, ca la cele 2046 de note din TOATE AU
# NOTĂ. Prețul e ținut mic în două feluri:
#
#   - conținutul e de manual: folosințele cunoscute ale fiecărui element (doze
#     de aluminiu, filamente de wolfram, ceasuri cu cesiu), nu detalii fine;
#   - `folosinta` NU intră în `surse` când se validează nota. Deci validatorul o
#     ține în continuare din scurt: nicio cifră și niciun nume propriu în ea,
#     fiindcă n-ar avea în ce date să se sprijine. Exact acolo stau greșelile
#     care sună bine („un număr cu o jumătate de grad pe lângă", vezi TOATE AU
#     NOTĂ). Ce rămâne neapărat de nimic e afirmația în cuvinte — aia se citește.
#
# Simbolul și numărul atomic rămân, dar trec pe locul doi și se scurtează: „Are
# simbolul chimic Al și numărul atomic 13." N-are gen, deci repară și „numărul
# lui atomic" spus platinei.
#
# ── DE CE NUMĂRUL ATOMIC E UN CÂRLIG, ȘI NU O REPETIȚIE ───────
# `ghid-note.md` §2.2 cere ca nota să adauge ceva, nu să repete întrebarea.
# Cele două întrebări ale tabelului cer simbolul sau numele, deci răspunsul e
# deja aprins pe buton când apare nota. Numărul atomic nu e întrebat de niciuna
# din ele: e locul elementului în tabelul periodic, singurul fapt în plus pe
# care-l am despre el și care nu se învechește niciodată.
#
# ── A DOUA PROPOZIȚIE, DOAR LA CELE 9 DIN `DIN_LATINA` ────────
# Acolo cârligul e „confuzia frecventă" (§3), cel mai bun dintre toate: Na nu
# pornește de la „sodiu", iar jucătorul care a greșit tocmai a greșit din motivul
# ăsta. Afirmația NU e a mea — e chiar înțelesul declarat al lui `DIN_LATINA`,
# scris de mână și folosit deja ca regulă de nivel (vezi `leaga_tabelul`). O
# folosesc ca dată, nu ca amintire.
#
# Lungimea: cu folosința, notele ajung la 150–240 de caractere, în §2.3. La cele
# 9 din `DIN_LATINA` folosința e scrisă mai scurt, ca să încapă și propoziția
# despre latină sub `MAX_NOTA`; validatorul oprește dacă nu încape.
# ─────────────────────────────────────────────────────────────

def compune_nota(e):
	"""Un element → (nota, valorile din care e făcută)."""
	nota = ("%s Are simbolul chimic %s și numărul atomic %d."
	        % (e["folosinta"], e["simbol"], e["numar"]))
	if e["simbol"] in DIN_LATINA:
		nota += " Simbolul vine din numele latin, nu din cel românesc."
	# Valorile îi ajung validatorului exact așa cum au intrat în șablon — fără
	# `folosinta`, dinadins (vezi mai sus).
	return nota, [e["genitiv"], e["nume"], e["simbol"], e["numar"]]


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ÎNTREBĂRILOR
# ─────────────────────────────────────────────────────────────

def construieste(lista, reale, rezerva):
	"""Lista de elemente + cele 118 → (întrebări, fapte, probleme, fără pereche).

	`reale` sunt simbolurile tuturor celor 118, `rezerva` cele care nu sunt în
	tabel, cu nume (vezi `alege_distractorii`).
	"""
	fara_pereche = []
	intrebari = []
	for e in lista:
		# Întrebat deja de mână, în oricare sens: elementul își are întrebarea.
		if any(s == e["simbol"] for s, _ in DUBLURI):
			continue
		ales = sensul(e)
		# Sensul ales întâi, celălalt doar dacă primul nu se poate scrie.
		for sens in [ales] + [s for s in SENSURI if s != ales]:
			if sens == "cere_simbol":
				text = "Care este simbolul chimic al %s?" % e["genitiv"]
				bun = e["simbol"]
				restul = alege_simbolurile(e, lista, reale)
			else:
				text = "Ce element chimic are simbolul %s?" % e["simbol"]
				bun = e["nume"]
				restul = alege_distractorii(e, lista, rezerva)
				# ── FĂRĂ PERECHE: ÎNTREBAREA NU SE SCRIE ──
				# U, W, X și K n-au niciun alt element pe litera lor, printre
				# toate cele 118. „Ce element are simbolul U?” se rezolvă atunci
				# din alfabet, oricare ar fi distractorii, iar un nume de element
				# INVENTAT nu e o ieșire: la `cere_simbol` „Ur” e o prescurtare
				# care nu există, aici ar fi un element care nu există — un lucru
				# fals de ținut minte. Deci întrebarea lipsește, iar sensul
				# celălalt („simbolul uraniului”) rămâne. Regula e o măsurătoare,
				# nu o listă: dacă tabelul primește un frate de literă, întrebarea
				# revine singură, cu același `id`.
				litera = e["simbol"][0].lower()
				if not any(n[0] == litera for n in restul):
					fara_pereche.append(e["simbol"])
					continue

			# Poziția răspunsului bun, `id`-ul și verificarea celor patru variante
			# distincte stau în `comun.pune_la_locul_lui` — sunt aceleași la toate
			# tabelele fabricii, inclusiv motivul (vezi docstring-ul de acolo).
			intrebari.append(comun.pune_la_locul_lui(
				cheie=e["qid"],
				relatie=RELATIE,
				sens=sens,
				text=text,
				bun=bun,
				restul=restul,
				nivel=e["nivel"],
				fapt="wd:%s" % e["qid"],
				domeniu=DOMENIU,
				subcategorie=SUBCATEGORIE,
				eticheta=e["simbol"],
			))
			break   # una pe element — vezi `sensul`

	# ── VERIFICAREA „EXACT UNA DIN PATRU E CORECTĂ" ──
	# Nouă la refactor, și n-a fost o adăugire gratuită: până acum elementele se
	# sprijineau doar pe `verifica_relatia` (relația e unu-la-unu) plus pe cele
	# patru variante distincte. Alea apără PRESUPUNEREA; asta apără REZULTATUL.
	# Opere o avea, elementele nu — iar un modul comun e exact locul în care o
	# plasă scrisă pentru un tabel ajunge la toate. N-a schimbat niciun octet din
	# fișierele scrise: a trecut din prima.
	pe_simbol_ales = {e["simbol"]: e for e in lista}
	pe_nume_ales = {e["nume"]: e for e in lista}

	def este_corect(q, varianta):
		qid = q["id"].split(":")[1]
		if q["id"].endswith("cere_simbol"):
			# Varianta e un simbol. E al elementului întrebat? Unul din afara
			# tabelului, sau unul inventat, nu e al nimănui din tabel — deci greșit.
			gasit = pe_simbol_ales.get(varianta)
		else:
			# Varianta e un nume de element. E numele elementului întrebat?
			gasit = pe_nume_ales.get(varianta)
		return gasit is not None and gasit["qid"] == qid

	comun.verifica_un_singur_raspuns(intrebari, este_corect)

	# ── FAPTELE, CU NOTĂ ──
	#
	# Vechea grijă din `docs/progres.md` („fișierul se rescrie întreg, deci notele
	# `wd:` nu pot sta în el") S-A DIZOLVAT, și merită spus de ce: ea presupunea
	# note scrise DE MÂNĂ, care s-ar fi pierdut la prima regenerare. O notă
	# compusă de șablon se recompune la fiecare rulare, din aceleași date, deci
	# n-are ce să se piardă. Nici varianta 1 (notele în fișierul de mână), nici
	# varianta 2 (scriptul păstrează notele vechi) nu mai sunt necesare.
	#
	# Dacă vreodată un fapt `wd:` are nevoie de o notă scrisă de mână, ziua aia
	# readuce decizia — dar atunci va fi despre UN fapt, nu despre toate.
	probleme = []
	fapte = []
	# Doar faptele pe care le cere o întrebare: un element întrebat numai de mână
	# (aurul) și-a păstrat faptul de mână, iar unul `wd:` fără întrebare ar pica
	# „niciun fapt nefolosit” din `verifica_trivia`.
	cerute = {q["fapt"] for q in intrebari}
	for e in lista:
		if "wd:%s" % e["qid"] not in cerute:
			continue
		nota, surse = compune_nota(e)
		# VALIDATĂ UNA CU UNA, nu pe un eșantion: costă microsecunde, iar un
		# șablon stricat strică toate cele 70 deodată, nu una.
		comun.verifica_nota(nota, surse, "wd:%s (%s)" % (e["qid"], e["simbol"]),
		                    probleme)
		fapte.append({
			"id": "wd:%s" % e["qid"],
			"nota": nota,
			"surse": ["https://www.wikidata.org/wiki/%s" % e["qid"]],
			"verificat": False,
		})

	return intrebari, fapte, probleme, fara_pereche




# ─────────────────────────────────────────────────────────────

def main():
	arg = comun.argumentele()
	# O dată, pe constantele tabelului: o subcategorie scrisă greșit aici ar face
	# ca `trivia.gd` să refuze TOATE întrebările tabelului — s-ar vedea în bilanț,
	# dar după ce s-a scris fișierul, nu înainte.
	comun.verifica_subcategoria(DOMENIU, SUBCATEGORIE)

	print("\n══ FABRICA: ELEMENTELE CHIMICE ══\n")

	randuri = comun.citeste_lista(CALE_ALESE, "elementele alese")

	brut = ia_datele(arg.reincarca)
	elemente = desfa(brut)
	pe_simbol = verifica_relatia(elemente)
	print("  Relația element ↔ simbol: unu-la-unu, verificată pe toate cele %d."
	      % len(elemente))

	masoara(elemente, pe_simbol, randuri)
	if arg.masoara:
		print("\n══ DOAR MĂSURAT. Nimic scris. ══\n")
		return 0

	lista_toata = leaga_tabelul(randuri, elemente, pe_simbol)

	# CIORNELE SE SCOT AICI, ÎNAINTE DE CONSTRUIRE, nu la sfârșit: distractorii se
	# aleg dintre elementele alese, deci o ciornă lăsată în listă ar ajunge
	# distractor într-o întrebare scrisă în `data/`. Mecanismul a venit de la opere;
	# aici nu e nicio ciornă azi, dar înseamnă același lucru la toate trei tabelele.
	ciorne = [e for e in lista_toata if e["ciorna"]]
	lista = [e for e in lista_toata if not e["ciorna"]] if arg.scrie else lista_toata
	comun.raporteaza_ciornele(lista_toata, ciorne, len(lista), arg.scrie, "elemente")

	intrebari_mana = comun.citeste_lista(comun.CALE_MANA, "întrebările scrise de mână")
	# DUBLURILE SE CAUTĂ PE TABELUL ÎNTREG, ciorne incluse: suprapunerea cu
	# fișierul de mână e o însușire a TABELULUI, nu a ce s-a confirmat azi.
	dubluri = verifica_dublurile(lista_toata, intrebari_mana)
	print("    dubluri cu fișierul scris de mână: %d  (%s)" % (
		len(dubluri),
		", ".join("%s/%s ← %s" % (s, sens, id_) for (s, sens), id_ in sorted(dubluri.items()))
		or "niciuna"))

	# Fondul de distractori la `cere_simbol`: cele 118 descoperite, nu doar cele
	# alese (vezi `alege_simbolurile`). Fără căsuțele ipotetice, din același
	# motiv ca la ZMAX.
	reale = {e["simbol"] for e in elemente.values()
	         if e["numar"] and 1 <= e["numar"] <= ZMAX}
	# Rezerva de NUME la `cere_nume`: cele descoperite care nu sunt în tabel, cu
	# eticheta română a Wikidata. Unul fără etichetă română nu poate sta pe un
	# buton, deci nu intră.
	din_tabel = {e["simbol"] for e in lista_toata}
	rezerva = sorted(({"qid": e["qid"], "simbol": e["simbol"],
	                   "nume": e["eticheta"].lower(), "nivel": None}
	                  for e in elemente.values()
	                  if e["simbol"] in reale and e["simbol"] not in din_tabel
	                  and e["eticheta"]),
	                 key=lambda e: e["qid"])
	intrebari, fapte, probleme_note, fara_pereche = construieste(lista, reale, rezerva)
	print("    generate: %d întrebări, %d fapte" % (len(intrebari), len(fapte)))
	print("    fără pereche, „ce element are simbolul…” nescrise: %d  (%s)"
	      % (len(fara_pereche), ", ".join(fara_pereche) or "niciuna"))
	print("    „exact una din patru e corectă”: verificat pe toate %d" % len(intrebari))
	comun.raporteaza_notele(fapte, probleme_note, arg.scrie)
	din_latina = sum(1 for e in lista if e["simbol"] in DIN_LATINA)
	print("          cu a doua propoziție (din DIN_LATINA): %d" % din_latina)

	# Grila arată TOT conținutul din joc, nu doar tabelul rulat acum: de când sunt
	# mai multe fabrici, un raport care se uită doar la el însuși minte cu jumătăți
	# de adevăr.
	celelalte_gen = comun.citeste_dosarul_generat(CALE_WD)
	comun.grila(intrebari_mana, celelalte_gen + intrebari)
	comun.cat_din_lupta(intrebari_mana, celelalte_gen + intrebari, intrebari,
	                    DOMENIU, "„ELEMENT ↔ SIMBOL”")
	if intrebari:
		comun.mostre(intrebari, 15, arg.samanta)

	if not arg.scrie:
		print("\n══ PROBĂ USCATĂ. Rulează cu --scrie ca să scrie fișierele. ══\n")
		return 0

	comun.scrie_lista(CALE_WD, intrebari,
	                  comun.ORDINEA_INTREBARII, "nivel")
	comun.scrie_lista(CALE_FAPTE_WD, fapte, comun.ORDINEA_FAPTULUI, "")
	print("\n  Scris:")
	print("    %s" % comun.relativ(CALE_WD))
	print("    %s" % comun.relativ(CALE_FAPTE_WD))

	comun.verifica_inapoi(CALE_WD, len(intrebari))
	comun.verifica_inapoi(CALE_FAPTE_WD, len(fapte))
	print("  Citit înapoi: JSON valid, id-uri unice în amândouă.")

	# Și unicitatea PESTE tot conținutul. `mana:` și `wd:` nu se pot ciocni, dar
	# verificarea nu costă nimic și nu se sprijină pe asta.
	toate = {str(q.get("id", "")) for q in intrebari_mana + celelalte_gen}
	ciocniri = sorted(toate & {q["id"] for q in intrebari})
	if ciocniri:
		raise Eroare("id-uri folosite în două fișiere: %s" % ", ".join(ciocniri))
	print("  Id-uri unice și peste restul conținutului (%d + %d + %d)."
	      % (len(intrebari_mana), len(celelalte_gen), len(intrebari)))
	if ciorne:
		print("  Rămase ciorne, neconfirmate: %d." % len(ciorne))

	print("\n══ GATA ══\n")
	return 0


if __name__ == "__main__":
	comun.ruleaza(main)

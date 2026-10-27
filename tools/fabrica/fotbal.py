#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — turneele de fotbal ale echipelor naționale, pe ediție.

    python tools/fabrica/fotbal.py --propune    toate edițiile cu câștigătoare, în
                                                `date/fotbal_propuse.json`
    python tools/fabrica/fotbal.py --masoara    doar măsoară: ce întoarce Wikidata
    python tools/fabrica/fotbal.py              raportul întreg, fără să scrie
    python tools/fabrica/fotbal.py --scrie      scrie perechea din data/trivia_gen/
    python tools/fabrica/fotbal.py --reincarca  reia din rețea și rescrie cache-ul

Produce `data/trivia_gen/fotbal_intrebari.json` și `fotbal_fapte.json`. Motorul e
`tabel.py`; aici stă ce e AL FOTBALULUI: ce competiții, cum se citește
câștigătoarea, cum sună întrebarea și nota.

─────────────────────────────────────────────────────────────
CE ÎNTREABĂ

Pentru fiecare ediție aleasă în `date/fotbal.json`, două întrebări:

    cere_castigatoare   „Ce țară a câștigat Cupa Mondială de fotbal din 1998?”
    cere_gazda          „Ce țară a găzduit Cupa Mondială de fotbal din 1998?”

Faptul e EDIȚIA (`wd:Q101730`), nu țara: o țară e deja fapt în tabelul
capitalelor (`wd:Q142`), iar nota ei vorbește despre Paris, nu despre fotbal.

Palmaresul e o listă finită și datată din construcție — regula „numai trecut, cu
data spusă” de la Sport nu e aici o constrângere, e forma datelor.

─────────────────────────────────────────────────────────────
CAPCANELE, MĂSURATE PE 27 OCTOMBRIE 2026

1. `P1346` („câștigător”) ȚINE ȘI FINALISTA. La Euro 2004 sunt două declarații,
   Grecia cu rolul „Campion” și Portugalia cu rolul „runner-up” (`P2501`). Deci
   câștigătoarea e declarația FĂRĂ rol sau cu rolul „Campion”; orice alt rol se
   lasă afară, iar un rol pe care nu-l cunosc OPREȘTE (`ROLURI`).

2. CÂȘTIGĂTORUL E O ECHIPĂ, NU O ȚARĂ. Țara vine din echipă: `P1532` („țara pentru
   sport”), apoi `P17`. Așa iese „Germania” pentru 1954, 1974 și 1990 — echipa
   națională a Germaniei e un singur item la Wikidata, ca în palmaresul FIFA, care
   numără patru titluri ale Germaniei. Nota nu spune „RF Germania”, fiindcă datele
   nu o spun.

3. GAZDA POATE FI MAI MULTE ȚĂRI (2002: Japonia și Coreea de Sud; Euro 2000, 2008,
   2012). Atunci nu se pune `cere_gazda`: un buton verde pentru una din două țări
   ar fi jumătate de adevăr. Nota le spune pe toate.

4. ANUL DIN NUME POATE FI ALTUL DECÂT ANUL JOCULUI. Euro 2020 s-a jucat în 2021.
   O ediție la care anul din etichetă nu e anul din `P585` se REFUZĂ și se
   tipărește — întrebarea ar fi fost corectă și ar fi sunat greșit.

6. LA CLUBURI (Liga Campionilor, fosta Cupă a Campionilor Europeni) totul e
   altfel, și măsurat: ediția e un SEZON („1977-1978”), `P585` lipsește la
   jumătate din ele, iar printre ediții sunt și fazele („faza eliminatorie”) și un
   item CONTOPIT, „Cupa Campionilor Europeni 1985-1986, 1986-1987, 2000-2001”,
   cu un singur câștigător pentru trei sezoane. Deci sezonul se citește din
   eticheta română, cu un tipar strict (`SEZON_CLUBURI`), iar ce nu se potrivește
   nu e ediție. Prețul, scris: sezonul 1985-1986 (Steaua) nu intră — și e deja
   întrebat de mână.

5. EDIȚIILE PREA PROASPETE nu se aleg. Cupa Mondială din 2026 are câștigătoare la
   Wikidata, dar e o declarație de câteva luni, pe care n-am cu ce s-o compar.
   Nu e o oprire în cod, e o absență din `date/fotbal.json`, scrisă aici.
"""

import os
import re

import comun
import tabel
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_fotbal.json")
CALE_LISTA = os.path.join(comun.DOSAR_DATE, "fotbal.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "fotbal_propuse.json")

CAMPURI = {"qid", "nume", "nivel", "nivel_gazda"}

# Competiția (`P3450` pe ediție) → cum se numește în întrebare. Numele e scris de
# mână, dinadins: eticheta Wikidata a ediției e „Campionatul Mondial de Fotbal
# 1998”, dar în română se spune „Cupa Mondială”, și așa o întreabă deja
# întrebările scrise de mână.
COMPETITII = {
	"Q19317": "Cupa Mondială de fotbal",
	"Q19323": "Cupa Mondială de fotbal feminin",
	"Q260858": "Campionatul European de fotbal",
	# Numele de aici nu se folosește în întrebare: competiția și-a schimbat
	# numele în 1992, iar întrebarea îl spune pe cel din sezonul ei, citit din
	# eticheta română (vezi `SEZON_CLUBURI`).
	"Q18756": "Liga Campionilor",
}

# Competițiile de CLUBURI. Aici câștigătorul e chiar echipa (nu țara ei), nu
# există gazdă, iar ediția e un SEZON, nu un an — vezi capcana 6.
CLUBURI = {"Q18756"}

# Eticheta română a unui sezon adevărat. Strictă dinadins: lasă afară fazele
# („Faza eliminatorie a Ligii Campionilor 2011-2012”) și itemul contopit
# „Cupa Campionilor Europeni 1985-1986, 1986-1987, 2000-2001”.
SEZON_CLUBURI = re.compile(r"^(Liga Campionilor|Cupa Campionilor Europeni) (\d{4})-(\d{4})$")

# Ultimul sezon luat. Finala din 2026 e de câteva luni, iar declarația ei n-are
# încă cu ce să fie comparată — aceeași regulă ca la Cupa Mondială din 2026.
ULTIMUL_SEZON = 2025

# Rolurile de pe `P1346`. `True` = câștigătoarea, `False` = altcineva. Un rol care
# nu e aici OPREȘTE: listă albă, din același motiv ca la licențele imaginilor.
ROLURI = {
	"Q852061": True,     # Campion
	"Q3275569": False,   # runner-up — finalista de la Euro 2004
}

# Nume de țări care pot fi, după cine întreabă, ACELAȘI răspuns: „Germania” și
# „Germania de Vest” (echipa Germaniei a câștigat 1954, 1974 și 1990 ca RFG;
# Euro 1988 s-a ținut în „Germania de Vest”), „Regatul Unit” și „Anglia” (Euro
# 1996), „Uniunea Sovietică” și „Rusia”. Niciunul nu are voie să fie distractor
# când celălalt e răspunsul bun: un jucător care alege „Germania” pentru 1988 n-a
# greșit. Măsurat la scriere, nicio întrebare nu le avea împreună — dar numai din
# norocul distanțelor, iar o regulă nu se lasă pe noroc.
ECHIVALENTE = [
	{"Germania", "Germania de Vest"},
	{"Regatul Unit", "Anglia"},
	{"Uniunea Sovietică", "Rusia"},
]


def cu_echivalentele(raspunsuri):
	tot = set(raspunsuri)
	for grup in ECHIVALENTE:
		if tot & grup:
			tot |= grup
	return sorted(tot)


# Întrebări generate care întreabă ce întreabă deja una scrisă de mână.
# `id` generat → `id`-ul celei existente. Vezi `tabel.Tabel._scoate_dublurile`.
DUBLURI = {
	"wd:Q101751:turneu:cere_castigatoare": "mana:0199",   # 1994, Brazilia
	"wd:Q170645:turneu:cere_castigatoare": "mana:0268",   # 2018, Franța
	"wd:Q176883:turneu:cere_castigatoare": "mana:0349",   # 2010, Spania „în Africa de Sud”
	"wd:Q176883:turneu:cere_gazda": "mana:0349",          # …deci și gazda e spusă acolo
	"wd:Q284163:turneu:cere_castigatoare": "mana:1833",   # 2022, Argentina
	"wd:Q37285:turneu:cere_castigatoare": "mana:1879",    # „antrenorul din 2006, cu Italia”
	"wd:Q48432:turneu:cere_gazda": "mana:0207",           # 1930, gazda Uruguay
	# Câștigătoarea din 1930 e tot Uruguay: întrebarea ar fi alta, dar răspunsul
	# l-ai citit deja în cealaltă, deci n-ar întreba nimic.
	"wd:Q48432:turneu:cere_castigatoare": "mana:0207",
}

# Potriviri citite care NU întreabă același lucru. Se păstrează.
NU_SUNT_DUBLURI = {
	# Euro 2004 → Grecia; cea de mână e despre Jocurile Olimpice de la Atena, 2004.
	"wd:Q102920:turneu:cere_castigatoare": "mana:0212",
}

_VALORI = " ".join("wd:%s" % q for q in COMPETITII)

INTEROGARI = {
	"editii": """SELECT ?e ?comp ?e_ro ?e_en ?e_mul (MIN(YEAR(?d)) AS ?an) WHERE {
  VALUES ?comp { %s }
  ?e wdt:P3450 ?comp .
  OPTIONAL { ?e wdt:P585 ?d }
  OPTIONAL { ?e rdfs:label ?e_ro FILTER(lang(?e_ro) = "ro") }
  OPTIONAL { ?e rdfs:label ?e_en FILTER(lang(?e_en) = "en") }
  OPTIONAL { ?e rdfs:label ?e_mul FILTER(lang(?e_mul) = "mul") }
} GROUP BY ?e ?comp ?e_ro ?e_en ?e_mul""" % _VALORI,

	"castigatori": """SELECT ?e ?st ?w ?w_ro ?w_en ?w_mul ?rol ?tara ?tara_ro ?tara_en ?tara_mul WHERE {
  VALUES ?comp { %s }
  ?e wdt:P3450 ?comp ; p:P1346 ?st .
  ?st ps:P1346 ?w .
  OPTIONAL { ?st pq:P2501 ?rol }
  OPTIONAL { ?w rdfs:label ?w_ro FILTER(lang(?w_ro) = "ro") }
  OPTIONAL { ?w rdfs:label ?w_en FILTER(lang(?w_en) = "en") }
  OPTIONAL { ?w rdfs:label ?w_mul FILTER(lang(?w_mul) = "mul") }
  OPTIONAL { ?w wdt:P1532 ?t1 }
  OPTIONAL { ?w wdt:P17 ?t2 }
  BIND(COALESCE(?t1, ?t2) AS ?tara)
  OPTIONAL { ?tara rdfs:label ?tara_ro FILTER(lang(?tara_ro) = "ro") }
  OPTIONAL { ?tara rdfs:label ?tara_en FILTER(lang(?tara_en) = "en") }
  OPTIONAL { ?tara rdfs:label ?tara_mul FILTER(lang(?tara_mul) = "mul") }
}""" % _VALORI,

	"gazde": """SELECT ?e ?tara ?tara_ro ?tara_en ?tara_mul WHERE {
  VALUES ?comp { %s }
  ?e wdt:P3450 ?comp ; wdt:P17 ?tara .
  OPTIONAL { ?tara rdfs:label ?tara_ro FILTER(lang(?tara_ro) = "ro") }
  OPTIONAL { ?tara rdfs:label ?tara_en FILTER(lang(?tara_en) = "en") }
  OPTIONAL { ?tara rdfs:label ?tara_mul FILTER(lang(?tara_mul) = "mul") }
}""" % _VALORI,
}


def editiile(randuri):
	"""Rândurile brute → ediție → {comp, nume, an, castigatori, gazde}."""
	editii = {}
	for r in randuri["editii"]:
		nume, _ = tabel.eticheta(r, "e")
		sezon = ""
		if r["comp"] in CLUBURI:
			m = SEZON_CLUBURI.match(r.get("e_ro", ""))
			if not m or int(m.group(3)) != int(m.group(2)) + 1:
				continue
			sezon, an, competitie = "%s-%s" % (m.group(2), m.group(3)), int(m.group(3)), m.group(1)
		elif r.get("an"):
			an, competitie = int(r["an"]), COMPETITII[r["comp"]]
		else:
			continue
		editii[r["e"]] = {"qid": r["e"], "comp": r["comp"], "nume": nume, "an": an,
		                  "sezon": sezon, "competitie": competitie,
		                  "castigatori": {}, "gazde": {}}

	for r in randuri["castigatori"]:
		e = editii.get(r["e"])
		if e is None:
			continue
		rol = r.get("rol", "")
		if rol and rol not in ROLURI:
			raise Eroare("%s (%s): rol necunoscut pe P1346: %s" % (e["nume"], e["qid"], rol))
		if rol and not ROLURI[rol]:
			continue
		if e["comp"] in CLUBURI:
			e["castigatori"].setdefault(r["st"], tabel.eticheta(r, "w")[0])
			continue
		tara, _ = tabel.eticheta(r, "tara")
		if not tara:
			raise Eroare("%s: câștigătoarea %s n-are țară (P1532/P17)" % (e["nume"], r["w"]))
		# Pe statement, nu pe țară: o echipă cu două țări (P1532 și P17 diferite)
		# ar da două rânduri cu aceeași declarație — se ia prima, la fel peste tot.
		e["castigatori"].setdefault(r["st"], tara)

	for r in randuri["gazde"]:
		e = editii.get(r["e"])
		if e is not None and e["comp"] not in CLUBURI:
			e["gazde"][r["tara"]] = tabel.eticheta(r, "tara")[0]
	return editii


def nota(e, castigatoare):
	"""Ediția → (nota, surse). Un șablon, două forme: gazda a câștigat sau nu."""
	competitie = COMPETITII[e["comp"]]
	gazde = sorted(e["gazde"].values())
	unde = " și ".join(gazde) if len(gazde) <= 2 else ", ".join(gazde[:-1]) + " și " + gazde[-1]
	surse = [competitie, e["an"], castigatoare] + gazde
	if len(gazde) == 1 and gazde[0] == castigatoare:
		text = ("%s din %d s-a ținut în %s, iar gazdele au câștigat-o."
		        % (competitie, e["an"], unde))
	else:
		text = ("%s din %d s-a ținut în %s și a fost câștigată de %s."
		        % (competitie, e["an"], unde, castigatoare))
	return text[0].upper() + text[1:], surse


def nota_sezonului(e, castigatoare):
	surse = [e["competitie"], e["sezon"], castigatoare]
	return ("%s din sezonul %s a fost câștigată de %s."
	        % (e["competitie"], e["sezon"], castigatoare)), surse


def sezon_de_cluburi(e, bun, castigatori, editii, nivel, t):
	"""Capcana 6: o ediție de cluburi e un SEZON, iar răspunsul e un CLUB."""
	if e["an"] > ULTIMUL_SEZON:
		t.refuzate.append("%s: sezon prea proaspăt" % e["nume"])
		return
	fapt = "wd:%s" % e["qid"]
	text_nota, surse = nota_sezonului(e, bun)
	t.fapt(fapt, text_nota, surse)
	vecine = [x for x in editii.values() if x["comp"] == e["comp"] and x["qid"] != e["qid"]
	          and x["an"] <= ULTIMUL_SEZON]
	t.intrebare(e["qid"], "cere_castigatoare",
	            "Ce echipă a câștigat %s în sezonul %s?" % (e["competitie"], e["sezon"]),
	            bun, castigatori,
	            [(c, abs(x["an"] - e["an"])) for x in vecine for c in x["castigatori"].values()],
	            nivel, fapt, [e["sezon"]])


def construieste(lista, editii, t):
	alese = [editii[r["qid"]] for r in lista]
	nivel = {r["qid"]: r["nivel"] for r in lista}
	nivel_gazda = {r["qid"]: r.get("nivel_gazda", r["nivel"]) for r in lista}

	for e in alese:
		an_nume = re.findall(r"\b(1[89]\d\d|20\d\d)\b", e["nume"])
		if not e["sezon"] and an_nume and int(an_nume[0]) != e["an"]:
			t.refuzate.append("%s: în nume scrie %s, dar s-a jucat în %d"
			                  % (e["nume"], an_nume[0], e["an"]))
			continue
		castigatori = sorted(set(e["castigatori"].values()))
		if len(castigatori) != 1:
			t.refuzate.append("%s: %d câștigătoare (%s)"
			                  % (e["nume"], len(castigatori), ", ".join(castigatori)))
			continue
		bun = castigatori[0]
		if e["comp"] in CLUBURI:
			sezon_de_cluburi(e, bun, castigatori, editii, nivel[e["qid"]], t)
			continue
		competitie = COMPETITII[e["comp"]]
		fapt = "wd:%s" % e["qid"]
		text_nota, surse = nota(e, bun)
		t.fapt(fapt, text_nota, surse)

		# Distractorii: câștigătoarele și gazdele ALTOR ediții ale aceleiași
		# competiții, cele mai apropiate în timp. Câștigătoarele întâi (o țară care
		# a câștigat o dată e un distractor care chiar te face să stai pe gânduri).
		vecine = [x for x in editii.values()
		          if x["comp"] == e["comp"] and x["qid"] != e["qid"]]
		castig = [(c, abs(x["an"] - e["an"])) for x in vecine for c in x["castigatori"].values()]
		gazde = [(g, abs(x["an"] - e["an"]) + 40) for x in vecine for g in x["gazde"].values()]
		t.intrebare(e["qid"], "cere_castigatoare",
		            "Ce țară a câștigat %s din %d?" % (competitie, e["an"]),
		            bun, cu_echivalentele(castigatori), castig + gazde, nivel[e["qid"]], fapt,
		            [str(e["an"])])

		if len(e["gazde"]) == 1:
			gazda = list(e["gazde"].values())[0]
			gazde_vecine = [(g, abs(x["an"] - e["an"])) for x in vecine for g in x["gazde"].values()]
			t.intrebare(e["qid"], "cere_gazda",
			            "Ce țară a găzduit %s din %d?" % (competitie, e["an"]),
			            gazda, cu_echivalentele([gazda]), gazde_vecine + [(c, d + 40) for c, d in castig],
			            nivel_gazda[e["qid"]], fapt, [str(e["an"])])


def masoara(editii):
	print("\n  ── CE ÎNTOARCE WIKIDATA ──")
	for comp, nume in COMPETITII.items():
		ale = sorted((e for e in editii.values() if e["comp"] == comp), key=lambda e: e["an"])
		print("\n    %s: %d ediții cu dată" % (nume, len(ale)))
		for e in ale:
			print("      %d  %-45s câștigă: %-28s gazde: %s" % (
				e["an"], e["nume"][:45], " / ".join(sorted(set(e["castigatori"].values()))) or "—",
				", ".join(sorted(e["gazde"].values())) or "—"))


def main():
	arg = comun.argumentele()
	print("FABRICA — fotbal: câștigătoarea și gazda, pe ediție")
	randuri = tabel.aduce(CALE_CACHE, INTEROGARI, arg.reincarca)
	editii = editiile(randuri)

	if arg.masoara:
		masoara(editii)
		return 0
	if arg.propune:
		propuse = sorted((e for e in editii.values() if e["castigatori"]),
		                 key=lambda e: (e["comp"], e["an"]))
		tabel.scrie_propunerile(CALE_PROPUSE, [
			{"qid": e["qid"], "nume": e["nume"], "nivel": 2} for e in propuse],
			["qid", "nume", "nivel"])
		return 0

	lista = tabel.citeste_randurile(CALE_LISTA, CAMPURI, "edițiile alese")
	tabel.verifica_numele(lista, {q: e["nume"] for q, e in editii.items()}, "ediție cu dată")
	t = tabel.Tabel("fotbal", "sport_jocuri", "sporturi_de_echipa", "turneu",
	                "turneele de fotbal")
	construieste(lista, editii, t)
	return t.incheie(arg, DUBLURI, NU_SUNT_DUBLURI)


if __name__ == "__main__":
	comun.ruleaza(main)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — campionii mondiali de Formula 1, pe sezon.

    python tools/fabrica/formula1.py --propune    toate sezoanele cu campion, în
                                                  `date/formula1_propuse.json`
    python tools/fabrica/formula1.py --masoara    doar măsoară
    python tools/fabrica/formula1.py              raportul întreg, fără să scrie
    python tools/fabrica/formula1.py --scrie      scrie perechea din data/trivia_gen/
    python tools/fabrica/formula1.py --reincarca  reia din rețea

Trei sensuri:

    cere_pilot        „Cine a câștigat titlul mondial de Formula 1 la piloți în 1988?”
                      — pe sezon. Faptul e SEZONUL.
    cere_constructor  „Ce echipă a câștigat titlul mondial al constructorilor în
                      Formula 1, în 1988?” — pe sezon, de la 1958, când a apărut
                      titlul. Același fapt.
    cere_an           „În care dintre acești ani a fost Ayrton Senna campion
                      mondial de Formula 1?” — o întrebare PER PILOT. Faptul e
                      OMUL, cu anii titlurilor în notă.

─────────────────────────────────────────────────────────────
CAPCANELE, MĂSURATE PE 27 OCTOMBRIE 2026

1. UN SEZON ARE DOI „CÂȘTIGĂTORI” PE `P1346`: pilotul și echipa. Îi desparte
   calificatorul `P2094` („clasa competiției”): titlul piloților sau al
   constructorilor. Toate cele 138 de declarații îl au; o clasă necunoscută
   OPREȘTE (`CLASE`).

2. `cere_an` E O ÎNTREBARE CU MULTE RĂSPUNSURI ADEVĂRATE, dacă nu ai grijă:
   Schumacher are șapte titluri. Răspunsul bun e UNUL din anii lui, ales cu zarul,
   iar NICIUN alt an al lui nu poate fi distractor — distractorii sunt anii în
   care a câștigat ALTCINEVA. Așa „exact una din patru” rămâne adevărat.

3. UN SEZON FĂRĂ CAMPION LA WIKIDATA nu e un sezon fără campion. 2024 n-are
   `P1346` (măsurat azi). Lipsa lui nu strică nimic — nu se pune întrebarea —,
   dar NU are voie să facă din `cere_an` o întrebare greșită: dacă pilotul din
   2024 ar fi și campion în alt an, 2024 ar putea apărea ca distractor „liber”.
   Deci anii fără campion cunoscut nu sunt niciodată distractori.

4. UN CAMPION CARE NU E PILOT. Sezonul 2018 are la Wikidata, pe `P1346`, lângă
   echipa Mercedes, itemul „Moreno” — un PRENUME (`Q3862934`), nu un om. Fără un
   al doilea semn, jocul ar fi predat că „Moreno” a fost campion mondial în 2018
   (a fost Lewis Hamilton). Semnul: câștigătorul titlului la piloți trebuie să
   aibă ocupația „pilot de curse” (`P106/P279*` `Q378622`). Măsurat pe toate cele
   74 de declarații: îl au toate, afară de „Moreno”. Ce nu trece se tipărește
   (`SUSPECTE`) și sezonul rămâne fără campion — deci fără întrebare, și fără să
   devină distractor (capcana 3).

   Semnul care NU merge, ca să nu fie încercat din nou: „pilotul a participat la
   sezon” (`P1344`) lipsește la 57 din 74 de campioni, inclusiv la Fangio.
"""

import os
import re

import comun
import tabel
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_formula1.json")
CALE_LISTA = os.path.join(comun.DOSAR_DATE, "formula1.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "formula1_propuse.json")

CAMPURI = {"qid", "nume", "nivel", "nivel_constructori"}

CLASE = {
	"Q63436479": "piloti",
	"Q63436495": "constructori",
}

# Declarațiile de campion care n-au trecut al doilea semn. Se tipăresc la fiecare
# rulare: o greșeală din Wikidata care dispare singură nu mai e o greșeală, dar
# una care stă acolo trebuie să rămână văzută.
SUSPECTE = []

# Sezoane și piloți întrebați deja de mână. Toate sunt dubluri adevărate: textul
# de mână spune anul ȘI pilotul. La Clark, Damon Hill și Räikkönen nu există an
# liber pentru `cere_an` (toate titlurile lor sunt spuse în acel text), deci iese
# și întrebarea per pilot; la ceilalți, `ar_atinge` alege un an nespus.
DUBLURI = {
	"wd:Q68955:campion:cere_pilot": "mana:1151",   # 1951, Fangio
	"wd:Q69047:campion:cere_pilot": "mana:1151",   # 1957, Fangio
	"wd:Q69184:campion:cere_pilot": "mana:1894",   # 1963, Jim Clark
	"wd:Q69204:campion:cere_pilot": "mana:1894",   # 1965, Jim Clark
	"wd:Q3137:campion:cere_an": "mana:1894",       # Jim Clark: 1963 sau 1965
	"wd:Q69633:campion:cere_pilot": "mana:0441",   # 1988, Senna
	"wd:Q69670:campion:cere_pilot": "mana:0441",   # 1991, Senna
	"wd:Q69735:campion:cere_pilot": "mana:1906",   # 1996, Damon Hill
	"wd:Q10505:campion:cere_an": "mana:1906",      # Damon Hill: doar 1996
	"wd:Q69869:campion:cere_pilot": "mana:0213",   # 2004, Schumacher
	"wd:Q69901:campion:cere_pilot": "mana:1849",   # 2007, Räikkönen
	"wd:Q11192:campion:cere_an": "mana:1849",      # Räikkönen: doar 2007
	"wd:Q69913:campion:cere_pilot": "mana:1143",   # 2008, Hamilton
}
NU_SUNT_DUBLURI = {}

INTEROGARI = {
	"sezoane": """SELECT ?e ?e_ro ?e_en ?e_mul (MIN(YEAR(?d)) AS ?an) WHERE {
  ?e wdt:P3450 wd:Q1968 ; wdt:P585 ?d .
  OPTIONAL { ?e rdfs:label ?e_ro FILTER(lang(?e_ro) = "ro") }
  OPTIONAL { ?e rdfs:label ?e_en FILTER(lang(?e_en) = "en") }
  OPTIONAL { ?e rdfs:label ?e_mul FILTER(lang(?e_mul) = "mul") }
} GROUP BY ?e ?e_ro ?e_en ?e_mul""",

	"campioni": """SELECT ?e ?st ?clasa ?w ?w_ro ?w_en ?w_mul ?descriere ?pilot
       (MIN(YEAR(?n)) AS ?nastere) (MIN(YEAR(?m)) AS ?moarte) WHERE {
  ?e wdt:P3450 wd:Q1968 ; p:P1346 ?st .
  ?st ps:P1346 ?w .
  BIND(EXISTS { ?w wdt:P106/wdt:P279* wd:Q378622 } AS ?pilot)
  OPTIONAL { ?st pq:P2094 ?clasa }
  OPTIONAL { ?w rdfs:label ?w_ro FILTER(lang(?w_ro) = "ro") }
  OPTIONAL { ?w rdfs:label ?w_en FILTER(lang(?w_en) = "en") }
  OPTIONAL { ?w rdfs:label ?w_mul FILTER(lang(?w_mul) = "mul") }
  OPTIONAL { ?w schema:description ?descriere FILTER(lang(?descriere) = "ro") }
  OPTIONAL { ?w wdt:P569 ?n }
  OPTIONAL { ?w wdt:P570 ?m }
} GROUP BY ?e ?st ?clasa ?w ?w_ro ?w_en ?w_mul ?descriere ?pilot""",
}


def sezoanele(randuri):
	sezoane = {}
	for r in randuri["sezoane"]:
		sezoane[r["e"]] = {"qid": r["e"], "nume": tabel.eticheta(r, "e")[0],
		                   "an": int(r["an"]), "piloti": {}, "constructori": {}}
	oameni = {}
	for r in randuri["campioni"]:
		s = sezoane.get(r["e"])
		if s is None:
			continue
		clasa = CLASE.get(r.get("clasa", ""))
		if clasa is None:
			raise Eroare("%s: clasă necunoscută pe P1346: %r" % (s["nume"], r.get("clasa")))
		nume = tabel.eticheta(r, "w")[0]
		if not nume:
			raise Eroare("%s: câștigătorul %s n-are etichetă" % (s["nume"], r["w"]))
		if clasa == "piloti" and r.get("pilot") != "true":
			# Al doilea semn (capcana 4): un campion la piloți e un PILOT.
			SUSPECTE.append("%s: „%s” (%s) nu e pilot de curse la Wikidata"
			                % (s["nume"], nume, r["w"]))
			continue
		s[clasa][r["w"]] = nume
		if clasa == "piloti":
			oameni[r["w"]] = {
				"nume": nume, "descriere": r.get("descriere", ""),
				"nastere": int(r["nastere"]) if r.get("nastere") else None,
				"moarte": int(r["moarte"]) if r.get("moarte") else None,
			}
	return sezoane, oameni


def un_singur(s, clasa):
	"""Câștigătorul unic al clasei, ca (qid, nume) — sau `None`."""
	c = s[clasa]
	if len(c) != 1:
		return None
	return list(c.items())[0]


def lista_de_ani(ani):
	ani = [str(a) for a in sorted(ani)]
	return ani[0] if len(ani) == 1 else ", ".join(ani[:-1]) + " și " + ani[-1]


def nota_sezonului(s):
	pilot = un_singur(s, "piloti")[1]
	constructor = un_singur(s, "constructori")
	surse = ["Formula 1", s["an"], pilot]
	if constructor:
		# „Williams F1 Team”: validatorul citește „F” din „F1” ca pe un cuvânt de
		# o literă (majusculă urmată de cifră), iar sursa îl dă lipit, „f1”. Se
		# adaugă numele cu cifrele scoase — aceleași litere, din aceeași sursă.
		surse += [constructor[1], re.sub(r"\d", " ", constructor[1])]
		return ("În sezonul de Formula 1 din %d, titlul la piloți l-a câștigat %s, "
		        "iar cel al constructorilor, %s." % (s["an"], pilot, constructor[1])), surse
	return ("În sezonul de Formula 1 din %d, titlul la piloți l-a câștigat %s."
	        % (s["an"], pilot)), surse


def nota_pilotului(om, ani):
	text, surse = comun.nota_omului(om["nume"], om, prezent=True)
	surse = surse + ["Formula 1"] + list(ani)
	cand = lista_de_ani(ani)
	if len(ani) == 1:
		adaos = "A fost campion mondial de Formula 1 în %s." % cand
	else:
		adaos = "A fost campion mondial de Formula 1 în %s." % cand
	return (text + " " + adaos).strip(), surse


def construieste(lista, sezoane, oameni, t):
	nivel = {r["qid"]: r["nivel"] for r in lista}
	nivel_c = {r["qid"]: r.get("nivel_constructori", r["nivel"]) for r in lista}

	# Anii fiecărui campion, pe TOATE sezoanele de la Wikidata, nu doar pe cele
	# alese: un an ales în afara listei e tot un an în care a câștigat el.
	ani_pilot = {}
	an_campion = {}
	for s in sezoane.values():
		p = un_singur(s, "piloti")
		if p:
			ani_pilot.setdefault(p[0], set()).add(s["an"])
			an_campion[s["an"]] = p[0]

	for r in lista:
		s = sezoane[r["qid"]]
		p = un_singur(s, "piloti")
		if p is None:
			t.refuzate.append("%s: %d campioni la piloți" % (s["nume"], len(s["piloti"])))
			continue
		fapt = "wd:%s" % s["qid"]
		text_nota, surse = nota_sezonului(s)
		t.fapt(fapt, text_nota, surse)

		vecine = [x for x in sezoane.values() if x["qid"] != s["qid"]]
		piloti = [(n, abs(x["an"] - s["an"])) for x in vecine for n in x["piloti"].values()]
		t.intrebare(s["qid"], "cere_pilot",
		            "Cine a câștigat titlul mondial de Formula 1 la piloți în %d?" % s["an"],
		            p[1], list(s["piloti"].values()), piloti, nivel[s["qid"]], fapt,
		            [str(s["an"])])

		c = un_singur(s, "constructori")
		if c:
			echipe = [(n, abs(x["an"] - s["an"])) for x in vecine for n in x["constructori"].values()]
			t.intrebare(s["qid"], "cere_constructor",
			            "Ce echipă a câștigat titlul mondial al constructorilor în "
			            "Formula 1, în %d?" % s["an"],
			            c[1], list(s["constructori"].values()), echipe,
			            nivel_c[s["qid"]], fapt, [str(s["an"])])

	# ── PER PILOT ── numai piloții care au măcar un sezon ALES.
	alese = {}
	for r in lista:
		p = un_singur(sezoane[r["qid"]], "piloti")
		if p:
			alese.setdefault(p[0], []).append(sezoane[r["qid"]])
	for qid_om, sez in sorted(alese.items()):
		om = oameni[qid_om]
		ani = ani_pilot[qid_om]
		# Anul bun: unul dintre sezoanele ALESE, cu zarul. Nivelul: al sezonului
		# ales, plus unu — „în ce an” e mai greu decât „cine”, la același fapt.
		# Dintre ei, întâi cei pe care nu-i întreabă deja o întrebare de mână:
		# Senna are 1988 și 1991 în textul uneia, deci aici primește 1990.
		ordonate = sorted(sez, key=lambda x: comun.zar(qid_om, x["an"]))
		libere = [x for x in ordonate if not t.ar_atinge([om["nume"]], str(x["an"]))]
		s = (libere or ordonate)[0]
		alti = [(str(a), abs(a - s["an"])) for a, cine in an_campion.items() if cine != qid_om]
		fapt = "wd:%s" % qid_om
		text_nota, surse = nota_pilotului(om, ani)
		t.fapt(fapt, text_nota, surse)
		t.intrebare(qid_om, "cere_an",
		            "În care dintre acești ani a fost %s campion mondial de Formula 1?"
		            % om["nume"],
		            str(s["an"]), [str(a) for a in ani], alti,
		            min(3, nivel[s["qid"]] + 1), fapt, [om["nume"]])


def masoara(sezoane):
	print("\n  ── SEZOANELE ──")
	for s in sorted(sezoane.values(), key=lambda s: s["an"]):
		print("    %d  piloți: %-28s constructori: %s" % (
			s["an"], " / ".join(s["piloti"].values()) or "—",
			" / ".join(s["constructori"].values()) or "—"))


def main():
	arg = comun.argumentele()
	print("FABRICA — Formula 1: campionii pe sezon")
	randuri = tabel.aduce(CALE_CACHE, INTEROGARI, arg.reincarca)
	sezoane, oameni = sezoanele(randuri)
	if SUSPECTE:
		print("\n  ── CAMPIONI RESPINȘI (al doilea semn) ──")
		for x in SUSPECTE:
			print("    %s" % x)
	if arg.masoara:
		masoara(sezoane)
		return 0
	if arg.propune:
		propuse = sorted((s for s in sezoane.values() if s["piloti"]), key=lambda s: s["an"])
		tabel.scrie_propunerile(CALE_PROPUSE, [
			{"qid": s["qid"], "nume": s["nume"], "nivel": 2} for s in propuse],
			["qid", "nume", "nivel"])
		return 0

	lista = tabel.citeste_randurile(CALE_LISTA, CAMPURI, "sezoanele alese")
	tabel.verifica_numele(lista, {q: s["nume"] for q, s in sezoane.items()}, "sezon de F1")
	t = tabel.Tabel("formula1", "sport_jocuri", "motor_extreme", "campion",
	                "campionii de Formula 1")
	construieste(lista, sezoane, oameni, t)
	return t.incheie(arg, DUBLURI, NU_SUNT_DUBLURI)


if __name__ == "__main__":
	comun.ruleaza(main)

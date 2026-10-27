#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — orașul-gazdă al Jocurilor Olimpice de vară, pe ediție.

    python tools/fabrica/olimpiade.py --propune    edițiile cu un singur oraș, în
                                                   `date/olimpiade_propuse.json`
    python tools/fabrica/olimpiade.py --masoara    doar măsoară
    python tools/fabrica/olimpiade.py              raportul întreg, fără să scrie
    python tools/fabrica/olimpiade.py --scrie      scrie perechea din data/trivia_gen/
    python tools/fabrica/olimpiade.py --reincarca  reia din rețea

Două sensuri:

    cere_oras   „Ce oraș a găzduit Jocurile Olimpice de vară din 1960?” — pe ediție
    cere_an     „În ce an a găzduit Roma Jocurile Olimpice de vară?” — numai pentru
                orașele care le-au găzduit O SINGURĂ DATĂ. Londra (1908, 1948,
                2012) ar avea trei răspunsuri bune, iar „exact una din patru” nu
                se poate cere de la o întrebare care are trei.

─────────────────────────────────────────────────────────────
CAPCANELE, MĂSURATE PE 27 OCTOMBRIE 2026

1. NU EXISTĂ O PROPRIETATE „ORAȘ-GAZDĂ”. Ce se folosește e `P276` (locul), iar
   `P276` ține și STADIOANELE: 1972 are doar „Stadionul Olimpic din München”, 1988
   doar „Seoul Olympic Main Stadium”. Deci se iau numai valorile care sunt
   AȘEZĂRI (`P31/P279*` așezare umană, `Q486972`), și numai edițiile cu exact
   una. 1972, 1984 și 1988 ies singure din tabel.

2. LA IARNĂ FILTRUL NU AJUNGE, și de-aia Jocurile de iarnă nu sunt aici. Acolo
   `P276` e lista locurilor de concurs, iar unele locuri sunt sate: 1994 iese
   „Hafjell”, nu Lillehammer; 2014 iese „Krasnaia Poliana + Soci”; jumătate din
   ediții n-au niciun oraș. Un filtru care dă un singur răspuns GREȘIT pe o
   ediție nu e un filtru, e o loterie.

3. EDIȚIILE ANULATE (1916, 1940, 1944) SUNT EDIȚII la Wikidata, cu oraș. Nu se
   aleg; `date/olimpiade.json` nu le are.

4. TOKYO 2020 S-A ȚINUT ÎN 2021. Ca la Euro 2020 în `fotbal.py`: anul din nume
   diferit de anul din date → rândul se refuză și se tipărește.

5. MELBOURNE 1956 a avut probele de călărie la Stockholm, iar Wikidata spune doar
   Melbourne. Ediția e deja întrebată de mână („1956, Melbourne”), deci iese ca
   dublură — dar nici n-ar fi intrat cu „Melbourne” singur pe un buton verde.
"""

import os
import re

import comun
import tabel
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_olimpiade.json")
CALE_LISTA = os.path.join(comun.DOSAR_DATE, "olimpiade.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "olimpiade_propuse.json")

CAMPURI = {"qid", "nume", "nivel", "nivel_an"}

VARA = "Q159821"

# Orașe găzduite o singură dată după `P276`, dar nu și în realitate. Fără `cere_an`
# pentru ele: întrebarea ar fi corectă după Wikidata și greșită după un cunoscător.
FARA_AN = {
	# Probele de călărie din 1956 s-au ținut la Stockholm (Melbourne n-a putut
	# primi caii din cauza carantinei). „În ce an a găzduit Stockholm…?” ar avea
	# două răspunsuri bune, iar 1956 ar putea apărea chiar ca distractor.
	"Stockholm",
}

# Ultima ediție ținută la data scrierii (27 octombrie 2026). Edițiile de după ea
# sunt la Wikidata, cu oraș, și nu se iau nici ca distractori.
ULTIMUL_AN = 2024

# Ediții întrebate deja de mână (`id` generat → `id`-ul de mână). Toate sunt
# dubluri adevărate: aceeași ediție, același oraș.
DUBLURI = {
	"wd:Q8080:gazda:cere_oras": "mana:0198",     # 1896, Atena
	"wd:Q8088:gazda:cere_oras": "mana:0428",     # 1900, Paris (primele femei)
	"wd:Q8150:gazda:cere_oras": "mana:0204",     # 1936, Berlin (Jesse Owens)
	"wd:Q8411:gazda:cere_oras": "mana:0425",     # 1956, Melbourne (călăria)
	"wd:Q8411:gazda:cere_an": "mana:0425",
	"wd:Q8429:gazda:cere_oras": "mana:1886",     # 1968, Ciudad de México
	"wd:Q8429:gazda:cere_an": "mana:1886",
	"wd:Q8450:gazda:cere_oras": "mana:0344",     # 1980, Moscova (boicotul)
	"wd:Q8450:gazda:cere_an": "mana:0344",
	"wd:Q8488:gazda:cere_oras": "mana:0346",     # 1992, Barcelona
	"wd:Q8488:gazda:cere_an": "mana:0346",
	"wd:Q995653:gazda:cere_oras": "mana:0263",   # 2024, Paris
}
NU_SUNT_DUBLURI = {}

INTEROGARI = {
	"editii": """SELECT ?e ?e_ro ?e_en ?e_mul (MIN(YEAR(?d)) AS ?an) WHERE {
  ?e wdt:P3450 wd:%s .
  { ?e wdt:P585 ?d } UNION { ?e wdt:P580 ?d }
  OPTIONAL { ?e rdfs:label ?e_ro FILTER(lang(?e_ro) = "ro") }
  OPTIONAL { ?e rdfs:label ?e_en FILTER(lang(?e_en) = "en") }
  OPTIONAL { ?e rdfs:label ?e_mul FILTER(lang(?e_mul) = "mul") }
} GROUP BY ?e ?e_ro ?e_en ?e_mul""" % VARA,

	"orase": """SELECT DISTINCT ?e ?oras ?oras_ro ?oras_en ?oras_mul ?tara_ro ?tara_en ?tara_mul WHERE {
  ?e wdt:P3450 wd:%s ; wdt:P276 ?oras .
  ?oras wdt:P31/wdt:P279* wd:Q486972 .
  OPTIONAL { ?oras rdfs:label ?oras_ro FILTER(lang(?oras_ro) = "ro") }
  OPTIONAL { ?oras rdfs:label ?oras_en FILTER(lang(?oras_en) = "en") }
  OPTIONAL { ?oras rdfs:label ?oras_mul FILTER(lang(?oras_mul) = "mul") }
  OPTIONAL { ?e wdt:P17 ?tara .
             OPTIONAL { ?tara rdfs:label ?tara_ro FILTER(lang(?tara_ro) = "ro") }
             OPTIONAL { ?tara rdfs:label ?tara_en FILTER(lang(?tara_en) = "en") }
             OPTIONAL { ?tara rdfs:label ?tara_mul FILTER(lang(?tara_mul) = "mul") } }
}""" % VARA,
}


def editiile(randuri):
	editii = {}
	for r in randuri["editii"]:
		editii[r["e"]] = {"qid": r["e"], "nume": tabel.eticheta(r, "e")[0],
		                  "an": int(r["an"]), "orase": {}, "tara": ""}
	for r in randuri["orase"]:
		e = editii.get(r["e"])
		if e is None:
			continue
		e["orase"][r["oras"]] = tabel.eticheta(r, "oras")[0]
		tara = tabel.eticheta(r, "tara")[0]
		if tara:
			# O ediție cu două `P17` ar da aici țara care vine ultima. Nu se
			# întâmplă pe nicio ediție aleasă; dacă se întâmplă, se vede în notă.
			e["tara"] = tara
	return editii


def nota(e, oras):
	surse = ["Jocurile Olimpice de vară", e["an"], oras, e["tara"]]
	if e["tara"]:
		return ("Jocurile Olimpice de vară din %d s-au ținut la %s, în %s."
		        % (e["an"], oras, e["tara"])), surse
	return "Jocurile Olimpice de vară din %d s-au ținut la %s." % (e["an"], oras), surse


def construieste(lista, editii, t):
	nivel = {r["qid"]: r["nivel"] for r in lista}
	nivel_an = {r["qid"]: r.get("nivel_an", r["nivel"]) for r in lista}

	# Câte ediții a găzduit fiecare oraș — pe TOATE edițiile cu oraș, nu doar pe
	# cele alese. Altfel Londra, cu o singură ediție aleasă, ar fi trecut drept
	# gazdă unică, iar „În ce an a găzduit Londra…” ar fi avut un singur răspuns
	# bun pe hârtie și trei în realitate.
	ani_pe_oras = {}
	for e in editii.values():
		if len(e["orase"]) == 1:
			ani_pe_oras.setdefault(list(e["orase"].values())[0], set()).add(e["an"])

	for r in lista:
		e = editii[r["qid"]]
		an_nume = re.findall(r"\b(1[89]\d\d|20\d\d)\b", e["nume"])
		if an_nume and int(an_nume[0]) != e["an"]:
			t.refuzate.append("%s: în nume scrie %s, dar s-au ținut în %d"
			                  % (e["nume"], an_nume[0], e["an"]))
			continue
		if len(e["orase"]) != 1:
			t.refuzate.append("%s: %d orașe (%s)" % (e["nume"], len(e["orase"]),
			                  ", ".join(sorted(e["orase"].values())) or "niciunul"))
			continue
		oras = list(e["orase"].values())[0]
		fapt = "wd:%s" % e["qid"]
		text_nota, surse = nota(e, oras)
		t.fapt(fapt, text_nota, surse)

		# Numai ediții care s-au și ținut până azi: un an din viitor (2028, 2032)
		# ca distractor ar fi un răspuns greșit care se elimină singur.
		vecine = [x for x in editii.values()
		          if x["qid"] != e["qid"] and len(x["orase"]) == 1 and x["an"] <= ULTIMUL_AN]
		orase = [(list(x["orase"].values())[0], abs(x["an"] - e["an"])) for x in vecine]
		t.intrebare(e["qid"], "cere_oras",
		            "Ce oraș a găzduit Jocurile Olimpice de vară din %d?" % e["an"],
		            oras, [oras], orase, nivel[e["qid"]], fapt, [str(e["an"])])

		ani = ani_pe_oras[oras]
		if len(ani) == 1 and oras not in FARA_AN:
			# Distractorii sunt anii ALTOR ediții, nu ani inventați: „1961” ar fi
			# un an în care nu s-au ținut deloc Jocuri, deci s-ar elimina singur.
			alti_ani = [(str(x["an"]), abs(x["an"] - e["an"])) for x in vecine
			            if x["an"] not in ani]
			t.intrebare(e["qid"], "cere_an",
			            "În ce an a găzduit %s Jocurile Olimpice de vară?" % oras,
			            str(e["an"]), [str(a) for a in ani], alti_ani, nivel_an[e["qid"]],
			            fapt, [oras])


def masoara(editii):
	print("\n  ── EDIȚIILE DE VARĂ ──")
	for e in sorted(editii.values(), key=lambda e: e["an"]):
		print("    %d  %-42s %s" % (e["an"], e["nume"][:42],
		                            " + ".join(sorted(e["orase"].values())) or "— fără oraș"))


def main():
	arg = comun.argumentele()
	print("FABRICA — Jocurile Olimpice de vară: orașul-gazdă")
	randuri = tabel.aduce(CALE_CACHE, INTEROGARI, arg.reincarca)
	editii = editiile(randuri)
	if arg.masoara:
		masoara(editii)
		return 0
	if arg.propune:
		propuse = sorted((e for e in editii.values() if len(e["orase"]) == 1),
		                 key=lambda e: e["an"])
		tabel.scrie_propunerile(CALE_PROPUSE, [
			{"qid": e["qid"], "nume": e["nume"], "nivel": 2} for e in propuse],
			["qid", "nume", "nivel"])
		return 0

	lista = tabel.citeste_randurile(CALE_LISTA, CAMPURI, "edițiile alese")
	tabel.verifica_numele(lista, {q: e["nume"] for q, e in editii.items()}, "ediție de vară")
	t = tabel.Tabel("olimpiade", "sport_jocuri", "individuale_olimpism", "gazda",
	                "Jocurile Olimpice de vară")
	construieste(lista, editii, t)
	return t.incheie(arg, DUBLURI, NU_SUNT_DUBLURI)


if __name__ == "__main__":
	comun.ruleaza(main)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — album → interpret.

    python tools/fabrica/albume.py --propune    albumele cele mai răspândite, în
                                                `date/albume_propuse.json`
    python tools/fabrica/albume.py --masoara    doar măsoară
    python tools/fabrica/albume.py              raportul întreg, fără să scrie
    python tools/fabrica/albume.py --scrie      scrie perechea din data/trivia_gen/
    python tools/fabrica/albume.py --reincarca  reia din rețea (OBLIGATORIU după ce
                                                schimbi `date/albume.json`)

Două sensuri, ca la `filme.py`:

    cere_interpret   „Cine a lansat albumul «Rumours», în 1977?” — PER ALBUM
    cere_album       „Care dintre aceste albume a fost lansat de Queen?” — PER
                     INTERPRET, numai pentru cei cu măcar două albume în tabel

─────────────────────────────────────────────────────────────
CAPCANELE, MĂSURATE PE 27 OCTOMBRIE 2026, PE 367 DE ALBUME CU PESTE 30 DE EDIȚII

1. ALBUMUL CARE POARTĂ NUMELE INTERPRETULUI: „Queen” de Queen, „Metallica” de
   Metallica, „Madonna” de Madonna, „Led Zeppelin”, „Black Sabbath”. Răspunsul se
   citește din întrebare. Îl prinde motorul (`tabel.py`, „răspunsul nu e în
   text”), care OPREȘTE — deci nu se aleg.

2. `P175` CU MAI MULȚI INTERPREȚI: „Yellow Submarine” (The Beatles + George
   Martin), „Led Zeppelin IV” (cu Sandy Denny și Ian Stewart, invitați), „The
   Velvet Underground & Nico”. Regula: EXACT un interpret, altfel refuz.

3. TITLURI SCURTE ȘI COMUNE: „Bad”, „Red”, „21”, „25”, „X”, „War”. Anul din
   întrebare le leagă de un singur album; distractorii sunt interpreți, nu
   titluri, deci un al doilea „Bad” n-ar strica nimic. În sensul invers, două
   titluri identice pe patru butoane ar strica — motorul le refuză (variante
   identice).

4. INTERPRETUL FĂRĂ ETICHETĂ: la Lady Gaga și Beyoncé, `P175` lipsea din
   rezultat la prima măsurătoare — eticheta era în `mul`. De-aia `tabel.eticheta`
   cade pe ro → en → mul.
"""

import os
import re

import comun
import tabel
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_albume.json")
CALE_LISTA = os.path.join(comun.DOSAR_DATE, "albume.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "albume_propuse.json")

CAMPURI = {"qid", "nume", "nivel"}

MINIM_EDITII = 25

DUBLURI = {}
NU_SUNT_DUBLURI = {}


def interogarile(qid_uri):
	valori = " ".join("wd:%s" % q for q in sorted(qid_uri))
	return {
		"albume": """SELECT ?a ?a_ro ?a_en ?a_mul (MIN(YEAR(?d)) AS ?an) WHERE {
  VALUES ?a { %s }
  ?a wdt:P31/wdt:P279* wd:Q482994 .
  OPTIONAL { ?a wdt:P577 ?d }
  OPTIONAL { ?a rdfs:label ?a_ro FILTER(lang(?a_ro) = "ro") }
  OPTIONAL { ?a rdfs:label ?a_en FILTER(lang(?a_en) = "en") }
  OPTIONAL { ?a rdfs:label ?a_mul FILTER(lang(?a_mul) = "mul") }
} GROUP BY ?a ?a_ro ?a_en ?a_mul""" % valori,

		"interpreti": """SELECT ?a ?i ?i_ro ?i_en ?i_mul ?descriere ?om
       (MIN(YEAR(?n)) AS ?nastere) (MIN(YEAR(?m)) AS ?moarte)
       (MIN(YEAR(?s)) AS ?start) WHERE {
  VALUES ?a { %s }
  ?a wdt:P175 ?i .
  BIND(EXISTS { ?i wdt:P31 wd:Q5 } AS ?om)
  OPTIONAL { ?i rdfs:label ?i_ro FILTER(lang(?i_ro) = "ro") }
  OPTIONAL { ?i rdfs:label ?i_en FILTER(lang(?i_en) = "en") }
  OPTIONAL { ?i rdfs:label ?i_mul FILTER(lang(?i_mul) = "mul") }
  OPTIONAL { ?i schema:description ?descriere FILTER(lang(?descriere) = "ro") }
  OPTIONAL { ?i wdt:P569 ?n }
  OPTIONAL { ?i wdt:P570 ?m }
  OPTIONAL { ?i wdt:P571 ?s }
} GROUP BY ?a ?i ?i_ro ?i_en ?i_mul ?descriere ?om""" % valori,
	}


def albumele(randuri):
	albume = {}
	for r in randuri["albume"]:
		titlu, limba = tabel.eticheta(r, "a")
		albume[r["a"]] = {"qid": r["a"], "titlu": titlu, "limba": limba,
		                  "an": int(r["an"]) if r.get("an") else None, "interpreti": {}}
	oameni = {}
	for r in randuri["interpreti"]:
		a = albume.get(r["a"])
		if a is None:
			continue
		nume = tabel.eticheta(r, "i")[0] or "?" + r["i"]
		a["interpreti"][r["i"]] = nume
		oameni[r["i"]] = {
			"qid": r["i"], "nume": nume, "descriere": r.get("descriere", ""),
			"om": r.get("om") == "true",
			"nastere": int(r["nastere"]) if r.get("nastere") else None,
			"moarte": int(r["moarte"]) if r.get("moarte") else None,
			"start": int(r["start"]) if r.get("start") else None,
		}
	return albume, oameni


def fara_punctuatie(text):
	"""Ca în `filme.py`: aceleași litere, fără semne și fără cifre, ca sursă în
	plus. Aici o cere și „U2”: validatorul citește „U” ca pe un cuvânt de o
	literă, ca „F” din „F1” la Formula 1."""
	return re.sub(r"[^\w\s'’-]|\d", " ", text)


def nota_albumului(a, interpret):
	surse = [a["titlu"], fara_punctuatie(a["titlu"]), a["an"], interpret,
	         fara_punctuatie(interpret)]
	return ("„%s” este un album lansat în %d de %s." % (a["titlu"], a["an"], interpret)), surse


def lista_titluri(titluri):
	bucati = ["„%s” (%d)" % (t, an) for t, an in titluri]
	return bucati[0] if len(bucati) == 1 else ", ".join(bucati[:-1]) + " și " + bucati[-1]


def nota_interpretului(om, albume_lui):
	"""Un om (`comun.nota_omului`) sau o formație — și cel mult trei albume.

	La formații nu există ani de viață, ci anul înființării (`P571`). Propoziția
	e „a luat ființă în”, nu „s-a format”: nu cere un acord cu „formație” sau cu
	„grup”, pe care nota nu-l știe.
	"""
	if om["om"]:
		text, surse = comun.nota_omului(om["nume"], om, prezent=True)
	else:
		surse = [om["nume"], fara_punctuatie(om["nume"])]
		descriere = comun.curata_descrierea(om["descriere"])
		# Descrierea stă ca APOZIȚIE, între virgule: „Queen, trupă rock
		# britanică, a luat ființă în 1970.” Prima formă era „Queen este trupă
		# rock britanică”, fără articol — iar articolul („o trupă”, „un grup”)
		# depinde de genul unui cuvânt pe care-l scrie Wikidata, nu eu.
		if descriere:
			surse.append(descriere)
		if om["start"]:
			surse.append(om["start"])
		if descriere and om["start"]:
			text = "%s, %s, a luat ființă în %d." % (om["nume"], descriere, om["start"])
		elif om["start"]:
			text = "%s a luat ființă în %d." % (om["nume"], om["start"])
		elif descriere:
			text = "%s: %s." % (om["nume"], descriere)
		else:
			text = ""
	alese = sorted(albume_lui, key=lambda a: a["an"])[:3]
	for a in alese:
		surse += [a["titlu"], fara_punctuatie(a["titlu"]), a["an"]]
	adaos = "Printre albumele lansate: %s." % lista_titluri([(a["titlu"], a["an"]) for a in alese])
	if len(text) + 1 + len(adaos) > comun.MAX_NOTA:
		adaos = "Printre albumele lansate: %s." % lista_titluri(
			[(a["titlu"], a["an"]) for a in alese[:1]])
	return (text + " " + adaos).strip(), surse


def construieste(lista, albume, oameni, t):
	nivel = {r["qid"]: r["nivel"] for r in lista}
	bune = []
	for r in lista:
		a = albume[r["qid"]]
		if len(a["interpreti"]) != 1:
			t.refuzate.append("„%s”: %d interpreți (%s)" % (
				a["titlu"], len(a["interpreti"]), ", ".join(sorted(a["interpreti"].values()))))
			continue
		if a["an"] is None:
			t.refuzate.append("„%s”: fără an (P577)" % a["titlu"])
			continue
		bune.append(a)

	for a in bune:
		interpret = list(a["interpreti"].values())[0]
		fapt = "wd:%s" % a["qid"]
		text_nota, surse = nota_albumului(a, interpret)
		t.fapt(fapt, text_nota, surse)
		altii = [(list(x["interpreti"].values())[0], abs(x["an"] - a["an"]))
		         for x in bune if x is not a]
		t.intrebare(a["qid"], "cere_interpret",
		            "Cine a lansat albumul „%s”, în %d?" % (a["titlu"], a["an"]),
		            interpret, [interpret], altii, nivel[a["qid"]], fapt, [a["titlu"]])

	pe_om = {}
	for a in bune:
		pe_om.setdefault(list(a["interpreti"])[0], []).append(a)
	for qid_i, ale_lui in sorted(pe_om.items()):
		# Ca la filme: cu un singur album în tabel, sensul invers ar fi aceeași
		# pereche întoarsă pe dos.
		if len(ale_lui) < 2:
			continue
		om = oameni[qid_i]
		ordonate = sorted(ale_lui, key=lambda a: comun.zar(qid_i, a["qid"]))
		libere = [a for a in ordonate if not t.ar_atinge([om["nume"]], a["titlu"])]
		a = (libere or ordonate)[0]
		altele = [(x["titlu"], abs(x["an"] - a["an"])) for x in bune
		          if list(x["interpreti"])[0] != qid_i]
		fapt = "wd:%s" % qid_i
		text_nota, surse = nota_interpretului(om, ale_lui)
		t.fapt(fapt, text_nota, surse)
		t.intrebare(qid_i, "cere_album",
		            "Care dintre aceste albume a fost lansat de %s?" % om["nume"],
		            a["titlu"], [x["titlu"] for x in ale_lui], altele,
		            nivel[a["qid"]], fapt, [om["nume"]])


def propune(arg):
	r = comun.interogheaza(
		"SELECT ?a ?n WHERE { ?a wdt:P31 wd:Q482994 ; wikibase:sitelinks ?n . "
		"FILTER(?n > %d) }" % MINIM_EDITII, "albumele răspândite")
	editii = {comun.qid_din(x["a"]["value"]): int(x["n"]["value"]) for x in comun.legaturi(r)}
	qid_uri = sorted(editii, key=lambda q: -editii[q])
	randuri = {"albume": [], "interpreti": []}
	for i in range(0, len(qid_uri), 150):
		for nume, text in interogarile(qid_uri[i:i + 150]).items():
			raspuns = comun.interogheaza(text, "%s, lotul %d" % (nume, i // 150 + 1))
			randuri[nume] += [tabel._simplu(x) for x in comun.legaturi(raspuns)]
	albume, _ = albumele(randuri)
	propuse = []
	for q in qid_uri:
		a = albume.get(q)
		if a and a["titlu"]:
			propuse.append({"qid": q, "nume": a["titlu"], "nivel": 2, "an": a["an"],
			                "editii": editii[q],
			                "interpreti": " + ".join(sorted(a["interpreti"].values()))})
	tabel.scrie_propunerile(CALE_PROPUSE, propuse,
	                        ["qid", "nume", "nivel", "an", "editii", "interpreti"])


def main():
	arg = comun.argumentele()
	print("FABRICA — album → interpret")
	if arg.propune:
		propune(arg)
		return 0
	lista = tabel.citeste_randurile(CALE_LISTA, CAMPURI, "albumele alese")
	randuri = tabel.aduce(CALE_CACHE, interogarile([r["qid"] for r in lista]), arg.reincarca)
	albume, oameni = albumele(randuri)
	tabel.verifica_numele(lista, {q: a["titlu"] for q, a in albume.items()}, "album")
	if arg.masoara:
		print("\n  interpreți pe album: %s" % sorted({len(a["interpreti"]) for a in albume.values()}))
		return 0
	t = tabel.Tabel("albume", "divertisment", "muzica_moderna", "interpret", "albumele")
	construieste(lista, albume, oameni, t)
	return t.incheie(arg, DUBLURI, NU_SUNT_DUBLURI)


if __name__ == "__main__":
	comun.ruleaza(main)

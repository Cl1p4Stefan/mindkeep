#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — film → regizor.

    python tools/fabrica/filme.py --propune    filmele cele mai răspândite (ediții
                                               Wikipedia), în `date/filme_propuse.json`
    python tools/fabrica/filme.py --masoara    doar măsoară
    python tools/fabrica/filme.py              raportul întreg, fără să scrie
    python tools/fabrica/filme.py --scrie      scrie perechea din data/trivia_gen/
    python tools/fabrica/filme.py --reincarca  reia din rețea (OBLIGATORIU după ce
                                               schimbi `date/filme.json`: interogarea
                                               cere exact filmele din listă)

Două sensuri, ca la `opere.py`:

    cere_regizor   „Cine a regizat filmul «Casablanca», din 1942?” — PER FILM
    cere_film      „Care dintre aceste filme a fost regizat de Billy Wilder?” — PER OM

Lista o scriu EU (`date/filme.json`), Wikidata dă regizorul, anul și premiile:
„eu spun CARE, mașina spune CE”, ca la elemente și la compozitori.

─────────────────────────────────────────────────────────────
CAPCANELE, MĂSURATE PE 27 OCTOMBRIE 2026, PE 1233 DE FILME CU PESTE 45 DE EDIȚII

1. FILME CU MAI MULȚI REGIZORI: „Pe aripile vântului” (Fleming, Wood, Cukor),
   „Matrix” (frații Wachowski), animațiile Disney cu câte cinci. O întrebare cu
   un singur buton verde n-are voie să aleagă unul. Regula: EXACT un regizor la
   Wikidata, altfel rândul se refuză și se tipărește.

2. ANUL: `P577` are câte o declarație pe țară. Se ia CEL MAI MIC an — prima
   lansare, oriunde. O reeditare sau o lansare târzie în altă țară nu poate
   coborî anul, deci minimul nu greșește niciodată în sensul periculos.

3. TITLUL: eticheta română, unde există (cele mai multe filme mari o au, și e
   titlul sub care au rulat la noi: „Închisoarea îngerilor”); altfel cea engleză.
   Titlul NU e tradus de mine — modelul de limbaj formulează, nu informează.

4. FILMELE DEJA ÎNTREBATE DE MÂNĂ sunt multe (75 de întrebări de cinema, cele mai
   multe „ce film din anul X, regizat de Y…”). Le prinde motorul (`tabel.py`),
   pe titlu și pe regizor, iar la `cere_film` se alege dinadins un film pe care
   nicio întrebare de mână nu-l leagă deja de același om.
"""

import os
import re

import comun
import tabel
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_filme.json")
CALE_LISTA = os.path.join(comun.DOSAR_DATE, "filme.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "filme_propuse.json")

CAMPURI = {"qid", "nume", "nivel"}

# Premiile care intră în notă, cu propoziția lor. Un premiu e o afirmație cu dată
# și cu juriu, deci un fapt, nu o părere despre film.
PREMII = {
	"Q102427": "A primit Oscarul pentru cel mai bun film.",
	"Q179808": "A primit Palme d'Or la Cannes.",
}

# Cât de departe se uită `--propune`: filmele cu mai multe ediții Wikipedia.
MINIM_EDITII = 45

DUBLURI = {}
NU_SUNT_DUBLURI = {}


def interogarile(qid_uri):
	valori = " ".join("wd:%s" % q for q in sorted(qid_uri))
	return {
		"filme": """SELECT ?f ?f_ro ?f_en ?f_mul (MIN(YEAR(?d)) AS ?an)
       (GROUP_CONCAT(DISTINCT STRAFTER(STR(?limba), "entity/"); separator=" ") AS ?limbi) WHERE {
  VALUES ?f { %s }
  ?f wdt:P31/wdt:P279* wd:Q11424 .
  OPTIONAL { ?f wdt:P577 ?d }
  OPTIONAL { ?f wdt:P364 ?limba }
  OPTIONAL { ?f rdfs:label ?f_ro FILTER(lang(?f_ro) = "ro") }
  OPTIONAL { ?f rdfs:label ?f_en FILTER(lang(?f_en) = "en") }
  OPTIONAL { ?f rdfs:label ?f_mul FILTER(lang(?f_mul) = "mul") }
} GROUP BY ?f ?f_ro ?f_en ?f_mul""" % valori,

		"regizori": """SELECT ?f ?r ?r_ro ?r_en ?r_mul ?descriere
       (MIN(YEAR(?n)) AS ?nastere) (MIN(YEAR(?m)) AS ?moarte) WHERE {
  VALUES ?f { %s }
  ?f wdt:P57 ?r .
  OPTIONAL { ?r rdfs:label ?r_ro FILTER(lang(?r_ro) = "ro") }
  OPTIONAL { ?r rdfs:label ?r_en FILTER(lang(?r_en) = "en") }
  OPTIONAL { ?r rdfs:label ?r_mul FILTER(lang(?r_mul) = "mul") }
  OPTIONAL { ?r schema:description ?descriere FILTER(lang(?descriere) = "ro") }
  OPTIONAL { ?r wdt:P569 ?n }
  OPTIONAL { ?r wdt:P570 ?m }
} GROUP BY ?f ?r ?r_ro ?r_en ?r_mul ?descriere""" % valori,

		"premii": """SELECT DISTINCT ?f ?p WHERE {
  VALUES ?f { %s }
  VALUES ?p { %s }
  ?f wdt:P166 ?p .
}""" % (valori, " ".join("wd:%s" % p for p in PREMII)),
	}


def filmele(randuri):
	filme = {}
	for r in randuri["filme"]:
		titlu, limba = tabel.eticheta(r, "f")
		filme[r["f"]] = {"qid": r["f"], "titlu": titlu, "limba": limba,
		                 "an": int(r["an"]) if r.get("an") else None,
		                 "limbi": set(r.get("limbi", "").split()),
		                 "regizori": {}, "premii": set()}
	oameni = {}
	for r in randuri["regizori"]:
		f = filme.get(r["f"])
		if f is None:
			continue
		nume = tabel.eticheta(r, "r")[0]
		if not nume:
			# Un regizor fără nicio etichetă se numără (filmul are tot doi
			# regizori), dar nu se poate afișa — deci rândul cade la regula 1.
			nume = "?" + r["r"]
		f["regizori"][r["r"]] = nume
		oameni[r["r"]] = {
			"qid": r["r"], "nume": nume, "descriere": r.get("descriere", ""),
			"nastere": int(r["nastere"]) if r.get("nastere") else None,
			"moarte": int(r["moarte"]) if r.get("moarte") else None,
		}
	for r in randuri["premii"]:
		if r["f"] in filme:
			filme[r["f"]]["premii"].add(r["p"])
	return filme, oameni


def fara_punctuatie(text):
	"""Titlul cu semnele scoase, ca sursă în plus pentru validator.

	„Adio, Lenin!”, „Mamma Mia!”, „Se7en”: validatorul taie sursa pe spații și
	virgule, deci „Lenin!” rămânea lipit de semnul exclamării și „Lenin” din notă
	nu se mai găsea. Aceleași litere, din aceeași sursă — nu o slăbire.
	"""
	return re.sub(r"[^\w\s'’-]|\d", " ", text)


def nota_filmului(f, regizor):
	surse = [f["titlu"], fara_punctuatie(f["titlu"]), f["an"], regizor]
	text = "„%s” este un film din %d, regizat de %s." % (f["titlu"], f["an"], regizor)
	for p in sorted(f["premii"]):
		text += " " + PREMII[p]
		surse.append(PREMII[p])
	return text, surse


def lista_titluri(titluri):
	bucati = ["„%s” (%d)" % (t, a) for t, a in titluri]
	return bucati[0] if len(bucati) == 1 else ", ".join(bucati[:-1]) + " și " + bucati[-1]


def nota_regizorului(om, filme_lui):
	"""Omul (`comun.nota_omului`) și cel mult trei dintre filmele lui din tabel.

	„A regizat, printre altele, …” și nu „Printre filmele lui”: nota nu știe și
	nu are de unde să știe cum își spune omul, deci nu-i dă un gen gramatical.
	"""
	text, surse = comun.nota_omului(om["nume"], om, prezent=True)
	alese = sorted(filme_lui, key=lambda f: f["an"])[:3]
	for f in alese:
		surse += [f["titlu"], fara_punctuatie(f["titlu"]), f["an"]]
	adaos = "A regizat, printre altele, %s." % lista_titluri([(f["titlu"], f["an"]) for f in alese])
	if len(text) + 1 + len(adaos) > comun.MAX_NOTA:
		adaos = "A regizat, printre altele, %s." % lista_titluri(
			[(f["titlu"], f["an"]) for f in alese[:1]])
	return (text + " " + adaos).strip(), surse


# Cât „costă” o limbă diferită, în ani. Destul cât un film în aceeași limbă de
# acum 40 de ani să treacă înaintea unuia din alt colț al lumii din același an.
ALTA_LIMBA = 60


def departare(f, x):
	"""Cât de departe e filmul `x` de `f`, ca distractor: anii, plus limba."""
	return abs(x["an"] - f["an"]) + (0 if f["limbi"] & x["limbi"] else ALTA_LIMBA)


def construieste(lista, filme, oameni, t):
	nivel = {r["qid"]: r["nivel"] for r in lista}
	bune = []
	for r in lista:
		f = filme[r["qid"]]
		if len(f["regizori"]) != 1:
			t.refuzate.append("„%s”: %d regizori (%s)" % (
				f["titlu"], len(f["regizori"]), ", ".join(sorted(f["regizori"].values()))))
			continue
		if f["an"] is None:
			t.refuzate.append("„%s”: fără an (P577)" % f["titlu"])
			continue
		bune.append(f)

	for f in bune:
		qid_r, regizor = list(f["regizori"].items())[0]
		fapt = "wd:%s" % f["qid"]
		text_nota, surse = nota_filmului(f, regizor)
		t.fapt(fapt, text_nota, surse)
		# Distractorii: regizorii celorlalte filme, cei mai apropiați ca an — și
		# întâi cei care au filmat în aceeași limbă (`P364`). Prima rulare, fără
		# limbă, dădea Radu Jude printre regizorii posibili ai unui „Războiul
		# stelelor”: un distractor care se elimină singur nu e un distractor.
		altii = [(list(x["regizori"].values())[0], departare(f, x))
		         for x in bune if x is not f]
		t.intrebare(f["qid"], "cere_regizor",
		            "Cine a regizat filmul „%s”, din %d?" % (f["titlu"], f["an"]),
		            regizor, [regizor], altii, nivel[f["qid"]], fapt, [f["titlu"]])

	# ── PER REGIZOR ──
	pe_om = {}
	for f in bune:
		pe_om.setdefault(list(f["regizori"])[0], []).append(f)
	for qid_r, ale_lui in sorted(pe_om.items()):
		# Numai regizorii cu MĂCAR DOUĂ filme în tabel. Cu unul singur, „care
		# dintre aceste filme e al lui X” e întrebarea directă întoarsă pe dos:
		# același fapt, aceeași pereche, a doua oară în același sac.
		if len(ale_lui) < 2:
			continue
		om = oameni[qid_r]
		ordonate = sorted(ale_lui, key=lambda f: comun.zar(qid_r, f["qid"]))
		libere = [f for f in ordonate if not t.ar_atinge([om["nume"]], f["titlu"])]
		f = (libere or ordonate)[0]
		ale_lui_titluri = [x["titlu"] for x in ale_lui]
		altele = [(x["titlu"], departare(f, x)) for x in bune
		          if list(x["regizori"])[0] != qid_r]
		fapt = "wd:%s" % qid_r
		text_nota, surse = nota_regizorului(om, ale_lui)
		t.fapt(fapt, text_nota, surse)
		t.intrebare(qid_r, "cere_film",
		            "Care dintre aceste filme a fost regizat de %s?" % om["nume"],
		            f["titlu"], ale_lui_titluri, altele,
		            nivel[f["qid"]], fapt, [om["nume"]])


def propune(arg):
	"""Filmele cu cele mai multe ediții Wikipedia, cu regizorii și anul.

	Nu se scrie în cache: e o listă de citit, refăcută la cerere.
	"""
	r = comun.interogheaza(
		"SELECT ?f ?n WHERE { ?f wdt:P31 wd:Q11424 ; wikibase:sitelinks ?n . "
		"FILTER(?n > %d) }" % MINIM_EDITII, "filmele răspândite")
	editii = {comun.qid_din(x["f"]["value"]): int(x["n"]["value"]) for x in comun.legaturi(r)}
	qid_uri = sorted(editii, key=lambda q: -editii[q])
	randuri = {"filme": [], "regizori": [], "premii": []}
	for i in range(0, len(qid_uri), 150):
		for nume, text in interogarile(qid_uri[i:i + 150]).items():
			raspuns = comun.interogheaza(text, "%s, lotul %d" % (nume, i // 150 + 1))
			randuri[nume] += [tabel._simplu(x) for x in comun.legaturi(raspuns)]
	filme, _ = filmele(randuri)
	propuse = []
	for q in qid_uri:
		f = filme.get(q)
		if f and f["titlu"]:
			propuse.append({"qid": q, "nume": f["titlu"], "nivel": 2, "an": f["an"],
			                "editii": editii[q],
			                "regizori": " + ".join(sorted(f["regizori"].values()))})
	tabel.scrie_propunerile(CALE_PROPUSE, propuse,
	                        ["qid", "nume", "nivel", "an", "editii", "regizori"])


def main():
	arg = comun.argumentele()
	print("FABRICA — film → regizor")
	if arg.propune:
		propune(arg)
		return 0
	lista = tabel.citeste_randurile(CALE_LISTA, CAMPURI, "filmele alese")
	randuri = tabel.aduce(CALE_CACHE, interogarile([r["qid"] for r in lista]), arg.reincarca)
	filme, oameni = filmele(randuri)
	tabel.verifica_numele(lista, {q: f["titlu"] for q, f in filme.items()}, "film")

	if arg.masoara:
		limbi = {}
		for f in filme.values():
			limbi[f["limba"]] = limbi.get(f["limba"], 0) + 1
		print("\n  titluri pe limba etichetei: %s" % limbi)
		print("  regizori pe film: %s" % sorted(
			{len(f["regizori"]) for f in filme.values()}))
		return 0

	t = tabel.Tabel("filme", "divertisment", "cinematografie", "regizor", "filmele")
	construieste(lista, filme, oameni, t)
	return t.incheie(arg, DUBLURI, NU_SUNT_DUBLURI)


if __name__ == "__main__":
	comun.ruleaza(main)

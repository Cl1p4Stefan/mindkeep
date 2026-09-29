#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — țara și capitala ei, din Wikidata.

    python tools/fabrica/capitale.py --propune     toate statele membre ONU, cu capitala,
                                                   ISO-ul și edițiile. Scrie doar
                                                   date/tari_propuse.json
    python tools/fabrica/capitale.py --masoara     distribuția edițiilor, pragul automat
                                                   posibil, etichetele lipsă, capitalele
                                                   multiple. Nu scrie nimic în data/
    python tools/fabrica/capitale.py               raportul întreg, cu tot cu ciorne
    python tools/fabrica/capitale.py --scrie       scrie perechea din data/trivia_gen/,
                                                   FĂRĂ ciorne
    python tools/fabrica/capitale.py --reincarca   reia din rețea și rescrie cache-ul

Al treilea tabel al fabricii, pentru domeniul `geografie`. Coloanele scrise de
mână stau în `tools/fabrica/date/tari.json`; ce e comun cu celelalte tabele, în
`tools/fabrica/comun.py`.

    data/trivia_gen/capitale_intrebari.json   întrebările
    data/trivia_gen/capitale_fapte.json       faptele, cu note goale și codul ISO

─────────────────────────────────────────────────────────────
CINE INTRĂ: STAT MEMBRU ONU, NU „STAT SUVERAN"

Filtrul e `P463 = Q1065` („membru al Organizației Națiunilor Unite"), cu
declarația fără dată de sfârșit.

DE CE NU CLASA „stat suveran" (`P31 = Q3624078`), care ar fi fost drumul evident.
Fiindcă „suveran" e o judecată, iar pe Wikidata o judecată contestată apare ca o
listă lungă de cazuri speciale: Kosovo, Taiwan, Palestina, Abhazia, Sahara
Occidentală, Ciprul de Nord. Fiecare ar fi cerut o decizie de la mine, iar un joc
de brain-training n-are ce căuta în dezbaterea aceea.

Apartenența la ONU e o CHESTIUNE DE FAPT, verificabilă, și nu e a mea. Statele cu
recunoaștere parțială ies de la sine, nu pe o listă de excluderi pe care ar trebui
s-o apăr. Pierderea: Vaticanul și Palestina sunt observatori, nu membri, deci nu
intră — iar Vaticanul chiar e cultură generală. Prețul e mic și e cinstit plătit.

Iar „fără dată de sfârșit" pe declarația de apartenență scoate URSS,
Cehoslovacia și Iugoslavia fără nicio listă de excepții: au fost membre, nu mai
sunt. Aceeași formă ca la capitală — o apartenență, ca o capitală, e o afirmație
cu un ÎNCEPUT și uneori un SFÂRȘIT, iar „actual" înseamnă „fără sfârșit".

─────────────────────────────────────────────────────────────
STATE ISTORICE: „FĂRĂ DATĂ DE SFÂRȘIT" NU E DE AJUNS

Măsurat, criteriul de mai sus a dat 203 țări, nu 193. Cele în plus sunt state
ÎNCHEIATE a căror apartenență la ONU pur și simplu n-are dată de sfârșit scrisă în
Wikidata: Republica Populară Mongolă, Regatul Nepalului, Statul Islamic
Afganistan, Republica Democratică Somalia, Republica Afganistan, Republica Congo
(cea din 1960), plus Regatul Laosului și Republica Populară Mozambic.

Lecția, și e aceeași formă ca la ediții la opere: UN CÂMP LIPSĂ NU E UN „NU".
`FILTER NOT EXISTS { pq:P582 }` înseamnă „nu scrie nicăieri că s-a terminat", nu
„nu s-a terminat". Pe o bază editată de oameni, cele două nu sunt același lucru, și
diferența e exact conținutul greșit.

Leacul: două semne în plus, `P576` (data desființării) și „instanță de țară
istorică". Măsurate, cad pe EXACT aceleași 8 entități, deci sunt de acord între
ele — și niciuna dintre cele 8 n-are cod ISO, deci nu se pierde nimic.

─────────────────────────────────────────────────────────────
CODUL ISO SE RAPORTEAZĂ, NU SE CERE

Prima încercare a fost să cer `P297` (ISO 3166-1 alpha-2) ca filtru de intrare: îl
au 192 din 203, și cele 11 care nu-l au sunt exact suspecții. Curat — dar pierde
DANEMARCA. Membrul ONU e „Regatul Danemarcei" (`Q756617`), care n-are cod ISO;
codul DK stă pe „Danemarca" (`Q35`), care nu e membru. Aceeași poveste la Țările de
Jos, doar că acolo codul stă pe Regat.

Deci ISO-ul e RAPORTAT, nu cerut: absența lui înseamnă doar „țara asta nu va putea
avea hartă la pasul 13", ceea ce nu e un motiv să nu fie întrebată. Cele două
entități fără ISO care mai rămân după filtrul de stat istoric n-au nici etichetă
română, iar numele e o afirmație verificată — deci nu pot intra în tăcere.

Iar unde Wikidata nu-l dă, codul se poate scrie de mână: `"cod_iso_de_mana": "DK"`.
Vezi `cod_iso_ales` pentru de ce câmpul ăsta ține o VALOARE, nu un `true`, și
pentru cele două feluri în care oprește.

─────────────────────────────────────────────────────────────
CAPITALA ACTUALĂ: DE CE PRIN NODUL DE DECLARAȚIE

Capitalele se cer prin `p:P36` → `ps:P36`, nu prin scurtătura `wdt:P36`.

„Capitala fără dată de sfârșit" e o însușire a DECLARAȚIEI, nu a valorii. Cu
`wdt:P36`, Kazahstanul ar veni cu Astana ȘI cu Almatî (capitala până în 1997), iar
scriptul n-ar avea de unde să știe care e care. Cu nodul de declarație, `pq:P582`
(data de sfârșit) se poate întreba, iar fostele capitale cad singure.

ȘI CE SE ÎNTÂMPLĂ CÂND RĂMÂN MAI MULTE. Nu se alege prima. Scriptul se OPREȘTE și
tipărește țara cu toate capitalele ei, fiindcă „mai multe capitale actuale" nu e o
eroare în date, e un fapt despre țară: Bolivia (La Paz / Sucre), Africa de Sud
(trei), Țările de Jos (Amsterdam / Haga). Un script care ar alege în tăcere între
La Paz și Sucre e un script care predă o greșeală cu toată încrederea.

Ieșirea e a omului: ori scoți rândul din tabel, ori pui `"capitala_qid"` pe el și
alegerea e scrisă, deci se vede în diff.

─────────────────────────────────────────────────────────────
CELE DOUĂ SENSURI, ȘI DE CE NUMAI UNUL CERE GRAMATICĂ

    cere_capitala   „Care este capitala Franței?"            → Paris
    cere_tara       „Canberra este capitala cărei țări?"     → Australia

Sensul direct cere GENITIVUL țării, iar el nu se calculează: Franței, Japoniei,
Egiptului, Statelor Unite ale Americii, Țării Galilor. La elemente genitivele erau
substantive comune cu vreo trei tipare; aici sunt nume proprii, fiecare cu forma
lui. Deci `genitiv` e o coloană de mână, ca la elemente — și tot ca acolo, plata e
că întrebarea generată iese identică cu cea scrisă de mână (`mana:0009`,
„Care este capitala Portugaliei?").

Sensul invers nu cere nicio declinare: „cărei țări" ține toată gramatica, iar
capitala stă la nominativ. De-aia el n-are nevoie de nicio coloană nouă.

Relația e UNU-LA-UNU după filtrare (o țară, o capitală actuală), deci AMBELE
sensuri sunt per țară — spre deosebire de opere, unde relația mulți-la-unu obliga
sensul invers să fie per autor, ca să nu iasă întrebări cu text repetat.

─────────────────────────────────────────────────────────────
ACELEAȘI DOUĂ REGULI CA LA CELELALTE TABELE

STRICT: orice lucru pe care scriptul nu-l recunoaște oprește tot.

UN `id` NU SE REFOLOSEȘTE NICIODATĂ. Se calculează din QID-ul ȚĂRII și din sens
(`wd:Q142:capitala:cere_capitala`), deci e același la fiecare rulare. Cheia e
țara și în sensul invers, deși acolo se arată capitala: țara e ce ține faptul, iar
o capitală mutată n-are voie să rupă identitatea întrebării.
"""

import math
import os
import re

import comun
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_capitale.json")

CALE_TARI = os.path.join(comun.DOSAR_DATE, "tari.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "tari_propuse.json")

CALE_INTREBARI = os.path.join(comun.DOSAR_GEN, "capitale_intrebari.json")
CALE_FAPTE = os.path.join(comun.DOSAR_GEN, "capitale_fapte.json")

DOMENIU = "geografie"

# Relația, din care se compune `id`-ul: `wd:Q142:capitala:cere_capitala`.
RELATIE = "capitala"

# Numele spune ce se CERE.
SENSURI = ["cere_capitala", "cere_tara"]

# Organizația Națiunilor Unite. Vezi docstring-ul pentru de ce apartenența la ea
# e criteriul de intrare, și nu clasa „stat suveran".
ONU = "Q1065"

# Câmpurile pe care un rând din `tari.json` are voie să le aibă. Lista e ÎNCHISĂ:
# „ciorne" în loc de „ciorna" ar fi o ciornă care ajunge în joc, fără ca nimic să
# spună nimic.
CAMPURI = {"qid", "tara", "genitiv", "capitala", "nivel", "ciorna",
           "capitala_qid", "tara_de_mana", "capitala_de_mana", "cod_iso_de_mana"}

# O capitală mutată DUPĂ anul ăsta intră în lista „de citit cu ochiul". Nu
# oprește nimic — doar îmi spune să mă uit. Vezi `arata_mutarile_recente`.
ANUL_RECENT = 2000

# ─────────────────────────────────────────────────────────────
# EXCLUSE DE MÂNĂ, CU MOTIVUL SCRIS
#
# Stă lângă `DUBLURI` dinadins, ca să se vadă că e o DECIZIE, nu o scăpare. Un
# rând lipsă dintr-un tabel de 130 nu se observă niciodată; o excludere scrisă,
# cu motivul ei, se citește la fiecare deschidere a fișierului.
#
# Scriptul OPREȘTE dacă o țară exclusă apare totuși în `tari.json`: altfel
# excluderea ar fi doar o părere într-un comentariu.
# ─────────────────────────────────────────────────────────────
EXCLUSE = {
	"Q801": "Israel — capitala e contestată internațional (Ierusalim / Tel Aviv). "
	        "Un joc de învățare n-are voie să prezinte un răspuns disputat ca pe un "
	        "fapt simplu, cu un singur buton verde.",
}

# Întrebări din fișierul scris de mână care spun deja ce-am vrea să generăm.
# Cheia e (QID-ul țării, sens); valoarea e id-ul întrebării care ocupă locul.
#
# Tabelul singur ar rezolva ziua de azi. De-aia există și `verifica_dublurile()`,
# care caută singură prin fișierul de mână și OPREȘTE scriptul dacă găsește una
# nedeclarată — și oprește la fel dacă o declarație de aici nu se mai găsește.
DUBLURI = {
	("Q45", "cere_capitala"): "mana:0009",     # Care este capitala Portugaliei?
	("Q408", "cere_capitala"): "mana:0057",    # Care este capitala Australiei?
	("Q232", "cere_capitala"): "mana:0101",    # Care este capitala Kazahstanului?
}

# Câte propuneri se scriu la `--propune`. Toate cele ~193, fiindcă tabelul se
# taie cu ochiul, nu cu un prag: un prag pe ediții ar șterge exact țările mici
# pentru care întrebarea e interesantă. (Lecția de la opere, unde pragul de 5
# ediții tăiase nouă zecimi din literatura română.)
CATE_PROPUNERI = 0  # 0 = toate


# ─────────────────────────────────────────────────────────────
# INTEROGĂRILE
# ─────────────────────────────────────────────────────────────

# DOUĂ CERERI, NU UNA. Prima dă o linie pe țară, cu însușirile strânse în
# `GROUP_CONCAT`; a doua, o linie pe fiecare pereche (țară, capitală).
#
# Despărțite fiindcă altfel data de început a capitalei s-ar amesteca între
# capitale: cu totul într-un singur `GROUP BY`, `MIN(?inceput)` ar da anul cel mai
# vechi dintre toate capitalele țării, iar tocmai ce vreau să știu e DACĂ UNA
# ANUME s-a mutat recent.
INTEROGARE_TARI = """
SELECT ?tara ?eticheta ?iso ?sitelinks ?desfiintata ?istorica ?coord
       (GROUP_CONCAT(DISTINCT STR(?continent); separator=" ") AS ?continente)
       (GROUP_CONCAT(DISTINCT STR(?vecin); separator=" ") AS ?vecini)
WHERE {
  ?tara p:P463 ?membru .
  ?membru ps:P463 wd:%s .
  FILTER NOT EXISTS { ?membru pq:P582 ?a_ieșit }
  ?tara wikibase:sitelinks ?sitelinks .
  OPTIONAL { ?tara wdt:P297 ?iso . }
  OPTIONAL { ?tara wdt:P30 ?continent . }
  OPTIONAL { ?tara wdt:P47 ?vecin . }
  OPTIONAL { ?tara wdt:P576 ?desfiintata . }
  OPTIONAL { ?tara wdt:P625 ?coord . }
  OPTIONAL { ?tara wdt:P31/wdt:P279* wd:Q3024240 . BIND(true AS ?istorica) }
  OPTIONAL { ?tara rdfs:label ?eticheta . FILTER(lang(?eticheta) = "ro") }
}
GROUP BY ?tara ?eticheta ?iso ?sitelinks ?desfiintata ?istorica ?coord
""" % ONU

# Eticheta capitalei o cerem cu `rdfs:label` filtrat EXPLICIT pe „ro", nu prin
# serviciul de etichete al Wikidata. Serviciul are limbi de rezervă, deci o
# capitală fără etichetă română ar veni cu una englezească strecurată pe ușa din
# dos — și ai crede că ai un nume românesc când n-ai. Așa, lipsa se vede ca lipsă.
INTEROGARE_CAPITALE = """
SELECT ?tara ?capitala ?ro ?en ?de_cand WHERE {
  ?tara p:P463 ?membru .
  ?membru ps:P463 wd:%s .
  FILTER NOT EXISTS { ?membru pq:P582 ?a_ieșit }
  ?tara p:P36 ?decl .
  ?decl ps:P36 ?capitala .
  ?decl wikibase:rank ?rang .
  FILTER(?rang != wikibase:DeprecatedRank)
  FILTER NOT EXISTS { ?decl pq:P582 ?sfarsit }
  OPTIONAL { ?decl pq:P580 ?de_cand . }
  OPTIONAL { ?capitala rdfs:label ?ro . FILTER(lang(?ro) = "ro") }
  OPTIONAL { ?capitala rdfs:label ?en . FILTER(lang(?en) = "en") }
}
""" % ONU


def ia_datele(reincarca):
	"""Cele două răspunsuri brute, din cache sau din rețea.

	CE validează cache-ul stă aici, nu în modulul comun: pentru capitale e
	criteriul de intrare (ONU) — dacă mâine l-aș schimba și aș uita
	`--reincarca`, scriptul ar genera liniștit dintr-o mulțime greșită de țări.
	"""
	pachet = None if reincarca else comun.cache_citeste(CALE_CACHE)
	if pachet is not None:
		if str(pachet.get("criteriu", "")) != ONU:
			raise Eroare(
				"cache-ul e luat cu criteriul de intrare %s, iar acum ONU e %s.\n"
				"  Criteriul stă în interogare, deci schimbarea lui cere --reincarca."
				% (pachet.get("criteriu", "?"), ONU))
		return pachet

	print("  Reîncarc din rețea.")
	return comun.cache_scrie(CALE_CACHE, {
		"criteriu": ONU,
		"tari": comun.interogheaza(INTEROGARE_TARI, "țările membre ONU"),
		"capitale": comun.interogheaza(INTEROGARE_CAPITALE, "capitalele actuale"),
	})


# ─────────────────────────────────────────────────────────────
# CITIREA RĂSPUNSURILOR
# ─────────────────────────────────────────────────────────────

def coordonatele(rand):
	"""`Point(long lat)` din Wikidata → `(lat, long)`, sau `None`.

	Doar pentru măsurătoare. Wikidata scrie longitudinea PRIMA, invers față de cum
	se citește o coordonată în vorbire — o inversare care ar trece neobservată
	într-o distanță, fiindcă rezultatul tot iese un număr plauzibil.
	"""
	if "coord" not in rand:
		return None
	p = re.match(r"Point\((-?[\d.]+) (-?[\d.]+)\)", rand["coord"]["value"])
	return (float(p.group(2)), float(p.group(1))) if p else None


def desfa_tarile(pachet):
	"""Rândurile → `(țările de azi, statele istorice scoase)`.

	Statele istorice se ÎNTORC, nu se aruncă: `--masoara` le tipărește. Un filtru
	care nu-și arată niciodată prada e un filtru despre care nu mai știi, peste
	șase luni, dacă mai face ceva.
	"""
	randuri = comun.legaturi(pachet["tari"])
	if not randuri:
		raise Eroare("Wikidata n-a întors nicio țară. Interogarea sau endpointul?")

	tari = {}
	for r in randuri:
		qid = comun.qid_din(r["tara"]["value"])
		tari[qid] = {
			"qid": qid,
			"eticheta": r["eticheta"]["value"].strip() if "eticheta" in r else None,
			"iso": r["iso"]["value"].strip() if "iso" in r else "",
			"editii": int(r["sitelinks"]["value"]),
			# Cele două semne că entitatea e un stat ÎNCHEIAT, nu unul de azi. Vezi
			# `STATE ISTORICE` din docstring pentru de ce sunt amândouă necesare.
			"desfiintata": "desfiintata" in r,
			"istorica": "istorica" in r,
			# Coordonatele NU intră în punctajul distractorilor. Sunt doar pentru
			# măsurătoarea din `distractori_departe`. Vezi comentariul de acolo.
			"unde": coordonatele(r),
			"continente": comun.multe(r, "continente"),
			"vecini": comun.multe(r, "vecini"),
		}

	istorice = [t for t in tari.values() if t["desfiintata"] or t["istorica"]]
	for t in istorice:
		del tari[t["qid"]]
	return tari, istorice


def desfa_capitalele(pachet):
	"""Rândurile → un dicționar QID de țară → lista capitalelor ei ACTUALE.

	Nu se contopește nimic: dacă o țară are două, se vede că are două. Contopirea
	în tăcere ar fi exact greșeala pe care oprirea din `leaga_tabelul` există ca
	s-o prindă.
	"""
	capitale = {}
	for r in comun.legaturi(pachet["capitale"]):
		qid_tara = comun.qid_din(r["tara"]["value"])
		qid_cap = comun.qid_sau_nimic(r["capitala"]["value"])
		if qid_cap is None:
			# Un nod anonim la P36 înseamnă „are o capitală, nu se știe care". Se
			# NUMĂRĂ, ca la autorii anonimi de la opere: o țară cu o capitală știută
			# plus una necunoscută are două, deci pică regula unei singure capitale.
			qid_cap = "?"
		an = None
		if "de_cand" in r:
			potrivire = re.match(r"(-?\d{1,4})-", r["de_cand"]["value"])
			if potrivire:
				an = int(potrivire.group(1))
		intrare = {
			"qid": qid_cap,
			"ro": r["ro"]["value"].strip() if "ro" in r else None,
			"en": r["en"]["value"].strip() if "en" in r else None,
			"de_cand": an,
		}
		lista = capitale.setdefault(qid_tara, [])
		# Aceeași capitală poate veni pe mai multe rânduri (mai multe declarații).
		# Se păstrează cea cu data de început cunoscută, ca `--masoara` să poată
		# raporta mutările recente.
		vechea = next((c for c in lista if c["qid"] == qid_cap), None)
		if vechea is None:
			lista.append(intrare)
		elif vechea["de_cand"] is None:
			vechea["de_cand"] = an
	return capitale


# ─────────────────────────────────────────────────────────────
# PROPUNERILE
# ─────────────────────────────────────────────────────────────

def propune(tari, capitale, alese_deja):
	"""Toate țările membre ONU care nu sunt deja în tabel, în `date/tari_propuse.json`.

	Scrie DOAR fișierul de propuneri. Scriptul nu atinge niciodată `tari.json`: un
	script care fuzionează în fișierul unde stă judecata omului e un script care
	într-o zi i-o șterge.

	Genitivul iese GOL dinadins. Aș putea ghici o formă („Franța" → „Franței"), și
	ar ieși bine la vreo două treimi — exact rata la care încetezi să verifici. Un
	câmp gol e o întrebare pusă; un câmp completat greșit e un răspuns fals.
	"""
	propuneri = []
	fara_eticheta = 0
	fara_iso = []
	multe_capitale = []
	for qid, t in tari.items():
		if qid in alese_deja or qid in EXCLUSE:
			continue
		ale_lui = capitale.get(qid, [])
		if not t["eticheta"]:
			fara_eticheta += 1
			continue
		if len(ale_lui) != 1:
			multe_capitale.append((t["eticheta"], ale_lui))
			continue
		c = ale_lui[0]
		if not t["iso"]:
			fara_iso.append(t["eticheta"])
		propuneri.append({
			"qid": qid,
			"tara": t["eticheta"],
			"genitiv": "",
			"capitala": c["ro"] or c["en"] or "",
			"nivel": 0,
			"ciorna": True,
			"_editii": t["editii"],
			"_iso": t["iso"],
			"_capitala_wd": "%s (%s)" % (c["ro"] or "—", c["qid"]),
		})

	# Sortate pe ediții, descrescător: cele mai cunoscute sus, ca tăierea cu ochiul
	# să înceapă de unde e cel mai probabil să spui „da".
	propuneri.sort(key=lambda p: (-p["_editii"], p["tara"]))
	if CATE_PROPUNERI:
		propuneri = propuneri[:CATE_PROPUNERI]

	comun.scrie_pe_rand(CALE_PROPUSE, propuneri,
	                    ["qid", "tara", "genitiv", "capitala", "nivel", "ciorna",
	                     "_editii", "_iso", "_capitala_wd"])
	print("\n  ── PROPUNERI ──")
	print("    scrise: %d" % len(propuneri))
	print("    lăsate afară: %d deja în tabel, %d excluse de mână, %d fără etichetă "
	      "română, %d cu altceva decât o capitală actuală"
	      % (len(alese_deja), len(EXCLUSE), fara_eticheta, len(multe_capitale)))
	if multe_capitale:
		print("    cu mai multe capitale actuale (le decizi de mână sau le lași afară):")
		for nume, ale_lui in sorted(multe_capitale):
			print("      %-24s %s" % (nume, ", ".join(
				"%s (%s)" % (c["ro"] or c["en"] or "?", c["qid"]) for c in ale_lui)))
	if fara_iso:
		# Nu o oprire: ISO-ul e pentru hărțile de la pasul 13, nu pentru întrebare.
		# Vezi `CODUL ISO SE RAPORTEAZĂ, NU SE CERE` în docstring — Danemarca e aici.
		print("    fără cod ISO, deci fără hartă la pasul 13 (dar întrebarea e bună):")
		print("      %s" % ", ".join(sorted(fara_iso)))
	print("    scris: %s" % comun.relativ(CALE_PROPUSE))
	print("    Copiază rândurile pe care le vrei în %s, scrie genitivul, pune nivelul"
	      % comun.relativ(CALE_TARI))
	print("    (1/2/3) și lasă \"ciorna\": true cât timp nu sunt confirmate.")
	print("    Câmpurile cu `_` sunt doar de citit: scoate-le din rândul copiat.")


# ─────────────────────────────────────────────────────────────
# MĂSURĂTOAREA
# ─────────────────────────────────────────────────────────────

def masoara(tari, capitale, istorice, lista):
	"""Ce se poate afla din date, înainte să se aleagă metoda pentru nivel.

	Aceeași disciplină ca la celelalte două tabele: se MĂSOARĂ înainte, nu se
	presupune. La elemente cifra separa „real" de „ipotetic", nu „ușor" de „greu";
	la opere separa ceva, dar greșea 23% din rânduri. Aici o măsurăm din nou,
	fiindcă răspunsul nu se moștenește de la un tabel la altul.
	"""
	print("\n  ── CE A VENIT DIN WIKIDATA ──")
	print("    țări membre ONU: %d" % len(tari))
	cu_eticheta = sum(1 for t in tari.values() if t["eticheta"])
	print("    cu etichetă română: %d din %d" % (cu_eticheta, len(tari)))
	fara = sorted(t["qid"] for t in tari.values() if not t["eticheta"])
	if fara:
		print("      fără: %s" % ", ".join(fara))
	print("    cu cod ISO (P297): %d din %d"
	      % (sum(1 for t in tari.values() if t["iso"]), len(tari)))
	print("    cu continent (P30): %d din %d"
	      % (sum(1 for t in tari.values() if t["continente"]), len(tari)))
	print("    cu vecini (P47): %d din %d"
	      % (sum(1 for t in tari.values() if t["vecini"]), len(tari)))

	print("\n  ── CÂTE CAPITALE ACTUALE ARE FIECARE ──")
	pe_cate = {}
	for qid in tari:
		pe_cate.setdefault(len(capitale.get(qid, [])), []).append(qid)
	for cate in sorted(pe_cate):
		print("    %d capitale: %d țări" % (cate, len(pe_cate[cate])))
	for cate in sorted(pe_cate):
		if cate == 1:
			continue
		for qid in sorted(pe_cate[cate]):
			nume = tari[qid]["eticheta"] or qid
			ale_lui = capitale.get(qid, [])
			print("      %-26s %s" % (nume, ", ".join(
				"%s (%s)" % (c["ro"] or c["en"] or "?", c["qid"]) for c in ale_lui) or "—"))

	print("\n  ── DISTRIBUȚIA EDIȚIILOR WIKIPEDIA ──")
	toate = [t["editii"] for t in tari.values()]
	v = sorted(toate)
	print("    min %3d   median %3d   maxim %3d" % (v[0], v[len(v) // 2], v[-1]))
	print("    decile: %s" % comun.decile(toate))

	if not lista:
		print("\n    (tabelul e gol, deci nu se poate compara cu nivelul pus de mână)")
		return

	print("\n  ── EDIȚIILE FAȚĂ DE NIVELUL PUS DE MÂNĂ ──")
	for nivel in comun.NIVELURI:
		ale_lui = sorted(e["editii"] for e in lista if e["nivel"] == nivel)
		if not ale_lui:
			continue
		print("    nivelul %d (%3d țări): min %3d   median %3d   maxim %3d"
		      % (nivel, len(ale_lui), ale_lui[0], ale_lui[len(ale_lui) // 2], ale_lui[-1]))
	comun.cat_de_bun_ar_fi_un_prag([(e["editii"], e["nivel"]) for e in lista])


# ─────────────────────────────────────────────────────────────
# TABELUL, CONFRUNTAT CU WIKIDATA
# ─────────────────────────────────────────────────────────────

def cod_iso_ales(de_la_wikidata, de_mana, unde, nume, probleme):
	"""Codul ISO al țării: al Wikidatei, sau al meu unde ea nu-l dă.

	DE CE ȚINE O VALOARE, NU UN `true`, spre deosebire de `tara_de_mana` și
	`capitala_de_mana`. Alea sunt marcaje care spun „nu verifica afirmația mea
	împotriva etichetei" — acolo valoarea există deja în rând, iar marcajul doar
	oprește comparația. Aici Wikidata nu dă NIMIC de comparat, deci n-ar avea ce
	să ocolească un `true`: câmpul trebuie să aducă el codul.

	DOUĂ OPRIRI, și a doua e cea care contează peste șase luni:

	1. Un cod scris de mână care NU arată ca un cod (două litere mari) oprește.
	   `"dk"` sau `"DNK"` ar ajunge tăcut în fapt, iar desenatorul de hărți de la
	   pasul 13 ar căuta un contur care nu există — și eroarea ar apărea la o
	   întrebare, nu aici.

	2. Un cod scris de mână pentru care Wikidata a ÎNCEPUT să dea unul oprește și
	   el, chiar dacă cele două coincid. E aceeași regulă ca „fantomele" din
	   `DUBLURI`: o declarație care nu mai e necesară e la fel de rea ca una
	   lipsă, doar mai tăcută. Fără oprirea asta, `tari.json` ar strânge, în
	   câteva luni, coduri scrise de mână pe care nimeni nu le mai folosește — iar
	   ziua în care unul dintre ele ar contrazice Wikidata n-ar mai fi de găsit.
	"""
	if de_mana:
		if not re.fullmatch(r"[A-Z]{2}", de_mana):
			probleme.append("%s (%s): cod_iso_de_mana %r nu arată a cod ISO 3166-1 "
			                "alpha-2 (două litere mari, ex. \"DK\")" % (unde, nume, de_mana))
			return ""
		if de_la_wikidata:
			probleme.append(
				"%s (%s): Wikidata dă acum codul %r, deci cod_iso_de_mana (%r) nu mai e "
				"necesar.\n      Șterge câmpul din rând — dacă cele două ar ajunge să "
				"difere, n-ai de unde să afli." % (unde, nume, de_la_wikidata, de_mana))
			return de_la_wikidata
		return de_mana
	return de_la_wikidata


def leaga_tabelul(alese, tari, capitale):
	"""`tari.json` + datele de la Wikidata → lista de lucru. Strict la fiecare pas.

	Adună TOATE neconcordanțele înainte să se oprească. Un script care cade la
	prima nepotrivire te pune să rulezi de 30 de ori ca să repari 30 de rânduri.
	"""
	probleme = []

	qiduri = [str(r.get("qid", "")) for r in alese if isinstance(r, dict)]
	duble = sorted({q for q in qiduri if qiduri.count(q) > 1})
	if duble:
		probleme.append("QID-uri repetate în tari.json: %s" % ", ".join(duble))

	lista = []
	for i, rand in enumerate(alese):
		unde = "rândul %d din tari.json" % (i + 1)
		if not comun.verifica_campurile(rand, CAMPURI, unde, probleme):
			continue

		qid = str(rand.get("qid", ""))
		nume = str(rand.get("tara", "")).strip()
		genitiv = str(rand.get("genitiv", "")).strip()
		nume_cap = str(rand.get("capitala", "")).strip()
		nivel = rand.get("nivel")
		ciorna = bool(rand.get("ciorna", False))
		tara_de_mana = bool(rand.get("tara_de_mana", False))
		cap_de_mana = bool(rand.get("capitala_de_mana", False))
		cap_pinuit = str(rand.get("capitala_qid", "")).strip()
		iso_de_mana = str(rand.get("cod_iso_de_mana", "")).strip()

		if not re.fullmatch(r"Q\d+", qid):
			probleme.append("%s: qid %r nu arată a QID" % (unde, qid))
			continue
		# Excluderea scrisă e o DECIZIE, deci trebuie să și oprească. Altfel ar fi
		# doar o părere într-un comentariu, iar Israelul ar reintra în tabel într-o
		# zi în care copiez un rând din propuneri fără să mă uit.
		if qid in EXCLUSE:
			probleme.append("%s (%s): exclus de mână.\n      %s"
			                % (unde, nume, EXCLUSE[qid]))
			continue
		if nivel not in comun.NIVELURI:
			probleme.append("%s (%s): nivelul %r nu e 1, 2 sau 3" % (unde, nume, nivel))
			continue
		if not nume or not genitiv or not nume_cap:
			probleme.append("%s (%s): tara, genitiv sau capitala gol" % (unde, qid))
			continue
		t = tari.get(qid)
		if t is None:
			probleme.append("%s (%s): %s nu e un stat membru ONU în Wikidata "
			                "(sau apartenența lui are dată de sfârșit)" % (unde, nume, qid))
			continue

		# ── NUMELE ȚĂRII: o AFIRMAȚIE verificată, nu o dată copiată ──
		if not tara_de_mana:
			if not t["eticheta"]:
				probleme.append(
					"%s (%s): Wikidata n-are etichetă română pentru %s. Dacă numele e "
					"bun, adaugă \"tara_de_mana\": true" % (unde, nume, qid))
				continue
			if t["eticheta"].lower() != nume.lower():
				probleme.append(
					"%s: în tabel scrie %r, Wikidata (%s) spune %r. Dacă numele tău e cel "
					"cunoscut în română, adaugă \"tara_de_mana\": true"
					% (unde, nume, qid, t["eticheta"]))
				continue

		# ── CAPITALA: câte are, și care e cea aleasă ──
		ale_lui = capitale.get(qid, [])
		if not ale_lui:
			probleme.append("%s (%s): Wikidata nu-i dă nicio capitală actuală"
			                % (unde, nume))
			continue
		if cap_pinuit:
			aleasa = next((c for c in ale_lui if c["qid"] == cap_pinuit), None)
			if aleasa is None:
				probleme.append(
					"%s (%s): capitala_qid %s nu e printre capitalele actuale de la "
					"Wikidata (%s)" % (unde, nume, cap_pinuit,
					                   ", ".join(c["qid"] for c in ale_lui)))
				continue
		elif len(ale_lui) != 1:
			# NU se alege prima. Vezi docstring-ul de sus: „mai multe capitale
			# actuale" e un fapt despre țară, nu o eroare în date.
			probleme.append(
				"%s (%s): Wikidata îi dă %d capitale actuale (%s).\n"
				"      Ori scoate rândul, ori scrie \"capitala_qid\": \"Q…\" ca să alegi tu."
				% (unde, nume, len(ale_lui),
				   ", ".join("%s %s" % (c["qid"], c["ro"] or c["en"] or "?") for c in ale_lui)))
			continue
		else:
			aleasa = ale_lui[0]

		if aleasa["qid"] == "?":
			probleme.append("%s (%s): capitala e un nod anonim în Wikidata "
			                "(„se știe că are, nu se știe care”)" % (unde, nume))
			continue

		# ── NUMELE CAPITALEI: tot o afirmație verificată ──
		if not cap_de_mana:
			if not aleasa["ro"]:
				probleme.append(
					"%s (%s): Wikidata n-are etichetă română pentru capitala %s. Dacă "
					"numele e bun, adaugă \"capitala_de_mana\": true"
					% (unde, nume, aleasa["qid"]))
				continue
			if aleasa["ro"].lower() != nume_cap.lower():
				probleme.append(
					"%s (%s): în tabel capitala e %r, Wikidata (%s) spune %r. Dacă numele "
					"tău e cel cunoscut în română, adaugă \"capitala_de_mana\": true"
					% (unde, nume, nume_cap, aleasa["qid"], aleasa["ro"]))
				continue

		lista.append({
			"qid": qid,
			"tara": nume,
			"tara_wd": t["eticheta"] or "",
			"tara_de_mana": tara_de_mana,
			"genitiv": genitiv,
			"capitala": nume_cap,
			"capitala_wd": aleasa["ro"] or aleasa["en"] or "",
			"capitala_de_mana": cap_de_mana,
			"capitala_qid": aleasa["qid"],
			# TOATE capitalele actuale, nu doar cea aleasă. De aici se apără regula
			# „nicio capitală a țării întrebate nu apare ca distractor": diferența
			# contează exact când o țară are două, fiindcă a doua ar fi un AL DOILEA
			# RĂSPUNS CORECT, nu un distractor nefericit.
			"capitale_wd": {c["qid"] for c in ale_lui},
			"de_cand": aleasa["de_cand"],
			"nivel": int(nivel),
			"ciorna": ciorna,
			# Codul care ajunge în fapt: al Wikidatei, sau al meu unde ea nu-l dă.
			"iso": cod_iso_ales(t["iso"], iso_de_mana, unde, nume, probleme),
			"iso_wd": t["iso"],
			"iso_de_mana": iso_de_mana,
			"editii": t["editii"],
			"continente": set(t["continente"]),
			"vecini": set(t["vecini"]),
			"unde": t["unde"],
		})

	# UNICITATEA CELOR DOUĂ FEȚE. Două țări cu același nume afișat ar da, la sensul
	# invers, două butoane identice; două capitale cu același nume, la fel în sensul
	# direct — iar dacă amândouă sunt „corecte", două răspunsuri bune. Nu e o
	# curățenie, e chiar garanția.
	for camp, ce in (("tara", "nume de țară"), ("capitala", "nume de capitală")):
		valori = [e[camp] for e in lista]
		duble = sorted({v for v in valori if valori.count(v) > 1})
		if duble:
			probleme.append("%s afișate identice: %s" % (ce, ", ".join(duble)))

	if probleme:
		raise Eroare("tari.json nu se potrivește cu Wikidata:\n  - " + "\n  - ".join(probleme))

	# Ordinea din fișier: pe nivel, apoi pe nume. Un rând adăugat mai târziu cade
	# la locul lui, deci diff-ul din Git arată ce s-a adăugat, nu o rearanjare.
	lista.sort(key=lambda e: (e["nivel"], e["tara"]))
	return lista


def arata_numele_de_mana(lista):
	"""Tipărește toate numele puse de mână, cu ce spune Wikidata alături.

	Rostul: un câmp care OCOLEȘTE o verificare trebuie să fie ZGOMOTOS. Dacă
	`tara_de_mana` ar trece în tăcere, ar deveni, în trei luni, felul comod de a
	face o greșeală de tipar să dispară.
	"""
	de_mana = [e for e in lista
	           if e["tara_de_mana"] or e["capitala_de_mana"] or e["iso_de_mana"]]
	if de_mana:
		print("\n  ── PUSE DE MÂNĂ (%d rânduri) ──" % len(de_mana))
		for e in de_mana:
			if e["tara_de_mana"]:
				print("    țară      %-26s  Wikidata: %s"
				      % (e["tara"], e["tara_wd"] or "— (fără etichetă)"))
			if e["capitala_de_mana"]:
				print("    capitală  %-26s  Wikidata: %s"
				      % (e["capitala"], e["capitala_wd"] or "— (fără etichetă)"))
			if e["iso_de_mana"]:
				print("    cod ISO   %-4s (%-20s) Wikidata: %s"
				      % (e["iso_de_mana"], e["tara"], e["iso_wd"] or "— (fără cod)"))

	# ȚĂRILE CARE AȘTEAPTĂ UN COD. Nu o oprire: codul e pentru hărțile de la pasul
	# 13, nu pentru întrebare, iar o țară fără hartă e tot o țară bună de întrebat.
	# Dar se tipărește la fiecare rulare, ca lista să se scurteze, nu să se uite.
	fara_cod = [e for e in lista if not e["iso"]]
	if fara_cod:
		print("\n  ── FĂRĂ COD ISO (%d) ──" % len(fara_cod))
		print("    Wikidata nu-l dă, iar rândul n-are nici cod_iso_de_mana. Întrebările")
		print("    ies normal; ce lipsește e cheia hărții de la pasul 13.")
		for e in sorted(fara_cod, key=lambda x: x["tara"]):
			print('    %-26s %-10s  adaugă "cod_iso_de_mana": "??"' % (e["tara"], e["qid"]))


def arata_mutarile_recente(lista):
	"""Capitalele mutate după `ANUL_RECENT` — de citit cu ochiul, nu o oprire.

	DE CE NU OPREȘTE. O capitală mutată recent e un fapt corect în Wikidata și o
	întrebare legitimă; ce vreau e să știu că există, fiindcă tocmai alea sunt
	cazurile în care „capitala actuală" se schimbă sub picioarele mele. Indonezia
	(Jakarta → Nusantara) e exemplul de azi, și e exact felul de rând pe care
	vreau să-l verific eu înainte să-l confirm.

	O oprire aici ar fi fost greșită: m-ar fi obligat să declar o excepție pentru
	fiecare mutare, iar excepțiile declarate mecanic nu se mai citesc.
	"""
	recente = sorted((e for e in lista if e["de_cand"] and e["de_cand"] > ANUL_RECENT),
	                 key=lambda e: -e["de_cand"])
	if not recente:
		return
	print("\n  ── CAPITALE MUTATE DUPĂ %d (de citit cu ochiul) ──" % ANUL_RECENT)
	for e in recente:
		print("    %-26s %-20s din %d" % (e["tara"], e["capitala"], e["de_cand"]))


# ─────────────────────────────────────────────────────────────
# ÎNTREBĂRILE CARE SE RĂSPUND SINGURE
# ─────────────────────────────────────────────────────────────

# Cel mai scurt cuvânt împărțit care încă spune ceva. Sub patru litere,
# potrivirile devin articole și cuvinte de umplutură („de", „la", „san"), pe care
# multe nume de capitale le au fără să dea nimic de gol.
MINIM_CUVANT = 4


def cuvinte_mari(text):
	"""Cuvintele de cel puțin `MINIM_CUVANT` litere, fără diacritice și majuscule."""
	return {c for c in re.findall(r"\w+", comun.fara_semne(text)) if len(c) >= MINIM_CUVANT}


def se_raspunde_singura(e):
	"""Răspunsul e scris în întrebare? Două reguli, fiindcă una nu ajunge.

	1. CONȚINERE, în ambele direcții: Kuweit → Kuweit, Mexic → Ciudad de México,
	   Tunisia → Tunis. Amândouă direcțiile fiindcă amândouă sunt cadouri — la
	   „Care este capitala Kuweitului?" răspunsul e în întrebare; la „Tunis este
	   capitala cărei țări?" la fel, doar pe dos. Care nume îl conține pe care nu
	   schimbă nimic pentru jucătorul care recunoaște rădăcina.

	2. UN CUVÂNT ÎNTREG ÎMPĂRȚIT. Regula a doua a venit din mostre, nu din plan:
	   „San Salvador este capitala cărei țări?" cu răspunsul „El Salvador" printre
	   Honduras, Nicaragua și Haiti. Niciunul nu-l conține pe celălalt, deci prima
	   regulă o rata — dar cuvântul „Salvador" e chiar răspunsul, scris în
	   întrebare.

	   Măsurată pe tabelul întreg, regula a doua prinde EXACT un caz nou (El
	   Salvador) și niciun fals pozitiv. Iar prima rămâne necesară: Mexic ↔ Ciudad
	   de México, Tunisia ↔ Tunis și Algeria ↔ Alger nu împart niciun cuvânt
	   întreg. Cele două se completează; niciuna nu o înlocuiește pe cealaltă.

	Totul fără diacritice și fără majuscule.

	CE NU PRINDE, dinadins: Brazilia → Brasília, unde nici nu se conțin, nici nu
	împart un cuvânt, deși ochiul îl vede pe loc. Pentru alea există lista „de
	citit cu ochiul" din `aproape_se_raspund`, care nu oprește nimic — și care e
	tocmai locul din care a ieșit regula a doua. O listă de citit care schimbă o
	regulă și-a plătit locul.
	"""
	tara = comun.fara_semne(e["tara"])
	cap = comun.fara_semne(e["capitala"])
	if tara in cap or cap in tara:
		return True
	return bool(cuvinte_mari(e["tara"]) & cuvinte_mari(e["capitala"]))


def aproape_se_raspund(lista, sarite):
	"""Perechile care SEAMĂNĂ, fără să se conțină. Nu opresc nimic."""
	sarite_qid = {e["qid"] for e in sarite}
	return ["%-26s %-22s (%s)" % (e["tara"], e["capitala"], e["qid"])
	        for e in lista
	        if e["qid"] not in sarite_qid and comun.seamana(e["tara"], e["capitala"])]


# ─────────────────────────────────────────────────────────────
# CÂT DE DEPARTE AJUNG DISTRACTORII
# ─────────────────────────────────────────────────────────────

# Peste atât, distractorul e „de pe altă lume" și merită numărat.
PRAG_DEPARTE_KM = 5000


def kilometri(a, b):
	"""Distanța pe sferă între două puncte `(lat, long)`, în km."""
	la1, lo1 = math.radians(a[0]), math.radians(a[1])
	la2, lo2 = math.radians(b[0]), math.radians(b[1])
	h = (math.sin((la2 - la1) / 2) ** 2
	     + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2)
	return 6371.0 * 2 * math.asin(math.sqrt(h))


def distractori_departe(intrebari, lista):
	"""Întrebările la care cel mai îndepărtat distractor e peste `PRAG_DEPARTE_KM`.

	SE NUMĂRĂ, NU SE REPARĂ — și merită spus de ce, fiindcă e a treia oară că
	fabrica ajunge aici și de fiecare dată răspunsul a fost altul.

	Măsurat pe cele 253 de întrebări, 15 (6%) au un distractor la peste 5000 km.
	Punctajul dă +100 pentru „același continent", și asta e prea gros pentru Asia:
	Libanul, Coreea de Nord și India sunt toate trei „Asia", deci „Care este
	capitala Libanului? Damasc / Beirut / Pyongyang / New Delhi" trece punctajul
	fără să clipească. O bandă de distanță ar repara-o, și ar fi ieftin.

	N-o repar pentru că MĂSURĂTOAREA arată că nu e în principal o problemă de
	punctaj. Cele trei cele mai rele sunt Australia și Noua Zeelandă: în tabel sunt
	singurele două țări din Oceania, deci pentru ele NU EXISTĂ un distractor
	apropiat, oricât de fin ar fi punctajul. E exact forma lecției de la opere, unde
	11 întrebări din 188 n-aveau niciun distractor de aceeași limbă fiindcă autorul
	era singur pe limba lui în `autori.json`: leacul e un rând în plus în tabel, nu
	cod.

	Deci cifra stă în raport, sub ochi, ca `fara_frate_de_limba`. Dacă după o
	revizuire a tabelului rămâne tot pe la 6% și restul nu mai e Oceania, ATUNCI
	banda de distanță merită scrisă — dar cu o măsurătoare care s-o ceară, nu cu o
	presimțire.

	CE NU VEDE MĂSURĂTOAREA, ca să nu fie citită ca mai tare decât e: distanța se
	ia între CENTRELE ȚĂRILOR (`P625`), nu între capitale. La țările întinse cele
	două nu sunt același lucru — centrul Rusiei e în Siberia, deci „Care este
	capitala Rusiei? Beijing / Tokyo / Moscova / Kiev" NU apare în lista de mai
	jos, deși Moscova e la 5800 km de Beijing. Se poate repara cerând `P625` și de
	la capitală; n-am făcut-o fiindcă e o măsurătoare, nu o gardă, și fiindcă
	rafinarea unei măsurători înainte ca ea să fi cerut o decizie e exact felul de
	lucru care umflă un script.
	"""
	pe_nume = {e["tara"]: e for e in lista}
	pe_capitala = {e["capitala"]: e for e in lista}
	pe_qid = {e["qid"]: e for e in lista}
	departe = []
	for q in intrebari:
		intrebata = pe_qid.get(q["id"].split(":")[1])
		if intrebata is None or intrebata["unde"] is None:
			continue
		cel_mai, la_cat = None, 0.0
		for i, v in enumerate(q["variante"]):
			if i == q["corect"]:
				continue
			e = pe_capitala.get(v) or pe_nume.get(v)
			if e is None or e["unde"] is None:
				continue
			d = kilometri(intrebata["unde"], e["unde"])
			if d > la_cat:
				cel_mai, la_cat = v, d
		if la_cat > PRAG_DEPARTE_KM:
			departe.append((la_cat, q, cel_mai))
	departe.sort(key=lambda x: -x[0])
	return departe


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

def verifica_dublurile(lista, intrebari_mana):
	"""Caută în fișierul scris de mână întrebări care spun deja ce vrem să generăm.

	Se caută DOAR prin întrebările care conțin cuvântul „capital", ca la elemente
	cu „simbol": restul nu pot fi dubluri ale relației asta. „Care este cel mai
	mare oraș al României?" are tot Bucureștiul ca răspuns, dar e o RELAȚIE ALTA
	— altfel jumătate din geografie ar părea dublură.

	Regula se uită la RĂSPUNS, nu doar la text, ca la opere:

	  - dublură de sens direct — răspunsul de mână e o capitală aleasă, iar în
	    text apare numele sau genitivul țării ei;
	  - dublură de sens invers — răspunsul de mână e o țară aleasă, iar în text
	    apare numele unei capitale alese.

	Potrivirea e pe cuvânt întreg și fără majuscule, în amândouă direcțiile. Fără
	majuscule fiindcă „Micul Prinț" și „Micul prinț" au fost aceeași carte la
	opere, iar cu potrivire sensibilă dublura ar fi trecut; pe cuvânt întreg
	fiindcă „Mali" s-ar găsi în „Somalia".
	"""
	pe_capitala = {comun.fara_semne(e["capitala"]): e for e in lista}
	pe_tara = {comun.fara_semne(e["tara"]): e for e in lista}
	gasite = {}
	aproape = []

	for q in intrebari_mana:
		text = str(q.get("text", ""))
		if "capital" not in comun.fara_semne(text):
			continue
		variante = q.get("variante", [])
		indice = int(q.get("corect", -1))
		if not (0 <= indice < len(variante)):
			continue
		corect = comun.fara_semne(str(variante[indice]))
		id_ = str(q.get("id", "?"))

		if corect in pe_capitala:
			# Răspunsul e o capitală aleasă → e o dublură a sensului DIRECT dacă
			# întrebarea numește țara ei (la nominativ sau la genitiv).
			e = pe_capitala[corect]
			if comun.cuvant_in(text, e["tara"]) or comun.cuvant_in(text, e["genitiv"]):
				gasite[(e["qid"], "cere_capitala")] = id_
			else:
				aproape.append("%s  răspuns „%s\" e o capitală aleasă, dar întrebarea "
				               "nu numește %s" % (id_, variante[indice], e["tara"]))
		if corect in pe_tara:
			# Răspunsul e o țară aleasă → dublură a sensului INVERS dacă întrebarea
			# numește capitala.
			e = pe_tara[corect]
			if comun.cuvant_in(text, e["capitala"]):
				gasite[(e["qid"], "cere_tara")] = id_
			else:
				aproape.append("%s  răspuns „%s\" e o țară aleasă, dar întrebarea nu "
				               "numește %s" % (id_, variante[indice], e["capitala"]))

	comun.compara_dublurile(gasite, DUBLURI)
	return gasite, aproape


# ─────────────────────────────────────────────────────────────
# DISTRACTORII
# ─────────────────────────────────────────────────────────────

def punctaj(tinta, candidat):
	"""Cât de plauzibil e `candidat` ca distractor la întrebarea despre `tinta`.

	Regula pornește de la cerință: la „capitala Franței", alte capitale europene,
	și mai bine ale vecinilor, nu Ulan Bator.

	  +100  același continent (`P30`)
	  +40   vecin de graniță cu țara întrebată (`P47`)
	  +10/5 același nivel / nivel vecin

	Continentul întâi, vecinătatea după: „o altă capitală europeană" e confuzia
	firească, iar „capitala unui vecin" o ascute. Amândouă contează, dar nu la fel.

	DE CE O SINGURĂ FUNCȚIE PENTRU AMBELE SENSURI, spre deosebire de elemente,
	unde punctajul depindea de sens. Fiindcă aici opțiunile sunt mereu de același
	fel ca entitatea întrebată — capitale lângă capitale, țări lângă țări — iar
	toate însușirile pe care le punctăm (continent, vecinătate, nivel) stau pe
	PERECHE, nu pe una din cele două fețe. La elemente, punctajul se uita la prima
	literă a simbolului sau a numelui, deci fața conta.
	"""
	p = 0
	if tinta["continente"] & candidat["continente"]:
		p += 100
	if candidat["qid"] in tinta["vecini"] or tinta["qid"] in candidat["vecini"]:
		p += 40
	p += 10 if candidat["nivel"] == tinta["nivel"] else 5
	return p


def alege_distractorii(tinta, candidati, sens):
	"""Cei trei distractori, deterministic.

	DOUĂ PLASE, și amândouă merită spuse.

	1. BANDA DE NIVEL (±1), pe OPȚIUNI. Trei nume obscure lângă unul celebru se
	   recunosc fără să știi nimic. Aici nivelul stă pe pereche, deci banda e
	   aceeași în ambele sensuri — la opere a fost nevoie de o lecție ca să se afle
	   că banda se măsoară pe opțiuni, nu pe întrebare, fiindcă acolo opera și
	   autorul ei puteau avea niveluri diferite.

	2. NICIO CAPITALĂ A ȚĂRII ÎNTREBATE, pe QID-ul capitalei, nu pe numele ei
	   afișat. Diferența contează exact când o țară are mai multe capitale actuale:
	   a doua n-ar fi un distractor nefericit, ar fi UN AL DOILEA RĂSPUNS CORECT.
	   Filtrul stă aici, la alegere, nu doar în verificarea de la sfârșit — o plasă
	   care doar constată e mai puțin bună decât una care previne, iar
	   `comun.verifica_un_singur_raspuns` rămâne oricum dedesubt.

	   MĂSURAT, GARDA ASTA PORNEȘTE DE 0 ORI din 16256 de perechi de candidați. Și
	   totuși rămâne, spre deosebire de garda de limbă de la opere, care a fost
	   ȘTEARSĂ tot după ce s-a măsurat că pornește de 0 ori. Diferența e ce apără:
	   aceea era o euristică de calitate (un distractor mai puțin potrivit), asta e
	   o gardă de CORECTITUDINE (o întrebare cu două răspunsuri bune). Motivul
	   pentru care nu pornește azi e că niciuna dintre cele 8 țări cu mai multe
	   capitale actuale nu e în tabel; în clipa în care pui `capitala_qid` pe
	   Bolivia sau pe Africa de Sud, începe să conteze. O gardă care costă o
	   intersecție de mulțimi și previne un răspuns greșit nu are nevoie să
	   pornească des ca să merite.
	"""
	posibili = [c for c in candidati
	            if c["qid"] != tinta["qid"]
	            and not (c["capitale_wd"] & tinta["capitale_wd"])
	            and c["capitala_qid"] not in tinta["capitale_wd"]]
	banda = [c for c in posibili if abs(c["nivel"] - tinta["nivel"]) <= 1]
	if len(banda) < 3:
		banda = posibili
	if len(banda) < 3:
		raise Eroare("%s / %s: mai puțin de 3 distractori posibili" % (tinta["tara"], sens))

	banda.sort(key=lambda c: (-punctaj(tinta, c), comun.zar(tinta["qid"], sens, c["qid"])))
	return banda[:3]


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ÎNTREBĂRILOR
# ─────────────────────────────────────────────────────────────

def construieste(lista):
	"""Lista de țări alese → (întrebări, fapte, statistici).

	AMBELE SENSURI SUNT PER ȚARĂ, fiindcă relația e unu-la-unu după filtrare. La
	opere sensul invers a trebuit să fie per autor: acolo un autor cu cinci opere
	alese ar fi dat cinci întrebări cu exact același text. Aici problema nu poate
	apărea, și tocmai de-aia filtrul de capitală actuală e ce face relația să fie
	unu-la-unu în primul rând.
	"""
	intrebari = []
	sarite = [e for e in lista if se_raspunde_singura(e)]
	de_intrebat = [e for e in lista if e not in sarite]

	for e in de_intrebat:
		for sens in SENSURI:
			if (e["qid"], sens) in DUBLURI:
				continue
			distractorii = alege_distractorii(e, de_intrebat, sens)
			if sens == "cere_capitala":
				text = "Care este capitala %s?" % e["genitiv"]
				bun = e["capitala"]
				restul = [d["capitala"] for d in distractorii]
			else:
				text = "%s este capitala cărei țări?" % e["capitala"]
				bun = e["tara"]
				restul = [d["tara"] for d in distractorii]

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
				eticheta=e["tara"],
			))

	intrebari.sort(key=lambda q: (q["nivel"], q["id"]))

	# ── VERIFICAREA „EXACT UNA DIN PATRU E CORECTĂ" ──
	# Forma e în modulul comun; ce înseamnă „corect" e al geografiei. Se întreabă
	# mulțimea COMPLETĂ de capitale actuale de la Wikidata (`capitale_wd`), nu
	# coloana `capitala`: dacă mâine cineva adaugă în Wikidata o a doua capitală
	# actuală la o țară aleasă, se vede la prima `--reincarca`, nu într-o partidă.
	pe_capitala = {e["capitala"]: e for e in lista}
	pe_tara = {e["tara"]: e for e in lista}

	def este_corect(q, varianta):
		qid_tara = q["id"].split(":")[1]
		intrebata = next(e for e in lista if e["qid"] == qid_tara)
		if q["id"].endswith("cere_capitala"):
			# Varianta e un nume de capitală. E una dintre capitalele actuale ale
			# țării întrebate?
			gasit = pe_capitala.get(varianta)
			return gasit is not None and gasit["capitala_qid"] in intrebata["capitale_wd"]
		# Varianta e un nume de țară. Are ea capitala arătată în întrebare?
		gasit = pe_tara.get(varianta)
		return gasit is not None and intrebata["capitala_qid"] in gasit["capitale_wd"]

	comun.verifica_un_singur_raspuns(intrebari, este_corect)

	# ── FAPTELE ──
	# UNUL PE ȚARĂ, folosit de amândouă sensurile: relația e unu-la-unu, deci e
	# chiar același fapt („capitala Franței e Parisul"). La opere erau două feluri
	# de fapte fiindcă entitățile celor două sensuri erau două, opera și autorul.
	#
	# Nota e goală: tabelul cere întrebări, nu note. Câmpul EXISTĂ fiindcă altfel
	# încărcătorul din `trivia.gd` se plânge pentru fiecare întrebare care arată
	# spre un fapt inexistent, iar de la al 180-lea avertisment consola nu mai e un
	# loc unde se citește ceva.
	#
	# `cod_iso` NU SE FOLOSEȘTE AZI. E cheia pentru hărțile desenate din date de la
	# pasul 13 („Află mai multe"), iar motivul pentru care se pune ACUM e că altfel
	# ar însemna, peste trei luni, o rulare `--reincarca` pe tot tabelul ca să
	# recuperez un câmp care era deja sub mână. `_incarca_fapte` din `trivia.gd`
	# cere doar `id` și `nota`, deci un câmp în plus nu strică nimic azi.
	folosite = {q["fapt"] for q in intrebari}
	fapte = [{
		"id": "wd:%s" % e["qid"],
		"nota": "",
		"surse": ["https://www.wikidata.org/wiki/%s" % e["qid"]],
		"verificat": False,
		"cod_iso": e["iso"],
	} for e in lista if "wd:%s" % e["qid"] in folosite]

	return intrebari, fapte, {"sarite": sarite}


# ─────────────────────────────────────────────────────────────

def main():
	arg = comun.argumentele()

	print("\n══ FABRICA: ȚARĂ ↔ CAPITALĂ ══\n")

	pachet = ia_datele(arg.reincarca)
	tari, istorice = desfa_tarile(pachet)
	capitale = desfa_capitalele(pachet)
	print("  Țări de azi, membre ONU: %d  (plus %d state istorice, scoase)"
	      % (len(tari), len(istorice)))

	alese = comun.citeste_lista(CALE_TARI, "țările alese") if os.path.exists(CALE_TARI) else []

	if arg.propune:
		propune(tari, capitale, {str(r.get("qid", "")) for r in alese})
		print("\n══ DOAR PROPUS. Nimic scris în data/. ══\n")
		return 0

	lista_toata = leaga_tabelul(alese, tari, capitale)

	if arg.masoara:
		masoara(tari, capitale, istorice, lista_toata)
		print("\n══ DOAR MĂSURAT. Nimic scris. ══\n")
		return 0

	# Ciornele se scot ÎNAINTE de construire, nu la sfârșit: distractorii se aleg
	# dintre țările alese, deci o ciornă lăsată în listă ar ajunge distractor
	# într-o întrebare scrisă în `data/`.
	ciorne = [e for e in lista_toata if e["ciorna"]]
	lista = [e for e in lista_toata if not e["ciorna"]] if arg.scrie else lista_toata
	comun.raporteaza_ciornele(lista_toata, ciorne, len(lista), arg.scrie, "țări")
	arata_numele_de_mana(lista_toata)
	arata_mutarile_recente(lista_toata)

	intrebari_mana = comun.citeste_lista(comun.CALE_MANA, "întrebările scrise de mână")
	# DUBLURILE SE CAUTĂ PE TABELUL ÎNTREG, ciorne incluse. Suprapunerea cu
	# fișierul de mână e o însușire a TABELULUI, nu a ce s-a confirmat azi: o
	# ciornă care dublează o întrebare scrisă de mână trebuie declarată ACUM,
	# altfel ziua în care îi ștergi marcajul e ziua în care apar două întrebări
	# identice, fără ca nimic să fi semnalat.
	dubluri, aproape_dubluri = verifica_dublurile(lista_toata, intrebari_mana)
	print("\n  ── DUBLURI CU FIȘIERUL SCRIS DE MÂNĂ ──")
	print("    declarate și găsite: %d" % len(dubluri))
	for (qid, sens), id_ in sorted(dubluri.items()):
		e = next((x for x in lista_toata if x["qid"] == qid), None)
		print("      %-14s %-24s ← %s" % (sens, e["tara"] if e else qid, id_))
	if aproape_dubluri:
		print("    de citit cu ochiul (nu opresc, dar seamănă a dublură):")
		for r in aproape_dubluri:
			print("      %s" % r)

	if len(lista) < 4:
		print("\n  Mai puțin de patru țări confirmate: nu se pot face nici măcar")
		print("  distractorii unei singure întrebări.")
		intrebari, fapte, statistici = [], [], {"sarite": []}
	else:
		intrebari, fapte, statistici = construieste(lista)

	directe = sum(1 for q in intrebari if q["id"].endswith("cere_capitala"))
	print("\n    generate: %d întrebări (%d directe, %d inverse), %d fapte"
	      % (len(intrebari), directe, len(intrebari) - directe, len(fapte)))
	print("    „exact una din patru e corectă”: verificat pe toate %d, pe mulțimea"
	      % len(intrebari))
	print("      completă de capitale actuale de la Wikidata.")

	sarite = statistici["sarite"]
	print("\n  ── SE RĂSPUND SINGURE, DECI SĂRITE: %d ──" % len(sarite))
	for e in sorted(sarite, key=lambda x: x["tara"]):
		print("    %-26s %-22s" % (e["tara"], e["capitala"]))
	aproape = aproape_se_raspund(lista, sarite)
	if aproape:
		print("    de citit cu ochiul (seamănă, dar nu se conțin — nu se sar):")
		for r in aproape:
			print("      %s" % r)

	# CIFRA DE ȚINUT SUB OCHI, ca `fara_frate_de_limba` la opere. Vezi
	# `distractori_departe` pentru de ce se numără și nu se repară.
	departe = distractori_departe(intrebari, lista)
	print("\n  ── DISTRACTORI DE PE ALTĂ LUME (peste %d km): %d din %d (%.0f%%) ──"
	      % (PRAG_DEPARTE_KM, len(departe), max(1, len(intrebari)),
	         100.0 * len(departe) / max(1, len(intrebari))))
	for d, q, cine in departe:
		print("    %5.0f km  %-46s  [%s]" % (d, q["text"], cine))
	if departe:
		print("    Nu e un bug de reparat în cod: unde lipsește un vecin în tabel (Oceania")
		print("    are două rânduri), niciun punctaj nu poate scoate un distractor apropiat.")

	celelalte_gen = comun.citeste_dosarul_generat(CALE_INTREBARI)
	comun.grila(intrebari_mana, celelalte_gen + intrebari)
	comun.cat_din_lupta(intrebari_mana, celelalte_gen + intrebari, intrebari,
	                    DOMENIU, "„ȚARĂ ↔ CAPITALĂ”")
	if intrebari:
		comun.mostre(intrebari, 15, arg.samanta)

	if not arg.scrie:
		print("\n══ PROBĂ USCATĂ. Rulează cu --scrie ca să scrie fișierele. ══\n")
		return 0

	comun.scrie_lista(CALE_INTREBARI, intrebari,
	                  ["id", "fapt", "text", "variante", "corect", "nivel", "categorie"], "nivel")
	comun.scrie_lista(CALE_FAPTE, fapte,
	                  ["id", "nota", "surse", "verificat", "cod_iso"], "")
	print("\n  Scris:")
	print("    %s" % comun.relativ(CALE_INTREBARI))
	print("    %s" % comun.relativ(CALE_FAPTE))

	comun.verifica_inapoi(CALE_INTREBARI, len(intrebari))
	comun.verifica_inapoi(CALE_FAPTE, len(fapte))
	print("  Citit înapoi: JSON valid, id-uri unice în amândouă.")

	toate = {str(q.get("id", "")) for q in intrebari_mana + celelalte_gen}
	ciocniri = sorted(toate & {q["id"] for q in intrebari})
	if ciocniri:
		raise Eroare("id-uri folosite în două fișiere: %s" % ", ".join(ciocniri))
	print("  Id-uri unice și peste restul conținutului (%d + %d + %d)."
	      % (len(intrebari_mana), len(celelalte_gen), len(intrebari)))

	if ciorne:
		print("\n  ATENȚIE: %d ciorne NU au fost scrise. Sunt în tari.json cu" % len(ciorne))
		print('  "ciorna": true; șterge marcajul de pe rândurile pe care le confirmi.')
		for e in sorted(ciorne, key=lambda x: (x["nivel"], x["tara"]))[:8]:
			print("    nivel %d  %s — %s" % (e["nivel"], e["tara"], e["capitala"]))
		if len(ciorne) > 8:
			print("    … și încă %d" % (len(ciorne) - 8))

	print("\n══ GATA ══\n")
	return 0


if __name__ == "__main__":
	comun.ruleaza(main)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""FABRICA DE ÎNTREBĂRI — lucrare muzicală → compozitor, pentru cultura clasică.

    python tools/fabrica/compozitori.py --propune    propune lucrări pentru
                                                compozitorii din `date/compozitori.json`.
                                                Scrie DOAR `date/lucrari_propuse.json`
    python tools/fabrica/compozitori.py --masoara    doar măsoară: rezolvarea
                                                compozitorilor, tipurile, titlurile
                                                refuzate, epocile. Nu scrie nimic
    python tools/fabrica/compozitori.py              raportul întreg, fără să scrie.
                                                CIORNELE INTRĂ în raport
    python tools/fabrica/compozitori.py --scrie      scrie perechea din data/trivia_gen/,
                                                FĂRĂ ciorne
    python tools/fabrica/compozitori.py --reincarca  reia din rețea și rescrie cache-ul

Produce două fișiere, rescrise ÎNTREGI la fiecare rulare cu `--scrie`:

    data/trivia_gen/compozitori_intrebari.json   întrebările
    data/trivia_gen/compozitori_fapte.json       faptele, cu notă

Fișierul scris de mână (`data/intrebari_trivia.json`) nu se atinge niciodată.

─────────────────────────────────────────────────────────────
AL PATRULEA TABEL. DE CE EXISTĂ

Pentru butonul „Află mai multe". Pe 12 octombrie 2026, 646 din 2692 de întrebări
ajungeau la o notă — iar cele 2046 scrise de mână nu pot ajunge niciodată, fiindcă
n-au niciun tabel în spate și singura lor sursă aș fi eu (vezi `CLAUDE.md`,
„Întrebările fără sursă rămân fără notă"). Drumul spre mai multe note e mai multe
TABELE, fiecare aducând întrebări ȘI note în aceeași rulare. Ăsta e primul de pe
drumul acela, și umple raftul `cultura_clasica`, care avea 75 de întrebări scrise
de mână și zero fabricate.

─────────────────────────────────────────────────────────────
CE E ALTFEL FAȚĂ DE `opere.py`

Relația are exact aceeași formă (mulți-la-unu: o lucrare are un compozitor, un
compozitor are multe lucrări), deci sensul invers e tot o întrebare PER OM, iar
felul lucrării nu se spune niciodată în text. Trei lucruri sunt însă ALTFEL, și
toate trei vin din măsurători făcute înainte de prima linie scrisă:

1. `P86` NU E O RELAȚIE CURATĂ: E PUSĂ ȘI PE FILME. „Compozitor" la Wikidata
   înseamnă și „cine a scris muzica filmului". Măsurat pe 6579 de lucrări ale a 49
   de compozitori, asta scoate la iveală perle ca:

       Bach      → „Hannah și surorile ei", „Sacrificiul"   (filme)
       Gershwin  → „Manhattan"                               (film)
       Grieg     → „M - Un oraș își caută ucigașul"          (film)
       Händel    → „Imnul Ligii Campionilor UEFA"

   „Cine a compus «Manhattan»?" cu răspunsul Gershwin nu e o întrebare de muzică
   clasică, e o greșeală de fapt îmbrăcată în întrebare. Deci aici `P31` se
   folosește ca FILTRU — exact proprietatea pe care `opere.py` a refuzat s-o
   folosească în TEXT, și pentru același motiv: la opere ar fi fost o afirmație în
   plus („roman"), aici e o condiție de intrare. Vezi `TIPURI_*`, și regula care
   le ține cinstite: un tip pe care nu-l cunosc OPREȘTE scriptul.

2. DISTRACTORII SE ALEG PE EPOCĂ, NU PE LIMBĂ SAU PE ȚARĂ. La opere, limba
   autorului era axa (un alt romancier român, nu Shakespeare). Muzica nu are
   limbă, deci primul gând a fost cetățenia, `P27`. Măsurată, nu ține: 25 din 49
   de compozitori au mai multe cetățenii, iar numele lor sunt „Cisleithania",
   „Regatul Saxoniei", „Episcopia Lübeckului", „principatul arhiepiscopal de
   Salzburg". O normalizare a lor ar fi 25 de rânduri de PĂREREA MEA despre ce
   state istorice „sunt de fapt" aceeași țară — adică exact ce `LIMBI_INRUDITE`
   din `opere.py` nu e (acolo se contopesc variante ale ACELEIAȘI limbi, o
   chestiune de fapt).

   Și, din fericire, epoca singură e axa adevărată a muzicii: pentru „Cine a
   compus «Flautul fermecat»?", Haydn, Gluck și Beethoven sunt distractori mult
   mai buni decât „un alt austriac". Toți cei 49 au an de naștere ȘI de moarte în
   Wikidata, deci epoca nu lipsește niciodată — spre deosebire de limbă la opere,
   unde Arghezi și Blaga rămâneau fără.

3. TITLUL POATE SCURGE RĂSPUNSUL, sau poate să nu fie un titlu. Trei refuzuri
   care la opere nu erau necesare, fiecare măsurat pe pool-ul adevărat:

       „Simfonia a V-a de Beethoven"      titlul conține răspunsul (4 cazuri)
       „Simfonia nr. 1"                    îl au Bruckner, Beethoven, Ceaikovski,
                                           Mahler, Șostakovici, Schumann (26 de
                                           lucrări pe 9 titluri)
       „Nocturne, Op. 32 (Chopin)"        paranteza e dezambiguizarea Wikidata, iar
                                           numărul de opus nu e o întrebare (77)

   Din 371 de lucrări care trec filtrul de tip, rămân 264. Tăierea nu e o
   curățenie, e chiar garanția „exact una din patru e corectă".

Un al patrulea lucru, mai mic: ANUL SE VERIFICĂ ÎMPOTRIVA VIEȚII OMULUI. `P571`
pe un item muzical e uneori anul unei prelucrări, nu al compoziției — „Rhapsody
in Blue" iese 1973 (Gershwin a murit în 1937), „Lied der Deutschen" 1841 (Haydn,
mort în 1809), „Imnul Ligii Campionilor" 1992 (Händel, 1759). Un an care nu încape
în viața compozitorului NU intră în notă și se tipărește la fiecare rulare. Fără
verificarea asta, nota ar fi spus, cu seninătate, că Haydn a compus ceva la 32 de
ani după moarte.

─────────────────────────────────────────────────────────────
CIORNELE, TITLUL DE MÂNĂ, STRICTEȚEA

Primele trei sunt exact ca la `opere.py`, și nu se repetă explicațiile aici:
un rând cu `"ciorna": true` intră în raport dar NU în joc; `"titlu_de_mana": true`
ocolește verificarea titlului împotriva etichetei române, dar se tipărește
zgomotos la fiecare rulare; orice lucru pe care scriptul nu-l recunoaște oprește
tot; iar `id`-ul (`wd:Q39212:compozitor:cere_compozitor`) nu-și schimbă niciodată
FORMA, fiindcă aia rupe legătura cu orice save.

A patra e nouă aici, și o cere relația: UN NUME PURTAT DE DOI COMPOZITORI. „Franz
Schubert" sunt doi oameni cu aceeași etichetă română, amândoi cu lucrări, deci
numele nu mai e cheie. Un rând din `compozitori.json` poate fi atunci un obiect,
`{"nume": "Franz Schubert", "qid": "Q7312"}` — vezi `rezolva_compozitorii`.
"""

import os
import re

import comun
from comun import Eroare

comun.consola_pe_utf8()

CALE_CACHE = os.path.join(comun.DOSAR_CACHE, "wikidata_compozitori.json")

CALE_COMPOZITORI = os.path.join(comun.DOSAR_DATE, "compozitori.json")
CALE_LUCRARI = os.path.join(comun.DOSAR_DATE, "lucrari.json")
CALE_PROPUSE = os.path.join(comun.DOSAR_DATE, "lucrari_propuse.json")

CALE_INTREBARI = os.path.join(comun.DOSAR_GEN, "compozitori_intrebari.json")
CALE_FAPTE = os.path.join(comun.DOSAR_GEN, "compozitori_fapte.json")

DOMENIU = "arta_literatura"

# Raftul. Muzica clasică stă la `cultura_clasica` împreună cu filosofia, opera și
# baletul — vezi `docs/plan-continut.md`.
SUBCATEGORIE = "cultura_clasica"

# Relația, din care se compune `id`-ul: `wd:Q39212:compozitor:cere_compozitor`.
RELATIE = "compozitor"

# Cele două sensuri. Numele spune ce se CERE.
#   cere_compozitor — se arată lucrarea, se cer compozitorii. O întrebare PER LUCRARE.
#   cere_lucrare    — se arată compozitorul, se cer lucrările. O întrebare PER OM.
SENSURI = ["cere_compozitor", "cere_lucrare"]

# Câte lucrări propune `--propune` pentru fiecare compozitor.
CATE_PROPUNERI = 20

# Ediții (`wikibase:sitelinks`) sub care o lucrare nici nu se cere de la Wikidata.
# Rămâne 1, din același motiv scris pe larg în `opere.py`: numărul de ediții
# Wikipedia măsoară răspândirea internațională, nu celebritatea în România, deci un
# prag pe el ar șterge exact conținutul care contează cel mai mult. Tăierea
# adevărată o face `CATE_PROPUNERI`, pe fiecare compozitor separat.
MINIM_EDITII = 1

CAMPURI_LUCRARE = {"qid", "titlu", "compozitor_nume", "nivel", "ciorna", "titlu_de_mana"}


# ─────────────────────────────────────────────────────────────
# TIPURILE (P31): CE E O LUCRARE MUZICALĂ ȘI CE NU E
#
# LISTĂ ALBĂ, NU LISTĂ NEAGRĂ — aceeași decizie ca la licențele imaginilor din
# `capitale.py`, și pentru același motiv: o listă neagră apără doar împotriva a ce
# mi-am imaginat deja, iar primul tip la care nu m-am gândit trece în tăcere. Aici
# „trece în tăcere" ar fi însemnat un film printre operele lui Verdi.
#
# De-aia sunt TREI liste, nu două, și regula are trei condiții:
#
#   intră  =  are măcar un tip din MUZICALE  ȘI  n-are niciun tip din RESPINSE
#             ȘI  toate tipurile lui îmi sunt cunoscute
#
# Un tip necunoscut OPREȘTE scriptul când e pe o lucrare ALEASĂ, și e doar raportat
# când e pe una propusă — altfel orice item nou-catalogat din Wikidata ar bloca o
# rulare de propuneri în care oricum nu se scrie nimic.
#
# NEUTRELE sunt a treia listă fiindcă fără ea aș fi greșit în amândouă felurile:
# „operă creativă" și „serie de opere" stau pe Bolero și pe L'estro Armonico
# ALĂTURI de tipul muzical, deci în lista neagră ar fi aruncat lucrări bune; în
# lista albă ar fi primit orice item „creativ", adică orice. Nu spun nimic, deci
# nici nu admit, nici nu resping.
# ─────────────────────────────────────────────────────────────

TIPURI_MUZICALE = {
	"Q105543609": "lucrare sau compoziție muzicală",
	"Q58483083": "lucrare dramatico-muzicală (operă, operetă, musical)",
	"Q114586269": "lucrare lirico-muzicală",
	"Q116476516": "operă dramatică",
	"Q17851193": "ciclu de opere",
	"Q1443637": "tetralogie",
	"Q15079786": "balet",
	"Q58483088": "lucrare coregrafică",
	"Q23691": "imn național",
	"Q484692": "imn",
	"Q21848887": "cântec de Crăciun",
	"Q856713": "imn creștin",
	"Q781815": "patimi (Pasiune)",
	"Q34320210": "Clavier-Übung",
	"Q115473170": "grup de lucrări muzicale",
	"Q17489659": "grup de opere muzicale",

	# ── FORMELE, adăugate după prima rulare a lui `--propune` ──
	# Prima listă a fost scrisă din tipurile celor 461 de lucrări cu etichetă
	# română. `--propune` se uită la tot pool-ul, deci a scos încă vreo 60 de
	# tipuri necunoscute — aproape toate pe lucrări cu titlu doar englez, deci
	# nefolosibile oricum. Măsurate, blocau DOUĂSPREZECE lucrări cu titlu
	# românesc, iar una singură conta: „La traviata" (64 de ediții), ținută afară
	# de „Italian opera". Astea sunt forme sau genuri muzicale — citesc ce spune
	# eticheta Wikidata, nu hotărăsc eu ce „e de fapt" un oratoriu.
	"Q785522": "operă italiană",
	"Q599099": "grand opéra",
	"Q580499": "oratoriu",
	"Q2066623": "patimi (mai multe)",
	"Q41425": "balet (al doilea QID)",
	"Q194172": "nocturnă",
	"Q209534": "scherzo",
	"Q852027": "impromptu",
	"Q873000": "canzonă",
	"Q324617": "tarantella",
	"Q1136846": "sinfonia concertante",
	"Q1352567": "missa brevis",
	"Q1755225": "liturghie solemnă",
	"Q724473": "coral",
	"Q18071186": "serenată",
	"Q647653": "divertimento",
	"Q582093": "antifon",
	"Q406714": "arie (air)",
	"Q5956785": "melodie de imn",
	"Q541947": "imn (al doilea QID)",
	"Q523896": "imn regional",
	"Q131613038": "cântec de masă",
	"Q1063010": "piesă de caracter",
	"Q214981": "temă cu variațiuni",
	"Q24887304": "compoziție instrumentală",
	"Q11487510": "cvartet de coarde",
	"Q7075242": "cvartet cu oboi",
	"Q5126979": "trio clarinet-violă-pian",
	"Q12376778": "trio vocal",
	"Q23687321": "lucrare pentru cor",
	"Q2207959": "masque",
	"Q1907293": "masque (al doilea QID)",
	"Q209741": "muzică programatică",
	"Q30309949": "concert pentru mâna stângă",
	"Q1545707": "foaie de album",
	"Q24949660": "ciclu de cantate corale",
	"Q41064": "psalmi",
	# Grupuri de N lucrări. Wikidata are o clasă pentru fiecare N; toate înseamnă
	# același lucru ca „grup de lucrări muzicale", care e deja mai sus.
	"Q29428373": "grup de patru lucrări",
	"Q93465857": "grup de douăsprezece lucrări",
	"Q93469014": "grup de șaptesprezece lucrări",
}

TIPURI_RESPINSE = {
	# Muzica de film: motivul pentru care tabelul are nevoie de filtru.
	"Q11424": "film",
	"Q506240": "film de televiziune",
	"Q202866": "film de animație",
	"Q24862": "scurtmetraj",
	"Q127402430": "film în două părți",
	"Q112158242": "film Tom and Jerry",
	"Q5398426": "serial de televiziune",
	"Q1259759": "miniserial",
	"Q24992028": "serie muzicală",
	# Nu compoziția, ci o ÎNREGISTRARE sau o EDIȚIE a ei. „Cine a compus albumul
	# X?" e altă întrebare, cu alt răspuns posibil (interpretul).
	"Q482994": "album",
	"Q134556": "single",
	"Q7302866": "pistă audio",
	"Q3331189": "ediție, versiune sau traducere",
	"Q1385610": "fragment",
	# Un item care e pagină de dezambiguizare nu e o lucrare, oricât de muzical ar
	# fi catalogat pe lângă („Minuet in G major").
	"Q4167410": "pagină de dezambiguizare Wikimedia",
	# „Imnul european" e catalogat ca SIMBOL al Uniunii, nu ca lucrare. Oda
	# bucuriei e a lui Beethoven; aranjamentul cântat la ceremonii nu e.
	"Q23774077": "simbolurile Uniunii Europene",
	# O operă LITERARĂ nu intră aici, chiar dacă cineva a pus pe ea un compozitor:
	# raftul ei e `literatura_universala`, și are deja tabelul lui.
	"Q7725634": "operă literară",
	"Q17518870": "grup de opere literare",
	"Q1440453": "fragment literar",
	"Q47461344": "lucrare scrisă",

	# ── RESTUL COZII, din aceeași rulare ──
	# Ce NU e o compoziție, oricât de muzical ar fi contextul. Două dintre ele
	# arată de ce lista albă e lista bună: `P86` l-a legat pe Schubert de un
	# scurtmetraj de animație („Flowers and Trees") și pe Grieg de o emisiune
	# norvegiană de televiziune. Amândouă aveau titlu și ar fi intrat într-o zi
	# în care aș fi clasificat pe fugă.
	"Q17517379": "scurtmetraj de animație",
	"Q20650540": "film anime",
	"Q18011171": "proiect de film neterminat",
	"Q15416": "program de televiziune",
	"Q122914758": "film de televiziune în trei părți",
	# O PRODUCȚIE sau o INTERPRETARE nu e compoziția: „Flautul fermecat, Opera
	# din Noua Zeelandă, 2016" e un spectacol, nu lucrarea lui Mozart.
	"Q47467768": "producție de operă",
	"Q43099500": "producție de arte ale spectacolului",
	"Q1486440": "concert (interpretare)",
	"Q6942562": "interpretare muzicală",
	"Q3764113": "coreografie",
	# Hârtia pe care e scrisă muzica nu e muzica.
	"Q87167": "manuscris",
	"Q11613006": "manuscris muzical",
	"Q187947": "partitură",
	"Q4327689": "partitură tipărită",
	"Q732577": "publicație",
	"Q2668072": "colecție",
	"Q20655472": "colecție editorială",
	"Q1516252": "carte de imnuri",
	"Q2560570": "catalog tematic",
	# Liste, discografii, cataloage: pagini despre lucrări, nu lucrări.
	"Q13406463": "articol-listă Wikimedia",
	"Q100775361": "listă Wikimedia de lucrări muzicale",
	"Q273057": "discografie",
	"Q20671381": "serie de albume",
	"Q7190204": "repertoriu pianistic",
	"Q107487333": "tip de operă sau compoziție (o CLASĂ, nu o lucrare)",
	# Altele, fiecare pe un singur item.
	"Q88392887": "parte dintr-o lucrare",
	"Q170439": "acord (acordul din Tristan)",
	"Q836950": "lucrare derivată",
	"Q1128018": "pastișă",
	"Q838948": "operă de artă",
}

TIPURI_NEUTRE = {
	"Q17537576": "operă creativă",
	"Q7725310": "serie de opere",
	"Q59163902": "producție muzicală",

	# ── CELE CARE NU SPUN NICI DA, NICI BA ──
	# „Parte", „neterminată", „pierdută" sunt stări, nu feluri: Zaide e o operă
	# neterminată a lui Mozart, iar „neterminată" nu e un argument nici să intre,
	# nici să nu intre. Dacă itemul are și un tip muzical, intră; dacă n-are decât
	# starea, rămâne afară, fiindcă n-am de unde să știu ce e.
	"Q929848": "parte (movement)",
	"Q2910675": "lucrare neterminată",
	"Q21752591": "lucrare pierdută",
	"Q21514702": "proiect abandonat",
	"Q170584": "proiect",
	# „CÂNTEC" E ȘI EL NEUTRU, și asta merită scris. Pare cel mai muzical tip
	# posibil, dar `P86` l-a legat pe Chopin de „Lemon Incest" — un cântec din
	# 1984 construit pe un studiu al lui. „Cine a compus «Lemon Incest»?" cu
	# răspunsul Chopin e exact genul de jumătate-de-adevăr pe care tabelul ăsta nu
	# are voie să-l pună pe un buton verde. Un cântec adevărat („Trei culori",
	# „Pe-al nostru steag") are oricum și un tip muzical pe lângă.
	"Q7366": "cântec",
}


def clasifica_tipurile(tipuri):
	"""Tipurile unei lucrări → („muzical" / „respins" / „necunoscut", motivul).

	Ordinea condițiilor e dinadins asta: un tip necunoscut se raportează ÎNAINTEA
	unui refuz, fiindcă e singurul care cere o decizie de la mine. Un refuz e deja
	decis.
	"""
	necunoscute = sorted(t for t in tipuri
	                     if t not in TIPURI_MUZICALE
	                     and t not in TIPURI_RESPINSE
	                     and t not in TIPURI_NEUTRE)
	if necunoscute:
		return "necunoscut", ", ".join(necunoscute)
	respinse = sorted(TIPURI_RESPINSE[t] for t in tipuri if t in TIPURI_RESPINSE)
	if respinse:
		return "respins", ", ".join(respinse)
	muzicale = sorted(TIPURI_MUZICALE[t] for t in tipuri if t in TIPURI_MUZICALE)
	if muzicale:
		return "muzical", ", ".join(muzicale)
	return "respins", "niciun tip care să spună că e muzică"


# ─────────────────────────────────────────────────────────────
# TITLUL: CÂND NU E O ÎNTREBARE
#
# Trei feluri de titlu care nu pot intra, toate măsurate pe pool-ul adevărat
# (vezi antetul fișierului). Refuzul e un MOTIV scris, nu un `False`, fiindcă
# apare în raport și pe el se decide dacă merită un `titlu_de_mana`.
# ─────────────────────────────────────────────────────────────

# Numerotările și numerele de opus. „Nocturne, Op. 32" nu e ceva ce poți recunoaște;
# „Simfonia nr. 1" e ceva ce au scris toți. Cifra din titlu e semnul amândurora.
_NUMEROTAT = re.compile(r"(?i)(\bop\.|\bnr\.|\bno\.|\bbwv\b|\bkv\b|\bwwv\b|\d)")


def de_ce_nu_merge_titlul(titlu, nume_compozitor):
	"""Motivul pentru care titlul nu poate intra, sau None dacă poate."""
	if "(" in titlu or ")" in titlu:
		# Paranteza din eticheta Wikidata e dezambiguizare internă, nu parte din
		# titlu — iar uneori conține chiar răspunsul: „Nocturne (Chopin)",
		# „Summertime (arie de George Gershwin)".
		return "are paranteză (dezambiguizare Wikidata, uneori cu răspunsul în ea)"
	if _NUMEROTAT.search(titlu):
		return "e numerotat (opus, număr de simfonie) — nu e un titlu de recunoscut"
	# SCURGEREA RĂSPUNSULUI. „Simfonia a V-a de Beethoven" pusă pe un buton între
	# patru compozitori nu mai e o întrebare. Se caută pe bucăți de nume mai lungi
	# de trei litere, fără diacritice: „van" și „de" din „Ludwig van Beethoven"
	# n-ar însemna nimic, „Beethoven" înseamnă tot.
	gol = comun.fara_semne(titlu)
	for bucata in re.split(r"[\s,.]+", comun.fara_semne(nume_compozitor)):
		if len(bucata) > 3 and re.search(r"\b%s" % re.escape(bucata), gol):
			return "titlul conține numele compozitorului („%s”) — scurge răspunsul" % bucata
	return None


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
#
# Cheia e (titlu, "cere_compozitor") pentru sensul direct și
# (compozitor, "cere_lucrare") pentru cel invers — adică ENTITATEA întrebării.
# Ce se găsește și nu e declarat aici OPREȘTE scriptul; și invers, o declarație
# care nu mai corespunde nimănui oprește la fel (vezi `comun.compara_dublurile`).
# ─────────────────────────────────────────────────────────────
DUBLURI = {
	# Toate unsprezece vin din ȘASE întrebări scrise de mână, fiindcă fiecare
	# numește câte DOUĂ lucrări: „Ce compozitor italian a scris operele «Rigoletto»
	# și «Aida»?". Aia e o întrebare mai bună decât „Cine a compus «Aida»?" — cere
	# același lucru, dar cu două indicii care se sprijină unul pe altul. Deci cea
	# scrisă de mână rămâne, iar sensul direct generat se sare.
	("Aida", "cere_compozitor"): "mana:1075",
	("Bărbierul din Sevilla", "cere_compozitor"): "mana:1635",
	("Clavecinul bine temperat", "cere_compozitor"): "mana:1111",
	("Frumoasa din pădurea adormită", "cere_compozitor"): "mana:1594",
	("Lacul lebedelor", "cere_compozitor"): "mana:1594",
	("Madama Butterfly", "cere_compozitor"): "mana:1600",
	("Muzica apelor", "cere_compozitor"): "mana:1593",
	("Patimile după Matei", "cere_compozitor"): "mana:1111",
	("Rigoletto", "cere_compozitor"): "mana:1075",
	("Tosca", "cere_compozitor"): "mana:1600",
	("Wilhelm Tell", "cere_compozitor"): "mana:1635",
}

# ─────────────────────────────────────────────────────────────
# DUBLURILE PE CARE `DUBLURI` NU LE POATE ȚINE: ALTĂ LIMBĂ
#
# Mecanismul de mai sus potrivește titlul AFIȘAT cu ce scrie între ghilimele în
# fișierul de mână, deci nu vede o dublură în care aceeași lucrare e numită în
# două limbi. Trei au ieșit la prima rulare, și toate trei din lista „de citit cu
# ochiul" (care tocmai de-aia nu oprește, dar se tipărește):
#
#     mana:0120  „Inelul Nibelungului"                  eu aveam „Inelul Nibelungilor"
#     mana:1641  „Rhapsody in Blue"                     eu aveam „Rapsodia albastră"
#     mana:1630  „Preludiu la după-amiaza unui faun"    eu aveam titlul francez
#
# Nu se pot DECLARA aici: `comun.compara_dublurile` cere ca fiecare declarație să
# fie și GĂSITĂ, altfel e „fantomă" și oprește — pe bună dreptate. Deci leacul e
# în date, nu în cod: cele trei lucrări NU sunt în `lucrari.json`. Întrebarea
# scrisă de mână rămâne singura, iar dacă vreodată o schimb, rândul se poate
# adăuga acolo.
#
# AL PATRULEA CAZ, care s-a încheiat altfel. `mana:1050` („Ce balet al lui
# Ceaikovski se joacă în preajma Crăciunului?") seamănă cu sensul invers, și la
# opere un caz identic — Jules Verne — a fost declarat. Aici declarația a căzut ca
# fantomă, fiindcă fișierul de mână scrie „Ceaikovski", iar numele meu e „Piotr
# Ilici Ceaikovski": potrivirea pe cuvânt întreg nu-l găsește. Și e bine că a
# căzut, fiindcă m-a pus să mă uit mai atent: cele două întrebări au RĂSPUNSURI
# DIFERITE. Cea de mână cere „Spărgătorul de nuci" (indiciul e Crăciunul), cea
# generată cere reprezentanta lui Ceaikovski, „Lacul lebedelor". Nu e o repetiție,
# sunt două întrebări. Rămân amândouă.
# ─────────────────────────────────────────────────────────────


# ─────────────────────────────────────────────────────────────
# INTEROGĂRILE
# ─────────────────────────────────────────────────────────────

def interogare_compozitori(nume, prin_alias):
	"""Numele → oameni. Potrivește eticheta sau, la a doua trecere, aliasul.

	Două treceri, nu un `UNION`, pentru același motiv măsurat la opere: potrivirea
	pe `skos:altLabel` peste zeci de literali deodată întoarce 504, fiindcă un om
	celebru are sute de alias-uri în toate limbile.

	Aliasul e trapa de scăpare pentru transliterări — „Ceaikovski", „Tchaikovsky"
	și „Чайковский" sunt același om, iar care dintre ele e eticheta oficială se
	schimbă de la o lună la alta.

	`P31 wd:Q5` (e om) plus `EXISTS { ?ceva wdt:P86 ?om }` (a compus măcar ceva)
	taie omonimiile: localități, trupe, omonimi fără nicio compoziție.
	"""
	valori = " ".join('"%s"@ro "%s"@en "%s"@mul' % ((n.replace('"', '\\"'),) * 3)
	                  for n in nume)
	potrivirea = ("?om skos:altLabel ?cautat . BIND(\"alias\" AS ?fel)" if prin_alias
	              else "?om rdfs:label ?cautat . BIND(\"etichetă\" AS ?fel)")
	return """
SELECT ?om ?cautat ?fel ?eticheta ?descriere ?nastere ?moarte WHERE {
  VALUES ?cautat { %s }
  %s
  ?om wdt:P31 wd:Q5 .
  FILTER EXISTS { ?ceva wdt:P86 ?om }
  OPTIONAL { ?om rdfs:label ?eticheta . FILTER(lang(?eticheta) IN ("ro", "mul")) }
  OPTIONAL { ?om schema:description ?descriere . FILTER(lang(?descriere) = "ro") }
  OPTIONAL { ?om wdt:P569 ?data_n . BIND(YEAR(?data_n) AS ?nastere) }
  OPTIONAL { ?om wdt:P570 ?data_m . BIND(YEAR(?data_m) AS ?moarte) }
}
""" % (valori, potrivirea)


def interogare_lucrari(qiduri):
	"""Lucrările unui grup de compozitori, cu TOȚI compozitorii fiecăreia.

	`?lucrare wdt:P86 ?x` apare de DOUĂ ori dinadins: o dată legat de omul cerut
	(ca să iasă doar lucrările lui), o dată liber (ca să vină TOȚI compozitorii
	lucrării). A doua e ce face posibilă regula „exact una din patru e corectă":
	fără ea, o lucrare scrisă în doi ar arăta ca scrisă de unul singur.

	`GROUP_CONCAT`, nu rânduri simple: o lucrare are mai mulți compozitori și mai
	multe tipuri, iar cerute simplu SPARQL întoarce produsul lor cartezian. Prima
	măsurătoare, pe 49 de compozitori, a adus 6668 de rânduri pentru 6579 de
	lucrări — cu produsul cartezian ar fi fost de câteva ori mai mult, iar cache-ul
	ăsta se COMITE ÎN GIT.

	`P571` („data începerii"), nu `P577` ca la opere: la o lucrare muzicală data
	publicării e a unei partituri tipărite, deci lipsește aproape peste tot.
	`P571` e anul compunerii — iar cât de mult să-l cred se decide mai jos, la
	`an_in_viata`.

	Se cer doar lucrările cu măcar o etichetă în română, engleză sau `mul`: fără
	filtru vin mii de itemi fără nicio etichetă (manuscrise, înregistrări, intrări
	de catalog) pe care nu le poți nici alege, nici măcar citi.
	"""
	valori = " ".join("wd:%s" % q for q in qiduri)
	return """
SELECT ?lucrare ?titlu_ro ?titlu_mul ?titlu_en ?editii
       (MIN(?an_unul) AS ?an)
       (GROUP_CONCAT(DISTINCT STR(?compozitor); SEPARATOR=" ") AS ?compozitori)
       (GROUP_CONCAT(DISTINCT STR(?tip); SEPARATOR=" ") AS ?tipuri)
WHERE {
  VALUES ?cerut { %s }
  ?lucrare wdt:P86 ?cerut .
  ?lucrare wikibase:sitelinks ?editii .
  FILTER(?editii >= %d)
  FILTER EXISTS { ?lucrare rdfs:label ?oricare . FILTER(lang(?oricare) IN ("ro", "mul", "en")) }
  ?lucrare wdt:P86 ?compozitor .
  OPTIONAL { ?lucrare rdfs:label ?titlu_ro . FILTER(lang(?titlu_ro) = "ro") }
  OPTIONAL { ?lucrare rdfs:label ?titlu_mul . FILTER(lang(?titlu_mul) = "mul") }
  OPTIONAL { ?lucrare rdfs:label ?titlu_en . FILTER(lang(?titlu_en) = "en") }
  OPTIONAL { ?lucrare wdt:P31 ?tip . }
  OPTIONAL { ?lucrare wdt:P571 ?data . BIND(YEAR(?data) AS ?an_unul) }
}
GROUP BY ?lucrare ?titlu_ro ?titlu_mul ?titlu_en ?editii
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
# Comis în Git, ca la celelalte tabele: Wikidata se editează, iar diferența trebuie
# văzută CÂND O CER (`--reincarca`), nu să apară singură într-un diff din `data/`.
# Ține și PENTRU CE a fost luat (lista de nume, pragul), fiindcă altfel adaugi un
# compozitor, uiți `--reincarca`, iar scriptul generează liniștit fără el.
# ─────────────────────────────────────────────────────────────

def ia_datele(reincarca, nume_oameni):
	pachet = None if reincarca else comun.cache_citeste(CALE_CACHE)
	if pachet is not None:
		if int(pachet.get("minim_editii", -1)) != MINIM_EDITII:
			raise Eroare(
				"cache-ul e luat cu pragul de %s ediții, iar acum MINIM_EDITII e %d.\n"
				"  Pragul stă în interogare, deci schimbarea lui cere --reincarca."
				% (pachet.get("minim_editii", "?"), MINIM_EDITII))
		vechi = list(pachet.get("pentru_nume", []))
		if vechi != list(nume_oameni):
			lipsa = [n for n in nume_oameni if n not in vechi]
			scosi = [n for n in vechi if n not in nume_oameni]
			raise Eroare(
				"cache-ul e luat pentru altă listă de compozitori.\n"
				"  în plus în compozitori.json: %s\n"
				"  scoși din compozitori.json: %s\n"
				"  Rulează cu --reincarca."
				% (", ".join(lipsa) or "—", ", ".join(scosi) or "—"))
		return pachet

	print("  Reîncarc din rețea.")
	raspunsuri_oameni = []
	gasite = set()
	for i in range(0, len(nume_oameni), 12):
		grup = nume_oameni[i:i + 12]
		r = comun.interogheaza(interogare_compozitori(grup, False),
		                       "compozitorii, etichete (%d-%d)" % (i + 1, i + len(grup)))
		raspunsuri_oameni.append(r)
		gasite |= {b["cautat"]["value"] for b in comun.legaturi(r)}

	ramase = [n for n in nume_oameni if n not in gasite]
	for i in range(0, len(ramase), 6):
		grup = ramase[i:i + 6]
		raspunsuri_oameni.append(comun.interogheaza(
			interogare_compozitori(grup, True),
			"compozitorii, alias-uri (%s)" % ", ".join(grup)))

	qiduri = sorted({comun.qid_din(r["om"]["value"])
	                 for raspuns in raspunsuri_oameni for r in comun.legaturi(raspuns)})
	if not qiduri:
		raise Eroare("niciun compozitor găsit pentru lista dată. Numele sunt scrise corect?")

	# Pe bucăți de câte cinci. Bach singur are peste o mie de itemi legați prin
	# `P86`; toți 49 deodată trec de cele 60 de secunde ale endpointului, iar un
	# timeout la jumătatea listei e cel mai prost fel de eșec: pare o listă scurtă,
	# nu o eroare.
	bucati = []
	for i in range(0, len(qiduri), 5):
		grup = qiduri[i:i + 5]
		bucati.append(comun.interogheaza(
			interogare_lucrari(grup),
			"lucrările (%d-%d din %d)" % (i + 1, i + len(grup), len(qiduri))))

	de_etichetat = set()
	for b in bucati:
		for r in comun.legaturi(b):
			de_etichetat |= {q for q in comun.multe(r, "tipuri") if q != "?"}
	etichete = []
	lista_et = sorted(de_etichetat)
	for i in range(0, len(lista_et), 300):
		etichete.append(comun.interogheaza(interogare_etichete(lista_et[i:i + 300]),
		                                   "etichetele (%d)" % len(lista_et[i:i + 300])))

	return comun.cache_scrie(CALE_CACHE, {
		"pentru_nume": list(nume_oameni),
		"minim_editii": MINIM_EDITII,
		"oameni": raspunsuri_oameni,
		"lucrari": bucati,
		"etichete": etichete,
	})


# ─────────────────────────────────────────────────────────────
# CITIREA RĂSPUNSURILOR
# ─────────────────────────────────────────────────────────────

def desfa_etichetele(pachet):
	et = {}
	for raspuns in pachet.get("etichete", []):
		for r in comun.legaturi(raspuns):
			q = comun.qid_din(r["x"]["value"])
			et[q] = {
				"ro": r["ro"]["value"] if "ro" in r else None,
				"en": r["en"]["value"] if "en" in r else None,
			}
	return et


def rezolva_compozitorii(pachet, nume_oameni, qid_cerut):
	"""Numele din `compozitori.json` → un om și numai unul. Strict.

	Un nume ambiguu sau negăsit OPREȘTE tot. N-am voie să „aleg cel mai probabil":
	un QID greșit leagă întrebarea de alt om, iar nicio validare n-ar prinde-o —
	omul există, lucrarea există, legătura e doar falsă. („Johann Strauss" e exact
	cazul: tatăl și fiul, amândoi compozitori, amândoi cu valsuri — de-aia în listă
	scrie „Johann Strauss II".)

	`qid_cerut` e trapa pentru cazul în care numele NU POATE fi cheie, oricât de
	corect l-ai scrie. „Franz Schubert" sunt doi oameni cu exact aceeași etichetă
	română: austriacul (Q7312) și un compozitor german din Dresda (Q322989).
	Amândoi au lucrări, deci niciun filtru nu-i desparte, iar numele AFIȘAT în joc
	trebuie să rămână „Franz Schubert".

	Trapa nu e o portiță, din trei motive:
	  - se declară în date, ca obiect (`{"nume": …, "qid": "Q7312"}`), nu se ghicește;
	  - QID-ul trebuie să fie printre candidații GĂSIȚI pentru numele ăla, altfel
	    oprește — deci o greșeală de tipar într-un QID nu trece în tăcere;
	  - toate rândurile așa se tipăresc la fiecare rulare, cu ce s-a lăsat afară
	    (vezi `arata_numele_dezambiguizate`). Aceeași regulă ca la `titlu_de_mana`:
	    un câmp care ocolește o verificare trebuie să fie ZGOMOTOS.
	"""
	pe_nume = {}
	randuri = []
	for raspuns in pachet["oameni"]:
		randuri.extend(comun.legaturi(raspuns))
	for r in randuri:
		cautat = r["cautat"]["value"]
		qid = comun.qid_din(r["om"]["value"])
		a = pe_nume.setdefault(cautat, {}).setdefault(qid, {
			"qid": qid,
			"feluri": set(),
			"eticheta": None,
			"descriere": None,
			"nastere": None,
			"moarte": None,
		})
		a["feluri"].add(r["fel"]["value"])
		if "eticheta" in r:
			a["eticheta"] = r["eticheta"]["value"]
		if "descriere" in r:
			a["descriere"] = r["descriere"]["value"]
		for camp in ("nastere", "moarte"):
			if camp in r:
				a[camp] = int(float(r[camp]["value"]))

	probleme = []
	oameni = []
	for nume in nume_oameni:
		gasiti = pe_nume.get(nume, {})
		if not gasiti:
			probleme.append("%s: niciun om cu numele ăsta care să fi compus ceva" % nume)
			continue
		cerut = qid_cerut.get(nume)
		if cerut:
			if cerut not in gasiti:
				probleme.append(
					"%s: am cerut %s, dar pentru numele ăsta Wikidata dă %s"
					% (nume, cerut, ", ".join(sorted(gasiti)) or "nimic"))
				continue
			a = gasiti[cerut]
			a["lasati_afara"] = sorted(
				"%s (%s)" % (q, g["descriere"] or g["eticheta"] or "fără descriere")
				for q, g in gasiti.items() if q != cerut)
		elif len(gasiti) > 1:
			lista = "; ".join(
				"%s (%s)" % (q, a["descriere"] or a["eticheta"] or "fără descriere")
				for q, a in sorted(gasiti.items()))
			probleme.append(
				"%s: mai mulți candidați — %s\n    Dacă numele e bun și unul dintre ei "
				"e omul pe care-l vreau, scrie-l în compozitori.json ca obiect: "
				"{\"nume\": \"%s\", \"qid\": \"Q…\"}" % (nume, lista, nume))
			continue
		else:
			a = list(gasiti.values())[0]
		a["cautat"] = nume
		# Numele AFIȘAT în joc e cel din `compozitori.json`, nu eticheta de la
		# Wikidata. Felul în care se scrie un nume pe un buton e o decizie de joc,
		# nu un fapt — iar la compozitori contează mai mult decât la scriitori:
		# „Pyotr Ilyich Tchaikovsky" pe un buton românesc ar fi o greșeală.
		a["nume"] = nume
		oameni.append(a)

	if probleme:
		raise Eroare("compozitori pe care nu-i pot rezolva:\n  - " + "\n  - ".join(probleme)
		             + "\n  Scrie numele exact ca la Wikidata, sau scoate-l din listă.")

	pe_qid = {}
	for a in oameni:
		pe_qid.setdefault(a["qid"], []).append(a["nume"])
	ciocniri = {q: n for q, n in pe_qid.items() if len(n) > 1}
	if ciocniri:
		raise Eroare("nume diferite care duc la același om:\n  - " + "\n  - ".join(
			"%s → %s" % (q, ", ".join(n)) for q, n in sorted(ciocniri.items())))

	return oameni


def desfa_lucrarile(pachet):
	"""Rândurile SPARQL → un dicționar QID → lucrare, cu TOȚI compozitorii ei."""
	lucrari = {}
	for raspuns in pachet["lucrari"]:
		for r in comun.legaturi(raspuns):
			qid = comun.qid_din(r["lucrare"]["value"])
			o = lucrari.setdefault(qid, {
				"qid": qid,
				"titlu_ro": None,
				"titlu_mul": None,
				"titlu_en": None,
				"editii": 0,
				"compozitori": set(),
				"tipuri": set(),
				"an": None,
			})
			o["editii"] = max(o["editii"], int(r["editii"]["value"]))
			o["compozitori"] |= comun.multe(r, "compozitori")
			o["tipuri"] |= {t for t in comun.multe(r, "tipuri") if t != "?"}
			for camp in ("titlu_ro", "titlu_mul", "titlu_en"):
				if camp in r and r[camp]["value"].strip():
					o[camp] = r[camp]["value"].strip()
			if "an" in r:
				an = int(float(r["an"]["value"]))
				o["an"] = an if o["an"] is None else min(o["an"], an)

	for o in lucrari.values():
		# Eticheta `mul` e afirmația explicită că numele se scrie la fel în toate
		# limbile, deci și în română — nu o lipsă. Vezi comentariul lung din
		# `opere.py`. La muzică e cazul obișnuit: „Aida", „Tosca", „Carmen".
		if not o["titlu_ro"] and o["titlu_mul"]:
			o["titlu_ro"] = o["titlu_mul"]
		o["fel"], o["fel_motiv"] = clasifica_tipurile(o["tipuri"])
	return lucrari


def titluri_pe_compozitor(lucrari):
	"""titlu (fără majuscule) → mulțimea de compozitori care au o lucrare așa.

	Se face pe TOT pool-ul de la Wikidata, nu doar pe ce am ales, fiindcă întrebarea
	„mai are cineva o «Simfonia nr. 1»?" nu e despre tabelul meu. Numai lucrările
	muzicale intră: un film cu același titlu ca o operă nu face titlul ambiguu, de
	vreme ce filmul nu poate ajunge pe niciun buton.

	ÎN TOATE TREI LIMBILE, nu doar în română, și asta a fost o reparație, nu un
	plan. Prima versiune se uita numai la `titlu_ro`, trecea curată, și scotea
	„Cine a compus «Otello»?" cu răspunsul Verdi — dar Otello e și al lui Rossini
	(1816), iar Rossini e în lista mea, deci poate ajunge pe un buton. Scăpase
	fiindcă itemul lui Rossini n-are etichetă română: ambiguitatea era în date, doar
	nu în limba în care mă uitam.

	Lărgită, prinde OPT din 128 de lucrări alese, toate adevărate: „Clemența lui
	Titus" (Mozart ȘI Gluck), „Romeo și Julieta" (Prokofiev ȘI Ceaikovski),
	„Anotimpurile" (Ceaikovski ȘI Haydn), „Concertul pentru violoncel" (patru
	dintre compozitorii din listă). Fiecare ar fi fost o întrebare cu două
	răspunsuri adevărate.
	"""
	pe_titlu = {}
	for o in lucrari.values():
		if o["fel"] != "muzical":
			continue
		for camp in ("titlu_ro", "titlu_mul", "titlu_en"):
			if o[camp]:
				pe_titlu.setdefault(o[camp].lower(), set()).update(o["compozitori"])
	return pe_titlu


def an_in_viata(an, om):
	"""Anul `P571` încape în viața compozitorului?

	`P571` pe un item muzical e uneori anul unei prelucrări, al unei înregistrări
	sau al unei adoptări oficiale, nu al compunerii. Măsurat pe pool-ul curat:
	trei lucrări din 92 cu an ies în afara vieții omului — „Rhapsody in Blue"
	(1973, Gershwin mort în 1937), „Lied der Deutschen" (1841, Haydn mort în 1809)
	și „Imnul Ligii Campionilor UEFA" (1992, Händel mort în 1759).

	Verificarea nu oprește nimic: lucrarea rămâne, doar ANUL nu intră în notă. Un
	an greșit e singura parte stricată a unui rând bun, iar nota fără el e în
	continuare adevărată. Cele refuzate se tipăresc la fiecare rulare.
	"""
	if an is None:
		return False
	n, m = om.get("nastere"), om.get("moarte")
	if n is None or m is None:
		# Fără amândoi anii nu pot verifica, deci nu cred. „Nu scrie nicăieri că
		# nu încape" nu e „încape" — aceeași regulă ca la câmpurile lipsă din
		# Wikidata, scrisă în `CLAUDE.md`.
		return False
	return n <= an <= m


# ─────────────────────────────────────────────────────────────
# PROPUNERILE
# ─────────────────────────────────────────────────────────────

def propune(oameni, lucrari, etichete, alese_deja):
	"""Scrie `date/lucrari_propuse.json`: ce-ar putea intra, ca omul să aleagă.

	Scriptul NU scrie niciodată în `lucrari.json`. Un script care fuzionează în
	fișierul unde stă judecata omului e un script care într-o zi îi șterge
	judecata.

	Ce se lasă afară se NUMĂRĂ pe motive, fiindcă aici cifrele sunt argumentul
	pentru filtre: dacă „film" ar fi 3 lucrări, filtrul n-ar merita existat.
	"""
	pe_om = {a["qid"]: a for a in oameni}
	propuneri = []
	sarite = {"alese": 0, "mai_multi": 0, "fara_eticheta": 0, "respinse": 0,
	          "necunoscute": 0, "titlu": 0}
	necunoscute = {}
	titluri_refuzate = []

	for o in lucrari.values():
		if o["qid"] in alese_deja:
			sarite["alese"] += 1
			continue
		if len(o["compozitori"]) != 1:
			sarite["mai_multi"] += 1
			continue
		if not o["titlu_ro"] and not o["titlu_en"]:
			sarite["fara_eticheta"] += 1
			continue
		if o["fel"] == "necunoscut":
			sarite["necunoscute"] += 1
			for t in o["fel_motiv"].split(", "):
				necunoscute.setdefault(t, []).append(o["titlu_ro"] or o["titlu_en"])
			continue
		if o["fel"] == "respins":
			sarite["respinse"] += 1
			continue
		om = pe_om.get(list(o["compozitori"])[0])
		if om is None:
			continue
		# Fără etichetă română nu pot judeca titlul; rămâne propus, cu titlul
		# englez, iar dacă îl vreau îi scriu titlul de mână.
		motiv = de_ce_nu_merge_titlul(o["titlu_ro"], om["nume"]) if o["titlu_ro"] else None
		if motiv:
			sarite["titlu"] += 1
			titluri_refuzate.append((o["titlu_ro"], om["nume"], motiv))
			continue
		propuneri.append({
			"qid": o["qid"],
			"titlu": o["titlu_ro"] or "",
			"titlu_en": o["titlu_en"] or "",
			"compozitor_nume": om["nume"],
			"tip": ", ".join(sorted(
				(etichete.get(t, {}).get("ro") or etichete.get(t, {}).get("en") or t)
				for t in o["tipuri"])),
			"an": o["an"] if an_in_viata(o["an"], om) else 0,
			"editii": o["editii"],
			"nivel": 0,
		})

	rang = {a["nume"]: i for i, a in enumerate(oameni)}
	propuneri.sort(key=lambda p: (rang[p["compozitor_nume"]], -p["editii"], p["qid"]))

	taiate = []
	cate = {}
	for p in propuneri:
		cate[p["compozitor_nume"]] = cate.get(p["compozitor_nume"], 0) + 1
		if cate[p["compozitor_nume"]] <= CATE_PROPUNERI:
			taiate.append(p)

	comun.scrie_pe_rand(CALE_PROPUSE, taiate,
	                    ["qid", "titlu", "titlu_en", "compozitor_nume", "tip", "an",
	                     "editii", "nivel"], "compozitor_nume")
	print("\n  ── PROPUNERI ──")
	print("    scris: %s" % comun.relativ(CALE_PROPUSE))
	print("    %d lucrări propuse, %d pe compozitor cel mult" % (len(taiate), CATE_PROPUNERI))
	print("    lăsate afară: %d deja alese, %d cu mai mulți compozitori, %d fără"
	      % (sarite["alese"], sarite["mai_multi"], sarite["fara_eticheta"]))
	print("      etichetă, %d respinse pe tip (film, album, ediție…), %d cu titlu"
	      % (sarite["respinse"], sarite["titlu"]))
	print("      care nu merge, %d cu tip necunoscut" % sarite["necunoscute"])
	if necunoscute:
		print("\n    TIPURI NECUNOSCUTE, de pus într-una din cele trei liste:")
		for t, titluri in sorted(necunoscute.items(), key=lambda x: -len(x[1])):
			nume = (etichete.get(t, {}).get("ro") or etichete.get(t, {}).get("en") or "?")
			print("      %-12s %-34s %d lucrări (ex. %s)"
			      % (t, nume[:33], len(titluri), titluri[0]))
	if titluri_refuzate:
		print("\n    TITLURI REFUZATE (%d), primele 12:" % len(titluri_refuzate))
		for t, n, motiv in titluri_refuzate[:12]:
			print("      %-38s %-22s %s" % (t[:37], n[:21], motiv))
	print("\n    Copiază rândurile pe care le vrei în %s, pune-le nivelul (1/2/3)"
	      % comun.relativ(CALE_LUCRARI))
	print("    și marchează-le \"ciorna\": true cât timp nu sunt confirmate.")
	return taiate


# ─────────────────────────────────────────────────────────────
# MĂSURĂTOAREA
# ─────────────────────────────────────────────────────────────

def masoara(oameni, lucrari, etichete, lista):
	"""Ce se poate afla din date, înainte să se aleagă ceva.

	Rostul e să DOVEDEASCĂ, nu să presupună. Aici a dovedit două lucruri care au
	schimbat tabelul: că `P86` e pusă pe filme, și că `P27` nu poate fi axa
	distractorilor.
	"""
	print("\n  ── COMPOZITORII ──")
	prin_alias = [a for a in oameni if "etichetă" not in a["feluri"]]
	print("    %d rezolvați, %d numai prin alias%s" % (
		len(oameni), len(prin_alias),
		(" (%s)" % ", ".join(a["nume"] for a in prin_alias)) if prin_alias else ""))
	fara_ani = [a["nume"] for a in oameni if not (a["nastere"] and a["moarte"])]
	print("    fără amândoi anii vieții (deci fără epocă): %s"
	      % (", ".join(fara_ani) if fara_ani else "niciunul"))
	fara_descriere = [a["nume"] for a in oameni
	                  if not comun.curata_descrierea(a["descriere"])]
	print("    fără apoziție folosibilă pentru notă: %d%s"
	      % (len(fara_descriere),
	         (" (%s)" % ", ".join(fara_descriere)) if fara_descriere else ""))

	print("\n  ── CE A VENIT DIN WIKIDATA ──")
	print("    %d lucrări legate de cei %d compozitori" % (len(lucrari), len(oameni)))
	cu_ro = sum(1 for o in lucrari.values() if o["titlu_ro"])
	print("    cu etichetă română: %d (%.0f%%) — la muzică e puțin, și e normal:"
	      % (cu_ro, 100.0 * cu_ro / max(1, len(lucrari))))
	print("      „String Quartet No. 14\" n-are de ce să fie tradus")
	cu_an = sum(1 for o in lucrari.values() if o["an"])
	print("    cu an (P571): %d (%.0f%%)" % (cu_an, 100.0 * cu_an / max(1, len(lucrari))))

	print("\n  ── TIPURILE (P31): DE-AIA EXISTĂ FILTRUL ──")
	cate = {}
	for o in lucrari.values():
		if not o["titlu_ro"]:
			continue
		for t in o["tipuri"]:
			cate[t] = cate.get(t, 0) + 1
	for t, n in sorted(cate.items(), key=lambda x: -x[1])[:14]:
		nume = etichete.get(t, {}).get("ro") or etichete.get(t, {}).get("en") or t
		unde = ("MUZICAL" if t in TIPURI_MUZICALE else
		        "RESPINS" if t in TIPURI_RESPINSE else
		        "neutru" if t in TIPURI_NEUTRE else "NECUNOSCUT")
		print("      %4d  %-10s %s" % (n, unde, nume))
	pe_fel = {}
	for o in lucrari.values():
		if o["titlu_ro"] and len(o["compozitori"]) == 1:
			pe_fel[o["fel"]] = pe_fel.get(o["fel"], 0) + 1
	print("    din lucrările cu titlu român și un singur compozitor: %s"
	      % ", ".join("%d %s" % (n, f) for f, n in sorted(pe_fel.items())))

	print("\n  ── TITLURILE REFUZATE ──")
	pe_om = {a["qid"]: a for a in oameni}
	motive = {}
	for o in lucrari.values():
		if o["fel"] != "muzical" or not o["titlu_ro"] or len(o["compozitori"]) != 1:
			continue
		om = pe_om.get(list(o["compozitori"])[0])
		if om is None:
			continue
		motiv = de_ce_nu_merge_titlul(o["titlu_ro"], om["nume"])
		if motiv:
			cheie = motiv.split("(")[0].split("—")[0].strip()
			motive[cheie] = motive.get(cheie, 0) + 1
	for m, n in sorted(motive.items(), key=lambda x: -x[1]):
		print("      %4d  %s" % (n, m))

	print("\n  ── EPOCILE (mijlocul vieții), axa distractorilor ──")
	epoci = sorted((epoca(a), a["nume"]) for a in oameni if epoca(a))
	for an, nume in epoci:
		print("      %4d  %s" % (an, nume))

	if lista:
		print("\n  ── EDIȚIILE FAȚĂ DE NIVELUL PUS DE MÂNĂ ──")
		for nivel in (1, 2, 3):
			v = sorted(e["editii"] for e in lista if e["nivel"] == nivel)
			if not v:
				continue
			print("    nivelul %d (%2d lucrări): min %3d   median %3d   maxim %3d"
			      % (nivel, len(v), v[0], v[len(v) // 2], v[-1]))
		comun.cat_de_bun_ar_fi_un_prag([(e["editii"], e["nivel"]) for e in lista])


# ─────────────────────────────────────────────────────────────
# TABELUL, CONFRUNTAT CU WIKIDATA
# ─────────────────────────────────────────────────────────────

def leaga_tabelul(alese, oameni, lucrari):
	"""`lucrari.json` + datele de la Wikidata → lista de lucru. Strict la fiecare pas.

	Adună TOATE neconcordanțele înainte să se oprească: un script care cade la
	prima nepotrivire te pune să rulezi de 20 de ori ca să repari 20 de rânduri.
	"""
	probleme = []
	pe_nume = {a["nume"]: a for a in oameni}
	pe_titlu_global = titluri_pe_compozitor(lucrari)

	qiduri = [str(r.get("qid", "")) for r in alese]
	duble = sorted({q for q in qiduri if qiduri.count(q) > 1})
	if duble:
		probleme.append("QID-uri repetate în lucrari.json: %s" % ", ".join(duble))

	lista = []
	for i, rand in enumerate(alese):
		unde = "rândul %d din lucrari.json" % (i + 1)
		if not isinstance(rand, dict):
			probleme.append("%s nu e un obiect" % unde)
			continue
		necunoscute = sorted(set(rand) - CAMPURI_LUCRARE)
		if necunoscute:
			probleme.append("%s are câmpuri pe care nu le cunosc: %s"
			                % (unde, ", ".join(necunoscute)))
			continue

		qid = str(rand.get("qid", ""))
		titlu = str(rand.get("titlu", "")).strip()
		nume_om = str(rand.get("compozitor_nume", "")).strip()
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
		if nume_om not in pe_nume:
			probleme.append("%s (%s): compozitorul %r nu e în compozitori.json"
			                % (unde, titlu, nume_om))
			continue
		o = lucrari.get(qid)
		if o is None:
			probleme.append("%s (%s): %s nu e printre lucrările compozitorilor din "
			                "compozitori.json" % (unde, titlu, qid))
			continue

		# TIPUL. Aici oprește, spre deosebire de `--propune`, unde doar raportează:
		# ce intră în joc trebuie să fie o lucrare muzicală după o listă pe care am
		# citit-o, nu după lipsa unei contraziceri.
		if o["fel"] == "necunoscut":
			probleme.append("%s (%s): tip necunoscut (%s). Pune-l în TIPURI_MUZICALE, "
			                "TIPURI_RESPINSE sau TIPURI_NEUTRE"
			                % (unde, titlu, o["fel_motiv"]))
			continue
		if o["fel"] == "respins":
			probleme.append("%s (%s): nu e o lucrare muzicală — %s"
			                % (unde, titlu, o["fel_motiv"]))
			continue

		# EXACT UN COMPOZITOR, pe mulțimea COMPLETĂ de la Wikidata, nu pe coloana
		# mea: dacă mâine cineva adaugă un al doilea compozitor la o lucrare aleasă,
		# se vede aici, la prima `--reincarca`.
		if len(o["compozitori"]) != 1:
			probleme.append("%s (%s): Wikidata îi dă %d compozitori, nu unul — nu intră"
			                % (unde, titlu, len(o["compozitori"])))
			continue
		om = pe_nume[nume_om]
		if list(o["compozitori"])[0] != om["qid"]:
			probleme.append("%s (%s): în tabel scrie %s, Wikidata spune %s"
			                % (unde, titlu, nume_om, list(o["compozitori"])[0]))
			continue

		# TITLUL. Fără marcaj, e o AFIRMAȚIE verificată împotriva etichetei române.
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

		# TITLUL CARE NU POATE FI O ÎNTREBARE. Se verifică pe titlul AFIȘAT (cel din
		# tabel), nu pe eticheta Wikidata: dacă mi-am scris titlul de mână,
		# răspunsul se scurge din ce vede jucătorul, nu din ce scrie în altă parte.
		motiv = de_ce_nu_merge_titlul(titlu, nume_om)
		if motiv:
			probleme.append("%s (%s): %s" % (unde, titlu, motiv))
			continue

		# TITLUL PURTAT DE ALTCINEVA. „Te Deum" îl au Bruckner și Dvořák: cu amândoi
		# pe butoane, întrebarea are două răspunsuri corecte, iar niciuna din
		# opririle de mai sus n-o vede, fiindcă fiecare lucrare în sine e curată.
		# Se întreabă cu TOATE numele lucrării — titlul meu afișat ȘI cele trei
		# etichete Wikidata. „Clemența lui Titus" nu se ciocnește cu nimic în
		# română; „La clemenza di Tito" se ciocnește cu opera lui Gluck.
		ceilalti = set()
		for nume_posibil in (titlu, o["titlu_ro"], o["titlu_mul"], o["titlu_en"]):
			if nume_posibil:
				ceilalti |= pe_titlu_global.get(nume_posibil.lower(), set())
		ceilalti -= {om["qid"]}
		if ceilalti:
			alti_nume = sorted(
				next((a["nume"] for a in oameni if a["qid"] == q), q) for q in ceilalti)
			probleme.append("%s (%s): titlul îl are și %s — nu intră"
			                % (unde, titlu, ", ".join(alti_nume)))
			continue

		an = o["an"] if an_in_viata(o["an"], om) else None
		lista.append({
			"qid": qid,
			"titlu": titlu,
			"titlu_wd": o["titlu_ro"] or o["titlu_en"] or "",
			"titlu_de_mana": de_mana,
			"om": om,
			"nivel": int(nivel),
			"ciorna": ciorna,
			"editii": o["editii"],
			"an": an,
			"an_refuzat": o["an"] if (o["an"] is not None and an is None) else None,
			"compozitori_wd": set(o["compozitori"]),
		})

	# UNICITATEA CELOR DOUĂ FEȚE, ca la opere: două lucrări alese cu același titlu
	# afișat ar da, la sensul invers, două butoane identice.
	titluri = [e["titlu"] for e in lista]
	duble = sorted({t for t in titluri if titluri.count(t) > 1})
	if duble:
		probleme.append("titluri afișate identice: %s" % ", ".join(duble))

	if probleme:
		raise Eroare("lucrari.json nu se potrivește cu Wikidata:\n  - "
		             + "\n  - ".join(probleme))

	lista.sort(key=lambda e: (e["nivel"], e["om"]["nume"], e["an"] or 9999, e["titlu"]))
	return lista


def arata_titlurile_de_mana(lista):
	"""Un câmp care ocolește o verificare trebuie să fie ZGOMOTOS."""
	de_mana = [e for e in lista if e["titlu_de_mana"]]
	if not de_mana:
		return
	print("\n  ── TITLURI PUSE DE MÂNĂ (%d) ──" % len(de_mana))
	for e in de_mana:
		print("    %-42s  Wikidata: %s"
		      % (e["titlu"], e["titlu_wd"] or "— (fără etichetă)"))


def arata_numele_dezambiguizate(oameni):
	"""Numele care au fost legate la un QID scris de mână, cu ce s-a lăsat afară.

	Se tipărește la fiecare rulare, ca `titlu_de_mana`: un rând care ocolește
	verificarea „numele duce la un singur om" trebuie văzut, nu presupus. Dacă
	vreodată omonimul e cel pe care-l voiam, aici se vede.
	"""
	cu_qid = [a for a in oameni if a.get("lasati_afara") is not None]
	if not cu_qid:
		return
	print("\n  ── NUME DEZAMBIGUIZATE DE MÂNĂ (%d) ──" % len(cu_qid))
	for a in cu_qid:
		print("    %-28s → %s" % (a["nume"], a["qid"]))
		for alt in a["lasati_afara"]:
			print("      lăsat afară: %s" % alt)


def arata_anii_refuzati(lista):
	"""Anii `P571` care nu încap în viața compozitorului.

	NU e o oprire, e o listă de citit: fiecare e un rând bun cu un an stricat, iar
	nota lui iese fără an. Se tipărește la fiecare rulare fiindcă o verificare
	tăcută care aruncă date devine, în trei luni, o mirare („de ce n-are an?").
	"""
	refuzati = [e for e in lista if e["an_refuzat"]]
	if not refuzati:
		return
	print("\n  ── ANI CARE NU ÎNCAP ÎN VIAȚA COMPOZITORULUI (%d) ──" % len(refuzati))
	for e in refuzati:
		om = e["om"]
		print("    %-36s %-22s P571=%s, a trăit %s–%s"
		      % (e["titlu"][:35], om["nume"][:21], e["an_refuzat"],
		         om["nastere"], om["moarte"]))
	print("    Anul nu intră în notă; lucrarea rămâne.")


# ─────────────────────────────────────────────────────────────
# DUBLURILE CU FIȘIERUL SCRIS DE MÂNĂ
# ─────────────────────────────────────────────────────────────

GHILIMELE = ("„", "”")


def verifica_dublurile(lista, intrebari_mana):
	"""Caută în fișierul scris de mână întrebări care spun deja ce vrem să generăm.

	Aceeași regulă ca la opere, fiindcă relația are aceeași formă — se uită la
	RĂSPUNS, nu doar la text:

	  dublură de sens direct  — răspunsul corect e numele unui compozitor ales,
	                            iar în text apare, între ghilimele, titlul unei
	                            lucrări alese;
	  dublură de sens invers  — răspunsul corect e titlul unei lucrări alese,
	                            iar în text apare numele unui compozitor ales.

	Titlurile se caută ÎNTRE GHILIMELE, nu ca text liber: „Aida" ca text liber s-ar
	găsi în jumătate din propoziții.
	"""
	titluri = {e["titlu"].lower(): e for e in lista}
	oameni = {e["om"]["nume"].lower(): e["om"] for e in lista}

	gasite = {}
	aproape = []
	for q in intrebari_mana:
		text = str(q.get("text", ""))
		variante = q.get("variante", [])
		try:
			corect = str(variante[int(q.get("corect", -1))])
		except (IndexError, ValueError, TypeError):
			continue

		citate = re.findall("%s([^%s]*)%s" % (GHILIMELE[0], GHILIMELE[1], GHILIMELE[1]),
		                    text)

		if corect.lower() in oameni:
			potrivite = [c for c in citate if c.lower() in titluri]
			for c in potrivite:
				gasite[(titluri[c.lower()]["titlu"], "cere_compozitor")] = \
					str(q.get("id", "?"))
			if citate and not potrivite:
				aproape.append("%s  răspuns „%s\", citează %s — nicio lucrare aleasă"
				               % (q.get("id", "?"), corect,
				                  ", ".join("„%s”" % c for c in citate)))
		if corect.lower() in titluri:
			numiti = [oameni[n]["nume"] for n in oameni
			          if re.search(r"\b%s\b" % re.escape(n), text.lower())]
			for n in numiti:
				gasite[(n, "cere_lucrare")] = str(q.get("id", "?"))
			if not numiti:
				aproape.append("%s  răspuns „%s\" e o lucrare aleasă, dar nu numește "
				               "niciun compozitor ales" % (q.get("id", "?"), corect))

	comun.compara_dublurile(gasite, DUBLURI)
	return gasite, aproape


# ─────────────────────────────────────────────────────────────
# DISTRACTORII
# ─────────────────────────────────────────────────────────────

def epoca(om):
	"""Anul în jurul căruia a compus: mijlocul vieții.

	La opere, epoca era a doua axă după limbă, și se calcula cu trei rezerve
	(mijlocul vieții, altfel medianul publicărilor, altfel naștere+40). Aici e
	SINGURA axă, dar nu are nevoie de rezerve: toți cei 49 de compozitori măsurați
	au an de naștere ȘI de moarte în Wikidata. Rezerva rămâne scrisă ca formă,
	pentru ziua în care intră cineva fără ani — dar atunci omul nu primește bonus,
	nu primește o epocă inventată.
	"""
	if om.get("nastere") and om.get("moarte"):
		return (om["nastere"] + om["moarte"]) // 2
	if om.get("nastere"):
		return om["nastere"] + 40
	return None


def punctaj(tinta, candidat):
	"""Cât de plauzibil e `candidat` ca distractor la întrebarea despre `tinta`.

	  +100 / +60 / +30 / +12   la cel mult 30 / 60 / 120 / 250 de ani distanță
	  +10 / +5                 același nivel / nivel vecin

	Treptele sunt mai strânse decât la opere (acolo prima era 50 de ani, aici 30),
	fiindcă muzica își schimbă epoca mai repede decât literatura: între Bach și
	Mozart sunt 70 de ani și două lumi, iar un baroc pus lângă trei clasici se
	recunoaște fără să știi nimic.

	Treapta largă de la capăt (250) nu spune „sunt din aceeași epocă" — RUPE
	EGALITĂȚILE CU SENS, ca la opere: fără ea, al treilea distractor ar fi ales de
	`zar` dintr-o duzină de oameni cu punctaj identic, iar Gershwin ar ajunge
	lângă Vivaldi.
	"""
	p = 0
	if tinta["an_reper"] is not None and candidat["an_reper"] is not None:
		distanta = abs(tinta["an_reper"] - candidat["an_reper"])
		for prag, puncte in ((30, 100), (60, 60), (120, 30), (250, 12)):
			if distanta <= prag:
				p += puncte
				break
	p += 10 if candidat["nivel"] == tinta["nivel"] else 5
	return p


def alege_distractorii(tinta, candidati, sens, cheie_zar):
	"""Cei trei distractori, deterministic.

	BANDA DE NIVEL e aceeași plasă ca la celelalte tabele: toate patru opțiunile
	stau în aceeași bandă (±1), fiindcă trei nume obscure lângă unul celebru se
	recunosc fără să știi nimic.

	Nu există aici garda de limbă din `opere.py` (nici măcar ștearsă): epoca nu e o
	însușire pe care un jucător o poate citi de pe buton. „Trei nume de altă epocă"
	nu e o scurtătură, fiindcă ar trebui să știi deja anii ca s-o vezi — iar dacă
	i-ai știut, ai știut și răspunsul. Ce se NUMĂRĂ, în schimb, e distanța în ani
	până la cel mai apropiat distractor: dacă iese mare, leacul e un compozitor în
	plus în `compozitori.json`, nu cod.
	"""
	banda = [c for c in candidati if abs(c["nivel"] - tinta["nivel"]) <= 1]
	if len(banda) < 3:
		banda = list(candidati)
	if len(banda) < 3:
		raise Eroare("%s / %s: mai puțin de 3 distractori posibili"
		             % (tinta["cheie"], sens))

	banda.sort(key=lambda c: (-punctaj(tinta, c), comun.zar(cheie_zar, sens, c["cheie"])))
	alesi = banda[:3]
	depart = None
	if tinta["an_reper"] is not None:
		distante = [abs(tinta["an_reper"] - c["an_reper"]) for c in alesi
		            if c["an_reper"] is not None]
		depart = min(distante) if distante else None
	return alesi, depart


# ─────────────────────────────────────────────────────────────
# NOTELE („AFLĂ MAI MULTE")
#
# Două șabloane, fiindcă sunt două feluri de fapte: lucrarea (pentru sensul direct)
# și compozitorul (pentru cel invers). Al doilea e `comun.nota_omului`, același
# folosit de autori — un om e un om. Primul e aici, fiindcă e vocea tabelului.
#
# NICIUN PASIV CU TITLUL CA SUBIECT, din același motiv ca la opere: „«Aida» a fost
# compusă de…" cere acordul participiului cu genul gramatical al titlului, care nu
# se poate deduce din nimic ce am în tabel. „Compozitorul «Aida» este…" merge la
# orice titlu. A doua propoziție are subiectul „Lucrarea", cuvântul MEU, mereu
# feminin singular — deci „a fost compusă" e în siguranță acolo.
# ─────────────────────────────────────────────────────────────

def nota_lucrarii(e):
	"""O lucrare → (nota, valorile din care e făcută). Sensul direct."""
	om = e["om"]
	nume = om["nume"]
	surse = [e["titlu"], nume]

	ani, valori = comun.anii_vietii(om)
	surse += valori
	cine = "%s (%s)" % (nume, ani) if ani else nume

	nota = "Compozitorul „%s” este %s." % (e["titlu"], cine)
	if e["an"]:
		nota += " Lucrarea a fost compusă în %d." % e["an"]
		surse.append(e["an"])
	return nota, surse


# ─────────────────────────────────────────────────────────────
# CONSTRUIREA ÎNTREBĂRILOR
# ─────────────────────────────────────────────────────────────

def construieste(lista, oameni):
	"""Lista de lucrări alese → (întrebări, fapte, statistici).

	Sensul invers e PER COMPOZITOR, nu per lucrare: relația e mulți-la-unu, deci
	„Care dintre aceste lucrări a fost compusă de Verdi?" generată per lucrare ar
	da, pentru cele 27 de lucrări alese ale lui, 27 de întrebări cu EXACT același
	text și 27 de răspunsuri corecte diferite. Sacul nu te apără: pentru el sunt
	`id`-uri diferite. Vezi aceeași socoteală, pe larg, în `opere.py`.
	"""
	intrebari = []
	statistici = {"distante": []}

	pe_om = {}
	for e in lista:
		pe_om.setdefault(e["om"]["qid"], []).append(e)

	for e in lista:
		e["an_reper"] = e["an"]
		e["cheie"] = e["qid"]

	candidati_oameni = []
	for a in oameni:
		ale_lui = pe_om.get(a["qid"], [])
		if not ale_lui:
			continue
		candidati_oameni.append({
			"qid": a["qid"],
			"cheie": a["qid"],
			"nume": a["nume"],
			# Cele trei de mai jos nu intră în alegerea distractorilor — intră în
			# NOTĂ (`comun.nota_omului`). Lecția e a operelor: acolo, candidatul
			# purta doar ce trebuia ca să fie ALES, iar toate cele 40 de note de
			# autor ieșeau goale, în tăcere.
			"nastere": a["nastere"],
			"moarte": a["moarte"],
			"descriere": a["descriere"],
			"an_reper": epoca(a),
			# Nivelul unui compozitor = cel mai mic nivel al lucrărilor lui alese.
			# Dacă una dintre ele e cunoscută de oricine, omul e cunoscut de oricine.
			"nivel": min(o["nivel"] for o in ale_lui),
			"lucrari": ale_lui,
		})
	pe_qid_om = {c["qid"]: c for c in candidati_oameni}

	# ── SENSUL DIRECT: o întrebare per lucrare ──
	for e in lista:
		if (e["titlu"], "cere_compozitor") in DUBLURI:
			continue
		om_tinta = pe_qid_om[e["om"]["qid"]]
		ceilalti = [c for c in candidati_oameni if c["qid"] != om_tinta["qid"]]
		tinta = {
			# Reperul e anul lucrării când se știe, altfel epoca omului. O lucrare
			# de tinerețe și una de bătrânețe cer distractori diferiți.
			"an_reper": e["an"] if e["an"] is not None else om_tinta["an_reper"],
			# NIVELUL BENZII E AL OMULUI, NU AL LUCRĂRII, fiindcă butoanele arată
			# COMPOZITORI. Lecția e a operelor, unde nivelul operei scotea din bandă
			# singurul alt rus posibil și-l înlocuia cu doi români.
			"nivel": om_tinta["nivel"],
			"cheie": e["qid"],
		}
		distractorii, depart = alege_distractorii(
			tinta, ceilalti, "cere_compozitor", e["qid"])
		if depart is not None:
			statistici["distante"].append(depart)

		intrebari.append(comun.pune_la_locul_lui(
			cheie=e["qid"],
			relatie=RELATIE,
			sens="cere_compozitor",
			text="Cine a compus „%s”?" % e["titlu"],
			bun=om_tinta["nume"],
			restul=[d["nume"] for d in distractorii],
			nivel=e["nivel"],
			fapt="wd:%s" % e["qid"],
			domeniu=DOMENIU,
			subcategorie=SUBCATEGORIE,
		))

	# ── SENSUL INVERS: o întrebare per compozitor ──
	for a in candidati_oameni:
		if (a["nume"], "cere_lucrare") in DUBLURI:
			continue
		# Reprezentanta: lucrarea cea mai recognoscibilă — nivelul cel mai mic, la
		# egalitate cea cu mai multe ediții Wikipedia. Întrebarea inversă întreabă
		# „recunoști o lucrare a omului ăstuia?", deci merită pusă pe cea pe care ar
		# recunoaște-o.
		reprezentanta = sorted(
			a["lucrari"], key=lambda o: (o["nivel"], -o["editii"], comun.zar(o["qid"])))[0]
		# TOATE lucrările lui ies din distractori, nu doar reprezentanta: altfel
		# întrebarea ar avea două răspunsuri corecte.
		ale_lui = {o["qid"] for o in a["lucrari"]}
		ceilalti = [o for o in lista if o["qid"] not in ale_lui]
		tinta = {
			"an_reper": reprezentanta["an"] if reprezentanta["an"] is not None
			else a["an_reper"],
			"nivel": reprezentanta["nivel"],
			"cheie": a["qid"],
		}
		distractorii, depart = alege_distractorii(tinta, ceilalti, "cere_lucrare", a["qid"])
		if depart is not None:
			statistici["distante"].append(depart)

		intrebari.append(comun.pune_la_locul_lui(
			cheie=a["qid"],
			relatie=RELATIE,
			sens="cere_lucrare",
			text="Care dintre aceste lucrări a fost compusă de %s?" % a["nume"],
			bun=reprezentanta["titlu"],
			restul=[d["titlu"] for d in distractorii],
			nivel=reprezentanta["nivel"],
			fapt="wd:%s" % a["qid"],
			domeniu=DOMENIU,
			subcategorie=SUBCATEGORIE,
		))

	intrebari.sort(key=lambda q: (q["nivel"], q["id"]))

	# ── VERIFICAREA „EXACT UNA DIN PATRU E CORECTĂ" ──
	# Pe mulțimea COMPLETĂ de compozitori de la Wikidata (`compozitori_wd`), nu pe
	# coloana mea: așa se vede, la prima `--reincarca`, dacă cineva a adăugat un al
	# doilea compozitor la o lucrare aleasă.
	pe_titlu = {e["titlu"]: e for e in lista}
	pe_nume = {a["nume"]: a for a in candidati_oameni}

	def este_corect(q, varianta):
		if q["id"].endswith("cere_compozitor"):
			qid_lucrare = q["id"].split(":")[1]
			lucrare = next(e for e in lista if e["qid"] == qid_lucrare)
			return (varianta in pe_nume
			        and pe_nume[varianta]["qid"] in lucrare["compozitori_wd"])
		qid_om = q["id"].split(":")[1]
		return varianta in pe_titlu and qid_om in pe_titlu[varianta]["compozitori_wd"]

	comun.verifica_un_singur_raspuns(intrebari, este_corect)

	# ── FAPTELE, CU NOTĂ ──
	folosite = {q["fapt"] for q in intrebari}
	probleme = []
	fapte = []

	def adauga(qid, nota, surse, unde):
		if nota:
			comun.verifica_nota(nota, surse, unde, probleme)
		fapte.append({"id": "wd:%s" % qid, "nota": nota})

	for e in lista:
		if "wd:%s" % e["qid"] in folosite:
			nota, surse = nota_lucrarii(e)
			adauga(e["qid"], nota, surse, "wd:%s („%s”)" % (e["qid"], e["titlu"]))
	for a in candidati_oameni:
		if "wd:%s" % a["qid"] in folosite:
			nota, surse = comun.nota_omului(a["nume"], a)
			adauga(a["qid"], nota, surse, "wd:%s (%s)" % (a["qid"], a["nume"]))

	statistici["note_probleme"] = probleme
	return intrebari, fapte, statistici


# ─────────────────────────────────────────────────────────────

def main():
	arg = comun.argumentele()
	comun.verifica_subcategoria(DOMENIU, SUBCATEGORIE)

	print("\n══ FABRICA: LUCRARE MUZICALĂ → COMPOZITOR ══\n")

	# UN RÂND POATE FI UN NUME SAU UN OBIECT. Obiectul e numai pentru numele care nu
	# pot fi cheie (vezi `rezolva_compozitorii`), și QID-ul din el nu intră nici în
	# interogare, nici în cache: acolo merge tot lista de NUME, fiindcă interogarea
	# caută etichete. QID-ul doar alege dintre răspunsuri.
	randuri = comun.citeste_lista(CALE_COMPOZITORI, "lista de compozitori")
	nume_oameni = []
	qid_cerut = {}
	for r in randuri:
		if isinstance(r, str) and r.strip():
			nume_oameni.append(r)
			continue
		if isinstance(r, dict) and sorted(r) == ["nume", "qid"]:
			nume = str(r["nume"]).strip()
			qid = str(r["qid"]).strip()
			if nume and re.fullmatch(r"Q\d+", qid):
				nume_oameni.append(nume)
				qid_cerut[nume] = qid
				continue
		raise Eroare("compozitori.json: un rând e un nume, sau {\"nume\": …, \"qid\": "
		             "\"Q…\"} pentru un nume purtat de doi compozitori. Am găsit %r" % r)
	if len(set(nume_oameni)) != len(nume_oameni):
		duble = sorted({n for n in nume_oameni if nume_oameni.count(n) > 1})
		raise Eroare("nume repetate în compozitori.json: %s" % ", ".join(duble))

	pachet = ia_datele(arg.reincarca, nume_oameni)
	oameni = rezolva_compozitorii(pachet, nume_oameni, qid_cerut)
	lucrari = desfa_lucrarile(pachet)
	etichete = desfa_etichetele(pachet)
	print("  Compozitori: %d din %d nume, fiecare cu un singur om."
	      % (len(oameni), len(nume_oameni)))
	arata_numele_dezambiguizate(oameni)

	alese = (comun.citeste_lista(CALE_LUCRARI, "lucrările alese")
	         if os.path.exists(CALE_LUCRARI) else [])

	if arg.propune:
		propune(oameni, lucrari, etichete, {str(r.get("qid", "")) for r in alese})
		print("\n══ DOAR PROPUS. Nimic scris în data/. ══\n")
		return 0

	lista_toata = leaga_tabelul(alese, oameni, lucrari)

	if arg.masoara:
		masoara(oameni, lucrari, etichete, lista_toata)
		print("\n══ DOAR MĂSURAT. Nimic scris. ══\n")
		return 0

	# Ciornele se scot ÎNAINTE de construire, nu la sfârșit: distractorii se aleg
	# dintre lucrările alese, deci o ciornă lăsată în listă ar ajunge distractor
	# într-o întrebare scrisă în `data/`.
	ciorne = [e for e in lista_toata if e["ciorna"]]
	lista = [e for e in lista_toata if not e["ciorna"]] if arg.scrie else lista_toata

	comun.raporteaza_ciornele(lista_toata, ciorne, len(lista), arg.scrie, "lucrări")
	arata_titlurile_de_mana(lista_toata)
	arata_anii_refuzati(lista_toata)

	intrebari_mana = comun.citeste_lista(comun.CALE_MANA, "întrebările scrise de mână")
	# Dublurile se caută pe TABELUL ÎNTREG, ciorne incluse: suprapunerea cu fișierul
	# de mână e o însușire a TABELULUI, nu a ce s-a confirmat azi.
	dubluri, aproape = verifica_dublurile(lista_toata, intrebari_mana)
	print("\n  ── DUBLURI CU FIȘIERUL SCRIS DE MÂNĂ ──")
	print("    declarate și găsite: %d" % len(dubluri))
	for (cheie, sens), id_ in sorted(dubluri.items()):
		print("      %-18s %-40s ← %s" % (sens, cheie, id_))
	if aproape:
		print("    de citit cu ochiul (nu opresc, dar seamănă a dublură):")
		for r in aproape:
			print("      %s" % r)

	if len(lista) < 4:
		print("\n  Mai puțin de patru lucrări confirmate: nu se pot face nici măcar")
		print("  distractorii unei singure întrebări.")
		intrebari, fapte, statistici = [], [], {"distante": []}
	else:
		intrebari, fapte, statistici = construieste(lista, oameni)

	directe = sum(1 for q in intrebari if q["id"].endswith("cere_compozitor"))
	inverse = len(intrebari) - directe
	print("\n    generate: %d întrebări (%d directe, %d inverse), %d fapte"
	      % (len(intrebari), directe, inverse, len(fapte)))
	comun.raporteaza_notele(fapte, statistici.get("note_probleme", []), arg.scrie)
	print("    „exact una din patru e corectă\": verificat pe toate %d, pe mulțimea"
	      % len(intrebari))
	print("      completă de compozitori de la Wikidata.")
	if statistici["distante"]:
		d = sorted(statistici["distante"])
		print("    distanța în ani până la cel mai apropiat distractor: median %d,"
		      % d[len(d) // 2])
		print("      cea mai mare %d. Peste ~120 de ani, leacul e un compozitor în"
		      % d[-1])
		print("      plus în compozitori.json, nu cod.")

	celelalte_gen = comun.citeste_dosarul_generat(CALE_INTREBARI)
	comun.grila(intrebari_mana, celelalte_gen + intrebari)
	comun.cat_din_lupta(intrebari_mana, celelalte_gen + intrebari, intrebari,
	                    DOMENIU, "„LUCRARE ↔ COMPOZITOR”")
	if intrebari:
		comun.mostre(intrebari, 15, arg.samanta)

	if not arg.scrie:
		print("\n══ PROBĂ USCATĂ. Rulează cu --scrie ca să scrie fișierele. ══\n")
		return 0

	comun.scrie_lista(CALE_INTREBARI, intrebari, comun.ORDINEA_INTREBARII, "nivel")
	comun.scrie_lista(CALE_FAPTE, fapte, comun.ORDINEA_FAPTULUI, "")
	print("\n  Scris:")
	print("    %s" % comun.relativ(CALE_INTREBARI))
	print("    %s" % comun.relativ(CALE_FAPTE))

	comun.verifica_inapoi(CALE_INTREBARI, len(intrebari))
	comun.verifica_inapoi(CALE_FAPTE, len(fapte))
	print("  Citit înapoi: JSON valid, id-uri unice în amândouă.")

	toate = [str(q.get("id", "")) for q in intrebari_mana + celelalte_gen]
	ciocniri = sorted(set(toate) & {q["id"] for q in intrebari})
	if ciocniri:
		raise Eroare("id-uri folosite și în alt fișier: %s" % ", ".join(ciocniri))
	print("  Id-uri unice și peste restul conținutului (%d + %d + %d)."
	      % (len(intrebari_mana), len(celelalte_gen), len(intrebari)))

	texte = [str(q.get("text", "")) for q in intrebari_mana + celelalte_gen]
	ciocniri_text = sorted(set(texte) & {q["text"] for q in intrebari})
	if ciocniri_text:
		raise Eroare("texte care apar și în alt fișier:\n  - "
		             + "\n  - ".join(ciocniri_text))
	print("  Texte unice peste tot conținutul.")

	if ciorne:
		print("\n  ATENȚIE: %d ciorne NU au fost scrise. Sunt în lucrari.json cu"
		      % len(ciorne))
		print("  \"ciorna\": true; șterge marcajul de pe rândurile pe care le confirmi.")
		for e in sorted(ciorne, key=lambda x: (x["nivel"], x["titlu"]))[:8]:
			print("    nivel %d  %s — %s" % (e["nivel"], e["titlu"], e["om"]["nume"]))
		if len(ciorne) > 8:
			print("    … și încă %d" % (len(ciorne) - 8))

	print("\n══ GATA ══\n")
	return 0


if __name__ == "__main__":
	comun.ruleaza(main)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MOTORUL TABELELOR SIMPLE — ce au în comun `filme.py`, `albume.py`, `fotbal.py`,
`olimpiade.py` și `formula1.py`.

Nu e un tabel și nu se rulează singur. E jumătatea de jos a celor cinci: un tabel
spune CE întreabă (rândurile, textul, răspunsul bun, din ce se aleg distractorii,
nota); motorul face tot ce e la fel peste tot:

    distractorii    cei mai APROPIAȚI de răspunsul bun (ca an, ca epocă), cu zarul
                    lui `comun.zar` la egalitate — nu primii din listă
    un singur bun   pe mulțimea COMPLETĂ de răspunsuri corecte de la Wikidata
    răspunsul       nu are voie să apară în textul întrebării
    dublurile       cu fișierul scris de mână ȘI cu celelalte tabele, declarate
                    în cod (`DUBLURI`), cu aceleași două opriri ca peste tot
    unicitatea      `id`-uri, texte și fapte unice în tot conținutul jocului
    notele          compuse din șabloane, trecute prin `comun.verifica_nota`
    raportul        grila, cât din luptă, mostrele — din `comun`
    scrierea        perechea din `data/trivia_gen/`, citită înapoi

DE CE UN AL DOILEA MODUL, ȘI NU `comun.py`. `comun.py` ține bucățile; asta ține
o ORDINE de pași. Cele patru tabele vechi și-au scris fiecare ordinea lor, cu
motive scrise lângă fiecare pas, și n-au de ce să se mute aici. Cele cinci noi au
aceeași formă — „un rând dă o întrebare, răspunsul e o etichetă, distractorii sunt
vecinii lui” —, iar cinci copii ale aceleiași ordini ar fi fost cinci locuri în
care o lecție învățată o dată se poate pierde.

Vezi sesiunea DIVERTISMENT ȘI SPORT DIN FABRICĂ din `docs/progres.md`.
"""

import io
import json
import os

import comun
from comun import Eroare


# ─────────────────────────────────────────────────────────────
# REȚEAUA, PRIN CACHE
# ─────────────────────────────────────────────────────────────

def _simplu(rand):
	"""Un rând SPARQL → {variabilă: text}. URI-urile de entitate devin QID-uri.

	Simplificat ÎNAINTE de cache, nu după: cache-ul e comis în Git, iar un diff în
	care fiecare valoare e un dicționar cu `type` și `xml:lang` nu se citește.
	"""
	iesire = {}
	for cheie, valoare in rand.items():
		text = valoare.get("value", "")
		if valoare.get("type") == "uri" and "/entity/Q" in text:
			text = comun.qid_din(text)
		iesire[cheie] = text
	return iesire


def aduce(cale, interogari, reia):
	"""Rezultatele interogărilor, din cache sau din rețea.

	`interogari` e un dicționar nume → text SPARQL. Textul intră în cache, și un
	cache făcut cu ALTE interogări oprește scriptul: altfel aș schimba o
	interogare, aș uita `--reincarca`, și raportul ar arăta date vechi sub un cod
	nou — o rulare care pare să fi verificat ceva ce n-a verificat.
	"""
	pachet = None if reia else comun.cache_citeste(cale)
	if pachet is not None:
		if pachet.get("interogari") != interogari:
			raise Eroare("cache-ul %s a fost făcut cu alte interogări decât cele din "
			             "cod. Rulează cu --reincarca." % comun.relativ(cale))
		return pachet["randuri"]

	randuri = {}
	for nume, text in interogari.items():
		randuri[nume] = [_simplu(r) for r in comun.legaturi(comun.interogheaza(text, nume))]
		print("      %s: %d rânduri" % (nume, len(randuri[nume])))
	comun.cache_scrie(cale, {"interogari": interogari, "randuri": randuri})
	return randuri


def eticheta(rand, prefix):
	"""Eticheta română, sau cea engleză dacă nu e una română. Și de unde a venit.

	Engleza NU e o traducere de-a mea: e eticheta pe care editorii au dat-o, și la
	nume de oameni, de formații și de albume e aproape mereu chiar numele (Max
	Verstappen n-are etichetă română, iar „Abbey Road” nu se traduce).

	A treia limbă, `mul`, e eticheta „pentru toate limbile” pe care Wikidata o
	folosește tot mai des la nume proprii — și singura pe care o are echipa Red
	Bull Racing (măsurat la F1: fără ea, scriptul se oprea pe sezonul 2013).
	"""
	for limba in ("ro", "en", "mul"):
		valoare = rand.get(prefix + "_" + limba, "").strip()
		if valoare:
			return valoare, limba
	return "", ""


def citeste_randurile(cale, campuri, ce):
	"""Lista scrisă de mână, cu câmpurile verificate. Un câmp necunoscut oprește."""
	lista = comun.citeste_lista(cale, ce)
	probleme = []
	vazute = set()
	for i, rand in enumerate(lista):
		unde = "%s, rândul %d" % (os.path.basename(cale), i + 1)
		if not comun.verifica_campurile(rand, campuri, unde, probleme):
			continue
		if rand.get("qid") in vazute:
			probleme.append("%s: %s apare de două ori" % (unde, rand.get("qid")))
		vazute.add(rand.get("qid"))
		if rand.get("nivel") not in comun.NIVELURI:
			probleme.append("%s: nivel %r (se cere 1, 2 sau 3)" % (unde, rand.get("nivel")))
	if probleme:
		raise Eroare("%s:\n  - %s" % (comun.relativ(cale), "\n  - ".join(probleme)))
	return lista


def verifica_numele(lista, gasite, ce):
	"""Numele scris de mână lângă QID e chiar eticheta de la Wikidata?

	Numele din lista mea NU ajunge pe ecran — acolo ajunge eticheta. E acolo ca
	lista să se poată citi, și ca să prindă un QID tastat greșit: Q47703 e
	„Nașul”, iar Q47704 e cu totul altceva. Fără verificarea asta, o cifră
	greșită ar fi pus în joc un film pe care nu l-am ales niciodată.
	"""
	gresite = []
	for rand in lista:
		vazut = gasite.get(rand["qid"])
		if vazut is None:
			gresite.append("%s (%s): Wikidata nu-l are, sau nu e un %s"
			               % (rand["qid"], rand["nume"], ce))
		elif comun.fara_semne(vazut) != comun.fara_semne(rand["nume"]):
			gresite.append("%s: în listă scrie „%s”, la Wikidata „%s”"
			               % (rand["qid"], rand["nume"], vazut))
	if gresite:
		raise Eroare("nume care nu se potrivesc cu Wikidata:\n  - " + "\n  - ".join(gresite))


# ─────────────────────────────────────────────────────────────
# TABELUL
# ─────────────────────────────────────────────────────────────

class Tabel(object):
	"""Întrebările și faptele unui tabel, strânse pe măsură ce se construiesc."""

	def __init__(self, nume, domeniu, subcategorie, relatie, eticheta_raport):
		comun.verifica_subcategoria(domeniu, subcategorie)
		self.nume = nume
		self.domeniu = domeniu
		self.subcategorie = subcategorie
		self.relatie = relatie
		self.eticheta_raport = eticheta_raport
		self.cale_intrebari = os.path.join(comun.DOSAR_GEN, nume + "_intrebari.json")
		self.cale_fapte = os.path.join(comun.DOSAR_GEN, nume + "_fapte.json")
		self.intrebari = []
		self.fapte = {}
		self.corecte = {}
		self.atinge = {}
		self.probleme_note = []
		self.refuzate = []
		self._texte = None

	# ── O ÎNTREBARE ──

	def intrebare(self, cheie, sens, text, bun, corecte, candidati, nivel, fapt, subiecte):
		"""Adaugă o întrebare.

		`corecte`   — TOATE răspunsurile bune după Wikidata (de obicei unul). Niciunul
		              nu are voie să ajungă distractor.
		`candidati` — perechi (valoare, depărtare). Se iau cele trei mai apropiate;
		              la egalitate decide zarul, nu ordinea listei (vezi `comun.zar`
		              pentru de ce ordinea e o scurtătură pentru jucător).
		`subiecte`  — cuvintele care NUMESC întrebarea (un an, un titlu, un nume).
		              Împreună cu răspunsul, spun dacă o întrebare de mână întreabă
		              același lucru.

		Întoarce `None` dacă nu se găsesc trei distractori — rândul se refuză și se
		tipărește, nu se scrie o întrebare cu doar două variante.
		"""
		interzise = {comun.fara_semne(c) for c in corecte} | {comun.fara_semne(bun)}
		vazute = set()
		ordonati = []
		for valoare, departare in candidati:
			semn = comun.fara_semne(valoare)
			if not valoare or semn in interzise or semn in vazute:
				continue
			vazute.add(semn)
			ordonati.append((departare, comun.zar(cheie, sens, valoare), valoare))
		ordonati.sort()
		if len(ordonati) < 3:
			self.refuzate.append("%s / %s: doar %d distractori" % (cheie, sens, len(ordonati)))
			return None

		q = comun.pune_la_locul_lui(cheie, self.relatie, sens, text, bun,
		                            [o[2] for o in ordonati[:3]], nivel, fapt,
		                            self.domeniu, self.subcategorie)
		self.intrebari.append(q)
		self.corecte[q["id"]] = {comun.fara_semne(c) for c in corecte} | {comun.fara_semne(bun)}
		self.atinge[q["id"]] = ([s for s in subiecte if s], bun)
		return q

	def ar_atinge(self, subiecte, bun):
		"""Ar atinge o întrebare existentă? Aceeași regulă ca `_scoate_dublurile`.

		Pentru tabelele care au de ALES răspunsul bun (anul unui campion cu șapte
		titluri): dintre variantele la fel de bune, se ia una pe care nicio
		întrebare de mână n-o întreabă deja. Așa o dublură se OCOLEȘTE la
		construire, în loc să scoată întrebarea întreagă la sfârșit.
		"""
		if self._texte is None:
			self._texte = self._texte_existente()
		b = comun.fara_semne(bun)
		for _, text in self._texte:
			if comun.cuvant_in(text, b) and any(
					comun.cuvant_in(text, comun.fara_semne(s)) for s in subiecte if s):
				return True
		return False

	def _texte_existente(self):
		"""Textul și răspunsul bun al fiecărei întrebări din afara tabelului."""
		celelalte = (comun.citeste_lista(comun.CALE_MANA, "întrebările scrise de mână")
		             + comun.citeste_dosarul_generat(self.cale_intrebari))
		texte = []
		for q in celelalte:
			bun = q["variante"][q["corect"]] if q.get("variante") else ""
			texte.append((str(q["id"]), comun.fara_semne(q["text"] + " | " + bun)))
		return texte

	# ── UN FAPT ──

	def fapt(self, id_fapt, nota, surse):
		"""Adaugă nota unui fapt, trecută prin validatorul din `comun`.

		Un fapt cerut de două ori trebuie să aibă aceeași notă: altfel două
		întrebări ar duce la același „Află mai multe” cu texte diferite.
		"""
		if id_fapt in self.fapte:
			if self.fapte[id_fapt] != nota:
				raise Eroare("faptul %s are două note diferite" % id_fapt)
			return
		comun.verifica_nota(nota, surse, id_fapt, self.probleme_note)
		self.fapte[id_fapt] = nota

	# ── ÎNCHEIEREA ──

	def incheie(self, arg, dubluri, nu_sunt_dubluri=None):
		"""Toate verificările, raportul și, cu `--scrie`, scrierea.

		`dubluri` e `DUBLURI` din scriptul tabelului: `id` generat → `id`-ul
		întrebării de mână (sau din alt tabel) care întreabă același lucru. Se
		SCOT din joc.

		`nu_sunt_dubluri` (`NU_SUNT_DUBLURI`) are aceeași formă și ține potrivirile
		pe care le-am citit și NU sunt aceeași întrebare: „Ce țară a câștigat
		Campionatul European din 2004?” → Grecia atinge „În ce an a găzduit Grecia
		din nou Jocurile Olimpice?” → 2004, dar nu întreabă nimic din ea. Se PĂSTREAZĂ,
		iar declarația lor e păzită la fel: dacă potrivirea dispare, oprește.
		"""
		comun.verifica_un_singur_raspuns(
			self.intrebari, lambda q, v: comun.fara_semne(v) in self.corecte[q["id"]])
		self._raspunsul_nu_e_in_text()

		mana = comun.citeste_lista(comun.CALE_MANA, "întrebările scrise de mână")
		altele = comun.citeste_dosarul_generat(self.cale_intrebari)
		self._scoate_dublurile(mana + altele, dubluri, nu_sunt_dubluri or {})
		self._unice(mana + altele)

		fapte = [{"id": f, "nota": self.fapte[f]} for f in self._fapte_folosite()]
		self._fapte_unice(fapte)

		self._raport(arg, mana, altele, fapte)
		if not arg.scrie:
			print("\n  Probă uscată: nu s-a scris nimic. Cu --scrie se scriu cele două fișiere.")
			return 0

		comun.scrie_lista(self.cale_intrebari, self.intrebari, comun.ORDINEA_INTREBARII, "nivel")
		comun.scrie_lista(self.cale_fapte, fapte, comun.ORDINEA_FAPTULUI, None)
		comun.verifica_inapoi(self.cale_intrebari, len(self.intrebari))
		comun.verifica_inapoi(self.cale_fapte, len(fapte))
		print("\n  Scris: %s (%d întrebări) și %s (%d fapte)."
		      % (comun.relativ(self.cale_intrebari), len(self.intrebari),
		         comun.relativ(self.cale_fapte), len(fapte)))
		return 0

	def _raspunsul_nu_e_in_text(self):
		"""Un răspuns care se citește din întrebare nu e o întrebare.

		„Ce formație a lansat albumul «Metallica»?” e cazul care o cere: albumele
		care poartă numele formației sunt zeci. Se OPREȘTE, nu se sare: un rând
		ca ăsta se scoate din lista de mână, cu ochii pe el.
		"""
		scapate = []
		for q in self.intrebari:
			bun = q["variante"][q["corect"]]
			if comun.cuvant_in(comun.fara_semne(q["text"]), comun.fara_semne(bun)):
				scapate.append("%s — %s → %s" % (q["id"], q["text"], bun))
		if scapate:
			raise Eroare("răspunsul se citește din text:\n  - " + "\n  - ".join(scapate))

	def _scoate_dublurile(self, celelalte, dubluri, nu_sunt):
		"""O întrebare care întreabă ce întreabă deja una scrisă de mână nu intră.

		„Atinge” înseamnă: o întrebare existentă are, în text sau în răspunsul ei
		bun, ȘI unul dintre subiectele mele (anul, titlul, numele), ȘI răspunsul
		meu. „Ce țară a câștigat Cupa Mondială din 1994?” → Brazilia atinge orice
		întrebare de mână în care stau „1994” și „Brazilia”.

		Prinde mai mult decât trebuie, dinadins: o potrivire falsă se declară cu
		ochiul (`NU_SUNT_DUBLURI`); una ratată pune în joc aceeași
		întrebare de două ori. Iar declarația e în cod, cu aceleași două opriri ca
		la celelalte tabele (`comun.compara_dublurile`): nedeclarată oprește,
		fantomă oprește.
		"""
		texte = self._texte_existente()
		gasite = {}
		for q in self.intrebari:
			subiecte, bun = self.atinge[q["id"]]
			b = comun.fara_semne(bun)
			for id_alt, text in texte:
				if not comun.cuvant_in(text, b):
					continue
				if any(comun.cuvant_in(text, comun.fara_semne(s)) for s in subiecte):
					gasite[(q["id"],)] = id_alt
					break

		comune = set(dubluri) & set(nu_sunt)
		if comune:
			raise Eroare("declarate și ca dubluri, și ca nedubluri: " + ", ".join(sorted(comune)))
		declarate = dict(dubluri)
		declarate.update(nu_sunt)
		comun.compara_dublurile(gasite, {(k,): v for k, v in declarate.items()})
		inainte = len(self.intrebari)
		self.intrebari = [q for q in self.intrebari if q["id"] not in dubluri]
		print("  Dubluri cu întrebări existente, scoase: %d (din %d)"
		      % (inainte - len(self.intrebari), inainte))

	def _unice(self, celelalte):
		"""`id`-uri și texte unice în TOT conținutul, nu doar în tabel."""
		ale_lor_id = {str(q["id"]) for q in celelalte}
		ale_lor_text = {comun.fara_semne(q["text"]) for q in celelalte}
		probleme = []
		vazute_id, vazute_text = set(), set()
		for q in self.intrebari:
			t = comun.fara_semne(q["text"])
			if q["id"] in ale_lor_id or q["id"] in vazute_id:
				probleme.append("id repetat: %s" % q["id"])
			if t in ale_lor_text or t in vazute_text:
				probleme.append("text repetat: %s" % q["text"])
			vazute_id.add(q["id"])
			vazute_text.add(t)
		if probleme:
			raise Eroare("repetiții:\n  - " + "\n  - ".join(probleme))

	def _fapte_folosite(self):
		"""Faptele cerute de măcar o întrebare, în ordinea în care au apărut.

		După scoaterea dublurilor, un fapt poate rămâne fără întrebare; scris așa,
		ar pica verdictul „niciun fapt nefolosit” din `verifica_trivia`.
		"""
		cerute = {q["fapt"] for q in self.intrebari}
		return [f for f in self.fapte if f in cerute]

	def _fapte_unice(self, fapte):
		"""Un `id` de fapt nu poate fi și al altui tabel, și nici al mâinii.

		`trivia.gd` ar păstra-o pe prima și ar ignora-o pe a doua, cu un simplu
		avertisment — deci o întrebare ar arăta nota altui tabel. Cazul nu e
		ipotetic: un fapt-om (`wd:Q…` al unui regizor) ar putea fi mâine și
		compozitor de muzică de film.
		"""
		ale_lor = set()
		for nume in os.listdir(comun.DOSAR_GEN):
			cale = os.path.join(comun.DOSAR_GEN, nume)
			if nume.endswith("_fapte.json") and os.path.abspath(cale) != os.path.abspath(self.cale_fapte):
				ale_lor |= {str(f["id"]) for f in comun.citeste_lista(cale)}
		ale_lor |= {str(f["id"]) for f in comun.citeste_lista(comun.CALE_FAPTE_MANA)}
		comune = sorted(f["id"] for f in fapte if f["id"] in ale_lor)
		if comune:
			raise Eroare("fapte care există deja în alt fișier: " + ", ".join(comune))

	def _raport(self, arg, mana, altele, fapte):
		print("\n  ── %s ──" % self.eticheta_raport.upper())
		for nivel in comun.NIVELURI:
			print("    nivelul %d: %d întrebări" % (
				nivel, sum(1 for q in self.intrebari if q["nivel"] == nivel)))
		sensuri = {}
		for q in self.intrebari:
			s = q["id"].split(":")[3]
			sensuri[s] = sensuri.get(s, 0) + 1
		print("    pe sensuri: %s" % ", ".join("%s %d" % kv for kv in sorted(sensuri.items())))
		if self.refuzate:
			print("    REFUZATE (fără destui distractori): %d" % len(self.refuzate))
			for r in self.refuzate:
				print("      %s" % r)
		comun.raporteaza_notele(fapte, self.probleme_note, arg.scrie)
		comun.grila(mana, altele + self.intrebari)
		comun.cat_din_lupta(mana, altele + self.intrebari, self.intrebari,
		                    self.domeniu, self.eticheta_raport.upper())
		comun.mostre(self.intrebari, 15, arg.samanta)
		print("\n  ── 6 NOTE, LA ÎNTÂMPLARE ──")
		import random
		for f in random.Random(arg.samanta).sample(fapte, min(6, len(fapte))):
			print("    %s  %s" % (f["id"], f["nota"]))


def scrie_propunerile(cale, randuri, ordinea):
	"""`--propune`: candidații, un rând pe obiect, ca să se taie cu mâna.

	Fișierul e în `.gitignore` (`date/*_propuse.json`): nu-l citește niciun
	script, iar alegerea se face COPIIND rânduri în lista de mână, nu prin el.
	"""
	comun.scrie_pe_rand(cale, randuri, ordinea)
	print("  Scris %s (%d candidați)." % (comun.relativ(cale), len(randuri)))

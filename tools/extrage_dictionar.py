# -*- coding: utf-8 -*-
"""Scoate lista de ghiciri acceptate pentru Cuvantul Ascuns, din dictionarul
hunspell romanesc.

DE CE EXISTA DOUA LISTE
-----------------------
`data/taverna_cuvinte.json`   — cuvintele care pot fi RASPUNSUL. Scrise de mana,
                                alese ca sa fie cunoscute si frumoase. 308.
`data/taverna_acceptate.json` — cuvintele pe care AI VOIE sa le scrii. Scoase de
                                aici, din dictionar. ~13 000.

E chiar despartirea lui Wordle, si fara ea jocul avea de ales intre doua rele:
ori accepta "aeiou" (ce facea pana pe 3 noiembrie 2026), ori refuza aproape tot
ce tastezi, fiindcă lista de raspunsuri are 308 cuvinte iar romana are zeci de
mii. Verificarea cere ca TOATE cele 308 raspunsuri sa fie in lista acceptata:
altfel jocul ar refuza chiar cuvantul pe care-l ascunde.

CUM SE REFACE
-------------
Dictionarul NU e in depozit (2,2 MB de radacini de care jocul n-are nevoie).
Se aduce intr-un dosar gol:

    mkdir dict-ro && cd dict-ro
    for f in ro_RO.dic ro_RO.aff COPYING.MPL README_EN.txt; do
      curl -sLO "https://raw.githubusercontent.com/LibreOffice/dictionaries/master/ro/$f"
    done

si apoi:

    python tools/extrage_dictionar.py dict-ro/ro_RO.aff dict-ro/ro_RO.dic \
        data/taverna_acceptate.json

Licenta (MPL 1.1, aleasa din tri-licenta) si autorii stau in
`data/taverna_acceptate-MPL.txt`, langa lista — acelasi tipar ca OFL-ul
fonturilor din `assets/fonturi/`.

CE SE PASTREAZA, SI DE CE ASA
-----------------------------
* Numai radacinile cu litera mica: celelalte sunt nume proprii si abrevieri.
* Formele flexionare se construiesc din regulile de afixe ale dictionarului
  (SFX/PFX), nu se iau de-a gata: altfel "apele" si "casei" n-ar exista.
* Diacriticele se SCOT, nu se resping. Tastatura n-are 31 de litere, deci orice
  cuvant la care se gandeste jucatorul e tastat fara ele — iar "masca" refuzat
  fiindca se scrie "masca" cu a-breve ar fi exact piedica pe care decizia
  "cuvintele n-au diacritice" o scoate din joc.
"""Scoate din dictionarul hunspell romanesc cuvintele de 5 litere, fara diacritice."""
import io, re, sys, json, unicodedata

cale_aff, cale_dic, cale_ies = sys.argv[1], sys.argv[2], sys.argv[3]

LUNGIME = 5

# ── 1. regulile de afixe ─────────────────────────────────────
# Format hunspell: "SFX <flag> <strip> <add> <conditie>".
# Antetul blocului: "SFX <flag> <cruce Y/N> <cate randuri>".
reguli = {}            # flag -> lista de (fel, strip, add, regex)
cruce = {}             # flag -> se poate combina cu celalalt fel?
for linie in io.open(cale_aff, encoding="utf-8"):
    p = linie.split()
    if not p or p[0] not in ("SFX", "PFX"):
        continue
    fel, flag = p[0], p[1]
    if len(p) >= 4 and p[2] in ("Y", "N") and p[3].isdigit():
        cruce[flag] = (p[2] == "Y")
        continue
    strip = "" if p[2] == "0" else p[2]
    adauga = "" if p[3] == "0" else p[3]
    cond = p[4] if len(p) > 4 else "."
    tipar = re.compile(cond + "$" if fel == "SFX" else "^" + cond)
    reguli.setdefault(flag, []).append((fel, strip, adauga, tipar))


def aplica(cuvant, flag):
    """Toate formele pe care flagul asta le scoate din cuvant."""
    iesite = []
    for fel, strip, adauga, tipar in reguli.get(flag, ()):
        if not tipar.search(cuvant):
            continue
        if fel == "SFX":
            if strip and not cuvant.endswith(strip):
                continue
            iesite.append((cuvant[:len(cuvant) - len(strip)] if strip else cuvant) + adauga)
        else:
            if strip and not cuvant.startswith(strip):
                continue
            iesite.append(adauga + (cuvant[len(strip):] if strip else cuvant))
    return iesite


def felul(flag):
    r = reguli.get(flag)
    return r[0][0] if r else None


# ── 2. fara diacritice ───────────────────────────────────────
def desparte(s):
    """ă â î ș ț -> a a i s t. Prinde si varianta cu sedila (ş ţ)."""
    return "".join(
        c for c in unicodedata.normalize("NFD", s)
        if unicodedata.category(c) != "Mn"
    ).replace("ș", "s").replace("ț", "t")


# ── 3. trecerea prin dictionar ───────────────────────────────
gasite = set()
stems = 0
with io.open(cale_dic, encoding="utf-8") as f:
    f.readline()                               # prima linie e un numar
    for linie in f:
        intrare = linie.strip().split("\t")[0]  # taie campurile morfologice
        if not intrare:
            continue
        cuvant, _, steaguri = intrare.partition("/")
        if not cuvant or not cuvant[0].islower():
            continue                            # nume proprii, abrevieri
        stems += 1
        forme = [cuvant]
        sufixe = [s for s in steaguri if felul(s) == "SFX"]
        prefixe = [s for s in steaguri if felul(s) == "PFX"]
        for s in sufixe:
            forme.extend(aplica(cuvant, s))
        for p in prefixe:
            baza = aplica(cuvant, p)
            forme.extend(baza)
            if cruce.get(p, False):
                for b in baza:
                    for s in sufixe:
                        if cruce.get(s, False):
                            forme.extend(aplica(b, s))
        for forma in forme:
            gol = desparte(forma).lower()
            if len(gol) == LUNGIME and gol.isalpha() and gol.isascii():
                gasite.add(gol)

lista = sorted(gasite)
io.open(cale_ies, "w", encoding="utf-8", newline="\n").write(
    json.dumps({"cuvinte": lista}, ensure_ascii=False, indent=0)
)
print("radacini citite: %d" % stems)
print("cuvinte de %d litere, fara diacritice: %d" % (LUNGIME, len(lista)))
print("mostra:", ", ".join(lista[::max(1, len(lista) // 25)][:25]))

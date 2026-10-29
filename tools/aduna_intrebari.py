# -*- coding: utf-8 -*-
"""ADUNĂ UN LOT DE ÎNTREBĂRI SCRISE DE MÂNĂ în data/intrebari_trivia.json.

    python tools/aduna_intrebari.py <lot.json> [...]           # probă uscată
    python tools/aduna_intrebari.py <lot.json> [...] --scrie   # scrie pe disc

Un lot e o listă JSON de intrări cu `nivel`, `categorie`, `subcategorie`,
`text`, `variante` (patru), `corect` și `nota`. Scriptul dă `id`-ul următor
(`mana:NNNN`), pune `fapt` egal cu `id` și scrie nota în data/fapte_trivia.json.

DE CE EXISTĂ. Scrisul unui lot mare nu cade la validările din `trivia.gd`
(acelea prind o întrebare stricată, nu una REPETATĂ), iar baza are mii de
întrebări: nimeni nu le mai ține minte. Scriptul refuză un text identic cu
unul existent și SEMNALEAZĂ apropierile, comparând amprenta fiecărei întrebări
(cuvintele din text plus răspunsul bun) cu toate întrebările din joc, inclusiv
cu cele fabricate din `data/trivia_gen/`. Pragul de 0,50 e o unealtă de citit,
nu un verdict: oglinzile („Paris e capitala cărei țări?”) și întrebările cu
același răspuns dar alt fapt se păstrează dinadins, după ce le citești.

Un `id` nu se refolosește niciodată (vezi sesiunea ID ȘI FAPT), deci o
întrebare greșită se CORECTEAZĂ pe loc, în fișier, nu se șterge.
"""
import json, glob, os, re, sys, unicodedata, collections

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CALE_Q = os.path.join(R, "data", "intrebari_trivia.json")
CALE_F = os.path.join(R, "data", "fapte_trivia.json")

SUB = {
 "geografie": ["geografie_politica","geografie_fizica","turism_monumente","demografie_cultura"],
 "istorie": ["antichitate_ev_mediu","modern_contemporan","lideri_personalitati","mitologie_religii"],
 "stiinta_tehnologie": ["stiinte_exacte","lumea_vie","astronomie_spatiu","tehnologie_inventii"],
 "arta_literatura": ["literatura_universala","arte_vizuale","arhitectura_design","cultura_clasica"],
 "divertisment": ["cinematografie","televiziune","muzica_moderna","pop_culture"],
 "sport_jocuri": ["sporturi_de_echipa","individuale_olimpism","motor_extreme","gaming"],
 "gastronomie_lifestyle": ["bucataria_lumii","ingrediente_tehnici","bauturi","moda_traditii"],
 "diverse": ["lingvistica","logica_perspicacitate","curiozitati"],
}
STOP = set("""a ai al ale alt alta altul am apoi are au ca care cat cate catre ce cea cel cele
ceva ci cine cu cum da dar de deci despre din doar doi dupa e ei el ele era este eu face fara
fi fie fost i ia iar il in intr intre isi la le lor lui mai mare mult n nu numai o or pe pentru
peste pot prima primul prin sa sau se si sunt te unde unu unui unei una va vor cu cel acest
aceasta aceste acesti acel acea numeste numit numita spune zice fel lucru mod""".split())

def norm(s):
    s = unicodedata.normalize("NFKD", s.lower())
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"[^a-z0-9 ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()

def cuvinte(s):
    return {w for w in norm(s).split() if len(w) > 3 and w not in STOP}

def amprenta(q):
    # textul + raspunsul bun: doua intrebari cu acelasi subiect si acelasi
    # raspuns sunt aceeasi intrebare, chiar reformulata
    return cuvinte(q["text"]) | cuvinte(q["variante"][int(q["corect"])])

def citeste_toate():
    vechi = json.load(open(CALE_Q, encoding="utf-8"))
    gen = []
    for p in sorted(glob.glob(os.path.join(R, "data", "trivia_gen", "*_intrebari.json"))):
        gen += json.load(open(p, encoding="utf-8"))
    return vechi, gen

def main():
    scrie = "--scrie" in sys.argv
    lots = [a for a in sys.argv[1:] if not a.startswith("--")]
    vechi, gen = citeste_toate()
    fapte = json.load(open(CALE_F, encoding="utf-8"))
    fapte_id = {f["id"] for f in fapte}

    baza = vechi + gen
    exact = {}
    index = collections.defaultdict(list)   # cuvant -> indici in baza
    amp = []
    for i, q in enumerate(baza):
        exact.setdefault(norm(q["text"]), q["id"])
        a = amprenta(q)
        amp.append(a)
        for w in a:
            index[w].append(i)

    maxid = 0
    for q in vechi:
        m = re.fullmatch(r"mana:(\d+)", q["id"])
        if m: maxid = max(maxid, int(m.group(1)))

    noi_q, noi_f = [], []
    probleme, apropiate = [], []
    nr = maxid
    for lot in lots:
        date = json.load(open(lot, encoding="utf-8"))
        for j, q in enumerate(date):
            unde = "%s[%d]" % (os.path.basename(lot), j)
            dom, sub, niv = q.get("categorie"), q.get("subcategorie"), q.get("nivel")
            if dom not in SUB or sub not in SUB.get(dom, []):
                probleme.append("%s: domeniu/raft greşit (%s / %s)" % (unde, dom, sub)); continue
            if niv not in (1,2,3):
                probleme.append("%s: nivel %r" % (unde, niv)); continue
            v = q.get("variante")
            if not isinstance(v, list) or len(v) != 4 or len({norm(x) for x in v}) != 4:
                probleme.append("%s: variante (%r)" % (unde, v)); continue
            if not isinstance(q.get("corect"), int) or not 0 <= q["corect"] <= 3:
                probleme.append("%s: corect %r" % (unde, q.get("corect"))); continue
            nota = q.get("nota", "")
            if not nota:
                probleme.append("%s: fara nota" % unde); continue
            if len(nota) > 240:
                probleme.append("%s: nota are %d caractere" % (unde, len(nota))); continue
            n = norm(q["text"])
            if n in exact:
                probleme.append("%s: TEXT IDENTIC cu %s" % (unde, exact[n])); continue
            a = amprenta(q)
            cand = collections.Counter()
            for w in a:
                for i in index[w]:
                    cand[i] += 1
            best, bi = 0.0, -1
            for i, com in cand.items():
                sc = com / max(1, len(a | amp[i]))
                if sc > best: best, bi = sc, i
            if best >= 0.50:
                apropiate.append("%s: %.2f ~ %s | %s" % (unde, best, baza[bi]["id"], baza[bi]["text"]))
            nr += 1
            qid = "mana:%04d" % nr
            noi_q.append({
                "id": qid, "verificat": False, "fapt": qid,
                "text": q["text"], "variante": v, "corect": q["corect"],
                "nivel": niv, "subcategorie": sub, "categorie": dom,
            })
            noi_f.append({"id": qid, "nota": nota})
            exact[n] = qid
            index_i = len(amp); amp.append(a)
            for w in a: index[w].append(index_i)
            baza.append(noi_q[-1])

    print("lot: %d intrari, %d bune, %d refuzate, %d apropiate" % (
        sum(len(json.load(open(l, encoding='utf-8'))) for l in lots), len(noi_q), len(probleme), len(apropiate)))
    for p in probleme: print("  REFUZ ", p)
    for p in apropiate: print("  APROAPE", p)
    if not scrie:
        print("proba uscata; nimic scris")
        return 1 if probleme else 0
    if probleme:
        print("NU SCRIU: sunt refuzuri de rezolvat")
        return 1
    vechi_disc = json.load(open(CALE_Q, encoding="utf-8"))
    vechi_disc += noi_q
    with open(CALE_Q, "w", encoding="utf-8") as f:
        json.dump(vechi_disc, f, ensure_ascii=False, indent="\t")
        f.write("\n")
    fapte += noi_f
    with open(CALE_F, "w", encoding="utf-8") as f:
        json.dump(fapte, f, ensure_ascii=False, indent="\t")
        f.write("\n")
    print("scris: %s si %s (%s ... %s)" % (os.path.basename(CALE_Q), os.path.basename(CALE_F),
          noi_q[0]["id"], noi_q[-1]["id"]))
    return 0

sys.exit(main())

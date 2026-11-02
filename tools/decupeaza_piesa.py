"""Decupează glifa unui Obelisc din randarea ei și o pune pe pânza iconițelor.

    python tools/decupeaza_piesa.py              # toate glifele din PIESE
    python tools/decupeaza_piesa.py turn_sah     # doar una

Intrarea e o randare pe TABLA DE TRANSPARENȚĂ — caroiajul alb-gri pe care
editoarele de imagini îl desenează în locul fundalului gol. „Transparent" e
acolo doar aparent: fișierul e JPEG, deci caroiajul e scris în pixeli, iar pus
direct pe buton ar ieși un timbru gri.

Ieșirea e un PNG de 256×256 cu alfa adevărat, GRI, așezat pe aceeași linie de
talpă ca celelalte iconițe — exact ce așteaptă `obelisc.gd`, care îi pune
culoarea disciplinei cu `modulate` (gri × culoare = culoare, cu umbrele
păstrate; pe o imagine deja colorată ar ieși noroi).

De ce un script și nu un decupaj de mână: proporțiile celor opt glife sunt o
FAMILIE — aceeași linie de talpă, aceeași pânză, înălțimi care se compară
între ele. Scrise în dicționarul `PIESE`, se văd dintr-o privire și se refac
dintr-o comandă; tăiate de mână, a noua n-ar mai fi știut de ce pionul e mai
scund decât nebunul.

─────────────────────────────────────────────────────────────
CUM SE DEOSEBEȘTE TABLA DE GLIFĂ

Trei semne, fiindcă niciunul singur nu ajunge.

**Luminozitatea** nu ajunge, și asta s-a măsurat, nu s-a bănuit: caseta închisă
a tablei e pe la 198, iar marginea luminată a pietrei urcă până pe la 190.
Între ele nu e loc de niciun prag — iar sub piesă tabla mai e și întunecată de
umbra ei, deci acolo casetele cad la 176 și un prag destul de jos cât să le
prindă ar mânca jumătate din glifă.

**Regularitatea.** O tablă se repetă: la două casete în stânga și în dreapta se
găsește același ton, iar la una tonul celălalt. Umbra nu strică repetiția,
fiindcă întunecă deodată și casetele deschise, și pe cele închise. O glifă nu se
repetă niciodată așa: marginea ei are fundal de o parte și material de cealaltă,
iar trupul ei e neted, deci îi lipsește tocmai saltul de o casetă.

**Culoarea.** Tabla e CENUȘIE — roșu, verde și albastru egale. Semnul ăsta n-a
fost nevoie la piesele de șah (și ele cenușii), dar fulgerul vine verde aprins,
iar luminozitatea lui (218) e peste pragul de mai sus: fără întrebarea
„are culoare?", jumătate din el ar fi fost declarată fundal.

Peste cele trei, un al patrulea lucru, geometric: umplerea pornește din
marginile imaginii ȘI din orice pată de tablă găsită înăuntru. Prima ține
griurile dinăuntrul glifei la locul lor; a doua scoate GĂURILE — steaua tăiată
în busolă, sticla clepsidrei — care nu se ating de margine și pe care nimic
altceva nu le-ar fi deosebit de material.
"""

import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter

RADACINA = Path(__file__).resolve().parent.parent
ARTA = RADACINA / "assets/art"

# ─────────────────────────────────────────────────────────────
# FAMILIA
# ─────────────────────────────────────────────────────────────

## Latura pânzei și linia de talpă, în pixeli. Nu sunt alese azi: sunt
## măsurate din `pion_sah.png`, `cal_sah.png` și `nebun_sah.png`, tăiate în
## septembrie cu o unealtă care trăia în afara repo-ului. O glifă nouă intră în
## familie doar dacă stă pe aceeași linie.
PANZA = 256
TALPA = 252
## Cât de înaltă e glifa cea mai înaltă (calul și nebunul, de la 6 la 252).
INALTIME_MAX = TALPA - 6

## Cât se rod marginile înainte de micșorare, în pixeli pe randarea mare.
## Pixelii de pe conturul glifei sunt AMESTECAȚI cu fundalul alb de compresia
## JPEG, deci păstrați ar lăsa o dungă deschisă de jur împrejur — iar o dungă
## deschisă, înmulțită cu culoarea disciplinei, se vede ca un halou.
## Doi pixeli din ~900 nu subțiază nimic: după micșorare sunt o jumătate.
RODERE = 2

## Fereastra filtrului de mediană care netezește conturul, în pixeli pe
## randarea mare. Vezi `decupeaza()` pentru ce repară. Busola cere o fereastră
## mai mare decât o CASETĂ de tablă (17), fiindcă acolo nu pâlpâie pixeli, ci
## jumătăți de casetă: umbra discului coboară casetele închise la ~185, adică
## fix cenușiul discului. N-o costă nimic — un disc n-are niciun amănunt mai
## mic decât fereastra, pe când coroana reginei are.
NETEZIRE = 9

## Fiecare glifă: de unde vine, cât de mare e caseta tablei pe care a fost
## randată (măsurată pe rândul de sus al fișierului) și cât de înaltă iese, ca
## fracțiune din `INALTIME_MAX`.
##
## ÎNĂLȚIMILE celor cinci piese de șah nu sunt cele reale dintr-o garnitură
## (acolo pionul e la 0,60 din nebun, iar regina îl depășește) — pânza are o
## margine de sus, iar calul și nebunul o ating deja. Ce se păstrează e
## ORDINEA, fiindcă ea e ce se citește pe butoane alăturate:
## pion < turn < cal = nebun = regină.
##
## Cele trei glife care nu sunt piese n-au nicio ierarhie de păstrat, deci merg
## la înălțimea întreagă — cu o excepție: BUSOLA, care e un disc plin. Ochiul
## nu cântărește înălțimea, ci SUPRAFAȚA, iar un cerc de 246 lângă o regină de
## 115 lățime arată de două ori mai mare, deși e „la fel de înalt". 0,86 e cât a
## fost nevoie ca cele două să pară de o seamă pe butoane alăturate.
##
## „prag" e opțional și spune de la ce luminozitate un pixel cenușiu e fundal
## fără alte întrebări. Implicit e `PRAG_LUMINA`; busola îl ridică fiindcă
## discul ei e cenușiu de 185, iar caseta închisă a tablei e 198 — treisprezece
## unități între material și fundal, cea mai strâmtă fâșie din toate cinci.
PIESE = {
    "turn_sah": {"sursa": "rook.jpg", "caseta": 17, "inaltime": 0.86},
    "regina_sah": {"sursa": "queen.jpg", "caseta": 17, "inaltime": 1.00},
    "busola": {"sursa": "compass.jpg", "caseta": 17, "inaltime": 0.86, "prag": 195, "cojiri": 25,
               "netezire": 31},
    "clepsidra": {"sursa": "hourglass.jpg", "caseta": 17, "inaltime": 1.00},
    "fulger": {"sursa": "bolt.jpg", "caseta": 30, "inaltime": 1.00},
}

# ─────────────────────────────────────────────────────────────
# DECUPAREA
# ─────────────────────────────────────────────────────────────

## Peste atât, un pixel CENUȘIU e fundal fără să mai fie nevoie de alte
## întrebări. 192 e sub caseta închisă a tablei (198) și peste cea mai luminată
## margine a pietrei (~190) — adică fix fâșia în care cele două nu se ating.
PRAG_LUMINA = 192

## Cât de mare poate fi diferența dintre roșu, verde și albastru ca un pixel să
## mai treacă drept cenușiu. Tabla e perfect cenușie; compresia JPEG o
## colorează cu câteva unități pe muchii, de unde marja.
PRAG_CROMA = 14

## Cât de aproape trebuie să fie două casete de ACELAȘI fel (la 2 casete
## distanță) ca să treacă drept repetiție, și cât de departe trebuie să fie
## două VECINE (la o casetă) ca să treacă drept salt.
LA_FEL = 14
ALTFEL = 25

## Sub atât nu se mai pune întrebarea repetiției. O tablă, oricât de umbrită
## sau văzută prin sticlă, rămâne mai deschisă decât materialul glifei.
PRAG_TABLA = 110

## COJIREA FRANJURILOR. Un pixel cenușiu mai deschis de atât, aflat chiar pe
## marginea glifei, e un ciob de tablă agățat de ea, nu material: nicio randare
## din cele cinci nu are o margine luminată peste 190, fiindcă materialul e
## mat. Fără pasul ăsta, busola iese cu un inel de puncte albe în jur — casete
## deschise prea mici ca să mai aibă vecini pe care să-i repete, deci scăpate
## și de prag, și de ritm.
PRAG_FRANJ = 193
## Câte straturi se cojesc. Trei ajung pe margini curate; busola cere mai
## multe, fiindcă în crestătura stelei bevelul prinde lumină și lasă așchii
## lungi de câte douăzeci de pixeli. Nu poate mânca materialul: niciuna din
## cele cinci randări nu are material peste `PRAG_FRANJ`.
COJIRI = 3

## DE CE COJIREA S-A MUTAT DUPĂ NETEZIRE (2 noiembrie 2026)
##
## A stat o zi înainte de ea, și o zi busola a ieșit cu exact inelul alb pe
## care cojirea îl scrisese în comentariu că-l scoate. Cele două se băteau cap
## în cap, și aritmetica o spune: cojirea taie `cojiri` straturi lipite de
## margine (25 la busolă), iar netezirea de după trece peste mască cu o
## fereastră de 31 și cere fiecărui pixel „fii ce sunt majoritatea vecinilor
## tăi". Un pixel din mijlocul unei fâșii subțiri de 25, rase de pe marginea
## unui DISC de 700, are majoritatea vecinilor înăuntru — deci netezirea punea
## înapoi aproape tot ce cojirea scosese, iar `MinFilter`-ul de la final nu mai
## roade decât 2 pixeli din el.
##
## Mutarea e o lecție, nu un reglaj, și e chiar cea scrisă deja o dată în
## comentariul cojirii: „e o întrebare despre MARGINE, iar marginea nu există
## până nu s-a așezat fundalul." Netezirea MUTĂ marginea, deci după ea e altă
## margine, și întrebarea trebuie pusă din nou.
##
## Cojirea dinaintea netezirii n-a fost scoasă: ea curăță pata din care se
## alege „cea mai mare", deci ce face ea nu e același lucru cu ce face asta.


def _pata_cea_mai_mare(plin, latime: int, inaltime: int) -> list[int]:
    """Indicii celei mai mari pete legate din `plin` (1 = face parte din formă).

    Celelalte pete sunt cioburi de compresie agățate prin colțurile casetelor:
    câțiva pixeli fiecare, invizibili pe randare și foarte vizibili pe un buton
    de 46 px.
    """
    vazut = bytearray(latime * inaltime)
    cea_mai_mare: list[int] = []
    coada: deque[int] = deque()
    for start in range(latime * inaltime):
        if not plin[start] or vazut[start]:
            continue
        pata: list[int] = []
        vazut[start] = 1
        coada.append(start)
        while coada:
            i = coada.popleft()
            pata.append(i)
            y, x = divmod(i, latime)
            vecini = (
                i - 1 if x else -1,
                i + 1 if x < latime - 1 else -1,
                i - latime if y else -1,
                i + latime if y < inaltime - 1 else -1,
            )
            for j in vecini:
                if j >= 0 and plin[j] and not vazut[j]:
                    vazut[j] = 1
                    coada.append(j)
        if len(pata) > len(cea_mai_mare):
            cea_mai_mare = pata
    return cea_mai_mare


def _masca(indici: list[int], latime: int, inaltime: int) -> Image.Image:
    """O mască alb-negru din indicii dați."""
    pixeli = bytearray(latime * inaltime)
    for i in indici:
        pixeli[i] = 255
    return Image.frombytes("L", (latime, inaltime), bytes(pixeli))


def _taie(cale: Path, caseta: int, prag: int, cojiri: int):
    """Întoarce (griuri, lățime, înălțime, pixelii glifei) pentru o randare."""
    color = Image.open(cale).convert("RGB")
    latime, inaltime = color.size
    # Griul e LUMINANȚA, nu media celor trei canale: un verde de 254 și un
    # albastru de 254 nu se văd la fel de luminoase, iar iconița trebuie să
    # păstreze volumul, nu valorile.
    imagine = color.convert("L")
    gri = list(imagine.getdata())
    r, v, a = color.split()
    croma = list(ImageChops.difference(
        ImageChops.lighter(ImageChops.lighter(r, v), a),
        ImageChops.darker(ImageChops.darker(r, v), a),
    ).getdata())

    def cenusiu(i: int) -> bool:
        return croma[i] <= PRAG_CROMA

    def repeta(i: int, pas: int, de_la: int, pana_la: int) -> bool:
        """Se repetă tonul din `i` cu pasul `pas`, ca o tablă?"""
        aici = gri[i]
        if aici < PRAG_TABLA:
            return False
        if i - 2 * pas < de_la or i + 2 * pas >= pana_la:
            return False
        if abs(gri[i - 2 * pas] - aici) > LA_FEL or abs(gri[i + 2 * pas] - aici) > LA_FEL:
            return False
        return abs(gri[i - pas] - aici) >= ALTFEL or abs(gri[i + pas] - aici) >= ALTFEL

    def ritm(i: int) -> tuple[bool, bool]:
        """Repetiția pe orizontală și pe verticală, separat."""
        if not cenusiu(i):
            return False, False
        y, x = divmod(i, latime)
        pe_lat = (2 * caseta <= x < latime - 2 * caseta
                  and repeta(i, caseta, y * latime, y * latime + latime))
        pe_inalt = (2 * caseta <= y < inaltime - 2 * caseta
                    and repeta(i, latime * caseta, 0, latime * inaltime))
        return pe_lat, pe_inalt

    def e_tabla(i: int) -> bool:
        # UNA din direcții ajunge: lângă glifă, cealaltă e acoperită de ea.
        pe_lat, pe_inalt = ritm(i)
        return pe_lat or pe_inalt

    fundal = bytearray(latime * inaltime)
    coada: deque[int] = deque()

    def impinge(i: int) -> None:
        if not fundal[i] and cenusiu(i) and (gri[i] >= prag or e_tabla(i)):
            fundal[i] = 1
            coada.append(i)

    # SĂMÂNȚA DE PE MARGINI: tot ce se atinge de marginea imaginii printr-un
    # drum de fundal e fundal.
    for x in range(latime):
        impinge(x)
        impinge((inaltime - 1) * latime + x)
    for y in range(inaltime):
        impinge(y * latime)
        impinge(y * latime + latime - 1)

    # SEMINȚELE DINĂUNTRU: petele de tablă închise în glifă — steaua busolei,
    # sticla clepsidrei. Aici întrebarea e mai strictă, AMBELE direcții, nu una:
    # o sămânță greșită n-ar roade conturul, ar deschide o gaură în mijlocul
    # glifei, deci greșeala costă mult mai mult decât pe margine. O tablă
    # adevărată, văzută pe toate părțile, trece și așa.
    for i in range(latime * inaltime):
        if fundal[i]:
            continue
        pe_lat, pe_inalt = ritm(i)
        if pe_lat and pe_inalt:
            fundal[i] = 1
            coada.append(i)

    while coada:
        i = coada.popleft()
        y, x = divmod(i, latime)
        if x:
            impinge(i - 1)
        if x < latime - 1:
            impinge(i + 1)
        if y:
            impinge(i - latime)
        if y < inaltime - 1:
            impinge(i + latime)

    # COJIREA: franjurile luminoase rămase pe contur, strat cu strat. Se face
    # DUPĂ umplere, nu în timpul ei, fiindcă e o întrebare despre margine, iar
    # marginea nu există până nu s-a așezat fundalul.
    for _ in range(cojiri):
        de_cojit = []
        for i in range(latime * inaltime):
            if fundal[i] or not cenusiu(i) or gri[i] < PRAG_FRANJ:
                continue
            y, x = divmod(i, latime)
            if ((x and fundal[i - 1]) or (x < latime - 1 and fundal[i + 1])
                    or (y and fundal[i - latime])
                    or (y < inaltime - 1 and fundal[i + latime])):
                de_cojit.append(i)
        if not de_cojit:
            break
        for i in de_cojit:
            fundal[i] = 1

    # CEA MAI MARE pată rămasă e glifa. Celelalte sunt cioburi de compresie
    # agățate prin colțurile casetelor — câțiva pixeli fiecare, invizibili pe
    # randare și foarte vizibili pe un buton de 46 px.
    glifa = _pata_cea_mai_mare(
        bytes(0 if f else 1 for f in fundal), latime, inaltime)

    # HARTA FRANJULUI: pixelii prea luminoși ca să fie material, oriunde ar fi.
    # Nu „pe margine" — marginea se mai mișcă o dată, la netezire, iar atunci
    # întrebarea se pune din nou (vezi comentariul lui `COJIRI`).
    franj = Image.frombytes("L", (latime, inaltime), bytes(
        255 if (croma[i] <= PRAG_CROMA and gri[i] >= PRAG_FRANJ) else 0
        for i in range(latime * inaltime)))
    return imagine, latime, inaltime, glifa, franj


def _cojeste(alfa: Image.Image, franj: Image.Image, cojiri: int) -> Image.Image:
    """Rade de pe conturul măștii, strat cu strat, pixelii din `franj`.

    Scris cu filtre, nu cu bucle peste pixeli: masca are două milioane de
    pixeli, iar 25 de straturi în Python ar fi însemnat cincizeci de milioane
    de pași pentru o glifă. `MinFilter(3)` pe o mască alb-negru E eroziunea cu
    un pixel, deci „masca minus masca erodată" E conturul.
    """
    for _ in range(cojiri):
        contur = ImageChops.subtract(alfa, alfa.filter(ImageFilter.MinFilter(3)))
        de_cojit = ImageChops.multiply(contur, franj)
        if not de_cojit.getbbox():
            break
        alfa = ImageChops.subtract(alfa, de_cojit)
    return alfa


def decupeaza(nume: str, date: dict) -> Path:
    netezire = date.get("netezire", NETEZIRE)
    sursa = ARTA / date["sursa"]
    cojiri = date.get("cojiri", COJIRI)
    imagine, latime, inaltime, glifa, franj = _taie(
        sursa, date["caseta"], date.get("prag", PRAG_LUMINA), cojiri)

    alfa = _masca(glifa, latime, inaltime)
    # NETEZIREA conturului. Conturul unui obiect randat e neted; unul zimțat e
    # o hotărâre care a PÂLPÂIT, nu o margine. La busolă pâlpâie tot timpul,
    # fiindcă discul ei (185) și caseta închisă a tablei (198) sunt la
    # treisprezece unități una de alta, deci de-a lungul marginii cele două
    # întrebări — pragul și ritmul — se contrazic de la pixel la pixel și rama
    # iese punctată.
    #
    # Filtrul de MEDIANĂ ia valoarea din mijlocul ferestrei, deci pe o mască
    # alb-negru înseamnă „fii ce sunt majoritatea vecinilor tăi": umple
    # scobiturile de câțiva pixeli și rade colții, fără să miște o margine
    # adevărată, care are vecinii de partea ei. Nouă pixeli dintr-o randare de
    # ~800 nu rotunjesc nici vârfurile stelei.
    alfa = alfa.filter(ImageFilter.MedianFilter(netezire))
    # COJIREA, A DOUA OARĂ — pe marginea pe care netezirea tocmai a așezat-o.
    # Fără ea, busola iese cu un inel alb de jur împrejur și cu așchii albe în
    # crestăturile stelei: netezirea pune înapoi aproape tot ce cojirea
    # dinaintea ei scosese. Vezi comentariul lui `COJIRI`.
    alfa = _cojeste(alfa, franj, cojiri)
    # Rodere: `MinFilter` ia cel mai mic pixel din fereastră, deci pe o mască
    # alb-negru înseamnă „taie `RODERE` pixeli de jur împrejur".
    alfa = alfa.filter(ImageFilter.MinFilter(RODERE * 2 + 1))

    # PLAFONUL DE TON — cât de deschisă are voie să fie glifa micșorată.
    #
    # Se măsoară din ea însăși: cel mai deschis pixel din INTERIORUL măștii (la
    # cel puțin 4 pixeli de margine) care NU e în harta franjului. Adică tonul
    # cel mai deschis pe care materialul îl are cu adevărat — iar un pixel pe
    # care regula franjului îl numește deja prea deschis ca să fie material nu
    # are ce căuta în măsurătoare.
    #
    # Nu era de ajuns „cel mai deschis din interior", și s-a văzut din prima
    # rulare: la busolă ieșea 255, deci plafonul nu tăia nimic. Netezirea de 31
    # umple cu material sliturile subțiri din vârfurile stelei, iar ele sunt
    # tablă albă — pixeli de 255 aflați adânc în mască, nu pe contur.
    #
    # DE CE E NEVOIE DE EL. Micșorarea amestecă pixeli, iar pe contur se adună
    # două greșeli care trag amândouă spre alb:
    #   • LANCZOS SUPRA-OSCILEAZĂ. La o trecere bruscă întuneric → lumină,
    #     filtrul aruncă valori peste capetele intervalului. Măsurat pe busolă:
    #     37 de pixeli prea deschiși pe contur cu Lanczos, 13 cu BOX, care nu
    #     oscilează deloc. Nu se schimbă filtrul — Lanczos e cel mai limpede la
    #     micșorare, iar coroana reginei are nevoie de limpezime.
    #   • ÎMPĂRȚIREA LA ALFA amplifică. Un pixel acoperit 10% are culoarea
    #     împărțită la 0,1 ca să se afle tonul adevărat — deci orice urmă de
    #     eroare din numărător se înmulțește cu zece.
    #
    # Amândouă dau același lucru: un pieptene de puncte albe lipit de contur,
    # care pe un disc cenușiu de 134 se vede ca un halou. Plafonul le taie pe
    # amândouă fără să atingă forma și fără niciun număr scris de mână — la
    # fulger, care e deschis de la natură (218), nu taie nimic.
    interior = ImageChops.subtract(alfa.filter(ImageFilter.MinFilter(9)), franj)
    plafon = ImageChops.multiply(imagine, interior).getextrema()[1]

    decupaj = Image.merge("RGBA", (imagine, imagine, imagine, alfa))
    decupaj = decupaj.crop(alfa.getbbox())

    # Micșorarea se face cu alfa ÎNMULȚIT în culoare și apoi împărțit la loc.
    # Altfel, la amestecarea pixelilor, griul glifei s-ar amesteca cu pixelii
    # din afara ei — care au alfa 0, dar culoarea fundalului alb — și conturul
    # ar ieși deschis, adică exact haloul pe care rodeala l-a scos.
    tinta_h = round(INALTIME_MAX * date["inaltime"])
    tinta_w = round(decupaj.width * tinta_h / decupaj.height)
    r, g, b, a = decupaj.split()
    r, g, b = (ImageChops.multiply(c, a) for c in (r, g, b))
    mic = Image.merge("RGBA", (r, g, b, a)).resize((tinta_w, tinta_h), Image.LANCZOS)
    r, g, b, a = mic.split()
    canal = Image.new("L", mic.size)
    canal.putdata([0 if av == 0 else min(plafon, cv * 255 // av)
                   for cv, av in zip(r.getdata(), a.getdata())])
    mic = Image.merge("RGBA", (canal, canal, canal, a))

    panza = Image.new("RGBA", (PANZA, PANZA), (0, 0, 0, 0))
    panza.paste(mic, ((PANZA - tinta_w) // 2, TALPA - tinta_h), mic)
    iesire = ARTA / (nume + ".png")
    panza.save(iesire)
    print("%-12s %s -> %s  (%dx%d, talpa %d)"
          % (nume, date["sursa"], iesire.name, tinta_w, tinta_h, TALPA))
    return iesire


if __name__ == "__main__":
    cerute = sys.argv[1:] or list(PIESE)
    for nume in cerute:
        if nume not in PIESE:
            raise SystemExit("Nu stiu glifa %s. Stiu: %s" % (nume, ", ".join(PIESE)))
        decupeaza(nume, PIESE[nume])

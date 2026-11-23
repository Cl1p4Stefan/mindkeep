"""Pregătește imaginile iazului: fundalurile se micșorează, undița și pontonul
se decupează de pe alb.

    python tools/iazul_imagini.py <zi.jpg> <amurg.jpg> <noapte.jpg> <undita.jpg> <ponton.jpg>

Scrie în assets/iazul/. Imaginile generate vin pe fond ALB și fără canal
alfa, deci fundalul se scoate aici: se umple de la margini tot ce e aproape
alb și fără culoare (un „găleată de vopsea” pornită din toate marginile), iar
pe muchie alfa se face moale și culoarea se curăță de albul amestecat în ea —
altfel undița ar avea un contur alb, vizibil pe cerul de noapte.

Umplerea pornește din MARGINI, nu ia „orice pixel alb”: luciul umed de pe
scândurile pontonului e aproape alb, dar e înconjurat de lemn, deci rămâne.

Doar Pillow, fără numpy (nu e instalat aici).
"""

import sys
from collections import deque
from pathlib import Path

from PIL import Image, ImageFilter

DOSAR = Path(__file__).resolve().parent.parent / "assets" / "iazul"
LATIME_FUNDAL = 1600
LATIME_DECUPAT = 1000


def fundal(sursa: str, nume: str) -> None:
    im = Image.open(sursa).convert("RGB")
    h = round(im.height * LATIME_FUNDAL / im.width)
    im = im.resize((LATIME_FUNDAL, h), Image.LANCZOS)
    im.save(DOSAR / nume, quality=88, optimize=True)
    print(f"  {nume}: {im.size}")


def e_alb(p, prag: int) -> bool:
    r, g, b = p[:3]
    return min(r, g, b) >= prag and max(r, g, b) - min(r, g, b) <= 22


def decupeaza(sursa: str, nume: str) -> None:
    im = Image.open(sursa).convert("RGB")
    h = round(im.height * LATIME_DECUPAT / im.width)
    im = im.resize((LATIME_DECUPAT, h), Image.LANCZOS)
    w, h = im.size
    px = im.load()

    # 1. Fondul: umplere din margini peste pixelii aproape albi.
    fond = bytearray(w * h)
    coada = deque()
    for x in range(w):
        coada.append((x, 0))
        coada.append((x, h - 1))
    for y in range(h):
        coada.append((0, y))
        coada.append((w - 1, y))
    while coada:
        x, y = coada.popleft()
        i = y * w + x
        if fond[i] or not e_alb(px[x, y], 228):
            continue
        fond[i] = 1
        if x > 0: coada.append((x - 1, y))
        if x < w - 1: coada.append((x + 1, y))
        if y > 0: coada.append((x, y - 1))
        if y < h - 1: coada.append((x, y + 1))

    # 1b. Golurile ÎNCHISE: albul dintre barele mulinetei sau dintr-o crăpătură
    # nu atinge marginea, deci umplerea de mai sus nu ajunge la el. Se scoate
    # doar albul PUR (≥ 242) în pete de cel puțin 20 de pixeli — luciul umed
    # de pe scânduri e mai cenușiu și mai mărunt, deci rămâne.
    vazut = bytearray(w * h)
    for y0 in range(h):
        for x0 in range(w):
            i0 = y0 * w + x0
            if fond[i0] or vazut[i0] or not e_alb(px[x0, y0], 242):
                continue
            pata = []
            coada = deque([(x0, y0)])
            vazut[i0] = 1
            while coada:
                x, y = coada.popleft()
                pata.append(y * w + x)
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= nx < w and 0 <= ny < h:
                        j = ny * w + nx
                        if not vazut[j] and not fond[j] and e_alb(px[nx, ny], 236):
                            vazut[j] = 1
                            coada.append((nx, ny))
            if len(pata) >= 20:
                for j in pata:
                    fond[j] = 1

    # 2. Masca, puțin înmuiată, ca muchia să nu fie în trepte.
    masca = Image.new("L", (w, h))
    masca.putdata([0 if f else 255 for f in fond])
    masca = masca.filter(ImageFilter.GaussianBlur(0.8))
    m = masca.load()

    # 3. Pe muchie: cât din pixel e alb amestecat se scoate din culoare.
    out = Image.new("RGBA", (w, h))
    o = out.load()
    for y in range(h):
        for x in range(w):
            a = m[x, y]
            r, g, b = px[x, y]
            if a == 0:
                o[x, y] = (0, 0, 0, 0)
                continue
            if a < 255:
                f = a / 255.0
                r, g, b = (max(0, min(255, round((c - 255 * (1 - f)) / f))) for c in (r, g, b))
            o[x, y] = (r, g, b, a)
    out = curata_muchia(out)
    out.save(DOSAR / nume, optimize=True)
    m = out.getchannel("A").load()

    # Unde e vârful și unde e mânerul — pentru undiță, în pixeli.
    vizibil = [(x, y) for y in range(h) for x in range(w) if m[x, y] > 128]
    sus = min(vizibil, key=lambda p: p[1])
    jos = [p for p in vizibil if p[1] == h - 1]
    print(f"  {nume}: {out.size}, cel mai de sus pixel {sus}, rândul de jos x {min(p[0] for p in jos) if jos else '-'}..{max(p[0] for p in jos) if jos else '-'}")


def curata_muchia(im: Image.Image) -> Image.Image:
    """Scoate conturul alb rămas după decupare.

    Generatorul de imagini netezește marginea obiectului ÎN fondul alb, deci
    în jurul lui rămâne o dungă de 1-3 pixeli de cenușiu deschis, prea închisă
    ca s-o prindă pragul de alb și prea deschisă ca să fie lemn. Pe fond închis
    (noaptea, apa) se vede ca un contur desenat cu creta.

    Două lucruri: muchia se roade cu un pixel, iar în banda de 3 pixeli de pe
    margine un pixel MAI DESCHIS decât interiorul de lângă el își ia culoarea
    de la cel mai apropiat pixel din interior. Pixelii mai închiși rămân —
    așa nu se pierd fibrele frânghiei sau crăpăturile de pe muchie.

    Nu e idempotentă (roade câte un pixel la fiecare trecere), deci se cheamă o
    singură dată, pe decupajul proaspăt.
    """
    w, h = im.size
    alfa = im.getchannel("A")
    plin = alfa.point(lambda a: 255 if a > 128 else 0)
    ros = plin.filter(ImageFilter.MinFilter(3))
    interior = plin.filter(ImageFilter.MinFilter(7)).load()
    domeniu = ros.filter(ImageFilter.MaxFilter(3)).load()
    px = im.load()

    # Cel mai apropiat pixel din interior, pentru fiecare pixel din bandă:
    # o căutare în lățime pornită deodată din tot interiorul.
    sursa = [None] * (w * h)
    coada = deque()
    for y in range(h):
        for x in range(w):
            if interior[x, y]:
                sursa[y * w + x] = px[x, y][:3]
                coada.append((x, y))
    while coada:
        x, y = coada.popleft()
        c = sursa[y * w + x]
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                j = ny * w + nx
                if sursa[j] is None and domeniu[nx, ny]:
                    sursa[j] = c
                    coada.append((nx, ny))

    def lum(c) -> float:
        return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]

    alfa_nou = ros.filter(ImageFilter.GaussianBlur(0.7)).load()
    out = Image.new("RGBA", (w, h))
    o = out.load()
    for y in range(h):
        for x in range(w):
            a = alfa_nou[x, y]
            if a == 0:
                o[x, y] = (0, 0, 0, 0)
                continue
            c = px[x, y][:3]
            s = sursa[y * w + x]
            if not interior[x, y] and s is not None and lum(c) > lum(s) + 10:
                c = s
            o[x, y] = (*c, a)
    return out


def main() -> None:
    if len(sys.argv) != 6:
        print(__doc__)
        sys.exit(1)
    DOSAR.mkdir(parents=True, exist_ok=True)
    zi, amurg, noapte, undita, ponton = sys.argv[1:]
    fundal(zi, "fundal_zi.jpg")
    fundal(amurg, "fundal_amurg.jpg")
    fundal(noapte, "fundal_noapte.jpg")
    decupeaza(undita, "undita.png")
    decupeaza(ponton, "ponton.png")


if __name__ == "__main__":
    main()

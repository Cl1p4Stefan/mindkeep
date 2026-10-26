"""Decupează cartea „Cronicile" din fundalul hărții, ca imagine separată.

    python tools/decupeaza_cartea.py

Cartea e PICTATĂ în `assets/art/campaign_map.jpg`, deci jocul n-o poate mișca.
Scriptul o taie de acolo într-un PNG cu transparență,
`assets/art/carte_cronici.png`, pe care `scenes/harta/carte_harta.gd` îl
desenează EXACT peste cea pictată. În repaus nu se vede nicio diferență; sub
mouse, decupajul se ridică și alunecă spre stânga.

De ce un script și nu un decupaj de mână: conturul e o listă de puncte, iar
dacă fundalul se schimbă, refaci PNG-ul dintr-o comandă. Tot de aici vine și
zona de clic — jocul citește transparența PNG-ului, deci conturul există o
singură dată, aici.

Decupajul merge până la marginea din dreapta și cea de jos a imaginii. Jocul se
bazează pe asta ca să-l așeze: colțul lui de sus-stânga e
(mărimea fundalului − mărimea decupajului), fără nicio cifră copiată în GDScript.
"""

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

RADACINA = Path(__file__).resolve().parent.parent
FUNDAL = RADACINA / "assets/art/campaign_map.jpg"
IESIRE = RADACINA / "assets/art/carte_cronici.png"
IESIRE_MARGINE = RADACINA / "assets/art/carte_cronici_margine.png"
IESIRE_UMBRA = RADACINA / "assets/art/carte_cronici_umbra.png"

# Conturul cărții, în FRACȚIUNI din imagine, în sensul acelor de ceasornic de
# la colțul de sus al cotorului. Măsurat pe imaginea originală cu o grilă de
# 0,01 peste ea, luminată ca să se vadă muchiile pe lemnul închis.
#
# Muchia de jos e ÎNCLINATĂ și atinge marginea imaginii pe la 0,96; de acolo
# spre dreapta, cartea continuă sub marginea ecranului. Două variante greșite,
# ca să nu se repete: una cobora drept din colțul cotorului (prindea masă), una
# urca spre colțul din dreapta-jos (lăsa afară muchia groasă a copertei).
#
# Cotorul și muchia de sus sunt măsurate din PIXELI (pergamentul e deschis,
# pielea e închisă), nu din ochi: pe rândurile 0,54-0,62 cotorul e la
# 0,920 → 0,903, iar o dreaptă trasă din ochi lăsa o fâșie de hârtie pe el.
#
# Muchia de sus include și CHENARUL ei: o dungă închisă, apoi una aurie, de
# 3-4 pixeli, care începe deasupra locului unde se termină hârtia la vedere.
# Prima variantă tăia sub ea, iar la coborâre dunga cărții pictate ieșea pe sub
# decupaj ca o a doua muchie de sus — cartea părea dublă exact cât mai era
# ridicată puțin.
CONTUR = [
    (0.921, 0.531),
    (0.950, 0.543),
    (0.975, 0.559),
    (1.000, 0.577),
    (1.000, 1.000),
    (0.958, 1.000),
    (0.940, 0.987),
    (0.920, 0.970),
    (0.900, 0.957),
    (0.880, 0.945),
    (0.860, 0.931),
    (0.846, 0.919),
    (0.842, 0.911),
]

# Masca se desenează de 4 ori mai mare și se micșorează: marginea iese netedă,
# nu în trepte. Fără asta, cartea ridicată ar avea muchia „zimțată”.
SUPRAESANTIONARE = 4

# ─── MARGINEA ─────────────────────────────────────────────────
# Un contur din puncte nu prinde niciodată EXACT cartea pictată: colțul de sus
# al cotorului e rotunjit, muchia are un chenar și o umbră pictată pe hârtie.
# Orice pixel al cărții rămas pe dinafară iese pe sub decupaj la coborâre, ca o
# a doua muchie — de două ori l-am vânat cu măsurători, și tot rămânea unul.
#
# Așa că se mai scrie o imagine, `carte_cronici_margine.png`: același decupaj,
# lățit cu MARGINE_PLINA pixeli opaci și apoi estompat. Jocul o desenează SUB
# carte. Ce ia ea în plus din jur e hârtie peste hârtie și masă peste masă,
# mutate cu câțiva pixeli și cu marginea moale, deci nu se văd; ce acoperă e
# orice rest al cărții pictate. Umbra și zona de clic rămân pe conturul strâns.
MARGINE_PLINA = 6
MARGINE_ESTOMPARE = 4.0

# ─── UMBRA ────────────────────────────────────────────────────
# A treia imagine, `carte_cronici_umbra.png`: silueta cărții, neagră și
# ESTOMPATĂ. Prima umbră era chiar decupajul colorat în negru, deci o siluetă
# tăiată la fel de precis ca cartea: deplasată spre stânga-jos, colțul ei de sus
# arăta ca o a doua carte sub cea ridicată. O umbră adevărată n-are muchii.
UMBRA_ESTOMPARE = 9.0


def main() -> None:
    fundal = Image.open(FUNDAL).convert("RGB")
    latime, inaltime = fundal.size

    # Cutia: de la cel mai din stânga / cel mai de sus punct, până la colțul
    # din dreapta-jos al imaginii (vezi docstring-ul).
    # Cutia are loc și pentru margine, de-aia începe mai la stânga și mai sus.
    # Toate trei imaginile ies din aceeași cutie, deci se așază identic.
    rezerva = max(MARGINE_PLINA + int(MARGINE_ESTOMPARE * 3), int(UMBRA_ESTOMPARE * 3))
    x0 = int(min(x for x, _ in CONTUR) * latime) - rezerva
    y0 = int(min(y for _, y in CONTUR) * inaltime) - rezerva
    cutie = fundal.crop((x0, y0, latime, inaltime))

    s = SUPRAESANTIONARE
    masca = Image.new("L", (cutie.width * s, cutie.height * s), 0)
    puncte = [((x * latime - x0) * s, (y * inaltime - y0) * s) for x, y in CONTUR]
    ImageDraw.Draw(masca).polygon(puncte, fill=255)
    masca = masca.resize(cutie.size, Image.LANCZOS)

    latita = masca.filter(ImageFilter.MaxFilter(2 * MARGINE_PLINA + 1))
    latita = latita.filter(ImageFilter.GaussianBlur(MARGINE_ESTOMPARE))
    latita = ImageChops.lighter(latita, masca)

    for iesire, alfa in ((IESIRE, masca), (IESIRE_MARGINE, latita)):
        decupaj = cutie.convert("RGBA")
        decupaj.putalpha(alfa)
        decupaj.save(iesire)
        print(f"{iesire.relative_to(RADACINA)}: {decupaj.width}x{decupaj.height}, "
              f"de la ({x0}, {y0}) din {latime}x{inaltime}")

    umbra = Image.new("RGBA", cutie.size, (0, 0, 0, 0))
    umbra.putalpha(masca.filter(ImageFilter.GaussianBlur(UMBRA_ESTOMPARE)))
    umbra.save(IESIRE_UMBRA)
    print(f"{IESIRE_UMBRA.relative_to(RADACINA)}: {umbra.width}x{umbra.height}, blur {UMBRA_ESTOMPARE} px")


if __name__ == "__main__":
    main()

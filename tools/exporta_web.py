#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EXPORTĂ BUILD-UL WEB ȘI ÎL ÎMPACHETEAZĂ PENTRU ITCH.IO.

    python tools/exporta_web.py              export + zip, CU Alergologia
    python tools/exporta_web.py --public     export + zip, FĂRĂ Alergologia

Face, în ordine, cei doi pași care se repetau de mână la fiecare versiune nouă:

  1. EXPORTUL: cheamă Godot fără fereastră, cu presetul „Web” din
     `export_presets.cfg`, care scrie în `../mindkeep_web/`.
  2. ARHIVA: pune CONȚINUTUL dosarului (nu dosarul însuși) în
     `../mindkeep_web.zip`, cu `index.html` direct la rădăcină, cum îl vrea
     itch.io.

Al treilea pas, urcarea zip-ului pe https://gyarados9.itch.io/mindkeep, rămâne
de mână: Edit game → Uploads → zip-ul nou, cu „played in the browser” bifat.

─────────────────────────────────────────────────────────────
CE VERIFICĂ, ȘI DE CE

- ETICHETA `alergologie`, în AMBELE sensuri. Secțiunea se aprinde doar dacă
  jocul a fost exportat cu eticheta asta în Custom Features (vezi
  `ALERGOLOGIE` din `scenes/trivia/trivia.gd`). Deci fiecare build și-o
  CERE: cel cu Alergologia oprește dacă lipsește, cel public oprește dacă e
  acolo. A doua jumătate nu e simetrie de dragul simetriei — un build public
  cu eticheta rămasă pe el arată exact ca unul fără ea până deschide cineva
  Practice, adică greșeala s-ar vedea abia pe itch.io. Se verifică de DOUĂ
  ori, în amândouă sensurile: în presetul din `export_presets.cfg` înainte de
  export, și în pachetul ieșit după (Godot o scrie în `project.binary`, ca
  `_custom_features`).
- CARE BUILD. Cele două sunt un RÂND în `BUILDURI`, nu o ramură: fiecare are
  presetul lui, dosarul lui și arhiva lui, deci nu se calcă — poți avea
  amândouă zip-urile pe disc deodată, iar `index.pck` al unuia nu e verificat
  în locul celuilalt.
- PACHETUL (`index.pck`). Fișierele JSON nu sunt resurse Godot și intră doar
  dacă presetul le prinde în filtru (vezi `fisierele_generate()` din
  `trivia.gd`). Un export fără ele nu dă nicio eroare, doar un joc gol. Aici
  se caută numele lor în pachet: grosolan, dar prinde exact greșeala aia.
- CE NU E COMIS. Exportul ia proiectul așa cum e PE DISC, nu ce e în Git.
  Scriptul doar ARATĂ fișierele modificate, nu oprește: uneori chiar vrei
  să urci ceva încă necomis.

Calea spre Godot se ia din variabila de mediu `GODOT`, iar dacă nu e setată,
din cea scrisă în CLAUDE.md.
"""

import argparse
import os
import re
import subprocess
import sys
import zipfile
from pathlib import Path

# Consola Windows scrie implicit în cp1252, care nu are ă, ș, ț.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

PROIECT = Path(__file__).resolve().parent.parent

# Cele două build-uri web. Ce le deosebește e presetul, dosarul și dacă poartă
# eticheta — trei câmpuri, deci un RÂND. Dosarele sunt despărțite dinadins:
# verificările citesc `index.pck` din dosarul build-ului, iar cu un singur
# dosar al doilea export ar fi verificat pachetul primului.
BUILDURI = {
    "alergologie": {"preset": "Web", "dosar": "mindkeep_web", "eticheta": True},
    "public": {"preset": "Web public", "dosar": "mindkeep_web_public", "eticheta": False},
}

GODOT_IMPLICIT = Path(
    r"C:\Users\stefa\Downloads\Godot_v4.7.2-stable_win64.exe"
    r"\Godot_v4.7.2-stable_win64_console.exe"
)

PRESETURI = PROIECT / "export_presets.cfg"
ETICHETA = "alergologie"

# Fișierele fără de care jocul pornește, dar gol. Dacă lipsește oricare din
# pachet, filtrul `*.json` din preset nu mai prinde ce trebuie.
OBLIGATORII = [
    "data/intrebari_trivia.json",
    "data/fapte_trivia.json",
    "data/trivia_gen/",
]


def opreste(mesaj: str) -> None:
    print(f"\nOPRIT: {mesaj}", file=sys.stderr)
    sys.exit(1)


def verifica_presetul(preset: str, cu_eticheta: bool) -> None:
    """Oprește dacă presetul nu poartă eticheta `alergologie` — sau o poartă.

    `export_presets.cfg` e un fișier INI scris de Godot: secțiuni `[preset.N]`,
    fiecare cu `name=` și `custom_features=`. Se caută secțiunea cu numele
    presetului și se citește linia ei, fără să se presupună că e `preset.0`.
    """
    if not PRESETURI.exists():
        opreste(f"nu există {PRESETURI}. Presetul Web se face din editor: "
                "Project → Export → Add… → Web.")
    sectiuni = re.split(r"^\[preset\.\d+\]\s*$", PRESETURI.read_text(encoding="utf-8"),
                        flags=re.MULTILINE)
    for sectiune in sectiuni:
        if re.search(rf'^name="{re.escape(preset)}"\s*$', sectiune, re.MULTILINE):
            linie = re.search(r'^custom_features="(.*)"\s*$', sectiune, re.MULTILINE)
            etichete = [e.strip() for e in (linie.group(1) if linie else "").split(",")]
            are = ETICHETA in etichete
            if cu_eticheta and not are:
                opreste(f"presetul „{preset}” nu are eticheta `{ETICHETA}`, deci "
                        "build-ul n-ar avea Alergologia. Adaug-o în editor: "
                        "Project → Export → Web → Features → Custom.")
            if not cu_eticheta and are:
                opreste(f"presetul „{preset}” poartă eticheta `{ETICHETA}`, deci "
                        "build-ul ar avea Alergologia aprinsă. Scoate-o din "
                        "Project → Export → " + preset + " → Features → Custom.")
            return
    opreste(f"nu găsesc presetul „{preset}” în {PRESETURI}. Se face din editor: "
            "Project → Export → Add… → Web, cu numele exact.")


def arata_ce_nu_e_comis() -> None:
    rezultat = subprocess.run(["git", "status", "--short"], cwd=PROIECT,
                              capture_output=True, text=True)
    if rezultat.returncode != 0:
        return   # fără Git nu e o problemă de export
    linii = rezultat.stdout.rstrip()   # nu strip(): spațiul din „ M” contează
    if linii:
        print("Intră în build și ce nu e comis:")
        for linie in linii.splitlines():
            print(f"    {linie}")
    else:
        print("Totul e comis: build-ul e exact ce e în Git.")


def exporta(godot: Path, preset: str, iesire: Path) -> None:
    iesire.mkdir(exist_ok=True)
    pachet = iesire / "index.pck"
    inainte = pachet.stat().st_mtime if pachet.exists() else 0.0

    print(f"\nExport cu presetul „{preset}” în {iesire} ...")
    rezultat = subprocess.run(
        [str(godot), "--headless", "--path", str(PROIECT),
         "--export-release", preset, str(iesire / "index.html")],
        capture_output=True, text=True, encoding="utf-8", errors="replace")

    # Godot poate ieși cu 0 și după un export ratat, deci se judecă și după
    # urme: pachetul trebuie să fie NOU, nu cel rămas de data trecută.
    if rezultat.returncode != 0 or not pachet.exists() \
            or pachet.stat().st_mtime <= inainte:
        print(rezultat.stdout[-3000:])
        print(rezultat.stderr[-3000:], file=sys.stderr)
        opreste("exportul n-a scris un index.pck nou (ieșirea lui Godot e mai sus).")


def verifica_pachetul(iesire: Path, cu_eticheta: bool) -> None:
    continut = (iesire / "index.pck").read_bytes()
    # `alergologie.json` se cere doar la build-ul care o aprinde. La cel public
    # fișierul poate intra sau nu (filtrul `*.json` îl prinde oricum, iar 100 KB
    # nu se simt): fără etichetă nu-l citește nimeni. Deci nu se cere și nu se
    # interzice — poarta e ETICHETA, nu prezența datelor.
    cautate = OBLIGATORII + (["data/alergologie.json"] if cu_eticheta else [])
    lipsa = [cale for cale in cautate if cale.encode() not in continut]
    if lipsa:
        opreste("lipsesc din pachet: " + ", ".join(lipsa)
                + ". Verifică filtrul `*.json` din preset.")
    print(f"Pachetul are toate fișierele de date ({len(cautate)} verificate).")

    # Eticheta, așa cum o vede jocul: în setările exportate ale proiectului.
    # Proximitatea de `_custom_features` contează — numele `alergologie` apare
    # în pachet și ca parte din calea fișierului de date.
    poarta = re.search(rb"_custom_features.{0,16}" + ETICHETA.encode(), continut, re.DOTALL)
    if cu_eticheta and not poarta:
        opreste(f"pachetul nu poartă eticheta `{ETICHETA}`: Alergologia ar fi stinsă.")
    if not cu_eticheta and poarta:
        opreste(f"pachetul poartă eticheta `{ETICHETA}`: Alergologia ar fi aprinsă "
                "într-un build public.")
    if cu_eticheta:
        print(f"Pachetul poartă eticheta `{ETICHETA}`: Alergologia va fi aprinsă.")
    else:
        print(f"Pachetul NU poartă eticheta `{ETICHETA}`: Alergologia va fi stinsă.")


def arhiveaza(iesire: Path, arhiva: Path) -> None:
    fisiere = sorted(f for f in iesire.iterdir() if f.is_file())
    with zipfile.ZipFile(arhiva, "w", zipfile.ZIP_DEFLATED) as zip_:
        for fisier in fisiere:
            zip_.write(fisier, arcname=fisier.name)
    mb = arhiva.stat().st_size / (1024 * 1024)
    print(f"Arhiva: {arhiva} ({mb:.1f} MB, {len(fisiere)} fișiere).")


def main() -> None:
    argumente = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    argumente.add_argument("--public", action="store_true",
                           help="build FĂRĂ Alergologia (presetul „Web public”)")
    optiuni = argumente.parse_args()

    godot = Path(os.environ.get("GODOT", GODOT_IMPLICIT))
    if not godot.exists():
        opreste(f"nu găsesc Godot la {godot}. Setează variabila GODOT.")

    build = BUILDURI["public" if optiuni.public else "alergologie"]
    iesire = PROIECT.parent / build["dosar"]
    arhiva = PROIECT.parent / (build["dosar"] + ".zip")

    verifica_presetul(build["preset"], build["eticheta"])
    arata_ce_nu_e_comis()
    exporta(godot, build["preset"], iesire)
    verifica_pachetul(iesire, build["eticheta"])
    arhiveaza(iesire, arhiva)
    print("\nGata. Urcă zip-ul pe https://gyarados9.itch.io/mindkeep "
          "(Edit game → Uploads), cu „played in the browser” bifat.")


if __name__ == "__main__":
    main()

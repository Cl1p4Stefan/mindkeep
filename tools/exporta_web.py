#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""EXPORTĂ BUILD-UL WEB ȘI ÎL ÎMPACHETEAZĂ PENTRU ITCH.IO.

    python tools/exporta_web.py      export + zip

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

- ETICHETA `alergologie`. Build-ul de pe itch.io există ca să joace cineva
  Alergologia, iar secțiunea se aprinde doar dacă jocul a fost exportat cu
  eticheta asta în Custom Features (vezi `ALERGOLOGIE` din
  `scenes/trivia/trivia.gd`). Fără ea, zip-ul ar avea un joc din care
  secțiunea ei a dispărut, fără niciun semn. Se verifică de DOUĂ ori: în
  presetul din `export_presets.cfg` înainte de export, și în pachetul ieșit
  după (Godot o scrie în `project.binary`, ca `_custom_features`).
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
IESIRE = PROIECT.parent / "mindkeep_web"
ARHIVA = PROIECT.parent / "mindkeep_web.zip"
PRESET = "Web"

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


def presetul_are_eticheta() -> None:
    """Oprește dacă presetul „Web” nu poartă eticheta `alergologie`.

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
        if re.search(rf'^name="{PRESET}"\s*$', sectiune, re.MULTILINE):
            linie = re.search(r'^custom_features="(.*)"\s*$', sectiune, re.MULTILINE)
            etichete = [e.strip() for e in (linie.group(1) if linie else "").split(",")]
            if ETICHETA not in etichete:
                opreste(f"presetul „{PRESET}” nu are eticheta `{ETICHETA}`, deci "
                        "build-ul n-ar avea Alergologia. Adaug-o în editor: "
                        "Project → Export → Web → Features → Custom.")
            return
    opreste(f"nu găsesc presetul „{PRESET}” în {PRESETURI}.")


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


def exporta(godot: Path) -> None:
    IESIRE.mkdir(exist_ok=True)
    pachet = IESIRE / "index.pck"
    inainte = pachet.stat().st_mtime if pachet.exists() else 0.0

    print(f"\nExport cu presetul „{PRESET}” în {IESIRE} ...")
    rezultat = subprocess.run(
        [str(godot), "--headless", "--path", str(PROIECT),
         "--export-release", PRESET, str(IESIRE / "index.html")],
        capture_output=True, text=True, encoding="utf-8", errors="replace")

    # Godot poate ieși cu 0 și după un export ratat, deci se judecă și după
    # urme: pachetul trebuie să fie NOU, nu cel rămas de data trecută.
    if rezultat.returncode != 0 or not pachet.exists() \
            or pachet.stat().st_mtime <= inainte:
        print(rezultat.stdout[-3000:])
        print(rezultat.stderr[-3000:], file=sys.stderr)
        opreste("exportul n-a scris un index.pck nou (ieșirea lui Godot e mai sus).")


def verifica_pachetul() -> None:
    continut = (IESIRE / "index.pck").read_bytes()
    cautate = OBLIGATORII + ["data/alergologie.json"]
    lipsa = [cale for cale in cautate if cale.encode() not in continut]
    if lipsa:
        opreste("lipsesc din pachet: " + ", ".join(lipsa)
                + ". Verifică filtrul `*.json` din presetul Web.")
    print(f"Pachetul are toate fișierele de date ({len(cautate)} verificate).")

    # Eticheta, așa cum o vede jocul: în setările exportate ale proiectului.
    if not re.search(rb"_custom_features.{0,16}" + ETICHETA.encode(), continut, re.DOTALL):
        opreste(f"pachetul nu poartă eticheta `{ETICHETA}`: Alergologia ar fi stinsă.")
    print(f"Pachetul poartă eticheta `{ETICHETA}`: Alergologia va fi aprinsă.")


def arhiveaza() -> None:
    fisiere = sorted(f for f in IESIRE.iterdir() if f.is_file())
    with zipfile.ZipFile(ARHIVA, "w", zipfile.ZIP_DEFLATED) as zip_:
        for fisier in fisiere:
            zip_.write(fisier, arcname=fisier.name)
    mb = ARHIVA.stat().st_size / (1024 * 1024)
    print(f"Arhiva: {ARHIVA} ({mb:.1f} MB, {len(fisiere)} fișiere).")


def main() -> None:
    argumente = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    argumente.parse_args()

    godot = Path(os.environ.get("GODOT", GODOT_IMPLICIT))
    if not godot.exists():
        opreste(f"nu găsesc Godot la {godot}. Setează variabila GODOT.")

    presetul_are_eticheta()
    arata_ce_nu_e_comis()
    exporta(godot)
    verifica_pachetul()
    arhiveaza()
    print("\nGata. Urcă zip-ul pe https://gyarados9.itch.io/mindkeep "
          "(Edit game → Uploads), cu „played in the browser” bifat.")


if __name__ == "__main__":
    main()

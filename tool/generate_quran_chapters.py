"""TASK 034B - Tanzil resmi quran-data.xml'den dogrulanmis sure katalogu JSON'u uretir.

Girdi : tool/quran_source/quran-data.xml (Tanzil Quran Metadata 1.0)
Cikti : bismillah_app/assets/quran/chapters_v1.json (deterministik)

Yalniz Python standart kutuphanesi kullanilir. Kaynakta olmayan veri URETILMEZ.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XML_PATH = ROOT / "quran_source" / "quran-data.xml"
OUT_PATH = ROOT.parent / "bismillah_app" / "assets" / "quran" / "chapters_v1.json"

PLACE_MAP = {"Meccan": "meccan", "Medinan": "medinan"}
TOTAL_VERSES = 6236


def main() -> None:
    suras = ET.parse(XML_PATH).getroot().findall("./suras/sura")

    chapters = []
    for sura in suras:
        place = sura.get("type")
        if place not in PLACE_MAP:
            raise SystemExit(f"Taninmayan nuzul turu: {place!r}")
        chapters.append(
            {
                "id": int(sura.get("index")),
                "arabicName": sura.get("name"),
                "transliteratedName": sura.get("tname"),
                "englishName": sura.get("ename"),
                "verseCount": int(sura.get("ayas")),
                "revelationPlace": PLACE_MAP[place],
                "revelationOrder": int(sura.get("order")),
                "startVerseIndex": int(sura.get("start")),
                "rukuCount": int(sura.get("rukus")),
            }
        )

    # Dogrulamalar (bozuk kaynak sessizce gecmez).
    if len(chapters) != 114:
        raise SystemExit(f"114 sure bekleniyordu: {len(chapters)}")
    ids = [c["id"] for c in chapters]
    if sorted(ids) != list(range(1, 115)):
        raise SystemExit("id degerleri benzersiz ve 1-114 araliginda olmali")
    if sum(c["verseCount"] for c in chapters) != TOTAL_VERSES:
        raise SystemExit("toplam ayet sayisi 6236 olmali")
    for c in chapters:
        if c["verseCount"] <= 0:
            raise SystemExit(f"sure {c['id']}: verseCount pozitif olmali")
        if c["revelationOrder"] <= 0 or c["rukuCount"] <= 0:
            raise SystemExit(f"sure {c['id']}: order/ruku pozitif olmali")
        if c["startVerseIndex"] < 0:
            raise SystemExit(f"sure {c['id']}: startVerseIndex negatif olamaz")
        for key in ("arabicName", "transliteratedName", "englishName"):
            if not (c[key] or "").strip():
                raise SystemExit(f"sure {c['id']}: {key} bos olamaz")

    # Deterministik cikti: id sirasi + sirali anahtarlar + sabit bicim.
    chapters.sort(key=lambda c: c["id"])
    payload = {
        "source": "Tanzil Project - Quran Metadata 1.0",
        "sourceUrl": "https://tanzil.net/docs/quran_metadata",
        "generator": "tool/generate_quran_chapters.py",
        "chapters": chapters,
    }
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print("114 chapters generated")


if __name__ == "__main__":
    main()

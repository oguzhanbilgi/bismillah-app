"""TASK 035 - Tanzil Uthmani metninden dogrulanmis ayet JSON'u uretir.

Girdi : tool/quran_source/quran-uthmani.xml (Tanzil Quran Text, Uthmani 1.1)
Cikti : bismillah_app/assets/quran/verses_uthmani_v1.json (deterministik)

Yalniz Python standart kutuphanesi kullanilir. Metin AYNEN korunur:
normalizasyon yok, hareke/isaret kaldirma yok, otomatik duzeltme yok,
Besmele ekleme/cikarma yok — yalniz bas/son whitespace kirpilir.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XML_PATH = ROOT / "quran_source" / "quran-uthmani.xml"
CHAPTERS_PATH = ROOT.parent / "bismillah_app" / "assets" / "quran" / "chapters_v1.json"
OUT_PATH = (
    ROOT.parent / "bismillah_app" / "assets" / "quran" / "verses_uthmani_v1.json"
)

TOTAL_VERSES = 6236


def main() -> None:
    expected_counts = {
        c["id"]: c["verseCount"]
        for c in json.loads(CHAPTERS_PATH.read_text(encoding="utf-8"))["chapters"]
    }
    if len(expected_counts) != 114:
        raise SystemExit("chapters_v1.json 114 sure icermeli")

    suras = ET.parse(XML_PATH).getroot().findall("./sura")
    if len(suras) != 114:
        raise SystemExit(f"114 sure bekleniyordu: {len(suras)}")

    verses = []
    seen_keys = set()
    for sura in suras:
        chapter_id = int(sura.get("index"))
        if not 1 <= chapter_id <= 114:
            raise SystemExit(f"gecersiz sure numarasi: {chapter_id}")
        ayas = sura.findall("./aya")
        if len(ayas) != expected_counts[chapter_id]:
            raise SystemExit(
                f"sure {chapter_id}: ayet sayisi katalogla eslesmiyor "
                f"({len(ayas)} != {expected_counts[chapter_id]})"
            )
        for position, aya in enumerate(ayas, start=1):
            verse_number = int(aya.get("index"))
            if verse_number != position:
                raise SystemExit(
                    f"sure {chapter_id}: ayet numaralari kesintisiz degil "
                    f"(beklenen {position}, bulunan {verse_number})"
                )
            # Metin AYNEN korunur; yalniz bas/son whitespace kirpilir.
            text = (aya.get("text") or "").strip()
            if not text:
                raise SystemExit(f"sure {chapter_id} ayet {verse_number}: metin bos")
            verse_key = f"{chapter_id}:{verse_number}"
            if verse_key in seen_keys:
                raise SystemExit(f"duplicate verseKey: {verse_key}")
            seen_keys.add(verse_key)
            verses.append(
                {
                    "chapterId": chapter_id,
                    "verseNumber": verse_number,
                    "verseKey": verse_key,
                    "textUthmani": text,
                }
            )

    if len(verses) != TOTAL_VERSES:
        raise SystemExit(f"{TOTAL_VERSES} ayet bekleniyordu: {len(verses)}")

    # Deterministik cikti: sure+ayet sirasi, sirali anahtarlar, sabit bicim.
    verses.sort(key=lambda v: (v["chapterId"], v["verseNumber"]))
    payload = {
        "source": "Tanzil Project - Quran Text (Uthmani), Version 1.1",
        "sourceUrl": "https://tanzil.net",
        "license": "Creative Commons Attribution 3.0",
        "generator": "tool/generate_quran_verses.py",
        "verses": verses,
    }
    OUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"{len(verses)} verses generated")


if __name__ == "__main__":
    main()

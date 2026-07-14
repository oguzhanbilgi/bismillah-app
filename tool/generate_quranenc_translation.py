"""CHECKPOINT 06 Recovery - QuranEnc resmi XML'inden offline Turkce meal JSON'u uretir.

Girdi : tool/quran_source/quranenc_turkish_rwwad.xml (QuranEnc.com, turkish_rwwad V1.0.4)
Cikti : bismillah_app/assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json

Yalniz Python standart kutuphanesi. Meal metni ve dipnotlar VERBATIM korunur:
degistirme, duzeltme, sadelestirme, ozetleme, yeniden noktalama, AI isleme YOK.
API tokeni/secret KULLANILMAZ.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XML_PATH = ROOT / "quran_source" / "quranenc_turkish_rwwad.xml"
CHAPTERS_PATH = ROOT.parent / "bismillah_app" / "assets" / "quran" / "chapters_v1.json"
OUT_PATH = (
    ROOT.parent
    / "bismillah_app"
    / "assets"
    / "quran"
    / "translations"
    / "quranenc_turkish_rwwad_v1_0_4.json"
)

TOTAL_VERSES = 6236
EXPECTED_VERSION_TAG = "v1.0.4"


def main() -> None:
    expected_counts = {
        c["id"]: c["verseCount"]
        for c in json.loads(CHAPTERS_PATH.read_text(encoding="utf-8"))["chapters"]
    }
    if len(expected_counts) != 114:
        raise SystemExit("chapters_v1.json 114 sure icermeli")

    root = ET.parse(XML_PATH).getroot()
    meta = root.find("meta")
    if meta is None:
        raise SystemExit("meta blogu bulunamadi")
    source_version = (meta.findtext("updated_at") or "").strip()
    if EXPECTED_VERSION_TAG not in source_version:
        raise SystemExit(f"beklenen surum {EXPECTED_VERSION_TAG} degil: {source_version!r}")
    if (meta.findtext("id") or "").strip() != "turkish_rwwad":
        raise SystemExit("beklenen tercume anahtari turkish_rwwad degil")

    suras = root.findall("./sura_list/sura")
    if len(suras) != 114:
        raise SystemExit(f"114 sure bekleniyordu: {len(suras)}")

    verses = []
    for sura in suras:
        chapter_id = int(sura.get("number"))
        if not 1 <= chapter_id <= 114:
            raise SystemExit(f"gecersiz sure numarasi: {chapter_id}")
        ayas = sura.findall("./aya")
        if len(ayas) != expected_counts[chapter_id]:
            raise SystemExit(
                f"sure {chapter_id}: ayet sayisi Tanzil katalogla eslesmiyor "
                f"({len(ayas)} != {expected_counts[chapter_id]})"
            )
        seen = set()
        for position, aya in enumerate(ayas, start=1):
            verse_number = int(aya.get("number"))
            if verse_number != position:
                raise SystemExit(
                    f"sure {chapter_id}: ayet numaralari kesintisiz degil "
                    f"(beklenen {position}, bulunan {verse_number})"
                )
            if verse_number in seen:
                raise SystemExit(f"duplicate ayet: {chapter_id}:{verse_number}")
            seen.add(verse_number)
            # Metin VERBATIM saklanir; yalniz bos-olmama dogrulamasi yapilir.
            translation = aya.findtext("translation") or ""
            if not translation.strip():
                raise SystemExit(f"bos meal: {chapter_id}:{verse_number}")
            footnotes = aya.findtext("footnotes") or ""
            verses.append(
                {
                    "chapterId": chapter_id,
                    "verseNumber": verse_number,
                    "verseKey": f"{chapter_id}:{verse_number}",
                    "translationText": translation,
                    "footnotes": footnotes,
                }
            )

    if len(verses) != TOTAL_VERSES:
        raise SystemExit(f"{TOTAL_VERSES} ayet bekleniyordu: {len(verses)}")

    payload = {
        "metadata": {
            "source": "QuranEnc.com",
            "publisher": "Rowad Tercüme Merkezi",
            "translationName": "Türkçe Tercüme — Rowad Tercüme Merkezi",
            "translationKey": "turkish_rwwad",
            "version": "V1.0.4",
            "sourceVersion": source_version,
            "sourceUrl": "https://quranenc.com/tr/browse/turkish_rwwad",
            "generator": "tool/generate_quranenc_translation.py",
        },
        "verses": verses,
    }
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"{len(verses)} verses generated")


if __name__ == "__main__":
    main()

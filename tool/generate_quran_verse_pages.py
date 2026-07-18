"""TASK 047 - Tanzil resmi quran-data.xml'den ayet -> Mushaf sayfasi eslemesi uretir.

Girdi : tool/quran_source/quran-data.xml (Tanzil Quran Metadata 1.0, <pages>)
Cikti : bismillah_app/assets/quran/verse_pages_v1.json (deterministik)

Yalniz Python standart kutuphanesi kullanilir. Kaynakta olmayan veri URETILMEZ:
sayfa sinirlari Tanzil'in dogrulanmis 604 sayfalik Medine Mushafi verisidir;
formul/tahminle sayfa uretilmez.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XML_PATH = ROOT / "quran_source" / "quran-data.xml"
OUT_PATH = ROOT.parent / "bismillah_app" / "assets" / "quran" / "verse_pages_v1.json"

TOTAL_VERSES = 6236
TOTAL_PAGES = 604
TOTAL_SURAS = 114


def main() -> None:
    root = ET.parse(XML_PATH).getroot()

    suras = root.findall("./suras/sura")
    if len(suras) != TOTAL_SURAS:
        raise SystemExit(f"114 sure bekleniyordu: {len(suras)}")
    verse_counts = {int(s.get("index")): int(s.get("ayas")) for s in suras}
    if sum(verse_counts.values()) != TOTAL_VERSES:
        raise SystemExit("toplam ayet sayisi 6236 olmali")

    # Global ayet sirasi (sure, ayet) -> 0 tabanli indeks.
    global_index: dict[tuple[int, int], int] = {}
    ordered_keys: list[tuple[int, int]] = []
    for sura_id in range(1, TOTAL_SURAS + 1):
        for aya in range(1, verse_counts[sura_id] + 1):
            global_index[(sura_id, aya)] = len(ordered_keys)
            ordered_keys.append((sura_id, aya))

    pages = root.findall("./pages/page")
    if len(pages) != TOTAL_PAGES:
        raise SystemExit(f"604 sayfa bekleniyordu: {len(pages)}")

    starts: list[tuple[int, int]] = []  # (global_start_index, page_no)
    seen_pages: set[int] = set()
    for page in pages:
        page_no = int(page.get("index"))
        sura = int(page.get("sura"))
        aya = int(page.get("aya"))
        if page_no in seen_pages:
            raise SystemExit(f"sayfa {page_no}: duplicate sayfa numarasi")
        seen_pages.add(page_no)
        if (sura, aya) not in global_index:
            raise SystemExit(f"sayfa {page_no}: gecersiz baslangic {sura}:{aya}")
        starts.append((global_index[(sura, aya)], page_no))
    if seen_pages != set(range(1, TOTAL_PAGES + 1)):
        raise SystemExit("sayfa numaralari kesintisiz 1-604 olmali")

    starts.sort(key=lambda item: item[1])
    if starts[0][0] != 0:
        raise SystemExit("1. sayfa 1:1 ile baslamali")
    for (prev_start, prev_no), (cur_start, cur_no) in zip(starts, starts[1:]):
        if cur_start <= prev_start:
            raise SystemExit(
                f"sayfa {cur_no}: baslangic, sayfa {prev_no} icinden once/aynisi"
            )

    # Her ayete sayfa ata: [start_n, start_n+1) araligi sayfa n'dir.
    verse_key_to_page: dict[str, int] = {}
    bounds = starts + [(TOTAL_VERSES, TOTAL_PAGES + 1)]
    for (start, page_no), (next_start, _) in zip(bounds, bounds[1:]):
        for idx in range(start, next_start):
            sura, aya = ordered_keys[idx]
            verse_key_to_page[f"{sura}:{aya}"] = page_no

    # Butunluk: eksiksiz 6236 ayet, 1-604 disinda sayfa yok, bos sayfa yok.
    if len(verse_key_to_page) != TOTAL_VERSES:
        raise SystemExit(f"6236 esleme bekleniyordu: {len(verse_key_to_page)}")
    if set(verse_key_to_page.values()) != set(range(1, TOTAL_PAGES + 1)):
        raise SystemExit("her sayfa 1-604 araliginda en az bir ayet icermeli")
    for sura_id in range(1, TOTAL_SURAS + 1):
        for aya in range(1, verse_counts[sura_id] + 1):
            if f"{sura_id}:{aya}" not in verse_key_to_page:
                raise SystemExit(f"eksik ayet: {sura_id}:{aya}")

    payload = {
        "source": "Tanzil Project - Quran Metadata 1.0 (Madani pages)",
        "sourceUrl": "https://tanzil.net/docs/quran_metadata",
        "generator": "tool/generate_quran_verse_pages.py",
        "pageCount": TOTAL_PAGES,
        "verseCount": TOTAL_VERSES,
        "verseKeyToPage": verse_key_to_page,
    }
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"{len(verse_key_to_page)} verse->page mappings generated")


if __name__ == "__main__":
    main()

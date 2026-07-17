"""TASK 048 - Dogrulanmis bundled asset'lerden offline Kur'an arama indeksi uretir.

Girdi : bismillah_app/assets/quran/chapters_v1.json
        bismillah_app/assets/quran/verses_uthmani_v1.json
        bismillah_app/assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json
Cikti : bismillah_app/assets/quran/search/quran_search_index_v1.json (deterministik)

Yalniz Python standart kutuphanesi kullanilir; ag erisimi YOKTUR. Indeks yalniz
ESLESTIRME icin normalize edilmis degerler ve referanslar icerir — orijinal
Tanzil/QuranEnc metinleri runtime'da mevcut asset depolarindan okunur ve ASLA
degistirilmez. Cikti yalniz TUM butunluk kontrolleri gectikten sonra yazilir.

Dart tarafindaki sorgu normalizasyonu (BundledQuranSearchRepository) bu
dosyadaki kurallarla birebir aynidir — degisiklikler iki tarafta birden yapilmali.
"""

from __future__ import annotations

import hashlib
import json
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent
APP_ASSETS = ROOT.parent / "bismillah_app" / "assets" / "quran"
CHAPTERS_PATH = APP_ASSETS / "chapters_v1.json"
VERSES_PATH = APP_ASSETS / "verses_uthmani_v1.json"
TRANSLATION_PATH = (
    APP_ASSETS / "translations" / "quranenc_turkish_rwwad_v1_0_4.json"
)
OUT_PATH = APP_ASSETS / "search" / "quran_search_index_v1.json"

TOTAL_VERSES = 6236
TOTAL_SURAS = 114

# Translit sure adlarindaki Arapca "el-" artikel varyantlari (alias uretimi).
ARTICLE_TOKENS = {
    "al", "an", "as", "ash", "ad", "adh", "ar", "az", "at", "ath", "el",
}

# Sinirli, dogrulanmis ayet referans alias'lari (TASK 049 §0): yalniz
# arama/navigasyon yardimcisidir; ayet/meal metnine EKLENMEZ, genel dini
# lakap listesi URETILMEZ. Alias'lar normalize edilmis halde tutulur ve
# runtime repository ayni sozlesmeyi okur.
REFERENCE_ALIASES = [
    {
        "aliases": [
            "ayetel kursi",
            "ayet el kursi",
            "ayetul kursi",
            "ayatul kursi",
            "ayat al kursi",
        ],
        "chapterId": 2,
        "verseNumber": 255,
    },
]

ARABIC_LETTER_FOLDS = [
    ("أ", "ا"),  # hemzeli elif -> elif
    ("إ", "ا"),
    ("آ", "ا"),  # medli elif -> elif
    ("ٱ", "ا"),  # vasla elif -> elif
    ("ؤ", "و"),  # vav uzeri hemze -> vav
    ("ئ", "ي"),  # ye uzeri hemze -> ye
    ("ء", ""),        # tek hemze kaldirilir
    ("ى", "ي"),  # elif maksura -> ye
    ("ة", "ه"),  # te merbuta -> he
]


def normalize_turkish(text: str) -> str:
    """Yalniz ESLESTIRME icin: kucuk harf, aksan/sapka katlama, i/ı birlestirme,
    noktalama -> bosluk, bosluk sadelestirme. Gorunen metin DEGISTIRILMEZ."""
    text = text.replace("İ", "i").replace("I", "i")
    text = text.lower().replace("ı", "i")
    text = unicodedata.normalize("NFD", text)
    out = []
    for ch in text:
        cat = unicodedata.category(ch)
        if cat == "Mn":
            continue  # sapka/sedil/aksan isaretleri (â->a, ş->s, ç->c ...)
        if cat.startswith("P") or cat.startswith("S"):
            out.append(" ")
        else:
            out.append(ch)
    return " ".join("".join(out).split())


def normalize_arabic(text: str) -> str:
    """Yalniz ESLESTIRME icin: hareke/Kur'an isaretleri ve tatweel kaldirma,
    elif/hemze/ye varyant katlama. Uthmani metin DEGISTIRILMEZ."""
    out = []
    for ch in text:
        cat = unicodedata.category(ch)
        if cat == "Mn" or ch == "ـ":
            continue  # harekeler, kucuk isaretler, tatweel
        if cat.startswith("P") or cat.startswith("S") or cat == "Cf":
            out.append(" ")  # ayet/durak isaretleri arama ayiraci olur
        else:
            out.append(ch)
    text = "".join(out)
    for src, dst in ARABIC_LETTER_FOLDS:
        text = text.replace(src, dst)
    return " ".join(text.split())


def collapse_transliteration(value: str) -> str:
    """Translit uzun unlu/karakterlerini Turkce yazima yaklastirir
    (Faatiha->fatiha, Yaseen->yasin, Baqara->bakara). Deterministik kural —
    elle dini lakap listesi ICAT EDILMEZ."""
    return (
        value.replace("aa", "a")
        .replace("ee", "i")
        .replace("oo", "u")
        .replace("q", "k")
    )


def chapter_aliases(chapter: dict) -> list[str]:
    """Dogrulanmis mevcut adlardan otomatik normalize alias kumesi."""
    aliases: set[str] = set()
    for base in (
        normalize_turkish(chapter["transliteratedName"]),
        normalize_turkish(chapter["englishName"]),
    ):
        for variant in (base, collapse_transliteration(base)):
            if not variant:
                continue
            aliases.add(variant)
            tokens = variant.split(" ")
            if len(tokens) > 1 and tokens[0] in ARTICLE_TOKENS:
                aliases.add(" ".join(tokens[1:]))
    arabic = normalize_arabic(chapter["arabicName"])
    if arabic:
        aliases.add(arabic)
        # "surat" on eki olmadan da aransin (سورة الفاتحة -> الفاتحة).
        tokens = arabic.split(" ")
        if len(tokens) > 1 and tokens[0] in ("سوره",):
            aliases.add(" ".join(tokens[1:]))
    return sorted(a for a in aliases if a)


def main() -> None:
    chapters = json.loads(CHAPTERS_PATH.read_text(encoding="utf-8"))["chapters"]
    verses = json.loads(VERSES_PATH.read_text(encoding="utf-8"))["verses"]
    translations = json.loads(TRANSLATION_PATH.read_text(encoding="utf-8"))[
        "verses"
    ]

    if len(chapters) != TOTAL_SURAS:
        raise SystemExit(f"114 sure bekleniyordu: {len(chapters)}")
    if len(verses) != TOTAL_VERSES:
        raise SystemExit(f"6236 ayet bekleniyordu: {len(verses)}")
    if len(translations) != TOTAL_VERSES:
        raise SystemExit(f"6236 meal ayeti bekleniyordu: {len(translations)}")

    verse_counts = {c["id"]: c["verseCount"] for c in chapters}
    if sum(verse_counts.values()) != TOTAL_VERSES:
        raise SystemExit("sure ayet sayilari toplami 6236 olmali")

    translation_by_key = {t["verseKey"]: t["translationText"] for t in translations}
    if len(translation_by_key) != TOTAL_VERSES:
        raise SystemExit("meal verseKey degerleri tekil olmali")

    index_chapters = []
    for chapter in sorted(chapters, key=lambda c: c["id"]):
        aliases = chapter_aliases(chapter)
        if not aliases:
            raise SystemExit(f"sure {chapter['id']}: alias uretilemedi")
        index_chapters.append(
            {
                "id": chapter["id"],
                "verseCount": chapter["verseCount"],
                "aliases": aliases,
            }
        )

    index_verses = []
    seen_keys: set[str] = set()
    for verse in verses:
        key = verse["verseKey"]
        if key in seen_keys:
            raise SystemExit(f"duplicate verseKey: {key}")
        seen_keys.add(key)
        translation = translation_by_key.get(key)
        if translation is None:
            raise SystemExit(f"eksik meal: {key}")
        norm_arabic = normalize_arabic(verse["textUthmani"])
        norm_turkish = normalize_turkish(translation)
        if not norm_arabic:
            raise SystemExit(f"bos normalize Arapca: {key}")
        if not norm_turkish:
            raise SystemExit(f"bos normalize meal: {key}")
        index_verses.append(
            {
                "k": key,
                "c": verse["chapterId"],
                "v": verse["verseNumber"],
                "a": norm_arabic,
                "t": norm_turkish,
            }
        )

    for chapter_id, count in verse_counts.items():
        actual = sum(1 for v in index_verses if v["c"] == chapter_id)
        if actual != count:
            raise SystemExit(
                f"sure {chapter_id}: ayet sayisi Tanzil ile eslesmiyor"
            )

    # Referans alias dogrulamalari: hedef gercek bir ayet olmali, alias'lar
    # normalize bicimde ve tekil olmali.
    seen_aliases: set[str] = set()
    for entry in REFERENCE_ALIASES:
        chapter_id = entry["chapterId"]
        verse_number = entry["verseNumber"]
        if not 1 <= verse_number <= verse_counts.get(chapter_id, 0):
            raise SystemExit(f"alias hedefi gecersiz: {chapter_id}:{verse_number}")
        for alias in entry["aliases"]:
            if alias != normalize_turkish(alias):
                raise SystemExit(f"alias normalize degil: {alias!r}")
            if alias in seen_aliases:
                raise SystemExit(f"duplicate referans alias: {alias!r}")
            seen_aliases.add(alias)

    payload = {
        "schemaVersion": 1,
        "source": {
            "arabic": "Tanzil Quran Text (Uthmani, v1.1)",
            "translation": "QuranEnc.com - Rowad (turkish_rwwad V1.0.4)",
            "generator": "tool/generate_quran_search_index.py",
            "note": "Yalniz eslestirme degerleri; gosterim metni asil "
            "asset'lerden okunur.",
        },
        "chapters": index_chapters,
        "referenceAliases": REFERENCE_ALIASES,
        "verses": index_verses,
    }
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    encoded = (
        json.dumps(payload, ensure_ascii=False, indent=1, sort_keys=True) + "\n"
    )
    OUT_PATH.write_text(encoded, encoding="utf-8", newline="\n")
    digest = hashlib.sha256(encoded.encode("utf-8")).hexdigest()
    size_kb = OUT_PATH.stat().st_size / 1024
    print(
        f"index ok: {len(index_chapters)} chapters, {len(index_verses)} verses, "
        f"{size_kb:.0f} KiB, sha256={digest[:16]}..."
    )


if __name__ == "__main__":
    main()

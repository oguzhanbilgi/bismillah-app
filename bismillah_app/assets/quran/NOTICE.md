# Quran Metadata Notice

- Metadata source: Tanzil Project
- Source version: Quran Metadata 1.0
- Generated catalog: `chapters_v1.json`
- Bu katalog `tool/generate_quran_chapters.py` ile otomatik üretildi ve
  elle değiştirilmedi (üretim doğrulaması: 114 sure, toplam 6236 ayet).
- Source URL: https://tanzil.net/docs/quran_metadata

# Turkish Translation Notice

- Translation source: QuranEnc.com
- Publisher: Rowad Tercüme Merkezi
- Translation name: Türkçe Tercüme — Rowad Tercüme Merkezi
- Translation key: `turkish_rwwad`
- Version: V1.0.4 (kaynak sürüm damgası: `v1.0.4-xml.1`, 2025-09-28)
- Generated asset: `translations/quranenc_turkish_rwwad_v1_0_4.json`
- Metin ve dipnotlar DEĞİŞTİRİLMEDEN kullanıldı:
  `tool/generate_quranenc_translation.py` yalnız doğrular ve JSON'a
  aktarır — düzeltme, sadeleştirme, yeniden noktalama veya AI işleme
  YAPILMAZ (üretim doğrulaması: 114 sure, toplam 6236 ayet, Tanzil
  katalogla eşleşen ayet sayıları).
- Source URL: https://quranenc.com/tr/browse/turkish_rwwad

## Yeniden yayımlama izni (resmî, erişim tarihi 2026-08-04)

QuranEnc'in site genelindeki "Terms and Policies" bölümü şunu belirtir:
"Contents of the translations can be downloaded and re-published, with the
following terms and conditions:" ardından **yedi koşul** gelir:
1. İçerikte değişiklik, ekleme veya çıkarma yapılmaması.
2. Yayıncıya ve kaynağa (QuranEnc.com) açıkça atıf yapılması.
3. Yeniden yayımlarken sürüm numarasının belirtilmesi.
4. Transcript/sürüm bilgisinin belge içinde korunması.
5. Tercümeye dair her türlü notun kaynağa bildirilmesi.
6. Kaynağın yayımladığı en son sürüme güncellenmesi.
7. Tercüme gösterilirken uygunsuz reklam bulundurulmaması.

Aynı metin şu resmî sayfalarda yer alır: https://quranenc.com/en/home ·
https://quranenc.com/en/home/about · https://quranenc.com/en/home/api

- Bu dağıtımda 1, 2, 3, 4 ve 7 numaralı koşullar SAĞLANIR; 6 numaralı koşul
  SÜREKLİ bir yükümlülüktür (bkz. sürüm doğrulaması aşağıda).
- **Ticari/freemium yeniden yayım bu koşullarda AÇIKÇA ELE ALINMAMIŞTIR** —
  ne izin verilmiş ne yasaklanmıştır; buradan ticari izin ÇIKARILMAZ.
  Kapalı alfa ÜCRETSİZDİR; tercüme satılmaz ve ödeme arkasına konmaz.

## Tam korpus doğrulaması (TASK 097B-B, 2026-08-04)

- Karşılaştırma kaynağı: resmî veri kümesi
  https://quranenc.com/downloads/sqlite/turkish_rwwad.sqlite
- Yöntem: **normalizasyon, kırpma veya boşluk sadeleştirmesi YAPILMADAN**
  tam Unicode kod-noktası karşılaştırması.
- Sonuç: **6236 / 6236 meal metni birebir aynı**, **6236 / 6236 dipnot
  birebir aynı**; eksik, fazla veya yinelenen ayet YOK; her iki taraf da
  kanonik 6236 ayet anahtarını taşır ve 29 dolu dipnot içerir.
- Sürüm kimliği: resmî kayıt `version 1.0.4`, `last_update 1759071052`
  (2025-09-28 14:50:52 UTC) — pakete gömülü `2025-09-28 17:50:52
  (v1.0.4-xml.1)` damgasıyla UTC+3'te aynı andır.

# Quran Text Notice

- Quran text source: Tanzil Project
- Text type: Uthmani
- Source version: Tanzil Quran Text version 1.1
- License: Creative Commons Attribution 3.0
- Generated asset: `verses_uthmani_v1.json`
- Metin değiştirilmeden kullanıldı: `tool/generate_quran_verses.py`
  yalnız doğrular ve JSON'a aktarır — normalizasyon, hareke/işaret
  kaldırma, otomatik düzeltme veya Besmele ekleme/çıkarma YAPILMAZ
  (üretim doğrulaması: 114 sure, toplam 6236 ayet, katalogla eşleşen
  ayet sayıları).
- Source URL: https://tanzil.net

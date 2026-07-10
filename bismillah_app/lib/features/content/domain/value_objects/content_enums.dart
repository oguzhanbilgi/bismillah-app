/// İçerik katmanı enum'ları (10_DATA_MODEL §20).
library;

/// Kutsal/editoryal içerik tipleri.
///
/// BİLİNÇLİ karar: `aiExplanation` bu enum'da YOKTUR — AI metni kutsal
/// içerik tipiyle temsil EDİLEMEZ (hiçbir katmanda; §20 bağlayıcı kural).
/// AI çıktısı ayrı `AiExplanation` tipidir ve içerik ağacına yazılmaz.
enum SacredContentType { quran, hadith, dua, dhikr, scholarlyNote, reflection }

/// İçerik yayın durumu — istemci YALNIZ `published` tüketir
/// (sorgu filtresi + rules + mapper üçlü savunması).
enum ContentStatus { draft, inReview, published, retracted }

/// Hadis derecesi. Derecesiz hadis YAYINLANAMAZ (10_DATA_MODEL §20) —
/// bu yüzden hadis tiplerinde alan nullable değildir.
enum HadithGrading { sahih, hasan, daif }

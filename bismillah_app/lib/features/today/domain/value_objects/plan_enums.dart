/// Günlük plan enum'ları (10_DATA_MODEL §4 `PlanItem`).
library;

/// Plan içi eylem tipi.
enum PlanItemType { prayer, quran, dhikr, dua, lesson, reflection }

/// Plan öğesi durumu. "Kaçırıldı/başarısız" durumu BİLİNÇLİ olarak
/// yoktur — tamamlanmayan öğe yalnız `pending` kalır; suçlayıcı durum
/// modeli yasak (CLAUDE.md ton kuralları).
enum PlanItemStatus { pending, completed }

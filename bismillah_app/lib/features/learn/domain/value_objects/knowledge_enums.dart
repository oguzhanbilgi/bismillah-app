/// Bilgi tabanı değer nesneleri (TASK 056).
///
/// Enum `name` değerleri JSON asset'lerinde ve SharedPreferences'ta STABİL
/// anahtar olarak kullanılır — yeniden adlandırmak veri bozar.
library;

/// Doğrulanmış kaynağın türü. Kullanıcıya gösterilen etiket
/// localization'dan gelir; bu enum teknik tanımlayıcıdır.
enum KnowledgeSourceType {
  ilmihal,
  quranTafsir,
  hadithCollection,
  fatwa,
  officialAnswer,
  officialPublication,
}

/// İçeriğin yayın/denetim durumu.
///
/// Uygulamada YALNIZ [published] görünür — diğerleri depo katmanında
/// filtrelenir (TASK 056 §3).
enum ReviewStatus {
  /// Taslak: kaynak doğrulanmamış veya içerik tamamlanmamış.
  draft,

  /// Kaynak künyesi doğrulandı; içerik incelemesi sürüyor.
  sourceVerified,

  /// İlmî inceleme bekliyor.
  scholarlyReviewPending,

  /// Yayında.
  published,

  /// Arşivlendi (geçmiş sürüm).
  archived,
}

/// İçeriğin dinî niteliği — kullanıcıya HER ZAMAN görünür kılınır
/// (TASK 056 §13): genel öğretici özet ile resmî fetva karıştırılamaz.
enum LearningContentType {
  /// Genel öğretici özet.
  generalTeaching,

  /// Kur'an açıklaması (tefsir kaynaklı).
  quranExplanation,

  /// Hadis temelli açıklama.
  hadithBased,

  /// İlmihal bilgisi.
  ilmihalKnowledge,

  /// Din İşleri Yüksek Kurulu cevabı.
  officialFatwa,
}

enum LearningDifficulty { beginner, basic, deep }

/// Tip güvenli içerik bloğu türleri — serbest HTML render EDİLMEZ.
enum LearningSectionType {
  paragraph,
  steps,
  checklist,
  keyPoint,
  warning,
  sourceNote,
  quranReference,
  hadithReference,
  differenceOfOpinion,
  practicalAction,
}

/// İçeriğin dil durumu (TASK 056 §6).
///
/// Türkçe resmî kaynak ASIL referanstır; İngilizce/Arapça metinler bu
/// kaynağa dayanan RESMÎ OLMAYAN açıklayıcı çevirilerdir ve kullanıcıya
/// böyle gösterilir.
enum LearningTranslationStatus {
  /// Türkçe: resmî kaynağa dayanan özgün özet.
  original,

  /// Resmî olmayan açıklayıcı çeviri.
  explanatoryTranslation,
}

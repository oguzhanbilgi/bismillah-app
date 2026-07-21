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

/// Doğrulamayı KİM yaptı (TASK 056A §2).
enum VerifiedBy {
  /// Editoryal inceleme: kaynak gövdesi okunup iddialarla karşılaştırıldı.
  editorialReview,

  /// Yalnız otomatik kaynak kontrolü (ör. URL/alan adı) — ZAYIFTIR.
  automatedSourceCheck,

  /// Yetkin ilmî inceleme.
  scholarlyReview,
}

/// Doğrulama YÖNTEMİ (TASK 056A §2).
///
/// [urlExistenceCheck] bilinçli olarak EN ZAYIF yöntemdir: bir adresin var
/// olması, o adresteki metnin makaledeki dinî iddiayı desteklediği anlamına
/// GELMEZ. Yayın kapısı bu yöntemi tek başına KABUL ETMEZ.
enum VerificationMethod {
  /// Yalnız URL/alan adı kontrolü — yayın için YETERSİZ.
  urlExistenceCheck,

  /// Kaynak gövdesi okundu ve iddialarla karşılaştırıldı.
  sourceBodyReview,

  /// Resmî belgeden birebir konum/alıntı ile doğrulandı.
  officialDocumentQuote,

  /// Yetkin ilmî inceleme ile doğrulandı.
  scholarlyReview;

  /// Yayın kapısı: URL varlığı kontrolünden GÜÇLÜ mü?
  bool get isStrongerThanUrlCheck => this != VerificationMethod.urlExistenceCheck;
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

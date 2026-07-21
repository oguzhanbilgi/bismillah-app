/// Bismillah Asistanı değer nesneleri (TASK 059 §5/§7).
library;

/// Sohbet mesajı rolü. Sistem güvenlik notu ayrı bir mesaj olarak
/// gösterilebildiğinden [system] de vardır.
enum AssistantRole { user, assistant, system }

/// Asistan cevabının türü — UI cevabı buna göre biçimlendirir ve güvenlik
/// davranışı buradan okunur (TASK 059 §5).
enum AssistantAnswerType {
  /// Doğrulanmış fatwa/officialAnswer exact eşleşmesinden doğrudan cevap.
  directVerifiedAnswer,

  /// Kaynaklı genel açıklama (kişisel duruma hüküm uygulanmaz).
  generalSourceSummary,

  /// Adım adım rehber (how-to).
  stepByStepGuide,

  /// Tanım cevabı.
  definition,

  /// Doğrulanmış kaynak bulunamadı — cevap uydurulmaz.
  noVerifiedSource,

  /// Kişisel duruma özel hüküm gerekiyor — yetkili mercie yönlendirilir.
  qualifiedGuidanceRequired,

  /// Kesin hüküm için resmî fatwa gerekiyor — Din İşleri'ne yönlendirilir.
  officialFatwaRequired,
}

/// Retrieval güven düzeyi (TASK 059 §5/§8).
enum AssistantConfidence {
  /// Başlık/alias birebir eşleşti.
  exact,

  /// Güçlü öbek/anahtar kelime eşleşmesi.
  strong,

  /// Yalnız zayıf/ilişkili eşleşme — hüküm için YETERSİZ.
  related,

  /// Anlamlı eşleşme yok.
  insufficient,
}

/// Deterministik soru sınıflandırması (TASK 059 §7).
enum AssistantQueryClass {
  /// "Abdest nasıl alınır?" — nasıl yapılır.
  howTo,

  /// "Teyemmüm nedir?" — tanım.
  definition,

  /// "Kan abdesti bozar mı?" — ibadet kuralı.
  worshipRule,

  /// "Bu caiz mi?" — hassas hüküm sorgusu.
  halalHaramVerdict,

  /// "Ben bu durumda ... günah mı?" — kişisel olay.
  personalCase,

  /// "Bunun delili nedir?" — delil talebi.
  evidenceRequest,

  /// Genel öğrenme sorusu.
  generalLearning,

  /// Sınıflandırılamadı.
  unknown,
}

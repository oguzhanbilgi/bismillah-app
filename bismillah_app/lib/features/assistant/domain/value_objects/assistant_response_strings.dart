/// Composer'ın kullandığı sabit, uygulama üretimi yerelleştirilmiş metinler
/// (TASK 059 §9/§15).
///
/// Makale içeriği (özet/adım/madde) zaten locale'e özel asset'ten gelir;
/// bu bundle YALNIZ uygulamanın ürettiği güvenlik/yönlendirme metinlerini
/// taşır. Domain katmanı böylece AppLocalizations'a doğrudan bağlanmaz —
/// bundle application/presentation katmanında l10n'dan kurulur.
final class AssistantResponseStrings {
  const AssistantResponseStrings({
    required this.noVerifiedSource,
    required this.officialFatwaRequired,
    required this.qualifiedGuidance,
    required this.generalInfoNotPersonalRuling,
    required this.personalCaseGeneralInfo,
    required this.sourceNotDirectlyAddressing,
    required this.translationNote,
  });

  /// Doğrulanmış kaynak bulunamadı.
  final String noVerifiedSource;

  /// Kesin hüküm için doğrulanmış resmî cevap yok.
  final String officialFatwaRequired;

  /// Kişisel duruma özel değerlendirme gerekiyor.
  final String qualifiedGuidance;

  /// "Bu genel bilgidir; özel duruma kesin hüküm uygulamaz."
  final String generalInfoNotPersonalRuling;

  /// Kişisel olayda genel bilgi verilirken gösterilen not.
  final String personalCaseGeneralInfo;

  /// Yalnız yakın/ilişkili eşleşmede: kaynak durumu doğrudan ele almıyor.
  final String sourceNotDirectlyAddressing;

  /// Açıklayıcı çeviri uyarısı.
  final String translationNote;
}

import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Bir içeriğin KAYNAK GÖVDESİ doğrulama kaydı (TASK 056A §2).
///
/// Neden gerekli: bir kaynak URL'sinin var olması ve resmî alan adında
/// bulunması, o sayfadaki metnin makaledeki dinî iddiayı DESTEKLEDİĞİ
/// anlamına gelmez. TASK 056'da tam olarak bu hata yapılmış, yalnız URL
/// doğrulamasıyla 16 makale yayına alınmıştı. Bu model o boşluğu kapatır.
final class SourceVerification {
  const SourceVerification({
    required this.sourceBodyVerified,
    required this.sourceId,
    required this.sourceLocator,
    required this.evidenceSummary,
    required this.verifiedAt,
    required this.verifiedBy,
    required this.verificationMethod,
    this.blocker,
  });

  /// Yalnız URL/alan adı kontrolü yapıldığında kullanılan kayıt.
  ///
  /// `sourceBodyVerified` DAİMA `false`'tır — bu kayıt yayın kapısını
  /// GEÇEMEZ (TASK 056A §2).
  factory SourceVerification.urlOnly({
    required String sourceId,
    required String verifiedAt,
    String? blocker,
  }) => SourceVerification(
    sourceBodyVerified: false,
    sourceId: sourceId,
    sourceLocator: '',
    evidenceSummary: '',
    verifiedAt: verifiedAt,
    verifiedBy: VerifiedBy.automatedSourceCheck,
    verificationMethod: VerificationMethod.urlExistenceCheck,
    blocker: blocker,
  );

  /// Kaynak metni gerçekten okunup iddialarla karşılaştırıldı mı?
  final bool sourceBodyVerified;

  /// Doğrulamanın dayandığı [KnowledgeSource] kimliği.
  final String sourceId;

  /// KESİN konum: PDF/kitap sayfası, bölüm başlığı, fetva sayfası vb.
  /// Genel bir ana sayfa adresi geçerli bir locator DEĞİLDİR.
  final String sourceLocator;

  /// Kaynakta bulunanın kısa özeti — uzun dinî metin BURAYA KOPYALANMAZ.
  final String evidenceSummary;

  final String verifiedAt;
  final VerifiedBy verifiedBy;
  final VerificationMethod verificationMethod;

  /// Doğrulanamadıysa engelin kısa açıklaması.
  final String? blocker;

  /// Yayın kapısının tüm koşulları sağlanıyor mu (TASK 056A §3)?
  bool get satisfiesPublicationGate =>
      sourceBodyVerified &&
      sourceLocator.trim().isNotEmpty &&
      evidenceSummary.trim().isNotEmpty &&
      verifiedAt.trim().isNotEmpty &&
      verificationMethod.isStrongerThanUrlCheck;
}

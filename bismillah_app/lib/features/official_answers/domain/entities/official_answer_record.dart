import 'package:bismillah_app/features/learn/domain/entities/source_verification.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/official_answers/domain/value_objects/official_answer_publication_gate.dart';

/// Resmî cevap / fetva dizini kaydı — TEMEL (TASK 092).
///
/// TASK 092 bu modeli SIFIR üretim kaydıyla taşır: gerçek fetva içeriği
/// yayınlanmadan önce doğrudan okunmuş bir kaynak gövdesi, sahip onayı ve
/// nitelikli ilmî inceleme gerekir — hiçbiri bu görevin sorumluluğunda
/// değildir. Bu sınıf yalnız gelecekteki kayıtlar için sözleşmeyi kurar.
///
/// [reviewStatus] ve [verification] Learn modülündeki [SourceVerification]
/// nesnesini KULLANIR ama Learn'ün yayın kapısını PAYLAŞMAZ:
/// [OfficialAnswerPublicationGate] BİLİNÇLİ OLARAK AYRI ve Learn makale
/// kapısından DAHA SIKI bir kapıdır (kişisel dinî hüküm/fetva niteliğindeki
/// bir kayıt, bir ilmihal makalesinden daha güçlü bir doğrulama gerektirir —
/// bkz. o dosyadaki gerekçe). Daha zayıf bir doğrulama yolu İCAT EDİLMEZ.
final class OfficialAnswerRecord {
  OfficialAnswerRecord({
    required this.id,
    required this.topic,
    required this.summary,
    required this.sourceId,
    required this.reviewStatus,
    required this.locale,
    required this.isGeneralInformationOnly,
    this.verification,
    this.sourceUrl = '',
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Kayıt id zorunludur');
    }
    if (!id.startsWith('oa-')) {
      throw ArgumentError.value(
        id,
        'id',
        'Resmî cevap id\'si "oa-" ile başlamalıdır',
      );
    }
    if (id.contains(':')) {
      throw ArgumentError.value(
        id,
        'id',
        'Resmî cevap id\'si ":" karakteri içeremez (plan öğesi ayıracı)',
      );
    }
    if (topic.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Konu (topic) zorunludur');
    }
    if (summary.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Özet (summary) zorunludur');
    }
    if (locale.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Locale zorunludur');
    }
    // ---------------------------------------------------------------
    // YAYIN KAPISI — Learn'den AYRI, DAHA SIKI kapı (TASK 092)
    // ---------------------------------------------------------------
    if (reviewStatus == ReviewStatus.published) {
      final issues = OfficialAnswerPublicationGate.evaluate(this);
      if (issues.isNotEmpty) {
        throw ArgumentError.value(
          id,
          'id',
          'Resmî cevap yayın kapısı reddetti: '
              '${issues.map((i) => i.name).join(', ')}',
        );
      }
    }
  }

  final String id;

  /// Nötr konu etiketi — kullanıcının sorusunun BİREBİR metni DEĞİLDİR.
  final String topic;

  /// Nötr açıklayıcı özet.
  final String summary;

  /// Kayıtlı bir [KnowledgeSource] kimliğine referans.
  final String sourceId;

  final ReviewStatus reviewStatus;

  /// Kaynak gövdesi doğrulama kaydı. `published` için ZORUNLUDUR.
  final SourceVerification? verification;

  final String locale;

  /// Kaydın yalnız GENEL bilgilendirme niteliğinde olduğunu, kişiye özel bir
  /// dinî hüküm/fetva İDDİA ETMEDİĞİNİ işaretler. `published` bir kayıt bu
  /// alanı DAİMA `true` taşımalıdır — kişiye özel bir hüküm bu dizinden asla
  /// otomatik yayına ALINAMAZ.
  final bool isGeneralInformationOnly;

  /// Kaynağın DOĞRUDAN ilgili sayfasının adresi (kaynağın genel
  /// `canonicalUrl`'sinden DAHA DERİN olmalıdır). `published` için
  /// ZORUNLUDUR — bkz. [OfficialAnswerPublicationGate].
  final String sourceUrl;

  bool get isPublished => reviewStatus == ReviewStatus.published;

  /// Bu kayıt [OfficialAnswerPublicationGate]'i GEÇER mi? `published`
  /// olmayan kayıtlar için de anlamlıdır (henüz yayına hazır mı sorusu).
  bool get satisfiesOfficialAnswerGate =>
      OfficialAnswerPublicationGate.evaluate(this).isEmpty;
}

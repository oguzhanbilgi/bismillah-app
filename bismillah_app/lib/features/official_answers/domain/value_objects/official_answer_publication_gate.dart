import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';

/// [OfficialAnswerPublicationGate.evaluate] tarafından üretilen TİPLİ ret
/// nedenleri — SERBEST METİN DEĞİL.
enum OfficialAnswerGateIssue {
  /// Kayıt `ReviewStatus.published` değil.
  notPublished,

  /// Doğrulama kaydı ([SourceVerification]) hiç yok.
  missingVerification,

  /// [SourceVerification.satisfiesPublicationGate] `false`.
  weakSourceVerification,

  /// Doğrulamayı yapan kişi/yöntem `VerifiedBy.scholarlyReview` DEĞİL.
  notScholarlyReviewed,

  /// Doğrulama kaydının `sourceId`'si kaydın kendi `sourceId`'sinden farklı.
  verificationSourceMismatch,

  /// Kaydın `sourceId`'si onaylı yetki kaynakları listesinde DEĞİL (veya
  /// çözülen [KnowledgeSource] fetva/resmî cevap türünde ya da resmî DEĞİL).
  unapprovedAuthoritySource,

  /// `sourceUrl` boş.
  missingSourceUrl,

  /// `sourceUrl` mutlak bir https adresi değil veya izin verilen alan
  /// adında değil.
  invalidSourceUrl,

  /// `sourceUrl`, kaynağın kendi `canonicalUrl`'sinden DAHA DERİN bir yol
  /// değil (ör. genel fetva listesi sayfasının kendisi).
  sourceUrlNotDeeperThanSource,

  /// Doğrulama kaydının `sourceLocator`'ı boş.
  missingSourceLocator,

  /// Kayıt id'si "oa-" ile başlamıyor veya ":" karakteri içeriyor.
  invalidId,

  /// Kaydın locale'i beklenen locale ile eşleşmiyor.
  localeMismatch,

  /// Kayıt `isGeneralInformationOnly == true` işaretli DEĞİL.
  notGeneralInformationOnly,
}

/// Resmî cevap / fetva dizini kayıtları için AYRI ve Learn makale kapısından
/// DAHA SIKI yayın kapısı (TASK 092).
///
/// BİLİNÇLİ TASARIM KARARI: bu kapı [SourceVerification.satisfiesPublicationGate]
/// (Learn TASK 056A §3) SONUCUNU yalnız bir BİLEŞEN olarak kullanır, KARARIN
/// KENDİSİ olarak DEĞİL. Learn kapısı KASITLI OLARAK DEĞİŞTİRİLMEDİ — bir
/// ilmihal makalesi için yeterli olan `editorialReview` + `sourceBodyReview`
/// disiplini, kişisel dinî hüküm/fetva niteliğindeki bir "resmî cevap" kaydı
/// için YETERSİZDİR. Bu yüzden burada AYRICA şunlar zorunludur:
///
/// - `verifiedBy == VerifiedBy.scholarlyReview` (editoryal veya otomatik
///   doğrulama YETERSİZ).
/// - Kaydın `sourceId`'si YALNIZ [approvedAuthoritySourceIds] içinde olabilir
///   (Din İşleri Yüksek Kurulu fetva/resmî cevap kaynakları) — bir ilmihal
///   veya tefsir kaynağı bir "resmî cevap"ı temellendiremez.
/// - `sourceUrl` doğrudan ilgili sayfaya işaret etmelidir; kaynağın kendi
///   genel `canonicalUrl`'si (ör. bare fetva listesi) KABUL EDİLMEZ.
///
/// ÖNEMLİ SINIR: `verifiedBy: scholarlyReview` burada YALNIZ bir VERİ
/// ALANIDIR — bu kapının geçmesi nitelikli bir insanın gerçekten inceleme
/// yaptığının KANITI DEĞİLDİR. Hiçbir ajan bu alanı KENDİLİĞİNDEN
/// KAYDEDEMEZ; gerçek nitelikli ilmî inceleme insan onay kapısıdır ve bu
/// dosyanın kapsamı dışındadır (bkz. proje talimatları — "qualified
/// scholarly review").
abstract final class OfficialAnswerPublicationGate {
  /// Bir "resmî cevap" kaydını temellendirebilecek TEK kaynak kümesi —
  /// Din İşleri Yüksek Kurulu fetva ve dinî soru hizmetleri kaynakları.
  /// Learn'ün geniş kaynak kayıt defterinden BİLİNÇLİ OLARAK dar bir alt
  /// kümedir.
  static const Set<String> approvedAuthoritySourceIds = {
    'diyanet-din-isleri-yuksek-kurulu',
    'diyanet-dini-soru-hizmetleri',
  };

  /// TÜM ret nedenlerini döner (ilk hata ile durmaz) — tüketici (parser,
  /// kayıt, test) tüm eksikleri TEK seferde görebilsin diye.
  static List<OfficialAnswerGateIssue> evaluate(
    OfficialAnswerRecord record, {
    KnowledgeSource? source,
    String? expectedLocale,
  }) {
    final issues = <OfficialAnswerGateIssue>[];

    if (!record.id.startsWith('oa-') || record.id.contains(':')) {
      issues.add(OfficialAnswerGateIssue.invalidId);
    }

    if (expectedLocale != null && record.locale != expectedLocale) {
      issues.add(OfficialAnswerGateIssue.localeMismatch);
    }

    if (record.reviewStatus != ReviewStatus.published) {
      issues.add(OfficialAnswerGateIssue.notPublished);
    }

    final verification = record.verification;
    if (verification == null) {
      issues.add(OfficialAnswerGateIssue.missingVerification);
    } else {
      if (!verification.satisfiesPublicationGate) {
        issues.add(OfficialAnswerGateIssue.weakSourceVerification);
      }
      if (verification.verifiedBy != VerifiedBy.scholarlyReview) {
        issues.add(OfficialAnswerGateIssue.notScholarlyReviewed);
      }
      if (verification.sourceId != record.sourceId) {
        issues.add(OfficialAnswerGateIssue.verificationSourceMismatch);
      }
      if (verification.sourceLocator.trim().isEmpty) {
        issues.add(OfficialAnswerGateIssue.missingSourceLocator);
      }
    }

    final isApprovedAuthoritySourceId = approvedAuthoritySourceIds.contains(
      record.sourceId,
    );
    final isApprovedAuthoritySource =
        isApprovedAuthoritySourceId &&
        (source == null ||
            (source.isOfficial &&
                (source.sourceType == KnowledgeSourceType.fatwa ||
                    source.sourceType == KnowledgeSourceType.officialAnswer)));
    if (!isApprovedAuthoritySource) {
      issues.add(OfficialAnswerGateIssue.unapprovedAuthoritySource);
    }

    final sourceUrl = record.sourceUrl.trim();
    if (sourceUrl.isEmpty) {
      issues.add(OfficialAnswerGateIssue.missingSourceUrl);
    } else {
      final uri = Uri.tryParse(sourceUrl);
      final isValidUrl =
          uri != null &&
          uri.isAbsolute &&
          uri.scheme == 'https' &&
          OfficialSourceDomains.isAllowed(sourceUrl);
      if (!isValidUrl) {
        issues.add(OfficialAnswerGateIssue.invalidSourceUrl);
      } else if (source != null) {
        final sourceCanonicalUri = Uri.tryParse(source.canonicalUrl);
        if (sourceCanonicalUri != null &&
            !_isStrictlyDeeperPath(
              uri.path,
              sourceCanonicalUri.path,
            )) {
          issues.add(OfficialAnswerGateIssue.sourceUrlNotDeeperThanSource);
        }
      }
    }

    if (!record.isGeneralInformationOnly) {
      issues.add(OfficialAnswerGateIssue.notGeneralInformationOnly);
    }

    return issues;
  }

  /// [candidatePath], [basePath]'ten daha derin mi (aynı adres veya daha
  /// sığ bir adres asla yeterli KANIT konumu SAYILMAZ)?
  static bool _isStrictlyDeeperPath(String candidatePath, String basePath) {
    final normalizedCandidate = _trimTrailingSlash(candidatePath);
    final normalizedBase = _trimTrailingSlash(basePath);
    if (normalizedCandidate == normalizedBase) {
      return false;
    }
    // Yalnız TABAN yolun bir devamı ("/segment" sınırıyla) yeterince derin
    // sayılır — "/tr/fetvalarim" gibi rastgele bir önek eşleşmesi KABUL
    // EDİLMEZ.
    return normalizedCandidate.startsWith('$normalizedBase/');
  }

  static String _trimTrailingSlash(String path) =>
      path.endsWith('/') && path.length > 1
      ? path.substring(0, path.length - 1)
      : path;
}

import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Doğrulanmış resmî bilgi kaynağı (TASK 056 §2/§3).
///
/// Bağlayıcı kurallar:
/// - Yalnız doğrulanmış RESMÎ kurum sayfaları kaynak olur; blog/forum/
///   sosyal medya kaynağı bu modele giremez.
/// - [canonicalUrl] izin verilen resmî alan adlarından biri olmalıdır
///   (bkz. [OfficialSourceDomains]) — aksi hâlde kurucu hata verir.
/// - Uygulamadaki metin bu kaynaktan ÖZGÜN ÖZETTİR; eserin aynen
///   kopyası değildir ([usageNotes] bunu kayıt altına alır).
final class KnowledgeSource {
  KnowledgeSource({
    required this.id,
    required this.institution,
    required this.title,
    required this.sourceType,
    required this.canonicalUrl,
    required this.originalLanguage,
    required this.accessedAt,
    required this.lastVerifiedAt,
    required this.attribution,
    required this.usageNotes,
    required this.isOfficial,
    this.publicationInfo,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Kaynak id boş olamaz');
    }
    if (institution.trim().isEmpty) {
      throw ArgumentError.value(
        institution,
        'institution',
        'Kurum adı zorunludur',
      );
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Eser/sayfa başlığı zorunludur');
    }
    if (!OfficialSourceDomains.isAllowed(canonicalUrl)) {
      throw ArgumentError.value(
        canonicalUrl,
        'canonicalUrl',
        'Kaynak URL izin verilen resmî alan adında olmalıdır',
      );
    }
  }

  final String id;

  /// Kaynağı yayımlayan kurum (ör. "T.C. Diyanet İşleri Başkanlığı").
  final String institution;

  /// Eser veya sayfa başlığı.
  final String title;

  final KnowledgeSourceType sourceType;

  /// Resmî kaynağın kanonik adresi.
  final String canonicalUrl;

  /// Kaynağın ORİJİNAL dili (ör. 'tr') — çeviri uyarısının dayanağı.
  final String originalLanguage;

  /// Baskı/sürüm bilgisi (varsa).
  final String? publicationInfo;

  /// Kaynağa erişim tarihi (ISO-8601 gün).
  final String accessedAt;

  /// Kaynağın son doğrulanma tarihi (ISO-8601 gün).
  final String lastVerifiedAt;

  /// Kullanıcıya gösterilecek atıf metni.
  final String attribution;

  /// Kullanım notu: özet mi, kısa alıntı mı olduğu burada kayıtlıdır.
  final String usageNotes;

  final bool isOfficial;
}

/// Dış bağlantı güvenliği (TASK 056 §10/§13).
///
/// Bir bağlantı AÇILMADAN ÖNCE alan adı bu listeye karşı doğrulanır:
/// içerik verisi bozulsa veya ileride uzak kaynaklı hale gelse bile
/// uygulama kullanıcıyı resmî olmayan bir siteye YÖNLENDİREMEZ.
abstract final class OfficialSourceDomains {
  /// İzin verilen kök alan adı. Yalnız bu alan ve alt alan adları geçerlidir.
  static const String rootDomain = 'diyanet.gov.tr';

  /// URL yalnız HTTPS ise ve host `diyanet.gov.tr` veya onun bir alt alan
  /// adıysa izin verilir. `notdiyanet.gov.tr` gibi son ek benzerlikleri
  /// nokta sınırı kontrolüyle REDDEDİLİR.
  static bool isAllowed(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
      return false;
    }
    final host = uri.host.toLowerCase();
    return host == rootDomain || host.endsWith('.$rootDomain');
  }
}

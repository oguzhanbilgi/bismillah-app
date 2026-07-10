import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';

/// Kurulum kaynağı kovası (10_DATA_MODEL §17) — platform attribution'ı
/// kovaya indirgenir; IDFA/GAID gibi reklam kimlikleri SAKLANMAZ.
enum InstallSource {
  organic,
  paidVideo,
  paidStore,
  paidBoost,
  paidRetargeting,
  unknown,
}

/// Reklam platformu kovası (10_DATA_MODEL §17).
enum AdPlatform { tiktok, meta, google, none }

/// Paid attribution kaydı (10_DATA_MODEL §17) — TEK ve IMMUTABLE.
///
/// Write-once (v1.1 hardening, bağlayıcı): ilk yazımdan sonra istemci
/// bu alanları DEĞİŞTİREMEZ — bu tipte `copyWith` bilinçli olarak YOKTUR
/// ve repository API'si update yolu sunmaz. PII taşımaz; dini pratik
/// verisiyle ham birleşim her katmanda yasaktır (kampanya KALİTESİ
/// ölçümüdür, kullanıcı profilleme değil). Analytics'e yalnız
/// `source_bucket`/`campaign_bucket` parametreleri çıkar.
final class Attribution implements Classified {
  Attribution({
    required this.installSource,
    required this.adPlatform,
    required this.firstOpenAt,
    this.campaignId,
    this.creativeId,
    this.onboardingCompletedFromPaid = false,
    this.activatedFromPaid = false,
    this.trialStartedFromPaid = false,
    this.paidConvertedFromPaid = false,
  });

  /// Attribution sinyali alınamadığında kullanılacak kayıt (§23 edge 16).
  /// Sonradan gelen sinyal bu kaydı DEĞİŞTİREMEZ — ilk yazım kazanır.
  factory Attribution.unknown({required UtcDateTime firstOpenAt}) {
    return Attribution(
      installSource: InstallSource.unknown,
      adPlatform: AdPlatform.none,
      firstOpenAt: firstOpenAt,
    );
  }

  final InstallSource installSource;
  final AdPlatform adPlatform;
  final UtcDateTime firstOpenAt;

  /// Kampanya kodu — kişisel değil operasyonel.
  final String? campaignId;

  /// Kreatif testi eşleme kodu.
  final String? creativeId;

  /// Kova metrikleri (dönüşüm hunisi).
  final bool onboardingCompletedFromPaid;
  final bool activatedFromPaid;
  final bool trialStartedFromPaid;
  final bool paidConvertedFromPaid;

  bool get isPaid =>
      installSource != InstallSource.organic &&
      installSource != InstallSource.unknown;

  /// Attribution Orta hassasiyettir (10_DATA_MODEL §19) — analytics'e
  /// yalnız kova alanları çıkar.
  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}

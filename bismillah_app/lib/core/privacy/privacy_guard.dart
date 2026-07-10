import 'package:bismillah_app/core/analytics/analytics_event.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/result/result.dart';

/// Telemetri ve log sınırlarının programatik bekçisi
/// (10_DATA_MODEL §18, 06_FLUTTER_ARCHITECTURE §21).
///
/// Tip sistemi serbest metni zaten engeller ([AnalyticsParamValue]);
/// bu bekçi ikinci savunma hattıdır: yasak anahtar adlarını ve kova
/// biçimine uymayan değerleri reddeder.
abstract final class PrivacyGuard {
  /// Analytics parametresi olarak ASLA görünemeyecek anahtar adları.
  /// (PII + ham ibadet/AI verisi — 10_DATA_MODEL §18 yasak listesi.)
  static const Set<String> forbiddenParamKeys = {
    'name',
    'display_name',
    'displayname',
    'email',
    'phone',
    'city',
    'address',
    'text',
    'message',
    'content',
    'answer',
    'entries',
    'surah',
    'ayah',
    'streak_timeline',
    'card_number',
    'token',
  };

  /// Kova değerleri için izin verilen biçim: kısa snake_case tanımlayıcı.
  static final RegExp _bucketPattern = RegExp(r'^[a-z0-9_.\-]{1,40}$');

  /// Event'i telemetriye çıkmadan önce doğrular.
  static Result<void> validateAnalyticsEvent(AnalyticsEvent event) {
    if (!_bucketPattern.hasMatch(event.name)) {
      return const Result.failure(
        ValidationFailure(messageKey: 'errorAnalyticsEventName'),
      );
    }
    for (final entry in event.params.entries) {
      final key = entry.key.toLowerCase();
      if (forbiddenParamKeys.contains(key)) {
        return const Result.failure(
          ValidationFailure(messageKey: 'errorAnalyticsForbiddenKey'),
        );
      }
      if (!_bucketPattern.hasMatch(entry.key)) {
        return const Result.failure(
          ValidationFailure(messageKey: 'errorAnalyticsParamKey'),
        );
      }
      final value = entry.value;
      if (value is BucketValue && !_bucketPattern.hasMatch(value.bucket)) {
        return const Result.failure(
          ValidationFailure(messageKey: 'errorAnalyticsParamValue'),
        );
      }
    }
    return const Result.success(null);
  }

  /// Verilen hassasiyet sınıfının log satırına yazılıp yazılamayacağı.
  static bool canLog(SensitivityClass sensitivity) => sensitivity.isLoggable;

  /// Verilen hassasiyet sınıfının saklanıp saklanamayacağı.
  /// [SensitivityClass.restricted] hiçbir katmanda saklanamaz.
  static bool canStore(SensitivityClass sensitivity) => sensitivity.isStorable;
}

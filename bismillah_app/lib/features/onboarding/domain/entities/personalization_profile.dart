import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';

/// Davranış sinyalleri — sabit alanlı nesne (10_DATA_MODEL §7 hardening:
/// keyfi map değil).
final class BehaviorSignals {
  BehaviorSignals({
    required this.completionRate7d,
    required this.activeHourBucket,
  }) {
    if (completionRate7d < 0 || completionRate7d > 1) {
      throw ArgumentError.value(
        completionRate7d,
        'completionRate7d',
        '0.0–1.0 aralığında olmalı',
      );
    }
  }

  /// Son 7 günün tamamlama oranı (0.0–1.0).
  final double completionRate7d;

  /// Aktif saat KOVASI (ör. `morning`) — ham zaman çizelgesi değil.
  final String activeHourBucket;
}

/// Türetilmiş kişiselleştirme profili (10_DATA_MODEL §4, §21).
///
/// YÜKSEK hassasiyet (türetilmiş dini profil). Kaynak: onboarding +
/// davranış sinyalleri; çakışmada merge edilmez, YENİDEN TÜRETİLİR.
/// 8 profil kovasının adları kişiselleştirme motoru görevinde
/// enum'lanır — bu görevde doğrulanmış kod taşınır.
final class PersonalizationProfile implements Classified {
  PersonalizationProfile({
    required this.profileType,
    required this.derivedAt,
    required this.behaviorSignals,
  }) {
    if (!RegExp(r'^[a-z0-9_]{1,40}$').hasMatch(profileType)) {
      throw ArgumentError.value(
        profileType,
        'profileType',
        'Profil türü kova kodu olmalı',
      );
    }
  }

  final String profileType;
  final UtcDateTime derivedAt;
  final BehaviorSignals behaviorSignals;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}

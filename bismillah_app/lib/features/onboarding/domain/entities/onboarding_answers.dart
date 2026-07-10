import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_enums.dart';

/// 16 sorunun ham cevapları (04_ONBOARDING §14; 10_DATA_MODEL §4).
///
/// YÜKSEK hassasiyet (dini + duygusal veri): asla loglanmaz, analytics'e
/// ham gitmez, üçüncü tarafla paylaşılmaz. `UserProfile`'dan AYRI
/// yaşar ve `settings/onboarding` alt belgesine senkronlanır — kök
/// belgeye KOYULMAZ (§8).
///
/// Kova alanları bu görevde doğrulanmış snake_case kod taşır; tam enum
/// seti onboarding implementasyon görevinde bağlanır (04 §4–13).
/// Varsayılanlar 04 §14 tablosuyla birebirdir.
final class OnboardingAnswers implements Classified {
  OnboardingAnswers({
    this.prayerRoutine = 'occasional',
    this.prayerCount,
    this.quranHabit = 'occasional',
    this.arabicAbility = 'not_yet',
    this.translationHabit = 'sometimes',
    this.dhikrInterest = 'yes',
    this.duaHabit = 'sometimes',
    this.growthGoal = OnboardingGoal.reconnect,
    this.mainStruggle = 'consistency',
    this.dailyTimeMinutes = 10,
    this.reminderPreference = 'prayer_only',
    this.wantsThirtyDayPlan = true,
    this.completedAt,
  }) {
    final count = prayerCount;
    if (count != null && (count < 0 || count > 5)) {
      throw ArgumentError.value(prayerCount, 'prayerCount', '0–5 olmalı');
    }
    if (!_allowedDailyTimes.contains(dailyTimeMinutes)) {
      throw ArgumentError.value(
        dailyTimeMinutes,
        'dailyTimeMinutes',
        '5/10/20/30 kovalarından biri olmalı (04 §14)',
      );
    }
    for (final (field, value) in [
      ('prayerRoutine', prayerRoutine),
      ('quranHabit', quranHabit),
      ('arabicAbility', arabicAbility),
      ('translationHabit', translationHabit),
      ('dhikrInterest', dhikrInterest),
      ('duaHabit', duaHabit),
      ('mainStruggle', mainStruggle),
      ('reminderPreference', reminderPreference),
    ]) {
      if (!_bucketPattern.hasMatch(value)) {
        throw ArgumentError.value(
          value,
          field,
          'Cevap kova kodu olmalı (kısa snake_case) — serbest metin yasak',
        );
      }
    }
  }

  static const Set<int> _allowedDailyTimes = {5, 10, 20, 30};
  static final RegExp _bucketPattern = RegExp(r'^[a-z0-9_]{1,40}$');

  final String prayerRoutine;

  /// 0–5; 0 vakit tamamen geçerlidir (04 §15 — dayatma yok).
  final int? prayerCount;

  final String quranHabit;
  final String arabicAbility;
  final String translationHabit;
  final String dhikrInterest;
  final String duaHabit;
  final OnboardingGoal growthGoal;

  /// Duygusal veri — Yüksek hassasiyet.
  final String mainStruggle;

  final int dailyTimeMinutes;
  final String reminderPreference;
  final bool wantsThirtyDayPlan;

  /// Bitince set edilir; null = onboarding devam ediyor.
  final UtcDateTime? completedAt;

  bool get isCompleted => completedAt != null;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı onboarding tercih deposu (TASK 028).
///
/// Bunlar AYAR tercihleridir, ibadet geçmişi DEĞİLDİR — Drift şeması
/// açılmaz (reminder store kararıyla aynı gerekçe). Enum'lar stabil
/// `name` ile yazılır; bozuk/tanınmayan değer tamamlanmış SAYILMAZ.
final class SharedPrefsOnboardingPreferencesRepository
    implements OnboardingPreferencesRepository {
  const SharedPrefsOnboardingPreferencesRepository();

  static const String _completedKey = 'bismillah.onboarding_completed';
  static const String _goalsKey = 'bismillah.onboarding_goals';
  static const String _journeyKey = 'bismillah.onboarding_journey_stage';
  static const String _paceKey = 'bismillah.onboarding_daily_pace';
  static const String _completedAtKey = 'bismillah.onboarding_completed_at';

  @override
  Future<bool> isCompleted() async {
    // Tamamlanma = geçerli bir tercih setinin okunabilmesi (tek doğrulama
    // yolu — load ile aynı kurallar). Okuma hatası da güvenli `false`dur.
    final result = await load();
    return result.fold(
      onSuccess: (preferences) => preferences != null,
      onFailure: (_) => false,
    );
  }

  @override
  ResultFuture<OnboardingPreferences?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_completedKey) ?? false)) {
        return const Result.success(null);
      }
      // Bayrak true olsa bile saklanan seçimler doğrulanır: bozuk veya
      // tanınmayan enum adı → tamamlanmış SAYILMAZ (`success(null)`;
      // crash yok, `byName` hatası aşağıda yakalanır).
      try {
        final goalNames = prefs.getStringList(_goalsKey) ?? const [];
        if (goalNames.isEmpty) {
          return const Result.success(null);
        }
        final completedAt = DateTime.tryParse(
          prefs.getString(_completedAtKey) ?? '',
        );
        if (completedAt == null) {
          return const Result.success(null);
        }
        return Result.success(
          OnboardingPreferences(
            goals: {
              for (final name in goalNames)
                OnboardingFocusGoal.values.byName(name),
            },
            journeyStage: OnboardingJourneyStage.values.byName(
              prefs.getString(_journeyKey) ?? '',
            ),
            dailyPace: OnboardingDailyPace.values.byName(
              prefs.getString(_paceKey) ?? '',
            ),
            completedAtUtc: completedAt.toUtc(),
          ),
        );
      } on ArgumentError {
        return const Result.success(null); // tanınmayan enum adı
      }
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Seçimler ÖNCE yazılır; tamamlanma bayrağı EN SON true olur —
      // yarıda kesilirse bayrak false kalır ve kapı güvenli tarafta düşer.
      await prefs.setStringList(_goalsKey, [
        for (final goal in preferences.goals) goal.name,
      ]);
      await prefs.setString(_journeyKey, preferences.journeyStage.name);
      await prefs.setString(_paceKey, preferences.dailyPace.name);
      await prefs.setString(
        _completedAtKey,
        preferences.completedAtUtc.toIso8601String(),
      );
      await prefs.setBool(_completedKey, true);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}

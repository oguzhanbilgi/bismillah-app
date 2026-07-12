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
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_completedKey) ?? false)) {
        return false;
      }
      // Bayrak true olsa bile saklanan seçimler doğrulanır: bozuk veya
      // tanınmayan enum adı → tamamlanmış SAYILMAZ, onboarding'e güvenle
      // dönülür (crash yok; `byName` hatası aşağıda yakalanır).
      final goals = prefs.getStringList(_goalsKey) ?? const [];
      if (goals.isEmpty) {
        return false;
      }
      for (final name in goals) {
        OnboardingFocusGoal.values.byName(name);
      }
      OnboardingJourneyStage.values.byName(prefs.getString(_journeyKey) ?? '');
      OnboardingDailyPace.values.byName(prefs.getString(_paceKey) ?? '');
      return true;
    } on Object {
      return false;
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

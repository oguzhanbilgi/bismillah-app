import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';

/// Today'in günlük kişiselleştirilmiş küçük adımı (TASK 031).
///
/// AI DEĞİLDİR: saf, deterministik, paket-bağımsız bir eşlemedir. Dini
/// hüküm/fetva üretmez — yalnız kullanıcının KENDİ seçtiği odaklara
/// nazik bir hatırlatmadır. Metinler localization'dadır; enum `.name`
/// kullanıcıya gösterilmez.
final class TodayPersonalizedSuggestion {
  const TodayPersonalizedSuggestion({required this.goal, required this.pace});

  final OnboardingFocusGoal goal;
  final OnboardingDailyPace pace;

  /// Günün önerisini seçer; tercih yoksa `null` (kart gizlenir).
  ///
  /// Deterministik günlük rotasyon: hedefler enum index sırasına dizilir,
  /// yerel takvim gününün epoch gün numarası hedef sayısına göre mod
  /// alınır — aynı gün içinde öneri DEĞİŞMEZ, ertesi gün sıradaki hedefe
  /// geçer. [localNow] clockProvider'dan gelir (DateTime.now yasak);
  /// timer/arka plan işi yoktur.
  static TodayPersonalizedSuggestion? fromPreferences({
    required OnboardingPreferences? preferences,
    required DateTime localNow,
  }) {
    if (preferences == null || preferences.goals.isEmpty) {
      return null;
    }
    final sorted = preferences.goals.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final localDay = DateTime(localNow.year, localNow.month, localNow.day);
    final dayNumber = localDay.difference(DateTime(1970)).inDays;
    return TodayPersonalizedSuggestion(
      goal: sorted[dayNumber % sorted.length],
      pace: preferences.dailyPace,
    );
  }
}

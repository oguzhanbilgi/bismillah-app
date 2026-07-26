import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';

/// 30 günlük plan üretiminin **tam** girdi kümesi (TASK 079).
///
/// Değişken olan her şey açıkça verilir: saat, locale, timezone, cihaz
/// durumu, kimlik veya kalıcılık referansı TAŞIMAZ. `completedAtUtc`,
/// UID, konum, abonelik ve bildirim ayarları bilinçli olarak YOKTUR.
///
/// Profil, TASK 078 `OnboardingProfileMapper` çıktısıdır ve burada
/// **yeniden türetilmez** — [validate] yalnız tutarlılığı denetler.
final class DailyPlanGenerationRequest {
  DailyPlanGenerationRequest({
    required this.profileType,
    required Set<OnboardingFocusGoal> goals,
    required this.dailyPace,
    required this.startDay,
  }) : goals = Set.unmodifiable(goals),
       // Normalizasyon: kanonik sıra = enum bildirim sırası. Bu BİLİNÇLİ
       // ve belgelenmiş bir seçimdir; `Set` yineleme sırası çıktıyı
       // etkileyemez.
       normalizedGoals = List.unmodifiable(
         OnboardingFocusGoal.values.where(goals.contains),
       );

  /// Üretilecek gün sayısı — kanonik 30 günlük çatı (10_DATA_MODEL §4).
  static const int planLengthDays = 30;

  final DailyPlanProfileType profileType;

  /// Ham seçim kümesi (sıra taşımaz).
  final Set<OnboardingFocusGoal> goals;

  /// Deterministik sıralanmış hedefler — üretim bunu kullanır.
  final List<OnboardingFocusGoal> normalizedGoals;

  final OnboardingDailyPace dailyPace;
  final DayKey startDay;

  /// Günlük zaman bütçesi (dakika) — **onaylı TASK 079 ürün kararı**.
  ///
  /// `light` 5 · `balanced` 10 · `focused` 20; tek profil-özel istisna
  /// `advanced` + `focused` → 30. Advanced sınırsız süre anlamına GELMEZ.
  int get sizeMinutes {
    if (profileType == DailyPlanProfileType.advanced &&
        dailyPace == OnboardingDailyPace.focused) {
      return 30;
    }
    return switch (dailyPace) {
      OnboardingDailyPace.light => 5,
      OnboardingDailyPace.balanced => 10,
      OnboardingDailyPace.focused => 20,
    };
  }

  /// Profil ile tempo TASK 078 kurallarıyla tutarlı mı?
  ///
  /// TASK 078 belirli birleşimleri ÜRETEMEZ (ör. `advanced` yalnız
  /// `focused`'tan, `lowTime` yalnız `light`'tan doğar). Tutarsız girdi
  /// sessizce ONARILMAZ; tipli bir sorun döner.
  GenerationRequestIssue? validate() {
    if (goals.isEmpty) {
      return GenerationRequestIssue.emptyGoals;
    }
    final compatible = switch (profileType) {
      // Yolculuk aşaması tempoyu ezer (TASK 078 Kural 1–2) → her tempo geçerli.
      DailyPlanProfileType.beginner || DailyPlanProfileType.returning => true,
      // TASK 078 Kural 3.
      DailyPlanProfileType.advanced => dailyPace == OnboardingDailyPace.focused,
      // TASK 078 Kural 4.
      DailyPlanProfileType.lowTime => dailyPace == OnboardingDailyPace.light,
      // TASK 078 Kural 5: `light` zaten Kural 4'e takılır.
      DailyPlanProfileType.prayerFocused ||
      DailyPlanProfileType.quranFocused ||
      DailyPlanProfileType.dhikrFocused ||
      DailyPlanProfileType.learningFocused =>
        dailyPace != OnboardingDailyPace.light,
    };
    return compatible ? null : GenerationRequestIssue.profilePaceMismatch;
  }

  bool get isValid => validate() == null;
}

/// Girdi tutarsızlığının stabil, nötr kimliği.
///
/// Kullanıcı metni, cevap içeriği veya istisna bilgisi taşımaz.
enum GenerationRequestIssue {
  /// Hedef seçilmemiş — tamamlanmış onboarding girdisi zorunludur.
  emptyGoals,

  /// Profil ile günlük tempo TASK 078 kurallarına göre birlikte doğamaz.
  profilePaceMismatch,
}

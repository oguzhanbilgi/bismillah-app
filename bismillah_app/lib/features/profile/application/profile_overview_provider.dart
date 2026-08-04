import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/profile/domain/profile_plan_overview.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/services/onboarding_profile_mapper.dart';
import 'package:bismillah_app/features/today/domain/value_objects/daily_plan_profile_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profil ana ekranının tek okuma modeli (TASK 096).
///
/// Tümü GERÇEK kayıtlı veriden gelir: tercihler onboarding deposundan,
/// plan ilerlemesi kayıtlı `DailyPlan` kayıtlarından. Uydurulmuş metrik
/// yoktur; hesaplanamayan alan `null` kalır ve arayüzde hiç gösterilmez.
final class ProfileOverview {
  const ProfileOverview({
    required this.preferences,
    required this.profileType,
    required this.planProgress,
  });

  /// Kayıtlı onboarding tercihleri; hiç tamamlanmadıysa `null`.
  final OnboardingPreferences? preferences;

  /// Tercihlerden TÜRETİLEN plan profili; tercih yoksa/eksikse `null`.
  /// Bu bir seviye, rütbe veya başarı göstergesi DEĞİLDİR.
  final DailyPlanProfileType? profileType;

  /// Bugünü içeren plan bloğunun özeti; aktif plan yoksa `null`.
  final ProfilePlanProgress? planProgress;

  bool get hasPreferences => preferences != null;
}

/// Profil özeti sağlayıcısı.
///
/// Okuma aralığı bugünden 29 gün geriye ve 29 gün ileriye bakar: plan
/// bugünden önce başlamış olabilir, bu yüzden bloğun gerçek başlangıcı
/// depodan bulunur — varsayılmaz. Aralık okuması tek bir depo çağrısıdır.
final profileOverviewProvider = FutureProvider<ProfileOverview>((ref) async {
  final preferencesResult = await ref
      .read(onboardingPreferencesRepositoryProvider)
      .load();
  // Tercih okunamıyorsa bu gerçek bir hatadır: ekran sakin hata gösterir.
  final preferences = preferencesResult.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw failure,
  );

  final DailyPlanProfileType? profileType;
  if (preferences == null) {
    profileType = null;
  } else {
    final mapping = OnboardingProfileMapper.map(preferences);
    profileType = mapping is ProfileMapped ? mapping.profile : null;
  }

  final today = DayKey.fromLocal(ref.read(clockProvider).nowLocal());
  final span = DailyPlanGenerator.dayAt(today, -29);
  final range = await ref
      .read(dailyPlanRepositoryProvider)
      .getRange(span, DailyPlanGenerator.dayAt(today, 29));

  // Plan okunamıyorsa profil ekranı ÇÖKMEZ: tercih özeti ve ayarlar
  // görünmeye devam eder, yalnız plan bölümü "özet yok" durumuna düşer.
  final plans = range.valueOrNull ?? const [];

  return ProfileOverview(
    preferences: preferences,
    profileType: profileType,
    planProgress: ProfilePlanOverviewCalculator.summarize(
      plans: plans,
      today: today,
    ),
  );
});

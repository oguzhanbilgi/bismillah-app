import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';

/// Onboarding'de toplanan tercihlerin tamamlanmış hâli (TASK 028).
///
/// Paket-bağımsız model; kalıcılıkta enum'lar GÖRÜNEN METİNLE DEĞİL,
/// stabil `name` değerleriyle saklanır (localization değişse de veri
/// bozulmaz). Bu veri cihazda kalır — Firestore'a gönderilmez,
/// SyncOperation üretmez (kişiselleştirme sync'i ayrı görev).
final class OnboardingPreferences {
  OnboardingPreferences({
    required Set<OnboardingFocusGoal> goals,
    required this.journeyStage,
    required this.dailyPace,
    required this.completedAtUtc,
  }) : goals = Set.unmodifiable(goals),
       assert(goals.isNotEmpty, 'En az bir hedef seçilmiş olmalı');

  final Set<OnboardingFocusGoal> goals;
  final OnboardingJourneyStage journeyStage;
  final OnboardingDailyPace dailyPace;

  /// Tamamlanma anı (UTC) — clockProvider'dan gelir.
  final DateTime completedAtUtc;
}

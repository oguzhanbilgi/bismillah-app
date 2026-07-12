import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';

/// Onboarding seçeneklerinin yerelleştirilmiş etiketleri — onboarding
/// akışı, profil özeti ve düzenleme ekranı AYNI metinleri kullanır;
/// enum `.name` kullanıcıya ASLA gösterilmez.
String onboardingGoalLabel(AppLocalizations l10n, OnboardingFocusGoal goal) =>
    switch (goal) {
      OnboardingFocusGoal.trackPrayers => l10n.onboardingGoalTrackPrayers,
      OnboardingFocusGoal.prayOnTime => l10n.onboardingGoalPrayOnTime,
      OnboardingFocusGoal.quranHabit => l10n.onboardingGoalQuranHabit,
      OnboardingFocusGoal.dhikrRoutine => l10n.onboardingGoalDhikrRoutine,
      OnboardingFocusGoal.islamicKnowledge => l10n.onboardingGoalKnowledge,
    };

String onboardingJourneyStageLabel(
  AppLocalizations l10n,
  OnboardingJourneyStage stage,
) => switch (stage) {
  OnboardingJourneyStage.justBeginning => l10n.onboardingJourneyNew,
  OnboardingJourneyStage.rebuildingRoutine => l10n.onboardingJourneyRebuilding,
  OnboardingJourneyStage.strengtheningRoutine =>
    l10n.onboardingJourneyStrengthening,
};

String onboardingDailyPaceLabel(
  AppLocalizations l10n,
  OnboardingDailyPace pace,
) => switch (pace) {
  OnboardingDailyPace.light => l10n.onboardingPaceLight,
  OnboardingDailyPace.balanced => l10n.onboardingPaceBalanced,
  OnboardingDailyPace.focused => l10n.onboardingPaceFocused,
};

String onboardingDailyPaceDescription(
  AppLocalizations l10n,
  OnboardingDailyPace pace,
) => switch (pace) {
  OnboardingDailyPace.light => l10n.onboardingPaceLightDesc,
  OnboardingDailyPace.balanced => l10n.onboardingPaceBalancedDesc,
  OnboardingDailyPace.focused => l10n.onboardingPaceFocusedDesc,
};

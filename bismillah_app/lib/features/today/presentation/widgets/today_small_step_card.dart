import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_preferences_provider.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/today/domain/today_personalized_suggestion.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today "Bugün için küçük bir adım" kartı (TASK 031) — SALT-OKUNUR.
///
/// AI DEĞİLDİR: TASK 029 tercih provider'ından beslenen deterministik
/// günlük öneri. Tercih yokken/bozukken/yüklenirken/okuma hatasında kart
/// SESSİZCE GİZLENİR — Today asla bloklanmaz, crash yok, onboarding
/// kapısına dokunulmaz. Profil düzenlemesi provider'ı invalidate ettiği
/// için sonraki okumada güncel tercih yansır.
class TodaySmallStepCard extends ConsumerWidget {
  const TodaySmallStepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(onboardingPreferencesProvider);

    // Yükleme/hata/veri-yok: kart gizlenir (pop-in ve yanıltıcı boş kart
    // yerine sakin yokluk — Today'in kalan kartları etkilenmez).
    final preferences = async.value;
    final suggestion = TodayPersonalizedSuggestion.fromPreferences(
      preferences: preferences,
      localNow: ref.watch(clockProvider).nowLocal(),
    );
    if (suggestion == null) {
      return const SizedBox.shrink();
    }

    final cta = _ctaFor(l10n, suggestion.goal);
    // Alt boşluk kartla birlikte yaşar: kart gizliyken Today'deki kartlar
    // arası boşluk sabit kalır (ekranda ekstra spacer yoktur).
    return _withBottomSpacing(
      // TASK 054: kişiselleştirilmiş öneri sıcak kum yüzeyinde yaşar —
      // Kur'an bölümünün adaçayı tonundan ayrışır, art arda aynı beyaz
      // kart dizilimi kırılır.
      AppCard(
        variant: AppCardVariant.sand,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    l10n.todaySmallStepTitle,
                    token: AppTextStyleToken.h3,
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                AppBadge(label: l10n.todaySmallStepBadge),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            AppText(_suggestionText(l10n, suggestion.goal)),
            const SizedBox(height: AppSpacing.s2),
            AppText(
              _paceText(l10n, suggestion.pace),
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            if (cta != null) ...[
              const SizedBox(height: AppSpacing.s5),
              AppButton(
                label: cta.label,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(cta.route),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _withBottomSpacing(Widget child) => Column(
    children: [
      child,
      const SizedBox(height: AppSpacing.s4),
    ],
  );

  static String _suggestionText(
    AppLocalizations l10n,
    OnboardingFocusGoal goal,
  ) => switch (goal) {
    OnboardingFocusGoal.trackPrayers => l10n.todaySuggestionTrackPrayers,
    OnboardingFocusGoal.prayOnTime => l10n.todaySuggestionPrayOnTime,
    OnboardingFocusGoal.quranHabit => l10n.todaySuggestionQuran,
    OnboardingFocusGoal.dhikrRoutine => l10n.todaySuggestionDhikr,
    OnboardingFocusGoal.islamicKnowledge => l10n.todaySuggestionKnowledge,
  };

  static String _paceText(AppLocalizations l10n, OnboardingDailyPace pace) =>
      switch (pace) {
        OnboardingDailyPace.light => l10n.todayPaceLight,
        OnboardingDailyPace.balanced => l10n.todayPaceBalanced,
        OnboardingDailyPace.focused => l10n.todayPaceFocused,
      };

  /// Hedefin CTA'sı; dua/zikir için aktif bir ekran HENÜZ olmadığından
  /// yanıltıcı route yerine CTA'sız yalın öneri gösterilir.
  static ({String label, String route})? _ctaFor(
    AppLocalizations l10n,
    OnboardingFocusGoal goal,
  ) => switch (goal) {
    OnboardingFocusGoal.trackPrayers => (
      label: l10n.todayGoToPrayers,
      route: AppRoutes.prayer,
    ),
    OnboardingFocusGoal.prayOnTime => (
      label: l10n.todayCtaSeeTimes,
      route: AppRoutes.prayer,
    ),
    OnboardingFocusGoal.quranHabit => (
      label: l10n.todayCtaGoQuran,
      route: AppRoutes.quran,
    ),
    OnboardingFocusGoal.dhikrRoutine => null,
    OnboardingFocusGoal.islamicKnowledge => (
      label: l10n.todayCtaGoLearn,
      route: AppRoutes.learn,
    ),
  };
}

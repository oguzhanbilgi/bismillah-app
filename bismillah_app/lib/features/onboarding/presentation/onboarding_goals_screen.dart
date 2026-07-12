import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_goals_controller.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding hedef seçimi (TASK 026). Çoklu seçim; en az bir hedef
/// olmadan devam edilemez. Seçim yalnız bellekte — kalıcılık TASK 028.
/// "Devam et" yolculuk aşaması adımına geçer (TASK 027 akışı).
/// Rekabet/puan/streak dili YOKTUR.
class OnboardingGoalsScreen extends ConsumerWidget {
  const OnboardingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(onboardingGoalsControllerProvider);
    final controller = ref.read(onboardingGoalsControllerProvider.notifier);

    return AppScaffold(
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s7),
          AppText(l10n.onboardingGoalsTitle, token: AppTextStyleToken.h1),
          const SizedBox(height: AppSpacing.s3),
          AppText(
            l10n.onboardingGoalsSupport,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s6),
          for (final goal in OnboardingFocusGoal.values) ...[
            OnboardingOptionCard(
              label: _goalLabel(l10n, goal),
              selected: selected.contains(goal),
              onTap: () => controller.toggleGoal(goal),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: l10n.onboardingGoalsCta,
            onPressed: selected.isEmpty
                ? null
                : () => context.push(AppRoutes.onboardingJourney),
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }

  static String _goalLabel(AppLocalizations l10n, OnboardingFocusGoal goal) =>
      switch (goal) {
        OnboardingFocusGoal.trackPrayers => l10n.onboardingGoalTrackPrayers,
        OnboardingFocusGoal.prayOnTime => l10n.onboardingGoalPrayOnTime,
        OnboardingFocusGoal.quranHabit => l10n.onboardingGoalQuranHabit,
        OnboardingFocusGoal.dhikrRoutine => l10n.onboardingGoalDhikrRoutine,
        OnboardingFocusGoal.islamicKnowledge => l10n.onboardingGoalKnowledge,
      };
}

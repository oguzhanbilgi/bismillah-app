import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_option_labels.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/profile/application/personalization_edit_controller.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kişiselleştirme tercihlerini düzenleme (TASK 030) — onboarding AKIŞI
/// DEĞİLDİR: startup kapısına dokunmaz, `completed` true kalır. Üç bölüm
/// tek ekranda; kayıt mevcut depo üzerinden, başarıda Profil'e dönülür.
class PersonalizationEditScreen extends ConsumerWidget {
  const PersonalizationEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(personalizationEditControllerProvider);

    return AppScaffold(
      title: l10n.profilePersonalizationEditTitle,
      body: switch (async) {
        AsyncData(:final value) => value == null
            // Geçerli tercih yok — sakin durum; AppBar geri oku Profil'e
            // döndürür (onboarding'e yönlendirme YOK).
            ? Center(
                child: AppText(
                  l10n.profilePersonalizationEmpty,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                  textAlign: TextAlign.center,
                ),
              )
            : _EditForm(state: value),
        AsyncError() => AppErrorState(
          message: l10n.profilePersonalizationLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () =>
              ref.invalidate(personalizationEditControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

final class _EditForm extends ConsumerWidget {
  const _EditForm({required this.state});

  final PersonalizationEditState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(
      personalizationEditControllerProvider.notifier,
    );

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppText(
          l10n.profilePersonalizationEditSupport,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s6),
        AppText(
          l10n.profileFocusAreas,
          token: AppTextStyleToken.h3,
        ),
        const SizedBox(height: AppSpacing.s3),
        for (final goal in OnboardingFocusGoal.values) ...[
          OnboardingOptionCard(
            label: onboardingGoalLabel(l10n, goal),
            selected: state.goals.contains(goal),
            onTap: () => controller.toggleGoal(goal),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        const SizedBox(height: AppSpacing.s4),
        AppText(
          l10n.profileJourneyStage,
          token: AppTextStyleToken.h3,
        ),
        const SizedBox(height: AppSpacing.s3),
        for (final stage in OnboardingJourneyStage.values) ...[
          OnboardingOptionCard(
            label: onboardingJourneyStageLabel(l10n, stage),
            selected: state.journeyStage == stage,
            onTap: () => controller.selectJourneyStage(stage),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        const SizedBox(height: AppSpacing.s4),
        AppText(
          l10n.profileDailyPace,
          token: AppTextStyleToken.h3,
        ),
        const SizedBox(height: AppSpacing.s3),
        for (final pace in OnboardingDailyPace.values) ...[
          OnboardingOptionCard(
            label: onboardingDailyPaceLabel(l10n, pace),
            description: onboardingDailyPaceDescription(l10n, pace),
            selected: state.dailyPace == pace,
            onTap: () => controller.selectDailyPace(pace),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        if (state.saveFailed) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.onboardingSaveIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s4),
        AppButton(
          label: l10n.profileSaveChanges,
          isLoading: state.isSaving,
          onPressed: !state.canSave || state.isSaving
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final savedMessage = l10n.profileChangesSaved;
                  final ok = await controller.save();
                  if (ok && context.mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(savedMessage)),
                    );
                    context.pop();
                  }
                },
        ),
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

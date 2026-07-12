import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_journey_controller.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding yolculuk aşaması (TASK 027) — TEK seçim.
///
/// Kaç vakit kılındığı SORULMAZ; seviye ölçen/yargılayan dil YOKTUR —
/// kullanıcı kendini nasıl görüyorsa odur. Seçim yalnız bellekte;
/// kalıcılık TASK 028. "Devam et" günlük tempo adımına geçer.
class OnboardingJourneyScreen extends ConsumerWidget {
  const OnboardingJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(onboardingJourneyControllerProvider);
    final controller = ref.read(onboardingJourneyControllerProvider.notifier);

    return AppScaffold(
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s7),
          AppText(l10n.onboardingJourneyTitle, token: AppTextStyleToken.h1),
          const SizedBox(height: AppSpacing.s3),
          AppText(
            l10n.onboardingJourneySupport,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s6),
          for (final stage in OnboardingJourneyStage.values) ...[
            OnboardingOptionCard(
              label: _stageLabel(l10n, stage),
              selected: selected == stage,
              onTap: () => controller.select(stage),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: l10n.onboardingGoalsCta,
            onPressed: selected == null
                ? null
                : () => context.push(AppRoutes.onboardingPace),
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }

  static String _stageLabel(
    AppLocalizations l10n,
    OnboardingJourneyStage stage,
  ) => switch (stage) {
    OnboardingJourneyStage.justBeginning => l10n.onboardingJourneyNew,
    OnboardingJourneyStage.rebuildingRoutine =>
      l10n.onboardingJourneyRebuilding,
    OnboardingJourneyStage.strengtheningRoutine =>
      l10n.onboardingJourneyStrengthening,
  };
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_completion_controller.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_pace_controller.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding günlük tempo (TASK 027) — TEK seçim; akışın son adımı.
///
/// "Planımı hazırla" (TASK 028): seçimler TEK kontrollü işlemle lokale
/// kaydedilir; yalnız BAŞARIDA tamamlanma kapısı açılır ve `go(today)`
/// stack'i onboarding'siz kurar (geri tuşu dönemez). Hata sakin bir
/// mesajdır — aynı buton tekrar dener; ana uygulamaya geçilmez.
class OnboardingPaceScreen extends ConsumerWidget {
  const OnboardingPaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(onboardingPaceControllerProvider);
    final controller = ref.read(onboardingPaceControllerProvider.notifier);
    final completion = ref.watch(onboardingCompletionControllerProvider);

    return AppScaffold(
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s7),
          AppText(l10n.onboardingPaceTitle, token: AppTextStyleToken.h1),
          const SizedBox(height: AppSpacing.s3),
          AppText(
            l10n.onboardingPaceSupport,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s6),
          for (final pace in OnboardingDailyPace.values) ...[
            OnboardingOptionCard(
              label: _paceLabel(l10n, pace),
              description: _paceDescription(l10n, pace),
              selected: selected == pace,
              onTap: () => controller.select(pace),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          if (completion.hasError) ...[
            const SizedBox(height: AppSpacing.s2),
            AppText(
              l10n.onboardingSaveIssue,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
          ],
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: l10n.onboardingPaceCta,
            isLoading: completion.isLoading,
            onPressed: selected == null || completion.isLoading
                ? null
                : () async {
                    final notifier = ref.read(
                      onboardingCompletionControllerProvider.notifier,
                    );
                    final ok = await notifier.complete();
                    if (ok && context.mounted) {
                      context.go(AppRoutes.today);
                    }
                  },
          ),
          if (completion.isLoading) ...[
            const SizedBox(height: AppSpacing.s3),
            Center(
              child: AppText(
                l10n.onboardingPreparingStart,
                token: AppTextStyleToken.caption,
                secondary: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }

  static String _paceLabel(AppLocalizations l10n, OnboardingDailyPace pace) =>
      switch (pace) {
        OnboardingDailyPace.light => l10n.onboardingPaceLight,
        OnboardingDailyPace.balanced => l10n.onboardingPaceBalanced,
        OnboardingDailyPace.focused => l10n.onboardingPaceFocused,
      };

  static String _paceDescription(
    AppLocalizations l10n,
    OnboardingDailyPace pace,
  ) => switch (pace) {
    OnboardingDailyPace.light => l10n.onboardingPaceLightDesc,
    OnboardingDailyPace.balanced => l10n.onboardingPaceBalancedDesc,
    OnboardingDailyPace.focused => l10n.onboardingPaceFocusedDesc,
  };
}

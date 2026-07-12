import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_preferences_provider.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_option_labels.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile sekmesi — ilk gerçek içerik: kişiselleştirme özeti (TASK 029,
/// SALT-OKUNUR; düzenleme TASK 030). İstatistik/rozet/ayarlar sonraki
/// görevlerde. Abonelik yönetimine geçiş köprüsü mevcut.
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabProfile,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: AppSpacing.s5),
                const _PersonalizationCard(),
                const SizedBox(height: AppSpacing.s5),
                Center(
                  child: AppText(
                    l10n.placeholderComingSoon,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s6),
            child: AppButton(
              label: l10n.subscriptionSettingsTitle,
              variant: AppButtonVariant.text,
              onPressed: () => context.push(AppRoutes.subscriptionSettings),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kişiselleştirme özeti kartı — SALT-OKUNUR; onboarding tercihlerini
/// TASK 028 deposundan okur (SharedPreferences importu YOK — arayüz +
/// provider). Veri yoksa/bozuksa sakin boş durum; okuma hatasında kısa
/// metin + tekrar dene. Bu görevde onboarding'e yönlendirme YOKTUR.
class _PersonalizationCard extends ConsumerWidget {
  const _PersonalizationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(onboardingPreferencesProvider);

    Widget card(Widget child) => AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.profilePersonalizationTitle,
            token: AppTextStyleToken.h3,
          ),
          const SizedBox(height: AppSpacing.s1),
          AppText(
            l10n.profilePersonalizationSubtitle,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          child,
        ],
      ),
    );

    return switch (async) {
      AsyncData(:final value) => card(
        value == null
            ? AppText(
                l10n.profilePersonalizationEmpty,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreferencesSummary(preferences: value),
                  const SizedBox(height: AppSpacing.s5),
                  AppButton(
                    label: l10n.profilePersonalizationEdit,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        context.push(AppRoutes.profilePersonalization),
                  ),
                ],
              ),
      ),
      AsyncError() => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.profilePersonalizationLoadIssue,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            AppButton(
              label: l10n.commonRetry,
              variant: AppButtonVariant.secondary,
              onPressed: () => ref.invalidate(onboardingPreferencesProvider),
            ),
          ],
        ),
      ),
      // Kompakt yükleme — ListView içinde sınırsız yükseklik istenmez.
      _ => card(
        const SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    };
  }
}

/// Tercih özeti: odak alanları (rozet sarmalı), yolculuk aşaması, tempo.
/// Etiketler onboarding localization metinleriyle AYNIDIR — enum `.name`
/// ekranda ASLA gösterilmez.
class _PreferencesSummary extends StatelessWidget {
  const _PreferencesSummary({required this.preferences});

  final OnboardingPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.profileFocusAreas,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s2),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final goal in preferences.goals)
              AppBadge(
                label: onboardingGoalLabel(l10n, goal),
                emphasized: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        AppText(
          l10n.profileJourneyStage,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s1),
        AppText(onboardingJourneyStageLabel(l10n, preferences.journeyStage)),
        const SizedBox(height: AppSpacing.s4),
        AppText(
          l10n.profileDailyPace,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s1),
        AppText(onboardingDailyPaceLabel(l10n, preferences.dailyPace)),
      ],
    );
  }
}

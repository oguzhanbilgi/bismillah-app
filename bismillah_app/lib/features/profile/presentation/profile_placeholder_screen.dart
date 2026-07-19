import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_preferences_provider.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_option_labels.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:bismillah_app/shared/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile sekmesi — ilk gerçek içerik: kişiselleştirme özeti (TASK 029,
/// SALT-OKUNUR; düzenleme TASK 030). İstatistik/rozet sonraki görevlerde.
///
/// TASK 055: ayarlar (dil + abonelik) tonal [SettingsSection] grubunda
/// toplanır — her satır ayrı ağır kart değildir. Route'lar ve işlevler
/// AYNEN korunur; puan/dini başarı seviyesi EKLENMEZ.
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabProfile,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s5),
          // Kompakt kişisel yolculuk alanı — sıcak kum yüzeyinde.
          const _PersonalizationCard(),
          const SizedBox(height: AppSpacing.s6),
          const _SettingsGroup(),
          const SizedBox(height: AppSpacing.s5),
          Center(
            child: AppText(
              l10n.placeholderComingSoon,
              token: AppTextStyleToken.caption,
              secondary: true,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}

/// Ayar grubu (TASK 055): dil ve abonelik tek tonal yüzeyde. Mevcut
/// route'lar korunur; premium satırı sakindir — altın/paywall baskısı YOK.
class _SettingsGroup extends ConsumerWidget {
  const _SettingsGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(appLocaleProvider);

    return SettingsSection(
      title: l10n.profileSettingsSection,
      rows: [
        // Dil satırı: seçili dil KENDİ adıyla ve KENDİ yönünde gösterilir.
        SettingsRow(
          leadingIcon: Icons.language_outlined,
          title: l10n.settingsLanguageTitle,
          value: selected.nativeName,
          valueDirection: selected.isRtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          onTap: () => context.push(AppRoutes.languageSettings),
        ),
        SettingsRow(
          leadingIcon: Icons.workspace_premium_outlined,
          title: l10n.subscriptionSettingsTitle,
          onTap: () => context.push(AppRoutes.subscriptionSettings),
        ),
      ],
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

    // TASK 055: kişisel yolculuk alanı sıcak kum yüzeyinde — Profile
    // "beyaz kart yığını" gibi okunmaz.
    Widget card(Widget child) => AppCard(
      variant: AppCardVariant.sand,
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

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
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

/// Profile sekmesi — public alpha için işlevsel ayar ve veri merkezi
/// (TASK 058).
///
/// Bölümler: kişisel yolculuk (salt-okunur özet), Uygulama, Namaz, Kur'an,
/// Öğren ve Destek. Namaz/Kur'an/Öğren satırları MEVCUT çalışan route'lara
/// gider (yeni ürün özelliği yoktur). Dinî puan/seviye ve premium baskısı
/// EKLENMEZ; çalışmayan (abonelik/asistan/sync) satır gösterilmez.
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.tabProfile,
      body: ListView(
        children: const [
          SizedBox(height: AppSpacing.s5),
          _JourneyCard(),
          SizedBox(height: AppSpacing.s6),
          _AppSection(),
          SizedBox(height: AppSpacing.s5),
          _PrayerSection(),
          SizedBox(height: AppSpacing.s5),
          _QuranSection(),
          SizedBox(height: AppSpacing.s5),
          _LearnSection(),
          SizedBox(height: AppSpacing.s5),
          _SupportSection(),
          SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Uygulama
// ---------------------------------------------------------------------------

class _AppSection extends ConsumerWidget {
  const _AppSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(appLocaleProvider);

    return SettingsSection(
      title: l10n.profileAppSection,
      rows: [
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
          leadingIcon: Icons.notifications_outlined,
          title: l10n.settingsNotificationsTitle,
          value: l10n.settingsNotificationsSubtitle,
          // Bildirimler = namaz hatırlatmaları; ayarı Namaz ekranında yaşar.
          onTap: () => context.go(AppRoutes.prayer),
        ),
        SettingsRow(
          leadingIcon: Icons.privacy_tip_outlined,
          title: l10n.settingsPrivacyDataTitle,
          onTap: () => context.push(AppRoutes.profilePrivacy),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Namaz — mevcut Prayer route/controller'larına kısayol
// ---------------------------------------------------------------------------

class _PrayerSection extends StatelessWidget {
  const _PrayerSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.profilePrayerSection,
      rows: [
        SettingsRow(
          leadingIcon: Icons.schedule_outlined,
          title: l10n.profilePrayerTimesRow,
          value: l10n.profilePrayerTimesSubtitle,
          onTap: () => context.go(AppRoutes.prayer),
        ),
        SettingsRow(
          leadingIcon: Icons.history_outlined,
          title: l10n.profilePrayerTrackingRow,
          value: l10n.profilePrayerTrackingSubtitle,
          onTap: () => context.go(AppRoutes.prayerHistory),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kur'an — mevcut Quran route/controller'larına kısayol
// ---------------------------------------------------------------------------

class _QuranSection extends StatelessWidget {
  const _QuranSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.profileQuranSection,
      rows: [
        SettingsRow(
          leadingIcon: Icons.menu_book_outlined,
          title: l10n.profileQuranPreferencesRow,
          value: l10n.profileQuranPreferencesSubtitle,
          onTap: () => context.go(AppRoutes.quran),
        ),
        SettingsRow(
          leadingIcon: Icons.bookmark_outline,
          title: l10n.profileQuranSavedRow,
          value: l10n.profileQuranSavedSubtitle,
          onTap: () => context.go(AppRoutes.quranBookmarks),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Öğren — sayaçlar LearningProgress state'inden hesaplanır (hard-code YOK)
// ---------------------------------------------------------------------------

class _LearnSection extends ConsumerWidget {
  const _LearnSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress =
        ref.watch(learnProgressProvider).asData?.value ??
        LearningProgress.empty;

    // Son okunan içerik: id → başlık/slug çözümü (varsa gerçek route'a gider).
    // Tek id sorgulandığından liste en çok bir yayınlanmış içerik döndürür;
    // içerik pending/bulunamazsa satır sakin boş duruma düşer.
    final lastId = progress.lastOpenedArticleId;
    final lastArticles = lastId == null
        ? null
        : ref.watch(learnArticlesByIdsProvider([lastId])).asData?.value;
    final lastArticle = (lastArticles == null || lastArticles.isEmpty)
        ? null
        : lastArticles.first;

    return SettingsSection(
      title: l10n.profileLearnSection,
      rows: [
        SettingsRow(
          leadingIcon: Icons.bookmarks_outlined,
          title: l10n.profileLearnSavedRow,
          value: '${progress.bookmarkedArticleIds.length}',
          onTap: () => context.go(AppRoutes.learn),
        ),
        SettingsRow(
          leadingIcon: Icons.check_circle_outline,
          title: l10n.profileLearnCompletedRow,
          value: '${progress.completedArticleIds.length}',
          onTap: () => context.go(AppRoutes.learn),
        ),
        SettingsRow(
          leadingIcon: Icons.auto_stories_outlined,
          title: l10n.profileLearnLastReadRow,
          value: lastArticle?.title ?? l10n.profileLearnLastReadEmpty,
          // İçerik yoksa satır etkin değildir — boş ekran açmaz.
          onTap: lastArticle == null
              ? null
              : () => context.go(AppRoutes.learnArticlePath(lastArticle.slug)),
        ),
        SettingsRow(
          leadingIcon: Icons.verified_outlined,
          title: l10n.profileLearnSourcesRow,
          value: l10n.profileLearnSourcesSubtitle,
          onTap: () => context.push(AppRoutes.profileSources),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Destek ve uygulama
// ---------------------------------------------------------------------------

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      title: l10n.profileSupportSection,
      rows: [
        SettingsRow(
          leadingIcon: Icons.info_outline,
          title: l10n.profileAboutRow,
          onTap: () => context.push(AppRoutes.profileAbout),
        ),
        SettingsRow(
          leadingIcon: Icons.menu_book_outlined,
          title: l10n.sourcesTitle,
          onTap: () => context.push(AppRoutes.profileSources),
        ),
        SettingsRow(
          leadingIcon: Icons.privacy_tip_outlined,
          title: l10n.profilePrivacyApproachRow,
          onTap: () => context.push(AppRoutes.profilePrivacy),
        ),
        SettingsRow(
          leadingIcon: Icons.description_outlined,
          title: l10n.profileLicensesRow,
          onTap: () =>
              showLicensePage(context: context, applicationName: l10n.appTitle),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kişisel yolculuk — SALT-OKUNUR onboarding özeti + yerel kullanım notu
// ---------------------------------------------------------------------------

class _JourneyCard extends ConsumerWidget {
  const _JourneyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(onboardingPreferencesProvider);

    Widget card(Widget child) => AppCard(
      variant: AppCardVariant.sand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.profileJourneySection, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s1),
          AppText(
            l10n.profileLocalUsageBody,
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

/// Tercih özeti: odak alanları (rozet), yolculuk aşaması, tempo. Etiketler
/// onboarding localization metinleriyle AYNIDIR — enum `.name` gösterilmez.
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

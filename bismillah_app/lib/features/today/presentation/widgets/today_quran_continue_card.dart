import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/quran/application/quran_preferences_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today "Kur'an'a devam et" kartı (TASK 038) — SALT-OKUNUR.
///
/// TASK 036 konum ve TASK 033 tercih sağlayıcılarından beslenir; Today
/// asla bloklanmaz: yükleme/tercih hatasında kart sessizce gizlenir,
/// konum hatası "henüz konum yok" gibi davranır. Sahte ayet numarası
/// veya tamamlanma oranı GÖSTERİLMEZ.
class TodayQuranContinueCard extends ConsumerWidget {
  const TodayQuranContinueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefsAsync = ref.watch(quranPreferencesControllerProvider);

    // Tercihler yüklenirken/hatalıyken kart gizlenir (sessiz fallback) —
    // alt boşluk kartla birlikte yaşar, kartlar arası boşluk sabit kalır.
    if (prefsAsync.isLoading || prefsAsync.hasError) {
      return const SizedBox.shrink();
    }
    final preferences = prefsAsync.value?.savedPreferences;

    if (preferences == null) {
      // Kur'an kurulumu tamamlanmamış: sakin davet.
      return _withBottomSpacing(
        _card(
          l10n,
          line: l10n.todayQuranSetupLine,
          ctaLabel: l10n.todayCtaGoQuran,
          onTap: () => context.go(AppRoutes.quran),
        ),
      );
    }

    final continueAsync = ref.watch(quranContinueReadingProvider);
    if (continueAsync.isLoading) {
      return const SizedBox.shrink();
    }
    final resume = continueAsync.value; // hata → null (konum yok davranışı)

    if (resume == null) {
      return _withBottomSpacing(
        _card(
          l10n,
          line: l10n.todayQuranEmptyLine,
          ctaLabel: l10n.todayQuranStartCta,
          onTap: () => context.go(AppRoutes.quran),
        ),
      );
    }

    final goal = preferences.goal;
    final goalLabel = switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesCount(goal.amount),
      QuranReadingGoalType.pages => l10n.quranPagesCount(goal.amount),
    };
    return _withBottomSpacing(
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.todayQuranContinueTitle,
              token: AppTextStyleToken.h3,
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                Expanded(
                  child: AppText(resume.chapter.transliteratedName),
                ),
                const SizedBox(width: AppSpacing.s3),
                AppText(resume.chapter.arabicName),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            AppText(
              l10n.todayQuranDailyGoal(goalLabel),
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s5),
            AppButton(
              label: l10n.quranResumeTitle,
              variant: AppButtonVariant.secondary,
              // Alt route hiyerarşisi sayesinde geri Kur'an sekmesine döner.
              onPressed: () => context.go(
                AppRoutes.quranChapterPath(resume.chapter.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    AppLocalizations l10n, {
    required String line,
    required String ctaLabel,
    required VoidCallback onTap,
  }) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.todayQuranContinueTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s2),
        AppText(line, token: AppTextStyleToken.bodySmall, secondary: true),
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: ctaLabel,
          variant: AppButtonVariant.secondary,
          onPressed: onTap,
        ),
      ],
    ),
  );

  static Widget _withBottomSpacing(Widget child) => Column(
    children: [
      child,
      const SizedBox(height: AppSpacing.s4),
    ],
  );
}

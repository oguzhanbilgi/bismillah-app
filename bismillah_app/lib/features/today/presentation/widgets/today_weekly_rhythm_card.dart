import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/prayer/application/prayer_history_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_history_state.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today panosundaki haftalık namaz ritmi kartı — SALT-OKUNUR (TASK 025).
///
/// TASK 024'ün `prayerHistoryControllerProvider`'ını AYNEN paylaşır — ikinci
/// bir haftalık sistem/sorgu KURULMAZ. Streak/puan/rozet yoktur; kayıt
/// olmayan gün sakin boş göstergedir (suçlayıcı dil yasak, CLAUDE.md ton).
/// Hiçbir veri yazmaz, SyncOperation üretmez.
class TodayWeeklyRhythmCard extends ConsumerWidget {
  const TodayWeeklyRhythmCard({super.key, required this.onSeeHistory});

  /// CTA: geçmiş ekranına geçiş (navigasyon kararı ekranın işidir).
  final VoidCallback onSeeHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(prayerHistoryControllerProvider);
    final state = async.value;

    if (async.isLoading && state == null) {
      // ListView içinde sınırsız yükseklik istememek için kompakt gösterge.
      return _card(
        l10n,
        const SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state == null) {
      // Sakin yükleme sorunu durumu — kırmızı/hata tonu yok; geçmiş
      // ekranından tekrar denenebilir.
      return _card(
        l10n,
        AppText(
          l10n.todayLoadIssue,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
        ),
      );
    }

    final totalCompleted = state.days.fold<int>(
      0,
      (sum, day) => sum + day.completedCount,
    );
    final totalPossible = state.days.length * PrayerHistoryDay.totalCount;

    return _card(
      l10n,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.todayPrayerProgress(totalCompleted, totalPossible),
            token: AppTextStyleToken.stat,
          ),
          const SizedBox(height: AppSpacing.s4),
          _WeekBars(days: state.days),
        ],
      ),
    );
  }

  Widget _card(AppLocalizations l10n, Widget child) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.prayerHistoryTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s1),
        AppText(
          l10n.todayWeeklyRhythmLine,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s4),
        child,
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: l10n.todayWeeklyHistoryCta,
          variant: AppButtonVariant.secondary,
          onPressed: onSeeHistory,
        ),
      ],
    ),
  );
}

/// 7 kompakt dikey sütun — eski gün solda, bugün sağda. Dolgu zümrüt
/// (`scheme.primary`), ray krem (`ext.surfaceAlt`) — AppProgressBar ile
/// aynı token çifti; %0 bile estetiktir, utandırmaz (03_DESIGN_SYSTEM §20).
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.days});

  /// Yeni → eski sıralı gelir (TASK 024 state sözleşmesi).
  final List<PrayerHistoryDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final material = MaterialLocalizations.of(context);

    return Row(
      children: [
        for (final day in days.reversed) ...[
          Expanded(
            child: Semantics(
              label:
                  '${material.formatMediumDate(day.date)} — '
                  '${l10n.todayPrayerProgress(day.completedCount, PrayerHistoryDay.totalCount)}',
              child: ClipRRect(
                borderRadius: AppRadius.smAll,
                child: SizedBox(
                  height: AppSpacing.s8,
                  child: ColoredBox(
                    color: ext.surfaceAlt,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: day.progress,
                        widthFactor: 1,
                        child: ColoredBox(color: scheme.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (day != days.first) const SizedBox(width: AppSpacing.s2),
        ],
      ],
    );
  }
}

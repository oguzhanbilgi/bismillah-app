import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_state.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Today panosundaki namaz özeti kartı — SALT-OKUNUR.
///
/// İlerleme sakin sunulur: 0/5 bile utandırmaz (AppProgressBar'ın boş
/// rayı estetiktir, 03_DESIGN_SYSTEM §20); kırmızı/uyarı durumu yoktur.
class TodayPrayerSummaryCard extends StatelessWidget {
  const TodayPrayerSummaryCard({
    super.key,
    required this.state,
    required this.onGoToPrayers,
  });

  final TodayPrayerSummaryState state;

  /// CTA: Namaz sekmesine geçiş (navigasyon kararı ekranın işidir).
  final VoidCallback onGoToPrayers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  l10n.todayPrayerCardTitle,
                  token: AppTextStyleToken.h3,
                ),
              ),
              AppBadge(label: state.dayKey.value),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.todayPrayerProgress(
              state.completedCount,
              TodayPrayerSummaryState.totalCount,
            ),
            token: AppTextStyleToken.stat,
          ),
          const SizedBox(height: AppSpacing.s3),
          AppProgressBar(
            value: state.progress,
            semanticLabel: l10n.todayPrayerCardTitle,
          ),
          const SizedBox(height: AppSpacing.s5),
          AppButton(
            label: l10n.todayGoToPrayers,
            variant: AppButtonVariant.secondary,
            onPressed: onGoToPrayers,
          ),
        ],
      ),
    );
  }
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/prayer/application/prayer_history_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_history_state.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Son 7 gün namaz geçmişi — SALT-OKUNUR (TASK 024).
///
/// Prayer branch içinde push route; geri dönüş AppBar'ın standart geri
/// davranışıyla Prayer ekranına döner (alt navigasyon görünür kalır).
/// Hiçbir veri YAZMAZ; işaretleme/sync kuyruğuna dokunmaz.
class PrayerHistoryScreen extends ConsumerWidget {
  const PrayerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(prayerHistoryControllerProvider);

    return AppScaffold(
      title: l10n.prayerHistoryTitle,
      body: switch (async) {
        AsyncData(:final value) => ListView(
          children: [
            AppText(
              l10n.prayerHistorySubtitle,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s5),
            for (final day in value.days) ...[
              _HistoryDayCard(day: day),
              const SizedBox(height: AppSpacing.s3),
            ],
            const SizedBox(height: AppSpacing.s7),
          ],
        ),
        AsyncError() => AppErrorState(
          message: l10n.prayerLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(prayerHistoryControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// Tek gün kartı: yerelleştirilmiş kısa tarih + X/5 + sakin ilerleme çubuğu.
/// 0/5 utandırmaz — boş ray estetiktir (03_DESIGN_SYSTEM §20).
class _HistoryDayCard extends StatelessWidget {
  const _HistoryDayCard({required this.day});

  final PrayerHistoryDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Tarih yerelleştirmesi Flutter'ın kendi mekanizmasıyla (GlobalMaterial
    // Localizations kayıtlı — tr/en/ar): manuel ay tablosu tutulmaz.
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(day.date);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: AppText(dateLabel, token: AppTextStyleToken.h3)),
              const SizedBox(width: AppSpacing.s2),
              AppText(
                l10n.todayPrayerProgress(
                  day.completedCount,
                  PrayerHistoryDay.totalCount,
                ),
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          AppProgressBar(value: day.progress, semanticLabel: dateLabel),
        ],
      ),
    );
  }
}

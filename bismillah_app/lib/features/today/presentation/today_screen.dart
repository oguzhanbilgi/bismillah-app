import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_controller.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_next_prayer_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_quran_center_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_small_step_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_weekly_rhythm_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today sekmesi — ilk gerçek pano içeriği (TASK 017): bugünün namaz
/// özeti. SALT-OKUNUR; yazma yalnız Prayer sekmesindedir ve iki ekran
/// aynı lokal kaynağı izler (tek doğruluk kaynağı, 06 §14).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(todayPrayerSummaryControllerProvider);

    return AppScaffold(
      title: l10n.tabToday,
      body: switch (asyncState) {
        AsyncData(:final value) => ListView(
          children: [
            AppSectionHeader(title: l10n.todayGreeting),
            AppText(
              l10n.todayGentleLine,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s5),
            TodayPrayerSummaryCard(
              state: value,
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s4),
            TodayNextPrayerCard(
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s4),
            // Kart gizliyken (tercih yok/yükleme/hata) kendi alt boşluğunu
            // da gizler — kartlar arası boşluk sabit kalır.
            const TodaySmallStepCard(),
            const TodayQuranCenterCard(),
            TodayWeeklyRhythmCard(
              onSeeHistory: () => context.go(AppRoutes.prayerHistory),
            ),
            const SizedBox(height: AppSpacing.s5),
            Center(
              child: AppText(
                l10n.todayLocalNote,
                token: AppTextStyleToken.caption,
                secondary: true,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.s7),
          ],
        ),
        AsyncError() => AppErrorState(
          message: l10n.todayLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(todayPrayerSummaryControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

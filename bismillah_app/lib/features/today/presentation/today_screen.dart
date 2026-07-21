import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_controller.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_daily_verse_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_next_prayer_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_quran_center_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_small_step_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_spiritual_hero.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_weekly_rhythm_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today sekmesi — bugünün namaz özeti (TASK 017) + manevi hero ve günün
/// ayeti (TASK 052). SALT-OKUNUR; yazma yalnız Prayer sekmesindedir ve iki
/// ekran aynı lokal kaynağı izler (tek doğruluk kaynağı, 06 §14).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  /// Hero aksiyonunun odaklandığı namaz bölümü — yeni route AÇILMAZ,
  /// yalnız mevcut Today içeriğine kaydırılır.
  final GlobalKey _prayerSectionKey = GlobalKey();

  void _scrollToPrayerSection() {
    final context = _prayerSectionKey.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: AppMotion.standard,
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(todayPrayerSummaryControllerProvider);

    return AppScaffold(
      title: l10n.tabToday,
      body: switch (asyncState) {
        AsyncData(:final value) => ListView(
          children: [
            AppSectionHeader(title: l10n.todayGreeting),
            // 1) Manevi hero — kompakt; namaz kartlarını gizlemez.
            TodaySpiritualHero(onSeeTodaysPlan: _scrollToPrayerSection),
            // 2) Sıradaki namaz ÖNCE gelir (TASK 054): Today'in en somut
            // sorusu "şimdi ne var?" — hero'nun hemen altında, ilk
            // viewport'ta görünür. Günlük özet onu destekler.
            TodayNextPrayerCard(
              key: _prayerSectionKey,
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s4),
            TodayPrayerSummaryCard(
              state: value,
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s4),
            // 3) Bugünün Ayeti — kaynaklı, deterministik.
            const TodayDailyVerseCard(),
            // 4) "Bugünkü yolculuğun": Kur'an merkezi, kişisel öneri ve
            // haftalık ritim tek anlamlı grup altında toplanır — ekran
            // bağlantısız kart yığını gibi okunmaz.
            AppSectionHeader(title: l10n.todayJourneyTitle),
            const TodayQuranCenterCard(),
            // 5) Kişiselleştirilmiş öneri — kart gizliyken kendi alt
            // boşluğunu da gizler (kartlar arası boşluk sabit kalır).
            const TodaySmallStepCard(),
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

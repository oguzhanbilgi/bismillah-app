import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_controller.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_daily_verse_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_next_prayer_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_plan_section.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_quran_center_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_section_label.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today sekmesi — SALT-OKUNUR; yazma yalnız Prayer sekmesindedir ve iki
/// ekran aynı lokal kaynağı izler (tek doğruluk kaynağı, 06 §14).
///
/// RDX-01C2: ekran üç çapa etrafında kurulur — sıradaki namaz, günlük plan
/// ve günün ayeti. Motive edici büyük hero, "küçük bir adım" önerisi ve
/// haftalık ritim kutusu bu hiyerarşiden ÇIKARILDI; sıradaki namaz artık
/// listenin başında olduğu için ona kaydıran yardımcı da gerekmiyor.
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
            // RDX-01C1: karşılama artık bir "bölüm başlığı" değil; AppBar'daki
            // ekran adının altına oturan sakin bir alt satırdır. Önceki
            // `AppSectionHeader` hiçbir bölümü başlatmadığı hâlde h3 ağırlığı
            // ve s7 üst boşluğu getiriyordu — referanstaki başlık/alt satır
            // hiyerarşisi bunun tersini ister.
            //
            // RDX-01C3: karşılama satırı bir kademe daha geri çekilir
            // (`secondary` → `tertiary`). AppBar'daki "Bugün" başlığıyla
            // arasındaki ağırlık farkı böylece net olur; iki satır aynı
            // güçte iki başlık gibi okunmaz. Satır dekoratiftir — tek başına
            // taşıdığı kritik bir bilgi yoktur.
            const SizedBox(height: AppSpacing.s1),
            AppText(
              l10n.todayGreeting,
              token: AppTextStyleToken.caption,
              tone: AppTextTone.tertiary,
            ),
            const SizedBox(height: AppSpacing.s4),
            // RDX-01C2: Today artık ÜÇ çapa etrafında kurulur — sıradaki
            // namaz, günlük plan, günün ayeti. Onaylanan referansta motive
            // edici büyük yeşil hero, "küçük bir adım" önerisi ve haftalık
            // ritim kutusu YOKTUR; üçü de ilk viewport'u doldurup asıl
            // içeriği aşağı itiyordu. Widget'lar silinmedi (RTL kabuk
            // testleri ve olası yeniden kullanım için durur), yalnız Today
            // hiyerarşisinden çıkarıldı.
            //
            // 1) Sıradaki namaz — ekranın hero'su. "Şimdi ne var?" sorusu
            // ilk ekranda cevaplanır.
            TodayNextPrayerCard(
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s3),
            // 2) Bugünün görevleri — DailyPlan durum makinesinin tek
            // yüzeyi (TASK 083). Plan ÜRETMEZ; yalnız kayıtlı günü gösterir.
            const TodayPlanSection(),
            // 3) Namaz özeti planı DESTEKLER; hero'yla yarışmaz.
            TodayPrayerSummaryCard(
              state: value,
              onGoToPrayers: () => context.go(AppRoutes.prayer),
            ),
            const SizedBox(height: AppSpacing.s3),
            // 4) Bugünün Ayeti — kaynaklı, deterministik; ekranı kapatır.
            const TodayDailyVerseCard(),
            // 5) Kur'an merkezi tek destekleyici blok olarak kalır.
            TodaySectionLabel(title: l10n.todayJourneyTitle),
            const TodayQuranCenterCard(),
            const SizedBox(height: AppSpacing.s4),
            Center(
              child: AppText(
                l10n.todayLocalNote,
                token: AppTextStyleToken.caption,
                secondary: true,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
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

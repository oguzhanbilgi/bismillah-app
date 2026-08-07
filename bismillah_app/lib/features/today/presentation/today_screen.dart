import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/today/application/today_greeting_provider.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_controller.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_brand_header.dart';
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
    final greeting = ref.watch(todayGreetingPeriodProvider);

    // RDX-02A: AppBar KALDIRILDI. Ekranın tepesinde artık jenerik bir ekran
    // adı ("Bugün" / "Günüm") değil, kompakt marka başlığı durur; navigasyon
    // etiketi ile ekran başlığı ayrı kavramlardır ve ikisi birden
    // gösterilmez. `AppScaffold` başlıksız çağrıldığında AppBar üretmez,
    // gövde doğrudan SafeArea'nın altından başlar.
    return AppScaffold(
      body: switch (asyncState) {
        AsyncData(:final value) => ListView(
          children: [
            TodayBrandHeader(
              onOpenProfile: () => context.go(AppRoutes.profile),
            ),
            // Tek sakin karşılama — gerçek namaz vakitlerinden seçilir.
            // İkinci bir başlık DEĞİLDİR: ikincil mürekkep ve gövde
            // boyutunda kalır (h1/h2 değil).
            AppText(
              l10n.greetingFor(greeting),
              token: AppTextStyleToken.bodySmall,
              tone: AppTextTone.secondary,
              maxLines: 2,
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

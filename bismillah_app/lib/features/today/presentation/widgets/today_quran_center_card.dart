import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/quran/application/quran_home_tab_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_progress_summary_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/today/application/today_quran_center_providers.dart';
import 'package:bismillah_app/shared/islamic/quran_on_rehal_illustration.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Today "Kur'an merkezi" (TASK 050) — SALT-OKUNUR tek bölüm.
///
/// Namaz odağını bozmadan tek bakışta: bugünkü hedef, gerçek ilerleme,
/// kalan miktar, seri, son okuma ve hızlı aksiyonlar. Tek gerçek kaynak
/// [quranProgressSummaryProvider]; Today asla bloklanmaz — yalnız Kur'an
/// bölümü yükleme/hata/boş durumlarını sakin biçimde ele alır. Ses
/// kontrolü yoktur (global mini player tek yüzeydir); içerik/meal metni
/// bu ekrana taşınmaz.
class TodayQuranCenterCard extends ConsumerWidget {
  const TodayQuranCenterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Yalnız özet alanını izler — Today ListView'ı bundan etkilenmez.
    final summaryAsync = ref.watch(quranProgressSummaryProvider);

    return switch (summaryAsync) {
      // Hedef kurulmamış → sakin başlangıç daveti (§6).
      AsyncData(:final value) =>
        value == null
            ? _startState(context, ref, l10n)
            : _centerState(context, ref, l10n, value),
      // Yerel ilerleme okuma hatası → sakin mesaj; aksiyonlar çalışır (§10).
      AsyncError() => _errorState(context, ref, l10n),
      // Yüklenirken bölüm sessizce gizlenir (§9): namaz içeriği görünür
      // kalır, Today'e sonsuz animasyon eklenmez — kısa yerel okumadır.
      _ => const SizedBox.shrink(),
    };
  }

  /// Bölüm kabuğu: "Bugünkü Kur'an" başlığı + opsiyonel İlerlemem eylemi +
  /// gövde + alt boşluk. Başlık AppSectionHeader'ın üst boşluğuyla önceki
  /// karttan ayrılır.
  Widget _shell(
    AppLocalizations l10n, {
    required Widget child,
    Widget? headerTrailing,
  }) => Column(
    children: [
      AppSectionHeader(
        title: l10n.todayQuranSectionTitle,
        trailing: headerTrailing,
      ),
      child,
      const SizedBox(height: AppSpacing.s4),
    ],
  );

  Widget _startState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => _shell(
    l10n,
    child: Column(
      children: [
        // Başlangıç daveti — rahle illüstrasyonu yalnız BURADA kullanılır:
        // kullanıcıyı Kur'an'a nazikçe çağıran tek anlık kompozisyon.
        _QuranIllustratedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(l10n.todayQuranStartCta, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.todayQuranStartBody,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s5),
              AppButton(
                label: l10n.todayQuranOpenCta,
                variant: AppButtonVariant.secondary,
                onPressed: () => _openQuranRead(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        // Ana kart zaten "Kur'an'ı aç" sunar — hızlı aksiyonda tekrar etme.
        const _TodayQuranQuickActions(showOpen: false),
      ],
    ),
  );

  Widget _errorState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => _shell(
    l10n,
    child: Column(
      children: [
        AppCard(
          child: AppText(
            l10n.todayQuranProgressUnavailable,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        const _TodayQuranQuickActions(),
      ],
    ),
  );

  Widget _centerState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    QuranProgressSummary summary,
  ) => _shell(
    l10n,
    headerTrailing: AppButton(
      label: l10n.quranTabProgress,
      variant: AppButtonVariant.text,
      onPressed: () => _openQuranProgress(context, ref),
    ),
    child: Column(
      children: [
        // Tek ana kart: hedef/ilerleme/seri + (varsa) devam satırı (§2).
        // Kur'an bölümü sakin adaçayı yüzeyinde yaşar — Today'deki namaz
        // kartlarından (kum) tonal olarak ayrışır, kart kalabalıklaşmaz.
        AppCard(
          variant: AppCardVariant.sage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodayQuranGoalSummary(summary: summary),
              const _TodayQuranContinueAction(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        const _TodayQuranQuickActions(),
      ],
    ),
  );
}

/// Rahle illüstrasyonlu Kur'an kartı (TASK 054).
///
/// İllüstrasyon DEKORATİFTİR ve sağ kenara sabitlenir; içerik her zaman
/// üstünde çizilir. Liste satırlarında DEĞİL, yalnız bu tek örneklik
/// davet kartında kullanılır (painter maliyeti tekrarlanmaz).
class _QuranIllustratedCard extends StatelessWidget {
  const _QuranIllustratedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.sage,
      child: Stack(
        children: [
          // Dekoratif katman: dar ekranda metnin okunmasını engellememesi
          // için sağ üstte sınırlı bir kutuya hapsedilir.
          const Positioned(
            top: 0,
            right: 0,
            width: 96,
            height: 96,
            child: QuranOnRehalIllustration(),
          ),
          child,
        ],
      ),
    );
  }
}

/// Günlük hedef/ilerleme/seri özeti (TASK 050) — tüm değerler
/// [quranProgressSummaryProvider]'dan; ikinci oran hesabı YOK.
class _TodayQuranGoalSummary extends StatelessWidget {
  const _TodayQuranGoalSummary({required this.summary});

  final QuranProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goal = summary.goal;
    final progressLabel = switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesProgress(
        summary.completedAmount,
        goal.amount,
      ),
      QuranReadingGoalType.pages => l10n.quranPagesProgress(
        summary.completedAmount,
        goal.amount,
      ),
    };
    final remainingLabel = switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesRemaining(
        summary.remainingAmount,
      ),
      QuranReadingGoalType.pages => l10n.quranPagesRemaining(
        summary.remainingAmount,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.quranTodayGoalTitle,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s3),
        if (summary.pageMappingUnavailable)
          // Sayfa eşlemesi doğrulanamadı: dakikaya sessizce dönüştürülmez.
          AppText(
            l10n.quranPageProgressUnavailable,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          )
        else ...[
          AppProgressBar(
            value: summary.goalProgressRatio,
            semanticLabel: progressLabel,
          ),
          const SizedBox(height: AppSpacing.s2),
          AppText(
            progressLabel,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s1),
          AppText(
            // Tamamlanmadıysa suçlayıcı/kırmızı dil YOK — sakin kalan.
            summary.isGoalCompleted
                ? l10n.quranGoalCompletedLine
                : remainingLabel,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        // Seri: sakin ve küçük; sıfırda gizlenir (suçlayıcı metin yok, §4).
        if (summary.currentStreakDays > 0) ...[
          const SizedBox(height: AppSpacing.s3),
          AppText(
            '${l10n.quranStreakTitle} · '
            '${l10n.quranDaysCount(summary.currentStreakDays)}',
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
        ],
      ],
    );
  }
}

/// Ana kart içindeki "Okumaya devam et" satırı (TASK 050).
///
/// [todayQuranResumeProvider] boş/yükleme/hata ise sessizce gizlenir —
/// kart yalnız hedef özetini gösterir; sahte konum ÜRETİLMEZ.
class _TodayQuranContinueAction extends ConsumerWidget {
  const _TodayQuranContinueAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final resume = ref.watch(todayQuranResumeProvider).value;
    if (resume == null) {
      return const SizedBox.shrink();
    }
    final verseKey = resume.verseKey;
    final title = verseKey == null
        ? resume.chapter.transliteratedName
        : '${resume.chapter.transliteratedName} · $verseKey';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s4),
        AppText(title, maxLines: 1),
        const SizedBox(height: AppSpacing.s3),
        AppButton(
          label: l10n.todayQuranResumeCta,
          variant: AppButtonVariant.secondary,
          onPressed: () {
            // TASK 048 helper'ı: ayet-odağı varsa hedef ayete, yoksa sure
            // konumuna. Alt route hiyerarşisi geri Kur'an sekmesine döner.
            final path = resume.verseNumber == null
                ? AppRoutes.quranChapterPath(resume.chapter.id)
                : AppRoutes.quranChapterVersePath(
                    resume.chapter.id,
                    resume.verseNumber!,
                  );
            context.go(path);
          },
        ),
      ],
    );
  }
}

/// Kompakt hızlı aksiyon satırı (TASK 050): Kur'an'ı aç · Kur'an'da ara ·
/// Kaydedilen ayetler. Dar ekranda Wrap ile taşmadan alt satıra iner.
/// Kayıt sayısı yalnız hafif anahtar kümesinden gelir (tam ayet listesi
/// yüklenmez, §12); yüklenemezse sayı olmadan gösterilir.
class _TodayQuranQuickActions extends ConsumerWidget {
  const _TodayQuranQuickActions({this.showOpen = true});

  /// Başlangıç durumunda ana kart zaten "Kur'an'ı aç" sunduğundan bu
  /// aksiyon gizlenir; diğer durumlarda görünür.
  final bool showOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Yalnız sayı değişince rebuild — hafif anahtar kümesi (§12/§13).
    final bookmarkCount = ref.watch(
      quranVerseBookmarksControllerProvider.select(
        (state) => state.value?.bookmarkedKeys.length,
      ),
    );
    final bookmarksLabel = bookmarkCount == null
        ? l10n.quranSavedVersesTitle
        : '${l10n.quranSavedVersesTitle} · $bookmarkCount';

    return Wrap(
      spacing: AppSpacing.s3,
      runSpacing: AppSpacing.s3,
      children: [
        if (showOpen)
          AppButton(
            label: l10n.todayQuranOpenCta,
            variant: AppButtonVariant.ghost,
            onPressed: () => _openQuranRead(context, ref),
          ),
        AppButton(
          label: l10n.quranSearchTitle,
          variant: AppButtonVariant.ghost,
          onPressed: () => _openQuranSearch(context, ref),
        ),
        AppButton(
          label: bookmarksLabel,
          variant: AppButtonVariant.ghost,
          onPressed: () => context.go(AppRoutes.quranBookmarks),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation — mevcut route/tab sözleşmeleri (yeni route YOK, §7/§8)
// ---------------------------------------------------------------------------

/// Kur'an sekmesine geçer ve Oku iç sekmesini hedefler.
void _openQuranRead(BuildContext context, WidgetRef ref) {
  ref.read(quranHomeTabProvider.notifier).request(QuranHomeTab.read);
  context.go(AppRoutes.quran);
}

/// "Kur'an'da ara": ayrı arama route'u YOK — Oku sekmesine geçer; arama
/// alanı sekmenin en üstünde görünür konumdadır (TASK 048).
void _openQuranSearch(BuildContext context, WidgetRef ref) {
  ref.read(quranHomeTabProvider.notifier).request(QuranHomeTab.read);
  context.go(AppRoutes.quran);
}

/// Kur'an sekmesine geçer ve İlerlemem iç sekmesini hedefler.
void _openQuranProgress(BuildContext context, WidgetRef ref) {
  ref.read(quranHomeTabProvider.notifier).request(QuranHomeTab.progress);
  context.go(AppRoutes.quran);
}

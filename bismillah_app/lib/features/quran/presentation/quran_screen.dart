import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/quran/application/quran_chapters_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_home_tab_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_preferences_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_progress_summary_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/application/quran_search_controller.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kur'an sekmesi (TASK 033) — profesyonel Kur'an deneyimi temeli:
/// kurulum tamamlanmamışsa üç adımlı iç kurulum (yazı biçimi → meal →
/// günlük hedef), tamamlanmışsa Oku / Öğren / İlerlemem iç sekmeleri.
/// Gerçek sure/ayet/meal/ses içeriği YOK (TASK 034+); streak/puan/
/// paywall YOK. Kurulum genel onboarding kapısına ve route stack'e
/// DOKUNMAZ.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranPreferencesControllerProvider);

    return AppScaffold(
      title: l10n.tabQuran,
      // Kaydedilen ayetler (TASK 038): yalnız kurulum tamamlanmışsa —
      // ikon her zaman gerçek route açar, işlevsiz ikon yok.
      actions: async.value?.savedPreferences == null
          ? null
          : [
              IconButton(
                tooltip: l10n.quranSavedVersesTitle,
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () => context.push(AppRoutes.quranBookmarks),
              ),
            ],
      body: switch (async) {
        AsyncData(:final value) =>
          value.savedPreferences == null
              ? _SetupFlow(state: value)
              : value.isEditingGoal
              ? _GoalEditView(state: value)
              : const _QuranHome(),
        AsyncError() => AppErrorState(
          message: l10n.quranGoalLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(quranPreferencesControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// Sure okuyucusunu açar; dönüşte devam kartı güncel konumu göstersin
/// diye kayıtlı konum provider'ı tazelenir (TASK 036).
Future<void> _openChapter(
  BuildContext context,
  WidgetRef ref,
  int chapterId,
) async {
  await context.push(AppRoutes.quranChapterPath(chapterId));
  if (context.mounted) {
    ref.invalidate(quranReadingPositionProvider);
  }
}

/// Arama sonucundan okuyucuyu HEDEF AYETLE açar (TASK 048): aynı reader
/// route'u `?verse=` sorgusuyla kullanılır — oynatma/mini player kesilmez.
Future<void> _openVerse(
  BuildContext context,
  WidgetRef ref,
  int chapterId,
  int verseNumber,
) async {
  await context.push(AppRoutes.quranChapterVersePath(chapterId, verseNumber));
  if (context.mounted) {
    ref.invalidate(quranReadingPositionProvider);
  }
}

/// Hedefin "3 sayfa" / "10 dakika" biçimli etiketi.
String _goalAmountLabel(AppLocalizations l10n, QuranReadingGoal goal) =>
    switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesCount(goal.amount),
      QuranReadingGoalType.pages => l10n.quranPagesCount(goal.amount),
    };

// ---------------------------------------------------------------------------
// Kur'an ana ekranı: Oku / Öğren / İlerlemem
// ---------------------------------------------------------------------------

final class _QuranHome extends ConsumerStatefulWidget {
  const _QuranHome();

  @override
  ConsumerState<_QuranHome> createState() => _QuranHomeState();
}

final class _QuranHomeState extends ConsumerState<_QuranHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _appliedRequestSeq;

  @override
  void initState() {
    super.initState();
    // Today hızlı aksiyonu ekran kurulmadan önce sekme istemiş olabilir —
    // ilk build o hedefle açılır (varsayılan Oku).
    final request = ref.read(quranHomeTabProvider);
    _appliedRequestSeq = request.seq;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: request.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    // Today'den gelen sekme isteği (TASK 050): yalnız yeni istek (seq
    // değişimi) sekmeyi değiştirir — elle yapılan sekme seçimi ezilmez,
    // aynı hedefe tekrar dokunmak yeniden odaklar.
    ref.listen<QuranHomeTabRequest>(quranHomeTabProvider, (previous, next) {
      if (next.seq != _appliedRequestSeq) {
        _appliedRequestSeq = next.seq;
        if (_tabController.index != next.index) {
          _tabController.animateTo(next.index);
        }
      }
    });

    return Column(
      children: [
        const SizedBox(height: AppSpacing.s3),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.quranTabRead),
            Tab(text: l10n.quranTabLearn),
            Tab(text: l10n.quranTabProgress),
          ],
          labelColor: scheme.primary,
          unselectedLabelColor: ext.textSecondary,
          indicatorColor: scheme.primary,
          dividerColor: Colors.transparent,
        ),
        const SizedBox(height: AppSpacing.s4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [_ReadTab(), _LearnTab(), _ProgressTab()],
          ),
        ),
      ],
    );
  }
}

/// Oku sekmesi — üstte offline Kur'an araması (TASK 048; sure adı/no,
/// ayet referansı, Arapça ve Türkçe meal içeriği), altında kaldığın yer
/// + doğrulanmış 114 surelik katalog. Alan boşken ekran aynen eski
/// davranışındadır; sorgu yazılınca sonuç görünümüne geçilir, temizle
/// normal ekrana döndürür. Sorgular hiçbir yere GÖNDERİLMEZ.
final class _ReadTab extends ConsumerStatefulWidget {
  const _ReadTab();

  @override
  ConsumerState<_ReadTab> createState() => _ReadTabState();
}

final class _ReadTabState extends ConsumerState<_ReadTab> {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchFieldController.clear();
    ref.read(quranSearchControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchState = ref.watch(quranSearchControllerProvider);
    final controller = ref.read(quranSearchControllerProvider.notifier);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.s2),
        Semantics(
          textField: true,
          label: l10n.quranSearchTitle,
          child: TextField(
            controller: _searchFieldController,
            onChanged: controller.setQuery,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => controller.submit(),
            decoration: InputDecoration(
              hintText: l10n.quranSearchFieldHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchState.isActive
                  ? IconButton(
                      tooltip: l10n.quranSearchClear,
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        Expanded(
          child: searchState.isActive
              ? _SearchResultsView(state: searchState)
              : _buildCatalog(l10n),
        ),
      ],
    );
  }

  Widget _buildCatalog(AppLocalizations l10n) {
    final async = ref.watch(quranChaptersProvider);
    return switch (async) {
      AsyncData(:final value) => _buildList(l10n, value),
      AsyncError() => AppErrorState(
        message: l10n.quranChaptersLoadIssue,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(quranChaptersProvider),
      ),
      _ => AppLoading(label: l10n.commonLoading),
    };
  }

  Widget _buildList(AppLocalizations l10n, List<QuranChapter> chapters) {
    return ListView.builder(
      itemCount: chapters.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Küçük günlük hedef özeti (TASK 047): dokunuş İlerlemem
              // sekmesine geçer; ana işlev sure listesi olarak kalır.
              const _ReadGoalSummaryCard(),
              AppText(l10n.quranResumeTitle, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s3),
              const _ContinueReadingCard(),
              const SizedBox(height: AppSpacing.s5),
              AppText(l10n.quranSurahsSection, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s3),
            ],
          );
        }
        final chapter = chapters[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s3),
          child: _ChapterRow(
            chapter: chapter,
            onTap: () => _openChapter(context, ref, chapter.id),
          ),
        );
      },
    );
  }
}

/// Arama sonuç görünümü (TASK 048): loading / hata / boş / bölümlenmiş
/// sonuçlar. Hata yalnız arama katmanını etkiler — katalog, bookmark,
/// progress ve ses sistemi AYNEN çalışır.
final class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({required this.state});

  final QuranSearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (state.failed) {
      return AppErrorState(
        message: l10n.quranSearchUnavailable,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.read(quranSearchControllerProvider.notifier).retry(),
      );
    }
    final response = state.response;
    if (response == null) {
      return state.isLoading
          ? AppLoading(label: l10n.quranSearchLoading)
          : const SizedBox.shrink();
    }
    if (response.isEmpty && !state.isLoading) {
      return ListView(
        children: [
          AppCard(
            child: AppText(
              l10n.quranSearchNoMatches,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        AppText(
          l10n.quranSearchResultCount(response.totalCount),
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        if (response.chapters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s4),
          AppText(l10n.quranSurahsSection, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s3),
          for (final chapter in response.chapters)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: _SearchChapterCard(result: chapter),
            ),
        ],
        if (response.verses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(l10n.quranSearchVersesSection, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s3),
          for (final verse in response.verses)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s3),
              child: _SearchVerseCard(result: verse),
            ),
        ],
        // Tek sakin kaynak satırı (kutsal içerik atfı) — her kartta
        // tekrarlanmaz.
        const SizedBox(height: AppSpacing.s2),
        const AppText(
          'Tanzil · QuranEnc Rowad',
          token: AppTextStyleToken.caption,
          secondary: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }
}

final class _SearchChapterCard extends ConsumerWidget {
  const _SearchChapterCard({required this.result});

  final QuranChapterSearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      onTap: () => _openChapter(context, ref, result.chapterId),
      child: Row(
        children: [
          AppBadge(label: '${result.chapterId}'),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(result.chapterName),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  l10n.quranAyahCount(result.verseCount),
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          AppText(result.arabicName, token: AppTextStyleToken.h3),
        ],
      ),
    );
  }
}

/// Ayet sonucu kartı: sure · verseKey, kısa ORİJİNAL Arapça (RTL) ve
/// Türkçe meal snippet'i. Dokunuş mevcut reader route'unu hedef ayetle
/// açar; oynatma/mini player etkilenmez.
final class _SearchVerseCard extends ConsumerWidget {
  const _SearchVerseCard({required this.result});

  final QuranVerseSearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.quranSearchGoToVerse,
      child: Tooltip(
        message: l10n.quranSearchGoToVerse,
        child: AppCard(
          onTap: () =>
              _openVerse(context, ref, result.chapterId, result.verseNumber),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                '${result.chapterName} · ${result.verseKey}',
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s2),
              Directionality(
                textDirection: TextDirection.rtl,
                child: AppText(result.arabicSnippet, maxLines: 2),
              ),
              if (result.translationSnippet.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: AppText(
                    result.translationSnippet,
                    token: AppTextStyleToken.bodySmall,
                    secondary: true,
                    maxLines: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kaldığın yerden devam et" kartı (TASK 036): kayıtlı konum + surenin
/// katalog bilgisi. Kayıt yoksa sakin boş durum; okuma hatasında sakin
/// mesaj. Ayet numarası GÖSTERİLMEZ — yalnız scroll konumu saklanıyor.
final class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranContinueReadingProvider);

    return switch (async) {
      AsyncData(:final value) =>
        value == null
            ? AppCard(
                child: AppText(
                  l10n.quranResumeEmpty,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
              )
            : AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            value.chapter.transliteratedName,
                            token: AppTextStyleToken.h3,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        AppText(
                          value.chapter.arabicName,
                          token: AppTextStyleToken.h3,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    AppButton(
                      label: l10n.quranResumeCta,
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          _openChapter(context, ref, value.chapter.id),
                    ),
                  ],
                ),
              ),
      AsyncError() => AppCard(
        child: AppText(
          l10n.quranPositionLoadIssue,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
        ),
      ),
      // Kompakt yükleme — hızlı prefs okuması, kart zıplatılmaz.
      _ => const AppCard(
        child: SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    };
  }
}

/// Tek sure satırı — mushaf numarası, ad, ayet sayısı + nüzul yeri ve
/// Arapça ad. Dokunma sure okuyucusunu açar (TASK 035/036).
final class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter, required this.onTap});

  final QuranChapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeLabel = switch (chapter.revelationPlace) {
      QuranRevelationPlace.meccan => l10n.quranRevelationMeccan,
      QuranRevelationPlace.medinan => l10n.quranRevelationMedinan,
    };

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppBadge(label: '${chapter.id}'),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(chapter.transliteratedName),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  '${l10n.quranAyahCount(chapter.verseCount)} · $placeLabel',
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          AppText(chapter.arabicName, token: AppTextStyleToken.h3),
        ],
      ),
    );
  }
}

/// Öğren sekmesi — yalnız profesyonel boş durum; sahte ders/dini içerik
/// OLUŞTURULMAZ.
final class _LearnTab extends StatelessWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(l10n.quranLearnTitle, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranLearnBody,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// İlerlemem sekmesi (TASK 047) — gerçek cihaz-lokal veriye bağlı:
/// bugünkü hedef, bugünkü aktivite, son 7 gün, seri ve devam kartı.
/// Yükleme/okuma hatasında sakin unavailable durumu — teknik detay YOK.
final class _ProgressTab extends ConsumerWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(quranProgressSummaryProvider);
    return switch (summaryAsync) {
      AsyncData(:final value) =>
        value == null
            // Savunmacı — bu görünüm kurulumsuz açılmaz.
            ? const SizedBox.shrink()
            : _ProgressView(summary: value),
      AsyncError() => ListView(
        children: [
          const SizedBox(height: AppSpacing.s2),
          AppCard(
            child: AppText(
              l10n.quranProgressUnavailable,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
          ),
        ],
      ),
      _ => AppLoading(label: l10n.commonLoading),
    };
  }
}

final class _ProgressView extends ConsumerWidget {
  const _ProgressView({required this.summary});

  final QuranProgressSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goal = summary.goal;
    final pagesUnavailable = summary.pageMappingUnavailable;
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

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        // Bugünkü hedef kartı
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTodayGoalTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s1),
              AppText(
                _goalAmountLabel(l10n, goal),
                token: AppTextStyleToken.h3,
              ),
              const SizedBox(height: AppSpacing.s3),
              if (pagesUnavailable)
                // Sayfa eşlemesi doğrulanamadı: dakikaya SESSİZCE
                // dönüştürülmez — kontrollü unavailable (TASK 047).
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
                  summary.isGoalCompleted
                      ? l10n.quranGoalCompletedLine
                      : remainingLabel,
                  token: AppTextStyleToken.bodySmall,
                  secondary: true,
                ),
              ],
              const SizedBox(height: AppSpacing.s4),
              AppButton(
                label: l10n.quranGoalEdit,
                variant: AppButtonVariant.secondary,
                onPressed: () => ref
                    .read(quranPreferencesControllerProvider.notifier)
                    .startGoalEdit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        // Bugünkü aktivite
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTodayActivityTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              _ActivityRow(
                label: l10n.quranActiveReadingLabel,
                value: l10n.quranMinutesCount(
                  summary.today.activeReadingSeconds ~/ 60,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              // "Okunan" değil "görüntülenen" — yanlış kesinlik yok.
              _ActivityRow(
                label: l10n.quranViewedVersesLabel,
                value: '${summary.today.viewedVerseKeys.length}',
              ),
              if (!pagesUnavailable) ...[
                const SizedBox(height: AppSpacing.s2),
                _ActivityRow(
                  label: l10n.quranViewedPagesLabel,
                  value: '${summary.today.viewedPageNumbers.length}',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        // Son 7 gün — token tabanlı küçük barlar; chart paketi YOK.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranLast7DaysTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final point in summary.last7Days)
                    _DayProgressColumn(point: point),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        // Kur'an hedefi serisi — sakin, suçlayıcı olmayan dil.
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranStreakTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s1),
              AppText(
                l10n.quranDaysCount(summary.currentStreakDays),
                token: AppTextStyleToken.h3,
              ),
            ],
          ),
        ),
        const _ProgressContinueCard(),
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }
}

final class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            label,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        AppText(value, token: AppTextStyleToken.bodySmall),
      ],
    );
  }
}

/// 7 günlük görünümde tek günün bar + gün numarası kolonu. Bugün
/// primarySoft rozetiyle ayırt edilir; tamamlanan gün dolu bar gösterir.
final class _DayProgressColumn extends StatelessWidget {
  const _DayProgressColumn({required this.point});

  final QuranDayProgressPoint point;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final dayLabel = '${int.parse(point.localDateKey.substring(8))}';
    return Semantics(
      label:
          '${point.localDateKey}: '
          '${(point.goalProgressRatio * 100).round()}%',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.s3,
            height: AppSpacing.s8,
            decoration: BoxDecoration(
              color: ext.surfaceAlt,
              borderRadius: AppRadius.pillAll,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: point.goalProgressRatio,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
            decoration: point.isToday
                ? BoxDecoration(
                    color: ext.primarySoft,
                    borderRadius: AppRadius.pillAll,
                  )
                : null,
            child: AppText(
              dayLabel,
              token: AppTextStyleToken.caption,
              secondary: !point.isToday,
            ),
          ),
        ],
      ),
    );
  }
}

/// İlerlemem "Okumaya devam et" kartı (TASK 047): son okunan sure/ayet
/// mevcutsa mevcut reader route'una götürür — yeni route YOK.
final class _ProgressContinueCard extends ConsumerWidget {
  const _ProgressContinueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(quranTodayProgressProvider).value;
    final chapterId = today?.lastChapterId;
    if (chapterId == null) {
      return const SizedBox.shrink();
    }
    final chapters = ref.watch(quranChaptersProvider).value;
    QuranChapter? chapter;
    for (final candidate in chapters ?? const <QuranChapter>[]) {
      if (candidate.id == chapterId) {
        chapter = candidate;
        break;
      }
    }
    if (chapter == null) {
      return const SizedBox.shrink();
    }
    final verseKey = today?.lastVerseKey;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(chapter.transliteratedName, token: AppTextStyleToken.h3),
            if (verseKey != null) ...[
              const SizedBox(height: AppSpacing.s1),
              AppText(
                verseKey,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
            ],
            const SizedBox(height: AppSpacing.s4),
            AppButton(
              label: l10n.quranResumeCta,
              variant: AppButtonVariant.secondary,
              onPressed: () => _openChapter(context, ref, chapter!.id),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oku sekmesindeki kompakt günlük hedef özeti (TASK 047): ilerleme +
/// kalan; dokunuş İlerlemem sekmesine geçer. Hedef/veri yoksa görünmez —
/// ekran dashboard'a boğulmaz.
final class _ReadGoalSummaryCard extends ConsumerWidget {
  const _ReadGoalSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(quranProgressSummaryProvider).value;
    if (summary == null) {
      return const SizedBox.shrink();
    }
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
    final supportLabel = summary.isGoalCompleted
        ? l10n.quranGoalCompletedLine
        : switch (goal.type) {
            QuranReadingGoalType.minutes => l10n.quranMinutesRemaining(
              summary.remainingAmount,
            ),
            QuranReadingGoalType.pages => l10n.quranPagesRemaining(
              summary.remainingAmount,
            ),
          };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s5),
      child: Semantics(
        button: true,
        label: l10n.quranTabProgress,
        child: AppCard(
          onTap: () => ref
              .read(quranHomeTabProvider.notifier)
              .request(QuranHomeTab.progress),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTodayGoalTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s2),
              if (summary.pageMappingUnavailable)
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
                  '$progressLabel · $supportLabel',
                  token: AppTextStyleToken.caption,
                  secondary: true,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Üç adımlı ilk kurulum (yalnız Kur'an sekmesi içinde)
// ---------------------------------------------------------------------------

final class _SetupFlow extends ConsumerWidget {
  const _SetupFlow({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);
    final step = state.currentSetupStep;
    const total = QuranPreferencesState.totalSetupSteps;
    final isLastStep = step == total;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppText(
          l10n.quranSetupStepLabel(step, total),
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s2),
        AppProgressBar(
          value: step / total,
          semanticLabel: l10n.quranSetupStepLabel(step, total),
        ),
        const SizedBox(height: AppSpacing.s6),
        ...switch (step) {
          1 => _scriptStep(l10n, controller),
          2 => _translationStep(l10n, controller),
          _ => [
            AppText(l10n.quranSetupGoalTitle, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s1),
            AppText(
              l10n.quranGoalSetupSupport,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s4),
            _GoalSelectionFields(state: state),
          ],
        },
        if (state.saveFailed) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.quranGoalSaveIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: isLastStep
              ? l10n.quranSetupFinishCta
              : l10n.quranSetupContinue,
          isLoading: state.isSaving,
          onPressed: !state.canContinueCurrentStep || state.isSaving
              ? null
              : isLastStep
              ? controller.completeSetup
              : controller.goToNextStep,
        ),
        if (step > 1) ...[
          const SizedBox(height: AppSpacing.s2),
          AppButton(
            label: l10n.quranSetupBack,
            variant: AppButtonVariant.text,
            onPressed: state.isSaving ? null : controller.goToPreviousStep,
          ),
        ],
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }

  List<Widget> _scriptStep(
    AppLocalizations l10n,
    QuranPreferencesController controller,
  ) => [
    AppText(l10n.quranSetupScriptTitle, token: AppTextStyleToken.h3),
    const SizedBox(height: AppSpacing.s4),
    OnboardingOptionCard(
      label: l10n.quranScriptUthmani,
      description: l10n.quranScriptUthmaniDesc,
      selected: state.selectedScript == QuranArabicScript.uthmani,
      onTap: () => controller.selectScript(QuranArabicScript.uthmani),
    ),
    const SizedBox(height: AppSpacing.s3),
    OnboardingOptionCard(
      label: l10n.quranScriptIndoPak,
      description: l10n.quranScriptIndoPakDesc,
      selected: state.selectedScript == QuranArabicScript.indopak,
      onTap: () => controller.selectScript(QuranArabicScript.indopak),
    ),
  ];

  List<Widget> _translationStep(
    AppLocalizations l10n,
    QuranPreferencesController controller,
  ) => [
    AppText(l10n.quranSetupTranslationTitle, token: AppTextStyleToken.h3),
    const SizedBox(height: AppSpacing.s4),
    OnboardingOptionCard(
      label: l10n.quranTranslationTurkish,
      description: l10n.quranTranslationTurkishDesc,
      selected: state.selectedTranslation == QuranTranslationPreference.turkish,
      onTap: () =>
          controller.selectTranslation(QuranTranslationPreference.turkish),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Hedef seçim alanları (kurulum 3. adımı + hedef düzenleme ortak)
// ---------------------------------------------------------------------------

final class _GoalSelectionFields extends ConsumerWidget {
  const _GoalSelectionFields({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);
    final type = state.selectedGoalType;

    String amountLabel(QuranReadingGoalType type, int amount) => switch (type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesCount(amount),
      QuranReadingGoalType.pages => l10n.quranPagesCount(amount),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingOptionCard(
          label: l10n.quranGoalTypeMinutes,
          selected: type == QuranReadingGoalType.minutes,
          onTap: () => controller.selectGoalType(QuranReadingGoalType.minutes),
        ),
        const SizedBox(height: AppSpacing.s3),
        OnboardingOptionCard(
          label: l10n.quranGoalTypePages,
          selected: type == QuranReadingGoalType.pages,
          onTap: () => controller.selectGoalType(QuranReadingGoalType.pages),
        ),
        if (type != null) ...[
          const SizedBox(height: AppSpacing.s5),
          for (final amount in QuranReadingGoal.supportedAmounts(type)) ...[
            OnboardingOptionCard(
              label: amountLabel(type, amount),
              selected: state.selectedGoalAmount == amount,
              onTap: () => controller.selectGoalAmount(amount),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
        ],
      ],
    );
  }
}

/// "Hedefi düzenle" görünümü — yalnız hedef; script ve meal tercihleri
/// KORUNUR, kaydedilmeden mevcut hedef silinmez.
final class _GoalEditView extends ConsumerWidget {
  const _GoalEditView({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppText(l10n.quranSetupGoalTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s1),
        AppText(
          l10n.quranGoalSetupSupport,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s4),
        _GoalSelectionFields(state: state),
        if (state.saveFailed) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.quranGoalSaveIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: l10n.quranGoalSaveCta,
          isLoading: state.isSaving,
          onPressed: state.selectedGoal == null || state.isSaving
              ? null
              : controller.saveGoalEdit,
        ),
        const SizedBox(height: AppSpacing.s2),
        AppButton(
          label: l10n.quranSetupBack,
          variant: AppButtonVariant.text,
          onPressed: state.isSaving ? null : controller.cancelGoalEdit,
        ),
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
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
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/islamic/quran_on_rehal_illustration.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_section_header.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kur'an sekmesi (TASK 033) — profesyonel Kur'an deneyimi temeli:
/// kurulum tamamlanmamışsa üç adımlı iç kurulum (yazı biçimi → meal →
/// günlük hedef), tamamlanmışsa Oku / Öğren / İlerlemem iç sekmeleri.
/// Kurulum genel onboarding kapısına ve route stack'e DOKUNMAZ.
///
/// ## RDX-04A kompozisyonu
///
/// Oku sekmesi üç kademeye ayrılır ve okuma sırası bu kademeleri izler:
///
/// 1. **Arama** — ekranın üstünde sabit kalır (TASK 048 sözleşmesi aynen).
/// 2. **Kaldığın yer** — kayıt varsa gerçek sure + tek devam aksiyonu;
///    kayıt yoksa sakin davet. Ekranın tek sıcak yüzeyi burasıdır.
/// 3. **Sure kataloğu** — 114 satır TEK gruplanmış yüzey gibi okunur ama
///    `ListView.builder` sanallaştırması KORUNUR.
///
/// TASK 054'ün gradient hero'su kaldırıldı: tasarım yönü gradient içermez ve
/// RDX-03A aynı kararı Namaz ekranında zaten verdi. `warmSectionGradient`
/// token'ı silinmedi — başka yüzeyler kullanmaya devam ediyor.
///
/// Bu ekran ücretsizdir: kilit, rozet, paywall, sayaç veya yükseltme çağrısı
/// YOKTUR. Arapça metin dekoratif animasyon ALMAZ.
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

    final tokens = IslamicVisualTokens.of(context);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.s3),
        // RDX-04A: seçili sekmenin dolu "hap"ı artık çıplak zeminde yüzmez —
        // tonal bir ray içinde oturur. Böylece üç sekme TEK bir kontrol
        // olarak okunur ve seçili olmayanlar da bir yüzeye ait görünür;
        // TASK 054'ün pil biçimi ve renk mantığı korunur.
        //
        // `isScrollable: false` üç sekmeyi eşit paylaştırır; RTL'de sıra
        // otomatik terslenir ve dar ekranda taşma olmaz.
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.sectionSurface,
            borderRadius: AppRadius.pillAll,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s1),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.quranTabRead),
                Tab(text: l10n.quranTabLearn),
                Tab(text: l10n.quranTabProgress),
              ],
              labelColor: scheme.onPrimary,
              unselectedLabelColor: ext.textSecondary,
              indicator: BoxDecoration(
                color: tokens.spiritualGreen,
                borderRadius: AppRadius.pillAll,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashBorderRadius: AppRadius.pillAll,
              // Etiket uzun dillerde (Arapça/Türkçe) sıkışmasın diye dolgu
              // dar tutulur; dokunma alanı Tab'ın kendi yüksekliğiyle
              // korunur.
              labelPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s1,
              ),
            ),
          ),
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
        // Arama hero'nun hemen ALTINDA kalır: sıcak, yüksek kontrastlı
        // yüzey (TASK 054). İşlev ve controller sözleşmesi DEĞİŞMEDİ.
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
              filled: true,
              fillColor: IslamicVisualTokens.of(context).sacredSurface,
              border: OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: BorderSide(
                  color: IslamicVisualTokens.of(context).surfaceBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: BorderSide(
                  color: IslamicVisualTokens.of(context).surfaceBorder,
                ),
              ),
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

  /// RDX-04A: liste HÂLÂ `ListView.builder`'dır — 114 satır tembel kurulur.
  ///
  /// Satırlar "tek yüzey" gibi okunsun diye kartın içine TOPLANMAZ (bir
  /// `Column` 114 satırın hepsini bir anda kurardı); bunun yerine her satır
  /// aynı yüzey rengini taşır, aralarında saç teli ayraç vardır ve yalnız
  /// ilk/son satır köşe yuvarlar. Sonuç görsel olarak tek bir gruplanmış
  /// yüzeydir, maliyet olarak hâlâ sanallaştırılmış listedir.
  Widget _buildList(AppLocalizations l10n, List<QuranChapter> chapters) {
    return ListView.builder(
      itemCount: chapters.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RDX-04A: gradient hero KALDIRILDI (RDX-03A'nın Namaz
              // ekranında verdiği kararla aynı gerekçe — tasarım yönü
              // gradient içermez). Yerine kompakt bir "kaldığın yer" bloğu
              // geldi: kayıt varsa gerçek sureyi, yoksa daveti gösterir.
              const _QuranResumeBlock(),
              const SizedBox(height: AppSpacing.s4),
              // Küçük günlük hedef özeti (TASK 047): dokunuş İlerlemem
              // sekmesine geçer; ana işlev sure listesi olarak kalır.
              const _ReadGoalSummaryCard(),
              // RDX-04A: çıplak `h3` yerine paylaşılan bölüm başlığı —
              // sayı katalogdan okunur, sabit "114" YAZILMAZ.
              AppSectionHeader(
                title: l10n.quranSurahsSection,
                subtitle: l10n.quranSurahCount(chapters.length),
              ),
            ],
          );
        }
        // Son eleman: listenin altında nefes payı. Alt navigasyonun son
        // sureyi kesmemesi için satırların KENDİ dolgusuna eklenmez.
        if (index == chapters.length + 1) {
          return const SizedBox(height: AppSpacing.s7);
        }
        final chapter = chapters[index - 1];
        return _ChapterRow(
          chapter: chapter,
          isFirst: index == 1,
          isLast: index == chapters.length,
          onTap: () => _openChapter(context, ref, chapter.id),
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

/// Kur'an ana ekranının açılış bloğu (RDX-04A).
///
/// TASK 054'ün gradient hero'sunun yerini alır. Gerekçe RDX-03A'nın Namaz
/// ekranında verdiği kararla aynıdır: tasarım yönü gradient/parlama
/// içermez ve blok, dekoratif bir başlık alanı değil KOMPAKT BİR BİLGİ
/// bloğudur. `warmSectionGradient` token'ı silinmedi — başka yüzeyler
/// kullanmaya devam ediyor.
///
/// İki AYRI durum vardır ve ikisi de dürüsttür:
///
/// - **Kayıtlı konum varsa** blok gerçek sureyi (Latin + Arapça ad) ve tek
///   bir devam aksiyonunu taşır. Küçük altın nokta yalnız BURADA yanar.
/// - **Kayıt yoksa** blok yalnız daveti gösterir ve rahle motifi bu sakin
///   durumda yaşar. Sahte veya yanıltıcı bir "devam" aksiyonu ÜRETİLMEZ.
///
/// Metinler AYET/HADİS DEĞİLDİR: tırnak içine alınmaz, kaynak etiketi
/// verilmez. Ayet numarası gösterilmez — yalnız scroll konumu saklanıyor.
final class _QuranResumeBlock extends ConsumerWidget {
  const _QuranResumeBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Yükleme/hata bloğu BLOKLAMAZ: davet metni her koşulda görünür,
    // yalnız devam satırı sessizce gizlenir.
    final resume = ref.watch(quranContinueReadingProvider).value;

    if (resume == null) {
      return const _QuranInvitationBlock();
    }

    final tokens = IslamicVisualTokens.of(context);

    return AppCard(
      variant: AppCardVariant.sand,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s4,
        AppSpacing.s5,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ResumeDot(),
              const SizedBox(width: AppSpacing.s2),
              Expanded(
                child: AppText(
                  l10n.quranHomeResumeEyebrow,
                  token: AppTextStyleToken.caption,
                  tone: AppTextTone.secondary,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppText(
                  resume.chapter.transliteratedName,
                  token: AppTextStyleToken.h3,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              // Arapça ad KENDİ yönünde çizilir (uygulama dili ne olursa
              // olsun) ve Kur'an vurgu rengini alır — sure satırlarıyla
              // aynı kural.
              Directionality(
                textDirection: TextDirection.rtl,
                child: AppText(
                  resume.chapter.arabicName,
                  token: AppTextStyleToken.h3,
                  color: tokens.quranAccent,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          AppButton(
            label: l10n.quranHomeContinueCta,
            onPressed: () => _openChapter(context, ref, resume.chapter.id),
          ),
        ],
      ),
    );
  }
}

/// Kayıtlı konum yokken görünen sakin davet (RDX-04A).
///
/// Rahle motifi YALNIZ burada yaşar: kart bu durumda gerçek bir içerik
/// taşımaz, motif de boşluğu doldurmak yerine ekrana kimlik verir. Kayıt
/// oluştuğunda blok gerçek bilgiye döner ve dekorasyona ihtiyaç kalmaz.
final class _QuranInvitationBlock extends StatelessWidget {
  const _QuranInvitationBlock();

  /// Motifin kapladığı sabit genişlik. Metin sütunu bu payı bırakır, böylece
  /// dar ekranda ve büyük yazı ölçeğinde motifle metin çakışmaz.
  static const double _motifWidth = 96;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppCard(
      variant: AppCardVariant.sand,
      padding: const EdgeInsets.all(AppSpacing.s5),
      child: Stack(
        children: [
          // Dekoratif rahle — YÖN DUYARLI kenarda (RTL'de sola geçer), sınırlı
          // kutuda, semantics dışı. `Positioned(right:)` kullanılsaydı Arapça
          // düzende metnin başladığı kenara oturur ve onunla çakışırdı.
          const PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: _motifWidth,
            child: QuranOnRehalIllustration(),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: _motifWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.quranHomeHeroTitle,
                  token: AppTextStyleToken.h3,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.s2),
                AppText(
                  l10n.quranHomeHeroBody,
                  token: AppTextStyleToken.bodySmall,
                  tone: AppTextTone.secondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Kaldığın yer" etiketinin başındaki küçük altın nokta.
///
/// Altının Kur'an ana ekranında göründüğü TEK yerdir; buton, kenarlık, kart
/// zemini veya metin rengi olarak altın KULLANILMAZ. Tamamen dekoratiftir —
/// taşıdığı hiçbir bilgi yoktur, etiket tek başına da eksiksiz okunur.
/// Namaz ekranındaki `_NowDot` ile aynı dili konuşur.
final class _ResumeDot extends StatelessWidget {
  const _ResumeDot();

  static const double _size = 6;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppThemeExtension.of(context).accentGold,
          borderRadius: AppRadius.pillAll,
        ),
        child: const SizedBox(width: _size, height: _size),
      ),
    );
  }
}

/// Tek sure satırı — mushaf numarası, ad, ayet sayısı + nüzul yeri ve
/// Arapça ad. Dokunma sure okuyucusunu açar (TASK 035/036).
///
/// ## RDX-04A yüzeyi
///
/// TASK 054 satırları çıplak zemine, yalnız alt ayraçla dizmişti; liste
/// teknik olarak sakin ama görsel olarak "yüzeysiz" duruyordu. Satırlar artık
/// ORTAK bir yüzey rengi taşır ve yalnız [isFirst]/[isLast] köşe yuvarlar, bu
/// yüzden 114 satır TEK gruplanmış yüzey gibi okunur.
///
/// Bu kasıtlı olarak satır başına çözülür, kartın içine toplanarak DEĞİL: tek
/// bir `AppCard` + `Column` 114 satırın tamamını bir anda kurardı ve
/// `ListView.builder`'ın sanallaştırması kaybolurdu.
final class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.chapter,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final QuranChapter chapter;
  final VoidCallback onTap;

  /// Gruplanmış yüzeyin ilk satırı mı? Üst köşeleri yuvarlar.
  final bool isFirst;

  /// Gruplanmış yüzeyin son satırı mı? Alt köşeleri yuvarlar ve ayracı
  /// bırakır — yüzey temizce biter.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final placeLabel = switch (chapter.revelationPlace) {
      QuranRevelationPlace.meccan => l10n.quranRevelationMeccan,
      QuranRevelationPlace.medinan => l10n.quranRevelationMedinan,
    };

    final radius = BorderRadius.vertical(
      top: Radius.circular(isFirst ? AppRadius.lg : 0),
      bottom: Radius.circular(isLast ? AppRadius.lg : 0),
    );

    return Material(
      color: tokens.sacredSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _ChapterNumber(id: chapter.id),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Latin ad birincil satırdır — güçlü hiyerarşi.
                          AppText(
                            chapter.transliteratedName,
                            token: AppTextStyleToken.h3,
                            maxLines: 1,
                          ),
                          const SizedBox(height: AppSpacing.s1),
                          AppText(
                            '${l10n.quranAyahCount(chapter.verseCount)} · $placeLabel',
                            token: AppTextStyleToken.caption,
                            tone: AppTextTone.tertiary,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    // Arapça ad KENDİ yönünde çizilir (uygulama dili ne
                    // olursa olsun) ve Kur'an vurgu rengini alır.
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: AppText(
                        chapter.arabicName,
                        token: AppTextStyleToken.h3,
                        color: tokens.quranAccent,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                // Saç teli ayraç satırın İÇİNDE yaşar ve son satırda çizilmez,
                // böylece yüzeyin alt kenarında çift çizgi oluşmaz. Yatay
                // dolgunun içinde kaldığı için klasik "inset divider" verir.
                if (!isLast) ...[
                  const SizedBox(height: AppSpacing.s3),
                  Divider(height: 1, thickness: 1, color: ext.divider),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mushaf sıra numarası (RDX-04A).
///
/// Önceden 28 px genişlikte çıplak bir yazıydı ve büyük yazı ölçeğinde
/// kırpılıyordu. Artık tonal bir çerçevede oturur: numara listedeki ritmi
/// verir, sure adıyla YARIŞMAZ. Kutu `minWidth` ile tanımlıdır — 1.5x ölçekte
/// "114" büyüdüğünde kutu da büyür, metin kırpılmaz.
final class _ChapterNumber extends StatelessWidget {
  const _ChapterNumber({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.sectionSurface,
        borderRadius: AppRadius.smAll,
      ),
      child: AppText(
        '$id',
        token: AppTextStyleToken.caption,
        tone: AppTextTone.secondary,
        maxLines: 1,
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
    // RDX-04A: tek satırlık düz kart yerine paylaşılan nazik boş durum.
    // Kart, ekranın üstüne yapışıp "yüklenmemiş içerik" gibi duruyordu;
    // ortalanmış boş durum bunun bilinçli bir bekleme olduğunu söyler.
    // METİNLER DEĞİŞMEDİ ve sahte ders/dini içerik ÜRETİLMEDİ — eylem
    // düğmesi de yoktur, çünkü gidilecek bir yer yok.
    return GentleEmptyState(
      icon: Icons.auto_stories_outlined,
      title: l10n.quranLearnTitle,
      message: l10n.quranLearnBody,
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

    // RDX-04A: sekme önceden ÜST ÜSTE BEŞ aynı yükseltilmiş kart idi —
    // hiyerarşisi olmayan bir kutu yığını. Artık üç kademe var:
    //
    //   1. Bugünkü hedef — sıcak kum yüzeyi, sekmenin çapası.
    //   2. Aktivite — bugünün sayıları, son 7 gün ve seri TEK kartta,
    //      aralarında saç teli ayraçla. Üçü de "ne kadar okudum" sorusunun
    //      parçası; ayrı kartlar bu ilişkiyi gizliyordu.
    //   3. Okumaya devam — ince kenarlıklı giriş satırı.
    //
    // Hiçbir metrik, metin veya hesap DEĞİŞMEDİ; yalnız yüzeyler gruplandı.
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        AppCard(
          variant: AppCardVariant.sand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTodayGoalTitle,
                token: AppTextStyleToken.caption,
                tone: AppTextTone.secondary,
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
                  tone: AppTextTone.secondary,
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
                  tone: AppTextTone.secondary,
                ),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  summary.isGoalCompleted
                      ? l10n.quranGoalCompletedLine
                      : remainingLabel,
                  token: AppTextStyleToken.bodySmall,
                  tone: AppTextTone.secondary,
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
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bugünkü aktivite
              AppText(
                l10n.quranTodayActivityTitle,
                token: AppTextStyleToken.caption,
                tone: AppTextTone.secondary,
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
              const _ProgressSectionDivider(),
              // Son 7 gün — token tabanlı küçük barlar; chart paketi YOK.
              AppText(
                l10n.quranLast7DaysTitle,
                token: AppTextStyleToken.caption,
                tone: AppTextTone.secondary,
              ),
              const SizedBox(height: AppSpacing.s3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final point in summary.last7Days)
                    _DayProgressColumn(point: point),
                ],
              ),
              const _ProgressSectionDivider(),
              // Kur'an hedefi serisi — sakin, suçlayıcı olmayan dil. Kendi
              // kartını kaybetti ama metni ve sayısı aynen korundu; seri bir
              // ödül değil, son 7 günün okunuşudur ve oraya aittir.
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      l10n.quranStreakTitle,
                      token: AppTextStyleToken.caption,
                      tone: AppTextTone.secondary,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  AppText(
                    l10n.quranDaysCount(summary.currentStreakDays),
                    token: AppTextStyleToken.h3,
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
        const _ProgressContinueCard(),
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

/// Aktivite kartının içindeki bölüm ayracı (RDX-04A). Üç ilgili blok tek
/// kartta yaşarken birbirine karışmasın diye kullanılır.
final class _ProgressSectionDivider extends StatelessWidget {
  const _ProgressSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppThemeExtension.of(context).divider,
      ),
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
    final resolved = chapter;
    // RDX-04A: ayrı başlık + ayrı buton taşıyan dolu kart yerine, kartın
    // TAMAMI tek dokunma hedefi olan ince kenarlıklı bir giriş satırı. Aynı
    // rota, aynı bilgi (sure adı + varsa ayet anahtarı), tek eylem.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tertiary = AppThemeExtension.of(context).textTertiary;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      child: Semantics(
        button: true,
        label: l10n.quranResumeCta,
        child: AppCard(
          variant: AppCardVariant.outlined,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          onTap: () => _openChapter(context, ref, resolved.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: AppSizes.iconMd,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.quranResumeCta,
                        token: AppTextStyleToken.h3,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      AppText(
                        verseKey == null
                            ? resolved.transliteratedName
                            : '${resolved.transliteratedName} · $verseKey',
                        token: AppTextStyleToken.caption,
                        tone: AppTextTone.secondary,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  size: AppSizes.iconSm,
                  color: tertiary,
                ),
              ],
            ),
          ),
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

    // RDX-04A: bu blok artık yükseltilmiş bir kart DEĞİL, ince kenarlıklı
    // kompakt bir giriş satırıdır. Gerekçe: üstteki "kaldığın yer" bloğu
    // ekranın sıcak yüzeyini zaten taşıyor; ikinci bir dolu kart, sure
    // listesine inmeden önce üçüncü bir büyük yüzey daha üretiyordu. Yön
    // duyarlı chevron, satırın gerçekten bir yere GÖTÜRDÜĞÜNÜ söyler —
    // Namaz ekranının ikincil giriş satırlarıyla aynı dil.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tertiary = AppThemeExtension.of(context).textTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: Semantics(
        button: true,
        label: l10n.quranTabProgress,
        child: AppCard(
          variant: AppCardVariant.outlined,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          onTap: () => ref
              .read(quranHomeTabProvider.notifier)
              .request(QuranHomeTab.progress),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.quranTodayGoalTitle,
                      token: AppTextStyleToken.caption,
                      tone: AppTextTone.secondary,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    if (summary.pageMappingUnavailable)
                      AppText(
                        l10n.quranPageProgressUnavailable,
                        token: AppTextStyleToken.bodySmall,
                        tone: AppTextTone.secondary,
                        maxLines: 2,
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
                        tone: AppTextTone.tertiary,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Icon(
                isRtl ? Icons.chevron_left : Icons.chevron_right,
                size: AppSizes.iconSm,
                color: tertiary,
              ),
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

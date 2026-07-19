import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_article_row.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Learn ana ekranı (TASK 056 §8) — işlevsel bilgi kütüphanesi.
///
/// Artık "hazırlanıyor" ekranı DEĞİLDİR: kullanıcı gerçekten konu açıp
/// okuyabilir. Bölümler veri yoksa SESSİZCE gizlenir — boş bölüm başlığı
/// gösterilmez, sahte içerik üretilmez.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(learnSearchQueryProvider);
    final categoriesAsync = ref.watch(learnCategoriesProvider);

    return AppScaffold(
      title: l10n.tabLearn,
      body: switch (categoriesAsync) {
        AsyncData(:final value) => _buildBody(l10n, value, query),
        AsyncError() => AppErrorState(
          message: l10n.learnLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(learnCategoriesProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    List<LearningCategorySummary> categories,
    String query,
  ) {
    final progress =
        ref.watch(learnProgressProvider).value ?? LearningProgress.empty;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s4),
        const _LearnHero(),
        const SizedBox(height: AppSpacing.s5),
        _SearchField(controller: _searchController),
        const SizedBox(height: AppSpacing.s5),
        // Arama aktifken yalnız sonuçlar gösterilir — ekran sadeleşir.
        if (query.trim().isNotEmpty)
          _SearchResults(progress: progress)
        else ...[
          _ContinueSection(progress: progress),
          _ArticleSection(
            title: l10n.learnBeginnerPathSection,
            provider: learnBeginnerPathProvider,
            progress: progress,
          ),
          _ArticleSection(
            title: l10n.learnFeaturedSection,
            provider: learnFeaturedProvider,
            progress: progress,
          ),
          _SavedSection(progress: progress),
          _CompletedSection(progress: progress),
          _CategoriesSection(categories: categories),
        ],
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

/// Kompakt sıcak Learn header'ı (TASK 055 deseninin devamı).
class _LearnHero extends StatelessWidget {
  const _LearnHero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return Semantics(
      container: true,
      label: l10n.learnHeroTitle,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: tokens.warmSectionGradient),
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: MosqueHorizonIllustration(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s5,
                  AppSpacing.s5,
                  AppSpacing.s5,
                  AppSpacing.s7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(l10n.learnHeroTitle, token: AppTextStyleToken.h2),
                    const SizedBox(height: AppSpacing.s2),
                    AppText(
                      l10n.learnHeroBody,
                      token: AppTextStyleToken.bodySmall,
                      secondary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tamamen offline öğrenme araması.
class _SearchField extends ConsumerWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final query = ref.watch(learnSearchQueryProvider);

    return Semantics(
      textField: true,
      label: l10n.learnSearchHint,
      child: TextField(
        controller: controller,
        onChanged: ref.read(learnSearchQueryProvider.notifier).setQuery,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.learnSearchHint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: tokens.sacredSurface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.pillAll,
            borderSide: BorderSide(color: tokens.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.pillAll,
            borderSide: BorderSide(color: tokens.surfaceBorder),
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.commonClose,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    ref.read(learnSearchQueryProvider.notifier).clear();
                  },
                ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(learnSearchResultsProvider).value;

    if (results == null) {
      return const SizedBox.shrink();
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
        child: AppText(
          l10n.learnSearchEmpty,
          secondary: true,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      children: [
        for (final article in results)
          LearnArticleRow(
            article: article,
            isBookmarked: progress.isBookmarked(article.id),
            isCompleted: progress.isCompleted(article.id),
          ),
      ],
    );
  }
}

/// Bölüm başlığı + içerik listesi; liste boşsa bölüm TAMAMEN gizlenir.
class _ArticleSection extends ConsumerWidget {
  const _ArticleSection({
    required this.title,
    required this.provider,
    required this.progress,
  });

  final String title;
  final FutureProvider<List<LearningArticle>> provider;
  final LearningProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(provider).value ?? const <LearningArticle>[];
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionShell(
      title: title,
      child: Column(
        children: [
          for (final article in articles)
            LearnArticleRow(
              article: article,
              isBookmarked: progress.isBookmarked(article.id),
              isCompleted: progress.isCompleted(article.id),
            ),
        ],
      ),
    );
  }
}

class _ContinueSection extends ConsumerWidget {
  const _ContinueSection({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lastId = progress.lastOpenedArticleId;
    if (lastId == null) {
      return const SizedBox.shrink();
    }
    final articles = ref.watch(learnArticlesByIdsProvider([lastId])).value;
    if (articles == null || articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionShell(
      title: l10n.learnContinueSection,
      child: LearnArticleRow(
        article: articles.first,
        isBookmarked: progress.isBookmarked(articles.first.id),
        isCompleted: progress.isCompleted(articles.first.id),
        showDivider: false,
      ),
    );
  }
}

class _SavedSection extends ConsumerWidget {
  const _SavedSection({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ids = progress.bookmarkedArticleIds.toList()..sort();
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }
    final articles = ref.watch(learnArticlesByIdsProvider(ids)).value;
    if (articles == null || articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionShell(
      title: l10n.learnSavedSection,
      child: Column(
        children: [
          for (final article in articles)
            LearnArticleRow(
              article: article,
              isBookmarked: true,
              isCompleted: progress.isCompleted(article.id),
            ),
        ],
      ),
    );
  }
}

class _CompletedSection extends ConsumerWidget {
  const _CompletedSection({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ids = progress.completedArticleIds.toList()..sort();
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }
    final articles = ref.watch(learnArticlesByIdsProvider(ids)).value;
    if (articles == null || articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return _SectionShell(
      title: l10n.learnCompletedSection,
      child: Column(
        children: [
          for (final article in articles)
            LearnArticleRow(
              article: article,
              isBookmarked: progress.isBookmarked(article.id),
              isCompleted: true,
            ),
        ],
      ),
    );
  }
}

/// Tüm kategoriler — içeriği olmayan kategori DÜRÜSTÇE "hazırlanıyor"
/// etiketiyle gösterilir, doluymuş gibi sunulmaz (TASK 056 §4).
class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.categories});

  final List<LearningCategorySummary> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return _SectionShell(
      title: l10n.learnAllCategoriesSection,
      child: Column(
        children: [
          for (final summary in categories)
            Semantics(
              button: !summary.isEmpty,
              label: summary.category.title,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // Boş kategori açılabilir ama dürüst boş durum gösterir.
                  onTap: () => context.push(
                    AppRoutes.learnCategoryPath(summary.category.slug),
                  ),
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: tokens.surfaceBorder),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s2,
                            vertical: AppSpacing.s3,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      summary.category.title,
                                      token: AppTextStyleToken.h3,
                                    ),
                                    const SizedBox(height: AppSpacing.s1),
                                    AppText(
                                      summary.isEmpty
                                          ? l10n.learnCategoryPreparing
                                          : l10n.learnTopicCount(
                                              summary.publishedCount,
                                            ),
                                      token: AppTextStyleToken.caption,
                                      secondary: true,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.chevron_left_rounded
                                    : Icons.chevron_right_rounded,
                                color: tokens.spiritualGreenStrong,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ortak bölüm kabuğu: başlık + içerik + alt boşluk.
class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s3),
          child: AppText(title, token: AppTextStyleToken.h3),
        ),
        child,
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_article_row.dart';
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kategori ekranı (TASK 056 §9).
///
/// İçeriği olmayan kategoride SAHTE içerik üretilmez: sakin ve dürüst bir
/// boş durum gösterilir ("güvenilir kaynaklarla hazırlanıyor").
class LearnCategoryScreen extends ConsumerWidget {
  const LearnCategoryScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoryAsync = ref.watch(learnCategoryBySlugProvider(slug));

    return switch (categoryAsync) {
      AsyncData(:final value) => value == null
          ? AppScaffold(
              title: l10n.tabLearn,
              body: GentleEmptyState(
                title: l10n.learnCategoryEmptyTitle,
                message: l10n.learnCategoryPreparing,
              ),
            )
          : _CategoryContent(category: value),
      AsyncError() => AppScaffold(
        title: l10n.tabLearn,
        body: AppErrorState(
          message: l10n.learnLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(learnCategoryBySlugProvider(slug)),
        ),
      ),
      _ => AppScaffold(
        title: l10n.tabLearn,
        body: AppLoading(label: l10n.commonLoading),
      ),
    };
  }
}

class _CategoryContent extends ConsumerWidget {
  const _CategoryContent({required this.category});

  final LearningCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final articlesAsync = ref.watch(
      learnCategoryArticlesProvider(category.id),
    );
    final progress =
        ref.watch(learnProgressProvider).value ?? LearningProgress.empty;

    return AppScaffold(
      title: category.title,
      body: switch (articlesAsync) {
        AsyncData(:final value) => value.isEmpty
            ? GentleEmptyState(
                title: l10n.learnCategoryEmptyTitle,
                message: category.shortDescription,
              )
            : _ArticleList(
                category: category,
                articles: value,
                progress: progress,
              ),
        AsyncError() => AppErrorState(
          message: l10n.learnLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () =>
              ref.invalidate(learnCategoryArticlesProvider(category.id)),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

class _ArticleList extends StatelessWidget {
  const _ArticleList({
    required this.category,
    required this.articles,
    required this.progress,
  });

  final LearningCategory category;
  final List<LearningArticle> articles;
  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // İçerikler zorluk seviyesine göre gruplanır — kullanıcı nereden
    // başlayacağını görür (TASK 056 §9).
    final byDifficulty = <LearningDifficulty, List<LearningArticle>>{};
    for (final article in articles) {
      byDifficulty.putIfAbsent(article.difficulty, () => []).add(article);
    }

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s4),
        AppText(category.shortDescription, secondary: true),
        const SizedBox(height: AppSpacing.s2),
        AppText(
          l10n.learnTopicCount(articles.length),
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s5),
        for (final difficulty in LearningDifficulty.values)
          if (byDifficulty[difficulty] case final List<LearningArticle> group)
            ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                child: AppText(
                  learnDifficultyLabel(l10n, difficulty),
                  token: AppTextStyleToken.h3,
                ),
              ),
              for (final article in group)
                LearnArticleRow(
                  article: article,
                  isBookmarked: progress.isBookmarked(article.id),
                  isCompleted: progress.isCompleted(article.id),
                ),
              const SizedBox(height: AppSpacing.s6),
            ],
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

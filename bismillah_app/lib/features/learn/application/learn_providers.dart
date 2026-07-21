import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/data/shared_prefs_learning_progress_repository.dart';
import 'package:bismillah_app/features/learn/data/url_launcher_external_link_service.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_progress_repository.dart';
import 'package:bismillah_app/features/learn/domain/services/external_link_service.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bilgi tabanı deposu (TASK 056).
///
/// autoDispose DEĞİL: parse edilmiş içerik cache'i uygulama ömrünce yaşar,
/// asset her ekran açılışında yeniden ayrıştırılmaz. Bismillah Assistant
/// tamamlandığında AYNI provider'ı kullanacaktır.
final learningKnowledgeRepositoryProvider =
    Provider<LearningKnowledgeRepository>(
      (ref) => AssetLearningKnowledgeRepository(),
    );

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) => const SharedPrefsLearningProgressRepository(),
);

/// Resmî kaynak bağlantısı açma servisi — alan adı doğrulaması içeride.
/// Testler bunu override ederek GERÇEK tarayıcı açmadan davranışı doğrular.
final externalLinkServiceProvider = Provider<ExternalLinkService>(
  (ref) => const UrlLauncherExternalLinkService(),
);

/// Aktif içerik dili — global uygulama diline bağlıdır (TASK 053).
final learnContentLocaleProvider = Provider<String>(
  (ref) => ref.watch(appLocaleProvider).name,
);

/// Kategoriler + yayınlanmış içerik sayıları.
final learnCategoriesProvider =
    FutureProvider<List<LearningCategorySummary>>((ref) async {
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getCategories(locale);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (failure) => throw StateError(failure.messageKey),
      );
    });

final learnBeginnerPathProvider = FutureProvider<List<LearningArticle>>((
  ref,
) async {
  final locale = ref.watch(learnContentLocaleProvider);
  final result = await ref
      .watch(learningKnowledgeRepositoryProvider)
      .getBeginnerPath(locale);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw StateError(failure.messageKey),
  );
});

final learnFeaturedProvider = FutureProvider<List<LearningArticle>>((
  ref,
) async {
  final locale = ref.watch(learnContentLocaleProvider);
  final result = await ref
      .watch(learningKnowledgeRepositoryProvider)
      .getFeatured(locale);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (failure) => throw StateError(failure.messageKey),
  );
});

/// Bir kategorinin yayınlanmış içerikleri (kategori id ile).
final learnCategoryArticlesProvider =
    FutureProvider.family<List<LearningArticle>, String>((ref, categoryId) async {
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getArticlesByCategory(locale, categoryId);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (failure) => throw StateError(failure.messageKey),
      );
    });

/// Slug ile kategori çözümü.
final learnCategoryBySlugProvider =
    FutureProvider.family<LearningCategory?, String>((ref, slug) async {
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getCategoryBySlug(locale, slug);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (failure) => throw StateError(failure.messageKey),
      );
    });

/// Slug ile içerik çözümü.
final learnArticleBySlugProvider =
    FutureProvider.family<LearningArticle?, String>((ref, slug) async {
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getArticleBySlug(locale, slug);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (failure) => throw StateError(failure.messageKey),
      );
    });

/// Bir içeriğin kaynak künyeleri.
final learnArticleSourcesProvider =
    FutureProvider.family<List<KnowledgeSource>, LearningArticle>((
      ref,
      article,
    ) async {
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getSourcesForArticle(article);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (_) => const <KnowledgeSource>[],
      );
    });

/// Id listesiyle içerik çözümü (ilgili konular, kaydedilenler, devam).
final learnArticlesByIdsProvider =
    FutureProvider.family<List<LearningArticle>, List<String>>((
      ref,
      ids,
    ) async {
      if (ids.isEmpty) {
        return const <LearningArticle>[];
      }
      final locale = ref.watch(learnContentLocaleProvider);
      final result = await ref
          .watch(learningKnowledgeRepositoryProvider)
          .getArticlesByIds(locale, ids);
      return result.fold(
        onSuccess: (value) => value,
        onFailure: (_) => const <LearningArticle>[],
      );
    });

/// Offline arama sorgusu (boş = arama kapalı).
final learnSearchQueryProvider =
    NotifierProvider<LearnSearchQueryController, String>(
      LearnSearchQueryController.new,
    );

final class LearnSearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;

  void clear() => state = '';
}

final learnSearchResultsProvider = FutureProvider<List<LearningArticle>>((
  ref,
) async {
  final query = ref.watch(learnSearchQueryProvider);
  if (query.trim().isEmpty) {
    return const <LearningArticle>[];
  }
  final locale = ref.watch(learnContentLocaleProvider);
  final result = await ref
      .watch(learningKnowledgeRepositoryProvider)
      .search(locale, query);
  return result.fold(
    onSuccess: (value) => value,
    onFailure: (_) => const <LearningArticle>[],
  );
});

/// Yerel öğrenme ilerlemesi — kaydet/tamamla aksiyonlarının TEK kaynağı.
final learnProgressProvider =
    AsyncNotifierProvider<LearnProgressController, LearningProgress>(
      LearnProgressController.new,
    );

final class LearnProgressController extends AsyncNotifier<LearningProgress> {
  @override
  Future<LearningProgress> build() async {
    final result = await ref.read(learningProgressRepositoryProvider).load();
    // Okuma hatası ekranı BLOKLAMAZ: boş ilerleme ile devam edilir.
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (_) => LearningProgress.empty,
    );
  }

  Future<void> toggleBookmark(String articleId) async {
    final result = await ref
        .read(learningProgressRepositoryProvider)
        .toggleBookmark(articleId);
    result.fold(
      onSuccess: (value) => state = AsyncData(value),
      // Yazma başarısızsa mevcut durum korunur; kullanıcıya hata ekranı
      // gösterilmez (sakin bozulma).
      onFailure: (_) {},
    );
  }

  Future<void> toggleCompleted(String articleId) async {
    final result = await ref
        .read(learningProgressRepositoryProvider)
        .toggleCompleted(articleId);
    result.fold(
      onSuccess: (value) => state = AsyncData(value),
      onFailure: (_) {},
    );
  }

  Future<void> noteOpened(String articleId, {int? sectionIndex}) async {
    final result = await ref
        .read(learningProgressRepositoryProvider)
        .noteOpened(articleId, sectionIndex: sectionIndex);
    result.fold(
      onSuccess: (value) => state = AsyncData(value),
      onFailure: (_) {},
    );
  }
}

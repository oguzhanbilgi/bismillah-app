import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/data/learning_search_normalizer.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_knowledge_repository.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Asset tabanlı bilgi tabanı deposu (TASK 056 §7).
///
/// Tamamen OFFLINE: HTTP/Firebase YOKTUR. JSON YALNIZ bu data katmanında
/// parse edilir — presentation AssetBundle veya ham JSON görmez.
///
/// Cache: her locale için içerikler ilk başarılı okumadan sonra bellekte
/// tutulur; asset her erişimde yeniden parse EDİLMEZ.
///
/// Filtreleme: depo YALNIZ `ReviewStatus.published` içerik döndürür —
/// taslak/incelemedeki içerik uygulamaya sızamaz.
final class AssetLearningKnowledgeRepository
    implements LearningKnowledgeRepository {
  AssetLearningKnowledgeRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const String _sourcesPath = 'assets/content/learn/sources.json';
  static const String _categoriesPath = 'assets/content/learn/categories.json';

  /// Desteklenen içerik dilleri. Bilinmeyen locale Türkçeye düşer —
  /// kanonik kaynak dili Türkçedir.
  static const Set<String> _supportedLocales = {'tr', 'en', 'ar'};
  static const String _fallbackLocale = 'tr';

  final AssetBundle _bundle;

  List<KnowledgeSource>? _sources;
  Map<String, KnowledgeSource>? _sourcesById;

  final Map<String, List<LearningCategory>> _categoriesByLocale = {};
  final Map<String, _ArticleIndex> _articlesByLocale = {};

  String _resolveLocale(String locale) =>
      _supportedLocales.contains(locale) ? locale : _fallbackLocale;

  Future<List<KnowledgeSource>> _loadSources() async {
    final cached = _sources;
    if (cached != null) {
      return cached;
    }
    final decoded = json.decode(await _bundle.loadString(_sourcesPath));
    final sources = LearningContentParser.parseSources(decoded);
    _sources = sources;
    _sourcesById = {for (final source in sources) source.id: source};
    return sources;
  }

  Future<List<LearningCategory>> _loadCategories(String locale) async {
    final cached = _categoriesByLocale[locale];
    if (cached != null) {
      return cached;
    }
    final decoded = json.decode(await _bundle.loadString(_categoriesPath));
    final categories = LearningContentParser.parseCategories(decoded, locale);
    _categoriesByLocale[locale] = categories;
    return categories;
  }

  /// Türkçe (kanonik) katalogda GERÇEKTEN yayınlanan içerik id'leri.
  ///
  /// Ayrı tutulur ki çeviri yüklemesi kanonik yüklemeyle özyinelemeye
  /// girmesin; sonuç cache'lenir.
  Set<String>? _canonicalPublishedIds;

  Future<Set<String>> _publishedCanonicalIds() async {
    final cached = _canonicalPublishedIds;
    if (cached != null) {
      return cached;
    }
    final index = await _loadArticles(_fallbackLocale);
    final ids = index.all.map((a) => a.id).toSet();
    _canonicalPublishedIds = ids;
    return ids;
  }

  Future<_ArticleIndex> _loadArticles(String locale) async {
    final cached = _articlesByLocale[locale];
    if (cached != null) {
      return cached;
    }
    // Çapraz doğrulama için kaynak ve kategori id'leri önce yüklenir.
    final sources = await _loadSources();
    final categories = await _loadCategories(locale);

    final decoded = json.decode(
      await _bundle.loadString('assets/content/learn/articles_$locale.json'),
    );
    final parsed = LearningContentParser.parseArticles(
      decoded,
      expectedLocale: locale,
      validSourceIds: {for (final source in sources) source.id},
      validCategoryIds: {for (final category in categories) category.id},
    );

    // Yalnız yayınlanmış içerik uygulamaya girer. Kaynak GÖVDESİ
    // doğrulanmamış içerik `published` olamadığı için (domain kapısı)
    // burada ayrıca bir kontrol gerekmez; yine de niyet açık kalsın diye
    // her iki koşul birlikte aranır (TASK 056A §3).
    var published = parsed
        .where((a) => a.isPublished && a.isSourceBodyVerified)
        .toList(growable: false);

    // TASK 056A §5: çeviriler Türkçe kanonik makaleye BAĞLIDIR. Türkçe
    // kaynak doğrulaması yoksa İngilizce/Arapça sürüm de yayınlanamaz —
    // çeviri, doğrulanmamış bir iddiayı dolaylı yoldan yayına sokamaz.
    if (locale != _fallbackLocale) {
      final canonicalIds = await _publishedCanonicalIds();
      published = published
          .where((a) => canonicalIds.contains(a.id))
          .toList(growable: false);
    }
    final index = _ArticleIndex(
      all: published,
      byId: {for (final article in published) article.id: article},
      bySlug: {for (final article in published) article.slug: article},
      categoryTitleById: {
        for (final category in categories) category.id: category.title,
      },
    );
    _articlesByLocale[locale] = index;
    return index;
  }

  /// Ortak hata sarmalayıcı: parse/asset hatası kullanıcıya sızmaz, sakin
  /// `StorageFailure` olur — ekran kendi boş/hata durumunu gösterir.
  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Result.success(await body());
    } on ContentSchemaError {
      return const Result.failure(StorageFailure());
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<List<LearningCategorySummary>> getCategories(String locale) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final categories = await _loadCategories(resolved);
      final index = await _loadArticles(resolved);
      final counts = <String, int>{};
      for (final article in index.all) {
        counts[article.categoryId] = (counts[article.categoryId] ?? 0) + 1;
      }
      return [
        for (final category in categories)
          LearningCategorySummary(
            category: category,
            publishedCount: counts[category.id] ?? 0,
          ),
      ];
    });
  }

  @override
  ResultFuture<LearningCategory?> getCategoryBySlug(
    String locale,
    String slug,
  ) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final categories = await _loadCategories(resolved);
      for (final category in categories) {
        if (category.slug == slug) {
          return category;
        }
      }
      return null;
    });
  }

  @override
  ResultFuture<List<LearningArticle>> getArticlesByCategory(
    String locale,
    String categoryId,
  ) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadArticles(resolved);
      final articles =
          index.all.where((a) => a.categoryId == categoryId).toList()
            // Kolaydan derine: aynı zorlukta başlığa göre.
            ..sort((a, b) {
              final byDifficulty = a.difficulty.index.compareTo(
                b.difficulty.index,
              );
              return byDifficulty != 0
                  ? byDifficulty
                  : a.title.compareTo(b.title);
            });
      return articles;
    });
  }

  @override
  ResultFuture<LearningArticle?> getArticleBySlug(String locale, String slug) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadArticles(resolved);
      return index.bySlug[slug];
    });
  }

  @override
  ResultFuture<List<LearningArticle>> getArticlesByIds(
    String locale,
    List<String> ids,
  ) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadArticles(resolved);
      return [
        for (final id in ids)
          if (index.byId[id] case final LearningArticle article) article,
      ];
    });
  }

  @override
  ResultFuture<List<LearningArticle>> getBeginnerPath(String locale) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadArticles(resolved);
      final path = index.all
          .where((a) => a.beginnerPathOrder != null)
          .toList(growable: false);
      final sorted = [...path]
        ..sort((a, b) => a.beginnerPathOrder!.compareTo(b.beginnerPathOrder!));
      return sorted;
    });
  }

  @override
  ResultFuture<List<LearningArticle>> getFeatured(String locale) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final index = await _loadArticles(resolved);
      return index.all.where((a) => a.isFeatured).toList(growable: false);
    });
  }

  @override
  ResultFuture<List<LearningArticle>> search(String locale, String query) {
    final resolved = _resolveLocale(locale);
    return _guard(() async {
      final normalized = LearningSearchNormalizer.normalize(query);
      // Tek harflik sorgu neredeyse her şeyi getirir; anlamlı eşik uygulanır.
      if (normalized.length < 2) {
        return const <LearningArticle>[];
      }
      final index = await _loadArticles(resolved);
      return index.all.where((article) {
        return LearningSearchNormalizer.matches(query, [
          article.title,
          article.summary,
          ...article.keywords,
          index.categoryTitleById[article.categoryId] ?? '',
        ]);
      }).toList(growable: false);
    });
  }

  @override
  ResultFuture<List<KnowledgeSource>> getSourcesForArticle(
    LearningArticle article,
  ) {
    return _guard(() async {
      await _loadSources();
      final byId = _sourcesById ?? const <String, KnowledgeSource>{};
      return [
        for (final id in article.sourceIds)
          if (byId[id] case final KnowledgeSource source) source,
      ];
    });
  }
}

/// Locale başına önceden hesaplanmış arama/erişim indeksi.
final class _ArticleIndex {
  const _ArticleIndex({
    required this.all,
    required this.byId,
    required this.bySlug,
    required this.categoryTitleById,
  });

  final List<LearningArticle> all;
  final Map<String, LearningArticle> byId;
  final Map<String, LearningArticle> bySlug;

  /// Arama, kategori adı üzerinden de eşleşebilsin diye tutulur.
  final Map<String, String> categoryTitleById;
}

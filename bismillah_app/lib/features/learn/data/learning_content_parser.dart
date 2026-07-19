import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/entities/source_verification.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// İçerik asset'lerinin deterministic parser + validator'ı (TASK 056 §7).
///
/// Doğrulama BİLEREK serttir: bozuk veri sessizce yutulmaz, [ContentSchemaError]
/// fırlatılır. Böylece geçersiz içerik testlerde/derlemede yakalanır ve
/// kullanıcıya ASLA yanlış dinî bilgi gösterilmez.
///
/// Bu sınıf saf Dart'tır (Flutter/asset bağımlılığı yok) — hem depo hem de
/// içerik doğrulama testleri aynı kodu kullanır.
abstract final class LearningContentParser {
  /// Desteklenen şema sürümü. Asset'ler farklı sürüm bildirirse yükleme
  /// başarısız olur — sessiz uyumsuzluk oluşmaz.
  static const int supportedSchemaVersion = 1;

  // ---------------------------------------------------------------------
  // Kaynaklar
  // ---------------------------------------------------------------------

  static List<KnowledgeSource> parseSources(Object? decoded) {
    final root = _asMap(decoded, 'sources.json');
    _checkSchemaVersion(root, 'sources.json');

    final rawList = _asList(root['sources'], 'sources');
    final sources = <KnowledgeSource>[];
    final seenIds = <String>{};

    for (final raw in rawList) {
      final map = _asMap(raw, 'source');
      final id = _requireString(map, 'id', 'source');
      if (!seenIds.add(id)) {
        throw ContentSchemaError('Yinelenen kaynak id: $id');
      }
      final url = _requireString(map, 'canonicalUrl', 'source[$id]');
      // Resmî alan adı doğrulaması — entity kurucusu da uygular; burada
      // hata mesajı daha açıklayıcı olsun diye ÖNCE kontrol edilir.
      if (!OfficialSourceDomains.isAllowed(url)) {
        throw ContentSchemaError(
          'Kaynak $id izin verilmeyen alan adı kullanıyor: $url',
        );
      }
      sources.add(
        KnowledgeSource(
          id: id,
          institution: _requireString(map, 'institution', 'source[$id]'),
          title: _requireString(map, 'title', 'source[$id]'),
          sourceType: _parseEnum(
            KnowledgeSourceType.values,
            _requireString(map, 'sourceType', 'source[$id]'),
            'sourceType',
          ),
          canonicalUrl: url,
          originalLanguage: _requireString(
            map,
            'originalLanguage',
            'source[$id]',
          ),
          publicationInfo: map['publicationInfo'] as String?,
          accessedAt: _requireString(map, 'accessedAt', 'source[$id]'),
          lastVerifiedAt: _requireString(map, 'lastVerifiedAt', 'source[$id]'),
          attribution: _requireString(map, 'attribution', 'source[$id]'),
          usageNotes: _requireString(map, 'usageNotes', 'source[$id]'),
          isOfficial: map['isOfficial'] == true,
        ),
      );
    }
    if (sources.isEmpty) {
      throw const ContentSchemaError('Kaynak listesi boş olamaz');
    }
    return sources;
  }

  // ---------------------------------------------------------------------
  // Kategoriler
  // ---------------------------------------------------------------------

  /// Kategorileri verilen [locale] için ÇÖZÜLMÜŞ metinlerle döner.
  /// Locale karşılığı eksikse Türkçeye düşer (tr kanonik dildir).
  static List<LearningCategory> parseCategories(
    Object? decoded,
    String locale,
  ) {
    final root = _asMap(decoded, 'categories.json');
    _checkSchemaVersion(root, 'categories.json');

    final rawList = _asList(root['categories'], 'categories');
    final categories = <LearningCategory>[];
    final seenIds = <String>{};
    final seenSlugs = <String>{};

    for (final raw in rawList) {
      final map = _asMap(raw, 'category');
      final id = _requireString(map, 'id', 'category');
      if (!seenIds.add(id)) {
        throw ContentSchemaError('Yinelenen kategori id: $id');
      }
      final slug = _requireString(map, 'slug', 'category[$id]');
      if (!seenSlugs.add(slug)) {
        throw ContentSchemaError('Yinelenen kategori slug: $slug');
      }
      categories.add(
        LearningCategory(
          id: id,
          slug: slug,
          title: _localized(map['title'], locale, 'category[$id].title'),
          shortDescription: _localized(
            map['shortDescription'],
            locale,
            'category[$id].shortDescription',
          ),
          iconKey: _requireString(map, 'iconKey', 'category[$id]'),
          sortOrder: _requireInt(map, 'sortOrder', 'category[$id]'),
          parentCategoryId: map['parentCategoryId'] as String?,
        ),
      );
    }
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  // ---------------------------------------------------------------------
  // İçerikler
  // ---------------------------------------------------------------------

  /// Bir locale dosyasındaki içerikleri parse eder ve çapraz doğrular.
  ///
  /// [validSourceIds] ve [validCategoryIds] verilirse kırık referanslar
  /// hata üretir (TASK 056 §7: broken source reference kontrolü).
  static List<LearningArticle> parseArticles(
    Object? decoded, {
    required String expectedLocale,
    Set<String>? validSourceIds,
    Set<String>? validCategoryIds,
  }) {
    final root = _asMap(decoded, 'articles_$expectedLocale.json');
    _checkSchemaVersion(root, 'articles_$expectedLocale.json');

    final declaredLocale = _requireString(root, 'locale', 'articles');
    if (declaredLocale != expectedLocale) {
      throw ContentSchemaError(
        'Locale uyuşmazlığı: beklenen $expectedLocale, bulunan $declaredLocale',
      );
    }

    final rawList = _asList(root['articles'], 'articles');
    final articles = <LearningArticle>[];
    final seenIds = <String>{};
    final seenSlugs = <String>{};

    for (final raw in rawList) {
      final map = _asMap(raw, 'article');
      final id = _requireString(map, 'id', 'article');
      if (!seenIds.add(id)) {
        throw ContentSchemaError('Yinelenen içerik id: $id');
      }
      final slug = _requireString(map, 'slug', 'article[$id]');
      if (!seenSlugs.add(slug)) {
        throw ContentSchemaError('Yinelenen içerik slug: $slug');
      }

      final categoryId = _requireString(map, 'categoryId', 'article[$id]');
      if (validCategoryIds != null && !validCategoryIds.contains(categoryId)) {
        throw ContentSchemaError(
          'İçerik $id tanımsız kategoriye bağlı: $categoryId',
        );
      }

      final sourceIds = _stringList(map['sourceIds']);
      if (validSourceIds != null) {
        for (final sourceId in sourceIds) {
          if (!validSourceIds.contains(sourceId)) {
            throw ContentSchemaError(
              'İçerik $id tanımsız kaynağa referans veriyor: $sourceId',
            );
          }
        }
      }

      final officialQuestionUrl = map['officialQuestionUrl'] as String?;
      if (officialQuestionUrl != null &&
          !OfficialSourceDomains.isAllowed(officialQuestionUrl)) {
        throw ContentSchemaError(
          'İçerik $id izin verilmeyen soru adresi taşıyor: $officialQuestionUrl',
        );
      }

      articles.add(
        LearningArticle(
          id: id,
          slug: slug,
          categoryId: categoryId,
          title: _requireString(map, 'title', 'article[$id]'),
          summary: _requireString(map, 'summary', 'article[$id]'),
          sections: _parseSections(map['sections'], id),
          contentType: _parseEnum(
            LearningContentType.values,
            _requireString(map, 'contentType', 'article[$id]'),
            'contentType',
          ),
          difficulty: _parseEnum(
            LearningDifficulty.values,
            _requireString(map, 'difficulty', 'article[$id]'),
            'difficulty',
          ),
          estimatedMinutes: _requireInt(
            map,
            'estimatedMinutes',
            'article[$id]',
          ),
          keywords: _stringList(map['keywords']),
          sourceIds: sourceIds,
          reviewStatus: _parseEnum(
            ReviewStatus.values,
            _requireString(map, 'reviewStatus', 'article[$id]'),
            'reviewStatus',
          ),
          translationStatus: _parseEnum(
            LearningTranslationStatus.values,
            _requireString(map, 'translationStatus', 'article[$id]'),
            'translationStatus',
          ),
          relatedArticleIds: _stringList(map['relatedArticleIds']),
          prerequisiteArticleIds: _stringList(map['prerequisiteArticleIds']),
          reviewedAt: map['reviewedAt'] as String?,
          differenceNote: map['differenceNote'] as String?,
          beginnerPathOrder: map['beginnerPathOrder'] as int?,
          isFeatured: map['isFeatured'] == true,
          requiresQualifiedGuidance: map['requiresQualifiedGuidance'] == true,
          guidanceMessage: map['guidanceMessage'] as String?,
          officialQuestionUrl: officialQuestionUrl,
          verification: _parseVerification(map['verification'], id),
        ),
      );
    }

    // relatedArticleIds doğrulaması: ancak tüm id'ler toplandıktan SONRA
    // yapılabilir (ileri referanslar geçerlidir).
    final allIds = articles.map((a) => a.id).toSet();
    for (final article in articles) {
      for (final relatedId in article.relatedArticleIds) {
        if (!allIds.contains(relatedId)) {
          throw ContentSchemaError(
            'İçerik ${article.id} tanımsız ilgili içeriğe referans veriyor: '
            '$relatedId',
          );
        }
      }
      for (final prerequisiteId in article.prerequisiteArticleIds) {
        if (!allIds.contains(prerequisiteId)) {
          throw ContentSchemaError(
            'İçerik ${article.id} tanımsız ön koşula referans veriyor: '
            '$prerequisiteId',
          );
        }
      }
    }

    return articles;
  }

  /// Locale katalogları arasındaki çapraz tutarlılık (TASK 057 §10).
  ///
  /// Kurallar:
  /// - Üç locale AYNI içerik id kümesini taşımalıdır.
  /// - Bir çeviri, Türkçe kanonik kayıttan DAHA GÜÇLÜ bir yayın durumunda
  ///   olamaz: TR yayında değilse çeviri de yayında olamaz.
  static void validateLocaleConsistency({
    required List<LearningArticle> canonical,
    required Map<String, List<LearningArticle>> translations,
  }) {
    final canonicalIds = {for (final a in canonical) a.id};
    final publishedCanonical = {
      for (final a in canonical)
        if (a.isPublished) a.id,
    };

    translations.forEach((locale, articles) {
      final ids = {for (final a in articles) a.id};
      if (ids.length != canonicalIds.length || !ids.containsAll(canonicalIds)) {
        throw ContentSchemaError(
          '$locale kataloğu Türkçe katalogla aynı içerik id kümesini '
          'taşımıyor',
        );
      }
      for (final article in articles) {
        if (article.isPublished && !publishedCanonical.contains(article.id)) {
          throw ContentSchemaError(
            '$locale/${article.id} yayında ama Türkçe kanonik kayıt '
            'yayında değil — çeviri kanonikten güçlü olamaz',
          );
        }
      }
    });
  }

  /// Kaynak gövdesi doğrulama kaydını okur (TASK 056A §2).
  ///
  /// Locator kalite kontrolü BURADA yapılır: genel bir ana sayfa adresi
  /// (ör. `https://kurul.diyanet.gov.tr/tr/fetvalar`) özel bir dinî hükme
  /// KANIT sayılmaz — kesin sayfa/bölüm gösterilmelidir.
  static SourceVerification? _parseVerification(Object? raw, String articleId) {
    if (raw == null) {
      return null;
    }
    final map = _asMap(raw, 'article[$articleId].verification');
    final locator = (map['sourceLocator'] as String? ?? '').trim();
    final bodyVerified = map['sourceBodyVerified'] == true;

    if (bodyVerified && _isGenericHomepageLocator(locator)) {
      throw ContentSchemaError(
        'İçerik $articleId genel bir ana sayfayı kesin kaynak konumu gibi '
        'kullanıyor: "$locator"',
      );
    }

    return SourceVerification(
      sourceBodyVerified: bodyVerified,
      sourceId: _requireString(
        map,
        'sourceId',
        'article[$articleId].verification',
      ),
      sourceLocator: locator,
      evidenceSummary: (map['evidenceSummary'] as String? ?? '').trim(),
      verifiedAt: (map['verifiedAt'] as String? ?? '').trim(),
      verifiedBy: _parseEnum(
        VerifiedBy.values,
        _requireString(map, 'verifiedBy', 'article[$articleId].verification'),
        'verifiedBy',
      ),
      verificationMethod: _parseEnum(
        VerificationMethod.values,
        _requireString(
          map,
          'verificationMethod',
          'article[$articleId].verification',
        ),
        'verificationMethod',
      ),
      blocker: map['blocker'] as String?,
    );
  }

  /// Kesin konum içermeyen locator'lar (TASK 056A §4).
  ///
  /// Kabul edilebilir bir locator, kaynağın İÇİNDEKİ yeri gösterir:
  /// sayfa numarası, bölüm başlığı veya belirli bir fetva/cevap başlığı.
  ///
  /// ÇIPLAK bir adres — `https://kurul.diyanet.gov.tr/tr/fetvalar` gibi —
  /// kaç yol parçası taşırsa taşısın kesin konum DEĞİLDİR: bir liste
  /// sayfası, özel bir dinî hükme kanıt olamaz. Bu yüzden kural yol
  /// derinliğine değil, "locator yalnızca bir URL mi?" sorusuna bakar.
  static bool _isGenericHomepageLocator(String locator) {
    if (locator.isEmpty) {
      return true;
    }
    // Açıklayıcı metin içermeyen (boşluksuz) mutlak adres → çıplak URL.
    if (!locator.contains(RegExp(r'\s'))) {
      final uri = Uri.tryParse(locator);
      if (uri != null && uri.hasScheme && uri.hasAuthority) {
        return true;
      }
    }
    return false;
  }

  static List<LearningSection> _parseSections(Object? raw, String articleId) {
    final list = _asList(raw, 'article[$articleId].sections');
    if (list.isEmpty) {
      throw ContentSchemaError('İçerik $articleId bölümsüz olamaz');
    }
    return [
      for (final entry in list)
        () {
          final map = _asMap(entry, 'article[$articleId].section');
          return LearningSection(
            type: _parseEnum(
              LearningSectionType.values,
              _requireString(map, 'type', 'article[$articleId].section'),
              'sectionType',
            ),
            text: map['text'] as String?,
            items: _stringList(map['items']),
          );
        }(),
    ];
  }

  // ---------------------------------------------------------------------
  // Yardımcılar
  // ---------------------------------------------------------------------

  static void _checkSchemaVersion(Map<String, Object?> root, String file) {
    final version = root['schemaVersion'];
    if (version != supportedSchemaVersion) {
      throw ContentSchemaError(
        '$file şema sürümü desteklenmiyor: $version '
        '(beklenen $supportedSchemaVersion)',
      );
    }
  }

  static Map<String, Object?> _asMap(Object? value, String context) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    throw ContentSchemaError('$context geçerli bir nesne değil');
  }

  static List<Object?> _asList(Object? value, String context) {
    if (value is List) {
      return value;
    }
    throw ContentSchemaError('$context geçerli bir liste değil');
  }

  static String _requireString(
    Map<String, Object?> map,
    String key,
    String context,
  ) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw ContentSchemaError('$context.$key zorunlu bir metin alanıdır');
  }

  static int _requireInt(Map<String, Object?> map, String key, String context) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    throw ContentSchemaError('$context.$key zorunlu bir sayı alanıdır');
  }

  static List<String> _stringList(Object? value) {
    if (value == null) {
      return const <String>[];
    }
    if (value is List) {
      return [
        for (final entry in value)
          if (entry is String) entry,
      ];
    }
    throw const ContentSchemaError('Beklenen metin listesi bulunamadı');
  }

  /// Locale haritasından metin çözer; karşılık yoksa Türkçeye (kanonik
  /// kaynak dili) düşer.
  static String _localized(Object? value, String locale, String context) {
    final map = _asMap(value, context);
    final selected = map[locale] ?? map['tr'];
    if (selected is String && selected.trim().isNotEmpty) {
      return selected;
    }
    throw ContentSchemaError('$context için metin bulunamadı');
  }

  static T _parseEnum<T extends Enum>(
    List<T> values,
    String raw,
    String field,
  ) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
    throw ContentSchemaError('Tanınmayan $field değeri: $raw');
  }
}

/// İçerik şeması ihlali — bozuk veri SESSİZCE yutulmaz.
final class ContentSchemaError implements Exception {
  const ContentSchemaError(this.message);

  final String message;

  @override
  String toString() => 'ContentSchemaError: $message';
}

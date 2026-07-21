import 'package:bismillah_app/core/text/islamic_text_normalizer.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Tek bir makalenin sıralama sonucu.
final class AssistantRankedArticle {
  const AssistantRankedArticle({
    required this.article,
    required this.score,
    required this.confidence,
  });

  final LearningArticle article;
  final int score;
  final AssistantConfidence confidence;
}

/// Retrieval sonucu: en fazla 3 makale + genel güven düzeyi (en iyi
/// makaleye göre).
final class AssistantRetrievalResult {
  const AssistantRetrievalResult({
    required this.articles,
    required this.confidence,
  });

  static const AssistantRetrievalResult empty = AssistantRetrievalResult(
    articles: [],
    confidence: AssistantConfidence.insufficient,
  );

  final List<AssistantRankedArticle> articles;
  final AssistantConfidence confidence;

  bool get hasGroundedMatch =>
      confidence == AssistantConfidence.exact ||
      confidence == AssistantConfidence.strong;
}

/// Yayınlanmış Learn makaleleri üzerinden deterministik retrieval (TASK
/// 059 §8).
///
/// Sıralama öncelikleri: exact başlık → exact alias → öbek → anahtar kelime
/// → kategori → özet token örtüşmesi → içerik bölümü token örtüşmesi.
/// Pending içerik zaten depoya girmez; buraya YALNIZ published gelir.
abstract final class AssistantRetriever {
  static const int maxArticles = 3;

  /// Retrieval'a katkısı olmayan sorgu-tipi kelimeler (normalize edilmiş).
  static const Set<String> _stopwords = {
    'nasil',
    'nedir',
    'nelerdir',
    'ne',
    'mi',
    'mu',
    'midir',
    'mudur',
    'hangi',
    'kac',
    'kim',
    'nicin',
    'neden',
    'bir',
    'bu',
    'su',
    'icin',
    've',
    'ile',
    'how',
    'what',
    'is',
    'are',
    'the',
    'do',
    'does',
    'of',
    'in',
    'to',
    'and',
    'ما',
    'هو',
    'هي',
    'كيف',
    'هل',
    'من',
    'في',
  };

  static AssistantRetrievalResult rank(
    String query,
    List<LearningArticle> articles, {
    Map<String, String> categoryTitleById = const {},
  }) {
    final qNorm = IslamicTextNormalizer.normalize(query);
    if (qNorm.length < 2) {
      return AssistantRetrievalResult.empty;
    }
    final qTokens = IslamicTextNormalizer.tokenize(
      query,
    ).where((t) => !_stopwords.contains(t)).toSet();

    final ranked = <AssistantRankedArticle>[];
    for (final article in articles) {
      final scored = _score(article, qNorm, qTokens, categoryTitleById);
      if (scored.score > 0) {
        ranked.add(scored);
      }
    }
    if (ranked.isEmpty) {
      return AssistantRetrievalResult.empty;
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      // Deterministik: eşit skorda başlığa göre sabit sıra.
      return byScore != 0
          ? byScore
          : a.article.title.compareTo(b.article.title);
    });

    final top = ranked.take(maxArticles).toList(growable: false);
    return AssistantRetrievalResult(
      articles: top,
      confidence: top.first.confidence,
    );
  }

  static AssistantRankedArticle _score(
    LearningArticle article,
    String qNorm,
    Set<String> qTokens,
    Map<String, String> categoryTitleById,
  ) {
    final titleNorm = IslamicTextNormalizer.normalize(article.title);
    final aliasNorms = [
      for (final k in article.keywords) IslamicTextNormalizer.normalize(k),
    ];

    var score = 0;
    var confidence = AssistantConfidence.insufficient;

    // 1) exact normalized title.
    if (titleNorm == qNorm) {
      return AssistantRankedArticle(
        article: article,
        score: 1000,
        confidence: AssistantConfidence.exact,
      );
    }
    // 2) exact alias.
    if (aliasNorms.contains(qNorm)) {
      return AssistantRankedArticle(
        article: article,
        score: 900,
        confidence: AssistantConfidence.exact,
      );
    }

    // 3) phrase match (başlık ⊆ sorgu veya sorgu ⊆ başlık) → strong.
    final phraseHit =
        (qNorm.length >= 4 && titleNorm.contains(qNorm)) ||
        (titleNorm.length >= 4 && qNorm.contains(titleNorm)) ||
        aliasNorms.any((a) => a.length >= 4 && qNorm.contains(a));
    if (phraseHit) {
      score += 500;
      confidence = AssistantConfidence.strong;
    }

    // 4) anahtar kelime (token) örtüşmesi: başlık + alias token'ları.
    final titleTokens = IslamicTextNormalizer.tokenize(article.title).toSet();
    final aliasTokens = {
      for (final k in article.keywords) ...IslamicTextNormalizer.tokenize(k),
    };
    final keyTokenHits = qTokens
        .where((t) => titleTokens.contains(t) || aliasTokens.contains(t))
        .length;
    score += keyTokenHits * 60;

    // 5) kategori adı örtüşmesi.
    final categoryTitle = categoryTitleById[article.categoryId];
    if (categoryTitle != null) {
      final categoryTokens = IslamicTextNormalizer.tokenize(
        categoryTitle,
      ).toSet();
      if (qTokens.any(categoryTokens.contains)) {
        score += 30;
      }
    }

    // 6) özet token örtüşmesi.
    final summaryTokens = IslamicTextNormalizer.tokenize(
      article.summary,
    ).toSet();
    score += qTokens.where(summaryTokens.contains).length * 12;

    // 7) içerik bölümü token örtüşmesi (metin blokları).
    final sectionTokens = <String>{};
    for (final section in article.sections) {
      final text = section.text;
      if (text != null) {
        sectionTokens.addAll(IslamicTextNormalizer.tokenize(text));
      }
      for (final item in section.items) {
        sectionTokens.addAll(IslamicTextNormalizer.tokenize(item));
      }
    }
    score += qTokens.where(sectionTokens.contains).length * 4;

    // Güven düzeyi: öbek eşleşmesi veya güçlü anahtar örtüşmesi → strong;
    // tek/zayıf sinyal → related.
    if (confidence != AssistantConfidence.strong) {
      if (keyTokenHits >= 2) {
        confidence = AssistantConfidence.strong;
      } else if (score > 0) {
        confidence = AssistantConfidence.related;
      }
    }

    return AssistantRankedArticle(
      article: article,
      score: score,
      confidence: confidence,
    );
  }

  /// Bir makalenin "kesin hüküm" cevabında kullanılabilmesi için doğrulanmış
  /// fatwa/officialAnswer olması gerekir (TASK 059 §2/§9).
  static bool isVerdictCapable(LearningArticle article) =>
      article.contentType == LearningContentType.officialFatwa &&
      article.isSourceBodyVerified;
}

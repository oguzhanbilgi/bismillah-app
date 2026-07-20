import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/bismillah_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_response_composer.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_retriever.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_response_strings.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_knowledge_repository.dart';

/// Locale → sabit yerelleştirilmiş metin çözücü. Presentation/application
/// katmanında AppLocalizations'tan kurulur; domain l10n'a bağlanmaz.
typedef AssistantStringsResolver =
    AssistantResponseStrings Function(String locale);

/// Tamamen yerel, kaynağa dayalı asistan (TASK 059 §6/§9).
///
/// - Yalnız [LearningKnowledgeRepository] üzerinden YAYINLANMIŞ içerik görür
///   (asset ikinci kez ayrıştırılmaz, pending/draft erişilemez).
/// - Ağ/Firebase kullanmaz, UI widget'ı döndürmez.
/// - Sınıflandırma → retrieval → kaynak çözümü → deterministik composer.
final class LocalSourceGroundedAssistantRepository
    implements BismillahAssistantRepository {
  const LocalSourceGroundedAssistantRepository(
    this._knowledge,
    this._stringsResolver,
  );

  /// Yönlendirme için resmî kaynak id'leri (sources.json'da doğrulanmış).
  /// URL tahmin edilmez — kaynak modelinden okunur.
  static const List<String> _guidanceSourceIds = [
    'diyanet-dini-soru-hizmetleri',
    'diyanet-din-isleri-yuksek-kurulu',
  ];

  final LearningKnowledgeRepository _knowledge;
  final AssistantStringsResolver _stringsResolver;

  @override
  Future<AssistantResponse> answer(AssistantQuery query) async {
    final strings = _stringsResolver(query.locale);
    final queryClass = AssistantQueryClassifier.classify(query.text);

    try {
      final articles = await _publishedArticles(query.locale);
      final categoryTitles = await _categoryTitles(query.locale);
      final retrieval = AssistantRetriever.rank(
        query.text,
        articles,
        categoryTitleById: categoryTitles,
      );

      final grounded = await _resolveGrounded(retrieval);
      final guidanceUrl = await _guidanceUrl();

      return AssistantResponseComposer.compose(
        queryClass: queryClass,
        confidence: retrieval.confidence,
        grounded: grounded,
        strings: strings,
        officialGuidanceUrl: guidanceUrl,
      );
    } on Exception {
      // Herhangi bir okuma hatasında bile UYDURMA YOK: güvenli boş cevap.
      return AssistantResponseComposer.compose(
        queryClass: queryClass,
        confidence: AssistantConfidence.insufficient,
        grounded: const [],
        strings: strings,
      );
    }
  }

  Future<List<LearningArticle>> _publishedArticles(String locale) async {
    final result = await _knowledge.getAllPublished(locale);
    return result.fold(
      onSuccess: (value) => value,
      onFailure: (_) => const <LearningArticle>[],
    );
  }

  Future<Map<String, String>> _categoryTitles(String locale) async {
    final result = await _knowledge.getCategories(locale);
    return result.fold(
      onSuccess: (categories) => {
        for (final c in categories) c.category.id: c.category.title,
      },
      onFailure: (_) => const <String, String>{},
    );
  }

  Future<List<AssistantGroundedArticle>> _resolveGrounded(
    AssistantRetrievalResult retrieval,
  ) async {
    final out = <AssistantGroundedArticle>[];
    for (final ranked in retrieval.articles) {
      out.add(
        AssistantGroundedArticle(
          article: ranked.article,
          source: await _sourceReference(ranked.article),
        ),
      );
    }
    return out;
  }

  /// Makalenin DOĞRULANMIŞ birincil kaynağını (exact locator ile) künyeye
  /// dönüştürür. Doğrulama kaydı veya kaynak yoksa `null` (kart gösterilmez).
  Future<AssistantSourceReference?> _sourceReference(
    LearningArticle article,
  ) async {
    final verification = article.verification;
    if (verification == null) {
      return null;
    }
    final source = await _sourceById(verification.sourceId);
    if (source == null) {
      return null;
    }
    return AssistantSourceReference(
      sourceId: source.id,
      articleId: article.id,
      articleSlug: article.slug,
      institution: source.institution,
      title: source.title,
      sourceType: source.sourceType,
      sourceLocator: verification.sourceLocator,
      canonicalUrl: source.canonicalUrl,
      originalLanguage: source.originalLanguage,
      lastVerifiedAt: source.lastVerifiedAt,
    );
  }

  Future<KnowledgeSource?> _sourceById(String id) async {
    final result = await _knowledge.getSourceById(id);
    return result.fold(onSuccess: (source) => source, onFailure: (_) => null);
  }

  Future<String?> _guidanceUrl() async {
    for (final id in _guidanceSourceIds) {
      final source = await _sourceById(id);
      if (source != null) {
        return source.canonicalUrl;
      }
    }
    return null;
  }
}

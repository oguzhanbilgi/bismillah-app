import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Asistan cevabındaki kaynak künyesi (TASK 059 §5/§12).
///
/// Doğrulanmış [KnowledgeSource] + kaynağın atıf yaptığı Learn makalesinin
/// bağlanması için gereken bilgiyi taşır. Serbest metin/alıntı TAŞIMAZ —
/// asistanın düzenlediği özet ayrıdır, bu yalnız resmî künyedir.
final class AssistantSourceReference {
  const AssistantSourceReference({
    required this.sourceId,
    required this.articleId,
    required this.articleSlug,
    required this.institution,
    required this.title,
    required this.sourceType,
    required this.sourceLocator,
    required this.canonicalUrl,
    required this.originalLanguage,
    required this.lastVerifiedAt,
  });

  final String sourceId;

  /// Kaynağın atıf yaptığı Learn makalesi ("Learn'de oku" için).
  final String articleId;
  final String articleSlug;

  /// Kurum (ör. "T.C. Diyanet İşleri Başkanlığı").
  final String institution;

  /// Eser/sayfa başlığı.
  final String title;

  final KnowledgeSourceType sourceType;

  /// KESİN konum (basılı eser sayfası / bölüm başlığı / fetva sayfası).
  final String sourceLocator;

  final String canonicalUrl;
  final String originalLanguage;
  final String lastVerifiedAt;
}

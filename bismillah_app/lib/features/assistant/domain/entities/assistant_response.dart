import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';

/// İlgili Learn makalesinin gezinme künyesi (TASK 059 §12).
final class AssistantRelatedArticle {
  const AssistantRelatedArticle({
    required this.id,
    required this.slug,
    required this.title,
  });

  final String id;
  final String slug;
  final String title;
}

/// Deterministik olarak oluşturulmuş asistan cevabı (TASK 059 §5/§9).
///
/// Harici AI YOKTUR: tüm alanlar doğrulanmış makale bloklarından türetilir.
/// Kaynak bulunmadığında güvenli yönlendirme cevabı da bu modelle döner.
final class AssistantResponse {
  const AssistantResponse({
    required this.answerType,
    required this.confidence,
    required this.answer,
    required this.shortSummary,
    this.steps = const [],
    this.keyPoints = const [],
    this.practicalAction,
    this.differenceNote,
    this.safetyNotice,
    this.sourceReferences = const [],
    this.relatedArticles = const [],
    this.shouldOfferOfficialGuidance = false,
    this.officialGuidanceUrl,
  });

  final AssistantAnswerType answerType;
  final AssistantConfidence confidence;

  /// Asistanın düzenlediği ana cevap metni (Diyanet alıntısı DEĞİL).
  final String answer;

  /// Kısa özet satırı.
  final String shortSummary;

  /// Adım adım rehber blokları (how-to).
  final List<String> steps;

  /// Öne çıkan maddeler.
  final List<String> keyPoints;

  /// Pratik eylem önerisi (varsa).
  final String? practicalAction;

  /// Görüş/mezhep farkı notu — varsa GİZLENMEZ (kaynaktan aynen).
  final String? differenceNote;

  /// Yalnız gerektiğinde gösterilen güvenlik notu.
  final String? safetyNotice;

  final List<AssistantSourceReference> sourceReferences;
  final List<AssistantRelatedArticle> relatedArticles;

  /// Din İşleri Yüksek Kurulu / Dinî Soru Hizmetleri yönlendirmesi sunulsun mu.
  final bool shouldOfferOfficialGuidance;

  /// Yönlendirilecek resmî sayfa (allowlist'ten geçer; varsa).
  final String? officialGuidanceUrl;
}

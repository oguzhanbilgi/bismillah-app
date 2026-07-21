import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';

/// Sohbet geçmişindeki tek mesaj (TASK 059 §5/§13).
///
/// Kullanıcı mesajlarında [answerType]/[confidence]/[response] boştur.
/// Asistan mesajları canlı oturumda [response]'u taşır (zengin kart:
/// adımlar/maddeler); yeniden açılışta yüklenen geçmiş için [response]
/// boştur ve kart sade biçimde ([text] + [sources] + [relatedArticleIds])
/// çizilir.
final class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.answerType,
    this.confidence,
    this.sources = const [],
    this.relatedArticleIds = const [],
    this.safetyNotice,
    this.response,
  });

  /// Kullanıcı mesajı fabrikası.
  factory AssistantMessage.user({
    required String id,
    required String text,
    required DateTime createdAt,
  }) => AssistantMessage(
    id: id,
    role: AssistantRole.user,
    text: text,
    createdAt: createdAt,
  );

  /// Asistan mesajını canlı [AssistantResponse]'tan üretir.
  factory AssistantMessage.fromResponse({
    required String id,
    required DateTime createdAt,
    required AssistantResponse response,
  }) => AssistantMessage(
    id: id,
    role: AssistantRole.assistant,
    text: response.answer,
    createdAt: createdAt,
    answerType: response.answerType,
    confidence: response.confidence,
    sources: response.sourceReferences,
    relatedArticleIds: [for (final a in response.relatedArticles) a.id],
    safetyNotice: response.safetyNotice,
    response: response,
  );

  final String id;
  final AssistantRole role;
  final String text;
  final DateTime createdAt;

  final AssistantAnswerType? answerType;
  final AssistantConfidence? confidence;

  final List<AssistantSourceReference> sources;
  final List<String> relatedArticleIds;
  final String? safetyNotice;

  /// Canlı zengin görünüm (adımlar/maddeler). Kalıcı geçmişte SAKLANMAZ;
  /// yeniden açılışta `null`'dır.
  final AssistantResponse? response;

  bool get isUser => role == AssistantRole.user;
  bool get isAssistant => role == AssistantRole.assistant;
}

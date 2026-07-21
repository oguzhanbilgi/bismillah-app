import 'dart:convert';

import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı yerel geçmiş (TASK 059 §13).
///
/// Bozuk/eksik kayıt sakin biçimde boş listeye düşer (crash yok). Zengin
/// canlı görünüm (adımlar/maddeler) KALICI DEĞİLDİR — yeniden açılışta
/// mesaj sade kart (metin + kaynak + ilgili) olarak çizilir.
final class SharedPrefsAssistantHistoryRepository
    implements AssistantHistoryRepository {
  const SharedPrefsAssistantHistoryRepository();

  static const String _key = 'bismillah.assistant_history';
  static const int maxMessages = 20;

  @override
  Future<List<AssistantMessage>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final decoded = json.decode(raw);
      if (decoded is! List) {
        return const [];
      }
      final messages = <AssistantMessage>[];
      for (final entry in decoded) {
        final message = _decodeMessage(entry);
        if (message != null) {
          messages.add(message);
        }
      }
      return messages;
    } on Exception {
      // Bozuk JSON/okuma hatası (FormatException dâhil) → boş geçmiş.
      return const [];
    }
  }

  @override
  Future<void> save(List<AssistantMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final capped = messages.length > maxMessages
          ? messages.sublist(messages.length - maxMessages)
          : messages;
      final encoded = json.encode([
        for (final message in capped) _encodeMessage(message),
      ]);
      await prefs.setString(_key, encoded);
    } on Exception {
      // Yazma hatası sessizce yutulur; oturum içi görünüm bozulmaz.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } on Exception {
      // yut
    }
  }

  Map<String, Object?> _encodeMessage(AssistantMessage m) => {
    'id': m.id,
    'role': m.role.name,
    'text': m.text,
    'createdAt': m.createdAt.toUtc().toIso8601String(),
    'answerType': m.answerType?.name,
    'confidence': m.confidence?.name,
    'safetyNotice': m.safetyNotice,
    'relatedArticleIds': m.relatedArticleIds,
    'sources': [for (final s in m.sources) _encodeSource(s)],
  };

  Map<String, Object?> _encodeSource(AssistantSourceReference s) => {
    'sourceId': s.sourceId,
    'articleId': s.articleId,
    'articleSlug': s.articleSlug,
    'institution': s.institution,
    'title': s.title,
    'sourceType': s.sourceType.name,
    'sourceLocator': s.sourceLocator,
    'canonicalUrl': s.canonicalUrl,
    'originalLanguage': s.originalLanguage,
    'lastVerifiedAt': s.lastVerifiedAt,
  };

  AssistantMessage? _decodeMessage(Object? entry) {
    if (entry is! Map) {
      return null;
    }
    final id = entry['id'];
    final roleName = entry['role'];
    final text = entry['text'];
    final createdAt = entry['createdAt'];
    if (id is! String ||
        roleName is! String ||
        text is! String ||
        text.trim().isEmpty ||
        createdAt is! String) {
      return null;
    }
    final role = _byName(AssistantRole.values, roleName);
    final parsedDate = DateTime.tryParse(createdAt);
    if (role == null || parsedDate == null) {
      return null;
    }
    return AssistantMessage(
      id: id,
      role: role,
      text: text,
      createdAt: parsedDate,
      answerType: _byName(AssistantAnswerType.values, entry['answerType']),
      confidence: _byName(AssistantConfidence.values, entry['confidence']),
      safetyNotice: entry['safetyNotice'] is String
          ? entry['safetyNotice'] as String
          : null,
      relatedArticleIds: [
        if (entry['relatedArticleIds'] is List)
          for (final id in entry['relatedArticleIds'] as List)
            if (id is String) id,
      ],
      sources: [
        if (entry['sources'] is List)
          for (final s in entry['sources'] as List)
            if (_decodeSource(s) case final AssistantSourceReference ref) ref,
      ],
    );
  }

  AssistantSourceReference? _decodeSource(Object? entry) {
    if (entry is! Map) {
      return null;
    }
    final sourceType = _byName(KnowledgeSourceType.values, entry['sourceType']);
    if (sourceType == null) {
      return null;
    }
    String str(Object? v) => v is String ? v : '';
    return AssistantSourceReference(
      sourceId: str(entry['sourceId']),
      articleId: str(entry['articleId']),
      articleSlug: str(entry['articleSlug']),
      institution: str(entry['institution']),
      title: str(entry['title']),
      sourceType: sourceType,
      sourceLocator: str(entry['sourceLocator']),
      canonicalUrl: str(entry['canonicalUrl']),
      originalLanguage: str(entry['originalLanguage']),
      lastVerifiedAt: str(entry['lastVerifiedAt']),
    );
  }

  T? _byName<T extends Enum>(List<T> values, Object? name) {
    if (name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

import 'dart:convert';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı yerel geçmiş (TASK 059 §13; TASK 094 §B/§C).
///
/// Bozuk/eksik kayıt sakin biçimde boş listeye düşer (crash yok). Zengin
/// canlı görünüm (adımlar/maddeler) KALICI DEĞİLDİR — yeniden açılışta
/// mesaj sade kart (metin + kaynak + ilgili) olarak çizilir.
///
/// `queryClass` hiçbir zaman saklanmadı; yalnız ham `text` saklanır. TASK
/// 094 öncesinde `isSensitiveVerdict` üretim kodunda hiç çağrılmadığından
/// (bkz. TASK 086 F1), eski kayıtlarda hassas metin çiftleri kalmış
/// olabilir. `load()` bu yüzden her okumada geriye dönük bir TEMİZLİK
/// geçişi uygular; `classify` saf/statik olduğundan yeniden sınıflandırma
/// güvenlidir.
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
      final pruned = _pruneSensitive(messages);
      // Yalnız GERÇEKTEN hassas bir kayıt bulunup silindiyse geri yazılır.
      // Koşulsuz yeniden yazma YASAKTIR: `_decodeMessage` boş metin/geçersiz
      // tarih/bilinmeyen rol için `null` döner ve bu kayıtlar `messages`'a
      // hiç girmez — koşulsuz bir geri yazma, zararsız bozuk kayıtları
      // KALICI OLARAK SİLERDİ (TASK 094 §C BLOCKER).
      if (pruned.length != messages.length) {
        await _writeBack(prefs, pruned);
      }
      return pruned;
    } on Exception {
      // Bozuk JSON/okuma hatası (FormatException dâhil) → boş geçmiş.
      return const [];
    }
  }

  /// Kullanıcı mesajı yeniden sınıflandırıldığında hassasse, o mesajı VE
  /// yalnız hemen ardından gelen asistan mesajını (rol kontrolüyle, ASLA
  /// çift/tek indeks varsayımıyla değil — `save()` son 20'ye keserken
  /// listenin bir yetim asistan mesajıyla BAŞLAMASI mümkündür) düşürür.
  ///
  /// Anahtar kelime tabanlı sınıflandırma bilinçli olarak KABA'dır: masum
  /// bir cümle hassas bir anahtar kelime içeriyorsa da silinir (kabul
  /// edilen yanlış pozitif — TASK 094 §G.6). Ham hassas metin hiçbir yere
  /// LOGLANMAZ.
  List<AssistantMessage> _pruneSensitive(List<AssistantMessage> messages) {
    final drop = <String>{};
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.role != AssistantRole.user) {
        continue;
      }
      final queryClass = AssistantQueryClassifier.classify(message.text);
      if (!AssistantQueryClassifier.isSensitiveVerdict(queryClass)) {
        continue;
      }
      drop.add(message.id);
      final next = i + 1 < messages.length ? messages[i + 1] : null;
      if (next != null && next.role == AssistantRole.assistant) {
        drop.add(next.id);
      }
    }
    if (drop.isEmpty) {
      return messages;
    }
    return [
      for (final m in messages)
        if (!drop.contains(m.id)) m,
    ];
  }

  /// Temizlik sonrası geri yazma. `save()`'in genel yolundan AYRIDIR:
  /// [messages] zaten en fazla 20 öğe içerir (önceden yazılmıştı) ve
  /// yeniden sınıflandırma/tekrar kesme YAPILMAMALIDIR.
  ///
  /// `save()` yalnız `Exception` yakalar; burada — build() içindeki bir
  /// provider'dan çağrıldığından — beklenmeyen bir `Error` de sessizce
  /// kapsanır (TASK 094 §C). Ham metin, hata mesajına da YAZILMAZ.
  Future<void> _writeBack(
    SharedPreferences prefs,
    List<AssistantMessage> messages,
  ) async {
    try {
      final encoded = json.encode([
        for (final message in messages) _encodeMessage(message),
      ]);
      await prefs.setString(_key, encoded);
    } on Exception {
      // yazma hatası → oturumda temizlenmiş liste yine de döner.
    } on Error {
      // beklenmeyen hata da build() güvenliği için burada durdurulur.
    }
  }

  /// Mesajları kalıcı yazar.
  ///
  /// SAVUNMA DERİNLİĞİ (TASK 094 §A): çağıran zaten filtrelese de, bu
  /// sınır ADI GEÇEN TEK kanonik yüklemi (`isSensitiveVerdict`) kendisi de
  /// uygular. Böylece depoyu DOĞRUDAN çağıran bir kod yolu (yeni bir
  /// controller, bir test yardımcısı, ileride eklenecek bir özellik)
  /// hassas geçmişi diske YAZAMAZ. İkinci bir hassasiyet listesi
  /// TUTULMAZ — [_pruneSensitive] `load()` ile AYNI mantığı paylaşır.
  ///
  /// Yazma başarısız olursa sessizce "başarılı" DENMEZ: sonuç
  /// [ResultFuture] ile taşınır (TASK 094 §A).
  @override
  ResultFuture<void> save(List<AssistantMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Önce hassas kayıtlar düşürülür, SONRA son 20'ye kesilir: sıralama
      // önemlidir, aksi hâlde düşen kayıtlar kotayı boşuna doldururdu.
      final safe = _pruneSensitive(messages);
      final capped = safe.length > maxMessages
          ? safe.sublist(safe.length - maxMessages)
          : safe;
      final encoded = json.encode([
        for (final message in capped) _encodeMessage(message),
      ]);
      await prefs.setString(_key, encoded);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
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
      // `_encodeMessage` anı UTC olarak yazar (`...Z`), bu yüzden
      // `DateTime.tryParse` UTC bir `DateTime` döner. Canlı oturumdaki
      // mesajlar ise `DateTime.now()` ile YEREL üretilir. Dönüşüm burada
      // yapılmazsa yeniden açılışta aynı an UTC duvar saatiyle çizilirdi
      // (UTC+03 cihazda 14:12 → 11:12). `toLocal()` ANI DEĞİŞTİRMEZ;
      // yalnız cihazın kendi saat dilimine çevirir — sabit bir saat dilimi
      // varsayılmaz. Saklanan biçim değişmedi, göç/sıfırlama gerekmez.
      createdAt: parsedDate.toLocal(),
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

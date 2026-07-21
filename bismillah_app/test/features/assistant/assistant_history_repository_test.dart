import 'package:bismillah_app/features/assistant/data/shared_prefs_assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel sohbet geçmişi kalıcılığı (TASK 059 §13/§17).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = SharedPrefsAssistantHistoryRepository();

  AssistantMessage user(String id, String text) => AssistantMessage.user(
    id: id,
    text: text,
    createdAt: DateTime(2026, 7, 20, 10),
  );

  AssistantMessage assistant(String id) => AssistantMessage(
    id: id,
    role: AssistantRole.assistant,
    text: 'Kaynaklı cevap.',
    createdAt: DateTime(2026, 7, 20, 10, 1),
    answerType: AssistantAnswerType.definition,
    confidence: AssistantConfidence.exact,
    relatedArticleIds: const ['art-teyemmum-nedir'],
    sources: const [
      AssistantSourceReference(
        sourceId: 'diyanet-islam-ilmihali',
        articleId: 'art-teyemmum-nedir',
        articleSlug: 'teyemmum-nedir',
        institution: 'T.C. Diyanet İşleri Başkanlığı',
        title: 'İslam İlmihali',
        sourceType: KnowledgeSourceType.ilmihal,
        sourceLocator: 'VI. TEYEMMÜM, s. 118',
        canonicalUrl: 'https://kuran.diyanet.gov.tr/',
        originalLanguage: 'tr',
        lastVerifiedAt: '2026-07-19',
      ),
    ],
  );

  test('save → load round-trip alanları korur', () async {
    SharedPreferences.setMockInitialValues({});
    await repo.save([user('u1', 'Teyemmüm nedir?'), assistant('a1')]);

    final loaded = await repo.load();
    expect(loaded, hasLength(2));
    expect(loaded[0].role, AssistantRole.user);
    expect(loaded[0].text, 'Teyemmüm nedir?');
    expect(loaded[1].role, AssistantRole.assistant);
    expect(loaded[1].answerType, AssistantAnswerType.definition);
    expect(loaded[1].relatedArticleIds, ['art-teyemmum-nedir']);
    expect(loaded[1].sources.single.sourceLocator, 'VI. TEYEMMÜM, s. 118');
    // Zengin canlı görünüm KALICI değildir.
    expect(loaded[1].response, isNull);
  });

  test('en fazla 20 mesaj tutulur (son 20)', () async {
    SharedPreferences.setMockInitialValues({});
    final many = [for (var i = 0; i < 25; i++) user('u$i', 'soru $i')];
    await repo.save(many);

    final loaded = await repo.load();
    expect(loaded, hasLength(20));
    // İlk 5 düşer; son mesaj korunur.
    expect(loaded.first.text, 'soru 5');
    expect(loaded.last.text, 'soru 24');
  });

  test('clear geçmişi siler', () async {
    SharedPreferences.setMockInitialValues({});
    await repo.save([user('u1', 'soru')]);
    await repo.clear();
    expect(await repo.load(), isEmpty);
  });

  test('bozuk kayıt sakin biçimde boş listeye düşer', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.assistant_history': '{ not valid json',
    });
    expect(await repo.load(), isEmpty);
  });
}

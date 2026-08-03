import 'dart:convert';

import 'package:bismillah_app/features/assistant/data/shared_prefs_assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 094 §A — KALICILIK SINIRINDA savunma derinliği.
///
/// TASK 094'ün ilk bölümü hassas geçmişin ÜRETİMDEKİ çağırandan (controller)
/// yazılmasını engelledi. Buradaki testler depoyu **DOĞRUDAN** çağırır —
/// yani UI/controller filtresini tamamen ATLAYARAK — ve hassas kaydın yine
/// de diske yazılmadığını kanıtlar.
///
/// İkinci bir hassasiyet listesi YOKTUR: depo da
/// [AssistantQueryClassifier.isSensitiveVerdict] kullanır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = SharedPrefsAssistantHistoryRepository();
  const key = 'bismillah.assistant_history';

  AssistantMessage user(String id, String text) => AssistantMessage(
    id: id,
    role: AssistantRole.user,
    text: text,
    createdAt: DateTime.utc(2026, 7, 30, 10),
  );

  AssistantMessage assistant(String id) => AssistantMessage(
    id: id,
    role: AssistantRole.assistant,
    text: 'Genel bilgi cevabı.',
    createdAt: DateTime.utc(2026, 7, 30, 10, 1),
  );

  Future<List<String>> storedTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) {
      return const [];
    }
    return [
      for (final e in json.decode(raw) as List) (e as Map)['text'] as String,
    ];
  }

  // Her kanonik hassas sınıf için gerçek bir örnek. Sınıflandırma testin
  // kendi içinde DOĞRULANIR: örnek metin beklenen sınıfa düşmezse test
  // anlamsızlaşırdı.
  const sensitiveSamples = <AssistantQueryClass, String>{
    AssistantQueryClass.worshipRule: 'Kan abdesti bozar mı?',
    AssistantQueryClass.halalHaramVerdict: 'Bu davranış caiz midir?',
    AssistantQueryClass.personalCase: 'Ben kredi çektim, günah mı?',
  };

  group('§A — örnek metinler gerçekten beklenen sınıfa düşer', () {
    for (final entry in sensitiveSamples.entries) {
      test('"${entry.value}" → ${entry.key.name}', () {
        expect(AssistantQueryClassifier.classify(entry.value), entry.key);
        expect(AssistantQueryClassifier.isSensitiveVerdict(entry.key), isTrue);
      });
    }

    test('kontrol: normal soru hassas DEĞİLDİR', () {
      final queryClass = AssistantQueryClassifier.classify('Teyemmüm nedir?');
      expect(AssistantQueryClassifier.isSensitiveVerdict(queryClass), isFalse);
    });
  });

  group('§A — depo DOĞRUDAN çağrıldığında hassas kayıt YAZILMAZ', () {
    for (final entry in sensitiveSamples.entries) {
      test('${entry.key.name} çifti diske hiç ulaşmaz', () async {
        SharedPreferences.setMockInitialValues({});

        // Controller ATLANIYOR: hassas çift doğrudan depoya veriliyor.
        final result = await repo.save([
          user('u1', entry.value),
          assistant('a1'),
        ]);

        expect(result.isSuccess, isTrue);
        expect(
          await storedTexts(),
          isEmpty,
          reason: '${entry.key.name} kaydı diske yazıldı — sınır korumadı.',
        );
        expect(await repo.load(), isEmpty);
      });
    }

    test('hassas çift düşerken NORMAL kayıtlar korunur', () async {
      SharedPreferences.setMockInitialValues({});

      await repo.save([
        user('u1', 'Teyemmüm nedir?'),
        assistant('a1'),
        user('u2', 'Kan abdesti bozar mı?'), // hassas
        assistant('a2'),
        user('u3', 'Namaz nedir?'),
        assistant('a3'),
      ]);

      final texts = await storedTexts();
      expect(texts, contains('Teyemmüm nedir?'));
      expect(texts, contains('Namaz nedir?'));
      expect(texts, isNot(contains('Kan abdesti bozar mı?')));
      // Hassas kullanıcı mesajının hemen ardındaki asistan cevabı da düşer:
      // 6 mesajdan 4'ü kalır.
      expect(texts.length, 4);
    });
  });

  group('§A — normal geçmiş ESKİSİ GİBİ çalışır', () {
    test('hassas olmayan kayıt yazılır ve geri okunur', () async {
      SharedPreferences.setMockInitialValues({});

      final result = await repo.save([
        user('u1', 'Teyemmüm nedir?'),
        assistant('a1'),
      ]);

      expect(result.isSuccess, isTrue);
      final loaded = await repo.load();
      expect(loaded.length, 2);
      expect(loaded.first.text, 'Teyemmüm nedir?');
    });

    test('20 mesaj sınırı korunur (hassas filtreden SONRA kesilir)', () async {
      SharedPreferences.setMockInitialValues({});

      await repo.save([
        for (var i = 0; i < 30; i++) user('u$i', 'Namaz nedir? $i'),
      ]);

      final texts = await storedTexts();
      expect(texts.length, SharedPrefsAssistantHistoryRepository.maxMessages);
      // Kesme SONDAN yapılır: en yeni kayıtlar kalır.
      expect(texts.last, 'Namaz nedir? 29');
    });

    test(
      'hassas kayıtlar kotayı DOLDURMAZ — filtre kesmeden önce çalışır',
      () async {
        SharedPreferences.setMockInitialValues({});

        // 10 hassas + 12 normal: hassas olanlar önce düşerse 12 normal
        // kaydın hepsi kalır (kota 20).
        await repo.save([
          for (var i = 0; i < 10; i++) user('s$i', 'Kan abdesti bozar mı? $i'),
          for (var i = 0; i < 12; i++) user('n$i', 'Namaz nedir? $i'),
        ]);

        final texts = await storedTexts();
        expect(texts.length, 12);
        expect(texts.every((t) => t.startsWith('Namaz nedir?')), isTrue);
      },
    );
  });

  group('§A — eski (legacy) temizlik davranışı DEĞİŞMEDİ', () {
    test('okuma sırasında eski hassas kayıt hâlâ temizlenir', () async {
      // Depo sınırını atlayarak doğrudan ham JSON yazılıyor: TASK 094
      // öncesi diskte kalmış bir kaydı temsil eder.
      final legacy = json.encode([
        {
          'id': 'old-u',
          'role': 'user',
          'text': 'Kan abdesti bozar mı?',
          'createdAt': '2026-07-01T10:00:00.000Z',
        },
        {
          'id': 'old-a',
          'role': 'assistant',
          'text': 'Eski cevap.',
          'createdAt': '2026-07-01T10:01:00.000Z',
        },
      ]);
      SharedPreferences.setMockInitialValues({key: legacy});

      expect(await repo.load(), isEmpty);
      expect(await storedTexts(), isEmpty, reason: 'geri yazma yapılmadı');
    });

    test('temizlik idempotenttir ve normal kaydı silmez', () async {
      final legacy = json.encode([
        {
          'id': 'ok-u',
          'role': 'user',
          'text': 'Teyemmüm nedir?',
          'createdAt': '2026-07-01T10:00:00.000Z',
        },
      ]);
      SharedPreferences.setMockInitialValues({key: legacy});

      final first = await repo.load();
      final second = await repo.load();
      expect(first.length, 1);
      expect(second.length, 1);
      expect(second.first.text, 'Teyemmüm nedir?');
      // Hiç hassas kayıt yoktu → bayt bayt aynı kalmalı.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key), legacy);
    });
  });

  group('§A — başarısızlık BAŞARI gibi raporlanamaz', () {
    test('save() tipli bir sonuç döndürür (sessiz void değil)', () async {
      SharedPreferences.setMockInitialValues({});
      final result = await repo.save([user('u1', 'Teyemmüm nedir?')]);
      // Sözleşme ResultFuture: çağıran başarıyı/başarısızlığı GÖREBİLİR.
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('clear() başarısı tipli sonuçla taşınır', () async {
      SharedPreferences.setMockInitialValues({});
      await repo.save([user('u1', 'Teyemmüm nedir?')]);
      final cleared = await repo.clear();
      expect(cleared.isSuccess, isTrue);
      expect(await repo.load(), isEmpty);
    });
  });
}

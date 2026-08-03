import 'dart:convert';

import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/data/shared_prefs_assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 094 — Asistan gizlilik/kalıcılık düzeltmesi ve editorialReview
/// yönetişim etiketinin doğrulanması.
///
/// Kapsam: TASK 086 F1 bulgusu (worshipRule kalıcılık kapısında EKSİKTİ),
/// eski (TASK 094 öncesi) kayıtlarda kalmış olası hassas kayıtların
/// `load()` sırasında geriye dönük temizlenmesi, ve `clear()` başarısızlığının
/// artık "başarılı" gibi raporlanmaması.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = SharedPrefsAssistantHistoryRepository();
  const key = 'bismillah.assistant_history';

  AssistantMessage user(String id, String text, {int minute = 0}) =>
      AssistantMessage.user(
        id: id,
        text: text,
        createdAt: DateTime(2026, 7, 20, 10, minute),
      );

  AssistantMessage assistant(String id, {int minute = 1}) => AssistantMessage(
    id: id,
    role: AssistantRole.assistant,
    text: 'Kaynaklı cevap.',
    createdAt: DateTime(2026, 7, 20, 10, minute),
  );

  group('§B/§C — eski hassas kayıtların geriye dönük temizlenmesi', () {
    test('eski hassas kullanıcı+asistan çifti load() tarafından DÖNDÜRÜLMEZ '
        've depodan SİLİNİR', () async {
      SharedPreferences.setMockInitialValues({});
      // save() sınıflandırma YAPMAZ — bu, TASK 094 öncesi bir yazımı
      // (queryClass hiç kontrol edilmeden) simüle eder.
      await repo.save([
        user('u1', 'Teyemmüm nedir?'), // normal
        assistant('a1'),
        user('u2', 'Kan abdesti bozar mı?'), // worshipRule — eski hassas
        assistant('a2', minute: 2),
      ]);

      final loaded = await repo.load();
      expect(loaded.map((m) => m.id), ['u1', 'a1']);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      expect(raw, isNotNull);
      expect(raw, isNot(contains('Kan abdesti bozar mı')));
      final decoded = json.decode(raw!) as List;
      expect(decoded, hasLength(2));
    });

    test(
      'kabul edilmiş yanlış pozitif: anahtar kelime İÇEREN masum cümle de '
      'silinir (bilinçli bir kaba filtre, hassas ANLAM analizi DEĞİL)',
      () async {
        SharedPreferences.setMockInitialValues({});
        await repo.save([
          user('u1', 'bu gürültü konsantrasyonumu bozar mı'),
          assistant('a1'),
        ]);

        final loaded = await repo.load();
        expect(loaded, isEmpty);
      },
    );

    test('idempotenttir: iki ardışık load() aynı sonucu verir ve ikincisi '
        'anahtarı TEKRAR YAZMAZ', () async {
      SharedPreferences.setMockInitialValues({});
      await repo.save([
        user('u1', 'Teyemmüm nedir?'),
        assistant('a1'),
        user('u2', 'Bu caiz midir?'),
        assistant('a2', minute: 2),
      ]);

      final first = await repo.load();
      final prefs = await SharedPreferences.getInstance();
      final rawAfterFirst = prefs.getString(key);

      final second = await repo.load();
      final rawAfterSecond = prefs.getString(key);

      expect(second.map((m) => m.id), first.map((m) => m.id));
      expect(rawAfterSecond, rawAfterFirst);
    });

    test(
      'hassas kayıt YOKKEN bozuk kayıt depodan silinmez (geri-yazma kapısı)',
      () async {
        // Elle bozuk (id alanı eksik) bir kayıt + geçerli, hassas olmayan
        // bir kayıt içeren ham JSON — _decodeMessage bozuk girdiyi
        // atlayacak, ama TEMİZLİK tetiklenmediği için ham anahtar
        // DEĞİŞMEMELİDİR (koşulsuz geri yazma YASAK, TASK 094 §C).
        const raw =
            '[{"role":"user","text":"kirli kayit","createdAt":"2026-07-20T10:00:00.000Z"},'
            '{"id":"u1","role":"user","text":"Teyemmüm nedir?","createdAt":"2026-07-20T10:00:00.000Z"}]';
        SharedPreferences.setMockInitialValues({key: raw});

        final loaded = await repo.load();
        expect(loaded.map((m) => m.id), ['u1']);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(key), raw);
      },
    );

    test('silinen ham hassas metin hiçbir çıktıya YAZILMAZ (yalnız sayı/'
        'davranış gözlemlenebilir)', () async {
      SharedPreferences.setMockInitialValues({});
      const sensitiveText = 'Ben kredi çektim, çok özel bir günahım var mı?';
      await repo.save([user('u1', sensitiveText), assistant('a1')]);

      await expectLater(
        () => repo.load(),
        prints(isNot(contains(sensitiveText))),
      );
    });

    test(
      'temizlik yalnız asistan geçmişi anahtarına dokunur — ilgisiz '
      'bismillah.* anahtarları TAM olarak korunur',
      () async {
        // Asistan geçmişi anahtarı DIŞINDA, temizlik geçişinin YANLIŞLIKLA
        // dokunmaması gereken birkaç ilgisiz kalıcılık anahtarı ekleniyor.
        const onboardingKey = 'bismillah.onboarding_completed';
        const quranProgressKey = 'bismillah.quran_daily_progress.2026-07-20';
        const localeKey = 'bismillah.locale';
        SharedPreferences.setMockInitialValues({
          onboardingKey: true,
          quranProgressKey: '{"pagesRead":3}',
          localeKey: 'tr',
        });
        await repo.save([
          user('u1', 'Teyemmüm nedir?'), // normal
          assistant('a1'),
          user('u2', 'Kan abdesti bozar mı?'), // worshipRule — hassas
          assistant('a2', minute: 2),
        ]);

        final prefsBeforeLoad = await SharedPreferences.getInstance();
        final keysBeforeLoad = prefsBeforeLoad.getKeys();

        final loaded = await repo.load();
        expect(loaded.map((m) => m.id), ['u1', 'a1']);

        final prefsAfterLoad = await SharedPreferences.getInstance();
        // Anahtar KÜMESİ, temizlik öncesi/sonrası AYNI kalmalıdır — yeni bir
        // yedek/karantina anahtarı eklenmemiş, ilgisiz bir anahtar da
        // silinmemiş olmalıdır.
        expect(prefsAfterLoad.getKeys(), keysBeforeLoad);
        // İlgisiz her anahtarın DEĞERİ de birebir korunmalıdır.
        expect(prefsAfterLoad.getBool(onboardingKey), isTrue);
        expect(
          prefsAfterLoad.getString(quranProgressKey),
          '{"pagesRead":3}',
        );
        expect(prefsAfterLoad.getString(localeKey), 'tr');
      },
    );

    test(
      'silinen hassas kayıtlar başka bir anahtar altına TAŞINMAZ — yedek/'
      'karantina anahtarı OLUŞTURULMAZ',
      () async {
        SharedPreferences.setMockInitialValues({});
        await repo.save([
          user('u1', 'Teyemmüm nedir?'), // normal
          assistant('a1'),
          user('u2', 'Kan abdesti bozar mı?'), // worshipRule — hassas
          assistant('a2', minute: 2),
        ]);

        final prefsBefore = await SharedPreferences.getInstance();
        final keysBefore = Set<String>.from(prefsBefore.getKeys());

        final loaded = await repo.load();
        // Temizliğin gerçekten tetiklendiğini doğrula (aksi hâlde bu test
        // hiçbir şey kanıtlamaz).
        expect(loaded.map((m) => m.id), ['u1', 'a1']);

        final prefsAfter = await SharedPreferences.getInstance();
        // Anahtar kümesi BİREBİR aynı kalmalı — silinen kayıtlar ayrı bir
        // yedek/karantina anahtarı altında SAKLANMAMIŞ, gerçekten silinmiş
        // olmalıdır.
        expect(Set<String>.from(prefsAfter.getKeys()), keysBefore);
      },
    );
  });

  group('§E — clear() başarısızlığı BAŞARI olarak raporlanmaz', () {
    Future<ProviderContainer> boot(AssistantHistoryRepository history) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          assistantHistoryRepositoryProvider.overrideWithValue(history),
        ],
      );
      addTearDown(container.dispose);
      await container.read(assistantConversationProvider.future);
      return container;
    }

    test('repo.clear() başarısız olursa controller.clear() FALSE döner ve '
        'state DOKUNULMAMIŞ kalır', () async {
      final container = await boot(const _FailingClearHistoryRepository());
      final ctrl = container.read(assistantConversationProvider.notifier);
      await ctrl.send('Teyemmüm nedir?');

      final beforeCount = container
          .read(assistantConversationProvider)
          .value!
          .messages
          .length;

      final result = await ctrl.clear();

      expect(result, isFalse);
      expect(
        container.read(assistantConversationProvider).value!.messages,
        hasLength(beforeCount),
      );
    });

    test(
      'repo.clear() başarılı olursa controller.clear() TRUE döner',
      () async {
        final container = await boot(
          const SharedPrefsAssistantHistoryRepository(),
        );
        final ctrl = container.read(assistantConversationProvider.notifier);
        await ctrl.send('Teyemmüm nedir?');

        final result = await ctrl.clear();

        expect(result, isTrue);
        expect(
          container.read(assistantConversationProvider).value!.messages,
          isEmpty,
        );
      },
    );
  });
}

/// `save`/`load` gerçek davranışı korur; yalnız `clear()` her zaman
/// [StorageFailure] döndürerek TASK 094 §E davranışını test eder.
final class _FailingClearHistoryRepository
    implements AssistantHistoryRepository {
  const _FailingClearHistoryRepository();

  static const _delegate = SharedPrefsAssistantHistoryRepository();

  @override
  Future<List<AssistantMessage>> load() => _delegate.load();

  @override
  ResultFuture<void> save(List<AssistantMessage> messages) =>
      _delegate.save(messages);

  @override
  ResultFuture<void> clear() async => const Result.failure(StorageFailure());
}

import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sohbet controller'ı: kalıcılık, gizlilik ve locale davranışı (TASK 059
/// §13/§17). Gerçek doğrulanmış içerik kullanılır; ağ/AI YOKTUR.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> boot() async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
      ],
    );
    addTearDown(container.dispose);
    await container.read(assistantConversationProvider.future);
    return container;
  }

  test('normal eğitim mesajı kalıcı saklanır', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);

    await ctrl.send('Teyemmüm nedir?');

    final state = container.read(assistantConversationProvider).value!;
    expect(state.messages, hasLength(2));
    expect(state.isResponding, isFalse);

    final history = await container
        .read(assistantHistoryRepositoryProvider)
        .load();
    expect(history, hasLength(2));
  });

  test('kişisel/hüküm sorgusu kalıcı SAKLANMAZ', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);

    await ctrl.send('Teyemmüm nedir?'); // normal → kalıcı
    await ctrl.send('Bu davranış caiz midir?'); // hüküm → kalıcı değil
    await ctrl.send('Ben kredi çektim, günah mı?'); // kişisel → kalıcı değil

    final state = container.read(assistantConversationProvider).value!;
    expect(state.messages, hasLength(6)); // oturum içinde hepsi görünür

    final history = await container
        .read(assistantHistoryRepositoryProvider)
        .load();
    // Yalnız normal çift kalıcıdır.
    expect(history, hasLength(2));
    expect(
      history.every((m) => !m.text.toLowerCase().contains('caiz')),
      isTrue,
    );
  });

  test('ibadet-kuralı sorgusu (worshipRule) kalıcı SAKLANMAZ (TASK 094 §A — '
      'TASK 086 F1 düzeltmesi)', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);

    await ctrl.send('Teyemmüm nedir?'); // normal → kalıcı
    await ctrl.send('Kan abdesti bozar mı?'); // worshipRule → kalıcı değil

    final state = container.read(assistantConversationProvider).value!;
    expect(state.messages, hasLength(4)); // oturum içinde hepsi görünür

    final history = await container
        .read(assistantHistoryRepositoryProvider)
        .load();
    // Yalnız normal çift kalıcıdır; worshipRule çifti geçmişe hiç
    // YAZILMAMIŞTIR (önceden geçmişe yazılıp load() tarafından
    // temizlenmesiyle KARIŞTIRILMAMALI — bu, §B/§C'nin ayrı bir testidir).
    expect(history, hasLength(2));
  });

  test(
    'normal (hassas olmayan) sorgular öncekiyle AYNI biçimde kalıcıdır',
    () async {
      final container = await boot();
      final ctrl = container.read(assistantConversationProvider.notifier);

      await ctrl.send('Teyemmüm nedir?'); // definition
      await ctrl.send('Abdest nasıl alınır?'); // howTo
      await ctrl.send('Namaz vakitleri'); // generalLearning

      final history = await container
          .read(assistantHistoryRepositoryProvider)
          .load();
      expect(history, hasLength(6));
    },
  );

  test('boş mesaj gönderilemez; loading sırasında kilit', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);

    await ctrl.send('   ');
    expect(
      container.read(assistantConversationProvider).value!.messages,
      isEmpty,
    );
  });

  test('clear geçmişi ve state\'i temizler', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);
    await ctrl.send('Teyemmüm nedir?');
    await ctrl.clear();

    expect(
      container.read(assistantConversationProvider).value!.messages,
      isEmpty,
    );
    expect(
      await container.read(assistantHistoryRepositoryProvider).load(),
      isEmpty,
    );
  });

  test('locale değişimi geçmişi bozmaz', () async {
    final container = await boot();
    final ctrl = container.read(assistantConversationProvider.notifier);
    await ctrl.send('Teyemmüm nedir?');

    // Dil değişse de sohbet state'i korunur (build locale'i izlemez).
    await container.read(appLocaleProvider.notifier).select(SupportedLocale.en);

    final state = container.read(assistantConversationProvider).value!;
    expect(state.messages, hasLength(2));
  });
}

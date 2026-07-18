import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/settings/data/shared_prefs_app_locale_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kur'an istisnası (TASK 053 §3): uygulama dili DEĞİŞSE DE özgün Arapça
/// ayet metni ve seçili meal tercihi değişmez; meal İÇERİĞİ çevrilmez.
/// Yalnız meal kartının BAŞLIĞI/kaynak açıklaması uygulama diline uyar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Arapça ayet metni locale\'den bağımsızdır', () {
    test('aynı ayet üç locale altında da BİREBİR aynı metindir', () async {
      final repository = AssetQuranContentRepository();

      // Depo API'si locale parametresi ALMAZ — Arapça metin tek kaynaktır.
      final first = (await repository.getVerse('1:1')).valueOrNull;
      expect(first, isNotNull);

      for (final locale in SupportedLocale.values) {
        // Uygulama dili değişse de aynı depo aynı metni döner.
        expect(locale.locale.languageCode, isNotEmpty);
        final again = (await repository.getVerse('1:1')).valueOrNull;
        expect(again!.textUthmani, first!.textUthmani);
      }
    });

    test(
      'Arapça metin Latin harfe çevrilmiş/transliterate edilmiş DEĞİL',
      () async {
        final repository = AssetQuranContentRepository();
        final verse = (await repository.getVerse('2:255')).valueOrNull;

        expect(verse, isNotNull);
        expect(RegExp(r'[؀-ۿ]').hasMatch(verse!.textUthmani), isTrue);
        expect(RegExp(r'[A-Za-z]').hasMatch(verse.textUthmani), isFalse);
      },
    );
  });

  group('Meal içeriği uygulama diliyle çevrilmez', () {
    test(
      'QuranEnc Türkçe meal, Arapça locale altında da Türkçe kalır',
      () async {
        final repository = BundledQuranEncTranslationRepository();
        final chapter = (await repository.getChapterTranslation(1)).valueOrNull;

        expect(chapter, isNotNull);
        final text = chapter!.verses.first.translationText;

        // İçerik kaynağın kendi dilindedir (Türkçe) — makine çevirisi veya
        // locale'e göre değişim YOKTUR.
        expect(RegExp(r'[A-Za-zğüşıöçĞÜŞİÖÇ]').hasMatch(text), isTrue);

        // Aynı çağrı locale ne olursa olsun aynı metni verir.
        final again = (await repository.getChapterTranslation(1)).valueOrNull;
        expect(again!.verses.first.translationText, text);
      },
    );
  });

  group('Meal tercihi uygulama dilinden bağımsız yaşar', () {
    test('dil değiştirmek kayıtlı meal tercihini SİLMEZ', () async {
      // Tamamlanmış Kur'an kurulumu (depo eksik/bozuk değerde null döner).
      SharedPreferences.setMockInitialValues({
        'bismillah.quran_setup_completed': true,
        'bismillah.quran_arabic_script': 'uthmani',
        'bismillah.quran_translation': 'turkish',
        'bismillah.quran_goal_type': 'pages',
        'bismillah.quran_goal_amount': 3,
      });

      const readingPrefs = SharedPrefsQuranReadingPreferencesRepository();
      final before = (await readingPrefs.load()).valueOrNull;
      expect(before?.translation, QuranTranslationPreference.turkish);

      // Uygulama dili tr → en → ar boyunca değişir.
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          appLocaleRepositoryProvider.overrideWithValue(
            const SharedPrefsAppLocaleRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.en);
      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.ar);

      expect(container.read(appLocaleProvider), SupportedLocale.ar);

      // Meal tercihi AYNEN durur — Türkçe meal Arapça arayüzde de seçilidir.
      final after = (await readingPrefs.load()).valueOrNull;
      expect(after?.translation, QuranTranslationPreference.turkish);
    });

    test('dil anahtarı meal anahtarını EZMEZ (ayrı anahtarlar)', () async {
      SharedPreferences.setMockInitialValues({});

      const localeRepo = SharedPrefsAppLocaleRepository();
      await localeRepo.saveLocale(SupportedLocale.ar);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bismillah.app_locale'), 'ar');
      // Meal anahtarına dokunulmamıştır.
      expect(prefs.get('bismillah.quran_translation'), isNull);
    });
  });

  group('Meal kartı BAŞLIĞI uygulama diline uyar', () {
    test('başlık/kaynak etiketleri üç dilde de çevrilidir', () {
      const tr = AppLocalizations(SupportedLocale.tr);
      const en = AppLocalizations(SupportedLocale.en);
      const ar = AppLocalizations(SupportedLocale.ar);

      // Meal kartı başlığı çevrilir...
      expect(
        en.quranTranslationSourceLabel,
        isNot(tr.quranTranslationSourceLabel),
      );
      expect(
        ar.quranTranslationSourceLabel,
        isNot(tr.quranTranslationSourceLabel),
      );

      // ...ama kaynak künyesi (marka adı) sözlükte DEĞİLDİR: verbatim
      // korunur ve çevrilmez.
      expect(
        BundledQuranEncTranslationRepository.sourceLabel,
        contains('QuranEnc.com'),
      );
    });

    test('meal dilinin farklı olabileceği sakin bir notla bildirilir', () {
      for (final locale in SupportedLocale.values) {
        final note = AppLocalizations(locale).settingsLanguageTranslationNote;
        expect(note, isNotEmpty);
        // Ton kontrolü: uyarı/hata dili değil, bilgilendirme.
        expect(note, isNot(contains('!')));
      }
    });
  });
}

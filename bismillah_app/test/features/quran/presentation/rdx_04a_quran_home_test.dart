import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_verse_page_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quran_search_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/islamic/quran_on_rehal_illustration.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RDX-04A — Kur'an ana ekranı premium çekirdek yerleşimi.
///
/// Kapsam SUNUMDUR. Sure kataloğu, arama motoru (TASK 048), okuma konumu
/// kalıcılığı (TASK 036), günlük hedef hesabı (TASK 047) ve okuyucu ekranı BU
/// GÖREVDE DEĞİŞMEDİ ve burada yeniden test edilmez — mevcut testleri yerinde
/// durur. Buradaki iddialar yalnız yerleşim, yüzey ve hiyerarşi hakkındadır.
///
/// Gerçek ağ/ses KULLANILMAZ ve golden framework EKLENMEZ.
void main() {
  const completedSetup = {
    'bismillah.quran_setup_completed': true,
    'bismillah.quran_arabic_script': 'uthmani',
    'bismillah.quran_translation': 'turkish',
    'bismillah.quran_goal_type': 'pages',
    'bismillah.quran_goal_amount': 3,
  };

  /// Kurulum + GERÇEK bir kayıtlı okuma konumu. "Kaldığın yer" bloğunun
  /// dolu durumu yalnız böyle üretilir — blok veri uydurmaz.
  final withSavedPosition = {
    ...completedSetup,
    'bismillah.quran_last_chapter_id': 2,
    'bismillah.quran_last_scroll_offset': 240.0,
    'bismillah.quran_last_read_at_utc': DateTime.utc(
      2026,
      8,
      7,
      9,
      30,
    ).toIso8601String(),
  };

  Future<void> pumpQuranScreen(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 3200),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz; cache'ler
    // runAsync ile ısıtılır ve depolar sıcak cache'iyle override edilir.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(repository.getChapters);

    final pageRepository = AssetQuranVersePageRepository();
    await tester.runAsync(() => pageRepository.pagesForChapter(1));

    final searchRepository = BundledQuranSearchRepository(
      contentRepository: repository,
      translationRepository: BundledQuranEncTranslationRepository(),
    );
    await tester.runAsync(() => searchRepository.search('1'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(repository),
          quranVersePageRepositoryProvider.overrideWithValue(pageRepository),
          quranSearchRepositoryProvider.overrideWithValue(searchRepository),
          appLocaleAtLaunchProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const QuranScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Ekrandaki HERHANGİ bir yüzeyin gradient taşıyıp taşımadığı. Üç kap türü
  /// de taranır çünkü `AppCard` `AnimatedContainer`, hero'lar `DecoratedBox`,
  /// diğer yüzeyler `Container` kullanır.
  bool anyGradientPainted(WidgetTester tester) {
    bool hasGradient(Decoration? decoration) =>
        decoration is BoxDecoration && decoration.gradient != null;

    return tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .any((w) => hasGradient(w.decoration)) ||
        tester
            .widgetList<Container>(find.byType(Container))
            .any((w) => hasGradient(w.decoration)) ||
        tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .any((w) => hasGradient(w.decoration));
  }

  group('kaldığın yer bloğu', () {
    testWidgets('kayıt varsa gerçek sureyi ve tek devam aksiyonunu gösterir', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);

      // Üst etiket + gerçek sure adı (Latin ve Arapça) + devam aksiyonu.
      expect(find.text('Kaldığın yer'), findsOneWidget);
      expect(find.text('Okumaya devam et'), findsOneWidget);

      // Sure adı hem blokta hem katalog satırında geçtiği için iki kez
      // bulunur — blok gerçek kaydı gösterir, uydurmaz.
      expect(find.text('Al-Baqara'), findsNWidgets(2));

      // Davet metni artık gösterilmez: blok gerçek bilgiye döndü.
      expect(find.text('Kur\'an ile yeniden buluş'), findsNothing);
    });

    testWidgets('kayıt yoksa yalnız davet gösterilir — sahte devam YOK', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      expect(find.text('Kur\'an ile yeniden buluş'), findsOneWidget);
      expect(find.text('Kaldığın yer'), findsNothing);
      // Gidilecek yeri olmayan bir "devam" düğmesi ÜRETİLMEZ.
      expect(find.text('Okumaya devam et'), findsNothing);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('rahle motifi yalnız DAVET durumunda yaşar', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      expect(find.byType(QuranOnRehalIllustration), findsOneWidget);

      // Kayıt varken blok gerçek içerik taşır ve dekorasyona ihtiyaç kalmaz.
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);
      expect(find.byType(QuranOnRehalIllustration), findsNothing);
    });

    testWidgets('altın YALNIZ küçük nokta olarak ve yalnız kayıt varken', (
      tester,
    ) async {
      final gold = AppTheme.light().extension<AppThemeExtension>()!.accentGold;

      int goldSurfaces(WidgetTester tester) => tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (w) => w.decoration is BoxDecoration
                ? (w.decoration as BoxDecoration).color == gold
                : false,
          )
          .length;

      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      // Davet durumunda "şu an" bilgisi yoktur — altın hiç yanmaz.
      expect(goldSurfaces(tester), 0);

      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);
      // Tek bir küçük nokta; buton, kenarlık veya kart zemini olarak DEĞİL.
      expect(goldSurfaces(tester), 1);
    });

    testWidgets('devam aksiyonu gerçekten etkindir', (tester) async {
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);

      // Bu harness'ta GoRouter yoktur, bu yüzden dokunuşun kendisi gezinmeyi
      // KANITLAYAMAZ — gerçek rota davranışı TASK 036 testlerinde durur.
      // Buradaki iddia daha dar ama dürüsttür: düğme devre dışı bir süs
      // değildir, bağlı bir eylemi vardır.
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('yüzey dili', () {
    testWidgets('ekranda HİÇBİR gradient boyanmaz', (tester) async {
      // RDX tasarım yönü gradient içermez; TASK 054 hero'su kaldırıldı.
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      expect(anyGradientPainted(tester), isFalse);

      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);
      expect(anyGradientPainted(tester), isFalse);
    });

    testWidgets('İlerlemem ve Öğren sekmelerinde de gradient yoktur', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      for (final tab in const ['İlerlemem', 'Öğren']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(anyGradientPainted(tester), isFalse, reason: tab);
      }
    });
  });

  group('sure kataloğu', () {
    testWidgets('bölüm başlığı sayıyı KATALOGDAN okur', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      expect(find.text('Sureler'), findsOneWidget);
      // Sabit "114" yazılmaz — değer listenin uzunluğundan gelir.
      expect(find.text('114 sure'), findsOneWidget);
    });

    testWidgets('satırlar ORTAK bir yüzey rengi paylaşır', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      final tokens = AppTheme.light().extension<IslamicVisualTokens>()!;
      for (final name in const ['Al-Faatiha', 'Al-Baqara', 'Aal-i-Imraan']) {
        final material = tester.widget<Material>(
          find
              .ancestor(of: find.text(name), matching: find.byType(Material))
              .first,
        );
        expect(material.color, tokens.sacredSurface, reason: name);
      }
    });

    testWidgets('yalnız ilk satır üst köşeleri yuvarlar', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      BorderRadius radiusOf(String name) =>
          tester
                  .widget<Material>(
                    find
                        .ancestor(
                          of: find.text(name),
                          matching: find.byType(Material),
                        )
                        .first,
                  )
                  .borderRadius!
              as BorderRadius;

      // İlk satır: üst köşeler yuvarlak, alt köşeler düz (yüzey devam eder).
      final first = radiusOf('Al-Faatiha');
      expect(first.topLeft.x, greaterThan(0));
      expect(first.bottomLeft.x, 0);

      // Ortadaki satır hiçbir köşeyi yuvarlamaz — tek yüzey izlenimi böyle
      // kurulur.
      final middle = radiusOf('Al-Baqara');
      expect(middle.topLeft.x, 0);
      expect(middle.bottomLeft.x, 0);
    });

    testWidgets('liste SANALLAŞTIRILMIŞ kalır — 114 satır birden kurulmaz', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      // Gruplanmış yüzey görünümü, satırları tek bir `Column`a toplayarak
      // DEĞİL satır başına çözülür. Son sure ekran dışındayken kurulmamış
      // olmalıdır; aksi hâlde `ListView.builder` tembelliğini kaybetmiştir.
      expect(find.text('Al-Faatiha'), findsOneWidget);
      expect(find.text('An-Naas'), findsNothing);
    });

    testWidgets('satır dokunma hedefi ve içeriği korunur', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);

      final rowSize = tester.getSize(
        find
            .ancestor(
              of: find.text('Al-Faatiha'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(rowSize.height, greaterThanOrEqualTo(48));

      // Numara, ayet sayısı, nüzul yeri ve Arapça ad yerinde durur.
      expect(find.text('1'), findsWidgets);
      expect(find.text('7 ayet · Mekkî'), findsOneWidget);
      expect(find.text('الفاتحة'), findsOneWidget);
    });

    testWidgets('Arapça ad uygulama dili LTR olsa da RTL çizilir', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester, locale: SupportedLocale.en);

      expect(
        Directionality.of(tester.element(find.text('الفاتحة'))),
        TextDirection.rtl,
      );
    });
  });

  group('İlerlemem', () {
    testWidgets('tüm metrikler korunur — yalnız yüzeyler gruplandı', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      await tester.tap(find.text('İlerlemem'));
      await tester.pumpAndSettle();

      // Hedef, bugünkü aktivite, son 7 gün ve seri: hiçbiri kaybolmadı.
      expect(find.text('Bugünkü hedefin'), findsWidgets);
      expect(find.text('3 sayfa'), findsOneWidget);
      expect(find.text('Bugünkü aktivite'), findsOneWidget);
      expect(find.text('Son 7 gün'), findsOneWidget);
      expect(find.text("Kur'an hedefi serisi"), findsOneWidget);
      expect(find.text('Hedefi düzenle'), findsOneWidget);
    });

    testWidgets('beş ayrı kart yerine daha az yüzey kullanılır', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      await tester.tap(find.text('İlerlemem'));
      await tester.pumpAndSettle();

      // RDX-04A öncesi bu sekme üst üste BEŞ yükseltilmiş karttı. Artık
      // hedef + aktivite (7 gün ve seri dâhil) iki yüzeyde yaşıyor; devam
      // satırı yalnız kayıt varken eklenir ve bu senaryoda kayıt yoktur.
      expect(find.byType(AppCard), findsNWidgets(2));
    });
  });

  group('Öğren', () {
    testWidgets('sakin boş durum gösterir — sahte ders içeriği YOK', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      await tester.tap(find.text('Öğren'));
      await tester.pumpAndSettle();

      expect(find.byType(GentleEmptyState), findsOneWidget);
      // Gidilecek yer olmadığı için eylem düğmesi de yoktur.
      expect(find.byType(AppButton), findsNothing);
    });
  });

  group('yerelleştirme ve RTL', () {
    testWidgets('yeni anahtarlar TR/EN/AR üçünde de tanımlı ve ayrıdır', (
      tester,
    ) async {
      final eyebrows = <String>{};
      final counts = <String>{};

      for (final locale in SupportedLocale.values) {
        SharedPreferences.setMockInitialValues(withSavedPosition);
        await pumpQuranScreen(tester, locale: locale);

        final l10n = AppLocalizations.of(
          tester.element(find.byType(QuranScreen)),
        );
        // Ham anahtar sızmaz ve üç dil birbirinin kopyası değildir.
        expect(l10n.quranHomeResumeEyebrow, isNot('quranHomeResumeEyebrow'));
        expect(l10n.quranSurahCount(114), contains('114'));
        eyebrows.add(l10n.quranHomeResumeEyebrow);
        counts.add(l10n.quranSurahCount(114));
      }

      expect(eyebrows, hasLength(SupportedLocale.values.length));
      expect(counts, hasLength(SupportedLocale.values.length));
    });

    testWidgets('Arapça değerler Arap harfleri taşır', (tester) async {
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester, locale: SupportedLocale.ar);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(QuranScreen)),
      );
      final arabic = RegExp(r'[؀-ۿ]');
      expect(arabic.hasMatch(l10n.quranHomeResumeEyebrow), isTrue);
      expect(arabic.hasMatch(l10n.quranSurahCount(114)), isTrue);
    });

    testWidgets('Arapça ekran RTL çözer, Türkçe LTR kalır', (tester) async {
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester, locale: SupportedLocale.ar);
      expect(
        Directionality.of(tester.element(find.byType(QuranScreen))),
        TextDirection.rtl,
      );

      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);
      expect(
        Directionality.of(tester.element(find.byType(QuranScreen))),
        TextDirection.ltr,
      );
    });

    testWidgets('chevron yönü RTL\'de aynalanır', (tester) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester);
      // `Icons.chevron_right` kendiliğinden aynalanmaz; yön AÇIKÇA çözülür.
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
      expect(find.byIcon(Icons.chevron_left), findsNothing);

      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(tester, locale: SupportedLocale.ar);
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('erişilebilirlik', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320dp + 1.5x metinde taşma olmaz', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues(withSavedPosition);
        await pumpQuranScreen(
          tester,
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('davet durumu da dar ekranda ve büyük metinde taşmaz', (
      tester,
    ) async {
      // Motif sabit genişlik ayırır; metin sütunu o payı bıraktığı için
      // büyük yazı ölçeğinde motifle çakışmaz.
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(
        tester,
        size: const Size(320 * 3, 720 * 3),
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(QuranOnRehalIllustration), findsOneWidget);
    });

    testWidgets('sekmeler ve arama 1.5x ölçekte kullanılabilir kalır', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(completedSetup);
      await pumpQuranScreen(
        tester,
        size: const Size(320 * 3, 720 * 3),
        textScale: 1.5,
      );

      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.text('İlerlemem'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Bugünkü aktivite'), findsOneWidget);
    });
  });

  group('ücretsiz çekirdek', () {
    testWidgets('kilit, rozet, paywall veya yükseltme çağrısı YOKTUR', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(withSavedPosition);
      await pumpQuranScreen(tester);

      for (final icon in const [
        Icons.lock,
        Icons.lock_outline,
        Icons.workspace_premium,
        Icons.star,
      ]) {
        expect(find.byIcon(icon), findsNothing, reason: '$icon');
      }
      for (final word in const ['Premium', 'Bismillah+', 'Destekçi']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }
    });
  });
}

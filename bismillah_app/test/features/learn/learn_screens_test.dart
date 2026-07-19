import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/domain/services/external_link_service.dart';
import 'package:bismillah_app/features/learn/presentation/learn_article_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_category_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_screen.dart';
import 'package:bismillah_app/features/learn/presentation/widgets/learn_source_card.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Learn ekranları (TASK 056 §14 UI).
///
/// Gerçek ağ, gerçek tarayıcı ve Firebase KULLANILMAZ.
void main() {
  /// Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz; depo
  /// `runAsync` ile ısıtılır ve sıcak hâliyle override edilir (mevcut
  /// Kur'an testlerindeki desen).
  Future<AssetLearningKnowledgeRepository> warmRepository(
    WidgetTester tester,
    String locale,
  ) async {
    final repository = AssetLearningKnowledgeRepository();
    await tester.runAsync(() async {
      await repository.getCategories(locale);
      await repository.getBeginnerPath(locale);
      await repository.getFeatured(locale);
      await repository.getArticlesByCategory(locale, 'cat-purity');
      await repository.getArticleBySlug(locale, 'abdesti-bozan-durumlar');
      await repository.search(locale, 'abdest');
    });
    return repository;
  }

  Future<GoRouter> pumpLearn(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    String initialLocation = AppRoutes.learn,
    Size size = const Size(1080, 2600),
    double textScale = 1.0,
    ExternalLinkService? linkService,
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = await warmRepository(tester, locale.name);

    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.learn,
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.learnCategory}/:slug',
          builder: (context, state) =>
              LearnCategoryScreen(slug: state.pathParameters['slug'] ?? ''),
        ),
        GoRoute(
          path: '${AppRoutes.learnArticle}/:slug',
          builder: (context, state) =>
              LearnArticleScreen(slug: state.pathParameters['slug'] ?? ''),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningKnowledgeRepositoryProvider.overrideWithValue(repository),
          appLocaleAtLaunchProvider.overrideWithValue(locale),
          if (linkService != null)
            externalLinkServiceProvider.overrideWithValue(linkService),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  group('Learn ana ekranı', () {
    testWidgets('artık yalnız "hazırlanıyor" göstermiyor — gerçek içerik var', (
      tester,
    ) async {
      await pumpLearn(tester);

      // Eski placeholder gövdesi KALKTI.
      expect(find.text('Bu bölüm hazırlanıyor.'), findsNothing);
      // Gerçek, açılabilir içerik başlıkları görünür.
      expect(find.text('Yeni başlayanlar yolu'), findsOneWidget);
      expect(find.text('İmanın şartları'), findsWidgets);
    });

    testWidgets('hero, arama ve tüm kategoriler render eder', (tester) async {
      await pumpLearn(tester);

      expect(find.text('Bilgini sakince derinleştir'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tüm başlıklar'), findsOneWidget);
    });

    testWidgets('boş kategori DÜRÜSTÇE "hazırlanıyor" etiketi taşır', (
      tester,
    ) async {
      await pumpLearn(tester);

      // İçeriği olan kategori sayaç, olmayan "Hazırlanıyor" gösterir.
      expect(find.text('Hazırlanıyor'), findsWidgets);
      expect(find.textContaining('konu'), findsWidgets);
    });

    testWidgets('cami ufku dekoratiftir — semantics dışı', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLearn(tester);

      expect(find.byType(MosqueHorizonIllustration), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MosqueHorizonIllustration),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('arama sonuç döndürür ve temizlenebilir', (tester) async {
      await pumpLearn(tester);

      await tester.enterText(find.byType(TextField), 'abdest');
      await tester.pumpAndSettle();

      // Arama aktifken bölümler yerini sonuçlara bırakır.
      expect(find.text('Yeni başlayanlar yolu'), findsNothing);
      expect(find.text('Abdesti bozan durumlar'), findsWidgets);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Yeni başlayanlar yolu'), findsOneWidget);
    });

    testWidgets('eşleşmeyen arama sakin boş durum gösterir', (tester) async {
      await pumpLearn(tester);

      await tester.enterText(find.byType(TextField), 'zzzqqq');
      await tester.pumpAndSettle();

      expect(
        find.text('Aramanla eşleşen bir konu bulunamadı.'),
        findsOneWidget,
      );
    });
  });

  group('Navigasyon', () {
    testWidgets('kategoriye ve oradan içeriğe gidilebilir', (tester) async {
      await pumpLearn(tester);

      await tester.tap(find.text('Temizlik, Abdest ve Gusül'));
      await tester.pumpAndSettle();

      // Kategori ekranı: açıklama + konu sayısı + zorluk grupları.
      expect(find.text('Temel'), findsWidgets);
      expect(find.text('Abdesti bozan durumlar'), findsWidgets);

      await tester.tap(find.text('Abdesti bozan durumlar').first);
      await tester.pumpAndSettle();

      // İçerik detayı: gerçek gövde render edilir.
      expect(find.textContaining('Ağız dolusu kusmak'), findsOneWidget);
    });

    testWidgets('boş kategori sakin boş durum gösterir', (tester) async {
      await pumpLearn(
        tester,
        initialLocation:
            '${AppRoutes.learnCategory}/islam-tarihi-ve-medeniyeti',
      );

      expect(find.byType(GentleEmptyState), findsOneWidget);
      expect(find.text('Bu bölüm hazırlanıyor'), findsOneWidget);
    });

    testWidgets('bilinmeyen slug crash üretmez', (tester) async {
      await pumpLearn(
        tester,
        initialLocation: '${AppRoutes.learnArticle}/boyle-bir-sey-yok',
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(GentleEmptyState), findsOneWidget);
    });
  });

  group('İçerik detayı', () {
    Future<void> openArticle(
      WidgetTester tester, {
      // Kaynak gövdesi DOĞRULANMIŞ makale (TASK 056A yayın kapısı).
      String slug = 'abdesti-bozan-durumlar',
      SupportedLocale locale = SupportedLocale.tr,
      ExternalLinkService? linkService,
    }) => pumpLearn(
      tester,
      locale: locale,
      initialLocation: '${AppRoutes.learnArticle}/$slug',
      linkService: linkService,
    ).then((_) {});

    testWidgets('içerik türü, süre ve son kontrol tarihi görünür', (
      tester,
    ) async {
      await openArticle(tester);

      // İçerik türü genel özet ile fetvayı ayırt ettirir.
      expect(find.text('İlmihal bilgisi'), findsOneWidget);
      expect(find.text('4 dk okuma'), findsOneWidget);
      expect(find.textContaining('Son kaynak kontrolü'), findsWidgets);
    });

    testWidgets('kaynak kartı kurum ve orijinal dili gösterir', (tester) async {
      await openArticle(tester);

      expect(find.byType(LearnSourceCard), findsWidgets);
      expect(find.text('İslam İlmihali'), findsOneWidget);
      expect(find.text('Kaynağın özgün dili: Türkçe'), findsWidgets);
      expect(find.text('Resmî sayfayı aç'), findsWidgets);
    });

    testWidgets('görüş farkı GİZLENMEZ', (tester) async {
      await openArticle(tester, slug: 'abdesti-bozan-durumlar');

      expect(find.text('Görüş farkı'), findsOneWidget);
      expect(find.textContaining('Şâfiî'), findsWidgets);
    });

    testWidgets('hassas içerik yetkili mercie yönlendirir', (tester) async {
      await openArticle(tester, slug: 'teyemmum-nedir');

      expect(find.text('Kişisel durumun için danış'), findsOneWidget);
    });

    testWidgets('asistan butonu DEVRE DIŞI ve "yakında" olarak gösterilir', (
      tester,
    ) async {
      await openArticle(tester);

      expect(find.text('Asistana sor — yakında'), findsOneWidget);
    });

    testWidgets('link açılamazsa CRASH olmaz, sakin mesaj gösterilir', (
      tester,
    ) async {
      await openArticle(tester, linkService: const _AlwaysFailsLinkService());

      await tester.tap(find.text('Resmî sayfayı aç').first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Bağlantı şu anda açılamadı.'),
        findsOneWidget,
      );
    });

    testWidgets('kaydet ve tamamlandı işaretlenip geri alınabilir', (
      tester,
    ) async {
      await openArticle(tester);

      expect(find.text('Kaydet'), findsOneWidget);
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
      expect(find.text('Kaydedildi'), findsOneWidget);

      // Geri alınabilir.
      await tester.tap(find.text('Kaydedildi'));
      await tester.pumpAndSettle();
      expect(find.text('Kaydet'), findsOneWidget);

      await tester.tap(find.text('Tamamlandı olarak işaretle'));
      await tester.pumpAndSettle();
      expect(find.text('Tamamlandı'), findsOneWidget);
    });
  });

  group('Yerelleştirme ve RTL', () {
    testWidgets('İngilizce locale İngilizce içerik gösterir', (tester) async {
      await pumpLearn(tester, locale: SupportedLocale.en);

      expect(find.text('Path for beginners'), findsOneWidget);
      expect(find.text('The articles of faith'), findsWidgets);
      expect(find.text('İmanın şartları'), findsNothing);
    });

    testWidgets('Arapça locale Arapça içerik ve RTL verir', (tester) async {
      await pumpLearn(tester, locale: SupportedLocale.ar);

      expect(find.text('مسار المبتدئين'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('مسار المبتدئين'))),
        TextDirection.rtl,
      );
    });

    testWidgets('Arapça içerik detayı çeviri uyarısı taşır', (tester) async {
      await pumpLearn(
        tester,
        locale: SupportedLocale.ar,
        initialLocation: '${AppRoutes.learnArticle}/ma-hu-al-tayammum',
      );

      // Resmî olmayan açıklayıcı çeviri uyarısı GÖRÜNÜR olmalıdır.
      expect(find.textContaining('ترجمة تفسيرية غير رسمية'), findsWidgets);
    });

    testWidgets('Türkçe içerik çeviri uyarısı TAŞIMAZ (özgün özet)', (
      tester,
    ) async {
      await pumpLearn(
        tester,
        initialLocation: '${AppRoutes.learnArticle}/abdest-nasil-alinir',
      );

      expect(find.textContaining('resmî olmayan açıklayıcı'), findsNothing);
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: Learn ana ekranı 320px + 1.5 taşmaz', (
        tester,
      ) async {
        await pumpLearn(
          tester,
          locale: locale,
          size: const Size(320 * 3, 800 * 3),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('${locale.name}: içerik detayı 320px + 1.5 taşmaz', (
        tester,
      ) async {
        await pumpLearn(
          tester,
          locale: locale,
          initialLocation:
              '${AppRoutes.learnArticle}/'
              '${locale == SupportedLocale.tr
                  ? 'abdest-nasil-alinir'
                  : locale == SupportedLocale.en
                  ? 'how-to-perform-wudu'
                  : 'kayfa-yutawadda'}',
          size: const Size(320 * 3, 800 * 3),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}

/// Açma denemesi her zaman başarısız olan servis — gerçek tarayıcı AÇILMAZ.
final class _AlwaysFailsLinkService implements ExternalLinkService {
  const _AlwaysFailsLinkService();

  @override
  Future<bool> openOfficialSource(String url) async => false;
}

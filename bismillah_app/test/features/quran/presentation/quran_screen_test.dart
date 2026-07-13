import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 033/034B Kur'an ekranı: kurulum kapısı, iç sekmeler, katalog
/// listesi ve lokal arama. Ekran GoRouter olmadan bağımsız pump'lanır.
void main() {
  const completedSetup = {
    'bismillah.quran_setup_completed': true,
    'bismillah.quran_arabic_script': 'uthmani',
    'bismillah.quran_translation': 'turkish',
    'bismillah.quran_goal_type': 'pages',
    'bismillah.quran_goal_amount': 3,
  };

  Future<void> pumpQuranScreen(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Asset okuma gerçek I/O'dur — FakeAsync altında tamamlanamaz;
    // cache runAsync ile ısıtılır, depo sıcak cache'iyle override edilir.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(() => repository.getChapters());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const QuranScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('kurulum tamamlanmamışsa üç adımlı kurulum görünür',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpQuranScreen(tester);

    expect(find.text('Arapça yazı biçimini seç'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Uthmani'), findsOneWidget);
    expect(find.text('IndoPak'), findsOneWidget);
    // Ana ekran sekmeleri görünmez.
    expect(find.text('İlerlemem'), findsNothing);
  });

  testWidgets('kayıtlı kurulumla sekmeler ve 114 surelik katalog görünür',
      (tester) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    expect(find.text('Oku'), findsOneWidget);
    expect(find.text('Öğren'), findsOneWidget);
    expect(find.text('İlerlemem'), findsOneWidget);
    // Katalog ilk suredan başlar; enum .name ekranda görünmez.
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('7 ayet · Mekkî'), findsOneWidget);
    expect(find.text('meccan'), findsNothing);
    expect(find.text('pages'), findsNothing);
  });

  testWidgets('arama: numara, Latin ad ve Arapça ad ile çalışır',
      (tester) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    // Numara ile: 114 → An-Naas. (Odaklı TextField imleci sürekli frame
    // ürettiği için pumpAndSettle yerine tek pump kullanılır.)
    await tester.enterText(find.byType(TextField), '114');
    await tester.pump();
    expect(find.text('An-Naas'), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsNothing);

    // Latin ad ile (büyük/küçük harf duyarsız).
    await tester.enterText(find.byType(TextField), 'baqara');
    await tester.pump();
    expect(find.text('Al-Baqara'), findsOneWidget);

    // Arapça ad ile.
    await tester.enterText(find.byType(TextField), 'الفاتحة');
    await tester.pump();
    expect(find.text('Al-Faatiha'), findsOneWidget);

    // Sonuç yok durumu sakin metinle gösterilir.
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();
    expect(find.text('Aramanla eşleşen sure bulunamadı.'), findsOneWidget);
  });

  testWidgets('İlerlemem doğru hedef türü ve miktarını gösterir',
      (tester) async {
    SharedPreferences.setMockInitialValues(completedSetup);
    await pumpQuranScreen(tester);

    await tester.tap(find.text('İlerlemem'));
    await tester.pumpAndSettle();

    expect(find.text('3 sayfa'), findsOneWidget);
    expect(find.text('0 / 3 sayfa'), findsOneWidget);
    expect(find.text('Hedefi düzenle'), findsOneWidget);
  });
}

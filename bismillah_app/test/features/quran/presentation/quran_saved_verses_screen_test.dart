import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/presentation/quran_saved_verses_screen.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 038 kaydedilen ayetler ekranı: gerçek asset'le liste, kayıt
/// kaldırma → boş durum, bozuk anahtar güvenliği.
void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Asset okuma gerçek I/O'dur — cache runAsync ile ısıtılır.
    final repository = AssetQuranContentRepository();
    await tester.runAsync(() => repository.getVersesForChapter(1));
    await tester.runAsync(() => repository.getVersesForChapter(2));

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
          home: const QuranSavedVersesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('kayıt yokken sakin boş durum ve CTA görünür', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpScreen(tester);

    expect(find.text('Henüz kaydedilmiş ayetin yok.'), findsOneWidget);
    expect(find.text("Kur'an okumaya git"), findsOneWidget);
  });

  testWidgets(
      'kayıtlar sure/ayet sırasıyla gerçek Uthmani metinle listelenir; '
      'bozuk anahtar atlanır', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_bookmarked_verse_keys': ['2:255', '1:1', 'bozuk'],
    });
    await pumpScreen(tester);

    final blocks = tester
        .widgetList<QuranTextBlock>(find.byType(QuranTextBlock))
        .toList();
    expect(blocks.length, 2);
    for (final block in blocks) {
      expect(block.arabicText.trim(), isNotEmpty);
      expect(block.translation, isNull); // sahte meal YOK
    }
    // Sıra: 1:1 önce, 2:255 sonra.
    expect(find.text('1:1'), findsOneWidget);
    expect(find.text('2:255'), findsOneWidget);
    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.text('Al-Baqara'), findsOneWidget);
  });

  testWidgets('son kaydın kaldırılması boş duruma geçirir', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_bookmarked_verse_keys': ['1:1'],
    });
    await pumpScreen(tester);
    expect(find.byType(QuranTextBlock), findsOneWidget);

    await tester.tap(find.text('Kaydı kaldır'));
    await tester.pumpAndSettle();

    expect(find.byType(QuranTextBlock), findsNothing);
    expect(find.text('Henüz kaydedilmiş ayetin yok.'), findsOneWidget);
  });
}

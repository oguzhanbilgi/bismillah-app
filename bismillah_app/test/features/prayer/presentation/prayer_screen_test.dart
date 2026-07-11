import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/widget_test_utils.dart';

/// TASK 016 ekran testleri: gerçek in-memory Drift DB üzerinde widget akışı.
///
/// `NativeDatabase.memory()` aynı isolate'te senkron çalışır; future'ları
/// microtask/sıfır-timer tabanlıdır ve `pumpAndSettle` ile ilerler
/// (Windows'ta `runAsync` içinde pump deadlock yapabildiği için bilinçli
/// olarak fake-async düzeninde kalınır).
void main() {
  final fixedLocalNow = DateTime(2026, 7, 11, 9, 30);

  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpPrayerScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const PrayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders five prayer rows with calm empty state', (tester) async {
    await pumpPrayerScreen(tester);

    expect(find.byType(PrayerEntryTile), findsNWidgets(5));
    expect(find.text('Sabah'), findsOneWidget);
    expect(find.text('Öğle'), findsOneWidget);
    expect(find.text('İkindi'), findsOneWidget);
    expect(find.text('Akşam'), findsOneWidget);
    expect(find.text('Yatsı'), findsOneWidget);
    expect(find.text('İşaretle'), findsNWidgets(5));
    expect(find.text('2026-07-11'), findsOneWidget); // gün rozeti
    // Boş durum sakindir: "Tamamlandı" yok ama hata/uyarı da yok.
    expect(find.text('Tamamlandı'), findsNothing);

    // Alt not viewport dışında (lazy ListView) — görünür olana dek kaydır.
    await tester.scrollUntilVisible(
      find.text('Kayıtlar cihazında güvenle saklanır.'),
      120,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('Kayıtlar cihazında güvenle saklanır.'),
      findsOneWidget,
    );

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('tapping a row marks it completed and allows undo',
      (tester) async {
    await pumpPrayerScreen(tester);

    await tester.tap(find.text('İşaretle').first);
    await tester.pumpAndSettle();

    expect(find.text('Tamamlandı'), findsOneWidget);
    expect(find.text('Geri al'), findsOneWidget);
    expect(find.text('İşaretle'), findsNWidgets(4));

    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();

    expect(find.text('Tamamlandı'), findsNothing);
    expect(find.text('İşaretle'), findsNWidgets(5));

    await unmountAndFlushDriftTimers(tester);
  });
}

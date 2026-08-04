import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// TASK 021: Prayer ekranı vakit gösterimi + konum-bağımsız işaretleme.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 15, 9);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester, {required bool granted}) async {
    // Uzun viewport: 5 vakit satırı + vakit kartı aynı anda kurulur
    // (lazy ListView aksi hâlde alt satırları build etmez).
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          granted ? grantedLocationOverride() : fakeLocationOverride(),
          ...fakeReminderOverrides(),
          ...testSessionOverrides(),
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

  testWidgets('shows calculated times (method label, Güneş, HH:mm) when granted',
      (tester) async {
    await pump(tester, granted: true);

    // TASK 096: yöntem artık seçilebilir olduğundan başlık nötrdür ve
    // yöntemin ADI ayrıca gösterilir. Assertion ZAYIFLATILMADI — tam tersi,
    // artık hem etiketi hem gerçekten kullanılan yöntemin adını doğrular.
    // Etiketi "Türkiye" olarak dondurmak, seçim eklendikten sonra yanlış
    // bir iddiayı test etmek olurdu.
    expect(find.text('Hesaplama yöntemi'), findsWidgets);
    expect(find.text('Türkiye'), findsWidgets);
    expect(find.text('Güneş'), findsOneWidget);
    // "Konumu kullan" daveti GÖRÜNMEZ (izin verilmiş).
    expect(find.text('Konumu kullan'), findsNothing);
    // En az bir HH:mm biçimli vakit render edilir (timezone-bağımsız desen).
    final hhmm = RegExp(r'^\d{2}:\d{2}$');
    final times = find.byWidgetPredicate(
      (w) => w is Text && w.data != null && hhmm.hasMatch(w.data!),
    );
    expect(times, findsWidgets);

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('marking still works when location is denied', (tester) async {
    await pump(tester, granted: false);

    // Konum daveti gösterilir ama namaz kaydı bağımsız çalışır.
    expect(find.text('Konumu kullan'), findsOneWidget);
    expect(find.text('İşaretle'), findsNWidgets(5));

    await tester.tap(find.text('İşaretle').first);
    await tester.pumpAndSettle();

    expect(find.text('Tamamlandı'), findsOneWidget);
    expect(find.text('Geri al'), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });
}

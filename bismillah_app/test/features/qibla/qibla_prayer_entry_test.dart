import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/router/route_metadata.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_prayer_times.dart';
import '../../helpers/test_reminders.dart';
import '../../helpers/test_session.dart';
import '../../helpers/widget_test_utils.dart';

/// TASK 095 — Namaz ekranındaki Kıble girişi.
///
/// Namaz ekranı YENİDEN TASARLANMAZ: mevcut kart dilinde tek bir giriş
/// eklenir, ücretsizdir ve ayrı bir ekrana götürür.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 15, 9);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester, {String locale = 'tr'}) async {
    tester.view.physicalSize = const Size(1080, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          fakeLocationOverride(),
          ...fakeReminderOverrides(),
          ...testSessionOverrides(),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(locale),
          supportedLocales: [Locale(locale)],
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

  testWidgets('Namaz ekranında Kıble girişi görünür ve dokunulabilir', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Kıble yönü'), findsOneWidget);
    expect(
      find.textContaining('Kâbe yönüne sakin bir bakış'),
      findsOneWidget,
    );

    // Giriş bir kart yüzeyidir ve dokunma eylemi TANIMLIDIR.
    final card = tester.widget<AppCard>(
      find
          .ancestor(of: find.text('Kıble yönü'), matching: find.byType(AppCard))
          .first,
    );
    expect(card.onTap, isNotNull);

    // Ücretsiz çekirdek: kilit/rozet/yükseltme çağrısı YOKTUR.
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('Arapça yerelde de giriş görünür', (tester) async {
    await pump(tester, locale: 'ar');

    expect(find.text('اتجاه القبلة'), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });

  test('Kıble route Prayer dalı altındadır ve asistan FAB gösterilmez', () {
    expect(AppRoutes.qibla, '/prayer/qibla');
    expect(AppRoutes.qibla.startsWith('${AppRoutes.prayer}/'), isTrue);

    final metadata = RouteMetadataRegistry.of(AppRoutes.qibla);
    expect(metadata.showsAssistantFab, isFalse);
    // Alt navigasyon açık kalır — ekran akıştan koparılmaz.
    expect(metadata.hidesChrome, isFalse);
  });
}

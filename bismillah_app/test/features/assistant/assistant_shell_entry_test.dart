import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:bismillah_app/app/shell/assistant_fab.dart';
import 'package:bismillah_app/app/shell/bottom_nav_bar.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_prayer_times.dart';
import '../../helpers/widget_test_utils.dart';

/// Assistant shell giriş noktası (TASK 060 §4/§16). Beş sabit sekme +
/// SAKİN tonal FAB; altıncı sekme YOKTUR. Gerçek ağ/Firebase/audio kanalı
/// çağrılmaz (fake override).
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryAppDatabaseOverride(), fakeLocationOverride()],
        child: const BismillahApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Today üzerinde sakin tonal FAB görünür (tek floating action)', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(AssistantFab), findsOneWidget);
    // Tek bir floating action — altıncı sekme değil, ikinci FAB yok.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);

    // Baskın primary değil, sakin: düşük elevation + tooltip'li.
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.elevation, 1);
    expect(fab.tooltip, isNotNull);

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('FAB Assistant\'ı açar; chrome gizlenir; geri dönüşte korunur', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byType(AssistantFab));
    await tester.pumpAndSettle();

    // Assistant açık: bottom nav ve FAB gizli (aynı anda iki floating yok).
    expect(find.byType(AssistantScreen), findsOneWidget);
    expect(find.byType(BottomNavBar), findsNothing);
    expect(find.byType(AssistantFab), findsNothing);

    // Geri: shell ve sekme durumu korunur.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byType(AssistantFab), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });
}

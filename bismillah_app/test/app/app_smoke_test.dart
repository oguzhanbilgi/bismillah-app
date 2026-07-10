import 'dart:async';

import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/bottom_nav_bar.dart';
import 'package:bismillah_app/features/premium/presentation/premium_placeholder_screen.dart';
import 'package:bismillah_app/features/today/presentation/today_placeholder_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('app builds and resolves /today with 5-tab shell', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BismillahApp()));
    await tester.pumpAndSettle();

    expect(find.byType(TodayPlaceholderScreen), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
  });

  testWidgets('router resolves /premium as full-screen modal', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final GoRouter router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BismillahApp(),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.push(AppRoutes.premium));
    await tester.pumpAndSettle();

    expect(find.byType(PremiumPlaceholderScreen), findsOneWidget);
    // Full-screen modal: chrome (bottom nav) görünmez.
    expect(find.byType(BottomNavBar), findsNothing);
  });

  testWidgets('unknown route falls back to /today', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final GoRouter router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BismillahApp(),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/does-not-exist');
    await tester.pumpAndSettle();

    expect(find.byType(TodayPlaceholderScreen), findsOneWidget);
  });
}

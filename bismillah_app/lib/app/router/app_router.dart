import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_shell.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_placeholder_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_placeholder_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_placeholder_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/premium/presentation/premium_placeholder_screen.dart';
import 'package:bismillah_app/features/premium/presentation/subscription_settings_placeholder_screen.dart';
import 'package:bismillah_app/features/profile/presentation/profile_placeholder_screen.dart';
import 'package:bismillah_app/features/quran/presentation/quran_placeholder_screen.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouter kurulumu (05_INFORMATION_ARCHITECTURE §6; 06_FLUTTER_ARCH §12).
///
/// Kurallar:
/// - 5 sekme `StatefulShellRoute.indexedStack` ile (her branch kendi yığını).
/// - Asistan sekme DEĞİL — kök navigator'da katman route'u.
/// - `/premium` full-screen modal; yalnız kontrollü push ile açılır,
///   hiçbir redirect paywall'a yönlendiremez.
/// - Bilinmeyen route `/today`'e düşer (kullanıcı hata ekranı görmez).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.today,
    onException: (context, state, router) => router.go(AppRoutes.today),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                name: AppRoutes.todayName,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.prayer,
                name: AppRoutes.prayerName,
                builder: (context, state) => const PrayerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quran,
                name: AppRoutes.quranName,
                builder: (context, state) => const QuranPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                name: AppRoutes.learnName,
                builder: (context, state) => const LearnPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
              // Abonelik yönetimi: Profile branch içinde push route
              // (05_IA §6 — bottom nav görünür kalır).
              GoRoute(
                path: AppRoutes.subscriptionSettings,
                name: AppRoutes.subscriptionSettingsName,
                builder: (context, state) =>
                    const SubscriptionSettingsPlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),
      // Shell DIŞI katmanlar (kök navigator):
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoutes.assistant,
        name: AppRoutes.assistantName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AssistantPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        name: AppRoutes.premiumName,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage<void>(
          fullscreenDialog: true,
          child: PremiumPlaceholderScreen(),
        ),
      ),
    ],
  );
}

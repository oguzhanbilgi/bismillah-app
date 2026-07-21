import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_shell.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_article_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_category_screen.dart';
import 'package:bismillah_app/features/learn/presentation/learn_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_goals_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_journey_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_pace_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_placeholder_screen.dart';
import 'package:bismillah_app/features/onboarding/presentation/onboarding_welcome_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_history_screen.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/premium/presentation/premium_placeholder_screen.dart';
import 'package:bismillah_app/features/premium/presentation/subscription_settings_placeholder_screen.dart';
import 'package:bismillah_app/features/profile/presentation/about_screen.dart';
import 'package:bismillah_app/features/profile/presentation/content_sources_screen.dart';
import 'package:bismillah_app/features/profile/presentation/personalization_edit_screen.dart';
import 'package:bismillah_app/features/profile/presentation/privacy_data_screen.dart';
import 'package:bismillah_app/features/profile/presentation/profile_placeholder_screen.dart';
import 'package:bismillah_app/features/quran/presentation/quran_chapter_reader_screen.dart';
import 'package:bismillah_app/features/quran/presentation/quran_saved_verses_screen.dart';
import 'package:bismillah_app/features/quran/presentation/quran_screen.dart';
import 'package:bismillah_app/features/settings/presentation/language_settings_screen.dart';
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

GoRouter buildAppRouter({bool Function()? isOnboardingCompleted}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.today,
    onException: (context, state, router) => router.go(AppRoutes.today),
    // Startup kapısı (TASK 028) — TEK kaynak: onboarding tamamlanmadıysa
    // onboarding dışındaki her konum Welcome'a yönlenir. Onboarding
    // route'ları muaf olduğundan döngü OLUŞAMAZ; tamamlanınca redirect
    // null döner ve `go(today)` stack'i onboarding'siz kurar (geri tuşu
    // onboarding'e dönemez). Router YENİDEN İNŞA EDİLMEZ — closure her
    // navigasyonda güncel değeri okur.
    redirect: (context, state) {
      final completed = isOnboardingCompleted?.call() ?? true;
      if (completed || state.matchedLocation.startsWith(AppRoutes.onboarding)) {
        return null;
      }
      return AppRoutes.onboardingWelcome;
    },
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
                routes: [
                  // Son 7 gün geçmişi: Prayer branch içinde push (relative
                  // path → /prayer/history). Geri PrayerScreen'e döner, alt
                  // navigasyon görünür kalır.
                  GoRoute(
                    path: 'history',
                    name: AppRoutes.prayerHistoryName,
                    builder: (context, state) => const PrayerHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quran,
                name: AppRoutes.quranName,
                builder: (context, state) => const QuranScreen(),
                routes: [
                  // Sure okuyucu (TASK 035): Quran branch içinde push
                  // (relative path → /quran/chapter/:chapterId); geri
                  // katalog listesine döner, alt navigasyon görünür kalır.
                  // Geçersiz parametre ekranda sakin hata olarak ele
                  // alınır — crash/redirect YOK.
                  GoRoute(
                    path: 'chapter/:chapterId',
                    name: AppRoutes.quranChapterName,
                    builder: (context, state) => QuranChapterReaderScreen(
                      chapterId: int.tryParse(
                        state.pathParameters['chapterId'] ?? '',
                      ),
                      // Arama sonucundan hedef ayet (TASK 048); geçersiz
                      // değer okuyucuda sakin biçimde yok sayılır.
                      initialVerseNumber: int.tryParse(
                        state.uri.queryParameters['verse'] ?? '',
                      ),
                    ),
                  ),
                  // Kaydedilen ayetler (TASK 038): Quran branch içinde push;
                  // geri Kur'an ana ekranına döner, alt navigasyon kalır.
                  GoRoute(
                    path: 'bookmarks',
                    name: AppRoutes.quranBookmarksName,
                    builder: (context, state) => const QuranSavedVersesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                name: AppRoutes.learnName,
                builder: (context, state) => const LearnScreen(),
              ),
              // Öğrenme kategorisi ve içerik detayı (TASK 056): Learn
              // branch içinde push route — alt navigasyon görünür kalır.
              GoRoute(
                path: '${AppRoutes.learnCategory}/:slug',
                name: AppRoutes.learnCategoryName,
                builder: (context, state) => LearnCategoryScreen(
                  slug: state.pathParameters['slug'] ?? '',
                ),
              ),
              GoRoute(
                path: '${AppRoutes.learnArticle}/:slug',
                name: AppRoutes.learnArticleName,
                builder: (context, state) => LearnArticleScreen(
                  slug: state.pathParameters['slug'] ?? '',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfilePlaceholderScreen(),
                routes: [
                  // Kişiselleştirme düzenleme (TASK 030): Profile branch
                  // içinde push (relative path → /profile/personalization);
                  // geri Profil'e döner, alt navigasyon görünür kalır.
                  GoRoute(
                    path: 'personalization',
                    name: AppRoutes.profilePersonalizationName,
                    builder: (context, state) =>
                        const PersonalizationEditScreen(),
                  ),
                  // İçerik kaynakları / gizlilik-veri / hakkında (TASK 058):
                  // Profile branch içinde push route'lar — alt navigasyon
                  // görünür kalır, geri Profil'e döner.
                  GoRoute(
                    path: 'sources',
                    name: AppRoutes.profileSourcesName,
                    builder: (context, state) => const ContentSourcesScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: AppRoutes.profilePrivacyName,
                    builder: (context, state) => const PrivacyDataScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    name: AppRoutes.profileAboutName,
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
              // Abonelik yönetimi: Profile branch içinde push route
              // (05_IA §6 — bottom nav görünür kalır).
              GoRoute(
                path: AppRoutes.subscriptionSettings,
                name: AppRoutes.subscriptionSettingsName,
                builder: (context, state) =>
                    const SubscriptionSettingsPlaceholderScreen(),
              ),
              // Uygulama dili seçimi (TASK 053): Profile branch içinde push
              // route — dil değişimi navigasyon YAPMAZ, açık ekranlar
              // yerinde yeniden çizilir.
              GoRoute(
                path: AppRoutes.languageSettings,
                name: AppRoutes.languageSettingsName,
                builder: (context, state) => const LanguageSettingsScreen(),
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
      // Onboarding adımları (TASK 026): startup HENÜZ buraya yönlenmez
      // (TASK 028'de bağlanır); checkpoint'te route manuel açılır.
      GoRoute(
        path: AppRoutes.onboardingWelcome,
        name: AppRoutes.onboardingWelcomeName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGoals,
        name: AppRoutes.onboardingGoalsName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingGoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingJourney,
        name: AppRoutes.onboardingJourneyName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingJourneyScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPace,
        name: AppRoutes.onboardingPaceName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingPaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.assistant,
        name: AppRoutes.assistantName,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AssistantScreen(),
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

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 5 sekmeli alt navigasyon (05_INFORMATION_ARCHITECTURE §4).
///
/// Kurallar: sekme sayısı SABİT 5'tir; Asistan sekme DEĞİLDİR; kırmızı
/// bildirim noktası/rozet yasaktır (03_DESIGN_SYSTEM §13); aktif durum
/// zümrüt token'ı kullanır (tema üzerinden). Sekmeye yeniden dokunuş
/// kendi yığınını köke döndürür.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.wb_sunny_outlined),
          selectedIcon: const Icon(Icons.wb_sunny),
          label: l10n.tabToday,
        ),
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: l10n.tabPrayer,
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_stories_outlined),
          selectedIcon: const Icon(Icons.auto_stories),
          label: l10n.tabQuran,
        ),
        NavigationDestination(
          icon: const Icon(Icons.school_outlined),
          selectedIcon: const Icon(Icons.school),
          label: l10n.tabLearn,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.tabProfile,
        ),
      ],
    );
  }
}

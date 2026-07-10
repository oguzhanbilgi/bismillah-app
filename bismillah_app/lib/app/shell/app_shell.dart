import 'package:bismillah_app/app/router/route_metadata.dart';
import 'package:bismillah_app/app/shell/assistant_fab.dart';
import 'package:bismillah_app/app/shell/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ana uygulama kabuğu: 5 sekmeli StatefulShellRoute gövdesi
/// (06_FLUTTER_ARCHITECTURE §12–13).
///
/// Alt navigasyon ve asistan FAB görünürlüğü EKRANLARIN DEĞİL bu kabuğun
/// kararıdır — merkezi route metadata'sından okunur (05_IA §16).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final metadata = RouteMetadataRegistry.of(location);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: metadata.hidesChrome
          ? null
          : BottomNavBar(navigationShell: navigationShell),
      floatingActionButton:
          (!metadata.hidesChrome && metadata.showsAssistantFab)
          ? const AssistantFab()
          : null,
    );
  }
}

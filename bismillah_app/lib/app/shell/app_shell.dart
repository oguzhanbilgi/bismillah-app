import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/router/route_metadata.dart';
import 'package:bismillah_app/app/shell/assistant_fab.dart';
import 'package:bismillah_app/app/shell/bottom_nav_bar.dart';
import 'package:bismillah_app/features/quran/presentation/widgets/quran_audio_mini_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ana uygulama kabuğu: 5 sekmeli StatefulShellRoute gövdesi
/// (06_FLUTTER_ARCHITECTURE §12–13).
///
/// Alt navigasyon ve asistan FAB görünürlüğü EKRANLARIN DEĞİL bu kabuğun
/// kararıdır — merkezi route metadata'sından okunur (05_IA §16).
///
/// Kur'an mini oynatıcısı (TASK 046) TEK ortak widget olarak burada,
/// içerik ile alt navigasyon arasında yaşar: bottomNavigationBar slotu
/// yüksekliği hesaba kattığından içerik altta KAPANMAZ, yükseklik tahmini
/// yapılmaz. Sure okuyucusunda mevcut tam panel kullanıldığı için mini
/// oynatıcı orada gösterilmez. Oturum durumunu mini oynatıcının kendisi
/// izler — shell her playback değişiminde YENİDEN KURULMAZ.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Mini oynatıcı gövdesinden aktif surenin okuyucusuna dönüş: mevcut
  /// `/quran/chapter/:chapterId` route'u kullanılır; aynı konum zaten
  /// açıksa yinelenen navigasyon YAPILMAZ. Oynatma kesilmez.
  void _openChapterReader(BuildContext context, int chapterId) {
    final target = AppRoutes.quranChapterPath(chapterId);
    if (GoRouterState.of(context).uri.path == target) {
      return;
    }
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final metadata = RouteMetadataRegistry.of(location);
    final onChapterReader = Uri.parse(
      location,
    ).path.startsWith('${AppRoutes.quranChapter}/');

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: metadata.hidesChrome
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!onChapterReader)
                  QuranAudioMiniPlayer(
                    onOpenReader: (chapterId) =>
                        _openChapterReader(context, chapterId),
                  ),
                BottomNavBar(navigationShell: navigationShell),
              ],
            ),
      floatingActionButton:
          (!metadata.hidesChrome && metadata.showsAssistantFab)
          ? const AssistantFab()
          : null,
    );
  }
}

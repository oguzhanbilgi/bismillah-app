import 'package:bismillah_app/app/router/app_routes.dart';

/// Route davranış metadata'sı (06_FLUTTER_ARCHITECTURE §13).
///
/// Kutsal/odak yüzeylerde alt navigasyon ve asistan FAB'ının gizlenmesi
/// ekranların kendi kararı DEĞİLDİR — bu merkezi kayıttan okunur
/// (05_INFORMATION_ARCHITECTURE §16).
final class RouteMetadata {
  const RouteMetadata({
    this.hidesChrome = false,
    this.showsAssistantFab = true,
    this.isFullScreenModal = false,
  });

  /// Alt navigasyon + FAB dahil tüm "chrome" gizlenir
  /// (zikir sayacı, Kur'an okuma yüzeyi, kutlamalar — ileride eklenir).
  final bool hidesChrome;

  /// Asistan FAB görünürlüğü (chrome açıkken bile kapatılabilir).
  final bool showsAssistantFab;

  /// Kök navigator'da fullscreenDialog olarak sunulur.
  final bool isFullScreenModal;

  static const RouteMetadata standard = RouteMetadata();
}

/// Path → metadata kaydı. Eşleşme önce tam path, sonra en uzun prefix ile
/// yapılır; kayıt yoksa [RouteMetadata.standard] döner.
abstract final class RouteMetadataRegistry {
  static const Map<String, RouteMetadata> _registry = {
    AppRoutes.onboarding: RouteMetadata(
      hidesChrome: true,
      showsAssistantFab: false,
    ),
    AppRoutes.assistant: RouteMetadata(
      hidesChrome: true,
      showsAssistantFab: false,
    ),
    AppRoutes.premium: RouteMetadata(
      hidesChrome: true,
      showsAssistantFab: false,
      isFullScreenModal: true,
    ),
    AppRoutes.subscriptionSettings: RouteMetadata(showsAssistantFab: false),
  };

  static RouteMetadata of(String location) {
    final path = Uri.parse(location).path;
    final exact = _registry[path];
    if (exact != null) {
      return exact;
    }
    String? bestPrefix;
    for (final key in _registry.keys) {
      if (path.startsWith('$key/') &&
          (bestPrefix == null || key.length > bestPrefix.length)) {
        bestPrefix = key;
      }
    }
    return bestPrefix != null ? _registry[bestPrefix]! : RouteMetadata.standard;
  }
}

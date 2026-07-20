import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tarayıcı açma çağrısının test dikişi.
typedef UrlLaunchCallback = Future<bool> Function(Uri uri);

/// Resmî kaynak bağlantısını SİSTEM TARAYICISINDA açar (TASK 058 §5).
///
/// `canLaunchUrl` sonucuna güvenilmez (Android 11+ paket görünürlüğü);
/// doğrudan `launchUrl` denenir, sonucu/istisnası yakalanır. Buton asla
/// önden devre dışı bırakılmaz — başarısızlıkta çağıran copy fallback sunar.
final class UrlLauncherAppSourceLinkService implements AppSourceLinkService {
  /// [launcher] yalnız TEST içindir: verilmezse gerçek `launchUrl` kullanılır.
  const UrlLauncherAppSourceLinkService({UrlLaunchCallback? launcher})
    : _launcher = launcher ?? _launchExternally;

  final UrlLaunchCallback _launcher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> openSource(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !AppSourceDomains.isAllowed(url)) {
      return false;
    }
    try {
      return await _launcher(uri);
    } on Exception {
      return false;
    }
  }
}

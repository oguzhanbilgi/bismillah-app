import 'package:bismillah_app/features/profile/domain/privacy_policy_link.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tarayıcı açma çağrısının test dikişi.
typedef PrivacyPolicyLaunchCallback = Future<bool> Function(Uri uri);

/// Yayımlanmış gizlilik politikasını SİSTEM TARAYICISINDA açar (ALPHA-R3C).
///
/// [UrlLauncherAppSourceLinkService] ve [UrlLauncherSupportContactService]
/// ile aynı gerekçe: `canLaunchUrl` sonucuna güvenilmez (Android 11+ paket
/// görünürlüğü), doğrudan `launchUrl` denenir ve sonucu/istisnası yakalanır.
/// Buton asla önden devre dışı bırakılmaz — başarısızlıkta çağıran adresi
/// gösteren sakin bir fallback sunar. Yeni bağımlılık EKLENMEZ.
final class UrlLauncherPrivacyPolicyLinkService
    implements PrivacyPolicyLinkService {
  /// [launcher] yalnız TEST içindir: verilmezse gerçek `launchUrl` kullanılır.
  const UrlLauncherPrivacyPolicyLinkService({
    PrivacyPolicyLaunchCallback? launcher,
  }) : _launcher = launcher ?? _launchExternally;

  final PrivacyPolicyLaunchCallback _launcher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> openPublishedPolicy() async {
    final uri = Uri.tryParse(PrivacyPolicyLink.url);
    if (uri == null || uri.scheme != 'https') {
      return false;
    }
    try {
      return await _launcher(uri);
    } on Exception {
      return false;
    }
  }
}

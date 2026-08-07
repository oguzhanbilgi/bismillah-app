import 'package:bismillah_app/features/profile/domain/support_contact.dart';
import 'package:url_launcher/url_launcher.dart';

/// `mailto` çağrısının test dikişi.
typedef SupportMailLaunchCallback = Future<bool> Function(Uri uri);

/// Destek e-postasını PLATFORMUN e-posta yazma ekranında açar (ALPHA-R3A).
///
/// [UrlLauncherAppSourceLinkService] ile aynı gerekçe: `canLaunchUrl`
/// sonucuna güvenilmez (Android 11+ paket görünürlüğü), doğrudan `launchUrl`
/// denenir ve sonucu/istisnası yakalanır. Buton asla önden devre dışı
/// bırakılmaz — başarısızlıkta çağıran adresi gösteren fallback sunar.
final class UrlLauncherSupportContactService implements SupportContactService {
  /// [launcher] yalnız TEST içindir: verilmezse gerçek `launchUrl` kullanılır.
  const UrlLauncherSupportContactService({SupportMailLaunchCallback? launcher})
    : _launcher = launcher ?? _launchExternally;

  final SupportMailLaunchCallback _launcher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> openSupportEmail() async {
    try {
      return await _launcher(SupportContact.mailtoUri);
    } on Exception {
      return false;
    }
  }
}

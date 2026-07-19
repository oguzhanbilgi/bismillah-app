import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/services/external_link_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resmî kaynak bağlantısını SİSTEM TARAYICISINDA açar (TASK 056A §7).
///
/// Güvenlik sırası:
/// 1. URI ayrıştırılabilir ve şeması HTTPS olmalı.
/// 2. Host [OfficialSourceDomains] allowlist'inden geçmeli.
/// 3. `launchUrl` ile harici uygulama (tarayıcı) denenir.
///
/// `canLaunchUrl` sonucuna GÜVENİLMEZ: Android 11+ paket görünürlüğü
/// nedeniyle tarayıcı kurulu olsa bile `false` dönebilir. Bu yüzden
/// doğrudan `launchUrl` denenir ve sonucu/istisnası yakalanır — buton
/// asla önden devre dışı bırakılmaz.
///
/// WebView KULLANILMAZ.
/// Tarayıcı açma çağrısının test dikişi.
typedef UrlLaunchCallback = Future<bool> Function(Uri uri);

final class UrlLauncherExternalLinkService implements ExternalLinkService {
  /// [launcher] yalnız TEST içindir: verilmezse gerçek `launchUrl`
  /// kullanılır. Böylece testler platform eklentisinin iç kanallarını
  /// taklit etmek zorunda kalmadan davranışı doğrulayabilir.
  const UrlLauncherExternalLinkService({UrlLaunchCallback? launcher})
    : _launcher = launcher ?? _launchExternally;

  /// Tarayıcı çağrısı; üretimde gerçek `launchUrl`, testte sahte olur.
  final UrlLaunchCallback _launcher;

  static Future<bool> _launchExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> openOfficialSource(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme != 'https') {
      return false;
    }
    // Allowlist ihlali: resmî olmayan adres HİÇBİR koşulda açılmaz.
    // Bu kontrol platform çağrısından ÖNCE gelir.
    if (!OfficialSourceDomains.isAllowed(url)) {
      return false;
    }
    try {
      return await _launcher(uri);
    } on Exception {
      // Platform kanalı yoksa/başarısızsa CRASH YOK — çağıran sakin bir
      // mesaj gösterir ve panoya kopyalama sunar.
      return false;
    }
  }
}

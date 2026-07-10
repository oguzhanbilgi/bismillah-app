import 'package:bismillah_app/core/config/flavor.dart';

/// Çalışma ortamı yapılandırması — koşullu `if (kDebugMode)` dağınıklığı
/// yerine tek config nesnesi (06_FLUTTER_ARCHITECTURE §34).
///
/// Firebase/RevenueCat/AI proxy config'leri bu görevde BİLİNÇLİ olarak yok;
/// gerçek entegrasyon görevlerinde bu sınıfa alan olarak eklenecekler.
/// Secret/anahtar bu sınıfa asla yazılmaz (sunucu tarafında yaşarlar).
final class AppEnvironment {
  const AppEnvironment({required this.flavor});

  final Flavor flavor;

  /// `--dart-define=FLAVOR=production` ile seçilir; verilmezse development.
  factory AppEnvironment.fromDartDefine() {
    const flavorName = String.fromEnvironment('FLAVOR');
    return AppEnvironment(flavor: FlavorParsing.fromName(flavorName));
  }

  bool get isDevelopment => flavor == Flavor.development;
  bool get isProduction => flavor == Flavor.production;

  /// Uygulama adı eki (dev/staging build'leri ayırt etmek için).
  String get appNameSuffix => switch (flavor) {
        Flavor.development => ' Dev',
        Flavor.staging => ' Beta',
        Flavor.production => '',
      };
}

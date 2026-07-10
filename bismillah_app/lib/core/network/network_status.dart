/// Bağlantı durumu soyutlaması (06_FLUTTER_ARCHITECTURE §7 `core/network`).
///
/// Gerçek connectivity implementasyonu sonraki görevde eklenir; bu görevde
/// yalnız sözleşme ve güvenli bir placeholder vardır. UI, bağlantıyı asla
/// doğrudan platform API'sinden okumaz.
enum NetworkStatus { online, offline }

abstract interface class NetworkStatusService {
  Future<NetworkStatus> current();

  Stream<NetworkStatus> watch();
}

/// Scaffold aşaması placeholder'ı: daima çevrimiçi varsayar.
///
/// Offline-first mimaride bu varsayım güvenlidir — hiçbir akış bağlantıyı
/// ön koşul olarak kullanmaz (05_INFORMATION_ARCHITECTURE §13).
final class AlwaysOnlineNetworkStatusService implements NetworkStatusService {
  const AlwaysOnlineNetworkStatusService();

  @override
  Future<NetworkStatus> current() async => NetworkStatus.online;

  @override
  Stream<NetworkStatus> watch() => Stream.value(NetworkStatus.online);
}

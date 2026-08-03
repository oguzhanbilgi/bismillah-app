import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';

/// Ön-planda alınmış cihaz konumu — paket-bağımsız (geolocator sızmaz).
final class PrayerLocation {
  const PrayerLocation({required this.coordinates, this.isApproximate = false});

  final PrayerCoordinates coordinates;

  /// Son-bilinen konumdan gelen tahmini konum mu? (UI'da nazik not için.)
  final bool isApproximate;
}

/// Konum çözümleme sonucu — UI durumlarına birebir eşlenir.
sealed class PrayerLocationResult {
  const PrayerLocationResult();
}

final class PrayerLocationResolved extends PrayerLocationResult {
  const PrayerLocationResolved(this.location);
  final PrayerLocation location;
}

/// İzin verilmemiş (henüz istenebilir) veya kalıcı reddedilmiş.
final class PrayerLocationPermissionDenied extends PrayerLocationResult {
  const PrayerLocationPermissionDenied({required this.permanentlyDenied});

  /// `true` ise sistem ayarlarından açılmalı (yeniden istenemez).
  final bool permanentlyDenied;
}

/// Konum alınamadı (zaman aşımı/hata) ve güvenli son-bilinen konum da yok.
final class PrayerLocationUnavailable extends PrayerLocationResult {
  const PrayerLocationUnavailable();
}

/// Cihazın konum servisi (GPS) KAPALI — izin verilmiş olsa bile konum
/// alınamaz ve izin istemek işe yaramaz; kullanıcının sistem ayarından
/// açması gerekir (TASK 095).
///
/// [PrayerLocationUnavailable]'dan ayrı tutulur: sebebi farklı olduğu için
/// kullanıcıya söylenecek dürüst cümle de farklıdır.
final class PrayerLocationServiceDisabled extends PrayerLocationResult {
  const PrayerLocationServiceDisabled();
}

/// Ön-plan konum sözleşmesi (SADECE foreground; arka plan konumu YASAK).
///
/// Gizlilik: konum Firebase'e/analytics'e GİTMEZ, sync payload'ına
/// EKLENMEZ, sürekli geçmiş TUTULMAZ (TASK 021). geolocator yalnız data
/// implementasyonunda import edilir.
abstract interface class PrayerLocationService {
  /// İzin ZATEN verilmişse konumu döndürür; verilmemişse İSTEMEDEN
  /// [PrayerLocationPermissionDenied] döner (day-0 izin duvarı yok).
  Future<PrayerLocationResult> currentLocationIfPermitted();

  /// İzni İSTER (kullanıcı "Konumu kullan" dediğinde), sonra konumu alır.
  Future<PrayerLocationResult> requestLocation();

  /// İzin kalıcı reddedildiğinde sistem ayarlarını açar (yeniden istenemez).
  Future<void> openAppSettings();
}

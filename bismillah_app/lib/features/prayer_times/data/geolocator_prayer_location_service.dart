import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:geolocator/geolocator.dart';

/// geolocator tabanlı ön-plan konum servisi. geolocator tipleri bu dosyanın
/// dışına SIZMAZ (domain/application/presentation geolocator görmez).
///
/// SADECE foreground: `LocationAccuracy.medium` (namaz vakti için şehir
/// çözünürlüğü yeter — hassas takip GEREKMEZ), makul timeout, sürekli
/// stream YOK, arka plan konumu YOK. Gizlilik: koordinat yalnız hesap için
/// kullanılır; loglanmaz, Firebase'e/sync'e gitmez (TASK 021).
final class GeolocatorPrayerLocationService implements PrayerLocationService {
  const GeolocatorPrayerLocationService();

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return const PrayerLocationPermissionDenied(permanentlyDenied: false);
    }
    if (permission == LocationPermission.deniedForever) {
      return const PrayerLocationPermissionDenied(permanentlyDenied: true);
    }
    return _resolvePosition();
  }

  @override
  Future<PrayerLocationResult> requestLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const PrayerLocationPermissionDenied(permanentlyDenied: false);
    }
    if (permission == LocationPermission.deniedForever) {
      return const PrayerLocationPermissionDenied(permanentlyDenied: true);
    }
    return _resolvePosition();
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// Güncel konumu dener; başarısızsa güvenli son-bilinen konuma düşer;
  /// o da yoksa [PrayerLocationUnavailable]. ASLA çökmez.
  ///
  /// Konum servisi kapalıysa (TASK 095) ayrı ve dürüst bir sonuç döner —
  /// ama YALNIZ son-bilinen konum da yoksa: izin istemek bu durumda çözüm
  /// değildir, sistem ayarı gerekir.
  ///
  /// Son-bilinen konum yedeği KORUNUR: servis kapalıyken de elde geçerli
  /// bir konum varsa namaz vakitleri gösterilmeye devam eder (TASK 021
  /// davranışı bu görevde bozulmaz).
  Future<PrayerLocationResult> _resolvePosition() async {
    var serviceDisabled = false;
    try {
      serviceDisabled = !await Geolocator.isLocationServiceEnabled();
    } on Exception {
      // Servis durumu okunamadıysa normal akışa devam edilir; aşağıdaki
      // konum denemesi zaten güvenli biçimde başarısız olabilir.
    }
    if (serviceDisabled) {
      return await _lastKnownOrNull() ?? const PrayerLocationServiceDisabled();
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: _timeout,
        ),
      );
      return PrayerLocationResolved(_toLocation(position, approximate: false));
    } on Exception {
      // Zaman aşımı / başka hata → son-bilinen konum.
      return await _lastKnownOrNull() ?? const PrayerLocationUnavailable();
    }
  }

  /// Son-bilinen konum varsa "yaklaşık" olarak döner; yoksa `null`.
  Future<PrayerLocationResolved?> _lastKnownOrNull() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return PrayerLocationResolved(_toLocation(last, approximate: true));
      }
    } on Exception {
      // Son-bilinen de alınamadı.
    }
    return null;
  }

  PrayerLocation _toLocation(Position p, {required bool approximate}) {
    return PrayerLocation(
      coordinates: PrayerCoordinates(
        latitude: p.latitude,
        longitude: p.longitude,
      ),
      isApproximate: approximate,
    );
  }
}

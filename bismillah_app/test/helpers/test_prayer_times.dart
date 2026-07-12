import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Widget testlerinde gerçek geolocator platform çağrısını engellemek için
/// fake konum servisi override'ı (TASK 021). Varsayılan: izin reddedilmiş
/// (namaz kaydı testleri konumdan bağımsız çalışmalı).
Override fakeLocationOverride({PrayerLocationResult? ifPermitted}) {
  return prayerLocationServiceProvider.overrideWithValue(
    _FakeLocationService(
      ifPermitted ??
          const PrayerLocationPermissionDenied(permanentlyDenied: false),
    ),
  );
}

/// İzin verilmiş + sabit koordinat döndüren override (vakit gösterimi testi).
Override grantedLocationOverride({
  PrayerCoordinates coordinates = const PrayerCoordinates(
    latitude: 41.0082,
    longitude: 28.9784,
  ),
}) {
  return prayerLocationServiceProvider.overrideWithValue(
    _FakeLocationService(PrayerLocationResolved(PrayerLocation(
      coordinates: coordinates,
    ))),
  );
}

final class _FakeLocationService implements PrayerLocationService {
  const _FakeLocationService(this._result);

  final PrayerLocationResult _result;

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async => _result;

  @override
  Future<PrayerLocationResult> requestLocation() async => _result;

  @override
  Future<void> openAppSettings() async {}
}

import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 021: konum izni akışları — fake PrayerLocationService ile; gerçek
/// Firebase/geolocator/cihaz GEREKMEZ. Gerçek adhan calculator kullanılır
/// (deterministik, offline).
void main() {
  const istanbul = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);
  final fixedLocalNow = DateTime(2026, 7, 15, 9);

  ProviderContainer buildContainer(_FakeLocationService service) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        prayerLocationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('permission granted → ready with calculated times for today', () async {
    final container = buildContainer(
      _FakeLocationService(
        ifPermitted: const PrayerLocationResolved(
          PrayerLocation(coordinates: istanbul),
        ),
      ),
    );
    final state = await container.read(prayerTimesControllerProvider.future);
    expect(state, isA<PrayerTimesReady>());
    final ready = state as PrayerTimesReady;
    expect(ready.times.dayKey, '2026-07-15');
    expect(ready.times.isChronological, isTrue);
    expect(ready.approximateLocation, isFalse);
  });

  test('permission denied → needs permission (not permanent)', () async {
    final container = buildContainer(
      _FakeLocationService(
        ifPermitted:
            const PrayerLocationPermissionDenied(permanentlyDenied: false),
      ),
    );
    final state = await container.read(prayerTimesControllerProvider.future);
    expect(state, isA<PrayerTimesNeedsPermission>());
    expect((state as PrayerTimesNeedsPermission).permanentlyDenied, isFalse);
  });

  test('permission permanently denied → needs permission (permanent)',
      () async {
    final container = buildContainer(
      _FakeLocationService(
        ifPermitted:
            const PrayerLocationPermissionDenied(permanentlyDenied: true),
      ),
    );
    final state = await container.read(prayerTimesControllerProvider.future);
    expect((state as PrayerTimesNeedsPermission).permanentlyDenied, isTrue);
  });

  test('location unavailable (service off / error) → unavailable', () async {
    final container = buildContainer(
      _FakeLocationService(ifPermitted: const PrayerLocationUnavailable()),
    );
    final state = await container.read(prayerTimesControllerProvider.future);
    expect(state, isA<PrayerTimesUnavailable>());
  });

  test('last-known fallback → ready with approximate flag', () async {
    final container = buildContainer(
      _FakeLocationService(
        ifPermitted: const PrayerLocationResolved(
          PrayerLocation(coordinates: istanbul, isApproximate: true),
        ),
      ),
    );
    final state = await container.read(prayerTimesControllerProvider.future);
    expect((state as PrayerTimesReady).approximateLocation, isTrue);
  });

  test('useLocation() transitions denied → ready after grant', () async {
    final service = _FakeLocationService(
      ifPermitted:
          const PrayerLocationPermissionDenied(permanentlyDenied: false),
      onRequest: const PrayerLocationResolved(
        PrayerLocation(coordinates: istanbul),
      ),
    );
    final container = buildContainer(service);

    final initial = await container.read(prayerTimesControllerProvider.future);
    expect(initial, isA<PrayerTimesNeedsPermission>());

    await container.read(prayerTimesControllerProvider.notifier).useLocation();

    final after = container.read(prayerTimesControllerProvider).value;
    expect(after, isA<PrayerTimesReady>());
  });
}

final class _FakeLocationService implements PrayerLocationService {
  _FakeLocationService({this.ifPermitted, this.onRequest});

  final PrayerLocationResult? ifPermitted;
  final PrayerLocationResult? onRequest;
  int openSettingsCalls = 0;

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async =>
      ifPermitted!;

  @override
  Future<PrayerLocationResult> requestLocation() async => onRequest!;

  @override
  Future<void> openAppSettings() async => openSettingsCalls++;
}

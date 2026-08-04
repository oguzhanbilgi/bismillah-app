import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz vakti controller'ı (application). Konum servisinden konumu alır,
/// clock'un yerel gününe göre TAM OFFLINE hesaplar. Namaz KAYDI'ndan
/// bağımsızdır — konum reddedilse bile işaretleme çalışmaya devam eder.
///
/// Gün değişimi: `clockProvider` yerel günü verir; controller yeniden
/// kurulduğunda (ör. sekmeye dönüş / invalidate) o günün vakitleri hesaplanır.
final prayerTimesControllerProvider =
    AsyncNotifierProvider<PrayerTimesController, PrayerTimesState>(
      PrayerTimesController.new,
    );

final class PrayerTimesController extends AsyncNotifier<PrayerTimesState> {
  @override
  Future<PrayerTimesState> build() async {
    // Seçili hesaplama yöntemi İZLENİR (TASK 096): yöntem değişince bu
    // controller yeniden kurulur ve vakitler yeniden hesaplanır. Bu yüzden
    // ayrı bir "önbelleği temizle" adımı yoktur — bayat vakit KALAMAZ.
    ref.watch(prayerCalculationMethodProvider);
    // Açılışta İZİN İSTENMEZ (day-0 duvarı yok) — yalnız zaten verilmişse
    // konum alınır; aksi hâlde "Konumu kullan" daveti gösterilir.
    final result = await ref
        .watch(prayerLocationServiceProvider)
        .currentLocationIfPermitted();
    return _map(result);
  }

  /// "Konumu kullan" eylemi: izni İSTER, sonra vakitleri hesaplar.
  Future<void> useLocation() async {
    state = const AsyncLoading<PrayerTimesState>();
    final result = await ref
        .read(prayerLocationServiceProvider)
        .requestLocation();
    state = AsyncData(_map(result));
  }

  /// Kalıcı reddedilmiş izinde sistem ayarlarını açar.
  Future<void> openSettings() =>
      ref.read(prayerLocationServiceProvider).openAppSettings();

  PrayerTimesState _map(PrayerLocationResult result) {
    switch (result) {
      case PrayerLocationResolved(:final location):
        final times = ref
            .read(prayerTimeCalculatorProvider)
            .calculate(
              coordinates: location.coordinates,
              date: ref.read(clockProvider).nowLocal(),
              method: ref.read(prayerCalculationMethodProvider),
            );
        return PrayerTimesReady(
          times: times,
          approximateLocation: location.isApproximate,
        );
      case PrayerLocationPermissionDenied(:final permanentlyDenied):
        return PrayerTimesNeedsPermission(permanentlyDenied: permanentlyDenied);
      case PrayerLocationUnavailable():
      case PrayerLocationServiceDisabled():
        // Namaz vakitleri yüzeyi TASK 095'te DEĞİŞTİRİLMEZ: konum servisi
        // kapalı olması da kullanıcı için "şu an konum alınamadı" sakin
        // durumudur. Ayrımı yalnız Kıble ekranı gösterir.
        return const PrayerTimesUnavailable();
    }
  }
}

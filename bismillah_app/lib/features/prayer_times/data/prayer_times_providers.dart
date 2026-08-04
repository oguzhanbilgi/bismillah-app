import 'package:bismillah_app/features/prayer_times/data/adhan_calculation_method_catalog.dart';
import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/data/geolocator_prayer_location_service.dart';
import 'package:bismillah_app/features/prayer_times/data/shared_prefs_prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz vakti altyapı provider'ları — somut adhan/geolocator
/// implementasyonlarını arayüz arkasından verir. Testler `ProviderScope`
/// override'ıyla fake calculator/location service enjekte eder.
final prayerTimeCalculatorProvider = Provider<PrayerTimeCalculator>(
  (ref) => const AdhanPrayerTimeCalculator(),
);

final prayerLocationServiceProvider = Provider<PrayerLocationService>(
  (ref) => const GeolocatorPrayerLocationService(),
);

/// Seçilebilir yöntemlerin ve parametrelerinin kaynağı — değerler motorun
/// kendi preset'lerinden okunur (TASK 096).
final prayerCalculationMethodCatalogProvider =
    Provider<PrayerCalculationMethodCatalog>(
      (ref) => const AdhanPrayerCalculationMethodCatalog(),
    );

final prayerCalculationMethodRepositoryProvider =
    Provider<PrayerCalculationMethodRepository>(
      (ref) => const SharedPrefsPrayerCalculationMethodRepository(),
    );

import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/data/geolocator_prayer_location_service.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
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

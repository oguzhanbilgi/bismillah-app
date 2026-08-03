import 'package:bismillah_app/features/qibla/data/platform_qibla_compass_service.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kıble altyapı provider'ları (TASK 095).
///
/// Konum için YENİ bir servis eklenmez: kıble, namaz vakitlerinin zaten
/// kullandığı `prayerLocationServiceProvider` üzerinden aynı ön-plan konum
/// sözleşmesini paylaşır. Testler burayı `ProviderScope` override'ı ile
/// belirlenimci sahte pusula akışına bağlar.
final qiblaCompassServiceProvider = Provider<QiblaCompassService>(
  (ref) => const PlatformQiblaCompassService(),
);

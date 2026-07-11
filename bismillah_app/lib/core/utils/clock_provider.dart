import 'package:bismillah_app/core/utils/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zaman kaynağı DI noktası (06_FLUTTER_ARCHITECTURE §7 — `DateTime.now()`
/// doğrudan çağrılmaz). `core`'da yaşar ki feature application katmanları
/// kompozisyon köküne (`app/`) bağımlanmadan saat enjekte edebilsin;
/// `app_providers` aynı sembolü re-export eder.
final clockProvider = Provider<AppClock>((ref) => const SystemClock());

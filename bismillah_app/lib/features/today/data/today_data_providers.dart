import 'package:bismillah_app/features/today/data/shared_prefs_daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Günlük plan deposunun DI bağlaması (06 §11 — tek DI mekanizması
/// Riverpod; presentation SharedPreferences görmez).
///
/// **GEÇİCİ:** bugün SharedPreferences tabanlı sürümlü zarf adaptörünü
/// döndürür; plan verisi Drift'e taşındığında yalnız bu satır değişir —
/// çağıranlar [DailyPlanRepository] arayüzünü görmeye devam eder.
///
/// Bootstrap bu provider'ı OKUMAZ: plan ne otomatik yüklenir ne üretilir.
final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  final repository = SharedPrefsDailyPlanRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

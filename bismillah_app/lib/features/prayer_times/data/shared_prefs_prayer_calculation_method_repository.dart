import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı yöntem tercihi deposu (TASK 096).
///
/// Enum stabil `name` ile yazılır. Bozuk/bilinmeyen/eski bir değer "seçim
/// yok" sayılır (`null`) — çökme yok, çağıran varsayılana düşer ve saklanan
/// bayt DEĞİŞTİRİLMEZ. Anahtar `bismillah.` önekindedir, bu yüzden mevcut
/// tam yerel sıfırlama onu zaten temizler (yeni sıfırlama kodu gerekmez).
final class SharedPrefsPrayerCalculationMethodRepository
    implements PrayerCalculationMethodRepository {
  const SharedPrefsPrayerCalculationMethodRepository();

  static const String _key = 'bismillah.prayer_calculation_method';

  @override
  ResultFuture<PrayerTimeCalculationMethod?> loadMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(
        PrayerTimeCalculationMethod.fromStorageKey(prefs.get(_key)),
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveMethod(PrayerTimeCalculationMethod method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, method.name);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}

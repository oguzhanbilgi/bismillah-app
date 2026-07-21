import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_preferences_provider.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_status_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/settings/data/shared_prefs_local_data_reset_repository.dart';
import 'package:bismillah_app/features/settings/domain/repositories/local_data_reset_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Yerel veri sıfırlama deposunun DI bağlaması (TASK 058).
final localDataResetRepositoryProvider = Provider<LocalDataResetRepository>(
  (ref) => const SharedPrefsLocalDataResetRepository(),
);

/// Yerel veri sıfırlama orkestrasyonu (TASK 058 §7).
///
/// Cihaz-lokal verinin farklı katmanlarını (SharedPreferences + Drift)
/// TEK yerden temizler ve ilgili controller/provider state'lerini
/// invalidate eder. Navigasyon yapmaz — ekran, tam reset sonrası
/// onboarding'e yönlendirir.
final localDataResetControllerProvider = Provider<LocalDataResetController>(
  LocalDataResetController.new,
);

final class LocalDataResetController {
  const LocalDataResetController(this._ref);

  final Ref _ref;

  /// Yalnız Learn verisini siler; sonra Learn ilerleme durumunu tazeler.
  Future<void> resetLearningData() async {
    await _ref.read(localDataResetRepositoryProvider).clearLearningData();
    _ref.invalidate(learnProgressProvider);
  }

  /// Tüm yerel veriyi (dil hariç) siler: SharedPreferences + Drift namaz
  /// kaydı. Ardından ilgili state'ler invalidate edilir ve onboarding
  /// kapısı yeniden kapatılır (router redirect kullanıcıyı onboarding'e
  /// döndürür).
  Future<void> resetAllLocalData() async {
    await _ref.read(localDataResetRepositoryProvider).clearAllExceptLocale();
    // Namaz kaydı ve sync kuyruğu Drift'te yaşar — tek transaction'da silinir.
    await _ref.read(appDatabaseProvider).clearAll();

    _ref.invalidate(learnProgressProvider);
    _ref.invalidate(prayerLogControllerProvider);
    _ref.invalidate(onboardingPreferencesProvider);
    // Kapı en sonda kapatılır: redirect değerini yalnız veriler silindikten
    // sonra değiştiririz.
    _ref.read(onboardingCompletedProvider.notifier).resetToIncomplete();
  }
}

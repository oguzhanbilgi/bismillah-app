import 'package:bismillah_app/features/settings/domain/repositories/local_data_reset_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı yerel veri sıfırlama (TASK 058 §7).
///
/// Anahtar ailesi `bismillah.` önekiyle tanımlıdır; tüm uygulama
/// tercihleri bu önekte yaşar. Dil anahtarı [_localeKey] açık bir ürün
/// kararıyla KORUNUR — kullanıcı sıfırlama sonrası tanıdığı dilde kalır.
final class SharedPrefsLocalDataResetRepository
    implements LocalDataResetRepository {
  const SharedPrefsLocalDataResetRepository();

  /// Tüm uygulama anahtarlarının ortak öneki.
  static const String _appPrefix = 'bismillah.';

  /// Tam reset'te bile korunan tek anahtar: uygulama dili.
  static const String _localeKey = 'bismillah.app_locale';

  /// Yalnız öğrenme ilerlemesi anahtarları
  /// (SharedPrefsLearningProgressRepository ile birebir aynı).
  static const Set<String> _learningKeys = {
    'bismillah.learn_bookmarked_ids',
    'bismillah.learn_completed_ids',
    'bismillah.learn_last_opened_id',
    'bismillah.learn_last_section_index',
    'bismillah.learn_last_opened_at',
  };

  @override
  Future<void> clearLearningData() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _learningKeys) {
      await prefs.remove(key);
    }
  }

  @override
  Future<void> clearAllExceptLocale() async {
    final prefs = await SharedPreferences.getInstance();
    // Anahtar kümesinin anlık kopyası üzerinde çalışılır: `getKeys` canlı
    // görünümü döndürebilir, döngü içinde silmek güvensizdir.
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(_appPrefix) && key != _localeKey)
        .toList(growable: false);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

import 'package:bismillah_app/features/settings/data/shared_prefs_local_data_reset_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel veri sıfırlama deposu (TASK 058 §7).
///
/// Learn-only sıfırlama YALNIZ öğrenme anahtarlarını siler; tam sıfırlama
/// dil hariç TÜM `bismillah.*` anahtarlarını siler.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = SharedPrefsLocalDataResetRepository();

  Map<String, Object> seed() => {
    'bismillah.app_locale': 'tr',
    'bismillah.learn_bookmarked_ids': ['art-a'],
    'bismillah.learn_completed_ids': ['art-b'],
    'bismillah.learn_last_opened_id': 'art-a',
    'bismillah.learn_last_section_index': 2,
    'bismillah.learn_last_opened_at': '2026-07-20T00:00:00Z',
    'bismillah.quran_translation': 'turkish',
    'bismillah.quran_bookmarked_verse_keys': ['2:255'],
    'bismillah.onboarding_completed': true,
    'bismillah.prayer_reminders_enabled': true,
  };

  group('clearLearningData', () {
    test('yalnız öğrenme anahtarlarını siler, diğerlerine dokunmaz', () async {
      SharedPreferences.setMockInitialValues(seed());
      final prefs = await SharedPreferences.getInstance();

      await repo.clearLearningData();
      await prefs.reload();

      // Learn anahtarları gitti.
      expect(prefs.get('bismillah.learn_bookmarked_ids'), isNull);
      expect(prefs.get('bismillah.learn_completed_ids'), isNull);
      expect(prefs.get('bismillah.learn_last_opened_id'), isNull);
      expect(prefs.get('bismillah.learn_last_section_index'), isNull);
      expect(prefs.get('bismillah.learn_last_opened_at'), isNull);
      // Diğer her şey korunur.
      expect(prefs.get('bismillah.quran_translation'), 'turkish');
      expect(prefs.get('bismillah.quran_bookmarked_verse_keys'), ['2:255']);
      expect(prefs.get('bismillah.onboarding_completed'), true);
      expect(prefs.get('bismillah.app_locale'), 'tr');
    });
  });

  group('clearAllExceptLocale', () {
    test('dil hariç tüm uygulama anahtarlarını siler', () async {
      SharedPreferences.setMockInitialValues(seed());
      final prefs = await SharedPreferences.getInstance();

      await repo.clearAllExceptLocale();
      await prefs.reload();

      // Dil korunur (açık ürün kararı).
      expect(prefs.get('bismillah.app_locale'), 'tr');
      // Geri kalan her şey silinir.
      expect(prefs.get('bismillah.learn_bookmarked_ids'), isNull);
      expect(prefs.get('bismillah.quran_translation'), isNull);
      expect(prefs.get('bismillah.quran_bookmarked_verse_keys'), isNull);
      expect(prefs.get('bismillah.onboarding_completed'), isNull);
      expect(prefs.get('bismillah.prayer_reminders_enabled'), isNull);
    });

    test('uygulama dışı anahtarlara dokunmaz', () async {
      SharedPreferences.setMockInitialValues({
        'bismillah.app_locale': 'ar',
        'bismillah.quran_translation': 'turkish',
        'third_party.some_key': 'keep-me',
      });
      final prefs = await SharedPreferences.getInstance();

      await repo.clearAllExceptLocale();
      await prefs.reload();

      expect(prefs.get('bismillah.app_locale'), 'ar');
      expect(prefs.get('bismillah.quran_translation'), isNull);
      // `bismillah.` öneki taşımayan anahtar korunur.
      expect(prefs.get('third_party.some_key'), 'keep-me');
    });
  });
}

import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dar SharedPreferences deposu — TEK boolean (Drift şema v2 açılmaz).
/// Bu bir ayar tercihidir, ibadet-geçmişi DEĞİLDİR.
final class SharedPrefsReminderPreferenceStore
    implements ReminderPreferenceStore {
  const SharedPrefsReminderPreferenceStore();

  static const String _key = 'bismillah.prayer_reminders_enabled';

  @override
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

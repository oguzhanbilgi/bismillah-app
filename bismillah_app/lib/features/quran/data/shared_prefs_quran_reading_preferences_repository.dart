import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_preferences.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı Kur'an tercih deposu (TASK 033).
///
/// Onboarding deposuyla aynı gerekçe: ayar tercihi için Drift şeması
/// açılmaz. Enum'lar stabil `name` ile yazılır; bozuk/eksik/tanınmayan
/// değer kurulum tamamlanmamış SAYILIR (crash yok). Tamamlanma bayrağı
/// EN SON yazılır — yarıda kesilirse kapı güvenli tarafta düşer.
final class SharedPrefsQuranReadingPreferencesRepository
    implements QuranReadingPreferencesRepository {
  const SharedPrefsQuranReadingPreferencesRepository();

  static const String _scriptKey = 'bismillah.quran_arabic_script';
  static const String _translationKey = 'bismillah.quran_translation';
  static const String _goalTypeKey = 'bismillah.quran_goal_type';
  static const String _goalAmountKey = 'bismillah.quran_goal_amount';
  static const String _completedKey = 'bismillah.quran_setup_completed';

  /// TASK 032'nin eski yalnız-sayfa hedefi anahtarı (yalnız okunur).
  static const String _legacyPageGoalKey = 'bismillah.quran_daily_page_goal';

  @override
  ResultFuture<QuranReadingPreferences?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_completedKey) ?? false)) {
        return const Result.success(null);
      }
      // Bayrak true olsa bile saklanan değerler doğrulanır: bozuk veya
      // tanınmayan değer → kurulum tamamlanmamış (`success(null)`).
      try {
        final rawAmount = prefs.get(_goalAmountKey);
        final goal = QuranReadingGoal.fromStored(
          typeName: prefs.getString(_goalTypeKey),
          amount: rawAmount is int ? rawAmount : null,
        );
        if (goal == null) {
          return const Result.success(null);
        }
        return Result.success(
          QuranReadingPreferences(
            arabicScript: QuranArabicScript.values.byName(
              prefs.getString(_scriptKey) ?? '',
            ),
            translation: QuranTranslationPreference.values.byName(
              prefs.getString(_translationKey) ?? '',
            ),
            goal: goal,
            setupCompleted: true,
          ),
        );
      } on ArgumentError {
        return const Result.success(null); // tanınmayan enum adı
      }
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> save(QuranReadingPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Tercihler ÖNCE yazılır; tamamlanma bayrağı EN SON true olur.
      await prefs.setString(_scriptKey, preferences.arabicScript.name);
      await prefs.setString(_translationKey, preferences.translation.name);
      await prefs.setString(_goalTypeKey, preferences.goal.type.name);
      await prefs.setInt(_goalAmountKey, preferences.goal.amount);
      await prefs.setBool(_completedKey, true);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<QuranReadingGoal?> loadLegacyPageGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(_legacyPageGoalKey);
      return Result.success(
        raw is int
            ? QuranReadingGoal.of(
                type: QuranReadingGoalType.pages,
                amount: raw,
              )
            : null,
      );
    } on Exception {
      // Ön-seçim iyileştirmesidir — hata kuruluma engel olmaz.
      return const Result.success(null);
    }
  }
}

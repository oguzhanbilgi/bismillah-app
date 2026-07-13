import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';

/// Kur'an okuma tercihleri (TASK 033): yazı biçimi + meal + günlük hedef.
///
/// Paket bağımsız, immutable. Bunlar AYAR tercihleridir, ibadet geçmişi
/// DEĞİLDİR; okuma oturumu/ilerleme TASK 036'da ayrıca ele alınır.
final class QuranReadingPreferences {
  const QuranReadingPreferences({
    required this.arabicScript,
    required this.translation,
    required this.goal,
    required this.setupCompleted,
  });

  final QuranArabicScript arabicScript;
  final QuranTranslationPreference translation;
  final QuranReadingGoal goal;
  final bool setupCompleted;

  /// Hedef güncellenirken diğer tercihler korunur (TASK 033 kuralı).
  QuranReadingPreferences copyWith({QuranReadingGoal? goal}) =>
      QuranReadingPreferences(
        arabicScript: arabicScript,
        translation: translation,
        goal: goal ?? this.goal,
        setupCompleted: setupCompleted,
      );
}

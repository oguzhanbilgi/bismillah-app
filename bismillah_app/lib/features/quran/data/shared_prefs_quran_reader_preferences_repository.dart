import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı okuyucu görünüm tercihleri (TASK 037).
///
/// Kur'an SETUP anahtarlarına dokunmaz. Enum stabil `name` ile yazılır;
/// bozuk/bilinmeyen değer varsayılana (medium) düşer — crash yok.
final class SharedPrefsQuranReaderPreferencesRepository
    implements QuranReaderPreferencesRepository {
  const SharedPrefsQuranReaderPreferencesRepository();

  static const String _textSizeKey = 'bismillah.quran_reader_arabic_text_size';
  static const String _showTranslationKey =
      'bismillah.quran_reader_show_translation';

  @override
  ResultFuture<QuranArabicTextSize> loadArabicTextSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(_textSizeKey);
      return Result.success(
        QuranArabicTextSize.values.asNameMap()[raw] ??
            QuranArabicTextSize.medium,
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveArabicTextSize(QuranArabicTextSize size) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_textSizeKey, size.name);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<bool> loadShowTranslation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(_showTranslationKey);
      // Bozuk/eksik değer TRUE kabul edilir (TASK 040 — varsayılan açık).
      return Result.success(raw is bool ? raw : true);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveShowTranslation({required bool show}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showTranslationKey, show);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}

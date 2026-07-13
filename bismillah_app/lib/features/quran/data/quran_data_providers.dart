import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kur'an tercih deposunun DI bağlaması: uygulama arayüzü okur, içeride
/// SharedPreferences implementasyonu döner (06 §11 — tek DI mekanizması
/// Riverpod; presentation SharedPreferences görmez).
final quranReadingPreferencesRepositoryProvider =
    Provider<QuranReadingPreferencesRepository>(
      (ref) => const SharedPrefsQuranReadingPreferencesRepository(),
    );

/// Kur'an içerik deposu (TASK 034B): doğrulanmış asset kataloğu, ilk
/// okumadan sonra bellekte cache; ayet metni erişimi TASK 035'te aynı
/// sözleşmeye eklenir. autoDispose DEĞİL — cache uygulama ömrünce yaşar.
final quranContentRepositoryProvider = Provider<QuranContentRepository>(
  (ref) => AssetQuranContentRepository(),
);

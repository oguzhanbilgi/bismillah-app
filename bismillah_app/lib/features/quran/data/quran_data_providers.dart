import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/mp3quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_position_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_verse_bookmark_repository.dart';
import 'package:bismillah_app/features/quran/data/unavailable_quran_audio_session_service.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_position_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_verse_bookmark_repository.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
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

/// Son okuma konumu deposu (TASK 036): cihaz-lokal, SharedPreferences.
final quranReadingPositionRepositoryProvider =
    Provider<QuranReadingPositionRepository>(
      (ref) => const SharedPrefsQuranReadingPositionRepository(),
    );

/// Ayet kaydı deposu (TASK 037): cihaz-lokal, SharedPreferences.
final quranVerseBookmarkRepositoryProvider =
    Provider<QuranVerseBookmarkRepository>(
      (ref) => const SharedPrefsQuranVerseBookmarkRepository(),
    );

/// Okuyucu görünüm tercihleri deposu (TASK 037): cihaz-lokal.
final quranReaderPreferencesRepositoryProvider =
    Provider<QuranReaderPreferencesRepository>(
      (ref) => const SharedPrefsQuranReaderPreferencesRepository(),
    );

/// Türkçe meal deposu (TASK 040): güvenli Firebase callable proxy'si —
/// autoDispose DEĞİL, oturum cache'i uygulama ömrünce yaşar.
///
/// CHECKPOINT 06 Recovery: aktif kaynak paketlenmiş QuranEnc Rowad
/// V1.0.4 asset'idir — tamamen offline. Diyanet callable deposu
/// (`FirebaseDiyanetQuranTranslationRepository`) gelecekteki opsiyonel
/// kaynak olarak INACTIVE durur; aktif akışta callable ÇAĞRILMAZ.
final quranTranslationRepositoryProvider = Provider<QuranTranslationRepository>(
  (ref) => BundledQuranEncTranslationRepository(),
);

/// Kıraat sesi deposu (TASK 041): MP3Quran read 5 — autoDispose DEĞİL,
/// read + timing cache'i oturum boyunca yaşar.
final quranAudioRepositoryProvider = Provider<QuranAudioRepository>(
  (ref) => Mp3QuranAudioRepository(),
);

/// Global Kur'an ses oturumu servisi (TASK 045). Gerçek handler bootstrap
/// override'ı ile enjekte edilir (`AudioService.init` uygulama başına BİR
/// KEZ); override yoksa (ör. widget testleri) platforma dokunmayan sakin
/// unavailable implementasyon döner. autoDispose DEĞİL — oturum ve
/// oynatma reader yaşam döngüsünden bağımsız, uygulama ömrünce yaşar.
final quranAudioSessionServiceProvider = Provider<QuranAudioSessionService>(
  (ref) => UnavailableQuranAudioSessionService(),
);

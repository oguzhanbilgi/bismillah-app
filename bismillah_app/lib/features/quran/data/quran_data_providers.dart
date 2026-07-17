import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_verse_page_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quran_search_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/mp3quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/data/mp3quran_reciter_catalog_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_audio_preferences_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_daily_progress_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_position_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/data/shared_prefs_quran_verse_bookmark_repository.dart';
import 'package:bismillah_app/features/quran/data/unavailable_quran_audio_session_service.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_content_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_daily_progress_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reader_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_position_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reciter_catalog_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_search_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_translation_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_verse_bookmark_repository.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_verse_page_repository.dart';
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

/// Günlük Kur'an ilerleme deposu (TASK 047): cihaz-lokal, gün başına
/// versioned JSON. autoDispose DEĞİL — watchToday akışı ve gün kaydı
/// uygulama ömrünce aynı depo örneğinden yaşar; sync/analytics YOK.
final quranDailyProgressRepositoryProvider =
    Provider<QuranDailyProgressRepository>(
      (ref) => SharedPrefsQuranDailyProgressRepository(
        clock: ref.watch(clockProvider),
      ),
    );

/// Ayet → Mushaf sayfası eşlemesi (TASK 047): doğrulanmış Tanzil sayfa
/// metadata'sından üretilen asset — autoDispose DEĞİL, cache uygulama
/// ömrünce yaşar.
final quranVersePageRepositoryProvider = Provider<QuranVersePageRepository>(
  (ref) => AssetQuranVersePageRepository(),
);

/// Timed MP3Quran kâri kataloğu (TASK 049): resmî reads endpoint'i +
/// 7 günlük yerel cache + her koşulda read 5 fallback. autoDispose
/// DEĞİL — bellek cache oturum boyunca yaşar.
final quranReciterCatalogRepositoryProvider =
    Provider<QuranReciterCatalogRepository>(
      (ref) =>
          Mp3QuranReciterCatalogRepository(clock: ref.watch(clockProvider)),
    );

/// Cihaz-lokal kâri tercihi (TASK 049): yalnız seçili readId saklanır.
/// autoDispose DEĞİL — watch akışı uygulama ömrünce aynı örnekten yaşar.
final quranAudioPreferencesRepositoryProvider =
    Provider<QuranAudioPreferencesRepository>(
      (ref) => SharedPrefsQuranAudioPreferencesRepository(),
    );

/// Tamamen offline Kur'an araması (TASK 048): normalize indeks asset'i +
/// mevcut içerik/meal depoları. autoDispose DEĞİL — indeks cache'i
/// oturum boyunca yaşar; ağ/analytics YOK.
final quranSearchRepositoryProvider = Provider<QuranSearchRepository>(
  (ref) => BundledQuranSearchRepository(
    contentRepository: ref.watch(quranContentRepositoryProvider),
    translationRepository: ref.watch(quranTranslationRepositoryProvider),
  ),
);

/// Global Kur'an ses oturumu servisi (TASK 045). Gerçek handler bootstrap
/// override'ı ile enjekte edilir (`AudioService.init` uygulama başına BİR
/// KEZ); override yoksa (ör. widget testleri) platforma dokunmayan sakin
/// unavailable implementasyon döner. autoDispose DEĞİL — oturum ve
/// oynatma reader yaşam döngüsünden bağımsız, uygulama ömrünce yaşar.
final quranAudioSessionServiceProvider = Provider<QuranAudioSessionService>(
  (ref) => UnavailableQuranAudioSessionService(),
);

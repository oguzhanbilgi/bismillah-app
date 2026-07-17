import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_daily_reading_progress.dart';

/// Günlük Kur'an okuma ilerlemesi lokal veri sözleşmesi (TASK 047).
///
/// Veri YALNIZ cihazda yaşar: Firestore shadow, sync queue veya
/// SyncOperation ÜRETİLMEZ; analytics'e hiçbir şey gitmez. "Bugün"
/// kullanıcının yazım anındaki YEREL günüdür; geçmiş dateKey kayıtları
/// timezone değişiminde yeniden yazılmaz.
abstract interface class QuranDailyProgressRepository {
  /// Günün kaydı; yoksa `null`. Bozuk kayıt kontrollü temizlenir ve
  /// `null` döner — diğer günler etkilenmez, crash yok.
  ResultFuture<QuranDailyReadingProgress?> loadDay(String localDateKey);

  ResultFuture<void> saveDay(QuranDailyReadingProgress progress);

  /// Bugünün kaydındaki her başarılı değişiklikte güncel kaydı yayınlar
  /// (broadcast). İlk değer için [loadDay] kullanılır.
  Stream<QuranDailyReadingProgress> watchToday();

  /// [startDateKey]..[endDateKey] (dahil) aralığındaki MEVCUT kayıtlar,
  /// eskiden yeniye. Kaydı olmayan günler listede YER ALMAZ.
  ResultFuture<List<QuranDailyReadingProgress>> loadRange(
    String startDateKey,
    String endDateKey,
  );

  /// Bugüne aktif okuma aktivitesi ekler: süre toplanır, ayet/sayfa
  /// kümeleri UNION olur, son konum güncellenir. Tek çağrıda toplu
  /// (debounced) persist için kullanılır.
  ResultFuture<QuranDailyReadingProgress> recordReadingActivity({
    int activeSeconds = 0,
    Set<String> viewedVerseKeys = const {},
    Set<int> viewedPageNumbers = const {},
    int? lastChapterId,
    String? lastVerseKey,
  });

  /// Bugüne aktif okuma süresi ekler (saniye).
  ResultFuture<QuranDailyReadingProgress> recordActiveReading(int seconds);

  /// Ayeti bugün için bir kez "anlamlı görüntülendi" işaretler.
  ResultFuture<QuranDailyReadingProgress> markVerseMeaningfullyViewed(
    String verseKey,
  );

  /// Mushaf sayfasını bugün için bir kez "anlamlı görüntülendi" işaretler.
  ResultFuture<QuranDailyReadingProgress> markPageMeaningfullyViewed(
    int pageNumber,
  );

  /// Bozuk gün kaydını kontrollü siler — diğer günler korunur.
  ResultFuture<void> clearCorruptRecord(String localDateKey);
}

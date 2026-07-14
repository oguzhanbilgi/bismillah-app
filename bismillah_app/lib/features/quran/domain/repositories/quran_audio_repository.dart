import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Kıraat sesi sözleşmesi (TASK 041) — içerik/meal depolarından AYRI
/// sorumluluk. Timing verisi doğrulanmadan asla dönmez.
abstract interface class QuranAudioRepository {
  /// Surenin kıraati: 1'den [expectedVerseCount]'a kadar TÜM ayetlerin
  /// zamanı doğrulanır; eksik/duplicate/bozuk timing kontrollü failure
  /// üretir. Başarılı sonuçlar oturum boyunca bellekte cache edilir.
  ResultFuture<QuranChapterRecitation> getChapterRecitation(
    int chapterId,
    int expectedVerseCount,
  );

  /// Yalnız ilgili surenin cache'ini düşürür (tekrar dene akışı).
  void invalidateChapter(int chapterId);
}

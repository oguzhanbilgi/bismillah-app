import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Kıraat sesi sözleşmesi (TASK 041/049) — içerik/meal depolarından AYRI
/// sorumluluk. Timing verisi doğrulanmadan asla dönmez; TASK 049 ile
/// kaynak (kâri) bağımsızdır — timing ve MP3 URL'si verilen [source]
/// üzerinden çözülür.
abstract interface class QuranAudioRepository {
  /// Surenin verilen kaynaktaki kıraati: 1'den [expectedVerseCount]'a
  /// kadar TÜM ayetlerin zamanı doğrulanır; eksik/duplicate/bozuk timing
  /// kontrollü failure üretir. Başarılı sonuçlar (readId, chapterId)
  /// anahtarıyla oturum boyunca bellekte cache edilir — kâri değişimi
  /// diğer kârilerin cache'ini BOZMAZ.
  ResultFuture<QuranChapterRecitation> getChapterRecitation(
    int chapterId,
    int expectedVerseCount,
    QuranRecitationSource source,
  );

  /// Yalnız ilgili (readId, chapterId) cache'ini düşürür (tekrar dene).
  void invalidateChapter(int chapterId, int readId);
}

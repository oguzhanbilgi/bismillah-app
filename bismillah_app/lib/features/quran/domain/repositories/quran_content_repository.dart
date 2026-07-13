import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';

/// Kur'an içerik sözleşmesi (TASK 034/034B/035) — paket bağımsız; UI
/// kaynak formatını (JSON/asset/DB) hiçbir zaman görmez. Ayet metni her
/// zaman kaynak künyesiyle taşınır ("no source, no render").
abstract interface class QuranContentRepository {
  /// Doğrulanmış 114 surelik katalog, id (mushaf) sırasına dizili.
  /// Eksik/bozuk katalog kontrollü failure üretir — crash yok.
  ResultFuture<List<QuranChapter>> getChapters();

  /// Tek sure; tanınmayan id `null` döner. Cache üzerinden çalışır.
  ResultFuture<QuranChapter?> getChapter(int id);

  /// Bir surenin doğrulanmış Uthmani ayetleri, ayet numarasına sıralı.
  /// Geçersiz chapterId veya eksik/duplicate/bozuk ayet kontrollü
  /// failure üretir — crash yok.
  ResultFuture<List<QuranVerse>> getVersesForChapter(int chapterId);

  /// "1:1" biçimli anahtarla tek ayet; tanınmayan/bozuk anahtar `null`.
  ResultFuture<QuranVerse?> getVerse(String verseKey);
}

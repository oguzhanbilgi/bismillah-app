import 'package:bismillah_app/core/contracts/contracts.dart';

/// Doğrulanmış ayet → Mushaf sayfası eşlemesi sözleşmesi (TASK 047).
///
/// Kaynak Tanzil'in 604 sayfalık Medine Mushafı metadata'sıdır — sayfa
/// numarası TAHMİN EDİLMEZ, formülle üretilmez. Eşleme doğrulanamazsa
/// kontrollü failure döner; sayfa hedefi dakikaya sessizce dönüştürülmez.
abstract interface class QuranVersePageRepository {
  /// Surenin `verseKey → pageNumber` eşlemesi (1–604). Eşleme yüklenemez
  /// veya bütünlük doğrulaması geçmezse failure.
  ResultFuture<Map<String, int>> pagesForChapter(int chapterId);
}

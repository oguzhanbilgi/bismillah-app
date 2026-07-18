import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_search_result.dart';

/// Tamamen offline Kur'an arama sözleşmesi (TASK 048).
///
/// Kaynak yalnız doğrulanmış bundled asset'lerdir; ağ/AI/analytics
/// YOKTUR, sorgular hiçbir yere gönderilmez ve diske yazılmaz. Bozuk
/// indeks kontrollü failure döner — reader/meal/ses etkilenmez.
abstract interface class QuranSearchRepository {
  /// Deterministik sıralı, sınırlanmış arama yanıtı (en fazla 10 sure +
  /// 50 ayet). Boş/çok kısa sorgu boş yanıt döner.
  ResultFuture<QuranSearchResponse> search(String query);

  /// `2:255`, `2/255`, `2 255` biçimli referansı çözer; geçersiz veya
  /// aralık dışıysa `null` (crash yok).
  ResultFuture<QuranVerseSearchTarget?> resolveReference(String input);
}

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';

/// Türkçe meal sözleşmesi (TASK 040) — içerik kataloğundan AYRI
/// sorumluluk; `QuranContentRepository` translation için GENİŞLETİLMEZ.
///
/// İmplementasyon meali yalnız güvenli backend proxy'sinden alır; API
/// tokenı istemcide BULUNMAZ.
abstract interface class QuranTranslationRepository {
  /// Surenin doğrulanmış meali. Başarılı sonuçlar uygulama oturumu
  /// boyunca bellekte cache edilir — aynı sure için tekrar çağrı yapılmaz.
  ResultFuture<QuranChapterTranslation> getChapterTranslation(int chapterId);

  /// Yalnız ilgili surenin cache'ini düşürür (tekrar dene akışı).
  void invalidateChapter(int chapterId);
}

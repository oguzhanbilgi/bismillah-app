import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';

/// Okuyucu görünüm tercihleri sözleşmesi (TASK 037) — Kur'an SETUP
/// tercihlerinden (script/meal/hedef) AYRIDIR, onlara dokunmaz.
abstract interface class QuranReaderPreferencesRepository {
  /// Bozuk/bilinmeyen saklanmış değer varsayılana (medium) düşer.
  ResultFuture<QuranArabicTextSize> loadArabicTextSize();

  ResultFuture<void> saveArabicTextSize(QuranArabicTextSize size);
}

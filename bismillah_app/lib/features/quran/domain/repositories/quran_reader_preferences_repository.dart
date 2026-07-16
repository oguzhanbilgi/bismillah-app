import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';

/// Okuyucu görünüm tercihleri sözleşmesi (TASK 037/040) — Kur'an SETUP
/// tercihlerinden (script/meal/hedef) AYRIDIR, onlara dokunmaz.
abstract interface class QuranReaderPreferencesRepository {
  /// Bozuk/bilinmeyen saklanmış değer varsayılana (medium) düşer.
  ResultFuture<QuranArabicTextSize> loadArabicTextSize();

  ResultFuture<void> saveArabicTextSize(QuranArabicTextSize size);

  /// Türkçe meal gösterimi (TASK 040). Bozuk/eksik değer `true` kabul
  /// edilir — varsayılan meal AÇIK.
  ResultFuture<bool> loadShowTranslation();

  ResultFuture<void> saveShowTranslation({required bool show});

  /// Tt okuma ayarları keşif göstergesi görüldü mü (TASK 044).
  /// Eksik/bozuk değer GÖRÜLMEMİŞ (`false`) kabul edilir.
  ResultFuture<bool> loadSettingsHintSeen();

  ResultFuture<void> saveSettingsHintSeen({required bool seen});
}

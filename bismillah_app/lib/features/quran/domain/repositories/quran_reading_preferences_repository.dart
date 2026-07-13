import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_preferences.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';

/// Kur'an okuma tercihleri sözleşmesi (TASK 033) — TASK 032'deki yalnız-
/// hedef sözleşmesinin genelleştirilmişi. Bunlar AYAR tercihleridir;
/// geniş `QuranProgressRepository` sözleşmesi oturum/yer imi görevleri
/// içindir — burada açılmaz.
abstract interface class QuranReadingPreferencesRepository {
  /// `null` = kurulum tamamlanmamış (bozuk/eksik veri dahil — crash yok).
  ResultFuture<QuranReadingPreferences?> load();

  ResultFuture<void> save(QuranReadingPreferences preferences);

  /// TASK 032'nin eski sayfa hedefi anahtarından kurulum ön-seçimi;
  /// yoksa/bozuksa `null` (normal kuruluma geçilir, migration YOK).
  ResultFuture<QuranReadingGoal?> loadLegacyPageGoal();
}

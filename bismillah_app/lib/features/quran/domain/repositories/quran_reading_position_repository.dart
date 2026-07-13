import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';

/// Son okuma konumu sözleşmesi (TASK 036) — cihaz-lokal ayar verisi;
/// Firebase/Drift/SyncOperation YOK.
abstract interface class QuranReadingPositionRepository {
  /// `null` = kayıtlı konum yok (bozuk/eksik veri dahil — crash yok).
  ResultFuture<QuranReadingPosition?> load();

  ResultFuture<void> save(QuranReadingPosition position);

  ResultFuture<void> clear();
}

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';

/// Yerel öğrenme ilerlemesi sözleşmesi (TASK 056 §11).
///
/// Cihaz-lokaldir; Firebase GEREKTİRMEZ. Dil değişimi ilerlemeyi
/// ETKİLEMEZ — kayıtlar locale'den bağımsız içerik id'leriyle tutulur.
abstract interface class LearningProgressRepository {
  ResultFuture<LearningProgress> load();

  /// Kaydetme durumunu değiştirir ve GÜNCEL durumu döner.
  ResultFuture<LearningProgress> toggleBookmark(String articleId);

  /// Tamamlanma durumunu değiştirir ve GÜNCEL durumu döner.
  ResultFuture<LearningProgress> toggleCompleted(String articleId);

  /// "Kaldığın yerden devam" için son konumu yazar.
  ResultFuture<LearningProgress> noteOpened(
    String articleId, {
    int? sectionIndex,
  });
}

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_index.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';

/// Resmî cevap / fetva dizini için TEK okuma sözleşmesi (TASK 092
/// foundation).
///
/// TASK 092 bu sözleşmeyi HİÇBİR tüketiciye BAĞLAMAZ: Assistant
/// retrieval/sıralama entegrasyonu TASK 093'ün kapsamındadır — bu depo
/// şimdilik hiçbir yerden çağrılmaz (bkz. TASK 092 kapsam notu). Depo
/// [LearningKnowledgeRepository] ile AYNI idiomu izler: YALNIZ
/// `ReviewStatus.published` kayıtlar `getPublished`/`getById` ile dışa
/// açılır.
abstract interface class OfficialAnswerRepository {
  /// Bir locale için TÜM dizin (yayınlanmamış kayıtlar dahil — dahili
  /// denetim/test amaçlıdır, uygulama tüketimi için değildir).
  ResultFuture<OfficialAnswerIndex> getIndex(String locale);

  /// Aktif locale'deki YALNIZ yayınlanmış kayıtlar.
  ResultFuture<List<OfficialAnswerRecord>> getPublished(String locale);

  /// Id ile tek kayıt. Kayıt bulunamıyorsa VEYA yayınlanmamışsa `null`
  /// döner — pending/draft içerik bu yoldan asla sızmaz.
  ResultFuture<OfficialAnswerRecord?> getById(String locale, String id);
}

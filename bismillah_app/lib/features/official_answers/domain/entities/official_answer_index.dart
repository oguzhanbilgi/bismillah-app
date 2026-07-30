import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';

/// Bir locale için resmî cevap / fetva dizini (TASK 092 foundation).
///
/// Sıra, kaynak JSON dosyasının sırasıdır; yinelenen id REDDEDİLİR — aynı
/// disiplin Learn kataloglarında da uygulanır (TASK 056 §7).
final class OfficialAnswerIndex {
  OfficialAnswerIndex({
    required this.schemaVersion,
    required this.locale,
    required List<OfficialAnswerRecord> answers,
  }) : answers = List.unmodifiable(answers) {
    if (locale.trim().isEmpty) {
      throw ArgumentError.value(locale, 'locale', 'Locale zorunludur');
    }
    final seenIds = <String>{};
    for (final answer in this.answers) {
      if (!seenIds.add(answer.id)) {
        throw ArgumentError.value(
          answer.id,
          'id',
          'Yinelenen resmî cevap id: ${answer.id}',
        );
      }
    }
  }

  final int schemaVersion;
  final String locale;

  /// Kaynak dosya sırasıyla TÜM kayıtlar (yayınlanmamış olanlar dahil).
  final List<OfficialAnswerRecord> answers;

  /// YALNIZ yayınlanmış VE resmî cevap yayın kapısını GEÇEN kayıtlar.
  ///
  /// Kapı BİLE İSTEYE hem kayıt kurucusunda (bkz. [OfficialAnswerRecord])
  /// HEM DE burada, alım (retrieval) sırasında zorlanır: ileride bir
  /// `copyWith`/`fromJson` kısayolu kurucuyu atlayarak kapıyı geçmemiş bir
  /// kaydı üretse bile, bu erişim noktası onu asla dışa sızdırmaz.
  List<OfficialAnswerRecord> get published => answers
      .where((a) => a.isPublished && a.satisfiesOfficialAnswerGate)
      .toList(growable: false);
}

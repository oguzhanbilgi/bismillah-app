import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Sırada çalınacak TEK ayet parçası (TASK 095A) — paket bağımsız.
///
/// Bir sure tek bir MP3'tür; her ayet o dosyanın bir zaman aralığıdır.
/// Parça, kaynağı ve aralığı taşır; kesme sınırları **doğrulanmış
/// timing'den birebir gelir** — kısaltma/kırpma yapılmaz, dolayısıyla
/// kıraatin başı veya sonu kesilemez.
final class QuranAudioClip {
  const QuranAudioClip({
    required this.verseNumber,
    required this.url,
    required this.start,
    required this.end,
  });

  final int verseNumber;
  final String url;
  final Duration start;
  final Duration end;

  Duration get duration => end - start;

  @override
  bool operator ==(Object other) =>
      other is QuranAudioClip &&
      other.verseNumber == verseNumber &&
      other.url == url &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(verseNumber, url, start, end);
}

/// Oynatma sırası (TASK 095A) — SAF, test edilebilir.
///
/// ## Neden var
///
/// Önceki akış her ayet için ayrı bir yükleme isteği kuruyordu: ayet
/// bitince uygulama durup yeni bir clip yüklüyor, tampon yeniden doluyor
/// ve arada gözle görülür bir boşluk oluşuyordu. Sıra **oynatmadan önce
/// bir kez** kurulur; oynatıcı kendi içinde bir sonraki parçaya geçer,
/// dolayısıyla uygulama kaynaklı geçiş gecikmesi kalmaz.
///
/// Sıra zamanlama üretmez, tahmin etmez ve sessizlik kırpmaz — yalnız
/// doğrulanmış `verseTimings` kayıtlarını sıraya dizer.
final class QuranAudioQueue {
  const QuranAudioQueue._(this.clips);

  /// Ayet numarasına göre ARTAN sırada parçalar.
  final List<QuranAudioClip> clips;

  int get length => clips.length;

  bool get isEmpty => clips.isEmpty;

  /// [index] konumundaki ayet numarası; aralık dışında `null`.
  int? verseAt(int index) =>
      index >= 0 && index < clips.length ? clips[index].verseNumber : null;

  /// [verseNumber] ayetinin sıradaki konumu; sırada yoksa `null`.
  int? indexOfVerse(int verseNumber) {
    for (var i = 0; i < clips.length; i++) {
      if (clips[i].verseNumber == verseNumber) {
        return i;
      }
    }
    return null;
  }

  /// Surenin TAMAMI için sıra — kesintisiz mod.
  ///
  /// Sıra her zaman **1. ayetten** kurulur (başlangıç ayeti sonradan
  /// seçilir), böylece kullanıcı geriye de gidebilir ve tüm sure zaten
  /// hazırlanmış olur. Zamanlaması olmayan ayet sıraya girmez.
  static QuranAudioQueue forChapter(QuranChapterRecitation recitation) {
    final timings = [...recitation.verseTimings]
      ..sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
    return QuranAudioQueue._([
      for (final timing in timings) _clipOf(recitation, timing),
    ]);
  }

  /// Yalnız tek ayet için sıra — tek ayet modu.
  ///
  /// Sırada tek parça olduğu için oynatıcı kendiliğinden sonraki ayete
  /// GEÇEMEZ; mevcut "tek ayet bitince oturum sonlanır" davranışı yapıdan
  /// gelir, ek bir kontrol gerektirmez.
  static QuranAudioQueue forSingleVerse(
    QuranChapterRecitation recitation,
    int verseNumber,
  ) {
    final timing = recitation.timingFor(verseNumber);
    return QuranAudioQueue._([if (timing != null) _clipOf(recitation, timing)]);
  }

  static QuranAudioClip _clipOf(
    QuranChapterRecitation recitation,
    QuranVerseTiming timing,
  ) => QuranAudioClip(
    verseNumber: timing.verseNumber,
    url: recitation.audioUrl,
    start: timing.start,
    end: timing.end,
  );
}

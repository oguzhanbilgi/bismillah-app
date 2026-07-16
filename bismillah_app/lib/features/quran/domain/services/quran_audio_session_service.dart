import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Ayet sesi ekran/oturum durumu (TASK 041/042/045) — paket bağımsız.
enum QuranVerseAudioStatus { idle, loading, playing, paused, error }

/// Oynatma modu (TASK 042): tek ayet veya kesintisiz sure.
enum QuranAudioPlaybackMode { singleVerse, continuousChapter }

/// Global ses oturumunun TEK gerçek durumu (TASK 045): hem reader UI hem
/// sistem bildirimi aynı kaynaktan türetilir — ikinci "gerçek state" YOK.
final class QuranVerseAudioState {
  const QuranVerseAudioState({
    this.activeChapterId,
    this.activeVerseKey,
    this.activeVerseNumber,
    this.playbackMode,
    this.status = QuranVerseAudioStatus.idle,
    this.errorVerseKey,
    this.chapterAudioFailed = false,
    this.serviceUnavailable = false,
    this.sourceReady = false,
    this.totalVerseCount,
  });

  /// Aktif oturumun suresi; hatada başarısız olan sure. Reader yalnız
  /// KENDİ suresine ait durumu paneline yansıtır (TASK 045).
  final int? activeChapterId;

  /// Şu an yüklenen/çalan/duraklatılan ayet.
  final String? activeVerseKey;
  final int? activeVerseNumber;

  /// Aktif oynatmanın modu; boşta `null`.
  final QuranAudioPlaybackMode? playbackMode;

  final QuranVerseAudioStatus status;

  /// Son hata alan ayet — sakin hata YALNIZ bu ayette gösterilir.
  final String? errorVerseKey;

  /// "Sureyi dinle" akışı hata aldı (panel sakin hata + tekrar dene).
  final bool chapterAudioFailed;

  /// AudioService başlatılamadı (TASK 045): reader Arapça/meal ile çalışır,
  /// panel yalnız sakin "ses hizmeti başlatılamadı" mesajı gösterir.
  final bool serviceUnavailable;

  /// En az bir ses başarıyla hazırlandı mı (kaynak etiketi görünürlüğü).
  final bool sourceReady;

  /// Yüklü surenin ayet sayısı (panel "Ayet X / Y" ve sınırlar için).
  final int? totalVerseCount;

  bool get hasPrevious => activeVerseNumber != null && activeVerseNumber! > 1;

  bool get hasNext =>
      activeVerseNumber != null &&
      totalVerseCount != null &&
      activeVerseNumber! < totalVerseCount!;
}

/// "Ayet X / Y" biçimli, yerelleşmiş etiket üreticisi — BuildContext YOK;
/// bildirim metadata'sı için gerekli string'ler istekle birlikte geçilir.
typedef QuranVerseOfLabelBuilder = String Function(int current, int total);

/// Bildirim/kilit ekranı metadata'sı için doğrulanmış görüntü metinleri
/// (TASK 045). API'den gelen ham metin veya ayet/meal içeriği TAŞINMAZ.
final class QuranAudioDisplayInfo {
  const QuranAudioDisplayInfo({
    required this.chapterDisplayName,
    required this.reciterName,
    required this.rewayaName,
    required this.albumName,
    required this.verseOfLabel,
  });

  final String chapterDisplayName;
  final String reciterName;
  final String rewayaName;
  final String albumName;
  final QuranVerseOfLabelBuilder verseOfLabel;
}

/// Oynatma isteği (TASK 045): servis oynatmaya başlamadan önce sure, tüm
/// ayet zamanlamaları ve görüntü metinlerinin tamamını alır — arka planda
/// reader'a/BuildContext'e bağımlılık kalmaz.
final class QuranAudioSessionRequest {
  QuranAudioSessionRequest({
    required this.recitation,
    required this.totalVerseCount,
    required this.startVerseNumber,
    required this.display,
  }) {
    if (recitation.timingFor(startVerseNumber) == null) {
      throw ArgumentError.value(
        startVerseNumber,
        'startVerseNumber',
        'başlangıç ayetinin zamanlaması bulunmalı',
      );
    }
  }

  final QuranChapterRecitation recitation;
  final int totalVerseCount;
  final int startVerseNumber;
  final QuranAudioDisplayInfo display;
}

/// Global Kur'an ses oturumu sözleşmesi (TASK 045) — paket bağımsız:
/// audio_service/just_audio/Flutter/HTTP İTHAL ETMEZ.
///
/// Uygulama süresince TEK oturum yaşar; reader ekranları yalnız durumu
/// izler ve komut gönderir. Reader kapanınca ses DEVAM eder; oturum yalnız
/// stop, tek ayetin tamamlanması, surenin son ayeti veya kalıcı hata ile
/// sonlanır.
abstract interface class QuranAudioSessionService {
  /// Mevcut oturumu durdurup yalnız seçilen ayeti oynatır; tamamlanınca
  /// sonraki ayete GEÇMEZ, oturum düzgün sonlanır.
  Future<void> playSingleVerse(QuranAudioSessionRequest request);

  /// Mevcut oturumu durdurup verilen ayetten kesintisiz oynatır; clip
  /// bitince servis sonraki ayete geçer, son ayette oturum sonlanır.
  Future<void> playContinuousChapter(QuranAudioSessionRequest request);

  Future<void> pause();

  Future<void> resume();

  /// Oynatmayı tamamen durdurur ve sistem oturumunu/bildirimi temizler.
  Future<void> stop();

  /// Önceki ayet; ilk ayette yok sayılır.
  Future<void> skipToPrevious();

  /// Sonraki ayet; son ayette yok sayılır.
  Future<void> skipToNext();

  /// Durum akışı (broadcast); mevcut değer için [currentState].
  Stream<QuranVerseAudioState> watchState();

  QuranVerseAudioState get currentState;
}

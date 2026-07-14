import 'package:bismillah_app/features/quran/domain/entities/quran_chapter_recitation.dart';

/// Oynatıcı durumu (TASK 041) — paket bağımsız.
enum QuranAudioPlaybackStatus { idle, loading, playing, paused, completed }

/// Ayet bazlı ses oynatıcı sözleşmesi (TASK 041).
///
/// Presentation just_audio GÖRMEZ — yalnız bu arayüzü kullanır. Reader
/// başına TEK oynatıcı yaşar; aynı surede ayet değişince MP3 yeniden
/// yüklenmez, sure değişince yeni URL yüklenir.
abstract interface class QuranVerseAudioPlayer {
  /// Sure MP3'ünü hazırlar; aynı sure zaten yüklüyse hiçbir şey yapmaz.
  Future<void> loadChapter({required String audioUrl, required int chapterId});

  /// Yüklü suredeki tek ayeti (clip) baştan oynatır.
  Future<void> playVerse(QuranVerseTiming timing);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> dispose();

  /// Oynatma durumu akışı (kesinti/odak kaybı duraklamaları dahil).
  Stream<QuranAudioPlaybackStatus> get statusStream;
}

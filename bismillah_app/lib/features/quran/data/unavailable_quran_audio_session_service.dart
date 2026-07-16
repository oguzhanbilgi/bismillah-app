import 'dart:async';

import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';

/// AudioService başlatılamadığında devreye giren sakin fallback
/// (TASK 045): uygulama tamamen açılır, Kur'an reader Arapça/meal ile
/// çalışır; yalnız ses aksiyonları `serviceUnavailable` işaretli sakin
/// hata durumu yayınlar. Hiçbir platform kanalına DOKUNMAZ.
final class UnavailableQuranAudioSessionService
    implements QuranAudioSessionService {
  final StreamController<QuranVerseAudioState> _stateController =
      StreamController<QuranVerseAudioState>.broadcast();

  QuranVerseAudioState _current = const QuranVerseAudioState();

  void _emit(QuranVerseAudioState state) {
    _current = state;
    _stateController.add(state);
  }

  @override
  QuranVerseAudioState get currentState => _current;

  @override
  Stream<QuranVerseAudioState> watchState() => _stateController.stream;

  @override
  Future<void> playSingleVerse(QuranAudioSessionRequest request) async {
    _emit(
      QuranVerseAudioState(
        activeChapterId: request.recitation.chapterId,
        status: QuranVerseAudioStatus.error,
        errorVerseKey:
            '${request.recitation.chapterId}:${request.startVerseNumber}',
        serviceUnavailable: true,
      ),
    );
  }

  @override
  Future<void> playContinuousChapter(QuranAudioSessionRequest request) async {
    _emit(
      QuranVerseAudioState(
        activeChapterId: request.recitation.chapterId,
        status: QuranVerseAudioStatus.error,
        chapterAudioFailed: true,
        serviceUnavailable: true,
      ),
    );
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {
    _emit(const QuranVerseAudioState());
  }

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> skipToNext() async {}
}

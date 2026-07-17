import 'dart:async';

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_audio_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı ses tercihi deposu (TASK 049).
///
/// Yalnız seçili read kimliği saklanır — kullanıcı verisi/UID/token YOK,
/// tercih cihaz dışına ÇIKMAZ. Eksik/bozuk değer varsayılan read 5'e
/// düşer; kayıt hatasında eski seçim korunur.
final class SharedPrefsQuranAudioPreferencesRepository
    implements QuranAudioPreferencesRepository {
  SharedPrefsQuranAudioPreferencesRepository();

  static const String _key = 'bismillah.quran_audio_selected_read_id';

  final StreamController<int> _controller = StreamController<int>.broadcast();

  @override
  Future<int> loadSelectedReadId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.get(_key);
      return value is int && value >= 1
          ? value
          : QuranAudioPreferencesRepository.defaultReadId;
    } on Exception {
      return QuranAudioPreferencesRepository.defaultReadId;
    }
  }

  @override
  ResultFuture<void> saveSelectedReadId(int readId) async {
    if (readId < 1) {
      return const Result.failure(StorageFailure());
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, readId);
      _controller.add(readId);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  Stream<int> watchSelectedReadId() => _controller.stream;
}

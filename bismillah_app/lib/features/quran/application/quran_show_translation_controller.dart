import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Türkçe meali göster" tercihi (TASK 040). Varsayılan AÇIK; bozuk/
/// okunamayan değer true'ya düşer. Seçim anında uygulanır, yerel kayıt
/// arkada koşar (kayıt hatası görünümü geri almaz).
final quranShowTranslationControllerProvider =
    AsyncNotifierProvider.autoDispose<QuranShowTranslationController, bool>(
      QuranShowTranslationController.new,
    );

final class QuranShowTranslationController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .loadShowTranslation();
    return result.fold(onSuccess: (show) => show, onFailure: (_) => true);
  }

  Future<void> setShow({required bool show}) async {
    state = AsyncData(show);
    await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .saveShowTranslation(show: show);
  }

  Future<void> toggle() => setShow(show: !(state.value ?? true));
}

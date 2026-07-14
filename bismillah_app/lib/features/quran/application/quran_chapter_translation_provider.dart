import 'package:bismillah_app/features/quran/application/quran_show_translation_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Surenin Diyanet meali (TASK 040). `null` = meal tercihi KAPALI
/// (callable ÇAĞRILMAZ); hata = kontrollü translation failure — Arapça
/// okuyucu bundan etkilenmez. Depo cache'i sayesinde aynı sure için
/// oturum boyunca tek callable çağrısı yapılır.
final quranChapterTranslationProvider = FutureProvider.autoDispose
    .family<QuranChapterTranslation?, int>((ref, chapterId) async {
      final show = await ref.watch(
        quranShowTranslationControllerProvider.future,
      );
      if (!show) {
        return null;
      }
      final result = await ref
          .watch(quranTranslationRepositoryProvider)
          .getChapterTranslation(chapterId);
      return result.fold(
        onSuccess: (translation) => translation,
        onFailure: (failure) => throw failure,
      );
    });

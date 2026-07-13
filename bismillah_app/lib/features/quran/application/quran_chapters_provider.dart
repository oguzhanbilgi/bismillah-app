import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sure kataloğunun SALT-OKUNUR görünümü (TASK 034B).
///
/// Hata = kontrollü katalog okuma sorunu (UI tekrar dene sunar,
/// `ref.invalidate` ile yenilenir; depo cache'i başarılı ilk okumadan
/// sonra bellekte kalır).
final quranChaptersProvider = FutureProvider.autoDispose<List<QuranChapter>>((
  ref,
) async {
  final result = await ref.watch(quranContentRepositoryProvider).getChapters();
  return result.fold(
    onSuccess: (chapters) => chapters,
    onFailure: (failure) => throw failure,
  );
});

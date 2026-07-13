import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ayet kaydı hata türü — localization mesajı seçimi için.
enum QuranBookmarkFailure { save, remove }

/// Ayet kaydı ekran durumu (TASK 037). Yükleme hatası sessizce boş sete
/// düşer — reader ASLA kapanmaz; kayıt hatası sakin bir bayraktır.
final class QuranVerseBookmarksState {
  const QuranVerseBookmarksState({
    required this.bookmarkedKeys,
    this.lastFailure,
  });

  final Set<String> bookmarkedKeys;

  /// Son dokunuşun hatası; başarılı dokunuşta temizlenir.
  final QuranBookmarkFailure? lastFailure;

  bool isBookmarked(String verseKey) => bookmarkedKeys.contains(verseKey);
}

/// Ayet kaydı controller'ı (TASK 037).
///
/// UI anında güncellenir (iyimser), kalıcı yazım arkada koşar; hata
/// durumunda durum geri alınır ve sakin mesaj bayrağı kalkar. Ayet
/// başına in-flight koruması hızlı/çift dokunuşta duplicate üretmez.
final quranVerseBookmarksControllerProvider =
    AsyncNotifierProvider.autoDispose<
      QuranVerseBookmarksController,
      QuranVerseBookmarksState
    >(QuranVerseBookmarksController.new);

final class QuranVerseBookmarksController
    extends AsyncNotifier<QuranVerseBookmarksState> {
  final Set<String> _inFlight = {};

  @override
  Future<QuranVerseBookmarksState> build() async {
    final result = await ref
        .read(quranVerseBookmarkRepositoryProvider)
        .loadBookmarkedVerseKeys();
    return QuranVerseBookmarksState(
      // Okuma hatası sakin boş sete düşer — kayıt özelliği o an devre
      // dışı görünür ama okuma deneyimi sürer.
      bookmarkedKeys: result.fold(
        onSuccess: (keys) => keys,
        onFailure: (_) => const <String>{},
      ),
    );
  }

  Future<void> toggle(String verseKey) async {
    final current = state.value;
    if (current == null || !_inFlight.add(verseKey)) {
      return; // hızlı çift dokunuş — önceki yazım bitmeden yenisi açılmaz
    }
    final willBookmark = !current.bookmarkedKeys.contains(verseKey);
    final updatedKeys = willBookmark
        ? {...current.bookmarkedKeys, verseKey}
        : current.bookmarkedKeys.where((k) => k != verseKey).toSet();
    // İyimser güncelleme: seçili durum anında yansır.
    state = AsyncData(QuranVerseBookmarksState(bookmarkedKeys: updatedKeys));

    final result = await ref
        .read(quranVerseBookmarkRepositoryProvider)
        .setBookmarked(verseKey, bookmarked: willBookmark);
    _inFlight.remove(verseKey);

    final latest = state.value;
    if (latest == null) {
      return;
    }
    result.fold(
      onSuccess: (_) {},
      onFailure: (_) {
        // Geri al + sakin hata bayrağı (mesaj seçimi eylem yönüne göre).
        state = AsyncData(
          QuranVerseBookmarksState(
            bookmarkedKeys: willBookmark
                ? latest.bookmarkedKeys.where((k) => k != verseKey).toSet()
                : {...latest.bookmarkedKeys, verseKey},
            lastFailure: willBookmark
                ? QuranBookmarkFailure.save
                : QuranBookmarkFailure.remove,
          ),
        );
      },
    );
  }
}

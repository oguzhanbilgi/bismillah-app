import 'package:bismillah_app/core/contracts/contracts.dart';

/// Ayet kaydı sözleşmesi (TASK 037) — cihaz-lokal; Firebase/Drift/
/// SyncOperation YOK. Anahtarlar stabil "chapterId:verseNumber"
/// biçimindedir; bozuk saklanmış değerler okunurken göz ardı edilir.
abstract interface class QuranVerseBookmarkRepository {
  ResultFuture<Set<String>> loadBookmarkedVerseKeys();

  ResultFuture<bool> isBookmarked(String verseKey);

  /// İdempotenttir: aynı durumun tekrarı duplicate ÜRETMEZ; bir kaydın
  /// kaldırılması diğer kayıtları etkilemez.
  ResultFuture<void> setBookmarked(String verseKey, {required bool bookmarked});
}

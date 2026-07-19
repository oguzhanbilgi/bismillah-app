/// Kullanıcının yerel öğrenme ilerlemesi (TASK 056 §11).
///
/// Tamamen CİHAZ-LOKALDİR: Firebase gerektirmez. Dinî puan, seviye veya
/// rekabet İÇERMEZ — yalnız kullanıcının kendi kaldığı yeri bulmasına ve
/// içerik kaydetmesine yarar. Tamamlanmamış içerik için suçluluk dili
/// üretecek hiçbir alan yoktur.
final class LearningProgress {
  LearningProgress({
    Set<String>? bookmarkedArticleIds,
    Set<String>? completedArticleIds,
    this.lastOpenedArticleId,
    this.lastReadSectionIndex,
    this.lastOpenedAt,
  }) : bookmarkedArticleIds = Set.unmodifiable(
         bookmarkedArticleIds ?? const <String>{},
       ),
       completedArticleIds = Set.unmodifiable(
         completedArticleIds ?? const <String>{},
       );

  /// Boş başlangıç durumu — okuma hatasında da güvenle kullanılır.
  static final LearningProgress empty = LearningProgress();

  final Set<String> bookmarkedArticleIds;
  final Set<String> completedArticleIds;

  /// Kaldığın yerden devam için son açılan içerik.
  final String? lastOpenedArticleId;

  /// Son okunan bölüm indeksi (0 tabanlı).
  final int? lastReadSectionIndex;

  /// Son açılış zamanı (ISO-8601).
  final String? lastOpenedAt;

  bool isBookmarked(String articleId) =>
      bookmarkedArticleIds.contains(articleId);

  bool isCompleted(String articleId) => completedArticleIds.contains(articleId);

  LearningProgress copyWith({
    Set<String>? bookmarkedArticleIds,
    Set<String>? completedArticleIds,
    String? lastOpenedArticleId,
    int? lastReadSectionIndex,
    String? lastOpenedAt,
  }) => LearningProgress(
    bookmarkedArticleIds: bookmarkedArticleIds ?? this.bookmarkedArticleIds,
    completedArticleIds: completedArticleIds ?? this.completedArticleIds,
    lastOpenedArticleId: lastOpenedArticleId ?? this.lastOpenedArticleId,
    lastReadSectionIndex: lastReadSectionIndex ?? this.lastReadSectionIndex,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
  );
}

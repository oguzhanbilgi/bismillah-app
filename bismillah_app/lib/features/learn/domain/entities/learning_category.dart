/// Öğrenme kategorisi (TASK 056 §4).
///
/// Başlık ve açıklama ÇÖZÜLMÜŞ olarak taşınır: depo, aktif locale'e göre
/// doğru metni seçip verir — presentation katmanı ham locale haritası
/// görmez.
final class LearningCategory {
  LearningCategory({
    required this.id,
    required this.slug,
    required this.title,
    required this.shortDescription,
    required this.iconKey,
    required this.sortOrder,
    this.parentCategoryId,
  }) {
    if (id.trim().isEmpty || slug.trim().isEmpty) {
      throw ArgumentError('Kategori id ve slug zorunludur');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Kategori başlığı zorunludur');
    }
  }

  final String id;
  final String slug;
  final String title;
  final String shortDescription;

  /// Tema ikonuna eşlenen stabil anahtar (ham IconData JSON'a girmez).
  final String iconKey;

  final int sortOrder;
  final String? parentCategoryId;
}

/// Kategori + o kategorideki YAYINLANMIŞ içerik sayısı.
///
/// Boş kategori kullanıcıya doluymuş gibi gösterilmez (TASK 056 §4/§9):
/// [publishedCount] sıfırsa UI "hazırlanıyor" durumunu gösterir.
final class LearningCategorySummary {
  const LearningCategorySummary({
    required this.category,
    required this.publishedCount,
  });

  final LearningCategory category;
  final int publishedCount;

  bool get isEmpty => publishedCount == 0;
}

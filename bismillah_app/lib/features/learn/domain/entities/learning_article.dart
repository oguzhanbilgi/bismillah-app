import 'package:bismillah_app/features/learn/domain/entities/source_verification.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';

/// Tip güvenli içerik bloğu (TASK 056 §3).
///
/// Serbest HTML/Markdown render EDİLMEZ: her blok bilinen bir türdedir ve
/// UI onu kendi güvenli bileşenine eşler.
final class LearningSection {
  LearningSection({required this.type, this.text, List<String>? items})
    : items = List.unmodifiable(items ?? const <String>[]) {
    final needsItems =
        type == LearningSectionType.steps ||
        type == LearningSectionType.checklist;
    if (needsItems && this.items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        '${type.name} bloğu en az bir madde içermelidir',
      );
    }
    if (!needsItems && (text == null || text!.trim().isEmpty)) {
      throw ArgumentError.value(
        text,
        'text',
        '${type.name} bloğu boş metinle oluşturulamaz',
      );
    }
  }

  final LearningSectionType type;

  /// Paragraf/vurgu/not blokları için metin.
  final String? text;

  /// Adım ve kontrol listesi blokları için sıralı maddeler.
  final List<String> items;
}

/// Yayınlanabilir öğrenme içeriği (TASK 056 §3).
///
/// Bağlayıcı kurallar:
/// - [ReviewStatus.published] içerik KAYNAKSIZ olamaz ("no source, no
///   render") ve [reviewedAt] taşımak zorundadır.
/// - Metin, resmî kaynaktan ÖZGÜN ÖZETTİR; aynen kopya değildir.
/// - Mezhep/görüş farkı varsa [differenceNote] ile AÇIKÇA belirtilir —
///   gizlenemez.
/// - Kişisel duruma özel hüküm gerektiren konularda
///   [requiresQualifiedGuidance] işaretlenir ve kullanıcı yetkili
///   mercie yönlendirilir; uygulama fetva ÜRETMEZ.
final class LearningArticle {
  LearningArticle({
    required this.id,
    required this.slug,
    required this.categoryId,
    required this.title,
    required this.summary,
    required List<LearningSection> sections,
    required this.contentType,
    required this.difficulty,
    required this.estimatedMinutes,
    required List<String> keywords,
    required List<String> sourceIds,
    required this.reviewStatus,
    required this.translationStatus,
    List<String>? relatedArticleIds,
    List<String>? prerequisiteArticleIds,
    this.reviewedAt,
    this.differenceNote,
    this.beginnerPathOrder,
    this.isFeatured = false,
    this.requiresQualifiedGuidance = false,
    this.guidanceMessage,
    this.officialQuestionUrl,
    this.verification,
  }) : sections = List.unmodifiable(sections),
       keywords = List.unmodifiable(keywords),
       sourceIds = List.unmodifiable(sourceIds),
       relatedArticleIds = List.unmodifiable(
         relatedArticleIds ?? const <String>[],
       ),
       prerequisiteArticleIds = List.unmodifiable(
         prerequisiteArticleIds ?? const <String>[],
       ) {
    if (id.trim().isEmpty || slug.trim().isEmpty) {
      throw ArgumentError('İçerik id ve slug zorunludur');
    }
    if (title.trim().isEmpty || summary.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Başlık ve özet zorunludur');
    }
    if (estimatedMinutes < 1) {
      throw ArgumentError.value(
        estimatedMinutes,
        'estimatedMinutes',
        '>= 1 olmalı',
      );
    }
    if (this.sections.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Bölümsüz içerik oluşturulamaz');
    }
    // ---------------------------------------------------------------
    // YAYIN KAPISI (TASK 056A §3)
    //
    // Bir içerik ancak kaynak GÖVDESİ doğrulanmışsa yayınlanabilir.
    // Yalnız URL/alan adı kontrolü YETMEZ — TASK 056'da tam olarak bu
    // hata yapılmıştı. Kural burada, domain kurucusunda zorlanır: geçersiz
    // bir "published" nesne HİÇ oluşturulamaz.
    // ---------------------------------------------------------------
    if (reviewStatus == ReviewStatus.published) {
      if (this.sourceIds.isEmpty) {
        throw ArgumentError.value(
          id,
          'id',
          'Yayınlanan içerik en az bir doğrulanmış kaynak taşımalıdır',
        );
      }
      if (reviewedAt == null || reviewedAt!.trim().isEmpty) {
        throw ArgumentError.value(
          id,
          'id',
          'Yayınlanan içerik reviewedAt taşımalıdır',
        );
      }
      final verification = this.verification;
      if (verification == null) {
        throw ArgumentError.value(
          id,
          'id',
          'Yayınlanan içerik kaynak doğrulama kaydı taşımalıdır',
        );
      }
      if (!verification.satisfiesPublicationGate) {
        throw ArgumentError.value(
          id,
          'id',
          'Yayın kapısı reddetti: kaynak gövdesi doğrulanmamış veya '
              'locator/evidenceSummary/verifiedAt eksik ya da doğrulama '
              'yöntemi URL kontrolünden güçlü değil',
        );
      }
      // Doğrulama, içeriğin GERÇEKTEN atıf yaptığı bir kaynağa dayanmalı.
      if (!this.sourceIds.contains(verification.sourceId)) {
        throw ArgumentError.value(
          id,
          'id',
          'Doğrulama kaydı içeriğin kaynakları arasında olmayan bir '
              'kaynağa dayanıyor: ${verification.sourceId}',
        );
      }
    }
  }

  final String id;
  final String slug;
  final String categoryId;

  final String title;
  final String summary;
  final List<LearningSection> sections;

  final LearningContentType contentType;
  final LearningDifficulty difficulty;
  final int estimatedMinutes;

  /// Arama için başlık dışı anahtar kelimeler ve yaygın yazımlar
  /// (ör. "tövbe" ↔ "tevbe").
  final List<String> keywords;

  /// [KnowledgeSource.id] referansları.
  final List<String> sourceIds;

  /// Mezhep/görüş farkı notu — varsa GİZLENMEZ.
  final String? differenceNote;

  /// Son kaynak kontrol tarihi (ISO-8601 gün).
  final String? reviewedAt;

  final ReviewStatus reviewStatus;
  final LearningTranslationStatus translationStatus;

  final List<String> relatedArticleIds;
  final List<String> prerequisiteArticleIds;

  /// Yeni başlayanlar yolundaki sıra (1 tabanlı); yolda değilse `null`.
  final int? beginnerPathOrder;

  final bool isFeatured;

  /// Konu kişisel duruma özel hüküm gerektiriyor mu (TASK 056 §13)?
  final bool requiresQualifiedGuidance;

  /// Yönlendirme mesajı (yalnız [requiresQualifiedGuidance] iken anlamlı).
  final String? guidanceMessage;

  /// Resmî soru sorma sayfası — alan adı doğrulamasından geçer.
  final String? officialQuestionUrl;

  /// Kaynak gövdesi doğrulama kaydı (TASK 056A). Yayın için ZORUNLUDUR.
  final SourceVerification? verification;

  /// Kaynak metni gerçekten okunup iddialarla karşılaştırıldı mı?
  bool get isSourceBodyVerified => verification?.sourceBodyVerified ?? false;

  bool get isPublished => reviewStatus == ReviewStatus.published;
}

import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/domain/supported_language.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/content/domain/entities/content_item.dart';
import 'package:bismillah_app/features/content/domain/value_objects/content_enums.dart';

/// İçerik kütüphanesi lokal veri sözleşmesi (indirilen cache;
/// 10_DATA_MODEL §7 `ContentCacheModel`).
///
/// İstemci YALNIZ `published` içerik tüketir — implementasyon sorgu
/// filtresini zorlar (rules + mapper ile üçlü savunma; §20).
/// Retract edilen içerik cache'ten düşürülür (§23 edge 13).
abstract interface class ContentRepository {
  ResultFuture<ContentItem?> getItem(ContentId contentId);

  ResultFuture<List<ContentItem>> listByType(
    SacredContentType contentType, {
    required SupportedLanguage language,
  });

  /// CMS'ten yayınlanmış içerik zarflarını tazeler (⬇ pull-only).
  ResultFuture<void> refreshCache();
}

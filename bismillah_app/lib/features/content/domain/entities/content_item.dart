import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/language_code.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/content/domain/value_objects/content_enums.dart';

/// Genel içerik zarfı (10_DATA_MODEL §20 zorunlu metadata zarfı).
///
/// Her içerik belgesi/cache kaydı bu zarfı taşır. Constructor,
/// zarf kurallarını zorlar: kaynaksız içerik kurulamaz; hadis tipinde
/// `grading` zorunludur; `version` monoton artan pozitif tamsayıdır.
final class ContentItem implements Classified {
  ContentItem({
    required this.contentId,
    required this.contentType,
    required this.source,
    required this.sourceReference,
    required this.language,
    required this.version,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.grading,
    this.reviewedBy,
  }) {
    if (source.trim().isEmpty || sourceReference.trim().isEmpty) {
      throw ArgumentError(
        'İçerik zarfı kaynaksız kurulamaz (no source, no render)',
      );
    }
    if (contentType == SacredContentType.hadith && grading == null) {
      throw ArgumentError.value(
        grading,
        'grading',
        'Derecesiz hadis yayınlanamaz (10_DATA_MODEL §20)',
      );
    }
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'version >= 1 olmalı');
    }
  }

  final ContentId contentId;
  final SacredContentType contentType;
  final String source;
  final String sourceReference;
  final LanguageCode language;

  /// Monoton artan sürüm; düzeltme yeni versiyondur, ID değişmez.
  final int version;

  final ContentStatus status;
  final UtcDateTime createdAt;
  final UtcDateTime updatedAt;

  /// Yalnız hadis için zorunlu.
  final HadithGrading? grading;

  /// V3 alan rezervasyonu (10_DATA_MODEL §20) — bugün nullable.
  final String? reviewedBy;

  /// İstemci yalnız `published` tüketir.
  bool get isConsumable => status == ContentStatus.published;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.publicContent;
}

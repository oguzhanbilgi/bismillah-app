import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_enums.dart';

/// Öğrenme yolu (10_DATA_MODEL §4) — İçerik CMS kaynaklı, Public.
///
/// Kullanıcı ilerlemesi ayrı tutulur (§4 not) — bu entity yalnız
/// yayınlanmış yol tanımıdır.
final class LearningPath implements Classified {
  LearningPath({
    required this.pathId,
    required List<ContentId> lessonIds,
    required this.level,
  }) : lessonIds = List.unmodifiable(lessonIds) {
    if (this.lessonIds.isEmpty) {
      throw ArgumentError.value(
        lessonIds,
        'lessonIds',
        'Derssiz öğrenme yolu yayınlanamaz',
      );
    }
  }

  final ContentId pathId;
  final List<ContentId> lessonIds;
  final ExperienceLevel level;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.publicContent;
}

import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';

/// Ders içeriği (10_DATA_MODEL §4) — İçerik CMS kaynaklı, Public.
///
/// Blok gövdeleri içerik görevinin kapsamıdır; domain yalnız doğrulanmış
/// içerik kütüphanesine [ContentId] referansları taşır. Kullanıcı
/// ilerlemesi bu entity'de DEĞİLDİR (lesson completion → plan/achievement
/// verisi; §4 not).
final class Lesson implements Classified {
  Lesson({
    required this.lessonId,
    required this.pathId,
    required this.order,
    required List<ContentId> blockContentIds,
    required this.durationMin,
  }) : blockContentIds = List.unmodifiable(blockContentIds) {
    if (order < 1) {
      throw ArgumentError.value(order, 'order', '>= 1 olmalı');
    }
    if (durationMin < 1) {
      throw ArgumentError.value(durationMin, 'durationMin', '>= 1 olmalı');
    }
    if (this.blockContentIds.isEmpty) {
      throw ArgumentError.value(
        blockContentIds,
        'blockContentIds',
        'Bloksuz ders yayınlanamaz',
      );
    }
  }

  final ContentId lessonId;
  final ContentId pathId;

  /// Yol içi sıra (1 tabanlı).
  final int order;

  /// Doğrulanmış içerik kütüphanesindeki blok referansları.
  final List<ContentId> blockContentIds;

  final int durationMin;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.publicContent;
}

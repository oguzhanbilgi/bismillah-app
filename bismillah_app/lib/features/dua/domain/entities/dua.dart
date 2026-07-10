import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/content/domain/entities/sacred_content.dart';

/// Dua içeriği (10_DATA_MODEL §4) — İçerik CMS kaynaklı, Public.
///
/// Metin, kaynak metadata'sını ZORUNLU taşıyan [DuaText] tipidir —
/// kaynaksız dua bu entity ile temsil edilemez (§20).
final class Dua implements Classified {
  Dua({required this.duaId, required this.category, required this.text}) {
    if (category.trim().isEmpty) {
      throw ArgumentError.value(category, 'category', 'Kategori boş olamaz');
    }
  }

  final ContentId duaId;

  /// Kategori kodu (ör. `morning`) — liste sorguları için.
  final String category;

  final DuaText text;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.publicContent;
}

/// Favori işareti (10_DATA_MODEL §4) — tombstone'lu.
///
/// Çakışmada tombstone > add; eşit zamanda LWW(updatedAt) (§14).
final class DuaFavorite implements Classified {
  DuaFavorite({
    required this.duaId,
    required this.addedAt,
    this.deleted = false,
    this.deletedAt,
  }) {
    if (deleted && deletedAt == null) {
      throw ArgumentError.value(
        deletedAt,
        'deletedAt',
        'Tombstone deletedAt taşımak zorundadır (§15)',
      );
    }
  }

  final ContentId duaId;
  final UtcDateTime addedAt;
  final bool deleted;
  final UtcDateTime? deletedAt;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}

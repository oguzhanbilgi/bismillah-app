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
    if (!deleted && deletedAt != null) {
      throw ArgumentError.value(
        deletedAt,
        'deletedAt',
        'Aktif favori deletedAt taşıyamaz (tombstone alanı)',
      );
    }
  }

  final ContentId duaId;
  final UtcDateTime addedAt;
  final bool deleted;
  final UtcDateTime? deletedAt;

  /// Çakışma çözümü (10_DATA_MODEL §14): **tombstone > add** — silme
  /// niyeti güçlüdür; aynı durumda geç zaman damgası kazanır (LWW).
  /// Sıra-bağımsızdır: `resolve(a, b) == resolve(b, a)`.
  static DuaFavorite resolveTombstoneWins(DuaFavorite a, DuaFavorite b) {
    assert(a.duaId == b.duaId, 'Aynı duanın kayıtları çözülür');
    if (a.deleted != b.deleted) {
      return a.deleted ? a : b;
    }
    if (a.deleted && a.deletedAt != b.deletedAt) {
      return a.deletedAt!.isAfter(b.deletedAt!) ? a : b;
    }
    if (a.addedAt != b.addedAt) {
      return a.addedAt.isAfter(b.addedAt) ? a : b;
    }
    return a; // tüm alanlar eşit — iki kopya aynı değerdir
  }

  @override
  bool operator ==(Object other) =>
      other is DuaFavorite &&
      other.duaId == duaId &&
      other.addedAt == addedAt &&
      other.deleted == deleted &&
      other.deletedAt == deletedAt;

  @override
  int get hashCode => Object.hash(duaId, addedAt, deleted, deletedAt);

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}

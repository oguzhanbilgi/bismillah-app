import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/dua/domain/entities/dua.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final duaId = ContentId('dua-morning-001');
  final t1 = UtcDateTime(DateTime.utc(2026, 7, 8, 10));
  final t2 = UtcDateTime(DateTime.utc(2026, 7, 8, 12));

  test('tombstone must carry deletedAt; active favorite must not', () {
    expect(
      () => DuaFavorite(duaId: duaId, addedAt: t1, deleted: true),
      throwsArgumentError,
    );
    expect(
      () => DuaFavorite(duaId: duaId, addedAt: t1, deletedAt: t2),
      throwsArgumentError,
    );
  });

  test('tombstone wins over add regardless of order', () {
    final added = DuaFavorite(duaId: duaId, addedAt: t2);
    final tombstone = DuaFavorite(
      duaId: duaId,
      addedAt: t1,
      deleted: true,
      deletedAt: t1,
    );

    final ab = DuaFavorite.resolveTombstoneWins(added, tombstone);
    final ba = DuaFavorite.resolveTombstoneWins(tombstone, added);
    expect(ab, ba);
    expect(ab.deleted, isTrue);
  });

  test('same state resolves by later timestamp, order-independent', () {
    // İkisi de tombstone: geç deletedAt kazanır.
    final earlyDelete = DuaFavorite(
      duaId: duaId,
      addedAt: t1,
      deleted: true,
      deletedAt: t1,
    );
    final lateDelete = DuaFavorite(
      duaId: duaId,
      addedAt: t1,
      deleted: true,
      deletedAt: t2,
    );
    expect(
      DuaFavorite.resolveTombstoneWins(earlyDelete, lateDelete),
      DuaFavorite.resolveTombstoneWins(lateDelete, earlyDelete),
    );
    expect(
      DuaFavorite.resolveTombstoneWins(earlyDelete, lateDelete).deletedAt,
      t2,
    );

    // İkisi de aktif: geç addedAt kazanır (LWW).
    final earlyAdd = DuaFavorite(duaId: duaId, addedAt: t1);
    final lateAdd = DuaFavorite(duaId: duaId, addedAt: t2);
    expect(
      DuaFavorite.resolveTombstoneWins(earlyAdd, lateAdd),
      DuaFavorite.resolveTombstoneWins(lateAdd, earlyAdd),
    );
    expect(DuaFavorite.resolveTombstoneWins(earlyAdd, lateAdd).addedAt, t2);
  });
}

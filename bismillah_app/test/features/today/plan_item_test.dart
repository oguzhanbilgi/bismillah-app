import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final itemId = EntityId('item-1');
  final t1 = UtcDateTime(DateTime.utc(2026, 7, 8, 10));
  final t2 = UtcDateTime(DateTime.utc(2026, 7, 8, 12));

  PlanItem item({
    PlanItemStatus status = PlanItemStatus.pending,
    UtcDateTime? completedAt,
    String? targetRef,
    int? sizeParam,
  }) {
    return PlanItem(
      itemId: itemId,
      type: PlanItemType.quran,
      status: status,
      completedAt: completedAt,
      targetRef: targetRef,
      sizeParam: sizeParam,
    );
  }

  test('completed beats incomplete regardless of order', () {
    final completed = item(status: PlanItemStatus.completed, completedAt: t1);
    final pending = item();

    final ab = PlanItem.resolveCompletedWins(completed, pending);
    final ba = PlanItem.resolveCompletedWins(pending, completed);
    expect(ab, ba);
    expect(ab.isCompleted, isTrue);
  });

  test('both completed: earlier completedAt wins, order-independent', () {
    final early = item(status: PlanItemStatus.completed, completedAt: t1);
    final late_ = item(status: PlanItemStatus.completed, completedAt: t2);

    final ab = PlanItem.resolveCompletedWins(early, late_);
    final ba = PlanItem.resolveCompletedWins(late_, early);
    expect(ab, ba);
    expect(ab.completedAt, t1);
  });

  test('same completion state with field differences is deterministic', () {
    // İkisi de pending, completedAt yok — kalıcı alanlar tie-break'i belirler.
    final a = item(targetRef: 'surah-2', sizeParam: 5);
    final b = item(targetRef: 'surah-36', sizeParam: 3);

    final ab = PlanItem.resolveCompletedWins(a, b);
    final ba = PlanItem.resolveCompletedWins(b, a);
    expect(ab, ba);

    // targetRef eşitken sizeParam kırar; null deterministik olarak önce.
    final c = item(targetRef: 'surah-2', sizeParam: 5);
    final d = item(targetRef: 'surah-2');
    expect(
      PlanItem.resolveCompletedWins(c, d),
      PlanItem.resolveCompletedWins(d, c),
    );
  });

  test('fully equal copies resolve to the same value in both orders', () {
    final a = item(targetRef: 'surah-2', sizeParam: 5);
    final b = item(targetRef: 'surah-2', sizeParam: 5);
    expect(
      PlanItem.resolveCompletedWins(a, b),
      PlanItem.resolveCompletedWins(b, a),
    );
  });
}

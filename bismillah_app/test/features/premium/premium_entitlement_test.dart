import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/premium/domain/entities/premium_entitlement.dart';
import 'package:bismillah_app/features/premium/domain/value_objects/subscription_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkedAt = UtcDateTime(DateTime.utc(2026, 7, 8, 12));

  PremiumEntitlement entitlement(SubscriptionStatus status) {
    return PremiumEntitlement(
      status: status,
      willRenew: false,
      trialUsed: false,
      lastEntitlementCheckAt: checkedAt,
      serverTimeAtLastEntitlementCheck: checkedAt,
      localTimeAtLastEntitlementCheck: checkedAt,
    );
  }

  test('isActive follows plusStatus decision field (trial/active/grace)', () {
    expect(entitlement(SubscriptionStatus.trial).isActive, isTrue);
    expect(entitlement(SubscriptionStatus.active).isActive, isTrue);
    expect(entitlement(SubscriptionStatus.grace).isActive, isTrue);
    expect(entitlement(SubscriptionStatus.none).isActive, isFalse);
    expect(entitlement(SubscriptionStatus.expired).isActive, isFalse);
  });

  test('isExpired only for expired status', () {
    expect(entitlement(SubscriptionStatus.expired).isExpired, isTrue);
    expect(entitlement(SubscriptionStatus.active).isExpired, isFalse);
    expect(entitlement(SubscriptionStatus.none).isExpired, isFalse);
  });

  test('verification not required within offline tolerance window', () {
    final active = entitlement(SubscriptionStatus.active);
    final localNow = checkedAt.add(const Duration(days: 2));
    expect(active.requiresOnlineVerification(localNow), isFalse);
  });

  test('verification required after offline tolerance window', () {
    final active = entitlement(SubscriptionStatus.active);
    final localNow = checkedAt.add(
      PremiumEntitlement.offlineTolerance + const Duration(minutes: 1),
    );
    expect(active.requiresOnlineVerification(localNow), isTrue);
  });

  test('clock rollback (negative elapsed) forces verification', () {
    final active = entitlement(SubscriptionStatus.active);
    final rolledBack = checkedAt.add(const Duration(hours: -1));
    expect(active.requiresOnlineVerification(rolledBack), isTrue);
  });
}

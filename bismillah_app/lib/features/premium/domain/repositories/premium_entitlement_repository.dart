import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/premium/domain/entities/premium_entitlement.dart';
import 'package:bismillah_app/features/premium/domain/entities/subscription_plan.dart';

/// Entitlement CACHE sözleşmesi (10_DATA_MODEL §16).
///
/// BİLİNÇLİ SINIR: bu API entitlement "verme" yolu SUNMAZ — yazma yalnız
/// server kaynaklı pull/webhook sonucunun cache'e işlenmesidir ve push
/// sync'e girmez. Cache manipülasyonu ilk pull'da ezilir (§14-12).
abstract interface class PremiumEntitlementRepository {
  ResultFuture<PremiumEntitlement?> getCached();

  Stream<PremiumEntitlement?> watch();

  /// Server kaynaklı yeni durumu cache'e yazar (pull/webhook sonucu).
  ResultFuture<void> updateCacheFromServer(PremiumEntitlement entitlement);

  ResultFuture<List<SubscriptionPlan>> getCachedPlans();

  ResultFuture<void> updatePlanCache(List<SubscriptionPlan> plans);
}

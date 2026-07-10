import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/premium/domain/value_objects/subscription_enums.dart';

/// Bismillah+ entitlement durumu — SERVER-OWNED kavram
/// (10_DATA_MODEL §16; kural §14-12).
///
/// İstemci entitlement VEREMEZ: bu nesnenin lokal kopyası salt cache'tir,
/// push sync'e girmez; doğruluk RevenueCat→function→Firestore zinciridir.
/// Ödeme kartı verisi HİÇBİR katmanda saklanmaz (Restricted — var
/// olmayarak korunur).
final class PremiumEntitlement implements Classified {
  const PremiumEntitlement({
    required this.status,
    required this.willRenew,
    required this.trialUsed,
    required this.lastEntitlementCheckAt,
    required this.serverTimeAtLastEntitlementCheck,
    required this.localTimeAtLastEntitlementCheck,
    this.source,
    this.activeProductId,
    this.originalPurchaseDate,
    this.expirationDate,
  });

  /// Hiç doğrulama yapılmamış ilk-kurulum durumu.
  factory PremiumEntitlement.none({
    required UtcDateTime checkedAt,
    required UtcDateTime localCheckedAt,
  }) {
    return PremiumEntitlement(
      status: SubscriptionStatus.none,
      willRenew: false,
      trialUsed: false,
      lastEntitlementCheckAt: checkedAt,
      serverTimeAtLastEntitlementCheck: checkedAt,
      localTimeAtLastEntitlementCheck: localCheckedAt,
    );
  }

  /// Offline tolerans penceresi (10_DATA_MODEL §16 — 3 gün *varsayım*).
  static const Duration offlineTolerance = Duration(days: 3);

  final SubscriptionStatus status;
  final SubscriptionSource? source;
  final String? activeProductId;
  final UtcDateTime? originalPurchaseDate;
  final UtcDateTime? expirationDate;

  /// İptal-niyet göstergesi (UI: "dönem sonuna dek aktif").
  final bool willRenew;

  /// İkinci deneme engeli.
  final bool trialUsed;

  /// Cache tazeliği meta'sı (istemci yazar — yalnız meta).
  final UtcDateTime lastEntitlementCheckAt;

  /// Son GÜVENİLİR server doğrulamasının sunucu zamanı (v1.1 hardening).
  final UtcDateTime serverTimeAtLastEntitlementCheck;

  /// Aynı anın yerel referansı — geçen süre hesabının çapası.
  final UtcDateTime localTimeAtLastEntitlementCheck;

  /// `isPlus` hesabı — istemci HESAPLAR, yazamaz (10_DATA_MODEL §24).
  bool get isActive => status.grantsAccess;

  bool get isExpired => status == SubscriptionStatus.expired;

  /// Online doğrulama gerekiyor mu? (§16 saat manipülasyonu hardening'i.)
  ///
  /// Karar `plusUntil` ile duvar saati karşılaştırmasına DEĞİL, son
  /// güvenilir server kontrolünden bu yana geçen YEREL süreye dayanır.
  /// Saat geri alınmışsa (negatif fark) yerel saate güvenilemez —
  /// doğrulama istenir. Pencere aşımı sert kesinti DEĞİLDİR; UI nazik
  /// "bağlanınca doğrulayalım" durumu gösterir.
  bool requiresOnlineVerification(UtcDateTime localNow) {
    final elapsed = localNow.difference(localTimeAtLastEntitlementCheck);
    if (elapsed.isNegative) {
      return true;
    }
    return elapsed > offlineTolerance;
  }

  /// Entitlement meta'sı Orta hassasiyettir (10_DATA_MODEL §19) — ibadet
  /// verisiyle ham birleştirilemez.
  @override
  SensitivityClass get sensitivityClass => SensitivityClass.medium;
}

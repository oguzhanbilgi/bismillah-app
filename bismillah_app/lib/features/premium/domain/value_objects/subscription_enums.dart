/// Premium abonelik enum'ları (10_DATA_MODEL §16).
library;

/// `plusStatus` — tek karar alanı. `isPlus = status ∈ {trial, active, grace}`.
enum SubscriptionStatus {
  none,
  trial,
  active,
  expired,
  grace;

  bool get grantsAccess =>
      this == SubscriptionStatus.trial ||
      this == SubscriptionStatus.active ||
      this == SubscriptionStatus.grace;
}

/// `plusSource` — entitlement'ın geldiği kanal.
enum SubscriptionSource { appStore, playStore, promo }

/// Paket dönem tipi (gösterim amaçlı; hesaplama store'dadır).
enum SubscriptionPeriod { monthly, annual }

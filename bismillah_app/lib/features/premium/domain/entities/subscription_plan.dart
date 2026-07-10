import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/features/premium/domain/value_objects/subscription_enums.dart';

/// Paket tanımı — GÖSTERİM verisi (10_DATA_MODEL §4, §16).
///
/// `priceLabel` yalnız görüntüleme içindir; fiyat hesaplama daima
/// store/RevenueCat tarafındadır. Bu nesne cache'tir, kaynak değildir.
final class SubscriptionPlan implements Classified {
  SubscriptionPlan({
    required this.productId,
    required this.period,
    required this.priceLabel,
    required this.offeringId,
  }) {
    if (productId.trim().isEmpty || offeringId.trim().isEmpty) {
      throw ArgumentError('productId/offeringId boş olamaz');
    }
  }

  final String productId;
  final SubscriptionPeriod period;

  /// Lokalize fiyat metni (ör. "₺49,99/ay") — hesaplamada KULLANILMAZ.
  final String priceLabel;

  final String offeringId;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.publicContent;
}

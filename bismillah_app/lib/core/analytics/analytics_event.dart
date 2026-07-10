/// Tipli analytics event sözlüğü (06_FLUTTER_ARCHITECTURE §21).
///
/// Parametre değerleri serbest `String` OLAMAZ — yalnız [AnalyticsParamValue]
/// alt tipleri kabul edilir. PII ve ham ibadet verisi bu tip sisteminden
/// geçemez; ikinci savunma hattı `PrivacyGuard`'dır.
sealed class AnalyticsParamValue {
  const AnalyticsParamValue();
}

/// Kova/enum değeri (ör. `source: notification`, `status: on_time`).
final class BucketValue extends AnalyticsParamValue {
  const BucketValue(this.bucket);

  final String bucket;
}

/// Sayısal ölçüm (süre bandı, adet — asla kimliklendirici değer).
final class CountValue extends AnalyticsParamValue {
  const CountValue(this.count);

  final num count;
}

/// Bayrak değeri.
final class FlagValue extends AnalyticsParamValue {
  const FlagValue(this.flag);

  final bool flag;
}

/// Tek bir telemetri eventi. Doğrudan kurulamaz — yalnız isimli
/// factory'lerle üretilir; böylece event sözlüğü tek yerde yaşar
/// (PRD §40 taksonomisi genişledikçe factory eklenir).
final class AnalyticsEvent {
  const AnalyticsEvent._(this.name, this.params);

  final String name;
  final Map<String, AnalyticsParamValue> params;

  factory AnalyticsEvent.appOpened() => const AnalyticsEvent._('app_opened', {});

  factory AnalyticsEvent.screenViewed({required String screenId}) =>
      AnalyticsEvent._('screen_viewed', {'screen_id': BucketValue(screenId)});

  factory AnalyticsEvent.tabSelected({required String tab}) =>
      AnalyticsEvent._('tab_selected', {'tab': BucketValue(tab)});

  factory AnalyticsEvent.assistantFabOpened({required String sourceScreen}) =>
      AnalyticsEvent._(
        'fab_assistant_opened',
        {'source_screen': BucketValue(sourceScreen)},
      );

  factory AnalyticsEvent.routeError({required String path}) =>
      AnalyticsEvent._('route_error', {'path': BucketValue(path)});

  /// Test/iç kullanım: sözlük dışı ham event üretimi yalnız testlerde
  /// PrivacyGuard doğrulamasını denemek içindir.
  factory AnalyticsEvent.unsafeForValidation({
    required String name,
    required Map<String, AnalyticsParamValue> params,
  }) =>
      AnalyticsEvent._(name, params);
}

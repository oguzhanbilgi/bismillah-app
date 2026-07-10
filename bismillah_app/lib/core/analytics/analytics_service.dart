import 'package:bismillah_app/core/analytics/analytics_event.dart';

/// Telemetri servis sözleşmesi (06_FLUTTER_ARCHITECTURE §21).
///
/// Gerçek Firebase Analytics implementasyonu sonraki görevde,
/// infrastructure katmanında eklenir. UI ve feature katmanları yalnız
/// bu arayüzü görür.
abstract interface class AnalyticsService {
  Future<void> log(AnalyticsEvent event);
}

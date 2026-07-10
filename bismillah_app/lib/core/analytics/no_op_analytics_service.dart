import 'package:bismillah_app/core/analytics/analytics_event.dart';
import 'package:bismillah_app/core/analytics/analytics_service.dart';
import 'package:bismillah_app/core/logging/app_logger.dart';
import 'package:bismillah_app/core/privacy/privacy_guard.dart';

/// Ağa hiçbir şey göndermeyen analytics implementasyonu.
///
/// Dev flavor'ın varsayılanıdır (06_FLUTTER_ARCHITECTURE §34) ve scaffold
/// aşamasında tüm flavor'larda kullanılır. Event'ler yine de
/// [PrivacyGuard]'dan geçirilir — gizlilik ihlali gerçek backend'e
/// bağlanmadan ÖNCE, geliştirme sırasında yakalanır.
final class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService(this._logger);

  final AppLogger _logger;

  @override
  Future<void> log(AnalyticsEvent event) async {
    final validation = PrivacyGuard.validateAnalyticsEvent(event);
    validation.fold(
      onSuccess: (_) => _logger.debug('analytics(noop): ${event.name}'),
      onFailure: (failure) => _logger.warning(
        'analytics event rejected by PrivacyGuard: ${event.name} '
        '(${failure.messageKey})',
      ),
    );
  }
}

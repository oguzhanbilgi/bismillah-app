import 'package:bismillah_app/app/router/app_router.dart';
import 'package:bismillah_app/core/analytics/analytics_service.dart';
import 'package:bismillah_app/core/analytics/no_op_analytics_service.dart';
import 'package:bismillah_app/core/config/app_environment.dart';
import 'package:bismillah_app/core/database/local_database.dart';
import 'package:bismillah_app/core/logging/app_logger.dart';
import 'package:bismillah_app/core/network/network_status.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Uygulama geneli DI provider'ları (06_FLUTTER_ARCHITECTURE §11):
/// tek DI mekanizması Riverpod'dur; ayrı DI kütüphanesi kullanılmaz.
/// Testler `ProviderScope(overrides: ...)` ile mock'lar.

final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.fromDartDefine(),
);

final appLoggerProvider = Provider<AppLogger>((ref) => const AppLogger());

final analyticsServiceProvider = Provider<AnalyticsService>(
  // Scaffold aşaması: tüm flavor'larda NoOp (gerçek Firebase Analytics
  // entegrasyonu ayrı görevde, infrastructure katmanına eklenir).
  (ref) => NoOpAnalyticsService(ref.watch(appLoggerProvider)),
);

final localDatabaseProvider = Provider<LocalDatabase>(
  // Gerçek DB implementasyonu TASK 012+ — paket kararı infrastructure'da
  // izole kalır (10_DATA_MODEL §7 hardening).
  (ref) => InMemoryLocalDatabase(),
);

final networkStatusServiceProvider = Provider<NetworkStatusService>(
  (ref) => const AlwaysOnlineNetworkStatusService(),
);

final clockProvider = Provider<AppClock>((ref) => const SystemClock());

final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());

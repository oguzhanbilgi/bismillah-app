import 'package:bismillah_app/app/router/app_router.dart';
import 'package:bismillah_app/core/analytics/analytics_service.dart';
import 'package:bismillah_app/core/analytics/no_op_analytics_service.dart';
import 'package:bismillah_app/core/config/app_environment.dart';
import 'package:bismillah_app/core/database/local_database.dart';
import 'package:bismillah_app/core/logging/app_logger.dart';
import 'package:bismillah_app/core/network/network_status.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/features/onboarding/application/onboarding_status_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:bismillah_app/core/utils/clock_provider.dart'
    show clockProvider;

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
  // Gerçek Drift DB'si (TASK 014) — paket kararı infrastructure'da izole
  // kalır (10_DATA_MODEL §7 hardening): bu katman yalnız soyutlamayı
  // görür, Drift tipi core/storage provider'ının arkasındadır.
  (ref) => ref.watch(appDatabaseProvider),
);

final networkStatusServiceProvider = Provider<NetworkStatusService>(
  (ref) => const AlwaysOnlineNetworkStatusService(),
);

final appRouterProvider = Provider<GoRouter>(
  // Onboarding kapısı closure ile okunur (ref.read): durum değişince
  // router yeniden İNŞA EDİLMEZ — bootstrap'ın bildirim-dokunuş bağladığı
  // instance yaşamaya devam eder (TASK 028).
  (ref) => buildAppRouter(
    isOnboardingCompleted: () => ref.read(onboardingCompletedProvider),
  ),
);

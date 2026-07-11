import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama ön-yüklemesi (06_FLUTTER_ARCHITECTURE §8).
///
/// Sözleşme: bootstrap AĞ BEKLEMEZ — soğuk açılış <2sn hedefi ilk frame'in
/// lokal veriyle çizilmesine dayanır. Burada yalnız lokal kalıcılık açılır;
/// Firebase init, Crashlytics ve sync engine başlangıcı ilgili entegrasyon
/// görevlerinde (timeout'lu ve non-blocking) eklenecek.
Future<ProviderContainer> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await initializeLocalPersistence(container);
  return container;
}

/// Lokal kalıcılığı açılışta hazırlar:
///
/// 1. Drift veritabanını başlatır — DB açılamıyorsa uygulama başlayamaz
///    (offline-first mimaride lokal DB tek doğruluk kaynağıdır; hatası
///    bilinçli olarak yutulmaz, yukarı fırlar).
/// 2. Yarım kalmış `inFlight` sync op'larını `pending`e döndürür
///    (10_DATA_MODEL §27-1 açılış kurtarması). Bu adım ağa ÇIKMAZ ve
///    başarısızlığı açılışı ENGELLEMEZ — kuyruk bir sonraki push
///    denemesinde kendini toparlar; yalnız log düşülür.
///
/// Testler container'ı in-memory DB override'ıyla kurar.
Future<void> initializeLocalPersistence(ProviderContainer container) async {
  await container.read(localDatabaseProvider).initialize();

  final recovery =
      await container.read(syncQueueRepositoryProvider).recoverInFlight();
  if (recovery.isFailure) {
    container
        .read(appLoggerProvider)
        .warning('bootstrap: inFlight sync op kurtarması başarısız — '
            'kuyruk sonraki denemede toparlanır');
  }
}

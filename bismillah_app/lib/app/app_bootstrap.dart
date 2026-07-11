import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/core/session/session_bootstrap.dart';
import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Uygulama ön-yüklemesi (06_FLUTTER_ARCHITECTURE §8; TASK 018 sırası):
///
/// 1. Firebase Core başlat — config yoksa/başarısızsa NET raporlanır ve
///    uygulama lokal kimlikle devam eder (07 §127; fatal DEĞİL).
/// 2. Anonim/mevcut kullanıcı kimliği garanti edilir.
/// 3. Uygulama-lokal cihaz kimliği garanti edilir.
/// 4. Lokal kalıcılık başlatılır (DB açılamazsa fatal — tek doğruluk
///    kaynağı lokaldir).
/// 5. Eski uid (placeholder/lokal-fallback) satırları güncel UID'ye
///    remap edilir.
/// 6. Yarım kalmış inFlight sync op'ları kurtarılır.
///
/// Sözleşme: bootstrap AĞ BEKLEMEZ ve uzak sync/Firestore BAŞLATMAZ.
Future<ProviderContainer> bootstrap({
  SessionIdentity? sessionIdentity,
  List<Override> overrides = const [],
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final identity = sessionIdentity ?? await resolveSessionIdentity();

  final container = ProviderContainer(
    overrides: [
      currentUserIdProvider.overrideWithValue(identity.userId),
      currentDeviceIdProvider.overrideWithValue(identity.deviceId),
      firebaseInitStatusProvider.overrideWithValue(identity.firebaseStatus),
      ...overrides,
    ],
  );
  if (!identity.firebaseStatus.isAvailable) {
    container.read(appLoggerProvider).info(
      'bootstrap: Firebase yok (${identity.firebaseStatus.reason}) — '
      'lokal kimlikle devam (FlutterFire CLI yapılandırması ayrı görev)',
    );
  }

  await initializeLocalPersistence(container);
  return container;
}

/// Lokal kalıcılığı açılışta hazırlar (adımlar 4–6). Testler container'ı
/// in-memory DB + sabit kimlik override'larıyla kurar.
Future<void> initializeLocalPersistence(ProviderContainer container) async {
  // DB açılamıyorsa uygulama başlayamaz — hata bilinçli olarak yukarı fırlar.
  await container.read(localDatabaseProvider).initialize();

  // TASK 016–017 gerçek auth'tan önce placeholder-local-user altında lokal
  // sync satırları üretmiş olabilir; gerçek sync açılmadan önce güncel
  // UID'ye remap ŞARTTIR (07 §146). Başarısızlık açılışı bloklamaz —
  // sync engine henüz yok, sonraki açılış yeniden dener.
  final remap = await container
      .read(driftSyncQueueRepositoryProvider)
      .remapUid(to: container.read(currentUserIdProvider));
  if (remap.isFailure) {
    container
        .read(appLoggerProvider)
        .warning('bootstrap: uid remap başarısız — sonraki açılışta denenir');
  }

  final recovery =
      await container.read(syncQueueRepositoryProvider).recoverInFlight();
  if (recovery.isFailure) {
    container
        .read(appLoggerProvider)
        .warning('bootstrap: inFlight sync op kurtarması başarısız — '
            'kuyruk sonraki denemede toparlanır');
  }
}

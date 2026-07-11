import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/features/sync/data/local/drift_sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sync kuyruğunun somut Drift implementasyonu — YALNIZ data katmanı içi
/// kullanım (ör. `DriftPrayerLogRepository`'nin transaction-paylaşan
/// `enqueueInSession` çağrısı somut tipe ihtiyaç duyar).
final driftSyncQueueRepositoryProvider = Provider<DriftSyncQueueRepository>(
  (ref) => DriftSyncQueueRepository(ref.watch(appDatabaseProvider)),
);

/// Uygulamanın geri kalanının okuduğu arayüz provider'ı — SyncEngine ve
/// Firestore push'u sonraki görevlerdedir; bu yalnız kalıcı kuyruktur.
final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => ref.watch(driftSyncQueueRepositoryProvider),
);

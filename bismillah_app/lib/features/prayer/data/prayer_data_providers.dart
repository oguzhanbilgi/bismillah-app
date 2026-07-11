import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/features/prayer/data/local/drift_prayer_log_repository.dart';
import 'package:bismillah_app/features/prayer/domain/repositories/prayer_log_repository.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz kaydı repository'sinin DI bağlaması: uygulama arayüzü okur,
/// içeride TASK 014 Drift implementasyonu döner
/// (06_FLUTTER_ARCHITECTURE §11 — tek DI mekanizması Riverpod).
///
/// `currentUserId` çağrı ANINDA okunur: kimlik provider'ı override
/// edildiğinde (test/auth entegrasyonu) yeni yazımlar yeni kimliği taşır.
final prayerLogRepositoryProvider = Provider<PrayerLogRepository>((ref) {
  return DriftPrayerLogRepository(
    ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(driftSyncQueueRepositoryProvider),
    currentUserId: () => ref.read(currentUserIdProvider),
  );
});

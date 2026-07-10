import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';

/// Asistan sohbet geçmişi lokal veri sözleşmesi (Isar-first;
/// 10_DATA_MODEL §7).
///
/// API bilinçli olarak APPEND-ONLY'dir: update yolu yoktur (§14).
/// Silme tombstone'dur; geçmişi tamamen silme PRD §35 hakkıdır ve
/// hesaptan bağımsız tek eylemdir (§16).
abstract interface class AssistantMessageRepository {
  /// Yeni mesaj ekler — mevcut mesaj üzerine yazma YOKTUR.
  ResultFuture<void> append(AssistantMessage message);

  /// UI'ın tek besleme kanalı — lokal watch akışı (06_FLUTTER_ARCH §14).
  Stream<List<AssistantMessage>> watchRecent({int limit = 50});

  /// Tek mesajı tombstone'lar (bağımsız silinebilir; §4).
  ResultFuture<void> markDeleted(EntityId messageId);

  /// Tüm geçmişi purge eder (assistant history deletion; §16).
  ResultFuture<void> purgeAll();
}

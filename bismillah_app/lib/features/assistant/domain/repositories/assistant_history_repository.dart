import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';

/// Asistan sohbet geçmişi YEREL kalıcılık sözleşmesi (TASK 059 §13).
///
/// Yalnız cihaz-lokal; Firebase/sync YOKTUR. Kişisel/fetva niteliğindeki
/// mesajlar buraya YAZILMAZ (çağıran filtreler). En fazla son 20 mesaj
/// tutulur. Zengin canlı görünüm (adım/madde) SAKLANMAZ — yeniden açılışta
/// sade kart olarak çizilir.
abstract interface class AssistantHistoryRepository {
  /// Kalıcı geçmişi yükler (bozuk kayıtta boş liste — crash yok).
  Future<List<AssistantMessage>> load();

  /// Verilen (zaten filtrelenmiş) mesajları kalıcı olarak yazar; en fazla
  /// son [maxMessages] tutulur.
  Future<void> save(List<AssistantMessage> messages);

  /// Tüm geçmişi siler.
  Future<void> clear();
}

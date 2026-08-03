import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';

/// Asistan sohbet geçmişi YEREL kalıcılık sözleşmesi (TASK 059 §13).
///
/// Yalnız cihaz-lokal; Firebase/sync YOKTUR. Kişisel/fetva/ibadet-kuralı
/// niteliğindeki mesajlar buraya YAZILMAZ (çağıran filtreler;
/// [AssistantQueryClassifier.isSensitiveVerdict] TEK kanonik yüklemdir,
/// TASK 094 §A). En fazla son 20 mesaj tutulur. Zengin canlı görünüm
/// (adım/madde) SAKLANMAZ — yeniden açılışta sade kart olarak çizilir.
/// `load()` ayrıca eski (TASK 094 öncesi) kayıtlarda kalmış olabilecek
/// hassas kayıtları geriye dönük TEMİZLER (TASK 094 §B/§C).
abstract interface class AssistantHistoryRepository {
  /// Kalıcı geçmişi yükler (bozuk kayıtta boş liste — crash yok).
  Future<List<AssistantMessage>> load();

  /// Mesajları kalıcı olarak yazar; en fazla son `maxMessages` tutulur.
  ///
  /// Çağıran hassas mesajları zaten filtrelemelidir, ANCAK uygulama bu
  /// sınırda da ZORUNLUDUR (savunma derinliği, TASK 094 §A): depoyu
  /// doğrudan çağıran bir kod yolu hassas geçmişi diske yazamaz. Yazma
  /// başarısız olursa sonuç sessizce yutulmaz.
  ResultFuture<void> save(List<AssistantMessage> messages);

  /// Tüm geçmişi siler. Silme BAŞARISIZ olursa çağıran kullanıcıya
  /// "temizlendi" bilgisini VERMEMELİDİR (TASK 094 §E) — bu yüzden sonuç
  /// [ResultFuture] ile taşınır, sessizce yutulmaz.
  ResultFuture<void> clear();
}

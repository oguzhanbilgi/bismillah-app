/// Presentation katmanının görebildiği tek hata ailesi.
///
/// Ham exception'lar data katmanında [AppFailure]'a eşlenir
/// (06_FLUTTER_ARCHITECTURE §22). Kullanıcıya gösterilecek metin,
/// [messageKey] üzerinden localization katmanında çözülür — failure
/// nesnesi asla kullanıcı metni taşımaz.
sealed class AppFailure {
  const AppFailure({required this.messageKey});

  /// Localization anahtarı (ör. `errorNetwork`). Ham hata metni değildir.
  final String messageKey;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure() : super(messageKey: 'errorNetwork');
}

final class StorageFailure extends AppFailure {
  const StorageFailure() : super(messageKey: 'errorStorage');
}

/// Kalıcı depodaki verinin kendisi bozuk/okunamaz durumda (TASK 077).
///
/// [StorageFailure]'dan AYRI bir tiptir çünkü anlamları farklıdır:
/// `StorageFailure` geçici bir depo *işlemi* hatasıdır (okuma/yazma
/// istisnası) ve tekrar denemek mantıklıdır; bu tip ise **saklanan
/// verinin** çözümlenemediğini söyler (bozuk JSON, desteklenmeyen şema
/// sürümü, yapısal olarak geçersiz kayıt) — tekrar denemek aynı sonucu
/// verir ve kurtarma ayrı bir karardır.
///
/// Çağıran doğrulama hataları (geçersiz argüman, geçersiz domain durumu)
/// bu tiple TEMSİL EDİLMEZ — onlar depo bozulması değildir.
///
/// Kullanıcı metni değişmez: aynı `errorStorage` anahtarını kullanır, yeni
/// localization anahtarı gerekmez. Ham istisna, JSON, yük, dosya yolu veya
/// depolama anahtarı TAŞIMAZ.
final class StorageCorruptionFailure extends AppFailure {
  const StorageCorruptionFailure() : super(messageKey: 'errorStorage');
}

final class SyncFailure extends AppFailure {
  const SyncFailure() : super(messageKey: 'errorSync');
}

final class PermissionFailure extends AppFailure {
  const PermissionFailure() : super(messageKey: 'errorPermission');
}

final class AuthFailure extends AppFailure {
  const AuthFailure() : super(messageKey: 'errorAuth');
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.messageKey});
}

final class AiUnavailableFailure extends AppFailure {
  const AiUnavailableFailure() : super(messageKey: 'errorAiUnavailable');
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure() : super(messageKey: 'errorUnexpected');
}

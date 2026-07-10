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

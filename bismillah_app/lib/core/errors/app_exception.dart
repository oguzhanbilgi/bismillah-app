/// Infrastructure katmanında fırlatılan iç istisna ailesi.
///
/// Bu tipler presentation katmanına ASLA sızmaz; data katmanı
/// [ErrorMapper] ile bunları `AppFailure`'a çevirir.
sealed class AppException implements Exception {
  const AppException(this.debugMessage);

  /// Yalnız log/teşhis amaçlı iç mesaj — kullanıcıya gösterilmez,
  /// hassas veri içeremez (06_FLUTTER_ARCHITECTURE §31).
  final String debugMessage;

  @override
  String toString() => '$runtimeType: $debugMessage';
}

final class NetworkException extends AppException {
  const NetworkException(super.debugMessage);
}

final class StorageException extends AppException {
  const StorageException(super.debugMessage);
}

final class PermissionException extends AppException {
  const PermissionException(super.debugMessage);
}

final class AuthException extends AppException {
  const AuthException(super.debugMessage);
}

final class ContentValidationException extends AppException {
  const ContentValidationException(super.debugMessage);
}

final class UnexpectedException extends AppException {
  const UnexpectedException(super.debugMessage);
}

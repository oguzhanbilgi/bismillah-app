import 'package:bismillah_app/core/errors/app_exception.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';

/// Infrastructure istisnalarını presentation'ın görebileceği
/// [AppFailure] tiplerine çevirir (06_FLUTTER_ARCHITECTURE §22).
abstract final class ErrorMapper {
  static AppFailure toFailure(Object error) {
    return switch (error) {
      NetworkException() => const NetworkFailure(),
      StorageException() => const StorageFailure(),
      PermissionException() => const PermissionFailure(),
      AuthException() => const AuthFailure(),
      ContentValidationException() => const ValidationFailure(
        messageKey: 'errorContentValidation',
      ),
      _ => const UnexpectedFailure(),
    };
  }
}

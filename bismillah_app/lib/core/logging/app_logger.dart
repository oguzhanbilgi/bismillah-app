import 'package:flutter/foundation.dart';

/// Uygulama geneli log cephesi (06_FLUTTER_ARCHITECTURE §7).
///
/// Kurallar (06 §31): doğrudan `print` tüm projede yasaktır; log satırına
/// kullanıcı adı, şehir, mesaj içeriği, ibadet detayı GİREMEZ — mesajlar
/// olay/ekran adı düzeyinde kalır. Release modunda yalnız warning ve üzeri
/// yazılır.
enum LogLevel { debug, info, warning, error }

final class AppLogger {
  const AppLogger({this.minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.warning});

  final LogLevel minimumLevel;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message) => _log(LogLevel.warning, message);

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message);
    if (error != null && kDebugMode) {
      debugPrint('[bismillah][error-detail] $error');
    }
  }

  void _log(LogLevel level, String message) {
    if (level.index < minimumLevel.index) {
      return;
    }
    debugPrint('[bismillah][${level.name}] $message');
  }
}

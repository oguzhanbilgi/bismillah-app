import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';

/// Uygulama dili tercihinin kalıcılık sözleşmesi (TASK 053 §4).
///
/// Firebase GEREKTİRMEZ — dil seçimi tamamen cihaz-lokaldir ve oturum
/// durumundan bağımsız çalışır.
abstract interface class AppLocaleRepository {
  /// Kayıtlı seçim; hiç seçim yapılmamışsa `null` döner (bu durumda
  /// çağıran sistem diline düşer — depo sistem dilini BİLMEZ).
  ResultFuture<SupportedLocale?> loadLocale();

  ResultFuture<void> saveLocale(SupportedLocale locale);
}

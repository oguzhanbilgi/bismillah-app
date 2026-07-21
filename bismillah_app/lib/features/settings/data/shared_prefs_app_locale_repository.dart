import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/settings/domain/repositories/app_locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı dil tercihi deposu (TASK 053).
///
/// Enum stabil `name` ile yazılır; bozuk/bilinmeyen değer "seçim yok"
/// sayılır (`null`) — crash yok, çağıran sistem diline düşer.
final class SharedPrefsAppLocaleRepository implements AppLocaleRepository {
  const SharedPrefsAppLocaleRepository();

  static const String _localeKey = 'bismillah.app_locale';

  @override
  ResultFuture<SupportedLocale?> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(
        SupportedLocale.fromStorageKey(prefs.get(_localeKey)),
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> saveLocale(SupportedLocale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.name);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}

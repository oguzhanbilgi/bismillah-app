import 'dart:ui';

import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/settings/data/shared_prefs_app_locale_repository.dart';
import 'package:bismillah_app/features/settings/domain/repositories/app_locale_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLocaleRepositoryProvider = Provider<AppLocaleRepository>(
  (ref) => const SharedPrefsAppLocaleRepository(),
);

/// Açılış anındaki uygulama dili.
///
/// PRODÜKSİYONDA DAİMA bootstrap tarafından override edilir: prefs okuması
/// `runApp`'ten ÖNCE biter, böylece ilk frame doğru dilde çizilir — siyah
/// ekran veya açılış spinner'ı OLUŞMAZ (TASK 053 §4). Buradaki varsayılan
/// yalnız bootstrap'sız kurulan container'lar (widget testleri) içindir.
final appLocaleAtLaunchProvider = Provider<SupportedLocale>(
  (ref) => SupportedLocale.tr,
);

/// Uygulama dilinin TEK global kaynağı.
///
/// `MaterialApp` bunu izler; değer değişince ağaç anında yeniden çizilir —
/// yeni route açmak veya uygulamayı yeniden başlatmak GEREKMEZ.
final appLocaleProvider =
    NotifierProvider<AppLocaleController, SupportedLocale>(
      AppLocaleController.new,
    );

final class AppLocaleController extends Notifier<SupportedLocale> {
  @override
  SupportedLocale build() => ref.watch(appLocaleAtLaunchProvider);

  /// Dili değiştirir. Arayüz ANINDA güncellenir; kalıcılık arkada yazılır.
  ///
  /// Yazma başarısız olsa bile oturum içi seçim korunur — kullanıcı seçtiği
  /// dilde kalır, hata ekranı gösterilmez (sakin bozulma).
  Future<void> select(SupportedLocale locale) async {
    if (state == locale) {
      return;
    }
    state = locale;
    await ref.read(appLocaleRepositoryProvider).saveLocale(locale);
  }
}

/// Açılışta kullanılacak dili çözer (TASK 053 §4 öncelik sırası):
/// 1. kayıtlı seçim, 2. desteklenen sistem dili, 3. Türkçe.
Future<SupportedLocale> resolveLaunchLocale({
  AppLocaleRepository repository = const SharedPrefsAppLocaleRepository(),
  required List<Locale> systemLocales,
}) async {
  final saved = (await repository.loadLocale()).valueOrNull;
  return saved ?? SupportedLocale.fromSystemLocales(systemLocales);
}

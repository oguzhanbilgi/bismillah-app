import 'dart:ui';

import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/settings/data/shared_prefs_app_locale_repository.dart';
import 'package:bismillah_app/features/settings/domain/repositories/app_locale_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bellek içi sahte depo — gerçek platform kanalına dokunmaz.
final class _FakeAppLocaleRepository implements AppLocaleRepository {
  _FakeAppLocaleRepository([this.stored]);

  SupportedLocale? stored;
  int saveCount = 0;

  @override
  ResultFuture<SupportedLocale?> loadLocale() async => Result.success(stored);

  @override
  ResultFuture<void> saveLocale(SupportedLocale locale) async {
    stored = locale;
    saveCount++;
    return const Result.success(null);
  }
}

/// Okuma ve yazması başarısız olan depo (sakin bozulma doğrulaması).
final class _FailingAppLocaleRepository implements AppLocaleRepository {
  @override
  ResultFuture<SupportedLocale?> loadLocale() async =>
      const Result.failure(StorageFailure());

  @override
  ResultFuture<void> saveLocale(SupportedLocale locale) async =>
      const Result.failure(StorageFailure());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupportedLocale sistem dili çözümü', () {
    test('sistem dili Türkçeyse tr seçilir', () {
      expect(
        SupportedLocale.fromSystemLocales(const [Locale('tr', 'TR')]),
        SupportedLocale.tr,
      );
    });

    test('sistem dili İngilizceyse en seçilir', () {
      expect(
        SupportedLocale.fromSystemLocales(const [Locale('en', 'US')]),
        SupportedLocale.en,
      );
    });

    test('sistem dili Arapçaysa ar seçilir', () {
      expect(
        SupportedLocale.fromSystemLocales(const [Locale('ar', 'SA')]),
        SupportedLocale.ar,
      );
    });

    test('desteklenmeyen sistem dili Türkçeye düşer', () {
      expect(
        SupportedLocale.fromSystemLocales(const [Locale('de', 'DE')]),
        SupportedLocale.tr,
      );
      expect(SupportedLocale.fromSystemLocales(const []), SupportedLocale.tr);
    });

    test('tercih listesindeki İLK desteklenen dil kazanır', () {
      expect(
        SupportedLocale.fromSystemLocales(const [
          Locale('de', 'DE'),
          Locale('ar', 'EG'),
          Locale('tr', 'TR'),
        ]),
        SupportedLocale.ar,
      );
    });
  });

  group('resolveLaunchLocale önceliği', () {
    test('kaydedilen locale sistem dilinden önceliklidir', () async {
      final resolved = await resolveLaunchLocale(
        repository: _FakeAppLocaleRepository(SupportedLocale.ar),
        systemLocales: const [Locale('tr', 'TR')],
      );
      expect(resolved, SupportedLocale.ar);
    });

    test('kayıt yoksa desteklenen sistem diline düşer', () async {
      final resolved = await resolveLaunchLocale(
        repository: _FakeAppLocaleRepository(),
        systemLocales: const [Locale('en', 'GB')],
      );
      expect(resolved, SupportedLocale.en);
    });

    test(
      'okuma başarısız olsa bile açılış kilitlenmez — tr fallback',
      () async {
        final resolved = await resolveLaunchLocale(
          repository: _FailingAppLocaleRepository(),
          systemLocales: const [Locale('de', 'DE')],
        );
        expect(resolved, SupportedLocale.tr);
      },
    );
  });

  group('AppLocaleController', () {
    test('açılış değeri state olur ve seçim kalıcılaşır', () async {
      final repo = _FakeAppLocaleRepository();
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          appLocaleRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLocaleProvider), SupportedLocale.tr);

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.en);

      expect(container.read(appLocaleProvider), SupportedLocale.en);
      expect(repo.stored, SupportedLocale.en);
    });

    test('aynı dil yeniden seçilince gereksiz yazma yapılmaz', () async {
      final repo = _FakeAppLocaleRepository(SupportedLocale.tr);
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          appLocaleRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.tr);

      expect(repo.saveCount, 0);
    });

    test('kayıt başarısız olsa da oturum içi seçim korunur', () async {
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          appLocaleRepositoryProvider.overrideWithValue(
            _FailingAppLocaleRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.ar);

      expect(container.read(appLocaleProvider), SupportedLocale.ar);
    });
  });

  group('SharedPrefsAppLocaleRepository', () {
    test('seçim restart sonrası (yeni instance) korunur', () async {
      SharedPreferences.setMockInitialValues({});
      const repo = SharedPrefsAppLocaleRepository();

      expect((await repo.loadLocale()).valueOrNull, isNull);

      await repo.saveLocale(SupportedLocale.ar);

      // Yeni instance = yeniden açılan uygulama.
      const reopened = SharedPrefsAppLocaleRepository();
      expect((await reopened.loadLocale()).valueOrNull, SupportedLocale.ar);
    });

    test('bozuk kayıt "seçim yok" sayılır — crash yok', () async {
      SharedPreferences.setMockInitialValues({
        'bismillah.app_locale': 'klingon',
      });
      const repo = SharedPrefsAppLocaleRepository();
      expect((await repo.loadLocale()).valueOrNull, isNull);
    });
  });
}

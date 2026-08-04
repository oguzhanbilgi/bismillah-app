import 'dart:io';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/presentation/prayer_calculation_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 096 — hesaplama yöntemi ekranı: onay akışı, dürüst raporlama,
/// TR/EN/AR eşliği, RTL, büyük yazı ve reduced-motion.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedLocalNow = DateTime(2026, 7, 15, 9);

  late _RecordingRepository repository;

  setUp(() => repository = _RecordingRepository());

  Future<void> pumpScreen(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    double textScale = 1,
    Size size = const Size(360, 800),
    bool reducedMotion = false,
    bool remindersEnabled = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          prayerCalculationMethodRepositoryProvider.overrideWithValue(
            repository,
          ),
          prayerLocationServiceProvider.overrideWithValue(
            const _FakeLocationService(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(
            _FakeReminderStore(enabled: remindersEnabled),
          ),
          localNotificationServiceProvider.overrideWithValue(
            _FakeNotifications(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reducedMotion,
            ),
            child: child!,
          ),
          home: const PrayerCalculationMethodScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Onay diyaloğunu açar ve verilen düğmeye basar.
  Future<void> tapMethodAndConfirm(
    WidgetTester tester,
    String methodName,
    String action,
  ) async {
    await tester.scrollUntilVisible(find.text(methodName), 200);
    await tester.tap(find.text(methodName));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  group('seçenek listesi', () {
    testWidgets('her seçenek gerçek bir motor yöntemine karşılık gelir', (
      tester,
    ) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      // Ekran katalogdan beslenir; katalog motorun kendi preset listesidir.
      for (final method in PrayerTimeCalculationMethod.values) {
        final name = l10n.prayerMethodName(method.stableName);
        expect(
          name.startsWith('prayerMethodName'),
          isFalse,
          reason: '${method.name} için ad anahtarı çözülemedi',
        );
      }
      expect(
        find.text(l10n.prayerMethodName('turkiyeDiyanet')),
        findsOneWidget,
      );
      expect(find.text(l10n.prayerMethodCurrentLabel), findsOneWidget);
    });

    testWidgets('kurumsal onay iddiası reddi her zaman görünür', (
      tester,
    ) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.scrollUntilVisible(
        find.text(l10n.prayerMethodNotEndorsement),
        300,
      );
      expect(find.text(l10n.prayerMethodNotEndorsement), findsOneWidget);
    });
  });

  group('onay akışı', () {
    testWidgets('vazgeçmek hiçbir şeyi değiştirmez', (tester) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapMethodAndConfirm(
        tester,
        l10n.prayerMethodName('egyptian'),
        l10n.prayerMethodConfirmCancel,
      );

      expect(repository.writes, 0);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PrayerCalculationMethodScreen)),
      );
      expect(
        container.read(prayerCalculationMethodProvider),
        PrayerTimeCalculationMethod.turkiyeDiyanet,
      );
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('onaylamak yöntemi uygular ve dürüstçe bildirir', (
      tester,
    ) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      final name = l10n.prayerMethodName('egyptian');
      await tapMethodAndConfirm(tester, name, l10n.prayerMethodConfirmApply);

      expect(repository.writes, 1);
      expect(find.text(l10n.prayerMethodChanged(name)), findsOneWidget);
    });

    testWidgets('onay metni yeniden hesaplamayı ve hatırlatıcıları söyler', (
      tester,
    ) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      final name = l10n.prayerMethodName('egyptian');
      await tester.scrollUntilVisible(find.text(name), 200);
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();

      final body = l10n.prayerMethodConfirmBody(name);
      expect(find.text(body), findsOneWidget);
      expect(body.contains('hesaplan'), isTrue);
      expect(body.contains('hatırlatıcı'), isTrue);
    });

    testWidgets('yazma başarısızsa başarı bildirilmez', (tester) async {
      repository = _RecordingRepository(fail: true);
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      final name = l10n.prayerMethodName('egyptian');
      await tapMethodAndConfirm(tester, name, l10n.prayerMethodConfirmApply);

      expect(find.text(l10n.prayerMethodSaveFailed), findsOneWidget);
      expect(find.text(l10n.prayerMethodChanged(name)), findsNothing);
    });
  });

  group('erişilebilirlik ve sunum', () {
    testWidgets('Arapça RTL olarak çözülür ve Arapça metin gösterir', (
      tester,
    ) async {
      await pumpScreen(tester, locale: SupportedLocale.ar);
      final direction = Directionality.of(
        tester.element(find.byType(PrayerCalculationMethodScreen)),
      );
      expect(direction, TextDirection.rtl);
      const l10n = AppLocalizations(SupportedLocale.ar);
      expect(
        find.text(l10n.prayerMethodName('turkiyeDiyanet')),
        findsOneWidget,
      );
    });

    testWidgets('1.5x yazı ve dar ekranda taşma yok', (tester) async {
      await pumpScreen(tester, textScale: 1.5, size: const Size(360, 640));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.5x yazı ile Arapça onay diyaloğu taşmaz', (tester) async {
      await pumpScreen(
        tester,
        locale: SupportedLocale.ar,
        textScale: 1.5,
        size: const Size(360, 640),
      );
      const l10n = AppLocalizations(SupportedLocale.ar);
      final name = l10n.prayerMethodName('egyptian');
      await tester.scrollUntilVisible(find.text(name), 200);
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.prayerMethodConfirmApply), findsOneWidget);
    });

    testWidgets('reduced-motion açıkken dinlenmede animasyon yoktur', (
      tester,
    ) async {
      await pumpScreen(tester, reducedMotion: true);
      const l10n = AppLocalizations(SupportedLocale.tr);
      final name = l10n.prayerMethodName('egyptian');
      await tapMethodAndConfirm(tester, name, l10n.prayerMethodConfirmApply);

      // Süreler sıfırlandığı için tek bir kare sonrasında ağaç dinlenmededir.
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('seçenek satırı anlamlı tek semantik düğüm sunar', (
      tester,
    ) async {
      await pumpScreen(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          RegExp('^${RegExp.escape(l10n.prayerMethodName('turkiyeDiyanet'))}'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('TR/EN/AR sözlük eşliği', () {
    test('yöntem anahtarları üç dilde de tam ve farklıdır', () {
      final strings = _localeStrings();
      final trKeys = strings['tr']!.keys.where(
        (k) => k.startsWith('prayerMethod'),
      );
      expect(trKeys, isNotEmpty);

      for (final key in trKeys) {
        for (final locale in ['en', 'ar']) {
          expect(
            strings[locale]!.containsKey(key),
            isTrue,
            reason: '$locale sözlüğünde $key eksik',
          );
        }
        // Arapça değer gerçekten Arap harfleriyle yazılmış olmalı; latin bir
        // kopya sessizce İngilizce sızdırırdı.
        if (!key.startsWith('prayerMethodName.') &&
            key != 'prayerMethodAngles' &&
            key != 'prayerMethodInterval') {
          expect(
            RegExp(r'[؀-ۿ]').hasMatch(strings['ar']![key]!),
            isTrue,
            reason: '$key Arapça değeri Arap harfleri içermiyor',
          );
        }
      }
    });

    test('her yöntem için üç dilde de ad tanımlıdır', () {
      final strings = _localeStrings();
      for (final method in PrayerTimeCalculationMethod.values) {
        final key = 'prayerMethodName.${method.stableName}';
        for (final locale in ['tr', 'en', 'ar']) {
          expect(
            strings[locale]!.containsKey(key),
            isTrue,
            reason: '$locale sözlüğünde $key eksik',
          );
        }
      }
    });

    test('hiçbir dilde kurumsal Diyanet onay iddiası yoktur', () {
      final strings = _localeStrings();
      for (final locale in ['tr', 'en', 'ar']) {
        for (final entry in strings[locale]!.entries) {
          if (!entry.key.startsWith('prayerMethod') &&
              entry.key != 'prayerTimesMethodLabel') {
            continue;
          }
          expect(
            entry.value.toLowerCase().contains('diyanet'),
            isFalse,
            reason: '$locale/${entry.key}',
          );
        }
      }
    });
  });
}

/// Sözlükleri okur; nokta içeren anahtarları da yakalar.
Map<String, Map<String, String>> _localeStrings() {
  final lines = File(
    'lib/app/localization/app_localizations.dart',
  ).readAsLinesSync();
  final result = <String, Map<String, String>>{'tr': {}, 'en': {}, 'ar': {}};
  String? current;
  final keyPattern = RegExp(r"^\s{6}'([A-Za-z0-9_.]+)':\s*(.*)$");
  String? pendingKey;
  final buffer = StringBuffer();

  void flush(String locale) {
    if (pendingKey != null) {
      result[locale]![pendingKey!] = buffer.toString();
      pendingKey = null;
      buffer.clear();
    }
  }

  for (final line in lines) {
    final marker = RegExp(
      r'SupportedLocale\.(tr|en|ar):\s*\{',
    ).firstMatch(line);
    if (marker != null) {
      current = marker.group(1);
      continue;
    }
    if (current == null) {
      continue;
    }
    final match = keyPattern.firstMatch(line);
    if (match != null) {
      flush(current);
      pendingKey = match.group(1);
      buffer.write(_unquote(match.group(2)!));
      continue;
    }
    if (pendingKey != null) {
      // Çok satırlı değerler (uzun açıklama metinleri) birleştirilir;
      // aksi hâlde Arapça harf kontrolü boş bir dize üzerinde çalışırdı.
      final trimmed = line.trim();
      if (trimmed.startsWith("'")) {
        buffer.write(_unquote(trimmed));
      } else {
        flush(current);
      }
    }
  }
  if (current != null) {
    flush(current);
  }
  return result;
}

/// Dart kaynak satırındaki tek tırnaklı parçadan metni çıkarır.
String _unquote(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith("'")) {
    return '';
  }
  final end = trimmed.lastIndexOf("'");
  return end <= 0 ? '' : trimmed.substring(1, end);
}

final class _RecordingRepository implements PrayerCalculationMethodRepository {
  _RecordingRepository({this.fail = false});

  final bool fail;
  int writes = 0;

  @override
  ResultFuture<PrayerTimeCalculationMethod?> loadMethod() async =>
      const Result.success(null);

  @override
  ResultFuture<void> saveMethod(PrayerTimeCalculationMethod method) async {
    if (fail) {
      return const Result.failure(StorageFailure());
    }
    writes++;
    return const Result.success(null);
  }
}

final class _FakeLocationService implements PrayerLocationService {
  const _FakeLocationService();

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async =>
      const PrayerLocationResolved(PrayerLocation(coordinates: _istanbul));

  @override
  Future<PrayerLocationResult> requestLocation() async =>
      const PrayerLocationResolved(PrayerLocation(coordinates: _istanbul));

  @override
  Future<void> openAppSettings() async {}
}

const PrayerCoordinates _istanbul = PrayerCoordinates(
  latitude: 41.0082,
  longitude: 28.9784,
);

final class _FakeReminderStore implements ReminderPreferenceStore {
  _FakeReminderStore({required this.enabled});

  bool enabled;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async => enabled = value;
}

final class _FakeNotifications implements LocalNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Stream<String> get reminderTaps => const Stream<String>.empty();

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<NotificationPermissionStatus> checkPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<bool?> requestExactAlarmPermission() async => true;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async {}

  @override
  Future<void> cancelAllPrayerReminders() async {}

  @override
  Future<void> openSettings() async {}
}

import 'dart:io';

import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/data/adhan_calculation_method_catalog.dart';
import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/data/shared_prefs_prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_calculation_method_repository.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 096 — namaz vakti hesaplama yöntemi seçimi.
///
/// Bu dosya davranışı doğrular: motor eşlemesi, kalıcılık, güvenli geri
/// düşme, tek yetkili kaynak, yeniden hesaplama ve bildirim politikası.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const istanbul = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);
  final fixedLocalNow = DateTime(2026, 7, 15, 9);
  const storageKey = 'bismillah.prayer_calculation_method';
  const catalog = AdhanPrayerCalculationMethodCatalog();
  const calculator = AdhanPrayerTimeCalculator();

  final copy = PrayerReminderCopy(
    title: 'Namaz vakti',
    bodyFor: (name) => name.name,
  );

  group('motor eşlemesi — sunulan her yöntem GERÇEKTEN destekleniyor', () {
    test('her yöntem gerçek bir adhan preset\'ine çözülür', () {
      for (final method in PrayerTimeCalculationMethod.values) {
        final params = adhanParametersFor(method);
        // Preset kendi kimliğini taşır; boş/uydurma bir parametre seti değil.
        expect(params.fajrAngle, greaterThan(0), reason: method.name);
        expect(
          params.ishaAngle > 0 || (params.ishaInterval ?? 0) > 0,
          isTrue,
          reason: '${method.name}: yatsı ne açı ne aralık ile tanımlı',
        );
      }
    });

    test('katalog, enum ile aynı listeyi sunar (gizli filtre yok)', () {
      expect(catalog.supportedMethods, PrayerTimeCalculationMethod.values);
      expect(catalog.supportedMethods.toSet(), hasLength(20));
    });

    test('katalog parametreleri hesabın kullandığı preset\'ten okunur', () {
      for (final method in PrayerTimeCalculationMethod.values) {
        final engine = adhanParametersFor(method);
        final shown = catalog.parametersFor(method);
        expect(shown.fajrAngle, engine.fajrAngle, reason: method.name);
        expect(shown.ishaAngle, engine.ishaAngle, reason: method.name);
        expect(
          shown.ishaIntervalMinutes,
          engine.ishaInterval ?? 0,
          reason: method.name,
        );
      }
    });

    test('anlamsız/kapsam dışı preset\'ler BİLİNÇLİ olarak sunulmaz', () {
      // `other` fajr 0 / isha 0 ile gerçek bir yöntem değildir; `jafari` ve
      // `tehran` farklı bir fıkhî geleneğe aittir ve ayrı bir onay kararı
      // gerektirir. Dışlama gizli değildir — burada yazılıdır.
      final exposed = PrayerTimeCalculationMethod.values
          .map((m) => adhanParametersFor(m).method)
          .toSet();
      expect(exposed.contains(adhan.CalculationMethod.other), isFalse);
      expect(exposed.contains(adhan.CalculationMethod.jafari), isFalse);
      expect(exposed.contains(adhan.CalculationMethod.tehran), isFalse);
    });

    test('farklı yöntemler GERÇEKTEN farklı vakitler üretir', () {
      final turkiye = calculator.calculate(
        coordinates: istanbul,
        date: fixedLocalNow,
        method: PrayerTimeCalculationMethod.turkiyeDiyanet,
      );
      final isna = calculator.calculate(
        coordinates: istanbul,
        date: fixedLocalNow,
        method: PrayerTimeCalculationMethod.northAmerica,
      );
      // Yöntem artık gerçekten uygulanıyor (eskiden argüman yok sayılıyordu).
      expect(isna.fajr, isNot(turkiye.fajr));
      expect(isna.isha, isNot(turkiye.isha));
      expect(isna.method, PrayerTimeCalculationMethod.northAmerica);
      expect(isna.isChronological, isTrue);
    });

    test('varsayılan yöntem DEĞİŞMEDİ ve sonuçta açıkça saklanır', () {
      expect(
        PrayerTimeCalculationMethod.defaultMethod,
        PrayerTimeCalculationMethod.turkiyeDiyanet,
      );
      final t = calculator.calculate(
        coordinates: istanbul,
        date: fixedLocalNow,
      );
      expect(t.method, PrayerTimeCalculationMethod.turkiyeDiyanet);
    });

    test('kurumsal iddia: yöntem adı üretim kodunda "Diyanet" DEMEZ', () {
      // `turkiyeDiyanet` yalnız KARARLI depolama anahtarıdır; kullanıcıya
      // görünen etiket localization\'dan gelir ve "Türkiye" der. Etiketin
      // gerçekten Diyanet verisiyle desteklenmediği için kurumsal ad
      // kullanıcıya gösterilmez.
      final tr = _localeStrings()['tr']!;
      expect(tr['prayerMethodName.turkiyeDiyanet'], 'Türkiye');
      for (final entry in tr.entries) {
        if (!entry.key.startsWith('prayerMethod')) {
          continue;
        }
        expect(
          entry.value.toLowerCase().contains('diyanet'),
          isFalse,
          reason: '${entry.key} kurumsal Diyanet iddiası içeriyor',
        );
      }
      // Vakit başlığı da artık sabit bir bölge adı iddia etmez.
      expect(tr['prayerTimesMethodLabel'], 'Hesaplama yöntemi');
    });
  });

  group('kalıcılık ve güvenli geri düşme', () {
    test('seçim yokken mevcut kurulumlar etkin yöntemi KORUR', () async {
      SharedPreferences.setMockInitialValues({});
      const repo = SharedPrefsPrayerCalculationMethodRepository();
      expect((await repo.loadMethod()).valueOrNull, isNull);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(
        container.read(prayerCalculationMethodProvider),
        PrayerTimeCalculationMethod.defaultMethod,
      );
    });

    test('seçim yeniden başlatmadan sonra korunur', () async {
      SharedPreferences.setMockInitialValues({});
      const repo = SharedPrefsPrayerCalculationMethodRepository();
      await repo.saveMethod(PrayerTimeCalculationMethod.egyptian);

      // "Yeniden başlatma": yeni bir depo örneği aynı saklanan baytları okur.
      const restarted = SharedPrefsPrayerCalculationMethodRepository();
      expect(
        (await restarted.loadMethod()).valueOrNull,
        PrayerTimeCalculationMethod.egyptian,
      );
    });

    test('bilinmeyen/bozuk kayıtlı değer GÜVENLE varsayılana düşer', () async {
      for (final stored in <Object>['zzz-unknown', '', 42, true]) {
        SharedPreferences.setMockInitialValues({storageKey: stored});
        const repo = SharedPrefsPrayerCalculationMethodRepository();
        expect(
          (await repo.loadMethod()).valueOrNull,
          isNull,
          reason: 'stored=$stored',
        );
      }
    });

    test('okuma, tanınmayan değeri depoya GERİ YAZMAZ', () async {
      SharedPreferences.setMockInitialValues({storageKey: 'zzz-unknown'});
      const repo = SharedPrefsPrayerCalculationMethodRepository();
      await repo.loadMethod();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.get(storageKey), 'zzz-unknown');
    });

    test('fromStorageKey her kararlı adı çözer', () {
      for (final method in PrayerTimeCalculationMethod.values) {
        expect(
          PrayerTimeCalculationMethod.fromStorageKey(method.stableName),
          method,
        );
      }
    });
  });

  group('tek yetkili kaynak ve yeniden hesaplama', () {
    ProviderContainer buildContainer({
      required _FakeMethodRepository repository,
      required _FakeReminderStore reminders,
      required _FakeNotifications notifications,
      PrayerLocationResult location = const PrayerLocationResolved(
        PrayerLocation(coordinates: istanbul),
      ),
    }) {
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          prayerLocationServiceProvider.overrideWithValue(
            _FakeLocationService(location),
          ),
          prayerCalculationMethodRepositoryProvider.overrideWithValue(
            repository,
          ),
          reminderPreferenceStoreProvider.overrideWithValue(reminders),
          localNotificationServiceProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('başarılı değişiklik görünen vakitleri yeniden hesaplar', () async {
      final container = buildContainer(
        repository: _FakeMethodRepository(),
        reminders: _FakeReminderStore(enabled: false),
        notifications: _FakeNotifications(),
      );

      final before =
          await container.read(prayerTimesControllerProvider.future)
              as PrayerTimesReady;
      expect(before.times.method, PrayerTimeCalculationMethod.turkiyeDiyanet);

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.northAmerica, copy);
      expect(outcome, isA<PrayerMethodApplied>());

      // Bayat önbellek KALMAZ: vakit controller\'ı yöntemi izlediğinden
      // yeniden kurulur ve yeni yöntemle hesaplar.
      final after =
          await container.read(prayerTimesControllerProvider.future)
              as PrayerTimesReady;
      expect(after.times.method, PrayerTimeCalculationMethod.northAmerica);
      expect(after.times.fajr, isNot(before.times.fajr));
    });

    test('Namaz ve Today AYNI seçili yöntemi okur', () async {
      final container = buildContainer(
        repository: _FakeMethodRepository(),
        reminders: _FakeReminderStore(enabled: false),
        notifications: _FakeNotifications(),
      );
      await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.karachi, copy);

      // Her iki yüzey de aynı provider\'ı okur; ayrı bir ayar kaynağı yoktur.
      final times =
          await container.read(prayerTimesControllerProvider.future)
              as PrayerTimesReady;
      expect(
        container.read(prayerCalculationMethodProvider),
        PrayerTimeCalculationMethod.karachi,
      );
      expect(times.times.method, PrayerTimeCalculationMethod.karachi);

      // Hatırlatıcı zamanlayıcısı da aynı kaynağı kullanır.
      final reminders = PrayerReminderScheduler.computeReminders(
        calculator: calculator,
        coordinates: istanbul,
        localNow: fixedLocalNow,
        nowUtc: fixedLocalNow.toUtc(),
        copy: copy,
        method: container.read(prayerCalculationMethodProvider),
      );
      final karachi = calculator.calculate(
        coordinates: istanbul,
        date: fixedLocalNow,
        method: PrayerTimeCalculationMethod.karachi,
      );
      final firstToday = reminders.firstWhere(
        (r) => r.dayKey == '2026-07-15' && r.prayerName == PrayerName.dhuhr,
      );
      expect(firstToday.scheduledUtc, karachi.dhuhr);
    });

    test('aynı yöntemi seçmek hiçbir yazma üretmez', () async {
      final repository = _FakeMethodRepository();
      final container = buildContainer(
        repository: repository,
        reminders: _FakeReminderStore(enabled: false),
        notifications: _FakeNotifications(),
      );
      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.turkiyeDiyanet, copy);
      expect(outcome, isA<PrayerMethodUnchanged>());
      expect(repository.writes, 0);
    });

    test('çift dokunuş TEK işlem üretir', () async {
      final repository = _FakeMethodRepository(writeDelay: true);
      final container = buildContainer(
        repository: repository,
        reminders: _FakeReminderStore(enabled: false),
        notifications: _FakeNotifications(),
      );
      final controller = container.read(
        prayerCalculationMethodProvider.notifier,
      );
      final first = controller.select(
        PrayerTimeCalculationMethod.egyptian,
        copy,
      );
      final second = controller.select(
        PrayerTimeCalculationMethod.egyptian,
        copy,
      );
      final results = await Future.wait([first, second]);

      expect(repository.writes, 1);
      expect(results.whereType<PrayerMethodBusy>(), hasLength(1));
      expect(results.whereType<PrayerMethodApplied>(), hasLength(1));
    });

    test('yazma başarısızsa HİÇBİR ŞEY değişmez', () async {
      final container = buildContainer(
        repository: _FakeMethodRepository(fail: true),
        reminders: _FakeReminderStore(enabled: true),
        notifications: _FakeNotifications(),
      );
      final before =
          await container.read(prayerTimesControllerProvider.future)
              as PrayerTimesReady;

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      expect(outcome, isA<PrayerMethodSaveFailed>());
      expect(
        container.read(prayerCalculationMethodProvider),
        PrayerTimeCalculationMethod.turkiyeDiyanet,
      );
      final after =
          await container.read(prayerTimesControllerProvider.future)
              as PrayerTimesReady;
      expect(after.times.fajr, before.times.fajr);
    });
  });

  group('bildirim güvenliği', () {
    ProviderContainer buildContainer({
      required _FakeReminderStore reminders,
      required _FakeNotifications notifications,
      PrayerLocationResult location = const PrayerLocationResolved(
        PrayerLocation(coordinates: istanbul),
      ),
    }) {
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          prayerLocationServiceProvider.overrideWithValue(
            _FakeLocationService(location),
          ),
          prayerCalculationMethodRepositoryProvider.overrideWithValue(
            _FakeMethodRepository(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(reminders),
          localNotificationServiceProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('hatırlatıcılar KAPALIYSA hiçbir bildirim kurulmaz', () async {
      final notifications = _FakeNotifications();
      final store = _FakeReminderStore(enabled: false);
      final container = buildContainer(
        reminders: store,
        notifications: notifications,
      );

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      expect(outcome, isA<PrayerMethodApplied>());
      expect((outcome as PrayerMethodApplied).remindersRescheduled, isFalse);
      expect(notifications.scheduled, isEmpty);
      expect(notifications.cancelAllCalls, 0);
      // Kullanıcı tercihi DEĞİŞTİRİLMEZ — kapalı kapalı kalır.
      expect(store.writes, 0);
      expect(await store.isEnabled(), isFalse);
    });

    test(
      'hatırlatıcılar AÇIKSA tercih korunur ve çift kurulum olmaz',
      () async {
        final notifications = _FakeNotifications();
        final store = _FakeReminderStore(enabled: true);
        final container = buildContainer(
          reminders: store,
          notifications: notifications,
        );

        final outcome = await container
            .read(prayerCalculationMethodProvider.notifier)
            .select(PrayerTimeCalculationMethod.egyptian, copy);

        expect(outcome, isA<PrayerMethodApplied>());
        expect((outcome as PrayerMethodApplied).remindersRescheduled, isTrue);
        // Önce YALNIZ kendi hatırlatıcıları iptal edilir → çift birikmez.
        expect(notifications.cancelAllCalls, 1);
        expect(notifications.scheduled, isNotEmpty);
        final ids = notifications.scheduled.map((r) => r.id).toList();
        expect(ids.toSet().length, ids.length, reason: 'çift bildirim kuruldu');
        // Tercih yazılmaz — kullanıcı ayarına dokunulmaz.
        expect(store.writes, 0);
        expect(await store.isEnabled(), isTrue);
      },
    );

    test('geçmiş vakitler için bildirim YENİDEN yaratılmaz', () async {
      final notifications = _FakeNotifications();
      final container = buildContainer(
        reminders: _FakeReminderStore(enabled: true),
        notifications: notifications,
      );
      await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      final nowUtc = fixedLocalNow.toUtc();
      for (final reminder in notifications.scheduled) {
        expect(reminder.scheduledUtc.isAfter(nowUtc), isTrue);
      }
    });

    test('yeni bildirimler SEÇİLEN yöntemle hesaplanır', () async {
      final notifications = _FakeNotifications();
      final container = buildContainer(
        reminders: _FakeReminderStore(enabled: true),
        notifications: notifications,
      );
      await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      final egyptian = calculator.calculate(
        coordinates: istanbul,
        date: fixedLocalNow,
        method: PrayerTimeCalculationMethod.egyptian,
      );
      final asrToday = notifications.scheduled.firstWhere(
        (r) => r.dayKey == '2026-07-15' && r.prayerName == PrayerName.asr,
      );
      expect(asrToday.scheduledUtc, egyptian.asr);
    });

    test('yeniden kurulum başarısızsa TAM başarı bildirilmez', () async {
      final notifications = _FakeNotifications()..throwOnSchedule = true;
      final container = buildContainer(
        reminders: _FakeReminderStore(enabled: true),
        notifications: notifications,
      );

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      expect(outcome, isA<PrayerMethodRemindersNotUpdated>());
      // Yöntem yine de yazılıdır (politika B) — vakitler tutarlıdır.
      expect(
        container.read(prayerCalculationMethodProvider),
        PrayerTimeCalculationMethod.egyptian,
      );
    });

    test('bildirim izni yoksa yeni izin İSTENMEZ, kısmi sonuç döner', () async {
      final notifications = _FakeNotifications()
        ..permission = NotificationPermissionStatus.denied;
      final container = buildContainer(
        reminders: _FakeReminderStore(enabled: true),
        notifications: notifications,
      );

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      expect(outcome, isA<PrayerMethodRemindersNotUpdated>());
      expect(notifications.permissionRequests, 0);
      expect(notifications.scheduled, isEmpty);
    });

    test('konum hazır değilse kısmi sonuç döner (yeni istem yok)', () async {
      final notifications = _FakeNotifications();
      final location = _FakeLocationService(const PrayerLocationUnavailable());
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          prayerLocationServiceProvider.overrideWithValue(location),
          prayerCalculationMethodRepositoryProvider.overrideWithValue(
            _FakeMethodRepository(),
          ),
          reminderPreferenceStoreProvider.overrideWithValue(
            _FakeReminderStore(enabled: true),
          ),
          localNotificationServiceProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      expect(outcome, isA<PrayerMethodRemindersNotUpdated>());
      expect(location.requestCalls, 0);
      expect(notifications.scheduled, isEmpty);
    });

    test(
      'yeniden deneme yalnız bildirimleri kurar, yöntemi tekrar yazmaz',
      () async {
        final notifications = _FakeNotifications()..throwOnSchedule = true;
        final repository = _FakeMethodRepository();
        final container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
            prayerLocationServiceProvider.overrideWithValue(
              _FakeLocationService(
                const PrayerLocationResolved(
                  PrayerLocation(coordinates: istanbul),
                ),
              ),
            ),
            prayerCalculationMethodRepositoryProvider.overrideWithValue(
              repository,
            ),
            reminderPreferenceStoreProvider.overrideWithValue(
              _FakeReminderStore(enabled: true),
            ),
            localNotificationServiceProvider.overrideWithValue(notifications),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(
          prayerCalculationMethodProvider.notifier,
        );

        expect(
          await controller.select(PrayerTimeCalculationMethod.egyptian, copy),
          isA<PrayerMethodRemindersNotUpdated>(),
        );
        expect(repository.writes, 1);

        notifications.throwOnSchedule = false;
        final retry = await controller.retryReminderReschedule(copy);
        expect(retry, isA<PrayerMethodApplied>());
        expect((retry as PrayerMethodApplied).remindersRescheduled, isTrue);
        // Yöntem yeniden YAZILMAZ — zaten kayıtlıdır.
        expect(repository.writes, 1);
        expect(notifications.scheduled, isNotEmpty);
      },
    );
  });

  group('kapsam sınırı — plan ve geçmiş verisine dokunulmaz', () {
    test('yöntem değişimi hiçbir plan/geçmiş anahtarını değiştirmez', () async {
      const planKey = 'bismillah.daily_plans';
      const planPayload = '{"version":1,"plans":{}}';
      SharedPreferences.setMockInitialValues({
        planKey: planPayload,
        'bismillah.prayer_reminders_enabled': false,
      });

      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          prayerLocationServiceProvider.overrideWithValue(
            _FakeLocationService(
              const PrayerLocationResolved(
                PrayerLocation(coordinates: istanbul),
              ),
            ),
          ),
          localNotificationServiceProvider.overrideWithValue(
            _FakeNotifications(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(prayerCalculationMethodProvider.notifier)
          .select(PrayerTimeCalculationMethod.egyptian, copy);

      final prefs = await SharedPreferences.getInstance();
      // Plan kaydı BAYT BAYT aynıdır; tamamlama/geçmiş silinmez.
      expect(prefs.getString(planKey), planPayload);
      // Yalnız yöntem anahtarı eklenir.
      expect(prefs.getString(storageKey), 'egyptian');
    });
  });
}

/// `app_localizations.dart` sözlüklerini okur. Nokta içeren anahtarlar
/// (`prayerMethodName.<id>`) da yakalanır — mevcut TASK 094 ayrıştırıcısı
/// yalnız harf/rakam kabul ettiği için bu yöntem adlarını GÖRMEZ.
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

final class _FakeMethodRepository implements PrayerCalculationMethodRepository {
  _FakeMethodRepository({this.fail = false, this.writeDelay = false});

  final bool fail;
  final bool writeDelay;
  int writes = 0;
  PrayerTimeCalculationMethod? stored;

  @override
  ResultFuture<PrayerTimeCalculationMethod?> loadMethod() async =>
      Result.success(stored);

  @override
  ResultFuture<void> saveMethod(PrayerTimeCalculationMethod method) async {
    if (writeDelay) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    if (fail) {
      return const Result.failure(StorageFailure());
    }
    writes++;
    stored = method;
    return const Result.success(null);
  }
}

final class _FakeReminderStore implements ReminderPreferenceStore {
  _FakeReminderStore({required this.enabled});

  bool enabled;
  int writes = 0;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool value) async {
    writes++;
    enabled = value;
  }
}

final class _FakeLocationService implements PrayerLocationService {
  _FakeLocationService(this._result);

  final PrayerLocationResult _result;
  int requestCalls = 0;

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async => _result;

  @override
  Future<PrayerLocationResult> requestLocation() async {
    requestCalls++;
    return _result;
  }

  @override
  Future<void> openAppSettings() async {}
}

final class _FakeNotifications implements LocalNotificationService {
  NotificationPermissionStatus permission =
      NotificationPermissionStatus.granted;
  bool throwOnSchedule = false;
  int cancelAllCalls = 0;
  int permissionRequests = 0;
  final List<PrayerReminder> scheduled = [];

  @override
  Future<void> initialize() async {}

  @override
  Stream<String> get reminderTaps => const Stream<String>.empty();

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<NotificationPermissionStatus> checkPermission() async => permission;

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<bool?> requestExactAlarmPermission() async => true;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async {
    if (throwOnSchedule) {
      throw StateError('schedule failed');
    }
    scheduled.add(reminder);
  }

  @override
  Future<void> cancelAllPrayerReminders() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<void> openSettings() async {}
}

import 'dart:async';
import 'dart:io';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/qibla/application/qibla_controller.dart';
import 'package:bismillah_app/features/qibla/application/qibla_state.dart';
import 'package:bismillah_app/features/qibla/data/qibla_providers.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';
import 'package:bismillah_app/features/qibla/presentation/qibla_screen.dart';
import 'package:bismillah_app/features/qibla/presentation/widgets/qibla_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// TASK 095 — Kıble ekranı: konum yeniden kullanımı, dürüst yedek
/// durumlar, hizalanma, dil/RTL/erişilebilirlik.
///
/// Gerçek pusula donanımı test EDİLMEZ: sensör akışı soyutlanmış ve
/// belirlenimci sahte okumalarla beslenmiştir.
void main() {
  const istanbul = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);
  // İstanbul için kıble ~151.6 derece (bağımsız olarak yayımlanmış değer).
  const istanbulQibla = 151.6;

  late _RecordingLocationService location;
  late _FakeCompassService compass;

  setUp(() {
    location = _RecordingLocationService(
      const PrayerLocationResolved(PrayerLocation(coordinates: istanbul)),
    );
    compass = _FakeCompassService();
  });

  tearDown(() => compass.dispose());

  List<Override> overrides() => [
    prayerLocationServiceProvider.overrideWithValue(location),
    qiblaCompassServiceProvider.overrideWithValue(compass),
  ];

  Future<void> pumpScreen(
    WidgetTester tester, {
    String locale = 'tr',
    double textScale = 1.0,
    Size size = const Size(1080, 2400),
    bool reducedMotion = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(locale),
          supportedLocales: [Locale(locale)],
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
          home: const QiblaScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Ağacı test gövdesi içinde söker: provider dispose olur, pusula
  /// aboneliği ve zaman aşımı timer'ı iptal edilir.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  group('mevcut konumun yeniden kullanımı', () {
    testWidgets('ekran açılışında YENİ izin isteği tetiklenmez', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(location.permittedCalls, 1);
      expect(
        location.requestCalls,
        0,
        reason: 'izin zaten verilmişse platform diyaloğu açılmamalı',
      );

      await unmount(tester);
    });

    testWidgets('izin yokken önce gerekçe gösterilir, istek kullanıcı '
        'dokununca yapılır', (tester) async {
      location = _RecordingLocationService(
        const PrayerLocationPermissionDenied(permanentlyDenied: false),
        onRequest: const PrayerLocationResolved(
          PrayerLocation(coordinates: istanbul),
        ),
      );
      await pumpScreen(tester);

      expect(
        find.textContaining('Kıble yönünü hesaplamak için'),
        findsOneWidget,
      );
      expect(location.requestCalls, 0);

      await tester.tap(find.text('Konumu kullan'));
      await tester.pumpAndSettle();

      expect(location.requestCalls, 1);
      // İzin verildikten sonra gerçek açı gösterilir.
      expect(find.text('${istanbulQibla.round()}°'), findsOneWidget);
      expect(
        find.textContaining('Kıble yönünü hesaplamak için'),
        findsNothing,
      );

      await unmount(tester);
    });

    testWidgets('kalıcı reddedilmiş izinde ayar yolu sunulur', (tester) async {
      location = _RecordingLocationService(
        const PrayerLocationPermissionDenied(permanentlyDenied: true),
      );
      await pumpScreen(tester);

      expect(find.textContaining('Konum izni kapalı'), findsOneWidget);
      await tester.tap(find.text('Ayarları aç'));
      await tester.pumpAndSettle();

      expect(location.settingsCalls, 1);
      expect(location.requestCalls, 0);

      await unmount(tester);
    });
  });

  group('dürüst yedek durumlar', () {
    testWidgets('konum servisi kapalı ayrı ve açık biçimde anlatılır', (
      tester,
    ) async {
      location = _RecordingLocationService(
        const PrayerLocationServiceDisabled(),
      );
      await pumpScreen(tester);

      expect(
        find.textContaining('Cihazın konum servisi kapalı'),
        findsOneWidget,
      );
      // İzin isteme YOLU SUNULMAZ: burada izin sorunu yok.
      expect(find.text('Konumu kullan'), findsNothing);

      await unmount(tester);
    });

    testWidgets('konum alınamadı durumu ayrı metin gösterir', (tester) async {
      location = _RecordingLocationService(const PrayerLocationUnavailable());
      await pumpScreen(tester);

      expect(find.textContaining('Konum şu an alınamadı'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('hesaplanamayan konum sakin bir hata durumu üretir', (
      tester,
    ) async {
      location = _RecordingLocationService(
        const PrayerLocationResolved(
          PrayerLocation(
            coordinates: PrayerCoordinates(
              latitude: double.nan,
              longitude: 0,
            ),
          ),
        ),
      );
      await pumpScreen(tester);

      expect(find.textContaining('hesaplanamadı'), findsOneWidget);
      expect(find.byType(QiblaDial), findsNothing);

      await unmount(tester);
    });

    testWidgets('pusula sensörü yoksa SABİT kıble açısı gösterilmeye '
        'devam eder', (tester) async {
      await pumpScreen(tester);
      compass.emit(const QiblaCompassUnsupported());
      await tester.pumpAndSettle();

      expect(find.text('152°'), findsOneWidget);
      expect(find.byType(QiblaDial), findsOneWidget);
      expect(
        find.textContaining('pusula sensörü bulunamadı'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Yalnız kuzeyden ölçülen kıble açısı'),
        findsOneWidget,
      );

      // Statik yedekte kadran kuzeye sabitlenir (okuma yok).
      final dial = tester.widget<QiblaDial>(find.byType(QiblaDial));
      expect(dial.headingDegrees, isNull);
      expect(dial.qiblaBearingDegrees, closeTo(istanbulQibla, 1));

      await unmount(tester);
    });

    testWidgets('okuma gelmezse geçici kullanılamazlık dürüstçe söylenir', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(find.textContaining('Pusula okuması bekleniyor'), findsOneWidget);

      await tester.pump(kQiblaHeadingTimeout + const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Yön okuması şu an alınamıyor'),
        findsOneWidget,
      );
      expect(find.text('152°'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('akış hatası ekranı bozmaz', (tester) async {
      await pumpScreen(tester);
      compass.emitError(Exception('platform failure'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Yön okuması şu an alınamıyor'),
        findsOneWidget,
      );
      expect(find.byType(QiblaDial), findsOneWidget);

      await unmount(tester);
    });
  });

  group('hizalanma', () {
    testWidgets('kıbleye dönükken hizalı durumu gösterilir', (tester) async {
      await pumpScreen(tester);
      compass.emit(
        const QiblaCompassHeading(
          degrees: istanbulQibla,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('kıble yönüne dönük'), findsOneWidget);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isTrue);

      await unmount(tester);
    });

    testWidgets('kıbleden uzakken çevirme ipucu gösterilir', (tester) async {
      await pumpScreen(tester);
      compass.emit(
        const QiblaCompassHeading(
          degrees: 10,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('yavaşça çevir'), findsOneWidget);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isFalse);

      await unmount(tester);
    });

    testWidgets('düşük güvenli okumada kalibrasyon uyarısı çıkar', (
      tester,
    ) async {
      await pumpScreen(tester);
      compass.emit(
        const QiblaCompassHeading(
          degrees: 10,
          confidence: QiblaHeadingConfidence.unreliable,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('oynak görünüyor'), findsOneWidget);

      await unmount(tester);
    });
  });

  group('gürültü yumuşatma (controller seviyesinde)', () {
    test('küçük oynamalar yeni durum yayınlamaz, gerçek dönüş yayınlar', () async {
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);

      await container.read(qiblaControllerProvider.future);
      // `_scheduleCompass` olay döngüsünün bir sonraki turunda abone olur.
      await Future<void>.delayed(Duration.zero);
      expect(compass.listenCount, 1);
      expect(compass.lastLatitude, istanbul.latitude);

      var updates = 0;
      container.listen(qiblaControllerProvider, (_, _) => updates++);

      compass.emit(
        const QiblaCompassHeading(
          degrees: 100,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      final afterFirst = updates;
      expect(afterFirst, 1, reason: 'ilk okuma beklemeden gösterilmeli');

      for (final noisy in <double>[100.3, 99.8, 100.1, 99.9, 100.2]) {
        compass.emit(
          QiblaCompassHeading(
            degrees: noisy,
            confidence: QiblaHeadingConfidence.high,
          ),
        );
        await Future<void>.delayed(Duration.zero);
      }
      expect(
        updates,
        afterFirst,
        reason: 'eşik altındaki gürültü yeni kare üretmemeli (ibre titremez)',
      );

      compass.emit(
        const QiblaCompassHeading(
          degrees: 250,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        updates,
        greaterThan(afterFirst),
        reason: 'gerçek dönüş anında yansımalı',
      );

      final state = container.read(qiblaControllerProvider).value! as QiblaReady;
      final active = state.compass as QiblaCompassActiveStatus;
      expect(active.headingDegrees, closeTo(250, 1e-6));
    });
  });

  group('dil, RTL ve erişilebilirlik', () {
    test('kıble anahtarları TR/EN/AR sözlüklerinin ÜÇÜNDE de vardır', () {
      final lines = File(
        'lib/app/localization/app_localizations.dart',
      ).readAsLinesSync();

      final byLocale = <String, Map<String, String>>{
        'tr': {},
        'en': {},
        'ar': {},
      };
      String? current;
      final keyPattern = RegExp(r"^\s{6}'(qibla[A-Za-z0-9_]*)':\s*(.*)$");

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
          byLocale[current]![match.group(1)!] = match.group(2)!;
        }
      }

      expect(byLocale['tr']!.length, greaterThanOrEqualTo(25));
      expect(byLocale['en']!.keys.toSet(), byLocale['tr']!.keys.toSet());
      expect(byLocale['ar']!.keys.toSet(), byLocale['tr']!.keys.toSet());
    });

    test('Arapça kıble metinleri Arap harfi içerir ve TR ile aynı değildir', () {
      const arabic = AppLocalizations(SupportedLocale.ar);
      const turkish = AppLocalizations(SupportedLocale.tr);
      final arabicScript = RegExp(r'[؀-ۿ]');

      for (final pair
          in <(String Function(AppLocalizations), String)>[
            ((l) => l.qiblaTitle, 'qiblaTitle'),
            ((l) => l.qiblaBearingLabel, 'qiblaBearingLabel'),
            ((l) => l.qiblaAligned, 'qiblaAligned'),
            ((l) => l.qiblaCompassUnsupported, 'qiblaCompassUnsupported'),
            ((l) => l.qiblaLocationInvite, 'qiblaLocationInvite'),
            ((l) => l.qiblaHonestyNote, 'qiblaHonestyNote'),
          ]) {
        final arabicValue = pair.$1(arabic);
        expect(
          arabicScript.hasMatch(arabicValue),
          isTrue,
          reason: '${pair.$2} Arapça değil',
        );
        expect(
          arabicValue,
          isNot(pair.$1(turkish)),
          reason: '${pair.$2} Türkçe ile aynı kalmış',
        );
      }
    });

    testWidgets('Arapça yerelde ekran RTL çözülür ve kadran render edilir', (
      tester,
    ) async {
      await pumpScreen(tester, locale: 'ar');
      compass.emit(
        const QiblaCompassHeading(
          degrees: istanbulQibla,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await tester.pumpAndSettle();

      final direction = Directionality.of(
        tester.element(find.byType(QiblaDial)),
      );
      expect(direction, TextDirection.rtl);
      expect(find.text('القبلة'), findsWidgets);
      expect(find.text('152°'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('İngilizce yerelde LTR ve İngilizce metin gelir', (
      tester,
    ) async {
      await pumpScreen(tester, locale: 'en');
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(QiblaDial))),
        TextDirection.ltr,
      );
      expect(find.textContaining('Qibla angle from north'), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('1.5x metin ölçeğinde dar ekranda taşma olmaz', (tester) async {
      await pumpScreen(
        tester,
        textScale: 1.5,
        size: const Size(360, 1400),
      );
      compass.emit(
        const QiblaCompassHeading(
          degrees: 10,
          confidence: QiblaHeadingConfidence.low,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(QiblaDial), findsOneWidget);

      await unmount(tester);
    });

    testWidgets('Arapça + 1.5x metin ölçeğinde de taşma olmaz', (tester) async {
      await pumpScreen(
        tester,
        locale: 'ar',
        textScale: 1.5,
        size: const Size(360, 1400),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await unmount(tester);
    });

    testWidgets('yön ve hizalanma ekran okuyucuya bildirilir', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester);
      compass.emit(
        const QiblaCompassHeading(
          degrees: istanbulQibla,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('kuzeyden 152 derece')),
        findsOneWidget,
      );

      handle.dispose();
      await unmount(tester);
    });

    testWidgets('reduced-motion açıkken durum geçişi anında tamamlanır', (
      tester,
    ) async {
      await pumpScreen(tester, reducedMotion: true);
      compass.emit(
        const QiblaCompassHeading(
          degrees: istanbulQibla,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      // pumpAndSettle YOK: tek kare sonra geçiş bitmiş olmalı.
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('kıble yönüne dönük'), findsOneWidget);
      expect(
        find.textContaining('Pusula okuması bekleniyor'),
        findsNothing,
        reason: 'reduced-motion açıkken eski durum çapraz geçişte kalmamalı',
      );

      await unmount(tester);
    });
  });
}

/// Çağrıları sayan sahte konum servisi.
final class _RecordingLocationService implements PrayerLocationService {
  _RecordingLocationService(this._ifPermitted, {PrayerLocationResult? onRequest})
    : _onRequest = onRequest ?? _ifPermitted;

  final PrayerLocationResult _ifPermitted;
  final PrayerLocationResult _onRequest;

  int permittedCalls = 0;
  int requestCalls = 0;
  int settingsCalls = 0;

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async {
    permittedCalls++;
    return _ifPermitted;
  }

  @override
  Future<PrayerLocationResult> requestLocation() async {
    requestCalls++;
    return _onRequest;
  }

  @override
  Future<void> openAppSettings() async {
    settingsCalls++;
  }
}

/// Belirlenimci sahte pusula akışı — gerçek sensör KULLANILMAZ.
final class _FakeCompassService implements QiblaCompassService {
  final StreamController<QiblaCompassEvent> _controller =
      StreamController<QiblaCompassEvent>.broadcast();

  int listenCount = 0;
  double? lastLatitude;
  double? lastLongitude;

  @override
  Stream<QiblaCompassEvent> headings({
    required double latitude,
    required double longitude,
  }) {
    listenCount++;
    lastLatitude = latitude;
    lastLongitude = longitude;
    return _controller.stream;
  }

  void emit(QiblaCompassEvent event) => _controller.add(event);

  void emitError(Object error) => _controller.addError(error);

  void dispose() => _controller.close();
}

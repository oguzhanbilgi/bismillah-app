import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_location.dart';
import 'package:bismillah_app/features/qibla/data/qibla_providers.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';
import 'package:bismillah_app/features/qibla/presentation/qibla_screen.dart';
import 'package:bismillah_app/features/qibla/presentation/widgets/kaaba_emblem.dart';
import 'package:bismillah_app/features/qibla/presentation/widgets/qibla_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// TASK 095 — kadranın görsel sunumu: merkezdeki Kâbe, dik duran
/// etiketler, aynalanmayan yön ve ölçülü hizalanma vurgusu.
///
/// Fiziksel pusula doğruluğu burada da ÖLÇÜLMEZ; okumalar belirlenimci
/// sahte akıştan gelir.
void main() {
  // Sabit konum İstanbul'dur (bkz. [_StubLocationService]); kıblesi
  // ~151.6 derece, hizalanma toleransı 5 derecedir.
  const alignedHeading = 151.6;

  late _FakeCompassService compass;

  setUp(() => compass = _FakeCompassService());
  tearDown(() => compass.dispose());

  List<Override> overrides() => [
    prayerLocationServiceProvider.overrideWithValue(
      const _StubLocationService(),
    ),
    qiblaCompassServiceProvider.overrideWithValue(compass),
  ];

  Future<void> pumpScreen(
    WidgetTester tester, {
    String locale = 'tr',
    double textScale = 1.0,
    Size size = const Size(1080, 2400),
    bool reducedMotion = false,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final theme = AppTheme.light();
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: brightness == Brightness.light
              ? theme
              : theme.copyWith(
                  // Koyu tema henüz bağlanmadı; koyu bir `ColorScheme`
                  // altında da kadranın çizilebildiği doğrulanır.
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: theme.colorScheme.primary,
                    brightness: Brightness.dark,
                  ),
                ),
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

  Future<void> emitHeading(WidgetTester tester, double degrees) async {
    compass.emit(
      QiblaCompassHeading(
        degrees: degrees,
        confidence: QiblaHeadingConfidence.high,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  /// Bir render nesnesinin ekrana kadar olan dönüşümü.
  Matrix4 transformOf(WidgetTester tester, Finder finder) =>
      tester.renderObject(finder).getTransformTo(null);

  group('Kâbe yerleşimi', () {
    testWidgets('Kâbe kadranın TAM MERKEZİNDEDİR', (tester) async {
      await pumpScreen(tester);
      await emitHeading(tester, 40);

      final dialCenter = tester.getCenter(find.byType(QiblaDial));
      final kaabaCenter = tester.getCenter(find.byType(KaabaEmblem));

      expect(kaabaCenter.dx, closeTo(dialCenter.dx, 0.5));
      expect(kaabaCenter.dy, closeTo(dialCenter.dy, 0.5));

      await unmount(tester);
    });

    testWidgets('halka dönerken Kâbe DİK kalır ve yer değiştirmez', (
      tester,
    ) async {
      await pumpScreen(tester);
      await emitHeading(tester, 0);

      final firstCenter = tester.getCenter(find.byType(KaabaEmblem));
      final firstRing = tester.widget<CustomPaint>(
        find.byKey(QiblaDial.compassRingKey),
      );

      await emitHeading(tester, 120);

      // Halka gerçekten döndü: yeni boyayıcı, eskisine göre yeniden
      // boyama gerektirir.
      final secondRing = tester.widget<CustomPaint>(
        find.byKey(QiblaDial.compassRingKey),
      );
      expect(
        secondRing.painter!.shouldRepaint(firstRing.painter!),
        isTrue,
        reason: 'yön değiştiğinde halka katmanı yeniden boyanmalı',
      );

      // Kâbe ise ne döndü ne de kaydı.
      final matrix = transformOf(tester, find.byType(KaabaEmblem));
      expect(
        matrix.storage[1],
        closeTo(0, 1e-6),
        reason: 'Kâbe dönüş/eğim bileşeni taşımamalı',
      );
      expect(matrix.storage[4], closeTo(0, 1e-6));

      final secondCenter = tester.getCenter(find.byType(KaabaEmblem));
      expect(secondCenter.dx, closeTo(firstCenter.dx, 0.5));
      expect(secondCenter.dy, closeTo(firstCenter.dy, 0.5));

      await unmount(tester);
    });

    testWidgets('Kâbe koyu bir renk şemasında da çizilir', (tester) async {
      await pumpScreen(tester, brightness: Brightness.dark);
      await emitHeading(tester, alignedHeading);

      expect(find.byType(KaabaEmblem), findsOneWidget);
      expect(tester.takeException(), isNull);

      await unmount(tester);
    });
  });

  group('yön aynalanmaz', () {
    test('kadran konumu YALNIZ açıdan türer (metin yönü girdi değildir)', () {
      const center = Offset(100, 100);

      final north = QiblaDialGeometry.pointAt(center, 0, 50);
      final east = QiblaDialGeometry.pointAt(center, 90, 50);
      final south = QiblaDialGeometry.pointAt(center, 180, 50);
      final west = QiblaDialGeometry.pointAt(center, 270, 50);

      // Kuzey yukarı, doğu SAĞ, güney aşağı, batı SOL — her dilde aynı.
      expect(north.dy, lessThan(center.dy));
      expect(north.dx, closeTo(center.dx, 1e-6));
      expect(east.dx, greaterThan(center.dx));
      expect(east.dy, closeTo(center.dy, 1e-6));
      expect(south.dy, greaterThan(center.dy));
      expect(west.dx, lessThan(center.dx));
    });

    testWidgets('Arapça RTL kadranı yatayda çevirmez', (tester) async {
      await pumpScreen(tester, locale: 'ar');
      await emitHeading(tester, 40);

      expect(
        Directionality.of(tester.element(find.byType(QiblaDial))),
        TextDirection.rtl,
      );

      final ring = transformOf(tester, find.byKey(QiblaDial.compassRingKey));
      expect(
        ring.storage[0],
        greaterThan(0),
        reason: 'yatay ölçek negatif olursa pusula aynalanmış olur',
      );
      expect(ring.storage[5], greaterThan(0));

      // Kâbe RTL'de de tam merkezde kalır.
      final dialCenter = tester.getCenter(find.byType(QiblaDial));
      final kaabaCenter = tester.getCenter(find.byType(KaabaEmblem));
      expect(kaabaCenter.dx, closeTo(dialCenter.dx, 0.5));

      await unmount(tester);
    });

    testWidgets('yön harfleri Arapçada Arapça, Türkçede Türkçedir', (
      tester,
    ) async {
      const arabic = AppLocalizations(SupportedLocale.ar);
      const turkish = AppLocalizations(SupportedLocale.tr);
      const english = AppLocalizations(SupportedLocale.en);

      expect(turkish.qiblaCardinalNorth, 'K');
      expect(english.qiblaCardinalNorth, 'N');
      expect(arabic.qiblaCardinalNorth, isNot(turkish.qiblaCardinalNorth));
      expect(RegExp(r'[؀-ۿ]').hasMatch(arabic.qiblaCardinalNorth), isTrue);

      await pumpScreen(tester);
      expect(find.byType(QiblaDial), findsOneWidget);
      await unmount(tester);
    });
  });

  group('hizalanma vurgusu', () {
    testWidgets('vurgu her okumada değil, GİRİŞTE bir kez tetiklenir', (
      tester,
    ) async {
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments.toString());
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpScreen(tester);

      // Hizasız okumalar vurgu üretmez.
      await emitHeading(tester, 10);
      await emitHeading(tester, 30);
      expect(haptics, isEmpty);

      // Hizalanmaya giriş: tam bir kez.
      await emitHeading(tester, alignedHeading);
      expect(haptics, hasLength(1));

      // Hizalı kalırken gelen yeni okumalar YENİDEN tetiklemez.
      await emitHeading(tester, alignedHeading - 2);
      await emitHeading(tester, alignedHeading + 3);
      await emitHeading(tester, alignedHeading - 1);
      expect(
        haptics,
        hasLength(1),
        reason: 'hizalı kalmak tek başına vurgu tetiklememeli',
      );

      // Çıkıp yeniden girmek ikinci bir vurgu üretir.
      await emitHeading(tester, 20);
      expect(haptics, hasLength(1));
      await emitHeading(tester, alignedHeading);
      expect(haptics, hasLength(2));

      await unmount(tester);
    });

    testWidgets('vurgu SONLUDUR — bir süre sonra çalışan animasyon kalmaz', (
      tester,
    ) async {
      await pumpScreen(tester);
      await emitHeading(tester, 10);

      compass.emit(
        const QiblaCompassHeading(
          degrees: alignedHeading,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      // İlk kare olayı taşır, ikinci kare yeniden inşayı uygular.
      await tester.pump();
      await tester.pump();
      // Vurgu oynarken animasyon vardır...
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpAndSettle();
      // ...ve biter. Kalıcı/dekoratif animasyon YOKTUR.
      expect(tester.hasRunningAnimations, isFalse);

      await unmount(tester);
    });

    testWidgets('reduced-motion açıkken dekoratif hizalanma animasyonu '
        'HİÇ oynamaz', (tester) async {
      await pumpScreen(tester, reducedMotion: true);
      await emitHeading(tester, 10);

      compass.emit(
        const QiblaCompassHeading(
          degrees: alignedHeading,
          confidence: QiblaHeadingConfidence.high,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        tester.hasRunningAnimations,
        isFalse,
        reason: 'azaltılmış harekette ölçek vurgusu ve halka oynamamalı',
      );
      // Durum yine de anında ve tam olarak anlaşılır.
      expect(find.textContaining('kıble yönüne dönük'), findsOneWidget);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isTrue);

      await unmount(tester);
    });

    testWidgets('hizadan çıkınca sakin biçimde normale döner', (tester) async {
      await pumpScreen(tester);
      await emitHeading(tester, alignedHeading);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isTrue);

      await emitHeading(tester, 40);
      expect(tester.widget<QiblaDial>(find.byType(QiblaDial)).aligned, isFalse);
      expect(tester.hasRunningAnimations, isFalse);

      await unmount(tester);
    });
  });

  group('erişilebilirlik ve büyük metin', () {
    testWidgets('Kâbe ekran okuyucuya yön hedefi olarak tanıtılır', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester);
      await emitHeading(tester, alignedHeading);

      expect(
        find.bySemanticsLabel(RegExp('Kâbe')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('kuzeyden 152 derece')),
        findsOneWidget,
      );

      handle.dispose();
      await unmount(tester);
    });

    testWidgets('1.5x metin ve dar ekranda kadran taşma üretmez', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        textScale: 1.5,
        size: const Size(360, 1500),
      );
      await emitHeading(tester, alignedHeading);

      expect(tester.takeException(), isNull);
      expect(find.byType(KaabaEmblem), findsOneWidget);

      // Kadran dar ekrana sığar.
      final dial = tester.getRect(find.byType(QiblaDial));
      expect(dial.width, lessThanOrEqualTo(360));

      await unmount(tester);
    });

    testWidgets('Arapça + 1.5x metin ölçeğinde de taşma yok', (tester) async {
      await pumpScreen(
        tester,
        locale: 'ar',
        textScale: 1.5,
        size: const Size(360, 1500),
      );
      await emitHeading(tester, alignedHeading);

      expect(tester.takeException(), isNull);

      await unmount(tester);
    });
  });
}

/// Konum davranışı bu dosyada test EDİLMEZ: sabit, izin verilmiş konum.
final class _StubLocationService implements PrayerLocationService {
  const _StubLocationService();

  static const PrayerLocationResult _resolved = PrayerLocationResolved(
    PrayerLocation(
      coordinates: PrayerCoordinates(latitude: 41.0082, longitude: 28.9784),
    ),
  );

  @override
  Future<PrayerLocationResult> currentLocationIfPermitted() async => _resolved;

  @override
  Future<PrayerLocationResult> requestLocation() async => _resolved;

  @override
  Future<void> openAppSettings() async {}
}

final class _FakeCompassService implements QiblaCompassService {
  final StreamController<QiblaCompassEvent> _controller =
      StreamController<QiblaCompassEvent>.broadcast();

  @override
  Stream<QiblaCompassEvent> headings({
    required double latitude,
    required double longitude,
  }) => _controller.stream;

  void emit(QiblaCompassEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

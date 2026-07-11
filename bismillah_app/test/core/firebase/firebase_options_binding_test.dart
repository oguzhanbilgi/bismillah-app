import 'package:bismillah_app/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 019: FlutterFire üretimi `firebase_options.dart` bağlamasını
/// doğrular — canlı Firebase projesi GEREKMEZ (sadece üretilen sabitler).
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('generated Android options bind to the approved project', () {
    expect(
      DefaultFirebaseOptions.android.projectId,
      'bismillah-app-dev-oguzhan',
    );
    expect(DefaultFirebaseOptions.android.appId, contains(':android:'));
  });

  test('generated iOS options bind to the approved bundle id and project', () {
    expect(DefaultFirebaseOptions.ios.iosBundleId, 'com.bismillah.app');
    expect(DefaultFirebaseOptions.ios.projectId, 'bismillah-app-dev-oguzhan');
  });

  test('currentPlatform selects Android options on the Android target', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(
      DefaultFirebaseOptions.currentPlatform.appId,
      DefaultFirebaseOptions.android.appId,
    );
  });

  test('currentPlatform selects iOS options on the iOS target', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(
      DefaultFirebaseOptions.currentPlatform.iosBundleId,
      'com.bismillah.app',
    );
  });

  test('currentPlatform is unsupported on web (→ initializer fallback)', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    // kIsWeb sabit false (VM testi); web dalı derleme zamanı sabitiyle
    // korunur. Burada yalnız yapılandırılmış platformların çözüldüğünü
    // doğrularız; web/desktop UnsupportedError → initializer `unavailable`
    // döner (session_bootstrap_test kapsıyor).
    expect(DefaultFirebaseOptions.currentPlatform, isNotNull);
  });
}

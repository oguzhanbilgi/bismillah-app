import 'package:bismillah_app/core/firebase/firebase_initializer.dart';
import 'package:bismillah_app/core/session/anonymous_auth_service.dart';
import 'package:bismillah_app/core/session/device_identity_service.dart';
import 'package:bismillah_app/core/session/session_bootstrap.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 018: kimlik çözümleme akışı — Firebase initializer fake'lenebilir,
/// gerçek proje/config GEREKMEZ.
void main() {
  test('resolves identity through injected fakes (Firebase available)',
      () async {
    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(const FirebaseInitStatus.available()),
      authService: _FixedAuthService(UserId('fake-uid')),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
    );

    expect(identity.userId.value, 'fake-uid');
    expect(identity.deviceId.value, 'fake-device');
    expect(identity.firebaseStatus.isAvailable, isTrue);
  });

  test(
      'Firebase unavailable → local fallback identity, clearly reported, '
      'app does not crash', () async {
    SharedPreferences.setMockInitialValues({});
    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(
        const FirebaseInitStatus.unavailable('config-missing'),
      ),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
    );

    expect(identity.userId.value, startsWith('local-'));
    expect(identity.firebaseStatus.isAvailable, isFalse);
    expect(identity.firebaseStatus.reason, 'config-missing');
  });

  test('auth failure falls back to persistent local identity', () async {
    SharedPreferences.setMockInitialValues({
      LocalFallbackAuthService.storageKey: 'local-previous',
    });
    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(const FirebaseInitStatus.available()),
      authService: _ThrowingAuthService(),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
    );

    expect(identity.userId.value, 'local-previous');
    expect(identity.identitySource, IdentitySource.local);
    expect(identity.authFailureReason, isNotNull); // redakte sebep taşınır
  });

  test(
      'FirebaseAuthException is classified by code (redacted) — mirrors the '
      'on-device CONFIGURATION_NOT_FOUND finding', () async {
    SharedPreferences.setMockInitialValues({});
    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(const FirebaseInitStatus.available()),
      authService: _AuthExceptionService(
        FirebaseAuthException(code: 'operation-not-allowed'),
      ),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
    );

    expect(identity.userId.value, startsWith('local-'));
    expect(identity.authFailureReason, 'firebase-auth:operation-not-allowed');
  });

  test(
      'anonymous sign-in TIMEOUT → persistent local fallback (cold start does '
      'not wait indefinitely)', () async {
    SharedPreferences.setMockInitialValues({});
    final stopwatch = Stopwatch()..start();

    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(const FirebaseInitStatus.available()),
      // Auth ağın asıldığını simüle eder (timeout'tan çok daha uzun).
      authService: _SlowAuthService(const Duration(seconds: 30)),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
      authTimeout: const Duration(milliseconds: 40),
    );
    stopwatch.stop();

    expect(identity.userId.value, startsWith('local-'));
    expect(identity.identitySource, IdentitySource.local);
    expect(identity.authFailureReason, 'timeout');
    // 30 sn'lik askıyı beklemeden, timeout bütçesi civarında döndü.
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('successful anonymous sign-in classifies identity as firebase',
      () async {
    SharedPreferences.setMockInitialValues({});
    final identity = await resolveSessionIdentity(
      initializer: _FakeInitializer(const FirebaseInitStatus.available()),
      authService: _FixedAuthService(UserId('firebase-uid-123')),
      deviceIdentityService: _FixedDeviceService(DeviceId('fake-device')),
      authTimeout: const Duration(seconds: 3),
    );

    expect(identity.userId.value, 'firebase-uid-123');
    expect(identity.identitySource, IdentitySource.firebase);
    expect(identity.authFailureReason, isNull); // başarıda sebep yok
  });

  test(
      'DefaultFirebaseInitializer (with generated options) reports '
      'unavailable in test env — no native channel — instead of crashing',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Config artık MEVCUT (firebase_options.dart bağlı), ama test ortamında
    // native Firebase kanalı yok → initializeApp fırlatır → yakalanır →
    // unavailable → lokal fallback. Uygulama çökmez.
    final status = await const DefaultFirebaseInitializer().initialize();
    expect(status.isAvailable, isFalse);
    expect(status.reason, isNotNull);
  });
}

final class _FakeInitializer implements FirebaseInitializer {
  _FakeInitializer(this._status);

  final FirebaseInitStatus _status;

  @override
  Future<FirebaseInitStatus> initialize() async => _status;
}

final class _FixedAuthService implements AnonymousAuthService {
  _FixedAuthService(this._userId);

  final UserId _userId;

  @override
  Future<UserId> ensureAnonymousUserId() async => _userId;
}

final class _ThrowingAuthService implements AnonymousAuthService {
  @override
  Future<UserId> ensureAnonymousUserId() async =>
      throw Exception('network unavailable');
}

/// Belirli bir hatayı fırlatır (FirebaseAuthException sınıflandırma testi).
final class _AuthExceptionService implements AnonymousAuthService {
  _AuthExceptionService(this._error);

  final Object _error;

  @override
  Future<UserId> ensureAnonymousUserId() async => throw _error;
}

/// Ağın asıldığını simüle eder: verilen süre boyunca döner (timeout testi).
final class _SlowAuthService implements AnonymousAuthService {
  _SlowAuthService(this._delay);

  final Duration _delay;

  @override
  Future<UserId> ensureAnonymousUserId() async {
    await Future<void>.delayed(_delay);
    return UserId('should-not-be-used');
  }
}

final class _FixedDeviceService implements DeviceIdentityService {
  _FixedDeviceService(this._deviceId);

  final DeviceId _deviceId;

  @override
  Future<DeviceId> ensureDeviceId() async => _deviceId;
}

import 'package:bismillah_app/core/session/anonymous_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 018: anonim auth servisi — gerçek Firebase projesi GEREKMEZ;
/// FirebaseAuth `Fake` ile taklit edilir.
void main() {
  group('FirebaseAnonymousAuthService', () {
    test('returns the existing user uid when a session is present', () async {
      final service = FirebaseAnonymousAuthService(
        _FakeFirebaseAuth(currentUser: _FakeUser('existing-uid')),
      );
      final userId = await service.ensureAnonymousUserId();
      expect(userId.value, 'existing-uid');
    });

    test('signs in anonymously when no user exists', () async {
      final auth = _FakeFirebaseAuth(
        currentUser: null,
        anonymousUid: 'fresh-anon-uid',
      );
      final service = FirebaseAnonymousAuthService(auth);

      final userId = await service.ensureAnonymousUserId();

      expect(userId.value, 'fresh-anon-uid');
      expect(auth.signInCallCount, 1);
    });
  });

  group('LocalFallbackAuthService', () {
    test('generates a local- prefixed uid once and reuses it', () async {
      SharedPreferences.setMockInitialValues({});
      const service = LocalFallbackAuthService();

      final first = await service.ensureAnonymousUserId();
      final second = await service.ensureAnonymousUserId();

      expect(first.value, startsWith('local-'));
      expect(second, first); // kalıcı — her açılışta aynı kimlik

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalFallbackAuthService.storageKey), first.value);
    });

    test('returns previously persisted fallback uid', () async {
      SharedPreferences.setMockInitialValues({
        LocalFallbackAuthService.storageKey: 'local-persisted',
      });
      final userId =
          await const LocalFallbackAuthService().ensureAnonymousUserId();
      expect(userId.value, 'local-persisted');
    });
  });
}

final class _FakeUser extends Fake implements User {
  _FakeUser(this._uid);

  final String _uid;

  @override
  String get uid => _uid;
}

final class _FakeUserCredential extends Fake implements UserCredential {
  _FakeUserCredential(this._user);

  final User _user;

  @override
  User get user => _user;
}

final class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeFirebaseAuth({required this._currentUser, this._anonymousUid});

  final User? _currentUser;
  final String? _anonymousUid;
  int signInCallCount = 0;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<UserCredential> signInAnonymously() async {
    signInCallCount++;
    return _FakeUserCredential(_FakeUser(_anonymousUid!));
  }
}

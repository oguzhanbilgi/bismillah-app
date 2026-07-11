import 'package:bismillah_app/core/firebase/firebase_initializer.dart';
import 'package:bismillah_app/core/session/anonymous_auth_service.dart';
import 'package:bismillah_app/core/session/device_identity_service.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Açılışta çözülen oturum kimliği — bootstrap bunu provider override'ı
/// olarak container'a sabitler; repository'ler senkron okur.
final class SessionIdentity {
  const SessionIdentity({
    required this.userId,
    required this.deviceId,
    required this.firebaseStatus,
  });

  final UserId userId;
  final DeviceId deviceId;
  final FirebaseInitStatus firebaseStatus;
}

/// Kimlik çözümleme sırası (06 §8, 07 §127):
///
/// 1. Firebase Core başlat — başarısızlık uygulamayı DURDURMAZ.
/// 2. Kullanıcı kimliği: Firebase varsa mevcut/yeni anonim UID; yoksa
///    kalıcı lokal fallback kimlik (07 §146).
/// 3. Cihaz kimliği: uygulama-lokal kalıcı UUID v4.
///
/// AĞ BEKLENMEZ: signInAnonymously ağ ister ama başarısızlığı fallback'e
/// düşer; soğuk açılış bütçesi lokal yoldan korunur. Firestore/sync
/// engine BAŞLATILMAZ.
Future<SessionIdentity> resolveSessionIdentity({
  FirebaseInitializer initializer = const DefaultFirebaseInitializer(),
  AnonymousAuthService? authService,
  DeviceIdentityService deviceIdentityService =
      const SharedPrefsDeviceIdentityService(),
}) async {
  final firebaseStatus = await initializer.initialize();

  final effectiveAuthService =
      authService ??
      (firebaseStatus.isAvailable
          ? FirebaseAnonymousAuthService(FirebaseAuth.instance)
          : const LocalFallbackAuthService());

  UserId userId;
  try {
    userId = await effectiveAuthService.ensureAnonymousUserId();
  } on Exception {
    // Firebase mevcut ama anonim oturum kurulamadı (ör. ağ yok): lokal
    // kimlikle devam; ilk başarılı auth'ta remap veriyi taşır (07 §127).
    userId = await const LocalFallbackAuthService().ensureAnonymousUserId();
  }

  final deviceId = await deviceIdentityService.ensureDeviceId();

  return SessionIdentity(
    userId: userId,
    deviceId: deviceId,
    firebaseStatus: firebaseStatus,
  );
}

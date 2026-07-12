import 'dart:async';

import 'package:bismillah_app/core/firebase/firebase_initializer.dart';
import 'package:bismillah_app/core/session/anonymous_auth_service.dart';
import 'package:bismillah_app/core/session/device_identity_service.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Çözülen kimliğin kaynağı — teşhis/redakte log için (07 §146).
/// Ham UID ASLA loglanmaz; yalnız bu sınıflandırma yazılır.
enum IdentitySource { firebase, local }

/// Açılışta çözülen oturum kimliği — bootstrap bunu provider override'ı
/// olarak container'a sabitler; repository'ler senkron okur.
final class SessionIdentity {
  const SessionIdentity({
    required this.userId,
    required this.deviceId,
    required this.firebaseStatus,
    required this.identitySource,
    this.authFailureReason,
  });

  final UserId userId;
  final DeviceId deviceId;
  final FirebaseInitStatus firebaseStatus;
  final IdentitySource identitySource;

  /// Firebase mevcutken anonim oturum kurulamadıysa REDAKTE sebep sınıfı
  /// (ör. `timeout`, `firebase-auth:network-request-failed`). Ham UID/PII
  /// ASLA taşımaz; yalnız teşhis içindir. Başarıda `null`.
  final String? authFailureReason;
}

/// Anonim auth başlangıç bütçesi (TASK 019 sertleştirmesi). TASK 018,
/// `signInAnonymously`'nin timeout'suz olduğunu tespit etmişti — ağ yavaş
/// ya da erişilemezse soğuk açılış sonsuz beklerdi. Bu süre aşılırsa
/// kalıcı lokal kimliğe düşülür (06 §8 "bootstrap ağ beklemez").
const Duration kDefaultAuthTimeout = Duration(seconds: 3);

/// Kimlik çözümleme sırası (06 §8, 07 §127):
///
/// 1. Firebase Core başlat — başarısızlık uygulamayı DURDURMAZ.
/// 2. Kullanıcı kimliği: Firebase varsa mevcut/yeni anonim UID; yoksa
///    kalıcı lokal fallback kimlik (07 §146). Anonim oturum kurulumu
///    [authTimeout] ile SINIRLIDIR — süre aşımı/ağ/auth hatası kalıcı
///    lokal kimliğe düşer (tek deneme, döngüsel retry YOK).
/// 3. Cihaz kimliği: uygulama-lokal kalıcı UUID v4.
///
/// AĞ BEKLENMEZ (mevcut kullanıcı anında döner; yeni anonim oturum
/// [authTimeout] ile sınırlı). Firestore/sync engine BAŞLATILMAZ.
Future<SessionIdentity> resolveSessionIdentity({
  FirebaseInitializer initializer = const DefaultFirebaseInitializer(),
  AnonymousAuthService? authService,
  DeviceIdentityService deviceIdentityService =
      const SharedPrefsDeviceIdentityService(),
  Duration authTimeout = kDefaultAuthTimeout,
}) async {
  final firebaseStatus = await initializer.initialize();

  final effectiveAuthService =
      authService ??
      (firebaseStatus.isAvailable
          ? FirebaseAnonymousAuthService(FirebaseAuth.instance)
          : const LocalFallbackAuthService());

  UserId userId;
  String? authFailureReason;
  try {
    // `.timeout` süre aşımında TimeoutException (implements Exception)
    // fırlatır; alttaki signInAnonymously arka planda sürse de beklenmez.
    userId = await effectiveAuthService.ensureAnonymousUserId().timeout(
      authTimeout,
    );
  } on Object catch (e) {
    // Süre aşımı / ağ yok / auth hatası: kalıcı lokal kimlikle devam;
    // ilk başarılı auth'ta remap veriyi taşır (07 §127). Retry YOK.
    // Sebep REDAKTE olarak taşınır (UID/PII yok) — sessiz başarısızlık
    // gözlemlenebilir olmalı (TASK 020 teşhisi).
    authFailureReason = _classifyAuthFailure(e);
    userId = await const LocalFallbackAuthService().ensureAnonymousUserId();
  }

  final deviceId = await deviceIdentityService.ensureDeviceId();

  // Sınıflandırma UID biçiminden türetilir: `local-` öneki daima lokal
  // fallback'tir, geri kalan her şey gerçek Firebase UID'sidir.
  final identitySource = userId.value.startsWith('local-')
      ? IdentitySource.local
      : IdentitySource.firebase;

  return SessionIdentity(
    userId: userId,
    deviceId: deviceId,
    firebaseStatus: firebaseStatus,
    identitySource: identitySource,
    authFailureReason: authFailureReason,
  );
}

/// Anonim auth başarısızlığını REDAKTE sebep sınıfına indirger — ham hata
/// mesajı/PII loglanmaz (06 §31, 10 §11 hata-kova ilkesi).
String _classifyAuthFailure(Object error) {
  if (error is TimeoutException) {
    return 'timeout';
  }
  if (error is FirebaseAuthException) {
    // Yalnız hata KODU loglanır (redakte kova); ham mesaj/PII taşınmaz.
    // Not: proje anonim sağlayıcısı kapalıysa kod `unknown`, alttaki
    // Identity Toolkit sebebi `CONFIGURATION_NOT_FOUND` olur (TASK 020'de
    // gözlemlendi) — çözüm Firebase Console'da anonim auth'u etkinleştirmek.
    return 'firebase-auth:${error.code}';
  }
  if (error is FirebaseException) {
    return 'firebase:${error.code}';
  }
  return error.runtimeType.toString();
}

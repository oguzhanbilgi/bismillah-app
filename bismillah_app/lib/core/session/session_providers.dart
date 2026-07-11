import 'package:bismillah_app/core/firebase/firebase_initializer.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Oturum kimliği provider'ları (TASK 018).
///
/// Değerler bootstrap'ta ÇÖZÜLÜR ve container'a override olarak sabitlenir
/// (`bootstrap()` → [resolveSessionIdentity]); hardcoded placeholder
/// YOKTUR. Varsayılan gövdenin fırlatması bilinçlidir: kimliği çözülmemiş
/// bir container'dan kimlik okumak programlama hatasıdır — testler
/// `ProviderScope(overrides: ...)` ile sabit kimlik verir
/// (`test/helpers/test_session.dart`).

/// Oturum sahibi kullanıcı. Kaynak: Firebase anonim UID; Firebase yoksa
/// kalıcı lokal fallback kimlik (`local-` önekli, 07 §146). Gerçek hesap
/// bağlama (Apple/Google/e-posta) ilerideki görevdedir.
final currentUserIdProvider = Provider<UserId>(
  (ref) => throw StateError(
    'currentUserIdProvider bootstrap/test override olmadan okunamaz '
    '(bootstrap resolveSessionIdentity sonucunu override eder)',
  ),
);

/// Uygulama-lokal cihaz kimliği (UUID v4, shared_preferences'ta kalıcı).
/// Reklam/donanım kimliği DEĞİLDİR.
final currentDeviceIdProvider = Provider<DeviceId>(
  (ref) => throw StateError(
    'currentDeviceIdProvider bootstrap/test override olmadan okunamaz '
    '(bootstrap resolveSessionIdentity sonucunu override eder)',
  ),
);

/// Firebase Core durumu — teşhis/koşullu davranış için (ör. sync engine
/// görevi yalnız available iken push dener). Varsayılan güvenli taraftır.
final firebaseInitStatusProvider = Provider<FirebaseInitStatus>(
  (ref) => const FirebaseInitStatus.unavailable('bootstrap override yok'),
);

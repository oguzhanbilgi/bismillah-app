import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Oturum kimliği placeholder provider'ları — **GEÇİCİ**.
///
/// Anonim-first mimaride (06_FLUTTER_ARCHITECTURE §17) gerçek kimlik
/// Firebase anonim auth'tan gelir ve ilk andan stabildir; o entegrasyon
/// ayrı görevdedir. Buradaki sabitler YALNIZ lokal geliştirme/test
/// içindir ve üretim auth'u gibi DAVRANMAZ — Firebase Auth görevi bu
/// provider'ların gövdesini gerçek kaynağa bağlayacak, imzalar sabit
/// kalacaktır. Testler `ProviderScope(overrides: ...)` ile değiştirir.

/// GEÇİCİ kullanıcı kimliği (gerçek kaynak: Firebase anonim UID — sonraki
/// görev). Değer bilinçli olarak "placeholder" damgalıdır.
final currentUserIdProvider = Provider<UserId>(
  (ref) => UserId('placeholder-local-user'),
);

/// GEÇİCİ cihaz kimliği (gerçek kaynak: ilk açılışta üretilip saklanan
/// UUID v4, 10_DATA_MODEL §6 — sonraki görev). Reklam/donanım kimliği
/// DEĞİLDİR ve olmayacaktır.
final currentDeviceIdProvider = Provider<DeviceId>(
  (ref) => DeviceId('placeholder-local-device'),
);

import 'package:bismillah_app/core/session/device_identity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 018: uygulama-lokal cihaz kimliği (UUID v4; reklam kimliği DEĞİL).
void main() {
  const service = SharedPrefsDeviceIdentityService();

  test('returns the persisted device id when present', () async {
    SharedPreferences.setMockInitialValues({
      SharedPrefsDeviceIdentityService.storageKey: 'persisted-device',
    });
    final deviceId = await service.ensureDeviceId();
    expect(deviceId.value, 'persisted-device');
  });

  test('generates, persists and reuses a UUID v4 when missing', () async {
    SharedPreferences.setMockInitialValues({});

    final first = await service.ensureDeviceId();
    final second = await service.ensureDeviceId();

    // UUID v4 biçimi (8-4-4-4-12, versiyon 4, varyant 10xx).
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(first.value),
      isTrue,
      reason: 'geçerli UUID v4 bekleniyordu: ${first.value}',
    );
    expect(second, first); // kalıcı ve stabil

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(SharedPrefsDeviceIdentityService.storageKey),
      first.value,
    );
  });
}

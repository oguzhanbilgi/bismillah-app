import 'package:bismillah_app/core/utils/uuid_v4.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cihaz kimliği sözleşmesi (10_DATA_MODEL §6).
///
/// Kimlik UYGULAMA-LOKALDİR: ilk açılışta UUID v4 üretilir ve saklanır;
/// uygulama verisi silinirse sıfırlanır. IDFA/GAID/donanım kimliği
/// KULLANILMAZ ve KULLANILAMAZ — bu bir reklam/izleme kimliği değildir.
abstract interface class DeviceIdentityService {
  Future<DeviceId> ensureDeviceId();
}

final class SharedPrefsDeviceIdentityService implements DeviceIdentityService {
  const SharedPrefsDeviceIdentityService();

  static const String storageKey = 'bismillah.device_id';

  @override
  Future<DeviceId> ensureDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(storageKey);
    if (existing != null && existing.isNotEmpty) {
      return DeviceId(existing);
    }
    final generated = UuidV4.generate();
    await prefs.setString(storageKey, generated);
    return DeviceId(generated);
  }
}

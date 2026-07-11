import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Sabit test kimliği (TASK 018 sonrası oturum provider'ları bootstrap
/// override'ı olmadan fırlatır — testler bu yardımcıyla kimlik sabitler).
const String testUserIdValue = 'test-user';
const String testDeviceIdValue = 'test-device';

List<Override> testSessionOverrides({
  String userId = testUserIdValue,
  String deviceId = testDeviceIdValue,
}) {
  return [
    currentUserIdProvider.overrideWithValue(UserId(userId)),
    currentDeviceIdProvider.overrideWithValue(DeviceId(deviceId)),
  ];
}

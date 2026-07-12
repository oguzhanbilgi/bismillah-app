import 'package:bismillah_app/features/prayer_reminders/domain/device_time_zone_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// flutter_timezone tabanlı IANA timezone çözücü. Paket tipi (TimezoneInfo)
/// bu dosyanın dışına sızmaz.
final class FlutterDeviceTimeZoneService implements DeviceTimeZoneService {
  const FlutterDeviceTimeZoneService();

  @override
  Future<String> localTimeZoneId() async {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  }
}

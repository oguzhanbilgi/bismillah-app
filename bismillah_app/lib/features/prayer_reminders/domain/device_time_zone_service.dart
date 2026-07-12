/// Cihaz IANA timezone kimliğini çözer (ör. `Europe/Istanbul`) — paket-
/// bağımsız. Sabit UTC+3 YASAK; zamanlama daima cihazın gerçek timezone'una
/// göre yapılır.
abstract interface class DeviceTimeZoneService {
  Future<String> localTimeZoneId();
}

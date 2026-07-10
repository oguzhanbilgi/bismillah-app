/// Test edilebilir zaman soyutlaması (06_FLUTTER_ARCHITECTURE §7).
///
/// Domain kodu `DateTime.now()` çağırmaz — [AppClock] enjekte edilir;
/// testlerde sabit/ilerletilebilir saat kullanılır.
abstract interface class AppClock {
  DateTime nowLocal();

  DateTime nowUtc();
}

final class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime nowLocal() => DateTime.now();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// Test amaçlı sabit saat.
final class FixedClock implements AppClock {
  const FixedClock(this.fixed);

  final DateTime fixed;

  @override
  DateTime nowLocal() => fixed;

  @override
  DateTime nowUtc() => fixed.toUtc();
}

/// Süreçler arası KARARLI içerik hash'i (FNV-1a, 64 bit).
///
/// `SyncOperation.payloadHash` (10_DATA_MODEL §11) oturumlar arasında
/// karşılaştırılır; Dart'ın `hashCode`/`Object.hash` değerleri süreç
/// başına tohumlandığı için kullanılamaz. Kriptografik amaç YOKTUR —
/// yalnız idempotency ve değişiklik tespiti.
abstract final class StableHash {
  static final BigInt _prime = BigInt.parse('100000001b3', radix: 16);
  static final BigInt _offset = BigInt.parse('cbf29ce484222325', radix: 16);
  static final BigInt _mask = (BigInt.one << 64) - BigInt.one;

  /// Girdinin FNV-1a 64-bit hash'ini 16 haneli hex olarak döner.
  static String fnv1a64(String input) {
    var hash = _offset;
    for (final codeUnit in input.codeUnits) {
      hash = ((hash ^ BigInt.from(codeUnit)) * _prime) & _mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

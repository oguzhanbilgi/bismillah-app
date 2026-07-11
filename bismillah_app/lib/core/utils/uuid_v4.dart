import 'dart:math';

/// Bağımlılıksız UUID v4 üretimi (RFC 4122).
///
/// 10_DATA_MODEL §6: `operationId`, `sessionId`, `messageId` gibi
/// kimlikler cihazda çakışmasız üretilir. Kaynak varsayılan olarak
/// [Random.secure]'dur; testler deterministik [Random] enjekte edebilir.
abstract final class UuidV4 {
  static final Random _secure = Random.secure();

  static String generate({Random? random}) {
    final rng = random ?? _secure;
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

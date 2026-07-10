/// Kimlik değer nesneleri (10_DATA_MODEL §6 ID stratejisi).
///
/// Tüm ID'ler cihazda üretilebilir ve deterministiktir; "sunucudan ID
/// bekleyen" yazma yolu yoktur. Ham `String` ID parametresi domain
/// API'lerinde kullanılmaz — daima bu tipler.
library;

/// Boş olmayan, kırpılmış string kimliklerin ortak tabanı.
abstract class UniqueId {
  UniqueId(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', '$runtimeType boş olamaz');
    }
    if (value != value.trim()) {
      throw ArgumentError.value(
        value,
        'value',
        '$runtimeType baş/son boşluk içeremez',
      );
    }
  }

  final String value;

  @override
  bool operator ==(Object other) =>
      other is UniqueId &&
      other.runtimeType == runtimeType &&
      other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => value;
}

/// Firebase UID (anonim dahil) — tüm kullanıcı verisinin sahiplik anahtarı.
final class UserId extends UniqueId {
  UserId(super.value);
}

/// Cihaz kimliği (ilk açılışta UUID v4). Reklam/donanım kimliği DEĞİLDİR.
final class DeviceId extends UniqueId {
  DeviceId(super.value);
}

/// Hedef belge anahtarı (dayKey / duaId / uuid…) — sync ve repository
/// katmanının entity adresleme birimi.
final class EntityId extends UniqueId {
  EntityId(super.value);
}

/// Sync kuyruğu kaydının birincil anahtarı (UUID v4).
final class OperationId extends UniqueId {
  OperationId(super.value);
}

/// CMS üretimi anlamlı-sabit içerik kimliği (ör. `dua-morning-001`).
/// İçerik sürümü ID'yi DEĞİŞTİRMEZ — `version` alanı artar.
final class ContentId extends UniqueId {
  ContentId(super.value);
}

/// Push sync tekrar-teslim güvenliği anahtarı (10_DATA_MODEL §11):
/// `operationId` + `payloadHash` türevi.
final class IdempotencyKey extends UniqueId {
  IdempotencyKey(super.value);

  factory IdempotencyKey.derive({
    required OperationId operationId,
    required String payloadHash,
  }) {
    return IdempotencyKey('${operationId.value}:$payloadHash');
  }
}

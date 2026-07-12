/// Coğrafi konum — paket-bağımsız değer nesnesi (adhan_dart/geolocator
/// tipleri domain'e sızmaz). Gizlilik: ham koordinat ASLA loglanmaz,
/// analytics'e/sync payload'ına eklenmez (10 §19; TASK 021 gizlilik kuralı).
final class PrayerCoordinates {
  const PrayerCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is PrayerCoordinates &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  /// `toString` KASITLI olarak koordinat sızdırmaz (gizlilik: hata/log
  /// bağlamında ham enlem/boylam yazılamaz).
  @override
  String toString() => 'PrayerCoordinates(<redacted>)';
}

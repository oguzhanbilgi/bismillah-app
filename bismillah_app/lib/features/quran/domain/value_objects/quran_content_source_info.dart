/// Kur'an içerik kaynağı künyesi (TASK 034B) — paket bağımsız.
///
/// İçerik hiçbir zaman kaynaksız taşınmaz; görünür kaynak ekranı ileriki
/// görevde bu modeli kullanır.
final class QuranContentSourceInfo {
  const QuranContentSourceInfo({
    required this.name,
    required this.version,
    required this.attributionLabel,
    required this.attributionUrl,
  });

  final String name;
  final String version;
  final String attributionLabel;
  final String attributionUrl;
}

/// Sure kataloğunun kaynağı (assets/quran/NOTICE.md ile aynı künye).
const QuranContentSourceInfo tanzilQuranMetadataSource =
    QuranContentSourceInfo(
      name: 'Tanzil Project',
      version: 'Quran Metadata 1.0',
      attributionLabel: 'Tanzil Project — Quran Metadata',
      attributionUrl: 'https://tanzil.net/docs/quran_metadata',
    );

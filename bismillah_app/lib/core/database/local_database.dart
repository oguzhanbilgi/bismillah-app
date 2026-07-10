/// Lokal veritabanı soyutlaması.
///
/// 10_DATA_MODEL §7 hardening kuralı: gerçek paket seçimi (Isar / bakımlı
/// fork / alternatif) infrastructure katmanında izole kalır; bu sözleşme
/// paketten bağımsızdır. UI ve feature katmanları bu arayüzü bile doğrudan
/// kullanmaz — yalnız local datasource sınıfları kullanır.
///
/// Gerçek DB implementasyonu TASK 012+ kapsamındadır; bu görevde yalnız
/// sözleşme ve testler için güvenli bir in-memory placeholder vardır.
abstract interface class LocalDatabase {
  bool get isInitialized;

  Future<void> initialize();

  /// Hesap silme akışının lokal ayağı (07_FIREBASE_ARCHITECTURE §25):
  /// tüm kullanıcı verisini atomik temizler.
  Future<void> clearAll();

  Future<void> close();
}

/// Scaffold aşaması placeholder'ı — hiçbir kalıcılık sağlamaz.
final class InMemoryLocalDatabase implements LocalDatabase {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> clearAll() async {
    // In-memory placeholder: temizlenecek kalıcı veri yok.
  }

  @override
  Future<void> close() async {
    _initialized = false;
  }
}

import 'package:bismillah_app/core/contracts/contracts.dart';

/// Kur'an ses tercihi sözleşmesi (TASK 049) — paket bağımsız.
///
/// Tercih YALNIZ cihazda saklanır: Firebase/analytics/sync YOK. Eksik
/// veya bozuk değer her zaman varsayılan read 5'e düşer.
abstract interface class QuranAudioPreferencesRepository {
  /// Varsayılan ve her zaman geçerli fallback read kimliği.
  static const int defaultReadId = 5;

  /// Seçili read kimliği; eksik/bozuk kayıtta [defaultReadId] (fırlatmaz).
  Future<int> loadSelectedReadId();

  /// Seçimi kalıcılaştırır; başarısızlıkta eski seçim korunur ve çağıran
  /// sakin hata gösterebilir.
  ResultFuture<void> saveSelectedReadId(int readId);

  /// Her başarılı kayıttan sonra yeni read kimliğini yayınlar (broadcast).
  Stream<int> watchSelectedReadId();
}

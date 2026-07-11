import 'package:bismillah_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase Core başlatma sonucu — Firebase tipleri bu dosyanın dışına
/// SIZMAZ; katmanlar yalnız bu durum nesnesini görür.
final class FirebaseInitStatus {
  const FirebaseInitStatus.available() : isAvailable = true, reason = null;

  const FirebaseInitStatus.unavailable(String this.reason)
    : isAvailable = false;

  final bool isAvailable;

  /// Kullanılamama nedeni (log/teşhis için; kullanıcı metni DEĞİLDİR).
  final String? reason;
}

/// Firebase Core başlatma soyutlaması (07_FIREBASE_ARCHITECTURE §7).
///
/// Sözleşme: başlatma BAŞARISIZLIĞI uygulamayı durdurmaz — offline-first
/// mimaride uygulama lokal kimlikle çalışmaya devam eder (07 §127).
/// Firestore/sync engine BAŞLATILMAZ; bu yalnız Core + Auth zeminidir.
abstract interface class FirebaseInitializer {
  Future<FirebaseInitStatus> initialize();
}

/// Gerçek Firebase Core başlatıcısı (TASK 019: FlutterFire bağlı).
///
/// Proje `bismillah-app-dev-oguzhan`; [DefaultFirebaseOptions.currentPlatform]
/// FlutterFire CLI tarafından üretildi (Android+iOS). Başlatma yapılandırılmış
/// seçeneklerle yapılır — Android'de `google-services.json` de mevcuttur.
///
/// `currentPlatform` yapılandırılmamış platformlarda (web/windows/macos/linux)
/// `UnsupportedError` fırlatır; test ortamında da native kanal yoktur. Her iki
/// durum da yakalanır ve `unavailable` döner — uygulama kalıcı lokal kimlikle
/// çalışmaya devam eder (07 §146: ilk gerçek anonim auth'ta remap ile UID
/// yükseltilir). Firestore/sync BAŞLATILMAZ; bu yalnız Core zeminidir.
final class DefaultFirebaseInitializer implements FirebaseInitializer {
  const DefaultFirebaseInitializer();

  @override
  Future<FirebaseInitStatus> initialize() async {
    try {
      // Hot restart / tekrar çağrı güvenliği: zaten başlatılmışsa
      // duplicate-app fırlatmasını önle.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return const FirebaseInitStatus.available();
      // Başarısızlık platforma göre Exception YA DA Error olarak yüzer
      // (UnsupportedError, MissingPluginException, FirebaseException...);
      // hepsi aynı karara çıkar: Firebase yok, lokal kimlikle devam.
    } catch (e) {
      return FirebaseInitStatus.unavailable(e.runtimeType.toString());
    }
  }
}

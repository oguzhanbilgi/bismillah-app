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

/// Gerçek Firebase Core başlatıcısı.
///
/// ÖNEMLİ (TASK 018 durumu): repoda `firebase_options.dart` ve platform
/// config dosyaları (google-services.json / GoogleService-Info.plist)
/// YOKTUR ve native platform klasörleri henüz oluşturulmamıştır. Gerçek
/// cihazda Firebase auth için FlutterFire CLI yapılandırması ayrı görevde
/// gelecektir; o zamana dek bu başlatıcı `unavailable` döner ve uygulama
/// kalıcı lokal kimlikle çalışır (07 §146: ilk gerçek anonim auth'ta
/// remap ile UID yükseltilir).
final class DefaultFirebaseInitializer implements FirebaseInitializer {
  const DefaultFirebaseInitializer();

  @override
  Future<FirebaseInitStatus> initialize() async {
    try {
      await Firebase.initializeApp();
      return const FirebaseInitStatus.available();
      // Config yokluğu platforma göre Exception YA DA Error olarak yüzer
      // (MissingPluginException, FirebaseException, UnsupportedError...);
      // hepsi aynı karara çıkar: Firebase yok, lokal kimlikle devam.
    } catch (e) {
      return FirebaseInitStatus.unavailable(e.runtimeType.toString());
    }
  }
}

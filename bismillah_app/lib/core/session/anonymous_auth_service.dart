import 'package:bismillah_app/core/utils/uuid_v4.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anonim-önce kimlik sözleşmesi (06 §17, 07 §127).
///
/// Bu bir login özelliği DEĞİLDİR: hesap ekranı, sosyal giriş, linking ve
/// sign-out yoktur. Tek iş: uygulamanın her açılışta stabil bir [UserId]
/// ile çalışmasını garanti etmek. Firebase `User` tipi bu sözleşmenin
/// dışına sızmaz.
abstract interface class AnonymousAuthService {
  Future<UserId> ensureAnonymousUserId();
}

/// Firebase Auth tabanlı implementasyon: mevcut oturum varsa UID'si
/// döner; yoksa sessizce anonim oturum açılır (07 §127).
final class FirebaseAnonymousAuthService implements AnonymousAuthService {
  FirebaseAnonymousAuthService(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<UserId> ensureAnonymousUserId() async {
    final existing = _auth.currentUser;
    if (existing != null) {
      return UserId(existing.uid);
    }
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('signInAnonymously kullanıcı döndürmedi');
    }
    return UserId(user.uid);
  }
}

/// Firebase kullanılamadığında (config yok / ağ yok) devreye giren KALICI
/// lokal kimlik (07 §146 "Device-local identity").
///
/// `local-` öneki bu kimliğin hiçbir zaman Firestore'a yazılmadığını
/// görünür kılar; ilk gerçek anonim auth kurulduğunda bootstrap'taki uid
/// remap'i veriyi gerçek UID'ye taşır — kullanıcı hiçbir şey fark etmez.
final class LocalFallbackAuthService implements AnonymousAuthService {
  const LocalFallbackAuthService();

  static const String storageKey = 'bismillah.local_fallback_uid';

  @override
  Future<UserId> ensureAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(storageKey);
    if (existing != null && existing.isNotEmpty) {
      return UserId(existing);
    }
    final generated = 'local-${UuidV4.generate()}';
    await prefs.setString(storageKey, generated);
    return UserId(generated);
  }
}

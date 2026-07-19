import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';

/// Resmî kaynak bağlantısı açma sözleşmesi (TASK 056 §10).
///
/// Bağlayıcı kurallar:
/// - Uygulama içinde WebView AÇILMAZ; hedef sistem tarayıcısıdır.
/// - Bağlantı açılmadan ÖNCE alan adı [OfficialSourceDomains] ile
///   doğrulanır — resmî olmayan adres hiçbir koşulda açılmaz.
/// - Açma başarısız olursa exception FIRLATILMAZ: `false` döner ve ekran
///   sakin bir mesaj gösterir (crash yok).
abstract interface class ExternalLinkService {
  /// Başarılıysa `true`. Adres resmî değilse veya açılamıyorsa `false`.
  Future<bool> openOfficialSource(String url);
}

/// Varsayılan implementasyon.
///
/// Bu sürümde uygulamaya tarayıcı açan bir platform paketi (url_launcher)
/// BAĞLANMAMIŞTIR — bu yüzden açma isteği güvenli biçimde `false` döner ve
/// arayüz kullanıcıya adresi görünür/kopyalanabilir şekilde sunar.
/// Alan adı doğrulaması BURADA da uygulanır: launcher ileride
/// bağlandığında güvenlik kuralı tek yerde kalır.
final class DomainValidatedExternalLinkService implements ExternalLinkService {
  const DomainValidatedExternalLinkService();

  @override
  Future<bool> openOfficialSource(String url) async {
    if (!OfficialSourceDomains.isAllowed(url)) {
      return false;
    }
    // Launcher bağlanana kadar açma DESTEKLENMEZ; sessizce başarısız olur.
    return false;
  }
}

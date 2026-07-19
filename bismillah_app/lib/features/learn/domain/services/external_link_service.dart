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

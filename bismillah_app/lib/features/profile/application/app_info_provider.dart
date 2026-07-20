import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Uygulama sürüm/build bilgisi (TASK 058 §8).
///
/// `package_info_plus` platform kanalından okur. Testler bu provider'ı
/// override ederek gerçek platform çağrısı olmadan Hakkında ekranını
/// doğrular. Okuma başarısız olursa ekran sakin bir "sürüm alınamadı"
/// durumu gösterir (crash yok).
final appInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

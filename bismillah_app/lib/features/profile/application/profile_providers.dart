import 'package:bismillah_app/features/profile/data/url_launcher_app_source_link_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İçerik kaynağı bağlantı servisi — alan adı allowlist doğrulaması
/// içeride (TASK 058 §5). Testler bunu override ederek GERÇEK tarayıcı
/// açmadan davranışı (success/failure + copy fallback) doğrular.
final appSourceLinkServiceProvider = Provider<AppSourceLinkService>(
  (ref) => const UrlLauncherAppSourceLinkService(),
);

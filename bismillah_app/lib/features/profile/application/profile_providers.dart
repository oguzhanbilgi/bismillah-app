import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/profile/data/url_launcher_app_source_link_service.dart';
import 'package:bismillah_app/features/profile/data/url_launcher_privacy_policy_link_service.dart';
import 'package:bismillah_app/features/profile/data/url_launcher_support_contact_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_reference.dart';
import 'package:bismillah_app/features/profile/domain/privacy_policy_link.dart';
import 'package:bismillah_app/features/profile/domain/support_contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İçerik kaynağı bağlantı servisi — alan adı allowlist doğrulaması
/// içeride (TASK 058 §5). Testler bunu override ederek GERÇEK tarayıcı
/// açmadan davranışı (success/failure + copy fallback) doğrular.
final appSourceLinkServiceProvider = Provider<AppSourceLinkService>(
  (ref) => const UrlLauncherAppSourceLinkService(),
);

/// Destek e-postası servisi (ALPHA-R3A). Testler bunu override ederek
/// GERÇEK e-posta istemcisi açmadan başarı ve fallback yollarını doğrular.
final supportContactServiceProvider = Provider<SupportContactService>(
  (ref) => const UrlLauncherSupportContactService(),
);

/// Yayımlanmış gizlilik politikası bağlantı servisi (ALPHA-R3C). Testler
/// bunu override ederek GERÇEK tarayıcı açmadan başarı ve fallback
/// yollarını doğrular.
final privacyPolicyLinkServiceProvider = Provider<PrivacyPolicyLinkService>(
  (ref) => const UrlLauncherPrivacyPolicyLinkService(),
);

/// İçerik kaynakları ekranının çözülmüş künye listesi (TASK 094 §B).
///
/// Resmî kaynakların adı/dili/adresi `sources.json`'dan OKUNUR — ekranda
/// veya [kAppSourceReferences] içinde ikinci bir elle tutulan kopya YOKTUR.
///
/// EKSİK KİMLİK GÜVENLİ ve GÖRÜNÜR şekilde başarısız olur: kayıt defterinde
/// bulunmayan bir kimlik SESSİZCE ATLANMAZ, uydurma künye ÜRETİLMEZ —
/// provider hata durumuna geçer ve ekran dürüst bir hata metni gösterir.
final resolvedAppSourcesProvider = FutureProvider<List<ResolvedAppSource>>((
  ref,
) async {
  final repository = ref.watch(learningKnowledgeRepositoryProvider);
  final resolved = <ResolvedAppSource>[];

  for (final reference in kAppSourceReferences) {
    switch (reference.origin) {
      case AppSourceOrigin.infrastructure:
        resolved.add(
          ResolvedAppSource(
            purpose: reference.purpose,
            name: reference.infrastructureName!,
            originalLanguage: reference.infrastructureLanguage!,
            canonicalUrl: reference.infrastructureUrl!,
          ),
        );
      case AppSourceOrigin.registry:
        final id = reference.registrySourceId!;
        final result = await repository.getSourceById(id);
        final source = result.valueOrNull;
        if (source == null) {
          // Kayıt defterinde yok: künye UYDURULMAZ, sessizce de atlanmaz.
          throw StateError('Kayıtlı kaynak çözülemedi: $id');
        }
        resolved.add(
          ResolvedAppSource(
            purpose: reference.purpose,
            name: source.title,
            originalLanguage: source.originalLanguage,
            canonicalUrl: source.canonicalUrl,
          ),
        );
    }
  }

  return resolved;
});

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:bismillah_app/shared/widgets/app_empty_state.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Learn sekmesi — dersler/günlük hadis sonraki görevlerde.
///
/// TASK 055: jenerik boş kart yerine sıcak, davetkâr giriş. Küçük bir
/// hero (cami ufku + sıcak tonal gradient) ve sakin bir davet metni;
/// mevcut "hazırlanıyor" durumu aşağıda erişilebilir kalır. Metinler
/// AYET/HADİS DEĞİLDİR; suçluluk/eksiklik dili YOKTUR.
class LearnPlaceholderScreen extends StatelessWidget {
  const LearnPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.tabLearn,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          const _LearnHero(),
          const SizedBox(height: AppSpacing.s6),
          AppText(l10n.learnExploreSection, token: AppTextStyleToken.h3),
          const SizedBox(height: AppSpacing.s3),
          // Mevcut içerik durumu korunur: sahte ders/dini içerik ÜRETİLMEZ.
          AppEmptyState(
            message: l10n.placeholderComingSoon,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}

/// Kompakt Learn hero'su — fazla yüksek değildir, içerikleri aşağıda
/// erişilebilir bırakır. İllüstrasyon dekoratiftir (semantics dışı).
class _LearnHero extends StatelessWidget {
  const _LearnHero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return Semantics(
      container: true,
      label: l10n.learnHeroTitle,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: tokens.warmSectionGradient),
          child: Stack(
            children: [
              // Cami ufku alt banda oturur (Today hero deseni) — metinle
              // yarışmaz, bölüme mekân duygusu verir.
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48,
                child: MosqueHorizonIllustration(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s5,
                  AppSpacing.s5,
                  AppSpacing.s5,
                  AppSpacing.s7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(l10n.learnHeroTitle, token: AppTextStyleToken.h2),
                    const SizedBox(height: AppSpacing.s2),
                    AppText(
                      l10n.learnHeroBody,
                      token: AppTextStyleToken.bodySmall,
                      secondary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

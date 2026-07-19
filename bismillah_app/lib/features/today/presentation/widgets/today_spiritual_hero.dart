import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:bismillah_app/shared/islamic/spiritual_hero_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Today manevi hero alanı (TASK 052; görsel dil TASK 054).
///
/// Ton: umut verici, kapsayıcı, yargılamayan. Metinler ayet/hadis DEĞİLDİR;
/// tırnak içine alınmaz, kaynak etiketi verilmez, dinî hüküm veya vaat
/// içermez (bkz. `docs/12_ISLAMIC_VISUAL_IDENTITY.md`).
///
/// TASK 054: tek nokta silueti yerine ALT banda oturan cami ufku kullanılır
/// — siluet metnin arkasında yüzen bir leke değil, kompozisyonun zeminidir.
/// Başlık h1'e yükseltilir (hero ekranın en karakterli metnidir).
///
/// Kompakt tutulur: namaz kartlarını ekranın çok aşağısına itmez — sıradaki
/// namaz ilk viewport'ta görünür kalmalıdır.
class TodaySpiritualHero extends StatelessWidget {
  const TodaySpiritualHero({super.key, this.onSeeTodaysPlan});

  /// Tek aksiyon — yeni route AÇMAZ; Today içeriğine odaklanır.
  final VoidCallback? onSeeTodaysPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: SpiritualHeroCard(
        title: l10n.todayHeroTitle,
        description: l10n.todayHeroBody,
        semanticLabel: l10n.todayHeroTitle,
        titleStyle: AppTypography.h1,
        // Dekoratif ufuk — semantics ve dokunma dışıdır. Alt banda hizalanır
        // ve yüksekliği sınırlıdır: büyük metin ölçeğinde metnin üstüne
        // binmez, kompozisyonun zemininde kalır.
        decorativeLayer: const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(height: 64, child: MosqueHorizonIllustration()),
        ),
        action: onSeeTodaysPlan == null
            ? null
            : AppButton(
                label: l10n.todayHeroCta,
                variant: AppButtonVariant.ghost,
                onPressed: onSeeTodaysPlan,
              ),
      ),
    );
  }
}

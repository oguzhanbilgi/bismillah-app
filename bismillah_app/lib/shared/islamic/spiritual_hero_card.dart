import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/islamic/islamic_pattern_background.dart';
import 'package:flutter/material.dart';

/// Manevi atmosfer hero kartı (TASK 051) — Today hero, onboarding, Learn ve
/// boş durumlar için ORTAK temel.
///
/// Kurallar:
/// - Görsel OPSİYONELDİR ve yalnız YEREL asset'tir (network görsel YOK).
/// - Görsel yoksa veya yüklenemezse token gradient'ine düşer — crash YOK,
///   kırık görsel ikonu YOK.
/// - Metin okunabilirliği scrim ile garanti edilir (`imageOverlayDark`).
/// - Dekoratif katmanlar semantics'ten hariçtir; kartın TEK anlamlı
///   etiketi [semanticLabel]'dır.
/// - Sabit yükseklik yoktur: içerik ve metin ölçeğiyle büyür (text scaling
///   1.0–1.5 aralığında taşma yapmaz).
class SpiritualHeroCard extends StatelessWidget {
  const SpiritualHeroCard({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.imageAssetPath,
    this.semanticLabel,
    this.showPattern = true,
    this.onTap,
  });

  /// Kartın başlığı — daima localization'dan gelir.
  final String title;

  final String? description;

  /// Alt aksiyon (ör. `AppButton`). Kart aksiyonsuz da kullanılabilir.
  final Widget? action;

  /// YEREL asset yolu (ör. `assets/images/islamic/today_hero.webp`).
  /// `null` ise doğrudan gradient kullanılır.
  final String? imageAssetPath;

  /// Ekran okuyucu etiketi; verilmezse başlık okunur.
  final String? semanticLabel;

  /// Arka planda sakin geometrik desen gösterilsin mi.
  final bool showPattern;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    final card = ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // 1) Taban: her koşulda var olan güvenli gradient (fallback).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.heroGradient),
            ),
          ),
          // 2) Opsiyonel yerel görsel — yüklenemezse sessizce gradient kalır.
          if (imageAssetPath != null)
            Positioned.fill(
              child: ExcludeSemantics(
                child: Image.asset(
                  imageAssetPath!,
                  fit: BoxFit.cover,
                  // Asset eksik/bozuksa kırık ikon değil, şeffaf geç:
                  // altındaki gradient görünür kalır.
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          // 3) Okunabilirlik scrim'i (yalnız görsel varken gerekir).
          if (imageAssetPath != null)
            Positioned.fill(
              child: ExcludeSemantics(
                child: ColoredBox(color: tokens.imageOverlayDark),
              ),
            ),
          // 4) Sakin desen — dekoratif, dokunmayı engellemez.
          if (showPattern)
            const Positioned.fill(child: IslamicPatternBackground()),
          // 5) İçerik
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.s5),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      button: onTap != null,
      child: onTap == null
          ? card
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: AppRadius.lgAll,
                child: card,
              ),
            ),
    );
  }
}

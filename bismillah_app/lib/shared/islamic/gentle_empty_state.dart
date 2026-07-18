import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Nazik boş durum (TASK 051) — mevcut `AppEmptyState`'in İslami motif
/// destekli varyantı; boş durum bir DAVETTİR, eksiklik raporu değildir.
///
/// Kurallar:
/// - Metinler dışarıdan (localization) gelir; suçlayıcı/korku/utandırma
///   dili KULLANILMAZ (bkz. `docs/12_ISLAMIC_VISUAL_IDENTITY.md`).
/// - Tek net aksiyon; kullanıcıya "geride kaldın" hissi verilmez.
/// - Motif alanı opsiyoneldir: yerel görsel yoksa/yüklenemezse token
///   zeminli ikon fallback'ine düşer — crash veya kırık görsel YOK.
class GentleEmptyState extends StatelessWidget {
  const GentleEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.spa_outlined,
    this.illustrationAssetPath,
    this.actionLabel,
    this.onAction,
  });

  /// Umut veren tek cümle.
  final String message;

  final String? title;

  /// Görsel yokken kullanılan sakin motif ikonu.
  final IconData icon;

  /// Opsiyonel YEREL illüstrasyon (network görsel YOK).
  final String? illustrationAssetPath;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Motif(
              icon: icon,
              assetPath: illustrationAssetPath,
              background: tokens.sacredSurfaceMuted,
              foreground: tokens.spiritualGreen,
            ),
            const SizedBox(height: AppSpacing.s5),
            if (title != null) ...[
              AppText(
                title!,
                token: AppTextStyleToken.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s2),
            ],
            AppText(message, textAlign: TextAlign.center, secondary: true),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s6),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dekoratif motif kabı — ekran okuyucudan gizlidir (anlamı taşıyan metin
/// zaten altında okunur).
class _Motif extends StatelessWidget {
  const _Motif({
    required this.icon,
    required this.assetPath,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String? assetPath;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.progressRingLarge,
        height: AppSizes.progressRingLarge,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.lgAll,
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: assetPath == null
            ? Icon(icon, size: AppSizes.iconLg, color: foreground)
            : Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                width: AppSizes.progressRingLarge,
                height: AppSizes.progressRingLarge,
                // Asset yoksa sakin ikon fallback'i.
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, size: AppSizes.iconLg, color: foreground),
              ),
      ),
    );
  }
}

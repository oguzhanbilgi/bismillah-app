import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Kutsal içerik kaynak satırı (03_DESIGN_SYSTEM §34).
///
/// "No source, no render" kuralının UI ayağı: kaynak etiketi zorunlu
/// parametredir — kaynaksız kutsal içerik bloğu derlenemez.
class SacredContentSourceBadge extends StatelessWidget {
  const SacredContentSourceBadge({super.key, required this.sourceLabel});

  /// Ör: "Yâsîn 36:12 · Diyanet Meali" / "Buhârî 6018 · Sahih".
  /// Metin, içerik verisinden gelir — widget içine yazılmaz.
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.menu_book_outlined,
          size: AppSizes.iconSm,
          color: ext.textSecondary,
        ),
        const SizedBox(width: AppSpacing.s1),
        Flexible(
          child: Text(
            sourceLabel,
            style: AppTypography.caption.copyWith(color: ext.textSecondary),
          ),
        ),
      ],
    );
  }
}

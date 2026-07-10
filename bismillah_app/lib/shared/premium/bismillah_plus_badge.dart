import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Bismillah+ rozeti (03_DESIGN_SYSTEM §12.1).
///
/// KİLİT İKONU DEĞİLDİR ve kilit metaforuna dönüşemez; kutsal içerik
/// kartlarında kullanılamaz (hiçbir ayet/hadis/dua premium rozeti taşımaz).
/// Altın yalnız ince kontur vurgusudur — zemin/metin altın değildir.
class BismillahPlusBadge extends StatelessWidget {
  const BismillahPlusBadge({super.key, required this.label});

  /// Rozet etiketi (ör. "Bismillah+") — localization'dan gelir.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s1,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.smAll,
        border: Border.all(color: ext.accentGold),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: ext.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

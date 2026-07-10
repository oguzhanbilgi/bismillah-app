import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Tipografi token'larına bağlı metin bileşeni (03_DESIGN_SYSTEM §5).
/// Token dışı font boyutu kullanımını engellemenin ana yolu budur.
enum AppTextStyleToken {
  display,
  h1,
  h2,
  h3,
  body,
  bodySmall,
  caption,
  stat,
  statLarge,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.token = AppTextStyleToken.body,
    this.secondary = false,
    this.textAlign,
  });

  final String text;
  final AppTextStyleToken token;

  /// İkincil metin rengi (`textSecondary`) kullanılsın mı?
  final bool secondary;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    final base = switch (token) {
      AppTextStyleToken.display => AppTypography.display,
      AppTextStyleToken.h1 => AppTypography.h1,
      AppTextStyleToken.h2 => AppTypography.h2,
      AppTextStyleToken.h3 => AppTypography.h3,
      AppTextStyleToken.body => AppTypography.body,
      AppTextStyleToken.bodySmall => AppTypography.bodySmall,
      AppTextStyleToken.caption => AppTypography.caption,
      AppTextStyleToken.stat => AppTypography.stat,
      AppTextStyleToken.statLarge => AppTypography.statLarge,
    };
    final style = secondary ? base.copyWith(color: ext.textSecondary) : base;
    return Text(text, style: style, textAlign: textAlign);
  }
}

import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Yumuşak uçlu ilerleme çubuğu (03_DESIGN_SYSTEM §20): zümrüt dolgu,
/// krem ray; %0 durumda bile estetik — boş ray utandırmaz.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.semanticLabel})
    : assert(value >= 0 && value <= 1, 'value 0–1 aralığında olmalı');

  /// 0.0–1.0 arası ilerleme.
  final double value;

  /// Ekran okuyucu etiketi — localization'dan gelir.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: LinearProgressIndicator(
          value: value,
          minHeight: 8,
          color: scheme.primary,
          backgroundColor: ext.surfaceAlt,
        ),
      ),
    );
  }
}

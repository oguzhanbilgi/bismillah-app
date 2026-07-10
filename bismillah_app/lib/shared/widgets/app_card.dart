import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Standart kart kabuğu (03_DESIGN_SYSTEM §12): surface zemin,
/// `radius.lg`, yumuşak kart gölgesi, ferah iç dolgu.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.s5),
    this.completed = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Tamamlanmış durum: zemin `primarySoft`a yumuşar
  /// (kırmızı/uyarı durumu bu bileşende YOKTUR).
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: completed ? ext.primarySoft : scheme.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: ext.cardShadow,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: AppRadius.lgAll, child: card),
    );
  }
}

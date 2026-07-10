import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Boş durum = davet ekranı (03_DESIGN_SYSTEM §26): ikon + tek cümle
/// umut + tek eylem. Asla suçlama, asla çıplak "veri yok".
/// Tüm metinler dışarıdan (localization) gelir.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.spa_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconLg, color: scheme.primary),
            const SizedBox(height: AppSpacing.s4),
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

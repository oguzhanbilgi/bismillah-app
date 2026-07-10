import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Hata durumu (03_DESIGN_SYSTEM §27): insani mesaj + kurtarma eylemi.
/// Yumuşak kırmızı yalnız teknik bağlamda; ibadet bağlamında bu bileşen
/// bile kırmızı ikon kullanmaz — nötr bilgi ikonuyla düşer.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.technical = true,
  });

  /// İnsani hata mesajı — localization'dan gelir (failure.messageKey çözümü).
  final String message;

  final String retryLabel;
  final VoidCallback onRetry;

  /// Teknik hata mı? (Yalnız teknik hatalar error rengi alabilir.)
  final bool technical;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              technical ? Icons.cloud_off_outlined : Icons.info_outline,
              size: AppSizes.iconLg,
              color: technical ? scheme.error : scheme.primary,
            ),
            const SizedBox(height: AppSpacing.s4),
            AppText(message, textAlign: TextAlign.center, secondary: true),
            const SizedBox(height: AppSpacing.s6),
            AppButton(
              label: retryLabel,
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Tek vakit satırı: etiket + sakin durum + eylem.
///
/// Ton kuralı (CLAUDE.md / 02_BRAND): tamamlanmamış vakit bir EKSİK
/// değildir — kırmızı yok, uyarı yok; yalnız davetkâr "İşaretle" eylemi.
/// Metinler ekrandan (localization'dan çözülmüş) gelir; bu widget saf
/// görsel bileşendir, provider/Drift bilmez.
class PrayerEntryTile extends StatelessWidget {
  const PrayerEntryTile({
    super.key,
    required this.label,
    required this.completed,
    required this.completedLabel,
    required this.actionLabel,
    required this.onToggle,
    this.time,
  });

  final String label;

  /// Hesaplanmış vakit (ör. "05:21") — konum yoksa `null`, satır yine
  /// işaretlenebilir (vakit hesabı, kayıttan bağımsızdır).
  final String? time;

  final bool completed;

  /// Tamamlanmış durum alt metni (ör. "Tamamlandı").
  final String completedLabel;

  /// Eylem etiketi ("İşaretle" / "Geri al").
  final String actionLabel;

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      completed: completed,
      onTap: onToggle,
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            size: AppSizes.iconMd,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, token: AppTextStyleToken.h3),
                if (time case final t?) ...[
                  const SizedBox(height: AppSpacing.s1),
                  AppText(t, token: AppTextStyleToken.stat),
                ],
                if (completed) ...[
                  const SizedBox(height: AppSpacing.s1),
                  AppText(
                    completedLabel,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                ],
              ],
            ),
          ),
          AppButton(
            label: actionLabel,
            variant: AppButtonVariant.text,
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Bölüm başlığı: başlık + opsiyonel alt başlık + opsiyonel sağ eylem
/// (03_DESIGN_SYSTEM §12).
///
/// RDX-01B: referans tasarımdaki "Kategoriler … Tümünü Gör" düzeni için
/// [subtitle] ve metin tabanlı [actionLabel]/[onActionTap] eklendi. Eylem
/// SESSİZDİR — dolu buton değil, metin eylemidir; bölüm başlığı ekranın
/// birincil eylemiyle yarışmaz. Serbest [trailing] alanı korunur.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.actionLabel,
    this.onActionTap,
  }) : assert(
         actionLabel == null || trailing == null,
         'Tek bir sağ eylem kullanın: actionLabel veya trailing.',
       );

  final String title;

  /// Başlığın altındaki tek satırlık açıklama. Referansta bölümün ne
  /// olduğunu anlatan sakin meta satırıdır.
  final String? subtitle;

  /// Serbest sağ eylem (korunan eski API).
  final Widget? trailing;

  /// Metin eylemi etiketi — daima localization'dan gelir.
  final String? actionLabel;

  /// [actionLabel] verildiğinde çalışacak eylem. `null` ise etiket sessiz
  /// bir metin olarak çizilir ve DOKUNULABİLİR GÖRÜNMEZ.
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final action = actionLabel;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s7, bottom: AppSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, token: AppTextStyleToken.h3),
                if (subtitle case final String value) ...[
                  const SizedBox(height: AppSpacing.s1),
                  AppText(
                    value,
                    token: AppTextStyleToken.caption,
                    tone: AppTextTone.secondary,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
          if (action != null) _SectionAction(label: action, onTap: onActionTap),
        ],
      ),
    );
  }
}

/// Sessiz metin eylemi. Dokunma hedefi görsel yüksekliğinden bağımsız
/// olarak erişilebilir kalsın diye dolgu ile büyütülür.
class _SectionAction extends StatelessWidget {
  const _SectionAction({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(
      label,
      token: AppTextStyleToken.caption,
      color: onTap == null ? null : scheme.primary,
      tone: onTap == null ? AppTextTone.secondary : null,
      maxLines: 1,
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s1),
        child: text,
      );
    }
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s1,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.compact,
      ),
      child: text,
    );
  }
}

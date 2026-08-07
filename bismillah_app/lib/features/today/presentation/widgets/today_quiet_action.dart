import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Today kart içi sessiz eylem (RDX-01C3).
///
/// `AppButton(variant: text)` yatayda `s6` (24) dolgu taşır; kart içinde
/// kullanıldığında etiket, kartın kendi içeriğinden 24px içeride başlar ve
/// hizasız görünür — telefonda en çok "jenerik Material" hissi veren detay
/// buydu. Bu eylem etiketi kart içeriğiyle AYNI hizada başlatır, dokunma
/// hedefini ise `touchTarget` (48) yüksekliğiyle korur.
///
/// `AppButton` DEĞİŞTİRİLMEDİ: onu tüm ekranlar kullanır ve dolgusu form/
/// alt sayfa bağlamlarında doğrudur.
///
/// Eylem bilinçli olarak SESSİZDİR: dolu zemin, kenarlık, altın renk veya
/// büyük bir pill YOKTUR. Keşfedilebilirliği birincil rengi ve yön duyarlı
/// chevron'u taşır.
class TodayQuietAction extends StatelessWidget {
  const TodayQuietAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// Kullanıcıya görünen etiket — daima localization'dan gelir.
  final String label;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // `Icons.chevron_right` kendiliğinden aynalanmaz; yön burada AÇIKÇA
    // çözülür, böylece Arapça'da ok metnin aktığı yöne bakar.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.smAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AppText(
                    label,
                    token: AppTextStyleToken.bodySmall,
                    color: scheme.primary,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.s1),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  size: AppSizes.iconSm,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

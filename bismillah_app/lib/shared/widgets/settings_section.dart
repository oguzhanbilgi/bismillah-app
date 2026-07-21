import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Ayar grubu (TASK 055): bölüm başlığı + tonal yüzeyde, ince divider'la
/// ayrılmış ayar satırları. Her satır AYRI ağır kart DEĞİLDİR — grup tek
/// sakin yüzeyde yaşar, gölge yoktur.
///
/// RTL: satır düzeni `Row` + `AlignmentDirectional` mantığıyla otomatik
/// terslenir; trailing ok ikonu yöne göre doğru tarafı gösterir.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.rows});

  /// Bölüm başlığı — daima localization'dan gelir.
  final String title;

  /// Gruptaki ayar satırları (en az bir tane).
  final List<SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s3),
        ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.sectionSurface,
              borderRadius: AppRadius.lgAll,
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      color: tokens.surfaceBorder,
                      height: 1,
                      indent: AppSpacing.s4,
                      endIndent: AppSpacing.s4,
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// [SettingsSection] içindeki tek ayar satırı.
///
/// Ekran okuyucu için tek anlamlı düğümdür: başlık + (varsa) değer birlikte
/// okunur, dokunma aksiyonu korunur. Minimum dokunma yüksekliği 48dp.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.value,
    this.valueDirection,
    this.onTap,
    this.leadingIcon,
  });

  /// Satır başlığı — localization'dan gelir.
  final String title;

  /// Opsiyonel mevcut değer (ör. seçili dilin kendi adı).
  final String? value;

  /// Değerin yön override'ı (ör. Arapça dil adı LTR arayüzde de RTL yazılır).
  final TextDirection? valueDirection;

  final VoidCallback? onTap;

  /// Opsiyonel sakin başlık ikonu.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final value = this.value;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: tokens.spiritualGreenStrong),
              const SizedBox(width: AppSpacing.s3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(title),
                  if (value != null) ...[
                    const SizedBox(height: AppSpacing.s1),
                    Directionality(
                      textDirection:
                          valueDirection ?? Directionality.of(context),
                      child: AppText(
                        value,
                        token: AppTextStyleToken.caption,
                        secondary: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.s2),
              // Ok, okuma yönünde İLERİYİ gösterir (RTL'de sola bakar).
              Icon(
                isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: tokens.spiritualGreenStrong,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) {
      return Semantics(container: true, child: content);
    }
    // ExcludeSemantics yalnız İÇERİĞİ sarar — InkWell dışarıda kalır ki
    // ekran okuyucudan etkinleştirme (tap) aksiyonu korunsun (TASK 053
    // dil seçici deseniyle aynı).
    return Semantics(
      button: true,
      // Başlık + değer tek anlamlı etikette birleşir.
      label: value == null ? title : '$title, $value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ExcludeSemantics(child: content),
        ),
      ),
    );
  }
}

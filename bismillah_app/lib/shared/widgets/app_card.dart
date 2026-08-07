import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/widgets/app_press_scale.dart';
import 'package:flutter/material.dart';

/// Kart yüzey ailesi (TASK 054).
///
/// Amaç: art arda dizilen AYNI beyaz kart hissini kırmak. Kart rolüne göre
/// yüzey seçer; hepsine ağır gölge verilmez — tonal ve border'lı varyantlar
/// gölgesizdir, böylece ekranda görsel gürültü birikmez.
enum AppCardVariant {
  /// Varsayılan: surface zemin + yumuşak gölge (mevcut davranış).
  elevated,

  /// Sıcak kum yüzeyi, gölgesiz — davetkâr/karşılama kartları.
  sand,

  /// Sakin adaçayı yüzeyi, gölgesiz — Kur'an ve manevi bölümler.
  sage,

  /// Gölge yerine ince kenarlık — yoğun listelerde sakin ayrım.
  outlined,
}

/// Standart kart kabuğu (03_DESIGN_SYSTEM §12): surface zemin,
/// `radius.lg`, yumuşak kart gölgesi, ferah iç dolgu.
///
/// [variant] ile yüzey ailesi değiştirilebilir; varsayılan [
/// AppCardVariant.elevated] mevcut görünümü aynen korur.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.s5),
    this.completed = false,
    this.variant = AppCardVariant.elevated,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Tamamlanmış durum: zemin `primarySoft`a yumuşar
  /// (kırmızı/uyarı durumu bu bileşende YOKTUR).
  final bool completed;

  /// Yüzey ailesi — kart hiyerarşisini çeşitlendirir.
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final tokens = IslamicVisualTokens.of(context);

    // `completed` yüzey seçimini EZER: tamamlanma geri bildirimi
    // varyanttan önce gelir (mevcut davranış korunur).
    final background = completed
        ? ext.primarySoft
        : switch (variant) {
            AppCardVariant.elevated => scheme.surface,
            AppCardVariant.sand => tokens.sandSurface,
            AppCardVariant.sage => tokens.sageSurface,
            AppCardVariant.outlined => tokens.sacredSurface,
          };

    // Tonal ve border'lı varyantlar gölgesizdir — ekrandaki gölge
    // yoğunluğu düşer, hiyerarşi renkle kurulur.
    final shadow = switch (variant) {
      AppCardVariant.elevated => ext.cardShadow,
      _ => null,
    };

    // RDX-01B: yükseltilmiş kart artık gölgeye EK OLARAK saç teli kalınlığında
    // bir kenarlık taşır. İki gerekçe var: (1) koyu temada gölge neredeyse
    // görünmezdir, kartın kenarını yalnız çizgi tanımlar; (2) referans
    // tasarımda derinlik ağır gölgeyle değil, net kenar + çok yumuşak gölgeyle
    // kuruluyor. `outlined` varyantı hâlâ AYRIDIR: orada gölge yoktur ve
    // ayrımı yalnız çizgi taşır.
    final border = switch (variant) {
      AppCardVariant.elevated ||
      AppCardVariant.outlined => Border.all(color: tokens.surfaceBorder),
      _ => null,
    };

    // TASK 094A: `completed` değiştiğinde zemin sert biçimde değişmez,
    // seçim süresinde yumuşar. Yapı aynıdır (dekorasyon + iç dolgu);
    // yalnız renk geçişi zamana yayılır. Reduced-motion açıkken süre
    // sıfırdır, yani davranış eski hâline birebir döner.
    final card = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.selection),
      curve: AppMotion.selectionCurve,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.lgAll,
        boxShadow: shadow,
        border: border,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return card;
    }
    return AppPressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: card,
        ),
      ),
    );
  }
}

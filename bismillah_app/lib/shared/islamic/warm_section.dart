import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/islamic/islamic_pattern_background.dart';
import 'package:flutter/material.dart';

/// Sıcak tonal bölüm kabı (TASK 054).
///
/// Amaç: ekranı "art arda beyaz kartlar" olmaktan çıkarıp anlamlı GRUPLARA
/// ayırmak. Kart DEĞİLDİR — gölgesizdir ve içine kart alabilir.
///
/// Kurallar:
/// - Desen opsiyoneldir ve token opaklığını AŞMAZ; kutsal metin (ayet/meal)
///   içeren alanların arkasına desen konmaz — çağıran `showPattern: false`
///   geçmelidir.
/// - Dekoratif katmanlar semantics dışıdır ([IslamicPatternBackground]
///   kendi içinde `ExcludeSemantics` + `IgnorePointer` uygular).
/// - Animasyon YOKTUR.
class WarmSection extends StatelessWidget {
  const WarmSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s4,
      vertical: AppSpacing.s5,
    ),
    this.showPattern = false,
    this.surface = WarmSectionSurface.section,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Çok düşük opaklıklı geometrik desen gösterilsin mi.
  final bool showPattern;

  final WarmSectionSurface surface;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final background = switch (surface) {
      WarmSectionSurface.section => tokens.sectionSurface,
      WarmSectionSurface.sand => tokens.sandSurface,
      WarmSectionSurface.sage => tokens.sageSurface,
    };

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: Stack(
          children: [
            if (showPattern)
              // Desen yalnız atmosferdir: içerik hep üstünde çizilir.
              const Positioned.fill(child: IslamicPatternBackground()),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// [WarmSection] yüzey ailesi.
enum WarmSectionSurface { section, sand, sage }

import 'package:flutter/widgets.dart';

/// Hareket token'ları (03_DESIGN_SYSTEM §29): "su gibi — yumuşak giren,
/// yumuşak duran". Token dışı `Duration` değeri projede yasaktır.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration gentle = Duration(milliseconds: 500);
  static const Duration celebration = Duration(milliseconds: 800);

  static const Curve instantCurve = Curves.easeOut;
  static const Curve quickCurve = Curves.easeOutCubic;
  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve gentleCurve = Curves.easeOutQuart;
  static const Curve celebrationCurve = Curves.easeOutBack;

  /// Reduced-motion desteği: sistem animasyon kapatmayı istiyorsa
  /// süreleri sıfıra indirir (03_DESIGN_SYSTEM §29).
  static Duration of(BuildContext context, Duration token) {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disable ? Duration.zero : token;
  }
}

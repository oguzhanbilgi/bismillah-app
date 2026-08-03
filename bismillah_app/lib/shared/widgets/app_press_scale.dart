import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:flutter/widgets.dart';

/// Dokunma geri bildirimi: basılıyken yüzey çok az çöker (TASK 095).
///
/// Jesti **sahiplenmez** — `Listener` yalnız işaretçi olaylarını dinler,
/// jest arenasına girmez. Bu yüzden alttaki `InkWell`/buton dokunuşu,
/// dalgası ve semantiği aynen çalışmaya devam eder.
///
/// Reduced-motion açıkken hiç küçülmez ve süre sıfırdır.
class AppPressScale extends StatefulWidget {
  const AppPressScale({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// Dokunulamayan (salt-okunur) yüzeylerde `false` verilir; o zaman
  /// hiçbir dinleyici veya animasyon eklenmez.
  final bool enabled;

  @override
  State<AppPressScale> createState() => _AppPressScaleState();
}

class _AppPressScaleState extends State<AppPressScale> {
  bool _pressed = false;

  void _setPressed({required bool value}) {
    if (_pressed == value || !mounted) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return Listener(
      onPointerDown: (_) => _setPressed(value: true),
      onPointerUp: (_) => _setPressed(value: false),
      onPointerCancel: (_) => _setPressed(value: false),
      child: AnimatedScale(
        scale: AppMotion.pressScaleOf(context, pressed: _pressed),
        duration: AppMotion.of(context, AppMotion.tap),
        curve: AppMotion.tapCurve,
        child: widget.child,
      ),
    );
  }
}

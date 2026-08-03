import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:flutter/widgets.dart';

/// Durum değişimini sakin bir çapraz geçişle gösteren ortak sarmalayıcı
/// (TASK 094A).
///
/// Kullanım alanı: aynı yerde duran ama **anlamı değişen** küçük bir
/// öğe — tamamlandı işareti, seçim işareti, dinle/yükleniyor/duraklat
/// düğmesinin içeriği.
///
/// ## Sınırlar
///
/// Kutlama, konfeti, sürekli parlama ve zıplayan yay eğrisi YOKTUR:
/// yalnız sönümlenen bir opaklık ve 0.94'ten 1'e çok küçük bir ölçek.
/// Kur'an metni bu bileşenle **sarılmaz** — ayet metni hareket etmez.
///
/// Reduced-motion açıkken süre sıfırlanır; geçiş anında tamamlanır ve
/// ölçek hiç uygulanmamış olur (animasyon değeri doğrudan 1'e gider).
class AppMotionSwitcher extends StatelessWidget {
  const AppMotionSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.stateChange,
    this.curve = AppMotion.stateChangeCurve,
  });

  /// Değiştiğinde geçişin tetiklenmesi için **anlamlı bir `key` taşımalıdır**
  /// (ör. `ValueKey(status)`); anahtarsız çocuk aynı sayılır ve geçiş olmaz.
  final Widget child;

  final Duration duration;
  final Curve curve;

  /// Giriş ölçeğinin başlangıcı — göze çarpmayan, tek yönlü.
  static const double _enterScale = 0.94;

  @override
  Widget build(BuildContext context) {
    final resolved = AppMotion.of(context, duration);
    return AnimatedSwitcher(
      duration: resolved,
      reverseDuration: resolved,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: _enterScale, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

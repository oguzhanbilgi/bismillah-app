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

  // --- Anlamsal hareket katmanı (TASK 095) -------------------------------
  //
  // Yukarıdaki ölçek token'ları ("ne kadar uzun") korunur; aşağıdakiler
  // **rol** token'larıdır ("hangi etkileşim"). Bir yüzey artık ham süre
  // seçmez, etkileşimin adını seçer.
  //
  // Kapsam bilinçli olarak dardır: burada YALNIZ gerçekten tüketilen
  // roller vardır. Panel, sayfa geçişi ve stagger token'ları EKLENMEDİ,
  // çünkü bu görevde onları tüketen bir yüzey yok ve kullanılmayan bir
  // token sonraki görevde yanlışlıkla "onaylanmış tasarım" sanılır.

  /// Dokunma geri bildirimi — basılı tutulurken yüzeyin hafif çökmesi.
  static const Duration tap = Duration(milliseconds: 120);

  /// Seçim geri bildirimi — seçili/seçili değil arası yüzey ve ikon.
  static const Duration selection = Duration(milliseconds: 180);

  /// Durum geçişi — tamamlandı, yükleniyor, çalıyor gibi hâl değişimi.
  static const Duration stateChange = Duration(milliseconds: 240);

  static const Curve tapCurve = Curves.easeOut;
  static const Curve selectionCurve = Curves.easeOutCubic;
  static const Curve stateChangeCurve = Curves.easeInOutCubic;

  /// Basılı hâlde uygulanan ölçek. Zıplama (bounce) YOKTUR: tek yönlü,
  /// çok küçük bir çöküş.
  static const double pressedScale = 0.98;

  /// Sistem "animasyonları azalt" diyorsa `true`.
  ///
  /// Tek karar noktasıdır: süre, ölçek ve geçiş kararlarının hepsi bunu
  /// sorar; hiçbir yüzey `MediaQuery`'yi kendi başına okumaz.
  static bool isReduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Reduced-motion desteği: sistem animasyon kapatmayı istiyorsa
  /// süreleri sıfıra indirir (03_DESIGN_SYSTEM §29).
  static Duration of(BuildContext context, Duration token) =>
      isReduced(context) ? Duration.zero : token;

  /// Basılı ölçek değeri; reduced-motion açıkken **hiç küçülmez**.
  static double pressScaleOf(BuildContext context, {required bool pressed}) =>
      pressed && !isReduced(context) ? pressedScale : 1;
}

import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Today bölüm etiketi (RDX-01C3).
///
/// Paylaşılan `AppSectionHeader` Today için fazla ferahtır: sabit `s7` (32)
/// üst boşluğu telefon boyunda ekranı ikiye böler ve arka arkaya iki başlık
/// geldiğinde aralarında ölü alan bırakır. Bu etiket AYNI tipografi
/// token'ını (`h3`) kullanır — yeni bir başlık boyutu icat etmez —, yalnız
/// Today kompozisyonuna göre daraltılır ve üst boşluğu çağıran tarafa
/// bırakır.
///
/// `AppSectionHeader` DEĞİŞTİRİLMEDİ: onu Learn, Profile ve Kur'an ekranları
/// da kullanır; Today'in yoğunluk kararı o ekranlara sızmamalıdır.
///
/// ## Altın kullanımı
///
/// Başlığın önündeki saç teli çizgi, ekranda altının göründüğü iki yerden
/// biridir ve kasıtlı olarak NADİRDİR: buton, kenarlık, kart zemini, ikon
/// dolgusu veya metin rengi olarak altın KULLANILMAZ. Çizgi dekoratiftir;
/// tek başına hiçbir bilgi taşımaz, bu yüzden görülmediğinde de etiket tam
/// olarak okunur.
class TodaySectionLabel extends StatelessWidget {
  const TodaySectionLabel({
    super.key,
    required this.title,
    this.trailing,
    this.topSpacing = AppSpacing.s5,
  });

  /// Bölüm başlığı — daima localization'dan gelir.
  final String title;

  /// Opsiyonel sağ eylem (ör. "İlerlemem").
  final Widget? trailing;

  /// Üst boşluk. Bir grup başlığının hemen ardından gelen alt bölümler
  /// daha küçük bir değer geçer, böylece iki başlık üst üste yığılmaz.
  final double topSpacing;

  /// Vurgu çizgisinin genişliği. Saç teli kalınlığındadır: fark edilir ama
  /// başlıkla yarışmaz.
  static const double _accentWidth = 3;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);

    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: AppSpacing.s3),
      child: Row(
        children: [
          // Yön duyarlı: Arapça'da satırın sonunda (sağda) çizilir, çünkü
          // konumu `Row` + `Directionality` belirler, sabit bir kenar değil.
          DecoratedBox(
            decoration: BoxDecoration(
              color: ext.accentGold,
              borderRadius: AppRadius.pillAll,
            ),
            child: const SizedBox(width: _accentWidth, height: AppSpacing.s4),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: AppText(title, token: AppTextStyleToken.h3, maxLines: 2),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

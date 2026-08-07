import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Today marka başlığı (RDX-02A).
///
/// Ekranın tepesindeki jenerik "Bugün" AppBar başlığının yerini alır. Bir
/// hero DEĞİLDİR: yaklaşık normal bir uygulama başlığı yüksekliğinde durur,
/// arkasında gradient/glow/cam efekti yoktur ve slogan taşımaz.
///
/// ## Marka görseli
///
/// Kullanılan tek çalışma-zamanı görseli, onaylı şeffaf marka glyph'inin
/// **doğru oranda küçültülmüş** bir kopyasıdır. Sanat eseri yeniden
/// çizilmedi, yeniden üretilmedi, renklendirilmedi; yalnız kendi saydam
/// kenar boşluğu kırpıldı ve ölçeklendi — Arapça `الله` kaligrafisine
/// dokunulmadı. Büyük sunum mockup'ı (`bismillah_app_icon_light.png`)
/// uygulama içinde KULLANILMAZ; o bir sunum render'ıdır.
///
/// Glyph dekoratiftir: kendi başına hiçbir bilgi taşımaz, bu yüzden ekran
/// okuyucudan gizlenir ve marka adı metin olarak okunur.
class TodayBrandHeader extends StatelessWidget {
  const TodayBrandHeader({super.key, required this.onOpenProfile});

  /// Mevcut Profil rotasına geçiş — navigasyon kararı ekranın işidir.
  final VoidCallback onOpenProfile;

  /// Çalışma-zamanı marka glyph'i. Yalnız BU dosya pubspec'e kayıtlıdır;
  /// büyük kaynak PNG'ler depoda kalır ama APK'ya girmez.
  static const String glyphAsset = 'assets/branding/bismillah_glyph_header.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s2, bottom: AppSpacing.s1),
      child: Row(
        children: [
          // Yükseklik sabittir ve yazı ölçeğiyle BÜYÜMEZ: başlığın kompakt
          // kalması bu görevin açık gereğidir. Genişlik `fit` ile oranından
          // türetilir, esnetilmez.
          ExcludeSemantics(
            child: Image.asset(
              glyphAsset,
              height: AppSizes.iconLg,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: AppText(
              // Marka adı üç dilde de aynıdır; yeni bir metin uydurulmadı.
              l10n.appTitle,
              token: AppTextStyleToken.h2,
              maxLines: 1,
            ),
          ),
          // Sessiz profil erişimi. Dolu buton değil; ikon eylemi. Dokunma
          // hedefi 48dp'de tutulur, görsel ağırlık düşük kalır.
          IconButton(
            onPressed: onOpenProfile,
            tooltip: l10n.tabProfile,
            icon: const Icon(Icons.person_outline),
            iconSize: AppSizes.iconMd,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: AppSizes.touchTarget,
              minHeight: AppSizes.touchTarget,
            ),
          ),
        ],
      ),
    );
  }
}

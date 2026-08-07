import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/presentation/today_plan_item_presentation.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Tek bir günlük plan görevi satırı (TASK 083; görsel dil RDX-01C1).
///
/// RDX-01C1: görev artık KENDİ kartı değildir. Önceden her görev, plan
/// kartının içine yerleştirilmiş ayrı bir `AppCard` idi; bu, kart içinde kart
/// yığını üretiyor ve ekranı jenerik bir liste gibi gösteriyordu. Referans
/// tasarımda görevler TEK kartın içinde, saç teli ayraçlarla bölünmüş
/// satırlardır. Ayraçları liste sahibi ([TodayPlanSection]) çizer; satır
/// yalnız kendi iç ritmini bilir.
///
/// ## Ton
///
/// Tamamlanmamış görev bir **başarısızlık değildir**: kırmızı renk, uyarı
/// ikonu, "kaçırdın" dili, seri (streak) kaybı, puan veya sıralama YOKTUR.
/// Tamamlanan görev yalnız yumuşak bir yüzey ve onay ikonu alır.
///
/// İşaretleme uygulama içi bir **takip** eylemidir; ibadetin yerine
/// getirildiği, kabul edildiği veya manevi bir derece kazanıldığı iddiası
/// DEĞİLDİR.
class TodayPlanTaskCard extends StatelessWidget {
  const TodayPlanTaskCard({
    super.key,
    required this.item,
    required this.presentation,
    this.onToggle,
  });

  final PlanItem item;
  final TodayPlanItemPresentation presentation;

  /// Tamamlanma durumunu çevirir; `null` ise satır salt-okunurdur
  /// (ör. kaydetme sürerken).
  final VoidCallback? onToggle;

  /// Satır metninin, satırın başlangıç kenarından uzaklığı — ikon karesi +
  /// aradaki boşluk. Ayracı çizen [TodayPlanSection] aynı değeri girinti
  /// olarak kullanır, böylece çizgi metinle hizalanır ve iki yerde birbirinden
  /// bağımsız sayı tutulmaz.
  static const double rowContentIndent = _iconTileSize + AppSpacing.s3;

  /// İkon karesinin kenarı. Token'lardan bileşiktir (`iconLg` + `s1`): ikonu
  /// nefes aldıracak kadar büyük, satırı liste görünümüne çevirmeyecek kadar
  /// küçük.
  static const double _iconTileSize = AppSizes.iconLg + AppSpacing.s1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final completed = item.isCompleted;

    final statusLabel = completed
        ? l10n.todayPlanItemCompleted
        : l10n.todayPlanItemPending;

    return Semantics(
      button: onToggle != null,
      // Ekran okuyucu tek cümlede görevi ve durumunu duyar.
      label: '${presentation.title}, $statusLabel',
      toggled: completed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            // RDX-01C3: dikey dolgu `s3`ten `s2`ye iner. Satır hâlâ 48dp
            // dokunma hedefinin üstündedir (`minHeight` değişmedi), yalnız
            // kart içindeki ritim sıkışır — dört görev artık ilk ekranda
            // birlikte okunur.
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.touchTarget,
              ),
              child: Row(
                children: [
                  // Küçük tonal ikon karesi — referanstaki satır ritmini
                  // verir ve taramayı kolaylaştırır. Tamamlandığında zemin
                  // yumuşak zümrüde döner; UYARI/HATA rengi kullanılmaz.
                  _IconTile(
                    icon: presentation.icon,
                    background: completed ? ext.primarySoft : ext.surfaceAlt,
                    foreground: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Uzun/çok dilli başlıklar dar ekranda taşmaz.
                        //
                        // RDX-01C3: tamamlanan görevin başlığı ikincil
                        // mürekkebe düşer. Bu, "bitti"yi üstü çizili metin,
                        // kırmızı renk veya rozet OLMADAN okutan en sakin
                        // sinyaldir; sıra, konum ve metin değişmez.
                        AppText(
                          presentation.title,
                          tone: completed
                              ? AppTextTone.secondary
                              : AppTextTone.primary,
                          maxLines: 2,
                        ),
                        AppText(
                          statusLabel,
                          token: AppTextStyleToken.caption,
                          tone: AppTextTone.tertiary,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  // Onay göstergesi: tamamlanmamışta nötr boş halka —
                  // uyarı/hata rengi KULLANILMAZ.
                  //
                  // TASK 094A: işaret sert biçimde yer değiştirmez, sakin bir
                  // çapraz geçişle belirir. Kutlama, konfeti, zıplama, puan
                  // ve seri dili YOKTUR; geçiş yalnız "değişti" der.
                  AppMotionSwitcher(
                    child: Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey<bool>(completed),
                      size: AppSizes.iconMd,
                      color: completed ? scheme.primary : ext.disabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Görev türünü taşıyan küçük tonal kare. Dekoratif değildir: satırın
/// türünü bir bakışta okunur kılar.
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TodayPlanTaskCard._iconTileSize,
      height: TodayPlanTaskCard._iconTileSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        // RDX-01C3: `md` (12) yerine `sm` (8). Küçülen karede 12'lik yarıçap
        // daireye yaklaşıp rozet gibi okunuyordu; 8 kareyi kare bırakır.
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(icon, size: AppSizes.iconMd, color: foreground),
    );
  }
}

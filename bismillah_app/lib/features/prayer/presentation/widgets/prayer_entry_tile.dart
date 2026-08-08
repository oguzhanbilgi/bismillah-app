import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Tek vakit satırı: ad + saat + sakin durum.
///
/// RDX-03A: satır artık KENDİ kartı değildir. Önceden her vakit ayrı bir
/// `AppCard` idi; beş vakit yan yana geldiğinde ekran, birbiriyle ilişkisiz
/// beş beyaz kutu yığınına dönüşüyordu. Artık beş satır TEK yüzeyin
/// (`_DailyPrayersCard`) içinde, saç teli ayraçlarla bölünmüş satırlar
/// olarak yaşar — ayraçları liste sahibi çizer, satır yalnız kendi iç
/// ritmini bilir. Bu, Today plan kartının RDX-01C1'de aldığı kararla aynı
/// dildir; yeni bir "premium kart" ailesi İCAT EDİLMEZ.
///
/// Etkileşim DEĞİŞMEDİ: satıra dokunmak işaretler/geri alır ve eylem
/// etiketi ("İşaretle" / "Geri al") satırda görünür kalır — mevcut
/// keşfedilebilirlik korunur, yalnız dolu bir buton yerine sakin bir alt
/// satır olarak okunur.
///
/// Ton kuralı (CLAUDE.md / 02_BRAND): tamamlanmamış vakit bir EKSİK
/// değildir — kırmızı yok, uyarı yok, seri/puan/rozet yok. Metinler ekrandan
/// (localization'dan çözülmüş) gelir; bu widget saf görsel bileşendir,
/// provider/Drift bilmez.
class PrayerEntryTile extends StatelessWidget {
  const PrayerEntryTile({
    super.key,
    required this.label,
    required this.completed,
    required this.completedLabel,
    required this.actionLabel,
    required this.onToggle,
    this.time,
    this.isNext = false,
    this.nextLabel,
  });

  final String label;

  /// Hesaplanmış vakit (ör. "05:21") — konum yoksa `null`, satır yine
  /// işaretlenebilir (vakit hesabı, kayıttan bağımsızdır).
  final String? time;

  final bool completed;

  /// Tamamlanmış durum alt metni (ör. "Tamamlandı").
  final String completedLabel;

  /// Eylem etiketi ("İşaretle" / "Geri al").
  final String actionLabel;

  final VoidCallback onToggle;

  /// Bu satır, GERÇEKTEN sıradaki vakit mi? (RDX-03B)
  ///
  /// Yalnız bulmayı kolaylaştıran DEKORATİF bir ipucudur: yumuşak tonal bir
  /// zemin. Yanıp sönme, geri sayım, altın dolgu, "CANLI" rozeti veya
  /// herhangi bir oyunlaştırma YOKTUR ve tamamlanma geri bildirimi (onay
  /// ikonu + sönümlenen mürekkep) her zaman daha baskındır. Karar bu widget'a
  /// AİT DEĞİLDİR — çağıran, mevcut vakit verisinden hesaplar; burada yeni
  /// bir hesap veya timer kurulmaz.
  final bool isNext;

  /// [isNext] doğruyken ekran okuyucuya eklenen etiket (ör. "Sıradaki
  /// namaz"). Zemin rengi görülmese bile bilgi kaybolmasın diye vardır;
  /// `null` ise semantiğe hiçbir şey eklenmez.
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    return Semantics(
      button: true,
      // Ekran okuyucu tek cümlede vakti, saatini, durumunu ve eylemini duyar.
      // Sıradaki vakit ipucu SEMANTİĞE de girer: renk görülmediğinde bilgi
      // kaybolmaz.
      label: [
        label,
        ?time,
        if (isNext) ?nextLabel,
        if (completed) completedLabel,
        actionLabel,
      ].join(', '),
      toggled: completed,
      excludeSemantics: true,
      child: Material(
        // RDX-03B: sıradaki vakit YUMUŞAK tonal bir zeminle bulunması
        // kolaylaşır. `surfaceAlt` kartın kendi yüzeyinin yalnız bir kademe
        // altındadır — ikinci bir hero, altın dolgu veya uyarı rengi
        // DEĞİLDİR. Tamamlanma geri bildirimi (dolu onay ikonu + sönümlenen
        // mürekkep) bu ipucundan görsel olarak daha güçlü kalır.
        color: isNext ? ext.surfaceAlt : Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onToggle,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s2,
              vertical: AppSpacing.s2,
            ),
            child: ConstrainedBox(
              // 48dp dokunma hedefi — dikey dolgu daralsa bile korunur.
              constraints: const BoxConstraints(
                minHeight: AppSizes.touchTarget,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // `Expanded`: saat satırın SONUNA yaslanır
                            // (RTL'de otomatik olarak başa geçer, çünkü
                            // konumu `Directionality` belirler). Uzun/çok
                            // dilli ad dar ekranda taşmaz, kırpılır.
                            Expanded(
                              child: AppText(
                                label,
                                token: AppTextStyleToken.h3,
                                tone: completed
                                    ? AppTextTone.secondary
                                    : AppTextTone.primary,
                                maxLines: 1,
                              ),
                            ),
                            if (time case final t?) ...[
                              const SizedBox(width: AppSpacing.s3),
                              // RDX-03A: saat `stat` (28) değil `h3` (17).
                              // 28px satır yüksekliğini şişiriyor ve beş
                              // satır birden ekranı dolduruyordu; ayrıca
                              // `stat` artık sıradaki-namaz bloğunun
                              // ayrıcalığıdır — hiyerarşi böyle kurulur.
                              AppText(
                                t,
                                token: AppTextStyleToken.h3,
                                tone: completed
                                    ? AppTextTone.secondary
                                    : AppTextTone.primary,
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                        // Durum ve eylem AYRI kalır: tamamlanmış satır hem
                        // "Tamamlandı" der hem geri alma eylemini görünür
                        // tutar. Eylem dolu bir buton DEĞİL, birincil renkli
                        // sakin bir etikettir; keşfedilebilirliği rengi ve
                        // satırın tamamının dokunulabilir olması taşır.
                        Row(
                          children: [
                            if (completed) ...[
                              AppText(
                                completedLabel,
                                token: AppTextStyleToken.caption,
                                tone: AppTextTone.tertiary,
                                maxLines: 1,
                              ),
                              const SizedBox(width: AppSpacing.s2),
                            ],
                            Flexible(
                              child: AppText(
                                actionLabel,
                                token: AppTextStyleToken.caption,
                                color: scheme.primary,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  // Onay göstergesi: tamamlanmamışta nötr boş halka —
                  // uyarı/hata rengi KULLANILMAZ. Geçiş sakin bir çapraz
                  // geçiştir (TASK 094A); kutlama, konfeti, zıplama YOKTUR.
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

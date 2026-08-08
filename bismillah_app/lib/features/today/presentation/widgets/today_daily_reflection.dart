import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/today/domain/today_reflection.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today'in sakin kapanış cümlesi (RDX-02B).
///
/// Teknik alt bilgi satırının ("Kayıtların cihazında saklanır.") yerini alır.
/// Depolama/uygulama dili Today'e ait değildir; o bilgi Namaz ve Gizlilik
/// yüzeylerinde OLDUĞU GİBİ durur.
///
/// ## Ne DEĞİLDİR
///
/// Ayet, hadis, dua, fetva veya Allah'a ya da Peygamber'e atfedilen bir söz
/// **değildir**. Bu yüzden burada tırnak işareti, kaynak künyesi, "buyurdu"
/// dili, sevap vaadi ve büyük alıntı işareti YOKTUR. Başlık da verilmez:
/// "Hadis", "Ayet" veya "Günün sözü" gibi bir etiket, cümleyi olmadığı bir
/// şeye dönüştürürdü.
///
/// ## Sunum
///
/// Bir içerik modülü değil, sessiz bir kapanış satırıdır: kart yok, çağrı
/// eylemi yok, karusel yok, emoji yok, illüstrasyon yok. Tek süs, üstündeki
/// saç teli altın çizgidir — ekranda altının nadir kaldığı yerlerden biri.
class TodayDailyReflection extends ConsumerWidget {
  const TodayDailyReflection({super.key});

  /// Dekoratif çizginin genişliği. Bilgi taşımaz; görülmese de cümle
  /// eksiksiz okunur.
  static const double _accentWidth = AppSpacing.s6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ext = AppThemeExtension.of(context);
    // Cihazın YEREL takvim günü — UTC sınırı kullanılmaz. Timer yoktur;
    // ekran yeniden kurulduğunda (gün devri dâhil) yeniden çözülür.
    final index = TodayReflection.indexForLocalDate(
      ref.watch(clockProvider).nowLocal(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s5,
        vertical: AppSpacing.s6,
      ),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: ext.accentGold,
              borderRadius: AppRadius.pillAll,
            ),
            child: const SizedBox(width: _accentWidth, height: 1),
          ),
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.reflectionAt(index),
            token: AppTextStyleToken.bodySmall,
            tone: AppTextTone.tertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

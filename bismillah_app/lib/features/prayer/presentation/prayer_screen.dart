import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_state.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/widgets/prayer_entry_tile.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_controller.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_state.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_controller.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_times_state.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/today/presentation/today_date_format.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Namaz sekmesi — namaz kaydı (TASK 016) + hesaplanmış vakitler (TASK 021).
///
/// Vakit hesabı KAYITTAN BAĞIMSIZDIR: konum reddedilse bile işaretleme/geri
/// alma çalışır (satırlar saat olmadan render edilir). Görsel dil sakindir.
///
/// ## RDX-03A kompozisyonu
///
/// Ekran üç kademeye ayrılır ve okuma sırası bu kademeleri izler:
///
/// 1. **Sıradaki namaz** — ekranın en güçlü bilgi bloğu. "Şimdi ne var?"
///    sorusu ilk bakışta cevaplanır.
/// 2. **Bugünün beş vakti** — TEK yüzey, saç teli ayraçlı satırlar.
/// 3. **İkincil girişler** — Kıble, hesaplama yöntemi, geçmiş, hatırlatıcı.
///    Erişilebilir kalır ama sıradaki namaz bilgisiyle YARIŞMAZ.
///
/// Marka başlığı burada YOKTUR: o, Günüm sekmesine özgüdür. Namaz ekranı
/// odaklı bir özellik ekranıdır ve kimliğini yerelleştirilmiş ekran adından
/// (`tabPrayer`) alır.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncState = ref.watch(prayerLogControllerProvider);

    return AppScaffold(
      title: l10n.tabPrayer,
      body: switch (asyncState) {
        AsyncData(:final value) => _PrayerLogView(state: value),
        AsyncError() => AppErrorState(
          message: l10n.prayerLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(prayerLogControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// UTC instant → yerel cihaz saatinde "HH:mm" (sabit UTC+3 EKLENMEZ;
/// `.toLocal()` cihaz timezone'unu kullanır — dakika hassasiyeti korunur).
String _formatLocal(DateTime utc) {
  final local = utc.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Vakit adının yerelleştirilmiş etiketi (satır + bildirim metni ortak).
String _prayerLabel(AppLocalizations l10n, PrayerName name) => switch (name) {
  PrayerName.fajr => l10n.prayerNameFajr,
  PrayerName.dhuhr => l10n.prayerNameDhuhr,
  PrayerName.asr => l10n.prayerNameAsr,
  PrayerName.maghrib => l10n.prayerNameMaghrib,
  PrayerName.isha => l10n.prayerNameIsha,
};

/// Bildirim metinlerini localization'dan scheduler'a taşır (BuildContext'siz
/// katmanlar için).
PrayerReminderCopy _reminderCopy(AppLocalizations l10n) => PrayerReminderCopy(
  title: l10n.reminderNotificationTitle,
  bodyFor: (name) => l10n.reminderNotificationBody(_prayerLabel(l10n, name)),
);

final class _PrayerLogView extends ConsumerWidget {
  const _PrayerLogView({required this.state});

  final PrayerLogState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timesAsync = ref.watch(prayerTimesControllerProvider);
    final timesState = timesAsync.value;
    // Vakitler yalnız BURADA bir kez izlenir ve aşağıya geçirilir; alt
    // bloklar kendi başlarına aynı provider'ı izlemez.
    final DailyPrayerTimes? times = timesState is PrayerTimesReady
        ? timesState.times
        : null;

    // RDX-03B: "şimdi" TEK BİR KEZ okunur ve hem hero'ya hem listeye aynı an
    // geçirilir. İki ayrı okuma, bir vakit sınırının iki yanına düşerek
    // hero'nun bir vakti, listenin başka bir vakti işaret etmesine yol
    // açabilirdi. Timer YOKTUR — an yalnız build sırasında okunur.
    final nowUtc = ref.read(clockProvider).nowUtc();
    final next = times?.nextPrayerAfter(nowUtc);

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        _NextPrayerBlock(timesAsync: timesAsync, nowUtc: nowUtc),
        const SizedBox(height: AppSpacing.s4),
        _DailyPrayersCard(state: state, times: times, nextPrayer: next?.name),
        const SizedBox(height: AppSpacing.s4),
        const _QiblaEntryCard(),
        const SizedBox(height: AppSpacing.s3),
        _CalculationMethodEntryCard(times: times),
        const SizedBox(height: AppSpacing.s3),
        _SecondaryEntryCard(
          icon: Icons.history_outlined,
          title: l10n.prayerHistoryTitle,
          onTap: () => context.go(AppRoutes.prayerHistory),
        ),
        const SizedBox(height: AppSpacing.s3),
        const _PrayerReminderCard(),
        // RDX-03B: "Kayıtlar cihazında güvenle saklanır." alt notu
        // KALDIRILDI. Bilgi kaybolmadı — Profil > Gizlilik ve Veri ekranı
        // "Cihazında saklananlar" başlığı altında "Namaz takip geçmişi"ni
        // zaten listeler, orası bu bilginin doğru yeridir. Ekran, kendi
        // kontrolleri bittiğinde temizce biter; yerine başka bir alıntı veya
        // günün cümlesi KONULMAZ (o desen Today'e aittir).
        const SizedBox(height: AppSpacing.s7),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1) Sıradaki namaz
// ---------------------------------------------------------------------------

/// Ekranın en güçlü bilgi bloğu (RDX-03A).
///
/// YENİ HESAP YOKTUR: sıradaki vakit, TASK 021 vakit motorunun zaten sunduğu
/// [DailyPrayerTimes.nextPrayerAfter] ile seçilir — Güneş namaz değildir ve
/// seçilmez. Canlı geri sayım / timer YOKTUR: an, `clockProvider` üzerinden
/// bir kez okunur, böylece sahte bir sayaç ekranda dönmez.
///
/// Konum izni ve "uygun değil" durumlarının metni ve eylemleri AYNEN
/// korunur — bunlar gerçek işlevi etkileyen açıklamalardır ve sadeleştirme
/// adına kaldırılmaz.
final class _NextPrayerBlock extends ConsumerWidget {
  const _NextPrayerBlock({required this.timesAsync, required this.nowUtc});

  final AsyncValue<PrayerTimesState> timesAsync;

  /// Ekranın tamamı için TEK an — çağıran okur ve geçirir, böylece hero ile
  /// liste aynı "sıradaki vakit" üzerinde anlaşır.
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(prayerTimesControllerProvider.notifier);
    final state = timesAsync.value;

    if (timesAsync.isLoading && state == null) {
      // ListView içinde sınırsız yükseklik istememek için kompakt gösterge
      // (`AppLoading` burada `Center` ile sonsuz yükseklik ister).
      return const _NextPrayerShell(
        eyebrowKey: null,
        showAccent: false,
        child: SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return switch (state) {
      PrayerTimesReady(:final times, :final approximateLocation) => _ready(
        context,
        l10n,
        times,
        approximateLocation: approximateLocation,
      ),
      PrayerTimesNeedsPermission(:final permanentlyDenied) => _message(
        l10n,
        message: permanentlyDenied
            ? l10n.prayerTimesLocationDeniedForever
            : l10n.prayerTimesLocationInvite,
        actionLabel: permanentlyDenied
            ? l10n.prayerTimesOpenSettings
            : l10n.prayerTimesUseLocation,
        onAction: permanentlyDenied
            ? controller.openSettings
            : controller.useLocation,
      ),
      PrayerTimesUnavailable() => _message(
        l10n,
        message: l10n.prayerTimesUnavailable,
        actionLabel: l10n.commonRetry,
        onAction: controller.useLocation,
      ),
      null => const SizedBox.shrink(),
    };
  }

  Widget _ready(
    BuildContext context,
    AppLocalizations l10n,
    DailyPrayerTimes times, {
    required bool approximateLocation,
  }) {
    final next = times.nextPrayerAfter(nowUtc);
    final tertiary = AppThemeExtension.of(context).textTertiary;

    return _NextPrayerShell(
      eyebrowKey: l10n.todayNextPrayerTitle,
      // Altın nokta yalnız GERÇEK bir sıradaki vakit varken yanar.
      showAccent: next != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (next == null)
            // Beş vakit de geçti — sakin bitiş cümlesi. Yarının programı
            // BURADA hesaplanmaz.
            AppText(
              l10n.todayNextPrayerAllDone,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppText(
                    _prayerLabel(l10n, next.name),
                    token: AppTextStyleToken.h3,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                // Ekrandaki TEK `stat` — saat, blokun çapasıdır. Beş vakit
                // listesi bilinçli olarak bir kademe altta (`h3`) kalır.
                AppText(
                  _formatLocal(next.instant),
                  token: AppTextStyleToken.stat,
                  maxLines: 1,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.s2),
          // Bağlam satırı yalnız GERÇEK mevcut veriden kurulur: Güneş vakti
          // ve konum kesinliği. "Güneş" ayrı bir metindir (etiket ile saat
          // birleştirilmez), böylece çeviri ve okuma sırası korunur.
          Row(
            children: [
              Icon(
                Icons.wb_twilight_outlined,
                size: AppSizes.iconSm,
                color: tertiary,
              ),
              const SizedBox(width: AppSpacing.s2),
              // `Flexible`: 320dp genişlikte 1.5x metin ölçeğinde uzun
              // etiket ("Sunrise" / "الشروق") satırı taşırmak yerine
              // kırpılır — saat her zaman okunur kalır.
              Flexible(
                child: AppText(
                  l10n.prayerTimesSunrise,
                  token: AppTextStyleToken.caption,
                  tone: AppTextTone.tertiary,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              AppText(
                _formatLocal(times.sunrise),
                token: AppTextStyleToken.caption,
                tone: AppTextTone.tertiary,
                maxLines: 1,
              ),
            ],
          ),
          if (approximateLocation) ...[
            const SizedBox(height: AppSpacing.s1),
            AppText(
              l10n.prayerTimesApproximate,
              token: AppTextStyleToken.caption,
              tone: AppTextTone.tertiary,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  /// Sakin durum metni + mevcut eylem (izin / uygun değil). Metin ve eylem
  /// TASK 021'deki hâliyle korunur; yalnız yüzey dili güncellenir.
  Widget _message(
    AppLocalizations l10n, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return _NextPrayerShell(
      eyebrowKey: l10n.todayNextPrayerTitle,
      showAccent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(message, token: AppTextStyleToken.bodySmall, secondary: true),
          const SizedBox(height: AppSpacing.s3),
          AppButton(
            label: actionLabel,
            variant: AppButtonVariant.secondary,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

/// Sıradaki-namaz blokunun ortak kabuğu: sıcak kum yüzeyi + küçük "eyebrow".
///
/// Dev bir yeşil dikdörtgen, gradient hero veya dekoratif cami zemini
/// KULLANILMAZ — blok kompakt bir bilgi kartıdır.
final class _NextPrayerShell extends StatelessWidget {
  const _NextPrayerShell({
    required this.eyebrowKey,
    required this.showAccent,
    required this.child,
  });

  /// Blok başlığı ("Sıradaki namaz"). Yükleme durumunda `null` — henüz
  /// hiçbir şey iddia edilmez.
  final String? eyebrowKey;

  /// Küçük altın nokta gösterilsin mi? Yalnız gerçek bir "şu an sıradaki"
  /// bilgisi varken yanar.
  final bool showAccent;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.sand,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s4,
        AppSpacing.s5,
        AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrowKey case final title?) ...[
            Row(
              children: [
                if (showAccent) ...[
                  const _NowDot(),
                  const SizedBox(width: AppSpacing.s2),
                ],
                Expanded(
                  child: AppText(
                    title,
                    token: AppTextStyleToken.caption,
                    tone: AppTextTone.secondary,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
          ],
          child,
        ],
      ),
    );
  }
}

/// Eyebrow'un başındaki küçük altın nokta.
///
/// Altının Namaz ekranında göründüğü TEK yerdir. Buton, kenarlık, kart zemini
/// veya metin rengi olarak altın KULLANILMAZ. Tamamen dekoratiftir — taşıdığı
/// hiçbir bilgi yoktur, metin tek başına da eksiksiz okunur.
final class _NowDot extends StatelessWidget {
  const _NowDot();

  static const double _size = 6;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppThemeExtension.of(context).accentGold,
        borderRadius: AppRadius.pillAll,
      ),
      child: const SizedBox(width: _size, height: _size),
    );
  }
}

// ---------------------------------------------------------------------------
// 2) Bugünün beş vakti
// ---------------------------------------------------------------------------

/// Beş vakit TEK yüzeyde (RDX-03A).
///
/// Önceden her vakit ayrı bir `AppCard` idi; ekran birbiriyle ilişkisiz beş
/// beyaz kutuya bölünüyordu. Artık tek kart, saç teli ayraçlarla bölünmüş
/// satırlar taşır. Hangi vakitlerin takip edildiği ve durum makinesi
/// DEĞİŞMEDİ — `PrayerName.values` sırası ve `controller.toggle` aynıdır.
final class _DailyPrayersCard extends ConsumerWidget {
  const _DailyPrayersCard({
    required this.state,
    required this.times,
    required this.nextPrayer,
  });

  final PrayerLogState state;
  final DailyPrayerTimes? times;

  /// Gerçekten sıradaki vakit — çağıran tek bir andan hesaplar. Beş vakit de
  /// geçtiyse (veya vakit yoksa) `null`'dır ve HİÇBİR satır işaretlenmez;
  /// uydurma bir "sıradaki" seçilmez.
  final PrayerName? nextPrayer;

  /// Satır metninin kart kenarından uzaklığı. Satırlar kendi tonal zeminleri
  /// için yatay dolgu taşıdığından, başlık bloğu da aynı değeri kullanır;
  /// böylece başlık ile vakit adları TEK hizada başlar ve ayraçlar ikisinin
  /// de biraz dışına taşarak klasik "inset divider" görünümü verir.
  static const double _rowInset = AppSpacing.s2;

  static DateTime? _timeFor(DailyPrayerTimes? t, PrayerName name) {
    if (t == null) {
      return null;
    }
    return t.instantFor(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    final controller = ref.read(prayerLogControllerProvider.notifier);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rowInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RDX-03B: kartın ayrı bir "Bugünün namaz takibi" başlığı
                // KALDIRILDI. AppBar zaten "Namaz" diyor ve kartın içinde beş
                // vakit adı ile saatleri duruyor; üçüncü bir başlık satırı,
                // tarih ve destek cümlesiyle birlikte üst üste ÜÇ başlık
                // benzeri satır üretiyordu. Anahtar silinmedi — Today kendi
                // özet kartında kullanmaya devam ediyor.
                //
                // Kalan iki satır rol olarak AYRIDIR: tarih hangi günün
                // takip edildiğini söyler, destek cümlesi tonu taşır.
                //
                // Tarih platformun kendi yerelleştirmesiyle biçimlenir; ham
                // `2026-07-11` gösterilmez ve ay adları elle YAZILMAZ.
                AppText(
                  formatDayKeyForDisplay(context, state.dayKey),
                  token: AppTextStyleToken.caption,
                  tone: AppTextTone.tertiary,
                  maxLines: 1,
                ),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  l10n.prayerGentleLine,
                  token: AppTextStyleToken.bodySmall,
                  tone: AppTextTone.secondary,
                  maxLines: 2,
                ),
                if (state.saveIssue) ...[
                  const SizedBox(height: AppSpacing.s3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppSizes.iconSm,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: AppText(
                          l10n.prayerSaveIssue,
                          token: AppTextStyleToken.caption,
                          secondary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          for (final (index, name) in PrayerName.values.indexed) ...[
            if (index > 0)
              // Saç teli ayraç — satırların tonal zemininin biraz dışına
              // taşar, kartın kenarına dayanmaz.
              Divider(height: 1, thickness: 1, color: ext.divider),
            PrayerEntryTile(
              label: _prayerLabel(l10n, name),
              time: switch (_timeFor(times, name)) {
                final t? => _formatLocal(t),
                _ => null,
              },
              completed: state.isCompleted(name),
              completedLabel: l10n.prayerCompleted,
              actionLabel: state.isCompleted(name)
                  ? l10n.prayerUndo
                  : l10n.prayerMark,
              // RDX-03B: yalnız GERÇEKTEN sıradaki vakit işaretlenir. Beş
              // vakit de geçtiyse `nextPrayer` null olur ve hiçbir satır
              // ipucu almaz — uydurma bir "sıradaki" üretilmez.
              isNext: nextPrayer == name,
              nextLabel: l10n.todayNextPrayerTitle,
              onToggle: () => controller.toggle(name),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3) İkincil girişler
// ---------------------------------------------------------------------------

/// Kompakt ikincil giriş satırı (RDX-03A).
///
/// Kıble, hesaplama yöntemi ve geçmiş aynı sakin dili paylaşır: gölgesiz,
/// ince kenarlıklı yüzey + küçük ikon + yön duyarlı chevron. Sıradaki namaz
/// bloğunun sıcak kum yüzeyiyle YARIŞMAZ. Ücretsizdir — kilit, rozet veya
/// yükseltme çağrısı YOKTUR.
final class _SecondaryEntryCard extends StatelessWidget {
  const _SecondaryEntryCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);
    // `Icons.chevron_right` kendiliğinden aynalanmaz; yön AÇIKÇA çözülür.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AppCard(
      variant: AppCardVariant.outlined,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMd, color: scheme.primary),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, token: AppTextStyleToken.h3, maxLines: 2),
                  if (subtitle case final s?) ...[
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      s,
                      token: AppTextStyleToken.caption,
                      tone: AppTextTone.secondary,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Icon(
              isRtl ? Icons.chevron_left : Icons.chevron_right,
              size: AppSizes.iconSm,
              color: ext.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kıble yönü girişi (TASK 095). Ücretsizdir — kilit, rozet veya yükseltme
/// çağrısı YOKTUR; rota ve davranış değişmedi.
final class _QiblaEntryCard extends StatelessWidget {
  const _QiblaEntryCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SecondaryEntryCard(
      icon: Icons.explore_outlined,
      title: l10n.qiblaEntryTitle,
      subtitle: l10n.qiblaEntrySubtitle,
      onTap: () => context.go(AppRoutes.qibla),
    );
  }
}

/// Hesaplama yöntemi girişi (TASK 096).
///
/// **TASK 096 dürüstlük kuralı korunur:** yöntem adı, vakitleri GERÇEKTEN
/// üreten sonuçtan (`times.method`) okunur — ayrı bir ayar kaynağından
/// değil; bu yüzden ekrandaki etiket ile hesap ayrışamaz. Önceden bu bilgi
/// ekranda İKİ yerde (vakit kartı + bu satır) duruyordu ve ikisi farklı
/// kaynaktan besleniyordu; RDX-03A ikisini TEK satırda birleştirir ve
/// sonucu tercih eder. Vakit henüz yoksa (konum reddi vb.) çelişecek bir
/// sonuç da yoktur, o durumda saklanmış seçim gösterilir.
final class _CalculationMethodEntryCard extends ConsumerWidget {
  const _CalculationMethodEntryCard({required this.times});

  final DailyPrayerTimes? times;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(prayerCalculationMethodProvider);
    final shown = times?.method ?? selected;

    return _SecondaryEntryCard(
      icon: Icons.tune_outlined,
      title: l10n.prayerMethodEntryTitle,
      subtitle: l10n.prayerMethodName(shown.stableName),
      onTap: () => context.go(AppRoutes.prayerCalculationMethod),
    );
  }
}

/// Namaz hatırlatıcıları kartı — sakin aç/kapat. Namaz kaydından bağımsız;
/// izin reddedilse bile işaretleme çalışır (kart yalnız hatırlatıcıyı yönetir).
///
/// RDX-03A: izin akışları, kesin-alarm diyaloğu ve metinler AYNEN korunur —
/// yalnız kart yüzeyi ekranın geri kalanıyla aynı sakin dile alınır.
final class _PrayerReminderCard extends ConsumerWidget {
  const _PrayerReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(prayerReminderControllerProvider.notifier);
    final async = ref.watch(prayerReminderControllerProvider);
    final state = async.value;

    Widget card(Widget child) => AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: AppSizes.iconMd,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: AppText(
                  l10n.reminderCardTitle,
                  token: AppTextStyleToken.h3,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          child,
        ],
      ),
    );

    Widget action(String label, VoidCallback onTap) => AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      onPressed: onTap,
    );

    if (async.isLoading && state == null) {
      // Sınırlı boyutlu gösterge — ListView içinde `Center` sınırsız yükseklik
      // isteyeceği için AppLoading burada KULLANILMAZ.
      return card(
        const SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return switch (state) {
      ReminderEnabled(:final exact) => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderEnabledState,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            if (!exact) ...[
              const SizedBox(height: AppSpacing.s1),
              AppText(
                l10n.reminderInexactNote,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              // Kullanıcının AÇIK isteğiyle: kesin-alarm özel-erişim ekranına
              // götürür (açılışta/otomatik gösterilmez).
              action(
                l10n.reminderExactAction,
                () => _promptExactTiming(context, ref, l10n),
              ),
            ],
            const SizedBox(height: AppSpacing.s3),
            action(l10n.reminderDisable, controller.disable),
          ],
        ),
      ),
      ReminderPermissionBlocked(:final permanentlyDenied) => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderPermissionNeeded,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            action(
              permanentlyDenied
                  ? l10n.prayerTimesOpenSettings
                  : l10n.reminderEnable,
              permanentlyDenied
                  ? controller.openSettings
                  : () => _onEnablePressed(context, ref, l10n),
            ),
          ],
        ),
      ),
      ReminderLocationNeeded() => card(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.reminderLocationNeeded,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            action(
              l10n.reminderEnable,
              () => _onEnablePressed(context, ref, l10n),
            ),
          ],
        ),
      ),
      _ => card(
        action(l10n.reminderEnable, () => _onEnablePressed(context, ref, l10n)),
      ),
    };
  }

  /// "Hatırlatıcıları aç" dokunuşu: etkinleştirir; sonuç açık ama INEXACT ise
  /// (kesin-alarm erişimi yok) kullanıcıya kesin-zamanlama açıklamasını gösterir.
  /// Açıklama YALNIZ bu açık kullanıcı eyleminden sonra çıkar (açılışta değil).
  Future<void> _onEnablePressed(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    await ref
        .read(prayerReminderControllerProvider.notifier)
        .enable(_reminderCopy(l10n));
    if (!context.mounted) {
      return;
    }
    final state = ref.read(prayerReminderControllerProvider).value;
    if (state is ReminderEnabled && !state.exact) {
      await _promptExactTiming(context, ref, l10n);
    }
  }

  /// Kesin-zamanlama açıklaması + "İzin ekranını aç" / "Şimdi değil". Onaylanırsa
  /// özel-erişim ekranı açılır, dönüşte yeniden kontrol edilir; sonuç dürüstçe
  /// snackbar ile bildirilir. Ayar ekranını açmak başarı SAYILMAZ.
  Future<void> _promptExactTiming(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final open = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reminderExactTitle),
        content: Text(l10n.reminderExactBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.reminderExactNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.reminderExactOpenSettings),
          ),
        ],
      ),
    );
    if (open != true) {
      return; // "Şimdi değil" → ekran açılmaz, inexact fallback korunur.
    }
    final granted = await ref
        .read(prayerReminderControllerProvider.notifier)
        .requestExactTiming(_reminderCopy(l10n));
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            granted ? l10n.reminderExactGranted : l10n.reminderExactNotGranted,
          ),
        ),
      );
  }
}

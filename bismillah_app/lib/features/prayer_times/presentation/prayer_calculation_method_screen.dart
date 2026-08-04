import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_times/application/prayer_calculation_method_controller.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Namaz vakti hesaplama yöntemi seçimi (TASK 096).
///
/// Listelenen her seçenek, hesaplama motorunun gerçek bir hazır ayarına
/// karşılık gelir ve açıklaması motordan OKUNAN parametrelerden üretilir —
/// ekranda uydurulmuş açı/dakika değeri yoktur. Değişiklik ONAY olmadan
/// uygulanmaz; vazgeçmek hiçbir şeye dokunmaz.
class PrayerCalculationMethodScreen extends ConsumerStatefulWidget {
  const PrayerCalculationMethodScreen({super.key});

  @override
  ConsumerState<PrayerCalculationMethodScreen> createState() =>
      _PrayerCalculationMethodScreenState();
}

class _PrayerCalculationMethodScreenState
    extends ConsumerState<PrayerCalculationMethodScreen> {
  /// Uygulama sürerken liste kilitlenir — ikinci dokunuş ikinci bir işlem
  /// başlatamaz (controller ayrıca kendi içinde de korur).
  bool _applying = false;

  /// Kısmi başarıdan sonra gösterilen deterministik yeniden deneme yolu.
  bool _remindersNeedRetry = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = ref.watch(prayerCalculationMethodCatalogProvider);
    final selected = ref.watch(prayerCalculationMethodProvider);

    return AppScaffold(
      title: l10n.prayerMethodTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.prayerMethodIntro,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          if (_applying) ...[
            // Canlı bölge: ekran okuyucu işlemin sürdüğünü duyurur.
            Semantics(
              liveRegion: true,
              child: AppText(
                l10n.prayerMethodApplying,
                token: AppTextStyleToken.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          if (_remindersNeedRetry) ...[
            _NoteBox(text: l10n.prayerMethodRemindersNotUpdated),
            const SizedBox(height: AppSpacing.s3),
            AppButton(
              label: l10n.prayerMethodRetryReminders,
              variant: AppButtonVariant.secondary,
              onPressed: _applying ? null : () => _retryReminders(l10n),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          for (final method in catalog.supportedMethods) ...[
            _MethodOption(
              name: l10n.prayerMethodName(method.stableName),
              detail: _detailFor(l10n, catalog.parametersFor(method)),
              isSelected: method == selected,
              selectedLabel: l10n.prayerMethodCurrentLabel,
              onSelected: _applying
                  ? null
                  : () => _confirmAndApply(l10n, method),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          const SizedBox(height: AppSpacing.s2),
          _NoteBox(text: l10n.prayerMethodNotEndorsement),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }

  /// Açıklama motordan gelen parametrelerden kurulur; sabit metin YOKTUR.
  String _detailFor(
    AppLocalizations l10n,
    PrayerCalculationMethodParameters params,
  ) {
    final base = params.usesIshaInterval
        ? l10n.prayerMethodInterval(
            _angle(params.fajrAngle),
            params.ishaIntervalMinutes,
          )
        : l10n.prayerMethodAngles(
            _angle(params.fajrAngle),
            _angle(params.ishaAngle),
          );
    if (!params.hasMethodMinuteAdjustments) {
      return base;
    }
    return '$base · ${l10n.prayerMethodAdjustmentsNote}';
  }

  /// 18.0 → "18", 18.2 → "18.2" (gereksiz sıfır gösterilmez).
  static String _angle(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  Future<void> _confirmAndApply(
    AppLocalizations l10n,
    PrayerTimeCalculationMethod method,
  ) async {
    final name = l10n.prayerMethodName(method.stableName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.prayerMethodConfirmTitle),
        // Uzun metin + büyük yazı tipinde diyalog taşmasın diye kaydırılabilir.
        content: SingleChildScrollView(
          child: Text(l10n.prayerMethodConfirmBody(name)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.prayerMethodConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.prayerMethodConfirmApply),
          ),
        ],
      ),
    );
    // Vazgeçmek HİÇBİR ŞEYE dokunmaz: yöntem, vakitler ve bildirimler aynı.
    if (confirmed != true || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _applying = true;
      _remindersNeedRetry = false;
    });
    final outcome = await ref
        .read(prayerCalculationMethodProvider.notifier)
        .select(method, _reminderCopy(l10n));
    if (!mounted) {
      return;
    }
    setState(() {
      _applying = false;
      _remindersNeedRetry = outcome is PrayerMethodRemindersNotUpdated;
    });
    _report(messenger, l10n, outcome, name);
  }

  Future<void> _retryReminders(AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = l10n.prayerMethodName(
      ref.read(prayerCalculationMethodProvider).stableName,
    );
    setState(() => _applying = true);
    final outcome = await ref
        .read(prayerCalculationMethodProvider.notifier)
        .retryReminderReschedule(_reminderCopy(l10n));
    if (!mounted) {
      return;
    }
    setState(() {
      _applying = false;
      _remindersNeedRetry = outcome is PrayerMethodRemindersNotUpdated;
    });
    _report(messenger, l10n, outcome, name);
  }

  /// Sonuç DÜRÜSTÇE bildirilir: başarısız bir yeniden zamanlama asla tam
  /// başarı mesajı almaz, başarısız bir yazma hiç mesajı almaz değil —
  /// ayrı ve belirgin bir mesaj alır.
  void _report(
    ScaffoldMessengerState messenger,
    AppLocalizations l10n,
    PrayerMethodChangeOutcome outcome,
    String name,
  ) {
    final message = switch (outcome) {
      PrayerMethodApplied() => l10n.prayerMethodChanged(name),
      PrayerMethodRemindersNotUpdated() => l10n.prayerMethodRemindersNotUpdated,
      PrayerMethodSaveFailed() => l10n.prayerMethodSaveFailed,
      // Zaten seçili yöntem ya da süren işlem: yeni bir şey olmadı, sessiz
      // kalınır (uydurma onay mesajı gösterilmez).
      PrayerMethodUnchanged() || PrayerMethodBusy() => null,
    };
    if (message == null) {
      return;
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  PrayerReminderCopy _reminderCopy(AppLocalizations l10n) => PrayerReminderCopy(
    title: l10n.reminderNotificationTitle,
    bodyFor: (name) => l10n.reminderNotificationBody(_prayerLabel(l10n, name)),
  );
}

String _prayerLabel(AppLocalizations l10n, PrayerName name) => switch (name) {
  PrayerName.fajr => l10n.prayerNameFajr,
  PrayerName.dhuhr => l10n.prayerNameDhuhr,
  PrayerName.asr => l10n.prayerNameAsr,
  PrayerName.maghrib => l10n.prayerNameMaghrib,
  PrayerName.isha => l10n.prayerNameIsha,
};

/// Tek seçenek satırı — dil seçimi ekranıyla AYNI sakin kart dilini kullanır;
/// yeni bir görsel bileşen ailesi eklenmez.
class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.name,
    required this.detail,
    required this.isSelected,
    required this.selectedLabel,
    required this.onSelected,
  });

  final String name;
  final String detail;
  final bool isSelected;
  final String selectedLabel;

  /// `null` ise uygulama sürüyordur — satır dokunulamaz.
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);

    return Semantics(
      button: true,
      enabled: onSelected != null,
      selected: isSelected,
      // Ekran okuyucu tek anlamlı düğüm duyar: yöntem adı + parametreleri.
      label: '$name. $detail',
      child: AppCard(
        completed: isSelected,
        onTap: onSelected,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            // Minimum dokunma alanı (44dp) dar ekranlarda da korunur.
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(name, token: AppTextStyleToken.h3),
                      const SizedBox(height: AppSpacing.s1),
                      AppText(
                        detail,
                        token: AppTextStyleToken.caption,
                        secondary: true,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: AppSpacing.s1),
                        AppText(
                          selectedLabel,
                          token: AppTextStyleToken.caption,
                          secondary: true,
                        ),
                      ],
                    ],
                  ),
                ),
                // Seçim işareti mevcut hareket rolüyle yumuşak geçer;
                // reduced-motion açıkken süre sıfırlanır ve dinlenme
                // hâlinde HİÇBİR animasyon çalışmaz.
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: AppMotion.of(context, AppMotion.selection),
                  curve: AppMotion.selectionCurve,
                  child: Icon(
                    Icons.check_rounded,
                    color: tokens.spiritualGreenStrong,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sakin bilgi kutusu — dil ekranındaki notla aynı yüzey dili.
class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sacredSurfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: AppText(text, token: AppTextStyleToken.caption, secondary: true),
      ),
    );
  }
}

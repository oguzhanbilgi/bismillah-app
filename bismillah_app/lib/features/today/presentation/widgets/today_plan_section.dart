import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/application/today_day_controller.dart';
import 'package:bismillah_app/features/today/application/today_plan_lesson_titles_provider.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:bismillah_app/features/today/presentation/today_date_format.dart';
import 'package:bismillah_app/features/today/presentation/today_plan_item_presentation.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_plan_task_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_recovery_note.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today günlük görev bölümü (TASK 083).
///
/// Mevcut [DailyPlanController] durum makinesini tüketen **tek** yüzeydir:
/// yükleme, plan yok, plan var, bozuk veri ve geçici hata hâllerini sakin
/// bir dille gösterir.
///
/// Gün seçimi ve yerel takvim devri `TodayDayController`'a aittir
/// (TASK 084); bu widget yalnız yaşam döngüsü olayını iletir ve durumu
/// çizer.
///
/// ## Sınırlar
///
/// Plan **ÜRETMEZ** ve otomatik kaydetmez; geçmiş günleri değiştirmez.
/// Elle gün gezinme (takvim seçici) EKLENMEZ — gösterilen gün daima yerel
/// takvim günüdür. Firebase yazımı, uzak senkron, bildirim, seri/puan,
/// ücretli özellik kapısı, reklam veya bağış mesajı YOKTUR.
///
/// ## Ton
///
/// Boş gün bir eksiklik değildir; tamamlanmamış görev kırmızıyla
/// işaretlenmez; seri (streak), puan, rütbe ve manevi değerlendirme YOKTUR.
class TodayPlanSection extends ConsumerStatefulWidget {
  const TodayPlanSection({super.key});

  @override
  ConsumerState<TodayPlanSection> createState() => _TodayPlanSectionState();
}

/// Yükleme iskeletindeki yer tutucu satır sayısı — tipik bir çekirdek
/// günün görev sayısına yakındır, böylece geçişte yükseklik oynamaz.
const int _skeletonRowCount = 3;

/// Görev satırları arasındaki saç teli ayraç (RDX-01C1). Renk temadan
/// gelir; koyu temada da doğru tonda çizilir.
///
/// RDX-01C3: ayraç artık satırın ikon karesi kadar içeriden başlar —
/// referanstaki liste ritmi budur ve çizgi kartı baştan sona kesip satırları
/// "ayar listesi" gibi göstermez. `Divider` girintiyi `EdgeInsetsDirectional`
/// ile uygular, bu yüzden Arapça'da kendiliğinden aynalanır.
class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: TodayPlanTaskCard.rowContentIndent,
      color: AppThemeExtension.of(context).divider,
    );
  }
}

/// Animasyonsuz, nötr yer tutucu çubuk.
class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final ext = AppThemeExtension.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ext.surfaceAlt,
            borderRadius: AppRadius.smAll,
          ),
          child: const SizedBox(height: AppSizes.touchTarget),
        ),
      ),
    );
  }
}

class _TodayPlanSectionState extends ConsumerState<TodayPlanSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Uygulama ön plana döndüğünde yerel gün değişmiş olabilir (TASK 084).
    WidgetsBinding.instance.addObserver(this);
    // Gün seçimi ilk frame'den SONRA yapılır: build sırasında provider
    // durumu değiştirilmez.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_startIfMounted()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Gün değişmediyse controller hiçbir şey yapmaz — yeniden okuma,
      // yeni abonelik veya yeni üretim tetiklenmez.
      unawaited(ref.read(todayDayControllerProvider.notifier).onAppResumed());
    }
  }

  Future<void> _startIfMounted() async {
    if (!mounted) {
      return;
    }
    await ref.read(todayDayControllerProvider.notifier).start();
  }

  /// Kullanıcı isteğiyle yeniden deneme (nötr hata yolundan).
  Future<void> _retry() async {
    if (!mounted) {
      return;
    }
    await ref.read(todayDayControllerProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dailyPlanControllerProvider);
    final recovery = ref.watch(
      todayDayControllerProvider.select((day) => day.recovery),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sakin dönüş notu planın ÜSTÜNDE durur; hiçbir görevi gizlemez
        // ve sırayı değiştirmez.
        if (TodayRecoveryNote.shouldShow(recovery, state))
          TodayRecoveryNote(recovery: recovery),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s3),
          child: AppCard(
            // RDX-01C3: satırlar kendi dikey dolgularını taşıdığı için kartın
            // alt/üst dolgusu `s5`ten `s4`e iner; kart ferahlığını kaybetmeden
            // bir görev satırı kadar kısalır.
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s5,
              vertical: AppSpacing.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RDX-01C2: başlık solda, tarih hemen altında sönük satır
                // olarak. Referansta bölüm başlığı tek satırlık ve
                // kompakttır; başlık ile içerik arasındaki boşluk s4'ten
                // s3'e iner.
                //
                // RDX-01C3: ilerleme sayacı başlığın SAĞINA taşındı. Önceden
                // kendi satırını kaplıyordu; başlıkla eşleşince kart bir satır
                // kısalır ve namaz özet kartıyla aynı düzeni okur.
                //
                // `Row` DEĞİL `Wrap`: iki metnin de doğal genişliği vardır ve
                // dar ekran + büyük yazı bileşiminde (320px @1.5x) tek satıra
                // sığmazlar. `Row`da bu ya taşma ya da başlığın erkenden
                // kırpılması demekti; `Wrap` sığdığında sayacı sağ kenara
                // yaslar, sığmadığında sakince alt satıra indirir.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.s3,
                  runSpacing: AppSpacing.s1,
                  children: [
                    AppText(
                      l10n.todayPlanTitle,
                      token: AppTextStyleToken.h3,
                      maxLines: 1,
                    ),
                    if (_progressLabel(l10n, state) case final String label)
                      AppText(
                        label,
                        token: AppTextStyleToken.caption,
                        tone: AppTextTone.secondary,
                        maxLines: 1,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s1),
                _dateLine(context, l10n, state),
                const SizedBox(height: AppSpacing.s3),
                switch (state) {
                  null || DailyPlanLoading() => _loading(l10n),
                  DailyPlanEmpty() => _empty(l10n),
                  DailyPlanAvailable(:final plan, :final isSaving) =>
                    _available(l10n, plan, isSaving: isSaving),
                  DailyPlanCorrupt() => _corrupt(l10n),
                  DailyPlanFailure() => _failure(l10n),
                },
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Başlık satırının sağındaki sayaç. Yalnız gerçekten bir plan varken
  /// üretilir — yükleme, boş, bozuk ve hata durumlarında `null` döner, çünkü
  /// o hâllerde gösterilecek bir oran YOKTUR ve "0/0" uydurulmaz.
  String? _progressLabel(AppLocalizations l10n, DailyPlanState? state) {
    if (state is! DailyPlanAvailable) {
      return null;
    }
    final plan = state.plan;
    if (plan.items.isEmpty) {
      return null;
    }
    return l10n.todayPlanProgress(plan.completedCount, plan.items.length);
  }

  /// Seçili gün satırı; gün henüz seçilmemişken gizlenir (yanıltıcı tarih
  /// gösterilmez).
  Widget _dateLine(
    BuildContext context,
    AppLocalizations l10n,
    DailyPlanState? state,
  ) {
    if (state == null) {
      return const SizedBox.shrink();
    }
    // Ham ISO tarih (`2026-08-07`) arayüzde teknik bir kaçaktır; cihazın
    // kendi dilindeki biçim kullanılır.
    return AppText(
      l10n.todayPlanSelectedDay(formatDayKeyForDisplay(context, state.dayKey)),
      token: AppTextStyleToken.caption,
      tone: AppTextTone.tertiary,
      maxLines: 2,
    );
  }

  /// Sakin iskelet: görev kartı yüksekliğinde nötr yer tutucular.
  ///
  /// Bilinçli olarak **animasyonsuzdur** — dönen/parlayan bir gösterge
  /// dikkat çeker, ekranı huzursuzlaştırır ve `pumpAndSettle` tabanlı
  /// testleri süresiz bekletir.
  ///
  /// Görev sayısı okuma bitmeden bilinemez, bu yüzden "hiç kaymayan" bir
  /// yükseklik VAAT EDİLMEZ; iskelet gerçek bir blok kaplayarak kartın
  /// sıfıra yakın yükseklikte parlayıp sonra açılmasını engeller.
  Widget _loading(AppLocalizations l10n) => Semantics(
    label: l10n.todayPlanLoading,
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _skeletonRowCount; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s3),
            child: _SkeletonBar(
              // Hafif değişen genişlik: tek tip bloklar yerine sakin ritim.
              widthFactor: i.isEven ? 0.92 : 0.72,
            ),
          ),
      ],
    ),
  );

  /// Plan yok: nötr bilgi. Üretim orkestrasyonu bağlı olmadığı için
  /// **sahte bir "plan oluştur" düğmesi gösterilmez**.
  Widget _empty(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(l10n.todayPlanEmptyTitle),
      const SizedBox(height: AppSpacing.s2),
      AppText(
        l10n.todayPlanEmptyBody,
        token: AppTextStyleToken.caption,
        secondary: true,
      ),
    ],
  );

  Widget _available(
    AppLocalizations l10n,
    DailyPlan plan, {
    required bool isSaving,
  }) {
    final total = plan.items.length;
    final completed = plan.completedCount;
    final progress = total == 0 ? 0.0 : completed / total;

    final lessonIds = [
      for (final item in plan.items)
        if (item.type == PlanItemType.lesson && item.targetRef != null)
          item.targetRef!,
    ];
    final titlesAsync = lessonIds.isEmpty
        ? null
        : ref.watch(todayPlanLessonTitlesProvider(lessonTitlesKey(lessonIds)));
    final lessonTitles = titlesAsync?.value ?? const <String, String>{};
    final isResolvingTitles = titlesAsync?.isLoading ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RDX-01C1: ilerleme çubuğu görev listesinden ince bir boşlukla
        // ayrılır — referansta özet üstte, satırlar altta durur.
        //
        // RDX-01C3: sayaç METNİ artık başlık satırındadır; burada tekrar
        // edilmez. Erişilebilirlik kaybı YOKTUR — aynı dize çubuğun semantik
        // etiketi olarak kalır.
        AppProgressBar(
          value: progress,
          semanticLabel: l10n.todayPlanProgress(completed, total),
        ),
        const SizedBox(height: AppSpacing.s2),
        if (total == 0)
          AppText(
            l10n.todayPlanNoItems,
            token: AppTextStyleToken.caption,
            secondary: true,
          )
        else
          // Kanonik kaynak sırası (Prayer → Quran → Learn) plandaki öğe
          // sırasıdır; burada yerelleştirilmiş metne göre YENİDEN
          // SIRALANMAZ.
          //
          // RDX-01C1: görevler tek kartın içinde saç teli ayraçlarla bölünmüş
          // satırlardır — kart içinde kart yığını DEĞİL. Ayracı liste sahibi
          // çizer, böylece son satırdan sonra sarkan bir çizgi kalmaz.
          for (final (index, item) in plan.items.indexed) ...[
            if (index > 0) _RowDivider(),
            TodayPlanTaskCard(
              item: item,
              presentation: TodayPlanItemPresentation.of(
                l10n,
                item,
                learnTitle: item.targetRef == null
                    ? null
                    : lessonTitles[item.targetRef],
                isResolvingLearnTitle: isResolvingTitles,
              ),
              // Kaydetme sürerken satır salt-okunur olur — çift yazma
              // engellenir.
              onToggle: isSaving
                  ? null
                  : () => ref
                        .read(dailyPlanControllerProvider.notifier)
                        .toggleItemCompletion(item.itemId),
            ),
          ],
      ],
    );
  }

  /// Bozuk veri: sakin açıklama. Ham istisna, JSON, depolama anahtarı veya
  /// dosya yolu GÖSTERİLMEZ ve depo kendiliğinden TEMİZLENMEZ.
  Widget _corrupt(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(l10n.todayPlanCorruptTitle),
      const SizedBox(height: AppSpacing.s2),
      AppText(
        l10n.todayPlanCorruptBody,
        token: AppTextStyleToken.caption,
        secondary: true,
      ),
    ],
  );

  Widget _failure(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(l10n.todayPlanFailureBody),
      const SizedBox(height: AppSpacing.s4),
      AppButton(
        label: l10n.commonRetry,
        variant: AppButtonVariant.secondary,
        onPressed: () => unawaited(_retry()),
      ),
    ],
  );
}

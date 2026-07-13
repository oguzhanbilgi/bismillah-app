import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/quran/application/quran_chapters_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_preferences_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Kur'an sekmesi (TASK 033) — profesyonel Kur'an deneyimi temeli:
/// kurulum tamamlanmamışsa üç adımlı iç kurulum (yazı biçimi → meal →
/// günlük hedef), tamamlanmışsa Oku / Öğren / İlerlemem iç sekmeleri.
/// Gerçek sure/ayet/meal/ses içeriği YOK (TASK 034+); streak/puan/
/// paywall YOK. Kurulum genel onboarding kapısına ve route stack'e
/// DOKUNMAZ.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranPreferencesControllerProvider);

    return AppScaffold(
      title: l10n.tabQuran,
      // Kaydedilen ayetler (TASK 038): yalnız kurulum tamamlanmışsa —
      // ikon her zaman gerçek route açar, işlevsiz ikon yok.
      actions: async.value?.savedPreferences == null
          ? null
          : [
              IconButton(
                tooltip: l10n.quranSavedVersesTitle,
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () => context.push(AppRoutes.quranBookmarks),
              ),
            ],
      body: switch (async) {
        AsyncData(:final value) => value.savedPreferences == null
            ? _SetupFlow(state: value)
            : value.isEditingGoal
            ? _GoalEditView(state: value)
            : const _QuranHome(),
        AsyncError() => AppErrorState(
          message: l10n.quranGoalLoadIssue,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(quranPreferencesControllerProvider),
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// Sure okuyucusunu açar; dönüşte devam kartı güncel konumu göstersin
/// diye kayıtlı konum provider'ı tazelenir (TASK 036).
Future<void> _openChapter(
  BuildContext context,
  WidgetRef ref,
  int chapterId,
) async {
  await context.push(AppRoutes.quranChapterPath(chapterId));
  if (context.mounted) {
    ref.invalidate(quranReadingPositionProvider);
  }
}

/// Hedefin "3 sayfa" / "10 dakika" biçimli etiketi.
String _goalAmountLabel(AppLocalizations l10n, QuranReadingGoal goal) =>
    switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesCount(goal.amount),
      QuranReadingGoalType.pages => l10n.quranPagesCount(goal.amount),
    };

// ---------------------------------------------------------------------------
// Kur'an ana ekranı: Oku / Öğren / İlerlemem
// ---------------------------------------------------------------------------

final class _QuranHome extends StatelessWidget {
  const _QuranHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    // Kurulum sonrası varsayılan sekme Oku'dur (initialIndex 0).
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.s3),
          TabBar(
            tabs: [
              Tab(text: l10n.quranTabRead),
              Tab(text: l10n.quranTabLearn),
              Tab(text: l10n.quranTabProgress),
            ],
            labelColor: scheme.primary,
            unselectedLabelColor: ext.textSecondary,
            indicatorColor: scheme.primary,
            dividerColor: Colors.transparent,
          ),
          const SizedBox(height: AppSpacing.s4),
          const Expanded(
            child: TabBarView(
              children: [_ReadTab(), _LearnTab(), _ProgressTab()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Oku sekmesi — kaldığın yer boş durumu + doğrulanmış 114 surelik
/// katalog (TASK 034/034B; Tanzil metadata asset'inden, ayet metni YOK).
/// Lokal arama: numara, Arapça/translit/İngilizce ad. Satırlar TASK
/// 035'te okuyucuya bağlanana kadar dokunulabilir DEĞİLDİR.
final class _ReadTab extends ConsumerStatefulWidget {
  const _ReadTab();

  @override
  ConsumerState<_ReadTab> createState() => _ReadTabState();
}

final class _ReadTabState extends ConsumerState<_ReadTab> {
  String _query = '';

  List<QuranChapter> _filter(List<QuranChapter> chapters) {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) {
      return chapters;
    }
    final lower = trimmed.toLowerCase();
    final number = int.tryParse(trimmed);
    return [
      for (final chapter in chapters)
        if ((number != null && chapter.id == number) ||
            chapter.arabicName.contains(trimmed) ||
            chapter.transliteratedName.toLowerCase().contains(lower) ||
            chapter.englishName.toLowerCase().contains(lower))
          chapter,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranChaptersProvider);

    return switch (async) {
      AsyncData(:final value) => _buildList(l10n, _filter(value)),
      AsyncError() => AppErrorState(
        message: l10n.quranChaptersLoadIssue,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(quranChaptersProvider),
      ),
      _ => AppLoading(label: l10n.commonLoading),
    };
  }

  Widget _buildList(AppLocalizations l10n, List<QuranChapter> chapters) {
    return ListView.builder(
      itemCount: chapters.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s2),
              AppText(l10n.quranResumeTitle, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s3),
              const _ContinueReadingCard(),
              const SizedBox(height: AppSpacing.s5),
              AppText(l10n.quranSurahsSection, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s3),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.quranSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              if (chapters.isEmpty)
                AppCard(
                  child: AppText(
                    l10n.quranSearchNoResults,
                    token: AppTextStyleToken.bodySmall,
                    secondary: true,
                  ),
                ),
            ],
          );
        }
        final chapter = chapters[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s3),
          child: _ChapterRow(
            chapter: chapter,
            onTap: () => _openChapter(context, ref, chapter.id),
          ),
        );
      },
    );
  }
}

/// "Kaldığın yerden devam et" kartı (TASK 036): kayıtlı konum + surenin
/// katalog bilgisi. Kayıt yoksa sakin boş durum; okuma hatasında sakin
/// mesaj. Ayet numarası GÖSTERİLMEZ — yalnız scroll konumu saklanıyor.
final class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranContinueReadingProvider);

    return switch (async) {
      AsyncData(:final value) => value == null
          ? AppCard(
              child: AppText(
                l10n.quranResumeEmpty,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
            )
          : AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          value.chapter.transliteratedName,
                          token: AppTextStyleToken.h3,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      AppText(
                        value.chapter.arabicName,
                        token: AppTextStyleToken.h3,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AppButton(
                    label: l10n.quranResumeCta,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        _openChapter(context, ref, value.chapter.id),
                  ),
                ],
              ),
            ),
      AsyncError() => AppCard(
        child: AppText(
          l10n.quranPositionLoadIssue,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
        ),
      ),
      // Kompakt yükleme — hızlı prefs okuması, kart zıplatılmaz.
      _ => const AppCard(
        child: SizedBox(
          height: AppSizes.iconMd,
          width: AppSizes.iconMd,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    };
  }
}

/// Tek sure satırı — mushaf numarası, ad, ayet sayısı + nüzul yeri ve
/// Arapça ad. Dokunma sure okuyucusunu açar (TASK 035/036).
final class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter, required this.onTap});

  final QuranChapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeLabel = switch (chapter.revelationPlace) {
      QuranRevelationPlace.meccan => l10n.quranRevelationMeccan,
      QuranRevelationPlace.medinan => l10n.quranRevelationMedinan,
    };

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppBadge(label: '${chapter.id}'),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(chapter.transliteratedName),
                const SizedBox(height: AppSpacing.s1),
                AppText(
                  '${l10n.quranAyahCount(chapter.verseCount)} · $placeLabel',
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          AppText(chapter.arabicName, token: AppTextStyleToken.h3),
        ],
      ),
    );
  }
}

/// Öğren sekmesi — yalnız profesyonel boş durum; sahte ders/dini içerik
/// OLUŞTURULMAZ.
final class _LearnTab extends StatelessWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(l10n.quranLearnTitle, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranLearnBody,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// İlerlemem sekmesi — günlük hedef özeti; ilerleme TASK 036'ya kadar 0.
final class _ProgressTab extends ConsumerWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goal = ref
        .watch(quranPreferencesControllerProvider)
        .value
        ?.savedPreferences
        ?.goal;
    if (goal == null) {
      return const SizedBox.shrink(); // savunmacı — bu görünüm kurulumsuz açılmaz
    }

    final typeLabel = switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranGoalTypeMinutes,
      QuranReadingGoalType.pages => l10n.quranGoalTypePages,
    };
    final progressLabel = switch (goal.type) {
      QuranReadingGoalType.minutes => l10n.quranMinutesProgress(
        0,
        goal.amount,
      ),
      QuranReadingGoalType.pages => l10n.quranPagesProgress(0, goal.amount),
    };

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s2),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTodayGoalTitle,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s1),
              AppText(
                _goalAmountLabel(l10n, goal),
                token: AppTextStyleToken.h3,
              ),
              const SizedBox(height: AppSpacing.s1),
              AppText(
                typeLabel,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranGoalGentleLine,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s4),
              AppProgressBar(value: 0, semanticLabel: progressLabel),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                progressLabel,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s4),
              AppButton(
                label: l10n.quranGoalEdit,
                variant: AppButtonVariant.secondary,
                onPressed: () => ref
                    .read(quranPreferencesControllerProvider.notifier)
                    .startGoalEdit(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Üç adımlı ilk kurulum (yalnız Kur'an sekmesi içinde)
// ---------------------------------------------------------------------------

final class _SetupFlow extends ConsumerWidget {
  const _SetupFlow({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);
    final step = state.currentSetupStep;
    const total = QuranPreferencesState.totalSetupSteps;
    final isLastStep = step == total;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppText(
          l10n.quranSetupStepLabel(step, total),
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s2),
        AppProgressBar(
          value: step / total,
          semanticLabel: l10n.quranSetupStepLabel(step, total),
        ),
        const SizedBox(height: AppSpacing.s6),
        ...switch (step) {
          1 => _scriptStep(l10n, controller),
          2 => _translationStep(l10n, controller),
          _ => [
            AppText(l10n.quranSetupGoalTitle, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s1),
            AppText(
              l10n.quranGoalSetupSupport,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s4),
            _GoalSelectionFields(state: state),
          ],
        },
        if (state.saveFailed) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.quranGoalSaveIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: isLastStep ? l10n.quranSetupFinishCta : l10n.quranSetupContinue,
          isLoading: state.isSaving,
          onPressed: !state.canContinueCurrentStep || state.isSaving
              ? null
              : isLastStep
              ? controller.completeSetup
              : controller.goToNextStep,
        ),
        if (step > 1) ...[
          const SizedBox(height: AppSpacing.s2),
          AppButton(
            label: l10n.quranSetupBack,
            variant: AppButtonVariant.text,
            onPressed: state.isSaving ? null : controller.goToPreviousStep,
          ),
        ],
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }

  List<Widget> _scriptStep(
    AppLocalizations l10n,
    QuranPreferencesController controller,
  ) => [
    AppText(l10n.quranSetupScriptTitle, token: AppTextStyleToken.h3),
    const SizedBox(height: AppSpacing.s4),
    OnboardingOptionCard(
      label: l10n.quranScriptUthmani,
      description: l10n.quranScriptUthmaniDesc,
      selected: state.selectedScript == QuranArabicScript.uthmani,
      onTap: () => controller.selectScript(QuranArabicScript.uthmani),
    ),
    const SizedBox(height: AppSpacing.s3),
    OnboardingOptionCard(
      label: l10n.quranScriptIndoPak,
      description: l10n.quranScriptIndoPakDesc,
      selected: state.selectedScript == QuranArabicScript.indopak,
      onTap: () => controller.selectScript(QuranArabicScript.indopak),
    ),
  ];

  List<Widget> _translationStep(
    AppLocalizations l10n,
    QuranPreferencesController controller,
  ) => [
    AppText(l10n.quranSetupTranslationTitle, token: AppTextStyleToken.h3),
    const SizedBox(height: AppSpacing.s4),
    OnboardingOptionCard(
      label: l10n.quranTranslationTurkish,
      description: l10n.quranTranslationTurkishDesc,
      selected: state.selectedTranslation == QuranTranslationPreference.turkish,
      onTap: () =>
          controller.selectTranslation(QuranTranslationPreference.turkish),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Hedef seçim alanları (kurulum 3. adımı + hedef düzenleme ortak)
// ---------------------------------------------------------------------------

final class _GoalSelectionFields extends ConsumerWidget {
  const _GoalSelectionFields({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);
    final type = state.selectedGoalType;

    String amountLabel(QuranReadingGoalType type, int amount) =>
        switch (type) {
          QuranReadingGoalType.minutes => l10n.quranMinutesCount(amount),
          QuranReadingGoalType.pages => l10n.quranPagesCount(amount),
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingOptionCard(
          label: l10n.quranGoalTypeMinutes,
          selected: type == QuranReadingGoalType.minutes,
          onTap: () => controller.selectGoalType(QuranReadingGoalType.minutes),
        ),
        const SizedBox(height: AppSpacing.s3),
        OnboardingOptionCard(
          label: l10n.quranGoalTypePages,
          selected: type == QuranReadingGoalType.pages,
          onTap: () => controller.selectGoalType(QuranReadingGoalType.pages),
        ),
        if (type != null) ...[
          const SizedBox(height: AppSpacing.s5),
          for (final amount in QuranReadingGoal.supportedAmounts(type)) ...[
            OnboardingOptionCard(
              label: amountLabel(type, amount),
              selected: state.selectedGoalAmount == amount,
              onTap: () => controller.selectGoalAmount(amount),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
        ],
      ],
    );
  }
}

/// "Hedefi düzenle" görünümü — yalnız hedef; script ve meal tercihleri
/// KORUNUR, kaydedilmeden mevcut hedef silinmez.
final class _GoalEditView extends ConsumerWidget {
  const _GoalEditView({required this.state});

  final QuranPreferencesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranPreferencesControllerProvider.notifier);

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.s5),
        AppText(l10n.quranSetupGoalTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s1),
        AppText(
          l10n.quranGoalSetupSupport,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
        const SizedBox(height: AppSpacing.s4),
        _GoalSelectionFields(state: state),
        if (state.saveFailed) ...[
          const SizedBox(height: AppSpacing.s2),
          AppText(
            l10n.quranGoalSaveIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
        ],
        const SizedBox(height: AppSpacing.s5),
        AppButton(
          label: l10n.quranGoalSaveCta,
          isLoading: state.isSaving,
          onPressed: state.selectedGoal == null || state.isSaving
              ? null
              : controller.saveGoalEdit,
        ),
        const SizedBox(height: AppSpacing.s2),
        AppButton(
          label: l10n.quranSetupBack,
          variant: AppButtonVariant.text,
          onPressed: state.isSaving ? null : controller.cancelGoalEdit,
        ),
        const SizedBox(height: AppSpacing.s6),
      ],
    );
  }
}

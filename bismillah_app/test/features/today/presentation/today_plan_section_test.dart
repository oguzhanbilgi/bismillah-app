import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_category.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/onboarding/data/onboarding_data_providers.dart';
import 'package:bismillah_app/features/onboarding/domain/entities/onboarding_preferences.dart';
import 'package:bismillah_app/features/onboarding/domain/repositories/onboarding_preferences_repository.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_daily_pace.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_focus_goal.dart';
import 'package:bismillah_app/features/onboarding/domain/value_objects/onboarding_journey_stage.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_controller.dart';
import 'package:bismillah_app/features/today/application/daily_plan_state.dart';
import 'package:bismillah_app/features/today/data/today_data_providers.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/repositories/daily_plan_repository.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:bismillah_app/features/today/presentation/today_plan_item_presentation.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_plan_section.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_plan_task_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Today günlük görev yüzeyi (TASK 083).
///
/// Ekran GoRouter'sız, doğrudan pump'lanır: konu durum makinesinin görsel
/// karşılığı, erişilebilirlik ve dinî güvenliktir — navigasyon değil.
/// Gerçek depolama, ağ, Firebase veya Drift KULLANILMAZ.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 27, 9, 30);
  final today = DayKey('2026-07-27');
  const article = 'art-islam-nedir';

  const trackId = 'prayer_track_daily';
  const onTimeId = 'prayer_on_time_daily';
  const quranId = 'quran_continue_daily';
  const learnId = 'learn_article_$article';

  EntityId itemId(String templateId, int slot) => EntityId(
    '${DailyPlanGenerator.generatorVersion}:${today.value}:$templateId:$slot',
  );

  PlanItem item(
    String templateId,
    int slot,
    PlanItemType type, {
    String? targetRef,
    bool completed = false,
  }) => PlanItem(
    itemId: itemId(templateId, slot),
    type: type,
    status: completed ? PlanItemStatus.completed : PlanItemStatus.pending,
    targetRef: targetRef,
  );

  /// Kanonik Prayer → Quran → Learn günü.
  DailyPlan corePlan({
    List<int> completedSlots = const [],
    DayKey? dayKey,
    String? learnRef = article,
  }) {
    final specs = <(String, PlanItemType, String?)>[
      (trackId, PlanItemType.prayer, null),
      (onTimeId, PlanItemType.prayer, null),
      (quranId, PlanItemType.quran, null),
      (learnId, PlanItemType.lesson, learnRef),
    ];
    return DailyPlan(
      dayKey: dayKey ?? today,
      items: [
        for (var i = 0; i < specs.length; i++)
          item(
            specs[i].$1,
            i,
            specs[i].$2,
            targetRef: specs[i].$3,
            completed: completedSlots.contains(i),
          ),
      ],
      profileType: 'beginner',
      sizeMinutes: 5,
      weekIndex: 0,
      generatedBy: DailyPlanGenerator.generatorVersion,
    );
  }

  late _FakePlanRepository repo;
  late _FakeLearnRepository learn;
  late _FakeOnboardingPreferencesRepository preferences;

  setUp(() {
    repo = _FakePlanRepository();
    learn = _FakeLearnRepository();
    // Varsayılan: kayıtlı tercih YOK → TASK 083A orkestratörü plan
    // üretmez ve bu dosyanın konusu olan durum makinesi izole kalır.
    preferences = _FakeOnboardingPreferencesRepository();
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(repo),
          learningKnowledgeRepositoryProvider.overrideWithValue(learn),
          onboardingPreferencesRepositoryProvider.overrideWithValue(
            preferences,
          ),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          appLocaleAtLaunchProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: const SingleChildScrollView(child: TodayPlanSection()),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  const tr = AppLocalizations(SupportedLocale.tr);
  const en = AppLocalizations(SupportedLocale.en);
  const ar = AppLocalizations(SupportedLocale.ar);

  // -------------------------------------------------------------------
  // Durumlar
  // -------------------------------------------------------------------

  group('durumlar', () {
    testWidgets('yükleme: erişilebilir etiket, sahte içerik yok', (
      tester,
    ) async {
      repo.holdGet();
      await pumpSection(tester, settle: false);
      await tester.pump(); // post-frame loadDay

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(tr.todayPlanLoading), findsOneWidget);
      handle.dispose();
      expect(find.byType(TodayPlanTaskCard), findsNothing);
      expect(find.byType(AppProgressBar), findsNothing);

      repo.releaseGet();
      await tester.pumpAndSettle();
    });

    testWidgets('yükleme iskeleti ANİMASYONSUZDUR (ekran yerleşir)', (
      tester,
    ) async {
      repo.holdGet();
      await pumpSection(tester, settle: false);
      await tester.pump();

      // Sonsuz dönen gösterge yok: hem sakin UX hem de settle güvenliği.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();

      repo.releaseGet();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'yükleme iskeleti gerçek bir blok kaplar (sıfır parlaması yok)',
      (tester) async {
        repo.plans[today] = corePlan();
        repo.holdGet();
        await pumpSection(tester, settle: false);
        await tester.pump();
        final loadingHeight = tester
            .getSize(find.byType(TodayPlanSection))
            .height;

        // Üç yer tutucu satır + başlık: kart boş bir çizgi gibi görünmez.
        expect(loadingHeight, greaterThan(180));

        repo.releaseGet();
        await tester.pumpAndSettle();
        final loadedHeight = tester
            .getSize(find.byType(TodayPlanSection))
            .height;

        // İçerik geldiğinde büyür; asla küçülüp sonra açılmaz.
        expect(loadedHeight, greaterThanOrEqualTo(loadingHeight));
      },
    );

    testWidgets('boş: nötr açıklama, sahte "plan oluştur" düğmesi YOK', (
      tester,
    ) async {
      await pumpSection(tester);

      expect(find.text(tr.todayPlanEmptyTitle), findsOneWidget);
      expect(find.text(tr.todayPlanEmptyBody), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
      expect(find.byType(TodayPlanTaskCard), findsNothing);
    });

    testWidgets('mevcut: başlık, gün, ilerleme ve dört görev', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      expect(find.text(tr.todayPlanTitle), findsOneWidget);
      expect(find.text(tr.todayPlanSelectedDay(today.value)), findsOneWidget);
      expect(find.text(tr.todayPlanProgress(0, 4)), findsWidgets);
      expect(find.byType(AppProgressBar), findsOneWidget);
      expect(find.byType(TodayPlanTaskCard), findsNWidgets(4));
    });

    testWidgets('bozuk: sakin açıklama, otomatik sıfırlama yok', (
      tester,
    ) async {
      repo.getFailure = const StorageCorruptionFailure();
      await pumpSection(tester);

      expect(find.text(tr.todayPlanCorruptTitle), findsOneWidget);
      expect(find.text(tr.todayPlanCorruptBody), findsOneWidget);
      // Bozulma tekrar denemeyi çözmez → yeniden dene düğmesi yok.
      expect(find.byType(AppButton), findsNothing);
      expect(repo.saveCalls, 0, reason: 'depo kendiliğinden yazmaz');
    });

    testWidgets('hata: nötr mesaj + yeniden dene', (tester) async {
      repo.getFailure = const StorageFailure();
      await pumpSection(tester);

      expect(find.text(tr.todayPlanFailureBody), findsOneWidget);
      expect(find.text(tr.commonRetry), findsOneWidget);
    });

    testWidgets('yeniden dene controller.retry çağırır ve düzelir', (
      tester,
    ) async {
      repo.getFailure = const StorageFailure();
      await pumpSection(tester);
      expect(find.text(tr.todayPlanFailureBody), findsOneWidget);

      repo.getFailure = null;
      repo.plans[today] = corePlan();
      await tester.tap(find.text(tr.commonRetry));
      await tester.pumpAndSettle();

      expect(find.byType(TodayPlanTaskCard), findsNWidgets(4));
      expect(repo.getCalls, greaterThanOrEqualTo(2));
    });

    testWidgets('bugünün günü saatten TÜRETİLİR', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      expect(repo.requestedDays, contains(today));
      expect(find.text(tr.todayPlanSelectedDay('2026-07-27')), findsOneWidget);
    });

    testWidgets('gün bir kez seçilir — çift abonelik yok', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.watchCalls, 1);
    });

    testWidgets('kayıtlı tercihle açılış planı KURAR ve Available olur', (
      tester,
    ) async {
      // TASK 083A: mevcut kullanıcı (onboarding tamam, plan yok).
      preferences.stored = OnboardingPreferences(
        goals: const {
          OnboardingFocusGoal.trackPrayers,
          OnboardingFocusGoal.quranHabit,
        },
        journeyStage: OnboardingJourneyStage.justBeginning,
        dailyPace: OnboardingDailyPace.balanced,
        completedAtUtc: fixedLocalNow.toUtc(),
      );
      await pumpSection(tester);

      expect(repo.batchSaveCalls, 1);
      expect(repo.plans.length, 30);
      expect(find.byType(TodayPlanTaskCard), findsNWidgets(2));
      expect(find.text(tr.todayPlanEmptyTitle), findsNothing);
    });

    testWidgets('yeniden çizim planı YENİDEN ÜRETMEZ', (tester) async {
      preferences.stored = OnboardingPreferences(
        goals: const {OnboardingFocusGoal.trackPrayers},
        journeyStage: OnboardingJourneyStage.justBeginning,
        dailyPace: OnboardingDailyPace.balanced,
        completedAtUtc: fixedLocalNow.toUtc(),
      );
      await pumpSection(tester);
      expect(repo.batchSaveCalls, 1);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.batchSaveCalls, 1, reason: 'build döngüsü üretim yapmaz');
      expect(repo.plans.length, 30);
    });

    testWidgets('tercih yokken plan UYDURULMAZ (Empty kalır)', (tester) async {
      await pumpSection(tester);

      expect(repo.batchSaveCalls, 0);
      expect(repo.plans, isEmpty);
      expect(find.text(tr.todayPlanEmptyTitle), findsOneWidget);
    });

    testWidgets('öğesiz plan: nötr satır, ilerleme %0', (tester) async {
      repo.plans[today] = DailyPlan(
        dayKey: today,
        items: const [],
        profileType: 'beginner',
        sizeMinutes: 5,
        weekIndex: 0,
        generatedBy: DailyPlanGenerator.generatorVersion,
      );
      await pumpSection(tester);

      expect(find.text(tr.todayPlanNoItems), findsOneWidget);
      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, 0.0);
    });
  });

  // -------------------------------------------------------------------
  // Öğe sunumu ve sıra
  // -------------------------------------------------------------------

  group('görev sunumu', () {
    testWidgets('kanonik sıra Prayer → Quran → Learn korunur', (tester) async {
      repo.plans[today] = corePlan();
      learn.titles[article] = 'İslam nedir?';
      await pumpSection(tester);

      final titles = tester
          .widgetList<TodayPlanTaskCard>(find.byType(TodayPlanTaskCard))
          .map((card) => card.presentation.title)
          .toList();
      expect(titles, [
        tr.todayPlanItemPrayerTrack,
        tr.todayPlanItemPrayerOnTime,
        tr.todayPlanItemQuranContinue,
        'İslam nedir?',
      ]);
    });

    testWidgets('yerelleştirilmiş metne göre YENİDEN SIRALANMAZ', (
      tester,
    ) async {
      // Alfabetik sıralama olsaydı Learn başlığı en başa gelirdi.
      repo.plans[today] = corePlan();
      learn.titles[article] = 'Aaa ilk harf';
      await pumpSection(tester);

      final first = tester
          .widgetList<TodayPlanTaskCard>(find.byType(TodayPlanTaskCard))
          .first;
      expect(first.presentation.title, tr.todayPlanItemPrayerTrack);
    });

    testWidgets('Learn başlığı doğrulanmış içerik katmanından çözülür', (
      tester,
    ) async {
      repo.plans[today] = corePlan();
      learn.titles[article] = 'İslam nedir?';
      await pumpSection(tester);

      expect(find.text('İslam nedir?'), findsOneWidget);
      expect(learn.requestedIds, contains(article));
    });

    testWidgets('çözülemeyen Learn referansı nötr etikete düşer', (
      tester,
    ) async {
      repo.plans[today] = corePlan();
      // Depo bu kimliği bilmiyor (yayından kalkmış olabilir).
      await pumpSection(tester);

      expect(find.text(tr.todayPlanItemLessonFallback), findsOneWidget);
      expect(
        find.text(article),
        findsNothing,
        reason: 'ham kimlik gösterilmez',
      );
    });

    testWidgets('Learn içerik hatası ekranı BLOKLAMAZ', (tester) async {
      repo.plans[today] = corePlan();
      learn.failure = const StorageFailure();
      await pumpSection(tester);

      expect(find.byType(TodayPlanTaskCard), findsNWidgets(4));
      expect(find.text(tr.todayPlanItemLessonFallback), findsOneWidget);
    });

    testWidgets('targetRef null olan ders öğesi çökmez', (tester) async {
      repo.plans[today] = corePlan(learnRef: null);
      await pumpSection(tester);

      expect(find.byType(TodayPlanTaskCard), findsNWidgets(4));
      expect(find.text(tr.todayPlanItemLessonFallback), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('durum etiketleri: işaretli / işaretsiz', (tester) async {
      repo.plans[today] = corePlan(completedSlots: const [0]);
      await pumpSection(tester);

      expect(find.text(tr.todayPlanItemCompleted), findsOneWidget);
      expect(find.text(tr.todayPlanItemPending), findsNWidgets(3));
    });

    testWidgets('tamamlanmamış görev HATA rengiyle gösterilmez', (
      tester,
    ) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      final scheme = AppTheme.light().colorScheme;
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        expect(icon.color, isNot(scheme.error));
        expect(icon.icon, isNot(Icons.error));
        expect(icon.icon, isNot(Icons.warning));
      }
    });
  });

  group('şablon eşlemesi (saf)', () {
    final cases = <String, (String, PlanItemType, String)>{
      'namaz takibi': (
        trackId,
        PlanItemType.prayer,
        'todayPlanItemPrayerTrack',
      ),
      'vaktinde namaz': (
        onTimeId,
        PlanItemType.prayer,
        'todayPlanItemPrayerOnTime',
      ),
      'Kur\'an devam': (
        quranId,
        PlanItemType.quran,
        'todayPlanItemQuranContinue',
      ),
    };

    String expectedOf(String key) => switch (key) {
      'todayPlanItemPrayerTrack' => tr.todayPlanItemPrayerTrack,
      'todayPlanItemPrayerOnTime' => tr.todayPlanItemPrayerOnTime,
      _ => tr.todayPlanItemQuranContinue,
    };

    for (final entry in cases.entries) {
      test('${entry.key} nötr başlığa eşlenir', () {
        final (templateId, type, expectedKey) = entry.value;
        final presentation = TodayPlanItemPresentation.of(
          tr,
          item(templateId, 0, type),
        );
        expect(presentation.title, expectedOf(expectedKey));
        expect(presentation.isResolving, isFalse);
      });
    }

    test('bilinmeyen şablon tip yedeğine düşer (uydurma başlık yok)', () {
      final presentation = TodayPlanItemPresentation.of(
        tr,
        item('totally_unknown_template', 0, PlanItemType.dhikr),
      );
      expect(presentation.title, tr.todayPlanItemDhikrFallback);
    });

    test('bozuk kimlik biçimi çökmez, tip yedeği kullanılır', () {
      final broken = PlanItem(
        itemId: EntityId('not-a-composed-id'),
        type: PlanItemType.reflection,
        status: PlanItemStatus.pending,
      );
      expect(TodayPlanItemPresentation.templateIdOf(broken), isNull);
      expect(
        TodayPlanItemPresentation.of(tr, broken).title,
        tr.todayPlanItemReflectionFallback,
      );
    });

    test('HER PlanItemType için nötr yedek vardır (kapsam kilidi)', () {
      for (final type in PlanItemType.values) {
        final presentation = TodayPlanItemPresentation.of(
          tr,
          item('unknown_$type', 0, type),
        );
        expect(presentation.title.trim(), isNotEmpty, reason: type.name);
      }
    });

    test('ders başlığı çözülürken isResolving işaretlenir', () {
      final presentation = TodayPlanItemPresentation.of(
        tr,
        item(learnId, 3, PlanItemType.lesson, targetRef: article),
        isResolvingLearnTitle: true,
      );
      expect(presentation.isResolving, isTrue);
      expect(presentation.title, tr.todayPlanItemLessonFallback);
    });

    test('şablon kimliği kullanıcı metni olarak KULLANILMAZ', () {
      for (final templateId in [trackId, onTimeId, quranId, learnId]) {
        final presentation = TodayPlanItemPresentation.of(
          tr,
          item(templateId, 0, PlanItemType.prayer),
        );
        expect(presentation.title, isNot(contains('_')));
        expect(presentation.title, isNot(contains(templateId)));
      }
    });
  });

  // -------------------------------------------------------------------
  // İlerleme
  // -------------------------------------------------------------------

  group('ilerleme', () {
    final cases = <String, (List<int>, double, int)>{
      'hiçbiri': (<int>[], 0.0, 0),
      'kısmi': ([0, 1], 0.5, 2),
      'tamamı': ([0, 1, 2, 3], 1.0, 4),
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key} tamamlanmış', (tester) async {
        final (slots, value, completed) = entry.value;
        repo.plans[today] = corePlan(completedSlots: slots);
        await pumpSection(tester);

        final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
        expect(bar.value, value);
        expect(bar.semanticLabel, tr.todayPlanProgress(completed, 4));
      });
    }

    testWidgets('tam tamamlanmada kutlama/puan/rütbe dili YOK', (tester) async {
      repo.plans[today] = corePlan(completedSlots: const [0, 1, 2, 3]);
      await pumpSection(tester);

      for (final forbidden in ['puan', 'seri', 'rütbe', 'ödül', 'sevap']) {
        expect(find.textContaining(forbidden), findsNothing);
      }
    });
  });

  // -------------------------------------------------------------------
  // Tamamlama etkileşimi
  // -------------------------------------------------------------------

  group('tamamlama', () {
    testWidgets('karta dokunma öğeyi işaretler ve KAYDEDER', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemQuranContinue));
      await tester.pumpAndSettle();

      expect(repo.saveCalls, 1);
      final saved = repo.plans[today]!;
      expect(saved.items[2].isCompleted, isTrue);
      expect(saved.items[2].completedAt, isNotNull);
      expect(find.text(tr.todayPlanItemCompleted), findsOneWidget);
    });

    testWidgets('tekrar dokunma işareti kaldırır ve completedAt siler', (
      tester,
    ) async {
      repo.plans[today] = corePlan(completedSlots: const [2]);
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemQuranContinue));
      await tester.pumpAndSettle();

      final saved = repo.plans[today]!;
      expect(saved.items[2].isCompleted, isFalse);
      expect(saved.items[2].completedAt, isNull);
    });

    testWidgets('diğer öğeler ve plan alanları KORUNUR', (tester) async {
      repo.plans[today] = corePlan();
      final before = corePlan();
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemPrayerOnTime));
      await tester.pumpAndSettle();

      final saved = repo.plans[today]!;
      expect(saved.dayKey, before.dayKey);
      expect(saved.profileType, before.profileType);
      expect(saved.sizeMinutes, before.sizeMinutes);
      expect(saved.weekIndex, before.weekIndex);
      expect(saved.generatedBy, before.generatedBy);
      expect(saved.items.length, 4);
      expect(
        saved.items.map((i) => i.itemId.value).toList(),
        before.items.map((i) => i.itemId.value).toList(),
      );
      expect(saved.items[0].isCompleted, isFalse);
      expect(saved.items[2].isCompleted, isFalse);
      expect(saved.items[3].targetRef, article);
    });

    testWidgets('completedAt enjekte edilen saatten gelir', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemPrayerTrack));
      await tester.pumpAndSettle();

      expect(
        repo.plans[today]!.items[0].completedAt!.value,
        fixedLocalNow.toUtc(),
      );
    });

    testWidgets('kaydetme sürerken ikinci dokunuş yazma BAŞLATMAZ', (
      tester,
    ) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);
      repo.holdSave();

      await tester.tap(find.text(tr.todayPlanItemQuranContinue));
      await tester.pump();
      await tester.tap(find.text(tr.todayPlanItemQuranContinue));
      await tester.pump();

      expect(repo.saveCalls, 1, reason: 'çift yazma engellenir');
      repo.releaseSave();
      await tester.pumpAndSettle();
    });

    testWidgets('yeniden okumada işaret KORUNUR', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemPrayerTrack));
      await tester.pumpAndSettle();

      await pumpSection(tester);
      expect(find.text(tr.todayPlanItemCompleted), findsOneWidget);
    });

    testWidgets('kaydetme hatası nötr hata durumuna düşer', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);
      repo.saveFailure = const StorageFailure();

      await tester.tap(find.text(tr.todayPlanItemPrayerTrack));
      await tester.pumpAndSettle();

      expect(find.text(tr.todayPlanFailureBody), findsOneWidget);
    });

    testWidgets('işaretleme plan ÜRETMEZ ve başka günü değiştirmez', (
      tester,
    ) async {
      final otherDay = DayKey('2026-07-26');
      repo.plans[today] = corePlan();
      repo.plans[otherDay] = corePlan(dayKey: otherDay);
      await pumpSection(tester);

      await tester.tap(find.text(tr.todayPlanItemPrayerTrack));
      await tester.pumpAndSettle();

      expect(repo.plans[otherDay]!.items.every((i) => !i.isCompleted), isTrue);
      expect(repo.plans.length, 2, reason: 'yeni gün üretilmez');
    });

    test('bilinmeyen öğe kimliği güvenle yok sayılır', () async {
      final container = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(repo),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ],
      );
      addTearDown(container.dispose);
      repo.plans[today] = corePlan();

      final controller = container.read(dailyPlanControllerProvider.notifier);
      await controller.loadDay(today);
      await controller.toggleItemCompletion(EntityId('nope'));

      expect(repo.saveCalls, 0);
      expect(
        container.read(dailyPlanControllerProvider),
        isA<DailyPlanAvailable>(),
      );
    });

    test('gün seçilmeden işaretleme hiçbir şey yapmaz', () async {
      final container = ProviderContainer(
        overrides: [
          dailyPlanRepositoryProvider.overrideWithValue(repo),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dailyPlanControllerProvider.notifier)
          .toggleItemCompletion(itemId(trackId, 0));

      expect(repo.saveCalls, 0);
      expect(container.read(dailyPlanControllerProvider), isNull);
    });
  });

  // -------------------------------------------------------------------
  // Erişilebilirlik, düzen ve yerelleştirme
  // -------------------------------------------------------------------

  group('erişilebilirlik ve düzen', () {
    testWidgets('görev kartı buton semantiği + durum taşır', (tester) async {
      repo.plans[today] = corePlan(completedSlots: const [0]);
      await pumpSection(tester);

      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          '${tr.todayPlanItemPrayerTrack}, ${tr.todayPlanItemCompleted}',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          '${tr.todayPlanItemQuranContinue}, ${tr.todayPlanItemPending}',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('kartlar minimum dokunma hedefini karşılar', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      for (final size
          in tester
              .widgetList<TodayPlanTaskCard>(find.byType(TodayPlanTaskCard))
              .map((card) => tester.getSize(find.byWidget(card)))) {
        expect(size.height, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('dar ekran (320px) taşmaz', (tester) async {
      repo.plans[today] = corePlan();
      learn.titles[article] =
          'Çok uzun bir öğrenme başlığı: temizlik, abdest ve gusül konularına '
          'kapsamlı bir giriş yazısı';
      await pumpSection(tester, size: const Size(320, 2400));

      expect(tester.takeException(), isNull);
    });

    testWidgets('büyük yazı (1.5x) taşmaz', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester, size: const Size(320, 3000), textScale: 1.5);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Arapça RTL yönü korunur', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester, locale: SupportedLocale.ar);

      expect(
        Directionality.of(tester.element(find.byType(TodayPlanSection))),
        TextDirection.rtl,
      );
      expect(find.text(ar.todayPlanTitle), findsOneWidget);
    });

    testWidgets('İngilizce metinler çözülür', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester, locale: SupportedLocale.en);

      expect(find.text(en.todayPlanTitle), findsOneWidget);
      expect(find.text(en.todayPlanItemPrayerTrack), findsOneWidget);
    });

    test('plan metinleri üç dilde gerçekten çevrilmiştir', () {
      final keys = <String Function(AppLocalizations)>[
        (l) => l.todayPlanTitle,
        (l) => l.todayPlanEmptyTitle,
        (l) => l.todayPlanCorruptTitle,
        (l) => l.todayPlanFailureBody,
        (l) => l.todayPlanItemPrayerTrack,
        (l) => l.todayPlanItemPrayerOnTime,
        (l) => l.todayPlanItemQuranContinue,
        (l) => l.todayPlanItemLessonFallback,
        (l) => l.todayPlanItemCompleted,
        (l) => l.todayPlanItemPending,
      ];
      for (final key in keys) {
        expect(key(tr), isNotEmpty);
        expect(key(en), isNot(key(tr)));
        expect(key(ar), isNot(key(tr)));
        expect(key(ar), isNot(key(en)));
      }
    });
  });

  // -------------------------------------------------------------------
  // Dinî güvenlik, gizlilik ve ücretsiz çekirdek
  // -------------------------------------------------------------------

  group('dinî güvenlik ve gizlilik', () {
    testWidgets('ham hata/depolama/JSON detayı SIZMAZ', (tester) async {
      repo.getFailure = const StorageCorruptionFailure();
      await pumpSection(tester);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join('\n');
      for (final forbidden in [
        'bismillah.daily_plans',
        'FormatException',
        'Exception',
        'errorStorage',
        '#0',
        'SharedPreferences',
        'firebase',
        'uid',
        '{',
      ]) {
        expect(texts, isNot(contains(forbidden)));
      }
    });

    testWidgets('plan yüzeyi sure/ayet/kota/hüküm iddia etmez', (tester) async {
      repo.plans[today] = corePlan();
      learn.titles[article] = 'İslam nedir?';
      await pumpSection(tester);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join('\n');
      for (final forbidden in [
        'ayet',
        'sure',
        'cüz',
        'rekat',
        'farz',
        'vacip',
        'günah',
        'sevap',
        'ödül',
        'ceza',
        'puan',
        'seri',
      ]) {
        expect(texts.toLowerCase(), isNot(contains(forbidden)));
      }
    });

    testWidgets('paywall/reklam/bağış öğesi YOK', (tester) async {
      repo.plans[today] = corePlan();
      await pumpSection(tester);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join('\n');
      for (final forbidden in [
        'premium',
        'bismillah+',
        'abonelik',
        'yükselt',
        'destekçi',
        'bağış',
        'reklam',
        'kilitli',
        'lösev',
      ]) {
        expect(texts, isNot(contains(forbidden)));
      }
    });

    testWidgets('ham makale kimliği veya şablon kimliği ekrana yazılmaz', (
      tester,
    ) async {
      repo.plans[today] = corePlan();
      learn.titles[article] = 'İslam nedir?';
      await pumpSection(tester);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join('\n');
      for (final raw in [article, trackId, onTimeId, quranId, learnId]) {
        expect(texts, isNot(contains(raw)));
      }
      expect(texts, isNot(contains('rule-engine-v1')));
    });

    testWidgets('bölüm plan ÜRETMEZ ve kendiliğinden KAYDETMEZ', (
      tester,
    ) async {
      await pumpSection(tester); // boş gün
      expect(repo.saveCalls, 0);

      repo.getFailure = const StorageCorruptionFailure();
      await pumpSection(tester);
      expect(repo.saveCalls, 0);
    });
  });
}

/// Denetlenebilir sahte plan deposu (gerçek depolama yok).
final class _FakePlanRepository implements DailyPlanRepository {
  final Map<DayKey, DailyPlan> plans = {};
  final Map<DayKey, StreamController<DailyPlan?>> _streams = {};
  final List<DayKey> requestedDays = [];

  AppFailure? getFailure;
  AppFailure? saveFailure;

  int getCalls = 0;
  int saveCalls = 0;
  int batchSaveCalls = 0;
  int watchCalls = 0;

  Completer<void>? _getGate;
  Completer<void>? _saveGate;

  void holdGet() => _getGate = Completer<void>();
  void releaseGet() => _getGate?.complete();
  void holdSave() => _saveGate = Completer<void>();
  void releaseSave() => _saveGate?.complete();

  StreamController<DailyPlan?> _streamFor(DayKey dayKey) =>
      _streams.putIfAbsent(dayKey, StreamController<DailyPlan?>.broadcast);

  @override
  Stream<DailyPlan?> watchPlan(DayKey dayKey) {
    watchCalls++;
    return _streamFor(dayKey).stream;
  }

  @override
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey) async {
    getCalls++;
    requestedDays.add(dayKey);
    final failure = getFailure;
    final gate = _getGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    if (failure != null) {
      return Result.failure(failure);
    }
    return Result.success(plans[dayKey]);
  }

  @override
  ResultFuture<void> savePlan(DailyPlan plan) async {
    saveCalls++;
    final failure = saveFailure;
    final gate = _saveGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    if (failure != null) {
      return Result.failure(failure);
    }
    plans[plan.dayKey] = plan;
    return const Result.success(null);
  }

  @override
  ResultFuture<void> savePlans(List<DailyPlan> plans) async {
    batchSaveCalls++;
    for (final plan in plans) {
      this.plans[plan.dayKey] = plan;
    }
    return const Result.success(null);
  }

  @override
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to) async {
    final selected =
        plans.entries
            .where(
              (e) => e.key.compareTo(from) >= 0 && e.key.compareTo(to) <= 0,
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return Result.success([for (final e in selected) e.value]);
  }
}

/// Kayıtlı onboarding tercihi olmayan sahte depo (varsayılan).
final class _FakeOnboardingPreferencesRepository
    implements OnboardingPreferencesRepository {
  OnboardingPreferences? stored;

  @override
  Future<bool> isCompleted() async => stored != null;

  @override
  ResultFuture<OnboardingPreferences?> load() async => Result.success(stored);

  @override
  ResultFuture<void> saveCompleted(OnboardingPreferences preferences) async {
    stored = preferences;
    return const Result.success(null);
  }
}

/// Yalnız kimlik→başlık çözümünü taklit eden sahte Learn deposu.
final class _FakeLearnRepository implements LearningKnowledgeRepository {
  final Map<String, String> titles = {};
  final List<String> requestedIds = [];

  AppFailure? failure;

  @override
  ResultFuture<List<LearningArticle>> getArticlesByIds(
    String locale,
    List<String> ids,
  ) async {
    requestedIds.addAll(ids);
    final f = failure;
    if (f != null) {
      return Result.failure(f);
    }
    return Result.success([
      for (final id in ids)
        if (titles.containsKey(id)) _article(id, titles[id]!),
    ]);
  }

  static LearningArticle _article(String id, String title) => LearningArticle(
    id: id,
    slug: id,
    categoryId: 'cat-basics',
    title: title,
    summary: 'test',
    sections: [
      LearningSection(type: LearningSectionType.paragraph, text: 'test'),
    ],
    contentType: LearningContentType.generalTeaching,
    difficulty: LearningDifficulty.beginner,
    estimatedMinutes: 4,
    keywords: const [],
    sourceIds: const [],
    reviewStatus: ReviewStatus.draft,
    translationStatus: LearningTranslationStatus.original,
  );

  // Bu yüzey TASK 083'te kullanılmaz.
  @override
  ResultFuture<List<LearningCategorySummary>> getCategories(
    String locale,
  ) async => const Result.success(<LearningCategorySummary>[]);

  @override
  ResultFuture<LearningCategory?> getCategoryBySlug(
    String locale,
    String slug,
  ) async => const Result.success(null);

  @override
  ResultFuture<List<LearningArticle>> getArticlesByCategory(
    String locale,
    String categoryId,
  ) async => const Result.success(<LearningArticle>[]);

  @override
  ResultFuture<LearningArticle?> getArticleBySlug(
    String locale,
    String slug,
  ) async => const Result.success(null);

  @override
  ResultFuture<List<LearningArticle>> getAllPublished(String locale) async =>
      const Result.success(<LearningArticle>[]);

  @override
  ResultFuture<List<LearningArticle>> getBeginnerPath(String locale) async =>
      const Result.success(<LearningArticle>[]);

  @override
  ResultFuture<List<LearningArticle>> getFeatured(String locale) async =>
      const Result.success(<LearningArticle>[]);

  @override
  ResultFuture<List<LearningArticle>> search(
    String locale,
    String query,
  ) async => const Result.success(<LearningArticle>[]);

  @override
  ResultFuture<List<KnowledgeSource>> getSourcesForArticle(
    LearningArticle article,
  ) async => const Result.success(<KnowledgeSource>[]);

  @override
  ResultFuture<KnowledgeSource?> getSourceById(String id) async =>
      const Result.success(null);
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';
import 'package:bismillah_app/features/today/presentation/today_plan_item_presentation.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_plan_task_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_motion_switcher.dart';
import 'package:bismillah_app/shared/widgets/app_press_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 095 — hareket sistemi temeli.
///
/// Konu **hareketin davranışa zarar vermemesidir**: reduced-motion, hızlı
/// dokunuşta durum tutarlılığı, Kur'an sesinin dinle/yükleniyor/duraklat
/// hâlleri, Today tamamlama mantığı, onboarding seçim semantiği ve RTL.
/// Gerçek depolama, ağ, Firebase veya ses servisi KULLANILMAZ.
void main() {
  Widget host(
    Widget child, {
    required bool disableAnimations,
    required SupportedLocale locale,
    required Size size,
    required double textScale,
  }) => MaterialApp(
    theme: AppTheme.light(),
    locale: locale.locale,
    supportedLocales: SupportedLocale.locales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox.fromSize(size: size, child: child),
          ),
        ),
      ),
    ),
  );

  /// Yerelleştirme delegate'leri ilk karede çözülür; ikinci kare olmadan
  /// `home` hiç çizilmez.
  Future<void> pumpHost(
    WidgetTester tester,
    Widget child, {
    bool disableAnimations = false,
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(360, 560),
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      host(
        child,
        disableAnimations: disableAnimations,
        locale: locale,
        size: size,
        textScale: textScale,
      ),
    );
    await tester.pump();
  }

  PlanItem planItem({required bool completed}) => PlanItem(
    itemId: EntityId('rule-engine-v1:2026-07-27:quran_continue_daily:0'),
    type: PlanItemType.quran,
    status: completed ? PlanItemStatus.completed : PlanItemStatus.pending,
  );

  Widget taskCard({required bool completed, VoidCallback? onToggle}) => Builder(
    builder: (context) {
      final item = planItem(completed: completed);
      return TodayPlanTaskCard(
        item: item,
        presentation: TodayPlanItemPresentation.of(
          AppLocalizations.of(context),
          item,
        ),
        onToggle: onToggle,
      );
    },
  );

  group('Hareket token katmanı', () {
    test('süreler önerilen sakin aralıklardadır ve artan sıradadır', () {
      expect(AppMotion.tap.inMilliseconds, inInclusiveRange(110, 130));
      expect(AppMotion.selection.inMilliseconds, inInclusiveRange(170, 190));
      expect(AppMotion.stateChange.inMilliseconds, inInclusiveRange(220, 250));
      expect(AppMotion.tap, lessThan(AppMotion.selection));
      expect(AppMotion.selection, lessThan(AppMotion.stateChange));
    });

    test('basılı ölçek çok küçüktür ve YALNIZ küçültür (zıplama yok)', () {
      expect(AppMotion.pressedScale, lessThan(1));
      expect(AppMotion.pressedScale, greaterThanOrEqualTo(0.95));
      // Yay/geri sekme eğrileri bilinçli olarak kullanılmaz.
      for (final curve in [
        AppMotion.tapCurve,
        AppMotion.selectionCurve,
        AppMotion.stateChangeCurve,
      ]) {
        expect(curve, isNot(Curves.easeOutBack));
        expect(curve, isNot(Curves.elasticOut));
        expect(curve, isNot(Curves.bounceOut));
      }
    });
  });

  group('Reduced-motion', () {
    testWidgets('disableAnimations tüm rol sürelerini SIFIRLAR', (
      tester,
    ) async {
      late BuildContext ctx;
      await pumpHost(
        tester,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
        disableAnimations: true,
      );

      expect(AppMotion.isReduced(ctx), isTrue);
      for (final token in [
        AppMotion.tap,
        AppMotion.selection,
        AppMotion.stateChange,
      ]) {
        expect(AppMotion.of(ctx, token), Duration.zero);
      }
      // Basılıyken bile ölçek uygulanmaz.
      expect(AppMotion.pressScaleOf(ctx, pressed: true), 1.0);
    });

    testWidgets('disableAnimations kapalıyken süre ve ölçek KORUNUR', (
      tester,
    ) async {
      late BuildContext ctx;
      await pumpHost(
        tester,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(AppMotion.isReduced(ctx), isFalse);
      expect(AppMotion.of(ctx, AppMotion.stateChange), AppMotion.stateChange);
      expect(
        AppMotion.pressScaleOf(ctx, pressed: true),
        AppMotion.pressedScale,
      );
      expect(AppMotion.pressScaleOf(ctx, pressed: false), 1.0);
    });

    testWidgets('reduced-motion açıkken geçiş ANINDA tamamlanır', (
      tester,
    ) async {
      await pumpHost(
        tester,
        taskCard(completed: false),
        disableAnimations: true,
      );
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await pumpHost(
        tester,
        taskCard(completed: true),
        disableAnimations: true,
      );

      // Tek kare sonra eski ikon YOKTUR: ara geçiş çizilmez.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });

    testWidgets('AppCard yüzey süresi reduced-motion ile sıfırlanır', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const AppCard(completed: true, child: Text('x')),
        disableAnimations: true,
      );
      final animated = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animated.duration, Duration.zero);
    });

    testWidgets('reduced-motion kapalıyken yüzey seçim süresini kullanır', (
      tester,
    ) async {
      await pumpHost(tester, const AppCard(completed: true, child: Text('x')));
      final animated = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animated.duration, AppMotion.selection);
    });
  });

  group('Dokunma geri bildirimi', () {
    testWidgets('basılı ölçek dokunuşu YUTMAZ (jest arenasına girmez)', (
      tester,
    ) async {
      var taps = 0;
      await pumpHost(
        tester,
        AppCard(onTap: () => taps++, child: const Text('kart')),
      );

      expect(find.byType(AppPressScale), findsOneWidget);
      await tester.tap(find.text('kart'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('dokunulamayan kart hiç dinleyici EKLEMEZ', (tester) async {
      await pumpHost(tester, const AppCard(child: Text('kart')));
      expect(find.byType(AppPressScale), findsNothing);
    });

    testWidgets('basılı tutmada ölçek küçülür, bırakınca geri döner', (
      tester,
    ) async {
      await pumpHost(tester, AppCard(onTap: () {}, child: const Text('kart')));

      double scale() => tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(AppPressScale),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      expect(scale(), 1.0);
      final gesture = await tester.press(find.text('kart'));
      await tester.pump();
      expect(scale(), AppMotion.pressedScale);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), 1.0);
    });
  });

  group('Today tamamlama', () {
    testWidgets('tamamlanmamış kart nötr halka gösterir ve bir kez tetikler', (
      tester,
    ) async {
      var toggles = 0;
      await pumpHost(
        tester,
        taskCard(completed: false, onToggle: () => toggles++),
      );

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      await tester.tap(find.byType(TodayPlanTaskCard));
      await tester.pumpAndSettle();
      expect(toggles, 1);
    });

    testWidgets('kaydetme sürerken (onToggle null) HIZLI dokunuşlar yazmaz', (
      tester,
    ) async {
      var toggles = 0;
      await pumpHost(
        tester,
        taskCard(completed: false, onToggle: () => toggles++),
      );
      await tester.tap(find.byType(TodayPlanTaskCard));
      await tester.pump(); // geçiş henüz sürerken kilit devreye girer

      // Bölüm, kaydetme sürerken kartı salt-okunur yapar; hareket bu
      // kilidi geciktirmemelidir.
      await pumpHost(tester, taskCard(completed: false));
      await tester.tap(find.byType(TodayPlanTaskCard), warnIfMissed: false);
      await tester.tap(find.byType(TodayPlanTaskCard), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(toggles, 1, reason: 'kilitliyken ek yazma tetiklenmez');
    });

    testWidgets('tamamlanma semantiği ve durum metni KORUNUR', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester, taskCard(completed: true));
      final l10n = AppLocalizations.of(
        tester.element(find.byType(TodayPlanTaskCard)),
      );
      final title = TodayPlanItemPresentation.of(
        l10n,
        planItem(completed: true),
      ).title;

      // Ekran okuyucu görevi ve durumunu TEK cümlede duyar.
      final labelled = find.bySemanticsLabel(
        '$title, ${l10n.todayPlanItemCompleted}',
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(labelled, findsOneWidget);
      expect(
        tester.getSemantics(labelled),
        isSemantics(isToggled: true, hasToggledState: true),
      );
      handle.dispose();
    });

    testWidgets('geçiş sonunda TEK ikon kalır (kutlama/konfeti yok)', (
      tester,
    ) async {
      await pumpHost(tester, taskCard(completed: false));
      await pumpHost(tester, taskCard(completed: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    });
  });

  group('Onboarding seçimi', () {
    testWidgets('seçim semantiği ve işaret geçişi doğrudur', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(
        tester,
        OnboardingOptionCard(
          label: 'Namazı takip et',
          selected: false,
          onTap: () {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(OnboardingOptionCard)),
        isSemantics(isSelected: false, hasSelectedState: true),
      );
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      await pumpHost(
        tester,
        OnboardingOptionCard(
          label: 'Namazı takip et',
          selected: true,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(OnboardingOptionCard)),
        isSemantics(isSelected: true, hasSelectedState: true),
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNothing);
      handle.dispose();
    });

    testWidgets('etiket ve açıklama AYRI AYRI animasyonlanmaz', (tester) async {
      await pumpHost(
        tester,
        OnboardingOptionCard(
          label: 'Sakin tempo',
          description: 'Günde birkaç dakika',
          selected: false,
          onTap: () {},
        ),
      );

      // Karttaki tek geçiş noktası seçim işaretidir.
      expect(
        find.descendant(
          of: find.byType(OnboardingOptionCard),
          matching: find.byType(AppMotionSwitcher),
        ),
        findsOneWidget,
      );
    });

    testWidgets('hızlı art arda seçim son duruma OTURUR', (tester) async {
      var selected = false;
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) => OnboardingOptionCard(
            label: "Kur'an alışkanlığı",
            selected: selected,
            onTap: () => setState(() => selected = !selected),
          ),
        ),
      );

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(OnboardingOptionCard));
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pumpAndSettle();

      // Tek sayıda dokunuş → seçili; ara kareler durumu bozmaz.
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNothing);
    });
  });

  group("Kur'an ses düğmesi", () {
    testWidgets('yükleme hâli dokunuşu ANINDA kilitler', (tester) async {
      var presses = 0;
      await pumpHost(
        tester,
        AppButton(label: 'Dinle', isLoading: true, onPressed: () => presses++),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Dinle'), findsNothing);

      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.pump();

      expect(presses, 0, reason: 'çift oynatma isteği engellenir');
    });

    testWidgets('dinle → yükleniyor → duraklat geçişi net biter', (
      tester,
    ) async {
      await pumpHost(tester, AppButton(label: 'Dinle', onPressed: () {}));
      expect(find.text('Dinle'), findsOneWidget);

      await pumpHost(
        tester,
        AppButton(label: 'Dinle', isLoading: true, onPressed: () {}),
      );
      // Geçiş bittikten sonra eski içerik KALMAZ (sonsuz dönen gösterge
      // yüzünden `pumpAndSettle` kullanılamaz).
      await tester.pump(AppMotion.stateChange);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Dinle'), findsNothing);

      await pumpHost(tester, AppButton(label: 'Duraklat', onPressed: () {}));
      await tester.pump(AppMotion.stateChange);
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('Duraklat'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('geçiş basmayı GECİKTİRMEZ', (tester) async {
      var presses = 0;
      await pumpHost(
        tester,
        AppButton(label: 'Dinle', onPressed: () => presses++),
      );
      // Henüz hiç geçiş oturmamışken bile buton basılabilir.
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(presses, 1);
    });
  });

  group('RTL ve büyük yazı', () {
    testWidgets('Arapça yerelde yön RTL çözülür ve işaretler bozulmaz', (
      tester,
    ) async {
      await pumpHost(
        tester,
        taskCard(completed: true),
        locale: SupportedLocale.ar,
      );
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(TodayPlanTaskCard))),
        TextDirection.rtl,
      );
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Türkçe yerelde yön LTR kalır', (tester) async {
      await pumpHost(tester, taskCard(completed: true));
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(TodayPlanTaskCard))),
        TextDirection.ltr,
      );
    });

    testWidgets('RTL + 1.5x yazı dar ekranda TAŞMAZ', (tester) async {
      await pumpHost(
        tester,
        Column(
          children: [
            taskCard(completed: false),
            OnboardingOptionCard(
              label: 'اختيار',
              description: 'وصف قصير',
              selected: true,
              onTap: () {},
            ),
          ],
        ),
        locale: SupportedLocale.ar,
        size: const Size(320, 700),
        textScale: 1.5,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

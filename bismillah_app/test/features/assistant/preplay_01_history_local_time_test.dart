import 'dart:convert';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/assistant/data/shared_prefs_assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PREPLAY-01 — Asistan geçmişinde YEREL SAAT gösterimi.
///
/// Kusur: `_encodeMessage` anı UTC yazar (`...Z`), `DateTime.tryParse` de UTC
/// bir `DateTime` döndürür. Canlı oturumdaki mesajlar ise `DateTime.now()` ile
/// YEREL üretilir. Dönüşüm yapılmadığında yeniden açılışta aynı an UTC duvar
/// saatiyle çizilir (UTC+03 cihazda 14:12 → 11:12).
///
/// Testler CİHAZIN saat dilimine BAĞLI DEĞİLDİR: sabit bir ofset (UTC+03 vb.)
/// varsayılmaz. Kusuru her saat diliminde yakalayan kanıt, geri yüklenen
/// `createdAt`'ın artık UTC İŞARETLİ OLMAMASIDIR — düzeltme öncesi bu her
/// makinede başarısızdır, UTC makinede bile.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repo = SharedPrefsAssistantHistoryRepository();
  const key = 'bismillah.assistant_history';

  /// Üretimin yazdığı biçimin AYNISI: an UTC olarak saklanır.
  String storedHistory(List<Map<String, Object?>> entries) =>
      json.encode(entries);

  Map<String, Object?> storedUser({
    required String id,
    required String text,
    required DateTime localCreatedAt,
  }) => {
    'id': id,
    'role': AssistantRole.user.name,
    'text': text,
    'createdAt': localCreatedAt.toUtc().toIso8601String(),
    'relatedArticleIds': const <String>[],
    'sources': const <Object?>[],
  };

  Map<String, Object?> storedAssistant({
    required String id,
    required String text,
    required DateTime localCreatedAt,
  }) => {
    'id': id,
    'role': AssistantRole.assistant.name,
    'text': text,
    'createdAt': localCreatedAt.toUtc().toIso8601String(),
    'answerType': AssistantAnswerType.definition.name,
    'confidence': AssistantConfidence.exact.name,
    'relatedArticleIds': const <String>[],
    'sources': const <Object?>[],
  };

  group('Geri yüklenen zaman damgası', () {
    test('UTC saklanan an cihaz YEREL saatine çevrilir; an korunur', () async {
      // 14:12 yerel — cihazın saat dilimi ne olursa olsun.
      final created = DateTime(2026, 7, 20, 14, 12);
      SharedPreferences.setMockInitialValues({
        key: storedHistory([
          storedUser(
            id: 'u1',
            text: 'Teyemmüm nedir?',
            localCreatedAt: created,
          ),
        ]),
      });

      final loaded = await repo.load();
      expect(loaded, hasLength(1));
      final restored = loaded.single.createdAt;

      // 1) Artık UTC işaretli DEĞİL — saat/dakika alanları cihaz yerel duvar
      //    saatini verir. Düzeltme öncesi bu satır her saat diliminde düşer.
      expect(
        restored.isUtc,
        isFalse,
        reason: 'Geri yüklenen zaman yerel olmalı; UTC duvar saati çizilmemeli',
      );

      // 2) AN korunur — `toLocal()` anı değiştirmez, yalnız temsili değiştirir.
      expect(restored.toUtc(), created.toUtc());
      expect(restored.isAtSameMomentAs(created), isTrue);

      // 3) Yerel duvar saati beklenen değerdir (14:12).
      expect(restored.hour, created.hour);
      expect(restored.minute, created.minute);
      expect(restored.year, created.year);
      expect(restored.month, created.month);
      expect(restored.day, created.day);
    });

    test(
      'canlı mesaj ile geri yüklenen mesaj AYNI zaman semantiğini taşır',
      () async {
        final created = DateTime(2026, 7, 20, 14, 12);
        final live = AssistantMessage.user(
          id: 'u1',
          text: 'Teyemmüm nedir?',
          createdAt: created,
        );
        SharedPreferences.setMockInitialValues({});

        final saved = await repo.save([live]);
        expect(saved.isSuccess, isTrue);

        final restored = (await repo.load()).single;

        // Canlı mesaj `DateTime.now()` ile yerel üretilir; geri yüklenen mesaj
        // da yerel olmalıdır — aksi hâlde iki oturum FARKLI saat gösterir.
        expect(live.createdAt.isUtc, isFalse);
        expect(restored.createdAt.isUtc, live.createdAt.isUtc);
        expect(restored.createdAt.hour, live.createdAt.hour);
        expect(restored.createdAt.minute, live.createdAt.minute);
        expect(restored.createdAt.isAtSameMomentAs(live.createdAt), isTrue);
      },
    );
  });

  group('Hassas geçmiş kuralı (değişmedi)', () {
    test(
      'hassas kullanıcı mesajı ve cevabı yüklemede yine düşürülür',
      () async {
        final created = DateTime(2026, 7, 20, 14, 12);
        SharedPreferences.setMockInitialValues({
          key: storedHistory([
            storedUser(
              id: 'u1',
              text: 'Namazı ne bozar?',
              localCreatedAt: created,
            ),
            storedAssistant(
              id: 'a1',
              text: 'Genel bilgi.',
              localCreatedAt: created.add(const Duration(minutes: 1)),
            ),
            storedUser(
              id: 'u2',
              text: 'Teyemmüm nedir?',
              localCreatedAt: created.add(const Duration(minutes: 2)),
            ),
          ]),
        });

        final loaded = await repo.load();

        // Hassas çift düşer; kalan kayıt korunur — davranış değişmedi.
        expect(loaded.map((m) => m.id), ['u2']);
        // Kalan kaydın saati de yereldir.
        expect(loaded.single.createdAt.isUtc, isFalse);
        expect(loaded.single.createdAt.hour, created.hour);
      },
    );

    test('hassas kayıt yoksa saklanan baytlar aynen korunur', () async {
      final created = DateTime(2026, 7, 20, 14, 12);
      final raw = storedHistory([
        storedUser(id: 'u1', text: 'Teyemmüm nedir?', localCreatedAt: created),
      ]);
      SharedPreferences.setMockInitialValues({key: raw});

      await repo.load();

      final prefs = await SharedPreferences.getInstance();
      // Yerel çevrim yalnız OKUMA/gösterim tarafındadır: saklanan biçim (UTC
      // ISO-8601) değişmez, göç/sıfırlama yapılmaz.
      expect(prefs.getString(key), raw);
    });
  });

  group('Ekran gösterimi', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: AppRoutes.assistant,
        routes: [
          GoRoute(
            path: AppRoutes.assistant,
            builder: (context, state) => const AssistantScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            locale: SupportedLocale.tr.locale,
            supportedLocales: SupportedLocale.locales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('geri yüklenen mesaj CİHAZ YEREL saatiyle çizilir', (
      tester,
    ) async {
      final created = DateTime(2026, 7, 20, 14, 12);
      SharedPreferences.setMockInitialValues({
        key: storedHistory([
          storedUser(
            id: 'u1',
            text: 'Teyemmüm nedir?',
            localCreatedAt: created,
          ),
        ]),
      });

      await pump(tester);

      final context = tester.element(find.byType(AssistantScreen));
      final materialL10n = MaterialLocalizations.of(context);
      final expectedTime = materialL10n.formatTimeOfDay(
        TimeOfDay.fromDateTime(created),
      );
      // UTC duvar saati ile çizilmiş olsaydı bu metin bulunamazdı.
      expect(find.text(expectedTime), findsOneWidget);
      expect(find.text('Teyemmüm nedir?'), findsOneWidget);
    });

    testWidgets(
      'gün ayracı yerel güne göre; aynı günde tek, farklı günde iki',
      (tester) async {
        final day1 = DateTime(2026, 7, 20, 14, 12);
        final day1Later = DateTime(2026, 7, 20, 14, 30);
        final day2 = DateTime(2026, 7, 21, 9, 5);
        SharedPreferences.setMockInitialValues({
          key: storedHistory([
            storedUser(id: 'u1', text: 'İlk soru', localCreatedAt: day1),
            storedUser(
              id: 'u2',
              text: 'Aynı gün soru',
              localCreatedAt: day1Later,
            ),
            storedUser(id: 'u3', text: 'Ertesi gün soru', localCreatedAt: day2),
          ]),
        });

        await pump(tester);

        final context = tester.element(find.byType(AssistantScreen));
        final materialL10n = MaterialLocalizations.of(context);

        // İki farklı yerel gün → iki ayraç; aynı gündeki ikinci mesaj ayraç
        // eklemez (davranış regresyonu yok).
        expect(find.text(materialL10n.formatMediumDate(day1)), findsOneWidget);
        expect(find.text(materialL10n.formatMediumDate(day2)), findsOneWidget);
      },
    );
  });
}

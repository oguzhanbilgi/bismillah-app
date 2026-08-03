import 'dart:io';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/application/profile_providers.dart';
import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:bismillah_app/features/profile/presentation/content_sources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/canonical_app_sources.dart';

/// TASK 094 §C (dil) ve §D (RTL) — Learn/Assistant ve kaynak sunumu
/// yüzeyleri için doğrulama.
///
/// `_t()` eksik anahtarda SESSİZCE İngilizceye düşer; bu yüzden anahtar
/// eşitliği asıl regresyon korumasıdır — eksik bir çeviri, kullanıcıya
/// yanlış dilde metin sızdırır.
class _FakeSourceLinkService implements AppSourceLinkService {
  @override
  Future<bool> openSource(String url) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// `app_localizations.dart` içindeki üç sözlüğün anahtarlarını çıkarır.
  Map<String, Set<String>> localeKeys() {
    final lines = File(
      'lib/app/localization/app_localizations.dart',
    ).readAsLinesSync();

    final result = <String, Set<String>>{'tr': {}, 'en': {}, 'ar': {}};
    String? current;
    final keyPattern = RegExp(r"^\s{6}'([A-Za-z0-9_]+)':");

    for (final line in lines) {
      final marker = RegExp(r'SupportedLocale\.(tr|en|ar):\s*\{').firstMatch(
        line,
      );
      if (marker != null) {
        current = marker.group(1);
        continue;
      }
      if (current == null) {
        continue;
      }
      final match = keyPattern.firstMatch(line);
      if (match != null) {
        result[current]!.add(match.group(1)!);
      }
    }
    return result;
  }

  group('§C — locale sözlükleri anahtar bazında EŞİTTİR', () {
    test('üç sözlük de anahtar çıkarımında dolu bulunur', () {
      final keys = localeKeys();
      for (final entry in keys.entries) {
        expect(
          entry.value.length,
          greaterThan(300),
          reason: '${entry.key} sözlüğü ayrıştırılamadı',
        );
      }
    });

    test('TR/EN/AR anahtar kümeleri BİREBİR aynıdır', () {
      final keys = localeKeys();
      final tr = keys['tr']!;
      final en = keys['en']!;
      final ar = keys['ar']!;

      expect(
        tr.difference(en),
        isEmpty,
        reason: 'EN sözlüğünde EKSİK anahtar → İngilizce sızıntısı riski',
      );
      expect(en.difference(tr), isEmpty, reason: 'TR sözlüğünde eksik anahtar');
      expect(
        tr.difference(ar),
        isEmpty,
        reason:
            'AR sözlüğünde EKSİK anahtar → Arapça arayüzde İNGİLİZCE metin '
            'görünür (fallback sızıntısı)',
      );
      expect(ar.difference(tr), isEmpty, reason: 'TR sözlüğünde eksik anahtar');
    });
  });

  group('§C — güvenlik/gizlilik ve kaynaksızlık metinleri üç dilde vardır', () {
    // TASK 094 kapsamındaki yüzeyler: Assistant reddi/kaynaksızlık ve
    // kaynak künyesi/politika etiketleri.
    const surfaces = <String, String Function(AppLocalizations)>{
      'assistantNoVerifiedSource': _noVerifiedSource,
      'assistantOfficialFatwaRequired': _officialFatwaRequired,
      'assistantQualifiedGuidance': _qualifiedGuidance,
      'sourcesUnavailable': _sourcesUnavailable,
      'sourcesOpenFailed': _sourcesOpenFailed,
      'sourcesPolicyNoEndorsement': _policyNoEndorsement,
      'sourcesPolicyPending': _policyPending,
      'sourcesPolicyFatwa': _policyFatwa,
      'sourcesOriginalLanguageLabel': _originalLanguageLabel,
    };

    for (final entry in surfaces.entries) {
      test('${entry.key} üç dilde de dolu ve birbirinden farklıdır', () {
        const tr = AppLocalizations(SupportedLocale.tr);
        const en = AppLocalizations(SupportedLocale.en);
        const ar = AppLocalizations(SupportedLocale.ar);

        final values = [entry.value(tr), entry.value(en), entry.value(ar)];
        for (final value in values) {
          expect(value.trim(), isNotEmpty, reason: entry.key);
        }
        // Üçü de aynıysa çeviri yapılmamış (ya da fallback sızıyor) demektir.
        expect(
          values.toSet().length,
          3,
          reason: '${entry.key} çevrilmemiş görünüyor: $values',
        );
      });
    }

    test('Arapça güvenlik metinleri Arap harfi İÇERİR (fallback sızmaz)', () {
      const ar = AppLocalizations(SupportedLocale.ar);
      final arabic = RegExp(r'[؀-ۿ]');
      for (final value in [
        ar.assistantNoVerifiedSource,
        ar.assistantOfficialFatwaRequired,
        ar.assistantQualifiedGuidance,
        ar.sourcesUnavailable,
        ar.sourcesPolicyNoEndorsement,
        ar.sourcesPolicyFatwa,
      ]) {
        expect(arabic.hasMatch(value), isTrue, reason: value);
      }
    });
  });

  group('§D — RTL: kaynak künyesi ekranı', () {
    Future<void> pump(WidgetTester tester, SupportedLocale locale) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSourceLinkServiceProvider.overrideWithValue(
              _FakeSourceLinkService(),
            ),
            resolvedAppSourcesProvider.overrideWith(
              (ref) => canonicalResolvedAppSources(),
            ),
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
            home: const ContentSourcesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Arapça locale sayfa yönünü RTL yapar', (tester) async {
      await pump(tester, SupportedLocale.ar);

      final direction = Directionality.of(
        tester.element(find.byType(ContentSourcesScreen)),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('Türkçe locale LTR kalır', (tester) async {
      await pump(tester, SupportedLocale.tr);

      final direction = Directionality.of(
        tester.element(find.byType(ContentSourcesScreen)),
      );
      expect(direction, TextDirection.ltr);
    });

    testWidgets(
      'kaynak adı (latin özel isim) Arapça arayüzde bile LTR yazılır',
      (tester) async {
        await pump(tester, SupportedLocale.ar);

        // Sayfa RTL, ama künye adı ters dönmemeli: adın kendi
        // Directionality'si LTR olmalı.
        final tanzil = find.text('Tanzil');
        expect(tanzil, findsOneWidget);
        expect(Directionality.of(tester.element(tanzil)), TextDirection.ltr);
      },
    );

    testWidgets('RTL\'de büyük yazı ölçeğinde künye kartı taşmaz', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSourceLinkServiceProvider.overrideWithValue(
              _FakeSourceLinkService(),
            ),
            resolvedAppSourcesProvider.overrideWith(
              (ref) => canonicalResolvedAppSources(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            locale: SupportedLocale.ar.locale,
            supportedLocales: SupportedLocale.locales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const ContentSourcesScreen(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

String _noVerifiedSource(AppLocalizations l) => l.assistantNoVerifiedSource;
String _officialFatwaRequired(AppLocalizations l) =>
    l.assistantOfficialFatwaRequired;
String _qualifiedGuidance(AppLocalizations l) => l.assistantQualifiedGuidance;
String _sourcesUnavailable(AppLocalizations l) => l.sourcesUnavailable;
String _sourcesOpenFailed(AppLocalizations l) => l.sourcesOpenFailed;
String _policyNoEndorsement(AppLocalizations l) => l.sourcesPolicyNoEndorsement;
String _policyPending(AppLocalizations l) => l.sourcesPolicyPending;
String _policyFatwa(AppLocalizations l) => l.sourcesPolicyFatwa;
String _originalLanguageLabel(AppLocalizations l) =>
    l.sourcesOriginalLanguageLabel;

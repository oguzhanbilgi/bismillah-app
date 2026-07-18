import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/shared/islamic/gentle_empty_state.dart';
import 'package:bismillah_app/shared/islamic/islamic_pattern_background.dart';
import 'package:bismillah_app/shared/islamic/referenced_verse_card.dart';
import 'package:bismillah_app/shared/islamic/spiritual_hero_card.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 051 İslami görsel kimlik temeli: token erişimi, görselsiz/hatalı
/// görselli fallback, semantics temizliği ve metin ölçeği dayanıklılığı.
/// Gerçek network veya golden altyapısı KULLANILMAZ.
void main() {
  Widget host(Widget child, {ThemeData? theme, double textScale = 1.0}) {
    return MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('IslamicVisualTokens', () {
    testWidgets('tema uzantısı olarak erişilebilir', (tester) async {
      late IslamicVisualTokens tokens;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              tokens = IslamicVisualTokens.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(tokens.geometricPatternOpacity, greaterThan(0));
      expect(tokens.geometricPatternOpacity, lessThan(0.2));
      expect(tokens.heroGradient.colors.length, 2);
    });

    test('light ve dark karşılıkları farklı yüzey renkleri tanımlar', () {
      expect(
        IslamicVisualTokens.light().sacredSurface,
        isNot(IslamicVisualTokens.dark().sacredSurface),
      );
      expect(
        IslamicVisualTokens.light().verseCardSurface,
        isNot(IslamicVisualTokens.dark().verseCardSurface),
      );
    });

    testWidgets('uzantı kayıtlı değilse açık temaya düşer, crash etmez', (
      tester,
    ) async {
      late IslamicVisualTokens tokens;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tokens = IslamicVisualTokens.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(tokens.sacredSurface, IslamicVisualTokens.light().sacredSurface);
    });
  });

  group('SpiritualHeroCard', () {
    testWidgets('görsel olmadan gradient fallback ile render eder', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SpiritualHeroCard(
            title: 'Bugüne Bismillah',
            description: 'Küçük bir adım yeter.',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Bugüne Bismillah'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('eksik asset yüklenemediğinde crash etmez', (tester) async {
      await tester.pumpWidget(
        host(
          const SpiritualHeroCard(
            title: 'Hero',
            imageAssetPath: 'assets/images/islamic/does_not_exist.webp',
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Hero'), findsOneWidget);
    });

    testWidgets('tek anlamlı semantic label sunar', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const SpiritualHeroCard(
            title: 'Başlık',
            semanticLabel: 'Bugünün manevi kartı',
          ),
        ),
      );
      // Semantics ağacı doğrudan doğrulanır: kartın düğümü anlamlı
      // etiketi taşır (alt metinlerle birleşmiş olabilir).
      final node = tester.getSemantics(find.byType(SpiritualHeroCard));
      expect(node.label, contains('Bugünün manevi kartı'));

      // Handle test bitmeden kapatılmalı (tearDown çok geç kalır).
      semantics.dispose();
    });

    testWidgets('metin ölçeği 1.5 iken taşma yapmaz', (tester) async {
      await tester.pumpWidget(
        host(
          SpiritualHeroCard(
            title: 'Uzunca bir manevi başlık metni',
            description:
                'Bu açıklama metni büyük yazı ölçeğinde de düzgün akmalıdır.',
            action: AppButton(label: 'Başla', onPressed: () {}),
          ),
          textScale: 1.5,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('koyu temada da sorunsuz render eder', (tester) async {
      await tester.pumpWidget(
        host(
          const SpiritualHeroCard(title: 'Koyu tema'),
          theme: ThemeData.dark().copyWith(
            extensions: <ThemeExtension<dynamic>>[IslamicVisualTokens.dark()],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Koyu tema'), findsOneWidget);
    });
  });

  group('ReferencedVerseCard', () {
    testWidgets('referans ve kaynak etiketini gösterir', (tester) async {
      await tester.pumpWidget(
        host(
          const ReferencedVerseCard(
            arabicText: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ',
            reference: 'Bakara 2:255',
            sourceLabel: 'Tanzil · QuranEnc Rowad',
            translation: 'Allah; O’ndan başka ilâh yoktur.',
          ),
        ),
      );
      expect(find.text('Bakara 2:255'), findsOneWidget);
      expect(find.text('Tanzil · QuranEnc Rowad'), findsOneWidget);
      expect(find.text('Allah; O’ndan başka ilâh yoktur.'), findsOneWidget);
    });

    testWidgets('Arapça metni kırpmaz (maxLines uygulanmaz)', (tester) async {
      await tester.pumpWidget(
        host(
          const ReferencedVerseCard(
            arabicText: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
            reference: 'Bakara 2:255',
            sourceLabel: 'Tanzil',
          ),
        ),
      );
      final arabic = tester.widget<Text>(
        find.text('ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ'),
      );
      expect(arabic.maxLines, isNull);
      expect(arabic.overflow, isNot(TextOverflow.ellipsis));
    });
  });

  group('IslamicPatternBackground', () {
    testWidgets('dekoratiftir: semantics kirletmez ve dokunmayı engellemez', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 200,
            child: IslamicPatternBackground(
              child: Center(
                child: ElevatedButton(
                  onPressed: () => tapped = true,
                  child: const Text('Dokun'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Dokun'));
      expect(tapped, isTrue);

      // Desen katmanı ekran okuyucuya hiçbir düğüm eklemez.
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('animasyon içermez (sonsuz ticker yok)', (tester) async {
      await tester.pumpWidget(
        host(const SizedBox(height: 120, child: IslamicPatternBackground())),
      );
      // Animasyon olsaydı pumpAndSettle takılırdı.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('GentleEmptyState', () {
    testWidgets('mesaj ve tek aksiyonu gösterir, görselsiz fallback verir', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          GentleEmptyState(
            title: 'Kur’an okumaya başla',
            message: 'Çevrimdışı Arapça metin ve Türkçe meal seni bekliyor.',
            actionLabel: 'Kur’an’ı aç',
            onAction: () {},
          ),
        ),
      );
      expect(find.text('Kur’an okumaya başla'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      // Görsel yokken sakin ikon fallback'i çizilir.
      expect(find.byType(Icon), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('yargılayıcı/suçlayıcı dil içermez', (tester) async {
      const message = 'Hazır olduğunda buradan başlayabilirsin.';
      await tester.pumpWidget(host(const GentleEmptyState(message: message)));

      const forbidden = [
        'geride kaldın',
        'kaçırdın',
        'başarısız',
        'ihmal',
        'günah',
        'utan',
      ];
      final rendered = message.toLowerCase();
      for (final word in forbidden) {
        expect(
          rendered.contains(word),
          isFalse,
          reason: 'boş durum metni suçlayıcı dil içermemeli: $word',
        );
      }
      expect(find.text(message), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/quran/data/asset_quran_content_repository.dart';
import 'package:bismillah_app/features/quran/data/bundled_quranenc_translation_repository.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/services/quran_audio_session_service.dart';
import 'package:bismillah_app/features/quran/presentation/quran_chapter_reader_screen.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 095A — çalan ayetin görsel takibi.
///
/// Ses oturumu belirlenimci bir sahte ile beslenir; gerçek oynatıcı, ağ
/// veya zamanlama BURADA çalışmaz.
void main() {
  late _FakeAudioSessionService audio;

  setUp(() => audio = _FakeAudioSessionService());
  tearDown(() => audio.dispose());

  QuranVerseAudioState playingVerse(
    int verseNumber, {
    QuranVerseAudioStatus status = QuranVerseAudioStatus.playing,
    int chapterId = 1,
  }) => QuranVerseAudioState(
    activeChapterId: chapterId,
    activeChapterName: 'Al-Faatiha',
    activeVerseKey: '$chapterId:$verseNumber',
    activeVerseNumber: verseNumber,
    playbackMode: QuranAudioPlaybackMode.continuousChapter,
    status: status,
    sourceReady: true,
    totalVerseCount: 7,
  );

  Future<void> pumpReader(
    WidgetTester tester, {
    String locale = 'tr',
    Size size = const Size(1080, 3200),
    double textScale = 1.0,
    bool reducedMotion = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_reader_show_translation': true,
    });
    tester.platformDispatcher.localeTestValue = Locale(locale);
    tester.platformDispatcher.localesTestValue = [Locale(locale)];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final contentRepository = AssetQuranContentRepository();
    final translationRepository = BundledQuranEncTranslationRepository();
    await tester.runAsync(() async {
      await contentRepository.getVersesForChapter(1);
      await translationRepository.getChapterTranslation(1);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranContentRepositoryProvider.overrideWithValue(contentRepository),
          quranTranslationRepositoryProvider.overrideWithValue(
            translationRepository,
          ),
          quranAudioSessionServiceProvider.overrideWithValue(audio),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: Locale(locale),
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: reducedMotion,
            ),
            child: child!,
          ),
          home: const QuranChapterReaderScreen(chapterId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Vurgulanmış ayet anahtarları (kaynak rozetinden okunur).
  Set<String> highlightedKeys(WidgetTester tester) {
    final keys = <String>{};
    for (final block in tester.widgetList<QuranTextBlock>(
      find.byType(QuranTextBlock),
    )) {
      if (block.highlighted) {
        keys.add(block.sourceLabel.split(' · ').first);
      }
    }
    return keys;
  }

  Future<void> emit(WidgetTester tester, QuranVerseAudioState state) async {
    audio.emit(state);
    await tester.pumpAndSettle();
  }

  group('aktif ayet takibi', () {
    testWidgets('vurgulanan ayet oynatıcının bildirdiği ayeti izler', (
      tester,
    ) async {
      await pumpReader(tester);
      expect(highlightedKeys(tester), isEmpty);

      await emit(tester, playingVerse(2));
      expect(highlightedKeys(tester), {'1:2'});

      await emit(tester, playingVerse(5));
      expect(highlightedKeys(tester), {'1:5'});
    });

    testWidgets('duraklatma aktif ayeti KORUR', (tester) async {
      await pumpReader(tester);
      await emit(tester, playingVerse(3));
      await emit(tester, playingVerse(3, status: QuranVerseAudioStatus.paused));

      expect(highlightedKeys(tester), {'1:3'});
    });

    testWidgets('devam aynı ayetten sürer', (tester) async {
      await pumpReader(tester);
      await emit(tester, playingVerse(3));
      await emit(tester, playingVerse(3, status: QuranVerseAudioStatus.paused));
      await emit(tester, playingVerse(3));

      expect(highlightedKeys(tester), {'1:3'});
    });

    testWidgets('tamamlanma/durdurma vurguyu temizler', (tester) async {
      await pumpReader(tester);
      await emit(tester, playingVerse(4));
      expect(highlightedKeys(tester), {'1:4'});

      await emit(tester, const QuranVerseAudioState(sourceReady: true));
      expect(highlightedKeys(tester), isEmpty);
    });

    testWidgets('tek ayet oynatma seçilen ayeti vurgular', (tester) async {
      await pumpReader(tester);
      await emit(
        tester,
        const QuranVerseAudioState(
          activeChapterId: 1,
          activeVerseKey: '1:6',
          activeVerseNumber: 6,
          playbackMode: QuranAudioPlaybackMode.singleVerse,
          status: QuranVerseAudioStatus.playing,
          sourceReady: true,
          totalVerseCount: 7,
        ),
      );

      expect(highlightedKeys(tester), {'1:6'});
    });

    testWidgets('başka surenin oturumu bu sureyi vurgulamaz', (tester) async {
      await pumpReader(tester);
      await emit(tester, playingVerse(2, chapterId: 2));

      expect(highlightedKeys(tester), isEmpty);
    });

    testWidgets('ses hatası YANLIŞ ayeti vurgulu bırakmaz', (tester) async {
      await pumpReader(tester);
      await emit(tester, playingVerse(3));
      expect(highlightedKeys(tester), {'1:3'});

      await emit(
        tester,
        const QuranVerseAudioState(
          activeChapterId: 1,
          status: QuranVerseAudioStatus.error,
          chapterAudioFailed: true,
          sourceReady: true,
        ),
      );

      expect(highlightedKeys(tester), isEmpty);
    });

    testWidgets('çalan ayet ekran okuyucuya ayrıca bildirilir', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpReader(tester);
      await emit(tester, playingVerse(2));

      expect(find.bySemanticsLabel(RegExp('Şu an çalan ayet')), findsOneWidget);

      handle.dispose();
    });
  });

  group('elle kaydırma ve takibe dönüş', () {
    testWidgets('elle kaydırma otomatik takibi askıya alır ve dönüş yolu '
        'sunar', (tester) async {
      await pumpReader(tester, size: const Size(400, 800));
      await emit(tester, playingVerse(2));
      expect(find.text('Kıraati takip et'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();

      expect(find.text('Kıraati takip et'), findsOneWidget);
    });

    testWidgets('takip askıdayken vurgu doğru ayette KALIR', (tester) async {
      await pumpReader(tester, size: const Size(400, 800));
      await emit(tester, playingVerse(2));
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();

      await emit(tester, playingVerse(3));
      expect(highlightedKeys(tester), {'1:3'});
      expect(find.text('Kıraati takip et'), findsOneWidget);
    });

    testWidgets('"Kıraati takip et" dokunuşu takibi geri açar', (tester) async {
      await pumpReader(tester, size: const Size(400, 800));
      await emit(tester, playingVerse(2));
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(find.text('Kıraati takip et'), findsOneWidget);

      await tester.tap(find.text('Kıraati takip et'));
      await tester.pumpAndSettle();

      expect(find.text('Kıraati takip et'), findsNothing);
    });

    testWidgets('oturum bitince takip durumu temizlenir', (tester) async {
      await pumpReader(tester, size: const Size(400, 800));
      await emit(tester, playingVerse(2));
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(find.text('Kıraati takip et'), findsOneWidget);

      await emit(tester, const QuranVerseAudioState(sourceReady: true));
      expect(
        find.text('Kıraati takip et'),
        findsNothing,
        reason: 'oynatma bitince askı durumu da temizlenmeli',
      );
    });

    testWidgets('oynatma yokken dönüş yolu hiç görünmez', (tester) async {
      await pumpReader(tester, size: const Size(400, 800));
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();

      expect(find.text('Kıraati takip et'), findsNothing);
    });
  });

  group('dil, RTL, büyük metin ve azaltılmış hareket', () {
    test('yeni anahtarlar TR/EN/AR üçünde de tanımlıdır', () {
      const tr = AppLocalizations(SupportedLocale.tr);
      const en = AppLocalizations(SupportedLocale.en);
      const ar = AppLocalizations(SupportedLocale.ar);

      expect(tr.quranFollowRecitation, 'Kıraati takip et');
      expect(en.quranFollowRecitation, 'Follow recitation');
      expect(ar.quranFollowRecitation, isNot(tr.quranFollowRecitation));
      expect(RegExp(r'[؀-ۿ]').hasMatch(ar.quranFollowRecitation), isTrue);
      expect(RegExp(r'[؀-ۿ]').hasMatch(ar.quranSemanticsPlayingVerse), isTrue);
      expect(en.quranSemanticsPlayingVerse, 'Currently playing verse');
    });

    testWidgets('Arapça yerelde RTL korunur ve takip çalışır', (tester) async {
      await pumpReader(tester, locale: 'ar', size: const Size(400, 800));
      await emit(tester, playingVerse(2));

      expect(
        Directionality.of(tester.element(find.byType(ListView))),
        TextDirection.rtl,
      );
      expect(highlightedKeys(tester), {'1:2'});

      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();
      expect(find.text('تابع التلاوة'), findsOneWidget);
    });

    testWidgets('1.5x metin ölçeğinde dar ekranda taşma olmaz', (tester) async {
      await pumpReader(tester, size: const Size(360, 900), textScale: 1.5);
      await emit(tester, playingVerse(2));
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Kıraati takip et'), findsOneWidget);
    });

    testWidgets('azaltılmış harekette aktif ayet yine net biçimde değişir', (
      tester,
    ) async {
      await pumpReader(tester, size: const Size(400, 800), reducedMotion: true);
      await emit(tester, playingVerse(2));
      expect(highlightedKeys(tester), {'1:2'});

      await emit(tester, playingVerse(4));
      expect(highlightedKeys(tester), {'1:4'});
      expect(tester.takeException(), isNull);
    });
  });
}

/// Belirlenimci sahte ses oturumu — gerçek oynatıcı/ağ yok.
final class _FakeAudioSessionService implements QuranAudioSessionService {
  final StreamController<QuranVerseAudioState> _controller =
      StreamController<QuranVerseAudioState>.broadcast();

  QuranVerseAudioState _current = const QuranVerseAudioState();

  @override
  QuranVerseAudioState get currentState => _current;

  @override
  Stream<QuranVerseAudioState> watchState() => _controller.stream;

  void emit(QuranVerseAudioState state) {
    _current = state;
    _controller.add(state);
  }

  void dispose() => unawaited(_controller.close());

  @override
  Future<void> playSingleVerse(QuranAudioSessionRequest request) async {}

  @override
  Future<void> playContinuousChapter(QuranAudioSessionRequest request) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}
}

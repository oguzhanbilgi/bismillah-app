import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/onboarding/presentation/widgets/onboarding_option_card.dart';
import 'package:bismillah_app/features/quran/application/quran_chapter_reader_providers.dart';
import 'package:bismillah_app/features/quran/application/quran_chapter_translation_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_reader_text_size_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_tracker.dart';
import 'package:bismillah_app/features/quran/application/quran_reciter_selection_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_settings_hint_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_show_translation_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_audio_controller.dart';
import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_translation.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_error_state.dart';
import 'package:bismillah_app/shared/widgets/app_loading.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sure okuyucu (TASK 035) — SALT-OKUNUR, doğrulanmış Uthmani Arapça
/// metin (Tanzil 1.1; kaynak atfı ekran sonunda ve her ayet bloğunda).
/// Meal/ses/yer imi/ilerleme kaydı YOK; işlevsiz buton YOK. Geçersiz
/// chapterId sakin hata durumudur — ekran kontrolsüz exception ile
/// KAPANMAZ, AppBar geri oku her durumda çalışır.
class QuranChapterReaderScreen extends ConsumerStatefulWidget {
  const QuranChapterReaderScreen({
    super.key,
    required this.chapterId,
    this.initialVerseNumber,
  });

  /// Route parametresinden çözülen sure numarası; `null` = bozuk parametre.
  final int? chapterId;

  /// Arama sonucundan hedef ayet (TASK 048, `?verse=`); geçersiz/aralık
  /// dışı değer sakin biçimde yok sayılır — sure normal açılır.
  final int? initialVerseNumber;

  @override
  ConsumerState<QuranChapterReaderScreen> createState() =>
      _QuranChapterReaderScreenState();
}

final class _QuranChapterReaderScreenState
    extends ConsumerState<QuranChapterReaderScreen> {
  /// Tt keşif göstergesi (TASK 044): görünürlük ekrana ait local state'tir;
  /// kalıcılık preference katmanındadır. OverlayEntry/timer KULLANILMAZ —
  /// gösterge Stack içinde çizilir, dispose'da sızıntı bırakmaz ve ekran
  /// ölçüsü değişince Positioned kendini yeniden konumlar.
  bool _settingsHintVisible = false;
  bool _settingsHintRequested = false;

  /// İçerik ilk frame'ini çizdikten SONRA göstergeyi bir kez dener.
  void _maybeShowSettingsHint() {
    if (_settingsHintRequested) {
      return;
    }
    _settingsHintRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final shouldShow = await ref.read(
        quranSettingsHintControllerProvider.future,
      );
      if (!mounted || !shouldShow) {
        return;
      }
      setState(() => _settingsHintVisible = true);
      // Yalnız OTURUM İÇİ işaret (TASK 045): aynı oturumda başka surede
      // tekrar çıkmaz ama kalıcı YAZILMAZ — kullanıcı göstergeyi
      // kapatmadan uygulama sonlanırsa sonraki açılışta yine gösterilir.
      ref
          .read(quranSettingsHintControllerProvider.notifier)
          .markShownForSession();
    });
  }

  /// Kullanıcı göstergeyi kapattı ("Anladım", dış dokunuş veya Tt):
  /// ancak ŞİMDİ kalıcı "görüldü" yazılır (TASK 045).
  void _dismissSettingsHint() {
    if (!_settingsHintVisible) {
      return;
    }
    setState(() => _settingsHintVisible = false);
    unawaited(
      ref
          .read(quranSettingsHintControllerProvider.notifier)
          .markSeenPermanently(),
    );
  }

  /// Tt aksiyonu: gösterge kapanır ve mevcut ayarlar paneli açılır.
  void _openReaderSettings() {
    _dismissSettingsHint();
    _showReaderSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.chapterId;
    if (id == null) {
      return AppScaffold(
        title: l10n.tabQuran,
        body: Center(
          child: AppText(
            l10n.quranReaderLoadIssue,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final chapterAsync = ref.watch(quranChapterProvider(id));
    final versesAsync = ref.watch(quranChapterVersesProvider(id));
    // Kayıtlı konum içerikle BİRLİKTE beklenir ki liste doğru offset'le
    // kurulsun; konum okuma hatası reader'ı BLOKLAMAZ (baştan açılır).
    final positionAsync = ref.watch(quranReadingPositionProvider);

    final chapter = chapterAsync.value;
    final contentReady =
        chapter != null && versesAsync.hasValue && !positionAsync.isLoading;
    if (contentReady) {
      // Gösterge yalnız Arapça içerik gerçekten render edildikten sonra
      // (post-frame) görünür — yapay gecikme yok (TASK 044).
      _maybeShowSettingsHint();
    }

    final bodyContent = switch ((chapterAsync, versesAsync)) {
      // Tanınmayan sure numarası: sakin durum + AppBar geri dönüşü.
      (AsyncData(value: null), _) => Center(
        child: AppText(
          l10n.quranReaderLoadIssue,
          token: AppTextStyleToken.bodySmall,
          secondary: true,
          textAlign: TextAlign.center,
        ),
      ),
      (AsyncData(value: final QuranChapter chapter), AsyncData())
          when !positionAsync.isLoading =>
        _ReaderBody(
          chapter: chapter,
          verses: versesAsync.value!,
          // Geçerli hedef ayet varsa (TASK 048) konum hedefe gider;
          // yoksa kayıtlı devam konumu davranışı AYNEN korunur.
          targetVerseNumber:
              widget.initialVerseNumber != null &&
                  widget.initialVerseNumber! >= 1 &&
                  widget.initialVerseNumber! <= versesAsync.value!.length
              ? widget.initialVerseNumber
              : null,
          // Kayıt başka sureye aitse baştan açılır (TASK 036).
          initialScrollOffset: switch (positionAsync.value) {
            _ when widget.initialVerseNumber != null => 0,
            final QuranReadingPosition saved when saved.chapterId == id =>
              saved.scrollOffset,
            _ => 0,
          },
        ),
      (AsyncError(), _) || (_, AsyncError()) => AppErrorState(
        message: l10n.quranReaderLoadIssue,
        retryLabel: l10n.commonRetry,
        onRetry: () {
          ref.invalidate(quranChapterProvider(id));
          ref.invalidate(quranChapterVersesProvider(id));
        },
      ),
      _ => AppLoading(label: l10n.commonLoading),
    };

    return AppScaffold(
      title: chapter?.transliteratedName ?? l10n.tabQuran,
      actions: [
        // Okuma ayarları (TASK 037/044): işlevsel tek aksiyon.
        IconButton(
          tooltip: l10n.quranReaderSettings,
          icon: const Icon(Icons.text_fields),
          onPressed: _openReaderSettings,
        ),
      ],
      // Translucent Listener: göstergenin DIŞINA yapılan herhangi bir
      // dokunuş onu kapatır; scroll ve diğer etkileşimler yutulmaz.
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _dismissSettingsHint(),
        child: Stack(
          children: [
            bodyContent,
            if (_settingsHintVisible)
              PositionedDirectional(
                top: AppSpacing.s1,
                end: AppSpacing.s3,
                child: _SettingsHintCard(onDismiss: _dismissSettingsHint),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tt butonunu işaret eden sakin keşif kartı (TASK 044) — modal değil,
/// içerik kaplamaz; token tabanlı renkler.
final class _SettingsHintCard extends StatelessWidget {
  const _SettingsHintCard({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AppBar'daki Tt aksiyonuna işaret eden küçük ok.
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.s4),
          child: Icon(
            Icons.arrow_drop_up,
            color: scheme.primary,
            size: AppSizes.iconLg,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.quranSettingsHint,
                  token: AppTextStyleToken.bodySmall,
                ),
                const SizedBox(height: AppSpacing.s3),
                AppButton(
                  label: l10n.commonGotIt,
                  variant: AppButtonVariant.secondary,
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.chapter,
    required this.verses,
    required this.initialScrollOffset,
    this.targetVerseNumber,
  });

  final QuranChapter chapter;
  final List<QuranVerse> verses;
  final double initialScrollOffset;

  /// Arama sonucundan doğrulanmış hedef ayet; ilk render sonrası scroll
  /// edilir ve sakin vurgulanır (TASK 048).
  final int? targetVerseNumber;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

final class _ReaderBodyState extends ConsumerState<_ReaderBody>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;

  /// Gerçek okuma takibi (TASK 047): reader başına TEK tracker. Görünür
  /// ayet tespiti için ayet öğelerine hafif GlobalKey verilir (yalnız
  /// build edilmiş öğeler yaşar) — 6236 widget/timer KURULMAZ.
  QuranReadingTracker? _tracker;
  final Map<String, GlobalKey> _verseItemKeys = {};

  /// Arama hedefi ayetin sakin vurgusu (TASK 048): hedefe ulaşınca
  /// gösterilir, ilk kullanıcı dokunuşunda kalkar — timer yok, bookmark/
  /// ses/progress durumuna DOKUNMAZ.
  String? _targetHighlightKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    );
    // Doğrulanmış ayet→sayfa eşlemesi asenkron bağlanır; yüklenemezse
    // yalnız sayfa işaretleme kapalı kalır (okuma süresi etkilenmez).
    unawaited(
      ref
          .read(quranVersePageRepositoryProvider)
          .pagesForChapter(widget.chapter.id)
          .then((result) {
            final pages = result.fold(
              onSuccess: (pages) => pages,
              onFailure: (_) => null,
            );
            if (mounted && pages != null) {
              _tracker?.attachVersePages(pages);
            }
          }),
    );
    // Kayıtlı offset içerikten uzunsa (farklı ekran boyutu vb.) ilk
    // frame'den sonra güvenle maksimuma çekilir — crash yok.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final max = _scrollController.position.maxScrollExtent;
      if (_scrollController.offset > max) {
        _scrollController.jumpTo(max);
      }
      final target = widget.targetVerseNumber;
      if (target != null) {
        unawaited(_scrollToTargetVerse(target));
      }
      // Açılıştaki birincil ayet — kullanıcı hiç kaydırmasa da dwell
      // ölçümü başlar.
      _reportPrimaryVerse();
    });
  }

  /// Hedef ayete kademeli scroll (TASK 048). Liste lazy olduğundan hedef
  /// öğe build edilene dek build edilmiş ayet aralığına göre doğru yönde
  /// viewport adımlarıyla ilerlenir; TASK 047'nin verse GlobalKey'leri
  /// kullanılır (ikinci key sistemi YOK). Hedef bulunamazsa sessizce
  /// vazgeçilir — sure normal açık kalır, crash yok.
  Future<void> _scrollToTargetVerse(int targetVerseNumber) async {
    final targetKey = '${widget.chapter.id}:$targetVerseNumber';
    for (var attempt = 0; attempt < 200; attempt++) {
      if (!mounted) {
        return;
      }
      final targetContext = _verseItemKeys[targetKey]?.currentContext;
      if (targetContext != null && targetContext.mounted) {
        await Scrollable.ensureVisible(
          targetContext,
          alignment: 0.15,
          duration: AppMotion.standard,
          curve: AppMotion.standardCurve,
        );
        if (mounted) {
          setState(() => _targetHighlightKey = targetKey);
        }
        return;
      }
      if (!_scrollController.hasClients) {
        await WidgetsBinding.instance.endOfFrame;
        continue;
      }
      // Build edilmiş ayet aralığı hedefin hangi yönde kaldığını söyler.
      int? minBuilt;
      int? maxBuilt;
      for (final entry in _verseItemKeys.entries) {
        if (entry.value.currentContext == null) {
          continue;
        }
        final number = int.tryParse(entry.key.split(':').last);
        if (number == null) {
          continue;
        }
        minBuilt = minBuilt == null || number < minBuilt ? number : minBuilt;
        maxBuilt = maxBuilt == null || number > maxBuilt ? number : maxBuilt;
      }
      final position = _scrollController.position;
      final step = position.viewportDimension * 1.5;
      final next = (maxBuilt == null || targetVerseNumber > maxBuilt)
          ? position.pixels + step
          : (minBuilt != null && targetVerseNumber < minBuilt)
          ? position.pixels - step
          : position.pixels + position.viewportDimension * 0.5;
      final clamped = next.clamp(0.0, position.maxScrollExtent);
      if ((clamped - position.pixels).abs() < 1) {
        return; // ilerleme yok — sessizce vazgeç
      }
      _scrollController.jumpTo(clamped);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  /// Uygulama lifecycle'ı: resumed dışında okuma süresi HEMEN duraklar
  /// (arka plan ses oynatımı süre SAYMAZ).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _tracker?.setAppResumed(state == AppLifecycleState.resumed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Shell sekme geçişinde reader mounted kalır ama offstage olur —
    // TickerMode bu görünürlüğün güvenilir sinyalidir.
    _tracker?.setScreenVisible(TickerMode.valuesOf(context).enabled);
  }

  /// Okuma bandındaki (viewport üst üçte birlik hizadaki) ayeti bulup
  /// tracker'a bildirir. Yalnız scroll bitiminde ve açılışta çalışır —
  /// kare başına maliyet YOK.
  void _reportPrimaryVerse() {
    final tracker = _tracker;
    final listRender = context.findRenderObject();
    if (tracker == null || listRender is! RenderBox || !listRender.hasSize) {
      return;
    }
    final bandY = listRender.size.height * 0.35;
    String? bestKey;
    var bestDistance = double.infinity;
    for (final entry in _verseItemKeys.entries) {
      final render = entry.value.currentContext?.findRenderObject();
      if (render is! RenderBox || !render.attached || !render.hasSize) {
        continue;
      }
      final top = render.localToGlobal(Offset.zero, ancestor: listRender).dy;
      final bottom = top + render.size.height;
      if (top <= bandY && bottom >= bandY) {
        bestKey = entry.key;
        break;
      }
      final distance = top > bandY ? top - bandY : bandY - bottom;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestKey = entry.key;
      }
    }
    if (bestKey != null) {
      tracker.reportPrimaryVerse(bestKey);
    }
  }

  /// Kaydırma BİTİNCE konumu kaydeder (her frame'de DEĞİL). Kayıt hatası
  /// sessizce yok sayılır — okuma deneyimi kesintiye uğramaz.
  void _savePosition(ScrollMetrics metrics) {
    final offset = metrics.pixels
        .clamp(0.0, metrics.maxScrollExtent)
        .toDouble();
    unawaited(
      ref
          .read(quranReadingPositionRepositoryProvider)
          .save(
            QuranReadingPosition(
              chapterId: widget.chapter.id,
              scrollOffset: offset,
              updatedAtUtc: ref.read(clockProvider).nowUtc(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verses = widget.verses;

    // Tracker provider'ı reader yaşadıkça canlı tutulur (autoDispose);
    // ekran kapanınca provider dispose'u birikmiş parçayı flush eder.
    // Tracker Notifier DEĞİLDİR — heartbeat UI'ı yeniden KURMAZ.
    _tracker = ref.watch(quranReadingTrackerProvider(widget.chapter.id));

    // Metin boyutu tercihi tüm ayetlere ANINDA uygulanır (TASK 037);
    // yalnız Arapça metin ölçeklenir, rozet/etiketler sabit kalır.
    final textSize =
        ref.watch(quranReaderTextSizeControllerProvider).value ??
        QuranArabicTextSize.medium;
    final blockSize = switch (textSize) {
      QuranArabicTextSize.small => QuranTextBlockSize.small,
      QuranArabicTextSize.medium => QuranTextBlockSize.medium,
      QuranArabicTextSize.large => QuranTextBlockSize.large,
    };

    final bookmarks =
        ref.watch(quranVerseBookmarksControllerProvider).value ??
        const QuranVerseBookmarksState(bookmarkedKeys: {});
    // Kayıt hatası: kısa, sakin mesaj — reader kapanmaz, durum geri alınır.
    ref.listen(quranVerseBookmarksControllerProvider, (previous, next) {
      final failure = next.value?.lastFailure;
      if (failure != null && previous?.value?.lastFailure == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (failure) {
              QuranBookmarkFailure.save => l10n.quranBookmarkSaveIssue,
              QuranBookmarkFailure.remove => l10n.quranBookmarkRemoveIssue,
            }),
          ),
        );
      }
    });

    // Diyanet meali (TASK 040): sure seviyesinde TEK durum — Arapça
    // içerik meal yüklenirken/hatalıyken de okunabilir kalır.
    final translationAsync = ref.watch(
      quranChapterTranslationProvider(widget.chapter.id),
    );
    final translationByKey = <String, String>{
      for (final verse
          in translationAsync.value?.verses ?? const <QuranVerseTranslation>[])
        verse.verseKey: verse.translationText,
    };

    // Ayet sesi (TASK 041/045): aktif ayet sakin vurgu alır. Global
    // oturum başka surede çalıyor olabilir — panel yalnız BU sureye ait
    // durumu yansıtır (ayet aksiyonları zaten verseKey ile süzülür).
    final audioState = ref.watch(quranVerseAudioControllerProvider);
    // Bildirim/kilit ekranı metadata'sı için doğrulanmış görüntü
    // metinleri (TASK 045): BuildContext servise TAŞINMAZ, istekle geçer.
    final audioDisplay = QuranAudioDisplayInfo(
      chapterDisplayName: widget.chapter.transliteratedName,
      reciterName: l10n.quranReciterName,
      rewayaName: l10n.quranRewayaName,
      albumName: l10n.appTitle,
      verseOfLabel: l10n.quranAudioVerseOf,
    );
    final scheme = Theme.of(context).colorScheme;

    // Header (0) + ayetler (1..n) + kaynak atfı (n+1); liste lazy kurulur.
    // Dış Listener (TASK 047): her dokunuş — scroll, ayet sesi, bookmark,
    // ayarlar — aktif okuma idle sayacını yeniler; dokunuşları YUTMAZ.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        _tracker?.noteInteraction();
        // Hedef ayet vurgusu ilk kullanıcı dokunuşunda sakinçe kalkar.
        if (_targetHighlightKey != null) {
          setState(() => _targetHighlightKey = null);
        }
      },
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          _savePosition(notification.metrics);
          // Scroll bitti: etkileşim + yeni birincil ayet sinyali. Hızlı
          // scroll'da aradaki ayet/sayfalar dwell eşiğini DOLDURMAZ.
          _tracker?.noteInteraction();
          _reportPrimaryVerse();
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: verses.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ChapterHeader(chapter: widget.chapter),
                  _ChapterPlaybackPanel(
                    chapterId: widget.chapter.id,
                    verseCount: verses.length,
                    audioState: audioState,
                    display: audioDisplay,
                  ),
                  _TranslationStatus(
                    chapterId: widget.chapter.id,
                    translationAsync: translationAsync,
                  ),
                  // Ses hazır olduktan sonra doğrulanmış kaynak künyesi:
                  // SEÇİLİ kârinin API'de doğrulanmış adı (TASK 049);
                  // rivayet etiketi yerelleşmiş sabittir (tümü Hafs).
                  if (audioState.sourceReady)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                      child: AppText(
                        '${l10n.quranAudioSourceLabel}: '
                        '${ref.watch(quranSelectedReciterProvider).value?.reciterName ?? l10n.quranReciterName}'
                        ' · ${l10n.quranRewayaName} · MP3Quran.net',
                        token: AppTextStyleToken.caption,
                        secondary: true,
                      ),
                    ),
                ],
              );
            }
            if (index == verses.length + 1) {
              return _SourceAttribution(l10n: l10n);
            }
            final verse = verses[index - 1];
            final isActiveVerse =
                audioState.activeVerseKey == verse.verseKey ||
                _targetHighlightKey == verse.verseKey;
            return Padding(
              // Birincil görünür ayet tespiti için hafif anahtar (TASK 047);
              // yalnız build edilmiş öğeler bellekte yaşar.
              key: _verseItemKeys.putIfAbsent(verse.verseKey, GlobalKey.new),
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              // TASK 055: her ayet AĞIR beyaz kart değil — sıcak yüzey +
              // ince token kenarlıkla sakin ayrım. Aktif ayet tonal
              // spiritualGreen yüzey + primary çerçeve alır ve YALNIZ
              // renkle değil, semantik durumla da işaretlenir (a11y).
              child: Semantics(
                selected: isActiveVerse,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: isActiveVerse
                          ? scheme.primary
                          : IslamicVisualTokens.of(context).surfaceBorder,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  // QuranTextBlock: RTL, geniş satır yüksekliği, kırpılamaz
                  // metin, zorunlu kaynak rozeti (no source, no render). Meal
                  // Arapça metnin hemen altında, boyut ayarından ETKİLENMEZ.
                  child: QuranTextBlock(
                    arabicText: verse.textUthmani,
                    sourceLabel: '${verse.verseKey} · Tanzil',
                    size: blockSize,
                    highlighted: isActiveVerse,
                    translation: translationByKey[verse.verseKey],
                    // Wrap: çok dar ekranda aksiyonlar taşmak yerine güvenle
                    // alt satıra kırılır (TASK 044).
                    footerAction: Wrap(
                      spacing: AppSpacing.s2,
                      runSpacing: AppSpacing.s1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.end,
                      children: [
                        _VerseAudioAction(
                          verse: verse,
                          expectedVerseCount: verses.length,
                          audioState: audioState,
                          display: audioDisplay,
                        ),
                        _VerseBookmarkAction(
                          bookmarked: bookmarks.isBookmarked(verse.verseKey),
                          onTap: () => ref
                              .read(
                                quranVerseBookmarksControllerProvider.notifier,
                              )
                              .toggle(verse.verseKey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Sure seviyesinde meal durumu (TASK 040): kompakt yükleme satırı,
/// sakin hata kartı (yalnız translation provider'ını yeniler) veya
/// doğrulanmış kaynak satırı. Meal kapalıyken hiçbir şey göstermez.
final class _TranslationStatus extends ConsumerWidget {
  const _TranslationStatus({
    required this.chapterId,
    required this.translationAsync,
  });

  final int chapterId;
  final AsyncValue<QuranChapterTranslation?> translationAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (translationAsync) {
      AsyncData(:final value) =>
        value == null
            ? const SizedBox.shrink() // meal tercihi kapalı
            : Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.quranTranslationRowadLine,
                      token: AppTextStyleToken.caption,
                      secondary: true,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      l10n.quranTranslationQuranEncLine,
                      token: AppTextStyleToken.caption,
                      secondary: true,
                    ),
                  ],
                ),
              ),
      AsyncError() => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.quranTranslationLoadIssue,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              AppButton(
                label: l10n.commonRetry,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  // Yalnız İLGİLİ surenin cache'i ve provider'ı yenilenir;
                  // Arapça içerik/scroll/bookmark etkilenmez.
                  ref
                      .read(quranTranslationRepositoryProvider)
                      .invalidateChapter(chapterId);
                  ref.invalidate(quranChapterTranslationProvider(chapterId));
                },
              ),
            ],
          ),
        ),
      ),
      // Meal paketlenmiş offline asset'tir — internet/spinner bekleme
      // durumu GÖSTERİLMEZ (CHECKPOINT 06 Recovery).
      _ => const SizedBox.shrink(),
    };
  }
}

/// Kesintisiz sure dinleme paneli (TASK 042): Sureyi dinle / Duraklat /
/// Devam et, önceki-sonraki ayet ve "Ayet X / Y" bilgisi. Yalnız gerçek
/// işlevler görünür; hata panelde sakin kalır, reader etkilenmez.
final class _ChapterPlaybackPanel extends ConsumerWidget {
  const _ChapterPlaybackPanel({
    required this.chapterId,
    required this.verseCount,
    required this.audioState,
    required this.display,
  });

  final int chapterId;
  final int verseCount;
  final QuranVerseAudioState audioState;
  final QuranAudioDisplayInfo display;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(quranVerseAudioControllerProvider.notifier);

    // Global oturum BAŞKA sureye aitse panel boşta görünür: "Sureyi
    // dinle" mevcut sesi durdurup bu sureyi başlatır (TASK 045).
    final appliesToChapter = audioState.activeChapterId == chapterId;
    final panelState = appliesToChapter
        ? audioState
        : QuranVerseAudioState(sourceReady: audioState.sourceReady);

    if (panelState.chapterAudioFailed &&
        panelState.status == QuranVerseAudioStatus.error) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        // TASK 055: hata bile sakin, gölgesiz yüzeyde — kırmızı/uyarıcı
        // görünüm YOK (mevcut metin tonu korunur).
        child: AppCard(
          variant: AppCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                // Ses hizmeti hiç başlatılamadıysa tekrar denemek sonucu
                // değiştirmez — yalnız sakin bilgi verilir (TASK 045).
                panelState.serviceUnavailable
                    ? l10n.quranAudioServiceUnavailable
                    : l10n.quranChapterAudioLoadIssue,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              if (!panelState.serviceUnavailable) ...[
                const SizedBox(height: AppSpacing.s3),
                AppButton(
                  label: l10n.commonRetry,
                  variant: AppButtonVariant.secondary,
                  // Retry ilgili (kâri, sure) cache'ini düşürüp yeniden
                  // dener (TASK 049).
                  onPressed: () => controller.retryChapter(
                    chapterId: chapterId,
                    expectedVerseCount: verseCount,
                    display: display,
                  ),
                ),
                // Seçili kârinin sesi yüklenemiyorsa kullanıcı buradan
                // başka kâri seçebilir — otomatik geçiş YAPILMAZ.
                const _ReciterSelector(),
              ],
            ],
          ),
        ),
      );
    }

    final isLoading = panelState.status == QuranVerseAudioStatus.loading;
    final isPlaying = panelState.status == QuranVerseAudioStatus.playing;
    final isPaused = panelState.status == QuranVerseAudioStatus.paused;
    final isActive = panelState.activeVerseNumber != null;
    final mainLabel = isPlaying
        ? l10n.quranAudioPause
        : isPaused
        ? l10n.quranAudioResume
        : l10n.quranChapterAudioPlay;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      // TASK 055: ses kontrolleri gölgesiz, ince kenarlıklı yüzeyde —
      // ayet metniyle görsel olarak YARIŞMAZ. Davranış değişmedi.
      child: AppCard(
        variant: AppCardVariant.outlined,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.quranAudioPrevVerse,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: panelState.hasPrevious
                      ? () => controller.skipToAdjacentVerse(forward: false)
                      : null,
                ),
                Expanded(
                  child: AppButton(
                    label: mainLabel,
                    variant: AppButtonVariant.secondary,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : isPlaying || isPaused
                        ? controller.togglePauseResume
                        : () => controller.playChapter(
                            chapterId: chapterId,
                            expectedVerseCount: verseCount,
                            display: display,
                          ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.quranAudioNextVerse,
                  icon: const Icon(Icons.skip_next),
                  onPressed: panelState.hasNext
                      ? () => controller.skipToAdjacentVerse(forward: true)
                      : null,
                ),
                if (isActive)
                  IconButton(
                    tooltip: l10n.quranChapterAudioStop,
                    icon: const Icon(Icons.stop),
                    onPressed: controller.stopPlayback,
                  ),
              ],
            ),
            // Kâri seçimi (TASK 049): kontrolleri sıkıştırmadan ayrı,
            // responsive satırda.
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: _ReciterSelector(),
            ),
            if (isActive && panelState.totalVerseCount != null) ...[
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranAudioVerseOf(
                  panelState.activeVerseNumber!,
                  panelState.totalVerseCount!,
                ),
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ayet alt bilgi satırındaki ses aksiyonu (TASK 041): Dinle / Duraklat /
/// Devam et / (hatada) Tekrar dene. Yalnız ilgili ayette durum gösterir;
/// hata reader'ı etkilemez.
final class _VerseAudioAction extends ConsumerWidget {
  const _VerseAudioAction({
    required this.verse,
    required this.expectedVerseCount,
    required this.audioState,
    required this.display,
  });

  final QuranVerse verse;
  final int expectedVerseCount;
  final QuranVerseAudioState audioState;
  final QuranAudioDisplayInfo display;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = verse.verseKey;
    final isActive = audioState.activeVerseKey == key;

    if (isActive && audioState.status == QuranVerseAudioStatus.loading) {
      // Spinner + kısa etiket: buton alanı boş görünmez, genişlik
      // Dinle/Duraklat ile benzer kalır (TASK 044). TextButton.icon
      // yapısı korunur ki durumlar arası geçişte hizalama zıplamasın.
      return Semantics(
        label: l10n.quranAudioLoading,
        child: Tooltip(
          message: l10n.quranAudioLoading,
          child: TextButton.icon(
            onPressed: null, // yükleme sürerken dokunuşlar kilitli
            icon: const SizedBox(
              height: AppSizes.iconSm,
              width: AppSizes.iconSm,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(l10n.quranAudioLoading),
          ),
        ),
      );
    }

    final isError =
        audioState.errorVerseKey == key &&
        audioState.status == QuranVerseAudioStatus.error;
    final (label, icon, tooltip) = switch ((isActive, audioState.status)) {
      (true, QuranVerseAudioStatus.playing) => (
        l10n.quranAudioPause,
        Icons.pause,
        l10n.quranAudioPause,
      ),
      (true, QuranVerseAudioStatus.paused) => (
        l10n.quranAudioResume,
        Icons.play_arrow,
        l10n.quranAudioResume,
      ),
      _ =>
        isError
            ? (l10n.commonRetry, Icons.refresh, l10n.quranAudioLoadIssue)
            : (l10n.quranAudioPlay, Icons.play_arrow, l10n.quranAudioPlay),
    };

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: Tooltip(
        message: tooltip,
        child: TextButton.icon(
          onPressed: () => ref
              .read(quranVerseAudioControllerProvider.notifier)
              .toggleVerse(
                verse,
                expectedVerseCount: expectedVerseCount,
                display: display,
              ),
          icon: Icon(icon, size: AppSizes.iconSm),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Ayet alt bilgi satırındaki sakin kaydetme aksiyonu (TASK 037).
/// Seçili durum yeterlidir — başarı snackbar'ı gösterilmez.
final class _VerseBookmarkAction extends StatelessWidget {
  const _VerseBookmarkAction({required this.bookmarked, required this.onTap});

  final bool bookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = bookmarked ? l10n.quranBookmarkSaved : l10n.quranBookmarkAdd;
    return Semantics(
      button: true,
      selected: bookmarked,
      label: label,
      child: Tooltip(
        message: label,
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(
            bookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: AppSizes.iconSm,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Sure oynatma panelindeki kâri seçim satırı (TASK 049): seçili kârinin
/// doğrulanmış adı + seçim sheet'i. Dar ekranda ellipsis; Tanzil/meal/
/// ses kaynak satırlarını sıkıştırmaz. Tt paneline ses seçeneği EKLENMEZ.
final class _ReciterSelector extends ConsumerWidget {
  const _ReciterSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedName =
        ref.watch(quranSelectedReciterProvider).value?.reciterName ??
        l10n.quranReciterName;
    return Semantics(
      button: true,
      label: l10n.quranReciterSelectTitle,
      child: Tooltip(
        message: l10n.quranReciterSelectTitle,
        child: TextButton.icon(
          onPressed: () => _showReciterSheet(context),
          icon: const Icon(
            Icons.record_voice_over_outlined,
            size: AppSizes.iconSm,
          ),
          label: Text(
            '${l10n.quranReciterLabel}: $selectedName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Kâri seçim sheet'i (TASK 049): doğrulanmış timed katalog, seçili
/// işaret, varsayılan her zaman görünür; 10'dan fazla kayıtta oturum içi
/// hafif ad araması. Seçim kalıcılaşınca aktif ses durdurulur (yardım
/// metniyle açıkça belirtilir) — büyük onay dialog'u YOK.
void _showReciterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => const SafeArea(child: _ReciterSheetContent()),
  );
}

final class _ReciterSheetContent extends ConsumerStatefulWidget {
  const _ReciterSheetContent();

  @override
  ConsumerState<_ReciterSheetContent> createState() =>
      _ReciterSheetContentState();
}

final class _ReciterSheetContentState
    extends ConsumerState<_ReciterSheetContent> {
  /// Yalnız oturum içi, kâri adında filtre — genel arama altyapısı DEĞİL.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(quranReciterSelectionControllerProvider);
    final controller = ref.read(
      quranReciterSelectionControllerProvider.notifier,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s2,
        AppSpacing.s5,
        AppSpacing.s6,
      ),
      child: switch (async) {
        AsyncData(:final value) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(l10n.quranReciterSelectTitle, token: AppTextStyleToken.h3),
            const SizedBox(height: AppSpacing.s2),
            AppText(
              l10n.quranReciterChangeStopsPlayback,
              token: AppTextStyleToken.caption,
              secondary: true,
            ),
            if (value.catalogDegraded) ...[
              const SizedBox(height: AppSpacing.s3),
              AppText(
                l10n.quranReciterListLoadIssue,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s2),
              AppButton(
                label: l10n.commonRetry,
                variant: AppButtonVariant.secondary,
                onPressed: controller.retryCatalog,
              ),
            ],
            if (value.saveFailed) ...[
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.quranReciterChangeFailed,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
            ],
            if (value.reciters.length > 10) ...[
              const SizedBox(height: AppSpacing.s3),
              TextField(
                onChanged: (query) => setState(() => _query = query),
                decoration: InputDecoration(
                  hintText: l10n.quranReciterSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s4),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final source in value.reciters)
                    if (_query.trim().isEmpty ||
                        source.reciterName.toLowerCase().contains(
                          _query.trim().toLowerCase(),
                        ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                        child: Semantics(
                          selected: source.readId == value.selectedReadId,
                          child: OnboardingOptionCard(
                            label: source.reciterName,
                            description: [
                              l10n.quranRewayaName,
                              if (source.isDefault)
                                l10n.quranReciterDefaultLabel,
                              if (source.readId == value.selectedReadId)
                                l10n.quranReciterSelectedLabel,
                            ].join(' · '),
                            selected: source.readId == value.selectedReadId,
                            onTap: value.isSaving
                                ? () {}
                                : () async {
                                    final changed = await controller.select(
                                      source.readId,
                                    );
                                    if (changed && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
        AsyncError() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              l10n.quranReciterListLoadIssue,
              token: AppTextStyleToken.bodySmall,
              secondary: true,
            ),
            const SizedBox(height: AppSpacing.s3),
            AppButton(
              label: l10n.commonRetry,
              variant: AppButtonVariant.secondary,
              onPressed: () =>
                  ref.invalidate(quranReciterSelectionControllerProvider),
            ),
          ],
        ),
        _ => AppLoading(label: l10n.commonLoading),
      },
    );
  }
}

/// Okuma ayarları paneli (TASK 037/040): Arapça metin boyutu + meal
/// tercihi. İçerik kaydırılabilir — küçük ekranlarda taşma yapmaz.
void _showReaderSettings(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s2,
            AppSpacing.s5,
            AppSpacing.s6,
          ),
          child: Consumer(
            builder: (context, ref, _) {
              final selected =
                  ref.watch(quranReaderTextSizeControllerProvider).value ??
                  QuranArabicTextSize.medium;
              final showTranslation =
                  ref.watch(quranShowTranslationControllerProvider).value ??
                  true;
              String sizeLabel(QuranArabicTextSize size) => switch (size) {
                QuranArabicTextSize.small => l10n.quranTextSizeSmall,
                QuranArabicTextSize.medium => l10n.quranTextSizeMedium,
                QuranArabicTextSize.large => l10n.quranTextSizeLarge,
              };
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.quranReaderViewTitle,
                    token: AppTextStyleToken.h3,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AppText(
                    l10n.quranArabicTextSizeLabel,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  for (final size in QuranArabicTextSize.values) ...[
                    OnboardingOptionCard(
                      label: sizeLabel(size),
                      selected: selected == size,
                      onTap: () => ref
                          .read(quranReaderTextSizeControllerProvider.notifier)
                          .select(size),
                    ),
                    const SizedBox(height: AppSpacing.s3),
                  ],
                  const SizedBox(height: AppSpacing.s2),
                  // Türkçe meal aç/kapat (TASK 040) — kapalıyken callable
                  // çağrısı yapılmaz, Arapça metin etkilenmez.
                  OnboardingOptionCard(
                    label: l10n.quranShowTranslationToggle,
                    selected: showTranslation,
                    onTap: () => ref
                        .read(quranShowTranslationControllerProvider.notifier)
                        .toggle(),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

final class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter});

  final QuranChapter chapter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placeLabel = switch (chapter.revelationPlace) {
      QuranRevelationPlace.meccan => l10n.quranRevelationMeccan,
      QuranRevelationPlace.medinan => l10n.quranRevelationMedinan,
    };

    // TASK 055: üst alan kompakt kalır (büyük hero YOK — ilk ayet aşağı
    // itilmez); sakin adaçayı yüzeyi ve Kur'an vurgu rengindeki Arapça ad
    // ile reader'a manevi bir giriş verir.
    final tokens = IslamicVisualTokens.of(context);
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s3),
        AppCard(
          variant: AppCardVariant.sage,
          child: Row(
            children: [
              AppBadge(label: '${chapter.id}'),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      chapter.transliteratedName,
                      token: AppTextStyleToken.h3,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    AppText(
                      '${l10n.quranAyahCount(chapter.verseCount)}'
                      ' · $placeLabel',
                      token: AppTextStyleToken.caption,
                      secondary: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              // Arapça sure adı KENDİ yönünde ve Kur'an vurgu renginde.
              Directionality(
                textDirection: TextDirection.rtl,
                child: AppText(
                  chapter.arabicName,
                  token: AppTextStyleToken.h2,
                  color: tokens.quranAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
      ],
    );
  }
}

/// Ekran sonunda sakin kaynak atfı (02_BRAND — güven; link paketi YOK).
final class _SourceAttribution extends StatelessWidget {
  const _SourceAttribution({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s2, bottom: AppSpacing.s6),
      child: Column(
        children: [
          AppText(
            '${l10n.quranTextSourceLabel}: Tanzil Project',
            token: AppTextStyleToken.caption,
            secondary: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s1),
          const AppText(
            'tanzil.net',
            token: AppTextStyleToken.caption,
            secondary: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

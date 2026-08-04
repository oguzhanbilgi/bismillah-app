import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_motion.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bismillah Asistanı sohbet ekranı (TASK 059 §11; TASK 060 cilası).
///
/// Kaynaklı, deterministik cevaplar; fetva makamı DEĞİLDİR. Cevap tek dev
/// karta doldurulmaz: kaynaklı açıklama, resmî kaynaklar ve ilgili Learn
/// içeriği tonal olarak ayrılır. Ses/mikrofon YOKTUR; retrieval/güvenlik
/// mantığı bu görevde DEĞİŞMEZ.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _didInitialScroll = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      return;
    }
    // Çift gönderim koruması iki katmanlıdır: buton zaten pasiftir, ama
    // hızlı ikinci bir dokunuş veya klavye aksiyonu buraya ulaşabilir.
    // Cevap sürerken metin TEMİZLENMEZ — kullanıcının yazdığı kaybolmaz.
    final current = ref.read(assistantConversationProvider).asData?.value;
    if (current == null || current.isResponding) {
      return;
    }
    _input.clear();
    await ref.read(assistantConversationProvider.notifier).send(text);
  }

  /// Yeni mesaj eklendiğinde: kullanıcının KENDİ mesajında daima, asistan
  /// cevabında yalnız kullanıcı zaten en alttaysa kaydır — uzun cevabı
  /// okurken kullanıcı zorla aşağı çekilmez (TASK 060 §15).
  void _onConversationChanged(
    AsyncValue<AssistantConversationState>? prev,
    AsyncValue<AssistantConversationState> next,
  ) {
    final prevMessages = prev?.asData?.value.messages ?? const [];
    final nextMessages = next.asData?.value.messages ?? const [];
    if (nextMessages.length <= prevMessages.length) {
      return;
    }
    if (nextMessages.last.isUser || _isNearBottom()) {
      _scrollToEnd();
    }
  }

  bool _isNearBottom() {
    if (!_scroll.hasClients) {
      return true;
    }
    final position = _scroll.position;
    return position.pixels >= position.maxScrollExtent - 160;
  }

  void _scrollToEnd({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      final target = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(target);
      }
    });
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.assistantClearConfirmTitle),
        content: Text(l10n.assistantClearConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.assistantClearConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final cleared = await ref
        .read(assistantConversationProvider.notifier)
        .clear();
    _didInitialScroll = false;
    // Silme BAŞARISIZ olursa "temizlendi" mesajı GÖSTERİLMEZ (TASK 094 §E) —
    // kullanıcıya yanlış bir güvence verilmez. TASK 095D: sessiz kalmak
    // yerine AYRI ve dürüst bir başarısızlık mesajı gösterilir; başarı
    // mesajı yalnız gerçek silmeden sonra çıkar.
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            cleared ? l10n.assistantCleared : l10n.assistantClearFailed,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(assistantConversationProvider, _onConversationChanged);

    final async = ref.watch(assistantConversationProvider);
    final state = async.asData?.value;
    final hasMessages = state != null && state.messages.isNotEmpty;

    // Ekran açıldığında son mesaja hizala (animasyonsuz, tek sefer).
    if (hasMessages && !_didInitialScroll) {
      _didInitialScroll = true;
      _scrollToEnd(animate: false);
    }

    return AppScaffold(
      title: l10n.assistantTitle,
      padded: false,
      actions: [
        if (hasMessages)
          IconButton(
            tooltip: l10n.assistantClearTitle,
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmClear,
          ),
      ],
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _LandingState(onPick: _pick),
              data: (state) => state.isEmpty && !state.isResponding
                  ? _LandingState(onPick: _pick)
                  : _MessageList(
                      scroll: _scroll,
                      messages: state.messages,
                      isResponding: state.isResponding,
                      hasRetrievalFailure: state.hasRetrievalFailure,
                      onRetry: () => ref
                          .read(assistantConversationProvider.notifier)
                          .retryLastFailed(),
                    ),
            ),
          ),
          _InputBar(
            controller: _input,
            isResponding: state?.isResponding ?? false,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  void _pick(String question) {
    // Cevap sürerken öneri kartı zaten görünmez; yine de kilit burada da
    // kontrol edilir — iki soru aynı anda gönderilemez.
    final current = ref.read(assistantConversationProvider).asData?.value;
    if (current == null || current.isResponding) {
      return;
    }
    _input.text = question;
    _send();
  }
}

// ---------------------------------------------------------------------------
// İniş (landing) durumu — ne yapabilir / sınırları / örnek sorular
// ---------------------------------------------------------------------------

/// Ekranın ilk hâli (TASK 095D). Sahte bir konuşma, referans/teşekkür
/// metni veya "yapay zekâ" iddiası YOKTUR: yalnız kapsam, sınır ve
/// gerçekten cevaplanabilen örnek sorular.
class _LandingState extends StatelessWidget {
  const _LandingState({required this.onPick});

  final void Function(String question) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestions = [
      l10n.assistantSuggested1,
      l10n.assistantSuggested2,
      l10n.assistantSuggested3,
      l10n.assistantSuggested4,
      l10n.assistantSuggested5,
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s5,
      ),
      children: [
        // Kompakt başlık kartı — büyük dekoratif alan yok.
        AppCard(
          variant: AppCardVariant.sand,
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(l10n.assistantTitle, token: AppTextStyleToken.h3),
              const SizedBox(height: AppSpacing.s1),
              AppText(
                l10n.assistantIntroBody,
                token: AppTextStyleToken.bodySmall,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s4),
              _BlockLabel(l10n.assistantLandingCanTitle),
              const SizedBox(height: AppSpacing.s2),
              _BulletLine(text: l10n.assistantLandingCan1),
              _BulletLine(text: l10n.assistantLandingCan2),
              _BulletLine(text: l10n.assistantLandingCan3),
              const SizedBox(height: AppSpacing.s3),
              _BlockLabel(l10n.assistantLandingLimitTitle),
              const SizedBox(height: AppSpacing.s2),
              // Fetva uyarısı sınırların İLKİ ve en görünür olanıdır.
              _SafetyNotice(text: l10n.assistantNotMuftiNotice),
              const SizedBox(height: AppSpacing.s2),
              _SafetyNotice(text: l10n.assistantLandingLocalOnly),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s5),
        AppText(l10n.assistantSuggestedTitle, token: AppTextStyleToken.h3),
        const SizedBox(height: AppSpacing.s2),
        for (final question in suggestions) ...[
          _SuggestionTile(question: question, onTap: () => onPick(question)),
          const SizedBox(height: AppSpacing.s2),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      button: true,
      label: question,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.sectionSurface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: tokens.surfaceBorder),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s3,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: AppSizes.iconSm,
                        color: tokens.spiritualGreenStrong,
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: AppText(
                          question,
                          token: AppTextStyleToken.bodySmall,
                        ),
                      ),
                      Icon(
                        isRtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: AppSizes.iconSm,
                        color: tokens.spiritualGreenStrong,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mesaj listesi
// ---------------------------------------------------------------------------

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.scroll,
    required this.messages,
    required this.isResponding,
    required this.hasRetrievalFailure,
    required this.onRetry,
  });

  final ScrollController scroll;
  final List<AssistantMessage> messages;
  final bool isResponding;
  final bool hasRetrievalFailure;
  final Future<void> Function() onRetry;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    // Son satır ya "aranıyor" ya da geçici arama hatasıdır — ikisi aynı
    // anda olamaz.
    final trailing = isResponding || hasRetrievalFailure ? 1 : 0;

    return ListView.builder(
      controller: scroll,
      // Tek ana scroll; iç scroll YOK. Klavye açılınca Scaffold body'yi
      // yeniden boyutlar, composer üstte kalır.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.s4,
      ),
      itemCount: messages.length + trailing,
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return isResponding
              ? const _ThinkingRow()
              : _RetrievalFailureCard(onRetry: onRetry);
        }
        final message = messages[index];
        // Gün ayracı: geçmiş yeniden yüklendiğinde hangi günün konuşması
        // olduğu okunur kalsın diye (var olan `createdAt` kullanılır).
        final showDay =
            index == 0 ||
            !_sameDay(messages[index - 1].createdAt, message.createdAt);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDay) _DaySeparator(date: message.createdAt),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s5),
              child: message.isUser
                  ? _UserMessage(
                      text: message.text,
                      createdAt: message.createdAt,
                    )
                  : _AssistantAnswer(message: message),
            ),
          ],
        );
      },
    );
  }
}

/// Konuşmanın hangi güne ait olduğunu gösteren sakin ayraç. Tarih biçimi
/// platformun kendi yerelleştirmesinden gelir (yeni bağımlılık yok).
class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).formatMediumDate(date);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: Center(
        child: AppText(
          label,
          token: AppTextStyleToken.caption,
          secondary: true,
        ),
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text, required this.createdAt});

  final String text;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(createdAt));
    return Semantics(
      label: '${AppLocalizations.of(context).assistantYouLabel}, $time: $text',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.sandSurface,
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: tokens.surfaceBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                      vertical: AppSpacing.s3,
                    ),
                    child: AppText(text, token: AppTextStyleToken.bodySmall),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s1),
            AppText(time, token: AppTextStyleToken.caption, secondary: true),
          ],
        ),
      ),
    );
  }
}

/// Geçici arama hatası (TASK 095D). Bir CEVAP DEĞİLDİR: dinî bir sonuç,
/// kaynak veya "kaynak bulunamadı" iddiası içermez; yalnız işlemin
/// tamamlanamadığını söyler ve tekrar denemeyi sunar.
class _RetrievalFailureCard extends StatelessWidget {
  const _RetrievalFailureCard({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s5),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: AppCard(
          variant: AppCardVariant.outlined,
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.assistantRetrievalFailedTitle,
                token: AppTextStyleToken.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s2),
              AppText(
                l10n.assistantRetrievalFailedBody,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
              const SizedBox(height: AppSpacing.s3),
              AppButton(
                label: l10n.assistantRetry,
                variant: AppButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinkingRow extends StatelessWidget {
  const _ThinkingRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s5),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          liveRegion: true,
          label: l10n.assistantThinking,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.sectionSurface,
              borderRadius: AppRadius.mdAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    // Reduced-motion açıkken dönen gösterge yerine sabit bir
                    // işaret durur; durum yine anında ve açıkça bildirilir.
                    child: AppMotion.isReduced(context)
                        ? Icon(
                            Icons.hourglass_empty_rounded,
                            size: AppSizes.iconSm,
                            color: tokens.spiritualGreenStrong,
                          )
                        : const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Flexible(
                    child: AppText(
                      l10n.assistantThinking,
                      token: AppTextStyleToken.bodySmall,
                      secondary: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Asistan cevabı — tek dev kart DEĞİL: açıklama + kaynaklar + ilgili Learn
// tonal olarak ayrılır (TASK 060 §9).
// ---------------------------------------------------------------------------

class _AssistantAnswer extends ConsumerWidget {
  const _AssistantAnswer({required this.message});

  final AssistantMessage message;

  /// Hüküm/yönlendirme ve kaynak-yok durumları sıcak kum yüzeyde; kaynaklı
  /// açıklama ince kenarlıklı sakin yüzeyde (alarm/kırmızı YOK).
  bool get _isAdvisory =>
      message.answerType == AssistantAnswerType.officialFatwaRequired ||
      message.answerType == AssistantAnswerType.qualifiedGuidanceRequired ||
      message.answerType == AssistantAnswerType.noVerifiedSource;

  /// Güvenli sonraki adım metni. Sınıflandırma BURADA YAPILMAZ — yalnız
  /// composer'ın verdiği kanonik [AssistantAnswerType] okunur; hassasiyet
  /// yüklemi presentation katmanında KOPYALANMAZ (TASK 094 §A).
  String? _nextStep(AppLocalizations l10n) => switch (message.answerType) {
    AssistantAnswerType.officialFatwaRequired ||
    AssistantAnswerType.qualifiedGuidanceRequired =>
      l10n.assistantNextStepGuidance,
    AssistantAnswerType.noVerifiedSource => l10n.assistantNextStepNoSource,
    _ => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final response = message.response;
    final steps = response?.steps ?? const <String>[];
    final keyPoints = response?.keyPoints ?? const <String>[];
    final guidanceUrl = (response?.shouldOfferOfficialGuidance ?? false)
        ? response?.officialGuidanceUrl
        : null;

    return Semantics(
      label: l10n.assistantTitle,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Kaynaklı kısa açıklama + adım/nokta/pratik + güvenlik notu.
          AppCard(
            variant: _isAdvisory
                ? AppCardVariant.sand
                : AppCardVariant.outlined,
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnswerBadge(answerType: message.answerType),
                const SizedBox(height: AppSpacing.s3),
                // "Kaynaklı açıklama" etiketi yalnız kaynaklı cevaplarda;
                // yönlendirme/kaynak-yok durumunda metin tek başına durur.
                if (!_isAdvisory) ...[
                  _BlockLabel(l10n.assistantSummaryTitle),
                  const SizedBox(height: AppSpacing.s1),
                ],
                AppText(message.text, token: AppTextStyleToken.bodySmall),
                if (steps.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _BlockLabel(l10n.assistantStepsTitle),
                  const SizedBox(height: AppSpacing.s2),
                  for (var i = 0; i < steps.length; i++)
                    _StepLine(index: i + 1, text: steps[i]),
                ],
                if (keyPoints.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _BlockLabel(l10n.assistantKeyPointsTitle),
                  const SizedBox(height: AppSpacing.s2),
                  for (final point in keyPoints) _BulletLine(text: point),
                ],
                if (response?.practicalAction case final String action) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _BlockLabel(l10n.assistantPracticalTitle),
                  const SizedBox(height: AppSpacing.s1),
                  AppText(action, token: AppTextStyleToken.bodySmall),
                ],
                if (response?.differenceNote case final String note) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _BlockLabel(l10n.learnDifferenceNoteTitle),
                  const SizedBox(height: AppSpacing.s1),
                  AppText(note, token: AppTextStyleToken.bodySmall),
                ],
                if (message.safetyNotice case final String notice) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _SafetyNotice(text: notice),
                ],
                // Güvenli sonraki adım: reddedilen/kaynaksız durumlarda
                // kullanıcı boşlukta bırakılmaz. Bu satır bir hüküm ya da
                // ilmî onay iddiası TAŞIMAZ, yalnız yapılabilecekleri söyler.
                if (_nextStep(l10n) case final String next) ...[
                  const SizedBox(height: AppSpacing.s3),
                  AppText(
                    next,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                ],
                // Din İşleri Yüksek Kurulu yönlendirmesi — açık aksiyon.
                if (guidanceUrl != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  AppButton(
                    label: l10n.assistantOfficialGuidanceCta,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _openOfficial(context, ref, guidanceUrl),
                  ),
                ],
              ],
            ),
          ),
          // 2) Resmî kaynaklar — Assistant özetinden AYRI bölüm.
          if (message.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s3),
            _BlockLabel(l10n.assistantSourcesTitle),
            // Yönlendirme/ret durumlarında künye, sorulan duruma dair bir
            // hükmün DAYANAĞI değildir; bu ayrım açıkça yazılır (mevcut,
            // zaten yerelleştirilmiş metin — yeni içerik eklenmez).
            if (_isAdvisory) ...[
              const SizedBox(height: AppSpacing.s1),
              AppText(
                l10n.assistantSourceNotDirectlyAddressing,
                token: AppTextStyleToken.caption,
                secondary: true,
              ),
            ],
            const SizedBox(height: AppSpacing.s2),
            for (final source in message.sources) _SourceCard(source: source),
          ],
          // 3) Learn'de devam et.
          if (response != null && response.relatedArticles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s3),
            _BlockLabel(l10n.assistantRelatedTitle),
            const SizedBox(height: AppSpacing.s2),
            Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: [
                for (final related in response.relatedArticles)
                  _RelatedChip(slug: related.slug, title: related.title),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _openOfficial(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref
      .read(externalLinkServiceProvider)
      .openOfficialSource(url);
  if (opened) {
    return;
  }
  // Açma başarısız → adres panoya kopyalanır (copy fallback korunur).
  await Clipboard.setData(ClipboardData(text: url));
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(l10n.sourcesOpenFailed)));
}

/// Kompakt, profesyonel kaynak kartı — ağır gölge yok, ham URL yok.
class _SourceCard extends ConsumerWidget {
  const _SourceCard({required this.source});

  final AssistantSourceReference source;

  String _languageLabel(AppLocalizations l10n) =>
      source.originalLanguage == 'ar'
      ? l10n.sourcesLangArabic
      : l10n.sourcesLangTurkish;

  /// Yalnız `https` adresler açılabilir sayılır (mevcut resmî kaynak
  /// politikası); boş veya bozuk künyede buton hiç çizilmez.
  bool get _canOpenUrl => source.canonicalUrl.startsWith('https://');

  bool get _canOpenArticle => source.articleSlug.trim().isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    // Kullanıcının dili kaynağın özgün dilinden farklıysa gösterilen metin
    // açıklayıcı çeviridir (sessizce Türkçe gösterilmez).
    final isExplanatoryTranslation =
        l10n.supportedLocale.name != source.originalLanguage;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: Semantics(
        container: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.sacredSurfaceMuted,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: tokens.surfaceBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Diyanet resmî kaynak etiketi + kurum.
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: AppSizes.iconSm,
                      color: tokens.spiritualGreenStrong,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Flexible(
                      child: AppText(
                        '${l10n.assistantOfficialSourceTag} · ${source.institution}',
                        token: AppTextStyleToken.caption,
                        secondary: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                // Eser adı ve kesin konum künyedir: kendi özgün dilinin
                // yönünde yazılır. Arapça arayüzde latin bir künye ters
                // dönmez, Türkçe arayüzde arapça künye düz yazılmaz.
                Directionality(
                  textDirection: source.originalLanguage == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(source.title, token: AppTextStyleToken.bodySmall),
                      if (source.sourceLocator.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s1),
                        AppText(
                          source.sourceLocator,
                          token: AppTextStyleToken.caption,
                          secondary: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s1),
                // Meta tek satırda birleşir: son doğrulama · özgün dil.
                AppText(
                  '${l10n.learnLastVerified}: ${source.lastVerifiedAt}'
                  '  ·  ${l10n.sourcesOriginalLanguageLabel}: '
                  '${_languageLabel(l10n)}',
                  token: AppTextStyleToken.caption,
                  secondary: true,
                ),
                if (isExplanatoryTranslation) ...[
                  const SizedBox(height: AppSpacing.s1),
                  AppText(
                    l10n.learnTranslationDisclaimer,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  ),
                ],
                const SizedBox(height: AppSpacing.s3),
                // Aksiyon YALNIZ gerçekten çalışan bir hedefi varsa gösterilir.
                // Bozuk/eksik künye (ör. eski kayıttan çözülen boş adres)
                // tıklanabilir görünüp hiçbir şey yapmaz duruma DÜŞMEZ;
                // eksiklik gizlenmez, açıkça yazılır.
                if (!_canOpenUrl && !_canOpenArticle)
                  AppText(
                    l10n.assistantSourceLinkUnavailable,
                    token: AppTextStyleToken.caption,
                    secondary: true,
                  )
                else
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: [
                      if (_canOpenUrl)
                        AppButton(
                          label: l10n.learnOpenOfficialPage,
                          variant: AppButtonVariant.secondary,
                          onPressed: () =>
                              _openOfficial(context, ref, source.canonicalUrl),
                        ),
                      if (_canOpenArticle)
                        AppButton(
                          label: l10n.assistantReadInLearn,
                          variant: AppButtonVariant.ghost,
                          onPressed: () => context.go(
                            AppRoutes.learnArticlePath(source.articleSlug),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedChip extends StatelessWidget {
  const _RelatedChip({required this.slug, required this.title});

  final String slug;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(AppRoutes.learnArticlePath(slug)),
          borderRadius: AppRadius.smAll,
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.touchTarget,
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s3,
                  vertical: AppSpacing.s2,
                ),
                decoration: BoxDecoration(
                  color: tokens.sageSurface,
                  borderRadius: AppRadius.smAll,
                ),
                child: AppText(title, token: AppTextStyleToken.caption),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ortak küçük parçalar
// ---------------------------------------------------------------------------

class _AnswerBadge extends StatelessWidget {
  const _AnswerBadge({required this.answerType});

  final AssistantAnswerType? answerType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    // Kişisel duruma yönlendirme ile resmî fetva gerekliliği AYRI
    // rozetlerdir: ikisi aynı etiketi taşıyınca kullanıcı hangi sınırın
    // devrede olduğunu göremiyordu (TASK 095D).
    final label = switch (answerType) {
      AssistantAnswerType.directVerifiedAnswer => l10n.assistantBadgeVerified,
      AssistantAnswerType.noVerifiedSource => l10n.assistantBadgeNoSource,
      AssistantAnswerType.officialFatwaRequired =>
        l10n.assistantBadgeOfficialFatwa,
      AssistantAnswerType.qualifiedGuidanceRequired =>
        l10n.assistantBadgeGuidance,
      _ => l10n.assistantBadgeGeneral,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sageSurface,
        borderRadius: AppRadius.smAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s1,
        ),
        child: AppText(
          label,
          token: AppTextStyleToken.caption,
          color: tokens.spiritualGreenStrong,
        ),
      ),
    );
  }
}

class _BlockLabel extends StatelessWidget {
  const _BlockLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return AppText(
      text,
      token: AppTextStyleToken.caption,
      color: tokens.spiritualGreenStrong,
    );
  }
}

/// Adım numarası — küçük sakin badge; RTL'de Row otomatik terslenir.
class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.sageSurface,
              shape: BoxShape.circle,
            ),
            child: AppText(
              '$index',
              token: AppTextStyleToken.caption,
              color: tokens.spiritualGreenStrong,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s1),
              child: AppText(text, token: AppTextStyleToken.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: Icon(
              Icons.circle,
              size: AppSpacing.s2,
              color: tokens.spiritualGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(child: AppText(text, token: AppTextStyleToken.bodySmall)),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: AppSizes.iconSm,
          color: tokens.spiritualGreenStrong,
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: AppText(
            text,
            token: AppTextStyleToken.caption,
            secondary: true,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Giriş alanı (composer)
// ---------------------------------------------------------------------------

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isResponding,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isResponding;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: tokens.warmBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.s2,
            AppSpacing.screenHorizontal,
            AppSpacing.s3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  enabled: !isResponding,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: l10n.assistantInputHint,
                    filled: true,
                    fillColor: tokens.sectionSurface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.lgAll,
                      borderSide: BorderSide(color: tokens.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.lgAll,
                      borderSide: BorderSide(
                        color: tokens.spiritualGreenStrong,
                      ),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.lgAll,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s4,
                      vertical: AppSpacing.s3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              // Boş mesaj/loading sırasında gönderim kilitli; ikon RTL'de
              // metin akış yönüne göre çevrilir.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canSend = !isResponding && value.text.trim().isNotEmpty;
                  return IconButton.filled(
                    tooltip: l10n.assistantSendLabel,
                    onPressed: canSend ? onSend : null,
                    icon: Transform.flip(
                      flipX: isRtl,
                      child: const Icon(Icons.send_rounded),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/assistant/data/local_source_grounded_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/data/shared_prefs_assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/bismillah_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_response_strings.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sabit composer metinlerini l10n'dan kurar (domain l10n'a bağlanmaz).
AssistantResponseStrings buildAssistantResponseStrings(AppLocalizations l10n) =>
    AssistantResponseStrings(
      noVerifiedSource: l10n.assistantNoVerifiedSource,
      officialFatwaRequired: l10n.assistantOfficialFatwaRequired,
      qualifiedGuidance: l10n.assistantQualifiedGuidance,
      generalInfoNotPersonalRuling: l10n.assistantGeneralInfoNotRuling,
      personalCaseGeneralInfo: l10n.assistantPersonalCaseGeneralInfo,
      sourceNotDirectlyAddressing: l10n.assistantSourceNotDirectlyAddressing,
      translationNote: l10n.learnTranslationDisclaimer,
    );

final assistantHistoryRepositoryProvider = Provider<AssistantHistoryRepository>(
  (ref) => const SharedPrefsAssistantHistoryRepository(),
);

/// Yerel, kaynağa dayalı asistan deposu (TASK 059). Uzak AI sağlayıcısı
/// GELECEKTE bu provider override edilerek eklenebilir — sözleşme temizdir.
final bismillahAssistantRepositoryProvider =
    Provider<BismillahAssistantRepository>((ref) {
      return LocalSourceGroundedAssistantRepository(
        ref.watch(learningKnowledgeRepositoryProvider),
        (locale) => buildAssistantResponseStrings(
          AppLocalizations(
            SupportedLocale.fromStorageKey(locale) ?? SupportedLocale.tr,
          ),
        ),
      );
    });

/// Sohbet ekranı durumu.
final class AssistantConversationState {
  const AssistantConversationState({
    this.messages = const [],
    this.isResponding = false,
  });

  final List<AssistantMessage> messages;
  final bool isResponding;

  bool get isEmpty => messages.isEmpty;

  AssistantConversationState copyWith({
    List<AssistantMessage>? messages,
    bool? isResponding,
  }) => AssistantConversationState(
    messages: messages ?? this.messages,
    isResponding: isResponding ?? this.isResponding,
  );
}

final assistantConversationProvider =
    AsyncNotifierProvider<
      AssistantConversationController,
      AssistantConversationState
    >(AssistantConversationController.new);

/// Sohbet orkestrasyonu (TASK 059 §11/§13).
///
/// - Boş mesaj gönderilemez, cevap sürerken yeni gönderim kilitlenir.
/// - Hassas (kişisel/hüküm) mesajlar kalıcı geçmişe YAZILMAZ.
/// - Locale değişimi geçmişi bozmaz (build locale'i izlemez).
final class AssistantConversationController
    extends AsyncNotifier<AssistantConversationState> {
  final Set<String> _nonPersistableIds = <String>{};
  int _seq = 0;

  @override
  Future<AssistantConversationState> build() async {
    final history = await ref.read(assistantHistoryRepositoryProvider).load();
    return AssistantConversationState(messages: history);
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    final current = state.value;
    if (text.isEmpty || current == null || current.isResponding) {
      return;
    }

    final locale = ref.read(appLocaleProvider);
    final createdAt = DateTime.now();
    final userMessage = AssistantMessage.user(
      id: _id(),
      text: text,
      createdAt: createdAt,
    );

    // Kalıcılık kararı: kişisel/hüküm niteliğindeki mesaj çifti KALICI
    // saklanmaz (TASK 059 §13).
    final queryClass = AssistantQueryClassifier.classify(text);
    final sensitive =
        queryClass == AssistantQueryClass.personalCase ||
        queryClass == AssistantQueryClass.halalHaramVerdict;

    // Kullanıcı mesajını hemen göster + gönderimi kilitle.
    state = AsyncData(
      current.copyWith(
        messages: [...current.messages, userMessage],
        isResponding: true,
      ),
    );

    final response = await ref
        .read(bismillahAssistantRepositoryProvider)
        .answer(
          AssistantQuery(
            id: userMessage.id,
            text: text,
            locale: locale.name,
            createdAt: createdAt,
          ),
        );

    final assistantMessage = AssistantMessage.fromResponse(
      id: _id(),
      createdAt: DateTime.now(),
      response: response,
    );

    if (sensitive) {
      _nonPersistableIds
        ..add(userMessage.id)
        ..add(assistantMessage.id);
    }

    final updated = [...current.messages, userMessage, assistantMessage];
    state = AsyncData(
      AssistantConversationState(messages: updated, isResponding: false),
    );
    await _persist(updated);
  }

  Future<void> _persist(List<AssistantMessage> messages) async {
    final persistable = [
      for (final m in messages)
        if (!_nonPersistableIds.contains(m.id)) m,
    ];
    await ref.read(assistantHistoryRepositoryProvider).save(persistable);
  }

  Future<void> clear() async {
    _nonPersistableIds.clear();
    await ref.read(assistantHistoryRepositoryProvider).clear();
    state = const AsyncData(AssistantConversationState());
  }
}

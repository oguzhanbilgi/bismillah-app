import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/islamic_visual_tokens.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/widgets/app_card.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama dili seçimi (TASK 053 §5).
///
/// Diller KENDİ adlarıyla listelenir (`SupportedLocale.nativeName`) —
/// kullanıcı arayüz dili ne olursa olsun kendi dilini tanır. Seçim tek
/// dokunuşla uygulanır; yeni route açılmaz, uygulama yeniden başlatılmaz.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(appLocaleProvider);

    return AppScaffold(
      title: l10n.settingsLanguageTitle,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.s4),
          AppText(
            l10n.settingsLanguageSubtitle,
            token: AppTextStyleToken.bodySmall,
            secondary: true,
          ),
          const SizedBox(height: AppSpacing.s4),
          for (final locale in SupportedLocale.values) ...[
            _LanguageOption(
              locale: locale,
              isSelected: locale == selected,
              onSelected: () => _select(context, ref, locale),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          const SizedBox(height: AppSpacing.s2),
          // Meal dili uygulama dilinden BAĞIMSIZDIR (TASK 053 §3) —
          // kullanıcı bunu sakin bir notla öğrenir, uyarı tonu yoktur.
          _TranslationNote(text: l10n.settingsLanguageTranslationNote),
          const SizedBox(height: AppSpacing.s6),
        ],
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    SupportedLocale locale,
  ) async {
    // Messenger await'ten ÖNCE alınır ve onay metni doğrudan SEÇİLEN dilden
    // üretilir. Dil değişimi `Localizations`'ı yeniden yüklediği için bu
    // ekranın element'i await sonrasında yeniden kurulmuş olabilir;
    // `BuildContext`e bağlı kalsaydık onay mesajı hiç görünmezdi.
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(appLocaleProvider.notifier).select(locale);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations(locale).settingsLanguageChanged),
        ),
      );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.isSelected,
    required this.onSelected,
  });

  final SupportedLocale locale;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = IslamicVisualTokens.of(context);

    return Semantics(
      // Ekran okuyucu için tek anlamlı düğüm: dil adı + seçili durumu.
      // ExcludeSemantics yalnız KART İÇERİĞİNİ sarar — InkWell dışarıda
      // kalır, böylece etkinleştirme (tap) aksiyonu korunur.
      button: true,
      selected: isSelected,
      label: locale.nativeName,
      child: AppCard(
        completed: isSelected,
        onTap: onSelected,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            // Minimum dokunma alanı (44dp) — kart dolgusuyla birlikte
            // rahatça aşılır, dar ekranlarda da korunur.
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Dil adı KENDİ yönünde yazılır: Arapça seçenek
                      // Türkçe/İngilizce arayüzde de doğru görünür.
                      Directionality(
                        textDirection: locale.isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: AppText(
                          locale.nativeName,
                          token: AppTextStyleToken.h3,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: AppSpacing.s1),
                        AppText(
                          l10n.settingsLanguageSelected,
                          token: AppTextStyleToken.caption,
                          secondary: true,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_rounded, color: tokens.spiritualGreenStrong),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslationNote extends StatelessWidget {
  const _TranslationNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = IslamicVisualTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.sacredSurfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: AppText(text, token: AppTextStyleToken.caption, secondary: true),
      ),
    );
  }
}

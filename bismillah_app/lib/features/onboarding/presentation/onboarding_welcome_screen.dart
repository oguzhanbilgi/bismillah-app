import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/shell/app_scaffold.dart';
import 'package:bismillah_app/app/theme/app_radius.dart';
import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:bismillah_app/core/constants/app_constants.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/widgets/app_badge.dart';
import 'package:bismillah_app/shared/widgets/app_button.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding karşılama ekranı (TASK 026 — 04_ONBOARDING §2 ton kuralları).
///
/// Bu ekranda ASLA olmayanlar: login, bildirim/konum izni, paywall,
/// abonelik mesajı, korku/suçluluk dili. Startup yönlendirmesi HENÜZ
/// buraya bağlı değildir (TASK 028); route manuel açılır.
class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ext = AppThemeExtension.of(context);

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dil aksiyonu (TASK 053 §5): AYRI bir onboarding ADIMI DEĞİLDİR —
          // akışı uzatmadan, ilk ekranda tek dokunuşla dil değiştirilebilir.
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.s3),
            child: _WelcomeLanguageSwitcher(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sade dekoratif form — yeni asset gerektirmez; Besmele
                // logosu DEĞİLDİR (02_BRAND §7 kutsal hat kuralları).
                Container(
                  width: AppSizes.progressRingLarge,
                  height: AppSizes.progressRingLarge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ext.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mosque_outlined,
                    size: AppSizes.iconLg,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s7),
                AppBadge(
                  label: l10n.onboardingWelcomeEyebrow,
                  emphasized: true,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppText(
                  l10n.onboardingWelcomeTitle,
                  token: AppTextStyleToken.h1,
                ),
                const SizedBox(height: AppSpacing.s4),
                AppText(
                  l10n.onboardingWelcomeSupport,
                  token: AppTextStyleToken.body,
                  secondary: true,
                ),
              ],
            ),
          ),
          AppButton(
            label: l10n.onboardingWelcomeCta,
            onPressed: () => context.push(AppRoutes.onboardingGoals),
          ),
          const SizedBox(height: AppSpacing.s3),
          Center(
            child: AppText(
              l10n.onboardingWelcomeNote,
              token: AppTextStyleToken.caption,
              secondary: true,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.s7),
        ],
      ),
    );
  }
}

/// Karşılama ekranındaki kompakt dil seçici.
///
/// Diller kendi adlarıyla listelenir; seçim ANINDA uygulanır ve akış
/// bozulmaz (navigasyon YOK). Minimum dokunma alanı korunur.
class _WelcomeLanguageSwitcher extends ConsumerWidget {
  const _WelcomeLanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appLocaleProvider);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final locale in SupportedLocale.values)
          Semantics(
            button: true,
            selected: locale == selected,
            label: locale.nativeName,
            // ExcludeSemantics yalnız etiketi sarar; InkWell dışarıda kalır
            // ki ekran okuyucudan etkinleştirme aksiyonu korunsun.
            child: InkWell(
              onTap: () => ref.read(appLocaleProvider.notifier).select(locale),
              borderRadius: AppRadius.smAll,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3,
                  ),
                  child: Center(
                    child: ExcludeSemantics(
                      child: Directionality(
                        textDirection: locale.isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          locale.nativeName,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: locale == selected
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                                fontWeight: locale == selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

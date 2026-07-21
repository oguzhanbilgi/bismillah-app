import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kök uygulama widget'ı.
class BismillahApp extends ConsumerWidget {
  const BismillahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Global dil kaynağı (TASK 053): seçim değişince MaterialApp yeniden
    // çizilir — açık olan ekranlar dahil tüm arayüz anında yeni dile geçer,
    // yeni route veya uygulama restart'ı GEREKMEZ. Arapça'da yön (RTL)
    // MaterialApp'in locale'e bağlı Directionality'si ile gelir.
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: locale.locale,
      supportedLocales: SupportedLocale.locales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

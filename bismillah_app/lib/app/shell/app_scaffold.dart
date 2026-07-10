import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Ekran şablonu (03_DESIGN_SYSTEM §9): safe area, token zemin, standart
/// yatay kenar boşluğu. Alt navigasyon ve FAB burada DEĞİL — onları shell
/// yönetir (route metadata ile, 06_FLUTTER_ARCHITECTURE §13).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.padded = true,
  });

  final Widget body;

  /// Opsiyonel başlık — localization'dan gelir.
  final String? title;

  /// Standart yatay kenar boşluğu uygulansın mı?
  /// (Tam genişlik içerikler — ör. Kur'an yüzeyi — false geçer.)
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: title == null
          ? null
          : AppBar(title: AppText(title!, token: AppTextStyleToken.h2)),
      body: SafeArea(
        child: padded
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: body,
              )
            : body,
      ),
    );
  }
}

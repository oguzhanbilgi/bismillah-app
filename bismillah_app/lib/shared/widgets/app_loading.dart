import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Basit yükleme durumu. İskelet (skeleton) bileşenleri gerçek içerik
/// ekranlarıyla birlikte gelecek (03_DESIGN_SYSTEM §28); scaffold
/// aşamasında sade gösterge yeterli.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label});

  /// Opsiyonel açıklama — localization'dan gelir.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.s4),
            AppText(label!, token: AppTextStyleToken.caption, secondary: true),
          ],
        ],
      ),
    );
  }
}

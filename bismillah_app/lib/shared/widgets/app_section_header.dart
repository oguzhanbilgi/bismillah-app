import 'package:bismillah_app/app/theme/app_spacing.dart';
import 'package:bismillah_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';

/// Bölüm başlığı: başlık + opsiyonel sağ eylem (03_DESIGN_SYSTEM §12).
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s7, bottom: AppSpacing.s3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: AppText(title, token: AppTextStyleToken.h3)),
          ?trailing,
        ],
      ),
    );
  }
}

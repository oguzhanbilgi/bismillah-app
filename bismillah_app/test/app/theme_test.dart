import 'package:bismillah_app/app/theme/app_colors.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/app/theme/app_theme_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme.light builds with AppThemeExtension attached', () {
    final theme = AppTheme.light();

    expect(theme.extension<AppThemeExtension>(), isNotNull);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
  });
}

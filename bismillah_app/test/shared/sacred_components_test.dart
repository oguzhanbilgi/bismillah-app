import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/shared/sacred/hadith_text_block.dart';
import 'package:bismillah_app/shared/sacred/quran_text_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  );

  testWidgets('QuranTextBlock renders arabic text with mandatory source', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const QuranTextBlock(
          arabicText: 'placeholder-arabic',
          sourceLabel: 'placeholder-source',
        ),
      ),
    );

    expect(find.text('placeholder-arabic'), findsOneWidget);
    expect(find.text('placeholder-source'), findsOneWidget);
  });

  testWidgets('HadithTextBlock requires and shows source with grading', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const HadithTextBlock(
          text: 'placeholder-hadith',
          source: 'placeholder-source',
          grading: 'placeholder-grading',
        ),
      ),
    );

    expect(
      find.text('placeholder-source · placeholder-grading'),
      findsOneWidget,
    );
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drift'li widget testlerinin ortak kapanışı: ağacı test gövdesi İÇİNDE
/// söker ve stream aboneliği iptalinin kurduğu kısa ömürlü timer'ı fake
/// saati ilerleterek boşaltır — aksi hâlde testWidgets kapanışta
/// "Timer is still pending" ile düşer (TASK 016'da tespit edildi).
Future<void> unmountAndFlushDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

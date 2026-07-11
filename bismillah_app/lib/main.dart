import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // Bootstrap DB yaşam döngüsünü sahiplenen container'ı kurar; uygulama
  // ömrü boyunca yaşar (dispose gerekmez — süreç sonlanınca kapanır).
  final container = await bootstrap();
  runApp(
    UncontrolledProviderScope(container: container, child: const BismillahApp()),
  );
}

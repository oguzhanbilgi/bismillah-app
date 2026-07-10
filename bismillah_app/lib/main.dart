import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(child: BismillahApp()));
}

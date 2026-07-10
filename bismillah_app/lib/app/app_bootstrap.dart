import 'package:flutter/widgets.dart';

/// Uygulama ön-yüklemesi (06_FLUTTER_ARCHITECTURE §8).
///
/// Sözleşme: bootstrap AĞ BEKLEMEZ — soğuk açılış <2sn hedefi ilk frame'in
/// lokal veriyle çizilmesine dayanır. Firebase init, Isar açılışı,
/// Crashlytics ve sync engine başlangıcı ilgili entegrasyon görevlerinde
/// buraya (timeout'lu ve non-blocking) eklenecek.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Şimdilik başka iş yok: environment dart-define'dan lazily okunur,
  // lokal DB provider üzerinden lazily açılır.
}

import 'package:flutter/widgets.dart';

/// Köşe yarıçapı token'ları (03_DESIGN_SYSTEM §7).
abstract final class AppRadius {
  static const double sm = 8; // Çipler, sınıf rozetleri
  static const double md = 12; // Girişler, sohbet balonları
  static const double lg = 20; // Standart kart — Bismillah imzası
  static const double xl = 28; // Bottom sheet, kutlama modali
  static const double pill = 999; // Butonlar, arama alanı

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

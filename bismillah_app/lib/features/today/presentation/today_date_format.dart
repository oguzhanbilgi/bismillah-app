import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:flutter/material.dart';

/// `DayKey` → arayüzde okunabilir tarih (RDX-01C2).
///
/// Ekranda ham `2026-08-07` göstermek teknik bir kaçaktır; kullanıcı arayüzü
/// tarihi kendi dilinde okur. Biçim, platformun kendi yerelleştirmesinden
/// gelir ([MaterialLocalizations.formatMediumDate]) — yeni paket eklenmez,
/// TR/EN/AR üçü de kendi biçimini alır ve ay adları elle YAZILMAZ.
///
/// Ayrıştırılamayan bir değer UYDURULMAZ: ham metin olduğu gibi döner, böylece
/// bozuk bir kayıt sessizce yanlış bir tarihe dönüşmez.
String formatDayKeyForDisplay(BuildContext context, DayKey dayKey) {
  final parsed = DateTime.tryParse(dayKey.value);
  if (parsed == null) {
    return dayKey.value;
  }
  return MaterialLocalizations.of(context).formatMediumDate(parsed);
}

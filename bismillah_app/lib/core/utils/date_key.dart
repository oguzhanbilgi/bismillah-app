/// `dayKey` üretimi (10_DATA_MODEL §6): `yyyy-MM-dd`, kullanıcının o anki
/// YEREL gününe kilitlenir; timezone sonradan değişse bile geçmiş anahtarlar
/// kaymaz.
abstract final class DateKey {
  /// Verilen yerel zamandan gün anahtarı üretir.
  static String fromLocal(DateTime local) {
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Geçerli bir `yyyy-MM-dd` anahtarı mı? (10_DATA_MODEL §24 tarih kısıtı.)
  static bool isValid(String key) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
    if (match == null) {
      return false;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return false;
    }
    final parsed = DateTime(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }
}

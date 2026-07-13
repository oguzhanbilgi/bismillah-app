import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_text_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Arapça metin boyutu controller'ı (TASK 037).
///
/// Seçim reader'da ANINDA uygulanır (iyimser), yerel kayıt arkada koşar;
/// kayıt hatası seçimi geri almaz — sonraki açılış son başarılı kayda
/// döner. Bozuk/okunamayan değer varsayılana (medium) düşer.
final quranReaderTextSizeControllerProvider =
    AsyncNotifierProvider.autoDispose<
      QuranReaderTextSizeController,
      QuranArabicTextSize
    >(QuranReaderTextSizeController.new);

final class QuranReaderTextSizeController
    extends AsyncNotifier<QuranArabicTextSize> {
  @override
  Future<QuranArabicTextSize> build() async {
    final result = await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .loadArabicTextSize();
    return result.fold(
      onSuccess: (size) => size,
      onFailure: (_) => QuranArabicTextSize.medium,
    );
  }

  Future<void> select(QuranArabicTextSize size) async {
    state = AsyncData(size);
    // Kayıt hatası sessizce yok sayılır — görünüm tercihi kritik veri
    // değildir, okuma deneyimi kesintiye uğramaz.
    await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .saveArabicTextSize(size);
  }
}

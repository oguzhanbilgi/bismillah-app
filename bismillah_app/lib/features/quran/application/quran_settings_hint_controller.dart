import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tt okuma ayarları keşif göstergesi durumu (TASK 044/045).
///
/// `true` = gösterge henüz görülmedi, uygun ilk reader açılışında
/// gösterilebilir. Kalıcılık mevcut `QuranReaderPreferencesRepository`
/// üzerindedir (ikinci preference sistemi YOK). Eksik/bozuk saklanmış
/// değer GÖRÜLMEMİŞ sayılır; okuma hatası sakin biçimde görülmüş sayılır
/// (bozuk depo kullanıcıyı her açılışta rahatsız etmez). autoDispose
/// DEĞİL — bellekteki `false` durumu oturum bayrağıdır: gösterge bir kez
/// gösterildikten sonra aynı oturumda başka surede tekrar çıkmaz.
final quranSettingsHintControllerProvider =
    AsyncNotifierProvider<QuranSettingsHintController, bool>(
      QuranSettingsHintController.new,
    );

final class QuranSettingsHintController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .loadSettingsHintSeen();
    return result.fold(onSuccess: (seen) => !seen, onFailure: (_) => false);
  }

  /// Oturum içi işaret (TASK 045): gösterge gösterildi — uygulama açık
  /// kaldığı sürece tekrar çıkmaz. KALICI YAZMAZ: kullanıcı göstergeyi
  /// kapatmadan uygulama sonlanırsa sonraki açılışta yeniden gösterilir.
  void markShownForSession() {
    if (state.value != false) {
      state = const AsyncData(false);
    }
  }

  /// Kullanıcı aksiyonu ("Anladım", gösterge dışına dokunma, Tt): kalıcı
  /// "görüldü" işareti — sonraki uygulama açılışlarında gösterilmez.
  Future<void> markSeenPermanently() async {
    state = const AsyncData(false);
    await ref
        .read(quranReaderPreferencesRepositoryProvider)
        .saveSettingsHintSeen(seen: true);
  }
}

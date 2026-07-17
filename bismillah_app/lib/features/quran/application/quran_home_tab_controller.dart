import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kur'an ana ekranı iç sekme indeksleri (TASK 050): Oku / Öğren /
/// İlerlemem. Ham index yazımı yerine bu sabitler kullanılır.
abstract final class QuranHomeTab {
  static const int read = 0;
  static const int learn = 1;
  static const int progress = 2;
}

/// Today hızlı aksiyonlarından Kur'an iç sekmesine odak isteği (TASK 050).
///
/// [seq] her istekte artar; böylece aynı sekmeye tekrar dokunmak da
/// (kullanıcı arada elle başka sekmeye geçmişse) yeniden odak tetikler.
final class QuranHomeTabRequest {
  const QuranHomeTabRequest({required this.index, required this.seq});

  final int index;
  final int seq;
}

/// Kur'an ana ekranındaki hedef iç sekmeyi süren tek kaynak (TASK 050) —
/// cihaz-lokal UI durumu; kalıcılık, ağ ve analytics YOK. Duplicate route
/// oluşturmak yerine mevcut tek ekranın sekmesini değiştirir; AppShell ve
/// global ses servisi yeniden kurulmaz.
final class QuranHomeTabNotifier extends Notifier<QuranHomeTabRequest> {
  @override
  QuranHomeTabRequest build() =>
      const QuranHomeTabRequest(index: QuranHomeTab.read, seq: 0);

  /// Belirtilen sekmeye geçiş ister; aralık dışı değer sessizce Oku'ya
  /// çekilir (kırılgan index yerine güvenli sözleşme).
  void request(int index) {
    final safeIndex =
        index >= QuranHomeTab.read && index <= QuranHomeTab.progress
        ? index
        : QuranHomeTab.read;
    state = QuranHomeTabRequest(index: safeIndex, seq: state.seq + 1);
  }
}

final quranHomeTabProvider =
    NotifierProvider<QuranHomeTabNotifier, QuranHomeTabRequest>(
      QuranHomeTabNotifier.new,
    );

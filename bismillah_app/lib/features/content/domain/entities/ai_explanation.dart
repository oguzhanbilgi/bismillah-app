import 'package:bismillah_app/core/value_objects/unique_id.dart';

/// AI açıklama metni — `SacredContent` hiyerarşisinin BİLİNÇLİ olarak
/// DIŞINDADIR (06_FLUTTER_ARCH §19; 10_DATA_MODEL §20).
///
/// Runtime çıktısıdır: içerik ağacına asla yazılmaz, kutsal içerik
/// bileşenlerinin parametresine uymaz, vahiy/hadis olarak sunulamaz.
/// UI'da daima kalıcı "AI açıklaması" etiketiyle render edilir
/// (`AiExplanationBlock`). Asistan çıktısındaki alıntılar doğrulanmış
/// kütüphaneden [citedContentIds] referanslarıyla gelir — AI metninin
/// içine gömülmez.
final class AiExplanation {
  AiExplanation({required this.text, List<ContentId> citedContentIds = const []})
    : citedContentIds = List.unmodifiable(citedContentIds) {
    if (text.trim().isEmpty) {
      throw ArgumentError.value(text, 'text', 'Boş AI açıklaması olamaz');
    }
  }

  final String text;

  /// Doğrulanmış içerik kütüphanesinden alıntı referansları.
  final List<ContentId> citedContentIds;
}

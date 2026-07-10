import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';

/// Set içi tek zikir referansı. Zikir METNİ burada değildir — kaynak
/// metadata'lı içerik kaydına (`DhikrText` taşıyan `ContentItem`)
/// `contentId` ile referans verilir; kaynaksız zikir dolaşamaz.
final class DhikrSetItem {
  DhikrSetItem({required this.contentId, required this.targetCount}) {
    if (targetCount < 1) {
      throw ArgumentError.value(targetCount, 'targetCount', '>= 1 olmalı');
    }
  }

  final ContentId contentId;
  final int targetCount;
}

/// Zikir seti tanımı (10_DATA_MODEL §4).
///
/// Preset setler içerik kaynaklıdır (Public); custom setler kullanıcı
/// ağacında yaşar ve YÜKSEK hassasiyettir.
final class DhikrSet implements Classified {
  DhikrSet({
    required this.setId,
    required List<DhikrSetItem> items,
    required this.isCustom,
  }) : items = List.unmodifiable(items) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Boş set olamaz');
    }
  }

  final EntityId setId;
  final List<DhikrSetItem> items;
  final bool isCustom;

  @override
  SensitivityClass get sensitivityClass =>
      isCustom ? SensitivityClass.high : SensitivityClass.publicContent;
}

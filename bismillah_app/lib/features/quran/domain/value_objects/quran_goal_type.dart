/// Kur'an hedef/miktar birimi (10_DATA_MODEL §4 `QuranGoal.goalType`).
///
/// İçerik değil MİKTAR ölçülür (§2-3): "ne okuduğu" değil "ne kadar
/// okuduğu" — sure/ayet bazında okuma telemetrisi YOKTUR (§18).
enum QuranGoalType { ayah, page, minute }

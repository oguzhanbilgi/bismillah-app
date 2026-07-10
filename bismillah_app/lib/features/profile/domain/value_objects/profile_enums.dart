/// Profil enum'ları (04_ONBOARDING §14; 10_DATA_MODEL §4).
library;

/// Konum belirleme yöntemi. `skipped` tamamen geçerlidir — konum
/// vermeyen kullanıcı ısrar/suçlama görmez (04 §15).
enum LocationMethod { gps, manual, skipped }

/// Metin ton tercihi (04 §14 `tonePreference`).
enum TonePreference { gentle, motivating, minimal }

/// Hesap durumu; `deleting` sırasında sync kuyruğu cancelled olur
/// (10_DATA_MODEL §12-7).
enum AccountStatus { active, deleting }

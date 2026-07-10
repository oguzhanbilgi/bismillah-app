/// Onboarding enum'ları (04_ONBOARDING §14).
///
/// Diğer cevap kovaları (prayerRoutine, quranHabit vb.) onboarding
/// implementasyon görevinde 04 §4–13 metinleriyle birlikte enum'lanır;
/// bu görevde `OnboardingAnswers` onları doğrulanmış kova kodu olarak
/// taşır (varsayılanlar 04 §14 tablosundan).
library;

/// `growthGoal` — profil ana anahtarı (5 kova; varsayılan `reconnect`).
enum OnboardingGoal {
  reconnect,
  buildConsistency,
  learnFoundations,
  deepenConnection,
  findPeace,
}

/// Genel deneyim/seviye kovası (öğrenme yolu seviyesi ve
/// kişiselleştirme kalibrasyonu için).
enum ExperienceLevel { beginner, intermediate, advanced }

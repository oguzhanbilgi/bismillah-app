/// Onboarding hedef seçimi adımındaki odak seçenekleri (TASK 026).
///
/// Paket-bağımsız değer nesnesidir; kullanıcıya görünen etiketler
/// localization'dan gelir. Mevcut [OnboardingGoal] growthGoal KOVASIDIR
/// (04 §14, profil anahtarı) — bu enum ise ekrandaki çoklu seçim
/// seçenekleridir; kova eşlemesi kişiselleştirme görevinde yapılır.
/// Seçim şimdilik yalnız controller state'inde yaşar — KALICI DEĞİLDİR.
enum OnboardingFocusGoal {
  trackPrayers,
  prayOnTime,
  quranHabit,
  dhikrRoutine,
  islamicKnowledge,
}

/// Günlük hedef türü (TASK 033): süre veya sayfa. Stabil `name` ile
/// saklanır; kullanıcıya `.name` gösterilmez.
enum QuranReadingGoalType { minutes, pages }

/// Günlük Kur'an okuma hedefi (TASK 033) — TASK 032'deki yalnız-sayfa
/// modelinin genelleştirilmişi. Yalnız desteklenen tür+miktar
/// kombinasyonlarıyla kurulabilir; desteklenmeyen değer `null` döner
/// (crash yok, kurulum tamamlanmamış sayılır).
final class QuranReadingGoal {
  const QuranReadingGoal._({required this.type, required this.amount});

  final QuranReadingGoalType type;
  final int amount;

  static const List<int> minuteAmounts = [5, 10, 15];
  static const List<int> pageAmounts = [1, 3, 5, 10];

  static List<int> supportedAmounts(QuranReadingGoalType type) =>
      switch (type) {
        QuranReadingGoalType.minutes => minuteAmounts,
        QuranReadingGoalType.pages => pageAmounts,
      };

  /// Desteklenen kombinasyonsa hedef, değilse `null`.
  static QuranReadingGoal? of({
    required QuranReadingGoalType type,
    required int amount,
  }) => supportedAmounts(type).contains(amount)
      ? QuranReadingGoal._(type: type, amount: amount)
      : null;

  /// Saklanan ham değerlerden hedef; bozuk/tanınmayan değer `null`.
  static QuranReadingGoal? fromStored({String? typeName, int? amount}) {
    if (typeName == null || amount == null) {
      return null;
    }
    try {
      return of(
        type: QuranReadingGoalType.values.byName(typeName),
        amount: amount,
      );
    } on ArgumentError {
      return null;
    }
  }
}

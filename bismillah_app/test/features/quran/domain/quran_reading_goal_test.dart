import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 032/033 hedef değer kuralları: yalnız desteklenen kombinasyonlar.
void main() {
  group('QuranReadingGoal.of', () {
    test('yalnız desteklenen dakika değerlerini kabul eder (5/10/15)', () {
      for (final amount in [5, 10, 15]) {
        final goal = QuranReadingGoal.of(
          type: QuranReadingGoalType.minutes,
          amount: amount,
        );
        expect(goal, isNotNull);
        expect(goal!.amount, amount);
        expect(goal.type, QuranReadingGoalType.minutes);
      }
      for (final amount in [0, -5, 7, 20]) {
        expect(
          QuranReadingGoal.of(
            type: QuranReadingGoalType.minutes,
            amount: amount,
          ),
          isNull,
        );
      }
    });

    test('yalnız desteklenen sayfa değerlerini kabul eder (1/3/5/10)', () {
      for (final amount in [1, 3, 5, 10]) {
        expect(
          QuranReadingGoal.of(
            type: QuranReadingGoalType.pages,
            amount: amount,
          ),
          isNotNull,
        );
      }
      for (final amount in [0, -1, 2, 4, 100]) {
        expect(
          QuranReadingGoal.of(type: QuranReadingGoalType.pages, amount: amount),
          isNull,
        );
      }
    });
  });

  group('QuranReadingGoal.fromStored', () {
    test('geçerli saklanmış değerler hedefe dönüşür', () {
      final goal = QuranReadingGoal.fromStored(typeName: 'pages', amount: 3);
      expect(goal, isNotNull);
      expect(goal!.type, QuranReadingGoalType.pages);
      expect(goal.amount, 3);
    });

    test('bozuk/eksik/desteklenmeyen değer null döner (crash yok)', () {
      expect(QuranReadingGoal.fromStored(typeName: null, amount: 3), isNull);
      expect(
        QuranReadingGoal.fromStored(typeName: 'pages', amount: null),
        isNull,
      );
      expect(
        QuranReadingGoal.fromStored(typeName: 'weeks', amount: 3),
        isNull,
      );
      expect(
        QuranReadingGoal.fromStored(typeName: 'pages', amount: 4),
        isNull,
      );
      expect(
        QuranReadingGoal.fromStored(typeName: 'minutes', amount: 3),
        isNull,
      );
    });
  });
}

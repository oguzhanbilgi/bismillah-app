import 'package:bismillah_app/features/quran/data/shared_prefs_quran_reading_preferences_repository.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_preferences.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_arabic_script.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_translation_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 033 tercih deposu: bozuk/eksik veri kurulum tamamlanmamış sayılır;
/// completed bayrağı en son yazıldığı için yarım yazım güvenli taraftadır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repository = SharedPrefsQuranReadingPreferencesRepository();

  test('hiç veri yokken load null döner (kurulum tamamlanmamış)', () async {
    SharedPreferences.setMockInitialValues({});
    final result = await repository.load();
    expect(result.fold(onSuccess: (p) => p, onFailure: (_) => 'f'), isNull);
  });

  test('bayrak true ama tanınmayan enum → null (crash yok)', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_setup_completed': true,
      'bismillah.quran_arabic_script': 'weird-script',
      'bismillah.quran_translation': 'turkish',
      'bismillah.quran_goal_type': 'pages',
      'bismillah.quran_goal_amount': 3,
    });
    final result = await repository.load();
    expect(result.fold(onSuccess: (p) => p, onFailure: (_) => 'f'), isNull);
  });

  test('bayrak true ama desteklenmeyen hedef miktarı → null', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_setup_completed': true,
      'bismillah.quran_arabic_script': 'uthmani',
      'bismillah.quran_translation': 'turkish',
      'bismillah.quran_goal_type': 'pages',
      'bismillah.quran_goal_amount': 4,
    });
    final result = await repository.load();
    expect(result.fold(onSuccess: (p) => p, onFailure: (_) => 'f'), isNull);
  });

  test('yarım yazım güvenli: bayrak true, hedef anahtarları eksik → null',
      () async {
    // save() bayrağı EN SON yazdığı için gerçek yarım yazımda bayrak false
    // kalır; bu test tersini de garantiler — bayrak bir şekilde true olsa
    // bile eksik veri kurulum SAYILMAZ.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_setup_completed': true,
    });
    final result = await repository.load();
    expect(result.fold(onSuccess: (p) => p, onFailure: (_) => 'f'), isNull);
  });

  test('save → load round-trip: tüm tercihler ve completed korunur',
      () async {
    SharedPreferences.setMockInitialValues({});
    final saved = QuranReadingPreferences(
      arabicScript: QuranArabicScript.indopak,
      translation: QuranTranslationPreference.turkish,
      goal: QuranReadingGoal.of(
        type: QuranReadingGoalType.minutes,
        amount: 10,
      )!,
      setupCompleted: true,
    );
    final saveResult = await repository.save(saved);
    expect(saveResult.fold(onSuccess: (_) => true, onFailure: (_) => false),
        isTrue);

    final loaded = (await repository.load()).fold(
      onSuccess: (p) => p,
      onFailure: (_) => null,
    );
    expect(loaded, isNotNull);
    expect(loaded!.arabicScript, QuranArabicScript.indopak);
    expect(loaded.translation, QuranTranslationPreference.turkish);
    expect(loaded.goal.type, QuranReadingGoalType.minutes);
    expect(loaded.goal.amount, 10);
    expect(loaded.setupCompleted, isTrue);

    // Enum'lar stabil NAME ile saklanır (index ASLA).
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bismillah.quran_arabic_script'), 'indopak');
    expect(prefs.getString('bismillah.quran_goal_type'), 'minutes');
    expect(prefs.getBool('bismillah.quran_setup_completed'), isTrue);
  });

  test('eski TASK 032 sayfa hedefi ön-seçim olarak okunur', () async {
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_daily_page_goal': 5,
    });
    final legacy = (await repository.loadLegacyPageGoal()).fold(
      onSuccess: (g) => g,
      onFailure: (_) => null,
    );
    expect(legacy, isNotNull);
    expect(legacy!.type, QuranReadingGoalType.pages);
    expect(legacy.amount, 5);

    // Bozuk eski değer sessizce yok sayılır.
    SharedPreferences.setMockInitialValues({
      'bismillah.quran_daily_page_goal': 'bozuk',
    });
    final corrupt = (await repository.loadLegacyPageGoal()).fold(
      onSuccess: (g) => g,
      onFailure: (_) => null,
    );
    expect(corrupt, isNull);
  });
}

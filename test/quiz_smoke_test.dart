import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/earthquake_quiz_data.dart';
import 'package:edukasi_gempa_malut/screens/games/earthquake_quiz_screen.dart';
import 'package:edukasi_gempa_malut/theme/app_theme.dart';

void main() {
  Future<void> setPhoneSize(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  Future<void> tapNext(WidgetTester tester) async {
    final action = find.byKey(const ValueKey('quiz-action'));
    await tester.ensureVisible(action);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(action);
    await tester.pump(const Duration(milliseconds: 150));
  }

  testWidgets('Pre-test 6 soal bisa diselesaikan tanpa overflow',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EarthquakeQuizScreen(mode: EarthquakeQuizMode.preTest),
      ),
    );
    await tester.pump();

    expect(find.text('Pre-Test'), findsOneWidget);
    expect(find.text('Soal 1 dari 6'), findsOneWidget);

    for (final question in EarthquakeQuizData.preTest) {
      final answer = find.text(question.options[question.correctOptionIndex]);
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(answer);
      await tester.pump();
      await tapNext(tester);
      expect(tester.takeException(), isNull);
    }

    // Semua benar -> skor 100% dan tombol untuk mulai bermain.
    expect(find.text('HASIL PRE-TEST'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('MULAI BERMAIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Post-test memberi umpan balik & perbandingan skor',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const EarthquakeQuizScreen(
          mode: EarthquakeQuizMode.postTest,
          preTestCorrect: 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Post-Test'), findsOneWidget);
    expect(find.text('Benar: 0'), findsOneWidget);

    // Jawaban pertama sengaja salah -> penjelasan langsung muncul.
    await tester.tap(find.byKey(const ValueKey('quiz-option-1')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Belum tepat, tidak apa-apa!'), findsOneWidget);
    expect(find.textContaining('Jawaban benar: A.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tapNext(tester);

    // Soal 2-6 dijawab benar.
    for (int i = 1; i < EarthquakeQuizData.postTest.length; i++) {
      final question = EarthquakeQuizData.postTest[i];
      final answer = find.text(question.options[question.correctOptionIndex]);
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Tepat sekali!'), findsOneWidget);
      await tapNext(tester);
      expect(tester.takeException(), isNull);
    }

    expect(find.text('HASIL POST-TEST'), findsOneWidget);
    expect(find.text('83%'), findsWidgets);
    expect(find.text('PERBANDINGAN SKOR'), findsOneWidget);
    expect(find.text('+66%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

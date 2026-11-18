import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/earthquake_quiz_data.dart';
import 'package:edukasi_gempa_malut/data/quiz_data.dart';

void main() {
  test('Kuis Siaga berisi 12 soal dengan 3 pilihan singkat', () {
    expect(QuizData.questions.length, 12);

    for (final question in QuizData.questions) {
      expect(question.options.length, 3);
      expect(question.correctOptionIndex, inInclusiveRange(0, 2));
      expect(question.explanation.trim(), isNotEmpty);
      expect(question.hint.trim(), isNotEmpty);

      for (final option in question.options) {
        expect(option.trim(), isNotEmpty);
        expect(option.length, lessThanOrEqualTo(60));
      }
    }
  });

  test('Pre-test dan post-test punya jumlah soal yang sama', () {
    expect(EarthquakeQuizData.preTest.length, 6);
    expect(EarthquakeQuizData.postTest.length, 6);
  });

  test('Semua soal pre-test dan post-test memakai 3 pilihan', () {
    final allQuestions = [
      ...EarthquakeQuizData.preTest,
      ...EarthquakeQuizData.postTest,
    ];

    for (final question in allQuestions) {
      expect(question.options.length, 3);
      expect(question.correctOptionIndex, inInclusiveRange(0, 2));
      expect(question.explanation.trim(), isNotEmpty);
    }
  });
}

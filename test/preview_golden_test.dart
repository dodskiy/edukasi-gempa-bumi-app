import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/earthquake_quiz_data.dart';
import 'package:edukasi_gempa_malut/data/education_data.dart';
import 'package:edukasi_gempa_malut/data/quiz_data.dart';
import 'package:edukasi_gempa_malut/data/user_progress_manager.dart';
import 'package:edukasi_gempa_malut/screens/education/education_detail_screen.dart';
import 'package:edukasi_gempa_malut/screens/education/education_list_screen.dart';
import 'package:edukasi_gempa_malut/screens/home_screen.dart';
import 'package:edukasi_gempa_malut/screens/quiz/quiz_screen.dart';
import 'package:edukasi_gempa_malut/screens/splash_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/drop_cover_game_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/earthquake_quiz_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/earthquake_simulation_game_screen.dart';
import 'package:edukasi_gempa_malut/theme/app_theme.dart';

const fontDir = r'C:\Users\Hype AMD\flutter\bin\cache\artifacts\material_fonts';
const bool capturePreviews = bool.fromEnvironment('CAPTURE_PREVIEWS');

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final path = file.contains(':') ? file : '$fontDir\\$file';
    final bytes = await File(path).readAsBytes();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

ThemeData previewTheme() {
  final baseTheme = AppTheme.lightTheme;
  return baseTheme.copyWith(
    textTheme: baseTheme.textTheme.apply(
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['PreviewEmoji'],
    ),
    primaryTextTheme: baseTheme.primaryTextTheme.apply(
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['PreviewEmoji'],
    ),
  );
}

void main() {
  setUpAll(() async {
    if (!capturePreviews) return;

    final roboto = [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
      'roboto-black.ttf',
    ];
    await loadFont('Roboto', roboto);
    await loadFont('Ahem', roboto);
    const emojiFont = r'C:\Windows\Fonts\seguiemj.ttf';
    if (File(emojiFont).existsSync()) {
      await loadFont('PreviewEmoji', [emojiFont]);
    }
    await loadFont('MaterialIcons', ['materialicons-regular.otf']);
  });

  Future<void> tapNext(WidgetTester tester) async {
    final action = find.byKey(const ValueKey('quiz-action'));
    await tester.ensureVisible(action);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(action);
    await tester.pump(const Duration(milliseconds: 150));
  }

  Future<void> finishPreTest(WidgetTester tester) async {
    for (int i = 0; i < EarthquakeQuizData.preTest.length; i++) {
      final option = find.byKey(const ValueKey('quiz-option-0'));
      await tester.ensureVisible(option);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(option);
      await tester.pump();
      await tapNext(tester);
    }
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('MULAI BERMAIN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('preview simulasi', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const EarthquakeSimulationGameScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await finishPreTest(tester);

    // Tutup tutorial.
    await tester.tap(find.text('MULAI SIMULASI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/sim_idle.png'),
    );

    // Mulai gempa dan lindungi diri di meja sebelah.
    await tester.ensureVisible(find.text('MULAI SIMULASI GEMPA'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('MULAI SIMULASI GEMPA'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.keyboard_arrow_right_rounded));
    await tester.pump(const Duration(milliseconds: 900));

    await tester.tap(find.text('DROP'));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.text('COVER'));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.text('HOLD ON'));
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/sim_quake.png'),
    );
  }, skip: !capturePreviews);

  testWidgets('preview splash & home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const SplashScreen(),
      ),
    );
    await tester.pump();
    // Sebelum getaran otomatis (1,2 detik) supaya tampilan stabil.
    await tester.pump(const Duration(milliseconds: 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/splash.png'),
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const HomeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home.png'),
    );
  }, skip: !capturePreviews);

  testWidgets('preview kuis pre & post', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Pre-test: satu jawaban dipilih.
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const EarthquakeQuizScreen(
          key: ValueKey('preview-pre'),
          mode: EarthquakeQuizMode.preTest,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('quiz-option-1')));
    await tester.pump(const Duration(milliseconds: 150));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/quiz_pre.png'),
    );

    // Post-test: umpan balik jawaban salah.
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const EarthquakeQuizScreen(
          key: ValueKey('preview-post'),
          mode: EarthquakeQuizMode.postTest,
          preTestCorrect: 2,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('quiz-option-1')));
    await tester.pump(const Duration(milliseconds: 150));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/quiz_feedback.png'),
    );

    // Lanjutkan semua soal dengan jawaban benar -> layar hasil.
    await tapNext(tester);
    for (int i = 1; i < EarthquakeQuizData.postTest.length; i++) {
      final question = EarthquakeQuizData.postTest[i];
      final answer = find.text(question.options[question.correctOptionIndex]);
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 150));
      await tapNext(tester);
    }
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('HASIL POST-TEST'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/quiz_result.png'),
    );
  }, skip: !capturePreviews);

  testWidgets('preview kuis drop cover hold on', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    UserProgressManager().resetProgress();

    const correctAnswers = [
      'Segera merunduk dan jatuhkan badan ke bawah, jangan berdiri.',
      'Berlindung di bawah meja yang kuat dan kokoh.',
      'Pegang kaki meja erat-erat sampai getaran benar-benar berhenti.',
      'DROP (merunduk) → COVER (berlindung) → HOLD ON (berpegangan)',
      'Merunduk di bawah meja, pegang kaki meja erat-erat.',
      'Merunduk di samping tempat tidur, lindungi kepala dengan bantal.',
      'Menjauh dari rak tinggi, merunduk, dan lindungi kepala.',
    ];

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const DropCoverGameScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/drop_cover_intro.png'),
    );

    for (int i = 0; i < correctAnswers.length; i++) {
      final answer = find.text(correctAnswers[i]);
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 260));

      if (i == 0) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/drop_cover_feedback.png'),
        );
      }

      final action = find.text(
        i == correctAnswers.length - 1 ? 'Lihat Hasil' : 'Soal Berikutnya',
      );
      await tester.ensureVisible(action);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 280));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/drop_cover_finish.png'),
    );
  }, skip: !capturePreviews);

  testWidgets('preview modul', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    UserProgressManager().resetProgress();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const EducationListScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/modul_list.png'),
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: EducationDetailScreen(topic: EducationData.topics.first),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/modul_detail.png'),
    );

    await tester.drag(
      find.byKey(const ValueKey('education-detail-scroll')),
      const Offset(0, -620),
    );
    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/modul_detail_baca.png'),
    );
  }, skip: !capturePreviews);

  testWidgets('preview kuis siaga', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    UserProgressManager().resetProgress();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: previewTheme(),
        home: const QuizScreen(),
      ),
    );
    await tester.pump();

    final firstQuestion = QuizData.questions.first;
    await tester.tap(
      find.text(firstQuestion.options[firstQuestion.correctOptionIndex]),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/kuis_siaga.png'),
    );
  }, skip: !capturePreviews);
}

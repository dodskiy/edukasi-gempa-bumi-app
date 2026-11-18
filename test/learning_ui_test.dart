import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/education_data.dart';
import 'package:edukasi_gempa_malut/data/quiz_data.dart';
import 'package:edukasi_gempa_malut/data/user_progress_manager.dart';
import 'package:edukasi_gempa_malut/screens/education/education_detail_screen.dart';
import 'package:edukasi_gempa_malut/screens/education/education_list_screen.dart';
import 'package:edukasi_gempa_malut/screens/education/video_list_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/drop_cover_game_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/game_hub_screen.dart';
import 'package:edukasi_gempa_malut/screens/home_screen.dart';
import 'package:edukasi_gempa_malut/screens/quiz/quiz_screen.dart';
import 'package:edukasi_gempa_malut/theme/app_theme.dart';

void main() {
  setUp(() {
    UserProgressManager().resetProgress();
  });

  Future<void> setPhoneSize(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  testWidgets('Home menampilkan statistik game pengganti tiga kartu lama',
      (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Kuis Siaga'), findsOneWidget);
    expect(find.text('Drop & Cover'), findsWidgets);
    expect(find.text('Lencana'), findsWidgets);

    // Menu Main & Belajar sudah dihapus dari navigasi bawah agar
    // lencana hanya didapat lewat alur belajar bertahap.
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Darurat'), findsOneWidget);
    expect(find.text('Main'), findsNothing);
    expect(find.text('Belajar'), findsNothing);

    expect(find.text('Titik Kumpul'), findsNothing);
    expect(find.text('Tas Siaga'), findsNothing);
    expect(find.text('Info BMKG'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Modul memakai poin aktivitas, bukan bintang', (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const EducationListScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Modul Belajar Siaga Gempa'), findsOneWidget);
    expect(find.text('20 poin / modul'), findsOneWidget);
    expect(find.textContaining('+20 poin'), findsWidgets);
    expect(find.textContaining('★'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Membaca modul sampai bawah mengisi poin aktivitas',
      (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(
      wrap(EducationDetailScreen(topic: EducationData.topics.first)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Poin Aktivitas Modul'), findsOneWidget);
    expect(find.text('Progres baca 0%'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('education-detail-scroll')),
      const Offset(0, -4000),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));

    final pm = UserProgressManager();
    expect(pm.isModuleCompleted('malut_geology'), isTrue);
    expect(pm.moduleActivityPoints('malut_geology'), 20);
    expect(find.text('Modul Selesai Dibaca!'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Video memakai poin aktivitas dan tanpa bintang', (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const VideoListScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Video Edukasi Gempa'), findsOneWidget);
    expect(find.text('10 poin / video'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kuis Drop Cover Hold On tampil dengan poin aktivitas',
      (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const DropCoverGameScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kuis Drop, Cover & Hold On'), findsOneWidget);
    expect(find.text('0 poin'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Semua soal Drop Cover Hold On muat di layar kecil tanpa emoji',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    const correctAnswers = [
      'Segera merunduk dan jatuhkan badan ke bawah, jangan berdiri.',
      'Berlindung di bawah meja yang kuat dan kokoh.',
      'Pegang kaki meja erat-erat sampai getaran benar-benar berhenti.',
      'DROP (merunduk) → COVER (berlindung) → HOLD ON (berpegangan)',
      'Merunduk di bawah meja, pegang kaki meja erat-erat.',
      'Merunduk di samping tempat tidur, lindungi kepala dengan bantal.',
      'Menjauh dari rak tinggi, merunduk, dan lindungi kepala.',
    ];

    await tester.pumpWidget(wrap(const DropCoverGameScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    for (int i = 0; i < correctAnswers.length; i++) {
      final answer = find.text(correctAnswers[i]);
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Tepat sekali!'), findsOneWidget);
      expect(find.textContaining('🎉'), findsNothing);
      expect(tester.takeException(), isNull);

      final action = find.text(
        i == correctAnswers.length - 1 ? 'Lihat Hasil' : 'Soal Berikutnya',
      );
      await tester.ensureVisible(action);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }

    expect(find.text('MISI SELESAI'), findsOneWidget);
    expect(find.text('Hebat, Kamu Jagoan Siaga!'), findsOneWidget);
    expect(find.text('Main Lagi'), findsOneWidget);
    expect(find.text('Kembali ke Arena'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kuis Siaga memakai poin dan memberi umpan balik',
      (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const QuizScreen()));
    await tester.pump();

    expect(find.text('Kuis Siaga Gempa'), findsOneWidget);
    expect(find.text('Misi Kuis Siaga'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);

    final firstQuestion = QuizData.questions.first;
    await tester.tap(
      find.text(firstQuestion.options[firstQuestion.correctOptionIndex]),
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Tepat sekali!'), findsOneWidget);
    expect(
      find.text('Benar! Jawabanmu tepat (+10 poin aktivitas).'),
      findsOneWidget,
    );
    expect(find.text('Soal Berikutnya'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Semua soal Kuis Siaga bisa diselesaikan di layar kecil',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(wrap(const QuizScreen()));
    await tester.pump();

    for (int i = 0; i < QuizData.questions.length; i++) {
      final question = QuizData.questions[i];
      final answer = find.text(
        question.options[question.correctOptionIndex],
      );
      await tester.ensureVisible(answer);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 140));

      expect(find.text('Tepat sekali!'), findsOneWidget);
      expect(find.textContaining('🎉'), findsNothing);
      expect(tester.takeException(), isNull);

      final action = find.text(
        i == QuizData.questions.length - 1
            ? 'Lihat Poin & Lencana'
            : 'Soal Berikutnya',
      );
      await tester.ensureVisible(action);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 220));
      expect(tester.takeException(), isNull);
    }

    expect(find.text('Pahlawan Siaga Gempa'), findsOneWidget);
    expect(find.text('/ 120 poin'), findsOneWidget);
    expect(find.text('Benar 12 dari 12 soal'), findsOneWidget);
    expect(find.text('Ulangi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Modul memakai ikon, bukan emoji, dan mudah dibaca',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(wrap(const EducationListScreen()));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Modul Belajar Siaga Gempa'), findsOneWidget);
    expect(find.text('Kenapa Maluku Utara Sering Gempa?'), findsOneWidget);
    expect(find.text('Saat Gempa: Drop, Cover, Hold On'), findsOneWidget);

    // Emoji dekoratif sudah diganti ikon Material.
    expect(find.text('🌍'), findsNothing);
    expect(find.text('📚'), findsNothing);
    expect(find.text('🎬'), findsNothing);
    expect(find.text('📖'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail modul memakai paragraf pendek dan kartu Ingat',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(
      wrap(EducationDetailScreen(topic: EducationData.topics.first)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Poin Penting'), findsOneWidget);
    expect(find.text('Baca Pelan-Pelan'), findsOneWidget);
    expect(find.text('Ingat, ya!'), findsOneWidget);
    expect(
      find.textContaining('Bumi kita tersusun dari kepingan batu raksasa'),
      findsOneWidget,
    );
    expect(find.text('💡'), findsNothing);
    expect(find.text('📖'), findsNothing);
    expect(find.text('⚠️'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arena game menampilkan hadiah poin, bukan rating bintang',
      (tester) async {
    await setPhoneSize(tester, const Size(390, 844));

    await tester.pumpWidget(wrap(const GameHubScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('+50 poin'), findsWidgets);
    expect(find.text('+70 poin'), findsOneWidget);
    expect(find.textContaining('★'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

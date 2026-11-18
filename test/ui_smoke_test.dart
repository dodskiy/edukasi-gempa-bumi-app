import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/earthquake_quiz_data.dart';
import 'package:edukasi_gempa_malut/screens/home_screen.dart';
import 'package:edukasi_gempa_malut/screens/splash_screen.dart';
import 'package:edukasi_gempa_malut/screens/games/earthquake_simulation_game_screen.dart';
import 'package:edukasi_gempa_malut/theme/app_theme.dart';

void main() {
  Future<void> setPhoneSize(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
  }

  testWidgets('Splash & Home tampil tanpa overflow di layar kecil',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);

    // Gulir sampai bawah untuk memastikan seluruh kartu aman.
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -1800));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Splash & Home tampil tanpa overflow di layar besar',
      (tester) async {
    await setPhoneSize(tester, const Size(480, 900));

    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const HomeScreen()),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  Future<void> finishPreTest(WidgetTester tester) async {
    expect(find.text('Pre-Test'), findsOneWidget);

    for (int i = 0; i < EarthquakeQuizData.preTest.length; i++) {
      final option = find.byKey(const ValueKey('quiz-option-0'));
      await tester.ensureVisible(option);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(option);
      await tester.pump();

      final action = find.byKey(const ValueKey('quiz-action'));
      await tester.ensureVisible(action);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.text('MULAI BERMAIN'), findsOneWidget);
    await tester.tap(find.text('MULAI BERMAIN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('Simulasi gempa tampil & bisa dimainkan di layar kecil',
      (tester) async {
    await setPhoneSize(tester, const Size(360, 640));

    await tester.pumpWidget(
      const MaterialApp(home: EarthquakeSimulationGameScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Pre-test tampil sebelum bermain.
    await finishPreTest(tester);
    expect(tester.takeException(), isNull);

    // Tutorial awal tampil setelah pre-test.
    expect(find.text('Drop, Cover & Hold On'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('MULAI SIMULASI'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);

    // Mulai gempa (gulir dulu ke panel alarm).
    await tester.ensureVisible(find.text('MULAI SIMULASI GEMPA'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('MULAI SIMULASI GEMPA'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);

    // Lakukan Drop lewat tombol aksi.
    await tester.ensureVisible(find.text('DROP'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('DROP'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    // Gulir ke bawah agar panel kontrol & alarm ikut diperiksa.
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);
  });
}

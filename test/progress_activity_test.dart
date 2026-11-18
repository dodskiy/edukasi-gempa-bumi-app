import 'package:flutter_test/flutter_test.dart';
import 'package:edukasi_gempa_malut/data/user_progress_manager.dart';

void main() {
  setUp(() {
    UserProgressManager().resetProgress();
  });

  test('membaca modul memberi poin aktivitas bertahap', () {
    final pm = UserProgressManager();

    expect(pm.updateModuleReadProgress('malut_geology', 10), 0);
    expect(pm.activityPoints, 0);

    expect(pm.updateModuleReadProgress('malut_geology', 25), 5);
    expect(pm.updateModuleReadProgress('malut_geology', 50), 5);
    expect(pm.updateModuleReadProgress('malut_geology', 75), 5);
    expect(pm.updateModuleReadProgress('malut_geology', 100), 5);

    expect(pm.activityPoints, 20);
    expect(pm.moduleReadPercent('malut_geology'), 100);
    expect(pm.moduleActivityPoints('malut_geology'), 20);
    expect(pm.isModuleCompleted('malut_geology'), isTrue);
    expect(pm.completedModuleCount, 1);
    expect(pm.isStoryRead, isTrue);
    expect(pm.unlockedBadgeIds, contains('pembaca_bijak'));

    // Membaca ulang tidak menambah poin.
    expect(pm.updateModuleReadProgress('malut_geology', 100), 0);
    expect(pm.activityPoints, 20);
  });

  test('setiap video hanya memberi poin sekali', () {
    final pm = UserProgressManager();

    expect(pm.completeVideoWatched(videoId: 'apa_itu_gempa'), 10);
    expect(pm.completeVideoWatched(videoId: 'apa_itu_gempa'), 0);
    expect(pm.completeVideoWatched(videoId: 'jenis_jenis_gempa'), 10);

    expect(pm.activityPoints, 20);
    expect(pm.watchedVideoCount, 2);
    expect(pm.totalVideoActivityPoints, 20);
    expect(pm.isVideoCompleted('apa_itu_gempa'), isTrue);
    expect(pm.isVideoWatched, isTrue);
    expect(pm.unlockedBadgeIds, contains('penonton_teladan'));
  });

  test('hasil Drop, Cover, Hold On dicatat sebagai skor terbaik', () {
    final pm = UserProgressManager();

    pm.recordDropCoverResult(4);
    expect(pm.hasPlayedDropCover, isTrue);
    expect(pm.dropCoverBestScore, 4);
    expect(pm.activityPoints, 40);
    expect(pm.unlockedBadgeIds, contains('pahlawan_siaga'));

    pm.recordDropCoverResult(2);
    expect(pm.dropCoverBestScore, 4);
    expect(pm.activityPoints, 60);
  });

  test('skor kuis terakhir tersimpan untuk statistik home', () {
    final pm = UserProgressManager();

    pm.completeQuiz(score: 70, maxScore: 100);

    expect(pm.isQuizCompleted, isTrue);
    expect(pm.lastQuizScore, 70);
    expect(pm.lastQuizMax, 100);
    expect(pm.activityPoints, 35);
    expect(pm.unlockedBadgeIds, contains('cerdas_tektonik'));
  });
}

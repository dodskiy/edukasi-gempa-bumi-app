import 'package:flutter/material.dart';

class BadgeItem {
  final String id;
  final String emoji;
  final String title;
  final String desc;
  final bool unlocked;
  final String
      category; // 'Membaca', 'Nonton Video', 'Belajar Kuis', 'Main Game', 'Juara 4 Pilar', 'Level Puncak'
  final String howToUnlock;

  const BadgeItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.unlocked,
    this.category = 'Umum',
    this.howToUnlock = 'Selesaikan misi terkait untuk membuka lencana ini.',
  });
}

class UserProgressManager {
  // Singleton pattern
  static final UserProgressManager _instance = UserProgressManager._internal();
  factory UserProgressManager() => _instance;
  UserProgressManager._internal();

  // Observable notifier untuk trigger update UI otomatis
  static final ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  // Status 4 Pilar Skenario Belajar Siswa SD (Mulai dari FALSE / Awal Permainan)
  bool isStoryRead = false; // 1. Membaca Modul Edukasi
  bool isVideoWatched = false; // 2. Menonton Video Edukasi
  bool isQuizCompleted = false; // 3. Belajar & Menjawab Kuis
  bool isGamePlayed = false; // 4. Bermain Game Interaktif
  bool isDailyBadgeClaimed = false; // 5. Klaim Juara 4 Pilar

  // Skor & XP — Mulai dari 0 untuk Siswa Baru
  int userXp = 0;
  final int maxXp = 1000;

  // Poin aktivitas belajar & bermain.
  // XP di atas adalah total poin aktivitas yang tampil di seluruh aplikasi.
  final Map<String, int> _moduleReadPercent = {};
  final Map<String, int> _moduleActivityPoints = {};
  final Map<String, int> _videoActivityPoints = {};
  final Set<String> watchedVideoIds = {};
  final Set<String> completedModuleIds = {};

  int lastQuizScore = 0;
  int lastQuizMax = 0;
  int dropCoverBestScore = 0;
  bool hasPlayedDropCover = false;

  int get activityPoints => userXp;

  int moduleReadPercent(String topicId) => _moduleReadPercent[topicId] ?? 0;

  int moduleActivityPoints(String topicId) =>
      _moduleActivityPoints[topicId] ?? 0;

  bool isModuleCompleted(String topicId) => moduleReadPercent(topicId) >= 100;

  int get completedModuleCount => completedModuleIds.length;

  int get totalModuleActivityPoints =>
      _moduleActivityPoints.values.fold(0, (a, b) => a + b);

  bool isVideoCompleted(String videoId) => watchedVideoIds.contains(videoId);

  int videoActivityPoints(String videoId) => _videoActivityPoints[videoId] ?? 0;

  int get watchedVideoCount => watchedVideoIds.length;

  int get totalVideoActivityPoints =>
      _videoActivityPoints.values.fold(0, (a, b) => a + b);

  int get userLevel {
    if (userXp >= 1000) return 5;
    if (userXp >= 700) return 4;
    if (userXp >= 400) return 3;
    if (userXp >= 150) return 2;
    return 1;
  }

  String get userRank {
    if (userXp >= 1000) return 'Legenda Siaga Malut';
    if (userXp >= 700) return 'Pahlawan Maluku Utara';
    if (userXp >= 400) return 'Penjaga Aman';
    if (userXp >= 150) return 'Sahabat Tanggap';
    return 'Siaga Pemula';
  }

  // Lencana yang terbuka: DIMULAI DARI 0 (KOSONG), didapat 1 per 1!
  final Set<String> unlockedBadgeIds = {};

  List<BadgeItem> get allBadges => [
        // 1. Membaca
        BadgeItem(
          id: 'pembaca_bijak',
          emoji: '📚',
          title: 'Pembaca Bijak',
          desc: 'Membaca modul & materi edukasi gempa bumi Malut.',
          unlocked: unlockedBadgeIds.contains('pembaca_bijak'),
          category: 'Membaca',
          howToUnlock:
              'Buka dan baca modul edukasi gempa bumi di menu Belajar.',
        ),

        // 2. Menonton Video
        BadgeItem(
          id: 'penonton_teladan',
          emoji: '🎬',
          title: 'Penonton Teladan',
          desc: 'Menonton video simulasi sains & panduan siaga gempa.',
          unlocked: unlockedBadgeIds.contains('penonton_teladan'),
          category: 'Menonton',
          howToUnlock: 'Tonton video edukasi interaktif di menu Video Edukasi.',
        ),

        // 3. Belajar / Kuis
        BadgeItem(
          id: 'cerdas_tektonik',
          emoji: '🧠',
          title: 'Cerdas Tektonik',
          desc: 'Menjawab kuis pengetahuan gempa Malut dengan baik.',
          unlocked: unlockedBadgeIds.contains('cerdas_tektonik'),
          category: 'Belajar Kuis',
          howToUnlock: 'Selesaikan 8 soal kuis di menu Kuis Pahlawan Siaga.',
        ),

        // 4. Game: Detektif Zona Aman
        BadgeItem(
          id: 'detektif_zona_aman',
          emoji: '🏫',
          title: 'Detektif Zona Aman',
          desc: 'Menemukan titik aman berlindung pada game simulasi gempa.',
          unlocked: unlockedBadgeIds.contains('detektif_zona_aman'),
          category: 'Main Game',
          howToUnlock:
              'Mainkan game Misi Zona Aman dan temukan tempat berlindung.',
        ),

        // 5. Game: Drop Cover Hold On
        BadgeItem(
          id: 'pahlawan_siaga',
          emoji: '🛡️',
          title: 'Pahlawan Siaga',
          desc: 'Menguasai respon cepat Drop, Cover & Hold On.',
          unlocked: unlockedBadgeIds.contains('pahlawan_siaga'),
          category: 'Main Game',
          howToUnlock: 'Mainkan game latihan refleks Drop, Cover, Hold On.',
        ),

        // 6. Game: Master Evakuasi Gedung Runtuh
        BadgeItem(
          id: 'master_evakuasi',
          emoji: '🏃',
          title: 'Master Evakuasi',
          desc:
              'Berhasil menemukan jalan keluar evakuasi saat simulasi gedung.',
          unlocked: unlockedBadgeIds.contains('master_evakuasi'),
          category: 'Main Game',
          howToUnlock:
              'Selesaikan simulasi penyelamatan di game Gedung Runtuh.',
        ),

        // 7. Juara 4 Pilar (Prestasi Puncak)
        BadgeItem(
          id: 'juara_mitigasi',
          emoji: '🏆',
          title: 'Juara Tanggap Bencana',
          desc:
              'Menyelesaikan 4 pilar lengkap: Membaca, Menonton, Kuis, & Game!',
          unlocked: unlockedBadgeIds.contains('juara_mitigasi'),
          category: 'Juara 4 Pilar',
          howToUnlock:
              'Tuntaskan seluruh 4 pilar aktivitas petualangan hari ini.',
        ),

        // 8. Legenda Siaga Malut (Level XP Maksimal)
        BadgeItem(
          id: 'legenda_malut',
          emoji: '🌟',
          title: 'Legenda Siaga Maluku Utara',
          desc: 'Capai 1000 XP sebagai pahlawan siaga tertinggi Malut.',
          unlocked: unlockedBadgeIds.contains('legenda_malut'),
          category: 'Level Puncak',
          howToUnlock: 'Kumpulkan total 1000 XP dari belajar dan bermain game.',
        ),
      ];

  /// Dipanggil saat siswa membaca modul cerita / materi edukasi.
  ///
  /// [percent] adalah progres baca 0–100. Poin diberikan bertahap setiap
  /// kelipatan 25% (5 poin per tahap, maksimal 20 poin per modul).
  /// Mengembalikan jumlah poin yang baru didapat pada pemanggilan ini.
  int updateModuleReadProgress(String topicId, int percent) {
    final int next = percent.clamp(0, 100);
    final int previous = moduleReadPercent(topicId);
    if (next <= previous) return 0;

    final int previousSteps = previous ~/ 25;
    final int nextSteps = next ~/ 25;
    final int gained = (nextSteps - previousSteps) * 5;

    _moduleReadPercent[topicId] = next;
    if (gained > 0) {
      _moduleActivityPoints[topicId] = moduleActivityPoints(topicId) + gained;
      userXp = (userXp + gained).clamp(0, maxXp);
    }

    if (next >= 100) {
      completedModuleIds.add(topicId);
      isStoryRead = true;
      unlockedBadgeIds.add('pembaca_bijak');
    }

    _checkAutoBadges();
    progressNotifier.value++;
    return gained;
  }

  /// Dipanggil saat siswa membaca modul cerita / materi edukasi (lama).
  void completeStoryRead({int bonusXp = 25}) {
    if (!isStoryRead) {
      isStoryRead = true;
      userXp = (userXp + bonusXp).clamp(0, maxXp);
      unlockedBadgeIds.add('pembaca_bijak');
      _checkAutoBadges();
      progressNotifier.value++;
    }
  }

  /// Dipanggil saat siswa menonton satu video edukasi.
  ///
  /// Setiap video hanya memberi poin satu kali. Jika [videoId] tidak diisi,
  /// metode lama tetap berjalan dan hanya memberi poin sekali untuk semua video.
  int completeVideoWatched({String? videoId, int bonusXp = 10}) {
    if (videoId != null) {
      if (watchedVideoIds.contains(videoId)) return 0;
      watchedVideoIds.add(videoId);
      _videoActivityPoints[videoId] = bonusXp;
      isVideoWatched = true;
      unlockedBadgeIds.add('penonton_teladan');
      userXp = (userXp + bonusXp).clamp(0, maxXp);
      _checkAutoBadges();
      progressNotifier.value++;
      return bonusXp;
    }

    if (!isVideoWatched) {
      isVideoWatched = true;
      userXp = (userXp + bonusXp).clamp(0, maxXp);
      unlockedBadgeIds.add('penonton_teladan');
      _checkAutoBadges();
      progressNotifier.value++;
      return bonusXp;
    }
    return 0;
  }

  /// Dipanggil saat kuis selesai.
  void completeQuiz({int bonusXp = 35, int score = 0, int maxScore = 0}) {
    if (score > 0) lastQuizScore = score;
    if (maxScore > 0) lastQuizMax = maxScore;
    if (!isQuizCompleted) {
      isQuizCompleted = true;
      userXp = (userXp + bonusXp).clamp(0, maxXp);
      unlockedBadgeIds.add('cerdas_tektonik');
      _checkAutoBadges();
    }
    progressNotifier.value++;
  }

  /// Simpan hasil mini-game Drop, Cover, Hold On.
  /// Poin aktivitas diberikan sesuai jumlah jawaban benar.
  void recordDropCoverResult(int correctAnswers) {
    hasPlayedDropCover = true;
    if (correctAnswers > dropCoverBestScore) {
      dropCoverBestScore = correctAnswers;
    }
    completeGameStep(
      badgeId: 'pahlawan_siaga',
      bonusXp: (correctAnswers * 10).clamp(0, 70),
    );
  }

  /// Dipanggil setelah user menyelesaikan mini-game apa saja
  void completeGameStep({String? badgeId, int bonusXp = 50}) {
    isGamePlayed = true;
    userXp = (userXp + bonusXp).clamp(0, maxXp);
    if (badgeId != null) {
      unlockedBadgeIds.add(badgeId);
    }
    _checkAutoBadges();
    progressNotifier.value++;
  }

  void _checkAutoBadges() {
    // Jika 4 pilar sudah selesai, buka lencana Juara Tanggap Bencana
    if (isStoryRead && isVideoWatched && isQuizCompleted && isGamePlayed) {
      unlockedBadgeIds.add('juara_mitigasi');
    }
    if (userXp >= maxXp) {
      unlockedBadgeIds.add('legenda_malut');
    }
  }

  /// Dipanggil saat user mengklik klaim lencana di kartu petualangan
  bool claimDailyBadge() {
    if (isStoryRead &&
        isVideoWatched &&
        isQuizCompleted &&
        isGamePlayed &&
        !isDailyBadgeClaimed) {
      isDailyBadgeClaimed = true;
      unlockedBadgeIds.add('juara_mitigasi');
      userXp = (userXp + 100).clamp(0, maxXp);
      _checkAutoBadges();
      progressNotifier.value++;
      return true;
    }
    return false;
  }

  /// Reset semua progres ke kondisi awal baru (0 lencana, 0 XP)
  void resetProgress() {
    isStoryRead = false;
    isVideoWatched = false;
    isQuizCompleted = false;
    isGamePlayed = false;
    isDailyBadgeClaimed = false;
    userXp = 0;
    unlockedBadgeIds.clear();
    _moduleReadPercent.clear();
    _moduleActivityPoints.clear();
    _videoActivityPoints.clear();
    watchedVideoIds.clear();
    completedModuleIds.clear();
    lastQuizScore = 0;
    lastQuizMax = 0;
    dropCoverBestScore = 0;
    hasPlayedDropCover = false;
    progressNotifier.value++;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'education/education_list_screen.dart';
import 'education/video_list_screen.dart';
import 'games/game_hub_screen.dart';
import 'games/earthquake_simulation_game_screen.dart';
import 'games/drop_cover_game_screen.dart';
import 'quiz/quiz_screen.dart';
import 'emergency/emergency_screen.dart';
import '../data/user_progress_manager.dart';
import '../theme/app_palette.dart';
import '../widgets/turtle_painter.dart';

// Layar lain (Game Hub & Modul Edukasi) memakai alias KikiPainter dari
// library ini. Re-export menjaga kompatibilitas tanpa mengubah layar tersebut.
export '../widgets/turtle_painter.dart'
    show TurtlePainter, TurtleExpression, KikiPainter, KikiExpression;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatController;
  int _factIndex = 0;

  static const Color sky = AppPalette.sky;
  static const Color skyDeep = AppPalette.skyDeep;
  static const Color sunny = AppPalette.sunny;
  static const Color sunnyDeep = AppPalette.sunnyDeep;
  static const Color coral = AppPalette.coral;
  static const Color coralDeep = AppPalette.coralDeep;
  static const Color mint = AppPalette.mint;
  static const Color mintDeep = AppPalette.mintDeep;
  static const Color grape = AppPalette.grape;
  static const Color cream = AppPalette.cream;
  static const Color cardBg = AppPalette.cardBg;
  static const Color navy = AppPalette.navy;
  static const Color inkSoft = AppPalette.inkSoft;
  static const Color lineBorder = AppPalette.lineBorder;
  static const Color shadow3D = AppPalette.shadow3D;
  static const Color skyMist = AppPalette.skyMist;
  static const Color coralSoft = AppPalette.coralSoft;

  static const List<String> _earthquakeFacts = [
    'Gempa bumi belum bisa diprediksi. Karena itu, menyiapkan tas siaga dan rencana evakuasi adalah cara terbaik untuk tetap aman.',
    'Saat gempa, jangan gunakan lift. Setelah guncangan berhenti, keluarlah lewat tangga darurat dengan tenang.',
    'Maluku Utara berada di zona pertemuan lempeng tektonik. Latihan evakuasi rutin membuat kita lebih siap saat gempa terjadi.',
    'Ingat Drop, Cover, Hold On: merunduk, lindungi kepala, dan berpegangan pada meja yang kokoh sampai guncangan berhenti.',
    'Titik kumpul harus berada di area terbuka, jauh dari gedung tinggi, tiang listrik, dan pohon besar.',
    'Gempa besar di laut bisa memicu tsunami. Jika merasakan guncangan kuat di dekat pantai, segera menuju tempat yang lebih tinggi.',
    'Setelah gempa, hindari bangunan yang retak atau miring. Dengarkan informasi resmi dari BMKG sebelum kembali ke dalam gedung.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _factIndex = DateTime.now().day % _earthquakeFacts.length;
    UserProgressManager.progressNotifier.addListener(_onProgressUpdated);
  }

  void _onProgressUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    UserProgressManager.progressNotifier.removeListener(_onProgressUpdated);
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 3) {
      // Tab Lencana
      _showAllBadgesDialog();
      setState(() => _currentNavIndex = 0);
    } else if (index == 4) {
      // Tab Darurat
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmergencyScreen()),
      ).then((_) => setState(() => _currentNavIndex = 0));
    }
  }

  void _showAllBadgesDialog() {
    final pm = UserProgressManager();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final unlockedCount = pm.unlockedBadgeIds.length;
          final totalBadges = pm.allBadges.length;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            title: Row(
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CustomPaint(
                    painter: TurtlePainter(expression: TurtleExpression.proud),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lencana Kura Siaga',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: navy),
                      ),
                      Text(
                        'Terbuka $unlockedCount dari $totalBadges Lencana ⭐',
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF2A70B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: pm.allBadges.map((b) {
                    return _buildBadgeDialogItem(b);
                  }).toList(),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            actions: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (confirmCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text('Mulai Ulang Progres?',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: navy)),
                          content: const Text(
                            'Semua lencana dan XP akan kembali ke awal (0) agar dapat dicoba lagi dari awal permainan.',
                            style: TextStyle(fontSize: 13, color: inkSoft),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                pm.resetProgress();
                                Navigator.pop(confirmCtx);
                                setDialogState(() {});
                                setState(() {});
                              },
                              child: const Text('Reset Awal 🔄'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded,
                        size: 16, color: inkSoft),
                    label: const Text(
                      'Reset Awal',
                      style: TextStyle(fontSize: 12, color: inkSoft),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyDeep,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Tutup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadgeDialogItem(BadgeItem b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: b.unlocked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: b.unlocked ? const Color(0xFFFFD166) : const Color(0xFFE2E8F0),
          width: b.unlocked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: b.unlocked ? 1.0 : 0.45,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: b.unlocked ? sunny : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(b.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: b.unlocked
                            ? const Color(0xFFE6F9EE)
                            : const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: b.unlocked
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: b.unlocked ? navy : inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  b.desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: b.unlocked ? navy.withValues(alpha: 0.85) : inkSoft,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  b.unlocked ? '✅ Lencana Terbuka!' : '🔒 ${b.howToUnlock}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: b.unlocked
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            b.unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 20,
            color: b.unlocked ? mintDeep : const Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFEBFA),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: cream,
            child: Stack(
              children: [
                // Scrollable Body
                Positioned.fill(
                  bottom: 82,
                  child: Stack(
                    children: [
                      // Ornamen latar lembut: awan, gelombang, dan titik.
                      const Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _HomeBackdropPainter(),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(),

                            // Content Container
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 18),
                                  _buildSectionTitleWithAction(
                                    '🎮 Siaga Hari Ini',
                                    'Arena Game',
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GameHubScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildGameStatRow(),
                                  const SizedBox(height: 20),

                                  // Signature: 🗺️ Petualangan Hari Ini
                                  _buildAdventureQuestCard(),
                                  const SizedBox(height: 24),

                                  // Fakta siaga harian
                                  _buildSectionTitleWithAction(
                                    '🧠 Fakta Siaga Hari Ini',
                                    'Fakta Lain',
                                    () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _factIndex = (_factIndex + 1) %
                                            _earthquakeFacts.length;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _buildFactCard(),
                                  const SizedBox(height: 24),

                                  // Section: 🎮 Misi Latihan Cepat
                                  _buildSectionTitleWithAction(
                                      '🎮 Misi Latihan Cepat', 'Lihat Semua',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const GameHubScreen()),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                  _buildActivityGrid(),
                                  const SizedBox(height: 20),

                                  // Section: 🎬 Video Edukasi Gempa
                                  _buildSectionTitleWithAction(
                                      '🎬 Video Edukasi Online', 'Buka Galeri',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const VideoListScreen()),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                  _buildVideoQuickCard(),
                                  const SizedBox(height: 22),
                                  _buildFooterNote(),
                                  const SizedBox(height: 26),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomNavigationBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final pm = UserProgressManager();
    final int dailyStepsDone = [
      pm.isStoryRead,
      pm.isVideoWatched,
      pm.isQuizCompleted,
      pm.isGamePlayed,
    ].where((done) => done).length;

    final TurtleExpression topBarExpression = dailyStepsDone >= 4
        ? TurtleExpression.proud
        : dailyStepsDone == 0
            ? TurtleExpression.alert
            : TurtleExpression.happy;

    // Batas XP tiap level untuk bar kemajuan.
    final int levelFloor = switch (pm.userLevel) {
      1 => 0,
      2 => 150,
      3 => 400,
      4 => 700,
      _ => 1000,
    };
    final int levelCeil = switch (pm.userLevel) {
      1 => 150,
      2 => 400,
      3 => 700,
      _ => 1000,
    };
    final double xpProgress = levelFloor == levelCeil
        ? 1.0
        : ((pm.userXp - levelFloor) / (levelCeil - levelFloor)).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3331355A),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi langit: matahari, awan, bintang, dan gelombang.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) => CustomPaint(
                  painter: _HeaderBackdropPainter(
                    t: _floatController.value,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            child: Column(
              children: [
                // Baris profil
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '🐢 Halo adik-adik, selamat datang di aplikasi edukasi bencana gempa bumi!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final double bob = math.sin(
                                _floatController.value * math.pi * 2,
                              ) *
                              2.5;
                          return Transform.translate(
                            offset: Offset(0, bob),
                            child: child,
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ScaleTransition(
                              scale: topBarExpression == TurtleExpression.alert
                                  ? _pulseAnimation
                                  : const AlwaysStoppedAnimation(1.0),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: sunny, width: 3.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(7),
                                child: CustomPaint(
                                  painter: TurtlePainter(
                                      expression: topBarExpression),
                                ),
                              ),
                            ),
                            // Stiker bintang di sudut avatar.
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 23,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: sunny,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33F2A70B),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),

                    // Sapaan
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Selamat Datang di',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            'Aplikasi Edukasi Gempa Bumi',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Yuk belajar sambil main, biar makin siaga',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFFEAF7FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Badge level
                    _buildLevelBadge(pm.userLevel),
                  ],
                ),
                const SizedBox(height: 14),

                // Bar XP / peringkat
                _buildXpBar(pm, xpProgress, levelCeil),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎯', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Progress Hari Ini',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1),
                      ),
                      child: Text(
                        dailyStepsDone >= 4
                            ? '✅ 4/4 Misi'
                            : '$dailyStepsDone/4 Misi',
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),

                Row(
                  children: List.generate(4, (i) {
                    final bool filled = i < dailyStepsDone;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                        decoration: BoxDecoration(
                          color: filled
                              ? null
                              : Colors.white.withValues(alpha: 0.26),
                          gradient: filled
                              ? const LinearGradient(
                                  colors: [sunny, Color(0xFFFFE08A)])
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: filled
                              ? const [
                                  BoxShadow(
                                    color: Color(0x40F2A70B),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LEVEL',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: Color(0xFFEAF7FF),
              letterSpacing: 0.8,
            ),
          ),
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBar(UserProgressManager pm, double xpProgress, int levelCeil) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppPalette.sunnyGradient,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 10, color: AppPalette.coralDark),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          pm.userRank,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pm.userXp} / $levelCeil XP',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(sunny),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatRow() {
    final pm = UserProgressManager();
    final String quizValue = pm.isQuizCompleted
        ? (pm.lastQuizScore > 0 ? '${pm.lastQuizScore} poin' : 'Selesai')
        : 'Ayo main';
    final String dropCoverValue =
        pm.hasPlayedDropCover ? '${pm.dropCoverBestScore}/7' : 'Coba dulu';
    final String badgeValue =
        '${pm.unlockedBadgeIds.length}/${pm.allBadges.length}';

    return Row(
      children: [
        _buildGameStatPill(
          icon: '🧠',
          label: 'Kuis Siaga',
          value: quizValue,
          tint: AppPalette.grapeDeep,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildGameStatPill(
          icon: '🛡️',
          label: 'Drop & Cover',
          value: dropCoverValue,
          tint: AppPalette.sunnyDeep,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DropCoverGameScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildGameStatPill(
          icon: '🏆',
          label: 'Lencana',
          value: badgeValue,
          tint: AppPalette.mintDeep,
          onTap: _showAllBadgesDialog,
        ),
      ],
    );
  }

  Widget _buildGameStatPill({
    required String icon,
    required String label,
    required String value,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFFFDF8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineBorder, width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: shadow3D,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tint.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(icon, style: const TextStyle(fontSize: 17)),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: inkSoft,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: navy,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // KARTU FAKTA SIAGA (fitur baru, bisa ganti fakta)
  // ============================================================
  Widget _buildFactCard() {
    final String fact = _earthquakeFacts[_factIndex];
    final int total = _earthquakeFacts.length;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFEFF9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppPalette.skySoft.withValues(alpha: 0.85),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: skyDeep.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppPalette.sunnySoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sunny.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🧠', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tahukah Kamu?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: navy,
                        ),
                      ),
                    ),
                    Text(
                      '${_factIndex + 1}/$total',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: inkSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    fact,
                    key: ValueKey(_factIndex),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: navy.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _buildMiniTag('BMKG', mintDeep),
                    const SizedBox(width: 5),
                    _buildMiniTag('Mitigasi', skyDeep),
                    const Spacer(),
                    const Icon(Icons.autorenew_rounded,
                        size: 12, color: inkSoft),
                    const SizedBox(width: 3),
                    const Flexible(
                      child: Text(
                        'Ganti fakta',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: sunny, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F31355A),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const CustomPaint(
              painter: TurtlePainter(expression: TurtleExpression.happy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const CustomPaint(
                  painter: TurtlePainter(expression: TurtleExpression.proud),
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'SIGEMPA Malut',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: navy,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Belajar siaga gempa, selamatkan diri & sesama 💙',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: inkSoft.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureQuestCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6E0), Color(0xFFFFEFC9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFBE6A6), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2EF2A70B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          // Cloud Sun emoji decoration
          const Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.8,
              child: Text('🌤️', style: TextStyle(fontSize: 24)),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗺️ Petualangan Hari Ini',
                style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A4A00)),
              ),
              const SizedBox(height: 2),
              Text(
                UserProgressManager().isDailyBadgeClaimed
                    ? '🎉 Semua petualangan hari ini selesai! Lencana Juara Mitigasi didapat!'
                    : UserProgressManager().isGamePlayed
                        ? '🔥 Misi game selesai! Klaim Lencana Juara Mitigasimu!'
                        : UserProgressManager().isQuizCompleted
                            ? '🎮 Kuis selesai! Sekarang saatnya bermain game!'
                            : UserProgressManager().isVideoWatched
                                ? '🧠 Video ditonton! Sekarang selesaikan kuis!'
                                : UserProgressManager().isStoryRead
                                    ? '🎬 Modul dibaca! Tonton video edukasi berikutnya!'
                                    : '📚 Baca modul edukasi untuk memulai petualangan!',
                style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF9A6B0E),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              // Stepper Path Row
              Stack(
                alignment: Alignment.center,
                children: [
                  // Connector Dashed Line
                  Positioned(
                    top: 24,
                    left: 28,
                    right: 28,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0D488),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Steps (5 langkah — 4 Pilar + Klaim)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Langkah 1: Baca Modul
                      UserProgressManager().isStoryRead
                          ? _buildCustomStepDot(
                              customIcon: const _BacaCeritaIcon(),
                              label: 'Baca\nModul',
                              status: _StepStatus.done,
                            )
                          : _buildPulsingCurrentStepCustom(
                              customIcon: const _BacaCeritaIcon(),
                              label: 'Baca\nModul',
                            ),

                      // Langkah 2: Nonton Video
                      UserProgressManager().isVideoWatched
                          ? _buildStepDot(
                              emoji: '🎬',
                              label: 'Nonton\nVideo',
                              status: _StepStatus.done,
                            )
                          : UserProgressManager().isStoryRead
                              ? _buildPulsingCurrentStep(
                                  emoji: '🎬',
                                  label: 'Nonton\nVideo',
                                )
                              : _buildStepDot(
                                  emoji: '🔒',
                                  label: 'Nonton\nVideo',
                                  status: _StepStatus.locked,
                                ),

                      // Langkah 3: Kuis
                      UserProgressManager().isQuizCompleted
                          ? _buildCustomStepDot(
                              customIcon: const _KuisPagiIcon(),
                              label: 'Kuis',
                              status: _StepStatus.done,
                            )
                          : UserProgressManager().isVideoWatched
                              ? _buildPulsingCurrentStepCustom(
                                  customIcon: const _KuisPagiIcon(),
                                  label: 'Kuis',
                                )
                              : _buildCustomStepDot(
                                  customIcon: const _KuisPagiIcon(),
                                  label: 'Kuis',
                                  status: _StepStatus.locked,
                                ),

                      // Langkah 4: Main Game
                      UserProgressManager().isGamePlayed
                          ? _buildStepDot(
                              emoji: '🎮',
                              label: 'Main\nGame',
                              status: _StepStatus.done,
                            )
                          : UserProgressManager().isQuizCompleted
                              ? _buildPulsingCurrentStep(
                                  emoji: '🎮',
                                  label: 'Main\nGame',
                                )
                              : _buildStepDot(
                                  emoji: '🔒',
                                  label: 'Main\nGame',
                                  status: _StepStatus.locked,
                                ),

                      // Langkah 5: Klaim Lencana (Kura bangga saat selesai)
                      UserProgressManager().isDailyBadgeClaimed
                          ? _buildCustomStepDot(
                              customIcon: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CustomPaint(
                                  painter: TurtlePainter(
                                      expression: TurtleExpression.proud),
                                ),
                              ),
                              label: 'Lencana\nDidapat',
                              status: _StepStatus.done,
                            )
                          : UserProgressManager().isGamePlayed
                              ? _buildPulsingCurrentStep(
                                  emoji: '🎖️',
                                  label: 'Klaim\nLencana',
                                )
                              : _buildStepDot(
                                  emoji: '🔒',
                                  label: 'Klaim\nLencana',
                                  status: _StepStatus.locked,
                                ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3D CTA Button (Dinamis sesuai progres)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final pm = UserProgressManager();
                  if (pm.isDailyBadgeClaimed) {
                    // Sudah selesai semua — tidak perlu aksi
                    return;
                  } else if (pm.isGamePlayed) {
                    // Langkah 4: Klaim lencana!
                    pm.claimDailyBadge();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CustomPaint(
                                painter: TurtlePainter(
                                    expression: TurtleExpression.proud),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lencana Baru Terbuka!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [sunny, Color(0xFFFF9770)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text('🏆',
                                  style: TextStyle(fontSize: 44)),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Juara Tanggap Bencana',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Selamat! Kamu telah menuntaskan rangkaian misi siaga gempa bumi hari ini dan mendapatkan +100 XP!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: inkSoft,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showAllBadgesDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mintDeep,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Lihat Koleksi Lencana',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  } else if (pm.isQuizCompleted) {
                    // Langkah 4: Main Game
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameHubScreen()),
                    );
                  } else if (pm.isVideoWatched) {
                    // Langkah 3: Kuis
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QuizScreen()),
                    );
                  } else if (pm.isStoryRead) {
                    // Langkah 2: Nonton Video
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VideoListScreen()),
                    );
                  } else {
                    // Langkah 1: Baca Modul
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EducationListScreen()),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: UserProgressManager().isDailyBadgeClaimed
                          ? [mint, mintDeep]
                          : UserProgressManager().isGamePlayed
                              ? [coral, coralDeep]
                              : UserProgressManager().isQuizCompleted
                                  ? [
                                      const Color(0xFF5B7FE0),
                                      const Color(0xFF3A5CC7)
                                    ]
                                  : UserProgressManager().isVideoWatched
                                      ? [
                                          const Color(0xFF9B59B6),
                                          const Color(0xFF7D3C98)
                                        ]
                                      : UserProgressManager().isStoryRead
                                          ? [
                                              const Color(0xFFFF6B35),
                                              const Color(0xFFE64A19)
                                            ]
                                          : [
                                              const Color(0xFFFFCB4A),
                                              sunnyDeep
                                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: UserProgressManager().isDailyBadgeClaimed
                            ? const Color(0xFF227E54)
                            : UserProgressManager().isGamePlayed
                                ? const Color(0xFF9E2C1A)
                                : UserProgressManager().isQuizCompleted
                                    ? const Color(0xFF2A4BB5)
                                    : UserProgressManager().isVideoWatched
                                        ? const Color(0xFF5B2D7E)
                                        : UserProgressManager().isStoryRead
                                            ? const Color(0xFFBF360C)
                                            : const Color(0xFFC6800F),
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      UserProgressManager().isDailyBadgeClaimed
                          ? '✅  Semua Misi Hari Ini Selesai'
                          : UserProgressManager().isGamePlayed
                              ? '🎁  Klaim Lencana Juara Mitigasi!'
                              : UserProgressManager().isQuizCompleted
                                  ? '🎮  Mulai Main Game!'
                                  : UserProgressManager().isVideoWatched
                                      ? '📝  Kerjakan Kuis Sekarang!'
                                      : UserProgressManager().isStoryRead
                                          ? '🎬  Tonton Video Edukasi!'
                                          : '📚  Baca Modul Edukasi',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(
      {required String emoji,
      required String label,
      required _StepStatus status}) {
    Color bgGradientStart;
    Color bgGradientEnd;

    if (status == _StepStatus.done) {
      bgGradientStart = const Color(0xFF8CE6B2);
      bgGradientEnd = mintDeep;
    } else {
      bgGradientStart = const Color(0xFFEFEAD9);
      bgGradientEnd = const Color(0xFFE5DECB);
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [bgGradientStart, bgGradientEnd]),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9A6B0E)),
        ),
      ],
    );
  }

  // Step dot dengan ikon kustom (CustomPaint/Widget) untuk logo unik per langkah
  Widget _buildCustomStepDot({
    required Widget customIcon,
    required String label,
    required _StepStatus status,
  }) {
    Color bgGradientStart;
    Color bgGradientEnd;

    if (status == _StepStatus.done) {
      bgGradientStart = const Color(0xFF8CE6B2);
      bgGradientEnd = mintDeep;
    } else {
      bgGradientStart = const Color(0xFFEFEAD9);
      bgGradientEnd = const Color(0xFFE5DECB);
    }

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [bgGradientStart, bgGradientEnd]),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: customIcon,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9A6B0E)),
        ),
      ],
    );
  }

  Widget _buildPulsingCurrentStep(
      {required String emoji, required String label}) {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  const LinearGradient(colors: [Color(0xFFFFD98A), sunnyDeep]),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x66F2A70B),
                    blurRadius: 10,
                    offset: Offset(0, 3)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9A6B0E)),
        ),
      ],
    );
  }

  // Versi pulsing untuk custom icon widget (dipakai saat step sedang aktif/current)
  Widget _buildPulsingCurrentStepCustom(
      {required Widget customIcon, required String label}) {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  const LinearGradient(colors: [Color(0xFFFFD98A), sunnyDeep]),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x66F2A70B),
                    blurRadius: 10,
                    offset: Offset(0, 3)),
              ],
            ),
            alignment: Alignment.center,
            child: customIcon,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9A6B0E)),
        ),
      ],
    );
  }

  Widget _buildActivityGrid() {
    return Column(
      children: [
        // 1. Simulasi Evakuasi (Featured Card Utama)
        _buildFeaturedActivityCard(
          icon: '🏫',
          iconBg: const Color(0xFFFFE9E9),
          title: 'Simulasi Gempa 7.2 SR',
          desc:
              'Latihan evakuasi mandiri keluar gedung menuju lapangan terbuka.',
          badgeText: 'UTAMA',
          badgeColor: coralDeep,
          badgeBg: const Color(0xFFFFE9E9),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EarthquakeSimulationGameScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        // 2 & 3: Drop & Cover + Modul Malut (Side by side)
        Row(
          children: [
            Expanded(
              child: _buildActivityCard(
                icon: '🛡️',
                iconBg: const Color(0xFFFFF3D0),
                title: 'Drop & Cover',
                desc: 'Refleks cepat gaya kura-kura.',
                badgeText: 'REFLEKS',
                badgeColor: const Color(0xFF8A6300),
                badgeBg: const Color(0xFFFFF3D0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DropCoverGameScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActivityCard(
                icon: '📚',
                iconBg: const Color(0xFFEFE7FF),
                title: 'Modul Malut',
                desc: 'Pahami lempeng & tsunami.',
                badgeText: 'EDUKASI',
                badgeColor: grape,
                badgeBg: const Color(0xFFEFE7FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EducationListScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturedActivityCard({
    required String icon,
    required Color iconBg,
    required String title,
    required String desc,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: lineBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: shadow3D,
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: navy,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: inkSoft,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String icon,
    required Color iconBg,
    required String title,
    required String desc,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: lineBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: shadow3D,
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.bold, color: navy),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10.5, color: inkSoft, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoQuickCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lineBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: shadow3D,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VideoListScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE50914), Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE50914).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.play_circle_filled,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tonton Video Edukasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text('🎬', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Simak animasi sains gempa bumi & panduan Drop-Cover-Hold On',
                        style: TextStyle(
                          fontSize: 11,
                          color: inkSoft,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '4 Video',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE50914),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR — hanya Beranda, Darurat, dan Lencana.
  // Menu Main & Belajar sengaja dihapus agar lencana hanya bisa
  // didapat lewat alur belajar bertahap, bukan lewat jalan pintas.
  // ============================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: lineBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F31355A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Beranda'),
          _buildNavItem(4, Icons.warning_rounded, 'Darurat',
              accentColor: coralDeep),
          _buildNavItem(3, Icons.military_tech_rounded, 'Lencana'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      {Color? accentColor}) {
    final bool isActive = _currentNavIndex == index;
    final Color activeColor = accentColor ?? skyDeep;
    final Color idleColor = (accentColor ?? inkSoft)
        .withValues(alpha: accentColor != null ? 0.85 : 0.8);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 34,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          activeColor.withValues(alpha: 0.18),
                          activeColor.withValues(alpha: 0.07),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? Border.all(
                        color: activeColor.withValues(alpha: 0.22),
                        width: 1.2,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: isActive ? 1.10 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 21,
                  color: isActive ? activeColor : idleColor,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive ? activeColor : idleColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 12 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Section Titles
  Widget _buildSectionTitleWithAction(
      String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: navy),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: skyDeep),
          ),
        ),
      ],
    );
  }
}

enum _StepStatus { done, current, locked }

// Catatan: Maskot Kura-kura (TurtlePainter) diimpor dari lib/widgets/turtle_painter.dart

class _KuisPagiIcon extends StatelessWidget {
  const _KuisPagiIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _KuisPagiPainter()),
    );
  }
}

class _KuisPagiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ---- Matahari di pojok kanan atas ----
    final sunPaint = Paint()
      ..color = const Color(0xFFFFF176)
      ..style = PaintingStyle.fill;
    final sunStrokePaint = Paint()
      ..color = const Color(0xFFF2A70B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Lingkaran matahari kecil
    canvas.drawCircle(Offset(cx + 7, cy - 8), 5, sunPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 8), 5, sunStrokePaint);

    // Sinar matahari
    final rayPaint = Paint()
      ..color = const Color(0xFFF2A70B)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * 3.14159 / 180;
      final x1 = (cx + 7) + 6.5 * _cos(angle);
      final y1 = (cy - 8) + 6.5 * _sin(angle);
      final x2 = (cx + 7) + 8.5 * _cos(angle);
      final y2 = (cy - 8) + 8.5 * _sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
    }

    // ---- Kertas soal (persegi panjang putih dengan garis) ----
    final paperRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 11, cy - 5, 14, 13),
      const Radius.circular(2),
    );
    canvas.drawRRect(paperRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      paperRect,
      Paint()
        ..color = const Color(0xFFB0C4DE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Garis-garis soal
    final linePaint = Paint()
      ..color = const Color(0xFFB0C4DE)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 8, cy - 1), Offset(cx + 0, cy - 1), linePaint);
    canvas.drawLine(Offset(cx - 8, cy + 2), Offset(cx + 1, cy + 2), linePaint);
    canvas.drawLine(Offset(cx - 8, cy + 5), Offset(cx - 2, cy + 5), linePaint);

    // ---- Tanda tanya merah (highlight) ----
    final qPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    // Busur atas tanda tanya
    final qPath = Path();
    qPath.moveTo(cx + 1.5, cy - 1.5);
    qPath.quadraticBezierTo(cx + 3.5, cy - 4, cx + 2, cy - 0.5);
    qPath.lineTo(cx + 2, cy + 1);
    canvas.drawPath(qPath, qPaint);
    // Titik bawah tanda tanya
    canvas.drawCircle(
      Offset(cx + 2, cy + 3),
      0.9,
      Paint()..color = const Color(0xFFFF6B6B),
    );
  }

  double _cos(double rad) => math.cos(rad);
  double _sin(double rad) => math.sin(rad);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// IKON KUSTOM: BACA CERITA (Buku Terbuka + Bintang)
// ============================================================
class _BacaCeritaIcon extends StatelessWidget {
  const _BacaCeritaIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(painter: _BacaCeritaPainter()),
    );
  }
}

class _BacaCeritaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final leftPage = Path()
      ..moveTo(cx - 1, cy - 6)
      ..lineTo(cx - 12, cy - 5)
      ..lineTo(cx - 12, cy + 6)
      ..lineTo(cx - 1, cy + 7)
      ..close();
    canvas.drawPath(leftPage, Paint()..color = const Color(0xFFE3F2FD));
    canvas.drawPath(
      leftPage,
      Paint()
        ..color = const Color(0xFF6FC6EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Halaman kanan
    final rightPage = Path()
      ..moveTo(cx + 1, cy - 6)
      ..lineTo(cx + 12, cy - 5)
      ..lineTo(cx + 12, cy + 6)
      ..lineTo(cx + 1, cy + 7)
      ..close();
    canvas.drawPath(rightPage, Paint()..color = const Color(0xFFE8F5E9));
    canvas.drawPath(
      rightPage,
      Paint()
        ..color = const Color(0xFF3DBE85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Lekukan tengah buku (punggung)
    final spinePaint = Paint()
      ..color = const Color(0xFF4A90D9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 8), spinePaint);

    // Garis teks halaman kiri
    final textPaint = Paint()
      ..color = const Color(0xFFB0C4DE)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 9, cy - 2), Offset(cx - 3, cy - 2), textPaint);
    canvas.drawLine(Offset(cx - 9, cy + 1), Offset(cx - 3, cy + 1), textPaint);
    canvas.drawLine(Offset(cx - 9, cy + 4), Offset(cx - 5, cy + 4), textPaint);

    // Garis teks halaman kanan
    canvas.drawLine(Offset(cx + 3, cy - 2), Offset(cx + 9, cy - 2), textPaint);
    canvas.drawLine(Offset(cx + 3, cy + 1), Offset(cx + 9, cy + 1), textPaint);
    canvas.drawLine(Offset(cx + 3, cy + 4), Offset(cx + 7, cy + 4), textPaint);

    // ---- Bintang kuning kecil di atas kanan ----
    _drawStar(canvas, Offset(cx + 9, cy - 8), 4.5, const Color(0xFFFFC107));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    const int points = 5;
    final innerRadius = radius * 0.42;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final x = center.dx + r * _cos(angle);
      final y = center.dy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF2A70B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  double _cos(double r) => math.cos(r);
  double _sin(double r) => math.sin(r);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================================================================
// DEKORASI LATAR HOME
// ================================================================
class _HomeBackdropPainter extends CustomPainter {
  const _HomeBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Awan tipis di kanan atas.
    final Paint cloud = Paint()..color = AppPalette.sky.withValues(alpha: 0.10);
    canvas.drawCircle(Offset(w - 34, 54), 34, cloud);
    canvas.drawCircle(Offset(w - 66, 62), 24, cloud);
    canvas.drawCircle(Offset(w - 10, 66), 27, cloud);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w - 38, 76), width: 110, height: 30),
      cloud,
    );

    // Bulatan mint lembut di kiri tengah.
    canvas.drawCircle(
      Offset(-40, h * 0.52),
      120,
      Paint()..color = AppPalette.mint.withValues(alpha: 0.06),
    );

    // Titik-titik halus di sisi kanan.
    final Paint dot = Paint()
      ..color = AppPalette.lineBorder.withValues(alpha: 0.9);
    for (double y = 150; y < h - 40; y += 30) {
      for (double x = w - 26; x > w - 70; x -= 22) {
        canvas.drawCircle(Offset(x, y), 1.4, dot);
      }
    }

    // Gelombang tipis di bagian bawah.
    final Paint wave = Paint()
      ..color = AppPalette.sky.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final Path path = Path()
      ..moveTo(0, h - 90)
      ..quadraticBezierTo(w * 0.28, h - 110, w * 0.55, h - 88)
      ..quadraticBezierTo(w * 0.82, h - 66, w, h - 92);
    canvas.drawPath(path, wave);
  }

  @override
  bool shouldRepaint(covariant _HomeBackdropPainter oldDelegate) => false;
}

// ================================================================
// DEKORASI HEADER HOME
// ================================================================
class _HeaderBackdropPainter extends CustomPainter {
  final double t;

  const _HeaderBackdropPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Matahari lembut di kanan atas.
    final Offset sun = Offset(w * 0.88, 20);
    canvas.drawCircle(
        sun, 46, Paint()..color = Colors.white.withValues(alpha: 0.08));
    canvas.drawCircle(
        sun, 30, Paint()..color = AppPalette.sunny.withValues(alpha: 0.20));
    canvas.drawCircle(
        sun, 16, Paint()..color = AppPalette.sunny.withValues(alpha: 0.55));

    // Awan mengapung.
    _drawCloud(
      canvas,
      Offset(w * 0.14 + math.sin(t * math.pi * 2) * 7, 30),
      16,
      Colors.white.withValues(alpha: 0.15),
    );
    _drawCloud(
      canvas,
      Offset(w * 0.63 - math.cos(t * math.pi * 2) * 8, 18),
      12,
      Colors.white.withValues(alpha: 0.12),
    );

    // Bintang kecil berkelip.
    for (int i = 0; i < 5; i++) {
      final double phase = i * 1.3;
      final double alpha =
          0.18 + 0.20 * (0.5 + 0.5 * math.sin(t * math.pi * 2 + phase));
      final Offset p = Offset(
        w * (0.18 + i * 0.16),
        28 + (i.isEven ? 44 : 18),
      );
      _drawSparkle(
        canvas,
        p,
        2.4,
        Colors.white.withValues(alpha: alpha),
      );
    }

    // Gelombang putih di dasar header.
    final Path wave = Path()
      ..moveTo(0, h - 26)
      ..quadraticBezierTo(w * 0.18, h - 44, w * 0.38, h - 26)
      ..quadraticBezierTo(w * 0.58, h - 8, w * 0.78, h - 30)
      ..quadraticBezierTo(w * 0.92, h - 44, w, h - 24)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave,
      Paint()..color = Colors.white.withValues(alpha: 0.07),
    );

    // Lengkung dekoratif tipis.
    final Paint arc = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(-10, h + 20), radius: 90),
      math.pi * 1.15,
      math.pi * 0.55,
      false,
      arc,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w + 20, h - 10), radius: 70),
      math.pi * 0.9,
      math.pi * 0.6,
      false,
      arc,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double size, Color color) {
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(center, size * 0.72, paint);
    canvas.drawCircle(
      Offset(center.dx - size * 0.68, center.dy + size * 0.14),
      size * 0.5,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.68, center.dy + size * 0.14),
      size * 0.56,
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.26),
        width: size * 2.1,
        height: size * 0.7,
      ),
      paint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Color color) {
    final Path path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(
          center.dx + r * 0.22, center.dy - r * 0.22, center.dx + r, center.dy)
      ..quadraticBezierTo(
          center.dx + r * 0.22, center.dy + r * 0.22, center.dx, center.dy + r)
      ..quadraticBezierTo(
          center.dx - r * 0.22, center.dy + r * 0.22, center.dx - r, center.dy)
      ..quadraticBezierTo(
          center.dx - r * 0.22, center.dy - r * 0.22, center.dx, center.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HeaderBackdropPainter old) => old.t != t;
}

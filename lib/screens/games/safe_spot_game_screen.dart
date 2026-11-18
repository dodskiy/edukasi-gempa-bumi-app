import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/user_progress_manager.dart';

class SafeSpotGameScreen extends StatefulWidget {
  const SafeSpotGameScreen({super.key});

  @override
  State<SafeSpotGameScreen> createState() => _SafeSpotGameScreenState();
}

class RoomObject {
  final String id;
  final String name;
  final IconData icon;
  final bool isSafe;
  final String explanation;
  final String advice;

  RoomObject({
    required this.id,
    required this.name,
    required this.icon,
    required this.isSafe,
    required this.explanation,
    required this.advice,
  });
}

class ScenarioData {
  final int stageNumber;
  final String title;
  final String subtitle;
  final IconData roomIcon;
  final Color themeColor;
  final Color themeDark;
  final List<RoomObject> objects;

  ScenarioData({
    required this.stageNumber,
    required this.title,
    required this.subtitle,
    required this.roomIcon,
    required this.themeColor,
    required this.themeDark,
    required this.objects,
  });

  int get totalSafe => objects.where((o) => o.isSafe).length;
}

class _SafeSpotGameScreenState extends State<SafeSpotGameScreen>
    with SingleTickerProviderStateMixin {
  // Palet warna Siaga Gempa Bumi
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color deepNavy = Color(0xFF1E293B);
  static const Color sunnyGold = Color(0xFFFFB020);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color creamBg = Color(0xFFF8FAFC);
  static const int _scenarioDuration = 30;
  static const int _pointsPerSafeZone = 100;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _currentScenarioIndex = 0;
  int _score = 0;
  int _secondsLeft = _scenarioDuration;
  Timer? _timer;
  bool _isQuaking = true;
  bool _gameEnded = false;
  bool _isTransitioning = false;

  final Set<String> _inspectedIds = {};

  String _siagaMessage =
      'Bumi berguncang! Ketuk benda di sekitarmu dan temukan semua ZONA AMAN untuk lanjut.';
  late List<ScenarioData> _scenarios;

  @override
  void initState() {
    super.initState();
    _initScenarios();
    _initAnimation();
    _startTimer();
  }

  void _initAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  /// Memulai timer skenario. Tidak memanggil setState sendiri,
  /// sehingga aman dipanggil dari initState maupun dari dalam setState.
  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _scenarioDuration;
    _isQuaking = true;
    _isTransitioning = false;

    _shakeController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        // Guncangan mereda. Skenario TIDAK dilewati otomatis,
        // pemain tetap harus menemukan semua zona aman.
        timer.cancel();
        _shakeController.stop();
        setState(() {
          _secondsLeft = 0;
          _isQuaking = false;
        });
      }
    });
  }

  void _initScenarios() {
    _scenarios = [
      // Skenario 1: Ruang kelas SD
      ScenarioData(
        stageNumber: 1,
        title: 'Di Dalam Ruang Kelas',
        subtitle: 'Saat jam pelajaran berlangsung, alarm gempa berbunyi!',
        roomIcon: Icons.school_rounded,
        themeColor: const Color(0xFF38BDF8),
        themeDark: const Color(0xFF0284C7),
        objects: [
          RoomObject(
            id: 's1_desk',
            name: 'Kolong Meja Belajar',
            icon: Icons.desk_rounded,
            isSafe: true,
            explanation:
                'ZONA AMAN UTAMA! Merunduklah ke bawah meja (DROP), lindungi kepala (COVER), dan pegang kaki meja erat-erat (HOLD ON)!',
            advice:
                'Meja kayu yang kuat melindungi tubuhmu dari reruntuhan plafon genteng.',
          ),
          RoomObject(
            id: 's1_bag',
            name: 'Tas Sekolah di Meja',
            icon: Icons.backpack_rounded,
            isSafe: true,
            explanation:
                'PELINDUNG KEPALA! Jika tidak sempat masuk kolong meja, pegang tas di atas kepala!',
            advice:
                'Buku-buku tebal di dalam tas menjadi bantalan pelindung kepalamu.',
          ),
          RoomObject(
            id: 's1_window',
            name: 'Kaca Jendela Besar',
            icon: Icons.window_rounded,
            isSafe: false,
            explanation:
                'AWAS SANGAT BERBAHAYA! Guncangan gempa bisa memecahkan kaca jendela seketika!',
            advice:
                'Jauhi kaca minimal 2 meter agar tidak terkena serpihan kaca tajam.',
          ),
          RoomObject(
            id: 's1_bookshelf',
            name: 'Lemari Buku Tinggi',
            icon: Icons.library_books_rounded,
            isSafe: false,
            explanation:
                'BAHAYA TERTINDIH! Lemari yang tinggi bisa tumbang ke depan saat bumi bergoyang.',
            advice:
                'Jangan berdiri di depan atau samping lemari buku yang berat.',
          ),
          RoomObject(
            id: 's1_lamp',
            name: 'Lampu Gantung Langit-langit',
            icon: Icons.lightbulb_rounded,
            isSafe: false,
            explanation:
                'BAHAYA KEJATUHAN! Lampu gantung dan kipas angin bisa patah atau copot dari plafon.',
            advice:
                'Segera merunduk menjauhi posisi tepat di bawah lampu gantung.',
          ),
          RoomObject(
            id: 's1_corner',
            name: 'Sudut Dinding Dekat Kolom',
            icon: Icons.account_balance_rounded,
            isSafe: true,
            explanation:
                'ZONA AMAN ALTERNATIF! Kolom beton di sudut ruangan biasanya paling kokoh menahan beban.',
            advice:
                'Merunduk rapat ke sudut pilar sambil melindungi leher dan kepala.',
          ),
        ],
      ),

      // Skenario 2: Kantin sekolah
      ScenarioData(
        stageNumber: 2,
        title: 'Di Kantin Sekolah',
        subtitle: 'Saat istirahat makan siang, tanah bergetar hebat!',
        roomIcon: Icons.restaurant_menu_rounded,
        themeColor: const Color(0xFFFBBF24),
        themeDark: const Color(0xFFD97706),
        objects: [
          RoomObject(
            id: 's2_stove',
            name: 'Kompor Gas Kantin',
            icon: Icons.local_fire_department_rounded,
            isSafe: false,
            explanation:
                'SUMBER KEBAKARAN! Api kompor yang menyala bisa memicu kebakaran besar saat gempa!',
            advice:
                'Jika berada sangat dekat, matikan kompor segera, lalu jauhi area dapur memasak.',
          ),
          RoomObject(
            id: 's2_table',
            name: 'Meja Makan Kayu Tebal',
            icon: Icons.table_restaurant_rounded,
            isSafe: true,
            explanation:
                'ZONA AMAN! Masuk ke kolong meja makan kantin yang kokoh dan tahan guncangan.',
            advice:
                'Pegang erat kaki meja agar meja tidak bergeser dari atasmu.',
          ),
          RoomObject(
            id: 's2_dishes',
            name: 'Rak Piring & Gelas Kaca',
            icon: Icons.restaurant_rounded,
            isSafe: false,
            explanation:
                'BAHAYA BENDA PECAH! Piring dan mangkuk sup panas bisa berhamburan ke lantai.',
            advice:
                'Jauhi rak piring dan jangan berjalan tanpa alas kaki pelindung.',
          ),
          RoomObject(
            id: 's2_tray',
            name: 'Baki Makan / Nampan Tebal',
            icon: Icons.shield_rounded,
            isSafe: true,
            explanation:
                'PELINDUNG DARURAT! Gunakan baki makanan plastik keras untuk menutupi kepala dari atas.',
            advice:
                'Benda pipih dan kuat bisa menggantikan helm darurat saat evakuasi.',
          ),
          RoomObject(
            id: 's2_gas',
            name: 'Tabung Gas Elpiji',
            icon: Icons.local_gas_station_rounded,
            isSafe: false,
            explanation:
                'SANGAT BERBAHAYA! Tabung gas bisa terguling dan selangnya robek hingga bocor gas beracun.',
            advice:
                'Hindari tabung gas dan jangan pernah menyalakan korek api atau listrik di sekitarnya.',
          ),
          RoomObject(
            id: 's2_exit_door',
            name: 'Pintu Darurat Terbuka',
            icon: Icons.door_front_door_rounded,
            isSafe: true,
            explanation:
                'JALUR EVAKUASI! Pintu yang terbuka mengarah langsung ke area terbuka luar ruangan.',
            advice:
                'Setelah gempa reda, segera keluar melalui pintu keluar dengan tenang tanpa panik.',
          ),
        ],
      ),

      // Skenario 3: Koridor dan jalur evakuasi
      ScenarioData(
        stageNumber: 3,
        title: 'Koridor Menuju Lapangan',
        subtitle: 'Gempa mulai reda, saatnya evakuasi keluar gedung!',
        roomIcon: Icons.directions_run_rounded,
        themeColor: const Color(0xFF34D399),
        themeDark: const Color(0xFF059669),
        objects: [
          RoomObject(
            id: 's3_elevator',
            name: 'Lift Sekolah / Gedung',
            icon: Icons.elevator_rounded,
            isSafe: false,
            explanation:
                'JANGAN PERNAH NAIK LIFT! Listrik sewaktu-waktu bisa mati dan kabel lift bisa macet fatal!',
            advice:
                'Selalu gunakan tangga biasa saat evakuasi bencana gempa bumi.',
          ),
          RoomObject(
            id: 's3_stairs',
            name: 'Tangga Evakuasi Darurat',
            icon: Icons.stairs_rounded,
            isSafe: true,
            explanation:
                'JALUR AMAN! Turuni tangga dengan tenang satu per satu, pegang pegangan tangga railing!',
            advice:
                'Ingat aturan emas: Jangan lari, jangan dorong, jangan panik, jangan berbalik arah.',
          ),
          RoomObject(
            id: 's3_pole',
            name: 'Tiang Listrik & Kabel Putus',
            icon: Icons.bolt_rounded,
            isSafe: false,
            explanation:
                'BAHAYA SENGATAN LISTRIK! Tiang beton bisa retak roboh dan kabel bertegangan tinggi menjuntai.',
            advice: 'Jauhi tiang listrik dan genangan air di halaman sekolah.',
          ),
          RoomObject(
            id: 's3_field',
            name: 'Lapangan Terbuka (Titik Kumpul)',
            icon: Icons.flag_rounded,
            isSafe: true,
            explanation:
                'TITIK KUMPUL TERAMAN! Lapangan terbuka bebas dari bahaya reruntuhan bangunan tinggi.',
            advice:
                'Berkumpullah di sini bersama guru dan teman-teman sampai diumumkan kondisi aman.',
          ),
          RoomObject(
            id: 's3_wall',
            name: 'Pagar Tembok Tua / Kaca Koridor',
            icon: Icons.fence_rounded,
            isSafe: false,
            explanation:
                'BAHAYA ROBOH! Pagar pembatas tembok yang tua sangat mudah runtuh oleh getaran gempa.',
            advice:
                'Berjalanlah di bagian tengah koridor atau halaman yang lapang.',
          ),
          RoomObject(
            id: 's3_hands_head',
            name: 'Tangan Melindungi Kepala & Tengkuk',
            icon: Icons.accessibility_new_rounded,
            isSafe: true,
            explanation:
                'POSISI AMAN! Kedua tangan saling mengunci di belakang kepala untuk melindungi kepala dan leher.',
            advice: 'Selalu lakukan ini saat berjalan melewati lorong beratap.',
          ),
        ],
      ),
    ];
  }

  int _foundSafeCount(ScenarioData scenario) {
    return scenario.objects
        .where((o) => o.isSafe && _inspectedIds.contains(o.id))
        .length;
  }

  void _onObjectTap(RoomObject obj) {
    if (_isTransitioning) return;
    HapticFeedback.mediumImpact();

    final isFirstInspection = !_inspectedIds.contains(obj.id);
    if (isFirstInspection) {
      _inspectedIds.add(obj.id);
      setState(() {
        if (obj.isSafe) {
          _score += _pointsPerSafeZone;
          _siagaMessage =
              'Benar! "${obj.name}" adalah ZONA AMAN (+$_pointsPerSafeZone poin).';
        } else {
          _siagaMessage =
              'Hati-hati! "${obj.name}" adalah AREA BAHAYA. Cari zona aman yang lain.';
        }
      });
    }

    _showObjectDetailDialog(obj);
  }

  void _showObjectDetailDialog(RoomObject obj) {
    final Color statusColor = obj.isSafe ? emeraldGreen : dangerRed;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(obj.icon, size: 38, color: statusColor),
                ),
                const SizedBox(height: 14),
                Text(
                  obj.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: deepNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        obj.isSafe
                            ? Icons.check_circle_rounded
                            : Icons.warning_amber_rounded,
                        color: statusColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        obj.isSafe
                            ? 'ZONA AMAN BERLINDUNG'
                            : 'ZONA RAWAN BAHAYA',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  obj.explanation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: deepNavy,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: creamBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.withOpacity(0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 18, color: sunnyGold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          obj.advice,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deepNavy.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: obj.isSafe ? emeraldGreen : primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _checkScenarioCompletion();
                    },
                    child: const Text(
                      'Paham, Lanjutkan',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkScenarioCompletion() {
    if (!mounted || _isTransitioning || _gameEnded) return;

    final scenario = _scenarios[_currentScenarioIndex];
    if (_foundSafeCount(scenario) < scenario.totalSafe) return;

    _isTransitioning = true;
    _timer?.cancel();
    _shakeController.stop();

    final isLastScenario = _currentScenarioIndex >= _scenarios.length - 1;

    if (isLastScenario) {
      setState(() {
        _isQuaking = false;
      });
      _endGame();
      return;
    }

    setState(() {
      _isQuaking = false;
      _siagaMessage =
          'Semua zona aman di ${scenario.title} sudah ditemukan. Pindah ke lokasi berikutnya...';
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _currentScenarioIndex++;
        _siagaMessage =
            'Guncangan baru dimulai! Temukan semua zona aman di lokasi ini.';
        _startTimer();
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    _shakeController.stop();
    setState(() {
      _gameEnded = true;
    });
    final progress = UserProgressManager();
    progress.completeGameStep(badgeId: 'detektif_zona_aman', bonusXp: 60);

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 56, color: sunnyGold),
                const SizedBox(height: 10),
                const Text(
                  'MISI SELESAI',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: deepNavy,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kamu berhasil menemukan semua zona aman saat gempa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: sunnyGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: sunnyGold, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Total Skor: $_score Poin',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: creamBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded,
                              size: 18, color: primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Tips Siaga Gempa Bumi:',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: deepNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. Saat gempa: DROP (Merunduk), COVER (Berlindung di bawah meja), HOLD ON (Pegang kaki meja).\n2. Jauhi jendela kaca, rak tinggi, dan jangan gunakan lift.\n3. Setelah gempa reda, berkumpullah di lapangan terbuka.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: deepNavy.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Ke Menu Hub',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            color: deepNavy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _currentScenarioIndex = 0;
                            _score = 0;
                            _inspectedIds.clear();
                            _gameEnded = false;
                            _siagaMessage =
                                'Guncangan gempa dimulai! Temukan semua zona aman.';
                            _startTimer();
                          });
                        },
                        child: const Text(
                          'Main Lagi',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScenario = _scenarios[_currentScenarioIndex];

    return Scaffold(
      backgroundColor: creamBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(currentScenario),
            _buildEarthquakeBanner(currentScenario),
            _buildProgress(currentScenario),
            Expanded(
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = _isQuaking ? _shakeAnimation.value : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: _buildObjectsGrid(currentScenario),
              ),
            ),

            // Asisten Siaga Gempa Bumi (umpan balik)
            _buildSiagaAssistant(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ScenarioData scenario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: deepNavy,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(scenario.roomIcon,
                        size: 14, color: scenario.themeDark),
                    const SizedBox(width: 4),
                    Text(
                      'Skenario ${scenario.stageNumber}/${_scenarios.length}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: scenario.themeDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  scenario.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: deepNavy,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sunnyGold.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: sunnyGold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeBanner(ScenarioData scenario) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isQuaking
              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
              : [const Color(0xFF10B981), const Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (_isQuaking ? dangerRed : emeraldGreen).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isQuaking ? Icons.vibration_rounded : Icons.shield_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isQuaking
                      ? 'GEMPA SEDANG TERJADI'
                      : 'GUNCANGAN UTAMA MEREDA',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _isQuaking
                      ? 'Temukan zona aman sebelum waktu habis!'
                      : 'Temukan semua zona aman untuk lanjut.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _isQuaking ? dangerRed : emeraldGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_secondsLeft}s',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _isQuaking ? dangerRed : emeraldGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(ScenarioData scenario) {
    final total = scenario.totalSafe;
    final found = _foundSafeCount(scenario);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 16, color: emeraldGreen),
          const SizedBox(width: 6),
          Text(
            'Zona aman ditemukan: $found/$total',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: deepNavy,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : found / total,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(emeraldGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectsGrid(ScenarioData scenario) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: scenario.objects.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final obj = scenario.objects[index];
          final isInspected = _inspectedIds.contains(obj.id);
          final Color statusColor = obj.isSafe ? emeraldGreen : dangerRed;

          return GestureDetector(
            onTap: () => _onObjectTap(obj),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isInspected
                      ? statusColor
                      : Colors.black.withOpacity(0.07),
                  width: isInspected ? 2.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isInspected
                        ? statusColor.withOpacity(0.18)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isInspected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon objek
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isInspected
                          ? statusColor.withOpacity(0.12)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      obj.icon,
                      size: 28,
                      color: isInspected
                          ? statusColor
                          : deepNavy.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    obj.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: deepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isInspected)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          obj.isSafe
                              ? Icons.verified_rounded
                              : Icons.warning_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          obj.isSafe ? 'AMAN' : 'BAHAYA',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ketuk untuk cek',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: deepNavy.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSiagaAssistant() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Siaga Gempa Bumi:',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  _siagaMessage,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: deepNavy,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../data/user_progress_manager.dart';
import '../../theme/app_palette.dart';
import '../../widgets/turtle_painter.dart';
import 'earthquake_quiz_screen.dart';

class EarthquakeSimulationGameScreen extends StatefulWidget {
  const EarthquakeSimulationGameScreen({super.key});

  @override
  State<EarthquakeSimulationGameScreen> createState() =>
      _EarthquakeSimulationGameScreenState();
}

enum Facing { up, down, left, right }

enum DialogMode { normal, quake, safe }

enum ShelterStage { none, drop, cover, holdOn }

enum QuakePhase {
  idle,
  mainQuake,
  calmAfterMain,
  aftershockWarning,
  aftershock,
  resolved
}

class Particle {
  final String type; // 'shard', 'dust'
  double x;
  double y;
  double vx;
  double vy;
  int life;
  double rot;
  double vr;
  double r;

  Particle({
    required this.type,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    this.rot = 0.0,
    this.vr = 0.0,
    this.r = 2.0,
  });
}

class LevelConfig {
  final int levelNumber;
  final String title;
  final String subtitle;
  final List<List<String>> map;
  final Point<int> startPos;
  final int mainQuakeTurns;
  final int aftershockTurns; // 0 kalau level tidak punya aftershock
  final double damageMultiplier;
  final int startHp;
  final double
      passHpRatio; // rasio HP minimum saat lulus (0.0 = tidak ada syarat selain >0)
  final bool hasAftershock;
  final int calmTurnsBeforeAftershock; // jeda "aman" sebelum aftershock dipicu
  final bool
      timedQuake; // true = gempa berjalan seiring waktu (tidak harus melangkah)

  const LevelConfig({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.map,
    required this.startPos,
    required this.mainQuakeTurns,
    required this.aftershockTurns,
    required this.damageMultiplier,
    required this.startHp,
    required this.passHpRatio,
    required this.hasAftershock,
    required this.calmTurnsBeforeAftershock,
    this.timedQuake = false,
  });
}

class _EarthquakeSimulationGameScreenState
    extends State<EarthquakeSimulationGameScreen>
    with SingleTickerProviderStateMixin {
  static const double tileSize = 27.0;

  static const List<List<String>> _mapLevel1 = [
    ['#', '#', '#', '#', '#', '#', '#', '#'],
    ['#', 'K', 'M', 'K', 'M', 'K', '#', '#'],
    ['#', '.', 'M', '.', 'M', '.', '#', '#'],
    ['#', '.', 'M', '.', 'M', '.', 'D', 'G'],
    ['#', '.', 'M', '.', 'M', '.', '#', 'G'],
    ['#', '#', '#', '#', '#', '#', '#', 'X'],
  ];

  static const List<List<String>> _mapLevel2 = [
    ['#', '#', '#', '#', '#', '#', '#', '#', '#', '#'],
    ['#', 'K', 'M', 'K', 'M', '.', '#', 'M', 'M', '#'],
    ['#', '.', 'M', '.', 'M', '.', 'D', 'M', 'M', '#'],
    ['#', '.', 'M', '.', 'M', '.', '.', '.', '.', '#'],
    ['#', '#', '.', '#', '#', '#', '#', 'D', '.', '#'],
    ['#', 'M', 'M', '#', 'M', 'M', '.', 'M', 'M', '#'],
    ['#', 'M', 'M', '#', 'M', 'K', '.', 'M', 'M', '#'],
    ['#', '#', '#', '#', 'D', '#', '#', 'D', 'G', 'X'],
  ];

  // Level 3: Kelas (atas) → pintu kelas → koridor → PINTU KELUAR (hijau)
  //          → jalur rumput → TITIK KUMPUL (bendera)
  static const List<List<String>> _mapLevel3 = [
    ['#', '#', '#', '#', '#', '#', '#', '#', '#', '#'],
    ['#', 'K', 'M', '.', 'M', '.', 'M', 'K', '#', '#'],
    ['#', '.', 'M', '.', 'M', '.', 'M', '.', '#', '#'],
    ['#', '.', '.', '.', '.', '.', '.', '.', '#', '#'],
    ['#', '#', '#', '#', 'D', '#', '#', '#', '#', '#'],
    ['#', 'M', '.', '.', '.', '.', 'K', 'M', 'D', 'G'],
    ['#', 'M', '.', '.', '.', '.', '.', 'M', '#', 'G'],
    ['#', '#', '#', '#', '#', '#', '#', '#', '#', 'X'],
  ];

  late final List<LevelConfig> _levels = [
    const LevelConfig(
      levelNumber: 1,
      title: 'LEVEL 1 — RUANG KELAS',
      subtitle: 'Pengenalan Drop, Cover & Hold On',
      map: _mapLevel1,
      startPos: Point(1, 2),
      mainQuakeTurns: 5,
      aftershockTurns: 0,
      damageMultiplier: 1.0,
      startHp: 100,
      passHpRatio: 0.0,
      hasAftershock: false,
      calmTurnsBeforeAftershock: 0,
    ),
    const LevelConfig(
      levelNumber: 2,
      title: 'LEVEL 2 — KORIDOR SEKOLAH',
      subtitle: 'Ruangan lebih luas, guncangan lebih kuat',
      map: _mapLevel2,
      startPos: Point(1, 2),
      mainQuakeTurns: 7,
      aftershockTurns: 0,
      damageMultiplier: 1.25,
      startHp: 100,
      passHpRatio: 0.30,
      hasAftershock: false,
      calmTurnsBeforeAftershock: 0,
    ),
    const LevelConfig(
      levelNumber: 3,
      title: 'LEVEL 3 — GEDUNG SEKOLAH',
      subtitle: 'Waspada gempa susulan setelah guncangan utama!',
      map: _mapLevel3,
      startPos: Point(1, 2),
      mainQuakeTurns: 6,
      aftershockTurns: 3,
      damageMultiplier: 1.4,
      startHp: 80,
      passHpRatio: 0.30,
      hasAftershock: true,
      calmTurnsBeforeAftershock: 4,
      timedQuake: true,
    ),
  ];

  int _levelIndex = 0;
  LevelConfig get _level => _levels[_levelIndex];
  int get cols => _level.map[0].length;
  int get rows => _level.map.length;

  int _totalScore = 0; // akumulasi skor lintas level
  int _levelScore = 0; // skor level berjalan

  // Player State
  late Point<int> _playerPos;
  double _px = 0;
  double _py = 0;
  Facing _facing = Facing.down;
  bool _walking = false;
  int _hp = 100;
  int _turn = 0;

  // Quake State
  QuakePhase _quakePhase = QuakePhase.idle;
  bool get _quakeActive =>
      _quakePhase == QuakePhase.mainQuake ||
      _quakePhase == QuakePhase.aftershock;
  int _quakeTurnsLeft = 0;
  int _calmTurnsLeft = 0;
  bool _quakeHappened = false;
  bool _gameOver = false;

  // Status Drop, Cover & Hold On — sekarang bertahap
  ShelterStage _shelterStage = ShelterStage.none;
  bool get _isSheltered => _shelterStage != ShelterStage.none;
  bool get _isHolding => _shelterStage == ShelterStage.holdOn;

  // Animation State
  late Ticker _ticker;
  int _animTime = 0;
  Duration _lastElapsed = Duration.zero;
  int _quakeClockMs = 0; // penghitung waktu gempa (untuk level timedQuake)
  static const int _quakeStepMs = 1100; // 1 "langkah gempa" tiap 1,1 detik
  double _screenShake = 0.0;
  int _flashT = 0;
  final List<Particle> _particles = [];
  final Random _random = Random();

  // Dialog State
  String _dialogText =
      'SISWA ADA DI RUANG KELAS. GUNAKAN D-PAD UNTUK BERGERAK.';
  DialogMode _dialogMode = DialogMode.normal;

  // Lever Visual
  bool _leverActive = false;

  // Tutorial overlay — tampil sekali di awal sebelum bisa mulai bermain
  bool _showIntroTutorial = true;

  // Hasil pre-test & post-test (null = belum dikerjakan)
  int? _preTestCorrect;
  int? _preTestTotal;

  @override
  void initState() {
    super.initState();
    _resetLevel(resetTotalScore: true);
    _ticker = createTicker((elapsed) {
      final dtMs = (elapsed - _lastElapsed).inMilliseconds;
      _lastElapsed = elapsed;
      _gameLoop(dtMs);
    })
      ..start();
    // Pre-test dulu, baru tutorial Drop, Cover & Hold On.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startPreTest();
    });
  }

  Future<void> _startPreTest() async {
    final result = await Navigator.of(context).push<EarthquakeQuizResult>(
      MaterialPageRoute(
        builder: (_) => const EarthquakeQuizScreen(
          mode: EarthquakeQuizMode.preTest,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;

    setState(() {
      _preTestCorrect = result?.correct ?? 0;
      _preTestTotal = result?.total ?? 6;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _showIntroTutorial) {
        _showTutorialModal();
      }
    });
  }

  Future<void> _runPostTest() async {
    final preCorrect = _preTestCorrect ?? 0;
    final preTotal = _preTestTotal ?? 6;

    final result = await Navigator.of(context).push<EarthquakeQuizResult>(
      MaterialPageRoute(
        builder: (_) => EarthquakeQuizScreen(
          mode: EarthquakeQuizMode.postTest,
          preTestCorrect: preCorrect,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;

    // Selesai post-test → kembali ke daftar game.
    if (result != null) {
      Navigator.of(context).pop();
    }
  }

  void _resetLevel({bool resetTotalScore = false}) {
    setState(() {
      if (resetTotalScore) {
        _totalScore = 0;
        _levelIndex = 0;
      }
      _levelScore = 0;
      _playerPos = _level.startPos;
      _px = _level.startPos.x * tileSize;
      _py = _level.startPos.y * tileSize;
      _facing = Facing.down;
      _walking = false;
      _hp = _level.startHp;
      _turn = 0;
      _quakePhase = QuakePhase.idle;
      _quakeTurnsLeft = 0;
      _calmTurnsLeft = 0;
      _quakeHappened = false;
      _gameOver = false;
      _shelterStage = ShelterStage.none;
      _screenShake = 0.0;
      _flashT = 0;
      _particles.clear();
      _leverActive = false;
      _quakeClockMs = 0;
      _setDialog(
          '${_level.title}\nTARIK TUAS ALARM DI BAWAH UNTUK MEMULAI GEMPA. LALU KELUAR LEWAT PINTU HIJAU "KELUAR" MENUJU TITIK KUMPUL.',
          DialogMode.normal);
    });
  }

  void _advanceShelterStage() {
    if (_gameOver) return;
    HapticFeedback.mediumImpact();

    final c = _playerPos.x;
    final r = _playerPos.y;
    final onMeja = _tileAt(c, r) == 'M';

    setState(() {
      switch (_shelterStage) {
        case ShelterStage.none:
          _shelterStage = ShelterStage.drop;
          _setDialog(
              '1. DROP! SEGERA MERUNDUK KE LANTAI SEKARANG!', DialogMode.quake);
          break;
        case ShelterStage.drop:
          if (onMeja) {
            _shelterStage = ShelterStage.cover;
            _levelScore += 8;
            _setDialog(
                '2. COVER! LINDUNGI KEPALA BAWAH MEJA!', DialogMode.safe);
          } else {
            _setDialog(
                '⚠ BELUM ADA MEJA! CARI MEJA (🪑) TERDEKAT DULU UNTUK COVER!',
                DialogMode.quake);
          }
          break;
        case ShelterStage.cover:
          _shelterStage = ShelterStage.holdOn;
          _levelScore += 12;
          _setDialog(
              '3. HOLD ON! PEGANG KAKI MEJA, JANGAN BERGERAK SAMPAI GEMPA BERHENTI!',
              DialogMode.safe);
          break;
        case ShelterStage.holdOn:
          if (_quakeActive) {
            // Selama gempa masih berlangsung, tetap bertahan (HOLD ON)
            _setDialog('TAHAN POSISI! JANGAN BERDIRI SEBELUM GETARAN REDA.',
                DialogMode.safe);
          } else {
            // Berdiri kembali setelah gempa reda
            _shelterStage = ShelterStage.none;
            _setDialog('BERDIRI KEMBALI. SIAP BERGERAK KE JALUR EVAKUASI.',
                DialogMode.normal);
          }
          break;
      }
    });
  }

  void _setDialog(String text, DialogMode mode) {
    setState(() {
      _dialogText = text;
      _dialogMode = mode;
    });
  }

  bool _inBounds(int c, int r) => c >= 0 && c < cols && r >= 0 && r < rows;
  String _tileAt(int c, int r) => _inBounds(c, r) ? _level.map[r][c] : '#';
  bool _walkable(int c, int r) => _inBounds(c, r) && _tileAt(c, r) != '#';

  List<Point<int>> _neighbors(int c, int r) {
    return [
      Point(c - 1, r),
      Point(c + 1, r),
      Point(c, r - 1),
      Point(c, r + 1),
    ].where((p) => _inBounds(p.x, p.y)).toList();
  }

  bool _isNearGlass(int c, int r) {
    if (_tileAt(c, r) == 'K') return true;
    return _neighbors(c, r).any((p) => _tileAt(p.x, p.y) == 'K');
  }

  /// Pintu keluar = pintu (D) yang bersebelahan dengan jalur luar (G).
  bool _isExitDoor(int c, int r) =>
      _tileAt(c, r) == 'D' &&
      _neighbors(c, r).any((p) => _tileAt(p.x, p.y) == 'G');

  void _spawnShardsFromGlass() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_tileAt(c, r) == 'K' && _random.nextDouble() < 0.6) {
          for (int i = 0; i < 2; i++) {
            _particles.add(Particle(
              type: 'shard',
              x: c * tileSize + 6 + _random.nextDouble() * (tileSize - 12),
              y: r * tileSize + 8,
              vx: (_random.nextDouble() - 0.5) * 1.2,
              vy: 0.6 + _random.nextDouble() * 0.6,
              life: 34,
              rot: _random.nextDouble() * pi,
              vr: (_random.nextDouble() - 0.5) * 0.5,
            ));
          }
        }
      }
    }
  }

  void _spawnDust(double x, double y) {
    for (int i = 0; i < 6; i++) {
      _particles.add(Particle(
        type: 'dust',
        x: x,
        y: y,
        vx: (_random.nextDouble() - 0.5) * 1.4,
        vy: -_random.nextDouble() * 0.6,
        life: 22,
        r: 2 + _random.nextDouble() * 2,
      ));
    }
  }

  void _tryMoveDir(int dx, int dy) {
    if (_gameOver || _walking) return;
    HapticFeedback.lightImpact();

    final nc = _playerPos.x + dx;
    final nr = _playerPos.y + dy;

    if (dy > 0) {
      _facing = Facing.down;
    } else if (dy < 0) {
      _facing = Facing.up;
    } else if (dx > 0) {
      _facing = Facing.right;
    } else if (dx < 0) {
      _facing = Facing.left;
    }

    if (!_walkable(nc, nr)) return;

    setState(() {
      _playerPos = Point(nc, nr);
      _walking = true;
      _turn++;
      // Jika sebelumnya berlindung lalu bergerak, otomatis berdiri dan reset tahap
      if (_isSheltered) {
        _shelterStage = ShelterStage.none;
      }
    });
  }

  void _afterMoveLanded() {
    final c = _playerPos.x;
    final r = _playerPos.y;

    if (_quakeActive) {
      _quakeClockMs = 0; // langkah manual ikut menggeser gempa
      _resolveQuakeStep();
      if (_gameOver) return;
    } else {
      _levelScore += 2;

      // Masa tenang sebelum gempa susulan (Level 3)
      if (_quakePhase == QuakePhase.calmAfterMain && _level.hasAftershock) {
        _calmTurnsLeft--;
        // Gempa susulan juga dipastikan datang saat siswa sampai di pintu keluar
        if (_calmTurnsLeft <= 0 || _isExitDoor(c, r)) {
          _triggerAftershock();
          return;
        }
      }
    }

    _checkGoal();
  }

  /// Cek apakah siswa sudah di titik kumpul dan boleh menyelesaikan level.
  void _checkGoal() {
    if (_gameOver) return;
    if (_tileAt(_playerPos.x, _playerPos.y) != 'X') return;

    if (!_quakeHappened) {
      _setDialog('TARIK TUAS ALARM GEMPA DULU! SIMULASI BELUM DIMULAI.',
          DialogMode.normal);
    } else if (_quakeActive) {
      _setDialog('TUNGGU GETARAN REDA DULU!', DialogMode.quake);
    } else if (_level.hasAftershock &&
        _quakePhase == QuakePhase.calmAfterMain) {
      _triggerAftershock(); // susulan datang sebelum benar-benar aman
    } else {
      _finishLevel(true);
    }
  }

  void _resolveQuakeStep() {
    _quakeTurnsLeft--;
    _spawnShardsFromGlass();

    final c = _playerPos.x;
    final r = _playerPos.y;
    final onMeja = _tileAt(c, r) == 'M';
    final danger = _isNearGlass(c, r) && !onMeja;
    final dmgMul = _level.damageMultiplier;
    final isAftershock = _quakePhase == QuakePhase.aftershock;

    if (_isHolding && onMeja) {
      _levelScore += 10;
      _setDialog(
          isAftershock
              ? '🛡 HOLD ON! REFLEKS BAGUS SAAT GEMPA SUSULAN!'
              : '🛡 HOLD ON! KAMU TERLINDUNGI DENGAN SEMPURNA!',
          DialogMode.safe);
    } else if (_shelterStage == ShelterStage.cover && onMeja) {
      _levelScore += 6;
      _setDialog(
          'BAGUS, SEKARANG HOLD ON! TEKAN A SEKALI LAGI!', DialogMode.safe);
    } else if (danger) {
      if (_isSheltered) {
        // Jika merunduk (drop) tapi belum di bawah meja, kurangi damage separuh
        _hp = max(0, _hp - (8 * dmgMul).round());
        _screenShake = 5;
        _flashT = 4;
        _spawnDust(c * tileSize + tileSize / 2, r * tileSize + tileSize / 2);
        HapticFeedback.mediumImpact();
        _setDialog('MERUNDUK MENGURANGI CEDERA! CARI MEJA KOKOH UNTUK COVER!',
            DialogMode.quake);
      } else {
        _hp = max(0, _hp - (16 * dmgMul).round());
        _screenShake = 8;
        _flashT = 6;
        _spawnDust(c * tileSize + tileSize / 2, r * tileSize + tileSize / 2);
        HapticFeedback.heavyImpact();
        _setDialog(
            isAftershock
                ? '⚠ GEMPA SUSULAN! AWAS KACA! TEKAN A UNTUK DROP SEKARANG!'
                : 'AWAS! KACA PECAH DI DEKATMU! TEKAN A UNTUK DROP!',
            DialogMode.quake);
      }
    } else if (onMeja) {
      _levelScore += 4;
      _setDialog('DEKAT MEJA. TEKAN TOMBOL A UNTUK MULAI DROP, COVER, HOLD ON!',
          DialogMode.safe);
    } else {
      _levelScore += 1;
      _setDialog(
          isAftershock
              ? 'GEMPA SUSULAN MASIH BERLANGSUNG... TEKAN A UNTUK DROP!'
              : 'GEDUNG MASIH BERGETAR... TEKAN A UNTUK DROP SEKARANG!',
          DialogMode.quake);
    }

    if (_hp <= 0) {
      _hp = 0;
      _finishLevel(false);
      return;
    }

    if (_quakeTurnsLeft <= 0) {
      if (isAftershock) {
        _endAftershock();
      } else {
        _endMainQuake();
      }
    }
  }

  void _startQuake() {
    if (_quakePhase != QuakePhase.idle || _quakeHappened || _gameOver) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _quakePhase = QuakePhase.mainQuake;
      _quakeHappened = true;
      _quakeTurnsLeft = _level.mainQuakeTurns;
      _quakeClockMs = -900; // jeda reaksi sebelum getaran pertama dihitung
      _screenShake = 10;
      _leverActive = true;
      _setDialog(
          'GEMPA ${_level.levelNumber == 1 ? "7.2" : _level.levelNumber == 2 ? "7.8" : "8.1"} SR! TEKAN A UNTUK DROP, COVER, HOLD ON!${_level.timedQuake ? " TAHAN POSISI SAMPAI GETARAN REDA!" : ""}',
          DialogMode.quake);
    });
  }

  void _endMainQuake() {
    if (_level.hasAftershock) {
      setState(() {
        _quakePhase = QuakePhase.calmAfterMain;
        _calmTurnsLeft = _level.calmTurnsBeforeAftershock;
        _setDialog(
            'GETARAN UTAMA REDA. WASPADA GEMPA SUSULAN! SEGERA KELUAR LEWAT PINTU HIJAU "KELUAR" MENUJU TITIK KUMPUL.',
            DialogMode.normal);
      });
    } else {
      setState(() {
        _quakePhase = QuakePhase.resolved;
        _setDialog(
            'GETARAN REDA. MENUJU PINTU LALU TITIK KUMPUL.', DialogMode.normal);
      });
    }
  }

  void _triggerAftershock() {
    HapticFeedback.heavyImpact();
    setState(() {
      _quakePhase = QuakePhase.aftershock;
      _quakeTurnsLeft = _level.aftershockTurns;
      _quakeClockMs = -900; // jeda reaksi
      _screenShake = 9;
      _setDialog(
          '⚠ GEMPA SUSULAN DATANG TIBA-TIBA! CEPAT DROP, COVER, HOLD ON LAGI!',
          DialogMode.quake);
    });
  }

  void _endAftershock() {
    setState(() {
      _quakePhase = QuakePhase.resolved;
      _setDialog(
          'GEMPA SUSULAN REDA. SEKARANG AMAN, KELUAR LEWAT PINTU "KELUAR" KE TITIK KUMPUL!',
          DialogMode.safe);
    });
  }

  void _finishLevel(bool won) {
    final passedHpCheck = _level.passHpRatio <= 0.0 ||
        (_hp / _level.startHp) >= _level.passHpRatio;
    final actuallyWon = won && passedHpCheck;

    setState(() {
      _gameOver = true;
      if (actuallyWon) {
        final int turnBonus = max<int>(0, 60 - _turn * 2);
        final int bonus = (_hp * 2) + turnBonus;
        _levelScore += bonus;
        _totalScore += _levelScore;
      }
    });

    if (!won) {
      // Kalah karena HP habis di tengah jalan
      _showRetryLevelDialog(
          'SISWA TERKENA RERUNTUHAN. COBA LAKUKAN DROP, COVER, HOLD ON LEBIH CEPAT.');
      return;
    }

    if (!passedHpCheck) {
      // Sampai titik kumpul tapi HP terlalu rendah
      _showRetryLevelDialog(
          'SISWA SELAMAT TAPI TERLALU BANYAK CEDERA (HP < ${(_level.passHpRatio * 100).round()}%). '
          'LINDUNGI DIRI LEBIH BAIK LAGI!');
      return;
    }

    final isLastLevel = _levelIndex == _levels.length - 1;
    if (isLastLevel) {
      UserProgressManager().completeGameStep(badgeId: 'master_evakuasi');
      _showFinalWinDialog();
    } else {
      _showLevelClearDialog();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  DIALOG — gaya kartu ramah anak
  // ══════════════════════════════════════════════════════════════════
  Widget _dialogShell({
    required String emoji,
    required String title,
    required Color accent,
    required Widget body,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.86,
            ),
            decoration: BoxDecoration(
              color: AppPalette.cream,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3331355A),
                  blurRadius: 32,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(accent, Colors.white, 0.35)!,
                                accent
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.30),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.navy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        body,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogPrimaryButton(
    String label,
    Color color,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelClearDialog() {
    final nextLevel = _levels[_levelIndex + 1];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _dialogShell(
        emoji: '🎉',
        title: 'Hebat! ${_level.title.split('—').last.trim()} selesai!',
        accent: AppPalette.mintDeep,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppPalette.sunnySoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.sunny, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'SKOR LEVEL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkSoft,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _levelScore.toString().padLeft(4, '0'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppPalette.navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.lineBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    'LEVEL BERIKUTNYA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.inkSoft,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLevel.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppPalette.skyDeep,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    nextLevel.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: AppPalette.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _dialogPrimaryButton(
            'LANJUT KE LEVEL BERIKUTNYA',
            AppPalette.skyDeep,
            () {
              Navigator.pop(context);
              setState(() {
                _levelIndex++;
              });
              _resetLevel();
            },
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }

  void _showFinalWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _dialogShell(
        emoji: '🏆',
        title: 'Misi Siaga Selesai!',
        accent: AppPalette.sunnyDeep,
        body: Column(
          children: [
            const Text(
              'Kamu berhasil menyelamatkan diri di 3 skenario gempa, termasuk gempa susulan. Kamu siap jadi Juara Mitigasi!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppPalette.navy,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppPalette.sunnyGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'SKOR TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _totalScore.toString().padLeft(4, '0'),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_preTestCorrect != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppPalette.skyMist,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppPalette.skySoft),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 17,
                      color: AppPalette.skyDeep,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Skor pre-test kamu: $_preTestCorrect/$_preTestTotal benar. '
                        'Saatnya kerjakan post-test untuk melihat kemajuanmu!',
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          _dialogPrimaryButton(
            'LANJUT KE POST-TEST',
            AppPalette.mintDeep,
            () {
              Navigator.pop(context);
              _runPostTest();
            },
            icon: Icons.quiz_rounded,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Lewati post-test, kembali ke daftar game',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppPalette.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRetryLevelDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _dialogShell(
        emoji: '💥',
        title: 'Ups, coba lagi!',
        accent: AppPalette.coralDeep,
        body: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppPalette.navy,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppPalette.coralSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ingat: DROP dulu, lalu cari meja untuk COVER, dan HOLD ON sampai getaran reda.',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.coralDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _dialogPrimaryButton(
            'ULANGI LEVEL INI',
            AppPalette.coralDeep,
            () {
              Navigator.pop(context);
              _resetLevel();
            },
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  // ---------------- TUTORIAL MODAL (Drop, Cover, Hold On) ----------------
  void _showTutorialModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _dialogShell(
        emoji: '🚨',
        title: 'Drop, Cover & Hold On',
        accent: AppPalette.coralDeep,
        body: Column(
          children: [
            const Text(
              'Tiga langkah penyelamat saat gempa. Lakukan berurutan, ya!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: AppPalette.inkSoft,
              ),
            ),
            const SizedBox(height: 14),
            const _TutorialStep(
              number: '1',
              title: 'DROP',
              desc:
                  'Segera merunduk ke lantai sebelum guncangan membuatmu jatuh.',
              color: AppPalette.coralDeep,
              icon: Icons.arrow_downward_rounded,
            ),
            const SizedBox(height: 8),
            const _TutorialStep(
              number: '2',
              title: 'COVER',
              desc:
                  'Berlindung di bawah meja kokoh, lindungi kepala dan lehermu.',
              color: AppPalette.sunnyDeep,
              icon: Icons.shield_rounded,
            ),
            const SizedBox(height: 8),
            const _TutorialStep(
              number: '3',
              title: 'HOLD ON',
              desc:
                  'Pegang kaki meja dan bertahan sampai getaran benar-benar berhenti.',
              color: AppPalette.mintDeep,
              icon: Icons.pan_tool_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppPalette.skyMist,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.skySoft),
              ),
              child: const Row(
                children: [
                  Text('⚠', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Level 3 punya gempa susulan. Tetap waspada meski getaran utama sudah reda!',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _dialogPrimaryButton(
            'MULAI SIMULASI',
            AppPalette.skyDeep,
            () {
              Navigator.pop(context);
              setState(() => _showIntroTutorial = false);
            },
            icon: Icons.play_arrow_rounded,
          ),
        ],
      ),
    );
  }

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) => _dialogShell(
        emoji: '📖',
        title: 'Panduan Bermain',
        accent: AppPalette.skyDeep,
        body: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.directions_walk_rounded,
              highlight: 'Tombol panah',
              text: 'menggerakkan siswa satu kotak.',
              color: AppPalette.skyDeep,
            ),
            _HelpItem(
              icon: Icons.touch_app_rounded,
              highlight: 'Tombol aksi besar',
              text: 'ditekan berulang saat gempa: DROP → COVER → HOLD ON.',
              color: AppPalette.coralDeep,
            ),
            _HelpItem(
              icon: Icons.campaign_rounded,
              highlight: 'Tombol mulai gempa',
              text: 'menyalakan alarm dan memulai guncangan.',
              color: AppPalette.sunnyDeep,
            ),
            _HelpItem(
              icon: Icons.window_rounded,
              highlight: 'Kaca',
              text: 'berbahaya saat gempa. Jangan berdiri di dekatnya.',
              color: AppPalette.skyDeep,
            ),
            _HelpItem(
              icon: Icons.table_restaurant_rounded,
              highlight: 'Meja',
              text: 'tempat terbaik untuk COVER dan HOLD ON.',
              color: AppPalette.mintDeep,
            ),
            _HelpItem(
              icon: Icons.flag_rounded,
              highlight: 'Pintu keluar hijau',
              text: 'menuju titik kumpul di halaman sekolah.',
              color: AppPalette.mintDeep,
            ),
            _HelpItem(
              icon: Icons.warning_amber_rounded,
              highlight: 'Level 3',
              text: 'ada gempa susulan setelah gempa utama reda.',
              color: AppPalette.coralDeep,
            ),
          ],
        ),
        actions: [
          _dialogPrimaryButton(
            'MENGERTI',
            AppPalette.skyDeep,
            () => Navigator.pop(context),
            icon: Icons.check_rounded,
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showTutorialModal();
            },
            child: const Text(
              'Lihat tutorial Drop, Cover, Hold On',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppPalette.skyDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _inspectTile() {
    final c = _playerPos.x;
    final r = _playerPos.y;
    final t = _tileAt(c, r);
    const names = {
      '.': 'LANTAI KOSONG',
      'M': 'MEJA — AMAN SAAT GEMPA (COVER DI SINI)',
      'K': 'KACA — BAHAYA SAAT GEMPA',
      'D': 'PINTU KELUAR',
      'G': 'JALUR LUAR',
      'X': 'TITIK KUMPUL',
    };
    if (_isExitDoor(c, r)) {
      _setDialog(
          'PINTU KELUAR — JALUR EVAKUASI MENUJU TITIK KUMPUL', DialogMode.safe);
      return;
    }
    _setDialog(names[t] ?? '...', DialogMode.normal);
  }

  void _gameLoop(int dtMs) {
    if (!mounted) return;

    _animTime++;

    // Tween player pixel position toward target tile
    final targetX = _playerPos.x * tileSize;
    final targetY = _playerPos.y * tileSize;
    const speed = 3.2;
    bool arrived = true;

    if ((_px - targetX).abs() > 0.5) {
      _px += (_px < targetX ? 1 : -1) * min(speed, (_px - targetX).abs());
      arrived = false;
    } else {
      _px = targetX;
    }

    if ((_py - targetY).abs() > 0.5) {
      _py += (_py < targetY ? 1 : -1) * min(speed, (_py - targetY).abs());
      arrived = false;
    } else {
      _py = targetY;
    }

    if (_walking && arrived) {
      _walking = false;
      _afterMoveLanded();
    }

    // Level dengan timedQuake: getaran tetap berjalan walau pemain diam
    // (sehingga HOLD ON benar-benar bisa dilakukan sampai gempa reda).
    if (_level.timedQuake && _quakeActive && !_walking && !_gameOver) {
      _quakeClockMs += dtMs;
      if (_quakeClockMs >= _quakeStepMs) {
        _quakeClockMs = 0;
        _resolveQuakeStep();
        _checkGoal();
      }
    } else {
      _quakeClockMs = 0;
    }

    // Update Particles
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.type == 'shard') {
        p.vy += 0.12;
        p.rot += p.vr;
      }
      p.life--;
    }
    _particles.removeWhere((p) => p.life <= 0);

    if (_screenShake > 0) {
      _screenShake *= 0.82;
      if (_screenShake < 0.1) _screenShake = 0.0;
    }

    if (_flashT > 0) {
      _flashT--;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  //  LAYAR UTAMA
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.skyMist,
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.skyGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildGamePanel(),
                    const SizedBox(height: 12),
                    _buildControlsCard(),
                    const SizedBox(height: 12),
                    _buildAlarmPanel(),
                    const SizedBox(height: 10),
                    const Text(
                      'SiGempa Malut  ·  Simulasi Drop, Cover, Hold On',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xB331355A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _softIconButton(
          Icons.arrow_back_rounded,
          AppPalette.navy,
          () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulasi Gempa',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Level ${_levelIndex + 1} · ${_level.title.split('—').last.trim()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F31355A),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 18, color: AppPalette.sunnyDeep),
              const SizedBox(width: 4),
              Text(
                '${_totalScore + _levelScore}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _softIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A31355A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  // ── PANEL GAME (layar + balon dialog) ────────────────────────────
  Widget _buildGamePanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppPalette.cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2631355A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildScreen(),
          const SizedBox(height: 10),
          _buildDialogBubble(),
          const SizedBox(height: 8),
          _buildMissionCard(),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    final screenBorder = _quakeActive
        ? AppPalette.coralDeep
        : (_quakeHappened ? AppPalette.mintDeep : Colors.white);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: screenBorder, width: 3),
        color: AppPalette.skyMist,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F31355A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _quakeActive
                      ? const [Color(0xFFFFE7DF), Color(0xFFFFD3C6)]
                      : const [
                          Color(0xFFE9F9FF),
                          Color(0xFFC7EEFF),
                          Color(0xFF9ADCF7)
                        ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              (_random.nextDouble() - 0.5) * _screenShake,
              (_random.nextDouble() - 0.5) * _screenShake,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.contain,
                child: CustomPaint(
                  size: _GameCanvasPainter.isoCanvasSize(cols, rows),
                  painter: _GameCanvasPainter(
                    map: _level.map,
                    px: _px,
                    py: _py,
                    facing: _facing,
                    walking: _walking,
                    animTime: _animTime,
                    quakeActive: _quakeActive,
                    particles: _particles,
                    shelterStage: _shelterStage,
                    levelNumber: _level.levelNumber,
                  ),
                ),
              ),
            ),
          ),
          // Chip level & nyawa
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F31355A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'LV ${_levelIndex + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F31355A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(5, (i) {
                  final segment = _level.startHp / 5.0;
                  final val = (_hp - i * segment).clamp(0, segment) / segment;
                  return Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 1),
                    child: Icon(
                      val > 0.5
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 13,
                      color: val > 0
                          ? AppPalette.coralDeep
                          : AppPalette.lineBorder,
                    ),
                  );
                }),
              ),
            ),
          ),
          // Banner getaran
          if (_quakeActive)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(child: _buildQuakeBanner()),
            ),
          // Kilatan cedera
          if (_flashT > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: AppPalette.coralDeep
                      .withValues(alpha: (_flashT / 6 * 0.35).clamp(0.0, 1.0)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuakeBanner() {
    final pulse = (sin(_animTime / 5.0) * 0.5 + 0.5).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.coralDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4 + pulse * 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.coralDeep.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.vibration_rounded,
            size: 13,
            color: Colors.white.withValues(alpha: 0.85 + pulse * 0.15),
          ),
          const SizedBox(width: 5),
          const Text(
            'GEMPA!',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogBubble() {
    Color bg;
    Color border;
    Color textColor;
    switch (_dialogMode) {
      case DialogMode.quake:
        bg = AppPalette.coralSoft;
        border = AppPalette.coral;
        textColor = AppPalette.coralDark;
        break;
      case DialogMode.safe:
        bg = const Color(0xFFE8FBF1);
        border = AppPalette.mint;
        textColor = AppPalette.forest;
        break;
      case DialogMode.normal:
        bg = AppPalette.skyMist;
        border = AppPalette.skySoft;
        textColor = AppPalette.navy;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.lineBorder, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1431355A),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: CustomPaint(
            painter: TurtlePainter(
              expression: _dialogMode == DialogMode.quake
                  ? TurtleExpression.alert
                  : (_dialogMode == DialogMode.safe
                      ? TurtleExpression.proud
                      : TurtleExpression.happy),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Text(
              _dialogText,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── KARTU MISI DROP · COVER · HOLD ON ────────────────────────────
  Widget _buildMissionCard() {
    final stageIndex = _shelterStage.index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.lineBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.checklist_rounded,
            size: 15,
            color: AppPalette.navy,
          ),
          const SizedBox(width: 5),
          const Text(
            'MISI',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: AppPalette.navy,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 6),
          _missionStep(
            1,
            Icons.arrow_downward_rounded,
            'DROP',
            AppPalette.coralDeep,
            done: stageIndex >= 1,
            active: _quakeActive && stageIndex == 0,
          ),
          const SizedBox(width: 4),
          _missionStep(
            2,
            Icons.shield_rounded,
            'COVER',
            AppPalette.sunnyDeep,
            done: stageIndex >= 2,
            active: stageIndex == 1,
          ),
          const SizedBox(width: 4),
          _missionStep(
            3,
            Icons.pan_tool_rounded,
            'HOLD ON',
            AppPalette.mintDeep,
            done: stageIndex >= 3,
            active: stageIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _missionStep(
    int number,
    IconData icon,
    String title,
    Color color, {
    required bool done,
    required bool active,
  }) {
    final isOn = done || active;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: BoxDecoration(
          color: done
              ? color.withValues(alpha: 0.14)
              : (active ? color.withValues(alpha: 0.10) : Colors.white),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: done
                ? color.withValues(alpha: 0.50)
                : (active ? color : AppPalette.lineBorder),
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_rounded : icon,
              size: 11,
              color: isOn ? color : AppPalette.inkSoft,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                '$number $title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  color: isOn ? color : AppPalette.inkSoft,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KONTROL: D-PAD + TOMBOL AKSI ─────────────────────────────────
  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppPalette.cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F31355A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              _buildDpad(),
              const SizedBox(height: 6),
              const Text(
                'GERAK',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppPalette.inkSoft,
                ),
              ),
            ],
          ),
          _buildActionButton(),
          Column(
            children: [
              _buildMiniAction(
                Icons.menu_book_rounded,
                'PANDUAN',
                AppPalette.skyDeep,
                _showHelpModal,
              ),
              const SizedBox(height: 8),
              _buildMiniAction(
                Icons.refresh_rounded,
                'ULANGI',
                AppPalette.sunnyDeep,
                _resetLevel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDpad() {
    const double size = 118;
    const double arm = 38;
    const double gap = 0.5;

    Widget key(IconData icon, BorderRadius radius, VoidCallback onTap) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: radius,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF1ECDD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFE4DCC9), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2931355A),
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: AppPalette.navy),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: arm + gap,
            left: arm + gap,
            width: arm,
            height: arm,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1ECDD),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: arm + gap,
            width: arm,
            height: arm,
            child: key(
              Icons.keyboard_arrow_up_rounded,
              const BorderRadius.vertical(top: Radius.circular(14)),
              () => _tryMoveDir(0, -1),
            ),
          ),
          Positioned(
            bottom: 0,
            left: arm + gap,
            width: arm,
            height: arm,
            child: key(
              Icons.keyboard_arrow_down_rounded,
              const BorderRadius.vertical(bottom: Radius.circular(14)),
              () => _tryMoveDir(0, 1),
            ),
          ),
          Positioned(
            left: 0,
            top: arm + gap,
            width: arm,
            height: arm,
            child: key(
              Icons.keyboard_arrow_left_rounded,
              const BorderRadius.horizontal(left: Radius.circular(14)),
              () => _tryMoveDir(-1, 0),
            ),
          ),
          Positioned(
            right: 0,
            top: arm + gap,
            width: arm,
            height: arm,
            child: key(
              Icons.keyboard_arrow_right_rounded,
              const BorderRadius.horizontal(right: Radius.circular(14)),
              () => _tryMoveDir(1, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    String label;
    IconData icon;
    Color color;
    String hint;

    if (!_quakeActive && !_isSheltered) {
      label = 'CEK';
      icon = Icons.search_rounded;
      color = AppPalette.skyDeep;
      hint = 'Periksa objek';
    } else {
      switch (_shelterStage) {
        case ShelterStage.none:
          label = 'DROP';
          icon = Icons.arrow_downward_rounded;
          color = AppPalette.coralDeep;
          hint = 'Merunduk sekarang!';
          break;
        case ShelterStage.drop:
          label = 'COVER';
          icon = Icons.shield_rounded;
          color = AppPalette.sunnyDeep;
          hint = 'Cari meja kokoh';
          break;
        case ShelterStage.cover:
          label = 'HOLD ON';
          icon = Icons.pan_tool_rounded;
          color = AppPalette.mintDeep;
          hint = 'Pegang kaki meja';
          break;
        case ShelterStage.holdOn:
          label = _quakeActive ? 'TAHAN' : 'BERDIRI';
          icon = _quakeActive
              ? Icons.pan_tool_rounded
              : Icons.accessibility_new_rounded;
          color = _quakeActive ? AppPalette.mintDeep : AppPalette.skyDeep;
          hint = _quakeActive ? 'Tahan sampai reda' : 'Berdiri kembali';
          break;
      }
    }

    final pulse = (sin(_animTime / 6.0) * 0.5 + 0.5).clamp(0.0, 1.0);
    final shouldPulse = _quakeActive || _isSheltered;

    return SizedBox(
      width: 104,
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (shouldPulse)
                  Container(
                    width: 88 + pulse * 10,
                    height: 88 + pulse * 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.35 - pulse * 0.2),
                        width: 4,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (_quakeActive || _isSheltered) {
                      _advanceShelterStage();
                    } else {
                      _inspectTile();
                    }
                  },
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(color, Colors.white, 0.22)!,
                          color,
                          Color.lerp(color, Colors.black, 0.14)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.42),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 26, color: Colors.white),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                hint,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.inkSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 62,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PANEL ALARM / MULAI GEMPA ────────────────────────────────────
  Widget _buildAlarmPanel() {
    final started = _leverActive;
    final title = !started
        ? 'MULAI SIMULASI GEMPA'
        : (_quakeActive
            ? 'GEMPA BERLANGSUNG!'
            : (_quakePhase == QuakePhase.calmAfterMain
                ? 'WASPADA GEMPA SUSULAN'
                : 'GETARAN REDA — EVAKUASI'));
    final subtitle = !started
        ? 'Tekan alarm, lalu lindungi diri dengan Drop, Cover, Hold On.'
        : (_quakeActive
            ? 'Drop, Cover, Hold On sekarang. Jangan berdiri di dekat kaca!'
            : (_quakePhase == QuakePhase.calmAfterMain
                ? 'Bergegas ke pintu keluar hijau menuju titik kumpul.'
                : 'Keluar lewat pintu hijau, lalu menuju bendera titik kumpul.'));

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: started
            ? null
            : () {
                HapticFeedback.heavyImpact();
                _startQuake();
              },
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            gradient: started
                ? const LinearGradient(
                    colors: [Color(0xFF7C89AC), Color(0xFF5A6788)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppPalette.coralGradient,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (started ? AppPalette.navy : AppPalette.coralDeep)
                    .withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  started
                      ? (_quakeActive
                          ? Icons.vibration_rounded
                          : Icons.flag_rounded)
                      : Icons.campaign_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (!started)
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 22,
                    color: AppPalette.coralDeep,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  WIDGET PENDUKUNG DIALOG
// ══════════════════════════════════════════════════════════════════
class _TutorialStep extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final Color color;
  final IconData icon;

  const _TutorialStep({
    required this.number,
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.lerp(color, Colors.white, 0.25)!, color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: AppPalette.navy,
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

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String highlight;
  final String text;
  final Color color;

  const _HelpItem({
    required this.icon,
    required this.highlight,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$highlight ',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: AppPalette.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  RENDERER ISOMETRIK — "DIORAMA KELAS" YANG CERIA UNTUK ANAK SD
// ══════════════════════════════════════════════════════════════════
class _GameCanvasPainter extends CustomPainter {
  final List<List<String>> map;
  final double px;
  final double py;
  final Facing facing;
  final bool walking;
  final int animTime;
  final bool quakeActive;
  final List<Particle> particles;
  final ShelterStage shelterStage;
  final int levelNumber;

  _GameCanvasPainter({
    required this.map,
    required this.px,
    required this.py,
    required this.facing,
    required this.walking,
    required this.animTime,
    required this.quakeActive,
    required this.particles,
    required this.shelterStage,
    this.levelNumber = 1,
  });

  // ── Dimensi tile isometrik ──────────────────────────────────────
  static const double tw = 48.0;
  static const double th = 24.0;
  static const double wallH = 42.0;
  static const double floorLip = 6.0;

  static Size isoCanvasSize(int cols, int rows) {
    final w = (cols + rows) * tw / 2;
    final h = wallH + 30 + (cols + rows - 2) * th / 2 + th + 42;
    return Size(w, h);
  }

  double get _originX => map.length * tw / 2;
  double get _originY => wallH + 30;

  /// Proyeksi titik grid (boleh pecahan) + ketinggian z ke koordinat layar.
  Offset _p(num gx, num gy, [double z = 0]) {
    return Offset(
      _originX + (gx - gy) * (tw / 2),
      _originY + (gx + gy) * (th / 2) - z,
    );
  }

  int _hash(int a, int b) {
    var h = a * 73856093 ^ b * 19349663 ^ levelNumber * 83492791;
    h &= 0x7fffffff;
    return h;
  }

  double _wob(int c, int r) {
    if (!quakeActive) return 0;
    return sin(animTime / 2.2 + c * 0.9 + r * 1.3) * 0.9;
  }

  // ── Path primitives ─────────────────────────────────────────────
  Path _quad(Offset a, Offset b, Offset c, Offset d) {
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
  }

  Path _tilePath(double x0, double y0, double x1, double y1, double z) {
    return _quad(
      _p(x0, y0, z),
      _p(x1, y0, z),
      _p(x1, y1, z),
      _p(x0, y1, z),
    );
  }

  void _fill(Canvas canvas, Path path, Color color) {
    canvas.drawPath(path, Paint()..color = color);
  }

  void _stroke(Canvas canvas, Path path, Color color, double width) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Balok isometrik dengan 2 sisi tampak + atap.
  void _box(
    Canvas canvas,
    double x0,
    double y0,
    double x1,
    double y1,
    double base,
    double h, {
    required Color top,
    required Color left,
    required Color right,
    Color? stroke,
    double strokeWidth = 0.6,
  }) {
    final t0 = _p(x0, y0, base + h);
    final t1 = _p(x1, y0, base + h);
    final t2 = _p(x1, y1, base + h);
    final t3 = _p(x0, y1, base + h);
    final b1 = _p(x1, y0, base);
    final b2 = _p(x1, y1, base);
    final b3 = _p(x0, y1, base);

    canvas.drawPath(_quad(t3, t2, b2, b3), Paint()..color = left);
    canvas.drawPath(_quad(t2, t1, b1, b2), Paint()..color = right);
    canvas.drawPath(_quad(t0, t1, t2, t3), Paint()..color = top);

    if (stroke != null) {
      _stroke(canvas, _quad(t3, t2, b2, b3), stroke, strokeWidth);
      _stroke(canvas, _quad(t2, t1, b1, b2), stroke, strokeWidth);
      _stroke(canvas, _quad(t0, t1, t2, t3), stroke, strokeWidth);
    }
  }

  void _floorShadow(Canvas canvas, int c, int r, double width, double height) {
    final o = _p(c + 0.5, r + 0.55, 0);
    canvas.drawOval(
      Rect.fromCenter(center: o, width: width, height: height),
      Paint()
        ..color = const Color(0x33231A12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
  }

  // ── Fasad dinding (untuk dekorasi) ─────────────────────────────
  Offset _faceL(int c, int r, double u, double z) => _p(c + u, r + 1, z);
  Offset _faceR(int c, int r, double u, double z) => _p(c + 1, r + u, z);

  Path _quadL(int c, int r, double u0, double u1, double z0, double z1) {
    return _quad(
      _faceL(c, r, u0, z1),
      _faceL(c, r, u1, z1),
      _faceL(c, r, u1, z0),
      _faceL(c, r, u0, z0),
    );
  }

  Path _quadR(int c, int r, double u0, double u1, double z0, double z1) {
    return _quad(
      _faceR(c, r, u0, z1),
      _faceR(c, r, u1, z1),
      _faceR(c, r, u1, z0),
      _faceR(c, r, u0, z0),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PAINT
  // ══════════════════════════════════════════════════════════════
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackdrop(canvas, size);

    // Bayangan besar di bawah diorama agar "mengambang" dengan rapi.
    final cols = map[0].length;
    final rows = map.length;

    // Pemain yang sedang berlindung digambar SEBELUM meja pada petak yang
    // sama, lalu meja digambar ulang di atasnya supaya terlihat di bawah meja.
    final playerCol = (px / 27.0).round();
    final playerRow = (py / 27.0).round();
    final underDesk = shelterStage != ShelterStage.none &&
        playerCol >= 0 &&
        playerCol < cols &&
        playerRow >= 0 &&
        playerRow < rows &&
        map[playerRow][playerCol] == 'M';

    final center = _p(cols / 2, rows / 2, 0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 34),
        width: (cols + rows) * tw * 0.56,
        height: (cols + rows) * th * 0.85,
      ),
      Paint()
        ..color = const Color(0x1F31355A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (underDesk && c == playerCol && r == playerRow) {
          _drawFloor(canvas, c, r);
          _drawChair(canvas, c, r);
          continue;
        }
        _drawIsoTile(canvas, c, r);
      }
    }

    _drawSigns(canvas);
    _drawAmbient(canvas);
    _drawParticles(canvas);
    _drawPlayer(canvas);
    if (underDesk) {
      _drawDesk(canvas, playerCol, playerRow, shadow: false, chair: false);
    }
  }

  void _drawBackdrop(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final colors = quakeActive
        ? const [
            Color(0xFFFFF2E8),
            Color(0xFFFFE0D2),
            Color(0xFFFFC9B8),
          ]
        : const [
            Color(0xFFDCF5FF),
            Color(0xFFB9E9FB),
            Color(0xFF8FD8F5),
          ];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );

    // Matahari lembut di sudut kanan atas.
    final sun = Offset(size.width - 30, 26);
    canvas.drawCircle(
      sun,
      16,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.55),
    );
    canvas.drawCircle(sun, 10, Paint()..color = AppPalette.sunny);
    canvas.drawCircle(
      sun,
      6.5,
      Paint()..color = const Color(0xFFFFE39B),
    );

    // Awan kapas.
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.7);
    void puff(double x, double y, double s) {
      canvas.drawCircle(Offset(x, y), 9 * s, cloud);
      canvas.drawCircle(Offset(x + 9 * s, y + 2 * s), 7 * s, cloud);
      canvas.drawCircle(Offset(x - 9 * s, y + 2.5 * s), 6 * s, cloud);
      canvas.drawCircle(Offset(x, y + 4 * s), 8 * s, cloud);
    }

    puff(42, 34, 1.0);
    puff(size.width * 0.44, 20, 0.75);
    puff(size.width - 84, 58, 0.85);
  }

  // ── TILE ───────────────────────────────────────────────────────
  bool _isOutdoorTile(int c, int r) {
    if (c < 0 || r < 0 || c >= map[0].length || r >= map.length) {
      return true;
    }
    final t = map[r][c];
    return t == 'G' || t == 'X';
  }

  /// Dinding di sisi dekat kamera dipotong rendah supaya ruangan kelas
  /// terlihat utuh (gaya diorama "cutaway"), bukan tertutup tembok.
  bool _isNearWall(int c, int r) {
    return (r + 1 >= map.length || _isOutdoorTile(c, r + 1)) ||
        (c + 1 >= map[0].length || _isOutdoorTile(c + 1, r));
  }

  void _drawIsoTile(Canvas canvas, int c, int r) {
    final t = map[r][c];
    switch (t) {
      case '#':
        if (_isNearWall(c, r)) {
          _drawLowWall(canvas, c, r);
        } else {
          _drawWall(canvas, c, r);
        }
        break;
      case 'K':
        _drawGlassWall(canvas, c, r);
        break;
      case 'D':
        _drawDoor(canvas, c, r);
        break;
      case 'M':
        _drawFloor(canvas, c, r);
        _drawDesk(canvas, c, r);
        break;
      case 'G':
        _drawGrass(canvas, c, r);
        break;
      case 'X':
        _drawGrass(canvas, c, r);
        _drawAssemblyPoint(canvas, c, r);
        break;
      default:
        _drawFloor(canvas, c, r);
        if (quakeActive && _isNearGlass(c, r)) {
          _drawDangerGlow(canvas, c, r);
        }
        if (quakeActive && _hash(c, r) % 4 == 0) {
          _drawFloorCrack(canvas, c, r);
        }
    }
  }

  // ── LANTAI KAYU ────────────────────────────────────────────────
  void _drawFloor(Canvas canvas, int c, int r) {
    final even = (c + r) % 2 == 0;
    final top = even ? const Color(0xFFF7E3BC) : const Color(0xFFF2D9AD);
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      -floorLip,
      floorLip,
      top: top,
      left: const Color(0xFFD0A96F),
      right: const Color(0xFFE0BE85),
      stroke: const Color(0x1A6B4A22),
    );

    final path = _tilePath(c.toDouble(), r.toDouble(), c + 1.0, r + 1.0, 0);
    canvas.save();
    canvas.clipPath(path);

    final seam = Paint()
      ..color = const Color(0x1FA0713C)
      ..strokeWidth = 0.7;
    for (final v in const [0.34, 0.67]) {
      canvas.drawLine(
        _p(c.toDouble(), r + v),
        _p(c + 1.0, r + v),
        seam,
      );
    }
    canvas.drawLine(
      _p(c + 0.52, r.toDouble()),
      _p(c + 0.52, r + 1.0),
      seam,
    );

    // Kilau lembut di tepi belakang lantai.
    canvas.drawLine(
      _p(c.toDouble(), r.toDouble()),
      _p(c + 1.0, r.toDouble()),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 1.2,
    );
    canvas.restore();
  }

  void _drawDangerGlow(Canvas canvas, int c, int r) {
    final pulse = (sin(animTime / 5.0 + c + r) * 0.5 + 0.5).clamp(0.0, 1.0);
    final path = _tilePath(c.toDouble(), r.toDouble(), c + 1.0, r + 1.0, 0);
    _fill(canvas, path,
        AppPalette.coralDeep.withValues(alpha: 0.10 + pulse * 0.12));
    _stroke(
      canvas,
      path,
      AppPalette.coralDeep.withValues(alpha: 0.35 + pulse * 0.3),
      1.2,
    );
  }

  void _drawFloorCrack(Canvas canvas, int c, int r) {
    final path = _tilePath(c.toDouble(), r.toDouble(), c + 1.0, r + 1.0, 0);
    canvas.save();
    canvas.clipPath(path);
    final start = _p(c + 0.2, r + 0.35);
    final mid = _p(c + 0.5, r + 0.55);
    final end = _p(c + 0.82, r + 0.62);
    final crack = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(mid.dx - 3, mid.dy + 3)
      ..lineTo(mid.dx + 2, mid.dy + 6)
      ..lineTo(end.dx, end.dy);
    _stroke(canvas, crack, const Color(0x663A2A20), 1.0);
    canvas.restore();
  }

  // ── DINDING ────────────────────────────────────────────────────
  /// Dinding rendah untuk sisi dekat kamera (cutaway diorama).
  void _drawLowWall(Canvas canvas, int c, int r) {
    const double h = 9.0;
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      0,
      h,
      top: const Color(0xFFEADFC7),
      left: const Color(0xFFFBF5E7),
      right: const Color(0xFFEDE1CB),
      stroke: const Color(0x226B5A3A),
      strokeWidth: 0.6,
    );

    // Skirting kayu + garis tepi atas.
    _fill(canvas, _quadL(c, r, 0, 1, 3.2, 5.4), const Color(0xFFCBA36A));
    _fill(canvas, _quadR(c, r, 0, 1, 3.2, 5.4), const Color(0xFFB78C55));
    _fill(canvas, _quadL(c, r, 0, 1, h - 2, h), const Color(0xFFF7EEDC));
    _fill(canvas, _quadR(c, r, 0, 1, h - 2, h), const Color(0xFFE6D9BF));
  }

  void _drawWall(Canvas canvas, int c, int r) {
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      0,
      wallH,
      top: const Color(0xFFF0E6D2),
      left: const Color(0xFFF8F2E4),
      right: const Color(0xFFE7DDC9),
      stroke: const Color(0x1A6B5A3A),
    );

    // Panel bawah (warna sekolah) + skirting kayu.
    _fill(canvas, _quadL(c, r, 0, 1, 3.5, 13), const Color(0xFFCFEAF6));
    _fill(canvas, _quadR(c, r, 0, 1, 3.5, 13), const Color(0xFFB9DEEF));
    _fill(canvas, _quadL(c, r, 0, 1, 0, 3.5), const Color(0xFFCBA36A));
    _fill(canvas, _quadR(c, r, 0, 1, 0, 3.5), const Color(0xFFB78C55));

    // Garis tepi atas dinding.
    _fill(
      canvas,
      _quadL(c, r, 0, 1, wallH - 3, wallH),
      const Color(0xFFF1E7D2),
    );
    _fill(
      canvas,
      _quadR(c, r, 0, 1, wallH - 3, wallH),
      const Color(0xFFE0D3B8),
    );

    _wallDecor(canvas, c, r);
  }

  bool _isTallWallAt(int c, int r) {
    if (c < 0 || r < 0 || r >= map.length || c >= map[0].length) {
      return false;
    }
    final t = map[r][c];
    if (t == 'K' || t == 'D') return true;
    if (t != '#') return false;
    return !_isNearWall(c, r);
  }

  void _wallDecor(Canvas canvas, int c, int r) {
    // Hiasan hanya di dinding yang menghadap ke dalam ruangan.
    // Dinding kiri menghadap keluar, sedangkan dinding yang di depannya
    // masih ada dinding tinggi akan tertutup atapnya (jam bisa terpotong).
    final facesRoom = r == 0 || c == map[0].length - 1;
    if (!facesRoom) return;
    if (_isTallWallAt(c, r + 1) || _isTallWallAt(c + 1, r + 1)) return;

    final kind = _hash(c, r) % 9;
    if (kind == 0) {
      _drawWhiteboard(canvas, c, r);
    } else if (kind == 2) {
      _drawPoster(canvas, c, r);
    } else if (kind == 4) {
      _drawClock(canvas, c, r);
    } else if (kind == 6) {
      _drawShelf(canvas, c, r);
    }
  }

  void _drawWhiteboard(Canvas canvas, int c, int r) {
    _fill(
      canvas,
      _quadL(c, r, 0.10, 0.90, 15, wallH - 8),
      const Color(0xFFD5DFE4),
    );
    _fill(
      canvas,
      _quadL(c, r, 0.13, 0.87, 16.5, wallH - 9.5),
      const Color(0xFFFFFFFF),
    );
    // Tulisan spidol.
    final colors = [
      AppPalette.skyDeep,
      AppPalette.coralDeep,
      AppPalette.mintDeep
    ];
    for (int i = 0; i < 3; i++) {
      final z = 27.0 - i * 4.2;
      canvas.drawLine(
        _faceL(c, r, 0.18 + i * 0.05, z),
        _faceL(c, r, 0.45 + i * 0.12, z),
        Paint()
          ..color = colors[i].withValues(alpha: 0.75)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }
    // Baki spidol.
    _fill(
      canvas,
      _quadL(c, r, 0.12, 0.88, 13.6, 15),
      const Color(0xFFC7D1D6),
    );
  }

  void _drawPoster(Canvas canvas, int c, int r) {
    final palette = [
      AppPalette.coral,
      AppPalette.sunny,
      AppPalette.mint,
      AppPalette.grape,
    ];
    final accent = palette[_hash(c, r) % palette.length];
    _fill(
      canvas,
      _quadL(c, r, 0.30, 0.70, 17, wallH - 9),
      const Color(0xFFFFFFFF),
    );
    _stroke(
      canvas,
      _quadL(c, r, 0.30, 0.70, 17, wallH - 9),
      accent,
      1.6,
    );
    _fill(
      canvas,
      _quadL(c, r, 0.34, 0.66, 20, 27),
      accent.withValues(alpha: 0.22),
    );
    // Bintang kecil di tengah poster.
    final center = _faceL(c, r, 0.5, 24.5);
    _star(canvas, center, 3.6, accent);
    // Dua garis teks.
    for (int i = 0; i < 2; i++) {
      canvas.drawLine(
        _faceL(c, r, 0.36, 20.5 - i * 2.4),
        _faceL(c, r, 0.64, 20.5 - i * 2.4),
        Paint()
          ..color = const Color(0x5531355A)
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawClock(Canvas canvas, int c, int r) {
    final center = _faceL(c, r, 0.5, wallH - 14);
    canvas.drawCircle(
      center,
      6.4,
      Paint()..color = const Color(0xFFF7FBFF),
    );
    canvas.drawCircle(
      center,
      6.4,
      Paint()
        ..color = AppPalette.navy.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(center, 1.1, Paint()..color = AppPalette.navy);
    canvas.drawLine(
      center,
      center + const Offset(0, -4),
      Paint()
        ..color = AppPalette.navy
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      center,
      center + const Offset(3, 1.5),
      Paint()
        ..color = AppPalette.coralDeep
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawShelf(Canvas canvas, int c, int r) {
    _fill(
      canvas,
      _quadL(c, r, 0.18, 0.82, 13, wallH - 12),
      const Color(0xFFC69C64),
    );
    _fill(
      canvas,
      _quadL(c, r, 0.21, 0.79, 13.5, wallH - 12.5),
      const Color(0xFFE7C68F),
    );
    for (int i = 0; i < 2; i++) {
      final z = 19.5 + i * 7.0;
      canvas.drawLine(
        _faceL(c, r, 0.21, z),
        _faceL(c, r, 0.79, z),
        Paint()
          ..color = const Color(0xFF8F6735)
          ..strokeWidth = 1.4,
      );
    }
    // Buku-buku warna.
    final bookColors = [
      AppPalette.coralDeep,
      AppPalette.skyDeep,
      AppPalette.mintDeep,
      AppPalette.sunnyDeep,
    ];
    for (int i = 0; i < 4; i++) {
      final u0 = 0.26 + i * 0.12;
      _fill(
        canvas,
        _quadL(c, r, u0, u0 + 0.07, 20 + (i % 2) * 6.5, 26 + (i % 2) * 6.5),
        bookColors[i].withValues(alpha: 0.9),
      );
    }
  }

  // ── JENDELA KACA ───────────────────────────────────────────────
  void _drawGlassWall(Canvas canvas, int c, int r) {
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      0,
      wallH,
      top: const Color(0xFFF0E6D2),
      left: const Color(0xFFF4EFE2),
      right: const Color(0xFFE5DBC7),
      stroke: const Color(0x1A6B5A3A),
    );
    _fill(canvas, _quadL(c, r, 0, 1, 0, 3.5), const Color(0xFFCBA36A));
    _fill(canvas, _quadR(c, r, 0, 1, 0, 3.5), const Color(0xFFB78C55));

    _drawWindowLeft(canvas, c, r);
    _drawWindowRight(canvas, c, r);
  }

  void _drawWindowLeft(Canvas canvas, int c, int r) {
    const u0 = 0.17, u1 = 0.83, z0 = 13.0, z1 = wallH - 7.0;
    _fill(
      canvas,
      _quadL(c, r, u0 - 0.05, u1 + 0.05, z0 - 3, z1 + 3),
      const Color(0xFFFFFBF1),
    );
    final glass = _quadL(c, r, u0, u1, z0, z1);
    final bounds = glass.getBounds();
    canvas.drawPath(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBDEBFC), Color(0xFF7FCDEE)],
        ).createShader(bounds),
    );

    canvas.save();
    canvas.clipPath(glass);
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final cloudCenter = _faceL(c, r, 0.36, z1 - 4);
    canvas.drawCircle(cloudCenter, 4.4, cloud);
    canvas.drawCircle(cloudCenter + const Offset(5, 1.2), 3.4, cloud);
    canvas.drawCircle(cloudCenter + const Offset(-5, 1.4), 3.0, cloud);
    canvas.drawCircle(
      _faceL(c, r, 0.72, z1 - 2),
      2.6,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.9),
    );
    canvas.restore();

    // Refleksi diagonal.
    canvas.drawLine(
      _faceL(c, r, 0.3, z0 + 3),
      _faceL(c, r, 0.45, z1 - 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      _faceL(c, r, 0.4, z0 + 3),
      _faceL(c, r, 0.55, z1 - 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.4,
    );

    // Palang jendela.
    final frame = Paint()
      ..color = const Color(0xFFFFFBF1)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      _faceL(c, r, 0.5, z0),
      _faceL(c, r, 0.5, z1),
      frame,
    );
    canvas.drawLine(
      _faceL(c, r, u0, (z0 + z1) / 2),
      _faceL(c, r, u1, (z0 + z1) / 2),
      frame,
    );

    // Kaca pecah saat gempa.
    if (quakeActive) {
      final crack = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round;
      final origin = _faceL(c, r, 0.54, (z0 + z1) / 2 + 1);
      for (final d in const [
        Offset(-7, 4),
        Offset(4, 7),
        Offset(8, -3),
        Offset(-4, -6),
      ]) {
        canvas.drawLine(origin, origin + d, crack);
        canvas.drawLine(
          origin + d,
          origin + d + Offset(d.dx * 0.4, d.dy * 0.35),
          crack,
        );
      }
    }

    // Ambang jendela.
    _fill(
      canvas,
      _quadL(c, r, u0 - 0.07, u1 + 0.07, z0 - 5.5, z0 - 2.5),
      const Color(0xFFE8D3AE),
    );
    _stroke(
      canvas,
      _quadL(c, r, u0 - 0.07, u1 + 0.07, z0 - 5.5, z0 - 2.5),
      const Color(0x33805F30),
      0.6,
    );

    // Gorden ceria.
    _fill(
      canvas,
      _quadL(c, r, u0 - 0.06, u0 + 0.03, z0 - 4, z1 + 3),
      AppPalette.coral.withValues(alpha: 0.85),
    );
    _fill(
      canvas,
      _quadL(c, r, u1 - 0.03, u1 + 0.06, z0 - 4, z1 + 3),
      AppPalette.coral.withValues(alpha: 0.85),
    );
    _fill(
      canvas,
      _quadL(c, r, u0 - 0.07, u1 + 0.07, z1 + 2, z1 + 4.5),
      AppPalette.coralDeep.withValues(alpha: 0.8),
    );
  }

  void _drawWindowRight(Canvas canvas, int c, int r) {
    const u0 = 0.22, u1 = 0.78, z0 = 14.0, z1 = wallH - 8.0;
    _fill(
      canvas,
      _quadR(c, r, u0 - 0.05, u1 + 0.05, z0 - 3, z1 + 3),
      const Color(0xFFF4EDDD),
    );
    final glass = _quadR(c, r, u0, u1, z0, z1);
    final bounds = glass.getBounds();
    canvas.drawPath(
      glass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF9ADCF7), Color(0xFF6FC6EE)],
        ).createShader(bounds),
    );
    final frame = Paint()
      ..color = const Color(0xFFF4EDDD)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      _faceR(c, r, 0.5, z0),
      _faceR(c, r, 0.5, z1),
      frame,
    );
    canvas.drawLine(
      _faceR(c, r, u0, (z0 + z1) / 2),
      _faceR(c, r, u1, (z0 + z1) / 2),
      frame,
    );
    canvas.drawLine(
      _faceR(c, r, u0 + 0.1, z0 + 3),
      _faceR(c, r, u0 + 0.3, z1 - 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.8,
    );
    if (quakeActive) {
      final crack = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 0.8;
      final origin = _faceR(c, r, 0.5, (z0 + z1) / 2);
      canvas.drawLine(origin, origin + const Offset(-6, 5), crack);
      canvas.drawLine(origin, origin + const Offset(6, 4), crack);
      canvas.drawLine(origin, origin + const Offset(1, -7), crack);
    }
    _fill(
      canvas,
      _quadR(c, r, u0 - 0.07, u1 + 0.07, z0 - 5, z0 - 2.5),
      const Color(0xFFDCC7A0),
    );
  }

  // ── PINTU ──────────────────────────────────────────────────────
  void _drawDoor(Canvas canvas, int c, int r) {
    final isExit = _isExitDoor(c, r);
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      0,
      wallH,
      top: const Color(0xFFF0E6D2),
      left: const Color(0xFFF6F0E2),
      right: const Color(0xFFE4DAC6),
      stroke: const Color(0x1A6B5A3A),
    );
    _fill(canvas, _quadL(c, r, 0, 1, 0, 3.5), const Color(0xFFCBA36A));
    _fill(canvas, _quadR(c, r, 0, 1, 0, 3.5), const Color(0xFFB78C55));

    final doorColor = isExit ? AppPalette.mintDeep : const Color(0xFFC98A4B);
    final doorDark = isExit ? const Color(0xFF2E9E6F) : const Color(0xFF9C632D);

    // Kusen pintu.
    _fill(
      canvas,
      _quadL(c, r, 0.24, 0.80, 0, wallH - 4),
      const Color(0xFFFFFBF1),
    );
    // Daun pintu.
    _fill(canvas, _quadL(c, r, 0.28, 0.76, 1.5, wallH - 6), doorColor);
    // Panel pintu.
    _fill(canvas, _quadL(c, r, 0.32, 0.72, 12, wallH - 13), doorDark);
    _fill(canvas, _quadL(c, r, 0.34, 0.70, 13, wallH - 14), doorColor);
    _fill(canvas, _quadL(c, r, 0.32, 0.72, 4, 10), doorDark);
    _fill(canvas, _quadL(c, r, 0.34, 0.70, 4.8, 9.2), doorColor);

    // Gagang pintu.
    final knob = _faceL(c, r, 0.70, 11.5);
    canvas.drawCircle(knob, 1.7, Paint()..color = const Color(0xFFFFD97A));
    canvas.drawCircle(
      knob,
      1.7,
      Paint()
        ..color = const Color(0xFF9C7A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    if (isExit) {
      // Panah keluar di daun pintu.
      final arrowColor = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 2; i++) {
        final x = 0.40 + i * 0.12;
        final a = _faceL(c, r, x, 17);
        final b = _faceL(c, r, x + 0.10, 20);
        final d = _faceL(c, r, x, 23);
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy)
            ..lineTo(d.dx, d.dy),
          arrowColor,
        );
      }
      // Cahaya hijau di lantai depan pintu.
      final glowCenter = _p(c + 0.5, r + 1.05, 0);
      canvas.drawOval(
        Rect.fromCenter(center: glowCenter, width: 30, height: 13),
        Paint()
          ..color = AppPalette.mint.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  // ── RUMPUT & TITIK KUMPUL ──────────────────────────────────────
  void _drawGrass(Canvas canvas, int c, int r) {
    final even = (c + r) % 2 == 0;
    _box(
      canvas,
      c.toDouble(),
      r.toDouble(),
      c + 1,
      r + 1,
      -floorLip,
      floorLip,
      top: even ? const Color(0xFF93DD97) : const Color(0xFF86D58B),
      left: const Color(0xFF5C9A4F),
      right: const Color(0xFF6DB25E),
      stroke: const Color(0x1A2F5A2A),
    );

    final h = _hash(c, r);
    final flowerColors = [
      Colors.white,
      AppPalette.sunny,
      AppPalette.coral,
      AppPalette.grape,
    ];
    for (int i = 0; i < 3; i++) {
      final gx = c + 0.2 + ((h >> (i * 3)) % 60) / 100.0;
      final gy = r + 0.2 + ((h >> (i * 5 + 1)) % 60) / 100.0;
      final p = _p(gx, gy, 1);
      final color = flowerColors[(h + i) % flowerColors.length];
      canvas.drawCircle(p, 1.5, Paint()..color = color);
      canvas.drawCircle(p, 0.6, Paint()..color = AppPalette.sunnyDeep);
    }

    // Beberapa helai rumput.
    final blade = Paint()
      ..color = const Color(0xFF4E8D45).withValues(alpha: 0.6)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 2; i++) {
      final p = _p(c + 0.3 + i * 0.35, r + 0.7, 1);
      canvas.drawLine(p, p + const Offset(-1, -3.5), blade);
      canvas.drawLine(p, p + const Offset(1.5, -2.5), blade);
    }
  }

  void _drawAssemblyPoint(Canvas canvas, int c, int r) {
    final center = _p(c + 0.5, r + 0.5, 0.5);
    // Target merah-putih di lantai.
    final rings = [
      (30.0, 15.0, AppPalette.coralDeep),
      (22.0, 11.0, Colors.white),
      (14.0, 7.0, AppPalette.coralDeep),
      (7.0, 3.5, Colors.white),
    ];
    for (final ring in rings) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: ring.$1,
          height: ring.$2,
        ),
        Paint()
          ..color = ring.$3
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 30, height: 15),
      Paint()
        ..color = AppPalette.navy.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Tiang bendera.
    final poleBase = _p(c + 0.22, r + 0.28, 0);
    final poleTop = poleBase + const Offset(0, -34);
    canvas.drawLine(
      poleBase,
      poleTop,
      Paint()
        ..color = const Color(0xFF8E6A3F)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(poleBase, 2.2, Paint()..color = const Color(0xFF6B4A26));
    final wave = sin(animTime / 9.0) * 1.2;
    final flag = Path()
      ..moveTo(poleTop.dx, poleTop.dy)
      ..quadraticBezierTo(
        poleTop.dx + 10,
        poleTop.dy + 1 + wave,
        poleTop.dx + 17,
        poleTop.dy + 4 + wave,
      )
      ..quadraticBezierTo(
        poleTop.dx + 9,
        poleTop.dy + 8,
        poleTop.dx,
        poleTop.dy + 9,
      )
      ..close();
    _fill(canvas, flag, AppPalette.coralDeep);
    _star(
      canvas,
      Offset(poleTop.dx + 7, poleTop.dy + 4.5),
      2.6,
      Colors.white,
    );
  }

  void _star(Canvas canvas, Offset center, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final angle = (i * 36 - 90) * pi / 180;
      final p = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    _fill(canvas, path, color);
  }

  // ── MEJA & KURSI ───────────────────────────────────────────────
  void _drawDesk(
    Canvas canvas,
    int c,
    int r, {
    bool shadow = true,
    bool chair = true,
  }) {
    final wob = _wob(c, r);
    canvas.save();
    canvas.translate(wob, 0);

    if (shadow) _floorShadow(canvas, c, r, 36, 14);

    // Kursi di belakang meja.
    if (chair) _drawChair(canvas, c, r);

    const legColor = Color(0xFF5A6E8A);
    const legDark = Color(0xFF40526B);

    // Kaki meja.
    for (final corner in const [
      (0.13, 0.13),
      (0.87, 0.13),
      (0.13, 0.87),
      (0.87, 0.87),
    ]) {
      final x = c + corner.$1;
      final y = r + corner.$2;
      final base = _p(x, y, 0);
      canvas.drawLine(
        base,
        base - const Offset(0, 12.5),
        Paint()
          ..color = corner.$2 > 0.5 ? legColor : legDark
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Palang penguat.
    final barA = _p(c + 0.14, r + 0.86, 5.5);
    final barB = _p(c + 0.86, r + 0.86, 5.5);
    canvas.drawLine(
      barA,
      barB,
      Paint()
        ..color = const Color(0xFF465A74)
        ..strokeWidth = 1.3,
    );

    // Daun meja tebal.
    _box(
      canvas,
      c + 0.07,
      r + 0.07,
      c + 0.93,
      r + 0.93,
      12.5,
      3.4,
      top: const Color(0xFFF0AE63),
      left: const Color(0xFFD58C42),
      right: const Color(0xFFB96F2E),
      stroke: const Color(0x662A1708),
      strokeWidth: 0.7,
    );

    // Panel depan meja (menutupi kaki).
    _fill(
      canvas,
      _quadL(c, r, 0.16, 0.84, 4.5, 12.5),
      const Color(0xFFE0A05C),
    );
    _fill(
      canvas,
      _quadL(c, r, 0.19, 0.81, 5.5, 11.5),
      const Color(0xFFEFB471),
    );

    // Buku & pensil di atas meja.
    _box(
      canvas,
      c + 0.18,
      r + 0.58,
      c + 0.34,
      r + 0.76,
      16,
      2.3,
      top: const Color(0xFF2F7DC4),
      left: const Color(0xFF1F5C93),
      right: const Color(0xFF275F8E),
      stroke: const Color(0x332A1708),
      strokeWidth: 0.4,
    );
    _box(
      canvas,
      c + 0.21,
      r + 0.60,
      c + 0.37,
      r + 0.78,
      18.3,
      2.0,
      top: const Color(0xFFFFF8EC),
      left: const Color(0xFFEADFC8),
      right: const Color(0xFFF3E9D6),
      stroke: const Color(0x332A1708),
      strokeWidth: 0.4,
    );
    final pencilA = _p(c + 0.58, r + 0.28, 16.6);
    final pencilB = _p(c + 0.78, r + 0.40, 16.6);
    canvas.drawLine(
      pencilA,
      pencilB,
      Paint()
        ..color = AppPalette.sunnyDeep
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      pencilB,
      pencilB + const Offset(2.5, 1.4),
      Paint()
        ..color = const Color(0xFF3A2A20)
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round,
    );

    // Penanda zona aman.
    _drawSafeMarker(canvas, c, r);

    canvas.restore();
  }

  void _drawChair(Canvas canvas, int c, int r) {
    // Kursi di sisi belakang meja (menghadap meja).
    _box(
      canvas,
      c + 0.36,
      r + 0.04,
      c + 0.72,
      r + 0.24,
      8.5,
      2.2,
      top: const Color(0xFF7FE0B4),
      left: const Color(0xFF46B98A),
      right: const Color(0xFF5BCB98),
      stroke: const Color(0x332A1708),
      strokeWidth: 0.5,
    );
    _box(
      canvas,
      c + 0.36,
      r + 0.04,
      c + 0.72,
      r + 0.10,
      10.7,
      10.5,
      top: const Color(0xFF83E3B7),
      left: const Color(0xFF4DBA8C),
      right: const Color(0xFF62CC9A),
      stroke: const Color(0x332A1708),
      strokeWidth: 0.5,
    );
    // Kaki kursi.
    for (final x in const [0.40, 0.68]) {
      final base = _p(c + x, r + 0.20, 0);
      canvas.drawLine(
        base,
        base - const Offset(0, 8.5),
        Paint()
          ..color = const Color(0xFF4A5C78)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawSafeMarker(Canvas canvas, int c, int r) {
    final center = _p(c + 0.5, r + 0.5, 0);
    final pulse = (sin(animTime / 4.5) * 0.5 + 0.5).clamp(0.0, 1.0);

    if (!quakeActive) {
      // Penanda kecil di atas meja (tidak menutupi ruangan).
      final marker = _p(c + 0.5, r + 0.5, 18);
      canvas.drawCircle(marker, 3.6, Paint()..color = Colors.white);
      canvas.drawCircle(
        marker,
        3.6,
        Paint()
          ..color = AppPalette.mintDeep
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(marker, 1.6, Paint()..color = AppPalette.mintDeep);
      return;
    }

    // Aura hijau berdenyut di lantai.
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 34 + pulse * 8,
        height: 17 + pulse * 4,
      ),
      Paint()
        ..color = AppPalette.mint.withValues(alpha: 0.20 + pulse * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 30, height: 15),
      Paint()
        ..color = AppPalette.mintDeep.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Hanya meja terdekat yang diberi label agar layar tidak penuh tulisan.
    final playerCol = px / 27.0;
    final playerRow = py / 27.0;
    int? nearestC;
    int? nearestR;
    var best = double.infinity;
    for (int rr = 0; rr < map.length; rr++) {
      for (int cc = 0; cc < map[0].length; cc++) {
        if (map[rr][cc] != 'M') continue;
        final dc = playerCol - (cc + 0.5);
        final dr = playerRow - (rr + 0.5);
        final d = dc * dc + dr * dr;
        if (d < best) {
          best = d;
          nearestC = cc;
          nearestR = rr;
        }
      }
    }
    if (nearestC != c || nearestR != r) return;

    final bob = sin(animTime / 8.0) * 1.5;
    final labelPos = _p(c + 0.5, r + 0.5, 47) + Offset(0, bob);
    _pillLabel(
      canvas,
      labelPos,
      'COVER DI SINI',
      AppPalette.mintDeep,
      fontSize: 6.8,
      showPointer: true,
    );
  }

  // ── LABEL MELAYANG ─────────────────────────────────────────────
  void _pillLabel(
    Canvas canvas,
    Offset center,
    String text,
    Color bg, {
    double fontSize = 7.5,
    bool showPointer = false,
    Color fg = Colors.white,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = Rect.fromCenter(
      center: center,
      width: tp.width + 12,
      height: tp.height + 7,
    );
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));

    canvas.drawRRect(
      rrect.shift(const Offset(0, 2)),
      Paint()..color = const Color(0x33231A12),
    );
    canvas.drawRRect(rrect, Paint()..color = bg);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    if (showPointer) {
      final arrow = Path()
        ..moveTo(center.dx - 3, rect.bottom)
        ..lineTo(center.dx + 3, rect.bottom)
        ..lineTo(center.dx, rect.bottom + 4)
        ..close();
      _fill(canvas, arrow, bg);
    }
  }

  // ── PAPAN PENUNJUK ─────────────────────────────────────────────
  void _drawSigns(Canvas canvas) {
    final bob = sin(animTime / 10.0) * 1.2;
    for (int r = 0; r < map.length; r++) {
      for (int c = 0; c < map[0].length; c++) {
        if (_isExitDoor(c, r)) {
          final o = _p(c + 0.5, r + 0.55, wallH + 12);
          _pillLabel(
            canvas,
            o + Offset(0, bob),
            'KELUAR',
            AppPalette.mintDeep,
            fontSize: 7.4,
            showPointer: true,
          );
        } else if (map[r][c] == 'X') {
          final o = _p(c + 0.5, r + 0.5, 52);
          _pillLabel(
            canvas,
            o + Offset(0, bob),
            'TITIK KUMPUL',
            AppPalette.coralDeep,
            fontSize: 7.4,
            showPointer: true,
          );
        }
      }
    }
  }

  // ── DEBU & CAHAYA ──────────────────────────────────────────────
  void _drawAmbient(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    for (int i = 0; i < 9; i++) {
      final t = animTime / 60.0 + i * 1.7;
      final gx = 0.6 + (sin(t * 0.7 + i) * 0.5 + 0.5) * (map[0].length - 1.2);
      final gy =
          0.6 + (cos(t * 0.5 + i * 1.3) * 0.5 + 0.5) * (map.length - 1.2);
      final p = _p(gx, gy, 24 + sin(t + i) * 8);
      canvas.drawCircle(p, 0.9 + (i % 3) * 0.35, paint);
    }
  }

  // ── PARTIKEL (pecahan kaca, debu) ──────────────────────────────
  void _drawParticles(Canvas canvas) {
    final paint = Paint();
    for (final p in particles) {
      final gx = p.x / 27.0;
      final gy = p.y / 27.0;
      final pos = _p(gx, gy, p.type == 'shard' ? 18 : 3);
      if (p.type == 'shard') {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(p.rot);
        paint.color = (p.x.toInt() % 3 == 0)
            ? const Color(0xFFBDEBFC)
            : const Color(0xFFFFFBF1);
        final shard = Path()
          ..moveTo(-2.4, -2)
          ..lineTo(2.6, -1)
          ..lineTo(1.2, 2.6)
          ..lineTo(-2, 1.4)
          ..close();
        canvas.drawPath(shard, paint);
        canvas.drawPath(
          shard,
          Paint()
            ..color = const Color(0x5531355A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.4,
        );
        canvas.restore();
      } else {
        paint.color = const Color(0xFF8C7A5E)
            .withValues(alpha: (p.life / 22.0 * 0.45).clamp(0.0, 1.0));
        canvas.drawCircle(pos, p.r, paint);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  KARAKTER SISWA — GAYA CHIBI LUCU
  // ══════════════════════════════════════════════════════════════
  void _drawPlayer(Canvas canvas) {
    final col = px / 27.0;
    final row = py / 27.0;
    final iso = _p(col + 0.5, row + 0.5, 0);
    final cx = iso.dx;
    final cy = iso.dy + 1;
    final sheltered = shelterStage != ShelterStage.none;

    canvas.save();
    canvas.translate(cx, cy);

    // Bayangan di lantai.
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 1.5),
        width: sheltered ? 20 : 16,
        height: sheltered ? 7 : 5.5,
      ),
      Paint()
        ..color = const Color(0x33120D08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );

    if (sheltered) {
      canvas.save();
      canvas.scale(0.78);
      _drawShelterPose(canvas);
      canvas.restore();
    } else {
      _drawStandPose(canvas);
    }
    canvas.restore();

    _drawStageBadge(
      canvas,
      cx,
      cy - (sheltered ? 38 : 49),
    );
  }

  void _drawStandPose(Canvas canvas) {
    final walkingCycle = walking ? sin(animTime / 3.4) : 0.0;
    final bob = walking
        ? (sin(animTime / 3.4).abs() * 1.6)
        : sin(animTime / 10.0) * 0.9;

    canvas.save();
    canvas.translate(0, -bob);

    const skin = Color(0xFFF6C9A0);
    const skinShade = Color(0xFFE0AF82);
    const pants = Color(0xFF3F5680);
    const pantsDark = Color(0xFF314464);
    const shirt = Color(0xFFFFFBF1);
    const hair = Color(0xFF38261F);

    // Kaki + sepatu.
    for (int side = 0; side < 2; side++) {
      final dir = side == 0 ? -1.0 : 1.0;
      final swing = walkingCycle * 2.2 * dir;
      final x = side == 0 ? -5.6 : 1.8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, -11 + swing, 4.2, 9.5),
          const Radius.circular(2),
        ),
        Paint()..color = pants,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 0.8, -3.2 + swing, 5.6, 3.4),
          const Radius.circular(1.5),
        ),
        Paint()..color = const Color(0xFF2B3550),
      );
    }

    // Tas ransel di belakang badan.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12.5, -27, 7.5, 13),
        const Radius.circular(3.2),
      ),
      Paint()..color = AppPalette.coralDeep,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12.0, -25.5, 6.5, 5.4),
        const Radius.circular(2.2),
      ),
      Paint()..color = AppPalette.coral,
    );

    // Badan / seragam putih.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8.2, -26, 16.4, 16.5),
        const Radius.circular(5),
      ),
      Paint()..color = shirt,
    );
    // Sisi badan berbayang.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.4, -26, 5.8, 16.5),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFEDE5D3),
    );
    // Dasai / dasi kecil.
    canvas.drawPath(
      Path()
        ..moveTo(-1.4, -26)
        ..lineTo(1.4, -26)
        ..lineTo(2.2, -21.5)
        ..lineTo(0, -19.5)
        ..lineTo(-2.2, -21.5)
        ..close(),
      Paint()..color = AppPalette.coralDeep,
    );
    // Kantong kecil.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.2, -18.5, 4.4, 3.0),
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFFE6DCC6),
    );

    // Lengan.
    for (int side = 0; side < 2; side++) {
      final x = side == 0 ? -11.0 : 7.4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, -25.5, 3.6, 11),
          const Radius.circular(1.8),
        ),
        Paint()..color = side == 0 ? shirt : const Color(0xFFEFE6D4),
      );
      canvas.drawCircle(
        Offset(x + 1.8, -14.2),
        2.2,
        Paint()..color = skin,
      );
    }

    // Leher.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2.2, -28.5, 4.4, 3.5),
        const Radius.circular(1.4),
      ),
      Paint()..color = skinShade,
    );

    // Kepala.
    const headCenter = Offset(0, -35);
    canvas.drawCircle(headCenter, 8.8, Paint()..color = skin);
    // Telinga.
    canvas.drawCircle(const Offset(-8.3, -34.6), 2.1, Paint()..color = skin);
    canvas.drawCircle(const Offset(8.3, -34.6), 2.1, Paint()..color = skin);

    // Rambut.
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: headCenter, radius: 9.1)));
    canvas.drawRect(
      const Rect.fromLTWH(-9.5, -45.5, 19, 9.5),
      Paint()..color = hair,
    );
    // Poni bergerigi.
    final fringe = Path()..moveTo(-9.5, -36.5);
    for (int i = 0; i < 6; i++) {
      fringe.lineTo(-9.5 + i * 3.2, -35.6);
      fringe.lineTo(-9.5 + i * 3.2 + 1.6, -38.4);
    }
    fringe
      ..lineTo(9.5, -36.5)
      ..lineTo(9.5, -45.5)
      ..lineTo(-9.5, -45.5)
      ..close();
    _fill(canvas, fringe, hair);
    canvas.restore();

    // Wajah (sembunyikan saat menghadap atas).
    if (facing != Facing.up) {
      final shiftX =
          facing == Facing.left ? -1.6 : (facing == Facing.right ? 1.6 : 0.0);
      final scared = quakeActive;

      // Mata putih.
      for (int side = 0; side < 2; side++) {
        final ex = side == 0 ? -3.6 : 3.6;
        canvas.save();
        if (facing == Facing.left || facing == Facing.right) {
          if ((facing == Facing.left && side == 1) ||
              (facing == Facing.right && side == 0)) {
            canvas.restore();
            continue;
          }
        }
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(ex + shiftX, -35.2),
            width: scared ? 4.6 : 3.8,
            height: scared ? 5.6 : 4.8,
          ),
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(ex + shiftX, -35.0),
          scared ? 2.1 : 1.8,
          Paint()..color = const Color(0xFF2B2D42),
        );
        canvas.drawCircle(
          Offset(ex + shiftX - 0.6, -35.7),
          0.6,
          Paint()..color = Colors.white,
        );
        canvas.restore();
      }

      // Pipi merona.
      final blush = Paint()..color = AppPalette.coral.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(-6.0 + shiftX, -31.6), 1.7, blush);
      canvas.drawCircle(Offset(6.0 + shiftX, -31.6), 1.7, blush);

      // Mulut.
      if (scared) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(shiftX, -30.4),
            width: 3.0,
            height: 3.8,
          ),
          Paint()..color = const Color(0xFF9E3A2C),
        );
        // Keringat.
        final sweat = Path()
          ..moveTo(8.4 + shiftX, -39.5)
          ..quadraticBezierTo(10.2 + shiftX, -37.2, 9.4 + shiftX, -36.2)
          ..quadraticBezierTo(7.8 + shiftX, -36.6, 8.4 + shiftX, -39.5)
          ..close();
        _fill(canvas, sweat, const Color(0xFF57C7F2));
      } else {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(shiftX, -31),
            width: 5.6,
            height: 4.2,
          ),
          0.15,
          pi - 0.3,
          false,
          Paint()
            ..color = const Color(0xFF8E4A38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    canvas.restore();
  }

  void _drawShelterPose(Canvas canvas) {
    final holdOn = shelterStage == ShelterStage.holdOn;
    final tremor = holdOn ? sin(animTime / 2.4) * 0.8 : 0.0;
    final duck = shelterStage == ShelterStage.drop ? 1.5 : 0.0;

    canvas.save();
    canvas.translate(tremor, duck);

    const skin = Color(0xFFF6C9A0);
    const pants = Color(0xFF3F5680);
    const shirt = Color(0xFFFFFBF1);
    const hair = Color(0xFF38261F);

    // Kaki terlipat.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9.5, -6.0, 8.0, 5.0),
        const Radius.circular(2.2),
      ),
      Paint()..color = pants,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1.5, -6.0, 8.0, 5.0),
        const Radius.circular(2.2),
      ),
      Paint()..color = pants,
    );
    // Sepatu.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-10.2, -2.4, 8.6, 3.0),
        const Radius.circular(1.4),
      ),
      Paint()..color = const Color(0xFF2B3550),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1.4, -2.4, 8.6, 3.0),
        const Radius.circular(1.4),
      ),
      Paint()..color = const Color(0xFF2B3550),
    );

    // Ransel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12.5, -19.5, 7.0, 11),
        const Radius.circular(3),
      ),
      Paint()..color = AppPalette.coralDeep,
    );

    // Badan membungkuk.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8.0, -19.0, 16.0, 13.5),
        const Radius.circular(5),
      ),
      Paint()..color = shirt,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1.8, -19.0, 6.2, 13.5),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFEDE5D3),
    );

    // Kepala menunduk.
    const headCenter = Offset(0, -25.5);
    canvas.drawCircle(headCenter, 7.6, Paint()..color = skin);
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: headCenter, radius: 7.9)),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-9, -34, 18, 8.2),
      Paint()..color = hair,
    );
    canvas.restore();

    // Mata terpejam + pipi.
    final eye = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: const Offset(-3.2, -25.0),
        width: 3.6,
        height: 3.0,
      ),
      0.15,
      pi - 0.3,
      false,
      eye,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: const Offset(3.2, -25.0),
        width: 3.6,
        height: 3.0,
      ),
      0.15,
      pi - 0.3,
      false,
      eye,
    );
    final blush = Paint()..color = AppPalette.coral.withValues(alpha: 0.5);
    canvas.drawCircle(const Offset(-5.2, -22.3), 1.5, blush);
    canvas.drawCircle(const Offset(5.2, -22.3), 1.5, blush);

    // Lengan melindungi kepala.
    final arm = Paint()
      ..color = skin
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    if (holdOn) {
      // Tangan memegang kaki meja.
      canvas.drawLine(const Offset(-6.5, -17), const Offset(-10.5, -10), arm);
      canvas.drawLine(const Offset(6.5, -17), const Offset(10.5, -10), arm);
    } else {
      // Tangan menyilang menutupi kepala.
      canvas.drawLine(const Offset(-7.0, -18), const Offset(-3.4, -30), arm);
      canvas.drawLine(const Offset(7.0, -18), const Offset(3.4, -30), arm);
      // Telapak tangan.
      canvas.drawCircle(const Offset(-3.2, -30.2), 2.0, Paint()..color = skin);
      canvas.drawCircle(const Offset(3.2, -30.2), 2.0, Paint()..color = skin);
    }

    // Aura pelindung saat HOLD ON.
    if (holdOn) {
      final pulse = (sin(animTime / 4.0) * 0.5 + 0.5).clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(0, -17), radius: 15 + pulse * 1.5),
        pi * 0.82,
        pi * 1.36,
        false,
        Paint()
          ..color = AppPalette.mintDeep.withValues(alpha: 0.45 + pulse * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  void _drawStageBadge(Canvas canvas, double cx, double cy) {
    if (shelterStage == ShelterStage.none) return;

    String label;
    Color color;
    switch (shelterStage) {
      case ShelterStage.drop:
        label = '1';
        color = AppPalette.coralDeep;
        break;
      case ShelterStage.cover:
        label = '2';
        color = AppPalette.sunnyDeep;
        break;
      case ShelterStage.holdOn:
        label = '3';
        color = AppPalette.mintDeep;
        break;
      case ShelterStage.none:
        return;
    }

    final bob = sin(animTime / 7.0) * 1.2;
    final center = Offset(cx, cy + bob);

    canvas.drawCircle(
      center + const Offset(0, 1),
      7.2,
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawCircle(center, 7.0, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5.6, Paint()..color = color);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  // ── Helper peta ────────────────────────────────────────────────
  bool _isNearGlass(int c, int r) {
    if (map[r][c] == 'K') return true;
    for (final n in const [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ]) {
      final nc = c + n[0];
      final nr = r + n[1];
      if (nc >= 0 &&
          nc < map[0].length &&
          nr >= 0 &&
          nr < map.length &&
          map[nr][nc] == 'K') {
        return true;
      }
    }
    return false;
  }

  bool _isExitDoor(int c, int r) {
    if (map[r][c] != 'D') return false;
    for (final n in const [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ]) {
      final nc = c + n[0];
      final nr = r + n[1];
      if (nc >= 0 &&
          nc < map[0].length &&
          nr >= 0 &&
          nr < map.length &&
          map[nr][nc] == 'G') {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(covariant _GameCanvasPainter oldDelegate) => true;
}

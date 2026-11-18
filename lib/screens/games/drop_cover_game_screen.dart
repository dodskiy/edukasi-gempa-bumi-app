import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/user_progress_manager.dart';
import '../../widgets/turtle_painter.dart';

class DropCoverGameScreen extends StatefulWidget {
  const DropCoverGameScreen({super.key});

  @override
  State<DropCoverGameScreen> createState() => _DropCoverGameScreenState();
}

class _DropCoverQuestion {
  final String tag;
  final String text;
  final List<_DropCoverOption> options;
  final String goodMsg;
  final String badMsg;

  const _DropCoverQuestion({
    required this.tag,
    required this.text,
    required this.options,
    required this.goodMsg,
    required this.badMsg,
  });
}

class _DropCoverOption {
  final String text;
  final bool isCorrect;

  const _DropCoverOption({
    required this.text,
    required this.isCorrect,
  });
}

/// Gaya visual untuk setiap tahap belajar. Dipakai agar anak langsung
/// mengenali warna tiap langkah: biru untuk DROP, hijau untuk COVER,
/// kuning untuk HOLD ON, ungu untuk urutan, dan coral untuk skenario.
class _SceneStyle {
  final String title;
  final IconData icon;
  final Color color;
  final Color deep;
  final Color soft;

  const _SceneStyle({
    required this.title,
    required this.icon,
    required this.color,
    required this.deep,
    required this.soft,
  });
}

class _DropCoverGameScreenState extends State<DropCoverGameScreen> {
  static const Color sky = Color(0xFF6FC6EE);
  static const Color skyDeep = Color(0xFF3FA8DA);
  static const Color skyMist = Color(0xFFE9F9FF);
  static const Color sunny = Color(0xFFFFC94D);
  static const Color sunnyDeep = Color(0xFFF2A70B);
  static const Color sunnySoft = Color(0xFFFFF6E0);
  static const Color coral = Color(0xFFFF8B7A);
  static const Color coralDeep = Color(0xFFF16249);
  static const Color coralSoft = Color(0xFFFFEDEB);
  static const Color mint = Color(0xFF6FDBA8);
  static const Color mintDeep = Color(0xFF3DBE85);
  static const Color mintSoft = Color(0xFFE7FBEF);
  static const Color grape = Color(0xFFB39DFF);
  static const Color grapeDeep = Color(0xFF7048C4);
  static const Color grapeSoft = Color(0xFFF0EAFE);
  static const Color cream = Color(0xFFFFFBF1);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF31355A);
  static const Color inkSoft = Color(0xFF8385A3);
  static const Color lineBorder = Color(0xFFF2ECDA);
  static const Color shadow3D = Color(0xFFE9E2CE);

  static const _SceneStyle _dropStyle = _SceneStyle(
    title: 'Merunduk ke Bawah',
    icon: Icons.arrow_downward_rounded,
    color: sky,
    deep: skyDeep,
    soft: skyMist,
  );

  static const _SceneStyle _coverStyle = _SceneStyle(
    title: 'Berlindung di Bawah Meja',
    icon: Icons.table_bar_rounded,
    color: mint,
    deep: mintDeep,
    soft: mintSoft,
  );

  static const _SceneStyle _holdStyle = _SceneStyle(
    title: 'Berpegangan Sampai Aman',
    icon: Icons.back_hand_rounded,
    color: sunny,
    deep: sunnyDeep,
    soft: sunnySoft,
  );

  static const _SceneStyle _orderStyle = _SceneStyle(
    title: 'Urutan Tiga Langkah',
    icon: Icons.format_list_numbered_rounded,
    color: grape,
    deep: grapeDeep,
    soft: grapeSoft,
  );

  static const _SceneStyle _scenarioStyle = _SceneStyle(
    title: 'Tetap Tenang dan Lindungi Diri',
    icon: Icons.explore_rounded,
    color: coral,
    deep: coralDeep,
    soft: coralSoft,
  );

  // Soal disusun bertahap: mengenal arti DROP, COVER, HOLD ON satu per satu,
  // lalu urutan, baru masuk ke skenario penerapan yang lebih ringan.
  final List<_DropCoverQuestion> _questions = const [
    _DropCoverQuestion(
      tag: 'AYO BELAJAR · DROP',
      text:
          'DROP artinya MERUNDUK. Saat gempa terjadi, apa yang harus segera kita lakukan dengan badan kita?',
      options: [
        _DropCoverOption(
          text: 'Segera merunduk dan jatuhkan badan ke bawah, jangan berdiri.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Tetap berdiri tegak seperti biasa.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'Melompat-lompat kegirangan.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Betul! DROP berarti merunduk. Badan kita jadi rendah dan tidak mudah jatuh.',
      badMsg:
          'Belum tepat. Ingat ya, DROP artinya kita segera merunduk ke bawah.',
    ),
    _DropCoverQuestion(
      tag: 'AYO BELAJAR · COVER',
      text:
          'Setelah merunduk, langkah selanjutnya adalah COVER, artinya BERLINDUNG. Ke mana kita berlindung supaya aman dari benda jatuh?',
      options: [
        _DropCoverOption(
          text: 'Berlindung di dekat jendela kaca yang besar.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'Berlindung di bawah meja yang kuat dan kokoh.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Berlindung sambil lari-lari keliling ruangan.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Tepat sekali! COVER berarti berlindung di bawah meja yang kuat.',
      badMsg:
          'Belum tepat. COVER artinya berlindung di bawah meja yang kokoh, bukan dekat kaca.',
    ),
    _DropCoverQuestion(
      tag: 'AYO BELAJAR · HOLD ON',
      text:
          'Langkah terakhir adalah HOLD ON, artinya BERPEGANGAN ERAT. Sambil berlindung di bawah meja, apa yang kita pegang, dan sampai kapan kita bertahan?',
      options: [
        _DropCoverOption(
          text:
              'Pegang kaki meja erat-erat sampai getaran benar-benar berhenti.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Pegang gawai untuk main game sebentar.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'Langsung berdiri dan berlari begitu badan mulai merunduk.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Hebat! HOLD ON berarti berpegangan erat dan bertahan sampai gempa berhenti.',
      badMsg:
          'Belum tepat. HOLD ON artinya berpegangan erat pada meja sampai getaran reda.',
    ),
    _DropCoverQuestion(
      tag: 'AYO URUTKAN',
      text:
          'Coba ingat lagi. Apa urutan yang BENAR dari tiga langkah menyelamatkan diri saat gempa?',
      options: [
        _DropCoverOption(
          text: 'DROP (merunduk) → COVER (berlindung) → HOLD ON (berpegangan)',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'COVER (berlindung) → HOLD ON (berpegangan) → DROP (merunduk)',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'HOLD ON (berpegangan) → DROP (merunduk) → COVER (berlindung)',
          isCorrect: false,
        ),
      ],
      goodMsg: 'Benar sekali! Urutannya selalu DROP → COVER → HOLD ON.',
      badMsg:
          'Belum tepat. Urutan yang benar adalah DROP dulu, baru COVER, lalu HOLD ON.',
    ),
    _DropCoverQuestion(
      tag: 'DI RUANG KELAS',
      text:
          'Alarm gempa berbunyi! Meja dan kursi di kelas mulai bergoyang. Apa yang harus kamu lakukan?',
      options: [
        _DropCoverOption(
          text: 'Merunduk di bawah meja, pegang kaki meja erat-erat.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Lari mendekati jendela kaca untuk melihat keluar.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'Berdiri di atas kursi sambil berteriak.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Betul! Merunduk, berlindung di bawah meja, lalu berpegangan erat.',
      badMsg:
          'Belum tepat. Ingat langkahnya: merunduk, berlindung di bawah meja, lalu berpegangan.',
    ),
    _DropCoverQuestion(
      tag: 'DI KAMAR RUMAH',
      text:
          'Kamu sedang bermain di kamar. Tiba-tiba lantai bergetar dan lampu bergoyang. Apa langkah amanmu?',
      options: [
        _DropCoverOption(
          text: 'Lari turun tangga secepat-cepatnya sambil panik.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text:
              'Merunduk di samping tempat tidur, lindungi kepala dengan bantal.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Bersembunyi di balik pintu lemari kaca.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Tepat! Berlindung dekat perabot kokoh lebih aman daripada berlari.',
      badMsg:
          'Belum tepat. Berlari saat gempa mudah membuat kita jatuh, dan kaca bisa pecah.',
    ),
    _DropCoverQuestion(
      tag: 'DI DALAM MAL',
      text:
          'Kamu sedang jalan-jalan di mal bersama keluarga. Rak barang mulai bergoyang karena gempa. Apa yang kamu lakukan?',
      options: [
        _DropCoverOption(
          text: 'Naik lift supaya cepat sampai lantai dasar.',
          isCorrect: false,
        ),
        _DropCoverOption(
          text: 'Menjauh dari rak tinggi, merunduk, dan lindungi kepala.',
          isCorrect: true,
        ),
        _DropCoverOption(
          text: 'Berlari ke pintu kaca sambil mendorong orang lain.',
          isCorrect: false,
        ),
      ],
      goodMsg:
          'Keren! Menjauh dari rak lalu merunduk adalah langkah paling aman.',
      badMsg:
          'Belum tepat. Lift bisa macet saat gempa, dan mendorong orang lain berbahaya.',
    ),
  ];

  int _currentIndex = 0;
  int _score = 0;
  int _timer = 9;
  Timer? _timerInterval;
  bool _answered = false;
  int _selectedOptionIdx = -1;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion(0);
  }

  @override
  void dispose() {
    _timerInterval?.cancel();
    super.dispose();
  }

  _SceneStyle _styleFor(int index) {
    switch (index) {
      case 0:
        return _dropStyle;
      case 1:
        return _coverStyle;
      case 2:
        return _holdStyle;
      case 3:
        return _orderStyle;
      default:
        return _scenarioStyle;
    }
  }

  void _startTimer() {
    _timerInterval?.cancel();
    setState(() {
      _timer = 9;
    });
    _timerInterval = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 1 && !_answered) {
        setState(() {
          _timer--;
        });
      } else if (_timer <= 1 && !_answered) {
        timer.cancel();
        setState(() {
          _timer = 0;
        });
        _lockOptions(-1);
      }
    });
  }

  void _loadQuestion(int idx) {
    setState(() {
      _currentIndex = idx;
      _answered = false;
      _selectedOptionIdx = -1;
    });
    _startTimer();
  }

  void _lockOptions(int selectedIdx) {
    _timerInterval?.cancel();
    final q = _questions[_currentIndex];
    final bool isCorrect =
        selectedIdx != -1 && q.options[selectedIdx].isCorrect;

    setState(() {
      _answered = true;
      _selectedOptionIdx = selectedIdx;
      if (isCorrect) {
        _score++;
      }
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _onOptionTapped(int idx) {
    if (_answered) return;
    _lockOptions(idx);
  }

  void _onNextTapped() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _questions.length - 1) {
      _loadQuestion(_currentIndex + 1);
    } else {
      _timerInterval?.cancel();
      UserProgressManager().recordDropCoverResult(_score);
      setState(() {
        _isFinished = true;
      });
    }
  }

  void _restartGame() {
    HapticFeedback.lightImpact();
    setState(() {
      _score = 0;
      _currentIndex = 0;
      _isFinished = false;
    });
    _loadQuestion(0);
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
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                    child: _isFinished
                        ? _buildFinishScreen()
                        : _buildQuizContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [sky, skyDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3331355A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuis Drop, Cover & Hold On',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'LATIHAN REFLEKS GEMPA BARENG KURA SIAGA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFFE6F8FF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: sunny, size: 15),
                const SizedBox(width: 2),
                Text(
                  '${_score * 10}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= QUIZ CONTENT =================
  Widget _buildQuizContent() {
    final q = _questions[_currentIndex];
    final style = _styleFor(_currentIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        _buildStatusStrip(),
        const SizedBox(height: 14),
        _buildSceneCard(q, style),
        const SizedBox(height: 20),
        const Text(
          'Pilih tindakan paling aman',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Ketuk salah satu jawaban di bawah ini.',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: inkSoft,
          ),
        ),
        const SizedBox(height: 11),
        ...q.options.asMap().entries.map((entry) {
          return _buildOptionButton(entry.key, entry.value, style);
        }),
        if (_answered) ...[
          const SizedBox(height: 2),
          _buildFeedbackBox(q),
          const SizedBox(height: 14),
          _buildNextButton(),
        ],
      ],
    );
  }

  Widget _buildStatusStrip() {
    final int total = _questions.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: sunnySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 17,
                  color: sunnyDeep,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_score * 10} poin',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),
              const Spacer(),
              Text(
                'Soal ${_currentIndex + 1} dari $total',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(total, (index) {
              final bool isDone = index < _currentIndex;
              final bool isActive = index == _currentIndex;
              final bool isAnsweredNow = isActive && _answered;
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: isDone || isAnsweredNow
                        ? skyDeep
                        : isActive
                            ? sunny
                            : lineBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneCard(_DropCoverQuestion q, _SceneStyle style) {
    final bool timerLow = _timer <= 3;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: style.deep.withValues(alpha: 0.32),
            blurRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [style.color, style.deep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -26,
                  top: -34,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 62,
                  bottom: -38,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: style.deep.withValues(alpha: 0.24),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: CustomPaint(
                        painter: TurtlePainter(
                          expression: timerLow
                              ? TurtleExpression.alert
                              : TurtleExpression.happy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.9,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            style.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            timerLow
                                ? Icons.timer_off_rounded
                                : Icons.timer_rounded,
                            size: 14,
                            color: timerLow ? coralDeep : style.deep,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$_timer dtk',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: timerLow ? coralDeep : style.deep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: style.soft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(style.icon, size: 20, color: style.deep),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    q.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: navy,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    int idx,
    _DropCoverOption opt,
    _SceneStyle style,
  ) {
    final bool isSelected = idx == _selectedOptionIdx;
    final bool showCorrect = _answered && opt.isCorrect;
    final bool showWrong = _answered && isSelected && !opt.isCorrect;

    Color borderColor = lineBorder;
    Color shadowColor = shadow3D;
    Color badgeBg = style.soft;
    Color badgeText = style.deep;
    IconData? badgeIcon;

    if (showCorrect) {
      borderColor = mintDeep;
      shadowColor = const Color(0xFFC8EFDA);
      badgeBg = mintDeep;
      badgeText = Colors.white;
      badgeIcon = Icons.check_rounded;
    } else if (showWrong) {
      borderColor = coralDeep;
      shadowColor = const Color(0xFFF7CFC8);
      badgeBg = coralDeep;
      badgeText = Colors.white;
      badgeIcon = Icons.close_rounded;
    }

    final double opacity = _answered && !showCorrect && !showWrong ? 0.55 : 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: () => _onOptionTapped(idx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: showCorrect
                  ? mintSoft
                  : showWrong
                      ? coralSoft
                      : cardBg,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: borderColor, width: 2.4),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: badgeIcon != null
                      ? Icon(badgeIcon, color: badgeText, size: 21)
                      : Text(
                          String.fromCharCode(65 + idx),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: badgeText,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt.text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: navy,
                      height: 1.4,
                    ),
                  ),
                ),
                if (showCorrect || showWrong) ...[
                  const SizedBox(width: 6),
                  Icon(
                    showCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 21,
                    color: showCorrect ? mintDeep : coralDeep,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBox(_DropCoverQuestion q) {
    final bool timedOut = _selectedOptionIdx == -1;
    final bool isCorrect = !timedOut && q.options[_selectedOptionIdx].isCorrect;

    final Color accent = isCorrect ? mintDeep : coralDeep;
    final Color softBg = isCorrect ? mintSoft : coralSoft;
    final Color border =
        isCorrect ? const Color(0xFFBEEBD1) : const Color(0xFFF7CFC8);

    final String title = isCorrect
        ? 'Tepat sekali!'
        : timedOut
            ? 'Waktu habis'
            : 'Belum tepat';

    final String message = isCorrect
        ? q.goodMsg
        : timedOut
            ? 'Waktu habis. ${q.badMsg}'
            : q.badMsg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isCorrect
                  ? Icons.check_rounded
                  : timedOut
                      ? Icons.timer_off_rounded
                      : Icons.lightbulb_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: navy,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final bool isLast = _currentIndex == _questions.length - 1;
    return GestureDetector(
      onTap: _onNextTapped,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isLast
              ? const LinearGradient(
                  colors: [mint, mintDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [sky, skyDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isLast ? const Color(0xFF238A5E) : const Color(0xFF2E86AF),
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Lihat Hasil' : 'Soal Berikutnya',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  // ================= FINISH SCREEN =================
  Widget _buildFinishScreen() {
    final bool passed = _score >= (_questions.length / 2);
    final UserProgressManager pm = UserProgressManager();
    final int earnedPoints = _score * 10;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 4),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: sunny, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: sunnyDeep.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(11),
                child: CustomPaint(
                  painter: TurtlePainter(
                    expression: passed
                        ? TurtleExpression.proud
                        : TurtleExpression.happy,
                  ),
                ),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: sunny,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    passed
                        ? Icons.emoji_events_rounded
                        : Icons.favorite_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: sunnySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'MISI SELESAI',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: Color(0xFF8A6300),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed ? 'Hebat, Kamu Jagoan Siaga!' : 'Terus Berlatih, Jagoan!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: navy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kamu sudah menyelesaikan semua misi kuis '
            'Drop, Cover & Hold On.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: inkSoft,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lineBorder, width: 2.5),
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
                const Text(
                  'POIN AKTIVITAS DIDAPAT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: inkSoft,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: sunnyDeep,
                      size: 34,
                    ),
                    Text(
                      '+$earnedPoints',
                      style: const TextStyle(
                        fontSize: 38,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: sunnyDeep,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5, left: 4),
                      child: Text(
                        'poin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8A6300),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: _score / _questions.length,
                    minHeight: 8,
                    backgroundColor: lineBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(mintDeep),
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Benar $_score dari ${_questions.length} soal',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: lineBorder,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Terbaik ${pm.dropCoverBestScore}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8A6300),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildStepRecap(),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _restartGame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [sky, skyDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF2E86AF),
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Main Lagi',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: lineBorder, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: shadow3D,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, color: navy, size: 19),
                  SizedBox(width: 7),
                  Text(
                    'Kembali ke Arena',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: navy,
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

  Widget _buildStepRecap() {
    return Row(
      children: [
        _buildRecapChip('DROP', Icons.arrow_downward_rounded, skyDeep, skyMist),
        const SizedBox(width: 7),
        _buildRecapChip('COVER', Icons.table_bar_rounded, mintDeep, mintSoft),
        const SizedBox(width: 7),
        _buildRecapChip(
          'HOLD ON',
          Icons.back_hand_rounded,
          sunnyDeep,
          sunnySoft,
        ),
      ],
    );
  }

  Widget _buildRecapChip(
    String label,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

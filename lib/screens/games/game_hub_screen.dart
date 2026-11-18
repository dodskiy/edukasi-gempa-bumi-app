import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/user_progress_manager.dart';
import 'drop_cover_game_screen.dart';
import 'safe_spot_game_screen.dart';
import 'earthquake_simulation_game_screen.dart';
import '../quiz/quiz_screen.dart';
import '../home_screen.dart' show KikiPainter, KikiExpression;

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF31355A);
  static const Color heroBlue = Color(0xFF6FC6EE); // sky
  static const Color heroBlueDeep = Color(0xFF3FA8DA); // skyDeep
  static const Color gold = Color(0xFFFFC94D); // sunny
  static const Color goldDeep = Color(0xFFF2A70B); // sunnyDeep
  static const Color red = Color(0xFFFF8B7A); // coral
  static const Color redDeep = Color(0xFFF16249); // coralDeep
  static const Color green = Color(0xFF6FDBA8); // mint
  static const Color greenDeep = Color(0xFF3DBE85); // mintDeep
  static const Color purple = Color(0xFFB79CF0); // grape
  static const Color purpleDeep = Color(0xFF7048C4); // grapeDeep
  static const Color cream = Color(0xFFFFFBF1);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color lineBorder = Color(0xFFF2ECDA);
  static const Color shadow3D = Color(0xFFE9E2CE); // shadow "3D" offset lembut
  static const Color inkSoft = Color(0xFF8385A3);

  late AnimationController _liveController;
  late Animation<double> _bounceOffset; // utk Kiki melompat kecil
  late Animation<double> _pulseScale; // utk badge "BARU" berdenyut
  late Animation<double> _twinkle; // utk kerlipan bintang dekoratif

  @override
  void initState() {
    super.initState();
    UserProgressManager.progressNotifier.addListener(_onProgressUpdated);
    _liveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _bounceOffset = Tween<double>(begin: 0, end: -9).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.09).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );
    _twinkle = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    UserProgressManager.progressNotifier.removeListener(_onProgressUpdated);
    _liveController.dispose();
    super.dispose();
  }

  void _onProgressUpdated() {
    if (mounted) setState(() {});
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
                // 1. Top Bar
                _buildTopBar(context),

                // 2. Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Banner biru+putih dengan Kiki melompat
                        _buildHeroBanner(),
                        const SizedBox(height: 16),

                        // Section Title
                        _buildSectionHeader(),
                        const SizedBox(height: 12),

                        // Game 1: Gedung Runtuh (Retro Handheld / Simulation)
                        _buildGameCard(
                          isNew: true,
                          iconEmoji: '🏚️',
                          iconGradient: const [
                            Color(0xFFFFE3E3),
                            Color(0xFFFFD1D1)
                          ],
                          tagText: 'Simulasi 2D Realistis',
                          tagColor: redDeep,
                          tagBg: const Color(0xFFFFE3E3),
                          title: 'Gedung Runtuh: Misi Evakuasi Gempa',
                          description:
                              'Selamatkan teman-teman di gedung sekolah yang retak saat gempa 7.2 SR, lalu pandu mereka ke tempat aman!',
                          rewardLabel: '+50 poin',
                          playerCount: '2.104 pemain',
                          difficulty: 'Menantang',
                          btnGradient: const [Color(0xFFFF8A7A), red],
                          btnShadowColor: redDeep,
                          btnTextColor: Colors.white,
                          onPlay: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EarthquakeSimulationGameScreen(),
                              ),
                            );
                          },
                        ),

                        // Game 2: Drop, Cover, Hold
                        _buildGameCard(
                          isNew: false,
                          iconEmoji: '🛡️',
                          iconGradient: const [
                            Color(0xFFFFF3D0),
                            Color(0xFFFFE7A8)
                          ],
                          tagText: 'Latihan Refleks',
                          tagColor: const Color(0xFF8A6300),
                          tagBg: const Color(0xFFFFF3D0),
                          title: 'Cepat Tanggap: Drop, Cover, Hold',
                          description:
                              'Uji respon tubuhmu secepat kilat saat alarm gempa tiba-tiba berbunyi di sekolah, kamar, atau mal!',
                          rewardLabel: '+70 poin',
                          playerCount: '3.870 pemain',
                          difficulty: 'Sedang',
                          btnGradient: const [Color(0xFFFFD35C), gold],
                          btnShadowColor: goldDeep,
                          btnTextColor: const Color(0xFF5B4300),
                          onPlay: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DropCoverGameScreen(),
                              ),
                            );
                          },
                        ),

                        // Game 3: Misi Zona Aman (Detektif Gempa)
                        _buildGameCard(
                          isNew: true,
                          iconEmoji: '🏫',
                          iconGradient: const [
                            Color(0xFFE0F2FE),
                            Color(0xFFBAE6FD)
                          ],
                          tagText: 'Eksplorasi Interaktif',
                          tagColor: const Color(0xFF0284C7),
                          tagBg: const Color(0xFFE0F2FE),
                          title: 'Misi Zona Aman: Detektif Gempa',
                          description:
                              'Bumi berguncang! Uji kejelianmu menemukan tempat aman dan jauhi benda berbahaya di kelas, kantin, & lorong sekolah!',
                          rewardLabel: '+50 poin',
                          playerCount: '2.840 pemain',
                          difficulty: 'Seru & Edukatif',
                          btnGradient: const [
                            Color(0xFF38BDF8),
                            Color(0xFF0284C7)
                          ],
                          btnShadowColor: const Color(0xFF0369A1),
                          btnTextColor: Colors.white,
                          onPlay: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SafeSpotGameScreen(),
                              ),
                            );
                          },
                        ),

                        // Game 4: Kuis Pahlawan Siaga Gempa
                        _buildGameCard(
                          isNew: false,
                          iconEmoji: '🧠',
                          iconGradient: const [
                            Color(0xFFEFE7FF),
                            Color(0xFFDED0FF)
                          ],
                          tagText: 'Kuis Pengetahuan',
                          tagColor: purpleDeep,
                          tagBg: const Color(0xFFEFE7FF),
                          title: 'Kuis Pahlawan Siaga Gempa',
                          description:
                              'Jawab 10 soal seru dan kumpulkan poin untuk membuktikan kamu pahlawan siaga sejati!',
                          rewardLabel: '+35 poin',
                          playerCount: '4.291 pemain',
                          difficulty: 'Mudah',
                          btnGradient: const [Color(0xFFB79CFF), purple],
                          btnShadowColor: purpleDeep,
                          btnTextColor: Colors.white,
                          onPlay: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuizScreen(),
                              ),
                            );
                          },
                        ),
                      ],
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

  // ================= TOP BAR =================
  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [heroBlue, heroBlueDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x3331355A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Row(
        children: [
          // Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                alignment: Alignment.center,
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Title Wrap
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Arena Game Siaga Gempa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'PILIH MISI SERUMU',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFFCFE4FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: gold,
                  size: 15,
                ),
                const SizedBox(width: 3),
                Text(
                  '${UserProgressManager().activityPoints}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
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

  // ================= HERO BANNER (3D, biru + putih, Kiki melompat) =================
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [heroBlue, heroBlueDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: heroBlueDeep.withOpacity(0.55),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dekorasi awan putih lembut (konsisten dgn Home Screen)
          const Positioned(
            top: -8,
            right: 54,
            child: Opacity(
              opacity: 0.30,
              child: Text('☁️', style: TextStyle(fontSize: 34)),
            ),
          ),
          const Positioned(
            bottom: 2,
            left: -8,
            child: Opacity(
              opacity: 0.22,
              child: Text('☁️', style: TextStyle(fontSize: 26)),
            ),
          ),

          // Bintang kerlap-kerlip (animasi opacity)
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) {
              return Positioned(
                top: 4,
                right: 96,
                child: Opacity(
                  opacity: _twinkle.value,
                  child: const Text('✦',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) {
              return Positioned(
                bottom: 10,
                right: 18,
                child: Opacity(
                  opacity: 1.35 - _twinkle.value,
                  child: const Text('✦',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              );
            },
          ),

          // Konten Teks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1.6),
                ),
                alignment: Alignment.center,
                child: const Text('🎮', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belajar Seru Sambil Bermain!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Uji kecepatan refleks dan ketepatan keputusanmu menghadapi gempa bumi, bareng si Kiki!',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFEAF7FF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 58),
            ],
          ),

          // Kiki si burung hantu — melompat-lompat kecil (animasi bounce)
          Positioned(
            right: -4,
            bottom: -10,
            child: AnimatedBuilder(
              animation: _bounceOffset,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceOffset.value),
                  child: child,
                );
              },
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const CustomPaint(
                  painter: KikiPainter(expression: KikiExpression.proud),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION HEADER =================
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Semua Game (4)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Diurutkan: Populer',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: inkSoft,
            ),
          ),
        ),
      ],
    );
  }

  // ================= GAME CARD BUILDER (gaya kartu 3D) =================
  Widget _buildGameCard({
    required bool isNew,
    required String iconEmoji,
    required List<Color> iconGradient,
    required String tagText,
    required Color tagColor,
    required Color tagBg,
    required String title,
    required String description,
    required String rewardLabel,
    required String playerCount,
    required String difficulty,
    required List<Color> btnGradient,
    required Color btnShadowColor,
    required Color btnTextColor,
    required VoidCallback onPlay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineBorder, width: 2.5),
        // Bayangan "3D" offset tegas tanpa blur — konsisten dgn Home Screen
        boxShadow: const [
          BoxShadow(
            color: shadow3D,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // New Tag on Top Right (berdenyut pelan agar menarik perhatian)
          if (isNew)
            Positioned(
              top: -24,
              right: 8,
              child: AnimatedBuilder(
                animation: _pulseScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScale.value,
                    child: child,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: red,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: red.withOpacity(0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: const Text(
                    'BARU',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Details (Icon + Title + Tags)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: iconGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(iconEmoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tagText,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: tagColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: navy,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                              fontSize: 11.5, color: inkSoft, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meta Information Row (Poin, Players, Difficulty)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: goldDeep,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rewardLabel,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8A6300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: lineBorder, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text(playerCount,
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: inkSoft)),
                  const SizedBox(width: 7),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: lineBorder, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      difficulty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Play Button — gaya 3D (bayangan offset padat tanpa blur)
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: btnGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: btnShadowColor.withOpacity(0.6),
                        blurRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '▶  Mulai Main Game',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: btnTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

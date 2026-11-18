import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_palette.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final AnimationController _ambient;
  bool _shaking = false;
  bool _pressed = false;
  Timer? _autoShake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // Getaran otomatis satu kali untuk menarik perhatian anak-anak.
    _autoShake = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) _guncang();
    });
  }

  @override
  void dispose() {
    _autoShake?.cancel();
    _shake.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _guncang() {
    if (_shaking) return;
    HapticFeedback.heavyImpact();
    setState(() => _shaking = true);
    _shake.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _shaking = false);
    });
  }

  void _masuk() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      backgroundColor: AppPalette.skyMist,
      body: Stack(
        children: [
          // Latar belakang penuh: langit, matahari, awan, pulau Maluku,
          // gelombang gempa, dan latar krem yang sama dengan Home.
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([_ambient, _shake]),
                builder: (context, _) => CustomPaint(
                  painter: _SplashBackdropPainter(
                    t: _ambient.value,
                    shakeT: _shake.value,
                    shaking: _shaking,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    compact ? 12 : 22,
                    22,
                    compact ? 10 : 16,
                  ),
                  child: Column(
                    children: [
                      _buildTitle(),
                      SizedBox(height: compact ? 10 : 14),
                      Expanded(child: _buildIllustration()),
                      SizedBox(height: compact ? 10 : 14),
                      _buildStatsRow(),
                      SizedBox(height: compact ? 10 : 14),
                      _buildButton(),
                      const SizedBox(height: 10),
                      _buildHint(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // JUDUL
  // ============================================================
  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppPalette.skyDeep.withValues(alpha: 0.22),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppPalette.skyDeep.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                'SIGEMPA MALUT',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppPalette.mintDeep,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'EDUKASI BENCANA',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppPalette.navy,
            height: 1.1,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: Color(0x33FFFFFF),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => AppPalette.coralGradient.createShader(rect),
          child: const Text(
            'GEMPA BUMI',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.05,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppPalette.skyDeep.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'BERBASIS GAME INTERAKTIF',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppPalette.navy,
              letterSpacing: 0.9,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bagi Siswa di Wilayah Rawan Gempa Maluku Utara',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6C8A),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ILUSTRASI UTAMA (kartu sekolah + maskot kura-kura)
  // ============================================================
  Widget _buildIllustration() {
    const double radius = 28.0;

    return GestureDetector(
      onTap: _guncang,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppPalette.skyDeep.withValues(alpha: 0.22),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppPalette.skyDeep.withValues(alpha: 0.45),
            radius: radius,
            strokeWidth: 2,
            dashLength: 8,
            gapLength: 6,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF9ADCF7), Color(0xFFEAF9FF)],
                ),
              ),
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, _) {
                  final double bob =
                      math.sin(_ambient.value * math.pi * 2) * 3.0;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SplashScenePainter(
                            t: _shake.value,
                            shaking: _shaking,
                            ambient: _ambient.value,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: Transform.translate(
                          offset: Offset(0, -bob),
                          child: _buildMascot(),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _buildBubble(),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 14,
                        child: _buildSafetyChip(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMascot() {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppPalette.sunny, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E31355A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TurtlePainter(
          expression:
              _shaking ? TurtleExpression.alert : TurtleExpression.happy,
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 248),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: _shaking
              ? AppPalette.sunnySoft
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
            color: _shaking
                ? AppPalette.sunny
                : Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2631355A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _shaking
                ? '⚠️ Gempa! Merunduk, lindungi kepala, & lari ke lapangan!'
                : '🐢 Ketuk layar untuk simulasi gempa!',
            key: ValueKey(_shaking),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppPalette.navy,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F31355A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety_rounded,
              size: 12, color: AppPalette.mintDeep),
          SizedBox(width: 4),
          Text(
            'DROP • COVER • HOLD ON',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              color: AppPalette.navy,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARIS STATISTIK KECIL
  // ============================================================
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatChip('🐢', 'Kura Siaga'),
        const SizedBox(width: 8),
        _buildStatChip('🎮', 'Game Seru'),
        const SizedBox(width: 8),
        _buildStatChip('⭐', 'Lencana'),
      ],
    );
  }

  Widget _buildStatChip(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppPalette.lineBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppPalette.shadow3D,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOMBOL MULAI GAME
  // ============================================================
  Widget _buildButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _masuk,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: double.infinity,
        height: 58,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          gradient: AppPalette.coralGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.38),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.coralDark,
              offset: Offset(0, _pressed ? 1 : 5),
              blurRadius: 0,
            ),
            BoxShadow(
              color: AppPalette.coralDeep.withValues(alpha: 0.28),
              offset: const Offset(0, 10),
              blurRadius: 18,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double shineX =
                  (constraints.maxWidth + 140) * _ambient.value - 70;
              return Stack(
                children: [
                  Positioned(
                    left: shineX,
                    top: -40,
                    child: Transform.rotate(
                      angle: 0.35,
                      child: Container(
                        width: 36,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PlayBadge(),
                        SizedBox(width: 10),
                        Text(
                          'MULAI GAME',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.touch_app_rounded,
            size: 14, color: AppPalette.inkSoft),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'Ketuk maskot untuk simulasi gempa  •  Siap belajar siaga gempa?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppPalette.inkSoft.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child:
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
    );
  }
}

// ================================================================
// LATAR BELAKANG SPLASH
// ================================================================
class _SplashBackdropPainter extends CustomPainter {
  final double t; // ambient 0..1
  final double shakeT; // 0..1
  final bool shaking;

  const _SplashBackdropPainter({
    required this.t,
    required this.shakeT,
    required this.shaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Langit cerah bergradasi.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = AppPalette.skyGradient.createShader(
          Rect.fromLTWH(0, 0, w, h),
        ),
    );

    // Cahaya lembut di balik judul supaya teks tetap nyaman dibaca.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.52),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.85),
          radius: 0.95,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.52)),
    );

    canvas.save();
    if (shaking) {
      final double amp = 3.4 * (1 - shakeT);
      canvas.translate(
        math.sin(shakeT * math.pi * 26) * amp,
        math.cos(shakeT * math.pi * 19) * amp * 0.45,
      );
    }

    // 2. Matahari dengan sinar yang berputar sangat pelan.
    final Offset sunCenter = Offset(w * 0.845, h * 0.105);
    final double sunR = math.min(w * 0.085, 44);
    canvas.drawCircle(
      sunCenter,
      sunR * 2.7,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      sunCenter,
      sunR * 1.75,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()..color = AppPalette.sunny,
    );
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()
        ..color = AppPalette.sunnyDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final rayPaint = Paint()
      ..color = AppPalette.sunnyDeep.withValues(alpha: 0.45)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi / 4) + (t * math.pi * 2 * 0.08);
      final double inner = sunR * 1.3;
      final double outer = sunR * (1.55 + 0.08 * math.sin(t * math.pi * 2 + i));
      canvas.drawLine(
        sunCenter + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        sunCenter + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        rayPaint,
      );
    }

    // 3. Awan kartun yang mengapung pelan.
    _drawCloud(
      canvas,
      Offset(
        w * 0.20 + math.sin(t * math.pi * 2) * 12,
        h * 0.115,
      ),
      w * 0.075,
      0.88,
    );
    _drawCloud(
      canvas,
      Offset(
        w * 0.58 - math.sin(t * math.pi * 2 + 1.2) * 10,
        h * 0.185,
      ),
      w * 0.052,
      0.65,
    );
    _drawCloud(
      canvas,
      Offset(
        w * 0.10 + math.cos(t * math.pi * 2 + 0.6) * 8,
        h * 0.29,
      ),
      w * 0.04,
      0.45,
    );

    // 4. Pulau & perbukitan Maluku Utara di kejauhan.
    final double horizon = h * 0.80;

    final farHills = Path()
      ..moveTo(-20, horizon)
      ..quadraticBezierTo(w * 0.12, h * 0.58, w * 0.34, horizon * 0.86)
      ..quadraticBezierTo(w * 0.52, h * 0.64, w * 0.70, horizon * 0.88)
      ..quadraticBezierTo(w * 0.88, h * 0.66, w + 20, horizon)
      ..lineTo(w + 20, horizon + 10)
      ..lineTo(-20, horizon + 10)
      ..close();
    canvas.drawPath(
      farHills,
      Paint()..color = AppPalette.mint.withValues(alpha: 0.34),
    );

    // Gunung berapi (Gamalama) dengan asap kecil.
    final volcano = Path()
      ..moveTo(w * 0.56, horizon)
      ..lineTo(w * 0.70, h * 0.665)
      ..quadraticBezierTo(w * 0.715, h * 0.648, w * 0.73, h * 0.665)
      ..lineTo(w * 0.87, horizon)
      ..close();
    canvas.drawPath(
      volcano,
      Paint()..color = AppPalette.mintDeep.withValues(alpha: 0.30),
    );
    final crater = Paint()
      ..color = AppPalette.coralDeep.withValues(alpha: 0.45);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.715, h * 0.657),
        width: w * 0.035,
        height: h * 0.009,
      ),
      crater,
    );
    for (int i = 0; i < 3; i++) {
      final double p = (t + i * 0.33) % 1.0;
      canvas.drawCircle(
        Offset(
          w * 0.715 + math.sin(p * math.pi * 2 + i) * 10,
          h * 0.64 - p * h * 0.055,
        ),
        5 + p * 7,
        Paint()..color = Colors.white.withValues(alpha: (1 - p) * 0.35),
      );
    }

    final nearHills = Path()
      ..moveTo(-20, horizon)
      ..quadraticBezierTo(w * 0.22, h * 0.70, w * 0.46, horizon * 0.97)
      ..quadraticBezierTo(w * 0.72, h * 0.72, w + 20, horizon * 0.96)
      ..lineTo(w + 20, horizon + 20)
      ..lineTo(-20, horizon + 20)
      ..close();
    canvas.drawPath(
      nearHills,
      Paint()..color = AppPalette.mintDeep.withValues(alpha: 0.22),
    );

    // 5. Daratan krem yang menyatu dengan warna Home Screen.
    final ground = Path()
      ..moveTo(0, horizon + 16)
      ..quadraticBezierTo(w * 0.18, horizon - 4, w * 0.36, horizon + 12)
      ..quadraticBezierTo(w * 0.55, horizon + 26, w * 0.74, horizon + 10)
      ..quadraticBezierTo(w * 0.90, horizon - 2, w, horizon + 14)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ground, Paint()..color = AppPalette.cream);

    // Garis gelombang tipis di atas daratan.
    final wavePaint = Paint()
      ..color = AppPalette.skyDeep.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 2; i++) {
      final double y = horizon + 22 + i * 18;
      final Path wave = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * 0.25, y - 8, w * 0.5, y)
        ..quadraticBezierTo(w * 0.75, y + 8, w, y);
      canvas.drawPath(wave, wavePaint);
    }

    // Jejak kaki kura-kura kecil di sudut bawah.
    final footprint = Paint()
      ..color = AppPalette.shadow3D.withValues(alpha: 0.85);
    for (int i = 0; i < 6; i++) {
      final Offset p = Offset(
        18.0 + i * 15,
        h - 20 - i * 5 - math.sin(i * 1.5) * 3,
      );
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(-0.35 + i * 0.12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 7, height: 8.5),
        footprint,
      );
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(-4 + j * 4.0, -6.5),
          1.35,
          footprint,
        );
      }
      canvas.restore();
    }

    // 6. Partikel bintang kecil yang melayang.
    const List<List<double>> sparkles = [
      [0.10, 0.22, 3.2, 0.0],
      [0.30, 0.36, 2.2, 0.7],
      [0.46, 0.12, 2.8, 1.4],
      [0.64, 0.30, 2.0, 2.1],
      [0.92, 0.34, 3.0, 0.4],
      [0.78, 0.58, 2.4, 1.8],
      [0.22, 0.62, 2.0, 2.8],
      [0.95, 0.66, 2.2, 1.1],
      [0.06, 0.46, 2.6, 3.4],
    ];
    for (final sparkle in sparkles) {
      final double x = sparkle[0] * w;
      final double baseY = sparkle[1] * h;
      final double radius = sparkle[2];
      final double phase = sparkle[3];
      final double y = baseY + math.sin(t * math.pi * 2 + phase) * 7;
      final double alpha =
          0.28 + 0.30 * (0.5 + 0.5 * math.sin(t * math.pi * 2 + phase));
      _drawSparkle(
        canvas,
        Offset(x, y),
        radius,
        Colors.white.withValues(alpha: alpha),
      );
    }

    // 7. Efek gelombang & retakan saat simulasi gempa.
    if (shaking) {
      final Offset epicenter = Offset(w * 0.5, h * 0.70);
      for (int i = 0; i < 3; i++) {
        final double p = (shakeT + i * 0.26) % 1.0;
        final double radius = w * 0.10 + p * w * 0.52;
        canvas.drawCircle(
          epicenter,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4
            ..color = AppPalette.coralDeep.withValues(alpha: (1 - p) * 0.30),
        );
      }

      final double alpha =
          shakeT < 0.75 ? 1.0 : ((1 - shakeT) / 0.25).clamp(0.0, 1.0);
      final crackPaint = Paint()
        ..color = AppPalette.coralDark.withValues(alpha: alpha * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final Path crackA = Path()
        ..moveTo(w * 0.08, h - 46)
        ..relativeLineTo(w * 0.06, -14)
        ..relativeLineTo(-w * 0.02, -10)
        ..relativeLineTo(w * 0.07, -12);
      canvas.drawPath(crackA, crackPaint);

      final Path crackB = Path()
        ..moveTo(w * 0.88, h - 34)
        ..relativeLineTo(-w * 0.05, -12)
        ..relativeLineTo(w * 0.02, -9)
        ..relativeLineTo(-w * 0.06, -11);
      canvas.drawPath(crackB, crackPaint);
    }

    canvas.restore();
  }

  void _drawCloud(
    Canvas canvas,
    Offset center,
    double size,
    double opacity,
  ) {
    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: 0.92 * opacity);
    final Paint shade = Paint()
      ..color = AppPalette.skyDeep.withValues(alpha: 0.10 * opacity);
    canvas.drawCircle(
      Offset(center.dx, center.dy + size * 0.18),
      size * 0.58,
      shade,
    );
    canvas.drawCircle(center, size * 0.72, p);
    canvas.drawCircle(
      Offset(center.dx - size * 0.70, center.dy + size * 0.16),
      size * 0.50,
      p,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.68, center.dy + size * 0.14),
      size * 0.56,
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.26),
        width: size * 2.15,
        height: size * 0.72,
      ),
      p,
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
  bool shouldRepaint(covariant _SplashBackdropPainter old) =>
      old.t != t || old.shakeT != shakeT || old.shaking != shaking;
}

// ================================================================
// BORDER PUTUS-PUTUS
// ================================================================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}

// ================================================================
// ADEGAN SEKOLAH DI DALAM KARTU
// ================================================================
class _SplashScenePainter extends CustomPainter {
  final double t;
  final bool shaking;
  final double ambient;

  const _SplashScenePainter({
    required this.t,
    required this.shaking,
    required this.ambient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double s = math.min(w / 400, h / 280);
    final double left = (w - 400 * s) / 2;
    final double top = h - 280 * s;

    // Langit di atas ilustrasi (layar tinggi) diisi awan & burung agar
    // tidak terlihat kosong.
    if (top > 60) {
      _drawCloud(canvas, Offset(w * 0.20, top * 0.32), 8.5);
      _drawCloud(canvas, Offset(w * 0.74, top * 0.22), 6.5);
      _drawCloud(canvas, Offset(w * 0.55, top * 0.58), 5.0);
      _drawBird(canvas, Offset(w * 0.82, top * 0.46), 4.5);
      _drawBird(canvas, Offset(w * 0.88, top * 0.41), 3.2);
    }

    canvas.save();
    canvas.translate(left, top);
    canvas.scale(s);

    if (shaking) {
      final double amp = 6.0 * (1 - t);
      final double dx = math.sin(t * math.pi * 2 * 11) * amp;
      final double dy = math.cos(t * math.pi * 2 * 17) * amp * 0.35;
      canvas.translate(dx, dy);
    }

    // 1. Matahari di dalam kartu.
    const Offset sun = Offset(338, 46);
    canvas.drawCircle(
      sun,
      32,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      sun,
      23,
      Paint()..color = AppPalette.sunny.withValues(alpha: 0.26),
    );
    canvas.drawCircle(sun, 15, Paint()..color = AppPalette.sunny);
    final Paint sunRay = Paint()
      ..color = AppPalette.sunnyDeep.withValues(alpha: 0.42)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi / 4) + (ambient * math.pi * 2 * 0.08);
      canvas.drawLine(
        sun + Offset(math.cos(angle) * 19, math.sin(angle) * 19),
        sun + Offset(math.cos(angle) * 24, math.sin(angle) * 24),
        sunRay,
      );
    }

    // 2. Awan.
    _drawCloud(
      canvas,
      Offset(70 + math.sin(ambient * math.pi * 2) * 3, 34),
      10,
    );
    _drawCloud(
      canvas,
      Offset(222 - math.sin(ambient * math.pi * 2 + 1) * 3, 22),
      12,
    );
    _drawCloud(canvas, const Offset(152, 62), 7);

    // 3. Burung kecil.
    _drawBird(canvas, const Offset(262, 58), 5);
    _drawBird(canvas, const Offset(276, 51), 3.5);

    // 4. Gunung berapi & bukit.
    final Path volcano = Path()
      ..moveTo(196, 162)
      ..lineTo(282, 78)
      ..quadraticBezierTo(289, 71, 296, 78)
      ..lineTo(392, 162)
      ..close();
    canvas.drawPath(
      volcano,
      Paint()..color = const Color(0xFF8FD3BC),
    );
    canvas.drawPath(
      Path()
        ..moveTo(282, 78)
        ..quadraticBezierTo(289, 71, 296, 78)
        ..lineTo(306, 92)
        ..quadraticBezierTo(289, 86, 274, 92)
        ..close(),
      Paint()..color = const Color(0xFF6FBFA6),
    );
    for (int i = 0; i < 3; i++) {
      final double p = (ambient + i * 0.33) % 1.0;
      canvas.drawCircle(
        Offset(289 + math.sin(p * math.pi * 2 + i) * 4, 70 - p * 24),
        3.0 + p * 5,
        Paint()..color = Colors.white.withValues(alpha: (1 - p) * 0.5),
      );
    }

    final Path farHill = Path()
      ..moveTo(-20, 162)
      ..quadraticBezierTo(40, 116, 106, 148)
      ..quadraticBezierTo(160, 170, 220, 150)
      ..quadraticBezierTo(300, 126, 420, 160)
      ..lineTo(420, 180)
      ..lineTo(-20, 180)
      ..close();
    canvas.drawPath(
      farHill,
      Paint()..color = const Color(0xFFA7DEBF),
    );

    final Path nearHill = Path()
      ..moveTo(-20, 166)
      ..quadraticBezierTo(60, 138, 140, 162)
      ..quadraticBezierTo(250, 186, 420, 156)
      ..lineTo(420, 184)
      ..lineTo(-20, 184)
      ..close();
    canvas.drawPath(
      nearHill,
      Paint()..color = const Color(0xFF7FCFA9),
    );

    // 5. Gedung sekolah dasar.
    const double schoolBaseY = 162;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 94, 98, schoolBaseY - 94),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFF9C4),
    );
    canvas.drawRect(
      const Rect.fromLTWH(42, schoolBaseY - 10, 98, 10),
      Paint()..color = const Color(0xFFFFB74D),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(260, 94, 98, schoolBaseY - 94),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFF9C4),
    );
    canvas.drawRect(
      const Rect.fromLTWH(260, schoolBaseY - 10, 98, 10),
      Paint()..color = const Color(0xFFFFB74D),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(134, 76, 132, schoolBaseY - 76),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFFFFDE7),
    );
    canvas.drawRect(
      const Rect.fromLTWH(134, schoolBaseY - 12, 132, 12),
      Paint()..color = const Color(0xFFFFA726),
    );

    _drawWindow(canvas, 52, 106, 22, 24);
    _drawWindow(canvas, 82, 106, 22, 24);
    _drawWindow(canvas, 112, 106, 20, 24);
    _drawWindow(canvas, 268, 106, 20, 24);
    _drawWindow(canvas, 298, 106, 22, 24);
    _drawWindow(canvas, 328, 106, 22, 24);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(180, 116, 40, 46),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawRect(
      const Rect.fromLTWH(199, 116, 2, 46),
      Paint()..color = const Color(0xFF4E342E),
    );
    canvas.drawRect(
      const Rect.fromLTWH(184, 122, 12, 16),
      Paint()..color = const Color(0xFF81D4FA),
    );
    canvas.drawRect(
      const Rect.fromLTWH(204, 122, 12, 16),
      Paint()..color = const Color(0xFF81D4FA),
    );

    final Paint pillarPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        const Rect.fromLTWH(164, 106, 8, schoolBaseY - 106), pillarPaint);
    canvas.drawRect(
        const Rect.fromLTWH(228, 106, 8, schoolBaseY - 106), pillarPaint);

    final Path leftRoof = Path()
      ..moveTo(34, 96)
      ..lineTo(88, 64)
      ..lineTo(142, 96)
      ..close();
    canvas.drawPath(leftRoof, Paint()..color = const Color(0xFFD84315));
    canvas.drawPath(
      leftRoof,
      Paint()
        ..color = const Color(0xFFBF360C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final Path rightRoof = Path()
      ..moveTo(258, 96)
      ..lineTo(312, 64)
      ..lineTo(366, 96)
      ..close();
    canvas.drawPath(rightRoof, Paint()..color = const Color(0xFFD84315));
    canvas.drawPath(
      rightRoof,
      Paint()
        ..color = const Color(0xFFBF360C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final Path centerRoof = Path()
      ..moveTo(124, 78)
      ..lineTo(200, 36)
      ..lineTo(276, 78)
      ..close();
    canvas.drawPath(centerRoof, Paint()..color = const Color(0xFFE64A19));
    canvas.drawPath(
      centerRoof,
      Paint()
        ..color = const Color(0xFFBF360C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(162, 54, 76, 18),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(162, 54, 76, 18),
        const Radius.circular(3),
      ),
      Paint()
        ..color = AppPalette.coralDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
        const Offset(200, 63), 6, Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawCircle(
      const Offset(200, 63),
      6,
      Paint()
        ..color = AppPalette.coralDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawLine(
        const Offset(200, 63),
        const Offset(200, 59),
        Paint()
          ..color = const Color(0xFF1B2433)
          ..strokeWidth = 1.0);
    canvas.drawLine(
        const Offset(200, 63),
        const Offset(203, 63),
        Paint()
          ..color = const Color(0xFF1B2433)
          ..strokeWidth = 1.0);

    _drawTree(canvas, const Offset(24, 150), 22);
    _drawTree(canvas, const Offset(376, 150), 22);

    // 6. Lapangan sekolah.
    const Rect fieldRect = Rect.fromLTWH(-60, schoolBaseY, 520, 160);
    canvas.drawRect(fieldRect, Paint()..color = const Color(0xFF4CAF50));
    canvas.drawRect(
      const Rect.fromLTWH(-60, schoolBaseY, 520, 18),
      Paint()..color = const Color(0xFF43A047),
    );

    final Path track1 = Path()
      ..moveTo(-40, schoolBaseY + 28)
      ..quadraticBezierTo(200, schoolBaseY + 16, 440, schoolBaseY + 28);
    canvas.drawPath(
      track1,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final Path track2 = Path()
      ..moveTo(-40, schoolBaseY + 68)
      ..quadraticBezierTo(200, schoolBaseY + 54, 440, schoolBaseY + 68);
    canvas.drawPath(
      track2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawOval(
      Rect.fromCenter(
          center: const Offset(200, schoolBaseY + 44), width: 70, height: 26),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 7. Tiang bendera Merah Putih.
    const double poleX = 148;
    const double poleBaseY = schoolBaseY + 38;
    const double poleTopY = 82;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(poleX - 6, poleBaseY - 4, 12, 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFB0BEC5),
    );
    canvas.drawLine(
      const Offset(poleX, poleBaseY),
      const Offset(poleX, poleTopY),
      Paint()
        ..color = const Color(0xFFECEFF1)
        ..strokeWidth = 3,
    );
    canvas.drawCircle(const Offset(poleX, poleTopY), 3.5,
        Paint()..color = const Color(0xFFFFD54F));

    final Path flagMerah = Path()
      ..moveTo(poleX, poleTopY + 4)
      ..quadraticBezierTo(poleX + 14, poleTopY + 2, poleX + 28, poleTopY + 6)
      ..lineTo(poleX + 28, poleTopY + 15)
      ..quadraticBezierTo(poleX + 14, poleTopY + 11, poleX, poleTopY + 13)
      ..close();
    canvas.drawPath(flagMerah, Paint()..color = const Color(0xFFD32F2F));

    final Path flagPutih = Path()
      ..moveTo(poleX, poleTopY + 13)
      ..quadraticBezierTo(poleX + 14, poleTopY + 11, poleX + 28, poleTopY + 15)
      ..lineTo(poleX + 28, poleTopY + 24)
      ..quadraticBezierTo(poleX + 14, poleTopY + 20, poleX, poleTopY + 22)
      ..close();
    canvas.drawPath(flagPutih, Paint()..color = Colors.white);
    canvas.drawPath(
      flagPutih,
      Paint()
        ..color = const Color(0xFFCFD8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 8. Papan rambu titik kumpul.
    const double signX = 312;
    const double signBaseY = schoolBaseY + 44;

    canvas.drawLine(
      const Offset(signX, signBaseY),
      const Offset(signX, signBaseY - 38),
      Paint()
        ..color = const Color(0xFF78909C)
        ..strokeWidth = 3.5,
    );

    final RRect signRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(signX - 22, signBaseY - 58, 44, 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(signRect, Paint()..color = const Color(0xFF1B5E20));
    canvas.drawRRect(
      signRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final Paint arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(signX, signBaseY - 48), 2.5,
        Paint()..color = Colors.white);
    canvas.drawLine(const Offset(signX - 6, signBaseY - 52),
        const Offset(signX - 3, signBaseY - 49), arrowPaint);
    canvas.drawLine(const Offset(signX + 6, signBaseY - 52),
        const Offset(signX + 3, signBaseY - 49), arrowPaint);
    canvas.drawLine(const Offset(signX - 6, signBaseY - 44),
        const Offset(signX - 3, signBaseY - 47), arrowPaint);
    canvas.drawLine(const Offset(signX + 6, signBaseY - 44),
        const Offset(signX + 3, signBaseY - 47), arrowPaint);

    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'TITIK KUMPUL',
        style: TextStyle(
          color: Colors.white,
          fontSize: 4.8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(signX - textPainter.width / 2, signBaseY - 41.5),
    );

    // 9. Anak-anak berlari ke titik kumpul.
    _drawKid(canvas, const Offset(58, 198), const Color(0xFFFF8B7A), -0.10);
    _drawKid(canvas, const Offset(84, 206), const Color(0xFF5B7FE0), 0.05);
    _drawKid(canvas, const Offset(328, 210), const Color(0xFFFFC94D), 0.12);

    // 10. Semak & bunga di lapangan.
    _drawBush(canvas, const Offset(22, schoolBaseY + 90), 16);
    _drawBush(canvas, const Offset(382, schoolBaseY + 82), 18);
    _drawFlower(canvas, const Offset(44, schoolBaseY + 118));
    _drawFlower(canvas, const Offset(372, schoolBaseY + 112));
    _drawFlower(canvas, const Offset(118, schoolBaseY + 128));

    // 11. Retakan & debu ketika gempa.
    if (shaking) {
      final double alpha = t < 0.8 ? 1.0 : ((1 - t) / 0.2).clamp(0.0, 1.0);
      final Paint crackPaint = Paint()
        ..color = const Color(0xFF3E2723).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final Path crack1 = Path()
        ..moveTo(254, schoolBaseY + 12)
        ..relativeLineTo(-12, 14)
        ..relativeLineTo(8, 9)
        ..relativeLineTo(-14, 15)
        ..relativeLineTo(8, 11)
        ..relativeLineTo(-9, 12);
      canvas.drawPath(crack1, crackPaint);

      final Path crack2 = Path()
        ..moveTo(122, schoolBaseY + 18)
        ..relativeLineTo(10, 12)
        ..relativeLineTo(-7, 8)
        ..relativeLineTo(12, 14)
        ..relativeLineTo(-6, 9);
      canvas.drawPath(crack2, crackPaint);

      final Paint tremorPaint = Paint()
        ..color = const Color(0xFFFFF9C4).withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawLine(
        const Offset(220, schoolBaseY + 8),
        const Offset(245, schoolBaseY + 8),
        tremorPaint,
      );
      canvas.drawLine(
        const Offset(100, schoolBaseY + 12),
        const Offset(120, schoolBaseY + 12),
        tremorPaint,
      );

      for (int i = 0; i < 4; i++) {
        final double p = (t + i * 0.20) % 1.0;
        canvas.drawCircle(
          Offset(240 + i * 8, schoolBaseY + 6 - p * 14),
          2 + p * 4,
          Paint()
            ..color = const Color(0xFFFFF9C4)
                .withValues(alpha: (1 - p) * alpha * 0.8),
        );
      }
    }

    canvas.restore();
  }

  void _drawWindow(Canvas canvas, double x, double y, double w, double h) {
    final RRect frame = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h), const Radius.circular(3));
    canvas.drawRRect(frame, Paint()..color = const Color(0xFF81D4FA));
    canvas.drawRRect(
      frame,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(x + w / 2, y),
      Offset(x + w / 2, y + h),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(x, y + h / 2),
      Offset(x + w, y + h / 2),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2,
    );
  }

  void _drawTree(Canvas canvas, Offset baseCenter, double radius) {
    canvas.drawRect(
      Rect.fromLTWH(baseCenter.dx - 3.5, baseCenter.dy - 6, 7, 24),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawCircle(Offset(baseCenter.dx, baseCenter.dy - 12), radius,
        Paint()..color = const Color(0xFF2E7D32));
    canvas.drawCircle(
      Offset(baseCenter.dx - radius * 0.45, baseCenter.dy - 16),
      radius * 0.7,
      Paint()..color = const Color(0xFF388E3C),
    );
    canvas.drawCircle(
      Offset(baseCenter.dx + radius * 0.45, baseCenter.dy - 16),
      radius * 0.7,
      Paint()..color = const Color(0xFF43A047),
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double size) {
    final Paint p = Paint()..color = Colors.white.withValues(alpha: 0.90);
    canvas.drawCircle(center, size * 0.70, p);
    canvas.drawCircle(
      Offset(center.dx - size * 0.65, center.dy + size * 0.15),
      size * 0.50,
      p,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.65, center.dy + size * 0.15),
      size * 0.55,
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.25),
        width: size * 2.1,
        height: size * 0.7,
      ),
      p,
    );
  }

  void _drawBird(Canvas canvas, Offset center, double size) {
    final Paint paint = Paint()
      ..color = AppPalette.navy.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;
    final Path path = Path()
      ..moveTo(center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx - size * 0.45, center.dy - size * 0.65,
          center.dx, center.dy)
      ..quadraticBezierTo(center.dx + size * 0.45, center.dy - size * 0.65,
          center.dx + size, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawKid(Canvas canvas, Offset base, Color shirt, double lean) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(lean);

    // Kaki.
    final Paint leg = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-2, 5), const Offset(-3, 10), leg);
    canvas.drawLine(const Offset(2, 5), const Offset(3.5, 9), leg);
    // Badan.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -1, 8, 8),
        const Radius.circular(3),
      ),
      Paint()..color = shirt,
    );
    // Tangan.
    final Paint arm = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-4, 1), const Offset(-7, 4), arm);
    canvas.drawLine(const Offset(4, 1), const Offset(7, 3), arm);
    // Kepala.
    canvas.drawCircle(
      const Offset(0, -4),
      3.4,
      Paint()..color = const Color(0xFFFFCC9E),
    );
    canvas.drawCircle(
      const Offset(0, -4),
      3.4,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    // Rambut.
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, -4.6), width: 7, height: 7),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF4E342E),
    );
    canvas.restore();
  }

  void _drawBush(Canvas canvas, Offset center, double radius) {
    final Paint paint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.75, center.dy + radius * 0.18),
      radius * 0.62,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.75, center.dy + radius * 0.18),
      radius * 0.66,
      paint,
    );
  }

  void _drawFlower(Canvas canvas, Offset center) {
    final Paint petal = Paint()..color = const Color(0xFFFFF176);
    for (int i = 0; i < 5; i++) {
      final double angle = i * math.pi * 2 / 5;
      canvas.drawCircle(
        center + Offset(math.cos(angle) * 1.8, math.sin(angle) * 1.8),
        1.5,
        petal,
      );
    }
    canvas.drawCircle(center, 1.2, Paint()..color = const Color(0xFFFF8B7A));
  }

  @override
  bool shouldRepaint(covariant _SplashScenePainter old) =>
      old.t != t || old.shaking != shaking || old.ambient != ambient;
}

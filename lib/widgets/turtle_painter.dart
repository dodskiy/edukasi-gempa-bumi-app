import 'dart:math' as math;
import 'package:flutter/material.dart';

enum TurtleExpression { happy, alert, proud }

// Alias for backwards compatibility with previous Kiki references
typedef KikiExpression = TurtleExpression;

class TurtlePainter extends CustomPainter {
  final TurtleExpression expression;

  const TurtlePainter({this.expression = TurtleExpression.happy});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width, size.height);
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(s / 100, s / 100);

    // Palet warna Kura-kura Siaga
    const Color skinLight = Color(0xFFA5D6A7);
    const Color skinBase = Color(0xFF66BB6A);
    const Color skinDark = Color(0xFF388E3C);
    const Color shellRim = Color(0xFF81C784);
    const Color shellBase = Color(0xFF2E7D32);
    const Color shellDark = Color(0xFF1B5E20);
    const Color shellScute = Color(0xFF43A047);
    const Color yellowHelmet = Color(0xFFFFCA28);
    const Color yellowHelmetDark = Color(0xFFFFA000);
    const Color blushColor = Color(0xFFFF8A80);
    const Color eyeDark = Color(0xFF1A2332);

    final tailPath = Path()
      ..moveTo(-4, 38)
      ..lineTo(0, 47)
      ..lineTo(4, 38)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = skinBase);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-28, 28), width: 16, height: 13),
      Paint()..color = skinBase,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(28, 28), width: 16, height: 13),
      Paint()..color = skinBase,
    );
    final clawPaint = Paint()
      ..color = skinDark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-32, 33), const Offset(-30, 35), clawPaint);
    canvas.drawLine(const Offset(-28, 34), const Offset(-27, 36), clawPaint);
    canvas.drawLine(const Offset(32, 33), const Offset(30, 35), clawPaint);
    canvas.drawLine(const Offset(28, 34), const Offset(27, 36), clawPaint);

    final shellRect =
        Rect.fromCenter(center: const Offset(0, 16), width: 68, height: 58);
    // Bayangan tepi tempurung
    canvas.drawOval(shellRect, Paint()..color = shellDark);
    // Tempurung luar
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 15), width: 64, height: 54),
      Paint()..color = shellBase,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 18), width: 62, height: 50),
      Paint()
        ..color = shellRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Corak Heksagonal Tempurung (Carapace Scutes)
    _drawScute(canvas, const Offset(0, 12), 10, shellScute, shellDark);
    _drawScute(canvas, const Offset(-15, 6), 7, shellScute, shellDark);
    _drawScute(canvas, const Offset(15, 6), 7, shellScute, shellDark);
    _drawScute(canvas, const Offset(-15, 22), 8, shellScute, shellDark);
    _drawScute(canvas, const Offset(15, 22), 8, shellScute, shellDark);
    _drawScute(canvas, const Offset(0, 27), 7, shellScute, shellDark);

    final leftFlipper = Path()
      ..moveTo(-26, 6)
      ..quadraticBezierTo(-40, 10, -36, 22)
      ..quadraticBezierTo(-30, 28, -20, 20)
      ..close();
    canvas.drawPath(leftFlipper, Paint()..color = skinBase);
    canvas.drawPath(
        leftFlipper,
        Paint()
          ..color = skinDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);

    final rightFlipper = Path()
      ..moveTo(26, 6)
      ..quadraticBezierTo(40, 10, 36, 22)
      ..quadraticBezierTo(30, 28, 20, 20)
      ..close();
    canvas.drawPath(rightFlipper, Paint()..color = skinBase);
    canvas.drawPath(
        rightFlipper,
        Paint()
          ..color = skinDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);

    final neckPath = Path()
      ..moveTo(-11, 4)
      ..lineTo(-9, -14)
      ..lineTo(9, -14)
      ..lineTo(11, 4)
      ..close();
    canvas.drawPath(neckPath, Paint()..color = skinBase);

    // Kepala bulat lembut
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -18), width: 38, height: 32),
      Paint()..color = skinLight,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -18), width: 38, height: 32),
      Paint()
        ..color = skinDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Pipi kemerahan (Blush)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-12, -13), width: 6, height: 4),
      Paint()..color = blushColor.withAlpha(160),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, -13), width: 6, height: 4),
      Paint()..color = blushColor.withAlpha(160),
    );

    // 6. Mata & Ekspresi Wajah
    if (expression == TurtleExpression.alert) {
      // Ekspresi Siaga / Gempa: Mata membulat kaget
      canvas.drawCircle(
          const Offset(-8, -19), 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(8, -19), 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(-8, -19),
          6.5,
          Paint()
            ..color = eyeDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      canvas.drawCircle(
          const Offset(8, -19),
          6.5,
          Paint()
            ..color = eyeDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);

      // Pupil kaget
      canvas.drawCircle(const Offset(-8, -19), 3.5, Paint()..color = eyeDark);
      canvas.drawCircle(const Offset(8, -19), 3.5, Paint()..color = eyeDark);
      canvas.drawCircle(
          const Offset(-6.5, -20.5), 1.2, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(9.5, -20.5), 1.2, Paint()..color = Colors.white);

      // Mulut "O" kaget
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -11), width: 5.5, height: 7),
        Paint()..color = const Color(0xFFC4400E),
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -11), width: 5.5, height: 7),
        Paint()
          ..color = eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Tetesan keringat siaga di pelipis kanan
      final sweatPath = Path()
        ..moveTo(16, -26)
        ..quadraticBezierTo(20, -22, 18, -18)
        ..quadraticBezierTo(14, -18, 16, -26)
        ..close();
      canvas.drawPath(sweatPath, Paint()..color = const Color(0xFF4FC3F7));
      canvas.drawPath(
          sweatPath,
          Paint()
            ..color = const Color(0xFF0288D1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
    } else if (expression == TurtleExpression.proud) {
      // Ekspresi Bangga: Mata tersenyum melengkung bahagia (^_^)
      final smileEye = Paint()
        ..color = eyeDark
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final leftEyePath = Path()
        ..moveTo(-13, -17)
        ..quadraticBezierTo(-8, -23, -3, -17);
      canvas.drawPath(leftEyePath, smileEye);

      final rightEyePath = Path()
        ..moveTo(3, -17)
        ..quadraticBezierTo(8, -23, 13, -17);
      canvas.drawPath(rightEyePath, smileEye);

      // Senyum lebar ceria
      final mouthPath = Path()
        ..moveTo(-6, -12)
        ..quadraticBezierTo(0, -7, 6, -12);
      canvas.drawPath(mouthPath, smileEye);

      // Lidah kecil ceria
      final tonguePath = Path()
        ..moveTo(-3, -10)
        ..quadraticBezierTo(0, -6, 3, -10)
        ..close();
      canvas.drawPath(tonguePath, Paint()..color = const Color(0xFFFF5252));
    } else {
      // Ekspresi Senang / Ramah (Default)
      // Mata kartun besar dengan kilau ganda
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-8, -19), width: 8, height: 10),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(8, -19), width: 8, height: 10),
        Paint()..color = Colors.white,
      );

      // Lingkar mata
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(-8, -19), width: 8, height: 10),
        Paint()
          ..color = eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(8, -19), width: 8, height: 10),
        Paint()
          ..color = eyeDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Pupil besar berkilau
      canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(-7.5, -18.5), width: 6, height: 7.5),
        Paint()..color = eyeDark,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(7.5, -18.5), width: 6, height: 7.5),
        Paint()..color = eyeDark,
      );

      // Kilau cahaya di mata (highlights)
      canvas.drawCircle(
          const Offset(-6.5, -20.5), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(-8.5, -17), 0.9, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(8.5, -20.5), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(6.5, -17), 0.9, Paint()..color = Colors.white);

      // Senyum manis
      final mouth = Paint()
        ..color = eyeDark
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final smile = Path()
        ..moveTo(-5, -12)
        ..quadraticBezierTo(0, -9, 5, -12);
      canvas.drawPath(smile, mouth);
    }

    // 7. Helm Keselamatan Kuning Siaga Bencana (Safety Helmet ⛑️)
    final helmetDome = Path()
      ..moveTo(-17, -27)
      ..cubicTo(-18, -42, 18, -42, 17, -27)
      ..close();
    canvas.drawPath(helmetDome, Paint()..color = yellowHelmet);
    canvas.drawPath(
        helmetDome,
        Paint()
          ..color = yellowHelmetDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);

    // Pinggiran helm (Brim)
    final brimPath = Path()
      ..moveTo(-21, -26)
      ..quadraticBezierTo(0, -29, 21, -26)
      ..quadraticBezierTo(21, -24, 19, -24)
      ..quadraticBezierTo(0, -26, -19, -24)
      ..close();
    canvas.drawPath(brimPath, Paint()..color = yellowHelmetDark);

    // Kilau helm atas
    final shinePath = Path()
      ..moveTo(-8, -38)
      ..quadraticBezierTo(-4, -40, 2, -38)
      ..quadraticBezierTo(-4, -37, -8, -38)
      ..close();
    canvas.drawPath(shinePath, Paint()..color = Colors.white.withAlpha(200));

    // Logo / Bintang Keselamatan di tengah helm
    canvas.drawCircle(const Offset(0, -32), 4.5, Paint()..color = Colors.white);
    final crossPaint = Paint()
      ..color = const Color(0xFFC4400E)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(const Offset(0, -35), const Offset(0, -29), crossPaint);
    canvas.drawLine(const Offset(-3, -32), const Offset(3, -32), crossPaint);

    // 8. Aksesoris Bintang saat Bangga (Proud)
    if (expression == TurtleExpression.proud) {
      canvas.drawCircle(
          const Offset(0, 16), 8, Paint()..color = const Color(0xFFFFD54F));
      canvas.drawCircle(
        const Offset(0, 16),
        8,
        Paint()
          ..color = const Color(0xFFF57F17)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // Simbol bintang kecil
      _drawMiniStar(canvas, const Offset(0, 16), 4.5, const Color(0xFFE65100));
    }

    canvas.restore();
  }

  void _drawScute(Canvas canvas, Offset center, double radius, Color fillColor,
      Color strokeColor) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor.withAlpha(140)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawMiniStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    const int points = 5;
    final inner = radius * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : inner;
      final angle = (i * 36) * math.pi / 180 - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant TurtlePainter oldDelegate) =>
      oldDelegate.expression != expression;
}

// Typedef alias for KikiPainter so existing references seamlessly resolve to Turtle
typedef KikiPainter = TurtlePainter;

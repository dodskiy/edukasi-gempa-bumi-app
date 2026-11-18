import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/emergency_data.dart';

class _KidColors {
  static const skyLight = Color(0xFFE6F1FB);
  static const skyMid = Color(0xFFB5D4F4);
  static const skyBorder = Color(0xFF85B7EB);
  static const blueMain = Color(0xFF378ADD);
  static const blueDark = Color(0xFF185FA5);
  static const blueDarkest = Color(0xFF042C53);
  static const white = Colors.white;
}

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isSirenActive = false;
  Timer? _sirenFlashTimer;
  bool _flashColorState = false;

  void _toggleSiren() {
    setState(() {
      _isSirenActive = !_isSirenActive;
    });

    if (_isSirenActive) {
      HapticFeedback.heavyImpact();
      _sirenFlashTimer =
          Timer.periodic(const Duration(milliseconds: 350), (timer) {
        if (!mounted) return;
        setState(() {
          _flashColorState = !_flashColorState;
        });
        HapticFeedback.vibrate();
      });
    } else {
      _sirenFlashTimer?.cancel();
      _flashColorState = false;
    }
  }

  @override
  void dispose() {
    _sirenFlashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _KidColors.white,
      appBar: AppBar(
        title: const Text('Sahabat Siaga'),
        backgroundColor: _KidColors.blueMain,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---------------- HEADER MASKOT ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: _KidColors.skyLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const _HeroMascot(size: 92),
                const SizedBox(height: 10),
                const Text(
                  'Halo, aku Sahabat Siaga!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _KidColors.blueDarkest,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Aku bantu kamu belajar aman, ya',
                  style: TextStyle(fontSize: 12.5, color: _KidColors.blueDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---------------- KARTU LATIHAN SIRENE ----------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isSirenActive
                  ? (_flashColorState ? _KidColors.skyMid : _KidColors.skyLight)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _KidColors.skyBorder, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _KidColors.skyLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: _KidColors.skyMid, width: 1.5),
                  ),
                  child: Icon(
                    _isSirenActive
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 34,
                    color: _KidColors.blueDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isSirenActive
                      ? 'Sirene latihan sedang bunyi!'
                      : 'Yuk latihan bunyi sirene',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _KidColors.blueDarkest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSirenActive
                      ? 'Ayo tiarap, lindungi kepala, dan berpegangan seperti latihan.'
                      : 'Tekan tombol biru ini kalau mau coba, ya!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5, color: _KidColors.blueDark, height: 1.4),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _toggleSiren,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isSirenActive ? Colors.white : _KidColors.blueMain,
                    foregroundColor:
                        _isSirenActive ? _KidColors.blueMain : Colors.white,
                    side: _isSirenActive
                        ? const BorderSide(
                            color: _KidColors.blueMain, width: 1.5)
                        : null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: Icon(_isSirenActive
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(
                      _isSirenActive ? 'Selesai latihan' : 'Coba sekarang'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Icon(Icons.favorite_rounded,
                  color: _KidColors.blueMain, size: 20),
              SizedBox(width: 8),
              Text(
                'Kalau butuh bantuan, hubungi',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _KidColors.blueDarkest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ---------------- LIST KONTAK (biru-putih) ----------------
          ...EmergencyData.contacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _KidColors.skyLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: _KidColors.skyBorder, width: 1.5),
                    ),
                    child: Icon(contact.icon,
                        color: _KidColors.blueDark, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: _KidColors.blueDarkest,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${contact.phoneNumber} (${contact.region})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _KidColors.blueDark,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          contact.description,
                          style: TextStyle(
                              fontSize: 11.5,
                              color:
                                  _KidColors.blueDark.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: _KidColors.skyBorder, width: 1.5),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: const Icon(Icons.copy_rounded,
                          color: _KidColors.blueDark),
                      tooltip: 'Salin nomor',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: contact.phoneNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Nomor ${contact.name} sudah disalin!'),
                            backgroundColor: _KidColors.blueMain,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeroMascot extends StatelessWidget {
  final double size;
  const _HeroMascot({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeroMascotPainter(),
      ),
    );
  }
}

class _HeroMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Jubah — bentuk membulat di belakang badan.
    final capePaint = Paint()..color = _KidColors.blueDark;
    final capePath = Path()
      ..moveTo(w * 0.28, h * 0.42)
      ..lineTo(w * 0.08, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 1.05, w * 0.92, h * 0.95)
      ..lineTo(w * 0.72, h * 0.42)
      ..close();
    canvas.drawPath(capePath, capePaint);

    // Badan — lingkaran biru utama.
    final badanPaint = Paint()..color = _KidColors.blueMain;
    canvas.drawCircle(center, w * 0.42, badanPaint);

    // Lencana bintang di dada.
    final starPaint = Paint()..color = Colors.white;
    final starPath = _buatBintang(
      pusat: Offset(center.dx, center.dy + h * 0.16),
      radiusLuar: w * 0.09,
      radiusDalam: w * 0.04,
    );
    canvas.drawPath(starPath, starPaint);

    // Wajah — lingkaran putih kecil sebagai dasar wajah.
    final wajahPaint = Paint()..color = Colors.white;
    final wajahCenter = Offset(center.dx, center.dy - h * 0.06);
    canvas.drawCircle(wajahCenter, w * 0.26, wajahPaint);

    // Mata — dua lingkaran kecil biru tua.
    final mataPaint = Paint()..color = _KidColors.blueDarkest;
    canvas.drawCircle(
        Offset(wajahCenter.dx - w * 0.09, wajahCenter.dy - h * 0.02),
        w * 0.028,
        mataPaint);
    canvas.drawCircle(
        Offset(wajahCenter.dx + w * 0.09, wajahCenter.dy - h * 0.02),
        w * 0.028,
        mataPaint);

    // Senyum — busur sederhana.
    final senyumPaint = Paint()
      ..color = _KidColors.blueDarkest
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    final senyumRect = Rect.fromCenter(
      center: Offset(wajahCenter.dx, wajahCenter.dy + h * 0.02),
      width: w * 0.22,
      height: w * 0.18,
    );
    canvas.drawArc(senyumRect, 0.25, 2.6, false, senyumPaint);

    // Pipi merona — dua lingkaran tipis transparan.
    final pipiPaint = Paint()
      ..color = const Color(0xFFF0997B).withValues(alpha: 0.5);
    canvas.drawCircle(
        Offset(wajahCenter.dx - w * 0.17, wajahCenter.dy + h * 0.05),
        w * 0.035,
        pipiPaint);
    canvas.drawCircle(
        Offset(wajahCenter.dx + w * 0.17, wajahCenter.dy + h * 0.05),
        w * 0.035,
        pipiPaint);
  }

  /// Menggambar bentuk bintang lima titik menggunakan dart:math untuk
  /// menghitung posisi tiap sudutnya.
  Path _buatBintang({
    required Offset pusat,
    required double radiusLuar,
    required double radiusDalam,
  }) {
    const jumlahSudut = 5;
    final path = Path();
    for (int i = 0; i < jumlahSudut * 2; i++) {
      final radius = i.isEven ? radiusLuar : radiusDalam;
      final sudut = (i * math.pi) / jumlahSudut - math.pi / 2;
      final titik = Offset(
        pusat.dx + radius * math.cos(sudut),
        pusat.dy + radius * math.sin(sudut),
      );
      if (i == 0) {
        path.moveTo(titik.dx, titik.dy);
      } else {
        path.lineTo(titik.dx, titik.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _HeroMascotPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/earthquake_quiz_data.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_palette.dart';
import '../../widgets/turtle_painter.dart';

enum EarthquakeQuizMode { preTest, postTest }

class EarthquakeQuizResult {
  final int correct;
  final int total;

  const EarthquakeQuizResult({required this.correct, required this.total});

  int get percent => total == 0 ? 0 : ((correct / total) * 100).round();
}

/// Pre-Test dan Post-Test simulasi gempa.
///
/// Tampilannya memakai bahasa desain yang sama dengan kuis lain:
/// kartu putih berbingkai, badge huruf A/B/C, warna langit, dan
/// maskot Kura Siaga. Tidak ada bintang penilaian; hasil ditampilkan
/// sebagai jumlah jawaban benar dan persentase.
class EarthquakeQuizScreen extends StatefulWidget {
  final EarthquakeQuizMode mode;

  /// Jumlah jawaban benar pada pre-test (untuk layar hasil post-test).
  final int preTestCorrect;

  const EarthquakeQuizScreen({
    super.key,
    required this.mode,
    this.preTestCorrect = 0,
  });

  @override
  State<EarthquakeQuizScreen> createState() => _EarthquakeQuizScreenState();
}

class _EarthquakeQuizScreenState extends State<EarthquakeQuizScreen> {
  static const List<IconData> _preIcons = [
    Icons.arrow_downward_rounded,
    Icons.table_restaurant_rounded,
    Icons.pan_tool_rounded,
    Icons.format_list_numbered_rounded,
    Icons.window_rounded,
  ];

  static const List<IconData> _postIcons = [
    Icons.vibration_rounded,
    Icons.table_restaurant_rounded,
    Icons.pan_tool_rounded,
    Icons.format_list_numbered_rounded,
    Icons.window_rounded,
  ];

  late final List<QuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correct = 0;
  bool _finished = false;

  bool get _isPost => widget.mode == EarthquakeQuizMode.postTest;
  Color get _accent => _isPost ? AppPalette.mintDeep : AppPalette.coralDeep;
  Color get _accentDeep => _isPost ? AppPalette.forest : AppPalette.coralDark;
  Color get _accentSoft =>
      _isPost ? const Color(0xFFE9FBF1) : AppPalette.coralSoft;
  LinearGradient get _accentGradient =>
      _isPost ? AppPalette.mintGradient : AppPalette.coralGradient;

  int get _total => _questions.length;
  int get _percent => _total == 0 ? 0 : ((_correct / _total) * 100).round();
  int get _prePercent => _total == 0
      ? 0
      : ((widget.preTestCorrect.clamp(0, _total) / _total) * 100).round();

  @override
  void initState() {
    super.initState();
    _questions =
        _isPost ? EarthquakeQuizData.postTest : EarthquakeQuizData.preTest;
  }

  IconData _iconFor(int index) {
    final icons = _isPost ? _postIcons : _preIcons;
    return icons[index % icons.length];
  }

  void _selectOption(int index) {
    if (_isPost && _answered) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selected = index;
      if (_isPost) {
        _answered = true;
        if (index == _questions[_index].correctOptionIndex) {
          _correct++;
        }
      }
    });
  }

  void _next() {
    if (_selected == null) return;
    HapticFeedback.mediumImpact();

    if (!_isPost) {
      if (_selected == _questions[_index].correctOptionIndex) {
        _correct++;
      }
    }

    if (_index >= _total - 1) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _finish() {
    Navigator.of(context).pop(
      EarthquakeQuizResult(correct: _correct, total: _total),
    );
  }

  void _restart() {
    setState(() {
      _index = 0;
      _selected = null;
      _answered = false;
      _correct = 0;
      _finished = false;
    });
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
            color: AppPalette.cream,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                    child: _finished ? _buildResult() : _buildQuestionPage(),
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
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3331355A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop(
                  EarthquakeQuizResult(correct: 0, total: _total),
                );
              },
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
          const SizedBox(width: 11),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.6,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              _isPost ? Icons.verified_rounded : Icons.assignment_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPost ? 'Post-Test' : 'Pre-Test',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _isPost
                      ? 'Uji pemahaman setelah bermain'
                      : 'Cek pengetahuan awalmu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE6F8FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '$_total SOAL',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HALAMAN SOAL =================
  Widget _buildQuestionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        _buildProgressCard(),
        const SizedBox(height: 14),
        _buildQuestionCard(),
        if (_isPost && _answered) ...[
          const SizedBox(height: 12),
          _buildExplanation(),
        ],
        const SizedBox(height: 14),
        _buildActionButton(),
        if (!_isPost) ...[
          const SizedBox(height: 10),
          const Text(
            'Jawab dengan jujur, ya. Skor pre-test tidak memengaruhi nilai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppPalette.inkSoft,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _buildKuraTip(),
      ],
    );
  }

  Widget _buildKuraTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.lineBorder, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: _accent.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: const CustomPaint(
              painter: TurtlePainter(expression: TurtleExpression.happy),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kata Kura Siaga',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _accentDeep,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _isPost
                      ? 'Baca penjelasan setelah menjawab. Itu membuatmu makin paham.'
                      : 'Ketuk satu jawaban, lalu tekan LANJUT. Tidak perlu takut salah, ya!',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.navy,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.lineBorder, width: 2.4),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow3D,
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _isPost ? Icons.flag_rounded : Icons.explore_rounded,
                  size: 17,
                  color: _accentDeep,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Soal ${_index + 1} dari $_total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.navy,
                  ),
                ),
              ),
              if (_isPost)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Benar: $_correct',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _accentDeep,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_total, (i) {
              final bool done = i < (_finished ? _total : _index);
              final bool current = i == _index && !_finished;
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i == _total - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: done
                        ? _accent
                        : current
                            ? AppPalette.sunny
                            : AppPalette.lineBorder,
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

  Widget _buildQuestionCard() {
    final question = _questions[_index];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow3D,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: _accentGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(_iconFor(_index), size: 22, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOAL ${_index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.inkSoft,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _isPost ? 'POST-TEST' : 'PRE-TEST',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: _accentDeep,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w900,
              color: AppPalette.navy,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(question.options.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == question.options.length - 1 ? 0 : 9,
              ),
              child: _buildOption(question, i),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOption(QuizQuestion question, int i) {
    final bool isCorrect = i == question.correctOptionIndex;
    final bool isSelected = _selected == i;
    final bool reveal = _isPost && _answered;

    Color bg = Colors.white;
    Color border = AppPalette.lineBorder;
    Color letterBg = AppPalette.skyMist;
    Color letterFg = AppPalette.skyDeep;
    Color textColor = AppPalette.navy;
    IconData? trailing;
    Color? trailingColor;

    if (reveal && isCorrect) {
      bg = const Color(0xFFE8FBF1);
      border = AppPalette.mintDeep;
      letterBg = AppPalette.mintDeep;
      letterFg = Colors.white;
      trailing = Icons.check_circle_rounded;
      trailingColor = AppPalette.mintDeep;
    } else if (reveal && isSelected) {
      bg = AppPalette.coralSoft;
      border = AppPalette.coralDeep;
      letterBg = AppPalette.coralDeep;
      letterFg = Colors.white;
      trailing = Icons.cancel_rounded;
      trailingColor = AppPalette.coralDeep;
    } else if (reveal) {
      bg = Colors.white;
      border = AppPalette.lineBorder;
      textColor = AppPalette.inkSoft;
      letterFg = AppPalette.inkSoft;
    } else if (isSelected) {
      bg = AppPalette.skyMist;
      border = AppPalette.skyDeep;
      letterBg = AppPalette.skyDeep;
      letterFg = Colors.white;
    }

    final double opacity = reveal && !isCorrect && !isSelected ? 0.6 : 1;

    return Opacity(
      opacity: opacity,
      child: Material(
        key: ValueKey('quiz-option-$i'),
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _selectOption(i),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: border,
                width: isSelected || (reveal && isCorrect) ? 2.2 : 1.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    String.fromCharCode(65 + i),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: letterFg,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.options[i],
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: isSelected || (reveal && isCorrect)
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  Icon(trailing, size: 21, color: trailingColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    final question = _questions[_index];
    final bool isCorrect = _selected == question.correctOptionIndex;
    final String correctLetter =
        String.fromCharCode(65 + question.correctOptionIndex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE8FBF1) : AppPalette.coralSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? AppPalette.mint : AppPalette.coral,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCorrect ? AppPalette.mintDeep : AppPalette.coralDeep,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.lightbulb_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect ? 'Tepat sekali!' : 'Belum tepat, tidak apa-apa!',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isCorrect ? AppPalette.forest : AppPalette.coralDark,
                  ),
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 7),
            Text(
              'Jawaban benar: $correctLetter. '
              '${question.options[question.correctOptionIndex]}',
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                fontWeight: FontWeight.w800,
                color: AppPalette.forest,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 12.8,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: AppPalette.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final bool isLast = _index == _total - 1;
    final String label;
    final bool enabled;

    if (_isPost) {
      enabled = _answered;
      if (!_answered) {
        label = 'PILIH JAWABAN DULU';
      } else {
        label = isLast ? 'LIHAT HASIL POST-TEST' : 'SOAL BERIKUTNYA';
      }
    } else {
      enabled = _selected != null;
      label = isLast ? 'SELESAI PRE-TEST' : 'LANJUT';
    }

    return Container(
      key: const ValueKey('quiz-action'),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: enabled ? _accentGradient : null,
        color: enabled ? null : AppPalette.lineBorder,
        borderRadius: BorderRadius.circular(18),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _accentDeep,
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? _next : null,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color: enabled ? Colors.white : AppPalette.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                  size: 19,
                  color: enabled ? Colors.white : AppPalette.inkSoft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HALAMAN HASIL =================
  Widget _buildResult() {
    final String title = _percent >= 80
        ? 'Luar biasa!'
        : (_percent >= 60 ? 'Bagus sekali!' : 'Ayo terus belajar!');

    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _accentSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withValues(alpha: 0.35)),
          ),
          child: Text(
            _isPost ? 'HASIL POST-TEST' : 'HASIL PRE-TEST',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: _accentDeep,
              letterSpacing: 0.9,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppPalette.lineBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppPalette.shadow3D,
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _accentGradient,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _accentDeep.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_percent%',
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$_correct / $_total benar',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xEEFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppPalette.sunny,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Kamu menjawab $_correct dari $_total soal dengan benar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.inkSoft,
                ),
              ),
              const SizedBox(height: 14),
              _buildAnswerDots(),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _percent / 100,
                  minHeight: 9,
                  backgroundColor: AppPalette.lineBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppPalette.mintDeep,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Benar $_correct',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.navy,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cancel_rounded,
                        size: 14,
                        color: AppPalette.coralDeep,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Salah ${_total - _correct}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.navy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_isPost) _buildComparisonCard() else _buildPreTestNote(),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _finish,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: _accentGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _accentDeep,
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPost
                      ? Icons.check_circle_rounded
                      : Icons.play_arrow_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 7),
                Text(
                  _isPost ? 'SELESAI' : 'MULAI BERMAIN',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isPost) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _restart,
            child: const Text(
              'Coba lagi post-test',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppPalette.skyDeep,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Deretan bulatan jawaban. Menggantikan bintang penilaian.
  Widget _buildAnswerDots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(_total, (i) {
        final bool filled = i < _correct;
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: filled ? _accentSoft : AppPalette.cream,
            shape: BoxShape.circle,
            border: Border.all(
              color: filled ? _accent : AppPalette.lineBorder,
              width: 1.8,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            filled ? Icons.check_rounded : Icons.remove_rounded,
            size: 14,
            color: filled ? _accentDeep : AppPalette.inkSoft,
          ),
        );
      }),
    );
  }

  Widget _buildPreTestNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: AppPalette.sunnySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.sunny, width: 2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            size: 20,
            color: AppPalette.sunnyDeep,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Simpan skor ini sebagai titik awalmu. Setelah menamatkan 3 level '
              'simulasi, kamu akan mengerjakan post-test untuk melihat '
              'kemajuanmu.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: AppPalette.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    final int delta = _percent - _prePercent;
    final bool improved = delta > 0;
    final bool same = delta == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.lineBorder, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow3D,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 18,
                color: AppPalette.navy,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'PERBANDINGAN SKOR',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.navy,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (improved ? AppPalette.mintDeep : AppPalette.coralDeep)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  same ? 'SAMA' : (improved ? '+$delta%' : '$delta%'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color:
                        improved ? AppPalette.mintDeep : AppPalette.coralDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScoreBar('Pre-Test', _prePercent, AppPalette.coralDeep),
          const SizedBox(height: 8),
          _buildScoreBar('Post-Test', _percent, AppPalette.mintDeep),
          const SizedBox(height: 10),
          Text(
            improved
                ? 'Pemahamanmu naik $delta% setelah bermain simulasi. '
                    'Pertahankan, ya!'
                : same
                    ? 'Skormu sama dengan pre-test. Baca lagi langkah Drop, '
                        'Cover, Hold On supaya makin paham.'
                    : 'Skor post-test sedikit turun. Tidak apa-apa, coba ulangi '
                        'simulasi lalu post-test sekali lagi.',
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppPalette.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppPalette.navy,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              color: AppPalette.lineBorder.withValues(alpha: 0.7),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.lerp(color, Colors.white, 0.3)!, color],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

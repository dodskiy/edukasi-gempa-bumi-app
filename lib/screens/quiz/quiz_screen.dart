import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/quiz_data.dart';
import '../../data/user_progress_manager.dart';
import '../../models/quiz_model.dart';
import '../../theme/app_palette.dart';
import '../../widgets/turtle_painter.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _pointsPerCorrect = 10;
  static const List<IconData> _badgeIcons = [
    Icons.emoji_events_rounded,
    Icons.military_tech_rounded,
    Icons.workspace_premium_rounded,
    Icons.thumb_up_alt_rounded,
  ];

  static final RegExp _emojiPattern = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}]',
    unicode: true,
  );

  String _clean(String text) => text.replaceAll(_emojiPattern, '').trim();

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _showHint = false;

  String _siagaMessage =
      'Baca soal dengan teliti, lalu pilih jawaban yang paling tepat.';

  void _answerQuestion(int index) {
    if (_isAnswered) return;

    final question = QuizData.questions[_currentIndex];
    final bool isCorrect = index == question.correctOptionIndex;

    HapticFeedback.lightImpact();
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score += _pointsPerCorrect;
        _siagaMessage =
            'Benar! Jawabanmu tepat (+$_pointsPerCorrect poin aktivitas).';
      } else {
        _siagaMessage =
            'Belum tepat. Jawaban yang benar sudah ditandai warna hijau.';
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < QuizData.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
        _showHint = false;
        _siagaMessage = 'Soal baru! Baca dengan teliti sebelum menjawab.';
      });
    } else {
      _showResultDialog();
    }
  }

  QuizBadge _getBadge(int finalScore) {
    for (var b in QuizData.badges) {
      if (finalScore >= b.minScore) return b;
    }
    return QuizData.badges.last;
  }

  IconData _badgeIcon(QuizBadge badge) {
    final index = QuizData.badges.indexOf(badge);
    if (index < 0) return _badgeIcons.first;
    if (index >= _badgeIcons.length) return _badgeIcons.last;
    return _badgeIcons[index];
  }

  void _showResultDialog() {
    final int maxScore = QuizData.questions.length * _pointsPerCorrect;
    UserProgressManager().completeQuiz(score: _score, maxScore: maxScore);
    final int percent = maxScore == 0 ? 0 : ((_score / maxScore) * 100).round();
    final badge = _getBadge(percent);
    final int correctCount = _score ~/ _pointsPerCorrect;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppPalette.cream,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: AppPalette.sunnyGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.sunnyDeep.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _badgeIcon(badge),
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _clean(badge.title),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.navy,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _clean(badge.description),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.inkSoft,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppPalette.lineBorder,
                      width: 2.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: AppPalette.sunnyDeep,
                            size: 30,
                          ),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 34,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              color: AppPalette.sunnyDeep,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 3),
                            child: Text(
                              '/ $maxScore poin',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8A6300),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _score / maxScore,
                          minHeight: 8,
                          backgroundColor: AppPalette.lineBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppPalette.mintDeep,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Benar $correctCount dari ${QuizData.questions.length} soal',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(
                            color: AppPalette.lineBorder,
                            width: 1.8,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppPalette.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.skyDeep,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _currentIndex = 0;
                            _score = 0;
                            _selectedOptionIndex = null;
                            _isAnswered = false;
                            _showHint = false;
                            _siagaMessage =
                                'Kuis dimulai lagi. Semoga poinmu makin tinggi!';
                          });
                        },
                        child: const Text(
                          'Ulangi',
                          style: TextStyle(
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
  Widget build(BuildContext context) {
    final question = QuizData.questions[_currentIndex];
    final int total = QuizData.questions.length;

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
                _buildTopBar(total),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMissionBanner(total),
                        const SizedBox(height: 14),
                        _buildQuestionCard(question),
                        const SizedBox(height: 12),
                        const Text(
                          'Pilih jawabanmu:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.navy,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ...List.generate(question.options.length, (index) {
                          return _buildOptionCard(question, index);
                        }),
                        if (_isAnswered) ...[
                          const SizedBox(height: 2),
                          _buildFeedbackCard(question),
                          const SizedBox(height: 12),
                          _buildNextButton(total),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildSiagaAssistant(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int total) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3331355A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOAL ${_currentIndex + 1} DARI $total',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFDDF4FF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const Text(
                  'Kuis Siaga Gempa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                  color: AppPalette.sunny,
                  size: 15,
                ),
                const SizedBox(width: 3),
                Text(
                  '$_score',
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

  Widget _buildMissionBanner(int total) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.grape, AppPalette.grapeDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppPalette.grapeDeep.withValues(alpha: 0.5),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: const CustomPaint(
                  painter: TurtlePainter(expression: TurtleExpression.happy),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Misi Kuis Siaga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Jawab tepat, kumpulkan poin aktivitas, dan buka lencana!',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFF1ECFF),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/$total',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.grapeDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_currentIndex + (_isAnswered ? 1 : 0)) / total,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppPalette.sunny,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.skyMist,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Soal ${_currentIndex + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.skyDeep,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showHint = !_showHint),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.sunnySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 15,
                        color: AppPalette.sunnyDeep,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Petunjuk',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8A6300),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showHint) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppPalette.sunnySoft.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppPalette.sunny.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    size: 17,
                    color: AppPalette.sunnyDeep,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _clean(question.hint),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Color(0xFF7A5600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _clean(question.question),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppPalette.navy,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(QuizQuestion question, int index) {
    final bool isSelected = _selectedOptionIndex == index;
    final bool isCorrect = index == question.correctOptionIndex;

    Color borderColor = AppPalette.lineBorder;
    double borderWidth = 2;
    Color shadowColor = AppPalette.shadow3D;
    Color badgeBg = AppPalette.skyMist;
    Color badgeText = AppPalette.skyDeep;
    IconData? trailingIcon;
    Color? trailingColor;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = AppPalette.mintDeep;
        borderWidth = 2.4;
        shadowColor = const Color(0xFFC8EFDA);
        badgeBg = AppPalette.mintDeep;
        badgeText = Colors.white;
        trailingIcon = Icons.check_circle_rounded;
        trailingColor = AppPalette.mintDeep;
      } else if (isSelected) {
        borderColor = AppPalette.coralDeep;
        borderWidth = 2.4;
        shadowColor = const Color(0xFFF7CFC8);
        badgeBg = AppPalette.coralDeep;
        badgeText = Colors.white;
        trailingIcon = Icons.cancel_rounded;
        trailingColor = AppPalette.coralDeep;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _isAnswered ? null : () => _answerQuestion(index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: borderWidth),
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
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _clean(question.options[index]),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.navy,
                    height: 1.45,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 5),
                Icon(trailingIcon, color: trailingColor, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(QuizQuestion question) {
    final bool isCorrect = _selectedOptionIndex == question.correctOptionIndex;
    final String correctLetter =
        String.fromCharCode(65 + question.correctOptionIndex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE9FBF1) : AppPalette.coralSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? AppPalette.mintDeep : AppPalette.coralDeep,
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
                    color:
                        isCorrect ? AppPalette.mintDeep : AppPalette.coralDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isCorrect
                ? _clean(question.explanation)
                : 'Jawaban benar: $correctLetter. '
                    '${_clean(question.explanation)}',
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              color: AppPalette.navy,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(int total) {
    final bool isLast = _currentIndex == total - 1;
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _nextQuestion,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient:
                isLast ? AppPalette.mintGradient : AppPalette.headerGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isLast ? AppPalette.forest : AppPalette.skyDeep,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Lihat Poin & Lencana' : 'Soal Berikutnya',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                isLast
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                size: 19,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiagaAssistant() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.lineBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow3D,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.skyMist,
              shape: BoxShape.circle,
              border: Border.all(color: AppPalette.skySoft, width: 1.5),
            ),
            padding: const EdgeInsets.all(4),
            child: CustomPaint(
              painter: TurtlePainter(
                expression: _isAnswered
                    ? TurtleExpression.happy
                    : TurtleExpression.alert,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kura Siaga:',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.skyDeep,
                  ),
                ),
                Text(
                  _siagaMessage,
                  style: const TextStyle(
                    fontSize: 12.2,
                    fontWeight: FontWeight.w700,
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/user_progress_manager.dart';
import '../../models/education_model.dart';
import '../../theme/app_palette.dart';

class EducationDetailScreen extends StatefulWidget {
  final EducationTopic topic;

  const EducationDetailScreen({super.key, required this.topic});

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final UserProgressManager _progress = UserProgressManager();

  int _readPercent = 0;

  @override
  void initState() {
    super.initState();
    _readPercent = _progress.moduleReadPercent(widget.topic.id);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFitsScreen());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Jika materi pendek dan tidak perlu digulir, anggap selesai dibaca.
  void _checkFitsScreen() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0) {
      _updateProgress(100);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      _updateProgress(100);
      return;
    }
    final int percent =
        ((_scrollController.offset / maxExtent) * 100).round().clamp(0, 100);
    _updateProgress(percent);
  }

  void _updateProgress(int percent) {
    if (!mounted || percent <= _readPercent) return;

    final int gained =
        _progress.updateModuleReadProgress(widget.topic.id, percent);
    setState(() => _readPercent = percent);

    if (gained > 0) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.mintDeep,
          duration: const Duration(milliseconds: 1500),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '+$gained poin aktivitas! Terus baca, makin jago siaga.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = _readPercent >= 100;

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
                _buildProgressStrip(),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('education-detail-scroll'),
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 14),
                        _buildMalutContextCard(),
                        const SizedBox(height: 14),
                        _buildKeyPointsCard(),
                        const SizedBox(height: 14),
                        _buildFullContentCard(),
                        if (widget.topic.remember.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildRememberCard(),
                        ],
                        const SizedBox(height: 14),
                        _buildDoDontCard(),
                        const SizedBox(height: 16),
                        if (isComplete)
                          _buildCompletionCard()
                        else
                          _buildReadingReminder(),
                        const SizedBox(height: 10),
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

  Widget _buildTopBar() {
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFDDF4FF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  widget.topic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
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
                  '${_progress.activityPoints}',
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

  Widget _buildProgressStrip() {
    final int modulePoints = _progress.moduleActivityPoints(widget.topic.id);
    final bool isComplete = _readPercent >= 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppPalette.lineBorder, width: 2.2),
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
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppPalette.sunnySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 17,
                    color: AppPalette.sunnyDeep,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Poin Aktivitas Modul',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.navy,
                    ),
                  ),
                ),
                Text(
                  '$modulePoints / 20 poin',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color:
                        isComplete ? AppPalette.mintDeep : AppPalette.sunnyDeep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _readPercent / 100,
                minHeight: 8,
                backgroundColor: AppPalette.lineBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppPalette.mintDeep : AppPalette.skyDeep,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Progres baca $_readPercent%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isComplete ? 'Selesai' : 'Baca sampai bawah',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color:
                          isComplete ? AppPalette.mintDeep : AppPalette.skyDeep,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final Color topicColor = widget.topic.color;
    final Color topicDeep = Color.lerp(topicColor, AppPalette.navy, 0.32)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topicColor, topicDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: topicDeep.withValues(alpha: 0.45),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -10,
            right: 4,
            child: Icon(
              Icons.public_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(widget.topic.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topic.shortDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: topicDeep.withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: AppPalette.sunnyDeep,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '+20 poin aktivitas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: topicDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMalutContextCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.skyMist,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppPalette.skySoft,
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AppPalette.skyDeep,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Khas Maluku Utara',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppPalette.skyDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            widget.topic.malukuUtaraContext,
            style: const TextStyle(
              fontSize: 13.3,
              color: AppPalette.navy,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsCard() {
    final Color topicColor = widget.topic.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            children: [
              _buildSectionIcon(Icons.lightbulb_rounded, topicColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Poin Penting',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.topic.keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: topicColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: topicColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: topicColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppPalette.navy,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionIcon(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 19, color: color),
    );
  }

  Widget _buildFullContentCard() {
    final Color topicColor = widget.topic.color;
    final List<String> paragraphs = widget.topic.fullContent
        .split('\n\n')
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            children: [
              _buildSectionIcon(Icons.menu_book_rounded, topicColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Baca Pelan-Pelan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...paragraphs.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == paragraphs.length - 1 ? 0 : 12,
              ),
              child: Text(
                entry.value.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppPalette.navy,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRememberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.sunnySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppPalette.sunny.withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF3E2B3),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppPalette.sunny,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.push_pin_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingat, ya!',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8A6300),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.topic.remember,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A5600),
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoDontCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppPalette.sunnySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPalette.sunny.withValues(alpha: 0.7),
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF3E2B3),
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
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppPalette.sunny,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Boleh & Dilarang',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A6300),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.topic.doAndDonts.map((action) {
            final bool isDont = action.toUpperCase().startsWith('JANGAN');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isDont ? Icons.cancel_rounded : Icons.check_circle_rounded,
                    size: 16,
                    color: isDont ? AppPalette.coralDeep : AppPalette.mintDeep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A5600),
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
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

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FBF1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.mintDeep, width: 2.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC8EFDA),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppPalette.mintDeep,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Modul Selesai Dibaca!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppPalette.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kamu sudah mengumpulkan 20 poin aktivitas dari modul ini. '
            'Lanjutkan modul lain atau tonton video edukasi!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.8,
              color: AppPalette.inkSoft,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: AppPalette.mintGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppPalette.forest,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Kembali ke Daftar Modul',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppPalette.skyMist,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.skySoft, width: 1.8),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 20,
            color: AppPalette.skyDeep,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Terus gulir sampai bawah. Setiap tahap bacaan memberi poin '
              'aktivitas tambahan hingga total 20 poin!',
              style: TextStyle(
                fontSize: 11.5,
                color: AppPalette.navy,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

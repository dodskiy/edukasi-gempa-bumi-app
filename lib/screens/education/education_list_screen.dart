import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/education_data.dart';
import '../../data/user_progress_manager.dart';
import '../../models/education_model.dart';
import '../../theme/app_palette.dart';
import '../home_screen.dart' show KikiPainter, KikiExpression;
import 'education_detail_screen.dart';
import 'video_list_screen.dart';

class EducationListScreen extends StatefulWidget {
  const EducationListScreen({super.key});

  @override
  State<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends State<EducationListScreen>
    with SingleTickerProviderStateMixin {
  final UserProgressManager _progress = UserProgressManager();

  late AnimationController _liveController;
  late Animation<double> _bounceOffset;
  late Animation<double> _pulseScale;
  late Animation<double> _twinkle;

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

  void _onProgressUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserProgressManager.progressNotifier.removeListener(_onProgressUpdated);
    _liveController.dispose();
    super.dispose();
  }

  EducationTopic _getTopicById(String id) {
    return EducationData.topics.firstWhere(
      (t) => t.id == id,
      orElse: () => EducationData.topics.first,
    );
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
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroBanner(),
                        const SizedBox(height: 14),
                        _buildActivitySummary(),
                        const SizedBox(height: 14),
                        _buildVideoPromoBanner(context),
                        const SizedBox(height: 18),
                        _buildSectionHeader(),
                        const SizedBox(height: 12),
                        _buildArticleCard(
                          context: context,
                          isNew: true,
                          icon: Icons.public_rounded,
                          iconGradient: const [
                            Color(0xFFE0F2FE),
                            Color(0xFFBAE6FD),
                          ],
                          tagText: 'Kenali Daerahmu',
                          tagColor: const Color(0xFF0284C7),
                          tagBg: const Color(0xFFE0F2FE),
                          title: 'Kenapa Maluku Utara Sering Gempa?',
                          description:
                              'Maluku Utara berada di antara tiga lempeng bumi yang besar.',
                          readTime: '3 menit baca',
                          topic: _getTopicById('malut_geology'),
                        ),
                        _buildArticleCard(
                          context: context,
                          isNew: false,
                          icon: Icons.security_rounded,
                          iconGradient: const [
                            Color(0xFFFFF3D0),
                            Color(0xFFFFE7A8),
                          ],
                          tagText: 'Langkah Cepat',
                          tagColor: const Color(0xFF8A6300),
                          tagBg: const Color(0xFFFFF3D0),
                          title: 'Saat Gempa: Drop, Cover, Hold On',
                          description:
                              'Merunduk, berlindung, lalu berpegangan erat.',
                          readTime: '2 menit baca',
                          topic: _getTopicById('saat_gempa'),
                        ),
                        _buildArticleCard(
                          context: context,
                          isNew: false,
                          icon: Icons.home_repair_service_rounded,
                          iconGradient: const [
                            Color(0xFFE3FBE9),
                            Color(0xFFC9F5D3),
                          ],
                          tagText: 'Ayo Bersiap',
                          tagColor: AppPalette.mintDeep,
                          tagBg: const Color(0xFFE3FBE9),
                          title: 'Siap Sebelum Gempa',
                          description:
                              'Menyiapkan kelas, rumah, dan tas siaga sebelum gempa datang.',
                          readTime: '3 menit baca',
                          topic: _getTopicById('pra_gempa'),
                        ),
                        _buildArticleCard(
                          context: context,
                          isNew: false,
                          icon: Icons.directions_walk_rounded,
                          iconGradient: const [
                            Color(0xFFEFE7FF),
                            Color(0xFFDED0FF),
                          ],
                          tagText: 'Ayo Evakuasi',
                          tagColor: AppPalette.grapeDeep,
                          tagBg: const Color(0xFFEFE7FF),
                          title: 'Setelah Gempa: Keluar dengan Aman',
                          description:
                              'Keluar dengan tertib dan waspada gempa susulan.',
                          readTime: '2 menit baca',
                          topic: _getTopicById('pasca_gempa'),
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

  Widget _buildTopBar(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
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
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Modul Belajar Siaga Gempa',
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
                  'BACA & KUMPULKAN POIN AKTIVITAS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.8,
                    color: Color(0xFFDDF4FF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
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

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppPalette.skyDeep.withValues(alpha: 0.55),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: -8,
            right: 54,
            child: Icon(Icons.cloud_rounded, size: 38, color: Colors.white38),
          ),
          const Positioned(
            bottom: 2,
            left: -8,
            child: Icon(Icons.cloud_rounded, size: 30, color: Colors.white24),
          ),
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) {
              return Positioned(
                top: 4,
                right: 96,
                child: Opacity(
                  opacity: _twinkle.value,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
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
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              );
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.6,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belajar Seru Sambil Membaca!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pahami penyebab gempa dan cara siaga menghadapinya, '
                      'bareng Kura Siaga!',
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
                  border: Border.all(color: AppPalette.sunny, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
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

  Widget _buildActivitySummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
      child: Row(
        children: [
          _buildSummaryItem(
            icon: Icons.bolt_rounded,
            iconColor: AppPalette.sunnyDeep,
            iconBg: AppPalette.sunnySoft,
            value: '${_progress.activityPoints}',
            label: 'Poin',
          ),
          _buildSummaryDivider(),
          _buildSummaryItem(
            icon: Icons.menu_book_rounded,
            iconColor: AppPalette.skyDeep,
            iconBg: AppPalette.skyMist,
            value:
                '${_progress.completedModuleCount}/${EducationData.topics.length}',
            label: 'Modul',
          ),
          _buildSummaryDivider(),
          _buildSummaryItem(
            icon: Icons.play_circle_fill_rounded,
            iconColor: AppPalette.coralDeep,
            iconBg: AppPalette.coralSoft,
            value: '${_progress.watchedVideoCount}',
            label: 'Video',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1.5,
      height: 34,
      color: AppPalette.lineBorder,
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.navy,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPromoBanner(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VideoListScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppPalette.headerGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.skyDeep.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Video Edukasi Online',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.navy,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.smart_display_rounded,
                            size: 18,
                            color: AppPalette.coralDeep.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tonton 4 video & kumpulkan poin aktivitas',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.inkSoft,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppPalette.skyDeep,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Semua Modul (4)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppPalette.navy,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '20 poin / modul',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppPalette.inkSoft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required BuildContext context,
    required bool isNew,
    required IconData icon,
    required List<Color> iconGradient,
    required String tagText,
    required Color tagColor,
    required Color tagBg,
    required String title,
    required String description,
    required String readTime,
    required EducationTopic topic,
  }) {
    final int percent = _progress.moduleReadPercent(topic.id);
    final int points = _progress.moduleActivityPoints(topic.id);
    final bool isComplete = percent >= 100;
    final String status = isComplete
        ? 'Selesai dibaca'
        : percent > 0
            ? 'Dibaca $percent%'
            : 'Belum dibaca';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.lineBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow3D,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.coral,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.coral.withValues(alpha: 0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'BARU',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: Icon(icon, size: 26, color: tagColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tagText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: tagColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.navy,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12.8,
                            color: AppPalette.inkSoft,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.sunnySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: AppPalette.sunnyDeep,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '+20 poin',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8A6300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    readTime,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : Icons.auto_stories_rounded,
                    size: 15,
                    color:
                        isComplete ? AppPalette.mintDeep : AppPalette.skyDeep,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isComplete
                            ? AppPalette.mintDeep
                            : AppPalette.inkSoft,
                      ),
                    ),
                  ),
                  Text(
                    '$points/20 poin',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: isComplete
                          ? AppPalette.mintDeep
                          : AppPalette.sunnyDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 7,
                  backgroundColor: AppPalette.lineBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppPalette.mintDeep : AppPalette.skyDeep,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EducationDetailScreen(topic: topic),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isComplete
                        ? AppPalette.mintGradient
                        : AppPalette.headerGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isComplete
                            ? AppPalette.forest
                            : AppPalette.skyDeep.withValues(alpha: 0.65),
                        blurRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          isComplete
                              ? 'Baca Ulang Modul'
                              : percent > 0
                                  ? 'Lanjut Baca Modul'
                                  : 'Baca & Kumpulkan Poin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

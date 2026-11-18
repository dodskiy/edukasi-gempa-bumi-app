class VideoEducationModel {
  final String id;
  final String youtubeId;
  final String title;
  final String category;
  final String duration;
  final String shortDescription;
  final String fullSummary;
  final List<String> learningPoints;
  final String youtubeUrl;

  const VideoEducationModel({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.category,
    required this.duration,
    required this.shortDescription,
    required this.fullSummary,
    required this.learningPoints,
    required this.youtubeUrl,
  });

  /// Mendapatkan URL thumbnail resmi dari YouTube
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
}

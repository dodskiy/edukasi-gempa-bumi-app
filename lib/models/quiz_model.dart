class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String hint;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.hint,
  });
}

class QuizBadge {
  final String title;
  final String description;
  final String iconEmoji;
  final int minScore;

  const QuizBadge({
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.minScore,
  });
}

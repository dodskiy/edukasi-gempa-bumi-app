import 'package:flutter/material.dart';

class DisasterBagItem {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final bool isEssential; // True jika wajib masuk Tas Siaga Bencana
  final String reason;

  const DisasterBagItem({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.isEssential,
    required this.reason,
  });
}

class DropCoverScenario {
  final String id;
  final String location;
  final String situation;
  final String imagePlaceholderText;
  final List<ScenarioAction> actions;

  const DropCoverScenario({
    required this.id,
    required this.location,
    required this.situation,
    required this.imagePlaceholderText,
    required this.actions,
  });
}

class ScenarioAction {
  final String actionText;
  final bool isCorrect;
  final String feedback;
  final IconData icon;

  const ScenarioAction({
    required this.actionText,
    required this.isCorrect,
    required this.feedback,
    required this.icon,
  });
}

import 'package:flutter/material.dart';

class EducationTopic {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final IconData icon;
  final Color color;
  final List<String> keyPoints;
  final String fullContent;
  final String malukuUtaraContext;
  final List<String> doAndDonts;

  /// Kalimat pendek yang mudah diingat siswa.
  final String remember;

  const EducationTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.icon,
    required this.color,
    required this.keyPoints,
    required this.fullContent,
    required this.malukuUtaraContext,
    required this.doAndDonts,
    this.remember = '',
  });
}

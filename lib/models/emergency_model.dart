import 'package:flutter/material.dart';

class EmergencyContact {
  final String name;
  final String region;
  final String phoneNumber;
  final String description;
  final IconData icon;

  const EmergencyContact({
    required this.name,
    required this.region,
    required this.phoneNumber,
    required this.description,
    required this.icon,
  });
}

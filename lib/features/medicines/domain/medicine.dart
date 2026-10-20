import 'package:flutter/material.dart';

class Medicine {
  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.intervalHours,
    required this.emoji,
    required this.color,
    this.lastGivenAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String dose;
  final int intervalHours;
  final String emoji;
  final Color color;
  DateTime? lastGivenAt;
  final DateTime createdAt;

  DateTime? get nextDoseAt => lastGivenAt?.add(Duration(hours: intervalHours));

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'dose': dose,
    'intervalHours': intervalHours,
    'emoji': emoji,
    'color': color.toARGB32(),
    'lastGivenAt': lastGivenAt?.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'] as String,
    name: json['name'] as String,
    dose: json['dose'] as String,
    intervalHours: json['intervalHours'] as int,
    emoji: json['emoji'] as String,
    color: Color(json['color'] as int),
    lastGivenAt: json['lastGivenAt'] == null
        ? null
        : DateTime.parse(json['lastGivenAt'] as String).toLocal(),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );
}

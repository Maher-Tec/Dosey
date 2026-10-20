import 'package:flutter/material.dart';

import 'medicine.dart';

class Dose {
  const Dose({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.doseLabel,
    required this.emoji,
    required this.color,
    required this.givenAt,
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final String doseLabel;
  final String emoji;
  final Color color;
  final DateTime givenAt;
  // The medicine name and dose label are snapshots for historical accuracy.

  factory Dose.forMedicine(Medicine medicine, DateTime givenAt) => Dose(
    id: givenAt.microsecondsSinceEpoch.toString(),
    medicineId: medicine.id,
    medicineName: medicine.name,
    doseLabel: medicine.dose,
    emoji: medicine.emoji,
    color: medicine.color,
    givenAt: givenAt,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'medicineId': medicineId,
    'medicineName': medicineName,
    'doseLabel': doseLabel,
    'emoji': emoji,
    'color': color.toARGB32(),
    'givenAt': givenAt.toUtc().toIso8601String(),
  };

  factory Dose.fromJson(Map<String, dynamic> json) => Dose(
    id: json['id'] as String,
    medicineId: json['medicineId'] as String,
    medicineName: json['medicineName'] as String,
    doseLabel: json['doseLabel'] as String,
    emoji: json['emoji'] as String,
    color: Color(json['color'] as int),
    givenAt: DateTime.parse(json['givenAt'] as String).toLocal(),
  );
}

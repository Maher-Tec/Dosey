import 'package:dose_reminder/features/medicines/domain/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('medicine timestamps round-trip as absolute UTC instants', () {
    final givenAt = DateTime(2026, 10, 17, 12, 30);
    final medicine = Medicine(
      id: 'medicine-1',
      name: 'Example medicine',
      dose: '1 unit',
      intervalHours: 6,
      emoji: '💊',
      color: Colors.pink,
      lastGivenAt: givenAt,
    );

    final encoded = medicine.toJson();
    final restored = Medicine.fromJson(Map<String, dynamic>.from(encoded));

    expect(encoded['lastGivenAt'], endsWith('Z'));
    expect(
      restored.lastGivenAt!.millisecondsSinceEpoch,
      givenAt.millisecondsSinceEpoch,
    );
    expect(
      restored.nextDoseAt!.millisecondsSinceEpoch,
      givenAt.add(const Duration(hours: 6)).millisecondsSinceEpoch,
    );
  });
}

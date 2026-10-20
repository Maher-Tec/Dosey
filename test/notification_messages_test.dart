import 'package:dose_reminder/features/medicines/data/notification_messages.dart';
import 'package:dose_reminder/features/medicines/domain/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final medicine = Medicine(
    id: 'medicine-1',
    name: 'Example medicine',
    dose: '1 unit',
    intervalHours: 6,
    emoji: '💊',
    color: Colors.pink,
  );

  test('Tunisian reminder keeps the medicine and dose visible', () {
    final title = NotificationMessages.title(medicine, derjaEnabled: true);
    final body = NotificationMessages.body(
      medicine,
      derjaEnabled: true,
      childName: 'votre enfant',
    );

    expect(title, contains('Wa9t el dwaa'));
    expect(title, contains('Example medicine'));
    expect(body, contains('Example medicine'));
    expect(body, contains('1 unit'));
  });
  test('French reminder title follows the Derja toggle', () {
    final title = NotificationMessages.title(medicine, derjaEnabled: false);
    expect(title, contains('Rappel'));
    expect(title, isNot(contains('Wa9t el dwaa')));
  });
}

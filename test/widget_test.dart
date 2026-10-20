import 'package:dose_reminder/features/medicines/presentation/screens/home_screen.dart';
import 'package:dose_reminder/features/medicines/presentation/widgets/medicine_card.dart';
import 'package:dose_reminder/features/medicines/domain/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a new installation shows the real empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            medicines: const [],
            doses: const [],
            childName: 'votre enfant',
            onOpen: (_) {},
            onGive: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Le petit carnet\nde votre enfant'), findsOneWidget);
    expect(
      find.text('Le carnet est prêt\npour ses premiers petits soins'),
      findsOneWidget,
    );
    expect(find.text('Example medicine'), findsNothing);
  });

  testWidgets('a recorded dose locks the action until the next due time', (
    tester,
  ) async {
    final medicine = Medicine(
      id: 'test-medicine',
      name: 'Test',
      dose: '1 unit',
      intervalHours: 6,
      emoji: '💊',
      color: Colors.pink.shade100,
      lastGivenAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MedicineCard(
            medicine: medicine,
            childName: 'votre enfant',
            onGive: () {},
            onOpen: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(find.bySubtype<ButtonStyleButton>())
          .onPressed,
      isNull,
    );
  });
}

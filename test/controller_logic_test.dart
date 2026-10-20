import 'package:dose_reminder/features/medicines/application/dose_reminder_controller.dart';
import 'package:dose_reminder/features/medicines/data/local_storage_service.dart';
import 'package:dose_reminder/features/medicines/data/notification_service.dart';
import 'package:dose_reminder/features/medicines/domain/dose.dart';
import 'package:dose_reminder/features/medicines/domain/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Storage implements MedicineStorage {
  List<Medicine> medicines = [];
  List<Dose> doses = [];
  @override
  Future<List<Medicine>> loadMedicines() async => List.of(medicines);
  @override
  Future<List<Dose>> loadDoses() async => List.of(doses);
  @override
  Future<bool> loadDerjaEnabled() async => true;
  @override
  Future<String> loadChildName() async => 'votre enfant';
  @override
  Future<void> saveMedicines(List<Medicine> value) async {
    medicines = List.of(value);
  }

  @override
  Future<void> saveDoses(List<Dose> value) async {
    doses = List.of(value);
  }

  @override
  Future<void> saveDerjaEnabled(bool value) async {}
  @override
  Future<void> saveChildName(String value) async {}
}

class _Notifications implements MedicineNotifications {
  bool enabled = false;
  bool grantOnRequest = false;
  int scheduledCount = 0;
  final cancelled = <String>[];
  @override
  bool get notificationsEnabled => enabled;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> refreshPermissionStatus() async => enabled;
  @override
  Future<bool> requestPermissions() async {
    enabled = grantOnRequest;
    return enabled;
  }

  @override
  Future<void> refreshLocalTimezone() async {}
  @override
  Future<bool> scheduleNextDose(
    Medicine medicine, {
    required bool derjaEnabled,
    required String childName,
  }) async {
    if (!enabled) return false;
    scheduledCount++;
    return true;
  }

  @override
  Future<void> cancelForMedicine(String medicineId) async {
    cancelled.add(medicineId);
  }
}

Medicine _medicine({
  String id = 'med-1',
  DateTime? lastGivenAt,
  int intervalHours = 6,
}) => Medicine(
  id: id,
  name: 'Example',
  dose: '1 unit',
  intervalHours: intervalHours,
  emoji: '💊',
  color: Colors.pink,
  lastGivenAt: lastGivenAt,
);

void main() {
  test(
    'permission granted after startup schedules existing due medicines',
    () async {
      final storage = _Storage()
        ..medicines = [
          _medicine(
            lastGivenAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          _medicine(
            id: 'med-overdue',
            lastGivenAt: DateTime.now().subtract(const Duration(hours: 8)),
          ),
        ];
      final notifications = _Notifications()..grantOnRequest = true;
      final controller = DoseReminderController(storage, notifications);
      await controller.initialize();
      expect(notifications.cancelled, ['med-1', 'med-overdue']);
      expect(notifications.scheduledCount, 0);
      expect(await controller.requestNotificationPermission(), isTrue);
      expect(notifications.scheduledCount, 1);
      controller.dispose();
    },
  );

  test('controller rejects an early dose without mutating history', () async {
    final storage = _Storage()
      ..medicines = [_medicine(lastGivenAt: DateTime.now())];
    final notifications = _Notifications()..enabled = true;
    final controller = DoseReminderController(storage, notifications);
    await controller.initialize();
    expect(
      () => controller.recordDose(controller.medicines.single),
      throwsA(
        isA<DoseRecordException>().having(
          (e) => e.failure,
          'failure',
          DoseRecordFailure.doseTooEarly,
        ),
      ),
    );
    expect(controller.doses, isEmpty);
    controller.dispose();
  });

  test(
    'system clock change cancels and reschedules only upcoming medicine IDs',
    () async {
      final storage = _Storage()
        ..medicines = [
          _medicine(
            lastGivenAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          _medicine(
            id: 'med-overdue',
            lastGivenAt: DateTime.now().subtract(const Duration(hours: 8)),
          ),
        ];
      final notifications = _Notifications()..enabled = true;
      final controller = DoseReminderController(storage, notifications);
      await controller.initialize();
      notifications.cancelled.clear();
      notifications.scheduledCount = 0;
      await controller.handleSystemTimeChange();
      expect(notifications.cancelled, ['med-1', 'med-overdue']);
      expect(notifications.scheduledCount, 1);
      controller.dispose();
    },
  );
  test(
    'editing reconciles the medicine alarm when it becomes overdue',
    () async {
      final storage = _Storage()
        ..medicines = [
          _medicine(
            lastGivenAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];
      final notifications = _Notifications()..enabled = true;
      final controller = DoseReminderController(storage, notifications);
      await controller.initialize();
      notifications.cancelled.clear();
      notifications.scheduledCount = 0;

      final updated = _medicine(
        lastGivenAt: DateTime.now().subtract(const Duration(hours: 2)),
        intervalHours: 1,
      );
      await controller.updateMedicine(updated);

      expect(notifications.cancelled, ['med-1']);
      expect(notifications.scheduledCount, 0);
      expect(controller.medicines.single.intervalHours, 1);
      controller.dispose();
    },
  );

  test(
    'deleting a medicine removes its linked dose history and alarm',
    () async {
      final medicine = _medicine(lastGivenAt: DateTime.now());
      final storage = _Storage()..medicines = [medicine];
      final notifications = _Notifications()..enabled = true;
      final controller = DoseReminderController(storage, notifications);
      await controller.initialize();

      await controller.deleteMedicine(medicine);

      expect(controller.medicines, isEmpty);
      expect(controller.doses, isEmpty);
      expect(storage.medicines, isEmpty);
      expect(storage.doses, isEmpty);
      expect(notifications.cancelled, contains('med-1'));
      controller.dispose();
    },
  );
}

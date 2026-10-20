import 'package:flutter/foundation.dart';

import '../data/local_storage_service.dart';
import '../data/notification_service.dart';
import '../domain/dose.dart';
import '../domain/medicine.dart';

class DoseRecordResult {
  const DoseRecordResult({
    required this.nextDoseAt,
    required this.reminderScheduled,
  });
  final DateTime nextDoseAt;
  final Future<bool> reminderScheduled;
}

enum DoseRecordFailure { medicineMissing, doseTooEarly, invalidTime }

class DoseRecordException implements Exception {
  const DoseRecordException(this.failure);
  final DoseRecordFailure failure;
}

class DoseReminderController extends ChangeNotifier {
  DoseReminderController(this._storage, this._notifications);
  final MedicineStorage _storage;
  final MedicineNotifications _notifications;
  final List<Medicine> _medicines = [];
  final List<Dose> _doses = [];
  int _selectedTab = 0;
  bool _derjaEnabled = true;
  String _childName = LocalStorageService.defaultChildName;
  bool _isLoading = true;
  bool _handlingSystemTimeChange = false;
  String? _loadError;
  String? _operationError;

  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<Dose> get doses => List.unmodifiable(_doses);
  int get selectedTab => _selectedTab;
  bool get derjaEnabled => _derjaEnabled;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;
  String? get operationError => _operationError;
  bool get notificationsEnabled => _notifications.notificationsEnabled;
  String get childName => _childName;
  Future<void> retryInitialize() async {
    _isLoading = true;
    _operationError = null;
    notifyListeners();
    await initialize();
  }

  void clearOperationError() {
    if (_operationError == null) return;
    _operationError = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final values = await Future.wait([
        _storage.loadMedicines(),
        _storage.loadDoses(),
        _storage.loadDerjaEnabled(),
        _storage.loadChildName(),
      ]);
      _medicines
        ..clear()
        ..addAll(values[0] as List<Medicine>);
      _doses
        ..clear()
        ..addAll(values[1] as List<Dose>);
      _derjaEnabled = values[2] as bool;
      _childName = values[3] as String;
      _loadError = null;
    } catch (_) {
      _loadError = 'Impossible de lire les données enregistrées.';
    }

    try {
      await _notifications.initialize();
      await _notifications.refreshPermissionStatus();
      // Clear stale alarms before restoring reminders after a process restart.
      final cancellations = await Future.wait(
        _medicines.map((medicine) => _cancelReminderSafely(medicine.id)),
      );
      await _rescheduleUpcomingReminders();
      if (cancellations.any((cancelled) => !cancelled)) {
        _operationError = 'Certains anciens rappels n’ont pas pu être annulés.';
      }
    } catch (_) {
      _operationError = 'Impossible de restaurer les rappels.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTab(int index) {
    if (_selectedTab == index) {
      return;
    }
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> setDerjaEnabled(bool value) async {
    if (_derjaEnabled == value) return;
    final previous = _derjaEnabled;
    _derjaEnabled = value;
    try {
      await _storage.saveDerjaEnabled(value);
      _operationError = null;
    } catch (_) {
      _derjaEnabled = previous;
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      return;
    }
    await _rescheduleUpcomingReminders();
    notifyListeners();
  }

  Future<bool> requestNotificationPermission() async {
    final enabled = await _notifications.requestPermissions();
    if (enabled) await _rescheduleUpcomingReminders(force: true);
    notifyListeners();
    return enabled;
  }

  Future<void> refreshNotificationPermissionStatus() async {
    final enabled = await _notifications.refreshPermissionStatus();
    if (enabled) await _rescheduleUpcomingReminders(force: true);
    notifyListeners();
  }

  Future<void> handleSystemTimeChange() async {
    if (_handlingSystemTimeChange) return;
    _handlingSystemTimeChange = true;
    try {
      await _notifications.refreshLocalTimezone();
      await _notifications.refreshPermissionStatus();
      final cancellations = await Future.wait(
        _medicines.map((medicine) => _cancelReminderSafely(medicine.id)),
      );
      await _rescheduleUpcomingReminders();
      if (cancellations.any((cancelled) => !cancelled)) {
        _operationError = 'Certains rappels anciens n’ont pas pu être annulés.';
      }
    } catch (_) {
      _operationError = 'Impossible de mettre à jour les rappels.';
    } finally {
      _handlingSystemTimeChange = false;
      notifyListeners();
    }
  }

  Future<bool> _cancelReminderSafely(String medicineId) async {
    try {
      await _notifications.cancelForMedicine(medicineId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setChildName(String value) async {
    final name = value.trim();
    if (name.isEmpty || name == _childName) return;
    final previous = _childName;
    _childName = name;
    try {
      await _storage.saveChildName(name);
      _operationError = null;
    } catch (_) {
      _childName = previous;
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      return;
    }
    await _rescheduleUpcomingReminders();
    notifyListeners();
  }

  Future<void> _rescheduleUpcomingReminders({bool force = false}) async {
    if (!force && !_notifications.notificationsEnabled) return;
    final now = DateTime.now();
    final upcoming = _medicines
        .where((medicine) => medicine.nextDoseAt?.isAfter(now) ?? false)
        .toList();
    final results = await Future.wait(
      upcoming.map(
        (medicine) => _notifications.scheduleNextDose(
          medicine,
          derjaEnabled: _derjaEnabled,
          childName: _childName,
        ),
      ),
    );
    if (results.any((scheduled) => !scheduled)) {
      _operationError = 'Certains rappels n’ont pas pu être programmés.';
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    _medicines.add(medicine);
    if (medicine.lastGivenAt != null) {
      _doses.insert(0, Dose.forMedicine(medicine, medicine.lastGivenAt!));
    }
    notifyListeners();
    try {
      await _storage.saveMedicines(_medicines);
      if (medicine.lastGivenAt != null) await _storage.saveDoses(_doses);
      _operationError = null;
    } catch (_) {
      _medicines.removeWhere((item) => item.id == medicine.id);
      _doses.removeWhere((dose) => dose.medicineId == medicine.id);
      try {
        await _storage.saveMedicines(_medicines);
        await _storage.saveDoses(_doses);
      } catch (_) {}
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      return;
    }
    await _rescheduleUpcomingReminders();
    notifyListeners();
  }

  Future<void> updateMedicine(Medicine updatedMedicine) async {
    final index = _medicines.indexWhere(
      (item) => item.id == updatedMedicine.id,
    );
    if (index == -1) return;
    final previous = _medicines[index];
    _medicines[index] = updatedMedicine;
    try {
      await _storage.saveMedicines(_medicines);
      _operationError = null;
    } catch (_) {
      _medicines[index] = previous;
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      return;
    }
    // Always reconcile this medicine's platform alarm after an edit. This also
    // removes an old alarm when the updated interval makes the next dose due.
    final cancelled = await _cancelReminderSafely(updatedMedicine.id);
    if (!cancelled) {
      _operationError = 'Ancien rappel non annulé.';
    } else if (updatedMedicine.nextDoseAt?.isAfter(DateTime.now()) ?? false) {
      final scheduled = await _notifications.scheduleNextDose(
        updatedMedicine,
        derjaEnabled: _derjaEnabled,
        childName: _childName,
      );
      if (!scheduled && _notifications.notificationsEnabled) {
        _operationError = 'Le médicament est modifié, mais le rappel a échoué.';
      }
    }
    notifyListeners();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    final oldMedicines = List<Medicine>.from(_medicines);
    final oldDoses = List<Dose>.from(_doses);
    _medicines.removeWhere((item) => item.id == medicine.id);
    _doses.removeWhere((dose) => dose.medicineId == medicine.id);
    try {
      await _storage.saveMedicines(_medicines);
      await _storage.saveDoses(_doses);
      _operationError = null;
    } catch (_) {
      _medicines
        ..clear()
        ..addAll(oldMedicines);
      _doses
        ..clear()
        ..addAll(oldDoses);
      try {
        await _storage.saveMedicines(oldMedicines);
        await _storage.saveDoses(oldDoses);
      } catch (_) {}
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      return;
    }
    final cancelled = await _cancelReminderSafely(medicine.id);
    if (!cancelled) {
      _operationError = 'Ancien rappel non annulé.';
    }
    notifyListeners();
  }

  Future<DoseRecordResult> recordDose(
    Medicine medicine, {
    DateTime? givenAt,
  }) async {
    final index = _medicines.indexWhere((item) => item.id == medicine.id);
    if (index < 0) {
      throw const DoseRecordException(DoseRecordFailure.medicineMissing);
    }
    final current = _medicines[index];
    final time = givenAt ?? DateTime.now();
    if (time.isAfter(DateTime.now())) {
      throw const DoseRecordException(DoseRecordFailure.invalidTime);
    }
    final dueAt = current.nextDoseAt;
    if (dueAt != null && time.isBefore(dueAt)) {
      throw const DoseRecordException(DoseRecordFailure.doseTooEarly);
    }

    final previousLastGivenAt = current.lastGivenAt;
    final previousDoses = List<Dose>.from(_doses);
    current.lastGivenAt = time;
    _doses.insert(0, Dose.forMedicine(current, time));
    try {
      await _storage.saveMedicines(_medicines);
      await _storage.saveDoses(_doses);
      _operationError = null;
    } catch (_) {
      current.lastGivenAt = previousLastGivenAt;
      _doses
        ..clear()
        ..addAll(previousDoses);
      try {
        await _storage.saveMedicines(_medicines);
        await _storage.saveDoses(previousDoses);
      } catch (_) {}
      _operationError = 'Impossible d’enregistrer les modifications.';
      notifyListeners();
      rethrow;
    }
    notifyListeners();
    final nextDoseAt = current.nextDoseAt!;
    var scheduled = false;
    try {
      scheduled = await _notifications.scheduleNextDose(
        current,
        derjaEnabled: _derjaEnabled,
        childName: _childName,
      );
    } catch (_) {
      _operationError = 'La dose est enregistrée, mais le rappel a échoué.';
      notifyListeners();
    }
    return DoseRecordResult(
      nextDoseAt: nextDoseAt,
      reminderScheduled: Future<bool>.value(scheduled),
    );
  }
}

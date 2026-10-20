import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/dose.dart';
import '../domain/medicine.dart';

abstract interface class MedicineStorage {
  Future<List<Medicine>> loadMedicines();
  Future<List<Dose>> loadDoses();
  Future<bool> loadDerjaEnabled();
  Future<String> loadChildName();
  Future<void> saveMedicines(List<Medicine> medicines);
  Future<void> saveDoses(List<Dose> doses);
  Future<void> saveDerjaEnabled(bool enabled);
  Future<void> saveChildName(String name);
}

class LocalStorageService implements MedicineStorage {
  static const _medicinesKey = 'medicines_v1';
  static const _dosesKey = 'doses_v1';
  static const _derjaKey = 'derja_enabled';
  static const _childNameKey = 'child_name';
  static const defaultChildName = 'votre enfant';

  @override
  Future<List<Medicine>> loadMedicines() async {
    final raw = (await SharedPreferences.getInstance()).getString(
      _medicinesKey,
    );
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map(
          (item) => Medicine.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<List<Dose>> loadDoses() async {
    final raw = (await SharedPreferences.getInstance()).getString(_dosesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => Dose.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<bool> loadDerjaEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_derjaKey) ?? true;
  @override
  Future<String> loadChildName() async =>
      (await SharedPreferences.getInstance()).getString(_childNameKey) ??
      defaultChildName;
  @override
  Future<void> saveMedicines(List<Medicine> medicines) async =>
      (await SharedPreferences.getInstance()).setString(
        _medicinesKey,
        jsonEncode(medicines.map((item) => item.toJson()).toList()),
      );
  @override
  Future<void> saveDoses(List<Dose> doses) async =>
      (await SharedPreferences.getInstance()).setString(
        _dosesKey,
        jsonEncode(doses.map((item) => item.toJson()).toList()),
      );
  @override
  Future<void> saveDerjaEnabled(bool enabled) async =>
      (await SharedPreferences.getInstance()).setBool(_derjaKey, enabled);
  @override
  Future<void> saveChildName(String name) async =>
      (await SharedPreferences.getInstance()).setString(_childNameKey, name);
}

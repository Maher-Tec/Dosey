import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'notification_messages.dart';
import '../domain/medicine.dart';

abstract interface class MedicineNotifications {
  bool get notificationsEnabled;
  Future<void> initialize();
  Future<bool> refreshPermissionStatus();
  Future<bool> requestPermissions();
  Future<void> refreshLocalTimezone();
  Future<bool> scheduleNextDose(
    Medicine medicine, {
    required bool derjaEnabled,
    required String childName,
  });
  Future<void> cancelForMedicine(String medicineId);
}

class NotificationService implements MedicineNotifications {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _notificationsEnabled = false;

  @override
  bool get notificationsEnabled => _notificationsEnabled;
  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    timezone_data.initializeTimeZones();
    try {
      final current = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(current.identifier));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
    await refreshPermissionStatus();
  }

  @override
  Future<bool> refreshPermissionStatus() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _notificationsEnabled = false;
      return false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      _notificationsEnabled = await android?.areNotificationsEnabled() ?? false;
    } else {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      _notificationsEnabled =
          (await ios?.checkPermissions())?.isEnabled ?? false;
    }
    return _notificationsEnabled;
  }

  @override
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
    return refreshPermissionStatus();
  }

  @override
  Future<void> refreshLocalTimezone() async {
    if (!_initialized) return;
    try {
      final current = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(current.identifier));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }
  }

  @override
  Future<bool> scheduleNextDose(
    Medicine medicine, {
    required bool derjaEnabled,
    required String childName,
  }) async {
    try {
      if (!await refreshPermissionStatus()) return false;
      final nextDoseAt = medicine.nextDoseAt;
      if (nextDoseAt == null || !nextDoseAt.isAfter(DateTime.now())) {
        return false;
      }
      final id = _notificationId(medicine.id);
      await _plugin.cancel(id: id);

      var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        var canScheduleExactly =
            await android?.canScheduleExactNotifications() ?? false;
        if (!canScheduleExactly) {
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      }

      await _plugin.zonedSchedule(
        id: id,
        title: NotificationMessages.title(medicine, derjaEnabled: derjaEnabled),
        body: NotificationMessages.body(
          medicine,
          derjaEnabled: derjaEnabled,
          childName: childName,
        ),
        scheduledDate: timezone.TZDateTime.from(nextDoseAt, timezone.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminders',
            'Rappels médicaments',
            channelDescription: 'Rappels des prochaines doses',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            icon: 'ic_stat_dose_reminder',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: scheduleMode,
        payload: medicine.id,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cancelForMedicine(String medicineId) =>
      _plugin.cancel(id: _notificationId(medicineId));

  int _notificationId(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = (hash * 37 + unit) & 0x7fffffff;
    }
    return hash;
  }
}

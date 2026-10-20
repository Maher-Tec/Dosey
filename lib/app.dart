import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/medicines/application/dose_reminder_controller.dart';
import 'features/medicines/data/local_storage_service.dart';
import 'features/medicines/data/notification_service.dart';
import 'features/medicines/presentation/screens/app_shell.dart';

class DoseReminderApp extends StatefulWidget {
  const DoseReminderApp({super.key});

  @override
  State<DoseReminderApp> createState() => _DoseReminderAppState();
}

class _DoseReminderAppState extends State<DoseReminderApp> {
  late final DoseReminderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DoseReminderController(
      LocalStorageService(),
      NotificationService(),
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dosey',
      theme: AppTheme.light,
      home: AppShell(controller: _controller),
    );
  }
}
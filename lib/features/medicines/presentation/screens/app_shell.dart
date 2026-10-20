import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/dose_reminder_controller.dart';
import '../../domain/medicine.dart';
import '../widgets/add_medicine_sheet.dart';
import '../widgets/edit_medicine_sheet.dart';
import '../widgets/medicine_detail_sheet.dart';
import '../widgets/dose_recorded_dialog.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});
  final DoseReminderController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  DoseReminderController get controller => widget.controller;
  static const _systemTimeChannel = MethodChannel('dose_reminder/system_time');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _systemTimeChannel.setMethodCallHandler((call) async {
      if (call.method == 'timeChanged') {
        await controller.handleSystemTimeChange();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _systemTimeChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.handleSystemTimeChange();
    }
  }

  Future<void> _addMedicine(BuildContext context) async {
    final medicine = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SafeArea(top: false, child: AddMedicineSheet()),
    );
    if (medicine != null) await controller.addMedicine(medicine);
  }

  Future<void> _editMedicine(BuildContext context, Medicine medicine) async {
    final updated = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SafeArea(top: false, child: EditMedicineSheet(medicine: medicine)),
    );
    if (updated != null) await controller.updateMedicine(updated);
  }

  Future<void> _deleteMedicine(BuildContext context, Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce médicament ?'),
        content: Text(
          '« ${medicine.name} » et son historique de doses seront supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteMedicine(medicine);
  }

  Future<void> _recordDose(BuildContext context, Medicine medicine) async {
    late final DoseRecordResult result;
    try {
      result = await controller.recordDose(medicine);
    } on DoseRecordException catch (error) {
      final message = switch (error.failure) {
        DoseRecordFailure.doseTooEarly => 'Cette dose est encore trop tôt.',
        DoseRecordFailure.invalidTime =>
          'L’heure saisie ne peut pas être dans le futur.',
        DoseRecordFailure.medicineMissing =>
          'Ce médicament n’est plus disponible.',
      };
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’enregistrer cette dose.')),
      );
      return;
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => DoseRecordedDialog(
        medicine: medicine,
        nextDoseAt: result.nextDoseAt,
        reminderScheduled: result.reminderScheduled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: PastelBackground(
            child: SafeArea(
              child: Column(
                children: [
                  if (controller.loadError != null ||
                      controller.operationError != null)
                    MaterialBanner(
                      content: Text(
                        controller.loadError ?? controller.operationError!,
                      ),
                      actions: [
                        TextButton(
                          onPressed: controller.loadError != null
                              ? controller.retryInitialize
                              : controller.clearOperationError,
                          child: Text(
                            controller.loadError != null
                                ? 'Réessayer'
                                : 'Fermer',
                          ),
                        ),
                      ],
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(.025, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _activeScreen(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: controller.selectedTab == 0
              ? FloatingActionButton.extended(
                  onPressed: () => _addMedicine(context),
                  backgroundColor: AppTheme.rose,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter'),
                )
              : null,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x1598677A),
                  blurRadius: 22,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: controller.selectedTab,
              onDestinationSelected: controller.selectTab,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.blush,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_rounded),
                  label: 'Historique',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Réglages',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _activeScreen(BuildContext context) {
    return switch (controller.selectedTab) {
      0 => HomeScreen(
        key: const ValueKey('home'),
        medicines: controller.medicines,
        doses: controller.doses,
        childName: controller.childName,
        onGive: (medicine) => _recordDose(context, medicine),
        onOpen: (medicine) => showDialog<void>(
          context: context,
          builder: (_) => MedicineDetailSheet(
            medicine: medicine,
            doses: controller.doses,
            onEdit: () {
              Navigator.pop(context);
              _editMedicine(context, medicine);
            },
            onDelete: () {
              Navigator.pop(context);
              _deleteMedicine(context, medicine);
            },
          ),
        ),
      ),
      1 => HistoryScreen(
        key: const ValueKey('history'),
        doses: controller.doses,
      ),
      _ => SettingsScreen(
        key: const ValueKey('settings'),
        derjaEnabled: controller.derjaEnabled,
        onDerjaChanged: controller.setDerjaEnabled,
        notificationsEnabled: controller.notificationsEnabled,
        onEnableNotifications: controller.requestNotificationPermission,
        childName: controller.childName,
        onChildNameChanged: controller.setChildName,
      ),
    };
  }
}

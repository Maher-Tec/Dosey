import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/edit_child_profile_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.derjaEnabled,
    required this.onDerjaChanged,
    required this.notificationsEnabled,
    required this.onEnableNotifications,
    required this.childName,
    required this.onChildNameChanged,
  });
  final bool derjaEnabled;
  final ValueChanged<bool> onDerjaChanged;
  final bool notificationsEnabled;
  final Future<bool> Function() onEnableNotifications;
  final String childName;
  final Future<void> Function(String) onChildNameChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
    children: [
      const Text(
        'Mon petit cocon',
        style: TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          color: AppTheme.ink,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Des réglages simples, rien de compliqué ✨',
        style: TextStyle(color: AppTheme.muted),
      ),
      const SizedBox(height: 24),
      _SettingCard(
        color: AppTheme.sky,
        icon: '🔔',
        title: 'Rappels de dose',
        subtitle: notificationsEnabled
            ? 'Actifs — Doudou veille sur la prochaine dose'
            : 'Active-les pour ne manquer aucune dose',
        trailing: notificationsEnabled
            ? const _StatusPill(label: 'Activés', color: Color(0xFF4C9488))
            : FilledButton(
                onPressed: () async {
                  final enabled = await onEnableNotifications();
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (_) => _PermissionDialog(enabled: enabled),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                child: const Text('Activer'),
              ),
      ),
      const SizedBox(height: 13),
      _SettingCard(
        color: AppTheme.blush,
        icon: '😄',
        title: 'Mode Derja',
        subtitle: 'Une touche tunisienne dans les rappels',
        trailing: Switch(
          value: derjaEnabled,
          onChanged: onDerjaChanged,
          activeThumbColor: AppTheme.rose,
        ),
      ),
      const SizedBox(height: 13),
      _SettingCard(
        color: AppTheme.butter,
        icon: '👶',
        title: 'Profil de $childName',
        subtitle: 'Appuie ici pour modifier le prénom',
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.muted,
        ),
        onTap: () async {
          final name = await showDialog<String>(
            context: context,
            builder: (_) => EditChildProfileDialog(initialName: childName),
          );
          if (name != null) await onChildNameChanged(name);
        },
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.butter,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Reminder only, not medical advice. Always follow the label and your doctor.',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4EDF8), Color(0xFFFFF1F5)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppTheme.roseDark),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Données stockées sur cet appareil',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Aucun serveur. Données locales non chiffrées. Les sauvegardes iOS dépendent des réglages système.',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });
  final Color color;
  final String icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: color),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B98677A),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800),
    ),
  );
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog({required this.enabled});
  final bool enabled;
  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: Text(enabled ? '🔔' : '🌙', style: const TextStyle(fontSize: 40)),
    title: Text(
      enabled ? 'Les rappels sont activés' : 'Les rappels restent désactivés',
    ),
    content: Text(
      enabled
          ? 'Doudou pourra te prévenir à la prochaine dose.'
          : 'Tu peux les autoriser plus tard depuis les réglages du téléphone.',
      textAlign: TextAlign.center,
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Compris'),
      ),
    ],
  );
}

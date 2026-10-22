import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dose.dart';
import '../../domain/medicine.dart';
import '../widgets/doudou_mascot.dart';
import '../widgets/medicine_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.medicines,
    required this.doses,
    required this.onGive,
    required this.onOpen,
    required this.childName,
  });

  final List<Medicine> medicines;
  final List<Dose> doses;
  final ValueChanged<Medicine> onGive;
  final ValueChanged<Medicine> onOpen;
  final String childName;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.blush,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '🌷  Bonjour',
                    style: TextStyle(
                      color: AppTheme.roseDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Le petit carnet\nde $childName',
                  style: const TextStyle(
                    fontSize: 32,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            image: true,
            label: 'Dosey logo',
            child: Container(
              width: 112,
              height: 112,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD5E2), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2298677A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      if (medicines.isEmpty)
        const _EmptyState()
      else ...[
        _MissionBanner(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aujourd’hui',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.ink,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${medicines.length} actif${medicines.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...medicines.map(
          (medicine) => MedicineCard(
            medicine: medicine,
            childName: childName,
            onGive: () => onGive(medicine),
            onOpen: () => onOpen(medicine),
          ),
        ),
      ],
    ],
  );
}

class _MissionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFDDF4EE), Color(0xFFE8F5FF)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Text('💗', style: TextStyle(fontSize: 24)),
        ),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission du jour : petits soins, grands câlins',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF356E67),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Doudou garde le carnet bien au chaud.',
                style: TextStyle(color: Color(0xFF51827B), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: const Color(0xFFFFE0E9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1298677A),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: const Column(
      children: [
        DoudouMascot(size: 145),
        SizedBox(height: 10),
        Text(
          'Le carnet est prêt\npour ses premiers petits soins',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: AppTheme.ink,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Ajoute un traitement avec le bouton rose, et Doudou gardera les doses et les rappels au chaud.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.muted, height: 1.45),
        ),
        SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.muted),
            SizedBox(width: 5),
            Text(
              'Données privées sur cet appareil',
              style: TextStyle(fontSize: 11, color: AppTheme.muted),
            ),
          ],
        ),
      ],
    ),
  );
}

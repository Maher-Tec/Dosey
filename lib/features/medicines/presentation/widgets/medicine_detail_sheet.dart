import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dose.dart';
import '../../domain/medicine.dart';

class MedicineDetailSheet extends StatelessWidget {
  const MedicineDetailSheet({
    super.key,
    required this.medicine,
    required this.doses,
    required this.onEdit,
    required this.onDelete,
  });

  final Medicine medicine;
  final List<Dose> doses;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  List<Dose> get _todayDoses {
    final now = DateTime.now();
    return doses.where((dose) {
      return dose.medicineId == medicine.id &&
          dose.givenAt.year == now.year &&
          dose.givenAt.month == now.month &&
          dose.givenAt.day == now.day;
    }).toList()..sort((a, b) => b.givenAt.compareTo(a.givenAt));
  }

  @override
  Widget build(BuildContext context) {
    final todayDoses = _todayDoses;
    final nextDose = medicine.nextDoseAt;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDFB),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: medicine.color.withValues(alpha: .55)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3398677A),
              blurRadius: 34,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Fermer',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: medicine.color.withValues(alpha: .35),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  medicine.emoji,
                  style: const TextStyle(fontSize: 39),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              medicine.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${medicine.dose}  •  toutes les ${medicine.intervalHours}h',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE8F0), Color(0xFFFFF1D9)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    '${todayDoses.length}',
                    style: const TextStyle(
                      color: AppTheme.roseDark,
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    todayDoses.length == 1
                        ? 'prise aujourd’hui, bravo !'
                        : 'prises aujourd’hui',
                    style: const TextStyle(
                      color: AppTheme.roseDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (todayDoses.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: todayDoses
                      .map(
                        (dose) => _TimeChip(
                          label:
                              '${dose.givenAt.hour.toString().padLeft(2, '0')}:${dose.givenAt.minute.toString().padLeft(2, '0')}',
                        ),
                      )
                      .toList(),
                ),
              )
            else
              const Text(
                'Pas encore notée aujourd’hui — Doudou veille. 💛',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
            if (nextDose != null) ...[
              const SizedBox(height: 17),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Prochaine dose : ${nextDose.hour.toString().padLeft(2, '0')}:${nextDose.minute.toString().padLeft(2, '0')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF39776E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('C’est noté ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F8F6),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      '✓ $label',
      style: const TextStyle(
        color: Color(0xFF39776E),
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

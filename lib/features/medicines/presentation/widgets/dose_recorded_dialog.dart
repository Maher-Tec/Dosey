import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/medicine.dart';
import 'doudou_mascot.dart';

class DoseRecordedDialog extends StatelessWidget {
  const DoseRecordedDialog({
    super.key,
    required this.medicine,
    required this.nextDoseAt,
    required this.reminderScheduled,
  });
  final Medicine medicine;
  final DateTime nextDoseAt;
  final Future<bool> reminderScheduled;

  String get _nextTime =>
      '${nextDoseAt.hour.toString().padLeft(2, '0')}:${nextDoseAt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF5F8), Colors.white],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFD9E4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2998677A),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DoudouMascot(size: 104),
          const Text(
            'Bravo !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'La dose est bien notée, Doudou est fier 🌷',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: medicine.color.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(
              children: [
                Text(medicine.emoji, style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                      Text(
                        medicine.dose,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF58A494),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<bool>(
            future: reminderScheduled,
            builder: (context, snapshot) {
              final waiting = snapshot.connectionState != ConnectionState.done;
              final scheduled = snapshot.data ?? false;
              final positive = waiting || scheduled;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: positive ? AppTheme.mint : AppTheme.butter,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    if (waiting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Color(0xFF39776E),
                        ),
                      )
                    else
                      Icon(
                        scheduled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        color: positive
                            ? const Color(0xFF39776E)
                            : const Color(0xFF9B7533),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        waiting
                            ? 'Programmation du rappel…'
                            : scheduled
                            ? 'Rappel programmé à $_nextTime'
                            : 'Prochaine dose à $_nextTime\nRappel non programmé — vérifie les autorisations',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: positive
                              ? const Color(0xFF39776E)
                              : const Color(0xFF8A682D),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'C’est noté 💗',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

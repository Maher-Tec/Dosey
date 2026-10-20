import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dose.dart';
import '../widgets/doudou_mascot.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.doses});
  final List<Dose> doses;
  String _time(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  String _day(DateTime value) {
    final today = DateTime.now();
    if (value.year == today.year &&
        value.month == today.month &&
        value.day == today.day) {
      return "Aujourd'hui";
    }
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
    children: [
      const Text(
        'Les petits soins',
        style: TextStyle(
          fontSize: 31,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          color: AppTheme.ink,
        ),
      ),
      const SizedBox(height: 5),
      const Text(
        'Chaque petit soin, gardé avec amour 🌷',
        style: TextStyle(color: AppTheme.muted),
      ),
      const SizedBox(height: 24),
      if (doses.isEmpty)
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .88),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            children: [
              DoudouMascot(size: 120),
              SizedBox(height: 12),
              Text(
                'Pas encore de dose notée',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Doudou remplira ce carnet dès le premier petit soin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
            ],
          ),
        )
      else
        ...doses.asMap().entries.map((entry) {
          final dose = entry.value;
          final showDay =
              entry.key == 0 ||
              _day(doses[entry.key - 1].givenAt) != _day(dose.givenAt);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDay)
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Text(
                    _day(dose.givenAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: dose.color,
                      child: Text(
                        dose.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dose.medicineName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                            ),
                          ),
                          Text(
                            dose.doseLabel,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.mint,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        _time(dose.givenAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF39776E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
    ],
  );
}

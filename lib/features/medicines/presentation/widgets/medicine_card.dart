import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/medicine.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onGive,
    required this.onOpen,
    required this.childName,
  });
  final Medicine medicine;
  final VoidCallback onGive;
  final VoidCallback onOpen;
  final String childName;
  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  late final Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  bool get _waiting {
    final next = widget.medicine.nextDoseAt;
    return next != null && next.isAfter(_now);
  }

  String get _status {
    final next = widget.medicine.nextDoseAt;
    if (next == null) return 'Première dose à noter';
    if (!_waiting) return "C'est l'heure — ${widget.childName} attend 🌼";
    final remaining = next.difference(_now);
    return 'Prochaine dose dans ${remaining.inHours}h${(remaining.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _waiting;
    final ready = !waiting;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.medicine.color.withValues(alpha: .55),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1098677A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onOpen,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.medicine.color,
                            widget.medicine.color.withValues(alpha: .48),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          widget.medicine.emoji,
                          style: const TextStyle(fontSize: 29),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.medicine.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.medicine.dose}  •  toutes les ${widget.medicine.intervalHours}h',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ready
                        ? const Color(0xFFFFEBE4)
                        : const Color(0xFFF1F8F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ready
                            ? Icons.notifications_active_rounded
                            : Icons.schedule_rounded,
                        size: 19,
                        color: ready
                            ? const Color(0xFFDE725D)
                            : const Color(0xFF4C9488),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _status,
                          style: TextStyle(
                            color: ready
                                ? const Color(0xFFB75646)
                                : const Color(0xFF39776E),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: waiting ? null : widget.onGive,
                    icon: Icon(
                      waiting
                          ? Icons.check_circle_rounded
                          : Icons.favorite_rounded,
                      size: 18,
                    ),
                    label: Text(
                      waiting ? 'Dose donnée ✓' : 'Donné maintenant',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.rose,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDDF0EB),
                      disabledForegroundColor: const Color(0xFF39776E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

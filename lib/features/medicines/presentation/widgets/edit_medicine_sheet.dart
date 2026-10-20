import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/medicine.dart';

class EditMedicineSheet extends StatefulWidget {
  const EditMedicineSheet({super.key, required this.medicine});
  final Medicine medicine;

  @override
  State<EditMedicineSheet> createState() => _EditMedicineSheetState();
}

class _EditMedicineSheetState extends State<EditMedicineSheet> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  final _formKey = GlobalKey<FormState>();
  late int _interval;
  late String _emoji;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.medicine.name);
    _dose = TextEditingController(text: widget.medicine.dose);
    _interval = widget.medicine.intervalHours;
    _emoji = widget.medicine.emoji;
    _color = widget.medicine.color;
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Medicine(
        id: widget.medicine.id,
        name: _name.text.trim(),
        dose: _dose.text.trim(),
        intervalHours: _interval,
        emoji: _emoji,
        color: _color,
        lastGivenAt: widget.medicine.lastGivenAt,
        createdAt: widget.medicine.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Modifier le médicament',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Indique le nom du médicament'
                  : null,
              decoration: const InputDecoration(labelText: 'Nom du médicament'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dose,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Indique la dose exacte'
                  : null,
              decoration: const InputDecoration(labelText: 'Dose exacte'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(child: Text('Intervalle entre les doses')),
                Text('${_interval}h'),
              ],
            ),
            Slider(
              value: _interval.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              onChanged: (v) => setState(() => _interval = v.round()),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['🧸', '☀️', '🌈', '💊', '🦋']
                  .map(
                    (emoji) => ChoiceChip(
                      label: Text(emoji),
                      selected: _emoji == emoji,
                      onSelected: (_) => setState(() => _emoji = emoji),
                    ),
                  )
                  .toList(),
            ),
            Wrap(
              spacing: 8,
              children:
                  [
                        AppTheme.blush,
                        AppTheme.sky,
                        AppTheme.mint,
                        AppTheme.butter,
                        const Color(0xFFEDE2FA),
                      ]
                      .map(
                        (color) => GestureDetector(
                          onTap: () => setState(() => _color = color),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: color,
                            child: _color == color
                                ? const Icon(Icons.check, size: 14)
                                : null,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
